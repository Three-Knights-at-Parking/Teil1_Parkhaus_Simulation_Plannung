# Begründung der Entwurfsentscheidungen (Parkhaus-Simulation Teil I)

In diesem Dokument wollen wir gemäß der Aufgabenstellung (Punkt 4f) Begründungen für die gewählte Architektur, die Dateistruktur, die Statistiken und die I/O-Formate der Parkhaus-Simulation festhalten.


## 1. Quellcode- und Header-Dateien (zu Punkt a)
Die Aufteilung des Quellcodes folgt streng dem Prinzip der **Separation of Concerns (Trennung der Zuständigkeiten)** und der **Modularisierung**, wie in den Requirements zum Teil auch gewünscht ist.
* **Kernlogik vs. I/O:** Wir trennen die reine Simulationslogik (`Simulation`, `Parkhaus`, `Queue`, `Car`) strikt von Ein- und Ausgabeprozessen (`ui`, `io`, `ConfigFileHandler`). Für uns stellt die Simulation einen eigenen Prozess dar, der einmal am Anfang durch die Eingabe des Nutzers konfiguriert wird und danach eigenständig ihre Aufgabe durchführt.
* **Wartbarkeit:** Durch die Aufteilung in fachliche Module (jedes Modul hat seinen eigenen Header, z.B. `Queue.h`, `Parkhaus.h`) können mehrere Teammitglieder parallel an verschiedenen Features arbeiten (z.B. UI-Design vs. Queue-Logik), ohne dass es zu großen Merge-Konflikten in Git kommt. Auch lassen sich im Nachhinein für jede Header-Datei eigene Tests schreiben. Jede Header-Datei ist einzeln dokumentiert und besitzt eine Definition in types.h, was dafür sorgt, dass jedes Objekt eine einheitliche Struktur/Schnittstelle zum Rest des Codes hat und als ein logischer Block erscheint.
* **Dokumentation und Klarheit**: Durch das Aufteilen in verschiedene Headerdateien lassen sich Zustände wie Ownership über Nodes, Verhalten bei einem Fehler o.ä. klarer veranschaulichen und dokumentieren. 

## 2. Geplante Statistiken (zu Punkt b)
Gemäß der Problemstellung soll die Simulation Daten liefern, um *"die Auslastung und mögliche bauliche Erweiterungen bewerten zu können"*. Unsere UI printet pro Simulations-Tick (`NORMAL mode`) folgende Metriken, die exakt auf dieses Ziel einzahlen:

1. **Occupancy (Auslastung - `capacity_taken` / `capacity_total`):** Zeigt die prozentuale und absolute Belegung. Anhand der Auslastung lässt sich gut abschätzen, ob die Göße des Parkhauses ausreichend ist oder nicht. Ist dieser Wert konstant nahe 100%, ist das Parkhaus möglicherweise zu klein.
2. **Queue Length (`queue_length_end`):** Die Länge der Warteschlange am Ende eines Ticks. Eine stetig wachsende Schlange ist der stärkste Indikator dafür, dass das Parkhaus Andrang nicht decken kann.
3. **Arrivals, In & Out (`arrivals_generated`, `entered`, `departed`):** Diese Durchsatz-Metriken liefern mehr Informationen darüber, wie sich der Zustand ändert. Sie helfen zu verstehen, ob es Stoßzeiten gibt (viele Arrivals, wenig Out) oder ob der Verkehr gleichmäßig fließt. In zukünftigen Implementierungen gäbe es ggf. die Möglichkeit, realistische Stoßzeiten zu simulieren.
4. **Rejections (`queue_rejections`):** Abgewiesene Fahrzeuge (z.B. weil die Schlange voll ist oder die Wartezeit zu lang wäre) stellen direkten wirtschaftlichen Verlust und unzufriedene Kunden dar. Hohe Rejection-Raten sind das stärkste Argument für eine bauliche Erweiterung. Die maximale Länge der Queue kann dabei durch den Nutzer definiert werden.
5. **Average Queue Wait (`avg_wait`):** Die durchschnittliche Wartezeit der Autos, die erfolgreich eingefahren sind. Auch wenn das Parkhaus nicht ständig voll ist, kann eine schlechte Abfertigung zu langen Wartezeiten führen (z.B. Schranken-Flaschenhals). Das erhöht auch die Chance, dass ein Fahrzeug gar nicht einfährt, und senkt die durchschnittliche Parkzeit.
Dies sind die Statistiken, die im normalen (`NORMAL`) Modus ausgegeben werden. Für Teil 2 der Aufgabe planen wir auch einen (`VERBOSE`) Modus einstellbar zu machen, welcher noch mehr Statisitken und Daten liefert, sollte der Nutzer an der vollen Bandbreite der Daten interessiert sein.

