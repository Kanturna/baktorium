# Baktorium Endfassung Fundament

Status: Runde-3-Endfassung / Projektfundament  
Datum: 2026-05-02  
Ziel: verbindlicher Planungsanker fuer Slice 0 und die Foundation-Phase

Quellen dieser Fassung:

- `docs/Runde 2/BAKTORIUM_KONSENSPLAN_CODEX.md`
- `docs/Runde 2/BAKTORIUM_KONSENSPLAN_CLAUDE.md`
- `docs/Runde 2/BAKTORIUM_KONSENSPLAN_GPT.md`
- aktuelle Godot-Dokumentation und Asset-Library-Recherche, siehe Abschnitt 14

Dieses Dokument ist die Endfassung der Planungsrunde. Es ist noch kein
Implementierungsdiff, aber ab jetzt der bevorzugte Projektvertrag fuer Codex,
Claude Code und ChatGPT.

## 1. Leitentscheidung

Baktorium wird als neue Godot-4.6-Simulation aufgebaut:

```text
Erst Hex-Topologie.
Dann deterministischer Zellkoerper.
Dann Lab-Darstellung.
Dann Energie.
Dann Wachstum.
Dann Genom-Einfluss.
Erst danach Population, Mutation, Bewegung, Kampf oder Verdauung.
```

Der Neustart soll nicht wieder an frueher Grafik, echter Zellphysik oder
zu breitem Biologieanspruch ersticken. Die erste spielbare Wahrheit ist ein
simpler, deterministischer, zusammenhaengender Hex-Zellkoerper.

## 2. Harte Grundsaetze

- Daten und Simulationszustand sind Wahrheit.
- Nodes, Renderer, UI, Debug-Overlays und Szenen sind Projektion.
- Eine Zelle ist ein Hex.
- Ein Bakterium ist ein direkt zusammenhaengender Verbund aus Hex-Zellen.
- Keine Zelle schwebt mit Abstand neben einer anderen Koerperzelle.
- Die Sim nutzt axiale Hex-Koordinaten `(q, r)`.
- Cube-Koordinaten werden nur abgeleitet, wenn Algorithmen sie brauchen.
- Boundary/Oberflaeche ist abgeleitet, nicht gespeichert.
- Config-Resources sind Tuningwerte, keine Runtime-Wahrheit.
- Keine Manager-Gottklasse.
- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Keine externen Addons im Fundament, bevor ein konkreter Slice davon
  messbar profitiert.

## 3. Final entschiedene Konflikte aus Runde 2

### 3.1 Projektname

Final:

```text
Baktorium
```

Der Workspace heisst `baktorium`; "Bactorial" bleibt historischer Begriff.

### 3.2 Doku-Set

Finales kanonisches Set fuer Slice 0:

```text
AGENTS.md
README.md
docs/ARCHITEKTUR.md
docs/SIM_RULES.md
docs/DECISIONS.md
docs/STATUS.md
docs/NEXT_STEPS.md
docs/FINDINGS.md
```

Entscheidung:

- `SIM_RULES.md` gewinnt gegen `CELL_SYSTEM.md`, weil Hex-Regeln,
  Zellfunktionen, Energie, Wachstum, Genom und Tick-Reihenfolge zusammen
  verstanden werden muessen.
- `FINDINGS.md` gewinnt gegen `BUGS.md`, weil dort Bugs, Review-Findings,
  Debug-Befunde und Architekturhinweise gemeinsam landen.
- Keine separate `CLAUDE.md` in Slice 0. Der Review-Fokus fuer Claude kommt
  in `AGENTS.md`. Eine eigene `CLAUDE.md` braucht spaeter eine konkrete
  Begruendung.
- Kein `HANDOFF.md`, kein `AI_KONTEXT.md`, keine separate `PERFORMANCE.md`
  am Anfang.

Prioritaet bei Widerspruch:

1. `docs/ARCHITEKTUR.md` fuer Schichten, Autoritaeten, Verbote.
2. `docs/DECISIONS.md` fuer Architekturentscheidungen.
3. `docs/SIM_RULES.md` fuer Simulationsregeln.
4. `docs/STATUS.md` fuer realen Implementierungsstand.
5. `docs/NEXT_STEPS.md` fuer den naechsten Arbeitsblock.
6. `AGENTS.md` fuer Arbeitsprozess.
7. `README.md` fuer Orientierung.
8. Aeltere Planungsnotizen sind Hintergrund.

