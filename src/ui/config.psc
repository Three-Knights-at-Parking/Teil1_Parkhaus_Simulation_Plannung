INCLUDE FILE ui.h
INCLUDE FILE config.h

/*
 * @file config.psc
 * @brief Configuration menu implementation (edit Settings).
 *
 * This module edits the Settings object that is owned by the UI state machine.
 * The object is passed by pointer so changes persist across menus.
 *
 * Notes on input validation:
 * - "type int"/"type float" checks are pseudocode.
 * - In C, validate input by checking scanf return value or parsing strings safely.
 */


/* ========================================================================= */
/* Global state                                                              */
/* ========================================================================= */

g_settings_state ← SETTINGS_NOT_INITIALIZED


/* ========================================================================= */
/* Settings initialization                                                   */
/* ========================================================================= */

FUNCTION init_settings(p_settings)

    // Defensive check: do nothing if settings pointer is invalid.
    IF p_settings = NULL THEN
        return
    END IF

    p_settings.src_path ← NULL
    p_settings.name ← "Rauenegg"

    p_settings.capacity ← 100
    p_settings.floors ← 1
    p_settings.gates ← 1

    p_settings.gate_entry_inSec ← 5
    p_settings.tick_inSec ← 10

    p_settings.mode_select ← 1
    p_settings.output_mode ← NORMAL

    p_settings.entry_probability_perSec_prec ← 75.0

    // Non-UI default (not editable in Config-Menu, but required for Simulation)
    p_settings.real_equivalent ← 10

    p_settings.max_ticks ← 24
    p_settings.rand_seed ← -1

END FUNCTION


/* ========================================================================= */
/* Screen printing                                                           */
/* ========================================================================= */

FUNCTION print_configscreen(p_settings)

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "             CONFIG MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "Current Settings"
    OUTPUT "------------------------------------"
    OUTPUT "1 Name                 : ", p_settings.name
    OUTPUT "2 Capacity / Floor     : ", p_settings.capacity
    OUTPUT "3 Floors               : ", p_settings.floors
    OUTPUT "4 Gates                : ", p_settings.gates
    OUTPUT "5 Gate Entry Time (sec): ", p_settings.gate_entry_inSec
    OUTPUT "6 Tick Length (sec)    : ", p_settings.tick_inSec
    OUTPUT "7 Output Mode          : ", CALL output_mode_to_string(p_settings.output_mode)
    OUTPUT "8 Entry Prob / Sec (%) : ", p_settings.entry_probability_perSec_prec
    OUTPUT "9 Max Ticks            : ", p_settings.max_ticks
    OUTPUT "10 Random Seed         : ", p_settings.rand_seed
    OUTPUT "------------------------------------"
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION


/* ========================================================================= */
/* Validation helpers                                                        */
/* ========================================================================= */

FUNCTION validate_int_input(value, min, max, allow_negative)

    // Pseudocode type validation; in C validate parsing result.
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

    // Pseudocode type validation; in C validate parsing result.
    IF value != type float THEN
        OUTPUT "Your input is not a valid number!"
        OUTPUT "Please enter a decimal value (e.g. 25.5)"
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    IF value < MIN_PROB_PERCENT OR value > MAX_PROB_PERCENT THEN
        OUTPUT "Probability must be between ", MIN_PROB_PERCENT, " and ", MAX_PROB_PERCENT, " percent."
        OUTPUT "Press ENTER and try again..."
        INPUT dummy
        return INVALID
    END IF

    return VALID

END FUNCTION


FUNCTION validate_string_input(text, max_len)

    // In C, string input is always a string buffer, so a "type string" check is unnecessary.
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


/* ========================================================================= */
/* Editing helpers                                                           */
/* ========================================================================= */

FUNCTION edit_int_setting(min, max, allow_negative)

    valid_flag ← INVALID

    WHILE valid_flag != VALID DO
        new_value ← INPUT
        valid_flag ← CALL validate_int_input(new_value, min, max, allow_negative)
    END WHILE

    return new_value

END FUNCTION


FUNCTION edit_float_setting_percent()

    valid_flag ← INVALID

    WHILE valid_flag != VALID DO
        new_value ← INPUT
        valid_flag ← CALL validate_float_input_percent(new_value)
    END WHILE

    return new_value

END FUNCTION


FUNCTION edit_string_setting(max_len)

    valid_flag ← INVALID

    WHILE valid_flag != VALID DO
        new_text ← INPUT
        valid_flag ← CALL validate_string_input(new_text, max_len)
    END WHILE

    return new_text

END FUNCTION


