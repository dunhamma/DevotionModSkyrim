# PDV Bosmer Variety — Papyrus Runtime Handoff

**Created:** 2026-06-12
**Status:** DRAFTED — paste-in spec for the `PDV__ManagerQuest.psc` Bosmer runtime
layer. Authored against the live snapshot
`generated/live-devotion-snapshot/2026-06-12-daedric-champion-parity/Scripts/Source/PDV__ManagerQuest.psc`.
NOT compiled or in-game tested (the canonical `.psc` is Windows-side under the
Devotion MO2 mod; this container has no Papyrus compiler).
**Records:** `references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json`
(closes that manifest's `scriptLayerPending` note — the author tool forward-wires
the 10 VMAD properties; this handoff adds the matching `.psc` declarations + logic).
**Design lock:** `race-sheets/PDV_RaceDesign_Bosmer.md` → "The Story Goes On".
**Modeled on:** the shipped Argonian variety functions in the same script
(`HandleArgonianSleepEvents`, `TryArgonianBedOfChoiceSleep`, `TryArgonianAdaptationRite`,
`HandleArgonianSacredWaterDiscovery`, `TryArgonianPostureDream`, `SyncArgonianAdaptation`).

## What already exists (reused, do not re-author)

The manager already has the Bosmer path spine this layer hangs off:

- Constants: `BOSMER_PATH_OLD_CONTRACT=0`, `BOSMER_PATH_LIVING_STORY=1`,
  `BOSMER_PATH_EXCHANGE=2`, `BOSMER_PATH_BANDIT_ROAD=3`, `ORIGIN_BOSMER=4`.
- `Int GetBosmerPathState()`, `Bool IsBosmerOrigin()`, `Bool IsBosmerPactBound()`,
  `Int GetBosmerGreenPactCompliance()` (0-100; Apostate band = 0-19).
- Exchange signal entry `HandleBosmerExchangeSignal(reason)` and Bandit Road
  `HandleBosmerBanditRoadSignal(reason)`.
- Sleep entry `HandlePlayerSleepStop(playerRef, wasInterrupted, reason)`.
- Dawn entry: the `IsBosmerOrigin() && PDV_BosmerPathTrack` block inside
  `RunDawnRefreshTrackStates()`.
- `Trace(level, msg)`, `GetPlayerOriginRaceIndex()`, standard StorageUtil idioms.

## Lever → trigger → effect map (what this layer wires)

| Lever | Player trigger | In-game effect | Hook |
|---|---|---|---|
| Green Dreams | sleep (elevated the night after a path change) | top-left dream line, path-keyed | sleep dispatcher + dawn arm |
| Hearth of the Telling | Living Story: sleep in declared hearth after 3+ new locations discovered since last stay | `PDV_SPEL_BosmerTaleCarried` (Speech +5, 600s) | sleep dispatcher |
| Songs of the Green | first arrival at each of 6 green LCTNs; milestone at all six | vision line + small path piety; milestone MessageBox | location-change entry (+ OnUpdate interior poll for Eldergleam) |
| Scales at Rest | Exchange: complete a favor/bounty/contract quest (once/day) | `PDV_SPEL_BosmerScalesAtRest` (Speech +10, 120s) | Exchange signal entry |
| Baan Dar Opens the Gap | Bandit Road: drop below 20% health in combat (once/day) | `PDV_SPEL_BosmerBaanDarGap` (SpeedMult +30, 5s) | **external** OnHit (PDV_PlayerEvents) |
| The Naming | sleep at hearth or any Songs site, 7+ days since last rite | one-active told-self ability; dawn fade/restore on path-coherence break | sleep dispatcher + dawn sync |

All gates are path-checked; nothing fires for the Old Contract path except Green
Dreams and the all-path Naming, per the design lock.

---

## STEP 1 — Property declarations

Add after the Argonian variety block (live snapshot line 137,
`FormList Property PDV_FLST_ArgonianSacredWaters Auto`). Names and types match
`PDV_BosmerVariety_RecordBatch.manifest.json` exactly so the author tool's
forward-wired VMAD properties resolve.

