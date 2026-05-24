# Phase 10/11 Doc-Grilled Plan

## Summary

Phase 10/11 are subsystem labels, but `PDV_Architecture_v3.md` Section 21.5 is authoritative for execution order. Phase 10 can move as a Dunmer substrate proof-graduation slice. Phase 11 should only receive prep now; live privilege implementation waits behind the Section 21.5 commitment and neglect/decay gates.

The stale Phase 9 top-level status has been corrected in `PDV_Architecture_v3.md`: Phase 9 Bosmer Path is fully runtime-proven.

## Phase 9 Status Correction

The Phase 9 evidence set is explicit in the v3 header/status:

- setup proof
- five route proof surfaces
- path offers
- confirmation-rite switching
- Old Contract re-entry
- PactBound/compliance separation
- forced reckoning `Renounce`
- forced reckoning `Recommit`
- save/load persistence
- strict gate `PASS=808, WARN=0, FAIL=0, INFO=28`

Archive docs are intentionally untouched.

## Locked Decisions

- **Phase 10 scope:** graduate existing Dunmer ancestor proof, not expand content.
- **Phase 10 proof surface:** reuse `PDV_ACTI_DunmerPortableShrineSignal` and `PDV_ACTI_DunmerPrivateShrineSignal`.
- **Phase 10 evidence:** normal-play activators, Papyrus traces, MCM/readback, and verifier; no new boon spell or notification required.
- **Phase 11 D-10:** resolve to the Arngeir/Kynareth privilege pilot.
- **Phase 11 gate:** `PDV_GLO_OriginRace = Nord`, `PDV_GLO_ActiveDeityIndex = Kyne`, `PDV_GLO_ActiveTier >= 3`.
- **Mara scope:** out of the first privilege pilot.
- **Worktrees:** docs/tools/manifests/verifier only. Live MO2 script/ESP/CK work stays serialized in one integration pass.

## Implementation Shape

- Architecture/status correction is isolated in commit `1f9c96e`.
- `--strict-phase10` covers Dunmer substrate graduation: source contract, substrate record/scripts/properties, manager property, reused receiver readback, and separation from patron piety.
- `--strict-phase11` is prep-only and verifies `references/authoring/PDV_Phase11PrivilegePilot.manifest.json`; it does not claim live privilege records.
- D-10 is ratified in living docs as the Arngeir/Kynareth pilot.
- Vanilla shrine base scripts are not edited.
- Broader privilege implementation remains blocked until commitment and neglect/decay are proven.

## Test Plan

- Baseline: current combined strict gate remains no fail/warn/todo.
- Phase 10: fresh Dunmer save, trigger both Dunmer ACTI proof surfaces, confirm substrate metric/counts change, patron piety does not, then save/load and rerun `--strict-phase10`.
- Phase 11 later: fresh Nord/Kyne Champion state exposes Arngeir recognition; non-Nord, wrong deity, and lower tier hide it.
- Final closeout: compile after any `.psc` edit, refresh SEQ after dialogue work, then run the combined strict verifier with Phase 10/11 modes included.

## Assumptions

- Phase 9 runtime proof is complete; remaining "pending" language in living docs is documentation drift.
- Phase 11 prep may happen now; Phase 11 implementation does not.
- No separate MO2 clone is created for parallel live CK/ESP work.
