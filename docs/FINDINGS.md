# Baktorium Findings

Use this file for bugs, review findings, debug notes, risks, and planned corrections.

## Open Findings

- Renderer accent drawing is still tag-specific for `energy_core`, `photosynthesis`, and `reproduction`. Before adding more visible cell functions, introduce data-driven accent metadata on `CellFunctionDef` or a dedicated accent recipe resource.
- Manual visual gate remains open for the user: check the lab scene for readable function colors, no logical cell gaps, debug overlay toggle, flow toggle, and Debug Menu toggle.

## Resolved Findings

### 2026-05-02 - Claude Code Slice 1 Review

- Closed public `OrganismBody.cells_by_key` access by renaming storage to `_cells_by_key` and adding read APIs.
- Replaced direct snapshot/validator dictionary access with body read methods.
- Documented plugin-mandatory autoloads in ADR-004.
- Added `CellFunctionDef.requires_surface`.
- Added stronger connectivity, boundary, plugin-isolation, and integration validation.
