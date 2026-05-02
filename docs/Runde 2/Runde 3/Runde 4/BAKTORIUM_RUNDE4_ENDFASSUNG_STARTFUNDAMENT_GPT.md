# Baktorium – Fundament v1.1

> Status: **Endfassung nach Codex-/Claude-Konsens + Nutzerpräzisierung**  
> Zweck: Verbindlicher Planungsanker für den Projektstart  
> Fokus: **Arbeitsweise + Architekturfundament + erstes visuelles Starter-Bakterium**  
> Umsetzung: Codex  
> Review: Claude Code + ChatGPT/Lyra  
> Projektname: **Baktorium**

---

## 0. Kurskorrektur dieser Endfassung

Die bisherigen Konsenspläne waren architektonisch stark, aber für den allerersten sichtbaren Schritt etwas zu abstrakt. Die Nutzerpräzisierung verschiebt den Startfokus:

> Am Anfang soll nicht nur ein leeres Fundament entstehen, sondern sehr früh ein **erstes visuelles Starter-Bakterium** sichtbar werden: mit Zellkern/Energiezentrum, fließender Zellwand und Photosynthese-Komponente.

Das verändert nicht die Grundarchitektur, aber es verändert die erste Roadmap:

```text
Nicht: erst lange unsichtbare Infrastruktur, dann irgendwann Darstellung.
Sondern: sauberes Fundament + früher visueller Vertikalschnitt.
```

Der zentrale Schutzsatz bleibt:

> **Visuelle Schönheit darf früh geprüft werden, aber sie darf nie Simulationswahrheit werden.**

---

## 1. Leitentscheidung

Baktorium wird eine Godot-4.x-Simulation von zellulären Bakterienkörpern auf Hex-Basis.

Die erste Zielsequenz lautet jetzt:

```text
1. Projektvertrag, Doku, Ordnerstruktur, Asset-Policy.
2. Hex- und Visual-Foundation so aufbauen, dass kein späterer Umbau nötig wird.
3. Erstes Starter-Bakterium im Lab sichtbar machen.
4. Danach Energie, Wachstum und Genom-Einfluss schrittweise aktivieren.
```

Langfristige Sim-Reihenfolge:

```text
Hex-Topologie
-> deterministischer Zellkörper
-> visuelles Starter-Bakterium
-> Energie
-> Wachstum
-> Genom-Einfluss
-> Population / Mutation / Bewegung / Kampf / Verdauung
```

---

## 2. Harte Grundsätze

- Daten und Simulationszustand sind Wahrheit.
- Nodes, Renderer, UI, Debug-Overlays und Szenen sind Projektion.
- Eine funktionale Zelle ist ein Hex-Block.
- Ein Bakterium ist ein direkt zusammenhängender Verbund aus Hex-Zellen.
- Keine Zelle schwebt mit Abstand neben einer anderen Körperzelle.
- Sim nutzt axiale Hex-Koordinaten `(q, r)`.
- Cube-Koordinaten werden nur abgeleitet, wenn Algorithmen sie brauchen.
- Boundary/Oberfläche ist abgeleitet, nicht gespeichert.
- Config-Resources sind Tuningwerte, keine Runtime-Wahrheit.
- Keine Manager-Gottklasse.
- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Assets dürfen Darstellung, Debugging und Bedienung verbessern, aber keine Sim-Wahrheit erzeugen.

---

## 3. Was im ersten Schritt wirklich entschieden werden muss

Damit später kein unnötiger Umbau entsteht, werden jetzt festgelegt:

1. **Doku- und Agentenvertrag**  
   Damit Codex, Claude und GPT gleich arbeiten.

2. **Schichten und Verzeichnisstruktur**  
   Damit Sim, Renderer, UI und Debug nicht ineinander wachsen.

3. **Render-Architektur**  
   Weil der erste sichtbare Körper direkt richtig angebunden werden soll.

4. **Asset-Policy und frühe Asset-Auswahl**  
   Weil spätere Render-/Debug-Umbauten teuer werden können.

5. **Starter-Bakterium als visueller Vertikalschnitt**  
   Damit früh geprüft werden kann: „Gefällt mir diese Richtung?“

Noch nicht entschieden werden müssen:

- genaue Mutationslogik
- echte Tochterorganismen
- Kampf/Sensorik/Verdauung
- mehrere Organismen
- globale Weltkarte
- Save/Load
- finale Performance-Renderer

---

## 4. Finales Doku-Set

