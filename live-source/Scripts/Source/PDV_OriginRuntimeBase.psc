Scriptname PDV_OriginRuntimeBase extends PDV_GainModifierProvider

; Origin runtime, extracted from PDV__ManagerQuest for the 2.0 rebuild (ORIGIN
; module, tranche 1: Altmer + Bosmer origin lanes). Behavior parity: bodies are
; the manager originals; only bare manager-member references were qualified
; through the Manager backref (Manager.X), and the two write-shared manager
; script vars (_activeDeity, _suppressCurseTransitionOutputs) route through the
; existing Manager getters. Origin-owned script vars (used only by moved bodies)
; moved here verbatim and stay bare. INERT until the host QUST exists, Manager is
; filled, and CK wiring lands.

PDV__ManagerQuest Property Manager Auto

; --- Origin-owned script variables (moved verbatim; referenced only by moved bodies) ---
Int _altmerPracticeLinesValidatedVersion = -1
ObjectReference _bosGildergreenRef
ObjectReference _bosYffreTreeStoneRef

; --- Origin-owned script variables (tranche 2: Khajiit moon-observation state; moved verbatim; referenced only by moved bodies) ---
Int _khajiitMoonObservationsValidatedVersion = -1
String _khajiitMoonObservationsValidatedKey = ""
Bool _khajiitMoonObservationPending = False
Int _khajiitMoonObservationGeneration = 0
Float _khajiitMoonObservationStartRealTime = 0.0
Cell _khajiitMoonObservationCell = None
Float _khajiitMoonObservationX = 0.0
Float _khajiitMoonObservationY = 0.0
Float _khajiitMoonObservationZ = 0.0

; --- Origin-owned script variables (tranche 4: Dunmer home-prayer + Nord Kyne champion-entry queue state; moved verbatim; referenced only by moved bodies) ---
Bool _dunmerHomePrayerContext = False
Message _pendingNordKyneChampionMsg = None
String _pendingNordKyneChampionFallback = ""
Int _pendingNordKyneChampionDelayTicks = 0

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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return 0
EndFunction

Function RemoveAltmerDisciplineSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell disc = GetAltmerDisciplineSpell(i)
        if disc && playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetAltmerDisciplineSpell(Int index)
    if index == 0
        return Manager.PDV_SPEL_AltmerDiscipline_Alteration
    elseIf index == 1
        return Manager.PDV_SPEL_AltmerDiscipline_Destruction
    elseIf index == 2
        return Manager.PDV_SPEL_AltmerDiscipline_Illusion
    elseIf index == 3
        return Manager.PDV_SPEL_AltmerDiscipline_Restoration
    endIf
    return None
EndFunction

Function SyncAltmerDisciplines(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.Alt.Disc.Active")
    if active <= 0
        return
    endIf
    Spell disc = GetAltmerDisciplineSpell(active - 1)
    if !disc
        return
    endIf

    Bool eligible = IsAltmerOrigin() && IsAltmerDisciplineCoherent()
    if eligible
        if !playerRef.HasSpell(disc)
            playerRef.AddSpell(disc, False)
            Manager.SendPrismaToast("auriel", "good", "Coherence restored", "The discipline holds again.")
        endIf
    else
        if playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
            Manager.SendPrismaToast("auriel", "warning", "The discipline goes quiet", "You have wandered from coherence.")
        endIf
    endIf
EndFunction

Bool Function IsAltmerDisciplineCoherent()
    if IsAltmerFavorSuppressedByCurse()
        return false
    endIf
    Int crisis = GetAltmerCrisisState()
    if crisis == Manager.ALTMER_CRISIS_NONE || crisis == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return true
    endIf
    return false
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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

Function ArmBosmerDreamOnPathChange()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerBanditRoadSignal(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerOldContractForestKept(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerLivingStoryCommunityKept(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerLivingStoryNatureSite(String reason)
    if RecordBosmerFavorSignal("LivingStory.NatureSite", Manager.BOSMER_PATH_LIVING_STORY, reason)
        HandleBosmerLivingStorySignal(reason + "_nature_site")
    endIf
EndFunction

Function HandleBosmerExchangeDebtSettled(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerExchangeProportionateVengeance(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerBanditRoadRoadLife(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBosmerBanditRoadReversal(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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

Bool Function IsAltmerOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER
EndFunction

Bool Function IsAltmerFavorSuppressedByCurse()
    if !IsAltmerOrigin()
        return False
    endIf

    if Manager.PDV_CurseStateService && (Manager.PDV_CurseStateService.IsWerewolf() || Manager.PDV_CurseStateService.IsVampire())
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Curse.Altmer.ExilePressure") == 1
EndFunction

Function HandleAltmerLorkhanPressure(Int pressureTier, String sourceId)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Float Function GetAltmerLorkhanPietyPenalty(Int pressureTier)
    if pressureTier == Manager.ALTMER_LORKHAN_PRESSURE_DIRECT
        return 10.0
    elseIf pressureTier == Manager.ALTMER_LORKHAN_PRESSURE_SHOR_ADJACENT
        return 7.0
    elseIf pressureTier == Manager.ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION
        return 5.0
    elseIf pressureTier == Manager.ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
        return 2.0
    endIf
    return 0.0
EndFunction

Float Function GetAltmerLorkhanFactionModifier()
    if !Manager.PDV_ThalmorAlignmentTrack
        return 1.0
    endIf

    Int alignment = Manager.PDV_ThalmorAlignmentTrack.GetValue()
    if alignment <= -76
        return 0.75
    elseIf alignment <= -51
        return 0.875
    elseIf alignment >= 76
        return 1.5
    elseIf alignment >= 51
        return 1.25
    endIf

    return 1.0
EndFunction

Function ApplyAltmerAlignmentAction(String actionKey, String reason)
    if !IsAltmerOrigin()
        return
    endIf
    if !Manager.PDV_ThalmorAlignmentTrack
        Manager.Trace(1, "ApplyAltmerAlignmentAction skipped: track missing.")
        return
    endIf

    Int adjustment = GetAltmerThalmorPointsForAction(actionKey)
    if adjustment == 0
        Manager.Trace(1, "ApplyAltmerAlignmentAction skipped: unknown action " + actionKey)
        return
    endIf

    String oldBand = GetAltmerCommittedAlignmentJournalBand()
    Manager.PDV_ThalmorAlignmentTrack.Adjust(adjustment, reason)
    MaybeSurfaceAltmerAlignmentBandChange(oldBand, "alignment_" + actionKey)
    Manager.Trace(2, "Altmer ThalmorAlignment " + actionKey + " " + adjustment + " -> " + Manager.PDV_ThalmorAlignmentTrack.GetValue())
EndFunction

Function MaybeSurfaceAltmerAlignmentBandChange(String oldBand, String reason)
    if !IsAltmerOrigin() || !Manager.PDV_ThalmorAlignmentTrack
        return
    endIf

    String newBand = GetAltmerCommittedAlignmentJournalBand()
    if oldBand == "" || newBand == "" || oldBand == newBand
        StorageUtil.SetStringValue(None, "PDV.Altmer.Alignment.LastCommittedBand", newBand)
        return
    endIf

    Manager.SendPrismaShiftToast("The Thalmor question turns in you: " + newBand + ".", "", "auri-el")
    Manager.SurfaceTransition("reorientation", newBand, "shift", -1, "turning", True, False)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Alignment.LastCommittedBand", newBand)
    Manager.Trace(1, "Altmer committed alignment band " + oldBand + " -> " + newBand + " (" + reason + ")")
EndFunction

String Function GetAltmerCommittedAlignmentJournalBand()
    if !Manager.PDV_ThalmorAlignmentTrack
        return ""
    endIf

    String label = Manager.PDV_ThalmorAlignmentTrack.GetStateLabelAt(Manager.PDV_ThalmorAlignmentTrack.GetCommittedStateIndex())
    if label == "OpenHeterodox"
        return "Open Heterodoxy"
    elseIf label == "PrivateHeterodox"
        return "Private Heterodoxy"
    elseIf label == "PublicOrthodox"
        return "Public Orthodoxy"
    elseIf label == "ThalmorEnforcer"
        return "Thalmor-Devout"
    endIf
    return "Uncommitted"
EndFunction

Int Function GetAltmerThalmorPointsForAction(String actionKey)
    if actionKey == "orthodox_rite"
        return 2
    elseIf actionKey == "help_thalmor_prisoner_escape"
        return -15
    elseIf actionKey == "kill_thalmor_agent"
        return -20
    elseIf actionKey == "read_banned_texts"
        return -5
    elseIf actionKey == "consort_with_daedra"
        return -25
    endIf

    return 0
EndFunction

Function HandleAltmerAlignmentSignal(String actionKey, Form sourceForm, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerCrisisSource(Int crisisSource, String sourceId)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ResolveAltmerCrisis(Bool reassertOrthodoxy, String reason)
    if !IsAltmerOrigin()
        return
    endIf

    if reassertOrthodoxy
        SetAltmerCrisisState(Manager.ALTMER_CRISIS_REASSERTING, reason)
    else
        SetAltmerCrisisState(Manager.ALTMER_CRISIS_SCARRED_RESOLVED, reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisResolvedAt", Utility.GetCurrentGameTime())

    ; P3 (2026-08-03): the first shipped organic source for Auri-El's
    ; SIGNAL_ORTHODOXY_AFFIRMATION. Holding the line through a crisis of faith and reasserting
    ; the orthodoxy IS the costly orthodox act that signal was authored for.
    ;
    ; ORDER IS LOAD-BEARING -- this call MUST stay BELOW the SetAltmerCrisisState above.
    ; HandleAltmerOrthodoxCostlyEnforcement calls RecordAltmerCrisisReassertEvidence, which on its
    ; third evidence day calls ResolveAltmerCrisis again. That recursion terminates ONLY because
    ; the state is already REASSERTING by the time it re-enters, so the DISSONANT/QUESTIONING
    ; guard rejects it immediately. Move this above the state set and it loops.
    ;
    ; The handler is curse- and origin-gated internally, and its SurfaceP2BookReadNotice call
    ; no-ops here because IsP2BookNoticeReason requires a "po3_book" token this reason lacks.
    if reassertOrthodoxy
        HandleAltmerOrthodoxCostlyEnforcement("crisis_reasserted_" + reason)
        ; P7 (2026-08-03): Trinimac's second 2301 source. Reasserting orthodoxy through a crisis is
        ; his beat as much as Auri-El's. Separate key from the book route's
        ; ConsumeDailyRepeatMultiplier, so both can land on the same day -- intended: a crisis
        ; resolution is a rare, heavy moment.
        if Manager.PDV_Trinimac && Manager.ConsumeOncePerDaySignal("PDV.Signal.TrinimacCrisisOrthodoxy")
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Trinimac, Manager.PDV_Trinimac.SIGNAL_FALLEN_GOD_ORTHODOXY, None, 2.0)
        endIf
    endIf
EndFunction

Bool Function RecordAltmerCrisisReassertEvidence(String reason)
    Int crisisState = GetAltmerCrisisState()
    if crisisState != Manager.ALTMER_CRISIS_DISSONANT && crisisState != Manager.ALTMER_CRISIS_QUESTIONING
        return False
    endIf

    ; fix-plan 4.2: one evidence day per DEVOTIONAL day -- the crisis resolves on a
    ; three-day count that dawn processing reads, so it must share dawn's boundary.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Altmer.CrisisEvidence.Day") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return False
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Altmer.CrisisEvidence.Day")

    Int evidenceDays = StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisEvidence.Days") + 1
    StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisEvidence.Days", evidenceDays)
    Manager.Trace(1, "Altmer crisis reassert evidence day " + evidenceDays + " (" + reason + ")")

    if evidenceDays >= 3
        StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisEvidence.Days", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisEvidence.Day", 0)
        ResolveAltmerCrisis(true, "orthodoxy_reasserted_" + reason)
        return True
    endIf
    return False
EndFunction

Function EvaluateAltmerCrisisAtDawn()
    if !IsAltmerOrigin()
        return
    endIf

    Int crisisState = GetAltmerCrisisState()
    Float nowTime = Utility.GetCurrentGameTime()

    ; P6 (2026-08-03): let a settled scar re-open the arc after ALTMER_CRISIS_REENTRY_DAYS.
    ; This is the ONLY caller of SetAltmerCrisisState(ALTMER_CRISIS_NONE, ...) in the codebase;
    ; without it the first resolved crisis permanently disarmed Lorkhan pressure.
    ;
    ; Deliberately NOT cleared here: PDV.Altmer.CrisisSeen.<source> (so re-entry needs a
    ; DIFFERENT authored source -- the arc cannot loop on one beat) and
    ; PDV.Altmer.VampireExileScar (a curse scar is not a crisis scar and does not heal on a timer).
    ;
    ; Setting NONE is intentionally silent: SetAltmerCrisisState only surfaces a toast and
    ; Book of Days entry when the new state is non-NONE, which is right -- a scar settling is
    ; the absence of pressure, not an event to announce.
    if crisisState == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        Float settledAt = StorageUtil.GetFloatValue(None, "PDV.Altmer.CrisisSettledAt")
        if settledAt <= 0.0
            ; Migration: a save that scarred before P6 has no stamp. Start its clock now rather
            ; than re-opening instantly on the first dawn after the update.
            StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisSettledAt", nowTime)
        elseIf (nowTime - settledAt) >= Manager.ALTMER_CRISIS_REENTRY_DAYS
            SetAltmerCrisisState(Manager.ALTMER_CRISIS_NONE, "scar_settled")
            SyncAltmerDisciplines(Game.GetPlayer())
        endIf
        return
    endIf

    if crisisState == Manager.ALTMER_CRISIS_REASSERTING
        Float resolvedAt = StorageUtil.GetFloatValue(None, "PDV.Altmer.CrisisResolvedAt")
        if resolvedAt > 0.0 && (nowTime - resolvedAt) >= 2.0
            SetAltmerCrisisState(Manager.ALTMER_CRISIS_SCARRED_RESOLVED, "reassert_lockout_complete")
            SyncAltmerDisciplines(Game.GetPlayer())
        endIf
        return
    endIf

    if crisisState != Manager.ALTMER_CRISIS_DISSONANT && crisisState != Manager.ALTMER_CRISIS_QUESTIONING
        return
    endIf

    Float startedAt = StorageUtil.GetFloatValue(None, "PDV.Altmer.CrisisStartedAt")
    if startedAt <= 0.0 || (nowTime - startedAt) < 7.0
        return
    endIf

    Int alignmentValue = 0
    if Manager.PDV_ThalmorAlignmentTrack
        alignmentValue = Manager.PDV_ThalmorAlignmentTrack.GetValue()
    endIf
    if alignmentValue < 0
        ResolveAltmerCrisis(false, "lived_through_heterodox")
        SyncAltmerDisciplines(Game.GetPlayer())
    endIf
EndFunction

Function AwardActiveAltmerHeritageMemorySignal()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER || Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return
    endIf

    ; fix-plan 4.2: the doc-comment above already calls this "once per dawn cycle" --
    ; it now actually uses the dawn day rather than raw midnight.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Signal.AltmerHeritageMemory.Day") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Signal.AltmerHeritageMemory.Day")

    if Manager.GetActiveDeity() == Manager.PDV_Magnus && Manager.PDV_Magnus
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Magnus, Manager.PDV_Magnus.SIGNAL_SHARED_PACT_MEMORY, None, 1.0)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Xarxes && Manager.PDV_Xarxes
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Xarxes, Manager.PDV_Xarxes.SIGNAL_SHARED_PACT_MEMORY, None, 1.0)
    endIf
EndFunction

Function HandleAltmerDawnSteadiness(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerOrthodoxCostlyEnforcement(String reason)
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        RecordAltmerRejectedSurface(reason, "curse_suppressed_altmer_favor")
        Manager.FavorRuntime.ClearActiveFavor("altmer_curse")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerOrthodoxCostlyEnforcement")

    RecordAltmerSourceFavor(Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    Manager.FavorRuntime.TryActivateContextualFavor(Manager.FavorRuntime.FAVOR_LANE_ALTMER, Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_ORTHODOX_COST, reason)
    if multiplier > 0.0
        AwardAltmerOrthodoxSignal(reason, multiplier)
        AwardAltmerAncestorSpinePulse(multiplier, reason)
    endIf
    if Manager.PDV_Trinimac && Manager.ConsumeOncePerDaySignal("PDV.Signal.TrinimacOrthodoxPressure")
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Trinimac, Manager.PDV_Trinimac.SIGNAL_ALTMER_ORTHODOX_PRESSURE, None, 1.0)
        if !Manager.IsP2BookNoticeReason(reason)
            Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Trinimac, "Orthodoxy upheld", "marks a costly defense of ancestral doctrine.")
        endIf
    endIf
    if Manager.ConsumeOncePerDaySignal("PDV.Signal.AltmerAlignmentRite")
        ApplyAltmerAlignmentAction("orthodox_rite", "rite_" + reason)
    endIf
    Bool crisisTransitioned = RecordAltmerCrisisReassertEvidence("orthodox_cost_" + reason)
    if !crisisTransitioned
        Manager.SurfaceP2BookReadNotice(reason, "The scribe Xarxes", "The ancestral record asks more of you.")
    endIf
EndFunction

Function HandleAltmerTrinimacOrthodoxy(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerTrinimacCivilizationDefense(String reason)
    if !IsAltmerOrigin() || !Manager.PDV_Trinimac || !Manager.PDV_ThalmorAlignmentTrack
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        return
    endIf

    if Manager.PDV_ThalmorAlignmentTrack.GetValue() < 70
        return
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.TrinimacCivilizationDefended")
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Trinimac, Manager.PDV_Trinimac.SIGNAL_CIVILIZATION_DEFENDED, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Trinimac, "The project defended", "marks the ordered world held against a threat.")
EndFunction

Int Function HandleAltmerPracticeFocus(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function GetAltmerPracticeIdleKind()
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE || !Manager.GetActiveDeity()
        return 0
    endIf
    if Manager.GetActiveDeity() == Manager.PDV_Magnus || Manager.GetActiveDeity() == Manager.PDV_Xarxes || Manager.GetActiveDeity() == Manager.PDV_Syrabane
        return 1
    endIf
    return 0
EndFunction

Function EnsureAltmerPracticeFocus()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER || !Manager.PDV_MISC_AltmerPracticeFocus
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(Manager.PDV_MISC_AltmerPracticeFocus) <= 0
        playerRef.AddItem(Manager.PDV_MISC_AltmerPracticeFocus, 1, True)
        Manager.Trace(2, "Altmer practice focus granted.")

        ; ONCE EVER, on a one-shot key rather than on the grant itself. This function re-grants the
        ; calian whenever the player does not have one, so hanging the line off AddItem would say
        ; "you have carried this since you were eighteen" about a replacement acquired a minute ago
        ; if the player ever dropped or sold it.
        ;
        ; Written as a Book of Days entry, not a notification, and allowed during race-setup quiet:
        ; the grant happens at init, when presentation is suppressed, so a notification would either
        ; be swallowed or would have to shout over the setup flow. This is backstory being entered
        ; in the chronicle, which is what the Book of Days is for.
        if StorageUtil.GetIntValue(None, "PDV.Altmer.Calian.Granted") != 1
            StorageUtil.SetIntValue(None, "PDV.Altmer.Calian.Granted", 1)
            ; The second sentence is the ONLY discoverability nudge the calian gets. It is a MISC
            ; item with no quest, no marker and no tutorial, so without a line telling the player it
            ; is theirs to use, the mod's one unlimited daily Altmer act is a thing that sits in the
            ; inventory forever. Phrased as the practice, not as a control prompt.
            Manager.AppendBookOfDaysEntry("You have carried this since you were eighteen. A sphere of aetherquartz, given in a chapel by a Curate, and still unbroken. Hold it in your hands when you would remember what you are.", Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 1, "Your calian", True)
        endIf
    endIf
EndFunction

Function HandleAltmerSyrabaneCureWard(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerSyrabaneProtectiveWard(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerSyrabaneAntiMageSurvival(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleAltmerSyrabaneContainment(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function AwardAltmerDawnSignal(String reason, Float multiplier)
    if PDV_DevotionRules.StringContainsToken(reason, "magnus") && Manager.PDV_Magnus
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Magnus, Manager.PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None, multiplier)
        return
    endIf

    if Manager.PDV_AuriEl
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_AuriEl, Manager.PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None, multiplier)
    endIf
EndFunction

Function AwardAltmerOrthodoxSignal(String reason, Float multiplier)
    if PDV_DevotionRules.StringContainsToken(reason, "xarxes") && Manager.PDV_Xarxes
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Xarxes, Manager.PDV_Xarxes.SIGNAL_LINEAGE_HONORED, None, multiplier)
        return
    endIf

    ; Hard daily cap. This lane carried only the 0.7^n repeat-decay multiplier and no ceiling, so
    ; a delta-3.0 signal could pay out repeatedly within one day as soon as a source existed.
    if Manager.PDV_AuriEl && Manager.ConsumeOncePerDaySignal("PDV.Signal.AuriElOrthodoxyAffirmation")
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_AuriEl, Manager.PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION, None, multiplier)
    endIf
EndFunction

Function HandleAltmerMagicSkillIncrease(String skillName)
    if !IsAltmerOrigin() || !Manager.PDV_Magnus || !IsAltmerMagicMilestoneSkill(skillName)
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Float skillValue = playerRef.GetActorValue(skillName)
    Int awardedCount = 0

    ; Every real increase in one of the six magic skills may claim today's
    ; substrate credit; milestone piety remains a separate finite signal.
    ; Enchanting is excluded: it only levels inside the enchanter menu, where
    ; this mid-menu pulse's toast is lost and it consumes today's daily credit
    ; before the post-menu enchant-item event (331) can surface the act-specific
    ; substrate toast. Let event 331 own the enchant credit; this pulse still
    ; covers the other five magic skills.
    if skillName != "Enchanting"
        AwardAltmerAncestorSpinePulse(1.0, "magic_skill_increase_" + skillName)
    endIf

    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 25)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 50)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 75)
    awardedCount += TryAwardAltmerMagicMilestone(skillName, skillValue, 100)

    if awardedCount > 0
        StorageUtil.SetStringValue(None, "PDV.Altmer.LastMagicMilestoneSkill", skillName)
        StorageUtil.SetIntValue(None, "PDV.Altmer.LastMagicMilestoneCount", awardedCount)
        StorageUtil.SetFloatValue(None, "PDV.Altmer.LastMagicMilestoneTime", Utility.GetCurrentGameTime())
        Manager.Trace(2, "Altmer magic milestone routed: " + skillName + " x" + awardedCount)
    endIf
EndFunction

Function AwardAltmerAncestorSpinePulse(Float multiplier, String reason)
    if !IsAltmerOrigin() || multiplier <= 0.0 || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    ; TOAST PARITY (owner ruling 2026-08-06). The Book of Days line is resolved FIRST and handed to
    ; SendPrismaSubstrateProgress as its context, so the toast carries the same sentence the
    ; chronicle records. This ordering matters for the calian: its line is drawn at random from a
    ; pool, so resolving it twice would let the toast and the Book entry name different lines for
    ; one act.
    Int tierBefore = 0
    Int tierAfter = 0
    Float grantedMetric = 0.0
    if Manager.PDV_AltmerAncestorSubstrate
        Float metricBefore = Manager.PDV_AltmerAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_AltmerAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_AltmerAncestorSubstrate.RecordHeritageStandingScaled(multiplier, reason)
        tierAfter = Manager.PDV_AltmerAncestorSubstrate.GetSubstrateTier()
        grantedMetric = Manager.PDV_AltmerAncestorSubstrate.GetMetric() - metricBefore
    endIf

    String voicedLine = AppendAltmerHeritageVoice(grantedMetric, reason)
    if Manager.PDV_AltmerAncestorSubstrate
        Manager.SendPrismaSubstrateProgress("altmer-heritage", tierBefore, tierAfter, grantedMetric, voicedLine, "auri-el", GetAltmerHeritageTierName())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Altmer.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Altmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Altmer ancestor spine routed with multiplier " + multiplier)

EndFunction

Int Function PickAltmerPracticeIndex()
    if !IsAltmerPracticeLineJsonValid()
        return -1
    endIf

    String lastId = StorageUtil.GetStringValue(None, "PDV.Altmer.PracticeLine.LastId")
    Int excludedIndex = -1
    Int i = 0
    while i < Manager.ALTMER_PRACTICE_LINES_COUNT && excludedIndex < 0
        if JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, ".lines[" + i + "].id", "") == lastId
            excludedIndex = i
        endIf
        i += 1
    endWhile

    ; Roll across the whole pool, or across one fewer slot and step over the excluded index, so the
    ; repeat is skipped without biasing any other line's odds.
    Int poolIndex = Utility.RandomInt(0, Manager.ALTMER_PRACTICE_LINES_COUNT - 1)
    if excludedIndex >= 0
        poolIndex = Utility.RandomInt(0, Manager.ALTMER_PRACTICE_LINES_COUNT - 2)
        if poolIndex >= excludedIndex
            poolIndex += 1
        endIf
    endIf

    StorageUtil.SetStringValue(None, "PDV.Altmer.PracticeLine.LastId", JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, ".lines[" + poolIndex + "].id", ""))
    return poolIndex
EndFunction

Bool Function IsAltmerPracticeLineJsonValid()
    ; Load/IsGood run every call -- see _altmerPracticeLinesValidatedVersion for why they are not cached.
    if !JsonUtil.Load(Manager.ALTMER_PRACTICE_LINES_FILE) || !JsonUtil.IsGood(Manager.ALTMER_PRACTICE_LINES_FILE)
        _altmerPracticeLinesValidatedVersion = -1
        return False
    endIf
    if _altmerPracticeLinesValidatedVersion == Manager.ALTMER_PRACTICE_LINES_VERSION
        return True
    endIf
    if JsonUtil.GetPathIntValue(Manager.ALTMER_PRACTICE_LINES_FILE, ".version", -1) != Manager.ALTMER_PRACTICE_LINES_VERSION
        return False
    endIf
    if JsonUtil.PathCount(Manager.ALTMER_PRACTICE_LINES_FILE, ".lines") != Manager.ALTMER_PRACTICE_LINES_COUNT
        return False
    endIf

    Int poolIndex = 0
    while poolIndex < Manager.ALTMER_PRACTICE_LINES_COUNT
        String entryPath = ".lines[" + poolIndex + "]"
        if JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, entryPath + ".id", "") == "" || JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, entryPath + ".title", "") == "" || JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, entryPath + ".body", "") == ""
            return False
        endIf
        poolIndex += 1
    endWhile
    _altmerPracticeLinesValidatedVersion = Manager.ALTMER_PRACTICE_LINES_VERSION
    return True
EndFunction

String Function AppendAltmerHeritageVoice(Float grantedMetric, String reason)
    if grantedMetric <= 0.0
        return ""
    endIf
    ; The calian owns its own entry because each pooled line carries its OWN title, the way the
    ; Khajiit moon observations do. Every other spine source shares the one "Ancestral practice"
    ; heading below.
    if PDV_DevotionRules.StringContainsToken(reason, "practice_focus")
        return AppendAltmerPracticeEntry()
    endIf
    String sourceLine = GetAltmerHeritageSourceLine(reason)
    Manager.AppendBookOfDaysEntry(sourceLine, Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 1, "Ancestral practice")
    return sourceLine
EndFunction

String Function AppendAltmerPracticeEntry()
    Int poolIndex = PickAltmerPracticeIndex()
    if poolIndex < 0
        String fallbackLine = "You kept the practice where you stood, with no shrine and no witness."
        Manager.AppendBookOfDaysEntry(fallbackLine, Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 1, "Ancestral practice")
        return fallbackLine
    endIf

    String entryPath = ".lines[" + poolIndex + "]"
    String bodyText = JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, entryPath + ".body", "")
    String titleText = JsonUtil.GetPathStringValue(Manager.ALTMER_PRACTICE_LINES_FILE, entryPath + ".title", "")
    if bodyText == ""
        bodyText = "You kept the practice where you stood, with no shrine and no witness."
    endIf
    if titleText == ""
        titleText = "Ancestral practice"
    endIf
    Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 1, titleText)
    return bodyText
EndFunction

String Function GetAltmerHeritageSourceLine(String reason)
    if PDV_DevotionRules.StringContainsToken(reason, "dawn_observance")
        return "You met the dawn under the open sky. The ordered life asks no more than this."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "auriel_shrine_rite")
        return "You performed the dawn rite as your ancestors have always done."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "sleep_dream")
        return "You awoke from a dream about the Aldmeri. It leaves an ache within you as you recall the past."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "enchantment")
        return "You bound magicka into a lasting shape. The binding holds."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "smithing")
        return "You worked the forge in the manner set down. The craft is older than you."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "study")
        return "You studied. The quest for knowledge is ingrained in your heritage."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "magic_skill_increase")
        return "You have deepened your magical skills. You are closer to perfection."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "curated_heritage")
        return "You read an ancestral text closely. What was written is remembered."
    endIf

    ; NOTE on "practice_focus" (P14's focus token composes "practice_focus_" + the EventBus reason,
    ; so it matches none of the arms above): it must NEVER fall to the orthodoxy default below, which
    ; asserts the opposite of a Psijic or Heterodox player's theology. It does not, because
    ; AppendAltmerHeritageVoice intercepts that token first and delegates to AppendAltmerPracticeEntry,
    ; which draws an alignment-neutral pooled line. An arm here was a SECOND draw site from that pool
    ; with its own LastId write; removed 2026-08-07 because reaching it would reintroduce the
    ; toast/Book divergence the single-pick design exists to prevent. If you ever make this function
    ; reachable for that token, route it back through AppendAltmerPracticeEntry -- not a new draw.
    return "You upheld the orthodoxy at real cost. Doctrine stands on what it costs you."
EndFunction

Function RunDawnRefreshAltmerAncestor()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function TryAwardAltmerMagicMilestone(String skillName, Float skillValue, Int threshold)
    if skillValue < (threshold as Float)
        return 0
    endIf

    String milestoneKey = "PDV.Altmer.MagicMilestone." + skillName + "." + threshold
    if StorageUtil.GetIntValue(None, milestoneKey) == 1
        return 0
    endIf

    StorageUtil.SetIntValue(None, milestoneKey, 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.LastMagicMilestoneThreshold", threshold)
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Magnus, Manager.PDV_Magnus.SIGNAL_MAGIC_MILESTONE, None, 4.0)
    return 1
EndFunction

Bool Function IsAltmerMagicMilestoneSkill(String skillName)
    return skillName == "Alteration" || skillName == "Conjuration" || skillName == "Destruction" || skillName == "Enchanting" || skillName == "Illusion" || skillName == "Restoration"
