// PDV Living Deities TEST ESP author (LD-P1 research slice).
//
// Emits PDV_LivingDeitiesTest.esp into a SEPARATE, disable-able MO2 mod folder.
// PlayerDevotion_Framework.esp is read as a MASTER and never written. Everything
// the LD-P1 Block B Papyrus slice needs at the record layer lives in the test
// plugin: the curse-gated PDV_Deity_Hircine quest (SGE + SEQ), the
// PDV_GLO_PatronMoodBand mirror global, the PDV_FLST_DemandGreatBeasts race
// list, an override of PDV_FLST_AllDeities adding the Hircine face, a VMAD
// override of PDV__ManagerQuest wiring the three new properties, a VMAD
// override of PDV_Deity_Kyne wiring band-boon TEST stand-ins, and a test
// clutch-save ability (constant-effect MGEF carrying
// PDV_T3DailyLowHealthSaveEffect with the mood gate engaged).
//
// Usage:
//   dotnet run -- --author [--framework <esp>] [--out <modFolder>]
//   dotnet run -- --check  [--framework <esp>] [--out <modFolder>]

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimFormList = Mutagen.Bethesda.Skyrim.FormList;

const string defaultFramework = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultOutDir = @"D:\Wabbajack\modlists\Anvil\mods\Devotion - Living Deities Test";
const string testEspName = "PDV_LivingDeitiesTest.esp";

var skyrimKey = ModKey.FromNameAndExtension("Skyrim.esm");
var dawnguardKey = ModKey.FromNameAndExtension("Dawnguard.esm");

// Quantified great-beast set (README "Quantified tunables"; FormIDs verified
// against the load order via houseCARL 2026-06-10). True beasts only - dragons
// arrive via eventType 302 and the quest matrix, never the bound event 1.
(FormKey Key, string Label)[] greatBeasts =
[
    (new FormKey(skyrimKey, 0x0131E7), "BearBrownRace"),
    (new FormKey(skyrimKey, 0x0131E8), "BearBlackRace"),
    (new FormKey(skyrimKey, 0x0131E9), "BearSnowRace"),
    (new FormKey(skyrimKey, 0x013200), "SabreCatRace"),
    (new FormKey(skyrimKey, 0x013202), "SabreCatSnowyRace"),
    (new FormKey(dawnguardKey, 0x00D0B6), "DLC1SabreCatGlowRace"),
    (new FormKey(skyrimKey, 0x0131FF), "MammothRace"),
    (new FormKey(skyrimKey, 0x013205), "TrollRace"),
    (new FormKey(skyrimKey, 0x013206), "TrollFrostRace"),
    (new FormKey(dawnguardKey, 0x0117F5), "DLC1TrollRaceArmored"),
    (new FormKey(dawnguardKey, 0x0117F4), "DLC1TrollFrostRaceArmored"),
];

var doAuthor = args.Contains("--author");
var doCheck = args.Contains("--check");
var frameworkPath = Path.GetFullPath(GetArg(args, "--framework") ?? defaultFramework);
var outDir = Path.GetFullPath(GetArg(args, "--out") ?? defaultOutDir);
var espPath = Path.Combine(outDir, testEspName);
var seqPath = Path.Combine(outDir, "SEQ", Path.ChangeExtension(testEspName, ".seq"));

var report = new Report { EspPath = espPath, FrameworkPath = frameworkPath };

