# PDV Platform v1 Internal Release

Status: ready for the narrow Platform v1 internal release.

Source CKRA commit:

```text
fcf7ede complete Platform v1 promotion evidence
```

Live plugin paths:

- Source ESP: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp`
- Reviewed candidate ESP: `D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework_PlatformV1_Candidate.esp`
- Generated proof ESP: `D:\Wabbajack\modlists\Anvil\mods\Devotion\CKRA_PlatformV1SafeWriterProof.esp`

Release status:

- `platformV1Gate.status: PASS`
- `platformV1ProductReady: true`
- `releaseReady: false`
- Promotion report: `PASS`
- Candidate winner readback: `PASS`
- PDV verifier: `PASS`

The generated proof ESP remains release evidence only. Do not merge
`CKRA_PlatformV1SafeWriterProof.esp` or duplicate shell proof records into
`Devotion.esp` as part of this release tranche.

The reviewed candidate ESP is the usable promoted output for Platform v1. A
separate explicit acceptance/replacement decision is still required before the
candidate replaces the source ESP.

Mirrored evidence:

- `references/authoring/generated/platform-v1-live-promotion-report.json`
- `references/authoring/generated/platform-v1-promotion-candidate-finalize.ck-command-packet.json`
- `references/authoring/generated/platform-v1-promotion-candidate-finalize.ck-result.json`
- `references/authoring/generated/platform-v1-proof-summary.json`

Scope boundary:

- This release proves the narrow Platform v1 operation gate.
- This release does not claim full Skyrim matrix readiness.
- This release does not claim generic `record.create` support.
