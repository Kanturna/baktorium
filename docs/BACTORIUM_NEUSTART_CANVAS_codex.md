# Bactorium Neustart Canvas

Status: Planungsphase / Arbeitsfassung  
Datum: 2026-05-02  
Workspace: `D:\Projekte\Godot\baktorium`  
Quellen: `D:\Projekte\Godot\baktorio.zip`, `D:\Projekte\Godot\Graviton.zip`, `D:\Projekte\Godot\Calibration_Orchestrator.zip`

Dieses Dokument ist kein finaler Bauplan. Es ist ein bewusst offenes Canvas,
das Codex, Claude Code und ChatGPT als gemeinsamen Kontext fuer die
dialogische Kalibrierung nutzen koennen.

## 1. Ausgangspunkt

Der Neustart soll bewusst einfacher starten als der verworfene Vectorio-/
Baktorio-Anlauf:

- Darstellung zuerst funktional und lesbar, nicht hochwertig.
- Keine zu fruehe echte Zellphysik, Fluidphysik, Softbody-Logik oder lokale
  Mikrosimulation.
- Die Basis soll simpel genug sein, dass emergentes Verhalten aus wenigen
  klaren Regeln wachsen kann.
- Die Architektur soll trotzdem von Anfang an langfristig tragfaehig sein:
  kleine Dateien, klare Schichten, keine Simulationswahrheit in Szenen,
  UI oder Renderer.

Neuer inhaltlicher Kern:

- Zellen sind Hexagons.
- Ein Bakterium ist ein zusammenhaengender Koerper aus aneinanderliegenden
  Hex-Zellen.
- Zellen schweben nicht mit Abstand nebeneinander; Topologie und spaetere
  Kollisionen beruhen auf echter Hex-Nachbarschaft.
- Start nur mit grundlegenden Zellfunktionen: Photosynthese, Energiekern,
  Vermehrung/Zellteilung und Zellwand.
- Noch keine Bewegung, Sensorik, Verdauung, Kampf, Dornen, Augen oder
  komplexe Organellen.

## 2. Projektuebergreifende Erkenntnisse aus den drei Archiven

### 2.1 Baktorio: nuetzliche Teile mitnehmen

Wertvoll:

- Der Arbeitsvertrag in `AGENTS.md` ist sehr passend: vor Codeaenderungen
  Status pruefen, Doku lesen, betroffene Schicht benennen, Risiken und
  Validierungspfad klaeren.
- Die zentrale Pipeline war sauber gedacht:
  `Genome -> BodyBlueprint -> RuntimeState -> Renderer`.
- Der wichtigste Leitsatz bleibt gueltig:
  Daten sind Wahrheit, Nodes sind Projektion.
- Config-Resources mit `@export` / `@export_range` sind ein guter Weg, damit
  Simulationsparameter im Godot Inspector einstellbar bleiben.
- Die headless Validierung `tools/validate_body_pipeline.gd` ist ein starkes
  Vorbild: deterministische Seeds, Pflichtbestandteile, Topologie und
  Config-Mutation pruefen.
- Die Commit-Vorschlag-Pflicht gehoert wieder in `AGENTS.md`.

Nicht ungeprueft uebernehmen:

- Das alte Hull-and-Fluid-Koerpermodell passt nicht mehr zum neuen Ziel,
  weil der neue Koerper wirklich aus diskreten Hex-Zellen bestehen soll.
- Die alte Render- und Organik-Ausrichtung war schon wieder relativ stark
  visuell getrieben. Fuer den Neustart soll Rendering nur Lesbarkeit liefern.
- `BodyZone` / `BodyInteriorFluid` sind konzeptuell eher Altlasten fuer
  diesen Neustart. Die bessere neue Wahrheit ist eine Hex-Zellkarte.

### 2.2 Graviton: Architekturdisziplin mitnehmen

Wertvoll:

- Graviton ist das staerkste Beispiel fuer Autoritaetsgrenzen:
  Simulationszustand ist Wahrheit, View-/Tool-/Szenencode ist abgeleitet.
