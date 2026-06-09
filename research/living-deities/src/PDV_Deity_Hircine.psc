;/
    PDV_Deity_Hircine.psc
    PlayerDevotion - LD-P1 curse-gated Hircine deity face (research slice)
    -----------------------------------------------------------------------
    OVERVIEW
    Second face of Hircine: the post-curse worship + mood layer. Cloned from
    the PDV_Deity_Kyne shell per the M3 Spike 0 owner ruling (2026-06-10).
    The existing PDV_DaedricPath_Hircine is retained unchanged as the
    onboarding / stigma / cure layer; this script never touches stigma.

    DESIGN NOTES
    - CURSE GATE: this deity scores, moods, and is demand/omen-eligible ONLY
      while PDV_CurseState.IsWerewolf(). A stray beast-kill cannot pull a
      non-werewolf toward Hircine (likes/dislikes matrix section 8.2).
    - While the curse is open the gate substitutes for race nativity
      (NATIVE-equivalent): IsRaceNativeForPlayer is overridden so the
      PDV.LD.* table rows score for any race that carries the curse.
    - MASKING RULE (matrix section 10.2): ScoreAction must delegate to
      ScoreFromTable after the gate. Never return a bare 0.0 stub for the
      table path - that silently kills the data-driven rows.
    - On cure the mood state zeros and any pending demand clears; the
      manager calls HandleCurseTransition from its curse-transition fanout
      (mirrors PDV_DaedricPath_Hircine.HandleCurseTransition).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Hircine extends PDV_DeityBase

PDV_CurseState Property PDV_CurseStateService Auto

Int Property CURSE_WEREWOLF = 1 AutoReadOnly

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Hircine deity face initialized.")
    endIf
EndEvent

Bool Function IsCurseGateOpen()
    return PDV_CurseStateService && PDV_CurseStateService.IsWerewolf()
EndFunction

; While werewolf, the curse substitutes for race nativity so the generic
; faucet's race-eligibility gate (ScoreFromTable -> IsRaceNativeForPlayer)
; opens for any cursed race. While not cursed this face is fully silent.
Bool Function IsRaceNativeForPlayer()
    return IsCurseGateOpen()
EndFunction

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    if !IsCurseGateOpen()
        return 0.0
    endIf

    ; Masking rule: delegate to the data-driven base (PDV.LD.* rows) after
    ; the gate. Anti-farm runs through the shared ScoreRepeatableAction path.
    return ScoreFromTable(eventType)
EndFunction

; Called by PDV__ManagerQuest.HandleCurseStateTransition alongside the path
; actor's hook. The path actor owns stigma/residue; this face only zeros its
; own mood + demand state so the deity goes quiet immediately on cure.
Function HandleCurseTransition(Int oldState, Int newState, String reason)
    if oldState == CURSE_WEREWOLF && newState != CURSE_WEREWOLF
        Form deityForm = GetDeityForm()
        StorageUtil.SetFloatValue(deityForm, "PDV.Mood", 0.0)
        StorageUtil.SetIntValue(deityForm, "PDV.Mood.Band", MOOD_BAND_COOL)
        StorageUtil.SetIntValue(deityForm, "PDV.Demand.Pending", 0)
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Hircine deity face silenced on cure (" + reason + ").")
        endIf
    endIf
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Hircine deity face tier change: " + oldTier + " -> " + newTier)
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has turned to Hircine as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Hircine.")
    endIf
EndFunction
