# CK Bridge Adapter

`creation-authoring` now emits `creation-authoring.ck-command-packet.v1` from
CK-semantic operations. The packet is the contract for the CKPE-native bridge.
UI automation is not part of the shippable green path.

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
    {
      "op": "loadPluginSet",
      "requiredPlugins": ["ExampleMod.esp", "ExampleMod_GeneratedCk.esp"],
      "sourcePlugin": "ExampleMod.esp",
      "generatedPlugin": "ExampleMod_GeneratedCk.esp",
      "activePlugin": "ExampleMod_GeneratedCk.esp",
      "intendedSaveTarget": "ExampleMod_GeneratedCk.esp",
      "sourcePluginNotActive": true
    },
    {
      "op": "addStoryManagerNode",
      "target": "EXM_SM_KillActor",
      "event": "Kill Actor",
      "receiverQuest": "EXM__SM_KillActor",
      "sharesEvent": true
    },
    { "op": "postUiSaveCommand", "plugin": "ExampleMod_GeneratedCk.esp" },
    { "op": "closeSafeStatus" }
  ]
}
```

Only ready operations are emitted into packets. Unproven CK-semantic operations
remain manual/blocked unless a discovery caller explicitly uses
`allowUnprovenCk` / `--allow-unproven-ck`.

Native bridge implementation target:

1. Launch CK through the configured MO2 executable.
2. Select the required masters/source plugins and generated plugin.
3. Mark the generated plugin active and prove the source plugin is not active.
4. Execute one proven command.
5. Save the active generated plugin.
6. Return JSON command results.
7. Let the outer pipeline perform MO2/Mutagen readback and project verification.

Do not expand the command surface until each operation has a readback verifier.

For new native CK-owned surfaces, follow the live-proof lessons in
`../../../docs/lessons-learned-live-ckpe-proof.md`: inspect first, prove the
generated active plugin, record the proof result, then implement the smallest
mutation fixture only after allocation/ownership/save/readback surfaces are
known.

## Load Set And Active Plugin Contract

CK does not write to "whatever plugin the manifest mentions." It writes to the active plugin selected in the Data dialog. The bridge must therefore make plugin selection an explicit command and return evidence such as:

```json
{
  "activePlugin": "PDV_Phase9To12_AutoWire.esp",
  "loadedPlugins": [
    "Skyrim.esm",
    "Update.esm",
    "PlayerDevotion_Framework.esp",
    "PDV_Phase9To12_AutoWire.esp"
  ],
  "missingPlugins": [],
  "sourcePlugin": "PlayerDevotion_Framework.esp",
  "generatedPlugin": "PDV_Phase9To12_AutoWire.esp",
  "saveTarget": "PDV_Phase9To12_AutoWire.esp",
  "saveTargetMatchesActive": true
}
```

Generated-first runs require the generated plugin to be active. Promotion finalization requires the reviewed merge candidate to be active. The source plugin may be active only when a profile explicitly enables in-place authoring. Strict mode fails before any CK-semantic mutation if this evidence is absent or inconsistent.

The native `loadPluginSet` command is verification-only. A product run must
block before mutation when evidence reports a missing source plugin, missing
generated or promotion-candidate plugin, generated/candidate plugin loaded but
not active, active source plugin, intended-save-target mismatch, stale generated
or candidate name, or a CK-active master/small-master target.

Current implementation status:

- `src/ck-ipc-adapter.mjs` can send packets over
  `\\.\pipe\CreationKitAuthoringBridge` or write file-queue requests.
- `native/CreationKitAuthoringBridge` defines the authoring-only bridge,
  command packet/result schemas, named-pipe transport, and CK main-thread
  command queue.
- Lifecycle handlers now return structured CK-side evidence for bridge readiness,
  loaded-plugin lookup, already-active plugin checks, active-plugin-only save,
  active plugin inspection, close safety, and record lookup.
- Proof-only inspection handlers now expose record-creation prerequisites,
  existing-form runtime surfaces, FormID lookup round-trip evidence, and
  altered-form-list/reference-map entrypoint discovery.
- `GLOB` creation discovery has progressed from observer timing to guarded
  Object Window duplicate replay. The live Phase 52 packet used real
  right-click input on the already-verified selected row, observed CK's popup
  menu, posted CK's duplicate command `WM_COMMAND 0xF8`, and produced one
  active-plugin-owned duplicate GLOB. Phase 54 hardened that route by focusing
  the Object Window list before input replay; the live rerun created
  `PDV_GLO_ActivePietyDUPLICATE002` at FormID `0x050000C9` and resolved it as
  the expected active-plugin-owned duplicate. A fresh-session rerun created
  `PDV_GLO_ActivePietyDUPLICATE001` at FormID `0x050000C8` and reported a
  typed read-only GLOB layout candidate with FNAM `f` at `form + 0x28` and FLTV
  `0` at `form + 0x2C`. This proves the replay route and narrows payload layout,
  but it is still selection-dependent discovery until guarded payload mutation,
  save, MO2 readback, verifier proof, and proof-ledger promotion are complete.
- Phase 56 adds a guarded in-memory GLOB payload mutation proof. It is allowed
  only for an active disposable-plugin-owned GLOB with readable typed layout,
  writes FNAM/FLTV, and invokes `MarkAsChanged(true)`. It is not a support gate
  by itself because save and MO2 readback still have to prove the winning plugin
  payload. The live run changed the duplicate from FNAM `f`/FLTV `0` to FNAM
  `s`/FLTV `1`; Phase 57 saves that active proof plugin through CK's UI save
  command path. Phase 58 direct ESP readback found the saved duplicate payload
  persisted as FNAM `s` and FLTV `1`.
- Phase 59 wires those pieces into the native `duplicateCreateGlob` product
  command: guarded Object Window duplicate replay followed by guarded FNAM/FLTV
  mutation for the requested target EditorID. The packet still saves as a
  separate CK UI save command so readback can verify persistence.
- Phase 60 confirms the Phase 59 product-command output in the saved proof
  plugin: `PDV_GLO_ActivePietyDUPLICATE002` read back from disk with FNAM `s`
  and FLTV `1`.
- Phase 61 promotes that evidence through the strict proof ledger and capability
  matrix. `GLOB` is now supported only for the narrow `glob.duplicate_create`
  operation; generic `record.create` remains blocked.
- `creation-authoring` now emits product packets only for ready CK operations by
  default. Broad Phase 9-12 manifests that contain unproven `record.create`,
  VMAD, FormList, artifact, or placed-reference work return a skipped/blocked
  CK phase rather than a speculative packet. Discovery packets require the
  explicit `allowUnprovenCk` escape hatch.
- The first promotion name is `glob.duplicate_create`. It means in-process CKPE
  replay of CK's own GLOB duplicate/create command path, with generated-plugin
  guards, changed-registration, save evidence, and readback proof. It is distinct
  from external UI automation and from generic blank `createRecord` allocation.
- Generic record creation, VMAD mutation, FormList mutation, full load-set
  selection, active plugin mutation, and generated artifact commands
  intentionally return fail-closed results until a handler is implemented and
  proven through live readback.
- UI automation remains a lab diagnostic only; it is not used automatically and
  cannot satisfy `supported` capability proof.

Phase 1 proof packets:

```powershell
node .\scripts\send-ckpe-packet.mjs .\fixtures\ckpe\phase1-lifecycle.ck-command-packet.json
node .\scripts\send-ckpe-packet.mjs .\fixtures\ckpe\phase1-mutator-blockers.ck-command-packet.json --allow-blocked --expect-status UNSAFE_BLOCKED
```
