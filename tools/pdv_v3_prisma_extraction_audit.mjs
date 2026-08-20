#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE = path.join(ROOT, "live-source", "Scripts", "Source");
const REGION_FILE = path.join(ROOT, "references", "authoring", "PDV_2_0RegionMap.json");
const CONTRACT_FILE = path.join(ROOT, "references", "authoring", "PDV_2_0ModuleContracts.manifest.json");
const MANAGER_FILE = path.join(SOURCE, "PDV__ManagerQuest.psc");
const PRESENTER_FILE = path.join(SOURCE, "PDV_PrismaPresenter.psc");
const ORIGIN_FILES = [
  "PDV_OriginRuntimeBase.psc",
  "PDV_OriginRuntime_Altmer.psc",
  "PDV_OriginRuntime_Argonian.psc",
  "PDV_OriginRuntime_Bosmer.psc",
  "PDV_OriginRuntime_Breton.psc",
  "PDV_OriginRuntime_Dunmer.psc",
  "PDV_OriginRuntime_Imperial.psc",
  "PDV_OriginRuntime_Khajiit.psc",
  "PDV_OriginRuntime_Nord.psc",
  "PDV_OriginRuntime_Orc.psc",
  "PDV_OriginRuntime_Redguard.psc",
];
const ORIGIN_VIRTUALS = [
  "GetQuasiPatronName",
  "GetQuasiPatronSymbol",
  "GetQuasiPatronTierLabel",
  "GetBookOfDaysSummary",
  "GetBookOfDaysPathFallbackLabel",
  "GetMcmSummaryLine",
  "GetMcmModeLine",
];
const PRESENTATION_HOOKS = [
  "GetPanelQuasiPatronName",
  "GetPanelQuasiPatronSymbol",
  "GetPanelQuasiPatronTierLabel",
  "BuildBookOfDaysSummary",
  "GetBookOfDaysPathStatusLabel",
  "GetSurveyDevotionText",
  "GetPlayerMcmSummaryLine",
  "GetPlayerMcmModeLine",
];

let passCount = 0;
let failCount = 0;
function pass(message) { passCount += 1; console.log(`[PASS] ${message}`); }
function fail(message) { failCount += 1; console.error(`[FAIL] ${message}`); }
function check(condition, message) { condition ? pass(message) : fail(message); }
function read(file) { return fs.readFileSync(file, "utf8"); }
function declarations(source) {
  return new Set([...source.matchAll(/^[ \t]*(?:(?:[A-Za-z_]\w*(?:\[\])?)[ \t]+)?Function[ \t]+([A-Za-z_]\w*)[ \t]*\(/gim)].map((match) => match[1]));
}
function functionBody(source, name) {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return source.match(new RegExp(`^[ \\t]*(?:(?:[A-Za-z_]\\w*(?:\\[\\])?)[ \\t]+)?Function[ \\t]+${escaped}[ \\t]*\\([^\\r\\n]*\\)[\\s\\S]*?^[ \\t]*EndFunction[ \\t]*$`, "im"))?.[0] ?? "";
}

const region = JSON.parse(read(REGION_FILE)).modules.PRISMA;
const contract = JSON.parse(read(CONTRACT_FILE)).modules.PRISMA;
const manager = read(MANAGER_FILE);
const presenter = read(PRESENTER_FILE);
const expected = region.functions.map((entry) => entry.name);
const managerDecls = declarations(manager);
const presenterDecls = declarations(presenter);

check(region.targetScript === "PDV_PrismaPresenter", "Region map targets PDV_PrismaPresenter.");
check(expected.length === 114, `Region map carries the current 114-function PRISMA inventory (${expected.length}).`);
const absent = expected.filter((name) => !presenterDecls.has(name));
const stranded = expected.filter((name) => managerDecls.has(name));
check(absent.length === 0, `All mapped PRISMA functions reside in the presenter${absent.length ? `; absent: ${absent.join(", ")}` : ""}.`);
check(stranded.length === 0, `No mapped PRISMA function remains manager-resident${stranded.length ? `; stranded: ${stranded.join(", ")}` : ""}.`);
check(/PDV_PrismaPresenter[ \t]+Property[ \t]+Prisma[ \t]+Auto/i.test(manager), "Manager exposes the presenter back-reference.");
check(/PDV__ManagerQuest[ \t]+Property[ \t]+Manager[ \t]+Auto/i.test(presenter), "Presenter exposes the manager back-reference.");

for (const fileName of ORIGIN_FILES) {
  const fileDecls = declarations(read(path.join(SOURCE, fileName)));
  const missing = ORIGIN_VIRTUALS.filter((name) => !fileDecls.has(name));
  check(missing.length === 0, `${fileName} implements the seven presentation virtuals${missing.length ? `; missing: ${missing.join(", ")}` : ""}.`);
}

for (const name of PRESENTATION_HOOKS) {
  const body = functionBody(presenter, name);
  const raceConstants = new Set(body.match(/\bORIGIN_(?:ALTMER|ARGONIAN|BOSMER|BRETON|DUNMER|IMPERIAL|KHAJIIT|NORD|ORC|REDGUARD)\b/g) ?? []);
  check(body.includes("Manager.OriginRuntime."), `${name} delegates race-owned content through OriginRuntime.`);
  check(raceConstants.size <= 1, `${name} contains no multi-race content switch${raceConstants.size > 1 ? `; constants: ${[...raceConstants].join(", ")}` : ""}.`);
}

const externalCalls = new Set();
for (const fileName of fs.readdirSync(SOURCE).filter((name) => name.endsWith(".psc") && name !== "PDV_PrismaPresenter.psc")) {
  const source = read(path.join(SOURCE, fileName));
  for (const match of source.matchAll(/(?<![A-Za-z0-9_])(?:(?:PDV_Manager|Manager)\.)?Prisma\.([A-Za-z_]\w*)[ \t]*\(/g)) externalCalls.add(match[1]);
}
const declaredPublic = new Set(contract.public.map((entry) => entry.name));
const missingPublic = [...externalCalls].filter((name) => !declaredPublic.has(name)).sort();
const stalePublic = [...declaredPublic].filter((name) => !externalCalls.has(name)).sort();
check(externalCalls.size === 48, `External call graph exposes the current 48-function public surface (${externalCalls.size}).`);
check(missingPublic.length === 0, `Contract includes every externally called function${missingPublic.length ? `; missing: ${missingPublic.join(", ")}` : ""}.`);
check(stalePublic.length === 0, `Contract has no stale public functions${stalePublic.length ? `; stale: ${stalePublic.join(", ")}` : ""}.`);
check(contract.privateCount === 114 - externalCalls.size, `Contract private count is ${114 - externalCalls.size} (${contract.privateCount}).`);

console.log(`PDV V3 PRISMA extraction audit: PASS=${passCount}, FAIL=${failCount}`);
process.exitCode = failCount === 0 ? 0 : 1;
