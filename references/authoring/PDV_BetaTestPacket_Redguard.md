# PDV Beta Test Packet - Redguard

Created: 2026-06-06
Status: ready to run - ancestor-spine book packet; sect/death-duty edge proof pending
Mode: console-assisted beta-feel packet

This packet starts Redguard beta-feel proof from the approved ancestor-spine
book source. It does not prove Crown/Forebear branch behavior, Ash'abah death
duty, Far Shores token, or HoonDing cap by itself.

Gated behavior note (2026-06-13): the Redguard sect no longer flips on the first
signal. Crown<->Forebear now needs two sect-coded evidence days within seven plus
a 3-day lock-in; Ash'abah is entered only by a marked burden reason
(redguard_ashabah_burden / redguard_deathduty_major), not casual undead; and the
HoonDing make-way signal is weekly-capped. Score sect/HoonDing expectations
against this gated behavior, not first-signal flips.

Use a disposable save for every block below. Origin index `9` is Redguard.

## Expected Build - Ancestor Spine

Set the origin gate, then add and read the approved Redguard book:

```text
set PDV_GLO_OriginRace to 9
set PDV_GLO_DebugLevel to 2
player.additem 0001ACD1 1
```

Read the book normally from inventory:

- `0001ACD1` - `Book2CommonManualMixedUnitTactics`.

Expected in game:

- Top-left notification only, unless a separately proven toast surface is in
  focus.
- No forced full Prisma panel.
- Survey Devotion explains sect posture, ancestor-spine pressure, death-duty
  state, and Far Shores/HoonDing cap state without debug labels.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race redguard --strict-manager
```

Expected log marker:

```text
RouteRedguardAncestorSpine complete: po3_book_redguard_spine
```

## Edge Build - Ash'abah Or HoonDing Pressure

> Deferred: Ash'abah / HoonDing / Crown-Forebear / Far Shores reward and cap
> levers pending exact approved source metadata (MS08, undead, vampire-cure);
> tracked in the GAP ledger. No runnable step this pass.

## Silence Checks

Run these two no-movement assertions back to back on the same save; both share
the same Survey/no-reward observation.

Wrong-origin check (origin 8 = not Redguard):

```text
set PDV_GLO_OriginRace to 8
player.additem 0001ACD1 1
```

Read the book. Expected: no Redguard manager state, reward, or Survey movement.

Generic-source silence (reset to origin 9 once; this is the only origin-9 reset
needed here):

```text
set PDV_GLO_OriginRace to 9
```

Try generic combat, undead clearing, fast travel, tomb proximity, random sword
use, faction membership, or Arkay shrine use. Expected: no Redguard state
movement (this also confirms the Arkay-not-Tu'whacca substitution guard).

Observe once and report both assertions: origin 8 = wrong-origin rejection;
origin 9 + generic acts = generic-source silence.

## Evidence To Bring Back

```text
Redguard expected build: PASS/FAIL
Redguard sect/death-duty edge: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Survey/status clarity: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

## Trim log (2026-06-13)

- CUT: "Edge Build - Ash'abah Or HoonDing Pressure" was entirely PENDING with no
  runnable step; replaced with a single deferred GAP-ledger pointer line so the
  Ash'abah/HoonDing/Crown-Forebear/Far Shores levers are not forgotten.
- MERGE: folded the standalone "Preflight" section's set-commands into each test
  block; dropped the duplicate origin-9 set (kept one explicit reset in the
  Silence Checks block after the origin-8 wrong-origin run).
- MERGE: combined "Wrong-Origin And Generic Silence" into one "Silence Checks"
  block with both distinct assertions (origin 8 = wrong origin; origin 9 +
  generic acts = generic silence) sharing one observe-and-report step.
- ADD: gated sect/HoonDing behavior note (two evidence days within seven +
  3-day lock-in for Crown<->Forebear; Ash'abah only by marked burden reason;
  HoonDing weekly-capped).
- Step count: 6 -> 4.

## Current-Build Refresh (2026-06-14) -- PART RUNNABLE, PART WAITS ON BUILD PASS

The sect no-flip gate (build-batch test 7) and the Far Shores token are runnable
now. The Dawnguard-cure -> Ash'abah re-entry stage source is being wired by the
concurrent build pass; its step is marked **PENDING build-pass confirmation**.
Items above stay valid.

Cross-cutting reminders:
- State inits ONLY on a NEW save / `coc qasmoke`; disable `Devotion - Living
  Deities Test` in MO2 first.
- Debug seeding is the MCM Debug page, NOT `cqf`. Standard `set` / `coc` only.
- PDV `PDV_REFR_*Signal` objects are INVISIBLE; fire by RefID: prefix XX off
  `help "HoonDing" 0`, then `prid XX<refid>` + `activate player`.

Redguard signal RefIDs (framework ESP): Crown `07102B`, Forebear `07102C`,
AshAbah `07102D`, FarShores `07102E`.

### Sect no longer flips on one act (build-batch test 7) -- runnable now

1. `set PDV_GLO_OriginRace to 9`, `set PDV_GLO_DebugLevel to 2`, `coc qasmoke`.
2. Survey -> sect is **Forebear** (default).
3. `prid XX07102B` then `activate player` once (Crown signal) -> sect **stays
   Forebear**. **PASS = no flip on a single signal.** (Two Crown evidence days
   in seven would switch it.)

### Far Shores token (unconditional V1) -- runnable now

`PDV_Bless_Redguard_FarShoresToken` is the unconditional V1 support surface
(ResistMagic 5% anywhere, daily-capped -- NOT a 3rd always-on boon family).

1. `prid XX07102E` then `activate player` once (Far Shores signal) ->
   `HandleRedguardFarShoresToken` routes (Tu'whacca `SIGNAL_FAR_SHORES_TOKEN`),
   granting the support spell after daily-capped token proof.
2. Fire it again the same day -> daily-capped (`ConsumeDailyRepeatMultiplier`),
   no second full grant. **PASS = grant once + daily cap holds.**

### Vampire-cure -> Ash'abah re-entry

- GENERIC vampire cure already drives re-entry (live): origin 9, `Curse vampire`
  then `Curse none` -> `ApplyRedguardCurseHandlers` +
  `PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry`. Runnable now.
- DAWNGUARD-cure exact stage (DLC1VQ02) -> Ash'abah burden re-entry is the
  build-pass addition to `PDV_FLST_P2_RedguardAshAbahSources` -- **PENDING
  build-pass confirmation**. Cure vampirism through the actual Dawnguard cure
  quest stage and confirm Ash'abah re-entry routes from that specific source.

Ash'abah entry/exit is a category-gate (reason `redguard_ashabah_burden`: major
death, undead, tomb, funerary duty), not a numeric threshold; the HoonDing
make-way signal is weekly-capped (see the gated-behavior note above).

### Neglect vanilla top-left fallback + Survey recent-events

Neglect line `<Deity>'s regard fades as your devotion goes quiet.` now fires
top-left. Survey lists recent beats in fiction voice.