```text
AGENTS.md
README.md
docs/ARCHITEKTUR.md
docs/SIM_RULES.md
docs/DECISIONS.md
docs/STATUS.md
docs/NEXT_STEPS.md
docs/FINDINGS.md
docs/BAKTORIUM_FUNDAMENT_v1_1.md
```

Entscheidungen:

- `SIM_RULES.md` statt `CELL_SYSTEM.md`, weil Hex, Zellen, Energie, Wachstum, Genom und Tick-Reihenfolge zusammengehören.
- `FINDINGS.md` statt `BUGS.md`, weil dort Bugs, Review-Findings, Debug-Befunde und Architekturhinweise gesammelt werden.
- Keine separate `CLAUDE.md` in Slice 0; Claude-Review-Fokus kommt in `AGENTS.md`.
- Kein `HANDOFF.md`, kein `AI_KONTEXT.md`, keine separate `PERFORMANCE.md` am Anfang.

Priorität bei Widerspruch:

1. `docs/ARCHITEKTUR.md` für Schichten, Autoritäten, Verbote.
2. `docs/DECISIONS.md` für Architekturentscheidungen.
3. `docs/SIM_RULES.md` für Simulationsregeln.
4. `docs/STATUS.md` für realen Implementierungsstand.
5. `docs/NEXT_STEPS.md` für den nächsten Arbeitsblock.
6. `AGENTS.md` für Arbeitsprozess.
7. `README.md` für Orientierung.
8. Ältere Planungsnotizen sind Hintergrund.

---

## 5. Architektur

### 5.1 Dependency-Richtung

```text
ui / debug / scenes
  -> rendering
  -> runtime
  -> sim
  -> body / cells
  -> genetics
  -> config / core
```

Regeln:

- `core/` kennt keine Godot-Nodes und keine höheren Schichten.
- `config/` enthält Resources und Defaults, keine Runtime-Wahrheit.
- `genetics/` erzeugt und interpretiert Genome, entscheidet aber nicht über Rendering.
- `body/` und `cells/` halten lokale Zellkörperdaten und Topologie.
- `sim/` ist autoritativ für Energie, Wachstum, Tick und spätere Weltlogik.
- `runtime/` erzeugt Snapshots und abgeleitete Lesemodelle.
- `rendering/` zeichnet nur.
- `ui/`, `debug/`, `scenes/` steuern Bedienung, Diagnose und Verdrahtung, aber keine Sim-Regeln.

### 5.2 Verzeichnisstruktur

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
  BAKTORIUM_FUNDAMENT_v1_1.md

src/
  core/
    hex/
    rng/
    ids/

  config/
    simulation_config.gd
    hex_grid_config.gd
    cell_function_def.gd
    cell_function_catalog.gd
    genome_config.gd
    growth_config.gd
    render_config.gd
    visual_style_config.gd
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
    visual_snapshot.gd
    simulation_snapshot_cache.gd

  rendering/
    hex_cell_renderer.gd
    starter_bacterium_renderer.gd
    membrane_renderer.gd
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
    visual_style_config.tres
    lab_config.tres

  cell_functions/
    energy_core.tres
    photosynthesis.tres
    reproduction.tres
    wall.tres

  cell_function_catalog.tres

tools/
  validate_hex_foundation.gd

addons/
  # zunächst leer; Asset-Aufnahme nur per ADR
