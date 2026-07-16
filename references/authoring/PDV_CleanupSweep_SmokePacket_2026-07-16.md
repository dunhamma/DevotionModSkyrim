# In-Game Smoke Packet -- Pre-1.0 Cleanup Sweep (2026-07-16)

**Scope:** the four behavior-touching changes in commit `47d6ad1f` only. This is
**not** a full 1.0 pass and closes **none** of the ten in-world gate buckets --
`PDV_1_0_CoTest_Runbook_2026-07-10.md` is still the sheet for those.

**Artifact under test:** `dist/Devotion-1.0-rc1-20260716.zip`
SHA256 `BD99DCC55EF848E6D1F7168039F54ED501A5E9874D081C8987CD1042B4194F5E`
(216 entries, 7.6 MB). **This zip already contains every change below** -- it was
built after the recompile. See "Repackaging" at the bottom before rebuilding.

**What changed and therefore what can break:**

| # | Change | Risk being tested |
|---|---|---|
| A1 | Deleted `Phase0PrismaChoiceTick` | Bridge/panel still intact after removing a Prisma caller |
| A2 | Hoisted `EnsureUnifiedStartupChoice`'s self-disable flag | Startup choice still fires |
| A3 | Disfavor sweep moved 1s -> 10s | Stings still clear (**the one real behavior change**) |
| A3 | Contextual favor deliberately left at 1s | Favor still reacts promptly |

---

## Preflight

1. **Disposable save.** Test 3 wants a fresh character; nothing here is
   save-safe by design.
2. **Unlock the dev tabs.** They are hidden by default since the 2026-07-16
   players-only MCM change -- a shipped copy renders no debug tab at all.
   Console: `set PDV_GLO_DebugLevel to 3`
   Then close and reopen the MCM. Six tabs should appear.
   (The in-code comment says "3"; the actual threshold is `>= 1`. Either works.
   `3` also raises trace verbosity, which you want for step 5.)
   Re-hide afterwards with `set PDV_GLO_DebugLevel to 0`.
3. **Confirm the quest-reaction queue is idle** before judging anything.
   MCM -> **Debug: State & Rewards** -> **Quest reaction queue**. A draining
   sweep runs for MINUTES and throws stray toasts and reward-sync races that
   look exactly like boon bugs. Do not start until it reads idle.
4. Papyrus logging on, if you want the step-5 log check.

All debug controls below are on **MCM -> Debug: State & Rewards**.

---

## Test 1 -- Disfavor still clears (A3) **[the critical one]**

This is the only test that exercises a real behavior change. A3 moved the expiry
sweep from every 1s to every 10s.

**Duration math:** a *light* sting lasts `0.0833333` days = **2 game-hours**;
*sharp* = **4 game-hours**. At default `timescale 20` that is 6 and 12 real
minutes -- too slow to watch. Accelerate:

```
set timescale to 200      ; 1 game-hour ~= 18 real seconds
```
A light sting now expires ~36 real seconds after firing. **Restore
`set timescale to 20` when done.**

All four controls are on **Debug: State & Rewards**, **left column**, under the
**"Disfavor (dislikes)"** header.

1. **Cycle disfavor band** -> set the label to **Light**.
2. **Cycle disfavor domain** -> pick any domain (1 Sky/Storm/Hunt .. 7 Void/Secrets).
3. **Apply domain sting** -> fires it.
   **Use this button, NOT "Fire dislike vs selected deity".** The two cyclers
   above feed *this* button only. "Apply domain sting" is the direct-seed path:
   it adds the selected domain+band spell with a real expiry and **bypasses the
   standing/repeat/cap gates**, which is exactly what an expiry test wants.
   "Fire dislike" is the organic dispatch and needs **Target piety >= 25** to pass
   the standing gate -- below that you get the piety loss and **no sting at all**,
   and it ignores your band/domain selection. It would look like a failure when
   nothing is wrong.
4. **Show active disfavor** -> confirm the sting is listed with its band and
   **remaining game-minutes**, and that the debuff is on your Active Effects.
5. Wait out the ~36s expiry, then keep watching for another ~15s.
6. **Show active disfavor** -> the sting must be **gone**, and the spell removed
   from Active Effects.

**PASS:** the sting clears within **~10 seconds** of its expiry.
**Expected and correct:** a lag of up to 10s. The old code cleared within ~1s.
**A short lag is the change working, not a bug -- do not report it as one.**
**FAIL:** the sting never clears, or survives past ~15s after expiry.

> Why 10s is safe: expiry is compared against **game** time. At timescale 20 a 10s
> real cadence is ~3 game-minutes of granularity on a 2-4 game-hour debuff. At the
> timescale 200 you are testing under, the same 10s is ~33 game-minutes -- so this
> test is *harsher* than live play. If it passes here it passes at 20.

7. **Anti-stack burst (4 domains)** -> clears disfavor, then fires four
   distinct-domain stings. Confirm the cap holds at **3 active with the 4th
   suppressed**, and that all three clear after expiry. (Regression check: the
   sweep now clears up to 3 domains in a single 10s pass rather than spread
   across ticks.)
8. **Clear active disfavor** -> confirm force-clear is still **immediate**. This
   path does not go through the sweep and must **not** have gained a 10s lag.

