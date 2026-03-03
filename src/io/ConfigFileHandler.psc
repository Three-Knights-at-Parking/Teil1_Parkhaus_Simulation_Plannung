//////////////////////////////////////////////////////////
// Module: config_file_handler
// Dependencies: types, file I/O, (later JSON parser)
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


FUNCTION config_save_settings(p_settings, dest_path)
    IF p_settings = NULL THEN
        return ERROR
    END IF

    // Default to root folder
    IF (dest_path = NULL) OR (dest_path = "") THEN
        file_path <- "../config.json"
    ELSE
        file_path <- dest_path
    END IF

    file <- FILE_OPEN_WRITE(file_path)
    IF file = NULL THEN
        return ERROR
    END IF

    // Future Implementation will generate a json file.
    // For now we do it symbolically like this.
    FILE_WRITE_LINE(file, "{")
    FILE_WRITE_LINE(file, "  \"name\": \"" + p_settings.name + "\",")
    FILE_WRITE_LINE(file, "  \"size\": " + TO_STRING(p_settings.size) + ",")
    FILE_WRITE_LINE(file, "  \"floors\": " + TO_STRING(p_settings.floors) + ",")
    FILE_WRITE_LINE(file, "  \"gates\": " + TO_STRING(p_settings.gates) + ",")
    FILE_WRITE_LINE(file, "  \"real_equivalent\": " + TO_STRING(p_settings.real_equivalent) + ",")
    FILE_WRITE_LINE(file, "  \"output_mode\": " + OUTPUTMODE_TO_STRING(p_settings.output_mode) + ",")
    FILE_WRITE_LINE(file, "  \"is_leavable\": " + QUEUELEAVABLE_TO_STRING(p_settings.is_leavable) + ",")
    FILE_WRITE_LINE(file, "  \"max_ticks\": " + TO_STRING(p_settings.max_ticks) + ",")
    FILE_WRITE_LINE(file, "  \"rand_seed\": " + TO_STRING(p_settings.rand_seed))
    FILE_WRITE_LINE(file, "}")

    FILE_CLOSE(file)

    return OK
END FUNCTION

