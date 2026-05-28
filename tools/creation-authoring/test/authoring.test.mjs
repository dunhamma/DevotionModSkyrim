import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  analyzeDrift,
  assertSafeMergePaths,
  buildCapabilityMatrix,
  buildCkCommandPacket,
  buildPatchRequest,
  buildPlatformProofSummary,
  buildStrictGatePhase,
  checkPromotionCandidateDryRun,
  buildProofLedgerFromRun,
  buildReviewJson,
  checkFixtureDirectory,
  createPlan,
  describeReadbackNormalizer,
  evaluatePromotionGates,
  extractCkpeRecordInventory,
  handleAuthoringRequest,
  migratePdvAuthorManifest,
  mergeProofResults,
  normalizeManifest,
  normalizeMo2RecordDetail,
  normalizeProfile,
  parseToolResult,
  promoteRunReport,
  runLocalMergeRunner,
  runPipeline,
  formatPlatformProofSummary,
  summarizePhaseStatuses,
  verifyCapabilityMatrix,
  verifyPlatformV1Evidence,
  verifyProofLedger,
  verifyManifest
} from "../src/index.mjs";
import { createCompileRunner, createReadbackCollector, prepareLiveProfile } from "../src/live-mcp-adapters.mjs";
import {
  applyExistingMessagePayloadPatch,
  rewriteMessageRecordPayload
} from "../src/esp-message-payload-writer.mjs";
import { analyzeMixedCkWriterSequence } from "../src/orchestrator.mjs";
import { flattenProofLedgerResults } from "../src/proof-ledger.mjs";

const profile = normalizeProfile({
  schema: "creation-profile.v1",
  game: "SkyrimSE",
  modId: "example-mod",
  sourcePlugin: "ExampleMod.esp",
  outputPolicy: "overlay",
  defaultOutput: "ExampleMod_AutoWire.esp",
  resourceConnectors: [
    {
      type: "fixture",
      records: {
        EXM_MainQuest: { formid: "ExampleMod.esp:000800", recordType: "QUST" },
        EXM_GLO_Debug: { formid: "ExampleMod.esp:000801", recordType: "GLOB" },
        EXM_FLST_AllServices: { formid: "ExampleMod.esp:000802", recordType: "FLST" },
        EXM_ServiceQuest: { formid: "ExampleMod.esp:000803", recordType: "QUST" }
      }
    },
    { type: "mo2-mcp" }
  ]
});

const manifest = normalizeManifest({
  schema: "creation-authoring.v1",
  project: "example-mod",
  game: "SkyrimSE",
  sourcePlugin: "ExampleMod.esp",
  output: "ExampleMod_AutoWire.esp",
  operations: [
    {
      id: "script",
      kind: "vmad.attach_script",
      target: "EXM_MainQuest",
      payload: {
        script: "EXM_MainQuestScript",
        properties: [
          { name: "DebugGlobal", type: "Object", value: "EXM_GLO_Debug" }
        ]
      }
    },
    {
      id: "list",
      kind: "formlist.add",
      target: "EXM_FLST_AllServices",
      payload: {
        entry: "EXM_ServiceQuest"
      }
    }
  ]
}, profile);

test("plans supported operations against available backends", () => {
  const plan = createPlan(manifest, profile);
  assert.equal(plan.summary.ready, 2);
  assert.equal(plan.summary.manual, 0);
  assert.equal(plan.operations[0].backend, "mo2-mcp-patch-request");
});

test("builds a deterministic patch request", () => {
  const plan = createPlan(manifest, profile);
  const patchRequest = buildPatchRequest(plan);
  assert.equal(patchRequest.output_name, "ExampleMod_AutoWire.esp");
  assert.equal(patchRequest.records.length, 2);
  assert.equal(patchRequest.records[0].formid, "ExampleMod.esp:000800");
  assert.equal(patchRequest.records[0].attach_scripts[0].properties[0].value, "ExampleMod.esp:000801");
});

test("emits manual packet for CK-only operation without CK backend", () => {
  const ckManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    operations: [
      {
        id: "sm",
        kind: "story_manager.node",
        target: "EXM_SM_KillActor",
        payload: {
          event: "Kill Actor",
          receiverQuest: "EXM__SM_KillActor",
          sharesEvent: true
        }
      }
    ]
  }, profile);

  const plan = createPlan(ckManifest, profile);
  assert.equal(plan.summary.manual, 1);
  assert.match(plan.operations[0].manualPacket.steps.join("\n"), /Story Manager/);
});

test("builds CK command packets for CK-semantic operations", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const ckManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_GeneratedCk.esp",
    operations: [
      {
        id: "sm",
        kind: "story_manager.node",
        target: "EXM_SM_KillActor",
        payload: {
          event: "Kill Actor",
          receiverQuest: "EXM__SM_KillActor",
          sharesEvent: true
        },
        verifierExpectations: [
          { type: "fieldEquals", path: "sharesEvent", value: true }
        ]
      }
    ]
  }, ckpeProfile);

  const plan = createPlan(ckManifest, ckpeProfile, { allowUnprovenCk: true });
  const packet = buildCkCommandPacket(plan);
  assert.equal(packet.schema, "creation-authoring.ck-command-packet.v1");
  assert.equal(packet.commands.some((command) => command.op === "addStoryManagerNode"), true);
  const loadPluginSet = packet.commands.find((command) => command.op === "loadPluginSet");
  assert.equal(loadPluginSet.activePlugin, "ExampleMod_GeneratedCk.esp");
  assert.equal(loadPluginSet.intendedSaveTarget, "ExampleMod_GeneratedCk.esp");
  assert.deepEqual(loadPluginSet.requiredPlugins, ["ExampleMod.esp", "ExampleMod_GeneratedCk.esp"]);
  assert.deepEqual(loadPluginSet.plugins, [
    { name: "ExampleMod.esp", selected: true, active: false },
    { name: "ExampleMod_GeneratedCk.esp", selected: true, active: true }
  ]);
  assert.equal(loadPluginSet.sourcePluginNotActive, true);
  assert.equal(packet.commands.some((command) => command.op === "loadPlugin"), false);
  assert.equal(packet.commands.some((command) => command.op === "setActivePlugin"), false);
  assert.equal(packet.commands.at(-2).op, "postUiSaveCommand");
  assert.equal(packet.commands.at(-1).op, "closeSafeStatus");
  assert.equal(packet.verifierExpectations.length, 1);
});

test("loadPluginSet preserves operation-level required plugins", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const ckManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_GeneratedCk.esp",
    operations: [
      {
        id: "create-message",
        kind: "record.create",
        target: "EXM_MSG_New",
        recordFamily: "MESG",
        mastersExpected: ["Update.esm"],
        payload: {
          recordType: "MESG",
          requiredPlugins: ["Dawnguard.esm", "ExampleMod.esp"]
        },
        ckSemanticsRequired: true
      }
    ]
  }, ckpeProfile);

  const plan = createPlan(ckManifest, ckpeProfile, { allowUnprovenCk: true });
  const packet = buildCkCommandPacket(plan);
  const loadPluginSet = packet.commands.find((command) => command.op === "loadPluginSet");

  assert.deepEqual(loadPluginSet.requiredPlugins, [
    "ExampleMod.esp",
    "ExampleMod_GeneratedCk.esp",
    "Update.esm",
    "Dawnguard.esm"
  ]);
  assert.equal(loadPluginSet.plugins.filter((plugin) => plugin.active).length, 1);
  assert.equal(loadPluginSet.plugins.find((plugin) => plugin.name === "ExampleMod_GeneratedCk.esp").active, true);
});

test("loadPluginSet product fixtures cover success and blocked runtime evidence", () => {
  const readyFixture = JSON.parse(fs.readFileSync(
    "fixtures/ckpe/load-plugin-set-product-ready.ck-command-packet.json",
    "utf8"
  ));
  const readyOps = readyFixture.commands.map((command) => command.op);
  const readyLoadSet = readyFixture.commands.find((command) => command.op === "loadPluginSet");

  assert.equal(readyOps.includes("loadPlugin"), false);
  assert.equal(readyOps.includes("setActivePlugin"), false);
  assert.equal(readyLoadSet.sourcePlugin, "ExampleMod.esp");
  assert.equal(readyLoadSet.generatedPlugin, "ExampleMod_GeneratedCk.esp");
  assert.equal(readyLoadSet.activePlugin, "ExampleMod_GeneratedCk.esp");
  assert.equal(readyLoadSet.intendedSaveTarget, "ExampleMod_GeneratedCk.esp");
  assert.equal(readyLoadSet.sourcePluginNotActive, true);
  assert.deepEqual(readyLoadSet.requiredPlugins, ["Skyrim.esm", "ExampleMod.esp", "ExampleMod_GeneratedCk.esp"]);

  const blockedFixture = JSON.parse(fs.readFileSync(
    "fixtures/ckpe/load-plugin-set-blocked-cases.ck-command-packet.json",
    "utf8"
  ));
  assert.equal(blockedFixture.commands.every((command) => command.op === "loadPluginSet"), true);
  assert.deepEqual(
    blockedFixture.commands.map((command) => command.expectedBlocker),
    [
      "missing_source_plugin",
      "missing_generated_or_candidate_plugin",
      "generated_or_candidate_plugin_not_active",
      "source_plugin_active",
      "intended_save_target_mismatch",
      "active_target_not_normal_writable_esp"
    ]
  );
});

test("blocks create conflicts unless manifest declares update or rename", () => {
  const createManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    operations: [
      {
        id: "create-existing",
        kind: "record.create",
        target: "EXM_MainQuest",
        mode: "create",
        onConflict: "fail",
        payload: { recordType: "QUST" }
      }
    ]
  }, profile);

  const plan = createPlan(createManifest, profile);
  assert.equal(plan.summary.abort, 1);
  assert.match(plan.operations[0].manualPacket.reason, /Authored EditorIDs are design identity/);
});

test("blocks unproven CK record creation and dependent wiring by default", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const createManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "create-quest",
        kind: "quest.create",
        target: "EXM_NewQuest",
        mode: "create",
        recordFamily: "QUST",
        ckSemanticsRequired: true,
        payload: { recordType: "QUST", startGameEnabled: false }
      },
      {
        id: "wire-new-quest",
        kind: "vmad.attach_script",
        target: "EXM_NewQuest",
        payload: {
          script: "EXM_NewQuestScript",
          properties: [{ name: "DebugGlobal", type: "Object", value: "EXM_GLO_Debug" }]
        }
      }
    ]
  }, ckpeProfile);

  const plan = createPlan(createManifest, ckpeProfile);
  assert.equal(plan.summary.ready, 0);
  assert.equal(plan.summary.manual, 2);
  assert.equal(plan.operations[0].backend, "manual-packet");
  assert.equal(plan.operations[1].backend, "manual-packet");
  assert.equal(plan.operations[0].targetResolution.plannedCreate, true);
});

test("can route unproven CK record creation through CKPE for explicit discovery", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const createManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "create-quest",
        kind: "quest.create",
        target: "EXM_NewQuest",
        mode: "create",
        recordFamily: "QUST",
        ckSemanticsRequired: true,
        payload: { recordType: "QUST", startGameEnabled: false }
      },
      {
        id: "wire-new-quest",
        kind: "vmad.attach_script",
        target: "EXM_NewQuest",
        payload: {
          script: "EXM_NewQuestScript",
          properties: [{ name: "DebugGlobal", type: "Object", value: "EXM_GLO_Debug" }]
        }
      }
    ]
  }, ckpeProfile);

  const plan = createPlan(createManifest, ckpeProfile, { allowUnprovenCk: true });
  assert.equal(plan.summary.ready, 2);
  assert.equal(plan.operations[0].backend, "ckpe-bridge");
  assert.equal(plan.operations[1].backend, "ckpe-bridge");

  const servicePlan = handleAuthoringRequest({
    action: "plan",
    profile: ckpeProfile,
    manifest: createManifest,
    allowUnprovenCk: true
  });
  assert.equal(servicePlan.summary.ready, 2);
});

test("builds CKPE packets for record creation and VMAD arrays", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const createManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "create-message",
        kind: "record.create",
        target: "EXM_Message",
        mode: "create",
        recordFamily: "MESG",
        ckSemanticsRequired: true,
        payload: { recordType: "MESG", text: "Example" }
      },
      {
        id: "array",
        kind: "vmad.set_array_property",
        target: "EXM_MainQuest",
        ckSemanticsRequired: true,
        payload: { script: "EXM_MainQuestScript", property: "Services", type: "Object", values: ["EXM_ServiceQuest"] }
      }
    ]
  }, ckpeProfile);

  const packet = buildCkCommandPacket(createPlan(createManifest, ckpeProfile, { allowUnprovenCk: true }));
  const createRecord = packet.commands.find((command) => command.op === "createRecord");
  assert.equal(createRecord.plugin, "ExampleMod_Generated.esp");
  assert.equal(createRecord.recordFamily, "MESG");
  assert.equal(packet.commands.some((command) => command.op === "setArrayProperty"), true);
});

test("live compile runner uses current node executable without PATH lookup", async () => {
  const runner = createCompileRunner(process.cwd(), ["-e", "process.stdout.write('ok')"], {
    cwd: process.cwd()
  });
  const originalPath = process.env.PATH;
  process.env.PATH = "";
  try {
    const result = await runner();
    assert.equal(result.status, "PASS");
    assert.equal(result.stdout, "ok");
  } finally {
    process.env.PATH = originalPath;
  }
});

test("live profile preparation reports MO2 MCP outages as preflight failures", async () => {
  const result = await prepareLiveProfile(manifest, profile, {
    mcp: {
      async callTool() {
        throw new TypeError("fetch failed");
      }
    }
  });
  assert.equal(result.profile, profile);
  assert.equal(result.preflight.length, 1);
  assert.equal(result.preflight[0].phase, "mo2-ping");
  assert.equal(result.preflight[0].status, "FAIL");
  assert.match(result.preflight[0].error.message, /fetch failed/);
});

test("builds explicit CKPE packet fields for GLOB duplicate-create", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const globManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "duplicate-global",
        kind: "glob.duplicate_create",
        target: "EXM_GLO_DebugDUPLICATE001",
        mode: "create",
        ckSemanticsRequired: true,
        payload: {
          sourceEditorId: "EXM_GLO_Debug",
          targetEditorId: "EXM_GLO_DebugDUPLICATE001",
          type: "short",
          value: 1
        }
      }
    ]
  }, ckpeProfile);

  const packet = buildCkCommandPacket(createPlan(globManifest, ckpeProfile));
  const command = packet.commands.find((item) => item.op === "duplicateCreateGlob");
  assert.equal(packet.commands.some((item) => item.op === "loadPluginSet" && item.activePlugin === "ExampleMod_Generated.esp"), true);
  assert.equal(packet.commands.at(-2).op, "postUiSaveCommand");
  assert.equal(packet.commands.at(-2).plugin, "ExampleMod_Generated.esp");
  assert.equal(packet.commands.at(-1).op, "closeSafeStatus");
  assert.equal(command.plugin, "ExampleMod_Generated.esp");
  assert.equal(command.sourceEditorId, "EXM_GLO_Debug");
  assert.equal(command.target, "EXM_GLO_DebugDUPLICATE001");
  assert.equal(command.targetEditorId, "EXM_GLO_DebugDUPLICATE001");
  assert.equal(command.recordFamily, "GLOB");
  assert.equal(command.mode, "input_context_focus_async_command");
  assert.equal(command.valueType, "short");
  assert.equal(command.value, 1);
});

