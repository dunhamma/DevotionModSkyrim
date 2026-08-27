Scriptname PDV_PrismaPresenter extends Quest

; Deep presentation module. Owns bounded toast, panel, Book of Days, journal,
; medallion, Survey, and public-copy construction; PDV_PrismaBridge remains
; the native transport adapter.
PDV__ManagerQuest Property Manager Auto
Spell Property PDV_SPEL_SurveyDevotion Auto
Int Property AMBIENT_CHAMPION_CADENCE_DAYS = 4 AutoReadOnly
Bool Property AutoPushPrismaPanel = False Auto
Bool Property AllowPrismaBlockingSurfaces = False Auto
PDV_DiegeticDirector Property PDV_DiegeticDirectorService Auto

String Function BuildToastFallbackText(String titleText, String messageText)
    if titleText != "" && messageText != ""
        return titleText + ": " + messageText
    endIf
    if messageText != ""
        return messageText
    endIf
    return titleText
EndFunction

Function ShowToastFallbackNotification(String titleText, String messageText)
    String fallbackText = BuildToastFallbackText(titleText, messageText)
    if fallbackText != ""
        Debug.Notification(fallbackText)
    endIf
EndFunction

Bool Function PrismaToastLargeEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Prisma.ToastLarge", 0) == 1
EndFunction

Function SetPrismaToastLargeEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Prisma.ToastLarge", PDV_DevotionRules.BoolToInt(enabled))
EndFunction

String Function WithPrismaToastSize(String payload)
    if !PrismaToastLargeEnabled()
        return payload
    endIf
    String marker = "\"toast\":{"
    Int idx = StringUtil.Find(payload, marker)
    if idx < 0
        return payload
    endIf
    Int insertAt = idx + StringUtil.GetLength(marker)
    return StringUtil.Substring(payload, 0, insertAt) + "\"size\":\"large\"," + StringUtil.Substring(payload, insertAt)
EndFunction

Bool Function SendPrismaToastPayloadOrFallback(String payload, String fallbackTitle, String fallbackMessage, Bool allowFallback = True, Bool allowDuringRaceSetup = False)
    if Manager.IsRaceSetupQuietPresentationActive() && !allowDuringRaceSetup
        return False
    endIf

    ; Player Notifications preference: when off, suppress the toast but leave the
    ; Book of Days ledger (a separate call path) untouched.
    if !Manager.NotificationsEnabled()
        return False
    endIf

    Bool sent = False
    if PDV_PrismaBridge.IsAvailable()
        sent = PDV_PrismaBridge.SendOverlayJson(WithPrismaToastSize(payload))
    endIf

    if !sent && allowFallback
        ShowToastFallbackNotification(fallbackTitle, fallbackMessage)
        sent = BuildToastFallbackText(fallbackTitle, fallbackMessage) != ""
    endIf
    return sent
EndFunction

String Function BuildPrismaEventFallbackText(String eventName, String deityName, String context, String tierLabel, String rival)
    context = Manager.NormalizePublicDeityDisplayText(context)
    deityName = Manager.NormalizePublicDeityDisplayText(deityName)
    rival = Manager.NormalizePublicDeityDisplayText(rival)
    if context != ""
        return context
    endIf
    if eventName == "tier" && deityName != "" && tierLabel != ""
        return deityName + " marks you as " + tierLabel + "."
    elseIf eventName == "neglect" && deityName != ""
        return deityName + "'s regard fades as your devotion goes quiet."
    elseIf eventName == "dawn"
        return "Your devotions settle with the dawn."
    elseIf eventName == "favor" && deityName != ""
        return deityName + " marks the act."
    elseIf eventName == "shift" && deityName != ""
        return deityName + " marks the change."
    elseIf eventName == "rivalry" && rival != ""
        return rival + " pulls against your path."
    endIf
    return ""
EndFunction

Bool Function SendPrismaToast(String symbolName, String tone, String titleText, String messageText, Bool allowFallback = True, Bool allowDuringRaceSetup = False)
    String payload = "{\"mode\":\"toast\",\"toast\":{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"message\":\"" + PDV_DevotionRules.JsonSafeString(messageText) + "\"}}"
    return SendPrismaToastPayloadOrFallback(payload, titleText, messageText, allowFallback, allowDuringRaceSetup)
EndFunction

Bool Function SendPrismaToastWithSource(String symbolName, String tone, String titleText, String messageText, String sourceModName, Bool allowFallback = True, String correlation = "")
    if sourceModName == "" && correlation == ""
        return SendPrismaToast(symbolName, tone, titleText, messageText, allowFallback)
    endIf
    sourceModName = Manager.NormalizePublicDeityDisplayText(sourceModName)
    String correlationPrefix = ""
    if correlation != ""
        correlationPrefix = "\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\","
    endIf
    String payload = "{\"mode\":\"toast\"," + correlationPrefix + "\"toast\":{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\",\"message\":\"" + PDV_DevotionRules.JsonSafeString(messageText) + "\""
    if sourceModName != ""
        payload = payload + ",\"source\":\"" + PDV_DevotionRules.JsonSafeString(sourceModName) + "\""
    endIf
    if correlation != ""
        payload = payload + ",\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\""
    endIf
    payload = payload + "}}"
    String fallbackTitle = titleText
    if sourceModName != ""
        fallbackTitle = titleText + " - " + sourceModName
    endIf
    return SendPrismaToastPayloadOrFallback(payload, fallbackTitle, messageText, allowFallback)
EndFunction

Bool Function SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival, Bool allowFallback = True)
    String deityName = ""
    String symbolName = "journal"
    if deity
        deityName = GetPublicDeityDisplayName(deity)
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    context = Manager.NormalizePublicDeityDisplayText(context)
    rival = Manager.NormalizePublicDeityDisplayText(rival)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\""
    j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(deityName) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + PDV_DevotionRules.JsonSafeString(rival) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, "", BuildPrismaEventFallbackText(eventName, deityName, context, tierLabel, rival), allowFallback)
EndFunction

Bool Function SendPrismaTierMilestone(PDV_DeityBase deity, Int tier, String correlation)
    String deityName = ""
    String tierLabel = ""
    String symbolName = ""
    String j = ""
    if !deity || tier <= Manager.LedgerRuntime.TIER_NONE || correlation == ""
        return False
    endIf
    deityName = GetPublicDeityDisplayName(deity)
    tierLabel = GetTierStandingLabel(tier)
    symbolName = GetPrismaSymbolForDeity(deity)
    j = "{\"mode\":\"toast\",\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\",\"toast\":{\"event\":\"tier\""
    j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(deityName) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    j = j + ",\"correlation\":\"" + PDV_DevotionRules.JsonSafeString(correlation) + "\"}}"
    return SendPrismaToastPayloadOrFallback(j, "", BuildPrismaEventFallbackText("tier", deityName, "", tierLabel, ""), True)
EndFunction

Function RequestPanelRefresh()
    Manager.SetPanelDirty(True)
EndFunction

Function HandleDiegeticLoad(String reason)
    Manager.SetDiegeticLoadHandled(True)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.OnLoad()
        Manager.Trace(2, "Diegetic director load hook handled: " + reason)
    endIf
EndFunction

Function RefreshDiegeticMedallion(String reason)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.RefreshMedallion()
        Manager.Trace(2, "Diegetic medallion refresh requested: " + reason)
    endIf
EndFunction

Function NotifyDiegeticRoutineFavor(String reason)
    if PDV_DiegeticDirectorService
        PDV_DiegeticDirectorService.EmitRoutineFavor()
        Manager.Trace(2, "Diegetic routine favor refresh requested: " + reason)
    endIf
EndFunction

Function SurfaceTransition(String eventClass, String surfaceKey, String direction, Int deityIndex = -1, String toneOverride = "", Bool repeatable = false, Bool headline = false, Bool silent = false)
    if eventClass == "" || surfaceKey == "" || direction == ""
        return
    endIf
    surfaceKey = Manager.NormalizePublicDeityDisplayText(surfaceKey)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf

    ; Tier milestones are admitted, persisted, and replayed only by the ledger.
    ; Refuse legacy callers instead of reviving the independent Surfaced.tier guard.
    if eventClass == "tier"
        Manager.Trace(1, "Legacy tier SurfaceTransition refused; use HandleTierTransition.")
        return
    endIf

    ; Guard. Non-repeatable transitions (curse/tier/neglect first-time) keep the
    ; original PERMANENT one-shot key -- zero behavior change for existing callers.
    ; Repeatable per-race transitions scope the guard by game-day so the same
    ; transition can re-surface on a later day; callers encode the destination state
    ; in surfaceKey so distinct destinations are distinct guards.
    String guard = "PDV.Surfaced." + eventClass + "." + surfaceKey + "." + direction
    if repeatable
        ; fix-plan 4.2: scope the repeatable guard by the devotional day so a transition
        ; cannot re-surface twice across a midnight the player slept through.
        guard = guard + "." + (Manager.LedgerRuntime.GetDevotionalDay() + 2)
    endIf
    if StorageUtil.GetIntValue(None, guard) == 1
        return
    endIf

    StorageUtil.SetIntValue(None, guard, 1)
    StorageUtil.SetStringValue(None, "PDV.Surfaced.Last", guard)
    ; A silent transition (e.g. a formal-offer REFUSAL) still writes the permanent pinned
    ; Book of Days chronicle below, but skips the transient director cue -- no screen wash,
    ; no D1 sound. A refusal is a quiet closing-of-the-door, not an announced moment.
    if PDV_DiegeticDirectorService && !silent
        PDV_DiegeticDirectorService.Dispatch(eventClass, surfaceKey, direction, deityIndex, toneOverride)
    endIf

    ; Feed the Book of Days chronicle (the entries BuildJournalPayloadJson renders).
    String line = ResolveTransitionJournalLine(eventClass, surfaceKey, direction, deityIndex)
    if line != ""
        Bool pinned = headline || eventClass == "curse" || eventClass == "reorientation"
        String toneKey = TransitionToneKey(eventClass, direction)
        AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, toneKey, ResolveTransitionJournalSymbol(eventClass, deityIndex), pinned, GetJournalMagnitudeForTone(toneKey), BuildJournalEventTitle(toneKey, ""))
    endIf
EndFunction

String Function TransitionToneKey(String eventClass, String direction)
    if eventClass == "reorientation"
        return "reorientation"
    elseIf eventClass == "digest"
        return "dawn.digest"
    endIf
    return eventClass + "." + direction
EndFunction

String Function ResolveTransitionJournalLine(String eventClass, String surfaceKey, String direction, Int deityIndex)
    String toneKey = eventClass + "." + direction
    ; A curse SHIFT (e.g. werewolf -> vampire) reads, for the incoming curse, like that
    ; curse's onset. Reuse the onset frame so the shift still earns a Book of Days entry;
    ; previously curse.shift had no journal line, so a vampire reached from werewolf
    ; chronicled nothing while a fresh vampire onset did.
    String directorToneKey = toneKey
    if eventClass == "curse" && direction == "shift"
        directorToneKey = "curse.onset"
    endIf
    if PDV_DiegeticDirectorService && !(eventClass == "tier" && direction == "reach")
        String bespoke = PDV_DiegeticDirectorService.ResolveJournalLine(deityIndex, directorToneKey)
        if bespoke != ""
            if eventClass == "curse"
                return AppendCurseConsequenceLine(bespoke, direction, surfaceKey)
            endIf
            return bespoke
        endIf
    endIf

    if eventClass == "offer" && direction == "accept"
        return Manager.LedgerRuntime.BuildCommitmentOfferAcceptJournalLine(deityIndex)
    elseIf eventClass == "offer" && direction == "refuse"
        return Manager.LedgerRuntime.BuildCommitmentOfferRefuseJournalLine(deityIndex)
    elseIf eventClass == "reorientation" && direction == "shift"
        return BuildReorientationJournalLine(surfaceKey)
    elseIf eventClass == "tier" && direction == "reach"
        return BuildTierReachJournalLine(surfaceKey, deityIndex)
    elseIf eventClass == "curse" && direction == "onset"
        return AppendCurseConsequenceLine("A curse changes the shape of devotion.", direction, surfaceKey)
    elseIf eventClass == "curse" && direction == "shift"
        return AppendCurseConsequenceLine("A curse gives way to a new shape.", direction, surfaceKey)
    elseIf eventClass == "curse" && direction == "cure"
        return "The curse lifts, and devotion may answer again."
    elseIf eventClass == "neglect" && direction == "drop"
        return "A rite has grown quiet and needs attention."
    elseIf eventClass == "neglect" && direction == "recover"
        return "You return to a rite you had let fall silent."
    elseIf eventClass == "creed" && direction == "drop"
        return "You crossed " + GetJournalDeityName(deityIndex) + "'s creed, and the path recoils."
    endIf
    return ""
EndFunction

String Function AppendCurseConsequenceLine(String baseLine, String direction, String curseType)
    String phase = direction
    if direction == "shift"
        phase = "onset"
    endIf
    String consequence = Manager.OriginRuntime.GetCurseContextForRace(phase, curseType)
    if consequence == ""
        return baseLine
    endIf
    if StringUtil.Find(baseLine, consequence) >= 0
        return baseLine
    endIf
    return baseLine + " " + consequence
EndFunction

String Function BuildTierReachJournalLine(String surfaceKey, Int deityIndex)
    String deityName = GetJournalDeityName(deityIndex)
    String tierLabel = Manager.LedgerRuntime.ExtractTierLabelFromSurfaceKey(surfaceKey)
    if tierLabel == ""
        tierLabel = "a deeper standing"
    endIf
    return "Your devotion to " + deityName + " has reached " + tierLabel + "."
EndFunction

String Function BuildReorientationJournalLine(String surfaceKey)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_ALTMER
        return "Your soul records where you stand in the Thalmor question: " + surfaceKey + "."
    elseIf originRace == Manager.ORIGIN_BRETON
        return BuildStartupRoadJournalLine(surfaceKey)
    endIf
    return ""
EndFunction

String Function GetJournalDeityName(Int deityIndex)
    PDV_DeityBase deity = Manager.LedgerRuntime.GetDeityByIndex(deityIndex)
    if deity
        return GetPublicDeityDisplayName(deity)
    endIf
    return "the patron"
EndFunction

String Function ResolveTransitionJournalSymbol(String eventClass, Int deityIndex)
    if deityIndex >= 0
        PDV_DeityBase deity = Manager.LedgerRuntime.GetDeityByIndex(deityIndex)
        if deity
            return GetPrismaSymbolForDeity(deity)
        endIf
    endIf
    return "journal"
EndFunction

