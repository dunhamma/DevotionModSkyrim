Scriptname PDV_OriginRuntime_Bosmer extends PDV_OriginRuntimeBase

; Bosmer ORIGIN adapter (ADR: PDV_2_0_ADR_OriginAdapterInterface, tranche t1).
; Lane bodies below are copied VERBATIM from PDV_OriginRuntimeBase so the split stays
; provable against origin_golden.json; the only new code is the dispatch layer at the
; bottom, which delegates the base virtuals to the existing named lane verbs.
; The originals still sit on the base -- a same-signature child function is an override,
; and a central pass removes the base copies from the manifest
; (references/authoring/PDV_2_0_AdapterManifest_t1.json).

; --- Origin-owned script variables moved from the base (referenced ONLY by this lane).
;     A Papyrus child cannot read a parent script variable, so these must live here. ---
ObjectReference _bosGildergreenRef
ObjectReference _bosYffreTreeStoneRef

; ===========================================================================
; LANE FUNCTIONS -- verbatim copies (79)
; ===========================================================================

Function EnsureBosmerRuntimeWiring()
    if Manager.PDV_BosmerPathTrack
        if Manager.PDV_BosmerPathTrack.TrackName != "BosmerPath"
            Manager.PDV_BosmerPathTrack.TrackName = "BosmerPath"
        endIf

        if Manager.PDV_BosmerPathTrack.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
            Manager.PDV_BosmerPathTrack.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
        endIf

        if Manager.PDV_BosmerPathTrack.StateLabels.Length != 4
            String[] labels = new String[4]
            labels[0] = "the Old Contract"
            labels[1] = "the Living Story"
            labels[2] = "the Exchange"
            labels[3] = "the Bandit Road"
            Manager.PDV_BosmerPathTrack.StateLabels = labels
        endIf
    endIf

    EnsureBosmerYffreRuntimeIdentity()
    EnsureBosmerZenRuntimeIdentity()
    EnsureBosmerBaanDarRuntimeIdentity()
EndFunction

Function EnsureBosmerYffreRuntimeIdentity()
    if !Manager.PDV_Yffre
        return
    endIf

    if Manager.PDV_Yffre.DeityName != "Y'ffre"
        Manager.PDV_Yffre.DeityName = "Y'ffre"
    endIf

    if Manager.PDV_Yffre.DeityDomain == ""
        Manager.PDV_Yffre.DeityDomain = "Story, Green Pact, Forest Law"
    endIf

    if Manager.PDV_Yffre.DeityIndex != 3
        Manager.PDV_Yffre.DeityIndex = 3
    endIf

    if Manager.PDV_Yffre.Stance_Bosmer != Manager.PDV_Yffre.STANCE_NATIVE
        Manager.PDV_Yffre.Stance_Bosmer = Manager.PDV_Yffre.STANCE_NATIVE
    endIf

    if Manager.PDV_Yffre.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.PDV_Yffre.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
    endIf

    if Manager.PDV_Yffre.PDV_GLO_OriginRace != Manager.PDV_GLO_OriginRace
        Manager.PDV_Yffre.PDV_GLO_OriginRace = Manager.PDV_GLO_OriginRace
    endIf

    if Manager.PDV_Yffre.EligibleStateTrack != Manager.PDV_BosmerPathTrack
        Manager.PDV_Yffre.EligibleStateTrack = Manager.PDV_BosmerPathTrack
    endIf

    if Manager.PDV_Yffre.EligibleStateValues.Length != 2
        Int[] eligibleStates = new Int[2]
        eligibleStates[0] = Manager.BOSMER_PATH_OLD_CONTRACT
        eligibleStates[1] = Manager.BOSMER_PATH_LIVING_STORY
        Manager.PDV_Yffre.EligibleStateValues = eligibleStates
    endIf
EndFunction

Function EnsureBosmerZenRuntimeIdentity()
    if !Manager.LedgerRuntime.PDV_Zen
        return
    endIf

    if Manager.LedgerRuntime.PDV_Zen.DeityName != "Z'en"
        Manager.LedgerRuntime.PDV_Zen.DeityName = "Z'en"
    endIf

    if Manager.LedgerRuntime.PDV_Zen.DeityDomain == ""
        Manager.LedgerRuntime.PDV_Zen.DeityDomain = "Exchange, Reciprocity, Restitution"
    endIf

    if Manager.LedgerRuntime.PDV_Zen.DeityIndex != 4
        Manager.LedgerRuntime.PDV_Zen.DeityIndex = 4
    endIf

    if Manager.LedgerRuntime.PDV_Zen.Stance_Bosmer != Manager.LedgerRuntime.PDV_Zen.STANCE_NATIVE
        Manager.LedgerRuntime.PDV_Zen.Stance_Bosmer = Manager.LedgerRuntime.PDV_Zen.STANCE_NATIVE
    endIf

    if Manager.LedgerRuntime.PDV_Zen.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.LedgerRuntime.PDV_Zen.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
    endIf

    if Manager.LedgerRuntime.PDV_Zen.PDV_GLO_OriginRace != Manager.PDV_GLO_OriginRace
        Manager.LedgerRuntime.PDV_Zen.PDV_GLO_OriginRace = Manager.PDV_GLO_OriginRace
    endIf

    if Manager.LedgerRuntime.PDV_Zen.EligibleStateTrack != Manager.PDV_BosmerPathTrack
        Manager.LedgerRuntime.PDV_Zen.EligibleStateTrack = Manager.PDV_BosmerPathTrack
    endIf

    if Manager.LedgerRuntime.PDV_Zen.EligibleStateValues.Length != 1 || Manager.LedgerRuntime.PDV_Zen.EligibleStateValues[0] != Manager.BOSMER_PATH_EXCHANGE
        Int[] eligibleStates = new Int[1]
        eligibleStates[0] = Manager.BOSMER_PATH_EXCHANGE
        Manager.LedgerRuntime.PDV_Zen.EligibleStateValues = eligibleStates
    endIf
EndFunction

Function EnsureBosmerBaanDarRuntimeIdentity()
    if !Manager.PDV_BaanDar
        return
    endIf

    if Manager.PDV_BaanDar.DeityName != "Baan Dar"
        Manager.PDV_BaanDar.DeityName = "Baan Dar"
    endIf

    if Manager.PDV_BaanDar.DeityDomain == ""
        Manager.PDV_BaanDar.DeityDomain = "Road, Theft, Survival Cunning"
    endIf

    if Manager.PDV_BaanDar.DeityIndex != 5
        Manager.PDV_BaanDar.DeityIndex = 5
    endIf

    if Manager.PDV_BaanDar.Stance_Bosmer != Manager.PDV_BaanDar.STANCE_NATIVE
        Manager.PDV_BaanDar.Stance_Bosmer = Manager.PDV_BaanDar.STANCE_NATIVE
    endIf

    if Manager.PDV_BaanDar.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.PDV_BaanDar.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
    endIf

    if Manager.PDV_BaanDar.PDV_GLO_OriginRace != Manager.PDV_GLO_OriginRace
        Manager.PDV_BaanDar.PDV_GLO_OriginRace = Manager.PDV_GLO_OriginRace
    endIf

    if Manager.PDV_BaanDar.EligibleStateTrack != Manager.PDV_BosmerPathTrack
        Manager.PDV_BaanDar.EligibleStateTrack = Manager.PDV_BosmerPathTrack
    endIf

    if Manager.PDV_BaanDar.EligibleStateValues.Length != 1 || Manager.PDV_BaanDar.EligibleStateValues[0] != Manager.BOSMER_PATH_BANDIT_ROAD
        Int[] eligibleStates = new Int[1]
        eligibleStates[0] = Manager.BOSMER_PATH_BANDIT_ROAD
        Manager.PDV_BaanDar.EligibleStateValues = eligibleStates
    endIf
