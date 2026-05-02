# Baktorium Simulation Rules

## Slice 1 Scope

Slice 1 creates one visible starter bacterium. It does not simulate energy, growth, mutation, movement, combat, digestion, light maps, substrate, world occupancy, or multiple organisms.

## Slice 2 Energy Scope

Slice 2 adds deterministic organism-pool energy only. It does not add growth, mutation, death, movement, light maps, substrate, world occupancy, or multiple organisms.

Energy rules:

- The starter bacterium has one shared energy pool.
- `energy_core` contributes `30.0` energy capacity and `0.1` maintenance.
- Each `photosynthesis` cell produces `2.0` energy per tick and costs `0.25` maintenance.
- `reproduction` costs `0.35` maintenance and carries dormant `growth_cost = 8.0`.
- Each `wall` costs `0.15` maintenance.
- Starter totals are `max_energy = 30.0`, initial energy `15.0`, production `4.0`, maintenance `1.4`, net `+2.6`.
- Low energy only affects HUD/tint feedback in Slice 2; it does not damage or disable cells.

## Hex Model

- One cell occupies exactly one axial hex coordinate `(q, r)`.
- The default render orientation is pointy-top.
- Pointy/flat orientation is render configuration, not simulation truth.
- A bacterium is a connected group of adjacent hex cells.
- Cells touch directly; visual outlines must not create logical gaps.

## Starter Bacterium v0

The starter body has exactly seven cells:

```text
(0,0)   = energy_core
(1,0)   = photosynthesis
(0,1)   = photosynthesis
(-1,0)  = reproduction
(1,-1)  = wall
(0,-1)  = wall
(-1,1)  = wall
```

## Cell Functions

| ID | Slice 1 role | Later role |
| --- | --- | --- |
| `energy_core` | visual cell nucleus and energy center | organism energy anchor |
| `photosynthesis` | visible green surface component | energy production |
| `reproduction` | visible growth organ placeholder | growth charge source |
| `wall` | visible membrane/body structure | protection and boundary material |

Slice 1 cell-function resources also carry visual metadata:

- `accent_kind` controls non-simulation accent drawing such as nucleus glow, surface dots, or reproduction rings.
- `boundary_outline_scale` controls boundary emphasis without renderer hard-coding.
- `requires_surface` marks functions that should live on organism surfaces once growth rules exist.
- `energy_capacity` controls organism-level storage capacity.

## Genome Schema

`Genome` exists in Slice 1 only as an inactive schema with eight normalized fields:

- `photosynthesis_bias`
- `wall_bias`
- `reproduction_bias`
- `growth_spread`
- `symmetry_bias`
- `surface_preference`
- `energy_efficiency`
- `mutation_rate`
