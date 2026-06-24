# HO_Notoriety -- top-band Notorious -> attack-on-sight (Codex Handoff, 2026-06-25)

**Queue A4 (dispatch-first, serialized on `PDV__ManagerQuest.psc` + adds 1-2 faction records to
`Devotion.esp`).** Full design dossier: `references/authoring/PDV_NotorietyHostileOnSight_Dossier.md`
(read it for rationale; this handoff is the executable distillation). This is a contained V2 slice,
not a system.

## Goal
At the **top band only** (Notorious), make the whitelisted hunter faction attack the player on sight;
lower bands keep the existing rumor/Survey-text treatment. Mechanism = a PDV-owned faction whose OWN
`Relations` array marks the hunter faction `Enemy`, toggled on the player via
`AddToFaction`/`RemoveFromFaction` on entering/leaving the top band. Engine-native combat reaction does
the rest -- NO cloak, NO poll, NO vanilla-record edit.

### The three populations are NOT symmetric (this is the whole job)
- **Vampire** -- ALREADY vanilla-hostile to Vigilants (`VampirePCFaction 0C4DE0` is `Enemy` to
  `VigilantOfStendarrFaction 0B3292`). **DO NOT add Vigilant hostility for vampires** -- that is the
  double-hostility/desync trap. (Optional, lower priority: a Dawnguard extension; see "Deferred".)
- **Human-form werewolf** -- the human-form player (`PlayerWerewolfFaction 091822`) is NOT in the
  Vigilant enemy list, so vanilla never attacks a walking werewolf. **REAL GAP -- build it.**
- **Heretic (Breton Hidden Art, no curse)** -- zero vanilla hostility. **REAL GAP -- build it.** Its
  track (`WitchcraftExposure`) already exists, so the heretic slice can pilot the consequence.

So the two populations to wire are **HERETIC** and **HUMAN-FORM WEREWOLF**. Both gate on
**Vigilants-alive** (`DLC1VQ01` quest still at stage 0).

## verify-current-state FIRST (grep before authoring -- multiple items were found already-built this session)
- `grep -n "AddToFaction\|RemoveFromFaction" live-source/Scripts/Source/PDV__ManagerQuest.psc` --
  currently ZERO hits (greenfield; only `IsInFaction` reads exist at 5812/5816). If a
  `PDV_Faction_Hunted_*` property or a band-cross handler already exists, do not re-author.
- `grep -n "VigilantWorldState\|DLC1VQ01\|Hunted" live-source/Scripts/Source/*.psc` -- confirm the
  world-state helper does not already exist.
- houseCARL on the Anvil/Devotion-Dev instance: confirm no `PDV_Faction_Hunted_Vigilant` record
  already in `Devotion.esp` before `housecarl_create_record`.

## Records to author in Devotion.esp (no vanilla record edited)
Author via houseCARL `housecarl_create_record` (FACT), or pdv-faction author tool if one exists.
- **`PDV_Faction_Hunted_Vigilant`** -- own `Relations`: one entry, `Faction = VigilantOfStendarrFaction`
  (`0B3292:Skyrim.esm`), `Combat = Enemy`. Flags none needed (HiddenFromPC optional). This single
  faction covers BOTH heretic and human-form-werewolf (same hunter, same gate).
- Declare a manager property mirroring the existing faction-property pattern (see
  `Faction Property NecromancerFaction Auto` at `PDV__ManagerQuest.psc:40`):
  `Faction Property PDV_Faction_Hunted_Vigilant Auto` near line 40-41, and CK-wire it.
- **Relation-direction smoke (the ONE technical unknown):** Skyrim resolves combat reaction by taking
  the most-hostile of BOTH factions' relations, so a PDV-side `Enemy` SHOULD make the Vigilant hostile
  to a PDV-faction member without touching the Vigilant record. **Prove this in a throwaway test ESP
  before trusting it.** Fallback if insufficient: add the relation to the vanilla Vigilant record via
  PDV's offline build-time patcher / SkyPatcher (loads after Requiem). Approach A (PDV-side) is
  preferred -- zero vanilla edit, Reqtificator-invisible.

## Design / steps (REUSE existing seams + functions)

### 1. World-state gate helper `PDV_VigilantWorldState` (new tiny script, service-seam style like `PDV_CurseState`)
- `Bool Function VigilantsAlive()`:
  - Resolve `DLC1VQ01` once via `Game.GetFormFromFile(0x00352A, "Dawnguard.esm") as Quest` and cache
    it (per the GetFormFromFile caching guidance).
  - If form is `None` (no Dawnguard installed) -> Vigilants intact -> return `True`.
  - `Quest.GetStage() == 0` (and/or not running) -> intact -> `True`; any value past 0 -> Hall fell ->
    `False`.
  - Re-evaluate on `OnPlayerLoadGame` and on the band-cross, NOT on a timer.
