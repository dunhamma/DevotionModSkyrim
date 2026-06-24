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
var spellSpecs = BuildSpellSpecs();
var messageSpecs = BuildMessageSpecs();

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
        CheckRedguardSpine(index, spellSpecs, messageSpecs, report);
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        AuthorRedguardSpine(mod, index, allocator, spellSpecs, messageSpecs, report);
        if (write)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            CheckRedguardSpine(BuildIndex(readback), spellSpecs, messageSpecs, report);
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

static void AuthorRedguardSpine(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<SpellSpec> spellSpecs,
    IReadOnlyList<MessageSpec> messageSpecs,
    AuthorReport report)
{
    foreach (var spec in spellSpecs)
    {
        BuildSpell(mod, index, allocator, spec, report);
    }

    foreach (var spec in messageSpecs)
    {
        EnsureMessage(mod, index, allocator, spec, report);
    }

    var manager = RequireRecord<Quest>(index, managerEdid);
    WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
    {
        ObjectProp("PDV_Bless_Redguard_Spine_Crown", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_Crown").FormKey),
        ObjectProp("PDV_Bless_Redguard_Spine_Forebear", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_Forebear").FormKey),
        ObjectProp("PDV_Bless_Redguard_Spine_AshAbah", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_AshAbah").FormKey),
        ObjectProp("PDV_Notif_Redguard_AncestorSpine_Rest", RequireRecord<Message>(index, "PDV_Notif_Redguard_AncestorSpine_Rest").FormKey),
    });
    report.Actions.Add("Wired Redguard spine boon properties on PDV__ManagerQuest.");
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    MessageSpec spec,
    AuthorReport report)
{
    if (spec.Title.Any(ch => ch > 127) || spec.Body.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{spec.EditorId} text must be ASCII-safe.");
    }

    Message message;
    if (index.TryGetValue(spec.EditorId, out var existing))
    {
        if (existing is not Message typed)
        {
            throw new InvalidOperationException($"{spec.EditorId} already exists as {existing.GetType().Name}, expected Message.");
        }
        message = typed;
    }
    else
    {
        message = new Message(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Messages.Add(message);
        index[spec.EditorId] = message;
        report.Actions.Add($"Created message {spec.EditorId}.");
    }

    message.EditorID = spec.EditorId;
    message.FormVersion = 44;
    message.Name = Tx(spec.Title);
    message.Description = Tx(spec.Body);
    message.Flags = 0;
    message.MenuButtons.Clear();
    return message;
}
static Spell BuildSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    SpellSpec spec,
    AuthorReport report)
{
    if (spec.Description.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{spec.SpellEditorId} description must be ASCII-safe.");
    }

    var effects = new List<(EffectSpec Spec, MagicEffect Record)>();
    foreach (var effectSpec in spec.Effects)
    {
        effects.Add((effectSpec, EnsureMgef(mod, index, allocator, spec, effectSpec, report)));
    }

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
    spell.Name = Tx(spec.DisplayName);
    spell.Description = Tx(spec.Description);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();

    foreach (var (effectSpec, record) in effects)
    {
        spell.Effects.Add(new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = effectSpec.Magnitude, Area = 0, Duration = 0 },
            Conditions = []
        });
    }

    return spell;
}

