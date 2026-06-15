// pdv-faucet-fix-author
// Surgical fix for PDV_FLST_FaucetDaedricArtifacts (FormID 0714A2:Devotion.esp):
//   ADD  0D2846:Skyrim.esm  (REQ_Artifact_MasqueOfClavicusVile) if absent
//   REMOVE 0F6D1A:Skyrim.esm (stray Dwemer Dish PlacedObject)   if present
// Nothing else is touched.

using System.Text.Json;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

const string espPath = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string backupSuffix = "Devotion.esp.bak_faucetfix_20260615";

// Target FormList: PDV_FLST_FaucetDaedricArtifacts
// FormID 0714A2 in Devotion.esp — the local ID (index) within Devotion.esp is 0x0714A2.
// SkyrimMod.CreateFromBinary re-maps all FormKeys so the ModKey part comes from the
// record's defining master. Records whose FormKey master == "Devotion.esp" stay as-is.
const uint faucetListLocalId = 0x0714A2;
const string devotionPlugin = "Devotion.esp";

// Forms to add / remove (both in Skyrim.esm)
const string skyrimPlugin = "Skyrim.esm";
const uint masqueId = 0x0D2846;  // REQ_Artifact_MasqueOfClavicusVile / MasqueofClavicusVile
const uint dishId   = 0x0F6D1A;  // stray Dwemer Dish PlacedObject

var dryRun = args.Contains("--dry-run");
var write  = args.Contains("--write");

