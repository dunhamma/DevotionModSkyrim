# PDV Race Piety-Rate Audit

**Created:** 2026-06-06
**Status:** Working model — informs an open design decision, not yet a locked balance contract
**Owner:** Companion to `PDV_RaceRewardBudgetLedger.md` and `PDV_RaceGameplayBalanceAudit.md`
**Trigger:** Concern that daily piety-earning *opportunity* is wildly skewed across races,
because the daily cap + anti-farm system was calibrated against Nord only.

---

## 1. The question this answers

The reward-budget ledger asks "does each race have comparable *felt* religious life?"
This doc asks a narrower, mechanical question the ledger does not:

> Does each race have enough **repeatable daily opportunity** to feed the **capped deity-piety
> pool** at a comparable rate — i.e. can each race realistically approach the daily cap and
> progress through tiers on a comparable timeline?

This matters because tier thresholds gate every blessing. If two races take 12 vs 60 in-game
days to reach Devoted purely because of how many daily hooks feed the piety pool, that is a
balance fault even if both races' *rewards* are individually well-budgeted.

---

## 2. The capped system (grounded constants)

From `PDV__ManagerQuest.psc` (`RunDawnConsolidateScratch`) and `PDV_DeityBase.psc`:

| Constant | Value | Meaning |
|---|---|---|
| `PIETY_DAILY_MAX_DELTA` | **4.3** | Max net piety gain per deity per day |
| `GAIN_RATE_SCALE` | **1.32** | `PietyToday` is multiplied by this before the clamp |
| Raw `PietyToday` to hit cap | **≈ 3.26** | `4.3 / 1.32` |
| `ThresholdSeeker` | 25 | Tier 1 |
| `ThresholdDevoted` | 50 | Tier 2 |
| `ThresholdChampion` | 85 | Tier 3 |
| `PIETY_MAX` | 200 | Hard ceiling |

**Days-to-tier *at a perfect daily cap* (best case any race can do):**

| Tier | Piety | Days at +4.3/day |
|---|---|---|
| Seeker | 25 | ~6 |
| Devoted | 50 | ~12 |
| Champion | 85 | ~20 |

So even the richest race needs ~12 in-game days of *capped* play to reach Devoted. A race that
can only bank a fraction of the cap per day multiplies that timeline proportionally.

**Anti-farm shape:** `ConsumeDailyRepeatMultiplier` decays each repeat of the *same* signal by
`0.7^n`. One signal spammed all day asymptotes at `1/(1-0.7) = 3.33×` its base value. Therefore
**variety of distinct daily signals matters far more than raw repetition** — a race with one
repeatable signal is hard-capped at ~3.33× that signal's base no matter how much the player grinds.

---

## 3. The three channels that can feed the capped pool

| # | Channel | Entry point | Who it serves | Repeatable? |
|---|---|---|---|---|
| 1 | **Universal kills** | `PDV_ActionRouter.RouteAction` → `deity.ScoreAction` → `AwardPiety` | Any deity whose `ScoreAction` pays for kills | Yes — abundant |
| 2 | **Contextual favors** | `ResolveEligibleFavorLane()` | **Nord + Altmer only** | Yes, but long cooldowns; spell grant ≠ piety |
| 3 | **Race substrates** | `ConsumeDailyRepeatMultiplier` → `Record*Scaled` | Khajiit/Argonian/Dunmer/Orc/Redguard | Yes — **but feeds substrate *tiers*, NOT `PDV.PietyToday`** |

### 3.1 Channel 1 is wired for ONE deity, not "combat races"

`PDV_ActionRouter` / `PDV_EventBus` fan kill events out to `deity.ScoreAction`. But
**`PDV_DeityBase.ScoreAction` returns `0.0`** — every deity earns nothing unless it has a
dedicated script override. Only **6 deities are scripted**: Kyne, Talos, Auri-El, Y'ffre, Z'en,
Baan Dar. Their actual scoring (read from source):