```

---

## 6. Autoload-Entscheidung

Slice 0 startet ohne projekt-eigene Autoloads.

Regel:

- Die Lab-Szene ist Composition Root.
- Services werden explizit verdrahtet.
- `TimeService` kann ab Energie-/Tick-Slice per ADR eingeführt werden.
- Keine globale Registry ohne konkreten Bedarf.

Grund:

Autoloads sind globale Kopplung. Baktorium übernimmt Gravitons Disziplin, aber nicht dessen reife Projektstruktur ab Tag 1.

---

## 7. Domain-Modell v0

### 7.1 HexCoord

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

- genau eine lokale Hex-Koordinate pro funktionaler Zelle
- keine doppelten Koordinaten im Organismus
- Körper bleibt connected
- Boundary wird abgeleitet

### 7.2 CellBlock

Eine funktionale Zelle ist Daten, kein Node.

Minimalfelder:

```text
cell_id
coord: HexCoord
function_id: StringName
```

Später möglich:

```text
integrity
age_ticks
flags
local_energy
```

Nicht Foundation:

- lokale Zellenergie
- lokale Zell-HP
- eigene `_process()`-Logik
- eigene Godot-Node pro Zelle

### 7.3 OrganismBody

`OrganismBody` hält:

- Dictionary nach Hex-Key
- funktionale Zellen
- lokale Topologie
- Pflichtfunktionen

Keine Energie, kein Tick, keine Renderdaten.

### 7.4 OrganismState

`OrganismState` hält:

```text
energy
growth_charge
age_ticks
alive
```

### 7.5 WorldState

`WorldState` existiert früh, bleibt aber klein:

- globaler Seed
- Tick/Sim-Zeit
- Liste von Organismen

Ein globales Zell-`WorldGrid` wird nicht in Slice 0/1 erzwungen. Sobald mehrere Organismen, Tochterorganismen, Kollision oder globale Belegung relevant werden, kommt ein eigener Occupancy-Slice mit ADR.

---

## 8. Zellfunktionen v0

Finale Foundation-Zellfunktionen:

```text
energy_core
photosynthesis
reproduction
wall
```

Semantik:

| Funktion | Bedeutung |
|---|---|
| `energy_core` | Pflichtzelle, Identität, Zellkern-/Energiezentrum |
| `photosynthesis` | Energiequelle, grüne/photosynthetische Komponente |
| `reproduction` | später Wachstumsladung / Anbaupotenzial |
| `wall` | Struktur-/Schutz-/Membran-Komponente, ohne HP-System |

Nicht in Foundation:

- separate `core` plus `energy_core`
- `cytoplasm`
- lokale Zell-HP
- lokale Zellenergie
- lokale Energie-Diffusion

---

## 9. Erstes visuelles Starter-Bakterium

### 9.1 Zielbild

Der erste sichtbare Spielinhalt ist kein leeres Testprojekt, sondern ein **Starter-Bakterium v0**.

Es soll zeigen:

- ein sichtbares Zellkern-/Energiezentrum
- eine Photosynthese-Komponente
- eine fließende Zellwand / Membran
- klare, lesbare Hex-Grundform
- optionales Debug-Overlay, das die funktionalen Hex-Zellen sichtbar macht

Wichtig:

> Default-Ansicht darf organischer wirken. Debug-Ansicht zeigt die Hex-Wahrheit.

### 9.2 Empfohlene erste Form

Starter-Bakterium v0:

```text
        wall
   wall photo wall
        energy_core
   wall repr  wall
