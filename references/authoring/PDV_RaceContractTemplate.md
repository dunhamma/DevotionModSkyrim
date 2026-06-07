# PDV Race Contract Template

**Created:** 2026-06-06
**Status:** Living per-race build contract (the "generalized Nord" scaffold)
**Owner:** Companion to `PDV_RacePietyRateAudit.md` (problem analysis) and
`PDV_RaceRewardBudgetLedger.md` / `PDV_RaceEffectReviewLedger.md` (balance locks).

## Why this exists

The piety-rate audit (`PDV_RacePietyRateAudit.md`) proved that only Nord (via Kyne) had a
working piety→tier→reward spine; 7 races earned ~0 piety and their substrate boon slots were
empty. This template is the **per-race checklist** that makes every race as mechanically complete
as Nord — rich daily hooks that feed piety, three escalating reward tiers, populated substrate
boons where applicable, and per-race neglect/regression — **without flattening race identity**.
Each race keeps its unique feel through *which acts feed its piety* and *what its tiers unlock*,
on top of the shared engine.

Fill one copy of §"Per-race contract" for every race. Khajiit is the worked pilot (Phase 1) and
the reference example.

## Shared engine (reuse — do not rebuild)

| Concern | Reuse |
|---|---|
| Award piety | `PDV__ManagerQuest.AwardPiety(deity, amount)`; curated acts via `AwardCuratedSignal(deity, signalType, ref)` → `deity.ScoreCuratedSignal` |
| Kill/shout scoring | `deity.ScoreAction(eventType, ...)` (returns 0 in base — must override per scored deity) |
| Per-deity anti-farm | `PDV_DeityBase.ScoreRepeatableAction(eventType, delta, dailyCap, cooldownDays)` |
| Same-signal diminishing returns | `ConsumeDailyRepeatMultiplier(keyPrefix)` (0.7^n) — substrate/state side only |
| Substrate boons | `PDV_SubstrateBase.SyncSubstrateBoonsToTier` grants `Substrate_Always/Mid/High` at LOW/MID(25)/HIGH(75) |
| Reward grant | `SyncRaceRewardSpell` / `SyncFirstTierRaceRewardRuntime` |
| Decay / tier regression | `RunDawnApplyDecay`, `ApplyDecayToDeity` (0.5/day, 2-day grace, broad ×0.2, tier floors, hysteresis 5, high-water-mark) — **race-agnostic, already works** |
| Neglect spell wiring | model `SyncKyneNeglectSpell` + `PDV_SPEL_Neglect_Kyne` in `RunDawnApplySpellAndNeglectLayers` |
| Tiers | Seeker 25 / Devoted 50 / Champion 85 (`PDV_DeityBase` thresholds) |
| Daily cap | `PIETY_DAILY_MAX_DELTA=4.3`, `GAIN_RATE_SCALE=1.32` |

## Reward shape (from `race-sheets/PDV_RaceDesign_Nord.md`)

| Tier | Piety | Shape |
|---|---|---|
| **T1 Seeker** | 25 | Small themed stat (~3–5%). "The god noticed you." |
| **T2 Devoted/Faithful** | 50 | ~6–8% stat **+ 1 signature utility/diegetic effect** (e.g. outdoor sleep restores stamina, animals neutral). Broad-worship cap lands here. |
| **T3 Champion** | 85 | ~10–12% stat **+ stronger signature effect + NPC recognition privilege** (dialogue access, vendor discount). Focused patron only. |

**Grain:** a **broad/baseline set** (T1–T2, capped at Faithful) **plus a full 3-tier set per
focusable patron** (each offerable god/emphasis feels distinct). Stack rule: ≤2 always-on boon
families at once; broad < focused; suppress broad T2 when a patron is focused.

## The gate-type dimension (key cross-race fork)

Each race declares how its rewards are gated:

- **Offer races** (Nord, Imperial, Breton, Orc, Redguard, Altmer, Bosmer, Dunmer-Reclamation):
  rewards gate on **piety Tier ≥ threshold AND active patron** (`IsFirstTierRaceRewardEligible`
  pattern). The patron-offer moment is the commitment.
- **No-offer races** (Khajiit; Argonian-Hist and Dunmer-ancestor substrate lanes): rewards gate
  on **state/substrate tier + emphasis state** (no faked offer). The manager must branch — do not
  assume active-patron universally. These races still get a **small real piety pulse** to a
  scripted patron deity (double-route) so decay/neglect/creed-loss remain honest.

## Neglect / regression model

1. **Soft drift** — existing race-agnostic decay (no action needed beyond a real piety target).
2. **Tier regression** — existing hysteresis/floors (no action needed).
3. **Per-race neglect spell + texture** — `PDV_SPEL_Neglect_<Race>` + `Sync<Race>NeglectSpell`;
   gentle/diegetic by default; **real mechanical bite only at rupture/curse** posture.