| Deity (race) | Ordinary kills | Shouts | Curated signals (one-shot) |
|---|---|---|---|
| **Kyne** (Nord) | humanoid **+0.5**, beast **−3.0** (Kyne protects beasts) | +0.35 ×3/day | — |
| **Talos** (Nord/Imp) | **0** | +0.5 ×2/day | shrine defiance +3, protect +4, milestone +5 |
| **Auri-El** (Altmer) | **0** | — | dawn ack +1, orthodoxy +3 |
| **Y'ffre** (Bosmer) | **0** | — | pact +2, living story +2.5, recommit +4, violation −2 |
| **Z'en** (Bosmer) | **0** | — | exchange/confirmation signals |
| **Baan Dar** (Bosmer) | **0** | — | bandit road +3, confirmation +2 |
| **All other deities** (Breton, Dunmer, Argonian, Orc, Redguard patrons) | **0** | **0** | **none — no script** |

→ **Kyne is the only deity in the build with a real repeatable kill faucet.** A Nord-Kyne player
caps the 4.3 with ~7–9 humanoid kills/day (events 1–4 have no per-deity cap, only the global dawn
clamp). Every other patron earns **nothing** from ordinary combat.

→ The intuition "combat races (Redguard/Orc) can grind kills to cap" is **false in the current
build** — those races have no scripted deity, so kills score 0.0 for them.

### 3.2 Channel 2 is wired for two races

`ResolveEligibleFavorLane()` returns a real lane only for Nord (Kyne / Old Ways / Nine Divines)
and Altmer. All other races fall to `FAVOR_LANE_NONE`. Favors are also a temporary spell grant
on `FAVOR_FAMILY_STANDARD_COOLDOWN_DAYS`, not a piety drip.

### 3.3 Channel 3 does not touch the capped pool

Substrate signals call `Record*Scaled` on the substrate scripts, adjusting substrate **tier**
(lunar / Hist / ancestor / life-mode / sect). **Verified:** no substrate script calls `AwardPiety`
or writes `PDV.Piety` / `PDV.PietyToday` (grep clean). They are a **parallel progression axis** the
cap neither limits nor fills. Note only 3 are true substrate scripts (Khajiit lunar, Argonian Hist,
Dunmer ancestor); Orc life-mode and Redguard sect are state-tracks, not scored substrates.

---

## 4. Per-race piety-rate model (live wired inventory)

This counts only hooks that **actually call `AwardPiety` in the current build** (verified by
tracing every `AwardPiety` / `AwardCuratedSignal` caller). "Repeatable" = can fire many times in
normal play; "one-time/low-freq" = book read, path transition, quest stage, or milestone.

| Race | Patron(s) wired to score piety | Repeatable daily faucet | One-time / low-freq piety | Realistic piety/day | Days→Devoted (50) |
|---|---|---|---|---|---|
| **Nord** | Kyne ✓, Talos ✓ | **Kyne humanoid kills (+0.5, uncapped)** + shouts (~1) | Talos shrine defiance (+3) | **~4.3 (caps)** | **~12** |
| **Bosmer** | Y'ffre ✓, Z'en ✓, Baan Dar ✓ | none (path signals are event-gated) | path positive/story/recommit (+2 to +4) | ~0–2 (bursty) | 30–60+ |
| **Altmer** | Auri-El (defined, **not fired** by live hook) | none | favor lane = **spell, not piety** | **~0** | stalls |
| **Imperial** | Talos (defiance only) | shouts (~1, if Talos patron) | shrine defiance (+3) | ~0–1 | 60+ |
| **Khajiit** | none scripted | none | book read (one-time) | **~0** → substrate | n/a (substrate-led) |
| **Argonian** | none scripted | none | book read (one-time) | **~0** → substrate | n/a (substrate-led) |
| **Dunmer** | none scripted | none | book reads (one-time) | **~0** → substrate | n/a (substrate-led) |
| **Orc** | none scripted | none | book read (one-time) | **~0** → state-track | n/a |
| **Redguard** | none scripted | none | book read (one-time) | **~0** → state-track | n/a |
| **Breton** | none scripted | none | book read (one-time) | **~0** → tradition track | n/a |

**Bottom line:** exactly **one race (Nord, via Kyne) has a working repeatable deity-piety
faucet.** Bosmer earns in one-time bursts. Every other race earns ~0 capped piety today — their
religious progression rides entirely on the substrate/state axis plus one-time book hooks.

