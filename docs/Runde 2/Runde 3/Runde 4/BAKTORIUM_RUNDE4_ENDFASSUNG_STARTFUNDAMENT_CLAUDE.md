# Baktorium — Fundament v2 (Pivot-Endfassung)

> **Status:** Endfassung Runde 4. Synthese der drei Runde-3-Endfassungen
> *plus* Anpassung an den expliziten Nutzer-Pivot vom 2026-05-02:
> *"am Anfang geht es schlichtweg erst mal um das Visuelle und das
> grundlegende Starter-Bakterium und die Weise, wie wir
> zusammenarbeiten."*
>
> Ab Freigabe ist dieses Dokument der **verbindliche Planungsanker**
> für Slice 0 und Slice 1.
>
> **Autor der Endfassung:** Claude (Opus 4.7, 1M-Kontext)
> **Datum:** 2026-05-02
> **Quellen (Runde 3):**
> - `docs/Runde 2/Runde 3/BAKTORIUM_ENDFASSUNG_FUNDAMENT_CODEX.md`
> - `docs/Runde 2/Runde 3/BAKTORIUM_ENDFASSUNG_FUNDAMENT_GPT.md`
> - `docs/Runde 2/Runde 3/BAKTORIUM_ENDFASSUNG_FUNDAMENT_CLAUDE.md`
>
> **Was neu ist gegenüber v1:**
> - **Pivot zu "First Visible Bacterium"** in Slice 1 (Sektion 7.1) —
>   GPT's gebündelter Slice 1 schlägt Codex/Claude's "Hex-Math allein"
>   weil der Nutzer früh ein sichtbares Bakterium sehen will
> - **Asset-Entscheidungen vorgezogen** (Sektion 8): zwei Assets werden
>   *jetzt* in Slice 1 verbindlich, statt sie auf Slice 4+ zu verschieben
> - **Architektur-Vorausschau-Liste** (Sektion 4) — was jetzt entschieden
>   wird, damit später kein Umbau nötig ist
> - Konkreter Codex-Auftrag für Slice 0 *und* skizzierter Auftrag für
>   Slice 1 (Sektion 11)

---

## 0. Was sich gegenüber v1 ändert (Kurz)

| Punkt | v1 (Runde 2 → Runde 3 Claude) | v2 (Pivot) | Grund |
|---|---|---|---|
| Slice-1-Scope | nur Hex-Math headless | **Hex + Body + Lab + Renderer als ein Slice mit Subphasen 1A–1D** | Nutzer will früh ein sichtbares Starter-Bakterium |
| Antialiased-Polygon-Asset | ab Slice 3 | **ab Slice 1** | Nutzer-Wunsch "fließende Zellwände" — visuelle Politur ist Slice-1-Acceptance, nicht später |
| DebugMenu-Asset | ab Slice 3 | **ab Slice 1** | kostenlos einzubauen, kein Architektur-Risiko, hilft Sim-Last-Diagnose |
| Renderer-Architektur | Snapshot-basiert ab Slice 3 | **Snapshot-basiert ab Slice 1** (gleicher Code-Pfad) | spart spätere MultiMesh-Migration |
| `core/sim/place_cell()`-Schnittstelle | erst ab Slice 5 | **bereits in Slice 1 als API definiert**, intern in Slice 1 trivial implementiert | spart spätere Refactors, wenn `WorldGrid` dazukommt |
| Tag-Naming Pflichtzelle | offen (`core` vs. `energy_core`) | **`energy_core`** (2:1 Codex+Claude); visuell als "Zellkern + Energiezentrum" gerendert | Naming sagt aus, was die Zelle technisch tut |

Alles andere bleibt wie in v1. Wer v1 schon verstanden hat: lies
Sektion 7 (neue Slice-1-Definition) und Sektion 8 (Assets jetzt
entscheiden) und überflieg den Rest.

---

## 1. Leitsatz und Reihenfolge

**Leitsatz (vom Nutzer):**
> Erst ein sichtbares Starter-Bakterium und eine geübte Zusammenarbeit.
> Dann tiefere Sim-Mechanik. Was später Umbauten sparen würde, wird
> jetzt entschieden — auch wenn der erste Slice dadurch größer wird.

**Reihenfolge:**
```text
Slice 0  → Workflow, Doku, Repo (= "wie wir zusammenarbeiten")
Slice 1  → First Visible Bacterium (Hex + Body + Lab + Renderer)
Slice 2  → Energie v0 (globaler Pool)
Slice 3  → Wachstum v0 (Frontier-Anbau am eigenen Körper)
Slice 4  → Genom-Expression v0 (sichtbare Variation über Seeds)
Slice 5+ → Mehrere Organismen / Reproduktion / Mutation / Bewegung / …
           jeweils mit eigenem Plan-Artefakt
```

---

## 2. Harter Konsens (alle drei Runde-3-Pläne einig)

### 2.1 Doktrin
- **Daten und Sim-Zustand sind Wahrheit.** Renderer/UI/Debug/Scenes
  sind Projektion.
- Eine Zelle ist ein Hex. Ein Bakterium ist ein direkt zusammen­
  hängender Verbund von Hex-Zellen.
- Kanonische Sim-Koordinaten: axial `(q, r)`. Cube nur abgeleitet.
  Boundary nur abgeleitet.
- Genom: typisiertes Resource, kein Bitstring, keine Mutation in v0.
- Energie v0: globaler Organismuspool, keine lokale Diffusion.
- `reproduction` = Wachstum am bestehenden Körper. Tochterorganismen
  sind späterer Slice.
- Renderer v0 = `Node2D._draw()`. Keine Node-pro-Zelle. Keine
  MultiMesh-/TileMapLayer-Pflicht.
- Keine Manager-Gottklasse. Kleine Dateien.
- Keine Sim-Logik in `rendering/`, `ui/`, `debug/`, `scenes/`.
- Konfiguration über `Resource` + `@export` / `@export_range`.