Bool Function PushDevotionPanel(Bool playerRequested = false)
    if !playerRequested
        return False
    endIf

    if !PDV_PrismaBridge.IsAvailable()
        return False
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    Bool pantheonBroadPresentation = Manager.LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace)
    String originLabel = "Unknown"
    if originRace >= 0
        originLabel = Manager.OriginRuntime.GetOriginRaceLabel(originRace)
    endIf

    String titleText = "Devotion"
    String symbolName = "journal"
    Float piety = 0.0
    Float pietyToday = 0.0
    Int tierValue = Manager.LedgerRuntime.TIER_NONE
    String tierLabelOverride = ""
    Float championThreshold = 85.0

    PDV_DaedricPathBase panelPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if panelPact
        ; Prince-wins: the active pact is the single commitment, so the WHOLE panel
        ; identity (not just the text fields) reflects it. Manager.GetActiveDeity() is None here
        ; (severed under exclusivity), so without this the header/bar would fall to the
        ; race substrate at piety 0.
        titleText = GetCanonicalDeityDisplayName(panelPact)
        symbolName = GetPrismaSymbolForDeity(panelPact)
        if symbolName == "journal"
            symbolName = "daedric"
        endIf
        piety = panelPact.GetStoredPiety()
        pietyToday = Manager.LedgerRuntime.GetPietyToday(panelPact)
        tierValue = panelPact.GetStoredTier()
        if panelPact.ThresholdChampion > 0.0
            championThreshold = panelPact.ThresholdChampion
        endIf
    elseIf Manager.GetActiveDeity()
        titleText = GetPublicDeityDisplayName(Manager.GetActiveDeity())
        symbolName = GetPrismaSymbolForDeity(Manager.GetActiveDeity())
        piety = Manager.LedgerRuntime.GetPiety(Manager.GetActiveDeity())
        pietyToday = Manager.LedgerRuntime.GetPietyToday(Manager.GetActiveDeity())
        tierValue = Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity())
        if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
            tierValue = Manager.LedgerRuntime.TIER_NONE
            tierLabelOverride = "Wavering"
        endIf
        if Manager.GetActiveDeity().ThresholdChampion > 0.0
            championThreshold = Manager.GetActiveDeity().ThresholdChampion
        endIf
    else
        ; Quasi-patron: surface the race's substrate/state-track as panel identity.
        ; Piety stays 0 for substrate races; there is no single scoring float.
        ; The tierLabelOverride carries the meaningful state (e.g. "Hist: Strained").
        titleText = GetPanelQuasiPatronName(originRace)
        symbolName = GetPanelQuasiPatronSymbol(originRace)
        tierLabelOverride = GetPanelQuasiPatronTierLabel(originRace)
        Int broadTier = Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace)
        if pantheonBroadPresentation || broadTier > Manager.LedgerRuntime.TIER_NONE
            titleText = Manager.OriginRuntime.GetBroadLaneDisplayName(originRace)
            symbolName = Manager.OriginRuntime.GetBroadLaneSymbol(originRace)
            tierValue = broadTier
            tierLabelOverride = Manager.OriginRuntime.GetBroadLaneStandingLabel(originRace, broadTier)
            piety = Manager.OriginRuntime.GetBroadLaneStandingValue(originRace)
            pietyToday = Manager.OriginRuntime.GetBroadLaneScratchValue(originRace)
        endIf
        if Manager.LedgerRuntime.PDV_GLO_ActivePiety
            if !pantheonBroadPresentation && broadTier <= Manager.LedgerRuntime.TIER_NONE
                piety = Manager.LedgerRuntime.PDV_GLO_ActivePiety.GetValue()
            endIf
        endIf
        if Manager.LedgerRuntime.PDV_GLO_ActiveTier
            if !pantheonBroadPresentation && broadTier <= Manager.LedgerRuntime.TIER_NONE
                tierValue = Manager.LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
            endIf
        endIf
        if originRace == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
            piety = Manager.PDV_ArgonianHistSubstrate.GetMetric()
            tierValue = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
            tierLabelOverride = Manager.OriginRuntime.GetArgonianCulturalPracticeLabel()
            championThreshold = 75.0
        endIf
    endIf

    ; The single active commitment (pact-wins, else patron) for the threshold + instrument.
    PDV_DeityBase panelCommitment = Manager.GetActiveDeity()
    if panelPact
        panelCommitment = panelPact
    endIf

    String tierLabel = tierLabelOverride
    if tierLabel == ""
        tierLabel = GetCurrentStandingLabel()
    endIf

    String j = "{\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    j = j + ",\"status\":\"Live\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"patron\":\"" + PDV_DevotionRules.JsonSafeString(GetPlayerMcmPatronLine()) + "\""
    j = j + ",\"patronNote\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelPatronNote()) + "\""
    j = j + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(GetSurveyDevotionText()) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    String nextText = GetPanelNextThresholdText(panelCommitment, piety)
    if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        nextText = "Focused boon returns at 50 piety"
    elseIf panelCommitment == None && originRace == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        nextText = Manager.OriginRuntime.GetArgonianCulturalNextThresholdText(piety)
    elseIf panelCommitment == None && (pantheonBroadPresentation || Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace) > Manager.LedgerRuntime.TIER_NONE)
        nextText = Manager.OriginRuntime.GetBroadLaneNextThresholdText(originRace)
    endIf
    j = j + ",\"nextText\":\"" + PDV_DevotionRules.JsonSafeString(nextText) + "\""
    j = j + ",\"piety\":" + piety
    if panelCommitment == None && (pantheonBroadPresentation || Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace) > Manager.LedgerRuntime.TIER_NONE)
        if originRace == Manager.ORIGIN_BRETON
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + Manager.OriginRuntime.GetBroadLaneServiceCount(originRace) + " practice points") + "\""
        elseIf originRace == Manager.ORIGIN_IMPERIAL || originRace == Manager.ORIGIN_NORD
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.FormatTwoDecimals(Manager.OriginRuntime.GetBroadLaneStandingValue(originRace)) + " pantheon standing") + "\""
        else
            j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString("" + Manager.OriginRuntime.GetBroadLaneServiceCount(originRace) + " broad acts") + "\""
        endIf
    elseIf panelCommitment == None && originRace == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        j = j + ",\"pietyLabel\":\"" + PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.FormatTwoDecimals(piety) + " cultural practice") + "\""
    endIf
    j = j + ",\"pietyToday\":" + pietyToday
    j = j + ",\"todayMood\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelTodayMood(pietyToday)) + "\""
    j = j + ",\"driftLabel\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelDriftLabel()) + "\""
    j = j + ",\"originRace\":\"" + PDV_DevotionRules.JsonSafeString(originLabel) + "\""
    j = j + ",\"patronState\":\"" + PDV_DevotionRules.JsonSafeString(Manager.LedgerRuntime.GetPatronStateLabel()) + "\""
    j = j + ",\"acts\":[" + GetPanelActsJson() + "]"
    j = j + ",\"rites\":[" + GetPanelRitesJson() + "]"
    j = j + ",\"relations\":[" + GetPanelRelationsJson() + "]"
    j = j + ",\"recognition\":" + Manager.RecognitionRuntime.GetNpcRecognitionPanelJson()
    j = j + ",\"instrument\":" + GetPanelInstrumentJson(originRace, panelCommitment != None, tierValue, tierLabel, piety, championThreshold)
    j = j + ",\"dashboard\":" + GetDashboardJson()
    j = j + ",\"debug\":" + GetPanelDebugJson()
    j = j + "}"

    return PDV_PrismaBridge.SendJson(j)
EndFunction

String Function GetDashboardJson()
    String gods = ""
    Int shown = 0
    Int originRace = Manager.GetPlayerOriginRaceIndex()

    PDV_DeityBase tracked = Manager.GetActiveDeity()
    if !tracked
        ; An active Prince pact is the tracked commitment (it's not in PDV_FLST_AllDeities,
        ; so the pantheon loop below won't double-list it).
        PDV_DaedricPathBase dashPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
        if dashPact
            tracked = dashPact
        endIf
    endIf
    if !tracked && Manager.OriginRuntime.IsKhajiitOrigin()
        tracked = Manager.OriginRuntime.GetKhajiitEmphasisDeity(Manager.OriginRuntime.GetKhajiitFocusedEmphasis())
    endIf
    if tracked
        gods = AppendDashboardGod(gods, tracked, "patron")
        shown += 1
    endIf

    PDV_DaedricPathBase watchingPath = Manager.DaedricRuntime.GetTopPrePactDaedricPath()
    if watchingPath && watchingPath != tracked
        gods = AppendDashboardGod(gods, watchingPath, "watching")
        shown += 1
    endIf

    if Manager.LedgerRuntime.PDV_FLST_AllDeities
        Int i = 0
        Int count = Manager.LedgerRuntime.PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = Manager.LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if deity && deity != tracked && Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, originRace)
                Form deityForm = deity as Form
                Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
                Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
                if piety > 0.0 || pietyToday != 0.0 || Manager.LedgerRuntime.IsNeglectFlagActive(deity) || Manager.LedgerRuntime.HasRecentPietyMovement(deityForm)
                    gods = AppendDashboardGod(gods, deity, "pantheon")
                    shown += 1
                endIf
            endIf
            i += 1
        endWhile
    endIf

    String j = "{\"gods\":[" + gods + "]"
    j = j + ",\"systems\":[\"patron\",\"pantheon\",\"watching\",\"neglected\"]}"
    return j
EndFunction

String Function AppendDashboardGod(String acc, PDV_DeityBase deity, String system)
    Form deityForm = deity as Form
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    Int tier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int

    String entry = "{\"god\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(deity)) + "\""
    entry = entry + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(GetPrismaSymbolForDeity(deity)) + "\""
    entry = entry + ",\"system\":\"" + PDV_DevotionRules.JsonSafeString(system) + "\""
    entry = entry + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(Manager.LedgerRuntime.GetGodRollupState(deity)) + "\""
    entry = entry + ",\"pietyToday\":" + pietyToday
    entry = entry + ",\"piety\":" + piety
    entry = entry + ",\"tier\":" + tier
    entry = entry + ",\"drivers\":[" + Manager.LedgerRuntime.GetDeityDriversJson(deity) + "]"
    entry = entry + ",\"week\":[" + BuildWeekNetJson(deityForm) + "]}"

    if acc != ""
        acc = acc + ","
    endIf
    return acc + entry
EndFunction

Function PushWeekNet(Form deityForm, Float dayNet)
    while StorageUtil.FloatListCount(deityForm, "PDV.Week.Net") >= 7
        StorageUtil.FloatListRemoveAt(deityForm, "PDV.Week.Net", 0)
    endWhile
    StorageUtil.FloatListAdd(deityForm, "PDV.Week.Net", dayNet, True)
EndFunction

String Function BuildWeekNetJson(Form deityForm)
    String out = ""
    Int n = StorageUtil.FloatListCount(deityForm, "PDV.Week.Net")
    Int i = 0
    while i < n
        if out != ""
            out = out + ","
        endIf
        out = out + StorageUtil.FloatListGet(deityForm, "PDV.Week.Net", i)
        i += 1
    endWhile
    Float todayNet = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    if out != ""
        out = out + ","
    endIf
    return out + todayNet
EndFunction

String Function GetPanelInstrumentJson(Int originRace, Bool hasActiveDeity, Int tierValue, String tierLabel, Float piety, Float championThreshold)
    String kindText = GetPanelInstrumentKind(originRace, hasActiveDeity)
    Float primary = 0.0
    if kindText == "broad"
        primary = PDV_DevotionRules.ClampValue(piety / Manager.LedgerRuntime.BROAD_PANTHEON_POOL_MAX, 0.0, 1.0)
    elseIf kindText == "cultural"
        primary = PDV_DevotionRules.ClampValue(piety / 75.0, 0.0, 1.0)
    elseIf kindText == "piety"
        Float pietyDenom = championThreshold
        if pietyDenom <= 0.0
            pietyDenom = 85.0
        endIf
        primary = PDV_DevotionRules.ClampValue(piety / pietyDenom, 0.0, 1.0)
    else
        primary = PDV_DevotionRules.ClampValue((tierValue as Float) / 3.0, 0.0, 1.0)
    endIf

    String j = "{\"kind\":\"" + PDV_DevotionRules.JsonSafeString(kindText) + "\""
    j = j + ",\"tier\":" + tierValue
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    j = j + ",\"primary\":" + PDV_DevotionRules.FormatTwoDecimals(primary)
    j = j + ",\"state\":\"" + PDV_DevotionRules.JsonSafeString(GetPanelInstrumentState(originRace, kindText, tierLabel)) + "\""
    j = j + ",\"data\":" + GetPanelInstrumentDataJson(originRace, kindText, piety)
    j = j + "}"
    return j
EndFunction

String Function GetPanelNextThresholdText(PDV_DeityBase deity, Float piety)
    if !deity
        return ""
    endIf
    if piety < deity.ThresholdSeeker
        return "Seeker at " + (deity.ThresholdSeeker as Int)
    elseIf piety < deity.ThresholdDevoted
        return "Devoted at " + (deity.ThresholdDevoted as Int)
    elseIf piety < deity.ThresholdChampion
        return "Champion at " + (deity.ThresholdChampion as Int)
    endIf
    return "Champion path"
EndFunction

String Function GetPanelInstrumentKind(Int originRace, Bool hasActiveDeity)
    if hasActiveDeity
        return "piety"
    endIf
    if Manager.LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace) > Manager.LedgerRuntime.TIER_NONE
        return "broad"
    endIf
    if originRace == Manager.ORIGIN_KHAJIIT
        return "lunar"
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        return "cultural"
    elseIf originRace == Manager.ORIGIN_DUNMER
        return "ancestor"
    elseIf originRace == Manager.ORIGIN_ORC
        return "forge"
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "sects"
    elseIf originRace == Manager.ORIGIN_BOSMER
        return "branch"
    endIf
    return "piety"
EndFunction

String Function GetPanelInstrumentState(Int originRace, String kindText, String tierLabel)
    if kindText == "lunar"
        return GetPanelQuasiPatronTierLabel(originRace)
    elseIf kindText == "cultural"
        return Manager.OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf kindText == "ancestor"
        return Manager.OriginRuntime.GetDunmerAncestorLayerLabel()
    elseIf kindText == "forge"
        return Manager.OriginRuntime.GetOrcLifeModeLabel()
    elseIf kindText == "sects"
        return Manager.OriginRuntime.GetRedguardSectLabel()
    elseIf kindText == "branch"
        return Manager.OriginRuntime.GetBosmerPathLabel()
    endIf
    return tierLabel
EndFunction

String Function GetPanelInstrumentDataJson(Int originRace, String kindText, Float piety)
    if kindText == "broad"
        if originRace == Manager.ORIGIN_IMPERIAL || originRace == Manager.ORIGIN_NORD
            return "{\"standing\":" + PDV_DevotionRules.FormatTwoDecimals(Manager.OriginRuntime.GetBroadLaneStandingValue(originRace)) + ",\"scratch\":" + PDV_DevotionRules.FormatTwoDecimals(Manager.OriginRuntime.GetBroadLaneScratchValue(originRace)) + ",\"pool\":\"" + PDV_DevotionRules.JsonSafeString(Manager.LedgerRuntime.GetActiveBroadPantheonPoolId()) + "\",\"baseline\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetBroadLaneDisplayName(originRace)) + "\"}"
        endIf
        return "{\"acts\":" + Manager.OriginRuntime.GetBroadLaneServiceCount(originRace) + "}"
    endIf
    if kindText == "lunar"
        Int phase = Manager.OriginRuntime.GetKhajiitMoonPhaseFromGameDay(Utility.GetCurrentGameTime())
        Int focus = Manager.OriginRuntime.GetKhajiitFocusedEmphasis()
        String lunarTier = "Quiet"
        Int substrateTier = 0
        if Manager.PDV_KhajiitLunarSubstrate
            substrateTier = Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier()
            lunarTier = Manager.OriginRuntime.GetKhajiitLunarTierLabel(substrateTier)
        endIf
        String standing = "Lunar Lattice"
        PDV_DeityBase focusDeity = Manager.OriginRuntime.GetKhajiitEmphasisDeity(focus)
        if focusDeity
            standing = GetPublicTierBand(Manager.LedgerRuntime.GetTier(focusDeity))
        endIf
        String focusLabel = Manager.OriginRuntime.GetKhajiitFocusLabel(focus)
        String strengthLabel = Manager.OriginRuntime.GetKhajiitFocusLabel(Manager.OriginRuntime.GetLunarPresidingFocus(phase))
        return "{\"phase\":" + phase + ",\"focus\":\"" + PDV_DevotionRules.JsonSafeString(focusLabel) + "\",\"lunarTier\":\"" + PDV_DevotionRules.JsonSafeString(lunarTier) + "\",\"currentFocus\":\"" + PDV_DevotionRules.JsonSafeString(focusLabel) + "\",\"godInStrength\":\"" + PDV_DevotionRules.JsonSafeString(strengthLabel) + "\",\"focusStanding\":\"" + PDV_DevotionRules.JsonSafeString(standing) + "\",\"substrateTier\":" + substrateTier + ",\"resonating\":" + PDV_DevotionRules.BoolToJson(Manager.OriginRuntime.IsKhajiitLatticeResonating()) + "}"
    elseIf kindText == "cultural"
        Float hist = 0.0
        Float people = 0.0
        Float voidValue = 0.0
        Bool voidActive = False
        if Manager.PDV_ArgonianHistSubstrate
            hist = Manager.PDV_ArgonianHistSubstrate.GetHistRelation()
            people = Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation()
            voidValue = Manager.PDV_ArgonianHistSubstrate.GetVoidRelation()
            voidActive = Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
        endIf
        Float culturalMetric = 0.0
        Int culturalTier = Manager.LedgerRuntime.TIER_NONE
        if Manager.PDV_ArgonianHistSubstrate
            culturalMetric = Manager.PDV_ArgonianHistSubstrate.GetMetric()
            culturalTier = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
        endIf
        return "{\"metric\":" + PDV_DevotionRules.FormatTwoDecimals(culturalMetric) + ",\"culturalTier\":" + culturalTier + ",\"hist\":" + PDV_DevotionRules.FormatTwoDecimals(hist) + ",\"people\":" + PDV_DevotionRules.FormatTwoDecimals(people) + ",\"void\":" + PDV_DevotionRules.FormatTwoDecimals(voidValue) + ",\"voidActive\":" + PDV_DevotionRules.BoolToJson(voidActive) + "}"
    elseIf kindText == "ancestor"
        Int depth = 0
        Int prayer = 0
        Int home = 0
        if Manager.PDV_DunmerAncestorSubstrate
            depth = Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier()
            prayer = Manager.PDV_DunmerAncestorSubstrate.GetPrayerCount()
            home = Manager.PDV_DunmerAncestorSubstrate.GetHomeBonusCount()
        endIf
        return "{\"depth\":" + depth + ",\"prayer\":" + prayer + ",\"home\":" + home + ",\"reclamation\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetDunmerAncestorLayerLabel()) + "\"}"
    elseIf kindText == "forge"
        return "{\"lifeMode\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetOrcLifeModeLabel()) + "\"}"
    elseIf kindText == "sects"
        return "{\"sect\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetRedguardSectLabel()) + "\"}"
    elseIf kindText == "branch"
        return "{\"path\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetBosmerPathLabel()) + "\",\"pactBound\":" + PDV_DevotionRules.BoolToJson(Manager.OriginRuntime.IsBosmerPactBound()) + ",\"evidenceDays\":" + Manager.OriginRuntime.GetBosmerPathEvidenceDays() + "}"
    endIf
    return "{\"piety\":" + PDV_DevotionRules.FormatTwoDecimals(piety) + ",\"pietyToday\":0.00}"
