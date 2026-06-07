using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase20KhajiitImplementationCosting.manifest.json";
const string managerRecord = "PDV__ManagerQuest";
const string proofActivatorModel = @"Architecture\HighHrothgar\MQEtchedShrineActivator.nif";

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkPlacements = args.Contains("--check-placements");
var authorRewards = args.Contains("--author-rewards");
var fixBaanDar = args.Contains("--fix-baandar");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);
var rewardsSpecPath = Path.GetFullPath(GetArg(args, "--rewards-spec") ?? @"references\authoring\PDV_KhajiitRewardRecords.spec.json");

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

    if (authorRewards)
    {
        AuthorRewards(espPath, rewardsSpecPath, dryRun, report);
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
        return report.Status == "PASS" ? 0 : 1;
    }

    if (fixBaanDar)
    {
        FixBaanDarStartup(espPath, dryRun, report);
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
        return report.Status == "PASS" ? 0 : 1;
    }

    if (!File.Exists(manifestPath))
    {
        throw new FileNotFoundException("Khajiit implementation manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    var triggerDefinitions = BuildTriggerDefinitions(manifest);
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (checkPlacements)
    {
        CheckTriggerPlacements(index, triggerDefinitions, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Khajiit placement check failed.");
        }

        report.Status = "PASS";
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
        var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");
        var focusGlobal = RequireRecord<Global>(index, "PDV_GLO_KhajiitFocusedEmphasis");
        var lunarSubstrate = RequireRecord<Quest>(index, "PDV_Substrate_KhajiitLunar");
        var eventBus = RequireRecord<Quest>(index, "PDV_EventBus");
        var playerRef = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x14);

        foreach (var trigger in triggerDefinitions)
        {
            if (!createMissing && !index.ContainsKey(trigger.EditorId))
            {
                throw new InvalidOperationException($"Required trigger shell is missing: {trigger.EditorId}");
            }

            EnsureSignalActivator(mod, index, allocator, trigger, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey, report);
        }

        var manager = RequireRecord<Quest>(index, managerRecord);
        WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
        {
            ObjectProp("PDV_KhajiitLunarSubstrate", lunarSubstrate.FormKey),
            ObjectProp("PDV_GLO_KhajiitFocusedEmphasis", focusGlobal.FormKey),
        });
        report.Actions.Add("Verified and rewired Khajiit substrate/focus properties on PDV__ManagerQuest.");

        WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-khajiit");
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

static KhajiitManifest LoadManifest(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<KhajiitManifest>(File.ReadAllText(manifestPath));
    if (parsed is null)
    {
        throw new InvalidOperationException("Khajiit implementation manifest could not be parsed.");
    }

    return parsed;
}

static TriggerDefinition[] BuildTriggerDefinitions(KhajiitManifest manifest)
{
    var definitions = new List<TriggerDefinition>();
    foreach (var trigger in manifest.triggerSurfaces ?? [])
    {
        if (!string.Equals(trigger.recordStatus, "source-scaffolded", StringComparison.OrdinalIgnoreCase)
            && !string.Equals(trigger.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (!string.Equals(trigger.recordType, "ACTI", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Khajiit trigger surface {trigger.id ?? "(unknown)"} must be an ACTI record.");
        }

        if (string.IsNullOrWhiteSpace(trigger.editorId)
            || trigger.routeId <= 0
            || trigger.requiredOriginRace != 6
            || string.IsNullOrWhiteSpace(trigger.name)
            || string.IsNullOrWhiteSpace(trigger.activateText)
            || string.IsNullOrWhiteSpace(trigger.signalSourceId))
        {
            throw new InvalidOperationException($"Khajiit trigger surface metadata is incomplete for {trigger.id ?? "(unknown)"}.");
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

    if (definitions.Count == 0)
    {
        throw new InvalidOperationException("Khajiit implementation manifest has no source-scaffolded or record-wired trigger surfaces.");
    }

    return definitions.ToArray();
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
        activator = new SkyrimActivator(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Activators.Add(activator);
        index[trigger.EditorId] = activator;
        report.Actions.Add($"Created trigger activator {trigger.EditorId}.");
    }

    activator.FormVersion = 44;
    activator.EditorID = trigger.EditorId;
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

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
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

// =======================================================================
// REWARD / SUBSTRATE / NEGLECT RECORD AUTHORING (--author-rewards)
// =======================================================================

static void FixBaanDarStartup(string espPath, bool dryRun, AuthorReport report)
{
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var baanDar = RequireRecord<Quest>(index, "PDV_Deity_BaanDar");
    var template = RequireRecord<Quest>(index, "PDV_Deity_Kyne");
    baanDar.Flags = template.Flags;
    baanDar.Priority = template.Priority;
    report.Actions.Add($"Set PDV_Deity_BaanDar Flags={(int)template.Flags} Priority={template.Priority} (matched PDV_Deity_Kyne). Run pdv_refresh_seq after.");

    // Shared-deity reconciliation: Baan Dar is native to Khajiit too (Stance_Khajiit=NATIVE=0),
    // and its Bosmer-path eligibility gate must only apply to Bosmer (EligibleStateTrackOriginRace=4),
    // so the Khajiit emphasis is not foreign-penalized or inactive-path-quartered.
    WireQuestScript(baanDar, "PDV_Deity_BaanDar", new ScriptProperty[]
    {
        IntProp("Stance_Khajiit", 0),
        IntProp("EligibleStateTrackOriginRace", 4),
    });
    report.Actions.Add("Set PDV_Deity_BaanDar Stance_Khajiit=NATIVE(0) and EligibleStateTrackOriginRace=Bosmer(4).");

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-baandar-sge");
}

static void AuthorRewards(string espPath, string specPath, bool dryRun, AuthorReport report)
{
    if (!File.Exists(specPath))
    {
        throw new FileNotFoundException("Khajiit rewards spec not found.", specPath);
    }

    var spec = JsonSerializer.Deserialize<RewardsSpec>(File.ReadAllText(specPath), new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
        ?? throw new InvalidOperationException("Khajiit rewards spec did not parse.");

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var lunarSubstrate = RequireRecord<Quest>(index, "PDV_Substrate_KhajiitLunar");
    var allDeities = RequireRecord<FormList>(index, "PDV_FLST_AllDeities");
    var deityTemplate = RequireRecord<Quest>(index, "PDV_Deity_Kyne");

    var deityIndexMap = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
    {
        ["PDV_Deity_Azura"] = 40,
        ["PDV_Deity_Khenarthi"] = 41,
        ["PDV_Deity_Rajhin"] = 42,
        ["PDV_Deity_Alkosh"] = 43,
    };

    var managerProps = new List<ScriptProperty>();

    // 1) Deity quests + FormList membership + manager deity properties.
    var questByEditorId = new Dictionary<string, Quest>(StringComparer.OrdinalIgnoreCase);
    foreach (var dq in spec.deityQuests ?? new())
    {
        var deityIndex = deityIndexMap.TryGetValue(dq.editorId!, out var mapped) ? mapped : 40;
        var quest = EnsureDeityQuest(mod, index, allocator, dq, deityTemplate, originGlobal.FormKey, debugGlobal.FormKey, deityIndex, report);
        questByEditorId[dq.editorId!] = quest;
        if (!allDeities.Items.Any(item => item.FormKey.Equals(quest.FormKey)))
        {
            allDeities.Items.Add(quest.FormKey.ToLink<ISkyrimMajorRecordGetter>());
            report.Actions.Add($"Added {dq.editorId} to PDV_FLST_AllDeities.");
        }
    }
    foreach (var mp in spec.managerDeityProperties ?? new())
    {
        if (questByEditorId.TryGetValue(mp.record!, out var quest))
        {
            managerProps.Add(ObjectProp(mp.property!, quest.FormKey));
        }
    }

    // 2) Substrate boon slots (broad lunar reward layer) wired onto the substrate quest.
    var substrateProps = new List<ScriptProperty>();
    if (spec.substrateBoons?.slots is { } slots)
    {
        foreach (var slot in slots)
        {
            var spell = BuildSpell(mod, index, allocator, slot.spellEditorId!, slot.displayName!, slot.playerFacingText!, slot.effects ?? new(), report);
            substrateProps.Add(ObjectProp(slot.slotProperty!, spell.FormKey));
        }
        WireQuestScript(lunarSubstrate, "PDV_Substrate_KhajiitLunar", substrateProps);
    }

    // 3) Neglect spell (manager-owned).
    if (spec.neglect is { } neglect)
    {
        var neglectSpell = BuildSpell(mod, index, allocator, neglect.spellEditorId!, neglect.displayName!, neglect.playerFacingText!, neglect.effects ?? new(), report);
        managerProps.Add(ObjectProp(neglect.spellProperty ?? "PDV_SPEL_Neglect_KhajiitLunar", neglectSpell.FormKey));
    }

    // 4) Per-emphasis 3-tier reward spells (manager-owned, gated on emphasis-deity piety tier).
    foreach (var reward in spec.emphasisRewards ?? new())
    {
        var spell = BuildSpell(mod, index, allocator, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), report);
        managerProps.Add(ObjectProp(reward.spellEditorId!, spell.FormKey));
    }

    WireQuestScript(manager, "PDV__ManagerQuest", managerProps);
    report.Actions.Add($"Wired {managerProps.Count} Khajiit deity/reward/neglect properties on PDV__ManagerQuest.");

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-khajiit-rewards");
}

static Quest EnsureDeityQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardsSpecDeityQuest dq,
    Quest template,
    FormKey originGlobal,
    FormKey debugGlobal,
    int deityIndex,
    AuthorReport report)
{
    Quest quest;
    if (index.TryGetValue(dq.editorId!, out var existing))
    {
        if (existing is not Quest typed)
        {
            throw new InvalidOperationException($"{dq.editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }
        quest = typed;
    }
    else
    {
        quest = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Quests.Add(quest);
        index[dq.editorId!] = quest;
        report.Actions.Add($"Created deity quest {dq.editorId} (DeityIndex {deityIndex}).");
    }

    quest.EditorID = dq.editorId;
    quest.FormVersion = 44;
    quest.Flags = template.Flags;
    quest.Priority = template.Priority;
    quest.Name = Tx(dq.editorId!);
    WireQuestScript(quest, dq.script!, new ScriptProperty[]
    {
        StringProp("DeityName", dq.deityName!),
        IntProp("DeityIndex", deityIndex),
        IntProp("Stance_Khajiit", 0),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
    });
    return quest;
}

static Spell BuildSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string spellEditorId,
    string displayName,
    string playerFacingText,
    List<RewardsSpecEffect> effects,
    AuthorReport report)
{
    if (playerFacingText.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{spellEditorId} player-facing text must be ASCII-safe.");
    }

    var built = new List<(RewardsSpecEffect Effect, MagicEffect Record)>();
    foreach (var effect in effects)
    {
        var mgefId = string.IsNullOrWhiteSpace(effect.magicEffectEditorId)
            ? GenerateMgefId(spellEditorId, effect.actorValue!)
            : effect.magicEffectEditorId!;
        var record = EnsureMgef(mod, index, allocator, mgefId, displayName, playerFacingText, effect, report);
        built.Add((effect, record));
    }

    Spell spell;
    if (index.TryGetValue(spellEditorId, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{spellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }
        spell = typed;
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[spellEditorId] = spell;
        report.Actions.Add($"Created spell {spellEditorId}.");
    }

    spell.EditorID = spellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(displayName);
    spell.Description = Tx(playerFacingText);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();
    foreach (var (effect, record) in built)
    {
        var spellEffect = new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = effect.magnitude, Area = 0, Duration = 0 },
            Conditions = []
        };
        if (effect.nightOnly)
        {
            AddNightConditions(spellEffect);
        }
        spell.Effects.Add(spellEffect);
    }
    return spell;
}

static MagicEffect EnsureMgef(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string mgefEditorId,
    string displayName,
    string description,
    RewardsSpecEffect effect,
    AuthorReport report)
{
    MagicEffect record;
    if (index.TryGetValue(mgefEditorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{mgefEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        record = typed;
    }
    else
    {
        record = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(record);
        index[mgefEditorId] = record;
        report.Actions.Add($"Created magic effect {mgefEditorId}.");
    }

    record.EditorID = mgefEditorId;
    record.FormVersion = 44;
    record.Name = Tx(displayName);
    record.Description = Tx(description);
    record.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    record.BaseCost = 0.0f;
    record.MagicSkill = ActorValue.None;
    record.ResistValue = ActorValue.None;
    record.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(effect.actorValue!)
    };
    record.CastType = CastType.ConstantEffect;
    record.TargetType = TargetType.Self;
    record.SkillUsageMultiplier = 0.0f;
    record.ScriptEffectAIScore = 0.0f;
    record.ScriptEffectAIDelayTime = 0.0f;
    return record;
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

static string GenerateMgefId(string spellEditorId, string actorValue)
{
    var stem = spellEditorId.StartsWith("PDV_Bless", StringComparison.OrdinalIgnoreCase)
        ? "PDV_MGEF" + spellEditorId.Substring("PDV_Bless".Length)
        : spellEditorId + "_MGEF";
    return $"{stem}_{actorValue}";
}

static ActorValue ParseActorValue(string actorValue)
{
    if (Enum.TryParse<ActorValue>(actorValue, ignoreCase: true, out var parsed))
    {
        return parsed;
    }
    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
}

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

sealed class KhajiitManifest
{
    public string? id { get; set; }
    public string? implementationStatus { get; set; }
    public List<ManifestTriggerSurface>? triggerSurfaces { get; set; }
}

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

sealed class RewardsSpec
{
    public List<RewardsSpecDeityQuest>? deityQuests { get; set; }
    public List<RewardsSpecManagerProp>? managerDeityProperties { get; set; }
    public RewardsSpecSubstrate? substrateBoons { get; set; }
    public RewardsSpecReward? neglect { get; set; }
    public List<RewardsSpecReward>? emphasisRewards { get; set; }
}

sealed class RewardsSpecDeityQuest
{
    public string? editorId { get; set; }
    public string? script { get; set; }
    public string? deityName { get; set; }
}

sealed class RewardsSpecManagerProp
{
    public string? property { get; set; }
    public string? record { get; set; }
}

sealed class RewardsSpecSubstrate
{
    public string? wireTo { get; set; }
    public List<RewardsSpecSlot>? slots { get; set; }
}

sealed class RewardsSpecSlot
{
    public string? slotProperty { get; set; }
    public string? spellEditorId { get; set; }
    public string? displayName { get; set; }
    public List<RewardsSpecEffect>? effects { get; set; }
    public string? playerFacingText { get; set; }
}

sealed class RewardsSpecReward
{
    public string? emphasis { get; set; }
    public string? tier { get; set; }
    public string? spellEditorId { get; set; }
    public string? spellProperty { get; set; }
    public string? displayName { get; set; }
    public List<RewardsSpecEffect>? effects { get; set; }
    public string? playerFacingText { get; set; }
}

sealed class RewardsSpecEffect
{
    public string? magicEffectEditorId { get; set; }
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public bool nightOnly { get; set; }
}
