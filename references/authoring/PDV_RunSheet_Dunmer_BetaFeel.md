# PDV Dunmer Beta-Feel In-Game Run-Sheet

Status: DRAFT (no-deploy prep)
Created 2026-06-19
Provenance: Drafted from references/authoring/PDV_BetaTestPacket_Dunmer.md,
race-sheets/Race_Dunmer.md, the Dunmer block of
references/authoring/PDV_Phase20_ManualEvidenceLedger.json,
references/authoring/PDV_BetaTestPacket_INDEX.md, and the live 2026-06-15
final-polish .psc source (PDV_MCM.psc, PDV__ManagerQuest.psc,
PDV_DunmerAncestralUrn.psc) for exact MCM button labels, Survey posture labels,
and log markers. Nothing here deploys or changes the live build.

---

## What this run-sheet is

A single ordered in-game pass that fills the seven Phase 20 manual-evidence
slots for Dunmer. It is a tester checklist, not a spec change.

**Dunmer has no Phase 20 route command.** The ledger records
`runtimeProofCommand: "No Phase 20 route command yet; audit manually through
Survey/status and stack review."` So unlike most races, the verdict here is
assembled by hand from:

- Survey Devotion text and the MCM Status page,
- the in-inventory / Active-Effects stack at two seed states,
- the Papyrus log markers below (route/runtime arm only).

There is a narrow accepted-route proof that already exists (P2 book route to
Reclamation focus 0/1 via `pdv_phase20_runtime_check.mjs --track p2-books --race
dunmer --strict-manager`, accepted 2026-06-04). That is **accepted-route proof
only**; it does not close wrong-origin, generic-source silence, Survey clarity,
stack snapshot, or feel. This run-sheet covers the rest.

### Proof-boundary key

Each check below is tagged:

- **[ROUTE/RUNTIME]** -- backed by a log marker or a deterministic state
  change; objective pass/fail.
- **[MANUAL-ACCEPTANCE]** -- tester reads fiction-voice text or a stack and
  judges it; subjective, recorded as the tester's acceptance.

Do not upgrade a MANUAL-ACCEPTANCE read into machine proof, and do not log a
FAIL on a PENDING route arm (outdoor shrine, Layer-2 werewolf 0.75x) unless
current repo evidence confirms the emitter is runnable.

---

## Preflight (do once, before slot 1)

1. In MO2, disable `Devotion - Living Deities Test` so its state does not
   contaminate inits.
2. Start a **disposable new save** (or `coc qasmoke` from a clean main menu).
   PDV state inits ONLY on a new save / `coc qasmoke`; old saves keep stale
   gate/curse/life-mode state.
3. Open the MCM. Player page -> Developer Options -> unlock the Status / Debug
   pages. The two debug pages are `Debug: State & Rewards` and
   `Debug: Daedric & Curse`.
4. Seed the Dunmer origin and a verbose debug level from console:

   ```text
   set PDV_GLO_OriginRace to 5
   set PDV_GLO_DebugLevel to 2
   ```

   Origin index `5` is Dunmer. DebugLevel 2 makes the route/runtime log markers
   below appear in `...\Logs\Script\Papyrus.0.log`.

5. Confirm seeding is MCM-driven. Do not use the CallQuestFunction console
   shortcut -- this user's Skyrim does not run it. Every "seed" step below is an MCM button press. Standard
   `set` / `coc` console is fine.

Plugin-prefix note (only needed if you fire a signal RefID by hand): read the
2-hex plugin prefix XX once off a NAMED Devotion blessing, e.g.
`help "HoonDing" 0`, take the first two hex digits of the returned `SPEL:`
FormID. Then `prid XX<refid>` + `activate player` (never bare `activate`). The
nameless `PDV_REFR_*Signal` activators have no Name, so `help` by EditorID fails
on them. This run-sheet does not require a hand-fired RefID -- the MCM substrate
buttons cover the Dunmer hooks -- but the recipe is here if you need it.

---

## Ordered checklist

### Slot 1 -- assetStatus  [MANUAL-ACCEPTANCE]

Front-load this so a missing asset blocks nothing downstream.

- **Ledger expectation:** every immersive hook contract has explicit asset
  status; current contract target is **no required new custom mesh**.
