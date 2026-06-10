# A3 Interventions -- Feasibility Assessment

**Status:** DESIGN DOSSIER, 2026-06-10. Source-traced against live PDV source
(`D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`). No CK or runtime
proof. Honesty bar = `03_feasibility.md`: every path traced to a real function name;
unknown seams become explicit proof items. Line numbers drift; names are the contract.

**Precondition:** all items below presuppose LD-P1 is built and runtime-proven (mood
EWMA, band-cross dispatch, OnMoodBandCross, SyncPatronBoonsToBand, RunDawnUpdateMood,
FulfillDemand, clutch save). A3 expansion builds on those functions. Do not start
until LD-P1's QASmoke has closed the proof-item list in `03_feasibility.md`.

---

## Grounding constants (inherited from LD-P1)

| Constant | Value | Source |
|---|---|---|
| PIETY_DAILY_MAX_DELTA | 4.3 | PDV__ManagerQuest.psc:313 (symbolic ref only) |
| Mood bands | Wroth <=-40, Cool -39..9, Pleased 10..54, Exalted >=55 | 02_mood_model.md |
| DAWN_DAY_OFFSET | 0.25 (6h) | PDV_DeityBase.psc |
| DevotionDayIndex | Utility.GetCurrentGameTime() - DAWN_DAY_OFFSET as Int | PDV_DeityBase:ScoreRepeatableAction |

Smite/surge magnitudes below are calibrated against 4.3 and the pacing model:
one ideal day of max positive signal = 4.3 piety. A smite that costs the player
~0.5 days of equivalent mood impact = roughly 2.1 mood points at alpha 0.15.

---

## A3a -- Clutch Save (LD-P1 delivered, reference only)

- Live seam: PDV_T3DailyLowHealthSaveEffect.psc TryApplyDailySave()
- Mood gate added in LD-P1: PDV_GLO_PatronMoodBand read at trigger time
- Confidence: HIGH (in-repo prototype exists)
- Status: buildable in LD-P1. Not re-specced here.

---

## A3b -- Divine Luck

- **Live seam:** no single existing seam; would require a new periodic check or
  an OnUpdate hook outside combat. The closest live pattern is the PDV_T3
  DailyLowHealthSaveEffect polling loop (RegisterForSingleUpdate) -- a similar
  pattern could check for non-combat context. However, "non-combat context" has no
  live PDV test function; IsInCombat() exists in Papyrus natively.
- **Recomposition vs greenfield:** mostly recomposition of the TryApplyDailySave
  polling pattern + a new non-combat condition check. The dawn-day-index anti-farm
  key (one fire per devotion-day) reuses PDV_DeityBase:GetDevotionDayIndex().
- **Confidence:** MEDIUM. The polling pattern is proven; the non-combat context
  gate is a native Papyrus call (IsInCombat) whose behavior in the PDV MGEF context
  has not been tested. The "quiet context" (no detection, not near hostiles) is
  underpowered without B2 location theology -- what counts as "wilderness" is
  currently undefined in live PDV. Recommend deferring to after B2 location context
  work.
- **In-CK/in-game proof still required:** (1) IsInCombat() returns False reliably
  in a wilderness MGEF context; (2) once-per-devotion-day gate works across
  save/load; (3) no double-fire with clutch save when both are live simultaneously.

---

## A3c -- Blessing Surge

- **Live seam:** OnMoodBandCross() (LD-P1 authored). A3c fires alongside
  SyncPatronBoonsToBand() on an up-cross. The function that calls both is the
  OnMoodBandCross handler in the LD-P1 manager extension. Adding one more
  AddSpell(surgeEffect) call there is a single-line extension.
- **Surge spell shape:** a time-limited MGEF (authored in CK with a Duration,
  not a constant effect). PDV_DeityBase.ClearAllBoons() does NOT remove the surge
  spell unless the surge is added to the boon list; it should be a separate
  authored Spell record, not wired through Boon_Seeker/Devoted/Champion properties.
  AddSpell(surgeSpell, False) on Game.GetPlayer() at crossing.
- **Recomposition vs greenfield:** pure recomposition + CK record authoring.
  No new Papyrus function or StorageUtil namespace required (the surge decays by
  MGEF Duration; no persistent state needed).
- **Confidence:** HIGH. The seam exists, the pattern (AddSpell on crossing) is
  exactly SyncPatronBoonsToBand. No proof gap on the Papyrus side; CK authoring
  of the surge spell is the only work.
- **In-CK/in-game proof still required:** (1) surge MGEF duration is authored and
  expires correctly; (2) surge does not persist after a save/load mid-duration (MGEF
  persistence is vanilla engine behavior -- check one case); (3) surge stacks
  correctly if two up-crosses happen close together (they shouldn't because band can
  only cross once per dawn in normal play, but confirm).

---

## A3d -- Smite / Curse

