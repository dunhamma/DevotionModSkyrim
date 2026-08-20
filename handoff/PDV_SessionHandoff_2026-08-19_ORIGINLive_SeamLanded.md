# Session handoff -- 2026-08-19: ORIGIN live, provider seam landed

Resume pointer for the 2.0 rebuild. The blow-by-blow for the day is in
`PDV_SessionHandoff_2026-08-19_LEDGERlive_ORIGINextracted.md` (nine dated update sections);
this file is the state you actually need to start from.

All work is committed on **`feature/v3-origin-extraction`**. Nothing pushed.

---

## Where the rebuild stands: 6 of 8 modules wired

| Module | Script | State |
|---|---|---|
| RULES | `PDV_DevotionRules` | done |
| QUESTREACTION | `PDV_QuestReactionRuntime` | done |
| FAVOR | `PDV_ContextualFavorRuntime` | done, runtime-verified |
| LEDGER | `PDV_DevotionLedger` | done, runtime-verified |
| **ORIGIN** | `PDV_OriginRuntimeBase` + **10 race adapters** | **wired, runtime-confirmed** |
| **DAEDRIC** | `PDV_DaedricRuntime` | **wired, deployed** |
| PRISMA | `PDV_PrismaPresenter` | not started (115 fns, 27 race tests) |
| RECOGNITION | `PDV_RecognitionRuntime` | not started (31 fns, 4 race tests) |
| MANAGER | `PDV__ManagerQuest` | stays as orchestration host |

Plus a new cross-module base: **`PDV_GainModifierProvider`**.

**Deployed to `Devotion-V3Dev`:** every one of the 114 PDV sources has a `.pex`. ESP is
659,851 bytes; SEQ carries 55 start-game-enabled quests.

---

## What landed today

- **MCM debug crash fixed** (`be572f0a`) -- Daedric page rebalanced to 37/45 rows, Status
  roster capped, 5 dead `RunPatternAction` arms removed.
- **Audit suite un-blinded** (`afe23e9b`) -- `familySourceText()` added to
  `tools/lib/pdv_symbol_home.mjs`; 24 red gates / 100 FAILs down to 12 / 18.
- **ORIGIN adapter interface** (`311796d2`, corrected `3e32f235`, `6f56d15a`) -- 21 virtuals,
  measured from 341 verbs over 707 call sites.
- **DAEDRIC extracted** (`3d77709b`) -- 47 fns; manager 444 -> 397 EndFunction blocks, exactly 47.
- **10 race adapters built and reconciled** (`80192e4f`) -- 606 lane functions.
- **13 base survivors re-routed** (`5bac22ba`) through the adapter interface.
- **ORIGIN wired** -- 10 host QUSTs `071794`-`07179D` in `ORIGIN_*` index order,
  `PDV_FLST_OriginAdapters` = `07179E`, manager property 511 -> 512, SEQ 45 -> 55.
- **Two runtime bugs fixed** (`fbea836e`, `a9c268c1`) -- see Traps below.
- **Provider seam** (`43af34a0`) -- LEDGER no longer names the modules that scale gains.

---

## Traps discovered today -- read these before touching the same ground

1. **A Papyrus call on a None reference does NOT halt.** It logs and returns the type default.
   `0` is the Int default and `ORIGIN_NORD == 0`, so an unbound `OriginRuntime` made the
   startup gate read "Nord" instead of "unknown" and fired the popup before RaceMenu. A
   sentinel `< 0` guard is unsafe behind any optional reference.
2. **`pdv_compile.mjs --all` builds from a fixed script list.** It compiled 102 of 114 and
   still exited 0, silently skipping the base, DAEDRIC and all ten adapters. **After any
   deploy, verify every `.psc` has a `.pex`** -- do not trust the PASS count. Compile new
   modules explicitly with repeated `--script`.
3. **Origin race is captured LATE.** `PDV_GLO_OriginRace` defaults to -1 (ESP `02C5C6`) and is
   written only by `PDV_Origin.InitializeOrigin()`, which MainQuest defers to a player
   load/sleep ingress; the FIRST Nord reading is discarded as provisional because RaceMenu
   reports Nord before the player commits. Anything that needs the race must be change-driven,
   not once-at-OnInit.
4. **The region map does not know about split modules.** ORIGIN's ten adapters and
   `PDV_GainModifierProvider` are absent from `PDV_2_0RegionMap.json`, so every resolver-aware
   gate was blind to them (the substrate audit saw 14 of 34 relevant calls). Worked around in
   `familySourceText` by also walking module *sibling* scripts, matched on the module STEM
   (base is `...RuntimeBase`, adapters are `...Runtime_<Race>`). The region map itself is still
   stale.
