//////////////////////////////////////////////////////////
// Module: parkhaus
// Dependencies: queue, vehicle_list, stats_model, rng
//////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////
// Initialization and basic helpers
//////////////////////////////////////////////////////////
FUNCTION parkhaus_init(p_parkhaus, p_settings, p_gate_queues)
    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    IF p_settings = NULL THEN
        RETURN ERROR
    END IF

    IF p_gate_queues = NULL THEN
        RETURN ERROR
    END IF

    p_parkhaus.base.id   <- 0
    p_parkhaus.base.type <- PARKHAUS
    p_parkhaus.base.tick <- parkhaus_tick
    p_parkhaus.capacity       <- p_settings.capacity
    p_parkhaus.floors         <- p_settings.floors
    p_parkhaus.capacity_taken <- 0


    // Init gate queues array and parked-vehicle list pointers
    p_parkhaus.gate_queues   <- p_gate_queues
    p_parkhaus.p_parked_head <- NULL
    p_parkhaus.p_parked_tail <- NULL

     RETURN OK
END FUNCTION

//Moving this to Stats -> Data Analyse 
FUNCTION parkhaus_get_utilization(p_parkhaus)
     IF p_parkhaus = NULL THEN
         RETURN 0.0
     END IF

     IF p_parkhaus.capacity = 0 THEN // CHANGED: from size
         RETURN 0.0
     END IF

      utilization <- (p_parkhaus.capacity_taken * 100) / p_parkhaus.capacity
      RETURN utilization
END FUNCTION


//////////////////////////////////////////////////////////
// Tick logic for Parkhaus (outer tick) / Primary Function
// @author: ibach
//////////////////////////////////////////////////////////

FUNCTION parkhaus_tick(p_self, p_settings, p_StatList, current_tick)
    // cast SimulationObject* to Parkhaus*
    p_parkhaus <- (Parkhaus) p_self

    /**
    * Free up spaces first to make space for the next cars.
    * Cars that have reached max_tick will leave here.
    */
    status <- parkhouse_tick_empty_general(
                  current_tick,
                  p_parkhaus,
                  p_settings,       // or p_sim.settings
                  p_StatList,
                  p_parkhaus.p_parked_head
              )
    IF status != 0 THEN
        RETURN
    END IF
    IF p_settings.num_gates = 1 THEN

        status <- parkhouse_tick_fill_general(
                      current_tick,
                      p_parkhaus,
                      p_settings,
                      p_StatList,
                      p_parkhaus.queue,
                      p_parkhaus.p_parked_head
                  )
        RETURN status
    ELSE
        // subtick based filling according to
        // https://github.com/Three-Knights-at-Parking/Teil1_Documentation/issues/16
        status <- parkhouse_fill_subtick(
                      current_tick,
                      p_parkhaus,
                      p_settings,
                      p_StatList,
                      p_parkhaus.queues
                  )
         // The gate_time scenario on exit is temporarily ignored
         //IF ((p_settings.num_gates > 1) AND settings.gate_time_exit_enabled) THEN
         //
         //    parkhouse_tick_empty_subtick(current_tick, settings, parkhouse, stats)
         //    parkhouse_fill_subtick(current_tick, parkhouse, settings, gate_queues)
         //    RETURN OK
         //END IF
        RETURN status
    END IF
END FUNCTION


//////////////////////////////////////////////////////////
// Emptying vehicles from Parkhaus
// - Checks if parked cars need to leave
// - no Gate_Exit_Time
// @author: ibach
//////////////////////////////////////////////////////////
FUNCTION parkhouse_tick_empty_general(current_tick, p_parkhaus, p_settings, p_StatList, p_vehicle_list_head)
    currentNode  <- p_vehicle_list_head
    previousNode <- NULL

    WHILE currentNode != NULL DO
        nextNode <- currentNode.p_next

        created_at   <- currentNode.created_at
        parking_time <- currentNode.parking_time
        leave_tick   <- created_at + parking_time
        IF current_tick >= leave_tick THEN
            // remove this vehicle from Parkhaus and free its space
            // updating StatsTick
            vehicle_leaving(p_parkhaus, p_StatList, p_vehicle_list_head, currentNode)
        END IF

        currentNode <- nextNode
    END WHILE

    RETURN OK
