Scriptname PDV_DiegeticDirector extends Quest
{Repo-side D1 diegetic UX director scaffold. Live use requires CK record creation and property wiring.}

PDV_DiegeticDeps Property PDV_DiegeticDepsService Auto

GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_OriginRace Auto
FormList Property PDV_FLST_AllDeities Auto

ImageSpaceModifier Property PDV_IMAD_Reverent Auto
ImageSpaceModifier Property PDV_IMAD_Revelation Auto
ImageSpaceModifier Property PDV_IMAD_Dread Auto
ImageSpaceModifier Property PDV_IMAD_Release Auto
ImageSpaceModifier Property PDV_IMAD_Absence Auto

Spell Property PDV_Abil_Shader_Reverent Auto
Spell Property PDV_Abil_Shader_Revelation Auto
Spell Property PDV_Abil_Shader_Dread Auto
Spell Property PDV_Abil_Shader_Release Auto

Sound Property PDV_SND_Chime Auto
Sound Property PDV_SND_Swell Auto
Sound Property PDV_SND_Hollow Auto
Sound Property PDV_SND_RisingChime Auto
Sound Property PDV_SND_Distant Auto

MusicType Property PDV_MUS_CurseBed Auto

MiscObject Property PDV_DevotionMedallion Auto
Book Property PDV_BookOfDays Auto

Bool Property D1Enabled = False Auto
Bool Property TraceDispatch = True Auto

Int Property VERBOSITY_SILENT = 0 AutoReadOnly
Int Property VERBOSITY_TRANSITIONS = 1 AutoReadOnly
Int Property VERBOSITY_VERBOSE = 2 AutoReadOnly

Function Dispatch(String eventClass, String surfaceKey, String direction, Int deityIndex, String toneOverride = "")
    if !D1Enabled
        StorageUtil.SetStringValue(None, "PDV.Diegetic.LastSkipped", eventClass + "." + surfaceKey + "." + direction)
        return
    endIf

    EnsureDeps()
    String tone = GetProfileTone(eventClass, direction, toneOverride)
    if tone == ""
        tone = "quiet"
    endIf

    StorageUtil.SetStringValue(None, "PDV.Diegetic.LastDispatch", eventClass + "." + surfaceKey + "." + direction)
    StorageUtil.SetStringValue(None, "PDV.Diegetic.LastTone", tone)
    StorageUtil.SetIntValue(None, "PDV.Diegetic.LastDeityIndex", deityIndex)

    if TraceDispatch
        Debug.Trace("[PDV] Diegetic dispatch " + eventClass + "." + surfaceKey + "." + direction + " tone " + tone)
    endIf

    EmitScreen(tone)
    EmitSound(tone)
    EmitMusicForClass(eventClass, direction)
    EmitJournal(deityIndex, eventClass + "." + direction)
    RefreshMedallion()

    if eventClass == "curse" && direction == "onset"
        SetBodyMark("scar", True)
    elseIf eventClass == "curse" && direction == "cure"
        SetBodyMark("scar", False)
    endIf
EndFunction

Function OnLoad()
    EnsureDeps()
    RemoveShaderSpell(PDV_Abil_Shader_Reverent)
    PDV_DiegeticDepsService.Reprobe()
    RefreshMedallion()
    ReassertMusicStates()
    ReassertBodyMarks()
EndFunction

Function RefreshMedallion()
    StorageUtil.SetIntValue(None, "PDV.Diegetic.MedallionDirty", 1)
    String text = BuildMedallionText()
    StorageUtil.SetStringValue(None, "PDV.Diegetic.MedallionText", text)

    if !HasDep("DF")
        StorageUtil.SetStringValue(None, "PDV.Diegetic.MedallionFallback", "Survey")
        return
    endIf

    ; Description Framework calls are intentionally not made until the CK/live pass
    ; verifies the installed API source. The computed text is cached for that pass.
    StorageUtil.SetStringValue(None, "PDV.Diegetic.MedallionFallback", "DFPending")
EndFunction

