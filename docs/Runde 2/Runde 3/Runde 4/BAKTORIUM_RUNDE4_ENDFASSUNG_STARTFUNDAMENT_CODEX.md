# Baktorium - Runde 4: Endfassung Startfundament

Stand: 2026-05-02  
Ziel: verbindlicher, aber weiter kalibrierbarer Planungsanker fuer den ersten echten Projektstart.

Hinweis zur Eingabe: Der lokal genannte Ordner `docs/Runde 3` war nicht vorhanden. Vorgefunden wurden die drei Runde-3-Plaene in `docs/Runde 2/Runde 3`:

- `BAKTORIUM_ENDFASSUNG_FUNDAMENT_CODEX.md`
- `BAKTORIUM_ENDFASSUNG_FUNDAMENT_GPT.md`
- `BAKTORIUM_ENDFASSUNG_FUNDAMENT_CLAUDE.md`

Diese Runde-4-Fassung konsolidiert diese drei Plaene und beruecksichtigt die neue Priorisierung: Der erste Schritt soll nicht nur abstrakte Architektur vorbereiten, sondern direkt ein visuell pruefbares Starter-Bakterium liefern.

---

## 1. Runde-4-Kernentscheidung

Die bisherige Konsenslinie war:

1. erst Doku, Repo-Disziplin und Tests,
2. dann Hex-Math,
3. dann Body,
4. dann Renderer.

Das war sauber, aber fuer diesen Neustart zu abstrakt. Der Nutzer will am Anfang sehen, ob die Grundidee visuell traegt: eine einfache Zell-/Bakterienform mit Zellkern, Energiezentrum, fliessender Zellwand und Photosynthesezelle.

Runde 4 entscheidet deshalb:

**Der erste Umsetzungsblock ist ein Startfundament mit sichtbarem Starter-Bakterium.**

Das bedeutet nicht, dass Grafik wichtiger als Architektur wird. Es bedeutet:

- Die Architektur muss frueh genug stehen, damit das erste sichtbare Objekt kein Wegwerf-Prototyp wird.
- Der erste sichtbare Zustand ist klein, aber ernst gemeint.
- Simulation, Rendering und Konfiguration werden von Anfang an getrennt.
- Die erste sichtbare Zelle darf animiert und schoen sein, aber sie darf keine versteckte Simulationswahrheit im Renderer erzeugen.

Kurzform:

> Erstes Ziel ist nicht "alles simulieren", sondern "ein sauber gebautes, sichtbares Startwesen, an dem wir Aussehen, Datenmodell und Arbeitsweise pruefen".

---

## 2. Was in Runde 4 verbindlich wird

### 2.1 Projektprinzip

Baktorium ist eine deterministische Hex-Zell-Simulation. Ein Bakterium ist technisch ein zusammenhaengender Verbund aus Hex-Zellen. Fuer den ersten visuellen Eindruck darf dieser Verbund aber wie ein einzelliger Organismus wirken.

Eine Hex-Zelle ist Daten. Godot-Nodes, Renderer, Inspector, Debug-Overlays und Szenen sind Projektion.

### 2.2 Erster sichtbarer Inhalt

Das erste sichtbare Simulationsspiel-Objekt ist:

**Starter-Bakterium v0**

Es ist ein kleiner zusammenhaengender Hex-Verbund, der visuell wie eine einzelne biologische Zelle gelesen werden soll.

Minimalbestandteile:

- ein zentraler `energy_core`, der visuell Zellkern und Energiezentrum traegt,
- eine oder mehrere `photosynthesis`-Zellen an der Oberflaeche,
- eine umschliessende, sichtbare `wall`-Boundary,
- fliessende Zellwand-Darstellung als Render-Effekt,
- keine Bewegung,
- kein Sehen,
- kein Kampf,
- kein Wachstum,
- keine Fortpflanzung im ersten sichtbaren Zustand.

Wichtig: Der Nutzer sagt "eine Zelle". Architektonisch bleibt die Wahrheit trotzdem: Das sichtbare Startwesen ist ein Bakterium aus Hex-Zellen, aber so klein und geschlossen, dass es wie ein einzelliger Koerper wirkt. Dadurch bleiben die spaeteren Regeln fuer Zell-an-Zell-Kontakt, Boundary, Wachstum und Kollision kompatibel.

