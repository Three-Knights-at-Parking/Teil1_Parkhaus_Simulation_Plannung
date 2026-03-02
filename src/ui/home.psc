INCLUDE FILE ui.h
INCLUDE FILE home.h


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


FUNCTION home_menu()

    CALL print_homescreen()

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN
        return UI_SIMULATION

    ELSE IF choice = 2 THEN
        return UI_KONFIG

    ELSE IF choice = 3 THEN
        return UI_STORAGE

    ELSE IF choice = 0 THEN
        return UI_EXIT
    END IF

END FUNCTION