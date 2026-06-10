# PDV Session Thread Continuation - Living Deities Build + Research (2026-06-10)

Branch: `claude/zen-allen-xrjqf8` (CURRENT worktree
`.claude/worktrees/zen-allen-build`; pushed through `15cc8cf`).
Everything below is ISOLATED investigatory work - the live Devotion mod is
untouched except inert data (`PDV_LivingDeities.json`) and NEW, disabled
MO2 mod folders.

> **Worktree note (2026-06-10):** the earlier worktree
> `.claude/worktrees/loving-wilbur-212b77` was de-registered from git during a
> planning gap (its `.git` link was pruned; the folder is now harmless orphaned
> files on disk - safe to delete). Work continued on a fresh worktree
> `.claude/worktrees/zen-allen-build` on the same branch; nothing was lost
> (branch local == remote == `15cc8cf`). The live `PDV__ManagerQuest.psc` was
> verified byte-identical (412314 bytes) throughout - live source never changed.

## What this session did (commit order)
1. `ed0da14` merge of main `2e665b7` (hybrid faucet wiring) + `0b8fde3`
   reconciliation: Kyne 313/343 receivers landed readback-clean (runtime proof
   pending); Kyne still has ZERO quest-matrix rows (being authored on a
   separate branch - reconcile when it lands).
2. `ff76503` **LD-P1 Block B Papyrus slice** - full engine authored in
   `research/living-deities/src/` (six scripts, compile 0/0, NOT deployed):
   curse-gated `PDV_Deity_Hircine`, mood EWMA in the dawn consolidate loop,
   demand offer/fulfill/expire on the two real signal layers, band mirror,
   band boons, mood-gated clutch, dream omens. See
   `research/living-deities/README.md` (incl. promote procedure).
3. `cd9f722` quantified tunables: demand swing = alpha*100 (one ideal day;
   Kyne 12 / Hircine 22), 7d cooldown = commitment precedent, dream cadence
   math, 11-race verified great-beast set.
4. `9c0e698` **complete test ESP setup** - tool `tools/pdv-living-deities-author`
   (--author/--check, both PASS) emitted MO2 mod
   `D:\Wabbajack\modlists\Anvil\mods\Devotion - Living Deities Test`
   (ESP + SEQ + six pex + JSON). Smoke procedure + counted checks:
   `research/living-deities/TEST_ESP.md`.
5. `37df51c` four parallel research dossiers (each charter + feasibility +
   architecture, traced to live source): LD-P2 layer
   (`references/research/living-deities/05_ld_p2_*.md`), divine debt
   (`references/research/divine-debt/`), relic resonance
   (`references/research/relic-resonance/`), holy days
   (`references/research/holy-days/`).
6. `2b2e0ee` four white-space dossiers (the four areas with zero Skyrim-faith-mod
   precedent): A3 interventions (`06_*`), B2 world context (`07_*`), B3 deity
   politics (`08_*`), B4 authored arcs (`09_*`).
7. `15cc8cf` **V1-candidate slices.** Slice A = the mood EWMA + band-cross toast
   teaser, BUILT + machine-proven + isolated (`research/living-deities/teaser-src/`
   compile 0/0; tool `tools/pdv-mood-teaser-author` --author/--check PASS; mod
   `Devotion - Living Deities - Mood Teaser`; smoke = `MOOD_TEASER.md`). Slice B
   (rivalry expansion) = BLOCKED by the B0 finding below; no inert wiring written.

## V1-candidate outcomes (2026-06-10)
- **Mood teaser (Slice A): DONE, awaits rig smoke.** Net-new "the gods notice you"
  layer; additive, reversible, degrades to silence. V1 merge is an owner call
  AFTER smoke (adds `PDV.Mood.*` save state).
- **Rivalry (Slice B): DEFERRED, not dormant.** CORRECTION to an earlier session
  claim: Talos->Auri-El rivalry is LIVE + in-game-proven (AGENTS.md 775/788).
  B0 finding (`RIVALRY_B0_FINDING.md`): rivalry fires ONLY via
  `AwardCuratedSignal -> AwardPietyInternal`; quest-reaction gains
  (`ApplyQuestReactionPiety` -> `AdjustFloatValue`) bypass it, so wiring
  `RivalDeities[]` on Boethiah/Molag Bal/Malacath would be inert. Real expansion
  = per-deity Papyrus+CK (Talos-style curated-signal pipeline; Molag Bal also
  needs a deity face). Lore decision recorded; defer until that infra exists.

## Load-bearing finding (verified)
`PDV_DiegeticDirector.psc` EXISTS in live source (14KB: Dispatch /
SetBodyMark / EmitPrayerAnim, D1Enabled-gated). The LD-P1 "not built" claims
were stale and are now corrected in 03/04. LD-P2 mechanism 4 = routing, not
greenfield.

## Resume point: in-game smokes (need the gaming rig) - TWO independent mods
Both are disable-able and require a NEW GAME / `coc qasmoke` (VMAD props bake at
first init). `set PDV_GLO_DebugLevel to 2` for `[PDV]` traces.
1. **Mood teaser (smallest, V1 candidate):** enable **Devotion - Living Deities
   - Mood Teaser** + tick `PDV_MoodTeaserTest.esp`. Checks in `MOOD_TEASER.md`:
   mood drifts/persists, band-cross toast once, decay on idle, disable-reverts.
2. **Full LD-P1 engine:** enable **Devotion - Living Deities Test** + tick
   `PDV_LivingDeitiesTest.esp`. Counted checks in `TEST_ESP.md` (mood persist,
   cross-once, demand offer/fulfill/expire once, boon swap no-stack, clutch gate,
   Hircine curse gate, disable-mod reversion).

## Open threads
- Kyne quest-matrix rows: separate branch; merge + flip the HANDOFF prereq.
- 313/343 receiver RUNTIME proof: carry in the same smoke.
- Four dossiers await owner ratification; each ends with explicit owner
  decisions. LD-P2 charter hard-blocks on the LD-P1 smoke passing.
- Backlog buckets 1/3/4/6/7/8/10/11 remain un-researched. OWNER CORRECTION
  (2026-06-10): bucket RESEARCH is independent of LD-P1 proof - dossiers can
  be produced any time (same fan-out pattern as today's four); only
  IMPLEMENTATION chains on the LD-P1 smoke. Do not gate research on it.
- Cosmetic: test ESP masters written Dawnguard-before-Skyrim (engine-fine,
  xEdit nags; fix at promote).
