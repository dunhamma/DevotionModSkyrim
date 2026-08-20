Scriptname PDV_RecognitionRuntime extends Quest

; Deep module for opt-in NPC religious recognition. Owns event arbitration,
; cached recognition forms, faction reactions, identity resolution, and surfaces.
PDV__ManagerQuest Property Manager Auto

; Devotion-owned forms never change at runtime, so resolve them once per saved
; module instance rather than repeating lookups during a 57-faction reset.
Faction _recognitionPlayerFaction = None
Faction[] _recognitionCohortFactions
Bool _recognitionFormsResolved = False

Int Property RECOGNITION_REACTION_NEUTRAL = 0 AutoReadOnly
Int Property RECOGNITION_REACTION_ENEMY = 1 AutoReadOnly
Int Property RECOGNITION_REACTION_ALLY = 2 AutoReadOnly
Int Property RECOGNITION_REACTION_FRIEND = 3 AutoReadOnly
Int Property RECOGNITION_IDENTITY_COUNT = 57 AutoReadOnly

; NPC religious recognition defaults OFF (missing key -> disabled). The feature is
; unadvertised in 1.5.0 and opt-in from the MCM while its in-game reactions are
; validated further; an explicit MCM toggle still persists via the same keys.
Bool Function NpcReligiousRecognitionEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Recognition.Disabled", 1) != 1
EndFunction

Bool Function NpcHostileRecognitionEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Recognition.HostilesDisabled", 1) != 1
EndFunction

Function SetNpcReligiousRecognitionEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Recognition.Disabled", PDV_DevotionRules.BoolToInt(!enabled))
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
EndFunction

Function SetNpcHostileRecognitionEnabled(Bool enabled)
    StorageUtil.SetIntValue(None, "PDV.Recognition.HostilesDisabled", PDV_DevotionRules.BoolToInt(!enabled))
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
EndFunction

String Function GetNpcRecognitionStatusLine()
    if !NpcReligiousRecognitionEnabled()
        return "Off"
    endIf
    String owner = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    if owner != ""
        return "Managed by " + owner
    endIf
    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    if identityIndex < 0 || band <= Manager.LedgerRuntime.TIER_NONE
        return "On - no public standing"
    endIf
    return GetRecognitionIdentityDisplayName(identityIndex) + " - " + Manager.GetPublicTierBand(band) + " (" + GetNpcRecognitionRelationLabel(band) + ")"
EndFunction

String Function GetNpcRecognitionRelationLabel(Int band)
    if band >= Manager.LedgerRuntime.TIER_CHAMPION
        return "ally"
    elseIf band >= Manager.LedgerRuntime.TIER_DEVOTED
        return "friend"
    endIf
    return "neutral"
EndFunction

String Function GetNpcRecognitionAdvisory(Int identityIndex, Int band, Bool recognitionEnabled, String ownerName)
    if !recognitionEnabled
        return "Public religious recognition is off."
    elseIf ownerName != ""
        return "Religious recognition is managed by " + ownerName + "."
    elseIf identityIndex < 0
        return "No public religious identity is active."
    elseIf band >= Manager.LedgerRuntime.TIER_CHAMPION
        return "Adherents may regard you as an ally."
    elseIf band >= Manager.LedgerRuntime.TIER_DEVOTED
        return "Adherents may regard you as a friend."
    endIf
    return "Adherents remain neutral until your standing is Faithful."
EndFunction

String Function GetNpcRecognitionPanelJson()
    Bool recognitionEnabled = NpcReligiousRecognitionEnabled()
    String ownerName = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    String identityName = GetRecognitionIdentityDisplayName(identityIndex)
    String bandName = Manager.GetPublicTierBand(band)
    String statusText = GetNpcRecognitionStatusLine()
    String advisory = GetNpcRecognitionAdvisory(identityIndex, band, recognitionEnabled, ownerName)
    String j = "{\"enabled\":" + PDV_DevotionRules.BoolToJson(recognitionEnabled)
    j = j + ",\"managed\":" + PDV_DevotionRules.BoolToJson(ownerName != "")
    j = j + ",\"status\":\"" + PDV_DevotionRules.JsonSafeString(statusText) + "\""
    j = j + ",\"identity\":\"" + PDV_DevotionRules.JsonSafeString(identityName) + "\""
    j = j + ",\"band\":\"" + PDV_DevotionRules.JsonSafeString(bandName) + "\""
    j = j + ",\"advisory\":\"" + PDV_DevotionRules.JsonSafeString(advisory) + "\"}"
    return j
