# Divine Debt -- Feasibility Assessment

**Status:** Traced to **live** source only
(`D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`). **No Creation Kit and
no Skyrim runtime were available** -- this is NOT QASmoke/in-game proof. Each
sub-mechanism ends with the specific in-CK/in-game proof STILL REQUIRED. Function
**names** are the contract; line numbers drift (`PDV__ManagerQuest.psc` ~10,197 lines,
re-edited 2026-06-10, `.bak_v2b_20260610`).

This matches the honesty bar of `references/research/living-deities/03_feasibility.md`.

---

## Grounding constants (live)

| Constant | Live value | Source |
|---|---|---|
| `PIETY_DAILY_MAX_DELTA` | 4.3 | `PDV__ManagerQuest.psc` (cited `:313` in 03_feasibility) |
| `GAIN_RATE_SCALE` | 1.32 | same |
| Daedric tiers (Seeker/Devoted/Champion) | 25 / 50 / 85 | `PDV_DeityBase` thresholds |
| `PIETY_MAX` (Daedric path) | 200.0 | `PDV_DaedricPathBase.psc:19` |

Anchor every debt tunable to these; never invent a free-floating constant (see
`02_architecture.md`).

---

## The two existing axes debt must NOT duplicate (verified live)

- **Piety:** `PDV_DaedricPathBase.GetStoredPiety/SetStoredPiety/AdjustStoredPiety`
  read/write `PDV.Piety` on the path form, clamped `[0, PIETY_MAX]`. Tier from
  `ComputeTierFromStoredPiety`. The dawn loop `RunDawnConsolidateScratch()` consolidates
  `PDV.PietyToday` -> `PDV.Piety` for `PDV_FLST_AllDeities` members only.
- **Stigma:** `PDV_DaedricPathBase.GetStigma/AddStigma` read/write
  `PDV.Daedric.Stigma` on the path form (or a mirror `StigmaGlobal`). Race-scaled by
  `GetStigmaModifierForRace`. Surfaced via `MaybeEmitHircineStigmaPrice` at thresholds
  3.0/6.0.

Debt's namespace (`PDV.Debt.*`) and accrual triggers are disjoint from both. Confirmed:
no `PDV.Debt` key exists in live source (greppable as a proof item once building).

---

## Sub-mechanism 1 -- ACCRUE

**Two accrual shapes, both grounded:**

- **(a) Bargain-loan accrual (Clavicus):** debt is added at the moment a favor is
  granted. The live grant points are tier boon swaps (`PDV_DeityBase.SyncPatronBoonsToTier`
  / Daedric `SyncDaedricContractToTier` in `PDV_DaedricPathBase.psc:262`) and clutch
  interventions (`PDV_T3DailyLowHealthSaveEffect.psc` -> `TryApplyDailySave`). A debt
  hook fires alongside the favor: `AddDebt(amount, reason)` on the path form.
  - **Confidence: HIGH.** These grant points are concrete live functions. The hook is a
    one-line addition at each grant site -- recomposition, not greenfield.
- **(b) Passive-draw accrual (Nocturnal -- the Sims need-decay seed):** debt rises a
  small amount each dawn while the path is OPEN (committed), modeling luck quietly
  borrowed even when idle. The natural host is a NEW dawn sub-phase iterating
  `PDV_FLST_DaedricPaths_All` (live FormList, `PDV__ManagerQuest.psc:36`), mirroring
  `RunDawnConsolidateScratch`'s loop shape.
  - **Confidence: HIGH** for the loop (the path roster + per-form StorageUtil pattern
    are live and proven); **MEDIUM** that "passive draw while idle" feels right without
    becoming nag -- a tuning/runtime question.

**Recomposition vs greenfield:** mostly recomposition. New = the `AddDebt` helper + the
passive-draw dawn sub-phase + a per-Prince "uses debt" flag/row.
**Proof still required:** (1) debt rises exactly once per grant (no double-count if a
boon re-syncs on an unrelated tier recompute -- `SyncDaedricContractToTier` is called
from `RecomputeStoredTier` even on no-change, so the loan hook must NOT live inside the
unconditional sync; bind it to the *grant event*, not the sync); (2) passive draw fires
once per dawn and persists across save/load.

---

## Sub-mechanism 2 -- TRACK

**Namespace:** `PDV.Debt.<deityForm>.{Total, LastAccrue, DueAt, LoanCount, Defaulted}`
on the path form, exactly parallel to the live `PDV.Daedric.*` and `PDV.Commitment.*`
patterns (`PDV__ManagerQuest.psc:6594` `RecordCommitmentSignalDay` is the template:
encoded-day Int keys, window checks via `IsEncodedDayWithinWindow`).

- **Confidence: HIGH.** This is the single most proven pattern in PDV -- per-form
  StorageUtil floats/ints with a debug-reset companion (cf. `ResetDaedricForDebug`).
- **Recomposition vs greenfield:** new namespace, but identical mechanics to shipping
  code. No new StorageUtil capability needed.
- **Honest cost:** one new namespace; a `GetDebt/AddDebt/SetDebt` helper trio on
  `PDV_DaedricPathBase` (mirrors `GetStigma/AddStigma`); a mirror GlobalVariable ONLY if
  a CK Condition must read debt (mirror `StigmaGlobal` pattern) -- defer unless a
  dialogue/shrine condition genuinely needs it.
- **Proof still required:** `PDV.Debt.*` survives save/load; debug-reset zeroes it;
  no collision with `PDV.Daedric.*` keys (distinct prefix, greppable).

---

