# Baktorium – Planungsdokument v0.1

> Arbeitsstand: **Planungsphase / dialogische Kalibrierung**\
> Zielgruppe: **Codex als Umsetzungsplattform, Claude Code als Review-/Architekturwächter, ChatGPT/Lyra als Konzept- und Systemkritik**\
> Status: **nicht final** – dieses Dokument soll als Ausgangspunkt für Gegenprüfung, Ergänzung und Konsensbildung dienen.

---

## 1. Ausgangslage und Reset-Grund

Der bisherige Baktorio-/Vectorio-Ansatz soll bewusst **nicht weiter repariert**, sondern als Lernmaterial ausgewertet werden.

Der Hauptgrund für den Reset:

- Der visuelle und biologische Anspruch wurde zu früh zu hoch gesetzt.
- Das Modell lief in Richtung komplexer Zell-/Körperästhetik, bevor die emergente Simulationsbasis stabil war.
- Die geplante zelluläre Ontologie wurde sofort mit organischer Darstellung, Rundkörpern, Innenraumlogik und komplexem Körperbau vermischt.
- Dadurch droht wieder das bekannte Muster: **zu viel Konzept, zu früh zu viel Architekturgewicht, zu wenig testbare Emergenz im Kern.**

Der Neustart soll daher auf einer klareren Prämisse beruhen:

> **Erst eine simple, diskrete, deterministische, testbare Hex-Zell-Simulation. Dann schrittweise emergente Tiefe. Grafik bleibt zunächst funktional.**

Nicht Ziel des Neustarts:

- keine Reparatur des alten Baktorio-Codes
- keine Übernahme des alten Hull-and-Fluid-Körpermodells als Inhalt
- keine frühe organische High-End-Grafik
- keine Bewegung, Sicht, Kampf, Verdauung oder komplexe Mutation in Slice 1
- keine riesige Architekturreform nach wenigen Tagen, weil der Anfang zu unklar gebaut wurde

---

## 2. Projektübergreifende Learnings aus den drei Repos

### 2.1 Aus Baktorio übernehmen

Baktorio hatte trotz inhaltlicher Überkomplexität mehrere sehr gute Grundregeln:

```text
Genome -> BodyBlueprint -> RuntimeState -> Renderer
```

Übertragbare Prinzipien:

- **Daten sind Wahrheit; Renderer sind Projektion.**
- Organismusvariation darf nicht im Renderer entstehen.
- UI, Debug und Szenen dürfen keine Simulationsregeln erzeugen.
- Konfigurationswerte sollen als Godot-Resources editierbar sein.
- Deterministische Seeds sind zentral für Review und Regressionstests.
- Ein Body-/Organismus-Lab als frühes Review-Werkzeug ist sinnvoll.
- Validierungsskripte sind wertvoll, bevor man große Features baut.
- Dokumente wie `AGENTS.md`, `ARCHITEKTUR.md`, `STATUS.md`, `NEXT_STEPS.md` und `DECISIONS.md` geben den Agenten Orientierung.

Was nicht übernommen werden sollte:

- das alte Hull-and-Fluid-Modell als Startpunkt
- frühe organische Fluid-/Innenraumdarstellung
- frühe Shader-/Antialiasing-Fokussierung
- zu schnelle biologische Spezialisierung vor der Simulationsbasis

### 2.2 Aus Graviton übernehmen

Graviton zeigt die stärkste Architekturdisziplin:

```text
core -> sim -> runtime -> scenes/tools
```

Übertragbare Prinzipien:

- Simulationszustand ist nie `Node.position` oder View-State.
- Renderkoordinaten sind abgeleitet.
- Szenen sind Composition Root und Projektion, nicht Logikquelle.
- Services haben klare Zuständigkeiten.
- Autoloads sind streng begrenzt.
- Performance-Diagnostik lebt außerhalb der autoritativen Sim-Schicht.
- Debug-/Perf-Counter sind read-only Signale, keine Steuerlogik.
- Tests und Headless-Checks sind Gates, nicht Dekoration.

Warnung aus Graviton:

- Dokumentation kann sehr stark wachsen.
- Für ein neues kleines Projekt muss die Doku **kanonisch, kurz und aktiv gepflegt** bleiben.
- Große historische Doku darf nicht zur zweiten Wahrheit werden.

