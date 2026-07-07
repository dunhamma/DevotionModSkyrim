;/ 
    PDV_Origin.psc
    PlayerDevotion - origin bootstrap helper
    -----------------------------------------------------------------------
    OVERVIEW
    One-shot utility quest script that detects the player's race, writes
    PDV_GLO_OriginRace, and seeds the current proof-slice deity ledgers.

    DESIGN NOTES
    - This script is called by PDV__MainQuest during bootstrap.
    - The current proof slice seeds a small generic script-constant table:
      Kyne, Talos, and Auri-El.
    - No patron is auto-selected. Origin establishes starting relationship,
      not active commitment.
    - The origin global should default to -1 in CK so repeat runs can bail
      out safely after the first initialization.
    -----------------------------------------------------------------------
/;

Scriptname PDV_Origin extends Quest

GlobalVariable Property PDV_GLO_OriginRace Auto
PDV__ManagerQuest Property PDV_Manager Auto
PDV_DeityBase Property PDV_Kyne Auto
PDV_DeityBase Property PDV_Talos Auto
PDV_DeityBase Property PDV_AuriEl Auto
Actor Property PlayerRef Auto

Race Property NordRace Auto
Race Property ImperialRace Auto
Race Property BretonRace Auto
Race Property HighElfRace Auto
Race Property WoodElfRace Auto
Race Property DarkElfRace Auto
Race Property KhajiitRace Auto
Race Property ArgonianRace Auto
Race Property OrcRace Auto
Race Property RedguardRace Auto

GlobalVariable Property PDV_GLO_DebugLevel Auto

Int Property RACE_UNKNOWN = -1 AutoReadOnly
Int Property RACE_NORD = 0 AutoReadOnly
Int Property RACE_IMPERIAL = 1 AutoReadOnly
Int Property RACE_BRETON = 2 AutoReadOnly
Int Property RACE_ALTMER = 3 AutoReadOnly
Int Property RACE_BOSMER = 4 AutoReadOnly
Int Property RACE_DUNMER = 5 AutoReadOnly
Int Property RACE_KHAJIIT = 6 AutoReadOnly
Int Property RACE_ARGONIAN = 7 AutoReadOnly
Int Property RACE_ORSIMER = 8 AutoReadOnly
Int Property RACE_REDGUARD = 9 AutoReadOnly

Float Property KYNE_START_PIETY_NORD = 10.0 Auto
Float Property KYNE_START_PIETY_OTHER = 0.0 Auto
Float Property TALOS_START_PIETY_NORD = 10.0 Auto
Float Property TALOS_START_PIETY_OTHER = 0.0 Auto
Float Property AURIEL_START_PIETY_ALTMER = 10.0 Auto
Float Property AURIEL_START_PIETY_OTHER = 0.0 Auto

String Property NORD_PROVISIONAL_KEY = "PDV.OriginNordProvisional" AutoReadOnly
Int Property QASMOKE_CELL_FORM_ID = 0x00032AE7 AutoReadOnly

; Custom-race compatibility layer (resolves modded/custom races to a vanilla
; profile so all downstream stance/UI/seeding logic works unchanged). See
; references/vanilla-gameplay/compatibility/PDV_CompatInvestigation_Findings.md.
String Property RACEMAP_FILE = "PlayerDevotion/PDV_RaceMap" AutoReadOnly
String Property TEMPORARY_RACEMAP_FILE = "PlayerDevotion/PDV_TemporaryRaceMap" AutoReadOnly
String Property RACECOMPAT_PLUGIN = "RaceCompatibility.esm" AutoReadOnly

Function InitializeOrigin()
    if !PDV_GLO_OriginRace
        Trace(1, "InitializeOrigin skipped: PDV_GLO_OriginRace not assigned.")
        return
    endIf

    Actor playerActor = GetPlayerActor()
    if PDV_GLO_OriginRace.GetValueInt() >= 0
        if playerActor && ShouldRetryOriginCapture()
            Trace(1, "InitializeOrigin retrying: prior result was a custom-race fallback or a manual reset was requested.")
        else
            Trace(2, "InitializeOrigin skipped: origin already set to " + PDV_GLO_OriginRace.GetValueInt())
            return
        endIf
    elseIf !playerActor
        Trace(1, "InitializeOrigin skipped: player unavailable.")
        return
    endIf

    Int raceIndex = DetectPlayerOriginRaceIndex(playerActor)
    if raceIndex < 0
        Trace(1, "InitializeOrigin deferred: player race is currently a temporary transformation race.")
        return
    endIf

    if ShouldDeferProvisionalNordCapture(raceIndex, playerActor)
        return
    endIf

    PDV_GLO_OriginRace.SetValue(raceIndex as Float)
    StorageUtil.SetIntValue(None, "PDV.Origin.ForceRedetect", 0)
    ClearProvisionalNordCapture()
    Trace(1, "Origin race set to " + raceIndex)

    SeedProofSliceDeities(raceIndex)
    EnsureOriginInventoryTokens()
