# Baktorium Next Steps

## Immediate Gate

Validate Slice 2.4:

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_camera_validation.gd
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_2_validation.gd
```

Then open the lab scene in Godot and check:

- the seven-cell starter bacterium is visible,
- all four function types are visually distinct,
- energy rises toward the maximum,
- the energy core and photosynthesis cells show subtle energy feedback,
- debug overlay toggles with `G`,
- flow toggles with `F`,
- Debug Menu toggles with `F3`,
- `WASD` (`W/A/S/D`) or arrow keys pan the camera,
- `Mouse wheel` zooms without making HUD text blurry,
- `C` resets camera position and zoom,
- seed reset/rebuild with `N`, `B`, and `R` keeps the body at seven cells,
- no logical cell gaps are visible.

## After Slice 2

Do not start growth until Slice 2 energy behavior and visual feedback have been reviewed.

Before growth, plan a visual calibration slice for the hybrid wall-hex plus flowing outer membrane style.

## Slice 2 Commit Suggestions

2A:

```text
feat(sim): add organism energy tick
```

2B:

```text
feat(runtime): expose energy feedback in lab
```

2.4:

```text
feat(lab): add camera navigation
```
