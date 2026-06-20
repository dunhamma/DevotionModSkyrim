# PDV Run-Sheet -- Orc Life-Mode Organic-Source Beta-Feel (Runtime Proof)

Status: DRAFT (no-deploy prep)
Created 2026-06-19
Provenance: read from references/authoring/PDV_BetaTestPacket_Orc.md; the orcLifeModeOrganicSources entry in references/authoring/PDV_Phase20_SourceFillApprovalLedger.json; the Orc block of references/authoring/PDV_Phase20_ManualEvidenceLedger.json; race-sheets/Race_Orc.md; references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md; and the MCM debug labels/constants confirmed in generated/live-devotion-snapshot/2026-06-15-final-polish/Scripts/Source/PDV_MCM.psc. Nothing here deploys; this only sequences the pending in-game proof.

---

## 0. What this run-sheet is for (and is NOT)

The Orc life-mode ORGANIC sources were BUILT 2026-06-19 as pure-Papyrus FormID/LCTN hooks (NO ESP write): `PlayerEvents.OnQuestStageChange` and `ActionRouter.HandleStoryChangeLocation` -> `EventBus.Route*` -> manager `Handle*` life-mode handlers, with quests registered by FormID in `RegisterOrcLifeModeQuestSources`. They compile 0 error / 0 warning and verify clean (default verify FAIL=0; `--strict-phase20-race-costing` introduced 0 new FAILs). What is PENDING is in-game RUNTIME PROOF.

In scope (the six BUILT organic sources, runtime proof pending):

- orc-stronghold-presence -- stronghold ARRIVAL = a Stronghold evidence day (NOT a major gate, NO forge reward for mere presence).
- orc-stronghold-bloodkin -- DA06 (The Cursed Tribe) stage 200 = INSTANT major-gate switch to Stronghold (reason `orc_cursed_tribe_resolved`).
- orc-city-dignity-thane -- named Thane of any of the nine holds (Favor250/252/253/254/255/256/257/258 + FreeformRiftenThane) at stage 200 = City evidence day.
- orc-city-self-made-community -- HousePurchase stage 10 (buying any of the five city homes) = City evidence day (the home is the thaneship reward / non-stronghold anchor).
- orc-legion-contract-pressure -- CW02A (Jagged Crown for the Empire) stage 200 = LegionExile evidence day.
- orc-legion-exile-burden -- CWFinale stage 500 GUARDED by `IsInFaction(CWImperialFaction)` = LegionExile capstone.
- The no-flip gate -- City is the default/fallback; a soft signal records an evidence day but flips the committed mode only on two mode-coded evidence days within seven (settled at dawn), with a three-day lock-in; a lapsed non-City mode demotes back to City.

Out of scope (do NOT chase these here): Malacath book route (`RouteOrcMalacathConduct`, covered by PDV_BetaTestPacket_Orc.md); the QASmoke 70-73/75 proof activators (covered by PDV_Phase20_OrcProofPlacement_Runbook.md); Code Holds survival beat; Four Holds organic arrival emitters; Witnessed tranche; oath-break (route 74). The QASmoke activators prove route WIRING; this run-sheet proves the ORGANIC sources fire from real gameplay outside QASmoke.

Honest gap carried from the source ledger: `city-quality-labor` has NO clean vanilla named-commission / quality-labor quest stage and is intentionally left unwired. City is covered by dignity (Thane x9) + self-made-community (home x5). Do not treat the absence of a quality-labor hook as a FAIL.

Promotion gate (from the manifest `runtimePromotionGate`): prove at least one Stronghold beat AND at least one City or Legion/Exile parity beat, outside QASmoke. Until that is recorded, the Orc race verdict stays "Fail - runtime/manual proof deferred".

---

## 1. Preflight

1. Use a DISPOSABLE save. PDV state inits only on a NEW save (or `coc qasmoke`). For organic location/quest proof you want a real walkable world, so prefer a fresh Orc character or a clean disposable save you do not mind discarding.
2. In MO2, UNCHECK "Devotion - Living Deities Test" before launching (per the Orc packet cross-cutting reminders).
3. Confirm the freshly-compiled 2026-06-19 build is the one loading: `PDV__ManagerQuest.pex`, `PDV_EventBus.pex`, `PDV_ActionRouter.pex`, `PDV_PlayerEvents.pex` current. (Live source-of-truth is the untracked live Scripts/Source dir, not the dated repo snapshots, which lag the 2026-06-19 wiring.)
4. Seed origin and debug verbosity (seeding-only -- not proof):
   ```text
   set PDV_GLO_OriginRace to 8
   set PDV_GLO_DebugLevel to 2
   ```
   Origin index 8 = Orc (`ORIGIN_ORC`). Every life-mode hook is origin-gated on `GetOriginRaceValue()==8`.
