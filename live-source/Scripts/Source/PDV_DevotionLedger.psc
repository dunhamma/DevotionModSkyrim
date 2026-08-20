Scriptname PDV_DevotionLedger extends Quest

; Devotion ledger runtime, extracted from PDV__ManagerQuest for the 2.0 rebuild
; (LEDGER module). Behavior parity: bodies are the manager originals; only bare
; manager-member references were qualified through the Manager backref (Manager.X),
; and manager script-variable reads/writes route through Manager getters/setters.
; INERT until the host QUST exists, Manager is filled, and the moved Auto props are
; filled in the batched houseCARL/CK session.

PDV__ManagerQuest Property Manager Auto

; The gain-modifier providers, assembled at runtime by the manager (see
; Manager.RefreshGainProviders). NOT an ESP fill: all ten origin adapter quests are
; start-game-enabled and running, but only ONE is bound to the player's race, so a static
; array would apply e.g. the Orc factor to a Nord. Empty/None is safe -- gains simply run
; unmultiplied by module factors.
PDV_GainModifierProvider[] _gainProviders

Function SetGainProviders(PDV_GainModifierProvider[] providers)
    _gainProviders = providers
EndFunction

; Product of every provider's factor for this phase. One scalar, one source -- award, dawn
; and decay all read it, so they cannot drift apart.
Float Function GetGainProviderProduct(PDV_DeityBase deity, Int phase)
    if !_gainProviders
        return 1.0
    endIf

    Float product = 1.0
    Int i = 0
    while i < _gainProviders.Length
        if _gainProviders[i]
            product = product * _gainProviders[i].GetProviderGainMultiplier(deity, phase)
        endIf
        i += 1
    endWhile

    return product
EndFunction

; --- moved properties (CK-filled later; AutoReadOnly consts move verbatim) ---
GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_PatronDeity Auto
GlobalVariable Property PDV_GLO_PatronState Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
PDV_ModePreset Property PDV_ModePresetRef Auto
FormList Property PDV_FLST_AllDeities Auto
Faction Property NecromancerFaction Auto
Faction Property WarlockFaction Auto
PDV_Deity_Zen Property PDV_Zen Auto
PDV_Deity_Akatosh Property PDV_Akatosh Auto
PDV_Deity_Mara Property PDV_Mara Auto
PDV_Deity_Arkay Property PDV_Arkay Auto
PDV_Deity_Stendarr Property PDV_Stendarr Auto
PDV_Deity_Zenithar Property PDV_Zenithar Auto
PDV_Deity_Dibella Property PDV_Dibella Auto
PDV_Deity_Julianos Property PDV_Julianos Auto
PDV_Deity_Kynareth Property PDV_Kynareth Auto
Spell Property PDV_SPEL_Neglect_Arkay Auto
Spell Property PDV_SPEL_Neglect_Dibella Auto
Spell Property PDV_SPEL_Disfavor_SkyStormHunt_Light Auto
Spell Property PDV_SPEL_Disfavor_SkyStormHunt_Sharp Auto
Spell Property PDV_SPEL_Disfavor_DeathAncestors_Light Auto
Spell Property PDV_SPEL_Disfavor_DeathAncestors_Sharp Auto
Spell Property PDV_SPEL_Disfavor_MercyProtection_Light Auto
Spell Property PDV_SPEL_Disfavor_MercyProtection_Sharp Auto
Spell Property PDV_SPEL_Disfavor_WarHonor_Light Auto
Spell Property PDV_SPEL_Disfavor_WarHonor_Sharp Auto
Spell Property PDV_SPEL_Disfavor_OrderTradeLore_Light Auto
Spell Property PDV_SPEL_Disfavor_OrderTradeLore_Sharp Auto
Spell Property PDV_SPEL_Disfavor_VoidSecrets_Light Auto
Spell Property PDV_SPEL_Disfavor_VoidSecrets_Sharp Auto
Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly
Int Property PATRON_STATE_UNSET = 0 AutoReadOnly
Int Property PATRON_STATE_BROAD = 1 AutoReadOnly
Int Property PATRON_STATE_ACTIVE = 2 AutoReadOnly
Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_DAILY_MAX_DELTA = 4.3 AutoReadOnly
Float Property DECAY_GRACE_DAYS = 2.0 AutoReadOnly
Float Property DECAY_PER_DAY = 0.5 AutoReadOnly
Float Property BROAD_WORSHIP_DECAY_MULTIPLIER = 0.2 AutoReadOnly
Float Property GAIN_RATE_SCALE = 1.32 AutoReadOnly
Int Property LIKES_DISLIKES_VERSION = 23 AutoReadOnly
Int Property DISFAVOR_DOMAIN_NONE = 0 AutoReadOnly
Int Property DISFAVOR_DOMAIN_SKY_STORM_HUNT = 1 AutoReadOnly
Int Property DISFAVOR_DOMAIN_DEATH_ANCESTORS = 2 AutoReadOnly
Int Property DISFAVOR_DOMAIN_MERCY_PROTECTION = 3 AutoReadOnly
Int Property DISFAVOR_DOMAIN_WAR_HONOR = 4 AutoReadOnly
Int Property DISFAVOR_DOMAIN_ORDER_TRADE_LORE = 5 AutoReadOnly
Int Property DISFAVOR_DOMAIN_MOON_LUCK_SHADOW = 6 AutoReadOnly
Int Property DISFAVOR_DOMAIN_VOID_SECRETS = 7 AutoReadOnly
Float Property DISFAVOR_LIGHT_MIN_DELTA = 0.5 AutoReadOnly
Float Property DISFAVOR_SHARP_MIN_DELTA = 1.0 AutoReadOnly
Float Property DISFAVOR_LIGHT_DURATION_DAYS = 0.0833333 AutoReadOnly
Float Property DISFAVOR_SHARP_DURATION_DAYS = 0.1666667 AutoReadOnly
Int Property DISFAVOR_MAX_ACTIVE_DOMAINS = 3 AutoReadOnly
Float Property TIER_DOWN_HYSTERESIS = 5.0 AutoReadOnly
Float Property LONG_DEVOTION_MARK_STEP = 15.0 AutoReadOnly
Int Property LONG_DEVOTION_MARK_MAX = 7 AutoReadOnly
Float Property NEGLECT_ACTIVE_PIETY_MAX = 10.0 AutoReadOnly
Int Property NEGLECT_ACTIVE_CAP = 3 AutoReadOnly
Float Property NEGLECT_LAPSE_GRACE_DAYS = 3.0 AutoReadOnly
Float Property COMMITMENT_OFFER_THRESHOLD = 50.0 AutoReadOnly
Float Property COMMITMENT_DECLINE_DELAY_DAYS = 1.0 AutoReadOnly
Float Property COMMITMENT_REFUSE_COOLDOWN_DAYS = 3.0 AutoReadOnly
Float Property COMMITMENT_CARRYOVER_MULTIPLIER = 1.0 AutoReadOnly
Float Property BROAD_PANTHEON_SEEKER_THRESHOLD = 25.0 AutoReadOnly
Float Property BROAD_PANTHEON_FAITHFUL_THRESHOLD = 50.0 AutoReadOnly
Float Property BROAD_PANTHEON_POOL_MAX = 50.0 AutoReadOnly
Float Property BROAD_PANTHEON_DECAY_GRACE_DAYS = 2.0 AutoReadOnly
Float Property BROAD_PANTHEON_DECAY_PER_DAWN = 0.1 AutoReadOnly
String Property BROAD_PANTHEON_IMPERIAL = "ImperialDivines" AutoReadOnly
String Property BROAD_PANTHEON_NORD_OLD = "NordOldWays" AutoReadOnly
String Property BROAD_PANTHEON_NORD_NINE = "NordNineDivines" AutoReadOnly
String Property COMPAT_SURVIVAL_TOGGLE_KEY = "PDV.Compat.SurvivalContextEnabled" AutoReadOnly
Float Property SURVIVAL_DAMP_PER_SEVERITY = 0.0267 AutoReadOnly
String Property COMPAT_CC_TOGGLE_KEY = "PDV.Compat.CCContentEnabled" AutoReadOnly

; --- moved script-scope variables (used only by moved logic) ---
Int _ldSurfEventType = -1
String _ldSurfPosNamesCsv = ""
String _ldSurfNegNamesCsv = ""
Int _ldSurfPosCount = 0
Int _ldSurfNegCount = 0
Float _ldSurfBestPosAmount = 0.0
Float _ldSurfBestNegAmount = 0.0
String _ldSurfBestPosName = ""
String _ldSurfBestNegName = ""
String _ldSurfBestPosSymbol = ""
String _ldSurfBestNegSymbol = ""
Int _broadPantheonEventDepth = 0
String _broadPantheonEventId = ""
Float _broadPantheonBestPositive = 0.0
Float _broadPantheonWorstNegative = 0.0
String _broadPantheonEventPool = ""
Int _pendingLikesDislikesEventType = -1
Bool _dawnRosterMissingLogged = false
Bool _pdvSurvivalContextInit = False
GlobalVariable _pdvSurvModeEnabled
GlobalVariable _pdvSurvHunger
GlobalVariable _pdvSurvCold
GlobalVariable _pdvSurvExhaustion
GlobalVariable _pdvSunHelmEnabled
GlobalVariable _pdvSunHelmHunger
GlobalVariable _pdvSunHelmThirst
GlobalVariable _pdvSunHelmCold
GlobalVariable _pdvSunHelmFatigue
Bool _pdvCCContentInit = False
Quest _pdvCCSaintsRestoringOrder
GlobalVariable _pdvCCFishingIsFishing
Int _pdvCCFishingLastFlag = 0

Function EnsureCanonicalDeityDisplayNames()
    Int repaired = 0
    repaired += RepairDeityRuntimeName(Manager.PDV_Kyne, "Kyne")
    repaired += RepairDeityRuntimeName(Manager.PDV_Talos, "Talos")
    repaired += RepairDeityRuntimeName(Manager.PDV_Yffre, "Y'ffre")
    repaired += RepairDeityRuntimeName(PDV_Zen, "Z'en")
    repaired += RepairDeityRuntimeName(Manager.PDV_BaanDar, "Baan Dar")
    repaired += RepairDeityRuntimeName(Manager.PDV_Azura, "Azura")
    repaired += RepairDeityRuntimeName(Manager.PDV_Khenarthi, "Khenarthi")
    repaired += RepairDeityRuntimeName(Manager.PDV_Rajhin, "Rajhin")
    repaired += RepairDeityRuntimeName(Manager.PDV_Alkosh, "Alkosh")
    repaired += RepairDeityRuntimeName(Manager.PDV_Boethiah, "Boethiah")
    repaired += RepairDeityRuntimeName(Manager.PDV_Mephala, "Mephala")
    repaired += RepairDeityRuntimeName(Manager.PDV_Hist, "The Hist")
    repaired += RepairDeityRuntimeName(Manager.PDV_Sithis, "Sithis")
    repaired += RepairDeityRuntimeName(Manager.PDV_Malacath, "Malacath")
    repaired += RepairDeityRuntimeName(Manager.PDV_Trinimac, "Trinimac")
    repaired += RepairDeityRuntimeName(Manager.PDV_Tuwhacca, "Tu'whacca")
    repaired += RepairDeityRuntimeName(Manager.PDV_HoonDing, "HoonDing")
    repaired += RepairDeityRuntimeName(Manager.PDV_Leki, "Leki")
    repaired += RepairDeityRuntimeName(Manager.PDV_Shor, "Shor")
    repaired += RepairDeityRuntimeName(Manager.PDV_Tsun, "Tsun")
    repaired += RepairDeityRuntimeName(Manager.PDV_Stuhn, "Stuhn")
    repaired += RepairDeityRuntimeName(PDV_Akatosh, "Akatosh")
    repaired += RepairDeityRuntimeName(PDV_Mara, "Mara")
    repaired += RepairDeityRuntimeName(PDV_Arkay, "Arkay")
    repaired += RepairDeityRuntimeName(PDV_Stendarr, "Stendarr")
    repaired += RepairDeityRuntimeName(PDV_Zenithar, "Zenithar")
    repaired += RepairDeityRuntimeName(PDV_Dibella, "Dibella")
    repaired += RepairDeityRuntimeName(PDV_Julianos, "Julianos")
    repaired += RepairDeityRuntimeName(PDV_Kynareth, "Kynareth")
    repaired += RepairDeityRuntimeName(Manager.PDV_AuriEl, "Auri-El")
    repaired += RepairDeityRuntimeName(Manager.PDV_Magnus, "Magnus")
    repaired += RepairDeityRuntimeName(Manager.PDV_Xarxes, "Xarxes")
    repaired += RepairDeityRuntimeName(Manager.PDV_Syrabane, "Syrabane")
    repaired += Manager.DaedricRuntime.RepairDaedricPathRuntimeNames()
    if repaired > 0 && Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Canonical deity display names repaired: " + repaired)
    endIf
EndFunction

Int Function RepairDeityRuntimeName(PDV_DeityBase deity, String canonicalName)
    if !deity || deity.DeityName == canonicalName
        return 0
    endIf
    deity.DeityName = canonicalName
    return 1
EndFunction

Function AwardPiety(PDV_DeityBase deity, Float amount, String reason = "")
    AwardPietyInternal(deity, amount, True, reason)
EndFunction

Float Function AwardPietyFromLikesDislikes(PDV_DeityBase deity, Float amount, Int eventType, String reason = "", Bool deferBroadPantheon = False, String detachedBroadPool = "")
    Bool ownsSurface = False
    if ShouldSurfaceLikesDislikesEvent(eventType) && _ldSurfEventType != eventType
        BeginLikesDislikesSurface(eventType)
        ownsSurface = True
    endIf

    Int previousEventType = _pendingLikesDislikesEventType
    _pendingLikesDislikesEventType = eventType
    Float appliedAmount = AwardPietyInternal(deity, amount, True, reason, True, !deferBroadPantheon)
    _pendingLikesDislikesEventType = previousEventType
    AccumulateLikesDislikesSurface(deity, amount, eventType)

    if ownsSurface
        FlushLikesDislikesSurface(eventType)
    endIf

    if deferBroadPantheon && appliedAmount != 0.0 && detachedBroadPool != "" && IsDeityEligibleForBroadPantheon(deity, detachedBroadPool)
        return appliedAmount
    endIf
    return 0.0
EndFunction

Function HandleBardPerformance(Int qualityDelta, Bool receivedOvation, Form contextForm)
    if !PDV_Dibella
        return
    endIf

    if qualityDelta < 1
        qualityDelta = 1
    elseIf qualityDelta > 8
        qualityDelta = 8
    endIf

    Float repeatMultiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BardPerformance")
    if repeatMultiplier <= 0.0
        Manager.Trace(2, "Bard performance decayed out for today; no Dibella award.")
        return
    endIf

    Float qualityMultiplier = 0.75 + (qualityDelta as Float * 0.125)
    if receivedOvation
        qualityMultiplier += 0.25
    endIf

    AwardCuratedSignalScaled(PDV_Dibella, PDV_Dibella.SIGNAL_PATRON_CIVIC_FAVOR, contextForm, repeatMultiplier * qualityMultiplier)
    Manager.Trace(2, "Bard performance routed quality=" + qualityDelta + " ovation=" + receivedOvation + " multiplier=" + (repeatMultiplier * qualityMultiplier))
EndFunction

Function ApplyDeityReaction(String deityName, String valence, String intensity, String magnitude, String sourceTag, Bool isFaucet, Form sourceForm)
    PDV_DeityBase deity = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionDeity(deityName)
    if !deity
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] QuestReaction skipped unknown deity: " + deityName)
        endIf
        return
    endIf

    Float amount = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionBaseValue(magnitude, intensity)
    if amount == 0.0
        return
    endIf

    if valence == "-"
        amount = amount * -1.0
    endIf

    if isFaucet && !Manager.PDV_QuestReactionRuntimeService.MarkQuestReactionFaucet(deityName, sourceTag, sourceForm)
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] QuestReaction faucet repeat blocked: " + deityName + " " + sourceTag)
        endIf
        return
    endIf

    String stance = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        StorageUtil.SetStringValue(None, "PDV.QuestReaction.LastCurse", deityName + "." + sourceTag)
        if Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive()
            Manager.PDV_QuestReactionRuntimeService.SetQrQueueNeedsCurseRefresh(True)
        else
            HandleCurseStateRefresh("quest_reaction_" + deityName)
        endIf
        if Manager.GetDebugLevel() >= 3 || (!Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive() && Manager.GetDebugLevel() >= 1)
            Debug.Trace("[PDV] QuestReaction curse routed: " + deityName + " " + sourceTag)
        endIf
        return
    endIf

    if stance == "TABOO" || stance == "HOSTILE"
        ; Preserve authored taboo/hostile displeasure for a god whose face
        ; remains in the origin roster, even when it is outside the Nord's
        ; selected baseline. Positive values become stigma; background favor
        ; from ordinary native/foreign cells never crosses that lane.
        if !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(deity) && !Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, Manager.GetPlayerOriginRaceIndex())
            if Manager.GetDebugLevel() >= 3
                Debug.Trace("[PDV] QuestReaction skipped unreachable taboo/hostile deity: " + deityName + " " + sourceTag)
            endIf
            return
        endIf

        if amount > 0.0
            Manager.PDV_QuestReactionRuntimeService.ApplyQuestReactionStigma(deity, amount, sourceTag)
            Manager.OriginRuntime.HandleBretonQuestTagPracticeSignal(sourceTag, False, "taboo_" + sourceTag)
            ; A taboo deity reaction is a real negative piety award (paths take
            ; stigma instead, which is not piety) -- fold it into the quest-fire
            ; surface as displeasure so the loss is not invisible.
            if !isFaucet && magnitude != "meta" && !(deity as PDV_DaedricPathBase)
                Manager.PDV_QuestReactionRuntimeService.AccumulateQuestReactionSurface(deity, amount * -1.0, magnitude)
            endIf
        else
            Manager.PDV_QuestReactionRuntimeService.ApplyQuestReactionPiety(deity, amount, "taboo_" + sourceTag)
            Manager.OriginRuntime.HandleBretonQuestTagPracticeSignal(sourceTag, False, "taboo_" + sourceTag)
            if !isFaucet && magnitude != "meta"
                Manager.PDV_QuestReactionRuntimeService.AccumulateQuestReactionSurface(deity, amount, magnitude)
            endIf
        endIf
        return
    endIf

    ; Reachability gate (2026-07-05): a FOREIGN/TOLERATED quest reaction for a god
    ; outside the player's origin roster (and not a Daedric path) writes piety no
    ; surface can ever read back -- the dashboard filters by
    ; IsDashboardDeityInOriginRoster and the formal commitment offer path is
    ; origin-gated, so the piety, driver ring, and signal-day writes are dead state.
    ; Skip the award entirely; generic acts (ScoreFromTable), the dashboard, and
    ; offers already hard-gate the same way. Daedric paths stay scored: a pre-pact
    ; path with piety renders as "watching", so path piety has a live consumer.
    ; Roster deities with a TOLERATED/FOREIGN stance (visible-but-foreign) keep
    ; their reduced-rate award below.
    if stance == "FOREIGN" || stance == "TOLERATED"
        if !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(deity)
            if Manager.GetDebugLevel() >= 3
                Debug.Trace("[PDV] QuestReaction skipped unreachable foreign deity: " + deityName + " " + sourceTag)
            endIf
            return
        endIf
    endIf

    ; Native/reachable stances used to fall straight through after the
    ; FOREIGN/TOLERATED guard above. That let the Nord dashboard union roster
    ; award Old Ways piety while Nine Divines was selected (and vice versa).
    ; Keep the final guard beside the award so old snapshots and direct callers
    ; cannot reintroduce an out-of-lane positive reaction after ingress compacts
    ; it away.
    if !Manager.PDV_QuestReactionRuntimeService.IsQuestReactionDeityReachable(deity)
        if Manager.GetDebugLevel() >= 3
            Debug.Trace("[PDV] QuestReaction skipped inactive lane deity: " + deityName + " " + sourceTag)
        endIf
        return
    endIf

    Float multiplier = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStanceMultiplier(stance)

    Float appliedReactionAmount = amount * multiplier
    ; Milestone surfacing (below) owns the top-left toast for a landed base-cell
    ; reaction, so mute AwardPiety's generic active-patron favor pulse across the
    ; award to avoid a double toast. The panel driver ring is still fed inside
    ; AwardPiety regardless.
    Manager.SetSuppressAwardFavorToast(True)
    Manager.PDV_QuestReactionRuntimeService.ApplyQuestReactionPiety(deity, appliedReactionAmount, deityName + "." + sourceTag)
    Manager.SetSuppressAwardFavorToast(False)
    Manager.OriginRuntime.HandleBretonQuestTagPracticeSignal(sourceTag, appliedReactionAmount > 0.0, deityName + "." + sourceTag)

    ; Milestone surfacing (2026-07-05): a base quest-reaction cell is a milestone-grade
    ; beat, so a landed reaction feeds the per-quest surface accumulator; the quest
    ; fire flushes ONE toast + ONE Book of Days beat for all its cells (owner ruling
    ; after the first per-cell build toasted 6 gods per assassination stage). Excluded,
    ; by design, from that loud surface:
    ;   - behavioral faucets (isFaucet): cannibalism / forbidden-knowledge signals, not
    ;     quests; they keep their daily/once caps and quiet-Ledger driver row.
    ;   - meta faucets (magnitude "meta"): thin-coverage background lanes that can fire
    ;     several at once per quest; surfacing them would burst. They already carry
    ;     bespoke humanized driver-row copy.
    ; The reachability gate above already dropped off-roster gods, so only gods the
    ; player actually follows reach this surface.
    if !isFaucet && magnitude != "meta"
        Manager.PDV_QuestReactionRuntimeService.AccumulateQuestReactionSurface(deity, appliedReactionAmount, magnitude)
    endIf

    ; Bridge: a positive quest reaction for a Khajiit-focus deity also tilts which
    ; moon-path leads, so the matrix's existing Baan Dar / Rajhin / Alkosh /
    ; Khenarthi / Azurah cells drive the focused-emphasis system. Piety is already
    ; awarded above; this adds focus weight only. Behavior-driven focus per the
    ; LOCKED Khajiit design sheet.
    if amount > 0.0 && Manager.OriginRuntime.IsKhajiitOrigin()
        Manager.OriginRuntime.BridgeKhajiitMatrixFocus(deityName, magnitude)
    endIf
EndFunction

Bool Function ShouldSurfaceLikesDislikesEvent(Int eventType)
    return eventType == 303 || eventType == 366
EndFunction

Function ResetLikesDislikesSurface()
    _ldSurfEventType = -1
    _ldSurfPosNamesCsv = ""
    _ldSurfNegNamesCsv = ""
    _ldSurfPosCount = 0
    _ldSurfNegCount = 0
    _ldSurfBestPosAmount = 0.0
    _ldSurfBestNegAmount = 0.0
    _ldSurfBestPosName = ""
    _ldSurfBestNegName = ""
    _ldSurfBestPosSymbol = ""
    _ldSurfBestNegSymbol = ""
EndFunction

Function BeginLikesDislikesSurface(Int eventType, String parentLogicalEventId = "")
    Bool joinedParentEvent = False
    if parentLogicalEventId != ""
        joinedParentEvent = JoinBroadPantheonEvent(parentLogicalEventId)
    endIf
    if !joinedParentEvent
        BeginBroadPantheonEvent("likes_dislikes_" + eventType + "_" + Utility.GetCurrentGameTime())
    endIf
    if !ShouldSurfaceLikesDislikesEvent(eventType)
        return
    endIf

    ResetLikesDislikesSurface()
    _ldSurfEventType = eventType
EndFunction

