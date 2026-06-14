# PDV Beta Test Packet - Bosmer

Created: 2026-06-06
Updated: 2026-06-13
Status: ready to run - DA05 source fill readback pass + variety tranche landed
(machine-verified, in-game smoke pending). For a single end-to-end pass covering
the whole race + the new variety levers, use "Single-Session Smoke (MCM-driven)"
at the bottom of this file. The DA05/QASmoke sections and the Variety Tranche
Addendum below remain the detailed per-area references.
Mode: console-assisted (standard `set`/`coc` console + the debug MCM dev page; no `cqf`)

Bosmer now has one approved exact P2 quest-stage source fill:
`PDV_FLST_P2_BosmerYffreSources` contains `DA05`
(`Skyrim.esm:02A49A`) for Ill Met By Moonlight terminal stages `100` and
`105`. This is readback/source-fill proof only. It does not prove runtime route
delivery, wrong-origin rejection, Survey/status clarity, reward/stack behavior,
or final-world feel.

## Remaining Run (2026-06-14) -- only the open items

Most of this packet is already PASS (all four path-family reward ladders +
single-family swap, broad-Y'ffre suppression, Neglect "The Path Goes Quiet",
Green Dreams, Hearth + Tale Carried, Scales at Rest, the Naming rite, and
wrong-origin / generic silence). Only the items below are still open; the
detailed procedures for each live in the sections further down. Tick these and
the packet closes.

- [ ] **Baan Dar Gap -- PRIORITY (the flagged cadence risk).** Procedure:
  "Variety Tranche Addendum -> Baan Dar Opens the Gap".
  - [ ] Fires sub-20% health WHILE IN COMBAT (seed path 3): `PDV_SPEL_BosmerBaanDarGap`
    (SpeedMult +30, 5s) + "Baan Dar opens the gap. Run." Markers:
    `Bosmer Baan Dar gap detected (combat_poll).` + `Bosmer Baan Dar Opens the Gap fired.`
  - [ ] SILENT off-trigger (the KEY check): above-20% in combat, sub-20% NOT in
    combat, a second sub-20% the same day, off-path (seed 0/1/2), and non-Bosmer
    origin all produce no spell / notification / manager fired line. Route-only
    EventBus noise is not a pass.
- [ ] **Songs of the Green (N/6 + milestone).** Procedure: "Variety Tranche
  Addendum -> Songs of the Green". Enter anchors via load door / fast-travel
  (NOT `coc`).
  - [ ] Eldergleam interior-only vision (cave cell, not the exterior approach).
  - [ ] Gildergreen OUTDOOR proximity (slot-2 swap, script-only / awaiting proof
    -- Polish backlog item 4): walk up to the Gildergreen tree, vision fires
    outdoors; the Temple of Kynareth interior must no longer fire it.
  - [ ] All-six milestone MessageBox.
- [ ] **8 QASmoke route markers (100-107).** Procedure: "Current Runnable
  Fallback - QASmoke Route Proof". The signals are INVISIBLE: fire each by RefID
  (`prid XX071035`..`XX07103C` + `activate player`; XX from `help "HoonDing" 0`),
  then the one session-end `node .\tools\pdv_phase20_runtime_check.mjs --race
  bosmer --strict-manager`.
- [ ] **DA05 100/105 organic route.** Procedure: "Expected Build" + "Mercy
  branch" sections. `setstage DA05 100`, then `105` on a separate clean save per
  branch; confirm the no-second-route anti-farm assertion.
- [ ] **Exchange T1/T2 Z'en copy -- fresh-load confirm.** Mechanics passed, but
  the prior run predated the 18:15 ESP refresh and showed the old non-Z'en copy.
  On a fresh load, re-read the Exchange T1/T2 reward and confirm the Z'en wording
  (Single-Session Smoke -> A, Exchange row).
- [ ] **Survey/status clarity -- final read.** Trigger Survey Devotion: names
  active path, standing, Pact binding/lapse, recent favor; no raw counters or
  route IDs.
- [ ] (minor) **Naming path-neutral declaration fix.** Declare the hearth on a
  NON-LivingStory path (OldContract/Exchange/BanditRoad) from a fresh save, then
  Name -- the rest of Naming is already proven.

## Edge Build - DA05 Mercy And Baan Dar Cadence

The edge build for this packet is split across two existing procedures rather
than a separate save route. For DA05, run the "Mercy branch + duplicate /
anti-farm check" on a separate clean save from the stage-100 accepted branch;
stage `105` must produce only the mercy marker and must not double-score the
stage-100 route. For the live variety cadence risk, run "Baan Dar Opens the Gap"
from the Variety Tranche Addendum: sub-20% health while in combat fires once per
day on the Bandit Road path, while above-20%, out-of-combat, repeat same-day,
off-path, and non-Bosmer origin attempts stay silent.

## Expected Build - Y'ffre Hunt-Law Pressure

Use a disposable Bosmer save or a clean reload before DA05 has resolved.
This proves the organic DA05 source path only. It does not cover the eight
QASmoke proof activators or the variety tranche.

### Setup

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

