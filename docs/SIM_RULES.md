# Baktorium Simulation Rules

## Slice 1 Scope

Slice 1 creates one visible starter bacterium. It does not simulate energy, growth, mutation, movement, combat, digestion, light maps, substrate, world occupancy, or multiple organisms.

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
