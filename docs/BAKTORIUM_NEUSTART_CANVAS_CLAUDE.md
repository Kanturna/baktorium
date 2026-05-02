# Baktorium — Planungs-Canvas v1 (Claude)

> **Status:** Planungsphase, *noch nicht* fix. Dieses Dokument ist Claudes Beitrag
> zur dialogischen Dreifach-Kalibrierung mit Codex und ChatGPT. Alles hier ist
> als **Vorschlag** und **Diskussionsgrundlage** zu lesen, nicht als Festlegung.
>
> **Autor:** Claude Code (Opus 4.7, 1M-Kontext)
> **Datum:** 2026-05-02
> **Ziel-Umsetzungsplattform:** Codex
> **Quellen:** Analyse der Repos `Graviton`, `baktorio`, `Calibration_Orchestrator`
> **Nicht-Quelle:** Spielinhalt von `baktorio` — bewusst ignoriert, Reset gewollt.

---

## 0. Was dieses Dokument ist (und nicht ist)

**Es ist:** Ein vollständiger, aber bewusst weicher Vorschlag für Domain-Modell,
Architektur, Doku-System, Workflow und ersten Slice-Plan. Gedacht zum
Zerpflücken durch Codex und ChatGPT, danach Konsens-Bildung, *dann* Umsetzung.

**Es ist nicht:** Ein Implementierungs-Plan. Es enthält bewusst keine
Code-Skeletons. Erst nach Triade-Konsens entsteht ein Slice-0-Implementierungs-Plan.

---

## 1. Was wir aus den drei Vorprojekten mitnehmen

### 1.1 Aus **Graviton** (am ausgereiftesten — Architektur-Blueprint)

- **Strikte Schichten:** `core/ → sim/ → runtime/ → scenes/`. Abhängigkeiten
  zeigen *nur* nach unten. Rückabhängigkeiten sind verboten.
- **Daten-/Sim-Wahrheit-Doktrin:** "Daten und Simulationszustand sind die
  Wahrheit. View-, Tool- und Szenen-Code ist Projektion, nie Simulationsquelle."
- **Genau zwei Autoloads** (TimeService, Registry). Alle anderen Services
  werden in der Composition-Root-Szene explizit verdrahtet (`_ready()`).
  Kein versteckter `get_node()`-Spaghetti.
- **Doku-Vierergespann:** STATUS, NEXT_STEPS, DECISIONS (ADRs), ARCHITEKTUR.
- **`@export_range`** auf jedem simulativ relevanten Parameter → Inspector-Tweaking.
- **Resource-Klassen** für Konfiguration (statt magischer Konstanten).
- **Diagnostik separat:** `PerfProbe` lebt in `tools/`, *nicht* in `sim/`.
  Sim-Services exponieren nur read-only Counter; Probe sampelt sie.
- **Conventional Commits** mit ausführlicher Body-Beschreibung bei Slices.
- **Performance-Budgets explizit:** Substep-Caps, Activation-Bubbles,
  Snapshot-Caches, dirty-basierte Refreshes.

### 1.2 Aus **baktorio** (was uns die Lehre kostet)

- **Was schiefging:** Hex-Tissue mit ~96 Cells und mehrere Fluid-Tropfen
  als *erster* Wurf. ADR-007 ist ein "supersedes" — alles wurde durch das
  einfachere Hull-and-Fluid-Modell ersetzt. Wörtlich: "kein Zurückpendeln
  zwischen zwei Körpermodellen."
- **Kernlehre:** **Slice-1-Scope explizit cuten.** "Was *nicht* in Slice 1
  gehört" muss in einem ADR stehen, sonst kriecht es zurück rein.
- **Modul-als-Tag (ADR-002):** Zell-Funktionen als **Daten-Tags**, nicht als
  Verhaltens-Klassen-Hierarchie. Verhindert Klassen-Spaghetti, wenn neue
  Funktionen dazukommen. → **Sehr relevant** für Baktoriums Zell-Typ-System.
- **Pipeline-Doktrin:** `Genome → BodyBlueprint → RuntimeState → Renderer`.
  Übertragbar als: `Genom → BakteriumsBauplan → LebendBakterium → Renderer`.
