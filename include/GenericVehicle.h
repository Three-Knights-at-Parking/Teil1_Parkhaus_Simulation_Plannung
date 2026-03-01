#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_GENERICVEHICLE_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_GENERICVEHICLE_H

#include "types.h"

/**
 * @brief Initialize a GenericVehicle base object.
 *        This sets the SimulationObject part and the common vehicle fields. The ownership of it's members
 *        stay with the caller object.
 * @param p_vehicle Pointer to the GenericVehicle to initialize.
 * @param type Object type (e.g., CAR, later EV, MOTORCYCLE).
 * @param tick_function Tick function for this vehicle type.
 * @param created_at Tick when this vehicle was created.
 * @param parking_time Maximum time (in ticks) this vehicle wants to stay in the system.
 */
void generic_vehicle_init(GenericVehicle *p_vehicle,
                          enum ObjectType type,
                          SimulationTickFunction tick_function,
                          uint32_t created_at,
                          uint32_t parking_time);

#endif
