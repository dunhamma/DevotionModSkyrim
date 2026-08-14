#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

assertKnownFlags(process.argv.slice(2), new Set(["--self-test"]), { toolName: "pdv_prisma_toast_cardinality_audit" });

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const appPath = path.join(repoRoot, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "app.js");
const nativePath = path.join(repoRoot, "native", "DevotionPrismaBridge", "src", "main.cpp");
const indexPath = path.join(repoRoot, "native", "DevotionPrismaBridge", "mod", "PrismaUI", "views", "Devotion", "index.html");
const managerPath = path.join(repoRoot, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
const appSource = fs.readFileSync(appPath, "utf8");
const nativeSource = fs.readFileSync(nativePath, "utf8");
const indexSource = fs.readFileSync(indexPath, "utf8");
const managerSource = fs.readFileSync(managerPath, "utf8");

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function toastKey(copy) {
  return [
    copy.event || "",
    copy.symbol || copy.mark || "",
    copy.title || "",
    copy.message || copy.text || "",
    copy.source || "",
    copy.correlation || "",
  ].join("|");
}

function accepts(recent, copy, now) {
  const key = toastKey(copy);
  if (recent.has(key) && now - recent.get(key) < 2200) {
    return false;
  }
  recent.set(key, now);
  return true;
}

assert(appSource.includes('text(copy.correlation, "")'), "toast correlation is absent from the UI dedupe key");
assert((appSource.match(/traceToast\("receipt", payload\.toast\)/g) || []).length >= 2, "overlay/UI receipt traces are absent");
assert(appSource.includes('traceToast("dedupe", copy)'), "toast dedupe trace is absent");
assert(appSource.includes('traceToast("render", copy)'), "toast render trace is absent");
assert(managerSource.includes('correlationPrefix = "\\\"correlation\\\":\\\""'), "Papyrus does not expose the logical reaction correlation at the overlay top level");
assert(nativeSource.includes('FindTopLevelKey(a_payload, "correlation", &correlation)'), "native top-level correlation reader is absent");
assert(nativeSource.includes('TraceToastOverlay("papyrus_receipt", overlayPayload)'), "native receipt trace is absent");
assert(nativeSource.includes('TraceToastOverlay("interop_dispatch", a_payload)'), "native Interop dispatch trace is absent");
const cacheBusts = [...indexSource.matchAll(/(?:styles\.css|app\.js)\?v=([^"']+)/g)].map((match) => match[1]);
assert(cacheBusts.length === 2 && cacheBusts[0] === cacheBusts[1], "Prisma stylesheet and script cache-bust values must match");

const baseToast = {
  symbol: "stuhn",
  tone: "good",
  title: "A deed marked",
  message: "Stuhn marks your deed.",
};
const distinctJobs = ["v3qr_2", "v3qr_3", "v3qr_4", "v3qr_5"].map((correlation) => ({ ...baseToast, correlation }));
const distinctRecent = new Map();
assert(distinctJobs.filter((toast) => accepts(distinctRecent, toast, 0)).length === 4, "four logical jobs with distinct correlations must all render");

const duplicateRecent = new Map();
const sameJob = { ...baseToast, correlation: "v3qr_2" };
assert([0, 100, 200, 300].filter((now) => accepts(duplicateRecent, sameJob, now)).length === 1, "an exact duplicate logical job must remain suppressed");

console.log("PASS: Prisma toast cardinality correlation and trace contract");
