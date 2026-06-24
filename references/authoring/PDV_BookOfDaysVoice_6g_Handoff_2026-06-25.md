# 6g Book-of-Days Bespoke Voice — Imperial / Altmer (Codex Handoff, 2026-06-25)

## Context
Open-item **6g** (gap #8) in `PDV_SessionHandoff_2026-06-25.md`. The Spine Stack Score's
`text_voice` dim scores **Imperial 2** and **Altmer 2** (vs 3 for the flagship races) — they read
in a generic templated voice on part of the Book-of-Days surface. This handoff gives them bespoke
turn-of-the-path journal voice, lifting `text_voice` toward 3.

## Current state (verified 2026-06-25 — do NOT redo the done part)
The Book-of-Days voice has TWO surfaces, and they are at different states for Imperial/Altmer:
1. **Mode-change line** — `PDV__ManagerQuest.BuildModeChangeLine` (~line 8084). **ALREADY bespoke**
   for Altmer + Imperial (and Breton). The stale `; Flagship races (Nord/Dunmer/Khajiit)...` comment
   above it should be corrected. **Leave the lines; do not rewrite.**
2. **Per-transition journal line** — `PDV_DiegeticDirector.ResolveJournalLine` (~line 329). **This is
   the gap.** Only Khajiit (`ResolveKhajiitJournalLine`) and Dunmer (`ResolveDunmerJournalLine`) have
   bespoke implementations; every other race (incl. Imperial/Altmer) falls through to the GENERIC
   templates (`curse.onset`/`curse.cure`/`tier.reach` at ~337-345, "" for other tone keys).

## The work
Add `ResolveImperialJournalLine(String toneKey)` and `ResolveAltmerJournalLine(String toneKey)` in
`PDV_DiegeticDirector.psc`, mirroring the Khajiit/Dunmer functions, and route them at the top of
`ResolveJournalLine` (the existing `if originRace == 6 ... if originRace == 5 ...` ladder — add
`ORIGIN_IMPERIAL` and `ORIGIN_ALTMER`). Cover the tone keys the flagship functions cover:
`substrate.act`, `tier.reach`, `curse.onset`, `curse.cure`, `neglect.drop` (+ `emergence.onset` if
the race has an emergence surface). Keep the generic templates as the final fallback for unhandled
keys (return "").

## Voice guidance (run `pdv-player-copy` guardrails; ASCII-only, short for the notification lane)
- **Imperial** — civic Divines, lawful order, oaths, public duty under private conscience; the
  Concordat tension is the backdrop. (e.g. `tier.reach` → the oaths recognize you; `curse.onset` →
  the civic communion falters.) Match the registry's Imperial framing.
- **Altmer** — Auri-El dawn foundation, coherence, the old line / discipline; not a multi-god blend.
  (e.g. `substrate.act` → the dawn-line steadies; `tier.reach` → coherence holds.) Werewolf is a
  hard halt, vampire is terminal/exile — reflect that in the curse tones.

## Serialize + Verify
Touches `PDV_DiegeticDirector.psc` (+ a one-line comment fix in the manager). Light surface.
- `node tools/pdv_compile.mjs --script PDV_DiegeticDirector` 0/0 → `node tools/pdv_verify.mjs` FAIL=0.
- Update the `text_voice` dim for Imperial/Altmer in `PDV_SpineStackRegistry.csv` (2→3 with a note
  citing the bespoke journal voice), then `node tools/pdv_spine_stack_score.mjs` to re-derive.
- `node tools/pdv_integrity_harness.mjs` PASS; confirm no generic fallback leaks for Imperial/Altmer
  on the transition surface in a trace (the bespoke line, not the template, should emit).
- In-voice copy proof (read the lines aloud against the race's theology) stays with the owner.
