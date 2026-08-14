Scriptname PDV_AFDIObserver extends Quest

PDV_QuestReactionRuntime Property PDV_QuestReactionRuntimeService Auto

String Property AFDI_PLUGIN = "Aetherium Forge Destroys Items.esp" AutoReadOnly
Float Property POLL_INTERVAL = 15.0 AutoReadOnly
Float Property RESOLVE_BACKOFF_INTERVAL = 300.0 AutoReadOnly
Int Property RESOLVE_ATTEMPT_LIMIT = 4 AutoReadOnly
Int Property BASELINE_VERSION = 1 AutoReadOnly

Bool _formsResolved = false
Bool _pollRetired = false
Bool _resolveBackoffActive = false
Int _resolveAttempts = 0
Int _unseenRemaining = 0
GlobalVariable[] _destroyedGlobals
String[] _artifactKeys
Bool[] _seen

Event OnInit()
    ResolveForms()
    PollDestroyedArtifacts()
    if !_pollRetired
        RegisterForUpdate(POLL_INTERVAL)
    endIf
EndEvent

Event OnUpdate()
    PollDestroyedArtifacts()
    ; Terminal exit: there are at most 30 once-ever destructions in a playthrough.
    ; Once every slot is accounted for this observer can never do useful work again,
    ; so drop the registration instead of leaving it baked into the save forever.
    if _pollRetired
        UnregisterForUpdate()
    endIf
EndEvent

Function ResolveForms()
    _formsResolved = false
    _resolveAttempts += 1
    _destroyedGlobals = new GlobalVariable[30]
    _artifactKeys = new String[30]

    SetEntry(0, 0x000FD4, "azura")
    SetEntry(1, 0x000FD5, "black_star")
    SetEntry(2, 0x000FD6, "clavicus_vile")
    SetEntry(3, 0x000FD7, "hircine")
    SetEntry(4, 0x000FD8, "mehrunes_dagon")
    SetEntry(5, 0x000FD9, "meridia")
    SetEntry(6, 0x000FDA, "molag_bal")
    SetEntry(7, 0x000FDB, "vaermina")
    SetEntry(8, 0x000FDC, "boethiah")
    SetEntry(9, 0x000FDD, "hermaeus_mora")
    SetEntry(10, 0x000FE7, "hermaeus_mora")
    SetEntry(11, 0x000FE8, "hermaeus_mora")
    SetEntry(12, 0x000FE9, "hermaeus_mora")
    SetEntry(13, 0x000FEA, "hermaeus_mora")
    SetEntry(14, 0x000FEB, "hermaeus_mora")
    SetEntry(15, 0x000FEC, "hermaeus_mora")
    SetEntry(16, 0x000FED, "hermaeus_mora")
    SetEntry(17, 0x000093, "hermaeus_mora")
    SetEntry(18, 0x000FDE, "malacath")
    SetEntry(19, 0x000FDF, "mephala")
    SetEntry(20, 0x000FE0, "namira")
    SetEntry(21, 0x000FE1, "peryite")
    SetEntry(22, 0x000FE2, "sanguine")
    SetEntry(23, 0x000FE3, "sheogorath")
    SetEntry(24, 0x000FD3, "nocturnal")
    SetEntry(25, 0x000F56, "auriel_bow")
    SetEntry(26, 0x000F55, "auriel_shield")
    SetEntry(27, 0x0000D9, "jyggalag")
    SetEntry(28, 0x000F54, "necromancer_amulet")
    SetEntry(29, 0x000110, "sithis")

    Int index = 0
    while index < _destroyedGlobals.Length
        if !_destroyedGlobals[index]
            ; Resolution can lose a race against load order settling, so retry a few
            ; times at the normal cadence. After that the honest reading is that the
            ; source mod is absent: back the poll off hard rather than re-running 30
            ; Game.GetFormFromFile calls and a log line every POLL_INTERVAL forever.
            if !_resolveBackoffActive && _resolveAttempts >= RESOLVE_ATTEMPT_LIMIT
                _resolveBackoffActive = true
                RegisterForUpdate(RESOLVE_BACKOFF_INTERVAL)
                Debug.Trace("[PDV AFDI] unresolved destruction global at index " + index + " after " + _resolveAttempts + " attempts; is " + AFDI_PLUGIN + " installed? Backing off to " + RESOLVE_BACKOFF_INTERVAL + "s.")
            endIf
            return
        endIf
        index += 1
    endWhile

    _formsResolved = true
    if _resolveBackoffActive
        _resolveBackoffActive = false
        RegisterForUpdate(POLL_INTERVAL)
        Debug.Trace("[PDV AFDI] destruction globals resolved; poll restored to " + POLL_INTERVAL + "s.")
    endIf
    PrimeSeenCache()
