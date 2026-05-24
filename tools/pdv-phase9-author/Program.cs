using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;
using SkyrimGlobal = Mutagen.Bethesda.Skyrim.Global;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string proofActivatorModel = @"Architecture\HighHrothgar\MQEtchedShrineActivator.nif";

var espPath = GetArg(args, "--esp") ?? defaultEsp;
var dryRun = args.Contains("--dry-run");
var checkPlacements = args.Contains("--check-placements");
var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, index.Values.Select(r => r.FormKey));

    if (checkPlacements)
    {
        CheckPhase9Placements(index, report);
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
        return report.Status == "PASS" ? 0 : 1;
    }

    var debugGlobal = Require(index, "PDV_GLO_DebugLevel");
    var originGlobal = Require(index, "PDV_GLO_OriginRace");
    var bosmerGlobal = EnsureGlobal(mod, index, allocator, "PDV_GLO_BosmerPath", 0.0f);
    var bosmerTrack = EnsureQuest(mod, index, allocator, "PDV_StateTrack_BosmerPath");
    WireQuestScript(bosmerTrack, "PDV_StateTrack", new ScriptProperty[]
    {
        StringProp("TrackName", "BosmerPath"),
        ObjectProp("StateGlobal", bosmerGlobal.FormKey),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        StringListProp("StateLabels", "OldContract", "LivingStory", "Exchange", "BanditRoad"),
        BoolProp("AllowsTransition", true),
        FloatProp("OfferCooldownDays", 7.0f),
        FloatProp("TransitionLockoutDays", 7.0f),
    });
    report.Actions.Add("Created/wired PDV_GLO_BosmerPath and PDV_StateTrack_BosmerPath shell data.");

    var eventBus = Require(index, "PDV_EventBus");
    var allDeities = RequireRecord<FormList>(index, "PDV_FLST_AllDeities");
    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var playerRef = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x14);

    var yffre = RequireRecord<Quest>(index, "PDV_Deity_Yffre");
    WireQuestScript(yffre, "PDV_Deity_Yffre", new ScriptProperty[]
    {
        StringProp("DeityName", "Y'ffre"),
        StringProp("DeityDomain", "Story, Green Pact, Forest Law"),
        IntProp("DeityIndex", 3),
        IntProp("Stance_Bosmer", 0),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        ObjectProp("PDV_GLO_OriginRace", originGlobal.FormKey),
        ObjectProp("EligibleStateTrack", bosmerTrack.FormKey),
        IntListProp("EligibleStateValues", 0, 1),
        FloatProp("DELTA_PACT_POSITIVE", 2.0f),
        FloatProp("DELTA_LIVING_STORY", 2.5f),
    });
    report.Actions.Add("Confirmed/wired PDV_Deity_Yffre.");

    var zen = EnsureQuest(mod, index, allocator, "PDV_Deity_Zen");
    WireQuestScript(zen, "PDV_Deity_Zen", new ScriptProperty[]
    {
        StringProp("DeityName", "Z'en"),
        StringProp("DeityDomain", "Exchange, Reciprocity, Restitution"),
        IntProp("DeityIndex", 4),
        IntProp("Stance_Bosmer", 0),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        ObjectProp("PDV_GLO_OriginRace", originGlobal.FormKey),
        ObjectProp("EligibleStateTrack", bosmerTrack.FormKey),
        IntListProp("EligibleStateValues", 2),
    });
    report.Actions.Add("Created/wired PDV_Deity_Zen.");

    var baanDar = EnsureQuest(mod, index, allocator, "PDV_Deity_BaanDar");
    WireQuestScript(baanDar, "PDV_Deity_BaanDar", new ScriptProperty[]
    {
        StringProp("DeityName", "Baan Dar"),
        StringProp("DeityDomain", "Road, Theft, Survival Cunning"),
        IntProp("DeityIndex", 5),
        IntProp("Stance_Bosmer", 0),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        ObjectProp("PDV_GLO_OriginRace", originGlobal.FormKey),
        ObjectProp("EligibleStateTrack", bosmerTrack.FormKey),
        IntListProp("EligibleStateValues", 3),
    });
    report.Actions.Add("Created/wired PDV_Deity_BaanDar.");

    EnsureFormListEntry(allDeities, yffre.FormKey, report, "PDV_Deity_Yffre");
    EnsureFormListEntry(allDeities, zen.FormKey, report, "PDV_Deity_Zen");
    EnsureFormListEntry(allDeities, baanDar.FormKey, report, "PDV_Deity_BaanDar");

    var setup = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerSetupChoice",
        "Choose the Bosmer path you will walk first.",
        "Old Contract", "Living Story", "Exchange", "Bandit Road");
    var suggestLiving = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerSuggestLivingStory",
        "Your recent life points toward Living Story. Accept this path offer? A rite still confirms the change.",
        "Accept", "Refuse");
    var suggestExchange = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerSuggestExchange",
        "Your recent life points toward Exchange. Accept this path offer? A rite still confirms the change.",
        "Accept", "Refuse");
    var suggestBandit = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerSuggestBanditRoad",
        "Your recent life points toward Bandit Road. Accept this path offer? A rite still confirms the change.",
        "Accept", "Refuse");
    var suggestOld = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerSuggestOldContract",
        "Your recent life points toward Old Contract. Accept this path offer? A rite still confirms the change.",
        "Accept", "Refuse");
    var reckoning = EnsureMessage(mod, index, allocator, "PDV_MSG_BosmerReckoning",
        "The Pact demands reckoning. Recommit now, or renounce it.",
        "Recommit", "Renounce");
    report.Actions.Add("Created/wired Bosmer message records.");

    WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
    {
        ObjectProp("PDV_BosmerPathTrack", bosmerTrack.FormKey),
        ObjectProp("PDV_Zen", zen.FormKey),
        ObjectProp("PDV_BaanDar", baanDar.FormKey),
        ObjectProp("PDV_MSG_BosmerSetupChoice", setup.FormKey),
        ObjectProp("PDV_MSG_BosmerSuggestLivingStory", suggestLiving.FormKey),
        ObjectProp("PDV_MSG_BosmerSuggestExchange", suggestExchange.FormKey),
        ObjectProp("PDV_MSG_BosmerSuggestBanditRoad", suggestBandit.FormKey),
        ObjectProp("PDV_MSG_BosmerSuggestOldContract", suggestOld.FormKey),
        ObjectProp("PDV_MSG_BosmerReckoning", reckoning.FormKey),
    });
    report.Actions.Add("Wired PDV__ManagerQuest Bosmer Phase 9 properties.");

    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_BosmerLivingStorySignal", 41, 4, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey);
    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_BosmerExchangeSignal", 42, 4, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey);
    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_BosmerBanditRoadSignal", 43, 4, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey);
    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_BosmerPactPositiveSignal", 44, 4, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey);
    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_StateTransitionConfirmRite", 45, -1, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey);
    report.Actions.Add("Created/wired Phase 9 ACTI signal receiver records.");

    if (!dryRun)
    {
        var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "phase9");
        Directory.CreateDirectory(backupDir);
        var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
        var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
        File.Copy(espPath, backupPath, overwrite: false);
        report.BackupPath = backupPath;

        var tempPath = $"{espPath}.phase9.tmp";
        using (var stream = File.Create(tempPath))
        {
            mod.WriteToBinary(stream);
        }

        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        report.TouchedFiles.Add(espPath);
    }

    report.Status = "PASS";
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Errors.Add(ex.Message);
    report.Exception = ex.ToString();
}
finally
{
    report.FinishedAt = DateTimeOffset.Now;
    Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
}

