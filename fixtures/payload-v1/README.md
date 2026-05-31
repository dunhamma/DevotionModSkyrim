# Payload v1 Fixtures

These fixtures define the next proof tranche without changing support claims.
Each manifest separates CK duplicate identity from generated-plugin payload
mutation:

- `record.duplicate_create` proves the CK-created shell identity.
- `message.payload.set` and `activator.payload.set` prove a minimal payload
  delta on that generated duplicate.

The fixtures are static readiness surfaces only. Matrix support still requires
strict live proof, generated-plugin readback, verifier PASS, proof ledger merge,
and capability-matrix verification for the exact operation.

Run the MESG live proof as a split CK/MO2 cycle. The runner keeps fixture
validation on these static fixtures, then uses the live manifest/profile under
`reference-packs/player-devotion/payload-v1` for the actual proof run:

```powershell
.\scripts\run-payload-v1-proof.ps1 -Surface MESG -DryRun
.\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Prepare
.\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Ck
.\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Finalize
```

Run the ACTI live proof through the same split cycle. The structure is the
same; only the live manifest/profile differ:

```powershell
.\scripts\run-payload-v1-proof.ps1 -Surface ACTI -DryRun
.\scripts\run-payload-v1-proof.ps1 -Surface ACTI -Stage Prepare
.\scripts\run-payload-v1-proof.ps1 -Surface ACTI -Stage Ck
.\scripts\run-payload-v1-proof.ps1 -Surface ACTI -Stage Finalize
```
