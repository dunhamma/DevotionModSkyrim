# Piety Pace — Balancing Table (per-act values back-solved from target calendar)

**Purpose:** lock the per-act piety values and the daily clamp so the time-to-tier
matches an agreed calendar. Closes the "exact values TBD during balancing" gap
(`references/PDV_RaceArchitecture_DesignReference.md:801`).

> **Revision (moderate-compression pass):** the calendar was compressed from the original
> 10/20/34 (base 2.5/day) to **8/15/26 (base 3.3/day)** so the top tier lands sooner. All
> per-act values, the clamp, and the Orc calendars below reflect the compressed rates.

## 1. Locked targets

Tier thresholds are unchanged: **Observant 25 · Faithful 50 · Devoted 85**
(code aliases: Seeker/Devoted/Champion). "Champion / top tier" = Devoted = 85.

| Tier | Piety | **Default UX** (avg player) | **Ceiling** (super-devoted RP) |
|------|------:|:---------------------------:|:------------------------------:|
| Observant | 25 | **~8 days** | **~6 days** |
| Faithful | 50 | **~15 days** | **~12 days** |
| Devoted (top) | 85 | **~26 days** | **~20 days** |

The ceiling is ~30% faster than default. Both columns are a single flat net-gain rate
applied every day of active worship:

- **Default net gain ≈ 3.3 piety/day** → 25/50/85 land at day 8 / 15 / 26.
- **Ceiling net gain ≈ 4.3 piety/day** → 25/50/85 land at day 6 / 12 / 20.

So the entire calendar reduces to **two numbers**: the typical daily gain a steady
player generates (3.3) and the hard daily clamp a maximizer can reach (4.3).

## 2. The one engine change required

The dawn-consolidation clamp is currently **±5/day** (`PDV_Architecture_v3.md:128`),
which would let a maximizer hit 5/10/17 — *faster* than the desired ceiling. Lower it:

| Constant | Old | **New** | Effect |
|----------|----:|--------:|--------|
| `DAWN_CLAMP_PER_DAY` | 5.0 | **4.3** | hard ceiling becomes 6 / 12 / 20 days |

This is the only guaranteed way to enforce a ceiling — content cooldowns alone leak.
The clamp is symmetric, so max *loss* from behavior also softens to −4.3/day, which
fits the "slow, recoverable drift" philosophy. Passive decay (0.5/day, 2-day grace,
tier floors) is a separate, much gentler system — see §5 and `PDV_DecayAudit.md`.

## 3. Per-act piety schedule

Calibrated so **typical play nets ~3.3/day** and a heavy day saturates the 4.3 clamp.
"Net" ≈ "gross" during an active climb, because regular worship keeps resetting the
2-day decay grace and active patrons are decay-exempt. Values scaled so that the
canonical "1 prayer + 1 standard favor" still equals one base day (preserving the
`PDV_SignalDensityAudit.md` "one favor/day clears it" property).

| Class | Example acts | Value | Cooldown / cap |
|-------|--------------|------:|----------------|
| **A — Devotion** | prayer at shrine / portable shrine / home altar | **+1.3** | 8–12 h cooldown; daily cap **2.6** |
| **B — Minor aligned** | incidental in-domain behavior (a Kyne-aligned wild kill, an Arkay undead cleanse in passing) | **+0.7** | daily cap **2.0** |
| **C — Standard favor** | a deliberate domain act (Mara charity, defiant Talos shout, Malacath quality-labor) | **+2.0** | ~1/day typical; daily cap **4.0** |
| **D — Milestone** | quest resolution, rite, artifact, conversion beat | **+6** (one-time); **+10** for a god's signature questline (optional) | clamp-bypassing + one-shot guarded (see §5) |
| **E — Violation** | counter-aligned act (Green Pact breach, Talos shrine for an Altmer) | **−1.0 to −15** + rival erosion | per the v2 stance/rivalry ledger |

### Worked days

- **Average steady day:** 1×A (1.3) + 1×C (2.0) = **+3.3** → tracks the default column.
- **Devout day:** 2×A (2.6) + 1×C (2.0) + 1×B (0.7) = 5.3 gross → clamped to **+4.3** → tracks the ceiling.
- **Light/blended day:** 1×A only = +1.3 → slower; this is the realistic "most days aren't perfect" sag the default column already absorbs.

## 4. Calendar verification

Cumulative piety on a perfectly-consistent climb (no decay, active worship):

| Day | Default (3.3/day) | Ceiling (4.3/day) |
|----:|------------------:|------------------:|
| 6  | 19.8 | **25.8 → Observant @ ~6** |
| 8  | **26.4 → Observant @ ~8** | 34.4 |
| 12 | 39.6 | **51.6 → Faithful @ ~12** |
| 15 | **49.5 → Faithful @ ~15** | 64.5 |
| 20 | 66.0 | **86 → Devoted @ ~20** |
| 26 | **85.8 → Devoted @ ~26** | 100 (capped) |

Both columns hit the agreed targets.

## 5. Interaction notes

- **Broad vs focused.** Most races cap broad worship at **Faithful (50)**
  (`PDV_RaceArchitecture_DesignReference.md` race caps), so broad-worship gods only
  ever traverse the 25→50 band: **8→15 days** default, **6→12** ceiling. The
  **Devoted (85)** band is focused-patron only. The patron *offer* fires at Faithful/50
  (`PDV_TargetEndStates_1.0.md:430`) — i.e. day ~15 default / ~12 ceiling — and the
  35-piety focused climb to Devoted is the back half of the calendar.

