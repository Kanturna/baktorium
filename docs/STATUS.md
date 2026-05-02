# Baktorium Status

## Current Slice

Slice 2 Polish Iter B0: frame normalization and visual bugfixes after Beauty Layer.

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
- Built-in `Camera2D` lab navigation with WASD/arrow pan, mouse-wheel zoom, `C` reset, and compact default view.
- Beauty/Debug render mode foundation using custom cell sprites, dynamic 5x2 SpriteFrames, render-only visual metadata, WorldEnvironment glow, ambient particles, and `G` mode toggle.
- 100-cell lab stress body override for manual Beauty-mode performance checks.
- Derived cell-function textures are regenerated from transparent `png/` source sheets with centered frame pivots and integer SpriteFrame regions.
- Derived animation frames also normalize visible alpha size per sheet to reduce grow/shrink jitter.
- Core and photosynthesis animations are slowed through `animation_base_fps`; reproduction and wall cells are static by default.
- Ambient particles are disabled by default and remain renderer-parented for later explicit reactivation.

## Not Implemented

- Growth.
- Mutation.
- World grid.
- Multiple organisms.
- Movement, collision, combat, digestion, sensors.
- Manual visual sign-off by the user.
- Manual Beauty-mode sign-off for Iter A.
- Manual Iter B0 sign-off for no checkerboard, no animation jitter, and acceptable cross-function sprite sizing.
- `png/` cleanup after Beauty-mode sign-off.

## Validation

Run after changes:

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_camera_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_validation.gd
```

Slice 2 Polish Iter A adds:

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a1_assets_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a2_renderer_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a3_environment_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_iter_a_validation.gd
```
