# Baktorium — Konsens-Plan v1

> **Status:** Konsens-Synthese aus den drei Einzelplänen von Claude, Codex
> und ChatGPT. Soll vom Nutzer und parallel von Codex gegengelesen werden,
> bevor Slice 0 startet.
>
> **Autor der Synthese:** Claude (Opus 4.7, 1M-Kontext)
> **Datum:** 2026-05-02
> **Quellen:**
> - `docs/BAKTORIUM_NEUSTART_CANVAS_CLAUDE.md`
> - `docs/BACTORIUM_NEUSTART_CANVAS_codex.md`
> - `docs/BAKTORIUM_NEUSTART_CANVAS_GPT.md`
>
> **Methode:** Punkt-für-Punkt-Abgleich. Wo alle drei einig waren →
> Konsens. Wo zwei einig waren → Mehrheitsentscheidung mit
> Begründung. Wo eine Stimme einen technisch überlegenen Vorschlag
> hatte → übernommen mit Begründung. Konflikte sind in Sektion 3
> einzeln aufgeführt.

---

## 0. Was dieses Dokument ist

Ein **konsolidierter, aber noch nicht verbindlicher** Plan, der die drei
Einzelpläne in ein gemeinsames Bild zusammenfasst. Nach Freigabe durch
den Nutzer wird daraus die Grundlage für `docs/AGENTS.md`,
`docs/ARCHITEKTUR.md` und das Slice-0-Plan-Artefakt.

**Es ist kein Implementierungsplan.** Code-Skeletons entstehen erst
nach Freigabe.

---

## 1. Harter Konsens (alle drei einig — nicht mehr verhandelt)

### 1.1 Domain
- **Geometrie:** Hexagonale Zellen. Eine Zelle belegt genau einen Hex.
- **Koordinaten:** Axial `(q, r)` ist die kanonische Sim-Wahrheit.
  Cube-Koordinaten werden für Distanz-/Rotationsmathe abgeleitet,
  nie zweite Wahrheit gespeichert.
- **Topologie:** Bakterium = zusammenhängender Verbund von Hex-Zellen
  über die sechs axialen Nachbarrichtungen. Lückenlose Adjazenz ist
  harte Invariante.
- **Boundary:** abgeleitet — eine Zelle ist Boundary, wenn mind. ein
  Nachbarplatz leer ist. Nicht persistiert.
- **Genom:** typisiertes Resource (kein Bitstring), beeinflusst
  Wachstumswahrscheinlichkeiten und -gewichtungen.

### 1.2 Architekturdoktrin
- **Daten und Simulationszustand sind Wahrheit.** View-, Tool-,
  Szenen-, UI- und Renderer-Code ist Projektion.
- **Schichten mit einseitigen Abhängigkeiten.** Genaue Schichtung
  siehe Sektion 5.
- **Keine Manager-Gottklasse.** Kleine Dateien mit klarer
  Verantwortung.
- **Keine Sim-Logik in `rendering/`, `ui/`, `debug/`, `scenes/`.**
- **Keine Nodes als Sim-Wahrheits-Container.** `Cell`, `Organism`
  sind RefCounted-Datenklassen.
- **Autoloads sind streng begrenzt.** Nur echte globale Wahrheit.
  Alle anderen Services werden in der Composition-Root-Szene
  verdrahtet.
- **Konfiguration über Resources** mit `@export` / `@export_range`
  für Inspector-Tweaking.

### 1.3 Workflow
- **Slice-Regel:** "So groß wie möglich, so klein wie nötig."
- **Startprotokoll vor jeder nicht-trivialen Änderung:**
  1. `git status --short --branch` prüfen.
  2. `AGENTS.md` und betroffene kanonische Doku lesen.
  3. Betroffene Schicht benennen.
  4. Ziel, Annahmen, Risiken, Validierungspfad nennen.
  5. Bei Architekturzweifeln zuerst `DECISIONS.md` oder
     Plan-Artefakt aktualisieren.
- **Abschlussprotokoll:** geänderte Dateien, betroffene Schichten,
  Tests/Validierung, Doku-Sync (oder Begründung), offene Risiken,
  **Commit-Vorschlag mit Titel und Body**.
