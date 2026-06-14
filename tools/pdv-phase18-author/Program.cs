using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultManifest = @"references\authoring\PDV_Phase18StatusNord.manifest.json";

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
        throw new FileNotFoundException("Phase 18 manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var managerQuest = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var debugGlobal = RequireRecord<ISkyrimMajorRecordGetter>(index, "PDV_GLO_DebugLevel");

    var effect = createMissing
        ? EnsureMagicEffect(mod, index, allocator, manifest.survey!, report)
        : RequireRecord<MagicEffect>(index, manifest.survey!.magicEffect!);
    var spell = createMissing
        ? EnsureSpell(mod, index, allocator, manifest.survey!, report)
        : RequireRecord<Spell>(index, manifest.survey!.spell!);

    ConfigureSurveyEffect(effect, manifest.survey!, managerQuest.FormKey, debugGlobal.FormKey);
    ConfigureSurveySpell(spell, manifest.survey!, effect);
    report.Actions.Add($"Filled {manifest.survey!.magicEffect} and {manifest.survey!.spell}.");

    var managerProperties = new List<ScriptProperty> { ObjectProp("PDV_SPEL_SurveyDevotion", spell.FormKey) };
    foreach (var message in manifest.messages!)
    {
        var record = createMissing
            ? EnsureMessage(mod, index, allocator, message, report)
            : RequireRecord<Message>(index, message.editorId!);
        ConfigureMessage(record, message);
        managerProperties.Add(ObjectProp(message.editorId!, record.FormKey));
        report.Actions.Add($"Filled message {message.editorId}.");
    }

    WireQuestScript(managerQuest, "PDV__ManagerQuest", managerProperties);
    report.Actions.Add("Wired Phase 18 manager properties.");

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase18");
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

static Phase18Manifest LoadManifest(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<Phase18Manifest>(File.ReadAllText(manifestPath));
    if (parsed?.survey is null
        || string.IsNullOrWhiteSpace(parsed.survey.spell)
        || string.IsNullOrWhiteSpace(parsed.survey.magicEffect)
        || string.IsNullOrWhiteSpace(parsed.survey.script)
        || parsed.messages is null
        || parsed.messages.Count == 0)
    {
        throw new InvalidOperationException("Phase 18 manifest is missing survey or message metadata.");
    }

    return parsed;
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
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }

    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} is {record.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    SurveyDefinition survey,
    AuthorReport report)
{
    if (index.TryGetValue(survey.magicEffect!, out var existing))
    {
        if (existing is not MagicEffect effect)
        {
            throw new InvalidOperationException($"{survey.magicEffect} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        return effect;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.MagicEffects.Add(created);
    index[survey.magicEffect!] = created;
    report.Actions.Add($"Created magic effect {survey.magicEffect}.");
    return created;
}

static Spell EnsureSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    SurveyDefinition survey,
    AuthorReport report)
{
    if (index.TryGetValue(survey.spell!, out var existing))
    {
        if (existing is not Spell spell)
        {
            throw new InvalidOperationException($"{survey.spell} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return spell;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[survey.spell!] = created;
    report.Actions.Add($"Created spell {survey.spell}.");
    return created;
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    MessageDefinition message,
    AuthorReport report)
{
    if (index.TryGetValue(message.editorId!, out var existing))
    {
        if (existing is not Message record)
        {
            throw new InvalidOperationException($"{message.editorId} already exists as {existing.GetType().Name}, expected Message.");
        }

        return record;
    }

    var created = new Message(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Messages.Add(created);
    index[message.editorId!] = created;
    report.Actions.Add($"Created message {message.editorId}.");
    return created;
}

static void ConfigureSurveyEffect(MagicEffect effect, SurveyDefinition survey, FormKey managerQuest, FormKey debugGlobal)
{
    effect.EditorID = survey.magicEffect;
    effect.FormVersion = 44;
    effect.Name = Tx(survey.name!);
    effect.Description = Tx(survey.description!);
    effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    effect.CastType = CastType.FireAndForget;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;

    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, survey.script!);
    UpsertProperties(script, new ScriptProperty[]
    {
        ObjectProp("PDV_Manager", managerQuest),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal)
    });
}

static void ConfigureSurveySpell(Spell spell, SurveyDefinition survey, MagicEffect effect)
{
    spell.EditorID = survey.spell;
    spell.FormVersion = 44;
    spell.Name = Tx(survey.name!);
    spell.Description = Tx(survey.description!);
    spell.BaseCost = 0;
    spell.Type = SpellType.LesserPower;
    spell.CastType = CastType.FireAndForget;
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

static void ConfigureMessage(Message record, MessageDefinition message)
{
    record.EditorID = message.editorId;
    record.FormVersion = 44;
    record.Flags = Message.Flag.MessageBox;
    record.Name = Tx(message.title!);
    record.Description = Tx(message.body!);
    record.MenuButtons.Clear();
    foreach (var button in message.buttons ?? ["OK"])
    {
        record.MenuButtons.Add(new MessageButton { Text = Tx(button) });
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

sealed class Phase18Manifest
{
    public SurveyDefinition? survey { get; set; }
    public List<MessageDefinition>? messages { get; set; }
}

sealed class SurveyDefinition
{
    public string? spell { get; set; }
    public string? magicEffect { get; set; }
    public string? script { get; set; }
    public string? name { get; set; }
    public string? description { get; set; }
}

sealed class MessageDefinition
{
    public string? editorId { get; set; }
    public string? title { get; set; }
    public string? body { get; set; }
    public List<string>? buttons { get; set; }
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
