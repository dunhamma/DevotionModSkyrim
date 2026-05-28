# Platform v1 Live Proof Pack

This pack proves safe-writer operations against the active Anvil/MO2 Devotion
profile using a disposable generated plugin:

`CKRA_PlatformV1SafeWriterProof.esp`

The generated plugin must remain a proof artifact. Do not promote it into
`PlayerDevotion_Framework.esp`; it intentionally writes synthetic proof entries
onto live records to verify writer/readback coverage.

Proof command:

```powershell
node packages\creation-authoring\src\cli.mjs prove-applied `
  reference-packs\player-devotion\platform-v1\platform-v1-live-safe-writer.creation-authoring.json `
  --profile reference-packs\player-devotion\platform-v1\platform-v1-live.profile.json `
  --readback reference-packs\player-devotion\platform-v1\platform-v1-live-safe-writer.readback.json `
  --writer-evidence reference-packs\player-devotion\platform-v1\platform-v1-live-safe-writer.writer-evidence.json `
  --strict `
  --platform-v1 `
  --report-path reports\platform-v1-live-safe-writer.strict.run-report.json `
  --proof-output generated\platform-v1-live-safe-writer.proof-ledger.json
```