EndFunction

Function EnsureRecognitionModEvents()
    UnregisterForModEvent("PDV.Recognition.Claim")
    UnregisterForModEvent("PDV.Recognition.Release")
    RegisterForModEvent("PDV.Recognition.Claim", "OnRecognitionClaim")
    RegisterForModEvent("PDV.Recognition.Release", "OnRecognitionRelease")
EndFunction

Event OnRecognitionClaim(String eventName, String strArg, Float numArg, Form sender)
    if strArg == ""
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Recognition.Owner", strArg)
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
    Manager.Trace(1, "NPC religious recognition claimed by " + strArg + ".")
EndEvent

Event OnRecognitionRelease(String eventName, String strArg, Float numArg, Form sender)
    String owner = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    if owner == "" || !RecognitionOwnersMatch(owner, strArg)
        return
    endIf
    StorageUtil.SetStringValue(None, "PDV.Recognition.Owner", "")
    InvalidateNpcReligiousRecognition()
    SyncNpcReligiousRecognition()
    Manager.Trace(1, "NPC religious recognition released by " + strArg + ".")
EndEvent

Bool Function RecognitionOwnersMatch(String firstOwner, String secondOwner)
    Int ownerLength = StringUtil.GetLength(firstOwner)
    if ownerLength != StringUtil.GetLength(secondOwner)
        return false
    endIf
    Int index = 0
    while index < ownerLength
        Int firstOrd = StringUtil.AsOrd(StringUtil.GetNthChar(firstOwner, index))
        Int secondOrd = StringUtil.AsOrd(StringUtil.GetNthChar(secondOwner, index))
        if firstOrd >= 65 && firstOrd <= 90
            firstOrd += 32
        endIf
        if secondOrd >= 65 && secondOrd <= 90
            secondOrd += 32
        endIf
        if firstOrd != secondOrd
            return false
        endIf
        index += 1
    endWhile
    return true
EndFunction

Function InvalidateNpcReligiousRecognition()
    StorageUtil.SetIntValue(None, "PDV.Recognition.LastSignature", -9999)
EndFunction

Faction Function GetRecognitionPlayerFaction()
    EnsureRecognitionForms()
    return _recognitionPlayerFaction
EndFunction

Faction Function GetRecognitionCohortFaction(Int identityIndex)
    if identityIndex < 0 || identityIndex >= RECOGNITION_IDENTITY_COUNT
        return None
    endIf
    EnsureRecognitionForms()
    return _recognitionCohortFactions[identityIndex]
EndFunction

Function EnsureRecognitionForms()
    if _recognitionFormsResolved && _recognitionPlayerFaction && _recognitionCohortFactions.Length == RECOGNITION_IDENTITY_COUNT
        return
    endIf
    if _recognitionCohortFactions.Length != RECOGNITION_IDENTITY_COUNT
        _recognitionCohortFactions = new Faction[57]
    endIf
    _recognitionPlayerFaction = Game.GetFormFromFile(0x00071756, "Devotion.esp") as Faction
    Int identityIndex = 0
    Bool allResolved = _recognitionPlayerFaction != None
    while identityIndex < RECOGNITION_IDENTITY_COUNT
        if !_recognitionCohortFactions[identityIndex]
            _recognitionCohortFactions[identityIndex] = Game.GetFormFromFile(0x00071757 + identityIndex, "Devotion.esp") as Faction
        endIf
        if !_recognitionCohortFactions[identityIndex]
            allResolved = False
        endIf
        identityIndex += 1
    endWhile
    _recognitionFormsResolved = allResolved
EndFunction

Function SetRecognitionPair(Faction cohort, Faction playerFaction, Int reaction)
    if !cohort || !playerFaction
        return
    endIf
    cohort.SetReaction(playerFaction, reaction)
    playerFaction.SetReaction(cohort, reaction)
EndFunction

Function ResetNpcRecognitionRelations(Faction playerFaction)
    Int i = 0
    while i < RECOGNITION_IDENTITY_COUNT
        SetRecognitionPair(GetRecognitionCohortFaction(i), playerFaction, RECOGNITION_REACTION_NEUTRAL)
        i += 1
    endWhile
EndFunction

