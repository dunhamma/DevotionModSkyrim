# Experience Mode — Record Minting Spec

**Owner:** Claude (ESP/record lane). **Sequenced ahead of:** Codex 1F.
**Design lock:** `references/PDV_ExperienceMode_DesignReference.md`.
**Manifest:** `references/authoring/PDV_ExperienceMode.manifest.json` (already
documents the property-wiring contract; this spec covers the QUST/GLOB
creation + script attach that the manifest marks `unsupported` for `pdv_author`).

## What this batch produces, in order

1. New GLOB record `PDV_GLO_Mode` (Short, init 0) in `Devotion.esp`.
2. New QUST record `PDV_ModePreset` (hidden, start-game-enabled, persistent,
   no aliases) in `Devotion.esp`.
3. Script attachment `PDV_ModePreset` on the new QUST, with properties
   `PDV_Manager → PDV__ManagerQuest` and `PDV_GLO_Mode → PDV_GLO_Mode`.
4. New property `PDV_ModePresetRef → PDV_ModePreset` added to the existing
   VMAD script attachments on `PDV_MCM`, `PDV__ManagerQuest`, and
   `PDV_ActionRouter` (three separate upserts; matches the five operations
   in the manifest).

The five operations in `PDV_ExperienceMode.manifest.json` `operations[]`
already describe (4); they just can't run until (1)–(3) exist as targets
to reference. This spec closes the gap.

---

## Record 1 — `PDV_GLO_Mode` (GLOB)

| Field | Value | Notes |
|-------|-------|-------|
| EditorID | `PDV_GLO_Mode` | Conventional `PDV_GLO_*` prefix; matches `PDV_GLO_DebugLevel` precedent |
| Record type | `GlobalShort` | Mirror takes only 0 / 1, so Short is the cheapest type that fits |
| InitialValue | `0` | Pilgrim's Path default; CK Condition reads on a fresh save return 0 with no manager run required |
| Plugin | `Devotion.esp` | Same plugin as the other `PDV_GLO_*` mirror globals |
| Flags | (none) | Not constant; `PDV_ModePreset.SetMode()` calls `SetValue()` on it |

**Refresh discipline.** Owned exclusively by `PDV_ModePreset.SetMode()`.
Never written from CK Conditions, never written from `PDV__ManagerQuest`.

---

## Record 2 — `PDV_ModePreset` (QUST)

| Field | Value | Notes |
|-------|-------|-------|
| EditorID | `PDV_ModePreset` | Matches the canonical script name in DesignReference §4 |
| Record type | `Quest` | |
| Flags | `Start Game Enabled`, `Run Once` (default), **NOT** `Allow repeated stages`, `Object Window Filter: hidden` | Hidden = doesn't appear in the journal; start-game-enabled = the resolver is alive from new-game onward without needing a stage prompt |
| `Quest Type` | `0` (None) | The script is the entire payload; no journal use |
| Priority | `60` | Same band as other PDV resolver/service quests (`PDV__ManagerQuest`, `PDV_CurseStateService`) |
| Aliases | (none) | Resolver, not an alias host |
| Stages | (none) | Script-only |
| Objectives | (none) | |
| Conditions | (none) | Always runs |
| Plugin | `Devotion.esp` | |

### VMAD script attachment

| | |
|---|---|
| Script name | `PDV_ModePreset` |
| Script flags | `Local` (matches `pdv-stance-author` convention) |
| VMAD `Version` | `5` |
| VMAD `ObjectFormat` | `2` |

#### Properties on the attached script

| Property | Type | Value (FormKey target) | Notes |
|----------|------|------------------------|-------|
| `PDV_Manager` | Object | `PDV__ManagerQuest` (Devotion.esp QUST) | Resolver writes StorageUtil `PDV.Mode` on this Form |
| `PDV_GLO_Mode` | Object | `PDV_GLO_Mode` (Devotion.esp GLOB, from Record 1) | Mirror target |

The five `AutoReadOnly` constants in the `PDV_ModePreset.psc` body
(`MODE_PILGRIM`, `MODE_WAYFARER`, `WAYFARER_GAIN`, `WAYFARER_DAILY_CAP`,
`WAYFARER_DECAY`, `WAYFARER_GRACE`, `WAYFARER_CHEAP_WEIGHT`) are
script-side `AutoReadOnly` — **do NOT add them as VMAD properties**.
AutoReadOnly properties are baked at compile, not in the save.

---

## Record 3 — Property additions on existing QUSTs

These are the five `operations[]` already declared in
`PDV_ExperienceMode.manifest.json`. They become applicable the moment
Records 1 + 2 exist as FormKey targets.

| Target record | Target script | Property added | Value |
|---------------|---------------|----------------|-------|
| `PDV_ModePreset` | `PDV_ModePreset` | `PDV_Manager` | `PDV__ManagerQuest` |
| `PDV_ModePreset` | `PDV_ModePreset` | `PDV_GLO_Mode` | `PDV_GLO_Mode` |
| `PDV_MCM` | `PDV_MCM` | `PDV_ModePresetRef` | `PDV_ModePreset` |
| `PDV__ManagerQuest` | `PDV__ManagerQuest` | `PDV_ModePresetRef` | `PDV_ModePreset` |
| `PDV_ActionRouter` | `PDV_ActionRouter` | `PDV_ModePresetRef` | `PDV_ModePreset` |

Idempotency rule (matches `pdv-stance-author` upsert pattern): if the
property already exists on the script entry, remove it and re-add; do
not duplicate.

VMAD flags on the upserted properties: `Edited` (matches the convention
used by every other PDV authoring tool that writes object properties).

---

## Execution path — recommended

**Write a small new tool, `tools/pdv-mode-preset-author/`, modelled on
`tools/pdv-stance-author/`.** Reasons:

- The pattern is proven (`pdv-stance-author/Program.cs` opens
  `Devotion.esp` via Mutagen, indexes records by EditorID, upserts VMAD
  properties, writes back atomically with a backup).
- One small `.NET` console project. Single command-line invocation. No
  CK launch needed.
- Avoids the houseCARL "writes a patch plugin that loads after
  Devotion.esp" caveat (the memory `housecarl-headless-ck-via-mutagen`
  flags this); pdv-stance-author writes directly into `Devotion.esp` in
  place, which is what we want here.
- Survives re-runs (idempotent upsert).

### Tool contract

```
node-or-dotnet path:  tools/pdv-mode-preset-author/
entry:                Program.cs (top-level)
default ESP path:     D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp
flags:                --dry-run (preview), --esp <path> (override)
output:               JSON AuthorReport on stdout (matches pdv-stance-author)
backups:              D:\...\Devotion\Backups\mode-preset\Devotion.esp.<stamp>.bak
```

Order of operations inside the tool:

1. Load `Devotion.esp` via `SkyrimMod.CreateFromBinary`.
2. Mint `PDV_GLO_Mode` if not present (`mod.Globals.AddNewShort(...)`
   with EditorID + InitialValue 0).
3. Mint `PDV_ModePreset` if not present (`mod.Quests.AddNew(...)`,
   set flags: StartGameEnabled, hidden; Priority 60; QuestType None).
4. Upsert VMAD on `PDV_ModePreset` with script `PDV_ModePreset` and
   properties `PDV_Manager` + `PDV_GLO_Mode` (Object refs).
5. Upsert VMAD properties on `PDV_MCM`, `PDV__ManagerQuest`,
   `PDV_ActionRouter` — each gets a single `PDV_ModePresetRef` Object
   property pointing at `PDV_ModePreset`.
6. Write back atomically (tmp + copy, same pattern as
   pdv-stance-author).

### Alternative paths (if the tool isn't feasible this session)

