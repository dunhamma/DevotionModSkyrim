// pdv-argonian-histpotion-author
// Authors the self-replenishing Hist Sap potion into Devotion.esp:
//   - MGEF PDV_MGEF_ArgonianHistSap (Script archetype) carrying PDV_PotionArgonianHistSapEffect
//   - ALCH PDV_ALCH_ArgonianHistSap "Hist Sap" whose single effect is that MGEF
//   - wires PDV_ALCH_ArgonianHistSap as a Potion property on both the MGEF script (so it replenishes
//     itself) and the PDV__ManagerQuest script (so EnsureArgonianHistSapToken can grant it)
// Mirrors the in-place Mutagen author pattern of pdv-daedric-offer-title-author / pdv-shrine-blessing-author.

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string mgefEdid = "PDV_MGEF_ArgonianHistSap";
const string alchEdid = "PDV_ALCH_ArgonianHistSap";
const string scriptName = "PDV_PotionArgonianHistSapEffect";
const string managerQuestEdid = "PDV__ManagerQuest";
const string managerScriptName = "PDV__ManagerQuest";
const string propName = "PDV_ALCH_ArgonianHistSap";
const string potionName = "Hist Sap";
const string potionModel = @"Clutter\Potions\PotionExtraSkooma01.nif";

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var write = args.Contains("--write");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var report = new Report { EspPath = espPath, Mode = checkOnly ? "check" : write ? "write" : dryRun ? "dry-run" : "none", StartedAt = DateTimeOffset.Now };

try
{
    if (new[] { checkOnly, write, dryRun }.Count(v => v) != 1)
        throw new InvalidOperationException("Choose exactly one mode: --check, --dry-run, or --write.");
    if (!File.Exists(espPath))
        throw new FileNotFoundException("Devotion ESP not found.", espPath);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);

    var mgef = mod.MagicEffects.Records.FirstOrDefault(r => string.Equals(r.EditorID, mgefEdid, StringComparison.OrdinalIgnoreCase));
    var alch = mod.Ingestibles.Records.FirstOrDefault(r => string.Equals(r.EditorID, alchEdid, StringComparison.OrdinalIgnoreCase));
    var quest = mod.Quests.Records.FirstOrDefault(r => string.Equals(r.EditorID, managerQuestEdid, StringComparison.OrdinalIgnoreCase));

    if (checkOnly)
    {
        report.Actions.Add($"{mgefEdid}: {(mgef is null ? "MISSING" : "present " + Hc(mgef.FormKey))}");
        report.Actions.Add($"{alchEdid}: {(alch is null ? "MISSING" : "present " + Hc(alch.FormKey))}");
        if (mgef is null) report.Errors.Add($"{mgefEdid} missing.");
        if (alch is null) report.Errors.Add($"{alchEdid} missing.");
        if (alch is not null && !alch.Effects.Any(e => mgef is not null && e.BaseEffect.FormKey.Equals(mgef.FormKey)))
            report.Errors.Add($"{alchEdid} does not reference {mgefEdid} as an effect.");
        if (mgef is not null && GetScriptProp(mgef.VirtualMachineAdapter?.Scripts, scriptName, propName) is null)
            report.Errors.Add($"{mgefEdid} script {scriptName} missing {propName} property.");
        if (quest is not null && GetScriptProp(quest.VirtualMachineAdapter?.Scripts, managerScriptName, propName) is null)
            report.Errors.Add($"{managerQuestEdid} script {managerScriptName} missing {propName} property.");
        Finish(report);
        return report.Status == "PASS" ? 0 : 1;
    }

    // Create-or-reuse the records (AddNew first so both have FormKeys before cross-wiring).
    if (mgef is null)
    {
        var m = mod.MagicEffects.AddNew();
        m.EditorID = mgefEdid;
        m.FormVersion = 44;
        report.Actions.Add($"Created MGEF {mgefEdid} {Hc(m.FormKey)}.");
        mgef = m;
    }
    if (alch is null)
    {
        var a = mod.Ingestibles.AddNew();
        a.EditorID = alchEdid;
        a.FormVersion = 44;
        report.Actions.Add($"Created ALCH {alchEdid} {Hc(a.FormKey)}.");
        alch = a;
    }
    if (quest is null)
        throw new InvalidOperationException($"{managerQuestEdid} quest not found in Devotion.esp (cannot wire grant property).");

    var mgefW = mod.MagicEffects.First(r => r.FormKey.Equals(mgef.FormKey));
    var alchW = mod.Ingestibles.First(r => r.FormKey.Equals(alch.FormKey));
    var questW = mod.Quests.First(r => r.FormKey.Equals(quest.FormKey));

    // MGEF: script archetype + the effect script with the ALCH property (self-replenish).
    mgefW.Name = Tx(potionName);
    mgefW.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.HideInUI;
    mgefW.BaseCost = 0.0f;
    mgefW.MagicSkill = ActorValue.None;
    mgefW.ResistValue = ActorValue.None;
    mgefW.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    mgefW.CastType = CastType.FireAndForget;
    mgefW.TargetType = TargetType.Self;
    SetScriptProp(EnsureVmadEffect(mgefW), scriptName, propName, alchW.FormKey, report, $"{mgefEdid}.{scriptName}");

    // ALCH: name, model, value/weight, single effect = the MGEF.
    alchW.Name = Tx(potionName);
    alchW.Model = new Model { File = potionModel };
    alchW.Value = 0;
    alchW.Weight = 0.1f;
    alchW.Flags = Ingestible.Flag.Medicine;
    alchW.Effects.Clear();
    alchW.Effects.Add(new Effect
    {
        BaseEffect = new FormLinkNullable<IMagicEffectGetter>(mgefW.FormKey),
        Data = new EffectData { Magnitude = 0f, Area = 0, Duration = 0 },
        Conditions = []
    });
    report.Actions.Add($"{alchEdid}: effect -> {mgefEdid}; model {potionModel}.");

    // Manager quest: add the Potion property so EnsureArgonianHistSapToken can grant it.
    SetScriptProp(questW.VirtualMachineAdapter?.Scripts, managerScriptName, propName, alchW.FormKey, report, $"{managerQuestEdid}.{managerScriptName}");

    if (write && report.Errors.Count == 0)
        WriteModIfNeeded(mod, espPath, report);
    else if (report.Errors.Count > 0)
        report.Actions.Add("Write skipped: errors present (fail-closed). No ESP bytes changed.");
    else
        report.Actions.Add("Dry run only; no ESP bytes changed.");

    Finish(report);
    return report.Status == "PASS" ? 0 : 1;
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Errors.Add(ex.Message);
    report.Exception = ex.ToString();
    Finish(report);
    return 1;
}

