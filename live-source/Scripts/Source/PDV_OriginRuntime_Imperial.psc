Scriptname PDV_OriginRuntime_Imperial extends PDV_OriginRuntimeBase

; ORIGIN adapter -- Imperial lane (tranche t5). Per
; references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md: the base declares 21
; virtuals with inert defaults; this adapter overrides only what the Imperial
; lane implements and delegates each override to the existing named Imperial
; function, whose body is copied here VERBATIM so the split stays provable
; against origin_golden.json.
;
; Lane scope: the White-Gold Concordat, civic service, patron civic favor, sleep
; events, Talos pressure, the Imperial vampire halt.
;
; Script variables: the Imperial lane bodies reference NO bare script variable,
; so nothing had to move and nothing is shared. (Papyrus children cannot reach a
; parent's script variables -- only Properties -- so this was checked per
; function, not per file.) The Manager backref is a Property on the base and is
; therefore reachable from here unchanged.
;
; Originals remain in PDV_OriginRuntimeBase for now; a same-signature child
; function is simply an override, so the duplication compiles and is removed by
; the central pass that consumes PDV_2_0_AdapterManifest_t5.json.
;
; INERT until the host QUST exists, Manager is filled, and the manager selects
; this adapter by birth race.

; ============================================================================
; Imperial lane functions -- copied VERBATIM from PDV_OriginRuntimeBase
; (source ranges 9520-9523, 10097-10107, 10235-10460, 10527-10738,
;  10774-10892).
; ============================================================================

Function HandleImperialSleepEvents(Actor playerRef, String reason)
    ; Retained for save/script compatibility. Imperial sleep is not a civic or
    ; pantheon signal under the pacing contract.
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


; ============================================================================
; Base virtual overrides (ADR interface). Each is a thin delegation to the
; verbatim lane function above -- the hand-reviewable dispatch layer the ADR
; calls out as the one part parity cannot cover.
;
; NOT overridden here, deliberately, because the Imperial lane has no matching
; function to delegate to (checked by name against PDV_OriginRuntimeBase, not
; assumed): ApplyInitialChoice -- the Imperial race is absent from
; PDV__ManagerQuest.ApplyStartupChoice and there is no ApplyImperialInitialChoice;
; EnsureRuntimeWiring -- no Imperial init entry point; HandleLocationChange -- no
; HandleImperialLocationChange; ShowOriginNotification / ShowOriginMessage -- no
; ShowImperial* notifier (the lane surfaces through Manager.SendPrismaToast and
; Manager.SurfaceP2BookReadNotice directly). See the manifest.
; ============================================================================

; -- Lifecycle --
Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyImperialCurseHandlers(oldState, newState, reason)
EndFunction

Function EvaluateAtDawn()
    RunDawnRefreshImperialAncestor()
EndFunction

; -- State --
String Function GetOriginStateLabel()
    return GetImperialConcordatLabel()
EndFunction

Int Function GetOriginStateValue()
    if !Manager.PDV_ConcordatStandingTrack
        return 0
    endIf

    return Manager.PDV_ConcordatStandingTrack.GetValue()
EndFunction

String Function GetOriginSummary()
    return GetConcordatSummary()
EndFunction

String Function GetSurveyFragment()
    return GetImperialSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsImperialCivicNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "medallion-entries"
        return GetImperialMedallionEntriesJson()
    elseIf detailKey == "concordat"
        return GetImperialConcordatLabel()
    elseIf detailKey == "concordat-book-line"
        return BuildImperialConcordatBookLine(GetImperialConcordatLabel())
    elseIf detailKey == "civic-layer"
        return GetImperialCivicLayerLabel()
    elseIf detailKey == "civic-tier"
        return GetImperialCivicTierName()
    elseIf detailKey == "curse-posture"
        return GetImperialCursePostureLabel()
    elseIf detailKey == "broad-lane-name"
        return "The Divines' Regard"
    elseIf detailKey == "broad-lane-symbol"
        return "akatosh"
    elseIf detailKey == "medallion-sections"
        return MedallionSection("native", "Native worship", GetImperialMedallionEntriesJson())
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "concordat-standing"
        if Manager.PDV_ConcordatStandingTrack
            return Manager.PDV_ConcordatStandingTrack.GetValue()
        endIf
        return 0
    elseIf detailKey == "vampire-halt"
        if IsImperialVampireStateActive()
            return 1
        endIf
        return 0
    elseIf detailKey == "talos-offer-allowed"
        if IsImperialTalosOfferAllowed()
            return 1
        endIf
        return 0
    elseIf detailKey == "broad-lane-service-count"
        return Manager.LedgerRuntime.GetBroadPantheonStanding(Manager.LedgerRuntime.BROAD_PANTHEON_IMPERIAL) as Int
    endIf

    return 0