Function AccumulateLikesDislikesSurface(PDV_DeityBase deity, Float amount, Int eventType)
    if !ShouldSurfaceLikesDislikesEvent(eventType) || !deity || amount == 0.0
        return
    endIf

    if _ldSurfEventType != eventType
        BeginLikesDislikesSurface(eventType)
    endIf

    String deityName = Manager.Prisma.GetPublicDeityDisplayName(deity)
    if amount > 0.0
        if _ldSurfPosNamesCsv != ""
            _ldSurfPosNamesCsv = _ldSurfPosNamesCsv + "|"
        endIf
        _ldSurfPosNamesCsv = _ldSurfPosNamesCsv + deityName
        _ldSurfPosCount += 1
        if amount > _ldSurfBestPosAmount
            _ldSurfBestPosAmount = amount
            _ldSurfBestPosName = deityName
            _ldSurfBestPosSymbol = Manager.Prisma.GetPrismaSymbolForDeity(deity)
        endIf
    else
        if _ldSurfNegNamesCsv != ""
            _ldSurfNegNamesCsv = _ldSurfNegNamesCsv + "|"
        endIf
        _ldSurfNegNamesCsv = _ldSurfNegNamesCsv + deityName
        _ldSurfNegCount += 1
        if amount < _ldSurfBestNegAmount
            _ldSurfBestNegAmount = amount
            _ldSurfBestNegName = deityName
            _ldSurfBestNegSymbol = Manager.Prisma.GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

Function FlushLikesDislikesSurface(Int eventType)
    ; Altmer lore reads receive a dedicated sacred-text acknowledgement when a
    ; curated source applies. Keep the generic piety fan-out real, but do not
    ; let its catch-all surface compete with that specific moment.
    if Manager.OriginRuntime.IsAltmerOrigin() && eventType == 342
        ResetLikesDislikesSurface()
        FlushBroadPantheonEvent()
        return
    endIf

    if !ShouldSurfaceLikesDislikesEvent(eventType)
        FlushBroadPantheonEvent()
        return
    endIf

    if _ldSurfPosCount == 0 && _ldSurfNegCount == 0
        ResetLikesDislikesSurface()
        FlushBroadPantheonEvent()
        return
    endIf

    Int nowDay = Utility.GetCurrentGameTime() as Int
    if _ldSurfNegCount == 0
        String posMsg = _ldSurfBestPosName + " marks the act."
        if _ldSurfPosCount == 2
            posMsg = Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " mark the act."
        elseIf _ldSurfPosCount > 2
            posMsg = _ldSurfBestPosName + " and " + (_ldSurfPosCount - 1) + " others mark the act."
        endIf
        Manager.Prisma.SendPrismaToast(_ldSurfBestPosSymbol, "good", "A deed noticed", posMsg)
        Manager.Prisma.AppendBookOfDaysEntry(Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " marked the act.", nowDay, "favor.act", _ldSurfBestPosSymbol, False, 1, "A deed noticed")
    elseIf _ldSurfPosCount == 0
        String negMsg = _ldSurfBestNegName + " takes offense at the act."
        if _ldSurfNegCount == 2
            negMsg = Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " take offense at the act."
        elseIf _ldSurfNegCount > 2
            negMsg = _ldSurfBestNegName + " and " + (_ldSurfNegCount - 1) + " others take offense at the act."
        endIf
        Manager.Prisma.SendPrismaToast(_ldSurfBestNegSymbol, "warning", "A deed ill-received", negMsg)
        Manager.Prisma.AppendBookOfDaysEntry(Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " took offense at the act.", nowDay, "favor.loss", _ldSurfBestNegSymbol, False, 1, "A deed ill-received")
    else
        Bool positiveLeads = _ldSurfBestPosAmount >= (_ldSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _ldSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _ldSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        Manager.Prisma.SendPrismaToast(mixedSymbol, mixedTone, "A deed weighed", _ldSurfBestPosName + " marks the act; " + _ldSurfBestNegName + " takes offense.")
        Manager.Prisma.AppendBookOfDaysEntry(Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfPosNamesCsv) + " marked the act; " + Manager.PDV_QuestReactionRuntimeService.JoinQuestSurfaceNames(_ldSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, 1, "A deed weighed")
    endIf

    Manager.Trace(1, "Likes/dislikes surface flushed: event " + eventType + ", positive " + _ldSurfPosCount + ", negative " + _ldSurfNegCount)
    ResetLikesDislikesSurface()
    FlushBroadPantheonEvent()
EndFunction

Function SurfaceDebugDislikeEvent(PDV_DeityBase deity, Float amount, Int eventType)
    if !deity || amount >= 0.0
        return
    endIf

    String deityName = Manager.Prisma.GetPublicDeityDisplayName(deity)
    String symbolName = Manager.Prisma.GetPrismaSymbolForDeity(deity)
    Int nowDay = Utility.GetCurrentGameTime() as Int
    Manager.Prisma.SendPrismaToast(symbolName, "warning", "A deed ill-received", deityName + " takes offense at the act.")
    Manager.Prisma.AppendBookOfDaysEntry(deityName + " took offense at the act.", nowDay, "favor.loss", symbolName, False, 1, "A deed ill-received")
    Manager.Trace(1, "Debug dislike surface flushed: " + deity.DeityName + " event " + eventType)
EndFunction

Bool Function ConsumeShrinePrayerCredit(PDV_DeityBase deity, String sourceId)
    if !deity
        return False
    endIf

    ; B13 / fix-plan 4.1 -- the day-0 false block. This compared a StorageUtil int that
    ; DEFAULTS TO 0 against raw game day 0, so on the first in-game day of a new save every
    ; shrine-prayer credit for every deity was refused. Fixed the way the rest of the tree
    ; already does it (fix-plan 4.2): the shared 06:00 devotional day in the zero-reserved
    ; +2 encoding, where the stamp is >= 1 by construction and 0 unambiguously means unset.
    ; NOT via ReadZeroReservedDevotionalDayStamp: that helper migrates a legacy +1 DEVOTIONAL
    ; stamp, and the value stored here was a raw wall-clock day. A stale wall-clock day can
    ; never equal a same-day devotional stamp (it would have to be two days in the future),
    ; so existing saves migrate silently with no false block and no false grant.
    Int todayStamp = GetDevotionalDay() + 2
    String deityKey = deity.DeityName
    if deityKey == ""
        deityKey = "" + deity.GetFormID()
    endIf
    String guardKey = "PDV.Signal.ShrinePrayer." + deityKey
    if StorageUtil.GetIntValue(None, guardKey) == todayStamp
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Shrine prayer daily cap blocked " + deityKey + " from " + sourceId)
        endIf
        return False
    endIf

    StorageUtil.SetIntValue(None, guardKey, todayStamp)
    return True
EndFunction

Bool Function IsGrandfatheredOffRosterPatron(PDV_DeityBase deity)
    if !deity || deity as PDV_DaedricPathBase
        return False
    endIf
    if GetPatronState() != PATRON_STATE_ACTIVE || deity != Manager.GetActiveDeity() || Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, Manager.GetPlayerOriginRaceIndex())
        return False
    endIf
    String stance = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStance(Manager.Prisma.GetPublicDeityDisplayName(deity), deity)
    return stance == "FOREIGN" || stance == "TOLERATED"
EndFunction

String Function ExtractTierLabelFromSurfaceKey(String surfaceKey)
    if PDV_DevotionRules.StringContainsToken(surfaceKey, "Champion")
        return "Champion"
    elseIf PDV_DevotionRules.StringContainsToken(surfaceKey, "Devoted")
        return "Devoted"
    elseIf PDV_DevotionRules.StringContainsToken(surfaceKey, "Seeker")
        return "Seeker"
    elseIf PDV_DevotionRules.StringContainsToken(surfaceKey, "Faithful")
        return "Faithful"
    elseIf PDV_DevotionRules.StringContainsToken(surfaceKey, "Observant")
        return "Observant"
    endIf
    return ""
EndFunction

String Function BuildCommitmentOfferAcceptJournalLine(Int deityIndex)
    String patron = Manager.Prisma.GetJournalDeityName(deityIndex)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_DUNMER
        return "The Reclamation deepens in you. You named " + patron + " as your focus."
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "The foundation narrows to a single disciplined road. You named " + patron + " your focus."
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "The sect's broad worship narrows to one charge. You took " + patron + " as your own."
    endIf
    return "The broad faith narrows to one; " + patron + " has named you their own."
EndFunction

String Function BuildCommitmentOfferAcceptToastLine(PDV_DeityBase deity)
    String patron = Manager.Prisma.GetPublicDeityDisplayName(deity)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_DUNMER
        return "The ash-prayer has a name: " + patron + "."
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "You name " + patron + " your focus."
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "You walk under " + patron + " now."
    endIf
    return patron + " has named you their own."
EndFunction

String Function BuildCommitmentOfferRefuseJournalLine(Int deityIndex)
    String patron = Manager.Prisma.GetJournalDeityName(deityIndex)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_DUNMER
        return "The Reclamation holds as it was. You set " + patron + " aside, and " + patron + " will not ask again."
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "The foundation stands as it was. You kept to it alone, and " + patron + " will not ask again."
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "The sect's broad worship holds as it was. You set " + patron + "'s charge aside; " + patron + " will not ask again."
    endIf
    return "The broad faith stays whole; you turned " + patron + " away, and " + patron + " will not ask again."
EndFunction

String Function BuildCommitmentOfferRefuseToastLine(PDV_DeityBase deity)
    String patron = Manager.Prisma.GetPublicDeityDisplayName(deity)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_DUNMER
        return "You set " + patron + " aside."
    elseIf originRace == Manager.ORIGIN_ALTMER
        return "You keep to the foundation."
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return "You keep to the sect."
    endIf
    return "You turned " + patron + " away."
EndFunction

String Function GetDeityDriversJson(PDV_DeityBase deity)
    Form deityForm = deity as Form
    Int count = StorageUtil.StringListCount(deityForm, "PDV.Driver.Reasons")
    String out = ""
    Int i = 0
    while i < count
        String reason = StorageUtil.StringListGet(deityForm, "PDV.Driver.Reasons", i)
        Float delta = StorageUtil.FloatListGet(deityForm, "PDV.Driver.Deltas", i)
        String dir = "gain"
        if delta < 0.0
            dir = "loss"
        endIf
        String entry = "{\"reason\":\"" + PDV_DevotionRules.JsonSafeString(reason) + "\",\"count\":1,\"net\":" + delta + ",\"dir\":\"" + dir + "\"}"
        if out != ""
            out = out + ","
        endIf
        out = out + entry
        i += 1
    endWhile
    return out
EndFunction

Bool Function HasRecentPietyMovement(Form deityForm)
    Int n = StorageUtil.FloatListCount(deityForm, "PDV.Week.Net")
    Int i = 0
    while i < n
        if StorageUtil.FloatListGet(deityForm, "PDV.Week.Net", i) != 0.0
            return True
        endIf
        i += 1
    endWhile

    Int today = Utility.GetCurrentGameTime() as Int
    Int driverDays = StorageUtil.IntListCount(deityForm, "PDV.Driver.Days")
    Int k = 0
    while k < driverDays
        if today - StorageUtil.IntListGet(deityForm, "PDV.Driver.Days", k) <= 7
            return True
        endIf
        k += 1
    endWhile

    return False
EndFunction

Function AwardCuratedSignal(PDV_DeityBase deity, Int signalType, Form contextRef)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignal skipped: no deity supplied.")
        endIf
        return
    endIf

    Float delta = deity.ScoreCuratedSignal(signalType, contextRef)
    if delta == 0.0
        if Manager.GetDebugLevel() >= 3
            Debug.Trace("[PDV] AwardCuratedSignal: " + deity.DeityName + " ignored signal " + signalType)
        endIf
        return
    endIf

    AwardPiety(deity, delta, Manager.Prisma.CuratedSignalDriverReason(deity, signalType))

    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardCuratedSignal: " + deity.DeityName + " signal " + signalType + " delta " + delta)
    endIf
EndFunction

Function AwardCuratedSignalScaled(PDV_DeityBase deity, Int signalType, Form contextRef, Float multiplier)
    if multiplier <= 0.0
        return
    endIf

    if multiplier == 1.0
        AwardCuratedSignal(deity, signalType, contextRef)
        return
    endIf

    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignalScaled skipped: no deity supplied.")
        endIf
        return
    endIf

    Float delta = deity.ScoreCuratedSignal(signalType, contextRef)
    if delta == 0.0
        if Manager.GetDebugLevel() >= 3
            Debug.Trace("[PDV] AwardCuratedSignalScaled: " + deity.DeityName + " ignored signal " + signalType)
        endIf
        return
    endIf

    Float scaledDelta = delta * multiplier
    AwardPiety(deity, scaledDelta, Manager.Prisma.CuratedSignalDriverReason(deity, signalType))

    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] AwardCuratedSignalScaled: " + deity.DeityName + " signal " + signalType + " delta " + scaledDelta + " multiplier " + multiplier)
    endIf
EndFunction

Function AwardCuratedSignalByIndex(Int deityIndex, Int signalType)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardCuratedSignalByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    AwardCuratedSignal(deity, signalType, None)
EndFunction

Float Function GetPiety(PDV_DeityBase deity)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
EndFunction

Float Function GetPietyToday(PDV_DeityBase deity)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
EndFunction

Int Function GetTier(PDV_DeityBase deity)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return TIER_NONE
    endIf
    return StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int
EndFunction

Int Function GetActiveDeityIndex()
    if Manager.GetActiveDeity()
        return Manager.GetActiveDeity().DeityIndex
    endIf
    return -1
EndFunction

Int Function GetDeityCount()
    if !PDV_FLST_AllDeities
        return 0
    endIf
    return PDV_FLST_AllDeities.GetSize()
EndFunction

PDV_DeityBase Function GetDeityAtListIndex(Int listIndex)
    if listIndex < 0 || !PDV_FLST_AllDeities
        return None
    endIf

    if listIndex >= PDV_FLST_AllDeities.GetSize()
        return None
    endIf

    return PDV_FLST_AllDeities.GetAt(listIndex) as PDV_DeityBase
EndFunction

PDV_DeityBase Function GetDeityByName(String deityName)
    if deityName == "" || !PDV_FLST_AllDeities
        return None
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && deity.DeityName == deityName
            return deity
        endIf
        i += 1
    endWhile

    return None
EndFunction

Float Function GetPietyByIndex(Int deityIndex)
    return GetPiety(GetDeityByIndex(deityIndex))
EndFunction

PDV_DeityBase Function GetShrinePrayerDeityByName(String deityName)
    if deityName == ""
        return None
    endIf

    if deityName == "Kyne"
        return Manager.PDV_Kyne
    elseIf deityName == "Kynareth"
        return PDV_Kynareth
    elseIf deityName == "Khenarthi"
        return Manager.PDV_Khenarthi
    elseIf deityName == "Akatosh"
        return PDV_Akatosh
    elseIf deityName == "Auri-El" || deityName == "Auriel"
        return Manager.PDV_AuriEl
    elseIf deityName == "Alkosh"
        return Manager.PDV_Alkosh
    elseIf deityName == "Arkay"
        return PDV_Arkay
    elseIf deityName == "Tu'whacca" || deityName == "Tuwhacca"
        return Manager.PDV_Tuwhacca
    elseIf deityName == "Zenithar"
        return PDV_Zenithar
    elseIf deityName == "Z'en" || deityName == "Zen"
        return PDV_Zen
    elseIf deityName == "Mara"
        return PDV_Mara
    elseIf deityName == "Dibella"
        return PDV_Dibella
    elseIf deityName == "Julianos"
        return PDV_Julianos
    elseIf deityName == "Stendarr"
        return PDV_Stendarr
    elseIf deityName == "Talos"
        return Manager.PDV_Talos
    endIf

    return GetDeityByName(deityName)
EndFunction

Function HandleShrinePrayer(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String shrineLabel, String sourceId)
    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_IMPERIAL && !Manager.OriginRuntime.IsImperialVampireStateActive() && ShrinePrayerHasAlias(primaryDeityName, secondaryDeityName, tertiaryDeityName, "Talos")
        StorageUtil.SetIntValue(None, "PDV.Imperial.TalosBroadUnlocked", 1)
        Manager.Trace(1, "Imperial broad Talos roster unlocked by explicit prayer: " + sourceId)
    endIf
    BeginBroadPantheonEvent("shrine_prayer_" + sourceId)
    Bool awarded = False
    awarded = AwardShrinePrayerToDeityName(primaryDeityName, shrineLabel, sourceId) || awarded
    awarded = AwardShrinePrayerToDeityName(secondaryDeityName, shrineLabel, sourceId) || awarded
    awarded = AwardShrinePrayerToDeityName(tertiaryDeityName, shrineLabel, sourceId) || awarded
    FlushBroadPantheonEvent()

    if awarded
        HandleSubstrateShrinePrayer(primaryDeityName, secondaryDeityName, tertiaryDeityName, sourceId)
        String label = Manager.Prisma.ResolveShrinePrayerJournalLabel(primaryDeityName, secondaryDeityName, tertiaryDeityName, shrineLabel)
        Manager.Prisma.AppendBookOfDaysEntry("You offered prayer at " + label + "'s shrine.", Utility.GetCurrentGameTime() as Int, "favor.act", "journal", False, 1, "Shrine prayer answered")
    endIf
EndFunction

Function HandleSubstrateShrinePrayer(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String sourceId)
    Int origin = Manager.GetPlayerOriginRaceIndex()
    if origin == Manager.ORIGIN_IMPERIAL && Manager.PDV_ImperialAncestorSubstrate && !Manager.OriginRuntime.IsImperialVampireStateActive()
        PDV_DeityBase primary = GetShrinePrayerDeityByName(primaryDeityName)
        PDV_DeityBase secondary = GetShrinePrayerDeityByName(secondaryDeityName)
        PDV_DeityBase tertiary = GetShrinePrayerDeityByName(tertiaryDeityName)
        if IsDeityEligibleForBroadPantheon(primary, BROAD_PANTHEON_IMPERIAL) || IsDeityEligibleForBroadPantheon(secondary, BROAD_PANTHEON_IMPERIAL) || IsDeityEligibleForBroadPantheon(tertiary, BROAD_PANTHEON_IMPERIAL)
            Manager.OriginRuntime.AwardImperialAncestorSpinePulse(1.0, "divine_prayer_" + sourceId)
        endIf
    elseIf origin == Manager.ORIGIN_ALTMER && Manager.PDV_AltmerAncestorSubstrate && !Manager.OriginRuntime.IsAltmerFavorSuppressedByCurse()
        if GetShrinePrayerDeityByName(primaryDeityName) == Manager.PDV_AuriEl || GetShrinePrayerDeityByName(secondaryDeityName) == Manager.PDV_AuriEl || GetShrinePrayerDeityByName(tertiaryDeityName) == Manager.PDV_AuriEl
            Manager.OriginRuntime.AwardAltmerAncestorSpinePulse(1.0, "auriel_shrine_rite_" + sourceId)
        endIf
    endIf
EndFunction

Bool Function ShrinePrayerHasAlias(String primaryDeityName, String secondaryDeityName, String tertiaryDeityName, String aliasName)
    return primaryDeityName == aliasName || secondaryDeityName == aliasName || tertiaryDeityName == aliasName
EndFunction

Bool Function AwardShrinePrayerToDeityName(String deityName, String shrineLabel, String sourceId)
    PDV_DeityBase deity = GetShrinePrayerDeityByName(deityName)
    if !deity
        if deityName != "" && Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] Shrine prayer skipped unknown deity alias " + deityName + " source " + sourceId)
        endIf
        return False
    endIf

    ; Divine shrine prayers are ambient world clicks; only emit PDV piety/journal
    ; movement when that deity belongs to the player's cultural roster. An
    ; off-roster patron restored from an older save remains eligible at the
    ; reduced foreign rate so the relationship is not stranded.
    Bool grandfatheredPatron = IsGrandfatheredOffRosterPatron(deity)
    if !Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, Manager.GetPlayerOriginRaceIndex()) && !grandfatheredPatron
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Shrine prayer skipped outside origin roster: " + deity.DeityName + " from " + shrineLabel + " source " + sourceId)
        endIf
        return False
    endIf

    if !ConsumeShrinePrayerCredit(deity, sourceId)
        return False
    endIf

    Float shrineAmount = 2.0
    if grandfatheredPatron
        shrineAmount = shrineAmount * Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStanceMultiplier(Manager.PDV_QuestReactionRuntimeService.GetQuestReactionStance(Manager.Prisma.GetPublicDeityDisplayName(deity), deity))
    endIf
    AwardPietyInternal(deity, shrineAmount, True, "shrine_prayer_" + sourceId, !grandfatheredPatron)
    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] Shrine prayer awarded " + deity.DeityName + " from " + shrineLabel + " source " + sourceId)
    endIf
    return True
EndFunction

Float Function GetPietyTodayByIndex(Int deityIndex)
    return GetPietyToday(GetDeityByIndex(deityIndex))
EndFunction

Bool Function IsDeityReachableForCurrentOrigin(PDV_DeityBase deity)
    if !deity || !Manager || !Manager.OriginRuntime
        return False
    endIf

    return Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, Manager.GetPlayerOriginRaceIndex()) || UsesFormalCommitmentOffersForDeity(deity)
EndFunction

Function SetActiveDeity(PDV_DeityBase newDeity)
    if newDeity == Manager.GetActiveDeity()
        return
    endIf

    ; Selection boundary: ordinary deity commitments must belong to the
    ; cultural roster or a currently valid formal-offer lane. This retains
    ; Imperial Talos and Breton Hidden Art's dynamic eligibility while blocking
    ; accidental off-roster assignment. RestoreActiveDeityFromStoredPatron
    ; deliberately bypasses this setter for save-safe grandfathering.
    if newDeity && !IsDeityReachableForCurrentOrigin(newDeity)
        Manager.Trace(1, "SetActiveDeity blocked off-roster commitment to " + newDeity.DeityName)
        return
    endIf

    UnsafeApplyActiveDeityState(newDeity)
EndFunction

; This routine deliberately performs no reachability check. Keep it behind the
; named fault-injection boundary; ordinary gameplay and debug callers use
; SetActiveDeity so off-origin deities cannot become reachable by accident.
Function UnsafeApplyActiveDeityState(PDV_DeityBase newDeity)

    ; Exclusivity (data-layer): committing a patron severs an active Prince pact.
    ; Guarded on newDeity != None so SetActiveDeity(None) (the patron-teardown path,
    ; incl. the Prince-commit sever above) cannot re-enter this and double-clear.
    if newDeity != None
        PDV_DaedricPathBase priorPact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
        if priorPact
            priorPact.ClearLiveDaedricPactSpells()
            StorageUtil.SetFormValue(None, "PDV.Daedric.ActivePact", None)
            Manager.DaedricRuntime.SurfaceSwitchSeverance("prince_to_patron", priorPact.DeityName)
        endIf
    endIf

    if Manager.GetActiveDeity()
        Manager.GetActiveDeity().OnPatronEnd()
    endIf

    Manager.SetActiveDeityRef(newDeity)
    Manager.FavorRuntime.ClearActiveFavor("patron_state_change")

    if Manager.GetActiveDeity()
        EnsureDeityState(Manager.GetActiveDeity())
        Manager.GetActiveDeity().OnPatronStart()
        SetPatronState(PATRON_STATE_ACTIVE)
    else
        SetPatronState(PATRON_STATE_UNSET)
    endIf

    UpdatePatronDeityGlobal()
    RefreshPatronMirrors()
    Manager.Prisma.RequestPanelRefresh()
EndFunction

Function SetBroadWorship()
    if Manager.GetActiveDeity()
        Manager.GetActiveDeity().OnPatronEnd()
    endIf

    Manager.SetActiveDeityRef(None)
    Manager.FavorRuntime.ClearActiveFavor("patron_state_change")
    SetPatronState(PATRON_STATE_BROAD)
    UpdatePatronDeityGlobal()
    RefreshPatronMirrors()
    Manager.Prisma.RequestPanelRefresh()
EndFunction

Int Function GetPatronState()
    Int storedState = StorageUtil.GetIntValue(None, "PDV.PatronState")
    if storedState == PATRON_STATE_BROAD || storedState == PATRON_STATE_ACTIVE
        return storedState
    endIf

    if Manager.GetActiveDeity()
        return PATRON_STATE_ACTIVE
    endIf

    return PATRON_STATE_UNSET
EndFunction

String Function GetPatronStateLabel()
    Int patronState = GetPatronState()
    if patronState == PATRON_STATE_ACTIVE
        return "Active patron"
    elseIf patronState == PATRON_STATE_BROAD
        return "Broad worship"
    endIf

    return "Unset"
EndFunction

Bool Function IsBroadWorshipActive()
    return GetPatronState() == PATRON_STATE_BROAD
EndFunction

String Function GetReservedSignalSurfaceName(PDV_DeityBase deity)
    if !deity
        return ""
    endIf
    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
        if deity == Manager.PDV_Boethiah
            return "Boethra"
        elseIf deity == Manager.PDV_Mephala
            return "Mafala"
        elseIf deity == Manager.PDV_Azura
            return "Azurah"
        endIf
    endIf
    return Manager.Prisma.GetPublicDeityDisplayName(deity)
EndFunction

Function SurfaceReservedSignal(PDV_DeityBase deity, String titleText, String actionText)
    if !deity || titleText == "" || actionText == ""
        return
    endIf
    String deityName = GetReservedSignalSurfaceName(deity)
    String bodyText = actionText
    if deityName != ""
        bodyText = deityName + " " + actionText
    endIf
    String symbolName = Manager.Prisma.GetPrismaSymbolForDeity(deity)
    Manager.Prisma.SendPrismaToast(symbolName, "good", titleText, bodyText)
    Manager.Prisma.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "favor.act", symbolName, False, 1, titleText)
    RecordRecentDevotionEvent(bodyText)
    Manager.Prisma.RequestPanelRefresh()
EndFunction

Int Function RecomputeTier(PDV_DeityBase deity, Bool surfaceTierUp = True)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return TIER_NONE
    endIf

    EnsureDeityState(deity)

    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Int oldTier = StorageUtil.GetFloatValue(deityForm, "PDV.Tier") as Int
    Int newTier = ComputeTierFromPiety(deity, piety)
    if newTier < oldTier && piety >= (ThresholdForTier(deity, oldTier) - TIER_DOWN_HYSTERESIS)
        newTier = oldTier
    endIf

    RefreshPassiveDecayFloorForDeity(deity, newTier)

    if newTier != oldTier
        StorageUtil.SetFloatValue(deityForm, "PDV.Tier", newTier as Float)
        StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", Utility.GetCurrentGameTime())

        ; P10 (2026-08-03): a demotion clears the one-shot notice for the tier just LOST, so a
        ; later re-climb can surface again. Without this, a Champion who decayed to Devoted and
        ; fought all the way back to 85 got TOTAL SILENCE -- NotifyTierUp's key was already
        ; burned and never cleared by anything. This fixes it for EVERY race, not just Altmer.
        if newTier < oldTier
            StorageUtil.SetIntValue(None, "PDV.TierNoticeShown." + deity.DeityIndex + "." + oldTier, 0)
            ; P10 parity for the authored Nord/Kyne recognition (2026-08-07). Its own one-shot key
            ; is NOT the tier notice, so without this a Nord who fell from Champion and climbed back
            ; got the toast and Book entry again but never the modal -- the exact "total silence on a
            ; re-climb" bug the block above exists to prevent, reintroduced one surface lower.
            if oldTier >= TIER_CHAMPION && Manager.PDV_Kyne && deity == Manager.PDV_Kyne
                StorageUtil.SetIntValue(None, "PDV.Nord.ChampionEntryShown.Kyne", 0)
            endIf
        endIf

        Bool isFocusedEmphasis = Manager.OriginRuntime.IsKhajiitOrigin() && deity == Manager.OriginRuntime.GetKhajiitEmphasisDeity(Manager.OriginRuntime.GetKhajiitFocusedEmphasis())

        ; Reward/mirror hooks fire only for the patron / focused-emphasis deity.
        if deity == Manager.GetActiveDeity()
            deity.OnTierChange(oldTier, newTier)
            RefreshPatronMirrors()
        elseIf isFocusedEmphasis
            deity.OnTierChange(oldTier, newTier)
        endIf

        ; Universal milestone surfacing: notice + toast + Book of Days entry for EVERY
        ; tier reach -- including broad-worship / pantheon gods with no single patron.
        ; A Nord keeping the whole pantheon (no _activeDeity, not Khajiit emphasis)
        ; previously got nothing here; now each god's milestone is marked. NotifyTierUp's
        ; per-(deity,tier) guard prevents duplicate notices; the band in surfaceKey scopes
        ; the journal guard so Seeker/Devoted/Champion each log once, Champion pinned.
        if surfaceTierUp && newTier > oldTier
            if Manager.OriginRuntime.ShouldSuppressImperialTalosTierSurface(deity)
                Manager.Trace(2, "Tier reach surface suppressed for Imperial Talos while Concordat blocks offers.")
            elseIf Manager.OriginRuntime.ShouldSuppressBretonFocusedChampionTierSurface(deity, newTier)
                Manager.Trace(2, "Tier reach surface suppressed for Breton resonant Champion; tradition reward presentation owns it.")
            elseIf NotifyTierUp(deity, newTier)
                StorageUtil.SetFormValue(None, "PDV.BookOfDays.LastTierDeity", deityForm)
                StorageUtil.SetIntValue(None, "PDV.BookOfDays.LastTierValue", newTier)
                Manager.Prisma.SendPrismaEventToast("tier", deity, "", Manager.Prisma.GetPublicTierBand(newTier), "")
                Manager.Prisma.SurfaceTransition("tier", deity.DeityName + " " + Manager.Prisma.GetTierStandingLabel(newTier), "reach", deity.DeityIndex, "", false, newTier >= TIER_CHAMPION)
                Manager.OriginRuntime.MaybeShowNordKyneChampionEntry(deity, newTier)
            endIf
        endIf

        Manager.Prisma.RequestPanelRefresh()
    elseIf deity == Manager.GetActiveDeity()
        RefreshPatronMirrors()
    endIf

    return newTier
EndFunction

Int Function GetDevotionMarks(PDV_DeityBase deity)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return 0
    endIf

    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if piety < deity.ThresholdChampion
        return 0
    endIf

    Int marks = ((piety - deity.ThresholdChampion) / LONG_DEVOTION_MARK_STEP) as Int
    return PDV_DevotionRules.ClampInt(marks, 0, LONG_DEVOTION_MARK_MAX)
EndFunction

Function MaybeSurfaceDevotionMark(PDV_DeityBase deity)
    if !deity || GetTier(deity) < TIER_CHAMPION
        return
    endIf

    Int marks = GetDevotionMarks(deity)
    if marks < 1
        return
    endIf

    String highKey = "PDV.LongDevotion.MarkHigh." + deity.DeityIndex
    if marks > StorageUtil.GetIntValue(None, highKey)
        StorageUtil.SetIntValue(None, highKey, marks)
    endIf

    String shownKey = "PDV.LongDevotion.MarkShown." + deity.DeityIndex + "." + marks
    if StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf
    StorageUtil.SetIntValue(None, shownKey, 1)

    String deityName = Manager.Prisma.GetPublicDeityDisplayName(deity)
    Manager.Prisma.AppendBookOfDaysEntry(deityName + " marks devotion held long past the day it was proven.", Utility.GetCurrentGameTime() as Int, "tier.reach", Manager.Prisma.GetPrismaSymbolForDeity(deity), True, 2, "Long devotion")
    Manager.Trace(1, "Long Devotion mark " + marks + " surfaced for " + deity.DeityName)
EndFunction

Function RunDawnRefreshDevotionMarks()
    if Manager.GetActiveDeity()
        MaybeSurfaceDevotionMark(Manager.GetActiveDeity())
    endIf
EndFunction

Bool Function NotifyTierUp(PDV_DeityBase deity, Int newTier)
    if !deity || newTier <= TIER_NONE
        return False
    endIf

    String shownKey = "PDV.TierNoticeShown." + deity.DeityIndex + "." + newTier
    if StorageUtil.GetIntValue(None, shownKey) == 1
        return False
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
    return True
EndFunction

Function RefreshPatronMirrors()
    if !Manager.GetActiveDeity()
        PDV_GLO_ActivePiety.SetValue(0.0)
        PDV_GLO_ActiveTier.SetValue(TIER_NONE as Float)
        PDV_GLO_ActiveDeityIndex.SetValue(-1.0)
        Manager.RecognitionRuntime.SyncNpcReligiousRecognition()
        return
    endIf

    EnsureDeityState(Manager.GetActiveDeity())
    Form deityForm = Manager.GetActiveDeity() as Form

    PDV_GLO_ActivePiety.SetValue(StorageUtil.GetFloatValue(deityForm, "PDV.Piety"))
    PDV_GLO_ActiveTier.SetValue(StorageUtil.GetFloatValue(deityForm, "PDV.Tier"))
    PDV_GLO_ActiveDeityIndex.SetValue(Manager.GetActiveDeity().DeityIndex as Float)
    Manager.RecognitionRuntime.SyncNpcReligiousRecognition()
EndFunction

Function SetPatronState(Int patronState)
    Int normalizedState = patronState
    if normalizedState != PATRON_STATE_BROAD && normalizedState != PATRON_STATE_ACTIVE
        normalizedState = PATRON_STATE_UNSET
    endIf

    StorageUtil.SetIntValue(None, "PDV.PatronState", normalizedState)
    SyncPatronStateGlobal()
EndFunction

Function SyncPatronStateGlobal()
    if PDV_GLO_PatronState
        PDV_GLO_PatronState.SetValue(GetPatronState() as Float)
    endIf
EndFunction

Function EnsureLikesDislikesTable()
    if StorageUtil.GetIntValue(None, "PDV.LD.Version") == LIKES_DISLIKES_VERSION
        return
    endIf
    LoadLikesDislikesTable()
    StorageUtil.SetIntValue(None, "PDV.LD.Version", LIKES_DISLIKES_VERSION)
EndFunction

Function LoadLikesDislikesTable()
    if !PDV_FLST_AllDeities
        return
    endIf
    Int ldIndex = 0
    Int ldCount = PDV_FLST_AllDeities.GetSize()
    while ldIndex < ldCount
        PDV_DeityBase ldDeity = PDV_FLST_AllDeities.GetAt(ldIndex) as PDV_DeityBase
        if ldDeity
            ; 12.4. Reset -> fill (inside WriteLD) -> seal, in lockstep with the rows
            ; themselves, so the participating-event cache can never disagree with what
            ; is actually in StorageUtil. Seal only after LoadRowsForDeity returns.
            ldDeity.ResetLikesDislikesEventCache()
            ClearRowsForDeity(ldDeity)
            LoadRowsForDeity(ldDeity)
            ldDeity.SealLikesDislikesEventCache()
            ApplyStancesForDeity(ldDeity)
        endIf
        ldIndex += 1
    endWhile
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Likes/dislikes table + stances loaded (version " + LIKES_DISLIKES_VERSION + ").")
    endIf
EndFunction

Function WriteLD(PDV_DeityBase deity, Int eventType, Float delta, Int dailyCap, Float cooldownDays, Int originGate)
    Form ldForm = deity as Form
    String ldPrefix = "PDV.LD." + eventType
    ; 12.4. Record the event on the deity's participating-event cache. Deliberately the
    ; FIRST thing this function does, and outside the origin-gate branch below, so an
    ; origin-gated overlay row is recorded under the same base event type ScoreFromTable
    ; tests -- there is no way to write a row without recording it.
    deity.NoteLikesDislikesEvent(eventType)
    if originGate >= 0
        String originPrefix = ldPrefix + ".O" + originGate
        StorageUtil.SetFloatValue(ldForm, originPrefix + ".D", delta)
        StorageUtil.SetIntValue(ldForm, originPrefix + ".C", dailyCap)
        StorageUtil.SetFloatValue(ldForm, originPrefix + ".O", cooldownDays)
        return
    endIf

    StorageUtil.SetFloatValue(ldForm, ldPrefix + ".D", delta)
    StorageUtil.SetIntValue(ldForm, ldPrefix + ".C", dailyCap)
    StorageUtil.SetFloatValue(ldForm, ldPrefix + ".O", cooldownDays)
EndFunction

Function ClearRowsForDeity(PDV_DeityBase deity)
    Form ldForm = deity as Form
    Int[] ldEvents = GetLikesDislikesEventTypes()
    Int ldIndex = 0
    while ldIndex < ldEvents.Length
        String ldPrefix = "PDV.LD." + ldEvents[ldIndex]
        StorageUtil.UnsetFloatValue(ldForm, ldPrefix + ".D")
        StorageUtil.UnsetIntValue(ldForm, ldPrefix + ".C")
        StorageUtil.UnsetFloatValue(ldForm, ldPrefix + ".O")
        Int originIndex = Manager.ORIGIN_NORD
        while originIndex <= Manager.ORIGIN_REDGUARD
            String originPrefix = ldPrefix + ".O" + originIndex
            StorageUtil.UnsetFloatValue(ldForm, originPrefix + ".D")
            StorageUtil.UnsetIntValue(ldForm, originPrefix + ".C")
            StorageUtil.UnsetFloatValue(ldForm, originPrefix + ".O")
            originIndex += 1
        endWhile
        ldIndex += 1
    endWhile
EndFunction

Int[] Function GetLikesDislikesEventTypes()
    Int[] ldEvents = new Int[35]
    ldEvents[0] = 1
    ldEvents[1] = 2
    ldEvents[2] = 3
    ldEvents[3] = 4
    ldEvents[4] = 40
    ldEvents[5] = 300
    ldEvents[6] = 301
    ldEvents[7] = 302
    ldEvents[8] = 304
    ldEvents[9] = 313
    ldEvents[10] = 314
    ldEvents[11] = 330
    ldEvents[12] = 331
    ldEvents[13] = 332
    ldEvents[14] = 333
    ldEvents[15] = 334
    ldEvents[16] = 335
    ldEvents[17] = 340
    ldEvents[18] = 341
    ldEvents[19] = 342
    ldEvents[20] = 343
    ldEvents[21] = 344
    ldEvents[22] = 345
    ldEvents[23] = 350
    ldEvents[24] = 351
    ldEvents[25] = 360
    ldEvents[26] = 361
    ldEvents[27] = 362
    ldEvents[28] = 364
    ldEvents[29] = 365
    ldEvents[30] = 368
    ldEvents[31] = 315
    ldEvents[32] = 303
    ldEvents[33] = 366
    ldEvents[34] = 305
    return ldEvents
EndFunction

Function EnsurePrinceLikesDislikesTable()
    if StorageUtil.GetIntValue(None, "PDV.PLD.Version") == Manager.PRINCE_LD_VERSION
        return
    endIf
    LoadPrinceLikesDislikesTable()
    StorageUtil.SetIntValue(None, "PDV.PLD.Version", Manager.PRINCE_LD_VERSION)
EndFunction

Function LoadPrinceLikesDislikesTable()
    if !Manager.PDV_FLST_DaedricPaths_All
        return
    endIf
    Int pldIndex = 0
    Int pldCount = Manager.PDV_FLST_DaedricPaths_All.GetSize()
    while pldIndex < pldCount
        PDV_DaedricPathBase pldPath = Manager.PDV_FLST_DaedricPaths_All.GetAt(pldIndex) as PDV_DaedricPathBase
        if pldPath
            Manager.DaedricRuntime.ClearPrinceRowsForPath(pldPath)
            Manager.DaedricRuntime.LoadPrinceRowsForPath(pldPath)
        endIf
        pldIndex += 1
    endWhile
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Prince V2 path table loaded (version " + Manager.PRINCE_LD_VERSION + ").")
    endIf
EndFunction

Function LoadRowsForDeity(PDV_DeityBase deity)
    String ldName = deity.DeityName
    if ldName == "kyne"
        WriteLD(deity, 1, -0.5, 2, 0.0, -1)
        WriteLD(deity, 2, 0.5, 0, 0.0, -1)
        WriteLD(deity, 40, 0.35, 3, 0.0208, -1)
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 303, -0.5, 3, 0.0, -1)
    elseIf ldName == "akatosh"
        WriteLD(deity, 302, -0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, 2)
        WriteLD(deity, 362, -0.75, 2, 0.5, 2)
    elseIf ldName == "Arkay"
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.75, 3, 0.0, 2)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Mara"
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 314, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 351, 0.5, 2, 0.0, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, 2)
        WriteLD(deity, 314, 0.35, 2, 0.5, 2)
        WriteLD(deity, 362, -0.5, 3, 0.0, 2)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Stendarr"
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, -1)
        WriteLD(deity, 351, 0.75, 1, 0.5, 2)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Zenithar"
        WriteLD(deity, 330, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -1.0, 2, 0.5, -1)
        WriteLD(deity, 360, -0.5, 3, 0.0, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 351, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
    elseIf ldName == "Julianos"
        WriteLD(deity, 340, 0.5, 3, 0.0, -1)
        WriteLD(deity, 341, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 331, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
    elseIf ldName == "Dibella"
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "Kynareth"
        WriteLD(deity, 313, 0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 1, 0.5, -1)
        WriteLD(deity, 334, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 2, 0.5, 2)
        WriteLD(deity, 303, -0.5, 3, 0.0, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Talos"
        WriteLD(deity, 343, 1.0, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 351, 0.5, 2, 0.5, 0)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "Shor"
        WriteLD(deity, 343, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, 0)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
    elseIf ldName == "Tsun"
        WriteLD(deity, 2, 0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 0.75, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
    elseIf ldName == "Stuhn"
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, -2.0, 1, 1.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 360, -0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, 0)
        WriteLD(deity, 351, 0.5, 2, 0.5, 0)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
    elseIf ldName == "auri-el"
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.35, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.5, 1, 1.0, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "magnus"
        WriteLD(deity, 341, 0.75, 2, 0.5, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 1, 0.5, -1)
        WriteLD(deity, 341, 0.75, 2, 0.5, 2)
        WriteLD(deity, 342, 0.5, 3, 0.0, 2)
        WriteLD(deity, 331, 0.35, 2, 0.5, 2)
        WriteLD(deity, 365, -1.25, 1, 1.0, 2)
        WriteLD(deity, 366, -0.5, 3, 0.0, -1)
    elseIf ldName == "xarxes"
        WriteLD(deity, 342, 0.75, 2, 0.5, -1)
        WriteLD(deity, 340, 0.5, 3, 0.0, -1)
        WriteLD(deity, 341, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.4, 3, 0.0, -1)
        WriteLD(deity, 343, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, -0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
    elseIf ldName == "trinimac"
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 2, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, -2.0, 1, 1.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 2, 0.35, 3, 0.0, 3)
        WriteLD(deity, 368, -1.5, 1, 1.0, 3)
        WriteLD(deity, 304, -1.0, 2, 0.5, 3)
    elseIf ldName == "Y'ffre"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 330, -0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.75, 2, 0.5, 2)
        WriteLD(deity, 334, 0.25, 3, 0.0, 2)
        WriteLD(deity, 331, -0.35, 3, 0.0, 2)
        WriteLD(deity, 303, 0.25, 3, 0.0, 2)
        WriteLD(deity, 333, 0.5, 3, 0.0, 2)
        WriteLD(deity, 300, 0.5, 3, 0.0, 2)
        WriteLD(deity, 350, 0.5, 3, 0.0, 2)
        WriteLD(deity, 365, -1.0, 2, 0.5, 2)
        WriteLD(deity, 364, -0.5, 3, 0.0, 2)
    elseIf ldName == "Z'en"
        WriteLD(deity, 333, 0.5, 3, 0.0, -1)
        WriteLD(deity, 330, 0.5, 3, 0.0, -1)
        WriteLD(deity, 332, 0.25, 3, 0.0, -1)
        WriteLD(deity, 340, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.75, 2, 0.5, -1)
        WriteLD(deity, 331, 0.25, 3, 0.0, -1)
        WriteLD(deity, 360, -0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
    elseIf ldName == "Baan Dar"
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 364, 0.5, 2, 0.0, -1)
        WriteLD(deity, 330, -0.25, 3, 0.0, -1)
        WriteLD(deity, 351, -0.25, 2, 0.5, -1)
    elseIf ldName == "khenarthi"
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 350, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 313, 0.5, 3, 0.0, 6)
        WriteLD(deity, 350, 0.5, 3, 0.0, 6)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "rajhin"
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.35, 3, 0.0, 6)
        WriteLD(deity, 304, -0.75, 2, 0.5, 6)
        WriteLD(deity, 366, -0.5, 3, 0.0, -1)
    elseIf ldName == "alkosh"
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 361, -0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -1.0, 2, 0.5, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -0.75, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
    elseIf ldName == "azura"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 368, 0.5, 3, 0.0, -1)
        WriteLD(deity, 345, 0.5, 3, 0.0, -1)
        WriteLD(deity, 331, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -1.0, 2, 0.5, -1)
    elseIf ldName == "Boethiah"
        WriteLD(deity, 2, 0.25, 3, 0.0, -1)
        WriteLD(deity, 344, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, 1.5, 1, 1.0, -1)
        WriteLD(deity, 350, -0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 1, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.5, 3, 0.0, -1)
        WriteLD(deity, 362, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 333, -0.25, 3, 0.0, -1)
        WriteLD(deity, 351, -0.25, 2, 0.5, -1)
        WriteLD(deity, 305, -0.25, 2, 0.5, -1)
    elseIf ldName == "Mephala"
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 362, 0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 1.0, 2, 0.5, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 368, 1.5, 1, 1.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 2, -0.25, 3, 0.0, -1)
        WriteLD(deity, 350, -0.5, 2, 0.0, -1)
        WriteLD(deity, 313, -0.25, 3, 0.0, -1)
        WriteLD(deity, 366, 0.35, 3, 0.0, -1)
    elseIf ldName == "The Hist"
        WriteLD(deity, 313, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 333, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 334, 0.25, 3, 0.0, 7)
        WriteLD(deity, 314, 0.25, 1, 0.0, -1)
        WriteLD(deity, 332, 0.5, 3, 0.0, -1)
        WriteLD(deity, 334, 0.5, 3, 0.0, -1)
        WriteLD(deity, 364, -0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.25, 3, 0.0, -1)
    elseIf ldName == "sithis"
        WriteLD(deity, 304, 1.0, 2, 0.5, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 315, -0.25, 1, 0.0, -1)
        WriteLD(deity, 364, 0.5, 3, 0.0, -1)
        WriteLD(deity, 350, -0.5, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 360, 0.5, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 330, -0.5, 3, 0.0, -1)
        WriteLD(deity, 331, -0.5, 3, 0.0, -1)
        WriteLD(deity, 304, 0.35, 1, 1.0, 7)
        WriteLD(deity, 351, -0.25, 2, 0.5, 7)
        WriteLD(deity, 366, 0.5, 3, 0.0, -1)
    elseIf ldName == "Malacath"
        WriteLD(deity, 330, 0.75, 2, 0.5, -1)
        WriteLD(deity, 330, 0.25, 3, 0.0, 8)
        WriteLD(deity, 2, 0.25, 3, 0.0, -1)
        WriteLD(deity, 1, 0.25, 3, 0.0, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 362, -0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 302, 0.75, 1, 0.5, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
    elseIf ldName == "Tu'whacca"
        WriteLD(deity, 300, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.25, 3, 0.0, 9)
        WriteLD(deity, 314, 0.25, 3, 0.0, -1)
        WriteLD(deity, 342, 0.25, 3, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.5, 1, 1.0, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 301, 0.75, 2, 0.5, -1)
        WriteLD(deity, 368, -1.0, 2, 0.5, -1)
        WriteLD(deity, 366, -1.5, 1, 1.0, -1)
    elseIf ldName == "Leki"
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 330, 0.75, 2, 0.5, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.75, 2, 0.5, -1)
        WriteLD(deity, 362, -0.25, 3, 0.0, -1)
        WriteLD(deity, 302, 1.0, 1, 0.5, -1)
        WriteLD(deity, 340, 0.25, 3, 0.0, -1)
        WriteLD(deity, 364, -0.75, 2, 0.5, -1)
        WriteLD(deity, 360, -0.25, 3, 0.0, -1)
    elseIf ldName == "HoonDing"
        WriteLD(deity, 302, 1.5, 1, 1.0, -1)
        WriteLD(deity, 344, 0.25, 3, 0.0, -1)
        WriteLD(deity, 345, 0.25, 3, 0.0, -1)
        WriteLD(deity, 343, 0.75, 2, 0.5, -1)
        WriteLD(deity, 304, -0.25, 3, 0.0, -1)
        WriteLD(deity, 313, 0.25, 3, 0.0, -1)
        WriteLD(deity, 360, 0.25, 3, 0.0, -1)
        WriteLD(deity, 361, 0.25, 3, 0.0, -1)
        WriteLD(deity, 315, -0.25, 3, 0.0, -1)
        WriteLD(deity, 365, -0.75, 2, 0.5, -1)
        WriteLD(deity, 366, -0.75, 2, 0.5, -1)
    elseIf ldName == "Syrabane"
        WriteLD(deity, 332, 0.5, 3, 0.0, -1)
        WriteLD(deity, 334, 0.25, 3, 0.0, -1)
        WriteLD(deity, 341, 0.35, 3, 0.0, -1)
        WriteLD(deity, 301, 0.5, 3, 0.0, -1)
        WriteLD(deity, 300, 0.25, 3, 0.5, -1)
        WriteLD(deity, 342, 0.2, 2, 0.0, -1)
        WriteLD(deity, 350, 0.75, 2, 0.5, -1)
        WriteLD(deity, 365, -1.25, 1, 1.0, -1)
        WriteLD(deity, 368, -1.25, 1, 1.0, -1)
        WriteLD(deity, 304, -1.25, 2, 0.5, -1)
        WriteLD(deity, 364, -1.0, 2, 0.5, -1)
        WriteLD(deity, 362, -0.25, 3, 0.0, -1)
    endIf
