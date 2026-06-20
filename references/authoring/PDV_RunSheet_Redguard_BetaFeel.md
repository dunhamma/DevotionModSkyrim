# PDV In-Game Run-Sheet -- Redguard (Requiem build B1 + B2)

Status: LIVE (build B1 + B2 core deployed 2026-06-20). Created 2026-06-20.
Provenance: this session's B1/B2 edits to live `PDV__ManagerQuest.psc`,
`PDV_ActionRouter.psc`, `PDV_Deity_HoonDing.psc`; the established run-sheet format
(`PDV_RunSheet_Imperial_BetaFeel.md`); `PDV_Phase20_RedguardProofPlacement_Runbook.md`
(QASmoke proof REFRs); `PDV_OpenDecisions_RulingMemo.md` decisions 6a/6b.

Tests the Requiem-build Redguard content: the **Tu'whacca death-rite heal**
(converted from swallowed HealRateMult), the **Ash'abah stigma** surfacing, and the
**HoonDing make-way rebuild** (dragon kills, road-passage reroute). The load-bearing
proof for the heal is in-game: the **HP bar actually moves** under a Requiem list.
Magnitudes are PROVISIONAL -- this run is also the tuning pass. Track status in
`PDV_RequiemSmokeTest_Tracker.md` (Sweep B1 + B2) and the manual ledger.

---

## Proof-boundary key
- **[R] ROUTE/RUNTIME** -- a Papyrus log marker / Trace line / numeric move. Objective.
- **[M] MANUAL-ACCEPTANCE** -- tester judgment (HP bar moved; "reads as earned").
Do not mix them when filling the ledger; do not mark a race-level `pass` from this sheet.

## Preflight (do once)
- New disposable save (or `coc qasmoke`). Redguard state inits only on a NEW save / `coc qasmoke`.
- MO2: DISABLE `Devotion - Living Deities Test`.
- Console seed:
  ```text
  set PDV_GLO_OriginRace to 9
  set PDV_GLO_DebugLevel to 2
  ```
  Origin index `9` is Redguard.
- Debug seeding is the MCM Debug page, NOT `cqf`. Use MCM Player -> Developer Options.
- Papyrus log: `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- Signal RefID prefix (for QASmoke proof REFRs): read the 2-hex plugin prefix `XX`
  once from a NAMED blessing, then reuse it:
  ```text
  help "HoonDing" 0
  ```
  Take the first two hex of the returned `SPEL:` FormID as `XX`. Fire a proof REFR with
  `prid XX<refid>` then `activate player` (NOT bare `activate`). The Redguard proof
  REFR EditorIDs/refids (incl. the **Ash'abah duty** signal) are in
  `PDV_Phase20_RedguardProofPlacement_Runbook.md`.

---

## Ordered evidence checklist

### Slot 1 -- assetStatus ([M], desk check)
- No new custom mesh is required for B1/B2: the Tu'whacca heal, Ash'abah stigma, and
  HoonDing make-way are script + existing-record changes; notices are top-left
  `Debug.Notification` fallbacks (no new MESG record). HoonDing Champion cheat-death
  save + named-boss FormList are DEFERRED (creation-authoring, task #11) -- not this run.
- PASS: no Redguard B1/B2 hook needs a new asset.

### Slot 2 -- surveyStatusClarity ([M])
- Seed (MCM): select Tu'whacca, `Apply target piety` ~85 (Champion); set sect/posture
  to Ash'abah (do a death-duty act, Slot 4) so the sect line reads Ash'abah.
- Open Survey Devotion. Watch the Redguard sect line:
  - Ash'abah branch reads the duty fiction ("the unclean dead are your charge...").
  - After death-duty acts, the **stigma line** appends: at stigma >=1 "You are
    death-touched: the mark of the duty is on you..."; at >=3 "You are hollow-eyed:
    the clean turn their faces...".
- PASS: sect + stigma read in plain narrator voice, no raw enum/counter leaking, and
  the stigma escalates legibly with kept duty.

### Slot 3 -- stackSnapshot ([R] numeric + [M] read)
- Lawful Tu'whacca build: Tu'whacca Champion, no death-duty yet. Active Effects shows
  the Tu'whacca ward (ResistMagic) -- and **NO standalone "Health Regeneration" effect**
  (the swallowed HealRateMult was removed in B1). `player.getav Health` is the baseline.
- Edge HoonDing build: switch active patron to HoonDing (MCM), Champion. Active Effects
  shows HoonDing's stat reward (OneHanded/SpeedMult). No make-way buff sits in the stack
  (make-way is a piety pulse, not an aura).
- PASS: Tu'whacca stack has ResistMagic but no rogue Health-Regen aura; HoonDing stack
  is the stat reward only; the two builds differ.

### Slot 4 -- immersiveHookProof (the Requiem-build core)

**4a. Tu'whacca death-rite heal -- RUNNABLE NOW ([R] + [M]):**
- Seed: select Tu'whacca, `Apply target piety` ~50 (Devoted) for the small heal, or ~85
  (Champion) for the large heal. Then damage yourself (e.g. `player.damageav health 150`
  or take a hit) so the HP bar is low.
- Fire a death-duty: activate the QASmoke **Ash'abah duty** proof REFR (`prid XX<refid>`
  + `activate player`) -- this routes `RouteRedguardAshAbahDeathDuty` ->
  `HandleRedguardAshAbahDeathDuty`. (Organic: an Ash'abah-coded undead/burial act.)
- Watch: the **HP bar jumps** (the load-bearing Requiem check). Log marker:
  `Redguard Tu'whacca death-rite heal fired ... tier=2 restore=30` (Devoted) or
  `tier=3 restore=50` (Champion). Fire death-duty AGAIN the same day -> the heal is
  once/day: `Redguard Tu'whacca death-rite heal suppressed (already restored today)`,
  HP bar does NOT move. The Far Shores token rite (`HandleRedguardFarShoresToken`) also
  fires the heal (same once/day key).
- PASS: HP bar moves on the first death-duty/Far-Shores rite of the day, scales with
  Tu'whacca tier, and does not re-heal the same day.

**4b. Ash'abah stigma -- RUNNABLE NOW ([R] + [M]):**
- Seed: continue from 4a (origin 9). Fire the death-duty proof REFR repeatedly.
- Watch: first death-duty -> top-left notice "The mark of the death-duty settles on
  you..." and log `Redguard Ash'abah stigma marked ... stigma=1 (was 0)`. Keep firing;
  at the 3rd act the band crosses to hollow-eyed: notice "The tomb-smell never fully
  leaves you now..." and `stigma=3 (was 2)`. Notices fire ONLY on a band crossing (no
  per-act spam). Confirm **piety did NOT drop** (text-only stigma -- check the Tu'whacca
  piety in MCM is unchanged by the stigma itself; the death-duty's own piety award is
  separate and positive).
- PASS: stigma builds with kept duty, surfaces in Survey (Slot 2) + a band-crossing
  notice, paired with the 4a heal, and applies NO piety penalty.

**4c. HoonDing make-way rebuild -- RUNNABLE NOW ([R]):**
- Seed: make HoonDing the ACTIVE focused patron (MCM select HoonDing + `Apply target
  piety` ~30 so it is active). Make-way gates on `_activeDeity == PDV_HoonDing`.
- Kill a DRAGON with your own killing blow (a wild dragon, or `player.placeatme` a dragon
  base then land the final hit). Watch: `HoonDing make-way fired: breakthrough dragon
  kill multiplier=1`, and HoonDing piety rises. Kill a SECOND dragon the same day ->
  `multiplier` is decayed (~0.7, soft-decay), smaller award. A generic bandit/draugr kill
  -> NO make-way marker (negative; only dragons qualify in V1).
- Road-passage NEGATIVE: trigger a Forebear road-passage act -> it routes to the Forebear
  lane / Leki (if Leki active), and does NOT fire `HoonDing make-way` (make-way left
  road-passage in B2). The old weekly-cap suppression line no longer appears.
- PASS: dragon kill fires make-way once, a same-day 2nd dragon soft-decays, a generic kill
  and a road-passage do NOT fire make-way.

**4d. Namira heal-on-feed -- cross-race ([R] + [M], use the Daedric packet):**
- Namira is Daedric (not Redguard origin) -- test under the Daedric smoke packet. Quick
  check: on a Namira-path character at tier >= Seeker, feed (cannibalism via the Ring of
  Namira / a Namira-coded corpse). HP bar pulses; log `Namira feed-heal fired tier=N ...`;
  repeated feeds the same day soft-decay. NOTE: the Namira boon DESCRIPTION still reads
  "+health regen" until the deferred Daedric-contract cleanup (task #10) -- the felt
  effect is the feed-heal.

### Slot 5 -- wrongOriginRejection ([R])
- `set PDV_GLO_OriginRace to 0` (Nord). Fire the Ash'abah duty proof REFR.
- Watch: NO Redguard sect/stigma/heal movement; no Tu'whacca death-rite marker; HP bar
  does not move. A non-Redguard origin cannot drive Redguard-native state.
- Reset: `set PDV_GLO_OriginRace to 9`.

### Slot 6 -- genericHookRejection ([R], negative class)
- Origin 9. Spot-check that non-Ash'abah acts do not score the Redguard sect/stigma, and
  that non-dragon kills do not fire make-way: kill a bandit (no make-way), clear a generic
  crypt without an Ash'abah-coded duty (no stigma), pay a bounty (nothing).
- PASS: generic combat, generic dungeon clears, and faction/bounty do NOT move
  Redguard-native state or fire make-way.

### Slot 7 -- manualFeelNote ([M])
- Across the session, judge: does the Tu'whacca reward now FEEL real (HP visibly restored
  at the death-rite) where before it was an invisible regen %? Does the Ash'abah stigma
  read as an earned social weight (not a punishment)? Does HoonDing make-way feel like a
  marked breakthrough (a dragon falling) rather than a road-walk toggle?
- Record 1-2 sentences + the magnitudes that felt right (for tuning: Tu'whacca 30/50,
  HoonDing decay, Namira 20/30/40).

---

## Known gotchas
- **HP-bar proof needs a Requiem list.** Under vanilla regen the heal still adds flat HP,
  but the POINT is that it works where a HealRateMult would be swallowed -- prove it under
  the actual Requiem load order.
- **Tu'whacca heal is once/day** (`PDV.Redguard.TuwhaccaDeathRiteHealDay`). Damage
  yourself before each test; a second same-day rite logs "suppressed".
- **Make-way needs HoonDing ACTIVE** (`_activeDeity == PDV_HoonDing`). A HoonDing-patron
  Redguard; otherwise dragon kills do not fire make-way (by design).
- **V1 make-way = dragons only.** Named bosses / quest milestones / final bosses need the
  deferred curated FormList (task #11) -- do NOT FAIL a non-dragon kill for "no make-way".
- **Stigma is per death-duty act** (caps at 5), notice only on band crossing. It does NOT
  decay and applies NO piety penalty.
- **`coc` skips location triggers.** Walk/fast-travel into cells for any location-anchored
  Redguard act; do not `coc` straight in.
- **MCM only, not cqf.**

---

## Record results here
Allowed: PASS / FAIL / PENDING / N-A. Label the proof class achieved.

| Slot | Surface | Proof | Status | Note |
|---|---|---|---|---|
| 1 assetStatus | No new mesh for B1/B2 | [M] | | |
| 2 surveyStatusClarity | Ash'abah sect + stigma line legible | [M] | | |
| 3 stackSnapshot | Tu'whacca ward, no rogue Health-Regen aura; HoonDing stat reward | [R]+[M] | | |
| 4a Tu'whacca death-rite heal | HP bar moves; tier 30/50; once/day | [R]+[M] | | |
| 4b Ash'abah stigma | builds + band-crossing notice; NO piety drop | [R]+[M] | | |
| 4c HoonDing make-way | dragon fires once; 2nd decays; generic/road negative | [R] | | |
| 4d Namira feed-heal (Daedric packet) | HP pulse on feed; daily decay | [R]+[M] | | |
| 5 wrongOriginRejection | Nord origin: zero Redguard movement | [R] | | |
| 6 genericHookRejection | generic kills/clears/bounty do not score | [R] | | |
| 7 manualFeelNote | reads as earned; record tuning magnitudes | [M] | | |

After the run: capture the Papyrus log before rotation, fill
`PDV_Phase20_ManualEvidenceLedger.json` (Redguard + Daedric/Namira blocks) honoring the
proof boundary, then update `PDV_RequiemSmokeTest_Tracker.md`. Do NOT mark the Redguard
race-level `status` as `pass` from this sheet -- keep it `pending` until recorded.
