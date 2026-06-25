// pdv-daedric-offer-title-author
// Title-only author/check helper for the 16 Daedric commitment MESG records.
// Bodies and buttons are intentionally untouched.

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var titles = new[]
{
    new TitleDef("PDV_Msg_Daedric_Azura_Commitment", "Azura's Twilight"),
    new TitleDef("PDV_Msg_Daedric_Boethiah_Commitment", "Boethiah's Trial"),
    new TitleDef("PDV_Msg_Daedric_Vile_Commitment", "Clavicus Vile's Bargain"),
    new TitleDef("PDV_Msg_Daedric_Mora_Commitment", "Hermaeus Mora's Unread Pages"),
    new TitleDef("PDV_Msg_Daedric_Hircine_Commitment", "Hircine's Hunt"),
    new TitleDef("PDV_Msg_Daedric_Malacath_Commitment", "Malacath's Oath"),
    new TitleDef("PDV_Msg_Daedric_Dagon_Commitment", "Mehrunes Dagon's Ruin"),
    new TitleDef("PDV_Msg_Daedric_Mephala_Commitment", "Mephala's Web"),
    new TitleDef("PDV_Msg_Daedric_Meridia_Commitment", "Meridia's Light"),
    new TitleDef("PDV_Msg_Daedric_Molag_Commitment", "Molag Bal's Grip"),
    new TitleDef("PDV_Msg_Daedric_Namira_Commitment", "Namira's Dark"),
    new TitleDef("PDV_Msg_Daedric_Nocturnal_Commitment", "Nocturnal's Shadow"),
    new TitleDef("PDV_Msg_Daedric_Peryite_Commitment", "Peryite's Order"),
    new TitleDef("PDV_Msg_Daedric_Sanguine_Commitment", "Sanguine's Revel"),
    new TitleDef("PDV_Msg_Daedric_Sheo_Commitment", "Sheogorath's Madness"),
    new TitleDef("PDV_Msg_Daedric_Vaermina_Commitment", "Vaermina's Dream"),
};

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var report = new AuthorReport { EspPath = espPath, DryRun = dryRun, CheckOnly = checkOnly, StartedAt = DateTimeOffset.Now };

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Devotion ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var beforeBodies = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    foreach (var title in titles)
    {
        var message = RequireMessage(index, title.EditorId);
        beforeBodies[title.EditorId] = message.Description?.String ?? "";
        if (!checkOnly)
        {
            if ((message.Name?.String ?? "") != title.Title)
            {
                report.Actions.Add($"{title.EditorId}: title '{message.Name?.String}' -> '{title.Title}'.");
            }
            message.Name = Tx(title.Title);
        }
    }

    foreach (var title in titles)
    {
        var message = RequireMessage(index, title.EditorId);
        var actualTitle = message.Name?.String ?? "";
        if (actualTitle != title.Title)
        {
            report.Errors.Add($"{title.EditorId}: expected title '{title.Title}', found '{actualTitle}'.");
        }
        var actualBody = message.Description?.String ?? "";
        if (beforeBodies.TryGetValue(title.EditorId, out var beforeBody) && actualBody != beforeBody)
        {
            report.Errors.Add($"{title.EditorId}: body changed; this helper is title-only.");
        }
        report.Actions.Add($"{title.EditorId}: title [{actualTitle}]");
    }

    if (!checkOnly)
    {
        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report);
        }
        else
        {
            report.Actions.Add("Write skipped: errors present (fail-closed). No ESP bytes changed.");
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords().OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static Message RequireMessage(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (!index.TryGetValue(editorId, out var existing))
    {
        throw new InvalidOperationException($"{editorId} not found in Devotion.esp.");
    }
    if (existing is not Message message)
    {
        throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected Message.");
    }
    return message;
}

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report)
{
    if (dryRun)
    {
        return;
    }
    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "daedric-offer-titles");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;
    var tempPath = $"{espPath}.daedric-offer-titles.tmp";
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

sealed record TitleDef(string EditorId, string Title);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public bool CheckOnly { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = new();
    public List<string> Actions { get; } = new();
    public List<string> Errors { get; } = new();
    public string? Exception { get; set; }
}