```papyrus
; --- Bosmer variety tranche ("The Story Goes On") ---
Spell Property PDV_SPEL_BosmerTaleCarried Auto
Spell Property PDV_SPEL_BosmerScalesAtRest Auto
Spell Property PDV_SPEL_BosmerBaanDarGap Auto
Message Property PDV_MESG_BosmerMarkHearth Auto
Message Property PDV_MESG_BosmerNaming Auto
Spell Property PDV_SPEL_BosmerNaming_Hunter Auto
Spell Property PDV_SPEL_BosmerNaming_Speaker Auto
Spell Property PDV_SPEL_BosmerNaming_Wanderer Auto
Spell Property PDV_SPEL_BosmerNaming_Keeper Auto
FormList Property PDV_FLST_BosmerGreenSongs Auto
```

---

## STEP 2 — Call-site insertions

### 2a. Sleep dispatcher

In `HandlePlayerSleepStop(...)`, after the existing Argonian branch
(`if GetPlayerOriginRaceIndex() == ORIGIN_ARGONIAN ... endIf`), add:

```papyrus
    if GetPlayerOriginRaceIndex() == ORIGIN_BOSMER
        HandleBosmerSleepEvents(playerRef, reason)
    endIf
```

### 2b. Dawn sync (Naming fade/restore + dream arming)

In `RunDawnRefreshTrackStates()`, inside the existing Bosmer block, add the two
calls:

```papyrus
    if IsBosmerOrigin() && PDV_BosmerPathTrack
        EnsureBosmerCurrentPathFallback()
        EvaluateBosmerForcedReckoning()
        SyncBosmerNaming(Game.GetPlayer())        ; ADD
        ArmBosmerDreamOnPathChange()              ; ADD
    endIf
```

### 2c. Exchange signature

In `HandleBosmerExchangeSignal(String reason)`, after the existing
`RecordEvidenceDay`/`AwardCuratedSignal` body, add:

```papyrus
    TryBosmerScalesAtRest(Game.GetPlayer())
```

(Firing from the shared Exchange entry means every Exchange favor — debt settled,
proportionate vengeance — can trip the once/day pulse, gated inside the function.)

### 2d. Location-change entry (external — PDV_PlayerEvents)

`HandleBosmerSongDiscovery` and the Hearth discovery counter both ride one
location-change entry, mirroring how the Argonian `HandleArgonianSacredWaterDiscovery`
is called from the player-alias location hook (that script is not in this snapshot).
In `PDV_PlayerEvents.psc`'s location-change handler (the same place that already
offers `HandleArgonianSacredWaterDiscovery` to the manager), add a sibling call:

```papyrus
    PDV__ManagerQuest.GetScript().HandleBosmerLocationChange(akNewLoc)
    ; (use the manager handle already cached in PDV_PlayerEvents)
```

`HandleBosmerLocationChange` is self-contained in the manager (Step 3), so this is
the only external line for Songs + Hearth-discovery counting. Like the Argonian
Waters set, Bosmer's Eldergleam vision is held for the cave interior (where the
water and great tree are) rather than the exterior approach: the location entry
arms a flag and the OnUpdate poll in Step 2f fires it on the interior cells.

### 2f. OnUpdate interior poll (Eldergleam)

In the 1.0s `OnUpdate` chain, immediately after the existing
`TryArgonianEldergleamInterior()` call (live snapshot line 593), add:

```papyrus
    TryBosmerEldergleamInterior()
```

The function early-returns unless the player is Bosmer and inside the armed
Eldergleam sanctuary, so the per-tick cost is a single StorageUtil read otherwise
— the same shape as the Argonian poll it sits beside.

### 2e. Combat signature (external — PDV_PlayerEvents) — the one piece needing a new hook + test

`Baan Dar Opens the Gap` triggers on "below 20% health in combat," and no
health/OnHit hook exists in the manager today (the Argonian Shadowscale rides a
kill event routed from the player-alias/action-router scripts). Add an `OnHit`
hook on the player alias in `PDV_PlayerEvents.psc` and have it offer the moment to
the manager, which gates it:

```papyrus
Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Actor selfRef = akTarget as Actor
    if selfRef && selfRef == Game.GetPlayer() && selfRef.GetActorValuePercentage("Health") < 0.20
        PDV__ManagerQuest.GetScript().TryBosmerBaanDarGap(selfRef)
    endIf
EndEvent
```

