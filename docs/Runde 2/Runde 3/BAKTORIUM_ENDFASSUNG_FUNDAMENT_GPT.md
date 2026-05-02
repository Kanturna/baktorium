# Baktorium Foundation – Endfassung v1.0

> Status: **freigabefähiger Planungsanker für Slice 0**  
> Zweck: Fundament für ein neues Godot-Projekt legen, nicht alte Baktorio-/Vectorio-Inhalte reparieren.  
> Umsetzung: **Codex**  
> Review/Kalibrierung: **Claude Code + ChatGPT/Lyra**  
> Projektname: **Baktorium**

---

## 1. Kernentscheidung

Baktorium startet als **deterministische Hex-Zell-Simulation**.

Leitformel:

```text
Erst Hex-Zellkörper beweisen.
Dann Energie.
Dann Wachstum.
Dann Genom-Einfluss.
Erst danach Population, Bewegung, Mutation, Kampf, Verdauung oder Schönheit.
```

Der Neustart ist bewusst kein Versuch, sofort ein biologisch schönes oder organisch komplexes System zu bauen. Der erste Erfolg ist nicht Ästhetik, sondern **tragfähige Simulationswahrheit**.

---

## 2. Harte Grundsätze

### 2.1 Datenwahrheit

- Daten und Simulationszustand sind Wahrheit.
- Nodes, Renderer, UI, Debug und Szenen sind Projektion.
- Keine Simulationsentscheidung entsteht in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Kein `Node2D.position`, kein Polygon und kein UI-Label ist autoritativer Sim-State.

### 2.2 Slice-Disziplin

Änderungen sind:

```text
so groß wie möglich,
so klein wie nötig.
```

Das heißt:

- keine künstlichen Mikro-Slices, wenn ein zusammenhängender Arbeitsblock sauber testbar ist;
- keine großen Misch-Slices, wenn Architektur, Rendering, Sim und UI getrennt validiert werden müssen;
- jeder Slice hat klare Nicht-Ziele, Acceptance-Kriterien und Validierung.

### 2.3 Scope-Schutz

Bis inklusive Slice 4 nicht bauen:

- Bewegung
- Augen / Sensorik
- Dornen / Kampf
- Mund / Verdauung
- Kollision zwischen Organismen
- lokale Zellschäden
- echte Tochterorganismen
- Mutation und Vererbung
- Populationsevolution
- Save/Load
- Tag/Nacht-Zyklus
- Shader-/High-End-Grafik
- UI-Polish außerhalb des Labs

---

## 3. Finale Entscheidungen aus der Triade

### 3.1 Doku-Set

Finales kanonisches Set:

```text
AGENTS.md
README.md
docs/ARCHITEKTUR.md
docs/SIM_RULES.md
docs/DECISIONS.md
docs/STATUS.md
docs/NEXT_STEPS.md
docs/FINDINGS.md
docs/BAKTORIUM_FOUNDATION_v1.md
```

Entscheidung gegen `CELL_SYSTEM.md`:

- `SIM_RULES.md` ist breiter.
- Es umfasst Hex-Regeln, Zellfunktionen, Energie, Wachstum, Genom, Tick-Reihenfolge und Nicht-Ziele.
- Zellregeln werden dort als eigener Abschnitt geführt.

Entscheidung gegen separate `CLAUDE.md` in Slice 0:

- Claude-spezifische Reviewpunkte kommen in `AGENTS.md`.
- Eine eigene `CLAUDE.md` entsteht erst, wenn der Reviewprozess wirklich eigene Regeln braucht.

Entscheidung für `FINDINGS.md` statt `BUGS.md`:

- Findings können Bugs, Debug-Befunde, Review-Findings, Risiken und geplante Korrekturen enthalten.
- Nicht jeder Befund ist sofort ein Bug.

### 3.2 Autoloads

Slice 0 startet **ohne projekt-eigene Autoload-Pflicht**.

Regel:

- Die Lab-Szene ist zuerst Composition Root.
- Services werden explizit verdrahtet.
- `TimeService` kann ab Tick-/Energie-Slice per ADR eingeführt werden.
- Keine globale Registry ohne konkreten Bedarf.

### 3.3 Hex-Orientierung

