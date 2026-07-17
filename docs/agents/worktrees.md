# Per-agent worktrees

## Why

Multiple agents (Codex, Claude, Fable) work in this repo. When they share **one**
checkout, they collide: during the 1.0 push a parallel agent switched branches
mid-commit and four commits landed on the wrong branch, costing a session to
reconcile. Each agent gets its **own git worktree** so commits can never be moved
out from under another agent.

## What a worktree does and does NOT isolate

| Resource | Isolated per worktree? |
|---|---|
| Git checkout, index, current branch | **Yes** — safe concurrent commits |
| `.git` history / refs / tags | Shared (one repo) — normal git |
| **The MO2 live tree** (`D:\Wabbajack\modlists\Anvil\mods\Devotion`) | **No** |
| **Compiling / deploying `.pex`** | **No** — a global side effect |
| The running game | **No** |

The second half is the one that bites. `pdv_compile.mjs` deploys bytecode into the
**shared** MO2 live tree, and the game loads from it. Two agents compiling at once
race on the same files, and compiling one branch's feature can sweep it into
another branch's release package (this is exactly how the bard hook reached the
1.0 zip). A worktree cannot fix this.

**Rule: treat compile + deploy as a serialized, one-agent-at-a-time resource.**
Do not run `pdv_compile.mjs` (or anything that writes the live tree) while another
agent is mid-compile. Coordinate, or compile from the trunk checkout only.

## Trunk model (post-1.0)

- **`main` is the trunk.** It is always releasable; releases are tagged here
  (`v1.0.0` is the first). Trunk infrastructure and merged features live here.
- **Feature work happens in a per-agent worktree off `main`**, on a short-lived
  branch, merged back via PR and then deleted — not left as a long-lived branch.
- The pile of stale `claude/*`, `beta/*`, and second-trunk branches from before
  1.0 should be pruned or merged; they are not part of this model.

## Commands

```
node tools/pdv_agent_worktree.mjs create <name> [--base main] [--branch <b>]
node tools/pdv_agent_worktree.mjs list
node tools/pdv_agent_worktree.mjs remove <name> [--force]
```

- `<name>` is a short session/agent label (`a-z0-9-`). It becomes the folder and,
  by default, the branch `agent/<name>`.
- Worktrees are created under **`C:\pdv-wt\<name>`** by default. Keep the root
  short: the repo's deep `archive/` tree overruns Windows MAX_PATH under a long
  path (a worktree under a long `%TEMP%` path fails with *"Filename too long"*).
  Override with `PDV_WORKTREE_ROOT`.

### Typical flow

```
node tools/pdv_agent_worktree.mjs create fix-altmer-toast
cd C:\pdv-wt\fix-altmer-toast          # branch agent/fix-altmer-toast off main
# ... edit, commit to the agent branch ...
# open a PR agent/fix-altmer-toast -> main, merge, then:
cd C:\Users\Admin\Documents\Devotion Mod Project
node tools/pdv_agent_worktree.mjs remove fix-altmer-toast
```

## Line endings

`.psc` under `live-source/` is pinned `eol=lf` in `.gitattributes`, and
`pdv_compile.mjs`'s drift guard normalizes line endings before comparing — so a
fresh worktree's LF checkout no longer false-drifts against a CRLF live tree. If
you ever see a drift error on byte-identical source, that pin/guard pair is the
fix; do **not** rewrite the live-tree file to match (it breaks whichever branch's
checkout currently matches it).
