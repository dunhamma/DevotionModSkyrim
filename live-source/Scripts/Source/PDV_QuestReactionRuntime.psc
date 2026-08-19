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
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.gold") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Z'en") != 1 && ShouldQueueQuestReactionCell("Z'en", "+", "zen", "meta")
            AppendBuiltQuestReactionCell(prefix, "Z'en", "+", "zen", "meta", "meta_zen_wage", True)
        endIf
    elseIf metaIndex == 1
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Julianos") != 1 && ShouldQueueQuestReactionCell("Julianos", "+", "julianos", "meta")
            AppendBuiltQuestReactionCell(prefix, "Julianos", "+", "julianos", "meta", "meta_julianos_wisdom", True)
        endIf
    elseIf metaIndex == 2
        if (JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid") == 1 || StorageUtil.GetIntValue(None, prefix + "MetaTwilight") == 1) && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Azura") != 1 && ShouldQueueQuestReactionCell("Azura", "+", "azura", "meta")
            AppendBuiltQuestReactionCell(prefix, "Azura", "+", "azura", "meta", "meta_azura_threshold", True)
        endIf
    elseIf metaIndex == 3
        if JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Nocturnal") != 1
            if StorageUtil.GetIntValue(None, prefix + "MetaNocturnalTheft") == 1 && ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalTheft", "meta")
                AppendBuiltQuestReactionCell(prefix, "Nocturnal", "+", "nocturnalTheft", "meta", "meta_nocturnal_herway", True)
            elseIf StorageUtil.GetIntValue(None, prefix + "MetaNight") == 1 && ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalNight", "meta")
                AppendBuiltQuestReactionCell(prefix, "Nocturnal", "+", "nocturnalNight", "meta", "meta_nocturnal_dark", True)
            endIf
        endIf
    elseIf metaIndex == 4
        if StorageUtil.GetIntValue(None, prefix + "MetaOutdoors") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Khenarthi") != 1 && ShouldQueueQuestReactionCell("Khenarthi", "+", "khenarthi", "meta")
            AppendBuiltQuestReactionCell(prefix, "Khenarthi", "+", "khenarthi", "meta", "meta_khenarthi_road", True)
        endIf
    elseIf metaIndex == 5
        Int wheelCount = StorageUtil.AdjustIntValue(None, "PDV.V3.QR.Meta.QuestCount", 1)
        if wheelCount > 0 && wheelCount % 10 == 0
            StorageUtil.SetIntValue(None, prefix + "MetaWheelEligible", 1)
        endIf
    elseIf metaIndex == 6
        if StorageUtil.GetIntValue(None, prefix + "MetaWheelEligible") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Akatosh") != 1 && ShouldQueueQuestReactionCell("Akatosh", "+", "wheel", "meta")
            AppendBuiltQuestReactionCell(prefix, "Akatosh", "+", "wheel", "meta", "meta_akatosh_wheel", True)
        endIf
    elseIf metaIndex == 7
        if StorageUtil.GetIntValue(None, prefix + "MetaWheelEligible") == 1 && JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Xarxes") != 1 && ShouldQueueQuestReactionCell("Xarxes", "+", "wheel", "meta")
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
            if ShouldQueueQuestReactionCell(deityName, valence, intensity, magnitude)
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
        PrepareQueuedQuestReactionTransaction()
        TraceQuestReactionQueue("START started " + jobId + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + cellCount + " sourceCells=" + StorageUtil.GetIntValue(None, prefix + "SourceCellCount") + " skipped=" + StorageUtil.GetIntValue(None, prefix + "SkippedCellCount") + " meta=" + StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount"))
    endIf

    Form sourceForm = StorageUtil.FormListGet(None, QUEUE_FORMS_KEY, 0)
    BeginQueuedQuestReactionSlice()
    while processed < QUEST_REACTION_QUEUE_CELLS_PER_TICK && cellIndex < cellCount
        ApplyQueuedQuestReactionCell(deities[cellIndex], valences[cellIndex], intensities[cellIndex], magnitudes[cellIndex], tags[cellIndex], sourceForm)
        cellIndex += 1
        ; Keep the persisted cursor adjacent to the landed cell. A save may
        ; suspend this stack, so checkpoint each delivery rather than the slice.
        StorageUtil.SetIntValue(None, prefix + "CellIndex", cellIndex)
        processed += 1
    endWhile
    EndQueuedQuestReactionSlice()
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
    FinalizeQueuedQuestReaction(sourceModName, reactionKey)
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

; ============================================================================
; QUEST-REACTION SUBSYSTEM -- moved verbatim from PDV__ManagerQuest (Phase B).
; Queue machinery + reaction-resolution primitives + surfaces + the 4 queue-state
; accessors, one cohesive module owning its own state. Manager-owned functions/refs
; qualify through PDV_Manager; consumers reach these via
; Manager.PDV_QuestReactionRuntimeService.X (ESP property consolidation is a later phase).
; ============================================================================

; -- QR-owned queue/surface state (moved from PDV__ManagerQuest) --
String _qrSurfPosNamesCsv = ""
String _qrSurfNegNamesCsv = ""
Int _qrSurfPosCount = 0
Int _qrSurfNegCount = 0
Float _qrSurfBestPosAmount = 0.0
Float _qrSurfBestNegAmount = 0.0
String _qrSurfBestPosName = ""
String _qrSurfBestNegName = ""
String _qrSurfBestPosSymbol = ""
String _qrSurfBestNegSymbol = ""
Bool _qrSurfMilestone = False
Bool _qrQueueTransactionActive = False
Bool _qrQueueNeedsCurseRefresh = False
Bool _qrQueueNeedsBretonRewardSync = False
String _qrQueueSurfPosNamesCsv = ""
String _qrQueueSurfNegNamesCsv = ""
Int _qrQueueSurfPosCount = 0
Int _qrQueueSurfNegCount = 0
Float _qrQueueSurfBestPosAmount = 0.0
Float _qrQueueSurfBestNegAmount = 0.0
String _qrQueueSurfBestPosName = ""
String _qrQueueSurfBestNegName = ""
String _qrQueueSurfBestPosSymbol = ""
String _qrQueueSurfBestNegSymbol = ""
Bool _qrQueueSurfMilestone = False
String _qrQueueBroadPool = ""
Float _qrQueueBroadBestPositive = 0.0
Float _qrQueueBroadWorstNegative = 0.0

; V3 Quest Reaction callback seam. The runtime owns catalogs, persistence,
; scheduling, and job lifecycle; Manager owns scoring and final presentation.
Bool Function ShouldQueueQuestReactionCell(String deityName, String valence, String intensity, String magnitude)
    return !IsQueuedQuestReactionCellCheapSkip(deityName, valence, intensity, magnitude)
EndFunction

Function PrepareQueuedQuestReactionTransaction()
    ResetQueuedQuestReactionSurface()
    _qrQueueNeedsCurseRefresh = False
    _qrQueueNeedsBretonRewardSync = False
    _qrQueueBroadPool = PDV_Manager.LedgerRuntime.GetActiveBroadPantheonPoolId()
    _qrQueueBroadBestPositive = 0.0
    _qrQueueBroadWorstNegative = 0.0
EndFunction

Function BeginQueuedQuestReactionSlice()
    _qrQueueTransactionActive = True
EndFunction

Function ApplyQueuedQuestReactionCell(String deityName, String valence, String intensity, String magnitude, String sourceTag, Form sourceForm)
    PDV_Manager.LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, magnitude, sourceTag, False, sourceForm)
