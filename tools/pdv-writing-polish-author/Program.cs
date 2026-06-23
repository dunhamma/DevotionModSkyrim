using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    CheckOnly = checkOnly,
    StartedAt = DateTimeOffset.Now
};

DescriptionTarget[] descriptionTargets =
[
    new("PDV_MGEF_BosmerTaleCarried", RecordType.MagicEffect, "You told the tale, and others listened. (Effect: +5 Speech for 10 minutes.)"),
    new("PDV_SPEL_BosmerTaleCarried", RecordType.Spell, "You told the tale, and others listened. (Effect: +5 Speech for 10 minutes.)"),
    new("PDV_MGEF_BosmerScalesAtRest", RecordType.MagicEffect, "The account is even. For a while, every bargain falls a little your way. (Effect: +10 Speech for 10 minutes.)"),
    new("PDV_SPEL_BosmerScalesAtRest", RecordType.Spell, "The account is even. For a while, every bargain falls a little your way. (Effect: +10 Speech for 10 minutes.)"),
    new("PDV_MGEF_BosmerBaanDarGap", RecordType.MagicEffect, "Baan Dar opens a gap. Run. (Effect: +40% Movement Speed for 15 seconds.)"),
    new("PDV_SPEL_BosmerBaanDarGap", RecordType.Spell, "Baan Dar opens a gap. Run. (Effect: +40% Movement Speed for 15 seconds.)"),
    new("PDV_MGEF_BosmerNaming_Hunter", RecordType.MagicEffect, "You told yourself to become the Hunter. Your aim runs truer. (Effect: +5 Archery.)"),
    new("PDV_SPEL_BosmerNaming_Hunter", RecordType.Spell, "You told yourself to become the Hunter. Your aim runs truer. (Effect: +5 Archery.)"),
    new("PDV_MGEF_BosmerNaming_Speaker", RecordType.MagicEffect, "You told yourself to become the Speaker. People lean in to listen. (Effect: +5 Speech.)"),
    new("PDV_SPEL_BosmerNaming_Speaker", RecordType.Spell, "You told yourself to become the Speaker. People lean in to listen. (Effect: +5 Speech.)"),
    new("PDV_MGEF_BosmerNaming_Wanderer", RecordType.MagicEffect, "You told yourself to become the Wanderer. The road tires you less. (Effect: +8% Stamina Regeneration.)"),
    new("PDV_SPEL_BosmerNaming_Wanderer", RecordType.Spell, "You told yourself to become the Wanderer. The road tires you less. (Effect: +8% Stamina Regeneration.)"),
    new("PDV_MGEF_BosmerNaming_Keeper", RecordType.MagicEffect, "You told yourself to become the Keeper. You carry more of what the people need kept. (Effect: +15 Carry Weight.)"),
    new("PDV_SPEL_BosmerNaming_Keeper", RecordType.Spell, "You told yourself to become the Keeper. You carry more of what the people need kept. (Effect: +15 Carry Weight.)"),
    new("PDV_MSG_BosmerSuggestLivingStory", RecordType.Message, "Your recent life points toward the Living Story. Accept this path offer? A rite still confirms the change."),
    new("PDV_MSG_BosmerSuggestExchange", RecordType.Message, "Your recent life points toward the Exchange. Accept this path offer? A rite still confirms the change."),
    new("PDV_MSG_BosmerSuggestBanditRoad", RecordType.Message, "Your recent life points toward the Bandit Road. Accept this path offer? A rite still confirms the change."),
    new("PDV_MSG_BosmerSuggestOldContract", RecordType.Message, "Your recent life points toward the Old Contract. Accept this path offer? A rite still confirms the change.")
];

