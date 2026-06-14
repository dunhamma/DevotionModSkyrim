using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

// Minimal, scoped framework-ESP author: make PDV_Deity_BaanDar Start-Game-Enabled
// by copying the QUST header Flags + Priority from a known-good sibling deity
// (default PDV_Deity_Yffre), so BaanDar matches its working Bosmer-path siblings
// byte-for-byte instead of hardcoding a flag value. In-place write of the
// framework ESP via the established Mutagen load -> modify -> backup -> save pattern.

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var espPath = GetArg(args, "--esp") ?? defaultEsp;
var referenceId = GetArg(args, "--reference") ?? "PDV_Deity_Yffre";
var targetId = GetArg(args, "--target") ?? "PDV_Deity_BaanDar";
var dryRun = args.Contains("--dry-run");

var report = new AuthorReport
{
    EspPath = espPath,
    ReferenceEditorId = referenceId,
    TargetEditorId = targetId,
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

    var reference = FindQuest(mod, referenceId);
    var target = FindQuest(mod, targetId);

    report.ReferenceFlagsBefore = (int)reference.Flags;
    report.ReferencePriorityBefore = reference.Priority;
    report.TargetFlagsBefore = (int)target.Flags;
    report.TargetPriorityBefore = target.Priority;

    // Copy the exact header flags + priority from the known-good sibling.
    target.Flags = reference.Flags;
    target.Priority = reference.Priority;

    report.TargetFlagsAfter = (int)target.Flags;
    report.TargetPriorityAfter = target.Priority;
    report.StartGameEnabledAfter = target.Flags.HasFlag(Quest.Flag.StartGameEnabled);
    report.Actions.Add(
        $"Set {targetId}.Flags={(int)target.Flags} (was {report.TargetFlagsBefore}), " +
        $"Priority={target.Priority} (was {report.TargetPriorityBefore}), " +
        $"copied from {referenceId}.");

    if (!dryRun)
    {
        var espDir = Path.GetDirectoryName(Path.GetFullPath(espPath))!;
        var backupDir = Path.Combine(espDir, "Backups", "baandar-sge");
        Directory.CreateDirectory(backupDir);
        var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
        var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
        File.Copy(espPath, backupPath, overwrite: false);
        report.BackupPath = backupPath;

        var tempPath = $"{espPath}.baandar.tmp";
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

static Quest FindQuest(SkyrimMod mod, string editorId)
{
    foreach (var quest in mod.Quests)
    {
        if (string.Equals(quest.EditorID, editorId, StringComparison.OrdinalIgnoreCase))
        {
            return quest;
        }
    }
    throw new InvalidOperationException($"Quest not found in {mod.ModKey.FileName}: {editorId}");
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

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ReferenceEditorId { get; set; }
    public string? TargetEditorId { get; set; }
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public int ReferenceFlagsBefore { get; set; }
    public int ReferencePriorityBefore { get; set; }
    public int TargetFlagsBefore { get; set; }
    public int TargetPriorityBefore { get; set; }
    public int TargetFlagsAfter { get; set; }
    public int TargetPriorityAfter { get; set; }
    public bool StartGameEnabledAfter { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
