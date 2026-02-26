/**
 * Define all types in here. If you wish for an object to be manipulated via the Simulation tick,
 * refer to the structure docs on how to implement your type with SimulationObject.
 */
#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H
#include <stdatomic.h>
#include <stdint.h>

typedef struct SimulationObject SimulationObject; // No touchy
typedef void (*SimulationTickFunction)(SimulationObject *p_self, uint32_t current_time); // No touchy

/**
 * Base Simulation Object for polymorphism.
 */
// Eine simulation simuliert immer das selbe Szenario / Zeitfenster, lediglich mit unterschiedlichen Parkhaus formaten
struct SimulationObject {
    int id;
    tick_t current_time; // Current tick time.
    tick_t end_time;
    SimulationTickFunction tick;
};
//---------------------------------------
// alles auf Ticks anpassen?????
//--> Einfachere kodierung und nur speichern des Ticks -> Kein umrechnen while runtime nötig von Ticks in Uhrzeit

//generalisierte definition for easy adjustment
typedef uint32_t tick_t;
typedef uint16_t ParkingSpaces;
//---------------------------------------


typedef struct Parkhaus {
    SimulationObject base; // base object
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future
     uint8_t floors; // Number of floors. This is currently miscellaneous

    ParkingSpaces size; // Number of total parking spaces
    ParkingSpaces fill_size; // Number of slots filled
    ParkingSpaces queue_size; // Number of cars in queue

//########## WRONG HERE ###########################
    ParkingSpaces current_slot; // *

}Parkhaus;

typedef struct Car {
    SimulationObject base; // base object
    tick_t created_at; // Time created
    tick_t queue_time; // Time wasted in queue
    tick_t parking_time; // Current total parking time
    ParkingSpaces current_slot; // Currently occupied parking spot, 0 if none.
    //uint16_t current_floor; // Currently occupied floor, 0 if none or don't care
}Car;

typedef struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    ParkingSpaces size; // Total parking spots
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint16_t real_equivalent; // Tick equivalent in real time (seconds)
    uint8_t output_mode; // 0 normal, 1 verbose, 2 debug FIXME Needs specific definition @Dani
    tick_t max_ticks; //--> move to SimObject NOT general Settings!!! Kills the funktion of multiple simulations
    // Max amount of ticks before the simulation stops. -1 for day equivalent.
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
}Settings;


#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H