### 2.3 Aus Calibration Orchestrator übernehmen

Der Orchestrator ist das stärkste Beispiel für Agentenarbeit, Quality-Gates und Slicing.

Übertragbare Prinzipien:

- Vor Änderungen: Ziel, Schicht, Risiken, Validierungspfad nennen.
- Änderungen werden **so groß wie möglich, so klein wie nötig** geschnitten.
- Quality entsteht nicht durch lange Antworten, sondern durch Evidenz, Risiken, Validierung und Delta-Verarbeitung.
- Claude-Findings müssen sichtbar verarbeitet werden.
- Bei Architekturzweifeln zuerst Planartefakt, dann Code.
- Keine Auto-Commits, Auto-Pushes oder Scope-Erweiterungen ohne explizite Freigabe.
- Commit-Vorschlag nach jeder commitfähigen Änderung ist Pflicht.

Für Baktorio-Neustart besonders wichtig:

> Das Projekt braucht kein schweres Orchestrator-System im Repo, aber es braucht dessen Arbeitsvertrag: klare Startprotokolle, Review-Gates, Doku-Sync, Commit-Vorschläge und Slice-Disziplin.

---

## 3. Kernentscheidung für den Neustart

### 3.1 Hexagons statt rund oder quadratisch

Neue Basis:

- Eine Zelle ist ein **Hexagon**.
- Ein Bakterium/Organismus ist ein **zusammenhängender Verbund von Hex-Zellen**.
- Zellen liegen direkt aneinander; keine schwebenden Abstände.
- Hex-Adjazenz ist die Grundlage für Wachstum, Kontakt, spätere Kollision, Schaden und Körperform.

Empfohlene Koordinatenbasis:

```text
Axial Coordinates: q, r
Optional abgeleitet: cube x, y, z für Distanz/Rotation
```

Standard-Nachbarn axial:

```text
(+1,  0)
(+1, -1)
( 0, -1)
(-1,  0)
(-1, +1)
( 0, +1)
```

Empfohlene Renderprojektion für pointy-top Hexes:

```text
x = hex_size * sqrt(3) * (q + r / 2)
y = hex_size * 1.5 * r
```

Diese Entscheidung ist stark, weil sie spätere Logik vereinfacht:

- Körperzusammenhang per BFS/DFS prüfbar
- Wachstum nur an freien Nachbar-Hexes
- Kontaktflächen klar bestimmbar
- Kollision später diskret und robust
- Zellfunktionen bleiben räumlich lesbar
- keine frühe Softbody-/Polygon-Komplexität nötig

---

## 4. Erste Simulationsidee – bewusst klein

### 4.1 Ontologie

Grundbegriffe:

- **CellBlock**: eine einzelne Hex-Zelle mit Funktion, Zustand, Integrität und lokalem Koordinatenplatz.
- **Organism**: zusammenhängende Menge von CellBlocks mit gemeinsamem Genom und Energiehaushalt.
- **Genome**: kleiner Satz vererbbarer Parameter, der Wachstum, Zellgewichtung und spätere Spezialisierung beeinflusst.
- **WorldGrid**: globale Belegungsstruktur für Hex-Koordinaten.
- **SimulationWorld**: autoritativer Zustand der Organismen, Zellen, Energie und Ticks.
- **RendererSnapshot**: read-only Projektion für Darstellung.

### 4.2 Grundlegende Zellfunktionen

Start nur mit Basiszellen:

| Zelltyp          | Zweck in Slice 1             | Verhalten                                    |
| ---------------- | ---------------------------- | -------------------------------------------- |
| `CORE`           | Identität / Koordination     | Pflichtzelle; keine komplexe Steuerung       |
| `ENERGY_CORE`    | Energiespeicher / Verteilung | speichert globale Organismusenergie          |
| `PHOTOSYNTHESIS` | Energiegewinnung             | erzeugt Energie pro Tick, wenn exponiert     |
| `REPRODUCTION`   | Wachstum / Zellteilung       | kann bei genug Energie neue Zelle anfügen    |
| `WALL`           | Schutz / Außenabschluss      | zunächst nur Struktur/Integrität, kein Kampf |

