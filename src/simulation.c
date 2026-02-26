//
// Created by ibach on 26.02.2026.
//

#include "simulation.h"
#include <stdio.h>
#include "types.h"


 Pseudocode;
int sim_tick()
{
    short status;

    if (get.currentTick + 1 == get_maxTick)
    {
        currentTick++;
        status = endSimulation(currentTick);
    }
    else if (get.currentTick < get_maxTick)
    {
        currentTick++;
        status = Parkhaus_Tick(currentTick);
    }
    else if (get.currentTick >= get_maxTick)
    {
        endSimulation();
        status = 0;   //error
    }
    return status;
}

int Parkhaus_Tick(uint32_t currentTick)
{
    Node* currentNode = head_CarList;

    while (current != NULL) {
        if ( ((current->car.created_at - currentTick)) < current->car.leavingIn_Ticks) {
            current = current->next;
        }
        else if ( ((current->car.created_at - currentTick)) >= current->car.leavingIn_Ticks)
        {
            Car_leaving();
            current = current->next;
        }// nächstes Element
    }
}


int Car_leaving(Parkhaus *p, car *c)
{
    if (p == NULL) return 0;
    if (c == NULL) return 10;

    p->fill_size--;
    p->total_left++;

}