EndFunction

Function EndQueuedQuestReactionSlice()
    _qrQueueTransactionActive = False
EndFunction

Function FinalizeQueuedQuestReaction(String sourceModName, String reactionKey)
    _qrQueueTransactionActive = False
    FlushQueuedQuestReactionSurface(sourceModName, reactionKey)
    CommitQueuedQuestReactionBroad(reactionKey)
    if _qrQueueNeedsCurseRefresh
        PDV_Manager.LedgerRuntime.HandleCurseStateRefresh("quest_reaction_queue")
    endIf
    if _qrQueueNeedsBretonRewardSync
        PDV_Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf
    PDV_Manager.RequestPanelRefresh()
EndFunction

Function ApplyQuestReactionFaucet(String faucetKey, Form sourceForm)
    if faucetKey == "" || !JsonUtil.JsonExists(PDV_Manager.QUEST_REACTION_MATRIX_FILE)
        return
    endIf

    String deityName = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".deity")
    if deityName == ""
        return
    endIf

    String valence = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".valence")
    String intensity = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".intensity")
    String magnitude = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".magnitude")
    String sourceTag = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "faucet." + faucetKey + ".tag")
    PDV_Manager.LedgerRuntime.ApplyDeityReaction(deityName, valence, intensity, magnitude, sourceTag, True, sourceForm)

    ; Namira lifesteal: feeding on the dead restores the Namira-pathed faithful. The
    ; old boon's HealRateMult (rate on Requiem's ~0 base) was swallowed; the sustain
    ; is now this event-driven, Requiem-proof heal-on-feed. Tier-gated + daily decay.
    if faucetKey == "Namira.cannibalism"
        PDV_Manager.DaedricRuntime.TryNamiraFeedHeal()
    endIf
EndFunction

Bool Function IsQueuedQuestReactionCellCheapSkip(String deityName, String valence, String intensity, String magnitude)
    PDV_DeityBase deity = GetQuestReactionDeity(deityName)
    if !deity
        return True
    endIf

    Float amount = GetQuestReactionBaseValue(magnitude, intensity)
    if amount == 0.0
        return True
    endIf
    if valence == "-"
        amount = amount * -1.0
    endIf

    String stance = GetQuestReactionStance(deityName, deity)
    if stance == "CURSE"
        return False
    endIf

    ; A named taboo/hostile cell is deliberate displeasure, not background
    ; favor: positive values become stigma and negative values become piety loss.
    ; Keep either form for a deity the player's origin roster can still show even
    ; when a Nord chose the other baseline. Every other cell must be reachable
    ; on the current lane before it enters the persisted worker snapshot.
    if (stance == "TABOO" || stance == "HOSTILE") && PDV_Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, PDV_Manager.GetPlayerOriginRaceIndex())
        return False
    endIf

    return !IsQuestReactionDeityReachable(deity)
EndFunction

Function ResetQuestReactionSurface()
    _qrSurfPosNamesCsv = ""
    _qrSurfNegNamesCsv = ""
    _qrSurfPosCount = 0
    _qrSurfNegCount = 0
    _qrSurfBestPosAmount = 0.0
    _qrSurfBestNegAmount = 0.0
    _qrSurfBestPosName = ""
    _qrSurfBestNegName = ""
    _qrSurfBestPosSymbol = ""
    _qrSurfBestNegSymbol = ""
    _qrSurfMilestone = False
EndFunction

Function AccumulateQuestReactionSurface(PDV_DeityBase deity, Float amount, String magnitude)
    ; A Daedric Prince stays out of Book-of-Days reaction surfaces (and their paired
    ; toast) until it reaches Seeker (25 piety); a still-uncommitted Prince below that
    ; only ever surfaces through the one pre-pact "taken notice" beat. Piety is still
    ; awarded upstream -- this gates DISPLAY only. Off-roster Aedric gods are already
    ; dropped by the reachability gate, so this leaves race-aligned gods untouched.
    PDV_DaedricPathBase daedricSurfacePath = deity as PDV_DaedricPathBase
    if daedricSurfacePath && daedricSurfacePath.GetStoredTier() < PDV_Manager.LedgerRuntime.TIER_SEEKER
        return
    endIf
    if _qrQueueTransactionActive
        AccumulateQueuedQuestReactionSurface(deity, amount, magnitude)
        return
    endIf
    if !deity || amount == 0.0
        return
    endIf
    String deityName = PDV_Manager.GetPublicDeityDisplayName(deity)
    if magnitude == "milestone"
        _qrSurfMilestone = True
    endIf
    if amount > 0.0
        if _qrSurfPosNamesCsv != ""
            _qrSurfPosNamesCsv = _qrSurfPosNamesCsv + "|"
        endIf
        _qrSurfPosNamesCsv = _qrSurfPosNamesCsv + deityName
        _qrSurfPosCount += 1
        if amount > _qrSurfBestPosAmount
            _qrSurfBestPosAmount = amount
            _qrSurfBestPosName = deityName
            _qrSurfBestPosSymbol = PDV_Manager.GetPrismaSymbolForDeity(deity)
        endIf
    else
        if _qrSurfNegNamesCsv != ""
            _qrSurfNegNamesCsv = _qrSurfNegNamesCsv + "|"
        endIf
        _qrSurfNegNamesCsv = _qrSurfNegNamesCsv + deityName
        _qrSurfNegCount += 1
        if amount < _qrSurfBestNegAmount
            _qrSurfBestNegAmount = amount
            _qrSurfBestNegName = deityName
            _qrSurfBestNegSymbol = PDV_Manager.GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

