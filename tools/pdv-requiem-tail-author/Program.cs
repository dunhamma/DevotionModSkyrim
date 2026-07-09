using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimFormList = Mutagen.Bethesda.Skyrim.FormList;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
var skyrimMaster = ModKey.FromNameAndExtension("Skyrim.esm");
var dawnguardMaster = ModKey.FromNameAndExtension("Dawnguard.esm");
var dragonbornMaster = ModKey.FromNameAndExtension("Dragonborn.esm");
var restoreHealthEffect = new FormKey(skyrimMaster, 0x01CEA6);

var dryRun = args.Contains("--dry-run");
var check = args.Contains("--check");
var all = args.Contains("--all");
var authorCapstones = all || args.Contains("--author-capstones");
var authorHoonDingBosses = all || args.Contains("--author-hoonding-bosses");
var authorNamira = all || args.Contains("--author-namira");
var authorAshAbahClearedSites = all || args.Contains("--author-ashabah-cleared-sites");
var authorUndeadCryptClearSites = all || args.Contains("--author-undead-crypt-clear-sites");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

var capstones = new[]
{
    new CapstoneConfig(
        "PDV_Bless_Nord_Shor_T3",
        "PDV_MGEF_Nord_Shor_T3_AvoidDeath",
        "PDV_SPEL_Nord_Shor_T3_AvoidDeathHeal",
        "PDV.Capstone.LowHealthSave.Nord",
        "Shor Remembers",
        "Shor pulls you back from the edge.",
        "Shor's Last Stand",
        "Shor pulls you back from the edge."),
    new CapstoneConfig(
        "PDV_Bless_Redguard_HoonDing_T3",
        "PDV_MGEF_Redguard_HoonDing_T3_AvoidDeath",
        "PDV_SPEL_Redguard_HoonDing_T3_AvoidDeathHeal",
        "PDV.Capstone.LowHealthSave.HoonDing",
        "HoonDing Makes Way",
        "HoonDing opens the road back from the edge.",
        "HoonDing's Edge",
        "HoonDing opens the road back from the edge.")
};

var hoonDingBosses = new[]
{
    new BossEntry(new FormKey(skyrimMaster, 0x100767), "Krosis"),
    new BossEntry(new FormKey(skyrimMaster, 0x04D6E7), "Hevnoraak"),
    new BossEntry(new FormKey(skyrimMaster, 0x0F496C), "Morokei"),
    new BossEntry(new FormKey(skyrimMaster, 0x0F849B), "Nahkriin"),
    new BossEntry(new FormKey(skyrimMaster, 0x03763A), "Otar"),
    new BossEntry(new FormKey(skyrimMaster, 0x035351), "Rahgot"),
    new BossEntry(new FormKey(skyrimMaster, 0x0327C2), "Vokun"),
    new BossEntry(new FormKey(skyrimMaster, 0x041930), "Volsung"),
    new BossEntry(new FormKey(dragonbornMaster, 0x01CAD5), "Vahlok"),
    new BossEntry(new FormKey(dragonbornMaster, 0x0248E9), "Ahzidal"),
    new BossEntry(new FormKey(dragonbornMaster, 0x0248E1), "Dukaan"),
    new BossEntry(new FormKey(dragonbornMaster, 0x0248E8), "Zahkriisos"),
    new BossEntry(new FormKey(dragonbornMaster, 0x01FB98), "Miraak"),
    new BossEntry(new FormKey(dawnguardMaster, 0x01A93D), "Lord Harkon"),
    new BossEntry(new FormKey(dawnguardMaster, 0x003788), "Arch-Curate Vyrthur"),
    new BossEntry(new FormKey(dragonbornMaster, 0x019665), "Karstaag"),
    new BossEntry(new FormKey(dragonbornMaster, 0x0285C3), "Ebony Warrior"),
    new BossEntry(new FormKey(skyrimMaster, 0x0C1908), "Red Eagle"),
    new BossEntry(new FormKey(skyrimMaster, 0x026C52), "Queen Potema")
};

