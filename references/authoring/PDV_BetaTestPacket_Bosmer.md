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

## Expected Build - Y'ffre Hunt-Law Pressure

Use a disposable Bosmer save.

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

Run one exact DA05 terminal branch with console assistance:

```text
setstage DA05 100
```

Expected runtime proof after closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Expected route marker:

```text
RouteBosmerYffre complete
```

Manual evidence to record:

```text
Accepted DA05 stage 100 route: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/FAIL
Feel note:
```

## Edge Build - Mercy Branch

Use a separate disposable Bosmer save or reload before the terminal branch.

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
setstage DA05 105
```

Expected runtime proof after closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
```

Manual evidence to record:

```text
Accepted DA05 stage 105 route: PASS/FAIL
Wrong-origin rejection: PENDING/FAIL
Generic-source silence: PENDING/FAIL
Repeat/anti-farm result: PENDING/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/FAIL
Feel note:
```

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

After closing Skyrim:

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
Bosmer DA05 live source packet: PASS/FAIL
Wrong-origin rejection: PENDING/FAIL
Generic-source silence: PENDING/FAIL
Survey/status clarity: PENDING/FAIL
Reward/stack snapshot: PENDING/FAIL
Blocking notes:
```


## Variety Tranche Addendum (2026-06-12) - "The Story Goes On"

Status: records + Papyrus layer landed and machine-verified (author tool write +
`--check` PASS, compile 0/0 across PDV__ManagerQuest / PDV_EventBus /
PDV_PlayerEvents / PDV_ActionRouter, `pdv_verify` FAIL=0). ALL sections below need
a NEW SAVE or main-menu `coc qasmoke` - new manager VMAD properties and the new
`OnHitEx` route only take effect on fresh init. Disable `Devotion - Living Deities
Test` in MO2 first.

This addendum proves six new levers: Green Dreams, Hearth of the Telling, Songs
of the Green, Scales at Rest (Exchange), Baan Dar Opens the Gap (Bandit Road), and
the Naming rite. The **Baan Dar Gap** is the one new event registration
(player-alias `OnHitEx` -> `PDV_EventBus.RouteBosmerBaanDarGap`) and the only lever
with real cadence risk.

### Preflight + debug seeder

```text
set PDV_GLO_OriginRace to 4
set PDV_GLO_DebugLevel to 2
```

Path axis (`PDV_State_BosmerPath`): OldContract=0, LivingStory=1, Exchange=2,
BanditRoad=3. `DebugSeedBosmer` sets the path, clears the Naming/signature
once-day cooldowns, and seeds +3 location discoveries:

```text
cqf PDV__ManagerQuest DebugSeedBosmer 1
```

A confirming MessageBox reports the applied path. If `cqf` is unreliable in your
setup, set the path from the MCM dev page (state-axis setter -> BosmerPath), then
re-run the seeder for the cooldown clear.

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
arrival.

### Scales at Rest (Exchange signature, once/day; seed path 2)

- Complete a favor / bounty / contract quest (trips the Exchange signal):
  `PDV_SPEL_BosmerScalesAtRest` (Speech +10, 120s) + "The account is even." At
  most once/day; a second settled account the same day is silent.
- Log marker: `Bosmer Scales at Rest fired.` Off-path (not Exchange): silent.

### Baan Dar Opens the Gap (Bandit Road signature, once/day; seed path 3) - CADENCE RISK

- In combat, take hits until health < 20%: `PDV_SPEL_BosmerBaanDarGap` (SpeedMult
  +30, 5s) + "Baan Dar opens the gap. Run." Once/day.
- Log marker: `Bosmer Baan Dar Opens the Gap fired.`
- **Silence checks (the real risk):**
  - Ordinary hits above 20% health: NOTHING fires (no notification, no log line).
  - A sub-20% hit while NOT in combat: silent (manager gates on `IsInCombat`).
  - A second sub-20% moment the same day: silent (once/day cap).
  - Off-path (seed 0/1/2): silent even at sub-20% in combat.
  - Non-Bosmer origin: the `OnHitEx` pre-gate (`GetOriginRaceValue() == 4`) means
    the manager is never even called.

### The Naming (rite, any path, 7-day cooldown)

- At the declared hearth OR any Songs site, sleep: a 5-option menu (Hunter /
  Speaker / Wanderer / Keeper / Not yet). "Not yet" does NOT spend the cooldown.
- Told-self in Active Effects, one at a time: Hunter = Archery +5; Speaker =
  Speech +5; Wanderer = Stamina Regen +8%; Keeper = Carry Weight +15.
- Choosing again retells (clear-before-add): the old told-self is removed first.
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
Green Dreams (path-keyed + armed-after-change): PASS/PENDING/FAIL
Hearth declaration + Tale Carried (3-discovery delta): PASS/PENDING/FAIL
Songs visited (count): N/6 + milestone PASS/PENDING
  - Eldergleam interior-only: PASS/PENDING/FAIL
  - Temple of Kynareth (slot-2 swap) fires: PASS/PENDING/FAIL
Scales at Rest (once/day, on-path): PASS/PENDING/FAIL
Baan Dar Gap fires sub-20% in combat: PASS/PENDING/FAIL
Baan Dar Gap SILENT on ordinary/off-path/non-combat hits: PASS/FAIL  <- key
Naming menu + one-active swap: PASS/PENDING/FAIL
Naming coherence fade + restore at dawn: PASS/PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
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

| Path button | Scoring deity | T1 (25) -> T2 (50) -> T3 (85) |
|---|---|---|
| Bosmer -> OldContract | Y'ffre (3) | Archery+5 -> Arch+13/Sneak+10 -> Arch+25/Sneak+22/PoisonRes+10% |
| Bosmer -> LivingStory | Y'ffre (3) | Speech+5 -> Speech+13/HRegen+10% -> Speech+25/HRegen+25%/MagRegen+5% |
| Bosmer -> Exchange | Z'en (4) | Speech+5 -> Speech+13/CarryWt+30 -> Speech+25/CarryWt+80/Armor+8 |
| Bosmer -> BanditRoad | Baan Dar (5) | Armor+5 -> Armor+15/HRegen+10% -> Armor+27/HRegen+25%/Sneak+10 |

- Switching the path button must SWAP the family: only ONE path family in Active
  Effects at a time.
- Broad + neglect: drop the active scoring deity below 25 + Run dawn pass -> path
  family removes, broad **Y'ffre's Weave** (Stamina Regen) shows; raise a path
  back to 25 -> broad suppresses. A neglected path shows **The Path Goes Quiet**
  (Stamina -5%).

### B. Variety levers
Click **Seed Bosmer variety** first (clears once-day cooldowns + seeds 3
discoveries on the current path). Then per the Variety Tranche Addendum above:
Green Dreams, Hearth + Tale Carried (declare, discover 3+ new locations, sleep
again), Songs of the Green (6 LCTNs incl. Eldergleam interior + the Temple of
Kynareth slot-2 swap), Scales at Rest (Exchange), **Baan Dar Gap** (BanditRoad,
the cadence risk -- prove it stays SILENT on ordinary/off-path/non-combat hits),
the Naming rite + coherence fade/restore.

### C. Route-signal proof
In `qasmoke`, activate the eight `PDV_REFR_Bosmer...Signal` objects once each
(list in "Current Runnable Fallback" above). Organic: `setstage DA05 100` / `105`
on a separate save.

### D. Negatives + Survey
- Wrong-origin: `set PDV_GLO_OriginRace to 6`, repeat any lever/signal -> zero
  Bosmer movement.
- Generic silence: back to `4`, generic sleep/travel/combat-above-20%/wrong-path
  turn-ins -> nothing fires.
- Survey: trigger Survey Devotion -> names active path, standing, Pact
  binding/lapse, recent favor; no raw counters or route IDs.

### E. After closing Skyrim
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
OldContract T1/T2/T3 grant + single-family swap: PASS/PENDING/FAIL
LivingStory T1/T2/T3: PASS/PENDING/FAIL
Exchange T1/T2/T3: PASS/PENDING/FAIL
BanditRoad T1/T2/T3: PASS/PENDING/FAIL
Broad Y'ffre lane + suppression-under-path: PASS/PENDING/FAIL
Neglect "The Path Goes Quiet": PASS/PENDING/FAIL
-- Variety levers --
Green Dreams / Hearth+Tale Carried / Songs (N/6) / Scales: PASS/PENDING/FAIL
Baan Dar Gap fires sub-20% in combat: PASS/PENDING/FAIL
Baan Dar Gap SILENT off-trigger: PASS/FAIL  <- key cadence check
Naming menu + swap + coherence fade/restore: PASS/PENDING/FAIL
-- Route signals + negatives --
8 QASmoke route markers (100-107): PASS/FAIL
DA05 100/105 organic: PASS/PENDING/FAIL
Wrong-origin rejection / Generic silence: PASS/FAIL
Survey/status clarity: PASS/PENDING/FAIL
Blocking notes:
```
