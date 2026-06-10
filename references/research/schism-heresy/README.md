# Bucket 4 -- Schism / Heresy Mood: Charter

**Status:** Design dossier only. No Papyrus/CK/ESP changes. No in-game proof.
**Date:** 2026-06-11
**Depends on:** LD-P1 engine (`04_living_deities_architecture.md`) built and
  runtime-proven. Schism is a modifier layer on top of the mood EWMA -- it
  cannot precede a working mood engine.

---

## What schism adds

Schism answers the question: not just "do you worship X?" but "are you
worshipping X in the way X prefers?" A god already has a mood that moves with
piety flow. Schism adds a second read at dawn that can apply a persistent mood
modifier -- a fractional multiplier on `clampedToday` -- when the player's
active worship-mode state does not match the god's authored preferred-practice
profile (the "orthodox lane").

The output is narrow and does not replace piety: a heterodox worshipper earns
piety normally, but the god's mood toward them is muted (or, for a Daedra with
an inverted orthodoxy, amplified on the heretical side). A secondary output is
a priest-faction tension flag readable by SPID-distributed NPC reactions.

---

## The orthodox/heterodox definition in PDV terms

PDV already tracks "how you worship" through six live state tracks:

| State variable | Live property name in PDV__ManagerQuest.psc |
|---|---|
| Nord pantheon baseline (OldWays/NineDivines) | `PDV_NordPantheonBaselineTrack` |
| Imperial Concordat compliance band | `PDV_ConcordatStandingTrack` (PDV_ReputationTrack) |
| Bosmer path (OldContract/LivingStory/Exchange/BanditRoad) | `PDV_BosmerPathTrack` |
| Altmer crisis state (None/Dissonant/Questioning/Reasserting/ScarredResolved) | `PDV_AltmerCrisisTrack` |
| Orc life-mode (City/Stronghold/LegionExile) | `PDV_OrcLifeModeTrack` |
| Redguard sect (Crown/Forebear/Ashabah) | `PDV_RedguardSectTrack` |

Schism builds on these existing dimensions. "Orthodox" for a given deity means
a specific value (or set of values) in one of the tracks above is aligned with
that deity's authored preferred-practice profile. "Heterodox" means the player
is worshipping that deity while the relevant track is in a misaligned state.

Schism does NOT invent a new state track. It adds an authored lookup table
(one CSV row per deity) that names which track and which value is that deity's
orthodox lane, then reads the live track at dawn to compute a mood modifier.

**Concrete example:** Talos (Nord, Nine Divines) has an authored orthodox lane
of `NordPantheonBaseline = NineDivines` AND `ConcordatStanding >= PrivateDefiant`.
A Nord worshipping Talos via the Old Ways baseline is technically unorthodox in
the Nine Divines institutional sense -- mood modifier applied. An Imperial
worshipping Talos while `PublicCompliant` is heterodox in the civic faith sense
-- a different modifier, captured by a second Talos row keyed to the Imperial's
ConcordatStanding axis.

---

## Novelty claim

This is not a new system. It is a data-driven modifier layer on top of the
existing mood EWMA that reads existing live state tracks. The only greenfield
is: one new CSV (orthodoxy profile), a new `RunDawnApplySchismModifierNoop`
dawn slot, and an optional SPID distribution record for priest-tension NPC
reactions. All state-reading machinery already exists.

---

## P1 pilot scope

Recommend **Talos (Nord)** as the P1 pilot deity for one clear reason: Talos
has two fully modeled orthodox/heterodox splits already wired in PDV --
`NordPantheonBaseline` (OldWays vs NineDivines framing) AND
`ConcordatStanding` (civic compliance vs defiance). Both tracks are live in
PDV__ManagerQuest.psc. No new state detection needed. The heterodox case
(Nine Divines Talos worshipped under Public Compliant standing) is lore-rich
and player-legible. The orthodox case (Old Ways Talos / Ysmir, or Private
Defiant Nine Divines Talos) produces a mood bonus that matters experientially.

Dunmer Reclamation deities (Azura via ancestor-cult framing vs primary-focus
framing) are a strong second candidate for P2 but require the Dunmer ancestor
substrate to be runtime-proven first.

---

## What stays backlog

- Priest-faction encounter spawning (beyond SPID aura flag reads): a full
  authored encounter system is Bucket 7 territory.
- Schism arcs: sustained heterodoxy leading to a rupture demand or
  excommunication dialogue. Deferred to Bucket 8 (prophecy / quest-chain
  mood-gating).
- Per-race schism for all ten races: P1 is Talos only. Other races (Dunmer
  Reclamation framing, Bosmer Old-Contract vs Living-Story Y'ffre, Orc
  life-mode vs Malacath expression) can be authored by adding CSV rows.
- Daedric schism (e.g., Boethiah wanting the cultist framing, not the
  "challenge accepted" tourist framing): architecturally identical but
  requires Daedric deity actors to exist first.
