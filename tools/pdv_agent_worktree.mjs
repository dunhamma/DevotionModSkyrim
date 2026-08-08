#!/usr/bin/env node
// Per-agent git worktree manager for the Devotion (PDV) repo.
//
// Why this exists: multiple agents (Codex, Claude, Fable) share ONE primary
// checkout. During the 1.0 work a parallel agent switched branches mid-commit and
// four commits landed on the wrong branch; reconciling them cost a whole session.
// The fix is one isolated worktree per agent, so each agent commits to its own
// branch and can never be moved out from under another. This wraps the git
// plumbing with the two things that bit us: a SHORT worktree root (the repo's deep
// archive/ tree overruns Windows MAX_PATH under a long path -- a worktree under
// %TEMP%\...\scratchpad failed with "Filename too long"), and a consistent branch
// name off a known base.
//
// IMPORTANT -- what a worktree does and does NOT isolate:
//   Isolates : the git checkout + index + branch. Safe concurrent commits.
//   Shared   : the MO2 live tree (D:\...\mods\Devotion) that pdv_compile.mjs
//              deploys .pex into, and the game that loads it. Compiling is a
//              GLOBAL side effect no worktree can isolate. Treat compile/deploy as
//              a serialized, one-agent-at-a-time resource -- see
//              docs/agents/worktrees.md.
//
// Usage:
//   node tools/pdv_agent_worktree.mjs create <name> [--base <ref>] [--branch <b>]
//   node tools/pdv_agent_worktree.mjs list
//   node tools/pdv_agent_worktree.mjs remove <name> [--force]
//
//   name   short agent/session label (a-z0-9-), becomes the folder and, by
//          default, the branch agent/<name>.
//   --base ref to branch from (default: main).
//   --branch  explicit branch to create/checkout instead of agent/<name>.
//
// Root override: set PDV_WORKTREE_ROOT (default C:\pdv-wt). Keep it SHORT.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--base", "--branch", "--force", "--help", "--quiet", "--verify"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_agent_worktree" });

const ROOT = process.env.PDV_WORKTREE_ROOT || "C:\\pdv-wt";
const DEFAULT_BASE = "main";

function git(args, opts = {}) {
  return execFileSync("git", args, { encoding: "utf8", ...opts }).trim();
}

function fail(message) {
  console.error(`[pdv-worktree] ${message}`);
  process.exit(1);
}

function sanitize(name) {
  const clean = String(name || "").toLowerCase().replace(/[^a-z0-9-]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
  if (!clean) {
    fail("Provide a name made of letters, digits, or dashes.");
  }
  return clean;
}

function parseFlags(argv) {
  const flags = {};
  const positional = [];
  for (let i = 0; i < argv.length; i += 1) {
    if (argv[i] === "--base") flags.base = argv[++i];
    else if (argv[i] === "--branch") flags.branch = argv[++i];
    else if (argv[i] === "--force") flags.force = true;
    else positional.push(argv[i]);
  }
  return { flags, positional };
}

function branchExists(branch) {
  try {
    git(["rev-parse", "--verify", "--quiet", `refs/heads/${branch}`]);
    return true;
  } catch {
    return false;
  }
}

function create(name, flags) {
  const label = sanitize(name);
  const base = flags.base || DEFAULT_BASE;
  const branch = flags.branch || `agent/${label}`;
  const dir = path.join(ROOT, label);

  if (fs.existsSync(dir)) {
    fail(`Worktree path already exists: ${dir}. Pick another name or remove it first.`);
  }
  fs.mkdirSync(ROOT, { recursive: true });

  // Verify base resolves before we touch anything.
  try {
    git(["rev-parse", "--verify", "--quiet", base]);
  } catch {
    fail(`Base ref not found: ${base}`);
  }

  const args = ["worktree", "add"];
  if (branchExists(branch)) {
    // Resume an existing agent branch.
    args.push(dir, branch);
    console.log(`[pdv-worktree] Resuming existing branch ${branch}.`);
  } else {
    // Fresh branch off base.
    args.push("-b", branch, dir, base);
  }

  try {
    execFileSync("git", args, { stdio: "inherit" });
  } catch {
    fail(`git worktree add failed. If it was a MAX_PATH error, set PDV_WORKTREE_ROOT to a shorter path (current: ${ROOT}).`);
  }

  console.log("");
  console.log(`[pdv-worktree] Ready.`);
  console.log(`  path   : ${dir}`);
  console.log(`  branch : ${branch}  (off ${base})`);
  console.log(`  cd "${dir}"  and work there. Commit to ${branch}.`);
  console.log(`  Merge to main via PR when done, then: node tools/pdv_agent_worktree.mjs remove ${label}`);
  console.log("");
  console.log(`  Reminder: the MO2 live tree + compile are SHARED. Do not compile/deploy`);
  console.log(`  while another agent is mid-compile. See docs/agents/worktrees.md.`);
}

function list() {
  console.log(git(["worktree", "list"]));
}

function remove(name, flags) {
  const label = sanitize(name);
  const dir = path.join(ROOT, label);
  const args = ["worktree", "remove", dir];
  if (flags.force) args.push("--force");
  try {
    execFileSync("git", args, { stdio: "inherit" });
  } catch {
    fail(`git worktree remove failed for ${dir}. If it has uncommitted changes, re-run with --force (this discards them).`);
  }
  git(["worktree", "prune"]);
  console.log(`[pdv-worktree] Removed ${dir} and pruned.`);
}

const [command, ...rest] = process.argv.slice(2);
const { flags, positional } = parseFlags(rest);

if (command === "create") {
  if (!positional[0]) fail("Usage: create <name> [--base <ref>] [--branch <b>]");
  create(positional[0], flags);
} else if (command === "list") {
  list();
} else if (command === "remove") {
  if (!positional[0]) fail("Usage: remove <name> [--force]");
  remove(positional[0], flags);
} else {
  console.log("PDV per-agent worktree manager");
  console.log("");
  console.log("  node tools/pdv_agent_worktree.mjs create <name> [--base <ref>] [--branch <b>]");
  console.log("  node tools/pdv_agent_worktree.mjs list");
  console.log("  node tools/pdv_agent_worktree.mjs remove <name> [--force]");
  console.log("");
  console.log(`  Worktree root: ${ROOT} (override with PDV_WORKTREE_ROOT; keep it short).`);
  console.log("  See docs/agents/worktrees.md for the full convention.");
  if (command && command !== "help" && command !== "--help") {
    process.exit(1);
  }
}