return report.Status == "PASS" ? 0 : 1;

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static ISkyrimMajorRecordGetter Require(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (!index.TryGetValue(editorId, out var record))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }
    return record;
}

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    var record = Require(index, editorId);
    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} is {record.GetType().Name}, expected {typeof(T).Name}.");
    }
    return typed;
}

static Quest EnsureQuest(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is Quest quest)
        {
            ConfigureQuestShell(quest, editorId);
            return quest;
        }
        throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId
    };
    ConfigureQuestShell(created, editorId);
    mod.Quests.Add(created);
    index[editorId] = created;
    return created;
}

static void ConfigureQuestShell(Quest quest, string editorId)
{
    quest.EditorID = editorId;
    quest.Name = Tx(editorId);
    quest.FormVersion = 44;
    quest.QuestFormVersion = 65;
    quest.Type = Quest.TypeEnum.None;
    quest.Priority = 0;
}

static SkyrimGlobal EnsureGlobal(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, float value)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimGlobal global)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Global.");
        }
        ConfigureGlobalShell(global, editorId, value);
        return global;
    }

    throw new InvalidOperationException($"{editorId} is missing. Create a blank GLOB shell with that exact EditorID, then rerun this helper.");
}

static void ConfigureGlobalShell(SkyrimGlobal global, string editorId, float value)
{
    global.EditorID = editorId;
    global.FormVersion = 44;
    global.RawFloat = value;
}

static Message EnsureMessage(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, string text, params string[] buttons)
{
    Message message;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Message typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Message.");
        }
        message = typed;
        message.EditorID = editorId;
    }
    else
    {
        message = new Message(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = editorId,
            FormVersion = 44
        };
        mod.Messages.Add(message);
        index[editorId] = message;
    }

    message.Flags = Message.Flag.MessageBox;
    message.FormVersion = 44;
    message.Description = Tx(text);
    message.Name = Tx(editorId);
    message.MenuButtons.Clear();
    foreach (var button in buttons)
    {
        message.MenuButtons.Add(new MessageButton { Text = Tx(button) });
    }
    return message;
}

