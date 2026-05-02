# Baktorium — Fundament v1 (Endfassung)

> **Status:** Endfassung der dialogischen Triade. Synthese der drei
> Konsenspläne aus Runde 2 (Codex / GPT / Claude). Ab Freigabe ist
> dieses Dokument der **verbindliche Planungsanker** für Slice 0.
>
> **Autor der Endfassung:** Claude (Opus 4.7, 1M-Kontext)
> **Datum:** 2026-05-02
> **Quellen (Runde 2):**
> - `docs/Runde 2/BAKTORIUM_KONSENSPLAN_CODEX.md`
> - `docs/Runde 2/BAKTORIUM_KONSENSPLAN_GPT.md`
> - `docs/Runde 2/BAKTORIUM_KONSENSPLAN_CLAUDE.md`
>
> **Methodik:** Punkt-für-Punkt-Abgleich der drei Runde-2-Pläne.
> Harter Konsens = übernommen. 2:1-Mehrheit = übernommen mit
> Begründung. Reine Einzel­vorschläge wurden nur übernommen, wenn
> sie technisch eindeutig überlegen sind. Konflikte sind in
> Sektion 3 einzeln dokumentiert.
>
> **Was neu ist gegenüber Runde 2:** finale 2:1-Auflösungen,
> erstmals konkrete Godot-Asset-Empfehlungen mit URLs (Sektion 8),
> erster Codex-Auftrag für Slice 0 (Sektion 11).

---

## 0. Zweck dieses Dokuments

Dieses Dokument legt das **Fundament** für Baktorium fest. Nach
Freigabe wird es zur Quelle für:

- `AGENTS.md` (Arbeitsvertrag)
- `docs/ARCHITEKTUR.md` (normative Schichten und Verbote)
- `docs/SIM_RULES.md` (Domain-Regeln)
- `docs/DECISIONS.md` (ADR-001..NNN)
- den ersten Codex-Auftrag für Slice 0

**Es ist kein Implementierungsplan.** Code-Skeletons entstehen erst
nach Slice-0-Freigabe.

---

## 1. Harter Konsens (alle drei Runde-2-Pläne einig)

### 1.1 Reset und Leitsatz
- Baktorium ist ein echter Neustart, keine Reparatur des
  Baktorio-/Vectorio-Codes.
- Inhalt von `baktorio` wird *nicht* übernommen.
- Architekturdoktrin und Workflow aus `Graviton` und
  `Calibration_Orchestrator` werden übernommen.
- Leitsatz: **Erst eine simple, diskrete, deterministische,
  testbare Hex-Zell-Simulation. Dann schrittweise emergente
  Tiefe. Grafik bleibt zunächst funktional.**

### 1.2 Domain
- **Geometrie:** Hexagon-Zellen. Eine Zelle belegt genau einen Hex.
- **Koordinaten:** Axial `(q, r)` ist die kanonische Sim-Wahrheit.
  Cube `(x,y,z)` mit `x+y+z=0` nur als abgeleitete Hilfsform für
  Distanz/Rotation. Niemals zweite Wahrheit gespeichert.
- **Topologie:** Bakterium = zusammenhängender Verbund von
  Hex-Zellen über die sechs axialen Nachbarrichtungen. Lückenlose
  Adjazenz ist harte Invariante.
- **Boundary:** abgeleitet — eine Zelle ist Boundary, wenn mind.
  ein Nachbarplatz leer ist. Nicht persistiert. `wall` ist eine
  Zellfunktion, nicht jede Boundary-Zelle muss `wall` sein.
- **Genom:** typisiertes Resource (kein Bitstring, kein einzelner
  Float), beeinflusst Wachstumsgewichtungen.
- **Energie v1:** globaler Organismus-Energiepool. Keine lokale
  Diffusion, kein Nachbartransfer. Lokale Energie ist Slice 7+.

### 1.3 Architekturdoktrin
- **Daten und Simulationszustand sind Wahrheit.** UI, Renderer,
  Debug, Szenen sind Projektion.
- **Schichten mit einseitigen Abhängigkeiten** (Sektion 5).
- **Keine Manager-Gottklasse.** Kleine Dateien mit klarer
  Verantwortung.
- **Keine Sim-Logik in `rendering/`, `ui/`, `debug/`, `scenes/`.**
- **Keine Nodes als Sim-Wahrheits-Container.** `CellBlock`,
  `OrganismBody`, `OrganismState` sind RefCounted-Datenklassen.
- **Konfiguration über Resources** mit `@export` /
  `@export_range` für Inspector-Tweaking.
