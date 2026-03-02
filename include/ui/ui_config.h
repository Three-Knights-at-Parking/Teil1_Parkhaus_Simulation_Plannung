#ifndef CONFIG_H
#define CONFIG_H

/*
 * File: config.h
 * Description: Settings structure and configuration menu declarations.
 */

#include <stdint.h>
#include "ui.h"
#include <../types.h>

/* Maximum valid menu number in Config menu (0..CONFIG_MAX_VALID_NUMBER). */
#define CONFIG_MAX_VALID_NUMBER 10

/* Name input constraints */
#define NAME_MAX_LEN 64

/* Mode select constraints */
#define MIN_MODE_SELECT 0
#define MAX_MODE_SELECT 3

/* Probability is configured in percent. */
#define MIN_PROB_PERCENT 0.0f
#define MAX_PROB_PERCENT 100.0f

/* Allowed ranges for settings (min/max). */
#define MIN_CAPACITY          1
#define MIN_FLOORS            1
#define MIN_GATES             1
#define MIN_GATE_ENTRY_SEC    1
#define MIN_TICK_SEC          1
#define MIN_REAL_EQUIV_SEC    10
#define MIN_MAX_TICKS         -365
#define MIN_SEED              -1

#define MAX_CAPACITY          200
#define MAX_FLOORS            10
#define MAX_GATES             6
#define MAX_GATE_ENTRY_SEC    120
#define MAX_TICK_SEC          86400
#define MAX_REAL_EQUIV_SEC    86400
#define MAX_MAX_TICKS         100
#define MAX_SEED              2147483647

/**
 * @brief Indicates whether settings are initialized with default values.
 */
typedef enum
{
    NOT_INITIALIZED,
    INITIALIZED
} settings_state_flag;

/**
 * @brief Initializes Settings with default values.
 *
 * @return Settings structure with default configuration.
 */
Settings init_settings(void);

/**
 * @brief Prints the configuration screen including current settings.
 *
 * @param[in] settings The current settings to display.
 */
void print_configscreen(Settings settings);

/**
 * @brief Validates an integer config value based on range and negativity rule.
 *
 * @param[in] value           Value entered by the user.
 * @param[in] min             Minimum allowed value.
 * @param[in] max             Maximum allowed value.
 * @param[in] allow_negative  If FALSE, negative values are rejected.
 * @return VALID if value is acceptable, otherwise INVALID.
 */
validation_flag validate_int_input(int value, int min, int max, int allow_negative);

/**
 * @brief Validates a float percentage input in the range [0.0 .. 100.0].
 *
 * @param[in] value Value entered by the user.
 * @return VALID if value is within [0.0 .. 100.0], otherwise INVALID.
 */
validation_flag validate_float_input_percent(float value);

/**
 * @brief Reads and validates an integer value until it is valid.
 *
 * @param[in] min             Minimum allowed value.
 * @param[in] max             Maximum allowed value.
 * @param[in] allow_negative  If FALSE, negative values are rejected.
 * @return A validated integer value within the configured constraints.
 */
int edit_int_setting(int min, int max, int allow_negative);

/**
 * @brief Reads and validates a float percentage value until it is valid.
 *
 * @return A validated percentage value within [0.0 .. 100.0].
 */
float edit_float_setting_percent(void);

/**
 * @brief Handles the configuration menu interaction.
 *
 * @param[in,out] settings The current settings (may be initialized/updated).
 * @return Next UI state depending on user selection.
 */
ui_state config_menu(Settings settings);

#endif /* CONFIG_H */