# PDV 2.0 -- LEDGER Extraction Spec (PDV_DevotionLedger)

STATUS: LIVING (authored 2026-08-18). Record of the LEDGER module extraction out of
`PDV__ManagerQuest.psc`. Mirrors `PDV_2_0_FAVOR_ExtractionSpec.md`. Governed by
`PDV_2_0_ADR_GainPipelineContract.md` for the gain-pipeline seam.

Branch: `feature/v3-ledger-extraction` (off `feature/v3-big-update` @ f01d1ada).

---

## 1. Scope

LEDGER is the piety / tier / patron economy -- the largest carve-out in the 2.0
decomposition. Per `PDV_2_0RegionMap.json -> modules.LEDGER`: 220 functions + 81 properties.
Extracted as a PURE, behavior-preserving MOVE into new host-instance script
`PDV_DevotionLedger extends Quest`, talking back to the manager through a single
`PDV__ManagerQuest Property Manager Auto` backref; the manager gains a
`PDV_DevotionLedger Property LedgerRuntime Auto` forward ref.

Owner-confirmed decisions (see also the ADR):
- **Defer the gain-pipeline provider seam.** The move is pure; the ADR's
  `PDV_GainModifierProvider` base + `Providers[]` array are NOT built here. The curse /
  stigma / orc-life-mode / imperial-curse multiplier functions STAY in the manager and are
  reached from the moved `RunGainPipeline` / `ProcessDawn` via `Manager.`-qualified calls.
  No cycle (LEDGER -> Manager only). The seam is built later, with ORIGIN and DAEDRIC.
- **Single pure-move commit**, proven by reconstruction parity (Section 4).
- **Leave the two direct external piety writers as-is** (`PDV_DaedricPathBase`,
  `PDV_Origin` write `PDV.Piety` / `PDV.PietyToday` directly). Keys stay a shared
  unbound-string contract; no migration.

## 2. Move-set adjustments (the move-set is NOT raw modules.LEDGER)

- **Moved: 216 functions** (of 220) + **81 properties** into `PDV_DevotionLedger.psc`.
- **Kept in the manager by adjustment (2):** `GetCurseGainMultiplier`,
  `GetCurseGainMultiplierNoop`(*inlined, see below*). Region map tags `GetCurseGainMultiplier`
  LEDGER, but the ADR reassigns it to ORIGIN (it reads `PDV_CurseStateService` +
  `PDV_HircinePath`). It therefore stays in the manager and moves later with ORIGIN. This is
  a known RegionMap drift -- reconcile the assignment when ORIGIN extracts.
- **Dropped (deleted, not ported) -- ADR Decision 6 (2):** `GetReputationGainMultiplier`,
  `GetReputationGainMultiplierNoop`. Dead (zero callers tree-wide; the track factor is
  already folded into `deity.GetEffectiveGainMultiplier()`). Confirmed no `tools/` needle
  pins either name.
- **Noop wrappers inlined -- ADR Decision 6 (2):** `GetCurseGainMultiplierNoop` /
  `GetDaedricStigmaGainMultiplierNoop` deleted from the manager; `RunGainPipeline` now calls
  `Manager.GetCurseGainMultiplier` / `Manager.GetDaedricStigmaGainMultiplier` directly (the
  "Noop" name lied -- they were pass-throughs). `GetDaedricStigmaGainMultiplier` itself stays
  in the manager (DAEDRIC-assigned; moves with DAEDRIC).