```

Alternativ als kompakter 7-Hex-Cluster:

```text
center: energy_core
ring: photosynthesis, reproduction, wall, wall, wall, wall
```

Die genaue visuelle Positionierung darf im Lab angepasst werden. Die Sim-Wahrheit bleibt: Jede funktionale Komponente sitzt auf einem Hex.

### 9.3 Visuelle Ebenen

| Ebene | Zweck | Autorität? |
|---|---|---|
| Hex-Funktionskörper | echte funktionale Struktur | ja |
| organische Membran | schöne Hülle um Boundary | nein |
| Energieglühen | visuelle Rückmeldung des Energiezentrums | nein |
| Photosynthese-Färbung | Lesbarkeit der Photo-Zelle | nein |
| Debug-Overlay | Koordinaten/Funktionen/Boundary anzeigen | nein |

### 9.4 Architekturregel für Schönheit

Die fließende Zellwand darf animiert sein, aber nur aus abgeleiteten Daten:

```text
OrganismBody -> BodyTopology/Boundary -> VisualSnapshot -> MembraneRenderer
```

Der Renderer darf niemals entscheiden:

- welche Zelle existiert,
- welche Funktion eine Zelle hat,
- wo Wachstum passiert,
- wie viel Energie vorhanden ist.

---

## 10. Genom v0

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

- Werte normalisiert oder klar begrenzt
- Genom beeinflusst Startkörper und später Wachstumsscore
- `mutation_rate_dormant` bleibt inaktiv, bis Mutation per ADR freigegeben ist
- Renderer liest kein Genom direkt

---

## 11. Simulation v0

Tick-Reihenfolge ab Energie-/Growth-Slices:

1. Topologie dirty aktualisieren oder ableiten.
2. Photosyntheseenergie berechnen.
3. Maintenance-Kosten abziehen.
4. Wachstumsladung aktualisieren.
5. Maximal konfigurierte Wachstumsevents ausführen.
6. Invarianten prüfen.
7. Snapshot für Rendering/Debug aktualisieren.

Growth-Regel später:

- Wachstum fügt neue Zellen an freie Nachbarpositionen an.
- Kandidaten kommen aus Frontier-Hexes.
- Score nutzt Genom, Zelltyp-Balance, Kompaktheit, Boundary/Surface und deterministischen RNG.
- Wachstum bleibt connected.
- Wachstum ist pro Tick begrenzt.

---

## 12. Config und Inspector

Alle wichtigen Tuningwerte werden über Resources und `@export` / `@export_range` inspector-editierbar.

Geplante Config-Resources:

- `SimulationConfig`
- `HexGridConfig`
- `CellFunctionDef`
- `CellFunctionCatalog`
- `GenomeConfig`
- `GrowthConfig`
- `RenderConfig`
- `VisualStyleConfig`
- `LabConfig`

### 12.1 VisualStyleConfig

Neu wichtig wegen Starter-Bakterium:

```text
membrane_color
membrane_outline_width
membrane_flow_strength
membrane_flow_speed
energy_core_color
energy_core_glow_strength
photosynthesis_color
photosynthesis_pulse_strength
hex_debug_alpha
show_hex_grid
show_organic_membrane
```

Regel:

- UI darf Runtime-Kopien verändern.
- UI darf `.tres`-Assets nicht versehentlich mutieren.
- Ein Validator prüft Config-Mutation, sobald UI-Interaktion existiert.

---

## 13. Asset-Strategie

### 13.1 Grundregel

Assets sollen Baktorium effektiver, schöner und umsetzbarer machen, aber nicht die Architektur bestimmen.

```text
Kein Asset darf Sim-Wahrheit erzeugen.
Asset-Aufnahme nur per ADR.
Asset-Version im README dokumentieren.
Asset in addons/ committen, nicht nur lose aus der Asset Library ziehen.
```

### 13.2 Frühe Entscheidungen

#### Antialiased Line2D – früh empfohlen

Status:

```text
empfohlen für den ersten visuellen Starter-Bakterium-Slice
```

Nutzen:

- saubere Zellwand-/Membranlinien
- schönere Hex-Outlines
- AntialiasedPolygon2D / AntialiasedRegularPolygon2D für hexagonale Formen
- gute Grundlage für visuelle Qualität, ohne Shader-Paket

Warum früh?

Die erste Nutzerprüfung ist visuell: „Gefällt mir das?“  
Wenn die Zellwand direkt treppig und hart wirkt, wird die Designbewertung verzerrt. Antialiasing ist hier kein Luxus, sondern Teil der visuellen Lesbarkeit.

Regel:

- Integration nur im Rendering-Layer.
- Fallback: eigener `_draw()`-Renderer bleibt möglich.
- Keine Sim-Abhängigkeit vom Addon.

#### Debug Menu – früh vormerken, aber nicht Slice 0 erzwingen

Status:

```text
empfohlen ab erstem echten Lab-/Performance-Moment
```

Nutzen:

- FPS
- Frametime
- CPU/GPU-Zeit
- Hardware-/Softwareinfos

Warum nicht sofort?

Für ein einzelnes Starter-Bakterium ist es nicht blockierend. Sobald Renderer, Energie oder Wachstum laufen, lohnt es sich.

#### GUT – nicht Foundation

Status:

```text
später optional
```

Start bleibt eigener schlanker Test-Runner. GUT wird erst geprüft, wenn Testumfang und Komfortbedarf steigen.

#### MultiMeshInstance2D – nicht Foundation

Status:

```text
späterer Scale-Pfad
```

Start ist `_draw()`/Antialiased-Renderer. MultiMesh erst, wenn viele Zellen/Organismen sichtbar werden und Messungen es begründen.

#### TileMapLayer – nicht für Organismus-v0

Status:

```text
später für Welt/Substrat prüfen
```

Nicht für den dynamischen OrganismBody-v0.

#### Phantom Camera – nicht Foundation

Status:

```text
später für Kamera-UX
```

Erst relevant bei größeren Welten oder beweglichen Organismen.

### 13.3 Built-ins, die sofort genutzt werden

- Godot `Resource` für Configs
- `@export` / `@export_range` für Inspector-Tuning
- `Node2D._draw()` als Render-Fallback und Baseline
- `Polygon2D` / `Line2D` / CanvasItem-Materialien für einfache visuelle Prototypen
- Godot Profiler/Monitors für erste Messung

---

## 14. Validierung

Frühe headless Checks:

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

Visuelle Lab-Checks:

- Starter-Bakterium wird angezeigt.
- Energiezentrum ist klar erkennbar.
- Photosynthese-Zelle ist klar erkennbar.
- Zellwand wirkt organisch/fließend genug für erste Bewertung.
- Debug-Overlay kann Hex-Wahrheit anzeigen.
- Umschalten zwischen organischer Ansicht und Debug-Hex-Ansicht funktioniert.

Teststrategie:

- eigener schlanker Godot-Test-Runner in Slice 0
- `tools/validate_hex_foundation.gd` als schneller Validator
- GUT erst später evaluieren

---

## 15. Performance-Leitlinie

Von Anfang an:

- keine Node pro funktionaler Zelle
- Dictionary/Set-Zugriff nach Hex-Key
- fixed simulation tick später
- Rendering liest Snapshots
- Debug-Overlay abschaltbar
- keine Full-Scans pro Frame, wenn Dirty-/Event-Pfad reicht
- Contiguity bei Änderung validieren, nicht blind jedes Frame

Renderpfad:

```text
_draw() / Antialiased visual layer
-> Dirty-Set / Chunk-Renderer
-> MultiMesh2D oder TileMapLayer-Spike bei echtem Skalierungsdruck
```

Erste Gates:

| Phase | Gate |
|---|---|
| Slice 1 | Starter-Bakterium flüssig und klar lesbar |
| Slice 2 | Hex-/Body-Validierung für 25–100 Zellen stabil |
| Slice 3 | Energie-Bilanz ohne NaN/Infinity |
| Slice 4 | Wachstum bis 250 Zellen flüssig |

---

## 16. Roadmap nach Nutzerpräzisierung

### Slice 0 – Projektvertrag und Fundament

Ziel:

- Agentenvertrag
- kanonische Doku
- Ordnerstruktur
- Config-Resource-Skelette
- eigener Test-Runner-/Validator-Skeleton
- minimale Lab-Szene
- Asset-Policy + ADRs

Nicht enthalten:

- echte Hex-Math
- Energie
- Wachstum
- Genomverhalten
- Population
- vollwertiger Renderer

Acceptance:

- Projekt öffnet.
- Lab-Szene lädt.
- Doku widerspricht sich nicht.
- `NEXT_STEPS.md` definiert Slice 1.
- Headless-Test-/Validator-Skeleton läuft.
- ADR für frühe Asset-Strategie ist angelegt.

### Slice 1 – Starter-Bakterium Visual Foundation

Ziel:

- ein erstes sichtbares Starter-Bakterium im Lab
- Hex-Kern minimal genug für feste Form
- `energy_core`, `photosynthesis`, `reproduction`, `wall` als Daten-Tags
- organische/fließende Membran als Projektion
- Debug-Hex-Overlay
- `VisualStyleConfig` im Inspector
- Antialiased Line2D prüfen/einbinden, falls gewählt

Wichtig:

Dieser Slice darf visuell sein, aber bleibt sim-arm:

- keine Energie-Ticks
- kein Wachstum
- keine Population
- keine Mutation

Acceptance:

- Starter-Bakterium ist sichtbar.
- Energiezentrum ist klar erkennbar.
- Photosynthese-Komponente ist klar erkennbar.
- Membran/Zellwand wirkt nicht nur hart-technisch, sondern leicht organisch/fließend.
- Debug-Overlay zeigt funktionale Hex-Struktur.
- Renderer erzeugt keine Sim-Entscheidungen.
- UI/Inspector kann visuelle Parameter tweaken.

### Slice 2 – Hex-Topologie und Body-Validierung

Ziel:

- vollständige HexCoord-Logik
- Nachbarn
- Distanz
- Boundary
- Connectedness
- BodyValidator
- Seed-/Preset-basierter Startkörper

Acceptance:

- Tests für Nachbarn, Distanz, bekannte Formen, Boundary und Connectedness.
- Startkörper bleibt connected.
- Keine duplicate Koordinaten.
- Pflichtfunktionen existieren.

### Slice 3 – Energie v0

Ziel:

- Photosynthese erzeugt Energie im Organismuspool.
- Maintenance-Kosten werden abgezogen.
- Energiebilanz ist sichtbar und deterministisch.

Acceptance:

- Energie-Tick deterministisch.
- Inspector-Config wirkt.
- keine lokale Energiephysik.
- kein Wachstum.
- keine NaN-/Infinity-Werte.

### Slice 4 – Wachstum v0

Ziel:

- `reproduction` erzeugt Growth Charge.
- neue Zellen entstehen an Frontier-Hexes.
- Energie wird verbraucht.

Acceptance:

- Wachstum bleibt connected.
- Wachstum pro Tick begrenzt.
- deterministisch bei Seed.
- Debug nennt Wachstumsentscheidung.
- Wachstum bis 250 Zellen flüssig.

### Slice 5 – Genom-Expression v0

Ziel:

- Genom beeinflusst Startkörper oder Wachstumsscore.
- Seed-Reihen erzeugen unterscheidbare, valide Organismen.

Acceptance:

- Genomwerte inspector-/debug-lesbar.
- Renderer liest abgeleitete Snapshot-/Palette-Daten.
- keine Mutation/Vererbung.

---

## 17. Agentenworkflow

### 17.1 Startprotokoll

Vor nicht-trivialer Codeänderung:

1. `git status --short --branch` prüfen.
2. `AGENTS.md` und relevante kanonische Docs lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad nennen.
5. Bei Architekturzweifel zuerst `docs/DECISIONS.md` oder Planartefakt aktualisieren.

### 17.2 Abschlussprotokoll

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

### 17.3 Review-Fokus

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
- Visual Layer sauber von Sim Layer getrennt?
- Asset nur in erlaubter Schicht eingebunden?

---

## 18. Erster Codex-Auftrag

```text
Bitte setze ausschließlich Slice 0 für Baktorium um.

