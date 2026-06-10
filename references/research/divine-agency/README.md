# Divine Agency -- Unified Dossier Charter

**Status:** Design dossier, 2026-06-11. Research only -- no Papyrus/CK/ESP changes.
**Subsumes:** Backlog buckets 1 (Theophany/avatar encounters), 6 (Congregation/proselytizing),
and 7 (Mortal champions/rival worshippers) from `04_future_buckets_backlog.md`.
**Dependencies:** LD-P1 mood engine (RunDawnUpdateMood, PDV_GLO_PatronMoodBand, active patron
pool, OnMoodBandCross) must be live before any divine-agency mechanism builds.

---

## 1. The Unified Model

All three backlog buckets are expressions of one idea: **the deity acts in the world through
a mortal body**. The differences are delivery channel and duration:

- **Emissary (Bucket 1):** a transient, rare NPC materializes to deliver one message or demand,
  then leaves. The god speaks once, in person, and is gone. Raven for Hermaeus Mora; a wandering
  beggar who turns out to be Sanguine; a Vigilant citing Stendarr's disappointment.
- **Congregation aura (Bucket 6):** ambient, persistent. SPID-distributed NPC priests and
  faction members carry a keyword whose MGEF condition reads PDV_GLO_PatronMoodBand. When
  your patron is Pleased+, local clergy warm to you; when Wroth, they cool. No per-NPC
  scripts -- only a CK-condition gate on a distributed keyword.
- **Champion/rival (Bucket 7):** a spawned or scenario-tagged NPC acts as the deity's agent
  for a scene -- a Vigilant hunt party when Stendarr is Pleased and your creed is impure;
  a cultist hit-squad when a Daedric Prince is Wroth. Related to A3e/A3f rivalry strikes
  already in `06_interventions_architecture.md` -- this dossier designs the NPC-delivery
  layer (spawn + allegiance tracking), not the intervention decision itself.

These three share one delivery infrastructure (spawn XMarker + PlaceActorAtMe OR SPID INI +
MGEF global condition), one anti-spam contract (ScoreRepeatableAction-style one-shot guard
in StorageUtil keyed by event class), and one data channel (PDV_GLO_PatronMoodBand as the
live condition read). **They are designed once here, not triply.**

---

## 2. Novelty Claim

Per the M1 white-space thesis (`01_mechanism_bank.md`, section "PDV's white space"): across
every Skyrim faith mod studied, gods are passive ledgers -- favor moves only because the player
acted, and the god **never initiates**. Theophany, congregation reaction, and mortal champions
are all initiating acts: the god reaches out, the world changes shape around the player's
standing without the player taking any action. Zero working precedent exists in the faith-mod
space for any of these three modalities. Every mechanism needed to build them comes from
adjacent mods (SoT XMarker+PlaceActorAtMe spawn, SPID global-condition pattern) and other
games (Black & White god-as-agent, Gods & Worship conversion). Divine agency is the next
frontier of PDV's differentiation claim.

---

## 3. P1 Pilot Scope -- Single Cheapest Modality

**Recommendation: Congregation aura (Bucket 6) as P1 pilot.**

Rationale: congregation aura requires no new Papyrus, no spawning, no new actors. It is a
SPID INI (authored once) + a CK MGEF record whose single condition reads the already-
specified PDV_GLO_PatronMoodBand global. The politics dossier (`08_deity_politics_charter.md`
section 7 and `08_deity_politics_architecture.md` section 4) already specced the identical
SPID + global-condition pattern for rivalry auras. Divine agency congregation aura is a
**parallel INI and MGEF** using the same machinery with a different distribution target
(patron-aligned priests rather than rival priests).

**Recommended pilot deity: Stendarr.**
- Vanilla has well-populated, clearly-named Vigilants of Stendarr faction NPCs.
- Stendarr's mood is straightforwardly tied to the player's creed discipline (Aedric
  commitment, avoidance of Daedric association).
- The congregation effect is intuitive: Vigilants are visibly warmer when Stendarr is
  Pleased, visibly cold or hostile when Wroth.
- No lore invention required; no INVENTED-tagged rows.

**P1 delivers:** one SPID INI, one MGEF record, one CK global (reuses PDV_GLO_PatronMoodBand
if live, or a proxy global before LD-P1 ships), no scripts. In-game proof: Vigilant NPC has
the keyword distributed after load; MGEF condition correctly gates on band value.

---

## 4. What Stays Backlog

- **Emissary spawning (Bucket 1):** higher cost (PlaceActorAtMe greenfield, cell-load
  problems, actor lifecycle management, dialogue authoring). Recommend after congregation
  aura is proven. Best pilot: Hircine hunt-emissary (curse-gated Hircine LD-P1 actor
  provides the mood substrate; a single spawn at band-cross-to-Wroth is the emissary).
- **Champion/rival sponsorship (Bucket 7):** shares the spawn infrastructure with emissary
  but adds allegiance tracking (disposition, level scaling). Depends on emissary being
  proven first. The A3e/A3f interventions in `06_interventions_architecture.md` are the
  closest cousin -- champion sponsorship extends them with a persistent NPC body.
- **Voiced theophany:** post-engine, explicitly out of scope per Bucket 12.
- **Congregation conversion mechanics** (Gods & Worship-style actual piety transfer to
  NPCs): not scoped here; the aura disposition effect is sufficient for P1.

---

## 5. Relationship to Other Dossiers

- B3 deity politics (`08_deity_politics_charter.md`): the SPID + PDV_GLO_PatronMoodBand
  pattern originated there and is **reused** here. Do not redesign it. Section 4 of
  `08_deity_politics_architecture.md` is the canonical SPID INI pattern reference.
- A3 interventions (`06_interventions_architecture.md`): A3e (rivalry strike) and A3f
  (Hades Sacrifice) are the intervention-decision layer. Divine agency provides the
  NPC-delivery body when an intervention takes physical form (a champion, a cultist squad).
  The two layers compose: A3f decides to act, divine agency provides the NPC who delivers it.
- LD-P1 architecture (`04_living_deities_architecture.md`): all mood namespaces, band
  constants, patron pool filter, and PDV_GLO_PatronMoodBand are LD-P1 dependencies.
  Divine agency does not build any of them; it only reads them.
