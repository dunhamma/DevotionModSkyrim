# PDV Codex Handoff -- Consolidated Build Pass (2026-06-14)

**For:** Codex (primary coding agent).
**Purpose:** Tie together two parallel offline streams that both feed the next ESP/manager build pass,
with the ordering + coordination points so nothing clobbers the other.
**Status of inputs:** consumed by the 2026-06-14 consolidated Codex build pass.
The live manager/codegen wave, first content-record wave, and Altmer
`ThalmorAlignment` bridge are built and read back. Runtime/manual proof remains
open. Read `AGENTS.md` first for current build status, then this.

The live manager `PDV__ManagerQuest.psc` lives at
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` (NOT repo-tracked; a generated artifact).
Compile = `node tools/pdv_compile.mjs --script PDV__ManagerQuest` (target 0/0). Gate =
`node tools/pdv_verify.mjs` (FAIL=0).

## Build closeout from consolidated pass

Built 2026-06-14:
- Manager safety backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\consolidated-build-pass\PDV__ManagerQuest.psc.20260614-143727.bak`.
- Held likes/dislikes codegen landed on the current deployed manager:
  `LIKES_DISLIKES_VERSION = 8`, `PRINCE_LD_VERSION = 3`,
  `LoadRowsForDeity` now emits 315 deity rows, and
  `LoadPrinceRowsForPath` now emits 160 Prince rows. The default verifier now
  hard-gates those generated bodies against the CSVs and checks that
  `GetLikesDislikesEventTypes` covers all 31 deity CSV event IDs; backup before
  that final splice:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\small-signal-verify-hardening\PDV__ManagerQuest.psc.20260614-172312.bak`.
- Voice follow-ups landed in `PDV__ManagerQuest.psc`: Nord scar wording,
  Khajiit posture display-label toasts, Rajhin/Alkosh top-left notices,
  Prisma toasts, and the Survey recent-events buffer.
- First content-record tranche authored through
  `references/authoring/PDV_ConsolidatedBuildPass_RecordWave.spec.json`: Nord
  offer/response messages, selected curse/champion/neglect records, and manager
  VMAD bindings.
- Altmer `PDV_RepTrack_ThalmorAlignment` is live as a Concordat mirror
  `PDV_ReputationTrack` with backing global, five state labels, manager
  property wiring, track FormList membership, and a track-backed no-arg
  `GetAltmerLorkhanFactionModifier()` using x0.75/x0.875/x1.0/x1.25/x1.5.
- Framework backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-145010.bak`.
- SEQ refreshed after the ESP write:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\PlayerDevotion_Framework.seq.20260614-045101.bak`.
- Proof boundary: compile/readback only. `PDV__ManagerQuest` compiled 0/0;
  `dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -- --check-rewards --rewards-spec .\references\authoring\PDV_ConsolidatedBuildPass_RecordWave.spec.json`
  passes as the durable readback gate for the first record wave and
  `ThalmorAlignment`; default `pdv_verify` is
  `FAIL=0, WARN=2, PASS=3038, INFO=43`; content verify is
  `FAIL=0, WARN=0, PASS=1080, INFO=4`. New-save Survey/likes-dislikes reload,
  feedback-surface, and Altmer alignment manual spot checks are still pending.
- Follow-up slice: `tools\pdv-phase20-race-author --check-rewards` now readbacks reward
  SPEL/MGEF packets as well as messages/reputation records: copy, magnitudes,
  conditions, regen AV archetypes, substrate slots, manager properties, and explicit
  creed-loss spell properties. It also supports `preserveAdditionalEffects`; Khajiit
  Baan Dar T3 uses this so its live capstone extra effect is preserved while the
  spec-owned stat effects are refreshed. All ten `PDV_{Race}RewardRecords.spec.json`
  files now pass tightened readback after a live framework refresh. Representative ESP
  backups: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-151135.bak`
  and final Khajiit backup
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-151753.bak`.
  Final SEQ backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\PlayerDevotion_Framework.seq.20260614-051820.bak`.
  Default gates remain `pdv_content_verify` `FAIL=0, WARN=0, PASS=1080, INFO=4`
  and `pdv_verify` `FAIL=0, WARN=2, TODO=0, PASS=2929, INFO=43`. Runtime/manual
  proof is still not claimed.
