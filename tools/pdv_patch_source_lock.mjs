#!/usr/bin/env node

import path from "node:path";
import { fileURLToPath } from "node:url";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";
import { validatePatchSourceLock, writePatchSourceLock } from "./lib/pdv_patch_source_lock.mjs";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE_ROOT = path.join(ROOT, "patch-source");
const args = process.argv.slice(2);
assertKnownFlags(args, new Set(["--check", "--relock"]), { toolName: "pdv_patch_source_lock" });
if (args.includes("--check") && args.includes("--relock")) throw new Error("Use either --check or --relock, not both.");

const report = args.includes("--relock") ? writePatchSourceLock(SOURCE_ROOT) : validatePatchSourceLock(SOURCE_ROOT);
console.log(JSON.stringify(report, null, 2));
