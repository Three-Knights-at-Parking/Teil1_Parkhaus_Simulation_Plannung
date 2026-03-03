INCLUDE FILE ui.h
INCLUDE FILE home.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h
INCLUDE FILE storage.h

/*
 * @file ui.psc
 * @brief UI state machine and shared UI helper functions.
 *
 * Contains:
 * - user_input(): reads raw menu input
 * - validate_user_input(): validates range (and conceptually type)
 * - welcome_message(): initial screen and global UI init
 * - ui_start(): UI state machine, dispatches to sub menus
 *
 * Ownership:
 * - The settings object is owned by the UI state machine (ui_start).
 * - Cleanup is done when UI exits (delete_settings).
 */


/* ========================================================================= */
/* Shared input helpers                                                      */
/* ========================================================================= */

FUNCTION user_input()

    // Reads a raw menu selection.
    // NOTE: In a C implementation, check the parsing result (scanf return value)
    // or read a string and parse it with strtol to detect non-integer input.
    OUTPUT "ENTER the number (int) you want navigate to: "
    value ← INPUT

    return value

END FUNCTION


FUNCTION validate_user_input(user_choice, max_valid_number)

    // NOTE: Pseudocode type check. In C, do not compare "type int".
    // Instead validate via scanf return value or parse a string safely.
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


/* ========================================================================= */
/* Welcome screen                                                            */
/* ========================================================================= */

FUNCTION welcome_message()

    CLEAR Terminal

    // Reset UI-side settings initialization flag at program start.
    // This flag is used by the config/simulation menus to ensure configuration
    // was performed before starting the simulation.
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


/* ========================================================================= */
/* Main UI state machine                                                     */
/* ========================================================================= */

FUNCTION ui_start()

    // The UI state machine owns the settings object and passes it by reference
    // to sub menus that may read and modify the configuration.
    //Implementing in C it should be allocated in the heap storage for better handling.
    Settings settings
    p_settings ← &settings

    state ← CALL welcome_message()

    WHILE state != UI_EXIT DO

        IF state = UI_HOME THEN
            state ← CALL home_menu()

        ELSE IF state = UI_KONFIG THEN
            state ← CALL config_menu(p_settings)

        ELSE IF state = UI_SIMULATION THEN
            state ← CALL simulation_menu(p_settings)

        ELSE IF state = UI_STORAGE THEN
            state ← CALL storage_menu()

        ELSE
            // Fallback in case of unexpected state value
            state ← UI_HOME
        END IF

    END WHILE

    // Free memory owned by settings (e.g., name/src_path strings).
    CALL delete_settings(p_settings)

    return UI_EXIT

END FUNCTION