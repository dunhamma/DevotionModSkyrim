;/
    PDV_DaedricPathBase.psc
    PlayerDevotion - V3 Structural Skeleton Daedric path base
    -----------------------------------------------------------------------
    Extends deity behavior with Daedric boon/price/stigma contract grammar.
    Inert until concrete Daedric path quests extend or attach it.
    -----------------------------------------------------------------------
/;

Scriptname PDV_DaedricPathBase extends PDV_DeityBase

Spell Property Price_Seeker Auto
Spell Property Price_Devoted Auto
Spell Property Price_Champion Auto

Float Property StigmaPerEvent = 1.0 Auto
GlobalVariable Property StigmaGlobal Auto
Int Property CommitmentSignalsRequired = 3 Auto
Float Property PIETY_MAX = 200.0 AutoReadOnly

Int[] Property StateByRace Auto
Float[] Property StigmaModByRace Auto
Int[] Property ExitDifficultyByRace Auto

Int Property DAEDRIC_STATE_NATIVE = 0 AutoReadOnly
Int Property DAEDRIC_STATE_LEGIBLE = 1 AutoReadOnly
Int Property DAEDRIC_STATE_FOREIGN = 2 AutoReadOnly
Int Property DAEDRIC_STATE_TOLERATED = 3 AutoReadOnly
Int Property DAEDRIC_STATE_TABOO = 4 AutoReadOnly
Int Property DAEDRIC_STATE_HOSTILE = 5 AutoReadOnly
Int Property DAEDRIC_STATE_CURSE = 6 AutoReadOnly

; Daedric pacts are EXCLUSIVE: only one Prince's boon+price are live at a time
; (hard switch). The active pact is a single deity form; the spells it granted are
; tracked in a StorageUtil form-list so the next activation can strip them without
; needing a reference to the previous path. The curse (Hircine/Molag) is separate
; from the pact favor and is untouched here.
String Property DAEDRIC_ACTIVE_PACT_KEY = "PDV.Daedric.ActivePact" AutoReadOnly
String Property DAEDRIC_LIVE_SPELLS_KEY = "PDV.Daedric.LivePactSpells" AutoReadOnly

Function OnTierChange(Int oldTier, Int newTier)
    if newTier > 0
        ; Advancing (or re-granting at a tier) makes THIS Prince the active pact.
        MakeActiveDaedricPact()
    elseIf IsActiveDaedricPact()
        ; The active pact lapsed to nothing; drop its effects and the pointer.
        ClearLiveDaedricPactSpells()
        StorageUtil.SetFormValue(None, DAEDRIC_ACTIVE_PACT_KEY, None)
        ; Leave a breadcrumb: this base script has no manager handle, so the manager's
        ; 1s tick (ProcessPendingDaedricLapse) reads this key and surfaces the lapse.
        ; Switch/migration severs clear the pointer directly and never reach here, so
        ; they cannot false-fire a lapse.
        StorageUtil.SetFormValue(None, "PDV.Daedric.PendingLapse", GetDeityForm())
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " daedric pact tier: " + oldTier + " -> " + newTier + " (active=" + IsActiveDaedricPact() + ")")
    endIf

    ShowTierEntryMessage(oldTier, newTier)
EndFunction

Bool Function IsActiveDaedricPact()
    return StorageUtil.GetFormValue(None, DAEDRIC_ACTIVE_PACT_KEY) == GetDeityForm()
EndFunction

; Make this Prince the single active pact: strip whatever pact spells are currently
; live (this Prince's or another's), grant this Prince's boon+price for its tier,
; and record them for the next switch. Idempotent.
Function MakeActiveDaedricPact()
    Form priorPact = StorageUtil.GetFormValue(None, DAEDRIC_ACTIVE_PACT_KEY)
    ClearLiveDaedricPactSpells()
    StorageUtil.SetFormValue(None, DAEDRIC_ACTIVE_PACT_KEY, GetDeityForm())
    Int tierValue = GetStoredTier()
    SyncPatronBoonsToTier(tierValue)
    SyncDaedricContractToTier(tierValue)
    TrackLiveDaedricPactSpells(tierValue)
    ; THE exclusivity seam. Every NEW pact activation funnels through here -- the
    ; live commitment funnel, an ambient/shrine tier-up (OnTierChange auto-calls this),
    ; and switch-back. On a genuine new activation (not a same-pact re-grant) leave a
    ; breadcrumb; the manager tick (ProcessPendingDaedricActivation) reads it and severs
    ; any active patron + surfaces the switch. The base has no manager handle, so it
    ; cannot check/sever the patron itself -- hence the breadcrumb, mirroring PendingLapse.
    if priorPact != GetDeityForm()
        StorageUtil.SetFormValue(None, "PDV.Daedric.PendingActivation", GetDeityForm())
    endIf
EndFunction

