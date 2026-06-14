using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

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

    foreach (var deity in DeityBalancingTarget.All)
    {
        var quest = RequireRecord<Quest>(index, deity.EditorId);
        WireQuestScript(quest, deity.ScriptName, new ScriptProperty[]
        {
            FloatProp("ThresholdSeeker", 25.0f),
            FloatProp("ThresholdDevoted", 50.0f),
            FloatProp("ThresholdChampion", 85.0f),
            BoolProp("IsAedric", deity.IsAedric)
        });
        report.Actions.Add($"Retuned {deity.EditorId}: thresholds 25/50/85; IsAedric={deity.IsAedric}.");
    }

    WriteModIfNeeded(mod, espPath, dryRun, report, "balancing");
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

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
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

static void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(quest.VirtualMachineAdapter.Scripts, scriptName);
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

record DeityBalancingTarget(string EditorId, string ScriptName, bool IsAedric)
{
    public static readonly DeityBalancingTarget[] All =
    [
        new("PDV_Deity_Kyne", "PDV_Deity_Kyne", true),
        new("PDV_Deity_Talos", "PDV_Deity_Talos", true),
        new("PDV_Deity_AuriEl", "PDV_Deity_AuriEl", true),
        new("PDV_Deity_Yffre", "PDV_Deity_Yffre", true),
        new("PDV_Deity_Zen", "PDV_Deity_Zen", true),
        new("PDV_Deity_BaanDar", "PDV_Deity_BaanDar", false)
    ];
}

class AuthorReport
{
    public string EspPath { get; set; } = "";
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public string Status { get; set; } = "PENDING";
    public string? BackupPath { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> TouchedFiles { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