Function EmitScreen(String tone)
    ImageSpaceModifier imod = GetImageSpaceForTone(tone)
    if imod
        if tone == "dread"
            imod.ApplyCrossFade(1.0)
            StorageUtil.SetIntValue(None, "PDV.Diegetic.Screen.DreadActive", 1)
        else
            imod.ApplyCrossFade(1.0)
        endIf
    endIf

    Actor playerRef = Game.GetPlayer()
    Spell shaderSpell = GetShaderForTone(tone)
    if tone == "reverent"
        RemoveShaderSpell(shaderSpell)
        return
    endIf
    if playerRef && shaderSpell
        if tone == "release" && PDV_Abil_Shader_Dread
            playerRef.RemoveSpell(PDV_Abil_Shader_Dread)
            StorageUtil.SetIntValue(None, "PDV.Diegetic.Screen.DreadActive", 0)
        endIf
        ; Pulse spell duration/removal belongs in the MGEF record, not a latent manager path.
        playerRef.AddSpell(shaderSpell, False)
    endIf
EndFunction

Function RemoveShaderSpell(Spell shaderSpell)
    Actor playerRef = Game.GetPlayer()
    if playerRef && shaderSpell && playerRef.HasSpell(shaderSpell)
        playerRef.RemoveSpell(shaderSpell)
    endIf
EndFunction

Function EmitSound(String tone)
    Sound cue = GetSoundForTone(tone)
    Actor playerRef = Game.GetPlayer()
    if cue && playerRef
        cue.Play(playerRef)
    endIf
EndFunction

Function EmitMusicState(String stateKey, Bool enable)
    if stateKey == "curse_bed" && PDV_MUS_CurseBed
        if enable
            if StorageUtil.GetIntValue(None, "PDV.Diegetic.Music." + stateKey) == 0
                PDV_MUS_CurseBed.Add()
                StorageUtil.SetIntValue(None, "PDV.Diegetic.Music." + stateKey, 1)
            endIf
        else
            if StorageUtil.GetIntValue(None, "PDV.Diegetic.Music." + stateKey) == 1
                PDV_MUS_CurseBed.Remove()
                StorageUtil.SetIntValue(None, "PDV.Diegetic.Music." + stateKey, 0)
            endIf
        endIf
    endIf
EndFunction

Function EmitJournal(Int deityIndex, String toneKey)
    String line = ResolveJournalLine(deityIndex, toneKey)
    if line == ""
        return
    endIf

    StorageUtil.SetStringValue(None, "PDV.Diegetic.Journal.LastLine", line)
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.PendingCount", StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.PendingCount") + 1)

    if !HasDep("DBF")
        StorageUtil.SetStringValue(None, "PDV.Diegetic.JournalFallback", "PendingDBF")
        return
    endIf

    ; DBF append is deferred until its local source signature is verified.
    StorageUtil.SetStringValue(None, "PDV.Diegetic.JournalFallback", "DBFPending")
EndFunction

Function SetBodyMark(String markKey, Bool enable)
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Mark." + markKey, BoolToInt(enable))
    StorageUtil.SetStringValue(None, "PDV.Diegetic.Mark.Last", markKey)
EndFunction

Function EmitPrayerAnim(String poseKey)
    StorageUtil.SetStringValue(None, "PDV.Diegetic.Anim.LastPose", poseKey)
    if !HasDep("OAR")
        return
    endIf
    ; OAR D1 is intentionally data-only/no-op. V2 supplies the submod and condition contract.
EndFunction

Function EmitRoutineFavor()
    RefreshMedallion()
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.FavorDigestPending", 1)
    if GetVerbosity() >= VERBOSITY_VERBOSE
        EmitSound("quiet")
    endIf
EndFunction

Function EmitMusicForClass(String eventClass, String direction)
    if eventClass == "curse" && direction == "onset"
        EmitMusicState("curse_bed", True)
    elseIf eventClass == "curse" && direction == "cure"
        EmitMusicState("curse_bed", False)
    endIf
EndFunction

Function ReassertMusicStates()
    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Music.curse_bed") == 1
        EmitMusicState("curse_bed", True)
    endIf
EndFunction

Function ReassertBodyMarks()
    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Mark.scar") == 1
        SetBodyMark("scar", True)
    endIf
EndFunction

String Function GetProfileTone(String eventClass, String direction, String toneOverride)
    if toneOverride != ""
        return toneOverride
    endIf
    if eventClass == "tier"
        return "reverent"
    endIf
    if eventClass == "emergence"
        return "revelation"
    endIf
    if eventClass == "curse"
        if direction == "cure"
            return "release"
        endIf
        return "dread"
    endIf
    if eventClass == "neglect"
        if direction == "recover"
            return "reverent"
        endIf
        return "absence"
    endIf
    if eventClass == "reorientation"
        return "turning"
    endIf
    return "quiet"
EndFunction

