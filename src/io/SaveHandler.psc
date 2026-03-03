//////////////////////////////////////////////////////////
// Modul: savehandler
// Abhaengigkeiten: types, Datei-I/O, UI
//////////////////////////////////////////////////////////

FUNCTION savehandler_save_tick(p_sim, p_tickstats, dest_path)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF p_tickstats = NULL THEN
        return ERROR
    END IF

    resolved_path <- savehandler_resolve_stats_path(dest_path)
    IF (resolved_path = "") THEN
        return ERROR
    END IF

    mode <- p_sim.settings.output_mode
    IF mode = NONE THEN
        return OK
    END IF

    file <- FILE_OPEN_APPEND(resolved_path)
    IF file = NULL THEN
        return ERROR
    END IF

    savehandler_write_header_if_new(file, p_sim, mode)

    IF mode = NORMAL THEN
        line <- TO_STRING(p_tickstats.tick) + ";" +
                TO_STRING(p_tickstats.capacity_taken_percent) + ";" +
                TO_STRING(p_tickstats.queue_length_end) + ";" +
                TO_STRING(p_tickstats.entered) + ";" +
                TO_STRING(p_tickstats.departed)
        FILE_WRITE_LINE(file, line)
    ELSE
        line <- TO_STRING(p_tickstats.tick) + ";" +
                TO_STRING(p_tickstats.capacity_total) + ";" +
                TO_STRING(p_tickstats.capacity_taken) + ";" +
                TO_STRING(p_tickstats.capacity_free) + ";" +
                TO_STRING(p_tickstats.capacity_taken_percent) + ";" +
                TO_STRING(p_tickstats.arrivals_generated) + ";" +
                TO_STRING(p_tickstats.enqueued) + ";" +
                TO_STRING(p_tickstats.entered) + ";" +
                TO_STRING(p_tickstats.departed) + ";" +
                TO_STRING(p_tickstats.queue_length_end) + ";" +
                TO_STRING(p_tickstats.queue_rejections) + ";" +
                TO_STRING(p_tickstats.bad_parking_cases)
        FILE_WRITE_LINE(file, line)
    END IF

    FILE_CLOSE(file)

    UI_PRINT_TICK_STATS(p_tickstats, mode)

    return OK
END FUNCTION

FUNCTION savehandler_save_summary(p_sim, p_summary, dest_path)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF p_summary = NULL THEN
        return ERROR
    END IF

    resolved_path <- savehandler_resolve_stats_path(dest_path)
    IF (resolved_path = "") THEN
        return ERROR
    END IF

    mode <- p_sim.settings.output_mode
    IF mode = NONE THEN
        return OK
    END IF

    file <- FILE_OPEN_WRITE(resolved_path)
    IF file = NULL THEN
        return ERROR
    END IF

    FILE_WRITE_LINE(file, "SUMMARY")
    ... // same lines as before
    FILE_CLOSE(file)

    UI_PRINT_SUMMARY_STATS(p_summary, mode)

    return OK
END FUNCTION


