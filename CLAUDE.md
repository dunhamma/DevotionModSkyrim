# Claude instructions

Read and follow [AGENTS.md](AGENTS.md). It is the canonical living context document for
this project -- build status, architecture decisions, the project file map, and the
decision history -- and it is shared with Codex.

## Rules for Claude sessions

1. Read `AGENTS.md` at the start of every session. This file is an entrypoint only and
   is never a source of build status.
2. All Skyrim plugin work goes through the `housecarl_*` MCP tools directly. `AGENTS.md`
   states that rule in full, and it supersedes any doc that conflicts with it -- if a doc
   still points at a retired helper, follow `AGENTS.md` and flag the drift.
3. Do not overwrite or update `AGENTS.md` unless asked.
4. Do not edit the toolchain scripts (`tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`) or
   the `pdv-*` skills unless asked.
5. Before writing or modifying a `.psc`, read the Papyrus guidance in `AGENTS.md` and
   `references/PAPYRUS_KNOWLEDGE_INTAKE.md`.
6. Prefer scoped changes. Avoid unrelated doc rewrites and broad cleanup.

## Coexistence with Codex

Codex is the primary coding agent and `AGENTS.md` is its canonical context. This file is
Claude's entrypoint and should stay small: anything that applies to both agents belongs
in `AGENTS.md`, not here.

Shared docs and scripts can be edited when asked, but a change that alters architecture,
status or workflow must be reflected in `AGENTS.md`.
