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
    if !Manager.PDV_BosmerPathTrack
        return 0
    endIf
    Int currentPath = Manager.PDV_BosmerPathTrack.GetCurrentState()
    if currentPath <= 0
        return 0
    endIf
    return Manager.PDV_BosmerPathTrack.GetRecentEvidenceDayCount(currentPath, 7)
EndFunction

Bool Function TryAltmerDisciplinesRite(Actor playerRef, String reason)
    if !playerRef || !Manager.PDV_MESG_AltmerDisciplines || !IsAltmerOrigin()
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.Alt.Disc.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    ; GetDevotionalDay can be -1 before the first 06:00 boundary. Reserve zero
    ; exactly as the shared substrate stamp does so a first-day decline sticks.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int lastDeclineStamp = StorageUtil.GetIntValue(None, "PDV.Alt.Disc.LastDeclineDay")
    if lastDeclineStamp > 0 && (todayStamp - lastDeclineStamp) < 3
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_AltmerDisciplines.Show()
    ; B4 / fix-plan 3. Show() returns -1 when another menu or message is already up
    ; (routine right after sleep in a heavy list). That is "not shown", never a choice:
    ; no decline stamp, no state change, and the caller is told the menu did NOT appear
    ; so the ancestral dream is not suppressed for a rite that never ran. The rite
    ; retries at its next natural trigger.
    if pressed < 0
        Manager.Trace(2, "Altmer Disciplines rite not shown (menu busy); no decline stamped.")
        return false
    endIf
    if pressed > 3
        StorageUtil.SetIntValue(None, "PDV.Alt.Disc.LastDeclineDay", todayStamp)
        return true                 ; "Not yet" -- short prompt cooldown only
    endIf

    StorageUtil.SetIntValue(None, "PDV.Alt.Disc.LastDeclineDay", 0)
    ApplyAltmerDiscipline(playerRef, pressed)
    return true
EndFunction

Function ApplyAltmerDiscipline(Actor playerRef, Int index)
    RemoveAltmerDisciplineSpells(playerRef)
    Spell chosen = GetAltmerDisciplineSpell(index)
    if !chosen
        return
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.Alt.Disc.Active", index + 1)
    StorageUtil.SetFloatValue(None, "PDV.Alt.Disc.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Auri-El pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    Manager.LedgerRuntime.AwardPiety(Manager.PDV_AuriEl, 0.5, "Set a Discipline of Return")
    Manager.AppendBookOfDaysEntry("You set a discipline of the Return. The road back is walked daily.", Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False)
    Manager.SendPrismaToast("auriel", "good", "Discipline of Return", "It holds while you hold to the path.")
    Manager.Trace(2, "Altmer Discipline of Return applied: " + index)
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

Function HandleAltmerSleepEvents(Actor playerRef, String reason)
    if !playerRef || !IsAltmerOrigin() || IsAltmerFavorSuppressedByCurse()
        return
    endIf

    if TryAltmerDisciplinesRite(playerRef, reason)
        return                          ; Disciplines menu shown; suppress the dream this wake
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerAncestralDream")
    if multiplier <= 0.0
        return
    endIf

    AwardAltmerAncestorSpinePulse(multiplier, "sleep_dream_" + reason)
    ; P4 (2026-08-03): graded rather than patron-only. This was `_activeDeity == PDV_Magnus`, which
    ; meant a follower who had not formally committed to Magnus got NOTHING from the sleep lane --
    ; and since 1802 is finite at 24 lifetime awards and 1804 is patron-only too, that left them
    ; with no curated income at all. A Seeker-or-better non-patron now gets half. The patron lane
    ; stays strictly better, so this widens access without flattening the commitment choice.
    if Manager.PDV_Magnus
        if Manager.GetActiveDeity() == Manager.PDV_Magnus
            AwardAltmerDawnSignal("magnus_sleep_dream_" + reason, multiplier)
        elseIf Manager.LedgerRuntime.GetTier(Manager.PDV_Magnus) >= Manager.LedgerRuntime.TIER_SEEKER
            AwardAltmerDawnSignal("magnus_sleep_dream_" + reason, multiplier * 0.5)
        endIf
    endIf
    ; P2 (2026-08-04): the hardcoded Book of Days line that used to sit here is gone.
    ; AwardAltmerAncestorSpinePulse now writes it via GetAltmerHeritageSourceLine, gated on the day
    ; credit actually landing. Keeping it here too would double-log the sleep feed and would report
    ; a dream on days the credit was already spent.
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
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerRejectedLorkhanSurface(sourceId)
        RecordAltmerRejectedSurface(sourceId, "lorkhan_surface_rejected")
        Manager.Trace(2, "Altmer Lorkhan pressure rejected for source " + sourceId)
        return
    endIf

    if pressureTier < Manager.ALTMER_LORKHAN_PRESSURE_DIRECT
        pressureTier = Manager.ALTMER_LORKHAN_PRESSURE_DIRECT
    elseIf pressureTier > Manager.ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
        pressureTier = Manager.ALTMER_LORKHAN_PRESSURE_CONTEXTUAL
    endIf

    StorageUtil.SetFloatValue(None, "PDV.Altmer.LastLorkhanPressureDay", Utility.GetCurrentGameTime())
    StorageUtil.SetIntValue(None, "PDV.Altmer.LastLorkhanPressureTier", pressureTier)
    StorageUtil.SetStringValue(None, "PDV.Altmer.LastLorkhanPressureSource", sourceId)
    StorageUtil.SetIntValue(None, "PDV.Altmer.LorkhanPressureCount", StorageUtil.GetIntValue(None, "PDV.Altmer.LorkhanPressureCount") + 1)

    ; The defining Altmer friction: Lorkhan adjacency costs piety. Deduct the tiered
    ; penalty from the deity the player is building (Auri-El foundation by default),
    ; scaled by the ThalmorAlignment faction modifier. It flows through the normal
    ; scratch / daily-clamp path, so it paces with the rest of the economy.
    Float lorkhanPenalty = GetAltmerLorkhanPietyPenalty(pressureTier) * GetAltmerLorkhanFactionModifier()
    if lorkhanPenalty > 0.0
        PDV_DeityBase lorkhanDeity = Manager.GetActiveDeity()
        if !lorkhanDeity
            lorkhanDeity = Manager.PDV_AuriEl
        endIf
        if lorkhanDeity
            Manager.LedgerRuntime.AwardPiety(lorkhanDeity, -lorkhanPenalty)
            Manager.Trace(2, "Altmer Lorkhan penalty applied: -" + lorkhanPenalty + " to " + lorkhanDeity.DeityName)
        endIf
    endIf

    if pressureTier >= Manager.ALTMER_LORKHAN_PRESSURE_MORTAL_VALIDATION && GetAltmerCrisisState() == Manager.ALTMER_CRISIS_NONE
        SetAltmerCrisisState(Manager.ALTMER_CRISIS_DISSONANT, "lorkhan_pressure_" + sourceId)
    endIf

    Manager.Trace(2, "Altmer Lorkhan pressure routed: tier " + pressureTier + " source " + sourceId)
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
    if !IsAltmerOrigin()
        return
    endIf

    Int sourceFormId = 0
    if sourceForm
        sourceFormId = sourceForm.GetFormID()
    endIf
    String guardKey = "PDV.Altmer.Alignment." + actionKey + "." + sourceFormId
    if StorageUtil.GetIntValue(None, guardKey) > 0
        Manager.Trace(2, "Altmer alignment signal skipped (one-shot): " + actionKey + " " + sourceFormId)
        return
    endIf
    StorageUtil.SetIntValue(None, guardKey, 1)

    ApplyAltmerAlignmentAction(actionKey, reason)
EndFunction

Function HandleAltmerCrisisSource(Int crisisSource, String sourceId)
    if !IsAltmerOrigin()
        return
    endIf

    if crisisSource < Manager.ALTMER_CRISIS_SOURCE_DRAGONBORN || crisisSource > Manager.ALTMER_CRISIS_SOURCE_COMPANIONS
        RecordAltmerRejectedSurface(sourceId, "unknown_crisis_source")
        return
    endIf

    String seenKey = "PDV.Altmer.CrisisSeen." + crisisSource
    if StorageUtil.GetIntValue(None, seenKey) == 1
        RecordAltmerRejectedSurface(sourceId, "repeat_crisis_source")
        return
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    StorageUtil.SetIntValue(None, "PDV.Altmer.CrisisSource", crisisSource)
    StorageUtil.SetStringValue(None, "PDV.Altmer.CrisisSourceId", sourceId)
    StorageUtil.SetFloatValue(None, "PDV.Altmer.CrisisStartedAt", Utility.GetCurrentGameTime())

    if crisisSource == Manager.ALTMER_CRISIS_SOURCE_DRAGONBORN || crisisSource == Manager.ALTMER_CRISIS_SOURCE_SOVNGARDE
        SetAltmerCrisisState(Manager.ALTMER_CRISIS_DISSONANT, sourceId)
    elseIf crisisSource == Manager.ALTMER_CRISIS_SOURCE_TALOS || crisisSource == Manager.ALTMER_CRISIS_SOURCE_COMPANIONS
        SetAltmerCrisisState(Manager.ALTMER_CRISIS_QUESTIONING, sourceId)
    endIf

    Manager.Trace(1, "Altmer crisis source accepted: " + GetAltmerCrisisSourceLabel(crisisSource) + " (" + sourceId + ")")
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
    if !IsAltmerOrigin()
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        RecordAltmerRejectedSurface(reason, "curse_suppressed_altmer_favor")
        Manager.FavorRuntime.ClearActiveFavor("altmer_curse")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.AltmerDawnSteadiness")

    RecordAltmerSourceFavor(Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    Manager.FavorRuntime.TryActivateContextualFavor(Manager.FavorRuntime.FAVOR_LANE_ALTMER, Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_DAWN_STEADINESS, reason)
    if multiplier > 0.0
        AwardAltmerDawnSignal(reason, multiplier)
        ; Passive dawn acknowledgement is piety-only. Curated Auri-El/Magnus
        ; books and the exact MG08 source are finite heritage substitutes.
        if PDV_DevotionRules.StringContainsToken(reason, "eventbus_p2_altmer_auriel_") || PDV_DevotionRules.StringContainsToken(reason, "eventbus_p2_altmer_magnus_")
            AwardAltmerAncestorSpinePulse(1.0, "curated_heritage_" + reason)
        endIf
    endIf
    if Manager.ConsumeOncePerDaySignal("PDV.Signal.AltmerAlignmentRite")
        ApplyAltmerAlignmentAction("orthodox_rite", "rite_" + reason)
    endIf
    Bool crisisTransitioned = RecordAltmerCrisisReassertEvidence("dawn_steadiness_" + reason)
    AwardActiveAltmerHeritageMemorySignal()
    if !crisisTransitioned && reason == "eventbus_p2_altmer_auriel_po3_book_altmer_auriel"
        Manager.SurfaceP2BookReadNotice(reason, "Auri-El's dawn", "The morning rite settles deeper.")
    elseIf !crisisTransitioned && reason == "eventbus_p2_altmer_magnus_po3_book_altmer_magnus"
        Manager.SurfaceP2BookReadNotice(reason, "The road of Magnus", "The discipline of light holds you to the dawn.")
    endIf
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
    if !IsAltmerOrigin() || !Manager.PDV_Trinimac
        return
    endIf

    if IsAltmerFavorSuppressedByCurse()
        RecordAltmerRejectedSurface(reason, "curse_suppressed_altmer_favor")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.TrinimacFallenGodOrthodoxy")
    if multiplier > 0.0
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Trinimac, Manager.PDV_Trinimac.SIGNAL_FALLEN_GOD_ORTHODOXY, None, multiplier)
    endIf
    Manager.SurfaceP2BookReadNotice(reason, "Trinimac remembered", "Trinimac is named as he was, not as he was made.")

    HandleAltmerOrthodoxCostlyEnforcement(reason)
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
    ; A non-Altmer holding the calian gets nothing and is told nothing -- it is not their object and
    ; there is no refusal to explain. The curse case IS explained, because that player owns the
    ; calian and needs to know the silence is their state and not a broken item.
    if !IsAltmerOrigin()
        return 0
    endIf

    if IsAltmerFavorSuppressedByCurse()
        ShowAltmerNotification(Manager.PDV_Notif_Altmer_Calian_Unanswered, "The calian does not warm to you now.")
        return 0
    endIf

    ; ONE cap across every lane, so switching patron cannot buy a second practice in a day.
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.AltmerPracticeFocus")
        ShowAltmerNotification(Manager.PDV_Notif_Altmer_Calian_AlreadyKept, "Your calian is already warm from today's practice.")
        return GetAltmerPracticeIdleKind()
    endIf

    ; Claim the substrate day. The spine takes one +4.0 credit per devotional day whatever claims
    ; it, so this adds no income -- it adds a way to claim the day that works indoors, in a jail
    ; cell, mid-dungeon, anywhere the outdoor dawn observance cannot reach.
    AwardAltmerAncestorSpinePulse(1.0, "practice_focus_" + reason)

    ; Then the active lane's own signal. Deliberately routed to the PATRON's lane rather than a
    ; fixed deity: the point is that practice feeds whatever you actually worship.
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        if Manager.GetActiveDeity() == Manager.PDV_Magnus && Manager.PDV_Magnus
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Magnus, Manager.PDV_Magnus.SIGNAL_APERTURE_KEPT, None, 1.0)
        elseIf Manager.GetActiveDeity() == Manager.PDV_Xarxes && Manager.PDV_Xarxes
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Xarxes, Manager.PDV_Xarxes.SIGNAL_RECORD_KEPT, None, 1.0)
        elseIf Manager.GetActiveDeity() == Manager.PDV_Trinimac && Manager.PDV_Trinimac
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Trinimac, Manager.PDV_Trinimac.SIGNAL_FALLEN_GOD_ORTHODOXY, None, 1.0)
        elseIf Manager.GetActiveDeity() == Manager.PDV_Syrabane && Manager.PDV_Syrabane
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_PROTECTIVE_WARDING, None, 1.0)
        elseIf Manager.GetActiveDeity() == Manager.PDV_AuriEl && Manager.PDV_AuriEl
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_AuriEl, Manager.PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None, 1.0)
        endIf
    elseIf Manager.PDV_AuriEl
        ; No patron, or broad worship: the foundation takes it. This is the ONLY arm that credits
        ; Auri-El without him being chosen, and it requires a deliberate act -- unlike the free
        ; dawn pulse P18 removed.
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_AuriEl, Manager.PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT, None, 1.0)
    endIf

    Manager.Trace(2, "Altmer practice focus routed (" + reason + ")")
    return GetAltmerPracticeIdleKind()
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
    if !IsSyrabaneSignalEligible()
        return
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.SyrabaneCureWard")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_CURSE_DISEASE_WARDING, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "The sickness lifts", "marks a curse turned aside before it took root.")
EndFunction

Function HandleAltmerSyrabaneProtectiveWard(String reason)
    if !IsSyrabaneSignalEligible()
        return
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.SyrabaneProtectiveWarding")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_PROTECTIVE_WARDING, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "The ward holds", "marks hostile magic stopped before it reached you.")
EndFunction

Function HandleAltmerSyrabaneAntiMageSurvival(String reason)
    if !IsSyrabaneSignalEligible()
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_ANTI_MAGE_SURVIVAL, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "Arcane duel survived", "marks a hostile mage outlasted and put down.")
EndFunction

Function HandleAltmerSyrabaneContainment(String reason)
    if !IsSyrabaneSignalEligible()
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.SyrabaneMagicalContainment")
    if multiplier > 0.0
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_MAGICAL_CONTAINMENT, None, multiplier)
    endIf
    Manager.SurfaceP2BookReadNotice(reason, "The first warding", "Syrabane opens the apprentice's art to you.")
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
    if !Manager.PDV_AltmerAncestorSubstrate
        return
    endIf

    Bool curseActive = IsAltmerFavorSuppressedByCurse()
    Manager.PDV_AltmerAncestorSubstrate.ProcessHeritageDawn(curseActive, "dawn")
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
    return familyValue == Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_DAWN_STEADINESS || familyValue == Manager.FavorRuntime.FAVOR_FAMILY_ALTMER_ORTHODOX_COST
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
    return sourceId == "ordinary_travel" || sourceId == "ordinary_friendship" || sourceId == "generic_spellcasting" || sourceId == "generic_helping" || sourceId == "generic_combat" || sourceId == "generic_college_membership" || sourceId == "generic_anti_thalmor_violence" || sourceId == "dragonborn_repeat" || sourceId == "vampire_power_route"
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
    return GetAltmerCrisisStateLabelForValue(GetAltmerCrisisState())
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

Function SyncAltmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isAltmer = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER
    SyncAltmerAncestorSubstrate(playerRef, isAltmer)
    Bool broadOrthodoxFaithful = isAltmer && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.DawnSteadiness.Count") + StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.OrthodoxCost.Count") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Altmer_Orthodox_T2, broadOrthodoxFaithful, "Altmer Orthodox T2")

    SyncAltmerRewardFamily(playerRef, Manager.PDV_AuriEl, Manager.PDV_Bless_Altmer_AuriEl_T1, Manager.PDV_Bless_Altmer_AuriEl_T2, Manager.PDV_Bless_Altmer_AuriEl_T3, "Auri-El")
    SyncAltmerRewardFamily(playerRef, Manager.PDV_Magnus, Manager.PDV_Bless_Altmer_Magnus_T1, Manager.PDV_Bless_Altmer_Magnus_T2, Manager.PDV_Bless_Altmer_Magnus_T3, "Magnus")
    SyncAltmerRewardFamily(playerRef, Manager.PDV_Trinimac, Manager.PDV_Bless_Altmer_Trinimac_T1, Manager.PDV_Bless_Altmer_Trinimac_T2, Manager.PDV_Bless_Altmer_Trinimac_T3, "Trinimac")
    SyncAltmerRewardFamily(playerRef, Manager.PDV_Xarxes, Manager.PDV_Bless_Altmer_Xarxes_T1, Manager.PDV_Bless_Altmer_Xarxes_T2, Manager.PDV_Bless_Altmer_Xarxes_T3, "Xarxes")
    SyncAltmerRewardFamily(playerRef, Manager.PDV_Syrabane, Manager.PDV_Bless_Altmer_Syrabane_T1, Manager.PDV_Bless_Altmer_Syrabane_T2, Manager.PDV_Bless_Altmer_Syrabane_T3, "Syrabane")
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

Bool Function IsAltmerCoherenceNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    if IsAltmerFavorSuppressedByCurse()
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Altmer.Favor.LastGameTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 3.0
EndFunction

Function SyncAltmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Altmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Altmer)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Altmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Altmer)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Altmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.AltmerSpellActive", 0)
    endIf
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

Message Function GetAltmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_AuriEl
        return Manager.PDV_Msg_Altmer_AuriEl_Offer
    elseIf deity == Manager.PDV_Magnus
        return Manager.PDV_Msg_Altmer_Magnus_Offer
    elseIf deity == Manager.PDV_Xarxes
        return Manager.PDV_Msg_Altmer_Xarxes_Offer
    elseIf deity == Manager.PDV_Trinimac
        return Manager.PDV_Msg_Altmer_Trinimac_Offer
    elseIf deity == Manager.PDV_Syrabane
        return Manager.PDV_Msg_Altmer_Syrabane_Offer
    endIf

    return None
EndFunction

Bool Function IsAltmerOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    return deity == Manager.PDV_AuriEl || deity == Manager.PDV_Magnus || deity == Manager.PDV_Xarxes || deity == Manager.PDV_Trinimac || deity == Manager.PDV_Syrabane
EndFunction

