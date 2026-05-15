# PDV Phase 5 CK Steps

Status: Manual CK/ESP walkthrough for the first MCM slice  
Last revised: 2026-05-14

## Purpose

This walkthrough closes the CK/ESP side of the first MCM slice after the Phase
5 scripts and helper surfaces exist on disk and compile cleanly.

Phase 5 stays intentionally narrow:

- one SkyUI config quest
- no MCM Helper
- no first-run quest UI
- no race-module-specific pages
- no Daedric side panels yet

The first MCM slice should expose four pages already locked in the
architecture:

- `Status` - read-only per-deity piety, tier, and current patron
- `Patron` - choose or change the active patron, with confirmation
- `Tuning` - global gain multiplier, decay rate, dawn-tick toggle
- `Debug` - print piety map, force tier transition, reset deity, set debug level

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

### Required Phase 5 config globals, if the script uses them

- `PDV_GLO__Config_GainMult`
- `PDV_GLO__Config_DecayRate`
- `PDV_GLO__Config_DawnTickEnabled`

Naming rule:

- keep the reserved prefix `PDV_GLO__Config_[Setting]`

If the final script chooses to keep any tuning value script-only rather than
global-backed, remove that property from the CK checklist and document the
change explicitly before testing.

## 3. Create the Phase 5 config globals

If these globals do not already exist, create them in
`PlayerDevotion_Framework.esp`.

### `PDV_GLO__Config_GainMult`

- numeric global
- default value: `1.0`
- meaning: player-facing overall gain multiplier

### `PDV_GLO__Config_DecayRate`

- numeric global
- default value: `1.0`
- meaning: player-facing decay-rate scalar

### `PDV_GLO__Config_DawnTickEnabled`

- numeric global
- default value: `1.0`
- meaning: `1.0 = enabled`, `0.0 = disabled`

These are player-facing tuning controls, not hidden debug scratch variables.
`PDV__ManagerQuest` remains authoritative for how they are applied at runtime.

## 4. Manager-side dependency checklist

Before declaring CK wiring complete, confirm the MCM has real callable support
for every interactive surface it exposes.

The manager-side Phase 5 API should support:

- reading piety per deity for the `Status` page
- reading tier per deity for the `Status` page
- reading the active patron
- setting or changing the active patron
- clean patron-swap confirmation flow
- resetting a deity by index or by quest form
- forcing tier or piety debug transitions
- setting debug verbosity
- reading and writing the Phase 5 tuning values, if those settings are
  manager-backed

Do not rely on placeholder menu actions. Every button, slider, menu, or toggle
in the MCM should have a real script target before in-game testing starts.

## 5. Expected page behavior

Use this as the CK-side intent check while reviewing the script and its
properties.

### `Status`

- read-only
- iterates `PDV_FLST_AllDeities`
- shows current deity state without mutating it

### `Patron`

- allows patron selection or change
- confirms the action before committing it
- relies on the existing patron-only boon contract

### `Tuning`

- exposes only:
  - gain multiplier
  - decay rate
  - dawn-tick enabled/disabled
- should not introduce broader rebalance controls in this first slice

### `Debug`

- print piety map
- force tier or piety transitions
- reset one deity at a time
- set `PDV_GLO_DebugLevel`

Keep all player-facing MCM text ASCII-only.

## 6. Save, compile, and verify

After CK wiring:

1. Save the ESP.
2. Run `node .\tools\pdv_compile.mjs --all`.
3. Run `node .\tools\pdv_verify.mjs`.

Expected verification outcomes once Phase 5 script/tooling support exists:

- `PDV_MCM` is present and script-attached
- all required MCM properties are assigned
- Phase 5 config globals exist and point correctly
- no accidental SkyUI script output has landed in the Devotion mod folder

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
4. Change patron through the `Patron` page and confirm:
   - confirmation prompt appears
   - active patron persists after closing MCM
   - boon handoff still respects the patron-only rule
5. Change each `Tuning` value and confirm:
   - the value persists after closing and reopening MCM
   - the manager uses the new setting on the next applicable event or dawn pass
6. Use the `Debug` page and confirm:
   - debug level changes propagate
   - force/reset actions hit the intended deity only
   - no stale UI state or cross-deity bleed occurs
7. Save, reload, and confirm patron and tuning state persist.

## 8. Exit criteria

Phase 5 CK wiring is not complete until all of the following are true:

- `PDV_MCM` exists and registers in SkyUI
- the four intended pages work without placeholder actions
- patron changes persist across save/load
- tuning values persist and affect runtime behavior
- debug actions are scoped correctly
- deity listings continue to flow from `PDV_FLST_AllDeities` rather than a
  hardcoded menu list