EndFunction

Int Function GetBosmerPathEvidenceDays()
    if !Manager.PDV_BosmerPathTrack
        return 0
    endIf
    Int currentPath = Manager.PDV_BosmerPathTrack.GetCurrentState()
    if currentPath <= 0
        return 0
    endIf
    return Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(currentPath, 7)
EndFunction

Function HandleBosmerSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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

Bool Function TryBosmerHearthSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef
        return false
    endIf

    ; fix-plan 4.2: the hearth decline cadence is a devotional-day cadence like every
    ; other sleep rite, not a raw-midnight one -- a midnight crossed mid-sleep must not
    ; shorten the 3-day re-prompt window. ReadZeroReserved migrates the legacy +1 stamp.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if declaredId == 0
        if !Manager.PDV_MESG_BosmerMarkHearth
            return false
        endIf
        Int declinedDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.BosHearth.DeclineDay")
        if declinedDay > 0 && (todayStamp - declinedDay) < 3
            return false
        endIf

        Utility.Wait(0.5)
        Int pressed = Manager.PDV_MESG_BosmerMarkHearth.Show()
        ; B4 / fix-plan 3. -1 is "not shown" -- no decline stamp, retry next sleep.
        if pressed < 0
            Manager.Trace(2, "Bosmer hearth menu not shown (menu busy); no decline stamped.")
            return false
        endIf
        if pressed == 0
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DeclaredCell", sleepCellId)
            StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount"))
            Manager.SendPrismaToast("yffre", "good", "Hearth declared", "This is where your stories come home now.")
        else
            Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.BosHearth.DeclineDay")
        endIf
        return true
    endIf

    if sleepCellId != declaredId
        return false
    endIf
    if GetBosmerPathState() != Manager.BOSMER_PATH_LIVING_STORY
        return false
    endIf

    ; Return sleep in the declared hearth: reward only when the player has been
    ; out gathering story (3+ new locations since last stay). Anti-farm is the
    ; discovery delta, not sleep count.
    Int discoveryNow = StorageUtil.GetIntValue(None, "PDV.BosLoc.DiscoveryCount")
    Int discoveryAtLastStay = StorageUtil.GetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay")
    if (discoveryNow - discoveryAtLastStay) >= 3
        StorageUtil.SetIntValue(None, "PDV.BosHearth.DiscoveryAtLastStay", discoveryNow)
        if Manager.PDV_SPEL_BosmerTaleCarried
            Manager.PDV_SPEL_BosmerTaleCarried.Cast(playerRef, playerRef)
            Manager.SendPrismaToast("yffre", "good", "Tale carried", "You told the tale, and the telling settled.")
            HandleBosmerLivingStoryCommunityKept(reason + "_tale_carried")
        endIf
    endIf
    return false
EndFunction

Bool Function TryBosmerNaming(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MESG_BosmerNaming || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
        return false
    endIf

    Bool atSite = false
    Int declaredHearth = StorageUtil.GetIntValue(None, "PDV.BosHearth.DeclaredCell")
    if sleepCellId != 0 && declaredHearth != 0 && sleepCellId == declaredHearth
        atSite = true
    elseIf Manager.PDV_FLST_BosmerGreenSongs && playerRef.GetCurrentLocation() && Manager.PDV_FLST_BosmerGreenSongs.HasForm(playerRef.GetCurrentLocation())
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
    Int pressed = Manager.PDV_MESG_BosmerNaming.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyBosmerNaming(playerRef, pressed)
    return true
EndFunction

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
    Manager.SendPrismaToast("yffre", "good", "Naming", "You tell yourself anew. The shape settles into you.")
    Manager.Trace(2, "Bosmer Naming told-self applied: " + index)
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
        return Manager.PDV_SPEL_BosmerNaming_Hunter
    elseIf index == 1
        return Manager.PDV_SPEL_BosmerNaming_Speaker
    elseIf index == 2
        return Manager.PDV_SPEL_BosmerNaming_Wanderer
    elseIf index == 3
        return Manager.PDV_SPEL_BosmerNaming_Keeper
    endIf
    return None
EndFunction

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
    Bool eligible = (GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER) && IsBosmerNamingCoherent(pathAtRite)
    if eligible
        if !playerRef.HasSpell(told)
            playerRef.AddSpell(told, False)
            Manager.SendPrismaToast("yffre", "good", "Told-self restored", "You are yourself again.")
        endIf
    else
        if playerRef.HasSpell(told)
            playerRef.RemoveSpell(told)
            Manager.SendPrismaToast("yffre", "warning", "The told-self goes quiet", "You have wandered from its path.")
        endIf
    endIf
EndFunction

Bool Function IsBosmerNamingCoherent(Int pathAtRite)
    if GetBosmerPathState() != pathAtRite
        return false
    endIf
    if pathAtRite == Manager.BOSMER_PATH_OLD_CONTRACT && GetBosmerGreenPactCompliance() < 20
        return false                ; Apostate band
    endIf
    return true
EndFunction

Function TryBosmerPathDream(String reason)
    ; fix-plan 4.2: sleep-triggered cadence -- devotional day, not raw midnight.
    Int today = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int lastDreamDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.BosDream.LastDay")
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

    Manager.SendPrismaToast("yffre", "neutral", "Green dream", GetBosmerDreamText(GetBosmerPathState()))
    StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 0)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.BosDream.LastDay")
    Manager.Trace(2, "Bosmer path dream fired (" + reason + ")")
EndFunction

String Function GetBosmerDreamText(Int pathState)
    if pathState == Manager.BOSMER_PATH_OLD_CONTRACT
        if GetBosmerGreenPactCompliance() < 20
            return "You dream of green going grey, and a voice that has stopped expecting you to answer."
        endIf
        return "You dream the old green, ordered and exact, and you know your place in it."
    elseIf pathState == Manager.BOSMER_PATH_EXCHANGE
        return "You dream of a ledger no one keeps but you, and every line balancing at last."
    elseIf pathState == Manager.BOSMER_PATH_BANDIT_ROAD
        return "You dream of a fire on the road, and faces that owe you nothing and share anyway."
    endIf
    return "You dream the Story still telling itself, and you are a line in it that has not ended."
EndFunction

Function HandleBosmerLocationChange(Location loc)
    if !loc || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
        return
    endIf

    ; New-location counter feeds the Living Story Hearth "3+ since last stay" gate.
    String locSeenKey = "PDV.BosLoc.Seen." + loc.GetFormID()
    if StorageUtil.GetIntValue(None, locSeenKey) == 0
        StorageUtil.SetIntValue(None, locSeenKey, 1)
        StorageUtil.AdjustIntValue(None, "PDV.BosLoc.DiscoveryCount", 1)
    endIf

    Bool armEldergleam = False
    if loc.GetFormID() == 0x000192AC
        armEldergleam = True
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", PDV_DevotionRules.BoolToInt(armEldergleam))

    Bool armGildergreen = False
    if loc.GetFormID() == 0x00018A56
        armGildergreen = True
    endIf
    StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", PDV_DevotionRules.BoolToInt(armGildergreen))

    Bool armTreeStone = PDV_DevotionRules.IsLocationFromFile(loc, 0x000142B6, "Dragonborn.esm")
    StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", PDV_DevotionRules.BoolToInt(armTreeStone))

    if armEldergleam || armGildergreen || armTreeStone
        return
    endIf

    ; Temple of Kynareth interior (0x0001F87D) stays the Gildergreen song's FLST
    ; slot id (milestone-of-6 count + Naming-at-songs check), but the vision must
    ; NOT fire inside the temple -- suppress the interior direct award; the
    ; Gildergreen poll awards slot 0x0001F87D at the tree instead.
    if loc.GetFormID() == 0x0001F87D
        return
    endIf

    TryAwardBosmerYffreLocationSite(loc)

    if Manager.PDV_FLST_BosmerGreenSongs && Manager.PDV_FLST_BosmerGreenSongs.HasForm(loc)
        AwardBosmerSong(loc.GetFormID())
    endIf
