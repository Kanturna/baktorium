# Baktorium Findings

Use this file for bugs, review findings, debug notes, risks, and planned corrections.

## Open Findings

- Manual visual gate remains open for the user: check the lab scene for readable function colors, no logical cell gaps, debug overlay toggle, flow toggle, and Debug Menu toggle.
- Before Slice 5 world-scale work, evaluate whether high-volume cell storage should keep `HexCoord` objects or move hot paths to `Vector2i`/packed axial keys. Keep `HexCoord` for Slice 1 clarity unless profiling says otherwise.
- If `src/debug/` grows beyond the current adapter/probe scope, narrow plugin-isolation validation from directory-level skips to explicit adapter-file whitelists.

## Resolved Findings

### 2026-05-02 - Claude Code Slice 1 Review

- Closed public `OrganismBody.cells_by_key` access by renaming storage to `_cells_by_key` and adding read APIs.
- Closed public `SimulationService.bodies_by_id` and `placement_count` access by moving them to private fields plus read-only getters.
- Replaced direct snapshot/validator dictionary access with body read methods.
- Documented plugin-mandatory autoloads in ADR-004.
- Added `CellFunctionDef.requires_surface`.
- Moved visible accent and boundary emphasis from renderer hard-coding into `CellFunctionDef` metadata.
- Added stronger connectivity, boundary, service-encapsulation, plugin-isolation, and integration validation.