- **AGENTS.md-Regel:** "Keine Manager-Gottklasse. Kleine Dateien mit einer
  klaren Verantwortlichkeit bevorzugen."
- **Lücke, die wir schließen:** baktorio hat **keine CLAUDE.md** — Reviewer-
  Rolle für Claude war nicht definiert. Übernehmen wir aus Graviton.

### 1.3 Aus **Calibration_Orchestrator** (Workflow-Backbone)

- **Triadische Rollenteilung** ist klar: **Codex plant**, **Claude
  reviewed/reframet**, **Codex überarbeitet sichtbar**, bis Konsens =
  ausführbarer Plan.
- **Maschinenlesbare Result-Blöcke** (`<!-- ORCHESTRATOR_RESULT … -->`) am
  Ende jeder Agent-Antwort: `continue`, `status_proposal`, `judgment`,
  `findings`, `reframe_required`. → Wenn der Nutzer den Orchestrator für
  Baktorium nutzt, sollten unsere Antworten dieses Format einhalten.
- **Plan-Artefakt-Struktur:** Ziel · Approach · Schritte · Abhängigkeiten ·
  Nicht-Ziele · Risiken · Validierung · Evidenz. Wird unten benutzt.
- **AGENTS.md-Regel:** "Schreibe vor Architektur-Änderungen ab etwa 100
  verschobenen Zeilen ein read-only Planartefakt in `docs/`, lasse es
  gegenlesen und implementiere erst danach." → Übertragen wir.

---

## 2. Domain-Modell Baktorium (Vorschlag)

### 2.1 Geometrie: Hexagon-Lattice

- **Koordinatensystem:** axial `(q, r)` als kanonische Form, cube
  `(x, y, z)` mit `x+y+z=0` als Hilfsform für Distanz-/Rotations-Mathe.
  Quelle: Red Blob Games' Hex-Standard.
- **Topologie:** "pointy-top" oder "flat-top" — **Diskussionspunkt** für
  die Triade. Pointy-top ist intuitiver für vertikales Wachstum, flat-top
  für horizontale Schwärme. Vorschlag: **flat-top**, weil später
  Bewegungsachsen klarer sind.
- **Kontiguitäts-Invariante (hart):** Eine Zelle eines Bakteriums liegt
  *immer* lückenlos an mindestens einer anderen Zelle desselben
  Bakteriums an. Validator in `sim/topology/`.

### 2.2 Zelle (`Cell`)

Eine Zelle ist die atomare Baueinheit. Sie ist **Daten**, kein Node.

- `id: int` (StableId, Registry-vergeben)
- `axial: Vector2i` (q, r) — relativ zum Bakterium-Origin
- `function_tag: StringName` — Daten-Tag (siehe 2.4), keine Klassenhierarchie
- `energy: float` — lokaler Energie-Puffer
- `health: float` — Strukturintegrität (für späteren Schaden, aber Feld
  existiert ab Tag 1)
- `state_flags: int` — Bitfeld (z.B. ENERGY_OVERFLOW, READY_TO_DIVIDE)

### 2.3 Bakterium (`Organism`)

Ein Bakterium ist eine Sammlung verbundener Zellen mit gemeinsamem Genom.

- `id: int`
- `cells: Array[Cell]`
- `genome: Genome` (Resource)
- `world_origin: Vector2` (Pixel-Position des Bakterium-Ankers)
- `world_rotation: float` (für späteres Drehen)
- `energy_pool: float` (zentraler Vorrat, gespeist durch Energiekern)
- `age_ticks: int`

**Lifecycle:** spawn → wachsen (Vermehrungszelle) → teilen → sterben
(Energiemangel oder Strukturkollaps).

### 2.4 Zell-Funktionen als Daten-Tags

Statt Vererbung: jede Zelle hat einen `function_tag`, der über eine
Lookup-Tabelle (`CellFunctionRegistry`) auf Funktions-Daten verweist
(Energie-Produktion/Verbrauch, Vermehrungslogik, etc.).

**Slice-1-MVP-Tags (nur diese vier):**

