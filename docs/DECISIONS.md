# Baktorium Decisions

## ADR-001: Axial Hex Coordinates

Decision: Simulation uses axial `(q, r)` coordinates. Render orientation is configurable and defaults to pointy-top.

Reason: Axial coordinates are compact, testable, and map well to connected hex bodies.

## ADR-002: SimulationService Owns Cell Placement

Decision: `SimulationService.place_cell()` is the only public placement API.

Reason: Slice 5 can add `WorldGrid` occupancy without refactoring every caller.

Implementation rule: `SimulationService` keeps organism storage and placement counters private. Callers use `place_cell()`, `get_body()`, `get_organism_ids()`, and read-only metrics such as `get_placement_count()`.

## ADR-003: Runtime Snapshot Between Sim And Rendering

Decision: `OrganismRenderSnapshot` lives in `src/runtime/`.

Reason: Rendering must consume derived read models, not live mutable organism bodies.

## ADR-004: Slice 1 External Assets

Decision: Antialiased Line2D v1.2.0 and Debug Menu v1.2.0 are vendored and activated.

Sources:

- Antialiased Line2D: `addons/antialiased_line2d`, Asset Library `https://godotengine.org/asset-library/asset/3103`
- Debug Menu: `addons/debug_menu`, Asset Library `https://godotengine.org/asset-library/asset/1902`

Rules:

- Assets are committed locally in `addons/`.
- Plugins are enabled in `project.godot`.
- `HexOutlineDrawer` and `DebugMenuAdapter` are the project-facing adapters.
- Built-in `_draw()` remains the fallback for organism rendering.
- Assets must not write simulation state.

Plugin-mandatory autoloads:

- `AntialiasedLine2DTexture` is required by Antialiased Line2D.
- `DebugMenu` is required by Debug Menu.
- Both autoloads are plugin/tooling autoloads, not simulation autoloads.
- They do not own or mutate simulation truth.
- They do not count as future Baktorium simulation autoloads such as `TimeService`.

## ADR-005: Flow Is Optional

Decision: `HexRenderConfig.flow_enabled` defaults to `false`.

Reason: Flow is useful for first visual calibration, but later growth/performance work should not inherit a mandatory animation cost.

## ADR-006: Visual Function Metadata Is Data-Driven

Decision: Cell-specific accent style and boundary outline emphasis live on `CellFunctionDef`, not as hard-coded renderer branches per function id.

Reason: Slice 2+ can add visible cell functions without rewriting renderer logic or mixing simulation identity with presentation recipes.

## ADR-007: Energy Tick Architecture

Decision: Slice 2 energy is an organism-level pool owned by simulation state, not per-cell mutable energy.

Implementation:

- `OrganismEnergyState` is a sim-internal RefCounted state object.
- `EnergySystem.tick(body, catalog, state, config)` is a static, stateless calculation path.
- `EnergySystem.tick()` may mutate `OrganismEnergyState`, but must not mutate `OrganismBody`.
- `SimulationService` stores energy states privately in `_energy_states_by_id`.
- Public energy access goes through `reset_energy()`, `tick_energy()`, and `get_energy_metrics()`.
- `CellFunctionDef.energy_capacity` is the canonical schema field for energy storage capacity.
- Runtime snapshot building keeps copied energy metrics separate from render hints such as low-energy warning thresholds.

Reason: This preserves the Slice 1 service/snapshot boundary while adding the first active simulation system.

## ADR-008: Slice 2 Tick Mechanism

Decision: Slice 2 uses the lab scene's `_process(delta)` as the composition-root driver for fixed energy ticks.

Reason: Slice 2 has one visible organism and no global world clock. A `TimeService` autoload would add global state and test mocking overhead before multiple organisms or a world grid exist.

Re-evaluation trigger: before Slice 5, reassess whether WorldGrid or multiple organisms require a shared `TimeService`.

## ADR-009: Lab Camera Uses Built-In Camera2D

Decision: Slice 2 lab navigation uses Godot's built-in `Camera2D`, not an external camera plugin.

Reason: The lab currently needs only pan, zoom, reset, smoothing, and HUD separation. Built-in `Camera2D` covers this without adding a plugin, adapter, autoload, or asset-maintenance burden.

Implementation:

- `W/A/S/D` and arrow keys pan the camera.
- Mouse wheel zooms.
- `C` resets camera position and zoom.
- `G` toggles debug overlay because `D` is reserved for camera pan.
- HUD remains in `CanvasLayer` so camera zoom does not scale the HUD text.