EndFunction

Bool Function TryAwardBosmerYffreLocationSite(Location loc)
    if PDV_DevotionRules.IsLocationFromFile(loc, 0x00003583, "Dawnguard.esm")
        return TryAwardBosmerYffreGreenSite("ancestor_glade", "location_ancestor_glade")
    elseIf PDV_DevotionRules.IsLocationFromFile(loc, 0x000142DF, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_wind", "location_allmaker_wind")
    elseIf PDV_DevotionRules.IsLocationFromFile(loc, 0x000142DE, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_water", "location_allmaker_water")
    elseIf PDV_DevotionRules.IsLocationFromFile(loc, 0x000142DC, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_sun", "location_allmaker_sun")
    elseIf PDV_DevotionRules.IsLocationFromFile(loc, 0x000142A4, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_earth", "location_allmaker_earth")
    elseIf PDV_DevotionRules.IsLocationFromFile(loc, 0x00014296, "Dragonborn.esm")
        return TryAwardBosmerYffreGreenSite("allmaker_beast", "location_allmaker_beast")
    endIf

    return False
EndFunction

Function TryBosmerEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Bool songSeen = StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.103084") == 1
    Bool yffreSeen = StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.eldergleam") == 1
    if songSeen && yffreSeen
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
        return
    endIf

    Cell parentCell = Game.GetPlayer().GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        if !songSeen
            AwardBosmerSong(0x000192AC)
        endIf
        TryAwardBosmerYffreGreenSite("eldergleam", "location_eldergleam")
        StorageUtil.SetIntValue(None, "PDV.BosSongs.EldergleamActive", 0)
    endIf
EndFunction

Function TryBosmerGildergreenProximity()
    if StorageUtil.GetIntValue(None, "PDV.BosSongs.GildergreenActive") != 1
        return
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
        return
    endIf

    Bool songSeen = StorageUtil.GetIntValue(None, "PDV.BosSongs.Seen.129149") == 1
    Bool yffreSeen = StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.gildergreen") == 1
    if songSeen && yffreSeen
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
        return
    endIf

    if !_bosGildergreenRef
        _bosGildergreenRef = Game.GetFormFromFile(0x00023612, "Skyrim.esm") as ObjectReference
    endIf
    if !_bosGildergreenRef
        return
    endIf

    if Game.GetPlayer().GetDistance(_bosGildergreenRef) < 600.0
        if !songSeen
            AwardBosmerSong(0x0001F87D)
        endIf
        TryAwardBosmerYffreGreenSite("gildergreen", "location_gildergreen")
        StorageUtil.SetIntValue(None, "PDV.BosSongs.GildergreenActive", 0)
    endIf
EndFunction

Function TryBosmerYffreTreeStoneProximity()
    if StorageUtil.GetIntValue(None, "PDV.Yffre.TreeStoneActive") != 1
        return
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.allmaker_tree") == 1
        StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", 0)
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Cell parentCell = playerRef.GetParentCell()
    if !parentCell || parentCell.IsInterior()
        return
    endIf

    if !_bosYffreTreeStoneRef
        _bosYffreTreeStoneRef = Game.GetFormFromFile(0x00026EEC, "Dragonborn.esm") as ObjectReference
    endIf
    if !_bosYffreTreeStoneRef
        return
    endIf

    if playerRef.GetDistance(_bosYffreTreeStoneRef) < 700.0
        TryAwardBosmerYffreGreenSite("allmaker_tree", "location_allmaker_tree")
        StorageUtil.SetIntValue(None, "PDV.Yffre.TreeStoneActive", 0)
    endIf
EndFunction

Bool Function TryAwardBosmerYffreGreenSite(String siteKey, String reason)
    String seenKey = "PDV.Yffre.Seen." + siteKey
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return False
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.YffreGreenSite")
        Manager.Trace(2, "Y'ffre green site capped for today: " + siteKey)
        return False
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    StorageUtil.AdjustIntValue(None, "PDV.Yffre.SiteCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Yffre.LastSite", siteKey)
    StorageUtil.SetFloatValue(None, "PDV.Yffre.LastSiteTime", Utility.GetCurrentGameTime())
    HandleBosmerLivingStoryNatureSite(reason)
    Manager.Trace(2, "Y'ffre green site remembered: " + siteKey)
    return True
EndFunction

Function AwardBosmerSong(Int siteFormId)
    String seenKey = "PDV.BosSongs.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.BosSongs.Count", 1)

    ; Small path-keyed piety: route through the active path's living-world signal.
    HandleBosmerPactPositiveSignal("green_song")
    Debug.MessageBox("For a breath, the Story enfolds you and names you a part of it. This place still holds the blessings of Y'ffre.")

    if Manager.PDV_FLST_BosmerGreenSongs && seenCount >= Manager.PDV_FLST_BosmerGreenSongs.GetSize()
        StorageUtil.SetIntValue(None, "PDV.BosSongs.Milestone", 1)
        Debug.MessageBox("Every Green Song is known to you now. Wherever the road goes, the Story travels with you.")
    endIf
    Manager.Trace(2, "Bosmer green song remembered: " + seenCount)
EndFunction

Function TryBosmerScalesAtRest(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || !Manager.PDV_SPEL_BosmerScalesAtRest
        return
    endIf
    if GetBosmerPathState() != Manager.BOSMER_PATH_EXCHANGE
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.BosSig.ScalesLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_BosmerScalesAtRest.Cast(playerRef, playerRef)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.BosSig.ScalesLastDay")
    Manager.SendPrismaToast("zenithar", "good", "Scales at rest", "The bargains fall your way for a while.")
    Manager.Trace(2, "Bosmer Scales at Rest fired.")
EndFunction

Function TryBosmerBaanDarGap(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || !Manager.PDV_SPEL_BosmerBaanDarGap
        return
    endIf
    if GetBosmerPathState() != Manager.BOSMER_PATH_BANDIT_ROAD
        return
    endIf
    if !playerRef.IsInCombat()
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.BosSig.GapLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_BosmerBaanDarGap.Cast(playerRef, playerRef)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.BosSig.GapLastDay")
    HandleBosmerBanditRoadReversal("baandar_gap_low_health")
    Manager.SendPrismaToast("baandar", "good", "Baan Dar opens the gap", "Run.")
    Manager.Trace(2, "Bosmer Baan Dar Opens the Gap fired.")
EndFunction

Function ArmBosmerDreamOnPathChange()
    Int currentPath = GetBosmerPathState()
    if StorageUtil.GetIntValue(None, "PDV.BosDream.LastPath") != currentPath
        StorageUtil.SetIntValue(None, "PDV.BosDream.LastPath", currentPath)
        StorageUtil.SetIntValue(None, "PDV.BosDream.Armed", 1)
    endIf
EndFunction

Function HandleBosmerLivingStorySignal(String reason)
    if !IsBosmerOrigin() || !Manager.PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerLivingStory")
    if multiplier <= 0.0
        return
    endIf

    Manager.PDV_BosmerPathTrack.RecordEvidenceDay(Manager.BOSMER_PATH_LIVING_STORY, reason)
    if Manager.PDV_BosmerPathTrack.GetCurrentState() == Manager.BOSMER_PATH_LIVING_STORY && Manager.PDV_Yffre
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_LIVING_STORY, None, multiplier)
    endIf
EndFunction

Function HandleBosmerExchangeSignal(String reason)
    if !IsBosmerOrigin() || !Manager.PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerExchange")
    if multiplier <= 0.0
        return
    endIf

    Manager.PDV_BosmerPathTrack.RecordEvidenceDay(Manager.BOSMER_PATH_EXCHANGE, reason)
    if Manager.PDV_BosmerPathTrack.GetCurrentState() == Manager.BOSMER_PATH_EXCHANGE && Manager.LedgerRuntime.PDV_Zen
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zen, Manager.LedgerRuntime.PDV_Zen.SIGNAL_EXCHANGE, None, multiplier)
    endIf

    TryBosmerScalesAtRest(Game.GetPlayer())
EndFunction

Function HandleBosmerBanditRoadSignal(String reason)
    if !IsBosmerOrigin() || !Manager.PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerBanditRoad")
    if multiplier <= 0.0
        return
    endIf

    Manager.PDV_BosmerPathTrack.RecordEvidenceDay(Manager.BOSMER_PATH_BANDIT_ROAD, reason)
    if Manager.PDV_BosmerPathTrack.GetCurrentState() == Manager.BOSMER_PATH_BANDIT_ROAD && Manager.PDV_BaanDar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_BANDIT_ROAD, None, multiplier)
    endIf
EndFunction

Function HandleBosmerPactPositiveSignal(String reason)
    if !IsBosmerOrigin() || !Manager.PDV_BosmerPathTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BosmerPactPositive")

    Manager.PDV_BosmerPathTrack.RecordEvidenceDay(Manager.BOSMER_PATH_OLD_CONTRACT, reason)
    if IsBosmerPactBound()
        AdjustBosmerGreenPactCompliance(5, reason)
        if Manager.PDV_Yffre && multiplier > 0.0
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_PACT_POSITIVE, None, multiplier)
        endIf
        return
    endIf

    if multiplier > 0.0
        Int currentPath = Manager.PDV_BosmerPathTrack.GetCurrentState()
        if currentPath == Manager.BOSMER_PATH_LIVING_STORY && Manager.PDV_Yffre
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        elseIf currentPath == Manager.BOSMER_PATH_EXCHANGE && Manager.LedgerRuntime.PDV_Zen
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zen, Manager.LedgerRuntime.PDV_Zen.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        elseIf currentPath == Manager.BOSMER_PATH_BANDIT_ROAD && Manager.PDV_BaanDar
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_SHARED_PACT_MEMORY, None, multiplier)
        endIf
    endIf