- **Seed:** none.
- **Action / where to stand:** anywhere. Confirm the Dunmer ancestor hook is a
  usable **MISC inventory urn** (`PDV_MISC_DunmerAncestralUrn`, Dark Elf urn
  model, Miscellaneous section; fires `RouteDunmerPortableShrinePrayer` on
  `OnEquipped` when used from the inventory), not a placed worldspace mesh.
  The portable-shrine design is exactly "carry the infrastructure in exile" --
  no in-world ancestral tomb is required. (2026-07-04 remediation: the old
  model-less BOOK token crashed the book menu on read; migration removes it.
  An "Ancestral Urn" under Books is the regression -> FAIL.)
- **Watch:** that the prayer hook is reachable via the MCM `Dunmer ancestor
  prayer` button and the urn use, with no missing-mesh / red placeholder.
- **PASS:** Dunmer uses portable token + MCM substrate buttons + (PENDING)
  the three DLC2 Solstheim altar spells re-pointed to `PDV_MGEF_DunmerShrineCure`.
  No new custom mesh is required by any Dunmer hook. Record "no new mesh" or
  name the missing asset.

---

### Slot 2 -- wrongOriginRejection  [ROUTE/RUNTIME]

Proves a non-Dunmer origin cannot read ancestor/Reclamation state as native.

- **Ledger expectation:** "Non-Dunmer origin cannot read ancestor/Reclamation
  state as native."
- **Seed (console):**

  ```text
  set PDV_GLO_OriginRace to 4
  player.additem 0001B245 1
  ```

  Origin 4 is a non-Dunmer race; `0001B245` is `Book4RareInvocationofAzura`
  (an approved Azura source).
- **Action / where to stand:** read the Azura book normally from inventory.
- **Watch:** Survey Devotion -- it must NOT gain a native Dunmer ancestor /
  Reclamation layer. No Dunmer manager state, no reward, no Survey movement.
  In the log, the Dunmer Reclamation-focus route marker
  (`RouteDunmerReclamationFocus complete: 130 focus 0`) must NOT fire for this
  origin.
- **PASS:** zero native Dunmer layer movement from the wrong-origin book read.
- **Reset before next slot:** `set PDV_GLO_OriginRace to 5`.

---

### Slot 3 -- genericHookRejection  [ROUTE/RUNTIME]

Proves the anti-false-positive lever: generic acts do not move native Dunmer
layers.

- **Ledger expectation:** "Generic Daedric contact, shrine use, theft, murder,
  ash proximity, and tomb travel do not move native Dunmer layers by
  themselves."
- **Seed:** origin already 5 from slot 2 reset. No MCM seed.
- **Action / where to stand:** perform generic acts that an over-eager system
  might miscredit -- generic Daedric contact, a theft, a murder, ash proximity,
  a vanilla shrine activation, tomb travel. None of these is an approved Dunmer
  route source.
- **Watch:** Survey Devotion ancestor layer and Reclamation focus stay flat.
  No Dunmer route marker (`RouteDunmer...`) in the log from any of these
  generic acts.
- **PASS:** native Dunmer layers move ONLY when the exact owning source fires
  (the urn read / MCM prayer / approved book), never from a generic act.

### Shared Daedric Inn-Sleep Proof  [ROUTE/RUNTIME + MANUAL]

This is cross-race backend smoke, not Dunmer-native proof or deviation-price proof. It may be recorded once per build and referenced from the other race sheets.

1. MCM Debug -> `Debug: Daedric & Curse`; use `Selected Prince` to choose Sanguine or Namira.
2. Select `Reset Prince path`, then `Force Seeker`.
3. Sleep in a non-inn bed. Expected: no `PrinceV2: <Prince> event 314 deepen -0.25`, and `Show Prince summary` does not drop from sleep.
4. Sleep in an inn. Expected: `PrinceV2: <Prince> event 315 deepen -0.25`, and the summary piety drops by the inn-sleep dislike.
5. Positive control: choose Vaermina, Peryite, or Azura, `Reset Prince path`, `Force Seeker`, then sleep in a non-inn bed. Expected: `event 314` still gives the positive sleep credit.
6. Record the Papyrus `PrinceV2` lines and before/after `Show Prince summary` piety.

---

### Slot 4 -- immersiveHookProof  [ROUTE/RUNTIME, plus PENDING arms]

The positive proof that the Dunmer immersive hooks route outside QASmoke.

- **Ledger expectation:** "Prove Dunmer portable ash-prayer/home rite,
  Reclamation focus, and deviation-price immersive hooks outside QASmoke, with
  stack audit and rejected generic Daedric behavior."

