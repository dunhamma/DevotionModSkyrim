# PDV Live-Manager Local Edits -- Restore Patch

**Created:** 2026-06-20
**Why this file exists:** `PDV__ManagerQuest.psc` lives ONLY in the untracked
live dir (`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\`); it is not
in this repo. Some edits therefore exist only on the live file and have no tracked
source. On 2026-06-20 a Devotion mod "disappearance"/restore reverted the live
manager to an older lineage and wiped these edits (the native bridge survived in
git; the manager edits did not). This file is the recovery source so a future
restore is a documented re-apply, not a from-memory reconstruction.

Pairs with: native bridge commit `019c740` ("Harden Phase 0 Prisma choice channel")
and `references/authoring/PDV_PrismaChoicePanel_CapabilityPlan.md`.

Two independent blocks live here:
- **A. Phase 0 Prisma choice channel** (the throwaway round-trip proof).
- **B. Extended Argonian debug seeds** (re-authored 2026-06-20 against the CURRENT
  manager's keys; the 06-19 originals + their helpers were lost and are NOT in any
  snapshot).

---

## Anchors (current manager structure, 2026-06-20)

- DebugSeed properties sit after `Int Property DebugSeedGo Auto Hidden`, before
  `Spell Property PDV_Bless_Argonian_Sithis_T1 Auto`.
- The `if DebugSeedGo != 0` block is inside `Event OnUpdate()`, just before the
  `Phase0PrismaChoiceTick()` call and `RegisterForSingleUpdate(1.0)`.
- `Phase0PrismaChoiceTick()` is defined immediately before `Function EnsurePhase8RuntimeWiring()`.

---

## A. Phase 0 Prisma choice channel

### A1. Property (after `Int Property DebugSeedGo Auto Hidden`)

```papyrus
Int Property DebugPrismaChoiceGo Auto Hidden
```

### A2. Call inside `Event OnUpdate()` (after the `if DebugSeedGo != 0` block, before `RegisterForSingleUpdate(1.0)`)

```papyrus
    Phase0PrismaChoiceTick()
```

### A3. Function (before `Function EnsurePhase8RuntimeWiring()`)

```papyrus
Function Phase0PrismaChoiceTick()
    if DebugPrismaChoiceGo != 0
        DebugPrismaChoiceGo = 0
        if !PDV_PrismaBridge.IsAvailable() || !PDV_PrismaBridge.SupportsChoice()
            Debug.Notification("PDV Phase 0: Prisma choice channel unavailable (rebuild the DLL). No round trip.")
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
            return
        endIf
        String optionsJson = "{\"choice\":{\"menu\":\"phase0_test\",\"title\":\"Phase 0 round-trip test\",\"prompt\":\"Pick an option, or press Esc to cancel.\",\"options\":[{\"index\":0,\"label\":\"Option A\"},{\"index\":1,\"label\":\"Option B\"}]}}"
        ; pauseGame=false on purpose: a paused game freezes this 1s OnUpdate
        ; watchdog, so a modal trap would be unrecoverable. Phase 0 stays non-modal.
        if PDV_PrismaBridge.ShowChoice("phase0_test", optionsJson, false)
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "phase0_test")
            StorageUtil.SetIntValue(None, "PDV.Phase0Choice.Ticks", 0)
        else
            Debug.Notification("PDV Phase 0: ShowChoice failed to open the panel.")
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
        endIf
        return
    endIf

    String pendingMenu = StorageUtil.GetStringValue(None, "PDV.Phase0Choice.Pending")
    if pendingMenu == ""
        return
    endIf
    Int status = PDV_PrismaBridge.ConsumePendingChoice(pendingMenu)
    if status == -2
        Int ticks = StorageUtil.GetIntValue(None, "PDV.Phase0Choice.Ticks") + 1
        StorageUtil.SetIntValue(None, "PDV.Phase0Choice.Ticks", ticks)
        if ticks >= 20
            PDV_PrismaBridge.CancelChoice()
            StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
            Debug.Notification("PDV Phase 0: watchdog forced unfocus after timeout.")
        endIf
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Phase0Choice.Pending", "")
    if status == -1
        Debug.Notification("PDV Phase 0: CANCELLED (Esc/cancel round trip OK).")
    elseIf status >= 0
        Debug.Notification("PDV Phase 0: picked option " + status + " (round trip OK).")
    else
        Debug.Notification("PDV Phase 0: no result (status " + status + ").")
    endIf
