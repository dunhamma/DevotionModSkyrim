Scriptname PDV_QuestReactionRuntime extends Quest

; V3 Quest Reaction deep module. This script repurposes the existing worker
; quest: one existing host, one scheduler, one persisted FIFO. Engine adapters
; submit semantic inputs; the Manager remains the scoring/presentation sink.

PDV__ManagerQuest Property PDV_Manager Auto

Int Property INTERFACE_VERSION = 1 AutoReadOnly
String Property QUEST_REACTION_MATRIX_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix" AutoReadOnly
String Property QUEST_REACTION_CHANNEL_FOLDER = "../StorageUtilData/PlayerDevotion/Channels" AutoReadOnly
String Property QUEST_REACTION_STAGE_ADAPTER_FOLDER = "../StorageUtilData/PlayerDevotion/QuestStageAdapters" AutoReadOnly
Int Property QUEST_REACTION_QUEUE_MAX_PENDING = 128 AutoReadOnly
Int Property QUEST_REACTION_QUEUE_CELLS_PER_TICK = 2 AutoReadOnly
Float Property QUEST_REACTION_QUEUE_TICK_SECONDS = 0.1 AutoReadOnly
Float Property QUEST_REACTION_DUPLICATE_WINDOW_DAYS = 0.02 AutoReadOnly

String Property QUEUE_IDS_KEY = "PDV.V3.QR.Queue.JobIds" AutoReadOnly
String Property QUEUE_FORMS_KEY = "PDV.V3.QR.Queue.SourceForms" AutoReadOnly
String Property QUEUE_SEQUENCE_KEY = "PDV.V3.QR.Queue.Sequence" AutoReadOnly
String Property QUEUE_UPDATE_ARMED_KEY = "PDV.V3.QR.Queue.UpdateArmed" AutoReadOnly
String Property JOB_PREFIX = "PDV.V3.QR.Job." AutoReadOnly
String Property CHANNEL_FILES_KEY = "PDV.V3.QR.ChannelFiles" AutoReadOnly

Alias _questStageReceiver = None
Bool _sliceActive = False

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
    if LoadCatalogFile(QUEST_REACTION_MATRIX_FILE)
        ActivateCatalogSources(QUEST_REACTION_MATRIX_FILE, True)
    endIf
    StorageUtil.StringListClear(None, CHANNEL_FILES_KEY)
    String[] channelNames = JsonUtil.JsonInFolder(QUEST_REACTION_CHANNEL_FOLDER)
    if channelNames
        Int channelIndex = 0
        while channelIndex < channelNames.Length
            String channelFile = QUEST_REACTION_CHANNEL_FOLDER + "/" + channelNames[channelIndex]
            if LoadCatalogFile(channelFile)
                StorageUtil.StringListAdd(None, CHANNEL_FILES_KEY, channelFile, False)
                ActivateCatalogSources(channelFile, False)
            endIf
            channelIndex += 1
        endWhile
    endIf

    StorageUtil.StringListClear(None, "PDV.V3.QR.StageAdapterFiles")
    String[] adapterNames = JsonUtil.JsonInFolder(QUEST_REACTION_STAGE_ADAPTER_FOLDER)
    if adapterNames
        Int adapterIndex = 0
        while adapterIndex < adapterNames.Length
            String adapterFile = QUEST_REACTION_STAGE_ADAPTER_FOLDER + "/" + adapterNames[adapterIndex]
            if LoadCatalogFile(adapterFile)
                StorageUtil.StringListAdd(None, "PDV.V3.QR.StageAdapterFiles", adapterFile, False)
            endIf
            adapterIndex += 1
        endWhile
    endIf
    TraceQuestReactionQueue("CATALOG loaded channels=" + StorageUtil.StringListCount(None, CHANNEL_FILES_KEY) + " adapters=" + StorageUtil.StringListCount(None, "PDV.V3.QR.StageAdapterFiles"))
EndFunction

Bool Function LoadCatalogFile(String matrixFile)
    if matrixFile == "" || !JsonUtil.JsonExists(matrixFile)
        return False
    endIf
    JsonUtil.Unload(matrixFile, False)
    return JsonUtil.Load(matrixFile)
EndFunction

Bool Function SubmitQuestStage(Quest sourceQuest, Int stageValue, String logicalEventId = "")
    return QueueQuestReactionJob(sourceQuest, ResolveQuestStage(sourceQuest, stageValue), logicalEventId)
EndFunction

