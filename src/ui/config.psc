INCLUDE FILE ui.h
INCLUDE FILE config.h


FUNCTION init_settings()

    CREATE FROM STRUCT Settings settings

    settings.capacity ← 100
    settings.floors ← 1
    settings.gates ← 1
    settings.entry_probability_perSec_prec ← 75.0
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
    OUTPUT "1 Name                 : ", settings.name
    OUTPUT "2 Capacity / Floor     : ", settings.capacity
    OUTPUT "3 Floors               : ", settings.floors
    OUTPUT "4 Gates                : ", settings.gates
    OUTPUT "5 Gate Entry Time (sec): ", settings.gate_entry_inSec
    OUTPUT "6 Tick Length (sec)    : ", settings.tick_inSec
    OUTPUT "7 Mode Select          : ", settings.mode_select
    OUTPUT "8 Entry Prob / Sec (%) : ", settings.entry_probability_perSec_prec
    OUTPUT "9 Max Ticks            : ", settings.max_ticks
    OUTPUT "10 Random Seed         : ", settings.rand_seed
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


FUNCTION validate_float_input_percent(value)

    IF value != type float THEN
        OUTPUT "Your input is not a valid number!"
        OUTPUT "Please enter a decimal value (e.g. 25.5)"
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF value < 0.0 OR value > 100.0 THEN
        OUTPUT "Probability must be between 0.0 and 100.0 percent."
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    return VALID

END FUNCTION


FUNCTION validate_string_input(text, max_len)

    IF text != type string THEN
        OUTPUT "Your input is not a string!"
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF LENGTH(text) = 0 THEN
        OUTPUT "Text cannot be empty!"
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF LENGTH(text) > max_len THEN
        OUTPUT "Text is too long! Max length: ", max_len
        OUTPUT "Press ENTER and try again..."
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


FUNCTION edit_float_setting_percent()

    valid ← FALSE

    WHILE valid = FALSE DO
        new_value ← INPUT
        valid ← CALL validate_float_input_percent(new_value)
    END WHILE

    return new_value

END FUNCTION


FUNCTION edit_string_setting(max_len)

    valid ← FALSE

    WHILE valid = FALSE DO
        new_text ← INPUT
        valid ← CALL validate_string_input(new_text, max_len)
    END WHILE

    return new_text

END FUNCTION


FUNCTION edit_mode_select()

    OUTPUT "Select mode:"
    OUTPUT "0 = NONE | 1 = NORMAL | 2 = VERBOSE | 3 = DEBUG"
    OUTPUT ""

    return CALL edit_int_setting(0, 3, FALSE)

END FUNCTION


FUNCTION apply_mode_select(settings)

    IF settings.mode_select = 0 THEN
        settings.output_mode ← NONE

    ELSE IF settings.mode_select = 1 THEN
        settings.output_mode ← NORMAL

    ELSE IF settings.mode_select = 2 THEN
        settings.output_mode ← VERBOSE

    ELSE IF settings.mode_select = 3 THEN
        settings.output_mode ← DEBUG
    END IF

END FUNCTION


FUNCTION output_mode_to_string(mode)

    IF mode = NONE THEN
        return "NONE"
    ELSE IF mode = NORMAL THEN
        return "NORMAL"
    ELSE IF mode = VERBOSE THEN
        return "VERBOSE"
    ELSE IF mode = DEBUG THEN
        return "DEBUG"
    END IF

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
        OUTPUT "Enter name (max ", NAME_MAX_LEN, " chars): "
        settings.name ← CALL edit_string_setting(NAME_MAX_LEN)
        return UI_KONFIG


    ELSE IF choice = 2 THEN
        OUTPUT "Enter capacity per floor (min ", MIN_CAPACITY, " / max ", MAX_CAPACITY, "): "
        settings.capacity ← CALL edit_int_setting(MIN_CAPACITY, MAX_CAPACITY, FALSE)
        return UI_KONFIG


    ELSE IF choice = 3 THEN
        OUTPUT "Enter number of floors (min ", MIN_FLOORS, " / max ", MAX_FLOORS, "): "
        settings.floors ← CALL edit_int_setting(MIN_FLOORS, MAX_FLOORS, FALSE)
        return UI_KONFIG


    ELSE IF choice = 4 THEN
        OUTPUT "Enter number of gates (min ", MIN_GATES, " / max ", MAX_GATES, "): "
        settings.gates ← CALL edit_int_setting(MIN_GATES, MAX_GATES, FALSE)
        return UI_KONFIG


    ELSE IF choice = 5 THEN
        OUTPUT "Enter gate entry time in seconds: "
        settings.gate_entry_inSec ← CALL edit_int_setting(MIN_GATE_ENTRY_SEC, MAX_GATE_ENTRY_SEC, FALSE)
        return UI_KONFIG


    ELSE IF choice = 6 THEN
        OUTPUT "Enter tick length in seconds: "
        settings.tick_inSec ← CALL edit_int_setting(MIN_TICK_SEC, MAX_TICK_SEC, FALSE)
        return UI_KONFIG


    ELSE IF choice = 7 THEN
        OUTPUT "Select mode (0 = NONE, 1 = NORMAL, 2 = VERBOSE, 3 = DEBUG): "
        settings.mode_select ← CALL edit_int_setting(MIN_MODE_SELECT, MAX_MODE_SELECT, FALSE)
        return UI_KONFIG


    ELSE IF choice = 8 THEN
        OUTPUT "Enter entry probability per second (", MIN_PROB_PERCENT, " - ", MAX_PROB_PERCENT, " %): "
        settings.entry_probability_perSec_prec ← CALL edit_float_setting_percent()
        return UI_KONFIG


    ELSE IF choice = 9 THEN
        OUTPUT "Enter max ticks (-1/-2/... for day equivalents): "
        settings.max_ticks ← CALL edit_int_setting(MIN_MAX_TICKS, MAX_MAX_TICKS, TRUE)
        return UI_KONFIG


    ELSE IF choice = 10 THEN
        OUTPUT "Enter random seed (or use -1 for default): "
        settings.rand_seed ← CALL edit_int_setting(MIN_SEED, MAX_SEED, TRUE)
        return UI_KONFIG


    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION