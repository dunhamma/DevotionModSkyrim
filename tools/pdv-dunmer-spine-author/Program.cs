using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimFormList = Mutagen.Bethesda.Skyrim.FormList;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string substrateEdid = "PDV_Substrate_DunmerAncestor";
const string managerEdid = "PDV__ManagerQuest";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var spellSpecs = BuildSpellSpecs();

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
        CheckDunmerSpine(index, spellSpecs, report);
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        AuthorDunmerSpine(mod, index, allocator, spellSpecs, report);
        if (write)
        {
            WriteMod(mod, espPath, report);
            var readback = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
            CheckDunmerSpine(BuildIndex(readback), spellSpecs, report);
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

static void AuthorDunmerSpine(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<SpellSpec> spellSpecs,
    AuthorReport report)
{
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
    var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");

    foreach (var spec in spellSpecs)
    {
        BuildSpell(mod, index, allocator, spec, report);
    }

    var substrate = EnsureQuest(mod, index, allocator, substrateEdid, report);
    ConfigureQuestShell(substrate, "Dunmer Ancestor Spine");
    var substrateProperties = new ScriptProperty[]
    {
        StringProp("SubstrateName", "DunmerAncestor"),
        IntProp("RequiredOriginRace", 5),
        ObjectProp("PDV_GLO_OriginRace", originGlobal.FormKey),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        ObjectProp("Substrate_Always", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_Always").FormKey),
        ObjectProp("Substrate_Mid", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_Mid").FormKey),
        ObjectProp("Substrate_High", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_High").FormKey),
    };
    WireQuestScript(substrate, "PDV_SubstrateBase", substrateProperties);
    WireQuestScript(substrate, "PDV_Substrate_DunmerAncestor", substrateProperties);
    report.Actions.Add("Wired PDV_Substrate_DunmerAncestor base and concrete scripts.");

    var manager = RequireRecord<Quest>(index, managerEdid);
    WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
    {
        ObjectProp("PDV_DunmerAncestorSubstrate", substrate.FormKey),
    });
    report.Actions.Add("Wired PDV_DunmerAncestorSubstrate on PDV__ManagerQuest.");

    EnsureFormListMember(index, "PDV_FLST_Substrates_All", substrate.FormKey, report);
    EnsureFormListMember(index, "PDV_FLST_Substrates_DevOnly", substrate.FormKey, report);
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

static void CheckDunmerSpine(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<SpellSpec> spellSpecs,
    AuthorReport report)
{
    foreach (var spec in spellSpecs)
    {
        CheckSpell(index, spec, report);
    }

    var substrate = CheckRecord<Quest>(index, substrateEdid, report);
    if (substrate is not null)
    {
        CheckQuestScript(substrate, "PDV_SubstrateBase", report);
        var concrete = CheckQuestScript(substrate, "PDV_Substrate_DunmerAncestor", report);
        if (concrete is not null)
        {
            CheckStringProperty(concrete, "SubstrateName", "DunmerAncestor", substrateEdid, report);
            CheckIntProperty(concrete, "RequiredOriginRace", 5, substrateEdid, report);
            CheckObjectProperty(concrete, "PDV_GLO_OriginRace", RequireRecord<Global>(index, "PDV_GLO_OriginRace").FormKey, substrateEdid, report);
            CheckObjectProperty(concrete, "PDV_GLO_DebugLevel", RequireRecord<Global>(index, "PDV_GLO_DebugLevel").FormKey, substrateEdid, report);
            CheckObjectProperty(concrete, "Substrate_Always", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_Always").FormKey, substrateEdid, report);
            CheckObjectProperty(concrete, "Substrate_Mid", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_Mid").FormKey, substrateEdid, report);
            CheckObjectProperty(concrete, "Substrate_High", RequireRecord<Spell>(index, "PDV_Bless_Dunmer_Substrate_High").FormKey, substrateEdid, report);
        }
    }

    var manager = CheckRecord<Quest>(index, managerEdid, report);
    if (manager is not null)
    {
        var script = CheckQuestScript(manager, "PDV__ManagerQuest", report);
        if (script is not null)
        {
            CheckObjectProperty(script, "PDV_DunmerAncestorSubstrate", RequireRecord<Quest>(index, substrateEdid).FormKey, managerEdid, report);
        }
    }

    CheckFormListMember(index, "PDV_FLST_Substrates_All", substrateEdid, report);
    CheckFormListMember(index, "PDV_FLST_Substrates_DevOnly", substrateEdid, report);
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
        report.Errors.Add($"{spec.SpellEditorId} description does not match the Dunmer substrate contract.");
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
        report.Errors.Add($"{effectSpec.EffectEditorId} description does not match the Dunmer substrate contract.");
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

static Quest EnsureQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest quest)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }
        return quest;
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Quests.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created quest {editorId}.");
    return created;
}

static void ConfigureQuestShell(Quest quest, string displayName)
{
    quest.EditorID = substrateEdid;
    quest.Name = Tx(displayName);
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

static void EnsureFormListMember(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string formListEdid,
    FormKey requiredFormKey,
    AuthorReport report)
{
    var formList = RequireRecord<SkyrimFormList>(index, formListEdid);
    if (formList.Items.Any(item => item.FormKey.Equals(requiredFormKey)))
    {
        report.Actions.Add($"{formListEdid} already contains {substrateEdid}.");
        return;
    }

    formList.Items.Add(requiredFormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    report.Actions.Add($"Added {substrateEdid} to {formListEdid}.");
}

static void CheckFormListMember(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string formListEdid,
    string requiredEdid,
    AuthorReport report)
{
    var formList = CheckRecord<SkyrimFormList>(index, formListEdid, report);
    if (formList is null)
    {
        return;
    }
    var required = RequireRecord<ISkyrimMajorRecordGetter>(index, requiredEdid);
    if (formList.Items.Any(item => item.FormKey.Equals(required.FormKey)))
    {
        report.Actions.Add($"Readback PASS: {formListEdid} contains {requiredEdid}.");
    }
    else
    {
        report.Errors.Add($"{formListEdid} does not contain {requiredEdid}.");
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

static void CheckStringProperty(ScriptEntry script, string propertyName, string expected, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptStringProperty stringProperty)
    {
        report.Errors.Add($"{owner}.{propertyName} is missing or not a string property.");
        return;
    }
    if (!string.Equals(stringProperty.Data, expected, StringComparison.Ordinal))
    {
        report.Errors.Add($"{owner}.{propertyName} is '{stringProperty.Data}', expected '{expected}'.");
    }
}

static void CheckIntProperty(ScriptEntry script, string propertyName, int expected, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptIntProperty intProperty)
    {
        report.Errors.Add($"{owner}.{propertyName} is missing or not an int property.");
        return;
    }
    if (intProperty.Data != expected)
    {
        report.Errors.Add($"{owner}.{propertyName} is {intProperty.Data}, expected {expected}.");
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

static ScriptIntProperty IntProp(string name, int value)
{
    return new ScriptIntProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static void WriteMod(SkyrimMod mod, string espPath, AuthorReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "dunmer-spine");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.dunmer-spine.tmp";
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
        "PDV_Bless_Dunmer_Substrate_Always",
        "Dunmer Ancestor's Steadiness",
        "The ancestors keep their hand on you across the diaspora. Magic Resistance +3%.",
        [
            new("PDV_MGEF_Dunmer_Substrate_Always_Magic", "Ancestor's Magic Steadiness", "ResistMagic", 3.0f),
        ]),
    new(
        "PDV_Bless_Dunmer_Substrate_Mid",
        "Dunmer Ancestor's Regard",
        "The ancestors gather closer at hearth and ash. Magic Resistance +9%.",
        [
            new("PDV_MGEF_Dunmer_Substrate_Mid_Magic", "Ancestor's Magic Regard", "ResistMagic", 9.0f),
        ]),
    new(
        "PDV_Bless_Dunmer_Substrate_High",
        "Dunmer Ancestor's Honor",
        "The ancestors are deeply with you even far from the ash. Magic Resistance +20%.",
        [
            new("PDV_MGEF_Dunmer_Substrate_High_Magic", "Ancestor's Magic Honor", "ResistMagic", 20.0f),
        ]),
];

sealed record SpellSpec(string SpellEditorId, string DisplayName, string Description, EffectSpec[] Effects);
sealed record EffectSpec(string EffectEditorId, string DisplayName, string ActorValue, float Magnitude);

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
