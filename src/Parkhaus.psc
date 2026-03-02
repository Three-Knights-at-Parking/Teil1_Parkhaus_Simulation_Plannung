//////////////////////////////////////////////////////////
// Modul: parkhaus
// Abhaengigkeiten: queue, vehicle_list, stats_model, rng
//////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////
// Initialization and basic helpers
//////////////////////////////////////////////////////////
FUNCTION parkhaus_init(p_parkhaus, p_settings, p_gate_queues)
    IF p_parkhaus = NULL THEN
        return -1
    END IF

    IF p_settings = NULL THEN
        return -1
    END IF

    // basic fields from Settings
    p_parkhaus.base.id   <- 0
    p_parkhaus.base.type <- PARKHAUS
    p_parkhaus.base.tick <- parkhaus_tick

    p_parkhaus.size      <- p_settings.size
    p_parkhaus.floors    <- p_settings.floors
    p_parkhaus.fill_size <- 0
    p_parkhaus.num_gates <- p_settings.gates
    p_parkhaus.missed_car_entries <- 0

    // p_parkhaus.name <- "Rauenegg" or p_settings.name

    // init gate queues and parked-vehicle list
    p_parkhaus.gate_queues    <- p_gate_queues
    p_parkhaus.p_parked_head  <- NULL

    return 0
END FUNCTION



FUNCTION parkhaus_has_free_slot(p_parkhaus)
    IF p_parkhaus = NULL THEN
        return 0
    END IF

    // free slots = total size - currently filled
    free_slots <- p_parkhaus.size - p_parkhaus.fill_size

    IF free_slots > 0 THEN
        return 1
    ELSE
        return 0
    END IF
END FUNCTION


FUNCTION parkhaus_get_utilization(p_parkhaus)
    IF p_parkhaus = NULL THEN
        return 0.0
    END IF

    IF p_parkhaus.size = 0 THEN
        return 0.0
    END IF

    utilization <- (p_parkhaus.fill_size * 100.0) / p_parkhaus.size
    return utilization
END FUNCTION


//////////////////////////////////////////////////////////
// Tick logic for Parkhaus (outer tick) / Primary Function
//////////////////////////////////////////////////////////

FUNCTION parkhaus_tick(p_self, current_tick)
    // cast SimulationObject* to Parkhaus*
    p_parkhaus <- (Parkhaus) p_self

    /**
    * Free up spaces first to make space for the next cars.
    * Cars that have reached max_tick will leave here.
    */
    status <- parkhouse_tick_empty_general(
                  current_tick,
                  p_parkhaus,
                  p_parkhaus.settings,       // or p_sim.settings
                  p_parkhaus.p_parked_head
              )
    IF status != 0 THEN
        return
    END IF
    IF p_parkhaus.num_gates = 1 THEN

        status <- parkhouse_tick_fill_general(
                      current_tick,
                      p_parkhaus,
                      p_parkhaus.settings,
                      p_parkhaus.p_parked_head,
                      p_parkhaus.queue
                  )
        return
    ELSE
        // subtick based filling according to
        // https://github.com/Three-Knights-at-Parking/Teil1_Documentation/issues/16
        status <- parkhouse_fill_subtick(
                      current_tick,
                      p_parkhaus,
                      p_parkhaus.settings,
                      p_parkhaus.queue
                  )
         // Das Szenario mit gate_time beim Exit wird voruebergehend vernachlaessigt
         //IF ((settings.number_of_gates > 1) AND settings.gate_time_exit_enabled) THEN
         //
         //    parkhouse_tick_empty_subtick(current_tick, settings, parkhouse, stats)
         //    parkhouse_fill_subtick(current_tick, parkhouse, settings, gate_queues)
         //    RETURN OK
         //END IF
        return
    END IF
END FUNCTION


//////////////////////////////////////////////////////////
// Emptying vehicles from Parkhaus
//////////////////////////////////////////////////////////
@brief Checks if parked cars need to leave
FUNCTION parkhouse_tick_empty_general(current_tick, p_parkhaus, p_settings, p_car_list_head)
    currentNode  <- p_car_list_head
    previousNode <- NULL

    WHILE currentNode != NULL DO
        nextNode <- currentNode.p_next

        created_at   <- currentNode.created_at
        parking_time <- currentNode.parking_time
        leave_tick   <- created_at + parking_time
        IF current_tick >= leave_tick THEN
            // remove this car from Parkhaus and free its space
            car_leaving(p_parkhaus, p_car_list_head, currentNode)
        END IF

        currentNode <- nextNode
    END WHILE

    return 0
