//
// Created by ibach on 01.03.2026.
// @author: Ibach
//

#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H

#include "../types.h"

/**
 * @file Stats.h
 * @brief API for per-tick statistics and overall aggregation.
 *
 * Expected sequence per tick:
 * 1) stats_tick_begin(...)
 * 2) populate during the tick
 * 3) stats_tick_finalize(...)
 * 4) stats_tick_commit(...)
 *
 * Each committed tick is stored in a doubly linked list
 * (p_tick_head ... p_tick_tail) inside `Simulation.StatList`.
 * Aggregation in `StatsSummary` is only performed on demand at the
 * end of the simulation using this tick history.
 */

/**
 * Initializes the statistics container for tick history.
 *
 * @param p_stats         Target container
 * @param capacity_total  Total parking garage capacity
 */
int StatsTick_init(StatList *p_stats, uint16_t capacity_total, uint32_t current_tick);
StatTick* StatTick_inti(Simulation *p_simulation)

/**
 * Frees all elements stored in the tick list.
 */
int stats_free(StatList *p_stats);

/**
 * Starts a new tick builder (p_current_tick).
 */
int stats_tick_begin(StatList *p_stats, uint32_t tick);

/**
 * Appends the finalized tick to the list.
 */
int stats_tick_commit(StatList *p_stats);

/** Sets end-of-tick capacity values. */
int stats_tick_set_capacity(StatList *p_stats, uint16_t taken, uint16_t free);

/** Increments queue rejections for the current tick. */
int stats_tick_add_queue_rejections(StatList *p_stats, uint16_t amount);

/** Sets whether the "full" blocker was active in this tick (0/1). */
int stats_tick_add_blocker_full_active(StatList *p_stats);

/**
 * Records vehicle-based metrics into the current tick.
 *
 * The function derives values from GenericVehicle timestamps relative
 * to `current_tick`:
 * - queue wait + entered counter if `park_house_entered == current_tick`
 * - parking duration + departed counter if `park_house_left == current_tick`
 *
 * For car objects, bad parking is counted when `spaces_needed > minimum_spaces`.
 */
int stats_tick_add_vehicle(StatList *p_stats, const GenericVehicle *p_vehicle, uint32_t current_tick);


int Stats_RecordTick(StatList *p_stats, uint32_t current_tick);

/** Returns the most recently committed tick (tail) or NULL. */
const StatsTick *stats_get_latest_tick(const StatList *p_stats);

/**
 * Computes the aggregated summary statistics from all stored ticks.
 * p_summary must be provided by the caller.
 */
int stats_build_summary(const StatList *p_stats, StatsSummary *p_summary);

#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H