EndFunction

Function RecordAltmerSourceFavor(Int familyValue, String reason)
    if !IsValidAltmerSourceFavorFamily(familyValue)
        RecordAltmerRejectedSurface(reason, "unknown_altmer_favor_family")
        return
    endIf

    String countKey = "PDV.Altmer.Favor." + GetAltmerFavorFamilyKey(familyValue) + ".Count"
    StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.Favor.LastFamily", familyValue)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Favor.LastReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Altmer.Favor.LastSurfacing", Manager.FavorRuntime.GetFavorSurfacingLabel(Manager.FavorRuntime.FAVOR_LANE_ALTMER, familyValue))
    StorageUtil.SetFloatValue(None, "PDV.Altmer.Favor.LastGameTime", Utility.GetCurrentGameTime())

    Manager.Trace(2, "Altmer source favor recorded: " + Manager.FavorRuntime.GetContextualFavorFamilyLabel(Manager.FavorRuntime.FAVOR_LANE_ALTMER, familyValue) + " (" + reason + ")")
EndFunction

Bool Function IsValidAltmerSourceFavorFamily(Int familyValue)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return False
EndFunction

String Function GetAltmerFavorFamilyKey(Int familyValue)
    if familyValue == Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_DAWN_STEADINESS
        return "DawnSteadiness"
    elseIf familyValue == Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_ORTHODOX_COST
        return "OrthodoxCost"
    endIf

    return "Unknown"
EndFunction

Bool Function IsAltmerRejectedLorkhanSurface(String sourceId)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RecordAltmerRejectedSurface(String sourceId, String reason)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastRejectedSurface", sourceId)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastRejectedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastRejectedAt", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(None, "PDV.Altmer.RejectedSurfaceCount", StorageUtil.GetIntValue(None, "PDV.Altmer.RejectedSurfaceCount") + 1)
EndFunction

Int Function GetAltmerCrisisState()
    if Manager.PDV_AltmerCrisisTrack
        return Manager.PDV_AltmerCrisisTrack.GetCurrentState()
    endIf

    Int stateValue = StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisState")
    if stateValue < Manager.ALTMER_CRISIS_NONE || stateValue > Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return Manager.ALTMER_CRISIS_NONE
    endIf

    return stateValue
EndFunction

Function SetAltmerCrisisState(Int stateValue, String reason)
    if stateValue < Manager.ALTMER_CRISIS_NONE
        stateValue = Manager.ALTMER_CRISIS_NONE
    elseIf stateValue > Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        stateValue = Manager.ALTMER_CRISIS_SCARRED_RESOLVED
    endIf

    Int oldState = GetAltmerCrisisState()
    StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisState", stateValue)
    StorageUtil.SetStringValue(None, "PDV.Altmer.CrisisReason", reason)
    if Manager.PDV_AltmerCrisisTrack && Manager.PDV_AltmerCrisisTrack.GetCurrentState() != stateValue
        Manager.PDV_AltmerCrisisTrack.SetState(stateValue, reason)
    endIf
    if oldState != stateValue
        Manager.Trace(1, "Altmer crisis state " + GetAltmerCrisisStateLabelForValue(oldState) + " -> " + GetAltmerCrisisStateLabelForValue(stateValue) + " (" + reason + ")")
        ; P6: stamp when the scar actually forms. This is the single funnel for every state
        ; change, so it catches BOTH exit paths. Deliberately not reusing
        ; PDV.Altmer.CrisisResolvedAt: that field means different things on the two paths --
        ; on the reassert path it marks REASSERTING entry (SCARRED_RESOLVED lands two days
        ; later and never restamps it), on the lived-through path it marks the settle itself.
        ; The re-entry clock needs one unambiguous meaning.
        if stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
            StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisSettledAt", Utility.GetCurrentGameTime())
        endIf
        if stateValue != Manager.ALTMER_CRISIS_NONE
            String crisisHeadline = GetAltmerCrisisHeadline(stateValue)
            String crisisLine = GetAltmerCrisisJournalLine(stateValue)
            String crisisTone = GetAltmerCrisisJournalTone(stateValue)
            Manager.SendPrismaShiftToast(crisisHeadline, crisisLine, "auri-el")
            Manager.AppendBookOfDaysEntry(crisisLine, Utility.GetCurrentGameTime() as Int, crisisTone, "auri-el", True, 3, crisisHeadline)
            Manager.RequestPanelRefresh()
        endIf
    endIf
EndFunction

String Function GetAltmerCrisisHeadline(Int stateValue)
    if stateValue == Manager.ALTMER_CRISIS_DISSONANT
        return "Auri-El's path is shaken"
    elseIf stateValue == Manager.ALTMER_CRISIS_QUESTIONING
        return "A question takes root"
    elseIf stateValue == Manager.ALTMER_CRISIS_REASSERTING
        return "You return to Auri-El's path"
    elseIf stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return "Auri-El's path holds"
    endIf

    return "A turning"
EndFunction

String Function GetAltmerCrisisJournalLine(Int stateValue)
    Int crisisSource = StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisSource")
    if stateValue == Manager.ALTMER_CRISIS_DISSONANT
        if crisisSource == Manager.ALTMER_CRISIS_SOURCE_DRAGONBORN
            return "The Dragonborn's claim unsettles your place on Auri-El's path."
        elseIf crisisSource == Manager.ALTMER_CRISIS_SOURCE_SOVNGARDE
            return "What you witnessed in Sovngarde unsettles Auri-El's path."
        endIf
        return "Auri-El's path no longer sits easily within you."
    elseIf stateValue == Manager.ALTMER_CRISIS_QUESTIONING
        if crisisSource == Manager.ALTMER_CRISIS_SOURCE_TALOS
            return "Talos's claim has opened a question Auri-El's path cannot ignore."
        elseIf crisisSource == Manager.ALTMER_CRISIS_SOURCE_COMPANIONS
            return "The Companions' claim has opened a question Auri-El's path cannot ignore."
        endIf
        return "A question has opened between you and Auri-El's path."
    elseIf stateValue == Manager.ALTMER_CRISIS_REASSERTING
        return "Three days of disciplined practice steady you on Auri-El's path."
    elseIf stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return "The crisis has settled. Its scar remains, but you keep Auri-El's path."
    endIf

    return "Auri-El's path turns within you."
EndFunction

String Function GetAltmerCrisisJournalTone(Int stateValue)
    if stateValue == Manager.ALTMER_CRISIS_REASSERTING || stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return "crisis.resolve"
    endIf
    return "crisis.onset"
EndFunction

String Function GetAltmerCrisisStateLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetAltmerCrisisStateLabelForValue(Int stateValue)
    if stateValue == Manager.ALTMER_CRISIS_DISSONANT
        return "Dissonant"
    elseIf stateValue == Manager.ALTMER_CRISIS_QUESTIONING
        return "Questioning"
    elseIf stateValue == Manager.ALTMER_CRISIS_REASSERTING
        return "Reasserting"
    elseIf stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return "Scarred resolved"
    endIf

    return "None"
EndFunction

String Function GetAltmerCrisisSourceLabel(Int sourceValue)
    if sourceValue == Manager.ALTMER_CRISIS_SOURCE_DRAGONBORN
        return "Dragonborn identity"
    elseIf sourceValue == Manager.ALTMER_CRISIS_SOURCE_SOVNGARDE
        return "Sovngarde witness"
    elseIf sourceValue == Manager.ALTMER_CRISIS_SOURCE_TALOS
        return "Talos contradiction"
    elseIf sourceValue == Manager.ALTMER_CRISIS_SOURCE_COMPANIONS
        return "Companions contradiction"
    endIf

    return "Unknown"
EndFunction

String Function GetAltmerSummary()
    return "crisis=" + GetAltmerCrisisStateLabel() + ";source=" + GetAltmerCrisisSourceLabel(StorageUtil.GetIntValue(None, "PDV.Altmer.CrisisSource")) + ";pressure=" + StorageUtil.GetIntValue(None, "PDV.Altmer.LorkhanPressureCount") + ";favor=" + Manager.FavorRuntime.GetContextualFavorFamilyLabel(Manager.FavorRuntime.FAVOR_LANE_ALTMER, StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.LastFamily")) + ";rejected=" + StorageUtil.GetIntValue(None, "PDV.Altmer.RejectedSurfaceCount") + ";curse=" + GetAltmerCurseSummary()
EndFunction

Function RunDawnAltmerHeritageAmbient()
    if !IsAltmerOrigin() || !Manager.PDV_AltmerAncestorSubstrate || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    String highKey = "PDV.Ambient.Heritage.WasHigh"
    if Manager.PDV_AltmerAncestorSubstrate.GetSubstrateTier() >= Manager.LedgerRuntime.TIER_CHAMPION
        StorageUtil.SetIntValue(None, highKey, 1)

        String cadenceKey = "PDV.Ambient.Heritage.Day"
        Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
        Int lastStamp = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp(cadenceKey)
        if lastStamp > 0 && (todayStamp - lastStamp) < Manager.AMBIENT_CHAMPION_CADENCE_DAYS
            return
        endIf

        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(cadenceKey)
        ShowAltmerNotification(Manager.PDV_Notif_Altmer_General_HeritageExemplar, "You keep the old Altmer way, and you keep it well.")
    elseIf StorageUtil.GetIntValue(None, highKey) == 1
        StorageUtil.SetIntValue(None, highKey, 0)
        ShowAltmerNotification(Manager.PDV_Notif_Altmer_General_HeritageQuiet, "You have let the old Altmer way slip.")
    endIf
EndFunction

Function RunDawnAwardAltmerAuriElDawn()
    if !IsAltmerOrigin() || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    Int dawnDayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Altmer.AuriElDawn.LastDay") == dawnDayStamp
        return
    endIf

    ; THE ACT GATE. The player must actually meet the dawn: outdoors, under the sky, at the turn of
    ; the day. Sleeping through it indoors is not an observance. P14's practice token will add the
    ; indoor path for players who keep the rite privately.
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf
    Cell dawnCell = playerRef.GetParentCell()
    if !dawnCell || dawnCell.IsInterior()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Altmer.AuriElDawn.LastDay", dawnDayStamp)
    AwardAltmerAncestorSpinePulse(1.0, "dawn_observance")
    Manager.Trace(2, "Altmer dawn observance routed to the ancestral spine for devotional day " + (dawnDayStamp - 2))
EndFunction

Function RunDawnAwardAltmerXarxesRecord()
    if !IsAltmerOrigin() || !Manager.PDV_Xarxes || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    Int dawnDayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Altmer.XarxesRecord.LastDay") == dawnDayStamp
        return
    endIf

    ; Require study on the PREVIOUS devotional day. Stamps use the zero-reserved day+2
    ; convention, so yesterday's stamp is exactly today's minus one. A zero here means "never
    ; studied" and correctly fails this test rather than matching day 0.
    if StorageUtil.GetIntValue(None, "PDV.Altmer.Xarxes.StudyDay") != (dawnDayStamp - 1)
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Altmer.XarxesRecord.LastDay", dawnDayStamp)
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Xarxes, Manager.PDV_Xarxes.SIGNAL_RECORD_KEPT, None, 1.5)
    Manager.Trace(2, "Altmer Xarxes record-kept routed for devotional day " + (dawnDayStamp - 2))
EndFunction

Function SyncAltmerAncestorSubstrate(Actor playerRef, Bool isAltmer)
    if !playerRef || !Manager.PDV_AltmerAncestorSubstrate
        return
    endIf

    if isAltmer
        Manager.PDV_AltmerAncestorSubstrate.RecomputeSubstrateTier()
    else
        Manager.PDV_AltmerAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncAltmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Altmer " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Altmer " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Altmer " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Altmer " + label)
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

Message Function GetAltmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ApplyAltmerCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function ShouldSuppressAltmerCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowAltmerNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("auri-el", "neutral", "", fallbackText)
EndFunction

Function ShowAltmerMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    if suppressModal
        Manager.SendPrismaToast("auriel", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Bool Function IsBosmerOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER
EndFunction

String Function GetBookOfDaysAltmerCrisisLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function HasBosmerSetupCompleted()
    return StorageUtil.GetIntValue(None, "PDV.Bosmer.SetupComplete") == 1
EndFunction

Function ApplyBosmerInitialChoice(Int pathState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function InitializeBosmerStorage()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsBosmerPactBound()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return False
EndFunction

Function SetBosmerPactBound(Bool isBound, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function EvaluateBosmerForcedReckoning()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function EvaluateBosmerPathSuggestion()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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

String Function GetAltmerCurseSummary()
    if IsAltmerWerewolfHalted()
        return "werewolf_halt"
    endIf

    if IsAltmerVampireExiled()
        return "vampire_exile"
    endIf

    if HasAltmerVampireExileScar()
        return "vampire_scar"
    endIf

    return "none"
EndFunction

String Function GetAltmerSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetAltmerHeritageTierName()
    if !Manager.PDV_AltmerAncestorSubstrate
        return "Heritage quiet"
    endIf
    Int tierValue = Manager.PDV_AltmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Exemplar Heritage"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Disciplined Heritage"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_SEEKER
        return "Ordered Heritage"
    endIf
    return "Heritage quiet"
EndFunction

String Function GetAltmerHeritageTierJournalLine(Int tierValue)
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Your ancestral inheritance is visible in all you do."
    elseIf tierValue >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Your ancestral inheritance is practiced, not merely inherited."
    elseIf tierValue >= Manager.LedgerRuntime.TIER_SEEKER
        return "Your ancestral inheritance begins to take shape in you."
    endIf
    return "Your ancestral inheritance gathers quietly."
EndFunction

String Function GetAltmerAlignmentSurveyBaseText()
    String band = Manager.GetCurrentStandingBand()
    if !Manager.PDV_ThalmorAlignmentTrack
        return "Auri-El remains the foundation. Standing: " + band + "."
    endIf

    Int alignment = Manager.PDV_ThalmorAlignmentTrack.GetValue()
    if alignment <= -76
        return "You hold open heterodoxy: Auri-El remains the foundation, but the Thalmor cannot own the path. Standing: " + band + "."
    elseIf alignment <= -51
        return "You keep private heterodoxy beneath the dawn, testing doctrine without surrendering it. Standing: " + band + "."
    elseIf alignment >= 76
        return "You stand Thalmor-devout, enforcing the return as law and doctrine together. Standing: " + band + "."
    elseIf alignment >= 51
        return "You walk public orthodoxy, letting Altmeri discipline answer Skyrim's compromises. Standing: " + band + "."
    endIf

    return "You remain uncommitted in the Thalmor question, holding Auri-El's foundation while the path sharpens. Standing: " + band + "."
EndFunction

String Function GetBosmerSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
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
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return ""
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

Bool Function IsAltmerVampireExiled()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileActive") == 1
EndFunction

Bool Function IsAltmerWerewolfHalted()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 1
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHalt") == 1
EndFunction

Bool Function HasAltmerVampireExileScar()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER && StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileScar") == 1
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

; ============================================================================
; ORIGIN tranche 2: Khajiit (lunar/road/Baan-Dar/Azurah/focus) + Argonian
; (Hist/sap/adaptation/home) lanes. Moved verbatim from PDV__ManagerQuest;
; bare manager-member references qualified via Manager.; read of
; _suppressCurseTransitionOutputs -> Manager.GetSuppressCurseTransitionOutputs();
; write of _raceCurseSurfaceShown -> Manager.SetRaceCurseSurfaceShown(...).
; ============================================================================

Int Function GetKhajiitFocusForDeityName(String deityName)
    if deityName == "Khenarthi"
        return Manager.KHAJIIT_FOCUS_KHENARTHI
    elseIf deityName == "Azurah" || deityName == "Azura"
        return Manager.KHAJIIT_FOCUS_AZURAH
    elseIf deityName == "Baan Dar"
        return Manager.KHAJIIT_FOCUS_BAANDAR
    elseIf deityName == "Rajhin"
        return Manager.KHAJIIT_FOCUS_RAJHIN
    elseIf deityName == "Alkosh"
        return Manager.KHAJIIT_FOCUS_ALKOSH
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
EndFunction

Function BridgeKhajiitMatrixFocus(String deityName, String magnitude)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function GetLunarPresidingFocus(Int phaseIndex)
    if phaseIndex == 1
        return Manager.KHAJIIT_FOCUS_ALKOSH      ; full moon -- order at its height, the dragon-sun
    elseIf phaseIndex == 2
        return Manager.KHAJIIT_FOCUS_AZURAH      ; waning gibbous -- twilight descending
    elseIf phaseIndex == 3
        return Manager.KHAJIIT_FOCUS_KHENARTHI   ; last quarter -- the road in balance
    elseIf phaseIndex == 4
        return Manager.KHAJIIT_FOCUS_RAJHIN      ; waning crescent -- fading into shadow
    elseIf phaseIndex == 5
        return Manager.KHAJIIT_FOCUS_RAJHIN      ; new moon -- the deepest dark, quiet theft
    elseIf phaseIndex == 6
        return Manager.KHAJIIT_FOCUS_BAANDAR     ; waxing crescent -- the pariah's edge emerging
    elseIf phaseIndex == 7
        return Manager.KHAJIIT_FOCUS_KHENARTHI   ; first quarter -- the road in balance
    elseIf phaseIndex == 8
        return Manager.KHAJIIT_FOCUS_AZURAH      ; waxing gibbous -- twilight ascending
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
EndFunction

Int Function GetKhajiitFocusForDeity(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function GetCurrentLunarPresidingFocus()
    if !IsKhajiitOrigin()
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    return GetLunarPresidingFocus(GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime()))
EndFunction

Int Function GetActiveLunarFavoredFocus()
    Int presidingFocus = GetCurrentLunarPresidingFocus()
    if presidingFocus == Manager.KHAJIIT_FOCUS_NONE || presidingFocus != GetKhajiitFocusedEmphasis()
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    PDV_DeityBase deity = GetKhajiitEmphasisDeity(presidingFocus)
    if !deity || Manager.LedgerRuntime.GetPiety(deity) < 25.0
        return Manager.KHAJIIT_FOCUS_NONE
    endIf

    return presidingFocus
EndFunction

Spell Function GetKhajiitPhaseBlessing(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_Bless_Khajiit_Phase_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_Bless_Khajiit_Phase_Azurah
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_Bless_Khajiit_Phase_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_Bless_Khajiit_Phase_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_Bless_Khajiit_Phase_Alkosh
    endIf

    return None
EndFunction

Function SyncKhajiitPhaseBlessing()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Int focusValue = 1
    while focusValue <= 5
        Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, GetKhajiitPhaseBlessing(focusValue), False, "retired Khajiit phase blessing " + GetKhajiitFocusLabel(focusValue))
        focusValue += 1
    endWhile
EndFunction

Bool Function IsKhajiitLatticeResonating()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return False
EndFunction

Spell Function GetKhajiitFocusedRewardSpell(Int focusValue, Int tierValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Khenarthi_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Khenarthi_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Khenarthi_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Azurah_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Azurah_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Azurah_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_BaanDar_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_BaanDar_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_BaanDar_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Rajhin_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Rajhin_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Rajhin_T1
        endIf
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
            return Manager.PDV_Bless_Khajiit_Alkosh_T3
        elseIf tierValue == Manager.LedgerRuntime.TIER_DEVOTED
            return Manager.PDV_Bless_Khajiit_Alkosh_T2
        elseIf tierValue == Manager.LedgerRuntime.TIER_SEEKER
            return Manager.PDV_Bless_Khajiit_Alkosh_T1
        endIf
    endIf
    return None
EndFunction

Function RefreshKhajiitFocusedRewardForResonance(Actor playerRef)
    Int focusValue = GetKhajiitFocusedEmphasis()
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    if !playerRef || !deity
        return
    endIf
    Spell rewardSpell = GetKhajiitFocusedRewardSpell(focusValue, Manager.LedgerRuntime.GetTier(deity))
    if rewardSpell && playerRef.HasSpell(rewardSpell)
        playerRef.RemoveSpell(rewardSpell)
        playerRef.AddSpell(rewardSpell, False)
    endIf
EndFunction

Function SyncKhajiitLatticeResonance(Actor playerRef)
    if !playerRef
        return
    endIf
    Bool shouldResonate = IsKhajiitLatticeResonating()
    Bool wasResonating = StorageUtil.GetIntValue(None, "PDV.Khajiit.LatticeResonating") == 1
    if shouldResonate
        if Manager.PDV_PERK_Khajiit_LatticeResonance && !playerRef.HasPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
            playerRef.AddPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
        endIf
        if Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker && !playerRef.HasSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
            playerRef.AddSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker, False)
        endIf
    else
        if Manager.PDV_PERK_Khajiit_LatticeResonance && playerRef.HasPerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
            playerRef.RemovePerk(Manager.PDV_PERK_Khajiit_LatticeResonance)
        endIf
        if Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker && playerRef.HasSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Khajiit_LatticeResonanceMarker)
        endIf
    endIf
    if shouldResonate != wasResonating
        if shouldResonate
            StorageUtil.SetIntValue(None, "PDV.Khajiit.LatticeResonating", 1)
        else
            StorageUtil.SetIntValue(None, "PDV.Khajiit.LatticeResonating", 0)
        endIf
        RefreshKhajiitFocusedRewardForResonance(playerRef)
        Manager.RequestPanelRefresh()
        Manager.Trace(1, "Khajiit Lattice Resonance " + shouldResonate)
    endIf
EndFunction

Function SyncKhajiitPortentPower(Actor playerRef)
    if !playerRef || !Manager.PDV_Power_Khajiit_AzurahPortent
        return
    endIf
    PDV_DeityBase focusDeity = GetKhajiitEmphasisDeity(GetKhajiitFocusedEmphasis())
    Bool shouldHave = GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT && focusDeity == Manager.PDV_Azura && Manager.LedgerRuntime.GetTier(focusDeity) >= Manager.LedgerRuntime.TIER_CHAMPION && playerRef.HasSpell(Manager.PDV_Bless_Khajiit_Azurah_T3)
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Power_Khajiit_AzurahPortent, shouldHave, "Azurah Portent power")
EndFunction

Bool Function TryUseKhajiitAzurahPortent(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_AZURAH
        return False
    endIf
    if !Manager.PDV_Azura || Manager.LedgerRuntime.GetTier(Manager.PDV_Azura) < Manager.LedgerRuntime.TIER_CHAMPION || !Manager.PDV_Bless_Khajiit_Azurah_T3 || !playerRef.HasSpell(Manager.PDV_Bless_Khajiit_Azurah_T3)
        SyncKhajiitPortentPower(playerRef)
        return False
    endIf

    Int currentDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.AzurahPortent.Day") == currentDay
        if Manager.PDV_SND_Khajiit_AzurahPortentFizzle
            Manager.PDV_SND_Khajiit_AzurahPortentFizzle.Play(playerRef)
        endIf
        return False
    endIf
    if !Manager.PDV_SPEL_Khajiit_AzurahPortentDetect
        return False
    endIf

    StorageUtil.SetIntValue(None, "PDV.Khajiit.AzurahPortent.Day", currentDay)
    Manager.PDV_SPEL_Khajiit_AzurahPortentDetect.Cast(playerRef, playerRef)
    String portentText = "For a moment, living hearts, restless dead, fallen bodies, Daedra, and brass minds declare their places."
    Manager.SendPrismaToast("azurah", "good", "Azurah's Portent", portentText)
    Manager.AppendBookOfDaysEntry(portentText, Utility.GetCurrentGameTime() as Int, "champion.act", "azurah", False, 1, "Azurah's Portent")
    return True
EndFunction

Bool Function CanExecuteKhajiitBaanDarRescue(Actor playerRef)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return False
EndFunction

Function ScheduleNextKhajiitGodStrengthBoundary()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        UnregisterForUpdateGameTime()
        return
    endIf
    Float nowTime = Utility.GetCurrentGameTime()
    Int currentPhase = GetKhajiitMoonPhaseFromGameDay(nowTime)
    Int currentBucket = (nowTime + 0.5) as Int
    Int candidateBucket = currentBucket + 1
    while candidateBucket < currentBucket + 5 && GetKhajiitMoonPhaseFromGameDay((candidateBucket as Float) - 0.5) == currentPhase
        candidateBucket += 1
    endWhile
    Float hoursUntilBoundary = (((candidateBucket as Float) - 0.5) - nowTime) * 24.0
    if hoursUntilBoundary < 0.05
        hoursUntilBoundary = 0.05
    endIf
    RegisterForSingleUpdateGameTime(hoursUntilBoundary)
EndFunction

Function SyncKhajiitRuntimeState()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf
    if GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_NONE && StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged") == 0
        ; Existing focused saves are grandfathered without replaying the ceremony.
        StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged", 1)
    endIf
    SyncKhajiitEmphasisRewards(playerRef)
    SyncKhajiitPhaseBlessing()
    ScheduleNextKhajiitGodStrengthBoundary()
EndFunction

Function ProcessKhajiitAlkoshWordDrip()
    if !IsKhajiitOrigin()
        return
    endIf

    Int wordsNow = Game.QueryStat("Words Of Power Learned")
    Manager.Trace(3, "Khajiit Alkosh word drip: stat reads " + wordsNow)
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen.Init") == 0
        StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen.Init", 1)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen", wordsNow)
        return
    endIf

    Int wordsSeen = StorageUtil.GetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen")
    Int newWords = wordsNow - wordsSeen
    if newWords <= 0
        return
    endIf

    Int awarded = 0
    while awarded < newWords && awarded < 3
        Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitAlkoshWordOfPower")
        AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_ALKOSH, Manager.KHAJIIT_FOCUS_MATRIX_DELTA * multiplier, "alkosh_word_of_power")
        awarded += 1
    endWhile

    StorageUtil.SetIntValue(None, "PDV.Khajiit.AlkoshWordsSeen", wordsSeen + awarded)
    Manager.Trace(2, "Khajiit Alkosh word-of-power drip awarded " + awarded + " of " + newWords + " new words")
    Manager.SendPrismaShiftToast("Words marked", "Alkosh orders new words.", GetKhajiitFocusSymbol(Manager.KHAJIIT_FOCUS_ALKOSH))
    Manager.LedgerRuntime.RecordRecentDevotionEvent("Alkosh: " + awarded + " words marked")
EndFunction

String Function GetArgonianCulturalNextThresholdText(Float metric)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetArgonianCulturalPracticeLabel()
    if !Manager.PDV_ArgonianHistSubstrate
        return "Practice quiet"
    endIf
    Int tierValue = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Rooted Adaptation"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_DEVOTED
        return "River-Kept Practice"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_SEEKER
        return "Root Memory"
    endIf
    return "Practice quiet"
EndFunction

Function SetArgonianHome(Actor playerRef, Int sleepCellId, Int devotionalDayStamp, String reason)
    if sleepCellId == 0
        return
    endIf

    ; Adaptation's older maturation clock remains a raw game-day value.  The
    ; declaration/candidate cadence above is the one governed by 06:00 days.
    Int today = Utility.GetCurrentGameTime() as Int

    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclaredDay", devotionalDayStamp)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    if Manager.PDV_ArgonianHistSubstrate
        StorageUtil.SetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount", 0)
        StorageUtil.SetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepDay", 0)
    endIf
    ; A chosen adaptation is permanent and follows the player to a new home.
    ; Only an unadapted player rolls a new maturation clock.
    if StorageUtil.GetIntValue(None, "PDV.Adapt.Active") == 0
        StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", today + Utility.RandomInt(10, 14) + 1)
    endIf
    Manager.Trace(2, "Argonian home declared: " + reason)
EndFunction

Spell Function GetArgonianAdaptationSpell(Int adaptationIndex)
    if adaptationIndex == 0
        return Manager.PDV_SPEL_ArgonianAdapt_Claws
    elseIf adaptationIndex == 1
        return Manager.PDV_SPEL_ArgonianAdapt_Skin
    elseIf adaptationIndex == 2
        return Manager.PDV_SPEL_ArgonianAdapt_Sap
    elseIf adaptationIndex == 3
        return Manager.PDV_SPEL_ArgonianAdapt_Marsh
    endIf

    return None
EndFunction

Function SyncArgonianAdaptation(Actor playerRef, Bool isArgonian)
    Int activeAdaptation = StorageUtil.GetIntValue(None, "PDV.Adapt.Active")
    if activeAdaptation <= 0
        return
    endIf

    Spell activeSpell = GetArgonianAdaptationSpell(activeAdaptation - 1)
    if !activeSpell
        return
    endIf

    if isArgonian
        if !playerRef.HasSpell(activeSpell)
            playerRef.AddSpell(activeSpell, False)
        endIf
    else
        if playerRef.HasSpell(activeSpell)
            playerRef.RemoveSpell(activeSpell)
        endIf
    endIf
EndFunction

Function HandleArgonianSacredWaterDiscovery(Location discoveredLocation)
    if !discoveredLocation || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    if !Manager.PDV_FLST_ArgonianSacredWaters || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    ; Eldergleam's water and great tree are inside the cave, but the sanctuary
    ; LOCATION spans the exterior approach too. Arm the interior-cell catch
    ; instead of firing at the door; TryArgonianEldergleamInterior awards it
    ; once the player is actually in a cave cell.
    if discoveredLocation.GetFormID() == 0x000192AC
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 1)
        return
    endIf

    if !Manager.PDV_FLST_ArgonianSacredWaters.HasForm(discoveredLocation)
        return
    endIf

    AwardArgonianSacredWater(discoveredLocation.GetFormID())
EndFunction

Function AwardArgonianSacredWater(Int siteFormId)
    String seenKey = "PDV.ArgWaters.Seen." + siteFormId
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    Int seenCount = StorageUtil.AdjustIntValue(None, "PDV.ArgWaters.Count", 1)

    Manager.PDV_ArgonianHistSubstrate.SetHistRelation(Manager.PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sacred_water")
    Manager.PDV_ArgonianHistSubstrate.StampHistMaintenance("sacred_water_" + siteFormId)
    Manager.PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_sacred_water", "sacred_water_" + siteFormId)
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, 1.0)
    endIf
    Debug.MessageBox("The water remembers. For one slow breath you stand in the marsh again, and the root speaks your name.")
    SendPrismaSubstrateToast("ArgonianHist", "water", "A water that remembers.", "hist", GetArgonianHistPostureLabel())
    Manager.AppendBookOfDaysEntry("A water that remembers.", Utility.GetCurrentGameTime() as Int, "substrate.act", "hist", False)

    if seenCount >= Manager.PDV_FLST_ArgonianSacredWaters.GetSize()
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.Milestone", 1)
        Debug.MessageBox("Every water that remembers has known you now. The marsh is never truly far -- the root holds you, wherever the road takes you.")
    endIf
    Manager.Trace(2, "Sacred water remembered: " + seenCount + " of " + Manager.PDV_FLST_ArgonianSacredWaters.GetSize())
