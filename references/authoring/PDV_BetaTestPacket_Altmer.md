# PDV Beta Test Packet - Altmer

Created: 2026-06-06
Status: pass - source, visual, edge, and reward/stack snapshot proof recorded
Mode: console-assisted beta-feel packet

This packet restarts Altmer as a full race proof packet, not just a focused
MQ104 or book-source proof. It proves accepted source wiring, wrong-origin and
generic-source rejection, Survey/status clarity, repeat crisis rejection, and
the first-tier reward display boundary.

## Result

2026-06-06:

- Tester confirmed Altmer passed all Auri-El/Magnus/Xarxes book checks and
  visuals in game.
- The MQ104 stage 160 edge proof is accepted from the already captured
  Papyrus.0.log and Survey Devotion evidence.
- No unwanted full Prisma/MCM auto-open was reported during the book/visual
  pass.

2026-06-10:

- Tester read the three approved Altmer books in game and confirmed the Survey
  Devotion surface showed Auri-El foundation, `Current standing: Unproven`, and
  `Last favor: Dawn steadiness`.
- Tester captured the Active Effects menu showing the live effect
  `Altmer: Dawn Steadiness` with source `Altmer: Dawn Steadiness`.
- Treat this as the accepted reward/stack snapshot for the current Altmer
  packet. It proves the visible favor/reward layer; it does not prove final
  world placement.

## Pass Bar

Altmer is beta-feel ready when this packet shows:

- Auri-El, Magnus, and Xarxes book sources route through the P2 book receivers.
- MQ104 stage 160 routes the authored Dragonborn/Lorkhan crisis pressure.
- The Survey Devotion output explains Auri-El foundation, current standing,
  Lorkhan pressure, and the most recent orthodox/dawn source in readable terms.
- Re-reading or re-triggering an already consumed crisis/source does not farm a
  stronger state.
- A non-Altmer origin does not gain Altmer manager state from Altmer sources.
- Generic Altmer-adjacent behavior stays silent.
- The stack snapshot shows the expected Altmer layer without overstacking. The
  current accepted proof is the contextual favor `Altmer: Dawn Steadiness`.
  The separate broad T1 reward contract `Altmer Orthodox Steadiness` remains
  patron/tier-gated and should only appear when that gate is legitimately met.

Stop and report a failure if the Prisma panel opens by itself, if a book read
blocks player control with a large panel, if a generic action awards Altmer
state, or if an Altmer reward appears while the player is not on the Altmer
origin lane.

## Preflight

Use a disposable save. Do not save over a real playthrough after curse or quest
stage console work.

Console setup:

```text
set PDV_GLO_OriginRace to 3
set PDV_GLO_DebugLevel to 2
```

Origin index `3` is Altmer.

## Expected Build - Scholar Orthodoxy

This checks the positive, non-crisis Altmer lane.

Add the three approved books:

```text
player.additem 0001AF94 1
player.additem 0001ACFE 1
player.additem 0001AD09 1
```

Read each book normally from inventory:

- `0001AF94` - `The Adabal-a` - Auri-El source.
- `0001ACFE` - `Arcana Restored` - Magnus source.
- `0001AD09` - `Last King of the Ayleids` - Xarxes source.

Expected in game:

- Top-left notifications only, no forced Prisma panel.
- Auri-El notice: dawn steadiness source.
- Magnus notice: dawn steadiness source.
- Xarxes notice: orthodoxy source.
- Manual Survey Devotion shows Auri-El foundation and an Altmer source/favor
  state in fiction-facing wording.

Reward/stack snapshot (folded in): the race reward is dawn-owned. Book reads
prove source state, not the Active Effect; the reward sync runs through
`ProcessDawn()` / `RunDawnApplySpellAndNeglectLayers()` and only grants the
first-tier race reward when the patron state is active and the active deity is
at least Seeker tier. After the normal dawn/update path, check Active Effects.
Accepted visible stack proof for the book packet is:

```text
Altmer: Dawn Steadiness
```

The separate broad T1 reward contract `Altmer Orthodox Steadiness` remains
patron/tier-gated. If that gate is not met, record the broad T1 reward as
correctly pending rather than forcing it with debug commands. The expected log
marker when the broad T1 reward is legitimately eligible:

```text
Race reward added: Altmer T1
```

