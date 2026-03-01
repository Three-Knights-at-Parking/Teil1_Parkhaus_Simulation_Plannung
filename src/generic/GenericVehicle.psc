FUNCTION generic_vehicle_init(p_vehicle, type, tick_function, created_at, parking_time)
    // safety check: pointer must not be NULL
    IF p_vehicle = NULL THEN
        return
    END IF

    // initialize SimulationObject part (base)
    p_vehicle.base.id   <- 0           // or some id generator later
    p_vehicle.base.type <- type
    p_vehicle.base.tick <- tick_function

    // initialize linked-list pointer
    p_vehicle.p_next <- NULL

    // initialize common vehicle fields
    p_vehicle.created_at        <- created_at
    p_vehicle.park_house_entered <- 0
    p_vehicle.parking_time      <- parking_time
    p_vehicle.current_slot      <- 0
    p_vehicle.current_floor     <- 0

    return
END FUNCTION
