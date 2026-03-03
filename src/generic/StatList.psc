//////////////////////////////////////////////////////////
// Modul: stat_list
// Abhaengigkeiten: types (Simulation, StatsTick)
//////////////////////////////////////////////////////////

FUNCTION statlist_append(p_sim, p_tick)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.p_next <- NULL
    IF p_sim.StatList.head = NULL THEN
        p_sim.StatList.head <- p_tick
        p_sim.StatList.tail <- p_tick
        return UNKNOWN
    END IF

    p_sim.StatList.tail.p_next <- p_tick
    p_sim.StatList.tail <- p_tick
    return OK
END FUNCTION

FUNCTION statlist_clear(p_sim)
    IF p_sim = NULL THEN
        return
    END IF

    current <- p_sim.StatList.head

    WHILE current != NULL DO
        next <- current.p_next
        // We have ownership here and need to free the dynamically
        // allocated StatTick. See SaveHandler.h for reference.
        FREE(current)

        current <- next
    END WHILE

    p_sim.StatList.head <- NULL
    p_sim.StatList.tail <- NULL

    return
END FUNCTION

FUNCTION statlist_compute_summary(p_sim, p_summary)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF p_summary = NULL THEN
        return ERROR
    END IF

    current <- p_sim.StatList.head
    IF current = NULL THEN
        return ERROR
    END IF
    stats_build_summary(p_sim, p_summary)
    return 0
END FUNCTION