# FormID Conventions

Use this file when translating between UESP/CK references, console IDs, local plugin records, and PDV table rows.

## Practical Rules

1. Record `source_plugin` alongside every FormID.
2. Prefer `EditorID` for human-facing tables; use FormID as implementation detail.
3. Do not treat the first two hexadecimal digits of a runtime FormID as stable across load orders.
4. For light plugins, be careful with `FE`-prefixed runtime IDs. Store the local form identity and plugin name instead of only the displayed runtime ID.
5. When a table row is not yet extracted from local data, set validation to `needs-local-extraction`.

## PDV Rule

For implementation work, exact FormIDs should be verified from local master/plugin data or xEdit/Mutagen output before being wired into scripts or manifests. UESP is excellent for discovery, but local data wins when records have been patched or replaced.

Source: `uesp_skyrim_form_id` should be added to `sources.yaml` if this file is expanded with direct FormID examples.