### 2.2 Workflow
- Slice-Regel: "so groß wie möglich, so klein wie nötig".
- Startprotokoll vor jeder nicht-trivialen Änderung:
  1. `git status --short --branch`
  2. `AGENTS.md` und kanonische Doku lesen
  3. Schicht benennen
  4. Ziel, Annahmen, Risiken, Validierungspfad nennen
  5. Bei Architekturzweifel zuerst `DECISIONS.md`/Plan-Artefakt
     aktualisieren
- Abschlussprotokoll: Ziel, Dateien, Schichten, Tests, Doku-Sync,
  Risiken, Review-Fokus, Commit-Vorschlag.
- Conventional Commits: `feat`, `fix`, `perf`, `refactor`, `docs`,
  `test`, `chore`.
- Keine Auto-Commits, keine Auto-Pushes, keine PRs ohne Freigabe.

### 2.3 Doku-Set (8 Dateien)
- `AGENTS.md`, `README.md`
- `docs/ARCHITEKTUR.md`, `docs/SIM_RULES.md`, `docs/DECISIONS.md`,
  `docs/STATUS.md`, `docs/NEXT_STEPS.md`, `docs/FINDINGS.md`

Bewusst nicht: separate `CLAUDE.md`, `BUGS.md`, `HANDOFF.md`,
`AI_KONTEXT.md`, `PERFORMANCE.md`. Claude-Review-Fokus lebt in
`AGENTS.md`.

### 2.4 Autoloads
- **Slice 0 hat keine projekt-eigenen Autoloads.** Lab-Szene ist
  Composition Root.
- `TimeService` kann ab Slice 2 (Energie-Tick) per ADR eingeführt
  werden.
- Kein globaler `SimRegistry` ohne konkreten Bedarf + ADR.

### 2.5 Nicht-Ziele bis einschließlich Slice 4
- Bewegung, Sensoren, Mund/Verdauung, Dornen/Kampf, Schaden
- echte Tochterorganismen, Mutation, Vererbung,
  Populationsevolution
- mehrere Welt-Substrate, Tag/Nacht, Save/Load
- Multiplayer/Networking
- Shader, Fluid/Softbody, organische Verformung
- prozedurale Animationen, UI-Polish über Lab hinaus
- MultiMesh / TileMapLayer als Pflicht

---

## 3. Auflösung der Runde-3-Konflikte

### 3.1 Tag-Naming Pflichtzelle: `energy_core` (2:1)

| Plan | Stimme |
|---|---|
| Codex | `energy_core` |
| GPT | `core` |
| Claude (v1) | `energy_core` |

**Endentscheidung:** `energy_core`. Naming sagt, was die Zelle
technisch tut. Die "Identitäts-/Zellkern-Rolle", die GPT mit
`core` betont, wird durch *Position* (zentral platziert) und
*Rendering* (eigene Farbe, leichtes Glow-Outline) sichtbar
gemacht — nicht durch den Tag-Namen.

**Visuelle Konsequenz für Slice 1:** Die `energy_core`-Zelle wird
visuell als "Zellkern + Energiezentrum" dargestellt:
- zentral im Bakterium platziert
- eigene Farbe (z.B. warmes Goldgelb)
- leichter Outline-Glow (`AntialiasedRegularPolygon2D` mit zweitem,
  größerem Outline-Polygon dahinter)

### 3.2 Slice-1-Scope: gebündelt mit Subphasen (Pivot-Entscheidung)

| Plan | Slice 1 |
|---|---|
| Codex | nur Hex-Math headless |
| GPT | Hex + Body + Lab gebündelt mit Subphasen 1A–1C |
| Claude (v1) | nur Hex-Math headless, Body+Renderer in Slice 2 |

**Endentscheidung:** **GPT's Ansatz mit erweitertem 1D**.

Begründung: Der Nutzer-Pivot fordert ein **sichtbares Starter-
Bakterium als ersten Sim-Inhalt**. Codex'/Claude's "nur Hex-Math"
würde bedeuten, dass das erste sichtbare Bild erst nach Slice 3
kommt. Das widerspricht dem Nutzer-Wunsch.

GPT's gebündelter Slice 1 ist trotzdem architektur-sauber, weil
die Subphasen 1A–1D *intern* die strikte Schichten-Reihenfolge
einhalten und jede Subphase einzeln getestet wird:

- **1A:** `core/hex/` — HexCoord, Math, headless Tests
- **1B:** `body/`, `genetics/` — Genome, OrganismBody, BodyFactory,
  headless Tests
- **1C:** `rendering/`, `scenes/lab/` — `_draw()` Renderer mit
  einfachen Hex-Polygonen, Lab-Composition-Root
- **1D:** **Visuelle Politur** — Antialiased-Polygons für
  fließende Zellwände, Farben pro Zellfunktion, Debug-Overlay,
  DebugMenu-Asset

1D ist neu gegenüber GPT. Begründung: der Nutzer hat *explizit*
"fließende Zellwände" und das visuelle Erleben angesprochen. Wenn
Slice 1 nur scharfkantige Hex-Polygone zeigt, fragt der Nutzer
"warum sieht das hässlich aus" und wir machen das Asset-Setup
sowieso danach. Lieber direkt mit hineinpacken.

**Acceptance Slice 1:** Der Nutzer kann das Lab öffnen, durch
20 Seeds klicken, und in jedem Seed ein Bakterium aus 4 Pflicht-
zellen mit angenehmen Outlines sehen. Kein Energie-Tick, kein
Wachstum.

### 3.3 Andere Punkte ohne Konflikt

Doku-Set, Autoloads, Hex-Orientierung (Sim agnostisch, Render-
Default pointy-top), `wall` ist Funktion nicht jede Boundary,
`reproduction` heißt Wachstum am Körper, eigener Test-Runner
(GUT später) — alle drei Runde-3-Pläne stimmen überein.
Übernommen.

---

