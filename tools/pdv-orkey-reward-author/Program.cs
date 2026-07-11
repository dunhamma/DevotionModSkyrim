using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerScriptName = "PDV__ManagerQuest";

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

var rewards = new[]
{
    new RewardDef(
        "PDV_Bless_Nord_Arkay_T1",
        "Orkey's Vigil - Seeker",
        "The Old Knocker keeps count of your years. Disease Resistance +5%.",
        new[]
        {
            new EffectDef("PDV_MGEF_Nord_Arkay_T1_Disease", "Orkey's Vigil - Seeker", "ResistDisease", 5.0f)
        }),
    new RewardDef(
        "PDV_Bless_Nord_Arkay_T2",
        "Orkey's Vigil - Devoted",
        "You keep the count between life and death. Disease Resistance +15%, Maximum Health +20.",
        new[]
        {
            new EffectDef("PDV_MGEF_Nord_Arkay_T2_Disease", "Orkey's Vigil - Devoted", "ResistDisease", 15.0f),
            new EffectDef("PDV_MGEF_Nord_Arkay_T2_Health", "Orkey's Hardiness - Devoted", "Health", 20.0f)
        }),
    new RewardDef(
        "PDV_Bless_Nord_Arkay_T3",
        "Orkey's Ward - Champion",
        "Orkey's ward stands between you and the grave. Disease Resistance +27%, Maximum Health +30.",
        new[]
        {
            new EffectDef("PDV_MGEF_Nord_Arkay_T3_Disease", "Orkey's Ward - Champion", "ResistDisease", 27.0f),
            new EffectDef("PDV_MGEF_Nord_Arkay_T3_Health", "Orkey's Hardiness - Champion", "Health", 30.0f)
        })
};

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    CheckOnly = checkOnly,
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
    var allocator = new FormKeyAllocator(mod);

    foreach (var reward in rewards)
    {
        var effects = new List<(EffectDef Definition, MagicEffect Record)>();
        foreach (var effect in reward.Effects)
        {
            var magicEffect = checkOnly
                ? RequireRecord<MagicEffect>(index, effect.EditorId)
                : EnsureMagicEffect(mod, index, allocator, effect, reward, report);
            if (!checkOnly)
            {
                ConfigureMagicEffect(magicEffect, effect, reward);
            }
            effects.Add((effect, magicEffect));
        }

        var spell = checkOnly
            ? RequireRecord<Spell>(index, reward.SpellEditorId)
            : EnsureSpell(mod, index, allocator, reward, report);
        if (!checkOnly)
        {
            ConfigureSpell(spell, reward, effects);
        }
        CheckReward(spell, reward, effects, report);
    }

    var managerQuest = RequireRecord<Quest>(index, managerScriptName);
    if (!checkOnly)
    {
        WireQuestScript(
            managerQuest,
            managerScriptName,
            rewards.Select(reward => (ScriptProperty)ObjectProp(reward.SpellEditorId, RequireRecord<Spell>(index, reward.SpellEditorId).FormKey)));
        report.Actions.Add($"Wired {rewards.Length} Orkey reward properties on {managerScriptName}.");
    }
    CheckManagerWiring(managerQuest, managerScriptName, rewards, index, report);

    if (!checkOnly)
    {
        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report, "orkey-rewards");
        }
        else
        {
            report.Actions.Add("Write skipped: errors present (fail-closed). No ESP bytes changed.");
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
        throw new InvalidOperationException($"{editorId} not found in the framework ESP.");
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
    EffectDef effect,
    RewardDef reward,
    AuthorReport report)
{
    if (index.TryGetValue(effect.EditorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{effect.EditorId} exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        report.Actions.Add($"Reconfigured magic effect {effect.EditorId}.");
        return typed;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.MagicEffects.Add(created);
    index[effect.EditorId] = created;
    report.Actions.Add($"Created Orkey magic effect {effect.EditorId} for {reward.SpellEditorId}.");
    return created;
}

static Spell EnsureSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardDef reward,
    AuthorReport report)
{
    if (index.TryGetValue(reward.SpellEditorId, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{reward.SpellEditorId} exists as {existing.GetType().Name}, expected Spell.");
        }
        report.Actions.Add($"Reconfigured spell {reward.SpellEditorId}.");
        return typed;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[reward.SpellEditorId] = created;
    report.Actions.Add($"Created Orkey reward spell {reward.SpellEditorId}.");
    return created;
}

static void ConfigureMagicEffect(MagicEffect magicEffect, EffectDef effect, RewardDef reward)
{
    magicEffect.EditorID = effect.EditorId;
    magicEffect.FormVersion = 44;
    magicEffect.Name = Tx(effect.DisplayName);
    magicEffect.Description = Tx(reward.Description);
    magicEffect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    magicEffect.BaseCost = 0.0f;
    magicEffect.MagicSkill = ActorValue.None;
    magicEffect.ResistValue = ActorValue.None;
    magicEffect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(effect.ActorValue)
    };
    magicEffect.CastType = CastType.ConstantEffect;
    magicEffect.TargetType = TargetType.Self;
    magicEffect.SkillUsageMultiplier = 0.0f;
    magicEffect.ScriptEffectAIScore = 0.0f;
    magicEffect.ScriptEffectAIDelayTime = 0.0f;
}

static void ConfigureSpell(Spell spell, RewardDef reward, IReadOnlyList<(EffectDef Definition, MagicEffect Record)> effects)
{
    spell.EditorID = reward.SpellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(reward.DisplayName);
    spell.Description = Tx(reward.Description);
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
        spell.Effects.Add(new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData
            {
                Magnitude = definition.Magnitude,
                Area = 0,
                Duration = 0
            },
            Conditions = []
        });
    }
}

static void CheckReward(
    Spell spell,
    RewardDef reward,
    IReadOnlyList<(EffectDef Definition, MagicEffect Record)> effects,
    AuthorReport report)
{
    CheckString(spell.Name?.String ?? "", reward.DisplayName, $"{reward.SpellEditorId}.Name", report);
    CheckString(spell.Description?.String ?? "", reward.Description, $"{reward.SpellEditorId}.Description", report);
    if (spell.Type != SpellType.Ability || spell.CastType != CastType.ConstantEffect || spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{reward.SpellEditorId}: expected Ability/ConstantEffect/Self.");
    }
    if (spell.Effects.Count != effects.Count)
    {
        report.Errors.Add($"{reward.SpellEditorId}: expected {effects.Count} effects, found {spell.Effects.Count}.");
    }

    foreach (var (definition, magicEffect) in effects)
    {
        CheckString(magicEffect.Name?.String ?? "", definition.DisplayName, $"{definition.EditorId}.Name", report);
        CheckString(magicEffect.Description?.String ?? "", reward.Description, $"{definition.EditorId}.Description", report);
        if (magicEffect.Archetype.ActorValue != ParseActorValue(definition.ActorValue))
        {
            report.Errors.Add($"{definition.EditorId}: expected ValueModifier {definition.ActorValue}.");
        }
        var spellEffect = spell.Effects.FirstOrDefault(candidate => candidate.BaseEffect.FormKey.Equals(magicEffect.FormKey));
        if (spellEffect is null)
        {
            report.Errors.Add($"{reward.SpellEditorId}: missing effect {definition.EditorId}.");
        }
        else if (Math.Abs((spellEffect.Data?.Magnitude ?? 0.0f) - definition.Magnitude) > 0.001f
            || spellEffect.Data?.Area != 0
            || spellEffect.Data?.Duration != 0)
        {
            report.Errors.Add($"{reward.SpellEditorId}.{definition.EditorId}: magnitude/area/duration mismatch.");
        }
    }

    report.Actions.Add($"Checked Orkey reward packet {reward.SpellEditorId}.");
}

static void CheckString(string actual, string expected, string label, AuthorReport report)
{
    if (!string.Equals(actual, expected, StringComparison.Ordinal))
    {
        report.Errors.Add($"{label}: actual='{actual}' expected='{expected}'.");
    }
}

static void CheckManagerWiring(
    Quest managerQuest,
    string scriptName,
    IEnumerable<RewardDef> expectedRewards,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    AuthorReport report)
{
    var script = managerQuest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{scriptName} is missing its manager VMAD script.");
        return;
    }

    foreach (var reward in expectedRewards)
    {
        var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, reward.SpellEditorId, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty || objectProperty.Object.FormKeyNullable is null)
        {
            report.Errors.Add($"{scriptName} VMAD property {reward.SpellEditorId} is missing or unresolved.");
        }
        else if (!objectProperty.Object.FormKey.Equals(RequireRecord<Spell>(index, reward.SpellEditorId).FormKey))
        {
            report.Errors.Add($"{scriptName} VMAD property {reward.SpellEditorId} points at {objectProperty.Object.FormKey}, expected {RequireRecord<Spell>(index, reward.SpellEditorId).FormKey}.");
        }
        else
        {
            report.Actions.Add($"{scriptName}.{reward.SpellEditorId} -> {objectProperty.Object.FormKeyNullable} [ok]");
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
    script = new ScriptEntry { Name = scriptName, Flags = ScriptEntry.Flag.Local };
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

sealed record RewardDef(string SpellEditorId, string DisplayName, string Description, EffectDef[] Effects);
sealed record EffectDef(string EditorId, string DisplayName, string ActorValue, float Magnitude);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public bool CheckOnly { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod)
    {
        modKey = mod.ModKey;
        usedIds = mod.EnumerateMajorRecords()
            .OfType<IMajorRecordGetter>()
            .Select(record => record.FormKey)
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

    private static uint ParseLocalId(FormKey key) => Convert.ToUInt32(key.IDString(), 16);
}