This DA05 route gives Y'ffre a small scratch-piety pulse (`+2 today`) and records
Old Contract path evidence. It is not enough by itself to create or change Magic
Effects. If this pass is meant to prove visible reward behavior, do this before
the DA05 branch:

1. MCM -> PlayerDevotion -> Player page -> enable **Developer Options**.
2. Open the **Debug page**.
3. Click **Bosmer -> OldContract**.
4. Click **Show piety map** and confirm the Y'ffre index from the message.
5. Cycle **Selected deity** to Y'ffre.
6. Set **Target piety** to `25`.
7. Click **Apply target piety**.
8. Click **Run dawn pass**.
9. Confirm `Magic > Active Effects` shows the Old Contract T1 reward before
   firing DA05. If it does not, stop and capture that as a reward-sync blocker.

Then run DA05. The DA05 branch should prove route/favor movement; visible Magic
Effects and Survey text should remain stable because the reward preflight already
put the player at Old Contract / Seeker. In this `Target piety = 25` route test,
same pre/post Active Effects and the same Player Devotion message are expected.

Visible threshold crossing (the T1 reward appearing as piety crosses 25) is
owned by the reward-tier sweep in "Single-Session Smoke > A", which walks
25 -> 50 -> 85 per path. Do not re-prove that here with a separate
`Target piety = 23` variant; the piety-25 preflight above plus the DA05
no-double-grant check is enough for the DA05 route.

If this save has already resolved DA05, reload a pre-DA05 save or run
`resetquest DA05` before testing a branch. DA05 stages `100` and `105` are
mutually exclusive for evidence purposes; use a separate clean attempt for each
branch.

### Accepted branch

```text
setstage DA05 100
```

Wait 5-10 seconds for Papyrus to route the event, then check in game:

```text
Survey Devotion: should show OldContract / Seeker after the piety-25 preflight
and should remain the same after DA05.
Magic > Active Effects: capture the current reward/stack state. If the reward
preflight above was skipped, no new Magic Effect is expected from DA05 alone.
If the piety-25 preflight was used, same pre/post Active Effects is expected.
```

Tell Codex when this is done so it can inspect the current Papyrus log. Until
`tools/pdv_phase20_runtime_check.mjs` gains a Bosmer DA05 P2 entry, do not use
the generic Bosmer checker for this DA05 proof. The generic checker validates
the eight QASmoke activators, not DA05.

Expected DA05 log markers:

```text
[PDV] EventBus: RouteBosmerYffre complete: 0 source po3_queststage_bosmer_da05_kill
[PDV] EventBus: RouteBosmerPactPositive complete: 44
```

The same DA05 stage may also route the Daedric Hircine content surface:

```text
[PDV] EventBus: RouteDaedricPrinceSignal complete: 200 index 15
```

That Hircine line is expected side evidence, not a failure of the Bosmer route.

Current manual log check:

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "RouteBosmerYffre|po3_queststage_bosmer_da05|RouteBosmerPactPositive|RouteDaedricPrinceSignal" -Context 1,1
```

Manual evidence to record:

```text
Accepted DA05 stage 100 route: PASS/FAIL
Survey/status stable after piety-25 preflight: PASS/PENDING/FAIL
Reward/stack stable after piety-25 preflight: PASS/PENDING/FAIL
Feel note:
```

### Mercy branch + duplicate / anti-farm check (one DA05 pass)

On the same save after the accepted `100` branch has routed, fire the alternate
DA05 mercy branch. This single pass captures BOTH the mercy-branch route marker
and the no-second-route anti-farm assertion, instead of re-running stage `105` on
a fresh save just to read the mercy marker.

```text
setstage DA05 105
```

Wait 5-10 seconds, then check Survey Devotion and Active Effects as above.

Expected: the mercy-branch route marker fires, but NO second `RouteBosmerYffre`
line appears for the prior accepted branch on the same quest instance. If a
second accepted-branch line appears, record it as a duplicate-guard failure.

Expected DA05 mercy marker:

```text
[PDV] EventBus: RouteBosmerYffre complete: 1 source po3_queststage_bosmer_da05_mercy
```

Current manual log check:

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "RouteBosmerYffre|po3_queststage_bosmer_da05|RouteBosmerPactPositive|RouteBosmerLivingStory|RouteDaedricPrinceSignal" -Context 1,1
```

Manual evidence to record:

```text
Accepted DA05 stage 100 route: PASS/FAIL
Mercy DA05 stage 105 route: PASS/FAIL
Repeat/anti-farm (no second accepted-branch line): PASS/PENDING/FAIL
Survey/status clarity: PASS/FAIL
Feel note:
```

## Wrong-Origin Check - DA05

Use a clean reload/reset before DA05 has resolved.

```text
set PDV_GLO_OriginRace to 6
set PDV_GLO_DebugLevel to 2
setstage DA05 100
```

Expected: no new `RouteBosmerYffre` line after the wrong-origin `setstage`.
The Daedric Hircine route may still fire; the Bosmer route must not.

Current result: **PASS 2026-06-13** by tester report.

Manual evidence to record:

```text
Wrong-origin DA05 stage 100 rejection: PASS/FAIL
Observed non-Bosmer route noise, if any:
```

Repeat with `setstage DA05 105` from another clean reload/reset if the mercy
branch also needs wrong-origin coverage.

