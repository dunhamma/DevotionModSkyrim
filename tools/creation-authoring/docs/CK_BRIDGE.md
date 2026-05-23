# CK Bridge Adapter

`creation-authoring` now emits `creation-authoring.ck-command-packet.v1` from
CK-semantic operations. The packet is the contract for a future CKPE/native
bridge or a verified UI automation fallback.

The executor never treats a CK packet as complete unless a host adapter runs it
and the normal readback/verifier phases prove the result.

Packet shape:

```json
{
  "schema": "creation-authoring.ck-command-packet.v1",
  "generatedPlugin": "ExampleMod_GeneratedCk.esp",
  "failClosed": true,
  "commands": [
    { "op": "openProject", "profile": "example-mod", "game": "SkyrimSE" },
    { "op": "loadPlugin", "plugin": "ExampleMod_GeneratedCk.esp", "active": true },
    {
      "op": "addStoryManagerNode",
      "target": "EXM_SM_KillActor",
      "event": "Kill Actor",
      "receiverQuest": "EXM__SM_KillActor",
      "sharesEvent": true
    },
    { "op": "savePlugin", "plugin": "ExampleMod_GeneratedCk.esp" }
  ]
}
```

Initial native bridge implementation target:

1. Launch CK through the configured MO2 executable.
2. Load the generated plugin as active.
3. Execute one proven command.
4. Save.
5. Return JSON command results.
6. Let the outer pipeline perform MO2/Mutagen readback and project verification.

Do not expand the command surface until each operation has a readback verifier.

Current implementation status:

- `src/ck-ipc-adapter.mjs` can send packets over
  `\\.\pipe\CreationKitAuthoringBridge` or write file-queue requests.
- `native/CreationKitAuthoringBridge` defines the authoring-only bridge scaffold
  and result schema.
- CK command handlers intentionally return fail-closed results until a handler
  is implemented and proven through live readback.
- UI automation remains an explicit fallback path only; it is not used
  automatically.
