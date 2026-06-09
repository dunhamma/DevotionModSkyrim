# PDV ProcessDawn Auto-Trigger - In-Game Test Packet

**Created:** 2026-06-08
**Status:** Runtime proof packet for the wired dawn auto-trigger
**Owner:** Companion to the `processdawn-no-auto-trigger` memory and `PDV_DeityLikesDislikesMatrix.md` (section3 prerequisite)
**Scope:** Prove the day-rollover auto-consolidation works in normal play, and characterize its two edges.

---

## What is under test

`PDV__ManagerQuest.psc` (~lines 500-514), inside the self-perpetuating 1s `OnUpdate` tick
(`RegisterForSingleUpdate(1.0)`):

```
Float pdvDawnAdjustedTime = Utility.GetCurrentGameTime() - 0.25 ; 06:00 dawn offset (6/24 day)
Int pdvCurrentDawnDay = pdvDawnAdjustedTime as Int
if PDV.DawnAuto.Init == 0:  set Init=1, LastDay = today        ; lazy baseline
elseIf pdvCurrentDawnDay > PDV.DawnAuto.LastDay:
    LastDay = today
    ProcessDawn()                                              ; banks once per day, at ~06:00
```

**Updated 2026-06-08:** the trigger now fires at **~06:00 (dawn)**, not midnight - the `- 0.25`
offset shifts the integer-day rollover to 6 AM. `RunDawnNotify` also now emits a vanilla
`Debug.Notification("Your devotions settle with the dawn.")` whenever the dawn actually consolidated
devotion (`_dawnHadActivity`), independent of Prisma - the old Prisma-only toast silently no-opped
without the bridge.

`ProcessDawn -> RunDawnConsolidateScratch` (`:3119`): for each deity in `PDV_FLST_AllDeities`,
`PietyToday * 1.32` (`GAIN_RATE_SCALE`), clamped to +/-4.3 (`PIETY_DAILY_MAX_DELTA`), added to `Piety`
(clamped 0-200), `PietyToday` reset to 0, tier recomputed (thresholds 25/50/85).

## Key constants for expected math
| Constant | Value |
|---|---|
| `GAIN_RATE_SCALE` | 1.32 |
| `PIETY_DAILY_MAX_DELTA` | +/-4.3 |
| Tiers (Seeker/Devoted/Champion) | 25 / 50 / 85 |
| Auto-dawn trace (DebugLevel >= 1) | `[PDV] Auto-dawn: day rollover to <day>; running ProcessDawn.` |
| Per-deity bank trace (DebugLevel >= **2**) | `[PDV] ProcessDawn: <name> piety <old> -> <new>, today <x> scaled to <s> clamped/applied to <c>, tier now <t>` |
| Complete trace (DebugLevel >= 1) | `[PDV] ProcessDawn complete.` |

> Use a **non-Orc patron** for clean arithmetic - Orc life-mode applies an extra gain multiplier
> (`GetOrcLifeModeGainMultiplier`) on positive deltas.

---

## Preflight

1. Load a save with the **Devotion Dev** profile active and a chosen patron (or set one via MCM Debug).
2. Enable verbose logging - console:
   ```
   set PDV_GLO_DebugLevel to 2
   ```
3. Confirm Papyrus logging is on (SKSE ini `bEnableTrace=1`). Log path:
   `%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`