Wichtig: Auch wenn diese Begriffe biologisch wirken, bleiben sie im Start technisch minimal.

### 4.3 Noch nicht einführen

Nicht in den ersten Slices:

- Bewegung
- Augen/Sichtkegel
- Dornen/Spitzen
- Münder
- Verdauung
- Kampf
- Schaden
- Fressen
- Populationen mit Konkurrenzdruck
- Mutation/Vererbung über Generationen
- komplexe Organellen
- Flüssigkeit/Innenraumphysik
- Shader-/High-End-Grafik

---

## 5. Empfohlene Architektur

### 5.1 Schichtmodell

Empfohlene Pipeline:

```text
core -> config -> genetics -> cells/body -> sim -> runtime/snapshots -> rendering -> ui/debug/scenes
```

Bedeutung:

| Schicht               | Verantwortung                                            |
| --------------------- | -------------------------------------------------------- |
| `core/`               | deterministische Hilfen, Hex-Math, RNG, kleine Utilities |
| `config/`             | Godot-Resources für Tuning und Inspector-Parameter       |
| `genetics/`           | Genome, GeneSchema, GenomeFactory                        |
| `cells/` oder `body/` | Zelltypen, Körperstruktur, lokale Zelltopologie          |
| `sim/`                | autoritative Simulation: Energie, Wachstum, Grid, Tick   |
| `runtime/`            | Snapshots, Runner, abgeleitete Lesemodelle               |
| `rendering/`          | reine Darstellung aus Snapshots / State                  |
| `ui/`                 | Bedienung, Inspector, Debug-Menüs                        |
| `debug/`              | Diagnose-Overlays, Logs, Validierungsanzeigen            |
| `scenes/`             | Composition Root, keine Simulationsregeln                |
| `tools/`              | Headless-Validierung, Test-/Debug-Skripte                |
| `docs/`               | Projektvertrag, Architektur, Status, Entscheidungen      |

### 5.2 Harte Architekturregeln

- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Kein `Node.position` als Simulationswahrheit.
- Keine zweite Wahrheit für Zellen, Energie oder Organismusstatus.
- Renderer lesen nur State/Snapshot/Config, erzeugen aber keine Regeln.
- UI darf Testinputs setzen, aber keine Körperregeln definieren.
- Config-Resources dürfen Parameter speichern, aber keine Runtime-Wahrheit.
- Debug-Code darf read-only messen und anzeigen, aber nichts entscheiden.
- Keine Manager-Gottklasse.
- Neue Zelltypen, Gene oder Systemregeln brauchen einen Eintrag in `docs/DECISIONS.md`, wenn sie die Architektur erweitern.

### 5.3 Simulationswahrheit sauber trennen

Empfohlene Autoritäten:

| Thema                 | Autoritative Quelle                                           |
| --------------------- | ------------------------------------------------------------- |
| Hex-Math              | `core/hex/*`                                                  |
| Tuningwerte           | `config/*.gd` + `.tres` Resources                             |
| Genomwerte            | `genetics/genome.gd`                                          |
| lokale Körperstruktur | `body/organism_body.gd` oder `cells/cell_block_state.gd`      |
| globale Zellbelegung  | `sim/world_grid.gd`                                           |
| Energie/Wachstum      | `sim/energy_system.gd`, `sim/growth_system.gd`                |
| Tick-Orchestrierung   | `sim/simulation_world.gd` oder `runtime/simulation_runner.gd` |
| Darstellung           | `rendering/hex_cell_renderer.gd`                              |

Wichtig: `WorldGrid` und `OrganismState` dürfen sich nicht widersprechen. Eine robuste Regel wäre:

- `OrganismState` hält die lokale Körperstruktur.
- `WorldGrid` hält globale Occupancy als Index/Autorität für Weltbelegung.
- Jede Zellplatzierung läuft über eine Sim-Methode, die beide Strukturen atomar aktualisiert und validiert.

---

## 6. Konkreter Dateivorschlag für den Neustart

Startstruktur:

```text
AGENTS.md
README.md
project.godot

config/
  simulation_config.gd
  growth_config.gd
  render_config.gd
  resources/
    simulation_config.tres
    growth_config.tres
    render_config.tres

core/
  rng/seeded_rng.gd
  hex/hex_coord.gd
  hex/hex_math.gd

 genetics/
  gene_schema.gd
  genome.gd
  genome_factory.gd

cells/
  cell_function.gd
  cell_block_state.gd
  cell_block_blueprint.gd

body/
  organism_blueprint.gd
  organism_state.gd
  organism_builder.gd
  body_validator.gd

sim/
  world_grid.gd
  simulation_world.gd
  energy_system.gd
  growth_system.gd

runtime/
  simulation_runner.gd
  world_snapshot.gd

rendering/
  hex_cell_renderer.gd
  organism_color_palette.gd

ui/
  sim_lab_panel.gd
  organism_inspector.gd

debug/
  debug_overlay.gd
  debug_counters.gd

scenes/
  sim_lab.tscn

tools/
  validate_hex_foundation.gd

docs/
  ARCHITEKTUR.md
  CELL_SYSTEM.md
  STATUS.md
  NEXT_STEPS.md
  DECISIONS.md
  BUGS.md
```

Hinweis zur Doku: `BUGS.md` sollte nicht zum Tagebuch werden. Nur offene, reproduzierbare Fehler mit Status, Repro-Schritten und nächstem Diagnosepunkt.

---

## 7. Dokumentationssystem – schlank, aber wirksam

### 7.1 Kanonische Dokumente

Empfohlene minimale Doku:

| Datei                 | Funktion                                              |
| --------------------- | ----------------------------------------------------- |
| `AGENTS.md`           | Arbeitsvertrag für Codex, Claude Code und GPT         |
| `README.md`           | Kurzstart, aktueller Projektzweck, wichtigste Befehle |
| `docs/ARCHITEKTUR.md` | normative Schichtregeln, Autoritäten, Verbote         |
| `docs/CELL_SYSTEM.md` | Zelltypen, Organismusmodell, Genomidee, Regeln        |
| `docs/STATUS.md`      | aktueller realer Stand, implementiert/offen/validiert |
| `docs/NEXT_STEPS.md`  | genau der nächste sinnvolle Arbeitsblock              |
| `docs/DECISIONS.md`   | ADRs für echte Richtungsentscheidungen                |
| `docs/BUGS.md`        | offene reproduzierbare Fehler und Diagnosepfade       |

Nicht empfohlen für den Start:

- zu viele historische Handoff-Dateien
- lange Konzeptarchive ohne klare Autorität
- mehrere Statusquellen
- ein riesiges `HANDOFF.md`, das `STATUS.md` und `NEXT_STEPS.md` dupliziert

Falls ein Handoff gebraucht wird:

- `HANDOFF.md` nur als erzeugte Übergabe verwenden
- nicht als kanonische Wahrheit
- Inhalt aus `STATUS.md`, `NEXT_STEPS.md` und `DECISIONS.md` ableiten

### 7.2 Priorität bei Widersprüchen

Wenn Dokumente widersprechen:

1. `docs/ARCHITEKTUR.md` gewinnt für Schichten, Autoritäten, Verbote.
2. `docs/DECISIONS.md` gewinnt für Architekturentscheidungen.
3. `docs/STATUS.md` gewinnt für aktuellen realen Implementierungsstand.
4. `docs/NEXT_STEPS.md` gewinnt für den nächsten Arbeitsblock.
5. `README.md` ist Orientierung, nicht Detailautorität.
6. Ältere Notizen/Handoffs sind Hintergrund, keine Wahrheit.

---

## 8. AGENTS.md – empfohlener Arbeitsvertrag

Folgende Regeln sollten direkt in `AGENTS.md` übernommen oder angepasst werden.

### Startprotokoll

Vor jeder nicht-trivialen Codeänderung:

1. `git status --short --branch` prüfen.
2. `AGENTS.md` und relevante Doku lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder Plan-Doku aktualisieren.
6. Bestehende uncommitted Änderungen nicht überschreiben.

### Slice-Regel

Änderungen sollen:

> **so groß wie möglich, so klein wie nötig** sein.

Groß genug heißt:

