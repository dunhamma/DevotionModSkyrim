# Bucket 4 -- Schism / Heresy: Feasibility Assessment

**Status:** Design dossier only. No CK, no runtime. No in-game proof exists.
**Honesty bar:** same as `03_feasibility.md` in the LD-P1 dossier -- every seam
  traced to a live function name; proof still required listed explicitly.

> Line references in PDV__ManagerQuest.psc are illustrative only. Function
> **names** are the contract; line numbers drift on every edit.

---

## Mechanism 1: Orthodoxy detection (reading existing worship-mode state)

**What it does:** At dawn, for each deity in `PDV_FLST_AllDeities`, look up
the deity's authored orthodoxy row. Read the named live state track. Compare
current state value against the authored orthodox value(s). Output a boolean
(orthodox/heterodox) plus an optional severity enum (Mild/Strong).

**Live seam:**
- `PDV_NordPantheonBaselineTrack` -- `PDV_StateTrack` property, line ~81,
  read via `GetNordPantheonBaselineState()` (name-stable function).
- `PDV_ConcordatStandingTrack` -- `PDV_ReputationTrack` property, line ~79,
  read via `PDV_ConcordatStandingTrack.GetCurrentState()` or the track's
  `GetStateLabel()`.
- `PDV_BosmerPathTrack`, `PDV_AltmerCrisisTrack`, `PDV_OrcLifeModeTrack`,
  `PDV_RedguardSectTrack` -- all `PDV_StateTrack` properties, lines ~80-88,
  same `GetCurrentState()` interface.
- `PDV_FLST_AllDeities` iterates live in `RunDawnConsolidateScratch()`. The
  schism check reuses the same loop structure.

**Confidence:** HIGH. Every required read is a live, stable function call. No
new detection machinery. The only new code is the CSV lookup and comparison.

**Recomposition vs greenfield:** Recomposition. No new state tracks. No new
property types. The CSV lookup is new data, not new machinery.

**In-CK / in-game proof still required:**
- Confirm `PDV_NordPantheonBaselineTrack.GetCurrentState()` returns stable
  `0`/`1` (OldWays/NineDivines) at dawn after the player has set a baseline
  -- one console-tested dawn cycle.
- Confirm `PDV_ConcordatStandingTrack.GetCurrentState()` returns the correct
  band index (0-4) after authored ConcordatStanding signals fire.

---

## Mechanism 2: Mood modifier (fractional delta applied in RunDawnUpdateMood)

**What it does:** When heterodox, the deity's effective `clampedToday`
contribution to the mood EWMA is scaled by a modifier (e.g., 0.60 for mild
heterodoxy, 0.35 for strong heterodoxy). When orthodox with a bonus lane, the
contribution may be scaled up (e.g., 1.10 -- small, bounded). The modifier
is applied inside `RunDawnUpdateMood()` (the new LD-P1 dawn slot) before the
EWMA formula runs.

**Live seam:**
- `RunDawnUpdateMood()` is the LD-P1 insertion point in `ProcessDawn()` (see
  `04_living_deities_architecture.md` section 3.1). It is NEW greenfield from
  LD-P1 -- schism slots into it as a sub-step.
- `clampedToday` is computed in `RunDawnConsolidateScratch()` (live function,
  name-stable) and stored under `PDV.PietyToday` (zeroed after use). The
  schism modifier must read `clampedToday` BEFORE it is zeroed, i.e., it must
  run inside or immediately after `RunDawnConsolidateScratch()` and before
  `PDV.PietyToday` is zeroed. Architecture option: add a
  `PDV.SchismModifier.<deity>` float that `RunDawnUpdateMood()` reads and
  applies alongside the EWMA -- see `02_architecture.md` for exact slot order.
- The EWMA formula in `RunDawnUpdateMood()` already uses `clampedToday /
  PIETY_DAILY_MAX_DELTA * 100` (constant `PIETY_DAILY_MAX_DELTA = 4.3` at
  `PDV__ManagerQuest.psc:313`). Schism multiplies this before the EWMA step.

**Confidence:** MEDIUM-HIGH. The slot (RunDawnUpdateMood) is LD-P1 new
authoring -- it does not exist yet in shipping PDV. Schism feasibility is
therefore contingent on LD-P1 being built first. Given LD-P1 is already
ratified, schism's modifier step is a natural sub-step of the same function.

**Recomposition vs greenfield:** Recomposition-of-planned-greenfield. The
modifier math is trivial; it slots into the LD-P1 function that does not exist
in shipping PDV today but is ratified for build.

**In-CK / in-game proof still required:**
- LD-P1 `RunDawnUpdateMood()` must be built and runtime-proven before this
  modifier can be validated.
- Once LD-P1 is proven: confirm schism modifier is applied correctly by seeding
  a Nord Talos worshipper in each baseline state (OldWays / NineDivines) +
  Concordat state (Enforcer / Defiant), running one dawn cycle, and confirming
  the stored `PDV.Mood.Talos` value reflects the modifier.

---

## Mechanism 3: Priest-faction tension flag (SPID aura / NPC read)

**What it does:** When a deity's heterodox modifier is active (severity Strong
or sustained for N days), set a flag that SPID-distributed priest/faction NPCs
can read. Minimal form: write a StorageUtil int
`PDV.Schism.<deity>.HeterodoxActive` (0/1). A SPID-distributed condition reads
`PDV_GLO_PatronMoodBand` (already planned in LD-P1, `04_living_deities_architecture.md`
section 2.3) combined with a schism-active flag to adjust NPC disposition or
block blessing interactions.

**Live seam:**
- `PDV_GLO_PatronMoodBand` is the LD-P1 global mirror (planned, not yet
  shipped). It exposes the active patron's mood band as a CK-readable global.
- SPID (Spell Perk Item Distributor) can distribute a faction membership or
  dummy spell to NPCs matching a keyword filter. A CK Condition on that spell
  can read `PDV_GLO_PatronMoodBand` via `GetGlobalValue`. StorageUtil values
  are not directly CK-readable, so the schism flag must mirror to a global
  (e.g., `PDV_GLO_SchismActive`, 0/1) if CK conditions need it.
- SPID keyword-distribution to priest factions is a known pattern in PDV's
  mechanism bank (Bucket 4 seed: "SPID faction auras"). No live PDV SPID
  distribution exists yet -- this is modest greenfield.

**Confidence:** MEDIUM. SPID distribution is buildable and well-documented,
but the priest-NPC layer is new content authoring. The flag write is trivial.
The SPID record and NPC reaction dialogue/disposition are content work.

**Recomposition vs greenfield:** Mixed. Flag write = recomposition (StorageUtil
pattern). Global mirror = recomposition (existing pattern). SPID distribution
record = modest greenfield. NPC reaction content = full content greenfield
(out of P1 scope).

**In-CK / in-game proof still required:**
- Author one SPID distribution record targeting a named priest faction with a
  condition reading `PDV_GLO_PatronMoodBand` and `PDV_GLO_SchismActive`.
- Confirm NPC disposition or dialogue flag changes when both globals are set
  at the expected values -- requires in-game test with SPID installed.
- Priest NPC reaction dialogue is content authoring blocked by CK work.
  P1 scope is flag-write + one SPID condition record only.

---

## Feasibility verdict

| Mechanism | Confidence | Recomposition? | LD-P1 gated? | P1 scope |
|---|---|---|---|---|
| Orthodoxy detection | HIGH | Yes (live state track reads) | No (tracks exist now) | Yes |
| Mood modifier in RunDawnUpdateMood | MEDIUM-HIGH | Recomp-of-planned-greenfield | Yes (LD-P1 first) | Yes |
| Priest-tension flag (StorageUtil + global mirror) | HIGH | Yes | No | Yes |
| SPID aura / NPC reaction | MEDIUM | Modest greenfield | No | Flag only (P1); full NPC = P2+ |

**Overall verdict:** Buildable after LD-P1. Zero new state tracks. One new CSV.
One new dawn sub-step. One new global mirror. Minimal greenfield. Honest
constraint: the mood modifier is a sub-step of LD-P1's RunDawnUpdateMood --
schism cannot ship before LD-P1 is runtime-proven.