5. **Bash heredocs here silently eat one backslash level.** Never write a regex through one --
   use the Edit/Write tool, or build backslashes with `String.fromCharCode(92)`.
6. **Insert dispatch arms INSIDE the if/elseIf chain**, before its closing `endIf`, not before
   the trailing `return` -- otherwise "mismatched input 'elseIf' expecting ENDFUNCTION". Cost
   two separate rounds today.

---

## Proof state -- be precise about this

**Runtime-confirmed by the owner in game:** the startup popup no longer fires before race
selection, and the adapter binds to the actual character's race.

**NOT exercised:** the deeper checks in `PDV_2_0_ORIGIN_Gate05_RuntimeTest.md` -- A3 race
behaviour, A4 the Khajiit moon-observation token path, A5 sleep routing, B1/B2 the Imperial
concordat query. **8 of the 10 adapters have had no runtime at all.** Same shape, so low risk,
not zero.

**Newly worth testing after the seam:** it changes how every piety gain is scaled. A Khajiit
under a curse exercises the award-phase curse factor; an Orc at dawn with Malacath as patron
exercises the dawn-phase life-mode factor.

**Static:** full compile 102 PASS / 0 FAIL plus the 13 new modules; `pdv_substrate_pacing_audit`
exit 0 with self-test 13/13; `housecarl_check_errors` on Devotion.esp 0/0/0; masters
`Skyrim.esm, Dawnguard.esm, HearthFires.esm, Dragonborn.esm`, game master first.

---

## Decisions already locked (do not re-litigate)

D1 `PDV_OriginRuntimeBase` owns the gain provider, not `PDV_Origin` (a one-shot bootstrap
quest). D2 decay routes through `Providers[]` with the other two sites. D3 Breton stigma
branch splits to the Breton adapter -- **still pending**. D4 MCM debug pages only. D6 DAEDRIC
before PRISMA/RECOGNITION. D7 wire light, consolidate properties later. D8 PRISMA gets a
presentation hook designed before extraction. D9 FAVOR replaces rather than suppresses. D10
mechanical work unattended, design and ESP writes supervised.

Two rulings worth keeping visible:
- **Neglect is THREE pools** (patron / race-culture / broad lane). The race lane IS the culture
  lane. Nord has no race-culture predicate, so `IsRaceLaneNeglected()` is deliberately
  un-overridden for Nord.
- **The split has ZERO exclusions.** An earlier claim that four parameterised lookups could not
  move was wrong -- every caller passes the player's own race, so the `Int origin` parameter is
  vestigial.

---

## Next, in the order I would take it

1. **RECOGNITION, then PRISMA** -- the last two modules. Recommend swapping the documented
   order: RECOGNITION *feeds* PRISMA (`GetNpcRecognitionPanelJson` is concatenated into the
   panel payload at `PDV__ManagerQuest.psc:2318`), so producer-first means that call site is
   remapped once instead of twice, and it is 31 functions against 115. PRISMA also needs its
   presentation hook (D8) designed first.
2. **The ORIGIN base cleanup** -- 477 external call sites still name lane functions through the
   base-typed reference (manager 225, ledger 123, EventBus 96, ActionRouter 17, six smaller
   files 16). They work today via override dispatch, so this is clarity, not correctness --
   but the base still holds all 608 originals as unreachable duplicates with shadowed script
   vars, which is a trap for anyone who edits the base copy thinking it is live.
3. **Breton stigma split (D3)** -- now unblocked, the Breton adapter exists.
4. **MCM by-module rebuild**, then the race-switch toggle scoped in the plan (its one required
   fix, the hardcoded `EnsureKhajiitObserveMoonsPower`, is already done).
5. **Deeper runtime coverage** on the eight unproven adapters.
6. **Housekeeping:** region map does not list the adapters or the provider base; ORIGIN's 557
   property declarations are still manager-side; `PDV_FeltEffectRegistry.json` regenerates with
   a large diff and deserves its own look.

---

## Environment notes

- MO2 profile **`Devotion Dev`** with mod folder **`Devotion-V3Dev`** enabled is the correct
  2.0 configuration. The profile is the dev environment; the enabled mod FOLDER picks the
  version. This is not a mismatch.
- Backups from today: `Devotion.esp.pre-daedric-backup`, `Devotion.esp.pre-origin-backup`,
  and matching `SEQ/Devotion.seq.pre-*-backup`.
- The stray MO2 folders `houseCARL - houseCARL_SEQ_00{2,3}` are build artefacts, not enabled,
  and can be ignored or deleted.
