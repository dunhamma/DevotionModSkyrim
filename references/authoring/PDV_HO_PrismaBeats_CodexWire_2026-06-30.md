# PDV Codex Handoff -- Prisma authoring-beat wires + parity-queue reconciliation

**Created:** 2026-06-30
**From:** Claude authoring pass (`references/authoring/PDV_PrismaAuthoringBeats_Copy.md`, owner-approved)
**For:** Codex (coding lane)
**Serialize:** ALL of Part A touches `PDV__ManagerQuest.psc` / `PDV_DaedricPath_Hircine.psc`. Run as
ONE manager-owning lane per `PDV_PrismaParity_SerializedHandoffs.md`; do not interleave with other
manager edits. The live `PDV__ManagerQuest.psc` is untracked -- snapshot before editing.

> **Source-of-truth note:** all line numbers are from `live-source\Scripts\Source\`. `pdv_compile`
> reads the MO2 copy, which DRIFTS from live-source. **Before wiring, sync/confirm live-source ->
> MO2** or you may edit a file that is not the one that compiles. See Part B step 0.

---

## HEADLINE FINDING (read first)

The Prisma-parity worklist (`PDV_PrismaParity_DecidedWorklist.md`, 06-25) and the consolidation
handoff (`PDV_HO_PrismaToOneOh_2026-06-30.md`) are **largely stale against live-source.** A build
wave shipped most of both the Group-1 coding queue and the Group-2 authoring beats. Re-grepping
live-source: **6 of 10 authoring beats and ALL 10 Group-1 coding items already exist** with
finished code/copy (verified 2026-06-30/07-01, cites in Part B). The genuinely-open work is small
(Part A below). Part B is **pure drift reconciliation**, zero fresh coding.

Do NOT wire from the worklist blindly -- verify each item against live-source first. Evidence tables
are in both this doc and the copy doc.

---

# PART A -- Authoring-beat wires (owner-approved copy)

Exact strings are locked. Public-facing name helper = `GetPublicDeityDisplayName(deity)`; deity
symbol helper = `GetPrismaSymbolForDeity(deity)`. All ASCII (the `.psc` hook enforces it).

**Shared-handler note (no trap):** `ShowFormalCommitmentOffer` (the real in-game offer) calls
`DebugAcceptPendingCommitment()` / `DebugRefusePendingCommitment()` by button index
(`PDV__ManagerQuest.psc:13215`). Wiring surfacing inside those two functions covers BOTH the
MCM-debug path and normal play. No separate handler to touch.

### A1 -- Nord (all-race) offer ACCEPT  [P1, GENUINE GAP -- confirmed absent]

- **Site:** `DebugAcceptPendingCommitment()` -- `PDV__ManagerQuest.psc:13353`. Insert after
  `SetActiveDeity(pendingDeity)`, before `ClearPendingCommitment()`.
- **Wire (chronicle, reuses existing race-aware line):**
  ```
  DispatchDiegeticCue("offer", pendingDeity.DeityName, "accept", pendingDeity, "revelation")
  ```
  This fires `SurfaceTransition("offer","accept",headline=true)` -> pinned BoD via the existing
  `BuildCommitmentOfferAcceptJournalLine` (Nord/Dunmer/Altmer/Redguard branches already authored)
  + the director cue. No new chronicle copy needed.
- **Wire (explicit toast, NEW approved copy):**
  ```
  SendPrismaShiftToast("You have given your devotion to " + GetPublicDeityDisplayName(pendingDeity) + ".", \
      GetPublicDeityDisplayName(pendingDeity) + " takes you as their own.", GetPrismaSymbolForDeity(pendingDeity))
  ```
- **Note:** carryover already routes through `AwardPiety(pendingDeity, carryAmount,
  "commitment_carryover")` -- the worklist's "reason-bearing award" sub-item is DONE; do not re-add.
- **If** the director cue alone already shows a toast, the explicit toast is redundant but harmless;
  keep it so the accept is as prominent as the worklist intends.

### A2 -- Hircine renunciation  [P1, GENUINE GAP -- confirmed absent]

- **Site:** `RenouncePath(reason)` -- `PDV_DaedricPath_Hircine.psc:114`. Insert after
  `ShowIfPresent(Msg_Exit)`.
- **Routing:** the Hircine path script should NOT own Prisma calls directly (mirror how onset
  toasts route through the manager seam). Add a small manager-side renounce-surface function and
  call it from `RenouncePath`, OR emit at the manager-level renounce caller.
- **Chronicle (NEW approved copy):** tone `reorientation`, pinned, magnitude 3, symbol `hircine`:
  ```
  AppendBookOfDaysEntry("You set the hunt down. The pact with Hircine is renounced -- the beast's mark fades slowly, but the road back is yours to walk.", \
      Utility.GetCurrentGameTime() as Int, "reorientation", "hircine", True, 3)
  ```
- **Toast (NEW approved copy):** distinct from the later residue toast:
  ```
  SendPrismaShiftToast("You renounce the hunt.", "Hircine's pact is set down.", "hircine")
  ```

### A3 -- Redguard sect Champion-entry toast  [APPROVED -- chronicle/modal already present]

- **Site:** `MaybeShowRedguardChampionEntry(sectValue)` -- `PDV__ManagerQuest.psc:7157`. In each
  sect branch, add the toast alongside the existing `ShowRedguardMessage(...)` + `AppendBookOfDaysEntry(...)`.
- **Toasts (NEW approved copy), symbol `sect`:**
  - Crown: `SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")`
  - Forebear: `SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")`
  - Ash'abah: `SendPrismaShiftToast("The Ash'abah duty, made public.", "More than necessity now -- a public shape of your devotion.", "sect")`