4. Open the MCM **Debug** page (this is the surface that sets the manager's `DebugCommand`/`DebugIndex`/`DebugValue`):
   - cmd 3 = Force Set Active Deity (by index) - if you need to pick the test patron.
   - cmd 6 = Force Set Piety (seed baseline `Piety`).
   - cmd 4 = Force Set Piety Today (seed today's scratch).
   - cmd 5 = Run ProcessDawn now (manual - used only as a control, NOT the auto path).
5. Note the in-game day: console `getgs` is not needed - read it from the first `Auto-dawn` trace, or
   `player.getav` is irrelevant; simplest is to seed and watch.

---

## Test 1 - Happy path (auto-bank + tier advance)

**Goal:** day rollover auto-fires ProcessDawn, banks PietyToday, advances tier - with NO MCM button press.

1. Seed a baseline just below a tier line and a known scratch (MCM Debug page):
   - Force Set Piety = **24.0**
   - Force Set Piety Today = **3.0**
2. Record: `Piety = 24.0`, `PietyToday = 3.0`, current tier (expect None/0 if fresh, or below Seeker).
3. **Advance time across one dawn (~06:00) without touching the ProcessDawn button.** The boundary is
   now the **6 AM rollover** - you must cross 06:00 into the next morning.
   - **Simplest - wait/sleep (recommended):** if it is before 6 AM (or the evening before), open the
     Wait menu (T) or sleep and advance to **past 06:00 the next morning**. (Can't wait in combat /
     enemies near.) The menu pauses script ticks, so on resume the next `OnUpdate` (~1s later) detects
     the rollover and fires ProcessDawn **once** - exactly the expected single bank.
   - **Alternative - continuous play (also exercises the gradual path):** console
     `set timescale to 20000`, stand still ~5-10 real seconds (a game day passes in ~4s), then
     `set timescale to 20`. Use this if you want to prove it fires while actively on foot as the clock
     passes 06:00, not only on a wait-jump.
4. **Expected log** (DebugLevel 2):
   ```
   [PDV] Auto-dawn: day rollover to <N>; running ProcessDawn.
   [PDV] ProcessDawn: <patron> piety 24.000000 -> 27.960000, today 3.000000 scaled to 3.960000 clamped/applied to 3.960000, tier now 1
   [PDV] ProcessDawn complete.
   ```
   - `27.96` = 24.0 + (3.0 x 1.32). Crosses 25 -> **tier now 1 (Seeker)**.
   - Re-open MCM/Survey: `PietyToday` should read **0**, `Piety` approx **27.96**, tier **Seeker**.
5. **Expected on-screen (top-left) - NOT in the log** (`Debug.Notification` does not write to Papyrus.log,
   so watch the screen, not the log, for these):
   - `Your devotions settle with the dawn.` - the new vanilla dawn notice (fires because today had activity).
   - `<patron> marks you as <Seeker label>.` - the tier-up notice (active patron only).

**PASS:** auto trace present, Piety increased by the scaled amount, PietyToday reset to 0, tier advanced - all without the MCM ProcessDawn button. **FAIL:** no `Auto-dawn` trace after a confirmed midnight crossing, or PietyToday did not bank.

### Test 1b - Daily cap clamp
Repeat with Force Set Piety Today = **4.0** -> scaled 5.28 -> **clamped to +4.3**. Expected
`clamped/applied to 4.300000`. PASS if the applied delta is 4.3, not 5.28.

---

## Test 2 - Boundary is now ~06:00 (dawn), not midnight

**Goal:** confirm the moved trigger fires at ~06:00, and no longer at midnight.

1. Seed Force Set Piety Today = **2.0** (so a fire is visible).
2. Set the clock to mid-evening so a midnight passes first - console:
   ```
   set gamehour to 21.0
   ```
3. Advance gently so you can read the clock at fire time:
   ```
   set timescale to 300
   ```
   Watch the log. Restore `set timescale to 20` once you have observed the fire (or confirmed none at
   midnight).

**Expected:**
- **No** `Auto-dawn` fire when the clock crosses **00:00** (midnight no longer triggers).
- The fire lands at **~06:00** the following morning.

**PASS:** fire clusters at ~06:00, with no midnight fire. Record the observed time. (To tune to 05:00,
change the `- 0.25` offset to `- (5.0/24.0)` in `PDV__ManagerQuest` and recompile.)

---

## Test 3 - Multi-day skip fires ONCE (banks once, not per skipped day)

**Goal:** confirm a jump spanning >=2 midnights between two `OnUpdate` ticks triggers a single
ProcessDawn, banking once - it does NOT run per-skipped-day decay/neglect.

1. Seed Force Set Piety = **10.0**, Force Set Piety Today = **3.0**.
2. Force a multi-day-per-tick jump - console:
   ```
   set timescale to 200000
   ```
   At this rate ~2.3 game-days pass per real second, so each 1s tick spans **more than one** midnight.
   Watch the log for **2-4 seconds**, then restore:
   ```
   set timescale to 20
   ```
3. **Expected:** each `Auto-dawn` trace shows `LastDay` jumping by **>=2** per fire, but each fire is a
   **single** ProcessDawn (one bank). After the first fire, `PietyToday` is 0, so subsequent fires add
   nothing. Net: Piety rises by **one** scaled bank (10.0 -> ~13.96), not by one bank per skipped day.

**PASS:** PietyToday banked exactly once despite multiple days crossed in the gap. **FAIL:** multiple
banks of the same PietyToday, or PietyToday banked then re-banked (double-count).

> **Design note to record, not a failure:** because skipped days collapse into one consolidation, any
> future per-day decay/neglect/commitment cadence will *under-count* across long sleeps/fast-travel.
> If per-day accrual across skips is desired, that is a deliberate design change (loop ProcessDawn per
> missed day), not a defect in this trigger. Flag the verdict.

---

## Control (sanity) - manual vs auto agree
Seed the same baseline, press the MCM **Run ProcessDawn now** button (cmd 5), and confirm the per-deity
bank trace/math is identical to the auto path. This isolates "is the trigger firing?" from "is
ProcessDawn correct?" - they share `ProcessDawn`, so a Test-1 failure with a passing control means the
**trigger** is the problem, not consolidation.

---

## Cleanup
```
set timescale to 20
set PDV_GLO_DebugLevel to 0
```

## Log-check (PowerShell)
```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" `
  -Pattern "Auto-dawn|ProcessDawn:|ProcessDawn complete"
```

## Results capture
| Test | Verdict | Observed | Notes |
|---|---|---|---|
| 1 happy path | **PASS 2026-06-08** | Tu'whacca 24.0->27.96, tier 0->1 (Seeker); single fire, 32-deity roster, complete | non-Orc patron; clean 1.32 math; re-confirmed after 06:00 move |
| dawn-time move (06:00) | **PASS 2026-06-08** | fired after 06:00 on reused save (new .pex loaded) | replaces midnight; `- 0.25` offset |
| dawn toast | **PASS 2026-06-08** | Prisma dawn toast fired; vanilla `_dawnHadActivity` fallback added | Prisma = SKSE .dll (not in plugins.txt); fallback backstops bridge-not-ready |
| 1b cap clamp | | applied delta = ? | |
| 2 midnight->dawn confirm | partial | fired after 06:00 PASS | full negative (no midnight fire) not separately run |
| 3 multi-day once | **PASS 2026-06-08** | banked once for a multi-day skip | no double-count; per-day decay across skips not pursued |
| control manual=auto | | match? | |
