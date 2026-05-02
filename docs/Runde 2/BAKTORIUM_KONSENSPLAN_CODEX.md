# Baktorium Konsensplan

Status: Konsensfassung aus Codex-, GPT- und Claude-Plan  
Datum: 2026-05-02  
Quellen:

- `docs/BACTORIUM_NEUSTART_CANVAS_codex.md`
- `docs/BAKTORIUM_NEUSTART_CANVAS_GPT.md`
- `docs/BAKTORIUM_NEUSTART_CANVAS_CLAUDE.md`

Dieses Dokument verdichtet die drei Planungsbeitraege zu einer gemeinsamen
Richtung. Es ersetzt die drei Einzelplaene nicht als Historie, ist aber ab
jetzt der bevorzugte Planungsanker fuer die Umsetzung.

## 1. Gemeinsamer Kern

Alle drei Plaene stimmen in den wichtigsten Punkten ueberein:

- Baktorium soll ein echter Neustart sein, keine Reparatur des alten
  Baktorio-/Vectorio-Ansatzes.
- Die erste Version soll bewusst simpel, diskret, deterministisch und
  validierbar sein.
- Hex-Zellen sind die atomare Koerpereinheit.
- Ein Bakterium ist ein zusammenhaengender Verbund direkt benachbarter
  Hex-Zellen.
- Darstellung bleibt zuerst funktional: farbige Hexes, klare Grenzen,
  Debug-Overlay, keine organische High-End-Grafik.
- Daten und Simulationszustand sind Wahrheit; Nodes, Renderer, UI und Debug
  sind Projektion.
- Godot-Inspector-Konfigurierbarkeit ueber Resources ist wichtig.
- Agentenarbeit braucht `AGENTS.md`, Startprotokoll, Doku-Sync,
  Validierungspfad und Commit-Vorschlag.
- Slices sollen so gross wie moeglich und so klein wie noetig sein.

Leitentscheidung:

```text
Zuerst einen deterministischen Hex-Zellkoerper beweisen.
Dann Energie.
Dann Wachstum.
Dann Genom-Einfluss.
Erst danach Population, Bewegung, Mutation, Kampf oder Verdauung.
```

## 2. Entschiedene Widersprueche

### 2.1 Projektname

Konsens:

```text
Baktorium
```

Begruendung:

- Der aktuelle Workspace heisst `baktorium`.
- Die neueren GPT-/Claude-Dateien nutzen Baktorium.
- "Bactorial" bleibt nur historischer Arbeitsbegriff.

### 2.2 Doku-System

Die Plaene unterscheiden sich bei `SIM_RULES.md` vs. `CELL_SYSTEM.md`,
`BUGS.md` vs. `FINDINGS.md` und separater `CLAUDE.md`.

Konsens fuer den Start:

```text
AGENTS.md
README.md
docs/ARCHITEKTUR.md
docs/CELL_SYSTEM.md
docs/DECISIONS.md
docs/STATUS.md
docs/NEXT_STEPS.md
docs/FINDINGS.md
```

Entscheidung:

- `CELL_SYSTEM.md` vereint Sim-Regeln, Hex-Regeln, Zelltypen, Genomidee und
  erste Energie-/Wachstumsregeln.
- `FINDINGS.md` ersetzt `BUGS.md`, weil dort Bugs, Review-Findings,
  Debug-Befunde und geplante Korrekturen gemeinsam Platz haben.
- Keine separate `CLAUDE.md` in Slice 0. Claude-spezifischer Review-Fokus
  kommt in `AGENTS.md`. Eine eigene `CLAUDE.md` wird erst angelegt, wenn
  der Review-Prozess wirklich eigene Regeln braucht.
- Keine `HANDOFF.md` und kein historisches `AI_KONTEXT.md` am Anfang.

Prioritaet bei Widerspruch:

1. `docs/ARCHITEKTUR.md` fuer Schichten, Autoritaeten, Verbote.
2. `docs/DECISIONS.md` fuer Architekturentscheidungen.
3. `docs/STATUS.md` fuer realen Implementierungsstand.
4. `docs/NEXT_STEPS.md` fuer den naechsten Arbeitsblock.
5. `docs/CELL_SYSTEM.md` fuer Domain-/Sim-Regeln.
6. Aeltere Planungsdokumente sind Hintergrund.