EndFunction

Function UpdateArgonianSanctuaryActive(Location loc)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    Int active = 0
    if loc && loc.GetFormID() == 0x000192AC
        active = 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", active)
EndFunction

Function TryArgonianEldergleamInterior()
    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.EldergleamActive") != 1
        return
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || StorageUtil.GetIntValue(None, "PDV.ArgWaters.Seen.103084") == 1
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 0)
        return
    endIf

    Actor argonianPlayer = Game.GetPlayer()
    Cell parentCell = argonianPlayer.GetParentCell()
    if !parentCell
        return
    endIf

    Int cellId = parentCell.GetFormID()
    if cellId == 0x0003A9EC || cellId == 0x0003A9E0 || cellId == 0x0003A9E3
        AwardArgonianSacredWater(0x000192AC)
        StorageUtil.SetIntValue(None, "PDV.ArgWaters.EldergleamActive", 0)
    endIf
EndFunction

Function TryArgonianNearWaterMaintenance()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Int pdvEncodedWaterDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.NearWaterDay") == pdvEncodedWaterDay
        return
    endIf

    Actor argonianPlayer = Game.GetPlayer()
    Cell waterCell = None
    if argonianPlayer
        waterCell = argonianPlayer.GetParentCell()
    endIf
    if !argonianPlayer || !argonianPlayer.IsSwimming() || !waterCell || waterCell.IsInterior()
        StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", 0.0)
        return
    endIf

    Float startedAt = StorageUtil.GetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime")
    if startedAt <= 0.0
        StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", Utility.GetCurrentRealTime())
        return
    endIf
    if Utility.GetCurrentRealTime() - startedAt < 10.0
        return
    endIf

    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.NearWaterDay")
    StorageUtil.SetFloatValue(None, "PDV.Argonian.WaterPractice.StartRealTime", 0.0)
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianNearWater")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, "near_water")
    RefreshArgonianHistPosture("near_water")
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The water remembers you.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian near-water Hist maintenance routed.")
EndFunction

Function HandleArgonianSapVision()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleArgonianShadowscaleKill(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return
    endIf

    if !Manager.PDV_ArgonianHistSubstrate || !Manager.PDV_SPEL_ArgonianShadowscaleVeil
        return
    endIf

    if !playerRef.IsSneaking()
        return
    endIf

    if !Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != Manager.ARGONIAN_FOCUS_VOID
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Shadowscale.LastInvisDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_ArgonianShadowscaleVeil.Cast(playerRef, playerRef)
    SendPrismaSubstrateToast("ArgonianHist", "shadowscale", "The shadow closes over you. The Void hides its own.", "void", Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Shadowscale.LastInvisDay")
    Manager.Trace(2, "Shadowscale veil fired on sneak kill.")
EndFunction

Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitLunarSubstrate(String sourceId)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function EnsureKhajiitObserveMoonsPower()
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_Power_Khajiit_ObserveMoons
        return
    endIf
    if IsKhajiitOrigin()
        if !playerRef.HasSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
            playerRef.AddSpell(Manager.PDV_Power_Khajiit_ObserveMoons, False)
        endIf
        ; One-time migration: clear an obsolete hand assignment without
        ; changing the player's selected lesser power. Observe the Moons and
        ; Survey Devotion are peers in the same Power slot; selecting either in
        ; the Magic menu replaces the other in the ordinary Skyrim way.
    elseIf playerRef.HasSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
        playerRef.RemoveSpell(Manager.PDV_Power_Khajiit_ObserveMoons)
    endIf
EndFunction

Int Function BeginKhajiitMoonObservation(Actor playerRef)
    if !playerRef || playerRef != Game.GetPlayer() || !IsValidKhajiitMoonObservationContext(playerRef)
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "invalid_start_context")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected start: invalid_start_context")
        return 0
    endIf
    if _khajiitMoonObservationPending
        if Utility.GetCurrentRealTime() - _khajiitMoonObservationStartRealTime > 30.0
            _khajiitMoonObservationPending = False
            Manager.Trace(1, "[PDV][MOON_RITE] cleared stale pending observation")
        else
            StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "already_pending")
            Manager.Trace(1, "[PDV][MOON_RITE] rejected start: already_pending")
            return 0
        endIf
    endIf

    _khajiitMoonObservationGeneration += 1
    if _khajiitMoonObservationGeneration <= 0
        _khajiitMoonObservationGeneration = 1
    endIf
    _khajiitMoonObservationPending = True
    _khajiitMoonObservationStartRealTime = Utility.GetCurrentRealTime()
    _khajiitMoonObservationCell = playerRef.GetParentCell()
    _khajiitMoonObservationX = playerRef.GetPositionX()
    _khajiitMoonObservationY = playerRef.GetPositionY()
    _khajiitMoonObservationZ = playerRef.GetPositionZ()
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "")
    Manager.Trace(1, "[PDV][MOON_RITE] started token=" + _khajiitMoonObservationGeneration)
    return _khajiitMoonObservationGeneration
EndFunction

Function ProcessPendingKhajiitMoonObservation(Int observationToken)
    if !_khajiitMoonObservationPending || observationToken <= 0 || observationToken != _khajiitMoonObservationGeneration
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: stale_token=" + observationToken)
        return
    endIf
    if Utility.GetCurrentRealTime() - _khajiitMoonObservationStartRealTime < 2.0
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "delay_incomplete")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: delay_incomplete token=" + observationToken)
        return
    endIf
    _khajiitMoonObservationPending = False
    Actor playerRef = Game.GetPlayer()
    if !IsValidKhajiitMoonObservationContext(playerRef) || playerRef.GetParentCell() != _khajiitMoonObservationCell
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "interrupted_context")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: interrupted_context token=" + observationToken)
        return
    endIf

    Float dx = playerRef.GetPositionX() - _khajiitMoonObservationX
    Float dy = playerRef.GetPositionY() - _khajiitMoonObservationY
    Float dz = playerRef.GetPositionZ() - _khajiitMoonObservationZ
    if (dx * dx) + (dy * dy) + (dz * dz) > 16384.0
        StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastReject", "moved_too_far")
        Manager.Trace(1, "[PDV][MOON_RITE] rejected completion: moved_too_far token=" + observationToken)
        return
    endIf

    CompleteKhajiitMoonObservation(playerRef)
EndFunction

Bool Function IsValidKhajiitMoonObservationContext(Actor playerRef)
    if !playerRef || !IsKhajiitOrigin() || playerRef.IsInCombat() || playerRef.IsOnMount() || playerRef.IsSwimming()
        return False
    endIf
    Cell currentCell = playerRef.GetParentCell()
    if !currentCell || currentCell.IsInterior()
        return False
    endIf
    Float nowTime = Utility.GetCurrentGameTime()
    Float hourOfDay = (nowTime - ((nowTime as Int) as Float)) * 24.0
    return hourOfDay >= 20.0 || hourOfDay < 5.0
EndFunction

Function CompleteKhajiitMoonObservation(Actor playerRef)
    Float nowTime = Utility.GetCurrentGameTime()
    Int phaseIndex = GetKhajiitMoonPhaseFromGameDay(nowTime)
    Int focusValue = GetLunarPresidingFocus(phaseIndex)
    Int tierBefore = Manager.LedgerRuntime.TIER_NONE
    Int tierAfter = Manager.LedgerRuntime.TIER_NONE
    Float metricBefore = 0.0
    Float metricAfter = 0.0
    if Manager.PDV_KhajiitLunarSubstrate
        metricBefore = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
        tierBefore = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
        Manager.PDV_KhajiitLunarSubstrate.ObserveMoonPhase(phaseIndex, "observe_moons_power")
        tierAfter = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
        metricAfter = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
    endIf

    Bool firstRiteToday = False
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Khajiit.MoonRite.PietyDay") != todayStamp
        firstRiteToday = True
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Khajiit.MoonRite.PietyDay")
        PDV_DeityBase presidingDeity = GetKhajiitEmphasisDeity(focusValue)
        if presidingDeity
            Manager.LedgerRuntime.AwardPietyInternal(presidingDeity, 0.4, True, "observe_moons_power")
        endIf
        StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", nowTime)
        ; Preserve the common actual-delta accounting path without emitting a
        ; second toast or Book entry; the authored contemplation below owns
        ; this rite's single player-facing presentation.
        Manager.SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, metricAfter - metricBefore, "", "lunar", GetKhajiitLunarTierLabel(tierAfter), False)
    endIf

    ShowKhajiitMoonContemplation(focusValue, firstRiteToday)
    SyncKhajiitRuntimeState()
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastPhase", phaseIndex)
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastFocus", focusValue)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.MoonRite.LastSuccessTime", nowTime)
    Manager.Trace(1, "[PDV][MOON_RITE] success phase=" + phaseIndex + " focus=" + focusValue + " metricDelta=" + (metricAfter - metricBefore))
    Manager.RequestPanelRefresh()
EndFunction

Function ShowKhajiitMoonContemplation(Int focusValue, Bool firstRiteToday)
    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        return
    endIf
    if !IsKhajiitMoonObservationJsonValid(focusValue)
        ShowKhajiitMoonContemplationFallback(focusValue, firstRiteToday)
        return
    endIf

    String deityKey = GetKhajiitMoonObservationDeityKey(focusValue)
    String lastId = StorageUtil.GetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId")
    Int excludedPoolIndex = -1
    Int i = 0
    while i < 16 && excludedPoolIndex < 0
        String candidatePath = "." + deityKey + "[" + i + "].id"
        if i >= 10
            candidatePath = ".shared[" + (i - 10) + "].id"
        endIf
        if JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, candidatePath, "") == lastId
            excludedPoolIndex = i
        endIf
        i += 1
    endWhile

    Int poolIndex = Utility.RandomInt(0, 15)
    if excludedPoolIndex >= 0
        poolIndex = Utility.RandomInt(0, 14)
        if poolIndex >= excludedPoolIndex
            poolIndex += 1
        endIf
    endIf

    String entryPath = "." + deityKey + "[" + poolIndex + "]"
    if poolIndex >= 10
        entryPath = ".shared[" + (poolIndex - 10) + "]"
    endIf
    String resolvedId = JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".id", "")
    String titleText = GetKhajiitFocusLabel(focusValue) + " in Strength - " + JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".title", "")
    String bodyText = JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".body", "")
    Manager.SendPrismaToast(GetKhajiitFocusSymbol(focusValue), "good", titleText, bodyText)
    if firstRiteToday
        Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "substrate.act", GetKhajiitFocusSymbol(focusValue), False, 1, titleText)
    endIf
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId", resolvedId)
EndFunction

Bool Function IsKhajiitMoonObservationJsonValid(Int focusValue)
    ; Load/IsGood run every call -- see _khajiitMoonObservationsValidatedVersion for why they are not
    ; cached. The cache is keyed on deityKey as well as VERSION: each focus deity has its own 10-entry
    ; pool, so validating khenarthi says nothing about alkosh.
    String deityKey = GetKhajiitMoonObservationDeityKey(focusValue)
    if deityKey == "" || !JsonUtil.Load(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE) || !JsonUtil.IsGood(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE)
        _khajiitMoonObservationsValidatedVersion = -1
        _khajiitMoonObservationsValidatedKey = ""
        return False
    endIf
    if _khajiitMoonObservationsValidatedVersion == Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION && _khajiitMoonObservationsValidatedKey == deityKey
        return True
    endIf
    if JsonUtil.GetPathIntValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, ".version", -1) != Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION
        return False
    endIf
    if JsonUtil.PathCount(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, ".shared") != 6 || JsonUtil.PathCount(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, "." + deityKey) != 10
        return False
    endIf
    Int poolIndex = 0
    while poolIndex < 16
        String entryPath = "." + deityKey + "[" + poolIndex + "]"
        if poolIndex >= 10
            entryPath = ".shared[" + (poolIndex - 10) + "]"
        endIf
        if JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".id", "") == "" || JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".title", "") == "" || JsonUtil.GetPathStringValue(Manager.KHAJIIT_MOON_OBSERVATIONS_FILE, entryPath + ".body", "") == ""
            return False
        endIf
        poolIndex += 1
    endWhile
    _khajiitMoonObservationsValidatedVersion = Manager.KHAJIIT_MOON_OBSERVATIONS_VERSION
    _khajiitMoonObservationsValidatedKey = deityKey
    return True
EndFunction

String Function GetKhajiitMoonObservationDeityKey(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "azurah"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "baandar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "alkosh"
    endIf
    return ""
EndFunction

Function ShowKhajiitMoonContemplationFallback(Int focusValue, Bool firstRiteToday)
    Int localIndex = Utility.RandomInt(0, 3)
    Int messageIndex = ((focusValue - 1) * 4) + localIndex
    Int lastIndex = StorageUtil.GetIntValue(None, "PDV.Khajiit.MoonRite.LastMessage", -1)
    if messageIndex == lastIndex
        localIndex = (localIndex + 1) % 4
        messageIndex = ((focusValue - 1) * 4) + localIndex
    endIf
    String titleText = GetKhajiitFocusLabel(focusValue) + " in Strength - " + GetKhajiitMoonContemplationTitle(messageIndex)
    String bodyText = GetKhajiitMoonContemplationText(messageIndex)
    Manager.SendPrismaToast(GetKhajiitFocusSymbol(focusValue), "good", titleText, bodyText)
    if firstRiteToday
        Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "substrate.act", GetKhajiitFocusSymbol(focusValue), False, 1, titleText)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Khajiit.MoonRite.LastMessage", messageIndex)
    StorageUtil.SetStringValue(None, "PDV.Khajiit.MoonRite.LastResolvedId", "fallback_" + messageIndex)
EndFunction

String Function GetKhajiitMoonContemplationTitle(Int messageIndex)
    if messageIndex == 0
        return "The Road Breathes"
    elseIf messageIndex == 1
        return "A Windward Home"
    elseIf messageIndex == 2
        return "The Open Mile"
    elseIf messageIndex == 3
        return "Breath Between Steps"
    elseIf messageIndex == 4
        return "Twilight's Mirror"
    elseIf messageIndex == 5
        return "A Name at Dusk"
    elseIf messageIndex == 6
        return "Shadow With Shape"
    elseIf messageIndex == 7
        return "The Liminal Hour"
    elseIf messageIndex == 8
        return "The Unlatched Gate"
    elseIf messageIndex == 9
        return "Luck Turned Sideways"
    elseIf messageIndex == 10
        return "The Laughing Escape"
    elseIf messageIndex == 11
        return "Clever Hands, Clear Debt"
    elseIf messageIndex == 12
        return "A Secret Kept"
    elseIf messageIndex == 13
        return "The Audacious Step"
    elseIf messageIndex == 14
        return "Limits in Silver"
    elseIf messageIndex == 15
        return "The Purring Question"
    elseIf messageIndex == 16
        return "The Ordered Sky"
    elseIf messageIndex == 17
        return "A Dragon's Measure"
    elseIf messageIndex == 18
        return "The Hour Unbroken"
    endIf
    return "Duty Beneath the Moons"
EndFunction

String Function GetKhajiitMoonContemplationText(Int messageIndex)
    if messageIndex == 0
        return "The wind crosses your whiskers like a road remembered. Khenarthi asks where you will return when the path grows quiet."
    elseIf messageIndex == 1
        return "Cloud and branch lean the same way tonight. Khenarthi teaches that a home may be carried without being abandoned."
    elseIf messageIndex == 2
        return "The sky leaves no walls around you. Khenarthi's road is freedom joined to the duty to return."
    elseIf messageIndex == 3
        return "For a moment, the wind stills. The pause belongs to Khenarthi as surely as the journey."
    elseIf messageIndex == 4
        return "Moonlight divides shadow from darkness. Azurah asks which parts of yourself you hide, and which you keep."
    elseIf messageIndex == 5
        return "The night changes every color without erasing it. Azurah keeps identity through every crossing."
    elseIf messageIndex == 6
        return "Your shadow lengthens beneath the moons. Azurah teaches that shadow can reveal the form that casts it."
    elseIf messageIndex == 7
        return "Neither day nor deepest night claims this hour. Azurah watches over the self made between worlds."
    elseIf messageIndex == 8
        return "A narrow opening is still an opening. Baan Dar favors the wit that finds a way without surrendering the self."
    elseIf messageIndex == 9
        return "The moons make familiar stones look strange. Baan Dar reminds you that reversal begins by seeing another angle."
    elseIf messageIndex == 10
        return "A distant night sound might be danger or laughter. Baan Dar prizes the survivor who can tell, then act."
    elseIf messageIndex == 11
        return "The road offers many exits. Baan Dar asks whether your cleverness frees only you, or those beside you."
    elseIf messageIndex == 12
        return "Moonlight reaches most places, but not all. Rajhin asks whether a secret is power, burden, or both."
    elseIf messageIndex == 13
        return "The next step lies beyond certainty. Rajhin honors audacity that knows the line it chooses to cross."
    elseIf messageIndex == 14
        return "The moons draw bright borders around the dark. Rajhin teaches that limits are clearest to those tempted to test them."
    elseIf messageIndex == 15
        return "Night keeps its answers close. Rajhin leaves you a question whose value lies in what you dare not say."
    elseIf messageIndex == 16
        return "The moons keep their courses without hurry. Alkosh teaches that order is not stillness, but motion kept true."
    elseIf messageIndex == 17
        return "Time stretches above you like a dragon's shadow. Alkosh asks what duty can survive both fear and glory."
    elseIf messageIndex == 18
        return "This moment will not return, yet it belongs to every moment after it. Alkosh keeps consequence within time."
    endIf
    return "The sky is vast, but each light holds its place. Alkosh reminds you that duty gives freedom a shape."
EndFunction