## Sub-mechanism 3 -- REPAY

**Repayment is a scored act that subtracts debt instead of adding piety.** The live
routing already exists: `RouteActionToOpenPaths(eventType, actorRef, targetRef)`
(`PDV__ManagerQuest.psc:3425`) fans a scored act over OPEN paths and calls
`ScorePrinceAction` -> `ScoreRepeatableAction` (`PDV_DeityBase.psc:283`) for anti-farm
(daily cap + cooldown via the `PDV.PLD.*` table).

- **Cheapest path:** author a small set of **sacrifice/offering eventTypes** (e.g. a
  shadow-offering act for Nocturnal, a bargain-fulfilment deed for Clavicus). When one
  fires for an OPEN debt-flagged path, route it to a NEW `ScoreRepayment(eventType)`
  branch that returns a *negative-to-debt* delta (consumes debt) rather than a
  positive-to-piety delta. Anti-farm reuses `ScoreRepeatableAction` unchanged.
- **Confidence: MEDIUM.** The routing fabric, anti-farm, and the OPEN-path gate are
  HIGH-confidence live. The MEDIUM is the same lesson as 03_feasibility Spike 3: **there
  is no string `act_tag` in the award path.** Repayment acts must bind to a concrete
  signal layer -- a specific `Int eventType` (faucet) and/or a quest-stage via
  `ApplyQuestReaction(Quest, Int)` (`:816`). A "sacrifice" must name its eventType(s);
  it cannot be a free-text label.
- **Recomposition vs greenfield:** routing = recomposition; the `ScoreRepayment` branch
  + the offering eventType authoring + the `PDV_DebtRepayTable.csv` (see arch doc) are new.
- **Proof still required:** (1) a sacrifice act lowers `PDV.Debt.Total` and does NOT
  also raise piety unless authored to do both; (2) anti-farm prevents a single offering
  being spammed to zero debt instantly; (3) over-repayment floors at 0 (no negative
  debt = no "the Prince owes YOU" inversion in P1).

---

## Sub-mechanism 4 -- DEFAULT CONSEQUENCE

**"Comes due" -- checked at dawn.** When `PDV.Debt.Total` sits above a threshold past
its `DueAt` grace window, an escalating consequence fires. The live escalation
vocabulary is the **price-spell swap** (`SyncDaedricContractToTier` adds
`Price_Seeker/Devoted/Champion` spells) plus the **Daedric toast channel**
`SendPrismaDaedricToast(princeName, phase, context, symbolName)`
(`PDV__ManagerQuest.psc:6892`, used live by `MaybeEmitHircineStigmaPrice`).

- **Cheapest path:** in the new debt dawn sub-phase, after aging, evaluate a 3-step
  escalation (warning toast -> a "collector's mark" price spell / debuff -> a Marked
  default event that, e.g., suspends boons until repaid). Each step reuses the live
  toast + price-spell swap; no new dispatch system.
- **Confidence: MEDIUM-HIGH.** Toast + price-spell swap are HIGH-confidence live seams.
  MEDIUM on whether suspend-boons-on-default is the right teeth without a new spell
  record per Prince -- that authoring is real cost.
- **Recomposition vs greenfield:** dawn check + toast + escalation steps = recomposition
  of the stigma-threshold pattern; new = the default-event spell record(s) +
  `PDV.Debt.Defaulted` state + the suspend-boon gate inside the existing boon sync.
- **Proof still required:** (1) default fires once per crossing, not per dawn (mirror
  the `stigmaBefore < X && stigmaAfter >= X` edge guard in `MaybeEmitHircineStigmaPrice`);
  (2) repaying below threshold clears the default and restores boons; (3) default state
  persists across save/load; (4) un-flagged Princes never trigger it.

---

## Feasibility verdict

| Sub-mechanism | Live precedent | Confidence | Greenfield? |
|---|---|:-:|:-:|
| Accrue (loan, Clavicus) | grant sites: `SyncDaedricContractToTier`, `TryApplyDailySave` | HIGH | `AddDebt` hook + per-Prince flag |
| Accrue (passive draw, Nocturnal) | `RunDawnConsolidateScratch` loop over `PDV_FLST_DaedricPaths_All` | HIGH (loop) / MED (feel) | new dawn sub-phase |
| Track | `PDV.Daedric.*` / `PDV.Commitment.*` per-form StorageUtil | HIGH | new `PDV.Debt.*` namespace |
| Repay | `RouteActionToOpenPaths` -> `ScoreRepeatableAction` | MEDIUM | `ScoreRepayment` branch + offering eventTypes + CSV; **no act_tag seam** |
| Default consequence | `SendPrismaDaedricToast`, price-spell swap, stigma-threshold edge guard | MED-HIGH | default-event spell record(s) + suspend-boon gate |

**Conclusion:** Divine debt is **buildable as a third axis** largely by recomposition
of the live Daedric-path machinery. The honest new costs are: one `PDV.Debt.*`
namespace, an `AddDebt/GetDebt/SetDebt` helper trio, one new dawn sub-phase
(`RunDawnProcessDivineDebt`), a `ScoreRepayment` branch, an offering/repayment CSV, a
per-Prince "uses debt" flag, and at least one default-event spell record per pilot
Prince. The one carried-over trap from the living-deities work is the **no-act_tag
seam**: repayment acts must bind to concrete `Int eventType` / quest-stage signals, not
free-text. All remaining unknowns are runtime-verification items (fire-once,
persistence, anti-farm, feel) appropriate for a future in-CK/in-game proof session. No
in-game proof exists today.