After closing Skyrim, the expected checker is:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race altmer --strict-manager
```

Expected log markers include:

```text
RouteAltmerAurielFoundation complete: po3_book_altmer_auriel
RouteAltmerMagnusScholarship complete: po3_book_altmer_magnus
RouteAltmerXarxesLineage complete: po3_book_altmer_xarxes
```

## Edge Build - Dragonborn Crisis

This checks the authored crisis/Lorkhan pressure source. If the current save
has already consumed MQ104 stage 160, run this from an earlier disposable save
or treat the already captured MQ104 proof as the accepted edge proof.

Console:

```text
getstage MQ104
setstage MQ104 160
```

Expected in game:

- No forced Prisma panel.
- Manual Survey Devotion names Lorkhan pressure and Dragonborn/authored crisis
  pressure.
- The event should not need a visible dawn-study or crisis click object.

Expected log markers:

```text
RouteAltmerLorkhanPressure complete: 50 tier 2
RouteAltmerLorkhanPenalty complete: po3_queststage_altmer_mq104
Altmer crisis source accepted: Dragonborn identity
RouteAltmerCrisisSource complete: 51 source 1
```

Anti-farm (folded in): on the same disposable save, immediately re-run the
stage once more:

```text
setstage MQ104 160
```

Expected:

- No stronger Altmer state is created from the repeat.
- The Survey text does not escalate beyond the already earned source/crisis
  state.

Note: book-source anti-farm is structurally guaranteed by Skyrim's own "book
already read" flag. If a re-opened book event does not fire again because Skyrim
already marked the book read, that is acceptable and should be recorded as
"no repeat fire".

## Wrong-Origin Rejection

Use a separate disposable save, or run this only after taking the expected-build
screenshots.

Console:

```text
set PDV_GLO_OriginRace to 0
player.additem 0001AD06 1
```

Read `0001AD06` - `Fragment: On Artaeum`.

Expected:

- No Altmer manager state, Survey movement, or Altmer reward.
- A low-level EventBus route may still appear because the book receiver saw the
  book read, but the manager-side Altmer handler must return without awarding
  Altmer state for a non-Altmer origin.

## Generic-Source Silence

Return to Altmer origin:

```text
set PDV_GLO_OriginRace to 3
```

Do one or two generic Altmer-adjacent actions:

- Cast ordinary spells.
- Join or enter generic College activity.
- Travel, wait, or interact with non-approved books/items.

Expected:

- No new Altmer source notice.
- No new Survey source state.
- No automatic Prisma panel.

## Optional Curse Edge

Only run this on a disposable save. This checks that curse pressure suppresses
or caps Altmer favor instead of becoming a stronger alternate build.

Route in-game debug through the MCM dev page (per project MEMORY: this Skyrim
profile does not use `cqf`). The equivalent debug action is `DebugForceCurseVampire`:

```text
cqf PDV__ManagerQuest DebugForceCurseVampire
```

Then read an unused approved Altmer book or use Survey Devotion.

Expected:

- Altmer favor is suppressed or capped by curse posture.
- Survey/status explains the curse posture.
- Restore on the same disposable save if needed (MCM dev page action
  `DebugForceCurseNone`):

```text
cqf PDV__ManagerQuest DebugForceCurseNone
```

## Report This

Closing report block (evidence + verdict in one place).

Minimum evidence to bring back:

- Screenshot of Survey after the three book sources.
- Screenshot of Survey after MQ104 stage 160, unless using the already captured
  MQ104 proof.
- Note whether top-left notifications appeared and whether the Prisma panel
  stayed closed.
- Screenshot or note for Active Effects reward state: visible reward or
  correctly pending due to patron/tier gate.
- Confirmation of wrong-origin and generic-source silence.

Post-run log checks:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race altmer --strict-manager
rg -n "RouteAltmer|Altmer source favor|Altmer crisis|Race reward added: Altmer T1|po3_queststage_altmer_mq104" "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log"
```

Verdict shape when reporting back:

```text
Altmer expected build: PASS
Altmer MQ104 edge: using prior proof
Wrong-origin rejection: PASS
Generic-source silence: PASS
Repeat anti-farm: PASS
Reward/stack snapshot: PASS - Active Effects shows Altmer: Dawn Steadiness
Blocking notes: no packet blocker; final-world placement remains separate
```

## Trim log (2026-06-13)

Trimmed per tools/_audit_trims.json (Altmer entry). Before -> after: 10 -> 6
test steps. Zero loss of safety coverage; all seven keepCritical levers
preserved.