EndFunction

String Function GetPanelPatronNote()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose a path through play, prayer, and consequence."
    endIf
    PDV_DaedricPathBase pactPath = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON && Manager.OriginRuntime.GetBretonTraditionValue() == Manager.BRETON_TRADITION_HIDDEN_ART && Manager.DaedricRuntime.IsBretonHiddenArtDaedricOfferDeity(pactPath)
            return "The " + GetCanonicalDeityDisplayName(pactPath) + " pact stands within the Hidden Art; the tradition remains your practiced road."
        endIf
        return "A pact binds you; lesser devotions fall quiet."
    endIf
    if Manager.LedgerRuntime.IsBroadWorshipActive()
        return "You keep the broad rites of your people, with no single patron yet named."
    endIf
    if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "The commitment remains, but its boon is suspended below 50 piety."
    endIf
    ; GetPlayerMcmModeLine handles all races: active patron, substrate, and
    ; state-track modes, so it works for both deity and quasi-patron cases.
    return GetPlayerMcmModeLine()
EndFunction

String Function GetPanelTodayMood(Float pietyToday)
    if pietyToday > 0.5
        return "The day's acts lean toward reverence."
    elseIf pietyToday < -0.5
        return "The day's acts have strained the bond."
    endIf
    return "No devotional acts have settled yet."
EndFunction

String Function GetPanelDriftLabel()
    if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Suspended"
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        return "Thinning"
    endIf
    if Manager.DaedricRuntime.GetActiveDaedricPactPath()
        return "Steady"
    endIf
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return "Steady"
    endIf
    return "Quiet"
EndFunction

String Function GetPanelActsJson()
    String items = ""
    PDV_DaedricPathBase actsPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if actsPact
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("daedric", "neutral", "Keep the pact", "Act in keeping with " + GetCanonicalDeityDisplayName(actsPact) + " to hold this pact."))
    elseIf Manager.GetActiveDeity()
        Float today = Manager.LedgerRuntime.GetPietyToday(Manager.GetActiveDeity())
        if today != 0.0
            String tone = "good"
            if today < 0.0
                tone = "warning"
            endIf
            items = PDV_DevotionRules.AppendJsonItem(items, PanelEventObject("favor", Manager.GetActiveDeity(), "", "Today's devotion is being weighed.", "" + today, tone, "", ""))
        endIf
    endIf

    if Manager.FavorRuntime.IsFavorActive()
        Int lane = Manager.FavorRuntime.GetActiveFavorLane()
        Int fam = Manager.FavorRuntime.GetActiveFavorFamily()
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("journal", "good", Manager.FavorRuntime.GetContextualFavorLaneLabel(lane), Manager.FavorRuntime.GetContextualFavorFamilyLabel(lane, fam)))
    endIf

    ; Quasi-patron: show current substrate/state-track mode as the headline act
    ; when there is no scoring patron; gives the player their mode at a glance.
    if !Manager.GetActiveDeity() && !actsPact
        Int originRace = Manager.GetPlayerOriginRaceIndex()
        String quasiLabel = GetPanelQuasiPatronTierLabel(originRace)
        if quasiLabel != ""
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(GetPanelQuasiPatronSymbol(originRace), "neutral", "Current practice", quasiLabel))
        endIf
    endIf

    return items
EndFunction

String Function GetPanelRitesJson()
    String items = PanelPlainObject("journal", "", "Survey your devotion", "Call on the Survey Devotion power to read where your path stands.")
    PDV_DaedricPathBase ritesPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if ritesPact
        String pactName = GetCanonicalDeityDisplayName(ritesPact)
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("daedric", "", "Keep " + pactName + "'s pact", "Act in keeping with " + pactName + " to hold this pact."))
    elseIf Manager.GetActiveDeity()
        String activeName = GetPublicDeityDisplayName(Manager.GetActiveDeity())
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(GetPrismaSymbolForDeity(Manager.GetActiveDeity()), "", "Keep " + activeName + "'s rites", "Act in keeping with " + activeName + " to deepen this bond."))
    else
        ; Quasi-patron: tell the player what kind of acts build their path.
        Int originRace = Manager.GetPlayerOriginRaceIndex()
        String patronName = GetPanelQuasiPatronName(originRace)
        String patronSymbol = GetPanelQuasiPatronSymbol(originRace)
        if patronName != "Devotion"
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject(patronSymbol, "", "Deepen your practice", "Continue acting in keeping with " + patronName + " to build this path."))
        endIf
    endIf
    return items
EndFunction

String Function GetPanelRelationsJson()
    String items = ""
    PDV_DaedricPathBase relsPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if relsPact
        Int dstate = relsPact.GetDaedricStateForPlayer()
        String dstateTone = "neutral"
        if dstate == relsPact.DAEDRIC_STATE_NATIVE
            dstateTone = "good"
        elseIf dstate >= relsPact.DAEDRIC_STATE_TABOO
            dstateTone = "warning"
        endIf
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", dstateTone, "", GetCanonicalDeityDisplayName(relsPact) + "'s pact stands " + relsPact.GetDaedricStateLabel(dstate) + " among your people."))
    elseIf Manager.GetActiveDeity()
        Int stance = Manager.GetActiveDeity().GetStanceForPlayer()
        String stanceText = ""
        String stanceTone = ""
        String activeName = GetPublicDeityDisplayName(Manager.GetActiveDeity())
        if stance == Manager.GetActiveDeity().STANCE_NATIVE
            stanceText = "Native practice: " + activeName + "'s rites answer you clearly."
            stanceTone = "good"
        elseIf stance == Manager.GetActiveDeity().STANCE_FOREIGN
            stanceText = "Foreign devotion: " + activeName + " answers, but as an outsider's god."
            stanceTone = "neutral"
        elseIf stance == Manager.GetActiveDeity().STANCE_TABOO
            stanceText = "Forbidden devotion: " + activeName + " is taboo to your people."
            stanceTone = "warning"
        elseIf stance == Manager.GetActiveDeity().STANCE_HOSTILE
            stanceText = "Hostile devotion: " + activeName + " stands against your people."
            stanceTone = "warning"
        endIf
        if stanceText != ""
            items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", stanceTone, "", stanceText))
        endIf

        Quest[] rivals = Manager.GetActiveDeity().RivalDeities
        if rivals && rivals.Length > 0
            Int rivalIndex = 0
            Bool relevantRivalFound = False
            while rivalIndex < rivals.Length && !relevantRivalFound
                PDV_DeityBase rivalDeity = rivals[rivalIndex] as PDV_DeityBase
                if rivalDeity && Manager.LedgerRuntime.IsDeityReachableForCurrentOrigin(rivalDeity)
                    items = PDV_DevotionRules.AppendJsonItem(items, PanelEventObject("rivalry", Manager.GetActiveDeity(), "", "", "", "", "", GetPublicDeityDisplayName(rivalDeity)))
                    relevantRivalFound = True
                endIf
                rivalIndex += 1
            endWhile
        endIf
    endIf

    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("hist", "neutral", "Hist relation", Manager.OriginRuntime.GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetHistRelation())))
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("journal", "neutral", "People relation", Manager.OriginRuntime.GetArgonianLayerStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetPeopleRelation())))
        String voidTone = "neutral"
        if Manager.PDV_ArgonianHistSubstrate.IsVoidFullyActive()
            voidTone = "warning"
        endIf
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("sithis", voidTone, "Void relation", Manager.OriginRuntime.GetArgonianVoidStrengthLabel(Manager.PDV_ArgonianHistSubstrate.GetVoidRelation())))
    endIf

    if Manager.LedgerRuntime.IsBroadWorshipActive()
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", "neutral", "", "You keep the broad rites of your people, with no single patron named."))
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
        items = PDV_DevotionRules.AppendJsonItem(items, PanelPlainObject("", "warning", "", "Some of your rites have grown quiet and need attention."))
    endIf

    return items
EndFunction

String Function GetPanelDebugJson()
    String j = "{\"Favor\":\"" + PDV_DevotionRules.JsonSafeString(Manager.FavorRuntime.GetPlayerMcmFavorLine()) + "\""
    j = j + ",\"Neglect\":\"" + PDV_DevotionRules.JsonSafeString(Manager.LedgerRuntime.GetPlayerMcmNeglectLine()) + "\""
    j = j + ",\"Curse\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetPlayerCursePublicLabel()) + "\""
    j = j + "}"
    return j
EndFunction

String Function GetPanelQuasiPatronName(Int originRace)
    String label = Manager.OriginRuntime.GetQuasiPatronName()
    if label != ""
        return label
    endIf
    return "Devotion"
EndFunction

String Function GetPanelQuasiPatronSymbol(Int originRace)
    String symbolName = Manager.OriginRuntime.GetQuasiPatronSymbol()
    if symbolName != ""
        return symbolName
    endIf
    return "journal"
EndFunction

String Function GetPanelQuasiPatronTierLabel(Int originRace)
    return Manager.OriginRuntime.GetQuasiPatronTierLabel()
EndFunction

String Function PanelEventObject(String eventName, PDV_DeityBase deity, String context, String itemText, String amountText, String tone, String tierLabel, String rival)
    String deityName = ""
    String symbolName = "journal"
    if deity
        deityName = GetPublicDeityDisplayName(deity)
        symbolName = GetPrismaSymbolForDeity(deity)
    endIf
    context = Manager.NormalizePublicDeityDisplayText(context)
    itemText = Manager.NormalizePublicDeityDisplayText(itemText)
    rival = Manager.NormalizePublicDeityDisplayText(rival)
    String j = "{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\""
    if deityName != ""
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(deityName) + "\""
    endIf
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if itemText != ""
        j = j + ",\"text\":\"" + PDV_DevotionRules.JsonSafeString(itemText) + "\""
    endIf
    if amountText != ""
        j = j + ",\"amount\":" + amountText
    endIf
    if tone != ""
        j = j + ",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\""
    endIf
    if tierLabel != ""
        j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    endIf
    if rival != ""
        j = j + ",\"rival\":\"" + PDV_DevotionRules.JsonSafeString(rival) + "\""
    endIf
    j = j + "}"
    return j
EndFunction

String Function PanelPlainObject(String symbolName, String tone, String listTitle, String listText)
    String j = "{\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if tone != ""
        j = j + ",\"tone\":\"" + PDV_DevotionRules.JsonSafeString(tone) + "\""
    endIf
    if listTitle != ""
        j = j + ",\"listTitle\":\"" + PDV_DevotionRules.JsonSafeString(listTitle) + "\""
    endIf
    j = j + ",\"listText\":\"" + PDV_DevotionRules.JsonSafeString(listText) + "\""
    j = j + "}"
    return j
EndFunction

Function ShowP2BookNotice(String reason, String titleText, String messageText)
    SurfaceP2BookReadNotice(reason, titleText, messageText)
EndFunction

Function SurfaceP2BookReadNotice(String reason, String titleText, String messageText)
    if !IsP2BookNoticeReason(reason)
        return
    endIf
    SurfaceP2Acknowledgement(titleText, messageText, True, "P2 book notice surfaced: ")
EndFunction

Function SurfaceP2AmbientProgressNotice(String titleText, String messageText)
    SurfaceP2Acknowledgement(titleText, messageText, False, "P2 ambient notice surfaced: ")
EndFunction

Function SurfaceP2Acknowledgement(String titleText, String messageText, Bool allowDuringRaceSetup, String tracePrefix)
    SendPrismaToast("journal", "good", titleText, messageText, True, allowDuringRaceSetup)
    AppendBookOfDaysEntry(messageText, Utility.GetCurrentGameTime() as Int, "favor.act", "journal", False, 1, titleText, allowDuringRaceSetup)
    Manager.Trace(2, tracePrefix + titleText)
EndFunction

Bool Function IsP2BookNoticeReason(String reason)
    return PDV_DevotionRules.StringContainsToken(reason, "po3_book")
EndFunction

String Function ResolveShrinePrayerJournalLabel(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel)
    Int originRace = Manager.GetPlayerOriginRaceIndex()

    if originRace == Manager.ORIGIN_NORD && Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Kyne")
        return "Kyne"
    endIf

    if originRace == Manager.ORIGIN_KHAJIIT
        if Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Khenarthi")
            return "Khenarthi"
        endIf
        if Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Alkosh")
            return "Alkosh"
        endIf
    endIf

    if originRace == Manager.ORIGIN_ALTMER && Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
        return "Auri-El"
    endIf

    if originRace == Manager.ORIGIN_BOSMER
        if Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Auri-El")
            return "Auri-El"
        endIf
        if Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Z'en")
            return "Z'en"
        endIf
    endIf

    if originRace == Manager.ORIGIN_REDGUARD && Manager.LedgerRuntime.ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Tu'whacca")
        return "Tu'whacca"
    endIf

    ; Resolve the alias to its deity record and use the canonical display name (e.g. the
    ; lowercase catalog key "talos" -> "Talos"). The special-case returns above still win for
    ; race display overrides (Kyne, Auri-El, ...); this only fixes the default fallthrough,
    ; which previously returned the raw lowercase alias. Falls back to the old normalize path
    ; for a shrineLabel/name that does not resolve to a deity.
    if shrineLabel != ""
        PDV_DeityBase labelDeity = Manager.LedgerRuntime.GetShrinePrayerDeityByName(shrineLabel)
        if labelDeity
            return GetPublicDeityDisplayName(labelDeity)
        endIf
        return Manager.NormalizePublicDeityDisplayText(shrineLabel)
    endIf
    PDV_DeityBase primaryDeity = Manager.LedgerRuntime.GetShrinePrayerDeityByName(primaryDeityName)
    if primaryDeity
        return GetPublicDeityDisplayName(primaryDeity)
    endIf
    return Manager.NormalizePublicDeityDisplayText(primaryDeityName)
EndFunction

String Function GetTierStandingLabel(Int tier)
    if tier >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Champion"
    elseIf tier >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Devoted"
    elseIf tier >= Manager.LedgerRuntime.TIER_SEEKER
        return "Seeker"
    endIf
    return "Unrecognized"
EndFunction

String Function GetBroadStandingBand(Int tier)
    if tier >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Faithful"
    elseIf tier >= Manager.LedgerRuntime.TIER_SEEKER
        return "Observant"
    endIf
    return "Distant"
EndFunction

String Function GetPublicTierBand(Int tier)
    return GetBroadStandingBand(tier)
EndFunction

String Function GetMilestoneStandingLabel(PDV_DeityBase deity, Int tier)
    if deity
        if deity == Manager.GetActiveDeity()
            return GetTierStandingLabel(tier)
        endIf
        if Manager.OriginRuntime.IsKhajiitOrigin() && deity == Manager.OriginRuntime.GetKhajiitEmphasisDeity(Manager.OriginRuntime.GetKhajiitFocusedEmphasis())
            return GetTierStandingLabel(tier)
        endIf
    endIf
    return GetBroadStandingBand(tier)
EndFunction

Function RunDawnBookOfDays()
    Int today = Utility.GetCurrentGameTime() as Int
    PruneBookOfDays()
    EmitBookOfDaysStateChange(today)
    Manager.OriginRuntime.EmitBookOfDaysBroadLaneTierChange(today)
    if Manager.GetDawnHadActivity()
        AppendBookOfDaysEntry(BuildBookOfDaysDigestLine(), today, "dawn.digest", "journal", False)
    endIf
EndFunction

Function EmitBookOfDaysStateChange(Int today)
    String current = GetPlayerMcmModeLine()
    String last = StorageUtil.GetStringValue(None, "PDV.BookOfDays.LastModeSnapshot")
    if current != "" && last != "" && current != last
        AppendBookOfDaysEntry(BuildModeChangeLine(current), today, "reorientation", "journal", True)
    endIf
    StorageUtil.SetStringValue(None, "PDV.BookOfDays.LastModeSnapshot", current)
EndFunction

String Function BuildModeChangeLine(String modeLabel)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_NORD
        return "The road turns beneath you. You keep the gods now as: " + modeLabel + "."
    elseIf originRace == Manager.ORIGIN_DUNMER
        return "The ash shifts, and your place among the dead settles anew: " + modeLabel + "."
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        return "The moons mark a turning in your road: " + modeLabel + "."
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "The ancestral record marks a turn in your discipline: " + modeLabel + "."
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        return Manager.OriginRuntime.BuildImperialConcordatBookLine(modeLabel)
    elseIf originRace == Manager.ORIGIN_BRETON
        return "Your Breton road turns under the chosen tradition: " + modeLabel + "."
    endIf
    return "Your path turns. You walk now as: " + modeLabel + "."
EndFunction