- zusammenhängende Änderungen mit demselben Ziel bündeln
- vermeidbare Mikro-Slices reduzieren
- Kontextverbrauch und redundante Review-Schleifen vermeiden

Klein genug heißt:

- Reviewbarkeit bleibt erhalten
- Tests bleiben gezielt möglich
- Architekturgrenzen bleiben klar
- Rückrollbarkeit bleibt möglich
- unabhängige UI-, Sim-, Render- oder Docs-Themen werden nicht künstlich vermischt

### Abschluss nach Codeänderungen

Am Ende jeder commitfähigen Änderung liefern:

- Ziel des Slices
- geänderte Dateien
- betroffene Schichten
- Tests / Validierung
- Doku-Sync oder Begründung, warum keine Doku geändert wurde
- offene Risiken
- konkrete Punkte für Claude-Code-Review
- Commit-Vorschlag mit Titel und Beschreibung

Commit-Titel bevorzugt:

```text
feat(scope): ...
fix(scope): ...
perf(scope): ...
docs(scope): ...
test(scope): ...
refactor(scope): ...
chore(scope): ...
```

Beispiel:

```text
Commit-Vorschlag:
feat(hex): add deterministic axial grid foundation

Beschreibung:
- Adds axial hex coordinate helpers and deterministic seeded organism placement.
- Introduces initial config resources for simulation and rendering.
- Adds headless validation for contiguity and stable seed output.
- Updates architecture/status docs for the new foundation slice.
```

Kein Agent committed, pusht oder öffnet PRs ohne explizite Freigabe.

---

## 9. Empfohlene Slices

### Slice 0 – Repo- und Doku-Fundament

Ziel:

- neues Godot-Projekt aufsetzen
- Ordnerstruktur anlegen
- kanonische Doku anlegen
- `AGENTS.md` mit Arbeitsvertrag einführen
- minimal lauffähige Szene ohne Simulationskomplexität

Akzeptanz:

- Projekt öffnet in Godot
- Startszene lädt
- Doku ist konsistent
- kein Feature-Overreach

### Slice 1 – Hex Foundation + ein statischer Organismus

Ziel:

- Axial-Hex-Koordinaten
- Hex-Nachbarn
- lokale Organismus-Zellen
- ein deterministisch erzeugter Organismus
- einfache farbige Hex-Darstellung

Akzeptanz:

- gleicher Seed erzeugt denselben Organismus
- alle Zellen sind zusammenhängend
- keine Zelle schwebt frei
- Renderer erzeugt keine Simulationsentscheidungen
- Headless-Validator prüft Seed-Stabilität und Contiguity

### Slice 2 – Energie v0

Ziel:

- Photosynthesezellen erzeugen Energie
- Energy-Core speichert Energie
- Energiefluss bleibt organism-level, nicht lokal komplex

Akzeptanz:

- Energie steigt deterministisch pro Tick
- Config-Werte sind im Inspector editierbar
- kein Wachstum, keine Bewegung, kein Kampf

### Slice 3 – Wachstum v0 durch Reproduction Cell

Ziel:

- Reproduction-Zelle kann bei genug Energie neue Zelle anfügen
- Wachstum nur an freien Nachbar-Hexes
- Kosten werden von Energie abgezogen

Akzeptanz:

- neue Zelle ist adjacent zu bestehendem Körper
- Organismus bleibt zusammenhängend
- WorldGrid verhindert Doppelbelegung
- Wachstum ist deterministisch bei gleichem Seed

### Slice 4 – Genome v0 beeinflusst Wachstum

Ziel:

- Genomwerte beeinflussen Zelltyp-Gewichtung und Wachstumsrichtung
- noch keine echte Mutation/Vererbung

Akzeptanz:

- mehrere Seeds erzeugen unterscheidbare, aber valide Körper
- Genomwerte erscheinen im Inspector
- Regeln bleiben in `genetics/`, `body/` und `sim/`, nicht im Renderer

### Erst danach prüfen

- Populationen
- Bewegung
- Sicht
- Dornen/Kampf
- Verdauung/Mund
- Reproduktion mit Nachkommen
- Mutation und Vererbung
- Performance-Optimierung für viele Organismen
- chunked rendering / MultiMesh / TileMapLayer

---

