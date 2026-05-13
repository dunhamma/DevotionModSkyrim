# PDV Phase 3 CK Steps - ActionRouter Kill Event Slice

Status: scripts compiled; CK wiring and in-game verification pending.

Phase 3 adds the first live action-capture path:

Story Manager Kill Actor event -> `PDV__SM_KillActor` -> `PDV_ActionRouter` -> deity `ScoreAction()` -> `PDV__ManagerQuest.AwardPiety()` -> `PDV.PietyToday`.

Persistent piety, tier changes, and mirror globals still update only at dawn through `ProcessDawn()`.

---

## Already Done

- `PDV_ActionRouter.psc` exists in `Devotion\Scripts\Source`.
- `PDV__SM_KillActor.psc` exists in `Devotion\Scripts\Source`.
- Both scripts compile cleanly.
- Compiled `.pex` files exist in `Devotion\Scripts`.

---

## CK Step 1 - Create `PDV_ActionRouter`

1. Launch Creation Kit through MO2 using the Anvil CKPE executable.
2. Load `PlayerDevotion_Framework.esp` as the active file.
3. Create a new Quest record:
   - ID: `PDV_ActionRouter`
   - Start Game Enabled: checked
   - Priority: `60`
4. Go to the Scripts tab.
5. Add existing script `PDV_ActionRouter`.
6. Open script Properties and assign:

| Property | Value |
|----------|-------|
| `PDV_Manager` | `PDV__ManagerQuest` |
| `PDV_FLST_AllDeities` | `PDV_FLST_AllDeities` |
| `PDV_GLO_DebugLevel` | `PDV_GLO_DebugLevel` |
| `PlayerRef` | `PlayerRef` |
| `ActorTypeNPC` | `ActorTypeNPC` |
| `ActorTypeAnimal` | `ActorTypeAnimal` |
| `ActorTypeCreature` | `ActorTypeCreature` |

Use Auto-Fill first. Manually fill anything Auto-Fill misses.

---

## CK Step 2 - Create `PDV__SM_KillActor`

1. Create a new Quest record:
   - ID: `PDV__SM_KillActor`
   - Start Game Enabled: unchecked
   - Priority: `60`
2. Go to the Scripts tab.
3. Add existing script `PDV__SM_KillActor`.
4. Open script Properties and assign:

| Property | Value |
|----------|-------|
| `PDV_Router` | `PDV_ActionRouter` |

This quest should normally be stopped. Story Manager starts it only when a Kill Actor event fires.

---

## CK Step 3 - Wire Kill Actor Story Manager

1. In the Object Window, open Story Manager / SM Event Node.
2. Open the Kill Actor Event node.
3. Add a quest node for `PDV__SM_KillActor`.
4. Check `Shares Event`.
5. Set Hours Until Reset to `0`.
6. Do not add CK conditions for the first test unless the UI path is completely clear. `PDV_ActionRouter` already guards:
   - direct player killer only
   - valid Actor victim/killer only
   - hostility evidence required
   - known victim classification required

Keeping CK conditions minimal makes this slice easier to debug.

---

## CK Step 4 - Save And Generate SEQ

1. Save `PlayerDevotion_Framework.esp`.
2. Because Phase 3 adds the new Start Game Enabled quest `PDV_ActionRouter`, generate/update the SEQ file.
3. Use the same xEdit SEQ generation workflow validated during Phase 2.
4. Confirm output lands in the Devotion mod, not Overwrite.

---

## In-Game Test Setup

Use a clean-ish test save or `coc qasmoke` path as usual.

Set debug output:

```text
set PDV_GLO_DebugLevel to 2
```

Activate Kyne:

```text
SetPQV PDV__ManagerQuest DebugIndex 0
SetPQV PDV__ManagerQuest DebugCommand 3
```

Close the console and wait 2-3 seconds.

Confirm:

```text
GetGlobalValue PDV_GLO_ActiveDeityIndex
SQV PDV_ActionRouter
SQV PDV__SM_KillActor
```

Expected:
- active deity index is `0`
- `PDV_ActionRouter` is running
- `PDV__SM_KillActor` is normally stopped unless a kill event just fired

---

## Test 1 - Hostile Bandit

1. Note current mirrors:

```text
GetGlobalValue PDV_GLO_ActivePiety
GetGlobalValue PDV_GLO_ActiveTier
```

2. Kill one hostile bandit directly with the player.
3. Check `Papyrus.0.log`.

Expected log signs:
- `ActionRouter` routed event `2`
- Kyne scored `+0.5`
- `AwardPiety` shows `today=0.5`

Expected before dawn:
- `PDV_GLO_ActivePiety` unchanged
- `PDV_GLO_ActiveTier` unchanged

Run dawn manually:

```text
SetPQV PDV__ManagerQuest DebugCommand 5
```

Close the console and wait 2-3 seconds.

Expected after dawn:
- persistent active piety increases by `0.5`
- mirrors update after dawn only

---

## Test 2 - Hostile Wolf

Seed enough piety that a penalty is visible after dawn:

```text
SetPQV PDV__ManagerQuest DebugValue 10.0
SetPQV PDV__ManagerQuest DebugCommand 6
```

Close the console and wait 2-3 seconds.

Kill one hostile wolf directly with the player.

Expected log signs:
- `ActionRouter` routed event `1`
- Kyne scored `-3.0`
- `AwardPiety` shows the negative scratch value

Run dawn:

```text
SetPQV PDV__ManagerQuest DebugCommand 5
```

Expected after dawn:
- active piety drops from `10.0` to `7.0`
- tier/mirrors update after dawn only

---

## Test 3 - Neutral Animal Or NPC

Kill one neutral animal or neutral NPC in a controlled test.

Expected:
- router skips the event for lack of hostility evidence
- no `AwardPiety` trace
- no mirror change before dawn
- no persistent piety change after dawn

---

## Test 4 - Rapid Valid Kills

Kill two valid hostile targets quickly.

Expected:
- two separate router traces
- two separate `AwardPiety` traces
- `PDV__SM_KillActor` does not get stuck running
- dawn consolidates the sum of both scratches, clamped by the existing `+/-5` daily cap

---

## If It Fails

- If CK cannot see a script, confirm the `.pex` exists in `Devotion\Scripts`.
- If no kill event fires, confirm `PDV__SM_KillActor` is under Kill Actor Event and `Shares Event` is checked.
- If every kill is ignored, raise `PDV_GLO_DebugLevel` to `3` and inspect ActionRouter skip traces.
- If wolves are ignored, `ActorTypeAnimal` may not match the target; test `ActorTypeCreature` classification next.
- If neutral kills score, hostility detection is too permissive and should be tightened before expanding Phase 3.