EndFunction

Function ApplyStances(PDV_DeityBase deity, Int sNord, Int sImperial, Int sBreton, Int sAltmer, Int sBosmer, Int sDunmer, Int sKhajiit, Int sArgonian, Int sOrc, Int sRedguard)
    deity.Stance_Nord = sNord
    deity.Stance_Imperial = sImperial
    deity.Stance_Breton = sBreton
    deity.Stance_Altmer = sAltmer
    deity.Stance_Bosmer = sBosmer
    deity.Stance_Dunmer = sDunmer
    deity.Stance_Khajiit = sKhajiit
    deity.Stance_Argonian = sArgonian
    deity.Stance_Orc = sOrc
    deity.Stance_Redguard = sRedguard
EndFunction

Function ApplyStancesForDeity(PDV_DeityBase deity)
    String sName = deity.DeityName
    if sName == "kyne"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Talos"
        ApplyStances(deity, 0, 1, 0, 3, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Shor"
        ApplyStances(deity, 0, 1, 3, 3, 1, 1, 1, 1, 1, 3)
    elseIf sName == "Tsun"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Stuhn"
        ApplyStances(deity, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Kynareth"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Mara"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "akatosh"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Arkay"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Stendarr"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Julianos"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Dibella"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Zenithar"
        ApplyStances(deity, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1)
    elseIf sName == "magnus"
        ApplyStances(deity, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1)
    elseIf sName == "Y'ffre"
        ApplyStances(deity, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1)
    elseIf sName == "auri-el"
        ApplyStances(deity, 1, 1, 1, 0, 0, 1, 1, 1, 3, 1)
    elseIf sName == "xarxes"
        ApplyStances(deity, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1)
    ; Azura's stance branch read "azurah" while the canonical runtime name is "Azura"
    ; (trailing h; Papyrus == is case-insensitive so lowercase alone was never the
    ; problem), so her per-race stance matrix never applied. Dual-check both spellings.
    elseIf sName == "Azura" || sName == "Azurah"
        ApplyStances(deity, 2, 2, 1, 2, 1, 0, 0, 1, 2, 1)
    elseIf sName == "Boethiah"
        ApplyStances(deity, 2, 2, 2, 3, 2, 0, 1, 1, 3, 1)
    elseIf sName == "Mephala"
        ApplyStances(deity, 2, 2, 1, 2, 1, 0, 1, 1, 2, 1)
    elseIf sName == "Baan Dar"
        ApplyStances(deity, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1)
    elseIf sName == "rajhin"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "alkosh"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "khenarthi"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1)
    elseIf sName == "Tu'whacca"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "Leki"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "HoonDing"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0)
    elseIf sName == "Malacath"
        ApplyStances(deity, 1, 2, 1, 2, 1, 2, 1, 1, 0, 3)
    elseIf sName == "The Hist"
        ApplyStances(deity, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1)
    elseIf sName == "sithis"
        ApplyStances(deity, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2)
    elseIf sName == "trinimac"
        ApplyStances(deity, 1, 1, 1, 0, 1, 1, 1, 1, 2, 1)
    elseIf sName == "Z'en"
        ApplyStances(deity, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1)
    elseIf sName == "Syrabane"
        ; Added 2026-08-02. Syrabane shipped with NO Stance_* properties at all on
        ; 07164C:Devotion.esp (4 props where every sibling carries 14), so Stance_Altmer
        ; fell to the PDV_DeityBase default of 1 = STANCE_FOREIGN. That made
        ; IsRaceNativeForPlayer() false, which makes ScoreFromTable early-out -- every
        ; likes/dislikes row for him would have scored 0.0, and his curated signals would
        ; have landed at the 0.5x foreign multiplier. Values are from
        ; references/phase4/PDV_StanceMatrix.csv: Altmer NATIVE, all others FOREIGN.
        ApplyStances(deity, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1)
    endIf
EndFunction

Function ProcessDawn()
    if !PDV_FLST_AllDeities
        ; D1 sweep. This used to log unconditionally on EVERY dawn -- once per in-game day,
        ; forever, on a broken install. Latched to once per session: the condition is fatal
        ; and worth a line in the log even with debug off, but it does not change, so
        ; repeating it daily only buries whatever else the user is trying to read.
        if !_dawnRosterMissingLogged
            _dawnRosterMissingLogged = true
            Debug.Trace("[PDV] ProcessDawn: PDV_FLST_AllDeities not assigned. Dawn processing is disabled for this session.")
        endIf
        return
    endIf

    Manager.EnsureAkatoshRuntimeIdentity()
    Manager.OriginRuntime.RunDawnAwardAltmerAuriElDawn()
    Manager.OriginRuntime.RunDawnAwardAltmerXarxesRecord()
    RunDawnRefreshDevotionMarks()
    RunDawnConsolidateScratch()
    ProcessBroadPantheonDawn()
    Manager.OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    Manager.DaedricRuntime.RunDawnConsolidateDaedricWeek()
    RunDawnRefreshTrackStates()
    Manager.OriginRuntime.EvaluateAltmerCrisisAtDawn()
    RunDawnApplyDecayNoop()
    RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnProcessCommitmentOffersNoop()
    RunDawnNotifyNoop()
    Manager.Prisma.RunDawnBookOfDays()
    RunDawnChampionAmbient()
    Manager.OriginRuntime.SyncKhajiitRuntimeState()
    Manager.OriginRuntime.ProcessKhajiitAlkoshWordDrip()
    Manager.OriginRuntime.DisarmDunmerAncestorWatch()
    Manager.Prisma.RequestPanelRefresh()

    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] ProcessDawn complete.")
    endIf
EndFunction

Function RunDawnChampionAmbient()
    if !Manager.NotificationsEnabled() || Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf

    RunDawnChampionDeityAmbient()
    Manager.OriginRuntime.RunDawnAltmerHeritageAmbient()
EndFunction

Function RunDawnChampionDeityAmbient()
    PDV_DeityBase deity = Manager.GetActiveDeity()
    if !deity || GetTier(deity) < TIER_CHAMPION
        return
    endIf

    String cadenceKey = "PDV.Ambient.Champion." + deity.DeityIndex + ".Day"
    Int todayStamp = GetDevotionalDay() + 2
    Int lastStamp = ReadZeroReservedDevotionalDayStamp(cadenceKey)
    if lastStamp > 0 && (todayStamp - lastStamp) < Manager.Prisma.AMBIENT_CHAMPION_CADENCE_DAYS
        return
    endIf

    ; The deep variant needs a mark actually earned. Without that gate the alternation would show
    ; the "you have kept this for seasons" line to somebody who reached Champion four days ago.
    String countKey = "PDV.Ambient.Champion." + deity.DeityIndex + ".Count"
    Int shown = StorageUtil.GetIntValue(None, countKey)
    Bool deep = (shown % 2) == 1 && StorageUtil.GetIntValue(None, "PDV.LongDevotion.MarkHigh." + deity.DeityIndex) >= 1
    if !ShowChampionAmbientForDeity(deity, deep)
        return
    endIf

    WriteZeroReservedDevotionalDayStamp(cadenceKey)
    StorageUtil.SetIntValue(None, countKey, shown + 1)
    String variantLabel = "standing"
    if deep
        variantLabel = "long-devotion"
    endIf
    Manager.Trace(2, "Champion ambient surfaced for " + deity.DeityName + " (" + variantLabel + ")")
EndFunction

Bool Function ShowChampionAmbientForDeity(PDV_DeityBase deity, Bool deep)
    if deity == Manager.PDV_AuriEl
        if deep
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_AuriEl_ChampionAmbient_Return, "You have met every dawn. Auri-El has counted them all.")
        else
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn, "The dawn answers you now, as it answered your ancestors.")
        endIf
        return True
    elseIf deity == Manager.PDV_Magnus
        if deep
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Magnus_ChampionAmbient_ElderWay, "Magnus has watched you study for a long time now.")
        else
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Magnus_ChampionAmbient_Study, "The spells come easily today. Your study shows.")
        endIf
        return True
    elseIf deity == Manager.PDV_Xarxes
        if deep
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Xarxes_ChampionAmbient_Lineage, "Xarxes has kept the record of your whole life.")
        else
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Xarxes_ChampionAmbient_Record, "Xarxes has written your name into the record.")
        endIf
        return True
    elseIf deity == Manager.PDV_Trinimac
        if deep
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Trinimac_ChampionAmbient_Sword, "Your sword arm is steady. Trinimac made it so.")
        else
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Trinimac_ChampionAmbient_Watch, "You have held the line, and Trinimac saw it.")
        endIf
        return True
    elseIf deity == Manager.PDV_Syrabane
        if deep
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Syrabane_ChampionAmbient_Guard, "Syrabane has warded you so long you forget it is there.")
        else
            Manager.OriginRuntime.ShowAltmerNotification(Manager.PDV_Notif_Altmer_Syrabane_ChampionAmbient_Ward, "Syrabane's ward is on you, quiet and steady.")
        endIf
        return True
    elseIf deity == Manager.PDV_Kyne
        ; Kyne keeps her existing one-shot at the moment of the reach; this is the recurring layer
        ; on top of it, not a replacement. She ships one ambient record, so both slots speak it.
        Manager.OriginRuntime.ShowNordNotification(Manager.PDV_Notif_Nord_Kyne_ChampionAmbient_Storm, "The wind is blowing your way.")
        return True
    endIf

    return False
EndFunction

Function RunDawnConsolidateScratch()
    Manager.SetDawnHadActivity(False)
    StorageUtil.StringListClear(None, "PDV.BookOfDays.TodayFed")
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()

    while i < count
        Form deityForm = PDV_FLST_AllDeities.GetAt(i)
        PDV_DeityBase deity = deityForm as PDV_DeityBase

        ; Dawn skip (2026-07-05): a deity outside the origin roster with zero
        ; scratch and zero standing has nothing to consolidate and no surface
        ; that reads its Week ring or tier -- skip the per-dawn writes for it.
        ; Old saves with pre-gate foreign piety still consolidate (piety > 0
        ; falls through to the full body).
        Bool dawnSkip = False
        if deity && !Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, Manager.GetPlayerOriginRaceIndex())
            if StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday") == 0.0 && StorageUtil.GetFloatValue(deityForm, "PDV.Piety") == 0.0
                dawnSkip = True
            endIf
        endIf

        if deity && !dawnSkip
            EnsureDeityState(deity)

            Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
            Float scaledToday = pietyToday * GAIN_RATE_SCALE
            Float dailyCap = PIETY_DAILY_MAX_DELTA
            if PDV_ModePresetRef
                dailyCap = dailyCap * PDV_ModePresetRef.DailyCapScalar()
            endIf
            Float clampedToday = PDV_DevotionRules.ClampValue(scaledToday, -dailyCap, dailyCap)
            if clampedToday > 0.0
                clampedToday = clampedToday * GetGainProviderProduct(deity, Manager.PHASE_AT_DAWN)
                ; Record the gods fed today so the dawn digest can name them.
                Manager.Prisma.RecordBookOfDaysFedName(Manager.Prisma.GetPublicDeityDisplayName(deity))
            endIf
            Float oldPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
            Float newPiety = PDV_DevotionRules.ClampValue(oldPiety + clampedToday, 0.0, PIETY_MAX)

            StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
            ; Feed the Weekly tab's 7-day ring with this day's net before clearing it.
            Manager.Prisma.PushWeekNet(deityForm, pietyToday)
            StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
            if clampedToday != 0.0
                StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
                Manager.SetDawnHadActivity(True)
            endIf

            Int newTier = RecomputeTier(deity)

            if Manager.GetDebugLevel() >= 2
                Debug.Trace("[PDV] ProcessDawn: " + deity.DeityName + " piety " + oldPiety + " -> " + newPiety + ", today " + pietyToday + " scaled to " + scaledToday + " clamped/applied to " + clampedToday + ", tier now " + newTier)
            endIf
        endIf

        i += 1
    endWhile
EndFunction

Function RunDawnApplyDecayNoop()
    RunDawnApplyDecay()
EndFunction

Function RunDawnRefreshTrackStates()
    HandleCurseStateRefresh("dawn")

    if Manager.PDV_ConcordatStandingTrack
        Manager.PDV_ConcordatStandingTrack.RefreshState()
    endIf

    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_IMPERIAL
        Manager.OriginRuntime.RunDawnRefreshImperialAncestor()
    endIf

    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
        Manager.OriginRuntime.EvaluateKhajiitFocusedEmphasis()
        Manager.OriginRuntime.RefreshKhajiitLunarPosture("dawn")
    endIf

    if Manager.OriginRuntime.IsArgonianOrigin()
        Manager.OriginRuntime.RunDawnRefreshArgonianHist()
    endIf

    if Manager.OriginRuntime.IsAltmerOrigin()
        String oldAltmerBand = Manager.OriginRuntime.GetAltmerCommittedAlignmentJournalBand()
        if Manager.PDV_ThalmorAlignmentTrack
            Manager.PDV_ThalmorAlignmentTrack.RefreshState()
            Manager.OriginRuntime.MaybeSurfaceAltmerAlignmentBandChange(oldAltmerBand, "dawn")
        endIf
        Manager.OriginRuntime.RunDawnRefreshAltmerAncestor()
        Manager.OriginRuntime.SyncAltmerDisciplines(Game.GetPlayer())
    endIf

    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
        Manager.OriginRuntime.RunDawnRefreshNordAncestor()
    endIf

    if Manager.OriginRuntime.IsOrcOrigin()
        Manager.OriginRuntime.EvaluateOrcLifeModeAtDawn()
        Manager.OriginRuntime.SyncOrcTrialOfIron(Game.GetPlayer())
    endIf

    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON
        Manager.OriginRuntime.RunDawnRefreshBretonAncestor()
        Manager.OriginRuntime.DecayBretonWitchcraftExposureAtDawn()
        Manager.OriginRuntime.DecayBretonDruidicStandingAtDawn()
    endIf

    if Manager.OriginRuntime.IsBosmerOrigin() && Manager.PDV_BosmerPathTrack
        Manager.OriginRuntime.EnsureBosmerCurrentPathFallback()
        Manager.OriginRuntime.EvaluateBosmerForcedReckoning()
        Manager.OriginRuntime.SyncBosmerNaming(Game.GetPlayer())
        Manager.OriginRuntime.ArmBosmerDreamOnPathChange()
    endIf

    if Manager.OriginRuntime.IsRedguardOrigin() && Manager.PDV_RedguardSectTrack
        Manager.OriginRuntime.SyncRedguardRemembering(Game.GetPlayer())
    endIf
EndFunction

Function RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnApplySpellAndNeglectLayers()
EndFunction

Function RunDawnProcessCommitmentOffersNoop()
    RunDawnProcessCommitmentOffers()
EndFunction

Function RunDawnNotifyNoop()
    RunDawnNotify()
EndFunction

Function RunDawnApplyDecay()
    if !PDV_FLST_AllDeities
        return
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            ApplyDecayToDeity(deity, nowTime)
        endIf
        i += 1
    endWhile
EndFunction

Function RunDawnApplySpellAndNeglectLayers()
    if IsBroadWorshipActive()
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        ; Broad-lane lapse neglect (owner ruling 2026-06-27): a broad / full-pantheon worshipper who
        ; goes quiet for a few days feels gentle neglect too, not just focused patrons. Nord broad
        ; (Old Ways / Nine Divines) reuses the Kyne weather spell as its broad-lane neglect for now;
        ; per-race broad-lane neglect spells are a follow-on. Other races: no broad spell yet.
        Bool nordBroadLapsed = Manager.OriginRuntime.IsBroadLaneLapsed() && Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_NORD
        Manager.OriginRuntime.SyncKyneNeglectSpell(nordBroadLapsed)
        Manager.OriginRuntime.SyncNordPatronNeglectSpells()
        if nordBroadLapsed && StorageUtil.GetIntValue(None, "PDV.Neglect.PatronToastState") == 0
            Manager.Prisma.SendPrismaToast("journal", "warning", "Devotion quiet", "The gods feel distant as your devotion goes quiet.")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", PDV_DevotionRules.BoolToInt(nordBroadLapsed))
        Manager.FavorRuntime.UpdateContextualFavorRuntime()
        SyncFirstTierRaceRewardRuntime()
        return
    endIf

    if GetPatronState() != PATRON_STATE_ACTIVE || !Manager.GetActiveDeity()
        ClearAllNeglectFlags()
        StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", 0)
        StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", 0)
        Manager.OriginRuntime.SyncKyneNeglectSpell(False)
        Manager.OriginRuntime.SyncNordPatronNeglectSpells()
        Manager.FavorRuntime.UpdateContextualFavorRuntime()
        SyncFirstTierRaceRewardRuntime()
        return
    endIf

    ClearAllNeglectFlags()
    Int activeCount = ApplyGenericNeglectFlags()
    ; Recency lapse (owner ruling 2026-06-27): the active patron bites after a few quiet days even
    ; though it is decay-shielded and rarely reaches the piety<=10 floor from absence. Force-flag it
    ; on lapse so the existing patron-spell (Kyne) + toast logic below fires. Non-Kyne patrons get
    ; the toast now; their own flat neglect spell is a follow-on (per-patron Nord neglect).
    if IsPatronLapsed(Manager.GetActiveDeity()) && !IsNeglectFlagActive(Manager.GetActiveDeity())
        SetNeglectFlag(Manager.GetActiveDeity(), True)
        activeCount += 1
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.ActiveCount", activeCount)
    ; Owner ruling 2026-06-26: committing to a patron fades other gods' neglect. Kyne's
    ; weather-neglect now fires only when Kyne is the player's own active patron; any
    ; non-Kyne focus (any tier) suppresses it. Broad worship already had no Kyne penalty.
    Manager.OriginRuntime.SyncKyneNeglectSpell(IsNeglectFlagActive(Manager.PDV_Kyne) && Manager.GetActiveDeity() == Manager.PDV_Kyne)
    Manager.OriginRuntime.SyncNordPatronNeglectSpells()
    Manager.FavorRuntime.UpdateContextualFavorRuntime()

    Bool patronNeglected = IsNeglectFlagActive(Manager.GetActiveDeity())
    Int priorPatronToastState = StorageUtil.GetIntValue(None, "PDV.Neglect.PatronToastState")
    if patronNeglected && priorPatronToastState == 0
        Manager.Prisma.SendPrismaEventToast("neglect", Manager.GetActiveDeity(), "", "", "")
        Manager.Prisma.SurfaceTransition("neglect", Manager.GetActiveDeity().DeityName, "drop", Manager.GetActiveDeity().DeityIndex, "absence")
    elseIf !patronNeglected && priorPatronToastState == 1
        Manager.Prisma.SurfaceTransition("neglect", Manager.GetActiveDeity().DeityName, "recover", Manager.GetActiveDeity().DeityIndex, "renewal")
    endIf
    StorageUtil.SetIntValue(None, "PDV.Neglect.PatronToastState", PDV_DevotionRules.BoolToInt(patronNeglected))
    SyncFirstTierRaceRewardRuntime()
EndFunction

Function RunDawnProcessCommitmentOffers()
    if Manager.OriginRuntime.IsBosmerOrigin()
        Manager.OriginRuntime.EvaluateBosmerPathSuggestion()
        return
    endIf

    RefreshCommitmentOfferQualificationGuards()
    EvaluateFormalCommitmentOffer()
EndFunction

Function RefreshCommitmentOfferQualificationGuards()
    if !PDV_FLST_AllDeities
        return
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if UsesFormalCommitmentOffersForDeity(deity) && GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD
            StorageUtil.SetIntValue(deity as Form, "PDV.Commitment.Offered", 0)
        endIf
        i += 1
    endWhile
EndFunction

Function RunDawnNotify()
    Manager.Prisma.SendPrismaEventToast("dawn", None, "", "", "", Manager.GetDawnHadActivity())
    Manager.Prisma.RefreshDiegeticMedallion("dawn")
    Manager.Trace(2, "Pattern summary: " + Manager.DebugRuntime.DebugGetPatternProvingSummary())
EndFunction

Function ApplyDecayToDeity(PDV_DeityBase deity, Float nowTime)
    if !deity
        return
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE && deity == Manager.GetActiveDeity()
        return
    endIf

    EnsureDeityState(deity)
    Form deityForm = deity as Form
    Float lastEventTime = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    if lastEventTime == 0.0
        return
    endIf

    Float decayGraceDays = DECAY_GRACE_DAYS
    if PDV_ModePresetRef
        decayGraceDays = decayGraceDays * PDV_ModePresetRef.GraceScalar()
    endIf

    if (nowTime - lastEventTime) < decayGraceDays
        return
    endIf

    Float currentPiety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    if currentPiety <= 0.0
        return
    endIf

    ; fix-plan 4.2: decay is applied BY the dawn pass, so its once-per-day guard must
    ; use the dawn day. On raw midnight a sleep through 00:00 could let the same dawn
    ; cycle decay twice (or skip a day) relative to the pass that drives it.
    Int currentDay = GetDevotionalDay() + 2
    if StorageUtil.GetIntValue(deityForm, "PDV.LastDecayAppliedDay") == currentDay
        return
    endIf

    Float multiplier = 1.0
    if IsBroadWorshipActive()
        multiplier = BROAD_WORSHIP_DECAY_MULTIPLIER
    endIf

    Float decayScalar = 1.0
    if PDV_ModePresetRef
        decayScalar = PDV_ModePresetRef.DecayScalar()
    endIf
    Float newPiety = currentPiety - (DECAY_PER_DAY * multiplier * deity.GetEffectiveDecayMultiplier() * GetGainProviderProduct(deity, Manager.PHASE_DECAY) * decayScalar)
    Float floorValue = GetDecayFloorForDeity(deity, currentPiety)
    if newPiety < floorValue
        newPiety = floorValue
    endIf

    StorageUtil.SetIntValue(deityForm, "PDV.LastDecayAppliedDay", currentDay)

    if newPiety != currentPiety
        StorageUtil.SetFloatValue(deityForm, "PDV.Piety", newPiety)
        RecomputeTier(deity)
        Manager.Trace(2, "Decay applied to " + deity.DeityName + ": " + currentPiety + " -> " + newPiety)
    endIf
