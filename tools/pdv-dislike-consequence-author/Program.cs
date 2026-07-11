using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultSpec = @"references\authoring\PDV_DislikeConsequenceRecords.spec.json";
const string managerEdid = "PDV__ManagerQuest";
const string managerScriptName = "PDV__ManagerQuest";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var specPath = Path.GetFullPath(GetArg(args, "--spec") ?? defaultSpec);

var report = new AuthorReport
{
    Mode = dryRun ? "dry-run" : write ? "write" : check ? "check" : "none",
    EspPath = espPath,
    SpecPath = specPath,
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
    if (!File.Exists(specPath))
    {
        throw new FileNotFoundException("Dislike consequence spec not found.", specPath);
    }

    var spec = LoadSpec(specPath);
    ValidateSpec(spec);
    var spells = ExpandSpells(spec);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (check)
    {
        CheckBatch(index, spells, report);
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        foreach (var spell in spells)
        {
            BuildSpell(mod, index, allocator, spell, report);
        }
        WireManager(index, spells, report);

        if (write)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            CheckBatch(BuildIndex(readback), spells, report);
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

DisfavorSpec LoadSpec(string specPath)
{
    return JsonSerializer.Deserialize<DisfavorSpec>(File.ReadAllText(specPath), new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    }) ?? throw new InvalidOperationException("Dislike consequence spec did not parse.");
}

void ValidateSpec(DisfavorSpec spec)
{
    if (spec.schema != "pdv.dislike-consequence-records.v1")
    {
        throw new InvalidOperationException($"Unexpected spec schema {spec.schema ?? "(missing)"}.");
    }
    if (spec.domains is null || spec.domains.Count != 7)
    {
        throw new InvalidOperationException("Spec must define exactly seven disfavor domains.");
    }

    foreach (var domain in spec.domains)
    {
        if (string.IsNullOrWhiteSpace(domain.domain) || string.IsNullOrWhiteSpace(domain.actorValue))
        {
            throw new InvalidOperationException("Each domain needs a domain name and ActorValue.");
        }
        _ = ParseActorValue(domain.actorValue);
        ValidateSpell(domain.light, domain.domain, "light");
        ValidateSpell(domain.sharp, domain.domain, "sharp");
    }
}

void ValidateSpell(DisfavorSpell? spell, string domain, string band)
{
    if (spell is null
        || string.IsNullOrWhiteSpace(spell.spellEditorId)
        || string.IsNullOrWhiteSpace(spell.magicEffectEditorId)
        || string.IsNullOrWhiteSpace(spell.propertyName)
        || string.IsNullOrWhiteSpace(spell.displayName)
        || string.IsNullOrWhiteSpace(spell.description)
        || spell.durationHours <= 0)
    {
        throw new InvalidOperationException($"{domain}/{band} spell spec is incomplete.");
    }
    EnsureAscii(spell.displayName, spell.spellEditorId);
    EnsureAscii(SpellDisplayName(spell), spell.spellEditorId);
    EnsureAscii(spell.description, spell.spellEditorId);
}

string SpellDisplayName(DisfavorSpell spell) =>
    string.IsNullOrWhiteSpace(spell.sourceDisplayName)
        ? spell.displayName!
        : spell.sourceDisplayName!;

List<ExpandedSpell> ExpandSpells(DisfavorSpec spec)
{
    var list = new List<ExpandedSpell>();
    foreach (var domain in spec.domains!)
    {
        list.Add(new ExpandedSpell(domain.domain!, domain.domainId, domain.actorValue!, "light", domain.light!));
        list.Add(new ExpandedSpell(domain.domain!, domain.domainId, domain.actorValue!, "sharp", domain.sharp!));
    }
    return list;
}

void BuildSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    ExpandedSpell spec,
    AuthorReport report)
{
    var mgef = EnsureMagicEffect(mod, index, allocator, spec, report);
    Spell spell;
    if (index.TryGetValue(spec.Definition.spellEditorId!, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{spec.Definition.spellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }
        spell = typed;
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[spec.Definition.spellEditorId!] = spell;
        report.Actions.Add($"Created spell {spec.Definition.spellEditorId}.");
    }

    spell.EditorID = spec.Definition.spellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(SpellDisplayName(spec.Definition));
    spell.Description = Tx(spec.Definition.description!);
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
        Data = new EffectData
        {
            Magnitude = spec.Definition.magnitude,
            Area = 0,
            Duration = DurationSeconds(spec.Definition.durationHours)
        },
        Conditions = []
    });
}

MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    ExpandedSpell spec,
    AuthorReport report)
{
    MagicEffect effect;
    if (index.TryGetValue(spec.Definition.magicEffectEditorId!, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{spec.Definition.magicEffectEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        effect = typed;
    }
    else
    {
        effect = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(effect);
        index[spec.Definition.magicEffectEditorId!] = effect;
        report.Actions.Add($"Created magic effect {spec.Definition.magicEffectEditorId}.");
    }

    effect.EditorID = spec.Definition.magicEffectEditorId;
    effect.FormVersion = 44;
    effect.Name = Tx(spec.Definition.displayName!);
    effect.Description = Tx(spec.Definition.description!);
    effect.Flags = MagicEffect.Flag.Detrimental
        | MagicEffect.Flag.NoArea
        | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(spec.ActorValue)
    };
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
    return effect;
}

void WireManager(Dictionary<string, ISkyrimMajorRecordGetter> index, IReadOnlyList<ExpandedSpell> specs, AuthorReport report)
{
    var manager = RequireRecord<Quest>(index, managerEdid);
    var properties = specs
        .Select(spec => ObjectProp(spec.Definition.propertyName!, RequireRecord<Spell>(index, spec.Definition.spellEditorId!).FormKey))
        .ToList();
    WireQuestScript(manager, managerScriptName, properties);
    report.Actions.Add("Wired PDV__ManagerQuest disfavor sting spell properties.");
}

void CheckBatch(Dictionary<string, ISkyrimMajorRecordGetter> index, IReadOnlyList<ExpandedSpell> specs, AuthorReport report)
{
    foreach (var spec in specs)
    {
        CheckSpell(index, spec, report);
    }

    var manager = CheckRecord<Quest>(index, managerEdid, report);
    var script = manager?.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, managerScriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{managerEdid} is missing VMAD script {managerScriptName}.");
        return;
    }

    foreach (var spec in specs)
    {
        if (index.TryGetValue(spec.Definition.spellEditorId!, out var record) && record is Spell spell)
        {
            CheckObjectProperty(script, spec.Definition.propertyName!, spell.FormKey, managerEdid, report);
        }
        else
        {
            report.Errors.Add($"{managerEdid}.{spec.Definition.propertyName} cannot be checked because {spec.Definition.spellEditorId} is missing.");
        }
    }
}

void CheckSpell(Dictionary<string, ISkyrimMajorRecordGetter> index, ExpandedSpell spec, AuthorReport report)
{
    var spell = CheckRecord<Spell>(index, spec.Definition.spellEditorId!, report);
    var mgef = CheckRecord<MagicEffect>(index, spec.Definition.magicEffectEditorId!, report);
    if (spell is null || mgef is null)
    {
        return;
    }

    var expectedSpellName = SpellDisplayName(spec.Definition);
    if (!string.Equals(spell.Name?.String ?? "", expectedSpellName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} name is '{spell.Name?.String}', expected '{expectedSpellName}'.");
    }
    if (!string.Equals(spell.Description?.String ?? "", spec.Definition.description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} description does not match the disfavor contract.");
    }
    if (spell.Type != SpellType.Ability || spell.CastType != CastType.ConstantEffect || spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} is {spell.Type}/{spell.CastType}/{spell.TargetType}, expected Ability/ConstantEffect/Self.");
    }
    if (spell.Effects.Count != 1)
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} has {spell.Effects.Count} effect(s), expected 1.");
        return;
    }

    var spellEffect = spell.Effects[0];
    if (!spellEffect.BaseEffect.FormKey.Equals(mgef.FormKey))
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} points at {spellEffect.BaseEffect.FormKey}, expected {spec.Definition.magicEffectEditorId}.");
    }
    if (!NearlyEqual(spellEffect.Data?.Magnitude ?? 0.0f, spec.Definition.magnitude)
        || (spellEffect.Data?.Area ?? 0) != 0
        || (spellEffect.Data?.Duration ?? 0) != DurationSeconds(spec.Definition.durationHours))
    {
        report.Errors.Add($"{spec.Definition.spellEditorId} effect data is {spellEffect.Data?.Magnitude ?? 0.0f}/{spellEffect.Data?.Area ?? 0}/{spellEffect.Data?.Duration ?? 0}, expected {spec.Definition.magnitude}/0/{DurationSeconds(spec.Definition.durationHours)}.");
    }

    CheckMagicEffect(mgef, spec, report);
}

