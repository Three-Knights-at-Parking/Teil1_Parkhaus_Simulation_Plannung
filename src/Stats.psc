//////////////////////////////////////////////////////////
// Module: Stats
// Dependencies: types, parkhaus, queue
//@author: ibach
//////////////////////////////////////////////////////////
// Description:
// This module manages the complete statistics pipeline of the simulation.
//
// 1) Tick recording (raw values)
//    - A tick is started with `stats_tick_begin`.
//    - During the tick, raw data is collected via `stats_tick_add_*`
//      and `stats_tick_set_*`.
//
// 2) Tick finalization
//    - `stats_tick_finalize` validates the current tick builder.
//    - `stats_tick_commit` appends the tick to history
//      (doubly linked list).
//
// 3) Overall statistics
//    - `StatsSummary` stores sums, averages, and peak values.
//    - Aggregation is computed on demand at the end from all stored
//      ticks, recalculated step by step.
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// Lifecycle: initialize/free container
//////////////////////////////////////////////////////////

// Brief: Sets all pointers, sums, and totals to defined
// initial values. Must be executed once before the first tick call.
FUNCTION stats_init(p_stats, capacity_total)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    p_stats.p_tick_head <- NULL
    p_stats.p_tick_tail <- NULL
    p_stats.p_current_tick <- NULL

    return OK
END FUNCTION

//////////////////////////////////////////////////////////
// Lifecycle: begin/finalize/commit tick
//////////////////////////////////////////////////////////

// Brief: Creates a new tick builder for the specified tick index.
// After that, tick raw values may be captured via add/set functions.
FUNCTION stats_tick_begin(p_stats, tick)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    IF p_stats.p_current_tick != NULL THEN
        return ERROR
    END IF

    p_tick <- ALLOCATE(StatsTick)
    IF p_tick = NULL THEN
        return ERROR
    END IF

    MEMSET(p_tick, 0, SIZEOF(StatsTick))
    p_tick.tick <- tick
    p_tick.capacity_total <- 0

    p_stats.p_current_tick <- p_tick
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

// Brief: Increments number of vehicles taken into queue.
FUNCTION stats_tick_add_enqueued(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.enqueued <- p_tick.enqueued + amount
    return OK
END FUNCTION

// Brief: Increments number of vehicles that actually entered.
FUNCTION stats_tick_add_entered(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.entered <- p_tick.entered + amount
    return OK
END FUNCTION

// Brief: Increments number of departing vehicles.
FUNCTION stats_tick_add_departed(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.departed <- p_tick.departed + amount
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

// Brief: Sets queue length at end of tick.
FUNCTION stats_tick_set_queue_length_end(p_stats, queue_length_end)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.queue_length_end <- queue_length_end
    return OK
END FUNCTION

// Brief: Adds wait time + counter for entered vehicles.
FUNCTION stats_tick_add_entered_queue_wait(p_stats, wait_ticks)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.queue_wait_entered_sum_ticks <- p_tick.queue_wait_entered_sum_ticks + wait_ticks
    p_tick.queue_wait_entered_count <- p_tick.queue_wait_entered_count + 1
    IF wait_ticks > p_tick.queue_wait_max_ticks_tick THEN
        p_tick.queue_wait_max_ticks_tick <- wait_ticks
    END IF
    return OK
END FUNCTION

// Brief: Adds parking duration + counter for departed vehicles.
FUNCTION stats_tick_add_departed_parking_duration(p_stats, duration_ticks)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.parking_duration_departed_sum_ticks <- p_tick.parking_duration_departed_sum_ticks + duration_ticks
    p_tick.parking_duration_departed_count <- p_tick.parking_duration_departed_count + 1
    return OK
END FUNCTION

// Brief: Sets number of bad parking cases for the tick.
FUNCTION stats_tick_set_bad_parking_cases(p_stats, bad_cases)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.bad_parking_cases <- bad_cases
    return OK
END FUNCTION

// Brief: Incrementally increases bad parking cases for the tick.
FUNCTION stats_tick_add_bad_parking_cases(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.bad_parking_cases <- p_tick.bad_parking_cases + amount
    return OK
END FUNCTION

// Brief: Marks whether the "full" blocker was active in the tick.
FUNCTION stats_tick_add_blocker_full_active(p_stats, active)
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

// Brief: Validates the tick builder before commit (currently without derived metrics).
FUNCTION stats_tick_finalize(p_stats)
    IF p_stats = NULL OR p_stats.p_current_tick = NULL THEN
        return ERROR
    END IF
    return OK
END FUNCTION

// Brief: Appends the tick to history.
FUNCTION stats_tick_commit(p_stats)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.p_prev <- p_stats.p_tick_tail
    p_tick.p_next <- NULL

    IF p_stats.p_tick_tail = NULL THEN
        p_stats.p_tick_head <- p_tick
    ELSE
        p_stats.p_tick_tail.p_next <- p_tick
    END IF

    p_stats.p_tick_tail <- p_tick
    p_stats.p_current_tick <- NULL

    return OK
END FUNCTION

//////////////////////////////////////////////////////////
// Access/compatibility
//////////////////////////////////////////////////////////

// Brief: Compatibility function for existing call sites.
FUNCTION Stats_RecordTick(p_stats, current_tick)
    status <- stats_tick_begin(p_stats, current_tick)
    IF status != OK THEN
        return status
    END IF

    status <- stats_tick_finalize(p_stats)
    IF status != OK THEN
        return status
    END IF

    return stats_tick_commit(p_stats)
END FUNCTION


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

FUNCTION stats_free(p_stats)
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