String Function BuildBookOfDaysDigestLine()
    Int fedCount = StorageUtil.StringListCount(None, "PDV.BookOfDays.TodayFed")
    Int shown = fedCount
    if shown > 5
        shown = 5
    endIf

    String names = ""
    Int i = 0
    while i < shown
        String godName = StorageUtil.StringListGet(None, "PDV.BookOfDays.TodayFed", i)
        if i == 0
            names = godName
        elseIf i == shown - 1 && shown == 2
            names = names + " and " + godName
        elseIf i == shown - 1
            names = names + ", and " + godName
        else
            names = names + ", " + godName
        endIf
        i += 1
    endWhile
    if fedCount > shown
        if names != ""
            names = names + ", and others"
        else
            names = "others"
        endIf
    endIf

    if names != ""
        return "At dawn, your acts fed " + names + "."
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_DUNMER
        return "The day's offerings were noted; the ash remembers, and settles with the dawn."
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        return "The day's road was walked and noted; it settles beneath the moons at dawn."
    endIf
    return "The day's devotions were noted, and settle with the dawn."
EndFunction

Function RecordBookOfDaysFedName(String displayName)
    if displayName == ""
        return
    endIf
    StorageUtil.StringListAdd(None, "PDV.BookOfDays.TodayFed", displayName, False)
EndFunction

String Function HumanizeDriverReason(String raw)
    if raw == ""
        return "An act of devotion"
    endIf
    ; A reason carrying the display sentinel is ALREADY finished player-facing copy
    ; (a per-signal curated phrase from HumanizeCuratedSignalReason). Strip the marker
    ; and store it verbatim; do NOT re-humanize, which would drop the specific phrase
    ; to a generic fallback. Every other reason is a routing token resolved below.
    String dispMark = DisplayReasonMarker()
    if StringUtil.Find(raw, dispMark) == 0
        return StringUtil.Substring(raw, StringUtil.GetLength(dispMark))
    endIf
    if PDV_DevotionRules.StringContainsToken(raw, "meta_zen_wage")
        return "a quest paid in gold"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_julianos_wisdom")
        return "a mage-aid quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_azura_threshold")
        return "a quest at twilight or aiding mages"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_nocturnal_herway")
        return "a quest done after stealing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_nocturnal_dark")
        return "a quest done at night"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_khenarthi_road")
        return "a quest finished outdoors"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_akatosh_wheel")
        return "every tenth quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "meta_xarxes_record")
        return "every tenth quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "wayfarer_akatosh_level")
        return "leveling up under Wayfarer's Path"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos-shrine-defiance")
        return "defiant prayer at a Talos shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos_betrayal_major")
        return "turning on Talos openly"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "talos_betrayal_compliance")
        return "bending to the Talos ban"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-talos-pressure")
        return "Concordat pressure over Talos"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "concordat-compliance")
        return "complying with the Concordat"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "concordat-defiance")
        return "defying the Concordat"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-patron-civic-favor")
        return "civic service (patron bonus)"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "imperial-civic-service")
        return "civic service"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-old-ways-state")
        return "keeping the Old Ways"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-kyne-talos-context")
        return "the Old Ways beside Talos"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "nord-hircine-arkay-edge")
        return "the hunt at Arkay's edge"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "sleep-moon-observance")
        return "sleeping under aligned moons"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-road-home")
        return "returning by the road home"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-baandar-road-trick")
        return "a trick on the road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-rajhin-elegant-theft")
        return "an artful theft"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "khajiit-alkosh-dragon-order")
        return "keeping dragon order"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "hircine-hunt-rite")
        return "a ritual hunt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "green-pact-violation")
        return "breaking the Green Pact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-old-contract-proper-hunt")
        return "a proper hunt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-old-contract-forest-kept")
        return "keeping the forest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story-community")
        return "sharing the living story"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story-nature-site")
        return "a tale at a wild place"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-living-story")
        return "a Living Story deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange-debt-settled")
        return "settling a debt"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange-proportionate-vengeance")
        return "measured vengeance"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-exchange")
        return "an Exchange deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road-road-life")
        return "living the road life"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road-reversal")
        return "a reversal on the road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-bandit-road")
        return "a Bandit Road deed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "bosmer-pact-positive")
        return "keeping the Green Pact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-portable-shrine")
        return "prayer at your portable shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-home-bonus")
        return "devotions kept at home"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-reclamation-focus")
        return "focus on the Reclamations"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "dunmer-deviation-price")
        return "straying from the Reclamations"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-lorkhan-pressure")
        return "leaning toward Lorkhan"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-crisis-source")
        return "feeding the crisis of faith"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-dawn-steadiness")
        return "steadiness at dawn"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "altmer-orthodox-cost")
        return "the cost of orthodoxy paid"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-hist-maintenance")
        return "tending the Hist bond"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-people-support")
        return "supporting the People"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-void-signal")
        return "a step toward the Void"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "argonian-bed-of-choice")
        return "rest in your chosen bed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-stronghold-forge")
        return "forge work in a stronghold"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-city-dignity")
        return "dignity kept in city life"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-legion-service")
        return "service with the Legion"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-self-made-community")
        return "building a community"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-oath-break")
        return "breaking an oath"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "orc-four-holds-visit")
        return "visiting the four holds"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-crown-tomb-respect")
        return "respect at a Crown tomb"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-forebear-road")
        return "walking the Forebear road"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-ashabah-death-duty")
        return "putting down the risen dead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "redguard-far-shores-token")
        return "a Far Shores token earned"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-tradition-choice")
        return "choosing a tradition"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-knightly-vow")
        return "keeping a knightly vow"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-hidden-art-exposure")
        return "a hidden art exposed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "breton-green-way-standing")
        return "standing with the Green Way"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "state-transition-confirm-rite")
        return "a rite confirming your path"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "daedric-prince-signal")
        return "a deed the Prince claims"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "daedric-generic-silence")
        return "silence from the Princes"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shout-to-open-sky")
        return "a shout to the open sky"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "rest-under-open-sky")
        return "resting under the open sky"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "sleep-in-bed")
        return "sleeping in a bed"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "take-blessing")
        return "taking a shrine blessing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Trial of Iron")
        return "taking up the Trial of Iron"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Remembering of Names")
        return "taking up the Remembering of Names"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "Discipline of Return")
        return "setting a Discipline of Return"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "cc_fishing")
        return "fishing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "commitment_carryover")
        return "devotion carried into commitment"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "rivalry with")
        return raw
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-skill-book")
        return "reading instructive texts"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-spell-tome")
        return "reading a spell tome"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "read-lore-book")
        return "reading a lore book"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "po3_book") || PDV_DevotionRules.StringContainsToken(raw, "book")
        return "reading a book"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "increase-skill")
        return "honing your skills"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "discover-location")
        return "discovering new roads"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "learn-word-of-power")
        return "learning a Word of Power"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shout") || PDV_DevotionRules.StringContainsToken(raw, "voice")
        return "using a shout"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "shrine") || PDV_DevotionRules.StringContainsToken(raw, "prayer") || PDV_DevotionRules.StringContainsToken(raw, "pray")
        return "prayer at a shrine"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "harvest-ingredient")
        return "harvesting ingredients"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "brew-potion")
        return "brewing potions"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "smith-item")
        return "smithing an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "enchant-item")
        return "enchanting an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "cook-meal")
        return "cooking a meal"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "mine-or-chop")
        return "mining or woodcutting"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-daedra")
        return "killing Daedra"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-undead")
        return "killing undead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-dragon")
        return "killing a dragon"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "killed-hostile-beast")
        return "killing hostile beasts"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "killed-hostile-humanoid")
        return "killing hostile people"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill-animal-noncombat")
        return "killing harmless animals"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "murder-defenseless")
        return "murdering the defenseless"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "assault-innocent")
        return "assaulting an innocent"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "kill") || PDV_DevotionRules.StringContainsToken(raw, "combat") || PDV_DevotionRules.StringContainsToken(raw, "hunt")
        return "combat or hunting kills"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "heal-or-cure-npc")
        return "healing or curing someone"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "clear-bounty")
        return "paying off a bounty"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "pick-owned-lock")
        return "picking an owned lock"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "trespass")
        return "trespassing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "steal-item")
        return "stealing an item"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "pickpocket")
        return "pickpocketing"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "raise-undead")
        return "raising undead"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "vampire-feed")
        return "feeding as a vampire"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "accept-daedric-artifact")
        return "accepting a Daedric artifact"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "quest")
        return "completing a quest"
    elseIf PDV_DevotionRules.StringContainsToken(raw, "curated") || PDV_DevotionRules.StringContainsToken(raw, "rite")
        return "a devotional rite"
    endIf

    ; Quest-matrix reasons arrive as "DeityName.tag_one,tag_two" (semantic act tags
    ; from the reaction CSVs). Render the primary tag as plain trigger text
    ; ("quest: forbidden knowledge") instead of the generic fallback. Meta lanes and
    ; rivalry reasons matched above, so only cell tags reach this branch.
    Int dotIndex = StringUtil.Find(raw, ".")
    if dotIndex > 0 && dotIndex < StringUtil.GetLength(raw) - 1
        String tagText = StringUtil.Substring(raw, dotIndex + 1)
        String[] tagParts = StringUtil.Split(tagText, ",")
        tagParts = StringUtil.Split(tagParts[0], ":")
        String[] tagWords = StringUtil.Split(tagParts[0], "_")
        String prettyTag = ""
        Int wordIndex = 0
        while wordIndex < tagWords.Length
            if wordIndex > 0
                prettyTag = prettyTag + " "
            endIf
            prettyTag = prettyTag + tagWords[wordIndex]
            wordIndex += 1
        endWhile
        if prettyTag != ""
            return "quest: " + prettyTag
        endIf
    endIf

    return "An act of devotion"
EndFunction

String Function HumanizeCuratedSignalReason(PDV_DeityBase deity, Int signalType)
    if !deity
        return "a devotional rite"
    endIf

    if Manager.PDV_Talos && deity == Manager.PDV_Talos
        if signalType == Manager.PDV_Talos.SIGNAL_SHRINE_DEFIANCE
            return "defiant prayer at a Talos shrine"
        elseIf signalType == Manager.PDV_Talos.SIGNAL_PROTECT_WORSHIPPER
            return "protecting a Talos worshipper"
        elseIf signalType == Manager.PDV_Talos.SIGNAL_DEFIANCE_MILESTONE
            return "defiance of the Talos ban"
        endIf
    elseIf Manager.PDV_AuriEl && deity == Manager.PDV_AuriEl
        if signalType == Manager.PDV_AuriEl.SIGNAL_DAWN_ACKNOWLEDGMENT
            return "dawn observance"
        elseIf signalType == Manager.PDV_AuriEl.SIGNAL_ORTHODOXY_AFFIRMATION
            return "orthodox lore study"
        endIf
    elseIf Manager.PDV_Yffre && deity == Manager.PDV_Yffre
        if signalType == Manager.PDV_Yffre.SIGNAL_PACT_POSITIVE
            return "keeping the Green Pact"
        elseIf signalType == Manager.PDV_Yffre.SIGNAL_LIVING_STORY
            return "a Living Story deed"
        elseIf signalType == Manager.PDV_Yffre.SIGNAL_PACT_VIOLATION
            return "breaking the Green Pact"
        elseIf signalType == Manager.PDV_Yffre.SIGNAL_RECOMMITMENT
            return "recommitting to the Green Pact"
        elseIf signalType == Manager.PDV_Yffre.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        elseIf signalType == Manager.PDV_Yffre.SIGNAL_GREEN_WAY
            return "keeping the Green Way"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Zen && deity == Manager.LedgerRuntime.PDV_Zen
        if signalType == Manager.LedgerRuntime.PDV_Zen.SIGNAL_EXCHANGE
            return "fair exchange"
        elseIf signalType == Manager.LedgerRuntime.PDV_Zen.SIGNAL_CONFIRMATION
            return "a rite confirming your path"
        elseIf signalType == Manager.LedgerRuntime.PDV_Zen.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        endIf
    elseIf Manager.PDV_BaanDar && deity == Manager.PDV_BaanDar
        if signalType == Manager.PDV_BaanDar.SIGNAL_BANDIT_ROAD
            return "a Bandit Road deed"
        elseIf signalType == Manager.PDV_BaanDar.SIGNAL_ROAD_TRICK
            return "roadside cunning"
        elseIf signalType == Manager.PDV_BaanDar.SIGNAL_CONFIRMATION
            return "a rite confirming your path"
        elseIf signalType == Manager.PDV_BaanDar.SIGNAL_BETRAYAL
            return "betraying someone who trusted you"
        elseIf signalType == Manager.PDV_BaanDar.SIGNAL_SHARED_PACT_MEMORY
            return "a pact-true deed"
        endIf
    elseIf Manager.PDV_Khenarthi && deity == Manager.PDV_Khenarthi
        if signalType == Manager.PDV_Khenarthi.SIGNAL_ROAD_HOME
            return "returning by the road home"
        elseIf signalType == Manager.PDV_Khenarthi.SIGNAL_CARAVAN_AID
            return "aiding a caravan"
        elseIf signalType == Manager.PDV_Khenarthi.SIGNAL_CARAVAN_HARM
            return "harming a caravan"
        endIf
    elseIf Manager.PDV_Azura && deity == Manager.PDV_Azura
        if signalType == Manager.PDV_Azura.SIGNAL_MOON_OBSERVANCE
            return "moon observance"
        elseIf signalType == Manager.PDV_Azura.SIGNAL_THRESHOLD_RITE
            return "a threshold rite"
        elseIf signalType == Manager.PDV_Azura.SIGNAL_ANCESTOR_SPINE
            return "Dunmer ancestor rites"
        elseIf signalType == Manager.PDV_Azura.SIGNAL_DUNMER_TWILIGHT_RITE
            return "a twilight rite of the Reclamations"
        elseIf signalType == Manager.PDV_Azura.SIGNAL_DESECRATION
            return "desecration"
        endIf
    elseIf Manager.PDV_Rajhin && deity == Manager.PDV_Rajhin
        if signalType == Manager.PDV_Rajhin.SIGNAL_ELEGANT_THEFT
            return "artful theft"
        elseIf signalType == Manager.PDV_Rajhin.SIGNAL_LEGEND_MADE
            return "a legendary heist"
        elseIf signalType == Manager.PDV_Rajhin.SIGNAL_BOTCHED_THEFT
            return "a botched theft"
        endIf
    elseIf Manager.PDV_Alkosh && deity == Manager.PDV_Alkosh
        if signalType == Manager.PDV_Alkosh.SIGNAL_DRAGON_ORDER
            return "keeping dragon order"
        elseIf signalType == Manager.PDV_Alkosh.SIGNAL_NAMED_DRAGON
            return "defeating a named dragon"
        elseIf signalType == Manager.PDV_Alkosh.SIGNAL_CHAOS_AID
            return "aiding the Dragon Cult"
        endIf
    elseIf Manager.PDV_Hist && deity == Manager.PDV_Hist
        if signalType == Manager.PDV_Hist.SIGNAL_HIST_PULSE
            return "answering the Hist"
        elseIf signalType == Manager.PDV_Hist.SIGNAL_HIST_ABANDONMENT
            return "abandoning the Hist"
        elseIf signalType == Manager.PDV_Hist.SIGNAL_HIST_CORRUPTION
            return "corrupting Hist memory"
        elseIf signalType == Manager.PDV_Hist.SIGNAL_VOID_OVERREACH
            return "overreaching into the Void"
        endIf
    elseIf Manager.PDV_Sithis && deity == Manager.PDV_Sithis
        if signalType == Manager.PDV_Sithis.SIGNAL_VOID_THRESHOLD
            return "crossing a Void threshold"
        endIf
    elseIf Manager.PDV_Malacath && deity == Manager.PDV_Malacath
        if signalType == Manager.PDV_Malacath.SIGNAL_STRONGHOLD_FORGE
            return "stronghold forge work"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_CITY_DIGNITY
            return "dignity kept in city life"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_LEGION_SERVICE
            return "Legion service"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_SELF_MADE_COMMUNITY
            return "building a community"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_BROAD_CONDUCT
            return "keeping the code"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_ANCESTOR_SPINE
            return "rest at your declared hearth"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_CURSE_CODE_RUPTURE
            return "breaking the code by curse"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_BROKEN_FAITH_KIN
            return "breaking faith with kin"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_BLOOD_KIN
            return "standing with your Blood-Kin"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_EXILE_RETURN
            return "carrying a burden home from exile"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_FOUR_HOLDS_VISIT
            return "reaching an Orc stronghold"
        elseIf signalType == Manager.PDV_Malacath.SIGNAL_OATH_BREAK
            return "breaking an oath"
        endIf
    elseIf Manager.PDV_Tuwhacca && deity == Manager.PDV_Tuwhacca
        if signalType == Manager.PDV_Tuwhacca.SIGNAL_CROWN_FORM
            return "keeping Crown form"
        elseIf signalType == Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY
            return "death duty"
        elseIf signalType == Manager.PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN
            return "honoring the Far Shores"
        elseIf signalType == Manager.PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE
            return "Yokudan ancestor rites"
        elseIf signalType == Manager.PDV_Tuwhacca.SIGNAL_VAMPIRE_REENTRY
            return "returning to the cycle after vampirism"
        elseIf signalType == Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT
            return "abandoning death duty"
        endIf
    elseIf Manager.PDV_Leki && deity == Manager.PDV_Leki
        if signalType == Manager.PDV_Leki.SIGNAL_SWORD_SINGING
            return "sword-singing"
        elseIf signalType == Manager.PDV_Leki.SIGNAL_HONORABLE_DUEL
            return "an honorable duel won"
        endIf
    elseIf Manager.PDV_HoonDing && deity == Manager.PDV_HoonDing
        if signalType == Manager.PDV_HoonDing.SIGNAL_MAKE_WAY
            return "making way past a mighty foe"
        endIf
    elseIf Manager.PDV_Magnus && deity == Manager.PDV_Magnus
        if signalType == Manager.PDV_Magnus.SIGNAL_DISCIPLINED_STUDY
            return "disciplined study"
        elseIf signalType == Manager.PDV_Magnus.SIGNAL_MAGIC_MILESTONE
            return "a magic milestone"
        elseIf signalType == Manager.PDV_Magnus.SIGNAL_SHARED_PACT_MEMORY
            return "keeping faith with the arts"
        endIf
    elseIf Manager.PDV_Xarxes && deity == Manager.PDV_Xarxes
        if signalType == Manager.PDV_Xarxes.SIGNAL_LINEAGE_HONORED
            return "honoring lineage"
        elseIf signalType == Manager.PDV_Xarxes.SIGNAL_SHARED_PACT_MEMORY
            return "keeping the long record"
        endIf
    elseIf Manager.PDV_Boethiah && deity == Manager.PDV_Boethiah
        if signalType == Manager.PDV_Boethiah.SIGNAL_RIGHTEOUS_STRUGGLE
            return "righteous struggle"
        elseIf signalType == Manager.PDV_Boethiah.SIGNAL_HONORABLE_DUEL
            return "winning an honorable duel"
        elseIf signalType == Manager.PDV_Boethiah.SIGNAL_SHARED_PACT_MEMORY
            return "a deed for the Reclamations"
        elseIf signalType == Manager.PDV_Boethiah.SIGNAL_RECLAMATION_ABANDONED
            return "abandoning the Reclamations"
        endIf
    elseIf Manager.PDV_Mephala && deity == Manager.PDV_Mephala
        if signalType == Manager.PDV_Mephala.SIGNAL_SECRET_KEPT
            return "a secret kept"
        elseIf signalType == Manager.PDV_Mephala.SIGNAL_WEB_WOVEN
            return "weaving a plot by cunning"
        elseIf signalType == Manager.PDV_Mephala.SIGNAL_SHARED_PACT_MEMORY
            return "a deed for the Reclamations"
        elseIf signalType == Manager.PDV_Mephala.SIGNAL_SECRET_BETRAYED
            return "a secret betrayed"
        elseIf signalType == Manager.PDV_Mephala.SIGNAL_RECLAMATION_ABANDONED
            return "abandoning the Reclamations"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Akatosh && deity == Manager.LedgerRuntime.PDV_Akatosh
        if signalType == Manager.LedgerRuntime.PDV_Akatosh.SIGNAL_CIVIC_SERVICE
            return "civic service"
        elseIf signalType == Manager.LedgerRuntime.PDV_Akatosh.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Mara && deity == Manager.LedgerRuntime.PDV_Mara
        if signalType == Manager.LedgerRuntime.PDV_Mara.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == Manager.LedgerRuntime.PDV_Mara.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Arkay && deity == Manager.LedgerRuntime.PDV_Arkay
        if signalType == Manager.LedgerRuntime.PDV_Arkay.SIGNAL_DEATH_DUTY
            return "death duty"
        elseIf signalType == Manager.LedgerRuntime.PDV_Arkay.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Stendarr && deity == Manager.LedgerRuntime.PDV_Stendarr
        if signalType == Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_MERCY
            return "mercy"
        elseIf signalType == Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_LAWFUL_ORDER
            return "upholding law and order"
        elseIf signalType == Manager.LedgerRuntime.PDV_Stendarr.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Zenithar && deity == Manager.LedgerRuntime.PDV_Zenithar
        if signalType == Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_HONEST_WORK
            return "honest work"
        elseIf signalType == Manager.LedgerRuntime.PDV_Zenithar.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Julianos && deity == Manager.LedgerRuntime.PDV_Julianos
        if signalType == Manager.LedgerRuntime.PDV_Julianos.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Kynareth && deity == Manager.LedgerRuntime.PDV_Kynareth
        if signalType == Manager.LedgerRuntime.PDV_Kynareth.SIGNAL_OPEN_SKY
            return "deeds under the open sky"
        elseIf signalType == Manager.LedgerRuntime.PDV_Kynareth.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.PDV_Kyne && deity == Manager.PDV_Kyne
        if signalType == Manager.PDV_Kyne.SIGNAL_SKY_ROAD
            return "walking the sky road"
        endIf
    elseIf Manager.PDV_Tsun && deity == Manager.PDV_Tsun
        if signalType == Manager.PDV_Tsun.SIGNAL_TRIAL_ENDURED
            return "a trial endured"
        elseIf signalType == Manager.PDV_Tsun.SIGNAL_ADVERSITY_SURVIVED
            return "surviving hard adversity"
        endIf
    elseIf Manager.PDV_Stuhn && deity == Manager.PDV_Stuhn
        if signalType == Manager.PDV_Stuhn.SIGNAL_MERCY_GRANTED
            return "granting mercy to the beaten"
        elseIf signalType == Manager.PDV_Stuhn.SIGNAL_JUST_SPOILS
            return "claiming just spoils"
        elseIf signalType == Manager.PDV_Stuhn.SIGNAL_PROTECT_BOND
            return "protecting a bond"
        endIf
    elseIf Manager.PDV_Shor && deity == Manager.PDV_Shor
        if signalType == Manager.PDV_Shor.SIGNAL_HONORED_DEAD
            return "honoring the dead"
        endIf
    elseIf Manager.LedgerRuntime.PDV_Dibella && deity == Manager.LedgerRuntime.PDV_Dibella
        if signalType == Manager.LedgerRuntime.PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR
            return "civic service (patron bonus)"
        endIf
    elseIf Manager.PDV_Trinimac && deity == Manager.PDV_Trinimac
        if signalType == Manager.PDV_Trinimac.SIGNAL_FALLEN_GOD_ORTHODOXY
            return "honoring fallen Trinimac"
        elseIf signalType == Manager.PDV_Trinimac.SIGNAL_ALTMER_ORTHODOX_PRESSURE
            return "upholding elven orthodoxy"
        endIf
    endIf

    return "a devotional rite"
