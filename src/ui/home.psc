INCLUDE FILE ui.h
INCLUDE FILE home.h

/*
 * @file home.psc
 * @brief Home menu implementation (main navigation).
 *
 * The home menu is responsible for:
 * - printing the home screen
 * - reading and validating the user's menu choice
 * - returning the selected next UI state
 */


/* ========================================================================= */
/* Screen printing                                                           */
/* ========================================================================= */

FUNCTION print_homescreen()

    CLEAR Terminal

    OUTPUT "=============================="
    OUTPUT "         Home-Menu"
    OUTPUT "=============================="
    OUTPUT "1 - Simulation"
    OUTPUT "2 - Configuration"
    OUTPUT "3 - Storage"
    OUTPUT "0 - Quit"
    OUTPUT ""

END FUNCTION


/* ========================================================================= */
/* Menu logic                                                                */
/* ========================================================================= */

FUNCTION home_menu()

    CALL print_homescreen()

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, HOME_MAX_VALID_NUMBER)
    END WHILE

    // Map numeric menu choice to UI state.
    // The state machine in ui_start() will call the appropriate menu handler.
    IF choice = 1 THEN
        return UI_SIMULATION

    ELSE IF choice = 2 THEN
        return UI_KONFIG

    ELSE IF choice = 3 THEN
        return UI_STORAGE

    ELSE IF choice = 0 THEN
        return UI_EXIT
    END IF

    // Defensive fallback (should never be reached because input is validated).
    return UI_HOME

END FUNCTION