var ashAbahClearedSites = new[]
{
    new LocationEntry(new FormKey(skyrimMaster, 0x0192C3), "Volunruud"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192AA), "Silverdrift Lair"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019299), "Saarthal"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019261), "Korvanjund"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019192), "Halldir's Cairn"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019188), "Geirmund's Hall"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01917B), "Forsaken Cave"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019179), "Folgunthur"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019161), "Dead Men's Respite"),
    new LocationEntry(new FormKey(dawnguardMaster, 0x004EE8), "Dimhollow Crypt"),
    new LocationEntry(new FormKey(dragonbornMaster, 0x0142BB), "Kolbjorn Barrow"),
    new LocationEntry(new FormKey(dragonbornMaster, 0x0142BA), "Vahlok's Tomb"),
    new LocationEntry(new FormKey(dragonbornMaster, 0x0142B6), "Temple of Miraak"),
    new LocationEntry(new FormKey(dragonbornMaster, 0x01429A), "Raven Rock Mine"),
    new LocationEntry(new FormKey(skyrimMaster, 0x018EE9), "Bleak Falls Barrow"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019173), "Dustman's Cairn"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019196), "Hillgrund's Tomb"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019265), "Ysgramor's Tomb"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019292), "Reachcliff Cave"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192AF), "Snow Veil Sanctum"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192B1), "Soljund's Sinkhole"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192C9), "Yngol Barrow"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0350BC), "Ironbind Barrow"),
    new LocationEntry(new FormKey(dragonbornMaster, 0x0142BC), "White Ridge Barrow"),
    new LocationEntry(new FormKey(skyrimMaster, 0x018EE3), "Angarvunde"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019293), "Reachwater Rock"),
    new LocationEntry(new FormKey(skyrimMaster, 0x06CCC6), "Shroud Hearth Barrow"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0ECF53), "Mara's Eye Pond"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019288), "Pinemoon Cave"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01918F), "Haemar's Shame"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01914D), "Broken Fang Cave"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0A0E30), "Shriekwind Bastion"),
    new LocationEntry(new FormKey(dawnguardMaster, 0x003CFD), "Moldering Ruins"),
    new LocationEntry(new FormKey(dawnguardMaster, 0x004D6F), "Redwater Den"),
    new LocationEntry(new FormKey(skyrimMaster, 0x016F85), "Bloodlet Throne"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01BDFC), "Movarth's Lair"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192C2), "Volskygge"),
    new LocationEntry(new FormKey(skyrimMaster, 0x0192AB), "Skuldafn"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01928F), "Ragnvald"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019195), "High Gate Ruins"),
    new LocationEntry(new FormKey(skyrimMaster, 0x019262), "Labyrinthian"),
    new LocationEntry(new FormKey(skyrimMaster, 0x033DA0), "Valthume"),
    new LocationEntry(new FormKey(skyrimMaster, 0x01917A), "Forelhost")
};

var namiraBoons = new[]
{
    new NamiraBoon("PDV_Bless_Daedric_Namira_Seeker", "PDV_MGEF_Bless_Daedric_Namira_Seeker"),
    new NamiraBoon("PDV_Bless_Daedric_Namira_Devoted", "PDV_MGEF_Bless_Daedric_Namira_Devoted"),
    new NamiraBoon("PDV_Bless_Daedric_Namira_Champion", "PDV_MGEF_Bless_Daedric_Namira_Champion")
};

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    Check = check,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!authorCapstones && !authorHoonDingBosses && !authorNamira && !authorAshAbahClearedSites && !authorUndeadCryptClearSites)
    {
        throw new InvalidOperationException("Specify --all or one of --author-capstones, --author-hoonding-bosses, --author-namira, --author-ashabah-cleared-sites, --author-undead-crypt-clear-sites.");
    }

    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    ValidateRequiredMasters(mod, report);

    if (check)
    {
        if (authorCapstones)
        {
            CheckCapstones(index, capstones, restoreHealthEffect, report);
        }

        if (authorHoonDingBosses)
        {
            CheckHoonDingBosses(index, hoonDingBosses, report);
        }

        if (authorNamira)
        {
            CheckNamira(index, namiraBoons, report);
        }

        if (authorAshAbahClearedSites)
        {
            CheckAshAbahClearedSites(index, ashAbahClearedSites, report);
        }

        if (authorUndeadCryptClearSites)
        {
            CheckUndeadCryptClearSites(index, ashAbahClearedSites, report);
        }
    }
    else
    {
        if (authorCapstones)
        {
            AuthorCapstones(mod, index, allocator, capstones, restoreHealthEffect, report);
        }

        if (authorHoonDingBosses)
        {
            AuthorHoonDingBosses(mod, index, allocator, hoonDingBosses, report);
        }

        if (authorNamira)
        {
            AuthorNamira(index, namiraBoons, report);
        }

        if (authorAshAbahClearedSites)
        {
            AuthorAshAbahClearedSites(mod, index, allocator, ashAbahClearedSites, report);
        }

        if (authorUndeadCryptClearSites)
        {
            AuthorUndeadCryptClearSites(mod, index, allocator, ashAbahClearedSites, report);
        }

        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report);
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

