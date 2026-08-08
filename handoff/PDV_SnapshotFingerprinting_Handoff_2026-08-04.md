# Snapshot record-fingerprinting -- CLOSED, premise disproven (2026-08-05)

**Status: CLOSED. Do not build this.** The 2026-08-04 version of this document specified a record
fingerprinting system for `tools/pdv_snapshot_live.mjs`. Its entire justification was a houseCARL
limitation that **does not exist**. The parked code has been reverted and replaced by
`tools/pdv_esp_diff_sweep.mjs`, which does the same job with no capture step.

## The claim, and what was actually true

The handoff claimed `housecarl_diff_record` cannot detect ADDED list elements -- that a quest whose
VMAD went from 4 script properties to 14 returns `complete: true, delta_count: 0`, making "most PDV
record work" invisible. That was recorded in memory as
`snapshot-diffing-misses-added-list-elements` (since corrected).

Reproduced against the current build on 2026-08-05, it is false in both claimed cases:

- **FormList addition, UNSCOPED, caught and named:**
  `Items: 32 vs Devotion.esp 33 item(s) -- only in Devotion.esp: [32] 07164C:Devotion.esp`
- **VMAD addition** (`07164C` PDV_Deity_Syrabane, 4 -> 14): unscoped reports the container
  asymmetry; adding `fields=["VirtualMachineAdapter.Scripts[0].Properties"]` enumerates **all 10
  added properties by name and value** -- `delta_count: 41, complete: true, truncated: false`.

That second result *is* the acceptance test the old handoff said the tool was not done until it
passed ("it must report 10 ADDED leaves"), passing with no fingerprint involved.

## Root cause: a stale pinned binary, not a houseCARL gap

`tools/lib/pdv_housecarl_stdio.mjs` pinned `DEFAULT_EXE` to
`AppData/Local/houseCARL/server/housecarl-mcp.exe` (**Jul 11** build), while the MCP tools use
`.claude/skills/housecarl/server/` (**Jul 17** build). A/B on the identical call:

| build | result |
|---|---|
| Jul 11 (what the tool called) | `Unknown tool: 'housecarl_diff_record'` |
| Jul 17 (what MCP calls) | 41 deltas, all 10 additions enumerated |

The old handoff's "already tried" item 1 -- `format:"json"` works over MCP but not through the stdio
driver, "likely a different build" -- was the same root cause, correctly observed and then filed as
a quirk to work around instead of a defect to fix. JSON works fine through the corrected driver.

**Standing lesson:** confirm which binary you are talking to before recording any houseCARL
limitation. `CLAUDE.md` already requires reproducing a suspected limitation on the current version;
this is what that rule is for.

## What shipped instead

`tools/pdv_esp_diff_sweep.mjs` -- diffs the snapshot ESPs directly.

```
node tools/pdv_esp_diff_sweep.mjs --from P1-pre-esp-only-20260802 --scope both
```

- **Two-tier by design:** an unscoped diff detects and localizes; a `fields=`-scoped re-diff
  enumerates leaves, only for records that actually moved.
- `--scope vmad|flst|both|all` -- `both` is the ~280 records PDV work lands on (183 VMAD carriers +
  97 FormLists).
- **280 records in ~18 seconds.** The old per-call process spawn (~5.7s each) would have made this
  ~17 minutes; `openHousecarl()` in the stdio driver now reuses one server process.
- **Works retroactively on all ~100 snapshots back to 2026-06-20**, including every snapshot taken
  before any of this was written. Fingerprinting structurally could not do this -- it had to be
  captured at write time and could never be back-filled.
- Verdict is the **exit code**: `0` swept / `1` differences under `--expect-clean` / `2` tool error.

Validated against `P1-pre-esp-only-20260802 -> live`: 4 added records, 2 changed, with full deep
enumeration of the 10 `Stance_*` additions. It also caught an unrelated real change nobody was
looking for -- `PDV_Substrate_AltmerAncestor` gained `HighThreshold = 60`.

## Reverted

`tools/pdv_snapshot_live.mjs` is back to its committed 298 lines (`--records` / `--diff` /
`records.json` all gone). It is once more the pure rollback tool it is committed as.

Note for anyone reverting a `tools/*.mjs`: those paths are **not** LF-pinned in `.gitattributes` and
`core.autocrlf=true`, so `git checkout` rewrites them to CRLF. Restore with `git show HEAD:<path>`.

The one existing fingerprint, `P9-fp-20260803-214454/records.json`, is now dead weight -- the ESP
beside it is the real artifact. Delete it whenever convenient.

## Real hazards that remain (these ones reproduce)

1. **A `fields=` path matching nothing returns `complete: true, delta_count: 0` with NO error.**
   `agreed_count: 0` is the only tell, and it is ambiguous -- an all-identical list scores 0 too.
   Validate the path with `read_record` first, or include a known scalar. This is plausibly how the
   original false finding was produced. The sweep tool warns on it explicitly.
2. **`depth` counts from the RECORD ROOT, not from a `fields=` path.**
   `fields=["VirtualMachineAdapter"] depth=2` still renders `Scripts` as a summary. Index
   explicitly (`VirtualMachineAdapter.Scripts[0].Properties`). The old handoff was right about this.
3. **Deleted records are invisible to the sweep.** Records are enumerated from the LIVE load order
   because `cross_plugin_query` cannot scope to an off-order file, so a record present in `--from`
   and deleted since is never enumerated. Added and changed records report normally.
4. **Confirm the houseCARL instance.** `Devotion.esp` exists in both Anvil and ARR 2.5; a
   wrong-instance run silently reads the wrong plugin. Anvil, profile `Devotion Dev`, ~357 plugins.

## Worth asking upstream

Not fingerprinting -- it duplicates `diff_record` with a staleness problem attached. The genuinely
missing primitive is **`housecarl_diff_plugin`**: a whole-plugin, record-level diff (added / removed
/ changed records) between two plugin files. It is a natural extension of `diff_record`, which
already accepts off-order paths, and it would close gap 3 above -- the only part still hand-rolled.

Related memories: `snapshot-diffing-misses-added-list-elements` (corrected),
`housecarl-update-procedure`, `inplace-write-silently-reverted-earlier-edit`,
`dev-esp-not-git-tracked-ships-in-zip`, `gate-verdict-is-exit-code-not-grepped-field`.
