# Slice 2 Polish Iter A: Visual Truth Layer (v4)

> **Status:** Plan-Artefakt zur Gegenprüfung durch Codex.
> Geschrieben von Claude (Opus 4.7), nach Codex-Review von v3
> alle 7 P1-Punkte korrigiert.
>
> **Datum:** 2026-05-02
> **Slice-Bezug:** Innerhalb Slice 2 (Energy v0). Kein neuer Sim-Slice.
> Polish-Iteration auf der Render-Schicht.
>
> **Versions-Historie:**
> - v1: vor Sichtung der Sprites
> - v2: nach erstem PNG-Inventar mit Outer/Inner-Wall-Trennung
> - v3: nach Animations-Spritesheets für Photo + Core
> - **v4: aktuell, nach Codex-Review von v3 — ADR-Nummern korrigiert,
>   Hotkey G statt D, Camera-Adapter gestrichen, Sprite-Skalierung
>   spezifiziert, Performance-Gate getrennt, WorldEnvironment-
>   Single-Instance-Guard, Asset-Manifest präziser**

---

## 0. Summary

Slice 2 ist sim-architektonisch abgeschlossen. Diese Iteration
hebt den Beauty-Mode auf hochwertiges Niveau, ohne Sim-Architektur
zu berühren.

Mittel:
- Custom-Sprites pro Cell-Function (vom Nutzer bereitgestellt)
- Outer/Inner-Wall-Trennung für lückenlose Membran-Optik
- Animierte Sprites für Energy Core und Photosynthesis
- WorldEnvironment-Glow (Godot 4 built-in, Single-Instance-Guard)
- Kenney Particle Pack (bereits vendored)
- Beauty/Debug-Mode-Switch über Hotkey **G** (erweitert bestehende
  Debug-Overlay-Toggle-Logik)

**Was diese Iter NICHT anfasst:**
- Camera-Architektur (ADR-009 bereits entschieden: Built-In
  Camera2D, kein Adapter)
- Sim-Code, Body, Energy-System, SimulationService
- Snapshot-Determinismus
- Hotkeys WASD/Arrow/C/Wheel (Camera-Slice-Eigentum)

---

## 1. Render-Dogma: Simulation Truth vs. Visual Truth

(Unverändert.) Verankert als **ADR-010** (siehe Sektion 7,
Nummer-Korrektur ggü. v3).

- **Simulation Truth (autoritativ):** `HexCoord`, `function_id`,
  `OrganismBody`, `OrganismState`, `OrganismEnergyState`, Boundary,
  Frontier. Schreibrecht über `SimulationService`.
- **Visual Truth (abgeleitet):** Sprites, Animationen, Glow,
  Particles, Tints. Renderer interpretiert Hex-Form organisch.
  Beauty-Mode darf Hex-Wahrheit teilweise kaschieren. Debug-Mode
  zeigt harte Hex-Polygone.

Visual Truth darf nie neue Sim-Fakten erzeugen. Sim-Systeme lesen
keine Visual-Felder.

---

## 2. PNG-Inventar (vom Nutzer bereitgestellt)

**Aktuelles Repo-Manifest** (vor A1-Asset-Move):

### Statische Sprites in `png/` (Root)

| Datei | Funktion | Variante | Status |
|-------|----------|----------|--------|
| `png/energy_core 2.png` | energy_core | 2 (Organisch) | nicht gewählt → `_alternates/` |
| `png/energy_core 3.png` | energy_core | 3 (Hybrid) | nicht gewählt → `_alternates/` |
| `png/photosynthesis.png` | photosynthesis | 1 (Frame klar) | nicht gewählt → `_alternates/` |
| `png/photosynthesis 2.png` | photosynthesis | 2 (Organisch) | nicht gewählt → `_alternates/` |
| `png/reproduction.png` | reproduction | 1 (Frame klassisch) | **Stil-Auswahl offen** |
| `png/reproduction 2.png` | reproduction | 2 (weicher) | **Stil-Auswahl offen** |
| `png/reproduction 3.png` | reproduction | 3 (Hex-Pattern) | **Stil-Auswahl offen** |
| `png/inner_wall_membrane.png` | wall (Innen) | 1 (hellblau) | **Stil-Auswahl offen** |
| `png/inner_wall_membrane 2.png` | wall (Innen) | 2 (intensiver Glow) | **Stil-Auswahl offen** |
| `png/outer_wall_membrane.png` | wall (Außen) | 1 (Frame mit Knoten) | gewählt |