## 3. Format der geplanten Ausgabe (zu Punkt c)
Die Ausgabe erfolgt zweigleisig, um sowohl die Benutzerfreundlichkeit als auch die maschinelle Auswertbarkeit zu gewährleisten:
* **Konsolenausgabe (Terminal):** Das Format wurde als übersichtliche, ASCII-basierte Tabelle entworfen (inklusive Status-Bars wie `occ_bar`). Dies ermöglicht es dem Benutzer, die Simulation live und visuell ansprechend im Terminal zu verfolgen. 
* **Text-Datei (CSV-Format):** Für die dauerhafte Speicherung schreiben wir die Statistiken in eine CSV-Datei (z.B. `CSV_FILE_NORMAL_MODE.csv`). CSV-Dateien sind der Industrie-Standard für tabellarische Daten. Sie lassen sich nach der Simulation trivial in Excel, Python (Pandas) oder R importieren, um dort fortgeschrittene Graphen zur Auswertung der "baulichen Erweiterungen" zu generieren. Zusätzlich generieren wir für die wichtigsten Statistiken auch eine Grafik (ein Beispiel für den `NORMAL` Modus ist docs/examples/charts zu finden).

## 4. Festgelegte Datentypen und Strukturen (zu Punkt d)
Um die Fahrzeuge und das Parkhaus abzubilden, nutzen wir ein objektorientiertes Design-Pattern in C, basierend auf Polymorphismus mit structs/typedefs.
* **`SimulationObject` & `GenericVehicle`:** C unterstützt nativ keine Klassen. Indem wir ein Basis-Struct (`SimulationObject`) als erstes Element in abgeleitete Structs (`GenericVehicle`, `Car`) einbetten, können wir Pointer sicher destruktiv casten. Jedes Objekt dass eine dieser Klassen erbt, muss diese an erster Stelle in seinem Struct platzieren, sodass der Pointer auf dieses Objekt zu einem Pointer auf `SimulationObject` (oder dann erweitert gecastet auf `GenericVehicle`) zerfällt. Das Grunprinzip lässt sich so veranschaulichen:
  ```c
  // Die "Basisklasse" für alle Objekte in der Simulation
  struct SimulationObject {
      int id;
      SimulationTickFunction tick;
      enum ObjectType type;
  };

  // Die abstrakte "Fahrzeugklasse", die von SimulationObject erbt
  struct GenericVehicle {
      SimulationObject base;    // MUSS das erste Element sein!
      GenericVehicle *p_next;   // Verkettete Liste
      uint32_t created_at_tick;
      // ... weitere allgemeine Fahrzeug-Eigenschaften
  };
  ```
  In der Anwendung sieht das dann so aus: 
    ```c
      void foo(){
        // Wir erstellen ein konkretes Auto
        Car* my_car = car_create(current_tick, max_parking_time, 1);

        // Beispiel A: Cast zu GenericVehicle (z.B. zur Verkettung, Datenstrukturen bearbeiten, etc.)
        // Die Queue akzeptiert alle Arten von Fahrzeugen, nicht nur Autos.
        GenericVehicle* vehicle_ptr = (GenericVehicle*) my_car;
        Queue_enqueue(my_queue, vehicle_ptr);
  
        // Beispiel B: Cast zu SimulationObject (z.b. für das Tick-System)
        // Die Simulation ruft nur SimulationObjects auf.
        SimulationObject* sim_obj_ptr = (SimulationObject*) my_car;
        
        // Führt indirekt "car_tick()" aus, da der Function-Pointer
        // bei der Initialisierung im Basis-Objekt hinterlegt wurde. Somit
        // lässt sich für jeden typen ein anderes Verhalten festlegen,
        // ohne gebrauch von mehreren Listen/Arrays zu machen.
        tick(sim_obj_ptr, current_tick);
      };
    ```
