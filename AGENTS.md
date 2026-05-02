# Baktorium Agent Rules

## Always Read First

Before code changes, read:

1. `AGENTS.md`
2. `docs/STATUS.md`
3. `docs/NEXT_STEPS.md`
4. `docs/ARCHITEKTUR.md` when changing architecture, layer rules, ownership, services, or autoloads
5. `docs/SIM_RULES.md` when changing cell functions, energy/growth logic, tick order, simulation rules, or non-goals
6. `docs/FINDINGS.md` when reviewing, debugging, or fixing known issues

If documents conflict, use this authority order:

```text
ARCHITEKTUR > DECISIONS > SIM_RULES > STATUS > NEXT_STEPS > AGENTS > README
```

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

Examples:

- OK: one coherent body/model slice that includes factory, resources, and tests.
- Too small: one commit per empty documentation stub when the docs form one working contract.
- Too large: combining unrelated renderer polish, energy simulation, growth, and UI changes without one validation gate.

## Architecture Invariants

These rules are non-negotiable. A change that conflicts with them needs an ADR in `docs/DECISIONS.md` before implementation.

- Simulation data, runtime snapshots, rendering, UI, and debug stay strictly separated by layer.
- A cell is data, not a Godot node.
- The only public cell placement API is `SimulationService.place_cell()`.
- Direct mutation of `OrganismBody.cells` is forbidden outside `SimulationService`.
- Renderer and UI must not create or mutate simulation truth.
- Tuning parameters should live in inspector-editable `Resource` and `@export` fields, not hardcoded constants.
- External assets must be documented in `docs/DECISIONS.md`, wrapped by adapter scripts, and vendored in `addons/`.

## Validation

After every code change, match validation depth to the changed layer:

- `core/`, `genetics/`, `body/`, `sim/`: run the relevant headless test in `tests/headless/`.
- `runtime/`, `rendering/`: run snapshot integrity validation and request or perform a Lab visual smoke check.
- `scenes/`, `ui/`, `debug/`: run or explicitly hand off a manual Lab check for toggles, sliders, hotkeys, and visible state.
- `docs/`: check cross-links, document hierarchy, and consistency with current code.

Rules:

- Run the smallest validation that is meaningful for the affected layer, not the smallest validation that is convenient.
- If the agent cannot perform a visual check, explicitly ask the user to run it and name what to inspect.
- Never invent test results or repo facts.
- If validation was not run at all, state exactly why and which gate remains open.

## Documentation Sync

After every relevant repo change, check whether documentation must be updated:

- `docs/STATUS.md` for the real current state
- `docs/NEXT_STEPS.md` for the next concrete work block or open gate
- `docs/DECISIONS.md` for new direction or architecture decisions
- `docs/ARCHITEKTUR.md` for changed layer rules, ownership, services, or autoloads
- `docs/SIM_RULES.md` for changed simulation rules, cell functions, tick order, or non-goals

If code changed but docs did not, explain why no documentation update was needed.

## Decision Triggers

Update `docs/DECISIONS.md` when a change introduces or changes:

- architecture or layer authority
- external assets, plugins, adapters, autoloads, or asset version upgrades
- simulation truth or core data ownership
- public APIs used across layers
- canonical cell functions, genome schema, or runtime snapshots
- test strategy or runner framework
- performance gate misses or regressions
- slice direction, scope boundaries, or non-goals

## Review Handoff

Every completion report ends with exactly one review stance:

- `No cross-agent review needed` for trivial single-file docs, typos, or mechanical fixes.
- A concrete cross-agent review request when another agent should evaluate the change.

A cross-agent review is recommended when the change:

- touches architecture, layer boundaries, or simulation authority
- introduces or changes a slice plan or scope boundary
- adds external assets, plugins, autoloads, or adapter boundaries
- changes core simulation data structures or runtime snapshots
- misses a performance gate or exposes unclear tradeoffs
- is large enough that a second perspective is likely to catch drift or hidden coupling

Frame the request as a concrete focus, not just "please review".

Examples:

- `Claude Code: verify no simulation truth lives in rendering/ or scenes/.`
- `Codex: verify all cell placements go through SimulationService.place_cell().`
- `GPT: review whether the slice plan creates micro-slicing or hidden coupling.`

## Completion Protocol

Every implementation response should include:

- goal handled
- changed file groups
- validation run
- documentation sync result or reason it was not needed
- known risks or follow-ups
- review handoff stance from "Review Handoff"
- commit title suggestion in its own copyable block
- commit description suggestion in a separate copyable block

Commit title format:

```text
type(scope): imperative title
```

Allowed commit types:

```text
feat, fix, perf, refactor, docs, test, chore
```

Common scopes:

```text
core, sim, runtime, body, genetics, rendering, ui, scenes, debug, addons, docs, tests, tools, planning
```

Do not auto-commit, push, or open PRs unless explicitly requested.

## Anti-Patterns

- Do not hide simulation truth in `rendering/`, `scenes/`, `ui/`, or `debug/`.
- Do not mutate `OrganismBody.cells` outside `SimulationService`.
- Do not introduce assets, plugins, adapter boundaries, or autoloads without documenting the decision.
- Do not bundle unrelated work just to reduce slice count.
- Do not split coherent work into artificial micro-slices.
- Do not invent validation results.
- Do not auto-commit, push, or open PRs without explicit user approval.
