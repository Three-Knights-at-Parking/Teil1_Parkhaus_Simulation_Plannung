INCLUDE FILE ui_statistics.h

INCLUDE FILE ui_statistics.h

/*
 * @file ui_statistics.psc
 * @brief Terminal output for simulation statistics.
 *
 * This module prints:
 * - Header/legend (depending on output mode)
 * - Tick-by-tick statistics (NORMAL / VERBOSE / DEBUG)
 * - Final simulation summary (StatsSummary)
 *
 * Design note:
 * - The UI only formats and prints existing values.
 * - Minimal derived values are computed only where required for readability:
 *   - Utilization in percent (capacity_taken / capacity_total)
 *   - Average queue wait (sum / count)
 */


/* ========================================================================= */
/* Helper functions                                                          */
/* ========================================================================= */

FUNCTION repeat_char(ch, count)
    result ← ""
    i ← 0
    WHILE i < count DO
        result ← result + ch
        i ← i + 1
    END WHILE
    return result
END FUNCTION


FUNCTION clamp_int(value, min, max)
    IF value < min THEN
        return min
    END IF
    IF value > max THEN
        return max
    END IF
    return value
END FUNCTION


FUNCTION format_float_1(value)
    // Rounds to 1 decimal place (readable NORMAL mode).
    rounded ← ROUND(value * 10) / 10
    return TO_STRING(rounded)
END FUNCTION


FUNCTION format_float_2(value)
    // Rounds to 2 decimals (used for VERBOSE mode / summary values).
    rounded ← ROUND(value * 100) / 100
    return TO_STRING(rounded)
END FUNCTION


FUNCTION build_occupancy_bar(taken_percent)
    // Visual bar for utilization. "UI_STATS_BAR_WIDTH" controls the size.
    filled ← (taken_percent / 100.0) * UI_STATS_BAR_WIDTH
    filled_int ← clamp_int(ROUND(filled), 0, UI_STATS_BAR_WIDTH)
    empty_int ← UI_STATS_BAR_WIDTH - filled_int

    bar ← "[" + repeat_char("#", filled_int) + repeat_char("-", empty_int) + "]"
    return bar
END FUNCTION


FUNCTION derive_status_text(stats_tick)
    // FULL means no free capacity at the end of the tick.
    IF stats_tick.capacity_free = 0 THEN
        return "FULL"
    END IF
    return "OK"
END FUNCTION


FUNCTION calc_util_percent(stats_tick)
    // Minimal derived value: utilization in percent.
    IF stats_tick.capacity_total = 0 THEN
        return 0
    END IF
    return (stats_tick.capacity_taken * 100.0) / stats_tick.capacity_total
END FUNCTION


FUNCTION calc_avg_queue_wait_entered(stats_tick)
    // Minimal derived value: avg waiting time of vehicles that entered in this tick.
    IF stats_tick.queue_wait_entered_count = 0 THEN
        return 0
    END IF
    return stats_tick.queue_wait_entered_sum_ticks / stats_tick.queue_wait_entered_count
END FUNCTION


/* ========================================================================= */
/* Header / Legend                                                           */
/* ========================================================================= */

FUNCTION ui_statistics_print_header_normal()

    OUTPUT ""
    OUTPUT "======================================================================"
    OUTPUT "                PARKHAUS – TICK STATISTICS (NORMAL)"
    OUTPUT "----------------------------------------------------------------------"
    OUTPUT "Legend:"
    OUTPUT "  Status : OK = capacity available | FULL = no free capacity"
    OUTPUT "  OCC    : occupied spots / total spots"
    OUTPUT "  Util % : utilization of parking capacity"
    OUTPUT "  Queue  : queue length at tick end"
    OUTPUT "  Arr/In/Out/Rej: arrivals / entered / departed / rejected"
    OUTPUT "======================================================================"
    OUTPUT ""

END FUNCTION


FUNCTION ui_statistics_print_header_verbose()

    OUTPUT ""
    OUTPUT "======================================================================"
    OUTPUT "           PARKHAUS – TICK STATISTICS (VERBOSE)"
    OUTPUT "----------------------------------------------------------------------"
    OUTPUT "All available raw metrics per tick are printed."
    OUTPUT "======================================================================"
    OUTPUT ""

END FUNCTION


FUNCTION ui_statistics_print_header(settings)

    // Output can be fully disabled by selecting NONE.
    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = VERBOSE THEN
        CALL ui_statistics_print_header_verbose()
    ELSE
        // NORMAL and DEBUG use the readable header.
        CALL ui_statistics_print_header_normal()
    END IF

END FUNCTION


/* ========================================================================= */
/* Tick output                                                               */
/* ========================================================================= */