**Optional organic cross-check.** To exercise the real dispatch rather than the
direct seed: set **Target piety** to >= 25, **Apply target piety**, set a
**Dislike event ID** the selected deity actually has a row for (the "Fire dislike"
label tells you), then **Fire dislike vs selected deity**. This ignores the
band/domain cyclers and picks the domain from the dislike row. Not required for
A3 -- the direct seed already proves the sweep.

---

## Test 2 -- Contextual favor still reacts at 1s (A3 negative)

Proves A3 did not catch favor by mistake. Favor stays at 1s on purpose: it
re-checks eligibility and must react when you leave the triggering context.

1. **Cycle favor lane** -> **Kyne**.
2. **Trigger selected favor** -> confirm it activates.
3. Leave the triggering context (Kyne favor is weather/context gated -- go
   indoors or wait out the weather).
4. Favor must drop **promptly (~1s)**, not after ~10s.

**PASS:** prompt drop. **FAIL:** a ~10s lag here means the favor call was moved
into the throttle -- a real regression, stop and report.

5. **Clear active favor** -> confirm immediate expire.

---

## Test 3 -- Startup choice still fires (A2)

A2 reordered the gate so the completion flag is read *before*
`GetPlayerOriginRaceIndex()`. Semantics should be identical.

1. **New game / fresh save**, any race with an explicit startup path.
2. The unified startup choice must present as it always has.
3. Pick a path; confirm it applies and does **not** re-present on subsequent
   loads (the self-disable flag still latches).

**PASS:** choice fires once, latches. **FAIL:** never fires, or re-presents every
load (flag not latching).

> Note: `PDV.Startup.UnifiedChoiceComplete` is what latches. If you want to re-arm
> without a new character, clear that StorageUtil key on a disposable save.

---

## Test 4 -- Prisma bridge intact after A1

A1 deleted a Prisma caller. The bridge itself was untouched, but prove it.

1. Press the **Book of Days** hotkey (MCM -> Player -> "Book of Days key").
   Journal must open, render, and close cleanly.
2. Press the **Open Devotion panel** hotkey ("Open Devotion panel").
   Panel must open, take focus, and **ESC must close it**.
3. Open the panel from the MCM button too (the third entry point).
4. Confirm toasts still render (fire a dislike from Test 1 and watch for the
   toast).

**PASS:** all three entry points work, ESC releases focus.
**FAIL:** any cold-open focus trap or a panel that will not close.

---

## Test 5 -- Phase 0 is gone and nothing misses it

1. Console: `setpqv PDV__ManagerQuest DebugPrismaChoiceGo 1`
   **Expected: an error / unknown variable.** The property is deleted. If this
   *works*, the live `.pex` is stale against the shipped source.
2. Play normally for a few minutes. **No** "PDV Phase 0:" notifications should
   ever appear (they cannot -- the code is gone).
3. Papyrus log: no new errors referencing `Phase0PrismaChoiceTick`.

**Guardrail:** deleting Phase 0 must change nothing player-visible. If a Prisma
**choice-panel** regression appears, that means the choice channel had a
production consumer the review did not find -- **stop and re-verify rather than
patching around it.** (`ShowChoice`/`ConsumePendingChoice`/`SupportsChoice` are
intentionally left with no Papyrus caller: retained bridge capability for the
planned choice panel. `CancelChoice` keeps its caller in
`DebugClosePrismaSurfaces`.)

---

## Repackaging

**If all five tests pass: do not repackage.** `Devotion-1.0-rc1-20260716.zip`
(`BD99DCC5...`) already contains the recompiled `.pex` and cleaned source. It is
the artifact. Rebuilding it changes nothing but the mtime.

**Only repackage if a test fails and you change code.** Then, in this order --
getting it wrong drift-voids the machine gates:

```
1. fix the .psc   (edit BOTH the live tree and live-source/ -- pdv_compile.mjs
                   REFUSES to compile on tracked/deployed drift; it does not sync)
2. node tools/pdv_compile.mjs --script PDV__ManagerQuest
   node tools/pdv_compile.mjs --script PDV_MCM      ; ALWAYS after a manager recompile
3. node tools/pdv_1_0_endstate_gate.mjs --run       ; AFTER the last recompile, never before
4. node tools/pdv_package_release.mjs --version 1.0-rc1
5. node tools/pdv_package_release.mjs --verify dist/Devotion-1.0-rc1-<date>.zip
6. record the new SHA256 in PDV_Handoff_2026-07-16_NexusReleasePackaging.md
```

Never hand-roll the zip -- that is what shipped 876 KB of stale `.orig` in the
first build while the handoff claimed zero leakage.

**Renaming `1.0-rc1` -> `1.0` is still blocked** on the ten in-world buckets, none
of which this packet touches.

## Known-not-mine

The gate reads 11 PASS / 1 STALE / 11 RED. The eleventh RED
(`C-MAIN-QUEST-FULL-COVERAGE`) is a concurrent session's in-flight DB01 authoring
-- contract expects 1978 cells / 172 keys, live reports 1982 / 173. Not a defect,
not from this sweep, and not something to fix from this packet.