Function ApplyAltmerCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressAltmerCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 0)
        Manager.FavorRuntime.ClearActiveFavor("altmer_vampire")
        Manager.LedgerRuntime.ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown") != 1
            ShowAltmerMessage(Manager.PDV_Msg_Altmer_VampireExiledPath_Entry, "Auri-El is closed while you flee the sun. What remains is exile: a narrow discipline, never a full return.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 1)
        Manager.FavorRuntime.ClearActiveFavor("altmer_werewolf")
        Manager.LedgerRuntime.ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown") != 1
            ShowAltmerMessage(Manager.PDV_Msg_Altmer_CurseState_WerewolfHardHalt, "The whole of Altmer faith is to become spirit again. You have become a beast. Devotion stops here.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHalt", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.VampireExileFeedbackShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Altmer.WerewolfHaltFeedbackShown", 0)
        if oldState == 2 && StorageUtil.GetIntValue(None, "PDV.Altmer.VampireRecognitionShown") != 1
            ShowAltmerMessage(Manager.PDV_Msg_Altmer_VampireExiledPath_Recognition, "You are exiled from the dawn, not restored to it. A thin discipline remains, capped low.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Altmer.VampireRecognitionShown", 1)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Altmer.ExilePressure", PDV_DevotionRules.BoolToInt(newState != 0))
    endIf
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
    Int stateValue = GetAltmerCrisisState()
    if stateValue == Manager.ALTMER_CRISIS_DISSONANT
        return "Dissonant"
    elseIf stateValue == Manager.ALTMER_CRISIS_QUESTIONING
        return "Questioning"
    elseIf stateValue == Manager.ALTMER_CRISIS_REASSERTING
        return "Reasserting"
    elseIf stateValue == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        return "Scarred Resolved"
    endIf

    return "None"
EndFunction

String Function GetAltmerMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("magnus", "Magnus", "god", "magnus", Manager.PDV_Magnus, "Light, magic, and origin memory.")
    entries = entries + "," + Manager.PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Endurance, pilgrimage, and old discipline.")
    entries = entries + "," + Manager.RosterMedallionEntry("auri-el", "Auri-El", "god", "auri-el", Manager.PDV_AuriEl, "The founding light and ancestral ascent.")
    entries = entries + "," + Manager.RosterMedallionEntry("syrabane", "Syrabane", "god", "syrabane", Manager.PDV_Syrabane, "Protection, apprentices, and survival through wisdom.")
    entries = entries + "," + Manager.RosterMedallionEntry("xarxes", "Xarxes", "god", "xarxes", Manager.PDV_Xarxes, "Lineage, record, and ordered memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("trinimac", "Trinimac", "god", "trinimac", Manager.PDV_Trinimac, "Warrior order and unbroken nobility.")
    return entries
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

String Function GetAltmerCursePublicLabel()
    if IsAltmerWerewolfHalted()
        return "Werewolf halt"
    endIf

    if IsAltmerVampireExiled()
        return "Exiled from dawn"
    endIf

    if HasAltmerVampireExileScar()
        return "Dawn-exile scar"
    endIf

    return ""
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
    String text = GetAltmerAlignmentSurveyBaseText()
    Int crisisState = GetAltmerCrisisState()
    if crisisState == Manager.ALTMER_CRISIS_DISSONANT
        text = text + " The crisis has not settled; each mortal exception still tests the doctrine."
    elseIf crisisState == Manager.ALTMER_CRISIS_SCARRED_RESOLVED
        text = text + " The crisis is resolved, but its scar still teaches caution."
    endIf

    if IsAltmerVampireExiled()
        text = text + " The thirst has exiled you from the dawn."
    elseIf HasAltmerVampireExileScar()
        text = text + " The vampire scar remains in the record, but the dawn can reach you again."
    endIf

    if IsAltmerWerewolfHalted()
        text = text + " The beast has stopped your devotion."
    endIf

    String favor = Manager.FavorRuntime.GetFavorSurfacingLabel(Manager.FavorRuntime.FAVOR_LANE_ALTMER, StorageUtil.GetIntValue(None, "PDV.Altmer.Favor.LastFamily"))
    if favor != ""
        text = text + " Last favor: " + favor + "."
    endIf

    if Manager.PDV_AltmerAncestorSubstrate
        text = text + " Your heritage practice is " + GetAltmerHeritageTierName() + "."
    endIf

    return text
EndFunction

String Function GetAltmerHeritageLayerLabel()
    if !Manager.PDV_AltmerAncestorSubstrate
        return "quiet"
    endIf

    return Manager.PDV_AltmerAncestorSubstrate.GetHeritagePostureLabel()
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
    Int focusValue = GetKhajiitFocusForDeityName(deityName)
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        return
    endIf

    Float base = Manager.KHAJIIT_FOCUS_MATRIX_DELTA
    if magnitude == "milestone"
        base = Manager.KHAJIIT_FOCUS_MATRIX_DELTA * 2.0
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitMatrixFocus." + deityName)
    if multiplier <= 0.0
        return
    endIf

    AdjustKhajiitFocusedEmphasis(focusValue, base * multiplier, "matrix_focus_" + deityName)
    Manager.Trace(2, "Khajiit matrix focus bridge: " + deityName + " focus +" + (base * multiplier))
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
    if !deity
        return Manager.KHAJIIT_FOCUS_NONE
    elseIf deity == Manager.PDV_Khenarthi
        return Manager.KHAJIIT_FOCUS_KHENARTHI
    elseIf deity == Manager.PDV_Azura
        return Manager.KHAJIIT_FOCUS_AZURAH
    elseIf deity == Manager.PDV_BaanDar
        return Manager.KHAJIIT_FOCUS_BAANDAR
    elseIf deity == Manager.PDV_Rajhin
        return Manager.KHAJIIT_FOCUS_RAJHIN
    elseIf deity == Manager.PDV_Alkosh
        return Manager.KHAJIIT_FOCUS_ALKOSH
    endIf

    return Manager.KHAJIIT_FOCUS_NONE
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return False
    endIf
    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue == Manager.KHAJIIT_FOCUS_NONE || focusValue != GetCurrentLunarPresidingFocus()
        return False
    endIf
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    return deity && Manager.LedgerRuntime.GetPiety(deity) >= 25.0
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
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || GetKhajiitFocusedEmphasis() != Manager.KHAJIIT_FOCUS_BAANDAR
        return False
    endIf
    if !Manager.PDV_BaanDar || Manager.LedgerRuntime.GetTier(Manager.PDV_BaanDar) < Manager.LedgerRuntime.TIER_CHAMPION || !Manager.PDV_Bless_Khajiit_BaanDar_T3
        return False
    endIf
    return playerRef.HasSpell(Manager.PDV_Bless_Khajiit_BaanDar_T3)
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

Float Function GetKhajiitLunarAlignmentMultiplier(PDV_DeityBase deity)
    return 1.0
EndFunction

String Function GetArgonianCulturalNextThresholdText(Float metric)
    if metric < 1.0
        return "Root Memory at 1"
    elseIf metric < 25.0
        return "River-Kept Practice at 25"
    elseIf metric < 75.0
        return "Rooted Adaptation at 75"
    endIf
    return "Rooted Adaptation"
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

Function HandleArgonianSleepEvents(Actor playerRef, String reason)
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    ; Identity = the CELL you sleep in (reliable at sleep-stop), not the bed
    ; furniture ref (GetFurnitureReference is None at OnSleepStart). Your home
    ; room becomes your place of rest.
    Int sleepCellId = 0
    Cell sleepCell = playerRef.GetParentCell()
    if sleepCell
        sleepCellId = sleepCell.GetFormID()
    endIf

    Bool menuShown = TryArgonianBedOfChoiceSleep(playerRef, sleepCellId, reason)
    if !menuShown
        menuShown = TryArgonianAdaptationRite(playerRef, sleepCellId, reason)
    endIf
    if !menuShown
        TryArgonianPostureDream(reason)
    endIf
EndFunction

Bool Function TryArgonianBedOfChoiceSleep(Actor playerRef, Int sleepCellId, String reason)
    if sleepCellId == 0 || !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return false
    endIf

    ; Every bed cadence uses the shared 06:00 devotional day, encoded with
    ; +2 so day zero cannot be mistaken for an unset legacy value.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if declaredId != 0 && sleepCellId == declaredId
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
        HandleArgonianBedOfChoiceReturn("declared_" + reason)
        if Manager.PDV_SPEL_ArgonianRootedRest && StorageUtil.GetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount") >= 12
            Int rootedRestStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
            if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.RootedRestDay") != rootedRestStamp
                Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.RootedRestDay")
                Manager.PDV_SPEL_ArgonianRootedRest.Cast(playerRef, playerRef)
                Manager.SendPrismaToast("hist", "good", "Rooted rest", "You wake feeling rooted.")
                Manager.Trace(1, "[PDV][ARGONIAN_ROOTED_REST] granted day=" + Manager.LedgerRuntime.GetDevotionalDay())
            else
                Manager.Trace(2, "Argonian Rooted Rest suppressed: already granted this devotional day")
            endIf
        endIf
        return false
    endIf

    if !Manager.PDV_MESG_ArgonianMarkBed
        return false
    endIf

    Int declinedDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclineDay")
    if declinedDay > 0 && (todayStamp - declinedDay) < 3
        return false
    endIf

    Int candidateId = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateFormID")
    Int candidateDay = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateDay")
    Int candidateCount = StorageUtil.GetIntValue(None, "PDV.ArgBed.CandidateCount")
    if candidateId != sleepCellId
        candidateCount = 1
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", sleepCellId)
    elseIf candidateDay != todayStamp
        candidateCount += 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", candidateCount)
    StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", todayStamp)

    if candidateCount < 3
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_ArgonianMarkBed.Show()
    ; B4 / fix-plan 3. -1 is "another menu was already up", not a decline. Stamping the
    ; 3-day suppression AND wiping the 3-sleep candidacy counters on a menu the player
    ; never saw threw away three nights of progress silently.
    if pressed < 0
        Manager.Trace(2, "Argonian bed-of-choice menu not shown (menu busy); candidacy kept.")
        return false
    endIf
    if pressed == 0
        SetArgonianHome(playerRef, sleepCellId, todayStamp, reason)
        Manager.SendPrismaToast("hist", "good", "Place of rest", "The Hist remembers it now.")
    else
        StorageUtil.SetIntValue(None, "PDV.ArgBed.DeclineDay", todayStamp)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.ArgBed.CandidateDay", 0)
    endIf
    return true
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

Function ClearArgonianAdaptation(Actor playerRef)
    if playerRef
        RemoveArgonianAdaptationSpells(playerRef)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", 0)
    StorageUtil.SetIntValue(None, "PDV.Adapt.DueDay", 0)
EndFunction

Bool Function TryArgonianAdaptationRite(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MESG_ArgonianAdaptRite || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN
        return false
    endIf

    if Manager.PDV_ArgonianHistSubstrate.GetMetric() < Manager.ARGONIAN_REWARD_SIGNATURE_THRESHOLD
        return false
    endIf

    Bool rooted = false
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.ArgBed.DeclaredFormID")
    if sleepCellId != 0 && declaredId != 0 && sleepCellId == declaredId
        rooted = true
    elseIf Manager.PDV_FLST_ArgonianSacredWaters && playerRef.GetCurrentLocation() && Manager.PDV_FLST_ArgonianSacredWaters.HasForm(playerRef.GetCurrentLocation())
        rooted = true
    endIf
    if !rooted
        return false
    endIf

    ; One-time, permanent choice: the rite is only offered while no adaptation is
    ; active. Once taken it is kept for good -- no swap, no re-rite.
    if StorageUtil.GetIntValue(None, "PDV.Adapt.Active") != 0
        return false
    endIf

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

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_ArgonianAdaptRite.Show()
    if pressed < 0 || pressed > 3
        return true
    endIf

    ApplyArgonianAdaptation(playerRef, pressed)
    return true
EndFunction

Function ApplyArgonianAdaptation(Actor playerRef, Int adaptationIndex)
    RemoveArgonianAdaptationSpells(playerRef)
    Spell chosenAdaptation = GetArgonianAdaptationSpell(adaptationIndex)
    if !chosenAdaptation
        return
    endIf

    playerRef.AddSpell(chosenAdaptation, False)
    StorageUtil.SetIntValue(None, "PDV.Adapt.Active", adaptationIndex + 1)
    Manager.SendPrismaShiftToast("The Hist has reshaped you.", "", "hist")
    Manager.AppendBookOfDaysEntry("You took the Hist's adaptation into your body. The change is permanent -- the root has answered, and you are remade in its image.", Utility.GetCurrentGameTime() as Int, "reorientation", "hist", True, 3)
    Manager.Trace(2, "Argonian adaptation applied: " + adaptationIndex)
EndFunction

Function RemoveArgonianAdaptationSpells(Actor playerRef)
    Int adaptationIndex = 0
    while adaptationIndex < 4
        Spell adaptationSpell = GetArgonianAdaptationSpell(adaptationIndex)
        if adaptationSpell && playerRef.HasSpell(adaptationSpell)
            playerRef.RemoveSpell(adaptationSpell)
        endIf
        adaptationIndex += 1
    endWhile
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.ArgWaters.SapVision") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.ArgWaters.SapVision", 1)
    Manager.PDV_ArgonianHistSubstrate.SetHistRelation(Manager.PDV_ArgonianHistSubstrate.GetHistRelation() + 1.0, "sleeping_tree_sap")
    Manager.PDV_ArgonianHistSubstrate.StampHistMaintenance("sleeping_tree_sap")
    Manager.PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_hist", "sleeping_tree_sap")
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, 1.0)
    endIf
    Debug.MessageBox("The sap is strange and far from home, but it resonates, and the Hist stirs within.")
    Manager.Trace(2, "Sleeping Tree Sap vision fired.")
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

Function TryArgonianPostureDream(String reason)
    ; fix-plan 4.2: the dream cadence is sleep-triggered, so a raw-midnight day boundary
    ; crossed mid-sleep was exactly the case that let it fire two nights running.
    Int today = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int lastDreamDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.ArgDream.LastDay")
    if lastDreamDay > 0 && (today - lastDreamDay) < 2
        return
    endIf

    Int posture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
    Int dreamChance = 8
    if StorageUtil.GetIntValue(None, "PDV.ArgDream.Armed") == 1
        dreamChance = 60
    elseIf posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_NORMAL
        dreamChance = 12
    endIf

    if Utility.RandomInt(1, 100) > dreamChance
        return
    endIf

    String dreamText = Manager.PDV_ArgonianHistSubstrate.GetDreamTextForPosture(posture)
    SendPrismaSubstrateToast("ArgonianHist", "dream", dreamText, "hist", Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel())
    StorageUtil.SetIntValue(None, "PDV.ArgDream.Armed", 0)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.ArgDream.LastDay")
    Manager.Trace(2, "Argonian posture dream fired (" + Manager.PDV_ArgonianHistSubstrate.GetHistPostureLabel() + ", " + reason + ")")
EndFunction

Function TryArgonianSithisNearDeathBurst(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_SPEL_ArgonianSithisNearDeathBurst
        return
    endIf
    if !playerRef.IsInCombat() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf
    if !Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return
    endIf

    Float voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
    Float peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if GetArgonianActiveFocus(peopleRelation, voidRelation, True) != Manager.ARGONIAN_FOCUS_VOID || voidRelation < Manager.ARGONIAN_REWARD_T3_THRESHOLD
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Argonian.SithisNearDeathLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf

    Manager.PDV_SPEL_ArgonianSithisNearDeathBurst.Cast(playerRef, playerRef)
    ; Requiem parity (2026-07-13): the cast StaminaRateMult burst is muted under
    ; Requiem, so pair it with a felt flat stamina restore (TryOrcCodeHolds
    ; pattern) - the Void lends an instant surge you can actually spend.
    playerRef.RestoreActorValue("Stamina", 100.0)
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Argonian.SithisNearDeathLastDay")
    HandleArgonianVoidSignal("near_death_burst")
    Manager.Trace(2, "Argonian Sithis near-death burst fired.")
EndFunction

Function HandleKhajiitMoonObservance(Int phaseIndex, String reason)
    ; Compatibility ingress is intentionally inert. Only the validated
    ; two-second Observe the Moons power may award observance credit.
    Manager.Trace(2, "Legacy moon observance ignored: " + reason)
EndFunction

Function HandleKhajiitLunarSubstrate(String sourceId)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT || !Manager.PDV_KhajiitLunarSubstrate
        return
    endIf

    ; Curated books and exact quest milestones are cultural substitutes. They
    ; claim the shared substrate day only; deity piety/focus remains on its own
    ; specifically authored receiver route.
    Manager.PDV_KhajiitLunarSubstrate.RecordCulturalSubstitute("khajiit_lunar_source", "p2_khajiit_lunar_" + sourceId)
    Manager.RequestPanelRefresh()
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
    if !IsKhajiitOrigin() || !Manager.PDV_KhajiitLunarSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitRoadHome")
    Float metricBefore = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    Manager.PDV_KhajiitLunarSubstrate.RecordRoadHomeCadence(reason)
    Int tierAfter = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
    Float grantedMetric = Manager.PDV_KhajiitLunarSubstrate.GetMetric() - metricBefore
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_KHENARTHI, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * multiplier, reason)
    if Manager.PDV_Khenarthi
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_ROAD_HOME, None, multiplier)
    endIf
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())

    ; Road-home recognition owns one presentation per 06:00 devotional cycle,
    ; independently of the shared lunar +4 budget. If another authentic lunar
    ; practice already spent that budget, the rest is still acknowledged without
    ; implying that it granted more substrate progress.
    String presentationDayKey = "PDV.Khajiit.RoadHome.PresentationDay"
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp(presentationDayKey) != todayStamp
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(presentationDayKey)
        if grantedMetric > 0.0
            Manager.SendPrismaSubstrateProgress("lunar", tierBefore, tierAfter, grantedMetric, "The road home was remembered.", "lunar", GetKhajiitLunarTierLabel(tierAfter))
        else
            String cappedContext = "The road home was remembered. Today's lunar practice was already marked."
            SendPrismaSubstrateToast("lunar", "act", cappedContext, "lunar", GetKhajiitLunarTierLabel(tierAfter))
            Manager.AppendBookOfDaysEntry(cappedContext, Utility.GetCurrentGameTime() as Int, "substrate.act", "lunar", False)
        endIf
    endIf
    Manager.NotifyDiegeticRoutineFavor("khajiit_road_home")
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Khajiit road-home cadence routed with multiplier " + multiplier)
EndFunction

Function HandleKhajiitRoadHomeAnchor(Int anchorId, String reason)
    ; Retired anchor/circuit ingress must never award metric or piety.
    Manager.Trace(2, "Retired Khajiit road anchor ignored: " + anchorId + " (" + reason + ")")
EndFunction

Float Function ConsumeKhajiitLunarMetricBudget(Float requestedMetric)
    ; Compatibility-only. PDV_SubstrateBase owns the one daily +4 budget.
    return 0.0
EndFunction

Function HandleKhajiitBaanDarRoadTrick(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_BAANDAR, "PDV.Signal.KhajiitBaanDarRoadTrick", "Baan Dar road trick", reason)
EndFunction

