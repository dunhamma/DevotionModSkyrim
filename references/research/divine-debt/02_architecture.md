# Divine Debt -- Buildable Architecture Spec

**Status:** Spec only. No Papyrus/CK/ESP changes in this dossier. Numbers anchored to
the live pacing model (`PIETY_DAILY_MAX_DELTA = 4.3`, tiers 25/50/85,
`PIETY_MAX = 200`). All seam names verified live; see `01_feasibility.md`.

---

## 1. StorageUtil namespace (per Prince path form)

Parallel to the live `PDV.Daedric.*` namespace on the path form (same form key as
`PDV.Piety` / `PDV.Daedric.Stigma`). Disjoint prefix `PDV.Debt.*`:

| Key | Type | Meaning |
|---|---|---|
| `PDV.Debt.Total` | Float | Outstanding debt, floored at 0, ceiling `DEBT_MAX` |
| `PDV.Debt.LastAccrue` | Float | game-time of last passive draw (dedupe per dawn) |
| `PDV.Debt.LoanCount` | Int | discrete loans taken (Clavicus bargains), for flavor/UI |
| `PDV.Debt.DueAt` | Float | game-time the current grace window ends |
| `PDV.Debt.EscalationStep` | Int | 0 none, 1 warned, 2 marked, 3 defaulted |

Reset companion: extend `ResetDaedricForDebug` to also zero these (or a sibling
`ResetDebtForDebug`). Mirror GlobalVariable ONLY if a CK Condition must read debt --
defer (mirror the optional `StigmaGlobal` pattern; do not add speculatively).

**Per-Prince enable flag (authoring, not runtime drift):** a `Bool Property UsesDivineDebt`
on `PDV_DaedricPathBase` (default `False`), set `True` on Nocturnal + Clavicus path
records via VMAD. Un-flagged paths skip every debt branch. (Heed the memory lesson:
VMAD prop values bake into the save at first init -- if this ships and later flags a new
Prince, existing saves need a runtime version-gated migration, not just an ESP edit.)

---

## 2. New functions and where they slot

**On `PDV_DaedricPathBase.psc` (mirror the `GetStigma/AddStigma` trio):**

```
Bool Property UsesDivineDebt = False Auto
Float Property DebtMax = 100.0 Auto

Float Function GetDebt()
Function AddDebt(Float amount, String reason)        ; floors 0, ceils DebtMax, traces
Function SetDebt(Float amount, String reason)
Float Function ScoreRepayment(Int eventType)         ; mirrors ScorePrinceAction but
                                                      ; reads a PDV.DebtRepay.* table and
                                                      ; returns a POSITIVE consume amount
```

`ScoreRepayment` reuses `ScoreRepeatableAction(eventType, delta, dailyCap, cooldownDays)`
for anti-farm exactly as `ScorePrinceAction` does -- offering acts get a daily cap so
debt cannot be zeroed in one sitting.

**On `PDV__ManagerQuest.psc` (mirror the dawn + routing seams):**

| New function | Slots into | Job |
|---|---|---|
| `RunDawnProcessDivineDebt()` | new line in `ProcessDawn()` AFTER `RunDawnConsolidateScratch()`, BEFORE `RunDawnNotifyNoop()` | iterate `PDV_FLST_DaedricPaths_All`; for OPEN debt-flagged paths: passive draw (Nocturnal), then `EvaluateDebtEscalation` |
| `EvaluateDebtEscalation(path)` | called by the above | edge-guarded escalation (warn/mark/default) using `SendPrismaDaedricToast` + price-spell swap |
| `RouteRepaymentToOpenPaths(eventType,...)` | called from the same dispatch point as `RouteActionToOpenPaths` (`:3425`) | fan a sacrifice act over OPEN debt paths; `AddDebt(-ScoreRepayment(...))` |
| `HookDebtOnFavorGranted(path, Float amount, reason)` | called at grant sites (boon swap, `TryApplyDailySave` clutch) | bargain-loan accrual; `AddDebt(amount, "loan_"+reason)` and `LoanCount += 1` |

**Critical placement (from `01_feasibility.md`):** the loan hook must bind to the
*grant event*, NOT inside `SyncDaedricContractToTier` -- that sync is called
unconditionally from `RecomputeStoredTier` even on no tier change, so a hook there
would double-count. Accrue on the favor's first grant only.

---

## 3. Dawn flow (proposed, showing the insert)

```
ProcessDawn()
  RunDawnConsolidateScratch()      ; live -- piety
  RunDawnProcessDivineDebt()       ; NEW -- passive draw + escalation
  RunDawnRefreshTrackStates()      ; live
  RunDawnApplyDecayNoop()          ; live
  RunDawnApplySpellAndNeglectLayersNoop()  ; live -- boon sync reads PDV.Debt.Defaulted
  RunDawnProcessCommitmentOffersNoop()     ; live
  RunDawnNotifyNoop()              ; live
```

