INCLUDE FILE ui.h
INCLUDE FILE confi.h

FUNCTION print_configscreen(settings)

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "             CONFIG MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "Current Settings"
    OUTPUT "------------------------------------"
    OUTPUT "1 Spots per Floor      : ", settings.size
    OUTPUT "2 Floors               : ", settings.floors
    OUTPUT "3 Gates                : ", settings.gates
    OUTPUT "4 Tick Length (sec)    : ", settings.real_equivalent
    OUTPUT "5 Max Ticks            : ", settings.max_ticks
    OUTPUT "6 Random Seed          : ", settings.rand_seed
    OUTPUT "------------------------------------"
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION

FUNCTION validate_user_input_config(user_choice, min, max, allow_negative)

    IF user_choice != type int THEN
        OUTPUT "Your input is not an integer!"
        OUTPUT "Please press ENTER and try again... "

        INPUT dummy
        return INVALID
    END IF

    IF allow_negative = FALSE AND user_choice < 0 THEN
        OUTPUT "Negative values are not allowed!"
        OUTPUT "Please press ENTER and try again... "

        INPUT dummy
        return INVALID
    END IF

    IF user_choice < min THEN
        OUTPUT "Your input must be >= ", min
        OUTPUT "Please press ENTER and try again... "

        INPUT dummy
        return INVALID
    END IF

    IF user_choice > max THEN
        OUTPUT "Value must be <= ", max
        OUTPUT "Please press ENTER and try again... "

        INPUT dummy
        return INVALID
    END IF

    return VALID

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