; "Kyne", "Kyne and Mara", "Kyne, Mara and Dibella" from a pipe-joined name list.
String Function JoinQuestSurfaceNames(String namesCsv)
    String[] names = StringUtil.Split(namesCsv, "|")
    Int count = names.Length
    if count <= 0
        return ""
    elseIf count == 1
        return names[0]
    endIf
    String joined = names[0]
    Int i = 1
    while i < count
        if i == count - 1
            joined = joined + " and " + names[i]
        else
            joined = joined + ", " + names[i]
        endIf
        i += 1
    endWhile
    return joined
EndFunction

Function FlushQuestReactionSurface()
    if _qrQueueTransactionActive
        FlushQueuedQuestReactionSurface()
        return
    endIf
    if _qrSurfPosCount == 0 && _qrSurfNegCount == 0
        return
    endIf

    Int nowDay = Utility.GetCurrentGameTime() as Int
    Int bodMagnitude = 1
    if _qrSurfMilestone
        bodMagnitude = 2
    endIf

    if _qrSurfNegCount == 0
        String posMsg = _qrSurfBestPosName + " marks your deed."
        if _qrSurfPosCount == 2
            posMsg = _qrSurfBestPosName + " and 1 other mark your deed."
        elseIf _qrSurfPosCount > 2
            posMsg = _qrSurfBestPosName + " and " + (_qrSurfPosCount - 1) + " others mark your deed."
        endIf
        PDV_Manager.SendPrismaToast(_qrSurfBestPosSymbol, "good", "A deed marked", posMsg)
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfPosNamesCsv) + " marked your deed.", nowDay, "favor.act", _qrSurfBestPosSymbol, False, bodMagnitude, "A deed marked")
    elseIf _qrSurfPosCount == 0
        String negMsg = _qrSurfBestNegName + " takes offense at your deed."
        if _qrSurfNegCount == 2
            negMsg = _qrSurfBestNegName + " and 1 other take offense at your deed."
        elseIf _qrSurfNegCount > 2
            negMsg = _qrSurfBestNegName + " and " + (_qrSurfNegCount - 1) + " others take offense at your deed."
        endIf
        PDV_Manager.SendPrismaToast(_qrSurfBestNegSymbol, "warning", "A deed ill-received", negMsg)
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfNegNamesCsv) + " took offense at your deed.", nowDay, "favor.loss", _qrSurfBestNegSymbol, False, bodMagnitude, "A deed ill-received")
    else
        ; Mixed: lead with the stronger side for tone and symbol.
        Bool positiveLeads = _qrSurfBestPosAmount >= (_qrSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _qrSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _qrSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        PDV_Manager.SendPrismaToast(mixedSymbol, mixedTone, "A deed weighed", _qrSurfBestPosName + " marks your deed; " + _qrSurfBestNegName + " takes offense.")
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrSurfPosNamesCsv) + " marked your deed; " + JoinQuestSurfaceNames(_qrSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, bodMagnitude, "A deed weighed")
    endIf

    ResetQuestReactionSurface()
EndFunction

Function ResetQueuedQuestReactionSurface()
    _qrQueueSurfPosNamesCsv = ""
    _qrQueueSurfNegNamesCsv = ""
    _qrQueueSurfPosCount = 0
    _qrQueueSurfNegCount = 0
    _qrQueueSurfBestPosAmount = 0.0
    _qrQueueSurfBestNegAmount = 0.0
    _qrQueueSurfBestPosName = ""
    _qrQueueSurfBestNegName = ""
    _qrQueueSurfBestPosSymbol = ""
    _qrQueueSurfBestNegSymbol = ""
    _qrQueueSurfMilestone = False
