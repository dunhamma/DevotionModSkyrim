# PDV In-Game Run-Sheet -- Redguard (Requiem build B1 + B2)

Status: LIVE (build B1 + B2 + Requiem-tail records deployed 2026-06-20). Created 2026-06-20.
Provenance: this session's B1/B2 edits to live `PDV__ManagerQuest.psc`,
`PDV_ActionRouter.psc`, `PDV_Deity_HoonDing.psc`; the established run-sheet format
(`PDV_RunSheet_Imperial_BetaFeel.md`); `PDV_Phase20_RedguardProofPlacement_Runbook.md`
(QASmoke proof REFRs); `PDV_OpenDecisions_RulingMemo.md` decisions 6a/6b.

Tests the Requiem-build Redguard content: the **Tu'whacca death-rite heal**
(converted from swallowed HealRateMult), the **Ash'abah stigma** surfacing, the
**HoonDing make-way rebuild** (dragon/listed-boss kills, road-passage reroute,
Champion low-health save), and the **Ash'abah cleared-undead-site** hook. The
load-bearing proof for the heal is in-game: the **HP bar actually moves** under a
Requiem list.
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
- Debug seeding is the MCM Debug page, not CallQuestFunction. Use MCM Player -> Developer Options.
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
- No new custom mesh is required for B1/B2/tail: the Tu'whacca heal, Ash'abah stigma,
  HoonDing make-way, HoonDing Champion low-health save, named-boss FormList, and
  Ash'abah cleared-site hook are script + existing-record changes. Notices are top-left
  `Debug.Notification` fallbacks where used; the low-health saves use hidden script-host
  effects.
- PASS: no Redguard B1/B2/tail hook needs a new asset.

### Slot 2 -- surveyStatusClarity ([M])
- Seed: choose the **Ash'abah sect at the Redguard startup choice** (a new save as
  origin 9 prompts it) so the Survey sect line reads Ash'abah. NOTE: mid-game switching
  INTO Ash'abah is now wired (2026-06-20) -- a UNIQUE/named-undead defeat routes a marked
  burden that flips the sect (see Slot 6b + gotchas) -- but starting as Ash'abah is still
  the quickest seed for the stigma/heal tests below. Then select Tu'whacca,
  `Apply target piety` ~85 (Champion).
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
  `multiplier` is decayed (~0.7, soft-decay), smaller award.
- Listed-boss positive: kill one V1 listed boss with your own killing blow (for example
  a named dragon priest or another base in `PDV_FLST_HoonDing_BreakthroughBosses`).
  Expected: make-way fires through the listed-boss route and uses its separate daily
  decay key.
- Negative: a generic bandit/draugr kill -> NO make-way marker.
- Road-passage NEGATIVE: trigger a Forebear road-passage act -> it routes to the Forebear
  lane / Leki (if Leki active), and does NOT fire `HoonDing make-way` (make-way left
  road-passage in B2). The old weekly-cap suppression line no longer appears.
- PASS: dragon kill fires make-way once, a same-day 2nd dragon soft-decays, a generic kill
  and a road-passage do NOT fire make-way, and one listed boss fires through the new
  boss route.

**4c2. HoonDing Champion low-health save -- RUNNABLE NOW ([M] + [R]):**
- Seed: HoonDing active, Champion tier, with `PDV_Bless_Redguard_HoonDing_T3` active.
- Drop below 20% Health. Expected: the hidden `PDV_T3DailyLowHealthSaveEffect` route
  fires from `PDV_MGEF_Redguard_HoonDing_T3_AvoidDeath` with storage key
  `PDV.Capstone.LowHealthSave.HoonDing`; the save fires once/day only.
- PASS: the first low-health edge saves the player once, same-day repeat does not.

