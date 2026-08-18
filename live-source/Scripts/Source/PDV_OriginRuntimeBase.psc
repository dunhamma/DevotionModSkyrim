Scriptname PDV_OriginRuntimeBase extends Quest

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
    if !playerRef || Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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
    if !playerRef || !Manager.PDV_MESG_BosmerNaming || Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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
    Bool eligible = (Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER) && IsBosmerNamingCoherent(pathAtRite)
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
    if !loc || Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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

    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || StorageUtil.GetIntValue(None, "PDV.Yffre.Seen.allmaker_tree") == 1
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
    if !playerRef || Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || !Manager.PDV_SPEL_BosmerScalesAtRest
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
    if !playerRef || Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER || !Manager.PDV_SPEL_BosmerBaanDarGap
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
    return Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER || Manager.LedgerRuntime.GetPatronState() != Manager.LedgerRuntime.PATRON_STATE_ACTIVE
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER || !Manager.PDV_MISC_AltmerPracticeFocus
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
    if !Manager.IsSyrabaneSignalEligible()
        return
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.SyrabaneCureWard")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_CURSE_DISEASE_WARDING, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "The sickness lifts", "marks a curse turned aside before it took root.")
EndFunction

Function HandleAltmerSyrabaneProtectiveWard(String reason)
    if !Manager.IsSyrabaneSignalEligible()
        return
    endIf
    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.SyrabaneProtectiveWarding")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_PROTECTIVE_WARDING, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "The ward holds", "marks hostile magic stopped before it reached you.")
EndFunction

Function HandleAltmerSyrabaneAntiMageSurvival(String reason)
    if !Manager.IsSyrabaneSignalEligible()
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Syrabane, Manager.PDV_Syrabane.SIGNAL_ANTI_MAGE_SURVIVAL, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Syrabane, "Arcane duel survived", "marks a hostile mage outlasted and put down.")
EndFunction

Function HandleAltmerSyrabaneContainment(String reason)
    if !Manager.IsSyrabaneSignalEligible()
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

    Bool isAltmer = Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER
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
    Bool isActive = Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
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

    Bool isBosmer = Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER
    Int pathState = GetBosmerPathState()
    Bool broadFaithful = isBosmer && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && GetBosmerFavorSignalCount() >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Bosmer_Yffre_T2, broadFaithful, "Bosmer Yffre T2")

    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_OLD_CONTRACT, pathState, Manager.PDV_Yffre, Manager.PDV_Bless_Bosmer_OldContract_T1, Manager.PDV_Bless_Bosmer_OldContract_T2, Manager.PDV_Bless_Bosmer_OldContract_T3, "OldContract")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_LIVING_STORY, pathState, Manager.PDV_Yffre, Manager.PDV_Bless_Bosmer_LivingStory_T1, Manager.PDV_Bless_Bosmer_LivingStory_T2, Manager.PDV_Bless_Bosmer_LivingStory_T3, "LivingStory")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_EXCHANGE, pathState, Manager.LedgerRuntime.PDV_Zen, Manager.PDV_Bless_Bosmer_Exchange_T1, Manager.PDV_Bless_Bosmer_Exchange_T2, Manager.PDV_Bless_Bosmer_Exchange_T3, "Exchange")
    SyncBosmerPathRewardFamily(playerRef, Manager.BOSMER_PATH_BANDIT_ROAD, pathState, Manager.PDV_BaanDar, Manager.PDV_Bless_Bosmer_BanditRoad_T1, Manager.PDV_Bless_Bosmer_BanditRoad_T2, Manager.PDV_Bless_Bosmer_BanditRoad_T3, "BanditRoad")
EndFunction

Function SyncBosmerPathRewardFamily(Actor playerRef, Int thisPath, Int activePath, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER && thisPath == activePath
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_BOSMER
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

    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
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
    return Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BOSMER
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
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 2
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileActive") == 1
EndFunction

Bool Function IsAltmerWerewolfHalted()
    if Manager.GetPlayerOriginRaceIndex() != Manager.ORIGIN_ALTMER
        return False
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.GetCurseState() == 1
        return True
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Altmer.WerewolfHalt") == 1
EndFunction

Bool Function HasAltmerVampireExileScar()
    return Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ALTMER && StorageUtil.GetIntValue(None, "PDV.Altmer.VampireExileScar") == 1
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
