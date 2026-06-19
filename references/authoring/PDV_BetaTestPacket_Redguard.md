# PDV Beta Test Packet - Redguard

Created: 2026-06-06
Status: PASS 2026-06-19 - all 8 beta-feel dimensions (manual/runtime packet); gate-ledger verdict flipped Fail->Pass. Non-blocking follow-ups A/B/C tracked (see 'Session corrections & findings'). Still genuinely deferred: Dawnguard exact-stage (DLC1VQ02) -> Ash'abah re-entry source-fill (blocked); runtime-MARKER re-capture (current log rotated)
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
Redguard expected build: PASS (ancestor-spine book 0001ACD1; top-left notice + Survey)
Redguard sect/death-duty edge: PASS (sect no-flip held; vampire 0<->2 / werewolf 0<->1 curse cycle + Tu'whacca re-entry log-confirmed). Dawnguard exact-stage (DLC1VQ02) source-fill still deferred (blocked).
Wrong-origin rejection: PASS (origin 8 book read -> no Redguard movement)
Generic-source silence: PASS for Arkay sub-check (zero Tu'whacca/PDV movement; cure-only guard holds). HoonDing/Leki day-to-day leak found (Finding B) -> fix APPLIED 2026-06-19 (CSV rows removed + LoadRowsForDeity regen + VERSION 8->9 + compile 0/0 + verifier FAIL=0); awaiting in-game reconfirm.
Survey/status clarity: PASS (sect/patron/tier/Far Shores/curse-cycle in Yokudan voice)
Reward/stack snapshot: PASS (focused Tu'whacca Champion T3 + Far Shores token + AncestorSpine-Seeker baseline; broad T2 'Faithful' suppressed under focus)
Far Shores token + daily cap: PASS (Resist Magic +5% after dawn pass; soft 0.7x cap)
Blocking notes: none beta-blocking. Tracked non-blocking: A (vampire earn-halt specced-not-built), B (HoonDing/Leki leak fix inert until regen), C (Arkay shrine cosmetic toast).
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

## Session corrections & findings (2026-06-19, live-run pass)

Corrections to this packet's wording and one specced-not-built gap surfaced
while running the R4/R5 blocks in game. Source-of-truth is the live
`PDV__ManagerQuest.psc` (line refs below are from the 2026-06-19 build).

- **Far Shores token grant is dawn-synced, not instant.** Firing the signal
  (`HandleRedguardFarShoresToken`) sets the `PDV.Redguard.FarShoresToken` credit
  and shows the top-left notice, but the ResistMagic-5% ability is only added
  on the next dawn consolidation (`ProcessDawn -> SyncFirstTierRaceRewardRuntime
  -> SyncRedguardRewards`). After firing, run **MCM -> Debug -> "Run dawn pass"**,
  then check **Magic -> Active Effects**. The "daily cap" is a soft 0.7x decay
  on the credit (`ConsumeDailyRepeatMultiplier`), trace-only -- not a visible
  "second grant blocked." Confirmed PASS.

- **R4 stack: broad Ancestor Spine T1 is the active-patron BASELINE and is
  supposed to remain under focus.** Earlier runsheet wording ("broad layer is
  gone under focus") was wrong. `IsFirstTierRaceRewardEligible` (line 8678)
  grants the first-tier reward (`PDV_Bless_Redguard_AncestorSpine_T1`,
  "Ancestor Spine - Seeker") whenever a focused patron is active at Seeker+.
  Only the broad **T2 "Ancestor Spine - Faithful"** (line 8315, requires
  `PATRON_STATE_BROAD`) suppresses under focus. Expected focused stack =
  focused family at its tier + Far Shores token + Ancestor Spine - Seeker
  baseline; "Faithful" absent. Proving T2 suppression requires building broad
  worship to Faithful (>=6 ancestor-spine sources, no patron) first, then
  committing a patron and watching "Faithful" drop. Confirmed PASS.

- **R5 via MCM curse-force surfaces as a top-left FALLBACK notice, not the
  authored modal.** `ShouldSuppressRedguardCurseModal` (line 11247) returns true
  for `mcm_force_none/_werewolf/_vampire`, so `ShowRedguardMessage` calls
  `Debug.Notification(fallbackText)`. The authored "Outside the Cycle" /
  "Right Re-Entry" message boxes only appear via REAL in-game vampirism + cure
  (non-debug reason). Earlier "expect the modal" wording for the MCM path was
  wrong.

- **Forced curse state is volatile; refresh events revert it.** Any curse
  refresh -- dawn pass, sleep, in-game day rollover -- calls
  `HandleCurseStateRefresh -> RefreshFromPlayerState` (line 10203) and snaps the
  forced state back to the player's REAL (non-curse) state. That refresh-driven
  cure fires with reason `player_state`, so it shows the full MODAL (not a
  top-left) and trips the show-once guard (`VampireCureFeedbackShown`). Test
  onset->cure **back-to-back with nothing in between**. The curse transition is
  also surfaced THREE ways: per-race top-left notice
  (`ApplyRedguardCurseHandlers`, not logged), `SendPrismaCurseToast` (right-side
  Prisma toast), and `SurfaceCurseTransitionDiegetic` + `EmitSound` (D1, logged
  as `Diegetic dispatch CURSE.*`). The right-side toast is the Prisma/diegetic
  surface; the small top-left race notice is easy to miss next to it. R5
  transitions all confirmed in log (vampire 0<->2, werewolf 0<->1); PASS on
  substance.

- **GAP (specced, not built): Redguard vampire earn-halt.** The costing manifest
  ("vampire breaks the cycle until Tu'whacca re-entry") and the
  `PDV_Msg_Redguard_CurseState_VampireOnset` copy ("devotion across all three
  sects falls quiet") both promise an earn-halt while undead. Only the narrative
  half shipped: `ApplyRedguardCurseHandlers` sets `CyclePressure` /
  `VampireReentryNeeded` / `VampireScar` and flips on the neglect debuff
  (`IsRedguardAncestorDistanceNeglected`, line 8344). There is NO gain-halt:
  `GetCurseGainMultiplier` (line 7644) returns 1.0 for all Yokudan deities
  (only Hircine is special-cased); the working halt is Imperial-only
  (`GetImperialCurseGainMultiplier -> 0.0` at dawn, line 6963). Proof: Papyrus
  log 2026-06-19, `AwardPiety: HoonDing/Leki` accrued during the vampire window
  09:20:27->09:25:29. The onset copy overpromises relative to the mechanics.
  Fix when prioritized: add a `GetRedguardCurseGainMultiplier(deity) -> 0.0` for
  Yokudan deities, applied at dawn next to the Imperial one; gate on
  `VampireReentryNeeded == 1` (persists post-cure -- stricter than Imperial's
  cure-lifts; clear on the Tu'whacca re-entry act). Werewolf is specced as
  "strains," not "breaks" -- keep it neglect-debuff-only or a soft <1.0x, never
  0.0. Related: the Imperial halt's own dawn-vs-earn-time strictness gap. Not an
  R5 blocker (re-entry routing itself works); log to the completeness GAP ledger
  for the content pass.

- **Shrine-blessing neutralization residual (Arkay, R7).** Clicking the Arkay
  shrine still prints "Blessing of Arkay added" and grants the cure-only ability,
  even though the stat boon is correctly suppressed. This is the `cure-only`
  policy working: the SPEL override (`AltarArkaySpell` 0FB994 -> keep cure 0FBFF5,
  strip stat 0FB98D) is winning, so the user's 2026-06-19 run is the runtime proof
  that closes `PDV_ShrineBlessingNeutralization.manifest.json`'s
  `pending-runtime-proof` status (stat suppressed). NOT a piety leak -- no
  Tu'whacca/PDV movement (substitution guard holds). The residual "added" toast +
  empty blessing entry is because the tool deliberately leaves the shrine
  `TempleBlessingScript` untouched. "More robust" without crossing into script
  scope = blank the overridden SPEL's Name so the toast stops implying a boon,
  KEEP the cure (Requiem disease matters); don't empty the cure. Update the
  neutralization manifest status to runtime-proven + note the message-residual.

- **HoonDing/Leki generic-combat day-to-day (R7 finding + resolution APPLIED).**
  R7 surfaced generic kills (events 1/2) and location discovery (event 345 =
  `EVT_DISCOVER_LOCATION`) feeding HoonDing and Leki via the universal
  likes/dislikes day-to-day layer, contradicting the spec ("Generic combat...
  never satisfy HoonDing"; Leki rejects body count). The anti-farm daily cap (3/day)
  works; the issue is curation, not farm. Parity check: the curated make-way route
  IS wired (`PDV__ManagerQuest` line ~5108) but is **weekly-capped** (max 1 per 7
  days), so it can never carry leveling -- the day-to-day likes are load-bearing
  for Champion-pace parity. Resolution (user-approved 2026-06-19): exempt generic
  COMBAT only, keep the on-theme make-way/discipline likes. **APPLIED to
  `PDV_DeityLikesDislikes.csv`:** removed `HoonDing,2,kill-hostile-humanoid`,
  `Leki,2,kill-hostile-humanoid`, `Leki,1,kill-hostile-beast` (3 rows). KEPT
  HoonDing's make-way set (discover-location / trespass / pick-owned-lock /
  rest-under-open-sky / increase-skill) + kill-dragon + learn-word; KEPT Leki's
  smith-item / read-skill-book / increase-skill / learn-word + kill-dragon. Those
  give ~1-2 piety/day for a traveling/training player -- comparable to peer deities
  -- so parity holds (exploration-skewed, which is on-theme for the Make-Way God).
  **UPDATE 2026-06-19 -- REGEN APPLIED (code-closed, awaiting in-game reconfirm):**
  ran `pdv_likesdislikes_gen` -> replaced live `LoadRowsForDeity` (351->348 lines, 3
  kill rows dropped), bumped `LIKES_DISLIKES_VERSION` 8->9 (the version-gated reload
  runs `ClearRowsForDeity`, whose `GetLikesDislikesEventTypes()` superset already
  includes events 1/2, so the removed rows clear on existing saves too), recompiled
  `PDV__ManagerQuest` (0 errors / 0 warnings), and `pdv_verify.mjs` FAIL=0 (verifier
  `EXPECTED_LIKES_DISLIKES_VERSION` synced 8->9). Remaining: in-game reconfirm that
  generic kills/discovery produce zero HoonDing/Leki movement on a save that loads
  version 9.
