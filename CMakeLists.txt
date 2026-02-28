cmake_minimum_required(VERSION 3.16)

project(Teil1_Parkhaus_Simulation_Plannung C)

set(CMAKE_C_STANDARD 17)

add_executable(Teil1_Parkhaus_Simulation_Plannung
        include/types.h
        include/Car.h
        include/Queue.h
        include/Parkhaus.h
        include/Simulation.h
        include/SimulationObject.h
        include/Settings.h
        include/VehicleList.h
        include/io/ConfigFileHandler.h
        include/io/SaveHandler.h
        include/io/GraphHandler.h
)

target_include_directories(Teil1_Parkhaus_Simulation_Plannung
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/includes
)
