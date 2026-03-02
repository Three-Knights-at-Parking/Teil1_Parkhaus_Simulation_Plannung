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