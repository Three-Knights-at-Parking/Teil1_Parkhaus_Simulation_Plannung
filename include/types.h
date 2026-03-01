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
    uint16_t current_slot; // Currently occupied parking spot, 0 if none.
    uint16_t current_floor; // Currently occupied floor, 0 if none or don't care
};

struct Parkhaus {
    SimulationObject base; // base object.
    char name[20]; // FIXME size is currently arbitrary, we should probably move this to a defined constant in the future && Update in Documentation of Settings and Parkhaus!!
    uint16_t capacity; // Number of total parking spaces.
    uint8_t floors; // Number of floors. This is currently miscellaneous.
    float_t capacity_taken; // Number of slots filled.
    uint32_t num_gates; // Number of gates.
    Queue* queue; // Queue for waiting cars.
    GenericVehicle *p_parked_head; // linked list of parked vehicles.
    uint16_t missed_car_entries; // How many car spawns where missed because of full queue.
};
struct Simulation {
    Settings* settings; // The underlying
    uint32_t current_tick; // Current tick time.
    uint16_t real_equivalent; // Tick equivalent in real time (seconds)
    Parkhaus* parkhaus; // The Parkhaus for this Simulation
};

struct Queue {
    SimulationObject base; // base object.
    uint16_t capacity; // Number of waiting cars.
    GenericVehicle *p_head; // first vehicle in queue
    GenericVehicle *p_tail; // last vehicle in queue
    uint8_t max_capacity; // maximum size of Queue before no cars should be created anymore.
};
//typedef tick_t unit32_t;
//typedef places_p unit16_t

struct Car {
    GenericVehicle base; // base vehicle object
    uint8_t minimum_spaces; // How many spaces this vehicle needs at least.
    uint8_t spaces_needed; // How many spaces this vehicle needs
};

// --- EXAMPLE OF ANOTHER VEHICLE TYPE ---
//
//
// struct ElectricCar {
//     GenericVehicle base; // base vehicle object
//     uint8_t minimum_spaces; // How many spaces this vehicle needs at least.
//     uint8_t spaces_needed; // How many spaces this vehicle needs
//     uint32_t charging_time; // The amount of time this car needs to charge. Can be randomized
// };

struct Settings {
    char* src_path; // Relative path to settings file, if any. Settings takes ownership of the string.
    char* name; // The name of the parking complex. Empty if default ("Rauenegg")
    uint16_t capacity; // Total parking spots per floor
    uint8_t floors; // Number of floors. This is currently miscellaneous
    uint8_t gates; // Number of gates. This will affect queue time.
    uint16_t gate_entry_inSec; // Time needed for an vehicle to enter der parkhouse
	uint16_t tick_inSec; //Time in seconds of one Tick
	float entry_probability_perSec_prec; //probability of a Car entering per second
    uint16_t real_equivalent; // Tick equivalent in real time (seconds), min. 10.
    enum OutputMode output_mode; //FIXME Needs specific definition @Dani
    enum QueueLeavable is_leavable; // Determines if vehicles can leave the queue early at any positions.
    int32_t max_ticks; // Max amount of ticks before the simulation stops. -1 for day equivalent. -2 for 2 day equivalent, ...
    int32_t rand_seed; // Specified random seed, -1 if current time should be used.
};

/**
 * Momentaufnahme aller Kennzahlen am Ende eines Ticks.
 * @author: ibach
 */