EndFunction

Function HandleBosmerOldContractProperHunt(String reason)
    if RecordBosmerFavorSignal("OldContract.ProperHunt", Manager.BOSMER_PATH_OLD_CONTRACT, reason)
        HandleBosmerPactPositiveSignal(reason + "_proper_hunt")
    endIf
EndFunction

Function HandleBosmerOldContractForestKept(String reason)
    if RecordBosmerFavorSignal("OldContract.ForestKept", Manager.BOSMER_PATH_OLD_CONTRACT, reason)
        HandleBosmerPactPositiveSignal(reason + "_forest_kept")
    endIf
EndFunction

Function HandleBosmerLivingStoryCommunityKept(String reason)
    if RecordBosmerFavorSignal("LivingStory.CommunityKept", Manager.BOSMER_PATH_LIVING_STORY, reason)
        HandleBosmerLivingStorySignal(reason + "_community_kept")
    endIf
EndFunction

Function HandleBosmerLivingStoryNatureSite(String reason)
    if RecordBosmerFavorSignal("LivingStory.NatureSite", Manager.BOSMER_PATH_LIVING_STORY, reason)
        HandleBosmerLivingStorySignal(reason + "_nature_site")
    endIf
EndFunction

Function HandleBosmerExchangeDebtSettled(String reason)
    if RecordBosmerFavorSignal("Exchange.DebtSettled", Manager.BOSMER_PATH_EXCHANGE, reason)
        HandleBosmerExchangeSignal(reason + "_debt_settled")
    endIf
EndFunction

Function HandleBosmerExchangeProportionateVengeance(String reason)
    if RecordBosmerFavorSignal("Exchange.ProportionateVengeance", Manager.BOSMER_PATH_EXCHANGE, reason)
        HandleBosmerExchangeSignal(reason + "_proportionate_vengeance")
    endIf
EndFunction

Function HandleBosmerBanditRoadRoadLife(String reason)
    if RecordBosmerFavorSignal("BanditRoad.RoadLife", Manager.BOSMER_PATH_BANDIT_ROAD, reason)
        HandleBosmerBanditRoadSignal(reason + "_road_life")
    endIf
EndFunction

Function HandleBosmerBanditRoadReversal(String reason)
    if !CanRecordBosmerMajorFavor("BanditRoad.Reversal", 7.0, reason)
        return
    endIf

    if RecordBosmerFavorSignal("BanditRoad.Reversal", Manager.BOSMER_PATH_BANDIT_ROAD, reason)
        HandleBosmerBanditRoadSignal(reason + "_reversal")
    endIf
EndFunction

Bool Function RecordBosmerFavorSignal(String favorKey, Int pathState, String reason)
    if !IsBosmerOrigin() || !Manager.PDV_BosmerPathTrack
        return False
    endIf

    String baseKey = "PDV.Bosmer.Favor." + favorKey
    StorageUtil.AdjustIntValue(None, baseKey + ".Count", 1)
    StorageUtil.SetIntValue(None, baseKey + ".Path", pathState)
    StorageUtil.SetFloatValue(None, baseKey + ".LastTime", Utility.GetCurrentGameTime())
    StorageUtil.AdjustIntValue(None, "PDV.Bosmer.Favor.SignalCount", 1)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.Favor.LastSignalTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Bosmer favor " + favorKey + " recorded for path " + pathState + " (" + reason + ")")
    return True
EndFunction

Bool Function CanRecordBosmerMajorFavor(String favorKey, Float cooldownDays, String reason)
    if !IsBosmerOrigin()
        return False
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    String baseKey = "PDV.Bosmer.Favor." + favorKey
    Float lastTime = StorageUtil.GetFloatValue(None, baseKey + ".LastMajorTime")
    if lastTime > 0.0 && nowTime - lastTime < cooldownDays
        StorageUtil.AdjustIntValue(None, baseKey + ".RejectCount", 1)
        Manager.Trace(2, "Bosmer major favor " + favorKey + " rejected by cooldown (" + reason + ")")
        return False
    endIf

    StorageUtil.SetFloatValue(None, baseKey + ".LastMajorTime", nowTime)
    return True
EndFunction

Function SyncBosmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isBosmer = GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER
    Int pathState = GetBosmerPathState()
    Bool broadFaithful = isBosmer && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && GetBosmerFavorSignalCount() >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Bosmer_Yffre_T2, broadFaithful, "Bosmer Yffre T2")

    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_OLD_CONTRACT, pathState, Manager.PDV_Yffre, Manager.PDV_Bless_Bosmer_OldContract_T1, Manager.PDV_Bless_Bosmer_OldContract_T2, Manager.PDV_Bless_Bosmer_OldContract_T3, "OldContract")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_LIVING_STORY, pathState, Manager.PDV_Yffre, Manager.PDV_Bless_Bosmer_LivingStory_T1, Manager.PDV_Bless_Bosmer_LivingStory_T2, Manager.PDV_Bless_Bosmer_LivingStory_T3, "LivingStory")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_EXCHANGE, pathState, Manager.LedgerRuntime.PDV_Zen, Manager.PDV_Bless_Bosmer_Exchange_T1, Manager.PDV_Bless_Bosmer_Exchange_T2, Manager.PDV_Bless_Bosmer_Exchange_T3, "Exchange")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_BANDIT_ROAD, pathState, Manager.PDV_BaanDar, Manager.PDV_Bless_Bosmer_BanditRoad_T1, Manager.PDV_Bless_Bosmer_BanditRoad_T2, Manager.PDV_Bless_Bosmer_BanditRoad_T3, "BanditRoad")
