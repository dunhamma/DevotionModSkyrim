using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase20_RewardRecordContracts.json";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkOnly = args.Contains("--check");
var wireManager = args.Contains("--wire-manager");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    CheckOnly = checkOnly,
    WireManager = wireManager,
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
        throw new FileNotFoundException("Reward contract manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    ValidateManifest(manifest);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var shouldConfigureRecords = createMissing || wireManager;
    foreach (var race in manifest.races!)
    {
        var effectRecords = new List<(RewardEffect Definition, MagicEffect Record)>();
        foreach (var effectDefinition in race.effects!)
        {
            var effect = createMissing
                ? EnsureMagicEffect(mod, index, allocator, race, effectDefinition, report)
                : RequireRecord<MagicEffect>(index, effectDefinition.magicEffectEditorId!);
            if (shouldConfigureRecords)
            {
                ConfigureMagicEffect(effect, race, effectDefinition);
            }
            effectRecords.Add((effectDefinition, effect));
        }

        var spell = createMissing
            ? EnsureSpell(mod, index, allocator, race, report)
            : RequireRecord<Spell>(index, race.spellEditorId!);
        if (shouldConfigureRecords)
        {
            ConfigureSpell(spell, race, effectRecords);
        }
        CheckRacePacket(spell, race, effectRecords, report);
    }

    if (wireManager)
    {
        var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
        WireQuestScript(
            manager,
            "PDV__ManagerQuest",
            manifest.races!.Select(race => ObjectProp(race.spellEditorId!, RequireRecord<Spell>(index, race.spellEditorId!).FormKey)));
        report.Actions.Add("Wired first-tier race reward spell properties on PDV__ManagerQuest.");
    }

    if (checkOnly)
    {
        CheckManagerProperties(index, manifest, report);
    }

    if (!checkOnly)
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-race-rewards");
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

static RewardManifest LoadManifest(string manifestPath)
{
    return JsonSerializer.Deserialize<RewardManifest>(File.ReadAllText(manifestPath), new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    }) ?? throw new InvalidOperationException("Reward contract manifest did not parse.");
}