- Simulationswahrheit ist axial `(q, r)`.
- Cube-Koordinaten werden nur abgeleitet.
- Pointy/flat ist Render-Konfiguration, nicht Sim-Wahrheit.
- Default im Lab: `pointy-top`, weil gut lesbar und Standardformeln verfügbar sind.
- Ein Wechsel der Orientierung darf keine Sim-Dateien verändern.

### 3.4 Weltmodell

- `WorldState` existiert früh als Container für Seed, Zeit und Organismen.
- Der Organismus nutzt lokale Hex-Koordinaten relativ zu seinem Ursprung.
- Kein globales Zell-`WorldGrid` in Slice 0 erzwingen.
- Ein echtes Occupancy-/Spatial-System kommt per eigenem Slice, sobald mehrere Organismen, Kollision, Tochterorganismen oder Weltbelegung relevant werden.

### 3.5 Zellfunktionen v0

Vier grundlegende Funktionen:

| Function Tag | Anzeige | Rolle |
|---|---|---|
| `core` | Energiekern | Pflichtzelle, Identität und globaler Energieanker |
| `photosynthesis` | Photosynthese | erzeugt Energie |
| `reproduction` | Vermehrung | erzeugt Wachstumsladung / Anbaupotenzial |
| `wall` | Zellwand | Struktur-/Schutzzelle, noch ohne HP-/Damage-System |

Nicht in v0:

- separate `energy_core` neben `core`
- `cytoplasm` / neutrale Füllzelle
- lokale Zellenergie
- lokale Zell-HP

`cytoplasm` kann später per ADR ergänzt werden, falls Startkörper und Wachstum mit nur vier Funktionen semantisch zu eng werden.

### 3.6 Energie

- Energie v0 ist ein globaler Organismuspool.
- `core` ist sichtbarer Anker dieses Pools.
- `photosynthesis` produziert in diesen Pool.
- `wall` und `reproduction` können Maintenance kosten.
- Keine lokale Diffusion, keine Zell-zu-Zell-Energieleitung in den ersten Slices.

### 3.7 Reproduktion

In der Foundation bedeutet `reproduction` nicht sofort Tochterorganismus.

Foundation-Bedeutung:

```text
reproduction = Wachstumsladung + Zell-Anbau am bestehenden Körper
```

Echte Tochterorganismen, Vererbung und Populationen kommen später als eigene Planartefakte.

---

## 4. Architektur

### 4.1 Schichtung

```text
ui / debug / scenes
  -> rendering
  -> runtime
  -> sim
  -> body / cells
  -> genetics
  -> config / core
```

Regel:

- Abhängigkeiten zeigen nur nach unten.
- `core` kennt keine Godot-Szenen und keine Sim-Domain.
- `sim` kennt keine UI und kein Rendering.
- `rendering` liest Snapshots, entscheidet aber nichts.
- `debug` misst und zeigt, steuert aber keinen Sim-State.

### 4.2 Verzeichnisstruktur

```text
project.godot
AGENTS.md
README.md

docs/
  ARCHITEKTUR.md
  SIM_RULES.md
  DECISIONS.md
  STATUS.md
  NEXT_STEPS.md
  FINDINGS.md
  BAKTORIUM_FOUNDATION_v1.md

src/
  core/
    hex_coord.gd
    hex_grid_math.gd
    seeded_rng.gd
    ids.gd

  config/
    simulation_config.gd
    hex_grid_config.gd
    cell_function_def.gd
    cell_function_catalog.gd
    genome_config.gd
    growth_config.gd
    render_config.gd
    lab_config.gd

  genetics/
    gene_schema.gd
    genome.gd
    genome_factory.gd
    genome_expression.gd

  cells/
    cell_block.gd
    cell_function.gd

  body/
    organism_body.gd
    body_topology.gd
    organism_builder.gd
    body_validator.gd

  sim/
    world_state.gd
    organism_state.gd
    simulation_service.gd
    energy_system.gd
    growth_system.gd

  runtime/
    world_snapshot.gd
    organism_snapshot.gd
    simulation_snapshot_cache.gd

  rendering/
    hex_cell_renderer.gd
    organism_palette.gd

  ui/
    lab/
      simulation_lab_panel.gd
      organism_inspector.gd

  debug/
    debug_overlay.gd
    debug_counters.gd
    perf_probe.gd

  tests/
    test_runner.gd
    core/
    genetics/
    body/
    sim/
    rendering/

scenes/
  lab/
    simulation_lab.tscn

resources/
  config/
    simulation_config.tres
    hex_grid_config.tres
    genome_config.tres
    growth_config.tres
    render_config.tres
    lab_config.tres

  cell_functions/
    core.tres
    photosynthesis.tres
    reproduction.tres
    wall.tres

  cell_function_catalog.tres

tools/
  validate_hex_foundation.gd
```