5. Know the MCM Debug dev page controls you will use (all SEEDING-ONLY, never proof):
   - "Orc -> City" / "Orc -> Stronghold" / "Orc -> Legion-Exile" -- these call `DebugSetOrcLifeMode(ORC_LIFE_MODE_CITY / _STRONGHOLD / _LEGION_EXILE)`. The MCM's own info text says: "Forces the Orc life mode so its mode-gated Malacath reward becomes testable. Then force piety and Run Dawn." Forcing a mode is a SEED, it is NOT evidence that an organic source fired.
   - "Run dawn pass" -- consolidates scratch (`EvaluateOrcLifeModeAtDawn` runs at dawn). Use this to settle accumulated evidence days when you do not want to sleep a full in-game day. Auto-dawn also fires on a natural day rollover.
   - Debug seeding is MCM-driven. The user does NOT use `cqf`. Standard `set` / `coc` are allowed; in-game debug/seeding goes through the MCM Debug dev page.
6. Papyrus log path for markers: `Logs\Script\Papyrus.0.log`. A fresh Skyrim launch rotates the log; capture the excerpt before relaunching.

Console signal-fire reference (only needed for the optional QASmoke cross-checks, NOT for the organic proofs in this sheet): PDV `PDV_REFR_*Signal` objects are invisible in `coc qasmoke`; fire by RefID with `prid XX<refid>` then `activate player`, where XX is the 2-hex plugin prefix taken from `help "HoonDing" 0` (a NAMED blessing -- `help` on the nameless activators fails). Orc signal RefIDs (framework ESP): Stronghold `071027`, City `071028`, Legion `071029`, SelfMade `07102A`. These are QASmoke route-wiring surfaces and are OUT OF SCOPE for the organic-source proof below; listed only so a tester does not confuse them with the organic hooks.

---

## 2. Known gotchas (read before you start)

- coc skips location triggers. `OnStoryChangeLocation` does NOT fire on `coc`. Every stronghold-arrival proof in this sheet MUST be reached by walking in through a load door or by fast-travel, never by `coc`. This is called out explicitly in the source manifest ("coc skips OnStoryChangeLocation -- enter strongholds via load door / fast-travel").
- Forcing a mode in MCM is not proof. `DebugSetOrcLifeMode` writes the committed mode directly. It proves the reward stack, not that an organic source moved the state. Seed-then-prove must keep these separate: an organic check must show the state/evidence MOVING from the gameplay event, with the log marker, not from the MCM button.
- No instant flip on a single soft signal. The committed life mode does not flip on one stronghold arrival, one Thane, one home, or one CW milestone. That is BY DESIGN (the old build flipped instantly; the gate now requires two mode-coded evidence days within seven, settled at dawn, with a three-day lock-in). A single-signal non-flip is a PASS for the no-flip gate, not a failure of the hook.
- DA06 is the exception. The Blood-Kin crisis (DA06 stage 200) is an INSTANT major-gate switch to Stronghold (`orc_cursed_tribe_resolved`). It should NOT wait for the 2-of-7 accumulation. Broad Malacath piety for DA06 is awarded separately by the existing `RouteOrcMalacathConduct` on the same stage -- watch for NO double-award on the life-mode side.
- One-shot guards. Most quest-stage sources are one-shot lifetime (`orc_da06_bloodkin`, `orc_city_home`, `orc_cw02a_jagged_crown`, `orc_cwfinale_imperial_stage_500`) or one-shot per quest form (`orc_city_thane_stage_200`). Stronghold presence is once/dawn via `PDV.Signal.OrcStrongholdPresence`. Re-firing a consumed source the same day/life is expected to be silent -- that is the anti-farm guard, not a miss.
- Imperial-side guard on the capstone. CWFinale stage 500 only counts when `IsInFaction(CWImperialFaction)` is true. A Stormcloak finale must NOT fire it. Membership here is a disambiguating GUARD on a real service completion, not a trigger.
- Excluded look-alikes must stay silent: CW01A (Legion membership join alone), CW02B (Stormcloak Jagged Crown), Hearthfire land/plot building (vs. city home purchase), ordinary city presence, raw crafting, generic combat, mining, vendor sales, brawls, random stronghold proximity short of arrival.
- Known editorial copy gap (not a blocker). The Orc Survey still opens with dev-language ("Malacath watches the code through City life") and can leak the raw life-mode enum; this is tracked as task #10 / the all-race Survey rewrite and is NOT a sole FAIL for `surveyStatusClarity`.