- Alternatively, inline this as a manager helper `Bool Function PDVVigilantsAlive()` to avoid a new
  CK-wired script property -- author choice; the dossier's "redundant NPC-alive OR-check" (Carcette
  dead/disabled) is OPTIONAL belt-and-suspenders, skip for the first cut.

### 2. The band-cross trigger (two emit seams already exist -- hook there, no new event system)

**HERETIC (Breton Hidden Art) -- the only place WitchcraftExposure is written:**
- `HandleBretonHiddenArtExposure(reason)` at `PDV__ManagerQuest.psc:13290`. It does
  `WitchcraftExposure = ClampInt(exposureValue + 25, 0, 100)` at line 13297. Capture `Int oldExposure`
  BEFORE the clamp and `Int newExposure` after, then call a shared
  `EvaluateHereticHostileBand(oldExposure, newExposure, reason)` at the end of the function.
- The DECAY path can drop the band: `DecayBretonWitchcraftExposureAtDawn()` at
  `PDV__ManagerQuest.psc:13181` (subtracts 1/dawn). Capture old/new there too and call the same
  evaluator so the hunt CLEARS when exposure decays below 75.
- Band threshold = **Notorious >= 75** (matches `GetBretonWitchcraftExposureLabel()` at
  `PDV__ManagerQuest.psc:16090`: `>=75 "notorious"`). Reuse that label rather than hardcoding if you
  prefer (`GetBretonWitchcraftExposureLabel()` before/after == "notorious").

**HUMAN-FORM WEREWOLF -- hook the curse-state transition dispatch:**
- `ApplyCurseRaceHandlers(oldState, newState, reason)` at `PDV__ManagerQuest.psc:12493` is the single
  curse-transition fan-out (called from `HandleCurseStateTransition` at 11738). Curse-state ints:
  `1 = werewolf`, `2 = vampire` (per `GetCurseSurfaceKey` at 11779).
- The werewolf hostile band is "the player IS an openly-known werewolf" -- for the first cut treat
  **werewolf curse onset (newState==1) at/above the witnessed-notoriety top band** as Notorious. The
  witnessed-curse-notoriety COUNTER is V2-backlog-item-3 and is NOT yet built (dossier sec.1) -- so
  until that counter exists, gate the werewolf hunt on a simple proxy you DO have (e.g.
  `PDV_CurseStateService.IsWerewolf()` true AND a placeholder `>= top-band` check), or DEFER the
  werewolf slice and ship heretic-only first. **Recommended: ship HERETIC first** (its track is live),
  add a TODO for werewolf once the witnessed counter lands.
- Use `PDV_CurseStateService.IsWerewolf()` (`PDV_CurseState`, property at `PDV__ManagerQuest.psc:106`;
  pattern used at 4790) to confirm human/beast -- the relation only matters in human form, but since the
  beast-form `WerewolfFaction 043594` is ALREADY a Vigilant enemy, the PDV faction-add simply extends
  it to human form. No special-casing of transform state needed.

### 3. Shared evaluator + the AddToFaction/RemoveFromFaction toggle
```
Function EvaluateHereticHostileBand(Int oldExposure, Int newExposure, String reason)
    Bool wasNotorious = oldExposure >= 75
    Bool isNotorious  = newExposure >= 75
    if wasNotorious == isNotorious
        return
    endIf
    Actor pl = Game.GetPlayer()
    if isNotorious
        if PDVVigilantsAlive()
            pl.AddToFaction(PDV_Faction_Hunted_Vigilant)
            SurfaceTransition("reorientation", "hunted_vigilant", "onset", -1, "dread")
        ; else: post-Dawnguard -> DEFER rare authored pressure (see Deferred)
        endIf
    else
        if pl.IsInFaction(PDV_Faction_Hunted_Vigilant)
            pl.RemoveFromFaction(PDV_Faction_Hunted_Vigilant)
            ; combat-clear pass: StopCombat on nearby engaged Vigilants so they forgive
            ; (confirm exact Papyrus API via housecarl:papyrus-reference at build time;
            ;  document the brief cool-down as expected)
            SurfaceTransition("reorientation", "hunted_vigilant", "cure", -1, "release")
        endIf
    endIf
EndFunction
```
- **Surfacing -- REUSE `SurfaceTransition(...)`** (`PDV__ManagerQuest.psc:1724`). Drive the
  "you are now hunted" beat through it (eventClass `"reorientation"` or `"curse"` are pinned to Book of
  Days; pick `"reorientation"`). It already one-shot-guards by `eventClass.surfaceKey.direction` so it
  will not double-fire. Keep the Survey/status line as the persistent readout via
  `GetBretonWitchcraftExposureLabel()` (already wired into Survey at 16017/16090).
- **Do NOT double-fire against curse transitions:** the hostile-on-sight toast fires on the NOTORIETY
  band cross; the curse toast fires on the CURSE transition (`SurfaceCurseTransitionDiegetic`, 11752).
  They are distinct events with distinct surfaceKeys -- keep them separate (the Model B desync lesson).