This is the only part of the Bosmer layer that adds a new event registration and
therefore the only part that genuinely needs an in-game smoke pass to confirm
cadence/feel (OnHit fires often; the once/day + path gate inside
`TryBosmerBaanDarGap` is what keeps it quiet). Everything else is manager-internal.

---

## STEP 3 — New manager functions

Paste these alongside the Argonian variety functions (e.g. after
`TryArgonianPostureDream`). All are origin/path-guarded and None-guarded so they
stay inert until the records land.

```papyrus
; ===================== Bosmer variety ("The Story Goes On") =====================

; Sleep-exit dispatcher. Order mirrors the Argonian one: silent declaration/rite
; menus first, dream text last, and a shown menu suppresses the dream that night
; so a MessageBox and a dream toast never stack.
Function HandleBosmerSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return
    endIf

    Int sleepCellId = 0
    Cell sleepCell = playerRef.GetParentCell()
    if sleepCell
        sleepCellId = sleepCell.GetFormID()
    endIf

    Bool menuShown = TryBosmerHearthSleep(playerRef, sleepCellId, reason)
    if !menuShown
        menuShown = TryBosmerNaming(playerRef, sleepCellId, reason)
    endIf
    if !menuShown
        TryBosmerPathDream(reason)
    endIf
EndFunction

; Hearth of the Telling (Living Story only). The hearth is the CELL you sleep in
; (reliable at sleep-stop). First eligible sleep prompts declaration; a decline
; re-prompts only after 3 days. On a return sleep in the declared hearth, if 3+
; new locations have been discovered since the last stay, the tale comes home and
; Tale Carried fires. Returns true only when the declaration menu was shown.
Bool Function TryBosmerHearthSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef
        return false
    endIf
    if GetBosmerPathState() != BOSMER_PATH_LIVING_STORY
        return false
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if declaredId == 0
        if !PDV_MESG_BosmerMarkHearth
            return false
        endIf
        Int declinedDay = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclineDay")
        if declinedDay > 0 && (today + 1 - declinedDay) < 3
            return false
        endIf

        Utility.Wait(0.5)
        Int pressed = PDV_MESG_BosmerMarkHearth.Show()
        if pressed == 0
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DeclaredCell", sleepCellId)
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount"))
            Debug.Notification("This hearth is where your stories come home now.")
        else
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DeclineDay", today + 1)
        endIf
        return true
    endIf

    if sleepCellId != declaredId
        return false
    endIf

    ; Return sleep in the declared hearth: reward only when the player has been
    ; out gathering story (3+ new locations since last stay). Anti-farm is the
    ; discovery delta, not sleep count.
    Int discoveryNow = StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount")
    Int discoveryAtLastStay = StorageUtil.GetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay")
    if (discoveryNow - discoveryAtLastStay) >= 3
        StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", discoveryNow)
        if PDV_SPEL_BosmerTaleCarried
            PDV_SPEL_BosmerTaleCarried.Cast(playerRef, playerRef)
            Debug.Notification("You told the tale, and the telling settled.")
            HandleBosmerLivingStoryCommunityKept(reason + "_tale_carried")
        endIf
    endIf
    return false
EndFunction

; The Naming rite: at the declared hearth or any Songs site, with a 7-day cooldown,
; the player retells their own form. One-active told-self, swap via re-rite
; (clear-before-add). "Not yet" does not spend the cooldown. Returns true when the
; menu was shown so the dream yields that night.
Bool Function TryBosmerNaming(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !PDV_MESG_BosmerNaming || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return false
    endIf

    Bool atSite = false
    Int declaredHearth = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if sleepCellId != 0 && declaredHearth != 0 && sleepCellId == declaredHearth
        atSite = true
    elseIf PDV_FLST_BosmerGreenSongs && playerRef.GetCurrentLocation() && PDV_FLST_BosmerGreenSongs.HasForm(playerRef.GetCurrentLocation())
        atSite = true
    endIf
    if !atSite
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.BosNaming.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = PDV_MESG_BosmerNaming.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" — cooldown not spent
    endIf

    ApplyBosmerNaming(playerRef, pressed)
    return true
EndFunction

; Clear-before-add: never two told-selves at once. Records the path the player was
; on so SyncBosmerNaming can fade/restore on coherence break.
Function ApplyBosmerNaming(Actor playerRef, Int index)
    RemoveBosmerNamingSpells(playerRef)
    Spell chosen = GetBosmerNamingSpell(index)
    if !chosen
        return
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.BosNaming.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.BosNaming.PathAtRite", GetBosmerPathState())
    StorageUtil.SetFloatValue(None, "PDV.BosNaming.LastRiteTime", Utility.GetCurrentGameTime())
    Debug.Notification("You tell yourself anew. The shape settles into you.")
    Trace(2, "Bosmer Naming told-self applied: " + index)
EndFunction

Function RemoveBosmerNamingSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell told = GetBosmerNamingSpell(i)
        if told && playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetBosmerNamingSpell(Int index)
    if index == 0
        return PDV_SPEL_BosmerNaming_Hunter
    elseIf index == 1
        return PDV_SPEL_BosmerNaming_Speaker
    elseIf index == 2
        return PDV_SPEL_BosmerNaming_Wanderer
    elseIf index == 3
        return PDV_SPEL_BosmerNaming_Keeper
    endIf
    return None
EndFunction

; The told-self holds to the path it was named on. Off that path (or, on Old
; Contract, in the Apostate GPC band) it goes quiet at dawn and returns at dawn
; when the player comes back to coherence. PDV.BosNaming.Active stays set while
; quiet so no re-rite is needed.
Function SyncBosmerNaming(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.BosNaming.Active")
    if active <= 0
        return
    endIf
    Spell told = GetBosmerNamingSpell(active - 1)
    if !told
        return
    endIf

    Int pathAtRite = StorageUtil.GetIntValue(None, "PDV.BosNaming.PathAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == ORIGIN_BOSMER) && IsBosmerNamingCoherent(pathAtRite)
    if eligible
        if !playerRef.HasSpell(told)
            playerRef.AddSpell(told, False)
            Debug.Notification("You are yourself again. The told-self returns.")
        endIf
    else
        if playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
            Debug.Notification("The told-self goes quiet. You have wandered from its path.")
        endIf
    endIf
EndFunction

Bool Function IsBosmerNamingCoherent(Int pathAtRite)
    if GetBosmerPathState() != pathAtRite
        return false
    endIf
    if pathAtRite == BOSMER_PATH_OLD_CONTRACT && GetBosmerGreenPactCompliance() < 20
        return false                ; Apostate band
    endIf
    return true
EndFunction

; Green Dreams: armed (strong roll) the night after a path change, otherwise a
; rare ambient murmur. Pure flavor; no piety, no state writes beyond the dream
; bookkeeping keys.
Function TryBosmerPathDream(String reason)
    Int today = Utility.GetCurrentGameTime() as Int
    Int lastDreamDay = StorageUtil.GetIntValue(None, "PDV.BosDream.LastDay")
    if lastDreamDay > 0 && (today - lastDreamDay) < 2
        return
    endIf

    Int dreamChance = 10
    if StorageUtil.GetIntValue(None, "PDV.BosDream.Armed") == 1
        dreamChance = 60
    endIf

    if Utility.RandomInt(1, 100) > dreamChance
        return
    endIf

    Debug.Notification(GetBosmerDreamText(GetBosmerPathState()))
    StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 0)
    StorageUtil.SetIntValue(None, "PDV.BosDream.LastDay", today)
    Trace(2, "Bosmer path dream fired (" + reason + ")")
EndFunction

String Function GetBosmerDreamText(Int pathState)
    if pathState == BOSMER_PATH_OLD_CONTRACT
        if GetBosmerGreenPactCompliance() < 20
            return "You dream of green going grey, and a voice that has stopped expecting you to answer."
        endIf
        return "You dream the old green, ordered and exact, and you know your place in it."
    elseIf pathState == BOSMER_PATH_EXCHANGE
        return "You dream of a ledger no one keeps but you, and every line balancing at last."
    elseIf pathState == BOSMER_PATH_BANDIT_ROAD
        return "You dream of a fire on the road, and faces that owe you nothing and share anyway."
    endIf
    return "You dream the Story still telling itself, and you are a line in it that has not ended."
EndFunction

; Songs of the Green: one location-change entry. Counts every newly-seen location
; (for the Hearth discovery delta) and awards the curated Songs sites once each.
; Eldergleam is held for the interior poll (Step 2f) so the vision lands in the
; cave at the water and the great tree, not at the exterior approach.
Function HandleBosmerLocationChange(Location loc)
    if !loc || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        return
    endIf

    ; New-location counter feeds the Living Story Hearth "3+ since last stay" gate.
    String locSeenKey = "PDV.BosLoc.Seen." + loc.GetFormID()
    if StorageUtil.GetIntValue(None, locSeenKey) == 0
        StorageUtil.SetIntValue(None, locSeenKey, 1)
        StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 1)
    endIf

    ; Eldergleam's water and great tree are inside the cave, but the sanctuary
    ; LOCATION spans the exterior approach. Arm the interior catch and keep the
    ; flag in sync so it clears the moment the player leaves; the OnUpdate poll
    ; awards it on a cave cell. Same shared interior cells as the Argonian set.
    if loc.GetFormID() == 0x000192AC
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 1)
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)

    if PDV_FLST_BosmerGreenSongs && PDV_FLST_BosmerGreenSongs.HasForm(loc)
        AwardBosmerSong(loc.GetFormID())
    endIf
EndFunction

; Bounded poll (OnUpdate): only while inside the armed Eldergleam sanctuary
; LOCATION. Fires the green-song vision when the player reaches an Eldergleam
; interior cave cell -- where the water and great tree are -- not at the exterior
; approach. Disarms on award, on leaving, or once seen. Awards with the LCTN
; FormID so the milestone count stays at 6. Mirrors TryArgonianEldergleamInterior
; (shared interior cells); "Seen.103084" is the decimal render of LCTN 0x000192AC.
Function TryBosmerEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.103084") == 1
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Cell parentCell = Game.GetPlayer().GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        AwardBosmerSong(0x000192AC)
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
    endIf
EndFunction

; One-shot award per Songs site, keyed by LCTN FormID. Small path piety + vision
; line; milestone MessageBox once all six are known.
Function AwardBosmerSong(Int siteFormId)
    String seenKey = "PDV.BosSongs.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.BosSongs.Count", 1)

    ; Small path-keyed piety: route through the active path's living-world signal.
    HandleBosmerPactPositiveSignal("green_song")
    Debug.MessageBox("The green here remembers an older telling. For a breath the Story leans close, and names you part of it.")

    if PDV_FLST_BosmerGreenSongs && seenCount >= PDV_FLST_BosmerGreenSongs.GetSize()
        StorageUtil.SetIntValue(None, "PDV.BosSongs.Milestone", 1)
        Debug.MessageBox("Every green song has known you now. Wherever the road runs, the Story runs with you.")
    endIf
    Trace(2, "Bosmer green song remembered: " + seenCount)
EndFunction

; Scales at Rest (Exchange signature, once/day). Called from HandleBosmerExchangeSignal.
Function TryBosmerScalesAtRest(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || !PDV_SPEL_BosmerScalesAtRest
        return
    endIf
    if GetBosmerPathState() != BOSMER_PATH_EXCHANGE
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.BosSig.ScalesLastDay") == today + 1
        return
    endIf

    PDV_SPEL_BosmerScalesAtRest.Cast(playerRef, playerRef)
    StorageUtil.SetIntValue(None, "PDV.BosSig.ScalesLastDay", today + 1)
    Debug.Notification("The account is even. The bargains fall your way for a while.")
    Trace(2, "Bosmer Scales at Rest fired.")
EndFunction

; Baan Dar Opens the Gap (Bandit Road signature, once/day). Called from the
; player-alias OnHit hook (Step 2e) when player health drops below 20% in combat.
Function TryBosmerBaanDarGap(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != ORIGIN_BOSMER || !PDV_SPEL_BosmerBaanDarGap
        return
    endIf
    if GetBosmerPathState() != BOSMER_PATH_BANDIT_ROAD
        return
    endIf
    if !playerRef.IsInCombat()
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    if StorageUtil.GetIntValue(None, "PDV.BosSig.GapLastDay") == today + 1
        return
    endIf

    PDV_SPEL_BosmerBaanDarGap.Cast(playerRef, playerRef)
    StorageUtil.SetIntValue(None, "PDV.BosSig.GapLastDay", today + 1)
    Debug.Notification("Baan Dar opens the gap. Run.")
    Trace(2, "Bosmer Baan Dar Opens the Gap fired.")
EndFunction

; Dawn helper: arm an elevated dream the night after a path change.
Function ArmBosmerDreamOnPathChange()
    Int currentPath = GetBosmerPathState()
    if StorageUtil.GetIntValue(None, "PDV.BosDream.LastPath") != currentPath
        StorageUtil.SetIntValue(None, "PDV.BosDream.LastPath", currentPath)
        StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 1)
    endIf
EndFunction

; DEBUG seeder for beta testing. Sets path, clears the Naming/signature cooldowns,
; and seeds the discovery counter so the Hearth/Naming gates are reachable fast.
;   cqf PDV__ManagerQuest DebugSeedBosmer <pathIndex 0-3>
Function DebugSeedBosmer(Int pathIndex)
    if GetPlayerOriginRaceIndex() != ORIGIN_BOSMER
        Debug.MessageBox("PDV seed: player origin is not Bosmer (set PDV_GLO_OriginRace to 4 first).")
        return
    endIf
    if PDV_BosmerPathTrack
        PDV_BosmerPathTrack.ForceState(pathIndex, "debug_seed")
    endIf
    StorageUtil.SetFloatValue(None, "PDV.BosNaming.LastRiteTime", 0.0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.ScalesLastDay", 0)
    StorageUtil.SetIntValue(None, "PDV.BosSig.GapLastDay", 0)
    StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 3)
    Debug.MessageBox("PDV seed applied. Bosmer path " + pathIndex + ". Naming/signature cooldowns cleared; +3 discoveries seeded. Naming offered at your hearth or any green song next sleep.")
EndFunction
```