ImageSpaceModifier Function GetImageSpaceForTone(String tone)
    if tone == "reverent"
        return PDV_IMAD_Reverent
    endIf
    if tone == "revelation"
        return PDV_IMAD_Revelation
    endIf
    if tone == "dread"
        return PDV_IMAD_Dread
    endIf
    if tone == "release"
        return PDV_IMAD_Release
    endIf
    if tone == "absence"
        return PDV_IMAD_Absence
    endIf
    return None
EndFunction

Spell Function GetShaderForTone(String tone)
    if tone == "reverent"
        return PDV_Abil_Shader_Reverent
    endIf
    if tone == "revelation"
        return PDV_Abil_Shader_Revelation
    endIf
    if tone == "dread"
        return PDV_Abil_Shader_Dread
    endIf
    if tone == "release"
        return PDV_Abil_Shader_Release
    endIf
    return None
EndFunction

Sound Function GetSoundForTone(String tone)
    if tone == "reverent"
        return PDV_SND_Chime
    endIf
    if tone == "revelation"
        return PDV_SND_Swell
    endIf
    if tone == "dread"
        return PDV_SND_Hollow
    endIf
    if tone == "release"
        return PDV_SND_RisingChime
    endIf
    if tone == "absence"
        return PDV_SND_Distant
    endIf
    return PDV_SND_Chime
EndFunction

String Function BuildMedallionText()
    Int originRace = GetOriginRace()
    Int tierValue = GetActiveTier()
    if originRace == 6
        return BuildKhajiitMedallionText(tierValue)
    endIf
    if originRace == 5
        return BuildDunmerMedallionText(tierValue)
    endIf
    return "Devotion Medallion|Favor: " + GetGenericTierLabel(tierValue) + ".|Listen for the gods you keep."
EndFunction

String Function BuildKhajiitMedallionText(Int tierValue)
    if IsCurseActive()
        return "Medallion (shadowed)|Favor: " + GetKhajiitTierLabel(tierValue) + ".|A curse stands between you and the sky."
    endIf
    if IsNeglectLikely()
        return "Medallion (dimmed)|Favor: " + GetKhajiitTierLabel(tierValue) + ".|Unheard for days. Pray, or offer on the road."
    endIf
    return "Medallion of Khenarthi|Favor: " + GetKhajiitTierLabel(tierValue) + ".|The wind carries your name."
EndFunction

String Function BuildDunmerMedallionText(Int tierValue)
    if IsCurseActive()
        return "Ancestral Medallion (turned away)|Favor: " + GetDunmerTierLabel(tierValue) + ".|The dead draw back from what you have become."
    endIf
    if IsNeglectLikely()
        return "Ancestral Medallion (cold)|Favor: " + GetDunmerTierLabel(tierValue) + ".|The shrine has gone cold. Burn ash, speak their names."
    endIf
    return "Ancestral Medallion|Favor: " + GetDunmerTierLabel(tierValue) + ".|The ash is warm; the dead walk near."
EndFunction

String Function ResolveJournalLine(Int deityIndex, String toneKey)
    Int originRace = GetOriginRace()
    if originRace == 6
        return ResolveKhajiitJournalLine(toneKey, deityIndex)
    endIf
    if originRace == 5
        return ResolveDunmerJournalLine(toneKey)
    endIf
    if originRace == 1
        return ResolveImperialJournalLine(toneKey)
    endIf
    if originRace == 3
        return ResolveAltmerJournalLine(toneKey)
    endIf
    if toneKey == "curse.onset"
        return "A curse changes the shape of devotion."
    endIf
    if toneKey == "curse.cure"
        return "The curse lifts, and devotion may answer again."
    endIf
    if toneKey == "tier.reach"
        return "Your devotion has deepened."
    endIf
    return ""
EndFunction

String Function ResolveKhajiitJournalLine(String toneKey, Int deityIndex)
    if toneKey == "substrate.act"
        return "The moons marked your road-rest."
    endIf
    if toneKey == "tier.reach"
        return "You reached Faithful. The pantheon turns to look."
    endIf
    if toneKey == "emergence.onset"
        return "Under the moons your road turned toward " + GetDeityNameByIndex(deityIndex) + ", and stayed there."
    endIf
    if toneKey == "curse.onset"
        return "Cold takes you. The moons close their eyes."
    endIf
    if toneKey == "curse.cure"
        return "The scar closes. The sky is yours again; she hears you once more."
    endIf
    if toneKey == "neglect.drop"
        return "Khenarthi's wind has stilled around you."
    endIf
    return ""
