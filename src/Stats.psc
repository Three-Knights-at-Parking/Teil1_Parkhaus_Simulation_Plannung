//////////////////////////////////////////////////////////
// Modul: Stats
// Abhaengigkeiten: types, parkhaus, queue
// @author: ibach
//////////////////////////////////////////////////////////
// Beschreibung:
// Dieses Modul verwaltet die komplette Statistik-Pipeline der Simulation.
//
// 1) Tick-Erfassung (Rohwerte)
//    - Ein Tick wird mit `stats_tick_begin` gestartet.
//    - Waehrend des Ticks werden Rohdaten per `stats_tick_add_*`
//      und `stats_tick_set_*` gesammelt.
//
// 2) Tick-Abschluss
//    - `stats_tick_finalize` validiert den aktuellen Tick-Builder.
//    - `stats_tick_commit` haengt den Tick in die Historie an
//      (doppelt verkettete Liste) und aktualisiert die Aggregation.
//
// 3) Gesamtstatistik
//    - `StatsGesamte` speichert Summen, Mittelwerte und Peak-Werte.
//    - Laufende Summen im Container vermeiden teure Re-Iteration
//      ueber alle bereits gespeicherten Ticks.
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// Lifecycle: Container initialisieren/freigeben
//////////////////////////////////////////////////////////

// Brief: Setzt alle Pointer, Summen und Gesamtwerte auf definierte
// Startwerte. Muss vor dem ersten Tick-Aufruf einmalig ausgefuehrt werden.
FUNCTION stats_init(p_stats, capacity_total)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    p_stats.p_tick_head <- NULL
    p_stats.p_tick_tail <- NULL
    p_stats.p_current_tick <- NULL
    p_stats.tick_count <- 0

    p_stats.gesamt.total_ticks <- 0
    p_stats.gesamt.capacity_total <- capacity_total
    p_stats.gesamt.capacity_taken_percent_avg <- 0
    p_stats.gesamt.capacity_taken_percent_peak <- 0
    p_stats.gesamt.capacity_taken_peak_tick <- 0
    p_stats.gesamt.first_full_tick <- -1
    p_stats.gesamt.full_ticks <- 0

    p_stats.gesamt.arrivals_total <- 0
    p_stats.gesamt.enqueued_total <- 0
    p_stats.gesamt.entered_total <- 0
    p_stats.gesamt.departed_total <- 0
    p_stats.gesamt.net_occupancy_change_total <- 0
    p_stats.gesamt.entered_per_tick_avg <- 0
    p_stats.gesamt.departed_per_tick_avg <- 0

    p_stats.gesamt.queue_length_avg <- 0
    p_stats.gesamt.queue_length_peak <- 0
    p_stats.gesamt.queue_length_peak_tick <- 0
    p_stats.gesamt.queue_rejections_total <- 0
    p_stats.gesamt.queue_wait_avg_ticks <- 0
    p_stats.gesamt.queue_wait_max_ticks <- 0
    p_stats.gesamt.queue_active_ratio_percent <- 0

    p_stats.gesamt.parking_duration_avg_ticks <- 0
    p_stats.gesamt.blocker_full_ratio_percent <- 0
    p_stats.gesamt.bad_parking_cases_total <- 0
    p_stats.gesamt.bad_parking_share_percent <- 0

    p_stats.sum_capacity_taken_percent <- 0
    p_stats.sum_queue_length_end <- 0
    p_stats.sum_entered <- 0
    p_stats.sum_departed <- 0
    p_stats.sum_queue_wait_entered_ticks <- 0
    p_stats.sum_queue_wait_entered_count <- 0
    p_stats.sum_parking_duration_departed_ticks <- 0
    p_stats.sum_parking_duration_departed_count <- 0
    p_stats.queue_active_ticks <- 0
    p_stats.blocker_full_ticks <- 0

    return OK
END FUNCTION

//////////////////////////////////////////////////////////
// Lifecycle: Tick beginnen/finalisieren/committen
//////////////////////////////////////////////////////////

// Brief: Erzeugt einen neuen Tick-Builder fuer den angegebenen Tick-Index.
// Danach duerfen Tick-Rohwerte ueber Add/Set-Funktionen erfasst werden.
FUNCTION stats_tick_begin(p_stats, tick)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    IF p_stats.p_current_tick != NULL THEN
        return ERROR
    END IF

    p_tick <- ALLOCATE(StatsTick)
    IF p_tick = NULL THEN
        return ERROR
    END IF

    MEMSET(p_tick, 0, SIZEOF(StatsTick))
    p_tick.tick <- tick
    p_tick.capacity_total <- p_stats.gesamt.capacity_total

    p_stats.p_current_tick <- p_tick
    return OK
END FUNCTION

//////////////////////////////////////////////////////////
// Tick-Rohwerte: Set/Add-Funktionen
//////////////////////////////////////////////////////////