* **Erweiterbarkeit (Open/Closed Principle):** Die `Queue`- und `Parkhaus`-Logik arbeitet nur mit `GenericVehicle`-Pointern. Sollen später Motorräder oder Elektroautos simuliert werden, können neue Structs implementiert werden, ohne den Code für die Warteschlange ändern zu müssen. `SimulationObject` traägt dabei ein Enum mit sich, welches den Typen dieses Objektes beschreibt. Somit kann später (falls nötig) eine Aussage gemacht werden, auf welchen Objekttypen wir arbeiten und erweiternd gecastet werden. Hier ist das Prinzip im Code veranschaulicht:
  ```c
  // 1. Das Enum für die Typen (in types.h)
  enum ObjectType {CAR, PARKHAUS, QUEUE /* später z.B. ELECTRIC_CAR */};

  // 2. Das Basis-Objekt merkt sich bei der Initialisierung seinen wahren Typ
  struct SimulationObject {
      int id;
      SimulationTickFunction tick;
      enum ObjectType type; // <-- Hier wird der Typ gespeichert
  };

  // 3. Die Queue-Schnittstelle (in Queue.h) arbeitet völlig unabhängig vom Typ
  int queue_enqueue(Queue *p_queue, GenericVehicle *p_vehicle);
  GenericVehicle *queue_dequeue(Queue *p_queue);

    // Fahrzeug verlässt die Warteschlange (Typ ist GenericVehicle*)
    GenericVehicle* next_vehicle = queue_dequeue(my_queue);
    
    if (next_vehicle != NULL) {
    // Welches Fahrzeug haben wir wirklich vor uns?
    if (next_vehicle->base.type == CAR) {
    Car* normal_car = (Car*) next_vehicle;
    // Parke in normaler Parklücke...
    
        } /* else if (next_vehicle->base.type == ELECTRIC_CAR) {
            ElectricCar* ev = (ElectricCar*) next_vehicle;
            // ev->charging_time auslesen und an Ladesäule schicken...
        } */
    }
  ```
* **Dynamische Speicherverwaltung (Queue):** Die Warteschlange vor dem Parkhaus wird, wie gefordert, als dynamisch allozierte verkettete Liste (Linked List) implementiert. Die Anforderungen in der Aufgabe verlangen von uns dass wir Linked-Lists verwenden, jedoch ist auch die effizienteste Datenstruktur (Für En- und Dequeue wird nur ein Schritt benötigt, womit der Algorithmus O(1) wird.), da ein großer Array bei dem Austreten von Fahrzeugen in der Mitte der Queue extrem Leistungsaufwendig wäre. Eine Technische Umsetzung in Form von C code sieht wie folgt aus:
  ```c
  // 1. Das Knoten-Element der Liste (in types.h)
  struct GenericVehicle {
      SimulationObject base;
      GenericVehicle *p_next;  // <-- Zeiger auf das nächste Fahrzeug in der Queue, vom Typ unabhängig
      ...
  };

  // 2. Die Queue als Verwalter der Liste (in types.h)
  struct Queue {
      SimulationObject base;
      uint16_t capacity;
      GenericVehicle *p_head; // <-- Ermöglicht O(1) Dequeue am Anfang
      GenericVehicle *p_tail; // <-- Ermöglicht O(1) Enqueue am Ende
      ...
  };
  // Neues Fahrzeug am Ende anlegen.
  // queue_enqueue(my_queue, new_car_ptr);
  p_queue->p_tail->p_next = p_vehicle;
  p_queue->p_tail = p_vehicle;
    
  // Erstes Fahrzeug aus der Queue entfernen.
  // GenericVehicle* next_in_line = queue_dequeue(my_queue);
  GenericVehicle* out = p_queue->p_head;
  p_queue->p_head = out->p_next;
    
  /* Effizientes Löschen in der Mitte der Schlange
  * Ein Array müsste hier alle Elemente aufrücken lassen.
  * Die Linked List biegt intern nur den p_next des Vorgängers um.
  * Das lohnt sich vor allem in den Fällen extrem, in dem die Einstellung
  * QueueLeavable auf LEAVABLE gesetzt ist und Autos in dem tick, in dem Sie ihre
  * max. Verweilzeit (Parkzeit) erreicht haben, entfernt werden.
  */
  queue_remove(my_queue, ungeduldiges_auto);
  ```  
## 5. Funktionsprototypen und Aufteilung (zu Punkt e)
Die Funktionsprototypen (siehe Header-Dateien) spiegeln unsere modulare Denkweise wider.
* Jede Funktion hat genau *eine* Aufgabe (Single Responsibility Principle). Beispielsweise kümmert sich `Queue_add_random_vehicle` nur um das Einfügen, während das Vorrücken der Schlange von einer eigenen Update-/Tick-Routine gehandhabt wird.
* Wir nutzen einheitliche Namenskonventionen (z.B. Präfixe wie `Parkhaus_...` oder `Queue_...`), die in C als eine Art "Namespace" fungieren. Das macht sofort ersichtlich, zu welchem Modul (welchem Struct) eine Funktion "gehört", wodurch der Code stark an Lesbarkeit gewinnt und Namenskonflikte vermieden werden.