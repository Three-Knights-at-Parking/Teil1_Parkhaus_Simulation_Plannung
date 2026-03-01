#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H

#include "types.h"

/**
 * @brief Fuehrt einen Simulations-Tick fuer das Parkhaus aus.
 *
 * Entspricht der Hauptfunktion aus `src/Parkhaus.psc`.
 */
int parkhouse_tick(uint32_t current_tick, Settings *p_settings, Parkhaus *p_parkhouse, Queue *p_gate_queues,
                   void *p_stats);

/**
 * @brief Verarbeitet ausfahrende Fahrzeuge am Tick-Anfang.
 */
int parkhouse_tick_empty_general(uint32_t current_tick, Parkhaus *p_parkhouse, Settings *p_settings,
                                 GenericVehicle **pp_car_list_head);

/**
 * @brief Verarbeitet Einfahrten fuer ein einzelnes Gate in einem Tick.
 */
int parkhouse_tick_fill_general(uint32_t current_tick, Parkhaus *p_parkhouse, Settings *p_settings,
                                GenericVehicle **pp_car_list_head, Queue *p_gate_queue);

/**
 * @brief Verteilt Einfahrten subtick-basiert ueber mehrere Gates.
 */
int parkhouse_fill_subtick(uint32_t current_tick, Parkhaus *p_parkhouse, Settings *p_settings, Queue *p_gate_queues);

/**
 * @brief Ein einzelner Subtick-Schritt fuer genau ein Gate.
 */
int parkhouse_fill_subtick_routine(uint32_t current_tick, Parkhaus *p_parkhouse, Settings *p_settings,
                                   Queue *p_gate_queue, int last_cycle);

/**
 * @brief Uebernimmt ein Fahrzeug aus der Queue und berechnet den benoetigten Platz.
 */
uint16_t fill_from_queue(Queue *p_gate_queue, uint16_t parkhouse_open_space);

/**
 * @brief Schreibt verbleibenden Demand in die Queue und zaehlt ggf. Rejections hoch.
 */
int open_demand(Parkhaus *p_parkhouse, Queue *p_gate_queue, uint16_t queue_max_len, uint16_t demand_remaining);

/**
 * @brief Entfernt ein Fahrzeug aus dem Parkhaus und gibt den Platz frei.
 */
int car_leaving(Parkhaus *p_parkhouse, GenericVehicle **pp_car_list_head, GenericVehicle *p_car);

/**
 * @brief Erstellt eine Queue-Struktur fuer mehrere Gates.
 */
Queue *parkhaus_create_gate_queues(uint32_t number_of_gates);

/**
 * @brief Fuegt ein Fahrzeug an einem Gate in die Queue ein.
 */
int parkhaus_enqueue_at_gate(Queue *p_gate_queues, uint32_t gate_index, GenericVehicle *p_vehicle);

/**
 * @brief Setzt den Demand-Wert eines Gates.
 */
int parkhaus_set_gate_demand(Queue *p_gate_queues, uint32_t gate_index, uint16_t demand_value);

/**
 * @brief Erzeugt ein zufaelliges Fahrzeug und fuegt es in eine Gate-Queue ein.
 */
int queue_add_random_vehicle(Queue *p_gate_queue);

#endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_PARKHAUS_H