Function HandleKhajiitRoadHome(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitRoadHomeAnchor(Int anchorId, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitFocusedSource(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitFocusedSourceForFocus(Int focusValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitAlkoshNamedDragon(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitAlkoshGenericDragon(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitBaanDarReversal(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Float Function RecordKhajiitFocusSignal(Int focusValue, String keyPrefix, String label, String reason)
    if !IsKhajiitOrigin()
        return 0.0
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier(keyPrefix)
    StorageUtil.AdjustIntValue(None, keyPrefix + ".CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    ; The piety pulse must land before evaluation: focus emergence requires both
    ; behavioral dominance and actual Seeker piety on this same event.
    AdjustKhajiitFocusedEmphasis(focusValue, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason, False)
    PulseKhajiitFocusPiety(focusValue, multiplier)
    EvaluateKhajiitFocusedEmphasis()
    Manager.Trace(2, "Khajiit " + label + " routed with multiplier " + multiplier)
    return multiplier
EndFunction

PDV_DeityBase Function GetKhajiitEmphasisDeity(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_Azura
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_Alkosh
    endIf

    return None
EndFunction

Function PulseKhajiitFocusPiety(Int focusValue, Float multiplier)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI && Manager.PDV_Khenarthi
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR && Manager.PDV_BaanDar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_ROAD_TRICK, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN && Manager.PDV_Rajhin
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_ELEGANT_THEFT, None, multiplier)
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH && Manager.PDV_Alkosh
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_DRAGON_ORDER, None, multiplier)
    endIf
EndFunction

Function HandleKhajiitAzurahDesecration(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitKhenarthiCaravanHarm(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitKhenarthiCaravanAid(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitRajhinLegendMade(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Rajhin
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RajhinLegendMade")
    if multiplier <= 0.0
        Manager.Trace(2, "Khajiit Rajhin legend-made blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_LEGEND_MADE, None, multiplier)
    AwardKhajiitSubstrateSubstitute("khajiit_rajhin_notable_theft", reason)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Rajhin, "Legend made", "marks a theft worth remembering.")
    Manager.Trace(2, "Khajiit Rajhin legend-made routed (" + reason + ")")
EndFunction

Function AwardKhajiitSubstrateSubstitute(String sourceId, String reason)
    if IsKhajiitOrigin() && Manager.PDV_KhajiitLunarSubstrate
        Manager.PDV_KhajiitLunarSubstrate.RecordCulturalSubstitute(sourceId, reason)
    endIf
EndFunction

Function HandleKhajiitRajhinBotchedTheft(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitAlkoshChaosAid(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleKhajiitBaanDarBetrayal(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsKhajiitOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
EndFunction

Int Function GetKhajiitLunarPosture()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function DeriveKhajiitLunarPosture()
    if Manager.PDV_CurseStateService
        if Manager.PDV_CurseStateService.IsWerewolf()
            return Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        elseIf Manager.PDV_CurseStateService.IsVampire()
            return Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        endIf
    endIf

    if HasKhajiitShadowDrift()
        return Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
    endIf

    return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
EndFunction

Bool Function HasKhajiitShadowDrift()
    if StorageUtil.GetIntValue(None, "PDV.Khajiit.ShadowDrift.DebugForce") == 1
        return True
    endIf

    if !Manager.PDV_KhajiitLunarPostureTrack
        return False
    endIf

    return Manager.PDV_KhajiitLunarPostureTrack.HasRecentEvidenceDays(Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, Manager.KHAJIIT_SHADOWDRIFT_EVIDENCE_REQUIRED, Manager.KHAJIIT_SHADOWDRIFT_EVIDENCE_WINDOW)
EndFunction

Function RecordKhajiitShadowEvidence(String reason)
    if !Manager.PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Float gameTime = Utility.GetCurrentGameTime()
    Int dayInt = gameTime as Int
    Float hour = (gameTime - dayInt) * 24.0
    if hour < 19.0 && hour >= 7.0
        return
    endIf

    Manager.PDV_KhajiitLunarPostureTrack.RecordEvidenceDay(Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT, reason)
    Manager.Trace(2, "Khajiit shadow-evidence day recorded (" + reason + ")")
EndFunction

Function RefreshKhajiitLunarPosture(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetKhajiitLunarPostureDisplayLabelAt(Int posture)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetKhajiitLunarPostureReadout(Int posture)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ShowKhajiitMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ApplyKhajiitCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleArgonianHistMaintenance(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleArgonianPeopleSupport(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleArgonianBedOfChoiceReturn(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleArgonianVoidSignal(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RunDawnRefreshArgonianHist()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RefreshArgonianHistPosture(String reason)
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    RefreshArgonianDominationPressure(reason)

    Int curseState = 0
    if Manager.PDV_CurseStateService
        curseState = Manager.PDV_CurseStateService.GetCurseState()
    endIf

    Int oldPosture = 0
    if Manager.PDV_ArgonianHistPostureTrack
        oldPosture = Manager.PDV_ArgonianHistPostureTrack.GetCurrentState()
    endIf

    Bool dominationPressure = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure") == 1
    Manager.PDV_ArgonianHistSubstrate.RefreshHistPosture(curseState, dominationPressure, reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.PDV_ArgonianHistSubstrate.GetHistPosture())
    if Manager.PDV_ArgonianHistPostureTrack
        Manager.PDV_ArgonianHistPostureTrack.SetState(Manager.PDV_ArgonianHistSubstrate.GetHistPosture(), reason)
        if Manager.PDV_ArgonianHistPostureTrack.GetCurrentState() != oldPosture
            Manager.SendPrismaShiftToast(GetArgonianHistPostureLabel(), "", "hist")
            Manager.RequestPanelRefresh()
            Int newPosture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
            if newPosture == Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
                EmitHistCorruptionMinus(reason)
            elseIf newPosture == Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_DISTANT
                EmitHistAbandonmentMinus(reason)
            endIf
        endIf
    endIf
EndFunction

Function RefreshArgonianDominationPressure(String reason)
    Bool active = IsArgonianMolagBalDominationPressureActive()
    Int oldValue = StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.DominationPressure")
    StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.DominationPressure", PDV_DevotionRules.BoolToInt(active))
    if PDV_DevotionRules.BoolToInt(active) != oldValue
        Manager.Trace(1, "Argonian domination pressure -> " + PDV_DevotionRules.BoolToInt(active) + " (" + reason + ")")
    endIf
EndFunction

Function RefreshArgonianDominationPressureForPath(PDV_DaedricPathBase path, String reason)
    if !path
        return
    endIf
    if path.DeityName != "Molag Bal" && path.DeityName != "Molag"
        return
    endIf
    if GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
        RefreshArgonianHistPosture(reason)
    endIf
EndFunction

Bool Function IsArgonianMolagBalDominationPressureActive()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return False
    endIf
    if !Manager.PDV_CurseStateService || Manager.PDV_CurseStateService.GetCurseState() != 2
        return False
    endIf

    PDV_DeityBase deity = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Molag Bal")
    PDV_DaedricPathBase molagPath = deity as PDV_DaedricPathBase
    if !molagPath
        return False
    endIf

    return molagPath.GetStoredTier() >= Manager.LedgerRuntime.TIER_SEEKER
EndFunction

Function AdjustKhajiitFocusedEmphasis(Int focusValue, Float amount, String reason, Bool evaluateNow = True)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return
    endIf

    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        return
    endIf

    String focusKey = GetKhajiitFocusWeightKey(focusValue)
    StorageUtil.AdjustFloatValue(None, focusKey, amount)
    if evaluateNow
        EvaluateKhajiitFocusedEmphasis()
    endIf
    Manager.Trace(2, "Khajiit focus " + GetKhajiitFocusLabel(focusValue) + " adjusted by " + amount + " (" + reason + ")")
EndFunction

Function EvaluateKhajiitFocusedEmphasis()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return
    endIf
    Float khenarthi = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_KHENARTHI)
    Float azurah = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_AZURAH)
    Float baanDar = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_BAANDAR)
    Float rajhin = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_RAJHIN)
    Float alkosh = GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_ALKOSH)

    Int bestFocus = Manager.KHAJIIT_FOCUS_NONE
    Float bestWeight = 0.0
    if khenarthi > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_KHENARTHI
        bestWeight = khenarthi
    endIf
    if azurah > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_AZURAH
        bestWeight = azurah
    endIf
    if baanDar > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_BAANDAR
        bestWeight = baanDar
    endIf
    if rajhin > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_RAJHIN
        bestWeight = rajhin
    endIf
    if alkosh > bestWeight
        bestFocus = Manager.KHAJIIT_FOCUS_ALKOSH
        bestWeight = alkosh
    endIf

    ; All five weights are already local. Re-reading the current leader from
    ; StorageUtil after every comparison added five external calls to every
    ; focus-bearing action without changing the strict-greater tie behavior.
    Float nextWeight = GetKhajiitSecondFocusWeight(bestFocus, khenarthi, azurah, baanDar, rajhin, alkosh)

    ; Once a focus has emerged, a tie, lead loss, or later piety loss does not
    ; erase it. A replacement must independently satisfy both gates.
    if bestWeight < Manager.KHAJIIT_FOCUS_THRESHOLD || (bestWeight - nextWeight) < Manager.KHAJIIT_FOCUS_LEAD_REQUIRED
        return
    endIf

    PDV_DeityBase bestDeity = GetKhajiitEmphasisDeity(bestFocus)
    if !bestDeity || Manager.LedgerRuntime.GetPiety(bestDeity) < 25.0
        return
    endIf

    SetKhajiitFocusedEmphasis(bestFocus, "lead")
EndFunction

Float Function GetKhajiitSecondFocusWeight(Int bestFocus, Float khenarthi, Float azurah, Float baanDar, Float rajhin, Float alkosh)
    Float secondWeight = 0.0
    if bestFocus != Manager.KHAJIIT_FOCUS_KHENARTHI && khenarthi > secondWeight
        secondWeight = khenarthi
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_AZURAH && azurah > secondWeight
        secondWeight = azurah
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_BAANDAR && baanDar > secondWeight
        secondWeight = baanDar
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_RAJHIN && rajhin > secondWeight
        secondWeight = rajhin
    endIf
    if bestFocus != Manager.KHAJIIT_FOCUS_ALKOSH && alkosh > secondWeight
        secondWeight = alkosh
    endIf
    return secondWeight
EndFunction

Function SetKhajiitFocusedEmphasis(Int focusValue, String reason)
    Int oldFocus = GetKhajiitFocusedEmphasis()
    if oldFocus != Manager.KHAJIIT_FOCUS_NONE && focusValue == Manager.KHAJIIT_FOCUS_NONE
        return
    endIf
    if oldFocus == focusValue
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusedEmphasis", focusValue)
    if Manager.PDV_GLO_KhajiitFocusedEmphasis
        Manager.PDV_GLO_KhajiitFocusedEmphasis.SetValue(focusValue as Float)
    endIf

    Manager.Trace(1, "Khajiit focused emphasis " + GetKhajiitFocusLabel(oldFocus) + " -> " + GetKhajiitFocusLabel(focusValue) + " (" + reason + ")")
    String focusText = GetKhajiitFocusShiftText(focusValue)
    Manager.SendPrismaShiftToast("Your road turns toward " + GetKhajiitFocusLabel(focusValue) + ".", focusText, GetKhajiitFocusSymbol(focusValue))
    Bool firstEmergence = oldFocus == Manager.KHAJIIT_FOCUS_NONE && StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged") == 0
    if firstEmergence
        StorageUtil.SetIntValue(None, "PDV.Khajiit.FocusEmergenceAcknowledged", 1)
        Message emergenceMessage = GetKhajiitFocusEmergenceMessage(focusValue)
        if emergenceMessage
            emergenceMessage.Show()
        else
            Debug.MessageBox(focusText)
        endIf
    endIf
    if firstEmergence
        Manager.AppendBookOfDaysEntry(focusText, Utility.GetCurrentGameTime() as Int, "focus.emergence", GetKhajiitFocusSymbol(focusValue), True, 1, GetKhajiitFocusLabel(focusValue) + " Emerges")
    else
        Manager.AppendBookOfDaysEntry(focusText, Utility.GetCurrentGameTime() as Int, "reorientation", GetKhajiitFocusSymbol(focusValue), False, 1, "The Road Turns")
    endIf
    SyncKhajiitRuntimeState()
    Manager.RequestPanelRefresh()
EndFunction

Message Function GetKhajiitFocusEmergenceMessage(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return Manager.PDV_MSG_KhajiitFocus_Khenarthi
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return Manager.PDV_MSG_KhajiitFocus_Azurah
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return Manager.PDV_MSG_KhajiitFocus_BaanDar
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return Manager.PDV_MSG_KhajiitFocus_Rajhin
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return Manager.PDV_MSG_KhajiitFocus_Alkosh
    endIf
    return None
EndFunction

Int Function GetKhajiitFocusedEmphasis()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return 0
EndFunction

Float Function GetKhajiitFocusWeight(Int focusValue)
    return StorageUtil.GetFloatValue(None, GetKhajiitFocusWeightKey(focusValue))
EndFunction

String Function GetKhajiitFocusWeightKey(Int focusValue)
    return "PDV.Khajiit.Focus." + GetKhajiitFocusStorageLabel(focusValue)
EndFunction

String Function GetKhajiitFocusLabel(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "Azurah"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "Rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "Alkosh"
    endIf

    return "None"
EndFunction

String Function GetKhajiitFocusStorageLabel(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "BaanDar"
    endIf

    return GetKhajiitFocusLabel(focusValue)
EndFunction

String Function GetKhajiitFocusShiftText(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "Khenarthi's wind has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "Azurah's dusk-bright road has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "Baan Dar's road has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "Rajhin's clever path has found your steps."
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "Alkosh's order has found your steps."
    endIf

    return "The Lunar Lattice has found a new shape in your practice."
EndFunction

Function EmitHistAbandonmentMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistAbandonment")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistAbandonmentTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistCorruptionMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistCorruption")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_CORRUPTION, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistCorruptionCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistCorruptionReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistCorruptionTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist corruption routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitHistVoidOverreachMinus(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_Hist
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HistVoidOverreach")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_VOID_OVERREACH, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.VoidOverreachCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastVoidOverreachReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastVoidOverreachTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Hist void overreach routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function SyncKhajiitEmphasisRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Int activeFocus = Manager.KHAJIIT_FOCUS_NONE
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
        activeFocus = GetKhajiitFocusedEmphasis()
        PDV_DeityBase deity = GetKhajiitEmphasisDeity(activeFocus)
        if deity
            activeTier = Manager.LedgerRuntime.GetTier(deity)
        endIf
    endIf

    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_KHENARTHI, activeFocus, activeTier, Manager.PDV_Khenarthi, Manager.PDV_Bless_Khajiit_Khenarthi_T1, Manager.PDV_Bless_Khajiit_Khenarthi_T2, Manager.PDV_Bless_Khajiit_Khenarthi_T3, "Khenarthi")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_AZURAH, activeFocus, activeTier, Manager.PDV_Azura, Manager.PDV_Bless_Khajiit_Azurah_T1, Manager.PDV_Bless_Khajiit_Azurah_T2, Manager.PDV_Bless_Khajiit_Azurah_T3, "Azurah")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_BAANDAR, activeFocus, activeTier, Manager.PDV_BaanDar, Manager.PDV_Bless_Khajiit_BaanDar_T1, Manager.PDV_Bless_Khajiit_BaanDar_T2, Manager.PDV_Bless_Khajiit_BaanDar_T3, "Baan Dar")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_RAJHIN, activeFocus, activeTier, Manager.PDV_Rajhin, Manager.PDV_Bless_Khajiit_Rajhin_T1, Manager.PDV_Bless_Khajiit_Rajhin_T2, Manager.PDV_Bless_Khajiit_Rajhin_T3, "Rajhin")
    SyncKhajiitEmphasisFamily(playerRef, Manager.KHAJIIT_FOCUS_ALKOSH, activeFocus, activeTier, Manager.PDV_Alkosh, Manager.PDV_Bless_Khajiit_Alkosh_T1, Manager.PDV_Bless_Khajiit_Alkosh_T2, Manager.PDV_Bless_Khajiit_Alkosh_T3, "Alkosh")
    SyncKhajiitLatticeResonance(playerRef)
    SyncKhajiitPortentPower(playerRef)
EndFunction

Function SyncKhajiitEmphasisFamily(Actor playerRef, Int thisFocus, Int activeFocus, Int activeTier, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = (thisFocus == activeFocus)
    Bool hadChampionSpell = False
    if t3
        hadChampionSpell = playerRef.HasSpell(t3)
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Khajiit " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Khajiit " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION, "Khajiit " + label + " T3")

    if isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION && t3 && !hadChampionSpell && playerRef.HasSpell(t3) && deity && Manager.LedgerRuntime.NotifyTierUp(deity, Manager.LedgerRuntime.TIER_CHAMPION)
        Manager.SendPrismaEventToast("tier", deity, "", Manager.GetPublicTierBand(Manager.LedgerRuntime.TIER_CHAMPION), "")
        Manager.SurfaceTransition("tier", deity.DeityName + " " + Manager.GetTierStandingLabel(Manager.LedgerRuntime.TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)
        Manager.Trace(1, "Khajiit Champion reward presentation shown: " + deity.DeityName)
    endIf
EndFunction

Int Function GetArgonianActiveFocus(Float peopleRelation, Float voidRelation, Bool voidActive)
    if voidActive && voidRelation > peopleRelation
        return Manager.ARGONIAN_FOCUS_VOID
    endIf

    return Manager.ARGONIAN_FOCUS_PEOPLE
EndFunction

String Function GetKhajiitFocusSymbol(Int focusValue)
    if focusValue == Manager.KHAJIIT_FOCUS_KHENARTHI
        return "khenarthi"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_AZURAH
        return "azura"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_BAANDAR
        return "baan-dar"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_RAJHIN
        return "rajhin"
    elseIf focusValue == Manager.KHAJIIT_FOCUS_ALKOSH
        return "alkosh"
    endIf
    return "lunar"
EndFunction

Function ApplyArgonianCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ShowArgonianMessage(Message messageRecord, String fallback, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal || !messageRecord
        Manager.SendPrismaToast("hist", "warning", "", fallback)
        return
    endIf

    messageRecord.Show()
EndFunction

Bool Function IsArgonianOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
EndFunction

Function EnsureArgonianHistSapToken()
    ; V1: grant the self-replenishing Hist Sap POTION (PDV_ALCH_ArgonianHistSap) rather than the old read
    ; BOOK. Drinking it routes Hist maintenance (see PDV_PotionArgonianHistSapEffect) and re-adds itself, so
    ; the player keeps one ritual vial. The book property stays declared but is no longer granted.
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ALCH_ArgonianHistSap
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if playerRef.GetItemCount(Manager.PDV_ALCH_ArgonianHistSap) <= 0
        playerRef.AddItem(Manager.PDV_ALCH_ArgonianHistSap, 1, True)
        StorageUtil.SetIntValue(None, "PDV.Token.ArgonianHistSap.Granted", 1)
        Manager.Trace(2, "Argonian Hist sap potion granted.")
    endIf
EndFunction

String Function GetKhajiitSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetKhajiitFocusStandingLine(Int focusValue)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetKhajiitLunarTierLabel(Int tierValue)
    if tierValue >= 3
        return "strong"
    elseIf tierValue == 2
        return "steady"
    elseIf tierValue == 1
        return "beginning"
    endIf

    return "quiet"
EndFunction

String Function GetArgonianSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetArgonianLayerStrengthLabel(Float value)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetArgonianVoidStrengthLabel(Float value)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetArgonianHistPostureLabel()
    if Manager.PDV_ArgonianHistSubstrate
        return Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel()
    endIf

    return "Missing"
EndFunction

String Function GetKhajiitLunarSummary()
    if !Manager.PDV_KhajiitLunarSubstrate
        return "missing"
    endIf

    return Manager.PDV_KhajiitLunarSubstrate.GetPilotSummary() + "; focus=" + GetKhajiitFocusLabel(GetKhajiitFocusedEmphasis()) + "; kh=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_KHENARTHI)) + "; az=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_AZURAH)) + "; bd=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_BAANDAR)) + "; rj=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_RAJHIN)) + "; ak=" + PDV_DevotionRules.FormatTwoDecimals(GetKhajiitFocusWeight(Manager.KHAJIIT_FOCUS_ALKOSH))
EndFunction

String Function GetArgonianHistSummary()
    if !Manager.PDV_ArgonianHistSubstrate
        return "missing"
    endIf

    return Manager.PDV_ArgonianHistSubstrate.GetPilotSummary()
EndFunction

Int Function GetKhajiitMoonPhaseFromGameDay(Float gameDay)
    Int phaseTest = (gameDay + 0.5) as Int
    phaseTest = phaseTest % 24
    if phaseTest < 0
        phaseTest += 24
    endIf

    if phaseTest >= 22 || phaseTest == 0
        return 1    ; Full Moon
    elseIf phaseTest < 4
        return 2    ; Waning Gibbous
    elseIf phaseTest < 7
        return 3    ; Last Quarter
    elseIf phaseTest < 10
        return 4    ; Waning Crescent
    elseIf phaseTest < 13
        return 5    ; New Moon
    elseIf phaseTest < 16
        return 6    ; Waxing Crescent
    elseIf phaseTest < 19
        return 7    ; First Quarter
    endIf

    return 8        ; Waxing Gibbous
EndFunction

; ============================================================================
; ORIGIN tranche 3: Breton (tradition/druidic/witchcraft/knightly-vow) +
; Redguard (sect/ancestor/Ash'abah/HoonDing/Leki/Tuwhacca) lanes. Moved
; verbatim from PDV__ManagerQuest; bare manager-member references qualified
; via Manager.; LedgerRuntime.X -> Manager.LedgerRuntime.X; reads of shared
; manager script vars route through manager accessors (GetActiveDeity,
; GetSuppressCurseTransitionOutputs, GetRaceCurseSurfaceShown,
; GetQrQueueTransactionActive, GetQrQueueNeedsBretonRewardSync); writes of
; _raceCurseSurfaceShown / _qrQueueNeedsBretonRewardSync route through their
; Set* accessors.
; ============================================================================

Function RemoveRedguardRememberSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell obs = GetRedguardRememberSpell(i)
        if obs && playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetRedguardRememberSpell(Int index)
    if index == 0
        return Manager.PDV_SPEL_RedguardRemember_Blade
    elseIf index == 1
        return Manager.PDV_SPEL_RedguardRemember_Road
    elseIf index == 2
        return Manager.PDV_SPEL_RedguardRemember_Rest
    elseIf index == 3
        return Manager.PDV_SPEL_RedguardRemember_Harvest
    endIf
    return None
EndFunction

Function SyncRedguardRemembering(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.RedRemember.Active")
    if active <= 0
        return
    endIf
    Spell obs = GetRedguardRememberSpell(active - 1)
    if !obs
        return
    endIf

    Int sectAtRite = StorageUtil.GetIntValue(None, "PDV.RedRemember.SectAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD) && IsRedguardRememberingCoherent(sectAtRite)
    if eligible
        if !playerRef.HasSpell(obs)
            playerRef.AddSpell(obs, False)
            Manager.SendPrismaToast("tuwhacca", "good", "The old line settles", "Your observance returns.")
        endIf
    else
        if playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
            Manager.SendPrismaToast("tuwhacca", "warning", "The observance goes quiet", "The line you named it under has shifted.")
        endIf
    endIf
EndFunction

Bool Function IsRedguardRememberingCoherent(Int sectAtRite)
    if !Manager.PDV_RedguardSectTrack
        return false
    endIf
    if Manager.PDV_RedguardSectTrack.GetCurrentState() != sectAtRite
        return false
    endIf
    return true
EndFunction

Function HandleLekiHonorableDuel(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleRedguardCrownTombRespect(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleRedguardAshAbahMajorBurden(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Actor victimActor = victimForm as Actor
    if !victimActor
        return
    endIf
    ActorBase victimBase = victimActor.GetLeveledActorBase()
    if !victimBase || !victimBase.IsUnique()
        return ; routine undead -- not a marked burden, no sect switch
    endIf

    String burdenReason = ""
    if eventType == 300 ; EVT_KILL_UNDEAD
        burdenReason = "redguard_deathduty_major"
    elseIf eventType == 2 && IsRedguardNamedNecromancerBurden(victimActor) ; EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
        burdenReason = "redguard_deathduty_major_necromancer"
    else
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahMajorBurden")
    if multiplier <= 0.0
        Manager.Trace(2, "Redguard Ash'abah major burden decayed out for today; no sect mark.")
        return
    endIf

    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Manager.Trace(2, "Redguard Ash'abah major burden fired: " + burdenReason + " marks sect entry (eventType=" + eventType + ").")
EndFunction

Function TrackRedguardAshAbahUndeadSiteVisit(Location currentLocation)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    if !currentLocation || !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(currentLocation)
        return
    endIf

    if currentLocation.IsCleared()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahClearSiteArmed." + currentLocation.GetFormID(), 1)
EndFunction

Function HandleRedguardAshAbahUndeadSiteClear(Location clearedLocation)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    if !clearedLocation || !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(clearedLocation)
        return
    endIf

    if !clearedLocation.IsCleared()
        return
    endIf

    String siteKey = "PDV.Redguard.AshAbahClearedSite." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, siteKey, 0) == 1
        return
    endIf

    String armKey = "PDV.Redguard.AshAbahClearSiteArmed." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, armKey, 0) != 1
        return
    endIf

    StorageUtil.SetIntValue(None, siteKey, 1)
    StorageUtil.SetIntValue(None, armKey, 0)
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahUndeadSiteClear")
    String burdenReason = "redguard_ashabah_burden_undead_site_clear"
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Manager.Trace(2, "Redguard Ash'abah undead-site clear fired for location " + clearedLocation.GetFormID() + " multiplier=" + multiplier)
EndFunction

Bool Function IsRedguardNamedNecromancerBurden(Actor victimActor)
    if !victimActor
        return False
    endIf

    if Manager.LedgerRuntime.NecromancerFaction && victimActor.IsInFaction(Manager.LedgerRuntime.NecromancerFaction)
        return True
    endIf

    if Manager.LedgerRuntime.WarlockFaction && victimActor.IsInFaction(Manager.LedgerRuntime.WarlockFaction)
        return True
    endIf

    return False
EndFunction

Function ApplyRedguardAshAbahDutyRewards(String reason, Float multiplier)
    AwardRedguardAshAbahSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    MarkRedguardAshAbahStigma(reason)
EndFunction

Function TryRedguardTuwhaccaDeathRiteHeal(String reason)
    if !Manager.PDV_Tuwhacca
        return
    endIf

    Int tuwhaccaTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca)
    if tuwhaccaTier < Manager.LedgerRuntime.TIER_DEVOTED
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        Manager.Trace(2, "Redguard Tu'whacca death-rite heal suppressed (already restored today).")
        return
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay")

    Float deathRiteHeal = 30.0
    if tuwhaccaTier >= Manager.LedgerRuntime.TIER_CHAMPION
        deathRiteHeal = 50.0
    endIf
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", deathRiteHeal)
    Manager.Trace(2, "Redguard Tu'whacca death-rite heal fired reason=" + reason + " tier=" + tuwhaccaTier + " restore=" + deathRiteHeal)
EndFunction

Function MarkRedguardAshAbahStigma(String reason)
    Int before = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    Int stigma = before + 1
    if stigma > 5
        stigma = 5
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahStigma", stigma)

    if before < 3 && stigma >= 3
        ShowRedguardNotification(None, "The tomb-smell never fully leaves you now; the clean keep their distance from the one who tends the unclean dead.")
    elseIf before < 1 && stigma >= 1
        ShowRedguardNotification(None, "The mark of the death-duty settles on you. Few will carry this burden, and they know it when they see you.")
    endIf
    Manager.Trace(2, "Redguard Ash'abah stigma marked reason=" + reason + " stigma=" + stigma + " (was " + before + ")")
EndFunction

String Function GetAshAbahStigmaLabel()
    Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    if stigma >= 3
        return "hollow-eyed"
    elseIf stigma >= 1
        return "death-touched"
    endIf
    return "unmarked"
EndFunction

Function HandleRedguardFarShoresToken(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleRedguardAncestorSpine(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RecordRedguardAncestorSpinePulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack || multiplier <= 0.0
        return
    endIf

    EnsureRedguardSectInitialized()
    Int currentSect = Manager.PDV_RedguardSectTrack.GetCurrentState()
    RecordRedguardSectSignal(currentSect, multiplier, reason)
    AwardRedguardAncestorSpinePietyPulse(multiplier, reason)
    ShowRedguardNotification(Manager.PDV_Notif_Redguard_AncestorSpine_Rest, "The ancestor-line steadies behind you.")
    Manager.RequestPanelRefresh()
EndFunction

Function HandleRedguardVampireReentryComplete(String reason)
    if !Manager.PDV_Tuwhacca || !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(Manager.PDV_Tuwhacca)
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_VAMPIRE_REENTRY, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Tuwhacca, "The cycle restored", "marks the return through Tu'whacca after the curse.")
    Manager.Trace(1, "Tu'whacca vampire re-entry completed (" + reason + ")")
EndFunction

Function RecordRedguardSectSignal(Int sectValue, Float multiplier, String reason)
    if !Manager.PDV_RedguardSectTrack
        return
    endIf

    if sectValue < Manager.REDGUARD_SECT_CROWN || sectValue > Manager.REDGUARD_SECT_ASHABAH
        return
    endIf

    EnsureRedguardSectInitialized()
    Manager.PDV_RedguardSectTrack.RecordEvidenceDay(sectValue, reason)
    StorageUtil.AdjustFloatValue(None, GetRedguardSectWeightKey(sectValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Redguard.LastSectSignal", sectValue)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf

    if multiplier <= 0.0
        return
    endIf

    if Manager.PDV_RedguardSectTrack.GetCurrentState() == sectValue
        MaybeShowRedguardChampionEntry(sectValue)
        SendPrismaSubstrateToast("sect", "act", "The Yokudan path was marked.", "sect", GetRedguardSectLabel())
        Manager.AppendBookOfDaysEntry("The Yokudan path was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "sect", False)
        Manager.RequestPanelRefresh()
        return
    endIf

    ; LOCKED sect-switch rule: Crown <-> Forebear needs two sect-coded evidence days
    ; inside seven, then a three-day lock-in -- one tomb visit no longer rewrites
    ; sect identity. Ash'abah is entered only by a marked death/funerary burden
    ; (casual undead fighting is not enough), and left by a Crown/Forebear switch.
    Bool allowSwitch = False
    if sectValue == Manager.REDGUARD_SECT_ASHABAH
        allowSwitch = IsRedguardAshAbahBurden(reason)
    else
        allowSwitch = Manager.PDV_RedguardSectTrack.HasRecentEvidenceDays(sectValue, 2, 7) && !Manager.PDV_RedguardSectTrack.IsTransitionLockedOut()
    endIf

    if allowSwitch
        Manager.PDV_RedguardSectTrack.SetState(sectValue, reason)
        Manager.PDV_RedguardSectTrack.SetTransitionLockout(3.0, reason)
        ShowRedguardSectEntry(sectValue)
        MaybeShowRedguardChampionEntry(sectValue)
        Manager.SurfaceTransition("reorientation", GetRedguardSectLabel(), "shift", -1, "turning")
        Manager.SendPrismaShiftToast(GetRedguardSectLabel(), "", "sect")
        Manager.RequestPanelRefresh()
    endIf
EndFunction

Bool Function IsRedguardAshAbahBurden(String reason)
    ; Token-contains, not exact-match: a marked-burden emit site may append a source
    ; suffix (e.g. "redguard_deathduty_major_krosis"), and the exact-match form was the
    ; original silent gap (gate correct, token never produced). Suffix/omission-proof per
    ; the P2 book-notice fix.
    return PDV_DevotionRules.StringContainsToken(reason, "redguard_deathduty_major") || PDV_DevotionRules.StringContainsToken(reason, "redguard_ashabah_burden")
EndFunction

Function AwardRedguardCrownSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_CROWN_FORM, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "crown_tomb_" + reason)
EndFunction

Function AwardRedguardForebearSignal(Float multiplier)
    ; Road-passage is the Forebear lane's own beat: the Forebear sect substrate credit
    ; is recorded by the caller (RecordRedguardSectSignal). HoonDing's make-way no
    ; longer rides road-passage -- it now fires on curated BREAKTHROUGH kills
    ; (HandleHoonDingBreakthroughKill), so the old blunt weekly cap is retired. Leki's
    ; sword-singing remains the focused-patron beat on the road.
    if Manager.GetActiveDeity() == Manager.PDV_Leki && Manager.PDV_Leki
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Leki, Manager.PDV_Leki.SIGNAL_SWORD_SINGING, None, multiplier)
    endIf
EndFunction

Function HandleHoonDingBreakthroughKill(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !Manager.PDV_HoonDing
        return
    endIf
    if Manager.GetActiveDeity() != Manager.PDV_HoonDing
        return
    endIf

    Bool dragonKill = eventType == 302 ; EVT_KILL_DRAGON
    Bool listedBossKill = False
    if !dragonKill && Manager.PDV_FLST_HoonDing_BreakthroughBosses
        Actor victimActor = victimForm as Actor
        if victimActor
            ActorBase victimBase = victimActor.GetLeveledActorBase()
            if victimBase && Manager.PDV_FLST_HoonDing_BreakthroughBosses.HasForm(victimBase)
                listedBossKill = True
            endIf
        endIf
    endIf

    if !dragonKill && !listedBossKill
        return
    endIf

    String repeatKey = "PDV.Signal.HoonDingDragon"
    String traceLabel = "dragon"
    if listedBossKill
        repeatKey = "PDV.Signal.HoonDingBreakthroughBoss"
        traceLabel = "listed boss"
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier(repeatKey)
    if multiplier <= 0.0
        Manager.Trace(2, "HoonDing make-way (" + traceLabel + ") decayed out for today; no award.")
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_HoonDing, Manager.PDV_HoonDing.SIGNAL_MAKE_WAY, victimForm, multiplier)
    Manager.Trace(2, "HoonDing make-way fired: breakthrough " + traceLabel + " kill multiplier=" + multiplier)
EndFunction

Function AwardRedguardAshAbahSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "ashabah_death_duty_" + reason)
EndFunction

Function AwardRedguardFarShoresSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "far_shores_" + reason)
EndFunction

Function AwardRedguardAncestorSpinePietyPulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || multiplier <= 0.0
        return
    endIf

    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastAncestorSpineSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastAncestorSpineSourceTime", Utility.GetCurrentGameTime())
EndFunction

Function EnsureRedguardSectInitialized()
    if !Manager.PDV_RedguardSectTrack
        return
    endIf

    if IsRedguardOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if Manager.PDV_RedguardSectTrack.GetCurrentState() < Manager.REDGUARD_SECT_CROWN
        Manager.PDV_RedguardSectTrack.SetState(Manager.REDGUARD_SECT_FOREBEAR, "redguard_default_forebear")
    endIf
EndFunction

Bool Function IsRedguardOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD
EndFunction

String Function GetRedguardSectWeightKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.Sect.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.Sect.AshAbah"
    endIf

    return "PDV.Redguard.Sect.Forebear"
EndFunction

String Function GetRedguardSectLabel()
    if !Manager.PDV_RedguardSectTrack
        return "Sect missing"
    endIf

    EnsureRedguardSectInitialized()
    return Manager.PDV_RedguardSectTrack.GetStateLabel()
EndFunction

Function ShowRedguardSectEntry(Int sectValue)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    String shownKey = GetRedguardSectEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == Manager.REDGUARD_SECT_CROWN
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_Crown_Entry, "You hold the Crown way: orthodoxy kept, the old inheritance intact.")
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_Forebear_Entry, "You hold the Forebear way: Redguard identity carried among outsiders.")
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_AshAbah_Entry, "You take up the Ash'abah duty: the unclean work others will not touch.")
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
EndFunction

String Function GetRedguardSectEntryShownKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.SectEntryShown.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.SectEntryShown.Forebear"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.SectEntryShown.AshAbah"
    endIf

    return ""
EndFunction

Function MaybeShowRedguardChampionEntry(Int sectValue)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    String shownKey = GetRedguardChampionEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == Manager.REDGUARD_SECT_CROWN
        if Manager.PDV_Tuwhacca && Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_Crown, "The Crown way has become more than memory. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Crown way is more than memory in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        if Manager.PDV_HoonDing && Manager.LedgerRuntime.GetTier(Manager.PDV_HoonDing) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_Forebear, "The Forebear way has become more than adaptation. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        if Manager.PDV_Tuwhacca && Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_AshAbah, "The Ash'abah duty has become more than necessity. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Ash'abah duty, made public.", "More than necessity now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    endIf
EndFunction

String Function GetRedguardChampionEntryShownKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.ChampionEntryShown.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.ChampionEntryShown.Forebear"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.ChampionEntryShown.AshAbah"
    endIf

    return ""
EndFunction

Function SyncBretonAncestorSubstrate(Actor playerRef, Bool isBreton)
    if !playerRef || !Manager.PDV_BretonAncestorSubstrate
        return
    endIf

    if isBreton
        Manager.Trace(2, "Breton ancestor substrate retired; clearing legacy boons.")
    endIf
    Manager.PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
EndFunction

Function SyncBretonTraditionRewardFamily(Actor playerRef, Int thisTradition, Int activeTradition, Spell t1, Spell t2, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON && thisTradition == activeTradition
    if thisTradition == Manager.BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        isActive = False
    endIf

    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    PDV_DeityBase presentationDeity = None
    if isActive
        activeTier = GetBretonTraditionTier(thisTradition)
        presentationDeity = GetBretonTraditionPresentationDeity(thisTradition)
    endIf

    Bool hadT1Spell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t1)
    Bool hadT2Spell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t2)
    Bool wantsT1Spell = isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER
    Bool championReplacesT2 = isActive && IsBretonPracticeTierReplacedByChampion(thisTradition)
    Bool wantsT2Spell = isActive && activeTier >= Manager.LedgerRuntime.TIER_DEVOTED && !championReplacesT2
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, wantsT1Spell, "Breton " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, wantsT2Spell, "Breton " + label + " T2")
    MaybeShowBretonTraditionRewardPresentation(playerRef, t1, hadT1Spell, wantsT1Spell, presentationDeity, label, Manager.LedgerRuntime.TIER_SEEKER)
    MaybeShowBretonTraditionRewardPresentation(playerRef, t2, hadT2Spell, wantsT2Spell, presentationDeity, label, Manager.LedgerRuntime.TIER_DEVOTED)
EndFunction

Bool Function IsBretonPracticeTierReplacedByChampion(Int traditionValue)
    PDV_DeityBase championSource = GetBretonChampionSource(True, traditionValue)
    if !championSource
        return False
    endIf

    Spell championSpell = GetBretonPatronChampionBoon(championSource, traditionValue)
    Spell traditionChampionSpell = None
    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        traditionChampionSpell = Manager.PDV_Bless_Breton_KnightsRoad_T3
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        traditionChampionSpell = Manager.PDV_Bless_Breton_HiddenArt_T3
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        traditionChampionSpell = Manager.PDV_Bless_Breton_GreenWay_T3
    endIf

    return championSpell && traditionChampionSpell && championSpell == traditionChampionSpell
EndFunction

PDV_DeityBase Function GetBretonChampionSource(Bool isBreton, Int traditionValue)
    if isBreton && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() && Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity()) >= Manager.LedgerRuntime.TIER_CHAMPION
        return Manager.GetActiveDeity()
    endIf
    if isBreton && traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
        if activePact && activePact.GetStoredTier() >= Manager.LedgerRuntime.TIER_CHAMPION
            return activePact
        endIf
    endIf
    return None
EndFunction

Function SyncBretonChampionBoon(Actor playerRef, Bool isBreton, Int traditionValue)
    Spell wantSpell = None
    PDV_DeityBase championSource = GetBretonChampionSource(isBreton, traditionValue)
    if championSource
        wantSpell = GetBretonPatronChampionBoon(championSource, traditionValue)
    endIf

    Bool hadWanted = wantSpell && Manager.LedgerRuntime.HasRewardSpell(playerRef, wantSpell)
    SyncBretonChampionBoonExclusive(playerRef, wantSpell)
    MaybeShowBretonChampionBoonPresentation(playerRef, wantSpell, hadWanted, traditionValue, championSource)
EndFunction

Function SyncBretonChampionBoonExclusive(Actor playerRef, Spell wantSpell)
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_KnightsRoad_T3, wantSpell == Manager.PDV_Bless_Breton_KnightsRoad_T3, "Breton Champion Stendarr")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_GreenWay_T3, wantSpell == Manager.PDV_Bless_Breton_GreenWay_T3, "Breton Champion Yffre")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_HiddenArt_T3, wantSpell == Manager.PDV_Bless_Breton_HiddenArt_T3, "Breton Champion HiddenArt")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Mara, wantSpell == Manager.PDV_Bless_Breton_Champion_Mara, "Breton Champion Mara")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Arkay, wantSpell == Manager.PDV_Bless_Breton_Champion_Arkay, "Breton Champion Arkay")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Akatosh, wantSpell == Manager.PDV_Bless_Breton_Champion_Akatosh, "Breton Champion Akatosh")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Julianos, wantSpell == Manager.PDV_Bless_Breton_Champion_Julianos, "Breton Champion Julianos")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Kynareth, wantSpell == Manager.PDV_Bless_Breton_Champion_Kynareth, "Breton Champion Kynareth")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Dibella, wantSpell == Manager.PDV_Bless_Breton_Champion_Dibella, "Breton Champion Dibella")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Zenithar, wantSpell == Manager.PDV_Bless_Breton_Champion_Zenithar, "Breton Champion Zenithar")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Talos, wantSpell == Manager.PDV_Bless_Breton_Champion_Talos, "Breton Champion Talos")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Champion_Magnus, wantSpell == Manager.PDV_Bless_Breton_Champion_Magnus, "Breton Champion Magnus")
EndFunction

Spell Function GetBretonPatronChampionBoon(PDV_DeityBase deity, Int traditionValue)
    if !deity
        return None
    endIf
    if deity == Manager.LedgerRuntime.PDV_Stendarr
        return Manager.PDV_Bless_Breton_KnightsRoad_T3
    elseIf deity == Manager.PDV_Yffre
        return Manager.PDV_Bless_Breton_GreenWay_T3
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return Manager.PDV_Bless_Breton_Champion_Mara
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return Manager.PDV_Bless_Breton_Champion_Arkay
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return Manager.PDV_Bless_Breton_Champion_Akatosh
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return Manager.PDV_Bless_Breton_Champion_Julianos
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return Manager.PDV_Bless_Breton_Champion_Kynareth
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return Manager.PDV_Bless_Breton_Champion_Dibella
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return Manager.PDV_Bless_Breton_Champion_Zenithar
    elseIf deity == Manager.PDV_Talos
        return Manager.PDV_Bless_Breton_Champion_Talos
    elseIf deity == Manager.PDV_Magnus
        return Manager.PDV_Bless_Breton_Champion_Magnus
    endIf

    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if path && traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        return Manager.PDV_Bless_Breton_HiddenArt_T3
    endIf
    return None
EndFunction

