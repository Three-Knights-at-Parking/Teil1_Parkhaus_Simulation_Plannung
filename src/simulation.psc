INCLUDE FILE ui.h
INCLUDE FILE config.h
INCLUDE FILE simulation.h

FUNCTION print_simulationscreen(settings)

    CLEAR Terminal

    OUTPUT "===================================="
    OUTPUT "          SIMULATION MENU"
    OUTPUT "===================================="
    OUTPUT ""
    OUTPUT "Current Configuration"
    OUTPUT "------------------------------------"
    OUTPUT "Spots per Floor  : ", settings.size
    OUTPUT "Floors           : ", settings.floors
    OUTPUT "Gates            : ", settings.gates
    OUTPUT "Tick Length (sec): ", settings.real_equivalent
    OUTPUT "Max Ticks        : ", settings.max_ticks
    OUTPUT "Random Seed      : ", settings.rand_seed
    OUTPUT "------------------------------------"
    OUTPUT ""
    OUTPUT "1 Start Simulation"
    OUTPUT "2 Go to Configuration"
    OUTPUT "0 Back to Home"
    OUTPUT ""
END FUNCTION