| Tag | Funktion | Energiebilanz pro Tick |
|-----|----------|----------------------|
| `photosynthesis` | wandelt Sonnenintensität in Energie | `+sun_intensity * yield` |
| `energy_core` | speichert/verteilt an Nachbarn | Transfer-Logik |
| `division` | teilt Bakterium bei Energie-Schwellwert | `-energy_per_division` (einmalig) |
| `cell_wall` | Schutz, schließt Körper | `-wall_upkeep` |

**Spätere Tags (in Doku als "future scope" notieren, NICHT implementieren):**
`movement_thrust`, `eye_cone`, `digestion_chamber`, `mouth_intake`,
`spike_offensive`, `armor_wall`. Werden in DECISIONS.md als geplante
Erweiterungen vermerkt, damit die Architektur sie verträgt, aber kein
Code dafür entsteht.

### 2.5 Genom

- **Datenstruktur (Vorschlag):** Resource mit typisierten Feldern statt
  freier Bitstrings. Vorteile: Inspector-konfigurierbar, debugbar,
  versionierbar.
- **Slice-1-Felder:**
  - `photo_efficiency: float` (0.5–1.5)
  - `division_threshold: float` (Energie-Schwelle für Teilung)
  - `target_cell_count: int` (wie groß wird das Bakterium maximal)
  - `wall_ratio: float` (Anteil Wand-Zellen am Körper)
- **Mutation:** Bei Teilung wird Genom kopiert mit kleinem
  Gauß-Rauschen pro Feld. `mutation_sigma` ist globaler Sim-Parameter.
- **Diskussionspunkt für Triade:** Soll Genom später zu echtem
  Bitstring/Sequenz wachsen (für Crossover, regulatorische Netze)?
  Vorschlag: **typisierte Resource bleibt**, Genom-Sequenz wäre Overkill
  für das Spiel-Ziel.

### 2.6 Welt

- **Sonne:** globaler Skalar `sun_intensity`. Später vielleicht
  Tag/Nacht-Zyklus oder Lichtquellen mit Falloff — Slice 4+.
- **Substrat/Karte:** flaches Hex-Grid als Welt? Oder Bakterien
  schweben auf 2D-Plane mit eigenem internem Hex-Grid?
  **Diskussionspunkt:** Vorschlag = **Bakterien haben eigenes lokales
  Hex-Grid, schweben in 2D-Welt**. Vorteil: Welt-Größe ist nicht durch
  Hex-Auflösung gedeckelt; Bakterien können sich später frei drehen.

---

## 3. Architektur-Vorschlag

### 3.1 Schichten (übernommen aus Graviton, validiert durch baktorio)

```
scenes/      ← Composition Root, Inspector-UI, reine Projektion
   ▲
src/runtime/ ← Derived state, Caches, Snapshot-Layer für Renderer
   ▲
src/sim/     ← Autoritative Simulationslogik, Services
   ▲
src/core/    ← Math, Time, IDs, Hex-Math, Units
```

**Harte Regeln:**
- `core` kennt nichts oberhalb. Nur reine Funktionen.
- `sim` kennt `core`. Nicht `runtime`, nicht `scenes`.
- `runtime` kennt `sim` (read-only Snapshots), nicht `scenes`.
- `scenes` darf alles lesen, schreibt aber nie in Sim-State.

### 3.2 Verzeichnisstruktur (konkreter Vorschlag)

```
project.godot
src/
  core/
    hex/                # axial.gd, neighbors.gd, distance.gd, ring.gd
    ids/                # StableIdRegistry
    math/               # Hilfsfunktionen
    time/               # TimeService.gd (Autoload)
  sim/
    cells/              # CellFunctionRegistry, function-handler je Tag
    organism/           # Organism.gd, OrganismService.gd, lifecycle
    genome/             # Genome.gd (Resource), MutationService
    topology/           # ContiguityValidator, AdjacencyIndex
    energy/             # EnergyService (Photo-Tick, Transfer)
    world/              # WorldService (Sonne, später Substrat)
  runtime/
    snapshots/          # OrganismSnapshot, populated each tick
    spatial/            # SpatialIndex für Kollisions-Vorbereitung
  tools/
    debug/              # PerfProbe, ContiguityViz
    inspector/          # Custom Inspector-Plugins, falls nötig
resources/
  config/               # SimulationConfig.tres, GenomeConfig.tres
  cell_functions/       # CellFunctionDef.tres pro Tag
scenes/
  main.tscn             # Composition Root
  hud/                  # Debug-Overlays
  renderer/             # MultiMeshInstance2D / shader-basierter Hex-Renderer
docs/
  AGENTS.md
  CLAUDE.md
  ARCHITEKTUR.md
  STATUS.md
  NEXT_STEPS.md
  DECISIONS.md
addons/                 # Godot-Assets (siehe 5.4)
```