- Die Schichtung `core -> sim -> runtime -> scenes/tools` ist uebertragbar.
- Die Autoritaetstabelle aus `ARCHITEKTUR.md` ist ein sehr gutes Muster:
  fuer jedes Thema wird festgelegt, wer schreiben darf und was niemals
  autoritativ ist.
- Autoloads werden konservativ behandelt. Nur echte globale Wahrheit darf
  Autoload sein; alles andere wird in der Szene als Composition Root
  verdrahtet.
- Derived-/Snapshot-Caches sind ein gutes Muster fuer Render- und Debugdaten:
  sie lesen Simulationswahrheit, erzeugen aber keine neue Wahrheit.
- Tests und Performance-Diagnostik sind frueh Teil des Systems, aber Diagnose
  bleibt ausserhalb der Simulationsschicht.

Nicht ungeprueft uebernehmen:

- Graviton ist gross und reif. Fuer Bactorial darf die Architektur klar sein,
  aber nicht so viele Services vorwegnehmen, bevor sie gebraucht werden.
- Grosse Acceptance-Bundles und lange Statushistorien sind erst sinnvoll,
  wenn das Projekt entsprechend gewachsen ist.

### 2.3 Calibration Orchestrator: Prozess und Qualitaetsmodell mitnehmen

Wertvoll:

- "So gross wie moeglich, so klein wie noetig" ist die richtige Slice-Regel:
  zusammenhaengende Aenderungen buendeln, aber trennen, sobald Reviewbarkeit,
  Testbarkeit oder Architekturgrenzen leiden.
- Architekturfragen werden zuerst als Planartefakt in `docs/` geklaert, nicht
  heimlich im Code entschieden.
- Ein Plan ist erst brauchbar, wenn Reihenfolge, konkrete Schritte,
  Abhaengigkeiten, Risiken, Validierung und Nicht-Ziele sichtbar sind.
- Claude/ChatGPT sollen nicht nur bestaetigen, sondern aktiv Alternativen,
  Risiken und Deltas liefern.
- Quality-Gates duerfen keine starren Keyword-Listen sein. Sie sollen
  Substanz, Evidenz, Risiken und Validierung sichern.
- Commit, Push und PR bleiben menschliche Entscheidungen. Agenten liefern nur
  Vorschlaege, bis der Nutzer explizit freigibt.

Nicht ungeprueft uebernehmen:

- Die Orchestrator-Doku ist fuer ein Meta-Tool sinnvoll, waere fuer ein
  frisches Godot-Projekt aber zu schwer. Bactorial braucht ein schlankes,
  kanonisches Doku-Set.

## 3. Vorgeschlagener Agentenvertrag

Dieser Abschnitt ist ein Entwurf fuer eine spaetere `AGENTS.md`.

Vor jeder nicht-trivialen Codeaenderung:

1. `git status --short --branch` pruefen.
2. `AGENTS.md` und die betroffenen kanonischen Docs lesen.
3. Betroffene Schicht benennen.
4. Ziel, Annahmen, Risiken und Validierungspfad kurz nennen.
5. Bei Architekturzweifeln zuerst `docs/DECISIONS.md` oder ein Planartefakt
   aktualisieren.

Grundregeln:

- Daten und Simulationszustand sind Wahrheit.
- Renderer, UI, Debug und Szenen sind Projektion.
- Keine Simulationslogik in `rendering/`, `ui/`, `debug/` oder `scenes/`.
- Keine Manager-Gottklasse.
- Kleine Dateien mit klarer Verantwortung.
- Neue Zellfunktionen, Genome-Regeln, Sim-Systeme oder Schichtgrenzen
  brauchen einen Eintrag in `docs/DECISIONS.md`, wenn sie die Architektur
  erweitern.
- Keine breiten Rewrites ohne Planartefakt.
- Slices so gross wie moeglich und so klein wie noetig schneiden.

Abschluss nach Codeaenderung:

- `git status --short`
- geaenderte Dateien
- Tests / Validierung
- Doku-Sync oder Begruendung, warum keine Doku-Aenderung noetig war
- offene Risiken
- Commit-Vorschlag mit Titel und Beschreibung

