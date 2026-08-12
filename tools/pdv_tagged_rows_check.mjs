#!/usr/bin/env node
// General nine-column semantic-row gate. Pass files directly or --dir <folder>.
// --self-test runs the same shared validator against one committed known-good JoJ file.

import path from "node:path";
import { fileURLToPath } from "node:url";

import { runTaggedRowsCheck } from "./lib/pdv_tagged_rows_check.mjs";

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const argv = process.argv.slice(2);
if (argv.includes("--self-test")) {
  const unexpected = argv.filter((arg) => !["--self-test", "--json"].includes(arg));
  if (unexpected.length) throw new Error(`--self-test accepts only --json; unexpected: ${unexpected.join(", ")}`);
  const forwarded = [path.join(repo, "generated", "joj-rows", "InterestingNPCs.tagged.csv")];
  if (argv.includes("--json")) forwarded.push("--json");
  runTaggedRowsCheck({ argv: forwarded, repo, checkName: "taggedRowsSelfTest" });
} else {
  runTaggedRowsCheck({ argv, repo });
}