String Function GetBretonChampionBoonDisplayName(PDV_DeityBase deity)
    if deity == Manager.LedgerRuntime.PDV_Stendarr
        return "Knight's Bulwark - Champion"
    elseIf deity == Manager.PDV_Yffre
        return "Green Way - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return "Mara's Compassion - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return "Arkay's Ward - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return "Akatosh's Endurance - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return "Julianos's Insight - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return "Kynareth's Sky - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return "Dibella's Inspiration - Champion"
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return "Zenithar's Prosperity - Champion"
    elseIf deity == Manager.PDV_Talos
        return "Talos's Triumph - Champion"
    elseIf deity == Manager.PDV_Magnus
        return "Magnus's Aperture - Champion"
    endIf

    if deity as PDV_DaedricPathBase
        return "Hidden Art - Champion"
    endIf
    return "Champion blessing"
EndFunction

Function MaybeShowBretonChampionBoonPresentation(Actor playerRef, Spell wantSpell, Bool hadWanted, Int traditionValue, PDV_DeityBase championSource)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !wantSpell || !championSource || !playerRef.HasSpell(wantSpell)
        return
    endIf

    ; The Prince milestone path already owns its toast and Book entry. Hidden Art's
    ; practitioner capstone is an additional reward, not a second tier announcement.
    if championSource as PDV_DaedricPathBase
        return
    endIf

    String deityName = Manager.GetPublicDeityDisplayName(championSource)
    String shownKey = "PDV.Breton.ChampionBoonNoticeShown." + deityName
    if hadWanted && StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    String traditionLabel = GetBretonTraditionLabel()
    String symbolName = Manager.GetPrismaSymbolForDeity(championSource)
    String titleText = deityName + " names you Champion"
    String line = deityName + " names you Champion."
    if IsBretonResonantPatronChampion(traditionValue)
        line = deityName + " names you Champion through the " + traditionLabel + "."
    endIf
    if Manager.LedgerRuntime.NotifyTierUp(championSource, Manager.LedgerRuntime.TIER_CHAMPION)
        Manager.Trace(2, "Breton champion boon marked generic tier guard: " + deityName)
    endIf
    Manager.SendPrismaToast(symbolName, "good", titleText, line)
    Manager.AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, True, Manager.LedgerRuntime.TIER_CHAMPION, titleText)
    Manager.Trace(1, "Breton champion boon presentation shown: " + deityName + " / " + traditionLabel)
EndFunction

Function MaybeShowBretonTraditionRewardPresentation(Actor playerRef, Spell rewardSpell, Bool hadSpell, Bool wantsSpell, PDV_DeityBase deity, String traditionLabel, Int tierValue)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !rewardSpell || !wantsSpell || !playerRef.HasSpell(rewardSpell)
        return
    endIf

    String displayLabel = GetBretonTraditionRewardDisplayLabel(traditionLabel)
    String shownKey = "PDV.Breton.TraditionRewardNoticeShown." + displayLabel + "." + tierValue
    if hadSpell && StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    String tierLabel = Manager.GetTierStandingLabel(tierValue)
    String symbolName = Manager.GetPrismaSymbolForDeity(deity)
    String titleText = displayLabel + " deepens"
    String line = "The " + displayLabel + " names you " + tierLabel + "."
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION && deity
        String deityName = Manager.GetPublicDeityDisplayName(deity)
        titleText = deityName + " names you " + tierLabel
        line = deityName + " names you " + tierLabel + " through the " + displayLabel + "."
        if Manager.LedgerRuntime.NotifyTierUp(deity, tierValue)
            Manager.Trace(2, "Breton focused Champion marked generic tier guard: " + deity.DeityName)
        endIf
    endIf
    Manager.SendPrismaToast(symbolName, "good", titleText, line)
    Manager.AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, tierValue >= Manager.LedgerRuntime.TIER_CHAMPION, tierValue, titleText)
EndFunction

String Function GetBretonTraditionRewardDisplayLabel(String label)
    if label == "KnightsRoad"
        return "Knight's Road"
    elseIf label == "HiddenArt"
        return "Hidden Art"
    elseIf label == "GreenWay"
        return "Green Way"
    endIf
    return label
EndFunction

Int Function GetBretonTraditionTier(Int traditionValue)
    return GetBretonPracticeTier(traditionValue)
EndFunction

Int Function GetBretonPracticeTier(Int traditionValue)
    Int practiceCount = GetBretonPracticeCount(traditionValue)
    if practiceCount >= Manager.BRETON_PRACTICE_DEVOTED_POINTS
        return Manager.LedgerRuntime.TIER_DEVOTED
    elseIf practiceCount >= Manager.BRETON_PRACTICE_SEEKER_POINTS
        return Manager.LedgerRuntime.TIER_SEEKER
    endIf
    return Manager.LedgerRuntime.TIER_NONE
EndFunction

Int Function GetBretonPracticeCount(Int traditionValue)
    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        return StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowCount")
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        return StorageUtil.GetIntValue(None, "PDV.Breton.HiddenArtCount")
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        return StorageUtil.GetIntValue(None, "PDV.Breton.GreenWayCount")
    endIf
    return 0
EndFunction

Function SetBretonPracticeCount(Int traditionValue, Int practicePoints)
    Int normalizedPoints = PDV_DevotionRules.ClampInt(practicePoints, 0, Manager.BRETON_PRACTICE_DEVOTED_POINTS)
    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowCount", normalizedPoints)
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        StorageUtil.SetIntValue(None, "PDV.Breton.HiddenArtCount", normalizedPoints)
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        StorageUtil.SetIntValue(None, "PDV.Breton.GreenWayCount", normalizedPoints)
    endIf
EndFunction

Bool Function IsBretonResonantPatronChampion(Int traditionValue)
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE || !Manager.GetActiveDeity()
        return False
    endIf
    if Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity()) < Manager.LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    return IsDeityResonantWithBretonTradition(traditionValue, Manager.GetActiveDeity())
EndFunction

Bool Function IsDeityResonantWithBretonTradition(Int traditionValue, PDV_DeityBase deity)
    if !deity
        return False
    endIf
    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        return deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.PDV_Talos || deity == Manager.LedgerRuntime.PDV_Kynareth
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        return deity == Manager.PDV_Yffre || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Kynareth || deity == Manager.LedgerRuntime.PDV_Dibella
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
        if path
            return True
        endIf
        return deity == Manager.PDV_Magnus || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Dibella
    endIf
    return False
EndFunction

PDV_DeityBase Function GetBretonTraditionPresentationDeity(Int traditionValue)
    if IsBretonResonantPatronChampion(traditionValue)
        return Manager.GetActiveDeity()
    endIf
    return GetBretonTraditionDeity(traditionValue)
EndFunction

Int Function GetBretonTraditionValue()
    Int traditionValue = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if traditionValue >= Manager.BRETON_TRADITION_KNIGHTS_ROAD && traditionValue <= Manager.BRETON_TRADITION_GREEN_WAY
        return traditionValue
    endIf

    return Manager.BRETON_TRADITION_KNIGHTS_ROAD
EndFunction

PDV_DeityBase Function GetBretonTraditionDeity(Int traditionValue)
    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        return Manager.LedgerRuntime.PDV_Stendarr
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        return Manager.PDV_Magnus
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        return Manager.PDV_Yffre
    endIf

    return None
EndFunction

Int Function GetBretonDruidicForkValue()
    Int forkValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicFork", Manager.BRETON_DRUIDIC_FORK_NONE)
    if forkValue >= Manager.BRETON_DRUIDIC_FORK_NONE && forkValue <= Manager.BRETON_DRUIDIC_FORK_BETRAYED
        return forkValue
    endIf

    return Manager.BRETON_DRUIDIC_FORK_NONE
EndFunction

Function SetBretonDruidicFork(Int forkValue, String reason)
    Int oldFork = GetBretonDruidicForkValue()
    Int normalized = PDV_DevotionRules.ClampInt(forkValue, Manager.BRETON_DRUIDIC_FORK_NONE, Manager.BRETON_DRUIDIC_FORK_BETRAYED)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicFork", normalized)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastDruidicForkReason", reason)
    if Manager.PDV_GLO_State_BretonDruidicFork
        Manager.PDV_GLO_State_BretonDruidicFork.SetValue(normalized as Float)
    endIf
    if GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON && oldFork != normalized
        SurfaceBretonDruidicForkChange(normalized)
    endIf
EndFunction

Function SurfaceBretonDruidicForkChange(Int forkValue)
    if forkValue == Manager.BRETON_DRUIDIC_FORK_WEREWOLF
        Manager.SendPrismaShiftToast("The Green Way turns wild in you.", "", "kynareth")
        Manager.AppendBookOfDaysEntry("The beast-blood took your Green Way down a wilder road. The Werewolf path is yours now.", Utility.GetCurrentGameTime() as Int, "reorientation", "kynareth", False, 3)
    elseIf forkValue == Manager.BRETON_DRUIDIC_FORK_BETRAYED
        Manager.SendPrismaShiftToast("You broke faith with the Green.", "", "kynareth")
        Manager.AppendBookOfDaysEntry("You turned from the Green Way's trust. The path remembers the betrayal.", Utility.GetCurrentGameTime() as Int, "reorientation", "kynareth", False, 3)
    endIf
EndFunction

Function EnsureBretonDruidicForkInitialized()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return
    endIf

    Int current = GetBretonDruidicForkValue()
    if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicForkInitialized") != 1
        if GetBretonTraditionValue() == Manager.BRETON_TRADITION_GREEN_WAY
            SetBretonDruidicFork(Manager.BRETON_DRUIDIC_FORK_DRUIDIC, "breton_greenway_default")
        else
            SetBretonDruidicFork(current, "breton_non_greenway_default")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    elseIf Manager.PDV_GLO_State_BretonDruidicFork
        Manager.PDV_GLO_State_BretonDruidicFork.SetValue(current as Float)
    endIf
EndFunction

Bool Function IsBretonGreenWayForkEligible()
    if GetBretonTraditionValue() != Manager.BRETON_TRADITION_GREEN_WAY
        return False
    endIf

    return GetBretonDruidicForkValue() == Manager.BRETON_DRUIDIC_FORK_DRUIDIC
EndFunction

Function SyncBretonKnightlyVowCreedLossSpells(Bool isKnightsRoadBreton)
    Int integrityValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
    Bool isStrained = isKnightsRoadBreton && integrityValue >= 30 && integrityValue < 70
    Bool isBroken = isKnightsRoadBreton && integrityValue < 30

    SyncBretonCreedLossSpell(Manager.PDV_SPEL_CreedLoss_Breton_VowIntegrity, isStrained, "PDV.CreedLoss.BretonVowIntegrityActive", "The vow strains. Mercy and the shield come harder now.")
    SyncBretonCreedLossSpell(Manager.PDV_SPEL_CreedLoss_Breton_Excommunication, isBroken, "PDV.CreedLoss.BretonExcommunicationActive", "The vow breaks. The Knight's Road is halted until repair.")
EndFunction

Function SyncBretonWitchcraftExposureRuptureSpell(Bool isBreton)
    Bool isRuptured = isBreton && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
    SyncBretonCreedLossSpell(Manager.PDV_SPEL_CreedLoss_Breton_ExposureRupture, isRuptured, "PDV.CreedLoss.BretonExposureRuptureActive", "Your cover is blown. The hidden art turns against you.")
EndFunction

Function SyncBretonCreedLossSpell(Spell creedLossSpell, Bool shouldBeActive, String stateKey, String noticeText = "")
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !creedLossSpell
        StorageUtil.SetIntValue(None, stateKey, 0)
        return
    endIf

    if shouldBeActive
        Bool wasActive = StorageUtil.GetIntValue(None, stateKey) == 1
        if !playerRef.HasSpell(creedLossSpell)
            playerRef.AddSpell(creedLossSpell, False)
        endIf
        if !wasActive && noticeText != ""
            Manager.SendPrismaToast("journal", "warning", "Creed strained", noticeText)
        endIf
        StorageUtil.SetIntValue(None, stateKey, 1)
    else
        if playerRef.HasSpell(creedLossSpell)
            playerRef.RemoveSpell(creedLossSpell)
        endIf
        StorageUtil.SetIntValue(None, stateKey, 0)
    endIf
EndFunction

Function SyncBretonDruidicForkBetrayalSpell(Bool shouldBeActive)
    SyncBretonCreedLossSpell(Manager.PDV_SPEL_CreedLoss_Breton_DruidicForkBetrayal, shouldBeActive, "PDV.CreedLoss.BretonDruidicForkBetrayalActive", "The Green has turned against the broken trust.")
EndFunction

Function SyncRedguardSpineBoon(Actor playerRef, Bool isRedguard, Int sectValue)
    if !playerRef
        return
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_Crown, isRedguard && sectValue == Manager.REDGUARD_SECT_CROWN, "Redguard Spine Crown")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_Forebear, isRedguard && sectValue == Manager.REDGUARD_SECT_FOREBEAR, "Redguard Spine Forebear")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_AshAbah, isRedguard && sectValue == Manager.REDGUARD_SECT_ASHABAH, "Redguard Spine AshAbah")
EndFunction

Int Function GetActiveRedguardSpineSect()
    if Manager.PDV_RedguardSectTrack
        EnsureRedguardSectInitialized()
        Int sectValue = Manager.PDV_RedguardSectTrack.GetCurrentState()
        if sectValue >= Manager.REDGUARD_SECT_CROWN && sectValue <= Manager.REDGUARD_SECT_ASHABAH
            return sectValue
        endIf
    endIf

    return Manager.REDGUARD_SECT_FOREBEAR
EndFunction

Function SyncRedguardRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Redguard " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Redguard " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Redguard " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Redguard " + label)
EndFunction

Function EmitRedguardDeathDutyAbandonmentMinus(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_Tuwhacca
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardDeathDutyAbandonment")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.DeathDutyAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastDeathDutyAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastDeathDutyAbandonmentTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Redguard death-duty abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

Message Function GetBretonFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Message Function GetRedguardFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function ShouldSuppressBretonFocusedChampionTierSurface(PDV_DeityBase deity, Int newTier)
    if newTier < Manager.LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE || !Manager.GetActiveDeity() || deity != Manager.GetActiveDeity()
        return False
    endIf

    return IsDeityResonantWithBretonTradition(GetBretonTraditionValue(), deity)
EndFunction

Function ApplyBretonCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ApplyRedguardCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function ShouldSuppressRedguardCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowRedguardNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("tuwhacca", "neutral", "", fallbackText)
EndFunction

Function ShowRedguardMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("tuwhacca", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyBretonInitialChoice(Int traditionValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBretonTraditionChoice(Int traditionValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function DecayBretonWitchcraftExposureAtDawn()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function DecayBretonDruidicStandingAtDawn()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function ShouldBretonDruidicStandingFray()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != Manager.BRETON_TRADITION_GREEN_WAY
        return False
    endIf
    return GetBretonDruidicForkValue() != Manager.BRETON_DRUIDIC_FORK_BETRAYED
EndFunction

Function AwardBretonAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return
    endIf

    Manager.Trace(2, "Retired Breton ancestor spine signal ignored: " + reason + " x" + multiplier)
EndFunction

Function RunDawnRefreshBretonAncestor()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBretonActionPracticeSignal(Int eventType, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return
    endIf

    String sourceKey = "event_" + eventType
    if eventType == 350 || eventType == 351
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_KNIGHTS_ROAD, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 300 || eventType == 301
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_KNIGHTS_ROAD, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 304 || eventType == 364 || eventType == 362 || eventType == 366
        DamageBretonPracticePressure(Manager.BRETON_TRADITION_KNIGHTS_ROAD, 10, sourceKey, reason)
    endIf

    if eventType == 313 || eventType == 334 || eventType == 303 || eventType == 333 || eventType == 300
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_GREEN_WAY, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 365 || eventType == 331 || eventType == 364
        DamageBretonPracticePressure(Manager.BRETON_TRADITION_GREEN_WAY, 10, sourceKey, reason)
    endIf

    if eventType == 341 || eventType == 342
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 331
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    elseIf eventType == 333 || eventType == 314
        AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, sourceKey, reason)
    endIf
EndFunction

Function HandleBretonQuestTagPracticeSignal(String sourceTag, Bool positive, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON || sourceTag == ""
        return
    endIf

    String sourceKey = "tag_" + sourceTag
    if positive
        if sourceTag == "mercy_spare" || sourceTag == "protect_the_weak" || sourceTag == "uphold_law_justice" || sourceTag == "keep_oath"
            AwardBretonPracticePulse(Manager.BRETON_TRADITION_KNIGHTS_ROAD, Manager.BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        elseIf sourceTag == "honor_the_wild" || sourceTag == "the_hunt"
            AwardBretonPracticePulse(Manager.BRETON_TRADITION_GREEN_WAY, Manager.BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        elseIf sourceTag == "forbidden_knowledge"
            AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_CURATED_POINTS, sourceKey, reason)
        endIf
    else
        if sourceTag == "kill_the_helpless" || sourceTag == "murder_treacherous"
            DamageBretonPracticePressure(Manager.BRETON_TRADITION_KNIGHTS_ROAD, 12, sourceKey, reason)
        elseIf sourceTag == "defile_nature" || sourceTag == "necromancy"
            DamageBretonPracticePressure(Manager.BRETON_TRADITION_GREEN_WAY, 12, sourceKey, reason)
        elseIf sourceTag == "reckless_magic"
            DamageBretonPracticePressure(Manager.BRETON_TRADITION_HIDDEN_ART, 12, sourceKey, reason)
        endIf
    endIf
EndFunction

Int Function ConsumeBretonPracticePointBudget(Int requestedPoints)
    if requestedPoints <= 0
        return 0
    endIf

    ; fix-plan 4.2: the practice-point budget is a daily cap; devotional day.
    Int today = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int budgetDay = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointDay", -1)
    if budgetDay != today
        StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointDay", today)
        StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", 0)
    endIf

    Int pointsToday = StorageUtil.GetIntValue(None, "PDV.Breton.PracticePointsToday")
    Int remaining = Manager.BRETON_PRACTICE_DAILY_MAX_POINTS - pointsToday
    if remaining <= 0
        return 0
    endIf

    Int appliedPoints = requestedPoints
    if appliedPoints > remaining
        appliedPoints = remaining
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.PracticePointsToday", pointsToday + appliedPoints)
    return appliedPoints
EndFunction

Bool Function AwardBretonPracticePulse(Int traditionValue, Int requestedPoints, String sourceKey, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != traditionValue
        return False
    endIf
    if traditionValue == Manager.BRETON_TRADITION_GREEN_WAY && !IsBretonGreenWayForkEligible()
        return False
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.BretonPractice." + traditionValue + "." + sourceKey)
        return False
    endIf

    Int appliedPoints = ConsumeBretonPracticePointBudget(requestedPoints)
    if appliedPoints <= 0
        Manager.Trace(2, "Breton practice daily cap blocked " + sourceKey + ": " + reason)
        return False
    endIf

    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
        StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", PDV_DevotionRules.ClampInt(exposureValue + appliedPoints, 0, 100))
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastHiddenArtReason", reason)
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        EnsureBretonDruidicForkInitialized()
        Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", PDV_DevotionRules.ClampInt(standingValue + appliedPoints, 0, 100))
        SetBretonPracticeCount(traditionValue, GetBretonPracticeCount(traditionValue) + appliedPoints)
        StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive()
        Manager.PDV_QuestReactionRuntimeService.SetQrQueueNeedsBretonRewardSync(True)
    else
        Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        Manager.RequestPanelRefresh()
    endIf
    Manager.Trace(2, "Breton practice pulse " + traditionValue + " +" + appliedPoints + " from " + sourceKey + ": " + reason)
    return True
EndFunction

Bool Function DamageBretonPracticePressure(Int traditionValue, Int damageDelta, String sourceKey, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf
    if GetBretonTraditionValue() != traditionValue
        return False
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.BretonPracticeDamage." + traditionValue + "." + sourceKey)
        return False
    endIf

    if traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD
        Int vowValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        StorageUtil.SetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", PDV_DevotionRules.ClampInt(vowValue - damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    elseIf traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART
        Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
        StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", PDV_DevotionRules.ClampInt(exposureValue + damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastHiddenArtReason", reason)
    elseIf traditionValue == Manager.BRETON_TRADITION_GREEN_WAY
        EnsureBretonDruidicForkInitialized()
        Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", PDV_DevotionRules.ClampInt(standingValue - damageDelta, 0, 100))
        StorageUtil.SetStringValue(None, "PDV.Breton.LastGreenWayReason", reason)
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    if Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive()
        Manager.PDV_QuestReactionRuntimeService.SetQrQueueNeedsBretonRewardSync(True)
    else
        Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        Manager.RequestPanelRefresh()
    endIf
    Manager.Trace(2, "Breton practice pressure " + traditionValue + " from " + sourceKey + ": " + reason)
    return True
EndFunction

Function MaybeRecordBretonCrossTraditionPressure(Int sourceTradition, String sourceKey, String reason)
    if StorageUtil.GetIntValue(None, "PDV.Breton.SetupComplete") != 1
        return
    endIf
    if GetBretonTraditionValue() == sourceTradition
        return
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.BretonCrossTradition." + sourceTradition + "." + sourceKey)
        return
    endIf

    StorageUtil.AdjustIntValue(None, "PDV.Breton.CrossTraditionPressure", 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
EndFunction

Function HandleBretonKnightlyVow(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleBretonHiddenArtExposure(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetBretonHiddenArtNoticeTitle(String reason)
    if PDV_DevotionRules.StringContainsToken(reason, "hagravens")
        return "Hagraven lore"
    elseIf PDV_DevotionRules.StringContainsToken(reason, "madmen_reach")
        return "Reach-mad whispers"
    elseIf PDV_DevotionRules.StringContainsToken(reason, "witch_note")
        return "A witch's note"
    endIf

    return "The Hidden Art"
EndFunction

String Function GetBretonHiddenArtNoticeText(String reason)
    if PDV_DevotionRules.StringContainsToken(reason, "hagravens")
        return "Old bargains leave a mark on your cover."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "madmen_reach")
        return "Forbidden Reach lore stirs your hidden practice."
    elseIf PDV_DevotionRules.StringContainsToken(reason, "witch_note")
        return "A private craft presses closer to the surface."
    endIf

    return "Forbidden pages leave their mark on you."
EndFunction

Function HandleBretonGreenWayStanding(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetRedguardSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetRedguardSurveySectText()
    Int sectValue = Manager.REDGUARD_SECT_FOREBEAR
    if Manager.PDV_RedguardSectTrack
        sectValue = Manager.PDV_RedguardSectTrack.GetCurrentState()
    endIf

    String standing = Manager.GetCurrentStandingBand()
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "You keep the Crown way: orthodox Yokudan practice carried intact in exile. Standing: " + standing + ". The ancestors are strong at your back."
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        String ashText = "You keep the Ash'abah duty: the unclean dead are your charge. Standing: " + standing + ". Tu'whacca honors the burden few will."
        ashText = ashText + " The duty hardens you against death and plague, but it cools your welcome among the living (Speech -5)."
        Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
        if stigma >= 3
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the clean turn their faces, and the living keep their distance from the death-handler."
        elseIf stigma >= 1
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the mark of the duty is on you, and the squeamish step wide."
        endIf
        return ashText
    endIf

    return "You keep the Forebear way: Redguard identity lived among outsiders. Standing: " + standing + ". The road and the contract are your proving ground."
EndFunction

String Function GetBretonSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetBretonTraditionLabel()
    Int traditionValue = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if traditionValue == 0
        return "Knight's Road"
    elseIf traditionValue == 1
        return "Hidden Art"
    elseIf traditionValue == 2
        return "Green Way"
    endIf

    return "no tradition yet"
EndFunction

String Function GetBretonBookOfDaysPathStatusLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetBretonPatronSurveySentence(Int traditionValue)
    PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        String pactName = Manager.GetPublicDeityDisplayName(activePact)
        if traditionValue == Manager.BRETON_TRADITION_HIDDEN_ART && activePact.GetStoredTier() >= Manager.LedgerRuntime.TIER_CHAMPION
            return " Your pact with " + pactName + " has opened Hidden Art - Champion."
        endIf
        return " Your pact with " + pactName + " stands beside the tradition."
    endIf

    if !Manager.GetActiveDeity() || Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return ""
    endIf

    String deityName = Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity())
    Int patronTier = Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity())
    if patronTier >= Manager.LedgerRuntime.TIER_CHAMPION
        String boonName = GetBretonChampionBoonDisplayName(Manager.GetActiveDeity())
        if IsDeityResonantWithBretonTradition(traditionValue, Manager.GetActiveDeity())
            return " " + deityName + " is your Champion patron through this tradition. " + boonName + " stands beside your practice."
        endIf
        return " " + deityName + " is your Champion patron beyond this tradition. " + boonName + " stands beside your practice."
    endIf

    return " " + deityName + " is your patron focus; your tradition advances through practiced deeds."
EndFunction

String Function GetRedguardSummary()
    if !Manager.PDV_RedguardSectTrack
        return "missing"
    endIf

    return "sect=" + GetRedguardSectLabel() + ";crown=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Crown")) + ";forebear=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Forebear")) + ";ashabah=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.AshAbah")) + ";farShores=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Redguard.LastSectReason")
EndFunction

Function ReconcileRedguardSpineRewardAfterLoad()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1 && StorageUtil.GetIntValue(None, "PDV.Redguard.SetupComplete") != 1
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    SyncRedguardSpineBoon(playerRef, True, GetActiveRedguardSpineSect())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Redguard spine reward reconciled after player load.")
EndFunction

; ============================================================================
; ORIGIN tranche 4: Nord (pantheon/baseline/Old-Ways ancestor/Kyne/Shor/Tsun/
; Stuhn worship) + Dunmer (Reclamation/ancestor/ancestral-urn/portable-shrine/
; House) lanes. Moved verbatim from PDV__ManagerQuest; bare manager-member
; references qualified via Manager.; LedgerRuntime.X -> Manager.LedgerRuntime.X;
; FavorRuntime.X -> Manager.FavorRuntime.X; reads of shared manager script vars
; route through manager accessors (GetActiveDeity,
; GetSuppressCurseTransitionOutputs, GetRaceCurseSurfaceShown); the write of
; _raceCurseSurfaceShown routes through Manager.SetRaceCurseSurfaceShown().
; ============================================================================

Function EnsureNordRuntimeWiring()
    EnsureNordOrkeyRewardRuntimeWiring()

    if !Manager.PDV_NordPantheonBaselineTrack
        return
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.TrackName != "NordPantheonBaseline"
        Manager.PDV_NordPantheonBaselineTrack.TrackName = "NordPantheonBaseline"
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.PDV_NordPantheonBaselineTrack.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
    endIf

    if Manager.PDV_NordPantheonBaselineTrack.StateLabels.Length != 2
        String[] labels = new String[2]
        labels[0] = "OldWays"
        labels[1] = "NineDivines"
        Manager.PDV_NordPantheonBaselineTrack.StateLabels = labels
    endIf

    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", Manager.PDV_NordPantheonBaselineTrack.GetCurrentState())
EndFunction

Function EnsureNordOrkeyRewardRuntimeWiring()
    Bool repaired = False

    if !Manager.PDV_Bless_Nord_Arkay_T1
        Manager.PDV_Bless_Nord_Arkay_T1 = Game.GetFormFromFile(0x071660, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T1
            repaired = True
        endIf
    endIf

    if !Manager.PDV_Bless_Nord_Arkay_T2
        Manager.PDV_Bless_Nord_Arkay_T2 = Game.GetFormFromFile(0x071663, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T2
            repaired = True
        endIf
    endIf

    if !Manager.PDV_Bless_Nord_Arkay_T3
        Manager.PDV_Bless_Nord_Arkay_T3 = Game.GetFormFromFile(0x071666, "Devotion.esp") as Spell
        if Manager.PDV_Bless_Nord_Arkay_T3
            repaired = True
        endIf
    endIf

    if repaired
        Manager.Trace(1, "Nord Orkey reward runtime wiring repaired.")
    endIf
EndFunction

Function HandleDunmerPortableShrinePrayer(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function DisarmDunmerAncestorWatch()
    ; The home-prayer ancestor watch lasts until dawn; remove it so each day's
    ; near-death protection must be re-earned with a fresh home prayer. The watcher
    ; script's own StorageUtil day-guard keeps the save once-per-day regardless.
    if !Manager.PDV_SPEL_Dunmer_AncestorWatch
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if playerRef && playerRef.HasSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
        playerRef.RemoveSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
        Manager.Trace(2, "Dunmer ancestor watch released at dawn.")
    endIf
EndFunction

Bool Function IsPlayerAtDunmerDeclaredHome(Actor playerRef)
    if !playerRef
        return false
    endIf
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID")
    if declaredId == 0
        return false
    endIf
    Cell currentCell = playerRef.GetParentCell()
    if !currentCell
        return false
    endIf
    return currentCell.GetFormID() == declaredId
EndFunction

Function HandleNordTsunAdversitySurvived(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleNordLocationChange(Location newLocation)
    if !newLocation || GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(Game.GetPlayer(), "PDV.Nord.HearthRest.DeclaredFormID")
        return
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.NordHearthReturn")
        return
    endIf

    RecordNordHearthReturn("location_hearth_return", 1.0)
EndFunction

Function RecordNordAncestorSpine(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordAncestorStandingScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line remembered.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Nord ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordNordHearthReturn(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordHearthReturnScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The hearth remembered your return.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.HearthReturnCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastHearthReturnReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastHearthReturnTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "The hearth remembers your return.")
    Manager.Trace(2, "Nord hearth return routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshNordAncestor()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function MaybeShowNordKyneChampionEntry(PDV_DeityBase deity, Int newTier)
    if newTier < Manager.LedgerRuntime.TIER_CHAMPION
        return
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return
    endIf
    if !Manager.PDV_Kyne || deity != Manager.PDV_Kyne
        return
    endIf
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Nord.ChampionEntryShown.Kyne") == 1
        return
    endIf
    if _pendingNordKyneChampionMsg
        return
    endIf

    ; Queued, never shown inline -- see _pendingNordKyneChampionMsg. The one-shot key is set when the
    ; modal actually PRESENTS, not here, so a recognition that could not display is not silently lost.
    _pendingNordKyneChampionMsg = Manager.PDV_Msg_Nord_Kyne_ChampionEntry
    _pendingNordKyneChampionFallback = "You sleep where the storm sleeps. You walk where the wind walks. Kyne has named her hunter."
    _pendingNordKyneChampionDelayTicks = 2
EndFunction

Function ProcessQueuedNordKyneChampionEntry()
    if !_pendingNordKyneChampionMsg && _pendingNordKyneChampionFallback == ""
        return
    endIf

    if _pendingNordKyneChampionDelayTicks > 0
        _pendingNordKyneChampionDelayTicks -= 1
        return
    endIf

    ; Belt and braces: OnUpdate already early-outs in menu mode, but the hold is cheap and this
    ; function is the thing that must never fire into an open menu.
    if Utility.IsInMenuMode()
        return
    endIf

    Message pendingRecord = _pendingNordKyneChampionMsg
    String pendingFallback = _pendingNordKyneChampionFallback
    _pendingNordKyneChampionMsg = None
    _pendingNordKyneChampionFallback = ""
    _pendingNordKyneChampionDelayTicks = 0

    ShowNordMessage(pendingRecord, pendingFallback, False)
    StorageUtil.SetIntValue(None, "PDV.Nord.ChampionEntryShown.Kyne", 1)
    Manager.Trace(1, "Nord/Kyne champion recognition presented.")
EndFunction

Function SyncKyneNeglectSpell(Bool shouldBeActive)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function SyncNordPatronNeglectSpells()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function SyncDunmerRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Dunmer " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Dunmer " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Dunmer " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Dunmer " + label)
EndFunction

Function SyncNordAncestorSubstrate(Actor playerRef, Bool isNord)
    if !playerRef || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    if isNord
        Manager.PDV_NordAncestorSubstrate.RecomputeSubstrateTier()
    else
        Manager.PDV_NordAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncNordRewardFamily(Actor playerRef, Int requiredBaseline, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool baselineOk = requiredBaseline < 0 || GetNordPantheonBaselineState() == requiredBaseline
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD && baselineOk && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Float activePiety = 0.0
    if isActive && deity
        activePiety = Manager.LedgerRuntime.GetPiety(deity)
    endIf
    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activePiety >= 85.0
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, False, "Nord " + label + " T1 compatibility")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activePiety >= 50.0 && activePiety < 85.0, "Nord " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Nord " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Nord " + label)
EndFunction

Int Function GetNordPantheonBaselineState()
    Int stateValue = StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState", Manager.NORD_BASELINE_OLD_WAYS)
    if Manager.PDV_NordPantheonBaselineTrack
        stateValue = Manager.PDV_NordPantheonBaselineTrack.GetCurrentState()
        StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", stateValue)
    endIf

    return stateValue
EndFunction

Message Function GetNordFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Message Function GetDunmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsKyneCommitmentSignalReady()
    if !Manager.PDV_Kyne
        return False
    endIf

    return Manager.LedgerRuntime.HasRecentCommitmentSignalDays(Manager.PDV_Kyne, 2, 7)
EndFunction

Function ApplyDunmerCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Float Function GetDunmerCurseLayerWeight(Int layer)
    Int posture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if layer == 1
        if posture == 2
            return 0.0
        elseIf posture == 1
            return 0.5
        endIf
    elseIf layer == 2
        if posture == 1
            return 0.75
        endIf
    endIf
    return 1.0
EndFunction

Function ApplyNordCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function ShouldSuppressNordCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowNordMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("kyne", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ShowNordNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("kyne", "neutral", "", fallbackText)
EndFunction

Function ApplyNordInitialChoice(Int baselineValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleDunmerHonorableVictory(Form victimForm)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RecordDunmerCombatVictoryEvidence(Form victimForm)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !victimForm
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableCombatVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableCombatTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function RecordDunmerStoryVictoryEvidence(Form victimForm, Int relationshipRank)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !victimForm || relationshipRank > -2
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableStoryVictim", victimForm.GetFormID())
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.HonorableStoryTime", Utility.GetCurrentGameTime())
    TryResolveDunmerHonorableVictory(victimForm)
EndFunction

Function TryResolveDunmerHonorableVictory(Form victimForm)
    if !Manager.PDV_DunmerAncestorSubstrate || !victimForm
        return
    endIf
    Int victimId = victimForm.GetFormID()
    if StorageUtil.GetIntValue(None, "PDV.Dunmer.HonorableCombatVictim") != victimId || StorageUtil.GetIntValue(None, "PDV.Dunmer.HonorableStoryVictim") != victimId
        return
    endIf
    Float combatTime = StorageUtil.GetFloatValue(None, "PDV.Dunmer.HonorableCombatTime")
    Float storyTime = StorageUtil.GetFloatValue(None, "PDV.Dunmer.HonorableStoryTime")
    if combatTime <= 0.0 || storyTime <= 0.0 || combatTime - storyTime > 0.02 || storyTime - combatTime > 0.02
        return
    endIf
    Actor victim = victimForm as Actor
    Actor playerRef = Game.GetPlayer()
    if !victim || !playerRef || victim.GetLevel() < playerRef.GetLevel()
        return
    endIf

    ; Clear both halves before awarding so repeated callbacks cannot double-fire.
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableCombatVictim", 0)
    StorageUtil.SetIntValue(None, "PDV.Dunmer.HonorableStoryVictim", 0)
    Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "honorable_victory_" + victim.GetFormID())
    Manager.Trace(2, "Dunmer honorable victory accepted for " + victim.GetFormID())
EndFunction

Function HandleDunmerDeviationPrice(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function SurfaceDunmerDeviationPriceNotice()
    if !Manager.GetActiveDeity()
        return
    endIf

    Int today = Utility.GetCurrentGameTime() as Int
    String activeName = Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity())
    String symbolName = Manager.GetPrismaSymbolForDeity(Manager.GetActiveDeity())
    String line = "The ash-prayer thins; " + activeName + " marks the wound."
    Manager.AppendBookOfDaysEntry(line, today, "creed.drop", symbolName, False, 2, "Reclamation strained")

    ; fix-plan 4.2: one notice per devotional day (the journal line above keeps the
    ; wall-clock date on purpose -- that is a display timestamp, not a cap).
    String toastKey = "PDV.Toast.DunmerDeviationPrice.Day"
    Int toastDayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, toastKey, -1) != toastDayStamp
        StorageUtil.SetIntValue(None, toastKey, toastDayStamp)
        Manager.SendPrismaToast(symbolName, "warning", "Reclamation strained", line)
    endIf
EndFunction

Bool Function TryAwardDunmerTwilightWindowSignal(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Azura
        return False
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Int windowValue = GetDunmerTwilightWindow(nowTime)
    if windowValue <= 0
        return False
    endIf

    ; fix-plan 4.2: one rite per window per devotional day.
    Int dayIndex = Manager.LedgerRuntime.GetDevotionalDay() + 2
    String windowLabel = GetDunmerTwilightWindowLabel(windowValue)
    String dayKey = "PDV.Signal.DunmerTwilight." + windowLabel + ".Day"
    if StorageUtil.GetIntValue(None, dayKey, -1) == dayIndex
        Manager.Trace(2, "Dunmer " + windowLabel + " twilight rite already recorded today (" + reason + ")")
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, dayIndex)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.TwilightWindowCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightWindow", windowLabel)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastTwilightReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastTwilightTime", nowTime)
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE, None)
    Manager.Trace(2, "Dunmer " + windowLabel + " twilight rite routed: " + reason)
    return True
EndFunction

Function HandleDunmerOutdoorGoodDaedraShrine(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function GetDunmerTwilightWindow(Float gameTime)
    Int dayIndex = gameTime as Int
    Float dayFraction = gameTime - dayIndex
    if dayFraction >= 0.25 && dayFraction < 0.375
        return 1
    elseIf dayFraction >= 0.75 && dayFraction < 0.875
        return 2
    endIf
    return 0
EndFunction

String Function GetDunmerTwilightWindowLabel(Int windowValue)
    if windowValue == 1
        return "Dawn"
    elseIf windowValue == 2
        return "Dusk"
    endIf
    return "None"
EndFunction

Function AwardActiveDunmerReclamationMemorySignal()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return
    endIf

    ; Anti-farm: the ancestor-memory piety pulse (portable-shrine prayer and the
    ; home rite share it) banks at most once per dawn cycle, keyed on the same
    ; day-int boundary as the rest of the daily gates. The substrate side keeps its
    ; own 0.7^n decay separately; this stops the pulse from stacking linearly.
    ; fix-plan 4.2: the comment above already says "once per dawn cycle" -- it now uses
    ; the dawn day boundary instead of raw midnight.
    Int pdvAncestorMemoryDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day") == pdvAncestorMemoryDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorMemory.Day", pdvAncestorMemoryDay)

    Float layerWeight = GetDunmerCurseLayerWeight(2)
    if Manager.GetActiveDeity() == Manager.PDV_Boethiah && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Mephala && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY, None, layerWeight)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Azura && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_MOON_OBSERVANCE, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerAncestorSpinePulse(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Azura || multiplier <= 0.0
        return
    endIf

    Int pdvAncestorSpineDay = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day") == pdvAncestorSpineDay
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.DunmerAncestorSpine.Day", pdvAncestorSpineDay)

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Dunmer.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastAncestorSpineTime", Utility.GetCurrentGameTime())
EndFunction

Function AwardDunmerReclamationFocusSignal(Int focusValue, Float layerWeight)
    if focusValue == 0 && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_THRESHOLD_RITE, None, layerWeight)
    elseIf focusValue == 1 && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE, None, layerWeight)
    elseIf focusValue == 2 && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SECRET_KEPT, None, layerWeight)
    endIf