## 4. Was JETZT entschieden wird (= Architektur-Vorausschau)

Diese Punkte werden **in Slice 0 / Slice 1 fixiert**, weil ein
späteres Umstellen Refactors über mehrere Schichten erzwingen
würde:

### 4.1 Sim/Renderer-Trennung über Snapshots ab Slice 1

Der Renderer liest ab dem allerersten Tag **nur** aus
`runtime/derived_organism_snapshot.gd`. Auch wenn der "Snapshot"
in Slice 1 trivial ist (nur eine Liste `(coord, function_id, color)`),
der Renderer fragt nie direkt `OrganismBody` oder `CellBlock` an.

**Warum jetzt:** Wenn wir später für Performance auf
`MultiMeshInstance2D` migrieren oder einen Chunk-Renderer einziehen,
ändert sich nur `rendering/`. Sim und Body bleiben unberührt. Wenn
wir das *später* einziehen, müssen wir den Renderer komplett
umschreiben.

### 4.2 `SimulationService.place_cell(...)` als einzige Zellplatzierungs-API

Auch in Slice 1, wo es nur einen Organismus und keinen `WorldGrid`
gibt, läuft jede Zellplatzierung über
`SimulationService.place_cell(organism_id, coord, function_id)`.
Intern aktualisiert die Methode nur `OrganismBody.cells` und
prüft "keine Doppelbelegung im selben Body".

**Warum jetzt:** In Slice 5 erweitern wir die Methode um
`WorldGrid.is_free(global_coord)` und atomares Update beider
Strukturen. Wenn die Methode schon existiert, muss kein einziger
Aufrufer geändert werden. Wenn sie *nicht* existiert, müssten wir
in Slice 5 alle direkten `body.cells[coord] = ...`-Stellen suchen
und ersetzen.

### 4.3 `CellFunctionDef` als Resource ab Slice 1

Die vier Pflichtfunktionen werden ab Slice 1 als
`resources/cell_functions/*.tres` ausgeliefert, mit dem vollen
Schema (`function_id`, `label`, `base_color`, `energy_production`,
`maintenance_cost`, `growth_cost`, `requires_surface`,
`protection_value`). Felder, die in Slice 1 unbenutzt sind
(`energy_production`, `growth_cost`, ...), bleiben im Schema.

**Warum jetzt:** Schema-Stabilität bedeutet, dass Slice 2
(Energie) nur Werte ausfüllt, statt das Schema zu erweitern.
Inspector-Editierbarkeit ist ab Tag 1 möglich.

### 4.4 `Genome` als Resource mit allen 8 Genen ab Slice 1

Das `Genome`-Resource trägt ab Slice 1 die 8 Felder aus
Sektion 5.5. Genome beeinflussen in Slice 1 *nur* den
Startkörper (welche Zellen wo). In Slice 4 werden weitere Felder
aktiv, ohne Schema-Änderung.

**Warum jetzt:** Vermeidet späteres Resource-Migrations-Theater
und gibt dem Inspector früh ein vollständiges Bild.

### 4.5 Test-Runner-Skelett ab Slice 0

`src/tests/test_runner.gd` wird in Slice 0 angelegt (selbst wenn
0 Tests). In Slice 1 hat jede Subphase 1A–1B headless Tests
(1C–1D sind manuell + Visual-Smoke-Test).

**Warum jetzt:** Keine "wir-fügen-Tests-später-hinzu"-Falle.

### 4.6 Asset-Adapter-Schicht für externe Plugins

DebugMenu und AntialiasedLine2D werden in Slice 1 verbindlich
(siehe Sektion 8). Sie werden über eigene Adapter-Skripte
angebunden (z.B. `debug/perf_probe.gd` ruft DebugMenu-API; der
Renderer nutzt eine eigene `hex_outline_drawer.gd`-Schicht, die
intern AntialiasedRegularPolygon2D verwendet).

**Warum jetzt:** Wenn ein Asset später bricht oder ersetzt wird,
ändern wir nur den Adapter, nicht alle Aufrufer.

---

## 5. Domain-Modell

### 5.1 Atomare Einheiten

- **`HexCoord`** (`src/core/hex/`): Wertobjekt `(q, r)`, immutable,
  reine Funktionen `neighbors()`, `distance()`, `ring()`.
- **`CellBlock`** (`src/body/`): Daten-Klasse, kein Node.
  - `cell_id: int`
  - `coord: Vector2i` (axial key, lokal)
  - `function_id: StringName` — Tag-basiert
- **`OrganismBody`** (`src/body/`): Dictionary[Vector2i, CellBlock]
  + `BodyTopology` (Boundary/Frontier dirty-getrieben).
- **`OrganismState`** (`src/sim/`): `id`, `energy`, `growth_charge`,
  `age_ticks`, `alive`, Refs auf Body und Genome.
- **`WorldState`** (`src/sim/`): `seed`, `tick`,
  `organisms: Array` (in v0–v1 Länge 1).
- **`Genome`** (`src/genetics/`): Resource mit den 8 Genen aus 5.5.

### 5.2 Pflicht-Zellfunktionen v0

| Tag | Rolle | v0-Verhalten | v1-Visuelle Darstellung |
|---|---|---|---|
| `energy_core` | Pflicht. Zellkern + Energieanker. | Speicher des globalen `OrganismState.energy` | zentral platziert, warmes Goldgelb, leichtes Outline-Glow |
| `photosynthesis` | Energiequelle | erzeugt Energie/Tick (ab Slice 2) | sattes Grün, optional dezentes Innenmuster |
| `reproduction` | Wachstumsmotor | wandelt Energie in `growth_charge` (ab Slice 3) | sanftes Lila/Magenta |
| `wall` | Strukturschutz | Topologie/Material, kein HP in v0 | mittleres Grau-Blau, dickerer Outline |

Visuelle Werte sind *Defaults* in den `.tres`-Resources. Der
Nutzer kann sie im Inspector ändern.

