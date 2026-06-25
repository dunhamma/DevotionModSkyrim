using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultContract = @"references\authoring\PDV_DaedricPrinceRecordContracts.json";

var checkOnly = args.Contains("--check");
var dryRun = args.Contains("--dry-run");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var contractPath = Path.GetFullPath(GetArg(args, "--contract") ?? defaultContract);

var report = new AuthorReport
{
    EspPath = espPath,
    ContractPath = contractPath,
    CheckOnly = checkOnly,
    DryRun = dryRun,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }
    if (!File.Exists(contractPath))
    {
        throw new FileNotFoundException("Daedric contract not found.", contractPath);
    }

    var titleUpdates = LoadCommitmentTitles(contractPath);
    if (titleUpdates.Count != 16)
    {
        throw new InvalidOperationException($"Expected 16 Daedric commitment messages, found {titleUpdates.Count}.");
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    foreach (var update in titleUpdates)
    {
        if (!index.TryGetValue(update.EditorId, out var record) || record is not Message message)
        {
            report.Errors.Add($"{update.EditorId}: missing or not a Message.");
            continue;
        }

        var currentTitle = message.Name?.String ?? "";
        if (currentTitle == update.Title)
        {
            report.Actions.Add($"{update.EditorId}: title already '{update.Title}'.");
            continue;
        }

        report.Actions.Add($"{update.EditorId}: title '{currentTitle}' -> '{update.Title}'.");
        if (!checkOnly)
        {
            message.Name = Tx(update.Title);
        }
    }

    if (!checkOnly && report.Errors.Count == 0)
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "daedric-title");
    }
    else if (checkOnly)
    {
        report.Actions.Add("Read-only check complete; ESP not written.");
    }
    else
    {
        report.Actions.Add("Write skipped: errors present (fail-closed).");
    }

    if (checkOnly)
    {
        foreach (var update in titleUpdates)
        {
            if (!index.TryGetValue(update.EditorId, out var record) || record is not Message message)
            {
                continue;
            }

            var currentTitle = message.Name?.String ?? "";
            if (currentTitle != update.Title)
            {
                report.Errors.Add($"{update.EditorId}: title is '{currentTitle}', expected '{update.Title}'.");
            }
        }
    }

    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
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

static List<TitleUpdate> LoadCommitmentTitles(string contractPath)
{
    using var doc = JsonDocument.Parse(File.ReadAllText(contractPath));
    if (!doc.RootElement.TryGetProperty("princes", out var princes) || princes.ValueKind != JsonValueKind.Array)
    {
        throw new InvalidOperationException("Daedric contract is missing princes[].");
    }

    var updates = new List<TitleUpdate>();
    foreach (var prince in princes.EnumerateArray())
    {
        var displayName = prince.GetProperty("displayName").GetString()
            ?? throw new InvalidOperationException("Prince entry missing displayName.");
        var messages = prince.GetProperty("messages");
        foreach (var message in messages.EnumerateArray())
        {
            var editorId = message.GetProperty("editorId").GetString();
            if (!string.IsNullOrWhiteSpace(editorId) && editorId.EndsWith("_Commitment", StringComparison.Ordinal))
            {
                updates.Add(new TitleUpdate(editorId, displayName));
                break;
            }
        }
    }

    return updates;
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords().OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report, string backupSubdir)
{
    if (dryRun)
    {
        report.Actions.Add("DRY-RUN: parsing and record resolution complete; ESP NOT written.");
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

sealed record TitleUpdate(string EditorId, string Title);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string? EspPath { get; set; }
    public string? ContractPath { get; set; }
    public bool CheckOnly { get; set; }
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = new();
    public List<string> Actions { get; } = new();
    public List<string> Errors { get; } = new();
    public string? Exception { get; set; }
}