## Current Runnable Fallback - QASmoke Route Proof

QASmoke proof confirms route-stack behavior only. It does not prove final
placement, normal-play feel, or anti-farm protection.

Use a disposable save:

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
coc qasmoke
```

Activate the eight Bosmer proof objects once:

```text
PDV_REFR_BosmerOldContractProperHuntSignal
PDV_REFR_BosmerOldContractForestKeptSignal
PDV_REFR_BosmerLivingStoryCommunityKeptSignal
PDV_REFR_BosmerLivingStoryNatureSiteSignal
PDV_REFR_BosmerExchangeDebtSettledSignal
PDV_REFR_BosmerExchangeProportionateVengeanceSignal
PDV_REFR_BosmerBanditRoadRoadLifeSignal
PDV_REFR_BosmerBanditRoadReversalSignal
```

After closing Skyrim, read the route markers from the SINGLE session-end runtime
check (see "Single-Session Smoke > E"). Do not invoke the node command a second
time just for this section:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Expected route markers:

```text
RouteBosmerOldContractProperHunt complete: 100
RouteBosmerOldContractForestKept complete: 101
RouteBosmerLivingStoryCommunityKept complete: 102
RouteBosmerLivingStoryNatureSite complete: 103
RouteBosmerExchangeDebtSettled complete: 104
RouteBosmerExchangeProportionateVengeance complete: 105
RouteBosmerBanditRoadRoadLife complete: 106
RouteBosmerBanditRoadReversal complete: 107
```

## Remaining Source Scope

Only DA05 stage `100` / `105` is currently approved and filled. Living Story,
Exchange, Bandit Road, Old Contract, Pact-pressure, book, trade, theft,
forest-travel, kindness, broad plant, and generic hunting sources remain blocked
unless separately approved with exact source metadata and readback.

## Evidence To Bring Back

```text
Bosmer QASmoke route fallback: PASS/FAIL
Bosmer DA05 live source packet: PASS
Wrong-origin rejection: PASS
Generic-source silence: PASS
Survey/status clarity: PASS
Reward/stack snapshot: PASS
Blocking notes:
```


## Variety Tranche Addendum (2026-06-12) - "The Story Goes On"

Status: records + Papyrus layer landed and machine-verified (author tool write +
`--check` PASS, compile 0/0 across PDV__ManagerQuest / PDV_EventBus /
PDV_PlayerEvents / PDV_ActionRouter, `pdv_verify` FAIL=0). ALL sections below need
a NEW SAVE or main-menu `coc qasmoke` - new manager VMAD properties and the new
player-alias combat-session route only take effect on fresh init. Disable
`Devotion - Living Deities Test` in MO2 first.

This addendum proves six new levers: Green Dreams, Hearth of the Telling, Songs
of the Green, Scales at Rest (Exchange), Baan Dar Opens the Gap (Bandit Road), and
the Naming rite. The **Baan Dar Gap** uses the shared Khajiit/Bosmer combat-session
poll: player-alias combat state opens a bounded session, a 4s poll samples health
while combat continues, and sub-20% Bosmer moments route through
`PDV_EventBus.RouteBosmerBaanDarGap`. This replaced the direct low-health `OnHitEx`
trigger because that naked hit hook was flaky in runtime smoke.

### Preflight + debug seeder

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

Path axis (`PDV_State_BosmerPath`): OldContract=0, LivingStory=1, Exchange=2,
BanditRoad=3. `DebugSeedBosmer` sets the path, clears the Naming/signature
once-day cooldowns, and seeds +3 location discoveries:

Use the MCM debug page instead of console-calling Papyrus functions: click the
path button you need, then click **Seed Bosmer variety**. A confirming MessageBox
reports the applied path and cooldown/discovery seed state.

### Green Dreams (all paths incl. Old Contract)

- Sleep on consecutive nights; occasional top-left dream line, path-keyed (~10%
  per sleep, min 2 days apart). Force a path change then sleep next night: chance
  jumps to 60% (armed at dawn after the change).
- Old Contract Apostate (GPC < 20) vs ordered Old Contract differ; Exchange /
  Bandit Road / Living Story each have their own line.
- Log marker: `Bosmer path dream fired`. Never stacks with a shown menu.

### Hearth of the Telling (Living Story only; seed path 1)

- Sleep in any interior cell: a "make this hearth yours" prompt (Yes / Not yet).
  Decline re-prompts only after 3 in-game days. Identity is the CELL, not the bed.
- After declaring, discover 3+ NEW locations, then sleep again in the declared
  hearth: `PDV_SPEL_BosmerTaleCarried` (Speech +5, 600s) + "You told the tale, and
  the telling settled." Anti-farm is the discovery delta (3+ since last stay), NOT
  sleep count.
- Log marker: `Bosmer favor LivingStory.CommunityKept`.
- Quick reach: `coc RiverwoodSleepingGiantInn`, declare, fast-travel to 3 new
  markers, return and sleep.

### Songs of the Green (all paths)

First arrival at each of 6 green LCTNs = one vision MessageBox + small path piety;
all six = milestone MessageBox. One-shot forever (anti-farm by design).

- Eldergleam Sanctuary (`0192AC`) - **interior cave cells only** (water + great
  tree), NOT the exterior approach. `coc EldergleamSanctuaryStart`.
- Kynesgrove (`018A4E`).
- Temple of Kynareth, Whiterun (`01F87D`) - the Gildergreen anchor. **Slot-2
  swap:** the design's `WhiterunWindDistrictLocation` does not exist as an LCTN, so
  the set binds the Temple of Kynareth (Danica's temple, devoted to the tree's
  goddess, beside the Gildergreen); vision fires entering the temple.
- Evergreen Grove (`019174`).
- Clearspring Tarn (`019157`).
- Autumnshade Clearing (`018EE4`).

Log marker: `Bosmer green song remembered: N` (1..6). Eldergleam arms a bounded
OnUpdate poll on entering the location; the vision fires on an interior cave cell
(Start/Start02/Top), mirroring the Argonian Waters set. The other five fire on
arrival via the Story-Manager location-change event matched against
`PDV_FLST_BosmerGreenSongs`. IMPORTANT: `coc` does NOT reliably fire that
location-change event, so coc-ing straight into an anchor cell does nothing for
those five -- enter via a load door or fast-travel instead. As of 2026-06-13 the
Whiterun anchor was reworked to fire OUTDOORS at the Gildergreen tree via a
proximity poll (walk up to the tree; the temple interior no longer fires it) -- see
Polish backlog item 4. Eldergleam is likewise a cell-poll, not the location event.

### Scales at Rest (Exchange signature, once/day; seed path 2)

- Current live proof route: set path to Exchange, then fire the Exchange signal
  through the MCM debug page or QASmoke proof object:

  - MCM Debug page: click **Bosmer Exchange** under path evidence.
  - QASmoke: activate `PDV_REFR_BosmerExchangeDebtSettledSignal`.

  A future curated favor / bounty / contract quest can trip the Exchange signal
  once an exact source is approved and filled, but arbitrary vanilla favor quest
  completion is not a safe live proof path for this packet.
- Expected result: `PDV_SPEL_BosmerScalesAtRest` (Speech +10, 120s) + "The
  account is even." At most once/day; a second settled account the same day is
  silent.
- Log markers: `RouteBosmerExchangeDebtSettled complete: 104`, `Bosmer favor
  Exchange.DebtSettled`, and `Bosmer Scales at Rest fired.` Off-path (not
  Exchange): the favor may route, but Scales should stay silent.

### Baan Dar Opens the Gap (Bandit Road signature, once/day; seed path 3) - CADENCE RISK

- In combat, drop below 20% health and remain in combat long enough for the next
  combat-session sample, up to roughly 4 seconds: `PDV_SPEL_BosmerBaanDarGap`
  (SpeedMult +30, 5s) + "Baan Dar opens the gap. Run." Once/day.
- Expected player-alias markers:
  - `Baan Dar combat session opened for origin 4.`
  - `Bosmer Baan Dar gap detected (combat_poll).`
- Required manager pass marker: `Bosmer Baan Dar Opens the Gap fired.`
- EventBus side marker: `RouteBosmerBaanDarGap complete.`
- **Silence checks (the real risk):**
  - Ordinary combat above 20% health: NOTHING fires (no notification, no manager
    fired line).
  - A sub-20% hit while NOT in combat: silent (manager gates on `IsInCombat`).
  - A second sub-20% moment the same day: silent (once/day cap).
  - Off-path (seed 0/1/2): no spell, notification, or manager fired line even at
    sub-20% in combat. The EventBus route may still log because the path gate is
    manager-owned; do not count route-only noise as a pass.
  - Non-Bosmer origin: the combat session does not open for Bosmer (`origin 4`),
    so no Bosmer Gap detection or manager fired line should appear.

### The Naming (rite, any path, 7-day cooldown)

- `Seed Bosmer variety` only clears the Naming/signature cooldowns and seeds +3
  discoveries. It does not declare the current bed/cell as the hearth.
- Fast hearth route:
  1. Use a Bosmer-origin save.
  2. Set the desired Bosmer path with the MCM path button.
  3. Click **Seed Bosmer variety**.
  4. Sleep in the target bed/cell and accept the hearth declaration prompt.
     This first eligible sleep is consumed by the hearth declaration menu. As of
     the 2026-06-13 script fix, declaration is path-neutral like Argonian bed
     declaration; Tale Carried remains Living Story-only.
  5. Sleep again in the same bed/cell. This second eligible sleep should show
     the Naming menu.
- Green Songs route: sleep at any Songs location instead of declaring a hearth.
  Current Songs anchors are Eldergleam Sanctuary, Kynesgrove, Whiterun Temple of
  Kynareth/Gildergreen, Evergreen Grove, Clearspring Tarn, and Autumnshade
  Clearing.
- Expected menu: Hunter / Speaker / Wanderer / Keeper / Not yet. "Not yet" does
  NOT spend the cooldown.
- Told-self in Active Effects, one at a time: Hunter = Archery +5; Speaker =
  Speech +5; Wanderer = Stamina Regen +8%; Keeper = Carry Weight +15.
- Choosing again retells (clear-before-add): the old told-self is removed first.
  Picking a told-self spends the 7-day Naming cooldown (`PDV.BosNaming.LastRiteTime`),
  so you cannot just sleep again to retell. To test the retell without waiting 7
  in-game days, click **Seed Bosmer variety** (it zeroes that key), then sleep
  again. "Not yet" does not spend the cooldown.
- Fix scope: the path-neutral declaration fix is only exercised by declaring the
  hearth on a NON-LivingStory path (OldContract/Exchange/BanditRoad); LivingStory
  declared+Named even before the fix, so a LivingStory-only run proves the
  menu/apply/swap mechanics but not the fix. The declared hearth is a single cell
  with no MCM reset, so prove the fix by declaring on a non-LivingStory path from
  a fresh save.
- Log marker: `Bosmer Naming told-self applied: N`.
- **Coherence fade/restore:** switch off the named path (or fall into Old Contract
  Apostate GPC < 20): at dawn it goes quiet ("The told-self goes quiet...") and the
  Active Effect drops, but `PDV.BosNaming.Active` stays set. Return to the named
  path: at dawn it returns ("You are yourself again. The told-self returns.").

### Wrong-origin + generic silence

```text
set PDV_GLO_OriginRace to 6
```

Repeat any lever trigger: ZERO Bosmer manager state, spell, or notification
movement. Then back to Bosmer (`set PDV_GLO_OriginRace to 4`) and try generic
sleeping / travel / combat above 20% / wrong-path quest turn-ins: no Tale Carried,
Scales, Gap, Naming, or Song movement.

### Evidence to bring back (variety addendum)

```text
Green Dreams (path-keyed + armed-after-change): PASS 2026-06-13
Hearth declaration + Tale Carried (3-discovery delta): PASS 2026-06-13
Songs visited (count): N/6 + milestone PASS/PENDING
  - Eldergleam interior-only: PASS/PENDING/FAIL
  - Temple of Kynareth (slot-2 swap) fires: PASS/PENDING/FAIL
