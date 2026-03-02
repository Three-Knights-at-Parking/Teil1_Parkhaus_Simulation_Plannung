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