### A4 -- Altmer alignment chronicle reword  [APPROVED polish -- edit existing line]

- **Site:** `BuildReorientationJournalLine` Altmer branch -- `PDV__ManagerQuest.psc:2031`.
- **Change:** replace
  `"Your soul records where you stand in the Thalmor question: " + surfaceKey + "."`
  with
  `"Where you stand in the Thalmor question shifts: " + surfaceKey + "."`

### A5 -- Nord refuse toast  [CONDITIONAL -- only if director cue is silent]

- **First verify:** does `DispatchDiegeticCue("offer", ..., "refuse", ...)` (already wired in
  `DebugRefusePendingCommitment`, `:13557`) produce a visible TOAST, or only the pinned chronicle?
- **If toast already fires:** do nothing (copy is complete).
- **If silent:** add, for parity with A1, symbol = `GetPrismaSymbolForDeity(pendingDeity)`:
  ```
  SendPrismaShiftToast("You turn " + GetPublicDeityDisplayName(pendingDeity) + " away.", \
      GetPublicDeityDisplayName(pendingDeity) + " will not ask again.", GetPrismaSymbolForDeity(pendingDeity))
  ```

### NOT in scope -- deferred to V2

- **Beat 5 (per-race bespoke werewolf-onset chronicle):** owner-deferred. Keep the generic line.
  Requires threading curse type into `ResolveJournalLine`, then a per-race line set -- all races or
  none. Filed: `PDV_V2_Backlog.md` section 5. Do NOT wire for 1.0.

---

# PART B -- The "other items" (Group-1 parity coding queue) -- RECONCILE, don't re-wire

These are the worklist's Group-1 coding items. **All 10 are already present in live-source** (grep
evidence below). Your task is reconciliation only: confirm deployed == live-source; deploy if
behind. Nothing here needs to be written.

### Step 0 -- drift reconciliation (do this first)

Confirm whether the **deployed MO2 copy** of `PDV__ManagerQuest.psc` matches `live-source`. If
live-source is ahead (likely), the "open" items below may already be in live-source and merely need
deploying. Diff the two copies before deciding any item is open.

### Evidence table (live-source greps, 2026-06-30)