Function HandleKhajiitRajhinElegantTheft(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", "Rajhin elegant theft", reason)
    ; Night theft is shadow-coded behavior; it accrues toward the ShadowDrift boundary.
    RecordKhajiitShadowEvidence("rajhin_night_theft_" + reason)
    Manager.SendPrismaShiftToast("Elegant theft", "Rajhin purrs.", GetKhajiitFocusSymbol(Manager.KHAJIIT_FOCUS_RAJHIN))
    Manager.LedgerRuntime.RecordRecentDevotionEvent("Rajhin: theft with style")
EndFunction

Function HandleKhajiitAlkoshDragonOrder(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh dragon order", reason)
EndFunction

Function HandleKhajiitFocusedSource(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        focusValue = GetActiveLunarFavoredFocus()
    endIf
    if focusValue == Manager.KHAJIIT_FOCUS_NONE
        focusValue = Manager.KHAJIIT_FOCUS_AZURAH
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

Function HandleKhajiitFocusedSourceForFocus(Int focusValue, String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    if focusValue < Manager.KHAJIIT_FOCUS_KHENARTHI || focusValue > Manager.KHAJIIT_FOCUS_ALKOSH
        HandleKhajiitFocusedSource(reason)
        return
    endIf

    RecordKhajiitFocusSignal(focusValue, "PDV.Signal.KhajiitFocusedSource", "Khajiit focused source", reason)
EndFunction

Function HandleKhajiitAlkoshNamedDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = RecordKhajiitFocusSignal(Manager.KHAJIIT_FOCUS_ALKOSH, "PDV.Signal.KhajiitAlkoshDragonOrder", "Alkosh named dragon", reason)
    if Manager.PDV_Alkosh
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_NAMED_DRAGON, None, multiplier)
    endIf
    AwardKhajiitSubstrateSubstitute("khajiit_alkosh_milestone", reason)
    Manager.Trace(1, "Khajiit Alkosh named-dragon beat routed (" + reason + ")")
EndFunction

Function HandleKhajiitAlkoshGenericDragon(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Int weekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
    if StorageUtil.GetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week") == weekStamp
        Manager.Trace(2, "Khajiit Alkosh generic-dragon nudge suppressed by weekly cap (" + reason + ")")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Signal.KhajiitAlkoshGenericDragon.Week", weekStamp)
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_ALKOSH, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * 0.25, reason)
    Manager.Trace(2, "Khajiit Alkosh generic-dragon emphasis nudge routed (" + reason + ")")
EndFunction

Function HandleKhajiitBaanDarReversal(String reason)
    if !IsKhajiitOrigin()
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhajiitBaanDarReversal")
    StorageUtil.AdjustIntValue(None, "PDV.Signal.KhajiitBaanDarReversal.CountAll", 1)
    StorageUtil.SetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Khajiit.LastLunarSourceReason", reason)
    AdjustKhajiitFocusedEmphasis(Manager.KHAJIIT_FOCUS_BAANDAR, Manager.KHAJIIT_FOCUS_SIGNAL_DELTA * 2.0 * multiplier, reason)
    if Manager.PDV_BaanDar
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_BANDIT_ROAD, None, multiplier)
    endIf
    AwardKhajiitSubstrateSubstitute("khajiit_baandar_reversal", reason)
    Manager.Trace(1, "Khajiit Baan Dar near-fatal reversal routed (" + reason + ")")
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
    if !IsKhajiitOrigin() || !Manager.PDV_Azura
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Azura, Manager.PDV_Azura.SIGNAL_DESECRATION, None)
    Manager.Trace(2, "Khajiit Azurah desecration routed (" + reason + ")")
EndFunction

Function HandleKhajiitKhenarthiCaravanHarm(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Khenarthi
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_CARAVAN_HARM, None)
    Manager.Trace(2, "Khajiit Khenarthi caravan-harm routed (" + reason + ")")
EndFunction

Function HandleKhajiitKhenarthiCaravanAid(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Khenarthi
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.KhenarthiCaravanAid")
    if multiplier <= 0.0
        Manager.Trace(2, "Khajiit Khenarthi caravan-aid blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Khenarthi, Manager.PDV_Khenarthi.SIGNAL_CARAVAN_AID, None, multiplier)
    AwardKhajiitSubstrateSubstitute("khajiit_caravan_defense", reason)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Khenarthi, "Caravan defended", "marks the caravan road kept safe.")
    Manager.Trace(2, "Khajiit Khenarthi caravan-aid routed (" + reason + ")")
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
    if !IsKhajiitOrigin() || !Manager.PDV_Rajhin
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Rajhin, Manager.PDV_Rajhin.SIGNAL_BOTCHED_THEFT, None)
    Manager.Trace(2, "Khajiit Rajhin botched-theft routed (" + reason + ")")
EndFunction

Function HandleKhajiitAlkoshChaosAid(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_Alkosh
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_Alkosh, Manager.PDV_Alkosh.SIGNAL_CHAOS_AID, None)
    Manager.Trace(2, "Khajiit Alkosh chaos-aid routed (" + reason + ")")
EndFunction

Function HandleKhajiitBaanDarBetrayal(String reason)
    if !IsKhajiitOrigin() || !Manager.PDV_BaanDar
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignal(Manager.PDV_BaanDar, Manager.PDV_BaanDar.SIGNAL_BETRAYAL, None)
    Manager.Trace(2, "Khajiit Baan Dar betrayal routed (" + reason + ")")
EndFunction

Bool Function IsKhajiitOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
EndFunction

Int Function GetKhajiitLunarPosture()
    if Manager.PDV_KhajiitLunarPostureTrack
        Int value = Manager.PDV_KhajiitLunarPostureTrack.GetCurrentState()
        if value < 0
            return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
        endIf
        return value
    endIf

    return Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
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
    if !Manager.PDV_KhajiitLunarPostureTrack || !IsKhajiitOrigin()
        return
    endIf

    Int oldPosture = GetKhajiitLunarPosture()
    Int newPosture = DeriveKhajiitLunarPosture()
    if newPosture == oldPosture
        return
    endIf

    Manager.PDV_KhajiitLunarPostureTrack.SetState(newPosture, reason)
    Manager.Trace(1, "Khajiit lunar posture " + oldPosture + " -> " + newPosture + " (" + reason + ")")

    if newPosture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_ShadowDriftEntry, "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars.", False)
    endIf

    if newPosture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        Manager.AppendBookOfDaysEntry("The moonlight scatters from your path. Corruption is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
    elseIf newPosture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        Manager.AppendBookOfDaysEntry("You slipped into the moons' shadow. Darkness is upon you.", Utility.GetCurrentGameTime() as Int, "curse.onset", "lunar", False, 3)
    endIf

    Manager.SendPrismaShiftToast(GetKhajiitLunarPostureDisplayLabelAt(newPosture), GetKhajiitLunarPostureReadout(newPosture), "lunar")
    Manager.RequestPanelRefresh()
EndFunction

String Function GetKhajiitLunarPostureLabel()
    return GetKhajiitLunarPostureLabelAt(GetKhajiitLunarPosture())
EndFunction

String Function GetKhajiitLunarPostureLabelAt(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Strained"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Corrupted"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "ShadowDrift"
    endIf

    return "Normal"
EndFunction

String Function GetKhajiitLunarPostureDisplayLabelAt(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "Lattice strained"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "Lattice thinned"
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "Drifting to shadow"
    endIf

    return "Lattice clear"
EndFunction

String Function GetKhajiitLunarPostureReadout(Int posture)
    if posture == Manager.KHAJIIT_LUNAR_POSTURE_STRAINED
        return "The Lattice holds you, but strained. The beast-shape is a competing form, and the caravans keep their distance."
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_CORRUPTED
        return "The Lattice still holds you, corrupted and thinned. The moons do not disown the undead, but the community does."
    elseIf posture == Manager.KHAJIIT_LUNAR_POSTURE_SHADOWDRIFT
        return "You have drifted into shadow. The moons grow distant; the Lattice loosens toward the dark between the stars."
    endIf

    return "The Lunar Lattice holds you cleanly. The moons know your form, and the road knows your step."
EndFunction

Function ShowKhajiitMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("lunar", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyKhajiitCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.VampireOnsetShown") != 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_VampireOnset, "The thirst has taken you, little moon. The Lattice does not cast you out, but the caravans will fear you.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 1)
        endIf
    elseIf newState == 1
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown") != 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_WerewolfOnset, "Hircine has given you another shape. You are still Khajiit -- strained, watched, but not erased.", False)
            StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 1)
        endIf
    elseIf newState == 0
        if oldState == 2
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_VampireCured, "The thirst is gone. The corruption lifts from the Lattice; walk back into the moonlight.", False)
        elseIf oldState == 1
            ShowKhajiitMessage(Manager.PDV_Msg_Khajiit_CurseState_WerewolfCured, "The wolf is set down, little moon. The Lattice holds a single shape once more.", False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Khajiit.VampireOnsetShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Khajiit.WerewolfOnsetShown", 0)
    endIf

    RefreshKhajiitLunarPosture("curse_" + reason)
EndFunction

Function HandleArgonianHistMaintenance(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianHistMaintenance")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordHistMaintenanceScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Double-route: the substrate carries the reward gating; a small honest +1 Hist pulse keeps
    ; the universal piety layer (decay/neglect/creed-loss) honest.
    if Manager.PDV_Hist
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Hist, Manager.PDV_Hist.SIGNAL_HIST_PULSE, None, multiplier)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Argonian.HistSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Argonian.LastHistSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Argonian.LastHistSourceTime", Utility.GetCurrentGameTime())
    Manager.SurfaceP2BookReadNotice(reason, "The Hist remembers", "The reading carries the smell of home.")
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The Hist memory stirred.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian Hist maintenance routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianPeopleSupport(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianPeopleSupport")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordPeopleSupportScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "Your people were supported.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian People support routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianBedOfChoiceReturn(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianBedOfChoice")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordBedOfChoiceReturnScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The chosen rest took root.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian bed-of-choice return routed with multiplier " + multiplier)
EndFunction

Function HandleArgonianVoidSignal(String reason)
    if !IsArgonianOrigin() || !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ArgonianVoidSignal")
    Float metricBefore = Manager.PDV_ArgonianHistSubstrate.GetMetric()
    Int tierBefore = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    Manager.PDV_ArgonianHistSubstrate.RecordVoidSignalScaled(multiplier, reason)
    RefreshArgonianHistPosture(reason)
    Int tierAfter = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
    ; Void piety belongs to Sithis only after the relation is explicitly active.
    if Manager.PDV_Sithis && Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Sithis, Manager.PDV_Sithis.SIGNAL_VOID_THRESHOLD, None, multiplier)
    endIf
    ; Void overreach: leaning deep into the Void (fully active) while Hist maintenance has
    ; lapsed below its non-curse floor is the curated major loss for the Hist.
    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive() && Manager.PDV_ArgonianHistSubstrate.GetHistRelation() <= Manager.PDV_ArgonianHistSubstrate.HistNonCurseFloor
        EmitHistVoidOverreachMinus(reason)
    endIf
    Manager.SendPrismaSubstrateProgress("argonian-practice", tierBefore, tierAfter, Manager.PDV_ArgonianHistSubstrate.GetMetric() - metricBefore, "The Void was noticed.", "journal", GetArgonianCulturalPracticeLabel())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Argonian Void signal routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshArgonianHist()
    if !Manager.PDV_ArgonianHistSubstrate
        return
    endIf

    Bool curseActive = False
    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() != 0
        curseActive = True
    endIf

    Manager.PDV_ArgonianHistSubstrate.ProcessHistDistanceDawn(curseActive, "dawn")
    Manager.PDV_ArgonianHistSubstrate.ProcessCulturalPracticeDawn(curseActive, "dawn")
    RefreshArgonianHistPosture("dawn")
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

    PDV_DeityBase deity = Manager.GetQuestReactionDeity("Molag Bal")
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
    return StorageUtil.GetIntValue(None, "PDV.Khajiit.FocusedEmphasis")
EndFunction

PDV_DeityBase Function GetKhajiitFocusDeity(Int focusValue)
    return GetKhajiitEmphasisDeity(focusValue)
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

Bool Function IsKhajiitLunarNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_KHAJIIT
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Khajiit.LastLunarSourceTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > Manager.KHAJIIT_LUNAR_NEGLECT_GRACE_DAYS
EndFunction

Function SyncKhajiitNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_KhajiitLunar
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_KhajiitLunar)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KhajiitLunarSpellActive", 0)
    endIf
EndFunction

Function SyncArgonianRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isArgonian = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
    Float histRelation = 0.0
    Float peopleRelation = 0.0
    Float voidRelation = 0.0
    Bool voidActive = False
    Int activeFocus = Manager.ARGONIAN_FOCUS_NONE
    if isArgonian && Manager.PDV_ArgonianHistSubstrate
        histRelation = Manager.PDV_ArgonianHistSubstrate.GetHistRelation()
        peopleRelation = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
        voidRelation = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
        voidActive = Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        activeFocus = GetArgonianActiveFocus(peopleRelation, voidRelation, voidActive)
    endIf

    ; Hist broad set, HIGHEST TIER ONLY (each tier spell carries the cumulative
    ; magnitude, so total power is unchanged but only one tier shows at a time).
    ; Retired Hist Communion boon family: the cultural-practice substrate now
    ; owns the universal identity boon, while Hist remains a relation ledger.
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_T1, False, "Argonian Hist T1 retired")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_T2, False, "Argonian Hist T2 retired")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Hist_Signature, False, "Argonian Hist Signature retired")

    ; People focused set, highest tier only (active only when People is the focus).
    Bool peopleActive = isArgonian && activeFocus == Manager.ARGONIAN_FOCUS_PEOPLE
    Bool wantPeopleT3 = peopleActive && peopleRelation >= Manager.ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantPeopleT2 = peopleActive && !wantPeopleT3 && peopleRelation >= Manager.ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantPeopleT1 = peopleActive && !wantPeopleT3 && !wantPeopleT2 && peopleRelation >= Manager.ARGONIAN_REWARD_T1_THRESHOLD
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T1, wantPeopleT1, "Argonian People T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T2, wantPeopleT2, "Argonian People T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_People_T3, wantPeopleT3, "Argonian People T3")

    ; Sithis tertiary, highest tier only (only when Void is fully active + the focus).
    Bool sithisActive = isArgonian && voidActive && activeFocus == Manager.ARGONIAN_FOCUS_VOID
    Bool wantSithisT3 = sithisActive && voidRelation >= Manager.ARGONIAN_REWARD_T3_THRESHOLD
    Bool wantSithisT2 = sithisActive && !wantSithisT3 && voidRelation >= Manager.ARGONIAN_REWARD_T2_THRESHOLD
    Bool wantSithisT1 = sithisActive && !wantSithisT3 && !wantSithisT2 && voidRelation >= Manager.ARGONIAN_REWARD_T1_THRESHOLD
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T1, wantSithisT1, "Argonian Sithis T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T2, wantSithisT2, "Argonian Sithis T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Argonian_Sithis_T3, wantSithisT3, "Argonian Sithis T3")

    ; Hist Adaptation slot rides the same dawn sync (separate channel from the
    ; tier rewards above; never touched by SyncRaceRewardSpell).
    SyncArgonianAdaptation(playerRef, isArgonian)

    ; Existing-save fallback for Waters That Remember: discovery events never
    ; re-fire for already-known locations, so the dawn sync also offers the
    ; player's current location to the same one-shot gate.
    if isArgonian
        HandleArgonianSacredWaterDiscovery(playerRef.GetCurrentLocation())
    endIf
EndFunction

Int Function GetArgonianActiveFocus(Float peopleRelation, Float voidRelation, Bool voidActive)
    if voidActive && voidRelation > peopleRelation
        return Manager.ARGONIAN_FOCUS_VOID
    endIf

    return Manager.ARGONIAN_FOCUS_PEOPLE
EndFunction

Bool Function IsArgonianHistNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ARGONIAN || !Manager.PDV_ArgonianHistSubstrate
        return False
    endIf

    Int posture = Manager.PDV_ArgonianHistSubstrate.GetHistPosture()
    if posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_SILENCED && posture != Manager.PDV_ArgonianHistSubstrate.HIST_POSTURE_CORRUPTED
        return False
    endIf

    if !Manager.PDV_ArgonianHistSubstrate.HasHistMaintenance()
        return True
    endIf

    Int elapsedDays = Manager.LedgerRuntime.GetDevotionalDay() - Manager.PDV_ArgonianHistSubstrate.GetLastHistMaintenanceDevotionalDay()
    return elapsedDays > (Manager.ARGONIAN_HIST_NEGLECT_GRACE_DAYS as Int)
EndFunction

Function SyncArgonianNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_ArgonianHist
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_ArgonianHist, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_ArgonianHist)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ArgonianHistSpellActive", 0)
    endIf
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
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_SILENCED)
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.VampireScar", 1)
        if StorageUtil.GetIntValue(None, "PDV.Argonian.VampireFeedbackShown") != 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_VampireOnset, "You are undead now. The Hist falls silent.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_STRAINED)
        if StorageUtil.GetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown") != 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_WerewolfOnset, "The beast is in you. The Hist relation strains, but does not sever.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_DISTANT)
        if oldState == 2
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_VampireCured, "The undeath is lifted. The Hist reaches again slowly.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.VampireFeedbackShown", 0)
        elseIf oldState == 1
            ShowArgonianMessage(Manager.PDV_Msg_Argonian_CurseState_WerewolfCured, "The beast is set down. The shape settles.", False)
            StorageUtil.SetIntValue(None, "PDV.Argonian.WerewolfFeedbackShown", 0)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Argonian.HistPosture", Manager.ARGONIAN_HIST_POSTURE_NORMAL)
    endIf

    RefreshArgonianHistPosture(reason)
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

String Function GetKhajiitMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("azura", "Azurah", "prince", "azura", Manager.PDV_Azura, "Dusk, dawn, moon-shadow, and fate.")
    entries = entries + "," + Manager.RosterMedallionEntry("boethiah", "Boethra", "prince", "boethiah", Manager.PDV_Boethiah, "Trial, edge, and hard lessons.")
    entries = entries + "," + Manager.RosterMedallionEntry("mephala", "Mafala", "prince", "mephala", Manager.PDV_Mephala, "Hidden paths, webs, and clan memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("baan-dar", "Baan Dar", "god", "baan-dar", Manager.PDV_BaanDar, "The bandit god, wit, and road survival.")
    entries = entries + "," + Manager.RosterMedallionEntry("rajhin", "Rajhin", "god", "rajhin", Manager.PDV_Rajhin, "The clever thief and impossible escape.")
    entries = entries + "," + Manager.RosterMedallionEntry("alkosh", "Alkosh", "god", "alkosh", Manager.PDV_Alkosh, "Dragon order and time in Khajiit memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("khenarthi", "Khenarthi", "god", "khenarthi", Manager.PDV_Khenarthi, "Wind, sky-road, and breath.")
    entries = entries + "," + Manager.PendingMedallionEntry("riddle-thar", "Riddle'Thar", "god", "riddle-thar", "Balance, ja-Kha'jay, and right conduct.")
    entries = entries + "," + Manager.PendingMedallionEntry("jone-jode", "Jone and Jode", "god", "lunar", "The moons, the lattice, and the road home.")
    return entries
EndFunction

String Function GetArgonianMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("hist", "The Hist", "substrate", "hist", Manager.PDV_Hist, "Root, memory, people, and sap.")
    entries = entries + "," + Manager.RosterMedallionEntry("sithis", "Sithis", "god", "sithis", Manager.PDV_Sithis, "Void, change, and dangerous silence.")
    return entries
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
    String band = Manager.GetCurrentStandingBand()
    Int focusValue = GetKhajiitFocusedEmphasis()
    String text = ""
    if focusValue > Manager.KHAJIIT_FOCUS_NONE
        text = "You walk inside the Lunar Lattice, and " + GetKhajiitFocusLabel(focusValue) + " leads your devotion now. Standing: " + band + ". You did not choose it; you were walking it."
    else
        text = "You walk inside the Lunar Lattice, broad and unfocused, held by the moons and the road. Standing: " + band + ". No god leads yet, and that is whole."
    endIf

    if Manager.PDV_KhajiitLunarSubstrate
        text = text + " Your moon practice is " + GetKhajiitLunarTierLabel(Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()) + "."
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarSourceCount") > 0
            text = text + " A lunar source has been read and remembered."
        endIf
        if Manager.PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has begun to carry weight."
        endIf
    else
        text = text + " The moons have not yet taken the measure of your practice."
    endIf

    Int presiding = GetCurrentLunarPresidingFocus()
    if presiding > Manager.KHAJIIT_FOCUS_NONE
        if GetActiveLunarFavoredFocus() == presiding
            text = text + " " + GetKhajiitFocusLabel(presiding) + " is in strength, and your focused blessing resonates."
        else
            text = text + " " + GetKhajiitFocusLabel(presiding) + " is in strength."
        endIf
    endIf

    Int posture = GetKhajiitLunarPosture()
    if posture != Manager.KHAJIIT_LUNAR_POSTURE_NORMAL
        text = text + "\n\n" + GetKhajiitLunarPostureReadout(posture)
    endIf

    return text
EndFunction

String Function GetKhajiitFocusStandingLine(Int focusValue)
    PDV_DeityBase deity = GetKhajiitEmphasisDeity(focusValue)
    if !deity
        return "not yet wired"
    endIf

    String line = Manager.GetTierStandingLabel(Manager.LedgerRuntime.GetTier(deity)) + ", piety " + PDV_DevotionRules.FormatTwoDecimals(Manager.LedgerRuntime.GetPiety(deity))
    if GetKhajiitFocusedEmphasis() == focusValue
        line = line + " (leading)"
    endIf
    if GetCurrentLunarPresidingFocus() == focusValue
        if GetActiveLunarFavoredFocus() == focusValue
            line = line + " (in strength, resonating)"
        else
            line = line + " (in strength)"
        endIf
    endIf

    return line
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
    if !Manager.PDV_ArgonianHistSubstrate
        return "Far from Black Marsh, the Hist is distant and your practice is still settling."
    endIf

    Float histRel = Manager.PDV_ArgonianHistSubstrate.GetHistRelation()
    String text = "Far from Black Marsh, Hist memory is " + GetArgonianLayerStrengthLabel(histRel)
    Float peopleRel = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
    if peopleRel >= 70.0
        text = text + " and the People are near."
    elseIf peopleRel >= 35.0
        text = text + " and the People are with you."
    elseIf peopleRel > 0.0
        text = text + " and the People are scattered."
    else
        text = text + " and the People are far off."
    endIf

    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        text = text + " Sithis is awake, but the Hist remains first."
    else
        Float voidRel = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
        if voidRel >= 35.0
            text = text + " Sithis stirs at the edge."
        elseIf voidRel > 0.0
            text = text + " Sithis waits at the edge."
        endIf
    endIf

    text = text + " Cultural practice: " + GetArgonianCulturalPracticeLabel() + "."

    return text
EndFunction

String Function GetArgonianHistLayerText()
    if !Manager.PDV_ArgonianHistSubstrate
        return "Hist, People, and Void are not yet readable."
    endIf

    String text = "Hist memory is " + GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetHistRelation())
    text = text + "; People support is " + GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation())
    text = text + "; Void awareness is " + GetArgonianVoidStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetVoidRelation())
    Int bedCount = StorageUtil.GetIntValue(Manager.PDV_ArgonianHistSubstrate.GetSubstrateForm(), "PDV.Substrate.ArgonianHist.BedOfChoiceSleepCount")
    if bedCount > 0
        text = text + ". Your chosen bed has begun to matter."
    endIf
    if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        text = text + ". Sithis is active, but the Hist remains first."
    else
        text = text + ". Sithis is only an awareness at the edge."
    endIf
    return text
