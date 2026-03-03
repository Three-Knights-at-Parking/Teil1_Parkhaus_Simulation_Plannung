# Übersicht der geplanten Statistiken (Parkhaus-Simulation)

Gemäß der Aufgabenstellung sollen Statistiken erhoben werden, um die Auslastung des Parkhauses und mögliche bauliche Erweiterungen bewerten zu können. Unser Programm sammelt dafür auf zwei Ebenen Daten: **Pro Zeitschritt (Tick)** für die Live-Auswertung und den zeitlichen Verlauf, sowie als **aggregierte Endauswertung (Summary)** über die gesamte Simulationsdauer.

---

## 1. Statistiken pro Zeitschritt (`StatsTick`)
In jedem Simulations-Tick wird ein "Snapshot" der aktuellen Lage erstellt. Diese Rohdaten dienen der Live-Ausgabe auf der Konsole und werden in eine CSV-Datei exportiert, um den zeitlichen Verlauf (z. B. Stoßzeiten) analysieren zu können.

### 1.1. Kapazität & Auslastung
* **`capacity_total`**: Gesamtkapazität des Parkhauses in diesem Tick.
* **`capacity_taken`**: Anzahl der belegten Stellplätze am Ende des Ticks.
* **`capacity_free`**: Anzahl der freien Stellplätze am Ende des Ticks.

### 1.2. Verkehrsfluss (Flow)
* **`arrivals_generated`**: Anzahl der Fahrzeuge, die in diesem Tick am Parkhaus angekommen sind (Demand).
* **`enqueued`**: Anzahl der Fahrzeuge, die sich in diesem Tick in die Warteschlange eingereiht haben.
* **`entered`**: Anzahl der Fahrzeuge, die in diesem Tick erfolgreich ins Parkhaus eingefahren sind.
* **`departed`**: Anzahl der Fahrzeuge, die das Parkhaus in diesem Tick verlassen haben.

### 1.3. Warteschlange (Queue)
* **`queue_length_end`**: Globale Länge der Warteschlange am Ende des Ticks.
* **`queue_rejections`**: Anzahl der Fahrzeuge, die abgewiesen wurden (z.B. weil die Schlange voll war). *Wichtiger Indikator für entgangene Kunden!*
* **`queue_wait_entered_sum_ticks`**: Summe der Wartezeiten aller Fahrzeuge, die in diesem Tick eingefahren sind (zur Berechnung der Durchschnitts-Wartezeit).
* **`queue_wait_entered_count`**: Anzahl der eingefahrenen Fahrzeuge zur Wartezeit-Auswertung.
* **`queue_wait_max_ticks_tick`**: Die maximale Wartezeit unter den Fahrzeugen, die in genau diesem Tick eingefahren sind.

### 1.4. Parkdauer
* **`parking_duration_departed_sum_ticks`**: Summe der Parkdauer aller Fahrzeuge, die in diesem Tick ausgefahren sind.
* **`parking_duration_departed_count`**: Anzahl der in diesem Tick ausgefahrenen Fahrzeuge.

### 1.5. Qualität & Blocker
* **`blocker_full_active`**: Zählt, wie oft ein Gate in diesem Tick blockiert war, weil das Parkhaus voll ist.
* **`bad_parking_cases`**: Anzahl der Fahrzeuge, die "schlecht geparkt" haben (nehmen mehr Platz ein als nötig).

---

## 2. Aggregierte Endauswertung (`StatsSummary`)
Am Ende der Simulation werden alle gesammelten `StatsTick`-Objekte ausgewertet, um eine finale Bilanz zu ziehen. Diese Werte sind entscheidend für die Beantwortung der Leitfrage: *"Muss das Parkhaus baulich erweitert werden?"*

### 2.1. Auslastungs-Analyse
* **Durchschnittliche Auslastung (`capacity_taken_percent_avg`)**: Die prozentuale Auslastung über die gesamte Zeit.
* **Spitzenauslastung (`capacity_taken_percent_peak`)**: Die höchste erreichte Auslastung in % inklusive des Ticks, an dem dies geschah (`capacity_taken_peak_tick`).
* **Vollauslastung (`full_ticks` & `first_full_tick`)**: Anzahl der Ticks, in denen das Parkhaus zu 100 % belegt war, sowie der Zeitpunkt, wann dies zum ersten Mal passierte.

### 2.2. Durchsatz-Bilanz
* **Gesamtzahlen (`arrivals_total`, `entered_total`, `departed_total`)**: Wie viele Fahrzeuge wurden insgesamt generiert, abgefertigt und haben das Parkhaus wieder verlassen.
* **Durchschnittlicher Fluss (`entered_per_tick_avg`, `departed_per_tick_avg`)**: Durchschnittliche Ein- und Ausfahrten pro Tick.

### 2.3. Warteschlangen-Analyse (Der Flaschenhals)
* **Durchschnittliche & Maximale Länge (`queue_length_avg`, `queue_length_peak`)**: Wie lang war die Schlange im Schnitt und im Extremfall?
* **Globale Abweisungen (`queue_rejections_total`)**: Summe **aller** abgewiesenen Fahrzeuge. Dies ist der stärkste Indikator für eine benötigte bauliche Erweiterung der Stellplätze oder der Gates.
* **Wartezeiten (`queue_wait_avg_ticks`, `queue_wait_max_ticks`)**: Durchschnittliche und maximale Wartezeit aller abgefertigten Fahrzeuge.
* **Warteschlangen-Aktivität (`queue_active_ratio_percent`)**: Anteil der Simulationszeit in %, in der sich überhaupt Autos in der Warteschlange befanden.

### 2.4. Parkdauer & Qualität
* **Durchschnittliche Parkdauer (`parking_duration_avg_ticks`)**: Wie lange bleibt ein Auto im Schnitt?
* **Blockade-Quote (`blocker_full_ratio_percent`)**: Prozentualer Anteil der Zeit, in der das Parkhaus keine neuen Fahrzeuge aufnehmen konnte.
* **Falschparker-Quote (`bad_parking_share_percent`)**: Einfluss der "Schlecht-Parker" auf die Gesamtkapazität.