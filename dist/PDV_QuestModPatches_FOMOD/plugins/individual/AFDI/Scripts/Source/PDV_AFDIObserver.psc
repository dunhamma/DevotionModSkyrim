Scriptname PDV_AFDIObserver extends Quest

PDV__ManagerQuest Property PDV_Manager Auto
GlobalVariable Property AFDI_Anchor Auto

String Property AFDI_PLUGIN = "Aetherium Forge Destroys Items.esp" AutoReadOnly
Float Property POLL_INTERVAL = 15.0 AutoReadOnly
Int Property BASELINE_VERSION = 1 AutoReadOnly

Bool _formsResolved = false
GlobalVariable[] _destroyedGlobals
String[] _artifactKeys

Event OnInit()
    ResolveForms()
    PollDestroyedArtifacts()
    RegisterForUpdate(POLL_INTERVAL)
EndEvent

Event OnUpdate()
    PollDestroyedArtifacts()
EndEvent

Function ResolveForms()
    _formsResolved = false
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
            Debug.Trace("[PDV AFDI] unresolved destruction global at index " + index)
            return
        endIf
        index += 1
    endWhile
    _formsResolved = true
EndFunction

Function SetEntry(Int index, Int localFormId, String artifactKey)
    if index == 0 && AFDI_Anchor
        _destroyedGlobals[index] = AFDI_Anchor
    else
        _destroyedGlobals[index] = Game.GetFormFromFile(localFormId, AFDI_PLUGIN) as GlobalVariable
    endIf
    _artifactKeys[index] = artifactKey
EndFunction

Function PollDestroyedArtifacts()
    if !_formsResolved
        ResolveForms()
    endIf
    if !_formsResolved || !PDV_Manager
        return
    endIf

    String versionKey = "PDV.AFDI.BaselineVersion"
    Bool baselineOnly = StorageUtil.GetIntValue(None, versionKey, 0) < BASELINE_VERSION
    Int index = 0
    while index < _destroyedGlobals.Length
        GlobalVariable destroyedGlobal = _destroyedGlobals[index]
        String seenKey = "PDV.AFDI.Seen." + index
        Bool destroyed = destroyedGlobal.GetValueInt() > 0

        if baselineOnly
            if destroyed
                StorageUtil.SetIntValue(None, seenKey, 1)
            endIf
        elseIf destroyed && StorageUtil.GetIntValue(None, seenKey, 0) == 0
            ; Persist first: a downstream stack failure must not make a once-ever
            ; artifact destruction repeatable.
            StorageUtil.SetIntValue(None, seenKey, 1)
            RouteArtifactReaction(_artifactKeys[index], destroyedGlobal as Form)
        endIf
        index += 1
    endWhile

    if baselineOnly
        StorageUtil.SetIntValue(None, versionKey, BASELINE_VERSION)
        Debug.Trace("[PDV AFDI] existing-save baseline captured without retroactive awards.")
    endIf
EndFunction

Function RouteArtifactReaction(String artifactKey, Form sourceForm)
    if artifactKey == "jyggalag"
        Debug.Trace("[PDV AFDI] Jyggalag destruction observed; classify-only.")
        return
    endIf

    String ownerName = GetDaedricOwnerName(artifactKey)
    if artifactKey != "black_star" && artifactKey != "auriel_bow" && artifactKey != "auriel_shield" && artifactKey != "sithis" && artifactKey != "necromancer_amulet" && ownerName == ""
        Debug.Trace("[PDV AFDI] unknown artifact key skipped: " + artifactKey)
        return
    endIf

    PDV_Manager.BeginExternalReactionBatch()
    if artifactKey == "black_star"
        PDV_Manager.ApplyExternalReaction("Azura", "+", "C", "milestone", "destroy_profane_artifact:black_star", sourceForm)
        ApplyDestroyRejectApprovals("azura", sourceForm)
    elseIf artifactKey == "auriel_bow" || artifactKey == "auriel_shield"
        PDV_Manager.ApplyExternalReaction("Auri-El", "-", "C", "milestone", "destroy_sacred_artifact:auriel", sourceForm)
    elseIf artifactKey == "sithis"
        PDV_Manager.ApplyExternalReaction("Sithis", "-", "C", "milestone", "destroy_sacred_artifact:sithis", sourceForm)
    elseIf artifactKey == "necromancer_amulet"
        PDV_Manager.ApplyExternalReaction("Arkay", "+", "S", "small", "destroy_reject_necromancy", sourceForm)
        PDV_Manager.ApplyExternalReaction("Stendarr", "+", "S", "small", "destroy_reject_necromancy", sourceForm)
    else
        PDV_Manager.ApplyExternalReaction(ownerName, "-", "C", "milestone", "destroy_reject_daedra:" + artifactKey, sourceForm)
        ApplyDestroyRejectApprovals(artifactKey, sourceForm)
    endIf
    PDV_Manager.EndExternalReactionBatch()
    Debug.Trace("[PDV AFDI] artifact destruction routed: " + artifactKey)
EndFunction

Function ApplyDestroyRejectApprovals(String ownerKey, Form sourceForm)
    String sourceTag = "destroy_reject_daedra:" + ownerKey
    PDV_Manager.ApplyExternalReaction("Stendarr", "+", "S", "small", sourceTag, sourceForm)
    PDV_Manager.ApplyExternalReaction("Syrabane", "+", "m", "small", sourceTag, sourceForm)
EndFunction

String Function GetDaedricOwnerName(String artifactKey)
    if artifactKey == "azura"
        return "Azura"
    elseIf artifactKey == "clavicus_vile"
        return "Clavicus Vile"
    elseIf artifactKey == "hircine"
        return "Hircine"
    elseIf artifactKey == "mehrunes_dagon"
        return "Mehrunes Dagon"
    elseIf artifactKey == "meridia"
        return "Meridia"
    elseIf artifactKey == "molag_bal"
        return "Molag Bal"
    elseIf artifactKey == "vaermina"
        return "Vaermina"
    elseIf artifactKey == "boethiah"
        return "Boethiah"
    elseIf artifactKey == "hermaeus_mora"
        return "Hermaeus Mora"
    elseIf artifactKey == "malacath"
        return "Malacath"
    elseIf artifactKey == "mephala"
        return "Mephala"
    elseIf artifactKey == "namira"
        return "Namira"
    elseIf artifactKey == "peryite"
        return "Peryite"
    elseIf artifactKey == "sanguine"
        return "Sanguine"
    elseIf artifactKey == "sheogorath"
        return "Sheogorath"
    elseIf artifactKey == "nocturnal"
        return "Nocturnal"
    endIf
    return ""
EndFunction