**Corroborating one-time-hook skew** (`pdv_phase20_base_wiring_audit.mjs`): quest-stage routes
Nord 7 → Orc 1; source-fills Altmer 8 → Bosmer 0. The one-time hooks lean the same way, so they
do not compensate.

---

## 4b. What the substrates are actually doing (and the design question)

Substrates (`PDV_Substrate_KhajiitLunar`, `_ArgonianHist`, `_DunmerAncestor`) and the Orc/Redguard
state-tracks **do not feed piety**. They drive a substrate **tier** that gates its own effects
(the lunar/Hist/ancestor reward layer in `PDV_RaceRewardBudgetLedger.md`), express identity, and
modify curse/eligibility posture. They are a *second progression currency*, not a piety on-ramp.

So the project currently has **two unequal currencies**:
- **Piety** → gates the tiered blessings (Seeker/Devoted/Champion). Only Nord earns it well.
- **Substrate tier** → gates race-flavor effects. Only the 5 substrate/state races have it.

This is why piety feels uneven: for 8 of 10 races, *the piety axis is effectively dead* and only
the substrate axis is live — but the substrate axis doesn't unlock the main blessing tiers.

**Recommendation (for the §6 decision):** keep substrates doing their identity/state job, but make
piety the **shared spine every race can fill**. Two non-exclusive levers:
1. **Give every race scripted, repeatable scored hooks** (the real fix): expand `ScoreAction` /
   curated-signal coverage so each patron pays for that race's authentic daily behavior
   (prayer, rest, study, civic act, sect duty, road circuit), not just Kyne-style kills.
2. **Let substrate milestones also award a piety pulse** (cheap bridge): when a substrate tier
   advances, emit a curated signal to the race's patron. This reuses existing substrate hooks to
   keep the piety axis alive for substrate races without authoring a whole new signal set first.

Lever 2 alone would immediately un-stall Khajiit/Argonian/Dunmer; lever 1 is the durable answer.

---

## 4c. Deep-dive verification — what is built vs. the missing link

Traced every piety-scoring entry point in the live build (complete set):
`ScoreAction` is called from `PDV_ActionRouter` (kills), `PDV_EventBus` (kills), and the manager
shout handler; `ScoreCuratedSignal` is called only from `AwardCuratedSignal`, whose callers are
the Bosmer trio (Y'ffre/Z'en/Baan Dar) + one Talos shrine-defiance + MCM debug. **There is no
generic shrine/prayer/worship → piety hook.** That is the entire piety faucet.

Then read the per-race immersive handlers. Confirmed at source level that they **record state, not
piety**:

| Handler | What it writes | Piety? |
|---|---|---|
| `HandleBretonKnightlyVow` / `HiddenArtExposure` / `GreenWayStanding` | `KnightlyVowIntegrity`, `WitchcraftExposure`, `DruidicStanding` counters | **No** |
| `HandleDunmerReclamationFocus` / `DeviationPrice` | `ReclamationFocus`, counters | **No** |
| `HandleImperialCivicService` / `TalosPressure` / `PatronCivicFavor` | civic/Talos pressure counters | **No** |
| `HandleOrc*` (Stronghold/City/Legion/Conduct) | `RecordOrcLifeModeSignal` → life-mode state | **No** |
| `HandleRedguard*` (sect/duty/token/spine) | sect state track | **No** |
| `HandleArgonian*`, `HandleKhajiit*`, `HandleDunmer*` (ancestor) | substrate tiers | **No** |

**Reward gate (the decisive link):** `IsFirstTierRaceRewardEligible()` requires
`GetTier(_activeDeity) >= TIER_SEEKER`, and `RecomputeTier` → `ComputeTierFromPiety` reads
**only `PDV.Piety`**. Substrate tier and state counters do **not** feed it. So the T1 race reward
is reachable only by accruing 25 patron piety — which, per §4, only Nord (and bursty Bosmer) can do.