EndFunction

Bool Function ShouldRetryOriginCapture()
    if StorageUtil.GetIntValue(None, "PDV.Origin.ForceRedetect", 0) == 1
        return true
    endIf

    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback", 0) == 1
        return true
    endIf

    return false
EndFunction

Function EnsureOriginInventoryTokens()
    if !PDV_Manager
        Trace(1, "Origin inventory token reconciliation skipped: PDV_Manager not assigned.")
        return
    endIf

    PDV_Manager.EnsureDunmerAncestralUrn()
    PDV_Manager.EnsureArgonianHistSapToken()
EndFunction

Bool Function ShouldDeferProvisionalNordCapture(Int raceIndex, Actor playerActor)
    if raceIndex != RACE_NORD
        return false
    endIf

    if StorageUtil.GetIntValue(None, NORD_PROVISIONAL_KEY) == 1
        if IsQASmokeCell(playerActor)
            Trace(1, "InitializeOrigin deferred: provisional Nord capture is in QASmoke.")
            return true
        endIf
        return false
    endIf

    StorageUtil.SetIntValue(None, NORD_PROVISIONAL_KEY, 1)
    Trace(1, "InitializeOrigin deferred: first Nord capture treated as provisional.")
    return true
EndFunction

Bool Function IsQASmokeCell(Actor playerActor)
    if !playerActor
        return false
    endIf

    Cell parentCell = playerActor.GetParentCell()
    if !parentCell
        return false
    endIf

    return parentCell.GetFormID() == QASMOKE_CELL_FORM_ID
EndFunction

Function ClearProvisionalNordCapture()
    if StorageUtil.GetIntValue(None, NORD_PROVISIONAL_KEY) == 0
        return
    endIf

    StorageUtil.SetIntValue(None, NORD_PROVISIONAL_KEY, 0)
EndFunction

Int Function DetectPlayerOriginRaceIndex(Actor playerActor)
    if !playerActor
        return RACE_UNKNOWN
    endIf

    Race currentRace = playerActor.GetRace()
    Int raceIndex = DetectRaceIndex(currentRace)
    if raceIndex >= 0
        return raceIndex
    endIf

    ActorBase baseRecord = playerActor.GetActorBase()
    if baseRecord
        Race baseRace = baseRecord.GetRace()
        raceIndex = DetectRaceIndex(baseRace)
        if raceIndex >= 0
            return raceIndex
        endIf
    endIf

    if IsTemporaryTransformationRace(currentRace)
        return RACE_UNKNOWN
    endIf

    Int resolvedCustomIndex = ResolveCustomRaceIndex(currentRace)
    if resolvedCustomIndex >= 0
        RecordCustomRaceResolved(resolvedCustomIndex)
        return resolvedCustomIndex
    endIf

    RecordCustomRaceFallback()
    Trace(1, "DetectPlayerOriginRaceIndex fallback: unsupported race, defaulting to Imperial.")
    return RACE_IMPERIAL
EndFunction