### Sprites + Animations-Spritesheets in Unterordnern

| Pfad | Funktion | Inhalt |
|------|----------|--------|
| `png/energy_core/energy_core.png` | energy_core | Single-Frame, Variante 1 (gewählt) |
| `png/energy_core/energy_core frames 10.png` | energy_core | Spritesheet 2×5, 10 Frames |
| `png/photosynthesis 3/photosynthesis 3.png` | photosynthesis | Single-Frame, Variante 3 (gewählt) |
| `png/photosynthesis 3/photosynthesis 3 frames 10.png` | photosynthesis | Spritesheet 2×5, 10 Frames |

### Stil-Auswahl (final für diese Iter)

- **Energy Core:** Variante 1, animiert
- **Photosynthesis:** Variante 3, animiert
- **Reproduction:** Stil-Auswahl offen (siehe 11.1), statisch in Iter A
- **Wall Outer:** einzige Variante, statisch
- **Wall Inner:** Stil-Auswahl offen (siehe 11.1), statisch

**A1 erste Aktion:** Codex verifiziert dieses Manifest gegen den
echten `png/`-Inhalt vor dem Move. Bei Diskrepanz Stop und
Nutzer-Klärung.

---

## 3. Key Changes

### 3.1 Asset-Layout

```
assets/
  textures/
    cell_functions/
      energy_core.png                  # Single-Frame (Fallback)
      energy_core_frames.png           # Spritesheet 2x5, 10 Frames
      photosynthesis.png               # Single-Frame
      photosynthesis_frames.png        # Spritesheet 2x5, 10 Frames
      reproduction.png                 # gewählte Variante
      wall_outer.png                   # outer_wall_membrane.png
      wall_inner.png                   # gewählte Inner-Variante
      _alternates/
        [nicht-gewählte Stil-Varianten]
```

`png/` und alle Unterordner werden **erst nach erfolgreichem
A1-Move + Test-Sign-off** gelöscht (Codex-Empfehlung 11.5).

### 3.2 SpriteFrames-Resources

```
resources/
  cell_functions/
    energy_core_frames.tres       # SpriteFrames mit 10 AtlasTexture-Regions
    photosynthesis_frames.tres    # SpriteFrames mit 10 AtlasTexture-Regions
```

Codex misst beim Import die echte Frame-Größe aus dem Spritesheet
(Sheet-Pixel-Breite/5 × Sheet-Pixel-Höhe/2). Atlas-Regions in
Lese-Reihenfolge: Reihe 1 links→rechts, dann Reihe 2 links→rechts.

### 3.3 `CellFunctionDef` Schema-Erweiterung

```gdscript
@export var outer_sprite_texture: Texture2D = null
@export var inner_sprite_texture: Texture2D = null
@export var sprite_frames: SpriteFrames = null
@export_range(1.0, 24.0, 0.5) var animation_base_fps: float = 8.0
@export_range(0.0, 1.0, 0.05) var animation_modulation_strength: float = 0.5
```

ADR-006 wird aktualisiert mit der expliziten Aussage:
*"Sim-Systeme (Body, EnergySystem, GrowthSystem etc.) lesen diese
Visual-Felder nicht. Sie sind ausschließlich von Runtime-Snapshot
und Renderer konsumierbar."*

Aktive Belegung pro Funktion:

| Funktion | outer | inner | sprite_frames | base_fps | mod_strength |
|----------|-------|-------|---------------|----------|--------------|
| `energy_core` | `energy_core.png` | null | `energy_core_frames.tres` | 8.0 | 0.5 |
| `photosynthesis` | `photosynthesis.png` | null | `photosynthesis_frames.tres` | 8.0 | 0.5 |
| `reproduction` | gewählte Variante | null | null | — | — |
| `wall` | `wall_outer.png` | `wall_inner.png` | null | — | — |

### 3.4 Sprite-Skalierung (NEU, Codex-P1)

`HexRenderConfig` bekommt zwei Felder für Sprite-Größen-Berechnung:

```gdscript
@export_range(1.0, 3.0, 0.05) var sprite_diameter_scale: float = 2.2
@export_range(8, 4096, 8) var sprite_source_size: int = 1024
```

**Berechnungs-Formel im Renderer:**

```
target_diameter = hex_radius * 2.0 * sprite_diameter_scale
sprite_scale = target_diameter / sprite_source_size
```

