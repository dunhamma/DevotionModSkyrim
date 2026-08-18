# PDV 2.0 -- ORIGIN Extraction Spec (PDV_OriginRuntimeBase)

STATUS: LIVING (authored 2026-08-19, autonomous overnight run). Record of the ORIGIN module
extraction out of PDV__ManagerQuest.psc. Mirrors PDV_2_0_LEDGER_ExtractionSpec.md. Branch:
feature/v3-origin-extraction (off feature/v3-ledger-extraction). NOT pushed. Module INERT
until the deferred ESP wiring session.

---

## 1. Scope

ORIGIN is the largest module in the 2.0 decomposition: 667 functions + 557 properties per
PDV_2_0RegionMap.json -> modules.ORIGIN. Extracted as a behavior-preserving PURE MOVE into new
host-instance script **PDV_OriginRuntimeBase (extends Quest)**, with a `PDV__ManagerQuest
Property Manager Auto` backref; the manager gains a `PDV_OriginRuntimeBase Property
OriginRuntime Auto` forward ref. Done in 6 verified incremental tranches (4x LEDGER scale, so
tranched rather than one move).

**FUNCTIONS: 664 of 667 moved.** The 3 gain-pipeline-seam multiplier functions are DEFERRED
(left in the manager, reached via `Manager.`): `GetOrcLifeModeGainMultiplier`,
`GetImperialCurseGainMultiplier` (ORIGIN-tagged), and `GetCurseGainMultiplier` (LEDGER-tagged
but ORIGIN/DAEDRIC-state-reading). Exactly as LEDGER deferred curse through its whole move.

**PROPERTIES: 0 of 557 moved (DEFERRED).** Property declarations stayed in the manager; moved
ORB bodies reference them via `Manager.<prop>`. A later property-consolidation pass moves the
declarations into ORB and un-qualifies. Consequence: ORB is intentionally Manager.-coupled for
property access until that pass -- but the ESP wiring is therefore LIGHTER than LEDGER's (no
property fills on the ORB host QUST; only the Manager backref + OriginRuntime forward-ref).

## 2. The 6 tranches (each parity-proven + compile 0/0 + committed)

| # | Lane cluster | Fns | Commit |
|---|---|---|---|
| 1 | Altmer + Bosmer | 164 | 6414077b |
| 2 | Khajiit + Argonian | 136 | 6e9b6151 |
| 3 | Breton + Redguard | 127 | 05b06011 |
| 4 | Nord + Dunmer (+ Kyne) | 85 | f56b50b0 |
| 5 | Orc + Imperial | 96 | b9036e9d |
| 6 | non-race infra (broad-lane, curse-summary, substrate, Talos, medallion, survey) | 56 | 760780de |
| | **Total** | **664** | |

Tranches were lowest-coupling-first, by-name from modules.ORIGIN (RegionMap line numbers have
drifted; located by name). MANAGER-tagged and DAEDRIC-tagged name-collisions (e.g. `Debug*Breton*`,
`IsBretonHiddenArtDaedricOfferDeity`) were correctly left behind. All 6 Talos functions (incl.
`GetTalosTrackGainMultiplier`, `GetTalosEffectiveGainMultiplier`) moved cleanly -- DeityBase and
the Talos deity scripts do not reach them; the only external reach was PDV_MCM (standard rewire).

## 3. Method (mirror of LEDGER)

- Move BY NAME into PDV_OriginRuntimeBase. Inside moved bodies: references to symbols STAYING in
  the manager qualified `Manager.` (incl. the 3 deferred multipliers, and all 557 properties);
  co-moved ORB symbols bare; `LedgerRuntime.X` -> `Manager.LedgerRuntime.X`, `FavorRuntime.X` ->
  `Manager.FavorRuntime.X`. Retained manager + external call sites of moved fns rewired to
  `OriginRuntime.X`.
- **Accessors: only 3 added total** (`GetRaceCurseSurfaceShown`, `Get/SetQrQueueNeedsBretonRewardSync`,
  in tranche 3); every other shared-script-var seam reused a LEDGER-era manager getter/setter.
- Compiler-guided reach-back qualification (compile from worktree source, iterate to 0/0).
- The resolver-aware verifier (checkSourceContains fallback + pdv_symbol_home decompositionFamily,
  from the LEDGER work) auto-handles the moved needles -- NOT touched.

## 4. Parity proof

Per tranche: every moved function reconstructs BYTE-FOR-BYTE against the pre-move golden
(origin_golden.json) after stripping `Manager.`/`OriginRuntime.` qualifications (accessor
substitutions excepted, and those are accessor-only); retained/caller CHANGED functions
reconstruct call-site-only. Per tranche compile 0 error / 0 warning.

Capstone (golden vs final tip 760780de): `pdv_parity_snapshot --compare` -> **removed=0,
added=3** (only the 3 accessors), moved=87 (verbatim), changed=850 (all qualification-only across
the 6 tranches). Final full-project compile: **101 PASS / 0 FAIL**. Zero logic changes.

## 5. DEFERRED -- supervised next steps (NOT done here; module is INERT)

1. **Provider-seam construction** (per PDV_2_0_ProviderSeam_ExtractionSpec.md, branch
   feature/v3-provider-seam-spec): build `PDV_GainModifierProvider`; make the ORIGIN runtime host
   a provider; move the 3 deferred multipliers into it (phase-tagged); convert LEDGER's interim
   `Manager.GetCurseGainMultiplier`/`GetOrcLifeModeGainMultiplier`/`GetImperialCurseGainMultiplier`
   reach-backs (RunGainPipeline Site A, ProcessDawn Site B) into the `Providers[]` loop. This is
   the one genuine architectural step -- deliberately left for owner-supervised work.
2. **Property-consolidation pass**: move the 557 ORIGIN property declarations from the manager into
   ORB and un-qualify the `Manager.<prop>` refs.
3. **ESP host-QUST wiring** (batched houseCARL session, like LEDGER): create the PDV_OriginRuntimeBase
   host QUST (SGE + SEQ), attach the script, fill the `Manager` backref + the manager's
   `OriginRuntime` forward-ref. LIGHTER than LEDGER (no property fills, since properties stayed on
   the manager QUST -- until step 2). Module no-ops until this lands.
4. **Full env gate roll-up** against deployed V3Dev (with the V3 root set).
5. **Manifest reconciliation**: RegionMap ORIGIN tags still carry original manager line numbers; a
   later pass reflects the OriginRuntime moves (same deferred class as LEDGER's).

## 6. Branch chain

feature/v3-big-update -> feature/v3-ledger-extraction (LEDGER, unmerged) ->
feature/v3-origin-extraction (this, unmerged). Both unpushed, pending owner review. Merge in
order: LEDGER, then ORIGIN.
