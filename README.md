# Baktorium

Baktorium is a Godot 4.6 hex-cell simulation prototype.

Slice 1 creates the first visible starter bacterium: a seven-cell connected hex body with `energy_core`, `photosynthesis`, `reproduction`, and `wall` functions.

## Run

Open the project in Godot 4.6 and run:

```text
res://scenes/lab/starter_bacterium_lab.tscn
```

Controls:

- `N`: next seed
- `B`: previous seed
- `R`: deterministic random seed
- `D`: debug overlay
- `F`: wall-flow visual toggle
- `F3`: Debug Menu toggle

## Validate

```powershell
D:\Programme\Godot\Godot.exe --headless --path D:\Projekte\Godot\baktorium --script res://tests/headless/run_slice_1_validation.gd
```

## Vendored Assets

- Antialiased Line2D v1.2.0, adapter: `src/rendering/hex_outline_drawer.gd`
- Debug Menu v1.2.0, adapter: `src/debug/debug_menu_adapter.gd`

Both assets are rendering/debug tools only. They do not own or mutate simulation state.

