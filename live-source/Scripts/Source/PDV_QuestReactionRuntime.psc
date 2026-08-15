Scriptname PDV_QuestReactionRuntime extends Quest

; V3 Quest Reaction deep module. This script repurposes the existing worker
; quest: one existing host, one scheduler, one persisted FIFO. Engine adapters
; submit semantic inputs; the Manager remains the scoring/presentation sink.

PDV__ManagerQuest Property PDV_Manager Auto

Int Property INTERFACE_VERSION = 1 AutoReadOnly
String Property QUEST_REACTION_CORE_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionCore.v2" AutoReadOnly
String Property QUEST_REACTION_PATCH_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionPatches.v2" AutoReadOnly
String Property QUEST_REACTION_EXTENSION_FOLDER = "../StorageUtilData/PlayerDevotion/QuestReactionExtensions" AutoReadOnly
Int Property QUEST_REACTION_QUEUE_MAX_PENDING = 128 AutoReadOnly
Int Property QUEST_REACTION_QUEUE_CELLS_PER_TICK = 2 AutoReadOnly
Float Property QUEST_REACTION_QUEUE_TICK_SECONDS = 0.1 AutoReadOnly
Float Property QUEST_REACTION_DUPLICATE_WINDOW_DAYS = 0.02 AutoReadOnly

String Property QUEUE_IDS_KEY = "PDV.V3.QR.Queue.JobIds" AutoReadOnly
String Property QUEUE_FORMS_KEY = "PDV.V3.QR.Queue.SourceForms" AutoReadOnly
String Property QUEUE_SEQUENCE_KEY = "PDV.V3.QR.Queue.Sequence" AutoReadOnly
String Property QUEUE_UPDATE_ARMED_KEY = "PDV.V3.QR.Queue.UpdateArmed" AutoReadOnly
String Property JOB_PREFIX = "PDV.V3.QR.Job." AutoReadOnly
String Property INDEXED_QUEST_KEYS_KEY = "PDV.V3.QR.Index.QuestKeys" AutoReadOnly
String Property INDEXED_SEMANTIC_KEYS_KEY = "PDV.V3.QR.Index.SemanticKeys" AutoReadOnly
String Property INDEXED_STAGE_ADAPTER_KEYS_KEY = "PDV.V3.QR.Index.StageAdapterKeys" AutoReadOnly
String Property INDEXED_RUNTIME_FORMS_KEY = "PDV.V3.QR.Index.RuntimeForms" AutoReadOnly
String Property REGISTERED_RUNTIME_FORMS_KEY = "PDV.V3.QR.Index.RegisteredRuntimeForms" AutoReadOnly
String Property DISABLED_SOURCES_KEY = "PDV.V3.QR.DisabledSources" AutoReadOnly

Alias _questStageReceiver = None
Bool _sliceActive = False
Int _loadedCatalogCount = 0
Int _loadedSourceCount = 0
Int _activeSourceCount = 0
Int _inactiveSourceCount = 0
Int _rejectedSourceCount = 0

Event OnInit()
    Configure(None, False)
EndEvent

Bool Function Configure(Alias questStageReceiver, Bool fromLoad = False)
    if questStageReceiver
        _questStageReceiver = questStageReceiver
    endIf
    Bool savedSliceOwnsResume = fromLoad && _sliceActive
    if fromLoad
        ; Cancel a saved pending registration before replacing it. If the save
        ; captured an active OnUpdate stack, that stack owns the cursor and will
        ; re-arm when it finishes; starting a second chain would replay cells.
        UnregisterForUpdate()
        StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 0)
    endIf
    RefreshCatalogSources()
    if fromLoad && HasQueuedQuestReactionJobs()
        TraceQuestReactionQueue("RESUME resumed " + GetStatusLine())
    endIf
    if !savedSliceOwnsResume
        EnsureQuestReactionQueueRunning()
    endIf
    return PDV_Manager != None
EndFunction

Function RefreshCatalogSources()
    ResetCatalogIndexes()
    _loadedCatalogCount = 0
    _loadedSourceCount = 0
    _activeSourceCount = 0
    _inactiveSourceCount = 0
    _rejectedSourceCount = 0
    LoadAndActivateCatalog(QUEST_REACTION_CORE_FILE)
    LoadAndActivateCatalog(QUEST_REACTION_PATCH_FILE)
    String[] extensionNames = SortCatalogNames(JsonUtil.JsonInFolder(QUEST_REACTION_EXTENSION_FOLDER))
    if extensionNames
        Int extensionIndex = 0
        while extensionIndex < extensionNames.Length
            LoadAndActivateCatalog(QUEST_REACTION_EXTENSION_FOLDER + "/" + extensionNames[extensionIndex])
            extensionIndex += 1
        endWhile
    endIf
    TraceQuestReactionQueue("CATALOG loaded catalogs=" + _loadedCatalogCount + " sources=" + _loadedSourceCount + " active=" + _activeSourceCount + " inactive=" + _inactiveSourceCount + " rejected=" + _rejectedSourceCount)
    TraceQuestReactionQueue("CATALOG loaded questKeys=" + StorageUtil.StringListCount(None, INDEXED_QUEST_KEYS_KEY) + " semanticKeys=" + StorageUtil.StringListCount(None, INDEXED_SEMANTIC_KEYS_KEY) + " active=" + _activeSourceCount + " rejected=" + _rejectedSourceCount)
EndFunction

Function LoadAndActivateCatalog(String catalogFile)
    if catalogFile == "" || !JsonUtil.JsonExists(catalogFile)
        _rejectedSourceCount += 1
        TraceQuestReactionQueue("CATALOG_REJECT file=" + catalogFile + " reason=missing")
        return
    endIf
    JsonUtil.Unload(catalogFile, False)
    if !JsonUtil.Load(catalogFile) || !JsonUtil.IsGood(catalogFile)
        _rejectedSourceCount += 1
        TraceQuestReactionQueue("CATALOG_REJECT file=" + catalogFile + " reason=parse_or_load")
        return
    endIf
    if JsonUtil.GetStringValue(catalogFile, "schema") != "pdv.quest-reaction.catalog.v2" || JsonUtil.GetIntValue(catalogFile, "schemaVersion") != 2
        _rejectedSourceCount += 1
        TraceQuestReactionQueue("CATALOG_REJECT file=" + catalogFile + " reason=schema")
        return
    endIf
    _loadedCatalogCount += 1
    ActivateCatalogSources(catalogFile)
EndFunction

