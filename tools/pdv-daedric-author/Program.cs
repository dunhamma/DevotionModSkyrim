using System.Reflection;
using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;
using SkyrimGlobal = Mutagen.Bethesda.Skyrim.Global;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultManifest = @"references\authoring\PDV_DaedricPrinceRecordContracts.json";
const string baseScript = "PDV_DaedricPathBase";
const string templateQuest = "PDV_DaedricPath_Hircine";
const string proofActivatorModel = @"Architecture\HighHrothgar\MQEtchedShrineActivator.nif";
const string qasmokeEditorId = "QASmoke";
var qasmokeFormKey = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x032AE7);
var qasmokeTemplatePluginCandidates = new[]
{
    @"D:\Wabbajack\modlists\Anvil\mods\Anvil - Synthesis Output\ANV_SynW4ENBPatcher.esp",
    @"D:\Wabbajack\modlists\Anvil\mods\Lux - Water for ENB patch\Lux - Water for ENB patch.esp",
    @"D:\Wabbajack\modlists\Anvil\mods\Water for ENB (Shades of Skyrim)\Water for ENB (Shades of Skyrim).esp",
    @"D:\Wabbajack\modlists\Anvil\Stock Game\Data\Skyrim.esm",
};
var skyrimModKey = ModKey.FromNameAndExtension("Skyrim.esm");
var daedricLiveQuestSources = new[]
{
    new DaedricLiveQuestSource("Azura", "PDV_FLST_Daedric_AzuraLiveSources", new FormKey(skyrimModKey, 0x028AD6), 100),
    new DaedricLiveQuestSource("Boethiah", "PDV_FLST_Daedric_BoethiahLiveSources", new FormKey(skyrimModKey, 0x04D8D6), 100),
    new DaedricLiveQuestSource("Vaermina", "PDV_FLST_Daedric_VaerminaLiveSources", new FormKey(skyrimModKey, 0x0242AF), 190),
    new DaedricLiveQuestSource("Meridia", "PDV_FLST_Daedric_MeridiaLiveSources", new FormKey(skyrimModKey, 0x04E4E1), 500),
    new DaedricLiveQuestSource("Molag", "PDV_FLST_Daedric_MolagLiveSources", new FormKey(skyrimModKey, 0x022F08), 200),
    new DaedricLiveQuestSource("Mephala", "PDV_FLST_Daedric_MephalaLiveSources", new FormKey(skyrimModKey, 0x04A37B), 60),
    new DaedricLiveQuestSource("Hircine", "PDV_FLST_Daedric_HircineLiveSources", new FormKey(skyrimModKey, 0x02A49A), 100),
    new DaedricLiveQuestSource("Malacath", "PDV_FLST_Daedric_MalacathLiveSources", new FormKey(skyrimModKey, 0x03B681), 200),
    new DaedricLiveQuestSource("Dagon", "PDV_FLST_Daedric_DagonLiveSources", new FormKey(skyrimModKey, 0x0240B8), 100),
    new DaedricLiveQuestSource("Sheo", "PDV_FLST_Daedric_SheoLiveSources", new FormKey(skyrimModKey, 0x02AC68), 200),
    new DaedricLiveQuestSource("Namira", "PDV_FLST_Daedric_NamiraLiveSources", new FormKey(skyrimModKey, 0x02C358), 100),
    new DaedricLiveQuestSource("Sanguine", "PDV_FLST_Daedric_SanguineLiveSources", new FormKey(skyrimModKey, 0x01BB9B), 200),
    new DaedricLiveQuestSource("Vile", "PDV_FLST_Daedric_VileLiveSources", new FormKey(skyrimModKey, 0x01BFC4), 200),
    new DaedricLiveQuestSource("Mora", "PDV_FLST_Daedric_MoraLiveSources", new FormKey(skyrimModKey, 0x02D512), 100),
    new DaedricLiveQuestSource("Nocturnal", "PDV_FLST_Daedric_NocturnalLiveSources", new FormKey(skyrimModKey, 0x021555), 200),
    new DaedricLiveQuestSource("Peryite", "PDV_FLST_Daedric_PeryiteLiveSources", new FormKey(skyrimModKey, 0x08998D), 100),
};

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkOnly = args.Contains("--check");
var checkMessagesOnly = args.Contains("--check-messages");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);
var princeFilter = GetArg(args, "--prince");

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    CheckOnly = checkOnly || checkMessagesOnly,
    Prince = princeFilter,
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
        throw new FileNotFoundException("Daedric contract manifest not found.", manifestPath);
    }

    var manifest = LoadManifest(manifestPath);
    ValidateManifest(manifest);
    var selected = SelectPrinces(manifest, princeFilter);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    if (checkMessagesOnly)
    {
        CheckMessageRecordsOnly(index, selected, report);
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
        return report.Status == "PASS" ? 0 : 1;
    }

    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var template = RequireRecord<Quest>(index, templateQuest);
    var debugGlobal = RequireRecord<SkyrimGlobal>(index, "PDV_GLO_DebugLevel");
    var originGlobal = RequireRecord<SkyrimGlobal>(index, "PDV_GLO_OriginRace");
    var operationalList = RequireRecord<FormList>(index, manifest.operationalFormList!);
    var devList = RequireRecord<FormList>(index, manifest.devFormList!);
    var managerQuest = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var eventBus = RequireRecord<Quest>(index, "PDV_EventBus");
    var playerRef = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x000014);
    var selectedLiveQuestSources = SelectDaedricLiveQuestSources(daedricLiveQuestSources, selected);

    var manifestOrderedQuestKeys = new List<FormKey>();
    foreach (var prince in selected)
    {
        var princeIndex = PrinceIndexFor(manifest, prince);
        var context = BuildPrinceContext(mod, index, allocator, prince, template, debugGlobal, originGlobal, createMissing, report);
        WirePrinceQuest(context, prince, report);
        manifestOrderedQuestKeys.Add(context.Quest.FormKey);
        if (!checkOnly)
        {
            EnsureDaedricProofActivator(mod, index, allocator, prince, princeIndex, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey, report);
        }
        CheckPrince(context, prince, report);
        CheckDaedricProofActivator(index, prince, princeIndex, report);
    }

    if (checkOnly)
    {
        CheckFormListOrder(operationalList, manifestOrderedQuestKeys, report, manifest.operationalFormList!);
        CheckFormListOrder(devList, manifestOrderedQuestKeys, report, manifest.devFormList!);
    }
    else
    {
        RebuildFormListInManifestOrder(operationalList, manifestOrderedQuestKeys, report, manifest.operationalFormList!);
        RebuildFormListInManifestOrder(devList, manifestOrderedQuestKeys, report, manifest.devFormList!);
        WireManagerDaedricList(managerQuest, operationalList, report);
        EnsureDaedricGenericProbeActivator(mod, index, allocator, eventBus.FormKey, playerRef, originGlobal.FormKey, debugGlobal.FormKey, report);
        EnsureDaedricLiveQuestSourceFormLists(mod, index, allocator, selectedLiveQuestSources, report);
        WirePlayerEventsDaedricLiveSourceProperties(index, selectedLiveQuestSources, report);
        var proofCell = EnsureQASmokeOverride(mod, index, report);
        EnsureDaedricProofReferences(proofCell, index, allocator, selected, report);
    }
    CheckManagerDaedricList(managerQuest, operationalList, report);
    CheckDaedricGenericProbeActivator(index, report);
    CheckDaedricLiveQuestSourceFormLists(index, selectedLiveQuestSources, report);
    CheckPlayerEventsDaedricLiveSourceProperties(index, selectedLiveQuestSources, report);
    CheckDaedricProofReferences(index, selected, report);

    if (!checkOnly)
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "daedric-princes");
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