EndFunction

Function ForceSetPiety(Float amount)
    if !Manager.GetActiveDeity()
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetPiety skipped: no active patron.")
        endIf
        return
    endIf

    Form deityForm = Manager.GetActiveDeity() as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", PDV_DevotionRules.ClampValue(amount, 0.0, PIETY_MAX))
    RecomputeTier(Manager.GetActiveDeity(), False)
    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_KHAJIIT
        Manager.OriginRuntime.EvaluateKhajiitFocusedEmphasis()
        Manager.OriginRuntime.SyncKhajiitRuntimeState()
    endIf
EndFunction

Function ForceSetActiveDeityByIndex(Int deityIndex)
    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity && deityIndex != -1
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetActiveDeityByIndex failed: no deity with index " + deityIndex)
        endIf
        return
    endIf

    SetActiveDeity(deity)
    ; Resync the race reward families immediately (mirrors DebugForceSetPietyByIndex):
    ; without this a debug patron override surfaces every toast/panel/Survey cue but
    ; grants no reward spells until the next dawn pass -- reads as "rewards not wired".
    SyncFirstTierRaceRewardRuntime()
EndFunction

Function UnsafeFaultInjectActiveDeity(PDV_DeityBase deity, String reason)
    if !deity
        Manager.Trace(1, "[UNSAFE_FAULT_INJECTION] Active-deity injection rejected: no deity.")
        return
    endIf

    String injectionReason = reason
    if injectionReason == ""
        injectionReason = "unspecified"
    endIf
    StorageUtil.SetIntValue(None, "PDV.Debug.UnsafeFaultInjectionActive", 1)
    StorageUtil.SetIntValue(None, "PDV.Debug.UnsafeFaultInjectionEver", 1)
    StorageUtil.SetStringValue(None, "PDV.Debug.UnsafeFaultInjectionReason", injectionReason)
    StorageUtil.SetFormValue(None, "PDV.Debug.UnsafeFaultInjectionDeity", deity as Form)
    Debug.Trace("[PDV][UNSAFE_FAULT_INJECTION] Injecting active deity " + deity.DeityName + ": " + injectionReason)
    UnsafeApplyActiveDeityState(deity)
    SyncFirstTierRaceRewardRuntime()
EndFunction

Bool Function IsUnsafeFaultInjectionActive()
    return StorageUtil.GetIntValue(None, "PDV.Debug.UnsafeFaultInjectionActive") == 1
EndFunction

Function ClearUnsafeFaultInjection()
    if !IsUnsafeFaultInjectionActive()
        return
    endIf

    ClearPendingCommitment()
    SetActiveDeity(None)
    SyncFirstTierRaceRewardRuntime()
    StorageUtil.UnsetIntValue(None, "PDV.Debug.UnsafeFaultInjectionActive")
    StorageUtil.UnsetStringValue(None, "PDV.Debug.UnsafeFaultInjectionReason")
    StorageUtil.UnsetFormValue(None, "PDV.Debug.UnsafeFaultInjectionDeity")
    Manager.DebugRuntime.DebugClosePrismaSurfaces()
    Manager.Prisma.RequestPanelRefresh()
    Debug.Trace("[PDV][UNSAFE_FAULT_INJECTION] Cleared injected state; PDV.Debug.UnsafeFaultInjectionEver remains set and this run does not count as gameplay proof.")
EndFunction

Function ForceSetPietyToday(Float amount)
    if !Manager.GetActiveDeity()
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] ForceSetPietyToday skipped: no active patron.")
        endIf
        return
    endIf

    StorageUtil.SetFloatValue(Manager.GetActiveDeity() as Form, "PDV.PietyToday", amount)
EndFunction

Function BeginBroadPantheonEvent(String logicalEventId)
    ; Papyrus may schedule independent event stacks on this quest. Do not let a
    ; second logical act borrow the first stack's temporary accumulator.
    ;
    ; DELIBERATELY NOT the Authoria 7.1 "containment" rewrite (1.0.3 review). That
    ; change dropped this wait and instead folded a second concurrent act into the
    ; live event as a nested depth. It is cheaper -- this is a 100 Hz busy loop for
    ; up to two real seconds -- but it MERGES two genuinely simultaneous acts into
    ; one broad-lane entry, and the second act's deltas are then judged against the
    ; FIRST act's pool. The broad-pantheon contract requires the opposite: distinct
    ; logical events serialize, and a stalled owner FAILS CLOSED (scope discarded)
    ; rather than silently absorbing the newcomer. pdv_broad_pantheon_audit asserts
    ; this shape (source.concurrent-event-serialization); do not "optimize" it away
    ; without changing the contract first.
    Float waitStarted = Utility.GetCurrentRealTime()
    while _broadPantheonEventDepth > 0 && _broadPantheonEventId != logicalEventId
        Utility.WaitMenuMode(0.01)
        if Utility.GetCurrentRealTime() - waitStarted >= 2.0
            Manager.Trace(1, "[PDV][BROAD_SCOPE_ABORT] discarded stalled logical event " + _broadPantheonEventId + " before " + logicalEventId)
            ClearBroadPantheonEventScope()
        endIf
    endWhile
    if _broadPantheonEventDepth == 0
        _broadPantheonEventId = logicalEventId
        _broadPantheonEventPool = GetActiveBroadPantheonPoolId()
        _broadPantheonBestPositive = 0.0
        _broadPantheonWorstNegative = 0.0
    endIf
    _broadPantheonEventDepth += 1
EndFunction

Bool Function JoinBroadPantheonEvent(String logicalEventId)
    if logicalEventId == "" || _broadPantheonEventDepth <= 0 || _broadPantheonEventId != logicalEventId
        Manager.Trace(1, "[PDV][BROAD_SCOPE_MISMATCH] cannot join " + logicalEventId + " while " + _broadPantheonEventId + " is active")
        return False
    endIf
    _broadPantheonEventDepth += 1
    return True
EndFunction

Function AccumulateBroadPantheonDelta(PDV_DeityBase deity, Float appliedDelta)
    if _broadPantheonEventDepth <= 0 || _broadPantheonEventPool == "" || !deity
        return
    endIf
    if !IsDeityEligibleForBroadPantheon(deity, _broadPantheonEventPool)
        return
    endIf

    if appliedDelta > 0.0 && appliedDelta > _broadPantheonBestPositive
        _broadPantheonBestPositive = appliedDelta
    elseIf appliedDelta < 0.0 && appliedDelta < _broadPantheonWorstNegative
        _broadPantheonWorstNegative = appliedDelta
    endIf
EndFunction

Function FlushBroadPantheonEvent()
    if _broadPantheonEventDepth > 1
        _broadPantheonEventDepth -= 1
        return
    endIf

    Float chosenDelta = 0.0
    if _broadPantheonBestPositive > 0.0
        chosenDelta = _broadPantheonBestPositive
    elseIf _broadPantheonWorstNegative < 0.0
        chosenDelta = _broadPantheonWorstNegative
    endIf

    ApplyBroadPantheonEventResult(_broadPantheonEventPool, _broadPantheonEventId, chosenDelta)

    ClearBroadPantheonEventScope()
EndFunction

Function CommitDetachedBroadPantheonEvent(String logicalEventId, String poolId, Float bestPositive, Float worstNegative, Int eventType)
    Float chosenDelta = 0.0
    if bestPositive > 0.0
        chosenDelta = bestPositive
    elseIf worstNegative < 0.0
        chosenDelta = worstNegative
    endIf
    if logicalEventId == ""
        logicalEventId = "likes_dislikes_" + eventType + "_" + Utility.GetCurrentGameTime()
    endIf
    ApplyBroadPantheonEventResult(poolId, logicalEventId, chosenDelta)
EndFunction

Function ApplyBroadPantheonEventResult(String poolId, String logicalEventId, Float chosenDelta)
    if poolId == "" || logicalEventId == "" || chosenDelta == 0.0
        return
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    Bool duplicateEvent = IsRecentBroadPantheonEventDuplicate(poolId, logicalEventId, nowTime)
    if duplicateEvent
        return
    endIf

    CatchUpBroadPantheonDecayBeforeCurrentDay(poolId)
    if GetBroadPantheonScratch(poolId) == 0.0
        WriteZeroReservedDevotionalDayStamp(GetBroadPantheonScratchDayKey(poolId))
    endIf
    StorageUtil.AdjustFloatValue(None, GetBroadPantheonScratchKey(poolId), chosenDelta)
    StorageUtil.SetStringValue(None, GetBroadPantheonLastEventKey(poolId), logicalEventId)
    StorageUtil.SetFloatValue(None, GetBroadPantheonLastEventTimeKey(poolId), nowTime)
    RememberBroadPantheonEvent(poolId, logicalEventId, nowTime)
    if chosenDelta > 0.0
        WriteZeroReservedDevotionalDayStamp(GetBroadPantheonLastGainDayKey(poolId))
    endIf
EndFunction

Function ClearBroadPantheonEventScope()
    _broadPantheonEventDepth = 0
    _broadPantheonEventId = ""
    _broadPantheonEventPool = ""
    _broadPantheonBestPositive = 0.0
    _broadPantheonWorstNegative = 0.0
EndFunction

Bool Function IsRecentBroadPantheonEventDuplicate(String poolId, String logicalEventId, Float nowTime)
    if logicalEventId == ""
        return False
    endIf
    String idKey = GetBroadPantheonRecentEventIdsKey(poolId)
    String timeKey = GetBroadPantheonRecentEventTimesKey(poolId)
    Int count = StorageUtil.StringListCount(None, idKey)
    Int index = count - 1
    while index >= 0
        if StorageUtil.StringListGet(None, idKey, index) == logicalEventId
            Float priorTime = StorageUtil.FloatListGet(None, timeKey, index)
            if priorTime > 0.0 && (nowTime - priorTime) < 0.02
                return True
            endIf
        endIf
        index -= 1
    endWhile
    return False
EndFunction

Function RememberBroadPantheonEvent(String poolId, String logicalEventId, Float nowTime)
    String idKey = GetBroadPantheonRecentEventIdsKey(poolId)
    String timeKey = GetBroadPantheonRecentEventTimesKey(poolId)
    while StorageUtil.StringListCount(None, idKey) >= 8
        StorageUtil.StringListRemoveAt(None, idKey, 0)
        StorageUtil.FloatListRemoveAt(None, timeKey, 0)
    endWhile
    StorageUtil.StringListAdd(None, idKey, logicalEventId, True)
    StorageUtil.FloatListAdd(None, timeKey, nowTime, True)
EndFunction

String Function GetActiveBroadPantheonPoolId()
    if GetPatronState() != PATRON_STATE_BROAD
        return ""
    endIf
    Int origin = Manager.GetPlayerOriginRaceIndex()
    if origin == Manager.ORIGIN_IMPERIAL
        if Manager.OriginRuntime.IsImperialVampireStateActive()
            return ""
        endIf
        return BROAD_PANTHEON_IMPERIAL
    elseIf origin == Manager.ORIGIN_NORD
        if Manager.OriginRuntime.GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            return BROAD_PANTHEON_NORD_NINE
        endIf
        return BROAD_PANTHEON_NORD_OLD
    endIf
    return ""
EndFunction

Bool Function IsDeityEligibleForBroadPantheon(PDV_DeityBase deity, String poolId)
    if !deity
        return False
    endIf
    if poolId == BROAD_PANTHEON_IMPERIAL
        if deity == Manager.PDV_Talos
            return StorageUtil.GetIntValue(None, "PDV.Imperial.TalosBroadUnlocked") == 1
        endIf
        return deity == PDV_Akatosh || deity == PDV_Arkay || deity == PDV_Dibella || deity == PDV_Julianos || deity == PDV_Kynareth || deity == PDV_Mara || deity == PDV_Stendarr || deity == PDV_Zenithar
    elseIf poolId == BROAD_PANTHEON_NORD_OLD
        return deity == Manager.PDV_Kyne || deity == Manager.PDV_Shor || deity == Manager.PDV_Tsun || deity == Manager.PDV_Stuhn || deity == PDV_Mara || deity == PDV_Arkay || deity == PDV_Dibella || deity == Manager.PDV_Talos
    elseIf poolId == BROAD_PANTHEON_NORD_NINE
        return deity == PDV_Akatosh || deity == PDV_Arkay || deity == PDV_Dibella || deity == PDV_Julianos || deity == PDV_Kynareth || deity == PDV_Mara || deity == PDV_Stendarr || deity == PDV_Zenithar || deity == Manager.PDV_Talos
    endIf
    return False
EndFunction

Float Function GetBroadPantheonStanding(String poolId)
    if poolId == ""
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(None, GetBroadPantheonStandingKey(poolId))
EndFunction

Float Function GetBroadPantheonScratch(String poolId)
    if poolId == ""
        return 0.0
    endIf
    return StorageUtil.GetFloatValue(None, GetBroadPantheonScratchKey(poolId))
EndFunction

Function SetBroadPantheonStanding(String poolId, Float standing, String reason = "")
    if poolId == ""
        return
    endIf
    StorageUtil.SetFloatValue(None, GetBroadPantheonStandingKey(poolId), PDV_DevotionRules.ClampValue(standing, 0.0, BROAD_PANTHEON_POOL_MAX))
    StorageUtil.SetStringValue(None, GetBroadPantheonLastEventKey(poolId), reason)
EndFunction

Function ResetBroadPantheonPool(String poolId)
    SetBroadPantheonStanding(poolId, 0.0, "debug_reset")
    StorageUtil.SetFloatValue(None, GetBroadPantheonScratchKey(poolId), 0.0)
    StorageUtil.SetIntValue(None, GetBroadPantheonScratchDayKey(poolId), 0)
    StorageUtil.SetIntValue(None, GetBroadPantheonScratchDayKey(poolId) + ".Encoding", 2)
    StorageUtil.SetIntValue(None, GetBroadPantheonLastGainDayKey(poolId), 0)
    WriteZeroReservedDevotionalDayStamp(GetBroadPantheonLastProcessedDayKey(poolId))
    StorageUtil.SetFloatValue(None, GetBroadPantheonLastEventTimeKey(poolId), 0.0)
    StorageUtil.StringListClear(None, GetBroadPantheonRecentEventIdsKey(poolId))
    StorageUtil.FloatListClear(None, GetBroadPantheonRecentEventTimesKey(poolId))
    SyncBroadPantheonRewards(Game.GetPlayer())
EndFunction

Function ProcessBroadPantheonDawn()
    Float signedCap = PIETY_DAILY_MAX_DELTA
    if PDV_ModePresetRef
        signedCap = signedCap * PDV_ModePresetRef.DailyCapScalar()
    endIf
    ; Every pool is processed, including a suppressed pool outside activePool,
    ; so commitment and Nord baseline switching never pause the
    ; BROAD_PANTHEON_DECAY_PER_DAWN inactivity rule.
    ProcessOneBroadPantheonDawn(BROAD_PANTHEON_IMPERIAL, signedCap)
    ProcessOneBroadPantheonDawn(BROAD_PANTHEON_NORD_OLD, signedCap)
    ProcessOneBroadPantheonDawn(BROAD_PANTHEON_NORD_NINE, signedCap)
    SyncBroadPantheonRewards(Game.GetPlayer())
EndFunction

Function ProcessOneBroadPantheonDawn(String poolId, Float signedCap)
    ProcessBroadPantheonThroughDay(poolId, GetDevotionalDay(), signedCap, "dawn")
EndFunction

Function ProcessBroadPantheonThroughDay(String poolId, Int targetDay, Float signedCap, String reason)
    Int processedStamp = ReadZeroReservedDevotionalDayStamp(GetBroadPantheonLastProcessedDayKey(poolId))
    Int lastProcessedDay = targetDay - 1
    if processedStamp <= 0
        ; Existing saves process the target dawn once without inventing older
        ; retroactive inactivity before this runtime knew the key.
        lastProcessedDay = targetDay - 1
    else
        lastProcessedDay = processedStamp - 2
    endIf
    if targetDay <= lastProcessedDay
        return
    endIf

    Float standing = GetBroadPantheonStanding(poolId)
    Float standingBeforeProcessing = standing
    Float scratch = GetBroadPantheonScratch(poolId)
    Int scratchStamp = ReadZeroReservedDevotionalDayStamp(GetBroadPantheonScratchDayKey(poolId))
    Int scratchDay = targetDay
    if scratchStamp > 0
        scratchDay = scratchStamp - 2
    endIf
    Bool scratchEligible = scratch != 0.0 && scratchDay <= targetDay
    Float applied = 0.0
    if scratchEligible
        applied = PDV_DevotionRules.ClampValue(scratch * GAIN_RATE_SCALE, 0.0 - signedCap, signedCap)
        if applied != 0.0
            standing = PDV_DevotionRules.ClampValue(standing + applied, 0.0, BROAD_PANTHEON_POOL_MAX)
            SetBroadPantheonStanding(poolId, standing, reason + "_fold")
            if applied > 0.0 && ReadZeroReservedDevotionalDayStamp(GetBroadPantheonLastGainDayKey(poolId)) <= 0
                StorageUtil.SetIntValue(None, GetBroadPantheonLastGainDayKey(poolId), scratchDay + 2)
                StorageUtil.SetIntValue(None, GetBroadPantheonLastGainDayKey(poolId) + ".Encoding", 2)
            endIf
        endIf
        StorageUtil.SetFloatValue(None, GetBroadPantheonScratchKey(poolId), 0.0)
        StorageUtil.SetIntValue(None, GetBroadPantheonScratchDayKey(poolId), 0)
    endIf

    if standing > 0.0
        Int lastGainStamp = ReadZeroReservedDevotionalDayStamp(GetBroadPantheonLastGainDayKey(poolId))
        Int lastGainDay = lastGainStamp - 2
        Int firstDecayDay = lastProcessedDay + 1
        ; A folded positive or negative scratch is an activity day.  It may
        ; change standing, but can never also suffer inactivity decay.
        if scratchEligible && firstDecayDay <= scratchDay
            firstDecayDay = scratchDay + 1
        endIf
        if lastGainStamp > 0 && firstDecayDay <= lastGainDay + (BROAD_PANTHEON_DECAY_GRACE_DAYS as Int)
            firstDecayDay = lastGainDay + (BROAD_PANTHEON_DECAY_GRACE_DAYS as Int) + 1
        endIf
        Int elapsedDecayDays = targetDay - firstDecayDay + 1
        if elapsedDecayDays > 0
            SetBroadPantheonStanding(poolId, standing - (BROAD_PANTHEON_DECAY_PER_DAWN * elapsedDecayDays), reason + "_inactive_decay")
        endIf
    endIf
    StorageUtil.SetIntValue(None, GetBroadPantheonLastProcessedDayKey(poolId), targetDay + 2)
    StorageUtil.SetIntValue(None, GetBroadPantheonLastProcessedDayKey(poolId) + ".Encoding", 2)
    ; Debug boundary seeds are deliberately silent.  A broad transition becomes
    ; player-facing only when real signed scratch settles at dawn.
    if applied > 0.0 && poolId == GetActiveBroadPantheonPoolId()
        MaybeSendBroadPantheonTierToast(poolId, standingBeforeProcessing, GetBroadPantheonStanding(poolId))
    endIf
    Manager.Trace(1, "[PDV][BROAD_CATCHUP] pool=" + poolId + " through=" + targetDay + " applied=" + applied + " standing=" + GetBroadPantheonStanding(poolId))
EndFunction

Int Function GetBroadPantheonTierForStanding(Float standing)
    if standing >= BROAD_PANTHEON_FAITHFUL_THRESHOLD
        return TIER_DEVOTED
    elseIf standing >= BROAD_PANTHEON_SEEKER_THRESHOLD
        return TIER_SEEKER
    endIf
    return TIER_NONE
EndFunction

Function MaybeSendBroadPantheonTierToast(String poolId, Float previousStanding, Float currentStanding)
    Int previousTier = GetBroadPantheonTierForStanding(previousStanding)
    Int currentTier = GetBroadPantheonTierForStanding(currentStanding)
    if currentTier <= previousTier
        return
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if poolId != GetActiveBroadPantheonPoolId() || !Manager.OriginRuntime.HasBroadLanePresentation(originRace)
        return
    endIf

    String familyName = Manager.OriginRuntime.GetBroadLaneDisplayName(originRace)
    String tierName = Manager.OriginRuntime.GetBroadLaneStandingLabel(originRace, currentTier)
    SendPrismaBroadPantheonTierToast(familyName, tierName, Manager.OriginRuntime.GetBroadLaneSymbol(originRace))
EndFunction

Bool Function SendPrismaBroadPantheonTierToast(String familyName, String tierName, String symbolName)
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"pantheon\""
    j = j + ",\"pantheon\":\"" + PDV_DevotionRules.JsonSafeString(familyName) + "\""
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierName) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + "}}"
    return Manager.Prisma.SendPrismaToastPayloadOrFallback(j, "", familyName + " has reached " + tierName + ".", True)
EndFunction

Function CatchUpBroadPantheonDecayBeforeCurrentDay(String poolId)
    Int targetDay = GetDevotionalDay() - 1
    Float signedCap = PIETY_DAILY_MAX_DELTA
    if PDV_ModePresetRef
        signedCap = signedCap * PDV_ModePresetRef.DailyCapScalar()
    endIf
    ProcessBroadPantheonThroughDay(poolId, targetDay, signedCap, "pre_event_catchup")
EndFunction

String Function GetBroadPantheonStandingKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".Standing"
EndFunction

String Function GetBroadPantheonScratchKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".Scratch"
EndFunction

String Function GetBroadPantheonScratchDayKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".ScratchDay"
EndFunction

String Function GetBroadPantheonLastEventKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".LastEvent"
EndFunction

String Function GetBroadPantheonLastEventTimeKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".LastEventTime"
EndFunction

String Function GetBroadPantheonRecentEventIdsKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".RecentEventIds"
EndFunction

String Function GetBroadPantheonRecentEventTimesKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".RecentEventTimes"
EndFunction

String Function GetBroadPantheonLastGainDayKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".LastGainDay"
EndFunction

String Function GetBroadPantheonLastProcessedDayKey(String poolId)
    return "PDV.BroadPantheon." + poolId + ".LastProcessedDay"
EndFunction

Int Function GetDevotionalDay()
    Float shiftedTime = Utility.GetCurrentGameTime() - 0.25
    Int truncatedDay = shiftedTime as Int
    if shiftedTime < 0.0 && shiftedTime != (truncatedDay as Float)
        return truncatedDay - 1
    endIf
    return truncatedDay
EndFunction

Int Function ReadZeroReservedDevotionalDayStamp(String keyName)
    ; Legacy ".Encoding < 2" +1-stamp fixup removed (not-save-safe: a fresh save only ever
    ; carries the +2 write scheme). The +2 WriteZeroReservedDevotionalDayStamp scheme stays
    ; live -- gates compare == GetDevotionalDay()+2.
    return StorageUtil.GetIntValue(None, keyName)
EndFunction