test("builds CKPE packet fields for family duplicate-create", () => {
  const ckpeProfile = normalizeProfile({
    ...profile,
    resourceConnectors: [
      ...profile.resourceConnectors,
      { type: "ckpe", transport: "named-pipe", pipe: "\\\\.\\pipe\\CreationKitAuthoringBridge" }
    ]
  });
  const manifestWithDuplicate = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "duplicate-message",
        kind: "record.duplicate_create",
        target: "EXM_MessageDUPLICATE001",
        recordFamily: "MESG",
        mode: "create",
        ckSemanticsRequired: true,
        payload: {
          sourceEditorId: "EXM_Message",
          targetEditorId: "EXM_MessageDUPLICATE001"
        }
      }
    ]
  }, ckpeProfile);

  const packet = buildCkCommandPacket(createPlan(manifestWithDuplicate, ckpeProfile));
  const command = packet.commands.find((item) => item.op === "duplicateCreateRecord");
  assert.equal(command.plugin, "ExampleMod_Generated.esp");
  assert.equal(command.sourceEditorId, "EXM_Message");
  assert.equal(command.target, "EXM_MessageDUPLICATE001");
  assert.equal(command.targetEditorId, "EXM_MessageDUPLICATE001");
  assert.equal(command.createdEditorId, "EXM_MessageDUPLICATE001");
  assert.equal(command.recordFamily, "MESG");
  assert.equal(command.mode, "input_context_focus_async_command");
});

test("PDV Phase 9/12 manifest does not emit unproven CK commands by default", async () => {
  const pdvProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "reference-packs/player-devotion/player-devotion-phase9-12.profile.json",
    "utf8"
  )));
  const pdvManifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "reference-packs/player-devotion/manifests/PDV_Phase9To12_Acceptance.creation-authoring.json",
    "utf8"
  )), pdvProfile);

  const plan = createPlan(pdvManifest, pdvProfile);
  assert.equal(plan.summary.total, 31);
  assert.equal(plan.summary.ready, 3);
  assert.equal(plan.summary.manual, 28);
  assert.equal(plan.operations.filter((item) => item.operation.kind === "record.create").every((item) => item.status === "manual"), true);

  const ckApply = await handleAuthoringRequest({
    action: "ck-apply",
    profile: pdvProfile,
    manifest: pdvManifest
  });
  assert.equal(ckApply.status, "SKIPPED");
});

test("surfaces capability tiers in plans", () => {
  const plan = createPlan(manifest, profile);
  assert.equal(plan.operations[0].capabilityTier, "safe_writer");
  assert.equal(plan.operations[1].capability.tier, "safe_writer");
});

test("verifies script wiring and FormList membership from readback", () => {
  const report = verifyManifest(manifest, profile, {
    records: {
      EXM_MainQuest: {
        scripts: [
          {
            name: "EXM_MainQuestScript",
            properties: {
              DebugGlobal: "EXM_GLO_Debug"
            }
          }
        ]
      },
      EXM_FLST_AllServices: {
        entries: ["EXM_ServiceQuest"]
      }
    }
  });

  assert.equal(report.summary.PASS, 2);
  assert.equal(report.summary.FAIL, 0);
});

test("detects duplicate VMAD script attachments", () => {
  const report = verifyManifest(manifest, profile, {
    records: {
      EXM_MainQuest: {
        scripts: [
          { name: "EXM_MainQuestScript", properties: { DebugGlobal: "EXM_GLO_Debug" } },
          { name: "EXM_MainQuestScript", properties: { DebugGlobal: "EXM_GLO_Debug" } }
        ]
      },
      EXM_FLST_AllServices: {
        entries: ["EXM_ServiceQuest"]
      }
    }
  });

  assert.equal(report.summary.FAIL, 1);
  assert.match(report.results[0].message, /attached 2 times/);
});

test("handles service-style MCP adapter requests", () => {
  const response = handleAuthoringRequest({
    action: "apply",
    profile,
    manifest
  });

  assert.equal(response.schema, "creation-authoring.apply-request.v1");
  assert.equal(response.patchRequest.records.length, 2);
});

test("runs full pipeline with host patch adapter and readback", async () => {
  const writes = [];
  const report = await runPipeline(manifest, profile, {
    patchWriter: async (patchRequest) => {
      writes.push(patchRequest);
      return { output: patchRequest.output_name };
    },
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: {
                DebugGlobal: "EXM_GLO_Debug"
              }
            }
          ]
        },
        EXM_FLST_AllServices: {
          entries: ["EXM_ServiceQuest"]
        }
      }
    }
  });

  assert.equal(writes.length, 1);
  assert.equal(report.status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "apply").status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "verify").status, "PASS");
});

test("pipeline can prove an already-applied generated patch from writer evidence", async () => {
  const report = await runPipeline(manifest, profile, {
    strict: true,
    appliedPatchEvidence: {
      success: true,
      output_path: "D:/Wabbajack/modlists/Anvil/mods/Devotion/ExampleMod_AutoWire.esp",
      records_written: 2
    },
    readback: {
      records: {
        EXM_MainQuest: {
          winningPlugin: "ExampleMod_AutoWire.esp",
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: {
          winningPlugin: "ExampleMod_AutoWire.esp",
          entries: ["EXM_ServiceQuest"]
        }
      }
    }
  });

  assert.equal(report.status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "apply").status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "strict-gate").status, "PASS");
});

test("pipeline fails when host patch adapter does not complete safely", async () => {
  const report = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async () => ({
      status: "REQUESTED",
      message: "Writer backend is not connected."
    }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: {
                DebugGlobal: "EXM_GLO_Debug"
              }
            }
          ]
        },
        EXM_FLST_AllServices: {
          entries: ["EXM_ServiceQuest"]
        }
      }
    }
  });

  assert.equal(report.status, "FAIL");
  assert.equal(report.phases.find((phase) => phase.phase === "apply").status, "REQUESTED");
  assert.equal(report.phases.find((phase) => phase.phase === "strict-gate").status, "FAIL");
});

test("strict live run requests readback collector when no adapter is configured", async () => {
  const report = await runPipeline(manifest, profile, {
    executeLive: true,
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name })
  });

  assert.equal(report.status, "FAIL");
  assert.equal(report.phases.find((phase) => phase.phase === "readback-collect").status, "REQUESTED");
  assert.equal(report.phases.find((phase) => phase.phase === "strict-gate").status, "FAIL");
});

test("mixed payload proof runs CK duplicate before payload writer", async () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/payload-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/payload-v1.readback.json",
    "utf8"
  ));
  const messageManifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/mesg-duplicate-payload.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  const order = [];
  const report = await runPipeline(messageManifest, fixtureProfile, {
    strict: true,
    readback: fixtureReadback,
    ckAdapter: async () => {
      order.push("ck");
      return { status: "PASS" };
    },
    patchWriter: async (patchRequest) => {
      order.push("payload");
      return { status: "PASS", output_name: patchRequest.output_name };
    }
  });

  assert.deepEqual(order, ["ck", "payload"]);
  assert.equal(report.status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "apply").status, "SKIPPED");
  assert.equal(report.phases.find((phase) => phase.phase === "ck-apply").status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "post-ck-identity-gate").status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "payload-apply").status, "PASS");
  assert.equal(report.phases.findIndex((phase) => phase.phase === "ck-apply") < report.phases.findIndex((phase) => phase.phase === "payload-apply"), true);
});

test("mixed payload proof blocks writer when post-CK identity is missing", async () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/payload-v1.profile.json",
    "utf8"
  )));
  const messageManifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/mesg-duplicate-payload.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  let payloadWriterCalled = false;
  const report = await runPipeline(messageManifest, fixtureProfile, {
    strict: true,
    readback: { records: {} },
    ckAdapter: async () => ({ status: "PASS" }),
    patchWriter: async () => {
      payloadWriterCalled = true;
      return { status: "PASS" };
    }
  });

  assert.equal(payloadWriterCalled, false);
  assert.equal(report.status, "FAIL");
  assert.equal(report.phases.find((phase) => phase.phase === "post-ck-identity-gate").status, "TODO");
  assert.equal(report.phases.find((phase) => phase.phase === "payload-apply").status, "UNSAFE_BLOCKED");
});

test("finalize sequencing preserves a completed CK duplicate identity", () => {
  const plan = {
    operations: [
      {
        status: "abort",
        operation: {
          id: "duplicate-message-shell",
          kind: "record.duplicate_create",
          target: "_HelpPipBoyItemsDUPLICATE002"
        },
        backend: "ckpe-bridge"
      },
      {
        status: "ready",
        operation: {
          id: "set-message-payload",
          kind: "message.payload.set",
          target: "_HelpPipBoyItemsDUPLICATE002"
        },
        backend: "mo2-mcp-patch-request"
      }
    ]
  };

  const sequencing = analyzeMixedCkWriterSequence(plan, {
    completedIdentityTargets: ["_HelpPipBoyItemsDUPLICATE002"]
  });

  assert.deepEqual([...sequencing.identityOperationIds], ["duplicate-message-shell"]);
  assert.deepEqual([...sequencing.delayedWriterOperationIds], ["set-message-payload"]);
});

test("MO2 readback collector attaches conflict chain to normalized records", async () => {
  const collector = createReadbackCollector({
    conflictCache: new Map(),
    mcp: {
      async callTool(name, args) {
        if (name === "mo2_record_detail") {
          assert.equal(args.editor_id, "_HelpPipBoyItemsDUPLICATE002");
          return {
            formid: "PDV_Phase9To12_CKProof.esp:00182A",
            record_type: "MESSAGE",
            editor_id: "_HelpPipBoyItemsDUPLICATE002",
            plugin: "PDV_Phase9To12_CKProof.esp",
            fields: {
              EditorID: "_HelpPipBoyItemsDUPLICATE002",
              MenuButtons: [{ Text: "Accept" }]
            }
          };
        }
        if (name === "mo2_conflict_chain") {
          assert.equal(args.editor_id, "_HelpPipBoyItemsDUPLICATE002");
          return {
            chain_length: 1,
            winner: "PDV_Phase9To12_CKProof.esp",
            chain: [{ plugin: "PDV_Phase9To12_CKProof.esp", is_winner: true }]
          };
        }
        throw new Error(`unexpected tool ${name}`);
      }
    }
  });
  const readback = await collector({
    manifest: {
      operations: [
        {
          id: "set-message-payload",
          kind: "message.payload.set",
          target: "_HelpPipBoyItemsDUPLICATE002"
        }
      ]
    },
    plan: {
      operations: [
        {
          operation: {
            id: "set-message-payload",
            kind: "message.payload.set",
            target: "_HelpPipBoyItemsDUPLICATE002"
          },
          targetResolution: {}
        }
      ]
    },
    phases: [
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: [
            {
              op: "duplicateCreateRecord",
              status: "PASS",
              evidence: {
                requested: {
                  targetEditorId: "_HelpPipBoyItemsDUPLICATE002",
                  sourceEditorId: "_HelpPipBoyItems"
                }
              }
            }
          ]
        }
      }
    ]
  });

  const record = readback.records._HelpPipBoyItemsDUPLICATE002;
  assert.equal(record.recordType, "MESG");
  assert.equal(record.winningPlugin, "PDV_Phase9To12_CKProof.esp");
  assert.equal(record.createdFrom.editorId, "_HelpPipBoyItems");
  assert.equal(record.conflictChain.length, 1);
  assert.equal(record.conflictChain[0].plugin, "PDV_Phase9To12_CKProof.esp");
  assert.equal(record.message.buttons[0].text, "Accept");
});

test("MESG payload writer rewrites title text and buttons while preserving core fields", () => {
  const payload = Buffer.concat([
    testSubrecord("EDID", "_HelpPipBoyItemsDUPLICATE002"),
    testSubrecord("DESC", ""),
    testBinarySubrecord("INAM", Buffer.alloc(4)),
    testBinarySubrecord("DNAM", Buffer.from([1, 0, 0, 0]))
  ]);

  const rewritten = rewriteMessageRecordPayload(payload, {
    title: "CKRA Payload Proof",
    text: "MESG payload proof body",
    buttons: [{ text: "Accept" }]
  });
  const fields = parseTestSubrecords(rewritten);

  assert.equal(fields.EDID[0], "_HelpPipBoyItemsDUPLICATE002");
  assert.equal(fields.FULL[0], "CKRA Payload Proof");
  assert.equal(fields.DESC[0], "MESG payload proof body");
  assert.equal(fields.ITXT[0], "Accept");
  assert.equal(fields.INAM[0].length, 4);
  assert.equal(fields.DNAM[0].readUInt32LE(0), 1);
});

test("existing MESG payload patch updates a generated ESP and records a backup", () => {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "ckra-mesg-payload-"));
  const pluginPath = path.join(tempRoot, "ExampleGenerated.esp");
  const backupRoot = path.join(tempRoot, "backups");
  fs.writeFileSync(pluginPath, testEspWithMessage({
    formId: 0x0400182a,
    editorId: "EXM_MessageDUPLICATE001"
  }));

  const result = applyExistingMessagePayloadPatch({
    output_name: "ExampleGenerated.esp",
    records: [
      {
        op: "override",
        formid: "ExampleGenerated.esp:00182A",
        set_message_payload: {
          title: "Payload title",
          text: "Payload body",
          buttons: [{ text: "Accept" }]
        }
      }
    ]
  }, {
    existingPath: pluginPath,
    backupRoot
  });

  assert.equal(result.status, "PASS");
  assert.equal(fs.existsSync(result.backup_path), true);
  const updated = fs.readFileSync(pluginPath);
  assert.equal(updated.subarray(0, 4).toString("ascii"), "TES4");
  const groupOffset = 24 + updated.readUInt32LE(4);
  assert.equal(updated.readUInt32LE(groupOffset + 4), updated.length - groupOffset);
  const recordOffset = groupOffset + 24;
  const recordSize = updated.readUInt32LE(recordOffset + 4);
  const fields = parseTestSubrecords(updated.subarray(recordOffset + 24, recordOffset + 24 + recordSize));
  assert.equal(fields.EDID[0], "EXM_MessageDUPLICATE001");
  assert.equal(fields.FULL[0], "Payload title");
  assert.equal(fields.DESC[0], "Payload body");
  assert.equal(fields.ITXT[0], "Accept");
});