Function ResetCatalogIndexes()
    if _questStageReceiver
        PO3_Events_Alias.UnregisterForAllQuestStages(_questStageReceiver)
    endIf
    Int index = 0
    Int count = StorageUtil.StringListCount(None, INDEXED_QUEST_KEYS_KEY)
    while index < count
        String questKey = StorageUtil.StringListGet(None, INDEXED_QUEST_KEYS_KEY, index)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.CellCatalog." + questKey)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.CellSourceName." + questKey)
        index += 1
    endWhile
    index = 0
    count = StorageUtil.StringListCount(None, INDEXED_SEMANTIC_KEYS_KEY)
    while index < count
        String semanticKey = StorageUtil.StringListGet(None, INDEXED_SEMANTIC_KEYS_KEY, index)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.SemanticCatalog." + semanticKey)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.SemanticSourceName." + semanticKey)
        index += 1
    endWhile
    index = 0
    count = StorageUtil.StringListCount(None, INDEXED_STAGE_ADAPTER_KEYS_KEY)
    while index < count
        String stageAdapterKey = StorageUtil.StringListGet(None, INDEXED_STAGE_ADAPTER_KEYS_KEY, index)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.StageAdapterCatalog." + stageAdapterKey)
        index += 1
    endWhile
    index = 0
    count = StorageUtil.StringListCount(None, INDEXED_RUNTIME_FORMS_KEY)
    while index < count
        String runtimeFormId = StorageUtil.StringListGet(None, INDEXED_RUNTIME_FORMS_KEY, index)
        StorageUtil.UnsetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId)
        StorageUtil.UnsetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId)
        index += 1
    endWhile
    StorageUtil.StringListClear(None, INDEXED_QUEST_KEYS_KEY)
    StorageUtil.StringListClear(None, INDEXED_SEMANTIC_KEYS_KEY)
    StorageUtil.StringListClear(None, INDEXED_STAGE_ADAPTER_KEYS_KEY)
    StorageUtil.StringListClear(None, INDEXED_RUNTIME_FORMS_KEY)
    StorageUtil.StringListClear(None, REGISTERED_RUNTIME_FORMS_KEY)
EndFunction

String[] Function SortCatalogNames(String[] names)
    if !names || names.Length < 2
        return names
    endIf
    Int index = 1
    while index < names.Length
        String value = names[index]
        Int scan = index - 1
        while scan >= 0 && CompareCatalogNames(names[scan], value) > 0
            names[scan + 1] = names[scan]
            scan -= 1
        endWhile
        names[scan + 1] = value
        index += 1
    endWhile
    return names
EndFunction

Int Function CompareCatalogNames(String left, String right)
    Int leftLength = StringUtil.GetLength(left)
    Int rightLength = StringUtil.GetLength(right)
    Int count = leftLength
    if rightLength < count
        count = rightLength
    endIf
    Int index = 0
    while index < count
        Int leftCode = StringUtil.AsOrd(StringUtil.GetNthChar(left, index))
        Int rightCode = StringUtil.AsOrd(StringUtil.GetNthChar(right, index))
        if leftCode < rightCode
            return -1
        elseIf leftCode > rightCode
            return 1
        endIf
        index += 1
    endWhile
    if leftLength < rightLength
        return -1
    elseIf leftLength > rightLength
        return 1
    endIf
    return 0
EndFunction

Bool Function SubmitQuestStage(Quest sourceQuest, Int stageValue, String logicalEventId = "")
    return QueueQuestReactionJob(sourceQuest, ResolveQuestStage(sourceQuest, stageValue), logicalEventId)
EndFunction

Function ActivateCatalogSources(String catalogFile)
    Int sourceIndex = 0
    Int sourceCount = JsonUtil.StringListCount(catalogFile, "sourceIds")
    _loadedSourceCount += sourceCount
    while sourceIndex < sourceCount
        String sourceId = JsonUtil.StringListGet(catalogFile, "sourceIds", sourceIndex)
        if !ValidateCatalogSource(catalogFile, sourceId)
            _rejectedSourceCount += 1
            TraceQuestReactionQueue("CATALOG_REJECT file=" + catalogFile + " source=" + sourceId + " reason=invalid_source")
        elseIf !CanActivateCatalogSource(catalogFile, sourceId)
            _inactiveSourceCount += 1
        else
            IndexCatalogSource(catalogFile, sourceId)
            _activeSourceCount += 1
        endIf
        sourceIndex += 1
    endWhile
EndFunction

Bool Function ValidateCatalogSource(String catalogFile, String sourceId)
    if sourceId == "" || JsonUtil.GetStringValue(catalogFile, "source." + sourceId + ".pluginName") == ""
        return False
    endIf
    String sentinelKey = "source." + sourceId + ".sentinelForms"
    Int sentinelCount = JsonUtil.StringListCount(catalogFile, sentinelKey)
    if sentinelCount <= 0 || HasDuplicateListValue(catalogFile, sentinelKey)
        return False
    endIf
    Int sentinelIndex = 0
    while sentinelIndex < sentinelCount
        if StringUtil.Split(JsonUtil.StringListGet(catalogFile, sentinelKey, sentinelIndex), "|").Length != 2
            return False
        endIf
        sentinelIndex += 1
    endWhile
    String questKeyList = "source." + sourceId + ".questKeys"
    if HasDuplicateListValue(catalogFile, questKeyList)
        return False
    endIf
    Int questIndex = 0
    Int questCount = JsonUtil.StringListCount(catalogFile, questKeyList)
    while questIndex < questCount
        String questKey = JsonUtil.StringListGet(catalogFile, questKeyList, questIndex)
        if StringUtil.Split(questKey, "|").Length != 3 || !ValidateReactionPayload(catalogFile, "quest." + questKey + ".")
            return False
        endIf
        questIndex += 1
    endWhile
    String semanticKeyList = "source." + sourceId + ".semanticKeys"
    if HasDuplicateListValue(catalogFile, semanticKeyList)
        return False
    endIf
    Int semanticIndex = 0
    Int semanticCount = JsonUtil.StringListCount(catalogFile, semanticKeyList)
    while semanticIndex < semanticCount
        String semanticKey = JsonUtil.StringListGet(catalogFile, semanticKeyList, semanticIndex)
        if StringUtil.Split(semanticKey, "|").Length != 2 || !ValidateReactionPayload(catalogFile, "semantic." + semanticKey + ".")
            return False
        endIf
        semanticIndex += 1
    endWhile
    String stageAdapterKeyList = "source." + sourceId + ".stageAdapterKeys"
    if HasDuplicateListValue(catalogFile, stageAdapterKeyList)
        return False
    endIf
    Int stageAdapterIndex = 0
    Int stageAdapterCount = JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
    while stageAdapterIndex < stageAdapterCount
        String stageAdapterKey = JsonUtil.StringListGet(catalogFile, stageAdapterKeyList, stageAdapterIndex)
        if JsonUtil.StringListFind(catalogFile, "stageAdapterKeys", stageAdapterKey) < 0 || !ValidateStageAdapter(catalogFile, stageAdapterKey)
            return False
        endIf
        stageAdapterIndex += 1
    endWhile
    return True
