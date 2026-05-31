# Creation Authoring Cookbook

This guide is for manifest authors. It explains the user-facing rules behind the schema so projects can use the same engine without inheriting Player Devotion assumptions.

## Authored EditorIDs Are Identity

For hand-authored records, an EditorID is part of the design language. If a manifest says `EXM_MainQuest`, the automation must not quietly create `EXM_MainQuest_001` unless the manifest explicitly permits a generated rename.

Defaults:

- `mode: "update"`
- `onConflict: "fail"`
- generated plugin output by default
- source plugin promotion only after review

Use `mode: "create"` only when the record should not already exist. Use `mode: "update"` when the record must already exist. Use `onConflict: "rename"` only for anonymous generated helper records where the exact EditorID is not design-bearing.

## Create A New Record

```json
{
  "id": "create-service-quest",
  "kind": "record.create",
  "target": "EXM_ServiceQuest",
  "mode": "create",
  "onConflict": "fail",
  "recordFamily": "QUST",
  "ckSemanticsRequired": true,
  "reviewIntent": "Create the service quest that will own event receiver glue.",
  "payload": {
    "recordType": "QUST",
    "name": "Example Service Quest"
  },
  "verifierExpectations": [
    { "type": "fieldEquals", "path": "recordType", "value": "QUST" }
  ],
  "mergePolicy": {
    "promote": "reviewed",
    "preserveFormId": "when-safe",
    "requiresCkFinalization": true
  }
}
```

In the current build this remains manual/blocked by default even when CKPE is configured. Use `--allow-unproven-ck` only for explicit discovery packets; generic `record.create` cannot become a product command until CK object mutation plus MO2 readback proof exists for that family.

## Platform v1 Recipes

Platform v1 has two lanes:

- Authoring Utilities: existing-record safe-writer operations with current
  Platform v1 operation proof. Keep support claims tied to those operation
  surfaces.
- CK Creation: CK-owned creation/finalization operations. `GLOB` is supported
  only for the narrow `glob.duplicate_create` path; generic `record.create`
  remains blocked unless a family-specific proof promotes it. `FLST`, `MESG`,
  `ACTI`, and `QUST` currently have operation-level `record.duplicate_create`
  shell proof only; that does not support payload editing, quest
  aliases/stages/fragments, finalization, or generic creation.
- Payload Proof Foundations: `message.payload.set` and
  `activator.payload.set` are explicit payload operation surfaces for the next
  proof tranche. They are not supported until strict live proof promotes the
  exact operation.

### Attach Script To Existing Record

```json
{
  "id": "attach-main-script",
  "kind": "vmad.attach_script",
  "target": "EXM_MainQuest",
  "mode": "update",
  "recordFamily": "QUST",
  "payload": {
    "script": "EXM_MainQuestScript",
    "properties": [
      { "name": "DebugGlobal", "type": "Object", "value": "EXM_GLO_Debug" }
    ]
  }
}
```

### Add FormList Entry

```json
{
  "id": "add-service-quest",
  "kind": "formlist.add",
  "target": "EXM_FLST_AllServices",
  "mode": "update",
  "recordFamily": "FLST",
  "payload": {
    "entry": "EXM_ServiceQuest"
  }
}
```

### Add Conditions, Inventory, Spells, Perks, Or Packages

Use the specific operation kind for the target field. Each operation still needs
strict proof before it can be listed as Platform v1 supported.

```json
[
  {
    "id": "add-condition",
    "kind": "condition.add",
    "target": "EXM_ServiceQuest",
    "mode": "update",
    "recordFamily": "QUST",
    "payload": {
      "conditions": [
        { "function": "GetIsID", "operator": "==", "value": "PlayerRef" }
      ]
    }
  },
  {
    "id": "add-spell",
    "kind": "spell.add",
    "target": "EXM_TestNpc",
    "mode": "update",
    "recordFamily": "NPC_",
    "payload": {
      "spell": "EXM_TestSpell"
    }
  },
  {
    "id": "add-inventory",
    "kind": "inventory.add",
    "target": "EXM_TestContainer",
    "mode": "update",
    "recordFamily": "CONT",
    "payload": {
      "items": [
        { "item": "EXM_TestItem", "count": 1 }
      ]
    }
  }
]
```

### Duplicate A Global Through CK

```json
{
  "id": "duplicate-debug-global",
  "kind": "glob.duplicate_create",
  "target": "EXM_GLO_DebugDUPLICATE001",
  "mode": "create",
  "recordFamily": "GLOB",
  "ckSemanticsRequired": true,
  "payload": {
    "sourceEditorId": "EXM_GLO_Debug",
    "targetEditorId": "EXM_GLO_DebugDUPLICATE001",
    "type": "short",
    "value": 1
  }
}
```

