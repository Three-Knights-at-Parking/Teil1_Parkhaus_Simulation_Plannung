INCLUDE FILE ui.h 

FUNCTION user_input()

    OUTPUT "ENTER the number (int) you want navigate to: "
    user_input ← INPUT

    return user_input

END FUNCTION

FUNCTION validate_user_input(int user_choice, const int max_valid_number)

    IF user_choice != type int THEN
        OUTPUT "Your input is not an integer!"
        OUTPUT "Please press ENTER and try again... "

        INPUT dummy
        return INVALID

    ELSE IF user_choice < 0 OR user_choice > max_valid_number THEN
        OUTPUT "The number you entered is invalid!"
        OUTPUT "Please only choose between the numbers displayed."
        OUTPUT "Press ENTER and try again..."

        INPUT dummy
        return INVALID
    
    ELSE 
        return VALID
    END IF

END FUNCTION

FUNCTION welcome_message()

    CLEAR Terminal

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