Function WriteZeroReservedDevotionalDayStamp(String keyName)
    StorageUtil.SetIntValue(None, keyName, GetDevotionalDay() + 2)
    StorageUtil.SetIntValue(None, keyName + ".Encoding", 2)
EndFunction

Float Function AwardPietyInternal(PDV_DeityBase deity, Float amount, Bool allowRivalry, String reason = "", Bool applyStanceMultiplier = True, Bool trackBroadPantheon = True)
    Bool queuedQuestReaction = Manager.PDV_QuestReactionRuntimeService.GetQrQueueTransactionActive()
    Bool ownsBroadEvent = trackBroadPantheon && !queuedQuestReaction && _broadPantheonEventDepth == 0
    if ownsBroadEvent
        Manager.SetBroadPantheonSelfEventSequence(Manager.GetBroadPantheonSelfEventSequence() + (1))
        if Manager.GetBroadPantheonSelfEventSequence() <= 0
            Manager.SetBroadPantheonSelfEventSequence(1)
        endIf
        String eventLabel = reason
        if eventLabel == ""
            eventLabel = "piety"
        endIf
        BeginBroadPantheonEvent(eventLabel + "_auto_" + Manager.GetBroadPantheonSelfEventSequence())
    endIf
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] AwardPiety skipped: no deity supplied.")
        endIf
        if ownsBroadEvent
            FlushBroadPantheonEvent()
        endIf
        return 0.0
    endIf

    EnsureDeityState(deity)

    Int stance = deity.GetStanceForPlayer()
    Float appliedAmount = RunGainPipeline(deity, amount, stance, applyStanceMultiplier)
    if queuedQuestReaction
        Manager.PDV_QuestReactionRuntimeService.AccumulateQueuedQuestReactionBroadDelta(deity, appliedAmount)
    elseIf trackBroadPantheon
        AccumulateBroadPantheonDelta(deity, appliedAmount)
    endIf

    StorageUtil.AdjustFloatValue(deityForm, "PDV.PietyToday", appliedAmount)
    if appliedAmount != 0.0
        StorageUtil.SetFloatValue(deityForm, "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
    endIf
    if appliedAmount > 0.0
        RecordCommitmentSignalDay(deity)
        ; Global "last devotional act" stamp for broad-lane lapse neglect (IsBroadLaneLapsed);
        ; the broad lane has no single patron, so it tracks any positive pantheon act.
        StorageUtil.SetFloatValue(None, "PDV.Devotion.LastActTime", Utility.GetCurrentGameTime())
    endIf
    if allowRivalry && appliedAmount < 0.0 && _pendingLikesDislikesEventType >= 0
        ApplyDisfavorSting(deity, appliedAmount, reason)
    endIf

    ; Attribution: any deity with visible piety movement must carry the reason into
    ; its recent-driver ring. The dashboard shows every deity with PietyToday, so
    ; gating this to the active patron leaves broad-pantheon gains unexplained.
    if appliedAmount != 0.0
        RecordDeityDriver(deity, reason, appliedAmount)
    endIf

    if Manager.GetDebugLevel() >= 2 && !queuedQuestReaction
        Debug.Trace("[PDV] AwardPiety: " + deity.DeityName + " raw " + amount + ", applied " + appliedAmount + ", stance " + stance + ", today=" + StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday"))
    endIf

    if appliedAmount > 0.0 && deity == Manager.GetActiveDeity() && !Manager.GetSuppressAwardFavorToast()
        Manager.Prisma.SendPrismaEventToast("favor", deity, "", "", "")
    endIf

    if allowRivalry && appliedAmount > 0.0 && stance == deity.STANCE_HOSTILE
        ApplyRivalryPenalties(deity, appliedAmount)
    endIf

    if appliedAmount != 0.0 && !queuedQuestReaction
        Manager.Prisma.RequestPanelRefresh()
    endIf
    ; B7 / fix-plan 4.3. This is the one place that knows whether the proposed delta
    ; survived RunGainPipeline. PDV_DeityBase.ScoreRepeatableAction now only PEEKS at
    ; the daily cap and cooldown and queues the bookkeeping; it is spent here, and only
    ; when piety actually landed. A multiplied-to-zero award (curse, ineligibility,
    ; stigma, survival context, lunar misalignment, mode preset) no longer burns the
    ; cap slot and starts the cooldown for nothing. Covers all three ScoreAction
    ; consumers -- ActionRouter, EventBus and HandleShoutAttack -- because every one of
    ; them routes its nonzero delta straight into AwardPietyFromLikesDislikes.
    if appliedAmount != 0.0
        deity.CommitPendingRepeatableActions()
    else
        deity.DiscardPendingRepeatableActions()
    endIf
    ; A Khajiit focus may already have the required behavioral lead when this
    ; piety movement crosses Seeker. Evaluate here as well as on weight changes
    ; so emergence cannot lag until the next unrelated action.
    if appliedAmount != 0.0 && Manager.OriginRuntime.IsKhajiitOrigin() && Manager.OriginRuntime.GetKhajiitFocusForDeity(deity) != Manager.KHAJIIT_FOCUS_NONE
        Manager.OriginRuntime.EvaluateKhajiitFocusedEmphasis()
    endIf
    if ownsBroadEvent
        FlushBroadPantheonEvent()
    endIf
    return appliedAmount
EndFunction

Function ApplyDisfavorSting(PDV_DeityBase deity, Float appliedAmount, String sourceTag)
    if !deity || appliedAmount >= 0.0 || _pendingLikesDislikesEventType < 0
        return
    endIf

    Float baseDelta = GetDislikeBaseDeltaForEvent(deity, _pendingLikesDislikesEventType)
    if baseDelta >= 0.0
        return
    endIf

    Float absDelta = 0.0 - baseDelta
    if absDelta <= DISFAVOR_LIGHT_MIN_DELTA
        return
    endIf

    if !HasDisfavorStanding(deity)
        Manager.Trace(3, "Disfavor sting skipped: no standing for " + deity.DeityName)
        return
    endIf

    Int domainValue = DomainForDeity(deity)
    if domainValue == DISFAVOR_DOMAIN_NONE
        Manager.Trace(2, "Disfavor sting skipped: no domain for " + deity.DeityName)
        return
    endIf

    if IsDisfavorRepeatSuppressed(deity, domainValue, _pendingLikesDislikesEventType)
        Manager.Trace(3, "Disfavor sting suppressed for repeat " + deity.DeityName + " / " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    UpdateDisfavorStingRuntime()

    Bool domainAlreadyActive = IsDisfavorDomainActive(domainValue)
    if !domainAlreadyActive && CountActiveDisfavorStings() >= DISFAVOR_MAX_ACTIVE_DOMAINS
        Manager.Trace(2, "Disfavor sting suppressed by active-domain cap for " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    Bool sharpBand = absDelta > DISFAVOR_SHARP_MIN_DELTA
    Spell targetSpell = GetDisfavorSpell(domainValue, sharpBand)
    if !targetSpell
        Manager.Trace(1, "Disfavor sting skipped: missing spell for " + GetDisfavorDomainLabel(domainValue))
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    playerRef.AddSpell(targetSpell, False)
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 1)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), Utility.GetCurrentGameTime() + GetDisfavorDurationDays(sharpBand))
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), GetDisfavorBandLabel(sharpBand))
    MarkDisfavorRepeatUsed(deity, domainValue, _pendingLikesDislikesEventType)
    Manager.Trace(1, "Disfavor sting applied: " + deity.DeityName + " -> " + GetDisfavorDomainLabel(domainValue) + " " + GetDisfavorBandLabel(sharpBand) + " (" + sourceTag + ")")
EndFunction

Float Function GetDislikeBaseDeltaForEvent(PDV_DeityBase deity, Int eventType)
    if !deity
        return 0.0
    endIf

    if !IsGenericLikesDislikesDeityReachable(deity)
        return 0.0
    endIf

    Form deityForm = deity as Form
    String tableKeyPrefix = "PDV.LD." + eventType
    Float baseDelta = StorageUtil.GetFloatValue(deityForm, tableKeyPrefix + ".D")
    if baseDelta < 0.0
        return baseDelta
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace >= 0
        Float originDelta = StorageUtil.GetFloatValue(deityForm, tableKeyPrefix + ".O" + originRace + ".D")
        if originDelta < 0.0
            return originDelta
        endIf
    endIf

    return 0.0
EndFunction

Bool Function HasDisfavorStanding(PDV_DeityBase deity)
    if !deity
        return False
    endIf
    if GetPatronState() == PATRON_STATE_ACTIVE && deity == Manager.GetActiveDeity()
        return True
    endIf
    return GetPiety(deity) >= 25.0
EndFunction

Bool Function IsDisfavorRepeatSuppressed(PDV_DeityBase deity, Int domainValue, Int eventType)
    Int currentDay = GetDisfavorDayIndex()
    return StorageUtil.GetIntValue(deity as Form, GetDisfavorRepeatDayKey(domainValue, eventType), -1) == currentDay
EndFunction

Function MarkDisfavorRepeatUsed(PDV_DeityBase deity, Int domainValue, Int eventType)
    if !deity
        return
    endIf
    StorageUtil.SetIntValue(deity as Form, GetDisfavorRepeatDayKey(domainValue, eventType), GetDisfavorDayIndex())
EndFunction

Int Function GetDisfavorDayIndex()
    return GetDevotionalDay() + 2
EndFunction

Int Function DomainForDeity(PDV_DeityBase deity)
    if deity == Manager.PDV_Kyne || deity == PDV_Kynareth || deity == Manager.PDV_Khenarthi || deity == Manager.PDV_HoonDing
        return DISFAVOR_DOMAIN_SKY_STORM_HUNT
    elseIf deity == PDV_Arkay || deity == Manager.PDV_Tuwhacca || deity == Manager.PDV_Xarxes || deity == Manager.PDV_Magnus
        return DISFAVOR_DOMAIN_DEATH_ANCESTORS
    elseIf deity == PDV_Mara || deity == PDV_Stendarr || deity == PDV_Dibella || deity == Manager.PDV_Stuhn
        return DISFAVOR_DOMAIN_MERCY_PROTECTION
    elseIf deity == Manager.PDV_Shor || deity == Manager.PDV_Tsun || deity == Manager.PDV_Talos || deity == Manager.PDV_Leki || deity == Manager.PDV_Trinimac || deity == Manager.PDV_Malacath
        return DISFAVOR_DOMAIN_WAR_HONOR
    elseIf deity == PDV_Zenithar || deity == PDV_Julianos || deity == PDV_Akatosh || deity == PDV_Zen || deity == Manager.PDV_Yffre || deity == Manager.PDV_AuriEl
        return DISFAVOR_DOMAIN_ORDER_TRADE_LORE
    elseIf deity == Manager.PDV_Azura || deity == Manager.PDV_Rajhin || deity == Manager.PDV_BaanDar || deity == Manager.PDV_Alkosh
        return DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
    elseIf deity == Manager.PDV_Sithis || deity == Manager.PDV_Mephala || deity == Manager.PDV_Hist || deity == Manager.PDV_Boethiah
        return DISFAVOR_DOMAIN_VOID_SECRETS
    endIf

    return DISFAVOR_DOMAIN_NONE
EndFunction

Function UpdateDisfavorStingRuntime()
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_SKY_STORM_HUNT)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_DEATH_ANCESTORS)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_MERCY_PROTECTION)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_WAR_HONOR)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_ORDER_TRADE_LORE)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_MOON_LUCK_SHADOW)
    ClearDisfavorIfExpired(DISFAVOR_DOMAIN_VOID_SECRETS)
EndFunction

Function ClearDisfavorIfExpired(Int domainValue)
    if !IsDisfavorDomainActive(domainValue)
        return
    endIf

    Float expiresAt = StorageUtil.GetFloatValue(None, GetDisfavorExpiryKey(domainValue))
    if expiresAt > 0.0 && Utility.GetCurrentGameTime() < expiresAt
        return
    endIf

    ClearDisfavorDomain(domainValue, "expired")
EndFunction

Function ClearDisfavorDomain(Int domainValue, String reason)
    Actor playerRef = Game.GetPlayer()
    if playerRef
        ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    endIf
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 0)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), 0.0)
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), "")
    Manager.Trace(2, "Disfavor sting cleared: " + GetDisfavorDomainLabel(domainValue) + " (" + reason + ")")
EndFunction

Function ClearDisfavorDomainSpellOnly(Actor playerRef, Int domainValue)
    if !playerRef
        return
    endIf

    Spell lightSpell = GetDisfavorSpell(domainValue, False)
    Spell sharpSpell = GetDisfavorSpell(domainValue, True)
    if lightSpell && playerRef.HasSpell(lightSpell)
        playerRef.RemoveSpell(lightSpell)
    endIf
    if sharpSpell && playerRef.HasSpell(sharpSpell)
        playerRef.RemoveSpell(sharpSpell)
    endIf
EndFunction

Bool Function IsDisfavorDomainActive(Int domainValue)
    return StorageUtil.GetIntValue(None, GetDisfavorActiveKey(domainValue)) == 1
EndFunction

Int Function CountActiveDisfavorStings()
    Int activeCount = 0
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_SKY_STORM_HUNT)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_DEATH_ANCESTORS)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_MERCY_PROTECTION)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_WAR_HONOR)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_ORDER_TRADE_LORE)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_MOON_LUCK_SHADOW)
        activeCount += 1
    endIf
    if IsDisfavorDomainActive(DISFAVOR_DOMAIN_VOID_SECRETS)
        activeCount += 1
    endIf
    return activeCount
EndFunction

Spell Function GetDisfavorSpell(Int domainValue, Bool sharpBand)
    if domainValue == DISFAVOR_DOMAIN_SKY_STORM_HUNT
        if sharpBand
            return PDV_SPEL_Disfavor_SkyStormHunt_Sharp
        endIf
        return PDV_SPEL_Disfavor_SkyStormHunt_Light
    elseIf domainValue == DISFAVOR_DOMAIN_DEATH_ANCESTORS
        if sharpBand
            return PDV_SPEL_Disfavor_DeathAncestors_Sharp
        endIf
        return PDV_SPEL_Disfavor_DeathAncestors_Light
    elseIf domainValue == DISFAVOR_DOMAIN_MERCY_PROTECTION
        if sharpBand
            return PDV_SPEL_Disfavor_MercyProtection_Sharp
        endIf
        return PDV_SPEL_Disfavor_MercyProtection_Light
    elseIf domainValue == DISFAVOR_DOMAIN_WAR_HONOR
        if sharpBand
            return PDV_SPEL_Disfavor_WarHonor_Sharp
        endIf
        return PDV_SPEL_Disfavor_WarHonor_Light
    elseIf domainValue == DISFAVOR_DOMAIN_ORDER_TRADE_LORE
        if sharpBand
            return PDV_SPEL_Disfavor_OrderTradeLore_Sharp
        endIf
        return PDV_SPEL_Disfavor_OrderTradeLore_Light
    elseIf domainValue == DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
        if sharpBand
            return Manager.PDV_SPEL_Disfavor_MoonLuckShadow_Sharp
        endIf
        return Manager.PDV_SPEL_Disfavor_MoonLuckShadow_Light
    elseIf domainValue == DISFAVOR_DOMAIN_VOID_SECRETS
        if sharpBand
            return PDV_SPEL_Disfavor_VoidSecrets_Sharp
        endIf
        return PDV_SPEL_Disfavor_VoidSecrets_Light
    endIf

    return None
EndFunction

Float Function GetDisfavorDurationDays(Bool sharpBand)
    if sharpBand
        return DISFAVOR_SHARP_DURATION_DAYS
    endIf
    return DISFAVOR_LIGHT_DURATION_DAYS
EndFunction

String Function GetDisfavorBandLabel(Bool sharpBand)
    if sharpBand
        return "sharp"
    endIf
    return "light"
EndFunction

String Function GetDisfavorDomainLabel(Int domainValue)
    if domainValue == DISFAVOR_DOMAIN_SKY_STORM_HUNT
        return "SkyStormHunt"
    elseIf domainValue == DISFAVOR_DOMAIN_DEATH_ANCESTORS
        return "DeathAncestors"
    elseIf domainValue == DISFAVOR_DOMAIN_MERCY_PROTECTION
        return "MercyProtection"
    elseIf domainValue == DISFAVOR_DOMAIN_WAR_HONOR
        return "WarHonor"
    elseIf domainValue == DISFAVOR_DOMAIN_ORDER_TRADE_LORE
        return "OrderTradeLore"
    elseIf domainValue == DISFAVOR_DOMAIN_MOON_LUCK_SHADOW
        return "MoonLuckShadow"
    elseIf domainValue == DISFAVOR_DOMAIN_VOID_SECRETS
        return "VoidSecrets"
    endIf

    return "None"
EndFunction

String Function GetDisfavorActiveKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".Active"
EndFunction

String Function GetDisfavorExpiryKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".ExpiresAt"
EndFunction

String Function GetDisfavorBandKey(Int domainValue)
    return "PDV.Disfavor.Domain." + domainValue + ".Band"
EndFunction

String Function GetDisfavorRepeatDayKey(Int domainValue, Int eventType)
    return "PDV.Disfavor.Repeat." + domainValue + "." + eventType + ".Day"
EndFunction

Bool Function ApplyDebugDomainSting(Int domainValue, Bool sharp, Bool respectCap)
    if domainValue < DISFAVOR_DOMAIN_SKY_STORM_HUNT || domainValue > DISFAVOR_DOMAIN_VOID_SECRETS
        Manager.Trace(1, "DebugApplyDomainSting skipped: bad domain " + domainValue)
        return False
    endIf
    UpdateDisfavorStingRuntime()
    Bool domainAlreadyActive = IsDisfavorDomainActive(domainValue)
    if respectCap && !domainAlreadyActive && CountActiveDisfavorStings() >= DISFAVOR_MAX_ACTIVE_DOMAINS
        Manager.Trace(2, "DebugApplyDomainSting suppressed by active-domain cap: " + GetDisfavorDomainLabel(domainValue))
        return False
    endIf
    Spell targetSpell = GetDisfavorSpell(domainValue, sharp)
    if !targetSpell
        Manager.Trace(1, "DebugApplyDomainSting skipped: missing spell for " + GetDisfavorDomainLabel(domainValue))
        return False
    endIf
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return False
    endIf
    ClearDisfavorDomainSpellOnly(playerRef, domainValue)
    playerRef.AddSpell(targetSpell, False)
    StorageUtil.SetIntValue(None, GetDisfavorActiveKey(domainValue), 1)
    StorageUtil.SetFloatValue(None, GetDisfavorExpiryKey(domainValue), Utility.GetCurrentGameTime() + GetDisfavorDurationDays(sharp))
    StorageUtil.SetStringValue(None, GetDisfavorBandKey(domainValue), GetDisfavorBandLabel(sharp))
    Manager.Trace(1, "DebugApplyDomainSting applied: " + GetDisfavorDomainLabel(domainValue) + " " + GetDisfavorBandLabel(sharp))
    return True
EndFunction

String Function GetActiveDisfavorSummary()
    UpdateDisfavorStingRuntime()
    String summary = ""
    Int domainValue = DISFAVOR_DOMAIN_SKY_STORM_HUNT
    while domainValue <= DISFAVOR_DOMAIN_VOID_SECRETS
        if IsDisfavorDomainActive(domainValue)
            Float expiresAt = StorageUtil.GetFloatValue(None, GetDisfavorExpiryKey(domainValue))
            Int remainMinutes = ((expiresAt - Utility.GetCurrentGameTime()) * 24.0 * 60.0) as Int
            if remainMinutes < 0
                remainMinutes = 0
            endIf
            String band = StorageUtil.GetStringValue(None, GetDisfavorBandKey(domainValue))
            if band == ""
                band = "?"
            endIf
            if summary != ""
                summary += "; "
            endIf
            summary += GetDisfavorDomainLabel(domainValue) + " " + band + " (~" + remainMinutes + "m)"
        endIf
        domainValue += 1
    endWhile
    if summary == ""
        return "Active disfavor: none (0/" + DISFAVOR_MAX_ACTIVE_DOMAINS + ")."
    endIf
    return "Active disfavor (" + CountActiveDisfavorStings() + "/" + DISFAVOR_MAX_ACTIVE_DOMAINS + "): " + summary
EndFunction

Function ClearAllDisfavorStings()
    Int domainValue = DISFAVOR_DOMAIN_SKY_STORM_HUNT
    while domainValue <= DISFAVOR_DOMAIN_VOID_SECRETS
        if IsDisfavorDomainActive(domainValue)
            ClearDisfavorDomain(domainValue, "debug_clear")
        endIf
        domainValue += 1
    endWhile
EndFunction

Function RecordDeityDriver(PDV_DeityBase deity, String reason, Float delta)
    Form deityForm = deity as Form
    String humanized = Manager.Prisma.HumanizeDriverReason(reason)
    while StorageUtil.StringListCount(deityForm, "PDV.Driver.Reasons") >= 6
        StorageUtil.StringListRemoveAt(deityForm, "PDV.Driver.Reasons", 0)
        StorageUtil.FloatListRemoveAt(deityForm, "PDV.Driver.Deltas", 0)
        StorageUtil.IntListRemoveAt(deityForm, "PDV.Driver.Days", 0)
    endWhile
    StorageUtil.StringListAdd(deityForm, "PDV.Driver.Reasons", humanized, True)
    StorageUtil.FloatListAdd(deityForm, "PDV.Driver.Deltas", delta, True)
    StorageUtil.IntListAdd(deityForm, "PDV.Driver.Days", Utility.GetCurrentGameTime() as Int, True)
EndFunction

String Function GetGodRollupState(PDV_DeityBase deity)
    if !deity
        return "steady"
    endIf
    if IsNeglectFlagActive(deity)
        return "neglected"
    endIf
    Form deityForm = deity as Form
    Float pietyToday = StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    Float piety = StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    Float lastEvent = StorageUtil.GetFloatValue(deityForm, "PDV.LastEventGameTime")
    Float now = Utility.GetCurrentGameTime()
    if pietyToday > 0.5
        return "gaining"
    endIf
    if pietyToday < -0.5
        return "starving"
    endIf
    if piety > 0.0 && lastEvent > 0.0 && (now - lastEvent) >= DECAY_GRACE_DAYS
        return "starving"
    endIf
    return "steady"
EndFunction

Float Function RunGainPipeline(PDV_DeityBase deity, Float amount, Int stance, Bool applyStanceMultiplier = True)
    Float appliedAmount = amount
    if amount > 0.0
        if applyStanceMultiplier
            appliedAmount = appliedAmount * deity.GetEffectiveGainMultiplier()
        else
            appliedAmount = appliedAmount * deity.GetEffectiveGainMultiplierWithoutStance()
        endIf
        appliedAmount = appliedAmount * GetGainProviderProduct(deity, Manager.PHASE_PER_EVENT)
        appliedAmount = appliedAmount * GetSurvivalContextGainMultiplier(deity)
        if PDV_ModePresetRef
            appliedAmount = appliedAmount * PDV_ModePresetRef.GainMultiplier()
        endIf
    endIf

    return appliedAmount
EndFunction