---

## 3. Ordered evidence checklist (seven manual-evidence slots)

Each slot is labeled route/runtime (the engine moved state + emitted a marker), manual-acceptance (a human judges feel/clarity), or seeding-only (setup, never proof). Work them in order. Within slot 1, do 1A..1E in sequence so the no-flip gate accumulation reads cleanly.

### Slot 1 -- immersiveHookProof  [route/runtime]  (currently: pending)

Prove the six organic sources fire from real gameplay outside QASmoke. This is the load-bearing slot for the promotion gate.

GENERAL WATCH for every sub-step: open `Logs\Script\Papyrus.0.log` after the action and look for the documented manager trace string; check the MCM/Survey life-mode readout for the committed mode and any "evidence day" movement; watch the top-left for any notice. Where an exact log-marker string is not reproduced verbatim in the readable repo snapshot (the 2026-06-19 handlers post-date the snapshot), the route names below come from the SourceFillApprovalLedger and the manager trace strings come from the OrcProofPlacement runbook; confirm the precise string in the live `Papyrus.0.log` at test time and record what actually printed.

1A. Stronghold ARRIVAL = evidence day (no flip, no reward)  [route/runtime]
- Seed: origin 8, DebugLevel 2 (from Preflight). Confirm starting committed mode is City (default).
- Action: travel to one of the four Orc strongholds -- Dushnikh Yal (`DushnikhYalLocation` 019171), Mor Khazgur (`MorKhazgurLocation` 01927C), Narzulbur (`NarzulburLocation` 019282), or Largashbur (`LargashburLocation` 019263). WALK IN through the load door or fast-travel. Do NOT `coc` in.
- Where to stand: cross the location boundary so the story location-change fires (`ActionRouter.HandleStoryChangeLocation -> Manager.HandleOrcLocationChange -> HandleOrcStrongholdPresence`).
- Watch: log for the stronghold-presence route + an evidence-day record (`PDV.Signal.OrcStrongholdPresence`, once/dawn); Survey/MCM life mode stays City.
- PASS criterion: a Stronghold EVIDENCE day is recorded AND the committed mode stays City on this single arrival (no instant flip, no forge reward for mere presence). Re-entering the same day is silent (once/dawn guard).

1B. DA06 Blood-Kin = INSTANT Stronghold gate  [route/runtime]
- Seed: progress The Cursed Tribe (DA06 03B681) to stage 200 in normal play (resolve it at Largashbur). If seeding the stage directly, set DA06 to 200 via the MCM/console as a seed, then confirm the stage-change event routes.
- Action / route: `PlayerEvents.OnQuestStageChange -> EventBus.RouteOrcBloodKinCrisis -> Manager.HandleOrcBloodKinCrisis`.
- Watch: log marker for the Blood-Kin crisis route with reason `orc_cursed_tribe_resolved`; committed life mode flips to Stronghold IMMEDIATELY (not waiting for 2-of-7). Confirm the broad Malacath piety from DA06 is the existing `RouteOrcMalacathConduct` award and that the life-mode side does NOT double-award.
- PASS criterion: committed mode = Stronghold on this single terminal-stage event; one-shot guard `orc_da06_bloodkin` consumed; no double piety award on the life-mode path. Non-terminal DA06 progress and generic stronghold proximity do NOT fire it.

1C. City dignity -- nine-hold Thane = City evidence day  [route/runtime]
- Seed: complete a hold's thaneship quest to stage 200: any of Favor250 (0A2C86), Favor252 (0A2C9B), Favor253 (0A2C9E), Favor254 (0A2CA6), Favor255 (0A34CE), Favor256 (0A34D4), Favor257 (0A34D7), Favor258 (0A34DE), or FreeformRiftenThane (065BDF). Seed the stage if not earning it organically.
- Action / route: `OnQuestStageChange -> EventBus.RouteOrcCityDignity -> Manager.HandleOrcCityDignity`. Manager trace per runbook: `Orc City dignity routed`.
- Watch: log for the City-dignity route + a City evidence day; one-shot-per-quest guard `orc_city_thane_stage_200`.
- PASS criterion: a City EVIDENCE day is recorded for a named Thane completion AND the committed mode does NOT flip off City on this single signal. Favors/quests short of thaneship and ordinary city presence stay silent.

