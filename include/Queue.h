#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_QUEUE_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_QUEUE_H

#include "types.h"
/**
 * Represents a Queue owned by a Parkhaus. Handles (and owns!) all waiting cars and "inherits"
 * SimulationObject for easy use of the tick() function. Parkhaus calls this object's free
 * function to free the Queue and the underlying cars.
 */

    /**
     * @brief Initialize the Queue.
     *        Sets base fields, max_size, and clears the internal vehicle list.
     * @param p_queue Pointer to the Queue to initialize.
     * @param max_size Maximum number of vehicles in the queue. If 0, queue is effectively disabled.
     * @return 0 on success, non-zero on error (e.g. invalid max_size).
     */
    int queue_init(Queue *p_queue, uint16_t max_size);

    /**
     * @brief Check if the queue is full.
     * @param p_queue Pointer to the Queue.
     * @return 1 if full, 0 otherwise.
     */
    int queue_is_full(const Queue *p_queue);

    /**
     * @brief Check if the queue is empty.
     * @param p_queue Pointer to the Queue.
     * @return 1 if empty, 0 otherwise.
     */
    int queue_is_empty(const Queue *p_queue);

    /**
     * @brief Enqueue a vehicle at the end of the queue.
     *        p_vehicle must be dynamically allocated. Queue will take the ownership of this vehicle.
     * @param p_queue Pointer to the Queue.
     * @param p_vehicle Pointer to the Vehicle to enqueue.
     * @return 0 on success, non-zero if the queue is full or inputs are invalid.
     */
    int queue_enqueue(Queue *p_queue, GenericVehicle *p_vehicle);

    /**
     * @brief Dequeue the first vehicle in the queue (FIFO). Ownership of the vehicle is given to the Parent!
     * @param p_queue Pointer to the Queue.
     * @return Pointer to the dequeued Vehicle, or NULL if the queue is empty.
     *
     */
    GenericVehicle *queue_dequeue(Queue *p_queue);

    /**
     * @brief Remove a specific vehicle from the queue (z.B. Timeout / max tick reached).
     * This will free the memory related to this vehicle.
     * @param p_queue Pointer to the Queue.
     * @param p_target Pointer to the Vehicle that should be removed.
     * @return 0 on success, non-zero if the vehicle was not found in the queue.
     */
    int queue_remove(Queue *p_queue, GenericVehicle *p_target);

    /**
     * @brief Tick function for Queue for the underlying
     * @param p_self Pointer to the SimulationObject
     * @param current_tick Current simulation tick.
     */
    void queue_tick(SimulationObject *p_self, uint32_t current_tick);

#endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_QUEUE_H
