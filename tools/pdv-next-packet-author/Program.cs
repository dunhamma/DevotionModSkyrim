using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;
using SkyrimGlobal = Mutagen.Bethesda.Skyrim.Global;
using SkyrimGlobalFloat = Mutagen.Bethesda.Skyrim.GlobalFloat;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultSkyrimEsm = @"D:\Wabbajack\modlists\Anvil\Stock Game\Data\Skyrim.esm";

if (args.Contains("--inspect-dialogue-types"))
{
    DumpType(typeof(DialogTopic));
    DumpType(typeof(DialogResponses));
    DumpType(typeof(DialogResponse));
    DumpType(typeof(DialogResponseFlags));
    DumpType(typeof(DialogBranch));
    DumpType(typeof(DialogBranch.CategoryType));
    DumpType(typeof(DialogBranch.Flag));
    DumpType(typeof(DialogView));
    DumpType(typeof(DialogTopic.CategoryEnum));
    DumpType(typeof(DialogTopic.SubtypeEnum));
    DumpType(typeof(DialogTopic.TopicFlag));
    DumpType(typeof(Condition));
    DumpType(typeof(ConditionGlobal));
    DumpType(typeof(ConditionFloat));
    DumpType(typeof(GetGlobalValueConditionData));
    DumpType(typeof(GetIsIDConditionData));
    DumpType(typeof(FormLinkOrIndex<IGlobalGetter>));
    DumpType(typeof(FormLinkOrIndex<IReferenceableObjectGetter>));
    DumpType(typeof(CompareOperator));
    return 0;
}

var espPath = GetArg(args, "--esp") ?? defaultEsp;
var skyrimEsmPath = GetArg(args, "--skyrim-esm") ?? defaultSkyrimEsm;
var dryRun = args.Contains("--dry-run");
var removePhase11Dialogue = args.Contains("--remove-phase11-dialogue");
var generatePhase11Dialogue = args.Contains("--unsafe-generate-phase11-dialogue");

if (args.Contains("--scan-arngeir-dialogue"))
{
    ScanArngeirDialogue(skyrimEsmPath);
    return 0;
}

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
    var allocator = new FormKeyAllocator(mod, index.Values.Select(r => r.FormKey));

    if (removePhase11Dialogue)
    {
        RemovePhase11ArngeirDialogue(mod, index, report);
        WriteModIfNeeded(mod, espPath, dryRun, report, "phase11-dialogue-removal");
        report.Status = "PASS";
        return 0;
    }

    if (generatePhase11Dialogue)
    {
        throw new InvalidOperationException(
            "Generated Phase 11 Arngeir dialogue is blocked. Rebuild the dialogue surface through a CK-safe path and verify it with --strict-phase11.");
    }

    var khajiitFocusGlobal = EnsureGlobal(mod, index, allocator, "PDV_GLO_KhajiitFocusedEmphasis", 0.0f);
    report.Actions.Add("Ensured PDV_GLO_KhajiitFocusedEmphasis.");

    var portable = RequireRecord<SkyrimActivator>(index, "PDV_ACTI_DunmerPortableShrineSignal");
    UpsertActivatorStringProperty(portable, "PDV_EventSignalActivator", "OncePerDayKey", "PDV.Signal.DunmerPortableShrine.Activator");
    report.Actions.Add("Set PDV_ACTI_DunmerPortableShrineSignal.OncePerDayKey to PDV.Signal.DunmerPortableShrine.Activator.");

    var privateShrine = RequireRecord<SkyrimActivator>(index, "PDV_ACTI_DunmerPrivateShrineSignal");
    UpsertActivatorStringProperty(privateShrine, "PDV_EventSignalActivator", "OncePerDayKey", "PDV.Signal.DunmerHome.Activator");
    report.Actions.Add("Confirmed PDV_ACTI_DunmerPrivateShrineSignal.OncePerDayKey remains PDV.Signal.DunmerHome.Activator.");

    var kyneNeglectEffect = EnsureKyneNeglectEffect(mod, index, allocator);
    report.Actions.Add("Ensured PDV_MGEF_Neglect_Kyne.");

    var kyneNeglectSpell = EnsureKyneNeglectSpell(mod, index, allocator, kyneNeglectEffect);
    report.Actions.Add("Ensured PDV_SPEL_Neglect_Kyne.");

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerProperties = new List<ScriptProperty>
    {
        ObjectProp("PDV_GLO_KhajiitFocusedEmphasis", khajiitFocusGlobal.FormKey),
        ObjectProp("PDV_SPEL_Neglect_Kyne", kyneNeglectSpell.FormKey),
    };
    report.Actions.Add("Wired PDV__ManagerQuest.PDV_SPEL_Neglect_Kyne.");

    WireQuestScript(manager, "PDV__ManagerQuest", managerProperties);
    report.Actions.Add("Wired PDV__ManagerQuest next-packet properties.");

    report.Actions.Add("Skipped Phase 11 Arngeir/Kynareth dialogue generation; CK-safe authoring is required.");

    WriteModIfNeeded(mod, espPath, dryRun, report, "next-packet");

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