EndFunction

Function AccumulateQueuedQuestReactionSurface(PDV_DeityBase deity, Float amount, String magnitude)
    if !deity || amount == 0.0
        return
    endIf
    String deityName = PDV_Manager.GetPublicDeityDisplayName(deity)
    if magnitude == "milestone"
        _qrQueueSurfMilestone = True
    endIf
    Bool alreadyListed = QueuedQuestReactionSurfaceHasName(deityName)
    if amount > 0.0
        if !alreadyListed
            if _qrQueueSurfPosNamesCsv != ""
                _qrQueueSurfPosNamesCsv = _qrQueueSurfPosNamesCsv + "|"
            endIf
            _qrQueueSurfPosNamesCsv = _qrQueueSurfPosNamesCsv + deityName
            _qrQueueSurfPosCount += 1
        endIf
        if amount > _qrQueueSurfBestPosAmount
            _qrQueueSurfBestPosAmount = amount
            _qrQueueSurfBestPosName = deityName
            _qrQueueSurfBestPosSymbol = PDV_Manager.GetPrismaSymbolForDeity(deity)
        endIf
    else
        if !alreadyListed
            if _qrQueueSurfNegNamesCsv != ""
                _qrQueueSurfNegNamesCsv = _qrQueueSurfNegNamesCsv + "|"
            endIf
            _qrQueueSurfNegNamesCsv = _qrQueueSurfNegNamesCsv + deityName
            _qrQueueSurfNegCount += 1
        endIf
        if amount < _qrQueueSurfBestNegAmount
            _qrQueueSurfBestNegAmount = amount
            _qrQueueSurfBestNegName = deityName
            _qrQueueSurfBestNegSymbol = PDV_Manager.GetPrismaSymbolForDeity(deity)
        endIf
    endIf
EndFunction

Bool Function QueuedQuestReactionSurfaceHasName(String deityName)
    if deityName == ""
        return False
    endIf
    String token = "|" + deityName + "|"
    return StringUtil.Find("|" + _qrQueueSurfPosNamesCsv + "|", token) >= 0 || StringUtil.Find("|" + _qrQueueSurfNegNamesCsv + "|", token) >= 0
EndFunction

Function FlushQueuedQuestReactionSurface(String sourceModName = "", String reactionKey = "")
    if _qrQueueSurfPosCount == 0 && _qrQueueSurfNegCount == 0
        return
    endIf
    String surfaceSourceModName = PDV_Manager.NormalizePublicDeityDisplayText(sourceModName)
    if surfaceSourceModName == "Skyrim.esm" || surfaceSourceModName == "Update.esm" || surfaceSourceModName == "Dawnguard.esm" || surfaceSourceModName == "HearthFires.esm" || surfaceSourceModName == "Dragonborn.esm"
        surfaceSourceModName = ""
    endIf
    Int nowDay = Utility.GetCurrentGameTime() as Int
    Int bodMagnitude = 1
    if _qrQueueSurfMilestone
        bodMagnitude = 2
    endIf
    Bool toastSent = False
    if _qrQueueSurfNegCount == 0
        String posMsg = _qrQueueSurfBestPosName + " marks your deed."
        if _qrQueueSurfPosCount == 2
            posMsg = _qrQueueSurfBestPosName + " and 1 other mark your deed."
        elseIf _qrQueueSurfPosCount > 2
            posMsg = _qrQueueSurfBestPosName + " and " + (_qrQueueSurfPosCount - 1) + " others mark your deed."
        endIf
        toastSent = PDV_Manager.SendPrismaToastWithSource(_qrQueueSurfBestPosSymbol, "good", "A deed marked", posMsg, surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfPosNamesCsv) + " marked your deed.", nowDay, "favor.act", _qrQueueSurfBestPosSymbol, False, bodMagnitude, "A deed marked", False, surfaceSourceModName)
    elseIf _qrQueueSurfPosCount == 0
        String negMsg = _qrQueueSurfBestNegName + " takes offense at your deed."
        if _qrQueueSurfNegCount == 2
            negMsg = _qrQueueSurfBestNegName + " and 1 other take offense at your deed."
        elseIf _qrQueueSurfNegCount > 2
            negMsg = _qrQueueSurfBestNegName + " and " + (_qrQueueSurfNegCount - 1) + " others take offense at your deed."
        endIf
        toastSent = PDV_Manager.SendPrismaToastWithSource(_qrQueueSurfBestNegSymbol, "warning", "A deed ill-received", negMsg, surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfNegNamesCsv) + " took offense at your deed.", nowDay, "favor.loss", _qrQueueSurfBestNegSymbol, False, bodMagnitude, "A deed ill-received", False, surfaceSourceModName)
    else
        Bool positiveLeads = _qrQueueSurfBestPosAmount >= (_qrQueueSurfBestNegAmount * -1.0)
        String mixedTone = "good"
        String mixedSymbol = _qrQueueSurfBestPosSymbol
        String mixedBodTone = "favor.act"
        if !positiveLeads
            mixedTone = "warning"
            mixedSymbol = _qrQueueSurfBestNegSymbol
            mixedBodTone = "favor.loss"
        endIf
        toastSent = PDV_Manager.SendPrismaToastWithSource(mixedSymbol, mixedTone, "A deed weighed", _qrQueueSurfBestPosName + " marks your deed; " + _qrQueueSurfBestNegName + " takes offense.", surfaceSourceModName, True, reactionKey)
        TraceQuestReactionToastResult(reactionKey, toastSent)
        PDV_Manager.AppendBookOfDaysEntry(JoinQuestSurfaceNames(_qrQueueSurfPosNamesCsv) + " marked your deed; " + JoinQuestSurfaceNames(_qrQueueSurfNegNamesCsv) + " took offense.", nowDay, mixedBodTone, mixedSymbol, False, bodMagnitude, "A deed weighed", False, surfaceSourceModName)
    endIf
    ResetQueuedQuestReactionSurface()
