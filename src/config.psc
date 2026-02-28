INCLUDE FILE ui.h
INCLUDE FILE confi.h

FUNCTION print_configscreen(settings)

    CLEAR Terminal

    OUTPUT "=============================="
    OUTPUT "         Config-Menu"
    OUTPUT "=============================="

    OUTPUT "Current Settings:"
    OUTPUT "1 Parking spots per floor: ", settings.size
    OUTPUT "2 Parking Floors: ", settings.floors
    OUTPUT "3 Amount of Gates: ", settings.gates
    OUTPUT "4 Tick equivalent (sec): ", settings.real_equivalent
    OUTPUT "5 Max ticks (or -1/-2/... for 1/2/... days equivalent): ", settings.max_ticks
    OUTPUT "6 Random seed (or -1 for default): ", settings.rand_seed
    OUTPUT ""
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION

FUNCTION config_menu(settings)

    CALL print_config_screen(settings)

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, CONFIG_MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN
        OUTPUT "Enter new parking spots per floor:"
        settings.size ← INPUT
        return UI_KONFIG

    ELSE IF choice = 2 THEN
        OUTPUT "Enter number of floors:"
        settings.floors ← INPUT
        return UI_KONFIG

    ELSE IF choice = 3 THEN
        OUTPUT "Enter number of gates:"
        settings.gates ← INPUT
        return UI_KONFIG

    ELSE IF choice = 4 THEN
        OUTPUT "Enter tick equivalent (min 10 sec):"
        settings.real_equivalent ← INPUT
        return UI_KONFIG

    ELSE IF choice = 5 THEN
        OUTPUT "Enter max ticks (-1 = 1 day, -2 = 2 days, ...):"
        settings.max_ticks ← INPUT
        return UI_KONFIG

    ELSE IF choice = 6 THEN
        OUTPUT "Enter random seed (-1 for current time):"
        settings.rand_seed ← INPUT
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION