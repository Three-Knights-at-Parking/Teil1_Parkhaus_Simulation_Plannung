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
typedef struct GenericVehicle GenericVehicle;

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
 * Determines if vehicles can leave the queue early (at any position)
 */
enum QueueLeavable {LEAVABLE, NON_LEAVABLE};

/**
 * Return values for functions/validation.
 */
enum SuccessState{ ERROR = -1, OK = 0, UNKNOWN = 1};

/**
 * Polymorphic base for anything that has a tick.
 */
struct SimulationObject {
    int id;
    SimulationTickFunction tick;
    enum ObjectType type;
};

/**
 * Vehicle Base for everything that can enter a queue and parking slot.
 */
struct GenericVehicle {
    SimulationObject base; // base object
    GenericVehicle *p_next;  // Chain with other Vehicles
    uint32_t created_at_tick; // Tick of creation
    uint32_t park_house_entered; // Entry tick, when the car started parking
    uint32_t park_house_left; // Exit tick, when the car left the parking slot
    uint16_t current_slot; // Currently occupied parking spot, 0 if none.
    uint16_t current_floor; // Currently occupied floor, 0 if none or don't care
};

struct Parkhaus {
    SimulationObject base; // base object.
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future && Update in Documentation of Settings and Parkhaus!!
    uint16_t size; // Number of total parking spaces.
    uint8_t floors; // Number of floors. This is currently miscellaneous.
    float_t fill_size; // Number of slots filled.
    uint32_t num_gates; // Number of gates.
    Queue **gate_queues; // array of Queue* with size = num_gates
    GenericVehicle *p_parked_head; // linked list of parked vehicles.
    GenericVehicle *p_parked_tail;
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
    GenericVehicle *p_head; // first vehicle in queue
    GenericVehicle *p_tail; // last vehicle in queue
    uint16_t demand;   // demand assigned to this gate in the current tick
    uint8_t max_size; // maximum size of Queue before no cars should be created anymore.
};
//typedef tick_t unit32_t;
//typedef places_p unit16_t

struct Car {
    GenericVehicle base; // base vehicle object
    uint8_t spaces_needed; // How many spaces this vehicle needs
};

// --- EXAMPLE OF ANOTHER VEHICLE TYPE ---
//
//
// struct ElectricCar {
//     GenericVehicle base; // base vehicle object
//     uint8_t spaces_needed; // How many spaces this vehicle needs
//     uint32_t charging_time; // The amount of time this car needs to charge. Can be randomized
// };

struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    char* name; // The name of the parking complex. Empty if default ("Rauenegg")
    uint16_t size; // Total parking spots per floor
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint8_t gates; // Number of gates. This will affect queue time.
    uint16_t real_equivalent; // Tick equivalent in real time (seconds), min. 10.
    enum OutputMode output_mode; //FIXME Needs specific definition @Dani
    enum QueueLeavable is_leavable; // Determines if vehicles can leave the queue early at any positions.
    int32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent. -2 for 2 day equivalent, ...
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
};

#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H