static void ValidateManifest(RewardManifest manifest)
{
    if (manifest.schema != "pdv.phase20.reward-record-contracts.v1")
    {
        throw new InvalidOperationException($"Unexpected reward contract schema {manifest.schema ?? "(missing)"}.");
    }

    if (manifest.races is null || manifest.races.Count != 10)
    {
        throw new InvalidOperationException("Reward contract manifest must contain exactly ten race entries.");
    }

    foreach (var race in manifest.races)
    {
        if (string.IsNullOrWhiteSpace(race.race)
            || string.IsNullOrWhiteSpace(race.spellEditorId)
            || string.IsNullOrWhiteSpace(race.displayName)
            || string.IsNullOrWhiteSpace(race.playerFacingText)
            || race.effects is null
            || race.effects.Count == 0)
        {
            throw new InvalidOperationException($"Reward race entry {race.race ?? "(missing race)"} is incomplete.");
        }

        if (race.playerFacingText.Any(ch => ch > 127))
        {
            throw new InvalidOperationException($"{race.race} player-facing text must be ASCII-safe.");
        }

        foreach (var effect in race.effects)
        {
            if (string.IsNullOrWhiteSpace(effect.magicEffectEditorId)
                || string.IsNullOrWhiteSpace(effect.displayName)
                || string.IsNullOrWhiteSpace(effect.actorValue))
            {
                throw new InvalidOperationException($"{race.race} has an incomplete effect entry.");
            }

            _ = ParseActorValue(effect.actorValue!);
        }
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
    if (!index.TryGetValue(editorId, out var existing))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }

    if (existing is not T typed)
    {
        throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardRace race,
    RewardEffect definition,
    AuthorReport report)
{
    if (index.TryGetValue(definition.magicEffectEditorId!, out var existing))
    {
        if (existing is not MagicEffect effect)
        {
            throw new InvalidOperationException($"{definition.magicEffectEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        return effect;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.MagicEffects.Add(created);
    index[definition.magicEffectEditorId!] = created;
    report.Actions.Add($"Created {race.race} magic effect {definition.magicEffectEditorId}.");
    return created;
}

static Spell EnsureSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardRace race,
    AuthorReport report)
{
    if (index.TryGetValue(race.spellEditorId!, out var existing))
    {
        if (existing is not Spell spell)
        {
            throw new InvalidOperationException($"{race.spellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return spell;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[race.spellEditorId!] = created;
    report.Actions.Add($"Created {race.race} spell {race.spellEditorId}.");
    return created;
}

static void ConfigureMagicEffect(MagicEffect effect, RewardRace race, RewardEffect definition)
{
    effect.EditorID = definition.magicEffectEditorId;
    effect.FormVersion = 44;
    effect.Name = Tx(definition.displayName!);
    effect.Description = Tx(race.playerFacingText!);
    effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(definition.actorValue!)
    };
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
}

static void ConfigureSpell(Spell spell, RewardRace race, IReadOnlyList<(RewardEffect Definition, MagicEffect Record)> effects)
{
    spell.EditorID = race.spellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(race.displayName!);
    spell.Description = Tx(race.playerFacingText!);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();

    foreach (var (definition, record) in effects)
    {
        var effect = new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData
            {
                Magnitude = definition.magnitude,
                Area = definition.area,
                Duration = definition.duration
            },
            Conditions = []
        };
        if (definition.nightOnly)
        {
            AddNightConditions(effect);
        }
        spell.Effects.Add(effect);
    }
}

static void AddNightConditions(Effect effect)
{
    effect.Conditions.Clear();
    effect.Conditions.Add(new ConditionFloat
    {
        Data = new GetCurrentTimeConditionData(),
        CompareOperator = CompareOperator.GreaterThanOrEqualTo,
        ComparisonValue = 19.0f,
        Flags = Condition.Flag.OR
    });
    effect.Conditions.Add(new ConditionFloat
    {
        Data = new GetCurrentTimeConditionData(),
        CompareOperator = CompareOperator.LessThanOrEqualTo,
        ComparisonValue = 7.0f
    });
}

static void CheckRacePacket(
    Spell spell,
    RewardRace race,
    IReadOnlyList<(RewardEffect Definition, MagicEffect Record)> effects,
    AuthorReport report)
{
    if (!string.Equals(spell.Description?.String, race.playerFacingText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{race.spellEditorId} description does not match the reward contract text.");
    }

    if (spell.Effects.Count != effects.Count)
    {
        report.Errors.Add($"{race.spellEditorId} has {spell.Effects.Count} effect(s), expected {effects.Count}.");
    }

    for (var index = 0; index < effects.Count; index++)
    {
        var (definition, effect) = effects[index];
        if (!string.Equals(effect.Description?.String, race.playerFacingText, StringComparison.Ordinal))
        {
            report.Errors.Add($"{effect.EditorID} description does not match the reward contract text.");
        }

        if (effect.Archetype.ActorValue != ParseActorValue(definition.actorValue!))
        {
            report.Errors.Add($"{effect.EditorID} is not a value modifier for {definition.actorValue}.");
        }

        if (index < spell.Effects.Count)
        {
            var spellEffect = spell.Effects[index];
            if (!spellEffect.BaseEffect.FormKey.Equals(effect.FormKey))
            {
                report.Errors.Add($"{race.spellEditorId} effect {index} points at {spellEffect.BaseEffect.FormKey}, expected {effect.FormKey}.");
            }

            if (Math.Abs(spellEffect.Data?.Magnitude - definition.magnitude ?? definition.magnitude) > 0.001f
                || spellEffect.Data?.Area != definition.area
                || spellEffect.Data?.Duration != definition.duration)
            {
                report.Errors.Add($"{race.spellEditorId} effect {index} magnitude/area/duration does not match the reward contract.");
            }

            if (definition.nightOnly && spellEffect.Conditions.Count < 2)
            {
                report.Errors.Add($"{race.spellEditorId} effect {index} is marked night-only but is missing time conditions.");
            }
        }
    }

    report.Actions.Add($"Checked {race.race} reward packet {race.spellEditorId}.");
}

static void CheckManagerProperties(Dictionary<string, ISkyrimMajorRecordGetter> index, RewardManifest manifest, AuthorReport report)
{
    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var script = manager.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add("PDV__ManagerQuest VMAD is missing PDV__ManagerQuest script.");
        return;
    }

    foreach (var race in manifest.races!)
    {
        var spell = RequireRecord<Spell>(index, race.spellEditorId!);
        var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, race.spellEditorId, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty)
        {
            report.Errors.Add($"Manager property {race.spellEditorId} is missing or not an object property.");
            continue;
        }

        if (!objectProperty.Object.FormKey.Equals(spell.FormKey))
        {
            report.Errors.Add($"Manager property {race.spellEditorId} points at {objectProperty.Object.FormKey}, expected {spell.FormKey}.");
        }
    }
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

static ActorValue ParseActorValue(string actorValue)
{
    if (Enum.TryParse<ActorValue>(actorValue, ignoreCase: true, out var parsed))
    {
        return parsed;
    }

    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
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

sealed class RewardManifest
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public string? runtimeGrantStatus { get; set; }
    public List<RewardRace>? races { get; set; }
}

sealed class RewardRace
{
    public string? race { get; set; }
    public string? tier { get; set; }
    public string? spellEditorId { get; set; }
    public string? magicEffectEditorId { get; set; }
    public string? displayName { get; set; }
    public string? playerFacingText { get; set; }
    public List<RewardEffect>? effects { get; set; }
}

sealed class RewardEffect
{
    public string? magicEffectEditorId { get; set; }
    public string? displayName { get; set; }
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public int area { get; set; }
    public int duration { get; set; }
    public bool nightOnly { get; set; }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public bool CheckOnly { get; set; }
    public bool WireManager { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