static void DumpType(Type type)
{
    Console.WriteLine($"TYPE {type.FullName}");
    if (type.IsEnum)
    {
        Console.WriteLine("VALUES");
        foreach (var value in Enum.GetValues(type))
        {
            Console.WriteLine($"  {value} = {Convert.ToInt64(value)}");
        }
        return;
    }
    Console.WriteLine("CTORS");
    foreach (var ctor in type.GetConstructors())
    {
        Console.WriteLine($"  {ctor}");
    }
    Console.WriteLine("PROPS");
    foreach (var prop in type.GetProperties().Take(160))
    {
        Console.WriteLine($"  {prop.PropertyType.FullName} {prop.Name} set={prop.CanWrite}");
    }
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static void ScanArngeirDialogue(string skyrimEsmPath)
{
    var mod = SkyrimMod.CreateFromBinary(skyrimEsmPath, SkyrimRelease.SkyrimSE);
    Console.WriteLine($"SCAN {skyrimEsmPath}");

    foreach (var record in mod.EnumerateMajorRecords().OfType<ISkyrimMajorRecordGetter>())
    {
        var editorId = record.EditorID ?? "";
        if (editorId.Contains("Arngeir", StringComparison.OrdinalIgnoreCase)
            || editorId.Contains("Greybeard", StringComparison.OrdinalIgnoreCase)
            || editorId.Contains("MQ105", StringComparison.OrdinalIgnoreCase))
        {
            Console.WriteLine($"RECORD {record.GetType().Name} {record.FormKey} {editorId}");
        }
    }

    foreach (var topic in mod.DialogTopics)
    {
        var editorId = topic.EditorID ?? "";
        var name = topic.Name?.String ?? "";
        if (editorId.Contains("Arngeir", StringComparison.OrdinalIgnoreCase)
            || editorId.Contains("Greybeard", StringComparison.OrdinalIgnoreCase)
            || editorId.Contains("MQ105", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Arngeir", StringComparison.OrdinalIgnoreCase)
            || name.Contains("Greybeard", StringComparison.OrdinalIgnoreCase))
        {
            Console.WriteLine($"DIAL {topic.FormKey} {editorId} name='{name}' category={topic.Category} subtype={topic.Subtype} responses={topic.Responses.Count}");
            foreach (var response in topic.Responses.Take(8))
            {
                DumpDialogResponses("  ", response);
            }
        }
    }

}

static void DumpDialogResponses(string indent, DialogResponses response)
{
    Console.WriteLine($"{indent}INFO {response.FormKey} {response.EditorID} topic={response.Topic} speaker={response.Speaker} conds={response.Conditions.Count} flags={response.Flags?.Flags}");
    foreach (var line in response.Responses)
    {
        Console.WriteLine($"{indent}  TEXT {line.ResponseNumber}: '{line.Text?.String}' emotion={line.Emotion}:{line.EmotionValue}");
    }
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

static SkyrimGlobal EnsureGlobal(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, float value)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimGlobal global)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Global.");
        }
        ConfigureGlobal(global, editorId, value);
        return global;
    }

    var created = new SkyrimGlobalFloat(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureGlobal(created, editorId, value);
    mod.Globals.Add(created);
    index[editorId] = created;
    return created;
}

