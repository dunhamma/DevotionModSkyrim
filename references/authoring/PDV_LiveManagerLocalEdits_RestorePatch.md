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

Recovery blocks now live here and in the tracked 2026-06-20 source snapshot:
- **A. Phase 0 Prisma choice channel** (the throwaway round-trip proof).
- **B. Extended Argonian debug seeds** (re-authored 2026-06-20 against the current
  manager's keys).
- **C. Argonian adaptation 10-14 day maturation clock**.
- **D. P2 book notice suffix gate**.
- **E. Startup per-path confirm selector**.
- **F. Orc life-mode organic wiring**.
- **G. Breton per-book Hidden Art notices**.
- **H. Argonian move-home / re-adapt bed-of-choice path**.
- **I. Book of Days Prisma journal hotkey + race/path line**.

Exact current source snapshot:
`generated/live-devotion-snapshot/2026-06-20-restore-recovery/Scripts/Source/`
contains the restored `PDV__ManagerQuest.psc`, `PDV_PlayerEvents.psc`,
`PDV_ActionRouter.psc`, `PDV_EventBus.psc`, and `PDV_MCM.psc`.

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

Re-authored 2026-06-20 against the current manager keys (verified by audit +
targeted Papyrus compile). The first recovery inlined the reset work because the
home helpers had been lost. The later restore-boundary pass reintroduced
`SetArgonianHome` / `ClearArgonianAdaptation`; current live source and the snapshot
therefore use the helper form.

### B1. Properties (after `Int Property DebugSeedGo Auto Hidden`)

```papyrus
Int Property DebugSeedDeclareHomeNow Auto Hidden
Int Property DebugSeedBedCount Auto Hidden
Int Property DebugSeedArgWatersCount Auto Hidden
Int Property DebugSeedAdaptDueNow Auto Hidden
```

### B2. Current `OnUpdate()` block

Use the exact block from the 2026-06-20 restore-recovery snapshot. The current
`DebugSeedDeclareHomeNow` path calls:

```papyrus
SetArgonianHome(seedPlayer, seedCellId, Utility.GetCurrentGameTime() as Int, "debug_seed")
```

That helper clears any active adaptation, resets the rooted-rest count, and rolls
the next adaptation due day.

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
2. **Manager/scripts**: restore from
   `generated/live-devotion-snapshot/2026-06-20-restore-recovery/Scripts/Source/`
   or re-apply the blocks in this file at the anchors above.
3. **Recompile**: `node tools/pdv_compile.mjs --script PDV_PrismaBridge` then
   `node tools/pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents --script PDV_ActionRouter --script PDV_EventBus`
   (all must be `0 error(s), 0 warning(s)`).
4. **Verify**: `node tools/pdv_prisma_ui_audit.mjs` (13/13) and
   `node tools/pdv_verify.mjs`; grep the live `.pex` for `DebugPrismaChoiceGo`,
   `Phase0PrismaChoiceTick`, and the 4 seed properties if the failure was a live
   file disappearance.

---

## C. Adaptation rite 10-14 day maturation clock (RESTORED 2026-06-20)

The 2026-06-20 restore had reverted `TryArgonianAdaptationRite` to an INSTANT version
(fires the moment composite>=75 + rooted + `PDV.Adapt.Active==0`). The 06-19
randomized 10-14 in-game-day maturation clock was re-authored back in -- compiled
0/0 and adversarially verified (arms on the first qualifying sleep, fires exactly
10-14 days later, no off-by-one; the gate's `-1` cancels the `+1` storage convention).

Insert this block in `TryArgonianAdaptationRite` AFTER the `PDV.Adapt.Active != 0`
gate and BEFORE `Utility.Wait(0.5)`:

```papyrus
    ; Grow into the home over time: wait out the randomized 10-14 day clock rolled
    ; on the first qualifying sleep at this home. DueDay is stored as targetDay + 1
    ; so 0 unambiguously means "never armed" (StorageUtil ints default to 0).
    Int dueDay = StorageUtil.GetIntValue(None, "PDV.Adapt.DueDay")
    Int todayDay = Utility.GetCurrentGameTime() as Int
    if dueDay <= 0
        StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", todayDay + Utility.RandomInt(10, 14) + 1)
        return false
    endIf
    if todayDay < (dueDay - 1)
        return false
    endIf
```

Also update the rite header comment to describe the 10-14 day clock (not the stale
"7-day cooldown swap" wording the instant version carried). DebugSeedDeclareHomeNow
zeroes `PDV.Adapt.DueDay` to re-arm; DebugSeedAdaptDueNow sets it to today+1 to mature.

The restore-boundary pass later reintroduced the bed-of-choice move-home helpers.
Moving home now clears adaptation, resets the rooted-rest count, and re-rolls the
10-14 day adaptation clock.

---

## D. P2 book notice suffix gate (RESTORED 2026-06-20)

`IsP2BookNoticeReason` must token-match `po3_book`, not exact-match suffixless
tokens:

```papyrus
return StringContainsToken(reason, "po3_book")
```

This protects all suffixed PO3 book routes, including Dunmer Mephala and per-book
variant reasons.

---

## E. Startup per-path confirm selector (RESTORED 2026-06-20)

The live manager now declares the 13 `PDV_MSG_Confirm_*` properties and routes
startup choices through:

```papyrus
Bool Function ConfirmStartupSelection(Int originRace, Message choiceMessage, Int expectedSelection)
Message Function GetStartupConfirmMessage(Int originRace, Int optionValue)
```

The old `Debug.MessageBox(GetStartupOptionDetailText(...))` middle detail box must
remain absent.

---

## F. Orc life-mode organic wiring (RESTORED 2026-06-20)

Recovered source coverage:

- `PDV_ActionRouter.HandleStoryChangeLocation` calls `HandleOrcLocationChange`.
- `PDV__ManagerQuest` maps exact stronghold `LCTN` FormIDs and handles stronghold
  presence plus Blood-Kin crisis.
- `PDV_PlayerEvents` registers the approved Orc quest-stage sources and routes
  DA06, city Thane, house purchase, Civil War service, and Imperial finale cases.
- `PDV_EventBus` accepts optional organic source IDs for City, Legion, and
  Self-Made routes.

Runtime proof is still separate; this restores reachability and compile-readiness.

---

## G. Breton per-book Hidden Art notices (RESTORED 2026-06-20)

`HandleBretonHiddenArtExposure` now calls per-source title/text helpers. Current
tokens are `hagravens`, `madmen_reach`, and `witch_note`, with a generic fallback.

---

## H. Argonian move-home / re-adapt bed-of-choice path (RESTORED 2026-06-20)

`TryArgonianBedOfChoiceSleep` now requires a three-sleep settle streak before
prompting for a new home. Accepting calls `SetArgonianHome`; declining records a
short cooldown and clears the candidate state. `SetArgonianHome` clears current
adaptation, resets rooted-rest progress, and rolls a new adaptation due day.

---

## I. Book of Days Prisma journal hotkey + race/path line (RESTORED 2026-06-20)

`PDV_MCM.psc` owns the player-facing hotkey:

- `OnGameReload()` resets `PDV.Diegetic.Journal.Open` to `0`.
- `RegisterJournalHotkey()` registers the saved key map value.
- `OnKeyDown()` toggles the Book of Days overlay open/closed outside menu mode.
- The player page exposes `Open Book of Days` as a key map option.

`PDV__ManagerQuest.psc` owns the journal payload:

- `BuildJournalPayloadJson()` includes a `survey` field for the book's left page.
- The `survey` value is race plus path only: `Race | Path`.
- Standing is intentionally excluded from that line because the Book of Days
  standing meter carries standing state.
- Startup-pending saves emit `Race | path not yet chosen`.

The Prisma view renders that payload as `Race · Path` in
`native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js` and places it in
`#pdv-journal-path` from `index.html`.

Do not rebuild this from `GetPlayerMcmSummaryLine()`: that line intentionally
includes standing for MCM/status surfaces.

## Still open (cosmetic): `meta.ini`

`meta.ini` remains missing from the live mod folder (MO2 metadata only; regenerated
by MO2). Not behavioral.
