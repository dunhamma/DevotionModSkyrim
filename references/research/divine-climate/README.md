# Divine Climate -- Charter (Bucket 10)

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes. Design only.
**Date:** 2026-06-11
**Bucket:** 10 -- Cross-pantheon "divine climate"
**Source:** `04_future_buckets_backlog.md` row 10 + additional-channels note
("World-state ambient as a standing omen layer")

---

## 1. What Is Divine Climate?

Divine climate is a **global, pantheon-level ascendancy scalar** that tints
omen tone and symbol selection across the whole mod. It answers the question
"which deity (or alignment) currently holds sway over the world?" and makes
that felt through omen flavor -- without touching piety, mood bands, or the
per-deity player-local context already owned by B2 (dossier 07).

The model in three sentences:

Once per dawn, after the all-deities consolidation loop completes, a new
sub-function `RunDawnComputeDivineClimate()` scans the same `PDV_FLST_AllDeities`
list to identify the highest-mood deity. It classifies that deity's alignment
(Aedra/Daedra) and writes a three-value global: `PDV_GLO_DivineClimate` (Int:
-1 Daedric, 0 Balanced, +1 Aedric) plus a pair of StorageUtil keys naming the
ascendant deity and its mood band. Omen dispatch then reads that global as a
soft tone bias -- "ominous" omens are weighted heavier in a Daedric climate,
"uplifting" omens in an Aedric one -- passing the bias as a `toneOverride`
argument to the existing `PDV_DiegeticDirector.Dispatch()` path.

---

## 2. Relationship to B2 (World Context, Dossier 07)

B2 is the **per-deity, player-local** context multiplier: it asks "given this
deity and what the player just did, does the current location and weather
amplify or attenuate the daily contribution?" It operates on dawn mood and the
omen-appropriateness filter. It is player-facing and deity-specific.

Divine climate is **one layer above B2**: it asks "across the whole pantheon,
which way is the cosmic wind blowing today?" It does not multiply piety,
does not change mood bands, and does not suppress or redirect omens. It is
a soft tone selector that colors omen _flavor_ only.

The two layers compose cleanly: B2 decides whether an omen fires and which
omen type is appropriate; divine climate nudges the tone of the omen that
does fire. Neither overrides the other.

**Rule:** divine climate NEVER writes to any piety, mood, or tier StorageUtil
key. It is cosmetic only.

---

## 3. Novelty Claim

No reviewed Skyrim faith mod (Wintersun, Pilgrim, Gods & Worship, Pantheon)
models a pantheon-level ascendancy state. They treat all deities as
independent score-keepers. Divine climate is the first layer that reads the
_collective_ state of the pantheon and feeds it back as a global world-feel
signal readable by CK conditions, MGEF, and SPID.

---

## 4. P1 Pilot Scope (Recommended)

**Pilot: Aedra/Daedra alignment scalar only. Omen tone bias only.**

Rationale:
- The Aedra/Daedra classification can be authored as a single bool property
  on `PDV_DeityBase` (`Bool IsAedra`). No new script logic is needed beyond
  reading it.
- The existing `PDV_FLST_AllDeities` loop in `RunDawnConsolidateScratch()`
  already iterates every deity with `PDV.Mood.<deity>` available. The
  ascendancy scan is a second pass over the same list, adding ~10-20 Papyrus
  operations per dawn -- negligible.
- `PDV_DiegeticDirector.Dispatch()` already accepts a `toneOverride` String
  parameter (live: `PDV_DiegeticDirector.psc:41`). The climate tint plugs
  in without changing the Director's interface.
- One new GlobalVariable (`PDV_GLO_DivineClimate`) gives CK/MGEF/SPID an
  always-readable world-state hook without any new script dependency.

**P1 deliverable:** `RunDawnComputeDivineClimate()` + `PDV_GLO_DivineClimate`
global + a `GetClimateToneOverride(String baseTone)` helper that returns a
modified tone string when the climate scalar is nonzero. No weather, no
wildlife, no NPC reactions. Those are backlog.

---

## 5. What Stays Backlog

The following are explicitly deferred and must not be designed until P1 is
runtime-proven:

- Weather/sky bias driven by divine climate (requires PROOF ITEM W1 from
  B2 architecture: `Weather.GetClassification()` not yet verified).
- Wildlife spawn bias (requires Story Manager hooks; see Bucket 1/7).
- NPC ambient reactions to climate (SPID-distributed; Bucket 6/7 territory).
- Per-deity named-ascendant display (UI work; post-P1).
- Multiple simultaneous ascendant deities (requires a ranked list, not a
  scalar; post-P1 only if the single-ascendant model proves too coarse).