EndFunction

Function SyncBosmerPathRewardFamily(Actor playerRef, Int thisPath, Int activePath, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER && thisPath == activePath
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Bosmer " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Bosmer " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Bosmer " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Bosmer " + label)
EndFunction

Int Function GetBosmerPathState()
    if Manager.PDV_BosmerPathTrack
        Int pathState = Manager.PDV_BosmerPathTrack.GetCurrentState()
        if pathState >= Manager.BOSMER_PATH_OLD_CONTRACT && pathState <= Manager.BOSMER_PATH_BANDIT_ROAD
            return pathState
        endIf
    endIf

    return Manager.BOSMER_PATH_LIVING_STORY
EndFunction

Int Function GetBosmerFavorSignalCount()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.Favor.SignalCount")
EndFunction

Bool Function IsBosmerPathNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
        return False
    endIf

    Int pathState = GetBosmerPathState()
    if pathState == Manager.BOSMER_PATH_EXCHANGE
        return Manager.LedgerRuntime.IsNeglectFlagActive(Manager.LedgerRuntime.PDV_Zen)
    elseIf pathState == Manager.BOSMER_PATH_BANDIT_ROAD
        return Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_BaanDar)
    endIf

    return Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Yffre)
EndFunction

Function SyncBosmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Bosmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Bosmer)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Bosmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Bosmer)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Bosmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BosmerSpellActive", 0)
    endIf
EndFunction

String Function GetBosmerNativeMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", Manager.PDV_Yffre, "The Green, story, and the Old Contract.")
    entries = entries + "," + Manager.RosterMedallionEntry("auri-el", "Auri-El", "god", "auri-el", Manager.PDV_AuriEl, "Elven ancestry and high memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("xarxes", "Xarxes", "god", "xarxes", Manager.PDV_Xarxes, "Record, lineage, and written memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", Manager.PDV_BaanDar, "Trickster road, masks, and survival.")
    return entries
EndFunction

String Function GetBosmerFocusMedallionEntriesJson()
    return Manager.RosterMedallionEntry("zen", "Z'en", "god", "zen", Manager.LedgerRuntime.PDV_Zen, "Debt, toil, exchange, and obligation.")
EndFunction

Bool Function HasBosmerSetupCompleted()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.SetupComplete") == 1
EndFunction

Function ApplyBosmerInitialChoice(Int pathState, String reason)
    if !Manager.PDV_BosmerPathTrack
        return
    endIf

    Manager.BeginRaceSetupQuietPresentation(reason)
    InitializeBosmerStorage()
    Manager.PDV_BosmerPathTrack.SetState(pathState, reason)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 1)

    if pathState == Manager.BOSMER_PATH_OLD_CONTRACT
        EnterBosmerOldContract(True, reason)
    else
        SetBosmerPactBound(False, reason)
        SetBosmerGreenPactCompliance(0, reason)
        ApplyBosmerPathPatron(pathState, reason)
    endIf
    Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(GetBosmerPathLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", GetBosmerPathSymbol(pathState), True, 3, "", True)
    Manager.EndRaceSetupQuietPresentation()
EndFunction

Function InitializeBosmerStorage()
    if StorageUtil.GetIntValue(None, "PDV.Bosmer.Initialized") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.SetupComplete", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.PactBound", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactCompliance", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.LapsedFromPact", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.Initialized", 1)
EndFunction

Bool Function IsBosmerPactBound()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.PactBound") == 1
EndFunction

Function SetBosmerPactBound(Bool isBound, String reason)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.PactBound", PDV_DevotionRules.BoolToInt(isBound))
    Manager.Trace(2, "Bosmer PactBound -> " + PDV_DevotionRules.BoolToInt(isBound) + " (" + reason + ")")
EndFunction

Int Function GetBosmerGreenPactCompliance()
    return PDV_DevotionRules.ClampInt(StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactCompliance"), 0, 100)
EndFunction

Function SetBosmerGreenPactCompliance(Int value, String reason)
    Int normalizedValue = PDV_DevotionRules.ClampInt(value, 0, 100)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactCompliance", normalizedValue)
    Manager.Trace(2, "Bosmer GreenPactCompliance -> " + normalizedValue + " (" + reason + ")")
EndFunction

Function AdjustBosmerGreenPactCompliance(Int delta, String reason)
    SetBosmerGreenPactCompliance(GetBosmerGreenPactCompliance() + delta, reason)
EndFunction

Int Function GetBosmerLapsedFromPact()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.LapsedFromPact")
EndFunction

Function SetBosmerLapsedFromPact(Int value, String reason)
    Int normalizedValue = value
    if normalizedValue < 0
        normalizedValue = 0
    elseIf normalizedValue > 2
        normalizedValue = 2
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.LapsedFromPact", normalizedValue)
    Manager.Trace(2, "Bosmer LapsedFromPact -> " + normalizedValue + " (" + reason + ")")
EndFunction

Bool Function HasBosmerTerminalRenunciation()
    return GetBosmerLapsedFromPact() >= 2
EndFunction

Function EnterBosmerOldContract(Bool isStartupChoice, String reason)
    if HasBosmerTerminalRenunciation()
        Manager.Trace(1, "Old Contract entry blocked by terminal renunciation.")
        return
    endIf

    SetBosmerPactBound(True, reason)
    if GetBosmerLapsedFromPact() > 0
        SetBosmerGreenPactCompliance(30, reason)
    elseIf isStartupChoice
        SetBosmerGreenPactCompliance(80, reason)
    else
        SetBosmerGreenPactCompliance(60, reason)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", 0.0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
    ApplyBosmerPathPatron(Manager.BOSMER_PATH_OLD_CONTRACT, reason)

    if Manager.PDV_Yffre && GetBosmerLapsedFromPact() > 0
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_RECOMMITMENT, None)
    endIf
EndFunction

Function ExitBosmerOldContract(Bool countLapse, String reason)
    if !IsBosmerPactBound()
        return
    endIf

    SetBosmerPactBound(False, reason)
    if countLapse
        SetBosmerLapsedFromPact(GetBosmerLapsedFromPact() + 1, reason)
    endIf

    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 0)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
EndFunction

Function ApplyBosmerPathPatron(Int pathState, String reason)
    PDV_DeityBase deity = GetBosmerForegroundDeity(pathState)
    if !deity
        Manager.Trace(1, "Bosmer foreground deity missing for state " + pathState + " (" + reason + ")")
        return
    endIf

    Manager.LedgerRuntime.SetActiveDeity(deity)
    Manager.Trace(2, "Bosmer foreground patron -> " + deity.DeityName + " (" + reason + ")")
    Manager.SurfaceTransition("reorientation", GetBosmerPathLabel(), "shift", deity.DeityIndex, "turning")
EndFunction

PDV_DeityBase Function GetBosmerForegroundDeity(Int pathState)
    if pathState == Manager.BOSMER_PATH_OLD_CONTRACT || pathState == Manager.BOSMER_PATH_LIVING_STORY
        return Manager.PDV_Yffre
    elseIf pathState == Manager.BOSMER_PATH_EXCHANGE
        return Manager.LedgerRuntime.PDV_Zen
    elseIf pathState == Manager.BOSMER_PATH_BANDIT_ROAD
        return Manager.PDV_BaanDar
    endIf

    return None
EndFunction