- **Conventional Commits:** `feat`, `fix`, `perf`, `refactor`,
  `docs`, `test`, `chore`. Codex' zusätzlicher `arch`-Type wird
  *nicht* übernommen — Architekturänderungen sind je nach Wirkung
  `feat` oder `refactor`, der Body trägt die Architektur-Begründung.
- **Keine Auto-Commits, Auto-Pushes oder PRs ohne explizite
  Freigabe.**
- **Headless-Validierung ab Slice 0**, deterministische Seeds.

### 1.4 Performance-Disziplin
- Fixed-Step-Sim, Renderer entkoppelt.
- Keine Node-pro-Zelle als langfristiger Pfad.
- Zellzugriff über Dictionary keyed by axial coord.
- Topologie inkrementell/dirty pflegen.
- Snapshot-Layer für Renderer und Debug.
- PerfProbe ab Tag 1, aber außerhalb der Sim-Schicht.
- Performance-Gates **pro Slice vorab schriftlich festgelegt**
  (Claude's Vorschlag, von Codex/GPT nicht widersprochen).

### 1.5 Nicht-Ziele bis Slice 5
Bewegung, Sensoren/Augen, Mund/Verdauung, Dornen/Kampf, Schaden,
strukturelle Mutation, Crossover/Vererbung über Generationen,
mehrere Welt-Substrate, Tag/Nacht-Zyklus, Save/Load,
Multiplayer/Networking, Shader-/High-End-Grafik, prozedurale
Animationen, UI-Polish über das Lab hinaus.

---

## 2. Mehrheitsentscheidungen (2:1 — mit Begründung)

### 2.1 Hex-Orientierung: Sim agnostisch (Codex + GPT)

Claude wollte flat-top als Sim-Wahl festschreiben. Codex und GPT
argumentieren überzeugender: **Sim darf sich nicht auf
Pixelorientierung verlassen.** Die Orientierung ist eine
Projektionsfrage und gehört in `RenderConfig`.

**Konsens:** Sim-Code arbeitet mit axial `(q, r)` und kennt keine
Pixelrichtung. Default für Slice 1: **pointy-top** im Renderer
(GPT's Beispielformel), aber per `RenderConfig` umschaltbar.

### 2.2 Slice 3 ist Wachstum, nicht Tochterspawn (Codex + GPT)

Claude's Slice 3 enthielt sofort Tochter-Bakterien an freier Position
in der Welt. Codex und GPT verschieben das, weil:
- Spatial-Index für Spawn-Lookup ist eigene Komplexität.
- Wachstum am eigenen Körper ist die Vorstufe und liefert bereits
  emergente Form.
- Echte Reproduktion mit zwei separaten Organismen ist eigener
  Slice nach validiertem Wachstum.

**Konsens:** Slice 3 = Wachstum am bestehenden Körper. Echte
Reproduktion (Tochterorganismus) wird Slice 5+ und braucht
eigenes Plan-Artefakt.

### 2.3 Mutation kommt später (Codex + GPT)

Claude's Slice 4 enthielt Gauß-Mutation bei Teilung. Da es
noch keine echte Teilung in Slice 3 gibt (siehe 2.2), entfällt
auch die Mutation dort. Codex und GPT empfehlen Mutation als
eigenen Slice nach validiertem Wachstum + valider Reproduktion.

**Konsens:** Slice 4 = Genom-Einfluss auf Wachstum (Variation
über Seeds). Mutation ist Slice 6+.

### 2.4 Doku: ein konsolidiertes 8-Dateien-Set

Drei verschiedene Vorschläge:

| Datei | Claude | Codex | GPT | Konsens |
|-------|--------|-------|-----|---------|
| AGENTS.md | ja | ja | ja | **ja** |
| README.md | nein | ja | ja | **ja** (2:1) |
| ARCHITEKTUR.md | ja | ja | ja | **ja** |
| STATUS.md | ja | ja | ja | **ja** |
| NEXT_STEPS.md | ja | ja | ja | **ja** |
| DECISIONS.md | ja | ja | ja | **ja** |
| CLAUDE.md | ja | nein | nein | **nein** (1:2) — Reviewer-Spezifika in AGENTS.md |
| Sim-Regeln | (in DECISIONS) | SIM_RULES.md | CELL_SYSTEM.md | **`SIM_RULES.md`** (2:1, breiterer Scope als nur Cells) |
| Bugs/Findings | (in NEXT_STEPS) | FINDINGS.md | BUGS.md | **`FINDINGS.md`** (Codex' Begriff schließt Reviews ein, nicht nur Bugs) |
| Canvas | (Plan-Doku) | BACTORIUM_NEUSTART_CANVAS.md | (kein Eintrag) | **dieses Dokument bleibt als `BAKTORIUM_NEUSTART_KONSENS_v1.md`**, dann archivieren |

**Finales kanonisches Set (8 Dateien):**
- `AGENTS.md` — Arbeitsvertrag für alle Agenten (inkl. Review-Rolle)
- `README.md` — Kurzstart, wichtigste Befehle, Doku-Übersicht
- `docs/ARCHITEKTUR.md` — Schichten, Autoritäten, Verbote, Autoloads
- `docs/SIM_RULES.md` — Hex-Modell, Zellfunktionen, Energie, Wachstum, Genom, Tick-Reihenfolge, Nicht-Ziele
- `docs/STATUS.md` — was läuft, was validiert ist, was offen ist
- `docs/NEXT_STEPS.md` — exakt der nächste Arbeitsblock + Gate
- `docs/DECISIONS.md` — ADR-001..NNN
- `docs/FINDINGS.md` — offene Bugs, Review-Findings, Diagnose-Pfade

**Bewusst nicht:** HANDOFF.md, AI_KONTEXT.md, separate
PERFORMANCE.md/CLAUDE.md/BUGS.md, Probe-Archive.

### 2.5 Genom-Genvektor: Codex' Set + GPT's Wirkung-Tabelle (kompromiss)

Drei Vorschläge unterschiedlicher Granularität:
- Claude: 4 Felder (photo_efficiency, division_threshold, target_cell_count, wall_ratio)
- Codex: 11 Felder (sehr breit, inkl. branching, symmetry_bias, surface_preference, mutation_rate)
- GPT: 6 Felder (photosynthesis_bias, wall_bias, growth_spread, core_reserve, reproduction_bias, symmetry_bias)

Claude's Set ist zu klein (kein Wachstumsformungs-Hebel). Codex'
Set ist breit aber speist sich aus theoretischer Reichhaltigkeit.
GPT's Set trifft den Mittelweg.

**Konsens — v1-Genom (8 Felder):**

| Gen | Range | Wirkung |
|-----|-------|---------|
| `photosynthesis_bias` | 0..1 | Gewichtung neuer Photo-Zellen beim Wachstum |
| `wall_bias` | 0..1 | Tendenz zu mehr Wand-Zellen |
| `reproduction_bias` | 0..1 | wie früh Wachstum auslöst |
| `growth_spread` | 0..1 | kompakt vs. ausgreifend (= Codex' compactness/branching kombiniert) |
| `symmetry_bias` | 0..1 | geordnete vs. zufällige Wachstumsrichtung |
| `surface_preference` | 0..1 | Photo-Zellen bevorzugt an Boundary |
| `energy_efficiency` | 0..1 | reduziert Maintenance-Kosten |
| `mutation_rate` | 0..1 | ruhendes Feld, in v1 unbenutzt |

`mutation_rate` bleibt absichtlich im Schema, damit das
GenomeConfig-Resource bei Aktivierung in Slice 6+ keine
Schema-Änderung braucht.

### 2.6 Energie: global in v1 (alle drei einig, aber GPT's Begründung)

Konsens war einfach. Wichtig ist die explizite Begründung in
`SIM_RULES.md`: "Globalenergie ist grob, aber sie macht emergente
Wachstumstests überschaubar. Lokale Energieflüsse sind Slice 7+
mit eigenem Plan-Artefakt."

---

## 3. Übernahmen technisch überlegener Einzelvorschläge

### 3.1 GPT's atomare WorldGrid-Methode (Konfliktauflösung)

GPT als einziger sauber: `WorldGrid` (globale Occupancy) und
`OrganismState` (lokale Körperstruktur) können sich widersprechen,
wenn Zellplatzierung nicht atomar ist.

**Übernommen:** Jede Zellplatzierung läuft über eine Sim-Methode
(`SimulationService.place_cell(...)`), die **beide Strukturen
atomar aktualisiert und validiert**. Doppelbelegung ist
unmöglich, weil `WorldGrid.is_free(coord)` Vorbedingung ist.

### 3.2 GPT's Doku-Hierarchie bei Widersprüchen

Übernommen direkt nach `docs/AGENTS.md`:

1. `ARCHITEKTUR.md` gewinnt für Schichten/Autoritäten/Verbote.
2. `DECISIONS.md` gewinnt für Architekturentscheidungen.
3. `STATUS.md` gewinnt für aktuellen Stand.
4. `NEXT_STEPS.md` gewinnt für nächsten Arbeitsblock.
5. `SIM_RULES.md` gewinnt für Sim-Regeln.
6. `README.md` ist Orientierung, keine Detailautorität.
7. Ältere Notizen sind Hintergrund.

### 3.3 Codex' CellFunctionDef + CellFunctionCatalog

Codex hat als einziger den Resource-Schnitt für Zellfunktionen
sauber durchgedacht. Übernommen, weil das die Inspector-
Konfigurierbarkeit (Wunsch des Nutzers) am besten realisiert:

- `CellFunctionDef.tres` pro Funktion: function_id, label,
  base_color, energy_production, maintenance_cost, growth_cost,
  requires_surface, protection_value.
- `CellFunctionCatalog.tres`: Array aller erlaubten Funktionen,
  Pflichtfunktionen, v1/v2-Feature-Gates.

Damit kann der Nutzer im Inspector Zellfunktionen tweaken **und**
neue Funktionen ohne Code-Änderung als Resource ergänzen.

### 3.4 Claude's Performance-Gates pro Slice

Claude als einziger explizit: jeder Slice schreibt sein
Performance-Budget vorab fest, und Nicht-Erfüllung = Slice
abbrechen + ADR. Codex/GPT haben Performance erwähnt, aber nicht
als Gate. Übernommen.

### 3.5 Codex' eigener Test-Runner statt GUT

Codex' Argument: Graviton hat einen schlanken eigenen Runner sehr
erfolgreich genutzt. GUT ist sinnvoll, wenn Testkomfort wichtiger
wird, aber das ist erst spät. Übernommen.

`src/tests/test_runner.gd` mit `tests/<schicht>/`-Unterordnern.

### 3.6 Claude's Calibration-Orchestrator-Format (optional)

Claude hat den `<!-- ORCHESTRATOR_RESULT -->`-Block-Vorschlag.
**Bedingt übernommen:** wird *nur* aktiviert, wenn der Nutzer den
Orchestrator für Baktorium nutzt. In v1 nicht Pflicht. Eintrag
in `AGENTS.md` als optionaler Footer.

---

## 4. Domain-Modell (final, Konsens)

### 4.1 Atomare Einheiten

- **`HexCoord`** (`src/core/hex/`): immutable Wertobjekt, `(q, r)`,
  reine Funktionen für Nachbarn, Distanz, Ring.
- **`CellBlock`** (`src/body/`): Daten-Klasse, kein Node.
  - `coord: HexCoord` (lokal zum Organismus)
  - `function_id: StringName` — Tag-basiert, **keine
    Klassenhierarchie** (übernommen aus baktorios ADR-002)
  - `function_def: CellFunctionDef` — Lookup via Registry
  - `state_flags: int` — Bitfeld
- **`Organism`** (`src/body/`): Daten-Klasse.
  - `id: int` (StableId via `IdRegistry`)
  - `cells: Dictionary[HexCoord, CellBlock]`
  - `genome: Genome`
  - `world_origin: Vector2`
  - `state: OrganismState` — Energie, Alter, Wachstumsladung
- **`Genome`** (`src/genetics/`): Resource mit den 8 Genen aus 2.5.
- **`WorldGrid`** (`src/sim/`): globale Occupancy-Map
  `Dictionary[Vector2i, OrganismCellRef]`. Schreibrecht nur via
  `SimulationService.place_cell` / `remove_cell`.

### 4.2 Pflichtige Cell-Funktionen in Slice 1

In v1 vier Funktionen, nicht fünf:

| Tag | Rolle | v1-Verhalten |
|-----|-------|--------------|
| `energy_core` | Pflicht. Identitäts- und Energiezentrum. | speichert globale Organismus-Energie |
| `photosynthesis` | Energiequelle | erzeugt Energie/Tick, optional Surface-Bonus |
| `reproduction` | Wachstumsmotor | wandelt Energieüberschuss in `growth_charge` |
| `wall` | Strukturschutz | nur Topologie/Material, kein HP-System in v1 |

GPT's separate `CORE`-Zelle wurde nicht übernommen, weil
`energy_core` in v1 die Identitätsrolle mit übernimmt.
Wenn sich später zeigt, dass Identität und Energie getrennt
werden müssen, kommt das als ADR.

`cytoplasm` (Codex' offene Kandidatin) wird **nicht** in
Slice 1 eingeführt. Erst entscheiden, wenn Wachstum sonst
unnatürlich wird.

### 4.3 Welt

- Ein **globales `WorldGrid`** in axialer Hex-Belegung.
- Bakterien haben zusätzlich **lokale Hex-Koordinaten** relativ
  zu ihrem `world_origin`.
- Bei Platzierung übersetzt `SimulationService` lokal → global
  und prüft `WorldGrid.is_free(global_coord)`.
- Sonne in v1 = globaler Skalar `sun_intensity`. Lichtquellen mit
  Falloff sind Slice 7+.

---

## 5. Architektur (final, Konsens)

### 5.1 Schichtung

```
ui / debug / scenes  ← Composition Root, reine Projektion
       ▲
   rendering          ← liest Snapshots, zeichnet Hex-Polygone
       ▲
    runtime           ← derived state, Snapshots, Caches
       ▲
      sim             ← autoritative Logik, Services, Tick-Orchestrierung
       ▲
   body / genetics    ← Daten-Klassen Organism, CellBlock, Genome
       ▲
   config / core      ← Hex-Math, RNG, IDs, Resources
```

**Dependency-Richtung:** strikt einseitig nach unten. Keine
Rückabhängigkeiten.

`config/` und `core/` werden von mehreren Schichten gelesen,
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
  BAKTORIUM_NEUSTART_KONSENS_v1.md   (dieses Dokument; nach Slice 0 archivieren)

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
    world_grid.gd
    organism_state.gd
    simulation_service.gd
    energy_system.gd
    growth_system.gd
  runtime/
    derived_organism_snapshot.gd
    simulation_snapshot_cache.gd
  rendering/
    hex_organism_renderer.gd
    hex_debug_overlay.gd
  ui/
    lab/
      simulation_lab_panel.gd
      organism_inspector.gd
  debug/
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
    energy_core.tres
    photosynthesis.tres
    reproduction.tres
    wall.tres
  cell_function_catalog.tres

tools/
  validate_hex_foundation.gd
```

(Übernommen aus Codex, ergänzt um GPT's `cell_functions/`-Resource-
Verzeichnis.)

### 5.3 Autoloads — exakt zwei (Claude/Graviton)

- `TimeService` — emittiert `sim_tick(delta_seconds)`, einziger
  Tick-Treiber.
- `SimRegistry` — hält Welt-Referenz, `IdRegistry`,
  `CellFunctionCatalog`-Lookup.

Alle anderen Services (`EnergySystem`, `GrowthSystem`,
`SimulationService`) werden in `simulation_lab.tscn` als
Kind-Nodes verdrahtet.

### 5.4 Autoritätstabelle

(Mergt Codex' und GPT's Tabellen. Codex hatte 10 Zeilen, GPT 8;
zusammen klar.)

| Thema | Autoritative Quelle | Schreibrecht |
|-------|---------------------|--------------|
| Sim-Zeit | `TimeService` | nur TimeService |
| Hex-Geometrie | `core/hex/*` | reine Funktionen |
| Globale Hex-Belegung | `sim/world_grid.gd` | `SimulationService` |
| Zellkörper (lokal) | `body/organism_body.gd` | `GrowthSystem` (später Damage/Reproduction) |
| Zellen | `CellBlock` Daten | autorisierte Sim-Systeme |
| Genom | `genetics/genome.gd` | `GenomeFactory` (später `MutationSystem`) |
| Energie | `OrganismState.energy` | `EnergySystem` |
| Wachstumsladung | `OrganismState.growth_charge` | `GrowthSystem` |
| Renderdaten | `DerivedOrganismSnapshot` | read-only abgeleitet |
| Tuningwerte | `config/*.tres` | nur Editor; UI darf Kopien tweaken |
| UI-Eingaben | `LabConfig` Runtime-Kopie | nur UI-Controls |

**Niemals autoritativ:** `Node2D.position`, `Polygon2D`-Vertices,
Debug-Overlay, UI-Labels, Editor-Szenenwerte (außer Composition),
Screenshots.

### 5.5 Tick-Reihenfolge v1 (übernommen aus Codex)

1. **Topologie** aus Zellkarte ableiten (Boundary, Frontier-Hexe).
2. **Energie produzieren** (Photo, ggf. Surface-Bonus).
3. **Energieverbrauch** (Maintenance pro Zelle).
4. **Wachstumsladung aktualisieren** (Reproduction wandelt
   Energieüberschuss in `growth_charge`).
5. **Wachstum ausführen** (max. N neue Zellen pro Tick an freien
   Frontier-Hexen, Scoring per Genom + Topologie).
6. **Invarianten prüfen** (connected, keine Doppelbelegung,
   Pflichtzellen vorhanden, Werte endlich).

---

## 6. Slice-Roadmap (final, Konsens)

### Slice 0 — Repo- und Doku-Fundament
**Ziel:** Verzeichnisstruktur + Doku + Test-Runner-Skelett +
leere Config-Resources.
**Acceptance:**
- `AGENTS.md`, alle 8 kanonischen Docs existieren mit Stub.
- Test-Runner läuft headless (auch mit 0 Tests).
- Projekt öffnet in Godot ohne Fehler.
- ADRs: ADR-001 (Hex-Modell), ADR-002 (Daten vs. Nodes),
  ADR-003 (Cell-Funktionen als Tags), ADR-004 (Doku-Set 8 Dateien).
**Performance-Gate:** entfällt (kein Sim-Code).
**Nicht anfangen:** Wachstum, Rendering, Population.

### Slice 1 — Hex-Kern und Topologie
**Ziel:** `HexCoord`, Nachbarn, Distanz, Connectedness-Check,
Boundary-Erkennung. Kein Renderer, kein Organismus.
**Acceptance:**
- Tests: 6 Nachbarn pro Coord, axiale Distanz, bekannte Formen
  (Linie, Ring, Cluster), connectedness, Boundary für Testformen.
- `core/hex/` hat keine Godot-Node-Abhängigkeit.
**Performance-Gate:** Connectedness-Check für 1000-Zell-Cluster
unter 5 ms.

### Slice 2 — Genom + Startkörper + statisches Rendering
**Ziel:** `GenomeFactory` (deterministisch aus Seed),
`BodyFactory` baut Pflichtzellen-Körper, einfacher
`HexOrganismRenderer` zeichnet ihn farbig im Lab.
Konsolidiert GPT's Slice 1 + Codex' Slices 2+3.
**Acceptance:**
- gleicher Seed → gleicher Körper.
- 20 Seeds → unterscheidbare aber valide Körper.
- alle Pflichtzellen vorhanden, Körper connected,
  keine Doppelbelegung in `WorldGrid`.
- Renderer liest nur Snapshot, kein Genom direkt.
- Inspector zeigt `SimulationConfig`, `GenomeConfig`,
  `RenderConfig`.
**Performance-Gate:** 1 Organismus mit 50 Zellen flüssig
(60 FPS).

### Slice 3 — Energie v1
**Ziel:** Photo erzeugt Energie, Maintenance verbraucht,
`OrganismState.energy` läuft deterministisch.
**Acceptance:**
- keine negativen/NaN-Werte.
- Headless-Test: bekannter Körper, bekannte Bilanz.
- Inspector ändert `sun_intensity` → sichtbarer Effekt < 1 s.
**Performance-Gate:** 1 Organismus mit 100 Zellen flüssig.

### Slice 4 — Wachstum v1
**Ziel:** `Reproduction`-Zellen sammeln Wachstumsladung, neue
Zellen entstehen an Frontier-Hexen, Genom beeinflusst
Zelltyp-Auswahl und Wachstumsrichtung.
**Acceptance:**
- Wachstum bleibt connected.
- Wachstum pro Tick begrenzt (`GrowthConfig.max_growth_per_tick`).
- `WorldGrid` verhindert Doppelbelegung.
- gleiches Seed → gleiches Wachstum.
- Debug-Overlay zeigt Wachstumsentscheidungs-Score.
**Performance-Gate:** 1 Organismus auf 250 Zellen wachsen lassen,
flüssig.

### Slice 5+ — Erst nach Slice 4 entscheiden
- mehrere Organismen (echtes `WorldState` mit N Organismen)
- echte Reproduktion in Tochterorganismus
- Mutation
- danach Bewegung / Sensorik / Verdauung / Kampf / Lichtkarte

Diese Slices kriegen jeweils eigenes Plan-Artefakt. ADR-005 hält
fest, dass sie aktive Future-Scope sind, aber kein Code dafür
entsteht.

---

## 7. Performance-Strategie

- **Fixed-Step-Sim:** `TimeService` mit konfigurierbarer Rate
  (default 30 Hz).
- **Renderer:** v1 = ein `Node2D` zeichnet Hex-Polygone in
  `_draw()` aus Snapshot. Bei Skalierung Phasen:
  v2 = chunked draw. v3 = `MultiMeshInstance2D`.
- **Object Pooling:** ab Slice 4, wenn Wachstum messbar
  allokiert.
- **PerfProbe:** Tick-Dauer, Cell-Count, Organism-Count,
  Energy-Throughput in CSV/JSON dumpbar.
- **Performance-Budget pro Slice festschreiben** (siehe
  Acceptance-Gates oben). Nicht-Erfüllung = ADR + Slice
  nachbessern, nicht weitermachen.

---

## 8. Validierungsstrategie

Headless-Validator `tools/validate_hex_foundation.gd` prüft pro
Slice mindestens:

- (Slice 1) axial neighbor count = 6, Distanz korrekt
- (Slice 2) gleicher Seed → gleicher Körper, contiguous, alle
  Pflichtzellen vorhanden, keine Doppelbelegung, Renderer liest
  nicht Genome direkt, Config-Resources nicht zur Laufzeit
  mutiert
- (Slice 3) Energie-Tick deterministisch, keine negativen/NaN
- (Slice 4) Wachstum bleibt contiguous, Wachstumskosten
  abgezogen, `WorldGrid` verhindert Doppelbelegung,
  Debug-Overlay verändert keinen Sim-State

Manueller Lab-Check pro Slice:
- Seed-Reihe durchklicken.
- Debug-Overlay an/aus.
- Tick/Pause/Reset testen.
- Inspector-Slider bewegen, sichtbarer Effekt < 1 s.

---

## 9. Risiken und Gegenmaßnahmen

(Mergt Claude's P0/P1-Liste mit GPT's Tabellenformat.)

| Risiko | Priorität | Gegenmaßnahme |
|--------|-----------|---------------|
| Hex-Math-Fehler (off-by-one in Adjazenz) | P0 | Unit-Tests für `core/hex/` ab Slice 1 |
| `WorldGrid` und `OrganismState` widersprechen sich | P0 | atomare `SimulationService.place_cell()` |
| Renderer-Wahl skaliert nicht | P0 | Performance-Gates + 3-Phasen-Plan (siehe 7) |
| Grafik wird wieder zu früh Hauptthema | P0 | harte Render-Slice-Reihenfolge nach Sim |
| Doku wächst wie Graviton/Orchestrator | P1 | nur 8 kanonische Docs; alte Notizen archivieren |
| Genom-Resource erschwert späteren Crossover | P1 | ADR über Erweiterungspfad in Slice 6 |
| Globale Energie zu eng für Slice 5+ | P1 | `WorldService` kapselt jetzt schon `get_light_at(pos)` |
| Doku-Drift nach mehreren Slices | P1 | Pflicht-Update von STATUS+NEXT_STEPS pro Slice-Commit |
| Zu viele Mikro-Slices | P2 | Slice-Regel in AGENTS.md fest |
| Agenten erweitern Scope | P2 | Startprotokoll + Review-Handover + Doku-Sync |

---

## 10. Offene Fragen für die finale Triade

Diese Punkte sind aus den Einzelplänen *nicht* sauber lösbar
und brauchen entweder Nutzer-Entscheidung oder eine zweite
Codex-Runde:

1. **Test-Runner-Konkretisierung:** Eigener Runner wie Graviton
   ist Konsens — aber soll er `assert_equal`-Style oder
   Hamcrest-Style API haben? *Vorschlag: minimaler
   `assert_equal/assert_true`-Style, GUT-Migration optional.*

2. **CellFunctionDef-Felder finalisieren:** Codex' 8 Felder
   sind ein guter Start. Soll `growth_cost` schon in v1 oder
   erst Slice 4 dabei sein? *Vorschlag: ab v1 im Schema, in
   Slice 1–2 unbenutzt.*

3. **`cytoplasm`-Zelle:** Codex hält die offen. Bauen wir
   Slice 2's Startkörper aus den 4 Pflichtfunktionen, oder
   führen wir `cytoplasm` mit ein? *Vorschlag: ohne
   `cytoplasm` starten. Wenn Slice 2's Körper unnatürlich
   aussieht (z.B. zu viele Photo-Zellen erzwingen), als
   ADR-006 nachträglich.*

4. **Calibration-Orchestrator-Format:** Sollen Agent-Antworten
   den `<!-- ORCHESTRATOR_RESULT -->`-Block setzen? *Vorschlag:
   Nur wenn der Nutzer den Orchestrator nutzt. Default: nein.*

5. **Init-Genome:** `GenomeFactory` baut aus Seed. Soll der
   Seed pro Organismus oder pro Welt sein? *Vorschlag: pro
   Organismus (für Lab-Reproduzierbarkeit), Welt-Seed in
   Slice 5 wenn mehrere Organismen.*

6. **DebugMenu-Addon:** Codex und GPT erwähnen es. Aufnehmen
   in Slice 0 oder erst wenn FPS/Memory wirklich im Auge
   behalten werden müssen? *Vorschlag: erst bei Slice 3
   (erste echte Sim-Last).*

---

## 11. Was *nicht* in diesen Plan gehört

- Konkrete Klassennamen jenseits dessen, was in der
  Verzeichnisstruktur (5.2) steht.
- Methoden-Signaturen.
- Code-Skeletons.
- Render-Shader-Details.
- Save/Load-Format.

Das ist Codex' Job nach Freigabe dieses Plans.

---

## 12. Plan-Artefakt-Block (Calibration-Orchestrator-Format)

```markdown
### Plan-Artefakt: Baktorium-Foundation (Konsens v1)

**Ziel:** Baktorium als hexagonale, deterministische Zell-Sim
aufbauen — beginnend mit einem statischen Pflichtzellen-Körper,
dann Energie, dann Wachstum. Architektur und Doku aus Graviton,
Scope-Disziplin aus baktorios Lehren, Workflow aus
Calibration_Orchestrator.

**Approach:** Drei-Stimmen-Konsens (Claude / Codex / GPT) als
Eingabe; harter Konsens + 2:1-Mehrheiten + technisch überlegene
Einzelvorschläge synthetisiert.

**Schritte:**
1. Nutzer + Codex lesen diesen Plan; Findings in `FINDINGS.md`.
2. Slice 0 implementieren (Repo, Doku, Test-Runner, leere
   Configs, ADR-001..004).
3. Slice 1 (Hex-Kern + Topologie-Tests).
4. Slice 2 (Genom + Startkörper + Renderer).
5. Slice 3 (Energie v1).
6. Slice 4 (Wachstum v1).

**Abhängigkeiten:** Slice N+1 startet erst nach validiertem
Performance-Gate von Slice N und Doku-Update.

**Nicht-Ziele:** Sektion 1.5. Bindend für Slice 0–4.

**Risiken:** Sektion 9 (P0: 4, P1: 4, P2: 2).

**Validierung:** Sektion 8 (headless + manueller Lab-Check pro
Slice).

**Evidenz:**
- Drei vollständige Einzelpläne in `docs/`.
- Quell-Repos analysiert: `Graviton`, `baktorio`,
  `Calibration_Orchestrator`.
- Übernommene Patterns: Graviton's Schichten + Autoloads,
  baktorios "Module-als-Tags" + atomare Zellplatzierung-Idee
  (ergänzt durch GPT), Orchestrator's Slice-Disziplin und
  Plan-Artefakt-Format.
```

---

*Ende Konsens v1. Bitte gegenprüfen lassen, dann Slice-0-Plan-
Artefakt schreiben und implementieren.*