> `PDV_BosmerPathTrack.ForceState(...)` in `DebugSeedBosmer` mirrors the existing
> `DebugSetBosmerPathState` path (live snapshot line 6930). If the track exposes a
> differently-named setter, swap it; the rest of the seeder is independent.

---

## Build sequence (after this layer is pasted in)

1. Land the records first (`pdv-bosmer-variety-author` after resolving the 4
   Songs FormIDs and a clean `--dry-run`), so the 10 properties exist to bind.
2. Paste Steps 1-3 into the canonical `PDV__ManagerQuest.psc`; add Steps 2d/2e to
   `PDV_PlayerEvents.psc`.
3. Recompile (`tools/pdv_compile.mjs`); expect 0 errors. Likely first-pass fixes:
   the `ForceState` setter name (2 above) and confirming `GetActorValuePercentage`
   vs `GetActorValuePercentage("Health")` signature on your SKSE build.
4. Fresh save / `coc qasmoke` (VMAD props bake at first init).
5. Smoke per lever; the OnHit combat signature (2e) is the one needing explicit
   cadence/feel confirmation. Fold results into a new
   `PDV_BetaTestPacket_Bosmer.md` (model on `PDV_BetaTestPacket_Argonian.md`).

## Open notes carried forward

- **Tale Carried piety routing:** the cast also calls
  `HandleBosmerLivingStoryCommunityKept` so the storyteller act feeds Living Story
  piety, not just the buff. Drop that line if playtest shows double-counting with
  another community hook.
- **Songs piety via `HandleBosmerPactPositiveSignal`:** reuses the shared
  living-world signal so the pulse is path-appropriate (Y'ffre/Z'en/Baan Dar) with
  no new per-deity wiring. If a dedicated "green song" signal is later authored,
  repoint `AwardBosmerSong`.
- **Keeper told-self** is Carry Weight +15 (not barter) per the manifest
  reconciliation; `PDV_SPEL_BosmerNaming_Keeper` already carries that effect.
