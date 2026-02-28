#ifndef SIMULATION_H
#define SIMULATION_H

#define SIMULATION_MAX_VALID_NUMBER 2
#define SIM_POST_MAX_VALID_NUMBER 1

void print_simulationscreen(Settings settings);
void post_simulation_prompt(char* sim_output_path);
ui_state simulation_menu(Settings settings);
char* start_simulation(Settings settings);

#endif