END FUNCTION


//////////////////////////////////////////////////////////
// Single-gate filling per tick
//////////////////////////////////////////////////////////

FUNCTION parkhouse_tick_fill_general(current_tick, p_parkhaus, p_settings, p_car_list_head, p_gate_queue)

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

        // Liegt etwas in der Queue? Wenn nein, erstelle neues Vehicle in Queue
        IF Queue_IsEmpty(p_gate_queue) THEN
            queue_add_random_vehicle(p_gate_queue)
            demand_remaining <- demand_remaining - 1
        END IF

        IF NOT Queue_IsEmpty(p_gate_queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(p_gate_queue)

            IF next_vehicle_size <= get_open_space(p_parkhaus) THEN
                required_space <- fill_from_queue(p_gate_queue, get_open_space(p_parkhaus))
                update_parkhouse_on_entry(p_parkhaus, required_space)
                entries_processed <- entries_processed + 1
            ELSE // Anstehendes Fahrzeug zu gross um einzufahren
                queue_blocked <- TRUE
            END IF
        END IF
    END WHILE

    // remaining demand goes into queue or gets rejected
    IF demand_remaining > 0 THEN
        open_demand(p_parkhaus, p_gate_queue, queue_max_len, demand_remaining)
    END IF

    return 0
END FUNCTION


//////////////////////////////////////////////////////////
// Multi-gate subtick filling
//////////////////////////////////////////////////////////

FUNCTION parkhouse_fill_subtick(current_tick, p_parkhaus, p_settings, p_gate_queues)

    number_of_gates      <- p_parkhaus.num_gates
    max_entries_per_tick <- p_settings.max_entries_per_tick

    m <- 0
    WHILE m < max_entries_per_tick DO

        // last cycle if this is the last subtick
        IF m = (max_entries_per_tick - 1) THEN
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
                p_gate_queue,
                lastCycle
            )

            i <- i + 1
        END WHILE

        m <- m + 1
    END WHILE

    return 0
END FUNCTION


