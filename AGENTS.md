# Baktorium Agent Rules

## Always Read First

Before code changes, read:

1. `AGENTS.md`
2. `docs/STATUS.md`
3. `docs/NEXT_STEPS.md`
4. `docs/ARCHITEKTUR.md` when changing structure
5. `docs/SIM_RULES.md` when changing simulation rules

## Slice Discipline

- Work in slices that are as large as possible and as small as needed.
- Keep simulation data, runtime snapshots, rendering, UI, and debug separate.
- A cell is data, not a Godot node.
- The only public cell placement API is `SimulationService.place_cell()`.
- Renderer and UI must not create or mutate simulation truth.
- Prefer inspector-editable `Resource` and `@export` parameters for calibration.
- External assets must be documented in `docs/DECISIONS.md` and wrapped by adapters.

## Completion Protocol

Every implementation response should include:

- goal handled
- changed file groups
- validation run
- known risks or follow-ups
- commit title and commit description suggestion

Do not auto-commit, push, or open PRs unless explicitly requested.

