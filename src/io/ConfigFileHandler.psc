//////////////////////////////////////////////////////////
// Modul: config_file_handler
// Abhaengigkeiten: types, Datei-I/O, (spaeter JSON-Parser)
//////////////////////////////////////////////////////////

FUNCTION config_load_settings(p_settings, src_path)
    IF p_settings = NULL THEN
        return ERROR
    END IF

    // Will default to root path (parent folder of EXE)
    IF (src_path = NULL) OR (src_path = "") THEN
        file_path <- "../config.json"
    ELSE
        file_path <- src_path
    END IF

    file <- FILE_OPEN_READ(file_path)
    IF file = NULL THEN
        return ERROR
    END IF
    raw_text <- FILE_READ_ALL(file)
    FILE_CLOSE(file)

    IF raw_text = NULL THEN
        return ERROR
    END IF

    // Future implementations might parse JSON here.
    // For now we symbolize:
    p_settings.name            <- PARSE_STRING(raw_text, "name")
    p_settings.size            <- PARSE_UINT16(raw_text, "size")
    p_settings.floors          <- PARSE_UINT8(raw_text, "floors")
    p_settings.gates           <- PARSE_UINT8(raw_text, "gates")
    p_settings.real_equivalent <- PARSE_UINT16(raw_text, "real_equivalent")
    p_settings.output_mode     <- PARSE_OUTPUTMODE(raw_text, "output_mode")
    p_settings.is_leavable     <- PARSE_QUEUELEAVABLE(raw_text, "is_leavable")
    p_settings.max_ticks       <- PARSE_INT32(raw_text, "max_ticks")
    p_settings.rand_seed       <- PARSE_INT32(raw_text, "rand_seed")

    // it's probably useful to safe this src string
    p_settings.src_path <- COPY_STRING(file_path)

    return OK
END FUNCTION