### 3.3 Autoloads

Final:

- Slice 0 startet ohne projekt-eigene Autoloads.
- Die Lab-Szene ist Composition Root.
- Ein `TimeService` kann ab Energie-/Tick-Slices sinnvoll werden, braucht
  aber eine ADR.
- Kein globaler `SimRegistry`-/`WorldRegistry`-Autoload im Fundament.

Grund:

Autoloads sind globale Kopplung. Baktorium soll Gravitons Disziplin
uebernehmen, aber nicht dessen reife Projektstruktur vorwegnehmen.

### 3.4 Hex-Orientierung

Final:

- Simulationswahrheit ist axial `(q, r)`.
- Pointy-top oder flat-top ist reine Render-Konfiguration.
- Default fuer das erste Lab: pointy-top.
- Ein Orientierungswechsel darf nur `RenderConfig` und Renderer beruehren.

### 3.5 Zellfunktionen v0

Finale Foundation-Zellfunktionen:

```text
energy_core
photosynthesis
reproduction
wall
```

Semantik:

- `energy_core`: Pflichtzelle, Identitaet und Energieanker.
- `photosynthesis`: erzeugt Energie.
- `reproduction`: erzeugt Wachstumsladung bzw. ermoeglicht Anbau.
- `wall`: Struktur-/Schutzzelle, aber ohne HP-/Damage-System.

Nicht in Foundation:

- separate `core` plus `energy_core`,
- `cytoplasm`,
- lokale Zell-HP,
- lokale Zellenergie,
- lokale Energie-Diffusion.

### 3.6 Energie

Final:

- Energie v0 ist ein globaler Organismuspool.
- `energy_core` ist der sichtbare Anker dieses Pools.
- Photosynthese schreibt in den Organismuspool.
- Keine Zell-zu-Zell-Diffusion in Foundation.

### 3.7 Wachstum und Reproduktion

Final:

- `reproduction` bedeutet in Foundation Wachstum am bestehenden Koerper.
- Echte Tochterorganismen sind spaeterer eigener Slice.
- Mutation und Vererbung kommen erst nach validiertem Wachstum und echter
  Reproduktion.

### 3.8 Renderer

Final:

- Der erste Renderer ist ein einzelner `Node2D` mit `_draw()`.
- Keine Node pro Zelle.
- Kein MultiMesh als Startpflicht.
- Kein Shader-/Antialiasing-Spike im Fundament.
- MultiMesh, TileMapLayer oder Shader werden erst ueber Performance- oder
  Render-Spikes geprueft.

## 4. Schichten

Finale Dependency-Richtung:

```text
ui/debug/scenes
  -> rendering
  -> runtime
  -> sim
  -> body/cells
  -> genetics
  -> config/core
```

Regeln:

- `core/` kennt keine Godot-Nodes und keine hoeheren Schichten.
- `config/` enthaelt Resources und Defaults, keine Runtime-Wahrheit.
- `genetics/` erzeugt und interpretiert Genome, entscheidet aber nicht ueber
  Rendering.
- `body/` / `cells/` halten lokale Zellkoerperdaten und Topologie.
- `sim/` ist autoritativ fuer Energie, Wachstum, Tick und spaetere Weltlogik.
- `runtime/` erzeugt Snapshots und abgeleitete Lesemodelle.
- `rendering/` zeichnet nur.
- `ui/`, `debug/`, `scenes/` steuern Bedienung, Diagnose und Verdrahtung,
  aber keine Sim-Regeln.

## 5. Verzeichnisstruktur fuer Slice 0

```text
AGENTS.md
README.md
project.godot

docs/
  ARCHITEKTUR.md
  SIM_RULES.md
  DECISIONS.md
  STATUS.md
  NEXT_STEPS.md
  FINDINGS.md

src/
  core/
    hex/
    rng/
    ids/
  config/
  genetics/
  body/
  sim/
  runtime/
  rendering/
  ui/
    lab/
  debug/
  tests/
    core/
    genetics/
    body/
    sim/
    rendering/

scenes/
  lab/

resources/
  config/
  cell_functions/

tools/
```

