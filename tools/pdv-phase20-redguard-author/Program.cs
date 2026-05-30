using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase20RedguardImplementationCosting.manifest.json";
const string redguardSectTrack = "PDV_StateTrack_RedguardSect";
const string managerRecord = "PDV__ManagerQuest";
const string proofActivatorModel = @"Architecture\HighHrothgar\MQEtchedShrineActivator.nif";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkPlacements = args.Contains("--check-placements");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    if (!File.Exists(manifestPath))
    {
        throw new FileNotFoundException("Redguard implementation manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    var sectLabels = GetStateLabels(manifest, redguardSectTrack);
    var triggerDefinitions = BuildTriggerDefinitions(manifest);
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (checkPlacements)
    {
        CheckTriggerPlacements(index, triggerDefinitions, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Redguard placement check failed.");
        }

        report.Status = "PASS";
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
        var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");
        var sectGlobal = RequireRecord<Global>(index, "PDV_GLO_RedguardSect");
        var eventBus = RequireRecord<Quest>(index, "PDV_EventBus");
        var playerRef = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x14);

        var sectTrack = createMissing
            ? EnsureQuest(mod, index, allocator, redguardSectTrack, report)
            : RequireRecord<Quest>(index, redguardSectTrack);
        ConfigureQuestShell(sectTrack, redguardSectTrack);
        WireQuestScript(sectTrack, "PDV_StateTrack", new ScriptProperty[]
        {
            StringProp("TrackName", "RedguardSect"),
            ObjectProp("StateGlobal", sectGlobal.FormKey),
            ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
            StringListProp("StateLabels", sectLabels),
        });
        report.Actions.Add("Ensured PDV_StateTrack_RedguardSect is wired to PDV_StateTrack.");

        foreach (var trigger in triggerDefinitions)
        {
            if (!createMissing && !index.ContainsKey(trigger.EditorId))
            {
                throw new InvalidOperationException($"Required trigger shell is missing: {trigger.EditorId}");
            }

            EnsureSignalActivator(mod, index, allocator, trigger, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey, report);
        }

        var manager = RequireRecord<Quest>(index, managerRecord);
        WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
        {
            ObjectProp("PDV_RedguardSectTrack", sectTrack.FormKey),
        });
        report.Actions.Add("Wired Redguard sect property on PDV__ManagerQuest.");

        WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-redguard");
        report.Status = "PASS";
    }
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

static RedguardManifest LoadManifest(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<RedguardManifest>(File.ReadAllText(manifestPath));
    if (parsed is null)
    {
        throw new InvalidOperationException("Redguard implementation manifest could not be parsed.");
    }

    if (parsed.stateSurfaces is null || parsed.stateSurfaces.Count == 0)
    {
        throw new InvalidOperationException("Redguard implementation manifest has no state surfaces.");
    }

    return parsed;
}

static string[] GetStateLabels(RedguardManifest manifest, string editorId)
{
    var surface = manifest.stateSurfaces!.FirstOrDefault(candidate => string.Equals(candidate.editorId, editorId, StringComparison.OrdinalIgnoreCase));
    if (surface?.@enum is null)
    {
        throw new InvalidOperationException($"Redguard implementation manifest is missing {editorId} enum.");
    }

    var ordered = surface.@enum
        .OrderBy(entry => entry.value)
        .Select(entry => entry.name ?? throw new InvalidOperationException($"{editorId} has an enum entry without a name."))
        .ToArray();

    if (ordered.Length != 3 || ordered[0] != "Crown" || ordered[1] != "Forebear" || ordered[2] != "AshAbah")
    {
        throw new InvalidOperationException($"{editorId} enum does not match the locked Redguard sect contract.");
    }

    return ordered;
}

