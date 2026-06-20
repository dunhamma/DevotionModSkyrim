# PDV Requiem-Regen Build -- Session Handoff (2026-06-20)

**Status:** Live build in progress. 8 races converted + committed; 5 work items
remain. **Commit:** `4116d6b` on branch `beta/feels-smoke-session`.

## Why this work exists

Requiem drives the BASE passive health-regen rate to ~0, so every PDV reward
authored as `HealRateMult`/`HealRate` ("Health Regeneration +X%") is unfelt
in-game (a 2026-06-20 audit found ~30 such effects, flat-Health-restore count =
ZERO). Fix = re-theme to felt, Requiem-proof forms. Full plan + per-effect list:
`references/authoring/PDV_RequiemRegenConversion_Plan.md`. The design rulings that
shaped the event-driven heals + other features:
`references/authoring/PDV_OpenDecisions_RulingMemo.md`. Reference memory:
`requiem-proof-heal-flat-restore-not-rate`, `reward-author-drops-capstone-save-on-converted-mgef`.

## The two conversion shapes (no author-tool change needed)

- **Always-on auras -> Fortify Health (max-HP).** Edit the reward spec effect:
  `actorValue: "HealRateMult"` -> `"Health"`, `magnitude` -> flat HP (tier rule:
  old <=5% ->10, <=14% ->20, else ->30), `effectName` -> `"Fortify Health"`, and
  rewrite the `playerFacingText` ("Health Regeneration +X%" -> "Maximum Health +N").
  The author tool emits a plain Value-Modifier on the `Health` AV with NO tool
  change. Batch helper: `scratch/requiem_convert.mjs` (dry-run; `--write`).
- **Event-driven heals -> scripted `playerRef.RestoreActorValue("Health", x)`**
  in Papyrus at a thematic moment (rest, near-death, home-prayer). Remove the
  swallowed effect from the spec; the heal lives in the manager. Requiem-proof
  because it adds real HP, not a rate.

## DONE this session (committed 4116d6b, readback PASS=1284 FAIL=1)

- **Imperial:** Civic T1/T2, Arkay T2/T3 -> Fortify Health. Mara T2/T3 ->
  Restoration-only + `HandleImperialMaraSleepMercy` (heal-on-rest, once/day,
  Devoted 25 / Champion 40).
- **Dunmer (11a):** `HandleDunmerSleepEvents` auto-declares the first interior
  bed-cell as the ancestor-home (`PDV.DunHome.DeclaredFormID`);
  `IsPlayerAtDunmerDeclaredHome` gates `HandleDunmerPlayerHomeBonus` (called from
  `HandleDunmerPortableShrinePrayer`), which now adds a flat Health pulse (15/30).
  Substrate Mid/High homeOrShrineOnly Magicka/Heal-regen removed (ResistMagic
  kept).
- **Argonian, Khajiit, Bosmer, Breton, Orc:** 20 always-on effects -> Fortify
  Health (via the batch script + an Argonian text fix). Khajiit BaanDar T3
  cheat-death save preserved (`preserveAdditionalEffects`).
- **Orc Code Holds:** `TryOrcCodeHolds` now restores flat Health (Seeker 40 /
  Devoted 60) mirroring the existing stamina restore.

