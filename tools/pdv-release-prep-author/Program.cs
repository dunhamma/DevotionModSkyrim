using System.Text.Json;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = GetArg(args, "--esp") ?? defaultEsp;

var report = new ReleasePrepReport
{
    Mode = dryRun ? "dry-run" : write ? "write" : check ? "check" : "none",
    EspPath = espPath,
    StartedAt = DateTimeOffset.Now,
};

try
{
    if ((dryRun ? 1 : 0) + (write ? 1 : 0) + (check ? 1 : 0) != 1)
    {
        throw new InvalidOperationException("Choose exactly one mode: --dry-run, --write, or --check.");
    }

    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var presentBefore = ScanV1DialogueRecords(mod);
    report.DialogueRecords.AddRange(presentBefore);

    if (check)
    {
        foreach (var row in presentBefore.Where(row => row.Present))
        {
            report.Errors.Add($"{row.Kind} {row.FormId} {row.EditorId ?? "(unnamed)"} is still present for {row.Chain}.");
        }

        if (report.Errors.Count == 0)
        {
            report.Actions.Add("V1 voiced dialogue records are absent.");
            report.Status = "PASS";
        }
    }
    else
    {
        var changed = RemoveV1DialogueRecords(mod, report);
        report.WouldChange = changed;

        if (write && changed)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            var presentAfter = ScanV1DialogueRecords(readback).Where(row => row.Present).ToArray();
            if (presentAfter.Length > 0)
            {
                foreach (var row in presentAfter)
                {
                    report.Errors.Add($"Readback still has {row.Kind} {row.FormId} {row.EditorId ?? "(unnamed)"} for {row.Chain}.");
                }
            }
            else
            {
                report.Actions.Add("Readback PASS: all V1 voiced dialogue records are absent.");
            }
        }
        else if (write)
        {
            report.Actions.Add("No ESP write needed; V1 voiced dialogue records were already absent.");
        }
        else
        {
            report.Actions.Add("Dry run: no bytes written.");
        }

        if (report.Errors.Count == 0)
        {
            report.Status = "PASS";
        }
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

static bool RemoveV1DialogueRecords(SkyrimMod mod, ReleasePrepReport report)
{
    var changed = false;

    foreach (var target in V1DialogueTargets())
    {
        var topic = mod.DialogTopics.FirstOrDefault(record =>
            record.FormKey == target.TopicFormKey ||
            string.Equals(record.EditorID, target.TopicEditorId, StringComparison.OrdinalIgnoreCase));
        if (topic is not null)
        {
            var removedResponses = topic.Responses.RemoveAll(response => response.FormKey == target.InfoFormKey);
            if (removedResponses > 0)
            {
                report.Actions.Add($"Removed INFO {ToHousecarl(target.InfoFormKey)} from {target.TopicEditorId}.");
                changed = true;
            }

            mod.DialogTopics.Remove(topic);
            report.Actions.Add($"Removed DIAL {target.TopicEditorId}.");
            changed = true;
        }

        var branch = mod.DialogBranches.FirstOrDefault(record =>
            record.FormKey == target.BranchFormKey ||
            string.Equals(record.EditorID, target.BranchEditorId, StringComparison.OrdinalIgnoreCase));
        if (branch is not null)
        {
            mod.DialogBranches.Remove(branch);
            report.Actions.Add($"Removed DLBR {target.BranchEditorId}.");
            changed = true;
        }
    }

    if (!changed)
    {
        report.Actions.Add("No V1 voiced dialogue records were present.");
    }

    return changed;
}

static List<DialogueRecordSnapshot> ScanV1DialogueRecords(SkyrimMod mod)
{
    var rows = new List<DialogueRecordSnapshot>();
    foreach (var target in V1DialogueTargets())
    {
        var branch = mod.DialogBranches.FirstOrDefault(record =>
            record.FormKey == target.BranchFormKey ||
            string.Equals(record.EditorID, target.BranchEditorId, StringComparison.OrdinalIgnoreCase));
        rows.Add(DialogueRecordSnapshot.From(target.Chain, "DLBR", ToHousecarl(target.BranchFormKey), target.BranchEditorId, branch is not null));

        var topic = mod.DialogTopics.FirstOrDefault(record =>
            record.FormKey == target.TopicFormKey ||
            string.Equals(record.EditorID, target.TopicEditorId, StringComparison.OrdinalIgnoreCase));
        rows.Add(DialogueRecordSnapshot.From(target.Chain, "DIAL", ToHousecarl(target.TopicFormKey), target.TopicEditorId, topic is not null));

        var info = topic?.Responses.FirstOrDefault(response => response.FormKey == target.InfoFormKey)
            ?? mod.DialogTopics.SelectMany(record => record.Responses).FirstOrDefault(response => response.FormKey == target.InfoFormKey);
        rows.Add(DialogueRecordSnapshot.From(target.Chain, "INFO", ToHousecarl(target.InfoFormKey), info?.EditorID, info is not null));
    }

    return rows;
}

static void WriteMod(SkyrimMod mod, string espPath, ReleasePrepReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "release-prep");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.release-prep.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");
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

static FormKey F(uint id) => new(ModKey.FromNameAndExtension("Devotion.esp"), id);

static string ToHousecarl(FormKey key) => $"{key.IDString().ToUpperInvariant()}:{key.ModKey.FileName}";

static DialogueTarget[] V1DialogueTargets() =>
[
    new(
        "Phase 11 Arngeir/Kyne recognition",
        F(0x0704F2),
        "PDV_DIAL_Phase11ArngeirKyneRecognitionBranch",
        F(0x0704F3),
        "PDV_DIAL_Phase11ArngeirKyneRecognitionTopic",
        F(0x0704F4)),
    new(
        "Froki / Kyne Champion",
        F(0x070A89),
        "PDV_DIAL_Nord_Froki_KyneChampionBranch",
        F(0x070A8A),
        "PDV_TIF_Nord_Froki_KyneChampion",
        F(0x070A8B)),
    new(
        "Heimskr / Talos Champion",
        F(0x070A8C),
        "PDV_DIAL_Nord_Heimskr_TalosChampionBranch",
        F(0x070A8D),
        "PDV_TIF_Nord_Heimskr_TalosChampion",
        F(0x070A8E)),
    new(
        "Andurs / broad death-rite",
        F(0x070FF0),
        "PDV_DIAL_Nord_Andurs_DeathRiteBranch",
        F(0x070FF1),
        "PDV_TIF_Nord_Andurs_DeathRite",
        F(0x070FF2)),
    new(
        "Aela / Hircine tension",
        F(0x070FF3),
        "PDV_DIAL_Nord_Aela_HircineTensionBranch",
        F(0x070FF4),
        "PDV_TIF_Nord_Aela_HircineTension",
        F(0x070FF5)),
];

record DialogueTarget(
    string Chain,
    FormKey BranchFormKey,
    string BranchEditorId,
    FormKey TopicFormKey,
    string TopicEditorId,
    FormKey InfoFormKey);

record DialogueRecordSnapshot(
    string Chain,
    string Kind,
    string FormId,
    string? EditorId,
    bool Present)
{
    public static DialogueRecordSnapshot From(string chain, string kind, string formId, string? editorId, bool present) =>
        new(chain, kind, formId, editorId, present);
}

class ReleasePrepReport
{
    public string Status { get; set; } = "FAIL";
    public string Mode { get; set; } = "";
    public string EspPath { get; set; } = "";
    public string? BackupPath { get; set; }
    public bool WouldChange { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<DialogueRecordSnapshot> DialogueRecords { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<string> TouchedFiles { get; } = [];
    public string? Exception { get; set; }
}