### 4. Load-game re-evaluation
- On `OnPlayerLoadGame` (or the existing startup/refresh seam), re-run the evaluator with
  old==new==currentExposure so the faction membership is reconciled to the saved band + current
  world-state (e.g. a save made Notorious-pre-Dawnguard that loads post-Dawnguard should drop the
  Vigilant membership). Cheapest: call `EvaluateHereticHostileBand(currentExposure, currentExposure, ...)`
  but force the toggle by comparing membership-vs-desired rather than old-vs-new on the load path.

## Whitelist discipline (NEVER broaden -- dossier sec.6)
- Hunter faction = `VigilantOfStendarrFaction 0B3292` ONLY (gated on Vigilants-alive).
- **NEVER** `CrimeFaction`/guards/townsfolk/merchants/essential NPCs. WitchcraftExposure is religious
  stigma, NOT hold crime-bounty. Faction-relation hostility only touches members of the hunter faction,
  so the whitelist guarantees no merchant/quest-giver breakage by construction.
- `SilverHandFaction 0AA0A4` -- NOT recommended (static, Companions-questline-entangled).

## Deferred (do NOT build in this slice; record as TODO)
- **Vampire Dawnguard extension** (`DLC1HunterFaction 003375`, Enemy to `DLC1VampireFaction 003376`),
  gated on `!Player.IsInFaction(DLC1DawnguardFaction)` so the order does not attack its own member.
  Lower priority; vampires are already covered pre-Dawnguard by vanilla.
- **Post-Vigilant authored pressure** for heretic/human-werewolf after the Hall falls (rare,
  long-cooldown ambush, not a standing relation) -- design-open (dossier 4.3, Appendix B).
- **Witnessed-curse-notoriety counter** (V2 backlog item 3) -- the werewolf band has nothing to hang on
  until this exists; ship heretic-only first.
- Lethal-band ruling: confirm **Notorious-only** (vs V2 backlog's "Known or above") -- dossier 7.1.

## Serialize note (manager-touching = serialize)
`PDV__ManagerQuest.psc` is manager-core and UNTRACKED-live-risk (snapshot the live file). Serialize
against any concurrent manager writer (Codex). The 1-2 FACT records are an in-place `Devotion.esp`
write -- serialize with concurrent ESP writers; houseCARL holds the ESP lock, re-point to DoD to write
if locked, re-point to Anvil after.

## Verify (standing cadence)
`node tools/pdv_compile.mjs` 0/0 -> `node tools/pdv_verify.mjs` FAIL=0 ->
`node tools/pdv_signal_e2e_gate.mjs` 0 RED + parity PASS -> `node tools/pdv_integrity_harness.mjs` PASS.
Then the design-specific proofs (in-game, play-gated, owner): (a) Notorious + Vigilants-alive -> a
living Vigilant attacks; (b) exposure decays below 75 -> hostility clears within the documented
cool-down; (c) post-`DLC1VQ01`-advance -> no Vigilant hunt; (d) the "you are hunted" toast fires once
per band-cross and never double-fires against curse transitions; (e) relation-direction smoke (PDV-side
Enemy actually makes the Vigilant hostile) -- prove in a throwaway test ESP before committing.

## Key live seams (file:line)
- `PDV__ManagerQuest.psc:40-41` -- faction property declaration pattern (`NecromancerFaction`).
- `PDV__ManagerQuest.psc:106` -- `PDV_CurseState Property PDV_CurseStateService` (IsWerewolf/IsVampire).
- `PDV__ManagerQuest.psc:1724` -- `SurfaceTransition(...)` REUSE for the hunted toast.
- `PDV__ManagerQuest.psc:13290` -- `HandleBretonHiddenArtExposure` (heretic +25 write; capture old/new).
- `PDV__ManagerQuest.psc:13181` -- `DecayBretonWitchcraftExposureAtDawn` (band-drop path).
- `PDV__ManagerQuest.psc:16090` -- `GetBretonWitchcraftExposureLabel` (>=75 == "notorious", REUSE).
- `PDV__ManagerQuest.psc:12493` -- `ApplyCurseRaceHandlers` (werewolf-curse hook seam, V2-deferred).
- `PDV__ManagerQuest.psc:8238-8242` -- Breton dawn-refresh block (where decay is called).

## Verified live FormIDs (houseCARL, Devotion Dev)
`VigilantOfStendarrFaction 0B3292:Skyrim.esm` | `PlayerWerewolfFaction 091822` (human, NOT enemy --
the gap) | `WerewolfFaction 043594` (beast, already enemy) | `VampirePCFaction 0C4DE0` (already enemy)
| `DLC1VQ01 00352A:Dawnguard.esm` (world-state gate, stage 0 == intact) | `DLC1HunterFaction
003375:Dawnguard.esm` (deferred vampire extension) | `DLC1VampireFaction 003376:Dawnguard.esm`.