### 2.3 Erste Shape-Entscheidung

Default fuer das erste Lab:

- axiale Hex-Koordinaten `(q, r)` fuer Sim-Daten,
- `pointy-top` als erste Render-Orientierung,
- Orientierung nur in `RenderConfig`/Renderer, nicht in Sim-Logik,
- lokale Organismus-Koordinaten relativ zum Organismus-Ursprung,
- kein globales `WorldGrid` im ersten Schritt.

Ein moeglicher Starter-Body fuer v0:

```text
       wall
  wall photo wall
    wall core wall
       photo
```

Die konkrete Form darf im ersten Lab per Konfiguration angepasst werden. Wichtig ist nur:

- alle Hexes sind direkt verbunden,
- keine doppelten Koordinaten,
- `energy_core` ist vorhanden,
- mindestens eine `photosynthesis`-Zelle liegt an der Oberflaeche,
- `wall` bildet eine lesbare Grenze.

---

## 3. Was der erste Schritt leisten muss

Der erste Schritt soll drei Dinge gleichzeitig klaeren:

1. **Arbeitsweise:** Wie arbeiten Codex, Claude, ChatGPT und Nutzer mit Doku, Next Steps, Findings und Commit-Vorschlaegen?
2. **Architektur:** Wo liegt welche Verantwortung, damit wir spaeter nicht alles umbauen muessen?
3. **Visueller Eindruck:** Gefaellt das Grundbild eines Hex-Bakteriums mit Zellkern, Energiezentrum, fliessender Wand und Photosynthesezelle?

Dieser erste Schritt darf deshalb groesser sein als ein reiner Mikro-Slice. Er muss aber intern klar trennbar bleiben.

### 3.1 Nicht-Ziele im ersten Schritt

Nicht bauen:

- echte Energieproduktion oder Energieverbrauch,
- Wachstum,
- Zellteilung,
- Genom-Mutation,
- mehrere Organismen,
- Weltkarte/Substrat/Lichtkarte,
- Kollision/Kampf,
- KI/Verhalten,
- Physik,
- Pathfinding,
- Node pro Zelle,
- globale Autoload-Pflicht.

Erlaubt ist:

- visuelle Energie-Aura im Kern,
- visuelles Wandfliessen,
- Konfigurationswerte fuer spaetere Energie/Growth-Slices als Platzhalter,
- kleine interne Validierer, die Datenmodell und Body pruefen.

---

## 4. Architektur fuer das Startfundament

### 4.1 Zentrale Trennung

Von Anfang an gibt es drei Ebenen:

**Sim-Daten**

- Hex-Koordinaten,
- Zellfunktion,
- Body-Zusammenhang,
- spaeter Energie, Genom, Wachstum.

**Render-Snapshot**

- flache, unveraenderliche Sicht auf Sim-Daten,
- abgeleitete Boundary,
- Farben/Marker nur als Darstellung,
- keine Sim-Entscheidungen.

**Godot-Szene**

- Lab,
- Camera,
- Inspector-Parameter,
- Debug-Overlay,
- Renderer-Node.

Der Renderer darf lesen, aber keine Zellfunktionen, Energie oder Koordinaten als Wahrheit erzeugen.

### 4.2 Vorgeschlagene Modulstruktur

Diese Struktur ist der Zielrahmen fuer den ersten Implementierungsblock. Namen duerfen beim Umsetzen leicht angepasst werden, wenn Godot-Konventionen oder vorhandene Projektstruktur das nahelegen.

```text
res://
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
        hex_coord.gd
        hex_grid_math.gd
        hex_grid_config.gd

    sim/
      body/
        cell_block.gd
        organism_body.gd
        starter_bacterium_factory.gd
        organism_validator.gd

      catalog/
        cell_function_def.gd
        cell_function_catalog.gd

    rendering/
      hex_render_config.gd
      organism_render_snapshot.gd
      hex_organism_renderer.gd
      wall_flow_renderer.gd

    lab/
      starter_bacterium_lab.gd

  resources/
    cell_functions/
      energy_core.tres
      photosynthesis.tres
      wall.tres
      reproduction.tres

    render/
      starter_bacterium_render_config.tres

  scenes/
    lab/
      starter_bacterium_lab.tscn

  tests/
    headless/
      validate_startfundament.gd
```