static TriggerDefinition[] BuildTriggerDefinitions(RedguardManifest manifest)
{
    var definitions = new List<TriggerDefinition>();
    foreach (var trigger in manifest.triggerSurfaces ?? [])
    {
        if (!string.Equals(trigger.recordStatus, "source-scaffolded", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(trigger.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (!string.Equals(trigger.recordType, "ACTI", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Redguard trigger surface {trigger.id ?? "(unknown)"} must be an ACTI record.");
        }

        if (string.IsNullOrWhiteSpace(trigger.editorId)
            || trigger.routeId <= 0
            || trigger.requiredOriginRace != 9
            || string.IsNullOrWhiteSpace(trigger.name)
            || string.IsNullOrWhiteSpace(trigger.activateText)
            || string.IsNullOrWhiteSpace(trigger.signalSourceId))
        {
            throw new InvalidOperationException($"Redguard trigger surface metadata is incomplete for {trigger.id ?? "(unknown)"}.");
        }

        definitions.Add(new TriggerDefinition(
            trigger.editorId,
            trigger.placementRefEditorId ?? "",
            trigger.routeId,
            trigger.requiredOriginRace,
            trigger.signalValue,
            trigger.signalSourceId,
            trigger.oncePerDayKey ?? "",
            trigger.name,
            trigger.activateText));
    }

    return definitions.ToArray();
}

static Quest EnsureQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest quest)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }

        return quest;
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Quests.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created quest {editorId}.");
    return created;
}

static SkyrimActivator EnsureSignalActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    TriggerDefinition trigger,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal,
    AuthorReport report)
{
    SkyrimActivator activator;
    if (index.TryGetValue(trigger.EditorId, out var existing))
    {
        if (existing is not SkyrimActivator typed)
        {
            throw new InvalidOperationException($"{trigger.EditorId} already exists as {existing.GetType().Name}, expected Activator.");
        }

        activator = typed;
        activator.EditorID = trigger.EditorId;
    }
    else
    {
        activator = new SkyrimActivator(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Activators.Add(activator);
        index[trigger.EditorId] = activator;
        report.Actions.Add($"Created trigger activator {trigger.EditorId}.");
    }

    activator.FormVersion = 44;
    activator.EditorID = trigger.EditorId;
    activator.Name = Tx(trigger.Name);
    activator.ActivateTextOverride = Tx(trigger.ActivateText);
    activator.Model ??= new Model();
    activator.Model.File = proofActivatorModel;
    WireActivatorScript(activator, "PDV_EventSignalActivator", new ScriptProperty[]
    {
        ObjectProp("PDV_EventBusService", eventBus),
        ObjectProp("PlayerREF", playerRef),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
        IntProp("RouteId", trigger.RouteId),
        IntProp("RequiredOriginRace", trigger.RequiredOriginRace),
        IntProp("SignalValue", trigger.SignalValue),
        StringProp("SignalSourceId", trigger.SignalSourceId),
        StringProp("TraceLabel", trigger.EditorId),
        StringProp("OncePerDayKey", trigger.OncePerDayKey),
    });
    report.Actions.Add($"Ensured trigger activator {trigger.EditorId} route {trigger.RouteId}.");
    return activator;
}

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (!index.TryGetValue(editorId, out var record))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }

    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} exists as {record.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static void CheckTriggerPlacements(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<TriggerDefinition> triggers,
    AuthorReport report)
{
    foreach (var trigger in triggers)
    {
        if (string.IsNullOrWhiteSpace(trigger.PlacementRefEditorId))
        {
            report.Errors.Add($"{trigger.EditorId} is missing placementRefEditorId in the manifest.");
            continue;
        }

        if (!index.TryGetValue(trigger.PlacementRefEditorId, out var refRecord))
        {
            report.Errors.Add($"Missing placed reference: {trigger.PlacementRefEditorId}");
            continue;
        }

        if (refRecord is not PlacedObject placed)
        {
            report.Errors.Add($"{trigger.PlacementRefEditorId} is {refRecord.GetType().Name}, expected PlacedObject/REFR.");
            continue;
        }

        if (!index.TryGetValue(trigger.EditorId, out var baseRecord))
        {
            report.Errors.Add($"Missing base activator for {trigger.PlacementRefEditorId}: {trigger.EditorId}");
            continue;
        }

        if (placed.Base.FormKey != baseRecord.FormKey)
        {
            report.Errors.Add($"{trigger.PlacementRefEditorId} points at {placed.Base.FormKey}, expected {trigger.EditorId} ({baseRecord.FormKey}).");
            continue;
        }

        report.Actions.Add($"{trigger.PlacementRefEditorId} -> {trigger.EditorId}");
    }
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
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
    var script = scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
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

static ScriptStringProperty StringProp(string name, string value)
{
    return new ScriptStringProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
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

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report, string backupSubdir)
{
    if (dryRun)
    {
        return;
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", backupSubdir);
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.{backupSubdir}.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
}

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length)
    {
        return null;
    }

    return args[index + 1];
}

static TranslatedString Tx(string value) => new(Language.English, value);

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod, IEnumerable<FormKey> existingKeys)
    {
        modKey = mod.ModKey;
        usedIds = existingKeys
            .Where(key => key.ModKey.Equals(modKey))
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

sealed class RedguardManifest
{
    public string? id { get; set; }
    public string? implementationStatus { get; set; }
    public List<StateSurface>? stateSurfaces { get; set; }
    public List<ManifestTriggerSurface>? triggerSurfaces { get; set; }
}

sealed class StateSurface
{
    public string? editorId { get; set; }
    public List<StateEnumEntry>? @enum { get; set; }
}

sealed class StateEnumEntry
{
    public string? name { get; set; }
    public int value { get; set; }
}

sealed record TriggerDefinition(
    string EditorId,
    string PlacementRefEditorId,
    int RouteId,
    int RequiredOriginRace,
    int SignalValue,
    string SignalSourceId,
    string OncePerDayKey,
    string Name,
    string ActivateText);

sealed class ManifestTriggerSurface
{
    public string? id { get; set; }
    public string? recordStatus { get; set; }
    public string? recordType { get; set; }
    public string? editorId { get; set; }
    public string? placementRefEditorId { get; set; }
    public int routeId { get; set; }
    public int requiredOriginRace { get; set; }
    public int signalValue { get; set; }
    public string? signalSourceId { get; set; }
    public string? oncePerDayKey { get; set; }
    public string? name { get; set; }
    public string? activateText { get; set; }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