static DaedricContract LoadManifest(string manifestPath)
{
    return JsonSerializer.Deserialize<DaedricContract>(File.ReadAllText(manifestPath), new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    }) ?? throw new InvalidOperationException("Daedric contract manifest did not parse.");
}

static void ValidateManifest(DaedricContract manifest)
{
    if (manifest.schema != "pdv.daedric-prince-record-contracts.v1")
    {
        throw new InvalidOperationException($"Unexpected Daedric contract schema {manifest.schema ?? "(missing)"}.");
    }

    if (string.IsNullOrWhiteSpace(manifest.operationalFormList)
        || string.IsNullOrWhiteSpace(manifest.devFormList)
        || manifest.princes is null
        || manifest.princes.Count != 16)
    {
        throw new InvalidOperationException("Daedric contract manifest must define both FormLists and exactly 16 Prince entries.");
    }

    foreach (var prince in manifest.princes)
    {
        if (string.IsNullOrWhiteSpace(prince.stem)
            || string.IsNullOrWhiteSpace(prince.displayName)
            || string.IsNullOrWhiteSpace(prince.questEditorId)
            || string.IsNullOrWhiteSpace(prince.scriptName)
            || string.IsNullOrWhiteSpace(prince.stigmaGlobalEditorId)
            || prince.boons is null
            || prince.boons.Count != 3
            || prince.prices is null
            || prince.prices.Count != 3
            || prince.messages is null
            || prince.stateByRace is null
            || prince.stateByRace.Count != 10
            || prince.stigmaModByRace is null
            || prince.stigmaModByRace.Count != 10
            || prince.exitDifficultyByRace is null
            || prince.exitDifficultyByRace.Count != 10)
        {
            throw new InvalidOperationException($"Daedric contract entry {prince.stem ?? "(missing)"} is incomplete.");
        }

        foreach (var spell in prince.boons.Concat(prince.prices))
        {
            if (string.IsNullOrWhiteSpace(spell.spellEditorId)
                || string.IsNullOrWhiteSpace(spell.magicEffectEditorId)
                || string.IsNullOrWhiteSpace(spell.displayName)
                || string.IsNullOrWhiteSpace(spell.playerFacingText)
                || string.IsNullOrWhiteSpace(spell.property)
                || spell.effects is null
                || spell.effects.Count == 0)
            {
                throw new InvalidOperationException($"{prince.stem} has an incomplete boon/price packet.");
            }

            if (spell.playerFacingText.Any(ch => ch > 127))
            {
                throw new InvalidOperationException($"{spell.spellEditorId} player-facing text must be ASCII-safe.");
            }

            foreach (var effect in spell.effects)
            {
                _ = ParseActorValue(effect.actorValue!);
            }
        }

        foreach (var message in prince.messages)
        {
            if (string.IsNullOrWhiteSpace(message.editorId)
                || string.IsNullOrWhiteSpace(message.body)
                || string.IsNullOrWhiteSpace(message.property))
            {
                throw new InvalidOperationException($"{prince.stem} has an incomplete message packet.");
            }

            if (message.body.Any(ch => ch > 127) || (message.title ?? "").Any(ch => ch > 127))
            {
                throw new InvalidOperationException($"{message.editorId} message text must be ASCII-safe.");
            }
        }
    }
}