EndFunction

String Function GetArgonianLayerStrengthLabel(Float value)
    if value >= 70.0
        return "held"
    elseIf value >= 35.0
        return "present"
    elseIf value > 0.0
        return "thin"
    endIf

    return "distant"
EndFunction

String Function GetArgonianVoidStrengthLabel(Float value)
    if Manager.PDV_ArgonianHistSubstrate && Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        return "awake"
    elseIf value >= 35.0
        return "stirring"
    elseIf value > 0.0
        return "at the edge"
    endIf

    return "dormant"
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

Function HandleRedguardSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Redguard.AncestralRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Redguard.AncestralRest", sleepCellId)
            ShowRedguardNotification(None, "This resting place remembers the old line.")
            Manager.Trace(2, "Redguard ancestral-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryRedguardRemembering(playerRef, sleepCellId, reason)
        return                          ; Remembering menu shown; suppress the rest-notice this wake
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.RedguardAncestralRest")
        return
    endIf

    RecordRedguardAncestralRest(1.0, "sleep_ancestor_rest_" + reason)
EndFunction

Bool Function TryRedguardRemembering(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MSG_RedguardRemembering || GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.RedRemember.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MSG_RedguardRemembering.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyRedguardRemembering(playerRef, pressed)
    return true
EndFunction

Function ApplyRedguardRemembering(Actor playerRef, Int index)
    RemoveRedguardRememberSpells(playerRef)
    Spell chosen = GetRedguardRememberSpell(index)
    if !chosen
        return
    endIf

    Int sectNow = 0
    if Manager.PDV_RedguardSectTrack
        sectNow = Manager.PDV_RedguardSectTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.SectAtRite", sectNow)
    StorageUtil.SetFloatValue(None, "PDV.RedRemember.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Tu'whacca pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    Manager.LedgerRuntime.AwardPiety(Manager.PDV_Tuwhacca, 0.5, "Took up the Remembering of Names")
    Manager.AppendBookOfDaysEntry("You remembered a name of the old line. The dead are kept in the telling.", Utility.GetCurrentGameTime() as Int, "substrate.act", "tu-whacca", False)
    Manager.SendPrismaToast("tuwhacca", "good", "Remembering of Names", "The observance settles into you.")
    Manager.Trace(2, "Redguard Remembering observance applied: " + index)
EndFunction

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

Function HandleBretonSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BretonAncestralDream")
    if multiplier <= 0.0
        return
    endIf

    AwardBretonAncestorSpinePulse(multiplier, "sleep_dream_" + reason)
    if GetBretonTraditionValue() != Manager.BRETON_TRADITION_HIDDEN_ART
        return
    endIf
    if Manager.LedgerRuntime.PDV_Julianos
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Julianos, Manager.LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR, None, multiplier)
    endIf
    if Manager.LedgerRuntime.PDV_Mara
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
    endIf
    AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_RENEWABLE_POINTS, "event_314", "sleep_in_bed_" + reason)
    Manager.SurfaceP2AmbientProgressNotice("Hidden reflection", "Rest gives the Hidden Art a hearth-kept shape.")
EndFunction

Function HandleLekiHonorableDuel(String reason)
    if !Manager.PDV_Leki || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Leki)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.LekiHonorableDuel")
    if multiplier <= 0.0
        Manager.Trace(2, "Leki honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Leki, Manager.PDV_Leki.SIGNAL_HONORABLE_DUEL, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Leki, "Duel honored", "marks single combat honorably won.")
    Manager.Trace(2, "Leki honorable-duel routed (" + reason + ")")
EndFunction

Function HandleRedguardCrownTombRespect(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardCrownTombRespect")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_CROWN, multiplier, reason)
    AwardRedguardCrownSignal(multiplier, reason)
    Manager.Trace(2, "Redguard Crown tomb respect routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_FOREBEAR, multiplier, reason)
    AwardRedguardForebearSignal(multiplier)
    Manager.Trace(2, "Redguard Forebear road passage routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, reason)
    ApplyRedguardAshAbahDutyRewards(reason, multiplier)
    Manager.Trace(2, "Redguard AshAbah death duty routed with multiplier " + multiplier)
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
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardFarShoresToken")
    EnsureRedguardSectInitialized()
    Int currentSect = Manager.PDV_RedguardSectTrack.GetCurrentState()
    Manager.PDV_RedguardSectTrack.RecordEvidenceDay(currentSect, reason)
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.FarShoresToken", multiplier)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf
    AwardRedguardFarShoresSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    ShowRedguardNotification(Manager.PDV_Notif_Redguard_FarShoresToken_Activate, "You tend the Far Shores token and speak to Tu'whacca.")
    Manager.Trace(2, "Redguard Far Shores token routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAncestorSpine(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAncestorSpine")
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    Manager.SurfaceP2BookReadNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")
    Manager.Trace(2, "Redguard ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardAncestralRest(Float multiplier, String reason)
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    Manager.Trace(2, "Redguard ancestral rest routed with multiplier " + multiplier)
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
    if !Manager.PDV_Tuwhacca || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Tuwhacca)
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

Function SyncBretonRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isBreton = GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON
    SyncBretonAncestorSubstrate(playerRef, isBreton)
    if isBreton
        EnsureBretonDruidicForkInitialized()
    endIf

    Int traditionValue = GetBretonTraditionValue()
    ; v3 12.5 / race sheet 10.3: Breton has NO generic broad lane. The retired
    ; generic Tradition_T1/T2 spells are force-removed so a migrated save loses
    ; them; the broad role now lives in each tradition family's T1/T2 phase, and
    ; the focused patron unlocks T3.
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Tradition_T1, False, "Breton Tradition T1 (retired)")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Breton_Tradition_T2, False, "Breton Tradition T2 (retired)")

    ; Unified model (2026-07-13): the tradition family grants T1/T2 practice only.
    ; The former T3 slots (KnightsRoad_T3 / GreenWay_T3 / HiddenArt_T3) are now
    ; patron-champion boons owned solely by SyncBretonChampionBoon, so the family
    ; sync must not touch them (else it would strip a boon the champion sync just
    ; granted - the reused-spell cross-lane strip, within Breton).
    SyncBretonTraditionRewardFamily(playerRef, Manager.BRETON_TRADITION_KNIGHTS_ROAD, traditionValue, Manager.PDV_Bless_Breton_KnightsRoad_T1, Manager.PDV_Bless_Breton_KnightsRoad_T2, "KnightsRoad")
    SyncBretonTraditionRewardFamily(playerRef, Manager.BRETON_TRADITION_HIDDEN_ART, traditionValue, Manager.PDV_Bless_Breton_HiddenArt_T1, Manager.PDV_Bless_Breton_HiddenArt_T2, "HiddenArt")
    SyncBretonTraditionRewardFamily(playerRef, Manager.BRETON_TRADITION_GREEN_WAY, traditionValue, Manager.PDV_Bless_Breton_GreenWay_T1, Manager.PDV_Bless_Breton_GreenWay_T2, "GreenWay")
    SyncBretonChampionBoon(playerRef, isBreton, traditionValue)
    SyncBretonKnightlyVowCreedLossSpells(isBreton && traditionValue == Manager.BRETON_TRADITION_KNIGHTS_ROAD)
    SyncBretonWitchcraftExposureRuptureSpell(isBreton)
    SyncBretonDruidicForkBetrayalSpell(isBreton && GetBretonDruidicForkValue() == Manager.BRETON_DRUIDIC_FORK_BETRAYED)
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

Bool Function IsBretonNonResonantPatronChampion(Int traditionValue)
    if Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE || !Manager.GetActiveDeity()
        return False
    endIf
    if Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity()) < Manager.LedgerRuntime.TIER_CHAMPION
        return False
    endIf
    return !IsDeityResonantWithBretonTradition(traditionValue, Manager.GetActiveDeity())
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

String Function GetBretonDruidicForkLabel()
    Int forkValue = GetBretonDruidicForkValue()
    if forkValue == Manager.BRETON_DRUIDIC_FORK_DRUIDIC
        return "Druidic"
    elseIf forkValue == Manager.BRETON_DRUIDIC_FORK_WEREWOLF
        return "Werewolf"
    elseIf forkValue == Manager.BRETON_DRUIDIC_FORK_BETRAYED
        return "Betrayed"
    endIf

    return "None"
EndFunction

Bool Function IsBretonTraditionNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Breton.LastTraditionSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncBretonNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Breton
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Breton)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Breton, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Breton)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Breton)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.BretonSpellActive", 0)
    endIf
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

Function SyncRedguardRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isRedguard = GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD
    Int sectValue = GetActiveRedguardSpineSect()
    SyncRedguardSpineBoon(playerRef, isRedguard, sectValue)
    ; Option 2 (2026-07-16): the generic ancestor FLOOR (AncestorSpine_T1, "Ancestors' Regard -
    ; Observant") is descoped -- the sect spine (SyncRedguardSpineBoon) is the always-on ancestor
    ; layer. Broad progression is KEPT (owner ruling 2026-07-16): AncestorSpine_T2 remains the
    ; broad-worship Faithful reward, so a broad Redguard at 6+ ancestor-spine sources gains
    ; "Ancestors' Regard - Faithful" on top of the sect spine. Focused patrons stay broad-state gated
    ; out of T2, so they carry only their sect spine.
    Bool broadFaithful = isRedguard && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_AncestorSpine_T2, broadFaithful, "Redguard AncestorSpine T2")

    SyncRedguardRewardFamily(playerRef, Manager.PDV_Tuwhacca, Manager.PDV_Bless_Redguard_Tuwhacca_T1, Manager.PDV_Bless_Redguard_Tuwhacca_T2, Manager.PDV_Bless_Redguard_Tuwhacca_T3, "Tuwhacca")
    SyncRedguardRewardFamily(playerRef, Manager.PDV_HoonDing, Manager.PDV_Bless_Redguard_HoonDing_T1, Manager.PDV_Bless_Redguard_HoonDing_T2, Manager.PDV_Bless_Redguard_HoonDing_T3, "HoonDing")
    SyncRedguardRewardFamily(playerRef, Manager.PDV_Leki, Manager.PDV_Bless_Redguard_Leki_T1, Manager.PDV_Bless_Redguard_Leki_T2, Manager.PDV_Bless_Redguard_Leki_T3, "Leki")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_FarShoresToken, isRedguard && StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken") > 0.0, "Redguard Far Shores Token")
    if isRedguard && Manager.PDV_RedguardSectTrack
        MaybeShowRedguardChampionEntry(Manager.PDV_RedguardSectTrack.GetCurrentState())
    endIf
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

Bool Function IsRedguardAncestorDistanceNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure") > 0
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Redguard.LastSectSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncRedguardNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Redguard
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
        return
    endIf

    if shouldBeActive
        ; Pass 5 rubric sweep (carried from Pass 2). This asked the engine the same
        ; question twice in consecutive lines -- wasActive was computed and then the very
        ; next line re-ran HasSpell on the same spell and the same actor. Reuse the answer.
        Bool wasActive = playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Redguard)
        if !wasActive
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Redguard, False)
        endIf
        if !wasActive
            EmitRedguardDeathDutyAbandonmentMinus("redguard_ancestor_distance_neglect")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Redguard)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Redguard)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
    endIf
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
    if deity == Manager.LedgerRuntime.PDV_Stendarr
        return Manager.PDV_Msg_Breton_Stendarr_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return Manager.PDV_Msg_Breton_Akatosh_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return Manager.PDV_Msg_Breton_Mara_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return Manager.PDV_Msg_Breton_Arkay_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return Manager.PDV_Msg_Breton_Julianos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return Manager.PDV_Msg_Breton_Zenithar_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return Manager.PDV_Msg_Breton_Kynareth_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return Manager.PDV_Msg_Breton_Dibella_Offer
    elseIf deity == Manager.PDV_Magnus
        return Manager.PDV_Msg_Breton_Magnus_Offer
    elseIf deity == Manager.PDV_Talos
        return Manager.PDV_Msg_Breton_Talos_Offer
    elseIf deity == Manager.PDV_Yffre
        return Manager.PDV_Msg_Breton_Yffre_Offer
    endIf

    return None
EndFunction

Message Function GetRedguardFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Tuwhacca
        return Manager.PDV_Msg_Redguard_Tuwhacca_Offer
    elseIf deity == Manager.PDV_Leki
        return Manager.PDV_Msg_Redguard_Leki_Offer
    elseIf deity == Manager.PDV_HoonDing
        return Manager.PDV_Msg_Redguard_HoonDing_Offer
    endIf

    return None
EndFunction

Bool Function IsBretonOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        return False
    endIf

    return deity == Manager.LedgerRuntime.PDV_Kynareth || deity == Manager.PDV_Talos || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Zenithar || deity == Manager.PDV_Magnus || deity == Manager.PDV_Yffre || Manager.DaedricRuntime.IsBretonHiddenArtDaedricOfferDeity(deity)
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

Bool Function IsRedguardOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return False
    endIf

    return deity == Manager.PDV_Tuwhacca || deity == Manager.PDV_HoonDing || deity == Manager.PDV_Leki
EndFunction

Function ApplyBretonCurseHandlers(Int oldState, Int newState, String reason)
    Bool curseActive = newState != 0
    if curseActive
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 2)
    elseIf oldState != 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 1)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Breton.RestorationState", 0)
    endIf

    EnsureBretonDruidicForkInitialized()
    Int forkValue = GetBretonDruidicForkValue()
    if newState == 1 && GetBretonTraditionValue() == Manager.BRETON_TRADITION_GREEN_WAY && forkValue == Manager.BRETON_DRUIDIC_FORK_DRUIDIC
        SetBretonDruidicFork(Manager.BRETON_DRUIDIC_FORK_WEREWOLF, reason)
    elseIf oldState == 1 && newState == 0 && forkValue == Manager.BRETON_DRUIDIC_FORK_WEREWOLF
        SetBretonDruidicFork(Manager.BRETON_DRUIDIC_FORK_DRUIDIC, reason)
    endIf
EndFunction

Function ApplyRedguardCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressRedguardCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_VampireOnset, "The vampire curse interrupts Tu'whacca's cycle until cure and re-entry.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_WerewolfOnset, "The beast blood strains the route to proper mortality.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry, "The thirst is gone, but the ancestors' protection stays withheld until you take up the death-duty and re-enter Tu'whacca's cycle.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 1)
        endIf
    elseIf oldState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_WerewolfCured, "The beast blood is quiet. The mortal road steadies again.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 1)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
    endIf

    StorageUtil.SetStringValue(None, "PDV.Curse.Redguard.LastReason", reason)
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
    Int normalized = PDV_DevotionRules.ClampInt(traditionValue, 0, 2)
    Manager.BeginRaceSetupQuietPresentation(reason)
    StorageUtil.SetIntValue(None, "PDV.Breton.Tradition", normalized)
    StorageUtil.SetIntValue(None, "PDV.Breton.SetupComplete", 1)
    StorageUtil.SetStringValue(None, "PDV.Breton.StartupReason", reason)
    if normalized == Manager.BRETON_TRADITION_GREEN_WAY
        SetBretonDruidicFork(Manager.BRETON_DRUIDIC_FORK_DRUIDIC, reason)
        ; Seed the covenant at its open midpoint so a fresh Green Way Breton reads
        ; "open" (50), not the rebanded fraying band (<30). Never lowers an
        ; existing value.
        if StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 0) < 50
            StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        endIf
    else
        SetBretonDruidicFork(Manager.BRETON_DRUIDIC_FORK_NONE, reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicForkInitialized", 1)
    PDV_DeityBase traditionDeity = GetBretonTraditionDeity(normalized)
    if traditionDeity
        String traditionLabel = GetBretonTraditionLabel()
        Manager.SendPrismaShiftToast("You set your tradition: " + traditionLabel + ".", "", Manager.GetPrismaSymbolForDeity(traditionDeity))
        Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(traditionLabel), Utility.GetCurrentGameTime() as Int, "reorientation", Manager.GetPrismaSymbolForDeity(traditionDeity), True, 3, "", True)
        Manager.SurfaceTransition("emergence", traditionDeity.DeityName, "onset", traditionDeity.DeityIndex, "revelation")
    endIf
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    Manager.BeginRaceSetupQuietPresentation(reason)
    if Manager.PDV_RedguardSectTrack
        Int normalized = PDV_DevotionRules.ClampInt(sectValue, Manager.REDGUARD_SECT_CROWN, Manager.REDGUARD_SECT_ASHABAH)
        Manager.PDV_RedguardSectTrack.SetState(normalized, reason)
        Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(GetRedguardSectLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "sect", True, 3, "", True)
        ShowRedguardSectEntry(normalized)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.SetupComplete", 1)
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

