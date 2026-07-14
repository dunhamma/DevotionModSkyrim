# Platform v1 Proof Fixtures

These manifests are minimal proof inputs for Platform v1 safe-writer promotion.
They are not support claims by themselves. A fixture becomes product evidence
only after strict generated-plugin execution, MO2 readback, verifier pass, proof
ledger generation, and capability matrix promotion.

Use `fixture-check` to validate that the manifests, fixture profile, and fixture
readback stay internally consistent before live proof runs:

```powershell
node packages\creation-authoring\src\cli.mjs fixture-check fixtures\platform-v1 `
  --profile fixtures\platform-v1\platform-v1.profile.json `
  --readback fixtures\platform-v1\platform-v1.readback.json `
  --output-file generated\platform-v1-fixture-check.json
```

Use the batch runner to inspect or execute the real strict proof commands:

```powershell
.\scripts\run-platform-v1-safe-writer-proof.ps1 -DryRun

.\scripts\run-platform-v1-safe-writer-proof.ps1
```

The dry run only prints the enforced commands. The real run must fail until a
surface has a live generated-plugin writer path and matching MO2 readback. A
`REQUESTED` proof result is expected for valid fixtures that still lack a real
writer adapter, and it must not be promoted.