static List<DaedricPrince> SelectPrinces(DaedricContract manifest, string? princeFilter)
{
    if (string.IsNullOrWhiteSpace(princeFilter))
    {
        return manifest.princes!;
    }

    var selected = manifest.princes!
        .Where(prince => string.Equals(prince.stem, princeFilter, StringComparison.OrdinalIgnoreCase)
            || string.Equals(prince.displayName, princeFilter, StringComparison.OrdinalIgnoreCase)
            || string.Equals(prince.questEditorId, princeFilter, StringComparison.OrdinalIgnoreCase))
        .ToList();

    if (selected.Count == 0)
    {
        throw new InvalidOperationException($"No Daedric Prince matches --prince {princeFilter}.");
    }

    return selected;
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

static PrinceContext BuildPrinceContext(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    DaedricPrince prince,
    Quest template,
    SkyrimGlobal debugGlobal,
    SkyrimGlobal originGlobal,
    bool createMissing,
    AuthorReport report)
{
    var quest = createMissing
        ? EnsureQuest(mod, index, allocator, prince.questEditorId!, template, prince.displayName!, report)
        : RequireRecord<Quest>(index, prince.questEditorId!);
    var stigmaGlobal = createMissing
        ? EnsureGlobal(mod, index, allocator, prince.stigmaGlobalEditorId!, report)
        : RequireRecord<SkyrimGlobal>(index, prince.stigmaGlobalEditorId!);

    var spells = new Dictionary<string, Spell>(StringComparer.OrdinalIgnoreCase);
    var messages = new Dictionary<string, Message>(StringComparer.OrdinalIgnoreCase);

    foreach (var spellDefinition in prince.boons!.Concat(prince.prices!))
    {
        var effects = new List<(DaedricSpellEffect Definition, MagicEffect Record)>();
        foreach (var effectDefinition in spellDefinition.effects!)
        {
            var effect = createMissing
                ? EnsureMagicEffect(mod, index, allocator, spellDefinition, effectDefinition, report)
                : RequireRecord<MagicEffect>(index, spellDefinition.magicEffectEditorId!);
            ConfigureMagicEffect(effect, spellDefinition, effectDefinition);
            effects.Add((effectDefinition, effect));
        }

        var spell = createMissing
            ? EnsureSpell(mod, index, allocator, spellDefinition, report)
            : RequireRecord<Spell>(index, spellDefinition.spellEditorId!);
        ConfigureSpell(spell, spellDefinition, effects);
        spells[spellDefinition.property!] = spell;
    }

    foreach (var messageDefinition in prince.messages!)
    {
        var message = createMissing
            ? EnsureMessage(mod, index, allocator, messageDefinition, report)
            : RequireRecord<Message>(index, messageDefinition.editorId!);
        ConfigureMessage(message, messageDefinition);
        messages[messageDefinition.property!] = message;
    }

    return new PrinceContext(quest, stigmaGlobal, debugGlobal, originGlobal, spells, messages);
}

static Quest EnsureQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    Quest template,
    string displayName,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest quest)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }

        ConfigureQuest(quest, template, editorId, displayName);
        return quest;
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureQuest(created, template, editorId, displayName);
    mod.Quests.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created quest {editorId}.");
    return created;
}

static void ConfigureQuest(Quest quest, Quest template, string editorId, string displayName)
{
    quest.EditorID = editorId;
    quest.FormVersion = 44;
    quest.QuestFormVersion = template.QuestFormVersion;
    quest.Flags = template.Flags;
    quest.Priority = template.Priority;
    quest.Type = template.Type;
    quest.Name = Tx(displayName);
}

static SkyrimGlobal EnsureGlobal(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimGlobal global)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Global.");
        }

        ConfigureGlobal(global, editorId);
        return global;
    }

    var created = new GlobalFloat(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureGlobal(created, editorId);
    mod.Globals.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created global {editorId}.");
    return created;
}

static void ConfigureGlobal(SkyrimGlobal global, string editorId)
{
    global.EditorID = editorId;
    global.FormVersion = 44;
    global.RawFloat = 0.0f;
}

