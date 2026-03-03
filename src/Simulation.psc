//////////////////////////////////////////////////////////
// Modul: Simulation
// Abhaengigkeiten: parkhaus, queue, stats, rng, demand, gate_routing, savehandler
//////////////////////////////////////////////////////////

//@brief: simulation initialisation and configuration
FUNCTION simulation_init(p_sim, p_settings, p_stats)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF p_settings = NULL THEN
        return ERROR
    END IF

    p_sim.settings      <- p_settings
    p_sim.current_tick  <- 0
    p_sim.real_equivalent <- p_settings.real_equivalent
    p_sim.max_ticks     <- p_settings.max_ticks
    p_sim.rand_seed     <- p_settings.rand_seed

    p_sim.stats         <- p_stats
    p_sim.rng <- RNG_Create(p_sim.rand_seed)
    IF p_sim.rng = NULL THEN
        return ERROR
    END IF

    p_gate_queues <- ALLOCATE_ARRAY(Queue*, p_settings.gates)
    IF p_gate_queues = NULL THEN
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return ERROR
    END IF

    i <- 0
    WHILE i < p_settings.gates DO
        p_queue <- ALLOCATE(Queue)
        // If allocation fails, we must free previously created queues!
        IF p_queue = NULL THEN
            j <- 0
            WHILE j < i DO
                queue_free(p_gate_queues[j])
                FREE(p_gate_queues[j])
                j <- j + 1
            END WHILE
            FREE(p_gate_queues)
            RNG_Destroy(p_sim.rng)
            p_sim.rng <- NULL
            return ERROR
        END IF

        // Initialize the individual queue
        result <- queue_init(p_queue, p_settings.queue_max_len)
        IF result != 0 THEN
            FREE(p_queue)
            return ERROR
        END IF

        p_gate_queues[i] <- p_queue
        i <- i + 1
    END WHILE

    p_sim.parkhaus <- ALLOCATE(Parkhaus)
    IF p_sim.parkhaus = NULL THEN
        // Cleanup all queues if Parkhaus allocation fails
        i <- 0
        WHILE i < p_settings.gates DO
            queue_free(p_gate_queues[i])
            FREE(p_gate_queues[i])
            i <- i + 1
        END WHILE
        FREE(p_gate_queues)
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return ERROR
    END IF

    result <- parkhaus_init(p_sim.parkhaus, p_settings, p_gate_queues)
    IF result != 0 THEN
        i <- 0
        // Parkhaus will not have been initialized here, FREE(p_sim.parkhaus)
        // is invalid and can't be used.
        WHILE i < p_settings.gates DO
            queue_free(p_gate_queues[i])
            FREE(p_gate_queues[i])
            i <- i + 1
        END WHILE
        FREE(p_gate_queues)
        FREE(p_sim.parkhaus)
        p_sim.parkhaus <- NULL
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return ERROR
    END IF

    return 0
END FUNCTION


FUNCTION simulation_start(p_sim)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    p_sim.current_tick <- 0
    OUTPUT "Simulation Started"
    return OK
END FUNCTION


FUNCTION simulation_tick(p_sim)

    status <- 0          // 0 = OK, non-zero = error or stop

    IF p_sim = NULL THEN
        return ERROR
    END IF
    IF (p_sim.current_tick + 1) > p_sim.max_ticks THEN
        status <- Simulation_End(p_sim)
        return status
    END IF
    p_sim.current_tick <- p_sim.current_tick + 1
    current_tick       <- p_sim.current_tick
    total_demand <- Demand_GenerateTotalPerTick(
                        p_sim.settings,
                        current_tick,
                        p_sim.rng
                    )
    status <- GateRouting_DistributeTotalDemand(
                  total_demand,
                  p_sim.parkhaus.queue,
                  p_sim.settings,
                  p_sim.rng,
                  current_tick
              )
    IF status != 0 THEN
        return status
    END IF

    /**
    * Order of execution for the ticks is important and needs to be preserved.
    * Contrary to earlier implementations, Queue needs to tick first to prevent cars that
    * are waiting in the queue and have reached their max tick get pulled into a slot. Parkhaus
    * then pulls the cars from the queue and doesn't need to tick them again.
    * /
    tick(p_sim.parkhaus.queue.base, current_tick)
    tick(p_sim.parkhaus.base, current_tick)


    status <- Stats_RecordTick(p_sim.stats, current_tick)
    IF status != 0 THEN
        return status
    END IF
    status <- savehandler_save_tick(p_sim, current_tick, "stats.csv")
    IF status != 0 THEN
        return status
    END IF
    IF p_sim.current_tick = p_sim.max_ticks THEN
        status <- Simulation_End(p_sim)
    END IF

    return status
END FUNCTION


FUNCTION Simulation_End(p_sim)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    // save final summary statistics of the run at the end.
    savehandler_save_summary(p_sim, "stats.csv")

    // free Parkhaus and its children!
    IF p_sim.parkhaus != NULL THEN
        parkhaus_free(p_sim.parkhaus)
        FREE(p_sim.parkhaus)
        p_sim.parkhaus <- NULL
    END IF
    IF p_sim.rng != NULL THEN
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
    END IF

    FREE(Settings) // free settings object
    OUTPUT "Simulation ended"

    return OK
END FUNCTION


FUNCTION free_simulation(p_sim)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    // end simulation and free all children
    Simulation_End(p_sim)
    // free the Simulation object itself if dynamically allocated
    FREE(p_sim)

    return OK
END FUNCTION