test("collects live readback through a host adapter", async () => {
  const report = await runPipeline(manifest, profile, {
    executeLive: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readbackCollector: async () => ({
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    })
  });

  assert.equal(report.status, "PASS");
  assert.equal(report.phases.find((phase) => phase.phase === "readback-collect").status, "PASS");
});

test("blocks CK-only run unless manual packets are allowed or CK adapter exists", async () => {
  const ckManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    operations: [
      {
        id: "sm",
        kind: "story_manager.node",
        target: "EXM_SM_KillActor",
        payload: {
          event: "Kill Actor"
        }
      }
    ]
  }, profile);

  const report = await runPipeline(ckManifest, profile);
  assert.equal(report.status, "FAIL");
  assert.equal(report.phases[1].status, "UNSAFE_BLOCKED");
});

test("strict mode fails manual packets even when packet output is explicitly allowed", async () => {
  const ckManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    operations: [
      {
        id: "sm",
        kind: "story_manager.node",
        target: "EXM_SM_KillActor",
        payload: { event: "Kill Actor" }
      }
    ]
  }, profile);

  const report = await runPipeline(ckManifest, profile, {
    allowManualPackets: true,
    strict: true,
    readback: { records: {} }
  });

  assert.equal(report.status, "FAIL");
  assert.equal(report.phases.find((phase) => phase.phase === "strict-gate").status, "FAIL");
  assert.equal(report.phases.find((phase) => phase.phase === "strict-gate").blockers.some((blocker) => blocker.phase === "manual-packet"), true);
});

test("migrates PDV author manifests into generic operations", () => {
  const migrated = migratePdvAuthorManifest({
    id: "mcm-property-wiring",
    defaultOutput: "PDV_PropertyWiringOverlay.esp",
    operations: [
      {
        kind: "setProperty",
        record: "PDV_MCM",
        script: "PDV_MCM",
        property: "PDV_Manager",
        valueType: "Object",
        value: "PDV__ManagerQuest"
      },
      {
        kind: "setProperty",
        record: "PDV_MCM",
        script: "PDV_MCM",
        property: "PDV_GLO_DebugLevel",
        valueType: "Object",
        value: "PDV_GLO_DebugLevel"
      }
    ]
  }, {
    modId: "player-devotion-reference",
    game: "SkyrimSE",
    sourcePlugin: "PlayerDevotion_Framework.esp",
    defaultOutput: "PDV_AutoWireReference.esp"
  });

  assert.equal(migrated.schema, "creation-authoring.v1");
  assert.equal(migrated.operations.length, 1);
  assert.equal(migrated.operations[0].kind, "vmad.attach_script");
  assert.equal(migrated.operations[0].payload.properties.length, 2);
});

test("normalizes MO2 record detail VMAD readback", () => {
  const readback = normalizeMo2RecordDetail({
    formid: "ExampleMod.esp:000800",
    record_type: "QUST",
    fields: {
      EditorID: "EXM_MainQuest",
      VirtualMachineAdapter: {
        Scripts: [
          {
            Name: "EXM_MainQuestScript",
            Properties: [
              {
                Name: "DebugGlobal",
                Object: "ExampleMod.esp:000801 (EXM_GLO_Debug)"
              }
            ]
          }
        ]
      }
    }
  });

  assert.equal(readback.records.EXM_MainQuest.scripts[0].name, "EXM_MainQuestScript");
  assert.equal(readback.records.EXM_MainQuest.scripts[0].properties.DebugGlobal, "ExampleMod.esp:000801 (EXM_GLO_Debug)");
});

test("verifies GLOB duplicate-create identity and payload from readback", () => {
  const globManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "duplicate-global",
        kind: "record.create",
        target: "EXM_GLO_Debug",
        mode: "create",
        recordFamily: "GLOB",
        ckSemanticsRequired: true,
        payload: {
          recordType: "GLOB",
          source: { editorId: "EXM_GLO_Debug", formid: "ExampleMod.esp:000801" },
          created: { editorId: "EXM_GLO_Debug_Copy0001", formid: "ExampleMod_Generated.esp:000D62" },
          type: "Float",
          value: 2.5
        }
      }
    ]
  }, profile);

  const report = verifyManifest(globManifest, profile, {
    records: {
      EXM_GLO_Debug_Copy0001: {
        editorId: "EXM_GLO_Debug_Copy0001",
        formid: "ExampleMod_Generated.esp:000D62",
        recordType: "GLOB",
        winningPlugin: "ExampleMod_Generated.esp",
        source: { editorId: "EXM_GLO_Debug", formid: "ExampleMod.esp:000801" },
        fields: {
          FNAM: "Float",
          FLTV: 2.5
        }
      }
    }
  });

  assert.equal(report.summary.PASS, 1);
  assert.equal(report.summary.FAIL, 0);
  assert.equal(report.results[0].details.global.value, 2.5);
});

test("verifies first-class glob.duplicate_create identity and payload from readback", () => {
  const globManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "duplicate-global",
        kind: "glob.duplicate_create",
        target: "EXM_GLO_DebugDUPLICATE001",
        mode: "create",
        ckSemanticsRequired: true,
        payload: {
          sourceEditorId: "EXM_GLO_Debug",
          sourceFormid: "ExampleMod.esp:000801",
          targetEditorId: "EXM_GLO_DebugDUPLICATE001",
          created: { editorId: "EXM_GLO_DebugDUPLICATE001", formid: "ExampleMod_Generated.esp:000D62" },
          type: "short",
          value: 1
        }
      }
    ]
  }, profile);

  const report = verifyManifest(globManifest, profile, {
    records: {
      EXM_GLO_DebugDUPLICATE001: {
        editorId: "EXM_GLO_DebugDUPLICATE001",
        formid: "ExampleMod_Generated.esp:000D62",
        recordType: "GLOB",
        winningPlugin: "ExampleMod_Generated.esp",
        source: { editorId: "EXM_GLO_Debug", formid: "ExampleMod.esp:000801" },
        global: {
          type: "short",
          value: 1
        }
      }
    }
  });

  assert.equal(report.summary.PASS, 1);
  assert.equal(report.summary.FAIL, 0);
  assert.equal(report.results[0].details.created.editorId, "EXM_GLO_DebugDUPLICATE001");
});

test("fails strict GLOB duplicate-create proof for missing winner or wrong evidence", () => {
  const globManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_Generated.esp",
    operations: [
      {
        id: "duplicate-global",
        kind: "record.create",
        target: "EXM_GLO_Debug",
        mode: "create",
        recordFamily: "GLOB",
        ckSemanticsRequired: true,
        payload: {
          recordType: "GLOB",
          source: { editorId: "EXM_GLO_Debug", formid: "ExampleMod.esp:000801" },
          created: { editorId: "EXM_GLO_Debug_Copy0001", formid: "ExampleMod_Generated.esp:000D62" },
          type: "Float",
          value: 2.5
        }
      }
    ]
  }, profile);
  const validRecord = {
    editorId: "EXM_GLO_Debug_Copy0001",
    formid: "ExampleMod_Generated.esp:000D62",
    recordType: "GLOB",
    winningPlugin: "ExampleMod_Generated.esp",
    source: { editorId: "EXM_GLO_Debug", formid: "ExampleMod.esp:000801" },
    fields: {
      FNAM: "Float",
      FLTV: 2.5
    }
  };

  const cases = [
    ["missing winner", { ...validRecord, winningPlugin: null }],
    ["wrong plugin", { ...validRecord, winningPlugin: "ExampleMod.esp" }],
    ["partial overlay", { ...validRecord, partialOverlay: true, missingFields: ["FLTV"] }],
    ["wrong FormID", { ...validRecord, formid: "ExampleMod_Generated.esp:000D63" }],
    ["missing source evidence", { ...validRecord, source: null }],
    ["wrong payload", { ...validRecord, fields: { FNAM: "Float", FLTV: 1 } }]
  ];

  for (const [name, record] of cases) {
    const report = verifyManifest(globManifest, profile, {
      records: {
        EXM_GLO_Debug_Copy0001: record
      }
    });
    assert.equal(report.results[0].status, "FAIL", name);
  }
});

test("rejects Phase22-31 GLOB discovery probes as save/readback proof", () => {
  const globManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_GeneratedCk.esp",
    operations: [
      {
        id: "glob-phase22-31-discovery",
        kind: "record.create",
        target: "EXM_GLO_PhaseDiscovery",
        mode: "create",
        recordFamily: "GLOB",
        ckSemanticsRequired: true,
        payload: { recordType: "GLOB" },
        verifierExpectations: [
          { type: "recordIdentity", editorId: "EXM_GLO_PhaseDiscovery", formid: "ExampleMod_GeneratedCk.esp:000D69" },
          { type: "winningPlugin", value: "ExampleMod_GeneratedCk.esp" },
          { type: "conflictChainIncludes", values: ["ExampleMod.esp", "ExampleMod_GeneratedCk.esp"] },
          { type: "noPartialOverlay" }
        ]
      }
    ]
  }, profile);
  const discoveryCases = [
    { proofSurface: "factory-0x141627e60", factoryReturnOnly: true },
    { proofSurface: "wrapper-0x14169c520", wrapperReturnOnly: true },
    { proofSurface: "source-probe", sourceProbeOnly: true },
    { proofSurface: "selector-probe", selectorProbeOnly: true },
    { proofSurface: "guard-probe", guardProbeOnly: true },
    { proofSurface: "existing-glob-return", existingRecordReturnOnly: true },
    { proofSurface: "template-record-return", templateRecordReturnOnly: true },
    { proofSurface: "boolean-return", booleanReturnOnly: true },
    { proofSurface: "no-capture", noCaptureOnly: true },
    {
      proofSurface: "post-allocation-0x141618120",
      postAllocationCandidateOnly: true,
      candidate: { address: "0x141618120", argumentRegister: "rdx", receivedRecordType: "GLOB" }
    },
    { proofSurface: "phase36-missed", missedCaptureOnly: true },
    { proofSurface: "phase37-missed", missedCaptureOnly: true }
  ];

  for (const evidence of discoveryCases) {
    const report = verifyManifest(globManifest, profile, {
      records: {
        EXM_GLO_PhaseDiscovery: {
          editorId: "EXM_GLO_PhaseDiscovery",
          formid: "ExampleMod_GeneratedCk.esp:000D69",
          recordType: "GLOB",
          winningPlugin: "ExampleMod_GeneratedCk.esp",
          conflictChain: ["ExampleMod.esp", "ExampleMod_GeneratedCk.esp"],
          overlayComplete: true,
          ...evidence
        }
      }
    });

    assert.equal(report.results[0].status, "TODO", evidence.proofSurface);
    assert.match(report.results[0].message, /discovery-phase evidence/, evidence.proofSurface);
  }
});

test("parses MCP text tool results as JSON", () => {
  const parsed = parseToolResult({
    content: [
      {
        type: "text",
        text: "{\"status\":\"ok\",\"profile\":\"Devotion Dev\"}"
      }
    ],
    isError: false
  });

  assert.equal(parsed.status, "ok");
  assert.equal(parsed.profile, "Devotion Dev");
});

test("blocks promotion until run report is passing and approved", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });

  assert.equal(runReport.status, "PASS");
  assert.equal(evaluatePromotionGates(runReport, profile).ready, false);

  const promotion = await promoteRunReport(runReport, profile, { approved: true });
  assert.equal(promotion.status, "FAIL");
  assert.equal(promotion.phases[0].status, "UNSAFE_BLOCKED");
  assert.equal(promotion.phases[0].gates.blockers.some((blocker) => /candidate output/.test(blocker)), true);
});

test("promotion can delegate backup and structured merge to a merge runner", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });

  let receivedMergeRequest = null;
  const promotion = await promoteRunReport(runReport, profile, {
    approved: true,
    mergeOutputPath: "ExampleMod_PromotionCandidate.esp",
    backupRunner: async () => ({ status: "DEFERRED_TO_MERGE_RUNNER" }),
    mergeRunner: async (mergeRequest) => {
      receivedMergeRequest = mergeRequest;
      return { status: "PASS", recordsMerged: mergeRequest.operations.length };
    }
  });

  assert.equal(promotion.phases.find((phase) => phase.phase === "backup").status, "PASS");
  assert.equal(promotion.phases.find((phase) => phase.phase === "structured-merge").status, "PASS");
  assert.equal(receivedMergeRequest.schema, "creation-authoring.structured-merge-request.v1");
  assert.equal(receivedMergeRequest.operations.length, 2);
});

test("promotion candidate dry-run proof passes while live release remains blocked", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "ckra-promotion-check-"));
  const candidatePath = path.join(tempDir, "ExampleMod_PromotionCandidate.esp");
  let receivedMergeRequest = null;

  const check = await checkPromotionCandidateDryRun(runReport, profile, {
    approved: true,
    sourcePath: path.join(tempDir, "ExampleMod.esp"),
    generatedPath: path.join(tempDir, "ExampleMod_AutoWire.esp"),
    mergeOutputPath: candidatePath,
    backupRunner: async () => ({ status: "DEFERRED_TO_MERGE_RUNNER" }),
    mergeRunner: async (mergeRequest) => {
      receivedMergeRequest = mergeRequest;
      return {
        status: "PASS",
        report: {
          status: "PASS",
          dryRun: true,
          outputPath: candidatePath,
          operationCount: mergeRequest.operations.length
        }
      };
    }
  });

  assert.equal(check.status, "PASS");
  assert.equal(check.releaseReady, false);
  assert.equal(check.phaseStatuses["promotion-gates"], "PASS");
  assert.equal(check.phaseStatuses["structured-merge"], "PASS");
  assert.equal(check.releaseBlockers.some((blocker) => blocker.phase === "post-merge-verify"), true);
  assert.equal(fs.existsSync(candidatePath), false);
  assert.equal(receivedMergeRequest.candidatePlugin, candidatePath);
  assert.equal(receivedMergeRequest.conflictPolicy, "fail-unless-declared");
  assert.equal(receivedMergeRequest.remapPolicy, "deterministic");
});

test("promotion candidate dry-run proof fails if the runner writes output", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "ckra-promotion-check-write-"));
  const candidatePath = path.join(tempDir, "ExampleMod_PromotionCandidate.esp");

  const check = await checkPromotionCandidateDryRun(runReport, profile, {
    approved: true,
    sourcePath: path.join(tempDir, "ExampleMod.esp"),
    generatedPath: path.join(tempDir, "ExampleMod_AutoWire.esp"),
    mergeOutputPath: candidatePath,
    backupRunner: async () => ({ status: "DEFERRED_TO_MERGE_RUNNER" }),
    mergeRunner: async () => {
      fs.writeFileSync(candidatePath, "unexpected dry-run output");
      return {
        status: "PASS",
        report: {
          status: "PASS",
          dryRun: true,
          outputPath: candidatePath
        }
      };
    }
  });

  assert.equal(check.status, "FAIL");
  assert.equal(check.failures.some((failure) => /candidatePath/.test(failure)), true);
});