### 3.3 Autoloads — *exakt zwei*

- `TimeService` — emittiert `sim_tick(delta_seconds)`, einziger Tick-Treiber.
- `SimRegistry` — hält Welt-State, Organism-Liste, IdRegistry.

**Alle anderen Services** (EnergyService, OrganismService, etc.) werden in
`scenes/main.tscn` als Kind-Nodes verdrahtet.

### 3.4 Was *nicht* in die Architektur gehört (Anti-Patterns)

- **Keine Manager-Gottklasse** (`SimulationManager` mit 1000 Zeilen).
- **Keine Sim-Wahrheit in `scenes/`** (z.B. `Cell` als Node mit eigenem
  `process()`, der Energie verändert).
- **Keine Nodes als Daten-Container.** `Cell` und `Organism` sind
  RefCounted-Datenklassen, nicht Nodes.
- **Keine versteckten Singletons** über `get_tree().root.get_node(...)`.

---

## 4. Doku-System (mit Bewertung der Vorprojekte)

### 4.1 Bewertung der bisherigen Doku-Sets

**Graviton (5 Dateien):** AGENTS, CLAUDE, ARCHITEKTUR, STATUS, NEXT_STEPS,
DECISIONS — sehr klare Aufgabenteilung, keine Redundanz, **Goldstandard**.

**baktorio (6 Dateien):** AGENTS, ARCHITEKTUR, STATUS, NEXT_STEPS,
DECISIONS, BODY_SYSTEM — letzteres ist Domain-spezifisch, fühlt sich
*okay* an, könnte aber als ADR-Anhang leben. Lücke: keine CLAUDE.md.

### 4.2 Vorschlag für Baktorium: **6 Dateien, klar getrennt**

| Datei | Zweck | Update-Frequenz |
|-------|-------|-----------------|
| `docs/AGENTS.md` | Vertrag für *alle* AI-Agenten (Codex, Claude, ChatGPT). Startprotokoll, Slice-Regeln, Commit-Format. | Selten (Architektur-Vertrag) |
| `docs/CLAUDE.md` | Reviewer-Spezifika für Claude (verlinkt AGENTS.md, ergänzt Review-Checkliste). | Selten |
| `docs/ARCHITEKTUR.md` | Normativ: Schichten, Autoritäten, Verbote, Autoloads. | Bei großen Architektur-ADRs |
| `docs/STATUS.md` | "Was läuft gerade, welcher Slice ist abgeschlossen, was sind sichtbare Effekte." | Pro Slice / pro PR |
| `docs/NEXT_STEPS.md` | Nächster Slice, offene Gates, bekannte Bugs (statt eigener BUGS.md). | Pro Slice / nach Bugfund |
| `docs/DECISIONS.md` | ADR-001..NNN. Jede Architekturentscheidung dokumentiert mit Kontext, Optionen, Wahl, Nicht-Ziele. | Bei jeder Architekturentscheidung |

**Was wir konsolidieren:** Bugs leben in `NEXT_STEPS.md` unter
`## Bekannte Bugs`. Eine separate `BUGS.md` ist Overhead, weil Bugs
ohnehin im nächsten Slice priorisiert werden müssen — wo sonst wäre der
natürliche Ort?

**Was wir *nicht* aufnehmen:** PERFORMANCE.md (Performance-Notizen
gehören in ADRs, sonst rotten sie), HANDOFF.md (Conversational-Drift —
wenn Konversation endet, gehört der Stand in STATUS).

**Diskussionspunkt für Triade:** Reicht `NEXT_STEPS.md` für Bugs, oder
braucht es separate `BUGS.md`? Mein Vote: kein zusätzliches Doc.

### 4.3 ADR-Format (verbindlich)