Function EnsureBosmerCurrentPathFallback()
    if !Manager.PDV_BosmerPathTrack || !HasBosmerSetupCompleted()
        return
    endIf

    if Manager.PDV_BosmerPathTrack.GetCurrentState() != Manager.PDV_BosmerPathTrack.UnsetSentinel
        return
    endIf

    Manager.PDV_BosmerPathTrack.SetState(Manager.BOSMER_PATH_LIVING_STORY, "fallback")
    SetBosmerPactBound(False, "fallback")
    ApplyBosmerPathPatron(Manager.BOSMER_PATH_LIVING_STORY, "fallback")
EndFunction

Function EvaluateBosmerForcedReckoning()
    if !IsBosmerPactBound()
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        return
    endIf

    if GetBosmerGreenPactCompliance() >= 20
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        return
    endIf

    Int apostateDays = StorageUtil.GetIntValue(None, "PDV.Bosmer.ApostateDays") + 1
    StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", apostateDays)
    if apostateDays < 3
        return
    endIf

    if !Manager.PDV_MSG_BosmerReckoning
        Debug.MessageBox("Devotion is missing the Bosmer reckoning message record.")
        Manager.Trace(1, "Bosmer reckoning blocked: message record missing.")
        return
    endIf

    Int choice = Manager.PDV_MSG_BosmerReckoning.Show()
    ; B4 / fix-plan 3 -- the worst of the six. Show() returns -1 whenever another menu or
    ; message is already up, and -1 fell into the else branch below, FORCE-SEVERING the Old
    ; Contract pact with no player input whatsoever. Treat it as "not shown": nothing is
    ; stamped or changed, ApostateDays stays at its 3+ value, and the reckoning re-attempts
    ; at the next dawn (the three-dawn condition still holds).
    if choice < 0
        Manager.Trace(1, "Bosmer reckoning not shown (menu busy); pact untouched, retry next dawn.")
        return
    endIf
    if choice == 0
        SetBosmerGreenPactCompliance(30, "reckoning_recommit")
        StorageUtil.SetIntValue(None, "PDV.Bosmer.ApostateDays", 0)
        if Manager.PDV_Yffre
            Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_RECOMMITMENT, None)
        endIf
    else
        ExitBosmerOldContract(True, "reckoning_renounce")
        Manager.PDV_BosmerPathTrack.SetState(Manager.BOSMER_PATH_LIVING_STORY, "reckoning_renounce")
        ApplyBosmerPathPatron(Manager.BOSMER_PATH_LIVING_STORY, "reckoning_renounce")
    endIf
EndFunction

Function EvaluateBosmerPathSuggestion()
    if !Manager.PDV_BosmerPathTrack || !HasBosmerSetupCompleted()
        return
    endIf

    if Manager.PDV_BosmerPathTrack.HasOfferedTransition() || Manager.PDV_BosmerPathTrack.IsTransitionPending() || Manager.PDV_BosmerPathTrack.IsTransitionLockedOut()
        return
    endIf

    Int targetState = GetSuggestedBosmerPathState()
    if targetState < 0
        return
    endIf

    Manager.PDV_BosmerPathTrack.OfferTransition(targetState, "dawn_suggestion")
    HandleBosmerSuggestionPopup(targetState)
EndFunction

Int Function GetSuggestedBosmerPathState()
    if !Manager.PDV_BosmerPathTrack
        return -1
    endIf

    Int currentState = Manager.PDV_BosmerPathTrack.GetCurrentState()
    Int bestState = -1
    Int bestScore = -1

    Int livingCount = Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(Manager.BOSMER_PATH_LIVING_STORY, 7)
    if currentState != Manager.BOSMER_PATH_LIVING_STORY && livingCount >= 1
        bestState = Manager.BOSMER_PATH_LIVING_STORY
        bestScore = 10 + livingCount
    endIf

    Int exchangeCount = Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(Manager.BOSMER_PATH_EXCHANGE, 7)
    if currentState != Manager.BOSMER_PATH_EXCHANGE && exchangeCount >= 2 && (20 + exchangeCount) > bestScore
        bestState = Manager.BOSMER_PATH_EXCHANGE
        bestScore = 20 + exchangeCount
    endIf

    Int banditCount = Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(Manager.BOSMER_PATH_BANDIT_ROAD, 7)
    if currentState != Manager.BOSMER_PATH_BANDIT_ROAD && banditCount >= 2 && (20 + banditCount) > bestScore
        bestState = Manager.BOSMER_PATH_BANDIT_ROAD
        bestScore = 20 + banditCount
    endIf

    Int pactCount = Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(Manager.BOSMER_PATH_OLD_CONTRACT, 7)
    if currentState != Manager.BOSMER_PATH_OLD_CONTRACT && !HasBosmerTerminalRenunciation() && pactCount >= 3 && (30 + pactCount) > bestScore
        bestState = Manager.BOSMER_PATH_OLD_CONTRACT
    endIf

    return bestState
EndFunction

Function HandleBosmerSuggestionPopup(Int targetState)
    Message suggestionMessage = GetBosmerSuggestionMessage(targetState)
    if !suggestionMessage
        Debug.MessageBox("Devotion is missing the Bosmer path suggestion message record.")
        Manager.PDV_BosmerPathTrack.ClearOfferedTransition("missing_message")
        Manager.Trace(1, "Bosmer suggestion popup blocked for " + targetState + ": message record missing.")
        return
    endIf

    String pathSymbol = GetBosmerPathSymbol(targetState)
    Int choice = suggestionMessage.Show()
    if choice == 0
        Manager.PDV_BosmerPathTrack.AcceptOfferedTransition("popup_accept")
        Manager.SendPrismaToast(pathSymbol, "good", "A new path stirs", "Confirm the change at the next rite.")
    else
        Manager.PDV_BosmerPathTrack.RefuseOfferedTransition("popup_refuse")
        Manager.SendPrismaToast(pathSymbol, "neutral", "The call fades", "You turn aside from that path for now.")
    endIf
EndFunction

String Function GetBosmerPathSymbol(Int pathState)
    if pathState == Manager.BOSMER_PATH_EXCHANGE
        return "zen"
    elseIf pathState == Manager.BOSMER_PATH_BANDIT_ROAD
        return "baan-dar"
    endIf
    return "yffre"
EndFunction

Message Function GetBosmerSuggestionMessage(Int targetState)
    if targetState == Manager.BOSMER_PATH_LIVING_STORY
        return Manager.PDV_MSG_BosmerSuggestLivingStory
    elseIf targetState == Manager.BOSMER_PATH_EXCHANGE
        return Manager.PDV_MSG_BosmerSuggestExchange
    elseIf targetState == Manager.BOSMER_PATH_BANDIT_ROAD
        return Manager.PDV_MSG_BosmerSuggestBanditRoad
    elseIf targetState == Manager.BOSMER_PATH_OLD_CONTRACT
        return Manager.PDV_MSG_BosmerSuggestOldContract
    endIf

    return None
EndFunction

