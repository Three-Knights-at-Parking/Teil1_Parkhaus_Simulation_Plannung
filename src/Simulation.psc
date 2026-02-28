FUNCTION Sim_Tick(simulation)
    INPUT simulation

    status ← OK

    IF ( (current_tick + 1) == max_tick ) THEN

        current_tick ← current_tick + 1
        status ← Simulation_End(simulation, current_tick)

    ELSE
        IF ( (current_tick + 1) < max_tick ) THEN
            current_tick ← current_tick + 1

            status ← Parkhaus_Tick(
                        current_tick,
                        Simulation_GetSettings(simulation),
                        Simulation_GetParkhouse(simulation),
                        Simulation_GetQueuesList(simulation),
                        Simulation_GetStats(simulation)
                     )

        ELSE
            // current_tick ≥ max_tick
            status ← Simulation_End(simulation, current_tick)
            status ← ERROR
        END IF
    END IF

    OUTPUT status

    return status
END FUNCTION