EndFunction
```

---

## B. Extended Argonian debug seeds

Re-authored 2026-06-20 against the CURRENT manager keys (verified by an audit +
adversarial pass + a clean `pdv_compile`). The 06-19 originals called helpers that
no longer exist (`SetArgonianHome`, `ClearArgonianAdaptation`,
`DebugSeedArgonianBedCount/WatersCount`) -- this version inlines everything.

### B1. Properties (after `Int Property DebugSeedGo Auto Hidden`)

```papyrus
Int Property DebugSeedDeclareHomeNow Auto Hidden
Int Property DebugSeedBedCount Auto Hidden
Int Property DebugSeedArgWatersCount Auto Hidden
Int Property DebugSeedAdaptDueNow Auto Hidden
```

### B2. Replace the `if DebugSeedGo != 0` block in `Event OnUpdate()` with:

```papyrus
    if DebugSeedGo != 0
        DebugSeedGo = 0
        DebugSeedArgonian(DebugSeedHist, DebugSeedPeople, DebugSeedVoid)

        ; (1) Declare current cell as Argonian home + clear adaptation.
        if DebugSeedDeclareHomeNow != 0
            DebugSeedDeclareHomeNow = 0
            Actor seedPlayer = Game.GetPlayer()
            Int seedCellId = 0
            Cell seedCell = seedPlayer.GetParentCell()
            if seedCell
                seedCellId = seedCell.GetFormID()
            endIf
            if seedCellId != 0
                Int seedToday = Utility.GetCurrentGameTime() as Int
                StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredFormID", seedCellId)
                StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredDay", seedToday + 1)
                StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", 0)
                RemoveArgonianAdaptationSpells(seedPlayer)
                StorageUtil.SetIntValue(None, "PDV.Adapt.Active", 0)
                Debug.Notification("PDV seed: this cell is now your Argonian home; adaptation cleared.")
            else
                Debug.Notification("PDV seed: no parent cell; home not declared.")
            endIf
        endIf

        ; (2) Rooted-rest sleep count (>=12 arms Rooted Rest). MUST be on the substrate form.
        if DebugSeedBedCount != 0
            Int seedBed = DebugSeedBedCount
            DebugSeedBedCount = 0
            if PDV_ArgonianHistSubstrate
                StorageUtil.SetIntValue(PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", seedBed)
                Debug.Notification("PDV seed: bed-of-choice sleep count set to " + seedBed + ".")
            else
                Debug.Notification("PDV seed: Argonian substrate not wired; bed count unchanged.")
            endIf
        endIf

        ; (3) Sacred-waters count (on None). size-1 arms the all-six milestone on the next NEW site.
        if DebugSeedArgWatersCount != 0
            Int seedWaters = DebugSeedArgWatersCount
            DebugSeedArgWatersCount = 0
            StorageUtil.SetIntValue(None, "PDV.ArgWaters.Count", seedWaters)
            Debug.Notification("PDV seed: sacred-waters count set to " + seedWaters + ".")
        endIf

        ; (4) Arm the (INSTANT) rite now: clear the slot + push Hist composite >=75.
        if DebugSeedAdaptDueNow != 0
            DebugSeedAdaptDueNow = 0
            if PDV_ArgonianHistSubstrate
                StorageUtil.SetIntValue(None, "PDV.Adapt.Active", 0)
                PDV_ArgonianHistSubstrate.SetHistRelation(95.0, "debug_adapt_due_now")
                PDV_ArgonianHistSubstrate.RefreshCompositeMetric("debug_adapt_due_now")
                Debug.Notification("PDV seed: adaptation rite armed (composite " + PDV_ArgonianHistSubstrate.GetMetric() + ", slot cleared); fires next sleep at home or a sacred water.")
            else
                Debug.Notification("PDV seed: Argonian substrate not wired; rite not armed.")
            endIf
        endIf
    endIf
```

### B3. Seed usage (SetPQV, then flip DebugSeedGo)

```
setpqv PDV__ManagerQuest DebugSeedDeclareHomeNow 1
setpqv PDV__ManagerQuest DebugSeedBedCount 12          ; >=12 arms Rooted Rest
setpqv PDV__ManagerQuest DebugSeedArgWatersCount 5     ; PDV_FLST_ArgonianSacredWaters.GetSize()-1
setpqv PDV__ManagerQuest DebugSeedAdaptDueNow 1
setpqv PDV__ManagerQuest DebugSeedGo 1                 ; applies all set seeds this tick
```

### B4. Gotchas (verified by the audit)

- `BedOfChoiceSleepCount` is held on `PDV_ArgonianHistSubstrate.GetSubstrateForm()`,
  NOT `None`. Seeding it on `None` compiles but silently no-ops (the gate reads the
  substrate form).
- `DebugSeedArgWatersCount` only trips the milestone if at least one UNSEEN
  sacred-water site remains (each site has a one-shot `PDV.ArgWaters.Seen.<decId>`
  guard). On a save that has visited all six, seeding the count alone does nothing.
- This build's adaptation rite is INSTANT -- there is no `PDV.Adapt.DueDay` /
  10-14 day clock to seed (see the open finding below). `DebugSeedAdaptDueNow`
  therefore arms via the Hist composite, which also raises real devotion state.

---

## Full restore runbook (after a future mod disappearance)

1. **Native bridge** (tracked since `019c740`):
   - `git checkout 019c740 -- native/DevotionPrismaBridge/` (if the working tree was lost).
   - Deploy view + decls to live:
     - `cp native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js  "D:\Wabbajack\modlists\Anvil\mods\Devotion\PrismaUI\views\Devotion\app.js"`
     - `cp native/DevotionPrismaBridge/mod/Scripts/Source/PDV_PrismaBridge.psc  "D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_PrismaBridge.psc"`
   - Rebuild the DLL (deploys via after_build): from `native/DevotionPrismaBridge`,
     `set PDV_MOD_PATH=D:\Wabbajack\modlists\Anvil\mods\Devotion`, then
     `xmake f -y -m releasedbg` + `xmake -y` (xmake at
     `C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe`).
2. **Manager** (NOT in repo -- re-apply from this file): blocks A1/A2/A3 + B1/B2 at
   the anchors above.
3. **Recompile**: `node tools/pdv_compile.mjs --script PDV_PrismaBridge` then
   `node tools/pdv_compile.mjs --script PDV__ManagerQuest` (both must be `0 error(s)`).
4. **Verify**: `node tools/pdv_prisma_ui_audit.mjs` (13/13); grep the live `.pex`
   for `DebugPrismaChoiceGo` / `Phase0PrismaChoiceTick` / the 4 seed properties.

---

## OPEN FINDING (not yet acted on) -- adaptation rite reverted

The 2026-06-20 restore did NOT only drop Phase 0 + the debug seeds. It reverted the
**Argonian adaptation rite itself** to an older lineage. The current
`TryArgonianAdaptationRite` (live ~L2549) is INSTANT once composite>=75 + rooted +
`PDV.Adapt.Active==0`. The 06-19 version had a **randomized 10-14 in-game-day
maturation clock** (`PDV.Adapt.DueDay` + `Utility.RandomInt(10,14)`) and an extracted
home-declaration helper (`SetArgonianHome`) + `ClearArgonianAdaptation`. Those are
absent from BOTH the current live manager and the 2026-06-15 repo snapshot, so the
snapshot cannot supply them -- the 06-19 rework would need re-authoring from the
06-19 reads / the original design intent. This is pending a product decision (restore
the clock-based rite, or accept the instant rite as current).