EndFunction

; -- Signals --
; `reason` is threaded through UNCHANGED. HandleImperialCivicService parses its
; reason for the civic-family token (GetImperialCivicFamilyFromSource) and
; returns early when none is present, so substituting the signalId here would
; not merely change stored text -- it would make every civic-service signal a
; no-op. The signalId selects the handler and nothing else.
Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "sleep"
        Actor sleepActor = contextForm as Actor
        if !sleepActor
            sleepActor = Game.GetPlayer()
        endIf
        HandleImperialSleepEvents(sleepActor, reason)
        return True
    elseIf signalId == "civic-service"
        HandleImperialCivicService(reason)
        return True
    elseIf signalId == "patron-civic-favor"
        HandleImperialPatronCivicFavor(reason)
        return True
    elseIf signalId == "talos-pressure-private"
        HandleImperialTalosPressure(True, reason)
        return True
    elseIf signalId == "talos-pressure-public"
        HandleImperialTalosPressure(False, reason)
        return True
    elseIf signalId == "concordat-pressure"
        ; base HandleTalosBetrayal / HandleTalosShrineDefiance adjusted Concordat standing
        ; directly; the adjustment rides the Float magnitude slot.
        ApplyConcordatPressure(magnitude as Int, reason)
        return True
    elseIf signalId == "hidden_talos_shrine" || signalId == "kill_thalmor_justiciar_unprovoked"
        ; The action key IS the signal id: the base names the act, the adapter owns what
        ; Imperials do about it.
        if signalId == "hidden_talos_shrine" && !IsImperialVampireStateActive()
            ; base HandleTalosShrineDefiance unlocked the Imperial broad Talos roster here,
            ; behind the same vampire gate. The curated Talos award itself is race-free and
            ; stays on the base.
            StorageUtil.SetIntValue(None, "PDV.Imperial.TalosBroadUnlocked", 1)
            Manager.Trace(1, "Imperial broad Talos roster unlocked by shrine defiance: " + reason)
        endIf
        ApplyImperialConcordatAction(signalId, reason)
        return True
    elseIf signalId == "substrate-action"
        ; base HandleSubstrateActionEvent, Imperial arm. eventType rides the Float slot.
        Int eventType = magnitude as Int
        if !IsImperialVampireStateActive() && Manager.PDV_ImperialAncestorSubstrate
            if eventType == 330 || eventType == 331 || eventType == 332
                Float metricBefore = Manager.PDV_ImperialAncestorSubstrate.GetMetric()
                Int tierBefore = Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier()
                Manager.PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(1.0, "craft_" + reason)
                Manager.SendPrismaSubstrateProgress("imperial-civic", tierBefore, Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier(), Manager.PDV_ImperialAncestorSubstrate.GetMetric() - metricBefore, "Completed craft strengthened civic practice.", "journal", GetImperialCivicTierName())
                return True
            endIf
        endIf
        return False
    endIf

    return False
EndFunction

; -- Value-returning sibling (21st virtual) --
; One real case in the Imperial lane: PDV_EventBus.RouteConcordatPressure reads
; the return of GetImperialConcordatPressureForAction("side_with_stormcloaks")
; and uses it as the adjustment magnitude, so it cannot ride HandleContextualSignal.
; Per the ADR's "signal ids drop the race prefix" rule, the concordat action key
; IS the query id. The lane function already returns 0 for an unknown key, which
; is exactly the base's inert default, so an unrecognised id stays inert.
Int Function HandleContextualQuery(String signalId, String reason = "", Form contextForm = None)
    return GetImperialConcordatPressureForAction(signalId)
EndFunction

; -- Upkeep --
Function SyncRaceRewards()
    SyncImperialRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncImperialNeglectSpell(IsImperialCivicNeglected())
EndFunction

; -- Patron and offers --
Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return IsImperialOfferEligibleDeity(deity)
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    return GetImperialFormalCommitmentOfferMessage(deity)
EndFunction

; -- Gain provider (ADR D1) --
; DELEGATING PLACEHOLDER. GetImperialCurseGainMultiplier still lives in
; PDV__ManagerQuest and is NOT moved by this tranche; this body changes when the
; provider seam lands and the function moves here. The Imperial race gate inside
; the manager function becomes redundant once this override is race-selected,
; but it is deliberately left in place for now.
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    ; Composes with Parent: the base owns the cross-race curse factor and dropping it here
    ; would silently lose it for this race.
    Float factor = Parent.GetProviderGainMultiplier(deity, phase)
    if phase == Manager.PHASE_AT_DAWN
        factor = factor * Manager.GetImperialCurseGainMultiplier(deity)
    endIf

    return factor
EndFunction