FUNCTION savehandler_load_and_print(src_path)
    base_folder <- "../stats/"

    IF (src_path = NULL) OR (src_path = "") THEN
        file_path <- base_folder + "stats.csv"
    ELSE
        IF STRING_CONTAINS(src_path, "..") THEN
            // Disallow path traversal up. We only want stats to be save under
            // the stats folder no matter what.
            file_path <- base_folder + "stats.csv"
        ELSE
            file_path <- base_folder + src_path
        END IF
    END IF

    file <- FILE_OPEN_READ(file_path)
    IF file = NULL THEN
        return ERROR
    END IF

    p_list_head <- NULL
    p_list_tail <- NULL

    WHILE NOT FILE_EOF(file) DO
        line <- FILE_READ_LINE(file)

        IF (line = NULL) OR (line = "") THEN
            CONTINUE
        END IF

        IF STRING_STARTS_WITH(line, "#") THEN
            CONTINUE
        END IF

        // skip summary line
        IF STRING_STARTS_WITH(line, "SUMMARY") THEN
            CONTINUE
        END IF

        p_tick <- ALLOCATE(StatsTick)
        IF p_tick = NULL THEN
            // Free list on error
            current <- p_list_head
            WHILE current != NULL DO
                next <- current.p_next
                FREE(current)
                current <- next
            END WHILE

            FILE_CLOSE(file)
            return ERROR
        END IF
        p_tick.p_next <- NULL


        columns <- STRING_SPLIT(line, ";")
        num_cols <- LENGTH(columns)

        IF num_cols = 5 THEN
            // NORMAL-Format ---- TODO Change to the most relevant statistics @Dani @Simon
            p_tick.tick                      <- TO_UINT32(columns[0])
            p_tick.capacity_taken_percent    <- TO_FLOAT(columns[1])
            p_tick.queue_length_end          <- TO_UINT8(columns[2])
            p_tick.entered                   <- TO_UINT16(columns[3])
            p_tick.departed                  <- TO_UINT16(columns[4])

            // other fields are not relevant for NORMAL-Format
            p_tick.capacity_total            <- 0
            p_tick.capacity_taken            <- 0
            p_tick.capacity_free             <- 0
            p_tick.queue_rejections          <- 0
            p_tick.bad_parking_cases         <- 0
            //....etc
        ELSE
            // VERBOSE-Format
            // indicies must be consistent
            p_tick.tick                      <- TO_UINT32(columns[0])
            p_tick.capacity_total            <- TO_UINT16(columns[1])
            p_tick.capacity_taken            <- TO_UINT16(columns[2])
            p_tick.capacity_free             <- TO_UINT16(columns[3])
            p_tick.capacity_taken_percent    <- TO_FLOAT(columns[4])
            p_tick.arrivals_generated        <- TO_UINT16(columns[5])
            p_tick.enqueued                  <- TO_UINT16(columns[6])
            p_tick.entered                   <- TO_UINT16(columns[7])
            p_tick.departed                  <- TO_UINT16(columns[8])
            p_tick.queue_length_end          <- TO_UINT8(columns[9])
            p_tick.queue_rejections          <- TO_UINT32(columns[10])
            p_tick.bad_parking_cases         <- TO_UINT16(columns[11])
            //....etc
        END IF

        IF p_list_head = NULL THEN
            p_list_head <- p_tick
            p_list_tail <- p_tick
        ELSE
            p_list_tail.p_next <- p_tick
            p_list_tail        <- p_tick
        END IF
    END WHILE

    FILE_CLOSE(file)

    // Forward data to UI Frontend.
    UI_PRINT_SAVED_STATS(p_list_head, p_list_tail)

    // SaveHandler stays owner of the list and frees it after use!
    current <- p_list_head
    WHILE current != NULL DO
        next <- current.p_next
        FREE(current)
        current <- next
    END WHILE

    return OK
END FUNCTION



FUNCTION savehandler_resolve_stats_path(dest_path)
    base_folder <- "../stats/"

    // Check if folder exists and will create it if not.
    IF NOT DIRECTORY_EXISTS(base_folder) THEN
        status <- DIRECTORY_CREATE(base_folder)
        IF status != 0 THEN
            return ""
        END IF
    END IF

    // Default case (file under ../stats/stats.csv)
    IF (dest_path = NULL) OR (dest_path = "") THEN
        return base_folder + "stats.csv"
    END IF

    // User given folder path, always under ../stats/..*
    IF STRING_CONTAINS(dest_path, "..") THEN
        // Disallow path traversal up.
        file_name <- "stats.csv"
    ELSE
        file_name <- dest_path
    END IF

    return base_folder + file_name
END FUNCTION



FUNCTION savehandler_write_header_if_new(file, p_sim, mode)
    IF FILE_SIZE(file) = 0 THEN
        FILE_WRITE_LINE(file, "# SETTINGS")
        FILE_WRITE_LINE(file, "# name=" + p_sim.settings.name)
        FILE_WRITE_LINE(file, "# capacity=" + TO_STRING(p_sim.settings.capacity))
        FILE_WRITE_LINE(file, "# floors=" + TO_STRING(p_sim.settings.floors))
        FILE_WRITE_LINE(file, "# gates=" + TO_STRING(p_sim.settings.gates))
        FILE_WRITE_LINE(file, "# tick_inSec=" + TO_STRING(p_sim.settings.tick_inSec))
        FILE_WRITE_LINE(file, "# max_ticks=" + TO_STRING(p_sim.settings.max_ticks))
        FILE_WRITE_LINE(file, "# rand_seed=" + TO_STRING(p_sim.settings.rand_seed))
        FILE_WRITE_LINE(file, "# output_mode=" + TO_STRING(p_sim.settings.output_mode))
        FILE_WRITE_LINE(file, "# is_leavable=" + TO_STRING(p_sim.settings.is_leavable))
        IF mode = NORMAL THEN
            header <- "tick;capacity_taken_percent;queue_length_end;entered;departed"
        ELSE
            header <- "tick;capacity_total;capacity_taken;capacity_free;" +
                      "capacity_taken_percent;arrivals_generated;enqueued;" +
                      "entered;departed;queue_length_end;queue_rejections;bad_parking_cases" //...etc some fields are missing
        END IF

        FILE_WRITE_LINE(file, header)
    END IF

    return
END FUNCTION


