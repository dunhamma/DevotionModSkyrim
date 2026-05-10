# Phase 2 Implementation Summary

**Date:** 2026-05-10  
**Status:** Scripts complete, ready for CK wiring  
**Authored by:** Claude  

---

## What's Been Done

### ✅ Script Creation (Complete)

**1. PDV_DeityBase.psc** — Foundation contract class
- Located: `Devotion\Scripts\Source\PDV_DeityBase.psc`
- Defines the deity contract all concrete deities extend
- Properties: identity (name, domain, index), tier thresholds, origin multipliers, rubric weights, boon spells
- Virtual functions: `ScoreAction()`, `OnTierChange()`, `OnPatronStart()`, `OnPatronEnd()`
- Utility helpers: `GetDeityForm()`, `GetDebugLevel()`
- **Status:** Ready to compile in CK

**2. PDV_Deity_Kyne.psc** — First concrete deity
- Located: `Devotion\Scripts\Source\PDV_Deity_Kyne.psc`
- Extends PDV_DeityBase
- Implements Kyne-specific rubric in `ScoreAction()`:
  - Slaughtering her beasts: -3.0 (forbidden)
  - Combat with humanoids: +0.5 (warriors honored)
  - Shouting (Thu'um): +0.25 (direct communion)
  - Sleeping outdoors: +0.5 (prayer under sky)
  - All other events: 0.0 (no change)
- Overrides `OnTierChange()` to add Kyne-specific trace messages
- Tier thresholds: Seeker (10), Devoted (50), Champion (150)
- Origin multipliers: Nordic 1.25x, Imperial 0.8x, Mer 0.5x, Foreign 0.6x
- **Status:** Ready to compile in CK

**3. PDV__ManagerQuest.psc** — Updated runtime manager
- Located: `Devotion\Scripts\Source\PDV__ManagerQuest.psc`
- Phase 2 additions:
  - New `FormList` property: `PDV_FLST_AllDeities` (will be wired in CK)
  - New `ProcessDawn()` function that:
    - Iterates all deity quests in the FormList
    - Placeholders for per-deity piety consolidation (TODOs for StorageUtil calls)
    - Calls `deity.OnTierChange()` when tier shifts
    - Handles debug tracing at appropriate verbosity levels
  - `GetDebugLevel()` utility function
  - TODO: Uncomment `OnUpdateGameTime()` event when Phase 3 ActionRouter is ready
- Core API (`AwardPiety`, `GetPiety`, `RecomputeTier`, `RefreshPatronMirrors`) unchanged
- **Status:** Ready to compile in CK

### ✅ Documentation

**PDV_Phase2_CK_Steps.md** — Complete Creation Kit walkthrough
- Located: `Devotion Mod Project\PDV_Phase2_CK_Steps.md`
- 7-part step-by-step guide:
  1. Compile all three scripts in CK
  2. Create PDV_Deity_Kyne quest form and configure properties
  3. Create PDV_FLST_AllDeities FormList
  4. Add Kyne to FormList
  5. Update quest properties to wire FormList
  6. Testing checklist
  7. Troubleshooting guide

---

## What You Need to Do (CK Work)

### Critical Path (in order)

1. **Launch CK through MO2** (required for MO2 virtual filesystem)

2. **Compile the three scripts** (creates .pex files in `Data\Scripts\`)
   - Ctrl+F7 in each script editor
   - Move `.pex` files from `Data\Scripts\` to `Devotion\Scripts\`
   - Files: `PDV_DeityBase.pex`, `PDV_Deity_Kyne.pex`, `PDV__ManagerQuest.pex`

3. **Create PDV_Deity_Kyne quest form**
   - ID: `PDV_Deity_Kyne`
   - Type: None
   - Start Game Enabled: Yes
   - Run Once: No
   - Attach script: `PDV_Deity_Kyne`
   - Set properties (see below)

4. **Configure Kyne quest properties** (in quest record Script Data section)
   ```
   DeityName:              Kyne
   DeityDomain:            Storms, Hunt, Warriors' Spirit
   DeityIndex:             0
   ThresholdSeeker:        10.0
   ThresholdDevoted:       50.0
   ThresholdChampion:      150.0
   GainMult_Nordic:        1.25
   GainMult_Imperial:      0.8
   GainMult_Mer:           0.5
   GainMult_Beast:         1.0
   GainMult_Foreign:       0.6
   Weight_Combat:          0.0  (leave for Phase 3)
   Weight_Social:          0.0  (leave for Phase 3)
   Weight_Lifestyle:       0.0  (leave for Phase 3)
   Boon_Seeker:            (None) — will be created Phase 4
   Boon_Devoted:           (None) — will be created Phase 4
   Boon_Champion:          (None) — will be created Phase 4
   ```

5. **Create PDV_FLST_AllDeities FormList**
   - Object window → Miscellaneous → FormLists → New
   - ID: `PDV_FLST_AllDeities`
   - Add Kyne: click "Add Form" → select `PDV_Deity_Kyne` quest

6. **Wire FormList to manager quest**
   - Open `PDV__ManagerQuest` quest properties
   - Script Data section → `PDV_FLST_AllDeities` field
   - Select the FormList you just created
   - Click OK

7. **Verify in-game**
   - Load game, check Papyrus log for `[PDV]` traces
   - Console: `sqv PDV_Deity_Kyne` (verify quest initialized)

---

## Architecture Overview (Phase 2 Complete)

```
playerDevotion_Framework.esp
├── PDV__MainQuest                 (RunOnce bootstrap, Phase 1)
├── PDV__ManagerQuest              (Start-Game-Enabled runtime, Phase 2)
│   ├─ Properties: FormList PDV_FLST_AllDeities
│   ├─ API: AwardPiety, GetPiety, RecomputeTier, RefreshPatronMirrors
│   └─ ProcessDawn() iterates FormList daily
│
├── PDV_FLST_AllDeities            (FormList, Phase 2)
│   └─ Contains: PDV_Deity_Kyne, [future: PDV_Deity_Talos, etc.]
│
├── PDV_Deity_Kyne                 (Start-Game-Enabled quest, Phase 2)
│   ├─ Script: PDV_Deity_Kyne (extends PDV_DeityBase)
│   ├─ ScoreAction() → deity-specific piety deltas
│   ├─ OnTierChange() → manage boons
│   └─ Properties: thresholds, multipliers, boon spells
│
├── PDV_GLO_ActivePiety            (Global, mirror cache)
├── PDV_GLO_ActiveTier             (Global, mirror cache)
└── PDV_GLO_ActiveDeityIndex       (Global, mirror cache)

Scripts location:
├── PDV_DeityBase.psc              Source
├── PDV_DeityBase.pex              Compiled
├── PDV_Deity_Kyne.psc             Source
├── PDV_Deity_Kyne.pex             Compiled
├── PDV__ManagerQuest.psc          Source (updated Phase 2)
└── PDV__ManagerQuest.pex          Compiled (re-run Ctrl+F7)
```

---

## Key Design Decisions Locked in Phase 2

1. **Deity-as-Quest model:** Each deity is a separate persistent quest, not hardcoded logic in the manager. Allows N deities without script duplication.

2. **FormList iteration:** `PDV_FLST_AllDeities` is the single source of truth for which deities exist. Adding deity #2 requires only duplicating the script, creating a quest form, and appending to the FormList.

3. **Mirror globals (active patron only):** `PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex` shadow only the player's chosen patron. Per-deity state lives in StorageUtil (Phase 2+).

4. **Manager as dispatcher:** The manager owns the API and dawn consolidation loop. Deities own their own scoring logic and boon mechanics. Clean separation of concerns.

5. **Boon granting in OnTierChange:** Each deity implements how its boons are granted/revoked on tier transition. Default (inherited) removes old tier's boon, adds new tier's boon. Concrete deities can override for VFX/messages.

---

## Phase 3 Dependency

Phase 3 (ActionRouter + Story Manager integration) depends on Phase 2 being complete:
- `PDV_ActionRouter` needs to iterate `PDV_FLST_AllDeities` to call `deity.ScoreAction()`
- First kill-event node will test Kyne's scoring rubric end-to-end
- ProcessDawn will consolidate the daily piety once ActionRouter is feeding events

Phase 2 standalone is structurally sound but not yet functional for piety ticking. You can verify:
- Quests initialize without errors
- Mirrors read back correctly
- FormList iteration works (ProcessDawn loop is safe, even if TODOs aren't filled yet)

---

## Testing Checklist

After wiring everything in CK:

- [ ] All three scripts compile in CK without errors
- [ ] PDV__ManagerQuest quest properties show `PDV_FLST_AllDeities` field correctly wired
- [ ] PDV_Deity_Kyne quest initializes in-game without script errors
- [ ] Papyrus log shows `[PDV]` traces for quest startup
- [ ] Console: `GetGlobalValue PDV_GLO_ActivePiety` returns 0.0
- [ ] Console: `sqv PDV_Deity_Kyne` shows quest running
- [ ] No CTD (crash to desktop) on load

---

## Files Reference

| File | Status | Purpose |
|------|--------|---------|
| [PDV_DeityBase.psc](d:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_DeityBase.psc) | ✅ Ready to compile | Base contract class |
| [PDV_Deity_Kyne.psc](d:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_Deity_Kyne.psc) | ✅ Ready to compile | Kyne implementation |
| [PDV__ManagerQuest.psc](d:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc) | ✅ Ready to compile | Updated manager |
| [PDV_Phase2_CK_Steps.md](c:\Users\Admin\Documents\Devotion Mod Project\PDV_Phase2_CK_Steps.md) | ✅ Complete guide | Detailed CK walkthrough |
| [Claude.md](c:\Users\Admin\Documents\Devotion Mod Project\Claude.md) | 📝 To update | Add Phase 2 complete entry |

---

## Next: Updates to Living Docs

After completing CK work and testing, update:

1. **Claude.md** - Add Phase 2 completion note to Decisions Log and Build Status
2. **Claude.md** - Update Current Build Status checkbox from `[ ] Phase 2` to `[x] Phase 2`

Template for Claude.md update:
```
[x] Phase 2 — PDV_DeityBase + PDV_Deity_Kyne; PDV_FLST_AllDeities created;
      ProcessDawn loop scaffolding in place; structurally ready for Phase 3
      (CK work completed 2026-05-10)
```

---

## Questions & Troubleshooting

**Q: When do boons actually appear?**  
A: Phase 4. Right now `Boon_Seeker`, `Boon_Devoted`, `Boon_Champion` are left as `None`. They'll be created as blessing spells in Phase 4.

**Q: When does piety actually tick?**  
A: Phase 3. ProcessDawn hook is ready but commented out. Phase 3 creates ActionRouter to feed kill/shout/sleep events. Once events are flowing, ProcessDawn will consolidate them at dawn.

**Q: Can I test tier transitions now?**  
A: Not automatically. But you can use console: `set PDV_GLO_ActivePiety to 15.0` to force a tier change and verify the mirrors work. Full end-to-end testing comes in Phase 3.

**Q: What if I want to add a second deity?**  
A: Duplicate `PDV_Deity_Kyne.psc` → `PDV_Deity_Talos.psc`, change the ScoreAction logic, create a quest form in CK, add it to the FormList. That's it. No manager changes needed. That's the payoff of this architecture.

---

**Questions? Check the comprehensive guide at [PDV_Phase2_CK_Steps.md](c:\Users\Admin\Documents\Devotion Mod Project\PDV_Phase2_CK_Steps.md) or the architecture doc at [PDV_Architecture_v2.md](c:\Users\Admin\Documents\Devotion Mod Project\PDV_Architecture_v2.md).**