### 4.3 Autoritäten

| Thema | Autoritative Quelle |
|---|---|
| Hex-Math | `src/core/hex_coord.gd`, `src/core/hex_grid_math.gd` |
| RNG | `src/core/seeded_rng.gd` |
| Tuningwerte | `src/config/*` + `resources/config/*.tres` |
| Zellfunktion | `CellBlock.function_tag` + `CellFunctionCatalog` |
| Zellkörper | `src/body/organism_body.gd` |
| Topologie | `src/body/body_topology.gd` |
| Genom | `src/genetics/genome.gd` |
| Organismus-Energie | `src/sim/organism_state.gd` |
| Wachstumsladung | `src/sim/organism_state.gd` |
| Tick-Orchestrierung | `src/sim/simulation_service.gd` oder Lab-Composition-Root |
| Renderdaten | `src/runtime/*snapshot*` |

---

## 5. Domain-Modell v0

### 5.1 HexCoord

Kanonisch:

```text
(q, r)
```

Nachbarn:

```text
(+1,  0)
(+1, -1)
( 0, -1)
(-1,  0)
(-1, +1)
( 0, +1)
```

Invarianten:

- Jede Zelle belegt exakt eine lokale Hex-Koordinate.
- Kein Organismus hat doppelte lokale Koordinaten.
- Ein Organismus ist connected.
- Boundary ist abgeleitet: Eine Zelle ist Boundary, wenn mindestens ein Nachbarplatz im Organismus leer ist.

### 5.2 CellBlock

Eine Zelle ist Daten, kein Node.

Minimalfelder:

```text
cell_id
coord: HexCoord
function_tag: StringName
```

Später möglich:

```text
integrity
age_ticks
flags
```

Nicht v0:

- lokale Energie
- lokale HP
- eigene `_process()`-Logik
- eigene Godot-Node

### 5.3 OrganismBody

Verantwortung:

- Zell-Dictionary nach Hex-Key
- lokale Topologie
- Pflichtzellen
- Body-Validierung

Keine Verantwortung:

- Energie
- Wachstumsladung
- Tick
- Rendering

### 5.4 OrganismState

Verantwortung:

```text
energy
growth_charge
age_ticks
alive
```

`OrganismState` referenziert Body und Genome oder stabile IDs, aber erzeugt keine Topologie selbst.

### 5.5 Genome v0

Empfohlene Gene:

```text
photosynthesis_bias
wall_bias
reproduction_bias
compactness
surface_preference
energy_efficiency
symmetry_bias
mutation_rate_dormant
```

Regeln:

- normalisierte Werte oder klare Min/Max-Grenzen
- keine Mutation aktiv in den ersten Slices
- Genom beeinflusst zuerst Startkörper, später Wachstumsscore
- Renderer liest nicht direkt das Genom, sondern abgeleitete Snapshot-/Palette-Daten

---

## 6. Simulation v0

Tick-Reihenfolge ab Energie-/Growth-Slices:

1. Topologie ableiten oder dirty aktualisieren.
2. Photosyntheseenergie berechnen.
3. Maintenance-Kosten abziehen.
4. Wachstumsladung aktualisieren.
5. Wenn erlaubt: maximal konfigurierte Wachstumsevents ausführen.
6. Invarianten validieren.
7. Snapshot für Renderer/Debug aktualisieren.

Wachstum:

- Neue Zelle entsteht an einer freien Nachbarposition.
- Kandidaten kommen aus Frontier-Hexes.
- Score nutzt Genom, Zelltyp-Balance, Kompaktheit, Boundary/Surface und deterministischen RNG.
- Wachstum bleibt connected.
- Wachstum pro Tick ist begrenzt.

---

## 7. Config und Inspector

Alle wichtigen Tuningwerte laufen über Resources.

### 7.1 Config-Resources

`SimulationConfig`

- seed
- tick rate
- start paused
- max growth events per tick
- global sun intensity

`HexGridConfig`

- hex size
- render orientation
- debug coordinate labels

`CellFunctionDef`

- function id
- label
- base color
- energy production
- maintenance cost
- growth cost
- requires surface
- protection hint