**4d. Namira heal-on-feed -- cross-race ([R] + [M], use the Daedric packet):**
- Namira is Daedric (not Redguard origin) -- test under the Daedric smoke packet. Quick
  check: on a Namira-path character at tier >= Seeker, feed (cannibalism via the Ring of
  Namira / a Namira-coded corpse). HP and Stamina bars pulse; log
  `Namira feed-heal fired tier=N ...`; repeated feeds the same day soft-decay. The
  three passive Namira boon magnitudes now read back as zero compatibility placeholders,
  and the boon descriptions say feeding restores Health and Stamina.

### Slot 5 -- wrongOriginRejection ([R])
- `set PDV_GLO_OriginRace to 0` (Nord). Fire the Ash'abah duty proof REFR.
- Watch: NO Redguard sect/stigma/heal movement; no Tu'whacca death-rite marker; HP bar
  does not move. A non-Redguard origin cannot drive Redguard-native state.
- Reset: `set PDV_GLO_OriginRace to 9`.

### Slot 6 -- genericHookRejection ([R], negative class)
- Origin 9. Spot-check that non-Ash'abah acts do not score the Redguard sect/stigma, and
  that non-dragon/non-listed kills do not fire make-way: kill a bandit (no make-way),
  clear a non-listed clearable dungeon (no Ash'abah cleared-site credit), pay a bounty
  (nothing).
- PASS: generic combat, non-listed dungeon clears, and faction/bounty do NOT move
  Redguard-native state or fire make-way.

### Slot 6b -- Ash'abah mid-game entry ([R] + [M])
- Seed: a **Crown or Forebear** Redguard (origin 9; do NOT start as Ash'abah for this one).
  Confirm the Survey sect line reads Crown/Forebear.
- POSITIVE: land the **player's own killing blow on a UNIQUE/named undead** -- e.g.
  `player.placeatme` a Dragon Priest base (Krosis/Morokei) or a named lich, then kill it
  (or fight one in its barrow). Also test one unique hostile living humanoid in
  `NecromancerFaction` or `WarlockFaction`. Watch: `Redguard Ash'abah major burden fired`
  + the Ash'abah **sect-entry notice**, and the Survey sect line now reads Ash'abah. The
  death-rite heal + stigma also fire (shared rewards).
- NEGATIVE: kill a **routine draugr/skeleton** (not Unique). Watch: NO major-burden marker,
  NO sect switch (it stays Crown/Forebear) -- casual undead fighting is not a marked burden.
  A second same-day named-undead kill soft-decays (`...major burden decayed out for today`).
- PASS: a named-undead defeat flips the sect to Ash'abah once; routine undead do not; the
  necromancer/warlock route works for unique hostile humanoids; and routine undead do not.
  The switch carries the entry notice + heal + stigma.

### Slot 6c -- Ash'abah cleared-undead-site burden ([R] + [M])
- Seed: origin 9. For mid-game-entry proof, start Crown or Forebear; for duty/reward proof,
  starting as Ash'abah is fine.
- Positive: walk or fast-travel into an approved clearable undead site while it is still
  uncleared, clear it, and leave the location if the final kill does not immediately trip
  the cleared state. Approved sites are the 43 entries in
  `PDV_FLST_RedguardAshAbahUndeadClearSites` (draugr crypts, vampire lairs, and
  dragon-priest lairs with `LocTypeClearable`).
- Expected: `redguard_ashabah_burden_undead_site_clear` routes once for that site,
  applying the Ash'abah duty path, sect/reward/stigma movement where eligible, and then
  consuming the site key.
- Negative: clear a non-listed clearable dungeon. Expected: no cleared-site burden.
- Old-save guard: a site must have been observed while uncleared before it can pay, so
  saves that already cleared a site before this build should not retroactively gain credit.
- PASS: one approved newly-cleared site pays once; repeated clears or already-consumed
  sites do not; a non-listed site stays silent.

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
- **V1 make-way = dragons plus the conservative named-boss FormList.** Generic kills
  still do not qualify. Major quest milestones and unlisted final bosses remain outside
  this V1 route unless their victim base is in `PDV_FLST_HoonDing_BreakthroughBosses`.
- **Stigma is per death-duty act** (caps at 5), notice only on band crossing. It does NOT
  decay and applies NO piety penalty. The marked-moment NOTICE fires on any Ash'abah-coded
  death-duty regardless of sect; the Survey STIGMA LINE only shows for an Ash'abah-sect
  player -- so start as Ash'abah to see both.
- **Mid-game Ash'abah entry is now wired (2026-06-20 fix).** Previously the sect-switch
  gated on `IsRedguardAshAbahBurden(reason)` but no caller ever produced the marked token
  (the live death-duty reason is always `eventbus_<N>`), so only the startup choice set
  Ash'abah. Now `PDV_Manager.HandleRedguardAshAbahMajorBurden` (hooked off
  `PDV_ActionRouter.HandleStoryKillActor`) fires on the player's killing blow against a
  **UNIQUE/named undead** (lich, Dragon Priest, named draugr overlord -- `ActorBase.IsUnique`),
  routing a death-duty with reason `"redguard_deathduty_major"`, which the gate accepts and
  flips the sect to Ash'abah. Routine draugr/skeletons are NOT Unique, so casual undead
  fighting still cannot switch sect. The Requiem-tail closeout also accepts unique hostile
  living humanoids in `NecromancerFaction` or `WarlockFaction`, and approved clearable
  undead sites through the separate armed clear-site hook. Costly impurity choices remain
  future design space.
- **Ash'abah cleared-site credit is armed while uncleared.** Enter or visit the approved
  location before it is cleared, then clear it. This prevents existing saves from getting
  retroactive credit for already-cleared dungeons.
- **`coc` skips location triggers.** Walk/fast-travel into cells for any location-anchored
  Redguard act; do not `coc` straight in.
- **MCM only, not CallQuestFunction.**

---

## Embedded Prisma Checks

Run these during the Redguard evidence pass:

- Ancestor-spine book, Ash'abah duty, Far Shores token, HoonDing make-way, curse transitions, and neglect may emit toasts or top-left notices; none should force-open the full Prisma panel.
- Manually open the Devotion panel after one accepted Redguard route and after one curse transition. It should open populated and close with ESC or X.
- Chronicle / Book of Days should not create blank entries for sect, duty, or dawn digest beats.
- Ledger should show accepted Redguard driver rows and stay unchanged after wrong-origin or generic-source probes.
- Curse-cycle Prisma/toast state must agree with Survey and MCM state; if a right-side toast is missed but the log and manager state are correct, record it as UI evidence missing, not route failure.
- Save/load after an Ash'abah or Tu'whacca stack snapshot and confirm Survey, Active Effects, and Prisma remain consistent.

Prisma failures are UI failures unless route logs, manager state, or Active Effects also fail.

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
| 4c HoonDing make-way | dragon/listed boss fires; generic/road negative | [R] | | |
| 4c2 HoonDing Champion save | low-health save fires once/day | [R]+[M] | | |
| 4d Namira feed-heal (Daedric packet) | HP pulse on feed; daily decay | [R]+[M] | | |
| 5 wrongOriginRejection | Nord origin: zero Redguard movement | [R] | | |
| 6 genericHookRejection | generic kills/non-listed clears/bounty do not score | [R] | | |
| 6b Ash'abah mid-game entry | named undead or unique hostile necromancer/warlock flips sect; routine undead do not | [R]+[M] | | |
| 6c Ash'abah cleared-undead site | approved newly-cleared site pays once; non-listed stays silent | [R]+[M] | | |
| 7 manualFeelNote | reads as earned; record tuning magnitudes | [M] | | |
| 8 Prisma surfaces | toast/panel/Chronicle/Ledger agree with manager state | [M] | | |

After the run: capture the Papyrus log before rotation, fill
`PDV_Phase20_ManualEvidenceLedger.json` (Redguard + Daedric/Namira blocks) honoring the
proof boundary, then update `PDV_RequiemSmokeTest_Tracker.md`. Do NOT mark the Redguard
race-level `status` as `pass` from this sheet -- keep it `pending` until recorded.