**What this means for "did we already sort this":** the *routing and state architecture* IS built
and proven — P2 receivers, immersive handlers, substrate/state tracks, the 10-race reward
contract, anti-farm, content prose, verifier/route proof. The project's own
`implementationStatusValues` (phase20-required → draft-prose → content-ready → verifier-covered →
runtime-proven) track **content and route proof — not whether a hook awards piety**. So the hooks
were built to *fire and record state* (which the verifiers check green), and the reward spells
were authored, but **the wire from "hook fired" to "patron piety increased" was only ever
connected for Kyne/Talos/Bosmer.** The gap is one specific link, not the whole system.

---

## 5. Finding

The skew is **structural, not a tuning error**, and it falls along a single fault line:

> **Combat theologies feed the capped piety pool richly and hit the cap easily. Contemplative,
> civic, and substrate theologies barely feed it at all — their daily religious life was routed
> into substrate tiers and one-time book/quest hooks instead.**

This was never an explicit decision. It fell out of which hooks happened to get wired first
(kills + Nord/Altmer favors). The daily cap (4.3) and `0.7^n` decay are well-designed **but only
proven against Nord**, the single race sitting on the richest channel.

---

## 6. The open decision (model-first; not yet chosen)

The fix depends on an intent decision that has not been made:

1. **Piety parity** — every race should feed the capped pool at a comparable rate.
   *Implies:* expand `PDV_ActionRouter`'s universal signal set beyond kills (shrine/prayer/
   rest/travel/study/civic-act events that non-combat `ScoreAction` implementations can pay),
   and/or extend favor lanes to all races.
2. **Substrates are the parity layer** — contemplative races *intentionally* progress mainly
   via substrate tiers; piety stays combat-leaning.
   *Implies:* tune substrate cadence + reward weight to be a genuine equal of tier progression,
   document the asymmetry, and accept uneven piety rates as designed.
3. **Hybrid / convert** — substrate progress converts into piety or tier so one cap governs all.
   *Implies:* a defined substrate→piety/tier conversion with its own anti-farm.

**Whichever is chosen, re-validate the 4.3 cap + `0.7^n` decay against at least one non-combat
race** — the current numbers have only ever been exercised by the richest channel.

---

## 7. Recommended review scope (end-to-end, bounded)

This is an end-to-end review trigger, but a scoped one — the architecture is sound; the
cross-race *rate model* is the gap.

1. Lock the §6 intent decision.
2. If parity/hybrid: design the expanded universal signal set or the conversion, with anti-farm.
3. Build a small instrumented "signals/day → piety/day → days-to-tier" harness per race to
   replace the assumptions in §4 with measured numbers.
4. Re-tune `PIETY_DAILY_MAX_DELTA` / `GAIN_RATE_SCALE` against a contemplative race.
5. Feed results back into `PDV_RaceRewardBudgetLedger.md` and the per-race effect ledger.

---

## 9. Design resolution — is piety the right home for state counters?