Function ClearLiveDaedricPactSpells()
    Actor player = Game.GetPlayer()
    Int i = StorageUtil.FormListCount(None, DAEDRIC_LIVE_SPELLS_KEY)
    while i > 0
        i -= 1
        Spell tracked = StorageUtil.FormListGet(None, DAEDRIC_LIVE_SPELLS_KEY, i) as Spell
        if tracked
            player.RemoveSpell(tracked)
        endIf
    endWhile
    StorageUtil.FormListClear(None, DAEDRIC_LIVE_SPELLS_KEY)
EndFunction

Function TrackLiveDaedricPactSpells(Int tierValue)
    if tierValue >= TIER_CHAMPION
        TrackPactSpell(Boon_Champion)
        TrackPactSpell(Price_Champion)
    elseIf tierValue >= TIER_DEVOTED
        TrackPactSpell(Boon_Devoted)
        TrackPactSpell(Price_Devoted)
    elseIf tierValue >= TIER_SEEKER
        TrackPactSpell(Boon_Seeker)
        TrackPactSpell(Price_Seeker)
    endIf
EndFunction

Function TrackPactSpell(Spell pactSpell)
    if pactSpell
        StorageUtil.FormListAdd(None, DAEDRIC_LIVE_SPELLS_KEY, pactSpell)
    endIf
EndFunction

; Remove this path's boon+price spells from the player. Used by the manager's
; one-time hard-switch migration to clear stacked spells on old saves.
Function StripPactSpells()
    ClearAllBoons()
    ClearPriceSpells()
EndFunction

Function SyncPatronBoonsToTier(Int tierValue)
    ClearAllBoons()
    if tierValue <= TIER_NONE || !IsActiveDaedricPact()
        return
    endIf

    if tierValue >= TIER_CHAMPION && Boon_Champion
        Game.GetPlayer().AddSpell(Boon_Champion, False)
    elseIf tierValue >= TIER_DEVOTED && Boon_Devoted
        Game.GetPlayer().AddSpell(Boon_Devoted, False)
    elseIf tierValue >= TIER_SEEKER && Boon_Seeker
        Game.GetPlayer().AddSpell(Boon_Seeker, False)
    endIf
EndFunction

; Authored player-facing beat hooks. Concrete PDV_DaedricPath_<Prince> scripts
; override these to Show their wired MESG records. The base default is silent, so
; sub-threshold commitment signals and any message-less path stay quiet.
Function ShowTierEntryMessage(Int oldTier, Int newTier)
EndFunction

Function ShowCommitmentBeat()
EndFunction

Bool Function HandleChampionOfferResult(Int selection, String reason)
    if selection <= 0
        return True
    endIf

    DeclineChampionOffer(reason)
    return False
EndFunction

Function DeclineChampionOffer(String reason)
    if GetStoredTier() < TIER_CHAMPION
        return
    endIf

    Float fallbackPiety = ThresholdChampion - 1.0
    if fallbackPiety < ThresholdDevoted
        fallbackPiety = ThresholdDevoted
    endIf

    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Piety", fallbackPiety)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Tier", TIER_DEVOTED as Float)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.LastTierChange", Utility.GetCurrentGameTime())
    if IsActiveDaedricPact()
        MakeActiveDaedricPact()
    else
        StripPactSpells()
    endIf

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " daedric Champion offer declined (" + reason + "); reverted to Devoted.")
    endIf
EndFunction

; Debug-only: seat the path at Champion WITHOUT firing the inline tier-entry
; message, so the MCM can defer the authored Champion offer to after the menu
; closes (a raw Message.Show cannot display while the MCM is open). The deferred
; replay then shows the real Msg_ChampionEntry and applies Accept/Decline.
Function DebugSeatChampionSilently()
    Form deityForm = GetDeityForm()
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", ThresholdChampion + 1.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.Tier", TIER_CHAMPION as Float)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", Utility.GetCurrentGameTime())
    MakeActiveDaedricPact()
EndFunction

Function OnPatronStart()
    if GetStoredTier() > TIER_NONE
        MakeActiveDaedricPact()
    else
        StripPactSpells()
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    ClearPriceSpells()
EndFunction

Bool Function HasCommitmentSignalGateOpen()
    return GetCommitmentSignalCount() >= CommitmentSignalsRequired
EndFunction

