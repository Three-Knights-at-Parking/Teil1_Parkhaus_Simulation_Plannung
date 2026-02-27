#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SIMULATION_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SIMULATION_H

#include "types.h"

    /**
     * Initialize a Simulation with Settings.
     * @param p_sim Pointer to the Simulation object to initialize.
     * @param p_settings Pointer to the Settings used to configure the Simulation.
     * @return 0 on success, non-zero on error.
     */
    int simulation_init(Simulation *p_sim, const Settings *p_settings);

    /**
     * Set new settings for this simulation.
     * @param p_sim Pointer to the Simulation object to modify.
     * @param p_settings Pointer to the new Settings.
     * @return 0 on success, non-zero on error.
     */
    int simulation_set_settings(Simulation *p_sim, const Settings *p_settings);

    /**
     * Progress the Simulation by one tick.
     * @param p_sim Pointer to the Simulation object to tick.
     * @return Short Status / Success of the tick (0 on success, non-zero on error or stop condition).
     */
    int simulation_tick(Simulation *p_sim);

    /**
     * Start a Simulation with given settings.
     * If p_settings is NULL, the current settings inside p_sim should be used.
     * @param p_sim Pointer to the Simulation object to run.
     * @param p_settings Pointer to the Settings object or NULL to keep current settings.
     * @return 0 on success, non-zero on error.
     */
    int simulation_start(Simulation *p_sim, const Settings *p_settings);

    /**
     * End the Simulation.
     * @param p_sim Pointer to the Simulation object to stop.
     */
    void simulation_end(Simulation *p_sim);

    #endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SIMULATION_H
