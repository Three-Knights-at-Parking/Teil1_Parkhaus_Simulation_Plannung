//
// Created by ibach on 01.03.2026.
//

#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_GATE_ROUTING_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_GATE_ROUTING_H

/*
 * Gate-Routing-Modul
 * - verteilt den globalen Tick-Demand (100%) auf vorhandene Gate-Queues
 * - prueft bei jedem Schritt, ob Queue/Element vorhanden ist
 * - schreibt nur Demand pro Gate in die Queues
 */

FUNCTION GateRouting_DistributeTotalDemand(total_demand, gate_queues, settings, rng, current_tick)

#endif //TEIL1_PARKHAUS_SIMULATION_PLANNUNG_GATE_ROUTING_H