Slice 0 darf leere `.gitkeep`-Dateien oder Stub-Dateien nutzen, wenn Godot
sonst leere Ordner nicht sichtbar haelt.

## 6. Domain-Modell v0

### 6.1 HexCoord

Kanonisch:

```text
HexCoord(q: int, r: int)
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

- genau eine lokale Hex-Koordinate pro Zelle,
- keine doppelten Koordinaten im Organismus,
- Koerper bleibt connected,
- Boundary wird abgeleitet.

### 6.2 CellBlock

Eine Zelle ist Daten, kein Node.

Minimalfelder:

```text
cell_id
coord: HexCoord
function_id: StringName
```

Spaeter moeglich, aber nicht Foundation:

```text
integrity
age_ticks
flags
local_energy
```

### 6.3 OrganismBody

`OrganismBody` haelt:

- Dictionary nach Hex-Key,
- Zellen,
- lokale Topologie,
- Pflichtfunktionen.

Keine Energie, kein Tick, keine Renderdaten.

### 6.4 OrganismState

`OrganismState` haelt:

- `energy`,
- `growth_charge`,
- `age_ticks`,
- `alive`,
- Referenz/ID auf `OrganismBody` und `Genome`.

### 6.5 WorldState

`WorldState` existiert frueh, bleibt aber klein:

- globaler Seed,
- Tick/Sim-Zeit,
- Liste von Organismen.

Ein globales Zell-`WorldGrid` wird nicht in Slice 0/1 erzwungen. Sobald
mehrere Organismen, Tochterorganismen, Kollision oder globale Belegung
relevant werden, wird ein eigener Occupancy-Slice mit ADR geplant.

## 7. Genom v0

Genom v0 ist typisiert oder schema-validiert, kein Bitstring.

Empfohlene Gene:

```text
photosynthesis_bias
wall_bias
reproduction_bias
growth_spread
symmetry_bias
surface_preference
energy_efficiency
mutation_rate_dormant
```

Regeln:

- Werte sind normalisiert oder klar begrenzt.
- Genom beeinflusst Startkoerper und spaeter Wachstumsscore.
- `mutation_rate_dormant` wird nicht aktiv genutzt, bis Mutation per ADR
  freigegeben ist.
- Renderer liest kein Genom direkt.

## 8. Simulation v0

Tick-Reihenfolge ab Energie-/Growth-Slices:

1. Topologie dirty aktualisieren oder ableiten.
2. Photosyntheseenergie berechnen.
3. Maintenance-Kosten abziehen.
4. Wachstumsladung aktualisieren.
5. Maximal konfigurierte Wachstumsevents ausfuehren.
6. Invarianten pruefen.
7. Snapshot fuer Rendering/Debug aktualisieren.

Growth-Regel:

- Wachstum fuegt neue Zellen an freie Nachbarpositionen an.
- Kandidaten kommen aus der Frontier.
- Scoring nutzt Genom, Zelltyp-Balance, Kompaktheit, Boundary/Surface und
  deterministischen RNG.
- Wachstum bleibt connected.
- Wachstum ist pro Tick begrenzt.

## 9. Config und Inspector

Alle wichtigen Tuningwerte werden ueber Resources und `@export` /
`@export_range` inspector-editierbar.

Geplante Config-Resources:

- `SimulationConfig`
- `HexGridConfig`
- `CellFunctionDef`
- `CellFunctionCatalog`
- `GenomeConfig`
- `GrowthConfig`
- `RenderConfig`
- `LabConfig`

Regeln:

- UI darf Runtime-Kopien veraendern.
- UI darf `.tres`-Assets nicht versehentlich mutieren.
- Ein Validator prueft Config-Mutation, sobald UI-Interaktion existiert.

## 10. Validierung

Fruehe headless Checks:

- axial neighbor count = 6,
- axiale Distanz korrekt,
- gleicher Seed erzeugt gleichen Koerper,
- Seed-Reihe erzeugt unterscheidbare Koerper,
- Organismus ist connected,
- keine duplicate Hex-Koordinate,
- jede Zelle hat bekannte Funktion,
- Pflichtfunktionen existieren,
- Boundary-Erkennung stimmt fuer bekannte Formen,
- Renderer liest keine Genome direkt,
- Config-Assets werden nicht zur Laufzeit mutiert.

Teststrategie:

- eigener schlanker Godot-Test-Runner in Slice 0,
- `tools/validate_hex_foundation.gd` als schneller Validator,
- GUT erst spaeter evaluieren, wenn der eigene Runner nicht mehr reicht.

## 11. Performance-Leitlinie

Von Anfang an:

- keine Node pro Zelle,
- Dictionary/Set-Zugriff nach Hex-Key,
- fixed simulation tick,
- Rendering liest Snapshots,
- Debug-Overlay abschaltbar,
- keine Full-Scans pro Frame, wenn Dirty-/Event-Pfad reicht,
- Contiguity bei Aenderung validieren, nicht blind jedes Frame.

Renderpfad:

1. Slice 3: ein `Node2D` mit `_draw()`.
2. Bei groesseren Zellmengen: Dirty-Set / Chunk-Renderer.
3. Bei Skalierungsdruck: MultiMesh2D oder TileMapLayer-Spike.

Performance-Gates:

- Slice 1: Hex-Topologie fuer Testcluster stabil.
- Slice 3: 1 Organismus mit 25 bis 100 Zellen fluessig und lesbar.
- Nach Wachstum: 1 Organismus bis 250 Zellen.
- Vor mehreren Organismen: eigener Scale-Test.

## 12. Slice-Roadmap

### Slice 0: Repo-, Doku- und Test-Fundament

Umfang:

- `AGENTS.md`
- `README.md`
- kanonische Docs
- Ordnerstruktur
- minimale Lab-Startszene
- Test-/Validator-Skelett
- Config-Resource-Skelette

Nicht enthalten:

- Hex-Math,
- Energie,
- Wachstum,
- Genomverhalten,
- Population,
- externe Addons.

Acceptance:

- Projekt oeffnet in Godot.
- Lab-Szene laedt.
- Test-/Validator-Skelett laeuft headless.
- Doku widerspricht sich nicht.
- `NEXT_STEPS.md` definiert Slice 1.

### Slice 1: Hex-Kern und Topologie

Umfang:

- `HexCoord`,
- axialer Key,
- Nachbarn,
- Distanz,
- Boundary-Erkennung,
- Connectedness.

Acceptance:

- Tests fuer Nachbarn, Distanz, bekannte Formen, Boundary und Connectedness.
- Keine Godot-Node-Abhaengigkeit im Hex-Kern.
- Sim kennt keine Pixelorientierung.

### Slice 2: Genom und Startkoerper

Umfang:

- `Genome`,
- `GenomeFactory`,
- `OrganismBody`,
- `BodyFactory`,
- Pflichtzellen: `energy_core`, `photosynthesis`, `reproduction`, `wall`.

Acceptance:

- gleicher Seed erzeugt gleichen Startkoerper,
- 20 bis 30 Seeds erzeugen unterscheidbare, valide Koerper,
- alle Koerper connected,
- keine duplicate Hex-Koordinaten,
- Pflichtfunktionen existieren.

### Slice 3: Lab-Rendering und Inspector

Umfang:

- `HexOrganismRenderer` via `_draw()`,
- Seed-Navigation,
- Debug-Overlay fuer Koordinaten, Boundary, Zellfunktionen,
- Inspector-Configs.

Acceptance:

- 20 bis 30 Seeds visuell schnell pruefbar,
- Renderer erzeugt keine Sim-Entscheidungen,
- UI mutiert keine gespeicherten `.tres`-Assets.

### Slice 4: Energie v0

Umfang:

- Photosynthese produziert Energie,
- globaler Organismuspool,
- Maintenance-Kosten,
- sichtbare Energiebilanz.

Acceptance:

- deterministischer Energie-Tick,
- keine negativen/NaN/Infinity-Werte,
- bekannte Testkoerper ergeben erwartbare Bilanz,
- Config-Werte beeinflussen Ergebnis sichtbar.

### Slice 5: Wachstum v0

Umfang:

- `reproduction` erzeugt Wachstumsladung,
- neue Zellen entstehen an Frontier-Hexen,
- Growth-Scoring nutzt Genom und Topologie,
- begrenzte Growth-Events pro Tick.

Acceptance:

- Wachstum bleibt connected,
- neue Zellen entstehen adjacent,
- keine Doppelbelegung,
- gleiches Seed ergibt gleiches Wachstum,
- Debug zeigt Wachstumsentscheidung.

## 13. Nicht-Ziele bis inklusive Slice 5

- Bewegung,
- Sensorik/Augen,
- Dornen/Kampf,
- Mund/Verdauung,
- Fressen,
- lokale Zellschadenwerte,
- Kollision,
- Fluid/Softbody,
- Tochterorganismen,
- Mutation und Vererbung,
- Populationsevolution,
- Tag/Nacht-Zyklus,
- Save/Load,
- Shader-/High-End-Grafik,
- MultiMesh als Pflicht,
- UI-Polish ausserhalb des Labs.

## 14. Godot-Assets und Addon-Strategie

### 14.1 Grundregel

Assets sollen Baktorium effektiver, schoener und umsetzbarer machen, aber
nicht die Architektur bestimmen.

Regel:

```text
Foundation ohne externe Addon-Pflicht.
Assets nur phasenweise und per ADR oder Render-/Tool-Spike einfuehren.
```

Godot selbst liefert bereits drei wichtige Bausteine:

- `Resource` fuer datengetriebene Configs.
- `@export` / `@export_range` fuer Inspector-Tuning.
- Custom Drawing via `_draw()` fuer viele einfache 2D-Objekte ohne Node-Flut.

### 14.2 Sofort nutzen, ohne Asset-Installation

| Baustein | Einsatz | Entscheidung |
|---|---|---|
| Godot `Resource` | Configs, GenomeConfig, CellFunctionDef | Pflicht ab Slice 0/2 |
| `@export` / `@export_range` | Inspector-Tuning | Pflicht |
| `Node2D._draw()` | erster Hex-Renderer | Pflicht ab Slice 3 |
| Godot Profiler/Monitors | erste manuelle Messungen | nutzen, kein Plugin noetig |

### 14.3 Kandidaten fuer spaetere Installation

| Asset / Tool | Nutzen fuer Baktorium | Phase | Entscheidung |
|---|---|---|---|
| Debug Menu | FPS, Frametime, CPU/GPU-Zeit, Hardware-/Softwaredaten im laufenden Projekt | ab Slice 4 oder erster Performance-Messung | empfehlenswert, aber nicht Slice 0 |
| Antialiased Line2D | sauberere Hex-Kanten, antialiased Polygone/RegularPolygon-Helfer | nach stabilem Minimalrenderer | guter Render-Polish-Kandidat |
| Hexagon TileMapLayer | Hex-TileMap mit Cube-Koordinaten, Debug, A* fuer spaetere Welt/Substrat-Karte | spaeterer World-/Occupancy-Spike | pruefen, nicht Foundation |
| Hexagonal Grid Utils | kleine Referenz fuer flat/pointy snapping | nur als Referenz oder Vergleich | eher nicht installieren; eigene HexMath bleibt Wahrheit |
| GUT 9.x | komfortablere Tests in Godot 4.6, Editor- und CLI-Testworkflow | wenn eigener Test-Runner zu klein wird | optionaler Test-Spike |
| Phantom Camera | komfortablere 2D-Kamera, Follow/Reframe/Tween | erst bei beweglicher Welt/mehreren Organismen | spaeter sinnvoll, nicht Foundation |
| Aseprite Wizard | Sprite-/Animationsimport aus Aseprite | falls spaeter handgezeichnete Zell-/Organismusassets entstehen | nicht Foundation |

### 14.4 Explizit nicht fuer Foundation

- Shaderpacks oder `shaderV`-artige Bibliotheken.
- 3D-Hex-Map-GDExtensions.
- Plugins, die globale Autoloads erzwingen, bevor wir diese Autoritaet
  architektonisch entschieden haben.
- Asset-Packs mit fertiger Grafik, die den Sim-Kern visuell ueberdeckt.
- TileMapLayer als Start-Renderer fuer Organismuskoerper.

### 14.5 Asset-Entscheidung nach Slices

Slice 0:

- Keine externen Assets installieren.
- Nur Godot-Built-ins.

Slice 1:

- Keine externen Assets.
- Red-Blob-Hex-Formeln als Referenz, aber eigene getestete `HexGridMath`.

Slice 2:

- Keine externen Assets.
- `CellFunctionDef` und `GenomeConfig` als eigene Resources.

Slice 3:

- `_draw()` als Startrenderer.
- Antialiased Line2D nur vormerken, falls Hex-Kanten im Lab stoeren.

Slice 4:

- Debug Menu evaluieren, sobald echte Tick-/Energie-Metriken sichtbar werden.

Slice 5+:

- GUT evaluieren, wenn Testumfang steigt.
- Hexagon TileMapLayer evaluieren, wenn globale Weltkarte/Substrat oder
  Pathfinding wichtig werden.
- MultiMesh2D oder TileMapLayer pruefen, wenn `_draw()` messbar kippt.

## 15. Quellen fuer Asset- und Technikentscheidungen

- Godot Asset Library Nutzung: https://docs.godotengine.org/en/stable/community/asset_library/using_assetlib.html
- Godot Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Godot GDScript Exports: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- Godot Custom Drawing in 2D: https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
- Godot MultiMeshInstance2D: https://docs.godotengine.org/en/stable/classes/class_multimeshinstance2d.html
- Godot TileMaps / TileMapLayer: https://docs.godotengine.org/en/4.6/tutorials/2d/using_tilemaps.html
- Red Blob Games Hexagonal Grids: https://www.redblobgames.com/grids/hexagons/
- Debug Menu: https://godotengine.org/asset-library/asset/1902
- Antialiased Line2D: https://godotengine.org/asset-library/asset/3103
- Hexagonal Grid Utils: https://godotengine.org/asset-library/asset/2682
- Hexagon TileMapLayer: https://store.godotengine.org/asset/zehir/hexagon-tilemaplayer/
- GUT 9.6.0 Docs: https://gut.readthedocs.io/en/v9.6.0/
- Phantom Camera: https://store.godotengine.org/asset/ramokz/phantom-camera/

## 16. Agentenworkflow

Startprotokoll vor nicht-trivialer Codeaenderung:

1. `git status --short --branch` pruefen.
2. `AGENTS.md` und relevante kanonische Docs lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder Planartefakt
   aktualisieren.

Abschluss nach Codeaenderung:

- Ziel des Slices,
- geaenderte Dateien,
- betroffene Schichten,
- Tests / Validierung,
- Doku-Sync oder bewusste Nicht-Doku,
- offene Risiken,
- Review-Fokus fuer Claude/Zweitagenten,
- Commit-Vorschlag.

Kein Agent committed, pusht oder oeffnet PRs ohne explizite Freigabe.

## 17. Erster Codex-Auftrag

```text
Bitte setze ausschliesslich Slice 0 fuer Baktorium um.

Ziel:
- AGENTS.md und README.md anlegen.
- docs/ARCHITEKTUR.md, SIM_RULES.md, DECISIONS.md, STATUS.md,
  NEXT_STEPS.md und FINDINGS.md anlegen.
- Die in der Endfassung beschlossene Ordnerstruktur vorbereiten.
- Config-Resource-Skelette vorbereiten.
- Einen minimalen Headless-Test-Runner oder Validator-Skeleton anlegen.
- Eine minimale Lab-Startszene anlegen, die noch keine echte Simulation
  enthaelt.

Nicht-Ziele:
- keine Hex-Math-Implementierung,
- keine Energie,
- kein Wachstum,
- kein Genomverhalten,
- keine Population,
- kein organisches Rendering,
- keine externen Addons,
- keine Autoloads ohne ADR.

Validierung:
- Projekt oeffnet in Godot.
- Lab-Szene laedt.
- Test-/Validator-Skeleton laeuft headless.
- Doku ist widerspruchsfrei.
- Abschluss mit geaenderten Dateien, Validierung, offenen Risiken,
  Doku-Sync und Commit-Vorschlag.
```

