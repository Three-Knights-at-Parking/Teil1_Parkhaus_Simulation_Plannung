# Parkhaus Rauenegg – Simulation (Teil I: Programmentwurf)

> **Kurs:** Programmieren 1 (TSA-TSL25, Embedded Systems)  
> **Abgabe:** Teil I – Programmentwurf / Design-Dokumentation  
> **Sprache:** C 
---
## Projektbeschreibung

Dieses Repository enthält den **Programmentwurf** (Teil I) für eine diskrete Parkhaus-Simulation
des fiktiven Parkhauses *Rauenegg*. Ziel ist **nicht** ein lauffähiges Programm, sondern ein
vollständiger, nachvollziehbarer Entwurf bestehend aus:

- Übersicht der zu erhebenden **Statistiken**
- Definition aller **Datentypen und Strukturen** (`struct`, `enum`)
- **Funktionsprototypen** mit dokumentierten Parametern und Rückgabewerten
- **Pseudocode** für alle zentralen Funktionen
- **Flussdiagramme** (mindestens 3 zentrale Funktionen)
---
## Ordnerstruktur

```text
Teil1_Parkhaus_Simulation_Plannung/
│
├── README.md                  ← Dieses Dokument (Projektübersicht, Struktur, Konventionen)
│
├── docs/                      ← Gesamte Entwurfs-Dokumentation
│   ├── statistiken.*       ← Übersicht aller Statistiken (pro Zeitschritt + Endsimulation)
│   ├── datenstrukturen.*     ← Beschreibung aller structs, enums, Typedefs mit Begründung
│   └── diagrams/              ← Flussdiagramme und sonstige Diagramme
│       ├── flowchart_main_loop
│       ├── flowchart_user_input
│       ├── flowchart_simulation_loop
│       ├── ...
│       └── exported/          ← Exportierte Bilder (PNG/SVG) der Diagramme
│           ├── flowchart_main_loop.png
│           ├── flowchart_user_input.png
│           ├── flowchart_simulation_loop.png
│           ├── ...
│           └── flowchart_data_handling.png
│
├── include/                   ← Header-Dateien (Schnittstellen / Prototypen)
│   ├── parkhaus.h             
│   ...
│
├── src/                       ← Pseudocode und Pseudoimplementierungen
│   ├── main.c                 ← Einstiegspunkt (Stub)
│   ├── parkhaus.c
│   ...
│
├── .gitignore                 ← Ignoriert Build-Artefakte, IDE-Ordner etc.
└── coding_conventions.md      ← Coding-Richtlinien
```
---
## Sonstiges

Ideen, Mindmaps und sonstiges sammeln wir in https://github.com/Three-Knights-at-Parking/Teil1_Documentation/tree/main. 
Dort liegen auch Transkripte/Zusammenfassungen unserer Meetings bei.