## 10. Genom-Idee v0

Für den Start soll das Genom keine mystische Komplexität tragen, sondern nur steuerbare Gewichtungen.

Mögliche v0-Gene:

| Gen                   | Wertebereich | Wirkung                                              |
| --------------------- | ------------ | ---------------------------------------------------- |
| `photosynthesis_bias` | 0..1         | Wahrscheinlichkeit/Präferenz für Photosynthesezellen |
| `wall_bias`           | 0..1         | Tendenz zu stärkerer Außenwand                       |
| `growth_spread`       | 0..1         | kompakter vs. ausgreifender Körper                   |
| `core_reserve`        | 0..1         | Energiepuffer vor Wachstum                           |
| `reproduction_bias`   | 0..1         | wie früh Wachstum ausgelöst wird                     |
| `symmetry_bias`       | 0..1         | Wachstumsrichtung geordneter vs. zufälliger          |

Wichtig:

- Genom beeinflusst Wahrscheinlichkeiten und Schwellen.
- Genom entscheidet nicht direkt in der Darstellung.
- Renderer kann Genomfarben höchstens über abgeleitete Palette/Snapshot lesen.
- Mutation kommt später.

---

## 11. Rendering-Strategie

### Start bewusst simpel

Für Slice 1:

- ein `HexCellRenderer` als `Node2D`
- zeichnet Hex-Polygone aus Snapshot/State
- Zelltypen über einfache Farben
- optional dünne Linien für Zellgrenzen
- Debug-Overlay für Koordinaten, Organismus-ID, Zelltyp

Noch nicht:

- Shader
- organische Verformung
- Antialiasing-Perfektion
- Fluid-/Membran-Effekte
- pro Zelle eigene Nodes bei größerer Zellzahl

### Performance-Richtung

Langfristige Renderstrategie:

1. Start: ein Node zeichnet alle sichtbaren Hexes.
2. Bei mehr Zellen: Dirty-Set und Chunk-Renderer.
3. Bei sehr vielen Zellen: MultiMesh2D oder TileMapLayer prüfen.
4. Debug-Overlays immer hinter Flags.
5. Keine Renderoptimierung darf Sim-Wahrheit verändern.

### Addons / Godot-Assets

Vorläufige Regel:

- Addons nur als bewusstes Tool, nicht als frühe Ablenkung.
- DebugMenu kann sinnvoll sein für FPS/Counter.
- Antialiased lines/polygons erst nach stabilem Minimalrenderer prüfen.
- Shader-/AssetLib-Spikes nur als eigener Render-Spike, nicht im Sim-Fundament.

---

## 12. Performance-Prinzipien von Anfang an

- Fixed Timestep für Simulation.
- Rendering von Simulation entkoppeln.
- Keine teuren Scans pro Frame, wenn ein Tick oder Event reicht.
- Hex-Adjazenz über Dictionaries/Sets, nicht über Physics-Abfragen.
- Organismus-Contiguity nur bei Wachstum/Änderung prüfen, nicht blind jedes Frame.
- Renderer nur `queue_redraw()` bei relevanter Änderung.
- Debug-Text, Koordinatenlabels und Overlays nur aktiv, wenn Debug-Flag gesetzt ist.
- Performance-Counter read-only aus Sim/Runtime; Sampling außerhalb der Sim-Schicht.
- Keine Node-Flut pro Zelle als endgültige Architektur einplanen.

---

## 13. Erste Validierungsskripte

Empfohlenes Tool:

```text
godot_console.exe --headless --path . --script res://tools/validate_hex_foundation.gd
```

Validator sollte prüfen:

- axial neighbor count = 6
- axial distance korrekt
- seed deterministisch
- initial organism contiguous
- keine duplicate Hex-Koordinate
- jede Zelle hat gültigen Zelltyp
- Pflichtzellen existieren
- Renderer liest keine Genome direkt
- Config-Resources werden nicht zur Laufzeit mutiert

Später ergänzen:

- Energie-Tick deterministisch
- Wachstum bleibt contiguous
- WorldGrid verhindert Doppelbelegung
- Wachstumskosten werden korrekt abgezogen
- Debug-Overlay verändert keinen Sim-State

---