FUNCTION parkhouse_fill_subtick_routine(current_tick, p_parkhaus, p_settings, p_gate_queue, lastCycle)

    queue_blocked    <- FALSE
    required_space   <- 0
    demand_remaining <- Queue_GetDemand(p_gate_queue)

    IF (get_open_space(p_parkhaus) > 0) AND (demand_remaining > 0) THEN

        // Wenn die Queue leer ist, wird ein neues Front Vehicle erstellt
        IF Queue_IsEmpty(p_gate_queue) THEN
            queue_add_random_vehicle(p_gate_queue)
            demand_remaining <- demand_remaining - 1
        END IF

        // Wenn die Queue infolge nicht leer ist, wird das erste Element der Liste in das Parkhaus uebernommen
        IF NOT Queue_IsEmpty(p_gate_queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(p_gate_queue)

            // Kontrolle ob Vehicle in Parkhaus passt
            IF next_vehicle_size <= get_open_space(p_parkhaus) THEN
                required_space <- fill_from_queue(p_gate_queue, get_open_space(p_parkhaus))
                update_parkhaus_on_entry(p_parkhaus, required_space)
            END IF
        END IF
    END IF

    IF (demand_remaining > 0) AND (lastCycle = TRUE) THEN
        open_demand(p_parkhaus, p_gate_queue, p_settings.queue_max_len, demand_remaining)
    END IF

    return 0
END FUNCTION


//////////////////////////////////////////////////////////
// Queue / vehicle helper functions
//////////////////////////////////////////////////////////

FUNCTION parkhaus_enqueue_at_gate(p_parkhaus, gate_index, p_vehicle)
    p_gate_queue <- p_parkhaus.gate_queues[gate_index]
    IF p_gate_queue = NULL THEN
        return -1
    END IF
    status <- queue_push_back(p_gate_queue, p_vehicle)
    return status
END FUNCTION

FUNCTION parkhaus_set_gate_demand(p_parkhaus, gate_index, demand_value)
    p_gate_queue <- p_parkhaus.gate_queues[gate_index]
    IF p_gate_queue = NULL THEN
        return -1
    END IF
    p_gate_queue.demand <- demand_value
    return 0
END FUNCTION

FUNCTION queue_add_random_vehicle(p_gate_queue)

    p_vehicle <- create_random_vehicle()
    status <- queue_enqueue(p_gate_queue, p_vehicle)

    return status
END FUNCTION

FUNCTION fill_from_queue(p_gate_queue, parkhouse_open_space)

    vehicle <- Queue_PopFront(p_gate_queue)

    base_space     <- GetVehicleBaseSpace(vehicle)
    required_space <- base_space

    // Bad parking only possible if double space is available
    IF parkhouse_open_space >= 2 * base_space THEN
        r <- RandomPercent()
        IF r < GetBadParkingProbability(vehicle) THEN
            required_space <- 2 * base_space
        END IF
    END IF

    // park this vehicle in Parkhaus (caller will call parkhaus_park_vehicle)
    RETURN required_space
END FUNCTION


FUNCTION open_demand(p_parkhaus, p_gate_queue, queue_max_len, demand_remaining)

    open_demand <- demand_remaining

    // Uebrige moegliche Einfahrten in die Queue
    WHILE (open_demand > 0) AND (Queue_Length(p_gate_queue) < queue_max_len) DO
        queue_add_random_vehicle(p_gate_queue)
        open_demand <- open_demand - 1
    END WHILE

    // Uebrige moegliche Einfahrten, welche nicht in Queue passen -> rejected
    IF open_demand > 0 THEN
        p_parkhaus.missed_car_entries <- p_parkhaus.missed_car_entries + open_demand
    END IF

    return 0
END FUNCTION


FUNCTION car_leaving(p_parkhaus, p_car_list_head, p_car)

    IF p_parkhaus = NULL THEN
        return -1
    END IF

    IF p_car = NULL THEN
        return -1
    END IF

    required_space <- GetVehicleRequiredSpace(p_car)

    update_parkhaus_on_exit(p_parkhaus, required_space)
    vehicle_list_remove(&p_parkhaus.parked_head, &p_parkhaus.parked_tail, p_car)

    // free vehicle node when removing it from list.
    // We will have to look at timings with the statistics objects,
    // do we want to tick the statistics before Parkhaus and Queue?
    // If not, freeing here is INVALID as we haven't collected the stats
    // yet.
    FREE(p_car)

    return 0
END FUNCTION


//////////////////////////////////////////////////////////
// Small helpers for Parkhaus capacity & stats
//////////////////////////////////////////////////////////

FUNCTION get_open_space(p_parkhaus)
    RETURN p_parkhaus.size - p_parkhaus.fill_size
END FUNCTION


FUNCTION update_parkhaus_on_exit(p_parkhaus, required_space)
    p_parkhaus.fill_size <- p_parkhaus.fill_size - required_space
    p_parkhaus.totalExit <- p_parkhaus.totalExit + 1
    return
END FUNCTION


FUNCTION update_parkhaus_on_entry(p_parkhaus, required_space)
    p_parkhaus.fill_size <- p_parkhaus.fill_size + required_space
    p_parkhaus.totalEntry <- p_parkhaus.totalEntry + 1
    return
END FUNCTION


//////////////////////////////////////////////////////////
// Parkhaus free
//////////////////////////////////////////////////////////

FUNCTION parkhaus_free(p_parkhaus)
    IF p_parkhaus = NULL THEN
        return
    END IF

    // free all parked vehicles. Same as before,
    // freeing is only valid if we collect statistics
    // before this. Otherwise data is lost!
    vehicle_list_remove_all(&p_parkhaus.parked_head, &p_parkhaus.parked_tail)


    // free all associated gate queues (Parkhaus is owner)
    IF p_parkhaus.gate_queues != NULL THEN
        i <- 0
        WHILE i < p_parkhaus.num_gates DO
            p_gate_queue <- p_parkhaus.gate_queues[i]
            IF p_gate_queue != NULL THEN
                queue_free(p_gate_queue)
                FREE(p_gate_queue)
                p_parkhaus.gate_queues[i] <- NULL
            END IF
            i <- i + 1
        END WHILE

        FREE(p_parkhaus.gate_queues)
        p_parkhaus.gate_queues <- NULL
    END IF

    return
END FUNCTION
