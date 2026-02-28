FUNCTION print_storagescreen()

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "            STORAGE MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "1 Browse Runtime Directory"
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION

FUNCTION storage_menu()

    CALL print_storagescreen()

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, 1)
    END WHILE

    IF choice = 1 THEN
        CALL browse_directory(runtime_path)
        return UI_STORAGE

    ELSE IF choice = 0 THEN
        return UI_HOME
    END IF

END FUNCTION

FUNCTION browse_directory(current_path)

    CLEAR Terminal

    entries ← CALL read_directory(current_path)

    OUTPUT "Current Path: ", current_path
    OUTPUT "------------------------------------"

    index ← 1

    FOR each entry IN entries DO
        OUTPUT index, " ", entry.name
        index ← index + 1
    END FOR

    OUTPUT "------------------------------------"
    OUTPUT "0 Back"

    max_valid_number ← index - 1
    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, max_valid_number)
    END WHILE

    IF choice = 0 THEN
        return
    END IF

    selected_entry ← entries[choice]

    IF selected_entry IS DIRECTORY THEN
        CALL directory_options(selected_entry.path)

    ELSE IF selected_entry IS FILE THEN
        CALL file_options(selected_entry.path)
    END IF

END FUNCTION

FUNCTION deleting_verification(object_path, object_type)

    CLEAR Terminal

    OUTPUT object_type, ": ", object_path
    OUTPUT ""
    OUTPUT "Are you sure you want to delete this ", object_type, "?"
    OUTPUT "1 Yes"
    OUTPUT "0 No"
    OUTPUT ""

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        confirm ← CALL user_input()
        validation_flag ← CALL validate_user_input(confirm, 1)
    END WHILE

    IF confirm = 1 THEN

        IF object_type = "Directory" THEN

            IF object_path = runtime_path THEN
                OUTPUT "Root runtime directory cannot be deleted."
                OUTPUT "Press ENTER to continue."
                INPUT dummy
                return
            END IF

            CALL delete_directory(object_path)

        ELSE IF object_type = "File" THEN
            CALL delete_file(object_path)
        END IF

        OUTPUT object_type, " deleted."
        OUTPUT "Press ENTER to continue."
        INPUT dummy
    END IF

    return

END FUNCTION

FUNCTION directory_options(dir_path)

    CLEAR Terminal

    OUTPUT "Directory: ", dir_path
    OUTPUT ""
    OUTPUT "1 Enter Directory"
    OUTPUT "2 Delete Directory"
    OUTPUT "0 Back"
    OUTPUT ""

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, 2)
    END WHILE

    IF choice = 1 THEN
        CALL browse_directory(dir_path)
        return

    ELSE IF choice = 2 THEN
        CALL deleting_verification(dir_path, "Directory")
        return

    ELSE IF choice = 0 THEN
        return
    END IF

END FUNCTION

FUNCTION file_options(file_path)

    CLEAR Terminal

    OUTPUT "File: ", file_path
    OUTPUT ""
    OUTPUT "1 Open File"
    OUTPUT "2 Delete File"
    OUTPUT "0 Back"
    OUTPUT ""

    validation_flag ← INVALID

    WHILE validation_flag != VALID DO
        choice ← CALL user_input()
        validation_flag ← CALL validate_user_input(choice, 2)
    END WHILE

    IF choice = 1 THEN

        CALL print_file_to_terminal(file_path)

        OUTPUT ""
        OUTPUT "Press ENTER to return."
        INPUT dummy
        return

    ELSE IF choice = 2 THEN

        CALL deleting_verification(file_path, "File")
        return

    ELSE IF choice = 0 THEN
        return
    END IF

END FUNCTION

FUNCTION print_file_to_terminal(path)

    OPEN file at path

    WHILE NOT end_of_file DO
        line ← READ line
        OUTPUT line
    END WHILE

    CLOSE file

END FUNCTION

FUNCTION delete_directory(path)

    entries ← CALL read_directory(path)

    FOR each entry IN entries DO

        IF entry IS FILE THEN
            CALL delete_file(entry.path)

        ELSE IF entry IS DIRECTORY THEN
            CALL delete_directory(entry.path)
        END IF

    END FOR

    REMOVE directory at path

END FUNCTION

FUNCTION delete_file(path)

    REMOVE file at path

END FUNCTION