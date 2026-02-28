/////////////////////////////
//////Primary Function//////
///////////////////////////
FUNCTION parkhouse_tick(current_tick, settings, parkhouse, gate_queues, stats)
    IF (settings.number_of_gates = 1) THEN
        parkhouse_tick_empty_general(current_tick, parkhouse, settings, car_list)
        parkhouse_tick_fill_general(current_tick, parkhouse, settings, car_list, gate_queue)
        RETURN OK
    ELSE
        IF ((settings.number_of_gates > 1) AND (!settings.gate_time_exit_enabled)) THEN
            parkhouse_tick_empty_general(current_tick, settings, parkhouse, stats)
            parkhouse_fill_subtick(current_tick, settings, parkhouse, gate_queue, stats)
            RETURN OK
        ELSE
            // Das Szenario mit gate_time beim Exit wird voruebergehend vernachlaessigt
            //IF ((settings.number_of_gates > 1) AND settings.gate_time_exit_enabled) THEN
            //
            //    parkhouse_tick_empty_subtick(current_tick, settings, parkhouse, stats)
            //    parkhouse_tick_entry_subtick(current_tick, settings, parkhouse, queue, stats)
            //    RETURN OK
            ELSE
                RETURN ERROR
            END IF
        END IF
    END IF
END FUNCTION


FUNCTION parkhouse_tick_empty_general(current_tick, parkhouse, settings, car_list)

    INPUT car_list
    INPUT current_tick

    currentNode = car_list_head

    WHILE (currentNode != NULL) DO
        IF ((currentNode -> car.created_at - current_tick) < currentNode -> car.leave_after_ticks) THEN
            currentNode = nextNode
        ELSE
            IF ((currentNode -> car.created_at - current_tick) >= currentNode -> car.leave_after_ticks) THEN
                currentNode = nextNode
                car_leaving(currentNode)
            END IF
        END IF
    END WHILE

END FUNCTION


FUNCTION parkhouse_tick_fill_general(current_tick, parkhouse, settings, car_list, queue)

    INPUT queue
    INPUT demand_remaining

    max_entries_per_tick <- settings.max_entries_per_tick
    queue_max_len <- settings.queue_max_len

    entries_processed <- 0
    queue_blocked <- FALSE

    // Befuellung des Parkhaus
    WHILE ((get_open_space(parkhouse) > 0) AND (entries_processed < max_entries_per_tick) AND (demand_remaining > 0) AND !queue_blocked) DO

        // Liegt etwas in der Queue? Wenn nein, erstelle neues Vehicle in Queue
        IF (QueueIsEmpty(queue)) THEN
            queue_add_random_vehicle(queue)
            demand_remaining--
        END IF

        IF (!QueueIsEmpty(queue)) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(queue)

            IF (next_vehicle_size <= get_open_space(parkhouse)) THEN
                required_space <- fill_from_queue(queue, get_open_space(parkhouse))
                update_parkhouse_on_entry(parkhouse, required_space)
                entries_processed++
            END IF
            // Anstehendes Fahrzeug zu gross um einzufahren
            ELSE
                queue_blocked <- TRUE
            END IF
        END IF
    END WHILE

    // Uebrige moegliche Einfahrten in die Queue
    WHILE ((demand_remaining > 0) AND (QueueLength(queue) < queue_max_len)) DO
        queue_add_random_vehicle(queue)
        demand_remaining--
    END WHILE

    // Uebrige moegliche Einfahrten, welche nicht in Queue passen -> rejected
    IF (demand_remaining > 0) THEN
        parkhouse.rejections += demand_remaining
    END IF

    OUTPUT queue
    OUTPUT get_open_space
    OUTPUT entries_processed
    OUTPUT queue_blocked
    OUTPUT rejected_count

END FUNCTION


FUNCTION parkhouse_fill_subtick(current_tick, parkhouse, settings, queue_list)

    number_of_gates <- parkhouse.number_of_gates
    max_entries_per_tick <- settings.max_entries_per_tick

    FOR (int m = 0; i < max_entries_per_tick; m++)

        FOR (int i = 0; i < number_of_gates; i++)

            parkhouse_fill_subtick_routine(queue <- queue_list[i], demand_remaining <- queue_list[i].demand_remaining, current_tick);
        END FOR
    END FOR
END FUNCTION


FUNCTION parkhouse_fill_subtick_routine(queue, demand_remaining, current_tick)

    queue_blocked <- FALSE
    required_space <- 0
    pending_demand <- demand_remaining + QueueLength(queue)

    IF (get_open_space() > 0 AND pending_demand > 0) THEN

        // Wenn die Queue leer ist, wird ein neues Front Vehicle erstellt
        IF (QueueIsEmpty(queue)) THEN
            IF (demand_remaining > 0) THEN
                queue_add_random_vehicle(queue, current_tick)
                demand_remaining <- demand_remaining - 1
            END IF
        END IF

        // Wenn die Queue infolge nicht leer ist, wird das erste Element der Liste in das Parkhaus uebernommen
        IF NOT QueueIsEmpty(queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(queue)

            // Kontrolle ob Vehicle in Parkhaus passt
            IF (next_vehicle_size <= get_open_space()) THEN
                required_space <- fill_from_queue(queue, get_open_space())
                UpdateParkhouseData(required_space)
                get_open_space <- get_open_space() - required_space
            ELSE
                queue_blocked <- TRUE
            END IF
        END IF

    END IF

    OUTPUT queue
    OUTPUT demand_remaining
    OUTPUT get_open_space
    OUTPUT queue_blocked
    OUTPUT required_space

END FUNCTION


FUNCTION fill_from_queue(queue, parkhouse_open_space)
    vehicle <- QueuePopFront(queue)

    base_space <- GetVehicleBaseSpace(vehicle)
    required_space <- base_space

    // Bad parking only possible if double space is available
    IF (parkhouse_open_space >= 2 * base_space) THEN
        r <- RandomPercent()
        IF (r < GetBadParkingProbability(vehicle)) THEN
            required_space <- 2 * base_space
        END IF
    END IF
    RETURN required_space

END FUNCTION


FUNCTION queue_add_random_vehicle(queue)
    vehicle <- CreateRandomVehicle()
    QueuePushBack(queue, vehicle)
    RETURN 0
END FUNCTION


/////////////////////
///help Functions///
///////////////////
FUNCTION get_open_space(parkhouse)

    RETURN parkhouse.size - parkhouse.fill_space

END FUNCTION


FUNCTION car_leaving(parkhouse, car_list, car)

    IF (parkhouse = NULL) THEN
        RETURN ERROR
    END IF

    IF (car = NULL) THEN
        RETURN ERROR
    END IF

    parkhouse.fill_space = parkhouse.fill_space - 1
    parkhouse.total_left++

    car_list_remove_object(car_list, car)

    RETURN OK

END FUNCTION


FUNCTION update_parkhouse_on_exit(parkhouse, required_space)

    parkhouse.fill_space = parkhouse.fill_space - required_space
    parkhouse.totalExit++

END FUNCTION


FUNCTION update_parkhouse_on_entry(parkhouse, required_space)
    parkhouse.fill_space = parkhouse.fill_space + required_space
    parkhouse.totalEntry++
END FUNCTION
