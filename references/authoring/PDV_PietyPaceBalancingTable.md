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
| **D — Milestone** | quest resolution, rite, artifact, conversion beat | **+5** (one-time); **+8** for a god's signature questline (optional) | clamp-bypassing + one-shot guarded (see §5) |
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

- **Uniform across gods by construction — with sanctioned exceptions.** Every deity
  shares the same thresholds, clamp, and schedule, so time-to-tier is identical *given
  equal daily signal*. The 10/20/34 default is validated against each god's trigger
  surface in `PDV_SignalDensityAudit.md`, which confirms most gods clear ~2.5/day and
  catalogues the deliberate off-calendar cases: **Orc life-modes** (Stronghold 1.00 ×
  base, City 0.75, Legion 0.60 — a ~57-day Legion climb to Devoted by design),
  **Argonian Hist** (a passive decay drag, not a multiplier), and **Daedric paths**
  (multi-day rite cadence, not daily accrual). Genuine density gaps (currently Bosmer
  Exchange and Breton Knight's Road) are fixed with a **richer trigger family, never a
  higher per-act value** — pace is set at the value layer, density at the trigger layer.

- **Milestones bypass the clamp (small + one-shot).** Class-D milestones are applied
  through a direct `Adjust(points, reason)` call that **bypasses** the daily clamp
  (`PDV_Architecture_v3.md:495`), so a big story beat actually registers instead of
  collapsing into a normal day. Under the clamp, milestone *size* is meaningless —
  any value above 3.5 is clamped to 3.5, so +5 and +15 behave identically — which is
  why bypass is required for milestones to matter at all.

  The magnitude is kept **small (+5)** so bypass stays safe. At +5 a milestone is worth
  ~2 default days, so it punctuates the climb without catapulting:
  - It cannot skip a tier — crossing a 25-piety band needs **5** distinct one-time
    milestones; reaching Faithful (50) from zero on milestones alone needs **10**,
    more milestone-grade quests than a god realistically offers.
  - It cannot trip a premature patron offer or focus emergence off a single quest
    (a +5 bump moves ~35 → ~40, not across 50).
  - Because the climb-crossing cross-tier exploit self-closes at this magnitude, the
    earlier "milestone can't cross a threshold" rule is **not needed** and is dropped.

  The **one required guardrail** is that each milestone is **one-shot guarded**
  (the `PDV.Surfaced.*` pattern) so a repeatable quest moment can't be farmed.

  **Optional signature peak.** A single *signature* questline per god — the act that
  makes you its true champion — may use **+8** instead of +5 for one standout moment.
  This is a ~1-day-of-progress difference, so it is pure flavor; flat +5 everywhere is
  equally valid and simpler.

  Pace is undisturbed: milestones are sparse, so a full playthrough nets only ~+20–30
  bonus spread across ~34 days. A quest-dense god will run slightly ahead, which is
  earned (doing most of a god's content *is* established faith), not an exploit.

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
SIGNAL_MILESTONE         = 5.0      ; Class D, one-time, clamp-BYPASSING + one-shot guarded
SIGNAL_MILESTONE_SIGNATURE = 8.0    ; Class D, optional: one signature questline per god
ORC_RATE_MULT_STRONGHOLD   = 1.00   ; Orc life-mode daily-rate multiplier (ProcessDawn, pre-clamp)
ORC_RATE_MULT_CITY         = 0.75   ; -> City calendar 13/27/45
ORC_RATE_MULT_LEGIONEXILE  = 0.60   ; -> Legion/Exile calendar 17/33/57
```

The `ORC_RATE_MULT_*` values are the only sanctioned per-deity rate multipliers in 1.0; they
multiply the daily gain in ProcessDawn *before* the clamp, so they scale both the default (2.5)
and ceiling (3.5) rates. All other gods run at ×1.00. See `PDV_SignalDensityAudit.md` for the
full per-mode calendar and `PDV_RaceDesign_Orc.md` for the theology.

Class-D milestones are applied via a direct `Adjust(SIGNAL_MILESTONE, reason)` that
skips the dawn clamp, and each must be wrapped in a one-shot `PDV.Surfaced.*` guard.
All other classes (A–C) still feed the clamped dawn consolidation.

Per-deity tuning is still allowed on top of these defaults (a multi-domain god may
warrant a higher milestone band), but the baseline above is what produces the agreed
10/20/34 default and 7/14/24–25 ceiling calendar.