FUNCTION ui_statistics_print_tick_normal(stats_tick)

    status_text ← CALL derive_status_text(stats_tick)

    util_percent ← CALL calc_util_percent(stats_tick)
    occ_bar ← CALL build_occupancy_bar(util_percent)
    occ_pct ← CALL format_float_1(util_percent) + "%"

    avg_wait ← CALL calc_avg_queue_wait_entered(stats_tick)

    OUTPUT "+--------------------------------------------------------------------+"
    OUTPUT "| Tick: ", stats_tick.tick, "   Status: ", status_text
    OUTPUT "| OCC : ", stats_tick.capacity_taken, "/", stats_tick.capacity_total,
           "   ", occ_bar, "  ", occ_pct
    OUTPUT "| Queue: ", stats_tick.queue_length_end,
           " | Arrivals: ", stats_tick.arrivals_generated,
           " | In: ", stats_tick.entered,
           " | Out: ", stats_tick.departed,
           " | Rej: ", stats_tick.queue_rejections
    OUTPUT "| Avg Queue Wait (entered): ", CALL format_float_2(avg_wait), " ticks"
    OUTPUT "+--------------------------------------------------------------------+"

END FUNCTION


FUNCTION ui_statistics_print_tick_verbose(stats_tick)

    // Verbose prints only the metrics that actually exist in StatsTick.
    status_text ← CALL derive_status_text(stats_tick)
    util_percent ← CALL calc_util_percent(stats_tick)
    avg_wait ← CALL calc_avg_queue_wait_entered(stats_tick)

    OUTPUT "----------------------------------------------------------------------"
    OUTPUT "Tick = ", stats_tick.tick, " | Status = ", status_text

    OUTPUT "Capacity: total=", stats_tick.capacity_total,
           " | taken=", stats_tick.capacity_taken,
           " | free=", stats_tick.capacity_free,
           " | util%=", CALL format_float_2(util_percent)

    OUTPUT "Flow (tick): arrivals=", stats_tick.arrivals_generated,
           " | enqueued=", stats_tick.enqueued,
           " | entered=", stats_tick.entered,
           " | departed=", stats_tick.departed

    OUTPUT "Queue: lenEnd=", stats_tick.queue_length_end,
           " | rejections=", stats_tick.queue_rejections,
           " | waitSumEnteredTicks=", stats_tick.queue_wait_entered_sum_ticks,
           " | waitCountEntered=", stats_tick.queue_wait_entered_count,
           " | avgWaitEntered=", CALL format_float_2(avg_wait)

    OUTPUT "Parking: durSumDepartedTicks=", stats_tick.parking_duration_departed_sum_ticks,
           " | durCountDeparted=", stats_tick.parking_duration_departed_count

    OUTPUT "Quality/Blocker: blocker_full_active=", stats_tick.blocker_full_active,
           " | bad_parking_cases=", stats_tick.bad_parking_cases

END FUNCTION


FUNCTION ui_statistics_print_tick(stats_tick, settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = VERBOSE THEN
        CALL ui_statistics_print_tick_verbose(stats_tick)
        return
    END IF

    // NORMAL and DEBUG share the same readable box output.
    CALL ui_statistics_print_tick_normal(stats_tick)

    IF settings.output_mode = DEBUG THEN
        OUTPUT "DEBUG: blocker_full_active=", stats_tick.blocker_full_active
    END IF

END FUNCTION


/* ========================================================================= */
/* Final / End statistics                                                    */
/* ========================================================================= */

FUNCTION ui_statistics_print_final(stats_total, settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF stats_total = NULL THEN
        OUTPUT "No summary statistics available."
        return
    END IF

    OUTPUT ""
    OUTPUT "======================================================================"
    OUTPUT "                       SIMULATION SUMMARY"
    OUTPUT "======================================================================"

    OUTPUT "Total ticks            : ", stats_total.total_ticks
    OUTPUT "Avg utilization (%)    : ", CALL format_float_2(stats_total.capacity_taken_percent_avg)
    OUTPUT "Peak utilization (%)   : ", CALL format_float_2(stats_total.capacity_taken_percent_peak),
           " at tick ", stats_total.capacity_taken_peak_tick
    OUTPUT "First FULL tick        : ", stats_total.first_full_tick
    OUTPUT "FULL ticks             : ", stats_total.full_ticks

    OUTPUT "Arrivals total         : ", stats_total.arrivals_total
    OUTPUT "Entered total          : ", stats_total.entered_total
    OUTPUT "Departed total         : ", stats_total.departed_total

    OUTPUT "Queue avg length       : ", CALL format_float_2(stats_total.queue_length_avg)
    OUTPUT "Queue peak             : ", stats_total.queue_length_peak,
           " at tick ", stats_total.queue_length_peak_tick
    OUTPUT "Queue rejections total : ", stats_total.queue_rejections_total
    OUTPUT "Avg queue wait (ticks) : ", stats_total.queue_wait_avg_ticks
    OUTPUT "Max queue wait (ticks) : ", stats_total.queue_wait_max_ticks

    OUTPUT "Avg parking duration   : ", stats_total.parking_duration_avg_ticks, " ticks"

    OUTPUT "Blocker FULL ratio (%) : ", CALL format_float_2(stats_total.blocker_full_ratio_percent)

    OUTPUT "Bad parking total      : ", stats_total.bad_parking_cases_total
    OUTPUT "Bad parking share (%)  : ", CALL format_float_2(stats_total.bad_parking_share_percent)

    OUTPUT "======================================================================"
    OUTPUT ""

END FUNCTION