/////////////////////////////
//////Primary Function//////
///////////////////////////
FUNCTION parkhouse_tick(current_tick, settings, parkhouse, gate_queues, stats)
    IF (settings.number_of_gates = 1) THEN
        parkhouse_tick_empty_general(current_tick, parkhouse, settings, car_list)
        parkhouse_tick_fill_general(current_tick, parkhouse, settings, car_list, gate_queues)
        RETURN OK
    ELSE
        IF ((settings.number_of_gates > 1) AND (!settings.gate_time_exit_enabled)) THEN
            parkhouse_tick_empty_general(current_tick, parkhouse, settings, car_list)
            parkhouse_fill_subtick(current_tick, parkhouse, settings, gate_queues)
            RETURN OK
        ELSE
            // Das Szenario mit gate_time beim Exit wird voruebergehend vernachlaessigt
            //IF ((settings.number_of_gates > 1) AND settings.gate_time_exit_enabled) THEN
            //
            //    parkhouse_tick_empty_subtick(current_tick, settings, parkhouse, stats)
            //    parkhouse_fill_subtick(current_tick, parkhouse, settings, gate_queues)
            //    RETURN OK
            ELSE
                RETURN ERROR
            END IF
        END IF
    END IF
END FUNCTION


FUNCTION parkhouse_tick_empty_general(current_tick, parkhouse, settings, car_list)

    currentNode = car_list.head
    previousNode = NULL

    WHILE (currentNode != NULL) DO
        IF ((currentNode -> car.created_at - current_tick) < (currentNode -> car.leave_after_ticks)) THEN
            currentNode = nextNode
        ELSE
            IF ((currentNode -> car.created_at - current_tick) >= (currentNode -> car.leave_after_ticks)) THEN
                previousNode = currentNode
                currentNode = nextNode
                car_leaving(parkhouse, car_list, previousNode)
            END IF
        END IF
    END WHILE

END FUNCTION


FUNCTION parkhouse_tick_fill_general(current_tick, parkhouse, settings, car_list, gate_queue)


    demand_remaining <- gate_queue.getDemand() // QueueLength(gate_queue) ODER gate_queue.getLength() + gate_queue.newDemand
    max_entries_per_tick <- settings.max_entries_per_tick
    queue_max_len <- settings.queue_max_len

    entries_processed <- 0
    queue_blocked <- FALSE

    // Befuellung des Parkhaus
    WHILE ((get_open_space(parkhouse) > 0) AND (entries_processed < max_entries_per_tick) AND (demand_remaining > 0) AND !queue_blocked) DO

        // Liegt etwas in der Queue? Wenn nein, erstelle neues Vehicle in Queue
        IF (QueueIsEmpty(gate_queue)) THEN
            queue_add_random_vehicle(gate_queue)
            demand_remaining--
        END IF

        IF (!QueueIsEmpty(gate_queue)) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(gate_queue)

            IF (next_vehicle_size <= get_open_space(parkhouse)) THEN
                required_space <- fill_from_queue(queue, get_open_space(parkhouse))
                update_parkhouse_on_entry(parkhouse, required_space)
                entries_processed++

            ELSE    // Anstehendes Fahrzeug zu gross um einzufahren
                queue_blocked <- TRUE
            END IF
        END IF
    END WHILE

    IF (demand_remaining > 0) THEN
        open_Demand(parkhouse, gate_queue, settings.queue_max_len, demand_remaining)
    END IF

    OUTPUT queue
    OUTPUT get_open_space
    OUTPUT entries_processed
    OUTPUT queue_blocked
    OUTPUT rejected_count

END FUNCTION


FUNCTION parkhouse_fill_subtick(current_tick, parkhouse, settings, gate_queues)

    number_of_gates <- parkhouse.number_of_gates
    max_entries_per_tick <- settings.max_entries_per_tick

    FOR (int m = 0; m < max_entries_per_tick; m++)
        IF (m == max_entries_per_tick && i == number_of_gates) THEN
            lastCycle = true;
        ELSE
            lastCycle = false;
        END IF

        FOR (int i = 0; i < number_of_gates; i++)
            parkhouse_fill_subtick_routine(current_tick, parkhouse, settings, gate_queue <- gate_queues.queue[i], lastCycle);

        END FOR
    END FOR
END FUNCTION


FUNCTION parkhouse_fill_subtick_routine(current_tick, parkhouse, settings, gate_queue, lastCycle)

    queue_blocked <- FALSE
    required_space <- 0
    demand_remaining <- gate_queue.getDemand() // QueueLength(gate_queue) ODER gate_queue.getLength() + gate_queue.newDemand

    IF ((get_open_space(parkhouse) > 0) AND (demand_remaining > 0)) THEN

        // Wenn die Queue leer ist, wird ein neues Front Vehicle erstellt
        IF (QueueIsEmpty(queue)) THEN
            queue_add_random_vehicle(queue, current_tick)
            demand_remaining--
        END IF

        // Wenn die Queue infolge nicht leer ist, wird das erste Element der Liste in das Parkhaus uebernommen
        IF !QueueIsEmpty(queue) THEN
            next_vehicle_size <- GetNextQueueVehicleSize(queue)

            // Kontrolle ob Vehicle in Parkhaus passt
            IF (next_vehicle_size <= get_open_space(parkhouse)) THEN
                required_space <- fill_from_queue(queue, get_open_space())
                update_parkhouse_on_entry(parkhouse, required_space)
            END IF
        END IF
    END IF

    IF (demand_remaining > 0 && lastCycle) THEN
        open_Demand(parkhouse, gate_queue, settings.queue_max_len, demand_remaining)
    END IF

    OUTPUT queue
    OUTPUT queue_blocked

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

FUNCTION open_Demand(parkhouse, gate_queue, queue_max_len, demand_remaining)

    open_demand <- demand_remaining
    // Uebrige moegliche Einfahrten in die Queue
    WHILE ((open_demand > 0) AND (QueueLength(gate_queue) < queue_max_len)) DO
        queue_add_random_vehicle(gate_queue)
        open_demand--
    END WHILE

    // Uebrige moegliche Einfahrten, welche nicht in Queue passen -> rejected
    IF (open_demand > 0) THEN
        parkhouse.rejections += open_demand
    END IF

END FUNCTION


FUNCTION queue_add_random_vehicle(gate_queue)
    vehicle <- CreateRandomVehicle()
    status = QueuePushBack(gate_queue, vehicle)
    RETURN status
END FUNCTION


FUNCTION car_leaving(parkhouse, car_list, car)

    IF (parkhouse = NULL) THEN
        RETURN ERROR
    END IF

    IF (car = NULL) THEN
        RETURN ERROR
    END IF

    update_parkhouse_on_exit(parkhouse, car.required_space)
    car_list_remove_object(car_list, car)

    RETURN OK

END FUNCTION


/////////////////////
///help Functions///
///////////////////
FUNCTION get_open_space(parkhouse)

    RETURN parkhouse.size - parkhouse.fill_space

END FUNCTION


FUNCTION update_parkhouse_on_exit(parkhouse, required_space)

    parkhouse.fill_space = parkhouse.fill_space - required_space
    parkhouse.totalExit++

END FUNCTION


FUNCTION update_parkhouse_on_entry(parkhouse, required_space)
    parkhouse.fill_space = parkhouse.fill_space + required_space
    parkhouse.totalEntry++
END FUNCTION



