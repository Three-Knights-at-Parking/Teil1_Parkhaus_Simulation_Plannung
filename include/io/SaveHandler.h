#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H

#include "../types.h"

    /**
     * @brief Append statistics for a single simulation tick to a file and forward to UI.
     *
     * This function takes a StatsTick (typically the one just created
     * at the end of the current tick and linked into Simulation.stats_head/tail)
     * and appends one line to a statistics file. The amount of detail depends on
     * the OutputMode in the Settings referenced by p_sim:
     *
     *  - NONE:    no output generated (the function may return immediately).
     *  - NORMAL:  only essential statistics per tick.
     *  - VERBOSE: all available statistics per tick.
     *  - DEBUG:   like VERBOSE plus debug information if available.
     *
     * @note This function also forwards the statistics to the UI so it can be printed.
     * @param p_sim       Pointer to the Simulation containing Settings and Parkhaus.
     * @param p_tickstats Pointer to the StatsTick snapshot to write.
     * @param dest_path   Relative path to the output file; must not be NULL.
     *
     * @return 0 on success, non-zero on error (e.g. file I/O failure or invalid pointers).
     */
    int savehandler_save_tick(const Simulation *p_sim,
                              const StatsTick *p_tickstats,
                              const char *dest_path);

    /**
     * @brief Save final aggregated statistics of a simulation run to a file.
     *
     * This function writes the aggregated statistics (StatsSummary) that were
     * computed from all StatsTick entries at the end of the simulation. It can be
     * used in addition to per-tick logging. The level of detail again depends on
     * the OutputMode in the Settings referenced by p_sim.
     *
     * @param p_sim     Pointer to the Simulation containing Settings and Parkhaus.
     * @param p_summary Pointer to the aggregated statistics (StatsSummary).
     * @param dest_path Relative path to the output file; must not be NULL.
     *
     * @note This function also forwards the statistics to the UI so it can be printed.
     * @return 0 on success, non-zero on error.
     */
    int savehandler_save_summary(const Simulation *p_sim,
                                 const StatsSummary *p_summary,
                                 const char *dest_path);

    /**
     *
     * @brief Load previously saved statistics from a file and print or display them.
     *
     * TODO implementation will change as soon as UI implementation of print has been submitted.
     *
     * Load data from previously saved files and give them to the UI for printing. Will
     * default to the root location of the EXE if src_path is NULL or invalid.
     *
     * @param src_path Relative path to the statistics file to load; must not be NULL.
     *
     * @return 0 on success, non-zero on error.
     */
    int savehandler_load_and_print(const char *src_path);

#endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H
