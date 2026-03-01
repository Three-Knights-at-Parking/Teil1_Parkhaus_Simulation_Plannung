FUNCTION car_create(created_at, parking_time, spaces_needed)
    // allocate memory for a new Car object
    p_car <- ALLOCATE(Car)

    IF p_car = NULL THEN
        return NULL
    END IF

    // initialize GenericVehicle base inside Car
    // type is CAR, tick function is car_tick
    generic_vehicle_init(p_car.base,
                         CAR,
                         car_tick,
                         created_at,
                         parking_time)

    // initialize car-specific fields
    p_car.spaces_needed <- spaces_needed

    return p_car
END FUNCTION

FUNCTION car_destroy(p_car)
    IF p_car = NULL THEN
        return
    END IF

    // free the memory of this Car object
    FREE(p_car)

    return
END FUNCTION

FUNCTION car_tick(p_self, current_tick)
    /**
    * cast SimulationObject* to GenericVehicle* and then to Car* to access
    * car-specific fields
    */
    p_vehicle <- (GenericVehicle) p_self
    p_car     <- (Car) p_vehicle

    // check if the car has reached or passed its planned leaving tick
    leave_tick <- p_vehicle.created_at + p_vehicle.parking_time

    return
END FUNCTION

