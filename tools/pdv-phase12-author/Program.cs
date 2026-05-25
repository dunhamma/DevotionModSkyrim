using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";

var dryRun = args.Contains("--dry-run");
var espPath = GetArg(args, "--esp") ?? defaultEsp;
var favorDefinitions = new FavorDefinition[]
{
    new("PDV_Favor_Kyne_OpenSkyRestRecovery", "PDV_SPEL_Favor_Kyne_OpenSkyRestRecovery", "PDV_FavorFamily_OpenSkyRecovery", "Kyne: Open-Sky Rest", "Kyne restores your breath after rest beneath the open sky."),
    new("PDV_Favor_Kyne_StormRoadGrace", "PDV_SPEL_Favor_Kyne_StormRoadGrace", "PDV_FavorFamily_RoadGrace", "Kyne: Storm-Road Grace", "Kyne lightens the hard road for a short while."),
    new("PDV_Favor_Kyne_GuidedHunt", "PDV_SPEL_Favor_Kyne_GuidedHunt", "PDV_FavorFamily_GuidedHunt", "Kyne: Guided Hunt", "The hunt briefly feels guided by Kyne's breath."),
    new("PDV_Favor_Kyne_WindMarkedPassage", "PDV_SPEL_Favor_Kyne_WindMarkedPassage", "PDV_FavorFamily_WindPassage", "Kyne: Wind-Marked Passage", "The wind carries you for a little while."),
    new("PDV_Favor_NordBroadOldWays_SkyRoadEndurance", "PDV_SPEL_Favor_NordBroadOldWays_SkyRoadEndurance", "PDV_FavorFamily_RoadGrace", "Old Ways: Sky-Road Endurance", "The old gods make the road feel briefly companionable."),
    new("PDV_Favor_NordBroadOldWays_HonorableOrdeal", "PDV_SPEL_Favor_NordBroadOldWays_HonorableOrdeal", "PDV_FavorFamily_HonorableOrdeal", "Old Ways: Honorable Ordeal", "For this fight, the Old Ways steady your courage."),
    new("PDV_Favor_NordBroadOldWays_HearthAndHoldDefense", "PDV_SPEL_Favor_NordBroadOldWays_HearthAndHoldDefense", "PDV_FavorFamily_HoldDefense", "Old Ways: Hearth and Hold", "Household duty and hold-defense briefly answer back."),
    new("PDV_Favor_NordBroadOldWays_DeathRightAncestorQuiet", "PDV_SPEL_Favor_NordBroadOldWays_DeathRightAncestorQuiet", "PDV_FavorFamily_AncestorQuiet", "Old Ways: Ancestor Quiet", "The dead settle and the old stories rest easier for a time."),
    new("PDV_Favor_NordBroadOldWays_HiddenTalosDefiance", "PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance", "PDV_FavorFamily_TalosPressure", "Old Ways: Hidden Talos Defiance", "Costly hidden defiance leaves a brief steadiness behind."),
    new("PDV_Favor_NordBroadNineDivines_KynarethRoadGrace", "PDV_SPEL_Favor_NordBroadNineDivines_KynarethRoadGrace", "PDV_FavorFamily_RoadGrace", "Nine Divines: Kynareth's Road Grace", "Kynareth briefly steadies the road ahead."),
    new("PDV_Favor_NordBroadNineDivines_HouseholdAndMercyDuty", "PDV_SPEL_Favor_NordBroadNineDivines_HouseholdAndMercyDuty", "PDV_FavorFamily_MercyDuty", "Nine Divines: Household and Mercy", "Mercy and household duty briefly answer in kind."),
    new("PDV_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy", "PDV_SPEL_Favor_NordBroadNineDivines_ProperDeathAndAntiNecromancy", "PDV_FavorFamily_ProperDeath", "Nine Divines: Proper Death", "The proper ordering of death leaves a brief blessing."),
    new("PDV_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft", "PDV_SPEL_Favor_NordBroadNineDivines_HonestWorkAndLearnedCraft", "PDV_FavorFamily_HonestWork", "Nine Divines: Honest Work", "Honest work and learned craft briefly sharpen your purpose."),
    new("PDV_Favor_NordBroadNineDivines_TalosPressureInsideTheNine", "PDV_SPEL_Favor_NordBroadNineDivines_TalosPressureInsideTheNine", "PDV_FavorFamily_TalosPressure", "Nine Divines: Talos Pressure", "A costly private contradiction leaves a brief resolve behind.")
};

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

    foreach (var favor in favorDefinitions)
    {
        var effect = RequireRecord<MagicEffect>(index, favor.MagicEffectEdid);
        var spell = RequireRecord<Spell>(index, favor.SpellEdid);
        var keywords = favor.KeywordEdids.Select(edid => RequireRecord<Keyword>(index, edid)).ToArray();

        ConfigureFavorEffect(effect, favor, keywords);
        ConfigureFavorSpell(spell, favor, effect);
        report.Actions.Add($"Filled {favor.MagicEffectEdid} and {favor.SpellEdid}.");
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var nordBaselineTrack = RequireRecord<Quest>(index, "PDV_State_NordPantheonBaseline");
    var managerProperties = new List<ScriptProperty>
    {
        ObjectProp("PDV_NordPantheonBaselineTrack", nordBaselineTrack.FormKey),
    };

    foreach (var favor in favorDefinitions)
    {
        var spell = RequireRecord<Spell>(index, favor.SpellEdid);
        managerProperties.Add(ObjectProp(favor.SpellEdid, spell.FormKey));
    }

    WireQuestScript(manager, "PDV__ManagerQuest", managerProperties);
    report.Actions.Add("Wired Phase 12 manager properties.");

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase12");
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
        throw new InvalidOperationException($"Required shell is missing: {editorId}");
    }

    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} is {record.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static void ConfigureFavorEffect(MagicEffect effect, FavorDefinition favor, IReadOnlyList<Keyword> keywords)
{
    effect.EditorID = favor.MagicEffectEdid;
    effect.FormVersion = 44;
    effect.Name = Tx(favor.Name);
    effect.Description = Tx(favor.Description);
    effect.Keywords ??= [];
    effect.Keywords.Clear();
    foreach (var keyword in keywords)
    {
        effect.Keywords.Add(keyword.FormKey.ToLink<IKeywordGetter>());
    }
}

static void ConfigureFavorSpell(Spell spell, FavorDefinition favor, MagicEffect effect)
{
    spell.EditorID = favor.SpellEdid;
    spell.FormVersion = 44;
    spell.Name = Tx(favor.Name);
    spell.Description = Tx(favor.Description);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();
    spell.Effects.Add(new Effect
    {
        BaseEffect = effect.FormKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData
        {
            Magnitude = 0.0f,
            Area = 0,
            Duration = 0
        }
    });
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

static TranslatedString Tx(string value) => new(Language.English, value);

sealed record FavorDefinition(
    string MagicEffectEdid,
    string SpellEdid,
    string KeywordEdid,
    string Name,
    string Description)
{
    public string[] KeywordEdids { get; } = [KeywordEdid];
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
