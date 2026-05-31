# Creation Merge Runner

Local Mutagen-backed promotion helper for `packages/creation-authoring`.

The runner consumes `creation-authoring.structured-merge-request.v1`, loads the
reviewed generated plugin and source plugin, copies approved top-level generated
records into a source-plugin output file, and emits JSON.

It is deliberately narrow:

- Requires `--approved`.
- Writes to `--output-path`; callers should point this at a reviewed temp/candidate path first.
- Creates a timestamped backup when `--backup-root` is supplied.
- Supports safe top-level record copies for the first authoring surface.
- Leaves CK finalization and post-merge live verification to the outer promotion pipeline.

Example:

```powershell
dotnet run --project .\native\CreationMergeRunner\CreationMergeRunner.csproj -- `
  --request .\scratch\structured-merge-request.json `
  --source-path D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp `
  --generated-path D:\Wabbajack\modlists\Anvil\mods\Devotion\PDV_AutoWireReference.esp `
  --output-path .\scratch\PlayerDevotion_Framework.merge-candidate.esp `
  --backup-root .\scratch\merge-backups `
  --approved
```

Current supported record-family gate:

- `ACTI`
- `GLOB`
- `KYWD`
- `FLST`
- `MGEF`
- `NPC_`
- `PACK`
- `PERK`
- `QUST`
- `vmad`
- `formlist`

CK-semantic operations can be copied as binary records only when the outer
promotion report still requires CK finalization afterward.