Commit-Vorschlag-Format:

```text
Commit-Vorschlag:
type(scope): kurzer imperativer titel

Beschreibung:
- wichtigste Aenderung
- Validierung
- Doku-Folge oder bewusste Nicht-Doku
- Risiken / Follow-up, falls relevant
```

Erlaubte Typen:

```text
feat, fix, perf, refactor, docs, test, chore, arch
```

## 4. Schlankes Doku-System fuer den Neustart

Empfohlenes kanonisches Set:

- `AGENTS.md`  
  Arbeitsvertrag fuer Codex, Claude Code und ChatGPT.

- `README.md`  
  Kurzbeschreibung, Start, Tests, wichtigste Docs.

- `docs/BACTORIAL_NEUSTART_CANVAS.md`  
  Dieses offene Planungs-Canvas.

- `docs/ARCHITEKTUR.md`  
  Normative Schichten, Dependency-Richtung, Autoritaeten, Autoload-Regeln.

- `docs/SIM_RULES.md`  
  Kanonische Simulationsregeln: Hex-Koordinaten, Zellfunktionen, Energie,
  Wachstum, Genom, Tick-Reihenfolge, Nicht-Ziele.

- `docs/DECISIONS.md`  
  ADRs. Nur echte Richtungsentscheidungen, keine Tagesnotizen.

- `docs/STATUS.md`  
  Aktueller Stand: implementiert, validiert, sichtbar, offen.

- `docs/NEXT_STEPS.md`  
  Genau der naechste Arbeitsblock, Gate, Nicht anfangen.

- `docs/FINDINGS.md`  
  Bugs, Debug-Befunde, offene Review-Findings und geplante Korrekturen.

Bewusst nicht am Anfang:

- Kein grosses `HANDOFF.md`, solange `STATUS.md` und `NEXT_STEPS.md`
  reichen.
- Kein langes historisches `AI_KONTEXT.md`, solange die kanonischen Docs
  kompakt bleiben.
- Keine Probe-Archive, solange keine echten Kalibrierungslaeufe dokumentiert
  werden muessen.

Regel:

- Codeaenderungen, die Verhalten, Architektur oder naechste Arbeit veraendern,
  aktualisieren mindestens `STATUS.md` oder `NEXT_STEPS.md`.
- Architekturentscheidungen gehen nach `DECISIONS.md`.
- Sim-Regeln gehen nach `SIM_RULES.md`.
- Bugs und Debug-Befunde gehen nach `FINDINGS.md`.

## 5. Simulationsvision

Bactorial ist eine Godot-4-Simulation zellulaerer Bakterienkoerper auf
Hex-Basis.

Ein Bakterium:

- besitzt ein Genom,
- besitzt einen zusammenhaengenden Hex-Zellkoerper,
- hat einen Laufzeitzustand wie Energie, Alter, Stress und Wachstumsladung,
- kann ueber Vermehrungs-/Zellteilungskomponenten neue Zellkoerper gewinnen,
- wird in den ersten Slices nicht bewegt, nicht gesteuert und nicht kaempfen.

Eine Zelle:

- liegt auf genau einer axialen Hex-Koordinate,
- hat genau eine primaere Funktion in v1,
- kann Nachbarn ueber die sechs Hex-Richtungen haben,
- ist Teil genau eines Organismus,
- erzeugt keine eigene Godot-Node-Wahrheit.

Erste grundlegende Zellfunktionen:

- `energy_core`  
  Pflichtzelle. Zentrum fuer Energieverteilung und spaetere Koordination.

- `photosynthesis`  
  Erzeugt Energie, vorzugsweise wenn sie an der Oberflaeche liegt.

- `reproduction`  
  Baut Wachstumsladung auf und ermoeglicht neue Zellkoerper.

- `wall`  
  Schuetzt, bildet spaeter Kollisions- und Schadensgrenze. In v1 nur
  Topologie-/Materialfunktion, kein HP-System.

Offene Kandidatin:

- `cytoplasm` oder `body`  
  Eine neutrale interne Fuell-/Verbindungszelle koennte nuetzlich sein, wenn
  die vier Grundfunktionen sonst zu semantisch ueberladen werden. Diese Zelle
  sollte nicht automatisch in Slice 1 eingefuehrt werden; erst entscheiden,
  wenn das Startkoerpermodell sie wirklich braucht.

Spaetere erweiternde Zellfunktionen:

- `thorn` / `spike`
- `eye`
- `motor`
- `mouth`
- `digestive`
- `storage`
- `sensor`
- weitere spezialisierte Wand- oder Organellenzellen

Diese bleiben Nicht-Ziele bis Wachstum und Energie stabil sind.

## 6. Hex-Grundmodell

Empfehlung:

- Simulationskoordinaten als axial coordinates `HexCoord(q, r)`.
- Cube-Koordinaten nur fuer Distanz/Algorithmen ableiten, nicht als zweite
  gespeicherte Wahrheit.
- Renderer entscheidet ueber Pointy-Top oder Flat-Top. Die Sim darf sich nicht
  auf Pixelorientierung verlassen.
- Jede Zelle nimmt exakt einen Hex ein.
- Nachbarschaft ist ausschliesslich eine der sechs axialen Richtungen.
- Der Koerper eines Organismus muss jederzeit connected sein.
- Boundary/Oberflaeche ist abgeleitet:
  eine Zelle ist Boundary, wenn mindestens ein Nachbarplatz leer ist.

Axial-Nachbarn:

```text
(+1,  0)
(+1, -1)
( 0, -1)
(-1,  0)
(-1, +1)
( 0, +1)
```

Renderer-Formel als Projektion, nicht als Sim-Wahrheit:

```text
pointy top:
x = hex_size * sqrt(3) * (q + r / 2)
y = hex_size * 1.5 * r
```

Wichtige Invariante:

```text
Zelle A beruehrt Zelle B genau dann, wenn B in A.neighbors liegt.
```

Das ist spaeter die Grundlage fuer Kollision, Schaden, Verdauung,
Kontaktlogik und Kampf.

## 7. Wahrheiten und Autoritaeten

Vorgeschlagene Autoritaetstabelle:

| Thema | Autoritative Quelle | Schreibrecht |
|---|---|---|
| Simulationszeit | `SimulationClock` oder `SimulationService` | nur Sim-Orchestrator |
| Hex-Geometrie | `HexCoord` / `HexGridMath` | pure Funktionen |
| Zellkoerper | `OrganismBody` | `GrowthSystem`, spaeter Damage/Reproduction-Systeme |
| Zellen | `CellBlock` Daten | autorisierte Sim-Systeme |
| Genom | `Genome` | Factory / spaeter MutationSystem |
| Energie | `OrganismState.energy` | `EnergySystem` |
| Wachstumsladung | `OrganismState.growth_charge` | `GrowthSystem` |
| Weltbelegung | `WorldState` | `SimulationService` / World-Systeme |
| Renderdaten | `DerivedRenderSnapshot` | read-only aus Simdaten abgeleitet |
| UI-Eingaben | `LabConfig` / UI Controls | duerfen nur Konfig/Testinput setzen |

Niemals autoritativ:

- `Node2D.position`
- `Polygon2D` oder Render-Vertices
- Debug-Overlay
- UI-Labels
- Editor-Szenenwerte, die nur Darstellung betreffen
- Screenshots

## 8. Genommodell v1

Der Nutzer spricht von einem "Genomswert". Fuer Architektur und spaetere
Evolution ist ein kleines Genom-Resource-Modell besser als ein einzelner
Float. Trotzdem kann es nach aussen als kompakter Genome-Seed oder
Genome-Signatur lesbar bleiben.

Vorgeschlagene v1-Gene, alle normalisiert `0.0..1.0`:

- `growth_rate`
- `photosynthesis_bias`
- `wall_bias`
- `reproduction_bias`
- `core_stability`
- `compactness`
- `branching`
- `symmetry_bias`
- `surface_preference`
- `energy_efficiency`
- `mutation_rate` als ruhendes Feld, noch ohne aktive Mutation