typedef struct StatsTick {
    SimulationObject base;
    uint32_t tick; /**< Aktueller Tick dieser Momentaufnahme. */

    /* 1) Auslastung & Kapazität */
    uint16_t capacity_total; /**< Gesamtkapazität des Parkhauses (auch fractional möglich). */
    uint16_t capacity_taken; /**< Belegte Plätze am Tick-Ende. */
    uint16_t capacity_free; /**< Freie Plätze am Tick-Ende. */
    float capacity_taken_percent; /**< Auslastung in % (belegt/gesamt). */
    float peak_capacity_taken_percent_so_far; /**< Bisherige Peak-Auslastung in %. */
    uint32_t first_full_tick; /**< Erster Tick ohne freie Plätze, -1 wenn nie voll. */
    uint32_t full_ticks_so_far; /**< Anzahl Ticks, in denen das Parkhaus vollständig voll war. */

    /* 2) Durchsatz / Flow */
    uint16_t arrivals_generated; /**< Demand/Ankünfte in diesem Tick. */
    uint16_t enqueued; /**< In Queue aufgenommen in diesem Tick. */
    uint16_t entered; /**< In Parkhaus eingefahren in diesem Tick. */
    uint16_t departed; /**< Aus Parkhaus ausgefahren in diesem Tick. */
    uint32_t net_occupancy_change; /**< Nettoänderung Belegung (entered - departed). */
    // ?? uint64_t total_entered_so_far; /**< Kumulierte Einfahrten bis inkl. Tick. */
    // ?? uint64_t total_departed_so_far; /**< Kumulierte Ausfahrten bis inkl. Tick. */

    /* 3) Queue / Warteschlange (global) */
    uint8_t queue_length_end; /**< Queue-Länge am Tick-Ende (global). */
    uint8_t queue_length_max_so_far; /**< Maximale Queue-Länge seit Simulationsstart (global). */
    uint32_t queue_rejections; /**< Fahrzeuge, die nicht anstehen konnten (Tick). */
    float avg_queue_wait_ticks_entered; /**< Ø-Wartezeit der Fahrzeuge, die in diesem Tick einfuhren. */
    uint32_t max_queue_wait_ticks_so_far; /**< Maximale Queue-Wartezeit seit Simulationsstart. */
    float queue_active_ratio_percent_so_far; /**< Anteil Ticks mit Queue>0 in %. */

    /* 4) Parkdauer */
    uint32_t avg_parking_duration_ticks_departed; /**< Ø-Parkdauer der in diesem Tick ausgefahrenen Fahrzeuge. */

    /* 6) Blocker / Ursachenanalyse */
    uint8_t blocker_full_active; /**< 1, wenn Tick wegen voller Kapazität blockiert war, sonst 0. */
    float blocker_full_ratio_percent_so_far; /**< Anteil Ticks mit Blocker "voll" in %. */

    /* 8) Qualitäts-/Regel-Statistiken */
    uint16_t bad_parking_cases; /**< Anzahl "schlecht geparkt" in diesem Tick. */
    float bad_parking_tick_percent; /**< Anteil "schlecht geparkt" in % im Tick. */

    /* 9) Zeitreihen-Zusammenfassungen (laufend) */
    float avg_capacity_percent_so_far; /**< Laufender Mittelwert der Auslastung in %. */
    float avg_queue_length_so_far; /**< Laufender Mittelwert der Queue-Länge. */
    uint16_t avg_entered_per_tick_so_far; /**< Laufender Ø-Durchsatz entered/Tick. */
    uint16_t avg_departed_per_tick_so_far; /**< Laufender Ø-Durchsatz departed/Tick. */
    uint8_t peak_queue_value_so_far; /**< Peak Queue-Wert seit Start. */
    uint32_t peak_queue_tick; /**< Tick-Zeitpunkt des Queue-Peaks. */
    float peak_capacity_value_percent_so_far; /**< Peak Belegung in %. */
    uint32_t peak_capacity_tick; /**< Tick-Zeitpunkt des Belegungs-Peaks. */

    /* 5) ADD-ON Betrachtung der einzelnen Gates & Fahrzeugtypen */

} StatsTick;

/**
 * Aggregierte Endauswertung über die vollständige Simulation.
 * @author: ibach
 */
typedef struct StatsGesamte {
    SimulationObject base;
    uint32_t total_ticks; /**< Anzahl ausgewerteter Ticks. */

    /* 1) Auslastung & Kapazität */
    float capacity_total; /**< Gesamtkapazität des Parkhauses. */
    float capacity_taken_percent_avg; /**< Durchschnittliche Auslastung über alle Ticks in %. */
    float capacity_taken_percent_peak; /**< Maximale Auslastung in %. */
    uint32_t capacity_taken_peak_tick; /**< Tick der maximalen Auslastung. */
    int32_t first_full_tick; /**< Erster Tick ohne freie Plätze, -1 wenn nie voll. */
    uint32_t full_ticks; /**< Anzahl Ticks mit voller Belegung. */

    /* 2) Durchsatz / Flow */
    uint64_t arrivals_total; /**< Kumulierte Ankünfte. */
    uint64_t enqueued_total; /**< Kumuliert in Queue aufgenommen. */
    uint64_t entered_total; /**< Kumulierte Einfahrten. */
    uint64_t departed_total; /**< Kumulierte Ausfahrten. */
    double net_occupancy_change_total; /**< Kumulierte Nettoänderung der Belegung. */
    float entered_per_tick_avg; /**< Durchschnittlich entered pro Tick. */
    float departed_per_tick_avg; /**< Durchschnittlich departed pro Tick. */

    /* 3) Queue / Warteschlange (global) */
    uint8_t queue_length_avg; /**< Durchschnittliche Queue-Länge über alle Ticks. */
    uint8_t queue_length_peak; /**< Maximale Queue-Länge global. */
    uint32_t queue_length_peak_tick; /**< Tick des globalen Queue-Peaks. */
    uint64_t queue_rejections_total; /**< Summe aller Queue-Rejections. */
    uint32_t queue_wait_avg_ticks; /**< Ø-Wartezeit über alle erfolgreich eingetretenen Fahrzeuge. */
    uint32_t queue_wait_max_ticks; /**< Maximale Wartezeit in der gesamten Simulation. */
    uint32_t queue_active_ratio_percent; /**< Anteil Ticks mit Queue>0 in %. */

    /* 4) Parkdauer */
    uint16_t parking_duration_avg_ticks; /**< Ø-Parkdauer aller ausgefahrenen Fahrzeuge. */

    /* 6) Blocker / Ursachenanalyse */
    float blocker_full_ratio_percent; /**< Anteil Ticks, in denen "voll" als Blocker aktiv war. */

    /* 8) Qualitäts-/Regel-Statistiken */
    uint64_t bad_parking_cases_total; /**< Gesamtanzahl "schlecht geparkt". */
    float bad_parking_share_percent; /**< Anteil "schlecht geparkt" über die Gesamtlaufzeit in %. */

    /* 5) ADD-ON Betrachtung der einzelnen Gates & Fahrzeugtypen */

} StatsGesamte;

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
*/
#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_TYPES_H