Function SyncNpcReligiousRecognition()
    Faction playerFaction = GetRecognitionPlayerFaction()
    Actor playerRef = Game.GetPlayer()
    if !playerFaction || !playerRef
        return
    endIf
    if !playerRef.IsInFaction(playerFaction)
        playerRef.AddToFaction(playerFaction)
    endIf

    Int identityIndex = ResolveNpcRecognitionIdentity()
    Int band = ResolveNpcRecognitionBand(identityIndex)
    String ownerName = StorageUtil.GetStringValue(None, "PDV.Recognition.Owner")
    Bool owned = ownerName != ""
    Bool recognitionEnabled = NpcReligiousRecognitionEnabled()
    Bool hostileRecognitionEnabled = NpcHostileRecognitionEnabled()
    Int signature = identityIndex * 100 + band * 10 + PDV_DevotionRules.BoolToInt(recognitionEnabled) + (PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) * 2) + (PDV_DevotionRules.BoolToInt(owned) * 4)
    if StorageUtil.GetIntValue(None, "PDV.Recognition.LastSignature", -9999) == signature
        return
    endIf

    ResetNpcRecognitionRelations(playerFaction)
    if recognitionEnabled && !owned && identityIndex >= 0
        if band >= Manager.LedgerRuntime.TIER_CHAMPION
            SetRecognitionPair(GetRecognitionCohortFaction(identityIndex), playerFaction, RECOGNITION_REACTION_ALLY)
            if hostileRecognitionEnabled
                ApplyNpcRecognitionHardRivals(identityIndex, playerFaction)
            endIf
        elseIf band >= Manager.LedgerRuntime.TIER_DEVOTED
            SetRecognitionPair(GetRecognitionCohortFaction(identityIndex), playerFaction, RECOGNITION_REACTION_FRIEND)
        endIf
    endIf

    StorageUtil.SetIntValue(None, "PDV.Recognition.LastSignature", signature)
    EmitNpcRecognitionState(identityIndex, band, hostileRecognitionEnabled, ownerName)
    SurfaceNpcRecognitionTransition(identityIndex, band, recognitionEnabled, hostileRecognitionEnabled, ownerName)
    Manager.RequestPanelRefresh()
EndFunction

Function SurfaceNpcRecognitionTransition(Int identityIndex, Int band, Bool recognitionEnabled, Bool hostileRecognitionEnabled, String ownerName)
    Bool owned = ownerName != ""
    Int presentationSignature = identityIndex * 1000 + band * 100 + PDV_DevotionRules.BoolToInt(recognitionEnabled) * 10 + PDV_DevotionRules.BoolToInt(owned) * 20 + PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) * 40
    if StorageUtil.GetIntValue(None, "PDV.Recognition.PresentationInitialized") != 1
        StorageUtil.SetIntValue(None, "PDV.Recognition.PresentationInitialized", 1)
        StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature", presentationSignature)
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Recognition.LastPresentedSignature", -9999) == presentationSignature
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Recognition.LastPresentedSignature", presentationSignature)
    ; Public recognition ships OFF. When neither friendly nor hostile recognition is enabled there
    ; is nothing to announce, so suppress the transition toast/journal -- a disabled feature must not
    ; nag on every patron/tier change. The signature above is still recorded, so the first change
    ; AFTER the owner enables recognition still surfaces cleanly.
    if !recognitionEnabled && !hostileRecognitionEnabled
        return
    endIf
    String identityName = GetRecognitionIdentityDisplayName(identityIndex)
    String bandName = Manager.GetPublicTierBand(band)
    String bodyText = GetNpcRecognitionAdvisory(identityIndex, band, recognitionEnabled, ownerName)
    if recognitionEnabled && ownerName == "" && identityIndex >= 0
        bodyText = identityName + " - " + bandName + ". " + bodyText
        if hostileRecognitionEnabled && band >= Manager.LedgerRuntime.TIER_CHAMPION
            bodyText = bodyText + " Explicit rival adherents may regard you as an enemy."
        endIf
    endIf
    Manager.SendPrismaToast("journal", "neutral", "Public recognition changed", bodyText)
    Manager.AppendBookOfDaysEntry(bodyText, Utility.GetCurrentGameTime() as Int, "reorientation", "journal", False, 1, "Public recognition changed")
EndFunction

