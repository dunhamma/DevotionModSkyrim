# Creation Authoring Automation

This package implements a project-agnostic authoring layer for Creation Engine mod wiring. It uses Player Devotion only as a reference pack for real-world regression cases.

## Flow

```text
Agent / MCP Client
  -> Authoring Manifest
  -> Capability Registry
  -> Resource Resolver
  -> Backend Executor
  -> Verification Oracle
  -> Report / Patch Request / Manual Packet
```

## v1 Boundaries

- JSON manifests and profiles are implemented. YAML is reserved by the schema but intentionally not loaded by the no-dependency CLI yet.
- `apply` emits a deterministic patch request that a host adapter can pass to MO2 MCP, Mutagen, or another writer.
- The CLI does not write ESP binaries directly.
- CK-only surfaces produce manual packets unless a profile advertises a future `ckpe` or `windows-ui-automation` connector.
- Verification reads a supplied readback document. An MCP wrapper should generate that readback from the active environment.
- Record creation intent is explicit: `mode` defaults to `update`, `onConflict` defaults to `fail`, and authored EditorIDs are treated as design identity.
- `generate` / `run --execute-live` are orchestration requests. Standalone Node still needs host adapters for live MO2, CK, readback, merge, and verifier actions.

## Connector Types

- `fixture`: in-repo or test records for planning and verification.
- `mo2-mcp`: host-provided MO2 MCP tools; enables MO2 patch request planning.
- `mutagen`: host-provided Mutagen writer; enables Mutagen patch request planning.
- `xedit`: future xEdit script request backend.
- `ckpe`: future native CK bridge backend.
- `windows-ui-automation`: future RPA fallback backend.

## Commands

```text
node ./src/cli.mjs plan ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json
node ./src/cli.mjs apply ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --emit-patch-request ./scratch/simple.patch-request.json
node ./src/cli.mjs verify ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --readback ./examples/simple-readback.after.json
node ./src/cli.mjs manual-packet ./examples/ck-only.manifest.json --profile ./examples/simple-project.profile.json
node ./src/cli.mjs run ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --readback ./examples/simple-readback.after.json
node ./src/cli.mjs migrate-pdv ../../references/authoring/PDV_MCMPropertyWiring.manifest.json --profile ./reference-packs/player-devotion/player-devotion.profile.json
node ./src/cli.mjs explain story_manager.node
```

## Backend Contract

Backends consume the normalized plan, not project-specific code. A host MCP server can call the library, inspect the `patchRequest`, execute it through its local writer, then pass readback data into `verify`.

The first concrete writer shape mirrors MO2 MCP `mo2_create_patch` enough to support existing-record script attachment and FormList membership.

## MCP Adapter Hook

Use `handleAuthoringRequest()` from `src/service.mjs` as the stable in-process adapter boundary:

```js
import { handleAuthoringRequest } from "./src/service.mjs";

const response = handleAuthoringRequest({
  action: "apply",
  profile,
  manifest
});
```

Supported actions are `plan`, `apply`, `ck-apply`, `run`, `verify`, `manual-packet`, `migrate-pdv`, and `explain`. The returned object is JSON-serializable.

## Full Pipeline Target

The `run` command is the orchestration boundary for the full end state:

```text
plan -> safe patch request/execution -> CK adapter execution -> compiler connector -> readback verifier -> project verifier
```

Standalone Node cannot call Codex MCP tools directly. For live writes, use `handleAuthoringRequest({ action: "run", adapters: { patchWriter, ckAdapter } })` from a host MCP server or Codex-side wrapper that owns the actual `mo2_create_patch` / CK automation functions. Without those adapters, the CLI fails closed with `REQUESTED` or `UNSAFE_BLOCKED` phases instead of pretending work was done.

`src/live-runner.mjs` is the first local host runner. It talks to the Anvil
MO2 MCP server over JSON-RPC HTTP, prepares a live fixture resolver from
`mo2_query_records` / `mo2_conflict_chain`, executes safe patch requests through
`mo2_create_patch`, collects readback through `mo2_record_detail`, calls the PDV
compiler/verifier connectors, and writes both machine run reports and human
review reports. CK packets are sent to the CKPE IPC adapter when available; if
the bridge is not running, the CK phase is fail-closed.

## Generated-First Promotion Lifecycle

Generated plugins are the default output. Source plugin mutation is a separate promotion step:

```text
manifest intent
  -> generated plugin
  -> live readback and verifier report
  -> human review of technical diff and gameplay intent
  -> promote run report
  -> timestamped backup request
  -> structured merge request
  -> CK finalization request when required
  -> post-merge verification
```

Use:

```text
node ./src/cli.mjs generate ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --strict
node ./src/cli.mjs promote ./reports/<run-report>.json --profile ./examples/simple-project.profile.json --approved
```

`promote` does not merge binaries by itself. It evaluates gates and emits machine-readable backup, structured-merge, CK-finalization, and post-merge-verification requests for a host adapter. Promotion is blocked unless the run report passed, no manual packets remain, and human approval is recorded.

The first local merge adapter lives in `../creation-merge-runner`. It is a
Mutagen-backed .NET runner that consumes `structured-merge-request.v1`, requires
explicit source/generated/output paths plus `--approved`, writes a candidate
source plugin output, and emits JSON. It is intentionally limited to proven
safe top-level record families; CK-semantic records still require the
`ck-finalization` promotion phase.

CK-semantic phases emit `creation-authoring.ck-command-packet.v1`; see
`docs/CK_BRIDGE.md`. A CK adapter must execute that packet and then let normal
live readback verify the result.

The CKPE authoring bridge scaffold lives under
`../../native/CreationKitAuthoringBridge`. It is an authoring-only tool
boundary, not a player-facing runtime dependency. The current scaffold defines
transport and result contracts; CK record mutation handlers must still be
implemented behind proof tests before CK-owned operations can pass.

## Capability Tiers

Every operation is classified so broad non-3D coverage can grow without overstating safety:

- `safe_writer`: deterministic MO2/Mutagen/xEdit creation or override is allowed.
- `ck_required`: CK must create or finalize the record.
- `generated_artifact`: CK or a proven tool must generate sidecar files such as SEQ, LIP, or FaceGen.
- `research_only`: known target, not automated until proof tests exist.
- `manual_blocked`: unsupported in the current build and not mergeable.

No non-3D record family is permanently excluded. Fragile families stay `research_only` or `ck_required` until their adapter and verifier proof exists.

## Drift Policy

Manifests are automation intent; the reviewed source plugin is accepted mod state. Future runs should compare manifest intent, generated plugin state, source plugin state, and live winning load-order state. Drift is classified as manual override, stale manifest, plugin regression, load-order conflict, or generated artifact drift. The default behavior is to stop and report, not auto-heal.
