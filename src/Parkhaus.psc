
/////////////////////////////
//////Primary Function//////
///////////////////////////
FUNCTION Parkhaus_Tick(current_tick, settings, parkhouse, gate_queues, stats)
    IF (settings.number_of_gates = 1) THEN
        Parkhaus_Tick_Empty_General(current_tick, parkhouse, settings, CarList)
        Parkhaus_Tick_Fill_General(current_tick, parkhouse, settings, CarList, gate_queue)
        return OK
    ELSE
        IF ( (settings.number_of_gates > 1)  AND (!settings.gate_time_exit_enabled) )THEN
            Parkhaus_Tick_Empty_General(current_tick, settings, parkhouse, stats)
            Parkhaus_Tick_Fill_SubTick(current_tick, settings, parkhouse, gate_queue, stats)
            return OK
        ELSE
            // Das szenario das auch beim exit eine gate_time besteht wird vorrübergehend vernachlässigt
            //IF ( (settings.number_of_gates > 1) AND settings.gate_time_exit_enabled ) THEN
            //
            //    Parkhaus_Tick_Empty_SubTick(current_tick, settings, parkhouse, stats)
            //    Parkhaus_Tick_Entry_SubTick(current_tick, settings, parkhouse, queue, stats)
            //    return OK
            ELSE
                return ERROR
            END IF
        END IF
    END IF
END FUNCTION



FUNCTION Parkhaus_Tick_Empty_General(current_tick, parkhouse, settings, CarList)

    INPUT  CarList
    INPUT  current_Tick

    currentNode = CarList_head

    while (currentNode != NULL) DO
        IF ( (currentNode -> car.created_at - currentTick) < currentNode -> car.leavingIn_Ticks ) THEN
            currentNode = nextNode
        ELSE
            IF ( (currentNode -> car.created_at - currentTick) >= currentNode -> car.leavingIn_Ticks ) THEN
                currentNode = nextNode
                Car_leaving(currentNode)
            END IF
        END IF
    END WHILE

END FUNCTION

FUNCTION Parkhaus_Tick_Fill_General(current_tick, parkhouse, settings, CarList, queue)

    INPUT queue
    INPUT demand_remaining

    maxEntrys_perTick <- settings.maxEntrys_perTick
    queue_max_len <- settings.queue_max_len

    entries_done ← 0
    queue_blocked ← FALSE

    //Befüllung des Parkhaus
    WHILE ( (parkhouse_open_space(parkhouse) > 0) AND (entries_done < maxEntrys_perTick) AND (demand_remaining > 0) AND !queue_blocked ) DO

        //liegt etwas in der Queue? -> Wenn nein erstelle neues Vehicle in Queue
        IF ( QueueIsEmpty(queue) ) THEN
            QueueAddRandomVehicle(queue)
            demand_remaining--
        END IF

        IF ( !QueueIsEmpty(queue) ) THEN
            next_size ← GetNextQueueVehicleSize(queue)

            IF ( next_size <= parkhouse_open_space(parkhouse) ) THEN
                needed_space ← FillFromQueue(queue, parkhouse_open_space(parkhouse))
                UpdateParkhouseData_Entry(parkhouse, needed_space)
                entries_done++
            END IF
            //Anstehendes Fahrzeug zu groß um einzufahren
            ELSE
                queue_blocked ← TRUE
            END IF
        END IF
    END WHILE

    //Übrige mögliche Einfahrten in die Queue
    WHILE (demand_remaining > 0) AND (QueueLength(queue) < queue_max_len) ) DO
        QueueAddRandomVehicle(queue)
        demand_remaining--
    END WHILE

    //Übrige mögliche Einfahrten welche nicht in Queue passen -> rejected
    IF demand_remaining > 0 THEN
        Parkhouse.rejections += demand_remaining
    END IF


    OUTPUT queue
    OUTPUT parkhouse_open_space
    OUTPUT entries_done
    OUTPUT queue_blocked
    OUTPUT rejected_count

}


FUNCTION Parkhouse_Fill_SubTick(current_Tick, parkhouse, settings, queue_list)

    anzGates <- parkhous.anzGates
    maxEntrys_perTick <- settings.maxEntrys_perTick


    FOR (int m = 0; i < maxEntrys_perTick; m++)

        FOR (int i = 0; i < anzGates; i++)

            Parkhouse_Fill_SubTick_Routine(queue <- queue_list[i], demand_remaining <- queue_list[i].demand_remaining, current_Tick);
        END FOR
    END FOR
END FUNCTION



FUNCTION Parkhouse_Fill_SubTick_Routine(queue, demand_remaining, current_Tick)

    queue_blocked ← FALSE
    needed_space ← 0
    total_demand ← demand_remaining + QueueLength(queue)

    IF parkhouse_open_space() > 0 AND total_demand > 0 THEN

        // Wenn die Queue leer ist wird ein neues Front Vehicle erstellt
        IF QueueIsEmpty(queue) THEN
            IF demand_remaining > 0 THEN
                QueueAddRandomVehicle(queue, current_Tick)
                demand_remaining ← demand_remaining - 1
            END IF
        END IF

        // Wenn die Queue infolge nicht leer ist wird das erste element der Liste in das Parkhaus übernommen
        IF NOT QueueIsEmpty(queue) THEN
            next_size ← GetNextQueueVehicleSize(queue)

            // Kontrolle ob Vehicle in Parkhaus passt
            IF next_size ≤ parkhouse_open_space() THEN
                needed_space ← FillFromQueue(queue, parkhouse_open_space())
                UpdateParkhouseData(needed_space)
                parkhouse_open_space ← parkhouse_open_space() - needed_space
            ELSE
                queue_blocked ← TRUE
            END IF
        END IF

    END IF

    OUTPUT queue
    OUTPUT demand_remaining
    OUTPUT parkhouse_open_space
    OUTPUT queue_blocked
    OUTPUT needed_space

END FUNCTION


FUNCTION FillFromQueue(queue, parkhouse_open_space)
    vehicle ← QueuePopFront(queue)

    base_space ← GetVehicleBaseSpace(vehicle)
    needed_space ← base_space

    // Bad parking only possible if double space is available
    IF parkhouse_open_space ≥ 2 * base_space THEN
        r ← RandomPercent()
        IF r < GetBadParkingProbability(vehicle) THEN
            needed_space ← 2 * base_space
        END IF
    END IF
    return needed_space

END FUNCTION


FUNCTION QueueAddRandomVehicle(queue)
    vehicle ← CreateRandomVehicle()
    QueuePushBack(queue, vehicle)
    return 0
END FUNCTION


/////////////////////
///help Functions///
///////////////////
FUNCTION parkhouse_open_space(parkhouse)

    RETURN parkhouse.size - parkhouse.fill_space

END FUNCTION


FUNCTION UpdateParkhouseData_EXIT(parkhouse, needed_space)

    parkhaus.fill_space = parkhaus.fill_space - spaces
    parkhaus.totalExit++;

END FUNCTION

FUNCTION UpdateParkhouseData_Entry(parkhouse, needed_space)
    parkhaus.fill_space = parkhaus.fill_space + spaces
    parkhaus.totalEntry++;
END FUNCTION