### 5.3 `CellFunctionDef` Resource-Schema

```
function_id: StringName
label: String
base_color: Color
energy_production: float       # /Tick (Slice 2)
maintenance_cost: float        # /Tick (Slice 2)
growth_cost: float             # einmalig bei Anbau (Slice 3)
requires_surface: bool         # Photo-Bonus an Boundary
protection_value: float        # für späteren Damage-Slice
```

`CellFunctionCatalog`: Array aller Funktionen, Pflichtfunktionen-
Liste, v1/v2-Feature-Gates.

### 5.4 Welt v0/v1

- **Slice 1:** ein Bakterium pro Lab-Run, Welt = Lab-Hintergrund.
- Sonne in Slice 2 = globaler Skalar `sun_intensity`.
- Lichtkarte/Substrat/mehrere Organismen → Slice 5+.

### 5.5 Genom v0 (8 Felder)

| Gen | Range | Wirkung in v0 (Slice 1) | Wirkung in v1 (Slice 4) |
|---|---|---|---|
| `photosynthesis_bias` | 0..1 | Anteil Photo-Zellen im Startkörper | + Wachstums-Score |
| `wall_bias` | 0..1 | Anteil Wand-Zellen im Startkörper | + Wachstums-Score |
| `reproduction_bias` | 0..1 | Anzahl `reproduction` (mind. 1) | Wachstums-Auslöseschwelle |
| `growth_spread` | 0..1 | kompakt vs. ausgreifend | Wachstumsrichtung |
| `symmetry_bias` | 0..1 | geordnet vs. zufällig | Wachstumsmuster |
| `surface_preference` | 0..1 | Photo-Zellen am Rand | Photo-Spawning an Boundary |
| `energy_efficiency` | 0..1 | (unbenutzt v0) | reduziert Maintenance |
| `mutation_rate` | 0..1 | (unbenutzt v0) | aktiv ab Slice 6 |

---

## 6. Architektur

### 6.1 Schichten

```
ui / debug / scenes  ← Composition Root, Projektion
       ▲
   rendering          ← liest Snapshots, zeichnet
       ▲
    runtime           ← Snapshots, abgeleitete Lesemodelle
       ▲
      sim             ← autoritative Logik, Tick, place_cell()
       ▲
   body / genetics    ← OrganismBody, CellBlock, Genome
       ▲
   config / core      ← Hex-Math, RNG, IDs, Resource-Schemas
```

Strikt einseitig nach unten. Keine Rückabhängigkeiten.

### 6.2 Verzeichnisstruktur

```
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
  BAKTORIUM_FUNDAMENT_v2.md   ← dieses Dokument

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
    simulation_service.gd     # Slice 1: place_cell() (intern trivial)
    # energy_system.gd        ← Slice 2
    # growth_system.gd        ← Slice 3
    # world_grid.gd           ← Slice 5
  runtime/
    derived_organism_snapshot.gd
    simulation_snapshot_cache.gd
  rendering/
    hex_organism_renderer.gd
    hex_outline_drawer.gd     # Adapter zu AntialiasedRegularPolygon2D
    hex_debug_overlay.gd
    organism_palette.gd
  ui/
    lab/
      simulation_lab_panel.gd
      organism_inspector.gd
  debug/
    perf_probe.gd             # eigene Sim-Counter
    debug_menu_adapter.gd     # Adapter zu DebugMenu-Plugin
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

addons/
  debug_menu/                   # vendored, festgelegte Version
  antialiased_line2d/           # vendored, festgelegte Version

tools/
  validate_hex_foundation.gd
```

### 6.3 Autoritätstabelle

| Thema | Autoritative Quelle | Schreibrecht |
|---|---|---|
| Hex-Math | `core/hex/*` | reine Funktionen |
| Tuningwerte | `resources/config/*.tres` | nur Editor; UI tweaked Runtime-Kopien |
| Genomwerte | `genetics/genome.gd` | `GenomeFactory` (Slice 1), später `MutationSystem` |
| Lokaler Zellkörper | `body/organism_body.gd` | nur über `SimulationService.place_cell()` |
| Zellfunktion | `CellBlock.function_id` + `CellFunctionCatalog` | nur Editor |
| Organismus-Energie | `OrganismState.energy` | `EnergySystem` (Slice 2) |
| Wachstumsladung | `OrganismState.growth_charge` | `GrowthSystem` (Slice 3) |
| Renderdaten | `runtime/derived_organism_snapshot.gd` | read-only, abgeleitet |
| Performance-Counter | `debug/perf_probe.gd` (Sim-spezifisch) + DebugMenu (Engine-Metriken) | nur Counter, nie Sim-Steuerung |

**Niemals autoritativ:** `Node2D.position`, `Polygon2D`-Vertices,
Debug-Overlay, UI-Labels, Editor-Szenenwerte (außer Composition).

---

## 7. Slice-Roadmap

### 7.1 Slice 0 — Repo, Doku, Workflow ("wie wir zusammenarbeiten")

**Ziel:** Verzeichnisstruktur + 8 Doku-Dateien + Test-Runner-
Skelett + leere Config-Resource-Skeletons + minimal ladende
Lab-Szene + zwei Asset-Vendor-Ordner als Stubs.

**Acceptance:**
- 8 Doku-Dateien existieren mit Stub-Inhalt
- Verzeichnisstruktur aus 6.2 angelegt
- `src/tests/test_runner.gd` läuft headless, exitcode 0
- `tools/validate_hex_foundation.gd` als Skelett, exitcode 0
- Projekt öffnet in Godot ohne Fehler
- ADRs: ADR-001..ADR-006 angelegt:
  - 001 Hex-Modell axial, Sim-agnostisch
  - 002 Daten vs. Nodes
  - 003 Cell-Funktionen als Daten-Tags
  - 004 Doku-Set 8 Dateien
  - 005 keine Pflicht-Autoloads in Slice 0
  - **006 Asset-Politik + zwei vendored Assets ab Slice 1**