Quelle:
- BAKTORIUM_FUNDAMENT_v1_1.md ist verbindlicher Planungsanker.

Ziel:
- AGENTS.md und README.md anlegen.
- docs/ARCHITEKTUR.md, SIM_RULES.md, DECISIONS.md, STATUS.md,
  NEXT_STEPS.md, FINDINGS.md und BAKTORIUM_FUNDAMENT_v1_1.md anlegen.
- Die beschlossene Ordnerstruktur vorbereiten.
- Config-Resource-Skelette vorbereiten, inklusive VisualStyleConfig.
- Einen minimalen Headless-Test-Runner oder Validator-Skeleton anlegen.
- Eine minimale Lab-Startszene anlegen, die noch keine echte Simulation enthält.
- Asset-Policy in DECISIONS.md dokumentieren.
- In NEXT_STEPS.md Slice 1 als Starter-Bakterium Visual Foundation definieren.

Nicht-Ziele:
- keine vollständige Hex-Math-Implementierung
- keine Energie
- kein Wachstum
- kein Genomverhalten
- keine Population
- kein finaler Renderer
- keine externen Addons ohne ADR
- keine alten Baktorio-Inhalte übernehmen
- keine Autoloads ohne ADR

Validierung:
- Projekt öffnet in Godot.
- Lab-Szene lädt.
- Test-/Validator-Skeleton läuft headless.
- Doku ist widerspruchsfrei.
- NEXT_STEPS.md beschreibt Slice 1 mit visuellem Starter-Bakterium.

