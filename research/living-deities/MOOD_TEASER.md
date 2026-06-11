# Mood Teaser -- Smoke Test Runsheet

The "the gods notice you" V1 candidate: each deity develops a mood that drifts
with your recent behavior (EWMA over the daily piety), sorts into four bands
(Wroth/Cool/Pleased/Exalted), and fires a once-per-day toast when an active-pool
deity crosses a band ("Kyne's regard warms toward you"). No demands, boons,
dreams, or clutch save.

This runsheet drives it deterministically from the **PDV MCM debug page** + a few
console reads -- no waiting for real in-game days. ~5 minutes for the core test.

---

## 0. Before you start (read this)

### !!! CRITICAL: a genuinely FRESH game, or nothing works !!!
`PDV__ManagerQuest` is a persistent Start-Game-Enabled quest. Its script AND its
VMAD properties **bake into the save at first init and are never re-read**
(PDV's hardest-learned lesson -- see the deity-stance-wiring history). The teaser
swaps that script and adds the `PDV_GLO_PatronMoodBand` property, so on ANY save
that already initialized Devotion, the game keeps running the OLD script with the
OLD (property-less) VMAD -- the mood code simply never executes.

You MUST load the new code on a clean instance:
1. Exit all the way to the **main menu** (alt-tabbing or loading a save
   mid-session is NOT enough).
2. With the mod enabled, either **start a brand-new game**, or open console at the
   main menu and `coc qasmoke`.
3. **Never use Continue / load an existing character** for this test -- those
   carry the baked old script and will silently behave like the mod is off.

**Failure signature (= you're on a stale save, not a bug):** "Run dawn pass"
shows *"Your devotions settle with the dawn."* but **no** "...regard warms toward
you", and `GetGlobalValue PDV_GLO_PatronMoodBand` is stuck at **1** even with a
patron set + scratch applied. If you see exactly this, you did not start fresh.

**Decisive proof the new code is live:** at `PDV_GLO_DebugLevel` 2, after a dawn,
search `...\SKSE\Papyrus.0.log` for **`Mood band cross`** -- that string exists
ONLY in the teaser script. Present = new code running; absent = old script.

### Other setup notes
- **One test mod at a time.** Enable EITHER this mood teaser OR the full LD-P1
  engine test -- never both (they override the same scripts and will conflict).
- The teaser folder lands **unchecked** in MO2. Enable it: left pane (top of the
  list) tick **Devotion - Living Deities - Mood Teaser**; right pane tick
  **PDV_MoodTeaserTest.esp** (MO2 auto-sorts it after PlayerDevotion_Framework.esp).

## 1. Setup (2 min)
1. Enable the mood teaser mod + plugin (above). Launch via SKSE.
2. New game, or main menu -> console (`~`) -> `coc qasmoke`.
3. Wait ~1 min for SkyUI to register the MCM (you'll see the "PlayerDevotion"
   entry under Mod Configuration).
4. Console: `set PDV_GLO_DebugLevel to 2`  (adds `[PDV]` lines to
   `Documents\My Games\Skyrim Special Edition\SKSE\Papyrus.0.log` -- optional but
   useful). The band-cross toast itself shows regardless of debug level.

## 2. Core test -- one band cross (the foundation proof, ~3 min)
Open **MCM -> PlayerDevotion -> Debug** page. Then:

| # | Do this | Expect |
|---|---|---|
| 1 | "Target deity": click **Selected deity** until it reads **Kyne** | selector shows Kyne |
| 2 | Click **Debug patron override** ("Set selected deity active") | Kyne becomes the active patron (this puts it in the toast pool AND lifts its mood ceiling to Exalted) |
| 3 | Console: `GetGlobalValue PDV_GLO_PatronMoodBand` | **1.00** (Cool -- the rest state) |
| 4 | "Debug values": set **Target scratch** slider to its **max** (>= 4), then click **Apply target scratch** | sets Kyne's day piety to ~max |
| 5 | "Actions": click **Run dawn pass** -> confirm Yes | top-left notification: **"Kyne's regard warms toward you."** |
| 6 | Console: `GetGlobalValue PDV_GLO_PatronMoodBand` | **2.00** (Pleased) -- mood moved 0 -> 15, crossed Cool->Pleased |

That's the core mechanic proven: mood reacts to the day's piety, sorts into a
band, mirrors to the global, and announces the crossing once.

(With no per-deity JSON deployed, every deity uses alpha 0.15, so one max-piety
day moves mood by 0.15 * 100 = 15 points -- enough to clear the Pleased
threshold at +10. If `GetGlobalValue` still reads 1.00 after step 5, the scratch
slider was too low -- redo step 4 at a higher value.)

## 3. Fire-once + persistence (~2 min)
| # | Do this | Expect |
|---|---|---|
| 7 | Click **Run dawn pass** again (same in-game day) | mood rises further in the log, but **NO second toast** (once-per-day anti-spam) and global stays **2.00** |
| 8 | `save moodtest`, then `load moodtest` | -- |
| 9 | `GetGlobalValue PDV_GLO_PatronMoodBand` | still **2.00** (mood persisted across save/load) |
| 10| MCM **Show piety map** | Kyne's piety/scratch retained |

## 4. Optional -- second cross + decay (proves one-toast-per-cross over days)
The toast anti-spam is per devotion-day, so to see more crossings you must
advance the day between dawns.
- Keep Kyne patron. Each cycle: `set gamedayspassed to <current+1>` (advances a
  day; you can read current via the console or just keep incrementing), MCM
  **Apply target scratch** (max) again, **Run dawn pass**.
- Over ~4-5 such days mood climbs past +55 -> **Exalted** -> a second
  "Kyne's regard warms toward you." + global **3.00**. One toast per crossing.
- Then set **Target scratch** to **0** and run several day-cycles -> mood decays
  toward 0 -> crosses back down -> **"Kyne's regard cools."** + global drops.

## 5. Reversion
Disable the mod in MO2, load a normal Devotion save -> no mood toasts, the global
is unused, shipped behavior returns.

---

## Pass / fail
| Check | Pass = |
|---|---|
| Mood reacts | global goes 1 -> 2 after one max-piety dawn (step 6) |
| Band-cross announces | "Kyne's regard warms toward you." fires on the cross (step 5) |
| Fires once | no duplicate toast on a same-day re-dawn (step 7) |
| Persists | global still 2 after save/load (step 9) |
| (opt) one-per-cross | each up/down crossing = exactly one toast (section 4) |
| Reverts | disabling the mod restores shipped behavior (section 5) |

## Troubleshooting
- **"Settling" message but never "warms toward you", global stuck at 1 (with Kyne
  patron + scratch applied):** you are on a **stale save** -- the old script is
  running. This is the #1 cause. Re-read section 0: exit to main menu, start a
  brand-new game or `coc qasmoke`, do NOT Continue an existing character. Confirm
  via the `Mood band cross` log check.
- **No MCM entry:** wait longer / re-open the Mod Config menu; SkyUI registers a
  beat after load.
- **Global reads "not found":** the plugin isn't ticked (right pane) -- the
  `PDV_GLO_PatronMoodBand` record lives in `PDV_MoodTeaserTest.esp`.
- **Toast but global stays 1:** you didn't make Kyne the patron (step 2) -- the
  global only mirrors the *active patron's* band.
- **Verify the right script won the file conflict:** MO2 -> right-click
  **Devotion - Living Deities - Mood Teaser** -> Information -> Conflicts ->
  `Scripts\PDV__ManagerQuest.pex` should show it **overwriting** Devotion. (It is
  already top-priority, so this should hold; check only if a fresh game still
  fails.)

---

## What got stripped vs the full LD-P1 engine
OnMoodBandCross: removed the demand-arm + SyncPatronBoonsToBand (kept the patron
mirror + toast). IsDeityInActivePool: removed the Hircine-curse branch. Dropped
entirely: demands, dream omens, ApplyMoodDelta, all boon-variant/clutch props.
PlayerEvents / EventBus / T3DailyLowHealthSaveEffect left vanilla.

## Build state (machine-proven, isolated -- Devotion mod byte-untouched)
Scripts `research/living-deities/teaser-src/` compile 0/0; tool
`tools/pdv-mood-teaser-author` --author/--check PASS; mod
`Devotion - Living Deities - Mood Teaser` (the global + manager VMAD override +
2 teaser pex). No JSON (defaults: alpha 0.15, bands -40/10/55); no SEQ.

## Feel caveat + V1 merge
Until the 313/343 non-combat faucet is runtime-proven, normal-play mood moves
mostly on kills (this debug runsheet bypasses that by injecting scratch piety).
V1 promote = copy the two teaser scripts into live Scripts\Source, compile via
tools/pdv_compile.mjs, author the global + manager prop into the framework ESP --
only after this smoke passes. Adds `PDV.Mood.*` save state, so it is a deliberate
V1 scope call.
