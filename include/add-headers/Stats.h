//
// Created by ibach on 01.03.2026.
// @author: Ibach
//

#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H

#include "../types.h"

/**
 * @file Stats.h
 * @brief API fuer Tick-Statistiken und Gesamtaggregation.
 *
 * Erwarteter Ablauf pro Tick:
 * 1) stats_tick_begin(...)
 * 2) waehrend des Ticks mit stats_tick_add_* / stats_tick_set_* befuellen
 * 3) stats_tick_finalize(...)
 * 4) stats_tick_commit(...)
 *
 * Jeder commitete Tick wird in einer doppelt verketteten Liste gespeichert
 * (p_tick_head ... p_tick_tail) und gleichzeitig in `StatsGesamte` aggregiert.
 */

/**
 * Initialisiert den Statistikcontainer inklusive Summenfeldern.
 *
 * @param p_stats         Zielcontainer
 * @param capacity_total  Gesamtkapazitaet des Parkhauses
 */
int stats_init(Stats *p_stats, uint16_t capacity_total);

/**
 * Gibt alle in der Tick-Liste gespeicherten Elemente frei.
 */
int stats_free(Stats *p_stats);

/**
 * Startet einen neuen Tick-Builder (p_current_tick).
 */
int stats_tick_begin(Stats *p_stats, uint32_t tick);

/**
 * Berechnet Tick-interne Kennzahlen (z.B. Durchschnitte).
 */
int stats_tick_finalize(Stats *p_stats);

/**
 * Haengt den finalisierten Tick an die Liste an und aktualisiert Gesamtwerte.
 */
int stats_tick_commit(Stats *p_stats);

/** Setzt Tick-Ende-Kapazitaetswerte. */
int stats_tick_set_capacity(Stats *p_stats, uint16_t taken, uint16_t free);

/** Erhoeht Ankuenfte fuer den laufenden Tick. */
int stats_tick_add_arrivals_generated(Stats *p_stats, uint16_t amount);

/** Erhoeht Queue-Aufnahmen fuer den laufenden Tick. */
int stats_tick_add_enqueued(Stats *p_stats, uint16_t amount);

/** Erhoeht Einfahrten ins Parkhaus fuer den laufenden Tick. */
int stats_tick_add_entered(Stats *p_stats, uint16_t amount);

/** Erhoeht Ausfahrten aus dem Parkhaus fuer den laufenden Tick. */
int stats_tick_add_departed(Stats *p_stats, uint16_t amount);

/** Erhoeht Anzahl Queue-Rejections fuer den laufenden Tick. */
int stats_tick_add_queue_rejections(Stats *p_stats, uint16_t amount);

/** Setzt Queue-Laenge am Tick-Ende. */
int stats_tick_set_queue_length_end(Stats *p_stats, uint8_t queue_length_end);

/**
 * Addiert Wartezeit eines Fahrzeugs, das in diesem Tick eingetreten ist.
 * Wird als Rohsumme + Zaehler gespeichert und in Gesamtwerten gemittelt.
 */
int stats_tick_add_entered_queue_wait(Stats *p_stats, uint32_t wait_ticks);

/**
 * Addiert Parkdauer eines Fahrzeugs, das in diesem Tick ausgefahren ist.
 * Wird als Rohsumme + Zaehler gespeichert und in Gesamtwerten gemittelt.
 */
int stats_tick_add_departed_parking_duration(Stats *p_stats, uint32_t duration_ticks);

/** Setzt Anzahl Bad-Parking-Faelle fuer diesen Tick. */
int stats_tick_set_bad_parking_cases(Stats *p_stats, uint16_t bad_cases);

/** Erhoeht Anzahl Bad-Parking-Faelle fuer diesen Tick. */
int stats_tick_add_bad_parking_cases(Stats *p_stats, uint16_t amount);

/** Setzt, ob der Blocker "voll" in diesem Tick aktiv war (0/1). */
int stats_tick_set_blocker_full_active(Stats *p_stats, uint8_t active);

/** Liefert den zuletzt commiteten Tick (Tail) oder NULL. */
const StatsTick *stats_get_latest_tick(const Stats *p_stats);

/** Liefert die aggregierte Gesamtstatistik oder NULL. */
const StatsGesamte *stats_get_summary(const Stats *p_stats);

#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_STATS_H