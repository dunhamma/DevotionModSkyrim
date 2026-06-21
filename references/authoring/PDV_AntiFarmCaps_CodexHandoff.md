# Codex Handoff — Anti-Farm Pulse Caps (1C)

**Owner:** Codex (live Papyrus). **Author of this spec:** Claude.
**Batch:** 1C. **Implement:** before in-game Sessions B (faucet/anti-farm) and D
(per-race runbooks), so pacing is tested with caps in place. **Files:**
`PDV__ManagerQuest.psc` (all line refs below), `PDV_ActionRouter.psc` (none —
router only fans out). **Source:** the ESP/anti-farm coverage audit, 2026-06-21.

## The finding

`AwardPiety` / `AwardPietyInternal` (`:1129/:7847`) has **no daily piety
ceiling** — `RunGainPipeline` (`:7970`) applies only multiplicative gain
modifiers. The dawn consolidation clamps each deity's day to ±`PIETY_DAILY_MAX_DELTA`
(4.3) — so this is **not an overflow exploit** (the clamp backstops it) — but
**any single repeatable act can trivially cap a deity in one sitting**, which
breaks the "cap requires varied practice" pacing model. So this is a
**pacing-quality** pass: every repeatable POSITIVE pulse should diminish on
same-day repeats.

The comment idiom in some handlers ("the pulse anti-farm is the AwardPiety
daily-max path", e.g. `:4540`) is **false** — there is no daily-max in the award
path. Do not trust it.

## Canonical pattern (the template every fix follows)

`HandleHoonDingBreakthroughKill` (`:5459`) is correct:
```papyrus
Float multiplier = ConsumeDailyRepeatMultiplier(repeatKey)   ; 0.7^n same-day
if multiplier <= 0.0
    return
endIf
AwardCuratedSignalScaled(deity, signal, victimForm, multiplier)
```
`HandleHircineHuntRite` (`:5762`) and the Dunmer ancestor-memory hard-day-key
path (`AwardActiveDunmerReclamationMemorySignal :12204`) are the other accepted
shapes. **Default to soft-decay** (`ConsumeDailyRepeatMultiplier`) to match
precedent, unless the act is a discrete once-a-day rite (then a hard day-key).

## Class A — `substrate-only` (multiplier already in scope; ONE-LINE fix each)

These compute `ConsumeDailyRepeatMultiplier(...)`, scale the **substrate**, then
call an **unscaled** `AwardCuratedSignal`. Fix = route that award through
`AwardCuratedSignalScaled(deity, signal, ref, multiplier)` with the multiplier
already in scope. **Do not** add a second `ConsumeDailyRepeatMultiplier` call
(that would double-consume the day counter).

| Handler | Award line |
|---------|-----------|
| `TryArgonianNearWaterMaintenance` (whole handler also hard-day-key gated — lowest priority) | `:3129/3151` |
| `HandleArgonianHistMaintenance` | `:4528/4542` |
| `HandleArgonianPeopleSupport` | `:4553/4565` |
| `HandleArgonianBedOfChoiceReturn` | `:4573/4585` |
| `HandleArgonianVoidSignal` (Hist + Sithis VOID pulses) | `:4593/4606/4609` |
| `HandleKhajiitMoonObservance` | `:4098/4115` |
| `HandleKhajiitRoadHomeAnchor` / `HandleKhajiitRoadHome` | `:4131/4153` |
| `RecordKhajiitFocusSignal` → `PulseKhajiitFocusPiety` (BaanDar/Rajhin/Alkosh) | `:4229/4262` |
| `HandleKhajiitBaanDarReversal` | `:4213/4224` |
| `HandleKhajiitAlkoshNamedDragon` (relies on named-ActorBase one-shot) | `:4181/4188` |
| `HandleOrcStrongholdForge` | `:4698/4939` |
| `HandleOrcCityDignity` | `:4744/4945` |
| `HandleOrcLegionService` | `:4755/4951` |
| `HandleOrcSelfMadeCommunity` | `:4766/4957` |
| `HandleOrcMalacathConduct` | `:4777/4963` |
| `HandleRedguardCrownTombRespect` | `:5104/5434` |
| `HandleRedguardForebearRoadPassage` | `:5115/5445` |
| `HandleRedguardAshAbahDeathDuty` | `:5126/5502` |
| `HandleRedguardAshAbahMajorBurden` (Unique-gated + mult-bail already) | `:5158` |
| `HandleRedguardFarShoresToken` | `:5342/5508` |
| `TryOrcCodeHolds` (`AwardPiety(Malacath,0.5)` per near-death — near-death so barely farmable; add a day-key, low priority) | `:3741/3771` |

## Class B — `none` (NO cap at all; ADD a key, then route scaled — higher priority)

No `ConsumeDailyRepeatMultiplier`, no day-key on the pulse. Add a per-signal
`repeatKey` + the template (compute multiplier → bail ≤0 → scaled award). Use a
distinct `PDV.Signal.<Name>` key per handler.

| Handler | Award line | Note |
|---------|-----------|------|
| `HandleImperialCivicService` | `:12357/12309` | civic-family pulse |
| `HandleImperialPatronCivicFavor` | `:12400/12333` | patron civic favor |
| `HandleImperialTalosPressure` | `:12377` | Talos defiance |
| `HandleNordOldWaysState`/`KyneTalosContext`/`HircineArkayEdge` → `RouteNordFamily` → `AwardNordRouteFamilySignal` | `:12519/12483` | cap at the shared `AwardNordRouteFamilySignal` sink |
| `HandleBretonKnightlyVow` | `:12034/12045` | |
| `HandleBretonHiddenArtExposure` | `:12055/12067` | |
| `HandleBretonGreenWayStanding` | `:12097/12110` | |
| `HandleAltmerDawnSteadiness` | `:6019/6057` | `TryActivateContextualFavor` gates only the favor SPELL |
| `HandleAltmerOrthodoxCostlyEnforcement` | `:6040/6068` | |
| `HandleTalosShrineDefiance` | `:5788/5790` | |
| `HandleShoutAttack` | `:6237` | only a ~0.86s anti-double debounce — add a daily soft-decay on top |
| `HandleBosmerLivingStorySignal` | `:3855/3862` | |
| `HandleBosmerExchangeSignal` | `:3866/3873` | |
| `HandleBosmerBanditRoadSignal` | `:3879/3886` | |
| `HandleBosmerPactPositiveSignal` | `:3890/3899` | |
| Bosmer OldContract/LivingStory/Exchange/BanditRoad favor handlers via `RecordBosmerFavorSignal` (always returns true; favor-spell gate ≠ pulse gate) | `:3914-3954` | cap each `Handle*Signal` sink — fixing the 4 rows above covers most |

## EXCLUDE — do NOT cap (report only)

- **Negative/anti-creed (uncapped by design — a penalty isn't farmable):**
  `HandleOrcOathBreak` (`:4797`), `HandleAltmerLorkhanPressure`,
  `HandleDunmerDeviationPrice` (`:12115/12229` — already scaled by curse layerWeight),
  the 5 Khajiit anti-creed handlers, `HandleGreenPactViolation`.
- **Already correct (do not touch):** hard-day-key — `HandleImperialMaraSleepMercy`,
  `RunDawnAwardAltmerAuriElDawn`, `TryAwardDunmerTwilightWindowSignal`,
  `AwardActiveDunmerReclamationMemorySignal`, `TryAwardAltmerMagicMilestone`,
  `HandleOrcFourHoldsVisit`, `HandleRedguardAshAbahUndeadSiteClear`,
  `AwardArgonianSacredWater`/`AwardBosmerSong`, `MarkLocationSeen`,
  `HandleBosmerBanditRoadReversal` (7-day cooldown); soft-decay-correct —
  `HandleHoonDingBreakthroughKill`, `HandleHircineHuntRite`.
- **Verify separately (caps live outside these two files):**
  `HandleDaedricShrinePrayer` (+2, relies on the activator's `OncePerDayKey`),
  `HandleDaedricPrinceSignal` (+10, relies on `PDV_DaedricPathBase.AddCommitmentSignal`
  per-source dedup). Confirm those before treating as safe — flag to Claude, don't edit blind.

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_verify.mjs
```
Expect `1 succeeded, 0 failed`, `FAIL=0`. This is one large mechanical pass —
commit in logical groups (Argonian, Khajiit, Orc, Redguard, then the Class-B
race families) so a regression is bisectable. Snapshot + hand back per group or
at the end.

## In-game proof (User — Session B + per-race D)

For a representative spammable act per race: repeat the same act several times in
one day → confirm the piety pulse **diminishes** (0.7ⁿ) instead of banking full
each time, and that the dawn total still lands at/under 4.3. Negative check:
penalties (oath-break, deviation) still apply full each time. Record in the
manual evidence ledger.
