;/
    PDV_Deity_Tuwhacca.psc
    PlayerDevotion - Redguard (Yokudan) death-duty patron
    -----------------------------------------------------------------------
    OVERVIEW
    Tu'whacca, the Tricky God / soul-keeper of the Yokudan pantheon. The
    focused death-duty / ward / restoration patron for Redguard players,
    emphasized under Crown (orthodoxy) and Ash'abah (death-duty / impurity).

    DESIGN NOTES
    - Tu'whacca uses Arkay-adjacent Skyrim spaces (Hall of the Dead, tombs,
      funerary sites) only as proxy geography. ALL worship and copy say
      Tu'whacca, never Arkay. Generic Arkay shrine use never feeds this deity.
    - Death-duty / Far-Shores / Yokudan-form acts arrive as curated signals;
      this deity only scores curated signals (no raw combat / ScoreAction).
    - The Far Shores token is SUPPORT for the death-duty lane (a portable
      Tu'whacca devotional surface with no V1 private/home bonus), not a separate boon family.
    - Per-act anti-farm (once-per-day sect keys, Far Shores daily cap, undead
      site/boss limits) lives at the manager layer (PDV__ManagerQuest), not
      here, so the manager owns the single anti-farm mechanism per act.
    - Vampire-cure re-entry to the cycle routes through Tu'whacca.
    - Creed-violation loss is medium/major only (death-duty abandonment).
    -----------------------------------------------------------------------
/;

Scriptname PDV_Deity_Tuwhacca extends PDV_DeityBase

Int Property SIGNAL_DEATH_DUTY = 2401 AutoReadOnly       ; Ash'abah: unclean dead put to rest / death duty kept
Int Property SIGNAL_CROWN_FORM = 2402 AutoReadOnly       ; Crown: tomb respect / Yokudan form toward the soul-keeper
Int Property SIGNAL_FAR_SHORES_TOKEN = 2403 AutoReadOnly ; Far Shores ritual support credit
Int Property SIGNAL_VAMPIRE_REENTRY = 2404 AutoReadOnly  ; cured vampire returns to the cycle (milestone)
Int Property SIGNAL_DEATH_DUTY_ABANDONMENT = 2405 AutoReadOnly ; anti-creed (major): dead left unkept / desecrated

Float Property DELTA_DEATH_DUTY = 2.0 Auto
Float Property DELTA_CROWN_FORM = 1.5 Auto
Float Property DELTA_FAR_SHORES_TOKEN = 1.0 Auto
Float Property DELTA_VAMPIRE_REENTRY = 4.0 Auto
Float Property DELTA_DEATH_DUTY_ABANDONMENT = -3.0 Auto

Event OnInit()
    if GetDebugLevel() >= 2
        Debug.Trace("[PDV] Tu'whacca deity initialized.")
    endIf
EndEvent

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    return ScoreFromTable(eventType)
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    if signalType == SIGNAL_DEATH_DUTY
        return DELTA_DEATH_DUTY
    elseIf signalType == SIGNAL_CROWN_FORM
        return DELTA_CROWN_FORM
    elseIf signalType == SIGNAL_FAR_SHORES_TOKEN
        return DELTA_FAR_SHORES_TOKEN
    elseIf signalType == SIGNAL_VAMPIRE_REENTRY
        return DELTA_VAMPIRE_REENTRY
    elseIf signalType == SIGNAL_DEATH_DUTY_ABANDONMENT
        return DELTA_DEATH_DUTY_ABANDONMENT
    endIf

    return 0.0
EndFunction