static MagicEffect EnsureMagicEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    DaedricSpell spell,
    DaedricSpellEffect effectDefinition,
    AuthorReport report)
{
    if (index.TryGetValue(spell.magicEffectEditorId!, out var existing))
    {
        if (existing is not MagicEffect effect)
        {
            throw new InvalidOperationException($"{spell.magicEffectEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        return effect;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.MagicEffects.Add(created);
    index[spell.magicEffectEditorId!] = created;
    report.Actions.Add($"Created magic effect {spell.magicEffectEditorId}.");
    return created;
}

static void ConfigureMagicEffect(MagicEffect effect, DaedricSpell spell, DaedricSpellEffect effectDefinition)
{
    effect.EditorID = spell.magicEffectEditorId;
    effect.FormVersion = 44;
    effect.Name = Tx(spell.displayName!);
    effect.Description = Tx(spell.playerFacingText!);
    effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(effectDefinition.actorValue!)
    };
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
    DaedricSpell spellDefinition,
    AuthorReport report)
{
    if (index.TryGetValue(spellDefinition.spellEditorId!, out var existing))
    {
        if (existing is not Spell spell)
        {
            throw new InvalidOperationException($"{spellDefinition.spellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return spell;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Spells.Add(created);
    index[spellDefinition.spellEditorId!] = created;
    report.Actions.Add($"Created spell {spellDefinition.spellEditorId}.");
    return created;
}

static void ConfigureSpell(Spell spell, DaedricSpell spellDefinition, IReadOnlyList<(DaedricSpellEffect Definition, MagicEffect Record)> effects)
{
    spell.EditorID = spellDefinition.spellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(spellDefinition.displayName!);
    spell.Description = Tx(spellDefinition.playerFacingText!);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();

    foreach (var (definition, effect) in effects)
    {
        spell.Effects.Add(new Effect
        {
            BaseEffect = effect.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData
            {
                Magnitude = definition.magnitude,
                Area = definition.area,
                Duration = definition.duration
            },
            Conditions = []
        });
    }
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    DaedricMessage messageDefinition,
    AuthorReport report)
{
    if (index.TryGetValue(messageDefinition.editorId!, out var existing))
    {
        if (existing is not Message message)
        {
            throw new InvalidOperationException($"{messageDefinition.editorId} already exists as {existing.GetType().Name}, expected Message.");
        }

        return message;
    }

    var created = new Message(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Messages.Add(created);
    index[messageDefinition.editorId!] = created;
    report.Actions.Add($"Created message {messageDefinition.editorId}.");
    return created;
}

static void ConfigureMessage(Message message, DaedricMessage messageDefinition)
{
    message.EditorID = messageDefinition.editorId;
    message.FormVersion = 44;
    message.Name = Tx(messageDefinition.title ?? messageDefinition.editorId!);
    message.Description = Tx(messageDefinition.body!);
    message.Flags = messageDefinition.messageBox ? Message.Flag.MessageBox : 0;
    message.MenuButtons.Clear();
    var buttons = messageDefinition.buttons ?? new List<string>();
    if (buttons.Count == 0 && messageDefinition.messageBox)
    {
        buttons = new List<string> { "Continue" };
    }

    foreach (var button in buttons)
    {
        message.MenuButtons.Add(new MessageButton { Text = Tx(button) });
    }
}

static void WirePrinceQuest(PrinceContext context, DaedricPrince prince, AuthorReport report)
{
    var baseProps = new List<ScriptProperty>
    {
        StringProp("DeityName", prince.displayName!),
        StringProp("DeityDomain", prince.hookSource ?? "Daedric path"),
        IntProp("DeityIndex", 1000 + Math.Abs(StringComparer.OrdinalIgnoreCase.GetHashCode(prince.stem!) % 500)),
        ObjectProp("PDV_GLO_OriginRace", context.OriginGlobal.FormKey),
        ObjectProp("PDV_GLO_DebugLevel", context.DebugGlobal.FormKey),
        ObjectProp("StigmaGlobal", context.StigmaGlobal.FormKey),
        IntProp("CommitmentSignalsRequired", prince.commitmentSignalsRequired),
        IntListProp("StateByRace", prince.stateByRace!.ToArray()),
        FloatListProp("StigmaModByRace", prince.stigmaModByRace!.ToArray()),
        IntListProp("ExitDifficultyByRace", prince.exitDifficultyByRace!.ToArray()),
    };
    foreach (var propertyName in new[] { "Boon_Seeker", "Boon_Devoted", "Boon_Champion", "Price_Seeker", "Price_Devoted", "Price_Champion" })
    {
        baseProps.Add(ObjectProp(propertyName, context.Spells[propertyName].FormKey));
    }

    WireQuestScript(context.Quest, baseScript, baseProps);

    var concreteProps = new List<ScriptProperty>
    {
        FloatProp("ControlledSignalPietyDelta", 12.0f),
        FloatProp("ControlledSignalStigmaDelta", 1.0f),
    };
    foreach (var message in prince.messages!)
    {
        concreteProps.Add(ObjectProp(message.property!, context.Messages[message.property!].FormKey));
    }

    // `quest as PDV_DaedricPathBase` resolves to the MOST-DERIVED (concrete) script instance, not the
    // standalone base entry -- so the identity/boon/price/state properties must live on the concrete
    // entry too, or every cast-based read (DeityName, Price_Seeker, StateByRace, ...) comes back empty.
    concreteProps.AddRange(baseProps);

    WireQuestScript(context.Quest, prince.scriptName!, concreteProps);
    report.Actions.Add($"Wired {prince.questEditorId} VMAD scripts and properties.");
}

static void CheckPrince(PrinceContext context, DaedricPrince prince, AuthorReport report)
{
    var scripts = context.Quest.VirtualMachineAdapter?.Scripts;
    var baseEntry = scripts?.FirstOrDefault(script => string.Equals(script.Name, baseScript, StringComparison.OrdinalIgnoreCase));
    var concreteEntry = scripts?.FirstOrDefault(script => string.Equals(script.Name, prince.scriptName, StringComparison.OrdinalIgnoreCase));
    if (baseEntry is null)
    {
        report.Errors.Add($"{prince.questEditorId} is missing {baseScript} VMAD script.");
        return;
    }

    if (concreteEntry is null)
    {
        report.Errors.Add($"{prince.questEditorId} is missing {prince.scriptName} VMAD script.");
        return;
    }

    foreach (var propertyName in new[] { "Boon_Seeker", "Boon_Devoted", "Boon_Champion", "Price_Seeker", "Price_Devoted", "Price_Champion" })
    {
        CheckObjectProperty(baseEntry, propertyName, context.Spells[propertyName].FormKey, prince.questEditorId!, report);
    }
    CheckObjectProperty(baseEntry, "StigmaGlobal", context.StigmaGlobal.FormKey, prince.questEditorId!, report);
    CheckIntArrayProperty(baseEntry, "StateByRace", 10, prince.questEditorId!, report);
    CheckFloatArrayProperty(baseEntry, "StigmaModByRace", 10, prince.questEditorId!, report);
    CheckIntArrayProperty(baseEntry, "ExitDifficultyByRace", 10, prince.questEditorId!, report);

    foreach (var spell in prince.boons!.Concat(prince.prices!))
    {
        CheckSpellPacket(spell, context.Spells[spell.property!], report);
    }

    foreach (var message in prince.messages!)
    {
        CheckObjectProperty(concreteEntry, message.property!, context.Messages[message.property!].FormKey, prince.questEditorId!, report);
        var record = context.Messages[message.property!];
        if (!string.Equals(record.Description?.String, message.body, StringComparison.Ordinal))
        {
            report.Errors.Add($"{message.editorId} description does not match the Daedric contract.");
        }
        CheckMessageButtons(record, message, report);
    }

    report.Actions.Add($"Checked {prince.questEditorId}.");
}

static void CheckMessageButtons(Message record, DaedricMessage definition, AuthorReport report)
{
    var expectedButtons = definition.buttons ?? new List<string>();
    if (expectedButtons.Count == 0 && definition.messageBox)
    {
        expectedButtons = new List<string> { "Continue" };
    }

    if (record.MenuButtons.Count != expectedButtons.Count)
    {
        report.Errors.Add($"{definition.editorId} has {record.MenuButtons.Count} button(s), expected {expectedButtons.Count}.");
        return;
    }

    for (var i = 0; i < expectedButtons.Count; i++)
    {
        var actualText = record.MenuButtons[i].Text?.String ?? "";
        if (!string.Equals(actualText, expectedButtons[i], StringComparison.Ordinal))
        {
            report.Errors.Add($"{definition.editorId} button {i} is '{actualText}', expected '{expectedButtons[i]}'.");
        }
    }
}

static void CheckMessageRecordsOnly(Dictionary<string, ISkyrimMajorRecordGetter> index, IEnumerable<DaedricPrince> princes, AuthorReport report)
{
    foreach (var prince in princes)
    {
        foreach (var messageDefinition in prince.messages ?? [])
        {
            var record = RequireRecord<Message>(index, messageDefinition.editorId!);
            if (!string.Equals(record.Description?.String, messageDefinition.body, StringComparison.Ordinal))
            {
                report.Errors.Add($"{messageDefinition.editorId} description does not match the Daedric contract.");
            }
            CheckMessageButtons(record, messageDefinition, report);
            var labels = string.Join(" | ", record.MenuButtons.Select((button, slot) => $"{slot}:{button.Text?.String}"));
            report.Actions.Add($"{messageDefinition.editorId}: buttons [{labels}]");
        }
    }
}

static void CheckSpellPacket(DaedricSpell definition, Spell spell, AuthorReport report)
{
    if (!string.Equals(spell.Description?.String, definition.playerFacingText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{definition.spellEditorId} description does not match the Daedric contract.");
    }

    if (spell.Effects.Count != definition.effects!.Count)
    {
        report.Errors.Add($"{definition.spellEditorId} has {spell.Effects.Count} effect(s), expected {definition.effects.Count}.");
        return;
    }

    for (var i = 0; i < definition.effects.Count; i++)
    {
        var expected = definition.effects[i];
        var effect = spell.Effects[i];
        if (effect.Data?.Area != expected.area
            || effect.Data?.Duration != expected.duration
            || Math.Abs((effect.Data?.Magnitude ?? 0.0f) - expected.magnitude) > 0.001f)
        {
            report.Errors.Add($"{definition.spellEditorId} effect {i} magnitude/area/duration does not match the Daedric contract.");
        }
    }
}

static void WireManagerDaedricList(Quest managerQuest, FormList operationalList, AuthorReport report)
{
    WireQuestScript(managerQuest, "PDV__ManagerQuest", new[]
    {
        ObjectProp("PDV_FLST_DaedricPaths_All", operationalList.FormKey)
    });
    report.Actions.Add("Wired PDV__ManagerQuest.PDV_FLST_DaedricPaths_All.");
}

static void CheckManagerDaedricList(Quest managerQuest, FormList operationalList, AuthorReport report)
{
    var script = managerQuest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add("PDV__ManagerQuest is missing its manager VMAD script.");
        return;
    }

    CheckObjectProperty(script, "PDV_FLST_DaedricPaths_All", operationalList.FormKey, "PDV__ManagerQuest", report);
}

static int PrinceIndexFor(DaedricContract manifest, DaedricPrince prince)
{
    var index = manifest.princes!.FindIndex(candidate => string.Equals(candidate.stem, prince.stem, StringComparison.OrdinalIgnoreCase));
    if (index < 0)
    {
        throw new InvalidOperationException($"Could not resolve global Daedric FormList index for {prince.stem}.");
    }

    return index;
}

static void EnsureDaedricProofActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    DaedricPrince prince,
    int princeIndex,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal,
    AuthorReport report)
{
    var editorId = DaedricProofActivatorEditorId(prince);
    var name = DaedricProofActivatorName(prince);
    var sourceId = DaedricProofSourceId(prince);
    var oncePerDayKey = $"PDV.Signal.Daedric.{prince.stem}.QASmoke";
    EnsureSignalActivator(mod, index, allocator, editorId, name, "TEST DAEDRIC PATH", 200, -1, princeIndex, sourceId, oncePerDayKey, eventBus, playerRef, originGlobal, debugGlobal, report);
}

static void EnsureDaedricGenericProbeActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal,
    AuthorReport report)
{
    EnsureSignalActivator(mod, index, allocator, "PDV_ACTI_Daedric_GenericSilenceProbe", "PDV DAEDRIC GENERIC SILENCE", "TEST NO RESPONSE", 201, -1, 0, "generic", "PDV.Signal.Daedric.GenericProbe.QASmoke", eventBus, playerRef, originGlobal, debugGlobal, report);
}

static SkyrimActivator EnsureSignalActivator(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    string name,
    string activateText,
    int routeId,
    int requiredOriginRace,
    int signalValue,
    string signalSourceId,
    string oncePerDayKey,
    FormKey eventBus,
    FormKey playerRef,
    FormKey originGlobal,
    FormKey debugGlobal,
    AuthorReport report)
{
    SkyrimActivator activator;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimActivator typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Activator.");
        }

        activator = typed;
    }
    else
    {
        activator = new SkyrimActivator(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Activators.Add(activator);
        index[editorId] = activator;
        report.Actions.Add($"Created Daedric proof activator {editorId}.");
    }

    activator.FormVersion = 44;
    activator.EditorID = editorId;
    activator.Name = Tx(name);
    activator.ActivateTextOverride = Tx(activateText);
    activator.Model ??= new Model();
    activator.Model.File = proofActivatorModel;
    WireActivatorScript(activator, "PDV_EventSignalActivator", new ScriptProperty[]
    {
        ObjectProp("PDV_EventBusService", eventBus),
        ObjectProp("PlayerREF", playerRef),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
        IntProp("RouteId", routeId),
        IntProp("RequiredOriginRace", requiredOriginRace),
        IntProp("SignalValue", signalValue),
        StringProp("SignalSourceId", signalSourceId),
        StringProp("TraceLabel", editorId),
        StringProp("OncePerDayKey", oncePerDayKey),
    });
    report.Actions.Add($"Ensured Daedric proof activator {editorId} route {routeId}.");
    return activator;
}

Cell EnsureQASmokeOverride(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    AuthorReport report)
{
    foreach (var block in mod.Cells.Records)
    {
        foreach (var subBlock in block.SubBlocks)
        {
            foreach (var cell in subBlock.Cells)
            {
                if (cell.FormKey == qasmokeFormKey || string.Equals(cell.EditorID, qasmokeEditorId, StringComparison.OrdinalIgnoreCase))
                {
                    cell.EditorID = qasmokeEditorId;
                    index[qasmokeEditorId] = cell;
                    report.Actions.Add("Using existing QASmoke cell override for Daedric proof senders.");
                    return cell;
                }
            }
        }
    }

    var targetBlock = mod.Cells.Records.FirstOrDefault(block =>
        block.GroupType == GroupTypeEnum.InteriorCellBlock
        && block.BlockNumber == 1);
    if (targetBlock is null)
    {
        targetBlock = new CellBlock
        {
            GroupType = GroupTypeEnum.InteriorCellBlock,
            BlockNumber = 1
        };
        mod.Cells.Records.Add(targetBlock);
        report.Actions.Add("Created QASmoke interior cell block override shell for Daedric proof senders.");
    }

    var targetSubBlock = targetBlock.SubBlocks.FirstOrDefault(subBlock =>
        subBlock.GroupType == GroupTypeEnum.InteriorCellSubBlock
        && subBlock.BlockNumber == 9);
    if (targetSubBlock is null)
    {
        targetSubBlock = new CellSubBlock
        {
            GroupType = GroupTypeEnum.InteriorCellSubBlock,
            BlockNumber = 9
        };
        targetBlock.SubBlocks.Add(targetSubBlock);
        report.Actions.Add("Created QASmoke interior cell sub-block override shell for Daedric proof senders.");
    }

    var qasmoke = CreateQASmokeOverrideFromTemplate(report);
    targetSubBlock.Cells.Add(qasmoke);
    index[qasmokeEditorId] = qasmoke;
    report.Actions.Add("Created QASmoke cell override from existing Anvil cell data for Daedric proof senders.");
    return qasmoke;
}

Cell CreateQASmokeOverrideFromTemplate(AuthorReport report)
{
    var template = FindQASmokeTemplateCell(report)
        ?? throw new InvalidOperationException("Could not find a source QASmoke cell template; refusing to write a minimal QASmoke override.");

    var copied = (Cell)DeepCopyRecord(template);
    copied.EditorID = qasmokeEditorId;
    copied.Temporary.Clear();
    copied.Persistent.Clear();
    return copied;
}

Cell? FindQASmokeTemplateCell(AuthorReport report)
{
    foreach (var candidate in qasmokeTemplatePluginCandidates)
    {
        if (!File.Exists(candidate))
        {
            continue;
        }

        var sourceMod = SkyrimMod.CreateFromBinary(candidate, SkyrimRelease.SkyrimSE);
        foreach (var block in sourceMod.Cells.Records)
        {
            foreach (var subBlock in block.SubBlocks)
            {
                foreach (var cell in subBlock.Cells)
                {
                    if (cell.FormKey == qasmokeFormKey || string.Equals(cell.EditorID, qasmokeEditorId, StringComparison.OrdinalIgnoreCase))
                    {
                        report.Actions.Add($"Using QASmoke cell template from {candidate}.");
                        return cell;
                    }
                }
            }
        }
    }

    return null;
}

static object DeepCopyRecord(object record)
{
    var method = record.GetType().GetMethod("DeepCopy", BindingFlags.Instance | BindingFlags.Public, Type.EmptyTypes);
    return method?.Invoke(record, []) ?? record;
}

static void EnsureDaedricProofReferences(
    Cell proofCell,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<DaedricPrince> princes,
    AuthorReport report)
{
    foreach (var (prince, princeIndex) in princes.Select((prince, princeIndex) => (prince, princeIndex)))
    {
        EnsurePlacedReference(proofCell, index, allocator, DaedricProofActivatorEditorId(prince), DaedricProofReferenceEditorId(prince), princeIndex, report);
    }

    EnsurePlacedReference(proofCell, index, allocator, "PDV_ACTI_Daedric_GenericSilenceProbe", "PDV_REFR_Daedric_GenericSilenceProbe_QASmoke", princes.Count, report);
}

static void EnsurePlacedReference(
    Cell proofCell,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string baseEditorId,
    string refEditorId,
    int ordinal,
    AuthorReport report)
{
    if (!index.TryGetValue(baseEditorId, out var baseRecord))
    {
        report.Errors.Add($"Missing Daedric proof base activator: {baseEditorId}");
        return;
    }

    if (baseRecord is not IPlaceableObjectGetter)
    {
        report.Errors.Add($"{baseEditorId} is {baseRecord.GetType().Name}, expected a placeable base record.");
        return;
    }

    PlacedObject placed;
    if (index.TryGetValue(refEditorId, out var existing))
    {
        if (existing is not PlacedObject existingPlaced)
        {
            report.Errors.Add($"{refEditorId} is {existing.GetType().Name}, expected PlacedObject/REFR.");
            return;
        }

        placed = existingPlaced;
        report.Actions.Add($"Updated existing Daedric proof reference {refEditorId}.");
    }
    else
    {
        placed = new PlacedObject(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = refEditorId
        };
        proofCell.Temporary.Add(placed);
        index[refEditorId] = placed;
        report.Actions.Add($"Created Daedric proof reference {refEditorId} in QASmoke.");
    }

    placed.FormVersion = 44;
    placed.EditorID = refEditorId;
    placed.Base = baseRecord.FormKey.ToNullableLink<IPlaceableObjectGetter>();
    placed.Scale = 1.0f;
    placed.Placement = new Placement
    {
        Position = DaedricProofPositionFor(ordinal),
        Rotation = new P3Float(0, 0, 0)
    };
}

static void CheckDaedricProofReferences(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<DaedricPrince> princes,
    AuthorReport report)
{
    foreach (var (prince, princeIndex) in princes.Select((prince, princeIndex) => (prince, princeIndex)))
    {
        CheckPlacedReference(index, DaedricProofActivatorEditorId(prince), DaedricProofReferenceEditorId(prince), report);
    }

    CheckPlacedReference(index, "PDV_ACTI_Daedric_GenericSilenceProbe", "PDV_REFR_Daedric_GenericSilenceProbe_QASmoke", report);
}

static void CheckPlacedReference(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string baseEditorId,
    string refEditorId,
    AuthorReport report)
{
    if (!index.TryGetValue(refEditorId, out var refRecord))
    {
        report.Errors.Add($"Missing Daedric proof placed reference: {refEditorId}");
        return;
    }

    if (refRecord is not PlacedObject placed)
    {
        report.Errors.Add($"{refEditorId} is {refRecord.GetType().Name}, expected PlacedObject/REFR.");
        return;
    }

    if (!index.TryGetValue(baseEditorId, out var baseRecord))
    {
        report.Errors.Add($"Missing Daedric proof base activator for {refEditorId}: {baseEditorId}");
        return;
    }

    if (placed.Base.FormKey != baseRecord.FormKey)
    {
        report.Errors.Add($"{refEditorId} points at {placed.Base.FormKey}, expected {baseEditorId} ({baseRecord.FormKey}).");
        return;
    }

    report.Actions.Add($"{refEditorId} [{placed.FormKey}] -> {baseEditorId} [{baseRecord.FormKey}]");
}

static void CheckDaedricProofActivator(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    DaedricPrince prince,
    int princeIndex,
    AuthorReport report)
{
    CheckSignalActivator(index, DaedricProofActivatorEditorId(prince), DaedricProofActivatorName(prince), "TEST DAEDRIC PATH", 200, princeIndex, DaedricProofSourceId(prince), report);
}

static void CheckDaedricGenericProbeActivator(Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    CheckSignalActivator(index, "PDV_ACTI_Daedric_GenericSilenceProbe", "PDV DAEDRIC GENERIC SILENCE", "TEST NO RESPONSE", 201, 0, "generic", report);
}

static IReadOnlyList<DaedricLiveQuestSource> SelectDaedricLiveQuestSources(
    IReadOnlyList<DaedricLiveQuestSource> sources,
    IReadOnlyList<DaedricPrince> selectedPrinces)
{
    var selectedStems = selectedPrinces
        .Select(prince => prince.stem ?? "")
        .ToHashSet(StringComparer.OrdinalIgnoreCase);
    return sources
        .Where(source => selectedStems.Contains(source.PrinceStem))
        .ToArray();
}

static void EnsureDaedricLiveQuestSourceFormLists(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<DaedricLiveQuestSource> sources,
    AuthorReport report)
{
    foreach (var source in sources)
    {
        FormList formList;
        if (index.TryGetValue(source.FormListEditorId, out var existing))
        {
            if (existing is not FormList existingList)
            {
                throw new InvalidOperationException($"{source.FormListEditorId} exists as {existing.GetType().Name}, expected FLST/FormList.");
            }

            formList = existingList;
            report.Actions.Add($"Verified existing Daedric live source FormList {source.FormListEditorId}.");
        }
        else
        {
            formList = new FormList(allocator.Next(), SkyrimRelease.SkyrimSE)
            {
                FormVersion = 44,
                EditorID = source.FormListEditorId
            };
            mod.FormLists.Add(formList);
            index[source.FormListEditorId] = formList;
            report.Actions.Add($"Created Daedric live source FormList {source.FormListEditorId}.");
        }

        EnsureFormListEntry(formList, source.QuestFormKey, report, source.QuestFormKey.ToString(), source.FormListEditorId);
    }
}

static void CheckDaedricLiveQuestSourceFormLists(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<DaedricLiveQuestSource> sources,
    AuthorReport report)
{
    foreach (var source in sources)
    {
        if (!index.TryGetValue(source.FormListEditorId, out var record))
        {
            report.Errors.Add($"Missing Daedric live source FormList: {source.FormListEditorId}");
            continue;
        }

        if (record is not FormList formList)
        {
            report.Errors.Add($"{source.FormListEditorId} exists as {record.GetType().Name}, expected FLST/FormList.");
            continue;
        }

        if (!formList.Items.Any(item => item.FormKey == source.QuestFormKey))
        {
            report.Errors.Add($"{source.FormListEditorId} is missing exact quest source {source.QuestFormKey}.");
            continue;
        }

        report.Actions.Add($"{source.FormListEditorId} contains {source.QuestFormKey} stage {source.Stage}.");
    }
}

static void WirePlayerEventsDaedricLiveSourceProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<DaedricLiveQuestSource> sources,
    AuthorReport report)
{
    var aliasScript = RequirePlayerEventsAliasScript(index);
    var properties = sources
        .Select(source =>
        {
            var record = RequireRecord<ISkyrimMajorRecordGetter>(index, source.FormListEditorId);
            return ObjectProp(source.FormListEditorId, record.FormKey);
        })
        .ToArray();
    UpsertProperties(aliasScript, properties);
    report.Actions.Add($"Wired {properties.Length} Daedric live source FormList properties on PDV_PlayerEvents alias script.");
}

static void CheckPlayerEventsDaedricLiveSourceProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<DaedricLiveQuestSource> sources,
    AuthorReport report)
{
    var aliasScript = RequirePlayerEventsAliasScript(index);
    foreach (var source in sources)
    {
        var expected = RequireRecord<ISkyrimMajorRecordGetter>(index, source.FormListEditorId);
        CheckObjectProperty(aliasScript, source.FormListEditorId, expected.FormKey, "PDV_PlayerEvents alias", report);
    }
}

static ScriptEntry RequirePlayerEventsAliasScript(Dictionary<string, ISkyrimMajorRecordGetter> index)
{
    var managerQuest = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var adapter = managerQuest.VirtualMachineAdapter ?? throw new InvalidOperationException("PDV__ManagerQuest has no VMAD.");
    var aliasScripts = adapter.Aliases
        .Where(alias => alias.Property.Alias == 0)
        .SelectMany(alias => alias.Scripts)
        .Where(script => string.Equals(script.Name, "PDV_PlayerEvents", StringComparison.OrdinalIgnoreCase))
        .ToArray();

    if (aliasScripts.Length == 0)
    {
        throw new InvalidOperationException("PDV_Player alias VMAD is missing PDV_PlayerEvents.");
    }

    if (aliasScripts.Length > 1)
    {
        throw new InvalidOperationException("PDV_Player alias has multiple PDV_PlayerEvents VMAD entries.");
    }

    return aliasScripts[0];
}

static void CheckSignalActivator(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string editorId,
    string expectedName,
    string expectedActivateText,
    int expectedRouteId,
    int expectedSignalValue,
    string expectedSourceId,
    AuthorReport report)
{
    if (!index.TryGetValue(editorId, out var record))
    {
        report.Errors.Add($"Missing Daedric proof activator: {editorId}");
        return;
    }

    if (record is not SkyrimActivator activator)
    {
        report.Errors.Add($"{editorId} is {record.GetType().Name}, expected Activator.");
        return;
    }

    if (!string.Equals(activator.Name?.String ?? "", expectedName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{editorId} FULL is '{activator.Name?.String ?? ""}', expected '{expectedName}'.");
    }

    if (!string.Equals(activator.ActivateTextOverride?.String ?? "", expectedActivateText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{editorId} activate text is '{activator.ActivateTextOverride?.String ?? ""}', expected '{expectedActivateText}'.");
    }

    var script = activator.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV_EventSignalActivator", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{editorId} is missing PDV_EventSignalActivator VMAD script.");
        return;
    }

    CheckIntProperty(script, "RouteId", expectedRouteId, editorId, report);
    CheckIntProperty(script, "SignalValue", expectedSignalValue, editorId, report);
    CheckStringProperty(script, "SignalSourceId", expectedSourceId, editorId, report);
    report.Actions.Add($"Checked Daedric proof activator {editorId}.");
}

static P3Float DaedricProofPositionFor(int ordinal)
{
    var column = ordinal % 6;
    var row = ordinal / 6;
    return new P3Float(1024f + (column * 192f), -768f + (row * 176f), 64f);
}

static string DaedricProofActivatorEditorId(DaedricPrince prince)
{
    return $"PDV_ACTI_Daedric_{prince.stem}_LiveSender";
}

static string DaedricProofReferenceEditorId(DaedricPrince prince)
{
    return $"PDV_REFR_Daedric_{prince.stem}_LiveSender_QASmoke";
}

static string DaedricProofActivatorName(DaedricPrince prince)
{
    return $"PDV DAEDRIC {prince.stem!.ToUpperInvariant()}";
}

static string DaedricProofSourceId(DaedricPrince prince)
{
    return $"qasmoke_daedric_{prince.stem!.ToLowerInvariant()}";
}

static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expectedFormKey, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptObjectProperty objectProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not an object property.");
        return;
    }

    if (!objectProperty.Object.FormKey.Equals(expectedFormKey))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} points at {objectProperty.Object.FormKey}, expected {expectedFormKey}.");
    }
}