### 4.3 Warum diese Struktur jetzt lohnt

Diese Aufteilung kostet im ersten Schritt mehr Arbeit als ein einzelnes Godot-Skript. Sie spart spaeter Umbau, weil folgende Entscheidungen frueh stabil sind:

- Hex-Koordinaten sind nicht vom Renderer abhaengig.
- Zellfunktionen sind `Resource`-Daten und damit Inspector-/Editor-tauglich.
- Ein Organismus ist keine Scene-Node-Hierarchie.
- Boundary wird aus Topologie abgeleitet.
- Visual-Polish kann ausgetauscht werden, ohne Sim-Daten umzuschreiben.
- Debug und Lab bleiben Konsumenten, keine Wahrheit.
- Spaeteres Wachstum kann an dieselbe Body-Struktur anschliessen.

---

## 5. Datenmodell v0

### 5.1 `HexCoord`

Reine Datenklasse oder Resource-freie Value-Struktur:

```text
q: int
r: int
```

Notwendig:

- Key-Erzeugung fuer Dictionary-Zugriff,
- sechs Nachbarn,
- Distanz,
- Ring/Radius optional, falls fuer Starter-Body nuetzlich,
- keine Godot-Node-Abhaengigkeit.

### 5.2 `CellBlock`

Eine Zellinstanz im Organismus:

```text
coord: HexCoord
function_id: StringName
visual_seed: int
```

Nicht enthalten in v0:

- lokale HP,
- lokale Energie,
- lokale AI,
- Physics Body,
- Node-Referenz.

### 5.3 `CellFunctionDef`

Godot-`Resource`, damit Werte im Inspector editierbar bleiben:

```text
id: StringName
display_name: String
base_color: Color
accent_color: Color
maintenance_energy: float
growth_cost: float
visual_weight: float
```

In v0 werden Energie- und Growth-Werte nur vorbereitet, nicht simuliert.

### 5.4 Zellfunktionen im ersten Projektfundament

Kanonische IDs:

| ID | Rolle | Status v0 |
| --- | --- | --- |
| `energy_core` | Zellkern-/Energiezentrum-Anker | sichtbar und Pflicht |
| `photosynthesis` | Oberflaechenzelle fuer spaetere Energieproduktion | sichtbar |
| `wall` | Wand-/Boundary-Zelle | sichtbar |
| `reproduction` | spaeteres Wachstum/Zellteilung | Resource vorbereitet, nicht sichtbar noetig |

Der Nutzer hat im aktuellen Fokus keine Vermehrungszelle fuer den ersten sichtbaren Zustand gefordert. Sie bleibt deshalb als Schema-/Resource-Teil vorbereitet, aber nicht als sichtbarer Pflichtbestandteil von Starter-Bakterium v0.

### 5.5 `OrganismBody`

Lokaler Zellkoerper:

```text
organism_id: int
cells_by_key: Dictionary
origin: Vector2
seed: int
```

Pflichtmethoden:

- `add_cell(coord, function_id)`,
- `has_cell(coord)`,
- `get_cell(coord)`,
- `get_neighbors(coord)`,
- `get_boundary_cells()`,
- `is_connected()`,
- `validate()`.

Das erste Lab erzeugt genau einen Body ueber `StarterBacteriumFactory`.

---

## 6. Rendering v0

### 6.1 Zielbild

Das Starter-Bakterium soll nicht wie eine abstrakte Brettspielmarke wirken. Es soll als organischer, aber noch klar hexagonaler Zellkoerper lesbar sein.

Visuelle Bestandteile:

- Hex-Fuellungen pro Zellfunktion,
- dezente Innenlinien zwischen Zellen,
- staerkerer aeusserer Boundary-Rand,
- animierte Wandlinie oder wandernde Highlights fuer "fliessende Zellwand",
- zentraler Kernpunkt oder Kernmembran im `energy_core`,
- Energiezentrum als pulsierender Akzent im Kernbereich,
- Photosynthesezelle mit gruenem Akzent und leichter innerer Textur/Bewegung.

### 6.2 Render-Grenze

Render-Effekte duerfen enthalten:

- Zeitparameter fuer Animation,
- Sinus/Puls fuer Wandfluss,
- Farbinterpolation,
- leichte Offset-/Noise-Illusion auf Boundary-Linien,
- Auswahl-/Debug-Overlay.