Scales at Rest (once/day, on-path): PASS 2026-06-13 -- effect PDV_SPEL_BosmerScalesAtRest (Speech +10, 120s), notify "The account is even. The bargains fall your way for a while."; off-path silence confirmed via Papyrus.0.log (after switching to OldContract the Exchange signal logged route only, no second "Bosmer Scales at Rest fired." -- gated at TryBosmerScalesAtRest, manager line 2941: GetBosmerPathState() != BOSMER_PATH_EXCHANGE -> return before cast)
Baan Dar Gap fires sub-20% in combat: PASS/PENDING/FAIL
Baan Dar Gap SILENT on ordinary/off-path/non-combat hits: PASS/FAIL  <- key
Naming menu + one-active swap: PASS 2026-06-13
Naming coherence fade + restore at dawn: PASS 2026-06-13
Wrong-origin rejection: PASS
Generic-source silence: PASS
Survey/status clarity: PASS/PENDING/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```


## Single-Session Smoke (MCM-driven, 2026-06-13)

One end-to-end pass covering the whole Bosmer race (path families + rewards +
route signals) AND the new variety levers, driven through the **debug MCM** (no
`cqf`). The only console commands are standard `set` / `coc`.

Three debug-MCM dev-page buttons were added 2026-06-13 for this:
**Bosmer -> LivingStory**, **Bosmer -> Exchange**, **Seed Bosmer variety** (the
existing page already had Bosmer -> OldContract / BanditRoad, Selected deity +
Target piety + Apply target piety, Run dawn pass, Show piety map). The buttons
live in the freshly recompiled `PDV_MCM.pex`, so start on a NEW save / `coc
qasmoke` and disable `Devotion - Living Deities Test` in MO2 first.

### Setup
1. `coc qasmoke`, then `set PDV_GLO_OriginRace to 4`, `set PDV_GLO_DebugLevel to 2`.
2. MCM -> PlayerDevotion -> Player page -> enable **Developer Options**, open the
   **Debug page**.
3. Click **Show piety map** -> confirm **3 = Y'ffre, 4 = Z'en, 5 = Baan Dar**
   (use what the map prints if it disagrees; do not trust hardcoded indices).

Debug-page controls reused below: `Selected deity` (cycles), `Target piety`
slider + `Apply target piety`, `Run dawn pass` (resyncs reward/neglect spells),
the four `Bosmer -> <Path>` buttons, `Seed Bosmer variety`.

### A. Reward-tier sweep (path families)
Per path: click its path button -> cycle `Selected deity` to the scoring deity ->
set `Target piety` -> `Apply target piety` -> **Run dawn pass** -> open
Magic > Active Effects. Bump piety 25 -> 50 -> 85, Run dawn pass each time.
If a path button changes the path but Active Effects do not immediately swap in
an already-running test session, click **Run dawn pass** once; the manager was
patched 2026-06-13 so fresh loads also force a reward-layer sync directly from
the path button.

| Path button | Scoring deity | T1 (25) -> T2 (50) -> T3 (85) |
|---|---|---|
| Bosmer -> OldContract | Y'ffre (3) | Archery+5 -> Arch+13/Sneak+10 -> Arch+25/Sneak+22/PoisonRes+10% |
| Bosmer -> LivingStory | Y'ffre (3) | Speech+5 -> Speech+13/HRegen+10% -> Speech+25/HRegen+25%/MagRegen+5% |
| Bosmer -> Exchange | Z'en (4) | Speech+5 -> Speech+13/CarryWt+30 -> Speech+25/CarryWt+80/Armor+8 |
| Bosmer -> BanditRoad | Baan Dar (5) | Armor+5 -> Armor+15/HRegen+10% -> Armor+27/HRegen+25%/Sneak+10 |

- Switching the path button must SWAP the family: only ONE path family in Active
  Effects at a time.
- At 85 piety, Bosmer should show the T3 path reward/presentation only. Do not
  expect a separate formal Champion offer prompt; Bosmer T3 recognition is
  Survey/status text in V1, not a commitment-offer flow.
- Broad + neglect: under an active Bosmer path, broad **Y'ffre's Weave** is
  suppressed. Drop the active scoring deity below 25 + Run dawn pass -> the path
  family should remove; do not expect Y'ffre's Weave to appear unless the player
  is in broad worship state with enough broad favor. A neglected path shows
  **The Path Goes Quiet** (StaminaRateMult -5, authored as a
  PeakValueModifier regen effect after the initial ValueModifier shape felt too
  harsh in runtime smoke).

### B. Variety levers
Click **Seed Bosmer variety** first (clears once-day cooldowns + seeds 3
discoveries on the current path), then run ONE variety pass by following the
**Variety Tranche Addendum** above as the detailed procedure -- it owns Green
Dreams, Hearth + Tale Carried, Songs of the Green (incl. Eldergleam interior +
the Temple of Kynareth slot-2 swap), Scales at Rest + off-path silence, the
**Baan Dar Gap** cadence-risk silence checks, and the Naming rite + coherence
fade/restore. Do not re-enumerate each lever as a fresh step here; run the
Addendum once and record its evidence block.

### C. Route-signal proof
Run the single QASmoke route proof from "Current Runnable Fallback - QASmoke
Route Proof" above (activate the eight `PDV_REFR_Bosmer...Signal` objects once
each, then the one runtime check at session end). Organic: `setstage DA05 100`
then `105` on a separate save per the DA05 sections above. Do not activate the
eight signals a second time here -- the Fallback run is the one primary route
proof.

### D. Negatives + Survey
- Wrong-origin: `set PDV_GLO_OriginRace to 6`, repeat any lever/signal -> zero
  Bosmer movement.
- Generic silence: back to `4`, generic sleep/travel/combat-above-20%/wrong-path
  turn-ins -> nothing fires.
- Survey: trigger Survey Devotion -> names active path, standing, Pact
  binding/lapse, recent favor; no raw counters or route IDs.

### E. After closing Skyrim
Run the runtime check ONCE for the whole session here -- this is the single
canonical invocation; the "Current Runnable Fallback" section points to this run
rather than calling the node command a second time.

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```
Expect eight `RouteBosmer...complete: 100`..`107` markers + the variety `Trace`
lines (`Bosmer path dream fired`, `Bosmer green song remembered: N`, `Bosmer
Scales at Rest fired.`, `Bosmer Baan Dar Opens the Gap fired.`, `Bosmer Naming
told-self applied: N`) in `Logs\Script\Papyrus.0.log`.