Function HandleBretonTraditionChoice(Int traditionValue, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        Manager.Trace(2, "Breton tradition choice ignored for non-Breton origin.")
        return
    endIf

    ; Tradition onboarding is explicit and start-locked: the first choice latches
    ; it, and there is no silent mid-game switching in 1.0. A later off-tradition
    ; source becomes cross-tradition pressure, never a silent tradition rewrite.
    if StorageUtil.GetIntValue(None, "PDV.Breton.SetupComplete") == 1
        if StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1) != traditionValue
            StorageUtil.SetIntValue(None, "PDV.Breton.CrossTraditionPressure", StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") + 1)
            StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
            Manager.Trace(2, "Breton tradition locked; off-tradition source -> cross-tradition pressure: " + reason)
        endIf
        return
    endIf

    ApplyBretonInitialChoice(traditionValue, reason)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastTraditionHookReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Breton.LastTraditionSignalTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Breton tradition choice routed: " + reason)
EndFunction

Function DecayBretonWitchcraftExposureAtDawn()
    Int exposure = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure")
    if exposure <= 0
        return
    endIf
    exposure -= 1
    StorageUtil.SetIntValue(None, "PDV.Breton.WitchcraftExposure", exposure)
    Manager.Trace(2, "Breton WitchcraftExposure passive decay -> " + exposure)
EndFunction

Function DecayBretonDruidicStandingAtDawn()
    if !ShouldBretonDruidicStandingFray()
        return
    endIf

    ; Once-per-dawn guard. fix-plan 4.2: the day+1 encoding already dodged the day-0
    ; self-suppression trap, but on the raw-midnight day -- now the actual dawn day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Breton.DruidicDecayDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        return
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Breton.DruidicDecayDay")

    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    if standingValue <= 0
        return
    endIf
    standingValue = PDV_DevotionRules.ClampInt(standingValue - 1, 0, 100)
    StorageUtil.SetIntValue(None, "PDV.Breton.DruidicStanding", standingValue)
    Manager.Trace(2, "Breton DruidicStanding neglect decay -> " + standingValue)
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
    if !Manager.PDV_BretonAncestorSubstrate
        return
    endIf

    Manager.PDV_BretonAncestorSubstrate.ClearSubstrateBoons()
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
    if Manager.GetQrQueueTransactionActive()
        Manager.SetQrQueueNeedsBretonRewardSync(True)
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
    if Manager.GetQrQueueTransactionActive()
        Manager.SetQrQueueNeedsBretonRewardSync(True)
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        Manager.Trace(2, "Breton Knightly Vow ignored for non-Breton origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BretonKnightlyVow")
    if multiplier <= 0.0
        return
    endIf

    if Manager.LedgerRuntime.PDV_Stendarr
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Stendarr, Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_MERCY, None, multiplier)
    endIf
    if !AwardBretonPracticePulse(Manager.BRETON_TRADITION_KNIGHTS_ROAD, Manager.BRETON_PRACTICE_CURATED_POINTS, "handler_knightly_vow", reason)
        MaybeRecordBretonCrossTraditionPressure(Manager.BRETON_TRADITION_KNIGHTS_ROAD, "handler_knightly_vow", reason)
    endIf

    AwardBretonAncestorSpinePulse(multiplier, reason)
    StorageUtil.SetStringValue(None, "PDV.Breton.LastKnightlyVowReason", reason)
    Manager.Trace(2, "Breton Knightly Vow routed: " + reason)
EndFunction

Function HandleBretonHiddenArtExposure(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        Manager.Trace(2, "Breton Hidden Art ignored for non-Breton origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BretonHiddenArtExposure")
    if multiplier <= 0.0
        return
    endIf

    if Manager.PDV_Magnus
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Magnus, Manager.PDV_Magnus.SIGNAL_DISCIPLINED_STUDY, None, multiplier)
    endIf
    if Manager.LedgerRuntime.PDV_Mara && PDV_DevotionRules.StringContainsToken(reason, "home")
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.LedgerRuntime.PDV_Mara, Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY, None, multiplier)
    endIf
    Bool practiceAwarded = AwardBretonPracticePulse(Manager.BRETON_TRADITION_HIDDEN_ART, Manager.BRETON_PRACTICE_CURATED_POINTS, "handler_hidden_art_exposure", reason)
    if !practiceAwarded
        MaybeRecordBretonCrossTraditionPressure(Manager.BRETON_TRADITION_HIDDEN_ART, "handler_hidden_art_exposure", reason)
    endIf
    AwardBretonAncestorSpinePulse(multiplier, reason)
    ; An approved P2 book is a distinct player acknowledgement even when the
    ; daily practice cap has already reduced its mechanical credit.
    Manager.SurfaceP2BookReadNotice(reason, GetBretonHiddenArtNoticeTitle(reason), GetBretonHiddenArtNoticeText(reason))
    Manager.Trace(2, "Breton Hidden Art exposure routed: " + reason)
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_BRETON
        Manager.Trace(2, "Breton Green Way ignored for non-Breton origin.")
        return
    endIf

    EnsureBretonDruidicForkInitialized()
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BretonGreenWayStanding")
    if multiplier <= 0.0
        return
    endIf
    if Manager.PDV_Yffre
        ; Breton-voiced Green Way signal; the Bosmer Living Story signal stays
        ; Bosmer-only so driver rows read in the right tradition's voice.
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Yffre, Manager.PDV_Yffre.SIGNAL_GREEN_WAY, None, multiplier)
    endIf
    if !AwardBretonPracticePulse(Manager.BRETON_TRADITION_GREEN_WAY, Manager.BRETON_PRACTICE_CURATED_POINTS, "handler_green_way_standing", reason)
        MaybeRecordBretonCrossTraditionPressure(Manager.BRETON_TRADITION_GREEN_WAY, "handler_green_way_standing", reason)
    endIf
    AwardBretonAncestorSpinePulse(multiplier, reason)
    Manager.Trace(2, "Breton Green Way standing routed: " + reason)
EndFunction

String Function GetBretonMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", Manager.LedgerRuntime.PDV_Kynareth, "Sky, travel, and druidic memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("talos", "Talos", "god", "talos", Manager.PDV_Talos, "Civic defiance and Septim inheritance.")
    entries = entries + "," + Manager.RosterMedallionEntry("mara", "Mara", "god", "mara", Manager.LedgerRuntime.PDV_Mara, "Household, mercy, and love.")
    entries = entries + "," + Manager.RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", Manager.LedgerRuntime.PDV_Akatosh, "Time, order, and covenant.")
    entries = entries + "," + Manager.RosterMedallionEntry("arkay", "Arkay", "god", "arkay", Manager.LedgerRuntime.PDV_Arkay, "Death, burial, and clean endings.")
    entries = entries + "," + Manager.RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", Manager.LedgerRuntime.PDV_Stendarr, "Mercy, protection, and oath.")
    entries = entries + "," + Manager.RosterMedallionEntry("julianos", "Julianos", "god", "julianos", Manager.LedgerRuntime.PDV_Julianos, "Learning, law, and formal craft.")
    entries = entries + "," + Manager.RosterMedallionEntry("dibella", "Dibella", "god", "dibella", Manager.LedgerRuntime.PDV_Dibella, "Beauty, courtliness, and grace.")
    entries = entries + "," + Manager.RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", Manager.LedgerRuntime.PDV_Zenithar, "Trade, craft, and honest work.")
    entries = entries + "," + Manager.RosterMedallionEntry("magnus", "Magnus", "god", "magnus", Manager.PDV_Magnus, "Magic, light, and hidden inheritance.")
    entries = entries + "," + Manager.PendingMedallionEntry("phynaster", "Phynaster", "god", "phynaster", "Pilgrimage, endurance, and Elven memory.")
    entries = entries + "," + Manager.RosterMedallionEntry("yffre", "Y'ffre", "god", "yffre", Manager.PDV_Yffre, "Green memory, story, and law.")
    return entries
EndFunction

String Function GetRedguardMedallionEntriesJson()
    String entries = Manager.PendingMedallionEntry("satakal", "Satakal", "god", "satakal", "Worldskin, cycle, and cosmic turning.")
    entries = entries + "," + Manager.PendingMedallionEntry("ruptga", "Ruptga", "god", "ruptga", "Tall Papa, ancestry, and guidance.")
    entries = entries + "," + Manager.RosterMedallionEntry("tuwhacca", "Tu'whacca", "god", "tu-whacca", Manager.PDV_Tuwhacca, "Death, passage, and the proper road.")
    entries = entries + "," + Manager.PendingMedallionEntry("tava", "Tava", "god", "tava", "Wind, sailors, and safe passage.")
    entries = entries + "," + Manager.RosterMedallionEntry("leki", "Leki", "god", "leki", Manager.PDV_Leki, "Sword-skill, discipline, and grace.")
    entries = entries + "," + Manager.PendingMedallionEntry("onsi", "Onsi", "god", "onsi", "The blade, craft, and warrior making.")
    entries = entries + "," + Manager.RosterMedallionEntry("hoon-ding", "HoonDing", "god", "hoon-ding", Manager.PDV_HoonDing, "Make-way spirit and impossible survival.")
    return entries
EndFunction

String Function GetRedguardSurveyText()
    if !Manager.PDV_RedguardSectTrack
        return "The Far Shores are named, but your Redguard sect is not yet readable here."
    endIf

    String text = GetRedguardSurveySectText()
    if StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") > 0
        text = text + " You have read the words of the ancestors, and the dead are nearer for it."
    endIf
    Float farShoresWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")
    if farShoresWeight > 0.0
        text = text + " The Far Shores token has been tended lately, and Tu'whacca holds the way open."
    endIf

    Int cyclePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure")
    if cyclePressure == 2
        text = text + " The vampire curse has set you outside the cycle, and the Far Shores stay shut until you cure it and return through Tu'whacca."
    elseIf cyclePressure == 1
        text = text + " The beast strains your road to a proper death, but the ancestors only watch the closer for it."
    endIf

    return text
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
    Int tradition = StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    if tradition < 0
        String unchosenText = "You have not yet chosen a tradition. Breton faith takes shape on the Knight's Road, through the Hidden Art, or along the Green Way."
        return unchosenText
    endIf

    String text = ""
    Int practiceTier = GetBretonPracticeTier(tradition)
    String practiceText = " Practice: " + Manager.GetPublicTierBand(practiceTier) + "."
    if tradition == 0
        text = "You walk the Knight's Road: vow, mercy, and protective justice." + practiceText
        Int vow = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
        if vow >= 70
            text = text + " Your knightly vow is intact."
        elseIf vow >= 30
            text = text + " Your knightly vow is strained, and the Road's favor comes harder."
        else
            text = text + " Your knightly vow is broken, and the Road is halted until you restore it."
        endIf
    elseIf tradition == 1
        text = "You walk the Hidden Art: occult practice and the double life." + practiceText
        Int exposure = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure", 0)
        if exposure >= 100
            text = text + " Your practice is notorious, openly named, and your patron rewards the full commitment."
        elseIf exposure >= 75
            text = text + " Your practice is known, and your cover is close to rupture."
        elseIf exposure >= 50
            text = text + " Your practice is known, and the Vigilants are a real danger now."
        elseIf exposure >= 25
            text = text + " Your practice is suspected, and watchful eyes have begun to turn."
        else
            text = text + " Your practice stays hidden, unseen by those who would object."
        endIf
    else
        text = "You walk the Green Way: the old druidic covenant." + practiceText
        Int druidic = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
        if druidic >= 70
            text = text + " Y'ffre answers you steadily."
        elseIf druidic < 30
            text = text + " The Green Way is fraying, and the forest begins to forget you."
        else
            text = text + " Y'ffre is listening."
        endIf
    endIf

    text = text + GetBretonPatronSurveySentence(tradition)

    Int fork = GetBretonDruidicForkValue()
    if fork == 1
        text = text + " The beast in you serves the Green, and the old covenant accepts your shape."
    elseIf fork == 2
        text = text + " You claimed the beast for yourself, and the Green has closed against the wolf."
    elseIf fork == 3
        text = text + " The covenant names you betrayer, and the Green presses against the broken trust."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Breton.CrossTraditionPressure") > 0
        text = text + " You are being pulled toward another tradition, and the pull weighs against the one you walk."
    endIf

    Int restoration = StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState")
    if restoration == 2
        text = text + " A curse has ruptured your tradition, and its road is closed to you until you are cured."
    elseIf restoration == 1
        text = text + " A curse sits on you, and your tradition will not hold until it is restored."
    endIf

    return text
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
    String traditionLabel = GetBretonTraditionLabel()
    Int practiceTier = GetBretonPracticeTier(GetBretonTraditionValue())
    String status = traditionLabel + " Practice " + Manager.GetPublicTierBand(practiceTier)

    PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return status + " / " + Manager.NormalizePublicDeityDisplayText(activePact.DeityName) + " Pact"
    endIf

    if Manager.GetActiveDeity() && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return status + " / " + Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity()) + " Focus"
    endIf

    return status
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

String Function GetBretonKnightlyVowLabel()
    Int integrityValue = StorageUtil.GetIntValue(None, "PDV.Breton.KnightlyVowIntegrity", 100)
    if integrityValue >= 70
        return "intact"
    elseIf integrityValue >= 30
        return "strained"
    endIf

    return "broken"
EndFunction

String Function GetBretonWitchcraftExposureLabel()
    Int exposureValue = StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure", 0)
    if exposureValue >= 100
        return "notorious"
    elseIf exposureValue >= 50
        return "known"
    elseIf exposureValue >= 25
        return "suspected"
    endIf

    return "hidden"
EndFunction

String Function GetBretonDruidicStandingLabel()
    Int standingValue = StorageUtil.GetIntValue(None, "PDV.Breton.DruidicStanding", 50)
    if standingValue >= 70
        return "acknowledged"
    elseIf standingValue < 30
        return "fraying"
    endIf

    return "open"
EndFunction

String Function GetBretonAncestorLayerLabel()
    if !Manager.PDV_BretonAncestorSubstrate
        return "retired"
    endIf

    return "retired"
EndFunction

String Function GetBretonCursePostureLabel()
    Int curseValue = StorageUtil.GetIntValue(None, "PDV.Curse.Breton.RestorationState")
    if curseValue == 2
        return "a ruptured tradition"
    elseIf curseValue == 1
        return "restoration needed"
    endIf

    return ""
EndFunction

String Function GetBretonAncestorSummary()
    if !Manager.PDV_BretonAncestorSubstrate
        return "retired"
    endIf

    return "retired"
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

Function HandleNordSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Nord.HearthRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Nord.HearthRest", sleepCellId)
            ShowNordNotification(None, "This hearth becomes a remembered place of rest.")
            Manager.Trace(2, "Nord hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.NordAncestralRest")
        return
    endIf

    RecordNordAncestralRest("sleep_rest_" + reason, 1.0)
EndFunction

Function HandleDunmerPortableShrinePrayer(String reason)
    if Manager.PDV_DunmerAncestorSubstrate
        ; Layer 1 (ancestor substrate) is silenced under vampirism, halved under the
        ; beast. Layer 2 (Reclamation memory) still answers, so it routes regardless.
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerPortableShrinePrayer") * layerWeight
            Float metricBefore = Manager.PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(multiplier, reason)
            Int tierAfter = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Ancestor prayer marked.", "ancestor", GetDunmerAncestorLayerLabel())
            ; The Ledger driver for the ancestral layer. Sits inside the layerWeight guard on purpose:
            ; vampirism silences this layer entirely, so a silenced prayer must not record one either.
            ; Self-caps to the first prayer of the devotional day; patron-independent by ruling.
            AwardDunmerAncestorSpinePulse(multiplier, reason)
        else
            Manager.Trace(2, "Dunmer ancestor layer silenced by curse posture (" + reason + ")")
        endIf
        Manager.NotifyDiegeticRoutineFavor("dunmer_portable_shrine")
        Bool twilightAwarded = TryAwardDunmerTwilightWindowSignal(reason)
        if !twilightAwarded
            AwardActiveDunmerReclamationMemorySignal()
        endIf
        ; Home presence changes the substrate/ward only. The portable prayer
        ; already supplied the one deity-piety pulse for this logical act.
        ; Home-prayer bonus (11a, reworked 2026-07-04): praying with the portable urn at
        ; your declared ancestor-home fires the bigger home progress step + arms the
        ; ancestor watch (once-per-day near-death save until dawn).
        ; HandleDunmerPlayerHomeBonus self-gates on curse posture.
        if IsPlayerAtDunmerDeclaredHome(Game.GetPlayer())
            _dunmerHomePrayerContext = True
            HandleDunmerPlayerHomeBonus(reason + "_home")
            _dunmerHomePrayerContext = False
        endIf
        Manager.RequestPanelRefresh()
        Manager.Trace(2, "Dunmer portable shrine prayer routed (" + reason + ")")
    endIf
EndFunction

Function HandleDunmerPlayerHomeBonus(String reason)
    Actor homePlayer = Game.GetPlayer()
    if !_dunmerHomePrayerContext || !IsPlayerAtDunmerDeclaredHome(homePlayer)
        if Manager.PDV_DunmerAncestorSubstrate
            Manager.PDV_DunmerAncestorSubstrate.RecordDailyCreditReject("dunmer_home_prayer", reason, "requires_paired_home_prayer")
        endIf
        Manager.Trace(2, "Dunmer home-only substrate route rejected (" + reason + ")")
        return
    endIf
    if Manager.PDV_DunmerAncestorSubstrate
        Float layerWeight = GetDunmerCurseLayerWeight(1)
        if layerWeight > 0.0
            Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerHomeBonus") * layerWeight
            Float metricBefore = Manager.PDV_DunmerAncestorSubstrate.GetMetric()
            Int tierBefore = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.PDV_DunmerAncestorSubstrate.RecordPlayerHomeBonusScaled(multiplier, reason)
            Int tierAfter = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_DunmerAncestorSubstrate.GetMetric() - metricBefore, "Prayers within the home feel more meaningful.", "ancestor", GetDunmerAncestorLayerLabel())
            ; Ancestor watch (11a rework 2026-07-04): the home prayer no longer heals on
            ; the spot; it arms a once-per-day near-death save that lasts until dawn (the
            ; BaanDar-style low-health watcher, PDV_T3DailyLowHealthSaveEffect on the
            ; PDV_SPEL_Dunmer_AncestorWatch ability). ProcessDawn disarms it, so each
            ; day's protection must be re-earned with a fresh home prayer.
            if homePlayer && Manager.PDV_SPEL_Dunmer_AncestorWatch && !homePlayer.HasSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch)
                homePlayer.AddSpell(Manager.PDV_SPEL_Dunmer_AncestorWatch, False)
                Manager.Trace(2, "Dunmer ancestor watch armed (" + reason + ")")
            endIf
        else
            Manager.Trace(2, "Dunmer home rite silenced by curse posture (" + reason + ")")
        endIf
        Manager.NotifyDiegeticRoutineFavor("dunmer_home_bonus")
        Manager.RequestPanelRefresh()
        Manager.Trace(2, "Dunmer player-home bonus routed (" + reason + ")")
    endIf
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

Function HandleDunmerSleepEvents(Actor playerRef, String reason)
    if !Manager.PDV_DunmerAncestorSubstrate || !playerRef
        return
    endIf
    Cell sleepCell = playerRef.GetParentCell()
    if !sleepCell || !sleepCell.IsInterior()
        return
    endIf

    Int sleepCellId = sleepCell.GetFormID()
    ; fix-plan 4.2: the ancestor-home cadence now runs on the shared 06:00 devotional
    ; day with the same zero-reserved +2 encoding the Argonian bed rite uses, so a
    ; midnight crossed mid-sleep can no longer shorten the decline window or split one
    ; night's sleep across two "days". ReadZeroReserved migrates the legacy +1 stamps.
    Int todayStamp = Manager.LedgerRuntime.GetDevotionalDay() + 2
    Int declaredId = StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID")
    if StorageUtil.GetIntValue(None, "PDV.DunHome.DeclaredFormID") != 0
        if sleepCellId == declaredId && StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") > 0
            HandleDunmerDeviationPrice("sleep_deviation_" + reason)
        endIf
        if sleepCellId == declaredId
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
            return
        endIf
    endIf

    if !Manager.PDV_MESG_DunmerMarkHome
        if declaredId == 0
            SetDunmerHome(sleepCellId, todayStamp, reason)
        endIf
        return
    endIf

    Int declinedDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
    if declinedDay > 0 && (todayStamp - declinedDay) < 3
        return
    endIf

    Bool shouldPrompt = declaredId == 0
    if declaredId != 0
        Int candidateId = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateFormID")
        Int candidateCount = StorageUtil.GetIntValue(None, "PDV.DunHome.CandidateCount")
        Int candidateDay = Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
        ; B13 / fix-plan 4.6. CandidateDay was written four times and read zero times, so
        ; the re-declare counter climbed on EVERY sleep -- sleep three times in one night
        ; and the "mark a new home" prompt fired instantly. Gate the increment on the day
        ; actually changing, exactly as TryArgonianBedOfChoiceSleep does.
        if candidateId != sleepCellId
            candidateCount = 1
            StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", sleepCellId)
        elseIf candidateDay != todayStamp
            candidateCount += 1
        endIf
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", candidateCount)
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.CandidateDay")
        shouldPrompt = candidateCount >= 3
    endIf

    if !shouldPrompt
        return
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_DunmerMarkHome.Show()
    ; B4 / fix-plan 3. -1 is "another menu was already up", not a decline: no 3-day
    ; suppression stamp and no wipe of the three-sleep candidacy the player earned.
    if pressed < 0
        Manager.Trace(2, "Dunmer ancestor-home menu not shown (menu busy); candidacy kept.")
        return
    endIf
    if pressed == 0
        SetDunmerHome(sleepCellId, todayStamp, reason)
    else
        Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.DunHome.DeclineDay")
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
        StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    endIf