**4a. Reclamation focus route (accepted-route, re-confirm) [ROUTE/RUNTIME]**

- **Seed (console):**

  ```text
  player.additem 0001B245 1
  player.additem 0001B233 1
  ```

  `0001B245` = Azura source, `0001B233` = `Book4RareBoethiahsGlory` (Boethiah
  source).
- **Action:** read one Azura book, then one Boethiah book.
- **Watch (log):**

  ```text
  RouteDunmerReclamationFocus complete: 130 focus 0
  RouteDunmerReclamationFocus complete: 130 focus 1
  ```

  Focus 0 = Azura, focus 1 = Boethiah -- proving route 130 fires AND focus
  distinguishes patron. Top-left notice / proven toast only, no forced Prisma
  panel.
- **PASS:** both markers present with the right focus index.

**4b. Portable ash-prayer + home rite [ROUTE/RUNTIME]**

- **Seed (MCM):** Debug: State & Rewards -> press **`Dunmer ancestor prayer`**
  (records one portable-shrine ancestor prayer on the Dunmer substrate). For
  the home arm, press **`Dunmer home bonus`** (records one player-home ancestor
  bonus).
- **Action / where to stand:** the MCM buttons route directly; no walk-in is
  required for these substrate buttons. (If proving via the real urn instead,
  read the urn token from inventory.)
- **Watch:** Survey "Ancestor practice is ..." rises a tier across 2-3 prayers;
  the home bonus reads as an added home-space credit, not a separate path.
- **PASS:** prayer credits on the substrate and Survey reflects the rise.

**4c. Ancestor-layer curse silence (the signature consequence) [ROUTE/RUNTIME]**

This is the key Dunmer runtime lever and the build-pass test-2 path.

- **Seed (MCM):** with origin 5 / debug 2 already set, press
  **`Dunmer ancestor prayer`** 2-3x to raise practice a tier (note the Survey
  tier).
- **Action:** Debug: Daedric & Curse -> press **`Curse vampire`** (backend force).
- **Watch:** Survey / MCM curse posture reads
  `silent, the ancestors cannot reach you`. Press **`Dunmer ancestor prayer`**
  again -- practice does NOT rise, and the log shows
  `Dunmer ancestor layer silenced by curse posture (...)`. **This is the key
  check** (Layer 1 = 0x under vampire).
- **Then:** press **`Curse werewolf`** -> posture
  `strained, the beast pulls at the ancestors` (prayer now credits at half,
  still routes). Press **`Curse none`** -> posture `restored, but scarred`
  (prayer credits fully again).
- **PASS:** prayer is silent under vampire (0x) AND the four posture labels are
  correct: active / `silent, the ancestors cannot reach you` /
  `strained, the beast pulls at the ancestors` / `restored, but scarred`.
- **2026-07-04 note:** tester reported 4c passed. The werewolf Survey sentence
  showed awkward double-dash punctuation and the restored branch did not surface
  the literal `restored, but scarred` posture. Copy was changed afterward; the
  behavior pass stands, but the revised Survey copy needs one display retest.

**4d. Twilight window + outdoor Good-Daedra shrine [ROUTE/RUNTIME -- PASS]**

Source/readback-clean. Route proof passed on 2026-07-04: Papyrus.0.log showed
the dusk route marker for `dlc2_shrine_blessing_effect`. Player-facing display
passed after restart: the shrine showed the vanilla prayer line and the Prisma
Good Daedra toast.

- **Seed (console):** `set gamehour to 7` (inside the 06:00-09:00 dawn window;
  dusk is 18:00-21:00). Origin 5 / debug 2.
- **Action:** the DLC2 Solstheim Azura/Boethiah/Mephala altar spells now use
  `PDV_MGEF_DunmerShrineCure`. Console shortcut without the Solstheim trip:
  derive Dragonborn.esm's 2-hex load index (e.g. `help "Bend Will" 0`, a NAMED
  Dragonborn shout) then `player.cast 04 03BCFB player` (Azura). Real-shrine
  path: travel or **walk in via a load door / fast-travel** to the altar and
  activate it -- this is a location/story-adjacent hook, so **`coc` straight
  into the cell will NOT fire it**.
- **See:** in-window prayer toasts *"The Good Daedra hear the ash-prayer."*
  Out-of-window Dunmer prayer toasts *"The shrine is quiet in this hour."*
