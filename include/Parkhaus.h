#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H

    #include "types.h"

    /**
     * @brief Initialize a Parkhaus object from given Settings.
     *        This sets all fields, connects the queue pointer, and prepares the parked-vehicle list.
     * @param p_parkhaus Pointer to the Parkhaus to initialize.
     * @param p_settings Pointer to the Settings used as configuration source.
     * @param p_queue Pointer to the Queue that belongs to this Parkhaus (may be NULL if not used).
     * @return 0 on success, non-zero on invalid parameters.
     */
    int parkhaus_init(Parkhaus *p_parkhaus,
                      const Settings *p_settings,
                      Queue *p_queue);

    /**
     * @brief Tick function for Parkhaus.
     * @param p_self Pointer to the SimulationObject
     * @param current_tick Current simulation tick.
     */
    void parkhaus_tick(SimulationObject *p_self, uint32_t current_tick);

    /**
     * @brief Try to park a vehicle in this Parkhaus.
     *        The vehicle node is added to the list of parked vehicles.
     * @param p_parkhaus Pointer to the Parkhaus.
     * @param p_vehicle Pointer to the GenericVehicle to park.
     *                  Ownership of the vehicle is transferred from the queue to the Parkhaus.
     * @return 0 on success, non-zero if no space is available or parameters are invalid.
     */
    int parkhaus_park_vehicle(Parkhaus *p_parkhaus, GenericVehicle *p_vehicle);

    /**
     * @brief Remove a vehicle from the Parkhaus (e.g., when parking time is over).
     *        The vehicle is removed from the internal list and free the underlying memory.
     * @param p_vehicle Pointer to the GenericVehicle to remove.
     * @return 0 on success, non-zero if the vehicle was not found.
     */
    int parkhaus_remove_vehicle(Parkhaus *p_parkhaus, GenericVehicle *p_vehicle);

    /**
     * @brief Check if the Parkhaus has at least one free parking slot.
     * @param p_parkhaus Pointer to the Parkhaus.
     * @return 1 if at least one slot is free, 0 otherwise.
     */
    int parkhaus_has_free_slot(const Parkhaus *p_parkhaus);

    /**
     * @brief Compute the current utilization of the Parkhaus in percent.
     * @param p_parkhaus Pointer to the Parkhaus.
     * @return Utilization as float between 0.0 and 100.0.
     */
    float parkhaus_get_utilization(const Parkhaus *p_parkhaus);

    /**
     * @brief Free all dynamic memory that belongs to the Parkhaus.
     *        This includes:
     *        - all parked GenericVehicle nodes,
     *        - any other dynamic resources owned by Parkhaus.
     *        - call the queues free() function.
     * Parkhaus is the owner of its Queue so it will call it's free function!
     * @param p_parkhaus Pointer to the Parkhaus.
     */
    void parkhaus_free(Parkhaus *p_parkhaus);

#endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H