Function ConfirmBosmerPendingTransition(String reason)
    if !Manager.PDV_BosmerPathTrack || !Manager.PDV_BosmerPathTrack.IsTransitionPending()
        return
    endIf

    Int pendingState = Manager.PDV_BosmerPathTrack.GetPendingState()
    if !CanConfirmBosmerPathState(pendingState)
        Manager.PDV_BosmerPathTrack.CancelPendingTransition("rite_invalid")
        Manager.SendPrismaToast(GetBosmerPathSymbol(pendingState), "warning", "The rite fails", "The new path has not yet been proven.")
        return
    endIf

    Int currentState = Manager.PDV_BosmerPathTrack.GetCurrentState()
    if currentState == Manager.BOSMER_PATH_OLD_CONTRACT && pendingState != Manager.BOSMER_PATH_OLD_CONTRACT
        ExitBosmerOldContract(True, reason)
    endIf

    Manager.PDV_BosmerPathTrack.ConfirmPendingTransition(reason)
    if pendingState == Manager.BOSMER_PATH_OLD_CONTRACT
        EnterBosmerOldContract(False, reason)
    else
        SetBosmerPactBound(False, reason)
        ApplyBosmerPathPatron(pendingState, reason)
        if pendingState == Manager.BOSMER_PATH_LIVING_STORY && Manager.PDV_Yffre
            Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_LIVING_STORY, None)
        elseIf pendingState == Manager.BOSMER_PATH_EXCHANGE && Manager.LedgerRuntime.PDV_Zen
            Manager.LedgerRuntime.AwardCuratedSignal(Manager.LedgerRuntime.PDV_Zen, Manager.LedgerRuntime.PDV_Zen.SIGNAL_CONFIRMATION, None)
        elseIf pendingState == Manager.BOSMER_PATH_BANDIT_ROAD && Manager.PDV_BaanDar
            Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_CONFIRMATION, None)
        endIf
    endIf

    Manager.SendPrismaShiftToast(GetBosmerPathLabel(), "", Manager.GetPrismaSymbolForDeity(Manager.GetActiveDeity()))
    Manager.AppendBookOfDaysEntry("Y'ffre's song settles within you. Your road through the Green is the " + GetBosmerPathLabel() + ".", Utility.GetCurrentGameTime() as Int, "reorientation", Manager.GetPrismaSymbolForDeity(Manager.GetActiveDeity()), False, 3)
    Manager.RequestPanelRefresh()
EndFunction

Bool Function CanConfirmBosmerPathState(Int targetState)
    if !Manager.PDV_BosmerPathTrack
        return False
    endIf

    if targetState == Manager.BOSMER_PATH_LIVING_STORY
        return Manager.PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 1, 7)
    elseIf targetState == Manager.BOSMER_PATH_EXCHANGE
        return Manager.PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 2, 7)
    elseIf targetState == Manager.BOSMER_PATH_BANDIT_ROAD
        return Manager.PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 2, 7)
    elseIf targetState == Manager.BOSMER_PATH_OLD_CONTRACT
        if HasBosmerTerminalRenunciation()
            return False
        endIf
        return Manager.PDV_BosmerPathTrack.HasRecentEvidenceDays(targetState, 3, 7)
    endIf

    return False
EndFunction

String Function GetBosmerSurveyText()
    if !Manager.PDV_BosmerPathTrack
        return "The Green is here, but no path has been declared yet. Sleep and choose the Old Contract, the Living Story, the Exchange, or the Bandit Road."
    endIf

    Int pathValue = Manager.PDV_BosmerPathTrack.GetCurrentState()
    String band = Manager.GetCurrentStandingBand()
    String text = ""
    if pathValue == Manager.BOSMER_PATH_OLD_CONTRACT
        text = "You walk the Old Contract, the Green Pact kept in full. Standing: " + band + ". Compliance: " + GetBosmerComplianceBand() + ". Y'ffre holds you to the terms."
        if IsBosmerPactBound()
            text = text + " The Pact is binding, and you are keeping to it."
        elseIf GetBosmerLapsedFromPact()
            text = text + " The Pact has lapsed, and a reckoning with Y'ffre is owed."
        else
            text = text + " The Pact is not yet taken up; the terms wait on your word."
        endIf
    elseIf pathValue == Manager.BOSMER_PATH_LIVING_STORY
        text = "You walk the Living Story, the covenant carried in memory and community. Standing: " + band + ". The Story passes through you."
    elseIf pathValue == Manager.BOSMER_PATH_EXCHANGE
        text = "You walk the Exchange, the world kept even debt by debt. Standing: " + band + ". Z'en weighs your account."
    else
        text = "You walk the Bandit Road, the exile's theology of the open road. Standing: " + band + ". Baan Dar favors the improbable."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Bosmer.RoutePressure") > 0
        text = text + " While the curse is on you, you stand outside the living world, and the path waits until it is lifted."
    endIf

    return text
EndFunction

String Function GetBosmerPathDisplayLabelAt(Int pathState)
    if pathState == Manager.BOSMER_PATH_OLD_CONTRACT
        return "Old Contract"
    elseIf pathState == Manager.BOSMER_PATH_LIVING_STORY
        return "Living Story"
    elseIf pathState == Manager.BOSMER_PATH_EXCHANGE
        return "Exchange"
    elseIf pathState == Manager.BOSMER_PATH_BANDIT_ROAD
        return "Bandit Road"
    endIf

    return "Unsettled"
EndFunction

String Function GetBosmerPathLabel()
    if Manager.PDV_BosmerPathTrack
        Int pathState = Manager.PDV_BosmerPathTrack.GetCurrentState()
        if pathState < Manager.BOSMER_PATH_OLD_CONTRACT || pathState > Manager.BOSMER_PATH_BANDIT_ROAD
            return "Unsettled"
        endIf
        return GetBosmerPathDisplayLabelAt(pathState)
    endIf

    return "Unsettled"
EndFunction

String Function GetBosmerComplianceBand()
    Int compliance = GetBosmerGreenPactCompliance()
    if compliance >= 80
        return "Strict"
    elseIf compliance >= 50
        return "Observant"
    elseIf compliance >= 20
        return "Lapsed"
    endIf
    return "Apostate"
EndFunction

String Function GetBosmerSummary()
    if !Manager.PDV_BosmerPathTrack
        return "missing"
    endIf

    return Manager.PDV_BosmerPathTrack.GetStateLabel() + ";offered=" + Manager.PDV_BosmerPathTrack.GetOfferedStateLabel() + ";pending=" + Manager.PDV_BosmerPathTrack.GetPendingStateLabel() + ";pact=" + PDV_DevotionRules.BoolToInt(IsBosmerPactBound()) + ";gpc=" + GetBosmerGreenPactCompliance() + ";lapsed=" + GetBosmerLapsedFromPact() + ";gp=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount") + ";penalty=" + StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive") + ";favor=" + GetBosmerFavorSummary()
EndFunction

String Function GetBosmerFavorSummary()
    return "oc=" + GetBosmerFavorCount("OldContract.ProperHunt") + "/" + GetBosmerFavorCount("OldContract.ForestKept") + ";ls=" + GetBosmerFavorCount("LivingStory.CommunityKept") + "/" + GetBosmerFavorCount("LivingStory.NatureSite") + ";ex=" + GetBosmerFavorCount("Exchange.DebtSettled") + "/" + GetBosmerFavorCount("Exchange.ProportionateVengeance") + ";br=" + GetBosmerFavorCount("BanditRoad.RoadLife") + "/" + GetBosmerFavorCount("BanditRoad.Reversal")
EndFunction

Int Function GetBosmerFavorCount(String favorKey)
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.Favor." + favorKey + ".Count")
EndFunction

Function HandleGreenPactViolation(String reason)
    if !IsBosmerOrigin()
        return
    endIf

    if !Manager.PDV_BosmerPathTrack
        Manager.Trace(1, "Green Pact violation skipped: Bosmer path missing.")
        return
    endIf

    if Manager.PDV_BosmerPathTrack.GetCurrentState() != Manager.BOSMER_PATH_OLD_CONTRACT
        Manager.Trace(2, "Green Pact violation ignored outside OldContract.")
        return
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Float windowStart = StorageUtil.GetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart")
    Int violationCount = StorageUtil.GetIntValue(None, "PDV.Bosmer.GreenPactViolationCount")
    if windowStart <= 0.0 || (nowTime - windowStart) > 2.0
        windowStart = nowTime
        violationCount = 0
    endIf

    violationCount += 1
    StorageUtil.SetFloatValue(None, "PDV.Bosmer.GreenPactWindowStart", windowStart)
    StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactViolationCount", violationCount)

    if violationCount >= 5
        StorageUtil.SetIntValue(None, "PDV.Bosmer.GreenPactPenaltyActive", 1)
    endIf

    AdjustBosmerGreenPactCompliance(-15, reason)
    if Manager.PDV_Yffre
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_PACT_VIOLATION, None)
        Manager.SendPrismaToast(Manager.GetPrismaSymbolForDeity(Manager.PDV_Yffre), "warning", "Green Pact broken", "You crossed Y'ffre's creed, and the path recoils.")
        Manager.SurfaceTransition("creed", "Green Pact", "drop", Manager.PDV_Yffre.DeityIndex, "absence", True)
    endIf

    Manager.Trace(2, "Green Pact violation count " + violationCount + " (" + reason + ")")