static void ValidateRequiredMasters(SkyrimMod mod, AuthorReport report)
{
    foreach (var required in new[] { "Skyrim.esm", "Dawnguard.esm", "Dragonborn.esm" })
    {
        if (!mod.ModHeader.MasterReferences.Any(master => string.Equals(master.Master.FileName.String, required, StringComparison.OrdinalIgnoreCase)))
        {
            report.Errors.Add($"Devotion.esp is missing required master reference {required}; refusing to write cross-master tail records.");
        }
    }
}

static void AuthorCapstones(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<CapstoneConfig> capstones,
    FormKey restoreHealthEffect,
    AuthorReport report)
{
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");

    foreach (var capstone in capstones)
    {
        var rewardSpell = RequireRecord<Spell>(index, capstone.RewardSpellEditorId);
        foreach (var visible in rewardSpell.Effects)
        {
            var visibleMgef = FindMagicEffect(index, visible.BaseEffect.FormKey);
            if (visibleMgef is not null && !string.Equals(visibleMgef.EditorID, capstone.ScriptEffectEditorId, StringComparison.OrdinalIgnoreCase))
            {
                RemoveMagicEffectScript(visibleMgef, "PDV_T3DailyLowHealthSaveEffect");
            }
        }

        var healSpell = EnsureCapstoneHealSpell(mod, index, allocator, capstone, restoreHealthEffect, report);
        var scriptEffect = EnsureCapstoneScriptEffect(mod, index, allocator, capstone, debugGlobal.FormKey, healSpell.FormKey, report);
        EnsureSpellCarriesEffect(rewardSpell, scriptEffect.FormKey, 0.0f, report);
        report.Actions.Add($"Prepared capstone tail for {capstone.RewardSpellEditorId}.");
    }
}

static Spell EnsureCapstoneHealSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    CapstoneConfig capstone,
    FormKey restoreHealthEffect,
    AuthorReport report)
{
    var spell = EnsureSpellRecord(mod, index, allocator, capstone.HealSpellEditorId);
    spell.EditorID = capstone.HealSpellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(capstone.HealSpellName);
    spell.Description = Tx(capstone.HealSpellDescription);
    spell.BaseCost = 0;
    spell.Type = SpellType.Spell;
    spell.CastType = CastType.FireAndForget;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();
    spell.Effects.Add(new Effect
    {
        BaseEffect = restoreHealthEffect.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData { Magnitude = capstone.HealMagnitude, Area = 0, Duration = 0 },
        Conditions = []
    });
    report.Actions.Add($"Prepared heal spell {spell.EditorID}.");
    return spell;
}

