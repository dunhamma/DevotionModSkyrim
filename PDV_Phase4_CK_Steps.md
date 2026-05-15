# PDV Phase 4 CK Steps

Status: Manual CK/ESP walkthrough for the Phase 4 Kyne proof slice  
Last revised: 2026-05-14

## Purpose

This walkthrough finishes the ESP-side work for the Phase 4 framework already
landed in script and tooling:

- `PDV__MainQuest.psc` now bootstraps origin detection on `OnInit()`
- `PDV_Origin.psc` now detects the player race and seeds the Kyne proof slice
- `PDV__ManagerQuest.psc` now applies stance-aware scratch writes, supports
  rivalry plumbing, and treats boons as active-patron-only
- `PDV_DeityBase.psc` now uses race-keyed stance properties and cumulative
  patron-only boon sync
- `tools/pdv_verify.mjs` now fails or warns on missing Phase 4 records and
  Kyne proof-slice wiring

At the time of writing, the scripts compile cleanly, but the verifier still
fails because the live ESP does not yet contain:

- `PDV_GLO_OriginRace`
- `PDV_GLO_PatronDeity`
- `PDV__MainQuest` quest record
- `PDV_Origin` quest record
- Kyne stance properties and boon assignments on the actual quest record

Use this doc to close that gap.

## Preconditions

Before opening CK:

1. Run `node .\tools\pdv_compile.mjs --all`.
2. Confirm the following files exist in `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\`:
   - `PDV__MainQuest.pex`
   - `PDV_Origin.pex`
   - `PDV__ManagerQuest.pex`
   - `PDV_DeityBase.pex`
   - `PDV_Deity_Kyne.pex`
3. Launch CK through MO2/Anvil, not directly:
   - Open `D:\Wabbajack\modlists\Anvil\Anvil.exe`
   - Select `Creation Kit`
   - Press `Run`

## 1. Create the missing globals

Create these globals in `PlayerDevotion_Framework.esp`:

### `PDV_GLO_OriginRace`

- Type: `Short` or float-compatible numeric global, consistent with existing PDV globals
- Default value: `-1`
- Purpose: sentinel for "origin not initialized yet", then one-time race index `0-9`

### `PDV_GLO_PatronDeity`

- Type: numeric global consistent with existing PDV globals
- Default value: `0`
- Purpose: cached active patron identifier written by manager script

Do not rename the EditorIDs. The verifier expects these exact names.

## 2. Create or restore `PDV__MainQuest`

The verifier currently shows that `PDV__MainQuest` is missing from the ESP even
though the script now exists and compiles. Create or restore the quest record.

Required shape:

- EditorID: `PDV__MainQuest`
- Start Game Enabled: `Yes`
- Run Once: `Yes`
- Priority: keep modest; this is bootstrap only
- Attach script: `PDV__MainQuest`

Script properties:

- `PDV_OriginQuest` -> `PDV_Origin`
- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`

Notes:

- Do not move runtime logic into a fragment. The current implementation uses
  script `OnInit()` as the bootstrap hook.
- No stage fragment is required for this slice.

## 3. Create `PDV_Origin`

Create a new utility quest:

- EditorID: `PDV_Origin`
- Start Game Enabled: `No`
- Persistent runtime service: `No`
- Attach script: `PDV_Origin`

This quest is not meant to run as a long-lived service. It exists so
`PDV__MainQuest` can call `InitializeOrigin()` once during bootstrap.

## 4. Wire `PDV_Origin` properties

Assign every required property on the `PDV_Origin` script:

- `PDV_GLO_OriginRace` -> `PDV_GLO_OriginRace`
- `PDV_Manager` -> `PDV__ManagerQuest`
- `PDV_Kyne` -> `PDV_Deity_Kyne`
- `PlayerRef` -> player reference if you prefer explicit wiring; otherwise the script falls back to `Game.GetPlayer()`
- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`

Race properties:

- `NordRace` -> Nord race
- `ImperialRace` -> Imperial race
- `BretonRace` -> Breton race
- `HighElfRace` -> Altmer race
- `WoodElfRace` -> Bosmer race
- `DarkElfRace` -> Dunmer race
- `KhajiitRace` -> Khajiit race
- `ArgonianRace` -> Argonian race
- `OrcRace` -> Orc race
- `RedguardRace` -> Redguard race

Keep the global default at `-1` so the script can bail out after the first
successful initialization.

## 5. Update `PDV__ManagerQuest`

Open the existing `PDV__ManagerQuest` quest and re-save its script properties.

New required property:

- `PDV_GLO_PatronDeity` -> `PDV_GLO_PatronDeity`

Existing required properties that must remain valid:

- `PDV_GLO_ActivePiety`
- `PDV_GLO_ActiveTier`
- `PDV_GLO_ActiveDeityIndex`
- `PDV_GLO_DebugLevel`
- `PDV_FLST_AllDeities`

Do not remove the existing manager wiring.

## 6. Update `PDV_Deity_Kyne`

Open `PDV_Deity_Kyne` and update its Phase 4 properties.

### Required global properties

- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`
- `PDV_GLO_OriginRace` -> `PDV_GLO_OriginRace`

### Stance row

Set Kyne's race stances exactly like this:

- `Stance_Nord = 0`
- `Stance_Imperial = 1`
- `Stance_Breton = 1`
- `Stance_Altmer = 1`
- `Stance_Bosmer = 1`
- `Stance_Dunmer = 1`
- `Stance_Khajiit = 1`
- `Stance_Argonian = 1`
- `Stance_Orc = 1`
- `Stance_Redguard = 1`

Interpretation:

- `0 = NATIVE`
- `1 = FOREIGN`
- `2 = TABOO`
- `3 = HOSTILE`

Kyne proof-slice rule:

- Nord only is `NATIVE`
- everyone else is `FOREIGN`
- no `TABOO`
- no `HOSTILE`

### Rivalry

For the proof slice, leave Kyne rivalry empty:

- `RivalDeities` -> empty
- `RivalMultipliers` -> empty

### Boon properties

Assign all three:

- `Boon_Seeker`
- `Boon_Devoted`
- `Boon_Champion`

The verifier now warns when these are left unassigned.

## 7. Author Kyne boon records

Create three passive Kyne boon spells and their supporting magic effects.

Naming:

- `PDV_Blessing_Kyne_Seeker`
- `PDV_Blessing_Kyne_Devoted`
- `PDV_Blessing_Kyne_Champion`

Recommended proof-slice behavior:

- Seeker: small, always-on baseline favor
- Devoted: the main persistent blessing tier
- Champion: meaningful but still modest capstone

Design constraints from the locked architecture:

- passive only
- cumulative across tiers
- active only while Kyne is the current patron
- no hotbar powers
- no effect that outcompetes perk overhauls or major combat mods

## 8. Save, compile, and verify

After CK wiring:

1. Save the ESP.
2. Re-run `node .\tools\pdv_compile.mjs --all`.
3. Re-run `node .\tools\pdv_verify.mjs`.

Expected verifier improvement:

- missing Phase 4 baseline records should disappear
- manager property failure for `PDV_GLO_PatronDeity` should disappear
- `PDV__MainQuest` and `PDV_Origin` should be detected and checked
- Kyne stance warnings should turn into passes
- Kyne boon warnings should turn into passes once the spells are assigned

## 9. In-game proof tests

Use a new game or a main-menu `coc qasmoke` path.

Minimum checks:

1. Nord character start:
   - `PDV_GLO_OriginRace` becomes `0`
   - Kyne starts with higher piety than a non-Nord comparison run
2. Non-Nord character start:
   - origin maps to the expected race index
   - Kyne start piety uses the non-Nord seed
3. Patron test:
   - set Kyne active
   - confirm her current tier grants cumulative live boon spells
4. Patron swap test:
   - switch away from Kyne
   - confirm Kyne boons are removed while stored piety/tier remain
5. Existing Phase 3 regression:
   - hostile bandit still grants Kyne scratch
   - hostile wolf still penalizes Kyne scratch
   - dawn still consolidates and recomputes tier

## 10. Current known boundary

The rivalry framework is implemented in script, but Kyne deliberately has no
hostile stance rows or rival entries in this slice. Rivalry should therefore
remain dormant until a later deity, likely Talos, is wired with real hostile
cross-pantheon data.