- **Live seam:** the primary routing path is ApplyDeityReaction() (live
  PDV__ManagerQuest.psc:877) which is called from the faucet and quest-matrix layers.
  After a negative reaction is applied to the active patron via ApplyDeityReaction ->
  AwardPietyInternal, a mood-band check can fire the smite. The cheapest hook point
  is inside the existing routing path, after AwardPietyInternal, when the score is
  negative AND mood == Wroth AND the eventType's delta magnitude exceeds an authored
  severity threshold. A smite sub-function calls AddSpell(smiteEffect) on the player.
- **Curse-state non-collision:** PDV_CurseState.psc owns IsWerewolf()/IsVampire()
  and SetCurseState(). A3d smites are time-limited active magic effects (MGEF with
  Duration in CK). They do NOT call SetCurseState or any PDV_CurseState function.
  The only interaction: if the player IS a werewolf, Hircine's smite flavor differs
  (checked via PDV_CurseState.IsWerewolf() for theming only, not for state changes).
  No collision is possible if the smite MGEF is a pure spell effect with no Papyrus
  script writing to "PDV.Curse.*" keys.
- **Anti-spam seam:** ScoreRepeatableAction() (live PDV_DeityBase.psc:283) handles
  daily cap and cooldown for faucet events. A smite needs its own per-deity per-day
  cap (once per devotion-day) keyed at "PDV.Intervention.Smite.Day" and
  "PDV.Intervention.Smite.Count". This reuses the exact same StorageUtil integer
  pattern but is a new key (proof: StorageUtil.GetIntValue / SetIntValue with the
  new key -- trivial, no unknown API).
- **Recomposition vs greenfield:** routing hook into the award path = small addition
  (one conditional block after AwardPietyInternal call in ApplyDeityReaction).
  Anti-spam key = new StorageUtil key, existing pattern. Smite spell/MGEF = CK
  authoring. No new Papyrus functions strictly required, but a named
  TryApplySmite(PDV_DeityBase deity, Int eventType, Float delta) function is
  recommended for testability.
- **Confidence:** HIGH (seam is live and the conditional pattern is well-established).
- **In-CK/in-game proof still required:** (1) smite fires only at Wroth, not Cool;
  (2) anti-spam per-day cap survives save/load; (3) smite MGEF does not interfere
  with PDV_CurseState reads (log both, confirm no PDV.Curse.* key is written);
  (4) domain theming fires the correct spell per deity (proof per pilot deity).

---

## A3e -- Rivalry Strike

- **Live seam:** ApplyRivalryPenalties() (live PDV__ManagerQuest.psc:9858).
  Currently: iterates RivalDeities[], computes rivalAmount = sourceAmount *
  rivalMultipliers[i] * -1.0, calls AwardPietyInternal(rivalDeity, rivalAmount,
  False), fires SendPrismaEventToast("rivalry", ...) once. A3e adds: after the
  penalty is applied to rivalDeity, check rivalDeity's mood band; if Wroth, fire
  TryApplyRivalryStrike(rivalDeity).
