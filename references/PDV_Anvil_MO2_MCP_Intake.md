# PDV Anvil MO2 MCP Intake

**Date:** 2026-05-14, updated 2026-05-29
**Scope:** Anvil MO2 MCP server setup, operating rules, and skill precedence for Codex-driven PDV work.

## Current Integration State

- Codex is configured for Anvil's dedicated MO2 MCP server in `C:\Users\Admin\.codex\config.toml`:
  - `[mcp_servers.mo2]`
  - `url = "http://127.0.0.1:27016/mcp"`
- The MCP server was confirmed live on `http://127.0.0.1:27016/mcp` after the port split; `mo2_ping` reported base path `D:/Wabbajack/modlists/Anvil` and profile `Devotion Dev`.
- Start the server from Anvil/MO2, not by launching Python or CK directly:
  - Open `D:\Wabbajack\modlists\Anvil\Anvil.exe`
  - Use MO2 Tools menu entry `Start/Stop MCP Server`
  - Restart Codex if `mo2_*` tools are not visible after first server start
- The plugin folder is named `Anvilmo2_mcp`, not the upstream default `mo2_mcp`.
- The plugin now checks Codex config on server start in addition to its legacy Claude config.
- An abandoned `D:\Wabbajack\modlists\Anvil\plugins\mo2_mcp` cache-only folder was removed on 2026-05-16 to avoid confusing it with the live plugin.

## Tool Surface

The authoritative tool list and descriptions live in the MCP registry — call
`mo2_ping` to confirm the server is live, then `tools/list` (or let Codex
auto-discover on session start). The table that was here has been removed to
prevent it drifting from the live registry (per the HOUSECARL authoring
standard: the registry is the single source of truth for what tools exist and
how to call them). Run `node tools/pdv_mcp_check.mjs` for a quick health check
that validates the server is live and the active profile is `Devotion Dev`.

## Optional Tool Status

| Tool | Status | Notes |
|---|---|---|
| `mutagen-bridge.exe` | Installed | Present at `D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp\tools\mutagen-bridge\mutagen-bridge.exe`; required for record detail and patching. |
| `spookys-automod.exe` | Installed | Present at `D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp\tools\spooky-cli\spookys-automod.exe`; help output works. |
| `PapyrusCompiler.exe` | Installed and configured | Present at `D:\Wabbajack\modlists\Anvil\Stock Game\Papyrus Compiler\PapyrusCompiler.exe`; `tool_paths.json` now points to it. |
| `PapyrusAssembler.exe` | Installed | Present beside the compiler. |
| `TESV_Papyrus_Flags.flg` | Installed | Present at `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts\TESV_Papyrus_Flags.flg`; plugin flag lookup now checks this Anvil CK path. |
| Base Skyrim script sources | Installed and configured | Present at `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts`; `tool_paths.json` now points to it. |
| `BSArch.exe` | Installed | Installed from xEdit `xedit-4.1.5f` release archive as `D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp\tools\spooky-cli\tools\bsarch\bsarch.exe`; Spooky `archive status --json` returns success. SHA256: `5A8F1FD36ADB183FCF3EEC04E092F61F2AFA5E9A869AB181F81BD65A55E5B267`. |
| `nif-tool.exe` | Missing | Not found under the Anvil tree. `mo2_nif_info` should work through Spooky CLI, but texture listing and shader inspection need `nif-tool.exe`. |

## Codex Skill Intake

The plugin's Codex-ready skill sources live under:

`D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp\.agents\skills`

They were normalized from Claude wording to Codex wording and installed into:

`C:\Users\Admin\.codex\skills`

Installed MCP skills:

- `audio-voice`
- `bsa-archives`
- `crash-diagnostics`
- `esp-patching`
- `leveled-list-patching`
- `mod-dissection`
- `nif-meshes`
- `npc-analysis`
- `npc-outfit-investigation`
- `papyrus-compilation`
- `session-strategy`

These will be available to future Codex sessions once skill discovery refreshes.

## PDV Operating Rules

**Skill precedence.** In PDV sessions, the `pdv-papyrus-ck` and `pdv-doc-sync`
project skills supersede the generic MO2 plugin skills. Specifically:
- `pdv-papyrus-ck` supersedes the MO2 `papyrus-compilation` skill.
- These PDV rules supersede the MO2 `session-strategy` skill guidance.
Follow the rules below rather than generic MO2 session advice.

**Papyrus compilation.**
- **Never use `mo2_compile_script` for PDV `.psc` files.** The MCP compiler
  path does not use PDV's verified import chain and does not run the verifier
  afterward. Always use `node tools/pdv_compile.mjs` instead.
- `mo2_compile_script` is reserved for one-off MCP-managed flows where source
  text is provided directly to the tool and the PDV script set is not involved.
- `pdv_compile.mjs` will detect sandbox write-access restrictions and emit a
  clear error (`rerun outside the Codex sandbox`) before attempting to spawn
  the compiler.

**ESP inspection and patching.**
- Use `mo2_record_detail`, `mo2_query_records`, and `mo2_conflict_chain` for
  ESP record inspection once the MCP server is live.
- Use `mo2_create_patch` for override patch plugins; do not hand-edit ESP
  binaries. Use `tools/pdv_author.mjs` for PDV-specific manifest-driven
  overlay patches against existing records.

**Server hygiene.**
- The MCP output mod default is `Devotion`, matching PDV's active output target.
- After editing plugin Python files, delete `__pycache__` and **fully restart
  MO2**. Stopping/starting the server inside MO2 is not enough — MO2 keeps
  Python modules loaded.
- The Anvil MCP VFS can cache file listings. If newly copied SKSE files or
  scripts do not appear through `mo2_*` tools, restart or refresh the MCP
  server. Run `node tools/pdv_mcp_check.mjs` to confirm the server is live
  and on the `Devotion Dev` profile before starting a work session.

## Remaining Setup Gap

The only confirmed missing optional binary is `nif-tool.exe`. It is not required for Phase 3 CK quest wiring, Papyrus compile verification, ESP record inspection, or BSA/BA2 archive work, but it is needed for advanced NIF texture/shader inspection.