### 2.3 Autoloads

Claude schlaegt exakt zwei Autoloads vor. Codex/GPT bleiben vorsichtiger.

Konsens:

- Slice 0 startet ohne projekt-eigene Autoload-Pflicht.
- Die Lab-Szene ist zuerst Composition Root und verdrahtet Services explizit.
- Ein `TimeService`-Autoload kann ab Energie-/Tick-Slices sinnvoll werden,
  braucht aber eine ADR.
- Ein globaler `SimRegistry`-/`WorldRegistry`-Autoload wird nicht vorab
  eingefuehrt.

Begruendung:

- Gravitons Autoload-Regel passt zu einem reifen Weltraumprojekt, waere fuer
  Baktoriums Foundation aber zu frueh globale Kopplung.
- Baktorium soll die Regel uebernehmen, nicht die konkrete Zahl:
  globale Wahrheit nur mit klarem Grund und ADR.

### 2.4 Hex-Orientierung

Claude votiert fuer flat-top, GPT/Codex zeigen pointy-top bzw. lassen die
Orientierung offen.

Konsens:

- Simulationswahrheit ist axial `(q, r)`.
- Pointy/flat ist Render-Konfiguration, nicht Sim-Wahrheit.
- Default fuer Slice 1: `pointy-top`, weil die Renderformel in zwei Plaenen
  bereits genutzt wird und gut fuer ein Lab lesbar ist.
- Ein Wechsel der Orientierung darf keine Sim-Dateien beruehren.

### 2.5 Weltmodell: lokales Koerpergrid vs. globales WorldGrid

Claude bevorzugt lokale Hex-Koerper auf einer 2D-Welt. GPT betont ein
globales `WorldGrid` zur Belegungsautoritaet.

Konsens:

- Der Organismuskoerper nutzt lokale axiale Koordinaten relativ zum
  Organismus-Origin.
- `WorldState` existiert frueh als Container fuer Zeit, Seed und Organismen.
- Ein globales Zell-`WorldGrid` wird nicht in Slice 0/1 erzwungen.
- Sobald mehrere Organismen, Tochterorganismen, Kollision oder Weltbelegung
  relevant werden, wird ein eigener Occupancy-Slice geplant.

Begruendung:

- Fuer einen statischen Einzelkoerper ist ein globales Zellgrid Overhead.
- Fuer spaetere Interaktion darf die Architektur aber nicht so gebaut werden,
  dass Weltbelegung schwer nachruestbar wird.

### 2.6 Zellfunktionen v1

GPT trennt `CORE` und `ENERGY_CORE`; Codex/Claude halten den Start kleiner.

Konsens fuer Foundation:

```text
core
photosynthesis
reproduction
wall
```

Semantik:

- `core`: Pflichtzelle, Identitaet und globaler Energieanker.
- `photosynthesis`: erzeugt Energie.
- `reproduction`: sammelt Wachstumsladung bzw. ermoeglicht Wachstum.
- `wall`: Struktur-/Schutzzelle, aber noch ohne HP-/Damage-System.

Nicht in v1:

- separate `energy_core` neben `core`,
- `cytoplasm`/neutrale Fuellzelle,
- lokale Zell-HP,
- lokale Energiepuffer pro Zelle.

Option:

- Falls der Startkoerper mit nur vier Funktionen semantisch zu eng wird,
  kann `body`/`cytoplasm` spaeter per ADR ergaenzt werden.

### 2.7 Energie: global oder lokal

Claude schlaegt lokale Zellenergie plus Transfer an. Codex/GPT bevorzugen
einen globalen Organismuspool.

Konsens:

- Energie v0 ist ein globaler Organismus-Energiepool.
- `core` ist der sichtbare Anker dieses Pools.
- Es gibt keine lokale Diffusion und keinen Nachbartransfer in den ersten
  Energie-Slices.
- Photosynthese kann von Boundary/Exposure abhaengen, aber das Ergebnis wird
  dem Organismuspool gutgeschrieben.

Begruendung:

- Lokale Energiefluesse waeren interessant, wuerden aber die Foundation
  wieder in Zellphysik ziehen.
- Ein globaler Pool ist einfacher zu testen und reicht fuer erstes Wachstum.

