//////////////////////////////////////////////////////////
// Modul: simulation
// Abhaengigkeiten: parkhaus, queue, stats, rng, demand, gate_routing, savehandler
//////////////////////////////////////////////////////////

//@brief: simulation initialisation and configuration
FUNCTION simulation_init(p_sim, p_settings, p_stats)
    IF p_sim = NULL THEN
        return -1
    END IF

    IF p_settings = NULL THEN
        return -1
    END IF

    p_sim.settings      <- p_settings
    p_sim.current_tick  <- 0
    p_sim.real_equivalent <- p_settings.real_equivalent
    p_sim.max_ticks     <- p_settings.max_ticks
    p_sim.rand_seed     <- p_settings.rand_seed

    p_sim.stats         <- p_stats
    p_sim.rng <- RNG_Create(p_sim.rand_seed)
    IF p_sim.rng = NULL THEN
        return -1
    END IF

    // create and initialize Queue for this parkhaus
    p_queue <- ALLOCATE(Queue)
    IF p_queue = NULL THEN
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return -1
    END IF

    // maximum size of queue may depend on settings (e.g. size or gates)
    result <- queue_init(p_queue, p_settings.size)
    IF result != 0 THEN
        FREE(p_queue)
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return -1
    END IF

    p_sim.parkhaus <- ALLOCATE(Parkhaus)
    IF p_sim.parkhaus = NULL THEN
        queue_free(p_queue)
        FREE(p_queue)
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return -1
    END IF

    result <- parkhaus_init(p_sim.parkhaus, p_settings, p_queue)
    IF result != 0 THEN // Something went wrong!
        queue_free(p_queue)
        FREE(p_queue)
        FREE(p_sim.parkhaus)
        p_sim.parkhaus <- NULL
        RNG_Destroy(p_sim.rng)
        p_sim.rng <- NULL
        return -1
    END IF

    return 0
END FUNCTION


FUNCTION simulation_start(p_sim)
    IF p_sim = NULL THEN
        return -1
    END IF

    p_sim.current_tick <- 0
    OUTPUT "Simulation Started"
    return 0
END FUNCTION


FUNCTION simulation_tick(p_sim)

    status <- 0          // 0 = OK, non-zero = error or stop

    IF p_sim = NULL THEN
        return -1
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
    * Order of ticks is important and needs to be preserved! First tick
    * tick the parkhaus and then tick the queue!
    * /
    tick(p_sim.parkhaus.base, current_tick)
    tick(p_sim.parkhaus.queue.base, current_tick)

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
        return -1
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

    return 0
END FUNCTION


FUNCTION free_simulation(p_sim)
    IF p_sim = NULL THEN
        return -1
    END IF

    // end simulation and free all children
    Simulation_End(p_sim)
    // free the Simulation object itself if dynamically allocated
    FREE(p_sim)

    return 0
END FUNCTION