4. **Creed-violation loss** — acts that actively contradict the race's creed cause **piety LOSS**
   to the relevant deity (negative `ScoreCuratedSignal` delta), **medium/major signals only**
   (model: Kyne beast-kill −3.0, Y'ffre pact-violation −2.0). No petty/ambient penalties.

---

## Per-race contract (fill one per race)

```
Race:
Foreground patron(s) [scripted PDV_Deity_*, in PDV_FLST_AllDeities, Stance_<Race>=NATIVE, DeityIndex]:
Gate type [offer | no-offer]:

Piety-feeding acts (repeatable):
  - <act> -> <route id> -> Handle<...> -> AwardCuratedSignal/ScoreAction(<deity>, <signal/event>, <delta>)
      anti-farm: ScoreRepeatableAction(dailyCap, cooldown) | ConsumeDailyRepeatMultiplier  [never both on one magnitude]
Creed-violation loss acts (medium/major only):
  - <act> -> <route id> -> AwardCuratedSignal(<deity>, <neg signal>, <-delta>)
Rejected hooks (must NOT score):
  - <list>

Substrate / identity:
  - substrate metric(s) [if substrate race] -> substrate tier -> Substrate_Always/Mid/High boons (low power)
  - identity/selection state(s) [enum]:

Rewards:
  - Broad/baseline set: T1, T2 (capped Faithful) — SPEL/MGEF ids, magnitudes
  - Per-patron 3-tier sets: <patron> T1/T2/T3 — SPEL/MGEF ids, magnitudes, signature, recognition privilege
  - Stack cap / suppression rule:

Neglect:
  - PDV_SPEL_Neglect_<Race> + texture; bite condition (rupture/curse posture):

Surfacing: Survey/status line; Prisma toast on shift; effect descriptions (quiet unless exceptional)

Verifier assertions:
  - deity base-data block (pdv_verify pattern); FLST membership; reward SPEL/MGEF readback;
    substrate slots non-empty; route entries; balance invariants (≤2 boon families, broad<focused,
    no double anti-farm, tier magnitude ceiling, creed-loss medium/major)
```

---

## Worked example: Khajiit (Phase 1 pilot)

```
Race: Khajiit
Foreground patron(s): Azurah, Khenarthi, Baan Dar (exists), Rajhin, Alkosh
  — scripted PDV_Deity_*, added to PDV_FLST_AllDeities, Stance_Khajiit=NATIVE, unique DeityIndex
Gate type: no-offer (silent emergent emphasis; reward gates on substrate tier + focused-emphasis state)

Piety-feeding acts (double-route: feed substrate metric AND small piety pulse ~0.3-0.5 to emphasis deity):
  - Moon observance   -> ROUTE_KHAJIIT_MOON_OBSERVANCE -> HandleKhajiitMoonObservance -> Azurah pulse
  - Road-home anchor  -> ROUTE_KHAJIIT_ROAD_HOME        -> HandleKhajiitRoadHomeAnchor -> Khenarthi pulse
  - Baan Dar road trick / Rajhin elegant theft / Alkosh dragon order -> RecordKhajiitFocusSignal -> matching deity pulse
      anti-farm: ScoreRepeatableAction owns the piety pulse cap; ConsumeDailyRepeatMultiplier stays on the substrate magnitude only
Creed-violation loss acts (medium/major):
  - Azurah desecration / shadow-drift (-2.5); Rajhin botched/innocent-kill theft (-2.0);
    Alkosh chaos / dragon-cult aid (-3.0); Khenarthi caravan-harm (-2.0); Baan Dar betrayal (-2.0)
Rejected hooks: generic crime, generic combat, repeating one bed, fast-travel loops, generic inn sleep, moon-sugar, manual focus selection

Substrate / identity:
  - Lunar substrate metric -> tier -> Substrate_Khajiit_Always/Mid/High (very low power identity boons)
  - Identity state: PDV_GLO_KhajiitFocusedEmphasis (None/Khenarthi/Azurah/BaanDar/Rajhin/Alkosh); PDV_State_KhajiitLunarPosture

Rewards:
  - Broad lunar: T1 (exists, night stamina/disease) + T2 (capped Faithful, +signature)
  - Per-emphasis 3-tier: Khenarthi/Azurah/BaanDar/Rajhin/Alkosh each T1/T2/T3 (Nord-shape themes)
  - Stack cap: one active emphasis set; suppress broad T2 when emphasis focused

Neglect: PDV_SPEL_Neglect_KhajiitLunar (gentle thinning when lunar metric flat/below floor); bite at posture Corrupted/ShadowDrift

Surfacing: emphasis shift toast (SendPrismaShiftToast, exists); Survey lunar/emphasis line; reward effect descriptions

Verifier: 4 deity base-data blocks; FLST membership; broad+emphasis SPEL/MGEF readback; substrate slots non-empty;
  anti-creed route entries; balance invariants
```
