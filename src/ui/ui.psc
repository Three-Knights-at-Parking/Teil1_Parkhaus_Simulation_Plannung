INCLUDE FILE ui.h
INCLUDE FILE home.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h
INCLUDE FILE storage.h


FUNCTION user_input()

    OUTPUT "ENTER the number (int) you want navigate to: "
    value ← INPUT

    return value

END FUNCTION


FUNCTION validate_user_input(user_choice, max_valid_number)

    IF user_choice != type int THEN
        OUTPUT "Your input is not an integer!"
        OUTPUT "Please press ENTER and try again... "
        INPUT dummy
        return INVALID
    END IF

    IF user_choice < 0 OR user_choice > max_valid_number THEN
        OUTPUT "The number you entered is invalid!"
        OUTPUT "Please only choose between the numbers displayed."
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    return VALID

END FUNCTION


FUNCTION welcome_message()

    CLEAR Terminal
    settings_state_flag ← NOT_INITIALIZED

    OUTPUT "========================================="
    OUTPUT "     Parkhaus-Simulation Rauenegg"
    OUTPUT "========================================="
    OUTPUT ""
    OUTPUT "[Welcome Message with brief description]"
    OUTPUT ""
    OUTPUT "Press ENTER to continue..."

    INPUT dummy

    return UI_HOME

END FUNCTION


FUNCTION ui_start()

    state ← CALL welcome_message()

    WHILE state != UI_EXIT DO

        IF state = UI_HOME THEN
            state ← CALL home_menu()

        ELSE IF state = UI_KONFIG THEN
            state ← CALL config_menu(settings)

        ELSE IF state = UI_SIMULATION THEN
            state ← CALL simulation_menu(settings)

        ELSE IF state = UI_STORAGE THEN
            state ← CALL storage_menu()

        END IF

    END WHILE

    return UI_EXIT

END FUNCTION