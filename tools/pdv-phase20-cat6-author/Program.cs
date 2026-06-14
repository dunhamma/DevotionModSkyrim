using System.Text.Json;
using System.Text.RegularExpressions;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultManifest = @"references\authoring\PDV_CAT6PromotionPilot.manifest.json";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    CheckOnly = checkOnly,
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
        throw new FileNotFoundException("CAT-6 promotion manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    ValidateManifestShape(manifest);
    var packet = manifest.packets![0];
    var sourceText = ReadManifestRowText(manifest.sourceManifest!, packet.sourceRow!);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    if (!createMissing && !checkOnly)
    {
        RequireRecord<Spell>(index, packet.spell!);
        foreach (var effect in packet.effects!)
        {
            RequireRecord<MagicEffect>(index, effect.magicEffect!);
        }
    }

    var effects = new List<(Cat6Effect Definition, MagicEffect Record)>();
    foreach (var effectDefinition in packet.effects!)
    {
        var effect = createMissing
            ? EnsureMagicEffect(mod, index, allocator, effectDefinition, sourceText, report)
            : RequireRecord<MagicEffect>(index, effectDefinition.magicEffect!);
        ConfigureMagicEffect(effect, effectDefinition, sourceText);
        effects.Add((effectDefinition, effect));
    }

    var spell = createMissing
        ? EnsureSpell(mod, index, allocator, packet, report)
        : RequireRecord<Spell>(index, packet.spell!);
    ConfigureSpell(spell, packet, sourceText, effects);

    if (checkOnly)
    {
        CheckPacket(spell, sourceText, effects, report);
    }
    else
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "cat6-khajiit-lunar-t1");
    }

    report.Status = "PASS";
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Exception = ex.ToString();
    report.Errors.Add(ex.Message);
}
finally
{
    report.FinishedAt = DateTimeOffset.Now;
    Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
}

return report.Status == "PASS" ? 0 : 1;

static Cat6Manifest LoadManifest(string manifestPath)
{
    var json = File.ReadAllText(manifestPath);
    return JsonSerializer.Deserialize<Cat6Manifest>(json, new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    }) ?? throw new InvalidOperationException("CAT-6 manifest did not parse.");
}

static void ValidateManifestShape(Cat6Manifest manifest)
{
    if (manifest.schema != "pdv.cat6.promotion-pilot.v1")
    {
        throw new InvalidOperationException($"Unexpected CAT-6 manifest schema {manifest.schema ?? "(missing)"}.");
    }

    if (manifest.packets is null || manifest.packets.Count != 1)
    {
        throw new InvalidOperationException("CAT-6 pilot must contain exactly one packet.");
    }

    var packet = manifest.packets[0];
    if (packet.sourceRow != "PDV_Bless_Khajiit_Lunar_T1"
        || packet.spell != "PDV_Bless_Khajiit_Lunar_T1"
        || packet.effects is null
        || packet.effects.Count != 2)
    {
        throw new InvalidOperationException("CAT-6 pilot is restricted to PDV_Bless_Khajiit_Lunar_T1 with two effect records.");
    }

    foreach (var effect in packet.effects)
    {
        if (string.IsNullOrWhiteSpace(effect.magicEffect)
            || string.IsNullOrWhiteSpace(effect.name)
            || string.IsNullOrWhiteSpace(effect.actorValue))
        {
            throw new InvalidOperationException("CAT-6 effect packet is missing required fields.");
        }
    }
}

