FUNCTION Parkhaus_Tick(current_tick, settings, parkhouse, queue, stats)
    IF settings.number_of_gates = 1 THEN
        Parkhaus_Tick_Empty_General(current_tick, settings, parkhouse, stats)
        Parkhaus_Tick_Fill_General(current_tick, settings, parkhouse, queue, stats)
        return OK
    ELSE
        IF settings.number_of_gates > 1 AND settings.gate_time_exit_enabled = FALSE THEN
            Parkhaus_Tick_Empty_General(current_tick, settings, parkhouse, stats)
            Parkhaus_Tick_Entry_SubTick(current_tick, settings, parkhouse, queue, stats)
            return OK
        ELSE
            //IF settings.number_of_gates > 1 AND settings.gate_time_exit_enabled = TRUE THEN
            //    // Exit-subticks are intentionally ignored for now (entry-only subticks)
            //    Parkhaus_Tick_Empty_General(current_tick, settings, parkhouse, stats)
            //    Parkhaus_Tick_Entry_SubTick(current_tick, settings, parkhouse, queue, stats)
            //    return OK
            ELSE
                return ERROR
            END IF
        END IF
    END IF
END FUNCTION


FUNCTION Parkhouse_fill_subtick(queue_list, currentTick, anzGates, maxEntrys_perTick)
{
    for (int m = 0; i < maxEntrys_perTick; m++)
    {
        for (int i = 0; i < Gates; i++)
        {
            Parkhouse_fill_subtick_sub(queue <- queue_list[i], demand_remaining <- queue_list[i].demand_remaining, currentTick);
        }
    }
}



FUNCTION Parkhouse_fill_subtick_routine(queue, demand_remaining, currentTick)

    queue_blocked ← FALSE
    needed_space ← 0
    total_demand ← demand_remaining + QueueLength(queue)

    IF parkhouse_open_space() > 0 AND total_demand > 0 THEN

        // Wenn die Queue leer ist wird ein neues Front Vehicle erstellt
        IF QueueIsEmpty(queue) THEN
            IF demand_remaining > 0 THEN
                QueueAddRandomVehicle(queue, currentTick)
                demand_remaining ← demand_remaining - 1
            END IF
        END IF

        // Wenn die Queue infolge nicht leer ist wird das erste element der Liste in das Parkhaus übernommen
        IF NOT QueueIsEmpty(queue) THEN
            next_size ← GetNextQueueVehicleSize(queue)

            // Kontrolle ob Vehicle in Parkhaus passt
            IF next_size ≤ parkhouse_open_space THEN
                needed_space ← FillFromQueue(queue, parkhouse_open_space)
                UpdateParkhouseData(needed_space)
                parkhouse_open_space ← parkhouse_open_space - needed_space
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



//help Functions

FUNCTION parkhouse_open_space()

    RETURN parkhouse.fill_space - parkhouse.size

END FUNCTION


FUNCTION parkhouse_spaces_blocked(spaces)

    parkhaus.fill_space = parkhaus.fill_space + spaces

END FUNCTION


FUNCTION parkhouse_spaces_freed(spaces)

    parkhaus.fill_space = parkhaus.fill_space - spaces

END FUNCTION