`CellFunctionCatalog`

- erlaubte Zellfunktionen
- Pflichtfunktionen
- Feature-Gates

`GenomeConfig`

- gene schemas
- clamp/defaults

`GrowthConfig`

- growth threshold
- compactness weight
- surface weight
- balance weights

`RenderConfig`

- colors / outline
- show debug
- draw coordinates
- selected alpha

`LabConfig`

- review seed start/count
- auto tick speed
- initial body preset

### 7.2 Config-Regel

- UI darf Runtime-Kopien verändern.
- UI darf gespeicherte `.tres`-Assets nicht unbeabsichtigt mutieren.
- Sobald UI-Interaktion existiert, prüft ein Validator, ob Config-Assets stabil bleiben.

---

## 8. Godot Assets und Engine-Features

### 8.1 Asset-Policy

Keine Addons in Slice 0, außer es gibt einen klaren Slice-Nutzen.

Ein Asset darf aufgenommen werden, wenn es:

1. ein aktuelles Problem löst,
2. keine Simulationswahrheit einführt,
3. keine Architekturkopplung nach oben erzwingt,
4. möglichst MIT oder ähnlich unkompliziert lizenziert ist,
5. in `docs/DECISIONS.md` dokumentiert wird,
6. über eine Adapter-/Wrapper-Schicht angebunden werden kann, wenn es kritisch wird.

### 8.2 Sofort nutzen als Referenz, nicht als Addon

**Red Blob Games – Hexagonal Grids**

- Referenz für axial/cube Koordinaten, Nachbarn, Distanz, Ringe, Hex-to-Pixel und Pixel-to-Hex.
- Nicht kopieren als fremdes System, sondern als mathematische Leitquelle für eigene `core/hex`-Tests.

### 8.3 Empfohlene Addon-/Feature-Shortlist

#### A) Debug Menu – empfohlen ab erster echter Sim-Last

Einsatz:

- FPS
- Frametime
- CPU/GPU-Zeit
- Hardware-/Renderinfos
- Debug-Schalter

Phase:

```text
nicht Slice 0
prüfen ab Slice 2/3, spätestens vor Wachstum + Performance-Gates
```

Architekturregel:

- DebugMenu liest nur Counter und Flags.
- Es darf keine Sim-Entscheidungen treffen.

#### B) Antialiased Line2D / AntialiasedRegularPolygon2D – optional für schöne Hex-Outlines

Einsatz:

- schönere Umrisse
- selektierte Zellen
- Boundary-/Debug-Overlays
- später organischere Konturlinien

Phase:

```text
nicht Pflicht für Foundation
prüfen nach funktionalem _draw()-Renderer
```

Architekturregel:

- Nicht als Hotpath für tausende Zellkörper erzwingen.
- Zuerst `_draw()` baseline messen.

#### C) GUT – optionaler Testframework-Pfad

Foundation-Entscheidung:

- Slice 0 startet mit eigenem schlanken Test-Runner.
- GUT wird erst geprüft, wenn Tests umfangreicher werden oder CLI-/JUnit-/Editor-Komfort relevant wird.

Phase:

```text
nicht Slice 0
prüfen nach mehreren echten Testsuites
```

#### D) Phantom Camera – später für Camera UX

Einsatz:

- weiche Kamera
- Fokuswechsel
- Folgen von Organismen
- Zoom-/Pan-Komfort

Phase:

```text
nicht Foundation
prüfen, wenn Kamera/Navigation wirklich Thema wird
```

#### E) DsInspector / Runtime Inspector – nur optional für UI-Diagnose

Einsatz:

- Runtime-Inspektion von Szene/Nodes

Einschränkung:

- Baktoriums Sim-Wahrheit liegt nicht in Nodes.
- Darum nur für UI-/Scene-Debugging verwenden, nicht zur Sim-Diagnose.

Phase:

```text
später optional, nicht Foundation
```

### 8.4 Godot-Engine-Features ohne Addon

#### `_draw()` auf Node2D

Startpfad für den ersten Renderer:

- simpel
- durchschaubar
- leicht debugbar
- gut für 25–250 Zellen

#### MultiMeshInstance2D

Scale-Pfad, wenn viele Zellen sichtbar werden:

```text
_draw() -> chunked draw -> MultiMeshInstance2D
```

Nicht vorab einbauen. Erst bei gemessenem Bedarf.

#### TileMapLayer

