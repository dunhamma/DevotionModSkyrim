#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT=path.resolve(path.dirname(fileURLToPath(import.meta.url)),"..");
const SOURCE=path.join(ROOT,"live-source","Scripts","Source");
const MANAGER=path.join(SOURCE,"PDV__ManagerQuest.psc");
const MODULE=path.join(SOURCE,"PDV_DebugRuntime.psc");
const MCM=path.join(SOURCE,"PDV_MCM.psc");
const REGION=path.join(ROOT,"references","authoring","PDV_2_0RegionMap.json");
const CONTRACT=path.join(ROOT,"references","authoring","PDV_2_0ModuleContracts.manifest.json");
let passes=0,failures=0;
function check(value,message){if(value){passes+=1;console.log(`[PASS] ${message}`);}else{failures+=1;console.error(`[FAIL] ${message}`);}}
function read(file){return fs.readFileSync(file,"utf8");}
function declarations(source){return [...source.matchAll(/^[ \t]*(?:(?:[A-Za-z_]\w*(?:\[\])?)[ \t]+)?Function[ \t]+([A-Za-z_]\w*)[ \t]*\(/gim)].map(match=>match[1]);}

const manager=read(MANAGER),module=read(MODULE),mcm=read(MCM);
const managerDebug=declarations(manager).filter(name=>name.startsWith("Debug"));
const moduleDebug=declarations(module).filter(name=>name.startsWith("Debug"));
const region=JSON.parse(read(REGION)).modules;
const contract=JSON.parse(read(CONTRACT)).modules.DEBUG;
check(moduleDebug.length===136,`DebugRuntime defines the current 136-function harness (${moduleDebug.length}).`);
check(new Set(moduleDebug).size===136,"DebugRuntime has no duplicate Debug function definitions.");
check(managerDebug.length===0,`Manager retains no Debug function body (${managerDebug.length}).`);
check(region.DEBUG?.targetScript==="PDV_DebugRuntime"&&region.DEBUG.functions.length===136,"Region map homes all 136 Debug functions to PDV_DebugRuntime.");
check(!region.MANAGER.functions.some(entry=>entry.name.startsWith("Debug")),"Region map leaves no Debug function under MANAGER.");
check(/PDV_DebugRuntime[ \t]+Property[ \t]+DebugRuntime[ \t]+Auto/i.test(manager),"Manager exposes the DebugRuntime reference.");
check(/DebugRuntime\.OriginRuntime[ \t]*=[ \t]*picked/.test(manager),"Origin binding propagates into DebugRuntime.");
for(const token of ["Int Property DebugCommand = 0 Auto","Int Property DebugIndex = -1 Auto","Float Property DebugValue = 0.0 Auto","Int Property DebugSignalType = 0 Auto","Function RunDebugCommand()"]){check(manager.includes(token),`Manager retains ${token}.`);}
for(const name of ["PDV_Manager","LedgerRuntime","OriginRuntime","DaedricRuntime","FavorRuntime","PDV_QuestReactionRuntimeService","PDV_CurseStateService","PDV_HircinePath"]){check(new RegExp(`Property[ \\t]+${name}[ \\t]+Auto`).test(module),`DebugRuntime declares ${name}.`);}
check(!/\bGlobal[ \t]+Function[ \t]+Debug|\bFunction[ \t]+Debug[A-Za-z_]\w*[^\r\n]*\bGlobal\b/i.test(module),"No Debug function is Global or console-callable.");
const managerRefs=new Set(["PDV_Manager"]);
for(const match of mcm.matchAll(/\bPDV__ManagerQuest[ \t]+([A-Za-z_]\w*)/g))managerRefs.add(match[1]);
const directManagerDebug=[];
for(const owner of managerRefs){
 const pattern=new RegExp(`\\b${owner}\\.Debug(?!Runtime\\.)[A-Z][A-Za-z_]\\w*[ \\t]*\\(`,"g");
 for(const match of mcm.matchAll(pattern))directManagerDebug.push(match[0]);
}
check(directManagerDebug.length===0,`MCM has no direct manager-owned Debug call${directManagerDebug.length?`; found: ${directManagerDebug.join(", ")}`:""}.`);
check(/\.DebugRuntime\.Debug[A-Z]/.test(mcm),"MCM reaches the harness through manager.DebugRuntime.");

const external=new Set();
for(const fileName of fs.readdirSync(SOURCE).filter(name=>name.endsWith(".psc")&&name!=="PDV_DebugRuntime.psc")){
 const source=read(path.join(SOURCE,fileName));
 for(const name of moduleDebug)if(new RegExp(`(?<![A-Za-z0-9_])${name}[ \\t]*\\(`).test(source))external.add(name);
}
const declaredPublic=new Set(contract.public.map(entry=>entry.name));
const missing=[...external].filter(name=>!declaredPublic.has(name)).sort();
const stale=[...declaredPublic].filter(name=>!external.has(name)).sort();
check(external.size===111,`External call graph exposes 111 Debug functions (${external.size}).`);
check(missing.length===0,`Contract includes every externally called Debug function${missing.length?`; missing: ${missing.join(", ")}`:""}.`);
check(stale.length===0,`Contract has no stale public Debug function${stale.length?`; stale: ${stale.join(", ")}`:""}.`);
check(contract.privateCount===25,`Contract records the 25 module-internal helpers (${contract.privateCount}).`);
console.log(`PDV V3 DEBUG extraction audit: PASS=${passes}, FAIL=${failures}`);
process.exitCode=failures?1:0;
