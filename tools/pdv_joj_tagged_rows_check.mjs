#!/usr/bin/env node
// Backward-compatible JoJ entrypoint. The reusable validator lives in lib so the
// core retrospective and future content audits use the same nine-column contract.

import path from "node:path";
import { fileURLToPath } from "node:url";

import { runTaggedRowsCheck } from "./lib/pdv_tagged_rows_check.mjs";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
runTaggedRowsCheck({
  repo,
  defaultRowsDir: path.join(repo, "generated", "joj-rows"),
  checkName: "jojTaggedRows",
  toolName: "pdv_joj_tagged_rows_check",
  allowDir: false,
});
