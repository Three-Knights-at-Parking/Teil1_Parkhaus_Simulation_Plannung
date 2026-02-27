#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SIMULATIONOBJECT_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SIMULATIONOBJECT_H

#include "types.h"

    /**
     * Tick this SimulationObject once.
     * This will call the tick-function stored in p_obj->tick if it is not NULL.
     * @param p_obj Pointer to the SimulationObject to tick.
     * @param current_tick Current simulation time (tick counter).
     */
    void tick(SimulationObject *p_obj, int current_tick);

    /**
     * Setter function to set the tick-function for this SimulationObject.
     * Generally you should only set the tick function at init of the object and not change it.
     * @param p_obj Pointer to the SimulationObject whose tick function should be set.
     * @param tick_function Pointer to the SimulationTickFunction for this object.
     */
    void simulation_object_set_tick(SimulationObject *p_obj,
                                    SimulationTickFunction tick_function);

    /**
     * If you ever need to get the SimulationFunction for this Object.
     * @param p_obj Pointer to the SimulationObject.
     * @return The SimulationTickFunction for this Object (may be NULL).
     */
    SimulationTickFunction simulation_object_get_tick(const SimulationObject *p_obj);

#endif
