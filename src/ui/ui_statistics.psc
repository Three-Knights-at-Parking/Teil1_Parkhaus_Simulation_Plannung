INCLUDE FILE ui_statistics.h

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


FUNCTION build_occupancy_bar(taken_percent)

    filled ← (taken_percent / 100.0) * UI_STATS_BAR_WIDTH
    filled_int ← clamp_int(ROUND(filled), 0, UI_STATS_BAR_WIDTH)
    empty_int ← UI_STATS_BAR_WIDTH - filled_int

    bar ← "[" + repeat_char("#", filled_int) + repeat_char("-", empty_int) + "]"
    return bar

END FUNCTION


FUNCTION derive_status_text(stats_tick)

    IF stats_tick.capacity_free = 0 THEN
        return "FULL"
    END IF

    return "OK"

END FUNCTION


FUNCTION format_float_1(value)

    // Pseudocode: round to 1 decimal and return as string
    // Example: 87.04 -> "87.0"
    rounded ← ROUND(value * 10) / 10
    return TO_STRING(rounded)

END FUNCTION


FUNCTION format_float_2(value)

    //Used in VERBOSE mode - rounds floating numbers to two decimals.
    rounded ← ROUND(value * 100) / 100
    return TO_STRING(rounded)

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
    OUTPUT "All metrics per tick are printed in technical format."
    OUTPUT "Each block represents one simulation tick snapshot."
    OUTPUT "======================================================================"
    OUTPUT ""

END FUNCTION


FUNCTION ui_statistics_print_header(settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = VERBOSE THEN
        CALL ui_statistics_print_header_verbose()
    ELSE
        CALL ui_statistics_print_header_normal()
    END IF

END FUNCTION


/* ========================================================================= */
/* Tick output                                                               */
/* ========================================================================= */

FUNCTION ui_statistics_print_tick_normal(stats_tick)

    status_text ← CALL derive_status_text(stats_tick)

    occ_bar ← CALL build_occupancy_bar(stats_tick.capacity_taken_percent)
    occ_pct ← CALL format_float_1(stats_tick.capacity_taken_percent) + "%"

    OUTPUT "+--------------------------------------------------------------------+"
    OUTPUT "| Tick: ", stats_tick.tick, "   Status: ", status_text
    OUTPUT "| OCC : ", stats_tick.capacity_taken, "/", stats_tick.capacity_total,
           "   ", occ_bar, "  ", occ_pct
    OUTPUT "| Queue: ", stats_tick.queue_length_end,
           " | Arrivals: ", stats_tick.arrivals_generated,
           " | In: ", stats_tick.entered,
           " | Out: ", stats_tick.departed,
           " | Rej: ", stats_tick.queue_rejections
    OUTPUT "| Avg Queue Wait (entered): ", CALL format_float_2(stats_tick.avg_queue_wait_ticks_entered), " ticks"
    OUTPUT "+--------------------------------------------------------------------+"

END FUNCTION


FUNCTION ui_statistics_print_tick_verbose(stats_tick)

    status_text ← CALL derive_status_text(stats_tick)

    OUTPUT "----------------------------------------------------------------------"
    OUTPUT "Tick = ", stats_tick.tick, " | Status = ", status_text

    OUTPUT "Capacity: total=", stats_tick.capacity_total,
           " | taken=", stats_tick.capacity_taken,
           " | free=", stats_tick.capacity_free,
           " | util%=", CALL format_float_2(stats_tick.capacity_taken_percent)

    OUTPUT "Capacity Peaks: peakUtilSoFar%=", CALL format_float_2(stats_tick.peak_capacity_taken_percent_so_far),
           " | peakUtilValueSoFar%=", CALL format_float_2(stats_tick.peak_capacity_value_percent_so_far),
           " @tick ", stats_tick.peak_capacity_tick,
           " | firstFullTick=", stats_tick.first_full_tick,
           " | fullTicksSoFar=", stats_tick.full_ticks_so_far

    OUTPUT "Flow (tick): arrivals=", stats_tick.arrivals_generated,
           " | enqueued=", stats_tick.enqueued,
           " | entered=", stats_tick.entered,
           " | departed=", stats_tick.departed,
           " | netOccChange=", stats_tick.net_occupancy_change

    OUTPUT "Queue: lenEnd=", stats_tick.queue_length_end,
           " | maxLenSoFar=", stats_tick.queue_length_max_so_far,
           " | rejections=", stats_tick.queue_rejections,
           " | avgWaitEntered=", CALL format_float_2(stats_tick.avg_queue_wait_ticks_entered),
           " | maxWaitSoFar=", stats_tick.max_queue_wait_ticks_so_far,
           " | activeRatioSoFar%=", CALL format_float_2(stats_tick.queue_active_ratio_percent_so_far)

    OUTPUT "Parking: avgParkingDurDeparted=", CALL format_float_2(stats_tick.avg_parking_duration_ticks_departed), " ticks"

    OUTPUT "Blocker: fullRatioSoFar%=", CALL format_float_2(stats_tick.blocker_full_ratio_percent_so_far)

    OUTPUT "Quality: badParkingCases=", stats_tick.bad_parking_cases,
           " | badParkingTick%=", CALL format_float_2(stats_tick.bad_parking_tick_percent)

    OUTPUT "Running Averages: avgUtilSoFar%=", CALL format_float_2(stats_tick.avg_capacity_percent_so_far),
           " | avgQueueLenSoFar=", CALL format_float_2(stats_tick.avg_queue_length_so_far),
           " | avgEntered/tick=", stats_tick.avg_entered_per_tick_so_far,
           " | avgDeparted/tick=", stats_tick.avg_departed_per_tick_so_far

    OUTPUT "Queue Peak So Far: value=", stats_tick.peak_queue_value_so_far,
           " @tick ", stats_tick.peak_queue_tick

END FUNCTION


FUNCTION ui_statistics_print_tick(stats_tick, settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = VERBOSE THEN
        CALL ui_statistics_print_tick_verbose(stats_tick)
        return
    END IF

    /* NORMAL and DEBUG share the same readable box output. */
    CALL ui_statistics_print_tick_normal(stats_tick)

    IF settings.output_mode = DEBUG THEN
        OUTPUT "DEBUG: blocker_full_active=", stats_tick.blocker_full_active,
               " | full_ticks_so_far=", stats_tick.full_ticks_so_far,
               " | peak_util_so_far%=", CALL format_float_2(stats_tick.peak_capacity_taken_percent_so_far)
    END IF

END FUNCTION


/* ========================================================================= */
/* Final / End statistics                                                    */
/* ========================================================================= */

FUNCTION ui_statistics_print_final(stats_total, settings)

    IF settings.output_mode = NONE THEN
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

    OUTPUT "Queue avg length       : ", stats_total.queue_length_avg
    OUTPUT "Queue peak             : ", stats_total.queue_length_peak,
           " at tick ", stats_total.queue_length_peak_tick
    OUTPUT "Queue rejections total : ", stats_total.queue_rejections_total
    OUTPUT "Avg queue wait (ticks) : ", stats_total.queue_wait_avg_ticks
    OUTPUT "Max queue wait (ticks) : ", stats_total.queue_wait_max_ticks

    OUTPUT "Blocker FULL ratio (%) : ", CALL format_float_2(stats_total.blocker_full_ratio_percent)

    OUTPUT "Bad parking total      : ", stats_total.bad_parking_cases_total
    OUTPUT "Bad parking share (%)  : ", CALL format_float_2(stats_total.bad_parking_share_percent)

    OUTPUT "======================================================================"
    OUTPUT ""

END FUNCTION