- **Mood band read for rival:** PDV.Mood.<rivalDeity>.Band (StorageUtil int, per the
  LD-P1 namespace). Requires LD-P1 to be live (the rival's mood must be tracked).
  Without LD-P1 this seam does not exist.
- **Recomposition vs greenfield:** one new conditional block inside
  ApplyRivalryPenalties, after the AwardPietyInternal call. Per-rival cooldown is a
  new StorageUtil key "PDV.Intervention.RivalStrike.<rivalDeityIndex>.Day". The
  strike spell = CK authoring per rival deity.
- **Confidence:** MEDIUM-HIGH (seam is live; the LD-P1 mood-band namespace dependency
  is a hard precondition). The rival mood-band dependency is the only UNKNOWN: if
  LD-P1 is not live, this entire seam is absent. Flag as gated on LD-P1 mood proven.
- **In-CK/in-game proof still required:** (1) rival mood band is populated by LD-P1
  before A3e fires; (2) strike fires only when rival is Wroth (not just any penalty);
  (3) per-rival cooldown prevents rapid repeat (multiple actions in one session
  against the same rival); (4) strike MGEF is domain-themed to the rival, not the
  patron.

---

## A3f -- Hades Sacrifice (flagship)

- **Live seam -- boon removal:** ClearAllBoons() (live PDV_DeityBase.psc:346).
  Called by OnPatronEnd(), OnTierChange(). For Sacrifice: called on the ACTIVE patron
  deity (not on end of patronage) as a partial clear. To be precise: only the
  specific tier boon being sacrificed is removed (RemoveSpell on the boon), not all
  boons. This is a scoped RemoveSpell + AddSpell(rivalBoon) sequence, not a full
  ClearAllBoons(), to avoid accidentally clearing multi-tier stacks. Live pattern:
  PDV_DeityBase.psc:333-344 shows boon application is per-tier; the same logic
  reversed is the scoped removal.
- **Live seam -- rival boon grant:** AddSpell(rivalBoon, False) on Game.GetPlayer().
  The rival boon is a new authored Spell record on the rival deity (a new property
  on PDV_DeityBase: "Spell Sacrifice_Boon"). This property does not currently exist
  in live PDV_DeityBase.psc (395 lines; properties at :22-80 -- Sacrifice_Boon is
  absent). It is a new authored property. The AddSpell call itself is not new.
- **Live seam -- patron mood penalty:** LD-P2's PushMoodModifier() if LD-P2 is live;
  otherwise direct StorageUtil.AdjustFloatValue on PDV.Mood.<patronDeity> (which LD-
  P1 writes). Either path is valid for the first proof. Magnitude: -20 mood points
  (approximately half a day's negative signal at alpha 0.15, consistent with the
  "boon was taken" severity).
- **Live seam -- offer surface:** SendPrismaEventToast() (live:1057) for a
  "sacrifice_offer" event type. MessageBox or Prisma choice surface for accept/
  decline. MessageBox is live vanilla API (no proof required). The Prisma choice
  surface is not verified in live PDV (Prisma may not have a confirm/deny variant
  used by PDV). PROOF ITEM: verify whether PDV's Prisma integration supports a
  two-option choice toast, or whether MessageBox is the correct fallback.
- **Live seam -- rivalry topology:** RivalDeities[] and RivalMultipliers[] (live
  PDV_DeityBase.psc:59-60). These are the authored rival lists. The Sacrifice offer
  selects the rival deity from this array (the rival with highest recent rivalry
  penalty magnitude, or the first rival in the Wroth band). No new topology data
  structure is needed -- the existing arrays are the source of truth.
- **Live seam -- offer state persistence:** modeled on PDV.Commitment.* namespace
  (PendingDeityIndex, OfferedAt). New StorageUtil keys:
  PDV.Intervention.Sacrifice.Active (int), .RivalDeityIndex (int),
  .TargetBoonTier (int: 1/2/3 = Seeker/Devoted/Champion), .OfferedAt (float),
  .ExpiresAt (float). Reuses the exact same float/int StorageUtil pattern.
- **Recomposition vs greenfield:** the mechanics decompose entirely into existing
  live calls. The ONE new thing is the Sacrifice_Boon authored property on
  PDV_DeityBase and the rival boon Spell records in CK. The offer/accept flow and
  state persistence reuse the commitment-offer engine's pattern verbatim. A new
  function TryOfferSacrifice(PDV_DeityBase rivalDeity, PDV_DeityBase patronDeity)
  and AcceptSacrifice() are recommended for testability.
- **Confidence:** HIGH for the mechanical seams; MEDIUM for the offer UX surface
  (Prisma choice confirmation is an open proof item).
- **In-CK/in-game proof still required:** (1) scoped boon removal (RemoveSpell for
  specific tier) does not strip other tier boons; (2) rival boon persists across
  save/load; (3) patron mood penalty fires once, not on every dawn until cured;
  (4) Sacrifice.Active flag cleared correctly on patron tier-loss or patron-change
  (which calls ClearAllBoons anyway -- confirm Sacrifice_Boon is also cleared);
  (5) MessageBox / Prisma choice surface works in the live LD-P1 toast context;
  (6) Sacrifice expires correctly if the player never chooses (ExpiresAt check
  in RunDawnProcessDemands-style dawn pass).

---

## Feasibility verdict table

| Type  | Live seam(s)                                         | Recomp vs greenfield          | Confidence  |
|-------|------------------------------------------------------|-------------------------------|-------------|
| A3a   | TryApplyDailySave (LD-P1)                            | Recomposition                 | HIGH        |
| A3b   | T3 polling pattern + IsInCombat native               | Mostly recomposition          | MEDIUM      |
| A3c   | OnMoodBandCross + AddSpell                           | Pure recomposition + CK       | HIGH        |
| A3d   | ApplyDeityReaction + ScoreRepeatableAction pattern   | Recomposition + new key       | HIGH        |
| A3e   | ApplyRivalryPenalties + LD-P1 mood-band namespace    | Recomposition, LD-P1 gated    | MED-HIGH    |
| A3f   | ClearAllBoons + AddSpell + CommitmentOffer pattern   | Recomposition + 1 new prop    | HIGH / MEDIUM UX |

**Open owner decisions:**
1. Which Prisma toast variant (if any) supports a two-option choice surface for the
   Sacrifice offer, or does the offer use MessageBox exclusively?
2. Authored severity threshold for A3d smite: what minimum negative eventType delta
   triggers a smite (vs a mere mood drop)? Suggest: abs(delta) >= 2.0 piety as the
   default, authored per deity, stored in PDV_InterventionProfile.csv.
3. Sacrifice_Boon property: on PDV_DeityBase (all deities can offer) vs a new
   sub-class script (Daedra only)? Recommend: on PDV_DeityBase with None default
   (deities without a rival boon simply cannot fire Sacrifice).