Abschluss:
- geänderte Dateien
- Validierung
- offene Risiken
- Doku-Sync
- Commit-Vorschlag
```

---

## 19. Zweiter Codex-Auftrag nach Slice 0

```text
Bitte setze Slice 1 um: Starter-Bakterium Visual Foundation.

Ziel:
- Ein erstes sichtbares Starter-Bakterium im Lab darstellen.
- Funktionale Struktur: energy_core, photosynthesis, reproduction, wall.
- Visuelle Struktur: Zellkern/Energiezentrum, Photosynthese-Komponente,
  fließende/organische Zellwand, optionales Hex-Debug-Overlay.
- VisualStyleConfig im Inspector nutzbar machen.
- Antialiased Line2D per ADR prüfen/einbinden oder bewusst ablehnen.

Nicht-Ziele:
- keine echte Energie-Simulation
- kein Wachstum
- keine Mutation
- keine Population
- keine Kampf-/Sensorik-/Verdauungslogik

Validierung:
- Starter-Bakterium ist sichtbar und lesbar.
- Debug-Overlay zeigt Hex-Wahrheit.
- Renderer trifft keine Sim-Entscheidungen.
- UI mutiert keine gespeicherten .tres-Assets.
- Abschluss mit Commit-Vorschlag.
```

---

## 20. Finaler Merksatz

> Baktorium soll früh sichtbar werden, aber nicht früh chaotisch werden.  
> Die Schönheit ist erlaubt – solange sie auf einer klaren Wahrheit tanzt.