`sprite_diameter_scale = 2.2` heißt: das Sprite ist 10% breiter als
der Hex-Diameter, sodass der Sprite-Frame mit Eck-Knoten leicht
über die Hex-Geometrie hinausragt — sauberer optischer Übergang
zwischen Zellen.

**Test (A2):** mit `hex_radius = 42` und `sprite_source_size = 1024`
ergibt sich `sprite_scale ≈ 0.090`. Bei `hex_radius = 60` ergibt
sich `sprite_scale ≈ 0.129`.

**Hinweis Mip-Mapping:** Bei `sprite_scale < 0.5` Mipmap-Filter in
`.import` aktivieren.

### 3.5 Renderer-Umbau (`hex_organism_renderer.gd`)

**Architekturentscheidung: Sprite-Nodes als Kinder, kein
`_draw()`-Custom-Drawing für Beauty-Pfad.**

- Pro Cell wird im Beauty-Mode ein Kind-Node erzeugt:
  - Animiert: `AnimatedSprite2D` mit `play("default")` und
    `set_speed_scale(modulated_speed)`
  - Statisch: `Sprite2D` mit `texture` aus
    `outer_sprite_texture` oder `inner_sprite_texture` je
    `is_boundary`
- Sprite-Scale aus Sektion 3.4 Formel
- Snapshot-Update steuert Sprite-Pool: existierende Nodes
  wiederverwenden, überzählige freigeben
- **Debug-Hide-Regel (Codex-P1):** in Debug-Mode werden alle
  Sprite-Kinder per `visible = false` (oder freed) versteckt;
  Polygon-`_draw()` wird sichtbar
- `_draw()` bleibt aktiv, **nur für Debug-Mode** (Polygon-Fallback)

**Animation-Speed-Modulation:**

```gdscript
var modulator = cell_data.get("animation_modulator", 0.5)
var strength = def.animation_modulation_strength
var speed_scale = 1.0 + strength * (modulator - 0.5) * 2.0
animated_sprite.speed_scale = clampf(speed_scale, 0.25, 2.0)
```

Bei `modulator = 0.0`: speed_scale = 0.5 → 4 FPS
Bei `modulator = 0.5`: speed_scale = 1.0 → 8 FPS
Bei `modulator = 1.0`: speed_scale = 1.5 → 12 FPS

**`_draw_accent` wird zu `_apply_sprite_modulation`:**
- `glow_disc` (energy_core): `animation_modulator = energy_tint_strength`
- `surface_dot` (photosynthesis): `animation_modulator = energy_activity`
- `ring_arc` (reproduction): statisch in Iter A
- `none` (wall): keine Modulation

### 3.6 SnapshotBuilder erweitern

`OrganismSnapshotBuilder.build()` hat **bereits** den
`render_hints`-Parameter (Slice-2-P1.1 wurde umgesetzt — Lab:192-193).
Diese Iter erweitert den Snapshot um:

- `outer_sprite_texture`, `inner_sprite_texture`
- `sprite_frames` (Reference)
- `animation_base_fps`, `animation_modulation_strength`
- `animation_modulator` (berechnet aus `accent_kind` + Energy-Daten)

`is_boundary` ist bereits seit Slice 1 im Snapshot.

### 3.7 `HexRenderConfig` Render-Mode-Switch

```gdscript
@export_enum("beauty", "debug") var render_mode: String = "beauty"
```

- `beauty`: Sprites + Animationen + Glow + Particles, keine Texte
- `debug`: harte Polygone, Coords/Function-IDs, kein Glow, keine
  Particles, keine Animationen

Future-Modi dokumentiert: `presentation`, `performance`.

**Hotkey: `G`** (erweitert die bestehende Debug-Overlay-Toggle-
Logik aus Lab:118-121).

Aktuell macht `KEY_G` nur `render_config.show_debug_overlay = !show_debug_overlay`.
Iter-A-Erweiterung: `KEY_G` toggelt jetzt den vollen
`render_mode` zwischen `beauty` und `debug`. Daraus werden die
einzelnen Bools (`show_debug_overlay`, `show_coordinates`,
`show_function_ids`) abgeleitet.

**Nicht angetastet:** WASD/Arrow (Camera-Pan), Mouse-Wheel (Zoom),
C (Camera-Reset), F (Flow-Toggle), N/B/R (Seed-Navigation), F3
(DebugMenu).

### 3.8 Particle-Layer-Architektur