var report = new FaucetReport
{
    Mode      = dryRun ? "dry-run" : write ? "write" : "none",
    EspPath   = espPath,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!dryRun && !write)
    {
        throw new InvalidOperationException("Choose exactly one mode: --dry-run or --write.");
    }

    if (dryRun && write)
    {
        throw new InvalidOperationException("Choose exactly one mode: --dry-run or --write.");
    }

    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    // ── Load ────────────────────────────────────────────────────────────────
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);

    var devotionKey = ModKey.FromNameAndExtension(devotionPlugin);
    var skyrimKey   = ModKey.FromNameAndExtension(skyrimPlugin);

    var faucetFormKey = new FormKey(devotionKey, faucetListLocalId);
    var masqueFormKey = new FormKey(skyrimKey, masqueId);
    var dishFormKey   = new FormKey(skyrimKey, dishId);

    // ── Find the FormList ────────────────────────────────────────────────────
    var faucetList = mod.FormLists.Records
        .FirstOrDefault(fl => fl.FormKey.Equals(faucetFormKey))
        ?? throw new InvalidOperationException(
            $"PDV_FLST_FaucetDaedricArtifacts ({ToHousecarl(faucetFormKey)}) not found in {devotionPlugin}. " +
            "It may live in a master — the tool only edits existing Devotion.esp records.");

    report.FormListEditorId = faucetList.EditorID ?? "(no EditorID)";
    report.FormListFormId   = ToHousecarl(faucetFormKey);

    // ── Snapshot BEFORE ──────────────────────────────────────────────────────
    var beforeItems = faucetList.Items
        .Select(item => ToHousecarl(item.FormKey))
        .ToList();
    report.Before = [.. beforeItems];

    // ── Determine changes ───────────────────────────────────────────────────
    bool masqueAlreadyPresent = faucetList.Items.Any(item => item.FormKey.Equals(masqueFormKey));
    bool dishPresent          = faucetList.Items.Any(item => item.FormKey.Equals(dishFormKey));

    report.AddMasque    = !masqueAlreadyPresent;
    report.RemoveDish   = dishPresent;
    report.MasqueFormId = ToHousecarl(masqueFormKey);
    report.DishFormId   = ToHousecarl(dishFormKey);

    // Sanity: only these two possible changes; nothing else.
    if (!report.AddMasque && !report.RemoveDish)
    {
        report.Actions.Add("No changes needed: Masque already present, Dish already absent.");
        report.Status = "PASS";
        PrintReport(report);
        return 0;
    }

    report.Actions.Add($"Before: {beforeItems.Count} item(s).");
    if (report.AddMasque)
        report.Actions.Add($"WILL ADD   {report.MasqueFormId} (REQ_Artifact_MasqueOfClavicusVile)");
    if (report.RemoveDish)
        report.Actions.Add($"WILL REMOVE {report.DishFormId} (stray Dwemer Dish PlacedObject)");

    if (dryRun)
    {
        var projectedCount = beforeItems.Count + (report.AddMasque ? 1 : 0) - (report.RemoveDish ? 1 : 0);
        report.Actions.Add($"Projected after-count: {projectedCount} item(s).");
        report.Actions.Add("Dry run: no bytes written.");
        report.Status = "PASS";
        PrintReport(report);
        return 0;
    }

    // ── WRITE MODE ───────────────────────────────────────────────────────────

    // Step 1: Backup BEFORE any write. If this fails, abort.
    var espDir    = Path.GetDirectoryName(Path.GetFullPath(espPath))!;
    var backupPath = Path.Combine(espDir, backupSuffix);
    if (!File.Exists(backupPath))
    {
        File.Copy(espPath, backupPath, overwrite: false);
        report.BackupPath = backupPath;
        report.Actions.Add($"Backup written: {backupPath}");
    }
    else
    {
        report.BackupPath = backupPath;
        report.Actions.Add($"Backup already exists (skipped re-copy): {backupPath}");
    }

    // Step 2: Apply changes to the in-memory FormList.
    if (report.RemoveDish)
    {
        var toRemove = faucetList.Items.Where(item => item.FormKey.Equals(dishFormKey)).ToList();
        foreach (var item in toRemove)
            faucetList.Items.Remove(item);
        report.Actions.Add($"Removed {toRemove.Count} instance(s) of {report.DishFormId}.");
    }

    if (report.AddMasque)
    {
        faucetList.Items.Add(masqueFormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
        report.Actions.Add($"Added {report.MasqueFormId} (Masque of Clavicus Vile).");
    }

    // Step 3: Write via temp file then overwrite.
    var tempPath = $"{espPath}.faucet-fix.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }
    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");

    // Step 4: Readback verification.
    var modBack    = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var listBack   = modBack.FormLists.Records.FirstOrDefault(fl => fl.FormKey.Equals(faucetFormKey))
        ?? throw new InvalidOperationException("Post-write readback: PDV_FLST_FaucetDaedricArtifacts not found.");

    var afterItems = listBack.Items.Select(item => ToHousecarl(item.FormKey)).ToList();
    report.After = [.. afterItems];

    bool masqueNowPresent = listBack.Items.Any(item => item.FormKey.Equals(masqueFormKey));
    bool dishNowAbsent    = !listBack.Items.Any(item => item.FormKey.Equals(dishFormKey));

    if (!masqueNowPresent)
        report.Errors.Add("READBACK FAIL: Masque of Clavicus Vile is NOT present after write.");
    else
        report.Actions.Add($"Readback PASS: Masque present at count {afterItems.Count}.");

    if (!dishNowAbsent)
        report.Errors.Add("READBACK FAIL: Dwemer Dish is still present after write.");
    else
        report.Actions.Add("Readback PASS: Dwemer Dish absent.");

    report.Actions.Add($"After: {afterItems.Count} item(s) (was {beforeItems.Count}).");
    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
}
catch (Exception ex)
{
    report.Status    = "FAIL";
    report.Errors.Add(ex.Message);
    report.Exception = ex.ToString();
}
finally
{
    report.FinishedAt = DateTimeOffset.Now;
    PrintReport(report);
}

return report.Status == "PASS" ? 0 : 1;

static string ToHousecarl(FormKey key) => $"{key.IDString().ToUpperInvariant()}:{key.ModKey.FileName}";

static void PrintReport(FaucetReport r)
    => Console.WriteLine(JsonSerializer.Serialize(r, new JsonSerializerOptions { WriteIndented = true }));

sealed class FaucetReport
{
    public string   Status           { get; set; } = "STARTED";
    public string?  Mode             { get; set; }
    public string?  EspPath          { get; set; }
    public string?  BackupPath       { get; set; }
    public string?  FormListEditorId { get; set; }
    public string?  FormListFormId   { get; set; }
    public string?  MasqueFormId     { get; set; }
    public string?  DishFormId       { get; set; }
    public bool     AddMasque        { get; set; }
    public bool     RemoveDish       { get; set; }
    public List<string> Before       { get; set; } = [];
    public List<string> After        { get; set; } = [];
    public DateTimeOffset StartedAt  { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<string>  Actions     { get; set; } = [];
    public List<string>  Errors      { get; set; } = [];
    public List<string>  TouchedFiles { get; set; } = [];
    public string?  Exception        { get; set; }
}
