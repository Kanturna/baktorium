# Baktorium Findings

Use this file for bugs, review findings, debug notes, risks, and planned corrections.

## Open Findings

- Manual visual gate remains open for the user: check the lab scene for readable function colors, no logical cell gaps, debug overlay toggle, flow toggle, and Debug Menu toggle.
- Before Slice 5 world-scale work, evaluate whether high-volume cell storage should keep `HexCoord` objects or move hot paths to `Vector2i`/packed axial keys. Keep `HexCoord` for Slice 1 clarity unless profiling says otherwise.
- If `src/debug/` grows beyond the current adapter/probe scope, narrow plugin-isolation validation from directory-level skips to explicit adapter-file whitelists.
- Before Slice 5, evaluate whether the lab-driven energy tick should become a shared `TimeService` for WorldGrid and multiple organisms.
- SimulationService grows with each sim system. Before Slice 5, reassess whether it should remain the central gateway or split into dedicated services with `SimulationService` as orchestrator.
- Visual quality is not yet acceptable. Before growth, plan a visual calibration slice for smaller framing, richer wall-hex detail, better palette, and flowing outer membrane.
- Hex-radius remains at `42.0` for Slice 2 Polish Iter A. Re-evaluate Hex-radius as a visual tuning option after Beauty-mode sign-off.
- Particle adapter currently owns only ambient world drift. Extend it in Slice 3 for cell event bursts and Slice 4 for organism aura only when those effects become real slice requirements.
- Before 250+ cells, evaluate whether the Beauty renderer should move from pooled `Sprite2D`/`AnimatedSprite2D` nodes to TextureAtlas, MultiMesh, or another batched path.
- Iter B0 normalized active sprite sheets, but final tile heights still differ by more than 5% between functions (`344..390` px). During manual Beauty sign-off, check whether cross-function sprite sizing feels coherent; if not, plan Iter B1 for cross-function anchor/scale normalization.

## Resolved Findings

### 2026-05-02 - Claude Code Slice 1 Review

- Closed public `OrganismBody.cells_by_key` access by renaming storage to `_cells_by_key` and adding read APIs.
- Closed public `SimulationService.bodies_by_id` and `placement_count` access by moving them to private fields plus read-only getters.
- Replaced direct snapshot/validator dictionary access with body read methods.
- Documented plugin-mandatory autoloads in ADR-004.
- Added `CellFunctionDef.requires_surface`.
- Moved visible accent and boundary emphasis from renderer hard-coding into `CellFunctionDef` metadata.
- Added stronger connectivity, boundary, service-encapsulation, plugin-isolation, and integration validation.

### 2026-05-02 - Slice 2 Energy v0

- Added organism-pool energy as the first active simulation system.
- Added ADR-007 for energy state, static tick calculation, service API, and `energy_capacity`.
- Added ADR-008 for lab-driven fixed ticks instead of an early `TimeService`.
- Added stress-test and snapshot-boundary validation for energy.
- Separated low-energy render hints from copied simulation energy metrics after Claude Code review.
- Added built-in `Camera2D` lab pan/zoom/reset controls without introducing a camera plugin.

### 2026-05-02 - Claude Coach Beauty Layer Review

- Reduced `sprite_diameter_scale` from `2.2` to `1.1` after manual sign-off exposed excessive sprite overlap.
- Re-parented ambient particles to the organism renderer so they spawn around the bacterium center.
- Regenerated SpriteFrame atlas regions as integer pixel rectangles to avoid animation sub-pixel jitter.
- Added validation for sprite diameter sanity, integer atlas regions, and particle anchoring.

### 2026-05-02 - Slice 2 Polish Iter B0

- Regenerated active cell-function textures from the transparent `png/` source sheets into derived runtime assets under `assets/textures/cell_functions/`.
- Added `tools/normalize_cell_spritesheets.gd` to center animation frames by alpha bounds, normalize visible frame footprint, and generate static frame-0 fallbacks.
- Added asset validation for transparent corners, mipmaps, integer regions, `<= 1 px` frame-center drift, and `<= 1 px` visible-size drift.
- Disabled ambient particles by default while keeping the renderer-relative adapter path available for later explicit effects.
- Slowed core/photosynthesis animation to subtle low-FPS playback and made reproduction/wall static by default.