Möglicher Pfad für:

- statisches Substrat
- Weltkarte
- Licht-/Nährstoff-Layer
- später globale Umwelt

Nicht für OrganismBody-v0 verwenden, weil der Organismus eine eigene dynamische Körperstruktur braucht.

---

## 9. Validierung

### 9.1 Headless Checks

Früh prüfen:

- axial neighbor count = 6
- axiale Distanz korrekt
- gleicher Seed erzeugt gleichen Körper
- Seed-Reihe erzeugt unterscheidbare Körper
- Organismus ist connected
- keine duplicate Hex-Koordinate
- jede Zelle hat bekannte Funktion
- Pflichtfunktionen existieren
- Boundary-Erkennung stimmt für bekannte Formen
- Renderer liest keine Genome direkt
- Config-Assets werden nicht zur Laufzeit mutiert

Später ergänzen:

- Energie-Tick deterministisch
- Energie bleibt endlich und im erlaubten Bereich
- Wachstum bleibt connected
- Wachstum erzeugt keine Doppelbelegung
- Wachstumskosten werden korrekt abgezogen
- Debug-Overlay verändert keinen Sim-State

### 9.2 Manueller Lab-Check

- Seed-Reihe durchklicken.
- Debug-Overlay an/aus.
- Tick/Pause/Reset testen.
- Inspector-Slider bewegen.
- Materiallesbarkeit prüfen.
- Wachstum nachvollziehbar beobachten.

---

## 10. Performance-Leitlinie

Von Anfang an:

- keine Node pro Zelle als Architektur
- Dictionary/Set-Zugriff nach Hex-Key
- fixed simulation tick
- Renderer liest Snapshots
- Debug-Overlay abschaltbar
- keine Full-Scans pro Frame, wenn Dirty/Event reicht
- Contiguity bei Änderung validieren, nicht blind jedes Frame

Erste Gates:

| Phase | Gate |
|---|---|
| Slice 1 | 1 Organismus mit 25–100 Zellen flüssig und lesbar |
| Slice 2 | 100 Zellen mit Energie-Bilanz stabil |
| Slice 3 | Wachstum bis 250 Zellen flüssig |
| vor mehreren Organismen | eigener Scale-Test |

---

## 11. Slice-Roadmap

### Slice 0 – Repo- und Doku-Fundament

Ziel:

- Agentenvertrag
- kanonische Doku
- Ordnerstruktur
- minimale Startszene
- Config-Resource-Skelette
- eigener Test-Runner-/Validator-Skeleton
- Asset-Policy dokumentieren

Umfang:

```text
AGENTS.md
README.md
docs/ARCHITEKTUR.md
docs/SIM_RULES.md
docs/DECISIONS.md
docs/STATUS.md
docs/NEXT_STEPS.md
docs/FINDINGS.md
docs/BAKTORIUM_FOUNDATION_v1.md
minimale scenes/lab/simulation_lab.tscn
```

Nicht anfangen:

- Hex-Simulation
- Energie
- Wachstum
- Population
- Render-Polish
- Addon-Import ohne ADR

Acceptance:

- Projekt öffnet.
- Startszene lädt.
- Doku widerspricht sich nicht.
- `NEXT_STEPS.md` definiert Slice 1.
- Headless-Test-/Validator-Skeleton läuft.

### Slice 1 – Hex Foundation + statischer Organismus + Lab-Visualisierung

Dieser Slice darf intern in Subschritte geteilt werden, bleibt aber ein zusammenhängender Foundation-Slice.

1A Hex-Kern:

- `HexCoord`
- Nachbarn
- Distanz
- axialer Key
- connectedness
- Boundary-Erkennung

1B statischer Organismus:

- deterministischer Startkörper
- vier Pflichtfunktionen
- Body-Validator
- Seed-Reproduzierbarkeit

1C Lab-Visualisierung:

- einfacher `_draw()` Hex-Renderer
- farbige Hexes
- Debug-Overlay für Koordinaten/Funktion/Boundary

Acceptance:

- gleicher Seed erzeugt gleiche Zellen
- Organismus ist connected
- keine duplicate Koordinaten
- Pflichtfunktionen existieren
- Renderer erzeugt keine Sim-Entscheidungen
- Headless-Validator läuft
- 25–100 Zellen flüssig und lesbar

### Slice 2 – Energie v0

Ziel:

- Photosynthese erzeugt Energie im Organismuspool.
- Maintenance-Kosten werden abgezogen.
- Energiebilanz ist sichtbar und deterministisch.

Acceptance:

- Energie-Tick deterministisch
- Inspector-Config wirkt
- keine lokale Energiephysik
- kein Wachstum
- keine NaN-/Infinity-Werte

### Slice 3 – Wachstum v0

Ziel:

- `reproduction` erzeugt Growth Charge.
- neue Zellen entstehen an Frontier-Hexes.
- Energie wird verbraucht.

Acceptance:

- Wachstum bleibt connected
- Wachstum pro Tick begrenzt
- deterministisch bei Seed
- Debug nennt Wachstumsentscheidung
- Wachstum bis 250 Zellen flüssig

### Slice 4 – Genom-Expression v0

Ziel:

- Genom beeinflusst Startkörper oder Wachstumsscore.
- Seed-Reihen erzeugen unterscheidbare, valide Organismen.

Acceptance:

- Genomwerte inspector-/debug-lesbar
- Renderer liest abgeleitete Snapshot-/Palette-Daten
- keine Mutation/Vererbung

---

## 12. Agentenworkflow

### 12.1 Startprotokoll

Vor nicht-trivialer Codeänderung:

1. `git status --short --branch` prüfen.
2. `AGENTS.md` und relevante kanonische Docs lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder Planartefakt aktualisieren.

### 12.2 Abschlussprotokoll

Nach Codeänderung:

- Ziel des Slices
- geänderte Dateien
- betroffene Schichten
- Tests / Validierung
- Doku-Sync oder bewusste Nicht-Doku
- offene Risiken
- Review-Fokus für Claude/Zweitagenten
- Commit-Vorschlag

Commit-Vorschlag:

```text
Commit-Vorschlag:
type(scope): imperative title

Beschreibung:
- wichtigste Änderung
- Validierung
- Doku-Folge
- Risiken / Follow-up
```

Kein Agent committed, pusht oder öffnet PRs ohne explizite Freigabe.

### 12.3 Review-Fokus

Zweitagenten prüfen besonders:

- Simulationslogik in Renderer/UI/Debug/Scenes?
- zweite Wahrheit für Zellkoordinaten, Energie oder Körperstruktur?
- Hex-Topologie korrekt und testbar?
- Config-Werte inspector-editierbar, aber keine Runtime-Wahrheit in Config?
- Scope-Erweiterung gegen Nicht-Ziele?
- Doku-Sync vorhanden?
- Headless-Validierung vorhanden?
- Slice-Größe sinnvoll?
- Commit-Vorschlag vorhanden?

---

## 13. Erster Codex-Auftrag

```text
Bitte setze ausschließlich Slice 0 für Baktorium um.

Ziel:
- Neues Godot-Projektfundament für Baktorium vorbereiten.
- AGENTS.md und README.md anlegen.
- docs/ARCHITEKTUR.md, SIM_RULES.md, DECISIONS.md, STATUS.md,
  NEXT_STEPS.md, FINDINGS.md und BAKTORIUM_FOUNDATION_v1.md anlegen.
- Die beschlossene Ordnerstruktur vorbereiten.
- Config-Resource-Skelette vorbereiten, aber noch ohne echte Sim-Logik.
- Einen minimalen eigenen Test-Runner-/Validator-Skeleton anlegen.
- Eine minimale Lab-Startszene anlegen, die ohne echte Simulation lädt.
- Die Asset-Policy in DECISIONS.md oder ARCHITEKTUR.md dokumentieren.

Nicht-Ziele:
- keine Hex-Math-Implementierung
- keine Energie
- kein Wachstum
- keine Population
- kein Genomverhalten
- kein Render-Polish
- keine externen Addons ohne ADR
- keine alten Baktorio-Inhalte übernehmen
- keine Autoloads ohne ADR

Arbeitsregeln:
- Diese Foundation-Endfassung ist der Planungsanker.
- Änderungen so groß wie möglich und so klein wie nötig schneiden.
- Szenen, UI, Debug und Renderer bleiben frei von Simulationsentscheidungen.
- Abschluss mit Validierung, Risiken, Doku-Sync und Commit-Vorschlag.
```

---

## 14. Finaler Merksatz

> Baktorium soll nicht durch schöne Zellen entstehen.  
> Baktorium soll durch eine klare Wahrheit entstehen, die später schön werden darf.