`src/rendering/particle_effect_adapter.gd` mit drei Slot-Methoden:

```gdscript
class_name ParticleEffectAdapter

# Iter A: aktiv
static func setup_world_ambient(parent: Node) -> Node

# Slice 3+: no-op in Iter A
static func setup_organism_aura(parent: Node, organism_id: int) -> Node
static func setup_cell_event(parent: Node, world_pos: Vector2, event_kind: String) -> Node
```

Iter A: dezenter Hintergrund-Drift mit Kenney `circle_05.png`,
`light_02.png`, `spark_01.png`. 30-50 Partikel,
`GPUParticles2D`, langsame Vertikal-Drift.

### 3.9 WorldEnvironment-Adapter mit Single-Instance-Guard (Codex-P1)

`src/rendering/world_environment_adapter.gd`:

```gdscript
class_name WorldEnvironmentAdapter
extends RefCounted

static func ensure_single_instance(parent: Node) -> WorldEnvironment:
    # Sucht in der Szene nach existierendem WorldEnvironment.
    # Wenn vorhanden: das wird wiederverwendet.
    # Wenn nicht: neuer WorldEnvironment-Node mit der Lab-Environment-Resource.
    var existing = parent.get_tree().get_first_node_in_group("world_environment")
    if existing != null:
        return existing
    var env_node = WorldEnvironment.new()
    env_node.add_to_group("world_environment")
    env_node.environment = load("res://resources/render/starter_lab_environment.tres")
    parent.add_child(env_node)
    return env_node

static func set_glow_enabled(env_node: WorldEnvironment, enabled: bool) -> void:
    if env_node == null or env_node.environment == null:
        return
    env_node.environment.glow_enabled = enabled
```

Adapter wird in Lab nach Camera-Setup gerufen, nicht vorher.

### 3.10 Camera bleibt unverändert (Codex-P1: Reject)

Mein Plan v3 hatte einen `lab_camera_adapter.gd`-Slot vorgeschlagen.
**Wird gestrichen.**

Begründung: ADR-009 (`docs/DECISIONS.md:84-96`) hat bewusst
entschieden, dass die Lab-Kamera Built-In `Camera2D` ohne Adapter
oder Plugin nutzt. Ein Adapter-Slot wäre Vorab-Abstraktion ohne
aktuellen Slice-Bedarf und würde die Doktrin verwässern.

Phantom-Camera bleibt als FINDINGS-Eintrag für Slice 5, wenn
Multi-Organism-Following relevant wird.

---

## 4. Subphases

### A1: Asset-Manifest + Move + Stil-Auswahl + Schema + SpriteFrames
**Liefern:**
- **Erste Aktion:** Codex verifiziert das Asset-Manifest aus
  Sektion 2 gegen den echten `png/`-Inhalt. Bei Diskrepanz
  STOP und Nutzer-Klärung.
- Stil-Auswahl pro offene Funktion (Reproduction, Wall Inner)
  durch Nutzer (Sektion 11.1)
- Sprites + Spritesheets in `assets/textures/cell_functions/`
- `SpriteFrames`-Resources mit korrekten Atlas-Regions
- Nicht-gewählte Stil-Varianten in `_alternates/`
- `png/`-Ordner-Bereinigung **nach A4-Sign-off**, nicht in A1
- `CellFunctionDef`-Schema mit fünf neuen Feldern (3.3)
- 4 `.tres` mit aktuellen Werten gefüllt
- Mip-Mapping-Aktivierung in `.import`-Files
- ADR-010 (Visual Truth Dogma)
- ADR-011 (Custom Sprites + Animation + Outer/Inner-Schema)
- ADR-006-Update (accent_kind als Sprite-Modulator inkl. Animations-
  Speed; Sim-Systeme lesen Visual-Felder nicht)
- ADR-004-Update (Asset-Politik)
- Headless-Test: `tests/headless/run_polish_a1_assets_validation.gd`

**Gate (Headless):**
- Manifest-Verifikation: alle erwarteten Quell-Dateien existieren
  in `png/`, alle Ziel-Pfade frei in `assets/`
- Alle Sprites + 2 SpriteFrames-Resources laden ohne Fehler
- SpriteFrames haben jeweils 10 Frames in der "default"-Animation
- Catalog hat alle Schema-Felder korrekt befüllt
- ADR-Texte enthalten Pflicht-Strings inkl. *"Sim-Systeme lesen
  diese Visual-Felder nicht"*