; V2 transgressive-Prince ambient layer. Only an OPEN (committed) path scores; reads the
; PDV.PLD.* table namespace (separate from the V1 PDV.LD.* deity table) keyed on this path
; form. Anti-farm runs through the shared dawn-aligned ScoreRepeatableAction. Returns the
; "deepen" delta; the caller (PDV__ManagerQuest.RouteActionToOpenPaths) applies it to THIS
; path's own piety, never the player's ambient V1 pool, and only deepen-not-initiate (the
; HasCommitmentSignalGateOpen guard means an uncommitted player never drifts toward a Prince).
Float Function ScorePrinceAction(Int eventType)
    if !HasCommitmentSignalGateOpen()
        return 0.0
    endIf
    Form pldForm = GetDeityForm()
    String pldPrefix = "PDV.PLD." + eventType
    Float pldDelta = StorageUtil.GetFloatValue(pldForm, pldPrefix + ".D")
    if pldDelta == 0.0
        return 0.0
    endIf
    Int pldCap = StorageUtil.GetIntValue(pldForm, pldPrefix + ".C")
    Float pldCooldown = StorageUtil.GetFloatValue(pldForm, pldPrefix + ".O")
    return ScoreRepeatableAction(eventType, pldDelta, pldCap, pldCooldown)
EndFunction

Int Function GetCommitmentSignalCount()
    return StorageUtil.GetIntValue(GetDeityForm(), "PDV.Daedric.CommitmentSignals")
EndFunction

Function AddCommitmentSignal(String reason)
    Int newCount = GetCommitmentSignalCount() + 1
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.CommitmentSignals", newCount)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.LastCommitmentSignal", Utility.GetCurrentGameTime())
    if newCount == CommitmentSignalsRequired
        ShowCommitmentBeat()
    endIf
    TraceDaedric(2, "Commitment signal " + newCount + " (" + reason + ")")
EndFunction

Function DebugForceCommitmentSignals(Int signalCount, String reason)
    if signalCount < 0
        signalCount = 0
    endIf

    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.CommitmentSignals", signalCount)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.LastCommitmentSignal", Utility.GetCurrentGameTime())
    TraceDaedric(2, "DebugForceCommitmentSignals " + signalCount + " (" + reason + ")")
EndFunction

Float Function GetStigma()
    if StigmaGlobal
        return StigmaGlobal.GetValue()
    endIf

    return StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Daedric.Stigma")
EndFunction

Function AddStigma(Float amount, String reason)
    Float modifiedAmount = amount * GetStigmaModifierForRace(GetPlayerOriginRace())
    Float newStigma = GetStigma() + modifiedAmount

    if newStigma < 0.0
        newStigma = 0.0
    endIf

    if StigmaGlobal
        StigmaGlobal.SetValue(newStigma)
    endIf

    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Stigma", newStigma)
    TraceDaedric(2, "Stigma " + newStigma + " (" + reason + ")")
EndFunction

Function DebugForceStigma(Float amount, String reason)
    if amount < 0.0
        amount = 0.0
    endIf

    if StigmaGlobal
        StigmaGlobal.SetValue(amount)
    endIf

    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Stigma", amount)
    TraceDaedric(2, "DebugForceStigma " + amount + " (" + reason + ")")
EndFunction

Function ResetDaedricForDebug()
    StorageUtil.SetIntValue(GetDeityForm(), "PDV.Daedric.CommitmentSignals", 0)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.LastCommitmentSignal", 0.0)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Daedric.Stigma", 0.0)

    if StigmaGlobal
        StigmaGlobal.SetValue(0.0)
    endIf

    ClearPriceSpells()
    TraceDaedric(2, "ResetDaedricForDebug")
EndFunction

Int Function GetDaedricStateForPlayer()
    return GetDaedricStateForRace(GetPlayerOriginRace())
EndFunction

Int Function GetDaedricStateForRace(Int raceIndex)
    if raceIndex >= 0 && raceIndex < StateByRace.Length
        return StateByRace[raceIndex]
    endIf

    return DAEDRIC_STATE_TOLERATED
EndFunction

Float Function GetStigmaModifierForRace(Int raceIndex)
    if raceIndex >= 0 && raceIndex < StigmaModByRace.Length
        return StigmaModByRace[raceIndex]
    endIf

    return 1.0
EndFunction

Int Function GetExitDifficultyForPlayer()
    Int raceIndex = GetPlayerOriginRace()
    if raceIndex >= 0 && raceIndex < ExitDifficultyByRace.Length
        return ExitDifficultyByRace[raceIndex]
    endIf

    return 1
EndFunction

Float Function GetStoredPiety()
    return StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Piety")
EndFunction

Function SetStoredPiety(Float amount, String reason)
    Float normalizedPiety = ClampPiety(amount)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Piety", normalizedPiety)
    StorageUtil.SetFloatValue(GetDeityForm(), "PDV.LastEventGameTime", Utility.GetCurrentGameTime())
    RecomputeStoredTier(reason)
    TraceDaedric(2, "SetStoredPiety " + normalizedPiety + " (" + reason + ")")
EndFunction

Function AdjustStoredPiety(Float amount, String reason)
    SetStoredPiety(GetStoredPiety() + amount, reason)
EndFunction

