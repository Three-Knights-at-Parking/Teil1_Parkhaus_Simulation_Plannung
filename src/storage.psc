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