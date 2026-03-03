
FUNCTION queue_init(p_queue, max_size)
    IF p_queue = NULL THEN
        return ERROR
    END IF

    IF max_size = 0 THEN
        // 0 => effectively disabled. Not sure if we should treat this as an error?
        p_queue.max_size    <- 0
        p_queue.size        <- 0
        p_queue.waiting_cars <- NULL
        p_queue.demand      <- 0
        p_queue.base.tick   <- queue_tick
        return 0
    END IF

    p_queue.max_size    <- max_size
    p_queue.capacity <- 0
    p_queue.p_head   <- NULL
    p_queue.p_tail   <- NULL
    p_queue.demand      <- 0

    p_queue.base.id     <- 0           // or some id generator
    p_queue.base.type   <- QUEUE      // enum value in ObjectType later
    p_queue.base.tick   <- queue_tick

    return 0
END FUNCTION

FUNCTION queue_free(p_queue)
    IF p_queue = NULL THEN
        return
    END IF

    // The queue owns its waiting cars. We must free them first.
    vehicle_list_remove_all(&p_queue.waiting_head, &p_queue.waiting_tail)

    p_queue.size <- 0
    p_queue.waiting_head <- NULL
    p_queue.waiting_tail <- NULL
    p_queue.demand <- 0
    return
END FUNCTION


FUNCTION queue_is_full(p_queue)
    IF p_queue = NULL THEN
        return UNKNOWN
    END IF

    IF p_queue.size >= p_queue.max_size THEN
        return ERROR
    ELSE
        return OK
    END IF
END FUNCTION


FUNCTION queue_is_empty(p_queue)
    IF p_queue = NULL THEN
        return UNKNOWN
    END IF

    IF p_queue.size = 0 THEN
        return UNKNOWN
    ELSE
        return OK
    END IF
END FUNCTION


FUNCTION queue_length(p_queue)
    IF p_queue = NULL THEN
        return OK
    END IF

    return p_queue.size
END FUNCTION

FUNCTION queue_enqueue(p_queue, p_vehicle)
    IF p_queue = NULL THEN
        return ERROR
    END IF

    IF p_vehicle = NULL THEN
        return ERROR
    END IF

    IF queue_is_full(p_queue) = ERROR THEN
        return ERROR
    END IF

    // append vehicle to internal list of waiting_cars
    vehicle_list_append(&p_queue.p_head, &p_queue.p_tail, p_vehicle)
    p_queue.capacity <- p_queue.capacity + 1

    return OK
END FUNCTION


FUNCTION queue_dequeue(p_queue)
    IF p_queue = NULL THEN
        return NULL
    END IF

    IF queue_is_empty(p_queue) = 1 THEN
        return NULL
    END IF

    // take first vehicle from internal list and transfer ownership
    p_vehicle <- vehicle_list_pop_front(&p_queue.waiting_head, &p_queue.waiting_tail)
    p_queue.size <- p_queue.size - 1

    // ownership of p_vehicle goes to caller (Parkhaus).
    return p_vehicle
END FUNCTION


FUNCTION queue_remove(p_queue, p_target)
    IF p_queue = NULL THEN
        return ERROR
    END IF

    IF p_target = NULL THEN
        return ERROR
    END IF

    // try to remove p_target from waiting_cars list
    removed <- vehicle_list_remove(&p_queue.waiting_head, &p_queue.waiting_tail, p_target)

    IF removed = ERROR THEN
        return ERROR
    END IF

    p_queue.size <- p_queue.size - 1

    // queue owns vehicles and needs to free them from
    // memory. This again is only valid if statistics
    // have been collected before this. Otherwise we
    // need to do this BEFORE calling FREE.
    FREE(p_target)

    return OK
END FUNCTION

FUNCTION queue_set_demand(p_queue, demand_value)
    IF p_queue = NULL THEN
        return
    END IF

    p_queue.demand <- demand_value
END FUNCTION


FUNCTION queue_get_demand(p_queue)
    IF p_queue = NULL THEN
        return OK
    END IF

    return p_queue.demand
END FUNCTION

FUNCTION queue_tick(p_self, current_tick)
    p_queue <- (Queue) p_self

    currentNode <- p_queue.waiting_cars
    WHILE currentNode != NULL DO
        nextNode <- currentNode.p_next

        // TODO
        // if current_tick - currentNode.created_at > currentNode.parking_time
        // THEN remove from queue and free
        // Currently no-op as we will leave out QueueLeavable for Part1.

        currentNode <- nextNode
    END WHILE

    return
END FUNCTION