- Source-Search: kein Sim-/Body-/Genetics-/Runtime-Code importiert
  `assets/` oder `addons/kenney_particle_pack/`

**Commit-Vorschlag:** `chore(addons,docs): vendor cell sprites with animations and outer/inner split`

### A2: Renderer-Umbau + Sprite-Skalierung + Hotkey G + Mode-Switch
**Liefern:**
- `HexRenderConfig.render_mode` Enum
- `HexRenderConfig.sprite_diameter_scale`,
  `HexRenderConfig.sprite_source_size`
- Hotkey `G` erweitert zur vollen Mode-Toggle-Logik
- Renderer-Compound: Sprite-Kinder im Beauty-Mode mit Pool/Reuse
- Beauty: AnimatedSprite2D + Sprite2D je nach `sprite_frames`
- Debug: Sprite-Kinder `visible = false`, `_draw()`-Polygone aktiv
- Sprite-Scale-Berechnung aus Sektion 3.4 implementiert
- `_apply_sprite_modulation` ersetzt `_draw_accent`
- Snapshot-Cell-Felder erweitert (siehe 3.6)
- `boundary_glow_enabled: bool = false` als optionaler Konfig-Wert
  (Codex-Empfehlung 11.2)
- Headless-Test: `tests/headless/run_polish_a2_renderer_validation.gd`

**Gate (Headless):**
- Beauty-Mode-Source enthält `AnimatedSprite2D` und `Sprite2D`
  Instanziierung
- Debug-Mode-Source enthält Polygon-Draw-Call (alte Logik)
- `KEY_G` mit Mode-Toggle-Logik im Lab
- **Sprite-Scale-Test:** mit `hex_radius = 42` und
  `sprite_source_size = 1024` ergibt sich `sprite_scale ≈ 0.090`
  (±0.005)
- **Animation-Modulation-Test:** speed_scale-Werte für
  modulator=0/0.5/1.0 ergeben 0.5/1.0/1.5
- **Boundary-Switch-Test:** synthetischer 19-Zellen-Cluster,
  Wall-Innen → `wall_inner.png`, Wall-Außen → `wall_outer.png`
- Mode-Switch-Test: Snapshots in beiden Modi haben **identische
  Sim-Daten**
- Snapshot-Determinismus bleibt grün
- Slice 1+2 Regression alle grün

**Commit-Vorschlag:** `feat(rendering): animated sprite-based beauty mode with G mode toggle`

### A3: WorldEnvironment + Particles
**Liefern:**
- `resources/render/starter_lab_environment.tres` mit Glow-Konfig
- `world_environment_adapter.gd` mit Single-Instance-Guard
- `particle_effect_adapter.gd` mit drei Slot-Methoden
- Hintergrund-Drift im Lab via Kenney-Particles
- Beauty/Debug-Mode steuert Glow + Particles an/aus
- **Camera-Adapter wird NICHT geliefert** (Codex-P1 reject)
- Headless-Test: `tests/headless/run_polish_a3_environment_validation.gd`
- Manuell-Stress-Test (siehe 5.2)

**Gate (Headless):**
- WorldEnvironment-Resource lädt
- `ensure_single_instance()` Test: zweimal aufrufen → exakt ein
  WorldEnvironment-Node in der Szene
- `set_glow_enabled(node, true/false)` schaltet `glow_enabled` korrekt
- Particle-Adapter hat alle drei Slot-Methoden
- Future-Slots sind no-op aber rufbar (Test ruft sie auf)

**Gate (Manueller Profiler-Test, Codex-P1):**
- Lab im Beauty-Mode mit dem 7-Zellen-Bakterium öffnen
- Godot-Profiler ruft Frametime-Statistik
- 60 FPS gehalten über 10 Sekunden Beobachtung
- Durchschnitts-Frametime < 16.6 ms
- Per-Frame-Spikes < 33.3 ms (kein Stutter)
- Zusatz: künstlicher 100-Zellen-Body-Lab-Hack (Test-Hotkey oder
  Inspector-Override) → Performance-Sign-off

**Commit-Vorschlag:** `feat(rendering): worldenvironment glow and ambient particles`