This is the only currently promoted CK creation recipe. It requires a generated
plugin active in CK, guarded CKPE duplicate replay, CK save, MO2 readback,
verifier proof, proof ledger, and matrix promotion. Do not rewrite it as generic
`record.create`.

### Payload On A Generated Duplicate

Payload proof uses two operations. The first proves CK duplicate shell identity;
the second proves the payload delta on the generated duplicate.

```json
[
  {
    "id": "duplicate-message-shell",
    "kind": "record.duplicate_create",
    "target": "EXM_MSG_SourceDUPLICATE001",
    "recordFamily": "MESG",
    "payload": {
      "recordType": "MESG",
      "sourceEditorId": "EXM_MSG_Source",
      "createdEditorId": "EXM_MSG_SourceDUPLICATE001"
    }
  },
  {
    "id": "set-message-payload",
    "kind": "message.payload.set",
    "target": "EXM_MSG_SourceDUPLICATE001",
    "recordFamily": "MESG",
    "payload": {
      "title": "Payload proof title",
      "text": "Payload proof body",
      "buttons": [
        { "text": "Accept" }
      ]
    }
  }
]
```

This is a proof foundation pattern, not a support claim. `record.create`,
`record.update`, broad MESG/ACTI payload editing, and quest payload/finalization
remain blocked until their own strict proof passes.

### Ten-Family Create-And-Fill Discovery

The `creation-fill-spike-v1` lane is intentionally not a cookbook support
recipe. It is a controlled discovery runner for generic `record.create` across
`SPEL`, `MGEF`, `ENCH`, `SCRL`, `WEAP`, `ARMO`, `AMMO`, `BOOK`, `CONT`, and
`MISC`.

Use it only when intentionally running a discovery proof:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Static
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Prepare
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Ck
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Finalize
```

The runner creates the CK-active proof plugin
`CKRA_CreationFillSpikeV1.esp` when missing and keeps its proof ledger separate
from the product proof-results file. Passing discovery does not make
`record.create` supported.

## Update Existing Wiring

```json
{
  "id": "wire-main-quest",
  "kind": "vmad.attach_script",
  "target": "EXM_MainQuest",
  "mode": "update",
  "onConflict": "fail",
  "recordFamily": "QUST",
  "reviewIntent": "Attach the main quest runtime script and fill its object property.",
  "payload": {
    "script": "EXM_MainQuestScript",
    "properties": [
      { "name": "DebugGlobal", "type": "Object", "value": "EXM_GLO_Debug" }
    ]
  }
}
```

This is a safe-writer operation when the profile exposes MO2 MCP or Mutagen.

## Allow Deterministic Rename For Generated Helpers

```json
{
  "id": "create-generated-helper",
  "kind": "record.create",
  "target": "EXM_GEN_HelperMarker",
  "mode": "create",
  "onConflict": "rename",
  "recordFamily": "GLOB",
  "reviewIntent": "Create an anonymous generated helper; exact EditorID is not player/design-facing.",
  "payload": {
    "recordType": "GLOB",
    "value": 0
  }
}
```

Renames must be deterministic, must update internal references, and must appear in the review report.

## CK-Only Packet

```json
{
  "id": "kill-story-manager-node",
  "kind": "story_manager.node",
  "target": "EXM_SM_KillActor",
  "mode": "create",
  "recordFamily": "SMQN",
  "ckSemanticsRequired": true,
  "reviewIntent": "Start the receiver quest from the Kill Actor Story Manager event without consuming the event.",
  "payload": {
    "event": "Kill Actor",
    "receiverQuest": "EXM__SM_KillActor",
    "sharesEvent": true
  },
  "verifierExpectations": [
    { "type": "fieldEquals", "path": "sharesEvent", "value": true }
  ],
  "runtimeSmokeRequired": true
}
```

If no verified CKPE adapter is configured, this blocks automation. Manual packets are development diagnostics only and are not mergeable as automated work.

## Generated Plugin Is The Active CK Plugin

Manifest authors do not manually pick CK's active file. The profile and live runner derive CK lifecycle commands from the project profile, manifest output, masters, and source plugin. Current packets use atomic `loadPluginSet` proof before any ready CK operation.

Generated-first runs select required masters and source plugins as dependencies, then make the generated plugin active. Promotion finalization makes the reviewed merge candidate active. Do not make the source plugin active for generated-first automation unless the profile explicitly opts into in-place authoring.

`loadPluginSet` is verification-only in the current bridge. It must prove the
source plugin, generated or candidate plugin, active plugin, intended save
target, missing-plugin list, and source-not-active rule before mutation. If it
reports blockers such as `missing_source_plugin`,
`generated_or_candidate_plugin_not_active`, `source_plugin_active`,
`intended_save_target_mismatch`, or `active_target_not_normal_writable_esp`, fix
CK's loaded/active state before running the proof.

```powershell
node .\scripts\send-ckpe-packet.mjs .\fixtures\ckpe\load-plugin-set-product-ready.ck-command-packet.json
node .\scripts\send-ckpe-packet.mjs .\fixtures\ckpe\load-plugin-set-blocked-cases.ck-command-packet.json --allow-blocked --expect-status UNSAFE_BLOCKED
```

## Review And Promote

Generate first:

```powershell
node .\src\cli.mjs generate .\examples\simple-wiring.manifest.json --profile .\examples\simple-project.profile.json --strict --write-report
```

Use the live runner when the Anvil MO2 MCP server should execute the safe patch
and readback phases:

```powershell
node .\src\live-runner.mjs run .\examples\simple-wiring.manifest.json `
  --profile .\examples\simple-project.profile.json `
  --strict `
  --reports-dir .\reports
```