Function InitSurvivalContext()
    if _pdvSurvivalContextInit
        return
    endIf
    _pdvSurvivalContextInit = True

    if Game.GetModByName("ccQDRSSE001-SurvivalMode.esl") != 255
        Manager.SetPdvSurvivalModePresent(True)
        _pdvSurvModeEnabled = Game.GetFormFromFile(0x000826, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvHunger = Game.GetFormFromFile(0x00081A, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvCold = Game.GetFormFromFile(0x00081B, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
        _pdvSurvExhaustion = Game.GetFormFromFile(0x000816, "ccQDRSSE001-SurvivalMode.esl") as GlobalVariable
    endIf

    if Game.GetModByName("SunHelmSurvival.esp") != 255
        Manager.SetPdvSunHelmPresent(True)
        _pdvSunHelmEnabled = Game.GetFormFromFile(0x02EB63, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmHunger = Game.GetFormFromFile(0x00EAAE, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmThirst = Game.GetFormFromFile(0x05C472, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmCold = Game.GetFormFromFile(0x6A13C5, "SunHelmSurvival.esp") as GlobalVariable
        _pdvSunHelmFatigue = Game.GetFormFromFile(0x021E3F, "SunHelmSurvival.esp") as GlobalVariable
    endIf
EndFunction

Bool Function IsSurvivalContextEnabled()
    return StorageUtil.GetIntValue(None, COMPAT_SURVIVAL_TOGGLE_KEY, 1) != 0
EndFunction

Int Function GetSurvivalContextSeverity()
    if !IsSurvivalContextEnabled()
        return 0
    endIf

    InitSurvivalContext()

    Int severity = 0

    if Manager.GetPdvSurvivalModePresent() && _pdvSurvModeEnabled && _pdvSurvModeEnabled.GetValueInt() != 0
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSurvHunger))
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSurvCold))
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSurvExhaustion))
    endIf

    if Manager.GetPdvSunHelmPresent() && _pdvSunHelmEnabled && _pdvSunHelmEnabled.GetValueInt() != 0
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSunHelmHunger))
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSunHelmThirst))
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSunHelmCold))
        severity = PDV_DevotionRules.MaxSeverity(severity, PDV_DevotionRules.NeedToSeverity(_pdvSunHelmFatigue))
    endIf

    return severity
EndFunction

Float Function GetSurvivalContextGainMultiplier(PDV_DeityBase deity)
    Int severity = GetSurvivalContextSeverity()
    if severity <= 0
        return 1.0
    endIf

    Float multiplier = 1.0 - (severity * SURVIVAL_DAMP_PER_SEVERITY)
    if multiplier < 0.9
        multiplier = 0.9
    endIf
    return multiplier
EndFunction

Function InitCCContent()
    if _pdvCCContentInit
        return
    endIf
    _pdvCCContentInit = True

    if Game.GetModByName("ccbgssse025-advdsgs.esm") != 255
        Manager.SetPdvCCSaintsPresent(True)
        _pdvCCSaintsRestoringOrder = Game.GetFormFromFile(0x000913, "ccbgssse025-advdsgs.esm") as Quest
    endIf

    if Game.GetModByName("ccbgssse001-fish.esm") != 255
        Manager.SetPdvCCFishingPresent(True)
        _pdvCCFishingIsFishing = Game.GetFormFromFile(0x000B26, "ccbgssse001-fish.esm") as GlobalVariable
    endIf
EndFunction

Bool Function IsCCContentEnabled()
    return StorageUtil.GetIntValue(None, COMPAT_CC_TOGGLE_KEY, 1) != 0
EndFunction

Function TryCCSaintsRecognition()
    if !IsCCContentEnabled()
        return
    endIf

    InitCCContent()
    if !Manager.GetPdvCCSaintsPresent() || !_pdvCCSaintsRestoringOrder
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.CC.SaintsRecognized") != 0
        return
    endIf

    if _pdvCCSaintsRestoringOrder.GetStageDone(200)
        PDV_DaedricPath_Sheo sheoPath = Manager.PDV_QuestReactionRuntimeService.GetQuestReactionDeity("Sheogorath") as PDV_DaedricPath_Sheo
        if sheoPath
            sheoPath.RecordControlledSignal("cc_saints_restoring_order")
            StorageUtil.SetIntValue(None, "PDV.CC.SaintsRecognized", 1)
        endIf
    endIf
EndFunction

Function TryCCFishingDevotion()
    if !IsCCContentEnabled()
        return
    endIf

    InitCCContent()
    if !Manager.GetPdvCCFishingPresent() || !_pdvCCFishingIsFishing
        return
    endIf

    Int nowFlag = _pdvCCFishingIsFishing.GetValueInt()
    if nowFlag != 0 && _pdvCCFishingLastFlag == 0
        Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.CCFishingKyne")
        if multiplier > 0.0 && Manager.PDV_Kyne
            AwardPiety(Manager.PDV_Kyne, 0.5 * multiplier, "cc_fishing")
        endIf
    endIf
    _pdvCCFishingLastFlag = nowFlag
EndFunction

Float Function GetReputationDecayMultiplier(PDV_DeityBase deity)
    if deity
        return deity.GetTrackDecayMultiplier()
    endIf

    return 1.0
EndFunction

Float Function GetDecayFloorForDeity(PDV_DeityBase deity, Float currentPiety)
    if !deity
        return 0.0
    endIf

    if Manager.PDV_CurseStateService && Manager.PDV_CurseStateService.IsVampire() && deity.IsAedric
        return 0.0
    endIf

    Int tierValue = ComputeTierFromPiety(deity, currentPiety)
    Float storedFloor = StorageUtil.GetFloatValue(deity as Form, "PDV.PassiveDecayFloor")
    Float currentFloor = GetDecayFloorForTier(deity, tierValue)
    if storedFloor > currentFloor
        return storedFloor
    endIf

    return currentFloor
EndFunction

Float Function GetDecayFloorForTier(PDV_DeityBase deity, Int tierValue)
    if !deity
        return 0.0
    endIf

    if tierValue >= TIER_CHAMPION
        ; P10 Long Devotion. A deity carried at least one full mark (15 piety) PAST Champion can
        ; no longer be idled back out of Champion: its decay floor rises from Devoted to Champion.
        ;
        ; THIS IS THE ONLY ARM OF P10 THAT TOUCHES EVERY RACE AND DEITY -- hence the per-deity
        ; MarkHigh gate. A deity never carried past Champion behaves exactly as before, which is
        ; what the non-Altmer regression test checks. It cannot GRANT anything:
        ; RefreshPassiveDecayFloorForDeity only ratchets the stored floor upward, and a floor
        ; bounds decay rather than awarding piety. Worst case if the design is wrong: a
        ; long-devoted patron stops decaying below 85, which is the intended statement.
        if StorageUtil.GetIntValue(None, "PDV.LongDevotion.MarkHigh." + deity.DeityIndex) >= 1
            return deity.ThresholdChampion
        endIf
        return deity.ThresholdDevoted
    elseIf tierValue >= TIER_DEVOTED
        return deity.ThresholdSeeker
    endIf

    return 0.0
EndFunction

Function RefreshPassiveDecayFloorForDeity(PDV_DeityBase deity, Int tierValue)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return
    endIf

    Float tierFloor = GetDecayFloorForTier(deity, tierValue)
    Float storedFloor = StorageUtil.GetFloatValue(deityForm, "PDV.PassiveDecayFloor")
    if tierFloor > storedFloor
        StorageUtil.SetFloatValue(deityForm, "PDV.PassiveDecayFloor", tierFloor)
    endIf
EndFunction

Function ClearAllNeglectFlags()
    Int i = 0
    Int count = GetDeityCount()
    while i < count
        PDV_DeityBase deity = GetDeityAtListIndex(i)
        if deity
            SetNeglectFlag(deity, False)
        endIf
        i += 1
    endWhile
EndFunction

Function SetNeglectFlag(PDV_DeityBase deity, Bool isActive)
    if !deity
        return
    endIf

    StorageUtil.SetIntValue(deity as Form, "PDV.Neglect.Active", PDV_DevotionRules.BoolToInt(isActive))
EndFunction

Bool Function IsNeglectFlagActive(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Neglect.Active") == 1
EndFunction

Bool Function IsPatronLapsed(PDV_DeityBase deity)
    ; Recency lapse: the active patron is "neglected" after NEGLECT_LAPSE_GRACE_DAYS of no
    ; devotional act, regardless of piety. The active patron is decay-shielded (ApplyDecayToDeity
    ; returns early for _activeDeity), so the piety<=10 floor almost never fires from mere absence.
    ; Mirrors the Imperial civic-lapse model (IsImperialCivicNeglected). Reuses the per-deity
    ; PDV.LastEventGameTime stamp that decay already consumes.
    if !deity
        return False
    endIf
    Float lastAct = StorageUtil.GetFloatValue(deity as Form, "PDV.LastEventGameTime")
    if lastAct <= 0.0
        return False
    endIf
    return (Utility.GetCurrentGameTime() - lastAct) > NEGLECT_LAPSE_GRACE_DAYS
EndFunction

Function SyncOnePatronNeglectSpell(Actor playerRef, Spell neglectSpell, Bool shouldBeActive)
    ; None-safe add/remove for one per-patron neglect spell. Guards on the spell so it no-ops while
    ; the record is unauthored (property still None until the ESP batch fills it).
    if !playerRef || !neglectSpell
        return
    endIf
    if shouldBeActive
        if !playerRef.HasSpell(neglectSpell)
            playerRef.AddSpell(neglectSpell, False)
        endIf
    else
        if playerRef.HasSpell(neglectSpell)
            playerRef.RemoveSpell(neglectSpell)
        endIf
    endIf
EndFunction

Function SyncFirstTierRaceRewardRuntime()
    Actor playerRef = Game.GetPlayer()
    Spell activeReward = GetFirstTierRaceRewardSpellForOrigin()
    ; The origin's first-tier "+10" Health floor grants to an active patron (>= Seeker) OR a
    ; broad worshipper with accumulated service (IsBroadFloorEligible) -- without the broad arm
    ; a broad worshipper got nothing until the count-gated Faithful (T2) reward, a 0 -> +20 cliff.
    Bool shouldBeActive = (IsFirstTierRaceRewardEligible() || Manager.OriginRuntime.IsBroadFloorEligible()) && activeReward

    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Altmer_Orthodox_T1, shouldBeActive && activeReward == Manager.PDV_Bless_Altmer_Orthodox_T1, "Altmer T1")
    ; Argonian Hist_T1 is intentionally absent here: SyncArgonianRewards owns it on the substrate
    ; tier (no-offer). Managing it in this active-patron path too would fight that grant.
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Bosmer_Yffre_T1, shouldBeActive && activeReward == Manager.PDV_Bless_Bosmer_Yffre_T1, "Bosmer T1")
    ; Breton T1 is intentionally absent here: SyncBretonTraditionRewardFamily owns
    ; the tradition family T1 on the tradition-breadth tier (v3 12.5, no generic
    ; broad lane). Managing it in this floor path too would fight that grant.
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Dunmer_Reclamation_T1, shouldBeActive && activeReward == Manager.PDV_Bless_Dunmer_Reclamation_T1, "Dunmer T1")
    ; Khajiit Lunar_T1 is intentionally absent here: PDV_Substrate_KhajiitLunar
    ; owns it as the Substrate_Mid slot. Managing it in this generic T1 path
    ; would fight the substrate grant and strip Khajiit Lunar Road.
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Orc_Malacath_T1, shouldBeActive && activeReward == Manager.PDV_Bless_Orc_Malacath_T1, "Orc T1")
    ; Redguard AncestorSpine_T1 is intentionally absent here: descoped 2026-07-16 (the
    ; Crown/Forebear/Ash'abah sect spine is the sole ancestor layer). The selector returns
    ; None for Redguard, so activeReward can never equal it -- this line only ever stripped,
    ; which is dead on a not-save-safe fresh save. The property and reward functions stay for
    ; gate assertions and the still-live T2 broad-worship path; uninstall teardown still clears it.

    if shouldBeActive
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Active", 1)
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Origin", Manager.GetPlayerOriginRaceIndex())
    else
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Active", 0)
        StorageUtil.SetIntValue(None, "PDV.RaceReward.T1Origin", -1)
    endIf

    ; Reconcile every race lane through generic dispatch (v3 switchboard): the bound (player)
    ; adapter grants its own lane; every other adapter's Sync runs the isX=false path and STRIPS
    ; its lane -- the same one-race-active invariant the former per-lane calls enforced, now via
    ; PDV_FLST_OriginAdapters instead of 10 hardcoded pairs. Adapters are Manager-wired even when
    ; unbound (ESP fill verified 2026-08-20), and each SyncRaceRewards/SyncNeglectSpells override
    ; mirrors its former per-lane call exactly. Nord's SyncNeglectSpells re-affirms the idempotent
    ; Kyne/patron neglect already set at dawn (identical IsNeglectFlagActive(Kyne) arg).
    Int adapterIndex = 0
    while adapterIndex < Manager.PDV_FLST_OriginAdapters.GetSize()
        PDV_OriginRuntimeBase laneAdapter = Manager.PDV_FLST_OriginAdapters.GetAt(adapterIndex) as PDV_OriginRuntimeBase
        if laneAdapter
            laneAdapter.SyncRaceRewards()
            laneAdapter.SyncNeglectSpells()
        endIf
        adapterIndex += 1
    endWhile

    SyncBroadPantheonRewards(playerRef)
EndFunction

Function SyncBroadPantheonRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    String activePool = ""
    Float standing = 0.0
    if GetPatronState() == PATRON_STATE_BROAD
        activePool = GetActiveBroadPantheonPoolId()
        standing = GetBroadPantheonStanding(activePool)
    endIf

    Bool imperialSeeker = activePool == BROAD_PANTHEON_IMPERIAL && standing >= BROAD_PANTHEON_SEEKER_THRESHOLD && standing < BROAD_PANTHEON_FAITHFUL_THRESHOLD
    Bool imperialFaithful = activePool == BROAD_PANTHEON_IMPERIAL && standing >= BROAD_PANTHEON_FAITHFUL_THRESHOLD
    Bool oldWaysSeeker = activePool == BROAD_PANTHEON_NORD_OLD && standing >= BROAD_PANTHEON_SEEKER_THRESHOLD && standing < BROAD_PANTHEON_FAITHFUL_THRESHOLD
    Bool oldWaysFaithful = activePool == BROAD_PANTHEON_NORD_OLD && standing >= BROAD_PANTHEON_FAITHFUL_THRESHOLD
    Bool nineSeeker = activePool == BROAD_PANTHEON_NORD_NINE && standing >= BROAD_PANTHEON_SEEKER_THRESHOLD && standing < BROAD_PANTHEON_FAITHFUL_THRESHOLD
    Bool nineFaithful = activePool == BROAD_PANTHEON_NORD_NINE && standing >= BROAD_PANTHEON_FAITHFUL_THRESHOLD

    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Imperial_Civic_T1, imperialSeeker, "The Divines' Regard - Observant")
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Imperial_Civic_T2, imperialFaithful, "The Divines' Regard - Faithful")
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Nord_OldWays_T1, oldWaysSeeker, "Old Ways - Observant")
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Nord_OldWays_T2, oldWaysFaithful, "Old Ways - Faithful")
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Nord_NineDivines_T1, nineSeeker, "Faith of the Holds - Observant")
    SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Nord_NineDivines_T2, nineFaithful, "Faith of the Holds - Faithful")
EndFunction

Bool Function IsFirstTierRaceRewardEligible()
    if GetPatronState() == PATRON_STATE_ACTIVE && Manager.GetActiveDeity() && GetTier(Manager.GetActiveDeity()) >= TIER_SEEKER
        return True
    endIf

    return False
EndFunction

Bool Function IsPantheonBroadPoolPresentationActive(Int origin)
    if origin != Manager.ORIGIN_IMPERIAL && origin != Manager.ORIGIN_NORD
        return False
    endIf
    return GetActiveBroadPantheonPoolId() != ""
EndFunction

Spell Function GetFirstTierRaceRewardSpellForOrigin()
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_ALTMER
        return Manager.PDV_Bless_Altmer_Orthodox_T1
    ; Argonian is a no-offer race: this selector exposes the fixed T1 spell for readback and
    ; shared reward contracts, while SyncArgonianRewards performs the actual substrate grant.
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        return Manager.PDV_Bless_Argonian_Hist_T1
    elseIf originRace == Manager.ORIGIN_BOSMER
        return Manager.PDV_Bless_Bosmer_Yffre_T1
    elseIf originRace == Manager.ORIGIN_BRETON
        ; Readback selector only; the grant is owned by SyncBretonTraditionRewardFamily.
        Int bretonTradition = Manager.OriginRuntime.GetBretonTraditionValue()
        if bretonTradition == Manager.BRETON_TRADITION_HIDDEN_ART
            return Manager.PDV_Bless_Breton_HiddenArt_T1
        elseIf bretonTradition == Manager.BRETON_TRADITION_GREEN_WAY
            return Manager.PDV_Bless_Breton_GreenWay_T1
        endIf
        return Manager.PDV_Bless_Breton_KnightsRoad_T1
    elseIf originRace == Manager.ORIGIN_DUNMER
        return Manager.PDV_Bless_Dunmer_Reclamation_T1
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        return Manager.PDV_Bless_Imperial_Civic_T1
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        return Manager.PDV_Bless_Khajiit_Lunar_T1
    elseIf originRace == Manager.ORIGIN_NORD
        return Manager.PDV_Bless_Nord_OldWays_T1
    elseIf originRace == Manager.ORIGIN_ORC
        return Manager.PDV_Bless_Orc_Malacath_T1
    elseIf originRace == Manager.ORIGIN_REDGUARD
        ; Redguard has no generic ancestor floor: the sect spine (Crown/Forebear/Ash'abah via
        ; SyncRedguardSpineBoon) is the sole ancestor layer (option 2, 2026-07-16). Returning None
        ; makes the generic-floor loop strip any legacy "Ancestors' Regard" (AncestorSpine_T1) and
        ; never re-grant it, so a sect member carries only their sect spine.
        return None
    endIf

    return None
EndFunction

Function SyncRaceRewardSpell(Actor playerRef, Spell rewardSpell, Bool shouldBeActive, String rewardLabel)
    if !playerRef || !rewardSpell
        return
    endIf

    if shouldBeActive
        if !playerRef.HasSpell(rewardSpell)
            playerRef.AddSpell(rewardSpell, False)
            Manager.Trace(2, "Race reward added: " + rewardLabel)
        endIf
    else
        if playerRef.HasSpell(rewardSpell)
            playerRef.RemoveSpell(rewardSpell)
            Manager.Trace(2, "Race reward removed: " + rewardLabel)
        endIf
    endIf
EndFunction

Bool Function HasRewardSpell(Actor playerRef, Spell rewardSpell)
    if !playerRef || !rewardSpell
        return False
    endIf

    return playerRef.HasSpell(rewardSpell)
EndFunction

Function MaybeShowChampionRewardPresentation(Actor playerRef, Spell championSpell, Bool hadChampionSpell, Bool wantsChampionSpell, PDV_DeityBase deity, String rewardLabel)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    if !playerRef || !championSpell || !wantsChampionSpell || hadChampionSpell || !playerRef.HasSpell(championSpell) || !deity
        return
    endIf

    if NotifyTierUp(deity, TIER_CHAMPION)
        Manager.Prisma.SendPrismaEventToast("tier", deity, "", Manager.Prisma.GetPublicTierBand(TIER_CHAMPION), "")
        Manager.Prisma.SurfaceTransition("tier", deity.DeityName + " " + Manager.Prisma.GetTierStandingLabel(TIER_CHAMPION), "reach", deity.DeityIndex, "", false, true)
        if deity == Manager.PDV_Kyne
            Manager.OriginRuntime.ShowNordNotification(Manager.PDV_Notif_Nord_Kyne_ChampionAmbient_Storm, "The wind is blowing your way.")
        endIf
        Manager.Trace(1, "Champion reward presentation shown: " + rewardLabel + " / " + deity.DeityName)
    endIf
EndFunction

Int Function ApplyGenericNeglectFlags()
    PDV_DeityBase firstDeity = None
    PDV_DeityBase secondDeity = None
    PDV_DeityBase thirdDeity = None
    Float firstPiety = PIETY_MAX + 1.0
    Float secondPiety = PIETY_MAX + 1.0
    Float thirdPiety = PIETY_MAX + 1.0

    Int i = 0
    Int count = GetDeityCount()
    while i < count
        PDV_DeityBase deity = GetDeityAtListIndex(i)
        if IsEligibleForNeglectSelection(deity)
            Float piety = GetPiety(deity)
            if piety <= NEGLECT_ACTIVE_PIETY_MAX
                if !firstDeity || piety < firstPiety
                    thirdDeity = secondDeity
                    thirdPiety = secondPiety
                    secondDeity = firstDeity
                    secondPiety = firstPiety
                    firstDeity = deity
                    firstPiety = piety
                elseIf deity != firstDeity && (!secondDeity || piety < secondPiety)
                    thirdDeity = secondDeity
                    thirdPiety = secondPiety
                    secondDeity = deity
                    secondPiety = piety
                elseIf deity != firstDeity && deity != secondDeity && (!thirdDeity || piety < thirdPiety)
                    thirdDeity = deity
                    thirdPiety = piety
                endIf
            endIf
        endIf
        i += 1
    endWhile

    Int activeCount = 0
    if firstDeity
        SetNeglectFlag(firstDeity, True)
        activeCount += 1
    endIf
    if secondDeity
        SetNeglectFlag(secondDeity, True)
        activeCount += 1
    endIf
    if thirdDeity
        SetNeglectFlag(thirdDeity, True)
        activeCount += 1
    endIf

    return activeCount
EndFunction

