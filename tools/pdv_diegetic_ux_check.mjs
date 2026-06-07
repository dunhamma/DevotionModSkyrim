#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const projectRoot = process.cwd();
const manifestPath = path.join(projectRoot, "references", "authoring", "PDV_DiegeticUX.manifest.json");
const findings = [];

function add(status, check, detail, filePath = null) {
  findings.push({ status, check, detail, path: filePath });
}

function pass(check, detail, filePath = null) {
  add("PASS", check, detail, filePath);
}

function warn(check, detail, filePath = null) {
  add("WARN", check, detail, filePath);
}

function fail(check, detail, filePath = null) {
  add("FAIL", check, detail, filePath);
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8").replace(/\r\n/g, "\n");
}

function resolveRepoPath(filePath) {
  return path.isAbsolute(filePath) ? filePath : path.join(projectRoot, filePath);
}

function countLines(text) {
  return text.split("\n").length;
}

if (!fs.existsSync(manifestPath)) {
  fail("Diegetic UX manifest", "references/authoring/PDV_DiegeticUX.manifest.json is missing.", manifestPath);
} else {
  let manifest = null;
  try {
    manifest = JSON.parse(readText(manifestPath));
    pass("Diegetic UX manifest", "Manifest JSON parses.", manifestPath);
  } catch (error) {
    fail("Diegetic UX manifest", `Manifest JSON does not parse: ${error.message}`, manifestPath);
  }

  if (manifest) {
    if (manifest.schema === "pdv.diegetic_ux.manifest.v1") {
      pass("Diegetic UX manifest schema", "Schema is pdv.diegetic_ux.manifest.v1.", manifestPath);
    } else {
      fail("Diegetic UX manifest schema", `Unexpected schema: ${manifest.schema || "(missing)"}.`, manifestPath);
    }

    const scripts = manifest.sourcePromotion?.scripts || [];
    for (const script of scripts) {
      const scratchPath = resolveRepoPath(script.scratch);
      if (!fs.existsSync(scratchPath)) {
        fail("Diegetic UX source script", `${script.scriptName} scratch source is missing.`, scratchPath);
        continue;
      }
      const text = readText(scratchPath);
      if (text.includes(`Scriptname ${script.scriptName}`) || text.includes(`ScriptName ${script.scriptName}`)) {
        pass("Diegetic UX source script", `${script.scriptName} declares the expected Scriptname.`, scratchPath);
      } else {
        fail("Diegetic UX source script", `${script.scriptName} does not declare the expected Scriptname.`, scratchPath);
      }
    }

    for (const contract of manifest.requiredSourceContracts || []) {
      const filePath = resolveRepoPath(contract.file);
      if (!fs.existsSync(filePath)) {
        fail("Diegetic UX source contract", `${contract.file} is missing.`, filePath);
        continue;
      }

      const text = readText(filePath);
      for (const expected of contract.mustContain || []) {
        if (text.includes(expected)) {
          pass("Diegetic UX source contract", `${contract.file} contains: ${expected}`, filePath);
        } else {
          fail("Diegetic UX source contract", `${contract.file} is missing: ${expected}`, filePath);
        }
      }

      for (const forbidden of contract.mustNotContain || []) {
        if (text.includes(forbidden)) {
          fail("Diegetic UX source contract", `${contract.file} must not contain: ${forbidden}`, filePath);
        } else {
          pass("Diegetic UX source contract", `${contract.file} does not contain forbidden token: ${forbidden}`, filePath);
        }
      }

      for (const marker of contract.mustAlsoPreserveLiveMarkers || []) {
        if (text.includes(marker)) {
          pass("Diegetic UX live parity marker", `${contract.file} preserves: ${marker}`, filePath);
        } else {
          fail("Diegetic UX live parity marker", `${contract.file} is missing live marker: ${marker}`, filePath);
        }
      }
    }

    const managerScript = scripts.find((script) => script.scriptName === "PDV__ManagerQuest");
    if (managerScript) {
      const scratchPath = resolveRepoPath(managerScript.scratch);
      const livePath = managerScript.live;
      if (fs.existsSync(scratchPath) && fs.existsSync(livePath)) {
        const scratchText = readText(scratchPath);
        const liveText = readText(livePath);
        const scratchLines = countLines(scratchText);
        const liveLines = countLines(liveText);
        if (scratchLines >= liveLines) {
          pass("Diegetic UX manager live parity", `Scratch manager line count ${scratchLines} is not shorter than live manager ${liveLines}.`, scratchPath);
        } else {
          fail("Diegetic UX manager live parity", `Scratch manager line count ${scratchLines} is shorter than live manager ${liveLines}; this suggests stale baseline deletion risk.`, scratchPath);
        }
      } else if (!fs.existsSync(livePath)) {
        warn("Diegetic UX manager live parity", `Live manager path is unavailable for line-count comparison: ${livePath}.`, livePath);
      }
    }

    for (const quest of manifest.ckWriteContract?.quests || []) {
      if (quest.editorId && quest.script) {
        pass("Diegetic UX CK quest contract", `${quest.editorId} is declared with script ${quest.script}.`, manifestPath);
      } else {
        fail("Diegetic UX CK quest contract", "A quest contract is missing editorId or script.", manifestPath);
      }
    }

    for (const property of manifest.ckWriteContract?.managerProperties || []) {
      if (property.record && property.script && property.property && property.value) {
        pass("Diegetic UX CK manager property", `${property.record}.${property.property} -> ${property.value} is declared.`, manifestPath);
      } else {
        fail("Diegetic UX CK manager property", "A manager property contract is incomplete.", manifestPath);
      }
    }

    const d1RecordIds = (manifest.ckWriteContract?.d1Records || []).flatMap((entry) => entry.editorIds || []);
    if (d1RecordIds.length > 0) {
      pass("Diegetic UX D1 record contract", `${d1RecordIds.length} D1 record EditorIDs are declared.`, manifestPath);
    } else {
      fail("Diegetic UX D1 record contract", "No D1 record EditorIDs are declared.", manifestPath);
    }

    const plannerPath = path.join(projectRoot, "tools", "pdv_diegetic_ux_author.mjs");
    if (fs.existsSync(plannerPath)) {
      pass("Diegetic UX planner", "tools/pdv_diegetic_ux_author.mjs exists.", plannerPath);
      const planner = spawnSync(process.execPath, [plannerPath, "plan", "--json"], {
        cwd: projectRoot,
        encoding: "utf8",
        maxBuffer: 4 * 1024 * 1024
      });
      if (planner.status === 0) {
        try {
          const payload = JSON.parse(planner.stdout);
          if (payload.status === "PASS" && payload.mode === "dry-run-only" && payload.liveWriteBlocked === true) {
            pass("Diegetic UX planner", `Planner emits ${payload.plan?.stepCount || 0} dry-run-only steps.`, plannerPath);
          } else {
            fail("Diegetic UX planner", "Planner output is not PASS/dry-run-only/live-write-blocked.", plannerPath);
          }
        } catch (error) {
          fail("Diegetic UX planner", `Planner JSON could not be parsed: ${error.message}`, plannerPath);
        }
      } else {
        fail("Diegetic UX planner", `Planner failed: ${(planner.stderr || planner.stdout || "").trim()}`, plannerPath);
      }
    } else {
      fail("Diegetic UX planner", "tools/pdv_diegetic_ux_author.mjs is missing.", plannerPath);
    }

    const runbookPath = resolveRepoPath(manifest.authoringPlanner?.runbook || "");
    if (manifest.authoringPlanner?.mode === "dry-run-only") {
      pass("Diegetic UX planner contract", "Manifest declares authoringPlanner.mode dry-run-only.", manifestPath);
    } else {
      fail("Diegetic UX planner contract", "Manifest must declare authoringPlanner.mode dry-run-only.", manifestPath);
    }

    if (manifest.authoringPlanner?.command === "node tools/pdv_diegetic_ux_author.mjs plan --json") {
      pass("Diegetic UX planner contract", "Manifest declares the canonical planner command.", manifestPath);
    } else {
      fail("Diegetic UX planner contract", "Manifest must declare the canonical planner command.", manifestPath);
    }

    if (runbookPath && fs.existsSync(runbookPath)) {
      const runbookText = readText(runbookPath);
      const requiredRunbookTokens = [
        "node .\\tools\\pdv_diegetic_ux_check.mjs",
        "node .\\tools\\pdv_diegetic_ux_author.mjs plan --json",
        "D1Enabled = false",
        "Do not merge this worktree into `main` just to test CK writes",
        "No live step is implied by this runbook"
      ];
      for (const token of requiredRunbookTokens) {
        if (runbookText.includes(token)) {
          pass("Diegetic UX runbook", `Runbook contains: ${token}`, runbookPath);
        } else {
          fail("Diegetic UX runbook", `Runbook is missing: ${token}`, runbookPath);
        }
      }
    } else {
      fail("Diegetic UX runbook", "Declared runbook is missing.", runbookPath || manifestPath);
    }

    const directorSource = resolveRepoPath("scratch/p2-toast-panel-fix/PDV_DiegeticDirector.psc");
    if (fs.existsSync(directorSource)) {
      const directorText = readText(directorSource);
      for (const property of manifest.ckWriteContract?.directorProperties || []) {
        const propertyPattern = `Property ${property.name}`;
        if (directorText.includes(propertyPattern)) {
          pass("Diegetic UX director VMAD source", `Director declares property ${property.name}.`, directorSource);
        } else {
          fail("Diegetic UX director VMAD source", `Director does not declare manifest property ${property.name}.`, directorSource);
        }
      }
    }

    const directorProperties = manifest.ckWriteContract?.directorProperties || [];
    const d1PropertyTargets = new Set(directorProperties.filter((property) => property.requiredForD1Live).map((property) => property.value));
    for (const editorId of d1RecordIds) {
      if (d1PropertyTargets.has(editorId)) {
        pass("Diegetic UX D1 property coverage", `${editorId} is represented as a director property.`, manifestPath);
      } else {
        fail("Diegetic UX D1 property coverage", `${editorId} is not represented as a director property.`, manifestPath);
      }
    }
  }
}

const failCount = findings.filter((finding) => finding.status === "FAIL").length;
const warnCount = findings.filter((finding) => finding.status === "WARN").length;
const passCount = findings.filter((finding) => finding.status === "PASS").length;
const summary = {
  status: failCount === 0 ? "PASS" : "FAIL",
  passCount,
  warnCount,
  failCount,
  findings
};

console.log(JSON.stringify(summary, null, 2));
process.exit(failCount === 0 ? 0 : 1);
