# PDV 2.0 LEDGER module — runtime smoke runbook (GATE 0.5 runtime tier)

STATUS: LIVING (authored 2026-08-18). Owner-in-loop, MCM-driven. Proves the extracted
`PDV_DevotionLedger` (the piety / tier / patron economy) behaves at runtime as the
pre-extraction inline code did -- the runtime half of GATE 0.5 (static half already green:
compile 0/0 + independently-verified reconstruction parity, 0 logic changes).

Because the extraction is a strict pure move (bodies byte-identical modulo `Manager.` /
`LedgerRuntime.` qualification + 21 trivial accessor substitutions, independently verified),
the runtime tier's real job is to prove the **wiring is live** -- that the host QUST started
and both refs resolved. This matters MORE for LEDGER than for FAVOR: the deployed manager
makes ~1,460 `LedgerRuntime.X` calls and the piety CORE routes through the new ledger, so a
None `LedgerRuntime` doesn't just no-op a niche feature -- it breaks earning piety entirely.
If piety round-trips (earn -> accrue -> dawn-commit -> tier), parity holds.

## Preconditions (all confirmed on disk 2026-08-18)
- MO2 Anvil, profile 'Devotion Dev'; `Devotion-V3Dev` ENABLED, 1.5 `Devotion` DISABLED.
- `Devotion.esp` wired: host QUST `PDV_DevotionLedger` (`0x04071792`, StartGameEnabled),
  34 script properties filled -- `Manager`->`00C325` + the 33 forms (6 globals, ModePreset,
  AllDeities FLST, Necromancer/Warlock factions, 9 deity refs, 14 spells); manager
  `LedgerRuntime`->`071792`. Readback clean; `check_errors` = 0 dangling / 0 missing masters.
- Fresh SEQ deployed (`Devotion-V3Dev/SEQ/Devotion.seq`, 44 SGE quests incl. the host quest).
- All 7 `.pex` recompiled + deployed to V3Dev (0 err / 0 warn).
- **NOT save-safe: a NEW GAME is required** -- the host quest starts at game-start via SEQ;
  an old save never started it, so the manager's `LedgerRuntime` would resolve to a
  never-started quest. (Same "new SGE quest needs a fresh save" rule as every prior host.)

## Key identifiers (front-loaded)
- Dev unlock (console): `set PDV_GLO_DebugLevel to 3` (>=1 shows dev tabs; 3 also raises
  Papyrus trace). `set PDV_GLO_DebugLevel to 0` hides them.
- MCM **Player** tab -> **"Patron"** line (`GetPlayerMcmPatronLine`) and **"Standing"** line
  (`GetPlayerMcmStandingLine`) = the liveness indicators.
- MCM **Debug** tab -> **"Patron state"** (`GetPatronStateLabel`), **"Active piety"**
  (`GetActivePietyValue`) readouts; **"Apply target piety"** button (sets committed piety
  via `ForceSetPiety`) with its adjacent target-value control; **"Show piety map"** (message dump).
- StorageUtil keys the ledger owns (keyed on the deity Form): `PDV.Piety` (committed),
  `PDV.PietyToday` (per-day scratch); `PDV.Devotion.LastActTime` (None-global).
- Globals the ledger mirrors: `PDV_GLO_ActivePiety` (`0x0400945A`), `PDV_GLO_ActiveTier`
  (`0x0400945B`), `PDV_GLO_ActiveDeityIndex` (`0x0400945C`) -- watchable via `getglobalvalue`.
- Award path under test: `PDV_ActionRouter` / `PDV_EventBus` ->
  `PDV_Manager.LedgerRuntime.AwardPietyFromLikesDislikes(...)`.
- Papyrus log: `.../Skyrim Special Edition/Logs/Script/Papyrus.0.log`. A None-ref fault names
  `LedgerRuntime` or `PDV_DevotionLedger` -- the definitive failure tell.

## Recommended test character
A fresh character of any race that can quickly commit to a patron with an easy liked deed
(e.g. **Imperial** or **Nord** -> commit to a Divine whose likes are easy to trigger, such
as Mara/Arkay/Stendarr -- all now filled deity refs on the ledger). The point is to reach an
active patron and fire ONE liked signal.

## Procedure

