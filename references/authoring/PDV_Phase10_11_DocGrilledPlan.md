# Phase 10/11 Doc-Grilled Plan

## Summary

Phase 10/11 are subsystem labels, but `PDV_Architecture_v3.md` Section 21.5 is authoritative for execution order. Phase 10 can move as a Dunmer substrate proof-graduation slice. Phase 11 should only receive prep now; live privilege implementation waits behind the Section 21.5 commitment and neglect/decay gates.

The stale Phase 9 top-level status has been corrected in `PDV_Architecture_v3.md`: Phase 9 Bosmer Path is fully runtime-proven. Phase 10 Dunmer substrate proof-graduation is also now runtime-proven.

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
- `--strict-phase11` now verifies `references/authoring/PDV_Phase11PrivilegePilot.manifest.json`; live dialogue readback is gated behind `implementationStatus = live-dialogue-authored`.
- D-10 is ratified in living docs as the Arngeir/Kynareth pilot.
- Vanilla shrine base scripts are not edited.
- Broader privilege implementation remains blocked until commitment and neglect/decay are proven.

## Test Plan

- Baseline: current combined strict gate remains no fail/warn/todo.
- Phase 10: COMPLETE on 2026-05-24. Fresh Dunmer save started at `DunmerAncestor=metric=0.000000; tier=0; prayers=0; homes=0` with patron piety and deity roster values still `0.000000`.
- Phase 10 route proof: `PDV_ACTI_DunmerPrivateShrineSignal` / route `31` advanced the substrate to `metric=8.000000; tier=1; prayers=0; homes=1`; after the daily gate cleared, `PDV_ACTI_DunmerPortableShrineSignal` / route `30` advanced it to `metric=13.000000; tier=1; prayers=1; homes=1`.
- Phase 10 closeout: patron piety remained separate, save/load persistence passed, and the combined strict gate was clean at `PASS=847, WARN=0, FAIL=0, INFO=28`.
- Phase 11 later: rebuild the Arngeir recognition surface through a CK-safe path, then prove fresh Nord/Kyne Champion recognition and the non-Nord, wrong-deity, and lower-tier negatives.
- Final closeout: compile after any `.psc` edit, refresh SEQ after future dialogue work, then run the combined strict verifier with Phase 10/11 modes included.

## Runtime Follow-Up

- COMPLETE in the next-packet implementation pass: `PDV_ACTI_DunmerPortableShrineSignal` now uses `PDV.Signal.DunmerPortableShrine.Activator`.
- `PDV_ACTI_DunmerPrivateShrineSignal` keeps `PDV.Signal.DunmerHome.Activator`.
- `--strict-phase10` now fails if both Dunmer proof ACTI records share one once-per-day key again.
- The correction does not reopen Phase 10 runtime proof; it removes the daily-key drift discovered during proof closeout.

## Next Packet Handoff

The follow-on plan is now tracked in `references/authoring/PDV_NextPacket_DocGrilledPlan.md`. It covers Khajiit focused emphasis, Kyne commitment, Kyne neglect/decay, and the gated Arngeir/Kynareth Phase 11 pilot.

## Assumptions

- Phase 9 runtime proof is complete; remaining "pending" language in living docs is documentation drift.
- Generated Phase 11 live dialogue records were removed after a CrashLogger-confirmed CTD on 2026-05-24. Phase 11 is prep-only again until the Arngeir surface is rebuilt through a CK-safe path.
- No separate MO2 clone is created for parallel live CK/ESP work.
