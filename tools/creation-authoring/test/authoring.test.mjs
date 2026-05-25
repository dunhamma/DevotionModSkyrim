import test from "node:test";
import assert from "node:assert/strict";
import { analyzeDrift, buildCkCommandPacket, buildPatchRequest, buildReviewJson, createPlan, evaluatePromotionGates, handleAuthoringRequest, migratePdvAuthorManifest, normalizeManifest, normalizeMo2RecordDetail, normalizeProfile, parseToolResult, promoteRunReport, runPipeline, verifyManifest } from "../src/index.mjs";
import { pipeServerNameFromPath } from "../src/ck-ipc-adapter.mjs";

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

test("normalizes Windows named-pipe paths for the PowerShell fallback", () => {
  assert.equal(pipeServerNameFromPath("\\\\.\\pipe\\CreationKitAuthoringBridge"), "CreationKitAuthoringBridge");
  assert.equal(pipeServerNameFromPath("//./pipe/CreationKitAuthoringBridge"), "CreationKitAuthoringBridge");
  assert.equal(pipeServerNameFromPath("CreationKitAuthoringBridge"), "CreationKitAuthoringBridge");
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
  }, profile);

  const plan = createPlan(ckManifest, profile);
  const packet = buildCkCommandPacket(plan);
  assert.equal(packet.schema, "creation-authoring.ck-command-packet.v1");
  assert.equal(packet.commands.some((command) => command.op === "addStoryManagerNode"), true);
  assert.equal(packet.verifierExpectations.length, 1);
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

test("routes planned CK record creation and dependent wiring through CKPE", () => {
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
  assert.equal(plan.summary.ready, 2);
  assert.equal(plan.operations[0].backend, "ckpe-bridge");
  assert.equal(plan.operations[1].backend, "ckpe-bridge");
  assert.equal(plan.operations[0].targetResolution.plannedCreate, true);
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

  const packet = buildCkCommandPacket(createPlan(createManifest, ckpeProfile));
  assert.equal(packet.commands.some((command) => command.op === "createRecord"), true);
  assert.equal(packet.commands.some((command) => command.op === "setArrayProperty"), true);
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
  assert.equal(promotion.status, "REQUESTED");
  assert.equal(promotion.phases[0].status, "PASS");
  assert.equal(promotion.phases.find((phase) => phase.phase === "structured-merge").status, "REQUESTED");
});

test("promotion can delegate backup and structured merge to a merge runner", async () => {
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

  let receivedMergeRequest = null;
  const promotion = await promoteRunReport(runReport, profile, {
    approved: true,
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