test("promotion release readiness stays requested without required adapters", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });

  const promotion = await promoteRunReport(runReport, profile, {
    approved: true,
    mergeOutputPath: "ExampleMod_PromotionCandidate.esp"
  });

  assert.equal(promotion.status, "REQUESTED");
  assert.equal(promotion.phases.find((phase) => phase.phase === "backup").status, "REQUESTED");
  assert.equal(promotion.phases.find((phase) => phase.phase === "structured-merge").status, "REQUESTED");
  assert.equal(promotion.phases.find((phase) => phase.phase === "post-merge-verify").status, "REQUESTED");
});

test("service promotion forwards candidate output options to promotion gates", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });

  const promotion = await handleAuthoringRequest({
    action: "promote",
    profile,
    runReport,
    approved: true,
    mergeOutputPath: "ExampleMod_PromotionCandidate.esp",
    adapters: {
      backupRunner: async () => ({ status: "PASS" }),
      mergeRunner: async () => ({ status: "PASS" })
    }
  });

  assert.equal(promotion.phases[0].status, "PASS");
  assert.equal(promotion.phases[0].gates.candidateOutput.ready, true);
  assert.equal(promotion.candidatePlugin, "ExampleMod_PromotionCandidate.esp");
});

test("promotion requests CK finalization when promoted operation requires CK semantics", async () => {
  const runReport = await runPipeline(manifest, profile, {
    strict: true,
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });
  const ckReport = {
    ...runReport,
    planOperations: runReport.planOperations.map((operation, index) => index === 0
      ? {
        ...operation,
        ckSemanticsRequired: true,
        mergePolicy: {
          ...operation.mergePolicy,
          requiresCkFinalization: true
        }
      }
      : operation)
  };

  const promotion = await promoteRunReport(ckReport, profile, {
    approved: true,
    mergeOutputPath: "ExampleMod_PromotionCandidate.esp",
    backupRunner: async () => ({ status: "PASS" }),
    mergeRunner: async () => ({ status: "PASS" }),
    postMergeVerifier: async () => ({ status: "PASS" })
  });

  assert.equal(promotion.status, "REQUESTED");
  assert.equal(promotion.phases.find((phase) => phase.phase === "ck-finalization").status, "REQUESTED");
});

test("blocks promotion of observer-only discovery proof reports", () => {
  const observerReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 1, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            { op: "openProject", status: "PASS" },
            { op: "armGlobCreateObserver", status: "PASS" },
            { op: "closeSafeStatus", status: "PASS" }
          ]
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: { summary: { PASS: 1, FAIL: 0, TODO: 0 }, results: [{ operationId: "glob-observer", status: "PASS" }] }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "glob-observer", kind: "glob.create.observer", target: "EXM_GLO_Probe", recordFamily: "GLOB", backend: "ckpe-bridge" }
    ]
  };

  const gates = evaluatePromotionGates(observerReport, profile, { approved: true });
  assert.equal(gates.ready, false);
  assert.equal(gates.blockers.some((blocker) => /observer/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /mutation evidence/.test(blocker)), true);
});

test("blocks inspectGlobCreateRecordInvocationPlan discovery evidence from createRecord promotion", () => {
  const inspectReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 1, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            {
              op: "inspectGlobCreateRecordInvocationPlan",
              operationId: "inspect-glob-create-plan",
              target: "EXM_GLO_Phase17Probe",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                requestedPlugin: "ExampleMod_AutoWire.esp",
                implementationRule: "Inspection plan only; does not call createRecord or mutate CK state."
              }
            }
          ]
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: {
          summary: { PASS: 1, FAIL: 0, TODO: 0 },
          results: [{ operationId: "inspect-glob-create-plan", status: "PASS" }]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "inspect-glob-create-plan", kind: "record.create.inspect", target: "EXM_GLO_Phase17Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true }
    ]
  };
  const proofLedger = buildProofLedgerFromRun(inspectReport, { fixture: "fixtures/phase17-glob-inspection.json" });
  proofLedger.verification = verifyProofLedger(proofLedger);

  const gates = evaluatePromotionGates(inspectReport, profile, { approved: true, proofLedger });
  assert.equal(gates.ready, false);
  assert.equal(gates.mutationProof.ckMutation, false);
  assert.equal(gates.blockers.some((blocker) => /discovery|observer/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /mutation evidence/.test(blocker)), true);
});

test("blocks wrapper caller contract evidence from createRecord promotion", () => {
  const contractReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 1, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            {
              op: "proveGlobCreateRecordWrapperCallerContract",
              operationId: "glob-wrapper-caller-contract",
              target: "EXM_GLO_Phase20Probe",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                requestedPlugin: "ExampleMod_AutoWire.esp",
                activePlugin: {
                  activePlugin: { fileName: "ExampleMod_AutoWire.esp", active: true }
                },
                wrapperContractResolved: true,
                callerContractResolved: true,
                implementationRule: "Wrapper/caller contract proof only; no generated-plugin mutation, save, or readback."
              }
            }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "glob-wrapper-caller-contract", kind: "record.create.wrapperContract", target: "EXM_GLO_Phase20Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true }
    ]
  };

  const gates = evaluatePromotionGates(contractReport, profile, { approved: true });
  assert.equal(gates.ready, false);
  assert.equal(gates.mutationProof.ckMutation, false);
  assert.equal(gates.blockers.some((blocker) => /discovery|observer/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /mutation evidence/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /readback phase/.test(blocker)), true);
});

test("blocks Phase21-31 discovery-only createRecord evidence", () => {
  const phaseDiscoveryReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 5, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            { op: "evaluateGlobCreateMutationReady", operationId: "phase21-mutation-ready", status: "PASS", evidence: { mutationReady: false } },
            { op: "lookupGlobCreateSourceTemplate", operationId: "phase22-source-template", target: "PDV_GLO_ActivePiety", recordFamily: "GLOB", status: "PASS" },
            { op: "selectGlobCreateInvocationContext", operationId: "phase24-selector-context", status: "PASS", evidence: { context: { generatedPlugin: "ExampleMod_AutoWire.esp" } } },
            { op: "initGlobCreateContext", operationId: "phase29-context-init", status: "PASS", evidence: { contextInitFired: false } },
            { op: "evaluateGlobCreateGuardBoolean", operationId: "phase30-guard-boolean", status: "PASS", evidence: { guardReturned: true } }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "phase21-mutation-ready", kind: "record.create.mutationReady", target: "EXM_GLO_Phase21Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true },
      { id: "phase22-source-template", kind: "record.create.sourceLookup", target: "PDV_GLO_ActivePiety", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true },
      { id: "phase24-selector-context", kind: "record.create.selectorContext", target: "EXM_GLO_Phase24Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true },
      { id: "phase29-context-init", kind: "record.create.contextInit", target: "EXM_GLO_Phase29Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true },
      { id: "phase30-guard-boolean", kind: "record.create.guardBoolean", target: "EXM_GLO_Phase30Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true }
    ]
  };

  const gates = evaluatePromotionGates(phaseDiscoveryReport, profile, { approved: true });
  assert.equal(gates.ready, false);
  assert.equal(gates.mutationProof.ckMutation, false);
  assert.equal(gates.blockers.some((blocker) => /discovery|observer/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /mutation evidence/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /readback phase/.test(blocker)), true);
});

test("blocks Phase33 post-allocation candidate discovery from createRecord promotion", () => {
  const phase33Report = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 1, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            {
              op: "proveGlobPostAllocationCandidate",
              operationId: "phase33-post-allocation-candidate",
              target: "EXM_GLO_Phase33Probe",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                candidate: "0x141618120",
                createdGlobRegister: "rdx",
                createdGlobObserved: true,
                ownershipProven: false,
                dirtyStateProven: false,
                savePluginProof: false,
                readbackProof: false,
                noisyPhases: ["phase32", "phase35"],
                missedPhases: ["phase36", "phase37"]
              }
            }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "phase33-post-allocation-candidate", kind: "record.create.postAllocationCandidate", target: "EXM_GLO_Phase33Probe", recordFamily: "GLOB", backend: "ckpe-bridge", ckSemanticsRequired: true }
    ]
  };

  const gates = evaluatePromotionGates(phase33Report, profile, { approved: true });
  assert.equal(gates.ready, false);
  assert.equal(gates.mutationProof.ckMutation, false);
  assert.equal(gates.blockers.some((blocker) => /discovery|observer/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /mutation evidence/.test(blocker)), true);
  assert.equal(gates.blockers.some((blocker) => /readback phase/.test(blocker)), true);
});

test("createRecord promotion requires proof ledger and active generated plugin evidence", () => {
  const createReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    reportPath: "reports/example-create.run-report.json",
    manifest: {
      project: "example-mod",
      game: "SkyrimSE",
      sourcePlugin: "ExampleMod.esp",
      output: "ExampleMod_AutoWire.esp"
    },
    phases: [
      { phase: "plan", status: "PASS", summary: { ready: 1, manual: 0, abort: 0 } },
      {
        phase: "ck-apply",
        status: "PASS",
        packet: { generatedPlugin: "ExampleMod_AutoWire.esp" },
        adapterResult: {
          status: "PASS",
          commands: [
            {
              op: "loadPluginSet",
              status: "PASS",
              evidence: {
                requestedActivePlugin: "ExampleMod_AutoWire.esp",
                intendedSaveTarget: "ExampleMod_AutoWire.esp",
                activePluginMatchesRequest: true,
                saveTargetMatchesActive: true,
                sourcePluginActive: false
              }
            },
            {
              op: "createRecord",
              operationId: "create-message",
              target: "EXM_Message",
              recordFamily: "MESG",
              status: "PASS",
              evidence: {
                generatedPluginOnly: true,
                mutationCommitted: true,
                saveCompleted: true
              }
            },
            { op: "postUiSaveCommand", plugin: "ExampleMod_AutoWire.esp", status: "PASS" }
          ]
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: {
          summary: { PASS: 1, FAIL: 0, TODO: 0 },
          results: [{ operationId: "create-message", status: "PASS" }]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    manualPackets: [],
    planOperations: [
      { id: "create-message", kind: "record.create", target: "EXM_Message", recordFamily: "MESG", backend: "ckpe-bridge", ckSemanticsRequired: true }
    ]
  };

  const promotionOptions = { approved: true, mergeOutputPath: "ExampleMod_Candidate.esp" };
  const missingLedger = evaluatePromotionGates(createReport, profile, promotionOptions);
  assert.equal(missingLedger.ready, false);
  assert.equal(missingLedger.blockers.some((blocker) => /proof ledger/.test(blocker)), true);

  const proofLedger = buildProofLedgerFromRun(createReport, { fixture: "fixtures/create-message.json" });
  proofLedger.verification = verifyProofLedger(proofLedger);
  assert.equal(proofLedger.status, "PASS");
  assert.equal(proofLedger.verification.status, "PASS");

  const gates = evaluatePromotionGates(createReport, profile, { ...promotionOptions, proofLedger });
  assert.equal(gates.ready, true);

  const unverifiedLedger = structuredClone(proofLedger);
  delete unverifiedLedger.verification;
  const unverifiedGates = evaluatePromotionGates(createReport, profile, { ...promotionOptions, proofLedger: unverifiedLedger });
  assert.equal(unverifiedGates.ready, false);
  assert.equal(unverifiedGates.blockers.some((blocker) => /PASS verification/.test(blocker)), true);

  const inactiveReport = structuredClone(createReport);
  inactiveReport.phases[1].adapterResult.commands[0].evidence.activePluginMatchesRequest = false;
  const inactiveGates = evaluatePromotionGates(inactiveReport, profile, { ...promotionOptions, proofLedger });
  assert.equal(inactiveGates.ready, false);
  assert.equal(inactiveGates.blockers.some((blocker) => /active.*generated plugin/i.test(blocker)), true);

  const unsavedReport = structuredClone(createReport);
  unsavedReport.phases[1].adapterResult.commands = unsavedReport.phases[1].adapterResult.commands.filter((command) => command.op !== "postUiSaveCommand");
  const unsavedGates = evaluatePromotionGates(unsavedReport, profile, { ...promotionOptions, proofLedger });
  assert.equal(unsavedGates.ready, false);
  assert.equal(unsavedGates.blockers.some((blocker) => /save PASS/.test(blocker)), true);

  const sourceTargetReport = structuredClone(createReport);
  sourceTargetReport.phases[1].adapterResult.commands[1].payload = { plugin: "ExampleMod.esp" };
  const sourceTargetGates = evaluatePromotionGates(sourceTargetReport, profile, { ...promotionOptions, proofLedger });
  assert.equal(sourceTargetGates.ready, false);
  assert.equal(sourceTargetGates.blockers.some((blocker) => /generated plugin only/.test(blocker)), true);
});

test("review report captures run phases and manifest intent", async () => {
  const runReport = await runPipeline(manifest, profile, {
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: { entries: ["EXM_ServiceQuest"] }
      }
    }
  });

  const review = buildReviewJson(runReport);
  assert.equal(review.schema, "creation-authoring.review-report.v1");
  assert.equal(review.status, "PASS");
  assert.equal(review.operations.length, 2);
  assert.equal(review.phases.some((phase) => phase.phase === "verify"), true);
});

test("classifies manifest/source drift without auto-healing", () => {
  const createManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    operations: [
      {
        id: "create-existing",
        kind: "record.create",
        target: "EXM_MainQuest",
        mode: "create",
        payload: { recordType: "QUST" }
      }
    ]
  }, profile);

  const report = analyzeDrift(createManifest, profile, {
    records: { EXM_MainQuest: { editorId: "EXM_MainQuest" } }
  });
  assert.equal(report.summary.manual_source_override, 1);
  assert.equal(report.results[0].status, "UNSAFE_BLOCKED");
});

test("extracts Skyrim SE CK record inventory from CKPE TESDataHandler", () => {
  const inventory = extractCkpeRecordInventory({ game: "SkyrimSE" });
  const families = new Set(inventory.recordFamilies.map((family) => family.recordFamily));
  assert.equal(inventory.schema, "creation-authoring.ck-record-inventory.v1");
  assert.equal(families.has("QUST"), true);
  assert.equal(families.has("MESG"), true);
  assert.equal(families.has("ACTI"), true);
  assert.equal(families.has("FLST"), true);
  assert.equal(families.has("REFR"), true);
});

test("builds a complete capability matrix with explicit status for every inventory row", () => {
  const inventory = extractCkpeRecordInventory({ game: "SkyrimSE" });
  const matrix = buildCapabilityMatrix({ inventory, proofResults: { results: [] } });
  const verification = verifyCapabilityMatrix(matrix, inventory);
  assert.equal(matrix.rows.length, inventory.recordFamilies.length);
  assert.equal(matrix.rows.every((row) => row.status), true);
  assert.equal(verification.status, "PASS");
  assert.equal(matrix.rows.find((row) => row.recordFamily === "QUST").status, "ck_required_unproven");
  assert.deepEqual(matrix.rows.find((row) => row.recordFamily === "GLOB").manifestOperations, ["glob.duplicate_create"]);
  assert.deepEqual(matrix.rows.find((row) => row.recordFamily === "GLOB").supportedCommands, ["duplicateCreateGlob"]);
  const mesg = matrix.rows.find((row) => row.recordFamily === "MESG");
  assert.equal(mesg.status, "ck_required_unproven");
  assert.equal(mesg.manifestOperations.includes("message.payload.set"), true);
  assert.equal(mesg.supportedCommands.includes("setMessagePayload"), true);
  assert.equal(mesg.operationProofs.find((proof) => proof.operation === "message.payload.set").status, "UNPROVEN");
  const acti = matrix.rows.find((row) => row.recordFamily === "ACTI");
  assert.equal(acti.status, "ck_required_unproven");
  assert.equal(acti.manifestOperations.includes("activator.payload.set"), true);
  assert.equal(acti.supportedCommands.includes("setActivatorPayload"), true);
  assert.equal(acti.operationProofs.find((proof) => proof.operation === "activator.payload.set").status, "UNPROVEN");
  assert.equal(matrix.rows.find((row) => row.recordFamily === "NONE").status, "not_applicable");
});

test("rejects supported matrix rows without end-to-end proof coverage", () => {
  const inventory = {
    schema: "creation-authoring.ck-record-inventory.v1",
    game: "SkyrimSE",
    recordFamilies: [
      {
        recordFamily: "QUST",
        formType: 77,
        ckpeArray: "arrQUST"
      }
    ]
  };
  const matrix = buildCapabilityMatrix({ inventory });
  matrix.rows[0] = {
    ...matrix.rows[0],
    status: "supported",
    proofStatus: "UNPROVEN",
    proofFixture: null
  };
  const verification = verifyCapabilityMatrix(matrix, inventory);
  assert.equal(verification.status, "FAIL");
  assert.equal(verification.failures[0].code, "unsupported_supported_row");
});

test("capability matrix does not attach failed proof ledger to unproven rows", () => {
  const inventory = {
    schema: "creation-authoring.ck-record-inventory.v1",
    game: "SkyrimSE",
    recordFamilies: [
      {
        recordFamily: "QUST",
        formType: 77,
        ckpeArray: "arrQUST"
      }
    ]
  };
  const matrix = buildCapabilityMatrix({
    inventory,
    proofResults: {
      sourceLedger: "reports/failed.run-report.json",
      results: []
    }
  });
  assert.equal(matrix.rows[0].proofStatus, "UNPROVEN");
  assert.equal(matrix.rows[0].proofLedger, null);
});

test("builds proof ledger only from strict passing verifier evidence", () => {
  const runReport = {
    status: "PASS",
    reportPath: "reports/example.run-report.json",
    manifest: { project: "example-mod", output: "ExampleMod_AutoWire.esp" },
    phases: [
      {
        phase: "verify",
        status: "PASS",
        report: {
          results: [
            { operationId: "script", status: "PASS" },
            { operationId: "list", status: "PASS" }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    planOperations: [
      { id: "script", kind: "vmad.attach_script", target: "EXM_MainQuest", recordFamily: "QUST", backend: "mo2-mcp-patch-request" },
      { id: "list", kind: "formlist.add", target: "EXM_FLST_AllServices", recordFamily: "FLST", backend: "mo2-mcp-patch-request" }
    ]
  };
  const ledger = buildProofLedgerFromRun(runReport, { fixture: "fixtures/example.json" });
  assert.equal(ledger.status, "PASS");
  assert.equal(ledger.proofs.length, 2);
  assert.equal(ledger.proofs.every((proof) => proof.coverage.strictReport), true);
  assert.equal(ledger.proofs.every((proof) => proof.commandEvidenceStatus === "NOT_REQUIRED"), true);
});

test("proof ledger requires passing CK command evidence for GLOB duplicate-create promotion", () => {
  const baseReport = {
    status: "PASS",
    reportPath: "reports/glob.run-report.json",
    manifest: { project: "example-mod", output: "ExampleMod_AutoWire.esp" },
    phases: [
      {
        phase: "verify",
        status: "PASS",
        report: {
          results: [{ operationId: "duplicate-global", status: "PASS" }]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    planOperations: [
      {
        id: "duplicate-global",
        kind: "glob.duplicate_create",
        target: "EXM_GLO_DebugDUPLICATE001",
        recordFamily: "GLOB",
        backend: "ckpe-bridge",
        ckSemanticsRequired: true
      }
    ]
  };

  const blockedLedger = buildProofLedgerFromRun({
    ...baseReport,
    phases: [
      ...baseReport.phases,
      {
        phase: "ck-apply",
        status: "UNSAFE_BLOCKED",
        adapterResult: {
          commands: [
            {
              op: "duplicateCreateGlob",
              status: "UNSAFE_BLOCKED",
              target: "EXM_GLO_DebugDUPLICATE001",
              evidence: { recordFamily: "GLOB" }
            }
          ]
        }
      }
    ]
  });
  assert.equal(blockedLedger.status, "FAIL");
  assert.equal(blockedLedger.proofs[0].commandEvidenceStatus, "FAIL");
  assert.equal(blockedLedger.proofs[0].missingCoverage.includes("ckCommandEvidence"), true);

  const passingLedger = buildProofLedgerFromRun({
    ...baseReport,
    phases: [
      ...baseReport.phases,
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: [
            {
              op: "duplicateCreateGlob",
              status: "PASS",
              target: "EXM_GLO_DebugDUPLICATE001",
              evidence: { recordFamily: "GLOB" }
            }
          ]
        }
      }
    ]
  });
  assert.equal(passingLedger.status, "PASS");
  assert.equal(passingLedger.proofs[0].coverage.ckCommandEvidence, true);

  const nestedEvidenceLedger = buildProofLedgerFromRun({
    ...baseReport,
    phases: [
      ...baseReport.phases,
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: [
            {
              op: "duplicateCreateGlob",
              status: "PASS",
              evidence: {
                requested: {
                  targetEditorId: "EXM_GLO_DebugDUPLICATE001",
                  recordFamily: "GLOB"
                }
              }
            }
          ]
        }
      }
    ]
  });
  assert.equal(nestedEvidenceLedger.status, "PASS");
  assert.equal(nestedEvidenceLedger.proofs[0].commandEvidence[0].target, "EXM_GLO_DebugDUPLICATE001");
});

test("Phase 61 GLOB proof ledger promotes the capability matrix row", () => {
  const runReport = JSON.parse(fs.readFileSync("fixtures/ckpe/phase61-glob-duplicate-create-strict-run-report.json", "utf8"));
  const ledger = buildProofLedgerFromRun(runReport, {
    fixture: "fixtures/ckpe/phase59-glob-duplicate-create-product-command.ck-command-packet.json"
  });
  const proofResults = flattenProofLedgerResults(ledger);
  proofResults.sourceLedger = "fixtures/ckpe/phase61-glob-duplicate-create-proof-ledger.json";
  const matrix = buildCapabilityMatrix({
    inventory: {
      game: "SkyrimSE",
      source: { kind: "fixture" },
      recordFamilies: [
        {
          recordFamily: "GLOB",
          formType: 9,
          ckpeArray: "arrGLOB",
          sourceFile: "third_party/Creation-Kit-Platform-Extended/CKPE.SkyrimSE/Include/EditorAPI/TESDataHandler.h",
          sourceLine: 55
        }
      ]
    },
    proofResults
  });
  const glob = matrix.rows.find((row) => row.recordFamily === "GLOB");
  assert.equal(ledger.status, "PASS");
  assert.equal(glob.status, "supported");
  assert.equal(glob.proofCommandEvidenceStatus, "PASS");
  assert.equal(glob.proofLedger, "fixtures/ckpe/phase61-glob-duplicate-create-proof-ledger.json");
});

test("Phase21-31 candidate results stay discovery-only and document blockers", () => {
  const runReport = {
    status: "PASS",
    reportPath: "reports/glob-phase21-31-discovery.run-report.json",
    manifest: { project: "example-mod", output: "ExampleMod_Generated.esp" },
    phases: [
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: [
            {
              op: "inspectGlobCreateRecordInvocationPlan",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                invocationPlan: {
                  invocationPlanPassed: true,
                  mutationReady: false,
                  supportBlockers: [
                    "CK UI stack/context still required",
                    "ownership registration not proven",
                    "save proof not proven",
                    "MO2 readback proof not proven"
                  ]
                }
              }
            },
            {
              op: "inspectGlobCreateRecordCandidateReturn",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                candidateResult: {
                  invocationTarget: "0x1413886f0",
                  returnedExistingFormId: 903642,
                  returnedPointerKind: "existing-source-template-glob",
                  expectedNewFormId: true
                }
              }
            },
            {
              op: "inspectGlobCreateRecordCandidateReturn",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                candidateResult: {
                  invocationTarget: "0x14129de20",
                  returnedPointerKind: "context-pointer"
                }
              }
            },
            {
              op: "inspectGlobCreateRecordCandidateReturn",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                candidateResult: {
                  invocationTarget: "0x141388300",
                  returnedPointerKind: "existing-glob-template-forms"
                }
              }
            },
            {
              op: "inspectGlobCreateRecordCandidateReturn",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                candidateResult: {
                  invocationTarget: "0x141a681f0",
                  fired: false,
                  fireCount: 0
                }
              }
            },
            {
              op: "inspectGlobCreateRecordCandidateReturn",
              operationId: "glob-create",
              target: "EXM_Phase31Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                candidateResult: {
                  invocationTarget: "0x14123ac90",
                  fired: true,
                  fireCount: 16,
                  booleanReturn: 1,
                  returnedPointerKind: "boolean"
                }
              }
            }
          ]
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: {
          results: [
            { operationId: "glob-create", status: "PASS" }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    planOperations: [
      {
        id: "glob-create",
        kind: "record.create",
        target: "EXM_Phase31Global",
        recordFamily: "GLOB",
        backend: "ckpe-bridge",
        ckSemanticsRequired: true
      }
    ]
  };

  const ledger = buildProofLedgerFromRun(runReport, { fixture: "fixtures/glob-phase21-31-discovery.json" });
  assert.equal(ledger.status, "FAIL");
  assert.equal(ledger.proofs[0].commandEvidenceStatus, "MISSING");
  assert.equal(ledger.proofs[0].commandEvidence.length, 0);
  assert.equal(ledger.proofs[0].discoveryEvidence.length, 6);
  assert.equal(ledger.proofs[0].discoveryEvidence[0].mutationReady, false);
  assert.equal(ledger.proofs[0].discoveryEvidence[0].supportBlockers.includes("save proof not proven"), true);
  assert.equal(ledger.proofs[0].discoveryEvidence[1].invocationTarget, "0x1413886f0");
  assert.equal(ledger.proofs[0].discoveryEvidence[1].returnedExistingFormId, 903642);
  assert.equal(ledger.proofs[0].discoveryEvidence[2].returnedPointerKind, "context-pointer");
  assert.equal(ledger.proofs[0].discoveryEvidence[3].returnedPointerKind, "existing-glob-template-forms");
  assert.equal(ledger.proofs[0].discoveryEvidence[4].fired, false);
  assert.equal(ledger.proofs[0].discoveryEvidence[5].fireCount, 16);
  assert.equal(ledger.proofs[0].discoveryEvidence[5].booleanReturn, 1);
  assert.equal(ledger.proofs[0].coverage.commandEvidence, false);
});

test("Phase32-37 post-allocation proof keeps only Phase33 as discovery candidate", () => {
  const runReport = {
    status: "PASS",
    reportPath: "reports/glob-phase32-37-discovery.run-report.json",
    manifest: { project: "example-mod", output: "ExampleMod_Generated.esp" },
    phases: [
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: [
            {
              op: "inspectGlobPostAllocationCandidate",
              operationId: "glob-create",
              target: "EXM_Phase37Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                postAllocationProof: {
                  postAllocationCandidate: false,
                  candidateAddress: "0x1411d8610",
                  noisy: true,
                  matchedExpectedCreatedForm: false
                }
              }
            },
            {
              op: "inspectGlobPostAllocationCandidate",
              operationId: "glob-create",
              target: "EXM_Phase37Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                postAllocationProof: {
                  postAllocationCandidate: true,
                  candidateAddress: "0x141618120",
                  callerReturn: "0x14146c662",
                  rdxValue: 83959999,
                  expectedCreatedFormId: 83959999,
                  expectedCreatedFormType: 9,
                  matchedExpectedCreatedForm: true,
                  discoveryGatePassed: true
                }
              }
            },
            {
              op: "inspectGlobPostAllocationCandidate",
              operationId: "glob-create",
              target: "EXM_Phase37Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                postAllocationProof: {
                  postAllocationCandidate: false,
                  candidateAddress: "0x141469e90",
                  sidePathReturn: "0x14146a795",
                  matchedExpectedCreatedForm: false
                }
              }
            },
            {
              op: "inspectGlobPostAllocationCandidate",
              operationId: "glob-create",
              target: "EXM_Phase37Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                postAllocationProof: {
                  postAllocationCandidate: false,
                  candidateAddress: "0x14169c840",
                  fired: false,
                  fireCount: 0
                }
              }
            },
            {
              op: "inspectGlobPostAllocationCandidate",
              operationId: "glob-create",
              target: "EXM_Phase37Global",
              recordFamily: "GLOB",
              status: "PASS",
              evidence: {
                recordFamily: "GLOB",
                postAllocationProof: {
                  postAllocationCandidate: false,
                  candidateAddress: "0x14129e540",
                  fired: false,
                  fireCount: 0
                }
              }
            }
          ]
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: {
          results: [
            { operationId: "glob-create", status: "PASS" }
          ]
        }
      },
      { phase: "strict-gate", status: "PASS" }
    ],
    planOperations: [
      {
        id: "glob-create",
        kind: "record.create",
        target: "EXM_Phase37Global",
        recordFamily: "GLOB",
        backend: "ckpe-bridge",
        ckSemanticsRequired: true
      }
    ]
  };

  const ledger = buildProofLedgerFromRun(runReport, { fixture: "fixtures/glob-phase32-37-discovery.json" });
  assert.equal(ledger.status, "FAIL");
  assert.equal(ledger.proofs[0].commandEvidenceStatus, "MISSING");
  assert.equal(ledger.proofs[0].commandEvidence.length, 0);
  assert.equal(ledger.proofs[0].discoveryEvidence.length, 5);

  const phase33 = ledger.proofs[0].discoveryEvidence.find((item) => item.candidateAddress === "0x141618120");
  assert.equal(phase33.postAllocationCandidate, true);
  assert.equal(phase33.callerReturn, "0x14146c662");
  assert.equal(phase33.rdxValue, 83959999);
  assert.equal(phase33.expectedCreatedFormId, 83959999);
  assert.equal(phase33.expectedCreatedFormType, 9);
  assert.equal(phase33.matchedExpectedCreatedForm, true);
  assert.equal(phase33.discoveryGatePassed, true);

  assert.equal(ledger.proofs[0].discoveryEvidence.find((item) => item.candidateAddress === "0x1411d8610").noisy, true);
  assert.equal(ledger.proofs[0].discoveryEvidence.find((item) => item.candidateAddress === "0x141469e90").sidePathReturn, "0x14146a795");
  assert.equal(ledger.proofs[0].discoveryEvidence.find((item) => item.candidateAddress === "0x14169c840").fired, false);
  assert.equal(ledger.proofs[0].discoveryEvidence.find((item) => item.candidateAddress === "0x14129e540").fired, false);
  assert.equal(ledger.proofs[0].coverage.commandEvidence, false);
});

test("readback oracle reports normalizer coverage by operation and family", () => {
  const covered = describeReadbackNormalizer({ kind: "vmad.set_array_property", recordFamily: "QUST" });
  assert.equal(covered.status, "PASS");
  assert.equal(covered.normalizer, "vmad-array-properties");

  const messagePayload = describeReadbackNormalizer({ kind: "message.payload.set", recordFamily: "MESG" });
  assert.equal(messagePayload.status, "PASS");
  assert.equal(messagePayload.normalizer, "message-payload");

  const activatorPayload = describeReadbackNormalizer({ kind: "activator.payload.set", recordFamily: "ACTI" });
  assert.equal(activatorPayload.status, "PASS");
  assert.equal(activatorPayload.normalizer, "activator-payload");

  const placed = describeReadbackNormalizer({ kind: "reference.place", recordFamily: "REFR" });
  assert.equal(placed.status, "PASS");
  assert.equal(placed.normalizer, "placed-reference");

  const dialogueBranch = describeReadbackNormalizer({ kind: "dialogue.branch.create", recordFamily: "DIAL" });
  assert.equal(dialogueBranch.status, "PASS");
  assert.equal(dialogueBranch.normalizer, "dialogue-branch");

  const dialogueTopic = describeReadbackNormalizer({ kind: "dialogue.topic.create", recordFamily: "DIAL" });
  assert.equal(dialogueTopic.status, "PASS");
  assert.equal(dialogueTopic.normalizer, "dialogue-topic");

  const dialogueInfo = describeReadbackNormalizer({ kind: "dialogue.info.create", recordFamily: "INFO" });
  assert.equal(dialogueInfo.status, "PASS");
  assert.equal(dialogueInfo.normalizer, "dialogue-info");
});

test("dialogue v1 fixture verifies CK-authored branch topic unnamed info and seq readback", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.readback.json",
    "utf8"
  ));

  const fixtureCheck = checkFixtureDirectory("fixtures/dialogue-v1", fixtureProfile, fixtureReadback, {
    allowUnprovenCk: true
  });

  assert.equal(fixtureCheck.status, "PASS");
  assert.equal(fixtureCheck.summary.PASS, 1);
  assert.deepEqual(fixtureCheck.results[0].verifySummary, {
    PASS: 4,
    FAIL: 0,
    WARN: 0,
    TODO: 0
  });
  assert.equal(fixtureCheck.results[0].operations.find((item) => item.id === "dialogue-info").backend, "ckpe-bridge");
});

test("dialogue v1 fixture remains manual without unproven CK discovery mode", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.readback.json",
    "utf8"
  ));

  const fixtureCheck = checkFixtureDirectory("fixtures/dialogue-v1", fixtureProfile, fixtureReadback);

  assert.equal(fixtureCheck.status, "FAIL");
  assert.equal(fixtureCheck.results[0].planSummary.manual, 4);
  assert.match(fixtureCheck.results[0].failures.join("\n"), /manual operation/);
});

test("dialogue info verifier accepts unnamed INFO by semantic payload and fails condition drift", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.profile.json",
    "utf8"
  )));
  const manifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/dialogue-v1/dialogue-v1.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  const infoOnlyManifest = {
    ...manifest,
    operations: manifest.operations.filter((operation) => operation.id === "dialogue-info")
  };
  const driftedReadback = {
    records: {
      "ExampleMod_DialogueV1Proof.esp:000802": {
        formid: "ExampleMod_DialogueV1Proof.esp:000802",
        recordType: "INFO",
        winningPlugin: "ExampleMod_DialogueV1Proof.esp",
        dialogue: {
          topic: "EXM_DIAL_GenericRecognitionTopic",
          speaker: "EXM_NPC_Mentor",
          speakerForm: "ExampleMod.esp:000901",
          prompt: "Do you know the old oath?",
          responseLine: "I remember it. Speak, and I will answer.",
          conditions: [
            {
              function: "GetGlobalValue",
              global: "EXM_GLO_DialogueGate",
              operator: "==",
              value: 0
            }
          ]
        }
      }
    }
  };

  const report = verifyManifest(infoOnlyManifest, fixtureProfile, driftedReadback);

  assert.equal(report.summary.FAIL, 1);
  assert.match(report.results[0].message, /dialogue info readback/);
  assert.equal(report.results[0].details.failures[0].field, "conditions");
});

test("dialogue readback alone cannot create support proof without CK command evidence", () => {
  const ledger = buildProofLedgerFromRun({
    status: "PASS",
    manifest: {
      project: "dialogue-v1",
      output: "ExampleMod_DialogueV1Proof.esp"
    },
    phases: [
      {
        phase: "verify",
        status: "PASS",
        report: {
          results: [
            {
              operationId: "dialogue-info",
              status: "PASS",
              details: {
                readbackNormalizer: {
                  status: "PASS",
                  normalizer: "dialogue-info"
                }
              }
            }
          ]
        }
      },
      {
        phase: "strict-gate",
        status: "PASS"
      }
    ],
    planOperations: [
      {
        id: "dialogue-info",
        kind: "dialogue.info.create",
        target: "EXM_INFO_GenericRecognition",
        recordFamily: "INFO",
        backend: "ckpe-bridge",
        ckSemanticsRequired: true
      }
    ]
  }, {
    fixture: "fixtures/dialogue-v1/dialogue-v1.creation-authoring.json"
  });

  assert.equal(ledger.status, "FAIL");
  assert.equal(ledger.proofs[0].commandEvidenceStatus, "MISSING");
  assert.equal(ledger.proofs[0].coverage.readbackNormalizer, true);
  assert.equal(ledger.proofs[0].coverage.ckCommandEvidence, false);
});

test("unsupported verifier expectations block strict proof coverage", () => {
  const expectationManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_AutoWire.esp",
    operations: [
      {
        id: "unsupported-expectation",
        kind: "record.update",
        target: "EXM_MainQuest",
        recordFamily: "QUST",
        payload: {},
        verifierExpectations: [
          { type: "not-yet-supported", path: "editorId", value: "EXM_MainQuest" }
        ]
      }
    ]
  }, profile);
  const report = verifyManifest(expectationManifest, profile, {
    records: {
      EXM_MainQuest: {
        editorId: "EXM_MainQuest",
        recordType: "QUST",
        winningPlugin: "ExampleMod_AutoWire.esp"
      }
    }
  });
  assert.equal(report.results[0].status, "TODO");
  assert.match(report.results[0].message, /unsupported verifier expectations/);
});

test("fails partial winning overlays before accepting generated plugin proof", () => {
  const overlayManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_AutoWire.esp",
    operations: [
      {
        id: "partial-overlay",
        kind: "vmad.attach_script",
        target: "EXM_MainQuest",
        recordFamily: "QUST",
        ckSemanticsRequired: true,
        payload: {
          script: "EXM_MainQuestScript",
          properties: [{ name: "DebugGlobal", type: "Object", value: "EXM_GLO_Debug" }]
        }
      }
    ]
  }, profile);
  const report = verifyManifest(overlayManifest, profile, {
    records: {
      EXM_MainQuest: {
        editorId: "EXM_MainQuest",
        recordType: "QUST",
        winningPlugin: "ExampleMod_AutoWire.esp",
        partialOverlay: true,
        missingFields: ["VMAD.Properties.DebugGlobal"],
        scripts: [
          { name: "EXM_MainQuestScript", properties: { DebugGlobal: "EXM_GLO_Debug" } }
        ],
        conflictChain: ["ExampleMod.esp", "ExampleMod_AutoWire.esp"]
      }
    }
  });
  assert.equal(report.results[0].status, "FAIL");
  assert.match(report.results[0].message, /partial winning overlay/);
});

test("verifies conflict chain, message buttons, aliases, stages, and artifact freshness expectations", () => {
  const expectationManifest = normalizeManifest({
    schema: "creation-authoring.v1",
    project: "example-mod",
    game: "SkyrimSE",
    sourcePlugin: "ExampleMod.esp",
    output: "ExampleMod_AutoWire.esp",
    operations: [
      {
        id: "message",
        kind: "record.create",
        target: "EXM_MSG_Test",
        recordFamily: "MESG",
        payload: { recordType: "MESG" },
        verifierExpectations: [
          { type: "conflictChainPresent" },
          { type: "messageButton", text: "Accept" }
        ]
      },
      {
        id: "alias",
        kind: "quest.alias.add",
        target: "EXM_MainQuest",
        recordFamily: "QUST",
        payload: { name: "PlayerAlias" }
      },
      {
        id: "stage",
        kind: "quest.stage.fragment",
        target: "EXM_MainQuest",
        recordFamily: "QUST",
        payload: { stage: 10 }
      },
      {
        id: "seq",
        kind: "artifact.seq.generate",
        target: "EXM_MainQuest",
        recordFamily: "QUST",
        payload: {},
        verifierExpectations: [{ type: "artifactFresh", kind: "seq" }]
      },
      {
        id: "placement",
        kind: "reference.place",
        target: "EXM_PhasePlacement",
        recordFamily: "REFR",
        ckSemanticsRequired: true,
        payload: {
          placedInstancesRequired: ["EXM_ACTI_Test"]
        }
      }
    ]
  }, profile);
  const report = verifyManifest(expectationManifest, profile, {
    records: {
      EXM_MSG_Test: {
        editorId: "EXM_MSG_Test",
        recordType: "MESG",
        winningPlugin: "ExampleMod_AutoWire.esp",
        message: { buttons: [{ text: "Accept" }] },
        conflictChain: ["ExampleMod.esp", "ExampleMod_AutoWire.esp"]
      },
      EXM_MainQuest: {
        editorId: "EXM_MainQuest",
        recordType: "QUST",
        aliases: [{ name: "PlayerAlias" }],
        stages: [{ index: 10 }],
        artifacts: [{ kind: "seq", exists: true, fresh: true }]
      },
      EXM_PhasePlacement: {
        editorId: "EXM_PhasePlacement",
        recordType: "REFR",
        winningPlugin: "ExampleMod_AutoWire.esp",
        placedReferences: [
          { editorId: "EXM_Placed_Test", baseObject: "EXM_ACTI_Test" }
        ]
      }
    }
  });
  assert.equal(report.summary.PASS, 5);
  assert.equal(report.summary.FAIL, 0);
  assert.equal(report.summary.TODO, 0);
});

test("builds Platform v1 proof summary groups from matrix rows", () => {
  const summary = buildPlatformProofSummary({
    game: "SkyrimSE",
    rows: [
      { recordFamily: "GLOB", status: "supported", manifestOperations: ["glob.duplicate_create"], proofStatus: "PASS" },
      { recordFamily: "FLST", status: "ck_required_unproven", blockReason: "Needs CK save/readback." },
      { recordFamily: "GMST", status: "read_only", blockReason: "Engine-owned." }
    ]
  });

  assert.equal(summary.schema, "creation-authoring.platform-v1-proof-summary.v1");
  assert.equal(summary.totals.supported, 1);
  assert.equal(summary.totals.discoveryOnly, 1);
  assert.equal(summary.totals.blocked, 1);
  assert.equal(summary.releaseReady, false);
  assert.equal(summary.platformV1ProductReady, false);
  assert.equal(summary.platformV1Gate.status, "BLOCKED");
  assert.equal(summary.platformV1Gate.requiredSupportedOperations.length, 9);
  assert.equal(summary.platformV1Gate.requiredSupportedOperations.find((item) => item.operation === "glob.duplicate_create").supported, true);
  assert.equal(summary.platformV1Gate.blockers.some((blocker) => blocker.operation === "vmad.attach_script"), true);
  assert.equal(summary.platformV1Gate.blockers.some((blocker) => blocker.code === "platform_v1_creation_family_disposition_pending"), true);
});

test("Platform v1 gate can use operation proof without claiming full family support", () => {
  const matrix = buildCapabilityMatrix({
    inventory: {
      game: "SkyrimSE",
      recordFamilies: [
        { recordFamily: "NPC_", formType: 43, ckpeArray: "arrNPC", sourceFile: "fixture", sourceLine: 1 }
      ]
    },
    proofResults: {
      schema: "creation-authoring.proof-results.v1",
      results: [
        {
          recordFamily: "NPC_",
          operation: "keyword.add",
          target: "EXM_NPC_Test",
          status: "PASS",
          fixture: "fixtures/platform-v1/keyword-add.creation-authoring.json",
          strictReport: "reports/keyword-add.strict.run-report.json",
          backend: "mo2-mcp-patch-request",
          verifierStatus: "PASS",
          readbackStatus: "PASS",
          commandEvidenceStatus: "NOT_REQUIRED",
          coverage: {
            manifestOperation: true,
            backend: true,
            ckpeOrWriterHandler: true,
            ckCommandEvidence: true,
            readbackNormalizer: true,
            verifier: true,
            strictReport: true,
            proofFixture: true
          },
          missingCoverage: []
        }
      ]
    }
  });

  const row = matrix.rows[0];
  assert.equal(row.status, "ck_required_unproven");
  assert.equal(row.operationProofs.find((proof) => proof.operation === "keyword.add").status, "PASS");

  const summary = buildPlatformProofSummary({
    game: "SkyrimSE",
    rows: [
      row,
      { recordFamily: "GLOB", status: "supported", manifestOperations: ["glob.duplicate_create"], proofStatus: "PASS" },
      { recordFamily: "MESG", status: "ck_required_unproven", manifestOperations: ["record.create"] },
      { recordFamily: "FLST", status: "ck_required_unproven", manifestOperations: ["record.create"] },
      { recordFamily: "ACTI", status: "ck_required_unproven", manifestOperations: ["record.create"] },
      { recordFamily: "QUST", status: "ck_required_unproven", manifestOperations: ["record.create"] }
    ]
  });
  assert.equal(summary.platformV1Gate.requiredSupportedOperations.find((item) => item.operation === "keyword.add").supported, true);
  const keywordSurface = summary.operationSurfaces.find((surface) => surface.recordFamily === "NPC_" && surface.operation === "keyword.add");
  assert.equal(keywordSurface.status, "PASS");
  assert.equal(keywordSurface.supportScope, "operation");
});