Int Function DetectRaceIndex(Race playerRace)
    if !playerRace
        return RACE_UNKNOWN
    endIf

    if (NordRace && playerRace == NordRace) || MatchesRaceForm(playerRace, 0x00088794, "Skyrim.esm")
        return RACE_NORD
    elseIf (ImperialRace && playerRace == ImperialRace) || MatchesRaceForm(playerRace, 0x00088844, "Skyrim.esm")
        return RACE_IMPERIAL
    elseIf (BretonRace && playerRace == BretonRace) || MatchesRaceForm(playerRace, 0x0008883C, "Skyrim.esm")
        return RACE_BRETON
    elseIf (HighElfRace && playerRace == HighElfRace) || MatchesRaceForm(playerRace, 0x00088840, "Skyrim.esm")
        return RACE_ALTMER
    elseIf (WoodElfRace && playerRace == WoodElfRace) || MatchesRaceForm(playerRace, 0x00088884, "Skyrim.esm")
        return RACE_BOSMER
    elseIf (DarkElfRace && playerRace == DarkElfRace) || MatchesRaceForm(playerRace, 0x0008883D, "Skyrim.esm")
        return RACE_DUNMER
    elseIf (KhajiitRace && playerRace == KhajiitRace) || MatchesRaceForm(playerRace, 0x00088845, "Skyrim.esm")
        return RACE_KHAJIIT
    elseIf (ArgonianRace && playerRace == ArgonianRace) || MatchesRaceForm(playerRace, 0x0008883A, "Skyrim.esm")
        return RACE_ARGONIAN
    elseIf (OrcRace && playerRace == OrcRace) || MatchesRaceForm(playerRace, 0x000A82B9, "Skyrim.esm")
        return RACE_ORSIMER
    elseIf (RedguardRace && playerRace == RedguardRace) || MatchesRaceForm(playerRace, 0x00088846, "Skyrim.esm")
        return RACE_REDGUARD
    endIf

    return RACE_UNKNOWN
EndFunction

Bool Function IsTemporaryTransformationRace(Race playerRace)
    if !playerRace
        return false
    endIf

    if MatchesRaceForm(playerRace, 0x000CDD84, "Skyrim.esm")
        return true
    elseIf MatchesRaceForm(playerRace, 0x0000283A, "Dawnguard.esm")
        return true
    elseIf IsCustomTemporaryRace(playerRace)
        return true
    endIf

    return false
EndFunction

Bool Function IsCustomTemporaryRace(Race playerRace)
    if !playerRace
        return false
    endIf

    if !JsonUtil.JsonExists(TEMPORARY_RACEMAP_FILE)
        return false
    endIf

    Int entryCount = JsonUtil.FormListCount(TEMPORARY_RACEMAP_FILE, "temporaryRaceForms")
    Int entryIndex = 0
    while entryIndex < entryCount
        Race temporaryRace = JsonUtil.FormListGet(TEMPORARY_RACEMAP_FILE, "temporaryRaceForms", entryIndex) as Race
        if temporaryRace && temporaryRace == playerRace
            Trace(1, "Custom temporary race matched; deferring origin capture.")
            return true
        endIf
        entryIndex += 1
    endWhile

    return false
EndFunction

Bool Function MatchesRaceForm(Race playerRace, Int localFormId, String pluginName)
    if !playerRace
        return false
    endIf

    Race knownRace = Game.GetFormFromFile(localFormId, pluginName) as Race
    if knownRace && playerRace == knownRace
        return true
    endIf

    return false
EndFunction

Function SeedProofSliceDeities(Int raceIndex)
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") != 1
        StorageUtil.SetIntValue(None, "PDV.CustomRaceFallback", 0)
    endIf

    SeedDeity(PDV_Kyne, GetKyneSeedPiety(raceIndex))
    SeedDeity(PDV_Talos, GetTalosSeedPiety(raceIndex))
    SeedDeity(PDV_AuriEl, GetAuriElSeedPiety(raceIndex))
EndFunction

Function RecordCustomRaceFallback()
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") == 1
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.CustomRaceFallback", 1)
    Debug.Notification("Devotion read your race as Imperial for devotion.")
EndFunction

Function RecordCustomRaceResolved(Int resolvedIndex)
    StorageUtil.SetIntValue(None, "PDV.CustomRaceFallback", 0)
    StorageUtil.SetIntValue(None, "PDV.CustomRaceResolved", 1)
    StorageUtil.SetIntValue(None, "PDV.CustomRaceResolvedIndex", resolvedIndex)
    Trace(1, "Custom race resolved to vanilla profile index " + resolvedIndex)
EndFunction

;/
    ResolveCustomRaceIndex
    Maps an unrecognized (modded/custom) race to one of the ten vanilla race
    indices. Precedence: author/user override map first, then RaceCompatibility
    ActorProxy keywords. Returns RACE_UNKNOWN when nothing resolves so the caller
    applies the existing configurable fallback. All optional forms are read via
    Game.GetModByName / GetFormFromFile and guarded for None, so absent
    frameworks simply skip their branch.
