INCLUDE FILE ui.h
INCLUDE FILE config.h


FUNCTION init_settings()

    CREATE FROM STRUCT Settings settings

    settings.size ← 100
    settings.floors ← 1
    settings.gates ← 1
    settings.real_equivalent ← 3600
    settings.max_ticks ← 24
    settings.rand_seed ← -1

    return settings

END FUNCTION


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


FUNCTION validate_int_input(value, min, max, allow_negative)

    IF value != type int THEN
        OUTPUT "Your input is not an integer!"
        OUTPUT "Please press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF allow_negative = FALSE AND value < 0 THEN
        OUTPUT "Negative values are not allowed!"
        OUTPUT "Please press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF value < min THEN
        OUTPUT "Value must be >= ", min
        OUTPUT "Please press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF value > max THEN
        OUTPUT "Value must be <= ", max
        OUTPUT "Please press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    return VALID

END FUNCTION


FUNCTION edit_int_setting(min, max, allow_negative)

    valid ← FALSE

    WHILE valid = FALSE DO
        new_value ← INPUT
        valid ← CALL validate_int_input(new_value, min, max, allow_negative)
    END WHILE

    return new_value

END FUNCTION


FUNCTION config_menu(settings)

    IF settings_state_flag = NOT_INITIALIZED THEN
        settings ← CALL init_settings()
        settings_state_flag ← INITIALIZED
    END IF

    CALL print_configscreen(settings)

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, CONFIG_MAX_VALID_NUMBER)
    END WHILE

    IF choice = 1 THEN
        OUTPUT "Enter spots per floor (min 1 / max MAX_SIZE): "
        settings.size ← CALL edit_setting(MIN_SIZE, MAX_SIZE, FALSE)
        return UI_KONFIG

    ELSE IF choice = 2 THEN
        OUTPUT "Enter number of floors (min 1 / max MAX_FLOORS): "
        settings.floors ← CALL edit_setting(MIN_FLOORS, MAX_FLOORS, FALSE)
        return UI_KONFIG

    ELSE IF choice = 3 THEN
        OUTPUT "Enter number of gates (min 1 / max MAX_GATES): "
        settings.gates ← CALL edit_setting(MIN_GATES, MAX_GATES, FALSE)
        return UI_KONFIG

    ELSE IF choice = 4 THEN
        OUTPUT "Enter tick length in seconds (min MIN_TICK / max MAX_TICK): "
        settings.real_equivalent ← CALL edit_setting(MIN_TICK, MAX_TICK, FALSE)
        return UI_KONFIG

    ELSE IF choice = 5 THEN
        OUTPUT "Enter max ticks (or use -1/-2/... for 1/2/... days; max MAX_MAX_TICKS): "
        settings.max_ticks ← CALL edit_setting(MIN_MAX_TICKS, MAX_MAX_TICKS, TRUE)
        return UI_KONFIG

    ELSE IF choice = 6 THEN
        OUTPUT "Enter random seed (or use -1 for default): "
        settings.rand_seed ← CALL edit_setting(MIN_SEED, MAX_SEED, TRUE)
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION