FUNCTION rng_init(p_settings)
    seed <- 0

    IF p_settings = NULL THEN
        // Default to current time
        seed <- CURRENT_TIME_IN_SECONDS()
    ELSE
        IF p_settings.rand_seed = -1 OR NULL THEN
            // -1 -> Default to current time
            seed <- CURRENT_TIME_IN_SECONDS()
        ELSE
            seed <- p_settings.rand_seed
        END IF
    END IF
    // initialize global RNG with seed.
    RNG_SEED(seed)

    return 0
END FUNCTION


//////////////////////////////////////////////////////////
// General functions
//////////////////////////////////////////////////////////

FUNCTION rng_next_u32()
    // Random 32-bit integer for range (inclusive) [0, UINT32_MAX]
    value <- RNG_RAW_U32()
    return value
END FUNCTION


FUNCTION rng_range_int(min, max)
    // make sure min <= max
    IF min > max THEN
        temp <- min
        min  <- max
        max  <- temp
    END IF

    range <- max - min + 1

    raw   <- rng_next_u32()
    offset <- raw MOD range

    return min + offset
END FUNCTION


FUNCTION rng_percent()
    value <- rng_range_int(0, 100)
    return value
END FUNCTION


//////////////////////////////////////////////////////////
// Specialized helpers
//////////////////////////////////////////////////////////

FUNCTION rng_parking_time(min_ticks, max_ticks)
    // treat as uniform distribution for now!
    time <- rng_range_int(min_ticks, max_ticks)
    return time
END FUNCTION


FUNCTION rng_gate_index(num_gates)
    IF num_gates = 0 THEN
        return 0
    END IF

    // Gate-Index in [0, num_gates - 1]
    index <- rng_range_int(0, num_gates - 1)
    return index
END FUNCTION
