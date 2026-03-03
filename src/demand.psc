//////////////////////////////////////////////////////////
//// Module: demand
//// Dependencies: rng
//////////////////////////////////////////////////////////

FUNCTION Demand_GenerateTotalPerTick(settings, current_tick, rng)

    total_demand <- RNG_GenerateTotalDemand(
                      rng,
                      settings.demand_profile,
                      current_tick
                   )

    RETURN total_demand

END FUNCTION