```markdown
## ADR-NNN: [Titel]
- **Status:** proposed | accepted | superseded by ADR-XXX
- **Datum:** YYYY-MM-DD
- **Kontext:** Welches Problem, welche Constraints?
- **Optionen erwogen:** A, B, C — kurz pro/contra
- **Entscheidung:** [gewählte Option, in einem Satz]
- **Begründung:** Warum diese, nicht die anderen?
- **Konsequenzen:** Was folgt daraus, was wird *nicht* unterstützt?
- **Nicht-Ziele:** Was bleibt explizit ausgeschlossen?
```

---

## 5. Workflow & Konventionen

### 5.1 Commit-Konvention (übernommen aus Graviton + baktorio)

- **Format:** `<type>(<scope>): <imperative title>` — Conventional Commits.
- **Types:** `feat`, `fix`, `docs`, `refactor`, `test`, `perf`, `chore`.
- **Scope-Beispiele:** `core`, `sim`, `runtime`, `scenes`, `genome`,
  `energy`, `topology`, `docs`.
- **Body:** Bei Slice-Commits ausführlich: was wurde gemacht, welche
  Architekturentscheidung steckt dahinter, welche Dateien sind
  betroffen, welche Validierung lief, was wurde *bewusst nicht* gemacht.
- **Pflicht:** Nach jeder Code-Änderung schlägt der Agent **selbständig**
  Commit-Titel und -Body vor. Der Nutzer muss nicht nachfragen.

### 5.2 Slice-Regel: "so groß wie möglich, so klein wie nötig"

Übernommen aus baktorio's AGENTS.md, paraphrasiert:

> Ein Slice fasst alle Änderungen zusammen, die thematisch
> zusammengehören und gemeinsam validierbar sind. Mikro-Slicing
> (jede Datei ein Commit) ist verboten, wenn die Änderungen logisch
> zusammenhängen. Riesen-Slices sind verboten, wenn Teile davon
> unabhängig getestet werden könnten.

**Faustregel:** Ein Slice = ein PR-würdiges Stück Funktionalität, das
alleinstehend Sinn ergibt und ohne den nächsten Slice keinen halben
Zustand hinterlässt. Architektur-Änderungen ab ~100 verschobenen Zeilen
brauchen ein vorgelagertes Plan-Artefakt in `docs/`.

### 5.3 Vor jeder Code-Änderung (Startprotokoll)

1. `git status` lesen, sicherstellen dass kein verwaister Stand existiert.
2. `docs/STATUS.md`, `docs/NEXT_STEPS.md`, `docs/ARCHITEKTUR.md` lesen.
3. Schicht der geplanten Änderung benennen.
4. Annahmen, Risiken, Validierungspfad nennen.
5. *Dann* implementieren.

### 5.4 Godot-Assets (Diskussionspunkt)

Der Nutzer wünscht Godot-Asset-Nutzung wo sinnvoll. Vorschläge zur
Evaluierung **vor** Slice 1:

- **Multimesh-Renderer** für Hex-Cells (statt N MeshInstance2D Nodes).
  In Engine, kein Asset.
- **`AntialiasedLine2D` / `AntialiasedPolygon2D`** für Hex-Outlines —
  in Graviton evaluiert, dort als Kandidat genannt.
- **DebugMenu-Plugin** für FPS/Frametime/Memory — Graviton-Vorbild.
- **Resource-driven Inspector-Plugins** falls Custom-Editing nötig wird
  (Slice 4+, nicht Slice 1).

**Diskussionspunkt für Triade:** Welche konkreten Asset-Lib Builds passen?

---

## 6. Slice-Roadmap (Vorschlag, alles weich)

### Slice 0 — Fundament

- Verzeichnisstruktur anlegen (siehe 3.2).
- `docs/`-Set initialisieren (alle 6 Dateien mit Stub-Inhalt).
- `core/hex/` Math-Modul (axial coords, neighbors, distance, ring).
- `TimeService`, `SimRegistry` als Autoloads.
- `SimulationConfig.tres` Resource mit `@export_range` für Sun-Intensity,
  Tick-Rate, etc.
- ADR-001 (Hex-Orientierung), ADR-002 (Daten vs. Nodes), ADR-003
  (Cell-Funktionen als Tags).