Promote only after review:

```powershell
node .\src\cli.mjs promote .\reports\example-run-report.json `
  --profile .\examples\simple-project.profile.json `
  --approved `
  --merge-output-path .\scratch\ExampleMod.merge-candidate.esp
```

Promotion requires a passing run report, no manual packets, human approval, an explicit candidate output path, timestamped backup, structured merge, CK finalization when required, and post-merge verification. Use `promotion-candidate-check` for repo-local dry-run proof; it must pass with the dry-run post-merge verifier proving the candidate verification contract while still proving that no source, generated, or candidate plugin path was written.

Payload proof has its own runner and should start with MESG before ACTI:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Prepare
powershell -ExecutionPolicy Bypass -File .\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Ck
powershell -ExecutionPolicy Bypass -File .\scripts\run-payload-v1-proof.ps1 -Surface MESG -Stage Finalize
powershell -ExecutionPolicy Bypass -File .\scripts\run-payload-v1-proof.ps1 -Surface ACTI -Stage All -DryRun
```

## Prove A Capability

Proof is separate from planning. A record family becomes `supported` only after a strict proof ledger drives the capability matrix:

```powershell
node .\src\cli.mjs prove .\examples\record-create.manifest.json `
  --profile .\examples\simple-project.profile.json `
  --strict `
  --proof-output ..\..\generated\example.proof-ledger.json
```

Then run `matrix --proof-results <ledger> --verify`. If the row remains unproven, use `docs/capability-promotion.md` or the `ck-record-family-promoter` skill.

Strict proof also requires readback-oracle coverage. If a manifest uses an operation without a normalizer, an unsupported verifier expectation, or a partial winning overlay, verification returns `TODO`/`FAIL` and the proof ledger cannot promote the row.

## Prepare A Dialogue Proof

Dialogue authoring is CK-owned. Use `fixtures/dialogue-v1` as the reusable
shape for future dialogue packets; it is intentionally generic and not tied to
any Player Devotion phase. It verifies CK-authored `DLBR`, `DIAL`, unnamed
`INFO`, condition stack, and separate SEQ freshness readback.

For batch work, start from rows and generate the normal manifest instead of
hand-building every branch/topic/info operation:

```powershell
node .\packages\creation-authoring\src\cli.mjs dialogue-scaffold .\fixtures\dialogue-v1\dialogue-v1.rows.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --output-file .\scratch\dialogue-v1.scaffold.json
```

Then author the records in CK with the generated plugin active, save it, refresh
readback, and bind the manifest intent to the CK-created identities:

```powershell
node .\packages\creation-authoring\src\cli.mjs dialogue-bind .\fixtures\dialogue-v1\dialogue-v1.creation-authoring.json `
  --profile .\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --readback .\fixtures\dialogue-v1\dialogue-v1.readback.json `
  --output-file .\scratch\dialogue-v1.bind-report.json
```

This pulls the manual burden forward into row review and CK binding, while still
failing closed. A bind report can prove that readback matches intent; it cannot
promote `DIAL` or `INFO` creation support without CKPE command evidence and the
normal strict proof ledger.

Static discovery planning can be checked with unproven CK explicitly enabled:

```powershell
node .\src\cli.mjs fixture-check ..\..\fixtures\dialogue-v1 `
  --profile ..\..\fixtures\dialogue-v1\dialogue-v1.profile.json `
  --readback ..\..\fixtures\dialogue-v1\dialogue-v1.readback.json `
  --allow-unproven-ck
```

Without `--allow-unproven-ck`, the same fixture must stay manual/blocked. Do not
promote `DIAL` or `INFO` support from fixture readback alone; a support proof
needs CKPE-side branch/topic/info creation, active generated-plugin save, MO2
readback, verifier pass, strict gate, proof ledger, and matrix verification.