- `addons/debug_menu/`, `addons/antialiased_line2d/` als leere
  Vendor-Ordner mit `README.md` "wird in Slice 1 befüllt"
- `NEXT_STEPS.md` definiert Slice 1

**Performance-Gate:** entfällt.

**Nicht anfangen:** Hex-Math-Implementierung, Genom, Energie,
Wachstum, Renderer-Code.

### 7.2 Slice 1 — First Visible Bacterium (Pivot-Slice)

**Ziel:** Der Nutzer öffnet das Lab, klickt durch 20 Seeds, und
sieht in jedem Seed ein deterministisches Bakterium aus den 4
Pflichtzellen, mit angenehm gerenderten "fließenden Zellwänden",
einem zentralen `energy_core`, und Debug-Overlays auf Knopfdruck.
Kein Energie-Tick, kein Wachstum.

**Subphase 1A — Hex-Kern** (1–2 Tage)
- `core/hex/hex_coord.gd`, `hex_grid_math.gd`
- Headless-Tests: 6 Nachbarn, axiale Distanz, bekannte Formen
  (Linie, Ring, Cluster), Connectedness, Boundary
- **Subphasen-Gate:** alle Tests grün, kein Godot-Node-Import in
  `core/hex/`.

**Subphase 1B — Body + Genom (headless)** (2–3 Tage)
- `body/cell_block.gd`, `organism_body.gd`, `body_topology.gd`,
  `body_factory.gd`
- `genetics/genome.gd`, `genome_factory.gd`, `genome_expression.gd`
- `sim/simulation_service.gd` mit `place_cell()` (intern: nur
  `body.cells[coord] = cell`, mit Doppelbelegungs-Check)
- Pflichtzellen-Bauplan: 1× `energy_core` zentral, 2–4× `photo­
  synthesis` an Boundary, 1× `reproduction`, Rest `wall`
- Headless-Tests: deterministisch via Seed, 20 Seeds → 20
  unterscheidbare aber valide Körper, alle connected, keine
  Doppel­belegung, alle Pflichtfunktionen vorhanden
- **Subphasen-Gate:** alle Tests grün; Genome inspector-lesbar.

**Subphase 1C — Lab-Renderer** (2–3 Tage)
- `runtime/derived_organism_snapshot.gd` — Snapshot mit
  `Array[(coord, function_id, base_color)]`
- `rendering/hex_organism_renderer.gd` — `Node2D._draw()`, liest
  nur Snapshot
- `rendering/organism_palette.gd` — Lookup `function_id → Color`
- `scenes/lab/simulation_lab.tscn` — Composition Root mit
  `SimulationService` als Kind-Node, `HexOrganismRenderer` als
  Kind-Node
- `ui/lab/simulation_lab_panel.gd` — Seed-Navigation
  (Zurück / Vor / Random / Eingabe), Inspector-Slots
- **Subphasen-Gate:** Lab läuft, Seed-Reihen werden gerendert,
  Hex-Polygone in den 4 Pflicht-Farben.

**Subphase 1D — Visuelle Politur + Assets** (2–3 Tage)
- `addons/antialiased_line2d/` — Plugin vendored und aktiviert
- `rendering/hex_outline_drawer.gd` — Adapter; nutzt
  `AntialiasedRegularPolygon2D` für jede Hex-Kontur
- "fließende Zellwände" — zwei Outline-Layer pro Zelle:
  - innerer dünner Outline in `base_color * 0.7`
  - äußerer dickerer Soft-Outline in `base_color` mit reduziertem Alpha
  - `wall`-Zellen kriegen extra dicken Outline
- `energy_core`-Zelle: zusätzliches Glow-Layer
  (`AntialiasedRegularPolygon2D` größer und transparent dahinter)
- `addons/debug_menu/` — Plugin vendored und aktiviert
- `debug/debug_menu_adapter.gd` — Hotkey F3 für DebugMenu (Engine-
  Metriken)
- `debug/perf_probe.gd` — eigene Counter (Cell-Count, Body-Build-
  Zeit, Snapshot-Build-Zeit)
- `rendering/hex_debug_overlay.gd` — Toggle Q/W/E für
  Koordinaten/Boundary/Funktion-Labels
- **Subphasen-Gate:** das Lab sieht für den Nutzer "gut genug" aus
  (User-Feedback-Loop hier explizit eingeplant)

**Slice-1-Acceptance gesamt:**
- Subphasen-Gates 1A–1D alle grün
- Renderer liest keine `OrganismBody`-Felder direkt (nur Snapshot)
- UI mutiert keine `.tres`-Assets zur Laufzeit
- `SimulationService.place_cell()` ist die einzige
  Zellplatzierungs-API (auch wenn Body trivial ist)
- 20 Seeds visuell + headless validiert
- DebugMenu zeigt FPS/Frametime per F3
- Visual-Smoke-Test: Screenshot pro Seed in `tools/screenshots/`
  speicherbar (manuell, optional)

**Performance-Gate:** 1 Bakterium mit 25 Zellen flüssig (60 FPS),
Body-Build < 50 ms, Snapshot-Build < 5 ms.

**Nicht-Ziele Slice 1:** Energie-Tick, Wachstum, mehrere
Organismen, Mutation, Shader, organische Verformung über
Outline-Layering hinaus.

### 7.3 Slice 2 — Energie v0

`TimeService`-Autoload (mit ADR-007), `EnergySystem`, `sun_intensity`,
Photosynthese-Produktion in `OrganismState.energy`,
Maintenance-Verbrauch, sichtbare Energiebilanz (HUD-Bar oder
Inspector-Wert), kein Wachstum.

**Performance-Gate:** 1 Bakterium 100 Zellen, Energie-Tick
deterministisch, kein NaN/Inf.

### 7.4 Slice 3 — Wachstum v0

