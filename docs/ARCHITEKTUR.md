# Baktorium Architecture

## Layer Order

```text
ui / debug / scenes
        ^
rendering
        ^
runtime
        ^
sim
        ^
core
```

Rules:

- `core/` contains reusable math and no Godot scene or node dependencies.
- `sim/` owns organism bodies, cell functions, placement, validation, and future rules.
- `runtime/` builds read-only snapshots and derived view models.
- `rendering/` draws snapshots and may use render/debug adapters.
- `scenes/` compose nodes, resources, input, and lab workflow.
- `debug/` observes; it does not write simulation state.

## Cell Placement

All cell placement goes through:

```text
SimulationService.place_cell(organism_id, coord, function_id, visual_seed)
```

`OrganismBody` has only an internal `_place_cell_internal()` method. This keeps the later `WorldGrid` extension possible without changing callers.

`SimulationService` internal organism storage and placement counters are private implementation details. Tests and debug UI may read counters only through explicit getters.

## Rendering Contract

Renderers read `OrganismRenderSnapshot` from `src/runtime/`. They must not read or mutate `OrganismBody` directly.

The first renderer uses `Node2D._draw()` plus optional adapter-based antialiased boundary drawing. A later MultiMesh or TileMapLayer spike must preserve the same snapshot contract.

Visual differences between cell functions are driven by render metadata copied into the snapshot. Renderers may branch on accent recipe names, not on simulation function ids.

## Energy Contract

Energy state is simulation truth and stays behind `SimulationService`. Runtime snapshots may carry copied energy metrics and derived per-cell render fields, but rendering and scenes must not hold mutable `OrganismEnergyState` references.

Render thresholds such as low-energy warning ratios are render hints. They must be passed separately from `energy_metrics` so simulation read data stays semantically clean.

Slice 2 uses the lab scene as composition root for fixed ticks. This is a deliberate local driver, not a global simulation clock.

## Asset Contract

External plugins live in `addons/` and are connected through adapter scripts. They may improve rendering or debugging, but they do not own simulation state.
