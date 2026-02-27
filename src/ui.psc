FUNCTION welcome_message()

    OUTPUT "========================================="
    OUTPUT "     Parkhaus-Simulation Rauenegg"
    OUTPUT "========================================="
    OUTPUT ""
    OUTPUT "[Welcome Message with brief description]"
    OUTPUT ""
    OUTPUT "Press ENTER to continue..."

    INPUT dummy

    return "HOME"
END FUNCTION

FUNCTION ui_start()

    state ← welcome_message()

    WHILE state != "EXIT" DO

        IF state = "HOME" THEN
            state ← home_menu()

        ELSE IF state = "KONFIG" THEN
            state ← konfig_menu()

        ELSE IF state = "SIMULATION" THEN
            state ← simulation_menu()

        ELSE IF state = "STORAGE" THEN
            state ← storage_menu()

        END IF

    END WHILE

END FUNCTION