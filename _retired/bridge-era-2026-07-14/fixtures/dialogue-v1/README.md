# Dialogue v1 Fixture

This fixture is a generic CK dialogue proof scaffold. It is not tied to a
Player Devotion phase.

The fixture covers the reusable shape needed for future dialogue work:

- CK-owned dialogue branch creation (`DLBR`)
- CK-owned dialogue topic creation (`DIAL`)
- CK-owned Topic Info creation (`INFO`), including unnamed INFO readback by
  topic, speaker, response line, and conditions
- SEQ freshness as a separate artifact proof gate

The fixture is allowed to plan CKPE commands only in discovery mode with
`allowUnprovenCk`. It must not promote `DIAL` or `INFO` support until the native
CKPE handlers create and save the records and a proof ledger contains passing
command evidence plus live readback.

## Batch Authoring Helpers

`dialogue-v1.rows.json` is the smallest rows-first input for future dialogue
work. It lets project authors draft lines in a compact shape, then scaffold the
normal creation-authoring manifest:

```powershell
node .\packages\creation-authoring\src\cli.mjs dialogue-scaffold .\fixtures\dialogue-v1\dialogue-v1.rows.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --output-file .\scratch\dialogue-v1.scaffold.json
```

After CK authoring and generated-plugin readback, bind the manifest back to the
actual CK identities:

```powershell
node .\packages\creation-authoring\src\cli.mjs dialogue-bind .\fixtures\dialogue-v1\dialogue-v1.creation-authoring.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --readback .\fixtures\dialogue-v1\dialogue-v1.readback.json `
  --output-file .\scratch\dialogue-v1.bind-report.json
```

The bind report is intentionally proof-adjacent, not a support claim. It can
match unnamed CK `INFO` records by topic, speaker, response line, and conditions,
but support still requires native CKPE command evidence, CK save, readback,
strict proof ledger, and capability-matrix promotion.