EndFunction

Function AwardDunmerDeviationPriceSignal(Float multiplier)
    if Manager.GetActiveDeity() == Manager.PDV_Boethiah && Manager.PDV_Boethiah
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Mephala && Manager.PDV_Mephala
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.PDV_Azura && Manager.PDV_Azura
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DESECRATION, None, multiplier)
    endIf
EndFunction

Int Function GetNordRouteFamilyFromSource(String sourceId)
    if sourceId == ""
        return Manager.NORD_ROUTE_UNKNOWN
    endIf

    if PDV_DevotionRules.StringContainsToken(sourceId, "sky_road") || PDV_DevotionRules.StringContainsToken(sourceId, "sky-road") || PDV_DevotionRules.StringContainsToken(sourceId, "storm_road") || PDV_DevotionRules.StringContainsToken(sourceId, "road_grace")
        if PDV_DevotionRules.StringContainsToken(sourceId, "nine")
            return Manager.NORD_ROUTE_NINE_ROAD
        endIf
        return Manager.NORD_ROUTE_OLD_SKY_ROAD
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ordeal") || PDV_DevotionRules.StringContainsToken(sourceId, "trial") || PDV_DevotionRules.StringContainsToken(sourceId, "adversity")
        return Manager.NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hearth") || PDV_DevotionRules.StringContainsToken(sourceId, "hold") || PDV_DevotionRules.StringContainsToken(sourceId, "protect_bond")
        return Manager.NORD_ROUTE_OLD_HEARTH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "ancestor") || PDV_DevotionRules.StringContainsToken(sourceId, "honored_dead")
        return Manager.NORD_ROUTE_OLD_ANCESTOR
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "hircine") || PDV_DevotionRules.StringContainsToken(sourceId, "hunt")
        return Manager.NORD_ROUTE_OLD_ORDEAL
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "household") || PDV_DevotionRules.StringContainsToken(sourceId, "mercy")
        return Manager.NORD_ROUTE_NINE_MERCY
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "proper_death") || PDV_DevotionRules.StringContainsToken(sourceId, "proper-death") || PDV_DevotionRules.StringContainsToken(sourceId, "anti_necromancy") || PDV_DevotionRules.StringContainsToken(sourceId, "arkay")
        return Manager.NORD_ROUTE_NINE_DEATH
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "honest_work") || PDV_DevotionRules.StringContainsToken(sourceId, "honest-work") || PDV_DevotionRules.StringContainsToken(sourceId, "learned_craft") || PDV_DevotionRules.StringContainsToken(sourceId, "zenithar")
        return Manager.NORD_ROUTE_NINE_WORK
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos_pressure") || PDV_DevotionRules.StringContainsToken(sourceId, "talos-pressure")
        return Manager.NORD_ROUTE_NINE_TALOS
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "talos") || PDV_DevotionRules.StringContainsToken(sourceId, "defiance")
        return Manager.NORD_ROUTE_OLD_TALOS
    endIf

    return Manager.NORD_ROUTE_UNKNOWN
EndFunction

Int Function GetNordFavorLaneForRouteFamily(Int familyValue)
    if familyValue >= Manager.NORD_ROUTE_NINE_ROAD
        return Manager.FavorRuntime.FAVOR_LANE_NORD_BROAD_NINE_DIVINES
    endIf

    if familyValue > Manager.NORD_ROUTE_UNKNOWN
        return Manager.FavorRuntime.FAVOR_LANE_NORD_BROAD_OLD_WAYS
    endIf

    return Manager.FavorRuntime.FAVOR_LANE_NONE
EndFunction

Int Function GetNordFavorFamilyForRouteFamily(Int familyValue)
    if familyValue == Manager.NORD_ROUTE_OLD_SKY_ROAD
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_SKY_ROAD
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ORDEAL
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HONORABLE_ORDEAL
    elseIf familyValue == Manager.NORD_ROUTE_OLD_HEARTH
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_HEARTH_HOLD
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ANCESTOR
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET
    elseIf familyValue == Manager.NORD_ROUTE_OLD_TALOS
        return Manager.FavorRuntime.FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE
    elseIf familyValue == Manager.NORD_ROUTE_NINE_ROAD
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_ROAD_GRACE
    elseIf familyValue == Manager.NORD_ROUTE_NINE_MERCY
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_HOUSEHOLD_MERCY
    elseIf familyValue == Manager.NORD_ROUTE_NINE_DEATH
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_PROPER_DEATH
    elseIf familyValue == Manager.NORD_ROUTE_NINE_WORK
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_HONEST_WORK
    elseIf familyValue == Manager.NORD_ROUTE_NINE_TALOS
        return Manager.FavorRuntime.FAVOR_FAMILY_NINE_TALOS_PRESSURE
    endIf

    return 0
EndFunction

Function AwardNordRouteFamilySignal(Int familyValue, Float multiplier)
    if familyValue == Manager.NORD_ROUTE_OLD_SKY_ROAD
        ; Kyne's curated sky-road milestone bump. Services broad Old Ways worship
        ; and a focused Kyne patron alike (direct deity award, patron-agnostic).
        if Manager.PDV_Kyne
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Kyne, Manager.PDV_Kyne.SIGNAL_SKY_ROAD, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ORDEAL
        if Manager.PDV_Tsun
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tsun, Manager.PDV_Tsun.SIGNAL_TRIAL_ENDURED, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_HEARTH
        if Manager.PDV_Stuhn
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Stuhn, Manager.PDV_Stuhn.SIGNAL_PROTECT_BOND, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_ANCESTOR
        if Manager.PDV_Shor
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Shor, Manager.PDV_Shor.SIGNAL_HONORED_DEAD, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_OLD_TALOS || familyValue == Manager.NORD_ROUTE_NINE_TALOS
        if Manager.PDV_Talos
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_ROAD
        if Manager.LedgerRuntime.PDV_Kynareth
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Kynareth, Manager.LedgerRuntime.PDV_Kynareth.SIGNAL_OPEN_SKY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_MERCY
        if Manager.LedgerRuntime.PDV_Mara
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_DEATH
        if Manager.LedgerRuntime.PDV_Arkay
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Arkay, Manager.LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    elseIf familyValue == Manager.NORD_ROUTE_NINE_WORK
        if Manager.LedgerRuntime.PDV_Zenithar
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zenithar, Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
        endIf
    endIf
EndFunction

Bool Function RouteNordFamily(String reason, String countKey, String lastReasonKey, String lastTimeKey, String traceLabel)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, traceLabel + " ignored for non-Nord origin.")
        return False
    endIf

    Int routeFamily = GetNordRouteFamilyFromSource(reason)
    if routeFamily == Manager.NORD_ROUTE_UNKNOWN
        Manager.Trace(2, traceLabel + " ignored: unknown source family token in " + reason)
        return False
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordRouteFamily." + routeFamily)

    Int laneValue = GetNordFavorLaneForRouteFamily(routeFamily)
    Int favorFamily = GetNordFavorFamilyForRouteFamily(routeFamily)
    if laneValue != Manager.FavorRuntime.FAVOR_LANE_NONE && favorFamily > 0
        Manager.FavorRuntime.TryActivateContextualFavor(laneValue, favorFamily, reason)
    endIf

    ; The old OldWaysContextCount is frozen after migration; other route
    ; counters remain telemetry for their non-migration families.
    if countKey != "PDV.Nord.OldWaysContextCount"
        StorageUtil.SetIntValue(None, countKey, StorageUtil.GetIntValue(None, countKey) + 1)
    endIf
    StorageUtil.SetStringValue(None, lastReasonKey, reason)
    StorageUtil.SetFloatValue(None, lastTimeKey, Utility.GetCurrentGameTime())
    if multiplier > 0.0
        RecordNordAncestorSpine(reason, multiplier)
        AwardNordRouteFamilySignal(routeFamily, multiplier)
    endIf
    ; Nord broad/focused survey + reward state should react on the accepted source itself, not wait
    ; for the next dawn pass. This is especially visible on broad Old Ways T1, which otherwise does
    ; not appear until ProcessDawn even after the third accepted source has already been read.
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.Trace(2, traceLabel + " routed: " + reason)
    return True
EndFunction