- **Validierung:** Projekt startet ohne Fehler, Inspector zeigt
  SimulationConfig.

### Slice 1 — Erste lebende Zelle

- Eine `Cell` mit Tag `photosynthesis`, fixiert auf Hex `(0, 0)`.
- `EnergyService` tickt: `cell.energy += sun_intensity * cell.efficiency`.
- Renderer: einzelnes Hex, Farbe oder Bar zeigt Energie-Level.
- Inspector ändert `sun_intensity` → sichtbarer Effekt.
- **Validierung:** Headless-Test über `godot_console.exe` (siehe Memory),
  Energie steigt monoton.

### Slice 2 — Bakterium aus mehreren Zellen

- `Organism` mit fester Bauplan-Konfiguration: 1 EnergyCore + 4 Photo +
  2 Wall (Beispiel).
- `EnergyCore` verteilt jeden Tick an Nachbarn.
- `ContiguityValidator` prüft beim Spawn, dass alle Cells verbunden sind.
- Renderer zeigt das Bakterium.
- **Validierung:** Bakterium spawnt, Energie-Bilanz im Debug-Overlay
  korrekt, Wand-Cells umschließen tatsächlich die anderen.

### Slice 3 — Vermehrung

- `Division`-Cell teilt Bakterium bei Energie-Schwellwert.
- Tochter spawnt an freier Hex-Position in der Welt (Spatial-Lookup).
- Genom wird kopiert (noch ohne Mutation).
- **Performance-Gate:** 50 Bakterien gleichzeitig flüssig (>= 60 FPS).
- ADR über Pooling-Strategie, falls Performance-Gate kippt.

### Slice 4 — Genom & sichtbare Variation

- Genom-Resource mit den 4 Slice-1-Feldern.
- Mutation bei Teilung (Gauß-Rauschen).
- Renderer codiert Genom-Diversität visuell (z.B. Farbverschiebung).
- Inspector zeigt globalen `mutation_sigma`.
- **Validierung:** Nach 1000 Ticks sichtbare Population-Diversität.

### Slice 5+ — Erweiterung (NICHT planen, nur ausschließen)

Bewegung, Sicht, Verdauung, Kampf — alle werden in DECISIONS.md als
"future scope, accepted aber nicht eingeplant" notiert, damit die
Architektur sie verträgt, aber kein Code entsteht.

---

## 7. Performance-Strategie (vom ersten Tag)

- **Fixed-Step Simulation:** TimeService treibt mit konstanter Rate
  (z.B. 30 Hz Sim-Tick), Renderer interpoliert bei Bedarf.
- **MultiMesh für Hex-Rendering:** ein MultiMeshInstance2D pro
  Cell-Funktions-Tag, Instanzen = lebende Zellen. Skaliert auf
  Tausende.
- **Spatial Index:** Bakterien-Origins in räumlichem Grid; Hex-interne
  Adjazenz via vorberechnetem Index.
- **Object Pooling:** Cells und Organisms aus Pool, nicht ständig neu
  allokiert (Slice 3+, wenn relevant).
- **Snapshot-Layer (`runtime/snapshots/`):** Renderer liest
  Snapshot-Resources, nicht direkt Sim-State. Erlaubt späteres
  Threading.
- **PerfProbe von Tag 1:** Tick-Dauer, Cell-Count, Organism-Count,
  Energy-Throughput in CSV/JSON dumpbar (Hotkey + CLI-Arg, wie Graviton).
- **Performance-Budget pro Slice festschreiben:** z.B. Slice 3 muss
  bei 100 Bakterien × 7 Cells = 700 Cells stabil über 30 FPS bleiben.

---

## 8. Inspector-Konfigurierbarkeit (Wunsch des Nutzers)

Alle simulativ relevanten Parameter über Resource + `@export_range`:

```gdscript
# resources/config/SimulationConfig.gd
extends Resource
class_name SimulationConfig

@export_range(0.0, 5.0, 0.05) var sun_intensity: float = 1.0
@export_range(1, 120) var sim_tick_rate_hz: int = 30
@export_range(0.0, 0.5, 0.001) var mutation_sigma: float = 0.05

@export_group("Energy")
@export_range(0.0, 10.0, 0.1) var photo_yield_per_tick: float = 1.0
@export_range(0.0, 5.0, 0.1) var wall_upkeep_per_tick: float = 0.1

@export_group("Reproduction")
@export_range(10.0, 1000.0, 1.0) var division_threshold_default: float = 100.0
```