Render-Effekte duerfen nicht enthalten:

- echte Energieproduktion,
- Zellplatzierungslogik,
- Growth-Scoring,
- Zellfunktion-Aenderung,
- Verbindungskorrektur,
- versteckte Body-Mutation.

### 6.3 Rendering-Technik

Start:

- `Node2D._draw()` als Basis,
- `queue_redraw()` nur fuer Animation oder Parameterwechsel,
- `draw_polygon()`/`draw_colored_polygon()` fuer Zellflaechen,
- eigener Boundary-Edge-Ableiter aus Hex-Nachbarn.

Freigegebener frueher Polish:

- Antialiased Line2D/Polygon fuer sauberere Boundary und Wandfluss, sofern Kompatibilitaet und Lizenz passen.

Fallback:

- Wenn das Addon stoert, bleibt der Renderer mit Godot-Built-ins lauffaehig.

---

## 7. Asset-Entscheidungen fuer den Projektstart

Runde 4 korrigiert die vorher sehr konservative Asset-Linie. Da der erste sichtbare Eindruck jetzt ein Hauptziel ist, duerfen bestimmte Assets frueher eingesetzt werden, aber nur als austauschbare Render-/Debug-Werkzeuge.

### 7.1 Sofort verbindlich ohne externes Addon

| Feature | Entscheidung | Grund |
| --- | --- | --- |
| Godot `Resource` | ab Start nutzen | Zellfunktionen und Renderwerte muessen Inspector-tauglich sein |
| `@export` / Inspector | ab Start nutzen | Parameter sollen ohne Codeaenderung kalibrierbar sein |
| `Node2D._draw()` | Start-Renderer | klein, direkt, gut fuer Hex-Polygone |
| axiale Hex-Math | eigene Implementierung | Sim-Wahrheit darf nicht von Asset/API abhaengen |

### 7.2 Frueh freigegebene Addons

| Asset | Runde-4-Entscheidung | Einsatz |
| --- | --- | --- |
| Antialiased Line2D | fuer ersten visuellen Slice freigegeben | Boundary, Zellwandfluss, glatte Hex-Kanten |
| Debug Menu | frueh freigegeben, aber nicht blocker | FPS/Frametime/Hardwaredaten bei Lab-Checks |

**Antialiased Line2D** ist der wichtigste fruehe Kandidat, weil die fliessende Zellwand ein Kernbestandteil des ersten sichtbaren Ziels ist. Wenn das Addon sauber funktioniert, darf es im ersten visuellen Slice installiert werden.

**Debug Menu** ist kein Gameplay-/Render-Asset, aber ein nuetzliches Entwicklungswerkzeug. Es darf frueh aufgenommen werden, solange es strikt read-only bleibt und nicht als Sim-Diagnose-Wahrheit missverstanden wird.

### 7.3 Noch nicht aufnehmen

| Asset / Feature | Entscheidung | Grund |
| --- | --- | --- |
| Hexagon TileMapLayer Addons | nicht im Startfundament | Organismus ist lokaler Body, keine Weltkarte |
| Godot `TileMapLayer` als Body-Renderer | nicht im Startfundament | zu frueh, erschwert individuelle Zellvisuals |
| `MultiMeshInstance2D` | spaeterer Performance-Spike | erst relevant, wenn `_draw()` messbar kippt |
| GUT / GdUnit4 | spaeter evaluieren | eigener kleiner Validator reicht fuer Start |
| PhantomCamera | spaeter | ein statisches Lab braucht keine Kamera-Folgelogik |
| Shader-Packs | nicht im Startfundament | visuelle Identitaet soll nicht vom Pack diktiert werden |
| externe Hex-Grid-Utils | nicht als Wahrheit | Red Blob reicht als Referenz, eigene HexMath wird getestet |

### 7.4 Asset-Aufnahmeregel

Jedes externe Asset braucht vor Aufnahme einen kurzen Eintrag in `docs/DECISIONS.md`:

- Name,
- Quelle/URL,
- Version,
- Lizenz,
- Godot-Version,
- konkreter Slice-Nutzen,
- Fallback, falls Asset bricht,
- bestaetigt: Asset veraendert keine Sim-Wahrheit.