test("Platform v1 gate accepts CK family shell proof without full payload support", () => {
  const families = ["MESG", "FLST", "ACTI", "QUST"];
  const rows = families.map((recordFamily) => ({
    recordFamily,
    status: "ck_required_unproven",
    manifestOperations: ["record.duplicate_create", "record.create", "record.update"],
    proofStatus: "PASS",
    operationProofs: [
      {
        operation: "record.duplicate_create",
        status: "PASS",
        proofLedger: `fixtures/ckpe/${recordFamily.toLowerCase()}-proof-ledger.json`,
        strictReport: `fixtures/ckpe/${recordFamily.toLowerCase()}-strict-run-report.json`
      },
      { operation: "record.create", status: "UNPROVEN" },
      { operation: "record.update", status: "UNPROVEN" }
    ]
  }));

  const summary = buildPlatformProofSummary({
    game: "SkyrimSE",
    rows: [
      { recordFamily: "GLOB", status: "supported", manifestOperations: ["glob.duplicate_create"], proofStatus: "PASS" },
      ...rows,
      ...[
        "vmad.attach_script",
        "formlist.add",
        "keyword.add",
        "spell.add",
        "perk.add",
        "package.add",
        "inventory.add",
        "condition.add"
      ].map((operation) => ({
        recordFamily: `SAFE_${operation}`,
        status: "ck_required_unproven",
        manifestOperations: [operation],
        operationProofs: [{ operation, status: "PASS" }]
      }))
    ]
  });

  assert.equal(summary.platformV1Gate.status, "PASS");
  assert.equal(summary.platformV1ProductReady, true);
  assert.equal(summary.releaseReady, false);
  assert.equal(rows.every((row) => row.status !== "supported"), true);
  const formatted = formatPlatformProofSummary(summary);
  assert.match(formatted, /Platform v1 product ready: yes/);
  assert.match(formatted, /Release ready: no/);
});

test("Platform v1 proof summary carries operation-level proof details", () => {
  const summary = buildPlatformProofSummary({
    game: "SkyrimSE",
    rows: [
      {
        recordFamily: "FLST",
        status: "ck_required_unproven",
        manifestOperations: ["record.duplicate_create", "record.create"],
        proofStatus: "PASS",
        operationProofs: [
          {
            operation: "record.duplicate_create",
            status: "PASS",
            target: "EXM_FLST_Copy",
            generatedPlugin: "Example_Generated.esp",
            fixture: "fixtures/ckpe/flst.ck-command-packet.json",
            proofLedger: "fixtures/ckpe/flst-proof-ledger.json",
            strictReport: "fixtures/ckpe/flst-strict-run-report.json",
            backend: "ckpe-bridge",
            verifierStatus: "PASS",
            readbackStatus: "PASS",
            commandEvidenceStatus: "PASS"
          },
          { operation: "record.create", status: "UNPROVEN" }
        ]
      }
    ]
  }, { sourceProofResults: "generated/proof-results.skyrimse.json" });

  assert.equal(summary.sourceProofResults, "generated/proof-results.skyrimse.json");
  assert.equal(summary.groups.discoveryOnly[0].operationProofs.length, 1);
  assert.equal(summary.groups.discoveryOnly[0].operationProofs[0].operation, "record.duplicate_create");
  assert.equal(summary.groups.discoveryOnly[0].operationProofs[0].generatedPlugin, "Example_Generated.esp");
  const duplicateSurface = summary.operationSurfaces.find((surface) => surface.operation === "record.duplicate_create");
  assert.equal(duplicateSurface.status, "PASS");
  assert.equal(duplicateSurface.supportScope, "operation");
  assert.equal(duplicateSurface.proofReferences.generatedPlugin, "Example_Generated.esp");
  const genericCreateSurface = summary.operationSurfaces.find((surface) => surface.operation === "record.create");
  assert.equal(genericCreateSurface.status, "UNPROVEN");
  assert.equal(genericCreateSurface.supportScope, "blocked_generic_create");
  assert.equal(genericCreateSurface.proofReferences.proofLedger, null);
});

test("Platform v1 evidence check validates proof-results, matrix, and summary agreement", () => {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "ckra-evidence-"));
  writeFixtureFile(tempDir, "fixtures/platform-v1/keyword-add.creation-authoring.json");
  writeFixtureFile(tempDir, "reports/keyword-add.strict.run-report.json");
  writeFixtureFile(tempDir, "generated/keyword-add.proof-ledger.json");
  writeFixtureFile(tempDir, "fixtures/ckpe/phase63-flst-duplicate-create-product-command.ck-command-packet.json");
  writeFixtureFile(tempDir, "fixtures/ckpe/phase65-flst-duplicate-create-strict-run-report.json");
  writeFixtureFile(tempDir, "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json");

  const proofResults = {
    schema: "creation-authoring.proof-results.v1",
    sourceLedgers: ["generated/keyword-add.proof-ledger.json", "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json"],
    results: [
      proofResult({
        recordFamily: "NPC_",
        operation: "keyword.add",
        target: "EXM_NPC_Test",
        fixture: "fixtures/platform-v1/keyword-add.creation-authoring.json",
        strictReport: "reports/keyword-add.strict.run-report.json",
        proofLedger: "generated/keyword-add.proof-ledger.json",
        generatedPlugin: "Example_Generated.esp",
        commandEvidenceStatus: "NOT_REQUIRED"
      }),
      proofResult({
        recordFamily: "FLST",
        operation: "record.duplicate_create",
        target: "EXM_FLST_Copy",
        fixture: "fixtures/ckpe/phase63-flst-duplicate-create-product-command.ck-command-packet.json",
        strictReport: "fixtures/ckpe/phase65-flst-duplicate-create-strict-run-report.json",
        proofLedger: "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json",
        generatedPlugin: "Example_CKProof.esp",
        commandEvidenceStatus: "PASS"
      }),
      ...["MESG", "ACTI", "QUST"].map((recordFamily) => proofResult({
        recordFamily,
        operation: "record.duplicate_create",
        target: `${recordFamily}_Copy`,
        fixture: "fixtures/ckpe/phase63-flst-duplicate-create-product-command.ck-command-packet.json",
        strictReport: "fixtures/ckpe/phase65-flst-duplicate-create-strict-run-report.json",
        proofLedger: "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json",
        generatedPlugin: "Example_CKProof.esp",
        commandEvidenceStatus: "PASS"
      }))
    ]
  };
  const matrix = {
    schema: "creation-authoring.capability-matrix.v1",
    rows: [
      {
        recordFamily: "GLOB",
        status: "supported",
        manifestOperations: ["glob.duplicate_create"],
        operationProofs: []
      },
      {
        recordFamily: "FLST",
        status: "ck_required_unproven",
        operationProofs: [
          {
            operation: "record.duplicate_create",
            status: "PASS",
            target: "EXM_FLST_Copy",
            generatedPlugin: "Example_CKProof.esp",
            fixture: "fixtures/ckpe/phase63-flst-duplicate-create-product-command.ck-command-packet.json",
            strictReport: "fixtures/ckpe/phase65-flst-duplicate-create-strict-run-report.json",
            proofLedger: "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json"
          }
        ]
      },
      ...["MESG", "ACTI", "QUST"].map((recordFamily) => ({
        recordFamily,
        status: "ck_required_unproven",
        operationProofs: [
          {
            operation: "record.duplicate_create",
            status: "PASS",
            target: `${recordFamily}_Copy`,
            generatedPlugin: "Example_CKProof.esp",
            fixture: "fixtures/ckpe/phase63-flst-duplicate-create-product-command.ck-command-packet.json",
            strictReport: "fixtures/ckpe/phase65-flst-duplicate-create-strict-run-report.json",
            proofLedger: "fixtures/ckpe/phase65-flst-duplicate-create-proof-ledger.json"
          }
        ]
      })),
      {
        recordFamily: "NPC_",
        status: "ck_required_unproven",
        operationProofs: [
          {
            operation: "keyword.add",
            status: "PASS",
            target: "EXM_NPC_Test",
            generatedPlugin: "Example_Generated.esp",
            fixture: "fixtures/platform-v1/keyword-add.creation-authoring.json",
            strictReport: "reports/keyword-add.strict.run-report.json",
            proofLedger: "generated/keyword-add.proof-ledger.json"
          }
        ]
      }
    ]
  };
  const summary = {
    schema: "creation-authoring.platform-v1-proof-summary.v1",
    sourceProofResults: "generated/proof-results.skyrimse.json",
    platformV1Gate: { status: "PASS" },
    groups: {
      supported: [],
      discoveryOnly: [
        {
          recordFamily: "FLST",
          operationProofs: [matrix.rows.find((row) => row.recordFamily === "FLST").operationProofs[0]]
        },
        ...["MESG", "ACTI", "QUST"].map((recordFamily) => ({
          recordFamily,
          operationProofs: [matrix.rows.find((row) => row.recordFamily === recordFamily).operationProofs[0]]
        })),
        {
          recordFamily: "NPC_",
          operationProofs: [matrix.rows.find((row) => row.recordFamily === "NPC_").operationProofs[0]]
        }
      ],
      blocked: []
    }
  };

  fs.mkdirSync(path.join(tempDir, "generated"), { recursive: true });
  fs.writeFileSync(path.join(tempDir, "generated/proof-results.skyrimse.json"), JSON.stringify(proofResults, null, 2));
  fs.writeFileSync(path.join(tempDir, "generated/capability-matrix.skyrimse.json"), JSON.stringify(matrix, null, 2));
  fs.writeFileSync(path.join(tempDir, "generated/platform-v1-proof-summary.json"), JSON.stringify(summary, null, 2));

  const report = verifyPlatformV1Evidence({ repoRoot: tempDir });
  assert.equal(report.status, "PASS", JSON.stringify(report.failures, null, 2));
});

test("Platform v1 evidence check fails when summary omits explicit proof-results source", () => {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "ckra-evidence-missing-source-"));
  fs.mkdirSync(path.join(tempDir, "generated"), { recursive: true });
  fs.writeFileSync(path.join(tempDir, "generated/proof-results.skyrimse.json"), JSON.stringify({
    schema: "creation-authoring.proof-results.v1",
    sourceLedgers: [],
    results: []
  }, null, 2));
  fs.writeFileSync(path.join(tempDir, "generated/capability-matrix.skyrimse.json"), JSON.stringify({
    schema: "creation-authoring.capability-matrix.v1",
    rows: []
  }, null, 2));
  fs.writeFileSync(path.join(tempDir, "generated/platform-v1-proof-summary.json"), JSON.stringify({
    schema: "creation-authoring.platform-v1-proof-summary.v1",
    platformV1Gate: { status: "PASS" },
    groups: { supported: [], discoveryOnly: [], blocked: [] }
  }, null, 2));

  const report = verifyPlatformV1Evidence({ repoRoot: tempDir });
  assert.equal(report.status, "FAIL");
  assert.equal(report.failures.some((failure) => failure.code === "summary_missing_source_proof_results"), true);
});

test("merges proof ledgers into one proof-results document", () => {
  const merged = mergeProofResults([
    {
      schema: "creation-authoring.proof-ledger.v1",
      sourceReport: "reports/keyword-add.strict.run-report.json",
      status: "PASS",
      proofs: [
        {
          recordFamily: "NPC_",
          operation: "keyword.add",
          target: "EXM_NPC_Test",
          status: "PASS",
          fixture: "fixtures/platform-v1/keyword-add.creation-authoring.json",
          verifiedAt: "2026-05-24T00:00:00.000Z",
          strictReport: "reports/keyword-add.strict.run-report.json",
          backend: "mo2-mcp-patch-request",
          verifierStatus: "PASS",
          readbackStatus: "PASS",
          commandEvidenceStatus: "NOT_REQUIRED",
          coverage: {},
          missingCoverage: []
        }
      ]
    },
    {
      schema: "creation-authoring.proof-results.v1",
      sourceLedger: "fixtures/ckpe/phase61-glob-duplicate-create-proof-ledger.json",
      results: [
        {
          recordFamily: "GLOB",
          operation: "glob.duplicate_create",
          target: "EXM_GLO_Copy",
          status: "PASS"
        }
      ]
    }
  ], { game: "SkyrimSE" });

  assert.equal(merged.schema, "creation-authoring.proof-results.v1");
  assert.equal(merged.results.length, 2);
  assert.equal(merged.results.some((proof) => proof.operation === "keyword.add"), true);
  assert.equal(merged.results.some((proof) => proof.operation === "glob.duplicate_create"), true);
  assert.equal(merged.results.every((proof) => proof.proofLedger), true);
});

test("proof-results merge keeps the first passing proof for the same operation target", () => {
  const merged = mergeProofResults([
    {
      schema: "creation-authoring.proof-results.v1",
      sourceLedger: "fixtures/ckpe/phase68-mesg-duplicate-create-proof-ledger.json",
      results: [
        {
          recordFamily: "MESG",
          operation: "record.duplicate_create",
          target: "_HelpPipBoyItemsDUPLICATE002",
          status: "PASS",
          fixture: "fixtures/ckpe/phase66-mesg-duplicate-create-product-command.ck-command-packet.json",
          strictReport: "fixtures/ckpe/phase68-mesg-duplicate-create-strict-run-report.json"
        }
      ]
    },
    {
      schema: "creation-authoring.proof-ledger.v1",
      sourceReport: "reports/mesg-payload-v1.strict.run-report.json",
      status: "PASS",
      proofs: [
        {
          recordFamily: "MESG",
          operation: "record.duplicate_create",
          target: "_HelpPipBoyItemsDUPLICATE002",
          status: "PASS",
          fixture: "reference-packs/player-devotion/payload-v1/mesg-payload-v1-live.creation-authoring.json",
          strictReport: "reports/mesg-payload-v1.strict.run-report.json"
        }
      ]
    }
  ]);

  assert.equal(merged.results.length, 1);
  assert.equal(merged.results[0].fixture, "fixtures/ckpe/phase66-mesg-duplicate-create-product-command.ck-command-packet.json");
  assert.equal(merged.results[0].proofLedger, "fixtures/ckpe/phase68-mesg-duplicate-create-proof-ledger.json");
});

test("proof ledger requires an explicit passing strict gate", () => {
  const runReport = {
    status: "PASS",
    reportPath: "reports/no-strict.run-report.json",
    manifest: { project: "example-mod", output: "ExampleMod_AutoWire.esp" },
    phases: [
      {
        phase: "verify",
        status: "PASS",
        report: { results: [{ operationId: "list", status: "PASS" }] }
      }
    ],
    planOperations: [
      { id: "list", kind: "formlist.add", target: "EXM_FLST_AllServices", recordFamily: "FLST", backend: "mo2-mcp-patch-request" }
    ]
  };

  const ledger = buildProofLedgerFromRun(runReport, { fixture: "fixtures/platform-v1/formlist-add.creation-authoring.json" });
  assert.equal(ledger.status, "FAIL");
  assert.equal(ledger.proofs[0].missingCoverage.includes("strictReport"), true);
});

test("safe-writer readback fails when a stale plugin wins", () => {
  const report = verifyManifest(manifest, profile, {
    records: {
      EXM_MainQuest: {
        winningPlugin: "ExampleMod.esp",
        scripts: [
          {
            name: "EXM_MainQuestScript",
            properties: { DebugGlobal: "EXM_GLO_Debug" }
          }
        ]
      },
      EXM_FLST_AllServices: {
        winningPlugin: "ExampleMod_AutoWire.esp",
        entries: ["EXM_ServiceQuest"]
      }
    }
  });

  assert.equal(report.results[0].status, "FAIL");
  assert.match(report.results[0].message, /not won by generated plugin/);
});

test("readback rejects stale generated output identity", () => {
  const report = verifyManifest(manifest, profile, {
    records: {
      EXM_MainQuest: {
        winningPlugin: "ExampleMod_AutoWire.esp",
        generatedPlugin: "OldGenerated.esp",
        scripts: [
          {
            name: "EXM_MainQuestScript",
            properties: { DebugGlobal: "EXM_GLO_Debug" }
          }
        ]
      },
      EXM_FLST_AllServices: {
        winningPlugin: "ExampleMod_AutoWire.esp",
        entries: ["EXM_ServiceQuest"]
      }
    }
  });

  assert.equal(report.results[0].status, "FAIL");
  assert.match(report.results[0].message, /stale generated output/);
});

test("promotion blocks direct source overwrite unless explicitly allowed", async () => {
  const runReport = await runPipeline(manifest, profile, {
    patchWriter: async (patchRequest) => ({ output: patchRequest.output_name }),
    readback: {
      records: {
        EXM_MainQuest: {
          winningPlugin: "ExampleMod_AutoWire.esp",
          scripts: [
            {
              name: "EXM_MainQuestScript",
              properties: { DebugGlobal: "EXM_GLO_Debug" }
            }
          ]
        },
        EXM_FLST_AllServices: {
          winningPlugin: "ExampleMod_AutoWire.esp",
          entries: ["EXM_ServiceQuest"]
        }
      }
    }
  });
  const gates = evaluatePromotionGates(runReport, profile, {
    approved: true,
    sourcePath: "ExampleMod.esp",
    mergeOutputPath: "ExampleMod.esp"
  });

  assert.equal(runReport.status, "PASS");
  assert.equal(gates.ready, false);
  assert.equal(gates.directSourceOverwrite, true);
  assert.equal(gates.blockers.some((blocker) => /candidate output/.test(blocker)), true);
});

test("merge runner path guard blocks direct source overwrite by default", () => {
  assert.throws(() => assertSafeMergePaths({
    sourcePath: "C:/mods/Devotion.esp",
    generatedPath: "C:/mods/Devotion_Generated.esp",
    outputPath: "C:/mods/Devotion.esp"
  }), /reviewed candidate path/);

  assert.throws(() => assertSafeMergePaths({
    sourcePath: "C:/mods/Devotion.esp",
    generatedPath: "C:/mods/Devotion.esp",
    outputPath: "C:/mods/Devotion_Candidate.esp"
  }), /Generated plugin path/);

  assert.doesNotThrow(() => assertSafeMergePaths({
    sourcePath: "C:/mods/Devotion.esp",
    generatedPath: "C:/mods/Devotion_Generated.esp",
    outputPath: "C:/mods/Devotion_Candidate.esp"
  }));
});

test("local merge runner adapter requires explicit paths before invoking dotnet", async () => {
  await assert.rejects(() => runLocalMergeRunner({}, {}, {
    generatedPath: "C:/mods/Devotion_Generated.esp",
    outputPath: "C:/mods/Devotion_Candidate.esp",
    approved: true,
    dryRun: true
  }), /sourcePath/);

  await assert.rejects(() => runLocalMergeRunner({}, {}, {
    sourcePath: "C:/mods/Devotion.esp",
    outputPath: "C:/mods/Devotion_Candidate.esp",
    approved: true,
    dryRun: true
  }), /generatedPath/);

  await assert.rejects(() => runLocalMergeRunner({}, {}, {
    sourcePath: "C:/mods/Devotion.esp",
    generatedPath: "C:/mods/Devotion_Generated.esp",
    approved: true,
    dryRun: true
  }), /outputPath/);
});

test("release status model summarizes phases and strict blockers consistently", () => {
  assert.equal(summarizePhaseStatuses([{ status: "PASS" }, { status: "SKIPPED" }]), "PASS");
  assert.equal(summarizePhaseStatuses([{ status: "PASS" }, { status: "REQUESTED" }]), "REQUESTED");
  assert.equal(summarizePhaseStatuses([{ status: "TODO" }]), "TODO");
  assert.equal(summarizePhaseStatuses([{ status: "UNSAFE_BLOCKED" }, { status: "REQUESTED" }]), "FAIL");

  const strictGate = buildStrictGatePhase(
    [{ phase: "verify", status: "TODO", message: "No readback." }],
    [{ kind: "record.create", target: "EXM_NewQuest" }]
  );
  assert.equal(strictGate.status, "FAIL");
  assert.equal(strictGate.blockers.length, 2);
  assert.equal(strictGate.blockers.some((blocker) => blocker.phase === "manual-packet"), true);
});

test("Platform v1 safe-writer fixtures plan and verify against fixture readback", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/platform-v1/platform-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/platform-v1/platform-v1.readback.json",
    "utf8"
  ));

  const report = checkFixtureDirectory("fixtures/platform-v1", fixtureProfile, fixtureReadback);
  assert.equal(report.status, "PASS");
  assert.equal(report.summary.total, 8);
  assert.equal(report.summary.FAIL, 0);
  assert.equal(report.results.every((result) => result.planSummary.ready === 1), true);
});

test("payload v1 fixtures keep duplicate identity and payload mutation as separate proof surfaces", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/payload-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/payload-v1.readback.json",
    "utf8"
  ));

  const report = checkFixtureDirectory("fixtures/payload-v1", fixtureProfile, fixtureReadback);
  assert.equal(report.status, "PASS");
  assert.equal(report.summary.total, 2);
  assert.equal(report.summary.FAIL, 0);
  assert.equal(report.results.every((result) => result.planSummary.ready === 2), true);
  assert.equal(report.results.every((result) => result.verifySummary.PASS === 2), true);

  const messageManifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/mesg-duplicate-payload.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  const messagePlan = createPlan(messageManifest, fixtureProfile);
  assert.equal(messagePlan.operations[0].backend, "ckpe-bridge");
  assert.equal(messagePlan.operations[1].backend, "mo2-mcp-patch-request");
  const messagePatch = buildPatchRequest(messagePlan);
  assert.equal(messagePatch.records.length, 1);
  assert.equal(messagePatch.records[0].formid, "EXM_MSG_SourceDUPLICATE001");
  assert.deepEqual(messagePatch.records[0].set_message_payload, {
    title: "Payload proof title",
    text: "Payload proof body",
    buttons: [
      { text: "Accept" },
      { text: "Decline" }
    ]
  });

  const activatorManifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/payload-v1/acti-duplicate-payload.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  const activatorPlan = createPlan(activatorManifest, fixtureProfile);
  assert.equal(activatorPlan.operations[0].backend, "ckpe-bridge");
  assert.equal(activatorPlan.operations[1].backend, "mo2-mcp-patch-request");
  const activatorPatch = buildPatchRequest(activatorPlan);
  assert.equal(activatorPatch.records.length, 1);
  assert.equal(activatorPatch.records[0].formid, "EXM_ACTI_SourceDUPLICATE001");
  assert.deepEqual(activatorPatch.records[0].set_activator_payload, {
    fullName: "Payload Proof Activator",
    model: "Clutter\\Common\\Basket01.nif"
  });
});

test("creation fill spike fixtures require explicit unproven CK discovery mode", () => {
  const fixtureProfile = normalizeProfile(JSON.parse(fs.readFileSync(
    "fixtures/creation-fill-spike-v1/creation-fill-spike-v1.profile.json",
    "utf8"
  )));
  const fixtureReadback = JSON.parse(fs.readFileSync(
    "fixtures/creation-fill-spike-v1/creation-fill-spike-v1.readback.json",
    "utf8"
  ));

  const blockedReport = checkFixtureDirectory("fixtures/creation-fill-spike-v1", fixtureProfile, fixtureReadback);
  assert.equal(blockedReport.status, "FAIL");
  assert.equal(blockedReport.results[0].planSummary.manual, 10);

  const discoveryReport = checkFixtureDirectory("fixtures/creation-fill-spike-v1", fixtureProfile, fixtureReadback, {
    allowUnprovenCk: true
  });
  assert.equal(discoveryReport.status, "PASS");
  assert.equal(discoveryReport.mode, "discovery_allow_unproven_ck");
  assert.equal(discoveryReport.summary.total, 1);
  assert.equal(discoveryReport.results[0].planSummary.ready, 10);
  assert.equal(discoveryReport.results[0].verifySummary.PASS, 10);
  assert.deepEqual(
    discoveryReport.results[0].operations.map((operation) => operation.recordFamily),
    ["SPEL", "MGEF", "ENCH", "SCRL", "WEAP", "ARMO", "AMMO", "BOOK", "CONT", "MISC"]
  );

  const manifest = normalizeManifest(JSON.parse(fs.readFileSync(
    "fixtures/creation-fill-spike-v1/ten-record-create-fill.creation-authoring.json",
    "utf8"
  )), fixtureProfile);
  const plan = createPlan(manifest, fixtureProfile, { allowUnprovenCk: true });
  const packet = buildCkCommandPacket(plan);
  const createCommands = packet.commands.filter((command) => command.op === "createRecord");
  assert.equal(createCommands.length, 10);
  assert.equal(createCommands.every((command) => command.plugin === "CKRA_CreationFillSpikeV1.esp"), true);
  assert.equal(createCommands.every((command) => command.payload?.recordType), true);

  const badReadback = JSON.parse(JSON.stringify(fixtureReadback));
  badReadback.records.CKRA_SPIKE_Weapon.fields.DATA.weight = 99;
  const verify = verifyManifest(manifest, fixtureProfile, badReadback);
  assert.equal(verify.summary.FAIL, 1);
  assert.match(
    verify.results.find((result) => result.operationId === "create-weapon").message,
    /record payload readback does not match/
  );

  const passingDiscoveryReport = {
    schema: "creation-authoring.run-report.v1",
    status: "PASS",
    reportPath: "reports/creation-fill-spike-v1.strict.run-report.json",
    manifest: {
      project: manifest.project,
      game: manifest.game,
      sourcePlugin: manifest.sourcePlugin,
      output: manifest.output,
      metadata: manifest.metadata
    },
    phases: [
      {
        phase: "ck-apply",
        status: "PASS",
        adapterResult: {
          commands: createCommands.map((command) => ({
            ...command,
            status: "PASS",
            evidence: {
              operationId: command.operationId,
              target: command.target,
              recordFamily: command.recordFamily,
              activeGeneratedPluginOnly: true,
              mutationCommitted: true,
              saveCompleted: true
            }
          }))
        }
      },
      {
        phase: "verify",
        status: "PASS",
        report: verifyManifest(manifest, fixtureProfile, fixtureReadback)
      },
      {
        phase: "strict-gate",
        status: "PASS"
      }
    ],
    planOperations: plan.operations.map((item) => ({
      id: item.operation.id,
      kind: item.operation.kind,
      target: item.operation.target,
      recordFamily: item.operation.recordFamily,
      backend: item.backend
    }))
  };
  const ledger = buildProofLedgerFromRun(passingDiscoveryReport, {
    fixture: "fixtures/creation-fill-spike-v1/ten-record-create-fill.creation-authoring.json"
  });
  assert.equal(ledger.status, "FAIL");
  assert.equal(ledger.discoveryOnly, true);
  assert.equal(ledger.proofs.every((proof) => proof.missingCoverage.includes("supportClaimAllowed")), true);
});

function writeFixtureFile(root, relativePath, content = "{}\n") {
  const filePath = path.join(root, relativePath);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, content);
}

function testEspWithMessage({ formId, editorId }) {
  const tes4 = testRecord("TES4", Buffer.concat([
    testBinarySubrecord("HEDR", Buffer.from([0x48, 0xe1, 0xda, 0x3f, 0, 0, 0, 0, 0, 0, 0, 0])),
    testSubrecord("MAST", "Skyrim.esm"),
    testBinarySubrecord("DATA", Buffer.alloc(8))
  ]), 0);
  const message = testRecord("MESG", Buffer.concat([
    testSubrecord("EDID", editorId),
    testSubrecord("DESC", ""),
    testBinarySubrecord("INAM", Buffer.alloc(4)),
    testBinarySubrecord("DNAM", Buffer.from([1, 0, 0, 0]))
  ]), formId);
  const groupHeader = Buffer.alloc(24);
  groupHeader.write("GRUP", 0, 4, "ascii");
  groupHeader.writeUInt32LE(24 + message.length, 4);
  groupHeader.write("MESG", 8, 4, "ascii");
  groupHeader.writeUInt32LE(0, 12);
  return Buffer.concat([tes4, groupHeader, message]);
}

function testRecord(type, payload, formId) {
  const header = Buffer.alloc(24);
  header.write(type, 0, 4, "ascii");
  header.writeUInt32LE(payload.length, 4);
  header.writeUInt32LE(0, 8);
  header.writeUInt32LE(formId, 12);
  header.writeUInt16LE(44, 20);
  return Buffer.concat([header, payload]);
}

function testSubrecord(type, value) {
  return testBinarySubrecord(type, Buffer.from(`${value}\0`, "utf8"));
}

function testBinarySubrecord(type, data) {
  const header = Buffer.alloc(6);
  header.write(type, 0, 4, "ascii");
  header.writeUInt16LE(data.length, 4);
  return Buffer.concat([header, data]);
}

function parseTestSubrecords(payload) {
  const result = {};
  let offset = 0;
  while (offset < payload.length) {
    const type = payload.subarray(offset, offset + 4).toString("ascii");
    const size = payload.readUInt16LE(offset + 4);
    const data = payload.subarray(offset + 6, offset + 6 + size);
    result[type] = result[type] || [];
    if (["EDID", "FULL", "DESC", "ITXT"].includes(type)) {
      result[type].push(data.toString("utf8").replace(/\0$/, ""));
    } else {
      result[type].push(data);
    }
    offset += 6 + size;
  }
  return result;
}

function proofResult(overrides = {}) {
  return {
    status: "PASS",
    verifiedAt: "2026-05-24T00:00:00.000Z",
    backend: "mo2-mcp-patch-request",
    verifierStatus: "PASS",
    readbackStatus: "PASS",
    commandEvidenceStatus: "NOT_REQUIRED",
    coverage: {
      manifestOperation: true,
      backend: true,
      ckpeOrWriterHandler: true,
      ckCommandEvidence: true,
      readbackNormalizer: true,
      verifier: true,
      strictReport: true,
      proofFixture: true
    },
    missingCoverage: [],
    ...overrides
  };
}
