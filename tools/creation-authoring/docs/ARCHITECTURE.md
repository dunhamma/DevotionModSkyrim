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
  -> Report / Patch Request / Proof Ledger
```

## v1 Boundaries

- JSON manifests and profiles are implemented. YAML is reserved by the schema but intentionally not loaded by the no-dependency CLI yet.
- `apply` emits a deterministic patch request that a host adapter can pass to MO2 MCP, Mutagen, or another writer.
- The CLI does not write ESP binaries directly.
- CK-owned surfaces require a `ckpe` connector for the shippable path. Without a verified CKPE adapter they fail closed; manual packets are development diagnostics only.
- CKPE availability is not enough to make a CK-semantic operation executable. Unproven CK operations are manual/blocked by default; `allowUnprovenCk` / `--allow-unproven-ck` intentionally opens discovery mode only.
- Verification reads a supplied readback document. An MCP wrapper should generate that readback from the active environment.
- Record creation intent is explicit: `mode` defaults to `update`, `onConflict` defaults to `fail`, and authored EditorIDs are treated as design identity.
- `generate` / `run --execute-live` are orchestration requests. Standalone Node still needs host adapters for live MO2, CK, readback, merge, and verifier actions.

## Platform v1 Release Lanes

Platform v1 is an internal-tooling release, not a public SDK. The package has
two release lanes:

- Authoring Utilities: safe-writer operations for existing records, including
  script attachment, FormList entries, keyword/spell/perk/package/inventory
  adds, and conditions.
- CK Creation: CK-owned creation/finalization, currently supported only for the
  narrow `GLOB glob.duplicate_create` surface and proof-gated for `MESG`,
  `ACTI`, `FLST`, and `QUST`.

Both lanes use the same proof rule: no support claim without strict proof,
readback, verifier pass, proof ledger, and capability matrix promotion.

## Connector Types

- `fixture`: in-repo or test records for planning and verification.
- `mo2-mcp`: host-provided MO2 MCP tools; enables MO2 patch request planning.
- `mutagen`: host-provided Mutagen writer; enables Mutagen patch request planning.
- `xedit`: future xEdit script request backend.
- `ckpe`: native CK bridge backend for CK-semantic operations.
- `windows-ui-automation`: lab-only fallback; not part of the shippable green path.

## Commands

```text
node ./src/cli.mjs plan ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json
node ./src/cli.mjs apply ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --emit-patch-request ./scratch/simple.patch-request.json
node ./src/cli.mjs verify ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --readback ./examples/simple-readback.after.json
node ./src/cli.mjs manual-packet ./examples/ck-only.manifest.json --profile ./examples/simple-project.profile.json
node ./src/cli.mjs run ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --readback ./examples/simple-readback.after.json
node ./src/cli.mjs prove ./examples/simple-wiring.manifest.json --profile ./examples/simple-project.profile.json --strict --proof-output ./generated/example.proof-ledger.json
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

Supported actions are `plan`, `apply`, `ck-apply`, `run`, `verify`, `manual-packet`, `migrate-pdv`, and `explain`. The returned object is JSON-serializable. Service callers may pass `allowUnprovenCk: true` for explicit discovery plans; product callers should leave it unset.

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

Strict proof runs can write `creation-authoring.proof-ledger.v1` through
`prove --proof-output` or from an existing strict run report with
`proof-ledger <run-report> --output-file <ledger>`. The capability matrix consumes proof ledgers; a row may
be promoted to `supported` only when the ledger proves the operation, handler,
readback normalizer, verifier, fixture, and strict report.

## Readback Oracle

`src/readback-oracle.mjs` is the Phase 2 seam for live readback. It owns record lookup by EditorID/FormID/resolver output, operation/family normalizer coverage, partial-overlay detection, shared VMAD script/property normalization helpers, and read-path access used by verifier expectations.

The verifier consumes this oracle before checking operation-specific intent. If a manifest operation has no readback normalizer coverage, verification returns `TODO`; proof ledgers cannot promote that row to `supported`.

The Phase 2 oracle foundation covers VMAD scalar/object/array properties, FormLists, message buttons, quest aliases/stages, Story Manager `Shares Event`, placed reference proof surfaces, generated artifact freshness, conflict-chain expectations, and partial-overlay failure. Additional record families still need family-specific proof fixtures before they can move to `supported`.

## Reference Pack Static Gates

Project packs may define static readiness checks before live proof. The Player Devotion pack uses:

```powershell
.\scripts\check-devotion-phase9-12-static.ps1
```

That check plans the Phase 9 seed manifest, plans the Phase 9-12 combined acceptance manifest, verifies the capability matrix, and reports which operations are ready versus manually blocked. Passing this check means the pack is ready for live MO2/CKPE proof, not that all Phase 9-12 CK operations are executable.

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

`promote` evaluates gates and can delegate to the local merge adapter when `--merge-runner` and explicit source/generated/output paths are supplied. Promotion is blocked unless the run report passed, no manual packets remain, human approval is recorded, and `--merge-output-path` names a reviewed candidate plugin rather than the source or generated proof plugin.

`promotion-candidate-check` is the repo-local release-candidate dry-run proof. It forces the local merge runner into dry-run mode, verifies no source/generated/candidate output path changed, and runs a repo-local post-merge verifier that checks the candidate verification request, reviewed candidate path, dry-run merge result, and promoted operation coverage without writing plugin files.

The first local merge adapter lives in `native/CreationMergeRunner` at the repo root. It is a
Mutagen-backed .NET runner that consumes `structured-merge-request.v1`, requires
explicit source/generated/output paths plus `--approved`, writes a candidate
source plugin output, and emits JSON. It is intentionally limited to proven
safe top-level record families; CK-semantic records still require the
`ck-finalization` promotion phase.

CK-semantic phases emit `creation-authoring.ck-command-packet.v1`; see
`docs/CK_BRIDGE.md`. A CK adapter must execute that packet and then let normal
live readback verify the result.

The CKPE authoring bridge lives under `native/CreationKitAuthoringBridge` at the repo root. It is an authoring-only tool boundary, not a player-facing runtime dependency. It currently has named-pipe transport, a CK main-thread command queue, lifecycle/lookup handlers, and fail-closed mutator placeholders; CK record mutation handlers must still be implemented behind proof tests before CK-owned operations can pass.

## CK Load Set And Active Plugin

CK's active file is not implied by manifest output. The live runner must command and prove the CK Data dialog load set before any CK-semantic phase:

```text
openProject -> loadPluginSet -> CK mutations -> postUiSaveCommand -> closeSafeStatus
```

Generated-first runs require the manifest output or profile default generated plugin to be active. Promotion finalization requires the reviewed merge candidate to be active. Strict mode fails if the source plugin is active by mistake, if required masters are missing, or if the save target does not match the active plugin.

`loadPluginSet` is the atomic load-set proof command. The current bridge implementation verifies the requested load set and active save target fail-closed; it does not mutate CK Data dialog state until a safe active-file setter is proven. Legacy `loadPlugin` and `setActivePlugin` remain diagnostics.

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
