Scriptname PDV_DiegeticDeps extends Quest
{Cached soft-dependency flags for the diegetic UX director.}

Bool Property ForceAllDepsAbsent = False Auto

String Property DEP_DF = "DF" AutoReadOnly
String Property DEP_DBF = "DBF" AutoReadOnly
String Property DEP_NIOVERRIDE = "NiOverride" AutoReadOnly
String Property DEP_OAR = "OAR" AutoReadOnly
String Property DEP_PO3 = "PO3" AutoReadOnly

Bool Function Has(String depName)
    if ForceAllDepsAbsent
        return False
    endIf

    String normalized = NormalizeDepName(depName)
    if normalized == ""
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Dep.ForceAllAbsent") == 1
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Dep.Disable." + normalized) == 1
        return False
    endIf

    return StorageUtil.GetIntValue(None, "PDV.Diegetic.Dep." + normalized) == 1
EndFunction

Function Reprobe()
    ; D1 is safe with every optional framework absent. Explicit Enable.* keys let
    ; a future CK/live proof opt into an emitter without changing this script.
    CacheDep(DEP_DF, 0)
    CacheDep(DEP_DBF, 0)
    CacheDep(DEP_NIOVERRIDE, 0)
    CacheDep(DEP_OAR, 1)
    CacheDep(DEP_PO3, 0)
    StorageUtil.SetFloatValue(None, "PDV.Diegetic.LastReprobeAt", Utility.GetCurrentGameTime())
EndFunction

Function CacheDep(String depName, Int defaultValue)
    String normalized = NormalizeDepName(depName)
    if normalized == ""
        return
    endIf

    Int value = defaultValue
    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Dep.Enable." + normalized) == 1
        value = 1
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Diegetic.Dep.Disable." + normalized) == 1
        value = 0
    endIf

    StorageUtil.SetIntValue(None, "PDV.Diegetic.Dep." + normalized, value)
EndFunction

String Function NormalizeDepName(String depName)
    if depName == "DF" || depName == "DescriptionFramework"
        return DEP_DF
    endIf
    if depName == "DBF" || depName == "DynamicBookFramework"
        return DEP_DBF
    endIf
    if depName == "NiOverride" || depName == "RaceMenu"
        return DEP_NIOVERRIDE
    endIf
    if depName == "OAR" || depName == "OpenAnimationReplacer"
        return DEP_OAR
    endIf
    if depName == "PO3" || depName == "PapyrusExtender"
        return DEP_PO3
    endIf
    return ""
EndFunction