EndFunction

Bool Function HasDuplicateListValue(String catalogFile, String listKey)
    Int index = 0
    Int count = JsonUtil.StringListCount(catalogFile, listKey)
    while index < count
        if JsonUtil.StringListFind(catalogFile, listKey, JsonUtil.StringListGet(catalogFile, listKey, index)) != index
            return True
        endIf
        index += 1
    endWhile
    return False
EndFunction

Bool Function ValidateReactionPayload(String catalogFile, String prefix)
    Int count = JsonUtil.StringListCount(catalogFile, prefix + "deities")
    return count > 0 && JsonUtil.StringListCount(catalogFile, prefix + "valences") == count && JsonUtil.StringListCount(catalogFile, prefix + "intensities") == count && JsonUtil.StringListCount(catalogFile, prefix + "magnitudes") == count && JsonUtil.StringListCount(catalogFile, prefix + "tags") == count
EndFunction

Bool Function ValidateStageAdapter(String catalogFile, String stageAdapterKey)
    if StringUtil.Split(stageAdapterKey, "|").Length != 3
        return False
    endIf
    String prefix = "stageAdapter." + stageAdapterKey + "."
    String selectorKind = JsonUtil.GetStringValue(catalogFile, prefix + "selectorKind")
    Int selectorValueCount = JsonUtil.IntListCount(catalogFile, prefix + "selectorValues")
    return (selectorKind == "global" || selectorKind == "player_item_count") && JsonUtil.GetStringValue(catalogFile, prefix + "selectorPlugin") != "" && JsonUtil.GetIntValue(catalogFile, prefix + "selectorFormId", -1) >= 0 && selectorValueCount > 0 && JsonUtil.IntListCount(catalogFile, prefix + "targetStages") == selectorValueCount
EndFunction

Bool Function CanActivateCatalogSource(String catalogFile, String sourceId)
    if StorageUtil.StringListFind(None, DISABLED_SOURCES_KEY, sourceId) >= 0
        return False
    endIf
    String pluginName = JsonUtil.GetStringValue(catalogFile, "source." + sourceId + ".pluginName")
    if Game.GetModByName(pluginName) == 255
        return False
    endIf
    String sentinelKey = "source." + sourceId + ".sentinelForms"
    Int sentinelIndex = 0
    Int sentinelCount = JsonUtil.StringListCount(catalogFile, sentinelKey)
    while sentinelIndex < sentinelCount
        String[] sentinelParts = StringUtil.Split(JsonUtil.StringListGet(catalogFile, sentinelKey, sentinelIndex), "|")
        if Game.GetModByName(sentinelParts[0]) == 255 || !Game.GetFormFromFile(sentinelParts[1] as Int, sentinelParts[0])
            return False
        endIf
        sentinelIndex += 1
    endWhile
    String questKeyList = "source." + sourceId + ".questKeys"
    Int questIndex = 0
    Int questCount = JsonUtil.StringListCount(catalogFile, questKeyList)
    while questIndex < questCount
        String[] questParts = StringUtil.Split(JsonUtil.StringListGet(catalogFile, questKeyList, questIndex), "|")
        if Game.GetModByName(questParts[0]) == 255 || !(Game.GetFormFromFile(questParts[1] as Int, questParts[0]) as Quest)
            return False
        endIf
        questIndex += 1
    endWhile
    String stageAdapterKeyList = "source." + sourceId + ".stageAdapterKeys"
    Int stageAdapterIndex = 0
    Int stageAdapterCount = JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
    while stageAdapterIndex < stageAdapterCount
        String stageAdapterKey = JsonUtil.StringListGet(catalogFile, stageAdapterKeyList, stageAdapterIndex)
        String stageAdapterPrefix = "stageAdapter." + stageAdapterKey + "."
        String selectorPlugin = JsonUtil.GetStringValue(catalogFile, stageAdapterPrefix + "selectorPlugin")
        if Game.GetModByName(selectorPlugin) == 255 || !Game.GetFormFromFile(JsonUtil.GetIntValue(catalogFile, stageAdapterPrefix + "selectorFormId"), selectorPlugin)
            return False
        endIf
        stageAdapterIndex += 1
    endWhile
    return True
EndFunction

Function IndexCatalogSource(String catalogFile, String sourceId)
    String displayName = JsonUtil.GetStringValue(catalogFile, "source." + sourceId + ".displayName")
    String questKeyList = "source." + sourceId + ".questKeys"
    Int questIndex = 0
    Int questCount = JsonUtil.StringListCount(catalogFile, questKeyList)
    while questIndex < questCount
        String questKey = JsonUtil.StringListGet(catalogFile, questKeyList, questIndex)
        String[] questParts = StringUtil.Split(questKey, "|")
        Quest sourceQuest = Game.GetFormFromFile(questParts[1] as Int, questParts[0]) as Quest
        Int runtimeFormId = sourceQuest.GetFormID()
        String runtimeFormIdText = runtimeFormId as String
        if StorageUtil.GetStringValue(None, "PDV.V3.QR.CellCatalog." + questKey) == ""
            StorageUtil.SetStringValue(None, "PDV.V3.QR.CellCatalog." + questKey, catalogFile)
            StorageUtil.SetStringValue(None, "PDV.V3.QR.CellSourceName." + questKey, displayName)
            StorageUtil.StringListAdd(None, INDEXED_QUEST_KEYS_KEY, questKey, False)
        endIf
        StorageUtil.SetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId, questParts[1] as Int)
        StorageUtil.SetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId, questParts[0])
        StorageUtil.StringListAdd(None, INDEXED_RUNTIME_FORMS_KEY, runtimeFormIdText, False)
        if _questStageReceiver && StorageUtil.StringListFind(None, REGISTERED_RUNTIME_FORMS_KEY, runtimeFormIdText) < 0
            PO3_Events_Alias.RegisterForQuestStage(_questStageReceiver, sourceQuest)
            StorageUtil.StringListAdd(None, REGISTERED_RUNTIME_FORMS_KEY, runtimeFormIdText, False)
        endIf
        questIndex += 1
    endWhile
    String semanticKeyList = "source." + sourceId + ".semanticKeys"
    Int semanticIndex = 0
    Int semanticCount = JsonUtil.StringListCount(catalogFile, semanticKeyList)
    while semanticIndex < semanticCount
        String semanticKey = JsonUtil.StringListGet(catalogFile, semanticKeyList, semanticIndex)
        if StorageUtil.GetStringValue(None, "PDV.V3.QR.SemanticCatalog." + semanticKey) == ""
            StorageUtil.SetStringValue(None, "PDV.V3.QR.SemanticCatalog." + semanticKey, catalogFile)
            StorageUtil.SetStringValue(None, "PDV.V3.QR.SemanticSourceName." + semanticKey, displayName)
            StorageUtil.StringListAdd(None, INDEXED_SEMANTIC_KEYS_KEY, semanticKey, False)
        endIf
        semanticIndex += 1
    endWhile
    String stageAdapterKeyList = "source." + sourceId + ".stageAdapterKeys"
    Int stageAdapterIndex = 0
    Int stageAdapterCount = JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
    while stageAdapterIndex < stageAdapterCount
        String stageAdapterKey = JsonUtil.StringListGet(catalogFile, stageAdapterKeyList, stageAdapterIndex)
        if StorageUtil.GetStringValue(None, "PDV.V3.QR.StageAdapterCatalog." + stageAdapterKey) == ""
            StorageUtil.SetStringValue(None, "PDV.V3.QR.StageAdapterCatalog." + stageAdapterKey, catalogFile)
            StorageUtil.StringListAdd(None, INDEXED_STAGE_ADAPTER_KEYS_KEY, stageAdapterKey, False)
        endIf
        stageAdapterIndex += 1
    endWhile
