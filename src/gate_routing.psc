//////////////////////////////////////////////////////////
//// Module: gate_routing
//// Dependencies: queue (Queue.h), rng, settings
//////////////////////////////////////////////////////////

/*
 * Goal:
 * - distribute one tick's total_demand across all gate queues
 * - robust against NULL/invalid parameters
 * - traceable routing with multiple gates
 */