EndFunction

Function SetEntry(Int index, Int localFormId, String artifactKey)
    _destroyedGlobals[index] = Game.GetFormFromFile(localFormId, AFDI_PLUGIN) as GlobalVariable
    _artifactKeys[index] = artifactKey
EndFunction

; Read the persisted once-ever state ONCE per resolve instead of once per slot per
; tick. After this the steady-state poll touches StorageUtil only when a slot has
; actually flipped, and the seen slots cost nothing at all.
Function PrimeSeenCache()
    _seen = new Bool[30]
    _unseenRemaining = 0
    Int index = 0
    while index < _seen.Length
        if StorageUtil.GetIntValue(None, "PDV.AFDI.Seen." + index, 0) != 0
            _seen[index] = true
        else
            _unseenRemaining += 1
        endIf
        index += 1
    endWhile
EndFunction

Function PollDestroyedArtifacts()
    if _pollRetired
        return
    endIf
    if !_formsResolved
        ResolveForms()
    endIf
    if !_formsResolved || !PDV_QuestReactionRuntimeService
        return
    endIf

    String versionKey = "PDV.AFDI.BaselineVersion"
    Bool baselineOnly = StorageUtil.GetIntValue(None, versionKey, 0) < BASELINE_VERSION
    Int index = 0
    while index < _destroyedGlobals.Length
        ; Skip slots already accounted for: no native global read, no key string
        ; built, no StorageUtil hit. Only live slots cost anything.
        if !_seen[index] && _destroyedGlobals[index].GetValueInt() > 0
            String seenKey = "PDV.AFDI.Seen." + index
            ; Persist first: a downstream stack failure must not make a once-ever
            ; artifact destruction repeatable.
            StorageUtil.SetIntValue(None, seenKey, 1)
            _seen[index] = true
            _unseenRemaining -= 1
            if !baselineOnly
                RouteArtifactReaction(index, _artifactKeys[index], _destroyedGlobals[index] as Form)
            endIf
        endIf
        index += 1
    endWhile

    if baselineOnly
        StorageUtil.SetIntValue(None, versionKey, BASELINE_VERSION)
        Debug.Trace("[PDV AFDI] existing-save baseline captured without retroactive awards.")
    endIf

    if _unseenRemaining <= 0
        _pollRetired = true
        Debug.Trace("[PDV AFDI] all 30 artifact slots accounted for; observer polling retired.")
    endIf
EndFunction

Function RouteArtifactReaction(Int artifactIndex, String artifactKey, Form sourceForm)
    if artifactKey == "jyggalag"
        Debug.Trace("[PDV AFDI] Jyggalag destruction observed; classify-only.")
        return
    endIf

    String eventId = GetArtifactEventId(artifactIndex, artifactKey)
    if eventId == ""
        Debug.Trace("[PDV AFDI] unknown artifact slot skipped: " + artifactIndex + " " + artifactKey)
        return
    endIf
    if PDV_QuestReactionRuntimeService.SubmitSemanticEvent("afdi", eventId, sourceForm)
        Debug.Trace("[PDV AFDI] artifact destruction submitted: " + eventId)
    else
        Debug.Trace("[PDV AFDI] artifact destruction rejected: " + eventId)
    endIf
EndFunction

String Function GetArtifactEventId(Int artifactIndex, String artifactKey)
    if artifactIndex < 0 || artifactIndex > 29 || artifactKey == "" || artifactIndex == 27
        return ""
    endIf
    if artifactIndex < 10
        return "artifact_destroyed.0" + artifactIndex + "." + artifactKey
    endIf
    return "artifact_destroyed." + artifactIndex + "." + artifactKey
EndFunction
