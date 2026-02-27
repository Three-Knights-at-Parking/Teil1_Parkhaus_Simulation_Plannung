#ifndef UI_H
#define UI_H

typedef enum {
    UI_HOME,
    UI_SIMULATION,
    UI_KONFIG,
    UI_STORAGE,
    UI_EXIT
} ui_state;

ui_state welcome_message();
ui_state ui_start();

#endif