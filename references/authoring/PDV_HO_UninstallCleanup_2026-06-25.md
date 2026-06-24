# PDV Uninstall Cleanup -- "Prepare for uninstall" MCM action (Codex Handoff, 2026-06-25) [queue A5]

## Goal
Add a best-effort, MCM-driven "Prepare for uninstall" action that strips PDV's
live footprint from the player/save so a tester can pull the mod with the least
orphan damage. There is NO cleanup handler today (confirmed: grep for
`PrepareForUninstall`/`Uninstall` in live-source returns nothing; no `StopQuest`
or `Self.Stop()` anywhere in PDV__ManagerQuest.psc). Frame it honestly: this is
BEST-EFFORT, not a guaranteed clean save. The only guaranteed-clean path is the
standard Bethesda one (revert to a save made before the mod was installed).

## Verify-current-state FIRST (grep before authoring)
Multiple "build this" items were found already-built in recent sessions. Before
writing a line, re-grep the live source -- if any piece below already exists,
wire to it instead of duplicating:
- `Grep PrepareForUninstall` and `Grep "Function PrepareForUninstall"` in
  live-source/Scripts/Source/ -- confirm still absent.
- `Grep "_oidPrepareUninstall"` in PDV_MCM.psc -- confirm the option id is unused.
- `Grep "Self.Stop"` / `StopQuest` in PDV__ManagerQuest.psc -- confirm still none.

## Design / steps

All manager work lands in ONE new public function on the manager quest script,
called from a new MCM button. The manager already `extends Quest`
(PDV__ManagerQuest.psc:22), so it can stop itself with `Self.Stop()`.

### 1. New manager function: PrepareForUninstall()
Add near the reward-sync helpers (after `HasRewardSpell`, which ends at
PDV__ManagerQuest.psc:10369). Returns void; do everything defensively
(null-guard playerRef). Order matters: strip spells and factions BEFORE
stopping the quest/unregistering, because once the quest stops the script
context may be torn down.

```
Function PrepareForUninstall()
    Actor playerRef = Game.GetPlayer()

    ; (1) Strip every PDV-granted spell/effect from the player.
    StripAllPdvSpells(playerRef)

    ; (3) RemoveFromFaction for PDV-owned/used factions.
    if NecromancerFaction
        playerRef.RemoveFromFaction(NecromancerFaction)
    endIf
    if WarlockFaction
        playerRef.RemoveFromFaction(WarlockFaction)
    endIf
    ; NOTE: also strip any notoriety hostile-on-sight faction if/when wired
    ; (see memory: notoriety-hostile-on-sight-dossier -- a PDV-owned faction
    ; toggled by AddToFaction; not a manager property today, grep before adding).

    ; (4) Best-effort StorageUtil purge of the big PDV.* namespaces.
    ClearPdvStorageNamespaces()

    ; (2) Halt the runtime: kill the 1s tick / dawn loop, then stop the quest.
    UnregisterForUpdate()
    Self.Stop()

    Debug.MessageBox("Devotion has removed its spells, factions, and most of " + \
        "its saved data. You may now exit to the main menu, remove the mod, " + \
        "and load this save. This is BEST EFFORT and not a guaranteed clean " + \
        "save -- some inert leftover data can remain. The only fully clean " + \
        "removal is to load a save made before Devotion was installed.")
EndFunction
```

### 2. StripAllPdvSpells(Actor playerRef) -- enumerate granted spells
There are 231 `Spell Property PDV_*` declarations on the manager
(PDV__ManagerQuest.psc:107..; `Grep "^Spell Property PDV_"` = 231) and NO
aggregate "all granted spells" FormList exists (`Grep PDV_FLST_All*Reward` etc.
= none). Two ways to enumerate; pick ONE:

OPTION A (preferred, least typing, self-maintaining): reuse the existing
per-race reward-sync helpers in their "remove" direction. The reward grant/strip
already funnels through `SyncRaceRewardSpell(playerRef, spell, shouldBeActive,
label)` at PDV__ManagerQuest.psc:10345 (calls `RemoveSpell` when
shouldBeActive=False). The per-race `Ensure*RaceRewards`/neglect sync functions
(e.g. the `SyncRaceRewardSpell(...)` cluster around 9124-9140 for all 10 T1s,
plus T2/T3 syncs, plus the `PDV_SPEL_Neglect_*` add/remove sites 9111-10271)
drive grant off active tier. A clean way to force-strip: set the player's
worship to "none/foreign" state, then call the existing reconciliation that the
10s tick uses (EnsurePhase8RuntimeWiring + the race reward refreshers), which
will RemoveSpell everything because shouldBeActive resolves false. RISK: that
path is tier/state-driven and may not cover contextual-favor and
adaptation spells. So COMBINE with Option B for the dynamically-added ones.

