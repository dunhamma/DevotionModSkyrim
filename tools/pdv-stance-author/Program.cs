using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

// Writes per-race stance VMAD Int properties (Stance_<Race>) onto every concrete
// PDV_Deity_* QUST from references/phase4/PDV_StanceMatrix.csv. The thin-shell deities
// shipped without their stances wired, so they defaulted to FOREIGN (1) for every race,
// which both leaked the generic-faucet eligibility gate and halved native curated signals.
// Values: NATIVE=0, FOREIGN=1, TABOO=2, HOSTILE=3. Property order matches PDV_DeityBase:
// Nord, Imperial, Breton, Altmer, Bosmer, Dunmer, Khajiit, Argonian, Orc, Redguard.

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";

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

    foreach (var deity in DeityStanceTarget.All)
    {
        if (index.TryGetValue(deity.EditorId, out var record) && record is Quest quest)
        {
            WireQuestScript(quest, deity.EditorId, deity.StanceProperties());
            report.Actions.Add($"Stanced {deity.EditorId}: [{string.Join(",", deity.Stances)}]");
        }
        else
        {
            report.Missing.Add(deity.EditorId);
        }
    }

    if (report.Missing.Count > 0)
    {
        report.Errors.Add($"Missing QUST records (stances NOT written): {string.Join(", ", report.Missing)}");
    }

    WriteModIfNeeded(mod, espPath, dryRun, report, "stance");
    report.Status = report.Missing.Count == 0 ? "PASS" : "PARTIAL";
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

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report, string backupSubdir)
{
    if (dryRun)
    {
        return;
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", backupSubdir);
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
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

record DeityStanceTarget(string EditorId, int[] Stances)
{
    // Order MUST match PDV_DeityBase property declarations and the stance matrix columns.
    static readonly string[] RaceProps =
    {
        "Stance_Nord", "Stance_Imperial", "Stance_Breton", "Stance_Altmer", "Stance_Bosmer",
        "Stance_Dunmer", "Stance_Khajiit", "Stance_Argonian", "Stance_Orc", "Stance_Redguard"
    };

    public ScriptProperty[] StanceProperties()
    {
        var props = new ScriptProperty[RaceProps.Length];
        for (var i = 0; i < RaceProps.Length; i++)
        {
            props[i] = new ScriptIntProperty
            {
                Name = RaceProps[i],
                Flags = ScriptProperty.Flag.Edited,
                Data = Stances[i]
            };
        }

        return props;
    }

    // From references/phase4/PDV_StanceMatrix.csv. [Nord,Imp,Bret,Alt,Bos,Dun,Kha,Arg,Orc,Red]
    public static readonly DeityStanceTarget[] All =
    [
        new("PDV_Deity_Kyne",      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Talos",     [0, 1, 0, 3, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Shor",      [0, 1, 3, 3, 1, 1, 1, 1, 1, 3]),
        new("PDV_Deity_Tsun",      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Stuhn",     [0, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Kynareth",  [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Mara",      [0, 0, 0, 0, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Akatosh",   [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Arkay",     [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Stendarr",  [0, 0, 0, 0, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Julianos",  [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Dibella",   [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Zenithar",  [0, 0, 0, 1, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Magnus",    [1, 1, 0, 0, 1, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Yffre",     [1, 1, 0, 0, 0, 1, 1, 1, 1, 1]),
        new("PDV_Deity_AuriEl",    [1, 1, 1, 0, 0, 1, 1, 1, 3, 1]),
        new("PDV_Deity_Xarxes",    [1, 1, 1, 0, 0, 1, 1, 1, 1, 1]),
        new("PDV_Deity_Azura",     [2, 2, 1, 2, 1, 0, 0, 1, 2, 1]),
        new("PDV_Deity_Boethiah",  [2, 2, 1, 3, 1, 0, 0, 1, 3, 1]),
        new("PDV_Deity_Mephala",   [2, 2, 1, 2, 1, 0, 0, 1, 2, 1]),
        new("PDV_Deity_BaanDar",   [1, 1, 1, 1, 0, 1, 0, 1, 1, 1]),
        new("PDV_Deity_Rajhin",    [1, 1, 1, 1, 1, 1, 0, 1, 1, 1]),
        new("PDV_Deity_Alkosh",    [1, 1, 1, 1, 1, 1, 0, 1, 1, 1]),
        new("PDV_Deity_Khenarthi", [1, 1, 1, 1, 1, 1, 0, 1, 1, 1]),
        new("PDV_Deity_Tuwhacca",  [1, 1, 1, 1, 1, 1, 1, 1, 1, 0]),
        new("PDV_Deity_Leki",      [1, 1, 1, 1, 1, 1, 1, 1, 1, 0]),
        new("PDV_Deity_HoonDing",  [1, 1, 1, 1, 1, 1, 1, 1, 1, 0]),
        new("PDV_Deity_Malacath",  [1, 2, 1, 2, 1, 2, 1, 1, 0, 3]),
        new("PDV_Deity_Hist",      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1]),
        new("PDV_Deity_Sithis",    [2, 2, 2, 2, 2, 2, 2, 0, 2, 2]),
        new("PDV_Deity_Trinimac",  [1, 1, 1, 0, 1, 1, 1, 1, 2, 1]),
        // Z'en is absent from the stance matrix; default to Bosmer-native (agriculture/payment god).
        new("PDV_Deity_Zen",       [1, 1, 1, 1, 0, 1, 1, 1, 1, 1])
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
    public List<string> Missing { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
