using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase12ContextualFavorPilot.manifest.json";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    if (!File.Exists(manifestPath))
    {
        throw new FileNotFoundException("Phase 12 manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    var favorDefinitions = BuildFavorDefinitions(manifest);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");

    foreach (var favor in favorDefinitions)
    {
        var keyword = createMissing
            ? EnsureKeyword(mod, index, allocator, favor.KeywordEdid, report)
            : RequireRecord<Keyword>(index, favor.KeywordEdid);
        var effect = createMissing
            ? EnsureMagicEffect(mod, index, allocator, favor, report)
            : RequireRecord<MagicEffect>(index, favor.MagicEffectEdid);
        var spell = createMissing
            ? EnsureSpell(mod, index, allocator, favor, report)
            : RequireRecord<Spell>(index, favor.SpellEdid);

        ConfigureFavorEffect(effect, favor, new[] { keyword });
        ConfigureFavorSpell(spell, favor, effect);
        report.Actions.Add($"Filled {favor.MagicEffectEdid} and {favor.SpellEdid}.");
    }

    var manager = RequireRecord<Quest>(index, manifest.manager!.record!);
    var nordBaselineTrack = EnsureNordBaselineTrack(mod, index, allocator, manifest, debugGlobal, createMissing, report);
    var managerProperties = new List<ScriptProperty>
    {
        ObjectProp("PDV_NordPantheonBaselineTrack", nordBaselineTrack.FormKey),
    };

    foreach (var favor in favorDefinitions)
    {
        var spell = RequireRecord<Spell>(index, favor.SpellEdid);
        managerProperties.Add(ObjectProp(favor.SpellEdid, spell.FormKey));
    }

    WireQuestScript(manager, manifest.manager.script!, managerProperties);
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

static Phase12Manifest LoadManifest(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<Phase12Manifest>(File.ReadAllText(manifestPath));
    if (parsed is null)
    {
        throw new InvalidOperationException("Phase 12 manifest could not be parsed.");
    }

    if (parsed.manager is null || string.IsNullOrWhiteSpace(parsed.manager.record) || string.IsNullOrWhiteSpace(parsed.manager.script))
    {
        throw new InvalidOperationException("Phase 12 manifest is missing manager record/script metadata.");
    }

    if (parsed.nordBaseline is null || string.IsNullOrWhiteSpace(parsed.nordBaseline.track) || parsed.nordBaseline.states is null)
    {
        throw new InvalidOperationException("Phase 12 manifest is missing nord baseline metadata.");
    }

    return parsed;
}

static FavorDefinition[] BuildFavorDefinitions(Phase12Manifest manifest)
{
    var definitions = new List<FavorDefinition>();
    foreach (var lane in manifest.lanes ?? [])
    {
        foreach (var family in lane.families ?? [])
        {
            if (string.IsNullOrWhiteSpace(family.magicEffect)
                || string.IsNullOrWhiteSpace(family.spell)
                || string.IsNullOrWhiteSpace(family.keyword)
                || string.IsNullOrWhiteSpace(family.name)
                || string.IsNullOrWhiteSpace(family.description))
            {
                throw new InvalidOperationException($"Phase 12 manifest family metadata is incomplete for {lane.laneId}/{family.familyId}.");
            }

            definitions.Add(new FavorDefinition(
                family.magicEffect,
                family.spell,
                family.keyword,
                family.name,
                family.description));
        }
    }

    return definitions.ToArray();
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

static Keyword EnsureKeyword(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Keyword keyword)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Keyword.");
        }

        ConfigureKeyword(keyword, editorId);
        return keyword;
    }

    var created = new Keyword(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureKeyword(created, editorId);
    mod.Keywords.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created keyword {editorId}.");
    return created;
}

static void ConfigureKeyword(Keyword keyword, string editorId)
{
    keyword.EditorID = editorId;
    keyword.FormVersion = 44;
}

static MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    FavorDefinition favor,
    AuthorReport report)
{
    if (index.TryGetValue(favor.MagicEffectEdid, out var existing))
    {
        if (existing is not MagicEffect effect)
        {
            throw new InvalidOperationException($"{favor.MagicEffectEdid} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        ConfigureNeutralFavorEffect(effect, favor);
        return effect;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureNeutralFavorEffect(created, favor);
    mod.MagicEffects.Add(created);
    index[favor.MagicEffectEdid] = created;
    report.Actions.Add($"Created magic effect {favor.MagicEffectEdid}.");
    return created;
}

static void ConfigureNeutralFavorEffect(MagicEffect effect, FavorDefinition favor)
{
    effect.EditorID = favor.MagicEffectEdid;
    effect.FormVersion = 44;
    effect.Name = Tx(favor.Name);
    effect.Description = Tx(favor.Description);
    effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
}

static Spell EnsureSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    FavorDefinition favor,
    AuthorReport report)
{
    if (index.TryGetValue(favor.SpellEdid, out var existing))
    {
        if (existing is not Spell spell)
        {
            throw new InvalidOperationException($"{favor.SpellEdid} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return spell;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[favor.SpellEdid] = created;
    report.Actions.Add($"Created spell {favor.SpellEdid}.");
    return created;
}

static void ConfigureFavorEffect(MagicEffect effect, FavorDefinition favor, IReadOnlyList<Keyword> keywords)
{
    ConfigureNeutralFavorEffect(effect, favor);
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

static Quest EnsureNordBaselineTrack(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    Phase12Manifest manifest,
    Global debugGlobal,
    bool createMissing,
    AuthorReport report)
{
    Quest track;
    if (index.TryGetValue(manifest.nordBaseline!.track!, out var existing))
    {
        if (existing is not Quest existingQuest)
        {
            throw new InvalidOperationException($"{manifest.nordBaseline.track} already exists as {existing.GetType().Name}, expected Quest.");
        }

        track = existingQuest;
    }
    else
    {
        if (!createMissing)
        {
            throw new InvalidOperationException($"Required shell is missing: {manifest.nordBaseline.track}");
        }

        track = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Quests.Add(track);
        index[manifest.nordBaseline.track!] = track;
        report.Actions.Add($"Created quest {manifest.nordBaseline.track}.");
    }

    ConfigureQuestShell(track, manifest.nordBaseline.track!);
    WireQuestScript(track, "PDV_StateTrack", new ScriptProperty[]
    {
        StringProp("TrackName", "NordPantheonBaseline"),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        StringListProp(
            "StateLabels",
            GetNordBaselineLabel(manifest.nordBaseline.states!, 0),
            GetNordBaselineLabel(manifest.nordBaseline.states!, 1))
    });
    report.Actions.Add("Ensured PDV_State_NordPantheonBaseline is wired to PDV_StateTrack.");
    return track;
}

static string GetNordBaselineLabel(Dictionary<string, int> states, int value)
{
    foreach (var pair in states)
    {
        if (pair.Value == value)
        {
            return pair.Key;
        }
    }

    throw new InvalidOperationException($"Phase 12 nord baseline manifest is missing state value {value}.");
}

static void ConfigureQuestShell(Quest quest, string editorId)
{
    quest.EditorID = editorId;
    quest.Name = Tx(editorId);
    quest.FormVersion = 44;
    quest.QuestFormVersion = 65;
    quest.Type = Quest.TypeEnum.None;
    quest.Priority = 0;
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

static ScriptStringProperty StringProp(string name, string value)
{
    return new ScriptStringProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptStringListProperty StringListProp(string name, params string[] values)
{
    var property = new ScriptStringListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };

    foreach (var value in values)
    {
        property.Data.Add(value);
    }

    return property;
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

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod, IEnumerable<FormKey> existingKeys)
    {
        modKey = mod.ModKey;
        usedIds = existingKeys
            .Where(key => key.ModKey.Equals(modKey))
            .Select(ParseLocalId)
            .ToHashSet();
        nextId = usedIds.Count == 0 ? 0x800u : Math.Max(0x800u, usedIds.Max() + 1);
    }

    public FormKey Next()
    {
        while (usedIds.Contains(nextId))
        {
            nextId++;
        }

        var id = nextId++;
        usedIds.Add(id);
        return new FormKey(modKey, id);
    }

    private static uint ParseLocalId(FormKey key)
    {
        var text = key.IDString();
        return Convert.ToUInt32(text, 16);
    }
}

sealed record FavorDefinition(
    string MagicEffectEdid,
    string SpellEdid,
    string KeywordEdid,
    string Name,
    string Description);

sealed class Phase12Manifest
{
    public string? id { get; set; }
    public string? implementationStatus { get; set; }
    public ManifestManager? manager { get; set; }
    public ManifestNordBaseline? nordBaseline { get; set; }
    public List<ManifestLane>? lanes { get; set; }
}

sealed class ManifestManager
{
    public string? record { get; set; }
    public string? script { get; set; }
}

sealed class ManifestNordBaseline
{
    public string? track { get; set; }
    public Dictionary<string, int>? states { get; set; }
}

sealed class ManifestLane
{
    public string? laneId { get; set; }
    public List<ManifestFamily>? families { get; set; }
}

sealed class ManifestFamily
{
    public string? familyId { get; set; }
    public string? keyword { get; set; }
    public string? magicEffect { get; set; }
    public string? spell { get; set; }
    public string? name { get; set; }
    public string? description { get; set; }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
