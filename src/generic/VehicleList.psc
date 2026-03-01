FUNCTION vehicle_list_append(pp_head, pp_tail, p_vehicle)

    IF p_vehicle = NULL THEN
        return
    END IF

    // ensure this vehicle is not already linked
    p_vehicle.p_next <- NULL

    // 1: list is currently empty
    IF *pp_head = NULL THEN
        *pp_head <- p_vehicle
        *pp_tail <- p_vehicle
        return
    END IF

    // 2: list is non-empty, append at tail
    (*pp_tail).p_next <- p_vehicle
    *pp_tail <- p_vehicle

    return
END FUNCTION

FUNCTION vehicle_list_pop_front(pp_head, pp_tail)
    IF *pp_head = NULL THEN
        return NULL // nothing to pop
    END IF
    p_first <- *pp_head
    *pp_head <- p_first.p_next

    // if list becomes empty, also reset tail
    IF *pp_head = NULL THEN
        *pp_tail <- NULL
    END IF
    p_first.p_next <- NULL

    return p_first
END FUNCTION

FUNCTION vehicle_list_remove(pp_head, pp_tail, p_target)

    IF p_target = NULL THEN
        return -1
    END IF

    IF *pp_head = NULL THEN
        return -1
    END IF

    // if target is at head
    IF *pp_head = p_target THEN
        // reuse pop_front logic
        p_removed <- vehicle_list_pop_front(pp_head, pp_tail)
        return 0
    END IF

    // otherwise search for node before target
    p_prev <- *pp_head
    p_curr <- p_prev.p_next

    WHILE p_curr != NULL DO
        IF p_curr = p_target THEN
            p_prev.p_next <- p_curr.p_next

            // if we removed the tail, update tail pointer
            IF *pp_tail = p_curr THEN
                *pp_tail <- p_prev
            END IF
            p_curr.p_next <- NULL
            return 0
        END IF
        p_prev <- p_curr
        p_curr <- p_curr.p_next
    END WHILE

    // target not found
    return -1
END FUNCTION

FUNCTION vehicle_list_remove_all(pp_head, pp_tail)

    p_curr <- *pp_head

    WHILE p_curr != NULL DO
        p_next <- p_curr.p_next
        p_curr.p_next <- NULL

        // We take ownership of the node here, see VehicleList.h
        FREE(p_curr)

        p_curr <- p_next
    END WHILE
    *pp_head <- NULL
    *pp_tail <- NULL

    return
END FUNCTION


FUNCTION vehicle_list_count(p_head)
    count <- 0

    p_curr <- p_head

    WHILE p_curr != NULL DO
        count <- count + 1
        p_curr <- p_curr.p_next
    END WHILE

    return count
END FUNCTION