### 0. Setup
1. Start a **new game**; reach free movement and let the startup/origin capture fire.
2. Console -> `set PDV_GLO_DebugLevel to 3` -> close console.
3. Confirm the ledger quest is running: console `sqv PDV_DevotionLedger` shows it running
   (state/stage present, not "not currently running").
4. Open MCM -> Devotion.

### A. Liveness (the core GATE-0.5 proof)
5. **Player** tab -> read the **"Patron"** and **"Standing"** lines.
   - PASS: they render values (pre-patron, expect "None"/no-patron text, NOT blank). Any
     non-blank render proves manager->`LedgerRuntime` AND the ledger's `Manager` backref both
     resolved (these helpers live on / route through the ledger now).
   - **FAIL**: line blank / MCM throws, or the Papyrus log shows a None-object call on
     `LedgerRuntime` -> the host quest didn't start (SEQ / not a new game) or the backref is
     unfilled. Stop and report.
6. **Debug** tab -> **"Active piety"** renders a number (0.0 pre-earn). Proves
   `GetActivePietyValue` reads through the ledger.

### B. Direct ledger write (fast wiring check)
7. Debug tab -> set the target-piety control, tap **"Apply target piety"**.
   - PASS: **"Active piety"** updates to the applied value; a tier/standing change surfaces if
     the value crosses a threshold. Exercises `ForceSetPiety` + `RecomputeTier` +
     `RefreshPatronMirrors` (the `PDV_GLO_Active*` globals move -- confirm with
     `getglobalvalue PDV_GLO_ActivePiety`).
   - **FAIL**: no change / None error -> ledger write path broken. Stop and report.

### C. Earn piety organically (the award round-trip)
8. Commit to a patron deity (via the game's commitment flow / an offer), then perform ONE
   deed that deity LIKES (the earning signal).
   - PASS: **"Active piety"** rises after the deed. This proves the full public path:
     `ScoreAction` -> `PDV_ActionRouter`/`PDV_EventBus` ->
     `PDV_Manager.LedgerRuntime.AwardPietyFromLikesDislikes` -> `AwardPietyInternal` ->
     `RunGainPipeline` -> `PDV.PietyToday`. A toast/Book-of-Days entry for the gain is the
     visible tell.
   - **FAIL**: deed fires (other feedback) but piety never moves, or the log shows a None
     `LedgerRuntime` call from ActionRouter/EventBus -> the external-caller rewire didn't
     resolve. Stop and report.

### D. Dawn consolidation (scratch -> committed -> tier)
9. Sleep/wait past **06:00** (`ProcessDawn` auto-fires at dawn; a multi-day skip fires once).
   - PASS: after dawn, the day's `PDV.PietyToday` folds into committed `PDV.Piety`; the
     Player-tab "Standing" and Debug "Active piety" reflect the consolidated total; a tier
     change surfaces if a threshold was crossed. Exercises `ProcessDawn` /
     `RunDawnConsolidateScratch` / `ApplyDecayToDeity` / `RecomputeTier` -- the Site-B
     post-cap path.
   - **FAIL**: dawn passes and committed piety never updates / a None error at dawn. Report.

## Verdict
GATE 0.5 runtime tier PASSES when: the Patron/Standing/Active-piety lines render (A), a direct
apply moves piety + globals (B), an organic liked deed accrues piety through
`Manager.LedgerRuntime.AwardPietyFromLikesDislikes` (C), and a dawn consolidates scratch into
committed piety with the right tier (D) -- with **no None-`LedgerRuntime` errors in the Papyrus
log** across the run. Record the earned-piety toast + the pre/post dawn "Active piety" values
as the golden observation.

## Cleanup
`set PDV_GLO_DebugLevel to 0` to hide the dev tabs. Flip the MO2 toggle back
(`Devotion` on / `Devotion-V3Dev` off) when you want the 1.5 line active elsewhere.

## Note on scope
This proves the LEDGER wiring + core economy round-trip. It does NOT exercise the deferred
gain-pipeline provider seam (curse/stigma/orc/imperial multipliers still run in the manager,
reached via `Manager.` calls -- unchanged behavior) -- that seam is built later with
ORIGIN/DAEDRIC (see `PDV_2_0_ProviderSeam_ExtractionSpec.md`).