Function ApplyNpcRecognitionHardRivals(Int identityIndex, Faction playerFaction)
    ; Explicit hard rivalries only. Enemy is a disposition relation, not an
    ; aggression package, so this never creates attack-on-sight behaviour.
    if identityIndex == 35 ; Molag Bal
        SetRecognitionPair(GetRecognitionCohortFaction(33), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 33 ; Meridia
        SetRecognitionPair(GetRecognitionCohortFaction(35), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 20 ; Malacath
        SetRecognitionPair(GetRecognitionCohortFaction(21), playerFaction, RECOGNITION_REACTION_ENEMY)
    elseIf identityIndex == 21 ; Trinimac
        SetRecognitionPair(GetRecognitionCohortFaction(20), playerFaction, RECOGNITION_REACTION_ENEMY)
    endIf

    if Manager.DaedricRuntime.GetActiveDaedricPactPath()
        SetRecognitionPair(GetRecognitionCohortFaction(13), playerFaction, RECOGNITION_REACTION_ENEMY)
    endIf
EndFunction

Function EmitNpcRecognitionState(Int identityIndex, Int band, Bool hostileRecognitionEnabled, String ownerName)
    Int handle = ModEvent.Create("PDV.Recognition.State")
    if handle == 0
        return
    endIf
    ModEvent.PushString(handle, GetRecognitionIdentityKey(identityIndex))
    ModEvent.PushString(handle, Manager.GetPublicTierBand(band))
    ModEvent.PushFloat(handle, PDV_DevotionRules.BoolToInt(hostileRecognitionEnabled) as Float)
    ModEvent.PushString(handle, ownerName)
    ModEvent.Send(handle)
EndFunction

Int Function ResolveNpcRecognitionIdentity()
    PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return GetRecognitionDaedricIndex(activePact.DeityName)
    endIf
    if Manager.GetActiveDeity()
        return GetRecognitionFocusedIndex(Manager.GetActiveDeity())
    endIf
    if Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD
        return GetRecognitionBroadIndex(Manager.GetPlayerOriginRaceIndex())
    endIf
    return -1
EndFunction

Int Function ResolveNpcRecognitionBand(Int identityIndex)
    if identityIndex < 0
        return Manager.LedgerRuntime.TIER_NONE
    endIf
    PDV_DaedricPathBase activePact = Manager.DaedricRuntime.GetActiveDaedricPactPath()
    if activePact
        return activePact.GetStoredTier()
    endIf
    if Manager.GetActiveDeity()
        return Manager.LedgerRuntime.GetTier(Manager.GetActiveDeity())
    endIf
    return GetRecognitionBroadTier(Manager.GetPlayerOriginRaceIndex())
EndFunction

Int Function GetRecognitionFocusedIndex(PDV_DeityBase deity)
    if deity == Manager.PDV_Talos
        return 0
    elseIf deity == Manager.PDV_AuriEl
        return 1
    elseIf deity == Manager.PDV_Yffre
        return 2
    elseIf deity == Manager.LedgerRuntime.PDV_Zen
        return 3
    elseIf deity == Manager.PDV_BaanDar
        return 4
    elseIf deity == Manager.PDV_Kyne
        return 5
    elseIf deity == Manager.PDV_Azura
        return 6
    elseIf deity == Manager.PDV_Khenarthi
        return 7
    elseIf deity == Manager.PDV_Rajhin
        return 8
    elseIf deity == Manager.PDV_Alkosh
        return 9
    elseIf deity == Manager.LedgerRuntime.PDV_Akatosh
        return 10
    elseIf deity == Manager.LedgerRuntime.PDV_Mara
        return 11
    elseIf deity == Manager.LedgerRuntime.PDV_Arkay
        return 12
    elseIf deity == Manager.LedgerRuntime.PDV_Stendarr
        return 13
    elseIf deity == Manager.LedgerRuntime.PDV_Zenithar
        return 14
    elseIf deity == Manager.LedgerRuntime.PDV_Dibella
        return 15
    elseIf deity == Manager.LedgerRuntime.PDV_Julianos
        return 16
    elseIf deity == Manager.LedgerRuntime.PDV_Kynareth
        return 17
    elseIf deity == Manager.PDV_Hist
        return 18
    elseIf deity == Manager.PDV_Sithis
        return 19
    elseIf deity == Manager.PDV_Malacath
        return 20
    elseIf deity == Manager.PDV_Trinimac
        return 21
    elseIf deity == Manager.PDV_Boethiah
        return 22
    elseIf deity == Manager.PDV_Mephala
        return 23
    elseIf deity == Manager.PDV_Magnus
        return 24
    elseIf deity == Manager.PDV_Xarxes
        return 25
    elseIf deity == Manager.PDV_Tuwhacca
        return 26
    elseIf deity == Manager.PDV_HoonDing
        return 27
    elseIf deity == Manager.PDV_Leki
        return 28
    elseIf deity == Manager.PDV_Shor
        return 29
    elseIf deity == Manager.PDV_Tsun
        return 30
    elseIf deity == Manager.PDV_Stuhn
        return 31
    elseIf deity == Manager.PDV_Syrabane
        return 32
    endIf
    return -1
EndFunction

Int Function GetRecognitionDaedricIndex(String deityName)
    if deityName == "Azura" || deityName == "Azurah"
        return 6
    elseIf deityName == "Malacath"
        return 20
    elseIf deityName == "Boethiah"
        return 22
    elseIf deityName == "Mephala"
        return 23
    elseIf deityName == "Meridia"
        return 33
    elseIf deityName == "Hircine"
        return 34
    elseIf deityName == "Molag Bal" || deityName == "Molag"
        return 35
    elseIf deityName == "Nocturnal"
        return 36
    elseIf deityName == "Hermaeus Mora" || deityName == "Mora"
        return 37
    elseIf deityName == "Mehrunes Dagon" || deityName == "Dagon"
        return 38
    elseIf deityName == "Sheogorath" || deityName == "Sheo"
        return 39
    elseIf deityName == "Namira"
        return 40
    elseIf deityName == "Sanguine"
        return 41
    elseIf deityName == "Clavicus Vile" || deityName == "Vile"
        return 42
    elseIf deityName == "Peryite"
        return 43
    elseIf deityName == "Vaermina"
        return 44
    endIf
    return -1
EndFunction

Int Function GetRecognitionBroadIndex(Int origin)
    if origin == Manager.ORIGIN_NORD
        if Manager.OriginRuntime.GetNordPantheonBaselineState() == Manager.NORD_BASELINE_NINE_DIVINES
            return 46
        endIf
        return 45
    elseIf origin == Manager.ORIGIN_IMPERIAL
        return 47
    elseIf origin == Manager.ORIGIN_BRETON
        if Manager.OriginRuntime.GetBretonTraditionValue() == Manager.BRETON_TRADITION_GREEN_WAY
            return 49
        endIf
        return 48
    elseIf origin == Manager.ORIGIN_ALTMER
        return 50
    elseIf origin == Manager.ORIGIN_BOSMER
        return 51
    elseIf origin == Manager.ORIGIN_DUNMER
        return 52
    elseIf origin == Manager.ORIGIN_KHAJIIT
        return 53
    elseIf origin == Manager.ORIGIN_ARGONIAN
        return 54
    elseIf origin == Manager.ORIGIN_ORC
        return 55
    elseIf origin == Manager.ORIGIN_REDGUARD
        return 56
    endIf
    return -1
EndFunction

Int Function GetRecognitionBroadTier(Int origin)
    Int tierValue = Manager.OriginRuntime.GetBroadLaneTierForOrigin(origin)
    if origin == Manager.ORIGIN_IMPERIAL && Manager.PDV_ImperialAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_ImperialAncestorSubstrate.GetSubstrateTier())
    elseIf origin == Manager.ORIGIN_BRETON
        tierValue = RecognitionMaxInt(tierValue, Manager.OriginRuntime.GetBretonPracticeTier(Manager.OriginRuntime.GetBretonTraditionValue()))
    elseIf origin == Manager.ORIGIN_ALTMER && Manager.PDV_AltmerAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_AltmerAncestorSubstrate.GetSubstrateTier())
    elseIf origin == Manager.ORIGIN_NORD && Manager.PDV_NordAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_NordAncestorSubstrate.GetSubstrateTier())
    elseIf origin == Manager.ORIGIN_DUNMER && Manager.PDV_DunmerAncestorSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_DunmerAncestorSubstrate.GetSubstrateTier())
    elseIf origin == Manager.ORIGIN_KHAJIIT && Manager.PDV_KhajiitLunarSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_KhajiitLunarSubstrate.GetSubstrateTier())
    elseIf origin == Manager.ORIGIN_ARGONIAN && Manager.PDV_ArgonianHistSubstrate
        tierValue = RecognitionMaxInt(tierValue, Manager.PDV_ArgonianHistSubstrate.GetSubstrateTier())
    endIf
    return tierValue