### Consolidated evidence to bring back
```text
-- Path families (rewards) --
OldContract T1/T2/T3 grant + single-family swap: PASS (T3 2026-06-13; T1/T2 + single-family swap confirmed in a prior playthrough, recorded 2026-06-13)
LivingStory T1/T2/T3: PASS 2026-06-13
Exchange T1/T2/T3 mechanics: PASS 2026-06-13; T1/T2 Z'en copy remediated + readback-confirmed in the live ESP, but in-game confirm on a fresh load PENDING (the prior playthrough predated the 18:15 ESP refresh and showed the old non-Z'en copy)
BanditRoad T1/T2/T3: PASS (prior playthrough, recorded 2026-06-13)
Broad Y'ffre lane + suppression-under-path: suppression-under-path PASS (prior playthrough, recorded 2026-06-13); broad-lane appearance only relevant in broad-worship state
Neglect "The Path Goes Quiet": PASS 2026-06-13 (fresh load; PeakValueModifier StaminaRateMult -5 confirmed -- stamina regen ~5% slower, not pinned near zero)
-- Variety levers --
Green Dreams: PASS 2026-06-13. Hearth+Tale Carried: PASS 2026-06-13. Songs (N/6): PENDING. Scales at Rest: PASS 2026-06-13 -- PDV_SPEL_BosmerScalesAtRest (Speech +10, 120s), notify "The account is even. The bargains fall your way for a while."; on-path fire + once/day + off-path silence confirmed (log: single "Bosmer Scales at Rest fired." on Exchange; off-path Exchange signal logged "RouteBosmerExchange complete: 42" route-only, no fire/cast/notify -- path gate at manager line 2941).
Baan Dar Gap fires sub-20% in combat: PASS/PENDING/FAIL
Baan Dar Gap SILENT off-trigger: PASS/FAIL  <- key cadence check
Naming menu + swap + coherence fade/restore: PASS 2026-06-13 (Naming rite + Hearth + Tale Carried + coherence confirmed on a reload; path-neutral declaration fix still needs one non-LivingStory declaration from a fresh save)
-- Route signals + negatives --
8 QASmoke route markers (100-107): PASS/FAIL
DA05 100/105 organic: PASS/PENDING/FAIL
Wrong-origin rejection / Generic silence: PASS
Survey/status clarity: PASS/PENDING/FAIL
Blocking notes:
```

