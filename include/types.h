/**
 * Define all types in here. If you wish for an object to be manipulated via the Simulation tick,
 * refer to the structure docs on how to implement your type with SimulationObject.
 */
#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#include <stdint.h>

typedef struct SimulationObject SimulationObject; // No touchy
typedef void (*SimulationTickFunction)(SimulationObject *p_self, int current_time); // No touchy

/**
 * Base Simulation Object for polymorphism.
 */
struct SimulationObject {
    int id;
    SimulationTickFunction tick;
};


typedef struct Parkhaus {
    SimulationObject base; // base object
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future
    uint32_t current_time; // Current tick time.
    uint8_t size; // Number of total parking spaces
    uint8_t floors; // Number of floors. This is currently miscellaneous
}Parkhaus;

typedef struct Car {
    SimulationObject base; // base object
    uint32_t created_at; // Time created
    uint32_t queue_time; // Time wasted in queue
    uint32_t parking_time; // Current total parking time
    uint8_t current_slot; // Currently occupied parking spot, 0 if none.
    uint8_t current_floor; // Currently occupied floor, 0 if none or don't care
}Car;

typedef struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    uint8_t size; // Total parking spots
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint8_t real_equivalent; // Tick equivalent in real time (minutes)
    uint8_t output_mode; // 0 normal, 1 verbose, 2 debug FIXME Needs specific definition @Dani
    long max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent.
    double rand_seed; // Specified random seed, -1 if current time should be used.
}Settings;


#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H