EndFunction

Int Function RecognitionMaxInt(Int firstValue, Int secondValue)
    if secondValue > firstValue
        return secondValue
    endIf
    return firstValue
EndFunction

String Function GetRecognitionIdentityKey(Int identityIndex)
    if identityIndex < 0
        return "None"
    endIf
    String[] keys = new String[57]
    keys[0] = "Talos"
    keys[1] = "AuriEl"
    keys[2] = "Yffre"
    keys[3] = "Zen"
    keys[4] = "BaanDar"
    keys[5] = "Kyne"
    keys[6] = "Azura"
    keys[7] = "Khenarthi"
    keys[8] = "Rajhin"
    keys[9] = "Alkosh"
    keys[10] = "Akatosh"
    keys[11] = "Mara"
    keys[12] = "Arkay"
    keys[13] = "Stendarr"
    keys[14] = "Zenithar"
    keys[15] = "Dibella"
    keys[16] = "Julianos"
    keys[17] = "Kynareth"
    keys[18] = "Hist"
    keys[19] = "Sithis"
    keys[20] = "Malacath"
    keys[21] = "Trinimac"
    keys[22] = "Boethiah"
    keys[23] = "Mephala"
    keys[24] = "Magnus"
    keys[25] = "Xarxes"
    keys[26] = "Tuwhacca"
    keys[27] = "HoonDing"
    keys[28] = "Leki"
    keys[29] = "Shor"
    keys[30] = "Tsun"
    keys[31] = "Stuhn"
    keys[32] = "Syrabane"
    keys[33] = "Meridia"
    keys[34] = "Hircine"
    keys[35] = "MolagBal"
    keys[36] = "Nocturnal"
    keys[37] = "HermaeusMora"
    keys[38] = "MehrunesDagon"
    keys[39] = "Sheogorath"
    keys[40] = "Namira"
    keys[41] = "Sanguine"
    keys[42] = "ClavicusVile"
    keys[43] = "Peryite"
    keys[44] = "Vaermina"
    keys[45] = "NordOldWays"
    keys[46] = "NordNineDivines"
    keys[47] = "ImperialDivines"
    keys[48] = "BretonEightDivines"
    keys[49] = "BretonOldGods"
    keys[50] = "AltmerOrthodox"
    keys[51] = "BosmerGreenPact"
    keys[52] = "DunmerReclamations"
    keys[53] = "KhajiitLunarLattice"
    keys[54] = "ArgonianHistPeople"
    keys[55] = "OrcCode"
    keys[56] = "RedguardAncestorSpine"
    return keys[identityIndex]
