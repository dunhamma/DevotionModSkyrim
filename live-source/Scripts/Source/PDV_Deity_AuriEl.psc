;/ 
    PDV_Deity_AuriEl.psc
    PlayerDevotion - Auri-El minimal foundation deity
    -----------------------------------------------------------------------
    OVERVIEW
    Auri-El is the minimum viable Altmer foundation deity for the coupled
    Talos/Auri-El proof slice. He is a real ledger target and patron option,
    but this slice does not attempt the full layered Altmer theology.

    DESIGN NOTES
    - "Always active" in this slice means seeded Altmer standing plus
      curated foundational signals, not a bypass of patron-only boon rules.
    - Auri-El carries no direct rivalry against Talos in this first pass.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_AuriEl extends PDV_DeityBase

Int Property SIGNAL_DAWN_ACKNOWLEDGMENT = 201 AutoReadOnly
Int Property SIGNAL_ORTHODOXY_AFFIRMATION = 202 AutoReadOnly

Float Property DELTA_DAWN_ACKNOWLEDGMENT = 1.0 Auto
Float Property DELTA_ORTHODOXY_AFFIRMATION = 3.0 Auto

; Declared-but-unread contract constant. Corrected 2026-08-02: this is NOT waiting
; on a future wire. The Auri-El deity-pulse spine was DESCOPED by design on
; 2026-07-15 (see the note at tools/pdv_verify.mjs:6650). PDV_Substrate_AltmerAncestor
; owns the Altmer spine now, and it is deity-agnostic -- readback of 0715AC:Devotion.esp
; shows no deity property on that record at all.
; DO NOT delete the line below, and DO NOT add a matching spine signal constant to
; this file. pdv_verify asserts this source contains the literal
; "DELTA_ANCESTOR_SPINE = 1.0" AND that it does NOT contain that signal constant's
; name. Writing that name here -- even inside a comment -- fails the verifier.
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Auri-El deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

; D2 / fix-plan 5.2. Auri-El was the sole deity of 34 returning hardcoded literals here
; instead of its own DELTA properties, so retuning DELTA_DAWN_ACKNOWLEDGMENT or
; DELTA_ORTHODOXY_AFFIRMATION in the CK silently did nothing. Their defaults are 1.0
; and 3.0, so behaviour is unchanged today and the knobs are live from now on.
Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DAWN_ACKNOWLEDGMENT
        return DELTA_DAWN_ACKNOWLEDGMENT
    elseIf signalType == SIGNAL_ORTHODOXY_AFFIRMATION
        return DELTA_ORTHODOXY_AFFIRMATION
    endIf

    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    Parent.OnTierChange(oldTier, newTier)

    if newTier == TIER_SEEKER
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El recognizes the player's returnward discipline.")
        endIf
    elseIf newTier == TIER_DEVOTED
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El strengthens the ancestral claim.")
        endIf
    elseIf newTier == TIER_CHAMPION
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] Auri-El marks the player as an exemplar of return.")
        endIf
    endIf
EndFunction

Function OnPatronStart()
    Parent.OnPatronStart()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has chosen Auri-El as patron.")
    endIf
EndFunction

Function OnPatronEnd()
    Parent.OnPatronEnd()
    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] Player has ceased worshipping Auri-El.")
    endIf
EndFunction

Bool Function ShouldSyncLegacyPatronBoons()
    return False
EndFunction