EndFunction

Function SetDunmerHome(Int sleepCellId, Int devotionalDayStamp, String reason)
    if sleepCellId == 0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredFormID", sleepCellId)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclaredDay", devotionalDayStamp)
    StorageUtil.SetIntValue(None, "PDV.DunHome.DeclineDay", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateFormID", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateCount", 0)
    StorageUtil.SetIntValue(None, "PDV.DunHome.CandidateDay", 0)
    Manager.SendPrismaToast("ancestor", "good", "Ancestor-space", "The ancestors will know this place.")
    Manager.Trace(2, "Dunmer ancestor-home declared: " + reason)
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
    if !Manager.PDV_Tsun || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Tsun)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordTsunAdversity")
    if multiplier <= 0.0
        Manager.Trace(2, "Tsun adversity blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tsun, Manager.PDV_Tsun.SIGNAL_ADVERSITY_SURVIVED, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Tsun, "Adversity survived", "marks a hard fight endured to its end.")
    Manager.Trace(2, "Tsun adversity-survived routed (" + reason + ")")
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

Function HandleNordAncestorSpine(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord ancestor spine ignored for non-Nord origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NordAncestorSpine")
    RecordNordAncestorSpine(reason, multiplier)
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

Function RecordNordAncestralRest(String reason, Float multiplier)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD || multiplier <= 0.0
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_NordAncestorSubstrate
        Float metricBefore = Manager.PDV_NordAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_NordAncestorSubstrate.RecordAncestralRestScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_NordAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("ancestor", tierBefore, tierAfter, Manager.PDV_NordAncestorSubstrate.GetMetric() - metricBefore, "The old line rested near.", "journal", GetNordAncestorLayerLabel())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Nord.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Nord.AncestralRestCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Nord.LastAncestralRestReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Nord.LastAncestralRestTime", Utility.GetCurrentGameTime())
    ShowNordNotification(None, "You wake with the old line nearer.")
    Manager.Trace(2, "Nord ancestral rest routed with multiplier " + multiplier)
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
    if !Manager.PDV_NordAncestorSubstrate
        return
    endIf

    Int postureBefore = Manager.PDV_NordAncestorSubstrate.GetAncestorPosture()
    Bool curseActive = IsNordVampireSuppressed()
    Manager.PDV_NordAncestorSubstrate.ProcessAncestorDawn(curseActive, "dawn")
    Int postureAfter = Manager.PDV_NordAncestorSubstrate.GetAncestorPosture()
    if postureBefore > Manager.PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN && postureAfter == Manager.PDV_NordAncestorSubstrate.POSTURE_FORGOTTEN
        ShowNordNotification(Manager.PDV_Notif_Nord_General_AncestorsQuiet, "The ancestors are quiet.")
    endIf
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

Bool Function IsKyneNeglectActive()
    return Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Kyne)
EndFunction

Function SyncKyneNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Kyne
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Kyne)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Kyne, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Kyne)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Kyne)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.KyneSpellActive", 0)
    endIf
EndFunction

Function SyncNordPatronNeglectSpells()
    ; Per-patron Nord neglect (follow-on, owner ruling 2026-06-27): each focusable NON-Kyne Nord
    ; patron gets its own gentle flat neglect spell, applied only when it is the player's active
    ; patron AND flagged neglected (recency lapse). Kyne keeps its dedicated spell
    ; (SyncKyneNeglectSpell). Idempotent and self-clearing: each spell is set to its exact correct
    ; state, so calling this from any branch (focused / broad / uncommitted / Prince) removes a stale
    ; spell after a patron switch. No-ops entirely until the ESP batch authors the four records.
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf
    Bool isNord = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Shor,  isNord && Manager.GetActiveDeity() == Manager.PDV_Shor  && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Shor))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Tsun,  isNord && Manager.GetActiveDeity() == Manager.PDV_Tsun  && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Tsun))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Stuhn, isNord && Manager.GetActiveDeity() == Manager.PDV_Stuhn && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Stuhn))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.PDV_SPEL_Neglect_Talos, isNord && Manager.GetActiveDeity() == Manager.PDV_Talos && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.PDV_Talos))
    ; Nord Old Ways patrons (Orkey/Dibella roster). _activeDeity keys on the internal Arkay/Dibella
    ; deity, not the "Orkey" display name; the spell record carries the Orkey-facing name.
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.LedgerRuntime.PDV_SPEL_Neglect_Arkay,   isNord && Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Arkay   && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.LedgerRuntime.PDV_Arkay))
    Manager.LedgerRuntime.SyncOnePatronNeglectSpell(playerRef, Manager.LedgerRuntime.PDV_SPEL_Neglect_Dibella, isNord && Manager.GetActiveDeity() == Manager.LedgerRuntime.PDV_Dibella && Manager.LedgerRuntime.IsNeglectFlagActive(Manager.LedgerRuntime.PDV_Dibella))
EndFunction

Function SyncDunmerRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isDunmer = GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER
    Bool broadReclamationFaithful = isDunmer && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Dunmer_Reclamation_T2, broadReclamationFaithful, "Dunmer Reclamation T2")

    SyncDunmerRewardFamily(playerRef, Manager.PDV_Azura, Manager.PDV_Bless_Dunmer_Azura_T1, Manager.PDV_Bless_Dunmer_Azura_T2, Manager.PDV_Bless_Dunmer_Azura_T3, "Azura")
    SyncDunmerRewardFamily(playerRef, Manager.PDV_Boethiah, Manager.PDV_Bless_Dunmer_Boethiah_T1, Manager.PDV_Bless_Dunmer_Boethiah_T2, Manager.PDV_Bless_Dunmer_Boethiah_T3, "Boethiah")
    SyncDunmerRewardFamily(playerRef, Manager.PDV_Mephala, Manager.PDV_Bless_Dunmer_Mephala_T1, Manager.PDV_Bless_Dunmer_Mephala_T2, Manager.PDV_Bless_Dunmer_Mephala_T3, "Mephala")
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

Bool Function IsDunmerAncestorNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        return False
    endIf

    Int dunmerPosture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    return dunmerPosture == 1 || dunmerPosture == 2
EndFunction

Function SyncDunmerNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Dunmer
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Dunmer)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Dunmer, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Dunmer)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Dunmer)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.DunmerSpellActive", 0)
    endIf
EndFunction

Function HandleDunmerClumsyCrime(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER || !Manager.PDV_Mephala
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1) != 2
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MephalaSecretBetrayed")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_SECRET_BETRAYED, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Dunmer.SecretBetrayedCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastSecretBetrayedReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Dunmer.LastSecretBetrayedTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Mephala secret-betrayed routed: " + reason + " multiplier=" + multiplier)
EndFunction

Function SyncNordRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    EnsureNordOrkeyRewardRuntimeWiring()

    Bool isNord = GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
    Int baselineState = GetNordPantheonBaselineState()
    SyncNordAncestorSubstrate(playerRef, isNord)
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Kyne, Manager.PDV_Bless_Nord_Kyne_T1, Manager.PDV_Bless_Nord_Kyne_T2, Manager.PDV_Bless_Nord_Kyne_T3, "Kyne")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Shor, Manager.PDV_Bless_Nord_Shor_T1, Manager.PDV_Bless_Nord_Shor_T2, Manager.PDV_Bless_Nord_Shor_T3, "Shor")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Tsun, Manager.PDV_Bless_Nord_Tsun_T1, Manager.PDV_Bless_Nord_Tsun_T2, Manager.PDV_Bless_Nord_Tsun_T3, "Tsun")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.PDV_Stuhn, Manager.PDV_Bless_Nord_Stuhn_T1, Manager.PDV_Bless_Nord_Stuhn_T2, Manager.PDV_Bless_Nord_Stuhn_T3, "Stuhn")
    SyncNordRewardFamily(playerRef, -1, Manager.PDV_Talos, Manager.PDV_Bless_Nord_Talos_T1, Manager.PDV_Bless_Nord_Talos_T2, Manager.PDV_Bless_Nord_Talos_T3, "Talos")

    ; Nord Nine Divines gods have no Nord-specific reward records (never authored); reuse the
    ; existing Imperial Divine reward spells (the canonical Nine Divines rewards), identical to
    ; the Mara fix. Owner ruling 2026-06-27. NOTE: Akatosh/Julianos/Kynareth Imperial rewards are
    ; regen-rate (~0 under Requiem) -- a pre-existing Imperial reward-feel gap to convert later.
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Akatosh, Manager.PDV_Bless_Imperial_Akatosh_T1, Manager.PDV_Bless_Imperial_Akatosh_T2, Manager.PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    ; Mara is focusable in BOTH lanes (Old Ways + Nine Divines), like Talos -- baseline -1.
    ; No Nord-specific Mara reward records exist, so reuse the Imperial Mara spells -- this IS
    ; the Nine Divines Mara reward (Restoration +5/+13/+23 + wake-mended), identical across lanes.
    SyncNordRewardFamily(playerRef, -1, Manager.LedgerRuntime.PDV_Mara, Manager.PDV_Bless_Imperial_Mara_T1, Manager.PDV_Bless_Imperial_Mara_T2, Manager.PDV_Bless_Imperial_Mara_T3, "Mara")
    ; Arkay is focusable in BOTH lanes. Old Ways names him Orkey and uses
    ; Orkey-facing Nord reward records so Active Effects do not surface Arkay.
    ; Nine Divines keeps the existing Imperial Arkay rewards.
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_OLD_WAYS, Manager.LedgerRuntime.PDV_Arkay, Manager.PDV_Bless_Nord_Arkay_T1, Manager.PDV_Bless_Nord_Arkay_T2, Manager.PDV_Bless_Nord_Arkay_T3, "Orkey")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Arkay, Manager.PDV_Bless_Imperial_Arkay_T1, Manager.PDV_Bless_Imperial_Arkay_T2, Manager.PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Stendarr, Manager.PDV_Bless_Imperial_Stendarr_T1, Manager.PDV_Bless_Imperial_Stendarr_T2, Manager.PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Zenithar, Manager.PDV_Bless_Imperial_Zenithar_T1, Manager.PDV_Bless_Imperial_Zenithar_T2, Manager.PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    ; Dibella is focusable in BOTH lanes (owner directive 2026-07-05), like Mara --
    ; baseline -1, same Imperial reward reuse either way.
    SyncNordRewardFamily(playerRef, -1, Manager.LedgerRuntime.PDV_Dibella, Manager.PDV_Bless_Imperial_Dibella_T1, Manager.PDV_Bless_Imperial_Dibella_T2, Manager.PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Julianos, Manager.PDV_Bless_Imperial_Julianos_T1, Manager.PDV_Bless_Imperial_Julianos_T2, Manager.PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncNordRewardFamily(playerRef, Manager.NORD_BASELINE_NINE_DIVINES, Manager.LedgerRuntime.PDV_Kynareth, Manager.PDV_Bless_Imperial_Kynareth_T1, Manager.PDV_Bless_Imperial_Kynareth_T2, Manager.PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
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

Function EvaluateKyneCommitmentOffer()
    Manager.LedgerRuntime.EvaluateFormalCommitmentOffer()
EndFunction

Message Function GetNordFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Kyne
        return Manager.PDV_Msg_Nord_Kyne_Offer
    elseIf deity == Manager.PDV_Shor
        return Manager.PDV_Msg_Nord_Shor_Offer
    elseIf deity == Manager.PDV_Tsun
        return Manager.PDV_Msg_Nord_Tsun_Offer
    elseIf deity == Manager.PDV_Stuhn
        return Manager.PDV_Msg_Nord_Stuhn_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return Manager.PDV_Msg_Nord_Akatosh_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return Manager.PDV_Msg_Nord_Mara_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
            return Manager.PDV_Msg_Nord_Orkey_Offer
        endIf
        return Manager.PDV_Msg_Nord_Arkay_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Stendarr
        return Manager.PDV_Msg_Nord_Stendarr_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return Manager.PDV_Msg_Nord_Zenithar_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return Manager.PDV_Msg_Nord_Julianos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return Manager.PDV_Msg_Nord_Dibella_Offer
    elseIf deity == Manager.PDV_Talos
        return Manager.PDV_Msg_Nord_Talos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return Manager.PDV_Msg_Nord_Kynareth_Offer
    endIf

    return None
EndFunction

Message Function GetDunmerFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Azura
        return Manager.PDV_Msg_Dunmer_Azura_Offer
    elseIf deity == Manager.PDV_Boethiah
        return Manager.PDV_Msg_Dunmer_Boethiah_Offer
    elseIf deity == Manager.PDV_Mephala
        return Manager.PDV_Msg_Dunmer_Mephala_Offer
    endIf

    return None
EndFunction

Bool Function IsKyneCommitmentSignalReady()
    if !Manager.PDV_Kyne
        return False
    endIf

    return Manager.LedgerRuntime.HasRecentCommitmentSignalDays(Manager.PDV_Kyne, 2, 7)
EndFunction

Bool Function IsNordOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf

    if deity == Manager.PDV_Talos
        return True
    endIf

    Int baselineState = GetNordPantheonBaselineState()
    if baselineState == Manager.NORD_BASELINE_OLD_WAYS
        return deity == Manager.PDV_Kyne || deity == Manager.PDV_Shor || deity == Manager.PDV_Tsun || deity == Manager.PDV_Stuhn || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Dibella
    elseIf baselineState == Manager.NORD_BASELINE_NINE_DIVINES
        return deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Zenithar || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Kynareth
    endIf

    return False
EndFunction

Bool Function IsDunmerOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        return False
    endIf

    return deity == Manager.PDV_Azura || deity == Manager.PDV_Boethiah || deity == Manager.PDV_Mephala
EndFunction

Function ApplyDunmerCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 2)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 1)
    elseIf oldState != 0 && newState == 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 3)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Dunmer.Posture", 0)
    endIf
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
    Bool suppressModal = ShouldSuppressNordCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 0)
        Manager.FavorRuntime.ClearActiveFavor("nord_vampire")
        Manager.LedgerRuntime.ClearPendingCommitment()
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_VampireOnset, "Sovngarde is closed while the thirst remains. Cure the curse, and the scar will still be remembered.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 1)
        endIf
    elseIf oldState == 2 && newState != 2
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.VampireCureFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_VampireCured, "The thirst is gone. The road opens again, but the scar remains.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.VampireCureFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_WerewolfOnset, "The hunt pulls against Sovngarde. Master the beast, or it will master you.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 1)
        endIf
    elseIf newState == 0
        StorageUtil.SetIntValue(None, "PDV.Nord.VampireActive", 0)
        ; oldState == 2 is claimed by the vampire-cure branch above, so reaching
        ; here with oldState == 1 is the werewolf cure and nothing else.
        if oldState == 1 && StorageUtil.GetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown") != 1
            ShowNordMessage(Manager.PDV_Msg_Nord_CurseState_WerewolfCured, "The hunt is set down. Hircine's hold is broken, and Sovngarde calls you once more.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfCureFeedbackShown", 1)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Nord.WerewolfFeedbackShown", 0)
    endIf
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
    Manager.BeginRaceSetupQuietPresentation(reason)
    Int normalized = PDV_DevotionRules.ClampInt(baselineValue, Manager.NORD_BASELINE_OLD_WAYS, Manager.NORD_BASELINE_NINE_DIVINES)
    StorageUtil.SetIntValue(None, "PDV.NordPantheonBaseline.DebugState", normalized)
    if Manager.PDV_NordPantheonBaselineTrack
        Manager.PDV_NordPantheonBaselineTrack.SetState(normalized, reason)
    endIf

    Manager.LedgerRuntime.SetBroadWorship()
    String baselineLabel = "Old Ways"
    if normalized == Manager.NORD_BASELINE_NINE_DIVINES
        baselineLabel = "Nine Divines"
    endIf
    Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(baselineLabel), Utility.GetCurrentGameTime() as Int, "reorientation", "journal", True, 3, "", True)
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

Function HandleDunmerReclamationFocus(Int focusValue, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        Manager.Trace(2, "Dunmer Reclamation focus ignored for non-Dunmer origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerReclamationFocus")
    if multiplier <= 0.0
        return
    endIf

    Float layerWeight = GetDunmerCurseLayerWeight(2) * multiplier
    if Manager.PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
        Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "reclamation_source_" + reason)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocus", PDV_DevotionRules.ClampInt(focusValue, 0, 2))
    StorageUtil.SetIntValue(None, "PDV.Dunmer.ReclamationFocusCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocusCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastReclamationReason", reason)
    AwardDunmerReclamationFocusSignal(focusValue, layerWeight)
    if focusValue == 0
        Manager.SurfaceP2BookReadNotice(reason, "Azura's twilight", "The Reclamation turns toward her.")
    elseIf focusValue == 1
        Manager.SurfaceP2BookReadNotice(reason, "Boethiah's proving", "The Reclamation turns toward struggle.")
    else
        Manager.SurfaceP2BookReadNotice(reason, "Mephala's web", "The Reclamation turns toward secrets.")
    endIf
    Manager.Trace(2, "Dunmer Reclamation focus routed: " + reason + " weight " + layerWeight)
EndFunction

Function HandleDunmerHonorableVictory(Form victimForm)
    ; Canonical player-alias ingress. It records only the clean-combat half; a
    ; single caller cannot award until Story Manager independently confirms the
    ; hostile, non-murder classification for the same victim.
    RecordDunmerCombatVictoryEvidence(victimForm)
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_DUNMER
        Manager.Trace(2, "Dunmer deviation price ignored for non-Dunmer origin.")
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.DunmerDeviationPrice")
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Dunmer.DeviationPriceCount", StorageUtil.GetIntValue(None, "PDV.Dunmer.DeviationPriceCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Dunmer.LastDeviationReason", reason)
    AwardDunmerDeviationPriceSignal(multiplier)
    SurfaceDunmerDeviationPriceNotice()
    Manager.Trace(2, "Dunmer deviation price routed: " + reason)
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
    if TryAwardDunmerTwilightWindowSignal(reason)
        if Manager.PDV_DunmerAncestorSubstrate && GetDunmerCurseLayerWeight(1) > 0.0
            Manager.PDV_DunmerAncestorSubstrate.RecordPortableShrinePrayerScaled(1.0, "good_daedra_altar_" + reason)
        endIf
        Manager.SendPrismaToast("journal", "good", "Good Daedra", "The Good Daedra hear the ash-prayer.")
    elseIf GetPlayerOriginRaceIndex() == Manager.ORIGIN_DUNMER
        Manager.SendPrismaToast("journal", "neutral", "Shrine quiet", "The shrine is quiet in this hour.")
    endIf
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Old Ways state ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.OldWaysContextCount", "PDV.Nord.LastOldWaysReason", "PDV.Nord.LastOldWaysSignalTime", "Nord Old Ways state")
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            Manager.SurfaceP2BookReadNotice(reason, "Faith of the Holds", "The Divines honored in the holds stand nearer.")
        else
            Manager.SurfaceP2BookReadNotice(reason, "The Old Ways", "The elder gods of the Nords stand nearer.")
        endIf
    endIf
EndFunction

