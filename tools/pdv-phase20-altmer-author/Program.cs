using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase20AltmerImplementationCosting.manifest.json";
const string altmerCrisisTrack = "PDV_State_AltmerCrisis";
const string managerRecord = "PDV__ManagerQuest";
const string proofActivatorModel = @"Architecture\HighHrothgar\MQEtchedShrineActivator.nif";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkPlacements = args.Contains("--check-placements");
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
        throw new FileNotFoundException("Altmer implementation manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    var stateLabels = GetStateLabels(manifest, altmerCrisisTrack);
    var favorDefinitions = BuildFavorDefinitions(manifest);
    var triggerDefinitions = BuildTriggerDefinitions(manifest);
    var curseMessageDefinitions = BuildCurseMessageDefinitions(manifest);
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (checkPlacements)
    {
        CheckTriggerPlacements(index, triggerDefinitions, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Altmer placement check failed.");
        }

        report.Status = "PASS";
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

        var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
        var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");
        var eventBus = RequireRecord<Quest>(index, "PDV_EventBus");
        var playerRef = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x14);
        var track = EnsureAltmerCrisisTrack(mod, index, allocator, debugGlobal, stateLabels, createMissing, report);

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

        foreach (var trigger in triggerDefinitions)
        {
            if (!createMissing && !index.ContainsKey(trigger.EditorId))
            {
                throw new InvalidOperationException($"Required trigger shell is missing: {trigger.EditorId}");
            }

            EnsureSignalActivator(mod, index, allocator, trigger, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey, report);
        }

        foreach (var messageDefinition in curseMessageDefinitions)
        {
            if (createMissing)
            {
                EnsureMessage(mod, index, allocator, messageDefinition, report);
            }
            else
            {
                RequireRecord<Message>(index, messageDefinition.EditorId);
            }
        }

        var manager = RequireRecord<Quest>(index, managerRecord);
        var managerProperties = new List<ScriptProperty>
        {
            ObjectProp("PDV_AltmerCrisisTrack", track.FormKey),
        };

        foreach (var favor in favorDefinitions)
        {
            var spell = RequireRecord<Spell>(index, favor.SpellEdid);
            managerProperties.Add(ObjectProp(favor.SpellEdid, spell.FormKey));
        }

        foreach (var messageDefinition in curseMessageDefinitions)
        {
            var message = RequireRecord<Message>(index, messageDefinition.EditorId);
            managerProperties.Add(ObjectProp(messageDefinition.EditorId, message.FormKey));
        }

        WireQuestScript(manager, "PDV__ManagerQuest", managerProperties);
        report.Actions.Add("Wired Altmer crisis and favor properties on PDV__ManagerQuest.");

        WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-altmer");
        report.Status = "PASS";
    }
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

static AltmerManifest LoadManifest(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<AltmerManifest>(File.ReadAllText(manifestPath));
    if (parsed is null)
    {
        throw new InvalidOperationException("Altmer implementation manifest could not be parsed.");
    }

    if (parsed.stateSurfaces is null || parsed.stateSurfaces.Count == 0)
    {
        throw new InvalidOperationException("Altmer implementation manifest has no state surfaces.");
    }

    return parsed;
}

static string[] GetStateLabels(AltmerManifest manifest, string editorId)
{
    var surface = manifest.stateSurfaces!.FirstOrDefault(candidate => string.Equals(candidate.editorId, editorId, StringComparison.OrdinalIgnoreCase));
    if (surface?.@enum is null)
    {
        throw new InvalidOperationException($"Altmer implementation manifest is missing {editorId} enum.");
    }

    var ordered = surface.@enum
        .OrderBy(entry => entry.value)
        .Select(entry => entry.name ?? throw new InvalidOperationException($"{editorId} has an enum entry without a name."))
        .ToArray();

    if (ordered.Length != 5 || ordered[0] != "None" || ordered[4] != "ScarredResolved")
    {
        throw new InvalidOperationException($"{editorId} enum does not match the locked Altmer crisis contract.");
    }

    return ordered;
}

