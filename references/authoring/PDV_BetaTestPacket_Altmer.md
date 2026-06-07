# PDV Beta Test Packet - Altmer

Created: 2026-06-06
Status: conditional pass - source, visual, and edge proof recorded; reward snapshot pending unless already observed
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
- Remaining closeout is the reward/Active Effects or correct patron/tier
  pending snapshot, unless that was part of the tester-observed visual pass.

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
- The first-tier race reward is either visible as `Altmer Orthodox Steadiness`
  when the patron/tier gate is legitimately met, or clearly remains pending
  because the patron/tier gate is not met.

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

## Repeat And Anti-Farm

On the same disposable save, re-open the three books and re-run:

```text
setstage MQ104 160
```

Expected:

- No stronger Altmer state is created from the repeat.
- The Survey text does not escalate beyond the already earned source/crisis
  state.
- If the book event does not fire again because Skyrim already marked the book
  read, that is acceptable and should be recorded as "no repeat fire".

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

## Reward And Stack Snapshot

The race reward is dawn-owned. Book reads prove source state, but they do not by
themselves prove the Active Effect. The reward sync runs through
`ProcessDawn()` / `RunDawnApplySpellAndNeglectLayers()` and only grants the
first-tier race reward when the patron state is active and the active deity is
at least Seeker tier.

Check Active Effects after the normal dawn/update path. If eligible, expected
reward:

```text
Altmer Orthodox Steadiness
```

Expected log marker when eligible:

```text
Race reward added: Altmer T1
```

If the patron/tier gate is not met, record that the reward is correctly pending
rather than forcing it with debug commands.

## Optional Curse Edge

Only run this on a disposable save. This checks that curse pressure suppresses
or caps Altmer favor instead of becoming a stronger alternate build.

```text
cqf PDV__ManagerQuest DebugForceCurseVampire
```

Then read an unused approved Altmer book or use Survey Devotion.

Expected:

- Altmer favor is suppressed or capped by curse posture.
- Survey/status explains the curse posture.
- Restore on the same disposable save if needed:

```text
cqf PDV__ManagerQuest DebugForceCurseNone
```

## Evidence To Bring Back

Minimum evidence:

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

## Verdict

Use this verdict shape when reporting back:

```text
Altmer expected build: PASS/FAIL
Altmer MQ104 edge: PASS/FAIL/using prior proof
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Repeat anti-farm: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```