Bool Function IsEligibleForNeglectSelection(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPiety(deity) > 0.0
        return True
    endIf

    return deity == Manager.GetActiveDeity()
EndFunction

Function ResetDailyRepeatKey(String keyPrefix)
    StorageUtil.SetIntValue(None, keyPrefix + ".Day", -1)
    StorageUtil.SetIntValue(None, keyPrefix + ".Count", 0)
EndFunction

String Function GetBroadPantheonPoolIdByDebugIndex(Int poolIndex)
    if poolIndex == 0
        return BROAD_PANTHEON_IMPERIAL
    elseIf poolIndex == 1
        return BROAD_PANTHEON_NORD_OLD
    elseIf poolIndex == 2
        return BROAD_PANTHEON_NORD_NINE
    endIf
    return ""
EndFunction

String Function GetBroadPantheonRosterForDebug(String poolId)
    if poolId == BROAD_PANTHEON_IMPERIAL
        if StorageUtil.GetIntValue(None, "PDV.Imperial.TalosBroadUnlocked") == 1
            return "Akatosh/Arkay/Dibella/Julianos/Kynareth/Mara/Stendarr/Zenithar/Talos (unlocked)"
        endIf
        return "Akatosh/Arkay/Dibella/Julianos/Kynareth/Mara/Stendarr/Zenithar (Talos locked)"
    elseIf poolId == BROAD_PANTHEON_NORD_OLD
        return "Kyne/Shor/Tsun/Stuhn/Mara/Orkey/Dibella/Talos"
    endIf
    return "Akatosh/Arkay/Dibella/Julianos/Kynareth/Mara/Stendarr/Zenithar/Talos"
EndFunction

PDV_DeityBase Function GetPacingPatronCandidate()
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_IMPERIAL
        return PDV_Akatosh
    elseIf originRace == Manager.ORIGIN_NORD
        if Manager.OriginRuntime.GetNordPantheonBaselineState() == Manager.NORD_BASELINE_OLD_WAYS
            return Manager.PDV_Kyne
        endIf
        return PDV_Akatosh
    endIf
    return None
EndFunction

Function EvaluateFormalCommitmentOffer()
    if GetPatronState() == PATRON_STATE_ACTIVE
        return
    endIf

    if ShouldBypassFormalCommitmentOffers()
        return
    endIf

    PDV_DeityBase candidate = GetBestFormalCommitmentOfferCandidate()
    if !candidate
        return
    endIf

    Message offerMessage = GetFormalCommitmentOfferMessage(candidate)
    if !offerMessage
        Manager.Trace(1, "Commitment offer skipped for " + candidate.DeityName + ": no offer message wired.")
        return
    endIf

    if StorageUtil.GetFormValue(None, "PDV.Commitment.PendingDeityForm") == (candidate as Form)
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", candidate.DeityIndex)
    StorageUtil.SetFormValue(None, "PDV.Commitment.PendingDeityForm", candidate as Form)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", Utility.GetCurrentGameTime())
    Manager.Trace(1, "Commitment offer pending for " + candidate.DeityName + ".")
    ShowFormalCommitmentOffer(candidate)
EndFunction

Function ShowFormalCommitmentOffer(PDV_DeityBase deity)
    Message offerMessage = GetFormalCommitmentOfferMessage(deity)
    if !offerMessage
        return
    endIf

    ; A blocking Message.Show cannot display over an open menu (it renders nothing and
    ; burns the one-shot). Stash the offer and let ProcessQueuedCommitmentOffer replay it
    ; from the poll once menus close.
    if Utility.IsInMenuMode()
        Manager.SetPendingCommitmentOfferDeity(deity)
        return
    endIf

    Manager.Prisma.DispatchDiegeticCue("offer", deity.DeityName, "present", deity, "revelation")
    StorageUtil.SetIntValue(deity as Form, "PDV.Commitment.Offered", 1)
    Int choice = offerMessage.Show()
    if choice == 0
        Manager.DebugRuntime.DebugAcceptPendingCommitment()
    elseIf choice == 1
        Manager.DebugRuntime.DebugDeclinePendingCommitment()
    elseIf choice == 2
        Manager.DebugRuntime.DebugRefusePendingCommitment()
    endIf
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    ; Any Daedric path uses the single shared Prince-pact offer message, ahead of the
    ; per-race divine dispatch (a path is offer-eligible regardless of origin race).
    if (deity as PDV_DaedricPathBase)
        return (deity as PDV_DaedricPathBase).GetCommitmentOfferMessage()
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_NORD
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    elseIf originRace == Manager.ORIGIN_DUNMER
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    elseIf originRace == Manager.ORIGIN_ALTMER
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    elseIf originRace == Manager.ORIGIN_BRETON
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    elseIf originRace == Manager.ORIGIN_REDGUARD
        return Manager.OriginRuntime.GetFormalCommitmentOfferMessage(deity)
    endIf

    return None
EndFunction

Bool Function IsPendingCommitmentStillAcceptable(PDV_DeityBase deity)
    if !deity || !UsesFormalCommitmentOffersForDeity(deity)
        return False
    endIf
    if GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD || !HasRecentCommitmentSignalDays(deity, 2, 7)
        return False
    endIf
    if IsCommitmentRefused(deity) || IsCommitmentDeclineDelayActive(deity)
        return False
    endIf
    return True
EndFunction

PDV_DeityBase Function GetBestFormalCommitmentOfferCandidate()
    PDV_DeityBase bestDeity = None
    Float bestWeight = -1.0

    ; Divine deities live in PDV_FLST_AllDeities; Daedric Princes live in their own list
    ; (PDV_FLST_DaedricPaths_All) and are NOT members of PDV_FLST_AllDeities. Scan both so a
    ; Prince pact-consent offer can fire.
    if PDV_FLST_AllDeities
        Int i = 0
        Int count = PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if IsEligibleForFormalCommitmentOffer(deity)
                Float weight = GetFormalCommitmentOfferWeight(deity)
                if !bestDeity || weight > bestWeight
                    bestDeity = deity
                    bestWeight = weight
                endIf
            endIf
            i += 1
        endWhile
    endIf

    if Manager.PDV_FLST_DaedricPaths_All
        Int j = 0
        Int pathCount = Manager.PDV_FLST_DaedricPaths_All.GetSize()
        while j < pathCount
            PDV_DeityBase deity = Manager.PDV_FLST_DaedricPaths_All.GetAt(j) as PDV_DeityBase
            if IsEligibleForFormalCommitmentOffer(deity)
                Float weight = GetFormalCommitmentOfferWeight(deity)
                if !bestDeity || weight > bestWeight
                    bestDeity = deity
                    bestWeight = weight
                endIf
            endIf
            j += 1
        endWhile
    endIf

    return bestDeity
EndFunction

Bool Function IsEligibleForFormalCommitmentOffer(PDV_DeityBase deity)
    if !UsesFormalCommitmentOffersForDeity(deity)
        return False
    endIf

    if deity == Manager.PDV_Kyne && !Manager.OriginRuntime.IsKyneCommitmentSignalReady()
        return False
    endIf

    if IsCommitmentRefused(deity)
        return False
    endIf

    if IsCommitmentOffered(deity)
        return False
    endIf

    if IsCommitmentDeclineDelayActive(deity)
        return False
    endIf

    if GetPiety(deity) < COMMITMENT_OFFER_THRESHOLD
        return False
    endIf

    if !HasRecentCommitmentSignalDays(deity, 2, 7)
        return False
    endIf

    return True
EndFunction

Bool Function UsesFormalCommitmentOffersForDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return Manager.OriginRuntime.IsOfferEligibleDeity(deity) || Manager.IsDaedricPactOfferEligibleDeity(deity)
EndFunction

Bool Function IsGenericLikesDislikesDeityReachable(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_NORD
        return Manager.OriginRuntime.IsOfferEligibleDeity(deity)
    endIf

    return deity.GetStanceForRace(originRace) == deity.STANCE_NATIVE
EndFunction

Float Function GetFormalCommitmentOfferWeight(PDV_DeityBase deity)
    if !deity
        return -1.0
    endIf

    Float weight = GetPiety(deity)
    weight += (GetRecentCommitmentSignalDayCount(deity, 7) as Float) * 10.0
    if deity == Manager.PDV_Kyne
        weight += 5.0
    endIf

    return weight
EndFunction

Function ClearPendingCommitment()
    StorageUtil.SetIntValue(None, "PDV.Commitment.PendingDeityIndex", -1)
    StorageUtil.SetFormValue(None, "PDV.Commitment.PendingDeityForm", None)
    StorageUtil.SetFloatValue(None, "PDV.Commitment.OfferedAt", 0.0)
EndFunction

Int Function GetPendingCommitmentDeityIndex()
    return StorageUtil.GetIntValue(None, "PDV.Commitment.PendingDeityIndex")
EndFunction

PDV_DeityBase Function GetPendingCommitmentDeity()
    Form pendingForm = StorageUtil.GetFormValue(None, "PDV.Commitment.PendingDeityForm")
    if pendingForm
        return pendingForm as PDV_DeityBase
    endIf

    Int deityIndex = GetPendingCommitmentDeityIndex()
    if deityIndex < 0
        return None
    endIf

    return GetDeityByIndex(deityIndex)
EndFunction

Bool Function IsCommitmentOffered(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Offered") == 1
EndFunction

Bool Function IsCommitmentDeclineDelayActive(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    Float declinedAt = StorageUtil.GetFloatValue(deity as Form, "PDV.Commitment.DeclinedAt")
    if declinedAt <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - declinedAt) < COMMITMENT_DECLINE_DELAY_DAYS
EndFunction

Bool Function IsCommitmentRefused(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    return StorageUtil.GetIntValue(deity as Form, "PDV.Commitment.Refused") == 1
EndFunction

Function RecordCommitmentSignalDay(PDV_DeityBase deity)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int encodedDay = currentDay + 1
    Int latestDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalLatestDay")
    Int previousDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay")

    if latestDay == encodedDay
        return
    endIf

    if !PDV_DevotionRules.IsEncodedDayWithinWindow(latestDay, currentDay, 7)
        latestDay = 0
        previousDay = 0
    elseIf !PDV_DevotionRules.IsEncodedDayWithinWindow(previousDay, currentDay, 7)
        previousDay = 0
    endIf

    if latestDay > 0
        previousDay = latestDay
    endIf

    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalLatestDay", encodedDay)
    StorageUtil.SetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay", previousDay)
EndFunction

Bool Function HasRecentCommitmentSignalDays(PDV_DeityBase deity, Int requiredCount, Int windowDays)
    return GetRecentCommitmentSignalDayCount(deity, windowDays) >= requiredCount
EndFunction

Int Function GetRecentCommitmentSignalDayCount(PDV_DeityBase deity, Int windowDays)
    if !deity
        return 0
    endIf

    Form deityForm = deity as Form
    Int currentDay = Utility.GetCurrentGameTime() as Int
    Int latestDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalLatestDay")
    Int previousDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.SignalPreviousDay")
    Int count = 0

    if PDV_DevotionRules.IsEncodedDayWithinWindow(latestDay, currentDay, windowDays)
        count += 1
    endIf

    if previousDay != latestDay && PDV_DevotionRules.IsEncodedDayWithinWindow(previousDay, currentDay, windowDays)
        count += 1
    endIf

    if count < 2 && StorageUtil.GetIntValue(deityForm, "PDV.Commitment.DebugSeedActive") == 1
        Int debugSeedDay = StorageUtil.GetIntValue(deityForm, "PDV.Commitment.DebugSeedDay")
        Int debugDayDelta = currentDay - debugSeedDay
        if debugDayDelta >= 0 && debugDayDelta < windowDays
            count = 2
        endIf
    endIf

    return count
EndFunction

Bool Function ShouldBypassFormalCommitmentOffers()
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    if originRace == Manager.ORIGIN_NORD && Manager.OriginRuntime.IsNordVampireSuppressed()
        return True
    endIf

    return originRace == Manager.ORIGIN_KHAJIIT || originRace == Manager.ORIGIN_BOSMER
EndFunction

Function HandleCurseStateRefresh(String reason)
    if !Manager.PDV_CurseStateService
        return
    endIf

    Int oldState = Manager.PDV_CurseStateService.GetCurseState()
    Manager.PDV_CurseStateService.RefreshFromPlayerState()
    Int newState = Manager.PDV_CurseStateService.GetCurseState()

    if oldState != newState
        HandleCurseStateTransition(oldState, newState, reason)
    else
        if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_ARGONIAN
            Manager.OriginRuntime.RefreshArgonianHistPosture(reason)
        endIf
        if Manager.PDV_HircinePath
            Manager.PDV_HircinePath.UpdateResidueRecovery()
            Manager.DaedricRuntime.DrainHircineResiduePrismaToasts()
        endIf
    endIf
EndFunction

Function HandleCurseStateTransition(Int oldState, Int newState, String reason)
    StorageUtil.SetIntValue(None, "PDV.Curse.State", newState)
    StorageUtil.SetFloatValue(None, "PDV.Curse.LastTransitionAt", Utility.GetCurrentGameTime())
    StorageUtil.SetStringValue(None, "PDV.Curse.LastTransitionReason", reason)

    Bool suppressOutputs = Manager.OriginRuntime.IsCurseStateLoadReconciliation(reason)
    Bool previousSuppress = Manager.GetSuppressCurseTransitionOutputs()
    Manager.SetSuppressCurseTransitionOutputs(suppressOutputs)
    Manager.SetRaceCurseSurfaceShown(False)
    ApplyCurseRaceHandlers(oldState, newState, reason)
    Manager.SetSuppressCurseTransitionOutputs(previousSuppress)

    ; Re-sync the reward/neglect layer immediately so a curse onset/cure applies or
    ; reverts the race neglect ability now, instead of waiting for the next dawn/re-sync
    ; tick. With Recover-flagged neglect MGEFs, cure cleanly restores the actor value.
    SyncFirstTierRaceRewardRuntime()

    Manager.Trace(1, "Curse transition " + oldState + " -> " + newState + " (" + reason + ")")
    if suppressOutputs
        Manager.Trace(2, "Curse transition surfaced silently during load reconciliation.")
    else
        Manager.Prisma.SendPrismaCurseToast(oldState, newState)
        Manager.Prisma.SurfaceCurseTransitionDiegetic(oldState, newState)
    endIf
    Manager.Prisma.RequestPanelRefresh()
EndFunction

Function ResyncCurseStateMirror(String reason)
    if !Manager.PDV_CurseStateService
        return
    endIf
    Int liveState = Manager.PDV_CurseStateService.GetCurseState()
    if StorageUtil.GetIntValue(None, "PDV.Curse.State") == liveState
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Curse.State", liveState)
    Manager.Trace(1, "Curse mirror re-synced to " + liveState + " (" + reason + ")")
EndFunction

Function ApplyCurseRaceHandlers(Int oldState, Int newState, String reason)
    Int originRace = Manager.GetPlayerOriginRaceIndex()
    Bool curseActive = newState != 0

    if originRace == Manager.ORIGIN_BOSMER
        StorageUtil.SetIntValue(None, "PDV.Curse.Bosmer.RoutePressure", PDV_DevotionRules.BoolToInt(curseActive))
    elseIf originRace == Manager.ORIGIN_BRETON
        Manager.OriginRuntime.ApplyBretonCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_DUNMER
        Manager.OriginRuntime.ApplyDunmerCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_ALTMER
        Manager.OriginRuntime.ApplyAltmerCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_ARGONIAN
        Manager.OriginRuntime.ApplyArgonianCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_IMPERIAL
        Manager.OriginRuntime.ApplyImperialCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_ORC
        Manager.OriginRuntime.ApplyOrcCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_REDGUARD
        Manager.OriginRuntime.ApplyRedguardCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_KHAJIIT
        Manager.OriginRuntime.ApplyKhajiitCurseHandlers(oldState, newState, reason)
    elseIf originRace == Manager.ORIGIN_NORD
        Manager.OriginRuntime.ApplyNordCurseHandlers(oldState, newState, reason)
        if Manager.PDV_HircinePath
            if !Manager.GetSuppressCurseTransitionOutputs()
                Manager.PDV_HircinePath.HandleCurseTransition(oldState, newState, reason)
                if oldState != 1 && newState == 1
                    Manager.Prisma.AppendBookOfDaysEntry("The beast-blood took you and stirred Hircine. The Hunt is in you now.", Utility.GetCurrentGameTime() as Int, "curse.onset", "hircine", False, 3)
                endIf
                Manager.PDV_HircinePath.UpdateResidueRecovery()
                Manager.DaedricRuntime.DrainHircineResiduePrismaToasts()
            endIf
        endIf
    endIf
EndFunction

Function RecordRecentDevotionEvent(String line)
    if line == ""
        return
    endIf

    while StorageUtil.StringListCount(None, "PDV.RecentDevotionEvents") >= 8
        StorageUtil.StringListShift(None, "PDV.RecentDevotionEvents")
    endWhile

    StorageUtil.StringListAdd(None, "PDV.RecentDevotionEvents", line, True)
EndFunction

String Function GetRecentDevotionEventsText()
    Int count = StorageUtil.StringListCount(None, "PDV.RecentDevotionEvents")
    if count <= 0
        return ""
    endIf

    String text = "Recent:"
    Int index = 0
    while index < count
        text = text + "\n" + StorageUtil.StringListGet(None, "PDV.RecentDevotionEvents", index)
        index = index + 1
    endWhile

    return text
EndFunction

String Function AppendRecentDevotionEvents(String text)
    String recent = GetRecentDevotionEventsText()
    if recent != ""
        return text + "\n\n" + recent
    endIf

    return text
EndFunction

String Function GetPlayerMcmNeglectLine()
    Int activeCount = StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount")
    if activeCount > 0
        return "Attention needed"
    endIf

    if GetPatronState() == PATRON_STATE_ACTIVE
        return "Steady"
    endIf

    ; "No neglect" not bare "None": the Anvil MCM font renders a lone "None" blank.
    return "No neglect"
EndFunction

String Function GetCommitmentSummary()
    PDV_DeityBase pending = GetPendingCommitmentDeity()
    String summary = "state=" + GetPatronStateLabel() + ";active=" + GetDeitySummaryLabel(Manager.GetActiveDeity()) + ";pending=" + GetPendingCommitmentDeityIndex() + ";label=" + GetDeitySummaryLabel(pending) + ";carry=" + StorageUtil.GetFloatValue(None, "PDV.Commitment.LastCarryover") + ";rupture=" + StorageUtil.GetIntValue(None, "PDV.Commitment.Rupture")
    if pending
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(pending, 7) + ";offered=" + PDV_DevotionRules.BoolToInt(IsCommitmentOffered(pending)) + ";refused=" + PDV_DevotionRules.BoolToInt(IsCommitmentRefused(pending))
    elseIf Manager.PDV_Kyne
        summary = summary + ";days=" + GetRecentCommitmentSignalDayCount(Manager.PDV_Kyne, 7) + ";offered=" + PDV_DevotionRules.BoolToInt(IsCommitmentOffered(Manager.PDV_Kyne)) + ";refused=" + PDV_DevotionRules.BoolToInt(IsCommitmentRefused(Manager.PDV_Kyne))
    endIf

    return summary
EndFunction

String Function GetNeglectSummary()
    return "state=" + GetPatronStateLabel() + ";broad=" + PDV_DevotionRules.BoolToInt(IsBroadWorshipActive()) + ";activeDeity=" + GetDeitySummaryLabel(Manager.GetActiveDeity()) + ";count=" + StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") + ";active=" + GetNeglectActiveSummary() + ";kyneSpell=" + StorageUtil.GetIntValue(None, "PDV.Neglect.KyneSpellActive")
EndFunction

String Function GetNeglectActiveSummary()
    if !PDV_FLST_AllDeities
        return "none"
    endIf

    String output = ""
    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && IsNeglectFlagActive(deity)
            if output == ""
                output = deity.DeityName
            else
                output = output + "," + deity.DeityName
            endIf
        endIf
        i += 1
    endWhile

    if output == ""
        return "none"
    endIf

    return output
EndFunction

String Function GetDeitySummaryLabel(PDV_DeityBase deity)
    if deity
        return deity.DeityName
    endIf

    return "none"
EndFunction

Function ApplyRivalryPenalties(PDV_DeityBase sourceDeity, Float sourceAmount)
    Quest[] rivalForms = sourceDeity.RivalDeities
    Float[] rivalMultipliers = sourceDeity.RivalMultipliers

    if !rivalForms || !rivalMultipliers
        return
    endIf

    Bool rivalToastShown = False
    Int i = 0
    Int rivalCount = rivalForms.Length
    while i < rivalCount
        if i < rivalMultipliers.Length
            PDV_DeityBase rivalDeity = rivalForms[i] as PDV_DeityBase
            Float rivalAmount = sourceAmount * rivalMultipliers[i] * -1.0

            if rivalDeity && rivalAmount != 0.0
                AwardPietyInternal(rivalDeity, rivalAmount, False, "rivalry with " + sourceDeity.DeityName)

                if !rivalToastShown
                    Manager.Prisma.SendPrismaEventToast("rivalry", sourceDeity, "", "", rivalDeity.DeityName)
                    rivalToastShown = True
                endIf

                if Manager.GetDebugLevel() >= 2
                    Debug.Trace("[PDV] Rivalry: " + sourceDeity.DeityName + " applied " + rivalAmount + " to " + rivalDeity.DeityName)
                endIf
            endIf
        endIf

        i += 1
    endWhile
EndFunction

Function EnsureDeityState(PDV_DeityBase deity)
    Form deityForm = Manager.GetDeityFormOrNone(deity)
    if !deityForm
        return
    endIf

    StorageUtil.GetFloatValue(deityForm, "PDV.Piety")
    StorageUtil.GetFloatValue(deityForm, "PDV.PietyToday")
    StorageUtil.GetFloatValue(deityForm, "PDV.Tier")
    StorageUtil.GetFloatValue(deityForm, "PDV.LastTierChange")
EndFunction

Int Function ComputeTierFromPiety(PDV_DeityBase deity, Float piety)
    if !deity
        return TIER_NONE
    endIf

    Int tierCap = deity.GetTierCap()
    if piety >= deity.ThresholdChampion
        if tierCap < TIER_CHAMPION
            return tierCap
        endIf
        return TIER_CHAMPION
    elseIf piety >= deity.ThresholdDevoted
        if tierCap < TIER_DEVOTED
            return tierCap
        endIf
        return TIER_DEVOTED
    elseIf piety >= deity.ThresholdSeeker
        if tierCap < TIER_SEEKER
            return tierCap
        endIf
        return TIER_SEEKER
    endIf

    return TIER_NONE
EndFunction

Float Function ThresholdForTier(PDV_DeityBase deity, Int tierValue)
    if !deity
        return 0.0
    endIf

    if tierValue >= TIER_CHAMPION
        return deity.ThresholdChampion
    elseIf tierValue >= TIER_DEVOTED
        return deity.ThresholdDevoted
    elseIf tierValue >= TIER_SEEKER
        return deity.ThresholdSeeker
    endIf

    return 0.0
EndFunction

PDV_DeityBase Function GetDeityByIndex(Int deityIndex)
    if deityIndex < 0 || !PDV_FLST_AllDeities
        return GetKnownDeityByIndex(deityIndex)
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity && deity.DeityIndex == deityIndex
            return deity
        endIf
        i += 1
    endWhile

    return GetKnownDeityByIndex(deityIndex)
EndFunction

PDV_DeityBase Function GetKnownDeityByIndex(Int deityIndex)
    if Manager.PDV_Kyne && Manager.PDV_Kyne.DeityIndex == deityIndex
        return Manager.PDV_Kyne
    endIf

    if PDV_Kynareth && PDV_Kynareth.DeityIndex == deityIndex
        return PDV_Kynareth
    endIf

    if Manager.PDV_Talos && Manager.PDV_Talos.DeityIndex == deityIndex
        return Manager.PDV_Talos
    endIf

    if Manager.PDV_Yffre && Manager.PDV_Yffre.DeityIndex == deityIndex
        return Manager.PDV_Yffre
    endIf

    if PDV_Zen && PDV_Zen.DeityIndex == deityIndex
        return PDV_Zen
    endIf

    if Manager.PDV_BaanDar && Manager.PDV_BaanDar.DeityIndex == deityIndex
        return Manager.PDV_BaanDar
    endIf

    return None
EndFunction

Function UpdatePatronDeityGlobal()
    if Manager.GetActiveDeity()
        StorageUtil.SetIntValue(None, "PDV.PatronDeityIndex", Manager.GetActiveDeity().DeityIndex)
    else
        StorageUtil.SetIntValue(None, "PDV.PatronDeityIndex", -1)
    endIf

    if !PDV_GLO_PatronDeity
        return
    endIf

    if !Manager.GetActiveDeity()
        PDV_GLO_PatronDeity.SetValue(0.0)
        return
    endIf

    PDV_GLO_PatronDeity.SetValue((Manager.GetActiveDeity() as Form).GetFormID() as Float)
EndFunction

Function RestoreActiveDeityFromStoredPatron()
    Int deityIndex = StorageUtil.GetIntValue(None, "PDV.PatronDeityIndex")
    if deityIndex < 0
        return
    endIf

    PDV_DeityBase deity = GetDeityByIndex(deityIndex)
    if !deity
        Manager.Trace(1, "Stored patron deity index " + deityIndex + " could not be restored.")
        return
    endIf

    Manager.SetActiveDeityRef(deity)
    EnsureDeityState(Manager.GetActiveDeity())
    Manager.GetActiveDeity().OnPatronStart()
    Manager.Trace(2, "Restored active deity from stored patron index " + deityIndex)
EndFunction

Function ReapplyActiveDisfavorStings(Actor playerRef)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_SKY_STORM_HUNT)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_DEATH_ANCESTORS)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_MERCY_PROTECTION)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_WAR_HONOR)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_ORDER_TRADE_LORE)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_MOON_LUCK_SHADOW)
    ReapplyOneDisfavorSting(playerRef, DISFAVOR_DOMAIN_VOID_SECRETS)
EndFunction

Function ReapplyOneDisfavorSting(Actor playerRef, Int domainValue)
    if !playerRef || !IsDisfavorDomainActive(domainValue)
        return
    endIf

    Bool sharpBand = StorageUtil.GetStringValue(None, GetDisfavorBandKey(domainValue)) == GetDisfavorBandLabel(True)
    Spell bandSpell = GetDisfavorSpell(domainValue, sharpBand)
    if bandSpell && !playerRef.HasSpell(bandSpell)
        playerRef.AddSpell(bandSpell, False)
    endIf
EndFunction







