/**
 * @brief Displays the Home-Menu and processes user input.
 *
 * @return Next UI-state.
 */
INCLUDE FILE ui.psc

FUNCTION print_homescreen()

    OUTPUT "=============================="
    OUTPUT "         Home-Menu "
    OUTPUT "=============================="
    OUTPUT "1 - Simulation"
    OUTPUT "2 - Configuration"
    OUTPUT "3 - Storage"
    OUTPUT "0 - Quit"
    OUTPUT ""

END FUNCTION

FUNCTION home_menu()

    CALL print_homescreen()

    CALL user_input()

    IF choice = 1 THEN
        return "SIMULATION"

    ELSE IF choice = 2 THEN
        return "KONFIG"

    ELSE IF choice = 3 THEN
        return "STORAGE"

    ELSE IF choice = 0 THEN
        return "EXIT"

    ELSE
        OUTPUT "Ungültige Eingabe"
        return "HOME"
    END IF

END FUNCTION