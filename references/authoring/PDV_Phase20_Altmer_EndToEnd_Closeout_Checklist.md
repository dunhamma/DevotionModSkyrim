# PDV Phase 20 Altmer End-to-End Closeout Checklist

**Created:** 2026-06-05
**Status:** First single-race end-to-end pre-beta closeout walkthrough
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceScalingSpine.md`, `PDV_PreBetaRaceAcceptanceRubric.md`, `PDV_Phase20_PreBetaManualChecks_Runbook.md`, `PDV_Phase20_QASmokeRuntimeProof_Runbook.md`, and `PDV_Phase20_NoInGameProof_Gates.json`

## Why this file exists

Altmer is the P0 active spine. No race has yet been driven all the way from
`Fail - runtime/manual proof deferred` to a `Pass` verdict. This checklist runs
Altmer through the **entire** loop once so the per-race cost stops being a
guess. The most important output is not just the `Pass` verdict — it is the
**wall-clock time** each step actually took, recorded in the Time Log at the
bottom, so the remaining races can be scheduled against a real number.

Distinction this checklist enforces:

- **Positive route proof** (Step C) is the quick QASmoke test you already run.
- **Final-world placement** (Step B) is CK/Codex *authoring*, not testing, and
  is the real time cost.
- **Negative / rejected-hook sweep** (Step D) and the **feel call** (Step G)
  are the new *kind* of test: play normally, confirm silence, judge feel.

## Altmer reference facts (from the locked manifests)

- Accepted hooks / route IDs: Lorkhan pressure `50`, Dragonborn declaration
  `51`, dawn steadiness `52`, orthodox costly enforcement `53`.
- QASmoke proof references (2026-05-31 placement): `071020`, `07101F`,
  `071021`, `071022`. Confirm live labels with
  `node .\tools\pdv_phase20_runtime_check.mjs --list`.
- Final-world placement contract (two surfaces required):
  - `PDV_REFR_AltmerDawnStudyWorldSignal` — **positive**, scholarship / Auri-El
    practice / dawn-facing study context. Mirrors QASmoke
    `PDV_REFR_AltmerDawnSteadinessSignal`.
  - `PDV_REFR_AltmerCrisisPressureWorldSignal` — **pressure-recovery**, authored
    crisis / Lorkhan / mortal-continuity context. Mirrors QASmoke
    `PDV_REFR_AltmerLorkhanPressureSignal`.
- Content-lock guardrail: `MarriageBeat` reads as **Marriage / Mortal
  Continuity** (household, lineage, embodied attachment, continuity inside
  Lorkhan's mortal world), **not** anti-Mara marriage rejection. Talos/Thalmor
  is not in the current four-row crisis list.
- Expected build: Auri-El or Magnus scholar managing dawn practice and study.
- Edge build: Exiled vampire, werewolf halt, or mortal-world pressure run.

---

## Step 0 — Preflight gates (automated, must be green first)

Run from the project root. Do **not** launch Skyrim until these pass.

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
```

Expected baseline ~`PASS=1985, WARN=1, INFO=28` (one known unnamed CK INFO).
If any gate fails, fix readback first — do not test on a red gate.

- [ ] Content verify clean
- [ ] Strict Altmer + race-costing verifier clean
- [ ] Runtime checker lists Altmer routes `50-53`
- [ ] QASmoke placement check passes

---

## Step A — Decide the two real-world placement objects (design, no CK yet)

The `manualStopCondition` in the gates JSON forbids placing until the exact CK
object/location is chosen and culturally specific.

- [ ] **Positive surface** — pick the concrete object + cell for
  `PDV_REFR_AltmerDawnStudyWorldSignal`. Candidate contexts: a College of
  Winterhold study/Arcanaeum surface, an Auri-El / dawn-facing shrine or study
  object. Must be reachable in ordinary scholar play.
- [ ] **Pressure surface** — pick the concrete object + cell for
  `PDV_REFR_AltmerCrisisPressureWorldSignal`. Must come from an authored
  crisis / Lorkhan / mortal-continuity beat, **not** a generic Skyrim object a
  non-Altmer would trip.
- [ ] Confirm neither location turns a rejected generic hook (travel, sleep,
  generic spellcasting, College membership) into a scoring surface.

Record both chosen object EditorIDs + cells here before authoring:

```text
Positive object/cell:
Pressure object/cell:
```

---

## Step B — Author the final-world placement (CK/Codex authoring — the real cost)

- [ ] Back up `PlayerDevotion_Framework.esp` (timestamped, per existing helper
  convention).
- [ ] Create `PDV_REFR_AltmerDawnStudyWorldSignal` pointing at the chosen
  positive base, in the chosen cell, wired to the same EventBus route as the
  QASmoke dawn-steadiness proof (`52`).
- [ ] Create `PDV_REFR_AltmerCrisisPressureWorldSignal` pointing at the chosen
  pressure base/context, wired to the Lorkhan-pressure route (`50`).