END FUNCTION


//////////////////////////////////////////////////////////
// Single-gate filling per tick
// -> Single gate entry
// @author: ibach
//////////////////////////////////////////////////////////

FUNCTION parkhouse_tick_fill_general(current_tick, p_parkhaus, p_settings, p_StatList, p_gate_queue, p_vehicle_list_head)

    // demand is number of vehicles that want to enter at this gate
    demand_remaining <- Queue_GetDemand(p_gate_queue)

    max_entries_per_tick <- p_settings.max_entries_per_tick
    queue_max_len        <- p_settings.queue_max_len

    entries_processed <- 0
    queue_blocked     <- FALSE

    WHILE (get_open_space(p_parkhaus) > 0) AND
          (entries_processed < max_entries_per_tick) AND
          (demand_remaining > 0) AND
          (queue_blocked = FALSE) DO

        // Is there something in the queue? If not, create a new vehicle in the queue
        IF Queue_IsEmpty(p_gate_queue) THEN

            queue_add_random_vehicle(p_gate_queue, current_tick, p_settings)
            demand_remaining <- demand_remaining - 1

        END IF

        IF NOT Queue_IsEmpty(p_gate_queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(p_gate_queue)

            IF next_vehicle_size <= get_open_space(p_parkhaus) THEN

                required_space <- fill_from_queue(p_parkhaus, p_gate_queue, p_vehicle)
                update_on_vehicle_entry(p_parkhaus, p_StatList, p_vehicle, required_space, current_tick)
                entries_processed <- entries_processed + 1

            ELSE // Waiting vehicle is too large to enter -> Entry Blocked
                queue_blocked <- TRUE
                stats_tick_set_blocker_full_active(p_StatsList)

            END IF
        END IF
    END WHILE

    // remaining demand goes into queue or gets rejected
    IF demand_remaining > 0 THEN
        open_demand(p_StatList, p_gate_queue, queue_max_len, demand_remaining, current_tick, p_settings)
    END IF

    RETURN OK
END FUNCTION


//////////////////////////////////////////////////////////
// Multi-gate subtick filling
// @author: ibach
//////////////////////////////////////////////////////////

FUNCTION parkhouse_fill_subtick(current_tick, p_parkhaus, p_settings, p_StatsList, p_gate_queues)

    number_of_gates      <- p_settings.num_gates
    max_entries_per_tick <- p_settings.max_entries_per_tick


    m <- 0
    WHILE m < max_entries_per_tick DO

        // last cycle if this is the last subtick
        IF m == (max_entries_per_tick - 1) THEN
            lastCycle <- TRUE
        ELSE
            lastCycle <- FALSE
        END IF

        i <- 0
        WHILE i < number_of_gates DO
            p_gate_queue <- Queue_GetGateQueue(p_gate_queues, i)

            parkhouse_fill_subtick_routine(
                    current_tick,
                    p_parkhaus,
                    p_settings,
                    p_StatList,
                    p_gate_queue,
                    lastCycle
            )
            i <- i + 1
        END WHILE

        m <- m + 1
    END WHILE

    RETURN OK
END FUNCTION


// @brief: In this function the single subtick will be run
// @author: ibach
// -> parallel checking of all Entrys for an euqal entry possibility
FUNCTION parkhouse_fill_subtick_routine(current_tick, p_parkhaus, p_settings, p_StatsList, p_gate_queue, lastCycle)


    required_space   <- 0
    demand_remaining <- Queue_GetDemand(p_gate_queue)

    IF (get_open_space(p_parkhaus) > 0) AND (demand_remaining > 0) THEN

        // If the queue is empty, a new front vehicle is created
        IF Queue_IsEmpty(p_gate_queue) THEN
            queue_add_random_vehicle(p_gate_queue, current_tick, p_settings)
            demand_remaining <- demand_remaining - 1
        END IF

        // If the queue is then not empty, the first list element is moved into the garage
        IF NOT Queue_IsEmpty(p_gate_queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(p_gate_queue)

            // Check whether the vehicle fits in the garage
            IF next_vehicle_size <= get_open_space(p_parkhaus) THEN
                required_space <- fill_from_queue(p_parkhaus, p_gate_queue, p_vehicle)
                update_on_vehicle_entry(p_parkhaus, p_StatList, p_vehicle, required_space, current_tick)
            ELSE
                stats_tick_set_blocker_full_active(p_StatsList)
            END IF
        END IF
    END IF

    IF (demand_remaining > 0) AND (lastCycle = TRUE) THEN
        //Stats?
        open_demand(p_StatList, p_gate_queue, queue_max_len, demand_remaining, current_tick, p_settings)
    END IF

    RETURN OK
END FUNCTION

//////////////////////////////////////////////////////////
// Queue / vehicle helper functions
// @author: ibach
//////////////////////////////////////////////////////////

FUNCTION parkhaus_enqueue_at_gate(p_parkhaus, gate_index, p_vehicle)
    p_gate_queue <- p_parkhaus.gate_queues[gate_index]
    IF p_gate_queue = NULL THEN
        RETURN ERROR
    END IF
    status <- queue_push_back(p_gate_queue, p_vehicle)
    RETURN status
END FUNCTION


FUNCTION parkhaus_set_gate_demand(p_parkhaus, gate_index, demand_value)
    p_gate_queue <- p_parkhaus.gate_queues[gate_index]
    IF p_gate_queue = NULL THEN
        RETURN ERROR
    END IF
    p_gate_queue.demand <- demand_value
    RETURN OK
END FUNCTION


FUNCTION queue_add_random_vehicle(p_gate_queue, current_tick, p_settings)

    p_vehicle <- create_random_vehicle(current_tick, p_settings)
    IF p_vehicle = NULL THEN
        RETURN ERROR
    END IF

    status <- queue_enqueue(p_gate_queue, p_vehicle)

    IF status != OK THEN
        FREE(p_vehicle)
        RETURN status
    END IF

    RETURN status
END FUNCTION

FUNCTION create_random_vehicle(current_tick, p_settings)

    // For now, only cars are generated.
    created_at <- current_tick
    parking_time <- rng_parking_time(p_settings.min_parking_ticks, p_settings.max_parking_ticks)
    spaces_needed <- Car_Space

    p_vehicle <- car_create(created_at, parking_time, spaces_needed)
    IF p_vehicle = NULL THEN
        RETURN NULL
    END IF

    RETURN (GenericVehicle) p_vehicle
END FUNCTION


FUNCTION park_vehicle(p_parkhaus, p_vehicle)
    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    IF p_vehicle = NULL THEN
        RETURN ERROR
    END IF

    vehicle_list_append(&p_parkhaus.p_parked_head, &p_parkhaus.p_parked_tail, p_vehicle)

    RETURN OK
END FUNCTION


FUNCTION fill_from_queue(p_parkhous, p_gate_queue, pp_vehicle)

    p_vehicle <- Queue_PopFront(p_gate_queue)
    IF p_vehicle = NULL THEN
        RETURN 0
    END IF

    IF pp_vehicle != NULL THEN
        pp_vehicle <- p_vehicle
    END IF

    p_car <- (Car) p_vehicle
    required_space <- p_car.minimum_spaces

    // Bad parking is only possible if double space is available
    IF get_open_space(p_parkhous) >= 2 * required_space THEN
        r <- rng_percent()
        // Assumption for now: 2% chance for bad parking.
        IF r < 2 THEN
            required_space <- 2 * required_space
        END IF
    END IF

    // Store resulting occupied space on vehicle for leaving logic.
    p_car.spaces_needed <- required_space

    status <- park_vehicle(p_parkhous, p_vehicle)
    IF status != OK THEN
        // safety: free dequeued node if it cannot be parked
        FREE(p_vehicle)
        RETURN ERROR
    END IF

    RETURN required_space
END FUNCTION


FUNCTION open_demand(p_StatList, p_gate_queue, queue_max_len, demand_remaining, current_tick, p_settings)

    status <- OK
    open_demand <- demand_remaining

    // Remaining possible entries into the queue
    WHILE (open_demand > 0) AND (Queue_Length(p_gate_queue) < queue_max_len) DO
        queue_add_random_vehicle(p_gate_queue, current_tick, p_settings)
        open_demand <- open_demand - 1
    END WHILE

    // Remaining possible entries that do not fit in queue -> rejected
    IF open_demand > 0 THEN
        status = stats_tick_add_queue_rejections(p_StatList, open_demand)
    END IF

    IF status != OK THEN
        RETURN ERROR
    ELSE
        RETURN status
    END IF
END FUNCTION


FUNCTION vehicle_leaving(p_parkhaus, p_StatList, p_vehicle_list_head, p_vehicle)

    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    IF p_vehicle = NULL THEN
        RETURN ERROR
    END IF

    p_StatsTick <- p_StatList.p_current_tick
    IF p_StatsTick = NULL THEN
        RETURN ERROR
    END IF

    p_car <- (Car) p_vehicle

    //Saving Data from Vehicle into Stats
    update_on_vehicle_exit(p_parkhaus, p_StatList, p_vehicle, p_car.spaces_needed, p_StatsTick.tick)
    vehicle_list_remove(p_parkhaus.parked_head, p_parkhaus.parked_tail, p_vehicle)

    FREE(p_vehicle)

    RETURN OK
END FUNCTION


//////////////////////////////////////////////////////////
// Small helpers for Parkhaus capacity & stats
// @author: ibach
//////////////////////////////////////////////////////////

FUNCTION get_open_space(p_parkhaus)

    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    RETURN p_parkhaus.capacity - p_parkhaus.capacity_taken
END FUNCTION


FUNCTION update_on_vehicle_exit(p_parkhaus, p_StatList, p_vehicle, required_space, current_tick)

    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    IF p_StatList = NULL THEN
        RETURN ERROR
    END IF

    p_StatsTick <- p_StatList.p_current_tick
    IF p_StatsTick = NULL THEN
        RETURN ERROR
    END IF

    IF p_vehicle = NULL THEN
        RETURN ERROR
    END IF

    IF required_space = 0 THEN
        RETURN ERROR
    END IF

    //Saving Data from Vehicle into Stats
    p_parkhaus.capacity_taken <- p_parkhaus.capacity_taken - required_space
    p_StatsTick.departed <- p_StatsTick.departed + 1
    stats_tick_add_vehicle(p_StatList, p_vehicle, current_tick)

    RETURN
END FUNCTION


FUNCTION update_on_vehicle_entry(p_parkhaus, p_StatList, p_vehicle, required_space, current_tick)

    IF p_parkhaus = NULL THEN
        RETURN ERROR
    END IF

    IF p_StatList = NULL THEN
        RETURN ERROR
    END IF

    p_StatsTick <- p_StatList.p_current_tick
    IF p_StatsTick = NULL THEN
        RETURN ERROR
    END IF

    IF p_vehicle = NULL THEN
        RETURN ERROR
    END IF

    IF required_space = 0 THEN
        RETURN ERROR
    END IF

    //Saving Data from Vehicle into Stats
    p_parkhaus.capacity_taken <- p_parkhaus.capacity_taken + required_space
    p_StatsTick.entered <- p_StatsTick.entered + 1
    stats_tick_add_vehicle(p_StatList, p_vehicle, current_tick)

    RETURN
END FUNCTION


//////////////////////////////////////////////////////////
// Parkhaus free
// @author: luca
//////////////////////////////////////////////////////////

FUNCTION parkhaus_free(p_parkhaus)
    IF p_parkhaus = NULL THEN
        RETURN
    END IF

    // free all parked vehicles. Same as before,
    // freeing is only valid if we collect statistics
    // before this. Otherwise data is lost!
    vehicle_list_remove_all(&p_parkhaus.parked_head, &p_parkhaus.parked_tail)


    // free all associated gate queues (Parkhaus is owner)
    IF p_parkhaus.gate_queues != NULL THEN
        i <- 0
        p_gate_queue <- p_parkhaus.gate_queues[i]

        WHILE p_gate_queue != NULL DO
            p_gate_queue <- p_parkhaus.gate_queues[i]
            queue_free(p_gate_queue)
            FREE(p_gate_queue)
            p_parkhaus.gate_queues[i] <- NULL

            i <- i + 1
        END WHILE

        FREE(p_parkhaus.gate_queues)
        p_parkhaus.gate_queues <- NULL
    END IF

    RETURN
END FUNCTION