Function HandleNordOldWaysState(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleNordKyneTalosContext(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleNordHircineArkayEdge(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetBookOfDaysDunmerAncestorLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function UsesNordOldWaysDeityNames()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf
    return GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
EndFunction

Function EnsureDunmerAncestralUrn()
    ; V1: grant the usable MISC urn (PDV_MISC_DunmerAncestralUrn); clicking it in the inventory
    ; fires OnEquipped and routes the ancestor prayer. The retired model-less BOOK token crashed
    ; the book menu on read, so migration removes any copies before granting the MISC urn.
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_MISC_DunmerAncestralUrn
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if Manager.PDV_BOOK_DunmerAncestralUrn
        int staleBookCount = playerRef.GetItemCount(Manager.PDV_BOOK_DunmerAncestralUrn)
        if staleBookCount > 0
            playerRef.RemoveItem(Manager.PDV_BOOK_DunmerAncestralUrn, staleBookCount, True)
            Manager.Trace(2, "Dunmer ancestral urn book token retired.")
        endIf
    endIf

    if playerRef.GetItemCount(Manager.PDV_MISC_DunmerAncestralUrn) <= 0
        playerRef.AddItem(Manager.PDV_MISC_DunmerAncestralUrn, 1, True)
        Manager.Trace(2, "Dunmer ancestral urn granted.")
    endIf
EndFunction

Bool Function IsNordVampireSuppressed()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return False
EndFunction

String Function GetNordSurveyBaseText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetNordContextSurveyText()
    String text = ""
    Int kyneTalosCount = StorageUtil.GetIntValue(None, "PDV.Nord.KyneTalosContextCount")
    Int edgeCount = StorageUtil.GetIntValue(None, "PDV.Nord.HircineArkayEdgeCount")
    if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS && Manager.LedgerRuntime.GetBroadPantheonStanding(Manager.LedgerRuntime.BROAD_PANTHEON_NORD_OLD) > 0.0
        text = text + " Recent acts confirm the old road."
    endIf
    if kyneTalosCount > 0
        text = text + " Kyne and Talos weigh on your road."
    endIf
    if edgeCount > 0
        text = text + " Hunt and death-duty are present, but remain edge pressures."
    endIf
    if Manager.PDV_NordAncestorSubstrate
        text = text + " The ancestor-line remains " + GetNordAncestorLayerLabel() + "."
    endIf
    return text
EndFunction

String Function GetNordAncestorLayerLabel()
    if !Manager.PDV_NordAncestorSubstrate
        return "quiet"
    endIf

    return Manager.PDV_NordAncestorSubstrate.GetAncestorPostureLabel()
EndFunction

String Function GetNordDevotionModeLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetDunmerSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetDunmerAncestorLayerLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub returns the type default (non-owner-race path).
    return ""
EndFunction

String Function GetDunmerReclamationFocusLabel(Int focusValue)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetNordScarLabel()
    if Manager.OriginRuntime.GetOriginDetailValue("vampire-scar") == 1 && !IsNordVampireSuppressed()
        return "The vampire scar still shows. The road is open again, but not unmarked."
    endIf

    return ""
EndFunction

String Function GetDunmerAncestorSummary()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "missing"
    endIf

    return Manager.PDV_DunmerAncestorSubstrate.GetPilotSummary()
EndFunction

; ============================================================================
; ORIGIN tranche 5: Orc (Malacath conduct/life-mode/stronghold/blood-kin/
; four-holds/legion/oath/self-made-community + curse handlers + trial-of-iron)
; + Imperial (civic service/patron-civic/Concordat pressure & labels/
; vampire-halt/ancestor substrate + Talos-pressure) lanes. Moved verbatim from
; PDV__ManagerQuest; bare manager-member references qualified via Manager.;
; LedgerRuntime.X -> Manager.LedgerRuntime.X; FavorRuntime.X -> Manager.FavorRuntime.X;
; reads of shared manager script vars route through existing manager accessors
; (GetActiveDeity, GetSuppressCurseTransitionOutputs). The race-specific gain-multiplier
; fns GetOrcLifeModeGainMultiplier / GetImperialCurseGainMultiplier now live in their race
; adapters (Phase A3, D1); no moved body here calls them.
; ============================================================================

Spell Function GetOrcTrialSpell(Int index)
    if index == 0
        return Manager.PDV_SPEL_Orc_TrialOfIron_Tusk
    elseIf index == 1
        return Manager.PDV_SPEL_Orc_TrialOfIron_Shield
    elseIf index == 2
        return Manager.PDV_SPEL_Orc_TrialOfIron_Hammer
    elseIf index == 3
        return Manager.PDV_SPEL_Orc_TrialOfIron_Yoke
    endIf
    return None
EndFunction

Function SyncOrcTrialOfIron(Actor playerRef)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsOrcTrialCoherent(Int modeAtRite)
    if !Manager.PDV_OrcLifeModeTrack
        return false
    endIf
    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() != modeAtRite
        return false
    endIf
    return true
EndFunction

Function HandleImperialSleepEvents(Actor playerRef, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcStoryCraftForge(Location craftLocation)
    if !IsOrcOrigin()
        return
    endIf
    if GetOrcStrongholdHoldId(craftLocation) <= 0
        return
    endIf
    HandleOrcStrongholdForge("story_craft_stronghold")
EndFunction

Function HandleOrcStrongholdForge(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdForge")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    AwardOrcStrongholdForgeSignal(multiplier)
    Manager.Trace(2, "Orc Stronghold forge routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLocationChange(Location newLocation)
    if !newLocation || !IsOrcOrigin()
        return
    endIf

    Int holdId = GetOrcStrongholdHoldId(newLocation)
    if holdId <= 0
        return
    endIf

    if Manager.PDV_Malacath && Manager.PDV_OrcLifeModeTrack && Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_LEGION_EXILE && StorageUtil.GetIntValue(None, "PDV.Signal.MalacathExileReturn.Done") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.MalacathExileReturn.Done", 1)
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_EXILE_RETURN, None, 1.0)
        Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Malacath, "Burden carried home", "marks the Exile's return to a stronghold hearth.")
        Manager.Trace(1, "Malacath exile-return banked (location_stronghold)")
    endIf

    HandleOrcStrongholdPresence(holdId, "location_stronghold")
EndFunction

Function HandleOrcStrongholdPresence(Int holdId, String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcStrongholdPresence")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, multiplier, reason)
    if Manager.PDV_SPEL_OrcHearthHeld && Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_STRONGHOLD && Manager.ConsumeOncePerDaySignal("PDV.Signal.OrcHearthHeld")
        Actor hearthPlayer = Game.GetPlayer()
        if hearthPlayer
            Manager.PDV_SPEL_OrcHearthHeld.Cast(hearthPlayer, hearthPlayer)
            Manager.Trace(2, "Orc hearth-held comfort cast (" + reason + ")")
        endIf
    endIf
    if holdId > 0
        HandleOrcFourHoldsVisit(holdId, reason)
    endIf
    Manager.Trace(2, "Orc Stronghold presence routed with multiplier " + multiplier)
EndFunction

Function HandleOrcBloodKinCrisis(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcCityDignity(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcLegionService(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcMalacathConduct(Int modeValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcOathBreak(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleOrcFourHoldsVisit(Int holdId, String reason)
    if !IsOrcOrigin()
        return
    endIf

    if holdId < Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL || holdId > Manager.ORC_FOUR_HOLDS_LARGASHBUR
        Manager.Trace(1, "Orc Four Holds skipped: invalid hold id " + holdId)
        return
    endIf

    String visitedKey = "PDV.Orc.FourHolds." + holdId
    if StorageUtil.GetIntValue(None, visitedKey) > 0
        Manager.Trace(2, "Orc Four Holds skipped: already visited hold " + holdId)
        return
    endIf

    StorageUtil.SetIntValue(None, visitedKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastFourHoldsReason", reason)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastFourHoldsVisit", holdId)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastFourHoldsVisitTime", Utility.GetCurrentGameTime())
    AwardOrcFourHoldsVisitSignal()
    AwardOrcAncestorSpineSignal(1.0, reason)

    Int count = GetOrcFourHoldsVisitCount()
    StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.Count", count)
    ShowOrcNotification(GetOrcFourHoldsNotice(holdId), GetOrcFourHoldsFallback(holdId))
    if count >= 4 && StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.FourHolds.MilestoneShown", 1)
        ShowOrcMessage(Manager.PDV_Msg_Orc_FourHolds_Milestone, "You have stood at all four strongholds. The code holds across distance.", False)
    endIf

    Manager.Trace(2, "Orc Four Holds routed: hold " + holdId + " count " + count)
EndFunction

Function RecordOrcLifeModeSignal(Int modeValue, Float multiplier, String reason)
    if !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    if modeValue < Manager.ORC_LIFE_MODE_CITY || modeValue > Manager.ORC_LIFE_MODE_LEGION_EXILE
        return
    endIf

    EnsureOrcLifeModeInitialized()
    Manager.PDV_OrcLifeModeTrack.RecordEvidenceDay(modeValue, reason)
    StorageUtil.AdjustFloatValue(None, GetOrcLifeModeWeightKey(modeValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Orc.LastLifeModeSignal", modeValue)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastLifeModeReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime", Utility.GetCurrentGameTime())

    if multiplier <= 0.0
        return
    endIf

    AwardOrcAncestorSpineSignal(multiplier, reason)
    MaybeShowOrcWatchersNotice(modeValue, reason)

    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() == modeValue
        SendPrismaSubstrateToast(GetOrcLifeModeSubstrateToken(modeValue), "act", "The code was marked.", "malacath", GetOrcLifeModeLabel())
        Manager.AppendBookOfDaysEntry("The code was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
        Manager.RequestPanelRefresh()
        return
    endIf

    ; LOCKED life-mode switch rule: a soft switch needs two evidence days inside
    ; seven; only a major gate (Blood-Kin, Cursed Tribe resolved) switches at once.
    ; Other soft switches settle at dawn via EvaluateOrcLifeModeAtDawn. A confirmed
    ; switch holds for a three-day lock-in. One stray act no longer flips the mode.
    if IsOrcMajorLifeModeGate(reason)
        ApplyOrcLifeModeSwitch(modeValue, reason)
    elseIf Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(modeValue, 2, 7) && !Manager.PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        ApplyOrcLifeModeSwitch(modeValue, reason)
    endIf
EndFunction

Function ApplyOrcLifeModeSwitch(Int modeValue, String reason)
    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() == Manager.ORC_LIFE_MODE_LEGION_EXILE && modeValue != Manager.ORC_LIFE_MODE_LEGION_EXILE
        EmitMalacathBrokenFaithKinMinus("desert_legion_exile_" + reason)
    endIf
    Manager.PDV_OrcLifeModeTrack.SetState(modeValue, reason)
    Manager.PDV_OrcLifeModeTrack.SetTransitionLockout(3.0, reason)
    Int deityIndex = -1
    if Manager.PDV_Malacath
        deityIndex = Manager.PDV_Malacath.DeityIndex
    endIf
    Manager.SurfaceTransition("reorientation", GetOrcLifeModeLabel(), "shift", deityIndex, "turning")
    Manager.SendPrismaShiftToast(GetOrcLifeModeLabel(), "", "malacath")
    Manager.RequestPanelRefresh()
EndFunction

Bool Function IsOrcMajorLifeModeGate(String reason)
    return PDV_DevotionRules.StringContainsToken(reason, "orc_bloodkin_crisis") || PDV_DevotionRules.StringContainsToken(reason, "orc_cursed_tribe_resolved") || PDV_DevotionRules.StringContainsToken(reason, "orc_major_gate")
EndFunction

String Function GetOrcLifeModeSubstrateToken(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "stronghold"
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "legionexile"
    endIf
    return "city"
EndFunction

Function EvaluateOrcLifeModeAtDawn()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function AwardOrcStrongholdForgeSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_STRONGHOLD_FORGE, None, multiplier)
    endIf
EndFunction

Function AwardOrcBloodKinSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BLOOD_KIN, None, multiplier)
    endIf
EndFunction

Function AwardOrcCityDignitySignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_CITY_DIGNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcLegionServiceSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_LEGION_SERVICE, None, multiplier)
    endIf
EndFunction

Function AwardOrcSelfMadeCommunitySignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY, None, multiplier)
    endIf
EndFunction

Function AwardOrcBroadConductSignal(Float multiplier)
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BROAD_CONDUCT, None, multiplier)
    endIf
EndFunction

Function AwardOrcOathBreakSignal()
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_OATH_BREAK, None)
    endIf
EndFunction

Function AwardOrcFourHoldsVisitSignal()
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT, None)
    endIf
EndFunction

Function AwardOrcAncestorSpineSignal(Float multiplier, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC || !Manager.PDV_Malacath || multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastAncestorSpineTime", Utility.GetCurrentGameTime())
EndFunction

Int Function GetOrcFourHoldsVisitCount()
    Int count = 0
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_NARZULBUR) > 0
        count += 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Orc.FourHolds." + Manager.ORC_FOUR_HOLDS_LARGASHBUR) > 0
        count += 1
    endIf
    return count
EndFunction

Message Function GetOrcFourHoldsNotice(Int holdId)
    if holdId == Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return Manager.PDV_Notif_Orc_FourHolds_DushnikhYal
    elseIf holdId == Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
        return Manager.PDV_Notif_Orc_FourHolds_MorKhazgur
    elseIf holdId == Manager.ORC_FOUR_HOLDS_NARZULBUR
        return Manager.PDV_Notif_Orc_FourHolds_Narzulbur
    elseIf holdId == Manager.ORC_FOUR_HOLDS_LARGASHBUR
        return Manager.PDV_Notif_Orc_FourHolds_Largashbur
    endIf

    return None
EndFunction

String Function GetOrcFourHoldsFallback(Int holdId)
    if holdId == Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
        return "Dushnikh Yal is counted. The code has a western hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
        return "Mor Khazgur is counted. The code has a northern hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_NARZULBUR
        return "Narzulbur is counted. The code has an eastern hold."
    elseIf holdId == Manager.ORC_FOUR_HOLDS_LARGASHBUR
        return "Largashbur is counted. Even a troubled hold is still a hold."
    endIf

    return "The stronghold is counted. The code holds across distance."
EndFunction

Bool Function ConsumeDailyOrcNotice(String noticeKey)
    ; fix-plan 4.2: devotional day, so a notice cannot re-fire at raw midnight.
    Int dayIndex = Manager.LedgerRuntime.GetDevotionalDay() + 2
    String storageKey = "PDV.Orc.Notice." + noticeKey + ".Day"
    if StorageUtil.GetIntValue(None, storageKey, -1) == dayIndex
        return False
    endIf

    StorageUtil.SetIntValue(None, storageKey, dayIndex)
    return True
EndFunction

Function MaybeShowOrcWatchersNotice(Int modeValue, String reason)
    if !ConsumeDailyOrcNotice("Watchers")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastWatchersNoticeReason", reason)
    ShowOrcNotification(GetOrcWatchersNotice(modeValue), GetOrcWatchersFallback(modeValue))
EndFunction

Message Function GetOrcWatchersNotice(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_Stronghold
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_LegionExile
    endIf

    return Manager.PDV_Notif_Orc_Witnessed_TheWatchers_City
EndFunction

String Function GetOrcWatchersFallback(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "The Watchers see the stronghold work. The code has witnesses."
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "The Watchers see the burden carried away from the hold. The code has witnesses."
    endIf

    return "The Watchers see the code kept under city stone. The code has witnesses."
EndFunction

Function MaybeShowOrcHearthHeldNotice(String reason)
    if StorageUtil.GetIntValue(None, "PDV.Orc.HearthHeldDeclared") == 0
        StorageUtil.SetIntValue(None, "PDV.Orc.HearthHeldDeclared", 1)
        StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldDeclareReason", reason)
        ; Declaring a hearth is a once-ever moment (the flag above guards it), so it
        ; earns a toast plus a permanent Book of Days beat rather than a transient
        ; corner notice. The toast honours the Notifications preference at the shared
        ; chokepoint while the Book entry always logs. PDV_Notif_Orc_HearthHeld_Declare
        ; is deliberately no longer shown here (it would double the surface); the
        ; record stays in the ESP, orphaned, with its text kept in sync.
        Manager.SendPrismaToast("malacath", "good", "A hearth held", "You claim this hearth as your own, and swear to hold it.")
        Manager.AppendBookOfDaysEntry("You claim this hearth as your own, and swear to hold it.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
        return
    endIf

    if !ConsumeDailyOrcNotice("HearthHeldReturn")
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Orc.LastHearthHeldReturnReason", reason)
    ShowOrcNotification(Manager.PDV_Notif_Orc_HearthHeld_Return, "You return to the hearth you hold. The code remembers the place.")
EndFunction

Function MaybeShowOrcHearthHeldMissedCadenceNotice()
    if !ConsumeDailyOrcNotice("HearthHeldMissed")
        return
    endIf

    ShowOrcNotification(Manager.PDV_Notif_Orc_HearthHeld_MissedCadence, "The held hearth has gone quiet. The code presses for proof.")
EndFunction

Function EnsureOrcLifeModeInitialized()
    if !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    if IsOrcOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if Manager.PDV_OrcLifeModeTrack.GetCurrentState() < Manager.ORC_LIFE_MODE_CITY
        Manager.PDV_OrcLifeModeTrack.SetState(Manager.ORC_LIFE_MODE_CITY, "orc_default_city")
    endIf
EndFunction

Bool Function IsOrcOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC
EndFunction

String Function GetOrcLifeModeWeightKey(Int modeValue)
    if modeValue == Manager.ORC_LIFE_MODE_STRONGHOLD
        return "PDV.Orc.LifeMode.Stronghold"
    elseIf modeValue == Manager.ORC_LIFE_MODE_LEGION_EXILE
        return "PDV.Orc.LifeMode.LegionExile"
    endIf

    return "PDV.Orc.LifeMode.City"
EndFunction

String Function GetOrcLifeModeLabel()
    if !Manager.PDV_OrcLifeModeTrack
        return "Life mode missing"
    endIf

    EnsureOrcLifeModeInitialized()
    return Manager.PDV_OrcLifeModeTrack.GetStateLabel()
EndFunction

Int Function GetOrcStrongholdHoldId(Location newLocation)
    if !newLocation
        return 0
    endIf

    Int locationFormId = newLocation.GetFormID()
    if locationFormId == 0x00019171
        return Manager.ORC_FOUR_HOLDS_DUSHNIKH_YAL
    elseIf locationFormId == 0x0001927C
        return Manager.ORC_FOUR_HOLDS_MOR_KHAZGUR
    elseIf locationFormId == 0x00019282
        return Manager.ORC_FOUR_HOLDS_NARZULBUR
    elseIf locationFormId == 0x00019263
        return Manager.ORC_FOUR_HOLDS_LARGASHBUR
    endIf

    return 0
EndFunction

String Function BuildImperialConcordatBookLine(String modeLabel)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsImperialVampireStateActive()
    return StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
EndFunction

Function SyncOrcSpineBoon(Actor playerRef, Bool isOrc, Int activeMode)
    if !playerRef
        return
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_City, isOrc && activeMode == Manager.ORC_LIFE_MODE_CITY, "Orc Spine City")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_Stronghold, isOrc && activeMode == Manager.ORC_LIFE_MODE_STRONGHOLD, "Orc Spine Stronghold")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Spine_LegionExile, isOrc && activeMode == Manager.ORC_LIFE_MODE_LEGION_EXILE, "Orc Spine LegionExile")
EndFunction

Int Function GetActiveOrcRewardMode()
    if Manager.PDV_OrcLifeModeTrack
        Int modeValue = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
        if modeValue >= Manager.ORC_LIFE_MODE_CITY && modeValue <= Manager.ORC_LIFE_MODE_LEGION_EXILE
            return modeValue
        endIf
    endIf

    return Manager.ORC_LIFE_MODE_CITY
EndFunction

Function SyncOrcRewardFamily(Actor playerRef, Int thisMode, Int activeMode, Int activeTier, Bool focusActive, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = focusActive && thisMode == activeMode
    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Orc " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Orc " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Orc " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, Manager.PDV_Malacath, "Orc " + label)
EndFunction

Function EmitMalacathCurseCodeRuptureMinus(String reason)
    if !IsOrcOrigin() || !Manager.PDV_Malacath
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathCurseCodeRupture")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CurseCodeRuptureCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastCurseCodeRuptureReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastCurseCodeRuptureTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Malacath curse-code rupture routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function EmitMalacathBrokenFaithKinMinus(String reason)
    if !IsOrcOrigin() || !Manager.PDV_Malacath
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MalacathBrokenFaithKin")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Malacath, Manager.PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.BrokenFaithKinCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastBrokenFaithKinReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Orc.LastBrokenFaithKinTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Malacath broken-faith-kin routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function SyncImperialAncestorSubstrate(Actor playerRef, Bool isImperial)
    if !playerRef || !Manager.PDV_ImperialAncestorSubstrate
        return
    endIf

    if isImperial
        Manager.PDV_ImperialAncestorSubstrate.RecomputeSubstrateTier()
    else
        Manager.PDV_ImperialAncestorSubstrate.ClearSubstrateBoons()
    endIf
EndFunction

Function SyncImperialRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_IMPERIAL && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity && !IsImperialVampireStateActive()
    Float activePiety = 0.0
    if isActive && deity
        activePiety = Manager.LedgerRuntime.GetPiety(deity)
    endIf
    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activePiety >= 85.0
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, False, "Imperial " + label + " T1 compatibility")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activePiety >= 50.0 && activePiety < 85.0, "Imperial " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Imperial " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Imperial " + label)
EndFunction

Function ApplyConcordatPressure(Int adjustment, String reason)
    if !Manager.PDV_ConcordatStandingTrack
        Manager.Trace(1, "ApplyConcordatPressure skipped: track missing.")
        return
    endIf
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        Manager.Trace(2, "ApplyConcordatPressure ignored for non-Imperial origin.")
        return
    endIf

    Manager.PDV_ConcordatStandingTrack.Adjust(adjustment, reason)
    Manager.Trace(2, "Concordat pressure " + adjustment + " -> " + Manager.PDV_ConcordatStandingTrack.GetValue())
EndFunction

Int Function GetImperialConcordatPressureForAction(String actionKey)
    if actionKey == "hidden_talos_shrine"
        return -15
    elseIf actionKey == "help_talos_worshipper_escape"
        return -15
    elseIf actionKey == "kill_thalmor_justiciar_unprovoked"
        return -10
    elseIf actionKey == "side_with_stormcloaks"
        return -20
    elseIf actionKey == "refuse_report_talos_worshipper"
        return -5
    elseIf actionKey == "public_observe_talos_ban"
        return 5
    elseIf actionKey == "report_talos_worshipper"
        return 15
    elseIf actionKey == "attack_talos_worshipper"
        return 15
    endIf

    return 0
EndFunction

Message Function GetImperialFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Bool Function IsImperialTalosOfferAllowed()
    if !Manager.PDV_ConcordatStandingTrack
        return False
    endIf

    return Manager.PDV_ConcordatStandingTrack.GetValue() <= 50
EndFunction

Bool Function ShouldSuppressImperialTalosTierSurface(PDV_DeityBase deity)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        return False
    endIf

    if deity != Manager.PDV_Talos
        return False
    endIf

    return !IsImperialTalosOfferAllowed()
EndFunction

Function ApplyImperialCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ApplyOrcCurseHandlers(Int oldState, Int newState, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function ShowOrcNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("malacath", "neutral", "", fallbackText)
EndFunction

Function ShowOrcMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    if suppressModal
        Manager.SendPrismaToast("malacath", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyOrcInitialChoice(Int modeValue, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Int Function GetImperialCivicFamilyFromSource(String sourceId)
    if PDV_DevotionRules.StringContainsToken(sourceId, "public_service") || PDV_DevotionRules.StringContainsToken(sourceId, "public-service") || PDV_DevotionRules.StringContainsToken(sourceId, "civic_public")
        return Manager.IMPERIAL_CIVIC_PUBLIC_SERVICE
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "mercy")
        return Manager.IMPERIAL_CIVIC_MERCY
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "lawful_order") || PDV_DevotionRules.StringContainsToken(sourceId, "lawful-order") || PDV_DevotionRules.StringContainsToken(sourceId, "law")
        return Manager.IMPERIAL_CIVIC_LAWFUL_ORDER
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "honest_work") || PDV_DevotionRules.StringContainsToken(sourceId, "honest-work") || PDV_DevotionRules.StringContainsToken(sourceId, "work")
        return Manager.IMPERIAL_CIVIC_HONEST_WORK
    elseIf PDV_DevotionRules.StringContainsToken(sourceId, "death_duty") || PDV_DevotionRules.StringContainsToken(sourceId, "death-duty") || PDV_DevotionRules.StringContainsToken(sourceId, "arkay")
        return Manager.IMPERIAL_CIVIC_DEATH_DUTY
    endIf

    return Manager.IMPERIAL_CIVIC_UNKNOWN
EndFunction

String Function GetImperialCivicFamilyLabel(Int familyId)
    if familyId == Manager.IMPERIAL_CIVIC_PUBLIC_SERVICE
        return "public_service"
    elseIf familyId == Manager.IMPERIAL_CIVIC_MERCY
        return "mercy"
    elseIf familyId == Manager.IMPERIAL_CIVIC_LAWFUL_ORDER
        return "lawful_order"
    elseIf familyId == Manager.IMPERIAL_CIVIC_HONEST_WORK
        return "honest_work"
    elseIf familyId == Manager.IMPERIAL_CIVIC_DEATH_DUTY
        return "death_duty"
    endIf

    return "unknown"
EndFunction

Function AwardImperialCivicFamilySignal(Int familyId, Float multiplier)
    if familyId == Manager.IMPERIAL_CIVIC_PUBLIC_SERVICE
        if Manager.LedgerRuntime.PDV_Akatosh
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Akatosh, Manager.LedgerRuntime.PDV_Akatosh.SIGNAL_CIVIC_SERVICE, None, multiplier)
        endIf
    elseIf familyId == Manager.IMPERIAL_CIVIC_MERCY
        if Manager.LedgerRuntime.PDV_Mara
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
        endIf
    elseIf familyId == Manager.IMPERIAL_CIVIC_LAWFUL_ORDER
        if Manager.LedgerRuntime.PDV_Stendarr
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Stendarr, Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_LAWFUL_ORDER, None, multiplier)
        endIf
    elseIf familyId == Manager.IMPERIAL_CIVIC_HONEST_WORK
        if Manager.LedgerRuntime.PDV_Zenithar
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zenithar, Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK, None, multiplier)
        endIf
    elseIf familyId == Manager.IMPERIAL_CIVIC_DEATH_DUTY
        if Manager.LedgerRuntime.PDV_Arkay
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Arkay, Manager.LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY, None, multiplier)
        endIf
    endIf
EndFunction

Function AwardImperialPatronCivicSignal(Float multiplier)
    if !Manager.GetActiveDeity()
        return
    endIf

    if Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Akatosh && Manager.LedgerRuntime.PDV_Akatosh
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Akatosh, Manager.LedgerRuntime.PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Mara && Manager.LedgerRuntime.PDV_Mara
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Arkay && Manager.LedgerRuntime.PDV_Arkay
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Arkay, Manager.LedgerRuntime.PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Stendarr && Manager.LedgerRuntime.PDV_Stendarr
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Stendarr, Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Zenithar && Manager.LedgerRuntime.PDV_Zenithar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Zenithar, Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Dibella && Manager.LedgerRuntime.PDV_Dibella
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Dibella, Manager.LedgerRuntime.PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Julianos && Manager.LedgerRuntime.PDV_Julianos
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Julianos, Manager.LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    elseIf Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Kynareth && Manager.LedgerRuntime.PDV_Kynareth
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Kynareth, Manager.LedgerRuntime.PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    endIf
EndFunction

Function AwardImperialAncestorSpinePulse(Float multiplier, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function RunDawnRefreshImperialAncestor()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleImperialCivicService(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleImperialTalosPressure(Bool isPrivate, String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetOrcSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetImperialSurveyText()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function GetImperialConcordatLabel()
    ; body removed in Phase C dedup -- live impl is the race adapter override; base stub never runs (call sites are race-gated).
EndFunction

String Function FormatImperialConcordatLabel(String label)
    if label == "OpenDefiant"
        return "Openly Defiant"
    elseIf label == "PrivateDefiant"
        return "Privately Defiant"
    elseIf label == "PublicCompliant"
        return "Publicly Compliant"
    elseIf label == "ConcordatEnforcer"
        return "Concordat Enforcer"
    endIf

    return label
EndFunction

String Function BuildImperialConcordatSurveySentence(String concordatLabel)
    if concordatLabel == "Concordat Enforcer"
        return "Under the Concordat, you are a Concordat Enforcer."
    endIf

    return "Under the Concordat, you are " + concordatLabel + "."
EndFunction

String Function GetImperialCivicTierName()
    if !Manager.PDV_ImperialAncestorSubstrate
        return "Civic practice quiet"
    endIf
    Int tierValue = Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier()
    if tierValue >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Civic Exemplar"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Civic Discipline"
    elseIf tierValue >= Manager.LedgerRuntime.TIER_SEEKER
        return "Civic Steadiness"
    endIf
    return "Civic practice quiet"
EndFunction

String Function GetConcordatSummary()
    if !Manager.PDV_ConcordatStandingTrack
        return "missing"
    endIf

    String gateState = "locked"
    if Manager.PDV_ConcordatStandingTrack.HasExtremeResetGate()
        gateState = "unlocked"
    endIf

    return "raw=" + Manager.PDV_ConcordatStandingTrack.GetValue() + ";state=" + Manager.PDV_ConcordatStandingTrack.GetStateLabel() + ";pending=" + Manager.PDV_ConcordatStandingTrack.GetPendingStateLabel() + ";gate=" + gateState + ";track=" + PDV_DevotionRules.FormatTwoDecimals(GetTalosTrackGainMultiplier()) + ";eff=" + PDV_DevotionRules.FormatTwoDecimals(GetTalosEffectiveGainMultiplier())
EndFunction

String Function GetOrcSummary()
    if !Manager.PDV_OrcLifeModeTrack
        return "missing"
    endIf

    return "mode=" + GetOrcLifeModeLabel() + ";stronghold=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.Stronghold")) + ";city=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.City")) + ";legion=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.LegionExile")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Orc.LastLifeModeReason")
EndFunction

; ============================================================================
; ORIGIN tranche 6 (final non-race infra): broad-lane tier/standing/
; presentation helpers, origin-race index/label/roster, curse summary &
; context, substrate pacing, Paarthurnax + undead-crypt + Thalmor + shout
; reactions, medallion assembly, survey/rest-cell helpers, generic Concordat,
; Talos deity fns (identity/rescue/defiance/betrayal + track/effective gain
; multipliers). Moved verbatim from PDV__ManagerQuest; bare manager-member
; references qualified via Manager.; LedgerRuntime.X -> Manager.LedgerRuntime.X;
; reads of shared manager script vars route through existing manager accessors
; (GetActiveDeity, GetQrQueueTransactionActive); writes through existing setters
; (SetSuppressAwardFavorToast, SetQrQueueNeedsCurseRefresh). The 3 gain-multiplier fns are
; no longer in the manager: GetCurseGainMultiplier moved to this base and
; GetOrcLifeModeGainMultiplier / GetImperialCurseGainMultiplier to their race adapters
; (Phase A3, D1). The provider seam sources each scalar once; no moved body reaches them by
; the old Manager.Get... path.
; ============================================================================

Function EnsureTalosRuntimeIdentity()
    if !Manager.PDV_Talos
        return
    endIf

    Bool repaired = False

    if Manager.PDV_Talos.DeityName != "Talos"
        Manager.PDV_Talos.DeityName = "Talos"
        repaired = True
    endIf

    if Manager.PDV_Talos.DeityDomain == ""
        Manager.PDV_Talos.DeityDomain = "Empire, War, Human Ascension"
        repaired = True
    endIf

    if Manager.PDV_Talos.DeityIndex != 1
        Manager.PDV_Talos.DeityIndex = 1
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Nord != Manager.PDV_Talos.STANCE_NATIVE
        Manager.PDV_Talos.Stance_Nord = Manager.PDV_Talos.STANCE_NATIVE
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Imperial != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Imperial = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Breton != Manager.PDV_Talos.STANCE_NATIVE
        Manager.PDV_Talos.Stance_Breton = Manager.PDV_Talos.STANCE_NATIVE
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Altmer != Manager.PDV_Talos.STANCE_HOSTILE
        Manager.PDV_Talos.Stance_Altmer = Manager.PDV_Talos.STANCE_HOSTILE
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Bosmer != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Bosmer = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Dunmer != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Dunmer = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Khajiit != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Khajiit = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Argonian != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Argonian = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Orc != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Orc = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.Stance_Redguard != Manager.PDV_Talos.STANCE_FOREIGN
        Manager.PDV_Talos.Stance_Redguard = Manager.PDV_Talos.STANCE_FOREIGN
        repaired = True
    endIf

    if Manager.PDV_Talos.PDV_GLO_DebugLevel != Manager.LedgerRuntime.PDV_GLO_DebugLevel
        Manager.PDV_Talos.PDV_GLO_DebugLevel = Manager.LedgerRuntime.PDV_GLO_DebugLevel
        repaired = True
    endIf

    if Manager.PDV_Talos.PDV_GLO_OriginRace != Manager.PDV_GLO_OriginRace
        Manager.PDV_Talos.PDV_GLO_OriginRace = Manager.PDV_GLO_OriginRace
        repaired = True
    endIf

    if repaired
        Manager.Trace(1, "Talos runtime identity repaired for save compatibility.")
    endIf
EndFunction

Bool Function IsDashboardDeityInOriginRoster(PDV_DeityBase deity, Int originRace)
    if !deity
        return False
    endIf

    if originRace == Manager.ORIGIN_NORD
        return deity == Manager.PDV_Kyne || deity == Manager.LedgerRuntime.PDV_Kynareth || deity == Manager.PDV_Talos || deity == Manager.PDV_Shor || deity == Manager.PDV_Tsun || deity == Manager.PDV_Stuhn || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Zenithar
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        return deity == Manager.LedgerRuntime.PDV_Kynareth || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Zenithar
    elseIf originRace == Manager.ORIGIN_BRETON
        return deity == Manager.LedgerRuntime.PDV_Kynareth || deity == Manager.PDV_Talos || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Zenithar || deity == Manager.PDV_Magnus || deity == Manager.PDV_Yffre
    elseIf originRace == Manager.ORIGIN_ALTMER
        return deity == Manager.PDV_AuriEl || deity == Manager.PDV_Magnus || deity == Manager.PDV_Xarxes || deity == Manager.PDV_Trinimac || deity == Manager.PDV_Syrabane
    elseIf originRace == Manager.ORIGIN_BOSMER
        return deity == Manager.PDV_Yffre || deity == Manager.PDV_AuriEl || deity == Manager.PDV_Xarxes || deity == Manager.PDV_BaanDar || deity == Manager.LedgerRuntime.PDV_Zen
    elseIf originRace == Manager.ORIGIN_DUNMER
        return deity == Manager.PDV_Azura || deity == Manager.PDV_Boethiah || deity == Manager.PDV_Mephala
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        return deity == Manager.PDV_Azura || deity == Manager.PDV_Boethiah || deity == Manager.PDV_Mephala || deity == Manager.PDV_BaanDar || deity == Manager.PDV_Rajhin || deity == Manager.PDV_Alkosh || deity == Manager.PDV_Khenarthi
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        return deity == Manager.PDV_Hist || deity == Manager.PDV_Sithis
    elseIf originRace == Manager.ORIGIN_ORC
        return deity == Manager.PDV_Malacath
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return deity == Manager.PDV_Tuwhacca || deity == Manager.PDV_Leki || deity == Manager.PDV_HoonDing
    endIf

    return False
EndFunction

Function HandlePlayerSleepStop(Actor playerRef, Bool wasInterrupted, Bool hadSleepStartContext, Bool sleepStartedOutside, String reason)
    if wasInterrupted
        Manager.Trace(3, "Player sleep stop ignored because sleep was interrupted.")
        return
    endIf

    if !playerRef
        Manager.Trace(1, "Player sleep stop skipped: player ref missing.")
        return
    endIf

    ; Road-home classification uses the CAPTURED sleep-start context, never a re-sample of the
    ; wake cell. The base decides WHICH signal fires; the live adapter decides what it means.
    if hadSleepStartContext && sleepStartedOutside
        Manager.OriginRuntime.HandleContextualSignal("outdoor-rest", reason, playerRef)
    endIf
    Manager.OriginRuntime.HandleContextualSignal("sleep-stop", reason, playerRef)
EndFunction

Function HandleSubstrateActionEvent(Int eventType, String reason)
    ; Race switch dissolved by the ORIGIN adapter split; the live adapter answers.
    ; See references/authoring/PDV_2_0_ORIGIN_SwitchboardReversal.md for the original.
    Manager.OriginRuntime.HandleContextualSignal("substrate-action", reason, None, eventType as Float)
EndFunction

Int Function GetInteriorSleepCellId(Actor playerRef)
    if !playerRef
        return 0
    endIf

    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return 0
    endIf

    return sleepCell.GetFormID()
EndFunction

Bool Function IsPlayerAtDeclaredRestCell(Actor playerRef, String declaredKey)
    if !playerRef
        return false
    endIf

    Int declaredId = StorageUtil.GetIntValue(None, declaredKey)
    if declaredId == 0
        return false
    endIf

    Cell currentCell = playerRef.GetParentCell()
    if !currentCell
        return false
    endIf

    return currentCell.GetFormID() == declaredId
EndFunction

Bool Function TryDeclareRestCell(String keyPrefix, Int sleepCellId)
    if sleepCellId == 0 || StorageUtil.GetIntValue(None, keyPrefix + ".DeclaredFormID") != 0
        return false
    endIf

    ; fix-plan 4.1 + 4.2. This shared Nord/Orc/Redguard rest-cell declaration compared a
    ; default-0 CandidateDay against raw game day 0 -- the same day-0 class as B13's shrine
    ; credit, here silently refusing the first candidacy sleep of a new save. Devotional
    ; +2 stamp: never 0, and it no longer splits one night's sleep across two days.
    Int today = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int candidateId = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateFormID")
    Int candidateDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp(keyPrefix + ".CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, keyPrefix + ".CandidateCount")

    if candidateId != sleepCellId
        candidateCount = 0
    elseIf candidateDay == today
        return false
    endIf

    candidateCount += 1
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateFormID", sleepCellId)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(keyPrefix + ".CandidateDay")
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateCount", candidateCount)

    if candidateCount < 3
        return false
    endIf

    StorageUtil.SetIntValue(None, keyPrefix + ".DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, keyPrefix + ".DeclaredDay", today)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateFormID", 0)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateDay", 0)
    StorageUtil.SetIntValue(None, keyPrefix + ".CandidateCount", 0)
    return true
EndFunction

Function HandlePlayerBelowHealthGate(Actor playerRef)
    Manager.OriginRuntime.HandleContextualSignal("baandar-gap", "below_health_gate", playerRef)
    Manager.OriginRuntime.HandleContextualSignal("sithis-near-death", "below_health_gate", playerRef)
    Manager.OriginRuntime.HandleContextualSignal("code-holds", "below_health_gate", playerRef)
EndFunction

Function HandlePlayerBelowHealthSurvived(Actor playerRef)
    ; Orc Code Holds now fires mid-fight from HandlePlayerBelowHealthGate (Baan Dar
    ; model), so the combat-exit survival path is intentionally a no-op. Left routed
    ; from the player alias for origin 8 without behavior.
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

Function HandleStateTransitionConfirmationRite(String reason)
    Manager.OriginRuntime.HandleContextualSignal("confirm-pending-transition", reason)
EndFunction

Function HandleTalosWorshipperRescued(String reason)
    if !Manager.PDV_Talos || !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(Manager.PDV_Talos)
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Signal.TalosWorshipperRescue.Done") == 1
        Manager.Trace(2, "Talos worshipper-rescue already banked (" + reason + ")")
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Signal.TalosWorshipperRescue.Done", 1)
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_PROTECT_WORSHIPPER, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Talos, "A worshipper protected", "marks one of the faithful carried out of Thalmor hands.")
    Manager.Trace(1, "Talos protect-worshipper routed (" + reason + ")")
EndFunction

Function HandlePaarthurnaxKill(Form sourceForm, String reason)
    String killKey = "PDV.Paarthurnax.KillSeen"
    if StorageUtil.GetIntValue(None, killKey, 0) == 1
        Manager.Trace(2, "Paarthurnax kill repeat blocked (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, killKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Paarthurnax.KillReason", reason)
    Manager.PDV_QuestReactionRuntimeService.ResetQuestReactionSurface()
    ApplyPaarthurnaxKillReaction("Shor", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Tsun", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Kyne", "S", sourceForm)
    ApplyPaarthurnaxKillReaction("Stendarr", "C", sourceForm)
    ApplyPaarthurnaxKillReaction("Stuhn", "C", sourceForm)
    ApplyPaarthurnaxKillReaction("Mara", "S", sourceForm)
    ; 2026-07-15 full-pantheon expansion: the dragon of the covenant, repentant,
    ; slain at the Blades' demand -- the time-and-order gods mourn it, the
    ; treachery-and-dominion Princes savor it.
    ApplyPaarthurnaxKillReaction("Akatosh", "S", sourceForm)
    ; Alkosh is deliberately absent here: the kill path already routes
    ; RouteKhajiitAlkoshChaosAid for Khajiit players (PDV_PlayerEvents), and Alkosh is
    ; reachable to no one else, so a row here would only double-penalize a Khajiit.
    ApplyPaarthurnaxKillReaction("Talos", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Julianos", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Auri-El", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Khenarthi", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Kynareth", "m", sourceForm)
    ApplyPaarthurnaxKillReaction("Boethiah", "S", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Hircine", "S", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Molag Bal", "m", sourceForm, "+")
    ApplyPaarthurnaxKillReaction("Mehrunes Dagon", "m", sourceForm, "+")
    Manager.PDV_QuestReactionRuntimeService.FlushQuestReactionSurface()
    Manager.Trace(2, "Paarthurnax kill fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxKillReaction(String deityName, String intensity, Form sourceForm, String valence = "-")
    Manager.LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, "small", "paarthurnax_kill", False, sourceForm)
EndFunction