- CUT "Repeat And Anti-Farm" standalone section. The crisis-repeat anti-farm
  check (re-run `setstage MQ104 160` once, confirm Survey does not escalate)
  was folded into Edge Build. The book re-read was dropped as a structural
  no-op (Skyrim's "book already read" flag), with the "no repeat fire"
  allowance retained as a note in Edge Build. Anti-farm coverage preserved.
- CUT "Reward And Stack Snapshot" standalone section. The Active-Effects
  observation (`Altmer: Dawn Steadiness` visible; broad T1 `Altmer Orthodox
  Steadiness` correctly pending behind the patron/tier gate) was folded into
  Expected Build. Reward-record enablement is already machine-proven
  (1280/0 readback), so this confirms the gate behaves rather than re-proving
  the record exists. Reward lever preserved.
- MERGED "Evidence To Bring Back" + "Verdict" into one closing "Report This"
  block. Pure reporting scaffolding; no coverage lost.
- Preserved verbatim as runnable steps: Preflight origin gate, Expected Build
  three-book route + reward snapshot, Edge Build MQ104 crisis + anti-farm,
  Wrong-Origin Rejection, Generic-Source Silence, Optional Curse Edge, and the
  post-run runtime_check machine gate.

## Current-Build Refresh (2026-06-14)

The Lorkhan-penalty lever (build-batch test 5) is runnable now. The
ThalmorAlignment actions were wired and **route-proven by the build pass
(2026-06-14)** -- the PENDING marks are cleared and the steps below reflect how
each emitter was actually built. Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- The "Optional Curse Edge" section above still shows `cqf` -- use the MCM Debug
  page `Curse vampire` / `Curse none` buttons instead (this profile does not use
  `cqf`).
- PDV `PDV_REFR_*Signal` objects are INVISIBLE; fire by RefID: prefix XX off
  `help "HoonDing" 0`, then `prid XX<refid>` + `activate player`.

### Lorkhan adjacency penalty now costs real piety (build-batch test 5)

Lorkhan-adjacent acts now subtract piety (was telemetry-only).

1. `set PDV_GLO_OriginRace to 3`, `set PDV_GLO_DebugLevel to 2`, `coc qasmoke`.
2. Select Auri-El, `Apply target piety` ~50, `Run dawn pass`, `Show piety map`
   -> note Auri-El piety.
3. Fire the Lorkhan-pressure signal: `prid XX07101F` + `activate player` once
   (organic alt: `setstage MQ104 160`). Log prints
   `Altmer Lorkhan penalty applied: -<n> to auri-el` (tier-3 source = -5; MQ104
   observed -7).
4. `Run dawn pass`, `Show piety map` -> Auri-El piety has DROPPED.
5. **PASS:** the penalty log fires and piety decreases. No toast is correct
   (silent penalty).

### ThalmorAlignment track (ROUTE-PROVEN 2026-06-14)

`PDV_ThalmorAlignmentTrack` mirrors the Imperial Concordat: range -100..+100,
5 states (Open Heterodox / Private Heterodox / Uncommitted / Public Orthodox /
Thalmor Devout). The band drives `GetAltmerLorkhanFactionModifier` (x0.75 / 1.0 /
1.5 on the Lorkhan penalty). NOTE: the committed band LABEL lags the raw value via
the track's lock-in, so a single action moves the raw value (visible in the trace)
but may not flip the Survey band -- prove via the raw value, not the label.

All three emitters are route-proven in Papyrus.0.log (build pass 2026-06-14):

```text
Read banned texts        -5   read "The Talos Mistake" book (000ED04D)
                              [trace: Altmer ThalmorAlignment read_banned_texts -5]
Consort with Daedra      -25  EQUIP any Daedric artifact (Savior's Hide, Mace of
                              Molag Bal, Mehrunes' Razor...). The trigger is
                              OnObjectEquipped of a Daedric artifact, NOT a quest
                              stage; one-shot per distinct artifact.
                              [trace: ... consort_with_daedra -25 ...]
Kill a Thalmor agent     -20  PLAYER'S OWN killing blow on a ThalmorFaction member
                              (00039F26) who is NOT a pre-set enemy (relationship
                              rank > -2); open kills and assassinations both count.
                              [trace: ... kill_thalmor_agent -20]
```

KILL-CREDIT CAVEAT: the kill beat scores ONLY the player's own killing blow
(ATTR_DIRECT_PLAYER). An ally or environmental kill is silent by design -- at the
Thalmor Embassy or any crowd fight a follower can steal the credit, producing a
false FAIL. Land the final hit yourself.

After each action, `Show Survey` -> ThalmorAlignment should move by the listed
points and the band/Lorkhan-modifier should shift accordingly.

NOT testable in V1 (no clean vanilla hook -- do not write these as steps):
arrest-Talos-worshipper (+15), complete-Thalmor-mission (+20),
help-prisoner-escape (-15).

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey lists recent beats in fiction voice.
