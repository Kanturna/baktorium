# Baktorium Agent Rules

## Always Read First

Before code changes, read:

1. `AGENTS.md`
2. `docs/STATUS.md`
3. `docs/NEXT_STEPS.md`
4. `docs/ARCHITEKTUR.md` when changing structure
5. `docs/SIM_RULES.md` when changing simulation rules

## Start Protocol

Before every non-trivial change:

- check `git status --short`
- read the required docs from "Always Read First"
- name the goal of the change
- name the affected layer or file group
- name the main assumption and risk
- name the intended validation path before editing

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

## Documentation Sync

After every relevant repo change, check whether documentation must be updated:

- `docs/STATUS.md` for the real current state
- `docs/NEXT_STEPS.md` for the next concrete work block or open gate
- `docs/DECISIONS.md` for new direction or architecture decisions
- `docs/ARCHITEKTUR.md` for changed layer rules, ownership, services, or autoloads
- `docs/SIM_RULES.md` for changed simulation rules, cell functions, tick order, or non-goals

If code changed but docs did not, explain why no documentation update was needed.

## Validation

After every code change:

- run the smallest meaningful validation that covers the change
- run the relevant headless Godot test when available
- perform or name a manual Lab/visual check for visual changes
- never invent test results or repo facts
- if validation was not run, state exactly why and what gate remains open

## Decision Triggers

Update `docs/DECISIONS.md` when a change introduces or changes:

- architecture or layer authority
- external assets, plugins, adapters, or autoloads
- simulation truth or core data ownership
- public APIs used across layers
- canonical cell functions, genome schema, or runtime snapshots
- slice direction, scope boundaries, or non-goals

## Completion Protocol

Every implementation response should include:

- goal handled
- changed file groups
- validation run
- documentation sync result or reason it was not needed
- known risks or follow-ups
- review handoff focus when another agent should evaluate the change
- commit title suggestion in its own copyable block
- commit description suggestion in a separate copyable block

Do not auto-commit, push, or open PRs unless explicitly requested.

## Review Handoff

For larger or riskier changes, end with a concrete review request for the other agent. Name what should be checked, not just "please review".

Useful review focuses:

- layer boundaries and hidden simulation truth
- scope drift or slice-size risk
- asset/plugin boundaries and fallback behavior
- missing tests or weak validation
- documentation drift
- performance risks in future slices

## Cross-Agent Review

Agents should explicitly recommend a second-agent review when it would improve quality or reduce architectural risk.

Recommend review by another agent when a change:

- touches architecture, layer boundaries, or simulation authority
- introduces or changes a slice plan
- adds external assets, plugins, autoloads, or adapter boundaries
- changes core simulation data structures or runtime snapshots
- has unclear tradeoffs, unresolved risks, or surprising test results
- is large enough that a second perspective is likely to catch drift or hidden coupling

Do not require cross-agent review for every small documentation or mechanical fix. When recommending review, name the requested reviewer focus clearly, for example: "Claude Code should review layer boundaries and hidden simulation truth" or "Codex should review implementation feasibility and test coverage."