OPTION B (explicit, exhaustive): RemoveSpell each declared property directly.
Author a flat `StripAllPdvSpells` that calls
`SyncRaceRewardSpell(playerRef, <prop>, False, "<name>")` (reuses the existing
null-guarded remove) for every `PDV_Bless_*`, `PDV_SPEL_Favor_*`,
`PDV_SPEL_Neglect_*`, and the standalone reward/adaptation/naming spells
(`PDV_SPEL_ArgonianAdapt_*` 151-154, `PDV_SPEL_BosmerNaming_*` 163-166,
`PDV_SPEL_SurveyDevotion` 107, etc.). This is ~231 one-line calls but is
mechanical -- generate it from the `^Spell Property PDV_` grep output. It is
the only way to guarantee the dynamically-added spells are caught:
  - Argonian adaptation: `playerRef.AddSpell(chosenAdaptation, ...)` 3398/3447,
    removed 3409/3451 -- so the adapt props ARE properties; covered.
  - Bosmer naming: AddSpell 3826/3879, RemoveSpell 3839/3884 -- props; covered.
  - Daedric path / Champion reward spells: grep `^Spell Property PDV_Path_`/
    `PDV_Daedric`/`PDV_Champion` returned NONE on the manager -- those grants
    live in PDV_DaedricPathBase / per-deity shells, NOT manager properties.
    For uninstall, the Daedric/patron T1-T3 bless spells that ARE manager
    properties get caught by the flat sweep; any path spells granted by the
    Daedric subsystem are out of manager scope -- note this gap honestly in
    the messagebox (already worded "most of its data / best effort").

RECOMMENDATION: do Option B (exhaustive flat sweep over the 231 properties)
as the trunk -- it is deterministic and covers contextual/adaptation/naming
spells that the tier-driven path B would miss. Generate the call list from the
grep; do not hand-curate (you will drop spells).

### 3. ClearPdvStorageNamespaces() -- best-effort StorageUtil purge
Per-deity piety and nearly all runtime flags live in StorageUtil under the
`PDV.` prefix on the None target (`Grep 'StorageUtil\.\w+\(None, "PDV\.'` shows
heavy use). A 100% purge is impractical (per-deity keys, per-prince keys,
day-keyed anti-farm keys, per-race tokens -- hundreds of distinct keys) and
unnecessary: orphaned StorageUtil keys are INERT once the .esp/.pex are gone.
Clear the big roots with PapyrusUtil's prefix clears (StorageUtil.ClearAllPrefix
clears Int+Float+String+Form for a key prefix):

```
StorageUtil.ClearAllPrefix("PDV.")
```

`ClearAllPrefix` is a substring/prefix match in PapyrusUtil, so `"PDV."` sweeps
the whole namespace in one call. Note: any keys NOT under the `PDV.` prefix
(if any per-deity values are stored on a deity Form target rather than None)
are left -- inert. State this is best-effort in the messagebox (already done).
Do NOT attempt to enumerate every key by hand.

### 4. MCM button wiring (PDV_MCM.psc)
Testing is MCM-driven (no cqf). Mirror the existing debug-button pattern:
- Declare the option id alongside the others near PDV_MCM.psc:61-63:
  `Int _oidPrepareUninstall = -1`
- Render it on the Developer/Status debug page where the other action buttons
  are added (the `AddTextOption(...)` cluster around PDV_MCM.psc:1286-1290,
  same page as `_oidSeedBroadLane`/`_oidApplyCuratedSignal`):
  `_oidPrepareUninstall = AddTextOption("Prepare for uninstall", "Strip + stop", OPTION_FLAG_NONE)`
- Handle it in `OnOptionSelect` (PDV_MCM.psc:418), guarded by a confirm box like
  the `_oidSeedBroadLane` handler at 501-506:
```
    if a_option == _oidPrepareUninstall
        if ShowMessage("Prepare Devotion for uninstall? SAVE FIRST. This strips " + \
            "all Devotion spells, removes its factions, clears most of its saved " + \
            "data, and STOPS the mod. It is best-effort, NOT a guaranteed clean " + \
            "save. Continue?", True, "$Yes", "$No")
            if EnsureManagerBinding("prepare_uninstall")
                PDV_Manager.PrepareForUninstall()
            else
                ShowMessage("Devotion is still starting up. Try again in a moment.", False, "$OK", "")
            endIf
        endIf
        return
    endIf
```
  (`EnsureManagerBinding`/`PDV_Manager` are the established MCM->manager call
  pattern, see PDV_MCM.psc:419-430.)

## Serialize note
This touches PDV__ManagerQuest.psc (manager-touching) AND PDV_MCM.psc. Both are
in the project's serialize set (live manager is the high-contention file, and
is the untracked-disappearance-risk script -- snapshot/commit it in the same
pass). SERIALIZE with Codex / any concurrent manager or MCM editor; do not
author while another writer holds either file.

## Verify
1. `node tools/pdv_compile.mjs` -> 0 errors / 0 warnings.
2. `node tools/pdv_verify.mjs` -> FAIL=0.
3. `node tools/pdv_signal_e2e_gate.mjs` -> 0 RED.
4. `node tools/pdv_integrity_harness.mjs` -> PASS.
In-game proof (manual, MCM-driven): on a test save, open the dev page, click
"Prepare for uninstall", confirm; verify via Survey/`player.hasspell` that the
reward/neglect spells are gone, the manager quest is stopped (no more 1s tick
traces in Papyrus.0.log), and the player is out of NecromancerFaction/
WarlockFaction. This is a one-way action on that save -- use a throwaway save.

## Honest framing (keep in player-facing copy)
Always present this as best-effort. The button text and both message boxes must
say it is NOT a guaranteed clean save and that loading a pre-install save is the
only fully clean removal. Do not imply a perfect uninstall.

## Open seams / known gaps to note in the doc, not silently fix
- Daedric-path / Champion grant spells are not manager properties; the flat
  sweep covers only manager-owned bless props. Out-of-scope path spells may
  linger until the .pex is removed (inert). Acceptable for best-effort.
- A notoriety hostile-on-sight PDV faction (per memory dossier) is not a manager
  property today; if it lands later, add its RemoveFromFaction here.
