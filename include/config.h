#ifndef KONFIG_H
#define KONFIG_

#define CONFIG_MAX_VALID_NUMBER 6

#define MIN_SIZE 1
#define MIN_FLOORS 1
#define MIN_GATES 1
#define MIN_TICK 10
#define MIN_MIN_TICKS -365
#define MIN_SEED -1

#define MAX_SIZE 100
#define MAX_FLOORS 10
#define MAX_GATES 6
#define MAX_TICK 86400
#define MAX_MAX_TICKS 100
#define MAX_SEED 2147483647

typedef struct Settings {
    //char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    //char* name; // The name of the parking complex. Empty if default ("Rauenegg")
    uint16_t size; // Total parking spots per floor
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint8_t gates; // Number of gates. This will affect queue time.
    uint16_t real_equivalent; // Tick equivalent in real time (seconds), min. 10.
    //enum OutputMode output_mode; //FIXME Needs specific definition @Dani
    //enum QueueLeavable is_leavable; // Determines if vehicles can leave the queue early at any positions.
    int32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent. -2 for 2 day equivalent, ...
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
} Settings;

#endif