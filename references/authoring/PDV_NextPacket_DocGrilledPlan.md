# Doc-Grilled Next Packet: Khajiit, Commitment, Neglect/Decay, and Phase 11

## Summary

This packet follows `PDV_Architecture_v3.md` Section 21.5:

1. Phase 10 cleanup: Dunmer shrine cooldown-key drift.
2. Slice 5: Khajiit lunar exception closeout.
3. Slice 6: Kyne commitment offer pilot.
4. Slice 7: Kyne neglect/decay pilot.
5. Slice 8 / Phase 11: Arngeir/Kynareth privilege pilot after Slices 6 and 7 pass.

Do not include full Daedric, curse-state, contextual favor, or live toast work in this packet. UI toast work remains prep-only.

## Implemented Scaffold

- `--strict-khajiit`, `--strict-commitment`, and `--strict-neglect-decay` exist in `tools/pdv_verify.mjs`; `tools/pdv_compile.mjs` passes them through.
- Phase 10 cooldown-key drift is fixed: portable shrine uses `PDV.Signal.DunmerPortableShrine.Activator`; private/home shrine uses `PDV.Signal.DunmerHome.Activator`.
- `--strict-phase10` fails if the two Dunmer ACTI records share one once-per-day key again.
- Khajiit focused emphasis source/readback is implemented with CK mirror `PDV_GLO_KhajiitFocusedEmphasis`.
- Khajiit enum is locked: `None=0`, `Khenarthi=1`, `Azurah=2`, `BaanDar=3`, `Rajhin=4`, `Alkosh=5`.
- Kyne commitment and neglect/decay source hooks are present in `PDV__ManagerQuest.psc`.
- `tools/pdv-next-packet-author` ensures the Khajiit mirror global, repairs Dunmer keys, creates `PDV_MGEF_Neglect_Kyne` / `PDV_SPEL_Neglect_Kyne`, and wires manager properties.

## Remaining CK-Owned Work

- The generated Arngeir/Greybeards `DLBR`/`DIAL`/`INFO` records were removed after CrashLogger tied a CTD to `PDV_DIAL_Phase11ArngeirKyneRecognitionTopic` and the generated branch.
- Phase 11 is demoted back to prep-only until the dialogue surface is rebuilt through a CK-safe path.
- Recognition line: `The wind has marked you, Dragonborn. Walk with Kyne's breath.`
- The line is gated on Arngeir speaker, `PDV_GLO_OriginRace = Nord`, `PDV_GLO_ActiveDeityIndex = Kyne`, and `PDV_GLO_ActiveTier >= 3`.
- Refresh SEQ after future dialogue work.

## Runtime Proof Closeout

Completed on 2026-05-25:

- Khajiit Slice 5: road-home cadence proved Khenarthi focus at `KhajiitLunar=metric=13.139999; tier=1; roadhome=3; focus=Khenarthi; kh=54.75; az=0.00`.
- Khajiit Slice 5: moon observance proved Azurah focus switch at `KhajiitLunar=metric=24.904676; tier=1; phase=1; observance=6; roadhome=3; focus=Azurah; kh=54.75; az=73.52`.
- Khajiit Slice 5: save/load persistence passed with `metric=24.904699`, `focus=Azurah`, `kh=54.75`, and `az=73.52`.
- Commitment Slice 6: two positive Kyne signal days produced `Commitment=pending=0; days=2; cooldown=0.00`.
- Commitment Slice 6: `Not Yet` cleared pending with `rupture=0` and about 7 days cooldown; `Refuse` cleared pending with `rupture=1` and 14 days cooldown; `Accept` set Kyne as active patron.
- Commitment Slice 6: accepted Kyne persisted across reload with `Active patron=KYNE [0]`, `Patron state=ACTIVE PATRON`, `Active piety=51.000000`, `Active tier=DEVOTED`, and `Active deity index=0`.
- Neglect/decay Slice 7: no decay inside 3-day grace, one decay tick after grace, no second same-day decay, Kyne neglect spell applied at low accepted-patron piety, and the spell removed after piety recovery.
- Final full strict gate after runtime proof: `PASS=898, INFO=29`, with no `FAIL`, `WARN`, or `TODO`.

Phase 11 remains deferred/prep-only after generated dialogue CTD remediation.

## Current Verification Boundary

Baseline Phase 10 stack after helper repair:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving --json
```

Current result after runtime proof and Phase 11 crash remediation: full packet verification treats Phase 11 as prep-only. The removed generated dialogue records must not be restored for runtime smoke.

Full packet gate:

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving --json
```

Expected current boundary:

- No generated Phase 11 dialogue records are present in the live ESP.
- `--strict-phase11` verifies only the D-10 manifest while `implementationStatus` is `prep-only`.
- The full strict gate is clean at `PASS=898, INFO=29`, with no `FAIL`, `WARN`, or `TODO`.

## Runtime Smoke Checklist

Use two fresh save branches.

### 1. Baseline

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

### 2. Fresh Khajiit Branch

- Confirm origin is Khajiit.
- Trigger moon observance.
- Trigger road-home cadence.
- Prove Khenarthi focus emerges.
- Trigger Azurah-weighted proof and prove focus can switch.
- Confirm `PDV_GLO_PatronState` does not become active primary.
- Save/load and confirm substrate plus focus persist.

### 3. Fresh Nord/Kyne Branch

- Reach Kyne piety threshold and two recent Kyne signal days.
- Dawn creates one pending commitment offer.
- Branch-save and prove `Not Yet` cooldown.
- Branch-save and prove `Refuse` rupture/cooldown.
- Main branch accepts and proves active patron, carry-over, and save/load.

### 4. Neglect/Decay Continuation

- Prove no decay inside grace.
- Prove one decay tick after grace.
- Prove no second decay on the same in-game day.
- Force low accepted-patron piety and prove Kyne neglect spell applies.
- Recover piety and prove the spell removes.

### 5. Phase 11 Continuation

- Deferred after CTD remediation.
- Rebuild the Arngeir recognition surface through a CK-safe dialogue path before runtime proof.
- Keep the future negative gates unchanged: non-Nord, wrong deity, and Kyne below Champion.

### 6. Final Gate

```powershell
cd "C:\Users\Admin\Documents\Devotion Mod Project"
node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```
