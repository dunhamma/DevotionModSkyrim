# PDV Session Thread Continuation - Living Deities Build + Research (2026-06-10)

Branch: `claude/zen-allen-xrjqf8` (worktree
`.claude/worktrees/loving-wilbur-212b77`; pushed through `37df51c`).
Everything below is ISOLATED investigatory work - the live Devotion mod is
untouched except inert data (`PDV_LivingDeities.json`) and a NEW, disabled
MO2 mod folder.

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

## Load-bearing finding (verified)
`PDV_DiegeticDirector.psc` EXISTS in live source (14KB: Dispatch /
SetBodyMark / EmitPrayerAnim, D1Enabled-gated). The LD-P1 "not built" claims
were stale and are now corrected in 03/04. LD-P2 mechanism 4 = routing, not
greenfield.

## Resume point: the in-game smoke (needs the gaming rig)
1. MO2 (Anvil): F5, enable mod **Devotion - Living Deities Test** (after
   Devotion), tick `PDV_LivingDeitiesTest.esp`.
2. **NEW GAME or main-menu `coc qasmoke` only** (VMAD bake: existing saves
   leave the three new manager props None -> shipped behavior).
3. `set PDV_GLO_DebugLevel to 2`; run the counted checks in
   `research/living-deities/TEST_ESP.md` (mood persist, cross-once,
   demand offer/fulfill/expire once, boon swap no-stack, clutch gate,
   Hircine curse gate, disable-mod reversion).

## Open threads
- Kyne quest-matrix rows: separate branch; merge + flip the HANDOFF prereq.
- 313/343 receiver RUNTIME proof: carry in the same smoke.
- Four dossiers await owner ratification; each ends with explicit owner
  decisions. LD-P2 charter hard-blocks on the LD-P1 smoke passing.
- Backlog buckets 1/3/4/6/7/8/10/11 remain un-researched (deliberately held).
- Cosmetic: test ESP masters written Dawnguard-before-Skyrim (engine-fine,
  xEdit nags; fix at promote).
