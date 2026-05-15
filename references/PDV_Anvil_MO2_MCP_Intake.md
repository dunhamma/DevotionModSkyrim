# PDV Anvil MO2 MCP Intake

**Date:** 2026-05-14, updated 2026-05-16
**Scope:** Local intake of `D:\Wabbajack\modlists\Anvil\plugins\Anvilmo2_mcp` for Codex-driven PDV work.

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

The plugin registers these MCP tools when the server is live:

| Area | Tools |
|---|---|
| Connection | `mo2_ping` |
| Modlist | `mo2_list_mods`, `mo2_mod_info`, `mo2_list_plugins`, `mo2_plugin_info`, `mo2_find_conflicts` |
| Filesystem | `mo2_resolve_path`, `mo2_list_files`, `mo2_read_file`, `mo2_analyze_dll` |
| Write | `mo2_write_file` |
| Records | `mo2_record_index_status`, `mo2_build_record_index`, `mo2_query_records`, `mo2_record_detail`, `mo2_conflict_chain`, `mo2_plugin_conflicts`, `mo2_conflict_summary` |
| ESP patching | `mo2_create_patch` |
| Papyrus | `mo2_compile_script` |
| Archives | `mo2_list_bsa`, `mo2_extract_bsa`, `mo2_extract_bsa_file`, `mo2_validate_bsa` |
| NIF | `mo2_nif_info`, `mo2_nif_list_textures`, `mo2_nif_shader_info` |
| Audio | `mo2_audio_info`, `mo2_extract_fuz` |

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

- Prefer PDV's local `tools\pdv_compile.mjs` for PDV source compilation. It already calls `PapyrusCompiler.exe` directly with the project-verified import chain and verifier loop.
- Use `mo2_compile_script` only for MCP-managed ad hoc compile flows where the source text is provided to the tool.
- Use `mo2_record_detail`, `mo2_query_records`, and `mo2_conflict_chain` for ESP inspection once the MCP server is live.
- Use `mo2_create_patch` for override patch plugins; do not hand-edit ESP binaries.
- The MCP output mod default is now `Devotion`, matching PDV's active project output target.
- After editing plugin Python files, delete `__pycache__` and fully restart MO2. Stopping/starting the server inside MO2 is not enough because MO2 keeps Python modules loaded.

## Remaining Setup Gap

The only confirmed missing optional binary is `nif-tool.exe`. It is not required for Phase 3 CK quest wiring, Papyrus compile verification, ESP record inspection, or BSA/BA2 archive work, but it is needed for advanced NIF texture/shader inspection.
