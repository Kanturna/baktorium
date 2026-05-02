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
- Do not split work into tiny micro-slices when one coherent thematic slice can be implemented, reviewed, and validated without raising risk.
- It is acceptable to include multiple related changes in one slice when they share one architectural purpose and can be tested together.
- Do not bundle unrelated work, risky rewrites, or broad reforms just to reduce the number of slices.
- Choose slice size by quality, failure risk, reviewability, and validation path, not by a fixed preference for small or large changes.
- Keep files and modules focused on one clear responsibility, but allow one slice to touch several focused files when that is the coherent implementation unit.
- For larger slices, explicitly name scope, architecture decisions, important file groups, validation, and deliberately excluded topics in the completion report.
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
- commit title suggestion in its own copyable block
- commit description suggestion in a separate copyable block

Do not auto-commit, push, or open PRs unless explicitly requested.