### A4: Doku + ADR-Konsolidierung + FINDINGS + png/-Cleanup
**Liefern:**
- `docs/ARCHITEKTUR.md` "Visual Truth Contract"-Sektion
- `docs/STATUS.md` aktualisiert
- `docs/NEXT_STEPS.md` mit Iter-A-Lab-Sign-off-Punkten
- `docs/FINDINGS.md` mit Iter-A-Resolved + neuen Future-Findings
- `tests/headless/run_polish_iter_a_validation.gd` (Integration)
- `run_slice_2_validation.gd` erweitert um ADR-010, ADR-011-Checks
- **`png/`-Ordner und Unterordner löschen** nach Test-Sign-off

**Gate:**
- Alle Doku-Files referenzieren Visual-Truth-Dogma einheitlich
- ADR-Doku-Checks im Integration-Test grün
- `png/` ist gelöscht
- Manueller Beauty/Debug-Mode-Lab-Check als zwei Gates

**Commit-Vorschlag:** `docs: visual truth contract and iter a documentation`

---

## 5. Test Plan

### 5.1 Headless-Suiten

(Inhalte wie in v3 Sektion 5, plus Sprite-Scale-Test in A2 und
WorldEnvironment-Single-Instance-Test in A3.)

### 5.2 Manueller Lab-Sign-off (Codex-P1: Performance getrennt)

**Beauty-Mode-Gate:**
- Lab startet im Beauty-Mode
- 7-Zellen-Bakterium ist sichtbar als Sprite-Hex-Zellen
- Energy Core animiert: zentrale Sphere pulsiert, Speed nimmt mit
  Pool-Füllstand zu
- Photosynthesis animiert: Chloroplasten bewegen sich subtil,
  Speed nimmt mit Activity zu
- `reproduction` statisch, `wall_outer` statisch mit Eck-Knoten
- Hintergrund-Particle-Drift dezent
- WorldEnvironment-Glow gibt Sprites Strahlung
- Keine sichtbaren Lücken zwischen Zellen
- **Camera funktioniert wie bisher:** WASD/Arrow pan, Wheel zoom,
  C reset

**Debug-Mode-Gate:**
- Hotkey `G` schaltet auf Debug-Mode
- Harte Hex-Polygone sichtbar mit Coords + Function-IDs
- Keine Animationen, keine Sprites, kein Glow, keine Particles
- Mode-Switch zerstört keine Sim
- Hotkey `G` schaltet zurück auf Beauty

**Performance-Gate (Profiler-basiert):**
- Godot-Profiler im Run aktivieren
- Im Beauty-Mode 10 Sekunden idle laufen lassen
- Frametime durchschnittlich < 16.6 ms (60 FPS)
- Keine Spikes > 33.3 ms
- Optional: künstlicher 100-Zellen-Body via Test-Inspector-Override
  → gleiches FPS-Gate

**Animation-Sign-off (entscheidend für Iter B):**
- Animation Energy Core: Geschwindigkeit + Wirkung gut?
- Animation Photo: Geschwindigkeit + Wirkung gut?
- Modulations-Range 4-12 FPS angemessen?
- Falls ja: Iter B liefert Reproduction- und Wall-Animationen
- Falls nein: FPS-Defaults oder Modulation-Strength tunen

---

## 6. Architecture Lookahead

(Unverändert ggü. v3.)

- **Iter B:** Reproduction + Wall-Animationen
- **Slice 3:** Cell-Spawn-Burst-Particles, Sprite-Pop-In
- **Slice 4:** Genom-Particle-Aura, Sprite-Tint-Modulation
- **Slice 5:** Texture-Atlas + MultiMesh, Phantom-Camera-Migration
  (laut ADR-009-Re-Eval-Trigger)
- **Slice 6+:** Sprite-Cross-Fade, Shader-Spike-ADR

---

## 7. ADR Updates (Codex-P1: Nummern korrigiert)

### ADR-010 (NEU): Simulation Truth vs. Visual Truth
Inhalt siehe Sektion 1.

### ADR-011 (NEU): Custom Cell Sprites with Animation and Outer/Inner Variants
- 5 statische Sprite-Dateien + 2 Animations-Spritesheets in
  `assets/textures/cell_functions/`
- 2 `SpriteFrames`-Resources in `resources/cell_functions/`
- Outer/Inner-Trennung für Wall (Variante A der Eck-Knoten-Lösung)
- Animations-Setup: 10 Frames pro Sheet, 2x5 Layout, 8 FPS Default
  mit 4-12 FPS Modulations-Range
- Loop einfach (kein Pingpong)
- Renderer-Compound: AnimatedSprite2D + Sprite2D-Kinder im Beauty-
  Mode, Polygon-`_draw()` nur in Debug-Mode
