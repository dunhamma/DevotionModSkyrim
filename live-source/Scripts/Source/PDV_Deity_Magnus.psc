;/
    PDV_Deity_Magnus.psc
    PlayerDevotion - Altmer Magnus focus deity
    -----------------------------------------------------------------------
    Magnus is an Altmer-owned secondary focus (one secondary at a time with
    Xarxes). He is the architect of magic: rewards disciplined study, magic
    milestones reached with restraint, and the recovery of arcane knowledge.
    Generic spellcasting spam or raw skill gain without context is rejected
    (see PDV_AltmerRewardRecords.spec.json rejectedHooks).

    Signal block 1800-1899. All three signals are wired and routing today:
    DISCIPLINED_STUDY from AwardAltmerDawnSignal (and the Breton Hidden Art lane),
    MAGIC_MILESTONE from TryAwardAltmerMagicMilestone (finite: 24 lifetime awards),
    SHARED_PACT_MEMORY from AwardActiveAltmerHeritageMemorySignal when Magnus is
    the active patron. Corrected 2026-08-02: this block previously called the
    Altmer handlers telemetry stubs, which has been false since at least 1.0.3.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Magnus extends PDV_DeityBase

Int Property SIGNAL_DISCIPLINED_STUDY = 1801 AutoReadOnly   ; curated rare-text / threshold study milestone
Int Property SIGNAL_MAGIC_MILESTONE = 1802 AutoReadOnly     ; magic milestone reached with restraint (study-framed)
Int Property SIGNAL_SHARED_PACT_MEMORY = 1804 AutoReadOnly  ; small foundation-keeping pulse to the arts
; P4 (2026-08-03). Magnus's only RENEWABLE-FOREVER curated lane, and load-bearing for his identity:
; 1801 rides sleep, 1802 is finite at 24 lifetime awards, 1804 needs him as active patron. Bound to
; ENCHANTING specifically because binding magicka into lawful form IS his doctrine, it never
; exhausts, and raw skill gain is in his rejected-hooks contract. Id 3121 sits in the 3110-3200
; block (Syrabane 3110-3114, Xarxes 3120; MCM slider ceiling 3200).
Int Property SIGNAL_APERTURE_KEPT = 3121 AutoReadOnly       ; a completed enchantment: the design holds

Float Property DELTA_DISCIPLINED_STUDY = 1.8 Auto
Float Property DELTA_MAGIC_MILESTONE = 1.5 Auto
Float Property DELTA_SHARED_PACT_MEMORY = 1.0 Auto
Float Property DELTA_APERTURE_KEPT = 1.2 Auto

; Declared-but-unread contract constant. Corrected 2026-08-02: this is NOT waiting
; on a future wire. The Auri-El deity-pulse spine was DESCOPED by design on
; 2026-07-15 (see the note at tools/pdv_verify.mjs:6650). PDV_Substrate_AltmerAncestor
; owns the Altmer spine now and is deity-agnostic -- readback of 0715AC:Devotion.esp
; shows no deity property on it at all.
; DO NOT delete the line below, and DO NOT add a matching spine signal constant to
; this file. pdv_verify asserts this source contains the literal
; "DELTA_ANCESTOR_SPINE = 1.0" AND that it does NOT contain that signal constant's
; name -- the Breton spine check runs checkSourceLacks against this file. Writing
; that name here, even inside a comment, fails the verifier. Learned the hard way
; on 2026-08-02: an explanatory comment that spelled the name out tripped the gate.
Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DISCIPLINED_STUDY
        return DELTA_DISCIPLINED_STUDY
    elseIf signalType == SIGNAL_MAGIC_MILESTONE
        return DELTA_MAGIC_MILESTONE
    elseIf signalType == SIGNAL_SHARED_PACT_MEMORY
        return DELTA_SHARED_PACT_MEMORY
    elseIf signalType == SIGNAL_APERTURE_KEPT
        return DELTA_APERTURE_KEPT
    endIf

    return 0.0
EndFunction
