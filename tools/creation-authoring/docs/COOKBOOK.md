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

In the current build this emits a fail-closed packet unless a project supplies a proven CK adapter.

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

If no verified CK adapter is configured, this blocks automation and emits a manual packet. It is not mergeable as automated work.

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
node .\src\cli.mjs promote .\reports\example-run-report.json --profile .\examples\simple-project.profile.json --approved
```

Promotion requires a passing run report, no manual packets, human approval, timestamped backup, structured merge, CK finalization when required, and post-merge verification.
