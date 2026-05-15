# CLAUDE.md — PlayerDevotion (PDV) Mod Project

## How Claude Works in This Repo

**Codex is the primary coding agent.** `AGENTS.md` is the canonical living context doc — it owns build status, decisions log, and the authoritative project file map. Claude defers to it.

### Rules for Claude sessions

1. **Read `AGENTS.md` at the start of every session** for current build status, architecture decisions, and the canonical file map. Do not rely on this file alone.
2. **Never overwrite or update `AGENTS.md`** — that file belongs to Codex's workflow. Post-session doc sync goes there only when the user explicitly asks.
3. **Never edit toolchain scripts** (`tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`) without being asked. Codex owns those.
4. **Never touch skill files** (`pdv-doc-sync.skill`, `pdv-papyrus-ck.skill`, `skills/`) without being asked.
5. **Prefer scoped changes.** Edit only the files directly relevant to the task. Avoid touching unrelated docs or restructuring anything.
6. **Papyrus rules:** Before writing or modifying any `.psc` file, read the Papyrus guidance section in `AGENTS.md` and `references/PAPYRUS_KNOWLEDGE_INTAKE.md`. Do not invent APIs; compile-verified beats plausible.

---

## Where to Find What

| Need | Go to |
|------|-------|
| Current build status, open phases | `AGENTS.md` § "Current Build Status" |
| Architecture, ESP structure, data model | `AGENTS.md` § "Architecture Summary", `PDV_Architecture_v2.md` |
| Operating rules, doc hygiene, safety rules | `PDV_STANDARDS.md` (read §1 + §4 when in doubt) |
| Dev environment, build order, naming conventions | `PDV_MOD_SETUP.md` |
| Papyrus API rules, compiler chain | `AGENTS.md` § "Papyrus Guidance", `references/PAPYRUS_KNOWLEDGE_INTAKE.md` |
| In-game console commands | `PDV_SkyrimConsoleReference.md` |
| Deity/lore reference | `references/skyrim-deity-reference.jsx`, `references/tamriel-daily-worship-4e201.html` |
| Phase 4 design matrices | `references/phase4/` |
| Frozen source material | `archive/HOUSECARL_*.md`, `archive/Skyrim_Modding_Lessons*.md` |

---

## Project Summary

A Skyrim Special Edition mod called **PlayerDevotion** that tracks per-deity piety based on the player's race-authentic religious behaviour. Daily actions feed a `PDV.Piety` value per deity (StorageUtil-backed), which gates tiered blessings and neglect effects.

**Phases completed through `AGENTS.md`** — check that file for current status. As of the last Claude.md update: Phases 1–3 complete (StorageUtil model, mirror globals, Kyne proof slice, ActionRouter kill event slice). Phase 4 (origin system, stance taxonomy, boon grants) is next.

**Key constraint:** StorageUtil (PapyrusUtil SE) is the source of truth for all per-deity values. Mirror GlobalVariables (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) are write-only caches for vanilla CK Conditions. Never write directly to mirror globals; always go through `AwardPiety`/`RecomputeTier`.

---

## Naming Conventions (summary)

- `PDV_` prefix on all records
- `PDV__X` (double underscore) for internal/machinery records
- `PDV_GLO_` for mirror GlobalVariables; `PDV_GLO__X` for internal/system globals
- `PDV_Deity_[Name]` for concrete deity quests; `PDV_DeityBase` for the base class

Full taxonomy in `PDV_MOD_SETUP.md` § EditorID Prefix Convention.

---

## Coexistence with Codex

Claude and Codex can both work on this repo. The division of labour is up to the user, but the ground rules are:

- `AGENTS.md` → Codex's file. Claude reads it, does not write to it unless asked.
- `CLAUDE.md` → Claude's entry point. Can be updated by Claude when the user asks.
- Everything else → shared; coordinate via git branches and the decisions log in `AGENTS.md`.