- **Uniform across gods by construction — with sanctioned exceptions.** Every deity
  shares the same thresholds, clamp, and schedule, so time-to-tier is identical *given
  equal daily signal*. The 8/15/26 default is validated against each god's trigger
  surface in `PDV_SignalDensityAudit.md`, which confirms most gods clear ~3.3/day and
  catalogues the deliberate off-calendar cases: **Orc life-modes** (Stronghold 1.00 ×
  base, City 0.75, Legion 0.60 — a ~43-day Legion climb to Devoted by design),
  **Argonian Hist** (a passive decay drag, not a multiplier), and **Daedric paths**
  (multi-day rite cadence, not daily accrual). Genuine density gaps (currently Bosmer
  Exchange and Breton Knight's Road) are fixed with a **richer trigger family, never a
  higher per-act value** — pace is set at the value layer, density at the trigger layer.

- **Milestones bypass the clamp (small + one-shot).** Class-D milestones are applied
  through a direct `Adjust(points, reason)` call that **bypasses** the daily clamp
  (`PDV_Architecture_v3.md:495`), so a big story beat actually registers instead of
  collapsing into a normal day. Under the clamp, milestone *size* is meaningless —
  any value above 4.3 is clamped to 4.3, so +6 and +15 behave identically — which is
  why bypass is required for milestones to matter at all.

  The magnitude is kept **small (+6)** so bypass stays safe. At +6 a milestone is worth
  ~2 default days, so it punctuates the climb without catapulting:
  - It cannot skip a tier — crossing a 25-piety band needs **~4** distinct one-time
    milestones; reaching Faithful (50) from zero on milestones alone needs **~8**,
    more milestone-grade quests than a god realistically offers.
  - It cannot trip a premature patron offer or focus emergence off a single quest
    (a +6 bump moves ~35 → ~41, not across 50).
  - Because the climb-crossing cross-tier exploit self-closes at this magnitude, the
    earlier "milestone can't cross a threshold" rule is **not needed** and is dropped.

  The **one required guardrail** is that each milestone is **one-shot guarded**
  (the `PDV.Surfaced.*` pattern) so a repeatable quest moment can't be farmed.

  **Optional signature peak.** A single *signature* questline per god — the act that
  makes you its true champion — may use **+10** instead of +6 for one standout moment.
  This is a ~1-day-of-progress difference, so it is pure flavor; flat +6 everywhere is
  equally valid and simpler.

  Pace is undisturbed: milestones are sparse, so a full playthrough nets only ~+30
  bonus spread across ~26 days. A quest-dense god will run slightly ahead, which is
  earned (doing most of a god's content *is* established faith), not an exploit.

- **Decay only bites the inactive.** During an active climb there is effectively no
  decay (the 2-day grace resets every worship day). The 0.5/day drain matters for
  *holding* a tier across idle stretches; tier floors (with a 5-point tier-down
  hysteresis) mean a reached tier can't be lost on a brief lapse. Decay does **not**
  change the time-to-first-reach for a steady player, so it stays out of this calendar.
  Full model and the decided forks (2-day grace, hysteresis, curse-floor bypass, Orc
  decay scaling) live in `PDV_DecayAudit.md`.

## 6. Constants to set in code

```
DAWN_CLAMP_PER_DAY        = 4.3     ; was 5.0  — enforces the 6/12/20 ceiling
ThresholdSeeker  (Observant) = 25   ; unchanged
ThresholdDevoted (Faithful)  = 50   ; unchanged
ThresholdChampion(Devoted)   = 85   ; unchanged
DECAY_PER_DAY             = 0.5     ; unchanged
DECAY_GRACE_DAYS          = 2       ; was 3 — decay audit: tighten so the meter breathes
TIER_DOWN_HYSTERESIS     = 5.0      ; lose a tier only 5 below its threshold (anti-whiplash)
SIGNAL_PRAYER            = 1.3      ; Class A, daily cap 2.6
SIGNAL_MINOR_ALIGNED     = 0.7      ; Class B, daily cap 2.0
SIGNAL_STANDARD_FAVOR    = 2.0      ; Class C, daily cap 4.0
SIGNAL_MILESTONE         = 6.0      ; Class D, one-time, clamp-BYPASSING + one-shot guarded
SIGNAL_MILESTONE_SIGNATURE = 10.0   ; Class D, optional: one signature questline per god
ORC_RATE_MULT_STRONGHOLD   = 1.00   ; Orc life-mode daily-rate multiplier (ProcessDawn, pre-clamp)
ORC_RATE_MULT_CITY         = 0.75   ; -> City calendar 10/20/34
ORC_RATE_MULT_LEGIONEXILE  = 0.60   ; -> Legion/Exile calendar 13/25/43
```

The `ORC_RATE_MULT_*` values are the only sanctioned per-deity rate multipliers in 1.0; they
multiply the daily gain in ProcessDawn *before* the clamp, so they scale both the default (3.3)
and ceiling (4.3) rates. All other gods run at ×1.00. See `PDV_SignalDensityAudit.md` for the
full per-mode calendar and `PDV_RaceDesign_Orc.md` for the theology.

Class-D milestones are applied via a direct `Adjust(SIGNAL_MILESTONE, reason)` that
skips the dawn clamp, and each must be wrapped in a one-shot `PDV.Surfaced.*` guard.
All other classes (A–C) still feed the clamped dawn consolidation.

Per-deity tuning is still allowed on top of these defaults (a multi-domain god may
warrant a higher milestone band), but the baseline above is what produces the agreed
8/15/26 default and 6/12/20 ceiling calendar.