EndFunction

Int Function ResolveQuestStage(Quest sourceQuest, Int physicalStage)
    if !sourceQuest
        return physicalStage
    endIf
    Int runtimeFormId = sourceQuest.GetFormID()
    String sourcePlugin = StorageUtil.GetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId)
    Int sourceFormId = StorageUtil.GetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId, -1)
    String stageAdapterKey = sourcePlugin + "|" + sourceFormId + "|" + physicalStage
    String adapterFile = StorageUtil.GetStringValue(None, "PDV.V3.QR.StageAdapterCatalog." + stageAdapterKey)
    String adapterPrefix = "stageAdapter." + stageAdapterKey + "."
    if sourcePlugin != "" && adapterFile != ""
        Int mappedStage = ResolveAdapterSelector(adapterFile, adapterPrefix)
        if mappedStage > 0
            return mappedStage
        endIf
    endIf
    return physicalStage
EndFunction

Int Function ResolveAdapterSelector(String adapterFile, String adapterPrefix)
    String selectorPlugin = JsonUtil.GetStringValue(adapterFile, adapterPrefix + "selectorPlugin")
    Int selectorFormId = JsonUtil.GetIntValue(adapterFile, adapterPrefix + "selectorFormId")
    if selectorPlugin == "" || Game.GetModByName(selectorPlugin) == 255
        return 0
    endIf
    Int selectorValue = 0
    String selectorKind = JsonUtil.GetStringValue(adapterFile, adapterPrefix + "selectorKind")
    if selectorKind == "global"
        GlobalVariable selectorGlobal = Game.GetFormFromFile(selectorFormId, selectorPlugin) as GlobalVariable
        if !selectorGlobal
            return 0
        endIf
        selectorValue = selectorGlobal.GetValueInt()
    elseIf selectorKind == "player_item_count"
        Form selectorItem = Game.GetFormFromFile(selectorFormId, selectorPlugin)
        Actor selectorPlayer = Game.GetPlayer()
        if !selectorItem || !selectorPlayer
            return 0
        endIf
        if selectorPlayer.GetItemCount(selectorItem) > 0
            selectorValue = 1
        endIf
    else
        return 0
    endIf
    Int valueIndex = 0
    Int valueCount = JsonUtil.IntListCount(adapterFile, adapterPrefix + "selectorValues")
    while valueIndex < valueCount
        if JsonUtil.IntListGet(adapterFile, adapterPrefix + "selectorValues", valueIndex) == selectorValue
            return JsonUtil.IntListGet(adapterFile, adapterPrefix + "targetStages", valueIndex)
        endIf
        valueIndex += 1
    endWhile
    return 0
EndFunction

Bool Function SubmitSemanticEvent(String sourceId, String eventId, Form sourceForm = None)
    if sourceId == "" || eventId == ""
        return False
    endIf
    String semanticKey = sourceId + "|" + eventId
    String catalogFile = StorageUtil.GetStringValue(None, "PDV.V3.QR.SemanticCatalog." + semanticKey)
    if catalogFile == ""
        TraceQuestReactionQueue("REJECT rejected unknown semantic event " + semanticKey)
        return False
    endIf
    return QueueResolvedReactionJob(catalogFile, "semantic." + semanticKey + ".", semanticKey, sourceForm, semanticKey, StorageUtil.GetStringValue(None, "PDV.V3.QR.SemanticSourceName." + semanticKey))
EndFunction

String Function GetStatusLine()
    Int pending = StorageUtil.StringListCount(None, QUEUE_IDS_KEY)
    if pending <= 0
        return "idle"
    endIf
    String jobId = StorageUtil.StringListGet(None, QUEUE_IDS_KEY, 0)
    String prefix = JOB_PREFIX + jobId + "."
    if StorageUtil.GetIntValue(None, prefix + "BuildComplete") != 1
        return "pending=" + pending + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " build=" + StorageUtil.GetIntValue(None, prefix + "BuildIndex") + "/" + StorageUtil.GetIntValue(None, prefix + "SourceCellCount")
    endIf
    return "pending=" + pending + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + StorageUtil.GetIntValue(None, prefix + "CellIndex") + "/" + StorageUtil.GetIntValue(None, prefix + "CellCount")
EndFunction

String Function GetCompatibilityDetail()
    return "interface=" + INTERFACE_VERSION + "; catalogs=" + _loadedCatalogCount + "; loaded=" + _loadedSourceCount + "; active=" + _activeSourceCount + "; inactive=" + _inactiveSourceCount + "; rejected=" + _rejectedSourceCount
EndFunction

; Development-only probes stay on the module that owns catalog and queue state.
String Function DebugReloadCatalog()
    RefreshCatalogSources()
    Int questKeyCount = StorageUtil.StringListCount(None, INDEXED_QUEST_KEYS_KEY)
    Int semanticKeyCount = StorageUtil.StringListCount(None, INDEXED_SEMANTIC_KEYS_KEY)
    return "Quest catalogs reloaded.\nQuest keys: " + questKeyCount + ".\nSemantic keys: " + semanticKeyCount + ".\n" + GetCompatibilityDetail()
EndFunction