NameTarget[] nameTargets =
[
    new("PDV_MGEF_Neglect_Dunmer_Magicka", RecordType.MagicEffect, "The Ancestors' Silence"),
    new("PDV_SPEL_Neglect_Dunmer", RecordType.Spell, "The Ancestors' Silence")
];

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    foreach (var target in descriptionTargets)
    {
        if (target.Type == RecordType.MagicEffect)
        {
            var record = RequireRecord<MagicEffect>(index, target.EditorId);
            CheckOrSetString(record.Description?.String ?? "", target.Description, target.EditorId, "Description", report, value => record.Description = Tx(value));
        }
        else if (target.Type == RecordType.Spell)
        {
            var record = RequireRecord<Spell>(index, target.EditorId);
            CheckOrSetString(record.Description?.String ?? "", target.Description, target.EditorId, "Description", report, value => record.Description = Tx(value));
        }
        else
        {
            var record = RequireRecord<Message>(index, target.EditorId);
            CheckOrSetString(record.Description?.String ?? "", target.Description, target.EditorId, "Description", report, value => record.Description = Tx(value));
        }
    }

    var scales = RequireRecord<Spell>(index, "PDV_SPEL_BosmerScalesAtRest");
    if (scales.Effects.Count == 0 || scales.Effects[0].Data is null)
    {
        report.Errors.Add("PDV_SPEL_BosmerScalesAtRest: missing first effect data.");
    }
    else
    {
        CheckOrSetInt(scales.Effects[0].Data!.Duration, 600, "PDV_SPEL_BosmerScalesAtRest", "Effects[0].Data.Duration", report, value => scales.Effects[0].Data!.Duration = value);
    }

    var baanDarGap = RequireRecord<Spell>(index, "PDV_SPEL_BosmerBaanDarGap");
    if (baanDarGap.Effects.Count == 0 || baanDarGap.Effects[0].Data is null)
    {
        report.Errors.Add("PDV_SPEL_BosmerBaanDarGap: missing first effect data.");
    }
    else
    {
        CheckOrSetFloat(baanDarGap.Effects[0].Data!.Magnitude, 40.0f, "PDV_SPEL_BosmerBaanDarGap", "Effects[0].Data.Magnitude", report, value => baanDarGap.Effects[0].Data!.Magnitude = value);
        CheckOrSetInt(baanDarGap.Effects[0].Data!.Duration, 15, "PDV_SPEL_BosmerBaanDarGap", "Effects[0].Data.Duration", report, value => baanDarGap.Effects[0].Data!.Duration = value);
    }

    foreach (var target in nameTargets)
    {
        if (target.Type == RecordType.MagicEffect)
        {
            var record = RequireRecord<MagicEffect>(index, target.EditorId);
            CheckOrSetString(record.Name?.String ?? "", target.Name, target.EditorId, "Name", report, value => record.Name = Tx(value));
        }
        else
        {
            var record = RequireRecord<Spell>(index, target.EditorId);
            CheckOrSetString(record.Name?.String ?? "", target.Name, target.EditorId, "Name", report, value => record.Name = Tx(value));
        }
    }

    if (report.Errors.Count == 0 && !checkOnly)
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "writing-polish");
    }

    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Errors.Add(ex.ToString());
}

report.CompletedAt = DateTimeOffset.Now;
Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
return report.Status == "PASS" ? 0 : 1;

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
    where T : class, ISkyrimMajorRecordGetter
{
    if (!index.TryGetValue(editorId, out var existing))
    {
        throw new InvalidOperationException($"{editorId} not found in the framework ESP.");
    }

    if (existing is not T typed)
    {
        throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static void CheckOrSetString(string actual, string expected, string editorId, string field, AuthorReport report, Action<string> set)
{
    if (actual == expected)
    {
        report.Actions.Add($"{editorId}.{field}: already correct.");
        return;
    }

    if (report.CheckOnly)
    {
        report.Errors.Add($"{editorId}.{field}: actual='{actual}' expected='{expected}'.");
        return;
    }

    set(expected);
    report.Actions.Add($"{editorId}.{field}: updated.");
}

static void CheckOrSetInt(int actual, int expected, string editorId, string field, AuthorReport report, Action<int> set)
{
    if (actual == expected)
    {
        report.Actions.Add($"{editorId}.{field}: already correct.");
        return;
    }

    if (report.CheckOnly)
    {
        report.Errors.Add($"{editorId}.{field}: actual={actual} expected={expected}.");
        return;
    }

    set(expected);
    report.Actions.Add($"{editorId}.{field}: updated {actual} -> {expected}.");
}

static void CheckOrSetFloat(float actual, float expected, string editorId, string field, AuthorReport report, Action<float> set)
{
    if (Math.Abs(actual - expected) < 0.001f)
    {
        report.Actions.Add($"{editorId}.{field}: already correct.");
        return;
    }

    if (report.CheckOnly)
    {
        report.Errors.Add($"{editorId}.{field}: actual={actual} expected={expected}.");
        return;
    }

    set(expected);
    report.Actions.Add($"{editorId}.{field}: updated {actual} -> {expected}.");
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

enum RecordType { MagicEffect, Spell, Message }
record DescriptionTarget(string EditorId, RecordType Type, string Description);
record NameTarget(string EditorId, RecordType Type, string Name);
record AuthorReport
{
    public string Status { get; set; } = "PENDING";
    public string EspPath { get; set; } = "";
    public bool DryRun { get; set; }
    public bool CheckOnly { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset CompletedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<string> TouchedFiles { get; } = [];
}