static void ConfigureGlobal(SkyrimGlobal global, string editorId, float value)
{
    global.EditorID = editorId;
    global.FormVersion = 44;
    global.RawFloat = value;
}

static MagicEffect EnsureKyneNeglectEffect(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator)
{
    const string editorId = "PDV_MGEF_Neglect_Kyne";
    MagicEffect effect;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not MagicEffect existingEffect)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        effect = existingEffect;
    }
    else
    {
        effect = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(effect);
        index[editorId] = effect;
    }

    effect.EditorID = editorId;
    effect.FormVersion = 44;
    effect.Name = Tx("Kyne's Withheld Breath");
    effect.Description = Tx("Your neglected bond with Kyne weighs against your breath and endurance.");
    effect.Flags = MagicEffect.Flag.Detrimental | MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.Restoration;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ActorValue.StaminaRateMult
    };
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;

    return effect;
}

static Spell EnsureKyneNeglectSpell(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, MagicEffect magicEffect)
{
    const string editorId = "PDV_SPEL_Neglect_Kyne";
    Spell spell;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Spell existingSpell)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Spell.");
        }
        spell = existingSpell;
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[editorId] = spell;
    }

    spell.EditorID = editorId;
    spell.FormVersion = 44;
    spell.Name = Tx("Kyne's Neglect");
    spell.Description = Tx("Kyne withholds her breath until devotion is restored.");
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
        BaseEffect = magicEffect.FormKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData
        {
            Magnitude = -10.0f,
            Area = 0,
            Duration = 0
        }
    });

    return spell;
}

static void RemovePhase11ArngeirDialogue(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    AuthorReport report)
{
    const string branchEdid = "PDV_DIAL_Phase11ArngeirKyneRecognitionBranch";
    const string topicEdid = "PDV_DIAL_Phase11ArngeirKyneRecognitionTopic";
    const string infoEdid = "PDV_INFO_Phase11ArngeirKyneRecognition";

    if (index.TryGetValue(topicEdid, out var topicRecord) && topicRecord is DialogTopic topic)
    {
        var removedInfos = topic.Responses.RemoveAll(response =>
            string.Equals(response.EditorID, infoEdid, StringComparison.OrdinalIgnoreCase));
        if (removedInfos > 0)
        {
            report.Actions.Add($"Removed {infoEdid} from {topicEdid}.");
        }

        mod.DialogTopics.Remove(topic);
        report.Actions.Add($"Removed {topicEdid}.");
    }

    if (index.TryGetValue(branchEdid, out var branchRecord) && branchRecord is DialogBranch branch)
    {
        mod.DialogBranches.Remove(branch);
        report.Actions.Add($"Removed {branchEdid}.");
    }

    if (report.Actions.Count == 0)
    {
        report.Warnings.Add("No Phase 11 Arngeir dialogue records were present to remove.");
    }
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

static void UpsertActivatorStringProperty(SkyrimActivator activator, string scriptName, string propertyName, string propertyValue)
{
    activator.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    activator.VirtualMachineAdapter.Version = 5;
    activator.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(activator.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, new ScriptProperty[] { StringProp(propertyName, propertyValue) });
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
    var script = scripts.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(p => string.Equals(p.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
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
            .Where(k => k.ModKey.Equals(modKey))
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
    public List<string> Warnings { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
