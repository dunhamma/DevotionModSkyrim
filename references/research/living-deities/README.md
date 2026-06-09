# PlayerDevotion — "Living Deities" Research Program

A multi-session, evidence-gated research program to evolve PDV from a *"piety
accountant"* into a **"Living Deities" engine**: gods (Aedra **and** the 16
Daedric Princes, first-class in every aspect) that behave as reactive,
data-driven agents with a **mood** the world reflects.

> Full charter / approved plan lives in the session plan file; this README is the
> in-repo anchor so each session can resume without it.

## North star

A "living" god **DOES** things the player notices through four **output channels**:
- **A1 Demands & tithes** — time-boxed asks (material / act / pilgrimage / abstinence); Daedra → *pact obligation*.
- **A2 Omens & portents** — dreams, weather, animal behavior, ambient audio, vision flashes.
- **A3 Interventions / miracles** — clutch save, divine luck, blessing surge, smite/curse, rivalry strike.
- **A4 Mood-scaled boons** — existing tier blessings scale/shift with the deity's current mood band.

Mood is driven by four **drivers**:
- **B1 Recent behavior** — short-term EWMA layered over long-term piety *(the one genuinely new runtime state)*.
- **B2 World context** — time / weather / lunar phase / location / season / holiday as a mood multiplier.
- **B3 Inter-deity politics** — jealousy / rivalry (surface the existing silent rivalry ledger).
- **B4 Authored arcs** — curated relationship beats, text/diegetic only for V1.

Relationship shape: **layered** — a deep bilateral bond with the active patron
**plus** a lightweight pantheon-wide political backdrop.

## Constraints

- **Data-driven & authorable** — CSV/JSON pipelines, not opaque C++.
- **Lore-respectful, liberties allowed** — not hardcore TES purist.
- Tech footprint **open** (SKSE C++, soft-dep frameworks, etc.) **except AI
  dialogue/voice is post-V1 and out of scope here.**
- Modlist compatibility is *not* a hard non-negotiable (heavier footprints OK
  where payoff justifies).
- **Not a V1-ship requirement** — the engine is forward research; the mod's
  release V1 does not depend on it (owner, this session). Engine build phases are
  labelled **LD-P1 / LD-P2 / Backlog** to avoid collision with the mod's "V1".
- **Diegetic-UI dependency stance** (settled this session): bundle *your* content
  (Prisma view files, `DevotionPrismaBridge.dll`, OAR animation files); the Prisma
  and OAR **engines are hard-installed dependencies, never bundled** (per-runtime
  breakage, not a license bar — Prisma's license actually permits redistribution).
  The summonable panel is **soft-with-fallback** (MCM/MessageBox when Prisma absent).
  See `prisma-ui-reference.md`.

## Milestone roadmap

| # | Milestone | Artifact | Status |
|---|---|---|---|
| **M0** | Substrate Seam Map — what we already have | `00_substrate_seam_map.md` | ✅ COMPLETE |
| **M1** | Competitor & inspiration teardowns | `01_teardown_dossier.md` + `01_mechanism_bank.md` | ✅ COMPLETE |
| **M2** | Mechanism shortlist & scoring + mood-model decision | `02_mechanism_shortlist.md` + `02_mood_model.md` | ✅ COMPLETE |
| **M3** | Feasibility (source-grounded; no CK/runtime here) | `03_feasibility.md` | ✅ COMPLETE |
| **M4** | Living Deities architecture doc | `04_living_deities_architecture.md` + `04_future_buckets_backlog.md` | ✅ DRAFT |
| ref | Prisma UI reference notes | `prisma-ui-reference.md` | ✅ |

**Owner ratification checkpoint reached (post-M2).** Per "automate until you need
me," the program continued through M4 on documented sensible defaults. The open
calls are consolidated in **`DECISIONS_PENDING.md`** — none blocking, all reversible.
**Nothing has been implemented; this is research only.**

## M0 headline result

The engine is **~70% REUSE/EXTEND** over PDV's existing machinery. The only
genuinely new runtime state is the **B1 mood EWMA**; the only new persistence
namespace is the **A1 demand window** (`PDV.Demand.<deity>.*`). Everything else
is authoring + one-new-`eventClass` extensions on the dawn pass, the
`DiegeticDirector`, the rivalry ledger, and the contextual-favor surfacing
ladder. One open question — the true V1 dependency tier of Prisma/OAR — is
deferred to M2. See `00_substrate_seam_map.md`.

## Working model

Opus 4.8 drives design/judgment (M1–M4 and review); mechanical/bulk passes
(cataloging, CSV authoring) are delegated to model-specific subagents (M0 was
authored by a Sonnet subagent under Opus review).