- Follow-up slice: Breton `KnightlyVowIntegrity` now has live manager-side
  persistent spell routing for the four record-backed creed-loss spells. The
  manager applies `PDV_SPEL_CreedLoss_Breton_VowIntegrity` in the strained band,
  `PDV_SPEL_CreedLoss_Breton_Excommunication` in the broken band,
  `PDV_SPEL_CreedLoss_Breton_ExposureRupture` at `WitchcraftExposure >= 100`,
  and the existing Druidic fork betrayal spell through the same helper. Manager
  backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\breton-creedloss-routing\PDV__ManagerQuest.psc.20260614-152113.bak`.
  Framework backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-152246.bak`.
  SEQ backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\PlayerDevotion_Framework.seq.20260614-052259.bak`.
  Proof is compile/readback only: `PDV__ManagerQuest` compile 0/0, Breton
  `--check-rewards` PASS, `pdv_content_verify` `FAIL=0, WARN=0, PASS=1080, INFO=4`,
  and `pdv_verify` `FAIL=0, WARN=2, TODO=0, PASS=2929, INFO=43`. Quest-stage
  breach routing, threshold notification text, and in-game Active Effects proof
  remain open.
- Follow-up slice: Imperial Concordat secondary modifiers are live/readback-clean.
  `tools\pdv-phase20-race-author` now supports spec-driven `deityTrackModifiers`
  with float-array VMAD write/readback. `PDV_ImperialRewardRecords.spec.json`
  wires `PDV_Deity_Arkay` and `PDV_Deity_Stendarr` to
  `PDV_RepTrack_ConcordatStanding`: Arkay
  `[1.0,1.0,1.0,0.85,0.85]`; Stendarr
  `[1.15,1.15,1.0,0.85,0.85]`. The deployed manager also has
  `GetImperialConcordatPressureForAction(actionKey)` and
  `ApplyImperialConcordatAction(actionKey, reason)` for the resolved eight-action
  table; the existing hidden Talos shrine route now uses `hidden_talos_shrine`
  and still applies `-15`. Manager backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\imperial-concordat-modifiers\PDV__ManagerQuest.psc.20260614-152707.bak`.
  Framework backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-153052.bak`.
  SEQ backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\PlayerDevotion_Framework.seq.20260614-053101.bak`
  (`changed=false`, `questCount=39`). Proof is compile/readback only: tool build
  0/0, manager compile 0/0, Imperial `--check-rewards` PASS, all ten reward
  specs PASS, `pdv_content_verify` `FAIL=0, WARN=0, PASS=1080, INFO=4`, and
  `pdv_verify` `FAIL=0, WARN=2, TODO=0, PASS=2929, INFO=43`. Exact source
  routing for the seven not-yet-live Concordat actions and runtime/manual
  multiplier proof remain open.
- Recheck cleanup: the earlier Redguard curse-state MESG body drift in
  `PDV_ConsolidatedBuildPass_RecordWave.spec.json` is closed. Re-authoring that
  spec produced framework backup
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\PlayerDevotion_Framework.esp.20260614-153521.bak`;
  SEQ refresh stayed `changed=false` with backup
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\PlayerDevotion_Framework.seq.20260614-053531.bak`.
  The consolidated record-wave `--check-rewards` now passes, with
  `pdv_content_verify` `FAIL=0, WARN=0, PASS=1080, INFO=4` and default
  `pdv_verify` `FAIL=0, WARN=2, TODO=0, PASS=2929, INFO=43`.