EndFunction

; ===========================================================================
; DISPATCH LAYER -- new code. Overrides of the base virtual surface; each one
; delegates to a lane verb above. Hand-review target per the ADR.
; ===========================================================================

Function ApplyInitialChoice(Int choiceValue, String reason)
    ApplyBosmerInitialChoice(choiceValue, reason)
EndFunction

Function EnsureRuntimeWiring()
    EnsureBosmerRuntimeWiring()
EndFunction

Function EvaluateAtDawn()
    EvaluateBosmerForcedReckoning()
EndFunction

String Function GetOriginStateLabel()
    return GetBosmerPathLabel()
EndFunction

Int Function GetOriginStateValue()
    return GetBosmerPathState()
EndFunction

String Function GetOriginSummary()
    return GetBosmerSummary()
EndFunction

String Function GetSurveyFragment()
    return GetBosmerSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsBosmerPathNeglected()
EndFunction

; SyncBosmerRewards takes the player ref the caller already held; the frozen virtual
; carries no argument, so the dispatch layer supplies it.
Function SyncRaceRewards()
    SyncBosmerRewards(Game.GetPlayer())
EndFunction

; Mirrors the live call site: SyncBosmerNeglectSpell(IsBosmerPathNeglected()).
Function SyncNeglectSpells()
    SyncBosmerNeglectSpell(IsBosmerPathNeglected())
EndFunction

; The caller composes `reason` (it is player-visible in the Ledger and several lane verbs
; branch on it), so it is threaded through UNCHANGED. Passing signalId into a reason slot
; would collapse every caller's context into one literal.
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "living-story"
        HandleBosmerLivingStorySignal(reason)
        return True
    elseIf signalId == "exchange"
        HandleBosmerExchangeSignal(reason)
        return True
    elseIf signalId == "bandit-road"
        HandleBosmerBanditRoadSignal(reason)
        return True
    elseIf signalId == "pact-positive"
        HandleBosmerPactPositiveSignal(reason)
        return True
    elseIf signalId == "old-contract-proper-hunt"
        HandleBosmerOldContractProperHunt(reason)
        return True
    elseIf signalId == "old-contract-forest-kept"
        HandleBosmerOldContractForestKept(reason)
        return True
    elseIf signalId == "living-story-community-kept"
        HandleBosmerLivingStoryCommunityKept(reason)
        return True
    elseIf signalId == "living-story-nature-site"
        HandleBosmerLivingStoryNatureSite(reason)
        return True
    elseIf signalId == "exchange-debt-settled"
        HandleBosmerExchangeDebtSettled(reason)
        return True
    elseIf signalId == "exchange-proportionate-vengeance"
        HandleBosmerExchangeProportionateVengeance(reason)
        return True
    elseIf signalId == "bandit-road-road-life"
        HandleBosmerBanditRoadRoadLife(reason)
        return True
    elseIf signalId == "bandit-road-reversal"
        HandleBosmerBanditRoadReversal(reason)
        return True
    elseIf signalId == "green-pact-violation"
        HandleGreenPactViolation(reason)
        return True
    elseIf signalId == "eldergleam-interior"
        TryBosmerEldergleamInterior()
        return True
    elseIf signalId == "gildergreen-proximity"
        TryBosmerGildergreenProximity()
        return True
    elseIf signalId == "yffre-tree-stone-proximity"
        TryBosmerYffreTreeStoneProximity()
        return True
    elseIf signalId == "arm-dream-on-path-change"
        ArmBosmerDreamOnPathChange()
        return True
    elseIf signalId == "forced-reckoning"
        EvaluateBosmerForcedReckoning()
        return True
    elseIf signalId == "path-suggestion"
        EvaluateBosmerPathSuggestion()
        return True
    elseIf signalId == "ensure-path-fallback"
        EnsureBosmerCurrentPathFallback()
        return True
    elseIf signalId == "initialize-storage"
        InitializeBosmerStorage()
        return True
    elseIf signalId == "sync-naming"
        SyncBosmerNaming(Game.GetPlayer())
        return True
    elseIf signalId == "remove-naming-spells"
        RemoveBosmerNamingSpells(Game.GetPlayer())
        return True
    elseIf signalId == "path-dream"
        TryBosmerPathDream(reason)
        return True
    elseIf signalId == "scales-at-rest"
        TryBosmerScalesAtRest(Game.GetPlayer())
        return True
    elseIf signalId == "baandar-gap"
        TryBosmerBaanDarGap(Game.GetPlayer())
        return True
    elseIf signalId == "confirm-pending-transition"
        ConfirmBosmerPendingTransition(reason)
        return True
    elseIf signalId == "sleep-events"
        HandleBosmerSleepEvents(Game.GetPlayer(), reason)
        return True
    elseIf signalId == "sleep-stop"
        ; base HandlePlayerSleepStop dispatched this by origin index.
        HandleBosmerSleepEvents(contextForm as Actor, reason)
        return True
    endIf

    return False
EndFunction

; The caller's akNewLocation rides through as a Form and is cast back to Location here.
; Deliberately NOT re-sampled via Game.GetPlayer().GetCurrentLocation(): the player can
; have moved on by the time the handler runs, and the lane keys per-location storage off
; exactly the location the event named.
Function HandleLocationChange(Form newLocation = None)
    HandleBosmerLocationChange(newLocation as Location)
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "path-label"
        return GetBosmerPathLabel()
    elseIf detailKey == "compliance-band"
        return GetBosmerComplianceBand()
    elseIf detailKey == "favor-summary"
        return GetBosmerFavorSummary()
    elseIf detailKey == "native-medallion-entries"
        return GetBosmerNativeMedallionEntriesJson()
    elseIf detailKey == "focus-medallion-entries"
        return GetBosmerFocusMedallionEntriesJson()
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "path-state"
        return GetBosmerPathState()
    elseIf detailKey == "path-evidence-days"
        return GetBosmerPathEvidenceDays()
    elseIf detailKey == "favor-signal-count"
        return GetBosmerFavorSignalCount()
    elseIf detailKey == "green-pact-compliance"
        return GetBosmerGreenPactCompliance()
    elseIf detailKey == "lapsed-from-pact"
        return GetBosmerLapsedFromPact()
    elseIf detailKey == "suggested-path-state"
        return GetSuggestedBosmerPathState()
    elseIf detailKey == "pact-bound"
        return BosmerFlagToInt(IsBosmerPactBound())
    elseIf detailKey == "setup-completed"
        return BosmerFlagToInt(HasBosmerSetupCompleted())
    elseIf detailKey == "terminal-renunciation"
        return BosmerFlagToInt(HasBosmerTerminalRenunciation())
    elseIf detailKey == "path-neglected"
        return BosmerFlagToInt(IsBosmerPathNeglected())
    endIf

    return 0
EndFunction

; -- dispatch-layer local helper (adapter-private; not a moved body) --
Int Function BosmerFlagToInt(Bool flagValue)
    if flagValue
        return 1
    endIf

    return 0
EndFunction
