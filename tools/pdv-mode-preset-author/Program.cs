using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimGlobal = Mutagen.Bethesda.Skyrim.Global;
using SkyrimGlobalFloat = Mutagen.Bethesda.Skyrim.GlobalFloat;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var dryRun = args.Contains("--dry-run");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

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
    var allocator = new FormKeyAllocator(mod, index.Values.Select(record => record.FormKey));

    var modeGlobal = EnsureGlobal(mod, index, allocator, "PDV_GLO_Mode", 0.0f, report);
    var modeQuest = EnsureModeQuest(mod, index, allocator, report);
    var manager = Require<Quest>(index, "PDV__ManagerQuest");
    var mcm = Require<Quest>(index, "PDV_MCM");
    var router = Require<Quest>(index, "PDV_ActionRouter");

    WireQuestScript(modeQuest, "PDV_ModePreset", new ScriptProperty[]
    {
        ObjectProp("PDV_Manager", manager.FormKey),
        ObjectProp("PDV_GLO_Mode", modeGlobal.FormKey),
    }, report);
    WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
    {
        ObjectProp("PDV_ModePresetRef", modeQuest.FormKey),
    }, report);
    WireQuestScript(mcm, "PDV_MCM", new ScriptProperty[]
    {
        ObjectProp("PDV_ModePresetRef", modeQuest.FormKey),
    }, report);
    WireQuestScript(router, "PDV_ActionRouter", new ScriptProperty[]
    {
        ObjectProp("PDV_ModePresetRef", modeQuest.FormKey),
    }, report);

    WriteModIfNeeded(mod, espPath, dryRun, report, "experience-mode");
    report.Status = report.Errors.Count == 0 ? "PASS" : "PARTIAL";
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

static T Require<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId) where T : class, ISkyrimMajorRecordGetter
{
    if (!index.TryGetValue(editorId, out var record))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }
    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} is {record.GetType().Name}, expected {typeof(T).Name}.");
    }
    return typed;
}

static SkyrimGlobal EnsureGlobal(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    float value,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimGlobal existingGlobal)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Global.");
        }

        ConfigureGlobal(existingGlobal, editorId, value);
        report.Actions.Add($"verified global {editorId}");
        return existingGlobal;
    }

    var created = new SkyrimGlobalFloat(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureGlobal(created, editorId, value);
    mod.Globals.Add(created);
    index[editorId] = created;
    report.Actions.Add($"created global {editorId}");
    return created;
}

static void ConfigureGlobal(SkyrimGlobal global, string editorId, float value)
{
    global.EditorID = editorId;
    global.FormVersion = 44;
    global.RawFloat = value;
}

static Quest EnsureModeQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    AuthorReport report)
{
    const string editorId = "PDV_ModePreset";
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest existingQuest)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }

        ConfigureModeQuest(existingQuest);
        report.Actions.Add($"verified quest {editorId}");
        return existingQuest;
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureModeQuest(created);
    mod.Quests.Add(created);
    index[editorId] = created;
    report.Actions.Add($"created SGE quest {editorId}");
    return created;
}

static void ConfigureModeQuest(Quest quest)
{
    quest.EditorID = "PDV_ModePreset";
    quest.FormVersion = 44;
    quest.Name = Tx("PDV_ModePreset");
    quest.Flags |= Quest.Flag.StartGameEnabled;
    quest.Priority = 50;
    quest.Type = Quest.TypeEnum.None;
}

static void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties, AuthorReport report)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(quest.VirtualMachineAdapter.Scripts, scriptName, report);
    UpsertProperties(script, properties, report, $"{quest.EditorID}.{scriptName}");
}

static ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName, AuthorReport report)
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
    report.Actions.Add($"attached script {scriptName}");
    return script;
}

static void UpsertProperties(ScriptEntry script, IEnumerable<ScriptProperty> properties, AuthorReport report, string ownerLabel)
{
    foreach (var property in properties)
    {
        var changed = false;
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
            changed = true;
        }

        script.Properties.Add(property);
        report.Actions.Add($"{ownerLabel}.{property.Name} -> {DescribeProperty(property)}{(changed ? " [rewired]" : "")}");
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

static string DescribeProperty(ScriptProperty property)
{
    if (property is ScriptObjectProperty objectProperty)
    {
        return objectProperty.Object.FormKeyNullable?.ToString() ?? "unassigned";
    }
    return property.Name;
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
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
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
        return Convert.ToUInt32(key.IDString(), 16);
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
