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
        status = ERROR;   //error
    }
    return status;
}

int Parkhaus_Tick(uint32_t currentTick)
{
    ///////////
    ///EXIT///
    /////////
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

    ////////////
    ///ENTRY///
    //////////
    Node* currentNode = head_CarList;

    //Simulating new awaiting Car'S
    CarEntrys = simEntrys();

    //Checks if any cars want to entry
    if (CarEntrys > 0 || !queue.empty())
    {
        //cycles for max possible Entrys in the timespan of one Tick
        for (int i = 0; i < possibleEntryPerTick; i++) //possible entrys per tick ergibt sich aus anzahl der schranken * (tick_insec / CarEntry_timeNeeded)
        {
            //Priorisizing cars in que then entrys from new cars
            if (!queue.empty())
            {
                entryFromQueue();   //set entry Tick in car object
            }
            else if (CarEntrys > 0)
            {
                Carentrys--;
                new Car();
                Car_entry();
            }
        }
        //Cars that coulndn't enter -> Queued
        if (CarEntrys > 0)
        {
            for (CarEntrys; CarEntrys > 0; CarEntrys--)
            {
                Queue.Add( NEW Car() ) // add queue Entry Tick at car
            }
        }

    }
}


//Parkhaus schließt - Alle Fahrzeuge müssen Ausfahren.
int Parkhaus_end()
{
    Node* currentNode = head_CarList;
    //Car list wird durchlaufen -> bei jedem car wird Car_leaviong gecalled
    while (current != NULL) {
            Car_leaving();
            current = current->next;
        }// nächstes Element
    }
}

int Car_leaving(Parkhaus *p, car *c)
{
    if (p == NULL) return ERROR;
    if (c == NULL) return ERROR;

    p->fill_size--;
    p->total_left++;

    List->remove.Car();
}

//Calculates how many new Cars wanna entry the parkingspace in one Tick
int simEntrys()
 {
     int counter = 0;
     //cycles for every entrance
     for (int a = 0; a < anz_entrance; a++)
     {
         //cycle for all possible entrys in one Tick at one Entrance
         for (int i = 0; i < Tick_inSec; i++0)
         {
             if ( (spawncalc(carspawn_perc) )
                 counter++;
         }
     }
     retunr counter; //return of the number of new cars
 }


