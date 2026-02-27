#ifndef UI_H
#define UI_H

typedef enum {
    UI_HOME,
    UI_SIMULATION,
    UI_KONFIG,
    UI_STORAGE,
    UI_EXIT
} ui_state;

typedef enum {
    INVALID,
    VALID
} validation_flag;

int user_input();
validation_flag validate_user_input(int user_choice, const int max_valid_number);
ui_state welcome_message();
ui_state ui_start();

#endif