Cell-Funktionen werden ebenfalls als Resource-Definitionen ausgeliefert
(`resources/cell_functions/photosynthesis.tres` etc.), so dass der Nutzer
sie im Inspector tweaken kann ohne Code anzufassen.

---

## 9. Offene Fragen für die dialogische Triade

Diese Fragen erwarten Beiträge von Codex und ChatGPT:

1. **Hex-Orientierung:** flat-top vs. pointy-top? *(Mein Vote: flat-top.)*
2. **Welt-Modell:** Bakterien mit eigenem lokalen Hex-Grid auf 2D-Plane,
   oder ein global gemeinsames Hex-Grid? *(Mein Vote: lokal.)*
3. **Genom-Repräsentation:** typisierte Resource bleibt, oder später
   echte Sequenz für Crossover? *(Mein Vote: Resource bleibt.)*
4. **Doku-Anzahl:** 6 Dateien wie vorgeschlagen, oder Konsolidierung
   (z.B. AGENTS+CLAUDE)? *(Mein Vote: 6 — CLAUDE.md kurz und verlinkt.)*
5. **Renderer:** MultiMesh + Shader, oder Custom `_draw()`? *(Mein Vote:
   MultiMesh, Custom-Draw nur als Fallback.)*
6. **Performance-Gates:** Sollen sie *vor* einem Slice festgeschrieben
   werden (mit Nicht-Erfüllung = Slice abbrechen) oder retrospektiv? *(Mein
   Vote: vor Slice, ADR-pflichtig.)*
7. **Substrat-/Ressourcen-Modell:** Photosynthese global per
   `sun_intensity`, oder Welt-Karte mit lokalen Lichtwerten? *(Slice
   1: global. Karte ist Slice 4+.)*
8. **Mutationsmodell:** nur Gauß auf Skalare, oder auch struktureller
   Bauplan-Mutation (Cell hinzu/weg)? *(Slice 4: nur Skalar. Strukturell
   ist Slice 5+.)*
9. **Calibration_Orchestrator:** Soll Baktorium dessen
   `ORCHESTRATOR_RESULT`-Block-Format konsumieren, also dass jede
   AI-Antwort den JSON-Block setzt? *(Mein Vote: ja, wenn der Nutzer
   den Orchestrator nutzt.)*

---

## 10. Nicht-Ziele für Slice 0–4 (explizit)

Diese Liste ist **bindend für die ersten fünf Slices**. Sie zu erweitern
bedarf eines ADR.

- ❌ Bewegung von Bakterien
- ❌ Sicht / Augen / Wahrnehmung
- ❌ Verdauung / Münder / Nahrungsaufnahme aus Beute
- ❌ Kampf / Dornen / Schaden / Tod durch Angriff
- ❌ Crossover / sexuelle Vermehrung
- ❌ Strukturelle Mutation (Cell hinzu/weg/umfunktionieren)
- ❌ Mehrere Welt-Substrate / Biome
- ❌ Tag/Nacht-Zyklus
- ❌ Save/Load des Welt-Zustands (kommt nach Slice 4)
- ❌ Multiplayer / Networking
- ❌ Detailrenderer (Sub-Cell-Texturen, Animationen)
- ❌ UI über Inspector-Sliders hinaus

---

## 11. Plan-Artefakt im Calibration-Orchestrator-Format