EndFunction

String Function GetRecognitionIdentityDisplayName(Int identityIndex)
    if identityIndex < 0
        return "None"
    elseIf identityIndex == 1
        return "Auri-El"
    elseIf identityIndex == 2
        return "Y'ffre"
    elseIf identityIndex == 3
        return "Z'en"
    elseIf identityIndex == 4
        return "Baan Dar"
    elseIf identityIndex == 27
        return "HoonDing"
    elseIf identityIndex == 35
        return "Molag Bal"
    elseIf identityIndex == 37
        return "Hermaeus Mora"
    elseIf identityIndex == 38
        return "Mehrunes Dagon"
    elseIf identityIndex == 42
        return "Clavicus Vile"
    elseIf identityIndex == 45
        return "Nord Old Ways"
    elseIf identityIndex == 46
        return "Nord Nine Divines"
    elseIf identityIndex == 47
        return "Imperial Divines"
    elseIf identityIndex == 48
        return "Breton Eight Divines"
    elseIf identityIndex == 49
        return "Breton Old Gods"
    elseIf identityIndex == 50
        return "Altmer Orthodoxy"
    elseIf identityIndex == 51
        return "Bosmer Green Pact"
    elseIf identityIndex == 52
        return "Dunmer Reclamations"
    elseIf identityIndex == 53
        return "Khajiit Lunar Lattice"
    elseIf identityIndex == 54
        return "Argonian Hist and People"
    elseIf identityIndex == 55
        return "Orc Code"
    elseIf identityIndex == 56
        return "Redguard Ancestor Spine"
    endIf
    return GetRecognitionIdentityKey(identityIndex)
EndFunction
