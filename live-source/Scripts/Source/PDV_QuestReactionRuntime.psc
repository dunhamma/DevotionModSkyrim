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
EndFunction

Bool Function LoadCatalogFile(String matrixFile)
    if matrixFile == "" || !JsonUtil.JsonExists(matrixFile)
        return False
    endIf
    JsonUtil.Unload(matrixFile, False)
    return JsonUtil.Load(matrixFile)
EndFunction

Function LoadAndActivateCatalog(String catalogFile)
    if !LoadCatalogFile(catalogFile)
        _rejectedSourceCount += 1
        return
    endIf
    if JsonUtil.GetStringValue(catalogFile, "schema") != "pdv.quest-reaction.catalog.v2" || JsonUtil.GetIntValue(catalogFile, "schemaVersion") != 2
        _rejectedSourceCount += 1
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
    if JsonUtil.StringListCount(catalogFile, sentinelKey) <= 0 || HasDuplicateListValue(catalogFile, sentinelKey)
        return False
    endIf
    Int sentinelIndex = 0
    while sentinelIndex < JsonUtil.StringListCount(catalogFile, sentinelKey)
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
    while questIndex < JsonUtil.StringListCount(catalogFile, questKeyList)
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
    while semanticIndex < JsonUtil.StringListCount(catalogFile, semanticKeyList)
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
    while stageAdapterIndex < JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
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
    while sentinelIndex < JsonUtil.StringListCount(catalogFile, sentinelKey)
        String[] sentinelParts = StringUtil.Split(JsonUtil.StringListGet(catalogFile, sentinelKey, sentinelIndex), "|")
        if Game.GetModByName(sentinelParts[0]) == 255 || !Game.GetFormFromFile(sentinelParts[1] as Int, sentinelParts[0])
            return False
        endIf
        sentinelIndex += 1
    endWhile
    String questKeyList = "source." + sourceId + ".questKeys"
    Int questIndex = 0
    while questIndex < JsonUtil.StringListCount(catalogFile, questKeyList)
        String[] questParts = StringUtil.Split(JsonUtil.StringListGet(catalogFile, questKeyList, questIndex), "|")
        if Game.GetModByName(questParts[0]) == 255 || !(Game.GetFormFromFile(questParts[1] as Int, questParts[0]) as Quest)
            return False
        endIf
        questIndex += 1
    endWhile
    String stageAdapterKeyList = "source." + sourceId + ".stageAdapterKeys"
    Int stageAdapterIndex = 0
    while stageAdapterIndex < JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
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
    while questIndex < JsonUtil.StringListCount(catalogFile, questKeyList)
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
    while semanticIndex < JsonUtil.StringListCount(catalogFile, semanticKeyList)
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
    while stageAdapterIndex < JsonUtil.StringListCount(catalogFile, stageAdapterKeyList)
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
    TraceQuestReactionQueue("CATALOG loaded questKeys=" + questKeyCount + " semanticKeys=" + semanticKeyCount + " active=" + _activeSourceCount + " rejected=" + _rejectedSourceCount)
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

    String sourceDeitiesCsv = JsonUtil.GetStringValue(matrixFile, cellPrefix + "deitiesCsv")
    String[] deityNames = StringUtil.Split(sourceDeitiesCsv, "|")
    String[] valences = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "valencesCsv"), "|")
    String[] intensities = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "intensitiesCsv"), "|")
    String[] magnitudes = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "magnitudesCsv"), "|")
    String[] sourceTags = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, cellPrefix + "tagsCsv"), "|")
    Int sourceCellCount = deityNames.Length
    if sourceCellCount <= 0 || sourceCellCount != valences.Length || sourceCellCount != intensities.Length || sourceCellCount != magnitudes.Length || sourceCellCount != sourceTags.Length
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

    String deitiesCsv = ""
    String valencesCsv = ""
    String intensitiesCsv = ""
    String magnitudesCsv = ""
    String tagsCsv = ""
    Int sourceIndex = 0
    Int cellCount = 0
    while sourceIndex < sourceCellCount
        if PDV_Manager.ShouldQueueQuestReactionCell(deityNames[sourceIndex], valences[sourceIndex], intensities[sourceIndex], magnitudes[sourceIndex])
            deitiesCsv = AppendSnapshotToken(deitiesCsv, deityNames[sourceIndex])
            valencesCsv = AppendSnapshotToken(valencesCsv, valences[sourceIndex])
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, intensities[sourceIndex])
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, magnitudes[sourceIndex])
            tagsCsv = AppendSnapshotToken(tagsCsv, sourceTags[sourceIndex])
            cellCount += 1
        endIf
        sourceIndex += 1
    endWhile
    Int skippedCellCount = sourceCellCount - cellCount

    Int metaRunnableCount = 0
    Int metaEligible = 0
    Int metaGold = JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.gold")
    Int metaMageAid = JsonUtil.GetIntValue(matrixFile, cellPrefix + "class.mageAid")
    Int metaTwilight = BoolToInt(IsTwilightWindow())
    Int metaNight = BoolToInt(IsNightWindow())
    Int metaNocturnalTheft = BoolToInt(StorageUtil.GetFloatValue(None, "PDV.Meta.LastTheftTime") > StorageUtil.GetFloatValue(None, "PDV.Meta.LastFulfillTime"))
    Int metaOutdoors = BoolToInt(IsPlayerOutdoors())
    Int metaSkipZen = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Z'en")
    Int metaSkipJulianos = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Julianos")
    Int metaSkipAzura = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Azura")
    Int metaSkipNocturnal = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Nocturnal")
    Int metaSkipKhenarthi = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Khenarthi")
    Int metaSkipAkatosh = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Akatosh")
    Int metaSkipXarxes = JsonUtil.GetIntValue(matrixFile, cellPrefix + "metaSkip.Xarxes")
    if metaPlugin != "" && metaLocalFormId >= 0
        String metaDoneKey = "PDV.V3.QR.Meta.Done." + metaPlugin + "|" + metaLocalFormId
        if StorageUtil.GetIntValue(None, metaDoneKey) != 1
            StorageUtil.SetIntValue(None, metaDoneKey, 1)
            metaEligible = 1
        endIf
    endIf

    if metaEligible == 1
        if metaGold == 1 && metaSkipZen != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Z'en", "+", "zen", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Z'en")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "zen")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_zen_wage")
            cellCount += 1
            metaRunnableCount += 1
        endIf
        if metaMageAid == 1 && metaSkipJulianos != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Julianos", "+", "julianos", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Julianos")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "julianos")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_julianos_wisdom")
            cellCount += 1
            metaRunnableCount += 1
        endIf
        if (metaMageAid == 1 || metaTwilight == 1) && metaSkipAzura != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Azura", "+", "azura", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Azura")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "azura")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_azura_threshold")
            cellCount += 1
            metaRunnableCount += 1
        endIf
        if metaSkipNocturnal != 1 && metaNocturnalTheft == 1 && PDV_Manager.ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalTheft", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Nocturnal")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "nocturnalTheft")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_nocturnal_herway")
            cellCount += 1
            metaRunnableCount += 1
        elseIf metaSkipNocturnal != 1 && metaNight == 1 && PDV_Manager.ShouldQueueQuestReactionCell("Nocturnal", "+", "nocturnalNight", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Nocturnal")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "nocturnalNight")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_nocturnal_dark")
            cellCount += 1
            metaRunnableCount += 1
        endIf
        if metaOutdoors == 1 && metaSkipKhenarthi != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Khenarthi", "+", "khenarthi", "meta")
            deitiesCsv = AppendSnapshotToken(deitiesCsv, "Khenarthi")
            valencesCsv = AppendSnapshotToken(valencesCsv, "+")
            intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "khenarthi")
            magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
            tagsCsv = AppendSnapshotToken(tagsCsv, "meta_khenarthi_road")
            cellCount += 1
            metaRunnableCount += 1
        endIf
        Int wheelCount = StorageUtil.AdjustIntValue(None, "PDV.V3.QR.Meta.QuestCount", 1)
        if wheelCount > 0 && wheelCount % 10 == 0
            if metaSkipAkatosh != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Akatosh", "+", "wheel", "meta")
                deitiesCsv = AppendSnapshotToken(deitiesCsv, "Akatosh")
                valencesCsv = AppendSnapshotToken(valencesCsv, "+")
                intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "wheel")
                magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
                tagsCsv = AppendSnapshotToken(tagsCsv, "meta_akatosh_wheel")
                cellCount += 1
                metaRunnableCount += 1
            endIf
            if metaSkipXarxes != 1 && PDV_Manager.ShouldQueueQuestReactionCell("Xarxes", "+", "wheel", "meta")
                deitiesCsv = AppendSnapshotToken(deitiesCsv, "Xarxes")
                valencesCsv = AppendSnapshotToken(valencesCsv, "+")
                intensitiesCsv = AppendSnapshotToken(intensitiesCsv, "wheel")
                magnitudesCsv = AppendSnapshotToken(magnitudesCsv, "meta")
                tagsCsv = AppendSnapshotToken(tagsCsv, "meta_xarxes_record")
                cellCount += 1
                metaRunnableCount += 1
            endIf
        endIf
    endIf

    Int sequence = StorageUtil.AdjustIntValue(None, QUEUE_SEQUENCE_KEY, 1)
    String jobId = "v3qr_" + sequence
    String prefix = JOB_PREFIX + jobId + "."
    StorageUtil.StringListAdd(None, QUEUE_IDS_KEY, jobId, True)
    StorageUtil.FormListAdd(None, QUEUE_FORMS_KEY, sourceForm, True)
    StorageUtil.SetStringValue(None, prefix + "ReactionKey", reactionKey)
    StorageUtil.SetStringValue(None, prefix + "LogicalEventId", logicalEventId)
    StorageUtil.SetStringValue(None, prefix + "DeitiesCsv", deitiesCsv)
    StorageUtil.SetStringValue(None, prefix + "ValencesCsv", valencesCsv)
    StorageUtil.SetStringValue(None, prefix + "IntensitiesCsv", intensitiesCsv)
    StorageUtil.SetStringValue(None, prefix + "MagnitudesCsv", magnitudesCsv)
    StorageUtil.SetStringValue(None, prefix + "TagsCsv", tagsCsv)
    StorageUtil.SetStringValue(None, prefix + "SourceModName", sourceModName)
    StorageUtil.SetIntValue(None, prefix + "CellCount", cellCount)
    StorageUtil.SetIntValue(None, prefix + "CellIndex", 0)
    StorageUtil.SetIntValue(None, prefix + "SourceCellCount", sourceCellCount)
    StorageUtil.SetIntValue(None, prefix + "SkippedCellCount", skippedCellCount)
    StorageUtil.SetIntValue(None, prefix + "MetaRunnableCount", metaRunnableCount)
    StorageUtil.SetIntValue(None, prefix + "Started", 0)
    StorageUtil.SetIntValue(None, prefix + "MetaEligible", metaEligible)
    StorageUtil.SetFloatValue(None, prefix + "QueuedGameTime", Utility.GetCurrentGameTime())
    StorageUtil.SetFloatValue(None, prefix + "EnqueuedRealTime", Utility.GetCurrentRealTime())
    Float ingressBuildMs = (Utility.GetCurrentRealTime() - ingressStartedRealTime) * 1000.0
    StorageUtil.SetFloatValue(None, prefix + "IngressBuildMs", ingressBuildMs)
    StorageUtil.SetStringValue(None, "PDV.V3.QR.LastKey", reactionKey)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastCellCount", cellCount)
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastSourceCellCount", sourceCellCount)
    TraceQuestReactionQueue("ENQUEUE queued " + jobId + " key=" + reactionKey + " cells=" + cellCount + " sourceCells=" + sourceCellCount + " skipped=" + skippedCellCount + " meta=" + metaRunnableCount + " buildMs=" + ingressBuildMs + " pending=" + StorageUtil.StringListCount(None, QUEUE_IDS_KEY))
    EnsureQuestReactionQueueRunning()
    return True
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

    if StorageUtil.GetIntValue(None, prefix + "Started") != 1
        StorageUtil.SetIntValue(None, prefix + "Started", 1)
        PDV_Manager.PrepareQueuedQuestReactionTransaction()
        TraceQuestReactionQueue("START started " + jobId + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + cellCount + " sourceCells=" + StorageUtil.GetIntValue(None, prefix + "SourceCellCount") + " skipped=" + StorageUtil.GetIntValue(None, prefix + "SkippedCellCount") + " meta=" + StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount"))
    endIf

    Form sourceForm = StorageUtil.FormListGet(None, QUEUE_FORMS_KEY, 0)
    Int processed = 0
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
    PDV_Manager.FinalizeQueuedQuestReaction(StorageUtil.GetStringValue(None, prefix + "SourceModName"), StorageUtil.GetStringValue(None, prefix + "ReactionKey"))
    Float elapsed = Utility.GetCurrentRealTime() - StorageUtil.GetFloatValue(None, prefix + "EnqueuedRealTime")
    StorageUtil.SetStringValue(None, "PDV.V3.QR.LastKey", StorageUtil.GetStringValue(None, prefix + "ReactionKey"))
    StorageUtil.SetIntValue(None, "PDV.V3.QR.LastCellCount", cellCount)
    TraceQuestReactionQueue("COMPLETE completed " + jobId + " key=" + StorageUtil.GetStringValue(None, prefix + "ReactionKey") + " cells=" + cellCount + " sourceCells=" + StorageUtil.GetIntValue(None, prefix + "SourceCellCount") + " skipped=" + StorageUtil.GetIntValue(None, prefix + "SkippedCellCount") + " meta=" + StorageUtil.GetIntValue(None, prefix + "MetaRunnableCount") + " elapsed=" + elapsed)
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