Assets werden lokal in `addons/` committed, nicht stillschweigend aus der Asset Library nachgeladen.

---

## 8. Dokumentationssystem

Das Doku-System soll helfen, nicht bremsen. Keine Doku-Datei soll nur existieren, weil sie "vielleicht irgendwann" nuetzlich ist.

Verbindliches Startset:

| Datei | Zweck |
| --- | --- |
| `AGENTS.md` | Arbeitsregeln fuer Codex/Claude/ChatGPT |
| `README.md` | Projektstart, Godot-Version, Startszene, Setup |
| `docs/ARCHITEKTUR.md` | Struktur, Schichten, Abhaengigkeitsregeln |
| `docs/SIM_RULES.md` | Hex-Regeln, Zellfunktionen, spaetere Tick-Reihenfolge, Nicht-Ziele |
| `docs/DECISIONS.md` | ADR-Log fuer Architektur-/Asset-Entscheidungen |
| `docs/STATUS.md` | realer Stand: implementiert, sichtbar, validiert, offen |
| `docs/NEXT_STEPS.md` | genau naechster Arbeitsblock mit Acceptance-Kriterien |
| `docs/FINDINGS.md` | Bugs, Debug-Befunde, Risiken, geplante Korrekturen |

Keine separate `CLAUDE.md` im Projektstart. Agentenspezifische Hinweise gehoeren in `AGENTS.md`, aber der Projektvertrag bleibt einheitlich.

### 8.1 Pflicht in `AGENTS.md`

`AGENTS.md` soll von Anfang an enthalten:

- Vor jeder Arbeit `AGENTS.md`, `docs/STATUS.md` und `docs/NEXT_STEPS.md` lesen.
- Architektur nicht umgehen, um kurzfristig sichtbare Ergebnisse zu erzwingen.
- Sim-Daten, Rendering, UI und Debug strikt trennen.
- Keine Node-pro-Zelle-Architektur.
- Parameter bevorzugt als `Resource`/`@export`, wenn sie kalibriert werden sollen.
- Slices: so gross wie moeglich, so klein wie noetig.
- Nach jeder Code-Aenderung Commit-Titel und Commit-Beschreibung vorschlagen.
- Abschlussbericht: Ziel, geaenderte Dateien, Validierung, offene Risiken, naechster Schritt.

### 8.2 Commit-Vorschlag-Format

Jede Umsetzung endet mit:

```text
Commit title:
<type>: <kurze handlungsorientierte Beschreibung>

Commit description:
- Was wurde geaendert?
- Warum?
- Wie wurde validiert?
- Welche Risiken/Naechsten Schritte bleiben?
```

---

## 9. Erster Umsetzungsblock

Name:

**Slice 0/R4 - Startfundament + Starter-Bakterium v0**

Dieser Slice ist bewusst ein zusammenhaengender Foundation-Slice. Er darf intern in vier Checkpoints umgesetzt werden.

### 9.1 Checkpoint A - Arbeitsvertrag und Doku

Liefern:

- `AGENTS.md`,
- `README.md`,
- `docs/ARCHITEKTUR.md`,
- `docs/SIM_RULES.md`,
- `docs/DECISIONS.md`,
- `docs/STATUS.md`,
- `docs/NEXT_STEPS.md`,
- `docs/FINDINGS.md`.

Acceptance:

- Doku beschreibt den aktuellen ersten Slice, nicht eine ferne Vision.
- Asset-Entscheidungen sind dokumentiert.
- `NEXT_STEPS.md` nennt den naechsten konkreten Arbeitsblock.
- `STATUS.md` trennt implementiert, geplant und offen.

### 9.2 Checkpoint B - Hex- und Body-Kern

Liefern:

- `HexCoord`,
- `HexGridMath`,
- `CellBlock`,
- `CellFunctionDef`,
- `CellFunctionCatalog`,
- `OrganismBody`,
- `StarterBacteriumFactory`,
- `OrganismValidator`.

Acceptance:

- sechs Nachbarn stimmen,
- keine duplicate Hex-Koordinaten,
- Starter-Body ist verbunden,
- `energy_core` ist vorhanden,
- mindestens eine `photosynthesis`-Zelle existiert,
- Boundary kann abgeleitet werden.

### 9.3 Checkpoint C - Lab und Renderer

Liefern:

- `starter_bacterium_lab.tscn`,
- `starter_bacterium_lab.gd`,
- `HexOrganismRenderer`,
- `HexRenderConfig`,
- `OrganismRenderSnapshot`,
- optional `WallFlowRenderer`.

Acceptance:

- Godot startet in eine Lab-Szene.
- Ein Starter-Bakterium ist sichtbar.
- Zellkern/Energiezentrum ist im Zentrum erkennbar.
- Photosynthesezelle ist visuell unterscheidbar.
- Zellwand/Boundary wirkt fliessend.
- Parameter fuer Farben, Hex-Groesse, Wandstaerke, Puls-/Flow-Geschwindigkeit sind im Inspector oder als Resource editierbar.
- Renderer kann Debug-Overlay ein/aus schalten.

### 9.4 Checkpoint D - Validierung und Abschluss

Liefern:

- kleiner headless Validator oder Test-Skript,
- dokumentierter manueller Lab-Check,
- aktualisierte `STATUS.md`,
- aktualisierte `NEXT_STEPS.md`,
- Commit-Vorschlag.

Acceptance:

- Validator meldet OK fuer Starter-Body.
- Keine Sim-Logik liegt im Renderer.
- Keine Node-pro-Zelle-Struktur wurde eingefuehrt.
- Addons, falls installiert, sind in `DECISIONS.md` mit Version und Fallback dokumentiert.

---

## 10. Qualitaetsgates fuer den ersten Schritt

### 10.1 Architektur-Gate

Der Slice ist nicht fertig, wenn:

- der Renderer Zellfunktionen entscheidet,
- die Lab-Szene Koordinaten-Wahrheit erzeugt,
- Zellen als einzelne Nodes modelliert sind,
- Hex-Orientierung in Sim-Math eingebrannt ist,
- Config-Werte nur als Magic Numbers im Renderer stecken,
- ein Asset Sim-Daten schreibt.

### 10.2 Visuelles Gate

Der Slice ist nicht fertig, wenn:

- das Startwesen nur wie ein abstraktes Raster aussieht,
- Zellkern/Energiezentrum nicht als Schwerpunkt lesbar ist,
- Photosynthese nicht erkennbar ist,
- die Wand nicht als aeussere Membran wirkt,
- fliessende Wand nur durch zufaelliges Flackern entsteht,
- UI/Text das Sichtfeld stoert.

### 10.3 Performance-Gate

Fuer Starter v0 reicht:

- 1 Organismus,
- ca. 7 bis 19 Hex-Zellen,
- fluessige Animation im Lab,
- keine spuerbaren Editor-Hitches beim Parameterwechsel.

Trotzdem muss die Struktur fuer 25 bis 100 Zellen plausibel bleiben, damit der naechste Body-/Visual-Ausbau nicht sofort eine Renderer-Neuschreibung erzwingt.

---

## 11. Naechste Slices nach dem Startfundament

Diese Reihenfolge ist absichtlich schlank. Nach Starter-Bakterium v0 wird neu bewertet, ob das visuelle Grundgefuehl stimmt.

### Slice 1 - Visual Calibration v1

Ziel:

- Aussehen des Starter-Bakteriums verbessern,
- Zellwandfluss feinjustieren,
- Farben und Groessen kalibrieren,
- eventuell Antialiased Line2D final integrieren, falls nicht schon passiert.

Nicht:

- Wachstum,
- Energieproduktion,
- Genom.

### Slice 2 - Energie v0

Ziel:

- globale Organismus-Energie,
- Photosynthese produziert Energie,
- Zellunterhalt verbraucht Energie,
- `energy_core` speichert/repraesentiert Organismus-Energie.

### Slice 3 - Wachstum v0

Ziel:

- freie Frontier-Hexes finden,
- neue Zellen an bestehende Zellen anbauen,
- Reproduction-Resource aktivieren,
- Wachstum noch ohne echte Tochterorganismen.

### Slice 4 - Genom-Expression v0

Ziel:

- Genomwerte beeinflussen Zelltyp-Gewichtung,
- deterministischer Seed,
- erste Variation zwischen Organismen.

### Slice 5+ - Welt, mehrere Organismen, Bewegung, Konflikt

Erst hier werden relevant:

- globales `WorldGrid`,
- Occupancy,
- Kollision,
- mehrere Organismen,
- Verdauung,
- Dornen,
- Augen,
- Bewegung,
- Kampf.

---

## 12. Konkreter Auftrag fuer Codex nach Runde 4

Der folgende Auftrag kann direkt als Startprompt fuer die Umsetzung verwendet werden:

```text
Bitte setze fuer Baktorium den Slice "R4 Startfundament + Starter-Bakterium v0" um.

Vor Beginn:
- Lies AGENTS.md, falls vorhanden.
- Lies docs/STATUS.md und docs/NEXT_STEPS.md, falls vorhanden.
- Falls diese Dateien fehlen, erstelle sie nach dem Runde-4-Plan.

Ziel:
- Ein Godot-Projektfundament mit sauberer Doku, Hex-Datenmodell, kleinem Starter-Bakterium und Lab-Szene.
- Das Starter-Bakterium soll als kleiner zusammenhaengender Hex-Verbund sichtbar sein und wie eine einfache biologische Zelle wirken.
- Sichtbar sein muessen: Zellkern/Energiezentrum, fliessende Zellwand, Photosynthesezelle.

Architekturregeln:
- Eine Zelle ist Daten, kein Node.
- Ein Bakterium ist ein lokaler zusammenhaengender Hex-Verbund.
- Renderer/UI/Debug lesen Snapshots und mutieren keine Sim-Daten.
- Parameter fuer Farben, Groessen und Animationen als Resource/@export vorbereiten.
- Keine echte Energie, kein Wachstum, kein Genom, keine Weltkarte in diesem Slice.

Assets:
- Godot Resources, @export und Node2D._draw() von Anfang an nutzen.
- Antialiased Line2D darf fuer Zellwand/Boundary integriert werden, wenn Kompatibilitaet/Lizenz geprueft und DECISIONS.md aktualisiert wird.
- Debug Menu darf frueh integriert werden, ist aber nicht blocker.
- Keine TileMapLayer-/MultiMesh-/GUT-/PhantomCamera-Integration in diesem Slice.

Validierung:
- Headless Validator fuer Hex-Nachbarn, connected Starter-Body, bekannte Zellfunktionen.
- Manueller Godot-Lab-Check fuer Sichtbarkeit und Animation.
- STATUS.md und NEXT_STEPS.md aktualisieren.

Abschluss:
- Liste geaenderter Dateien.
- Validierungsergebnis.
- Offene Risiken.
- Commit title und Commit description vorschlagen.
```

---

## 13. Quellen und technische Referenzen

- Godot Resources: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
- Godot GDScript Exports / Inspector: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html
- Godot Custom Drawing in 2D: https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html
- Godot MultiMeshInstance2D: https://docs.godotengine.org/en/stable/classes/class_multimeshinstance2d.html
- Godot TileMapLayer: https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
- Red Blob Games Hexagonal Grids: https://www.redblobgames.com/grids/hexagons/
- Debug Menu Asset: https://godotengine.org/asset-library/asset/1902
- Antialiased Line2D Asset: https://godotengine.org/asset-library/asset/3103

---

## 14. Runde-4-Zusammenfassung

Die wichtigste Korrektur gegenueber Runde 3:

**Der erste echte Schritt wird nicht nur Doku-Slice, sondern ein sichtbares, architektonisch sauberes Starter-Bakterium.**

Das Startfundament soll jetzt schon entscheiden:

- Hex-Sim bleibt Datenmodell, nicht Scene-Hierarchie.
- Startkoerper ist ein lokaler, verbundener Hex-Body.
- Der erste visuelle Organismus ist klein, aber kein Wegwerfcode.
- `energy_core`, `photosynthesis` und `wall` sind die sichtbaren Startfunktionen.
- `reproduction` wird vorbereitet, aber nicht sichtbar erzwungen.
- Antialiased Line2D ist fuer fruehen Visual-Polish freigegeben.
- Debug Menu ist frueh erlaubt, aber kein blocker.
- Weltkarte, Wachstum, Energie und Genom kommen erst nach der visuellen Grundkalibrierung.

Wenn Starter-Bakterium v0 visuell nicht ueberzeugt, wird zuerst Visual Calibration v1 gemacht. Erst wenn das Grundbild passt, lohnt sich Energie- und Wachstumssimulation.