EndFunction

String Function DisplayReasonMarker()
    return "[disp]"
EndFunction

String Function CuratedSignalDriverReason(PDV_DeityBase deity, Int signalType)
    return DisplayReasonMarker() + HumanizeCuratedSignalReason(deity, signalType)
EndFunction

String Function GetSurvivalContextStatusLine()
    Manager.LedgerRuntime.InitSurvivalContext()

    String detected = ""
    if Manager.GetPdvSurvivalModePresent()
        detected = "Survival Mode"
    endIf
    if Manager.GetPdvSunHelmPresent()
        if detected != ""
            detected = detected + ", "
        endIf
        detected = detected + "SunHelm"
    endIf

    if detected == ""
        return "No supported survival mod detected"
    endIf

    if !Manager.LedgerRuntime.IsSurvivalContextEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | " + PDV_DevotionRules.SeverityLabel(Manager.LedgerRuntime.GetSurvivalContextSeverity())
EndFunction

String Function GetCCContentStatusLine()
    Manager.LedgerRuntime.InitCCContent()

    String detected = ""
    if Manager.GetPdvCCSaintsPresent()
        detected = "Saints & Seducers"
    endIf
    if Manager.GetPdvCCFishingPresent()
        if detected != ""
            detected = detected + ", "
        endIf
        detected = detected + "Fishing"
    endIf

    if detected == ""
        return "No supported CC content detected"
    endIf

    if !Manager.LedgerRuntime.IsCCContentEnabled()
        return detected + " | integration off"
    endIf

    return detected + " | integration on"
EndFunction

Function DispatchDiegeticCue(String eventClass, String surfaceKey, String direction, PDV_DeityBase deity, String toneOverride = "")
    Int deityIndex = -1
    if deity
        deityIndex = deity.DeityIndex
    endIf

    Bool headline = eventClass == "offer" && (direction == "accept" || direction == "refuse")
    SurfaceTransition(eventClass, surfaceKey, direction, deityIndex, toneOverride, False, headline)
EndFunction

Function SurfaceCurseTransitionDiegetic(Int oldState, Int newState)
    String direction = GetCurseSurfaceDirection(oldState, newState)
    String surfaceKey = GetCurseSurfaceKey(oldState, newState)
    if direction == "" || surfaceKey == ""
        return
    endIf

    String tone = "dread"
    if direction == "cure"
        tone = "release"
    endIf
    SurfaceTransition("curse", surfaceKey, direction, -1, tone)
EndFunction

String Function GetCurseSurfaceDirection(Int oldState, Int newState)
    if oldState == 0 && newState != 0
        return "onset"
    endIf
    if oldState != 0 && newState == 0
        return "cure"
    endIf
    if oldState != newState
        return "shift"
    endIf
    return ""
EndFunction

String Function GetCurseSurfaceKey(Int oldState, Int newState)
    Int curseRef = newState
    if newState == 0
        curseRef = oldState
    endIf
    if curseRef == 1
        return "werewolf"
    endIf
    if curseRef == 2
        return "vampire"
    endIf
    return ""
EndFunction

Function SendPrismaCurseToast(Int oldState, Int newState)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    ; Phase: what kind of transition is this?
    String phase = ""
    if oldState == 0
        phase = "onset"
    elseIf newState == 0
        phase = "cure"
    else
        phase = "shift"
    endIf

    ; Owner ruling 2026-08-07: on a CURE, stand aside when the race already spoke. A Nord curing
    ; lycanthropy was getting three surfaces for one event -- the race line, Hircine's residue toast,
    ; and this generic one, whose copy is marked PLACEHOLDER below and only restates the event flatly.
    ; Cure only, deliberately: onset has the same duplicate shape but was not part of the ruling.
    ; Only Nord, Argonian, Khajiit and Redguard have cure records, so for the other five races this
    ; generic toast is the ONLY cure surface and must keep firing.
    if phase == "cure" && Manager.GetRaceCurseSurfaceShown()
        return
    endIf

    ; Curse type: use the *incoming* state for onset/shift; outgoing state for cure
    ; so the mark and wording match what the player just experienced.
    Int curseRef = newState
    if phase == "cure"
        curseRef = oldState
    endIf
    String curseType = ""
    String symbolName = "journal"
    if curseRef == 1
        curseType = "werewolf"
        symbolName = "curse-werewolf"
    elseIf curseRef == 2
        curseType = "vampire"
        symbolName = "curse-vampire"
    endIf

    ; Race-aware context so the toast reads right for each theology.
    String context = Manager.OriginRuntime.GetCurseContextForRace(phase, curseType)

    ; Send explicit phase-correct title/message so app.js never falls to its no-phase
    ; "A curse stirs" default (it prefers an explicit title/message when present, like
    ; the working milestone toast). PLACEHOLDER copy.
    String curseLabel = "The curse"
    if curseType == "werewolf"
        curseLabel = "Lycanthropy"
    elseIf curseType == "vampire"
        curseLabel = "Vampirism"
    endIf
    String curseTitle = curseLabel + " stirs"
    String curseMessage = "Something has changed in your blood."
    if phase == "onset"
        curseTitle = curseLabel + " takes hold"
        curseMessage = curseLabel + " has taken root in your blood."
    elseIf phase == "cure"
        curseTitle = curseLabel + " is lifted"
        curseMessage = curseLabel + " has been driven out."
    elseIf phase == "shift"
        curseTitle = "The curse changes shape"
        curseMessage = "One curse gives way to another."
    endIf

    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"curse\""
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"curse\":\"" + PDV_DevotionRules.JsonSafeString(curseType) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(curseTitle) + "\""
    j = j + ",\"message\":\"" + PDV_DevotionRules.JsonSafeString(curseMessage) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if Manager.GetActiveDeity()
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(Manager.GetActiveDeity())) + "\""
    endIf
    j = j + "}}"
    PDV_PrismaBridge.SendOverlayJson(WithPrismaToastSize(j))
EndFunction

Bool Function SendPrismaShiftToast(String shiftMode, String context, String symbolName, Bool allowFallback = True)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"shift\""
    j = j + ",\"shiftMode\":\"" + PDV_DevotionRules.JsonSafeString(shiftMode) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    if Manager.GetActiveDeity()
        j = j + ",\"deity\":\"" + PDV_DevotionRules.JsonSafeString(GetPublicDeityDisplayName(Manager.GetActiveDeity())) + "\""
    endIf
    j = j + "}}"
    return SendPrismaToastPayloadOrFallback(j, shiftMode, context, allowFallback)
EndFunction

Function SendPrismaSubstrateProgress(String substrate, Int tierBefore, Int tierAfter, Float grantedMetric, String context, String symbolName, String stateLabel, Bool surfacePresentation = True)
    ; Presentation follows the actual daily-credit result, never a route's
    ; repeat multiplier. Same-day, duplicate, and capped acts therefore stay
    ; silent on substrate toasts and Book entries.
    if grantedMetric <= 0.0
        return
    endIf
    ; TOAST PARITY, owner ruling 2026-08-06. This branch used to return before any toast, so the
    ; Altmer spine was the only substrate in the mod that never surfaced one. That came from an
    ; earlier "slow cultural foundation, not an interruption" note written while depth was still
    ; being decided, and it was read more strictly than intended: it silenced the toast as well as
    ; the chatter. Altmer now surfaces like every other race.
    ;
    ; It still does NOT fall through to the generic path below, because that path also writes a
    ; Book of Days entry from the context. AppendAltmerHeritageVoice already owns the per-credit
    ; line and the tier crossing is handled here, so falling through would double-log every act.
    if substrate == "altmer-heritage"
        if surfacePresentation
            if tierAfter > tierBefore
                Manager.OriginRuntime.SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
            else
                Manager.OriginRuntime.SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
            endIf
        endIf
        if tierAfter > tierBefore
            AppendBookOfDaysEntry(Manager.OriginRuntime.GetAltmerHeritageTierJournalLine(tierAfter), Utility.GetCurrentGameTime() as Int, "substrate.act", "auri-el", False, 2, "Ancestral inheritance deepens")
        endIf
        return
    endIf
    if surfacePresentation
        if tierAfter > tierBefore
            Manager.OriginRuntime.SendPrismaSubstrateToast(substrate, "deepen", context, symbolName, stateLabel)
        elseIf tierAfter < tierBefore
            Manager.OriginRuntime.SendPrismaSubstrateToast(substrate, "thin", context, symbolName, stateLabel)
        else
            Manager.OriginRuntime.SendPrismaSubstrateToast(substrate, "act", context, symbolName, stateLabel)
        endIf

        if context != "" && tierAfter >= tierBefore
            String entryText = context
            if stateLabel != ""
                entryText = stateLabel + ": " + context
            endIf
            AppendBookOfDaysEntry(entryText, Utility.GetCurrentGameTime() as Int, "substrate.act", symbolName, False)
        endIf
    endIf
EndFunction

String Function BuildStartupRoadJournalLine(String pathLabel)
    if pathLabel == ""
        return "You've chosen your road."
    endIf
    return "You've chosen your road: " + pathLabel + "."
EndFunction

Function SendPrismaStartupPayload(Int originRace, Int startupMode, Int defaultOption, Bool confirmRequired, String eventName)
    if !AllowPrismaBlockingSurfaces
        return
    endIf

    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    Int optionCount = 1
    if startupMode == Manager.STARTUP_MODE_EXPLICIT_CHOICE
        optionCount = Manager.GetStartupChoiceMaxOption(originRace) + 1
    endIf

    String optionsJson = ""
    Int i = 0
    while i < optionCount
        Int optionValue = i
        if startupMode == Manager.STARTUP_MODE_INFO_ONLY
            optionValue = 0
        endIf

        if i > 0
            optionsJson = optionsJson + ","
        endIf

        optionsJson = optionsJson + "{\"option_id\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupOptionId(originRace, optionValue)) + "\",\"title\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupOptionTitle(originRace, optionValue)) + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupOptionSummary(originRace, optionValue)) + "\",\"description\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupOptionDescription(originRace, optionValue)) + "\"}"
        i += 1
    endWhile

    String modeText = "info_only"
    if startupMode == Manager.STARTUP_MODE_EXPLICIT_CHOICE
        modeText = "explicit_choice"
    endIf

    String payload = "{\"mode\":\"startup\",\"startup\":{\"event\":\"" + PDV_DevotionRules.JsonSafeString(eventName) + "\",\"race_id\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupRaceId(originRace)) + "\",\"startup_mode\":\"" + modeText + "\",\"options\":[" + optionsJson + "],\"default_option_id\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupOptionId(originRace, defaultOption)) + "\",\"advisory_line\":\"" + PDV_DevotionRules.JsonSafeString(Manager.STARTUP_ADVISORY_TEXT) + "\",\"confirm_required\":" + PDV_DevotionRules.BoolToJson(confirmRequired) + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(Manager.OriginRuntime.GetOriginRaceLabel(originRace) + " startup") + "\",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupCanonicalSummary(originRace)) + "\"}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