`GrowthSystem`, Frontier-Anbau, Genom-Score für Zelltyp und
Position, Wachstum pro Tick begrenzt (`GrowthConfig.max_growth_per_tick`).

**Performance-Gate:** 1 Bakterium auf 250 Zellen wachsen lassen
flüssig, Wachstum bleibt connected, deterministisch via Seed.

### 7.5 Slice 4 — Genom-Expression v0

Mehr Gene werden in Wachstums-Score und Body-Bau aktiv.
20 Seeds → sichtbar verschiedene "Spezies".

### 7.6 Slice 5+ — Eigenes Plan-Artefakt pro Slice

Globales `WorldGrid` + `SimulationService.place_cell()`-Erweiterung,
mehrere Organismen, Reproduktion, Mutation, Bewegung,
Sensorik, Verdauung, Lichtkarte.

---

## 8. Asset-Entscheidungen (jetzt verbindlich, weil Pivot)

### 8.1 Slice-1-Pflicht (vendored in `addons/`, ab Slice 1 produktiv)

**Antialiased Line2D / AntialiasedRegularPolygon2D**
*Vendored ab Slice 1 / Subphase 1D*
*Lizenz: MIT*

- Asset Library: <https://godotengine.org/asset-library/asset/1266>
- GitHub: <https://github.com/godot-extended-libraries/godot-antialiased-line2d>

**Begründung jetzt:** Der Nutzer hat *explizit* "fließende
Zellwände" als Slice-1-Acceptance-Bedingung gesetzt. Ohne dieses
Asset müssten wir entweder:
- mit kantigen Hex-Polygonen leben (Nutzer-Acceptance ❌), oder
- Shader für Outline-Smoothing schreiben (Asset-Politik ❌:
  "Shader-Spike erst Slice 5+"), oder
- Asset später nachziehen und alle Outline-Code-Stellen anpassen
  (Architektur-Vorausschau ❌).

`AntialiasedRegularPolygon2D` zeichnet Hex-Outlines in einem
Aufruf, mit konfigurierbarer Linienbreite und Soft-Edge. Genau
das, was wir für die Slice-1-Visuelle brauchen.

**Adapter:** `rendering/hex_outline_drawer.gd` kapselt die
Plugin-API. Wenn das Plugin später stirbt, ändert sich nur dieser
Adapter.

**DebugMenu**
*Vendored ab Slice 1 / Subphase 1D*
*Lizenz: MIT*

- Asset Library: <https://godotengine.org/asset-library/asset/1902>
- GitHub: <https://github.com/godot-extended-libraries/godot-debug-menu>

**Begründung jetzt:** F3-Hotkey für FPS / Frametime / CPU-/GPU-Time
ist in Slice 1 gratis nutzbar und spart, dass wir später eigenes
FPS-Overlay bauen müssen. Kein Architektur-Risiko (liest nur
Engine-Counter, treibt keine Sim-Logik). Graviton hat es als
Vorbild — wir machen es ihm gleich.

**Adapter:** `debug/debug_menu_adapter.gd` ist trivial — bindet
Hotkey, fügt Plugin als AutoLoad hinzu (das ist der einzige
explizit erlaubte Autoload außerhalb von ADR, weil es ein
Engine-Metric-Plugin ist und ADR-006 das vorsieht).

### 8.2 Architekturlich vorausgesetzt (Built-in, kein Asset)

**Snapshot-getriebener Renderer-Pfad ab Slice 1**

`Node2D._draw()` reicht für 25–250 Zellen. Wir bauen ihn so, dass
er nur aus `DerivedOrganismSnapshot` liest. Wenn später
`MultiMeshInstance2D` oder ein Chunk-Renderer kommt, ändert sich
nur `rendering/hex_organism_renderer.gd`, nicht Sim/Body.

**`Resource` + `@export_range`**

Alle Configs als Resource. Inspector-tweakbar. Ist eingebaut, kein
Asset.

### 8.3 Bewusst auf später vertagt (mit Begründung)

| Asset | Wann sinnvoll | Warum nicht jetzt |
|---|---|---|
| **MultiMeshInstance2D** (Built-in) | wenn `_draw()` bei >250 Zellen kippt | spekulativ; Renderer-Architektur lässt Migration zu, ohne dass wir es jetzt einbauen |
| **TileMapLayer** (Built-in seit 4.3) | für Welt-Substrat / Lichtkarte | Slice 5+, nicht Foundation |
| **GUT** (Test-Framework) | wenn eigener Runner nicht reicht / CI-Bedarf | Konsens: eigener Runner. Migration ist später schmerzfrei. |
| **GdUnit4** | Alternative zu GUT | gleiche Einschätzung wie GUT |
| **Phantom Camera** | wenn mehrere Bakterien Kamera-Folgen brauchen | Slice 5+ |
| **Hexagon TileMapLayer** (Asset) | wenn statische Welt-Karte gebraucht wird | konkurriert mit Built-in TileMapLayer; pro Slice neu entscheiden |
| **Hexagonal Grid Utils** | nur als Vergleich für eigene Math | wir wollen eigene getestete `core/hex/` als Wahrheit |
| **Aseprite Wizard** | wenn handgemalte Sprites kommen | nicht mit `_draw()`-Renderer kombinierbar |
| **shaderV / Shaderpacks** | für organische Effekte | Shader-Spike erst Slice 5+ |
| **Imgui-Godot** | komplexe Debug-UI | Godot-Inspector reicht für Lab |
| **Beehave** (Behavior Trees) | für späteres Verhalten | wir haben Energie-/Wachstumsregeln, keine Behavior-Bäume |

### 8.4 Asset-Politik (verbindlich, in `docs/DECISIONS.md` als ADR-006)

1. **Kein Asset darf Sim-Wahrheit lesen oder schreiben.** Assets
   leben in `rendering/`, `debug/`, `ui/` oder `addons/`.
2. **Asset-Aufnahme per ADR.** Begründung muss enthalten: welcher
   Slice profitiert, welche Schicht hängt davon ab, welche
   Alternative geprüft wurde, welcher Adapter verwendet wird.