Function ActivateCatalogSources(String matrixFile, Bool coreCatalog)
    if !_questStageReceiver || matrixFile == ""
        return
    endIf
    Int sourceIndex = 0
    Int sourceCount = JsonUtil.StringListCount(matrixFile, "questWatchFormIds")
    if sourceCount > 0
        while sourceIndex < sourceCount
            ActivateCatalogSource(matrixFile, JsonUtil.StringListGet(matrixFile, "questWatchFormIds", sourceIndex), JsonUtil.StringListGet(matrixFile, "questWatchPlugins", sourceIndex), coreCatalog)
            sourceIndex += 1
        endWhile
        return
    endIf
    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchFormIdsCsv"), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchPluginsCsv"), ",")
    sourceCount = formIds.Length
    while sourceIndex < sourceCount && sourceIndex < plugins.Length
        ActivateCatalogSource(matrixFile, formIds[sourceIndex], plugins[sourceIndex], coreCatalog)
        sourceIndex += 1
    endWhile
EndFunction

Function ActivateCatalogSource(String matrixFile, String formIdString, String pluginName, Bool coreCatalog)
    Int localFormId = formIdString as Int
    if localFormId <= 0 || pluginName == "" || Game.GetModByName(pluginName) == 255
        return
    endIf
    Quest sourceQuest = Game.GetFormFromFile(localFormId, pluginName) as Quest
    if !sourceQuest
        return
    endIf
    PO3_Events_Alias.RegisterForQuestStage(_questStageReceiver, sourceQuest)
    Int runtimeFormId = sourceQuest.GetFormID()
    StorageUtil.SetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId, localFormId)
    StorageUtil.SetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId, pluginName)
    String sourceCatalogKey = "PDV.V3.QR.SourceCatalog." + runtimeFormId
    if coreCatalog || StorageUtil.GetStringValue(None, sourceCatalogKey) == ""
        StorageUtil.SetStringValue(None, sourceCatalogKey, matrixFile)
    endIf
EndFunction

Int Function ResolveQuestStage(Quest sourceQuest, Int physicalStage)
    if !sourceQuest
        return physicalStage
    endIf
    Int adapterIndex = 0
    Int adapterCount = StorageUtil.StringListCount(None, "PDV.V3.QR.StageAdapterFiles")
    while adapterIndex < adapterCount
        String adapterFile = StorageUtil.StringListGet(None, "PDV.V3.QR.StageAdapterFiles", adapterIndex)
        String sourcePlugin = JsonUtil.GetStringValue(adapterFile, "sourcePlugin")
        Int sourceFormId = JsonUtil.GetIntValue(adapterFile, "sourceFormId")
        if sourcePlugin != "" && JsonUtil.GetIntValue(adapterFile, "sourceStage") == physicalStage && Game.GetModByName(sourcePlugin) != 255
            if (Game.GetFormFromFile(sourceFormId, sourcePlugin) as Quest) == sourceQuest
                Int mappedStage = ResolveAdapterSelector(adapterFile)
                if mappedStage > 0
                    return mappedStage
                endIf
            endIf
        endIf
        adapterIndex += 1
    endWhile
    return physicalStage
EndFunction

Int Function ResolveAdapterSelector(String adapterFile)
    String selectorPlugin = JsonUtil.GetStringValue(adapterFile, "selectorPlugin")
    Int selectorFormId = JsonUtil.GetIntValue(adapterFile, "selectorFormId")
    if selectorPlugin == "" || Game.GetModByName(selectorPlugin) == 255
        return 0
    endIf
    Int selectorValue = 0
    String selectorKind = JsonUtil.GetStringValue(adapterFile, "selectorKind")
    if selectorKind == "" || selectorKind == "global"
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
    Int valueCount = JsonUtil.IntListCount(adapterFile, "selectorValues")
    while valueIndex < valueCount
        if JsonUtil.IntListGet(adapterFile, "selectorValues", valueIndex) == selectorValue
            return JsonUtil.IntListGet(adapterFile, "targetStages", valueIndex)
        endIf
        valueIndex += 1
    endWhile
    return 0
EndFunction

Bool Function SubmitSemanticEvent(String sourceId, String eventId, Form sourceForm = None)
    ; The versioned seam exists from Slice 1. Catalog v2 semantic rows land in
    ; the next catalog tranche; unknown events fail quiet and source-local.
    if sourceId == "" || eventId == ""
        return False
    endIf
    TraceQuestReactionQueue("REJECT rejected unknown semantic event " + sourceId + "|" + eventId)
    return False
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
    return "interface=" + INTERFACE_VERSION + "; channels=" + StorageUtil.StringListCount(None, CHANNEL_FILES_KEY)
EndFunction

; Development-only probes stay on the module that owns catalog and queue state.
String Function DebugReloadCatalog()
    RefreshCatalogSources()
    Int coreCells = 0
    if JsonUtil.IsGood(QUEST_REACTION_MATRIX_FILE)
        coreCells = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, "questWatchFormIdsCsv"), ",").Length
    endIf
    Int channelCount = StorageUtil.StringListCount(None, CHANNEL_FILES_KEY)
    TraceQuestReactionQueue("CATALOG loaded core=" + coreCells + " channels=" + channelCount)
    return "Quest matrix reloaded.\nCore: " + coreCells + " watched quests.\nMod channels: " + channelCount + " loaded."
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

