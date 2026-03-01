//////////////////////////////////////////////////////////
//// Modul: simulation
//// Abhaengigkeiten: parkhaus, stats, rng, demand, gate_routing
//////////////////////////////////////////////////////////

FUNCTION simulation_init(simulation, settings_provider, stats)

    sim <- Simulation_CreateObject()

    //Simulation Setup
    sim.settings <- SettingsProvider_Load(settings_provider)
    sim.stats <- stats
    sim.current_tick <- 0
    sim.rng <- RNG_Create(sim.settings.seed)

    // simulation -> parkhaus
    sim.parkhouse <- Parkhaus_Create(sim.settings)
    sim.gate_queues <- Parkhaus_CreateGateQueues(sim.settings.number_of_gates)

    RETURN sim
END FUNCTION


FUNCTION simulation_tick(simulation)

    status <- OK //Status Global als Start/Stop ?

    IF ((simulation.current_tick + 1) > simulation.settings.max_tick) THEN
        status <- Simulation_End(simulation, simulation.current_tick)

        RETURN status
    END IF

    simulation.current_tick <- simulation.current_tick + 1

    //Berrechngun gesamter Demand fuer diesen Tick (demand.h)
    total_demand <- Demand_GenerateTotalPerTick(
                       simulation.settings,
                       simulation.current_tick,
                       simulation.rng
                    )

    //Verteilung des globalen Demands auf Gates (gate_routing.h)
    status <- GateRouting_DistributeTotalDemand(
            total_demand,
            simulation.gate_queues,
            simulation.settings,
            simulation.rng,
            simulation.current_tick
    )
    IF (status == Error) THEN
        RETURN status
    END IF

    status <- Parkhaus_Tick(
                simulation.current_tick,
                simulation.settings,
                simulation.parkhouse,
                simulation.gate_queues,
                simulation.stats
             )
    IF (status == Error) THEN
        RETURN status
    END IF

    status <- Stats_RecordTick(simulation.stats, simulation.current_tick)
    IF (status == Error) THEN
        RETURN status
    END IF

    IF (simulation.current_tick == simulation.settings.max_tick) THEN
        status <- Simulation_End(simulation, simulation.current_tick)
    END IF

    RETURN status
END FUNCTION