static void CheckIntProperty(ScriptEntry script, string propertyName, int expectedValue, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptIntProperty intProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not an int property.");
        return;
    }

    if (intProperty.Data != expectedValue)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is {intProperty.Data}, expected {expectedValue}.");
    }
}

static void CheckStringProperty(ScriptEntry script, string propertyName, string expectedValue, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptStringProperty stringProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not a string property.");
        return;
    }

    if (!string.Equals(stringProperty.Data, expectedValue, StringComparison.Ordinal))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is '{stringProperty.Data}', expected '{expectedValue}'.");
    }
}

static void CheckIntArrayProperty(ScriptEntry script, string propertyName, int expectedLength, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptIntListProperty list || list.Data.Count != expectedLength)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} must have {expectedLength} Int entries.");
    }
}

static void CheckFloatArrayProperty(ScriptEntry script, string propertyName, int expectedLength, string owner, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptFloatListProperty list || list.Data.Count != expectedLength)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} must have {expectedLength} Float entries.");
    }
}

static void EnsureFormListEntry(FormList formList, FormKey formKey, AuthorReport report, string label, string formListLabel)
{
    if (formList.Items.Any(item => item.FormKey == formKey))
    {
        return;
    }

    formList.Items.Add(formKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    report.Actions.Add($"Added {label} to {formListLabel}.");
}

static void RebuildFormListInManifestOrder(FormList formList, List<FormKey> orderedKeys, AuthorReport report, string formListLabel)
{
    var currentOrder = formList.Items.Select(i => i.FormKey).ToList();
    if (currentOrder.SequenceEqual(orderedKeys))
    {
        report.Actions.Add($"{formListLabel}: already in manifest order ({orderedKeys.Count} entries).");
        return;
    }
    formList.Items.Clear();
    foreach (var key in orderedKeys)
        formList.Items.Add(key.ToLinkGetter<ISkyrimMajorRecordGetter>());
    report.Actions.Add($"Rebuilt {formListLabel} in manifest order ({orderedKeys.Count} entries, was out of order).");
}

static void CheckFormListOrder(FormList formList, List<FormKey> orderedKeys, AuthorReport report, string formListLabel)
{
    var currentOrder = formList.Items.Select(i => i.FormKey).ToList();
    if (currentOrder.SequenceEqual(orderedKeys))
    {
        return;
    }

    report.Errors.Add($"{formListLabel}: entries are not in manifest order. Run --create-missing to rebuild.");
    for (int slot = 0; slot < Math.Max(currentOrder.Count, orderedKeys.Count); slot++)
    {
        var actual = slot < currentOrder.Count ? currentOrder[slot].ToString() : "(none)";
        var expected = slot < orderedKeys.Count ? orderedKeys[slot].ToString() : "(none)";
        var flag = string.Equals(actual, expected, StringComparison.OrdinalIgnoreCase) ? "ok" : "MISWIRED";
        report.Actions.Add($"{formListLabel} slot {slot}: actual={actual} expected={expected} [{flag}]");
    }
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

static ScriptFloatProperty FloatProp(string name, float value)
{
    return new ScriptFloatProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static ScriptIntListProperty IntListProp(string name, params int[] values)
{
    var property = new ScriptIntListProperty
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

static ScriptFloatListProperty FloatListProp(string name, params float[] values)
{
    var property = new ScriptFloatListProperty
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

static ActorValue ParseActorValue(string actorValue)
{
    var normalized = actorValue switch
    {
        "Speechcraft" => "Speech",
        _ => actorValue
    };

    if (Enum.TryParse<ActorValue>(normalized, ignoreCase: true, out var parsed))
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

sealed record PrinceContext(
    Quest Quest,
    SkyrimGlobal StigmaGlobal,
    SkyrimGlobal DebugGlobal,
    SkyrimGlobal OriginGlobal,
    Dictionary<string, Spell> Spells,
    Dictionary<string, Message> Messages);

sealed record DaedricLiveQuestSource(
    string PrinceStem,
    string FormListEditorId,
    FormKey QuestFormKey,
    int Stage);

sealed class DaedricContract
{
    public string? schema { get; set; }
    public string? operationalFormList { get; set; }
    public string? devFormList { get; set; }
    public List<DaedricPrince>? princes { get; set; }
}

sealed class DaedricPrince
{
    public string? stem { get; set; }
    public string? displayName { get; set; }
    public object? batch { get; set; }
    public string? questEditorId { get; set; }
    public string? scriptName { get; set; }
    public bool existingScript { get; set; }
    public string? stigmaGlobalEditorId { get; set; }
    public int commitmentSignalsRequired { get; set; }
    public string? hookSource { get; set; }
    public List<int>? stateByRace { get; set; }
    public List<float>? stigmaModByRace { get; set; }
    public List<int>? exitDifficultyByRace { get; set; }
    public List<DaedricSpell>? boons { get; set; }
    public List<DaedricSpell>? prices { get; set; }
    public List<DaedricMessage>? messages { get; set; }
}

sealed class DaedricSpell
{
    public string? spellEditorId { get; set; }
    public string? magicEffectEditorId { get; set; }
    public string? displayName { get; set; }
    public string? playerFacingText { get; set; }
    public string? property { get; set; }
    public List<DaedricSpellEffect>? effects { get; set; }
}

sealed class DaedricSpellEffect
{
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public int area { get; set; }
    public int duration { get; set; }
}

sealed class DaedricMessage
{
    public string? editorId { get; set; }
    public string? title { get; set; }
    public string? body { get; set; }
    public string? property { get; set; }
    public bool messageBox { get; set; }
    public List<string>? buttons { get; set; }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public bool CheckOnly { get; set; }
    public string? Prince { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