static MagicEffect EnsureCapstoneScriptEffect(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    CapstoneConfig capstone,
    FormKey debugGlobal,
    FormKey healSpell,
    AuthorReport report)
{
    var effect = EnsureMagicEffectRecord(mod, index, allocator, capstone.ScriptEffectEditorId);
    effect.EditorID = capstone.ScriptEffectEditorId;
    effect.FormVersion = 44;
    effect.Name = Tx(capstone.ScriptEffectName);
    effect.Description = Tx(capstone.ScriptEffectDescription);
    effect.Flags = MagicEffect.Flag.Recover
        | MagicEffect.Flag.NoDuration
        | MagicEffect.Flag.NoArea
        | MagicEffect.Flag.HideInUI
        | MagicEffect.Flag.PowerAffectsMagnitude;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.Restoration;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script)
    {
        ActorValue = ActorValue.None
    };
    effect.CastType = CastType.ConstantEffect;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
    WireMagicEffectScript(effect, "PDV_T3DailyLowHealthSaveEffect", new ScriptProperty[]
    {
        StringProp("StorageKey", capstone.StorageKey),
        StringProp("NotificationText", capstone.NotificationText),
        StringProp("PrismaTitle", capstone.PrismaTitle),
        StringProp("PrismaText", capstone.PrismaText),
        StringProp("PrismaSymbol", capstone.PrismaSymbol),
        StringProp("PrismaTone", capstone.PrismaTone),
        FloatProp("TriggerHealthPercent", capstone.TriggerHealthPercent),
        FloatProp("HealAmount", capstone.HealAmount),
        FloatProp("WatchIntervalSeconds", capstone.WatchIntervalSeconds),
        ObjectProp("HealSpell", healSpell),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal)
    });
    report.Actions.Add($"Prepared hidden script effect {effect.EditorID}.");
    return effect;
}

static void EnsureSpellCarriesEffect(Spell spell, FormKey effectFormKey, float magnitude, AuthorReport report)
{
    var matching = spell.Effects.Where(effect => effect.BaseEffect.FormKey.Equals(effectFormKey)).ToList();
    Effect effectEntry;
    if (matching.Count == 0)
    {
        effectEntry = new Effect
        {
            BaseEffect = effectFormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData(),
            Conditions = []
        };
        spell.Effects.Add(effectEntry);
        report.Actions.Add($"Added hidden script effect {effectFormKey} to {spell.EditorID}.");
    }
    else
    {
        effectEntry = matching[0];
    }

    foreach (var duplicate in matching.Skip(1))
    {
        spell.Effects.Remove(duplicate);
        report.Actions.Add($"Removed duplicate hidden script effect {effectFormKey} from {spell.EditorID}.");
    }

    effectEntry.BaseEffect = effectFormKey.ToNullableLink<IMagicEffectGetter>();
    effectEntry.Data = new EffectData { Magnitude = magnitude, Area = 0, Duration = 0 };
    effectEntry.Conditions.Clear();
}