## 14. Risiken und Gegenmaßnahmen

| Risiko                                         | Gegenmaßnahme                                                |
| ---------------------------------------------- | ------------------------------------------------------------ |
| Grafik wird wieder zu früh Hauptthema          | Render-Slices strikt nach Sim-Fundament                      |
| Hex-System wird zu abstrakt                    | frühes Sim-Lab mit sichtbaren Zelltypen                      |
| Doku wächst wie Graviton/Orchestrator          | nur wenige kanonische Docs; alte Notizen archivieren         |
| Zu viele Mikro-Slices                          | Slice-Regel „groß möglich, klein nötig“ in AGENTS.md         |
| Zu frühe biologische Komplexität               | harte Nicht-Ziele bis Slice 4                                |
| Renderer wird heimliche Logikquelle            | Architekturregel + Review-Checklist                          |
| WorldGrid und OrganismState widersprechen sich | atomare Sim-Methoden für Zellplatzierung                     |
| Performance kippt bei Zellmengen               | Datenorientierung, Snapshots, Dirty-Rendering, später Chunks |
| Agenten bauen am Scope vorbei                  | Startprotokoll, Review-Handover, Commit-Vorschlag, Doku-Sync |

---

## 15. Claude-Code-Review-Fokus

Claude Code sollte bei Plänen und Implementierungen besonders prüfen:

- Gibt es Simulationslogik in Szenen, UI, Debug oder Renderer?
- Gibt es eine zweite Wahrheit für Zellen, Energie oder Grid-Belegung?
- Ist die Hex-Topologie deterministisch und testbar?
- Sind Config-Werte im Inspector editierbar, ohne Runtime-State in Configs zu schreiben?
- Wurde der Scope erweitert?
- Wurde Doku aktualisiert oder bewusst nicht aktualisiert?
- Gibt es Headless-Validierung?
- Ist der Slice wirklich zusammenhängend und nicht künstlich zu klein oder zu groß?
- Gibt es einen Commit-Vorschlag?

---

## 16. Codex-Erstauftrag – Vorschlag

Möglicher erster Auftrag an Codex:

```text
Bitte setze für den Baktorio-Neustart nur Slice 0 um: Repo- und Doku-Fundament.

Ziel:
- Neues Godot-Projekt-Fundament mit klarer Ordnerstruktur anlegen.
- AGENTS.md, README.md und docs/ARCHITEKTUR.md, CELL_SYSTEM.md, STATUS.md, NEXT_STEPS.md, DECISIONS.md, BUGS.md erstellen.
- Noch keine echte Simulation implementieren.
- Startszene darf nur minimal laden und den Projektstatus anzeigen.

Arbeitsregeln:
- Lies dieses Planungsdokument vollständig.
- Arbeite nach dem AGENTS.md-Vertrag, den du selbst anlegst.
- Keine Bewegung, keine Population, keine Mutation, keine Grafik-Politur.
- Architektur soll langfristig sauber, aber nicht überabstrakt sein.
- Änderungen so groß wie möglich und so klein wie nötig schneiden.

Validierung:
- Projekt muss in Godot öffnen.
- Startszene muss laden.
- Doku darf sich nicht widersprechen.
- Abschluss mit geänderten Dateien, Validierung, Risiken und Commit-Vorschlag.
```

Nach Slice 0 erst gegenprüfen lassen. Danach Slice 1: Hex Foundation.

---

## 17. Aktueller Konsensvorschlag

Vorläufige Leitentscheidung:

> Der Neustart sollte nicht versuchen, sofort „lebendige Zellen“ schön darzustellen. Er sollte zuerst beweisen, dass ein Organismus als deterministischer Hex-Zellkörper existieren, Energie erzeugen und später kontrolliert wachsen kann – sauber getrennt, konfigurierbar, validierbar und für Agenten gut führbar.

Minimaler erster Meilenstein:

```text
Ein einzelner statischer Hex-Organismus aus Basiszellen,
der deterministisch aus Seed/Config entsteht,
zusammenhängend ist,
einfach gerendert wird
und headless validiert werden kann.
```

Das ist klein genug, um nicht wieder im Anspruch zu ertrinken – und stark genug, um später echte Emergenz zu tragen.