Function SendPrismaMedallionPayload(Int originRace)
    if !AllowPrismaBlockingSurfaces
        return
    endIf

    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf

    String sectionsJson = Manager.OriginRuntime.GetMedallionSectionsJson(originRace)
    String raceLabel = Manager.OriginRuntime.GetOriginRaceLabel(originRace)
    String payload = "{\"mode\":\"medallion\",\"medallion\":{\"race_id\":\"" + PDV_DevotionRules.JsonSafeString(Manager.GetStartupRaceId(originRace)) + "\""
    payload = payload + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(raceLabel + " Medallion") + "\""
    payload = payload + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString("The medallion shows the native roster. Only live, scorable entries can be chosen.") + "\""
    payload = payload + ",\"active_option_id\":\"" + PDV_DevotionRules.JsonSafeString(GetActiveMedallionOptionId()) + "\""
    payload = payload + ",\"advisory_line\":\"" + PDV_DevotionRules.JsonSafeString("The medallion shows the roster; commitment comes through an offer.") + "\""
    payload = payload + ",\"sections\":[" + sectionsJson + "]}}"

    PDV_PrismaBridge.SendOverlayJson(payload)
EndFunction

String Function BuildBookOfDaysPathInfo(Int originRace)
    return Manager.OriginRuntime.GetOriginRaceLabel(originRace) + " - " + GetBookOfDaysPathStatusLabel(originRace)
EndFunction

String Function GetBookOfDaysPathStatusLabel(Int originRace)
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Path Not Yet Chosen"
    endIf

    if originRace == Manager.ORIGIN_BRETON
        return Manager.OriginRuntime.GetBretonBookOfDaysPathStatusLabel()
    endIf

    PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return GetCanonicalDeityDisplayName(activePact) + " Pact"
    endIf

    if Manager.GetActiveDeity() && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE
        return GetPublicDeityDisplayName(Manager.GetActiveDeity())
    endIf

    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        return Manager.OriginRuntime.GetBroadLaneDisplayName(originRace)
    endIf

    String pathLabel = Manager.OriginRuntime.GetBookOfDaysPathFallbackLabel()
    if pathLabel != ""
        return pathLabel
    endIf
    return "Path Unsettled"
EndFunction

String Function BuildBookOfDaysSummary(Int originRace)
    String summary = Manager.OriginRuntime.GetBookOfDaysSummary()
    if summary != ""
        return summary
    endIf
    return "Faith, conduct, and consequence leave their marks here."
EndFunction

PDV_DeityBase Function ResolveBookOfDaysStandingDeity()
    PDV_DaedricPathBase journalPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if journalPact
        return journalPact
    endIf

    if Manager.GetActiveDeity()
        return Manager.GetActiveDeity()
    endIf

    return StorageUtil.GetFormValue(None, "PDV.BookOfDays.LastTierDeity") as PDV_DeityBase
EndFunction

String Function BuildBookOfDaysInstrumentJson(Int originRace)
    Int tierValue = 0
    Float pietyValue = 0.0
    Float championThreshold = 85.0
    Int bretonPracticeTier = Manager.LedgerRuntime.TIER_NONE
    if originRace == Manager.ORIGIN_BRETON
        bretonPracticeTier = Manager.OriginRuntime.GetBretonPracticeTier(Manager.OriginRuntime.GetBretonTraditionValue())
    endIf
    if Manager.LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = Manager.LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf
    if Manager.LedgerRuntime.PDV_GLO_ActivePiety
        pietyValue = Manager.LedgerRuntime.PDV_GLO_ActivePiety.GetValue()
    endIf

    PDV_DeityBase journalCommitment = ResolveBookOfDaysStandingDeity()
    if Manager.LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || originRace == Manager.ORIGIN_ARGONIAN
        ; A remembered prior deity must not hide the active broad pool.
        journalCommitment = None
    endIf
    if journalCommitment
        championThreshold = journalCommitment.ThresholdChampion
        tierValue = Manager.LedgerRuntime.GetTier(journalCommitment)
        pietyValue = Manager.LedgerRuntime.GetPiety(journalCommitment)
        if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
            tierValue = Manager.LedgerRuntime.TIER_NONE
        endIf
    elseIf originRace == Manager.ORIGIN_BRETON
        if bretonPracticeTier > Manager.LedgerRuntime.TIER_NONE
            tierValue = bretonPracticeTier
            pietyValue = Manager.OriginRuntime.GetBretonPracticeCount(Manager.OriginRuntime.GetBretonTraditionValue()) as Float
        endIf
    elseIf originRace == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        tierValue = Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier()
        pietyValue = Manager.PDV_ArgonianHistSubstrate.GetMetric()
        championThreshold = 75.0
    else
        Int broadTier = Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace)
        if Manager.LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || broadTier > Manager.LedgerRuntime.TIER_NONE
            tierValue = broadTier
            pietyValue = Manager.OriginRuntime.GetBroadLaneStandingValue(originRace)
        endIf
    endIf

    String tierLabel = GetCurrentStandingLabel()
    if journalCommitment == None && originRace == Manager.ORIGIN_BRETON && bretonPracticeTier > Manager.LedgerRuntime.TIER_NONE
        tierLabel = GetPublicTierBand(bretonPracticeTier)
    elseIf journalCommitment == None && originRace == Manager.ORIGIN_ARGONIAN
        tierLabel = Manager.OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf journalCommitment == None && (Manager.LedgerRuntime.IsPantheonBroadPoolPresentationActive(originRace) || Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace) > Manager.LedgerRuntime.TIER_NONE)
        tierLabel = Manager.OriginRuntime.GetBroadLaneStandingLabel(originRace, Manager.OriginRuntime.GetBroadLaneTierForOrigin(originRace))
    elseIf journalCommitment && Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        tierLabel = "Wavering"
    endIf
    return GetPanelInstrumentJson(originRace, journalCommitment != None, tierValue, tierLabel, pietyValue, championThreshold)
EndFunction

String Function BuildJournalPayloadJson()
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    Int titleCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
    Int magnitudeCount = StorageUtil.IntListCount(None, "PDV.Diegetic.Journal.Magnitudes")
    Int sourceCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources")
    Int keyCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Keys")
    String entries = ""
    Int i = 0
    while i < count
        String line = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", i))
        Int gameDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        String tone = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", i))
        String symbol = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Symbols", i))
        String fictionDate = PDV_DevotionRules.JsonSafeString(PDV_DevotionRules.JournalDayToFictionDate(gameDay))
        String entryTitle = ""
        if i < titleCount
            entryTitle = StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Titles", i)
        endIf
        if entryTitle == ""
            entryTitle = JournalToneToTitle(tone)
        endIf
        entryTitle = PDV_DevotionRules.JsonSafeString(entryTitle)
        Int magnitude = GetJournalMagnitudeForTone(tone)
        if i < magnitudeCount
            magnitude = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Magnitudes", i)
        endIf
        String valence = JournalToneToValence(tone)
        String entry = "{\"date\":\"" + fictionDate + "\""
        entry = entry + ",\"day\":" + gameDay
        entry = entry + ",\"symbol\":\"" + symbol + "\""
        entry = entry + ",\"tone\":\"" + tone + "\""
        entry = entry + ",\"valence\":\"" + valence + "\""
        entry = entry + ",\"magnitude\":" + magnitude
        entry = entry + ",\"title\":\"" + entryTitle + "\""
        if i < keyCount
            String entryKey = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Keys", i))
            if entryKey != ""
                entry = entry + ",\"eventKey\":\"" + entryKey + "\""
            endIf
        endIf
        if i < sourceCount
            String sourceText = PDV_DevotionRules.JsonSafeString(StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Sources", i))
            if sourceText != ""
                entry = entry + ",\"source\":\"" + sourceText + "\""
            endIf
        endIf
        entry = entry + ",\"text\":\"" + line + "\"}"
        if i > 0
            entries = entries + ","
        endIf
        entries = entries + entry
        i += 1
    endWhile
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    String pathInfo = BuildBookOfDaysPathInfo(originRace)
    String j = "{\"mode\":\"journal\",\"journal\":{"
    j = j + "\"title\":\"Book of Days\""
    j = j + ",\"by\":\"" + PDV_DevotionRules.JsonSafeString(GetJournalByline()) + "\""
    j = j + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(BuildBookOfDaysSummary(originRace)) + "\""
    j = j + ",\"survey\":\"" + PDV_DevotionRules.JsonSafeString(pathInfo) + "\""
    j = j + ",\"foot\":\"Press your Book of Days key again to close.\""
    j = j + ",\"instrument\":" + BuildBookOfDaysInstrumentJson(originRace)
    j = j + ",\"culture\":" + BuildJournalCultureJson(originRace)
    j = j + ",\"entries\":[" + entries + "]"
    j = j + "}}"
    return j
EndFunction

String Function BuildJournalCultureJson(Int originRace)
    {Culture-lane gauge for the Book of Days header: the race's cultural practice
    measured against fixed, race-appropriate points. Independent of the deity
    instrument -- a patron does not hide the culture lane. Labels reuse existing
    player-facing vocabulary only; empty object means nothing real to measure.}
    Float cultureValue = 0.0
    Float cultureMax = 75.0
    String pips = "1,25,75"
    String posture = ""
    if originRace == Manager.ORIGIN_NORD && Manager.PDV_NordAncestorSubstrate
        cultureValue = Manager.PDV_NordAncestorSubstrate.GetAncestorStanding()
        posture = Manager.OriginRuntime.GetNordAncestorLayerLabel()
    elseIf originRace == Manager.ORIGIN_IMPERIAL && Manager.PDV_ImperialAncestorSubstrate
        cultureValue = Manager.PDV_ImperialAncestorSubstrate.GetCivicStanding()
        posture = Manager.OriginRuntime.GetImperialCivicTierName()
    elseIf originRace == Manager.ORIGIN_ALTMER && Manager.PDV_AltmerAncestorSubstrate
        cultureValue = Manager.PDV_AltmerAncestorSubstrate.GetHeritageStanding()
        posture = Manager.OriginRuntime.GetAltmerHeritageTierName()
    elseIf originRace == Manager.ORIGIN_DUNMER && Manager.PDV_DunmerAncestorSubstrate
        cultureValue = Manager.PDV_DunmerAncestorSubstrate.GetMetric()
        posture = Manager.OriginRuntime.GetDunmerAncestorLayerLabel()
    elseIf originRace == Manager.ORIGIN_KHAJIIT && Manager.PDV_KhajiitLunarSubstrate
        cultureValue = Manager.PDV_KhajiitLunarSubstrate.GetMetric()
        posture = Manager.OriginRuntime.GetKhajiitLunarTierLabel(Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier())
    elseIf originRace == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        cultureValue = Manager.PDV_ArgonianHistSubstrate.GetMetric()
        posture = Manager.OriginRuntime.GetArgonianCulturalPracticeLabel()
    elseIf originRace == Manager.ORIGIN_BOSMER
        cultureValue = Manager.OriginRuntime.GetBosmerGreenPactCompliance() as Float
        cultureMax = 100.0
        pips = "20,50,80"
        posture = Manager.OriginRuntime.GetBosmerComplianceBand()
    elseIf originRace == Manager.ORIGIN_BRETON
        Int practiceCount = Manager.OriginRuntime.GetBretonPracticeCount(Manager.OriginRuntime.GetBretonTraditionValue())
        cultureValue = practiceCount as Float
        cultureMax = 85.0
        pips = "25,50"
        posture = GetPublicTierBand(Manager.OriginRuntime.GetBretonPracticeTier(Manager.OriginRuntime.GetBretonTraditionValue()))
    elseIf originRace == Manager.ORIGIN_ORC
        Float strongholdWeight = StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.Stronghold")
        Float cityWeight = StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.City")
        Float legionWeight = StorageUtil.GetFloatValue(None, "PDV.Orc.LifeMode.LegionExile")
        cultureValue = ComputeDominantShare(strongholdWeight, cityWeight, legionWeight)
        cultureMax = 100.0
        pips = ""
        posture = Manager.OriginRuntime.GetOrcLifeModeLabel()
    elseIf originRace == Manager.ORIGIN_REDGUARD
        Float crownWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Crown")
        Float forebearWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Forebear")
        Float ashabahWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.AshAbah")
        cultureValue = ComputeDominantShare(crownWeight, forebearWeight, ashabahWeight)
        cultureMax = 100.0
        pips = ""
        posture = Manager.OriginRuntime.GetRedguardSectLabel()
    endIf
    if posture == ""
        return "{}"
    endIf
    if cultureValue < 0.0
        cultureValue = 0.0
    elseIf cultureValue > cultureMax
        cultureValue = cultureMax
    endIf
    String j = "{\"posture\":\"" + PDV_DevotionRules.JsonSafeString(posture) + "\""
    j = j + ",\"value\":" + PDV_DevotionRules.FormatTwoDecimals(cultureValue)
    j = j + ",\"max\":" + PDV_DevotionRules.FormatTwoDecimals(cultureMax)
    j = j + ",\"pips\":[" + pips + "]"
    j = j + "}"
    return j
EndFunction

Float Function ComputeDominantShare(Float firstWeight, Float secondWeight, Float thirdWeight)
    {Share of the largest of three accumulating weights, as 0-100. Reads existing
    StorageUtil state only; zero total reads as zero commitment.}
    Float total = firstWeight + secondWeight + thirdWeight
    if total <= 0.0
        return 0.0
    endIf
    Float dominant = firstWeight
    if secondWeight > dominant
        dominant = secondWeight
    endIf
    if thirdWeight > dominant
        dominant = thirdWeight
    endIf
    return dominant / total * 100.0
EndFunction

Bool Function AppendBookOfDaysEntry(String line, Int gameDay, String tone, String symbol, Bool headlinePinned, Int magnitude = 1, String titleText = "", Bool allowDuringRaceSetup = False, String sourceText = "", String entryKey = "")
    if Manager.IsRaceSetupQuietPresentationActive() && !allowDuringRaceSetup
        return False
    endIf
    if line == ""
        return False
    endIf
    line = Manager.NormalizePublicDeityDisplayText(line)
    if tone == ""
        tone = "substrate.act"
    endIf
    if symbol == ""
        symbol = "journal"
    endIf
    sourceText = Manager.NormalizePublicDeityDisplayText(sourceText)

    ; Existing development saves predate event keys. Pad the parallel list before
    ; reading or appending so a key can never attach to an older journal line.
    Int count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Keys") < count
        StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Keys", "", True)
    endWhile

    ; Keyed entries deduplicate by event identity. Unkeyed callers retain the old
    ; newest-entry content guard.
    if entryKey != ""
        Int keyIndex = 0
        while keyIndex < count
            if StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Keys", keyIndex) == entryKey
                return False
            endIf
            keyIndex += 1
        endWhile
    elseIf count > 0
        Int last = count - 1
        if StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", last) == gameDay && StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Tones", last) == tone && StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Lines", last) == line
            return False
        endIf
    endIf

    ; Existing saves predate the optional source list. Pad it before adding a new
    ; entry so a patch label can never attach to an older journal line.
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources") < count
        StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Sources", "", True)
    endWhile

    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Lines", line, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Days", gameDay, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Tones", tone, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Symbols", symbol, True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Pinned", PDV_DevotionRules.BoolToInt(headlinePinned), True)
    StorageUtil.IntListAdd(None, "PDV.Diegetic.Journal.Magnitudes", PDV_DevotionRules.ClampInt(magnitude, 1, 3), True)
    if titleText == ""
        titleText = BuildJournalEventTitle(tone, "")
    endIf
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Titles", titleText, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Sources", sourceText, True)
    StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Keys", entryKey, True)

    PruneBookOfDays()
    return True
EndFunction

Bool Function AppendTierMilestoneEntry(PDV_DeityBase deity, Int tier, String entryKey)
    String surfaceKey = ""
    String line = ""
    if !deity || tier <= Manager.LedgerRuntime.TIER_NONE || entryKey == ""
        return False
    endIf
    surfaceKey = GetCanonicalDeityDisplayName(deity) + " " + GetTierStandingLabel(tier)
    line = BuildTierReachJournalLine(surfaceKey, deity.DeityIndex)
    return AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "tier.reach", GetPrismaSymbolForDeity(deity), tier >= Manager.LedgerRuntime.TIER_CHAMPION, GetJournalMagnitudeForTone("tier.reach"), BuildJournalEventTitle("tier.reach", ""), False, "", entryKey)