String Function DebugSubmitQuestStage(Int questFormId, String pluginName, Int stageValue, String label)
    DebugReloadCatalog()
    Quest sourceQuest = Game.GetFormFromFile(questFormId, pluginName) as Quest
    if !sourceQuest
        return label + ": quest not found in " + pluginName + "."
    endIf
    Bool accepted = SubmitQuestStage(sourceQuest, stageValue, "debug_" + label)
    if !accepted
        return label + ": no runnable cell was queued. " + GetStatusLine()
    endIf
    return label + ": queued. " + GetStatusLine() + ". Wait for QR_QUEUE COMPLETE."
EndFunction

String Function DebugQueuePerformanceSweep()
    DebugReloadCatalog()
    Quest mq101 = Game.GetFormFromFile(0x0003372B, "Skyrim.esm") as Quest
    Quest mq105 = Game.GetFormFromFile(0x000242BA, "Skyrim.esm") as Quest
    Quest mq106 = Game.GetFormFromFile(0x00032926, "Skyrim.esm") as Quest
    Quest mq206 = Game.GetFormFromFile(0x00036193, "Skyrim.esm") as Quest
    if !mq101 || !mq105 || !mq106 || !mq206
        return "Quest Reaction Performance Sweep could not resolve all vanilla quests."
    endIf
    SubmitQuestStage(mq101, 150, "debug_qr_perf_mq101")
    SubmitQuestStage(mq105, 160, "debug_qr_perf_mq105")
    SubmitQuestStage(mq106, 200, "debug_qr_perf_mq106")
    SubmitQuestStage(mq206, 220, "debug_qr_perf_mq206")
    TraceQuestReactionQueue("SWEEP queued " + GetStatusLine())
    return "Quest Reaction Performance Sweep queued. Wait for QR_QUEUE COMPLETE markers."
EndFunction

Function EnsureQuestReactionQueueRunning()
    if HasQueuedQuestReactionJobs() && !_sliceActive && StorageUtil.GetIntValue(None, QUEUE_UPDATE_ARMED_KEY) != 1
        StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 1)
        RegisterForSingleUpdate(QUEST_REACTION_QUEUE_TICK_SECONDS)
    endIf
EndFunction

Event OnUpdate()
    StorageUtil.SetIntValue(None, QUEUE_UPDATE_ARMED_KEY, 0)
    if _sliceActive
        TraceQuestReactionQueue("OVERLAP suppressed; active slice retains queue ownership")
        return
    endIf
    _sliceActive = True
    Bool hasMore = ProcessQuestReactionQueueSlice()
    _sliceActive = False
    if hasMore
        EnsureQuestReactionQueueRunning()
    endIf
EndEvent

String Function AppendSnapshotToken(String existingCsv, String nextToken)
    if existingCsv == ""
        return nextToken
    endIf
    return existingCsv + "|" + nextToken
EndFunction

Bool Function QueueQuestReactionJob(Quest sourceQuest, Int stageValue, String logicalEventId = "")
    if !sourceQuest || !PDV_Manager
        return False
    endIf

    Int runtimeFormId = sourceQuest.GetFormID()
    Int localFormId = StorageUtil.GetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId, -1)
    String sourcePlugin = StorageUtil.GetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId)
    if sourcePlugin == "" || localFormId < 0 || Game.GetModByName(sourcePlugin) == 255
        return False
    endIf
    String reactionKey = sourcePlugin + "|" + localFormId + "|" + stageValue
    String matrixFile = StorageUtil.GetStringValue(None, "PDV.V3.QR.CellCatalog." + reactionKey)
    if matrixFile == ""
        return False
    endIf
    return QueueResolvedReactionJob(matrixFile, "quest." + reactionKey + ".", reactionKey, sourceQuest as Form, logicalEventId, StorageUtil.GetStringValue(None, "PDV.V3.QR.CellSourceName." + reactionKey), sourcePlugin, localFormId)
EndFunction