static void EnsureSignalActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    int routeId,
    int requiredOriginRace,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal)
{
    SkyrimActivator activator;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimActivator typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Activator.");
        }
        activator = typed;
        activator.EditorID = editorId;
    }
    else
    {
        activator = new SkyrimActivator(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = editorId,
            FormVersion = 44,
            Name = Tx(editorId),
            ActivateTextOverride = Tx("Activate")
        };
        mod.Activators.Add(activator);
        index[editorId] = activator;
    }

    activator.FormVersion = 44;
    activator.Name = Tx(editorId);
    activator.ActivateTextOverride = Tx("Activate");
    activator.Model ??= new Model();
    activator.Model.File = proofActivatorModel;
    WireActivatorScript(activator, "PDV_EventSignalActivator", new ScriptProperty[]
    {
        ObjectProp("PDV_EventBusService", eventBus),
        ObjectProp("PlayerREF", playerRef),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
        IntProp("RouteId", routeId),
        IntProp("RequiredOriginRace", requiredOriginRace),
        StringProp("TraceLabel", editorId),
    });
}

static void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(quest.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static void WireActivatorScript(SkyrimActivator activator, string scriptName, IEnumerable<ScriptProperty> properties)
{
    activator.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    activator.VirtualMachineAdapter.Version = 5;
    activator.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(activator.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName)
{
    var script = scripts.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script is not null)
    {
        script.Name = scriptName;
        return script;
    }

    script = new ScriptEntry
    {
        Name = scriptName,
        Flags = ScriptEntry.Flag.Local
    };
    scripts.Add(script);
    return script;
}

static void UpsertProperties(ScriptEntry script, IEnumerable<ScriptProperty> properties)
{
    foreach (var property in properties)
    {
        while (script.Properties.FirstOrDefault(p => string.Equals(p.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
        }
        script.Properties.Add(property);
    }
}

static ScriptObjectProperty ObjectProp(string name, FormKey formKey)
{
    return new ScriptObjectProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
        Alias = -1
    };
}

static ScriptIntProperty IntProp(string name, int value)
{
    return new ScriptIntProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptFloatProperty FloatProp(string name, float value)
{
    return new ScriptFloatProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptBoolProperty BoolProp(string name, bool value)
{
    return new ScriptBoolProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptStringProperty StringProp(string name, string value)
{
    return new ScriptStringProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptStringListProperty StringListProp(string name, params string[] values)
{
    var property = new ScriptStringListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };
    foreach (var value in values)
    {
        property.Data.Add(value);
    }
    return property;
}

static ScriptIntListProperty IntListProp(string name, params int[] values)
{
    var property = new ScriptIntListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };
    foreach (var value in values)
    {
        property.Data.Add(value);
    }
    return property;
}

static void EnsureFormListEntry(FormList formList, FormKey formKey, AuthorReport report, string label)
{
    if (formList.Items.Any(i => i.FormKey == formKey))
    {
        return;
    }
    formList.Items.Add(formKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    report.Actions.Add($"Added {label} to PDV_FLST_AllDeities.");
}

static void CheckPhase9Placements(Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    var expected = new (string RefEditorId, string BaseEditorId)[]
    {
        ("PDV_REFR_BosmerLivingStorySignal", "PDV_ACTI_BosmerLivingStorySignal"),
        ("PDV_REFR_BosmerExchangeSignal", "PDV_ACTI_BosmerExchangeSignal"),
        ("PDV_REFR_BosmerBanditRoadSignal", "PDV_ACTI_BosmerBanditRoadSignal"),
        ("PDV_REFR_BosmerPactPositiveSignal", "PDV_ACTI_BosmerPactPositiveSignal"),
        ("PDV_REFR_StateTransitionConfirmRite", "PDV_ACTI_StateTransitionConfirmRite"),
    };

    foreach (var (refEditorId, baseEditorId) in expected)
    {
        if (!index.TryGetValue(refEditorId, out var refRecord))
        {
            report.Errors.Add($"Missing placed reference: {refEditorId}");
            continue;
        }
        if (refRecord is not PlacedObject placed)
        {
            report.Errors.Add($"{refEditorId} is {refRecord.GetType().Name}, expected PlacedObject/REFR.");
            continue;
        }
        if (!index.TryGetValue(baseEditorId, out var baseRecord))
        {
            report.Errors.Add($"Missing base activator for {refEditorId}: {baseEditorId}");
            continue;
        }
        if (placed.Base.FormKey != baseRecord.FormKey)
        {
            report.Errors.Add($"{refEditorId} points at {placed.Base.FormKey}, expected {baseEditorId} ({baseRecord.FormKey}).");
            continue;
        }
        report.Actions.Add($"{refEditorId} -> {baseEditorId}");
    }
}

static TranslatedString Tx(string value) => new(Language.English, value);

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length)
    {
        return null;
    }
    return args[index + 1];
}

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod, IEnumerable<FormKey> existingKeys)
    {
        modKey = mod.ModKey;
        usedIds = existingKeys
            .Where(k => k.ModKey.Equals(modKey))
            .Select(ParseLocalId)
            .ToHashSet();
        nextId = usedIds.Count == 0 ? 0x800u : Math.Max(0x800u, usedIds.Max() + 1);
    }

    public FormKey Next()
    {
        while (usedIds.Contains(nextId))
        {
            nextId++;
        }
        var id = nextId++;
        usedIds.Add(id);
        return new FormKey(modKey, id);
    }

    private static uint ParseLocalId(FormKey key)
    {
        var text = key.IDString();
        return Convert.ToUInt32(text, 16);
    }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