EndFunction

Function TraceQuestReactionToastResult(String reactionKey, Bool toastSent)
    if PDV_Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV][PDV_TOAST_TRACE] questReaction correlation=" + reactionKey + " submitted=" + toastSent)
    endIf
EndFunction

PDV_DeityBase Function GetQuestReactionDeity(String deityName)
    ; Per-cell quest-reaction hot path. Resolution was an O(deities) FormList
    ; scan (plus a Daedric-path scan on a name miss) run once per cell -- twice
    ; for a runnable cell (cheap-skip check then ApplyDeityReaction). The
    ; name->deity mapping is static for the session, so cache the resolved form
    ; in a StorageUtil map keyed by name. Only non-None results are cached, so a
    ; name whose owning form is not loaded yet keeps re-scanning until it hits.
    if deityName == ""
        return None
    endIf

    Form cachedForm = StorageUtil.GetFormValue(None, "PDV.Manager.QuestReaction.DeityCache." + deityName)
    PDV_DeityBase cachedDeity = cachedForm as PDV_DeityBase
    if cachedDeity
        return cachedDeity
    endIf

    PDV_DeityBase deity = PDV_Manager.LedgerRuntime.GetDeityByName(deityName)
    if !deity && PDV_Manager.PDV_FLST_DaedricPaths_All
        Int i = 0
        Int count = PDV_Manager.PDV_FLST_DaedricPaths_All.GetSize()
        while i < count && !deity
            PDV_DeityBase path = PDV_Manager.PDV_FLST_DaedricPaths_All.GetAt(i) as PDV_DeityBase
            if path && IsQuestReactionNameMatch(path.DeityName, deityName)
                deity = path
            endIf
            i += 1
        endWhile
    endIf

    if deity
        StorageUtil.SetFormValue(None, "PDV.Manager.QuestReaction.DeityCache." + deityName, deity)
    endIf
    return deity
EndFunction

Bool Function IsQuestReactionNameMatch(String recordName, String requestedName)
    if recordName == requestedName
        return True
    endIf
    if requestedName == "Hermaeus Mora" && recordName == "Mora"
        return True
    endIf
    if requestedName == "Clavicus Vile" && recordName == "Vile"
        return True
    endIf
    if requestedName == "Mehrunes Dagon" && recordName == "Dagon"
        return True
    endIf
    if requestedName == "Molag Bal" && recordName == "Molag"
        return True
    endIf
    if requestedName == "Sheogorath" && recordName == "Sheo"
        return True
    endIf
    return False