Bool Function QueueResolvedReactionJob(String matrixFile, String cellPrefix, String reactionKey, Form sourceForm, String logicalEventId = "", String sourceModName = "", String metaPlugin = "", Int metaLocalFormId = -1)
    if matrixFile == "" || cellPrefix == "" || reactionKey == "" || !PDV_Manager
        return False
    endIf
    Float ingressStartedRealTime = Utility.GetCurrentRealTime()

    Int sourceCellCount = JsonUtil.StringListCount(matrixFile, cellPrefix + "deities")
    if sourceCellCount <= 0 || JsonUtil.StringListCount(matrixFile, cellPrefix + "valences") != sourceCellCount || JsonUtil.StringListCount(matrixFile, cellPrefix + "intensities") != sourceCellCount || JsonUtil.StringListCount(matrixFile, cellPrefix + "magnitudes") != sourceCellCount || JsonUtil.StringListCount(matrixFile, cellPrefix + "tags") != sourceCellCount
        TraceQuestReactionQueue("REJECT rejected malformed reaction " + reactionKey)
        return False
    endIf
    if IsQuestReactionQueued(reactionKey)
        TraceQuestReactionQueue("COALESCE coalesced queued " + reactionKey)
        return False
    endIf
    if StorageUtil.StringListCount(None, QUEUE_IDS_KEY) >= QUEST_REACTION_QUEUE_MAX_PENDING
        TraceQuestReactionQueue("OVERFLOW rejected " + reactionKey + " pending=" + StorageUtil.StringListCount(None, QUEUE_IDS_KEY))
        return False
    endIf
    if ShouldSuppressDuplicateQuestReaction(reactionKey)
        TraceQuestReactionQueue("COALESCE coalesced recent " + reactionKey)
        return False
    endIf

    Int metaEligible = 0
    if metaPlugin != "" && metaLocalFormId >= 0
        String metaDoneKey = "PDV.V3.QR.Meta.Done." + metaPlugin + "|" + metaLocalFormId
        if StorageUtil.GetIntValue(None, metaDoneKey) != 1
            StorageUtil.SetIntValue(None, metaDoneKey, 1)
            metaEligible = 1
        endIf
    endIf

    Int sequence = StorageUtil.AdjustIntValue(None, QUEUE_SEQUENCE_KEY, 1)
    String jobId = "v3qr_" + sequence
    String prefix = JOB_PREFIX + jobId + "."
    StorageUtil.StringListAdd(None, QUEUE_IDS_KEY, jobId, True)
    StorageUtil.FormListAdd(None, QUEUE_FORMS_KEY, sourceForm, True)
    StorageUtil.SetStringValue(None, prefix + "ReactionKey", reactionKey)
    StorageUtil.SetStringValue(None, prefix + "LogicalEventId", logicalEventId)
    StorageUtil.SetStringValue(None, prefix + "MatrixFile", matrixFile)
    StorageUtil.SetStringValue(None, prefix + "CellPrefix", cellPrefix)
    StorageUtil.SetStringValue(None, prefix + "DeitiesCsv", "")
    StorageUtil.SetStringValue(None, prefix + "ValencesCsv", "")
    StorageUtil.SetStringValue(None, prefix + "IntensitiesCsv", "")
    StorageUtil.SetStringValue(None, prefix + "MagnitudesCsv", "")
    StorageUtil.SetStringValue(None, prefix + "TagsCsv", "")
    StorageUtil.SetStringValue(None, prefix + "SourceModName", sourceModName)
    StorageUtil.SetIntValue(None, prefix + "CellCount", 0)
    StorageUtil.SetIntValue(None, prefix + "CellIndex", 0)
    StorageUtil.SetIntValue(None, prefix + "SourceCellCount", sourceCellCount)
    StorageUtil.SetIntValue(None, prefix + "SkippedCellCount", 0)
    StorageUtil.SetIntValue(None, prefix + "MetaRunnableCount", 0)
    StorageUtil.SetIntValue(None, prefix + "BuildIndex", 0)
    StorageUtil.SetIntValue(None, prefix + "BuildPhase", 0)
    StorageUtil.SetIntValue(None, prefix + "BuildComplete", 0)
    StorageUtil.SetIntValue(None, prefix + "MetaBuildIndex", 0)
    StorageUtil.SetIntValue(None, prefix + "MetaWheelEligible", 0)
    StorageUtil.SetIntValue(None, prefix + "Started", 0)
    StorageUtil.SetIntValue(None, prefix + "MetaEligible", metaEligible)
    if metaEligible == 1
        StorageUtil.SetIntValue(None, prefix + "MetaTwilight", BoolToInt(IsTwilightWindow()))
        StorageUtil.SetIntValue(None, prefix + "MetaNight", BoolToInt(IsNightWindow()))
        StorageUtil.SetIntValue(None, prefix + "MetaNocturnalTheft", BoolToInt(StorageUtil.GetFloatValue(None, "PDV.Meta.LastTheftTime") > StorageUtil.GetFloatValue(None, "PDV.Meta.LastFulfillTime")))
        StorageUtil.SetIntValue(None, prefix + "MetaOutdoors", BoolToInt(IsPlayerOutdoors()))
    endIf
    StorageUtil.SetFloatValue(None, prefix + "QueuedGameTime", Utility.GetCurrentGameTime())
    StorageUtil.SetFloatValue(None, prefix + "EnqueuedRealTime", Utility.GetCurrentRealTime())
    Float admissionMs = (Utility.GetCurrentRealTime() - ingressStartedRealTime) * 1000.0
    StorageUtil.SetFloatValue(None, prefix + "AdmissionMs", admissionMs)
    StorageUtil.SetStringValue(None, "PDV.V3.QR.LastKey", reactionKey)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastCellCount", 0)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastSourceCellCount", sourceCellCount)
    TraceQuestReactionQueue("ENQUEUE queued " + jobId + " key=" + reactionKey + " cells=0 sourceCells=" + sourceCellCount + " materialized=0 admissionMs=" + admissionMs + " pending=" + StorageUtil.StringListCount(None, QUEUE_IDS_KEY))
    EnsureQuestReactionQueueRunning()
    return True
EndFunction

Function AppendBuiltQuestReactionCell(String prefix, String deityName, String valence, String intensity, String magnitude, String sourceTag, Bool isMeta = False)
    StorageUtil.SetStringValue(None, prefix + "DeitiesCsv", AppendSnapshotToken(StorageUtil.GetStringValue(None, prefix + "DeitiesCsv"), deityName))
    StorageUtil.SetStringValue(None, prefix + "ValencesCsv", AppendSnapshotToken(StorageUtil.GetStringValue(None, prefix + "ValencesCsv"), valence))
    StorageUtil.SetStringValue(None, prefix + "IntensitiesCsv", AppendSnapshotToken(StorageUtil.GetStringValue(None, prefix + "IntensitiesCsv"), intensity))
    StorageUtil.SetStringValue(None, prefix + "MagnitudesCsv", AppendSnapshotToken(StorageUtil.GetStringValue(None, prefix + "MagnitudesCsv"), magnitude))
    StorageUtil.SetStringValue(None, prefix + "TagsCsv", AppendSnapshotToken(StorageUtil.GetStringValue(None, prefix + "TagsCsv"), sourceTag))
    Int cellCount = StorageUtil.GetIntValue(None, prefix + "CellCount")
    StorageUtil.SetIntValue(None, prefix + "CellCount", cellCount + 1)
    if isMeta
        StorageUtil.AdjustIntValue(None, prefix + "MetaRunnableCount", 1)
    endIf
EndFunction

Function CompleteQuestReactionBuild(String jobId, String prefix)
    StorageUtil.SetIntValue(None, prefix + "BuildComplete", 1)
    Int cellCount = StorageUtil.GetIntValue(None, prefix + "CellCount")
    Int sourceCellCount = StorageUtil.GetIntValue(None, prefix + "SourceCellCount")
    Int skippedCellCount = StorageUtil.GetIntValue(None, prefix + "SkippedCellCount")
    Int metaRunnableCount = StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount")
    Float materializeMs = (Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(None, prefix + "EnqueuedRealTime")) * 1000.0
    StorageUtil.SetFloatValue(None, prefix + "MaterializeMs", materializeMs)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastCellCount", cellCount)
    TraceQuestReactionQueue("BUILD completed " + jobId + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + cellCount + " sourceCells=" + sourceCellCount + " skipped=" + skippedCellCount + " meta=" + metaRunnableCount + " materializeMs=" + materializeMs)
EndFunction

