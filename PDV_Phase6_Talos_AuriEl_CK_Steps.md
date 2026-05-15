# PDV Phase 6 Talos + Auri-El CK Steps

Status: Manual CK/ESP walkthrough for the coupled Talos + Auri-El slice  
Last revised: 2026-05-14

## Purpose

This walkthrough closes the CK/ESP side of the coupled hostile-path proof now
landed in script and tooling:

- `PDV_Deity_Talos.psc` is the first hostile-path proof deity
- `PDV_Deity_AuriEl.psc` is the minimum viable Altmer foundation/rival deity
- `PDV_Origin.psc` now seeds a small generic table for Kyne, Talos, and Auri-El
- `PDV__ManagerQuest.psc` now exposes `AwardCuratedSignal()` plus
  `AwardCuratedSignalByIndex()` and applies rivalry from the written
  stance-adjusted delta
- `tools/pdv_verify.mjs` now checks for Talos/Auri-El records, FormList
  membership, stance rows, boon assignments, and Talos rivalry wiring

The scripts compile cleanly, but the live ESP still needs the actual records,
properties, and spell assignments.

## 1. Create deity quest records

Create two new persistent deity quests in `PlayerDevotion_Framework.esp`:

### `PDV_Deity_Talos`

- EditorID: `PDV_Deity_Talos`
- Attach script: `PDV_Deity_Talos`
- Deity identity:
  - `DeityName = Talos`
  - `DeityIndex = 1`

### `PDV_Deity_AuriEl`

- EditorID: `PDV_Deity_AuriEl`
- Attach script: `PDV_Deity_AuriEl`
- Deity identity:
  - `DeityName = Auri-El`
  - `DeityIndex = 2`

Add both quests to `PDV_FLST_AllDeities`.

## 2. Update `PDV_Origin`

The script now expects these deity properties in addition to Kyne:

- `PDV_Talos` -> `PDV_Deity_Talos`
- `PDV_AuriEl` -> `PDV_Deity_AuriEl`

Keep existing properties valid:

- `PDV_Kyne`
- `PDV_Manager`
- `PDV_GLO_OriginRace`
- race-form properties
- `PDV_GLO_DebugLevel`

## 3. Wire Talos

### Required globals

- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`
- `PDV_GLO_OriginRace` -> `PDV_GLO_OriginRace`

### Talos stance row

Set:

- `Stance_Nord = 0`
- `Stance_Imperial = 1`
- `Stance_Breton = 0`
- `Stance_Altmer = 3`
- `Stance_Bosmer = 1`
- `Stance_Dunmer = 1`
- `Stance_Khajiit = 1`
- `Stance_Argonian = 1`
- `Stance_Orc = 1`
- `Stance_Redguard = 1`

### Talos rivalry

First pass is one-way only:

- `RivalDeities` -> contains only `PDV_Deity_AuriEl`
- `RivalMultipliers` -> one matching multiplier entry

Recommended first multiplier:

- `1.0`

### Talos boons

Assign:

- `Boon_Seeker`
- `Boon_Devoted`
- `Boon_Champion`

Keep them modest. The first Talos slice proves pipeline + hostility, not final
Talos balance.

## 4. Wire Auri-El

### Required globals

- `PDV_GLO_DebugLevel` -> `PDV_GLO_DebugLevel`
- `PDV_GLO_OriginRace` -> `PDV_GLO_OriginRace`

### Auri-El stance row

Set:

- `Stance_Nord = 1`
- `Stance_Imperial = 1`
- `Stance_Breton = 1`
- `Stance_Altmer = 0`
- `Stance_Bosmer = 0`
- `Stance_Dunmer = 1`
- `Stance_Khajiit = 1`
- `Stance_Argonian = 1`
- `Stance_Orc = 3`
- `Stance_Redguard = 1`

### Auri-El rivalry

Leave first-pass rivalry empty:

- `RivalDeities` -> empty
- `RivalMultipliers` -> empty

### Auri-El boons

Assign:

- `Boon_Seeker`
- `Boon_Devoted`
- `Boon_Champion`

“Always active” for Altmer in this slice means seeded standing plus curated
signals, not a bypass of patron-only boon rules.

## 5. Curated signal families

### Talos

The script exposes these signal IDs:

- `101` = shrine defiance
- `102` = protecting or concealing a worshipper
- `103` = larger defiance milestone

### Auri-El

The script exposes these signal IDs:

- `201` = dawn acknowledgment
- `202` = orthodoxy affirmation

CK-backed callers should route these through `PDV__ManagerQuest`:

- `AwardCuratedSignal(PDV_DeityBase deity, Int signalType, Form contextRef)`
- `AwardCuratedSignalByIndex(Int deityIndex, Int signalType)` for simple testing

Do not use generic hostile-humanoid kill routing as Talos’s first proof lane.

## 6. Seed expectations

Current proof-slice seed expectations from `PDV_Origin.psc`:

- Nord:
  - Kyne = 10
  - Talos = 10
  - Auri-El = 0
- Altmer:
  - Auri-El = 10
  - Kyne = 0
  - Talos = 0

No patron is auto-selected by origin seeding.

## 7. Verification path

After saving the ESP:

1. Run `node .\tools\pdv_compile.mjs --all`
2. Run `node .\tools\pdv_verify.mjs`

Expected verifier closure for this slice:

- `PDV_Deity_Talos` and `PDV_Deity_AuriEl` records found
- both scripts attached
- both quests present in `PDV_FLST_AllDeities`
- origin quest has `PDV_Talos` and `PDV_AuriEl` assigned
- Talos stance row and Auri-El stance row match expected values
- Talos rival list contains only Auri-El
- Talos and Auri-El boon properties are assigned

## 8. Canonical in-game proof

Use a clean Altmer start or clean bootstrap path.

Success story:

1. Altmer begins with seeded Auri-El standing.
2. Player performs an explicit Talos-facing act:
   - illicit Talos shrine use, or
   - protecting/concealing a Talos worshipper
3. Talos piety rises.
4. Auri-El piety drops through rivalry.
5. Patron-only boon behavior still works correctly.

This slice is not complete until that story works in game and the verifier is
clean for the new records/wiring.