Function HandleNordKyneTalosContext(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Kyne/Talos context ignored for non-Nord origin.")
        return
    endIf

    RouteNordFamily(reason, "PDV.Nord.KyneTalosContextCount", "PDV.Nord.LastKyneTalosReason", "PDV.Nord.LastKyneTalosSignalTime", "Nord Kyne/Talos context")
EndFunction

Function HandleNordHircineArkayEdge(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        Manager.Trace(2, "Nord Hircine/Arkay edge ignored for non-Nord origin.")
        return
    endIf

    if RouteNordFamily(reason, "PDV.Nord.HircineArkayEdgeCount", "PDV.Nord.LastHircineArkayReason", "PDV.Nord.LastHircineArkaySignalTime", "Nord Hircine/Arkay edge")
        Manager.SurfaceP2BookReadNotice(reason, "Hunt and grave", "Beast and rest blur at the edges.")
    endIf
EndFunction

String Function GetBookOfDaysDunmerAncestorLabel()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "Unreadable"
    endIf

    Int tierValue = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= 3
        return "Strong"
    elseIf tierValue == 2
        return "Steady"
    elseIf tierValue == 1
        return "Beginning"
    endIf

    return "Quiet"
EndFunction

Bool Function UsesNordOldWaysDeityNames()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf
    return GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
EndFunction

String Function GetNordMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("kyne", "Kyne", "god", "kyne", Manager.PDV_Kyne, "Sky, storm, hunt, and warrior-spirit.")
    entries = entries + "," + Manager.RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", Manager.LedgerRuntime.PDV_Kynareth, "The Nine Divines sky road.")
    entries = entries + "," + Manager.RosterMedallionEntry("talos", "Talos", "god", "talos", Manager.PDV_Talos, "Open defiance and human apotheosis.")
    entries = entries + "," + Manager.RosterMedallionEntry("shor", "Shor", "god", "shor", Manager.PDV_Shor, "The old king and afterlife road.")
    entries = entries + "," + Manager.RosterMedallionEntry("tsun", "Tsun", "god", "tsun", Manager.PDV_Tsun, "Trial, honor, and the threshold.")
    entries = entries + "," + Manager.RosterMedallionEntry("stuhn", "Stuhn", "god", "stuhn", Manager.PDV_Stuhn, "Mercy in war and fair ransom.")
    entries = entries + "," + Manager.RosterMedallionEntry("mara", "Mara", "god", "mara", Manager.LedgerRuntime.PDV_Mara, "Love, hearth, and compassion.")
    entries = entries + "," + Manager.RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", Manager.LedgerRuntime.PDV_Akatosh, "Time, order, and dragon authority.")
    String arkayRosterName = "Arkay"
    if UsesNordOldWaysDeityNames()
        arkayRosterName = "Orkey"
    endIf
    entries = entries + "," + Manager.RosterMedallionEntry("arkay", arkayRosterName, "god", "arkay", Manager.LedgerRuntime.PDV_Arkay, "Death, burial, and proper passage.")
    entries = entries + "," + Manager.RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", Manager.LedgerRuntime.PDV_Stendarr, "Mercy, justice, and protection.")
    entries = entries + "," + Manager.RosterMedallionEntry("julianos", "Julianos", "god", "julianos", Manager.LedgerRuntime.PDV_Julianos, "Law, learning, and craft of mind.")
    entries = entries + "," + Manager.RosterMedallionEntry("dibella", "Dibella", "god", "dibella", Manager.LedgerRuntime.PDV_Dibella, "Beauty, art, and embodied grace.")
    entries = entries + "," + Manager.RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", Manager.LedgerRuntime.PDV_Zenithar, "Work, trade, and honest craft.")
    return entries
EndFunction

String Function GetDunmerMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("azura", "Azura", "prince", "azura", Manager.PDV_Azura, "Dawn, dusk, prophecy, and fate.")
    entries = entries + "," + Manager.RosterMedallionEntry("boethiah", "Boethiah", "prince", "boethiah", Manager.PDV_Boethiah, "Trial, overthrow, and hard becoming.")
    entries = entries + "," + Manager.RosterMedallionEntry("mephala", "Mephala", "prince", "mephala", Manager.PDV_Mephala, "Web, secrecy, clan, and hidden duty.")
    return entries
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_NORD
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Nord.VampireActive") == 1
EndFunction

Bool Function HasNordVampireScar()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD && StorageUtil.GetIntValue(None, "PDV.Nord.VampireScar") == 1
EndFunction

String Function GetNordSurveyBaseText()
    String band = Manager.GetCurrentStandingBand()
    if IsNordVampireSuppressed()
        return "Standing: " + band + ". Sovngarde is closed while the thirst remains. Cure the curse to reopen the road."
    endIf

    String contextText = GetNordContextSurveyText()
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        String focusedText = "Standing: " + band + ". " + Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity()) + " names you."
        if IsFocusedPantheonBoonSuspended()
            return focusedText + " The commitment remains, but its boon is suspended until 50 piety." + contextText
        endIf
        if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
            return focusedText + " The bond is thinning and needs attention." + contextText
        endIf
        return focusedText + " The bond holds." + contextText
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        Int baselineState = GetNordPantheonBaselineState()
        if baselineState == Manager.NORD_BASELINE_NINE_DIVINES
            return "Standing: " + band + ". You walk the Nine Divines as a Nord walks them: weather, hearth, hold, and the old breath underneath." + contextText
        endIf

        return "Standing: " + band + ". You honor the Old Ways broadly." + contextText
    endIf

    if Manager.PDV_HircinePath
        String hircineSummary = Manager.PDV_HircinePath.GetPilotSummary()
        if hircineSummary != "missing"
            return "Standing: " + band + ". The hunt pulls at the edge of the Old Ways. No patron has claimed you, but the beast is listening." + contextText
        endIf
    endIf

    return "Standing: " + band + ". No Nord patron has answered yet. Keep the rites, and the road will grow clearer." + contextText
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
    if IsNordVampireSuppressed()
        return "Vampire rupture"
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        return "Focused " + Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity())
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        if GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            return "Broad Nine Divines"
        endIf

        return "Broad Old Ways"
    endIf

    return "Unsettled"
EndFunction

String Function GetDunmerSurveyText()
    String band = Manager.GetCurrentStandingBand()
    Int reclamationFocus = StorageUtil.GetIntValue(None, "PDV.Dunmer.ReclamationFocus", -1)
    String text = ""
    if reclamationFocus == 0
        text = "Azura holds your focus; the ash-prayer carries beneath her. Your standing with Azura is " + band + "."
    elseIf reclamationFocus == 1
        text = "Boethiah holds your focus; the ash-prayer carries beneath. Your standing with Boethiah is " + band + "."
    elseIf reclamationFocus == 2
        text = "Mephala holds your focus; the ash-prayer carries beneath. Your standing with Mephala is " + band + "."
    else
        text = "The ash-prayer holds and the three Good Daedra answer together. Your standing with the Reclamations is " + band + ". No single Reclamation has your name yet."
    endIf

    Int posture = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if posture == 1
        text = text + " Something in you pulls against the ancestors. The beast, or an unclean rite, makes the ash-prayer carry thinly."
    elseIf posture == 2
        text = text + " The ash-prayer meets no answer; the ancestors do not speak to the undead."
    elseIf posture == 3
        text = text + " The ancestors answer again; your posture is restored, but scarred."
    endIf

    return text
EndFunction

String Function GetDunmerAncestorLayerLabel()
    if !Manager.PDV_DunmerAncestorSubstrate
        return "unreadable"
    endIf

    Int tierValue = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
    if tierValue >= 3
        return "strong"
    elseIf tierValue == 2
        return "steady"
    elseIf tierValue == 1
        return "beginning"
    endIf

    return "quiet"
EndFunction

String Function GetDunmerCursePostureLabel()
    Int postureValue = StorageUtil.GetIntValue(None, "PDV.Curse.Dunmer.Posture")
    if postureValue == 1
        return "strained, the beast pulls at the ancestors"
    elseIf postureValue == 2
        return "silent, the ancestors cannot reach you"
    elseIf postureValue == 3
        return "restored, but scarred"
    endIf

    return ""
EndFunction

String Function GetDunmerReclamationFocusLabel(Int focusValue)
    if focusValue == 0
        return "Azura"
    elseIf focusValue == 1
        return "Boethiah"
    elseIf focusValue == 2
        return "Mephala"
    endIf

    return "unset"
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

String Function GetNordAncestorSummary()
    if !Manager.PDV_NordAncestorSubstrate
        return "missing"
    endIf

    return Manager.PDV_NordAncestorSubstrate.GetPilotSummary()
EndFunction

String Function GetKyneFavorSummary()
    Int maskValue = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ConditionMask")
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.KyneFavor.ActiveCount")
    return "mask=" + maskValue + ";conds=" + PDV_DevotionRules.CountSetBits(maskValue) + ";active=" + activeCount + ";generic=" + Manager.FavorRuntime.GetContextualFavorSummary()
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

Function HandleOrcSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Orc.HearthRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Orc.HearthRest", sleepCellId)
            MaybeShowOrcHearthHeldNotice("sleep_rest_declare_" + reason)
            Manager.Trace(2, "Orc hearth-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryOrcTrialOfIron(playerRef, sleepCellId, reason)
        return                          ; Trial menu shown; suppress the rest-notice this wake
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.OrcAncestralRest")
        return
    endIf

    Int modeValue = GetActiveOrcRewardMode()
    RecordOrcLifeModeSignal(modeValue, 1.0, "sleep_hearth_rest_" + reason)
    MaybeShowOrcHearthHeldNotice("sleep_hearth_rest_" + reason)
    Manager.Trace(2, "Orc ancestral rest routed: " + reason)
EndFunction

Bool Function TryOrcTrialOfIron(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MESG_Orc_TrialOfIron || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.OrcTrial.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MESG_Orc_TrialOfIron.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyOrcTrialOfIron(playerRef, pressed)
    return true
EndFunction

Function ApplyOrcTrialOfIron(Actor playerRef, Int index)
    RemoveOrcTrialSpells(playerRef)
    Spell chosen = GetOrcTrialSpell(index)
    if !chosen
        return
    endIf

    Int modeNow = 0
    if Manager.PDV_OrcLifeModeTrack
        modeNow = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.OrcTrial.ModeAtRite", modeNow)
    StorageUtil.SetFloatValue(None, "PDV.OrcTrial.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Malacath pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    Manager.LedgerRuntime.AwardPiety(Manager.PDV_Malacath, 0.5, "Took up the Trial of Iron")
    Manager.AppendBookOfDaysEntry("You took up a discipline in the Trial of Iron. The Code is held in iron.", Utility.GetCurrentGameTime() as Int, "substrate.act", "malacath", False)
    Manager.SendPrismaToast("malacath", "good", "Trial of Iron", "You take up a discipline of the Code. The Trial of Iron holds you to it.")
    Manager.Trace(2, "Orc Trial of Iron discipline applied: " + index)
EndFunction

Function RemoveOrcTrialSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell disc = GetOrcTrialSpell(i)
        if disc && playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
        endIf
        i += 1
    endWhile
EndFunction

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
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.OrcTrial.Active")
    if active <= 0
        return
    endIf
    Spell disc = GetOrcTrialSpell(active - 1)
    if !disc
        return
    endIf

    Int modeAtRite = StorageUtil.GetIntValue(None, "PDV.OrcTrial.ModeAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC) && IsOrcTrialCoherent(modeAtRite)
    if eligible
        if !playerRef.HasSpell(disc)
            playerRef.AddSpell(disc, False)
            Manager.SendPrismaToast("malacath", "good", "The Code holds", "Your discipline returns.")
        endIf
    else
        if playerRef.HasSpell(disc)
            playerRef.RemoveSpell(disc)
            Manager.SendPrismaToast("malacath", "warning", "The discipline goes quiet", "The standing you swore it under has broken.")
        endIf
    endIf
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
    ; Retained for save/script compatibility. Imperial sleep is not a civic or
    ; pantheon signal under the pacing contract.
EndFunction

Function TryOrcCodeHolds(Actor playerRef)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return
    endIf
    if !playerRef.IsInCombat() || (!Manager.PDV_SPEL_OrcCodeHolds && !Manager.PDV_SPEL_OrcCodeHolds_Devoted)
        return
    endIf

    Int malacathTier = Manager.LedgerRuntime.TIER_NONE
    if Manager.PDV_Malacath
        malacathTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Malacath)
    endIf
    if malacathTier < Manager.LedgerRuntime.TIER_SEEKER
        return
    endIf

    ; B12 / fix-plan 4.5. The rescue latched once per COMBAT SESSION while both siblings
    ; -- the Bosmer Baan Dar gap and the Argonian Sithis burst, the two other below-health
    ; payloads fanned from the same HandlePlayerBelowHealthGate -- are once per DAY. An
    ; uncapped 40-60 HP (+30 stamina) clutch save every fight is a different power budget
    ; from what the design says it is. Same LastDay guard, same devotional-day encoding.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        Manager.Trace(2, "Orc Code Holds suppressed: already spent this devotional day.")
        return
    endIf

    ; The Code Holds is a near-death clutch save. It fires mid-fight the instant
    ; health drops past the below-health gate (Baan Dar Opens the Gap model), not on
    ; combat exit -- so it can actually save the player. Its old
    ; HealRate spell is not cast because Requiem swallows rate-mult healing on a
    ; near-zero base; the actual health save is a flat RestoreActorValue. Requiem-proof.
    if malacathTier >= Manager.LedgerRuntime.TIER_DEVOTED && Manager.PDV_SPEL_OrcCodeHolds_Devoted
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf Manager.PDV_SPEL_OrcCodeHolds
        playerRef.RestoreActorValue("Health", 40.0)
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Orc.CodeHoldsLastDay")

    ; B12's second half asked for a Cast() of PDV_SPEL_OrcCodeHolds* "so the rescue has
    ; feedback". Checked against the records: 071534 and 071536 are both Type=Ability,
    ; CastType=ConstantEffect, TargetType=Self. A constant-effect ability is applied with
    ; AddSpell, never cast -- Spell.Cast() on one is an engine no-op, and the author's
    ; comment above says the HealRate payload is deliberately dead under Requiem anyway.
    ; So the feedback is delivered the way both siblings deliver theirs: a toast.
    Manager.SendPrismaToast("malacath", "good", "The Code holds", "The Code holds, and so do you.")

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCodeHolds")
    if multiplier > 0.0
        Manager.LedgerRuntime.AwardPiety(Manager.PDV_Malacath, 0.5 * multiplier)
    endIf
    StorageUtil.AdjustIntValue(None, "PDV.Orc.CodeHolds.Count", 1)
    Manager.Trace(2, "Orc Code Holds fired.")
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
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_STRONGHOLD, 1.0, reason)
    ; Curated award (dead-wiring burndown Wave 1, 2026-07-07): this handler recorded
    ; life-mode progress but -- unlike its CityDignity/LegionService/SelfMadeCommunity
    ; siblings -- never dispatched the curated signal, so BLOOD_KIN could never bank.
    ; The crisis is a one-shot quest milestone (The Cursed Tribe resolution); the latch
    ; keeps a save-reload edge from ever double-banking it.
    if StorageUtil.GetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded") != 1
        StorageUtil.SetIntValue(None, "PDV.Signal.OrcBloodKinCrisis.Awarded", 1)
        AwardOrcBloodKinSignal(1.0)
    endIf
    Manager.Trace(2, "Orc Blood-Kin crisis routed: " + reason)
EndFunction

Function HandleOrcCityDignity(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcCityDignity")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcCityDignitySignal(multiplier)
    Manager.Trace(2, "Orc City dignity routed with multiplier " + multiplier)
EndFunction

Function HandleOrcLegionService(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcLegionService")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_LEGION_EXILE, multiplier, reason)
    AwardOrcLegionServiceSignal(multiplier)
    Manager.Trace(2, "Orc Legion or exile service routed with multiplier " + multiplier)
EndFunction

Function HandleOrcSelfMadeCommunity(String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcSelfMadeCommunity")
    RecordOrcLifeModeSignal(Manager.ORC_LIFE_MODE_CITY, multiplier, reason)
    AwardOrcSelfMadeCommunitySignal(multiplier)
    if multiplier > 0.0
        MaybeShowOrcHearthHeldNotice(reason)
    endIf
    Manager.Trace(2, "Orc self-made community routed with multiplier " + multiplier)
EndFunction

Function HandleOrcMalacathConduct(Int modeValue, String reason)
    if !IsOrcOrigin() || !Manager.PDV_OrcLifeModeTrack
        return
    endIf

    EnsureOrcLifeModeInitialized()
    if modeValue < Manager.ORC_LIFE_MODE_CITY || modeValue > Manager.ORC_LIFE_MODE_LEGION_EXILE
        modeValue = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.OrcMalacathConduct")
    RecordOrcLifeModeSignal(modeValue, multiplier, reason)
    AwardOrcBroadConductSignal(multiplier)
    StorageUtil.AdjustFloatValue(None, "PDV.Orc.MalacathConduct", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Orc.MalacathSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastMalacathSourceReason", reason)
    Manager.SurfaceP2BookReadNotice(reason, "The Code of Malacath", "Malacath weighs your conduct against it.")
    Manager.Trace(2, "Orc Malacath conduct routed with multiplier " + multiplier)
EndFunction

Function HandleOrcOathBreak(String reason)
    if !IsOrcOrigin()
        return
    endIf

    AwardOrcOathBreakSignal()
    StorageUtil.AdjustIntValue(None, "PDV.Orc.OathBreakCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Orc.LastOathBreakReason", reason)
    Manager.Trace(2, "Orc oath-break routed: " + reason)
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
    if !Manager.PDV_OrcLifeModeTrack || !IsOrcOrigin()
        return
    endIf

    EnsureOrcLifeModeInitialized()
    Int currentMode = Manager.PDV_OrcLifeModeTrack.GetCurrentState()

    if !Manager.PDV_OrcLifeModeTrack.IsTransitionLockedOut()
        Int bestMode = -1
        Float bestWeight = -1.0
        Int candidate = Manager.ORC_LIFE_MODE_CITY
        while candidate <= Manager.ORC_LIFE_MODE_LEGION_EXILE
            if candidate != currentMode && Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(candidate, 2, 7)
                Float candidateWeight = StorageUtil.GetFloatValue(None, GetOrcLifeModeWeightKey(candidate))
                if bestMode < 0 || candidateWeight > bestWeight
                    bestMode = candidate
                    bestWeight = candidateWeight
                endIf
            endIf
            candidate += 1
        endWhile

        if bestMode >= 0
            ApplyOrcLifeModeSwitch(bestMode, "orc_dawn_softswitch")
            return
        endIf
    endIf

    if currentMode > Manager.ORC_LIFE_MODE_CITY && !Manager.PDV_OrcLifeModeTrack.HasRecentEvidenceDays(currentMode, 1, 14)
        ApplyOrcLifeModeSwitch(Manager.ORC_LIFE_MODE_CITY, "orc_dawn_lapse_to_city")
        Manager.RequestPanelRefresh()
    endIf
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
    if modeLabel == "Concordat Enforcer"
        return "Under the White-Gold Concordat, you are a Concordat Enforcer."
    endIf

    return "Under the White-Gold Concordat, you are " + modeLabel + "."
EndFunction

Bool Function IsImperialVampireStateActive()
    return StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
EndFunction

Function SyncOrcRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isOrc = GetPlayerOriginRaceIndex() == Manager.ORIGIN_ORC
    Int activeMode = GetActiveOrcRewardMode()
    SyncOrcSpineBoon(playerRef, isOrc, activeMode)

    Bool broadFaithful = isOrc && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Malacath_T2, broadFaithful, "Orc Malacath T2")

    Bool focusActive = isOrc && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == Manager.PDV_Malacath && Manager.PDV_Malacath
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if focusActive
        activeTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Malacath)
    endIf

    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_STRONGHOLD, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_Stronghold_T1, Manager.PDV_Bless_Orc_Stronghold_T2, Manager.PDV_Bless_Orc_Stronghold_T3, "Stronghold")
    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_CITY, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_City_T1, Manager.PDV_Bless_Orc_City_T2, Manager.PDV_Bless_Orc_City_T3, "City")
    SyncOrcRewardFamily(playerRef, Manager.ORC_LIFE_MODE_LEGION_EXILE, activeMode, activeTier, focusActive, Manager.PDV_Bless_Orc_LegionExile_T1, Manager.PDV_Bless_Orc_LegionExile_T2, Manager.PDV_Bless_Orc_LegionExile_T3, "LegionExile")
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

Bool Function IsOrcCodeNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_ORC
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure") == 1
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Orc.LastLifeModeSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncOrcNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Orc
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Orc)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Orc, False)
            MaybeShowOrcHearthHeldMissedCadenceNotice()
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Orc)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Orc)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.OrcSpellActive", 0)
    endIf
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