### 2.8 Reproduktion vs. Wachstum

Claude zieht echte Teilung/Tochterorganismen frueher in die Roadmap.
Codex/GPT schneiden konservativer.

Konsens:

- `reproduction` bedeutet in Foundation zuerst: Wachstum am bestehenden
  Koerper.
- Echte Tochterorganismen, Zellteilung in zwei Organismen und Vererbung sind
  eigene spaetere Slices.
- Das Wort "Reproduction Cell" darf im UI auftauchen, aber die technische
  v0-Funktion ist Wachstumsladung/Anbau.

### 2.9 Genom

Alle Plaene wollen ein steuerbares Genom, aber nicht als fruehen Bitstring.

Konsens:

- Genom v0 ist eine typisierte Resource oder ein kleines schema-validiertes
  Dictionary.
- Werte sind normalisiert oder klar begrenzt.
- Keine echte Mutation in den ersten Slices.
- Genom beeinflusst erst deterministischen Startkoerper, spaeter Wachstum.
- Renderer liest nicht direkt das Genom, sondern nur abgeleitete Snapshot-/
  Palette-Daten.

Empfohlene v0-Gene:

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

`mutation_rate_dormant` darf als vorbereiteter Wert existieren, wird aber
nicht aktiv genutzt, bis Mutation per ADR freigegeben ist.

### 2.10 Renderer

Claude bevorzugt frueh MultiMesh, GPT/Codex starten mit `_draw()`.

Konsens:

- Slice 1 nutzt einen einzelnen `Node2D`-Renderer mit `_draw()` fuer farbige
  Hex-Polygone.
- Keine Node pro Zelle als Architektur.
- Keine Shader- oder Antialiasing-Pflicht im Fundament.
- MultiMesh, Chunk-Renderer oder TileMapLayer werden erst geprueft, wenn ein
  Performance-Gate es fordert.

Begruendung:

- `_draw()` ist fuer einen kleinen Lab-Slice schneller, transparenter und gut
  debugbar.
- Die Datenstruktur muss trotzdem so bleiben, dass der Renderer spaeter
  ersetzt werden kann.

## 3. Normative Architektur

Schichten:

```text
ui/debug/scenes
  -> rendering
  -> runtime
  -> sim
  -> body/cells
  -> genetics
  -> config/core
```

Empfohlene Verzeichnisstruktur:

```text
AGENTS.md
README.md
project.godot

docs/
  ARCHITEKTUR.md
  CELL_SYSTEM.md
  DECISIONS.md
  STATUS.md
  NEXT_STEPS.md
  FINDINGS.md
  BAKTORIUM_KONSENSPLAN.md

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

tools/
  validate_hex_foundation.gd
```

Harte Regeln:

- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Kein `Node2D.position` als Simulationswahrheit.
- Keine zweite Wahrheit fuer Zellkoordinaten, Energie oder Koerperstruktur.
- Config-Resources speichern Tuningwerte, keine Runtime-Wahrheit.
- Debug-Code liest und misst, entscheidet aber nichts.
- Renderer erzeugt keine Zellen und keine Wachstumsentscheidungen.
- Neue Zellfunktionen, Gene, Sim-Systeme oder Autoloads brauchen eine ADR,
  sobald sie die Architektur erweitern.
- Keine Manager-Gottklasse.

Autoritaeten:

| Thema | Autoritative Quelle |
|---|---|
| Hex-Math | `src/core/hex_*` |
| Tuningwerte | `src/config/*` und `resources/config/*.tres` |
| Genomwerte | `src/genetics/genome.gd` |
| Zellkoerper | `src/body/organism_body.gd` |
| Zellfunktion | `CellBlock.function_tag` plus `CellFunctionCatalog` |
| Organismus-Energie | `src/sim/organism_state.gd` |
| Wachstumsladung | `src/sim/organism_state.gd` |
| Tick-Orchestrierung | `src/sim/simulation_service.gd` oder Lab-Composition-Root |
| Renderdaten | `src/runtime/*snapshot*` |

## 4. Domain-Modell v0

### 4.1 Hex-Koordinaten

- Kanonisch: axial `(q, r)`.
- Cube-Koordinaten nur als abgeleitete Hilfsform fuer Distanz/Rotation.
- Nachbarn:

```text
(+1,  0)
(+1, -1)
( 0, -1)
(-1,  0)
(-1, +1)
( 0, +1)
```

Invarianten:

- Jede Zelle belegt genau eine lokale Hex-Koordinate.
- Kein Organismus hat doppelte lokale Koordinaten.
- Ein Organismus ist connected.
- Boundary ist abgeleitet: eine Zelle ist Boundary, wenn mindestens ein
  Nachbarplatz im Organismus leer ist.

### 4.2 CellBlock

Eine Zelle ist Daten, kein Node.

Minimalfelder:

```text
cell_id
coord: HexCoord
function_tag: StringName
```

Optional spaeter:

```text
integrity
age_ticks
flags
```

Nicht in v0:

- lokale Energie pro Zelle,
- lokale HP,
- eigene `_process()`-Logik,
- eigene Godot-Node.

### 4.3 OrganismBody und OrganismState

`OrganismBody`:

- Zellliste / Dictionary nach Hex-Key,
- lokale Topologie,
- Pflichtzellen,
- keine Energie- oder Tick-Wahrheit.

`OrganismState`:

- `energy`,
- `growth_charge`,
- `age_ticks`,
- `alive`,
- Referenz auf `OrganismBody` und `Genome` oder stabile IDs.

### 4.4 WorldState

`WorldState` existiert frueh, bleibt aber klein:

- globaler Seed,
- Tick/Sim-Zeit,
- Liste von Organismen,
- spaeter globale Occupancy/Spatial Index.

Slice 1 darf genau einen Organismus enthalten. Mehrere Organismen sind nicht
Teil der Foundation, aber `WorldState` verhindert, dass spaeter alles in ein
Lab-Script einwaechst.

## 5. Simulation v0

Tick-Reihenfolge ab Energie/Growth-Slices:

1. Topologie ableiten oder dirty aktualisieren.
2. Photosyntheseenergie berechnen.
3. Maintenance-Kosten abziehen.
4. Wachstumsladung aktualisieren.
5. Wenn erlaubt: maximal konfigurierte Wachstumsevents ausfuehren.
6. Invarianten validieren.
7. Snapshot fuer Renderer/Debug aktualisieren.

Energie:

- Organismusweiter Energiepool.
- `core` ist Pflicht und sichtbarer Anker.
- `photosynthesis` produziert.
- `wall` kostet Maintenance.
- `reproduction` kostet Maintenance und kann Growth Charge erzeugen.

Wachstum:

- Wachstum fuegt eine neue Zelle an eine freie Nachbarposition an.
- Kandidaten kommen aus der Frontier.
- Score nutzt Genom, Zelltyp-Balance, Kompaktheit, Boundary/Surface und
  deterministischen RNG.
- Wachstum bleibt connected.
- Pro Tick begrenzt.

## 6. Config und Inspector

Alle wichtigen Tuningwerte sollen als Resources editierbar sein:

- `SimulationConfig`
  - seed,
  - tick rate,
  - start paused,
  - max growth events per tick,
  - global sun intensity.

- `HexGridConfig`
  - hex size,
  - render orientation,
  - debug coordinate labels.

- `CellFunctionDef`
  - function id,
  - label,
  - base color,
  - energy production,
  - maintenance cost,
  - growth cost,
  - requires surface,
  - protection hint.

- `CellFunctionCatalog`
  - erlaubte Zellfunktionen,
  - Pflichtfunktionen,
  - Feature-Gates.

- `GenomeConfig`
  - gene schemas,
  - clamp/defaults.

- `GrowthConfig`
  - growth threshold,
  - compactness weight,
  - surface weight,
  - balance weights.

- `RenderConfig`
  - colors/outline,
  - show debug,
  - draw coordinates,
  - selected alpha.

- `LabConfig`
  - review seed start/count,
  - auto tick speed,
  - initial body preset.

Regel:

- UI darf Runtime-Kopien veraendern.
- UI darf nicht versehentlich `.tres`-Assets mutieren.
- Ein Validator soll das pruefen, sobald UI-Interaktion vorhanden ist.

## 7. Validierung

Fruehe headless Checks:

- axial neighbor count = 6,
- axial distance korrekt,
- gleicher Seed erzeugt gleichen Koerper,
- Seed-Reihe erzeugt unterscheidbare Koerper,
- Organismus ist connected,
- keine duplicate Hex-Koordinate,
- jede Zelle hat bekannte Funktion,
- Pflichtfunktionen existieren,
- Boundary-Erkennung stimmt fuer bekannte Formen,
- Renderer liest keine Genome direkt,
- Config-Assets werden nicht zur Laufzeit mutiert.

Spaeter:

- Energie-Tick deterministisch,
- Energie bleibt endlich und im erlaubten Bereich,
- Wachstum bleibt connected,
- Wachstum erzeugt keine Doppelbelegung,
- Wachstumskosten werden korrekt abgezogen,
- Debug-Overlay veraendert keinen Sim-State.

Teststrategie:

- Zunaechst eigener schlanker Godot-Test-Runner wie in Graviton.
- GUT nicht in Slice 0.
- `tools/validate_hex_foundation.gd` als schneller Headless-Validator.

## 8. Performance-Leitlinie

Von Anfang an:

- Keine Node pro Zelle als Architektur.
- Dictionary/Set-Zugriff nach Hex-Key.
- Fixed Simulation Tick.
- Rendering liest Snapshots.
- Debug-Overlay abschaltbar.
- Keine teuren Full-Scans pro Frame, wenn ein Dirty-/Event-Pfad reicht.
- Contiguity bei Aenderung validieren, nicht blind jedes Frame.

Renderpfad:

1. Slice 1: ein `Node2D` mit `_draw()`.
2. Bei groesseren Zellmengen: Dirty-Set / Chunk-Renderer.
3. Bei Skalierungsdruck: MultiMesh2D oder TileMapLayer-Spike.

Erste Performance-Gates:

- Slice 1: 1 Organismus mit 25 bis 100 Zellen fluessig und lesbar.
- Nach Wachstum: 1 Organismus bis 250 Zellen.
- Vor mehreren Organismen: eigener Scale-Test.

## 9. Slice-Roadmap

### Slice 0: Repo- und Doku-Fundament

Ziel:

- Agentenvertrag, kanonische Doku, Ordnerstruktur und minimale Startszene.

Umfang:

- `AGENTS.md`
- `README.md`
- `docs/ARCHITEKTUR.md`
- `docs/CELL_SYSTEM.md`
- `docs/DECISIONS.md`
- `docs/STATUS.md`
- `docs/NEXT_STEPS.md`
- `docs/FINDINGS.md`
- minimale `scenes/lab/simulation_lab.tscn`

Noch nicht:

- Hex-Simulation,
- Energie,
- Wachstum,
- Population,
- Render-Polish.

Acceptance:

- Projekt oeffnet.
- Startszene laedt.
- Doku widerspricht sich nicht.
- `NEXT_STEPS.md` definiert Slice 1.

### Slice 1: Hex Foundation und statischer Organismus

Ziel:

- Axial-Hex-Math,
- deterministischer statischer Organismus,
- einfache Hex-Darstellung im Lab.

Acceptance:

- gleicher Seed erzeugt gleiche Zellen,
- Organismus ist connected,
- keine duplicate Koordinaten,
- Pflichtfunktionen existieren,
- Renderer erzeugt keine Sim-Entscheidungen,
- Headless-Validator laeuft.

### Slice 2: Energie v0

Ziel:

- Photosynthese erzeugt Energie im Organismuspool,
- Maintenance-Kosten,
- sichtbare Energiebilanz.

Acceptance:

- deterministischer Energie-Tick,
- Inspector-Config wirkt,
- keine lokale Energiephysik,
- kein Wachstum.

### Slice 3: Wachstum v0

Ziel:

- `reproduction` erzeugt Growth Charge,
- neue Zellen entstehen an Frontier-Hexes,
- Energie wird verbraucht.

Acceptance:

- Wachstum bleibt connected,
- pro Tick begrenzt,
- deterministisch bei Seed,
- Debug nennt Wachstumsentscheidung.

### Slice 4: Genom-Expression v0

Ziel:

- Genom beeinflusst Startkoerper oder Wachstumsscore.
- Seed-Reihen erzeugen unterscheidbare, valide Organismen.

Acceptance:

- Genomwerte inspector-/debug-lesbar,
- Renderer liest abgeleitete Snapshot-/Palette-Daten,
- keine Mutation/Vererbung.

Erst danach entscheiden:

- Tochterorganismen,
- Mutation,
- mehrere Organismen,
- Bewegung,
- Sensorik,
- Verdauung,
- Kampf,
- lokale Schadenslogik,
- World-Occupancy/Spatial-Index.

## 10. Nicht-Ziele bis einschliesslich Slice 4

- Bewegung,
- Augen/Sicht/Sensorik,
- Dornen/Kampf,
- Mund/Verdauung,
- Fressen,
- lokale Zellschadenwerte,
- Kollision,
- Fluid/Softbody,
- Tochterorganismus-Reproduktion,
- Mutation und Vererbung,
- Populationsevolution,
- Tag/Nacht-Zyklus,
- Save/Load,
- Shader-/High-End-Grafik,
- MultiMesh als Pflicht,
- UI-Polish ausserhalb des Labs.

## 11. Agentenworkflow

Startprotokoll vor nicht-trivialer Codeaenderung:

1. `git status --short --branch` pruefen.
2. `AGENTS.md` und relevante kanonische Docs lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder ein Planartefakt
   aktualisieren.

Abschluss nach Codeaenderung:

- Ziel des Slices,
- geaenderte Dateien,
- betroffene Schichten,
- Tests / Validierung,
- Doku-Sync oder bewusste Nicht-Doku,
- offene Risiken,
- Review-Fokus fuer Claude,
- Commit-Vorschlag.

Commit-Vorschlag:

```text
Commit-Vorschlag:
type(scope): imperative title

Beschreibung:
- wichtigste Aenderung
- Validierung
- Doku-Folge
- Risiken / Follow-up
```

Kein Agent committed, pusht oder oeffnet PRs ohne explizite Freigabe.

## 12. Review-Fokus fuer Claude / Zweitagenten

Bei Plan- und Code-Reviews besonders pruefen:

- Simulationslogik in Renderer/UI/Debug/Scenes?
- Zweite Wahrheit fuer Zellkoordinaten, Energie oder Koerperstruktur?
- Hex-Topologie korrekt und testbar?
- Config-Werte inspector-editierbar, aber keine Runtime-Wahrheit in Config?
- Scope-Erweiterung gegen Nicht-Ziele?
- Doku-Sync vorhanden?
- Headless-Validierung vorhanden?
- Slice-Groesse sinnvoll?
- Commit-Vorschlag vorhanden?

## 13. Offene Fragen, die nicht vor Slice 0 blockieren

Diese Punkte bleiben bewusst offen:

- Wann genau ein globales WorldGrid/SpatialIndex eingefuehrt wird.
- Ob `cytoplasm`/neutrale Zellen gebraucht werden.
- Ob pointy-top spaeter optisch durch flat-top ersetzt wird.
- Ob GUT spaeter den eigenen Test-Runner ersetzt.
- Ob MultiMesh, TileMapLayer oder Chunk-Renderer der beste Scale-Pfad wird.
- Wie Mutation/Vererbung konkret modelliert wird.
- Wie echte Tochterorganismus-Teilung funktioniert.

Keine dieser Fragen blockiert Slice 0.

## 14. Erster Codex-Auftrag nach diesem Konsens

Empfohlener erster Umsetzungsauftrag:

```text
Bitte setze nur Slice 0 fuer Baktorium um.

Ziel:
- AGENTS.md und README.md anlegen.
- docs/ARCHITEKTUR.md, CELL_SYSTEM.md, DECISIONS.md, STATUS.md,
  NEXT_STEPS.md und FINDINGS.md anlegen.
- Die im Konsensplan beschlossene Ordnerstruktur vorbereiten.
- Eine minimale Lab-Startszene anlegen, die ohne echte Simulation laedt.
- Noch keine Hex-Math, keine Energie, kein Wachstum und keine Population
  implementieren.

Arbeitsregeln:
- Dieser Konsensplan ist der Planungsanker.
- Keine alten Baktorio-Inhalte uebernehmen.
- Keine Render-Politur.
- Keine Autoloads ohne ADR.
- Abschluss mit Validierung, Risiken und Commit-Vorschlag.
```