static string ReadManifestRowText(string sourceManifestPath, string sourceRow)
{
    var manifestPath = Path.GetFullPath(sourceManifestPath);
    var text = File.ReadAllText(manifestPath);
    var pattern = @"\|\s*" + Regex.Escape(sourceRow) + @"\s*\|(?:[^|]*\|){6}\s*(?<text>[^|]+?)\s*\|";
    var match = Regex.Match(text, pattern);
    if (!match.Success)
    {
        throw new InvalidOperationException($"Source row {sourceRow} was not found in {sourceManifestPath}.");
    }

    return match.Groups["text"].Value.Trim();
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
    Cat6Effect definition,
    string sourceText,
    AuthorReport report)
{
    if (index.TryGetValue(definition.magicEffect!, out var existing))
    {
        if (existing is not MagicEffect effect)
        {
            throw new InvalidOperationException($"{definition.magicEffect} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        ConfigureMagicEffect(effect, definition, sourceText);
        return effect;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureMagicEffect(created, definition, sourceText);
    mod.MagicEffects.Add(created);
    index[definition.magicEffect!] = created;
    report.Actions.Add($"Created magic effect {definition.magicEffect}.");
    return created;
}

static Spell EnsureSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    Cat6Packet packet,
    AuthorReport report)
{
    if (index.TryGetValue(packet.spell!, out var existing))
    {
        if (existing is not Spell spell)
        {
            throw new InvalidOperationException($"{packet.spell} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return spell;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[packet.spell!] = created;
    report.Actions.Add($"Created spell {packet.spell}.");
    return created;
}

static void ConfigureMagicEffect(MagicEffect effect, Cat6Effect definition, string sourceText)
{
    effect.EditorID = definition.magicEffect;
    effect.FormVersion = 44;
    effect.Name = Tx(definition.name!);
    effect.Description = Tx(sourceText);
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

static void ConfigureSpell(Spell spell, Cat6Packet packet, string sourceText, IReadOnlyList<(Cat6Effect Definition, MagicEffect Record)> effects)
{
    spell.EditorID = packet.spell;
    spell.FormVersion = 44;
    spell.Name = Tx(packet.name!);
    spell.Description = Tx(sourceText);
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
        AddNightConditions(effect);
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

static ActorValue ParseActorValue(string actorValue)
{
    if (Enum.TryParse<ActorValue>(actorValue, ignoreCase: true, out var parsed))
    {
        return parsed;
    }

    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
}

static void CheckPacket(
    Spell spell,
    string sourceText,
    IReadOnlyList<(Cat6Effect Definition, MagicEffect Record)> effects,
    AuthorReport report)
{
    if (!string.Equals(spell.Description?.String, sourceText, StringComparison.Ordinal))
    {
        throw new InvalidOperationException("CAT-6 spell description does not match source manifest text exactly.");
    }

    foreach (var (_, effect) in effects)
    {
        if (!string.Equals(effect.Description?.String, sourceText, StringComparison.Ordinal))
        {
            throw new InvalidOperationException($"{effect.EditorID} description does not match source manifest text exactly.");
        }
    }

    if (spell.Effects.Count != effects.Count)
    {
        throw new InvalidOperationException($"CAT-6 spell has {spell.Effects.Count} effect(s), expected {effects.Count}.");
    }

    foreach (var spellEffect in spell.Effects)
    {
        if (spellEffect.Conditions is null || spellEffect.Conditions.Count != 2)
        {
            throw new InvalidOperationException("CAT-6 spell effect is missing the required two GetCurrentTime conditions.");
        }
    }

    report.Actions.Add("Checked CAT-6 Khajiit lunar Tier 1 record packet.");
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
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
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

sealed class Cat6Manifest
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public string? sourceManifest { get; set; }
    public List<string>? allowedRows { get; set; }
    public List<Cat6Packet>? packets { get; set; }
}

sealed class Cat6Packet
{
    public string? id { get; set; }
    public string? sourceRow { get; set; }
    public string? recordStatus { get; set; }
    public string? spell { get; set; }
    public string? name { get; set; }
    public List<Cat6Effect>? effects { get; set; }
}

sealed class Cat6Effect
{
    public string? magicEffect { get; set; }
    public string? name { get; set; }
    public string? archetype { get; set; }
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public int duration { get; set; }
    public int area { get; set; }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public bool CheckOnly { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