try
{
    if (!doAuthor && !doCheck)
    {
        throw new InvalidOperationException("Specify --author or --check.");
    }
    if (!File.Exists(frameworkPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", frameworkPath);
    }

    var framework = SkyrimMod.CreateFromBinary(frameworkPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(framework);

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = manager.VirtualMachineAdapter?.Scripts
            .FirstOrDefault(s => string.Equals(s.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase))
        ?? throw new InvalidOperationException("PDV__ManagerQuest VMAD script missing.");
    var curseStateKey = RequireObjectPropValue(managerScript, "PDV_CurseStateService");
    var debugGloKey = RequireObjectPropValue(managerScript, "PDV_GLO_DebugLevel");
    var originGloKey = RequireObjectPropValue(managerScript, "PDV_GLO_OriginRace");
    var allDeities = RequireRecord<SkyrimFormList>(index, "PDV_FLST_AllDeities");
    var kyne = RequireRecord<Quest>(index, "PDV_Deity_Kyne");
    var nextDeityIndex = ComputeNextDeityIndex(framework, allDeities, report);

    if (doAuthor)
    {
        var testMod = new SkyrimMod(ModKey.FromNameAndExtension(testEspName), SkyrimRelease.SkyrimSE);
        uint nextId = 0x800;
        FormKey Next() => new(testMod.ModKey, nextId++);

        // 1. Mood-band mirror global (Cool = 1 at rest).
        var moodGlobal = new GlobalFloat(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_GLO_PatronMoodBand",
            Data = 1.0f,
        };
        testMod.Globals.Add(moodGlobal);
        report.Actions.Add("Created PDV_GLO_PatronMoodBand (GlobalFloat, 1.0).");

        // 2. Great-beast victim races for the Hircine demand filter.
        var beasts = new SkyrimFormList(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_FLST_DemandGreatBeasts",
        };
        foreach (var (key, label) in greatBeasts)
        {
            beasts.Items.Add(key.ToLinkGetter<ISkyrimMajorRecordGetter>());
            report.Actions.Add($"Great beast: {label} ({key}).");
        }
        testMod.FormLists.Add(beasts);

        // 3. Test clutch-save: constant-effect MGEF carrying the mood-gated
        // script, wrapped in an ability spell used as the Seeker/Pleased
        // band-boon stand-in (proves band-swap AND the clutch gate together).
        var clutchEffect = new MagicEffect(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_LDTEST_MGEF_ClutchSaveKyne",
            Name = Tx("Kyne's Breath (LD test)"),
            Description = Tx("While Kyne is Pleased, she may steady you once a day at death's edge."),
            CastType = CastType.ConstantEffect,
            TargetType = TargetType.Self,
            MagicSkill = ActorValue.None,
            ResistValue = ActorValue.None,
        };
        clutchEffect.Archetype = new MagicEffectArchetype
        {
            Type = MagicEffectArchetype.TypeEnum.Script,
            ActorValue = ActorValue.None,
        };
        WireMagicEffectScript(clutchEffect, "PDV_T3DailyLowHealthSaveEffect",
        [
            StringProp("StorageKey", "PDV.Capstone.LowHealthSave.LDTestKyne"),
            IntProp("RequiredMoodBand", 2),
            StringProp("DeityLabel", "Kyne"),
            ObjectProp("PDV_GLO_PatronMoodBand", moodGlobal.FormKey),
            ObjectProp("PDV_GLO_DebugLevel", debugGloKey),
        ]);
        testMod.MagicEffects.Add(clutchEffect);

        var pleasedSpell = MakeAbility(testMod, Next(), "PDV_LDTEST_SPEL_KyneBoon_Pleased", "Kyne's Favor: Pleased (LD test)", clutchEffect.FormKey);
        var exaltedMarker = new MagicEffect(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_LDTEST_MGEF_KyneExaltedMarker",
            Name = Tx("Kyne's Favor: Exalted (LD test)"),
            Description = Tx("Marker effect proving the Exalted band-boon swap (no gameplay change)."),
            CastType = CastType.ConstantEffect,
            TargetType = TargetType.Self,
            MagicSkill = ActorValue.None,
            ResistValue = ActorValue.None,
        };
        exaltedMarker.Archetype = new MagicEffectArchetype
        {
            Type = MagicEffectArchetype.TypeEnum.Script,
            ActorValue = ActorValue.None,
        };
        testMod.MagicEffects.Add(exaltedMarker);
        var exaltedSpell = MakeAbility(testMod, Next(), "PDV_LDTEST_SPEL_KyneBoon_Exalted", "Kyne's Favor: Exalted (LD test)", exaltedMarker.FormKey);
        report.Actions.Add("Created test clutch MGEF + Pleased/Exalted band-boon stand-in abilities.");

        // 4. The curse-gated Hircine deity face quest. Start Game Enabled +
        // SEQ entry (the BaanDar lesson). All stances TABOO; the curse gate
        // substitutes for nativity at runtime (IsRaceNativeForPlayer override).
        var hircine = new Quest(Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = "PDV_Deity_Hircine",
            Name = Tx("PDV Hircine Deity Face"),
            FormVersion = 44,
            QuestFormVersion = 65,
            Type = Quest.TypeEnum.None,
            Priority = 0,
        };
        hircine.Flags |= Quest.Flag.StartGameEnabled;
        WireQuestScript(hircine, "PDV_Deity_Hircine",
        [
            StringProp("DeityName", "Hircine"),
            StringProp("DeityDomain", "the Hunt"),
            IntProp("DeityIndex", nextDeityIndex),
            FloatProp("MoodAlpha", 0.22f),
            IntProp("Stance_Nord", 2), IntProp("Stance_Imperial", 2),
            IntProp("Stance_Breton", 2), IntProp("Stance_Altmer", 2),
            IntProp("Stance_Bosmer", 2), IntProp("Stance_Dunmer", 2),
            IntProp("Stance_Khajiit", 2), IntProp("Stance_Argonian", 2),
            IntProp("Stance_Orc", 2), IntProp("Stance_Redguard", 2),
            ObjectProp("PDV_CurseStateService", curseStateKey),
            ObjectProp("PDV_GLO_DebugLevel", debugGloKey),
            ObjectProp("PDV_GLO_OriginRace", originGloKey),
        ]);
        testMod.Quests.Add(hircine);
        report.Actions.Add($"Created PDV_Deity_Hircine QUST (SGE, DeityIndex {nextDeityIndex}, stances TABOO).");

        // 5. Override PDV_FLST_AllDeities to register the new face.
        var allDeitiesOverride = allDeities.DeepCopy();
        allDeitiesOverride.Items.Add(hircine.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
        testMod.FormLists.Add(allDeitiesOverride);
        report.Actions.Add($"Override PDV_FLST_AllDeities: {allDeities.Items.Count} -> {allDeitiesOverride.Items.Count} entries.");

        // 6. Override PDV__ManagerQuest VMAD with the three new properties.
        var managerOverride = manager.DeepCopy();
        var managerOverrideScript = managerOverride.VirtualMachineAdapter!.Scripts
            .First(s => string.Equals(s.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
        UpsertProperties(managerOverrideScript,
        [
            ObjectProp("PDV_HircineDeity", hircine.FormKey),
            ObjectProp("PDV_GLO_PatronMoodBand", moodGlobal.FormKey),
            ObjectProp("PDV_FLST_DemandGreatBeasts", beasts.FormKey),
        ]);
        testMod.Quests.Add(managerOverride);
        report.Actions.Add("Override PDV__ManagerQuest: +PDV_HircineDeity, +PDV_GLO_PatronMoodBand, +PDV_FLST_DemandGreatBeasts.");

        // 7. Override PDV_Deity_Kyne with band-boon test stand-ins.
        var kyneOverride = kyne.DeepCopy();
        var kyneScript = EnsureScript(kyneOverride.VirtualMachineAdapter!, "PDV_Deity_Kyne");
        UpsertProperties(kyneScript,
        [
            ObjectProp("Boon_Seeker_Pleased", pleasedSpell.FormKey),
            ObjectProp("Boon_Seeker_Exalted", exaltedSpell.FormKey),
        ]);
        testMod.Quests.Add(kyneOverride);
        report.Actions.Add("Override PDV_Deity_Kyne: +Boon_Seeker_Pleased/_Exalted test stand-ins.");

        Directory.CreateDirectory(outDir);
        var tempPath = espPath + ".tmp";
        using (var stream = File.Create(tempPath))
        {
            testMod.WriteToBinary(stream);
        }
        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        report.TouchedFiles.Add(espPath);

        WriteSeq(seqPath, espPath, [hircine.FormKey], report);
        report.Status = "PASS";
    }
    else
    {
        RunCheck(espPath, seqPath, index, nextDeityIndex, greatBeasts.Length, report);
    }
}
catch (Exception ex)
{
    report.Status = "FAIL";
    report.Errors.Add(ex.Message);
}

Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
return report.Status == "PASS" ? 0 : 1;

static void RunCheck(
    string espPath,
    string seqPath,
    Dictionary<string, ISkyrimMajorRecordGetter> frameworkIndex,
    int expectedDeityIndex,
    int expectedBeastCount,
    Report report)
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Test ESP not authored yet.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    var hircine = RequireRecord<Quest>(index, "PDV_Deity_Hircine");
    if (!hircine.Flags.HasFlag(Quest.Flag.StartGameEnabled))
    {
        report.Errors.Add("PDV_Deity_Hircine is not Start Game Enabled.");
    }
    var hircineScript = hircine.VirtualMachineAdapter?.Scripts
        .FirstOrDefault(s => string.Equals(s.Name, "PDV_Deity_Hircine", StringComparison.OrdinalIgnoreCase));
    if (hircineScript is null)
    {
        report.Errors.Add("PDV_Deity_Hircine quest is missing its script.");
    }
    else
    {
        CheckProp<ScriptStringProperty>(hircineScript, "DeityName", p => p.Data == "Hircine", report);
        CheckProp<ScriptIntProperty>(hircineScript, "DeityIndex", p => p.Data == expectedDeityIndex, report);
        CheckProp<ScriptFloatProperty>(hircineScript, "MoodAlpha", p => Math.Abs(p.Data - 0.22f) < 0.0001f, report);
        CheckProp<ScriptObjectProperty>(hircineScript, "PDV_CurseStateService", p => !p.Object.IsNull, report);
    }

    var beasts = RequireRecord<SkyrimFormList>(index, "PDV_FLST_DemandGreatBeasts");
    if (beasts.Items.Count != expectedBeastCount)
    {
        report.Errors.Add($"PDV_FLST_DemandGreatBeasts has {beasts.Items.Count} entries, expected {expectedBeastCount}.");
    }

    RequireRecord<GlobalFloat>(index, "PDV_GLO_PatronMoodBand");

    var allDeitiesOverride = RequireRecord<SkyrimFormList>(index, "PDV_FLST_AllDeities");
    if (!allDeitiesOverride.Items.Any(item => item.FormKey == hircine.FormKey))
    {
        report.Errors.Add("PDV_FLST_AllDeities override does not contain the Hircine face.");
    }
    var frameworkAll = RequireRecord<SkyrimFormList>(frameworkIndex, "PDV_FLST_AllDeities");
    if (allDeitiesOverride.Items.Count != frameworkAll.Items.Count + 1)
    {
        report.Errors.Add($"PDV_FLST_AllDeities override count {allDeitiesOverride.Items.Count} != framework {frameworkAll.Items.Count} + 1.");
    }

    var managerOverride = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = managerOverride.VirtualMachineAdapter?.Scripts
        .FirstOrDefault(s => string.Equals(s.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
    if (managerScript is null)
    {
        report.Errors.Add("PDV__ManagerQuest override is missing its script.");
    }
    else
    {
        CheckProp<ScriptObjectProperty>(managerScript, "PDV_HircineDeity", p => p.Object.FormKey == hircine.FormKey, report);
        CheckProp<ScriptObjectProperty>(managerScript, "PDV_GLO_PatronMoodBand", p => !p.Object.IsNull, report);
        CheckProp<ScriptObjectProperty>(managerScript, "PDV_FLST_DemandGreatBeasts", p => p.Object.FormKey == beasts.FormKey, report);
    }

    var kyneOverride = RequireRecord<Quest>(index, "PDV_Deity_Kyne");
    var kyneScript = kyneOverride.VirtualMachineAdapter?.Scripts
        .FirstOrDefault(s => string.Equals(s.Name, "PDV_Deity_Kyne", StringComparison.OrdinalIgnoreCase));
    if (kyneScript is null)
    {
        report.Errors.Add("PDV_Deity_Kyne override is missing its script.");
    }
    else
    {
        CheckProp<ScriptObjectProperty>(kyneScript, "Boon_Seeker_Pleased", p => !p.Object.IsNull, report);
        CheckProp<ScriptObjectProperty>(kyneScript, "Boon_Seeker_Exalted", p => !p.Object.IsNull, report);
    }

    if (!File.Exists(seqPath))
    {
        report.Errors.Add($"SEQ file missing: {seqPath}");
    }
    else
    {
        var bytes = File.ReadAllBytes(seqPath);
        var masterCount = (uint)mod.ModHeader.MasterReferences.Count;
        var expectedRaw = (masterCount << 24) | ParseLocalId(hircine.FormKey);
        var found = false;
        for (var i = 0; i + 4 <= bytes.Length; i += 4)
        {
            if (BitConverter.ToUInt32(bytes, i) == expectedRaw)
            {
                found = true;
            }
        }
        if (!found)
        {
            report.Errors.Add($"SEQ does not contain expected raw FormID 0x{expectedRaw:X8}.");
        }
        else
        {
            report.Actions.Add($"SEQ contains PDV_Deity_Hircine (0x{expectedRaw:X8}).");
        }
    }

    report.Actions.Add($"Masters: {string.Join(", ", mod.ModHeader.MasterReferences.Select(m => m.Master.FileName))}");
    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
}

static void CheckProp<T>(ScriptEntry script, string name, Func<T, bool> predicate, Report report)
    where T : ScriptProperty
{
    var property = script.Properties.FirstOrDefault(p => string.Equals(p.Name, name, StringComparison.OrdinalIgnoreCase));
    if (property is null)
    {
        report.Errors.Add($"Property {name} is missing on {script.Name}.");
        return;
    }
    if (property is not T typed)
    {
        report.Errors.Add($"Property {name} is {property.GetType().Name}, expected {typeof(T).Name}.");
        return;
    }
    if (!predicate(typed))
    {
        report.Errors.Add($"Property {name} has an unexpected value.");
        return;
    }
    report.Actions.Add($"Property OK: {script.Name}.{name}");
}

static Spell MakeAbility(SkyrimMod mod, FormKey key, string editorId, string name, FormKey effectKey)
{
    var spell = new Spell(key, SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        Name = Tx(name),
        Type = SpellType.Ability,
        CastType = CastType.ConstantEffect,
        TargetType = TargetType.Self,
        BaseCost = 0,
    };
    spell.Effects.Add(new Effect
    {
        BaseEffect = effectKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData { Magnitude = 0f, Area = 0, Duration = 0 },
    });
    mod.Spells.Add(spell);
    return spell;
}

// SEQ = little-endian u32 raw FormIDs of Start Game Enabled quests in this
// plugin. Raw id = (master count << 24) | local id, read back from the
// written plugin so the master list is the authoritative one.
static void WriteSeq(string seqPath, string espPath, FormKey[] questKeys, Report report)
{
    var written = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var masterCount = (uint)written.ModHeader.MasterReferences.Count;
    Directory.CreateDirectory(Path.GetDirectoryName(seqPath)!);
    using var stream = File.Create(seqPath);
    using var writer = new BinaryWriter(stream);
    foreach (var key in questKeys)
    {
        var raw = (masterCount << 24) | ParseLocalId(key);
        writer.Write(raw);
        report.Actions.Add($"SEQ entry: 0x{raw:X8} ({key}).");
    }
    report.TouchedFiles.Add(seqPath);
    report.Actions.Add($"Masters: {string.Join(", ", written.ModHeader.MasterReferences.Select(m => m.Master.FileName))}");
}

static int ComputeNextDeityIndex(SkyrimMod framework, SkyrimFormList allDeities, Report report)
{
    var max = -1;
    var quests = framework.Quests.ToDictionary(q => q.FormKey, q => q);
    foreach (var item in allDeities.Items)
    {
        if (!quests.TryGetValue(item.FormKey, out var quest))
        {
            continue;
        }
        foreach (var script in quest.VirtualMachineAdapter?.Scripts ?? [])
        {
            var prop = script.Properties.FirstOrDefault(p => string.Equals(p.Name, "DeityIndex", StringComparison.OrdinalIgnoreCase));
            if (prop is ScriptIntProperty intProp && intProp.Data > max)
            {
                max = intProp.Data;
            }
        }
    }
    var next = max + 1;
    report.Actions.Add($"Max framework DeityIndex {max}; Hircine face gets {next}.");
    return next;
}

static FormKey RequireObjectPropValue(ScriptEntry script, string name)
{
    var property = script.Properties.FirstOrDefault(p => string.Equals(p.Name, name, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptObjectProperty objectProperty || objectProperty.Object.IsNull)
    {
        throw new InvalidOperationException($"Manager VMAD property {name} missing or unset; cannot resolve the target record.");
    }
    return objectProperty.Object.FormKey;
}

static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
{
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScriptIn(effect.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScriptIn(quest.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static ScriptEntry EnsureScript(QuestAdapter adapter, string scriptName)
{
    return EnsureScriptIn(adapter.Scripts, scriptName);
}

static ScriptEntry EnsureScriptIn(IList<ScriptEntry> scripts, string scriptName)
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

static uint ParseLocalId(FormKey key) => key.ID;

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length)
    {
        return null;
    }
    return args[index + 1];
}

static ScriptObjectProperty ObjectProp(string name, FormKey formKey)
{
    return new ScriptObjectProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
        Alias = -1,
    };
}

static ScriptStringProperty StringProp(string name, string value) =>
    new() { Name = name, Flags = ScriptProperty.Flag.Edited, Data = value };

static ScriptIntProperty IntProp(string name, int value) =>
    new() { Name = name, Flags = ScriptProperty.Flag.Edited, Data = value };

static ScriptFloatProperty FloatProp(string name, float value) =>
    new() { Name = name, Flags = ScriptProperty.Flag.Edited, Data = value };

static TranslatedString Tx(string value) => new(Language.English, value);

sealed class Report
{
    public string Status { get; set; } = "FAIL";
    public string? EspPath { get; set; }
    public string? FrameworkPath { get; set; }
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<string> TouchedFiles { get; } = [];
}
