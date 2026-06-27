using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerEdid = "PDV__ManagerQuest";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var specs = BuildSpecs();

var report = new AuthorReport
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
    var index = BuildIndex(mod);

    if (check)
    {
        CheckNeglectBatch(index, specs, report);
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        AuthorNeglectBatch(mod, index, allocator, specs, report);

        if (write)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            CheckNeglectBatch(BuildIndex(readback), specs, report);
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

static void AuthorNeglectBatch(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<NeglectSpellSpec> specs,
    AuthorReport report)
{
    foreach (var spec in specs)
    {
        BuildSpell(mod, index, allocator, spec, report);
    }

    var manager = RequireRecord<Quest>(index, managerEdid);
    var managerProps = specs
        .Where(spec => !string.IsNullOrWhiteSpace(spec.PropertyName))
        .Select(spec => ObjectProp(spec.PropertyName!, RequireRecord<Spell>(index, spec.SpellEditorId).FormKey))
        .ToList();
    WireQuestScript(manager, "PDV__ManagerQuest", managerProps);
    report.Actions.Add("Wired PDV__ManagerQuest neglect spell properties.");
}

static Spell BuildSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    NeglectSpellSpec spec,
    AuthorReport report)
{
    EnsureAscii(spec.Description, spec.SpellEditorId);

    var mgef = EnsureMagicEffect(mod, index, allocator, spec, report);
    Spell spell;
    if (index.TryGetValue(spec.SpellEditorId, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{spec.SpellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }

        spell = typed;
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[spec.SpellEditorId] = spell;
        report.Actions.Add($"Created spell {spec.SpellEditorId}.");
    }

    spell.EditorID = spec.SpellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(spec.SpellName);
    spell.Description = Tx(spec.Description);
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
        BaseEffect = mgef.FormKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData { Magnitude = spec.Magnitude, Area = 0, Duration = 0 },
        Conditions = []
    });

    return spell;
}

static MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    NeglectSpellSpec spec,
    AuthorReport report)
{
    MagicEffect effect;
    if (index.TryGetValue(spec.MagicEffectEditorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{spec.MagicEffectEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        effect = typed;
    }
    else
    {
        effect = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(effect);
        index[spec.MagicEffectEditorId] = effect;
        report.Actions.Add($"Created magic effect {spec.MagicEffectEditorId}.");
    }

    var actorValue = ParseActorValue(spec.ActorValue);
    effect.EditorID = spec.MagicEffectEditorId;
    effect.FormVersion = 44;
    effect.Name = Tx(spec.EffectName);
    effect.Description = Tx(spec.Description);
    effect.Flags = MagicEffect.Flag.Detrimental
        | MagicEffect.Flag.NoArea
        | MagicEffect.Flag.NoDuration
        | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    if (UsesPeakValueModifier(actorValue))
    {
        effect.Flags |= MagicEffect.Flag.Recover | MagicEffect.Flag.PowerAffectsMagnitude;
        effect.Archetype = new MagicEffectPeakValueModArchetype
        {
            ActorValue = actorValue
        };
    }
    else
    {
        effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
        {
            ActorValue = actorValue
        };
    }
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
    return effect;
}

static void CheckNeglectBatch(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<NeglectSpellSpec> specs,
    AuthorReport report)
{
    foreach (var spec in specs)
    {
        CheckSpell(index, spec, report);
    }

    var manager = CheckRecord<Quest>(index, managerEdid, report);
    var script = manager?.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{managerEdid} is missing VMAD script PDV__ManagerQuest.");
        return;
    }

    foreach (var spec in specs.Where(spec => !string.IsNullOrWhiteSpace(spec.PropertyName)))
    {
        if (index.TryGetValue(spec.SpellEditorId, out var record) && record is Spell spell)
        {
            CheckObjectProperty(script, spec.PropertyName!, spell.FormKey, managerEdid, report);
        }
        else
        {
            report.Errors.Add($"{managerEdid}.{spec.PropertyName} cannot be checked because {spec.SpellEditorId} is missing.");
        }
    }
}

static void CheckSpell(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    NeglectSpellSpec spec,
    AuthorReport report)
{
    var spell = CheckRecord<Spell>(index, spec.SpellEditorId, report);
    var mgef = CheckRecord<MagicEffect>(index, spec.MagicEffectEditorId, report);
    if (spell is null || mgef is null)
    {
        return;
    }

    if (!string.Equals(spell.Name?.String ?? "", spec.SpellName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.SpellEditorId} name is '{spell.Name?.String}', expected '{spec.SpellName}'.");
    }
    if (!string.Equals(spell.Description?.String ?? "", spec.Description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.SpellEditorId} description does not match the neglect contract.");
    }
    if (spell.Type != SpellType.Ability || spell.CastType != CastType.ConstantEffect || spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{spec.SpellEditorId} is {spell.Type}/{spell.CastType}/{spell.TargetType}, expected Ability/ConstantEffect/Self.");
    }
    if (spell.Effects.Count != 1)
    {
        report.Errors.Add($"{spec.SpellEditorId} has {spell.Effects.Count} effect(s), expected 1.");
        return;
    }

    var spellEffect = spell.Effects[0];
    if (!spellEffect.BaseEffect.FormKey.Equals(mgef.FormKey))
    {
        report.Errors.Add($"{spec.SpellEditorId} points at {spellEffect.BaseEffect.FormKey}, expected {spec.MagicEffectEditorId}.");
    }
    if (!NearlyEqual(spellEffect.Data?.Magnitude ?? 0.0f, spec.Magnitude)
        || (spellEffect.Data?.Area ?? 0) != 0
        || (spellEffect.Data?.Duration ?? 0) != 0)
    {
        report.Errors.Add($"{spec.SpellEditorId} effect data is {spellEffect.Data?.Magnitude ?? 0.0f}/{spellEffect.Data?.Area ?? 0}/{spellEffect.Data?.Duration ?? 0}, expected {spec.Magnitude}/0/0.");
    }

    CheckMagicEffect(mgef, spec, report);
}

static void CheckMagicEffect(MagicEffect effect, NeglectSpellSpec spec, AuthorReport report)
{
    if (!string.Equals(effect.Name?.String ?? "", spec.EffectName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.MagicEffectEditorId} name is '{effect.Name?.String}', expected '{spec.EffectName}'.");
    }
    if (!string.Equals(effect.Description?.String ?? "", spec.Description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.MagicEffectEditorId} description does not match the neglect contract.");
    }

    var expectedActorValue = ParseActorValue(spec.ActorValue);
    if (UsesPeakValueModifier(expectedActorValue))
    {
        if (effect.Archetype is not MagicEffectPeakValueModArchetype peak || peak.ActorValue != expectedActorValue)
        {
            report.Errors.Add($"{spec.MagicEffectEditorId} is not a PeakValueModifier for {expectedActorValue}.");
        }
    }
    else if (effect.Archetype is not MagicEffectArchetype archetype || archetype.ActorValue != expectedActorValue)
    {
        report.Errors.Add($"{spec.MagicEffectEditorId} is not a ValueModifier for {expectedActorValue}.");
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

static ActorValue ParseActorValue(string actorValue)
{
    if (Enum.TryParse<ActorValue>(actorValue.Trim(), ignoreCase: true, out var parsed))
    {
        return parsed;
    }

    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
}

static bool UsesPeakValueModifier(ActorValue actorValue)
{
    return actorValue == ActorValue.Health
        || actorValue == ActorValue.Magicka
        || actorValue == ActorValue.Stamina
        || actorValue == ActorValue.HealRate
        || actorValue == ActorValue.MagickaRate
        || actorValue == ActorValue.StaminaRate
        || actorValue == ActorValue.HealRateMult
        || actorValue == ActorValue.MagickaRateMult
        || actorValue == ActorValue.StaminaRateMult;
}

static void WriteMod(SkyrimMod mod, string espPath, AuthorReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "neglect-esp");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.neglect-esp.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");
}

static void EnsureAscii(string value, string owner)
{
    if (value.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{owner} text must be ASCII-safe.");
    }
}

static bool NearlyEqual(float actual, float expected) => Math.Abs(actual - expected) < 0.001f;

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

static NeglectSpellSpec[] BuildSpecs() =>
[
    new(
        "PDV_SPEL_Neglect_Kyne",
        "PDV_MGEF_Neglect_Kyne_Stamina",
        "PDV_SPEL_Neglect_Kyne",
        "The Weather Stops Cooperating",
        "The Weather Stops Cooperating",
        "The weather no longer feels on your side and the cold bites deeper. Frost Resistance -8% until you return to the open sky and keep Kyne's regard.",
        "ResistFrost",
        -8.0f),
    new(
        "PDV_SPEL_Neglect_Imperial",
        "PDV_MGEF_Neglect_Imperial_Restoration",
        "PDV_SPEL_Neglect_Imperial",
        "The Divines Grow Distant",
        "The Divines Grow Distant",
        "You have let civic faith lapse. The Divines' ward against sickness thins -- Disease Resistance -5% until you return to public service. The real bite comes only at rupture or curse.",
        "ResistDisease",
        -5.0f),
    new(
        "PDV_SPEL_Neglect_Shor",
        "PDV_MGEF_Neglect_Shor",
        "PDV_SPEL_Neglect_Shor",
        "Shor's Neglect",
        "Shor's Neglect",
        "Sovngarde's hall forgets the idle; your sword-arm dulls. One-Handed -5 until you return to valor.",
        "OneHanded",
        -5.0f),
    new(
        "PDV_SPEL_Neglect_Tsun",
        "PDV_MGEF_Neglect_Tsun",
        "PDV_SPEL_Neglect_Tsun",
        "Tsun's Neglect",
        "Tsun's Neglect",
        "Tsun sets no trials for the absent; your endurance flags. Maximum Stamina -15 until you take up the trials again.",
        "Stamina",
        -15.0f),
    new(
        "PDV_SPEL_Neglect_Stuhn",
        "PDV_MGEF_Neglect_Stuhn",
        "PDV_SPEL_Neglect_Stuhn",
        "Stuhn's Neglect",
        "Stuhn's Neglect",
        "Stuhn's ward withdraws from the unmindful; your guard thins. Armor -5 until you keep faith with the shield-thane.",
        "DamageResist",
        -5.0f),
    new(
        "PDV_SPEL_Neglect_Talos",
        "PDV_MGEF_Neglect_Talos",
        "PDV_SPEL_Neglect_Talos",
        "Talos's Neglect",
        "Talos's Neglect",
        "Defiance left unkept softens; your resolve no longer hardens you. Armor -5 until you stand firm again.",
        "DamageResist",
        -5.0f),
];

sealed record NeglectSpellSpec(
    string SpellEditorId,
    string MagicEffectEditorId,
    string? PropertyName,
    string SpellName,
    string EffectName,
    string Description,
    string ActorValue,
    float Magnitude);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string Mode { get; set; } = "";
    public string EspPath { get; set; } = "";
    public string? BackupPath { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<string> TouchedFiles { get; } = [];
    public string? Exception { get; set; }
}

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod, IEnumerable<FormKey> used)
    {
        modKey = mod.ModKey;
        usedIds = used.Where(key => key.ModKey == modKey).Select(key => key.ID).ToHashSet();
        nextId = Math.Max(0x800u, usedIds.Count == 0 ? 0x800u : usedIds.Max() + 1);
    }

    public FormKey Next()
    {
        while (usedIds.Contains(nextId))
        {
            nextId++;
        }

        var key = new FormKey(modKey, nextId);
        usedIds.Add(nextId);
        nextId++;
        return key;
    }
}
