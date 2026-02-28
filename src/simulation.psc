INCLUDE FILE ui.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h

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
            OUTPUT "Press ENTER to change to Config-Menu."
            INPUT dummy

            return UI_CONFIG
        END IF

        OUTPUT "Starting simulation..."
        //CALL start_simulation(settings)
        OUTPUT "Simulation finished."
        OUTPUT "You can find more data in the storage."
        OUTPUT "Press ENTER to continue."
        INPUT dummy

        return UI_SIMULATION

    ELSE IF choice = 2 THEN
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION