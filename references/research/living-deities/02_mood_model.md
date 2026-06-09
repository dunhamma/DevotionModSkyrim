# M2 — Mood Model Decision (the engine's one architectural crux)

**Status:** DECIDED (pending owner ratification of the tunables flagged below).
This resolves "where mood lives and how it's computed," grounded in PDV's actual
dawn/award code and the M1 implementation models.

> Terminology: "**LD-P1 / LD-P2 / Backlog**" below are **engine build phases**, not
> the mod's release V1. Per the owner, the Living Deities engine is **not** a
> V1-ship requirement.

## Decision in one paragraph
Mood is a **per-deity bounded EWMA** over the *daily net stance-adjusted piety
delta PDV already computes*, persisted in StorageUtil, recomputed once per dawn in
a new sub-phase of `ProcessDawn()`, and bucketed into **four bands** whose
**crossings** (not levels) fire omens/demands/boon-shifts through the existing
anti-spam machinery. It introduces **one new float + one new int per deity** and
**~30 lines** on an existing pass. No new tick, no new event hooks. This is the
single new runtime state M0 predicted.

## State
- `PDV.Mood.<deityForm>` — float, clamped **[−100, +100]**. Persisted via StorageUtil on each deity form, exactly like the live `PDV.Piety` / `PDV.PietyToday` (`PDV__ManagerQuest.psc`).
- `PDV.Mood.<deityForm>.Band` — int 0-3 (last band, for crossing detection).
- New per-deity authored properties on `PDV_DeityBase.psc` (alongside `ThresholdSeeker/Devoted/Champion`): `MoodAlpha` (EWMA weight) and optional per-deity band overrides.

## Input — *reuse what already exists* (no new pipeline)
In `RunDawnConsolidateScratch()` (`PDV__ManagerQuest.psc:2951`) PDV already computes, per deity, per dawn:

```
pietyToday  -> scaledToday (×GAIN_RATE_SCALE) -> clampedToday  (clamped ±PIETY_DAILY_MAX_DELTA)
```

`clampedToday ∈ [−PIETY_DAILY_MAX_DELTA, +PIETY_DAILY_MAX_DELTA]` (= ±5.0) is the day's **net, stance-adjusted, value-profile-weighted, capped** behavior toward that deity. That is *precisely* the EWMA input the mood model needs — and it means **the PoE "per-deity disposition net scalar" is already baked in** by PDV's existing stance matrix + approve/disapprove profiles. The mood layer only adds **recency**; it needs no new weighting table.

## Update (the EWMA) — new dawn sub-phase `RunDawnUpdateMood()`
Inserted into `ProcessDawn()` right after `RunDawnConsolidateScratch()` (it must read `clampedToday` **before** `PietyToday` is zeroed — line 2972 — so the cleanest implementation folds it into the same per-deity loop and reads the same local).

```
dailyContribution = (clampedToday / PIETY_DAILY_MAX_DELTA) * 100.0        ; -> [-100,+100]
MoodNew = Clamp( alpha * dailyContribution + (1 - alpha) * MoodOld , -100, 100 )
```

- A day of no acts toward the deity → `clampedToday = 0` → mood **decays toward 0** (the god's short-term impression fades). This reuses the "decay-as-absence" pattern and needs no separate decay code.
- `alpha` default **0.15** (≈ 4-day half-life of an impression; sustained devotion reaches Exalted in ~5 days, sustained offense reaches Wroth in ~3). **Authored per deity**: Daedra trend higher (0.20-0.25, impatient/volatile); patient Aedra lower (0.10). *[Owner tunable — flagged.]*

## Bands (asymmetric — "easier to anger," per CK3)
| Band | Range | Meaning |
|---|---|---|
| **Wroth** | [−100, −40) | actively displeased; negative omens, displeasure escalation eligible |
| **Cool** | [−40, +10) | neutral/default (new & dormant deities sit at 0 = Cool) |
| **Pleased** | [+10, +55) | favorable; positive omens, boon uplift |
| **Exalted** | [+55, +100] | peak; rare interventions, strongest boon scaling |

Thresholds authored/tunable. *[Owner tunable — flagged.]*

**Stance caps the ceiling** (ties mood to the existing race×deity stance matrix): FOREIGN caps at Pleased; TABOO/HOSTILE caps at Cool **unless** a curse/commitment path is active. This makes a non-native deity's mood structurally shallower without new data — it reads `deity.GetStanceForPlayer()`. *[Owner decision — flagged.]*

## Firing rule — crossings, not levels
In `RunDawnUpdateMood()`, after recompute, compare new band to stored `.Band`:
- **Downward cross** → eligible negative event (omen of displeasure; at Wroth, displeasure-escalation per the Sacrosanct/Growl staged model).
- **Upward cross** → eligible positive event (omen of favor; boon uplift).
- **No cross** → silence (the CK3 "quiet between bands" rule that keeps it un-annoying).

Eligibility is then filtered by **(a) the active patron pool** (only recently-relevant deities fire — the Hades godpool filter, reusing PDV's existing `RecordCommitmentSignalDay`/recent-signal-day tracking) and **(b) the anti-spam triad** (`ScoreRepeatableAction()` day-cap + cooldown, the `Marked` surfacing tier, the MCM density slider). Dispatch goes through `PDV_DiegeticDirector.Dispatch("omen"/"mood", ...)`.

## Reads (who consumes mood)
- **A4 boons:** an MGEF magnitude factor reads the active patron's band via a **global mirror** `PDV_GLO_PatronMoodBand` (mirror mood→global the same way PDV already mirrors piety/tier to globals for CK conditions) or `GetVMQuestVariable`. Scales within the existing one-active-boost + family-cap guardrails; no re-grant.
- **A1 demands / A3 interventions / B3 rivalry:** gated by band + pool + anti-spam.
- **Survey/MCM/Prisma panel:** display the band as a worded state ("Kyne watches you with favor"), never a raw number — preserves the "reading a divine mind" quality.

## Optional Tier-2 enrichment — materialized modifiers (CK3)
For a diegetic "why" and an audit trail, optionally keep a small ring buffer per deity of recent `{actTag, delta, day}` (the rotating-buffer pattern). Omen text can then name the cause ("your mercy at the gate pleases Stendarr"). **Deferred to LD-P2** — the scalar EWMA is sufficient for LD-P1.

## Cost summary
1 float + 1 int per deity (StorageUtil) · 2 authored properties on `PDV_DeityBase` · 1 new dawn sub-phase (~30 lines) folded into the existing loop · 1 global mirror · **zero new ticks, zero new event hooks.** Verifier impact: extend the readback to assert mood persistence + band-on-cross logging.

## Owner decisions — ✅ RATIFIED (owner, 2026-06-09) for LD-P1
All four accepted as recommended:
1. `alpha` default **0.15**, per-deity tuned (Daedra higher, patient Aedra lower). **LOCKED.**
2. Band thresholds (asymmetric set above). **LOCKED.**
3. Stance-caps-ceiling rule (yes). **LOCKED.**
4. Materialized decaying modifiers **deferred to LD-P2**; LD-P1 ships the scalar EWMA only. **LOCKED.**
