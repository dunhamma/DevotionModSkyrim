import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, "..");
const patcher = path.join(projectRoot, "tools", "pdv_patch.mjs");

test("blocks candidate rules with unresolved payload references", () => {
  const rules = writeRules({
    id: "missing-payload-test",
    rules: [
      {
        id: "missing-keyword",
        operation: "keyword_add",
        target: {
          plugins: ["Skyrim.esm"],
          signatures: ["BOOK"],
          editorIds: ["MQ103FarengarBook"],
        },
        payload: {
          keywords: ["PDV_KW_DOES_NOT_EXIST"],
        },
        provenance: {
          status: "candidate",
          source: "test",
          comment: "Intentional missing keyword.",
        },
      },
    ],
  });

  const payload = runJson(["validate", "--rules", rules]);
  assert.equal(payload.summary.buildReady, 0);
  assert.equal(payload.summary.buildBlocked, 1);
  assert.equal(payload.evaluations[0].status, "BLOCKED");
  assert.match(payload.evaluations[0].messages.join("\n"), /could not be resolved/);
});

test("keeps tooling examples plan-only even when payloads resolve", () => {
  const rules = writeRules({
    id: "tooling-plan-only-test",
    rules: [
      {
        id: "tooling-formlist",
        operation: "formlist_inject",
        target: {
          plugins: ["PlayerDevotion_Framework.esp"],
          signatures: ["QUST"],
          editorIds: ["PDV_State_NordPantheonBaseline"],
        },
        payload: {
          formList: "PDV_FLST_StateTracks_DevOnly",
        },
        provenance: {
          status: "tooling-example",
          source: "test",
          comment: "Resolved but not buildable by default.",
        },
      },
    ],
  });

  const payload = runJson(["build", "--dry-run", "--rules", rules]);
  assert.equal(payload.summary.planOnly, 1);
  assert.equal(payload.build.buildRuleCount, 0);
  assert.equal(payload.build.patchRecordCount, 0);
  assert.equal(payload.build.skippedPlanOnlyRuleCount, 1);
});

test("default dry-run build emits approved rules and skips candidates", () => {
  const rules = writeRules({
    id: "approved-default-test",
    rules: [
      {
        id: "approved-temple-location",
        operation: "keyword_add",
        target: {
          plugins: ["Skyrim.esm"],
          signatures: ["LCTN"],
          editorIds: ["ShrineofAzuraLocation"],
        },
        payload: {
          keywords: ["Skyrim.esm:01CD56"],
        },
        provenance: {
          status: "approved",
          source: "test",
          comment: "Approved live rule.",
        },
      },
      {
        id: "candidate-formlist",
        operation: "formlist_inject",
        target: {
          plugins: ["PlayerDevotion_Framework.esp"],
          signatures: ["QUST"],
          editorIds: ["PDV_State_NordPantheonBaseline"],
        },
        payload: {
          formList: "PDV_FLST_StateTracks_DevOnly",
        },
        provenance: {
          status: "candidate",
          source: "test",
          comment: "Candidate should not emit by default.",
        },
      },
    ],
  });

  const payload = runJson(["build", "--dry-run", "--rules", rules]);
  assert.equal(payload.summary.buildReady, 2);
  assert.equal(payload.build.buildRuleCount, 1);
  assert.equal(payload.build.skippedCandidateRuleCount, 1);
  assert.equal(payload.build.patchRecordCount, 1);
  assert.equal(payload.build.patchRequest.records[0].formid, "Skyrim.esm:092497");
});

test("explicit candidate dry-run emits resolved candidate rules", () => {
  const rules = writeRules({
    id: "candidate-opt-in-test",
    rules: [
      {
        id: "candidate-formlist",
        operation: "formlist_inject",
        target: {
          plugins: ["PlayerDevotion_Framework.esp"],
          signatures: ["QUST"],
          editorIds: ["PDV_State_NordPantheonBaseline"],
        },
        payload: {
          formList: "PDV_FLST_StateTracks_DevOnly",
        },
        provenance: {
          status: "candidate",
          source: "test",
          comment: "Candidate can emit only with the explicit flag.",
        },
      },
    ],
  });

  const payload = runJson(["build", "--dry-run", "--allow-candidates", "--rules", rules]);
  assert.equal(payload.build.allowCandidates, true);
  assert.equal(payload.build.buildRuleCount, 1);
  assert.equal(payload.build.skippedCandidateRuleCount, 0);
  assert.equal(payload.build.patchRecordCount, 1);
  assert.equal(payload.build.patchRequest.records[0].formid, "PlayerDevotion_Framework.esp:0499DB");
});

test("dry-run build emits the approved subset when another rule is blocked", () => {
  const rules = writeRules({
    id: "mixed-ready-blocked-test",
    rules: [
      {
        id: "ready-temple-location",
        operation: "keyword_add",
        target: {
          plugins: ["Skyrim.esm"],
          signatures: ["LCTN"],
          editorIds: ["ShrineofAzuraLocation"],
        },
        payload: {
          keywords: ["Skyrim.esm:01CD56"],
        },
        provenance: {
          status: "approved",
          source: "test",
          comment: "Approved live rule.",
        },
      },
      {
        id: "blocked-keyword",
        operation: "keyword_add",
        target: {
          plugins: ["Skyrim.esm"],
          signatures: ["BOOK"],
          editorIds: ["MQ103FarengarBook"],
        },
        payload: {
          keywords: ["PDV_KW_DOES_NOT_EXIST"],
        },
        provenance: {
          status: "candidate",
          source: "test",
          comment: "Intentional blocked rule.",
        },
      },
    ],
  });

  const payload = runJson(["build", "--dry-run", "--rules", rules]);
  assert.equal(payload.summary.buildReady, 1);
  assert.equal(payload.summary.buildBlocked, 1);
  assert.equal(payload.build.patchRecordCount, 1);
  assert.equal(payload.build.patchRequest.records[0].formid, "Skyrim.esm:092497");
});

test("approved Temple LCTN rules produce exactly six patch records", () => {
  const rules = path.join(projectRoot, "references", "authoring", "patch-rules", "PDV_Phase19TempleLocationRules.json");
  const payload = runJson(["build", "--dry-run", "--rules", rules]);
  assert.equal(payload.summary.buildReady, 6);
  assert.equal(payload.build.buildRuleCount, 6);
  assert.equal(payload.build.patchRecordCount, 6);
  assert.deepEqual(
    payload.build.patchRequest.records.map((record) => record.formid).sort(),
    [
      "Dawnguard.esm:01379F",
      "Skyrim.esm:0240E6",
      "Skyrim.esm:06E830",
      "Skyrim.esm:092497",
      "Skyrim.esm:0F5BA5",
      "Skyrim.esm:0F5BA7",
    ],
  );
  for (const record of payload.build.patchRequest.records) {
    assert.deepEqual(record.add_keywords, ["Skyrim.esm:01CD56"]);
  }
});

test("non-dry-run build refuses blocked rules before writing", () => {
  const rules = writeRules({
    id: "blocked-build-refusal-test",
    rules: [
      {
        id: "blocked-keyword",
        operation: "keyword_add",
        target: {
          plugins: ["Skyrim.esm"],
          signatures: ["BOOK"],
          editorIds: ["MQ103FarengarBook"],
        },
        payload: {
          keywords: ["PDV_KW_DOES_NOT_EXIST"],
        },
        provenance: {
          status: "candidate",
          source: "test",
          comment: "Intentional blocked rule.",
        },
      },
    ],
  });

  const result = run(["build", "--rules", rules]);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Refusing to build with 1 build-blocked rule/);
});

function writeRules({ id, rules }) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "pdv-patch-test-"));
  const filePath = path.join(dir, `${id}.json`);
  fs.writeFileSync(
    filePath,
    `${JSON.stringify({
      ruleType: "pdv_patch_rules_v0",
      id,
      title: id,
      rules: rules.map((rule) => ({
        description: rule.description || rule.id,
        ...rule,
      })),
    }, null, 2)}\n`,
    "utf8",
  );
  return filePath;
}

function runJson(args) {
  const result = run([...args, "--json"]);
  assert.equal(result.status, 0, result.stderr || result.stdout);
  return JSON.parse(result.stdout);
}

function run(args) {
  return spawnSync(process.execPath, [patcher, ...args], {
    cwd: projectRoot,
    encoding: "utf8",
    timeout: 120_000,
    maxBuffer: 128 * 1024 * 1024,
    windowsHide: true,
  });
}