| # | Worklist item | Worklist cite | Live-source evidence | Likely state |
|---|---|---|---|---|
| 1 | Rivalry-drain Ledger reason | `AwardPietyInternal` `:17721` | `AwardPietyInternal(rivalDeity, rivalAmount, False, "rivalry with " + sourceDeity.DeityName)` at `:19206` -- reason present | **DONE** |
| 2 | Khajiit lunar-posture chronicle | `:5342` | `RefreshKhajiitLunarPosture` appends BoD for Corrupted (`:5755`) and ShadowDrift (`:5757`), tone `curse.onset` | **DONE** |
| 3 | emergence.onset wire (BLOCKING) | Khajiit + Breton callsites | `SurfaceTransition("emergence",...,"onset",...)` present at `:7293` (Khajiit) and `:15134` (Breton); `GetBretonTraditionDeity` exists | **DONE** |
| 4 | substrate.thin branch | `SendPrismaSubstrateProgress` | `SendPrismaSubstrateToast(...,"thin",...)` at `:13925` | **DONE** |
| 5 | Hircine residue onset/fade | `PDV_DaedricPath_Hircine.psc:168` | `SendPrismaDaedricToast("Hircine","residue",...)` at manager `:13953`/`:13957` | **DONE** |
| 6 | Daedric boon "rite answered" | rite-completion | `SendPrismaDaedricToast(prince,"boon",...)` at `:14079` | **DONE** |
| 7 | Khajiit Champion pin (`headline=true`) | `:10637` | `SurfaceTransition("tier", deity.DeityName + " " + GetTierStandingLabel(TIER_CHAMPION), "reach", ..., false, true)` at `:11575` -- headline=true + band suffix | **DONE** |
| 8 | Orc lapse-to-City toast | route `:5904` via `ApplyOrcLifeModeSwitch` | dawn lapse routes `ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")` at `:6327` (surfaces chronicle + toast) | **DONE** |
| 9 | New-pact Daedric toast | `:2896` | `SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", ...)` at `:3167` | **DONE** |
| 10 | Altmer crisis-state toast | `:7417` | `SendPrismaShiftToast("The old line turns: " + GetAltmerCrisisStateLabelForValue(...), ...)` at `:7874` | **DONE** |
| R | RETIRE drift.warn dead branch | `:1773-1774` + tones | NO `drift.warn` / `eventClass == "drift"` / `SurfaceTransition("drift")` matches anywhere | **already RETIRED** |
| -- | 6f overlay toast | DECLINED per R1 | n/a | no action |

**RESULT: every Group-1 item is already implemented in live-source** (all 10 wires DONE +
drift.warn already retired). Part B has **zero fresh coding** -- it is purely the Step-0 drift
reconciliation: diff the deployed MO2 `PDV__ManagerQuest.psc` against live-source and deploy if the
MO2 copy is behind. If the deployed copy already matches live-source, Part B is fully closed.

### emergence.onset direction-token note (only if #3 is genuinely incomplete)

The worklist flags a `reach` vs `onset` direction mismatch: the formal-offer gate snippet
(`tools/pdv_formal_offer_check.mjs` `quietEmergenceSnippets`) keyed `emergence.reach`, but the
authored tone arms use `emergence.onset`. Live-source emits `"onset"`. If the gate is still RED,
fix the GATE to expect `"onset"` (the callsites already emit it) rather than re-emitting `"reach"`.
Verify the journal line renders non-empty after.

---

## Verify (after each slice)

1. `node tools/pdv_compile.mjs --script PDV__ManagerQuest` -> 0/0 (and `PDV_DaedricPath_Hircine`).
2. `node tools/pdv_prisma_ui_audit.mjs` -> still PASS (47 checks).
3. `node tools/pdv_verify.mjs` -> FAIL=0.
4. `node tools/pdv_integrity_harness.mjs` -> PASS.
5. Ledger acceptance: every newly-surfaced beat records a driver so it lands in the Ledger
   ("Ledger monitors all data points").
6. FELT proof is in-game (toast fires, chronicle entry appears, Ledger shows the driver) --
   play-gated; test the offer accept/refuse via the debug MCM page, not `cqf`.

## Dispatch advice

- **Serialize** Part A as one manager lane (A1-A5 are independent edits but all touch the same two
  high-contention files).
- Part B step 0 (drift reconciliation) **gates** the rest of Part B and de-risks Part A too -- do it
  first.
- A1, A2, A3 are independent and can land in any order. A4 is a one-line edit. A5 is conditional on
  the A5 verify.