Int Function RecomputeStoredTier(String reason)
    Int oldTier = GetStoredTier()
    Int newTier = ComputeTierFromStoredPiety()

    if oldTier != newTier
        StorageUtil.SetFloatValue(GetDeityForm(), "PDV.Tier", newTier as Float)
        StorageUtil.SetFloatValue(GetDeityForm(), "PDV.LastTierChange", Utility.GetCurrentGameTime())
        OnTierChange(oldTier, newTier)
        TraceDaedric(1, "Tier " + oldTier + " -> " + newTier + " (" + reason + ")")
    else
        if newTier > TIER_NONE && IsActiveDaedricPact()
            MakeActiveDaedricPact()
        else
            StripPactSpells()
        endIf
    endIf

    return newTier
EndFunction

Int Function ComputeTierFromStoredPiety()
    Float piety = GetStoredPiety()
    if piety >= ThresholdChampion
        return TIER_CHAMPION
    elseIf piety >= ThresholdDevoted
        return TIER_DEVOTED
    elseIf piety >= ThresholdSeeker
        return TIER_SEEKER
    endIf

    return TIER_NONE
EndFunction

String Function GetDaedricStateLabel(Int stateValue)
    if stateValue == DAEDRIC_STATE_NATIVE
        return "Native"
    elseIf stateValue == DAEDRIC_STATE_LEGIBLE
        return "Legible"
    elseIf stateValue == DAEDRIC_STATE_FOREIGN
        return "Foreign"
    elseIf stateValue == DAEDRIC_STATE_TOLERATED
        return "Tolerated"
    elseIf stateValue == DAEDRIC_STATE_TABOO
        return "Taboo"
    elseIf stateValue == DAEDRIC_STATE_HOSTILE
        return "Hostile"
    elseIf stateValue == DAEDRIC_STATE_CURSE
        return "Curse"
    endIf

    return "Unknown"
EndFunction

String Function GetContractSummary()
    return "p=" + GetStoredPiety() + "; tier=" + GetStoredTier() + "; sig=" + GetCommitmentSignalCount() + "; stigma=" + GetStigma() + "; state=" + GetDaedricStateLabel(GetDaedricStateForPlayer())
EndFunction

String Function GetBoonSpellStateSummary()
    return "boon=" + GetSpellTierStateSummary(Boon_Seeker, Boon_Devoted, Boon_Champion)
EndFunction

String Function GetPriceSpellStateSummary()
    return "price=" + GetSpellTierStateSummary(Price_Seeker, Price_Devoted, Price_Champion)
EndFunction

String Function GetDaedricSpellSummary()
    return GetBoonSpellStateSummary() + "; " + GetPriceSpellStateSummary()
EndFunction

Int Function GetPlayerOriginRace()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf

    return RACE_IMPERIAL
EndFunction

Function SyncDaedricContractToTier(Int tierValue)
    ClearPriceSpells()
    if tierValue <= TIER_NONE || !IsActiveDaedricPact()
        return
    endIf

    if tierValue >= TIER_CHAMPION && Price_Champion
        Game.GetPlayer().AddSpell(Price_Champion, False)
    elseIf tierValue >= TIER_DEVOTED && Price_Devoted
        Game.GetPlayer().AddSpell(Price_Devoted, False)
    elseIf tierValue >= TIER_SEEKER && Price_Seeker
        Game.GetPlayer().AddSpell(Price_Seeker, False)
    endIf
EndFunction

Function ClearPriceSpells()
    if Price_Seeker
        Game.GetPlayer().RemoveSpell(Price_Seeker)
    endIf
    if Price_Devoted
        Game.GetPlayer().RemoveSpell(Price_Devoted)
    endIf
    if Price_Champion
        Game.GetPlayer().RemoveSpell(Price_Champion)
    endIf
EndFunction

String Function GetSpellTierStateSummary(Spell seekerSpell, Spell devotedSpell, Spell championSpell)
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return "none"
    endIf

    String output = ""
    if seekerSpell && playerRef.HasSpell(seekerSpell)
        output = AppendSpellStateToken(output, "seeker")
    endIf
    if devotedSpell && playerRef.HasSpell(devotedSpell)
        output = AppendSpellStateToken(output, "devoted")
    endIf
    if championSpell && playerRef.HasSpell(championSpell)
        output = AppendSpellStateToken(output, "champion")
    endIf

    if output == ""
        return "none"
    endIf

    return output
EndFunction

String Function AppendSpellStateToken(String currentValue, String token)
    if currentValue == ""
        return token
    endIf

    return currentValue + "+" + token
EndFunction

Function TraceDaedric(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] DaedricPath: " + DeityName + ": " + traceText)
    endIf
EndFunction

Float Function ClampPiety(Float amount)
    if amount < 0.0
        return 0.0
    elseIf amount > PIETY_MAX
        return PIETY_MAX
    endIf

    return amount
EndFunction