void CheckMagicEffect(MagicEffect effect, ExpandedSpell spec, AuthorReport report)
{
    if (!string.Equals(effect.Name?.String ?? "", spec.Definition.displayName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.Definition.magicEffectEditorId} name is '{effect.Name?.String}', expected '{spec.Definition.displayName}'.");
    }
    if (!string.Equals(effect.Description?.String ?? "", spec.Definition.description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.Definition.magicEffectEditorId} description does not match the disfavor contract.");
    }

    var expectedActorValue = ParseActorValue(spec.ActorValue);
    if (effect.Archetype is not MagicEffectArchetype archetype || archetype.ActorValue != expectedActorValue)
    {
        report.Errors.Add($"{spec.Definition.magicEffectEditorId} is not a flat ValueModifier for {expectedActorValue}.");
    }
}

void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(quest.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName)
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

void UpsertProperties(ScriptEntry script, IEnumerable<ScriptProperty> properties)
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

void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expected, string owner, AuthorReport report)
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

ScriptObjectProperty ObjectProp(string name, FormKey formKey)
{
    return new ScriptObjectProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
        Alias = -1
    };
}

T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
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

T? CheckRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, AuthorReport report)
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

Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

ActorValue ParseActorValue(string actorValue)
{
    if (string.Equals(actorValue.Trim(), "Speechcraft", StringComparison.OrdinalIgnoreCase))
    {
        return ActorValue.Speech;
    }

    if (Enum.TryParse<ActorValue>(actorValue.Trim(), ignoreCase: true, out var parsed))
    {
        return parsed;
    }
    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
}

void WriteMod(SkyrimMod mod, string espPath, AuthorReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "dislike-consequence");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.dislike-consequence.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");
}

int DurationSeconds(int hours) => hours * 3600;

void EnsureAscii(string value, string owner)
{
    if (value.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{owner} text must be ASCII-safe.");
    }
}

bool NearlyEqual(float actual, float expected) => Math.Abs(actual - expected) < 0.001f;

string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length)
    {
        return null;
    }
    return args[index + 1];
}

TranslatedString Tx(string value) => new(Language.English, value);

sealed class DisfavorSpec
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public List<DisfavorDomain>? domains { get; set; }
}

sealed class DisfavorDomain
{
    public string? domain { get; set; }
    public int domainId { get; set; }
    public string? actorValue { get; set; }
    public DisfavorSpell? light { get; set; }
    public DisfavorSpell? sharp { get; set; }
}

sealed class DisfavorSpell
{
    public string? spellEditorId { get; set; }
    public string? magicEffectEditorId { get; set; }
    public string? propertyName { get; set; }
    public string? displayName { get; set; }
    public string? sourceDisplayName { get; set; }
    public string? description { get; set; }
    public float magnitude { get; set; }
    public int durationHours { get; set; }
}

sealed record ExpandedSpell(string Domain, int DomainId, string ActorValue, string Band, DisfavorSpell Definition);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string Mode { get; set; } = "";
    public string EspPath { get; set; } = "";
    public string SpecPath { get; set; } = "";
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