- **Watch (log):**

  ```text
  RouteDunmerOutdoorGoodDaedraShrine complete: dlc2_shrine_blessing_effect
  Dunmer Dawn twilight rite routed: ...
  ```

  A second activation in the same window/day logs `already recorded today`;
  outside the window (`set gamehour to 12`) -> no twilight-route award line.
- **PASS (when not PENDING):** twilight marker fires once-per-window; in-window
  second prayer does not award again; out-of-window does not award.
- **2026-07-04 route proof:** `Papyrus.0.log` line 125 showed
  `Dunmer Dusk twilight rite routed: eventbus_dlc2_shrine_blessing_effect`; line
  126 showed `RouteDunmerOutdoorGoodDaedraShrine complete:
  dlc2_shrine_blessing_effect`. The toast fix was later retested after restart
  and passed.

**4e. Deviation-price hook [ROUTE/RUNTIME -- RUNTIME PENDING]**

DA01 Black Star branch is now static/readback wired for the Dunmer deviation
price route. This is **DA01 stage 110 only**. DA02/sacrifice is not a
deviation-price source; DA02 remains a separate Reclamation/Boethiah focus
route. Do not count generic crime, cruelty, twilight, magic, shrine visits,
ordinary Daedric contact, or artifact possession alone as deviation-price proof.

- **Seed:** Dunmer origin 5 / debug 2. Use a save that can complete DA01 through
  the Black Star branch. If using console for a route smoke, only do it on a
  DA01 test save where the quest is already in a valid running state.
- **Trigger:** complete DA01 through the Black Star branch so DA01 reaches stage
  110.
- **Watch (log):**

  ```text
  RouteDunmerDeviationPrice complete
  Dunmer deviation price routed: eventbus_131_po3_queststage_dunmer_da01_black_star
  ```

- **Expected behavior:** the active Reclamation receives the deviation penalty
  signal. Later declared-home sleep may renew the remembered deviation only
  after this first `PDV.Dunmer.DeviationPriceCount` exists.
- **PASS:** DA01 Black Star stage 110 produces both route markers and the
  deviation-price state/penalty behavior. Until this is observed in game, record
  the arm as RUNTIME PENDING, not DEFERRED.

---

### Slot 5 -- surveyStatusClarity  [MANUAL-ACCEPTANCE]

- **Ledger expectation:** "Survey/MCM explains active Reclamation focus, names
  what the standing band refers to, and only adds curse posture when cursed."
- **Seed:** use the state left by slot 4 (some ancestor practice, a chosen
  focus from the book reads). Optionally `Curse none` for a clean read.
- **Action:** open Survey Devotion and the MCM Status page.
- **Watch:** the text must explain, in fiction voice and without leaking route
  IDs or raw counters:
  - the active Reclamation focus (Azura / Boethiah / Mephala), or the broad
    "three Good Daedra answer together" state,
  - what the standing band refers to (for example, standing with the
    Reclamations),
  - curse posture only when cursed.
  Confirm the Survey "recent events" line lists the just-fired beat in fiction
  voice (e.g. "The Reclamations have answered a source you sought out.") with no
  route IDs or raw counters.
- **PASS:** the compact Survey is legible, fiction-voiced, and counter-free.

---

### Slot 6 -- stackSnapshot  [MANUAL-ACCEPTANCE]

- **Ledger expectation:** "Expected Reclamation build and edge deviation/curse
  build record ancestor substrate, active focus, silence/deviation, and
  suppressed generic Daedric stacking."
- **Seed -- two snapshots:**
  - **Snapshot A (expected Reclamation build):** origin 5, ancestor practice
    raised, one focus chosen (Azura or Boethiah from slot 4), `Curse none`.
  - **Snapshot B (edge deviation/curse build):** from A, press
    **`Curse vampire`** so the ancestor layer goes silent and the Good-Daedra
    path is what remains.
- **Action:** at each snapshot, open Active Effects (the magic-effect list) and
  the MCM Status page; record what is present.
- **Watch:** snapshot A shows the ancestor substrate + active focus reward layer.
  Snapshot B shows the silence/deviation state (ancestor layer inert under
  vampire) with the Good-Daedra layer still reachable, and NO generic Daedric
  stack accreted from generic acts.
- **PASS:** both snapshots match their descriptions; no suppressed-generic
  Daedric reward leaked into either stack.