1D. Self-made community -- first city home = City evidence day  [route/runtime]
- Seed: buy a city home so HousePurchase (0A7B33) sets stage 10 -- Breezehome, Proudspire, Honeyside, Vlindrel Hall, or Hjerim.
- Action / route: `OnQuestStageChange -> EventBus.RouteOrcSelfMadeCommunity -> Manager.HandleOrcSelfMadeCommunity`. Manager trace per runbook: `Orc self-made community routed`.
- Watch: log for the self-made route + a City evidence day; one-shot lifetime guard `orc_city_home` (first home is the anchor beat).
- PASS criterion: a City EVIDENCE day records on the first city-home purchase; subsequent home purchases are silent. Hearthfire land/plot building does NOT fire it.

1E. Legion / Exile service = LegionExile evidence day + Imperial-guarded capstone  [route/runtime]
- Seed (contract pressure): bring CW02A (02D75C, Jagged Crown for the Empire) to stage 200.
- Seed (capstone): win the Civil War on the Imperial side so CWFinale (0D1444) hits stage 500 while `IsInFaction(CWImperialFaction 02BF9A)`.
- Action / route: both go `OnQuestStageChange -> EventBus.RouteOrcLegionService -> Manager.HandleOrcLegionService`. Manager trace per runbook: `Orc Legion or exile service routed`.
- Watch: log for the Legion-service route on CW02A 200 (one-shot `orc_cw02a_jagged_crown`) and on the Imperial CWFinale 500 (one-shot `orc_cwfinale_imperial_stage_500`, marked capstone). Confirm CW01A (membership alone), CW02B (Stormcloak Jagged Crown), and a Stormcloak finale all stay SILENT.
- PASS criterion: LegionExile evidence day records on CW02A 200; the Imperial-side CWFinale 500 fires the capstone while the Stormcloak path does not; excluded look-alikes silent.

SLOT 1 PASS criterion (the promotion gate): at least one Stronghold beat (1A or 1B) AND at least one City or Legion/Exile parity beat (1C/1D or 1E) proven outside QASmoke, with log markers and state/evidence movement recorded. Until then, slot 1 stays pending.

### Slot 2 -- wrongOriginRejection  [route/runtime]  (already evidence-recorded 2026-06-18; re-confirm on the new build)

- Seed: `set PDV_GLO_OriginRace to 7` (non-Orc).
- Action: repeat a representative organic trigger from slot 1 (e.g. arrive a stronghold via load door; or set a seeded Thane/CW02A stage).
- Watch: every Orc life-mode hook early-returns on the origin guard (`GetOriginRaceValue()==8`); no Stronghold/City/Legion-Exile/self-made-community state moves; no Survey movement; no log route for an Orc handler.
- Restore: `set PDV_GLO_OriginRace to 8` afterward.
- PASS criterion: nothing in the Orc life-mode state moves on a non-Orc origin.

### Slot 3 -- genericHookRejection  [route/runtime]  (already evidence-recorded 2026-06-18; re-confirm on the new build)

- Seed: origin 8.
- Action: attempt 2-3 representative REJECTED hooks: raw crafting / smithing, generic combat kills, ore mining, vendor sales, a brawl, ordinary (non-stronghold) city presence, CW01A Legion membership join alone, and CW02B (Stormcloak Jagged Crown).
- Watch: no Orc life-mode evidence day, no committed-mode movement, no Survey movement, no life-mode route in the log.
- PASS criterion: every rejected surface stays silent. (Note: byte-identical Malacath generic-combat kill rows ship live and are route/state-clean by precedent -- they belong to the Malacath piety layer, NOT the life-mode track.)

### Slot 4 -- surveyStatusClarity  [manual-acceptance]  (already evidence-recorded; re-read after slot 1)

