//////////////////////////////////////////////////////////
//// Modul: gate_routing
//// Abhaengigkeiten: queue (Queue.h), rng, settings
//////////////////////////////////////////////////////////

/*
 * Ziel:
 * - total_demand eines Ticks auf alle Gate-Queues verteilen
 * - robust gegen NULL/ungueltige Parameter
 * - nachvollziehbares Routing bei mehreren Gates
 */