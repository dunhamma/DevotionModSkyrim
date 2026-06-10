# A3 Interventions -- Charter

**Status:** DESIGN DOSSIER, 2026-06-10. No Papyrus/CK/ESP changes. Same honesty
discipline as `03_feasibility.md` and `05_ld_p2_charter.md`. Names are the contract.

> Scope: the full A3 intervention taxonomy for the Living Deities engine. This is
> forward work beyond LD-P1 (which built exactly one intervention type: the clutch
> save). It does not duplicate LD-P1 or LD-P2 and must be built after LD-P1 is
> runtime-proven.

---

## 1. The white-space claim (why this matters)

From `01_mechanism_bank.md` section "PDV's white space":

> "Across every Skyrim faith mod studied (Wintersun, Pilgrim, Gods and Worship,
> Pantheon), the god is a passive ledger: favor moves only because the player acted,
> and the god never initiates. A3 interventions, B2 world-context, B3 inter-deity
> politics, and B4 authored arcs have zero working precedent in the faith-mod space."

The LD-P1 clutch-save (low-health save gated on mood >= Pleased) is the first crack
in the passive-ledger wall. It is a god-initiated output -- the deity acts unprompted
when the player is about to die -- but it is a single type, mood-gated, player-
favorable. The full A3 taxonomy covers the other quadrants: the god acting against
you (smite/curse), a rival god acting against you (rivalry strike), a god demanding
you renounce something (Hades Sacrifice), and probabilistic favor/luck that is too
light to reach clutch-save territory (divine luck and blessing surge).

**Novelty claim.** No Skyrim faith mod has shipped any of these. The clutch-save
precedent is Andromeda (conditioned MGEF, not faith-system-initiated). The Sacrifice
precedent is Hades (rival overwrites a boon). The curse precedent is EnaiSiaion
vampirism/lycanthropy (staged state machine, no deity agency). PDV's intervention
taxonomy is the first to assemble these into a multi-type, deity-initiated, pantheon-
spanning faith system including Daedra as first-class participants.

---

## 2. Intervention taxonomy

| ID  | Name             | Initiator        | Direction   | Trigger                              | Domain flavored? |
|-----|------------------|------------------|-------------|--------------------------------------|-----------------|
| A3a | Clutch Save      | patron deity     | for player  | mood >= Pleased + health < 10%       | YES (LD-P1)     |
| A3b | Divine Luck      | patron deity     | for player  | mood == Exalted + low-stakes context | YES             |
| A3c | Blessing Surge   | patron deity     | for player  | mood >= Pleased + band-up cross      | YES             |
| A3d | Smite / Curse    | patron deity     | vs player   | mood == Wroth + player act triggers  | YES             |
| A3e | Rivalry Strike   | rival deity      | vs player   | rival Wroth + patron acted for you   | YES             |
| A3f | Hades Sacrifice  | rival deity      | vs player   | rival Wroth + patron boon active     | YES (flagship)  |

A3a (clutch save) is LD-P1 delivered. This dossier owns A3b through A3f.

---

## 3. Per-type definition

### A3b -- Divine Luck
A subtle favor pulse: a minor buff (domain-flavored) fires during non-combat moments
when the patron is Exalted and the player has been in a "quiet" context (no active
combat, no recent hostile detection) for a short window. It is the Exalted-tier
equivalent of the clutch save -- but proactive reward, not rescue.

- Kyne example: standing in wilderness at Exalted mood, a brief Fortify Stamina
  Regen pulse (10s, small magnitude) fires once per game-day.
- Hircine example: while Werewolf + Exalted, a brief bestial speed/strength surge
  fires once per dawn cycle (outside the beast form combat loop).
- Anti-spam: once per dawn cycle (dawn-day-index key), Marked-tier toast, MCM density.
- Pacing: magnitude calibrated to ~1/4 of the Seeker boon value so it feels like a
  whisper, not a free second boon.

### A3c -- Blessing Surge
On mood band-up-cross to Pleased or Exalted, the transition itself fires a short-
duration bonus MGEF: the patron's domain energy surges for a few minutes. This is
distinct from the persistent band-variant boon (A4/SyncPatronBoonsToBand): the surge
is a punctuation of the crossing moment, not a steady-state grant. The boon swap
(A4) and the surge (A3c) both fire on the same crossing event; the surge decays.

- Kyne: on crossing to Pleased, a 90s Fortify Archery + nature detection pulse.
- Hircine: on crossing to Exalted, a 120s Fortify Beast Form magnitude pulse.
- Anti-spam: surge duration itself is the natural cooldown (one per crossing).
- Note: this is the easiest of the new types -- it piggybacks on the existing
  OnMoodBandCross dispatch and adds one time-limited MGEF alongside the boon swap.

### A3d -- Smite / Curse
The patron acts against the player. Triggers when: mood == Wroth AND the player
performs an act that the deity's like/dislike table scores negatively AND the
triggering act is above a "severity threshold" (authored per deity as a minimum
negative eventType delta magnitude). The deity fires a domain-flavored penalty MGEF.

- Kyne example: player kills a protected animal species (eventType scoring a large
  negative for Kyne) while mood is Wroth. Kyne's smite: brief Weakness to Nature
  (poison/shock penalties) + a "Kyne turns her face" omen.
- Hircine example: player commits an act Hircine scores deeply negative (fleeing
  combat, being downed by prey) while Wroth. Smite: brief Fortify Weakness to
  beast attacks + howling wind omen (werewolf only).
- Curse-state interaction: A3d must NOT write to PDV_CurseState. The curse-state
  service is the canonical owner of werewolf/vampire state. A3d smites are time-
  limited active magic effects only -- they expire, they do not persist as curse
  state. If a smite conceptually should become a "curse" (Daedric displeasure arc),
  that is a Daedric-escalation mechanism riding the Sacrosanct/Growl staged state
  machine (see 05 docs), not A3d. A3d = a single-shot timed MGEF; it never calls
  SetCurseState or ClearCurseState.
- Anti-spam: ScoreRepeatableAction-style cooldown (minimum 1 devotion-day between
  smites), Wroth-band gate, MCM density, Marked-tier toast.

### A3e -- Rivalry Strike
A rival deity, when its own mood is Wroth (due to the player gaining piety with the
patron via ApplyRivalryPenalties), fires a one-shot punitive MGEF against the player.
This is the active, felt manifestation of what ApplyRivalryPenalties does silently in
piety arithmetic -- the player hears the rival's displeasure.

- Trigger condition: after ApplyRivalryPenalties fires a penalty above a threshold
  magnitude on rival deity R, and R's mood is Wroth, R may fire a strike.
- Kyne vs Hircine example (if they are rivals): a large Kyne piety award triggers
  rivalry penalty to Hircine. If Hircine is Wroth, Hircine's strike fires: brief
  Fortify Weakness to frost (Hircine's cold hunt) + "Hircine's pack circles" omen.
- Rivalry Strike vs Hades Sacrifice: a Strike is a punitive burst MGEF. Sacrifice
  (A3f) is a permanent replacement of a boon. Strike < Sacrifice in severity.
- Anti-spam: per-rival cooldown (separate from patron smite cooldown), Wroth gate,
  MCM density.
- Note: the rivalry ledger (RivalDeities[] + RivalMultipliers[]) is live. A3e rides
  the existing ApplyRivalryPenalties seam and adds a conditional MGEF dispatch.

### A3f -- Hades Sacrifice (flagship)
The marquee intervention. A rival deity that is Wroth and has recently been penalized
by your patron devotion demands that you renounce something the patron gave you.
Mechanically: the rival deity offers to overwrite one of your currently-active patron
boon spells with a rival-domain boon spell (more domain-potent to the rival) in
exchange for the patron's boon being removed. This is the Hades "replace a rival's
boon" pattern adapted to the PDV persistent-save model.

**What is renounced (PDV mechanical definition):**

The rival offers to replace the player's currently active patron tier boon (one of
Boon_Seeker, Boon_Devoted, Boon_Champion on the active patron deity) with a rival-
domain equivalent spell. The replacement is permanent until the player regains the
patron tier boon by the normal piety path, OR until the player accepts a new patron
commitment (which clears all boons anyway). The patron deity's piety is not directly
zeroed -- Sacrifice targets the boon, not the piety. However: the patron deity's
mood drops by a calibrated delta (it notices its gift was replaced) and a
SendPrismaEventToast "sacrifice_accepted" fires for the patron.

The rival boon is authored as a separate Spell record, slightly more potent in the
rival's domain but domain-narrow (it does not give the breadth of the patron's boon).
This is the Hades "+1 rarity but rival domain" tradeoff.

**What the player sees:** an omen/dream (via OnSleepStart or a Marked-tier toast)
where the rival deity makes the offer. The player has a choice: accept (lose patron
boon, gain rival boon, patron mood drop) or refuse (rival mood drops further, but
nothing changes). Choice is surfaced through a MessageBox (the existing PDV
commitment-offer UX pattern) or a Prisma toast with accept/decline.

**Which existing function handles the renouncement:**
The acceptance path calls ClearAllBoons() on the active patron deity (live:
PDV_DeityBase.psc:346) then AddSpell(rivalBoon) on the player. The patron's mood
delta is applied via a new call to a function whose shape mirrors PushMoodModifier
(LD-P2) or a direct StorageUtil adjustment to PDV.Mood.<patronDeity> if LD-P2 is not
yet live. The rival deity's piety is NOT awarded (Sacrifice is not a devotional act
toward the rival; it is a coercion). StorageUtil writes: PDV.Intervention.Sacrifice
.Active (int 1), .RivalDeityIndex (int), .SacrificedBoon (string spell EditorID or
formID ref), .OfferedAt (float gametime).

Kyne example: Hircine is Wroth (werewolf player, Hircine mood Wroth, Kyne is patron
at Seeker tier with Boon_Seeker active). Hircine offers to replace Kyne's wind-step
boon with Hircine's Hunt Edge boon (slightly better bestial stats but no wind).
Accept: wind-step gone, hunt-edge applied, Kyne mood drops -20, omen "the Hunt
silences the Wind."

Hircine example (as patron vs Meridia as rival): Meridia is Wroth (the player
is a werewolf AND has been gaining Hircine piety). Meridia offers to replace
Hircine's beast vigor boon with a Meridia sun-blade boon (slightly better fire/undead
damage but no beast benefit). Accept: beast vigor gone, sun-blade applied, Hircine
mood drops, omen "the Light demands you shed the beast's gift."

---

## 4. P1 pilot scope -- which 2-3 interventions first

Recommended P1 (after LD-P1 is runtime-proven):

1. **A3c -- Blessing Surge** (easiest; piggybacks on the already-built band-cross
   dispatch; no new trigger, no new seam, just an additional MGEF on crossing).
2. **A3d -- Smite / Curse** (proves the "deity acts against you" quadrant; rides the
   same like/dislike scoring path; Wroth gate uses the already-built mood band; no
   new seam -- just a conditional in the routing path after a negative score).
3. **A3f -- Hades Sacrifice** (the flagship; most design complexity but the
   mechanical seams are all live -- ClearAllBoons, AddSpell, RivalDeities array,
   SendPrismaEventToast, StorageUtil).

**Backlog:** A3b (Divine Luck) can wait -- it adds a non-combat trigger context check
that needs B2 location-context work to feel right. A3e (Rivalry Strike) is a natural
companion to A3d but adds rival-mood tracking complexity; defer until smite is proven.

---

## 5. What stays backlog and why

| Intervention | Backlog reason |
|---|---|
| A3b Divine Luck | Needs B2 "quiet context" detection; premature without location theology work |
| A3e Rivalry Strike | Adds per-rival mood-band state; wait until patron smite loop is proven |
| Multi-deity Sacrifice | One active sacrifice offer at a time; multi-rivalry is content breadth, not new mechanism |
| Forced renouncement (no player choice) | Requires proven MessageBox/choice seam first; escalation-only variant is LD-P3+ |

---

## 6. Daedra first-class

Every intervention type is specified Daedra-first. Daedric Princes are the natural
protagonists of the aggressive quadrant (A3d smite, A3f Sacrifice): they have
stronger rivalry relationships, domain aesthetics suited to dramatic interventions,
and the Sacrosanct/Growl displeasure escalation model as a precedent. The Hades
Sacrifice flagship is authored with two Daedric examples (Hircine, Meridia) and one
Aedric-as-patron example (Kyne). All A3 types must have authored domain flavoring per
deity -- generic/undifferentiated interventions are explicitly forbidden (per M1
mechanism bank pattern 23: "domain-flavored effect, never generic").