Function HandlePaarthurnaxSpare(Form sourceForm, String reason)
    String spareKey = "PDV.Paarthurnax.SpareSeen"
    if StorageUtil.GetIntValue(None, spareKey, 0) == 1
        Manager.Trace(2, "Paarthurnax spare repeat blocked (" + reason + ")")
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Paarthurnax.KillSeen", 0) == 1
        Manager.Trace(2, "Paarthurnax spare blocked because kill fork already fired (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, spareKey, 1)
    StorageUtil.SetStringValue(None, "PDV.Paarthurnax.SpareReason", reason)
    Manager.PDV_QuestReactionRuntimeService.ResetQuestReactionSurface()
    ApplyPaarthurnaxSpareReaction("Stuhn", "C", sourceForm)
    ApplyPaarthurnaxSpareReaction("Stendarr", "C", sourceForm)
    ApplyPaarthurnaxSpareReaction("Mara", "S", sourceForm)
    ApplyPaarthurnaxSpareReaction("Kyne", "m", sourceForm)
    ; 2026-07-15 full-pantheon expansion: mercy for the repentant dragon honors
    ; the time-and-order gods; the treachery-and-dominion Princes read it as
    ; weakness.
    ApplyPaarthurnaxSpareReaction("Akatosh", "S", sourceForm)
    ApplyPaarthurnaxSpareReaction("Talos", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Alkosh", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Auri-El", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Kynareth", "m", sourceForm)
    ApplyPaarthurnaxSpareReaction("Boethiah", "m", sourceForm, "-")
    ApplyPaarthurnaxSpareReaction("Molag Bal", "m", sourceForm, "-")
    Manager.PDV_QuestReactionRuntimeService.FlushQuestReactionSurface()
    Manager.Trace(2, "Paarthurnax spare fork routed (" + reason + ")")
EndFunction

Function ApplyPaarthurnaxSpareReaction(String deityName, String intensity, Form sourceForm, String valence = "+")
    Manager.LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, "small", "paarthurnax_spare", False, sourceForm)
EndFunction

Function TrackUndeadCryptClearSiteVisit(Location currentLocation)
    if !currentLocation || !Manager.PDV_FLST_UndeadCryptClearSites
        return
    endIf

    if !Manager.PDV_FLST_UndeadCryptClearSites.HasForm(currentLocation)
        return
    endIf

    if currentLocation.IsCleared()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.UndeadCryptClear.Armed." + currentLocation.GetFormID(), 1)
EndFunction

Function HandleUndeadCryptSiteClear(Location clearedLocation)
    if !clearedLocation || !Manager.PDV_FLST_UndeadCryptClearSites
        return
    endIf

    if !Manager.PDV_FLST_UndeadCryptClearSites.HasForm(clearedLocation)
        return
    endIf

    if !clearedLocation.IsCleared()
        return
    endIf

    String siteKey = "PDV.UndeadCryptClear.Seen." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, siteKey, 0) == 1
        return
    endIf

    String armKey = "PDV.UndeadCryptClear.Armed." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, armKey, 0) != 1
        return
    endIf

    StorageUtil.SetIntValue(None, siteKey, 1)
    StorageUtil.SetIntValue(None, armKey, 0)
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.UndeadCryptClear")
    ApplyUndeadCryptClearReactions(clearedLocation, multiplier)
    Manager.Trace(2, "Undead crypt clear fired for location " + clearedLocation.GetFormID() + " multiplier=" + multiplier)
EndFunction

Function ApplyUndeadCryptClearReactions(Location clearedLocation, Float repeatMultiplier)
    if repeatMultiplier <= 0.0
        return
    endIf

    Manager.PDV_QuestReactionRuntimeService.ResetQuestReactionSurface()
    ApplyUndeadCryptClearReaction("Arkay", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Meridia", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Stendarr", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Tu'whacca", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Azura", "m", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Y'ffre", "m", clearedLocation, repeatMultiplier)
    Manager.PDV_QuestReactionRuntimeService.FlushQuestReactionSurface()
EndFunction

Function ApplyUndeadCryptClearReaction(String deityName, String intensity, Location clearedLocation, Float repeatMultiplier)
    PDV_DeityBase deity = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionDeity(deityName)
    if !deity
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear skipped unknown deity: " + deityName)
        endIf
        return
    endIf

    Float amount = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionBaseValue("small", intensity) * repeatMultiplier
    if amount == 0.0
        return
    endIf

    String sourceTag = "undead_crypt_clear"
    String stance = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastCurse", deityName + "." + sourceTag)
        if Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive()
            Manager.PDV_QuestReactionRuntimeService.SetQrQueueNeedsCurseRefresh(True)
        else
            Manager.LedgerRuntime.HandleCurseStateRefresh("quest_reaction_" + deityName)
        endIf
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear curse routed: " + deityName)
        endIf
        return
    endIf

    if stance == "TABOO" || stance == "HOSTILE"
        Manager.PDV_QuestReactionRuntimeService.ApplyQuestReactionStigma(deity, amount, sourceTag)
        if !(deity as PDV_DaedricPathBase)
            Manager.PDV_QuestReactionRuntimeService.AccumulateQuestReactionSurface(deity, amount * -1.0, "small")
        endIf
        return
    endIf

    if stance == "FOREIGN" || stance == "TOLERATED"
        if !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(deity)
            if Manager.GetDebugLevel() >= 2
                Debug.Trace("[PDV] UndeadCryptClear skipped unreachable foreign deity: " + deityName)
            endIf
            return
        endIf
    endIf

    Float stanceMultiplier = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStanceMultiplier(stance)

    Float appliedReactionAmount = amount * stanceMultiplier
    Manager.SetSuppressAwardFavorToast(True)
    Manager.PDV_QuestReactionRuntimeService.ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    Manager.SetSuppressAwardFavorToast(False)
    Manager.PDV_QuestReactionRuntimeService.AccumulateQuestReactionSurface(deity, appliedReactionAmount, "small")

    Manager.OriginRuntime.HandleContextualSignal("crypt-clear-focus", deityName)
EndFunction

Function HandleTalosShrineDefiance(String reason)
    ; The Imperial broad-Talos unlock and the Concordat action both moved into the Imperial
    ; adapter; the award below is race-free and stays.
    ; See references/authoring/PDV_2_0_ORIGIN_SwitchboardReversal.md for the original.
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.TalosShrineDefiance")
    if Manager.PDV_Talos
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
    else
        Manager.Trace(1, "Talos shrine defiance skipped: PDV_Talos missing.")
    endIf

    if Manager.OriginRuntime.HandleContextualSignal("hidden_talos_shrine", "talos_shrine_" + reason)
        Manager.Trace(2, "Talos shrine defiance also applied Concordat pressure.")
    else
        Manager.Trace(2, "Talos shrine defiance awarded without Concordat pressure for non-Imperial origin.")
    endIf
EndFunction

Function HandleThalmorUnprovokedKill(Form victimForm)
    ; Mattered to Altmer (alignment) and Imperials (Concordat) for different reasons; every
    ; other race ignored it. Both signals fire, only the live adapter answers one.
    ; See references/authoring/PDV_2_0_ORIGIN_SwitchboardReversal.md for the original.
    Manager.OriginRuntime.HandleContextualSignal("kill_thalmor_agent", "thalmor_unprovoked_kill", victimForm)
    Manager.OriginRuntime.HandleContextualSignal("kill_thalmor_justiciar_unprovoked", "thalmor_unprovoked_kill", victimForm)
EndFunction

Bool Function IsSyrabaneSignalEligible()
    return IsAltmerOrigin() && Manager.PDV_Syrabane && !IsAltmerFavorSuppressedByCurse()
EndFunction

Function HandleShoutAttack(Int eventType, Actor playerRef, Shout shoutUsed, String reason)
    if !playerRef
        Manager.Trace(1, "Shout attack skipped: player ref missing.")
        return
    endIf

    if Manager.ShouldSuppressDuplicateShoutAttack()
        Manager.Trace(3, "Shout attack duplicate suppressed (" + reason + ")")
        return
    endIf

    if !Manager.LedgerRuntime.PDV_FLST_AllDeities
        Manager.Trace(1, "Shout attack skipped: deity roster missing.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ShoutAttack")
    if multiplier <= 0.0
        Manager.Trace(2, "Shout attack decayed out for today; no piety award.")
        return
    endIf

    Int i = 0
    Int count = Manager.LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    Int scoredCount = 0
    Manager.LedgerRuntime.BeginBroadPantheonEvent("shout_attack_" + eventType + "_" + reason)

    while i < count
        PDV_DeityBase deity = Manager.LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float delta = deity.ScoreAction(eventType, playerRef as Form, shoutUsed as Form)
            if delta != 0.0
                Manager.LedgerRuntime.AwardPietyFromLikesDislikes(deity, delta * multiplier, eventType, reason)
                scoredCount += 1
            endIf
        endIf

        i += 1
    endWhile
    Manager.LedgerRuntime.FlushBroadPantheonEvent()

    Manager.Trace(2, "Shout attack routed: event " + eventType + ", scored deities " + scoredCount + " (" + reason + ")")
EndFunction

Function EmitBookOfDaysBroadLaneTierChange(Int today)
    Int originRace = GetPlayerOriginRaceIndex()
    Int broadTier = GetBroadLaneTierForOrigin(originRace)
    if broadTier <= Manager.LedgerRuntime.TIER_NONE
        return
    endIf

    Int tier = Manager.LedgerRuntime.TIER_SEEKER
    while tier <= broadTier && tier <= Manager.LedgerRuntime.TIER_DEVOTED
        String guard = "PDV.BookOfDays.BroadLaneTierShown." + originRace + "." + tier
        if StorageUtil.GetIntValue(None, guard) != 1
            StorageUtil.SetIntValue(None, guard, 1)
            Manager.AppendBookOfDaysEntry(BuildBroadLaneTierReachJournalLine(originRace, tier), today, "tier.reach", GetBroadLaneSymbol(originRace), False, tier)
        endIf
        tier += 1
    endWhile
EndFunction

String Function BuildBroadLaneTierReachJournalLine(Int originRace, Int tier)
    return GetBroadLaneDisplayName(originRace) + " has reached " + GetBroadLaneStandingLabel(originRace, tier) + "."
EndFunction

Function HandleWayfarerAkatoshLevel()
    if !Manager.LedgerRuntime.PDV_ModePresetRef || !Manager.LedgerRuntime.PDV_ModePresetRef.AllowCheapRepeatables()
        return
    endIf
    if !Manager.LedgerRuntime.PDV_Akatosh
        return
    endIf

    Float baseAmount = 1.0
    Float weight = Manager.LedgerRuntime.PDV_ModePresetRef.CheapRepeatableWeight()
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.WayfarerAkatoshLevel")
    Float amount = baseAmount * weight * multiplier
    if amount > 0.0
        Manager.LedgerRuntime.AwardPietyInternal(Manager.LedgerRuntime.PDV_Akatosh, amount, True, "wayfarer_akatosh_level")
    endIf
EndFunction

Bool Function IsBroadLaneLapsed()
    ; Broad-lane recency lapse: a full-pantheon (broad) worshipper who has practiced at least once
    ; and then goes quiet for NEGLECT_LAPSE_GRACE_DAYS feels gentle neglect too. Generalizes the
    ; Imperial civic-lapse model to the broad lane, keyed off the global PDV.Devotion.LastActTime.
    if !Manager.LedgerRuntime.IsBroadWorshipActive()
        return False
    endIf
    Float lastAct = StorageUtil.GetFloatValue(None, "PDV.Devotion.LastActTime")
    if lastAct <= 0.0
        return False
    endIf
    return (Utility.GetCurrentGameTime() - lastAct) > Manager.LedgerRuntime.NEGLECT_LAPSE_GRACE_DAYS
EndFunction

Bool Function IsBroadFloorEligible()
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_BROAD
        return False
    endIf
    Int origin = GetPlayerOriginRaceIndex()
    if !HasBroadLanePresentation(origin)
        return False
    endIf
    return GetBroadLaneServiceCount(origin) >= 3
EndFunction

Int Function GetBroadFloorServiceCount(Int origin)
    return GetBroadLaneServiceCount(origin)
EndFunction

Bool Function HasBroadLanePresentation(Int origin)
    return origin == Manager.ORIGIN_IMPERIAL || origin == Manager.ORIGIN_BRETON || origin == Manager.ORIGIN_ORC || origin == Manager.ORIGIN_ALTMER || origin == Manager.ORIGIN_NORD || origin == Manager.ORIGIN_BOSMER || origin == Manager.ORIGIN_DUNMER || origin == Manager.ORIGIN_REDGUARD
EndFunction

Float Function GetBroadLaneStandingValue(Int origin)
    if origin == Manager.ORIGIN_IMPERIAL || origin == Manager.ORIGIN_NORD
        return Manager.LedgerRuntime.GetBroadPantheonStanding(Manager.LedgerRuntime.GetActiveBroadPantheonPoolId())
    endIf
    return GetBroadLaneServiceCount(origin) as Float
EndFunction

Float Function GetBroadLaneScratchValue(Int origin)
    if origin == Manager.ORIGIN_IMPERIAL || origin == Manager.ORIGIN_NORD
        return Manager.LedgerRuntime.GetBroadPantheonScratch(Manager.LedgerRuntime.GetActiveBroadPantheonPoolId())
    endIf
    return 0.0
EndFunction

Int Function GetBroadLaneServiceCount(Int origin)
    ; 'origin' is vestigial: every caller passed the player's own race. Kept so call sites
    ; are unchanged.
    ; See references/authoring/PDV_2_0_ORIGIN_SwitchboardReversal.md for the original.
    return Manager.OriginRuntime.GetOriginDetailValue("broad-lane-service-count")
EndFunction

Int Function GetBroadLaneTierForOrigin(Int origin)
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_BROAD || !HasBroadLanePresentation(origin)
        return Manager.LedgerRuntime.TIER_NONE
    endIf

    Int count = GetBroadLaneServiceCount(origin)
    if origin == Manager.ORIGIN_IMPERIAL || origin == Manager.ORIGIN_NORD
        Float standing = GetBroadLaneStandingValue(origin)
        if standing >= Manager.LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD
            return Manager.LedgerRuntime.TIER_DEVOTED
        elseIf standing >= Manager.LedgerRuntime.BROAD_PANTHEON_SEEKER_THRESHOLD
            return Manager.LedgerRuntime.TIER_SEEKER
        endIf
        return Manager.LedgerRuntime.TIER_NONE
    elseIf count >= 6
        return Manager.LedgerRuntime.TIER_DEVOTED
    elseIf count >= 3
        return Manager.LedgerRuntime.TIER_SEEKER
    endIf
    return Manager.LedgerRuntime.TIER_NONE
EndFunction

String Function GetBroadLaneDisplayName(Int origin)
    ; 'origin' is vestigial -- see GetBroadLaneServiceCount.
    String laneName = Manager.OriginRuntime.GetOriginDetailLabel("broad-lane-name")
    if laneName != ""
        return laneName
    endIf
    return "Broad Faith"
EndFunction

String Function GetBroadLaneSymbol(Int origin)
    ; 'origin' is vestigial -- see GetBroadLaneServiceCount.
    String laneSymbol = Manager.OriginRuntime.GetOriginDetailLabel("broad-lane-symbol")
    if laneSymbol != ""
        return laneSymbol
    endIf
    return "journal"
EndFunction

String Function GetBroadLaneStandingLabel(Int origin, Int tier)
    if tier >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Faithful"
    elseIf tier >= Manager.LedgerRuntime.TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
EndFunction

String Function GetBroadLaneNextThresholdText(Int origin)
    Int count = GetBroadLaneServiceCount(origin)
    if origin == Manager.ORIGIN_IMPERIAL || origin == Manager.ORIGIN_NORD
        Float standing = GetBroadLaneStandingValue(origin)
        if standing < Manager.LedgerRuntime.BROAD_PANTHEON_SEEKER_THRESHOLD
            return "Observant at 25 pantheon standing"
        elseIf standing < Manager.LedgerRuntime.BROAD_PANTHEON_FAITHFUL_THRESHOLD
            return "Faithful at 50 pantheon standing"
        endIf
        return "Pantheon standing cap reached"
    endIf
    if origin == Manager.ORIGIN_BRETON
        if count < Manager.BRETON_PRACTICE_SEEKER_POINTS
            return "Observant at 25 practice points"
        elseIf count < Manager.BRETON_PRACTICE_DEVOTED_POINTS
            return "Faithful at 50 practice points"
        endIf
        return "Practice cap reached"
    endIf
    if count < 3
        return "Observant at 3 broad acts"
    elseIf count < 6
        return "Faithful at 6 broad acts"
    endIf
    return "Broad lane cap reached"
EndFunction

Bool Function HandleTalosBetrayal(Int severity, String sourceReason)
    if !Manager.PDV_Talos
        Manager.Trace(1, "Talos betrayal skipped: PDV_Talos missing.")
        return False
    endIf

    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE || Manager.GetActiveDeity() != Manager.PDV_Talos
        Manager.Trace(2, "Talos betrayal skipped: active patron is not Talos.")
        return False
    endIf

    Int originRace = GetPlayerOriginRaceIndex()
    if originRace != Manager.ORIGIN_IMPERIAL && originRace != Manager.ORIGIN_NORD
        Manager.Trace(2, "Talos betrayal skipped: origin is not Imperial or Nord.")
        return False
    endIf

    if originRace == Manager.ORIGIN_IMPERIAL
        if !Manager.PDV_ConcordatStandingTrack
            Manager.Trace(1, "Imperial Talos betrayal skipped: ConcordatStanding track missing.")
            return False
        endIf
        if Manager.PDV_ConcordatStandingTrack.GetValue() > 50
            Manager.Trace(2, "Imperial Talos betrayal skipped: raw ConcordatStanding is already compliant.")
            return False
        endIf
    endIf

    Int normalizedSeverity = 2
    if severity >= 3
        normalizedSeverity = 3
    endIf

    String reason = "talos_betrayal_compliance"
    String surfaceText = "You bent the knee where you once stood firm. The old faith feels distant."
    Float pietyLoss = -2.0
    Int concordatPressure = 15
    if normalizedSeverity >= 3
        reason = "talos_betrayal_major"
        surfaceText = "You turned on the Ninth in the open. The defiance that was faith is gone."
        pietyLoss = -3.0
        concordatPressure = 25
    endIf

    if originRace == Manager.ORIGIN_IMPERIAL
        reason = "imperial_" + reason
    else
        reason = "nord_" + reason
    endIf

    ; fix-plan 4.2: one betrayal charge per devotional day.
    String dayKey = "PDV.Creed." + reason + ".Day"
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp(dayKey) == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        Manager.Trace(2, "Talos betrayal suppressed for " + reason + ": already applied today.")
        return False
    endIf

    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(dayKey)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Creed.LastTalosBetrayalSource", sourceReason)

    Manager.LedgerRuntime.AwardPiety(Manager.PDV_Talos, pietyLoss, reason)
    Manager.OriginRuntime.HandleContextualSignal("concordat-pressure", reason, None, concordatPressure as Float)

    Manager.SendPrismaEventToast("creed", Manager.PDV_Talos, surfaceText, "", "")
    Manager.SurfaceTransition("creed", "Talos betrayal", "drop", Manager.PDV_Talos.DeityIndex, "betrayal")
    Manager.Trace(2, "Talos betrayal applied: " + reason + " piety=" + pietyLoss + " source=" + sourceReason)
    return True
EndFunction

PDV_SubstrateBase Function GetSubstrateForPacingOrigin(Int originValue)
    if originValue == Manager.ORIGIN_IMPERIAL
        return Manager.PDV_ImperialAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == Manager.ORIGIN_DUNMER
        return Manager.PDV_DunmerAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == Manager.ORIGIN_ARGONIAN
        return Manager.PDV_ArgonianHistSubstrate as PDV_SubstrateBase
    elseIf originValue == Manager.ORIGIN_NORD
        return Manager.PDV_NordAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == Manager.ORIGIN_ALTMER
        return Manager.PDV_AltmerAncestorSubstrate as PDV_SubstrateBase
    elseIf originValue == Manager.ORIGIN_KHAJIIT
        return Manager.PDV_KhajiitLunarSubstrate as PDV_SubstrateBase
    endIf
    return None
EndFunction

String Function GetSubstrateDecaySummary(Int originValue)
    if originValue == Manager.ORIGIN_DUNMER || originValue == Manager.ORIGIN_KHAJIIT
        return "none"
    elseIf originValue == Manager.ORIGIN_IMPERIAL || originValue == Manager.ORIGIN_ARGONIAN || originValue == Manager.ORIGIN_NORD || originValue == Manager.ORIGIN_ALTMER
        return "3-day grace, -1/dawn, floor 20 (curse floor 0)"
    endIf
    return "n/a"
EndFunction

Function ResetSubstratePacingState(Int originValue)
    if originValue == Manager.ORIGIN_IMPERIAL && Manager.PDV_ImperialAncestorSubstrate
        Manager.PDV_ImperialAncestorSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ImperialCivicService")
    elseIf originValue == Manager.ORIGIN_DUNMER && Manager.PDV_DunmerAncestorSubstrate
        Manager.PDV_DunmerAncestorSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.DunmerPortableShrinePrayer")
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.DunmerHomeBonus")
    elseIf originValue == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        Manager.PDV_ArgonianHistSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianHistMaintenance")
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianPeopleSupport")
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianBedOfChoice")
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.ArgonianVoidSignal")
    elseIf originValue == Manager.ORIGIN_NORD && Manager.PDV_NordAncestorSubstrate
        Manager.PDV_NordAncestorSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.NordAncestorSpine")
        StorageUtil.SetIntValue(None, "PDV.Signal.NordAncestralRest.Day", -1)
    elseIf originValue == Manager.ORIGIN_ALTMER && Manager.PDV_AltmerAncestorSubstrate
        Manager.PDV_AltmerAncestorSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.AltmerAncestorSpine")
    elseIf originValue == Manager.ORIGIN_KHAJIIT && Manager.PDV_KhajiitLunarSubstrate
        Manager.PDV_KhajiitLunarSubstrate.ResetPilotForDebug()
        Manager.LedgerRuntime.ResetDailyRepeatKey("PDV.Signal.KhajiitRoadHome")
        StorageUtil.SetIntValue(None, "PDV.Khajiit.RoadHome.PresentationDay", 0)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.RoadHome.PresentationDay.Encoding", 2)
    endIf
EndFunction

Bool Function IsCurseStateLoadReconciliation(String reason)
    return reason == "eventbus_Load" || reason == "eventbus_alias_init"
EndFunction

String Function GetCurseContextForRace(String phase, String curseType)
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_NORD
        if phase == "onset" && curseType == "vampire"
            return "Sovngarde is closed while the thirst remains."
        elseIf phase == "cure" && curseType == "vampire"
            return "The road opens again. The scar remains."
        elseIf phase == "onset" && curseType == "werewolf"
            return "The hunt pulls against Sovngarde."
        endIf
    elseIf originRace == Manager.ORIGIN_ALTMER
        if phase == "onset" && curseType == "vampire"
            return "Auri-El's light is closed. Only exile remains."
        elseIf phase == "cure" && curseType == "vampire"
            return "Exiled from the dawn, not restored to it."
        elseIf phase == "onset" && curseType == "werewolf"
            return "Devotion stops here. You have become a beast."
        endIf
    elseIf originRace == Manager.ORIGIN_BOSMER
        if phase == "onset"
            return "The Green Pact does not speak to what you have become."
        endIf
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        if phase == "onset" && curseType == "vampire"
            return "The Hist recoils from what stirs in your blood."
        elseIf phase == "onset" && curseType == "werewolf"
            return "The Hist feels the hunt-shape pulling at your form."
        endIf
    elseIf originRace == Manager.ORIGIN_ORC
        if phase == "onset"
            return "Malacath's code bends under this new shape."
        endIf
    endIf
    return ""
EndFunction

Bool Function SendPrismaSubstrateToast(String substrate, String phase, String context, String symbolName, String stateLabel, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"substrate\""
    j = j + ",\"substrate\":\"" + PDV_DevotionRules.JsonSafeString(substrate) + "\""
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if stateLabel != ""
        j = j + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(stateLabel) + "\""
    endIf
    j = j + "}}"
    String fallbackTitle = stateLabel
    if fallbackTitle == ""
        fallbackTitle = substrate
    endIf
    return Manager.SendPrismaToastPayloadOrFallback(j, fallbackTitle, context, allowFallback)
EndFunction

String Function GetMedallionSectionsJson(Int originRace)
    ; 'originRace' is vestigial. The adapter returns its OWN fully-wrapped sections, which is
    ; how Bosmer emits two (native + path focus) without the base knowing it is Bosmer.
    ; See references/authoring/PDV_2_0_ORIGIN_SwitchboardReversal.md for the original.
    String sections = Manager.OriginRuntime.GetOriginDetailLabel("medallion-sections")
    if sections != ""
        return sections
    endIf

    return MedallionSection("native", "Native worship", Manager.MedallionEntry("unknown", "Devotion", "substrate", "journal", None, False, "Your origin is not settled yet.", "Once your origin is known, the medallion can show the roster your people can name.", "Origin readback is pending."))
EndFunction

String Function MedallionSection(String sectionId, String titleText, String entriesJson)
    return "{\"section_id\":\"" + PDV_DevotionRules.JsonSafeString(sectionId) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"entries\":[" + entriesJson + "]}"
EndFunction

; Delegates to the manager so there is exactly ONE implementation. Kept here because ~255
; in-module callers use the bare name.
Int Function GetPlayerOriginRaceIndex()
    if Manager
        return Manager.GetPlayerOriginRaceIndex()
    endIf

    return -1
EndFunction

Bool Function IsFocusedPantheonBoonSuspended()
    Int originRace = GetPlayerOriginRaceIndex()
    if originRace != Manager.ORIGIN_IMPERIAL && originRace != Manager.ORIGIN_NORD
        return False
    endIf
    return Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() && Manager.LedgerRuntime.GetPiety(Manager.GetActiveDeity()) < Manager.LedgerRuntime.COMMITMENT_OFFER_THRESHOLD
EndFunction

String Function GetPlayerCursePublicLabel()
    String originCurseLabel = Manager.OriginRuntime.GetOriginDetailLabel("curse-public-label")
    if originCurseLabel != ""
        return originCurseLabel
    endIf

    if Manager.PDV_CurseStateService
        String curseLabel = Manager.PDV_CurseStateService.GetCurseStateLabel()
        if curseLabel != "None"
            return curseLabel
        endIf
    endIf

    if Manager.OriginRuntime.GetOriginDetailValue("vampire-scar") == 1
        return "Cured vampire scar"
    endIf

    return "None"
EndFunction

Float Function GetTalosTrackGainMultiplier()
    if Manager.PDV_Talos
        return Manager.PDV_Talos.GetTrackGainMultiplier()
    endIf

    return 1.0
EndFunction

Float Function GetTalosEffectiveGainMultiplier()
    if Manager.PDV_Talos
        return Manager.PDV_Talos.GetEffectiveGainMultiplier()
    endIf

    return 1.0
EndFunction

String Function GetCurseStateSummary()
    if !Manager.PDV_CurseStateService
        return "missing"
    endIf

    return Manager.PDV_CurseStateService.GetCurseStateLabel()
EndFunction

String Function GetCurseHandlerSummary()
    return "origin=" + GetOriginRaceLabel(GetPlayerOriginRaceIndex()) + ";bosmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Bosmer.RoutePressure") + ";breton=" + StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState") + ";dunmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture") + ";argonian=" + StorageUtil.GetIntValue(None, "PDV.Curse.Argonian.HistPosture") + ";orc=" + StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure") + ";redguard=" + StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure") + ";altmer=" + StorageUtil.GetIntValue(None, "PDV.Curse.Altmer.ExilePressure") + ";altmerVampire=" + StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileActive") + ";altmerWerewolf=" + StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHalt")
EndFunction

String Function GetOriginRaceLabel(Int originRace)
    if originRace == Manager.ORIGIN_NORD
        return "Nord"
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        return "Imperial"
    elseIf originRace == Manager.ORIGIN_BRETON
        return "Breton"
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "Altmer"
    elseIf originRace == Manager.ORIGIN_BOSMER
        return "Bosmer"
    elseIf originRace == Manager.ORIGIN_DUNMER
        return "Dunmer"
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        return "Khajiit"
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        return "Argonian"
    elseIf originRace == Manager.ORIGIN_ORC
        return "Orc"
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "Redguard"
    endIf

    return "" + originRace
EndFunction



; ---------------------------------------------------------------------------
; ADAPTER INTERFACE -- the base virtual surface (ADR: PDV_2_0_ADR_OriginAdapterInterface)
;
; These 19 verbs are the ONLY way a caller outside ORIGIN may reach race
; behaviour. Each PDV_OriginRuntime_<Race> adapter overrides the ones its race
; implements; every default below is deliberately inert, so a signal sent to the
; wrong origin returns False / "" / 0 and changes nothing. Wrong-origin silence
; is therefore structural rather than re-checked inside each handler.
;
; Adapter overrides DELEGATE to the existing named race functions, whose bodies
; are unchanged -- that is what keeps the split provable against origin_golden.
; ---------------------------------------------------------------------------

; -- Lifecycle --
Function ApplyInitialChoice(Int choiceValue, String reason)
EndFunction

Function EnsureRuntimeWiring()
EndFunction

Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
EndFunction

Function EvaluateAtDawn()
EndFunction

; -- State --
String Function GetOriginStateLabel()
    return ""
EndFunction

Int Function GetOriginStateValue()
    return 0
EndFunction

String Function GetOriginSummary()
    return ""
EndFunction

String Function GetSurveyFragment()
    return ""
EndFunction

Bool Function IsRaceLaneNeglected()
    return False
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    return 0
EndFunction

; -- Signals --
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    return False
EndFunction

; Value-returning sibling of HandleContextualSignal, for the few lane entry points whose
; RETURN a caller actually consumes -- HandleContextualSignal's Bool means handled/not-handled
; and cannot carry a payload. Two known cases: the Khajiit moon-observation generation token
; (PDV_ObserveMoonsEffect reads it and rejects stale completions) and the Altmer practice-focus
; value the EventBus returns onward. Actor extends Form, so a player argument rides contextForm.
; 0 is the inert default: no adapter answered, nothing happened.
Int Function HandleContextualQuery(String signalId, String reason = "", Form contextForm = None)
    return 0
EndFunction

Function HandleLocationChange(Form newLocation = None)
EndFunction

; -- Upkeep --
Function SyncRaceRewards()
EndFunction

Function SyncNeglectSpells()
EndFunction

; -- Patron and offers --
Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return False
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    return None
EndFunction

; -- Presentation --
Function ShowOriginNotification(Message messageRecord, String fallbackText)
EndFunction

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
EndFunction

; -- Gain provider. The curse factor is NOT race-gated (it reads curse state and a deity
;    check), so the base owns it for every race. A race adapter that adds its own factor
;    MUST compose with Parent so this one is not lost. Applies on award and on decay --
;    the same scalar, sourced once. --

; Cross-race curse factor. Moved from PDV__ManagerQuest in the provider seam (Phase A3, D1)
; so the provider no longer reaches back through Manager for the scalar it owns. Curse-state
; and Hircine-path reads qualify through the Manager backref (properties consolidate in
; Phase F).
Float Function GetCurseGainMultiplier(PDV_DeityBase deity)
    if !deity || !Manager.PDV_CurseStateService
        return 1.0
    endIf

    if deity == Manager.PDV_HircinePath
        if Manager.PDV_CurseStateService.IsWerewolf()
            return 1.5
        elseIf Manager.PDV_CurseStateService.IsVampire()
            return 0.5
        endIf
    endIf

    return 1.0
EndFunction

Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    if phase == Manager.PHASE_PER_EVENT || phase == Manager.PHASE_DECAY
        return GetCurseGainMultiplier(deity)
    endIf

    return 1.0
EndFunction