static FavorDefinition[] BuildFavorDefinitions(AltmerManifest manifest)
{
    var definitions = new List<FavorDefinition>();
    foreach (var family in manifest.favorFamilies ?? [])
    {
        if (!string.Equals(family.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (string.IsNullOrWhiteSpace(family.magicEffect)
            || string.IsNullOrWhiteSpace(family.spell)
            || string.IsNullOrWhiteSpace(family.keyword)
            || string.IsNullOrWhiteSpace(family.name)
            || string.IsNullOrWhiteSpace(family.description))
        {
            throw new InvalidOperationException($"Altmer favor family metadata is incomplete for {family.id ?? "(unknown)"}.");
        }

        definitions.Add(new FavorDefinition(
            family.magicEffect,
            family.spell,
            family.keyword,
            family.name,
            family.description));
    }

    return definitions.ToArray();
}

static TriggerDefinition[] BuildTriggerDefinitions(AltmerManifest manifest)
{
    var definitions = new List<TriggerDefinition>();
    foreach (var trigger in manifest.triggerSurfaces ?? [])
    {
        if (!string.Equals(trigger.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (!string.Equals(trigger.recordType, "ACTI", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Altmer trigger surface {trigger.id ?? "(unknown)"} must be an ACTI record.");
        }

        if (string.IsNullOrWhiteSpace(trigger.editorId)
            || trigger.routeId <= 0
            || trigger.requiredOriginRace < 0
            || string.IsNullOrWhiteSpace(trigger.name)
            || string.IsNullOrWhiteSpace(trigger.activateText)
            || string.IsNullOrWhiteSpace(trigger.signalSourceId))
        {
            throw new InvalidOperationException($"Altmer trigger surface metadata is incomplete for {trigger.id ?? "(unknown)"}.");
        }

        definitions.Add(new TriggerDefinition(
            trigger.editorId,
            trigger.placementRefEditorId ?? "",
            trigger.routeId,
            trigger.requiredOriginRace,
            trigger.signalValue,
            trigger.signalSourceId,
            trigger.oncePerDayKey ?? "",
            trigger.name,
            trigger.activateText));
    }

    return definitions.ToArray();
}

static CurseMessageDefinition[] BuildCurseMessageDefinitions(AltmerManifest manifest)
{
    var definitions = new List<CurseMessageDefinition>();
    foreach (var rule in manifest.curseAndExileRules ?? [])
    {
        if (!string.Equals(rule.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (!string.Equals(rule.recordType, "MESG", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Altmer curse rule {rule.id ?? "(unknown)"} must be a MESG record.");
        }

        if (string.IsNullOrWhiteSpace(rule.row)
            || string.IsNullOrWhiteSpace(rule.title)
            || string.IsNullOrWhiteSpace(rule.body))
        {
            throw new InvalidOperationException($"Altmer curse rule metadata is incomplete for {rule.id ?? "(unknown)"}.");
        }

        definitions.Add(new CurseMessageDefinition(rule.row, rule.title, rule.body));
    }

    return definitions.ToArray();
}

static Quest EnsureAltmerCrisisTrack(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    Global debugGlobal,
    string[] stateLabels,
    bool createMissing,
    AuthorReport report)
{
    Quest track;
    if (index.TryGetValue(altmerCrisisTrack, out var existing))
    {
        if (existing is not Quest existingQuest)
        {
            throw new InvalidOperationException($"{altmerCrisisTrack} already exists as {existing.GetType().Name}, expected Quest.");
        }

        track = existingQuest;
    }
    else
    {
        if (!createMissing)
        {
            throw new InvalidOperationException($"Required shell is missing: {altmerCrisisTrack}");
        }

        track = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Quests.Add(track);
        index[altmerCrisisTrack] = track;
        report.Actions.Add($"Created quest {altmerCrisisTrack}.");
    }

    ConfigureQuestShell(track, altmerCrisisTrack);
    WireQuestScript(track, "PDV_StateTrack", new ScriptProperty[]
    {
        StringProp("TrackName", "AltmerCrisis"),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
        StringListProp("StateLabels", stateLabels),
    });
    report.Actions.Add("Ensured PDV_State_AltmerCrisis is wired to PDV_StateTrack.");
    return track;
}

static SkyrimActivator EnsureSignalActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    TriggerDefinition trigger,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal,
    AuthorReport report)
{
    SkyrimActivator activator;
    if (index.TryGetValue(trigger.EditorId, out var existing))
    {
        if (existing is not SkyrimActivator typed)
        {
            throw new InvalidOperationException($"{trigger.EditorId} already exists as {existing.GetType().Name}, expected Activator.");
        }

        activator = typed;
        activator.EditorID = trigger.EditorId;
    }
    else
    {
        activator = new SkyrimActivator(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = trigger.EditorId,
            FormVersion = 44,
            Name = Tx(trigger.Name),
            ActivateTextOverride = Tx(trigger.ActivateText)
        };
        mod.Activators.Add(activator);
        index[trigger.EditorId] = activator;
        report.Actions.Add($"Created trigger activator {trigger.EditorId}.");
    }

    activator.FormVersion = 44;
    activator.Name = Tx(trigger.Name);
    activator.ActivateTextOverride = Tx(trigger.ActivateText);
    activator.Model ??= new Model();
    activator.Model.File = proofActivatorModel;
    WireActivatorScript(activator, "PDV_EventSignalActivator", new ScriptProperty[]
    {
        ObjectProp("PDV_EventBusService", eventBus),
        ObjectProp("PlayerREF", playerRef),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
        IntProp("RouteId", trigger.RouteId),
        IntProp("RequiredOriginRace", trigger.RequiredOriginRace),
        IntProp("SignalValue", trigger.SignalValue),
        StringProp("SignalSourceId", trigger.SignalSourceId),
        StringProp("TraceLabel", trigger.EditorId),
        StringProp("OncePerDayKey", trigger.OncePerDayKey),
    });
    report.Actions.Add($"Ensured trigger activator {trigger.EditorId} route {trigger.RouteId}.");
    return activator;
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    CurseMessageDefinition definition,
    AuthorReport report)
{
    Message message;
    if (index.TryGetValue(definition.EditorId, out var existing))
    {
        if (existing is not Message typed)
        {
            throw new InvalidOperationException($"{definition.EditorId} already exists as {existing.GetType().Name}, expected Message.");
        }

        message = typed;
    }
    else
    {
        message = new Message(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = definition.EditorId,
            FormVersion = 44
        };
        mod.Messages.Add(message);
        index[definition.EditorId] = message;
        report.Actions.Add($"Created message {definition.EditorId}.");
    }

    message.EditorID = definition.EditorId;
    message.FormVersion = 44;
    message.Name = Tx(definition.Title);
    message.Description = Tx(definition.Body);
    message.Flags = Message.Flag.MessageBox;
    message.MenuButtons.Clear();
    message.MenuButtons.Add(new MessageButton { Text = Tx("Continue") });
    report.Actions.Add($"Ensured message {definition.EditorId}.");
    return message;
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

static void CheckTriggerPlacements(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<TriggerDefinition> triggers,
    AuthorReport report)
{
    foreach (var trigger in triggers)
    {
        if (string.IsNullOrWhiteSpace(trigger.PlacementRefEditorId))
        {
            report.Errors.Add($"{trigger.EditorId} is missing placementRefEditorId in the manifest.");
            continue;
        }

        if (!index.TryGetValue(trigger.PlacementRefEditorId, out var refRecord))
        {
            report.Errors.Add($"Missing placed reference: {trigger.PlacementRefEditorId}");
            continue;
        }

        if (refRecord is not PlacedObject placed)
        {
            report.Errors.Add($"{trigger.PlacementRefEditorId} is {refRecord.GetType().Name}, expected PlacedObject/REFR.");
            continue;
        }

        if (!index.TryGetValue(trigger.EditorId, out var baseRecord))
        {
            report.Errors.Add($"Missing base activator for {trigger.PlacementRefEditorId}: {trigger.EditorId}");
            continue;
        }

        if (placed.Base.FormKey != baseRecord.FormKey)
        {
            report.Errors.Add($"{trigger.PlacementRefEditorId} points at {placed.Base.FormKey}, expected {trigger.EditorId} ({baseRecord.FormKey}).");
            continue;
        }

        report.Actions.Add($"{trigger.PlacementRefEditorId} -> {trigger.EditorId}");
    }
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

static void WireActivatorScript(SkyrimActivator activator, string scriptName, IEnumerable<ScriptProperty> properties)
{
    activator.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    activator.VirtualMachineAdapter.Version = 5;
    activator.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(activator.VirtualMachineAdapter.Scripts, scriptName);
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

static ScriptIntProperty IntProp(string name, int value)
{
    return new ScriptIntProperty
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

sealed class AltmerManifest
{
    public string? id { get; set; }
    public string? implementationStatus { get; set; }
    public List<StateSurface>? stateSurfaces { get; set; }
    public List<ManifestFavorFamily>? favorFamilies { get; set; }
    public List<ManifestTriggerSurface>? triggerSurfaces { get; set; }
    public List<ManifestCurseRule>? curseAndExileRules { get; set; }
}

sealed class StateSurface
{
    public string? editorId { get; set; }
    public List<StateEnumEntry>? @enum { get; set; }
}

sealed class StateEnumEntry
{
    public string? name { get; set; }
    public int value { get; set; }
}

sealed record FavorDefinition(
    string MagicEffectEdid,
    string SpellEdid,
    string KeywordEdid,
    string Name,
    string Description);

sealed record TriggerDefinition(
    string EditorId,
    string PlacementRefEditorId,
    int RouteId,
    int RequiredOriginRace,
    int SignalValue,
    string SignalSourceId,
    string OncePerDayKey,
    string Name,
    string ActivateText);

sealed record CurseMessageDefinition(
    string EditorId,
    string Title,
    string Body);

sealed class ManifestFavorFamily
{
    public string? id { get; set; }
    public string? recordStatus { get; set; }
    public string? keyword { get; set; }
    public string? magicEffect { get; set; }
    public string? spell { get; set; }
    public string? name { get; set; }
    public string? description { get; set; }
}

sealed class ManifestTriggerSurface
{
    public string? id { get; set; }
    public string? recordStatus { get; set; }
    public string? recordType { get; set; }
    public string? editorId { get; set; }
    public string? placementRefEditorId { get; set; }
    public int routeId { get; set; }
    public int requiredOriginRace { get; set; }
    public int signalValue { get; set; }
    public string? signalSourceId { get; set; }
    public string? oncePerDayKey { get; set; }
    public string? name { get; set; }
    public string? activateText { get; set; }
}

sealed class ManifestCurseRule
{
    public string? id { get; set; }
    public string? row { get; set; }
    public string? recordStatus { get; set; }
    public string? recordType { get; set; }
    public string? title { get; set; }
    public string? body { get; set; }
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