Bool Function ProcessQuestReactionMetaBuildUnit(String jobId, String prefix, String matrixFile, String cellPrefix)
    if StorageUtil.GetIntValue(None, prefix + "MetaEligible") != 1
        CompleteQuestReactionBuild(jobId, prefix)
        return True
    endIf

    Int metaIndex = StorageUtil.GetIntValue(None, prefix + "MetaBuildIndex")
    if metaIndex == 0
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.gold") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Z'en") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Z'en", "+", "zen", "meta")
            AppendBuiltQuestReactionCell(prefix, "Z'en", "+", "zen", "meta", "meta_zen_wage", True)
        endIf
    elseIf metaIndex == 1
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Julianos") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Julianos", "+", "julianos", "meta")
            AppendBuiltQuestReactionCell(prefix, "Julianos", "+", "julianos", "meta", "meta_julianos_wisdom", True)
        endIf
    elseIf metaIndex == 2
        if (JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid") == 1 || StorageUtil.GetIntValue(None, prefix + "MetaTwilight") == 1) && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Azura") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Azura", "+", "azura", "meta")
            AppendBuiltQuestReactionCell(prefix, "Azura", "+", "azura", "meta", "meta_azura_threshold", True)
        endIf
    elseIf metaIndex == 3
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Nocturnal") != 1
            if StorageUtil.GetIntValue(None, prefix + "MetaNocturnalTheft") == 1 && PDV_Manager.ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalTheft", "meta")
                AppendBuiltQuestReactionCell(prefix, "Nocturnal", "+", "nocturnalTheft", "meta", "meta_nocturnal_herway", True)
            elseIf StorageUtil.GetIntValue(None, prefix + "MetaNight") == 1 && PDV_Manager.ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalNight", "meta")
                AppendBuiltQuestReactionCell(prefix, "Nocturnal", "+", "nocturnalNight", "meta", "meta_nocturnal_dark", True)
            endIf
        endIf
    elseIf metaIndex == 4
        if StorageUtil.GetIntValue(None, prefix + "MetaOutdoors") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Khenarthi") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Khenarthi", "+", "khenarthi", "meta")
            AppendBuiltQuestReactionCell(prefix, "Khenarthi", "+", "khenarthi", "meta", "meta_khenarthi_road", True)
        endIf
    elseIf metaIndex == 5
        Int wheelCount = StorageUtil.AdjustIntValue(None, "PDV.V3.QR.Meta.QuestCount", 1)
        if wheelCount > 0 && wheelCount % 10 == 0
            StorageUtil.SetIntValue(None, prefix + "MetaWheelEligible", 1)
        endIf
    elseIf metaIndex == 6
        if StorageUtil.GetIntValue(None, prefix + "MetaWheelEligible") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Akatosh") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Akatosh", "+", "wheel", "meta")
            AppendBuiltQuestReactionCell(prefix, "Akatosh", "+", "wheel", "meta", "meta_akatosh_wheel", True)
        endIf
    elseIf metaIndex == 7
        if StorageUtil.GetIntValue(None, prefix + "MetaWheelEligible") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Xarxes") != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Xarxes", "+", "wheel", "meta")
            AppendBuiltQuestReactionCell(prefix, "Xarxes", "+", "wheel", "meta", "meta_xarxes_record", True)
        endIf
    endIf

    metaIndex += 1
    StorageUtil.SetIntValue(None, prefix + "MetaBuildIndex", metaIndex)
    if metaIndex >= 8
        CompleteQuestReactionBuild(jobId, prefix)
    endIf
    return True
EndFunction

Bool Function ProcessQuestReactionBuildUnit(String jobId, String prefix)
    String matrixFile = StorageUtil.GetStringValue(None, prefix + "MatrixFile")
    String cellPrefix = StorageUtil.GetStringValue(None, prefix + "CellPrefix")
    if matrixFile == "" || cellPrefix == "" || !JsonUtil.JsonExists(matrixFile) || !JsonUtil.IsGood(matrixFile)
        RejectHeadJob(jobId, prefix, "catalog unavailable during materialization")
        return False
    endIf

    Int buildPhase = StorageUtil.GetIntValue(None, prefix + "BuildPhase")
    if buildPhase == 0
        Int buildIndex = StorageUtil.GetIntValue(None, prefix + "BuildIndex")
        Int sourceCellCount = StorageUtil.GetIntValue(None, prefix + "SourceCellCount")
        if buildIndex < 0 || buildIndex > sourceCellCount
            RejectHeadJob(jobId, prefix, "corrupt build cursor")
            return False
        endIf
        if buildIndex < sourceCellCount
            String deityName = JsonUtil.StringListGet(matrixFile, cellPrefix + "deities", buildIndex)
            String valence = JsonUtil.StringListGet(matrixFile, cellPrefix + "valences", buildIndex)
            String intensity = JsonUtil.StringListGet(matrixFile, cellPrefix + "intensities", buildIndex)
            String magnitude = JsonUtil.StringListGet(matrixFile, cellPrefix + "magnitudes", buildIndex)
            String sourceTag = JsonUtil.StringListGet(matrixFile, cellPrefix + "tags", buildIndex)
            if PDV_Manager.ShouldQueueQuestReactionCell(deityName, valence, intensity, magnitude)
                AppendBuiltQuestReactionCell(prefix, deityName, valence, intensity, magnitude, sourceTag)
            endIf
            buildIndex += 1
            StorageUtil.SetIntValue(None, prefix + "BuildIndex", buildIndex)
        endIf
        if buildIndex >= sourceCellCount
            StorageUtil.SetIntValue(None, prefix + "SkippedCellCount", sourceCellCount - StorageUtil.GetIntValue(None, prefix + "CellCount"))
            StorageUtil.SetIntValue(None, prefix + "BuildPhase", 1)
        endIf
        return True
    elseIf buildPhase == 1
        return ProcessQuestReactionMetaBuildUnit(jobId, prefix, matrixFile, cellPrefix)
    endIf

    RejectHeadJob(jobId, prefix, "corrupt build phase")
    return False
EndFunction

Bool Function HasQueuedQuestReactionJobs()
    return StorageUtil.StringListCount(None, QUEUE_IDS_KEY) > 0
EndFunction

Bool Function IsQuestReactionQueued(String reactionKey)
    Int queueIndex = 0
    Int count = StorageUtil.StringListCount(None, QUEUE_IDS_KEY)
    while queueIndex < count
        String jobId = StorageUtil.StringListGet(None, QUEUE_IDS_KEY, queueIndex)
        if StorageUtil.GetStringValue(None, JOB_PREFIX + jobId + ".ReactionKey") == reactionKey
            return True
        endIf
        queueIndex += 1
    endWhile
    return False
EndFunction

Bool Function ShouldSuppressDuplicateQuestReaction(String reactionKey)
    String timeKey = "PDV.V3.QR.Recent.Time." + reactionKey
    String seenKey = "PDV.V3.QR.Recent.Seen." + reactionKey
    Float nowTime = Utility.GetCurrentGameTime()
    if StorageUtil.GetIntValue(None, seenKey) == 1
        Float elapsed = nowTime - StorageUtil.GetFloatValue(None, timeKey)
        if elapsed >= 0.0 && elapsed < QUEST_REACTION_DUPLICATE_WINDOW_DAYS
            return True
        endIf
    endIf
    StorageUtil.SetFloatValue(None, timeKey, nowTime)
    StorageUtil.SetIntValue(None, seenKey, 1)
    return False
EndFunction

