# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Repo layout

This is a single-context repo. There is no `CONTEXT-MAP.md`, and skills should treat the repo's top-level project docs as the primary domain reference set.

## Before exploring, read these

- `AGENTS.md` at the repo root for the current project context and workflow rules
- `PDV_STANDARDS.md` for operating rules, safety constraints, and doc hygiene
- `PDV_MOD_SETUP.md` for environment, build order, and variable reference
- `PDV_Architecture_v2.md` for architecture, phase planning, and system model
- `references/PAPYRUS_KNOWLEDGE_INTAKE.md` when the task touches Papyrus APIs, imports, compiler setup, or plugin-provided functions
- `references/PDV_RaceArchitecture_DesignReference.md` when the task touches race theology, reward logic, or design intent
- `docs/adr/` if it is added later and contains decisions relevant to the area being changed

If a listed file does not exist, proceed silently and use the closest available project context docs.

## Use the project's vocabulary

When describing domain concepts, use the terms already established in the repo docs. Prefer the PDV-specific language used in `AGENTS.md`, architecture docs, and reference files over generic synonyms.

## Flag decision conflicts

If a proposal or change conflicts with an established project document or later ADR, surface that conflict explicitly instead of silently overriding it.