- Sprite-Skalierung: `sprite_diameter_scale = 2.2` Default
- Schema: `outer_sprite_texture`, `inner_sprite_texture`,
  `sprite_frames`, `animation_base_fps`, `animation_modulation_strength`
- Provenance: ChatGPT (User-Account), OpenAI Content Policy
- Re-Eval-Trigger: vor erstem Public-Release
- Stilkommitment: Nutzer liefert künftige Cell-Funktionen + ggf.
  Animationen im selben Stil
- Kenney Particle Pack: CC0, vendored, Adapter-pflichtig
- WorldEnvironment-Single-Instance-Guard im Adapter

### ADR-004 (UPDATE): Asset-Politik erweitert
(Wie v3.)

### ADR-006 (UPDATE): Visual Function Metadata Is Data-Driven
(Wie v3, plus expliziter Satz: *"Sim-Systeme lesen diese
Visual-Felder nicht. Sie sind ausschließlich von Runtime-Snapshot
und Renderer konsumierbar."*)

### ADR-009 (UNVERÄNDERT): Lab Camera Uses Built-In Camera2D
**Iter A respektiert ADR-009.** Kein `lab_camera_adapter.gd`,
keine Phantom-Camera, keine neue Camera-Schicht. Phantom-Camera
bleibt als FINDINGS-Eintrag für Slice 5.

---

## 8. Performance Gates (Codex-P1: Headless + Manuell getrennt)

### Headless-Gates (Setup/Struktur)

| Gate | Wert | Test |
|------|------|------|
| SpriteFrames laden | alle Frames laden ohne Fehler | A1 |
| Sprite-Scale-Berechnung | korrekte Formel | A2 |
| Snapshot-Build mit Animation-Feldern | < 5 ms bei 100 Zellen | A3 stress |
| Energy-Tick | < 1 ms bei 100 Zellen | Slice-2-Stress |
| Particle-Adapter Slots | alle drei rufbar | A3 |
| WorldEnvironment Single-Instance | exakt 1 Node nach 2× Aufruf | A3 |

### Manuelle Profiler-Gates (Beauty-Mode-Realismus)

| Gate | Wert | Test |
|------|------|------|
| Lab-FPS Beauty-Mode 7 Zellen | ≥ 60 FPS über 10 s | manuell A3 |
| Lab-FPS Beauty-Mode 100-Zellen-Hack | ≥ 60 FPS über 10 s | manuell A3 |
| Frame-Spike-Limit | < 33.3 ms (keine Stutter) | manueller Profiler |

---

## 9. Asset Provenance & Licensing

(Unverändert ggü. v3 Sektion 9.)

---

## 10. Assumptions

- Stil-Auswahl für Reproduction und Wall Inner durch Nutzer vor A1
- Reproduction- und Wall-Animationen in Iter B nach Sign-off
- Animations-Default-FPS = 8.0, Range 4-12 FPS, Loop einfach
- Frame-Größe pro Spritesheet wird beim Import gemessen
- WorldEnvironment-Glow ist 2D-tauglich in Godot 4.6 Mobile-Renderer
- AnimatedSprite2D-Approach skaliert auf 100 Zellen
- ChatGPT-Sprites 1024×1024 Single, Spritesheets variable
- `png/`-Ordner-Cleanup erst nach A4-Test-Sign-off
- `OrganismSnapshotBuilder.build()` hat bereits `render_hints`-
  Parameter (Lab:192-193 — Slice-2-P1.1 ist umgesetzt)
- Camera-Architektur ist ADR-009-Eigentum, wird nicht angetastet

---

## 11. Open Questions / Decisions Pending User

### 11.1 Stil-Auswahl (FINAL — durch Nutzer entschieden)

| Funktion | Gewählte Variante | Quelldatei | Begründung |
|----------|-------------------|------------|------------|
| Energy Core | Variante 1 (Sci-Fi-Frame mit Eck-Knoten) | `png/energy_core/energy_core.png` + `frames 10.png` | Hält Frame-Stil-Konsens mit Photo-V3 und Wall-Outer |
| Photosynthesis | Variante 3 (Frame mit Bubble-Detail) | `png/photosynthesis 3/photosynthesis 3.png` + `frames 10.png` | Einzige animierte Variante, faktisch festgelegt |
| Reproduction | Variante 3 (warmer Goldton, Hex-Pattern) | `png/reproduction 3/reproduction 3.png` + `frames 10.png` | Einzige animierte Variante, faktisch festgelegt |
| Wall Outer | (einzige Variante) | `png/outer_wall_membrane/outer_wall_membrane.png` + `frames 10.png` | — |
| Wall Inner | Variante 2 (intensiverer Glow) | `png/inner_wall_membrane 2/inner_wall_membrane 2.png` + `frames 10.png` | Animations-Sheet verfügbar, Boundary-Switch laut Variante A |

**Asset-Reserve (nicht in Iter A genutzt, behalten in `_alternates/`):**

- `png/energy_core 2/`, `png/energy_core 3/` (alternative Stil-Varianten + Animationen)
- `png/photosynthesis.png`, `png/photosynthesis 2.png` (statische Stil-Alternativen)
- `png/reproduction.png`, `png/reproduction 2.png` (statische Stil-Alternativen)
- `png/inner_wall_membrane.png` (Stil-Alternative ohne Animation)
- `png/inner_outer_wall_membrane/` (Backup-Konzept "generischer Wall-Sprite ohne
  Boundary-Switch", siehe FINDINGS-Eintrag)

**FINDINGS-Notiz:** Das `inner_outer_wall_membrane`-Konzept liefert einen
Wall-Sprite ohne Eck-Knoten, der für Innen UND Außen funktionieren würde
(Schema-Vereinfachung Variante B). Wird nicht in Iter A genutzt, weil
Variante A (Outer-mit-Knoten + Inner-2-ohne-Knoten) visuell differenzierter
ist. Falls Lab-Sign-off zeigt "doch lieber generisch", in Iter A.5
oder Slice 4 evaluieren.

**Iter B-Reserve:** Animations-Spritesheets für Energy Core V2/V3,
Photo-V1/V2 und Reproduction-V1/V2 existieren nicht (User hat dort nur
statische Varianten geliefert). Heißt: ein späterer Stil-Pivot weg
von der aktuellen Auswahl würde gleichzeitig Animations-Verlust bedeuten,
es sei denn der User liefert nach.

### 11.2 Außenmembran-Saum (Codex zugestimmt: implementieren)

`HexRenderConfig.boundary_glow_enabled: bool = false` als Konfig-
Toggle. Implementierung in A2.

### 11.3 Phantom Camera (Codex zugestimmt: nicht in Iter A)

Bleibt FINDINGS-Eintrag für Slice 5.

### 11.4 Beauty-Mode-Default (Codex zugestimmt: ja)

Beauty als Default. Hotkey G toggelt zu Debug.

### 11.5 `png/`-Cleanup (Codex zugestimmt: erst nach Test-Sign-off)

Löschen in A4 nach grünen Tests.

---

## 12. First Codex Review Brief

**Codex-Auftrag (für v4-Re-Review):**

Diesen Plan v4 verifizieren — alle 7 P1-Punkte aus dem v3-Review
sollten umgesetzt sein:

1. **ADR-Nummern:** ADR-010 = Visual Truth, ADR-011 = Custom Sprites
   ✅ in Sektion 7
2. **Hotkey G** statt D ✅ in Sektion 3.7
3. **Asset-Manifest** als A1-erste-Aktion ✅ in Sektion 4 A1
4. **Sprite-Skalierung** Formel + Schema-Felder ✅ in Sektion 3.4
5. **Performance-Gate** getrennt Headless + Manuell ✅ in Sektion 8
6. **WorldEnvironment Single-Instance-Guard** ✅ in Sektion 3.9
7. **Camera-Adapter** gestrichen ✅ in Sektion 3.10

**Plus (nicht im v3-Review aber wichtig):**
- ADR-006-Update enthält explizite Aussage *"Sim-Systeme lesen
  Visual-Felder nicht"* (Codex' Action-Hinweis zu 3.3)
- `boundary_glow_enabled = false` Default (Codex 11.2)
- `png/`-Cleanup erst in A4 nach Test-Sign-off (Codex 11.5)
- Debug-Hide-Regel: Sprite-Kinder werden in Debug-Mode versteckt
  (Codex' Action-Hinweis zu 3.4)

**Erwartete Ausgabe:**
Knappe Bestätigung pro P1-Punkt + grünes Licht für Iter-A-Start.

**Was noch offen bleibt:**
- Stil-Auswahl 11.1 (meine Entscheidung als Nutzer)

---

*Ende Plan v4. Bei grünem Licht von Codex und Stil-Auswahl 11.1
startet A1.*