Genomeinfluss in v1:

- bestimmt die Gewichtung, welche Zellfunktion bei Wachstum bevorzugt wird,
- bestimmt, ob Wachstum kompakter oder verzweigter ausfaellt,
- bestimmt, ob neue Photosynthesezellen eher an Oberflaechen entstehen,
- beeinflusst Energieeffizienz und Wachstumskosten,
- erzeugt deterministische Varianten aus Seeds.

Nicht in v1:

- echte Vererbung,
- Populationsevolution,
- komplexe Mutationspfade,
- neuronale oder regelbasierte Steuerung,
- direkte Render-Entscheidungen aus dem Genom.

Pipeline:

```text
Genome -> GenomeExpression -> GrowthWeights -> Body/Growth decisions
```

Renderer liest nicht das Genom direkt.

## 9. Erste Simulationsregeln

Tick-Reihenfolge v1:

1. Topologie aus Zellkarte ableiten: Boundary, Nachbarzahlen,
   freie Frontier-Hexe.
2. Energie produzieren:
   Photosynthesezellen erzeugen Energie, Surface-Exposure kann den Wert
   beeinflussen.
3. Energieverbrauch abziehen:
   jede Zelle hat Maintenance-Kosten, Zelltypen koennen unterschiedlich teuer
   sein.
4. Wachstumsladung aktualisieren:
   Reproduction-Zellen wandeln Energieueberschuss in `growth_charge`.
5. Wachstum ausfuehren:
   wenn genug Ladung vorhanden ist, wird maximal eine konfigurierte Anzahl
   neuer Zellen an freien Nachbar-Hexen erzeugt.
6. Invarianten pruefen:
   Koerper bleibt connected, keine doppelten Koordinaten, Pflichtzellen
   bleiben vorhanden, Werte bleiben endlich und im erlaubten Bereich.

Energie v1:

- globaler Organismus-Energiepool.
- keine lokale Diffusion.
- keine Leitungsnetze.
- keine Zell-zu-Zell-Ressourcenfluesse.

Begruendung:

- Globalenergie ist grob, aber sie macht die ersten emergenten Wachstumstests
  ueberschaubar.
- Lokale Energiefluesse waeren spannend, aber sie wuerden den Neustart wieder
  zu frueh in echte Zellphysik ziehen.

Wachstum v1:

- Wachstum fuegt neue Zellen an vorhandene Nachbarplaetze an.
- Kandidaten werden aus Frontier-Hexen berechnet.
- Scoring beruecksichtigt Genom, Oberflaeche, Kompaktheit,
  Nachbarzahl und aktuelle Zelltyp-Balance.
- Wachstum darf keine isolierten Zellen erzeugen.
- Wachstum darf pro Tick begrenzt werden, damit Performance und Debugbarkeit
  stabil bleiben.

## 10. Vorgeschlagene Godot-Architektur

Empfohlene Struktur:

```text
AGENTS.md
README.md
project.godot

docs/
  BACTORIAL_NEUSTART_CANVAS.md
  ARCHITEKTUR.md
  SIM_RULES.md
  DECISIONS.md
  STATUS.md
  NEXT_STEPS.md
  FINDINGS.md

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

tools/
  validate_hex_foundation.gd
```

Dependency-Richtung:

```text
ui/debug/scenes -> rendering -> runtime -> sim -> body -> genetics -> config/core
```

Config-Resources duerfen von mehreren Schichten gelesen werden, speichern aber
keine Laufzeitwahrheit.

Szenenregel:

- `scenes/lab/simulation_lab.tscn` ist Composition Root und Verdrahtung.
- Szenen duerfen Services instanziieren und konfigurieren.
- Szenen duerfen keine Zellentscheidungen, Energieentscheidungen oder
  Genomlogik enthalten.

Renderer-Regel:

- `HexOrganismRenderer` liest Snapshots oder Body/State-Daten.
- Er erzeugt keine Zellen.
- Er entscheidet nicht, welche Zellfunktion eine neue Zelle bekommt.
- Er darf Debug-Layer zeichnen, aber Debug ist keine Wahrheit.

## 11. Config- und Inspector-Strategie

Moeglichst viele Tuningwerte sollen als Godot Resources ueber den Inspector
editierbar sein.

Empfohlene Resources:

- `SimulationConfig`
  - fixed dt / tick rate
  - start paused
  - max ticks per frame
  - max growth events per tick
  - deterministic seed

- `HexGridConfig`
  - hex size
  - orientation fuer Rendering
  - spacing, default exakt 1.0 ohne Luecken
  - debug coordinate labels

- `CellFunctionDef`
  - function id
  - label
  - base color
  - energy production
  - maintenance cost
  - growth cost
  - requires surface
  - protection value

- `CellFunctionCatalog`
  - Array aller erlaubten Zellfunktionen
  - Pflichtfunktionen
  - v1/v2 Feature-Gates

- `GenomeConfig`
  - GeneSchemas
  - min/max/default
  - clamp rules

- `GrowthConfig`
  - growth charge threshold
  - compactness weight
  - branching weight
  - surface weight
  - required function balance
  - reproduction influence

- `RenderConfig`
  - colors
  - outline width
  - selected/debug alpha
  - show debug overlay
  - draw coordinates
  - draw organism bounds

- `LabConfig`
  - review seed start/count
  - initial body preset
  - auto tick speed
  - reset mode

Wichtige Regel:

- UI darf Config-Kopien fuer Experimente veraendern.
- UI darf nicht versehentlich `.tres`-Assets zur Laufzeit mutieren.
- Headless-Tests sollen pruefen, dass Config-Assets nach UI-Interaktion
  unveraendert bleiben.

## 12. Godot-Addons und Assets

Aus den vorhandenen Projekten sind folgende Kandidaten bekannt:

- `AntialiasedLine2D` / antialiased drawing  
  Nuetzlich fuer spaetere glatte Umrisse und Debuglinien. Nicht kritisch fuer
  Slice 1.

- `DebugMenu`  
  Nuetzlich fuer FPS, Frametime, Memory und Debug-Schalter. Gute fruehe
  Tooling-Ergaenzung, wenn es ohne Architekturkopplung eingebunden wird.

- `GUT` oder eigener Test-Runner  
  Graviton nutzt einen einfachen eigenen Godot-Test-Runner sehr erfolgreich.
  Fuer den Neustart ist ein eigener `src/tests/test_runner.gd` wahrscheinlich
  schlanker. GUT kann spaeter sinnvoll sein, wenn Testkomfort wichtiger wird.

- `shaderV` oder Shader-Assets  
  Erst spaeter. Nicht fuer Foundation verwenden, sonst wird der Neustart
  wieder zu rendergetrieben.

- `PhantomCamera`  
  Fuer dieses 2D-Lab zunaechst nicht noetig.

Regel:

- Addons duerfen Darstellung, Debugging oder Bedienung verbessern.
- Addons duerfen keine Simulationswahrheit einfuehren.
- Kein Addon wird aufgenommen, bevor ein konkreter Slice davon profitiert.

## 13. Performance-Leitlinie

Fruehe Performance-Entscheidungen:

- Keine Node pro Zelle als langfristiger Pfad.
- Slice 1 darf klein und simpel rendern, aber die Sim-Datenstruktur muss
  bereits fuer viele Zellen geeignet sein.
- Zellzugriff ueber Dictionary nach axialer Koordinate oder stabilem Key.
- Topologie dirty/inkrementell vorbereiten, sobald Wachstum groesser wird.
- Simulation in festen Ticks, Rendering interpoliert/liest nur.
- Wachstum pro Tick begrenzen.
- Snapshot/Derived-Daten fuer Rendering und Debug, damit Renderer keine
  Hotpath-Berechnungen anstoesst.

Renderpfad:

- v1: ein `Node2D` zeichnet Hex-Polygone in `_draw()` aus einem Snapshot.
- v2: chunked draw oder `MultiMeshInstance2D`, falls viele Zellen/Organismen
  sichtbar werden.
