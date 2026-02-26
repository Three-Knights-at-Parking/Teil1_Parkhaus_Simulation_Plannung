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
struct SimulationObject {
    int id;
    SimulationTickFunction tick;
};
//typedef tick_t unit32_t;
//typedef places_p unit16_t

typedef struct Parkhaus {
    SimulationObject base; // base object
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future
    uint32_t current_time; // Current tick time.
    uint16_t size; // Number of total parking spaces
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint16_t fill_size; // Number of slots filled
    uint16_t queue_size; // Number of cars in queue
}Parkhaus;

typedef struct Car {
    SimulationObject base; // base object
    uint32_t created_at; // Time created
    uint32_t queue_time; // Time wasted in queue
    uint32_t parking_time; // Current total parking time
    uint16_t current_slot; // Currently occupied parking spot, 0 if none.
    //uint16_t current_floor; // Currently occupied floor, 0 if none or don't care
}Car;

typedef struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    uint16_t size; // Total parking spots
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint16_t real_equivalent; // Tick equivalent in real time (seconds)
    uint8_t output_mode; // 0 normal, 1 verbose, 2 debug FIXME Needs specific definition @Dani
    uint32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent.
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
}Settings;


/* ******************************************************
 						ADD

 CAR:
		- leavingIn_ticks -> Cars
      	- Benefit : kein hochzählen in car nötig
      	- further funcionality Auto kann mehr als ein Parkplatz benötigen -> neededSpaces + simulationsvariable in Settings
 		- Queue_Entry / Exit

PARKHAUS:
		- add total_left
		- add total_entry
		- add anz_entrance --> important for Simulation

 SETTINGS:
	 	- maxParking_Ticks
			setting files benötig eine einstellung für den ParkingTime generator was die max Parkzeit (in Ticks) beträgt
 		- parking_time unnötig --> can be calculated durch created_at--> safe memory
			parking_time müsste auch hochgezählt werden
		- BadParking -> warscheinlichkeit
		- CarSpawn-perc -> Warscheinlichkeit
			Berrechnung ob car entry für jede Sekunde eines Ticks? Abzüglich einfahrtzeit?
			Max mögliche einfahrten 1Car pro 4 Sekunden -> Pro schranke
		- CarEntry_timeNeeded
		- Tick_inSec -> for simulation


 Allgemein bitte alle zeiten in Ticks bennenen -> verhindert verwirrung
*/
#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H