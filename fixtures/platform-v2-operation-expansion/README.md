# Platform v2 Operation-Expansion Fixtures

These fixtures define the first V2 operation-expansion tranche for:

- `SPEL spell.add`
- `SPEL condition.add`
- `PERK perk.add`
- `PERK vmad.attach_script`

The fixtures are support candidates only. Promotion still requires strict run
proof, readback/verifier PASS, proof-ledger aggregation, capability-matrix
verification, and a passing V2 tranche summary.

Validate fixture/profile/readback alignment:

```powershell
node packages\creation-authoring\src\cli.mjs fixture-check fixtures\platform-v2-operation-expansion `
  --profile fixtures\platform-v2-operation-expansion\platform-v2.profile.json `
  --readback fixtures\platform-v2-operation-expansion\platform-v2.readback.json `
  --output-file generated\platform-v2-operation-expansion-fixture-check.json
```

Run the tranche lane:

```powershell
.\scripts\run-platform-v2-operation-expansion.ps1 -Mode Preflight

.\scripts\run-platform-v2-operation-expansion.ps1 -Mode Release
```
