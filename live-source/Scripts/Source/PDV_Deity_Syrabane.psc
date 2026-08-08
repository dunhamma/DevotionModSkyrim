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

; Signal ids renumbered 2001-2005 -> 3110-3114 (1.0.3). Four of the original five
; collided with PDV_Deity_Boethiah's authored ids (2001 righteous struggle, 2002
; honorable duel, 2003 shared pact memory, 2005 reclamation abandoned), so a curated
; signal fired for one could score on the other. The highest id otherwise in use is
; 3102, and the MCM debug slider's ceiling is 3200, so 3110-3114 is free and reachable.
; STATUS (updated 2026-08-03, packet P9). FOUR of the five are now wired and firing:
;   3110 PROTECTIVE_WARDING     - a ward that BLOCKED hostile magic (OnHitEx, abHitBlocked +
;                                 akSource as Spell). Not a cast counter: "every ward cast" stays
;                                 rejected per the design contract.
;   3112 CURSE_DISEASE_WARDING  - a vanilla cure effect landing on the player
;                                 (OnMagicEffectApplyEx, PDV_FLST_Altmer_Syrabane_CureEffects).
;   3113 ANTI_MAGE_SURVIVAL     - survived a mage fight at low health with a kill; weekly stamp.
;   3114 MAGICAL_CONTAINMENT    - learning a vanilla Ward tome
;                                 (PDV_FLST_P2_AltmerSyrabaneSources, one-shot per tome).
;
; 3111 APPRENTICE_AID is deliberately NOT wired and is marked retired-not-wired in
; tools/pdv_reserved_signals.json. Every College-aid hook duplicates quest-reaction rows Syrabane
; already holds on MG01/MG02/MG03/MG05/MG07/MG08, so it would score him twice for one act. The
; constant stays declared: it costs nothing unwired, and deleting its registry entry while it is
; unwired would itself fail the signal gate.
;
; He also has a full day-to-day likes/dislikes table as of P8 -- until then he had none at all,
; and before P1 his Stance_Altmer defaulted to FOREIGN so any row would have scored 0.0 anyway.
Int Property SIGNAL_PROTECTIVE_WARDING = 3110 AutoReadOnly
Int Property SIGNAL_APPRENTICE_AID = 3111 AutoReadOnly
Int Property SIGNAL_CURSE_DISEASE_WARDING = 3112 AutoReadOnly
Int Property SIGNAL_ANTI_MAGE_SURVIVAL = 3113 AutoReadOnly
Int Property SIGNAL_MAGICAL_CONTAINMENT = 3114 AutoReadOnly

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
