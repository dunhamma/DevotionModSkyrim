# Creation Kit Authoring Bridge

Authoring-only CKPE bridge for `tools/creation-authoring`.

This is not a player-facing runtime dependency. Players should receive only the
normal mod artifacts: ESP/ESM/ESL files, scripts, meshes, textures, audio, and
generated sidecar files.

## Contract

The Node live runner sends `creation-authoring.ck-command-packet.v1` to the
bridge and expects `creation-authoring.ck-command-result.v1` back.

Primary transport:

```text
\\.\pipe\CreationKitAuthoringBridge
```

Debug fallback:

```text
%TEMP%\creation-kit-authoring-bridge\*.request.json
%TEMP%\creation-kit-authoring-bridge\*.result.json
```

## Current Implementation

This bridge is built against the real CKPE PluginAPI/TestPlugin shape:

- `CKPEPlugin_Version`
- `CKPEPlugin_HasDependencies`
- `CKPEPlugin_GetDependCount`
- `CKPEPlugin_GetDependAt`
- `CKPEPlugin_Load(const CKPEPluginInterface*)`

The implemented native commands are `heartbeat`, `version`/`environment`, and
`capabilities`. Mutating CK commands deliberately return `UNSAFE_BLOCKED` until
their CK object handler and MO2 readback verifier are both implemented.

## Build

The project file is:

```powershell
msbuild .\native\CreationKitAuthoringBridge\CreationKitAuthoringBridge.vcxproj /p:Configuration=Release /p:Platform=x64
```

It expects the pinned upstream CKPE source under:

```text
native/vendor/Creation-Kit-Platform-Extended
```

Build CKPE's `CKPE`, `CKPE.Common`, and `CKPE.PluginAPI` projects first so
`CKPE.lib`, `CKPE.Common.lib`, and `CKPE.PluginAPI.lib` exist under the
vendor `x64` output folder.

## Safety Rules

- Local machine only.
- One packet at a time.
- Unknown commands return `UNSUPPORTED`.
- CK-sensitive commands return `UNSAFE_BLOCKED` until implemented and proven.
- Manual packets are development diagnostics only. They are not a shippable
  authoring path.
- A command result is not final acceptance. The outer pipeline must still run
  MO2 readback and project verification.
- The bridge should not overwrite source plugins directly. It loads/saves the
  generated plugin or the reviewed merge candidate selected by the host runner.

## Initial Command Surface

- `openProject`
- `loadPlugin`
- `findRecord`
- `createRecord`
- `attachScript`
- `setProperty`
- `setArrayProperty`
- `addFormListEntry`
- `addAlias`
- `addStoryManagerNode`
- `setSharesEvent`
- `createDialogueBranch`
- `createDialogueTopic`
- `createDialogueInfo`
- `createScene`
- `placeReference`
- `savePlugin`
- `generateSeq`
- `generateLip`
- `exportFaceGen`

Dialogue/scenes, LIP, FaceGen, navmesh, cells, and worldspace-adjacent records
remain deferred until each has a verifier-backed proof.