All ESP writes backed up under
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\`.
Manager compiles 0/0.

## REMAINING work (next session)

1. **Nord conversion -- BLOCKED on a capstone-save re-attach.** Shor T1/T2/T3 are
   still `HealRateMult` (Nord spec reverted). Converting ANY Shor record makes the
   reward author re-create its MGEFs, which DROPS the "Sovngarde Looks Back"
   cheat-death save (`PDV_T3DailyLowHealthSaveEffect`) that rides the Shor T3
   `HealRateMult` MGEF. To convert: (a) edit Nord spec Shor effects -> Health +
   add `preserveAdditionalEffects: true` to Shor T3; (b) author Nord; (c) re-run
   the capstone-signature save attachment (CK-command-packet flow under
   `tools/creation-authoring/`, see `PDV_Phase2_CapstoneSignatures.md`) to re-bind
   the save to a surviving Shor T3 MGEF; (d) readback-confirm the capstone-script
   check passes. Low priority -- Nord's real heal IS the save (works); only the
   sole-effect Shor T1 dead-regen loses a conversion.
2. **Redguard Tu'whacca T2/T3 event-heals** (healing patron). Spec: remove the
   HealRateMult from Tu'whacca T2/T3. Papyrus: scripted Health restore at a
   Tu'whacca death-rite/restoration moment. NOTE: Redguard ALSO has the HoonDing
   rebuild (#3) and Ash'abah stigma (#4) -- do Redguard's spec/Papyrus together.
3. **HoonDing make-way rebuild (Decision 6a -- the big one).** Memo has the full
   spec. Retarget standard make-way (`SIGNAL_MAKE_WAY` 2501) from the mis-wired
   Forebear road-passage to curated dragon/named-boss/milestone/final-boss kills
   (hook `PDV_ActionRouter.HandleStoryKillActor`, `EVT_KILL_DRAGON=302`); route
   road-passage to the broad Forebear/AncestorSpine signal; drop the weekly cap
   (`PDV.Redguard.HoonDingMakeWayWeek`) for per-source dedup + daily soft-decay
   on dragons. Retire signal 2502; make the HoonDing Champion reward a once/day
   cheat-death save reusing `PDV_T3DailyLowHealthSaveEffect`. Combat-odds
   detection stays post-1.0.
4. **Ash'abah stigma (6b).** Text-only, mirror the proven Altmer crisis surfacing
   (`PDV_AltmerCrisisTrack` + `GetAltmerCrisisStateLabel`, dispatched in
   `GetPanelQuasiPatronTierLabel`) WITHOUT the piety penalty. Add a stigma posture
   surfaced via `GetRedguardSectLabel` + a marked-moment notice from
   `HandleRedguardAshAbahDeathDuty`.
5. **Breton "Vigilant attention" nod (7).** Text-only Survey/status surfacing at
   high `WitchcraftExposure`. (The full encounter is a separate spun-off V2 spike,
   task_54dd32a0 / `PDV_NotorietyHostileOnSight_Dossier.md`.)
6. **Daedric Namira boon** (cross-race, highest-magnitude swallowed positive).
   Convert with the Daedric records; consider heal-on-feed (lifesteal theme).

## Critical context / gotchas

- **LIVE MANAGER IS UNTRACKED + FRAGILE.** `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`
  (~14.6k lines) is NOT in git; a 2026-06-20 mod restore already wiped live-only
  edits once. ALWAYS `cp` it to a dated snapshot under
  `generated/live-devotion-snapshot/` after edits AND commit, so work survives a
  restore. This session's edits are snapshotted in `2026-06-20-requiem-build/`.
- **Reward author re-creates ALL of a record's MGEFs from the spec each run** ->
  drops any externally-attached script (capstone saves). Preserve via
  `preserveAdditionalEffects: true` ONLY if the script is on an EXTRA effect;
  it does NOT protect a replaced spec'd effect (the Nord blocker).
- **Always readback after a reward author** and grep for `\[FAIL\]` + capstone
  scripts. Baseline is `PASS=1284 FAIL=1`; the 1 FAIL = pre-existing unrelated
  `PDV_GreenPact_KID.ini` missing -- IGNORE it, it is not ours.
- **Live-manager line numbers shift as you edit** -- re-grep/re-read the target
  region before each Edit (the harness rejects edits whose read is stale).
- **Magnitudes are PROVISIONAL** -- tune in-game under an actual Requiem list
  (the load-bearing proof a regen conversion can't get from readback: HP bar moves).

## Toolchain (exact invocations)

- Author a race: `dotnet run --project tools/pdv-phase20-race-author/PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --rewards-spec references/authoring/PDV_<Race>RewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"` (run `--dry-run` first; auto-`.bak`).
- Readback: `node ./tools/pdv_phase2_reward_readback_audit.mjs`
- Compile manager: `node ./tools/pdv_compile.mjs --script PDV__ManagerQuest`
- Verify: `node ./tools/pdv_verify.mjs` ; gate: `node ./tools/pdv_beta_readiness_audit.mjs --strict`
- ESP path: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp` (Anvil instance,
  profile "Devotion Dev"). houseCARL writes patches, NOT Devotion.esp.

## After remaining builds

Re-snapshot the live manager + commit. Then the genuinely-open in-game pole is
unchanged: manual beta-feel for Dunmer + Imperial + Nord packets + Orc life-mode
runtime (run-sheets in `references/authoring/PDV_RunSheet_*`), then re-prove the
converted-race stacks under Requiem (HP-bar proof), then `pdv_beta_readiness_audit
--strict`.