- **Note:** reward-record existence is machine-verified elsewhere (readback
  1280/0). This snapshot proves the in-game stack SHAPE / suppression, not
  record existence.

---

## Home-Prayer Pulse (redesign 2026-06-20 -- build queued, test the NEW behavior)

The Dunmer home bonus is being rebuilt (ruling memo Decision 11a). The OLD
behavior was a passive, unconditional Magicka-Regen aura that (a) applied
everywhere, not just at home, and (b) is SWALLOWED under Requiem (a
HealRate/MagickaRate-style rate buff is +% of Requiem's near-zero base). DO NOT
test the old aura. The NEW behavior, to be built before the Dunmer packet's home
checks run:

- **Declared ancestor-home:** sleeping in a bed makes that cell your
  ancestor-space (cloned from the Argonian bed-of-choice; immediate, no settle
  clock), with a Dunmer-flavored declaration notice. Any first interior bed-cell,
  including an inn room, can become the V1 ancestor-home; there is no move-home
  prompt yet.
- **Home-prayer pulse:** praying with the portable urn AT your declared home
  fires the bigger progress step (HomeBonusDelta 8 vs PrayerDelta 5) plus a timed
  **Health** restoration -- authored as a flat Restore-Health (Value-Modifier on
  Health + Recover, or a scripted RestoreActorValue HoT), NOT a
  HealRate/HealRateMult rate buff, so it is FELT under Requiem. Praying anywhere
  else = base prayer only.
- **Always-on substrate** keeps only Magic Resistance (+3/+9/+20%); the
  Magicka-Regen line is removed from its text.

How to prove (route/runtime + manual-acceptance), under an ACTUAL Requiem list:
1. Sleep in a bed -> confirm the declaration notice; that cell is now your home.
2. Pray with the urn AT that home -> watch the HP bar actually move during the
   pulse (the load-bearing Requiem check) and confirm the bigger progress step.
3. Pray with the urn ELSEWHERE -> base prayer only, no pulse.
4. Magnitudes (+6%/+15% by tier, duration) are PROVISIONAL pending Dunmer row review.

Until this is built, record the home-bonus arm as DEFERRED (redesign queued), not
FAIL, in slots 5/6.

---

### Slot 7 -- manualFeelNote  [MANUAL-ACCEPTANCE]

- **Ledger expectation:** "Ancestor substrate stays interpretive/identity-heavy
  while the foreground Reclamation remains the loudest reward layer."
- **Seed:** the run as-played (no extra seed).
- **Action:** play / read across the run and form a judgment.
- **Watch:** the ancestor layer should feel quiet, identity-defining, and
  cumulative (always counting, never zero), while the chosen Reclamation focus
  is the loudest, most legible reward. The layers reinforce -- focus adds weight
  on top of ancestor, it does not compete.
- **PASS:** the tester writes a short feel note affirming the
  substrate-is-identity / Reclamation-is-foreground balance, or flags drift.

---

### Slot 8 -- Prisma Embedded Checks  [MANUAL-ACCEPTANCE]

- Accepted Reclamation book reads may produce a toast or top-left notice; they must not force the full Prisma panel.
- Manually open the Devotion panel after the Azura/Boethiah reads. It should be populated, focused, and close cleanly with ESC or the X.
- Chronicle / Book of Days should show readable source or dawn-digest text if that UI path emits for the beat; no blank entries.
- Ledger should show the Reclamation source row and any ancestor/substrate driver row created by the prayer test.
- During the shared Prisma U6/U7 pass, include the active-patron neglect recovery beat. Set patron piety to 0,
  run dawn, then award one patron signal, set piety to 15, and run dawn again. The recovery beat must be readable,
  must not force-open the full panel, and must not repeat the old lapse as a fresh neglect event.
- Under `Curse vampire`, Prisma may surface a posture/curse toast, but the manager state remains the proof source; do not count Prisma display as route proof.
- Save/load after snapshot A, reopen the panel, and confirm Survey/Active Effects/Prisma agree on the same focus and posture.

Prisma failures are UI failures unless the log marker, Survey state, or Active Effects stack is also wrong.

---

## Known gotchas

- **No route command for Dunmer.** The verdict is assembled by hand from
  Survey/status + stack + the log markers in slots 2-4. Do not wait for a
  `--track dunmer` runtime command -- the only checker arm is the accepted
  `--track p2-books --race dunmer --strict-manager` book-route proof.
- **State inits ONLY on a new save / `coc qasmoke`.** Disable
  `Devotion - Living Deities Test` first; old saves carry stale curse/gate
  state and will false-FAIL.
- **Seeding is MCM-driven, not CallQuestFunction.** Use the `Debug: State & Rewards` and
  `Debug: Daedric & Curse` pages. The Dunmer buttons are
  `Dunmer ancestor prayer`, `Dunmer home bonus`; curse buttons are
  `Curse none`, `Curse werewolf`, `Curse vampire` (and `Cycle curse origin` /
  `Apply curse origin` for the curse race-handler smoke). Standard `set` /
  `coc` console is allowed.
- **`coc` skips Story location-change triggers.** The outdoor DLC2 Good-Daedra
  shrine arm (slot 4d) needs a load-door entry or fast-travel, never a `coc`
  straight into the altar cell. The MCM substrate buttons and book reads are
  not location-gated and work anywhere.
- **Nameless signal activators.** If you ever fire a `PDV_REFR_*Signal` by
  hand, read XX off a NAMED blessing (`help "HoonDing" 0`) and use
  `prid XX<refid>` + `activate player`. `help` by EditorID fails on the
  nameless proof objects. Not required for this run-sheet.
- **Kill-credit caveat.** Any kill-based beat scores only the player's own
  killing blow (ATTR_DIRECT_PLAYER); an ally stealing the kill reads as a
  false-FAIL. (Not central to Dunmer, but relevant if a deviation arm ever
  lands.)
- **PENDING vs DEFERRED, not FAIL.** Slot 4d (outdoor shrine, twilight) is now
  passed for route/display. Layer-2 werewolf 0.75x remains runtime-PENDING.
  Slot 4e (deviation price) is DA01 Black Star stage-110 runtime-PENDING, not
  deferred. Record pending arms as pending, not as FAIL.
- **Not testable in V1:** Grey Quarter solidarity (the Windhelm Dunmer NPC
  whitelist) has no wired list -- no runnable step, omitted by design.

---

## Record results here

Fill one status per slot. Statuses: PASS / FAIL / PENDING (build-pass arm not
yet landed) / DEFERRED (no runnable step) / N/A.

| Slot | Boundary | Status field | Result |
|---|---|---|---|
| 1. assetStatus | manual-acceptance | no-new-mesh confirmed? | |
| 2. wrongOriginRejection | route/runtime | non-Dunmer origin moved native layer? (expect NO) | |
| 3. genericHookRejection | route/runtime | generic act moved native layer? (expect NO) | |
| Shared Daedric inn-sleep proof | route/runtime + manual | negative Prince inn-only sleep + positive 314 control | |
| 4a. immersiveHook -- Reclamation focus | route/runtime | focus 0 + focus 1 markers present? | PASS 2026-07-04 tester-reported |
| 4b. immersiveHook -- ash-prayer / home rite | route/runtime | prayer + home bonus credit + Survey rise? | PASS 2026-07-04 tester-reported through home bonus; toast copy changed afterward and needs one display retest |
| 4c. immersiveHook -- curse silence | route/runtime | vampire 0x silence + 4 posture labels? | PASS 2026-07-04 tester-reported; Survey copy changed afterward and needs one display retest |
| 4d. immersiveHook -- twilight / outdoor shrine | route/runtime + display | twilight marker + once-per-window + Good Daedra toast? | PASS 2026-07-04 from Papyrus.0.log plus tester-reported Prisma toast after restart |
| 4e. immersiveHook -- deviation price | route/runtime | DA01 Black Star stage 110 routes deviation price? | RUNTIME PENDING; static/readback wired for DA01 stage 110 only |
| 5. surveyStatusClarity | manual-acceptance | compact focus + named standing + curse posture, counter-free? | |
| 6. stackSnapshot | manual-acceptance | snapshots A + B match, no generic leak? | |
| 7. manualFeelNote | manual-acceptance | feel note recorded | |
| 8. Prisma surfaces | manual-acceptance | toast/panel/Chronicle/Ledger safe and populated, including recovery? | |

Blocking notes:

After the run, before log rotation, re-run the accepted route checker
(`node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer
--strict-manager`) to attach fresh route proof, then transcribe these statuses
into the Dunmer block of
`references/authoring/PDV_Phase20_ManualEvidenceLedger.json` and only then touch
verdicts in `PDV_PreBetaRaceGateLedger.md`.