static IEnumerable<ScriptEntry>? EnsureVmadEffect(MagicEffect mgef)
{
    mgef.VirtualMachineAdapter ??= new VirtualMachineAdapter { Version = 5, ObjectFormat = 2 };
    return mgef.VirtualMachineAdapter.Scripts;
}

static ScriptObjectProperty? GetScriptProp(IEnumerable<ScriptEntry>? scripts, string scriptName, string propName)
{
    var entry = scripts?.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    return entry?.Properties.OfType<ScriptObjectProperty>()
        .FirstOrDefault(p => string.Equals(p.Name, propName, StringComparison.OrdinalIgnoreCase));
}

static void SetScriptProp(IEnumerable<ScriptEntry>? scripts, string scriptName, string propName, FormKey target, Report report, string where)
{
    if (scripts is not List<ScriptEntry> list)
    {
        report.Errors.Add($"{where}: no VMAD script list to attach {propName}.");
        return;
    }
    var entry = list.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (entry is null)
    {
        entry = new ScriptEntry { Name = scriptName, Flags = ScriptEntry.Flag.Local };
        list.Add(entry);
        report.Actions.Add($"{where}: added script entry {scriptName}.");
    }
    var prop = entry.Properties.OfType<ScriptObjectProperty>().FirstOrDefault(p => string.Equals(p.Name, propName, StringComparison.OrdinalIgnoreCase));
    if (prop is null)
    {
        prop = new ScriptObjectProperty { Name = propName, Flags = ScriptProperty.Flag.Edited };
        entry.Properties.Add(prop);
    }
    prop.Object = new FormLink<ISkyrimMajorRecordGetter>(target);
    report.Actions.Add($"{where}: {propName} -> {Hc(target)}.");
}

static void WriteModIfNeeded(SkyrimMod mod, string espPath, Report report)
{
    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "argonian-hist-potion");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;
    var tempPath = $"{espPath}.argonian-hist-potion.tmp";
    using (var stream = File.Create(tempPath))
        mod.WriteToBinary(stream);
    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
}

static void Finish(Report report)
{
    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
    report.FinishedAt = DateTimeOffset.Now;
    Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
}

static string Hc(FormKey key) => $"{key.IDString().ToUpperInvariant()}:{key.ModKey.FileName}";
static TranslatedString Tx(string value) => new(Language.English, value);
static string? GetArg(string[] args, string name)
{
    var i = Array.IndexOf(args, name);
    return i < 0 || i + 1 >= args.Length ? null : args[i + 1];
}

sealed class Report
{
    public string Status { get; set; } = "STARTED";
    public string? Mode { get; set; }
    public string? EspPath { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = new();
    public List<string> Actions { get; } = new();
    public List<string> Errors { get; } = new();
    public string? Exception { get; set; }
}