FUNCTION edit_mode_select()

    CLEAR Terminal

    OUTPUT "Select Output Mode:"
    OUTPUT "------------------------------------"
    OUTPUT "0 = NONE"
    OUTPUT "1 = NORMAL"
    OUTPUT "2 = VERBOSE"
    OUTPUT "3 = DEBUG"
    OUTPUT "------------------------------------"
    OUTPUT "Enter your choice (0 - 3): "

    valid_flag ← INVALID

    WHILE valid_flag != VALID DO

        choice ← INPUT
        valid_flag ← CALL validate_int_input(choice, 0, 3, FALSE)

        IF valid_flag != VALID THEN
            OUTPUT "Invalid mode selection."
            OUTPUT "Press ENTER and try again..."
            INPUT dummy
        END IF

    END WHILE

    return choice

END FUNCTION


FUNCTION apply_mode_select(mode_select)

    IF mode_select = 0 THEN return NONE
    ELSE IF mode_select = 1 THEN return NORMAL
    ELSE IF mode_select = 2 THEN return VERBOSE
    ELSE IF mode_select = 3 THEN return DEBUG
    END IF

    // Defensive fallback
    return NORMAL

END FUNCTION


FUNCTION output_mode_to_string(mode)

    IF mode = NONE THEN return "NONE"
    ELSE IF mode = NORMAL THEN return "NORMAL"
    ELSE IF mode = VERBOSE THEN return "VERBOSE"
    ELSE IF mode = DEBUG THEN return "DEBUG"
    END IF

    // Defensive fallback
    return "NORMAL"

END FUNCTION


/* ========================================================================= */
/* Config menu                                                               */
/* ========================================================================= */

FUNCTION config_menu(p_settings)

    // Initialize settings with defaults on first entry.
    IF g_settings_state = SETTINGS_NOT_INITIALIZED THEN
        CALL init_settings(p_settings)
        g_settings_state ← SETTINGS_INITIALIZED
    END IF

    CALL print_configscreen(p_settings)

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, CONFIG_MAX_VALID_NUMBER)
    END WHILE


    IF choice = 1 THEN
        OUTPUT "Enter name (max ", NAME_MAX_LEN, " chars): "
        p_settings.name ← CALL edit_string_setting(NAME_MAX_LEN)
        return UI_KONFIG

    ELSE IF choice = 2 THEN
        OUTPUT "Enter capacity per floor (min ", MIN_CAPACITY, " / max ", MAX_CAPACITY, "): "
        p_settings.capacity ← CALL edit_int_setting(MIN_CAPACITY, MAX_CAPACITY, FALSE)
        return UI_KONFIG

    ELSE IF choice = 3 THEN
        OUTPUT "Enter number of floors (min ", MIN_FLOORS, " / max ", MAX_FLOORS, "): "
        p_settings.floors ← CALL edit_int_setting(MIN_FLOORS, MAX_FLOORS, FALSE)
        return UI_KONFIG

    ELSE IF choice = 4 THEN
        OUTPUT "Enter number of gates (min ", MIN_GATES, " / max ", MAX_GATES, "): "
        p_settings.gates ← CALL edit_int_setting(MIN_GATES, MAX_GATES, FALSE)
        return UI_KONFIG

    ELSE IF choice = 5 THEN
        OUTPUT "Enter gate entry time in seconds: "
        p_settings.gate_entry_inSec ← CALL edit_int_setting(MIN_GATE_ENTRY_SEC, MAX_GATE_ENTRY_SEC, FALSE)
        return UI_KONFIG

    ELSE IF choice = 6 THEN
        OUTPUT "Enter tick length in seconds: "
        p_settings.tick_inSec ← CALL edit_int_setting(MIN_TICK_SEC, MAX_TICK_SEC, FALSE)
        return UI_KONFIG

    ELSE IF choice = 7 THEN
        p_settings.mode_select ← CALL edit_mode_select()
        p_settings.output_mode ← CALL apply_mode_select(p_settings.mode_select)
        return UI_KONFIG

    ELSE IF choice = 8 THEN
        OUTPUT "Enter entry probability per second (", MIN_PROB_PERCENT, " - ", MAX_PROB_PERCENT, " %): "
        p_settings.entry_probability_perSec_prec ← CALL edit_float_setting_percent()
        return UI_KONFIG

    ELSE IF choice = 9 THEN
        OUTPUT "Enter max ticks (-1/-2/... for day equivalents): "
        p_settings.max_ticks ← CALL edit_int_setting(MIN_MAX_TICKS, MAX_MAX_TICKS, TRUE)
        return UI_KONFIG

    ELSE IF choice = 10 THEN
        OUTPUT "Enter random seed (or use -1 for default): "
        p_settings.rand_seed ← CALL edit_int_setting(MIN_SEED, MAX_SEED, TRUE)
        return UI_KONFIG

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION