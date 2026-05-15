# PDV Phase 5 CK Steps

Status: Manual CK/ESP walkthrough for the first MCM slice; framework wiring completed 2026-05-16  
Last revised: 2026-05-16

## Purpose

This walkthrough closes the CK/ESP side of the first MCM slice after the Phase
5 scripts and helper surfaces exist on disk and compile cleanly.

Current project state: `PDV_MCM` now exists in `PlayerDevotion_Framework.esp`,
has the `PDV_MCM` script attached, and has the required properties assigned
directly in the framework ESP after the overlay merge-back. Keep this page as
the rebuild/smoke-test checklist rather than evidence that an overlay remains
part of the steady-state workflow.

Phase 5 stays intentionally narrow:

- one SkyUI config quest
- no MCM Helper
- no first-run quest UI
- no race-module-specific pages
- no Daedric side panels yet
- no player-facing patron-selection flow
- no tuning/config globals in this slice

The first MCM slice should expose two pages only:

- `Status` - read-only per-deity piety, tier, and active patron state
- `Debug` - development-only override and inspection actions

## Preconditions

Before opening CK:

1. Run `node .\tools\pdv_compile.mjs --all`.
2. Confirm the Phase 5 outputs exist in `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\`.
   Minimum expected files:
   - `PDV_MCM.pex`
   - any updated `PDV__ManagerQuest.pex`
   - any `.pex` files for helper scripts Phase 5 added
3. Launch CK through MO2/Anvil, not directly:
   - Open `D:\Wabbajack\modlists\Anvil\Anvil.exe`
   - Select `Creation Kit`
   - Press `Run`
4. Confirm SkyUI is active in the `Devotion Dev` profile before in-game testing.

Do not start CK wiring until the Phase 5 script surface compiles. If CK cannot
see a new script, compile once first.

## 1. Create `PDV_MCM`

Create a new SkyUI config quest in `PlayerDevotion_Framework.esp`:

- EditorID: `PDV_MCM`
- Start Game Enabled: `Yes`
- keep it lightweight and persistent; this is UI/config, not gameplay routing
- attach script: `PDV_MCM`

Script contract:

- `PDV_MCM.psc` should derive from `SKI_ConfigBase`

Common failure modes:

- If CK only offers `Add New Script` and cannot see `PDV_MCM`, stop and compile
  `PDV_MCM.psc` first so the `.pex` exists.
- If `SKI_ConfigBase.pex` appears in `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\`,
  stop and fix the compile target list. Do not ship copied SkyUI output into the
  Devotion mod folder.
- If `PDV_MCMWirePatch.esp` is active, stop and untick it. That overlay was a
  temporary rescue artifact and has been merged back into the framework ESP.

## 2. Wire `PDV_MCM` properties

Open the `PDV_MCM` quest and assign its script properties.

### Required existing properties

- `PDV_Manager` -> `PDV__ManagerQuest`
- `PDV_FLST_AllDeities` -> `PDV_FLST_AllDeities`
- `PDV_GLO_ActivePiety` -> `PDV_GLO_ActivePiety`
- `PDV_GLO_ActiveTier` -> `PDV_GLO_ActiveTier`
- `PDV_GLO_ActiveDeityIndex` -> `PDV_GLO_ActiveDeityIndex`
- `PDV_GLO_PatronDeity` -> `PDV_GLO_PatronDeity`
- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`

## 3. Manager-side dependency checklist

Before declaring CK wiring complete, confirm the MCM has real callable support
for every interactive surface it exposes.

The manager-side Phase 5 API should support:

- reading piety per deity for the `Status` page
- reading tier per deity for the `Status` page
- reading the active patron
- cycling the live deity roster without hardcoded menu data
- applying a debug patron override
- clearing the debug patron override
- resetting a deity by index or by quest form
- forcing targeted piety and scratch-piety debug transitions
- setting debug verbosity

Do not rely on placeholder menu actions. Every button, slider, menu, or toggle
in the MCM should have a real script target before in-game testing starts.

## 5. Expected page behavior

Use this as the CK-side intent check while reviewing the script and its
properties.

### `Status`

- read-only
- iterates `PDV_FLST_AllDeities`
- shows current deity state without mutating it

### `Debug`

- debug patron override only -- not player-facing religious commitment
- print piety map
- force targeted piety or scratch transitions
- reset one deity at a time
- set `PDV_GLO_DebugLevel`

Keep all player-facing MCM text ASCII-only.

## 6. Save, compile, and verify

After CK wiring:

1. Save the ESP.
2. Regenerate `PlayerDevotion_Framework.seq` because `PDV_MCM` is a new
   Start Game Enabled quest.
3. Run `node .\tools\pdv_compile.mjs --all`.
4. Run `node .\tools\pdv_verify.mjs`.

Expected verification outcomes once Phase 5 script/tooling support exists:

- `PDV_MCM` is present and script-attached
- all required MCM properties are assigned
- no accidental SkyUI script output has landed in the Devotion mod folder
- `PDV_MCM.pex` exists and is fresh
- retired overlays (`PDV_ManagerPatronWirePatch.esp`, `PDV_MCMWirePatch.esp`)
  are present only as inactive historical files, not active profile plugins

If verifier coverage for `PDV_MCM` does not exist yet, add it before treating
the Phase 5 CK pass as complete.

## 7. In-game validation

Use a clean start path where possible.

Minimum checks:

1. Open Mod Configuration and confirm `PlayerDevotion` appears.
2. Confirm the `Status` page lists every deity currently present in
   `PDV_FLST_AllDeities`.
3. Confirm read-only status values match runtime state for at least:
   - active piety
   - active tier
   - active deity index
4. Use the `Debug` page and confirm:
   - patron override is clearly presented as a debug action, not normal devotion flow
   - confirmation prompt appears before patron override or clear
   - active patron persists after closing MCM where the underlying manager state persists
   - boon handoff still respects the patron-only rule
   - debug level changes propagate
   - force/reset actions hit the intended deity only
   - no stale UI state or cross-deity bleed occurs
5. Save, reload, and confirm patron/debug state persists where the underlying
   runtime state already persists.

## 8. Exit criteria

Phase 5 CK wiring is not complete until all of the following are true:

- `PDV_MCM` exists and registers in SkyUI
- the two intended pages work without placeholder actions
- debug patron override behaves correctly for the live roster
- debug actions are scoped correctly
- deity listings continue to flow from `PDV_FLST_AllDeities` rather than a
  hardcoded menu list
