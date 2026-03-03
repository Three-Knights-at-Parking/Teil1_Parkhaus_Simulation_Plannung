//////////////////////////////////////////////////////////
// Module: Stats
// @author: ibach
//////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////
// Lifecycle: initialize & create /free container
//////////////////////////////////////////////////////////

// Brief: Sets all pointers, sums, and totals to defined
// initial values. Must be executed once before the first tick call.
FUNCTION StatsTick_init(p_StatList, capacity_total, current_tick)

    p_CurrentTick <- ALLOCATE(StatsTick)

    IF p_StatList = NULL THEN
        return ERROR
    END IF

    IF current_tick = NULL THEN
            return ERROR
    END IF

    IF capacity_total = NULL THEN
           return ERROR
    END IF

    //Moving the Current Tick into the StatList and moving the pushing the last tick back
    IF p_StatList.p_tick_head = NULL THEN
        p_StatList.p_tick_head <- p_CurrentTick
        struct StatsTick *p_prev <- NULL
    ELSE
        IF p_StatList.p_current_tick = NULL THEN
            return ERROR
        END IF
        p_CurrentTick.p_prev <- p_StatList.p_tick_tail
        p_StatList.p_tick_tail.p_next <- p_StatList.p_current_tick
        p_StatList.p_tick_tail <- p_StatList.p_current_tick
        p_StatList.p_current_tick <- p_CurrentTick
    END IF

    current_tick <- current_tick

    capacity_total <- capacity_total
    capacity_taken <- 0
    capacity_free <- 0

    arrivals_generated <- 0
    enqueued <- 0
    entered <- 0
    departed <- 0

    queue_length_end <- 0
    queue_rejections <- 0
    queue_wait_entered_sum_ticks <- 0
    queue_wait_entered_count <- 0
    queue_wait_max_ticks_tick <- 0

    parking_duration_departed_sum_ticks <- 0
    parking_duration_departed_count <- 0

    blocker_full_active <- 0
    bad_parking_cases <- 0

    return OK
END FUNCTION


FUNCTION StatList_init(p_simulation)

    IF p_simulation = NULL THEN
        return ERROR
    END IF

    p_StatList <- ALLOCATE(StatList)
    IF p_StatList = NULL THEN
        return ERROR
    END IF

    p_tick_head <- NULL
    p_tick_tail <- NULL
    p_current_tick <- NULL

    RETURN p_StatList

END FUNCTION


FUNCTION StatList_free(p_StatList)

    IF p_StatList = NULL THEN
        return ERROR
    END IF

    FREE(p_StatList)

    RETURN OK

END FUNCTION


FUNCTION StatsTick_free(p_stats)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    p_current <- p_stats.p_tick_head
    WHILE p_current != NULL DO
        p_next <- p_current.p_next
        FREE(p_current)
        p_current <- p_next
    END WHILE

    p_stats.p_tick_head <- NULL
    p_stats.p_tick_tail <- NULL
    p_stats.p_current_tick <- NULL

    return OK
END FUNCTION


//////////////////////////////////////////////////////////
// Tick raw values: set/add functions
//////////////////////////////////////////////////////////

// Brief: Sets the capacity raw values for the current tick.
FUNCTION stats_tick_set_capacity(p_stats, taken, free)

    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.capacity_taken <- taken
    p_tick.capacity_free <- free
    p_tick.capacity_total <- taken + free

    return OK
END FUNCTION


// Brief: Increments number of newly generated arrivals in current tick.
FUNCTION stats_tick_add_arrivals_generated(p_stats, amount)

    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.arrivals_generated <- p_tick.arrivals_generated + amount

    return OK
END FUNCTION


// Brief: Increments the number of queue rejections in the current tick.
FUNCTION stats_tick_add_queue_rejections(p_stats, amount)

    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.queue_rejections <- p_tick.queue_rejections + amount

    return OK
END FUNCTION


// Brief: Marks whether the "full" blocker was active in the tick.
FUNCTION stats_tick_add_blocker_full_active(p_stats)

    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.blocker_full_active <- p_tick.blocker_full_active + 1

    return OK
END FUNCTION