The boon sync already runs in `RunDawnApplySpellAndNeglectLayers`; the suspend-on-default
gate reads `PDV.Debt.EscalationStep == 3` and skips re-granting that path's boons.

---

## 4. Authoring CSV (data-driven, mirrors `PDV.PLD.*` shape)

Two tables, both keyed by Prince path + eventType, generated like
`PDV_DeityLikesDislikes_Princes_V2.csv` -> `tools/pdv_princeld_gen.mjs` -> `WritePLD`.

**`PDV_DebtAccrual.csv`** -- what costs debt to receive:

| prince | accrualMode | perGrantDebt | passivePerDawn | graceDays |
|---|---|---|---|---|
| Nocturnal | passive | 2.0 | 1.0 | 7 |
| Clavicus | loan | 8.0 | 0.0 | 5 |

**`PDV_DebtRepay.csv`** -- offering/sacrifice acts that clear debt (loaded to a
`PDV.DebtRepay.<eventType>.{D,C,O}` table via a `WriteDebtRepay` helper mirroring
`WritePLD`):

| prince | eventType | repayDelta | dailyCap | cooldownDays |
|---|---|---|---|---|
| Nocturnal | <shadow-offering evt> | 6.0 | 1 | 0.5 |
| Clavicus | <bargain-deed evt> | 12.0 | 1 | 1.0 |

eventTypes must be REAL `Int` signals (the 300+ faucet) or quest-stage tags via
`ApplyQuestReaction` -- never free-text (the no-act_tag lesson). Flagging which is a P1
authoring decision (open owner question).

---

## 5. Numeric tunables (anchored, not free-floating)

All expressed relative to live constants so they track future retunes:

| Tunable | Proposed | Anchor / rationale |
|---|---|---|
| `passivePerDawn` (Nocturnal) | ~`0.25 * PIETY_DAILY_MAX_DELTA` (~1.0) | one quarter of a max piety day -- felt but not crushing |
| `perGrantDebt` (Clavicus loan) | ~`2 * PIETY_DAILY_MAX_DELTA` (~8.6) | a bargain costs ~2 good days to repay |
| `DebtMax` | `100.0` | half of `PIETY_MAX` (200); debt is a pressure, not a second 200-deep pool |
| Escalation thresholds | warn `25`, mark `50`, default `85` | reuse the live tier breakpoints 25/50/85 so "debt at Champion-equivalent = default" reads intuitively |
| `repayDelta` | `>= passivePerDawn * graceDays` | one offering must out-pace a full grace window of passive draw, else debt is unpayable |
| `graceDays` | 5--7 | matches the live 7-day commitment-signal window (`HasRecentCommitmentSignalDays`) |

Implement thresholds SYMBOLICALLY (reference the tier breakpoint properties), never as
literals, exactly as 03_feasibility requires for `PIETY_DAILY_MAX_DELTA`.

---

## 6. Verifier / self-test expectations

(For the future toolchain pass; not run in this dossier.)

- **Static:** `PDV.Debt.*` keys grep clean against `PDV.Daedric.*` / `PDV.Commitment.*`
  (no prefix collision). `UsesDivineDebt` present on exactly the flagged Prince records.
  `RunDawnProcessDivineDebt` present in `ProcessDawn` call order.
- **Authoring:** every `PDV_DebtRepay.csv` row's eventType resolves to a real signal
  (faucet eventType or quest-stage tag); no free-text. Every accrual Prince has at least
  one repayment row (a debt with no repay path is a soft-lock -- assert it).
- **Self-test (QASmoke, future runtime):**
  1. Grant a Clavicus boon -> `PDV.Debt.Total` rises by `perGrantDebt` exactly once.
  2. Three dawns idle on open Nocturnal -> debt rises by `3 * passivePerDawn`, once per dawn.
  3. Fire a repayment act -> debt drops by `repayDelta`, floored at 0, anti-farm blocks a
     same-day second fire.
  4. Drive debt past `default` threshold across `graceDays` -> default fires once, boons
     suspend; repay below threshold -> default clears, boons restore.
  5. Un-flagged Prince: no debt keys ever written; behaves as today.
  6. Save/load mid-debt: all `PDV.Debt.*` values and `EscalationStep` persist.

---

## 7. Open implementation decisions (for the owner)

1. Which concrete `Int eventType`(s) / quest stages back the Nocturnal shadow-offering
   and Clavicus bargain-deed repayment acts (the no-act_tag binding)?
2. Default teeth: suspend-boons (proposed) vs a dedicated debuff spell vs a stigma bump.
   Suspend reuses existing machinery; a debuff is a new record per Prince.
3. Does P1 allow debt to go *negative* (Prince owes you) or floor at 0? (Spec floors at 0.)
4. Should Nocturnal passive draw pause while debt is in default, or keep climbing (harsher)?
5. Mirror GlobalVariable for debt now, or defer until a CK Condition needs it?