## Polish / Follow-up Backlog (recorded 2026-06-13)

Non-blocking copy/polish items captured during Bosmer in-game testing. Defer to a
polish pass (now or a future session); they do not gate beta-feel.

1. **Variety-effect descriptions lack the magnitude clause.** The Bosmer variety
   spells carry flavor-only player-facing text with no stated effect, unlike the
   reward blessings (which append an "(Effect: ...)" clause -- see
   `PDV_RewardDescriptionClarity_Review_2026-06-09.md`). Add a magnitude + duration
   clause to each, then re-author from `PDV_BosmerVariety_RecordBatch.manifest.json`:
   - `PDV_SPEL_BosmerTaleCarried` -- Speech +5, 600s
   - `PDV_SPEL_BosmerScalesAtRest` -- Speech +10, 120s
   - `PDV_SPEL_BosmerBaanDarGap` -- SpeedMult +30, 5s
   - `PDV_SPEL_BosmerNaming_Hunter` -- Archery +5
   - `PDV_SPEL_BosmerNaming_Speaker` -- Speech +5
   - `PDV_SPEL_BosmerNaming_Wanderer` -- Stamina Regen +8%
   - `PDV_SPEL_BosmerNaming_Keeper` -- Carry Weight +15

   AUDIT BLIND SPOT: `tools/pdv_reward_desc_audit.mjs` scans the 12 reward spec
   files only, NOT the variety manifest, so these will never auto-surface in the
   clarity review. Either extend the audit to the variety manifest or fix by hand.
   Timed buffs should state the duration, unlike the constant reward abilities.

