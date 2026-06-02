# Piety Pace — Balancing Table (per-act values back-solved from target calendar)

**Purpose:** lock the per-act piety values and the daily clamp so the time-to-tier
matches an agreed calendar. Closes the "exact values TBD during balancing" gap
(`references/PDV_RaceArchitecture_DesignReference.md:801`).

## 1. Locked targets

Tier thresholds are unchanged: **Observant 25 · Faithful 50 · Devoted 85**
(code aliases: Seeker/Devoted/Champion). "Champion / top tier" = Devoted = 85.

| Tier | Piety | **Default UX** (avg player) | **Ceiling** (super-devoted RP) |
|------|------:|:---------------------------:|:------------------------------:|
| Observant | 25 | **~10 days** | **~7 days** |
| Faithful | 50 | **~20 days** | **~14 days** |
| Devoted (top) | 85 | **~34 days** | **~24–25 days** |

The ceiling is ~30% faster than default, per the design call. Both columns are a
single flat net-gain rate applied every day of active worship:

- **Default net gain ≈ 2.5 piety/day** → 25/50/85 land at day 10 / 20 / 34.
- **Ceiling net gain ≈ 3.5 piety/day** → 25/50/85 land at day 7.1 / 14.3 / 24.3.

So the entire calendar reduces to **two numbers**: the typical daily gain a steady
player generates (2.5) and the hard daily clamp a maximizer can reach (3.5).

## 2. The one engine change required

The dawn-consolidation clamp is currently **±5/day** (`PDV_Architecture_v3.md:128`),
which would let a maximizer hit 5/10/17 — *faster* than the desired ceiling. Lower it:

| Constant | Old | **New** | Effect |
|----------|----:|--------:|--------|
| `DAWN_CLAMP_PER_DAY` | 5.0 | **3.5** | hard ceiling becomes 7 / 14 / 24–25 days |

This is the only guaranteed way to enforce a ceiling — content cooldowns alone leak.
The clamp is symmetric, so max *loss* from behavior also softens to −3.5/day, which
fits the "slow, recoverable drift" philosophy. Decay (0.5/day, 3-day grace, tier
floors) is unchanged.

## 3. Per-act piety schedule

Calibrated so **typical play nets ~2.5/day** and a heavy day saturates the 3.5 clamp.
"Net" ≈ "gross" during an active climb, because regular worship keeps resetting the
3-day decay grace (`PDV_Architecture_v3.md:1369`) and active patrons are decay-exempt.

| Class | Example acts | Value | Cooldown / cap |
|-------|--------------|------:|----------------|
| **A — Devotion** | prayer at shrine / portable shrine / home altar | **+1.0** | 8–12 h cooldown; daily cap **2.0** |
| **B — Minor aligned** | incidental in-domain behavior (a Kyne-aligned wild kill, an Arkay undead cleanse in passing) | **+0.5** | daily cap **1.5** |
| **C — Standard favor** | a deliberate domain act (Mara charity, defiant Talos shout, Malacath quality-labor) | **+1.5** | ~1/day typical; daily cap **3.0** |
| **D — Milestone** | quest resolution, rite, artifact, conversion beat | **+5 to +15**, one-time | clamp-respecting (see §5) |
| **E — Violation** | counter-aligned act (Green Pact breach, Talos shrine for an Altmer) | **−1.0 to −15** + rival erosion | per the v2 stance/rivalry ledger |

### Worked days

- **Average steady day:** 1×A (1.0) + 1×C (1.5) = **+2.5** → tracks the default column.
- **Devout day:** 2×A (2.0) + 1×C (1.5) + 1×B (0.5) = 4.0 gross → clamped to **+3.5** → tracks the ceiling.
- **Light/blended day:** 1×A only = +1.0 → slower; this is the realistic "most days aren't perfect" sag the default column already absorbs.

## 4. Calendar verification

Cumulative piety on a perfectly-consistent climb (no decay, active worship):

| Day | Default (2.5/day) | Ceiling (3.5/day) |
|----:|------------------:|------------------:|
| 7  | 17.5 | **24.5 → Observant @ ~7** |
| 10 | **25 → Observant @ 10** | 35 |
| 14 | 35 | **49 → Faithful @ ~14** |
| 20 | **50 → Faithful @ 20** | 70 |
| 24 | 60 | **84 → Devoted @ ~24–25** |
| 34 | **85 → Devoted @ 34** | 100 (capped) |

Both columns hit the agreed targets.

## 5. Interaction notes

- **Broad vs focused.** Most races cap broad worship at **Faithful (50)**
  (`PDV_RaceArchitecture_DesignReference.md` race caps), so broad-worship gods only
  ever traverse the 25→50 band: **10→20 days** default, **7→14** ceiling. The
  **Devoted (85)** band is focused-patron only. The patron *offer* fires at Faithful/50
  (`PDV_TargetEndStates_1.0.md:430`) — i.e. day ~20 default / ~14 ceiling — and the
  35-piety focused climb to Devoted is the back half of the calendar.

- **Uniform across gods by construction.** Every deity shares the same thresholds,
  clamp, and schedule, so time-to-tier is identical *given equal daily signal*. The
  only cross-god variance is **signal density** (how many Class A–C opportunities a
  god realistically affords per day). Keep an eye on gods whose domains rarely come up
  in normal play — they may need a slightly richer trigger family, **not** a higher
  per-act value, to stay on the same calendar.

- **Milestones and the clamp (the one tradeoff).** A +10 Class-D milestone on a given
  day is still clamped to +3.5 that day, so the overflow is "wasted." This is
  deliberate: it keeps the hard ceiling intact and makes milestone days *guaranteed
  max days* rather than catapults. If you later decide quest moments should feel
  bigger than a normal day, the alternative is to route Class-D through a direct
  `Adjust(points, reason)` call that **bypasses** the daily clamp
  (`PDV_Architecture_v3.md:495`) — at the cost of the 7/14/24 ceiling guarantee.
  Recommend keeping milestones clamp-respecting for 1.0.

- **Decay only bites the inactive.** During an active climb there is effectively no
  decay (grace resets every worship day). The 0.5/day drain matters for *holding* a
  tier across idle stretches, and tier floors mean a reached tier can't passively fall
  below the previous threshold. Decay does **not** change the time-to-first-reach for
  a steady player, so it stays out of this calendar.

## 6. Constants to set in code

```
DAWN_CLAMP_PER_DAY        = 3.5     ; was 5.0  — enforces the ceiling
ThresholdSeeker  (Observant) = 25   ; unchanged
ThresholdDevoted (Faithful)  = 50   ; unchanged
ThresholdChampion(Devoted)   = 85   ; unchanged
DECAY_PER_DAY             = 0.5     ; unchanged
DECAY_GRACE_DAYS          = 3       ; unchanged
SIGNAL_PRAYER            = 1.0      ; Class A, daily cap 2.0
SIGNAL_MINOR_ALIGNED     = 0.5      ; Class B, daily cap 1.5
SIGNAL_STANDARD_FAVOR    = 1.5      ; Class C, daily cap 3.0
SIGNAL_MILESTONE_MIN     = 5.0      ; Class D, one-time, clamp-respecting
SIGNAL_MILESTONE_MAX     = 15.0     ; Class D
```

Per-deity tuning is still allowed on top of these defaults (a multi-domain god may
warrant a higher milestone band), but the baseline above is what produces the agreed
10/20/34 default and 7/14/24–25 ceiling calendar.