EndFunction

Bool Function RemoveBookOfDaysEntryByKey(String entryKey)
    Int count = 0
    Int i = 0
    Bool removed = False
    if entryKey == ""
        return False
    endIf
    count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Keys") < count
        StorageUtil.StringListAdd(None, "PDV.Diegetic.Journal.Keys", "", True)
    endWhile
    i = count - 1
    while i >= 0
        if StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Keys", i) == entryKey
            RemoveBookOfDaysEntryAt(i)
            removed = True
        endIf
        i -= 1
    endWhile
    return removed
EndFunction

Bool Function HasBookOfDaysEntryKey(String entryKey)
    Int count = 0
    Int keyCount = 0
    Int i = 0
    if entryKey == ""
        return False
    endIf
    count = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines")
    keyCount = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Keys")
    while i < count && i < keyCount
        if StorageUtil.StringListGet(None, "PDV.Diegetic.Journal.Keys", i) == entryKey
            return True
        endIf
        i += 1
    endWhile
    return False
EndFunction

String Function GetCanonicalDeityDisplayName(PDV_DeityBase deity)
    if !deity
        return ""
    endIf

    PDV_DaedricPathBase daedricPath = deity as PDV_DaedricPathBase
    if daedricPath
        return NormalizeExternalDeityText(Manager.DaedricRuntime.CanonicalDaedricPathName(daedricPath))
    endIf

    ; DeityIndex is a persistence/routing identifier, not a dense display-name
    ; ordinal (for example, the shared Azurah record is index 40). Resolve the
    ; bound form instead so display identity cannot drift when indices change.
    if deity == Manager.PDV_Kyne
        return NormalizeExternalDeityText("Kyne")
    elseIf deity == Manager.PDV_Talos
        return NormalizeExternalDeityText("Talos")
    elseIf deity == Manager.PDV_Yffre
        return NormalizeExternalDeityText("Y'ffre")
    elseIf deity == Manager.LedgerRuntime.PDV_Zen
        return NormalizeExternalDeityText("Z'en")
    elseIf deity == Manager.PDV_BaanDar
        return NormalizeExternalDeityText("Baan Dar")
    elseIf deity == Manager.PDV_Azura
        return NormalizeExternalDeityText("Azurah")
    elseIf deity == Manager.PDV_Khenarthi
        return NormalizeExternalDeityText("Khenarthi")
    elseIf deity == Manager.PDV_Rajhin
        return NormalizeExternalDeityText("Rajhin")
    elseIf deity == Manager.PDV_Alkosh
        return NormalizeExternalDeityText("Alkosh")
    elseIf deity == Manager.PDV_Boethiah
        return NormalizeExternalDeityText("Boethiah")
    elseIf deity == Manager.PDV_Mephala
        return NormalizeExternalDeityText("Mephala")
    elseIf deity == Manager.PDV_Hist
        return NormalizeExternalDeityText("The Hist")
    elseIf deity == Manager.PDV_Sithis
        return NormalizeExternalDeityText("Sithis")
    elseIf deity == Manager.PDV_Malacath
        return NormalizeExternalDeityText("Malacath")
    elseIf deity == Manager.PDV_Trinimac
        return NormalizeExternalDeityText("Trinimac")
    elseIf deity == Manager.PDV_Tuwhacca
        return NormalizeExternalDeityText("Tu'whacca")
    elseIf deity == Manager.PDV_HoonDing
        return NormalizeExternalDeityText("HoonDing")
    elseIf deity == Manager.PDV_Leki
        return NormalizeExternalDeityText("Leki")
    elseIf deity == Manager.PDV_Shor
        return NormalizeExternalDeityText("Shor")
    elseIf deity == Manager.PDV_Tsun
        return NormalizeExternalDeityText("Tsun")
    elseIf deity == Manager.PDV_Stuhn
        return NormalizeExternalDeityText("Stuhn")
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return NormalizeExternalDeityText("Akatosh")
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return NormalizeExternalDeityText("Mara")
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return NormalizeExternalDeityText("Arkay")
    elseIf deity == Manager.LedgerRuntime.PDV_Stendarr
        return NormalizeExternalDeityText("Stendarr")
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return NormalizeExternalDeityText("Zenithar")
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return NormalizeExternalDeityText("Dibella")
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return NormalizeExternalDeityText("Julianos")
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return NormalizeExternalDeityText("Kynareth")
    elseIf deity == Manager.PDV_AuriEl
        return NormalizeExternalDeityText("Auri-El")
    elseIf deity == Manager.PDV_Magnus
        return NormalizeExternalDeityText("Magnus")
    elseIf deity == Manager.PDV_Xarxes
        return NormalizeExternalDeityText("Xarxes")
    elseIf deity == Manager.PDV_Syrabane
        return NormalizeExternalDeityText("Syrabane")
    endIf
    ; A saved quest instance may retain an older property binding even after the
    ; current plugin record is corrected. The raw VMAD name is still a valid
    ; identity, so pass it through the exhaustive display normalizer instead of
    ; leaking its saved casing or reporting a false unknown.
    return NormalizeExternalDeityText(deity.DeityName)
EndFunction

String Function NormalizeExternalDeityText(String sourceText)
    return Manager.NormalizeExternalDeityDisplayText(sourceText)
EndFunction

String Function GetPublicDeityDisplayName(PDV_DeityBase deity)
    return GetCanonicalDeityDisplayName(deity)
EndFunction

Function PruneBookOfDays()
    Int windowDays = 21
    Int hardCeiling = 60
    Int now = Utility.GetCurrentGameTime() as Int

    Int i = StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines") - 1
    while i >= 0
        Int entryDay = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Days", i)
        Int pinned = StorageUtil.IntListGet(None, "PDV.Diegetic.Journal.Pinned", i)
        if pinned == 0 && (now - entryDay) >= windowDays
            RemoveBookOfDaysEntryAt(i)
        endIf
        i -= 1
    endWhile

    ; Hard ceiling backstop (includes pinned): drop oldest until within the cap.
    while StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Lines") > hardCeiling
        RemoveBookOfDaysEntryAt(0)
    endWhile
EndFunction

Function RemoveBookOfDaysEntryAt(Int index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Lines", index)
    StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Days", index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Tones", index)
    StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Symbols", index)
    StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Pinned", index)
    if index < StorageUtil.IntListCount(None, "PDV.Diegetic.Journal.Magnitudes")
        StorageUtil.IntListRemoveAt(None, "PDV.Diegetic.Journal.Magnitudes", index)
    endIf
    if index < StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Titles")
        StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Titles", index)
    endIf
    if index < StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Sources")
        StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Sources", index)
    endIf
    if index < StorageUtil.StringListCount(None, "PDV.Diegetic.Journal.Keys")
        StorageUtil.StringListRemoveAt(None, "PDV.Diegetic.Journal.Keys", index)
    endIf
EndFunction

String Function GetJournalByline()
    PDV_DaedricPathBase pact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if pact
        return "kept by the terms of the pact"
    endIf
    if Manager.GetActiveDeity()
        return "kept for " + GetPublicDeityDisplayName(Manager.GetActiveDeity())
    endIf
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_KHAJIIT
        return "kept beneath the moons"
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        return "kept within the Hist"
    elseIf originRace == Manager.ORIGIN_DUNMER
        return "kept among the ancestors"
    endIf
    return "a record kept since the path began"
EndFunction

String Function BuildJournalEventTitle(String toneKey, String fallbackTitle)
    if fallbackTitle != ""
        return fallbackTitle
    endIf
    return JournalToneToTitle(toneKey)
EndFunction

Int Function GetJournalMagnitudeForTone(String toneKey)
    if toneKey == "tier.reach"
        return 3
    endIf
    if toneKey == "curse.onset" || toneKey == "curse.cure"
        return 3
    endIf
    if toneKey == "reorientation"
        return 3
    endIf
    if toneKey == "offer.accept" || toneKey == "offer.refuse"
        return 3
    endIf
    if toneKey == "neglect.drop" || toneKey == "neglect.recover"
        return 2
    endIf
    if toneKey == "creed.drop"
        return 2
    endIf
    if toneKey == "dawn.digest"
        return 2
    endIf
    return 1
EndFunction

String Function JournalToneToTitle(String toneKey)
    if toneKey == "tier.reach"
        return "Favor deepened"
    endIf
    if toneKey == "curse.onset"
        return "A shadow falls"
    endIf
    if toneKey == "curse.cure"
        return "The curse lifts"
    endIf
    if toneKey == "crisis.onset"
        return "Auri-El's path is shaken"
    endIf
    if toneKey == "crisis.resolve"
        return "Auri-El's path holds"
    endIf
    if toneKey == "neglect.drop"
        return "Silence grows"
    endIf
    if toneKey == "neglect.recover"
        return "Return to the path"
    endIf
    if toneKey == "creed.drop"
        return "Creed broken"
    endIf
    if toneKey == "emergence.onset"
        return "An emergence"
    endIf
    if toneKey == "offer.accept"
        return "Patron accepted"
    endIf
    if toneKey == "offer.refuse"
        return "Offer refused"
    endIf
    if toneKey == "substrate.act"
        return "An act of devotion"
    endIf
    if toneKey == "favor.act"
        return "Prayer answered"
    endIf
    if toneKey == "focus.emergence"
        return "A road emerges"
    endIf
    if toneKey == "champion.act"
        return "A champion's gift"
    endIf
    if toneKey == "favor.loss"
        return "A deed ill-received"
    endIf
    if toneKey == "reorientation"
        return "A turning"
    endIf
    if toneKey == "dawn.digest"
        return "The day's reckoning"
    endIf
    if toneKey == "daedric.pressure"
        return "A Prince watches"
    endIf
    return "A moment noted"
EndFunction

String Function JournalToneToValence(String toneKey)
    if toneKey == "tier.reach"
        return "good"
    endIf
    if toneKey == "curse.cure"
        return "good"
    endIf
    if toneKey == "crisis.resolve"
        return "good"
    endIf
    if toneKey == "neglect.recover"
        return "good"
    endIf
    if toneKey == "emergence.onset"
        return "good"
    endIf
    if toneKey == "offer.accept"
        return "good"
    endIf
    if toneKey == "substrate.act"
        return "good"
    endIf
    if toneKey == "favor.act"
        return "good"
    endIf
    if toneKey == "focus.emergence"
        return "good"
    endIf
    if toneKey == "champion.act"
        return "good"
    endIf
    if toneKey == "favor.loss"
        return "warning"
    endIf
    if toneKey == "curse.onset"
        return "warning"
    endIf
    if toneKey == "crisis.onset"
        return "warning"
    endIf
    if toneKey == "neglect.drop"
        return "warning"
    endIf
    if toneKey == "creed.drop"
        return "warning"
    endIf
    if toneKey == "daedric.pressure"
        return "warning"
    endIf
    if toneKey == "offer.refuse"
        return "warning"
    endIf
    if toneKey == "reorientation"
        return "neutral"
    endIf
    if toneKey == "dawn.digest"
        return "neutral"
    endIf
    return "neutral"
EndFunction

Function SendPrismaJournalPayload(Bool playerRequested = false)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    ; AllowPrismaBlockingSurfaces gates GAMEPLAY auto-push (default off). A player-pressed
    ; hotkey passes playerRequested=true to bypass that gate -- it is player-owned, not auto-push.
    if !AllowPrismaBlockingSurfaces && !playerRequested
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson(BuildJournalPayloadJson())
EndFunction

Function ClosePrismaJournal()
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    if !PDV_PrismaBridge.IsAvailable()
        return
    endIf
    PDV_PrismaBridge.SendOverlayJson("{\"journalClose\":true}")
EndFunction

Bool Function SelectMedallionEntry(String optionId)
    Manager.Trace(1, "Medallion selection blocked for " + optionId + "; roster display is offer-only.")
    return False
EndFunction

Bool Function CanSelectMedallionEntry(String optionId)
    return False
EndFunction

String Function GetActiveMedallionOptionId()
    if !Manager.GetActiveDeity()
        return ""
    endIf

    return GetMedallionOptionIdForDeity(Manager.GetActiveDeity())
EndFunction

String Function PendingMedallionEntry(String optionId, String titleText, String kindText, String symbolName, String summaryText)
    String descriptionText = titleText + " belongs in this native roster, but is not yet a live scoring patron."
    String disabledText = "Awaiting live deity record and scoring path."
    if kindText == "prince"
        descriptionText = titleText + " belongs in this native roster, but is not yet a live Prince path."
        disabledText = "Awaiting live Prince path and scoring route."
    elseIf kindText == "substrate"
        descriptionText = titleText + " is live as a cultural substrate, but not yet as a selectable medallion patron."
        disabledText = "Awaiting medallion-safe substrate selection."
    endIf

    return MedallionEntry(optionId, titleText, kindText, symbolName, None, False, summaryText, descriptionText, disabledText)
EndFunction

String Function RosterMedallionEntry(String optionId, String titleText, String kindText, String symbolName, PDV_DeityBase deity, String summaryText)
    if deity && IsMedallionDeitySelectable(deity)
        String liveDesc = titleText + " is a living patron your people can name."
        String liveHint = "Build devotion and this god offers to take you as their own."
        return MedallionEntry(optionId, titleText, kindText, symbolName, deity, False, summaryText, liveDesc, liveHint)
    endIf
    return PendingMedallionEntry(optionId, titleText, kindText, symbolName, summaryText)
EndFunction

String Function MedallionEntry(String optionId, String titleText, String kindText, String symbolName, PDV_DeityBase deity, Bool requestedSelectable, String summaryText, String descriptionText, String disabledReason)
    Bool selectable = requestedSelectable && IsMedallionDeitySelectable(deity)
    String disabledText = disabledReason
    if !selectable && disabledText == ""
        disabledText = "Awaiting live deity record and scoring path."
    endIf

    String entry = "{\"option_id\":\"" + PDV_DevotionRules.JsonSafeString(optionId) + "\""
    entry = entry + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    entry = entry + ",\"kind\":\"" + PDV_DevotionRules.JsonSafeString(kindText) + "\""
    entry = entry + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    entry = entry + ",\"visible\":true"
    entry = entry + ",\"selectable\":" + PDV_DevotionRules.BoolToJson(selectable)
    entry = entry + ",\"summary\":\"" + PDV_DevotionRules.JsonSafeString(summaryText) + "\""
    entry = entry + ",\"description\":\"" + PDV_DevotionRules.JsonSafeString(descriptionText) + "\""
    if disabledText != ""
        entry = entry + ",\"disabled_reason\":\"" + PDV_DevotionRules.JsonSafeString(disabledText) + "\""
    endIf
    entry = entry + "}"
    return entry
EndFunction

Bool Function IsMedallionDeitySelectable(PDV_DeityBase deity)
    if !deity || !Manager.LedgerRuntime.PDV_FLST_AllDeities
        return False
    endIf

    Int i = 0
    Int count = Manager.LedgerRuntime.PDV_FLST_AllDeities.GetSize()
    while i < count
        if (Manager.LedgerRuntime.PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase) == deity
            return True
        endIf
        i += 1
    endWhile

    return False
EndFunction

PDV_DeityBase Function GetMedallionDeityForOptionId(String optionId)
    if optionId == "kyne"
        return Manager.PDV_Kyne
    elseIf optionId == "kynareth"
        return Manager.LedgerRuntime.PDV_Kynareth
    elseIf optionId == "talos"
        return Manager.PDV_Talos
    elseIf optionId == "auri-el"
        return Manager.LedgerRuntime.GetDeityByName("Auri-El")
    elseIf optionId == "yffre"
        return Manager.PDV_Yffre
    elseIf optionId == "zen"
        return Manager.LedgerRuntime.PDV_Zen
    elseIf optionId == "baan-dar"
        return Manager.PDV_BaanDar
    endIf

    return None
EndFunction

String Function GetMedallionOptionIdForDeity(PDV_DeityBase deity)
    if deity == Manager.PDV_Kyne
        return "kyne"
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return "kynareth"
    elseIf deity == Manager.PDV_Talos
        return "talos"
    elseIf deity == Manager.PDV_Yffre
        return "yffre"
    elseIf deity == Manager.LedgerRuntime.PDV_Zen
        return "zen"
    elseIf deity == Manager.PDV_BaanDar
        return "baan-dar"
    elseIf deity && deity.DeityName == "Auri-El"
        return "auri-el"
    endIf

    return ""
EndFunction

