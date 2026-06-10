// PDV Mood Teaser TEST ESP author (V1-candidate "the gods notice you" slice).
//
// Emits PDV_MoodTeaserTest.esp into a SEPARATE, disable-able MO2 mod folder.
// PlayerDevotion_Framework.esp is read as a MASTER and never written. The test
// plugin carries exactly what the mood-only teaser needs at the record layer:
//   - PDV_GLO_PatronMoodBand (GlobalFloat mirror; 1.0 = Cool at rest)
//   - a VMAD override of PDV__ManagerQuest wiring that one new property
// The two teaser .pex (PDV_DeityBase, PDV__ManagerQuest) are deployed alongside
// (they VFS-override Devotion's while the mod is enabled). Toggling the mod off
// reverts everything; the Devotion mod itself is untouched.
//
//   dotnet run -- --author [--framework <esp>] [--out <modFolder>]
//   dotnet run -- --check  [--framework <esp>] [--out <modFolder>]

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string defaultFramework = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultOutDir = @"D:\Wabbajack\modlists\Anvil\mods\Devotion - Living Deities - Mood Teaser";
const string testEspName = "PDV_MoodTeaserTest.esp";

var doAuthor = args.Contains("--author");
var doCheck = args.Contains("--check");
var frameworkPath = Path.GetFullPath(GetArg(args, "--framework") ?? defaultFramework);
var outDir = Path.GetFullPath(GetArg(args, "--out") ?? defaultOutDir);
var espPath = Path.Combine(outDir, testEspName);

var report = new Report { EspPath = espPath, FrameworkPath = frameworkPath };

try
{
    if (!doAuthor && !doCheck)
    {
        throw new InvalidOperationException("Specify --author or --check.");
    }
    if (!File.Exists(frameworkPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", frameworkPath);
    }

    var framework = SkyrimMod.CreateFromBinary(frameworkPath, SkyrimRelease.SkyrimSE);
    var frameworkIndex = BuildIndex(framework);
    var manager = RequireRecord<Quest>(frameworkIndex, "PDV__ManagerQuest");

    if (doAuthor)
    {
        var testMod = new SkyrimMod(ModKey.FromNameAndExtension(testEspName), SkyrimRelease.SkyrimSE);
        uint nextId = 0x800;
        FormKey Next() => new(testMod.ModKey, nextId++);

        // 1. The mood-band mirror global (Cool = 1 at rest).
        var moodGlobal = new GlobalFloat(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_GLO_PatronMoodBand",
            Data = 1.0f,
        };
        testMod.Globals.Add(moodGlobal);
        report.Actions.Add("Created PDV_GLO_PatronMoodBand (GlobalFloat, 1.0).");

        // 2. Override PDV__ManagerQuest VMAD wiring the one new property.
        var managerOverride = manager.DeepCopy();
        var managerScript = managerOverride.VirtualMachineAdapter?.Scripts
                .FirstOrDefault(s => string.Equals(s.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase))
            ?? throw new InvalidOperationException("PDV__ManagerQuest override has no VMAD script.");
        UpsertProperties(managerScript, [ObjectProp("PDV_GLO_PatronMoodBand", moodGlobal.FormKey)]);
        testMod.Quests.Add(managerOverride);
        report.Actions.Add("Override PDV__ManagerQuest: +PDV_GLO_PatronMoodBand.");

        Directory.CreateDirectory(outDir);
        var tempPath = espPath + ".tmp";
        using (var stream = File.Create(tempPath))
        {
            testMod.WriteToBinary(stream);
        }
        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        report.TouchedFiles.Add(espPath);
        report.Actions.Add($"Masters: {string.Join(", ", SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE).ModHeader.MasterReferences.Select(m => m.Master.FileName))}");
        report.Status = "PASS";
    }
    else
    {
        if (!File.Exists(espPath))
        {
            throw new FileNotFoundException("Test ESP not authored yet.", espPath);
        }
        var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
        var index = BuildIndex(mod);

        RequireRecord<GlobalFloat>(index, "PDV_GLO_PatronMoodBand");
        report.Actions.Add("PDV_GLO_PatronMoodBand present.");

        var managerOverride = RequireRecord<Quest>(index, "PDV__ManagerQuest");
        var managerScript = managerOverride.VirtualMachineAdapter?.Scripts
            .FirstOrDefault(s => string.Equals(s.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
        if (managerScript is null)
        {
            report.Errors.Add("PDV__ManagerQuest override is missing its script.");
        }
        else
        {
            var prop = managerScript.Properties.FirstOrDefault(p => string.Equals(p.Name, "PDV_GLO_PatronMoodBand", StringComparison.OrdinalIgnoreCase));
            if (prop is not ScriptObjectProperty op || op.Object.IsNull)
            {
                report.Errors.Add("PDV_GLO_PatronMoodBand is not wired on the manager override.");
            }
            else
            {
                report.Actions.Add("Manager override wires PDV_GLO_PatronMoodBand.");
            }
        }
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
    }
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Errors.Add(ex.Message);
}

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

static void UpsertProperties(ScriptEntry script, IEnumerable<ScriptProperty> properties)
{
    foreach (var property in properties)
    {
        while (script.Properties.FirstOrDefault(c => string.Equals(c.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
        }
        script.Properties.Add(property);
    }
}

static ScriptObjectProperty ObjectProp(string name, FormKey formKey) => new()
{
    Name = name,
    Flags = ScriptProperty.Flag.Edited,
    Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
    Alias = -1,
};

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    return index < 0 || index + 1 >= args.Length ? null : args[index + 1];
}

sealed class Report
{
    public string Status { get; set; } = "FAIL";
    public string? EspPath { get; set; }
    public string? FrameworkPath { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<string> TouchedFiles { get; } = [];
}