3. **Vendored, nicht Live-Reference.** Wir kopieren Assets in
   `addons/` und committen sie. Asset-Library-Updates kommen über
   bewusste Plugin-Updates, nicht automatisch.
4. **Adapter-Schicht Pflicht.** Jedes Plugin wird über ein
   eigenes Adapter-Skript angesprochen. Plugin-Tausch ändert nur
   den Adapter.
5. **Asset-Versionen in `README.md`.** Name, Version, Lizenz,
   Quelle.
6. **Plugin-AutoLoad nur, wenn das Plugin es zwingend braucht.**
   DebugMenu darf AutoLoad-Slot nutzen (ADR-006). Andere Plugins
   brauchen separate ADR.

---

## 9. Validierung

### 9.1 Headless-Validator pro Slice

**Slice 1 (alle Subphasen):**
- 1A: Hex-Math (6 Nachbarn, Distanz, Connectedness, Boundary)
- 1B: 20 Seeds → 20 unterscheidbare valide Körper, connected,
  Pflichtfunktionen, keine Doppelbelegung,
  `SimulationService.place_cell` wird verwendet
- 1C: Renderer benutzt nur Snapshot
- 1D: keine `.tres`-Mutation zur Laufzeit, Adapter funktionieren
  ohne Plugin (Mock)

**Slice 2:** Energie-Tick deterministisch, kein NaN/Inf
**Slice 3:** Wachstum connected, Wachstumskosten korrekt
**Slice 4:** Genom-Expression sichtbar, deterministisch

### 9.2 Manueller Lab-Check (ab Slice 1)

- Seed-Reihe durchklicken: jedes Bakterium sieht "ordentlich" aus
- Debug-Overlay an/aus (Q/W/E)
- DebugMenu-Hotkey F3 funktioniert
- Inspector-Slider auf `RenderConfig` → sichtbarer Effekt < 1 s
- "fließende Zellwände" gefällt dem Nutzer (= Subphase-1D-Gate)

### 9.3 Visual Smoke Test

Ab Slice 1 optional: pro Seed ein Screenshot in
`tools/screenshots/seed_<n>.png`. Dient als Regressions-
Vergleich, nicht als Pflicht.

---

## 10. Risiken und Gegenmaßnahmen

| Risiko | Priorität | Gegenmaßnahme |
|---|---|---|
| Hex-Math-Fehler in Adjazenz | P0 | Subphase 1A Headless-Tests |
| Renderer skaliert nicht | P0 | Snapshot-Architektur ab Slice 1, Migrationspfad zu MultiMesh ohne Sim-Änderung |
| Asset bricht bei Godot-Update | P1 | vendored Assets, Adapter-Schicht |
| "fließende Zellwände" gefallen Nutzer nicht | P1 | Subphase 1D als expliziter User-Feedback-Gate; ggf. Polish-Iteration vor Slice 2 |
| `SimulationService.place_cell` wird umgangen | P0 | Code-Review-Checkliste prüft "alle Mutationen über place_cell" |
| Doku wuchert | P1 | strikt 8 Doku-Dateien; ältere Notizen archivieren |
| Slice 1 wird zu groß | P1 | klare Subphasen-Gates 1A–1D, jede Phase einzeln einschätz- und reviewbar |
| `WorldGrid` wird in Slice 5 schmerzhaft nachgezogen | P0 | `place_cell()`-API ab Slice 1 — keine direkten `body.cells[...] = ...`-Stellen |
| Genom-Schema erweitert sich später | P1 | alle 8 Felder ab Slice 1 im Schema, auch wenn nur 5 davon in Slice 1 aktiv |
| `CellFunctionDef`-Schema erweitert sich | P1 | Vollschema ab Slice 1 |
| Scope-Erweiterung durch Agenten | P2 | Startprotokoll, Review, Doku-Sync |

---

## 11. Erste Codex-Aufträge

### 11.1 Slice 0 — sofort startbar nach Freigabe

```text
Bitte setze ausschließlich Slice 0 für Baktorium um.

Quelle (verbindlich, lies vollständig):
docs/Runde 2/Runde 3/Runde 4/BAKTORIUM_FUNDAMENT_v2.md

Ziel:
- Verzeichnisstruktur gemäß Sektion 6.2 anlegen.
- Die 8 kanonischen Doku-Dateien (Sektion 2.3) anlegen mit
  Stub-Inhalt, der die wichtigsten Punkte aus dem Fundament-
  Dokument zusammenfasst:
  - AGENTS.md (Workflow Sektion 2.2 + Review-Fokus + Asset-Politik 8.4)
  - README.md (Kurzstart, Doku-Übersicht, Doku-Hierarchie aus 6.3)
  - docs/ARCHITEKTUR.md (Sektionen 6.1–6.3)
  - docs/SIM_RULES.md (Sektionen 2.1 + 5)
  - docs/DECISIONS.md (ADR-001..ADR-006 mit Inhalten aus
    Sektionen 2.1, 2.4, 5.2, 8.4)
  - docs/STATUS.md (Stand: Slice 0 in Arbeit)
  - docs/NEXT_STEPS.md (verweist auf Slice-1-Briefing in
    BAKTORIUM_FUNDAMENT_v2.md Sektion 7.2)
  - docs/FINDINGS.md (leer, mit Format-Beschreibung)
- resources/config/*.tres als leere Resource-Skeletons (mit
  korrekt registrierter custom_class).
- resources/cell_functions/*.tres für die 4 Pflichtfunktionen
  als leere Resource-Skeletons (Felder existieren, Werte 0/leer).
- src/tests/test_runner.gd minimal: läuft headless mit 0 Tests,
  exitcode 0, druckt "Test runner: 0 tests, 0 failures".
- tools/validate_hex_foundation.gd als Skelett: headless,
  exitcode 0, druckt "Slice 0 validation: OK".
- scenes/lab/simulation_lab.tscn minimal: Node2D-Wurzel mit
  Label "Baktorium Lab — Slice 0". Lädt ohne Fehler.
- addons/debug_menu/ und addons/antialiased_line2d/ als
  Vendor-Ordner mit README.md "wird in Slice 1 befüllt".
  Nicht aktiviert in project.godot (das passiert in Slice 1).
- project.godot konfigurieren (kein Autoload, kein Plugin
  aktiviert).

Nicht-Ziele Slice 0:
- keine Hex-Math-Implementierung
- keine Genom-Logik
- keine Sim-Service-Implementierung
- kein Renderer
- keine Plugin-Aktivierung
- keine Pflicht-Autoloads

Arbeitsregeln:
- Keine Auto-Commits, kein Push, keine PRs ohne Freigabe.
- Halte die Schichten frei — auch Stubs respektieren die
  Dependency-Richtung aus 6.1.
- Änderungen so groß wie möglich, so klein wie nötig.

Validierung:
- Projekt öffnet in Godot 4.6 ohne Fehler.
- Lab-Szene lädt.
- test_runner und validator laufen headless.
- Doku ist widerspruchsfrei und referenziert
  BAKTORIUM_FUNDAMENT_v2.md.

Abschluss:
- Liste geänderter Dateien.
- Validierungsergebnis.
- Offene Risiken.
- Doku-Sync-Bestätigung.
- Commit-Vorschlag (Format aus AGENTS.md).
```