String Function ResolveQuestReactionCellFile(Int runtimeFormId, String sourcePlugin, Int localFormId)
    String matrixFile = StorageUtil.GetStringValue(None, "PDV.V3.QR.SourceCatalog." + runtimeFormId)
    if CatalogContainsQuestIdentity(matrixFile, sourcePlugin, localFormId)
        return matrixFile
    endIf
    return ""
EndFunction

String Function ResolveQuestReactionCellPrefix(String matrixFile, String sourcePlugin, Int localFormId, Int stageValue)
    ; Catalog v2 stores the fully-qualified key directly. Transitional v1 files
    ; are accepted only through the exact source-catalog binding registered for
    ; this runtime quest, never through discovery-order scanning.
    String qualifiedPrefix = "quest." + sourcePlugin + "|" + localFormId + "|" + stageValue + "."
    if JsonUtil.GetStringValue(matrixFile, qualifiedPrefix + "deitiesCsv") != ""
        return qualifiedPrefix
    endIf
    String legacyPrefix = "quest." + localFormId + "|" + stageValue + "."
    if JsonUtil.GetStringValue(matrixFile, legacyPrefix + "deitiesCsv") != ""
        return legacyPrefix
    endIf
    return ""
EndFunction

Bool Function CatalogContainsQuestIdentity(String matrixFile, String sourcePlugin, Int localFormId)
    if matrixFile == "" || sourcePlugin == ""
        return False
    endIf
    Int sourceIndex = 0
    Int sourceCount = JsonUtil.StringListCount(matrixFile, "questWatchFormIds")
    if sourceCount > 0
        while sourceIndex < sourceCount
            if (JsonUtil.StringListGet(matrixFile, "questWatchFormIds", sourceIndex) as Int) == localFormId && JsonUtil.StringListGet(matrixFile, "questWatchPlugins", sourceIndex) == sourcePlugin
                return True
            endIf
            sourceIndex += 1
        endWhile
        return False
    endIf

    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchFormIdsCsv"), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchPluginsCsv"), ",")
    sourceCount = formIds.Length
    while sourceIndex < sourceCount && sourceIndex < plugins.Length
        if (formIds[sourceIndex] as Int) == localFormId && plugins[sourceIndex] == sourcePlugin
            return True
        endIf
        sourceIndex += 1
    endWhile
    return False
EndFunction

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

    Float ingressStartedRealTime = Utility.GetCurrentRealTime()
    Int runtimeFormId = sourceQuest.GetFormID()
    Int localFormId = StorageUtil.GetIntValue(None, "PDV.V3.QR.SourceLocalFormId." + runtimeFormId, runtimeFormId)
    String sourcePlugin = StorageUtil.GetStringValue(None, "PDV.V3.QR.SourcePlugin." + runtimeFormId)
    if sourcePlugin == "" || Game.GetModByName(sourcePlugin) == 255
        return False
    endIf
    String reactionKey = sourcePlugin + "|" + localFormId + "|" + stageValue
    String matrixFile = ResolveQuestReactionCellFile(runtimeFormId, sourcePlugin, localFormId)
    String cellPrefix = ResolveQuestReactionCellPrefix(matrixFile, sourcePlugin, localFormId, stageValue)
    if matrixFile == "" || cellPrefix == ""
        return False
    endIf

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
    String metaDoneKey = "PDV.V3.QR.Meta.Done." + sourcePlugin + "|" + localFormId
    if StorageUtil.GetIntValue(None, metaDoneKey) != 1
        StorageUtil.SetIntValue(None, metaDoneKey, 1)
        metaEligible = 1
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
    StorageUtil.FormListAdd(None, QUEUE_FORMS_KEY, sourceQuest as Form, True)
    StorageUtil.SetStringValue(None, prefix + "ReactionKey", reactionKey)
    StorageUtil.SetStringValue(None, prefix + "LogicalEventId", logicalEventId)
    StorageUtil.SetStringValue(None, prefix + "DeitiesCsv", deitiesCsv)
    StorageUtil.SetStringValue(None, prefix + "ValencesCsv", valencesCsv)
    StorageUtil.SetStringValue(None, prefix + "IntensitiesCsv", intensitiesCsv)
    StorageUtil.SetStringValue(None, prefix + "MagnitudesCsv", magnitudesCsv)
    StorageUtil.SetStringValue(None, prefix + "TagsCsv", tagsCsv)
    StorageUtil.SetStringValue(None, prefix + "SourceModName", JsonUtil.GetStringValue(matrixFile, "sourceMod"))
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