Bool Function IsMedallionOptionAvailableForOrigin(String optionId, Int originRace)
    if optionId == "kyne"
        return originRace == Manager.ORIGIN_NORD
    elseIf optionId == "kynareth"
        return originRace == Manager.ORIGIN_NORD || originRace == Manager.ORIGIN_IMPERIAL || originRace == Manager.ORIGIN_BRETON
    elseIf optionId == "talos"
        return originRace == Manager.ORIGIN_NORD || originRace == Manager.ORIGIN_BRETON
    elseIf optionId == "auri-el"
        return originRace == Manager.ORIGIN_ALTMER || originRace == Manager.ORIGIN_BOSMER
    elseIf optionId == "yffre"
        return originRace == Manager.ORIGIN_BRETON || originRace == Manager.ORIGIN_ALTMER || originRace == Manager.ORIGIN_BOSMER
    elseIf optionId == "zen"
        return originRace == Manager.ORIGIN_BOSMER
    elseIf optionId == "baan-dar"
        return originRace == Manager.ORIGIN_BOSMER || originRace == Manager.ORIGIN_KHAJIIT
    endIf

    return False
EndFunction

Function EnsureSurveyDevotionPower()
    if !PDV_SPEL_SurveyDevotion
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    if !playerRef.HasSpell(PDV_SPEL_SurveyDevotion)
        playerRef.AddSpell(PDV_SPEL_SurveyDevotion, False)
    endIf

EndFunction

String Function OnOffForReport(Int v)
    if v != 0
        return "On"
    endIf
    return "Off"
EndFunction

String Function GetExperienceModeLabelForReport()
    if Manager.LedgerRuntime.PDV_ModePresetRef
        return Manager.LedgerRuntime.PDV_ModePresetRef.GetModeLabel()
    endIf
    return "Pilgrim's Path"
EndFunction

String Function PendingFormLabelForReport(String storageKey)
    if StorageUtil.GetFormValue(None, storageKey) != None
        return "set"
    endIf
    return "none"
EndFunction

String Function ExportDevotionReport()
    String nl = "\n"
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    Float gameDay = Utility.GetCurrentGameTime()

    String report = "=== Devotion Bug Report Snapshot ==="
    report = report + nl + "Generated in-game. Attach this file to your report."
    report = report + nl
    report = report + nl + "-- Versions --"
    report = report + nl + "Devotion build: " + Manager.PDV_BUILD_VERSION
    report = report + nl + "Framework schema: " + Manager.FRAMEWORK_SCHEMA_VERSION
    report = report + nl + "Likes/dislikes: " + Manager.LedgerRuntime.LIKES_DISLIKES_VERSION
    report = report + nl + "Prince LD: " + Manager.PRINCE_LD_VERSION
    report = report + nl + "Daedric pact: " + Manager.DAEDRIC_PACT_VERSION
    report = report + nl + "PapyrusUtil: " + PapyrusUtil.GetVersion()
    report = report + nl + "In-game day: " + (gameDay as Int)
    report = report + nl
    report = report + nl + "-- Environment --"
    report = report + nl + "Experience Mode: " + GetExperienceModeLabelForReport()
    report = report + nl + "Custom race mapping: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.CustomRaceMapping", 1))
    report = report + nl + "Origin detect: " + Manager.DebugRuntime.DebugGetOriginDiagnostic()
    report = report + nl + "Survival integration: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.SurvivalContextEnabled", 1))
    report = report + nl + "CC integration: " + OnOffForReport(StorageUtil.GetIntValue(None, "PDV.Compat.CCContentEnabled", 1))
    report = report + nl
    report = report + nl + "-- Summary --"
    report = report + nl + "Race: " + Manager.OriginRuntime.GetOriginRaceLabel(originRace) + " (index " + originRace + ")"
    report = report + nl + "Summary: " + GetPlayerMcmSummaryLine()
    report = report + nl + "Mode: " + GetPlayerMcmModeLine()
    report = report + nl + "Patron: " + GetPlayerMcmPatronLine() + " | state " + Manager.LedgerRuntime.GetPatronState() + " | activeIndex " + Manager.LedgerRuntime.GetActiveDeityIndex()
    report = report + nl + "Standing: " + GetPlayerMcmStandingLine()
    report = report + nl + "Curse: " + GetPlayerMcmCurseLine()
    report = report + nl + "Favor: " + Manager.FavorRuntime.GetPlayerMcmFavorLine()
    report = report + nl + "Neglect: " + Manager.LedgerRuntime.GetPlayerMcmNeglectLine()
    report = report + nl + "Startup: " + Manager.GetStartupMcmLine()
    report = report + nl
    report = report + nl + "-- Survey readout --"
    report = report + nl + GetSurveyDevotionText()
    report = report + nl
    report = report + nl + "-- Per-deity ledger (tier: 0 None 1 Seeker 2 Devoted 3 Champion) --"
    report = report + nl + "deity [index] | tier | piety | scratch"

    Int count = Manager.LedgerRuntime.GetDeityCount()
    Int i = 0
    while i < count
        PDV_DeityBase deityEntry = Manager.LedgerRuntime.GetDeityAtListIndex(i)
        if deityEntry
            report = report + nl + deityEntry.DeityName + " [" + deityEntry.DeityIndex + "] | " + Manager.LedgerRuntime.GetTier(deityEntry) + " | " + Manager.LedgerRuntime.GetPiety(deityEntry) + " | +" + Manager.LedgerRuntime.GetPietyToday(deityEntry)
        endIf
        i += 1
    endWhile

    report = report + nl
    report = report + nl + "-- Diagnostics --"
    report = report + nl + "Breton tradition: " + StorageUtil.GetIntValue(None, "PDV.Breton.Tradition", -1)
    report = report + nl + "Daedric pending lapse: " + PendingFormLabelForReport("PDV.Daedric.PendingLapse")
    report = report + nl + "Daedric pending activation: " + PendingFormLabelForReport("PDV.Daedric.PendingActivation")
    report = report + nl + "Last diegetic dispatch: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastDispatch", "none")
    report = report + nl + "Last diegetic tone: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastTone", "none")
    report = report + nl + "Last diegetic skipped: " + StorageUtil.GetStringValue(None, "PDV.Diegetic.LastSkipped", "none")
    report = report + nl
    report = report + nl + "-- Logs (for deeper diagnosis) --"
    report = report + nl + "If asked, also attach the Papyrus log and any SKSE crash log:"
    report = report + nl + "Papyrus: Documents\\My Games\\Skyrim Special Edition\\Logs\\Script\\Papyrus.0.log"
    report = report + nl + "SKSE crash: Documents\\My Games\\Skyrim Special Edition\\SKSE\\crash-*.log"
    report = report + nl + "Papyrus logging is OFF by default; the beta guide explains how to turn it on."
    report = report + nl
    report = report + nl + "=== End of report ==="

    String fileName = "PDV_DevotionReport.txt"
    Bool wrote = MiscUtil.WriteToFile(fileName, report, False, False)
    ; D1 sweep. Gated like every other PDV trace. Nothing is lost by it: the function
    ; already returns the filename on success and "" on failure, which is what the MCM
    ; button surfaces to the user.
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] ExportDevotionReport wrote=" + wrote + " file=" + fileName)
    endIf
    if wrote
        return fileName
    endIf
    return ""
EndFunction

String Function GetSurveyDevotionText()
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace < 0
        return Manager.LedgerRuntime.AppendRecentDevotionEvents("Devotion has not settled yet. Wait a moment, then survey again.")
    endIf

    if originRace == Manager.ORIGIN_BRETON
        return Manager.LedgerRuntime.AppendRecentDevotionEvents(Manager.OriginRuntime.GetSurveyFragment())
    endIf

    PDV_DaedricPathBase pactPath = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        return Manager.LedgerRuntime.AppendRecentDevotionEvents(Manager.DaedricRuntime.GetDaedricSurveyText(pactPath))
    endIf

    String text = Manager.OriginRuntime.GetSurveyFragment()
    if text == ""
        text = "Your devotion is watched. Standing: " + GetCurrentStandingBand() + "."
    endIf
    String scarText = Manager.OriginRuntime.GetOriginDetailLabel("scar")
    if scarText != ""
        text = text + "\n\n" + scarText
    endIf
    return Manager.LedgerRuntime.AppendRecentDevotionEvents(text)
EndFunction

String Function GetPlayerMcmSummaryLine()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Startup pending | " + Manager.GetStartupMcmLine()
    endIf

    PDV_DaedricPathBase summaryPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if summaryPact
        return GetCanonicalDeityDisplayName(summaryPact) + " | Pact | " + GetCurrentStandingLabel()
    endIf

    String summary = Manager.OriginRuntime.GetMcmSummaryLine(GetCurrentStandingLabel())
    if summary != ""
        return summary
    endIf
    return Manager.OriginRuntime.GetOriginRaceLabel(Manager.GetPlayerOriginRaceIndex()) + " | " + Manager.LedgerRuntime.GetPatronStateLabel() + " | " + GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmPatronLine()
    ; An active Prince pact is the single commitment (patron severed under exclusivity);
    ; surface it here so the Prisma panel "patron" field matches the Survey.
    PDV_DaedricPathBase pactPath = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if pactPath
        return GetCanonicalDeityDisplayName(pactPath)
    endIf

    if Manager.GetActiveDeity()
        return GetPublicDeityDisplayName(Manager.GetActiveDeity())
    endIf

    return Manager.LedgerRuntime.GetPatronStateLabel()
EndFunction

String Function GetPlayerMcmStandingLine()
    return GetCurrentStandingLabel()
EndFunction

String Function GetPlayerMcmModeLine()
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return Manager.GetStartupMcmLine()
    endIf

    String modeLine = Manager.OriginRuntime.GetMcmModeLine()
    if modeLine != ""
        return modeLine
    endIf
    return Manager.LedgerRuntime.GetPatronStateLabel()
EndFunction

String Function GetPlayerMcmCurseLine()
    ; The Anvil MCM font renders a bare "None" value as effectively blank, so map
    ; the no-curse state to an explicit phrase. Surgical to the MCM display only;
    ; GetPlayerCursePublicLabel keeps returning "None" for its other callers.
    String curseLabel = Manager.OriginRuntime.GetPlayerCursePublicLabel()
    if curseLabel == "None"
        return "No curse"
    endIf
    return curseLabel
EndFunction

String Function GetFocusedStandingLabel(PDV_DeityBase deity)
    if !deity
        return "Unproven"
    endIf
    if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Wavering"
    endIf

    PDV_DaedricPathBase focusedPact = deity as PDV_DaedricPathBase
    if focusedPact
        return GetTierStandingLabel(focusedPact.GetStoredTier())
    endIf

    Float focusedPiety = Manager.LedgerRuntime.GetPiety(deity)
    if focusedPiety >= 85.0
        return "Champion"
    elseIf focusedPiety >= 50.0
        return "Devoted"
    endIf
    return "Wavering"
EndFunction

String Function GetPlayerStandingLabel()
    if Manager.OriginRuntime.IsFocusedPantheonBoonSuspended()
        return "Wavering"
    endIf
    Int tierValue = Manager.LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf Manager.GetActiveDeity()
        tierValue = Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity())
    elseIf Manager.OriginRuntime.GetBroadLaneTierForOrigin(Manager.GetPlayerOriginRaceIndex()) > Manager.LedgerRuntime.TIER_NONE
        tierValue = Manager.OriginRuntime.GetBroadLaneTierForOrigin(Manager.GetPlayerOriginRaceIndex())
    elseIf Manager.LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = Manager.LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf

    if !Manager.GetActiveDeity() && !standingPact && Manager.OriginRuntime.GetBroadLaneTierForOrigin(Manager.GetPlayerOriginRaceIndex()) > Manager.LedgerRuntime.TIER_NONE
        return Manager.OriginRuntime.GetBroadLaneStandingLabel(Manager.GetPlayerOriginRaceIndex(), tierValue)
    endIf

    PDV_DeityBase focusedDeity = Manager.GetActiveDeity()
    if standingPact
        focusedDeity = standingPact as PDV_DeityBase
    endIf
    if focusedDeity
        return GetFocusedStandingLabel(focusedDeity)
    endIf

    return "Unproven"
EndFunction

String Function GetCurrentStandingLabel()
    return GetPlayerStandingLabel()
EndFunction

String Function GetCurrentStandingBand()
    Int tierValue = Manager.LedgerRuntime.TIER_NONE
    PDV_DaedricPathBase standingPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if standingPact
        tierValue = standingPact.GetStoredTier()
    elseIf Manager.GetActiveDeity()
        tierValue = Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity())
    elseIf Manager.OriginRuntime.GetBroadLaneTierForOrigin(Manager.GetPlayerOriginRaceIndex()) > Manager.LedgerRuntime.TIER_NONE
        tierValue = Manager.OriginRuntime.GetBroadLaneTierForOrigin(Manager.GetPlayerOriginRaceIndex())
    elseIf Manager.LedgerRuntime.PDV_GLO_ActiveTier
        tierValue = Manager.LedgerRuntime.PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return GetBroadStandingBand(tierValue)
EndFunction

String Function GetPrismaSymbolForDeity(PDV_DeityBase deity)
    if !deity
        return "journal"
    endIf

    if deity == Manager.PDV_Kyne
        return "kyne"
    endIf

    if deity == Manager.PDV_Talos
        return "talos"
    endIf

    if deity.DeityName == "Auri-El"
        return "auri-el"
    endIf

    if deity.DeityName == "Y'ffre"
        return "yffre"
    endIf

    if deity.DeityName == "Z'en"
        return "zen"
    endIf

    if deity.DeityName == "Baan Dar"
        return "baan-dar"
    endIf

    if deity.DeityName == "Akatosh"
        return "akatosh"
    endIf

    if deity.DeityName == "Arkay"
        return "arkay"
    endIf

    if deity.DeityName == "Dibella"
        return "dibella"
    endIf

    if deity.DeityName == "Julianos"
        return "julianos"
    endIf

    if deity.DeityName == "Mara"
        return "mara"
    endIf

    if deity.DeityName == "Stendarr"
        return "stendarr"
    endIf

    if deity.DeityName == "Zenithar"
        return "zenithar"
    endIf

    ; --- Phase 2 all-race roster (Group 1: existing JS glyphs) ---
    if deity.DeityName == "Azura" || deity.DeityName == "Azurah"
        return "azura"
    endIf
    if deity.DeityName == "Malacath"
        return "malacath"
    endIf
    if deity.DeityName == "The Hist"
        return "hist"
    endIf

    ; --- Phase 2 all-race roster (Group 2: glyphs land via prisma-glyphs-phase2-deities) ---
    if deity.DeityName == "Shor"
        return "shor"
    endIf
    if deity.DeityName == "Tsun"
        return "tsun"
    endIf
    if deity.DeityName == "Stuhn"
        return "stuhn"
    endIf
    if deity.DeityName == "Kynareth"
        return "kynareth"
    endIf
    if deity.DeityName == "Magnus"
        return "magnus"
    endIf
    if deity.DeityName == "Xarxes"
        return "xarxes"
    endIf
    if deity.DeityName == "Trinimac"
        return "trinimac"
    endIf
    if deity.DeityName == "Syrabane"
        return "syrabane"
    endIf
    if deity.DeityName == "Phynaster"
        return "phynaster"
    endIf
    if deity.DeityName == "Khenarthi"
        return "khenarthi"
    endIf
    if deity.DeityName == "Rajhin"
        return "rajhin"
    endIf
    if deity.DeityName == "Alkosh"
        return "alkosh"
    endIf
    if deity.DeityName == "Sithis"
        return "sithis"
    endIf
    if deity.DeityName == "Tu'whacca"
        return "tuwhacca"
    endIf
    if deity.DeityName == "HoonDing"
        return "hoonding"
    endIf
    if deity.DeityName == "Leki"
        return "leki"
    endIf
    if deity.DeityName == "Boethiah"
        return "boethiah"
    endIf
    if deity.DeityName == "Mephala"
        return "mephala"
    endIf
    if deity.DeityName == "Hircine"
        return "hircine"
    endIf
    if deity.DeityName == "Azura"
        return "azura"
    endIf
    if deity.DeityName == "Molag Bal" || deity.DeityName == "Molag"
        return "molag-bal"
    endIf
    if deity.DeityName == "Mehrunes Dagon" || deity.DeityName == "Dagon"
        return "mehrunes-dagon"
    endIf
    if deity.DeityName == "Sheogorath" || deity.DeityName == "Sheo"
        return "sheogorath"
    endIf
    if deity.DeityName == "Clavicus Vile" || deity.DeityName == "Vile"
        return "clavicus-vile"
    endIf
    if deity.DeityName == "Hermaeus Mora" || deity.DeityName == "Mora"
        return "hermaeus-mora"
    endIf
    if deity.DeityName == "Meridia"
        return "meridia"
    endIf
    if deity.DeityName == "Vaermina"
        return "vaermina"
    endIf
    if deity.DeityName == "Namira"
        return "namira"
    endIf
    if deity.DeityName == "Sanguine"
        return "sanguine"
    endIf
    if deity.DeityName == "Nocturnal"
        return "nocturnal"
    endIf
    if deity.DeityName == "Peryite"
        return "peryite"
    endIf

    return "journal"
EndFunction