- Follow-up slice: Argonian Molag Bal DominationPressure is manager-live and
  compile/readback-clean. Molag Bal Argonian accessibility is confirmed by the
  all-Prince contract/readback state (`Argonian = Curse`) and live
  `PDV_DaedricPath_Molag` in `PDV_FLST_DaedricPaths_All`. No new manager
  property was needed: the deployed manager finds Molag through the existing
  path FormList, requires Argonian origin + vampire + Molag Seeker tier, writes
  `PDV.Curse.Argonian.DominationPressure`, and lets the existing Hist substrate
  posture resolver escalate Silenced to Corrupted(4). Manager backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\argonian-domination-pressure\PDV__ManagerQuest.psc.20260614-154229.bak`.
  `PDV_BetaContract.csv` row `BC-0714` now uses the live
  `PDV_DaedricPath_Molag` script name instead of the stale proposed
  `PDV_DaedricPath_MolagBal`, so regenerated completeness audit reports
  `PASS=337`, `GAP-REVIEW=77`, with `BC-0714` PASS. Proof is compile/readback
  only: `PDV__ManagerQuest` compile 0/0, Argonian reward-spec readback PASS,
  `pdv_completeness_audit` PASS, `pdv_content_verify` `FAIL=0, WARN=0,
  PASS=1080, INFO=4`, and default `pdv_verify` `FAIL=0, WARN=2, TODO=0,
  PASS=2929, INFO=43`. Runtime/manual proof of the posture transition remains
  open.

---

## The two streams

### Stream A -- Likes/dislikes enrichment + next-build-pass record spec (Claude, committed + pushed)
Commits on `origin/main`: `7814929` (enrichment + spec) and `f6bea65` (spec open-question resolution).
- **Likes/dislikes enriched to full two-sided coverage** (+188 rows; all 48 actors -- 32 deities + 16
  Princes -- now have authentic likes AND dislikes). Files:
  `references/authoring/PDV_DeityLikesDislikes.csv` (188->315) and `..._Princes_V2.csv` (99->160).
  These are INERT until the held codegen runs (below). See
  `references/authoring/PDV_DeityLikesDislikes_EnrichmentSummary_2026-06-14.md`.
- **Next-build-pass record spec** (8 race items: Altmer ThalmorAlignment, Breton vow, Orc Witnessed,
  Redguard Far Shores, Argonian Sithis T3, Dunmer layers, Orc oath-break, Imperial Concordat) with
  EditorIDs + exact magnitudes:
  `references/authoring/PDV_NextBuildPass_RecordSpec.md` (the spine
  `PDV_PreBetaRaceScalingSpine.md` points at it).

### Stream B -- Survey + D0 voice-conformance pass (parallel Claude session)
Plan: `references/authoring/PDV_VoiceConformancePass_Plan.md`. Owns the live `PDV__ManagerQuest.psc`
and `race-sheets/PDV_RaceContent_Manifest.md` right now.
- **DONE:** Survey `.psc` ports for ALL 10 races (componentized, manifest-sourced, compile 0/0, verify
  FAIL=0/PASS=2938, negative-grep clean). New manager helpers: `GetPublicTierBand`,
  `GetCurrentStandingBand`, `GetBosmerComplianceBand`.
- **CONSUMED BY THIS BUILD PASS:** the Nord/message/curse/champion/neglect first record wave,
  Altmer `ThalmorAlignment` record bridge, Nord cured-vampire-scar reword, and Khajiit Prisma
  posture-title label are now represented in the closeout above. Remaining work is runtime/manual
  proof and later ESP/source tranches from `PDV_NextBuildPass_RecordSpec.md`.

---

## Convergence points (where the streams MUST coordinate)

1. **Altmer ThalmorAlignment track.** Stream B's Altmer Survey base is currently an INTERIM Auri-El
   anchor and explicitly waits on this track ("the alignment-path base wires when ThalmorAlignment is
   built"). Stream A (record spec sec.1) defines the track. **Build the track per spec sec.1, THEN let
   Stream B swap the Altmer Survey base.** NOTE: sec.1 is a USER OVERRIDE of the locked Altmer doc --
   the track is the **Imperial Concordat mirror, -100..+100, 5-state** (not the 0-100/3-band the Altmer
   race doc still says). See memory `altmer-thalmoralignment-concordat-override`.

2. **Curse-state MESG records.** Stream A sec.5 specs the Argonian curse-state MESGs (BC-0642:
   `PDV_Msg_Argonian_CurseState_{VampireOnset,VampireCured,WerewolfOnset,WerewolfCured}` <- Nord
   `PDV_Msg_Nord_CurseState_*`). Stream B's remaining wave also does "curse-state MESG verify/conform"
   and owns the voice (curse-state = God-voice per `PDV_ContentDestinationMatrix`). **Author the
   Argonian curse MESGs ONCE, with Stream B's god-voice copy -- do not double-author.**

3. **Held likes/dislikes codegen writes the manager.** `tools/pdv_likesdislikes_gen.mjs` (emits
   `LoadRowsForDeity` from the deity CSV) and `tools/pdv_princeld_gen.mjs` (emits
   `LoadPrinceRowsForPath` from the Princes CSV) both SPLICE into `PDV__ManagerQuest.psc`. They were
   HELD precisely because Stream B owns the manager. **Run them AFTER Stream B's manager edits land and
   compile 0/0**, and confirm each splice replaces ONLY its target function body (no collateral on the
   Survey/helper edits).

---

## Recommended build sequence

1. **Stream B manager edits land + compile 0/0.** (Its Survey ports are already in; let its remaining
   manager-side `.psc` work settle so the manager is stable before codegen splices into it.)
2. **Run the held likes/dislikes codegen** onto the post-Stream-B manager:
   - `node tools/pdv_likesdislikes_gen.mjs` -> splice the emitted `LoadRowsForDeity` into the manager;
     bump `LIKES_DISLIKES_VERSION`.
   - `node tools/pdv_princeld_gen.mjs` -> splice `LoadPrinceRowsForPath`; bump `PRINCE_LD_VERSION`.
   - Recompile 0/0; prove on a FRESH save (existing saves reload via the version bump). This lights up
     the 188 enriched rows. 11 of them use not-yet-wired PENDING events (303/334/335/351) -- they stay
     inert until the router/receivers are extended (optional, separate).
3. **Author the Task-2 ESP records (Skyrim CLOSED)** per `PDV_NextBuildPass_RecordSpec.md` sec.1-sec.8,
   BY HAND. Coordinate the Altmer track (conv. 1) and Argonian curse MESGs (conv. 2) with Stream B.
   Then verify with the relevant `--check`/readback tools.
4. **Stream B swaps the Altmer Survey base** from interim Auri-El to the alignment-path base (track now
   exists).
5. **Reconcile `race-sheets/PDV_RaceDesign_Altmer.md`** to the Concordat-mirror ruling (the one
   spec-vs-locked-doc contradiction).
6. **Final gate:** compile 0/0, `pdv_verify` FAIL=0, readback/`--check` clean, manifest<->live parity
   (Stream B), in-game new-save spot-check.

---

## Guardrails (do not violate)

- **Idempotency:** every Task-2 magnitude goes in BY HAND. Do NOT run any cumulative/additive rebalance
  tool to apply them -- those double values on a 2nd write (memory `rebalance-tool-idempotency`).
- **Codegen ordering:** the two likes/dislikes generators write the manager; run them after Stream B,
  and verify the splice is surgical (only `LoadRowsForDeity` / `LoadPrinceRowsForPath`).
- **No double-authoring** of the Argonian curse MESGs or the Altmer track across streams.
- **Actor-name fidelity:** the likes/dislikes `actor` strings are exact-matched to the runtime
  `DeityName` set (`ldName ==` in `LoadRowsForDeity`); do not rename. Princes keep the `Daedric:` prefix.
- **Princes V2 gate:** every Prince row is `stanceGate = PathOpen` (deepen-an-open-path only) and writes
  the separate `PDV.PLD.*` namespace -- never let Prince rows leak into the race-gated V1 `PDV.LD.*`.

---

## Deferred / open (genuinely build-pass, listed in record spec sec.10)

Signal-routing for each track action (which vanilla quest stage/dialogue emits it -- Altmer 6 actions,
Imperial 8 actions, Orc oath-break); FormID of the portable Far Shores token inventory object;
and runtime/manual proof of the shared below-20%-health hook.
The shared hook itself is no longer open: 2026-06-14 source/record/readback work added
`RoutePlayerBelowHealthGate`, `RoutePlayerBelowHealthSurvived`, Argonian Sithis T3 passive/burst records,
and Orc Code Holds base/devoted records. Everything
doc-answerable was already resolved into the spec (Imperial point table, Argonian creed-loss triple,
Breton breaches, Four Holds names). Breton threshold-crossing HUD notice text is also source/compile
closed as of the `breton-threshold-notices` backup; breach-source quest routing and runtime/manual proof
remain open.