2. **Wording brush-up sweep.** Pass over all Bosmer variety / told-self / signature
   player-facing strings (and consider an all-race sweep) to tighten tone and
   consistency. A future polish session is fine; not now-blocking.

3. **Songs of the Green vision text is awkward + shared across all 6 anchors.** The
   per-arrival vision is a hardcoded `Debug.MessageBox` in `PDV__ManagerQuest`
   (`AwardBosmerSong`, ~line 2927): "The green here remembers an older telling. For
   a breath the Story leans close, and names you part of it." -- reads as word salad
   without Y'ffre-Storyteller context, and the SAME line shows for every anchor (no
   per-site flavor). Reword (proposed, pending pick): A) name Y'ffre's first telling;
   B) keep the mystery; C) most concrete. Because it is hardcoded in the manager (not
   a record) the fix needs a manager source edit + recompile and is invisible to
   `pdv_reward_desc_audit.mjs`.

4. **Whiterun Songs anchor moved to the Gildergreen tree -- IMPLEMENTED 2026-06-13
   (script-only; awaiting in-game proof).** The Temple of Kynareth interior fired
   correctly but was the wrong spot -- the anchor is the Gildergreen, OUTDOORS in
   the Wind District. As-built (NO ESP/FLST edit; manager `.psc` only; compiled 0/0,
   verifier FAIL=0): `HandleBosmerLocationChange` now intercepts WhiterunLocation
   `0x00018A56` to arm `PDV.BosSongs.GildergreenActive`, and intercepts the Temple
   LCTN `0x0001F87D` to suppress its interior award. The Temple LCTN is RETAINED in
   `PDV_FLST_BosmerGreenSongs` as the song's slot id (keeps the milestone-of-6 count
   and the Naming-at-songs check intact). A new `TryBosmerGildergreenProximity()`
   poll on the Eldergleam OnUpdate tick caches Gildergreen ref `0x00023612`
   (`Game.GetFormFromFile`, resolve-once) and awards slot `0x0001F87D` when
   `GetDistance < 600` then disarms. The FLST-swap variant was rejected because
   putting WhiterunLocation in the FLST would also make Naming-at-songs fire anywhere
   in Whiterun. PENDING: in-game proof next session -- walk up to the Gildergreen and
   the vision should fire outdoors; the temple interior should no longer fire it; the
   600 distance is tunable.

## Trim log (2026-06-13)

Step-count trim with zero loss of safety coverage. Before -> after: 58 -> 34 steps.
Every wrong-origin, generic-source silence, anti-farm/silence, and unique
reward/curse/variety lever was preserved verbatim as a runnable step.

Cuts:

1. Single-Session Smoke > C "Route-signal proof" no longer re-runs the eight
   QASmoke activators; it points to the one "Current Runnable Fallback - QASmoke
   Route Proof" run as the single primary route proof (the eight 100-107 markers
   are still proven once).
2. Single-Session Smoke > B "Variety levers" no longer re-enumerates Green
   Dreams / Hearth / Songs / Scales / Gap / Naming; it runs ONE variety pass via
   the Variety Tranche Addendum (the detailed procedure). All variety levers,
   incl. the Baan Dar Gap silence checks, remain proven once.