- **Renderer liest nur Snapshots/State**, erzeugt nie Sim-Regeln.
- **`WorldGrid` und `OrganismState` werden atomar fortgeschrieben**
  (GPT's Konfliktauflösung): Zellplatzierung läuft über eine
  Sim-Methode, die beide Strukturen synchron aktualisiert und
  validiert.

### 1.4 Workflow
- **Slice-Regel:** "So groß wie möglich, so klein wie nötig."
- **Startprotokoll vor jeder nicht-trivialen Änderung:**
  1. `git status --short --branch` prüfen.
  2. `AGENTS.md` und betroffene kanonische Doku lesen.
  3. Betroffene Schicht benennen.
  4. Ziel, Annahmen, Risiken, Validierungspfad nennen.
  5. Bei Architekturzweifeln zuerst `DECISIONS.md` oder
     Plan-Artefakt aktualisieren.
- **Abschlussprotokoll:** Ziel des Slices, geänderte Dateien,
  betroffene Schichten, Tests/Validierung, Doku-Sync (oder
  Begründung), offene Risiken, Review-Fokus, Commit-Vorschlag mit
  Titel und Body.
- **Conventional Commits:** `feat`, `fix`, `perf`, `refactor`,
  `docs`, `test`, `chore`. Architekturänderungen sind je nach
  Wirkung `feat` oder `refactor`; der Body trägt die
  Architektur-Begründung.
- **Keine Auto-Commits, Auto-Pushes oder PRs ohne explizite
  Freigabe.**
- **Headless-Validierung ab Slice 0**, deterministische Seeds.

### 1.5 Performance-Disziplin
- Fixed-Step-Sim, Renderer entkoppelt.
- Keine Node-pro-Zelle als Architektur.
- Zellzugriff über Dictionary keyed by axial coord.
- Topologie inkrementell/dirty pflegen.
- Snapshot-Layer für Renderer und Debug.
- Keine teuren Full-Scans pro Frame, wenn ein Tick-/Event-Pfad
  reicht.
- `queue_redraw()` nur bei relevanter Änderung.

### 1.6 Nicht-Ziele bis einschließlich Slice 5
- Bewegung, Sicht/Sensorik, Mund/Verdauung, Dornen/Kampf, Schaden
- echte Tochterorganismen (separate Organismen), Mutation,
  Vererbung, Populationsevolution
- mehrere Welt-Substrate, Tag/Nacht-Zyklus, Lichtkarte
- Save/Load, Multiplayer/Networking
- Shader-/High-End-Grafik, organische Verformung, Fluid/Softbody
- prozedurale Animationen, UI-Polish über das Lab hinaus
- MultiMesh oder TileMapLayer als Pflicht (Performance-Spike erst
  bei Bedarf)

---

## 2. 2:1-Mehrheitsentscheidungen (mit Begründung)

| Thema | Codex | GPT | Claude | **Endentscheidung** |
|-------|-------|-----|--------|---------------------|
| Sim-Regeln-Doku | `CELL_SYSTEM.md` | `SIM_RULES.md` | `SIM_RULES.md` | **`SIM_RULES.md`** (2:1; breiterer Scope: Hex-Modell + Zellen + Energie + Wachstum + Genom + Tick) |
| `CLAUDE.md` separat | nein | ja (kurze Brücke) | nein | **nein** (2:1; Review-Fokus lebt in einer eigenen Sektion in `AGENTS.md`) |
| Pflicht-Autoloads in Slice 0 | keine | keine | exakt zwei | **keine in Slice 0** (2:1; Lab-Szene als Composition Root; Autoloads nur per ADR später) |
| Pflichtzelle Naming | `core` | `energy_core` | `energy_core` | **`energy_core`** (2:1; Naming sagt aus, was die Zelle technisch tut. Identität in v1 implizit, keine separate `core`-Zelle) |
| Slice-Granularität | 4 Slices, Body+Renderer gebündelt | 5 Slices, Body und Renderer getrennt | 4 Slices, Body+Renderer gebündelt | **5 Slices** (2:1 für getrennten Renderer-Slice; Body kann headless validiert werden bevor Renderer kommt) |
| Globales `WorldGrid` ab Slice 0/1 | nein | implizit ja | ja | **erst ab Slice 5 (Wachstum)** (Mittelweg; vorher reicht `OrganismBody.cells` als Dictionary, weil nur ein Organismus existiert. Atomare `place_cell()`-Schnittstelle ab Tag 1 als Konzept) |
| Genom-Genvektor | 8 Felder (mit `mutation_rate_dormant`) | 6 Felder | 8 Felder (mit `mutation_rate`) | **8 Felder** (2:1) — siehe Sektion 4.4 |
| Render-Orientierung | offen / Render-Frage | pointy-top default | pointy-top default | **pointy-top default**, per `RenderConfig` umschaltbar; Sim bleibt agnostisch |
| Renderer v1-Strategie | `_draw()` einfach | `_draw()` einfach | `_draw()` v1, MultiMesh v3 | **`_draw()`** (alle drei einig, keine MultiMesh-Pflicht in v1) |
| Test-Runner | eigener schlanker Runner | eigener Runner-Skelett | eigener Runner | **eigener** (3:0); GUT als Migrations­option für später |

### Detail-Begründung der wichtigsten 2:1-Entscheidungen

**Slice-Granularität (5 statt 4):** GPT's Argument schlägt:
> "Mein ursprünglicher Slice 1 war noch zu groß, weil er
> Hex-Grundlage, statischen Organismus und Rendering bereits
> koppelte. Die bessere Reihenfolge: erst Hex-Topologie beweisen,
> dann Körper, dann Lab, dann Energie, dann Wachstum."

Das entkoppelt Body-Korrektheit (headless testbar) von Renderer-
Komplexität. Claude's Sorge "Body ohne Renderer hat keine visuelle
Validierung" ist gültig — wird durch deterministische Seed-Reihen
und Headless-Validator gelöst, nicht durch Bündelung.

**Pflicht-Autoloads erst per ADR (statt Claude's "exakt zwei"):**
Codex und GPT argumentieren: "Gravitons Autoload-Regel passt zu
einem reifen Projekt, wäre für Baktoriums Foundation aber zu früh
globale Kopplung." Wir übernehmen die *Regel* (max. zwei,
ADR-Pflicht), nicht die *konkrete Zahl ab Tag 1*. Die Lab-Szene
ist Composition Root und verdrahtet Services explizit.

**`SIM_RULES.md` statt `CELL_SYSTEM.md`:** Codex' Argument für
`CELL_SYSTEM.md` war Domänenklarheit. GPT's Gegenargument: "Sim-
Regeln, Hex-Regeln, Zelltypen, Genomidee und Tick-Reihenfolge
sollten nicht isoliert betrachtet werden — sie hängen an einem
gemeinsamen Sim-Modell." Claude einig. Übernommen.

---

## 3. Bewusst nicht übernommen (mit Begründung)

- **Pflicht-Autoloads ab Slice 0** (Claude) — siehe oben.
- **Codex' separate `CellFunctionDef`-Pflichtfelder
  `growth_cost` und `protection_value` als aktive Werte in v1**
  (Codex) — bleiben im Schema, aber **nur** für Slice 5 aktiv.
  Begründung: Schema-Stabilität ohne v1-Komplexität.
- **`ORCHESTRATOR_RESULT`-Block-Pflicht** (Claude) — bleibt
  optional. Aktivierung nur, wenn Nutzer den Orchestrator
  konkret einsetzt.
- **Sofortiges globales `WorldGrid` als verpflichtende
  Datenstruktur** (Claude) — verschoben auf Slice 5. Schnittstelle
  konzeptuell ab Tag 1 (`SimulationService.place_cell` ist die
  einzige Zellplatzierungs-API), Implementierung erst wenn nötig.
- **`cytoplasm`/neutrale Füllzelle** — bleibt offen. Erst
  einführen, wenn der Slice-2-Startkörper sonst unnatürlich wird,
  dann als ADR.

---

## 4. Domain-Modell (final)

### 4.1 Atomare Einheiten

- **`HexCoord`** (`src/core/hex/`)
  - Wertobjekt `(q, r)`, immutable
  - reine Funktionen: `neighbors()`, `distance(other)`, `ring(n)`,
    `to_cube()`, `to_axial_key() -> Vector2i`
  - keine Godot-Node-Abhängigkeit
- **`CellBlock`** (`src/body/`)
  - `coord: Vector2i` (axial key, lokal zum Organismus)
  - `function_id: StringName` — Tag, **keine Klassen­hierarchie**
  - `state_flags: int` (Bitfeld; v1 leer)
  - kein eigenes `_process()`, keine Node, keine lokale Energie
- **`OrganismBody`** (`src/body/`)
  - `cells: Dictionary[Vector2i, CellBlock]`
  - `body_topology: BodyTopology` (Boundary/Frontier/Adjazenz,
    dirty-getrieben)
  - keine Energie, keine Tick-Wahrheit
- **`OrganismState`** (`src/sim/`)
  - `id: int` (StableId)
  - `energy: float` (globaler Pool)
  - `growth_charge: float`
  - `age_ticks: int`
  - `alive: bool`
  - Referenz auf `OrganismBody` und `Genome`
- **`WorldState`** (`src/sim/`)
  - `seed: int`
  - `tick: int`
  - `organisms: Array[OrganismState]` (in v1 Länge 1)
  - **kein** globales `WorldGrid` in v1; wird in Slice 5 ergänzt.
- **`Genome`** (`src/genetics/`)
  - typisiertes Resource mit den 8 Genen aus 4.4

### 4.2 Pflicht-Zellfunktionen v1

| Tag | Rolle | v1-Verhalten |
|-----|-------|--------------|
| `energy_core` | Pflichtzelle. Identitäts- und Energieanker. | speichert globalen `OrganismState.energy` (= Repräsentation, nicht eigene Pufferung pro Zelle) |
| `photosynthesis` | Energiequelle | erzeugt Energie/Tick; optional `requires_surface`-Multiplikator |
| `reproduction` | Wachstumsmotor | wandelt Energieüberschuss in `growth_charge` |
| `wall` | Strukturschutz | nur Topologie/Material in v1, kein HP-System |

`cytoplasm` bleibt **offen** und wird nicht in v1 eingeführt.

### 4.3 `CellFunctionDef` (Resource pro Zellfunktion)

```gdscript
# Schema, keine Implementierung
function_id: StringName       # eindeutig
label: String                  # für UI
base_color: Color              # Renderer-Default
energy_production: float       # /Tick
maintenance_cost: float        # /Tick
growth_cost: float             # einmalig bei Anbau (Slice 5+)
requires_surface: bool         # Photo-Bonus an Boundary
protection_value: float        # für späteren Damage-Slice
```

`CellFunctionCatalog` (Resource): Array aller erlaubten Funktionen,
Pflichtfunktionen-Liste, v1/v2-Feature-Gates.

### 4.4 Genom v1 (8 Felder)

| Gen | Range | Wirkung in v1 |
|-----|-------|--------------|
| `photosynthesis_bias` | 0..1 | Gewichtung von Photo-Zellen beim Body-Bau & Wachstum |
| `wall_bias` | 0..1 | Tendenz zu mehr Wand-Zellen |
| `reproduction_bias` | 0..1 | wann Wachstum auslöst (Schwelle) |
| `growth_spread` | 0..1 | kompakt vs. ausgreifend (Codex' compactness/branching kombiniert) |
| `symmetry_bias` | 0..1 | geordnete vs. zufällige Wachstumsrichtung |
| `surface_preference` | 0..1 | Photo-Zellen bevorzugt an Boundary |
| `energy_efficiency` | 0..1 | reduziert Maintenance |
| `mutation_rate` | 0..1 | **ruhend** in v1, aktiviert ab Slice 6 |

`mutation_rate` bleibt im Schema, damit `GenomeConfig` bei
Aktivierung in Slice 6+ keine Schema-Änderung braucht.

### 4.5 Welt v1

- Ein einzelner Organismus pro Lab-Run.
- Sonne in v1 = globaler Skalar `sun_intensity`.
- Lichtkarte / Substrat / mehrere Organismen → Slice 6+.

---

## 5. Architektur (final)

### 5.1 Schichten

```
ui / debug / scenes  ← Composition Root, reine Projektion
       ▲
   rendering          ← liest Snapshots, zeichnet Hex-Polygone
       ▲
    runtime           ← Snapshots, Caches, abgeleitete Lesemodelle
       ▲
      sim             ← autoritative Logik, Services, Tick-Orchestrierung
       ▲
   body / genetics    ← Daten-Klassen Organism, CellBlock, Genome
       ▲
   config / core      ← Hex-Math, RNG, IDs, Resource-Skeletons
```

**Dependency-Richtung:** strikt einseitig nach unten. Keine
Rückabhängigkeiten. `config/` und `core/` werden quer gelesen,
speichern aber **keine Laufzeitwahrheit**.

### 5.2 Verzeichnisstruktur

```
project.godot
AGENTS.md
README.md

docs/
  ARCHITEKTUR.md
  SIM_RULES.md
  STATUS.md
  NEXT_STEPS.md
  DECISIONS.md
  FINDINGS.md
  BAKTORIUM_FUNDAMENT_v1.md   ← dieses Dokument; nach Slice 0 in archive/

src/
  core/
    hex/
      hex_coord.gd
      hex_grid_math.gd
    rng/
      seeded_rng.gd
    ids/
      id_registry.gd
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
  body/
    cell_block.gd
    organism_body.gd
    body_topology.gd
    body_factory.gd
  sim/
    world_state.gd
    organism_state.gd
    simulation_service.gd
    energy_system.gd
    growth_system.gd
    # world_grid.gd  ← erst in Slice 5
  runtime/
    derived_organism_snapshot.gd
    simulation_snapshot_cache.gd
  rendering/
    hex_organism_renderer.gd
    hex_debug_overlay.gd
    organism_palette.gd
  ui/
    lab/
      simulation_lab_panel.gd
      organism_inspector.gd
  debug/
    perf_probe.gd
    debug_counters.gd
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
    energy_core.tres
    photosynthesis.tres
    reproduction.tres
    wall.tres
  cell_function_catalog.tres

tools/
  validate_hex_foundation.gd
```

### 5.3 Autoload-Regel

- **Slice 0 hat keine projekt-eigenen Autoloads.**
- Lab-Szene `simulation_lab.tscn` ist Composition Root und
  verdrahtet Services explizit als Kind-Nodes.
- Jede neue Autoload-Einführung braucht eine ADR mit Begründung
  "warum dies globale Wahrheit ist und keine Komposition".
- Realistische Kandidaten später: `TimeService` (ab Slice 4 mit
  Energie-Tick), evtl. `SimRegistry` (ab Slice 5 mit `WorldGrid`).

### 5.4 Autoritätstabelle

| Thema | Autoritative Quelle | Schreibrecht |
|-------|---------------------|--------------|
| Hex-Math | `core/hex/*` | reine Funktionen |
| Tuningwerte | `config/*.gd` + `resources/config/*.tres` | nur Editor; UI darf Runtime-Kopien tweaken, nie `.tres` mutieren |
| Genomwerte | `genetics/genome.gd` | `GenomeFactory`; später `MutationSystem` |
| Lokaler Zellkörper | `body/organism_body.gd` | `BodyFactory` (Slice 2), `GrowthSystem` (Slice 5) |
| Zellfunktion | `CellBlock.function_id` + `CellFunctionCatalog` | nur Editor |
| Organismus-Energie | `OrganismState.energy` | `EnergySystem` |
| Wachstumsladung | `OrganismState.growth_charge` | `GrowthSystem` |
| Tick-Orchestrierung | `sim/simulation_service.gd` | nur SimulationService |
| Zellplatzierung | `SimulationService.place_cell()` | atomare Schnittstelle (Slice 5: aktualisiert `WorldGrid` + `OrganismBody` zusammen) |
| Renderdaten | `runtime/derived_organism_snapshot.gd` | read-only, abgeleitet |
| UI-Eingaben | `LabConfig` Runtime-Kopie | nur UI-Controls |

**Niemals autoritativ:** `Node2D.position`, `Polygon2D`-Vertices,
Debug-Overlay, UI-Labels, Editor-Szenenwerte (außer Composition),
Screenshots.

### 5.5 Tick-Reihenfolge (ab Slice 4)

1. **Topologie aktualisieren** (dirty: Boundary, Frontier-Hexe).
2. **Energie produzieren** (Photo, ggf. Surface-Bonus).
3. **Energie verbrauchen** (Maintenance pro Zelle).
4. **Wachstumsladung aktualisieren** (Reproduction wandelt
   Überschuss in `growth_charge`).
5. **Wachstum ausführen** (Slice 5+: max. N neue Zellen pro Tick
   an freien Frontier-Hexen, Scoring per Genom + Topologie).
6. **Invarianten prüfen** (connected, keine Doppelbelegung,
   Pflichtzellen vorhanden, Werte endlich).
7. **Snapshot aktualisieren** (für Renderer und Debug).

---

## 6. Kanonisches Doku-Set (8 Dateien)

| Datei | Funktion | Update-Frequenz |
|-------|----------|-----------------|
| `AGENTS.md` | Arbeitsvertrag für alle Agenten (inkl. Review-Fokus) | selten |
| `README.md` | Kurzstart, Projektzweck, wichtigste Befehle, Doku-Übersicht | selten |
| `docs/ARCHITEKTUR.md` | normative Schichten, Autoritäten, Verbote, Autoload-Regeln | bei Architektur-ADRs |
| `docs/SIM_RULES.md` | Hex-Modell, Zellfunktionen, Energie, Wachstum, Genom, Tick-Reihenfolge, Nicht-Ziele | bei Sim-Regel-Änderungen |
| `docs/DECISIONS.md` | ADR-001..NNN | bei jeder Architekturentscheidung |
| `docs/STATUS.md` | aktueller realer Stand: implementiert, validiert, sichtbar, offen | pro Slice / pro PR |
| `docs/NEXT_STEPS.md` | exakt nächster Arbeitsblock + Gate + Nicht anfangen | pro Slice |
| `docs/FINDINGS.md` | Bugs, Review-Findings, Debug-Befunde, geplante Korrekturen | bei Fund |

**Bewusst nicht:** `CLAUDE.md`, `HANDOFF.md`, `AI_KONTEXT.md`,
separate `BUGS.md`, separate `PERFORMANCE.md`, Probe-Archive.

### Priorität bei Widersprüchen

1. `docs/ARCHITEKTUR.md` — Schichten, Autoritäten, Verbote
2. `docs/DECISIONS.md` — Architekturentscheidungen
3. `docs/SIM_RULES.md` — Sim-Regeln
4. `docs/STATUS.md` — aktueller Stand
5. `docs/NEXT_STEPS.md` — nächster Arbeitsblock
6. `AGENTS.md` — Arbeitsprozess
7. `README.md` — Orientierung
8. ältere Notizen/Handoffs — Hintergrund

---

## 7. Slice-Roadmap (final, 5 Slices)

### Slice 0 — Repo-, Doku- und Test-Fundament

**Ziel:** Verzeichnisstruktur + alle 8 kanonischen Docs + leere
Config-Resource-Skeletons + minimaler Test-Runner + minimal
ladende Lab-Szene.

**Acceptance:**
- alle 8 Doku-Dateien existieren (Stub-Inhalt erlaubt)
- Verzeichnisstruktur aus 5.2 angelegt
- `src/tests/test_runner.gd` läuft headless (auch mit 0 Tests)
- `tools/validate_hex_foundation.gd` als Skelett vorhanden
- Projekt öffnet in Godot ohne Fehler
- ADRs angelegt:
  - ADR-001: Hex-Modell (axial, Sim-agnostisch)
  - ADR-002: Daten vs. Nodes
  - ADR-003: Cell-Funktionen als Daten-Tags
  - ADR-004: Doku-Set 8 Dateien
  - ADR-005: keine Pflicht-Autoloads in Slice 0
- `NEXT_STEPS.md` definiert Slice 1

**Performance-Gate:** entfällt (kein Sim-Code).

**Nicht anfangen:** Hex-Math, Genom, Energie, Wachstum, Renderer-
Polish, Population.

### Slice 1 — Hex-Kern und Topologie

**Ziel:** `HexCoord`, Nachbarn, Distanz, axialer Key,
Connectedness-Check, Boundary-Erkennung, Frontier-Liste. Kein
Renderer, kein Organismus, kein Genom.

**Acceptance:**
- Tests für 6 Nachbarn, axiale Distanz, bekannte Formen
  (Linie, Ring, Cluster), Connectedness, Boundary
- `core/hex/` keine Godot-Node-Abhängigkeit
- Sim kennt keine Pixelorientierung

**Performance-Gate:** Connectedness-Check für 1000-Zell-Cluster
< 5 ms.

### Slice 2 — Genom + Startkörper (headless)

**Ziel:** `GenomeFactory` (deterministisch aus Seed), `Genome`-
Resource mit den 8 Genen, `BodyFactory` baut Pflichtzellen-Körper.
Kein Renderer.

**Acceptance:**
- gleicher Seed → gleicher Körper
- 20 Seeds → unterscheidbare aber valide Körper
- alle Pflichtzellen vorhanden, Körper connected, keine
  Doppelbelegung in `OrganismBody.cells`
- `cytoplasm` nicht eingeführt
- Genom inspector-lesbar
- `Renderer` und `Lab-Szene` noch nicht beteiligt

**Performance-Gate:** 1000 Body-Generierungen über 20 Seeds
< 2 s headless.

### Slice 3 — Lab-Renderer und Inspector

**Ziel:** `simulation_lab.tscn` als Composition Root,
`HexOrganismRenderer` als `Node2D` mit `_draw()` aus Snapshot,
Seed-Navigation, Debug-Overlay für Koordinaten/Boundary/
Zellfunktion, Inspector zeigt `SimulationConfig`, `GenomeConfig`,
`RenderConfig`.

**Acceptance:**
- 20 Seeds visuell schnell prüfbar (Hotkey/UI-Button)
- Renderer erzeugt keine Sim-Entscheidungen
- UI mutiert keine `.tres`-Assets zur Laufzeit
- Debug-Overlay verändert keinen Sim-State
- erste Asset-Integration nach Empfehlung in Sektion 8

**Performance-Gate:** 1 Organismus mit 50 Zellen flüssig
(60 FPS).

### Slice 4 — Energie v1

**Ziel:** Photo erzeugt Energie, Maintenance verbraucht,
`OrganismState.energy` läuft deterministisch. `TimeService` als
erstes Autoload (mit ADR-006).

**Acceptance:**
- keine negativen / NaN / Inf-Werte
- Headless-Test: bekannter Körper → bekannte Bilanz
- Inspector ändert `sun_intensity` → sichtbarer Effekt < 1 s
- bekannter Körper über N Ticks deterministisch reproduzierbar

**Performance-Gate:** 1 Organismus mit 100 Zellen flüssig.

### Slice 5 — Wachstum v1 (+ erstes globales `WorldGrid`)

**Ziel:** `Reproduction`-Zellen sammeln Wachstumsladung, neue
Zellen entstehen an Frontier-Hexen, Genom beeinflusst Zelltyp-
Auswahl und Wachstumsrichtung. **`world_grid.gd` wird hier
eingeführt** (atomare `place_cell()`-Methode).

**Acceptance:**
- Wachstum bleibt connected
- Wachstum pro Tick begrenzt (`GrowthConfig.max_growth_per_tick`)
- `WorldGrid` verhindert Doppelbelegung
- gleicher Seed → gleiches Wachstum
- Debug-Overlay zeigt Wachstumsentscheidungs-Score

**Performance-Gate:** 1 Organismus auf 250 Zellen wachsen
lassen, flüssig.

### Slice 6+ — Erst nach Slice 5 entscheiden

- mehrere Organismen, echtes WorldState mit N Organismen
- echte Tochter-Reproduktion in zwei Organismen
- Mutation
- danach Bewegung / Sensorik / Verdauung / Kampf / Lichtkarte

Jeder Slice 6+ braucht eigenes Plan-Artefakt in `docs/`.

---

## 8. Godot-Asset-Empfehlungen (NEU für Endfassung)

Der Nutzer wünscht Godot-Assets, die das Projekt **effektiver,
schöner und umsetzbarer** machen. Einsatz strikt nach Konsens:
*Addons dürfen Darstellung, Debugging oder Bedienung verbessern,
aber niemals Simulationswahrheit einführen.* Kein Asset wird
aufgenommen, bevor ein konkreter Slice davon profitiert.

### 8.1 Empfohlen — direkt einplanen

**Debug Menu** (godot-extended-libraries)
*Slice: 3 (mit Renderer)*
*Status: Pflichtempfehlung*

In-Game-FPS/Frametime/CPU-/GPU-Time mit Graphen, Hardware-Info,
F3-Hotkey für compact/full/off. Funktioniert mit allen Renderern,
2D und 3D, läuft im Editor und in Exports. Genau das, was Graviton
als Vorbild hatte.

- Asset Library: <https://godotengine.org/asset-library/asset/1902>
- GitHub: <https://github.com/godot-extended-libraries/godot-debug-menu>

Begründung: spart uns selbstgebaute FPS-Logik. Wir behalten
trotzdem einen eigenen `PerfProbe` für sim-spezifische Counter
(Tick-Dauer, Cell-Count, Energy-Throughput), weil DebugMenu nur
Engine-Metriken misst.

**Antialiased Line2D** (godot-extended-libraries)
*Slice: 3 (mit Renderer)*
*Status: Empfohlen für lesbare Hex-Outlines*

Bietet `AntialiasedLine2D`, `AntialiasedPolygon2D`,
`AntialiasedRegularPolygon2D`. Letzteres zeichnet Hexagons direkt
und sauber. Performt über eine 256×256 Custom-Texture, läuft auf
GLES2/3, Mobile, Web.

- Asset Library: <https://godotengine.org/asset-library/asset/1266>
- GitHub: <https://github.com/godot-extended-libraries/godot-antialiased-line2d>

Begründung: das Lab soll sauber lesbar sein, ohne in Shader-Spielerei
zu gehen. `AntialiasedRegularPolygon2D` ist die einfachste Lösung,
um Hexes ohne aliasing-Treppen zu zeichnen. Erst Slice 3, weil
Slice 1–2 keinen Renderer haben.

### 8.2 Bedingt empfohlen — nach Performance-Messung

**Eigener `_draw()`-Renderer (Built-in)**
*Slice: 3 (Default-Renderer in v1)*

Kein Asset nötig. `Node2D._draw()` mit `draw_polygon()` oder
`draw_colored_polygon()` reicht für 50–250 Zellen. Wenn das
Performance-Gate kippt, *dann* Migrationspfad zu MultiMesh oder
TileMapLayer.

**TileMapLayer (Built-in seit Godot 4.3)**
*Slice: 5+ (Performance-Spike, falls nötig)*

Godot 4 hat native Hex-TileMap-Unterstützung über `TileMapLayer`
(Nachfolger von `TileMap`, der ab Godot 4.3 deprecated ist).
Hexagonal-Modus mit pointy-top oder flat-top eingebaut, Mapping
zwischen Welt- und Map-Koordinaten via `world_to_map()`.

- Doku: <https://docs.godotengine.org/en/latest/classes/class_tilemaplayer.html>
- Hex-Demo: <https://godotengine.org/asset-library/asset/406>

**Wann nutzen?** Wenn `_draw()` bei 250+ Zellen unter 60 FPS fällt
und MultiMesh-Setup-Aufwand höher wäre als TileMapLayer-Atlas-Bau.
**Wann *nicht* nutzen?** Wenn dynamisches Wachstum jeden Tick neue
Zellen mit individuellen Farben/States erzeugt — dann ist
TileMapLayer eher fummelig. MultiMeshInstance2D skaliert in dem
Fall besser.

**MultiMeshInstance2D (Built-in)**
*Slice: 5+ (falls TileMapLayer ausscheidet)*

Eine MMInst pro Cell-Funktion, Instances = lebende Zellen mit
dieser Funktion. Skaliert auf Tausende. Kein Asset.

### 8.3 Nicht empfehlen — bewusst weglassen

**GUT (Godot Unit Test)**
*Begründung: Konsens war eigener schlanker Runner ab Slice 0.
GUT ist als Migrations­option später möglich, aber bringt
Plugin-Kopplung, die wir in der Foundation vermeiden.*

- Asset Library: <https://godotengine.org/asset-library/asset/1709>
- GitHub: <https://github.com/bitwes/Gut>

**GdUnit4** — gleiche Einschätzung wie GUT, plus mehr Komplexität.

- Asset Library: <https://godotengine.org/asset-library/asset/4390>

**PhantomCamera** — 2D-Camera mit Folgelogik. Lab braucht keine
Folgelogik (Organismus statisch in Slice 2–4, einzelner Organismus
in Slice 5). Würde später relevant, falls mehrere Organismen
verfolgt werden. Slice 6+.

**shaderV / Shader-Asset-Libs** — Shader-Spike ist kein
Foundation-Thema. Bewusst nicht in Slice 0–5.

**Beehave (Behavior Trees)** — keine Behavior-Bäume in Sim.
Verhalten ist Tag-basierte Energie-/Wachstumslogik, nicht
Entscheidungsbäume.

**Imgui-Godot** — Godot's Inspector reicht für Slice 3-Lab.
Imgui wäre attraktiv für komplexe Debug-UIs, aber das ist
Slice 6+.

**Better Terrain / Cyclops Level Builder / Maaack's** —
themenfremd.

### 8.4 Asset-Integrations-Regeln (verbindlich)

1. **Kein Asset darf Sim-Wahrheit lesen oder schreiben.** Assets
   leben in `rendering/`, `debug/`, `ui/` oder `addons/`.
2. **Asset-Add per ADR.** Begründung muss enthalten: welcher Slice
   profitiert, welche Schicht hängt davon ab, welche Alternative
   geprüft wurde, was passiert wenn das Asset einfriert oder bricht.
3. **Asset-Aufnahme nur als bewusstes Tool.** Kein "wir nehmen X,
   weil es cool ist."
4. **Asset-Versionen in `README.md`** dokumentieren (Name, Version,
   Quelle).
5. **Lock the version.** Wir kopieren Assets in `addons/` und
   committen sie, statt auf Asset-Library-Updates zu vertrauen.

---

## 9. Validierungsstrategie

Headless-Validator `tools/validate_hex_foundation.gd` prüft pro
Slice mindestens:

**Slice 1:**
- axial neighbor count = 6
- axial Distanz korrekt
- bekannte Formen (Linie, Ring, Cluster) connected
- Boundary-Erkennung für Testformen

**Slice 2:**
- gleicher Seed → gleicher Körper
- 20 Seeds → 20 verschiedene aber valide Körper
- alle Pflichtzellen vorhanden
- keine Doppelbelegung in `OrganismBody.cells`
- Renderer ist nicht beteiligt
- Config-Resources nicht zur Laufzeit mutiert

**Slice 3:**
- Renderer liest keine Genome direkt (nur Snapshot/Palette)
- UI mutiert keine `.tres`-Assets
- Debug-Overlay verändert keinen Sim-State

**Slice 4:**
- Energie-Tick deterministisch
- keine negativen/NaN/Inf-Werte
- Energie bleibt im erlaubten Bereich

**Slice 5:**
- Wachstum bleibt connected
- Wachstumskosten korrekt abgezogen
- `WorldGrid` verhindert Doppelbelegung
- Wachstum pro Tick begrenzt

Manueller Lab-Check pro Slice (ab Slice 3):
- Seed-Reihe durchklicken
- Debug-Overlay an/aus
- Tick/Pause/Reset
- Inspector-Slider → sichtbarer Effekt < 1 s

---

## 10. Risiken und Gegenmaßnahmen

| Risiko | Priorität | Gegenmaßnahme |
|--------|-----------|---------------|
| Hex-Math-Fehler (off-by-one in Adjazenz) | P0 | Unit-Tests für `core/hex/` ab Slice 1 |
| `WorldGrid` und `OrganismState` widersprechen sich | P0 | atomare `SimulationService.place_cell()` ab Slice 5 |
| Renderer skaliert nicht | P0 | Performance-Gates pro Slice + 3-Phasen-Plan (`_draw()` → MultiMesh / TileMapLayer) |
| Grafik wird zu früh Hauptthema | P0 | harte Render-Slice-Reihenfolge nach Sim, Asset-Aufnahmeregel 8.4 |
| Doku wuchert wie in Graviton/Orchestrator | P1 | nur 8 kanonische Docs, alte Notizen archivieren |
| Genom-Resource erschwert späteren Crossover | P1 | ADR über Erweiterungspfad in Slice 6 |
| Globale Energie zu eng für Slice 6+ | P1 | `WorldService` kapselt schon `get_light_at(world_pos)` als Funktion |
| Doku-Drift nach mehreren Slices | P1 | Pflicht-Update STATUS+NEXT_STEPS pro Slice-Commit |
| Asset bricht bei Godot-Update | P1 | Assets in `addons/` lokal committen, Version dokumentieren |
| Mikro-Slices | P2 | Slice-Regel in `AGENTS.md` |
| Scope-Erweiterung durch Agenten | P2 | Startprotokoll + Review-Handover + Doku-Sync |

---

## 11. Erster Codex-Auftrag (Slice 0)

```text
Bitte setze für Baktorium ausschließlich Slice 0 um.

Quelle: docs/Runde 2/Runde 3/BAKTORIUM_FUNDAMENT_v1.md
        (verbindlich, lies vollständig vor Beginn)

Ziel:
- Verzeichnisstruktur gemäß Sektion 5.2 anlegen.
- Die 8 kanonischen Doku-Dateien (Sektion 6) anlegen mit
  Stub-Inhalt, der die wichtigsten Punkte aus dem Fundament-
  Dokument zusammenfasst:
  - AGENTS.md (Workflow Sektion 1.4 + Review-Fokus)
  - README.md (Kurzstart, Doku-Übersicht, Doku-Hierarchie 6.5)
  - docs/ARCHITEKTUR.md (Sektionen 5.1–5.4)
  - docs/SIM_RULES.md (Sektionen 1.2 + 4 + 5.5)
  - docs/DECISIONS.md (ADR-001..005, Templates für weitere)
  - docs/STATUS.md (Stand: Slice 0 in Arbeit)
  - docs/NEXT_STEPS.md (Slice 1 Acceptance + Performance-Gate)
  - docs/FINDINGS.md (leer + Format-Erklärung)
- Leere Config-Resource-Skeletons anlegen (resources/config/*.tres)
  als noch nicht ausgefüllte Resource-Dateien.
- src/tests/test_runner.gd minimal:
    läuft headless, ruft eine leere Suite auf, exitcode 0.
- tools/validate_hex_foundation.gd als Skelett:
    headless, exitcode 0, druckt "Slice 0 validation: OK".
- scenes/lab/simulation_lab.tscn minimal:
    eine Node2D-Wurzel, lädt ohne Fehler.
- project.godot konfigurieren (kein Autoload).

Nicht-Ziele in Slice 0:
- keine Hex-Math
- keine Genom-Logik
- keine Energie
- kein Wachstum
- keine Population
- kein echter Renderer (Stub-Szene reicht)
- keine Godot-Assets/Addons
- keine Pflicht-Autoloads

Arbeitsregeln:
- Halte Szenen, UI, Debug und Renderer frei von Sim-Entscheidungen.
- Änderungen so groß wie möglich, so klein wie nötig.
- Keine Auto-Commits, kein Push, keine PRs ohne Freigabe.

Validierung:
- Projekt öffnet in Godot ohne Fehler.
- Lab-Szene lädt.
- Doku ist widerspruchsfrei und referenziert das Fundament-Dokument.
- test_runner und validator laufen headless.

Abschluss:
- Liste geänderter Dateien.
- Validierungsergebnis.
- Offene Risiken.
- Doku-Sync-Bestätigung.
- Commit-Vorschlag (Format aus AGENTS.md).
```

---

## 12. Was *nicht* in diesem Dokument steht

- Konkrete Klassennamen jenseits 5.2 — Codex' Job nach Slice 0.
- Methoden-Signaturen.
- Code-Skeletons (auch keine GDScript-Snippets).
- Render-Shader-Details.
- Save/Load-Format.
- Konkrete Mutations- oder Reproduktionsregeln.
- UI-Layout-Mockups.

---

## 13. Plan-Artefakt-Block (für Calibration-Orchestrator-Nutzung)

```markdown
### Plan-Artefakt: Baktorium-Fundament v1

**Ziel:** Hexagonale, deterministische Zell-Sim aufbauen —
Repo/Doku → Hex-Topologie → Genom+Body → Lab+Renderer → Energie
→ Wachstum.

**Approach:** Drei-Stimmen-Konsens (Codex / GPT / Claude) durch
zwei Runden synthetisiert. Endfassung dieses Dokument.

**Schritte:**
1. Slice 0: Repo, Doku, Test-Runner, leere Configs (Sektion 11).
2. Slice 1: Hex-Kern + Topologie-Tests.
3. Slice 2: Genom + Startkörper headless.
4. Slice 3: Lab + Renderer + Inspector + Asset-Integration.
5. Slice 4: Energie v1 + erstes Autoload (TimeService).
6. Slice 5: Wachstum v1 + globales WorldGrid.

**Abhängigkeiten:** Slice N+1 startet erst nach validiertem
Performance-Gate von Slice N und Doku-Update.

**Nicht-Ziele:** Sektion 1.6.

**Risiken:** Sektion 10 (P0: 4, P1: 5, P2: 2).

**Validierung:** Sektion 9 (headless + manuell).

**Evidenz:**
- Drei Runde-1-Pläne und drei Runde-2-Konsenspläne in docs/.
- Quell-Repos analysiert: Graviton, baktorio,
  Calibration_Orchestrator.
- Asset-Recherche dokumentiert mit URLs (Sektion 8).
```

---

*Ende Endfassung v1. Bei Freigabe geht der Codex-Auftrag aus
Sektion 11 raus.*

---

## Anhang: Quellen

- Godot Asset Library: <https://godotengine.org/asset-library/asset>
- Debug Menu Plugin: <https://github.com/godot-extended-libraries/godot-debug-menu>
- Antialiased Line2D Plugin: <https://github.com/godot-extended-libraries/godot-antialiased-line2d>
- TileMapLayer Doku (Godot 4): <https://docs.godotengine.org/en/latest/classes/class_tilemaplayer.html>
- TileSets / Hex-Tutorial: <https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html>
- Hex Grid Demo (Asset): <https://godotengine.org/asset-library/asset/406>
- GUT (Godot Unit Test): <https://github.com/bitwes/Gut>
- GdUnit4: <https://github.com/MikeSchulze/gdUnit4>
- Red Blob Games Hex Guide (theoretische Referenz für Sektion 4.1): <https://www.redblobgames.com/grids/hexagons/>