Function SyncImperialRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isImperial = GetPlayerOriginRaceIndex() == Manager.ORIGIN_IMPERIAL
    SyncImperialAncestorSubstrate(playerRef, isImperial)
    ; The Divine reward SPELs below are REUSED by the Nord baseline lanes
    ; (SyncNordRewardFamily: Mara/Arkay/Dibella + the whole Nine Divines set, owner ruling
    ; 2026-06-27). SyncNordRewards runs BEFORE this in SyncFirstTierRaceRewardRuntime and
    ; grants the Nord patron's spell; running the Imperial family here on a non-Imperial save
    ; (isActive is false because origin != Imperial) would REMOVE that just-granted spell in
    ; the same pass -- which is why Nord reused-spell rewards never reached Active Effects.
    ; Only the player's own race lane should manage these records; skip entirely when not
    ; Imperial. SyncNordRewards runs unconditionally and already owns both grant and cleanup
    ; for these spells on every non-Imperial save (Civic_T2 above is Imperial-only, so it
    ; stays before this guard to keep self-clearing).
    if !isImperial
        return
    endIf

    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Akatosh, Manager.PDV_Bless_Imperial_Akatosh_T1, Manager.PDV_Bless_Imperial_Akatosh_T2, Manager.PDV_Bless_Imperial_Akatosh_T3, "Akatosh")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Mara, Manager.PDV_Bless_Imperial_Mara_T1, Manager.PDV_Bless_Imperial_Mara_T2, Manager.PDV_Bless_Imperial_Mara_T3, "Mara")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Arkay, Manager.PDV_Bless_Imperial_Arkay_T1, Manager.PDV_Bless_Imperial_Arkay_T2, Manager.PDV_Bless_Imperial_Arkay_T3, "Arkay")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Stendarr, Manager.PDV_Bless_Imperial_Stendarr_T1, Manager.PDV_Bless_Imperial_Stendarr_T2, Manager.PDV_Bless_Imperial_Stendarr_T3, "Stendarr")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Zenithar, Manager.PDV_Bless_Imperial_Zenithar_T1, Manager.PDV_Bless_Imperial_Zenithar_T2, Manager.PDV_Bless_Imperial_Zenithar_T3, "Zenithar")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Dibella, Manager.PDV_Bless_Imperial_Dibella_T1, Manager.PDV_Bless_Imperial_Dibella_T2, Manager.PDV_Bless_Imperial_Dibella_T3, "Dibella")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Julianos, Manager.PDV_Bless_Imperial_Julianos_T1, Manager.PDV_Bless_Imperial_Julianos_T2, Manager.PDV_Bless_Imperial_Julianos_T3, "Julianos")
    SyncImperialRewardFamily(playerRef, Manager.LedgerRuntime.PDV_Kynareth, Manager.PDV_Bless_Imperial_Kynareth_T1, Manager.PDV_Bless_Imperial_Kynareth_T2, Manager.PDV_Bless_Imperial_Kynareth_T3, "Kynareth")
    SyncImperialRewardFamily(playerRef, Manager.PDV_Talos, Manager.PDV_Bless_Imperial_Talos_T1, Manager.PDV_Bless_Imperial_Talos_T2, Manager.PDV_Bless_Imperial_Talos_T3, "Talos")
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

Bool Function IsImperialCivicNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        return False
    endIf

    if !Manager.PDV_ImperialAncestorSubstrate || Manager.PDV_ImperialAncestorSubstrate.GetMetric() <= 0.0
        return False
    endIf

    Float lastSource = Manager.PDV_ImperialAncestorSubstrate.GetLastAcceptedTime()
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 3.0
EndFunction

Function SyncImperialNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Imperial
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 0)
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Imperial)
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Imperial, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Imperial)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Imperial)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.ImperialSpellActive", 0)
    endIf
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

Function ApplyImperialConcordatAction(String actionKey, String reason)
    Int adjustment = GetImperialConcordatPressureForAction(actionKey)
    if adjustment == 0
        Manager.Trace(1, "ApplyImperialConcordatAction skipped: unknown action " + actionKey)
        return
    endIf

    ApplyConcordatPressure(adjustment, reason)
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
    if deity == Manager.LedgerRuntime.PDV_Akatosh
        return Manager.PDV_Msg_Imperial_Akatosh_Offer
    elseIf deity == Manager.PDV_Talos && IsImperialTalosOfferAllowed()
        return Manager.PDV_Msg_Imperial_Talos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return Manager.PDV_Msg_Imperial_Kynareth_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return Manager.PDV_Msg_Imperial_Mara_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return Manager.PDV_Msg_Imperial_Zenithar_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return Manager.PDV_Msg_Imperial_Arkay_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Stendarr
        return Manager.PDV_Msg_Imperial_Stendarr_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return Manager.PDV_Msg_Imperial_Julianos_Offer
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return Manager.PDV_Msg_Imperial_Dibella_Offer
    endIf

    return None
EndFunction

Bool Function IsImperialOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        return False
    endIf

    if deity == Manager.PDV_Talos
        return IsImperialTalosOfferAllowed()
    endIf

    return deity == Manager.LedgerRuntime.PDV_Akatosh || deity == Manager.LedgerRuntime.PDV_Mara || deity == Manager.LedgerRuntime.PDV_Arkay || deity == Manager.LedgerRuntime.PDV_Stendarr || deity == Manager.LedgerRuntime.PDV_Zenithar || deity == Manager.LedgerRuntime.PDV_Dibella || deity == Manager.LedgerRuntime.PDV_Julianos || deity == Manager.LedgerRuntime.PDV_Kynareth
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
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 1)
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHistory", 1)
        if Manager.PDV_ImperialAncestorSubstrate
            Manager.PDV_ImperialAncestorSubstrate.SetMetric(0.0, "vampire_onset")
            Manager.PDV_ImperialAncestorSubstrate.ClearSubstrateBoons()
        endIf
        StorageUtil.SetFloatValue(None, Manager.LedgerRuntime.GetBroadPantheonScratchKey(Manager.LedgerRuntime.BROAD_PANTHEON_IMPERIAL), 0.0)
        Manager.FavorRuntime.ClearActiveFavor("imperial_vampire")
    elseIf newState == 1
        ; Werewolf strains but does not halt the civic path the way undeath does.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    elseIf oldState == 2 && newState == 0
        ; Cured: the halt lifts, but VampireHistory stays set as the scar.
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
        if Manager.PDV_ImperialAncestorSubstrate
            Manager.PDV_ImperialAncestorSubstrate.SetMetric(20.0, "vampire_cure_seed")
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.VampireHalt", 0)
    endIf
    Manager.LedgerRuntime.SyncBroadPantheonRewards(Game.GetPlayer())
    SyncImperialRewards(Game.GetPlayer())
EndFunction

Function ApplyOrcCurseHandlers(Int oldState, Int newState, String reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.VampireScar", 1)
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 1)
        if !Manager.GetSuppressCurseTransitionOutputs()
            EmitMalacathCurseCodeRuptureMinus("werewolf_onset_" + reason)
        endIf
    elseIf oldState != 0
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Orc.CodePressure", 0)
    endIf
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
    Manager.BeginRaceSetupQuietPresentation(reason)
    if Manager.PDV_OrcLifeModeTrack
        Manager.PDV_OrcLifeModeTrack.SetState(PDV_DevotionRules.ClampInt(modeValue, Manager.ORC_LIFE_MODE_CITY, Manager.ORC_LIFE_MODE_LEGION_EXILE), reason)
        Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(GetOrcLifeModeLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "malacath", True, 3, "", True)
    endIf
    ; Malacath is the single innate Orc spine (not chosen, not offered) -- activate him as the
    ; patron at origin so the life-mode reward ladder (gated on _activeDeity==PDV_Malacath) is
    ; reachable in normal play; without this the whole Malacath progression was a dead no-op.
    ; Owner ruling 2026-06-27.
    if Manager.PDV_Malacath
        Manager.LedgerRuntime.SetActiveDeity(Manager.PDV_Malacath)
    endIf
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
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
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL || multiplier <= 0.0 || IsImperialVampireStateActive()
        return
    endIf

    Int tierBefore = 0
    if Manager.PDV_ImperialAncestorSubstrate
        Float metricBefore = Manager.PDV_ImperialAncestorSubstrate.GetMetric()
        tierBefore = Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        Manager.PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(multiplier, reason)
        Int tierAfter = Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier()
        Manager.SendPrismaSubstrateProgress("imperial-civic", tierBefore, tierAfter, Manager.PDV_ImperialAncestorSubstrate.GetMetric() - metricBefore, "Your public service steadies your devotion.", "journal", GetImperialCivicTierName())
    endIf

    StorageUtil.AdjustFloatValue(None, "PDV.Imperial.AncestralStanding", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Imperial.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastAncestorSpineReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Imperial.LastAncestorSpineTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Imperial ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RunDawnRefreshImperialAncestor()
    if !Manager.PDV_ImperialAncestorSubstrate
        return
    endIf

    Manager.PDV_ImperialAncestorSubstrate.ProcessCivicDawn(IsImperialVampireStateActive(), "dawn")
EndFunction

Function HandleImperialCivicService(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        Manager.Trace(2, "Imperial civic service ignored for non-Imperial origin.")
        return
    endIf
    if IsImperialVampireStateActive()
        Manager.Trace(2, "Imperial civic service blocked by vampirism: " + reason)
        return
    endIf

    Int civicFamily = GetImperialCivicFamilyFromSource(reason)
    if civicFamily == Manager.IMPERIAL_CIVIC_UNKNOWN
        Manager.Trace(1, "Imperial civic service ignored: missing civic family token in " + reason)
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ImperialCivicService." + GetImperialCivicFamilyLabel(civicFamily))
    if multiplier <= 0.0
        return
    endIf

    ; Legacy CivicServiceCount is frozen after broad-pool migration.
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicServiceReason", reason)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastCivicFamily", GetImperialCivicFamilyLabel(civicFamily))
    StorageUtil.SetFloatValue(None, "PDV.Imperial.LastCivicServiceTime", Utility.GetCurrentGameTime())
    AwardImperialCivicFamilySignal(civicFamily, multiplier)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    Manager.Trace(2, "Imperial civic service routed: " + reason + " family " + GetImperialCivicFamilyLabel(civicFamily))
EndFunction

Function HandleImperialTalosPressure(Bool isPrivate, String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        Manager.Trace(2, "Imperial Talos pressure ignored for non-Imperial origin.")
        return
    endIf
    if IsImperialVampireStateActive()
        Manager.Trace(2, "Imperial Talos pressure blocked by vampirism: " + reason)
        return
    endIf

    String repeatKey = "PDV.Signal.ImperialPublicTalosPressure"
    if isPrivate
        repeatKey = "PDV.Signal.ImperialPrivateTalosPressure"
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier(repeatKey)
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.TalosBroadUnlocked", 1)

    if isPrivate
        StorageUtil.SetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") + 1)
        if Manager.PDV_Talos
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_SHRINE_DEFIANCE, None, multiplier)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Imperial.PublicTalosPressureCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") + 1)
        if Manager.PDV_Talos
            Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Talos, Manager.PDV_Talos.SIGNAL_DEFIANCE_MILESTONE, None, multiplier)
        endIf
    endIf

    StorageUtil.SetStringValue(None, "PDV.Imperial.LastTalosPressureReason", reason)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    Manager.SurfaceP2BookReadNotice(reason, "The name of Talos", "The question of the Ninth presses harder.")
    Manager.Trace(2, "Imperial Talos pressure routed: " + reason)
EndFunction

Function HandleImperialPatronCivicFavor(String reason)
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_IMPERIAL
        Manager.Trace(2, "Imperial patron civic favor ignored for non-Imperial origin.")
        return
    endIf
    if IsImperialVampireStateActive()
        Manager.Trace(2, "Imperial patron civic favor blocked by vampirism: " + reason)
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.ImperialPatronCivicFavor")
    if multiplier <= 0.0
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Imperial.PatronCivicFavorCount", StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") + 1)
    StorageUtil.SetStringValue(None, "PDV.Imperial.LastPatronCivicFavorReason", reason)
    AwardImperialPatronCivicSignal(multiplier)
    AwardImperialAncestorSpinePulse(multiplier, reason)
    Manager.Trace(2, "Imperial patron civic favor routed: " + reason)
EndFunction

String Function GetImperialMedallionEntriesJson()
    String entries = Manager.RosterMedallionEntry("kynareth", "Kynareth", "god", "kynareth", Manager.LedgerRuntime.PDV_Kynareth, "Road, wind, and natural order.")
    entries = entries + "," + Manager.RosterMedallionEntry("mara", "Mara", "god", "mara", Manager.LedgerRuntime.PDV_Mara, "Love, family, and mercy.")
    entries = entries + "," + Manager.RosterMedallionEntry("akatosh", "Akatosh", "god", "akatosh", Manager.LedgerRuntime.PDV_Akatosh, "Time, covenant, and empire.")
    entries = entries + "," + Manager.RosterMedallionEntry("arkay", "Arkay", "god", "arkay", Manager.LedgerRuntime.PDV_Arkay, "Life, death, and lawful burial.")
    entries = entries + "," + Manager.RosterMedallionEntry("stendarr", "Stendarr", "god", "stendarr", Manager.LedgerRuntime.PDV_Stendarr, "Mercy, protection, and civic virtue.")
    entries = entries + "," + Manager.RosterMedallionEntry("julianos", "Julianos", "god", "julianos", Manager.LedgerRuntime.PDV_Julianos, "Law, learning, and reason.")
    entries = entries + "," + Manager.RosterMedallionEntry("dibella", "Dibella", "god", "dibella", Manager.LedgerRuntime.PDV_Dibella, "Art, beauty, and human grace.")
    entries = entries + "," + Manager.RosterMedallionEntry("zenithar", "Zenithar", "god", "zenithar", Manager.LedgerRuntime.PDV_Zenithar, "Work, trade, and prosperity.")
    return entries
EndFunction

String Function GetOrcMedallionEntriesJson()
    return Manager.RosterMedallionEntry("malacath", "Malacath", "prince", "malacath", Manager.PDV_Malacath, "Oath, code, exile, and vengeance.")
EndFunction

String Function GetOrcSurveyText()
    if !Manager.PDV_OrcLifeModeTrack
        return "Malacath watches, but the shape of your life has not settled yet. Carry the code a while, then survey again."
    endIf

    EnsureOrcLifeModeInitialized()
    String band = Manager.GetCurrentStandingBand()
    Int mode = Manager.PDV_OrcLifeModeTrack.GetCurrentState()
    String text = ""
    if mode == Manager.ORC_LIFE_MODE_STRONGHOLD
        text = "You carry Malacath's code inside the stronghold, where forge, kin, and oath hold it with you. Standing: " + band + "."
    elseIf mode == Manager.ORC_LIFE_MODE_LEGION_EXILE
        text = "You carry Malacath's code under foreign discipline. The contract is the oath; the endurance is the strength. Standing: " + band + "."
    else
        text = "You carry Malacath's code in the city, alone, with no stronghold to confirm it. Standing: " + band + ". Malacath watches what no one else does."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Orc.MalacathSourceCount") > 0
        text = text + " You have sought out the old tellings of Malacath, and kept them."
    endIf
    Int cursePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Orc.CodePressure")
    if cursePressure == 2
        text = text + " The thirst sets you outside the test until it is cured."
    elseIf cursePressure == 1
        text = text + " The beast in you is being weighed against the code, not turned away from."
    endIf

    return text
EndFunction

String Function GetImperialSurveyText()
    String band = Manager.GetCurrentStandingBand()
    String concordat = GetImperialConcordatLabel()
    String text = ""
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity()
        text = Manager.GetPublicDeityDisplayName(Manager.GetActiveDeity()) + " holds your focus among the Nine. Standing: " + band + ". " + BuildImperialConcordatSurveySentence(concordat)
        if IsFocusedPantheonBoonSuspended()
            text = text + " The commitment remains, but its boon is suspended until 50 piety."
        endIf
    else
        text = "You worship the Nine Divines broadly, and your standing is " + band + ". " + BuildImperialConcordatSurveySentence(concordat)
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PrivateTalosPressureCount") > 0
        text = text + " You have kept Talos at hidden shrines, away from watching eyes."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PublicTalosPressureCount") > 0
        text = text + " You have honored Talos in the open, where the Concordat forbids it."
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Imperial.PatronCivicFavorCount") > 0
        text = text + " Your patron has taken note of the civic good you have done in their name."
    endIf
    if Manager.PDV_ImperialAncestorSubstrate
        text = text + " Civic practice: " + GetImperialCivicTierName() + "."
    endIf

    if Manager.PDV_ConcordatStandingTrack && Manager.PDV_ConcordatStandingTrack.HasExtremeResetGate()
        text = text + " You have drifted far enough on the Talos question that a deliberate change of course could now bring you back."
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1 || (Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2)
        text = text + " Curse posture: the civic faith is halted while the undeath holds."
    elseIf Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 1
        text = text + " Curse posture: the civic faith runs strained while the beast is in you."
    elseIf StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHistory") == 1
        text = text + " Curse posture: the civic faith is whole again, but the community religion remembers the absence."
    endIf

    return text
EndFunction

String Function GetImperialConcordatLabel()
    if Manager.PDV_ConcordatStandingTrack
        return FormatImperialConcordatLabel(Manager.PDV_ConcordatStandingTrack.GetStateLabel())
    endIf

    return "Uncommitted"
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

String Function GetImperialCivicLayerLabel()
    if !Manager.PDV_ImperialAncestorSubstrate
        return "quiet"
    endIf

    return Manager.PDV_ImperialAncestorSubstrate.GetCivicPostureLabel()
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

String Function GetImperialCursePostureLabel()
    if StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHalt") == 1
        return "civic faith halted"
    elseIf Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2
        return "civic faith halted"
    elseIf Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 1
        return "civic faith strained"
    elseIf StorageUtil.GetIntValue(None, "PDV.Imperial.VampireHistory") == 1
        return "civic faith scarred"
    endIf

    return ""
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
    if !Manager.PDV_Talos || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Talos)
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
    Manager.ResetQuestReactionSurface()
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
    Manager.FlushQuestReactionSurface()
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
    Manager.ResetQuestReactionSurface()
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
    Manager.FlushQuestReactionSurface()
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

    Manager.ResetQuestReactionSurface()
    ApplyUndeadCryptClearReaction("Arkay", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Meridia", "C", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Stendarr", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Tu'whacca", "S", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Azura", "m", clearedLocation, repeatMultiplier)
    ApplyUndeadCryptClearReaction("Y'ffre", "m", clearedLocation, repeatMultiplier)
    Manager.FlushQuestReactionSurface()
EndFunction

Function ApplyUndeadCryptClearReaction(String deityName, String intensity, Location clearedLocation, Float repeatMultiplier)
    PDV_DeityBase deity = Manager.GetQuestReactionDeity(deityName)
    if !deity
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear skipped unknown deity: " + deityName)
        endIf
        return
    endIf

    Float amount = Manager.GetQuestReactionBaseValue("small", intensity) * repeatMultiplier
    if amount == 0.0
        return
    endIf

    String sourceTag = "undead_crypt_clear"
    String stance = Manager.GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastCurse", deityName + "." + sourceTag)
        if Manager.GetQrQueueTransactionActive()
            Manager.SetQrQueueNeedsCurseRefresh(True)
        else
            Manager.LedgerRuntime.HandleCurseStateRefresh("quest_reaction_" + deityName)
        endIf
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] UndeadCryptClear curse routed: " + deityName)
        endIf
        return
    endIf

    if stance == "TABOO" || stance == "HOSTILE"
        Manager.ApplyQuestReactionStigma(deity, amount, sourceTag)
        if !(deity as PDV_DaedricPathBase)
            Manager.AccumulateQuestReactionSurface(deity, amount * -1.0, "small")
        endIf
        return
    endIf

    if stance == "FOREIGN" || stance == "TOLERATED"
        if !Manager.IsQuestReactionDeityReachable(deity)
            if Manager.GetDebugLevel() >= 2
                Debug.Trace("[PDV] UndeadCryptClear skipped unreachable foreign deity: " + deityName)
            endIf
            return
        endIf
    endIf

    Float stanceMultiplier = Manager.GetQuestReactionStanceMultiplier(stance)

    Float appliedReactionAmount = amount * stanceMultiplier
    Manager.SetSuppressAwardFavorToast(True)
    Manager.ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    Manager.SetSuppressAwardFavorToast(False)
    Manager.AccumulateQuestReactionSurface(deity, appliedReactionAmount, "small")

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
