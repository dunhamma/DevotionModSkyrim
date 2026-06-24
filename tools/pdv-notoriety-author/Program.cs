using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerEdid = "PDV__ManagerQuest";
const string managerScript = "PDV__ManagerQuest";
const string huntedFactionEdid = "PDV_Faction_Hunted_Vigilant";
const string huntedFactionProperty = "PDV_Faction_Hunted_Vigilant";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var vigilantFactionKey = FormKey.Factory("0B3292:Skyrim.esm");

var report = new AuthorReport
{
    Mode = dryRun ? "dry-run" : write ? "write" : check ? "check" : "none",
    EspPath = espPath,
    StartedAt = DateTimeOffset.Now
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
    var index = BuildIndex(mod);

    if (check)
    {
        CheckNotoriety(index, report);
    }
    else
    {
        AuthorNotoriety(mod, index, report);
        if (write)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            CheckNotoriety(BuildIndex(readback), report);
        }
        else
        {
            report.Actions.Add("Dry run: no bytes written.");
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

void AuthorNotoriety(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    var faction = EnsureHuntedFaction(mod, index, report);
    NormalizeHuntedRelation(faction, report);

    var manager = RequireRecord<Quest>(index, managerEdid);
    WireQuestScript(manager, managerScript, new ScriptProperty[]
    {
        ObjectProp(huntedFactionProperty, faction.FormKey)
    });
    report.Actions.Add($"Wired {managerEdid}.{huntedFactionProperty} => {ToHousecarl(faction.FormKey)}.");
}

Faction EnsureHuntedFaction(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    if (index.TryGetValue(huntedFactionEdid, out var existing))
    {
        if (existing is not Faction typed)
        {
            throw new InvalidOperationException($"{huntedFactionEdid} already exists as {existing.GetType().Name}, expected Faction.");
        }

        return typed;
    }

    var faction = mod.Factions.AddNew();
    faction.EditorID = huntedFactionEdid;
    faction.FormVersion = 44;
    faction.Flags = Faction.FactionFlag.HiddenFromPC;
    index[huntedFactionEdid] = faction;
    report.Actions.Add($"Created {huntedFactionEdid} {ToHousecarl(faction.FormKey)}.");
    return faction;
}

void NormalizeHuntedRelation(Faction faction, AuthorReport report)
{
    faction.Relations.Clear();
    faction.Relations.Add(new Relation
    {
        Target = vigilantFactionKey.ToLink<IRelatableGetter>(),
        Reaction = CombatReaction.Enemy,
        Modifier = 0
    });
    report.Actions.Add($"{huntedFactionEdid}: relation set to Enemy against VigilantOfStendarrFaction only.");
}

void CheckNotoriety(Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    var faction = CheckRecord<Faction>(index, huntedFactionEdid, report);
    if (faction is not null)
    {
        if (faction.Relations.Count != 1)
        {
            report.Errors.Add($"{huntedFactionEdid}: expected exactly one relation, found {faction.Relations.Count}.");
        }
        else
        {
            var relation = faction.Relations[0];
            if (!relation.Target.FormKey.Equals(vigilantFactionKey))
            {
                report.Errors.Add($"{huntedFactionEdid}: relation target is {relation.Target.FormKey}, expected {vigilantFactionKey}.");
            }
            if (relation.Reaction != CombatReaction.Enemy)
            {
                report.Errors.Add($"{huntedFactionEdid}: relation reaction is {relation.Reaction}, expected Enemy.");
            }
            if (relation.Modifier != 0)
            {
                report.Errors.Add($"{huntedFactionEdid}: relation modifier is {relation.Modifier}, expected 0.");
            }
            if (report.Errors.Count == 0)
            {
                report.Actions.Add($"{huntedFactionEdid}: readback relation PASS -> VigilantOfStendarrFaction Enemy modifier 0.");
            }
        }
    }

    var manager = CheckRecord<Quest>(index, managerEdid, report);
    var script = manager?.VirtualMachineAdapter?.Scripts
        .FirstOrDefault(candidate => string.Equals(candidate.Name, managerScript, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{managerEdid}: missing VMAD script {managerScript}.");
    }
    else if (faction is not null)
    {
        CheckObjectProperty(script, huntedFactionProperty, faction.FormKey, managerEdid, report);
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

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
    where T : class, ISkyrimMajorRecordGetter
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

static T? CheckRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, AuthorReport report)
    where T : class, ISkyrimMajorRecordGetter
{
    if (!index.TryGetValue(editorId, out var record))
    {
        report.Errors.Add($"Missing record {editorId}.");
        return null;
    }
    if (record is not T typed)
    {
        report.Errors.Add($"{editorId} exists as {record.GetType().Name}, expected {typeof(T).Name}.");
        return null;
    }

    report.Actions.Add($"Readback PASS: {editorId} exists as {typeof(T).Name}.");
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

static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expected, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptObjectProperty objectProperty)
    {
        report.Errors.Add($"{owner}.{propertyName} is missing or not an object property.");
        return;
    }
    if (!objectProperty.Object.FormKey.Equals(expected))
    {
        report.Errors.Add($"{owner}.{propertyName} points at {objectProperty.Object.FormKey}, expected {expected}.");
        return;
    }

    report.Actions.Add($"{owner}.{propertyName}: readback object property PASS -> {ToHousecarl(expected)}.");
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

static void WriteMod(SkyrimMod mod, string espPath, AuthorReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "notoriety");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.notoriety.tmp";
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

static string ToHousecarl(FormKey key)
{
    return $"{key.ID:X6}:{key.ModKey.FileName}";
}

class AuthorReport
{
    public string Mode { get; set; } = "";
    public string EspPath { get; set; } = "";
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset? FinishedAt { get; set; }
    public string Status { get; set; } = "PENDING";
    public string? BackupPath { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> TouchedFiles { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
