FUNCTION graphhandler_generate_from_file(src_path, dest_path)
    IF src_path = NULL THEN
        return ERROR
    END IF

    IF (dest_path = NULL) OR (dest_path = "") THEN
        graph_path <- "../graphs/parkhaus_stats.png"
    ELSE
        graph_path <- dest_path
    END IF

    stats_file <- FILE_OPEN_READ(src_path)
    IF stats_file = NULL THEN
        return ERROR
    END IF

    stats_lines <- FILE_READ_ALL_LINES(stats_file)
    FILE_CLOSE(stats_file)

    IF stats_lines = NULL THEN
        return ERROR
    END IF

    // Convert data into arrays
    ticks          <- EXTRACT_COLUMN(stats_lines, "tick")
    fill_sizes     <- EXTRACT_COLUMN(stats_lines, "fill_size")
    queue_lengths  <- EXTRACT_COLUMN(stats_lines, "queue_length")
    missed_entries <- EXTRACT_COLUMN(stats_lines, "missed_entries")

    // Build data set for plotting library
    // Currently only schematically
    plot_data <- PLOT_DATA_CREATE()
    PLOT_DATA_ADD_SERIES(plot_data, "Fill Size", ticks, fill_sizes)
    PLOT_DATA_ADD_SERIES(plot_data, "Queue Length", ticks, queue_lengths)
    PLOT_DATA_ADD_SERIES(plot_data, "Missed Entries", ticks, missed_entries)

    // or any library specific implementation
    status <- PLOT_RENDER_TO_FILE(
                  plot_data,
                  graph_path,
                  "Parkhaus Simulation",     // Title
                  "Tick",                    // X-Axis
                  "Werte"                    // Y-Axis
              )

    PLOT_DATA_FREE(plot_data)

    IF status != 0 THEN
        return ERROR
    END IF

    return OK
END FUNCTION

FUNCTION graphhandler_generate_from_simulation(p_sim, dest_path)
    IF p_sim = NULL THEN
        return ERROR
    END IF

    IF (dest_path = NULL) OR (dest_path = "") THEN
        graph_path <- "../graphs/parkhaus_stats.png"
    ELSE
        graph_path <- dest_path
    END IF

    p_parkhaus <- p_sim.parkhaus

    // For now we use the array in p_sim.stats_... (TODO not yet implemented)
    ticks          <- p_sim.stats_ticks
    fill_sizes     <- p_sim.stats_fill_sizes
    queue_lengths  <- p_sim.stats_queue_lengths
    missed_entries <- p_sim.stats_missed_entries

    plot_data <- PLOT_DATA_CREATE()
    PLOT_DATA_ADD_SERIES(plot_data, "Fill Size", ticks, fill_sizes)
    PLOT_DATA_ADD_SERIES(plot_data, "Queue Length", ticks, queue_lengths)
    PLOT_DATA_ADD_SERIES(plot_data, "Missed Entries", ticks, missed_entries)
    //Library specific
    status <- PLOT_RENDER_TO_FILE(
                  plot_data,
                  graph_path,
                  "Parkhaus Simulation",
                  "Tick",
                  "Werte"
              )

    PLOT_DATA_FREE(plot_data)

    IF status != 0 THEN
        return ERROR
    END IF

    return OK
END FUNCTION