EndFunction

String Function GetDeityNameByIndex(Int deityIndex)
    if deityIndex >= 0 && PDV_FLST_AllDeities
        Int i = 0
        Int count = PDV_FLST_AllDeities.GetSize()
        while i < count
            PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
            if deity && deity.DeityIndex == deityIndex
                return deity.DeityName
            endIf
            i += 1
        endWhile
    endIf
    return "the road"
EndFunction

String Function ResolveDunmerJournalLine(String toneKey)
    if toneKey == "substrate.act"
        return "The ash remembers you came to the shrine today."
    endIf
    if toneKey == "tier.reach"
        return "You are Remembered. The ancestors keep your name among theirs."
    endIf
    if toneKey == "curse.onset"
        return "Cold blood. The ancestors recoil, yet the Good Daedra turn their eyes toward you."
    endIf
    if toneKey == "curse.cure"
        return "The taint lifts. The ash accepts you again, and the dead draw near."
    endIf
    if toneKey == "neglect.drop"
        return "The shrine has gone cold; the ancestors' voices thin."
    endIf
    return ""
EndFunction

String Function ResolveImperialJournalLine(String toneKey)
    if toneKey == "substrate.act"
        return "You kept the civic vigil today; the old oaths take note."
    endIf
    if toneKey == "tier.reach"
        return "The Divines acknowledge you under law. The covenant holds."
    endIf
    if toneKey == "curse.onset"
        return "The communion falters; the curse sets you outside the lawful rites."
    endIf
    if toneKey == "curse.cure"
        return "The rites reopen to you. The Divines answer the lawful again."
    endIf
    if toneKey == "neglect.drop"
        return "The temples grow distant, and the oaths go unspoken."
    endIf
    return ""
EndFunction

String Function ResolveAltmerJournalLine(String toneKey)
    if toneKey == "substrate.act"
        return "The dawn-line steadies. Auri-El keeps your discipline today."
    endIf
    if toneKey == "tier.reach"
        return "Coherence holds. The old line names you among the disciplined."
    endIf
    if toneKey == "curse.onset"
        return "The line frays. The dawn turns its face from a divided self."
    endIf
    if toneKey == "curse.cure"
        return "The discipline reasserts, and Auri-El's dawn finds you whole again."
    endIf
    if toneKey == "neglect.drop"
        return "The dawn-practice lapses; the line dims and waits."
    endIf
    return ""
EndFunction

Int Function GetVerbosity()
    return StorageUtil.GetIntValue(None, "PDV.Diegetic.Verbosity")
EndFunction

Int Function GetOriginRace()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf
    return -1
EndFunction

Int Function GetActiveTier()
    if PDV_GLO_ActiveTier
        return PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return 0
EndFunction

Bool Function IsCurseActive()
    return StorageUtil.GetIntValue(None, "PDV.Curse.State") != 0
EndFunction

Bool Function IsNeglectLikely()
    return StorageUtil.GetIntValue(None, "PDV.Neglect.ActiveCount") > 0
EndFunction

Bool Function HasDep(String depName)
    EnsureDeps()
    if !PDV_DiegeticDepsService
        return False
    endIf
    return PDV_DiegeticDepsService.Has(depName)
EndFunction

Function EnsureDeps()
    if !PDV_DiegeticDepsService
        Debug.Trace("[PDV] DiegeticDirector missing PDV_DiegeticDepsService.")
    endIf
EndFunction

String Function GetGenericTierLabel(Int tierValue)
    if tierValue >= 3
        return "Champion"
    endIf
    if tierValue == 2
        return "Devoted"
    endIf
    if tierValue == 1
        return "Seeker"
    endIf
    return "Distant"
EndFunction

String Function GetKhajiitTierLabel(Int tierValue)
    if tierValue >= 3
        return "Champion"
    endIf
    if tierValue == 2
        return "Devoted"
    endIf
    if tierValue == 1
        return "Seeker"
    endIf
    return "Distant"
EndFunction

String Function GetDunmerTierLabel(Int tierValue)
    if tierValue >= 3
        return "Kin of the Ash"
    endIf
    if tierValue == 2
        return "Honored"
    endIf
    if tierValue == 1
        return "Remembered"
    endIf
    return "Distant"
EndFunction

Int Function BoolToInt(Bool value)
    if value
        return 1
    endIf
    return 0
EndFunction