```markdown
### Plan-Artefakt: Baktorium-Foundation

**Ziel:** Eine emergente Hexagon-Zell-Sim mit klarer Schichtenarchitektur,
Daten-Wahrheit-Doktrin und striktem Slice-Workflow aufbauen, beginnend
mit photosynthetisch-basierten Bakterien aus rein grundlegenden Zellen.

**Approach:** Architektur und Doku aus Graviton übernehmen, Lehren aus
baktorio's gescheiterter v1 berücksichtigen (Scope-Cuts explizit), Workflow
aus Calibration_Orchestrator (triadische Konsens-Bildung) anwenden. Alle
Erweiterungs-Cell-Funktionen (Bewegung, Sicht, Kampf) als ADR-akzeptierte
Future-Scope notieren, aber nicht implementieren.

**Schritte:**
1. Triade-Konsens über diesen Plan (Codex + ChatGPT lesen, kommentieren,
   Claude überarbeitet) — Deliverable: `PLANUNG_v2.md` mit allen drei
   Stimmen integriert.
2. Slice-0-Plan-Artefakt schreiben (Verzeichnisstruktur, Doku-Stubs,
   Hex-Math, Autoloads, ADR-001..003) — Deliverable: `docs/NEXT_STEPS.md`.
3. Slice 0 implementieren via Codex — Deliverable: lauffähiges
   Skelett-Projekt.
4. Slice 1: erste Photosynthese-Zelle — Deliverable: Inspector-Demo.
5. Slice 2–4 wie in Roadmap (Sektion 6).

**Abhängigkeiten:** Slice N+1 startet erst, wenn Slice N's
Validierungs-Gate bestanden ist und STATUS.md aktualisiert ist.

**Nicht-Ziele:** Siehe Sektion 10. Verbindlich für Slice 0–4.

**Risiken:**
- **P0:** Hex-Math-Fehler (off-by-one in Adjazenz) → schwer zu debuggen.
  Mitigation: Unit-Tests für `core/hex/` von Tag 1.
- **P0:** Renderer-Wahl (MultiMesh vs. Custom-Draw) entscheidet über
  Skalierbarkeit. Mitigation: Spike in Slice 0 mit 1000 Test-Hexes.
- **P1:** Genom-Resource als typisierte Klasse erschwert späteren
  Crossover. Mitigation: ADR über Genom-Erweiterungspfad in Slice 4.
- **P1:** "Sun-Intensity global" könnte zu Slice 4 zu enge Konstruktion
  sein. Mitigation: WorldService kapselt das jetzt schon hinter
  Funktion `get_light_at(world_pos)`.
- **P2:** Doku-Drift nach mehreren Slices. Mitigation: Pflicht-Update
  von STATUS+NEXT_STEPS in jedem Slice-Commit.

**Validierung:**
- Per Slice: Headless-Run via `godot_console.exe`, Sim-Counter werden
  gedumpt und gegen Erwartung verglichen.
- Manueller Check: Inspector-Slider bewegen, sichtbarer Effekt
  innerhalb 1 Sekunde.
- Architektur-Check (durch Claude bei jedem Review): Schichtenrichtung,
  versteckte Sim-Wahrheit in scenes/, Doku-Sync.

**Evidenz:**
- Quell-Repos analysiert: `d:\Projekte\Godot\Graviton`,
  `d:\Projekte\Godot\baktorio`, `d:\Projekte\Godot\Calibration_Orchestrator`.
- Konkrete übernommene Patterns: Graviton's `core/sim/runtime/scenes`,
  baktorio's "Module-als-Tags" (ADR-002), Orchestrator's
  Plan-Artefakt-Format.
```

```html
<!-- ORCHESTRATOR_RESULT
{
  "continue": "yes",
  "status_proposal": "pending_codex",
  "judgment": "needs_context",
  "findings": {"p0": 2, "p1": 2, "p2": 1},
  "next_expected_gain": "Codex und ChatGPT nehmen Stellung zu den 9 offenen Fragen in Sektion 9 und ergänzen/widersprechen den Slice-Cuts in Sektion 10. Konsens-Plan v2 entsteht daraus.",
  "reframe_required": false
}
-->
```

---

## 12. Was ich (Claude) explizit *nicht* festlegen will

- Konkrete Klassennamen, Methoden-Signaturen, Datei-Inhalte. Das ist
  Codex's Job nach Konsens.
- Die endgültige Antwort auf die 9 offenen Fragen — Triade soll
  diskutieren.
- UI-/Renderer-Details über MultiMesh-Empfehlung hinaus.
- Save/Load-Format — Slice 5+, irrelevant jetzt.

---

*Ende Canvas v1. Bitte Codex- und ChatGPT-Beiträge anhängen oder als
v2-Datei integrieren.*