- Action: after slot 1, open Survey / MCM status.
- Watch: the readout should explain the committed life mode, dignity/service posture, craft-quality context, and recent mode evidence, in Orc race language.
- PASS criterion (acceptance): a tester can tell which mode is committed and why. KNOWN editorial gap -- Survey opens with dev-language and may leak the raw life-mode enum (task #10 / all-race Survey rewrite); record it as a noted gap, NOT a sole FAIL.

### Slot 5 -- stackSnapshot  [manual-acceptance]  (currently: pending -- blocked on slot 1)

- Seed (only to read a specific mode's stack): force a mode with the MCM "Orc -> ..." button + force piety + Run dawn pass. Label this SEED, not proof.
- Action: open Active Effects / reward readout for the committed mode.
- Watch: exactly one life-mode reward family is active for the committed mode (Stronghold forge build vs. City/Legion-Exile edge build); layers match the committed mode -- mode, Malacath layer, craft/context caps, community recognition, curse modifier. Magnitudes are shared with task #9 (reward rebalance).
- PASS criterion (acceptance): the active stack matches the committed mode with no cross-mode bleed. This slot stays pending until the City/Legion edge build is runtime-reachable via slot 1 (Stronghold-side read was acceptable 2026-06-18; full mode-stack snapshot deferred until life-mode runtime proof lands).

### Slot 6 -- assetStatus  [manual-acceptance / readback]  (already evidence-recorded)

- Action: confirm the in-scope organic hooks use only existing surfaces.
- Watch: pure-Papyrus FormID/LCTN hooks, NO ESP write; reuse existing spell/message/notification surfaces; no new custom mesh.
- PASS criterion: no new asset required. If any in-scope hook is found to need a new mesh, NAME the missing asset before any implementation.

### Slot 7 -- manualFeelNote  [manual-acceptance]  (currently: pending -- blocked on slot 1)

- Action: after slot 1, judge the felt shape of the modes.
- Watch: the three modes read as authored SOCIAL CIRCUMSTANCE, not as a different theology; DA06 Blood-Kin feels like a MAJOR beat (instant gate); soft signals (arrival, Thane, home, CW milestone) feel like they ACCUMULATE toward a switch rather than flipping instantly; City and Legion/Exile dignity can compete with Stronghold craft/combat without becoming generic smithing.
- PASS criterion (acceptance): the mode feel matches Race_Orc.md ("how fully can you live inside the code?"). This stays pending until City/Legion modes are runtime-reachable via slot 1.

---

## 4. Record results here

Tester fills STATUS only as: pending / evidence-recorded / not-applicable. There is deliberately NO pass/complete at the slot level. The Orc race verdict stays "Fail - runtime/manual proof deferred" until in-game runtime proof is recorded and the maintainer promotes it.

| # | Slot | Proof type | Marker / surface to capture | STATUS (tester fills) |
|---|------|-----------|------------------------------|------------------------|
| 1A | immersiveHookProof -- stronghold arrival | route/runtime | stronghold-presence route + Stronghold evidence day (once/dawn); mode stays City | pending |
| 1B | immersiveHookProof -- DA06 Blood-Kin | route/runtime | Blood-Kin crisis route, reason `orc_cursed_tribe_resolved`; INSTANT Stronghold; no double-award | pending |
| 1C | immersiveHookProof -- nine-hold Thane | route/runtime | `Orc City dignity routed`; City evidence day; `orc_city_thane_stage_200` | pending |
| 1D | immersiveHookProof -- self-made home | route/runtime | `Orc self-made community routed`; City evidence day; `orc_city_home` one-shot | pending |
| 1E | immersiveHookProof -- Legion/Exile service | route/runtime | `Orc Legion or exile service routed`; CW02A 200 + Imperial-guarded CWFinale 500; CW01A/CW02B/Stormcloak silent | pending |
| 1 | immersiveHookProof -- promotion gate | route/runtime | >=1 Stronghold beat AND >=1 City or Legion/Exile beat, outside QASmoke | pending |
| 2 | wrongOriginRejection | route/runtime | origin 7 -> origin-guard early-return; nothing moves; restore 8 | evidence-recorded (re-confirm on 2026-06-19 build) |
| 3 | genericHookRejection | route/runtime | raw craft / combat / mining / vendor / brawl / city presence / CW01A / CW02B all silent | evidence-recorded (re-confirm on 2026-06-19 build) |
| 4 | surveyStatusClarity | manual-acceptance | Survey reads mode + posture in race language; dev-language/enum gap noted (task #10) | evidence-recorded |
| 5 | stackSnapshot | manual-acceptance | one life-mode reward family active; layers match committed mode (magnitudes = task #9) | pending |
| 6 | assetStatus | manual-acceptance / readback | pure-Papyrus, no ESP write, existing surfaces, no new mesh | evidence-recorded |
| 7 | manualFeelNote | manual-acceptance | modes read as social circumstance; DA06 major; soft signals accumulate | pending |

No-deploy note: this run-sheet only sequences the pending proof. Nothing here deploys. The Orc race verdict remains "Fail - runtime/manual proof deferred" until the runtime/manual evidence above is recorded in-game and the maintainer promotes it.