### 11.2 Slice 1 — Skizze (nach Slice-0-Abnahme freigeben)

Slice 1 wird nach Slice-0-Abnahme als eigenes Plan-Artefakt
detailliert (`docs/SLICE_1_PLAN.md`). Der Codex-Auftrag wird
dann pro Subphase 1A → 1B → 1C → 1D *einzeln* erteilt, nicht
gebündelt. Jede Subphase liefert eigenen Commit-Vorschlag und
eigenes Subphasen-Gate. Die Reihenfolge ist verbindlich (1A
muss grün sein bevor 1B startet, etc.).

Das hat zwei Vorteile gegenüber einem Mega-Auftrag:
- Reviewbarkeit pro Subphase
- der Nutzer kann nach 1C entscheiden, ob 1D's visuelle Politur
  schon reicht oder ob ein Polish-Iter-Cycle gebraucht wird

---

## 12. Was *nicht* in diesem Dokument steht

- Konkrete Klassennamen jenseits 6.2.
- Methoden-Signaturen.
- Code-Skeletons (auch keine GDScript-Snippets).
- Konkrete Pflichtzellen-Bauplan-Algorithmus jenseits "1× core,
  2–4× photo an Boundary, 1× repro, Rest wall" — Codex
  bestimmt das in Subphase 1B.
- Render-Shader-Details (Slice 5+).
- UI-Layout-Mockups.
- Save/Load-Format.

---

## 13. Plan-Artefakt-Block (für Calibration-Orchestrator)

```markdown
### Plan-Artefakt: Baktorium Fundament v2 (Pivot)

**Ziel:** First Visible Bacterium so früh wie möglich, mit sauberer
Architektur und früh getroffenen Asset-Entscheidungen, damit
spätere Slices keinen Refactor erzwingen.

**Approach:** Drei-Stimmen-Konsens (Codex / GPT / Claude) durch drei
Runden synthetisiert. v2 nimmt zusätzlich den Nutzer-Pivot vom
2026-05-02 auf: visuell früh, Architektur trotzdem sauber,
Asset-Entscheidungen vorgezogen.

**Schritte:**
1. Slice 0: Repo, Doku, Workflow (Sektion 11.1).
2. Slice 1: First Visible Bacterium — Subphasen 1A–1D
   (Sektion 7.2).
3. Slice 2: Energie v0.
4. Slice 3: Wachstum v0.
5. Slice 4: Genom-Expression v0.

**Abhängigkeiten:** Subphase N+1 startet erst nach validiertem
Subphasen-Gate von N. Slice N+1 erst nach validiertem
Performance-Gate von N und Doku-Update.

**Nicht-Ziele:** Sektion 2.5.

**Risiken:** Sektion 10 (P0: 4, P1: 6, P2: 1).

**Validierung:** Sektion 9 (headless + manuell + Visual Smoke).

**Evidenz:**
- Drei Runde-1, drei Runde-2, drei Runde-3-Pläne in docs/.
- Asset-Recherche dokumentiert in Sektion 8 mit URLs.
- Quell-Repos: Graviton, baktorio, Calibration_Orchestrator.
```

---

## 14. Anhang: Quellen

**Asset-Library**
- Antialiased Line2D: <https://godotengine.org/asset-library/asset/1266>
- Debug Menu: <https://godotengine.org/asset-library/asset/1902>

**GitHub**
- Antialiased Line2D: <https://github.com/godot-extended-libraries/godot-antialiased-line2d>
- Debug Menu: <https://github.com/godot-extended-libraries/godot-debug-menu>

**Godot-Doku**
- Custom Drawing 2D: <https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html>
- TileMapLayer: <https://docs.godotengine.org/en/latest/classes/class_tilemaplayer.html>
- MultiMeshInstance2D: <https://docs.godotengine.org/en/stable/classes/class_multimeshinstance2d.html>
- Resources: <https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html>
- GDScript Exports: <https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html>

**Theoretische Referenz**
- Red Blob Games — Hexagonal Grids: <https://www.redblobgames.com/grids/hexagons/>

**Test-Frameworks (für späteren Vergleich)**
- GUT: <https://github.com/bitwes/Gut>
- GdUnit4: <https://github.com/MikeSchulze/gdUnit4>

---

*Ende v2. Bei Freigabe geht der Slice-0-Auftrag aus 11.1 raus.
Nach Slice-0-Abnahme entsteht `docs/SLICE_1_PLAN.md` und Codex
beginnt Subphase 1A.*
