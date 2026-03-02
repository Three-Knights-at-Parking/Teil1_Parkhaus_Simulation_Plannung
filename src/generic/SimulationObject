FUNCTION tick(p_obj, current_tick)
    IF p_obj = NULL THEN
        return
    END IF

    IF p_obj.tick = NULL THEN
        return
    END IF

    // call the stored tick-function with this object and the current tick. For Car it will be car_tick.
    p_obj.tick(p_obj, current_tick)

    return
END FUNCTION

FUNCTION simulation_object_set_tick(p_obj, tick_function)

    IF p_obj = NULL THEN
        return
    END IF

    p_obj.tick <- tick_function

    return
END FUNCTION

FUNCTION simulation_object_get_tick(p_obj)

    IF p_obj = NULL THEN
        return NULL
    END IF

    // return the stored tick function (may be NULL)
    return p_obj.tick
END FUNCTION

FUNCTION free_simulation_object(p_obj)

    IF p_obj = NULL THEN
        return ERROR
    END IF

    // SimulationObject does not own the tick-function or any parent object.
    // Only free the memory of this SimulationObject itself, if it was
    // dynamically allocated as a plain SimulationObject. See SimulationObject.h.
    FREE(p_obj)

    return OK
END FUNCTION