static void CheckCapstones(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<CapstoneConfig> capstones,
    FormKey restoreHealthEffect,
    AuthorReport report)
{
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");

    foreach (var capstone in capstones)
    {
        var rewardSpell = RequireRecord<Spell>(index, capstone.RewardSpellEditorId);
        var scriptEffect = RequireRecord<MagicEffect>(index, capstone.ScriptEffectEditorId);
        var healSpell = RequireRecord<Spell>(index, capstone.HealSpellEditorId);

        foreach (var visible in rewardSpell.Effects.Where(entry => !entry.BaseEffect.FormKey.Equals(scriptEffect.FormKey)))
        {
            var visibleMgef = FindMagicEffect(index, visible.BaseEffect.FormKey);
            if (visibleMgef?.VirtualMachineAdapter?.Scripts.Any(script => string.Equals(script.Name, "PDV_T3DailyLowHealthSaveEffect", StringComparison.OrdinalIgnoreCase)) == true)
            {
                report.Errors.Add($"{visibleMgef.EditorID} still carries PDV_T3DailyLowHealthSaveEffect; expected dedicated hidden effect {scriptEffect.EditorID}.");
            }
        }

        var rewardEffectCount = rewardSpell.Effects.Count(effect => effect.BaseEffect.FormKey.Equals(scriptEffect.FormKey));
        if (rewardEffectCount != 1)
        {
            report.Errors.Add($"{rewardSpell.EditorID} carries {rewardEffectCount} instance(s) of {scriptEffect.EditorID}; expected exactly 1.");
        }

        if (healSpell.Type != SpellType.Spell || healSpell.CastType != CastType.FireAndForget || healSpell.TargetType != TargetType.Self)
        {
            report.Errors.Add($"{healSpell.EditorID} is not a self FireAndForget Spell.");
        }

        var healEffect = healSpell.Effects.FirstOrDefault();
        if (healEffect is null
            || healEffect.Data is null
            || !healEffect.BaseEffect.FormKey.Equals(restoreHealthEffect)
            || Math.Abs(healEffect.Data.Magnitude - capstone.HealMagnitude) > 0.0001f)
        {
            report.Errors.Add($"{healSpell.EditorID} does not use RestoreHealthFFSelf at magnitude {capstone.HealMagnitude}.");
        }

        if (scriptEffect.Archetype is not MagicEffectArchetype archetype || archetype.Type != MagicEffectArchetype.TypeEnum.Script)
        {
            report.Errors.Add($"{scriptEffect.EditorID} is not a Script archetype magic effect.");
        }

        if (scriptEffect.CastType != CastType.ConstantEffect || scriptEffect.TargetType != TargetType.Self)
        {
            report.Errors.Add($"{scriptEffect.EditorID} is not a self ConstantEffect magic effect.");
        }

        if (!scriptEffect.Flags.HasFlag(MagicEffect.Flag.HideInUI)
            || !scriptEffect.Flags.HasFlag(MagicEffect.Flag.Recover)
            || !scriptEffect.Flags.HasFlag(MagicEffect.Flag.NoDuration)
            || !scriptEffect.Flags.HasFlag(MagicEffect.Flag.NoArea))
        {
            report.Errors.Add($"{scriptEffect.EditorID} does not carry the expected hidden script-effect flags.");
        }

        var script = scriptEffect.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV_T3DailyLowHealthSaveEffect", StringComparison.OrdinalIgnoreCase));
        if (script is null)
        {
            report.Errors.Add($"{scriptEffect.EditorID} is missing PDV_T3DailyLowHealthSaveEffect.");
            continue;
        }

        var props = script.Properties
            .Where(prop => !string.IsNullOrWhiteSpace(prop.Name))
            .ToDictionary(prop => prop.Name!, StringComparer.OrdinalIgnoreCase);
        CheckStringProperty(props, "StorageKey", capstone.StorageKey, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckStringProperty(props, "NotificationText", capstone.NotificationText, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckStringProperty(props, "PrismaTitle", capstone.PrismaTitle, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckStringProperty(props, "PrismaText", capstone.PrismaText, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckStringProperty(props, "PrismaSymbol", capstone.PrismaSymbol, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckStringProperty(props, "PrismaTone", capstone.PrismaTone, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckFloatProperty(props, "TriggerHealthPercent", capstone.TriggerHealthPercent, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckFloatProperty(props, "HealAmount", capstone.HealAmount, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckFloatProperty(props, "WatchIntervalSeconds", capstone.WatchIntervalSeconds, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckObjectProperty(script, "HealSpell", healSpell.FormKey, scriptEffect.EditorID ?? "(missing editorid)", report);
        CheckObjectProperty(script, "PDV_GLO_DebugLevel", debugGlobal.FormKey, scriptEffect.EditorID ?? "(missing editorid)", report);
        report.Actions.Add($"{scriptEffect.EditorID} capstone check complete.");
    }
}

static void AuthorHoonDingBosses(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<BossEntry> bosses,
    AuthorReport report)
{
    var list = EnsureFormList(mod, index, allocator, "PDV_FLST_HoonDing_BreakthroughBosses", report);
    list.Items.Clear();
    foreach (var boss in bosses)
    {
        list.Items.Add(boss.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    UpsertProperties(managerScript, new ScriptProperty[]
    {
        ObjectProp("PDV_FLST_HoonDing_BreakthroughBosses", list.FormKey),
        ObjectProp("NecromancerFaction", new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x034B74)),
        ObjectProp("WarlockFaction", new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x026724))
    });
    report.Actions.Add($"Rebuilt PDV_FLST_HoonDing_BreakthroughBosses with {bosses.Count} exact boss base(s) and wired manager properties.");
}

static void CheckHoonDingBosses(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<BossEntry> bosses,
    AuthorReport report)
{
    var list = RequireRecord<SkyrimFormList>(index, "PDV_FLST_HoonDing_BreakthroughBosses");
    var actual = list.Items.Select(item => item.FormKey).ToList();
    if (actual.Count != bosses.Count)
    {
        report.Errors.Add($"{list.EditorID} has {actual.Count} entries; expected {bosses.Count}.");
    }

    for (var i = 0; i < bosses.Count; i++)
    {
        if (i >= actual.Count)
        {
            report.Errors.Add($"{list.EditorID} is missing expected slot {i}: {bosses[i].Label} {bosses[i].FormKey}.");
            continue;
        }

        if (!actual[i].Equals(bosses[i].FormKey))
        {
            report.Errors.Add($"{list.EditorID}[{i}] is {actual[i]}, expected {bosses[i].Label} {bosses[i].FormKey}.");
        }
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    CheckObjectProperty(managerScript, "PDV_FLST_HoonDing_BreakthroughBosses", list.FormKey, "PDV__ManagerQuest", report);
    CheckObjectProperty(managerScript, "NecromancerFaction", new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x034B74), "PDV__ManagerQuest", report);
    CheckObjectProperty(managerScript, "WarlockFaction", new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x026724), "PDV__ManagerQuest", report);
    report.Actions.Add($"{list.EditorID} boss list check complete.");
}

static void AuthorAshAbahClearedSites(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<LocationEntry> locations,
    AuthorReport report)
{
    var list = EnsureFormList(mod, index, allocator, "PDV_FLST_RedguardAshAbahUndeadClearSites", report);
    list.Items.Clear();
    foreach (var location in locations)
    {
        list.Items.Add(location.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    UpsertProperties(managerScript, new ScriptProperty[]
    {
        ObjectProp("PDV_FLST_RedguardAshAbahUndeadClearSites", list.FormKey)
    });
    report.Actions.Add($"Rebuilt PDV_FLST_RedguardAshAbahUndeadClearSites with {locations.Count} clearable undead location(s) and wired manager property.");
}

static void CheckAshAbahClearedSites(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<LocationEntry> locations,
    AuthorReport report)
{
    var list = RequireRecord<SkyrimFormList>(index, "PDV_FLST_RedguardAshAbahUndeadClearSites");
    var actual = list.Items.Select(item => item.FormKey).ToList();
    if (actual.Count != locations.Count)
    {
        report.Errors.Add($"{list.EditorID} has {actual.Count} entries; expected {locations.Count}.");
    }

    for (var i = 0; i < locations.Count; i++)
    {
        if (i >= actual.Count)
        {
            report.Errors.Add($"{list.EditorID} is missing expected slot {i}: {locations[i].Label} {locations[i].FormKey}.");
            continue;
        }

        if (!actual[i].Equals(locations[i].FormKey))
        {
            report.Errors.Add($"{list.EditorID}[{i}] is {actual[i]}, expected {locations[i].Label} {locations[i].FormKey}.");
        }
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    CheckObjectProperty(managerScript, "PDV_FLST_RedguardAshAbahUndeadClearSites", list.FormKey, "PDV__ManagerQuest", report);
    report.Actions.Add($"{list.EditorID} cleared-site list check complete.");
}

static void AuthorUndeadCryptClearSites(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IReadOnlyList<LocationEntry> locations,
    AuthorReport report)
{
    var list = EnsureFormList(mod, index, allocator, "PDV_FLST_UndeadCryptClearSites", report);
    list.Items.Clear();
    foreach (var location in locations)
    {
        list.Items.Add(location.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    UpsertProperties(managerScript, new ScriptProperty[]
    {
        ObjectProp("PDV_FLST_UndeadCryptClearSites", list.FormKey)
    });
    report.Actions.Add($"Rebuilt PDV_FLST_UndeadCryptClearSites with {locations.Count} clearable undead location(s) and wired manager property.");
}

static void CheckUndeadCryptClearSites(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<LocationEntry> locations,
    AuthorReport report)
{
    var list = RequireRecord<SkyrimFormList>(index, "PDV_FLST_UndeadCryptClearSites");
    var actual = list.Items.Select(item => item.FormKey).ToList();
    if (actual.Count != locations.Count)
    {
        report.Errors.Add($"{list.EditorID} has {actual.Count} entries; expected {locations.Count}.");
    }

    for (var i = 0; i < locations.Count; i++)
    {
        if (i >= actual.Count)
        {
            report.Errors.Add($"{list.EditorID} is missing expected slot {i}: {locations[i].Label} {locations[i].FormKey}.");
            continue;
        }

        if (!actual[i].Equals(locations[i].FormKey))
        {
            report.Errors.Add($"{list.EditorID}[{i}] is {actual[i]}, expected {locations[i].Label} {locations[i].FormKey}.");
        }
    }

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");
    CheckObjectProperty(managerScript, "PDV_FLST_UndeadCryptClearSites", list.FormKey, "PDV__ManagerQuest", report);
    report.Actions.Add($"{list.EditorID} cleared-site list check complete.");
}

static void AuthorNamira(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<NamiraBoon> boons,
    AuthorReport report)
{
    foreach (var boon in boons)
    {
        var spell = RequireRecord<Spell>(index, boon.SpellEditorId);
        var effect = RequireRecord<MagicEffect>(index, boon.MagicEffectEditorId);
        if (GetArchetypeActorValue(effect) != ActorValue.HealRateMult)
        {
            throw new InvalidOperationException($"{effect.EditorID} is not a HealRateMult passive placeholder.");
        }

        spell.Description = Tx(NamiraBoon.Text);
        effect.Description = Tx(NamiraBoon.Text);
        var entries = spell.Effects.Where(entry => entry.BaseEffect.FormKey.Equals(effect.FormKey)).ToList();
        if (entries.Count == 0)
        {
            throw new InvalidOperationException($"{spell.EditorID} does not contain {effect.EditorID}.");
        }

        foreach (var entry in entries)
        {
            entry.Data ??= new EffectData();
            entry.Data.Magnitude = 0.0f;
            entry.Data.Area = 0;
            entry.Data.Duration = 0;
        }

        report.Actions.Add($"Zeroed Namira passive placeholder and refreshed copy for {spell.EditorID}.");
    }
}

static void CheckNamira(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<NamiraBoon> boons,
    AuthorReport report)
{
    foreach (var boon in boons)
    {
        var spell = RequireRecord<Spell>(index, boon.SpellEditorId);
        var effect = RequireRecord<MagicEffect>(index, boon.MagicEffectEditorId);
        if (GetArchetypeActorValue(effect) != ActorValue.HealRateMult)
        {
            report.Errors.Add($"{effect.EditorID} is not a HealRateMult passive placeholder.");
        }

        if (!StringEquals(spell.Description?.String, NamiraBoon.Text))
        {
            report.Errors.Add($"{spell.EditorID} description is not the Namira feed Health/Stamina copy.");
        }

        if (!StringEquals(effect.Description?.String, NamiraBoon.Text))
        {
            report.Errors.Add($"{effect.EditorID} description is not the Namira feed Health/Stamina copy.");
        }

        var entries = spell.Effects.Where(entry => entry.BaseEffect.FormKey.Equals(effect.FormKey)).ToList();
        if (entries.Count == 0)
        {
            report.Errors.Add($"{spell.EditorID} does not contain {effect.EditorID}.");
            continue;
        }

        foreach (var entry in entries)
        {
            if (entry.Data is null || Math.Abs(entry.Data.Magnitude) > 0.0001f)
            {
                report.Errors.Add($"{spell.EditorID} has non-zero Namira passive magnitude.");
            }
        }

        report.Actions.Add($"{spell.EditorID} Namira check complete.");
    }
}

static ActorValue? GetArchetypeActorValue(MagicEffect effect)
{
    if (effect.Archetype is MagicEffectPeakValueModArchetype peak)
    {
        return peak.ActorValue;
    }

    if (effect.Archetype is MagicEffectArchetype archetype)
    {
        return archetype.ActorValue;
    }

    return null;
}

static bool StringEquals(string? left, string right)
{
    return string.Equals(left ?? "", right, StringComparison.Ordinal);
}

static MagicEffect? FindMagicEffect(Dictionary<string, ISkyrimMajorRecordGetter> index, FormKey formKey)
{
    return index.Values.OfType<MagicEffect>().FirstOrDefault(candidate => candidate.FormKey.Equals(formKey));
}

static Spell EnsureSpellRecord(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Spell.");
        }

        return typed;
    }

    var created = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId
    };
    mod.Spells.Add(created);
    index[editorId] = created;
    return created;
}

static MagicEffect EnsureMagicEffectRecord(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        return typed;
    }

    var created = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId
    };
    mod.MagicEffects.Add(created);
    index[editorId] = created;
    return created;
}

static SkyrimFormList EnsureFormList(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not SkyrimFormList typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected FormList.");
        }

        return typed;
    }

    var created = new SkyrimFormList(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = editorId,
        FormVersion = 44
    };
    mod.FormLists.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created FormList {editorId}.");
    return created;
}

static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
{
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static void RemoveMagicEffectScript(MagicEffect effect, string scriptName)
{
    var scripts = effect.VirtualMachineAdapter?.Scripts;
    if (scripts is null)
    {
        return;
    }

    while (scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase)) is { } script)
    {
        scripts.Remove(script);
    }
}

static ScriptEntry RequireScript(Quest quest, string scriptName)
{
    return quest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase))
        ?? throw new InvalidOperationException($"{quest.EditorID} is missing VMAD script {scriptName}.");
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

static void CheckStringProperty(Dictionary<string, ScriptProperty> props, string propertyName, string expected, string ownerLabel, AuthorReport report)
{
    if (!props.TryGetValue(propertyName, out var property)
        || property is not ScriptStringProperty stringProperty
        || !string.Equals(stringProperty.Data, expected, StringComparison.Ordinal))
    {
        report.Errors.Add($"{ownerLabel} {propertyName} is not {expected}.");
    }
}

static void CheckFloatProperty(Dictionary<string, ScriptProperty> props, string propertyName, float expected, string ownerLabel, AuthorReport report)
{
    if (!props.TryGetValue(propertyName, out var property)
        || property is not ScriptFloatProperty floatProperty
        || Math.Abs(floatProperty.Data - expected) > 0.0001f)
    {
        report.Errors.Add($"{ownerLabel} {propertyName} is not {expected}.");
    }
}

static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expected, string ownerLabel, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is null)
    {
        report.Errors.Add($"{ownerLabel} property {propertyName} is missing.");
        return;
    }

    if (property is not ScriptObjectProperty objectProperty)
    {
        report.Errors.Add($"{ownerLabel} property {propertyName} is {property.GetType().Name}, expected ScriptObjectProperty.");
        return;
    }

    if (!objectProperty.Object.FormKey.Equals(expected))
    {
        report.Errors.Add($"{ownerLabel} property {propertyName} points at {objectProperty.Object.FormKey}, expected {expected}.");
        return;
    }

    report.Actions.Add($"{ownerLabel} property {propertyName} points at expected form {expected}.");
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

static ScriptFloatProperty FloatProp(string name, float value)
{
    return new ScriptFloatProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
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

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report)
{
    if (dryRun)
    {
        report.Actions.Add("DRY-RUN: parsing and record resolution complete; ESP NOT written.");
        return;
    }

    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "requiem-tail");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.requiem-tail.tmp";
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

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public bool Check { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}

sealed record CapstoneConfig(
    string RewardSpellEditorId,
    string ScriptEffectEditorId,
    string HealSpellEditorId,
    string StorageKey,
    string ScriptEffectName,
    string ScriptEffectDescription,
    string HealSpellName,
    string HealSpellDescription)
{
    public float HealAmount { get; } = 0.0f;
    public float TriggerHealthPercent { get; } = 0.20f;
    public float WatchIntervalSeconds { get; } = 0.1f;
    public float HealMagnitude { get; } = 10000.0f;
    public string NotificationText => ScriptEffectDescription;
    public string PrismaTitle => HealSpellName;
    public string PrismaText => ScriptEffectDescription;
    public string PrismaSymbol => RewardSpellEditorId.Contains("Shor", StringComparison.OrdinalIgnoreCase) ? "shor" : "journal";
    public string PrismaTone { get; } = "good";
}

sealed record BossEntry(FormKey FormKey, string Label);

sealed record LocationEntry(FormKey FormKey, string Label);

sealed record NamiraBoon(string SpellEditorId, string MagicEffectEditorId)
{
    public const string Text = "Namira's reviled hunger sustains you. Feeding on the dead restores Health and Stamina.";
}