/;
Int Function ResolveCustomRaceIndex(Race customRace)
    if !customRace
        return RACE_UNKNOWN
    endIf

    ; Player-facing master toggle (MCM Compatibility page). Off => behave as
    ; vanilla-only and let the existing Imperial fallback apply.
    if StorageUtil.GetIntValue(None, "PDV.Compat.CustomRaceMapping", 1) == 0
        return RACE_UNKNOWN
    endIf

    Int viaOverride = ResolveViaRaceMap(customRace)
    if viaOverride >= 0
        return viaOverride
    endIf

    Int viaProxy = ResolveViaActorProxy(customRace)
    if viaProxy >= 0
        return viaProxy
    endIf

    return RACE_UNKNOWN
EndFunction

Int Function ResolveViaRaceMap(Race customRace)
    if !JsonUtil.JsonExists(RACEMAP_FILE)
        return RACE_UNKNOWN
    endIf

    Int entryCount = JsonUtil.FormListCount(RACEMAP_FILE, "raceForms")
    Int entryIndex = 0
    while entryIndex < entryCount
        Race mappedRace = JsonUtil.FormListGet(RACEMAP_FILE, "raceForms", entryIndex) as Race
        if mappedRace && mappedRace == customRace
            Int mappedIndex = JsonUtil.IntListGet(RACEMAP_FILE, "raceIndices", entryIndex)
            if mappedIndex >= RACE_NORD && mappedIndex <= RACE_REDGUARD
                Trace(1, "Custom race resolved via override map to index " + mappedIndex)
                return mappedIndex
            endIf
        endIf
        entryIndex += 1
    endWhile

    return RACE_UNKNOWN
EndFunction

Int Function ResolveViaActorProxy(Race customRace)
    if Game.GetModByName(RACECOMPAT_PLUGIN) == 255
        return RACE_UNKNOWN
    endIf

    if HasProxyKeyword(customRace, 0x001D93)
        return RACE_NORD
    elseIf HasProxyKeyword(customRace, 0x001D90)
        return RACE_IMPERIAL
    elseIf HasProxyKeyword(customRace, 0x001D8A)
        return RACE_BRETON
    elseIf HasProxyKeyword(customRace, 0x001D8E)
        return RACE_ALTMER
    elseIf HasProxyKeyword(customRace, 0x001D92)
        return RACE_BOSMER
    elseIf HasProxyKeyword(customRace, 0x001D8F)
        return RACE_DUNMER
    elseIf HasProxyKeyword(customRace, 0x001D8C)
        return RACE_KHAJIIT
    elseIf HasProxyKeyword(customRace, 0x001D8B)
        return RACE_ARGONIAN
    elseIf HasProxyKeyword(customRace, 0x001D8D)
        return RACE_ORSIMER
    elseIf HasProxyKeyword(customRace, 0x001D91)
        return RACE_REDGUARD
    endIf

    return RACE_UNKNOWN
EndFunction

Bool Function HasProxyKeyword(Race customRace, Int localFormId)
    Keyword proxyKeyword = Game.GetFormFromFile(localFormId, RACECOMPAT_PLUGIN) as Keyword
    if proxyKeyword
        return customRace.HasKeyword(proxyKeyword)
    endIf
    return false
EndFunction

Function SeedDeity(PDV_DeityBase deity, Float startPiety)
    if !deity
        return
    endIf

    Form deityForm = deity as Form
    StorageUtil.SetFloatValue(deityForm, "PDV.Piety", startPiety)
    StorageUtil.SetFloatValue(deityForm, "PDV.PietyToday", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.Tier", 0.0)
    StorageUtil.SetFloatValue(deityForm, "PDV.LastTierChange", 0.0)

    if PDV_Manager
        PDV_Manager.RecomputeTier(deity, False)
    endIf

    Trace(1, deity.DeityName + " seeded to " + startPiety + " piety.")
EndFunction

Float Function GetKyneSeedPiety(Int raceIndex)
    if raceIndex == RACE_NORD
        return KYNE_START_PIETY_NORD
    endIf
    return KYNE_START_PIETY_OTHER
EndFunction

Float Function GetTalosSeedPiety(Int raceIndex)
    if raceIndex == RACE_NORD
        return TALOS_START_PIETY_NORD
    endIf
    return TALOS_START_PIETY_OTHER
EndFunction

Float Function GetAuriElSeedPiety(Int raceIndex)
    if raceIndex == RACE_ALTMER
        return AURIEL_START_PIETY_ALTMER
    endIf
    return AURIEL_START_PIETY_OTHER
EndFunction

Actor Function GetPlayerActor()
    if PlayerRef
        return PlayerRef
    endIf
    return Game.GetPlayer()
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] Origin: " + traceText)
    endIf
EndFunction
