Scriptname PDV_OriginRuntime_Breton extends PDV_OriginRuntimeBase

; ORIGIN adapter -- Breton lane (tradition: Knight's Road / Hidden Art / Green Way,
; practice tier + count, druidic fork, witchcraft exposure, ancestor spine).
; Cut from PDV_OriginRuntimeBase tranche 3 per PDV_2_0_ADR_OriginAdapterInterface.
;
; Section 1 below is the lane's 68 functions, copied BYTE-IDENTICAL from the base so
; the split stays provable against origin_golden.json. Section 2 is the new dispatch
; layer: thin overrides of the base virtuals that delegate to those bodies.
;
; The originals still stand in PDV_OriginRuntimeBase; a same-signature child function
; is simply an override, so this compiles. A central pass removes them from the base
; using PDV_2_0_AdapterManifest_t3.json.
;
; Script variables: this lane reads and writes NONE. Every shared manager script var
; the bodies touch already routes through a Manager accessor (see the tranche-3 header
; comment in the base), so nothing had to move and nothing needs a new base accessor.
;
; TODO (pending arrival, do not add by hand): the Breton-gated branch of
; GetDaedricStigmaGainMultiplier and its helper IsBretonHiddenArtDaedricOfferDeity
; are scheduled to move into THIS adapter from PDV_DaedricRuntime. They are
; deliberately NOT moved yet. IsBretonOfferEligibleDeity below still calls
; Manager.DaedricRuntime.IsBretonHiddenArtDaedricOfferDeity(deity); that call becomes
; a bare local call when the move lands.

; ===========================================================================
; SECTION 1 -- lane functions, copied verbatim from PDV_OriginRuntimeBase
; ===========================================================================

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

; ===========================================================================
; SECTION 2 -- adapter dispatch. New code; every body above is untouched.
;
; NOTE (interface gap, reported with this tranche): the frozen
; HandleContextualSignal signature carries no String reason slot, but every
; Breton Handle* body takes one and the live callers compose it dynamically
; ("eventbus_" + eventType + "_" + sourceId). Until the ADR adds
; String reason = "", this layer synthesizes "signal_" + signalId. That is a
; provenance-string change only -- no dedupe key or gate reads it -- but it is a
; real diff and must not be mistaken for a verbatim move.
; ===========================================================================

; -- State --

String Function GetOriginStateLabel()
    return GetBretonTraditionLabel()
EndFunction

Int Function GetOriginStateValue()
    return GetBretonTraditionValue()
EndFunction

String Function GetOriginSummary()
    return GetBretonAncestorSummary()
EndFunction

String Function GetSurveyFragment()
    return GetBretonSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsBretonTraditionNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "tradition"
        return GetBretonTraditionLabel()
    elseIf detailKey == "bod-path-status"
        return GetBretonBookOfDaysPathStatusLabel()
    elseIf detailKey == "knightly-vow"
        return GetBretonKnightlyVowLabel()
    elseIf detailKey == "witchcraft-exposure"
        return GetBretonWitchcraftExposureLabel()
    elseIf detailKey == "druidic-standing"
        return GetBretonDruidicStandingLabel()
    elseIf detailKey == "druidic-fork"
        return GetBretonDruidicForkLabel()
    elseIf detailKey == "ancestor-layer"
        return GetBretonAncestorLayerLabel()
    elseIf detailKey == "curse-posture"
        return GetBretonCursePostureLabel()
    elseIf detailKey == "ancestor-summary"
        return GetBretonAncestorSummary()
    elseIf detailKey == "medallion-json"
        return GetBretonMedallionEntriesJson()
    elseIf detailKey == "patron-survey-sentence"
        return GetBretonPatronSurveySentence(GetBretonTraditionValue())
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "tradition"
        return GetBretonTraditionValue()
    elseIf detailKey == "tradition-tier"
        return GetBretonTraditionTier(GetBretonTraditionValue())
    elseIf detailKey == "practice-tier"
        return GetBretonPracticeTier(GetBretonTraditionValue())
    elseIf detailKey == "practice-count"
        return GetBretonPracticeCount(GetBretonTraditionValue())
    elseIf detailKey == "druidic-fork"
        return GetBretonDruidicForkValue()
    elseIf detailKey == "green-way-fork-eligible"
        if IsBretonGreenWayForkEligible()
            return 1
        endIf
        return 0
    elseIf detailKey == "tradition-neglected"
        if IsBretonTraditionNeglected()
            return 1
        endIf
        return 0
    elseIf detailKey == "resonant-patron-champion"
        if IsBretonResonantPatronChampion(GetBretonTraditionValue())
            return 1
        endIf
        return 0
    endIf

    return 0
EndFunction

; -- Signals --

Bool Function HandleContextualSignal(String signalId, Form contextForm = None, Float magnitude = 0.0)
    String reason = "signal_" + signalId

    if signalId == "knightly-vow"
        HandleBretonKnightlyVow(reason)
        return True
    elseIf signalId == "hidden-art-exposure"
        HandleBretonHiddenArtExposure(reason)
        return True
    elseIf signalId == "green-way-standing"
        HandleBretonGreenWayStanding(reason)
        return True
    elseIf signalId == "action-practice"
        HandleBretonActionPracticeSignal(magnitude as Int, reason)
        return True
    elseIf signalId == "tradition-choice"
        HandleBretonTraditionChoice(magnitude as Int, reason)
        return True
    elseIf signalId == "druidic-fork"
        SetBretonDruidicFork(magnitude as Int, reason)
        return True
    elseIf signalId == "ancestor-spine-pulse"
        AwardBretonAncestorSpinePulse(magnitude, reason)
        return True
    elseIf signalId == "sleep"
        HandleBretonSleepEvents(contextForm as Actor, reason)
        return True
    endIf

    return False
EndFunction

; -- Upkeep --

Function SyncRaceRewards()
    SyncBretonRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncBretonNeglectSpell(IsBretonTraditionNeglected())
EndFunction

Function EvaluateAtDawn()
    RunDawnRefreshBretonAncestor()
    DecayBretonWitchcraftExposureAtDawn()
    DecayBretonDruidicStandingAtDawn()
EndFunction

; -- Patron and offers --

Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return IsBretonOfferEligibleDeity(deity)
EndFunction
