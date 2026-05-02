# Baktorium Status

## Current Slice

Slice 2: Energy v0.

## Implemented In This Slice

- Canonical agent and project docs.
- Hex coordinate and grid math foundation.
- Body model, function catalog, genome schema, simulation placement service.
- Runtime render snapshot between sim and renderer.
- Starter bacterium lab scene with seven-cell body.
- Built-in renderer, debug overlay, optional flow config, plugin adapters.
- Headless validation scripts under `tests/headless/`.
- Claude Code Slice 1 review hardening: private body storage, documented plugin autoloads, `requires_surface`, stronger validation.
- Claude Code follow-up hardening: private `SimulationService` storage, data-driven visual accent metadata, stricter plugin adapter boundary tests, typed lab/config and cell coordinate fields.
- Organism-pool energy state, fixed energy ticks, energy config resource, energy snapshot fields, lab HUD energy feedback, and 100-cell stress validation.

## Not Implemented

- Growth.
- Mutation.
- World grid.
- Multiple organisms.
- Movement, collision, combat, digestion, sensors.
- Manual visual sign-off by the user.

## Validation

Run after changes:

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_validation.gd
```
