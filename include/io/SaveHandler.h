#ifndef TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H
#define TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H
#include "../types.h"

/**
 * FIXME Waiting for Statistics Object implementation. If Statistics is a child of Simulation keep this implementation.
 *
 */

    /**
     * @brief Append statistics for a single simulation tick to a file.
     *        The amount of detail depends on the OutputMode in the Settings:
     *        - NONE:    no output generated.
     *        - NORMAL:  only essential statistics per tick.
     *        - VERBOSE: all available statistics per tick.
     *        - DEBUG:   NORMAL plus debug information.
     * @param p_sim Pointer to the Simulation to read statistics from.
     * @param current_tick Current simulation tick.
     * @param dest_path Relative path to the output file; must not be NULL.
     * @return 0 on success, non-zero on error (e.g. file I/O failure).
     */
    int savehandler_save_tick(const Simulation *p_sim,
                              uint32_t current_tick,
                              const char *dest_path);

    /**
     * @brief Save final aggregated statistics of a simulation run to a file.
     *        Can be called at the end of the simulation in addition to per-tick logging.
     *        The level of detail again depends on OutputMode.
     * @param p_sim Pointer to the Simulation whose statistics should be written.
     * @param dest_path Relative path to the output file; must not be NULL.
     * @return 0 on success, non-zero on error.
     */
    int savehandler_save_summary(const Simulation *p_sim,
                                 const char *dest_path);

    /**
     * @brief Load previously saved statistics from a file and print/show them to the console.
     *        This allows the user to inspect results of earlier simulation runs.
     * @param src_path Relative path to the statistics file to load; must not be NULL.
     * @return 0 on success, non-zero on error (e.g. file not found, parse error).
     */
    int savehandler_load_and_print(const char *src_path);

#endif // TEIL1_PARKHAUS_SIMULATION_PLANNUNG_SAVEHANDLER_H
