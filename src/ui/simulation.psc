INCLUDE FILE ui.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h
INCLUDE FILE storage.h


GLOBAL StatList* g_pStatList ← NULL
GLOBAL StatsSummary* g_pStatsSummary ← NULL


FUNCTION print_simulationscreen(settings)

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "          SIMULATION MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "Current Configuration"
    OUTPUT "------------------------------------"
    OUTPUT "Spots per Floor      : ", settings.size
    OUTPUT "Floors               : ", settings.floors
    OUTPUT "Gates                : ", settings.gates
    OUTPUT "Tick Length (sec)    : ", settings.real_equivalent
    OUTPUT "Max Ticks            : ", settings.max_ticks
    OUTPUT "Random Seed          : ", settings.rand_seed
    OUTPUT "------------------------------------"
    OUTPUT ""
    OUTPUT "1 Start Simulation"
    OUTPUT "2 Go to Configuration"
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION


FUNCTION post_simulation_prompt(sim_output_path)

    OUTPUT ""
    OUTPUT "Simulation data saved to:"
    OUTPUT sim_output_path
    OUTPUT ""
    OUTPUT "1 Jump to Storage Folder"
    OUTPUT "0 Back to Simulation Menu"
    OUTPUT ""

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, 1)
    END WHILE

    IF choice = 1 THEN
        CALL browse_directory(sim_output_path)
    END IF

    return

END FUNCTION


FUNCTION simulation_menu(settings)

    CALL print_simulationscreen(settings)

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, SIMULATION_MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN

        IF settings_state_flag = NOT_INITIALIZED THEN
            OUTPUT "Settings not initialized!"
            OUTPUT "Please open the Configuration Menu first."
            INPUT dummy
            return UI_KONFIG
        END IF

        OUTPUT "Starting simulation..."

        CALL start_simulation(settings)

        /* Sicherheitscheck */
        IF g_pStatList = NULL THEN
            OUTPUT "Error: No simulation data received from backend."
            return UI_SIMULATION
        END IF

        CALL ui_statistics_print_header(settings)

        current_tick ← g_pStatList.p_tick_head

        WHILE current_tick ≠ NULL DO
            CALL ui_statistics_print_tick(current_tick, settings)
            current_tick ← current_tick.p_next
        END WHILE

        IF g_pStatsSummary ≠ NULL THEN
            CALL ui_statistics_print_final(g_pStatsSummary, settings)
        END IF

        OUTPUT "Simulation finished."

        CALL post_simulation_prompt(sim_output_path)

        return UI_SIMULATION

    ELSE IF choice = 2 THEN
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION


FUNCTION hand_over_simulationdata(pStatList)
    g_pStatList ← pStatList
END FUNCTION


FUNCTION hand_over_simulationdata(pStatList)
    g_pStatList ← pStatList
END FUNCTION