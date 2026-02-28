INCLUDE FILE ui.h
INCLUDE FILE confi.h

FUNCTION print_configscreen(settings)

    OUTPUT "=============================="
    OUTPUT "         Config-Menu"
    OUTPUT "=============================="

    OUTPUT "Current Settings:"
    OUTPUT "1 Parking spots per floor: ", settings.size
    OUTPUT "2 Parking Floors: ", settings.floors
    OUTPUT "3 Amount of Gates: ", settings.gates
    OUTPUT "4 Tick equivalent (sec): ", settings.real_equivalent
    OUTPUT "5 Max ticks (or -1/-2/... for 1/2/... days equivalent): ", settings.max_ticks
    OUTPUT "6 Random seed (or -1 for default): ", settings.rand_seed
    OUTPUT ""
    OUTPUT "0 Back to Home"
    OUTPUT ""

END FUNCTION