// Brief: Derives and writes all useful vehicle metrics into current tick.
FUNCTION stats_tick_add_vehicle(p_stats, p_vehicle, current_tick)

    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL OR p_vehicle = NULL THEN
        return ERROR
    END IF

    // Vehicle entered this tick -> entered counter + queue wait sample.
    IF p_vehicle.park_house_entered = current_tick THEN
        p_tick.entered <- p_tick.entered + 1

        IF p_vehicle.park_house_entered >= p_vehicle.created_at_tick THEN
            wait_ticks <- p_vehicle.park_house_entered - p_vehicle.created_at_tick
            p_tick.queue_wait_entered_sum_ticks <- p_tick.queue_wait_entered_sum_ticks + wait_ticks
            p_tick.queue_wait_entered_count <- p_tick.queue_wait_entered_count + 1
            IF wait_ticks > p_tick.queue_wait_max_ticks_tick THEN
                p_tick.queue_wait_max_ticks_tick <- wait_ticks
            END IF
        END IF
    END IF

    // Vehicle left this tick -> departed counter + parking duration sample.
    IF p_vehicle.park_house_left = current_tick THEN
        p_tick.departed <- p_tick.departed + 1

        IF p_vehicle.park_house_left >= p_vehicle.park_house_entered THEN
            duration_ticks <- p_vehicle.park_house_left - p_vehicle.park_house_entered
            p_tick.parking_duration_departed_sum_ticks <- p_tick.parking_duration_departed_sum_ticks + duration_ticks
            p_tick.parking_duration_departed_count <- p_tick.parking_duration_departed_count + 1
        END IF
    END IF

    // Car-specific rule quality metric: required spaces exceed minimum spaces.
    IF p_vehicle.base.type = CAR THEN
        p_car <- (Car) p_vehicle
        IF p_car.spaces_needed > p_car.minimum_spaces THEN
            p_tick.bad_parking_cases <- p_tick.bad_parking_cases + 1
        END IF
    END IF

    return OK
END FUNCTION


//////////////////////////////////////////////////////////
// Access/compatibility
//////////////////////////////////////////////////////////


FUNCTION stats_get_latest_tick(p_stats)
    IF p_stats = NULL THEN
        return NULL
    END IF
    return p_stats.p_tick_tail
END FUNCTION


//////////////////////////////////////////////////////////
// Summary Builder
//////////////////////////////////////////////////////////
// Brief: Builds the final overall statistics by iterating all stored
// tick snapshots in StatList sequentially in a loop
// and transferring them into the external result object.

