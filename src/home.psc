/**
 * @brief Displays the Home-Menu and processes user input.
 *
 * @return Next UI-state.
 */

FUNCTION home_menu()

    OUTPUT "=============================="
    OUTPUT " Parkhaus-Simulation Rauenegg "
    OUTPUT "=============================="
    OUTPUT "1 - Simulation"
    OUTPUT "2 - Konfiguration"
    OUTPUT "3 - Speicheroptionen"
    OUTPUT "0 - Beenden"

    choice ← INPUT

    IF choice = 1 THEN
        return "SIMULATION"

    ELSE IF choice = 2 THEN
        return "KONFIG"

    ELSE IF choice = 3 THEN
        return "STORAGE"

    ELSE IF choice = 0 THEN
        return "EXIT"

    ELSE
        OUTPUT "Ungültige Eingabe"
        return "HOME"
    END IF

END FUNCTION