// Brief: Setzt die Kapazitaets-Rohwerte fuer den aktuellen Tick.
FUNCTION stats_tick_set_capacity(p_stats, taken, free)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.capacity_taken <- taken
    p_tick.capacity_free <- free
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl neu erzeugter Ankuenfte im aktuellen Tick.
FUNCTION stats_tick_add_arrivals_generated(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.arrivals_generated <- p_tick.arrivals_generated + amount
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl in Queue aufgenommener Fahrzeuge.
FUNCTION stats_tick_add_enqueued(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.enqueued <- p_tick.enqueued + amount
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl effektiv eingefahrener Fahrzeuge.
FUNCTION stats_tick_add_entered(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.entered <- p_tick.entered + amount
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl ausgefahrener Fahrzeuge.
FUNCTION stats_tick_add_departed(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.departed <- p_tick.departed + amount
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl Queue-Rejections im aktuellen Tick.
FUNCTION stats_tick_add_queue_rejections(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.queue_rejections <- p_tick.queue_rejections + amount
    return OK
END FUNCTION

// Brief: Setzt die Queue-Laenge am Tick-Ende.
FUNCTION stats_tick_set_queue_length_end(p_stats, queue_length_end)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.queue_length_end <- queue_length_end
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl effektiv eingefahrener Fahrzeuge.
// Brief: Addiert Wartezeit + Zaehler fuer eingetretene Fahrzeuge.
FUNCTION stats_tick_add_entered_queue_wait(p_stats, wait_ticks)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.queue_wait_entered_sum_ticks <- p_tick.queue_wait_entered_sum_ticks + wait_ticks
    p_tick.queue_wait_entered_count <- p_tick.queue_wait_entered_count + 1
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl ausgefahrener Fahrzeuge.
// Brief: Addiert Parkdauer + Zaehler fuer ausgefahrene Fahrzeuge.
FUNCTION stats_tick_add_departed_parking_duration(p_stats, duration_ticks)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.parking_duration_departed_sum_ticks <- p_tick.parking_duration_departed_sum_ticks + duration_ticks
    p_tick.parking_duration_departed_count <- p_tick.parking_duration_departed_count + 1
    return OK
END FUNCTION

// Brief: Setzt die Anzahl Bad-Parking-Faelle des Ticks.
FUNCTION stats_tick_set_bad_parking_cases(p_stats, bad_cases)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.bad_parking_cases <- bad_cases
    return OK
END FUNCTION

// Brief: Erhoeht die Anzahl Bad-Parking-Faelle des Ticks inkrementell.
FUNCTION stats_tick_add_bad_parking_cases(p_stats, amount)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.bad_parking_cases <- p_tick.bad_parking_cases + amount
    return OK
END FUNCTION

// Brief: Markiert, ob im Tick der Blocker "voll" aktiv war.
FUNCTION stats_tick_set_blocker_full_active(p_stats, active)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF
    p_tick.blocker_full_active <- active
    return OK
END FUNCTION

// Brief: Validiert den Tick-Builder vor dem Commit (derzeit ohne Ableitungen).
FUNCTION stats_tick_finalize(p_stats)
    IF p_stats = NULL OR p_stats.p_current_tick = NULL THEN
        return ERROR
    END IF
    return OK
END FUNCTION

// Brief: Haengt den Tick in die Historie ein und aktualisiert alle
// laufenden Summen, Mittelwerte und Peak-Kennzahlen in `StatsGesamte`.
FUNCTION stats_tick_commit(p_stats)
    p_tick <- p_stats.p_current_tick
    IF p_tick = NULL THEN
        return ERROR
    END IF

    p_tick.p_prev <- p_stats.p_tick_tail
    p_tick.p_next <- NULL

    IF p_stats.p_tick_tail = NULL THEN
        p_stats.p_tick_head <- p_tick
    ELSE
        p_stats.p_tick_tail.p_next <- p_tick
    END IF

    p_stats.p_tick_tail <- p_tick
    p_stats.p_current_tick <- NULL
    p_stats.tick_count <- p_stats.tick_count + 1

    g <- &p_stats.gesamt
    g.total_ticks <- p_stats.tick_count

    g.arrivals_total <- g.arrivals_total + p_tick.arrivals_generated
    g.enqueued_total <- g.enqueued_total + p_tick.enqueued
    g.entered_total <- g.entered_total + p_tick.entered
    g.departed_total <- g.departed_total + p_tick.departed
    g.net_occupancy_change_total <- g.net_occupancy_change_total + (p_tick.entered - p_tick.departed)
    g.queue_rejections_total <- g.queue_rejections_total + p_tick.queue_rejections
    g.bad_parking_cases_total <- g.bad_parking_cases_total + p_tick.bad_parking_cases

    IF p_tick.capacity_total > 0 THEN
        current_capacity_percent <- (p_tick.capacity_taken * 100.0) / p_tick.capacity_total
    ELSE
        current_capacity_percent <- 0
    END IF

    IF p_tick.capacity_free = 0 THEN
        g.full_ticks <- g.full_ticks + 1
        IF g.first_full_tick < 0 THEN
            g.first_full_tick <- p_tick.tick
        END IF
    END IF

    IF current_capacity_percent > g.capacity_taken_percent_peak THEN
        g.capacity_taken_percent_peak <- current_capacity_percent
        g.capacity_taken_peak_tick <- p_tick.tick
    END IF

    IF p_tick.queue_length_end > g.queue_length_peak THEN
        g.queue_length_peak <- p_tick.queue_length_end
        g.queue_length_peak_tick <- p_tick.tick
    END IF

    p_stats.sum_capacity_taken_percent <- p_stats.sum_capacity_taken_percent + current_capacity_percent
    p_stats.sum_queue_length_end <- p_stats.sum_queue_length_end + p_tick.queue_length_end
    p_stats.sum_entered <- p_stats.sum_entered + p_tick.entered
    p_stats.sum_departed <- p_stats.sum_departed + p_tick.departed

    IF p_tick.queue_length_end > 0 THEN
        p_stats.queue_active_ticks <- p_stats.queue_active_ticks + 1
    END IF

    IF p_tick.blocker_full_active = 1 THEN
        p_stats.blocker_full_ticks <- p_stats.blocker_full_ticks + 1
    END IF

    p_stats.sum_queue_wait_entered_ticks <- p_stats.sum_queue_wait_entered_ticks + p_tick.queue_wait_entered_sum_ticks
    p_stats.sum_queue_wait_entered_count <- p_stats.sum_queue_wait_entered_count + p_tick.queue_wait_entered_count

    p_stats.sum_parking_duration_departed_ticks <- p_stats.sum_parking_duration_departed_ticks +
                                                  p_tick.parking_duration_departed_sum_ticks
    p_stats.sum_parking_duration_departed_count <- p_stats.sum_parking_duration_departed_count +
                                                  p_tick.parking_duration_departed_count

    g.capacity_taken_percent_avg <- p_stats.sum_capacity_taken_percent / g.total_ticks
    g.entered_per_tick_avg <- p_stats.sum_entered / g.total_ticks
    g.departed_per_tick_avg <- p_stats.sum_departed / g.total_ticks
    g.queue_length_avg <- p_stats.sum_queue_length_end / g.total_ticks
    g.queue_active_ratio_percent <- (p_stats.queue_active_ticks * 100.0) / g.total_ticks
    g.blocker_full_ratio_percent <- (p_stats.blocker_full_ticks * 100.0) / g.total_ticks

    IF p_stats.sum_queue_wait_entered_count > 0 THEN
        g.queue_wait_avg_ticks <- p_stats.sum_queue_wait_entered_ticks / p_stats.sum_queue_wait_entered_count
        IF g.queue_wait_avg_ticks > g.queue_wait_max_ticks THEN
            g.queue_wait_max_ticks <- g.queue_wait_avg_ticks
        END IF
    END IF

    IF p_stats.sum_parking_duration_departed_count > 0 THEN
        g.parking_duration_avg_ticks <- p_stats.sum_parking_duration_departed_ticks /
                                        p_stats.sum_parking_duration_departed_count
    END IF

    IF g.enqueued_total > 0 THEN
        g.bad_parking_share_percent <- (g.bad_parking_cases_total * 100.0) / g.enqueued_total
    END IF

    return OK
END FUNCTION

//////////////////////////////////////////////////////////
// Zugriff/Kompatibilitaet
//////////////////////////////////////////////////////////

// Brief: Kompatibilitaetsfunktion fuer bestehende Aufrufstellen.
FUNCTION Stats_RecordTick(p_stats, current_tick)
    status <- stats_tick_begin(p_stats, current_tick)
    IF status != OK THEN
        return status
    END IF

    status <- stats_tick_finalize(p_stats)
    IF status != OK THEN
        return status
    END IF

    return stats_tick_commit(p_stats)
END FUNCTION

FUNCTION stats_get_latest_tick(p_stats)
    IF p_stats = NULL THEN
        return NULL
    END IF
    return p_stats.p_tick_tail
END FUNCTION

FUNCTION stats_get_summary(p_stats)
    IF p_stats = NULL THEN
        return NULL
    END IF
    return &p_stats.gesamt
END FUNCTION

FUNCTION stats_free(p_stats)
    IF p_stats = NULL THEN
        return ERROR
    END IF

    p_current <- p_stats.p_tick_head
    WHILE p_current != NULL DO
        p_next <- p_current.p_next
        FREE(p_current)
        p_current <- p_next
    END WHILE

    p_stats.p_tick_head <- NULL
    p_stats.p_tick_tail <- NULL
    p_stats.p_current_tick <- NULL
    p_stats.tick_count <- 0

    return OK
END FUNCTION