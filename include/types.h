/**
 * Define all types in here. If you wish for an object to be manipulated via the Simulation tick,
 * refer to the structure docs on how to implement your type with SimulationObject.
 */
#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#include <math.h>
#include <stdint.h>

typedef struct SimulationObject SimulationObject; // No touchy
typedef void (*SimulationTickFunction)(SimulationObject *p_self, uint32_t current_time); // No touchy
typedef struct Car Car; //
typedef struct Parkhaus Parkhaus;
typedef struct Settings Settings;
typedef struct Queue Queue;
typedef struct Simulation Simulation;

/**
 * Can be expanded in the future to simulate EVs or Motorcycles etc.
 */
enum ObjectType {CAR, PARKHAUS, QUEUE};

/**
 * NONE - Here for completeness
 * NORMAL - The Normal mode, only the most import statistics and averages -> Minimum Required in "Teil 1"
 * VERBOSE - EVERYTHING, every single bit of data (this will dump performance)
 * DEBUG - NORMAL + Debug Messages (i.e. tick - enteredTick() debugInfo debugInfo)
 */
enum OutputMode {NONE, NORMAL, VERBOSE, DEBUG};

/**
 * Base Simulation Object for polymorphism.
 */
struct SimulationObject {
    int id;
    SimulationTickFunction tick;
    enum ObjectType type;
};


struct Parkhaus {
    SimulationObject base; // base object.
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future
    uint16_t size; // Number of total parking spaces.
    uint8_t floors; // Number of floors. This is currently miscellaneous.
    float_t fill_size; // Number of slots filled.
    uint32_t num_gates; // Number of gates.
    Queue* queue; // Queue for waiting cars.
    Car* parked_cars; // Dynamic List of currently parked cars.
    uint16_t missed_car_entries; // How many car spawns where missed because of full queue.
};
struct Simulation {
    Settings* settings; // The underlying
    uint32_t current_tick; // Current tick time.
    uint16_t real_equivalent; // Tick equivalent in real time (seconds)
    uint32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent.
    int32_t rand_seed; // Specified random seed, -1 if current time should be used in generation (default).
    Parkhaus* parkhaus; // The Parkhaus for this Simulation
};

struct Queue {
    SimulationObject base; // base object.
    uint16_t size; // Number of waiting cars.
    Car* waiting_cars; // Dynamic List of waiting cars.
    uint8_t max_size; // maximum size of Queue before no cars should be created anymore.
};


struct Car {
    SimulationObject base; // base object
    uint32_t created_at; // Time created
    uint32_t park_house_entered; // Entry tick, when the car started parking
    uint32_t parking_time; // Max_tick it will park for (or wait in queue)
    uint16_t current_slot; // Currently occupied parking spot, 0 if none.
    uint16_t current_floor; // Currently occupied floor, 0 if none or don't care
    uint8_t spaces_needed; // Chance of this car parking shitty
};

struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    char* name; // The name of the parking complex. Empty if default ("Rauenegg")
    uint16_t size; // Total parking spots per floor
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint8_t gates; // Number of gates. This will affect queue time.
    uint16_t real_equivalent; // Tick equivalent in real time (seconds), min. 10.
    enum OutputMode output_mode; //FIXME Needs specific definition @Dani
    int32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent. -2 for 2 day equivalent, ...
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
};


#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H