Bool Function ProcessQuestReactionQueueSlice()
    if !HasQueuedQuestReactionJobs() || !PDV_Manager
        return False
    endIf
    String jobId = StorageUtil.StringListGet(None, QUEUE_IDS_KEY, 0)
    String prefix = JOB_PREFIX + jobId + "."
    Int processed = 0
    while processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK && StorageUtil.GetIntValue(None, prefix + "BuildComplete") != 1
        if !ProcessQuestReactionBuildUnit(jobId, prefix)
            return HasQueuedQuestReactionJobs()
        endIf
        processed += 1
    endWhile
    if StorageUtil.GetIntValue(None, prefix + "BuildComplete") != 1
        return True
    endIf

    Int cellCount = StorageUtil.GetIntValue(None, prefix + "CellCount")
    Int cellIndex = StorageUtil.GetIntValue(None, prefix + "CellIndex")
    if cellCount < 0 || cellIndex < 0 || cellIndex > cellCount
        RejectHeadJob(jobId, prefix, "corrupt")
        return HasQueuedQuestReactionJobs()
    endIf

    String[] deities
    String[] valences
    String[] intensities
    String[] magnitudes
    String[] tags
    if cellCount > 0
        deities = StringUtil.Split(StorageUtil.GetStringValue(None, prefix + "DeitiesCsv"), "|")
        valences = StringUtil.Split(StorageUtil.GetStringValue(None, prefix + "ValencesCsv"), "|")
        intensities = StringUtil.Split(StorageUtil.GetStringValue(None, prefix + "IntensitiesCsv"), "|")
        magnitudes = StringUtil.Split(StorageUtil.GetStringValue(None, prefix + "MagnitudesCsv"), "|")
        tags = StringUtil.Split(StorageUtil.GetStringValue(None, prefix + "TagsCsv"), "|")
        if deities.Length != cellCount || valences.Length != cellCount || intensities.Length != cellCount || magnitudes.Length != cellCount || tags.Length != cellCount
            RejectHeadJob(jobId, prefix, "snapshot mismatch")
            return HasQueuedQuestReactionJobs()
        endIf
    endIf

    ; A tick that spent its full budget materializing cells must not open an
    ; empty scoring transaction. START means the first apply slice can begin.
    if processed >= QUEST_REACTION_QUEUE_CELLS_PER_TICK && cellCount > 0
        return True
    endIf

    if StorageUtil.GetIntValue(None, prefix + "Started") != 1
        StorageUtil.SetIntValue(None, prefix + "Started", 1)
        PDV_Manager.PrepareQueuedQuestReactionTransaction()
        TraceQuestReactionQueue("START started " + jobId + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + cellCount + " sourceCells=" + StorageUtil.GetIntValue(None, prefix + "SourceCellCount") + " skipped=" + StorageUtil.GetIntValue(None, prefix + "SkippedCellCount") + " meta=" + StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount"))
    endIf

    Form sourceForm = StorageUtil.FormListGet(None, QUEUE_FORMS_KEY, 0)
    PDV_Manager.BeginQueuedQuestReactionSlice()
    while processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK && cellIndex < cellCount
        PDV_Manager.ApplyQueuedQuestReactionCell(deities[cellIndex], valences[cellIndex], intensities[cellIndex], magnitudes[cellIndex], tags[cellIndex], sourceForm)
        cellIndex += 1
        ; Keep the persisted cursor adjacent to the landed cell. A save may
        ; suspend this stack, so checkpoint each delivery rather than the slice.
        StorageUtil.SetIntValue(None, prefix + "CellIndex", cellIndex)
        processed += 1
    endWhile
    PDV_Manager.EndQueuedQuestReactionSlice()
    if cellIndex < cellCount
        return True
    endIf

    if StorageUtil.GetIntValue(None, prefix + "MetaEligible") == 1
        StorageUtil.SetFloatValue(None, "PDV.Meta.LastFulfillTime", StorageUtil.GetFloatValue(None, prefix + "QueuedGameTime"))
    endIf
    String reactionKey = StorageUtil.GetStringValue(None, prefix + "ReactionKey")
    String sourceModName = StorageUtil.GetStringValue(None, prefix + "SourceModName")
    Int sourceCellCount = StorageUtil.GetIntValue(None, prefix + "SourceCellCount")
    Int skippedCellCount = StorageUtil.GetIntValue(None, prefix + "SkippedCellCount")
    Int metaRunnableCount = StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount")
    PDV_Manager.FinalizeQueuedQuestReaction(sourceModName, reactionKey)
    Float elapsed = Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(None, prefix + "EnqueuedRealTime")
    StorageUtil.SetStringValue(None, "PDV.V3.QR.LastKey", reactionKey)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastCellCount", cellCount)
    TraceQuestReactionQueue("COMPLETE completed " + jobId + " key=" + reactionKey + " cells=" + cellCount + " sourceCells=" + sourceCellCount + " skipped=" + skippedCellCount + " meta=" + metaRunnableCount + " elapsed=" + elapsed)
    RemoveHeadJob()
    return HasQueuedQuestReactionJobs()
EndFunction

Function RejectHeadJob(String jobId, String prefix, String reason)
    TraceQuestReactionQueue("REJECT rejected " + reason + " " + jobId)
    RemoveHeadJob()
EndFunction

Function RemoveHeadJob()
    if !HasQueuedQuestReactionJobs()
        return
    endIf
    String jobId = StorageUtil.StringListGet(None, QUEUE_IDS_KEY, 0)
    StorageUtil.StringListRemoveAt(None, QUEUE_IDS_KEY, 0)
    StorageUtil.FormListRemoveAt(None, QUEUE_FORMS_KEY, 0)
    StorageUtil.ClearAllPrefix(JOB_PREFIX + jobId + ".")
EndFunction

Bool Function IsTwilightWindow()
    Float nowTime = Utility.GetCurrentGameTime()
    Float hourOfDay = (nowTime - ((nowTime as Int) as Float)) * 24.0
    return (hourOfDay >= 5.0 && hourOfDay < 7.0) || (hourOfDay >= 17.0 && hourOfDay < 19.0)
EndFunction

Bool Function IsNightWindow()
    Float nowTime = Utility.GetCurrentGameTime()
    Float hourOfDay = (nowTime - ((nowTime as Int) as Float)) * 24.0
    return hourOfDay >= 20.0 || hourOfDay < 6.0
EndFunction

Bool Function IsPlayerOutdoors()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return False
    endIf
    Cell parentCell = playerRef.GetParentCell()
    return parentCell && !parentCell.IsInterior()
EndFunction

Int Function BoolToInt(Bool value)
    if value
        return 1
    endIf
    return 0
EndFunction

Function TraceQuestReactionQueue(String text)
    if PDV_Manager && PDV_Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV][QR_QUEUE] " + text)
    endIf
EndFunction