- Debug-Overlays abschaltbar und getrennt messen.

Mess-Gates:

- Foundation: 1 Organismus mit 50, 100, 250 Zellen.
- Frueher Scale-Test: 10 Organismen mit je 100 Zellen.
- Spaeter: 100 Organismen oder grosse Welt erst nach eigenem Performance-Slice.

## 14. Validierung

Headless-Validierung fuer erste Slices:

- gleicher Seed erzeugt gleichen Startkoerper,
- 20 bis 30 Seeds erzeugen unterscheidbare Koerperformen,
- jeder Koerper ist connected,
- keine zwei Zellen teilen dieselbe Hex-Koordinate,
- jede Zelle hat eine bekannte Funktion,
- Pflichtfunktionen existieren,
- Boundary-Erkennung stimmt fuer bekannte Testformen,
- Energie bleibt endlich und in definierten Grenzen,
- Wachstum erzeugt keine isolierten Zellen,
- Renderer liest keine Genome direkt,
- UI veraendert keine gespeicherten Config-Resources versehentlich.

Manuelle Lab-Validierung:

- Seed-Reihe durchklicken.
- Debug-Overlay fuer Koordinaten, Boundary und Zellfunktionen pruefen.
- Tick/Pause/Reset testen.
- Materiallesbarkeit pruefen.
- Beobachten, ob Wachstum lesbar und nachvollziehbar bleibt.

Spaetere Performance-Validierung:

- Headless Tick-Benchmark.
- Editor-Playtest mit DebugMenu/PerfProbe.
- Renderkosten mit Debug-Overlay an/aus vergleichen.

## 15. Vorgeschlagene erste Slices

### Slice 0: Repo- und Doku-Fundament

Ziel:

- `AGENTS.md`, kanonische Docs, Verzeichnisstruktur, Test-Runner-Skelett,
  Config-Resources.

Acceptance:

- Agentenvertrag steht.
- `docs/ARCHITEKTUR.md`, `docs/SIM_RULES.md`, `docs/STATUS.md`,
  `docs/NEXT_STEPS.md`, `docs/DECISIONS.md`, `docs/FINDINGS.md` existieren.
- Test-Runner laeuft headless, auch wenn noch wenige Tests existieren.

Nicht anfangen:

- Wachstum,
- komplexes Rendering,
- Population,
- Evolution.

### Slice 1: Hex-Kern und Topologie

Ziel:

- `HexCoord`, Nachbarn, Distanz, axialer Key, connectedness,
  Boundary-Erkennung.

Acceptance:

- Tests fuer Nachbarn, Distanz, bekannte Formen, Boundary und connectedness.
- Keine Godot-Node-Abhaengigkeit im Hex-Kern.

### Slice 2: Genom und Startkoerper

Ziel:

- deterministische GenomeFactory,
- einfache Startkoerper-Factory,
- Pflichtzellen: Core, Photosynthesis, Reproduction, Wall.

Acceptance:

- gleicher Seed erzeugt gleiche Zellen,
- Varianten ueber Seedreihe,
- Koerper connected,
- Pflichtfunktionen vorhanden.

### Slice 3: Lab-Rendering und Inspector

Ziel:

- Simulation Lab Szene,
- Hex-Renderer,
- Seed-Navigation,
- Inspector fuer Genom, Zellzahlen, Energieplatzhalter und Topologie.

Acceptance:

- 20 bis 30 Seeds schnell visuell pruefbar,
- keine Sim-Entscheidung im Renderer,
- Config-Resources im Inspector editierbar.

### Slice 4: Energie v1

Ziel:

- Photosynthese produziert Energie,
- Zellen verbrauchen Maintenance,
- Organismus zeigt Energie, Stress und einfache Bilanz.

Acceptance:

- Energie laeuft deterministisch,
- keine negativen/NaN-Werte,
- Headless-Test fuer einfache Koerper und bekannte Bilanz.

### Slice 5: Wachstum v1

Ziel:

- Reproduction-Zellen sammeln Wachstumsladung,
- neue Zellen entstehen an Frontier-Hexen,
- Genom beeinflusst Zelltyp und Position.

Acceptance:

- Wachstum bleibt connected,
- Wachstum ist pro Tick begrenzt,
- Seed-Verhalten deterministisch,
- Debug zeigt Grund fuer Wachstumsentscheidung.

Erst danach neu entscheiden:

- mehrere Organismen,
- echte Zellteilung in Tochterorganismen,
- Mutation,
- Bewegung,
- Kampf,
- Sensorik,
- Verdauung.

## 16. Offene Designfragen fuer die Kalibrierung

1. Startet Slice 1 mit genau einem Organismus oder bereits mit mehreren
   unabhaengigen Organismen im selben WorldState?

   Empfehlung: genau ein Organismus im Lab, weil Wachstum und Topologie zuerst
   stabil werden muessen.

2. Soll `wall` zwingend jede Boundary-Zelle sein?

   Empfehlung: nein fuer v1. Boundary ist eine abgeleitete Topologie, `wall`
   ist eine Zellfunktion. Spaeter kann eine Regel entstehen, dass ungeschuetzte
   Boundary riskant ist.

3. Braucht es eine neutrale `cytoplasm`/`body`-Zelle?

   Empfehlung: offen halten. Einfuehren, wenn Startkoerper oder Wachstum sonst
   unnatuerlich wird.

4. Ist Energie global oder lokal?

   Empfehlung: global in v1. Lokale Diffusion erst nach stabilem Wachstum.

5. Ist Zellteilung zuerst Wachstum am selben Koerper oder echte Reproduktion
   in einen Tochterorganismus?

   Empfehlung: zuerst Wachstum am selben Koerper. Echte Tochterorganismen sind
   ein spaeterer eigener Slice.

6. Soll das Genom ein einzelner Wert oder ein Vektor sein?

   Empfehlung: intern Vektor/Dictionary, extern als Seed/Signatur lesbar.

7. Soll Rendering schon organisch aussehen?

   Empfehlung: nein. Erst klare Hex-Zellen, Farben, Outline, Debug.

## 17. Nicht-Ziele fuer die Foundation

Nicht anfangen, bevor Energie + Wachstum v1 validiert sind:

- Bewegung,
- Augen/Sensoren,
- Dornen/Kampf,
- Verdauung/Mund,
- lokale Schadenswerte,
- Kollision,
- Fluide,
- Softbody,
- Populationsevolution,
- Mutation und Vererbung,
- komplexe Shader,
- hochwertige Grafik,
- prozedurale Animationen,
- UI-Polish ausserhalb des Labs.

## 18. Auftrag an Codex / Claude / ChatGPT fuer die naechste Kalibrierung

Nutzt dieses Canvas als Ausgangspunkt und prueft kritisch:

- Ist die vorgeschlagene Schichtung fuer eine Godot-Hex-Zellsimulation
  langfristig tragfaehig?
- Ist der erste Scope klein genug, ohne wieder zu komplex zu starten?
- Fehlt ein zentrales Datenmodell, das spaeter schwer nachzuruesten waere?
- Sind die Doku-Dateien zu viel, zu wenig oder richtig geschnitten?
- Welche der offenen Designfragen muss vor Slice 0 entschieden werden?
- Welche Risiken entstehen durch globale Energie, einfache Growth-Weights oder
  Boundary als abgeleitete Topologie?
- Sollte `WorldState` von Anfang an existieren, auch wenn Slice 1 nur einen
  Organismus zeigt?
- Soll der Test-Runner wie in Graviton direkt selbst gebaut werden oder ist
  GUT frueh sinnvoll?
- Welche Godot-Addons aus den alten Projekten sind fuer Slice 0/1 wirklich
  wertvoll?

Erwartetes Ergebnis:

- konkrete Deltas zum Plan,
- priorisierte Risiken,
- klare Empfehlungen fuer Slice 0 bis 2,
- keine Implementierung, solange die Kalibrierung noch offen ist.