- **houseCARL `create_record` + `set_field`** on the Anvil Devotion
  instance. Memory `housecarl-headless-ck-via-mutagen` confirms it can
  do these record/VMAD operations headless. Caveat: re-point houseCARL
  to Anvil first; release Anvil lock when done (`housecarl-holds-esp-lock`
  memory). Caveat: confirm output goes into `Devotion.esp` directly, not
  a patch overlay — the `houseCARL-CK-Session-Plan.md` may have the
  invocation pattern.
- **Manual CK.** Open `Devotion.esp` as the active file in CKPE; create
  GLOB then QUST through the Object Window; attach the script via the
  Quest dialog's Papyrus tab; add the property to PDV_MCM /
  PDV__ManagerQuest / PDV_ActionRouter through the same dialog.
  Slowest path; lowest risk if Mutagen-on-MCM-quests behaves oddly.

---

## Readback verification

After running the tool, run these checks (all should PASS before
unblocking Codex 1F):

1. **GLOB exists.** Use houseCARL `read_record` against
   `Devotion.esp|PDV_GLO_Mode`. Confirm `RecordType = GLOB`, subtype
   `Short`, `InitialValue = 0`.
2. **QUST exists.** `read_record` against
   `Devotion.esp|PDV_ModePreset`. Confirm `Flags` include
   `Start Game Enabled`, `Priority = 60`, `VirtualMachineAdapter.Scripts`
   contains one entry named `PDV_ModePreset` with properties
   `PDV_Manager` + `PDV_GLO_Mode` resolving correctly.
3. **MCM property wired.** `read_record` against `PDV_MCM`'s VMAD;
   confirm a `PDV_ModePresetRef` property exists pointing at
   `PDV_ModePreset`.
4. **Manager property wired.** Same on `PDV__ManagerQuest`.
5. **Router property wired.** Same on `PDV_ActionRouter`.
6. **Manifest "operations applied" check.** Run
   `tools/creation-authoring` against
   `references/authoring/PDV_ExperienceMode.manifest.json`. The five
   `setProperty` ops should report `already applied` (or apply
   no-op-cleanly). If any report `not applied`, investigate before
   handing to Codex.
7. **Verifier baseline still green.** `node .\tools\pdv_verify.mjs`
   should still report `FAIL=0`. Records added; nothing should regress.

---

## Sequencing vs Codex 1F

This batch is **independent of the tuning freeze**. It can run at any
time. Sequence:

```
   This record batch
        ↓
   Records exist in Devotion.esp + VMAD properties wired
        ↓
   (tuning freeze lands — Sessions B/C/D + 1B re-author done)
        ↓
   Hand 1F handoff to Codex
        ↓
   Codex writes PDV_ModePreset.psc + manager/MCM integrations
        ↓
   Compile + Codex hand-back
        ↓
   In-game smoke (DesignReference §6, including the new step 5
   Akatosh route)
```

If the record batch runs and Codex's `.psc` work hasn't landed,
the new VMAD properties exist but resolve to `None` at runtime —
all the integration helpers null-guard `PDV_ModePresetRef`, so
behaviour is identical to pre-Wayfarer Pilgrim. No regressions.

---

## Out of scope for this batch

- **`PDV_ModePreset.psc` Papyrus source.** Codex's lane, per the 1F
  handoff Step 1. The script body in DesignReference §4 is final.
- **`PDV_PlayerEvents.psc` level-up hook for the Akatosh route.**
  Codex's lane, per the 1F handoff Step 4a.
- **MCM page strings / lore copy.** DesignReference §5.4 has the
  page structure; the four short label helpers (`GetGainLabel`,
  `GetCeilingLabel`, `GetDecayLabel`, `GetCheapLabel`) are pure
  Papyrus. If you want player-copy review on the labels before
  Codex compiles, route through the `pdv-player-copy` skill.
- **Mirror `PDV_GLO_Mode` track-syncs** across deity track scripts.
  Per 1F handoff Step 3, only needed if any track-script reads mode
  for a CK condition. V1 likely zero; if a future deity dialog
  branches on path, add the parallel sync at that point.
