INCLUDE FILE ui.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h
INCLUDE FILE storage.h
INCLUDE FILE ui_statistics.h

/*
 * @file simulation.psc
 * @brief Simulation menu implementation.
 *
 * Responsibilities:
 * - Print simulation menu and read validated user input
 * - Start the simulation through start_simulation(p_settings)
 * - Receive statistics pointers via hand_over_* callbacks
 * - Print tick statistics by iterating the linked list (StatList.p_tick_head)
 * - Print final summary statistics (StatsSummary)
 *
 * Design note:
 * - The UI does NOT compute simulation results. It only reads and displays
 *   the data produced by the simulation/data layer.
 */


/* ========================================================================= */
/* Global handover storage (pointers owned by simulation/data layer)          */
/* ========================================================================= */

GLOBAL StatList* g_pStatList ← NULL
GLOBAL StatsSummary* g_pStatsSummary ← NULL


/* ========================================================================= */
/* Screen printing                                                           */
/* ========================================================================= */

FUNCTION print_simulationscreen(p_settings)

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "          SIMULATION MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "Current Configuration"
    OUTPUT "------------------------------------"
    OUTPUT "Spots per Floor      : ", p_settings.capacity
    OUTPUT "Floors               : ", p_settings.floors
    OUTPUT "Gates                : ", p_settings.gates
    OUTPUT "Tick Length (sec)    : ", p_settings.real_equivalent
    OUTPUT "Max Ticks            : ", p_settings.max_ticks
    OUTPUT "Random Seed          : ", p_settings.rand_seed
    OUTPUT "------------------------------------"
    OUTPUT ""
    OUTPUT "1 Start Simulation"
    OUTPUT "2 Go to Configuration"
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION


/* ========================================================================= */
/* Post simulation prompt                                                    */
/* ========================================================================= */

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
        validation_flag ← CALL validate_user_input(choice, SIM_POST_MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN
        CALL browse_directory(sim_output_path)
    END IF

    return

END FUNCTION


/* ========================================================================= */
/* Menu logic                                                                */
/* ========================================================================= */

FUNCTION simulation_menu(p_settings)

    CALL print_simulationscreen(p_settings)

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, SIMULATION_MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN

        // Ensure settings were initialized in configuration menu at least once.
        IF g_settings_state = SETTINGS_NOT_INITIALIZED THEN
            OUTPUT "Settings not initialized!"
            OUTPUT "Please open the Configuration Menu first."
            INPUT dummy
            return UI_KONFIG
        END IF

        OUTPUT "Starting simulation..."

        // Reset handover pointers before starting a new run.
        g_pStatList ← NULL
        g_pStatsSummary ← NULL

        // Start simulation (data layer). It must call the hand_over_* callbacks.
        sim_output_path ← CALL start_simulation(p_settings)

        // Safety check: if backend didn't hand over a stats list, printing is impossible.
        IF g_pStatList = NULL THEN
            OUTPUT "Error: No simulation data received from backend."
            INPUT dummy
            return UI_SIMULATION
        END IF

        CALL ui_statistics_print_header(p_settings)

        // Iterate tick list and print per-tick statistics.
        current_tick ← g_pStatList.p_tick_head
        WHILE current_tick ≠ NULL DO
            CALL ui_statistics_print_tick(current_tick, p_settings)
            current_tick ← current_tick.p_next
        END WHILE

        // Print final summary if available.
        IF g_pStatsSummary ≠ NULL THEN
            CALL ui_statistics_print_final(g_pStatsSummary, p_settings)
        ELSE
            OUTPUT "Warning: No summary received."
        END IF

        OUTPUT "Simulation finished."

        // Only show storage prompt if a valid path was returned.
        IF sim_output_path ≠ NULL THEN
            CALL post_simulation_prompt(sim_output_path)
        END IF

        return UI_SIMULATION

    ELSE IF choice = 2 THEN
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

    // Defensive fallback
    return UI_SIMULATION

END FUNCTION


/* ========================================================================= */
/* Handover callbacks (called by simulation/data layer)                       */
/* ========================================================================= */

FUNCTION hand_over_simulationdata(pStatList)
    g_pStatList ← pStatList
END FUNCTION


FUNCTION hand_over_endstatistics(pStatsSummary)
    g_pStatsSummary ← pStatsSummary
END FUNCTION