static MagicEffect EnsureMgef(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    SpellSpec spellSpec,
    EffectSpec effectSpec,
    AuthorReport report)
{
    MagicEffect record;
    if (index.TryGetValue(effectSpec.EffectEditorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{effectSpec.EffectEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        record = typed;
    }
    else
    {
        record = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(record);
        index[effectSpec.EffectEditorId] = record;
        report.Actions.Add($"Created magic effect {effectSpec.EffectEditorId}.");
    }

    record.EditorID = effectSpec.EffectEditorId;
    record.FormVersion = 44;
    record.Name = Tx(effectSpec.DisplayName);
    record.Description = Tx(spellSpec.Description);
    record.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    record.BaseCost = 0.0f;
    record.MagicSkill = ActorValue.None;
    record.ResistValue = ActorValue.None;
    var actorValue = ParseActorValue(effectSpec.ActorValue);
    if (UsesPeakValueModifier(actorValue))
    {
        record.Flags |= MagicEffect.Flag.Recover | MagicEffect.Flag.PowerAffectsMagnitude;
        record.Archetype = new MagicEffectPeakValueModArchetype
        {
            ActorValue = actorValue
        };
    }
    else
    {
        record.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
        {
            ActorValue = actorValue
        };
    }
    record.CastType = CastType.ConstantEffect;
    record.TargetType = TargetType.Self;
    record.SkillUsageMultiplier = 0.0f;
    record.ScriptEffectAIScore = 0.0f;
    record.ScriptEffectAIDelayTime = 0.0f;
    return record;
}

static void CheckRedguardSpine(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<SpellSpec> spellSpecs,
    IReadOnlyList<MessageSpec> messageSpecs,
    AuthorReport report)
{
    foreach (var spec in spellSpecs)
    {
        CheckSpell(index, spec, report);
    }

    foreach (var spec in messageSpecs)
    {
        CheckMessage(index, spec, report);
    }

    var manager = CheckRecord<Quest>(index, managerEdid, report);
    if (manager is not null)
    {
        var script = CheckQuestScript(manager, "PDV__ManagerQuest", report);
        if (script is not null)
        {
            CheckObjectProperty(script, "PDV_Bless_Redguard_Spine_Crown", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_Crown").FormKey, managerEdid, report);
            CheckObjectProperty(script, "PDV_Bless_Redguard_Spine_Forebear", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_Forebear").FormKey, managerEdid, report);
            CheckObjectProperty(script, "PDV_Bless_Redguard_Spine_AshAbah", RequireRecord<Spell>(index, "PDV_Bless_Redguard_Spine_AshAbah").FormKey, managerEdid, report);
            CheckObjectProperty(script, "PDV_Notif_Redguard_AncestorSpine_Rest", RequireRecord<Message>(index, "PDV_Notif_Redguard_AncestorSpine_Rest").FormKey, managerEdid, report);
        }
    }
}

static void CheckMessage(Dictionary<string, ISkyrimMajorRecordGetter> index, MessageSpec spec, AuthorReport report)
{
    var message = CheckRecord<Message>(index, spec.EditorId, report);
    if (message is null)
    {
        return;
    }

    if (!string.Equals(message.Name?.String ?? "", spec.Title, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.EditorId} title is '{message.Name?.String}', expected '{spec.Title}'.");
    }
    if (!string.Equals(message.Description?.String ?? "", spec.Body, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.EditorId} body does not match the Redguard ancestor-spine contract.");
    }
    if (message.Flags.HasFlag(Message.Flag.MessageBox))
    {
        report.Errors.Add($"{spec.EditorId} should be a notification, not a MessageBox.");
    }
}
static void CheckSpell(Dictionary<string, ISkyrimMajorRecordGetter> index, SpellSpec spec, AuthorReport report)
{
    var spell = CheckRecord<Spell>(index, spec.SpellEditorId, report);
    if (spell is null)
    {
        return;
    }

    if (!string.Equals(spell.Name?.String ?? "", spec.DisplayName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.SpellEditorId} name is '{spell.Name?.String}', expected '{spec.DisplayName}'.");
    }
    if (!string.Equals(spell.Description?.String ?? "", spec.Description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spec.SpellEditorId} description does not match the Redguard spine contract.");
    }
    if (spell.Type != SpellType.Ability || spell.CastType != CastType.ConstantEffect || spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{spec.SpellEditorId} is {spell.Type}/{spell.CastType}/{spell.TargetType}, expected Ability/ConstantEffect/Self.");
    }
    if (spell.Effects.Count != spec.Effects.Length)
    {
        report.Errors.Add($"{spec.SpellEditorId} has {spell.Effects.Count} effect(s), expected {spec.Effects.Length}.");
        return;
    }

    foreach (var effectSpec in spec.Effects)
    {
        var mgef = CheckRecord<MagicEffect>(index, effectSpec.EffectEditorId, report);
        if (mgef is null)
        {
            continue;
        }
        CheckMagicEffect(mgef, spec, effectSpec, report);
        var spellEffect = spell.Effects.FirstOrDefault(candidate => candidate.BaseEffect.FormKey.Equals(mgef.FormKey));
        if (spellEffect is null)
        {
            report.Errors.Add($"{spec.SpellEditorId} is missing effect {effectSpec.EffectEditorId}.");
            continue;
        }
        if (!NearlyEqual(spellEffect.Data?.Magnitude ?? 0.0f, effectSpec.Magnitude)
            || (spellEffect.Data?.Area ?? 0) != 0
            || (spellEffect.Data?.Duration ?? 0) != 0)
        {
            report.Errors.Add($"{spec.SpellEditorId}.{effectSpec.EffectEditorId} magnitude/area/duration is {spellEffect.Data?.Magnitude ?? 0.0f}/{spellEffect.Data?.Area ?? 0}/{spellEffect.Data?.Duration ?? 0}, expected {effectSpec.Magnitude}/0/0.");
        }
    }
}

static void CheckMagicEffect(MagicEffect mgef, SpellSpec spellSpec, EffectSpec effectSpec, AuthorReport report)
{
    if (!string.Equals(mgef.Name?.String ?? "", effectSpec.DisplayName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{effectSpec.EffectEditorId} name is '{mgef.Name?.String}', expected '{effectSpec.DisplayName}'.");
    }
    if (!string.Equals(mgef.Description?.String ?? "", spellSpec.Description, StringComparison.Ordinal))
    {
        report.Errors.Add($"{effectSpec.EffectEditorId} description does not match the Redguard spine contract.");
    }

    var actorValue = ParseActorValue(effectSpec.ActorValue);
    if (UsesPeakValueModifier(actorValue))
    {
        if (mgef.Archetype is not MagicEffectPeakValueModArchetype peak || peak.ActorValue != actorValue)
        {
            report.Errors.Add($"{effectSpec.EffectEditorId} is not a PeakValueModifier for {actorValue}.");
        }
    }
    else if (mgef.Archetype is not MagicEffectArchetype valueModifier || valueModifier.ActorValue != actorValue)
    {
        report.Errors.Add($"{effectSpec.EffectEditorId} is not a ValueModifier for {actorValue}.");
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

static ScriptEntry? CheckQuestScript(Quest quest, string scriptName, AuthorReport report)
{
    var script = quest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{quest.EditorID} is missing script {scriptName}.");
        return null;
    }

    report.Actions.Add($"Readback PASS: {quest.EditorID} has {scriptName} attached.");
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

static void WriteMod(SkyrimMod mod, string espPath, AuthorReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "redguard-spine");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.redguard-spine.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");
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

static SpellSpec[] BuildSpellSpecs() =>
[
    new(
        "PDV_Bless_Redguard_Spine_Crown",
        "Redguard Spine - Crown",
        "The old form steadies your stance. Maximum Health +10, One-Handed +4.",
        [
            new("PDV_MGEF_Redguard_Spine_Crown_Health", "Redguard Crown Spine Health", "Health", 10.0f),
            new("PDV_MGEF_Redguard_Spine_Crown_OneHanded", "Redguard Crown Spine Precision", "OneHanded", 4.0f),
        ]),
    new(
        "PDV_Bless_Redguard_Spine_Forebear",
        "Redguard Spine - Forebear",
        "The road hardens without breaking the old line. Maximum Health +8, One-Handed +5.",
        [
            new("PDV_MGEF_Redguard_Spine_Forebear_Health", "Redguard Forebear Spine Health", "Health", 8.0f),
            new("PDV_MGEF_Redguard_Spine_Forebear_OneHanded", "Redguard Forebear Spine Precision", "OneHanded", 5.0f),
        ]),
    new(
        "PDV_Bless_Redguard_Spine_AshAbah",
        "Redguard Spine - Ash'abah",
        "The death-duty leaves you steady where others turn away. Maximum Health +12, One-Handed +3.",
        [
            new("PDV_MGEF_Redguard_Spine_AshAbah_Health", "Redguard Ash'abah Spine Health", "Health", 12.0f),
            new("PDV_MGEF_Redguard_Spine_AshAbah_OneHanded", "Redguard Ash'abah Spine Precision", "OneHanded", 3.0f),
        ]),
];

static MessageSpec[] BuildMessageSpecs() =>
[
    new(
        "PDV_Notif_Redguard_AncestorSpine_Rest",
        "Ancestor Rest",
        "The ancestor-line steadies behind you."),
];

sealed record SpellSpec(string SpellEditorId, string DisplayName, string Description, EffectSpec[] Effects);
sealed record EffectSpec(string EffectEditorId, string DisplayName, string ActorValue, float Magnitude);
sealed record MessageSpec(string EditorId, string Title, string Body);

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