3. Expected Build "threshold-crossing variant" (Target piety 23 -> setstage 100
   -> dawn pass) removed; visible T1 threshold crossing is owned by the
   reward-tier sweep (Single-Session A: 25 -> 50 -> 85). The piety-25 preflight +
   DA05 no-double-grant check still establishes the DA05 route does not
   double-grant.
4. Edge Build - Mercy Branch (standalone DA05 105 on a fresh save) merged into
   the "Mercy branch + duplicate / anti-farm check" so one DA05 pass captures the
   mercy marker AND the no-second-route anti-farm assert. The clean-save
   wrong-origin DA05 run is kept separate and intact.
5. Single-Session Smoke > E runtime check is now the single canonical
   `pdv_phase20_runtime_check.mjs --race bosmer --strict-manager` invocation; the
   QASmoke Fallback section reads from that one run instead of calling the node
   command a second time.

Merges:

- Single-Session Smoke is the one canonical run-through; the DA05, QASmoke, and
  Variety Addendum sections are now referenced procedures it points into, not
  independently re-run passes.
- The two DA05-105 setups collapsed into one mercy + anti-farm sequence.
- The threshold-crossing proof folded into the reward-tier sweep.
- The runtime-check node command runs once at session end.

Preserved (not cut): Wrong-Origin Check - DA05 (clean save), the variety
wrong-origin + generic-silence block, the Baan Dar Gap silence checks
(above-20% / not-in-combat / second-same-day / off-path / non-Bosmer), Scales at
Rest off-path silence, DA05 no-second-route anti-farm, Hearth + Tale Carried
discovery-delta anti-farm, the reward-tier sweep with single-family swap and
broad-Yffre suppression-under-path, Neglect "The Path Goes Quiet", Songs of the
Green location levers (Eldergleam interior + Gildergreen proximity + milestone of
6), Naming coherence fade/restore, the eight QASmoke route markers (single run),
and Survey/status clarity.

## Current-Build Refresh (2026-06-14)

Ready to run NOW. Folds the 2026-06-14 consolidated build + new surfaces in.
Everything above stays valid; the items here are additive corrections.

Cross-cutting reminders:
- State inits ONLY on a NEW save / main-menu `coc qasmoke`; disable `Devotion -
  Living Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.
- `coc` does NOT fire Story location-change triggers -- the Songs of the Green
  anchors (and Eldergleam) need a load-door entry or fast-travel, never a `coc`
  straight into the cell (already noted above; restated because it is the #1
  false-FAIL on this packet).
- Bosmer neglect gate is piety **<= 10** plus bottom-3-lowest, NOT "below 25".
  To prove "The Path Goes Quiet", drop the scoring deity to **0** Target piety;
  seeding it to ~12-24 will read as a false FAIL.

### Invisible QASmoke signals -- fire by RefID (corrects the Fallback section)

The eight `PDV_REFR_Bosmer...Signal` proof objects are INVISIBLE, nameless
script activators -- you cannot see or click them in `coc qasmoke`. Fire each by
RefID instead: get your 2-hex plugin prefix XX once off a NAMED blessing
(`help "HoonDing" 0` -> the `SPEL:` FormID's first two hex digits = XX), then
for each signal `prid XX<refid>` + `activate player` (NOT bare `activate`).

Bosmer signal RefIDs are `071035`..`07103C`; in the packet's object order they
map to routes 100..107:

```text
071035 OldContractProperHunt    -> 100
071036 OldContractForestKept     -> 101
071037 LivingStoryCommunityKept  -> 102
071038 LivingStoryNatureSite     -> 103
071039 ExchangeDebtSettled       -> 104
07103A ExchangeProportionateVengeance -> 105
07103B BanditRoadRoadLife        -> 106
07103C BanditRoadReversal        -> 107
```

The session-end `pdv_phase20_runtime_check.mjs --race bosmer --strict-manager`
run confirms which route each fired (trust the 100..107 markers over the
object->RefID pairing if they ever disagree).

### Baan Dar Gap now uses the shared below-20% hook

The sub-20% combat detection that drives the Baan Dar Gap is now the
cross-race combat-session poll (`PDV_PlayerEvents` ->
`PDV_EventBus.RoutePlayerBelowHealthGate` ->
`PDV__ManagerQuest.HandlePlayerBelowHealthGate`; the same hook Khajiit / Argonian
/ Orc use). The player-alias markers and all five silence checks in the Variety
Tranche Addendum are unchanged. This is health-based, not kill-based, so the
killing-blow caveat does not apply here.

### Neglect vanilla top-left fallback

Beyond "The Path Goes Quiet", a neglected COMMITTED patron now prints a vanilla
top-left line `<Deity>'s regard fades as your devotion goes quiet.` even with the
Prisma overlay off (D0). To prove it: commit a patron, drop it to ~5 Target
piety, Run dawn pass until it crosses neglect.

### Survey "recent events" log

Survey Devotion now lists the last few devotion beats in fiction voice. After any
accepted Bosmer lever, confirm it appears there with no route IDs or raw
counters. (Known editorial gap: `GetBosmerPathLabel()` still leaks the raw enum
`OldContract` in the path line -- folded into the all-race Survey rewrite, not a
beta-feel blocker.)