**Manifest reconciliation (DEFERRED, matches FAVOR precedent of not editing manifests during
extraction).** `PDV_2_0RegionMap.json` still lists four now-deleted functions
(`GetReputationGainMultiplier`, `GetReputationGainMultiplierNoop`, `GetCurseGainMultiplierNoop`
under `modules.LEDGER`; `GetDaedricStigmaGainMultiplierNoop` under `modules.DAEDRIC`) and still
tags `GetCurseGainMultiplier` LEDGER though it stays in the manager. No current gate false-fails
on this (the resolver's `definitionFile` reads reality). Reconcile these -- plus registering the
new `PDV_DevotionLedger` (and the still-unregistered FAVOR `PDV_ContextualFavorRuntime`) in
`PDV_ReleasePayload.manifest.json` -- in the V3 manifest catch-up pass.

## 3. Reach-backs, accessors, external callers

- **Qualification is the only permitted body change.** A moved body's reference to a symbol
  that STAYS in the manager is qualified `Manager.X`; co-moved LEDGER symbols stay bare;
  globals / method-calls-on-locals / string keys are unchanged.
- **21 new manager accessors** (9 getters + 12 setters) were required because LEDGER has
  WRITE-shared script state (unlike FAVOR, which needed one existing getter). Moved bodies
  route access to manager-retained script VARIABLES through these; 142+ retained reads stay
  bare/unchanged. Each accessor is a trivial pass-through (`return _var` / `_var = value`)
  over the correct variable (e.g. `SetActiveDeityRef`/`GetActiveDeity` for `_activeDeity`,
  `Set/GetBroadPantheonSelfEventSequence`, the four survival/CC presence flags, the three
  suppress flags, `SetPendingCommitmentOfferDeity`, `SetRaceCurseSurfaceShown`,
  `SetQrQueueNeedsCurseRefresh`, `Set/GetDawnHadActivity`, `GetQrQueueTransactionActive`).
- **External-caller rewires (compile-forced):** 55 receiver-typed rewrites across 5 files
  -- `PDV_ActionRouter` (incl. the public `AwardPietyFromLikesDislikes` call ->
  `PDV_Manager.LedgerRuntime.AwardPietyFromLikesDislikes`), `PDV_EventBus`, `PDV_MCM`,
  `PDV_Origin`, and `PDV_ContextualFavorRuntime` (its `Manager.GetTier/GetPatronState/...`
  now route through `Manager.LedgerRuntime.*`). Comment-only references were not rewritten.

## 4. Parity proof (independently verified, not agent-self-reported)

Method: pre-move manager from git HEAD; for every function, strip `Manager.`/`LedgerRuntime.`
qualifications from the current body and require it to reconstruct the golden body exactly.
Result over 1310 manager functions:
- **1277 reconstruct byte-for-byte** (186 moved-to-ledger + 1091 stayed) = pure qualification.
- **30 accessor-substitution functions** differ only by `_var` <-> `Get/SetVar()` swaps
  (semantically identical given the trivial accessors above).
- **REMOVED = exactly {GetReputationGainMultiplier, GetReputationGainMultiplierNoop}**.
- **ADDED = exactly the 21 accessors.**
- **0 logic changes; no string literals altered** (`"PDV.Manager.*"` key counts identical
  golden vs current).
- Compile: `PDV_DevotionLedger` + `PDV__ManagerQuest` (+ callers) 0 error / 0 warning,
  isolated worktree-source compile.

## 5. Resolver-aware verifier fix (owner-approved toolchain change)

The move broke 78 `pdv_verify.mjs` definition-contract needles (and FAVOR had already left
32 stale) because `checkSourceContains` hard-codes a script name and asserts exact strings.
Rather than hand-patch per extraction, `checkSourceContains` now falls back -- when the exact
check on the named script fails AND the target is the decomposition source
(`PDV__ManagerQuest`) -- to searching the whole DECOMPOSITION FAMILY (manager + every
`RegionMap.modules[].targetScript`) with qualifier-stripped matching. New resolver helpers in
`tools/lib/pdv_symbol_home.mjs`: `decompositionFamily()`, `stripQualifiers()`. The fallback is
ADDITIVE (exact check runs first -> no currently-passing needle can regress). Plus 3 needle
texts updated from `_activeDeity` to `GetActiveDeity()` (the one accessor form the family
search can't infer).

Effect: the LEDGER move introduces **zero net-new stale needles**, and FAVOR's moved needles
resolve for free. This is durable -- future extractions won't break these needles.

**Known residual (pre-existing, OUT OF SCOPE):** 20 needles remain stale on BOTH the clean
base and this branch -- older drift referencing symbols absent even at f01d1ada (e.g.
`Function BuildModePage()`, `SetArgonianHome`, `AdjustKhajiitFocusedEmphasis`,
`EnsureBosmerSetupChoice`, `RouteP2ImmersiveSource`). Not extraction-caused; flagged for a
separate cleanup, not fixed here.

## 6. Deferred provider-seam obligation (do not let the interim ossify)

The interim `Manager.GetCurseGainMultiplier` / `Manager.GetDaedricStigmaGainMultiplier`
(Site A) and `Manager.GetOrcLifeModeGainMultiplier` / `Manager.GetImperialCurseGainMultiplier`
(Site B, in the moved `ProcessDawn` consolidation) reach-backs are TEMPORARY. When ORIGIN and
DAEDRIC extract, each MUST, per the ADR:
1. take its gain-multiplier function(s) out of the manager into its runtime host,
2. make that host a `PDV_GainModifierProvider`,
3. convert LEDGER's interim `Manager.Get*GainMultiplier` reach-backs into `Providers[]`
   entries (phase-tagged), and fill the array in the batched houseCARL session.
Until then the reach-backs are known debt, not a permanent Option-C choice.

## 7. DEFERRED -- ESP / CK work (batched houseCARL session; module is INERT until done)

Not part of the code change. Via `housecarl_create_record` + `housecarl_set_field`, per
`skyrim-plugin-record-writes` (readback is the proof):
1. Create the `PDV_DevotionLedger` host QUST (start-game enabled -> SGE + SEQ) and attach the
   compiled script.
2. Fill the moved filled-`Auto` form properties with the forms currently on
   `PDV__ManagerQuest`; fill the `Manager` backref and `Manager.LedgerRuntime` forward ref.
3. `pdv_vmad_audit.mjs` must then report zero unfilled properties.
The ADR `Providers[]` array fill is NOT part of this session (it belongs to the ORIGIN/DAEDRIC
seam work, Section 6). Until steps 1-2 land, `Manager`/`LedgerRuntime` are None and LEDGER
calls no-op or return default -- the intended inert state.

## 8. Gate posture at authoring time

Proven here: reconstruction parity (Section 4), isolated worktree-source compile 0/0, and the
resolver-aware needle logic (validated by replicating the matcher; worktree residual == the
20 pre-existing). NOT yet run here (needs the deployed V3Dev + game env): the full
`pdv_verify.mjs` against the deployed tree, `pdv_deity_stance_parity`, `pdv_integrity_harness`,
`pdv_ledger_coverage_audit`, `pdv_vmad_audit`. Run those with the V3 roots set
(`PDV_COMPILE_SOURCE_ROOT`/`PDV_DEVOTION_ROOT` -> Devotion-V3Dev) after the ESP session --
the inventory/verify gates false-FAIL against the 1.5 default.
