;/
    PDV_Deity_Syrabane.psc
    PlayerDevotion - Altmer Syrabane focus deity
    -----------------------------------------------------------------------
    Syrabane is an Altmer-owned secondary focus. The launch lane is narrow:
    warding, magical protection, apprentice or College aid, curse and disease
    warding, and anti-mage survival. Generic spellcasting, raw magic skill
    gain, every ward cast, and generic College membership are rejected by the
    design contract.

    Signal block 2000-2099. Quest-reaction rows can still award piety through
    the shared matrix path; these curated signals are for direct Altmer route
    handlers and future exact-source protection milestones.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Syrabane extends PDV_DeityBase

Int Property SIGNAL_PROTECTIVE_WARDING = 2001 AutoReadOnly
Int Property SIGNAL_APPRENTICE_AID = 2002 AutoReadOnly
Int Property SIGNAL_CURSE_DISEASE_WARDING = 2003 AutoReadOnly
Int Property SIGNAL_ANTI_MAGE_SURVIVAL = 2004 AutoReadOnly
Int Property SIGNAL_MAGICAL_CONTAINMENT = 2005 AutoReadOnly

Float Property DELTA_PROTECTIVE_WARDING = 1.8 Auto
Float Property DELTA_APPRENTICE_AID = 1.8 Auto
Float Property DELTA_CURSE_DISEASE_WARDING = 2.0 Auto
Float Property DELTA_ANTI_MAGE_SURVIVAL = 1.8 Auto
Float Property DELTA_MAGICAL_CONTAINMENT = 2.2 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Syrabane deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_PROTECTIVE_WARDING
        return DELTA_PROTECTIVE_WARDING
    elseIf signalType == SIGNAL_APPRENTICE_AID
        return DELTA_APPRENTICE_AID
    elseIf signalType == SIGNAL_CURSE_DISEASE_WARDING
        return DELTA_CURSE_DISEASE_WARDING
    elseIf signalType == SIGNAL_ANTI_MAGE_SURVIVAL
        return DELTA_ANTI_MAGE_SURVIVAL
    elseIf signalType == SIGNAL_MAGICAL_CONTAINMENT
        return DELTA_MAGICAL_CONTAINMENT
    endIf

    return 0.0
EndFunction
