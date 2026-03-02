FUNCTION ui_statistics_print_header(settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    OUTPUT ""
    OUTPUT "╔══════════════════════════════════════════════════════════════════════════════════════════════╗"
    OUTPUT "║                                   PARKHAUS – TICK STATISTICS                                ║"
    OUTPUT "╠══════════════════════════════════════════════════════════════════════════════════════════════╣"
    OUTPUT "║ Legend: Status=OK/FULL | Occ=Occupied | Util=Utilization% | Q=QueueLen | Arr=Arrivals        ║"
    OUTPUT "║         In=Entered | Out=Departed | Rej=Queue Rejections                                      ║"
    OUTPUT "╚══════════════════════════════════════════════════════════════════════════════════════════════╝"

    IF settings.output_mode = NORMAL OR settings.output_mode = DEBUG THEN
        OUTPUT "┌───────┬────────┬─────────────┬────────┬────────┬───────┬───────┬──────┬──────┬───────┐"
        OUTPUT "│ Tick  │ Status │ Occ (taken) │ Total  │ Util % │ Queue │  Arr  │  In  │ Out  │  Rej  │"
        OUTPUT "├───────┼────────┼─────────────┼────────┼────────┼───────┼───────┼──────┼──────┼───────┤"
    END IF

END FUNCTION


FUNCTION ui_statistics_print_footer(settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = NORMAL OR settings.output_mode = DEBUG THEN
        OUTPUT "└───────┴────────┴─────────────┴────────┴────────┴───────┴───────┴──────┴──────┴───────┘"
    END IF

END FUNCTION


FUNCTION ui_statistics_print_tick_normal(stats_tick)

    status_text ← "OK"
    IF stats_tick.capacity_free = 0 THEN
        status_text ← "FULL"
    END IF

    OUTPUT "│ ",
           CALL pad_left(stats_tick.tick, 5), " │ ",
           CALL pad_right(status_text, 6), " │ ",
           CALL pad_left(stats_tick.capacity_taken, 11), " │ ",
           CALL pad_left(stats_tick.capacity_total, 6), " │ ",
           CALL pad_left(CALL format_float_1(stats_tick.capacity_taken_percent), 6), " │ ",
           CALL pad_left(stats_tick.queue_length_end, 5), " │ ",
           CALL pad_left(stats_tick.arrivals_generated, 5), " │ ",
           CALL pad_left(stats_tick.entered, 4), " │ ",
           CALL pad_left(stats_tick.departed, 4), " │ ",
           CALL pad_left(stats_tick.queue_rejections, 5), " │"

END FUNCTION


FUNCTION ui_statistics_print_tick_verbose(stats_tick)

    status_text ← "OK"
    IF stats_tick.capacity_free = 0 THEN
        status_text ← "FULL"
    END IF

    OUTPUT "──────────────────────────────────────────────────────────────────────────────────────────────"
    OUTPUT "Tick ", stats_tick.tick, " | Status=", status_text,
           " | Occ=", stats_tick.capacity_taken, "/", stats_tick.capacity_total,
           " (", CALL format_float_1(stats_tick.capacity_taken_percent), "%)",
           " | Free=", stats_tick.capacity_free

    OUTPUT "Peak/Full: peakUtilSoFar=", CALL format_float_1(stats_tick.peak_capacity_taken_percent_so_far), "% ",
           " | firstFullTick=", stats_tick.first_full_tick,
           " | fullTicksSoFar=", stats_tick.full_ticks_so_far

    OUTPUT "Flow: arrivals=", stats_tick.arrivals_generated,
           " | enqueued=", stats_tick.enqueued,
           " | entered=", stats_tick.entered,
           " | departed=", stats_tick.departed,
           " | netOccChange=", stats_tick.net_occupancy_change

    OUTPUT "Queue: lenEnd=", stats_tick.queue_length_end,
           " | maxSoFar=", stats_tick.queue_length_max_so_far,
           " | rejections=", stats_tick.queue_rejections,
           " | avgWaitEntered=", CALL format_float_2(stats_tick.avg_queue_wait_ticks_entered),
           " | maxWaitSoFar=", stats_tick.max_queue_wait_ticks_so_far,
           " | activeRatioSoFar=", CALL format_float_1(stats_tick.queue_active_ratio_percent_so_far), "%"

    OUTPUT "Parking/Block/Quality: avgParkDurDeparted=", CALL format_float_2(stats_tick.avg_parking_duration_ticks_departed),
           " | blockerFullActive=", stats_tick.blocker_full_active,
           " | blockerFullRatioSoFar=", CALL format_float_1(stats_tick.blocker_full_ratio_percent_so_far), "%",
           " | badParkingCases=", stats_tick.bad_parking_cases,
           " | badParkingTick%=", CALL format_float_1(stats_tick.bad_parking_tick_percent), "%"

    OUTPUT "RunningAvgs/Peaks: avgUtilSoFar=", CALL format_float_1(stats_tick.avg_capacity_percent_so_far), "%",
           " | avgQueueSoFar=", CALL format_float_2(stats_tick.avg_queue_length_so_far),
           " | avgIn/tick=", stats_tick.avg_entered_per_tick_so_far,
           " | avgOut/tick=", stats_tick.avg_departed_per_tick_so_far,
           " | peakQueue=", stats_tick.peak_queue_value_so_far, " @T", stats_tick.peak_queue_tick,
           " | peakUtil=", CALL format_float_1(stats_tick.peak_capacity_value_percent_so_far), "% @T", stats_tick.peak_capacity_tick

END FUNCTION


FUNCTION ui_statistics_print_summary(stats_total, settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    OUTPUT ""
    OUTPUT "╔══════════════════════════════════════════════════════════════════════════════╗"
    OUTPUT "║                               SIMULATION SUMMARY                             ║"
    OUTPUT "╠══════════════════════════════════════════════════════════════════════════════╣"

    OUTPUT "║ Total Ticks           : ", stats_total.total_ticks
    OUTPUT "║ Avg Utilization (%)   : ", CALL format_float_1(stats_total.capacity_taken_percent_avg)
    OUTPUT "║ Peak Utilization (%)  : ", CALL format_float_1(stats_total.capacity_taken_percent_peak),
           "  @ Tick ", stats_total.capacity_taken_peak_tick
    OUTPUT "║ First FULL Tick       : ", stats_total.first_full_tick
    OUTPUT "║ FULL Ticks            : ", stats_total.full_ticks
    OUTPUT "║ Queue Peak            : ", stats_total.queue_length_peak,
           "  @ Tick ", stats_total.queue_length_peak_tick
    OUTPUT "║ Total Rejections      : ", stats_total.queue_rejections_total

    OUTPUT "╚══════════════════════════════════════════════════════════════════════════════╝"
    OUTPUT ""

END FUNCTION


FUNCTION ui_statistics_print_tick(stats_tick, settings)

    IF settings.output_mode = NONE THEN
        return
    END IF

    IF settings.output_mode = NORMAL OR settings.output_mode = DEBUG THEN
        CALL ui_statistics_print_tick_normal(stats_tick)

        IF settings.output_mode = DEBUG THEN
            OUTPUT "  DEBUG: blocker_full_active=", stats_tick.blocker_full_active
        END IF

        return
    END IF

    IF settings.output_mode = VERBOSE THEN
        CALL ui_statistics_print_tick_verbose(stats_tick)
        return
    END IF

END FUNCTION


//Smaller helping-functions for data formatting process
FUNCTION repeat_char(ch, count)

    result ← ""
    i ← 0
    WHILE i < count DO
        result ← result + ch
        i ← i + 1
    END WHILE

    return result

END FUNCTION


FUNCTION pad_right(text, width)

    // Convert to string if needed
    s ← TO_STRING(text)

    IF LENGTH(s) >= width THEN
        return SUBSTRING(s, 0, width)
    END IF

    return s + CALL repeat_char(" ", width - LENGTH(s))

END FUNCTION


FUNCTION pad_left(text, width)

    s ← TO_STRING(text)

    IF LENGTH(s) >= width THEN
        return SUBSTRING(s, 0, width)
    END IF

    return CALL repeat_char(" ", width - LENGTH(s)) + s

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