FUNCTION stats_build_summary(p_stats, p_summary)

    IF p_stats = NULL OR p_summary = NULL THEN
        return ERROR
    END IF

    MEMSET(p_summary, 0, SIZEOF(StatsSummary))
    p_summary.first_full_tick <- -1

    sum_capacity_taken_percent <- 0
    sum_queue_length_end <- 0
    sum_entered <- 0
    sum_departed <- 0
    sum_queue_wait_entered_ticks <- 0
    sum_queue_wait_entered_count <- 0
    sum_parking_duration_departed_ticks <- 0
    sum_parking_duration_departed_count <- 0
    queue_active_ticks <- 0
    blocker_full_ticks <- 0

    p_next_tick <- p_stats.p_tick_head
    WHILE p_next_tick != NULL DO
        p_tick <- p_next_tick
        p_summary.total_ticks <- p_summary.total_ticks + 1

        p_summary.arrivals_total <- p_summary.arrivals_total + p_tick.arrivals_generated
        p_summary.enqueued_total <- p_summary.enqueued_total + p_tick.enqueued
        p_summary.entered_total <- p_summary.entered_total + p_tick.entered
        p_summary.departed_total <- p_summary.departed_total + p_tick.departed
        p_summary.net_occupancy_change_total <- p_summary.net_occupancy_change_total + (p_tick.entered - p_tick.departed)
        p_summary.queue_rejections_total <- p_summary.queue_rejections_total + p_tick.queue_rejections
        p_summary.bad_parking_cases_total <- p_summary.bad_parking_cases_total + p_tick.bad_parking_cases

        IF p_tick.capacity_total > 0 THEN
            current_capacity_percent <- (p_tick.capacity_taken * 100.0) / p_tick.capacity_total
        ELSE
            current_capacity_percent <- 0
        END IF

        sum_capacity_taken_percent <- sum_capacity_taken_percent + current_capacity_percent
        sum_queue_length_end <- sum_queue_length_end + p_tick.queue_length_end
        sum_entered <- sum_entered + p_tick.entered
        sum_departed <- sum_departed + p_tick.departed

        IF p_tick.capacity_free = 0 THEN
            p_summary.full_ticks <- p_summary.full_ticks + 1
            IF p_summary.first_full_tick < 0 THEN
                p_summary.first_full_tick <- p_tick.tick
            END IF
        END IF

        IF current_capacity_percent > p_summary.capacity_taken_percent_peak THEN
            p_summary.capacity_taken_percent_peak <- current_capacity_percent
            p_summary.capacity_taken_peak_tick <- p_tick.tick
        END IF

        IF p_tick.queue_length_end > p_summary.queue_length_peak THEN
            p_summary.queue_length_peak <- p_tick.queue_length_end
            p_summary.queue_length_peak_tick <- p_tick.tick
        END IF

        IF p_tick.queue_length_end > 0 THEN
            queue_active_ticks <- queue_active_ticks + 1
        END IF

        IF p_tick.blocker_full_active = 1 THEN
            blocker_full_ticks <- blocker_full_ticks + 1
        END IF

        sum_queue_wait_entered_ticks <- sum_queue_wait_entered_ticks + p_tick.queue_wait_entered_sum_ticks
        sum_queue_wait_entered_count <- sum_queue_wait_entered_count + p_tick.queue_wait_entered_count
        IF p_tick.queue_wait_max_ticks_tick > p_summary.queue_wait_max_ticks THEN
            p_summary.queue_wait_max_ticks <- p_tick.queue_wait_max_ticks_tick
        END IF

        sum_parking_duration_departed_ticks <- sum_parking_duration_departed_ticks + p_tick.parking_duration_departed_sum_ticks
        sum_parking_duration_departed_count <- sum_parking_duration_departed_count + p_tick.parking_duration_departed_count

        IF p_summary.total_ticks = 1 THEN
            p_summary.capacity_total <- p_tick.capacity_total
        END IF

        p_next_tick <- p_tick.p_next
    END WHILE

    IF p_summary.total_ticks > 0 THEN
        // Utilization average includes all ticks. Ticks with capacity_total=0
        // contribute 0% utilization by definition.
        p_summary.capacity_taken_percent_avg <- sum_capacity_taken_percent / p_summary.total_ticks
        p_summary.entered_per_tick_avg <- sum_entered / p_summary.total_ticks
        p_summary.departed_per_tick_avg <- sum_departed / p_summary.total_ticks
        p_summary.queue_length_avg <- sum_queue_length_end / p_summary.total_ticks
        p_summary.queue_active_ratio_percent <- (queue_active_ticks * 100.0) / p_summary.total_ticks
        p_summary.blocker_full_ratio_percent <- (blocker_full_ticks * 100.0) / p_summary.total_ticks
    END IF

    // Wait average is only valid with at least one wait sample.
    IF sum_queue_wait_entered_count > 0 THEN
        p_summary.queue_wait_avg_ticks <- sum_queue_wait_entered_ticks / sum_queue_wait_entered_count
    ELSE
        // Explicit fallback implementation for missing basis data.
        p_summary.queue_wait_avg_ticks <- 0
    END IF

    // Parking-duration average is only valid with at least one departed sample.
    IF sum_parking_duration_departed_count > 0 THEN
        p_summary.parking_duration_avg_ticks <- sum_parking_duration_departed_ticks / sum_parking_duration_departed_count
    ELSE
        // Explicit fallback implementation for missing basis data.
        p_summary.parking_duration_avg_ticks <- 0
    END IF

    // Bad-parking share is only valid if entered_total > 0.
    IF p_summary.entered_total > 0 THEN
        p_summary.bad_parking_share_percent <- (p_summary.bad_parking_cases_total * 100.0) / p_summary.entered_total
    ELSE
        // Explicit fallback implementation for missing basis data.
        p_summary.bad_parking_share_percent <- 0
    END IF

    return OK
END FUNCTION