Deep-dive verdict: **no single answer — there are three different kinds of "counter," and the
intended architecture already routes them to three different homes.** Forcing all of them into
piety would violate the project's own "two always-on boon families" budget rule and flatten the
race identity the substrates exist to express. Your instinct ("same mechanism hidden under
substrates is fine") matches the locked design.

### The architecture has TWO reward currencies by design (verified in code)
- **Piety** → per-deity, drives Seeker/Devoted/Champion **foreground** patron blessings
  (`RecomputeTier` ← `PDV.Piety`; T1 reward gated on patron tier ≥ Seeker).
- **Substrate tier** → `PDV_SubstrateBase.SyncSubstrateBoonsToTier` grants `Substrate_Always`/
  `Substrate_Mid`/`Substrate_High` at its own LOW/MID(25)/HIGH(75) thresholds, **independent of
  piety**. This is the "low-power persistent substrate boon" layer the design intended.

The asymmetric hybrid boon policy (`PDV_Architecture_v2.md`): Dunmer/Khajiit/Argonian keep the
strongest substrates; Altmer/Redguard/Orc keep light ones; Nord/Imperial/Breton/Bosmer rely on
state tracks + contextual favors + privileges instead of a second passive layer.

### Three buckets → three homes

| Bucket | Examples | Routes to | Rationale |
|---|---|---|---|
| **Identity / selection** | Orc life-mode, Redguard sect, Breton tradition, Dunmer reclamation *focus*, Bosmer path, Nord pantheon baseline | **State track (NOT piety)** | Chooses *which lane* is active; gates eligibility/expression. Best-practice: "substrate stays identity, foreground carries power." |
| **Substrate metric** | Khajiit lunar, Argonian Hist, Dunmer ancestor | **Substrate tier → substrate boons** | The parallel reward currency, by design. This is your "hidden under substrates" — correct and intended. |
| **Foreground devotional act** | Imperial civic service/mercy/burial, Breton vow-keeping, Orc Malacath conduct, Redguard death-duty, Dunmer ash-prayer, Khajiit moon/road-as-emphasis, Argonian Hist-maintenance | **Piety → foreground patron** | The shared spine. This is the bucket that's currently unwired for non-Nord/Bosmer races. |

### Per-race routing target

| Race | Identity → state | Metric → substrate boons | Devotional acts → patron piety (gap) |
|---|---|---|---|
| Nord | pantheon baseline | — | kills(Kyne)/defiance(Talos) — **wired** |
| Bosmer | path | — | path acts — **wired** (bursty) |
| Altmer | Thalmor/crisis | light orthodoxy | dawn/study/orthodoxy → Auri-El (signals exist, **unfired**) |
| Imperial | ConcordatStanding | — | civic service, mercy, burial, Talos defiance → patron (**missing**) |
| Breton | tradition | — | vow / occult / druidic rite → tradition patron (**missing**) |
| Dunmer | reclamation focus | ancestor | ash-prayer, Reclamation acts → focus patron (**missing**) |
| Khajiit | silent emphasis | lunar | moon/road as Khenarthi/Azurah devotion → emphasis (**missing**) |
| Argonian | (Hist is primary) | Hist | Hist-maintenance/People → Hist (**missing**) |
| Orc | life-mode | light standing | Malacath conduct, quality forge, service → Malacath (**missing**) |
| Redguard | sect | light ancestor/death | death-duty, sect acts, Far Shores → Tu'whacca/sect patron (**missing**) |

### Two architecture bugs to fix regardless of the above

1. **Thematically-substrate rewards are gated on the unfed piety axis.** `PDV_Bless_Khajiit_Lunar_T1`
   (night StaminaRateMult +5 / ResistDisease +10) is granted by the manager **only when the patron
   is at piety Tier ≥ Seeker** — but lunar observance feeds the substrate, not piety. So a Khajiit
   can max the Lunar Lattice and still receive nothing. Decide per reward whether it belongs to the
   **substrate tier** (its natural home) or to **foreground piety** (then feed that piety).
2. **Substrate boon slots appear unpopulated.** No `Substrate_Always/Mid/High` spell is referenced
   in any authoring manifest (grep clean); only the piety-gated `PDV_Bless_*_T1` set is authored.
   If confirmed empty, substrate races currently get **nothing from either axis** — which matches
   the `Thin` verdicts in `PDV_RaceRewardBudgetLedger.md`. **Verify and wire.**

### "Other options" besides piety
No new currency is needed. For low-violence/civic races, keep piety as the spine but let it be
**fed by recognition-worthy acts** and let it **unlock privileges/recognition**, not only stat
blessings (`PDV_RaceRewardBudgetLedger.md` rule 5: privileges/recognition are reward wealth). The
uniqueness comes from *which acts feed each race's piety* and *what the tier unlocks* — not from
inventing per-race progression maths.

### Same act, both axes (Khajiit/Argonian/Dunmer)
The design intends a single act (e.g. moon observance) to feed **both** the substrate metric
(identity) **and** a small foreground piety pulse to the emphasis deity — Khajiit emphasis is
explicitly piety-thresholded (≥50 piety, 15 lead). Keep the substrate boon low-power so this does
not breach the two-boon-family cap.

---

## 8. Assumptions to verify before locking

- Favor lanes contribute ~0 *piety* (treated as spell grants). Confirm no favor path calls `AwardPiety`.
- Substrate scripts never write `PDV.Piety` / `PDV.PietyToday`. Confirmed for the functions read; verify across all five substrates.
- Per-kill magnitudes (0.25–0.5) sampled from Kyne; other combat deities assumed similar — confirm.
- "Active session" kill counts are estimates, not telemetry. Replace with the §7.3 harness.