EndFunction

String Function GetQuestReactionStance(String deityName, PDV_DeityBase deity)
    String raceLabel = PDV_Manager.OriginRuntime.GetOriginRaceLabel(PDV_Manager.GetPlayerOriginRaceIndex())
    String stance = JsonUtil.GetStringValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "stance." + raceLabel + "." + deityName)
    if stance != ""
        return stance
    endIf

    Int stanceValue = deity.GetStanceForPlayer()
    if stanceValue == deity.STANCE_NATIVE
        return "NATIVE"
    elseIf stanceValue == deity.STANCE_TABOO
        return "TABOO"
    elseIf stanceValue == deity.STANCE_HOSTILE
        return "HOSTILE"
    endIf

    return "FOREIGN"
EndFunction

Float Function GetQuestReactionBaseValue(String magnitude, String intensity)
    return JsonUtil.GetFloatValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "value." + magnitude + "." + intensity, 0.0)
EndFunction

Float Function GetQuestReactionStanceMultiplier(String stance)
    if stance == "FOREIGN"
        return JsonUtil.GetFloatValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "stanceMult.FOREIGN", 0.4)
    elseIf stance == "TOLERATED"
        return JsonUtil.GetFloatValue(PDV_Manager.QUEST_REACTION_MATRIX_FILE, "stanceMult.TOLERATED", 0.4)
    endIf
    return 1.0
EndFunction

; A quest-reaction target is "reachable" when automatic piety can land on a
; player-facing, currently eligible lane. Daedric paths always qualify
; (pre-pact paths render as "watching"; pacts as patron), and an active
; off-roster patron restored from an older save remains reachable. Nords are
; deliberately narrower than their dashboard's union roster: the selected Old
; Ways or Nine Divines baseline decides which native god can receive an
; automatic quest reaction. DeityBase state tracks still own their documented
; reduced-gain/tier-cap behavior and are not duplicated as a binary gate here.
Bool Function IsQuestReactionDeityReachable(PDV_DeityBase deity)
    if deity as PDV_DaedricPathBase
        return True
    endIf
    if PDV_Manager.LedgerRuntime.IsGrandfatheredOffRosterPatron(deity)
        return True
    endIf

    Int originRace = PDV_Manager.GetPlayerOriginRaceIndex()
    if originRace == PDV_Manager.ORIGIN_NORD
        return PDV_Manager.OriginRuntime.IsNordOfferEligibleDeity(deity)
    endIf

    return PDV_Manager.OriginRuntime.IsDashboardDeityInOriginRoster(deity, originRace)
EndFunction

Function ApplyQuestReactionPiety(PDV_DeityBase deity, Float amount, String reason)
    Form deityForm = PDV_Manager.GetDeityFormOrNone(deity)
    if !deityForm || amount == 0.0
        return
    endIf

    ; The caller already applied the matrix stance multiplier. Preserve track,
    ; eligibility, curse, survival, and mode modifiers without double-scaling
    ; FOREIGN/TOLERATED through the record stance again.
    PDV_Manager.LedgerRuntime.AwardPietyInternal(deity, amount, True, reason, False)
    StorageUtil.SetStringValue(deityForm, "PDV.QuestReaction.LastReason", reason)
    if !_qrQueueTransactionActive
        PDV_Manager.RequestPanelRefresh()
    endIf

    if PDV_Manager.GetDebugLevel() >= 3 || (!_qrQueueTransactionActive && PDV_Manager.GetDebugLevel() >= 1)
        Debug.Trace("[PDV] QuestReaction piety: " + deity.DeityName + " " + amount + " (" + reason + ")")
    endIf
EndFunction

Function ApplyQuestReactionStigma(PDV_DeityBase deity, Float amount, String reason)
    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if path
        path.AddStigma(amount, "quest_reaction_" + reason)
    else
        ApplyQuestReactionPiety(deity, amount * -1.0, "taboo_" + reason)
    endIf
EndFunction

