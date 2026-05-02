# Baktorium Decisions

## ADR-001: Axial Hex Coordinates

Decision: Simulation uses axial `(q, r)` coordinates. Render orientation is configurable and defaults to pointy-top.

Reason: Axial coordinates are compact, testable, and map well to connected hex bodies.

## ADR-002: SimulationService Owns Cell Placement

Decision: `SimulationService.place_cell()` is the only public placement API.

Reason: Slice 5 can add `WorldGrid` occupancy without refactoring every caller.

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

## ADR-005: Flow Is Optional

Decision: `HexRenderConfig.flow_enabled` defaults to `false`.

Reason: Flow is useful for first visual calibration, but later growth/performance work should not inherit a mandatory animation cost.