- [ ] Refresh SEQ after the ESP write.
- [ ] Re-run Step 0 gates; confirm still green with the two new references.
- [ ] Update `PDV_Phase20_NoInGameProof_Gates.json` placement entries from
  `plan` toward authored, and note the backup path in the gate ledger.

---

## Step C — Positive runtime proof (the quick test you already do)

Archive the old Papyrus log first, then in-game:

```text
set PDV_GLO_DebugLevel to 2
```

- [ ] Fresh **Altmer** save (expected build: Auri-El/Magnus scholar).
- [ ] Activate the **real** dawn/study surface in its world location (not
  QASmoke). Confirm route `52` fires in the log and a dawn-steadiness favor is
  recorded.
- [ ] Trigger the **real** crisis/pressure surface. Confirm route `50` fires
  and crisis/Lorkhan state moves.
- [ ] `node .\tools\pdv_phase20_runtime_check.mjs --race altmer` passes.
- [ ] `node .\tools\pdv_phase20_runtime_check.mjs --race altmer --strict-manager`
  passes.

---

## Step D — Negative / rejected-hook sweep (the NEW test — play normally)

Play the Altmer normally for a short stretch and confirm each of these stays
**silent**: no scoring, no hidden counter movement, no misleading Survey text.

- [ ] Ordinary travel between holds
- [ ] Ordinary sleep / waiting
- [ ] Generic spellcasting (raw magic use)
- [ ] Generic combat / kills
- [ ] Generic helping / ordinary friendships
- [ ] Joining / being in the College of Winterhold
- [ ] Generic anti-Thalmor violence
- [ ] **Repeated** Dragonborn identity beats (route `51` must not re-fire as a
  faucet after the first declaration)
- [ ] **Wrong-origin check:** repeat one accepted hook on a **non-Altmer**
  save — confirm it is silent except debug rejection.

If any ordinary action fires a reward, that is an anti-farm failure → tune the
gate in `PDV__ManagerQuest`, recompile, re-test. Note it in the Issues Log.

---

## Step E — Survey / status legibility

- [ ] Cast Survey Devotion (or open MCM Player page) after a **real** accepted
  hook.
- [ ] Confirm the text reads as Altmer coherence in fiction terms: dawn
  discipline, study, crisis, pressure, recovery/scar, alignment posture.
- [ ] Confirm `MarriageBeat` surfaces as **Marriage / Mortal Continuity**, not
  as anti-Mara language.
- [ ] Confirm **no** route IDs, raw favor counters, or "debug" labels appear in
  player-facing copy.

---

## Step F — Edge build (Exiled vampire / werewolf halt)

- [ ] On an Exiled vampire Altmer, confirm the curse state surfaces as **capped
  or halted**, not as a stronger alternate build.
- [ ] On a werewolf Altmer, confirm the hard-halt message path fires.
- [ ] Confirm cured-vampire **scar** recognition surfaces.

---

## Step G — Stack snapshot + feel call (the subjective judgment)

- [ ] Record everything active at once: Auri-El foundation, secondary focus,
  active favor, crisis state, pressure count/source, ThalmorAlignment, vampire
  exile / werewolf halt / scar, any Daedric modifier.
- [ ] **Reward floor:** confirm coherent dawn/study play trends net-positive
  without perfect play.
- [ ] **Reward ceiling:** confirm Auri-El + one secondary focus + one active
  favor does not over-stack; ThalmorAlignment modifies access/pressure rather
  than acting as a third boon engine.
- [ ] **Feel call:** can you say *why* the crisis or favor happened, *why*
  ordinary life stayed silent, and whether recovery felt possible? Does it read
  as authored religion, not homework?

If reward balance feels off → adjust magnitudes, recompile, repeat from Step C.
**Count each tuning pass in the Time Log** — that iteration count is the number
that decides the project-wide beta date.

---

## Step H — Record the verdict

- [ ] Update the Altmer block in `PDV_PreBetaRaceGateLedger.md` to `Pass`,
  `Conditional` (with the one named condition), or keep `Fail` with the
  blocking item.
- [ ] Update the matching slots in `PDV_Phase20_ManualEvidenceLedger.json` with
  real proof notes (only after the checks were actually run).
- [ ] If `Pass`: Altmer is cleared for external playfeel testing.

---

## Time Log (the actual deliverable)

Fill wall-clock minutes per step. This is the data point that converts the
July / August / September beta-feel spread into a real date.

```text
Step A (choose placement):        ____ min
Step B (author placement, CK):    ____ min
Step C (positive runtime proof):  ____ min
Step D (negative sweep):          ____ min
Step E (Survey legibility):       ____ min
Step F (edge build):              ____ min
Step G (stack + feel):            ____ min
Tuning passes needed:             ____ (count)   total ____ min
------------------------------------------------
TOTAL Altmer closeout:            ____ min / ____ hrs
```

## Issues Log

```text
(record anything that fired when it shouldn't, any copy that read as debug,
any reward that felt too loud, and how it was fixed)
```