Bool Function MarkQuestReactionFaucet(String deityName, String sourceTag, Form sourceForm)
    String capKey = "PDV.QuestReaction.Faucet." + deityName + "." + sourceTag
    if sourceTag == "forbidden_knowledge" && sourceForm
        String everKey = capKey + "." + sourceForm.GetFormID() + ".Seen"
        if StorageUtil.GetIntValue(None, everKey) == 1
            return False
        endIf
        StorageUtil.SetIntValue(None, everKey, 1)
        return True
    endIf

    Int currentDayStamp = PDV_Manager.LedgerRuntime.GetDevotionalDay() + 2
    String dayKey = capKey + ".Day"
    if StorageUtil.GetIntValue(None, dayKey) == currentDayStamp
        return False
    endIf

    StorageUtil.SetIntValue(None, dayKey, currentDayStamp)
    return True
EndFunction

Function AccumulateQueuedQuestReactionBroadDelta(PDV_DeityBase deity, Float appliedDelta)
    if _qrQueueBroadPool == "" || !deity || !PDV_Manager.LedgerRuntime.IsDeityEligibleForBroadPantheon(deity, _qrQueueBroadPool)
        return
    endIf
    if appliedDelta > 0.0 && appliedDelta > _qrQueueBroadBestPositive
        _qrQueueBroadBestPositive = appliedDelta
    elseIf appliedDelta < 0.0 && appliedDelta < _qrQueueBroadWorstNegative
        _qrQueueBroadWorstNegative = appliedDelta
    endIf
EndFunction

Function CommitQueuedQuestReactionBroad(String reactionKey)
    Float chosenDelta = 0.0
    if _qrQueueBroadBestPositive > 0.0
        chosenDelta = _qrQueueBroadBestPositive
    elseIf _qrQueueBroadWorstNegative < 0.0
        chosenDelta = _qrQueueBroadWorstNegative
    endIf
    if _qrQueueBroadPool != "" && chosenDelta != 0.0
        Float nowTime = Utility.GetCurrentGameTime()
        if !PDV_Manager.LedgerRuntime.IsRecentBroadPantheonEventDuplicate(_qrQueueBroadPool, "quest_" + reactionKey, nowTime)
            PDV_Manager.LedgerRuntime.CatchUpBroadPantheonDecayBeforeCurrentDay(_qrQueueBroadPool)
            if PDV_Manager.LedgerRuntime.GetBroadPantheonScratch(_qrQueueBroadPool) == 0.0
                PDV_Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(PDV_Manager.LedgerRuntime.GetBroadPantheonScratchDayKey(_qrQueueBroadPool))
            endIf
            StorageUtil.AdjustFloatValue(None, PDV_Manager.LedgerRuntime.GetBroadPantheonScratchKey(_qrQueueBroadPool), chosenDelta)
            StorageUtil.SetStringValue(None, PDV_Manager.LedgerRuntime.GetBroadPantheonLastEventKey(_qrQueueBroadPool), "quest_" + reactionKey)
            StorageUtil.SetFloatValue(None, PDV_Manager.LedgerRuntime.GetBroadPantheonLastEventTimeKey(_qrQueueBroadPool), nowTime)
            PDV_Manager.LedgerRuntime.RememberBroadPantheonEvent(_qrQueueBroadPool, "quest_" + reactionKey, nowTime)
            if chosenDelta > 0.0
                PDV_Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp(PDV_Manager.LedgerRuntime.GetBroadPantheonLastGainDayKey(_qrQueueBroadPool))
            endIf
        endIf
    endIf
    _qrQueueBroadPool = ""
    _qrQueueBroadBestPositive = 0.0
    _qrQueueBroadWorstNegative = 0.0
EndFunction

Bool Function GetQrQueueTransactionActive()
    return _qrQueueTransactionActive
EndFunction

Function SetQrQueueNeedsCurseRefresh(Bool value)
    _qrQueueNeedsCurseRefresh = value
EndFunction

Bool Function GetQrQueueNeedsBretonRewardSync()
    return _qrQueueNeedsBretonRewardSync
EndFunction

Function SetQrQueueNeedsBretonRewardSync(Bool value)
    _qrQueueNeedsBretonRewardSync = value
EndFunction
