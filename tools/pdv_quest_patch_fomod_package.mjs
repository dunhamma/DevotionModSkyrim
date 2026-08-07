#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const PACKAGE_ROOT = path.join(ROOT, "dist", "PDV_QuestModPatches_FOMOD");
const outputArg = process.argv.indexOf("--output");
const output = path.resolve(ROOT, outputArg >= 0 ? process.argv[outputArg + 1] : "dist/PDV-QuestModPatchHub-ARR25-Experimental-20260807.zip");
if (outputArg >= 0 && !process.argv[outputArg + 1]) throw new Error("--output requires a path");
if (fs.existsSync(output)) throw new Error(`Refusing to overwrite existing archive: ${output}`);

execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_patch_fomod_generate.mjs")], { cwd: ROOT, stdio: "inherit" });
execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_patch_fomod_validate.mjs")], { cwd: ROOT, stdio: "inherit" });

fs.mkdirSync(path.dirname(output), { recursive: true });
const source = `${PACKAGE_ROOT.replaceAll("'", "''")}\\*`;
const destination = output.replaceAll("'", "''");
execFileSync("powershell", ["-NoProfile", "-Command", `$ErrorActionPreference='Stop'; Compress-Archive -LiteralPath (Get-ChildItem -LiteralPath '${PACKAGE_ROOT.replaceAll("'", "''")}' | ForEach-Object {$_.FullName}) -DestinationPath '${destination}' -CompressionLevel Optimal`], { cwd: ROOT, stdio: "inherit" });
execFileSync(process.execPath, [path.join(ROOT, "tools", "pdv_quest_patch_fomod_validate.mjs"), "--archive", path.relative(ROOT, output), "--write-receipt"], { cwd: ROOT, stdio: "inherit" });

console.log(`Built ${path.relative(ROOT, output).replaceAll("\\", "/")}`);
