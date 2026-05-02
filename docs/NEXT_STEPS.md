# Baktorium Next Steps

## Immediate Gate

Validate Slice 2 Polish Iter B0:

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tools/normalize_cell_spritesheets.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a1_assets_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a2_renderer_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_a3_environment_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_polish_iter_a_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_camera_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_validation.gd
```

Then open the lab scene in Godot and check:

- Beauty mode starts by default.
- Cell sprites no longer show checkerboard or opaque rectangular backgrounds.
- Energy Core and Photosynthesis animations do not visibly jitter left/right, up/down, or grow/shrink.
- Energy Core and Photosynthesis animation speed feels slow and subtle rather than busy.
- Reproduction and Wall cells stay visually static unless animation is deliberately re-enabled later.
- The seven-cell starter bacterium is visible with detailed sprites and no visual cell gaps.
- Energy Core, Photosynthesis, Reproduction, and Wall cells are clearly distinguishable.
- Energy Core and Photosynthesis animations feel subtle rather than noisy.
- Wall boundary cells use the outer wall visual style.
- Ambient particle bubbles are not visible by default.
- `G` toggles Beauty/Debug mode.
- Debug mode shows hard hex polygons, coordinates, and function ids.
- Beauty mode hides debug text and keeps sprites visible.
- `F` still toggles flow.
- `F3` still toggles Debug Menu.
- `WASD` (`W/A/S/D`) or arrow keys pan the camera.
- `Mouse wheel` zooms without making cell sprites visibly pixelated.
- `C` resets camera position and zoom.
- Seed reset/rebuild with `N`, `B`, and `R` keeps the starter body at seven cells.
- Enable `use_stress_body` in the lab Inspector and confirm the 100-cell Beauty-mode stress body runs at 60 FPS for 10 seconds with no frame spikes above 33.3 ms.

## Cleanup Gate

Do not delete `png/` until the Beauty/Debug visual check and the 100-cell performance gate are signed off. After sign-off, remove `png/` and rerun `run_polish_iter_a_validation.gd` with the cleanup expectation updated.

## After Polish Iter A

Do not start growth until the Beauty-mode baseline has been reviewed. Before 250+ cells, evaluate whether Sprite2D/AnimatedSprite2D pooling should move to TextureAtlas, MultiMesh, or another batched rendering approach.

## Commit Suggestion

```text
fix(rendering): normalize cell animation frames
```
