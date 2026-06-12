using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using SkyrimFormList = Mutagen.Bethesda.Skyrim.FormList;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_Phase20_P2ImmersiveReceivers.manifest.json";
const string defaultPlayerEvents = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV_PlayerEvents.psc";
const string defaultKidPath = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\KeywordItemDistributor\PDV_GreenPact_KID.ini";

string[] greenPactFormLists =
[
    "PDV_FLST_GreenPact_PlantFoods",
    "PDV_FLST_GreenPact_MeatFoods",
    "PDV_FLST_GreenPact_FungiFoods",
    "PDV_FLST_GreenPact_EggFoods",
    "PDV_FLST_GreenPact_InsectFoods"
];

string[] greenPactKeywords =
[
    "PDV_KW_GreenPact_Plant",
    "PDV_KW_GreenPact_Meat",
    "PDV_KW_GreenPact_Fungi",
    "PDV_KW_GreenPact_Egg",
    "PDV_KW_GreenPact_Insect"
];

string[] genericFaucetFormLists =
[
    "PDV_FLST_FaucetSkillBooks",
    "PDV_FLST_FaucetSpellTomes",
    "PDV_FLST_FaucetDaedricArtifacts",
    "PDV_FLST_FaucetRaiseUndeadEffects"
];

string[] genericFaucetReceiverQuests =
[
    "PDV__SM_CraftItem",
    "PDV__SM_NewVoicePower",
    "PDV__SM_IncreaseSkill",
    "PDV__SM_ChangeLocation",
    "PDV__SM_PickLock",
    "PDV__SM_Trespass",
    "PDV__SM_AssaultActor"
];

var skyrimMaster = ModKey.FromNameAndExtension("Skyrim.esm");
var genericFaucetFillEntries = BuildGenericFaucetFillEntries(skyrimMaster);
GenericFaucetStoryManagerNode[] genericFaucetStoryManagerNodes =
[
    new("PDV__SM_CraftItemNode", "PDV__SM_CraftItem", new FormKey(skyrimMaster, 0x039D86), new FormKey(skyrimMaster, 0x04F593)),
    new("PDV__SM_NewVoicePowerNode", "PDV__SM_NewVoicePower", new FormKey(skyrimMaster, 0x02D389), new FormKey(skyrimMaster, 0x02D38A)),
    new("PDV__SM_IncreaseSkillNode", "PDV__SM_IncreaseSkill", new FormKey(skyrimMaster, 0x02D386), new FormKey(skyrimMaster, 0x02D387)),
    new("PDV__SM_ChangeLocationNode", "PDV__SM_ChangeLocation", new FormKey(skyrimMaster, 0x01320E), new FormKey(skyrimMaster, 0x0A39C6)),
    new("PDV__SM_PickLockNode", "PDV__SM_PickLock", new FormKey(skyrimMaster, 0x05BD7B), null),
    new("PDV__SM_AssaultActorNode", "PDV__SM_AssaultActor", new FormKey(skyrimMaster, 0x02C494), new FormKey(skyrimMaster, 0x0A39C0)),
];

Dictionary<string, FormKey> genericFaucetRouterPropertyTargets = new(StringComparer.OrdinalIgnoreCase)
{
    ["ActorTypeUndead"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x013796),
    ["ActorTypeDaedra"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x013797),
    ["ActorTypeDragon"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x035D59),
    ["PDV_FLST_FaucetSkillBooks"] = FormKey.Null,
    ["PDV_FLST_FaucetSpellTomes"] = FormKey.Null,
    ["CraftingSmithingArmorTable"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x0ADB78),
    ["CraftingSmithingForge"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x088105),
    ["CraftingSmithingSharpeningWheel"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x088108),
    ["CraftingSmithingSkyforge"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x0F46CE),
    ["CraftingCookpot"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x0A5CB3),
    ["isAlchemy"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x02A40B),
    ["isEnchanting"] = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x06E2A3),
};

string[] khajiitOrganicFormLists =
[
    "PDV_FLST_AlkoshNamedDragons",
    "PDV_FLST_RajhinNotableTargets"
];

Dictionary<string, GenericFaucetEntry[]> khajiitOrganicFillEntries = new(StringComparer.OrdinalIgnoreCase)
{
    ["PDV_FLST_AlkoshNamedDragons"] =
    [
        new(new FormKey(skyrimMaster, 0x01CA05), "MQ104Dragon"),
        new(new FormKey(skyrimMaster, 0x0FAE86), "lvlMQ104Dragon"),
        new(new FormKey(skyrimMaster, 0x032D9B), "MQ106Dragon"),
        new(new FormKey(skyrimMaster, 0x0FE430), "MQResurrectDragon1"),
        new(new FormKey(skyrimMaster, 0x0FE431), "MQResurrectDragon2"),
        new(new FormKey(skyrimMaster, 0x0FE432), "MQResurrectDragon3"),
    ],
    ["PDV_FLST_RajhinNotableTargets"] =
    [
        new(new FormKey(skyrimMaster, 0x013BBD), "BalgruuftheGreater"),
        new(new FormKey(skyrimMaster, 0x01326A), "ElisifTheFair"),
        new(new FormKey(skyrimMaster, 0x01414D), "Ulfric"),
        new(new FormKey(skyrimMaster, 0x01339F), "Igmund"),
        new(new FormKey(skyrimMaster, 0x0135EB), "IdgrodRavencrone"),
        new(new FormKey(skyrimMaster, 0x013653), "Siddgeir"),
        new(new FormKey(skyrimMaster, 0x013620), "SkaldtheElder"),
        new(new FormKey(skyrimMaster, 0x01C188), "Korir"),
        new(new FormKey(skyrimMaster, 0x013366), "Laila"),
        new(new FormKey(skyrimMaster, 0x013269), "Elenwen"),
        new(new FormKey(skyrimMaster, 0x0133AF), "Ondolemar"),
        new(new FormKey(skyrimMaster, 0x013BBB), "FarengarSecretFire"),
        new(new FormKey(skyrimMaster, 0x014146), "Wuunferth"),
        new(new FormKey(skyrimMaster, 0x01338E), "Calcelmo"),
        new(new FormKey(skyrimMaster, 0x0132AA), "SybilleStentor"),
        new(new FormKey(skyrimMaster, 0x01361D), "Madena"),
        new(new FormKey(skyrimMaster, 0x0135E9), "Falion"),
        new(new FormKey(skyrimMaster, 0x01327E), "GeneralTullius"),
        new(new FormKey(skyrimMaster, 0x01336A), "Maven"),
        new(new FormKey(skyrimMaster, 0x013BB4), "OlfridBattleBorn"),
        new(new FormKey(skyrimMaster, 0x013272), "Erikur"),
        new(new FormKey(skyrimMaster, 0x01327A), "VittoriaVici"),
    ],
};

Dictionary<string, FormKey> khajiitOrganicAliasVanillaTargets = new(StringComparer.OrdinalIgnoreCase)
{
    ["ActorTypeDragon"] = new FormKey(skyrimMaster, 0x035D59),
    ["Paarthurnax"] = new FormKey(skyrimMaster, 0x03C57C),
};

CapstoneFallback[] capstoneFallbacks =
[
    new("PDV_Bless_Imperial_Akatosh_T3", "PDV.Capstone.Imperial.AkatoshSave", 90.0f),
    new("PDV_Bless_Altmer_AuriEl_T3", "PDV.Capstone.Altmer.AuriElSave", 90.0f),
    new("PDV_Bless_Nord_Shor_T3", "PDV.Capstone.Nord.ShorLastStand", 85.0f),
    new("PDV_Bless_Orc_LegionExile_T3", "PDV.Capstone.Orc.LegionHoldLine", 85.0f),
    new("PDV_Bless_Redguard_Tuwhacca_T3", "PDV.Capstone.Redguard.TuwhaccaSave", 90.0f),
    new("PDV_Bless_Khajiit_BaanDar_T3", "PDV.Capstone.Khajiit.BaanDarSlip", 75.0f),
    new("PDV_Bless_Bosmer_BanditRoad_T3", "PDV.Capstone.Bosmer.BaanDarSlip", 75.0f)
];

var dryRun = args.Contains("--dry-run");
var createMissing = args.Contains("--create-missing");
var checkFormLists = args.Contains("--check-formlists");
var inspectVmad = args.Contains("--inspect-vmad");
var wireAliasProperties = args.Contains("--wire-alias-properties");
var checkAliasProperties = args.Contains("--check-alias-properties");
var fillSourceEntries = args.Contains("--fill-source-entries");
var checkSourceFill = args.Contains("--check-source-fill");
var checkExactStageGates = args.Contains("--check-exact-stage-gates");
var checkRouteEntries = args.Contains("--check-route-entries");
var authorGreenPact = args.Contains("--author-green-pact");
var checkGreenPact = args.Contains("--check-green-pact");
var authorCapstones = args.Contains("--author-capstones");
var checkCapstones = args.Contains("--check-capstones");
var authorGenericFaucets = args.Contains("--author-generic-faucets");
var checkGenericFaucets = args.Contains("--check-generic-faucets");
var authorGenericFaucetReceivers = args.Contains("--author-generic-faucet-receivers");
var checkGenericFaucetReceivers = args.Contains("--check-generic-faucet-receivers");
var authorGenericFaucetStoryManager = args.Contains("--author-generic-faucet-story-manager");
var checkGenericFaucetStoryManager = args.Contains("--check-generic-faucet-story-manager");
var fillGenericFaucets = args.Contains("--fill-generic-faucets");
var checkGenericFaucetFill = args.Contains("--check-generic-faucet-fill");
var authorKhajiitOrganic = args.Contains("--author-khajiit-organic");
var checkKhajiitOrganic = args.Contains("--check-khajiit-organic");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);
var playerEventsPath = Path.GetFullPath(GetArg(args, "--player-events") ?? defaultPlayerEvents);
var kidPath = Path.GetFullPath(GetArg(args, "--kid") ?? defaultKidPath);

var report = new AuthorReport
{
    EspPath = espPath,
    ManifestPath = manifestPath,
    DryRun = dryRun,
    CreateMissing = createMissing,
    CheckFormLists = checkFormLists,
    InspectVmad = inspectVmad,
    WireAliasProperties = wireAliasProperties,
    CheckAliasProperties = checkAliasProperties,
    FillSourceEntries = fillSourceEntries,
    CheckSourceFill = checkSourceFill,
    CheckExactStageGates = checkExactStageGates,
    CheckRouteEntries = checkRouteEntries,
    AuthorGreenPact = authorGreenPact,
    CheckGreenPact = checkGreenPact,
    AuthorCapstones = authorCapstones,
    CheckCapstones = checkCapstones,
    FillGenericFaucets = fillGenericFaucets,
    CheckGenericFaucetFill = checkGenericFaucetFill,
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
        throw new FileNotFoundException("P2 receiver manifest not found.", manifestPath);
    }

    if (!createMissing
        && !checkFormLists
        && !inspectVmad
        && !wireAliasProperties
        && !checkAliasProperties
        && !fillSourceEntries
        && !checkSourceFill
        && !checkExactStageGates
        && !checkRouteEntries
        && !authorGreenPact
        && !checkGreenPact
        && !authorCapstones
        && !checkCapstones
        && !authorGenericFaucets
        && !checkGenericFaucets
        && !authorGenericFaucetReceivers
        && !checkGenericFaucetReceivers
        && !authorGenericFaucetStoryManager
        && !checkGenericFaucetStoryManager
        && !fillGenericFaucets
        && !checkGenericFaucetFill
        && !authorKhajiitOrganic
        && !checkKhajiitOrganic)
    {
        throw new InvalidOperationException("Specify --create-missing, --check-formlists, --inspect-vmad, --wire-alias-properties, --check-alias-properties, --fill-source-entries, --check-source-fill, --check-exact-stage-gates, --check-route-entries, --author-green-pact, --check-green-pact, --author-capstones, --check-capstones, --author-generic-faucets, --check-generic-faucets, --fill-generic-faucets, --check-generic-faucet-fill, --author-generic-faucet-receivers, --check-generic-faucet-receivers, --author-generic-faucet-story-manager, --check-generic-faucet-story-manager, --author-khajiit-organic, or --check-khajiit-organic. Use --dry-run with write modes for planning only.");
    }

    var manifest = LoadManifest(manifestPath);
    var propertyNames = BuildPropertyNames(manifest);
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (inspectVmad)
    {
        InspectPlayerAliasVmad(index, report);
        report.Status = "PASS";
    }
    else if (checkGenericFaucets)
    {
        CheckGenericFaucets(index, genericFaucetFormLists, genericFaucetRouterPropertyTargets, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Generic faucet FormList/property check failed.");
        }

        report.Status = "PASS";
    }
    else if (checkGenericFaucetFill)
    {
        CheckGenericFaucetEntries(index, genericFaucetFillEntries, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Generic faucet FormList content check failed.");
        }

        report.Status = "PASS";
    }
    else if (fillGenericFaucets)
    {
        FillGenericFaucetEntries(index, genericFaucetFillEntries, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (authorKhajiitOrganic)
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureFormLists(mod, index, allocator, khajiitOrganicFormLists, report);
        FillGenericFaucetEntries(index, khajiitOrganicFillEntries, report);
        WireKhajiitOrganicAliasProperties(index, khajiitOrganicFormLists, khajiitOrganicAliasVanillaTargets, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkKhajiitOrganic)
    {
        CheckKhajiitOrganic(index, khajiitOrganicFormLists, khajiitOrganicFillEntries, khajiitOrganicAliasVanillaTargets, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Khajiit organic-hook record check failed.");
        }

        report.Status = "PASS";
    }
    else if (authorGenericFaucets)
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureFormLists(mod, index, allocator, genericFaucetFormLists, report);
        WireGenericFaucetProperties(index, genericFaucetFormLists, genericFaucetRouterPropertyTargets, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkGenericFaucetReceivers)
    {
        CheckGenericFaucetReceivers(index, genericFaucetReceiverQuests, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Generic faucet receiver quest check failed.");
        }

        report.Status = "PASS";
    }
    else if (authorGenericFaucetReceivers)
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureGenericFaucetReceivers(mod, index, allocator, genericFaucetReceiverQuests, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkGenericFaucetStoryManager)
    {
        CheckGenericFaucetStoryManager(index, genericFaucetStoryManagerNodes, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Generic faucet Story Manager node check failed.");
        }

        report.Status = "PASS";
    }
    else if (authorGenericFaucetStoryManager)
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureGenericFaucetStoryManager(mod, index, allocator, genericFaucetStoryManagerNodes, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkCapstones)
    {
        CheckCapstoneFallbacks(index, capstoneFallbacks, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("T3 capstone fallback check failed.");
        }

        report.Status = "PASS";
    }
    else if (authorCapstones)
    {
        WireCapstoneFallbacks(mod, index, capstoneFallbacks, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkGreenPact)
    {
        CheckGreenPact(index, playerEventsPath, kidPath, greenPactFormLists, greenPactKeywords, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Green Pact tag layer check failed.");
        }

        report.Status = "PASS";
    }
    else if (authorGreenPact)
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureFormLists(mod, index, allocator, greenPactFormLists, report);
        EnsureKeywords(mod, index, allocator, greenPactKeywords, report);
        WireGreenPactAliasProperties(mod, index, greenPactFormLists, greenPactKeywords, report);
        WriteKidIfNeeded(kidPath, dryRun, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkFormLists)
    {
        CheckFormLists(index, propertyNames, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver FormList check failed.");
        }

        report.Status = "PASS";
    }
    else if (checkAliasProperties)
    {
        CheckAliasProperties(index, propertyNames, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver alias property check failed.");
        }

        report.Status = "PASS";
    }
    else if (wireAliasProperties)
    {
        CheckFormLists(index, propertyNames, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Cannot wire alias properties until all P2 FormList shells exist.");
        }

        WireAliasProperties(mod, index, propertyNames, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else if (checkSourceFill)
    {
        CheckSourceFill(index, manifest, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver source fill check failed.");
        }

        report.Status = "PASS";
    }
    else if (checkExactStageGates)
    {
        CheckExactStageGates(manifest, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver exact-stage gate check failed.");
        }

        report.Status = "PASS";
    }
    else if (checkRouteEntries)
    {
        CheckRouteEntries(manifest, playerEventsPath, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver route-entry check failed.");
        }

        report.Status = "PASS";
    }
    else if (fillSourceEntries)
    {
        FillSourceEntries(mod, index, manifest, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("P2 receiver source fill failed.");
        }

        WriteModIfNeeded(mod, espPath, dryRun, report);
        report.Status = "PASS";
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        EnsureFormLists(mod, index, allocator, propertyNames, report);
        WriteModIfNeeded(mod, espPath, dryRun, report);
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

static void CheckSourceFill(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    P2ReceiverManifest manifest,
    AuthorReport report)
{
    var groups = ValidateSourceFillEntries(manifest, requireApproved: false, report);
    if (groups.Count == 0)
    {
        report.Actions.Add("No curated P2 source fill entries are declared yet.");
        return;
    }

    foreach (var group in groups)
    {
        var formList = RequireRecord<SkyrimFormList>(index, group.Property);
        foreach (var source in group.Sources)
        {
            if (formList.Items.Any(item => item.FormKey == source.FormKey))
            {
                report.Actions.Add($"{group.Property} contains {source.Label} ({source.FormKey}).");
            }
            else
            {
                report.Errors.Add($"{group.Property} is missing {source.Label} ({source.FormKey}).");
            }
        }
    }
}

static void FillSourceEntries(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    P2ReceiverManifest manifest,
    AuthorReport report)
{
    _ = mod;
    var groups = ValidateSourceFillEntries(manifest, requireApproved: true, report);
    if (groups.Count == 0)
    {
        throw new InvalidOperationException("No approved curated P2 source fill entries are declared.");
    }

    foreach (var group in groups)
    {
        var formList = RequireRecord<SkyrimFormList>(index, group.Property);
        foreach (var source in group.Sources)
        {
            if (formList.Items.Any(item => item.FormKey == source.FormKey))
            {
                report.Actions.Add($"{group.Property} already contains {source.Label} ({source.FormKey}).");
                continue;
            }

            formList.Items.Add(source.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
            report.Actions.Add($"Added {source.Label} ({source.FormKey}) to {group.Property}.");
        }
    }
}

static List<ValidatedSourceFillGroup> ValidateSourceFillEntries(
    P2ReceiverManifest manifest,
    bool requireApproved,
    AuthorReport report)
{
    var declaredProperties = (manifest.sourceProperties ?? [])
        .Where(property => !string.IsNullOrWhiteSpace(property.property))
        .ToDictionary(
            property => property.property!,
            property => new HashSet<string>(
                property.sourceKinds ?? [],
                StringComparer.OrdinalIgnoreCase),
            StringComparer.OrdinalIgnoreCase);

    var groups = manifest.sourceFillEntries ?? [];
    var validated = new List<ValidatedSourceFillGroup>();
    var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

    foreach (var group in groups)
    {
        var propertyName = group.property?.Trim() ?? "";
        if (propertyName.Length == 0)
        {
            report.Errors.Add("A sourceFillEntries group is missing property.");
            continue;
        }

        if (!declaredProperties.TryGetValue(propertyName, out var allowedKinds))
        {
            report.Errors.Add($"Source fill group {propertyName} does not match a declared source property.");
            continue;
        }

        var sources = new List<ValidatedSourceFillEntry>();
        foreach (var source in group.sources ?? [])
        {
            var label = source.editorId?.Trim();
            if (string.IsNullOrWhiteSpace(label))
            {
                label = source.formKey?.Trim();
            }

            var sourceKind = source.sourceKind?.Trim() ?? "";
            if (sourceKind.Length == 0)
            {
                report.Errors.Add($"{propertyName} source {label ?? "(unnamed)"} is missing sourceKind.");
                continue;
            }

            if (!allowedKinds.Contains(sourceKind))
            {
                report.Errors.Add($"{propertyName} source {label ?? "(unnamed)"} uses sourceKind {sourceKind}, which is not declared for that receiver property.");
                continue;
            }

            if (!TryParseFormKey(source.formKey, out var formKey, out var parseError))
            {
                report.Errors.Add($"{propertyName} source {label ?? "(unnamed)"} has invalid formKey: {parseError}");
                continue;
            }

            var status = source.status?.Trim() ?? "";
            if (requireApproved && !string.Equals(status, "approved-for-fill", StringComparison.OrdinalIgnoreCase))
            {
                report.Errors.Add($"{propertyName} source {label ?? formKey.ToString()} must have status approved-for-fill before live fill.");
                continue;
            }

            if (requireApproved && string.IsNullOrWhiteSpace(source.rationale))
            {
                report.Errors.Add($"{propertyName} source {label ?? formKey.ToString()} needs rationale before live fill.");
                continue;
            }

            if (string.Equals(sourceKind, "quest-stage", StringComparison.OrdinalIgnoreCase)
                && (requireApproved || string.Equals(status, "approved-for-fill", StringComparison.OrdinalIgnoreCase))
                && !ValidateQuestStageSource(manifest, propertyName, source, label ?? formKey.ToString(), requireApproved, report))
            {
                continue;
            }

            var uniqueKey = $"{propertyName}|{formKey}|{sourceKind}";
            if (!seen.Add(uniqueKey))
            {
                report.Errors.Add($"{propertyName} source {label ?? formKey.ToString()} is declared more than once for {sourceKind}.");
                continue;
            }

            sources.Add(new ValidatedSourceFillEntry(
                formKey,
                label ?? formKey.ToString(),
                sourceKind));
        }

        if (sources.Count > 0)
        {
            validated.Add(new ValidatedSourceFillGroup(propertyName, sources));
        }
    }

    return validated;
}

static bool ValidateQuestStageSource(
    P2ReceiverManifest manifest,
    string propertyName,
    P2SourceFillEntry source,
    string label,
    bool requireApproved,
    AuthorReport report)
{
    var gate = manifest.questStageGate;
    if (gate is null)
    {
        report.Errors.Add($"{propertyName} quest-stage source {label} is blocked: manifest is missing questStageGate.");
        return false;
    }

    var receiverStatus = gate.receiverStatus?.Trim() ?? "";
    if (!string.Equals(receiverStatus, "exact-stage-supported", StringComparison.OrdinalIgnoreCase))
    {
        report.Errors.Add($"{propertyName} quest-stage source {label} is blocked: questStageGate.receiverStatus is {(receiverStatus.Length == 0 ? "(missing)" : receiverStatus)}, expected exact-stage-supported.");
        return false;
    }

    if (source.approvedStages is null || source.approvedStages.Count == 0)
    {
        report.Errors.Add($"{propertyName} quest-stage source {label} must declare approvedStages before any quest-stage fill.");
        return false;
    }

    if (source.approvedStages.Any(stage => stage < 0 || stage > 65535))
    {
        report.Errors.Add($"{propertyName} quest-stage source {label} has approvedStages outside the 0-65535 range.");
        return false;
    }

    if (requireApproved)
    {
        if (string.IsNullOrWhiteSpace(source.stageReadbackEvidence))
        {
            report.Errors.Add($"{propertyName} quest-stage source {label} needs stageReadbackEvidence before live fill.");
            return false;
        }

        if (string.IsNullOrWhiteSpace(source.rejectedStageContext))
        {
            report.Errors.Add($"{propertyName} quest-stage source {label} needs rejectedStageContext before live fill.");
            return false;
        }

        if (string.IsNullOrWhiteSpace(source.duplicateGuard))
        {
            report.Errors.Add($"{propertyName} quest-stage source {label} needs duplicateGuard before live fill.");
            return false;
        }
    }

    return true;
}

static void CheckExactStageGates(P2ReceiverManifest manifest, AuthorReport report)
{
    var gate = manifest.questStageGate;
    if (gate is null)
    {
        report.Errors.Add("Manifest is missing questStageGate.");
        return;
    }

    var receiverStatus = gate.receiverStatus?.Trim() ?? "";
    var approvedQuestSources = (manifest.sourceFillEntries ?? [])
        .SelectMany(group => (group.sources ?? [])
            .Where(source => string.Equals(source.sourceKind, "quest-stage", StringComparison.OrdinalIgnoreCase)
                && string.Equals(source.status, "approved-for-fill", StringComparison.OrdinalIgnoreCase))
            .Select(source => new { Group = group.property ?? "(missing property)", Source = source }))
        .ToList();

    if (approvedQuestSources.Count == 0)
    {
        report.Actions.Add($"No approved quest-stage source entries are declared. Current receiverStatus={receiverStatus}.");
        return;
    }

    if (!string.Equals(receiverStatus, "exact-stage-supported", StringComparison.OrdinalIgnoreCase))
    {
        report.Errors.Add($"Approved quest-stage entries exist, but questStageGate.receiverStatus is {(receiverStatus.Length == 0 ? "(missing)" : receiverStatus)}; expected exact-stage-supported.");
    }

    foreach (var entry in approvedQuestSources)
    {
        var label = entry.Source.editorId ?? entry.Source.formKey ?? "(unnamed source)";
        ValidateQuestStageSource(manifest, entry.Group, entry.Source, label, requireApproved: true, report);
    }

    if (report.Errors.Count == 0)
    {
        report.Actions.Add($"{approvedQuestSources.Count} approved quest-stage source entries have exact-stage gate metadata.");
    }
}

static void CheckRouteEntries(P2ReceiverManifest manifest, string playerEventsPath, AuthorReport report)
{
    if (!File.Exists(playerEventsPath))
    {
        report.Errors.Add($"PDV_PlayerEvents source not found: {playerEventsPath}");
        return;
    }

    var contract = manifest.routeContract;
    if (contract is null)
    {
        report.Errors.Add("Manifest is missing routeContract.");
    }
    else
    {
        if (!string.Equals(contract.sourceOfTruth, "routeEntries", StringComparison.OrdinalIgnoreCase))
        {
            report.Errors.Add($"routeContract.sourceOfTruth is {contract.sourceOfTruth ?? "(missing)"}, expected routeEntries.");
        }

        if (string.IsNullOrWhiteSpace(contract.verificationCommand)
            || !contract.verificationCommand.Contains("--check-route-entries", StringComparison.OrdinalIgnoreCase))
        {
            report.Errors.Add("routeContract.verificationCommand must include --check-route-entries.");
        }
    }

    var declaredProperties = (manifest.sourceProperties ?? [])
        .Where(property => !string.IsNullOrWhiteSpace(property.property))
        .ToDictionary(
            property => property.property!,
            property => new HashSet<string>(
                property.sourceKinds ?? [],
                StringComparer.OrdinalIgnoreCase),
            StringComparer.OrdinalIgnoreCase);

    var routeEntries = manifest.routeEntries ?? [];
    if (routeEntries.Count == 0)
    {
        report.Errors.Add("Manifest routeEntries is empty.");
        return;
    }

    var scriptText = File.ReadAllText(playerEventsPath);
    var seenIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    var seenRouteKeys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    var races = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    var mutualExclusionGroups = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

    foreach (var entry in routeEntries)
    {
        var label = entry.id?.Trim();
        if (string.IsNullOrWhiteSpace(label))
        {
            report.Errors.Add("A routeEntries item is missing id.");
            continue;
        }

        if (!seenIds.Add(label))
        {
            report.Errors.Add($"Route entry {label} is declared more than once.");
        }

        var propertyName = entry.property?.Trim() ?? "";
        if (propertyName.Length == 0 || !declaredProperties.TryGetValue(propertyName, out var sourceKinds))
        {
            report.Errors.Add($"Route entry {label} targets undeclared property {propertyName}.");
            continue;
        }

        var sourceKind = entry.sourceKind?.Trim() ?? "";
        if (!sourceKinds.Contains(sourceKind))
        {
            report.Errors.Add($"Route entry {label} uses sourceKind {sourceKind}, which is not declared on {propertyName}.");
        }

        if (!string.Equals(sourceKind, "quest-stage", StringComparison.OrdinalIgnoreCase))
        {
            report.Errors.Add($"Route entry {label} uses sourceKind {sourceKind}; route verification currently supports quest-stage entries only.");
        }

        if (entry.expectedFormId <= 0)
        {
            report.Errors.Add($"Route entry {label} must declare positive expectedFormId.");
        }

        if (entry.approvedStage < 0 || entry.approvedStage > 65535)
        {
            report.Errors.Add($"Route entry {label} approvedStage {entry.approvedStage} is outside 0-65535.");
        }

        var routeKey = entry.routeKey?.Trim() ?? "";
        if (routeKey.Length == 0)
        {
            report.Errors.Add($"Route entry {label} is missing routeKey.");
            continue;
        }

        if (!seenRouteKeys.Add(routeKey))
        {
            report.Errors.Add($"Route key {routeKey} is declared more than once.");
        }

        var dispatch = entry.dispatch?.Trim() ?? "";
        if (dispatch.Length == 0)
        {
            report.Errors.Add($"Route entry {label} is missing dispatch.");
        }

        foreach (var field in new[]
                 {
                     ("acceptedContext", entry.acceptedContext),
                     ("rejectedContext", entry.rejectedContext),
                     ("duplicateGuard", entry.duplicateGuard),
                     ("stageReadbackEvidence", entry.stageReadbackEvidence),
                     ("implementationStatus", entry.implementationStatus),
                     ("reviewStatus", entry.reviewStatus)
                 })
        {
            if (string.IsNullOrWhiteSpace(field.Item2))
            {
                report.Errors.Add($"Route entry {label} is missing {field.Item1}.");
            }
        }

        if (!string.IsNullOrWhiteSpace(entry.race))
        {
            races.Add(entry.race!);
        }

        if (!string.IsNullOrWhiteSpace(entry.mutualExclusionGroup))
        {
            mutualExclusionGroups.TryGetValue(entry.mutualExclusionGroup!, out var count);
            mutualExclusionGroups[entry.mutualExclusionGroup!] = count + 1;
        }

        var branchSnippet = $"ShouldRouteP2QuestStage({propertyName}, sourceQuest, {entry.expectedFormId}, {entry.approvedStage}, \"{routeKey}\", newStage)";
        if (!scriptText.Contains(branchSnippet, StringComparison.Ordinal))
        {
            report.Errors.Add($"Route entry {label} is not present in PDV_PlayerEvents: {branchSnippet}");
        }

        if (dispatch.Length > 0 && !scriptText.Contains(dispatch, StringComparison.Ordinal))
        {
            report.Errors.Add($"Route entry {label} dispatch is not present in PDV_PlayerEvents: {dispatch}");
        }
    }

    var expectedRaces = new[] { "Altmer", "Argonian", "Bosmer", "Dunmer", "Khajiit", "Nord", "Orc", "Redguard" };
    foreach (var race in expectedRaces)
    {
        if (!races.Contains(race))
        {
            report.Errors.Add($"Route entries do not cover {race}.");
        }
    }

    foreach (var pair in mutualExclusionGroups.Where(pair => pair.Value > 1))
    {
        report.Actions.Add($"Mutual exclusion group {pair.Key} has {pair.Value} route entries.");
    }

    if (report.Errors.Count == 0)
    {
        report.Actions.Add($"{routeEntries.Count} manifest route entries match PDV_PlayerEvents static quest-stage routing.");
    }
}

static bool TryParseFormKey(string? value, out FormKey formKey, out string error)
{
    formKey = default;
    error = "";
    var text = value?.Trim() ?? "";
    if (text.Length == 0)
    {
        error = "missing formKey";
        return false;
    }

    var parts = text.Split(':', 2);
    if (parts.Length != 2 || parts[0].Trim().Length == 0 || parts[1].Trim().Length == 0)
    {
        error = "expected ModName.ext:localHex";
        return false;
    }

    var modName = parts[0].Trim();
    var localHex = parts[1].Trim();
    if (localHex.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
    {
        localHex = localHex[2..];
    }

    if (localHex.Length > 8 || !localHex.All(Uri.IsHexDigit))
    {
        error = "localHex must be 1-8 hexadecimal digits";
        return false;
    }

    var localId = Convert.ToUInt32(localHex, 16);
    if (localId > 0x00FFFFFF)
    {
        error = "formKey must use a local file FormID, not a load-order FormID";
        return false;
    }

    formKey = new FormKey(ModKey.FromNameAndExtension(modName), localId);
    return true;
}

static void CheckAliasProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> propertyNames,
    AuthorReport report)
{
    var aliasScript = RequirePlayerEventsAliasScript(index);
    var properties = aliasScript.Properties
        .Where(property => !string.IsNullOrWhiteSpace(property.Name))
        .ToDictionary(property => property.Name!, StringComparer.OrdinalIgnoreCase);

    foreach (var propertyName in propertyNames)
    {
        if (!properties.TryGetValue(propertyName, out var property))
        {
            report.Errors.Add($"PDV_PlayerEvents alias property {propertyName} is missing.");
            continue;
        }

        if (property is not ScriptObjectProperty objectProperty)
        {
            report.Errors.Add($"PDV_PlayerEvents alias property {propertyName} is {property.GetType().Name}, expected ScriptObjectProperty.");
            continue;
        }

        var expected = RequireRecord<ISkyrimMajorRecordGetter>(index, propertyName);
        if (!objectProperty.Object.FormKey.Equals(expected.FormKey))
        {
            report.Errors.Add($"PDV_PlayerEvents alias property {propertyName} points at {objectProperty.Object.FormKey}, expected {expected.FormKey}.");
            continue;
        }

        report.Actions.Add($"PDV_PlayerEvents alias property {propertyName} points at {propertyName}.");
    }
}

static void WireAliasProperties(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> propertyNames,
    AuthorReport report)
{
    _ = mod;
    var aliasScript = RequirePlayerEventsAliasScript(index);
    var properties = propertyNames
        .Select(propertyName =>
        {
            var record = RequireRecord<ISkyrimMajorRecordGetter>(index, propertyName);
            return ObjectProp(propertyName, record.FormKey);
        })
        .ToArray();

    UpsertProperties(aliasScript, properties);
    report.Actions.Add($"Wired {properties.Length} P2 FormList properties on PDV_PlayerEvents alias script.");
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

static P2ReceiverManifest LoadManifest(string manifestPath)
{
    var manifest = JsonSerializer.Deserialize<P2ReceiverManifest>(File.ReadAllText(manifestPath));
    if (manifest is null)
    {
        throw new InvalidOperationException("P2 receiver manifest could not be parsed.");
    }

    if (!string.Equals(manifest.schema, "pdv.phase20.p2-immersive-receivers.v1", StringComparison.OrdinalIgnoreCase))
    {
        throw new InvalidOperationException($"Unexpected P2 receiver manifest schema: {manifest.schema ?? "(missing)"}.");
    }

    return manifest;
}

static string[] BuildPropertyNames(P2ReceiverManifest manifest)
{
    var names = (manifest.sourceProperties ?? [])
        .Select(property => property.property)
        .Where(name => !string.IsNullOrWhiteSpace(name))
        .Select(name => name!)
        .Distinct(StringComparer.OrdinalIgnoreCase)
        .OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
        .ToArray();

    if (names.Length < 17)
    {
        throw new InvalidOperationException($"Expected at least 17 P2 receiver source properties; found {names.Length}.");
    }

    foreach (var name in names)
    {
        if (!name.StartsWith("PDV_FLST_P2_", StringComparison.Ordinal))
        {
            throw new InvalidOperationException($"Receiver property {name} must be a PDV_FLST_P2_* FormList shell.");
        }
    }

    return names;
}

static void CheckFormLists(Dictionary<string, ISkyrimMajorRecordGetter> index, IEnumerable<string> propertyNames, AuthorReport report)
{
    foreach (var propertyName in propertyNames)
    {
        if (!index.TryGetValue(propertyName, out var record))
        {
            report.Errors.Add($"Missing P2 receiver FormList shell: {propertyName}");
            continue;
        }

        if (record is not SkyrimFormList)
        {
            report.Errors.Add($"{propertyName} exists as {record.GetType().Name}, expected FLST/FormList.");
            continue;
        }

        report.Actions.Add($"{propertyName} exists as FLST.");
    }
}

static void InspectPlayerAliasVmad(Dictionary<string, ISkyrimMajorRecordGetter> index, AuthorReport report)
{
    if (!index.TryGetValue("PDV__ManagerQuest", out var record) || record is not Quest quest)
    {
        throw new InvalidOperationException("PDV__ManagerQuest is missing or is not a Quest.");
    }

    var adapter = quest.VirtualMachineAdapter;
    if (adapter is null)
    {
        report.Actions.Add("PDV__ManagerQuest has no VirtualMachineAdapter.");
        return;
    }

    report.Actions.Add($"Quest VMAD type: {adapter.GetType().FullName}");
    foreach (var property in adapter.GetType().GetProperties().OrderBy(item => item.Name))
    {
        report.Actions.Add($"Quest VMAD property: {property.Name} => {property.PropertyType.FullName}");
    }

    var aliasesProperty = adapter.GetType().GetProperty("Aliases");
    var aliasesValue = aliasesProperty?.GetValue(adapter) as System.Collections.IEnumerable;
    if (aliasesValue is null)
    {
        report.Actions.Add("Quest VMAD Aliases property is missing or not enumerable.");
        return;
    }

    foreach (var aliasEntry in aliasesValue)
    {
        if (aliasEntry is null)
        {
            continue;
        }

        report.Actions.Add($"Alias VMAD entry type: {aliasEntry.GetType().FullName}");
        foreach (var property in aliasEntry.GetType().GetProperties().OrderBy(item => item.Name))
        {
            var value = property.GetValue(aliasEntry);
            report.Actions.Add($"Alias VMAD property: {property.Name} => {property.PropertyType.FullName} value={value}");
        }

        var aliasProperty = aliasEntry.GetType().GetProperty("Property")?.GetValue(aliasEntry);
        if (aliasProperty is not null)
        {
            foreach (var property in aliasProperty.GetType().GetProperties().OrderBy(item => item.Name))
            {
                var value = property.GetValue(aliasProperty);
                report.Actions.Add($"Alias ScriptObjectProperty: {property.Name} => {property.PropertyType.FullName} value={value}");
            }
        }

        var scripts = aliasEntry.GetType().GetProperty("Scripts")?.GetValue(aliasEntry) as System.Collections.IEnumerable;
        if (scripts is not null)
        {
            foreach (var script in scripts)
            {
                if (script is null)
                {
                    continue;
                }

                report.Actions.Add($"Alias script type: {script.GetType().FullName}");
                foreach (var property in script.GetType().GetProperties().OrderBy(item => item.Name))
                {
                    var value = property.GetValue(script);
                    report.Actions.Add($"Alias script property: {property.Name} => {property.PropertyType.FullName} value={value}");
                }
            }
        }
    }
}

static void EnsureFormLists(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<string> propertyNames,
    AuthorReport report)
{
    foreach (var propertyName in propertyNames)
    {
        if (index.TryGetValue(propertyName, out var existing))
        {
            if (existing is not SkyrimFormList)
            {
                throw new InvalidOperationException($"{propertyName} exists as {existing.GetType().Name}, expected FLST/FormList.");
            }

            report.Actions.Add($"Verified existing P2 receiver FormList {propertyName}.");
            continue;
        }

        var formList = new SkyrimFormList(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            FormVersion = 44,
            EditorID = propertyName
        };
        mod.FormLists.Add(formList);
        index[propertyName] = formList;
        report.Actions.Add($"Created empty P2 receiver FormList {propertyName}.");
    }
}

static void EnsureKeywords(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<string> keywordNames,
    AuthorReport report)
{
    foreach (var keywordName in keywordNames)
    {
        if (index.TryGetValue(keywordName, out var existing))
        {
            if (existing is not Keyword)
            {
                throw new InvalidOperationException($"{keywordName} exists as {existing.GetType().Name}, expected KYWD/Keyword.");
            }

            report.Actions.Add($"Verified existing Green Pact keyword {keywordName}.");
            continue;
        }

        var keyword = new Keyword(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            FormVersion = 44,
            EditorID = keywordName
        };
        mod.Keywords.Add(keyword);
        index[keywordName] = keyword;
        report.Actions.Add($"Created Green Pact keyword {keywordName}.");
    }
}

static void WireGreenPactAliasProperties(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> formListNames,
    IEnumerable<string> keywordNames,
    AuthorReport report)
{
    _ = mod;
    var aliasScript = RequirePlayerEventsAliasScript(index);
    var properties = formListNames.Concat(keywordNames)
        .Select(propertyName =>
        {
            var record = RequireRecord<ISkyrimMajorRecordGetter>(index, propertyName);
            return ObjectProp(propertyName, record.FormKey);
        })
        .ToArray();

    UpsertProperties(aliasScript, properties);
    report.Actions.Add($"Wired {properties.Length} Green Pact properties on PDV_PlayerEvents alias script.");
}

static void WireKhajiitOrganicAliasProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> formListNames,
    Dictionary<string, FormKey> vanillaTargets,
    AuthorReport report)
{
    var aliasScript = RequirePlayerEventsAliasScript(index);
    var properties = formListNames
        .Select(propertyName => (ScriptProperty)ObjectProp(propertyName, RequireRecord<ISkyrimMajorRecordGetter>(index, propertyName).FormKey))
        .Concat(vanillaTargets.OrderBy(pair => pair.Key).Select(pair => (ScriptProperty)ObjectProp(pair.Key, pair.Value)))
        .ToArray();

    UpsertProperties(aliasScript, properties);
    report.Actions.Add($"Wired {properties.Length} Khajiit organic-hook properties on PDV_PlayerEvents alias script.");
}

static void CheckKhajiitOrganic(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> formListNames,
    IReadOnlyDictionary<string, GenericFaucetEntry[]> entriesByList,
    Dictionary<string, FormKey> vanillaTargets,
    AuthorReport report)
{
    CheckGenericFaucetEntries(index, entriesByList, report);

    var aliasScript = RequirePlayerEventsAliasScript(index);
    foreach (var formListName in formListNames)
    {
        if (!index.TryGetValue(formListName, out var record))
        {
            report.Errors.Add($"FormList {formListName} is missing.");
            continue;
        }

        CheckObjectProperty(aliasScript, formListName, record.FormKey, "PDV_PlayerEvents alias", report);
    }

    foreach (var pair in vanillaTargets.OrderBy(item => item.Key))
    {
        CheckObjectProperty(aliasScript, pair.Key, pair.Value, "PDV_PlayerEvents alias", report);
    }
}

static void WireGenericFaucetProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> formListNames,
    Dictionary<string, FormKey> routerPropertyTargets,
    AuthorReport report)
{
    var router = RequireRecord<Quest>(index, "PDV_ActionRouter");
    WireQuestScript(router, "PDV_ActionRouter", BuildGenericFaucetRouterProperties(index, routerPropertyTargets));
    report.Actions.Add($"Wired {routerPropertyTargets.Count} generic faucet properties on PDV_ActionRouter.");

    var aliasScript = RequirePlayerEventsAliasScript(index);
    var aliasProperties = formListNames
        .Select(propertyName =>
        {
            var record = RequireRecord<ISkyrimMajorRecordGetter>(index, propertyName);
            return ObjectProp(propertyName, record.FormKey);
        })
        .ToArray();
    UpsertProperties(aliasScript, aliasProperties);
    report.Actions.Add($"Wired {aliasProperties.Length} generic faucet FormList properties on PDV_PlayerEvents alias script.");
}

static ScriptProperty[] BuildGenericFaucetRouterProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    Dictionary<string, FormKey> routerPropertyTargets)
{
    return routerPropertyTargets
        .Select(pair =>
        {
            var formKey = pair.Value;
            if (formKey.Equals(FormKey.Null))
            {
                formKey = RequireRecord<ISkyrimMajorRecordGetter>(index, pair.Key).FormKey;
            }

            return (ScriptProperty)ObjectProp(pair.Key, formKey);
        })
        .ToArray();
}

static void CheckGenericFaucets(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> formListNames,
    Dictionary<string, FormKey> routerPropertyTargets,
    AuthorReport report)
{
    foreach (var formListName in formListNames)
    {
        if (!index.TryGetValue(formListName, out var record))
        {
            report.Errors.Add($"Missing generic faucet FormList: {formListName}");
        }
        else if (record is not SkyrimFormList)
        {
            report.Errors.Add($"{formListName} exists as {record.GetType().Name}, expected FLST/FormList.");
        }
        else
        {
            report.Actions.Add($"{formListName} exists as FLST.");
        }
    }

    var router = RequireRecord<Quest>(index, "PDV_ActionRouter");
    var routerScript = router.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV_ActionRouter", StringComparison.OrdinalIgnoreCase));
    if (routerScript is null)
    {
        report.Errors.Add("PDV_ActionRouter is missing its PDV_ActionRouter VMAD script.");
    }
    else
    {
        foreach (var pair in routerPropertyTargets)
        {
            var expected = pair.Value.Equals(FormKey.Null)
                ? RequireRecord<ISkyrimMajorRecordGetter>(index, pair.Key).FormKey
                : pair.Value;
            CheckObjectProperty(routerScript, pair.Key, expected, "PDV_ActionRouter", report);
        }
    }

    var aliasScript = RequirePlayerEventsAliasScript(index);
    foreach (var formListName in formListNames)
    {
        var expected = RequireRecord<ISkyrimMajorRecordGetter>(index, formListName);
        CheckObjectProperty(aliasScript, formListName, expected.FormKey, "PDV_PlayerEvents alias", report);
    }
}

static void FillGenericFaucetEntries(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyDictionary<string, GenericFaucetEntry[]> entriesByList,
    AuthorReport report)
{
    foreach (var pair in entriesByList)
    {
        var formList = RequireRecord<SkyrimFormList>(index, pair.Key);
        var expected = pair.Value.Select(entry => entry.FormKey).ToHashSet();
        var existing = formList.Items.Select(item => item.FormKey).ToHashSet();

        foreach (var entry in pair.Value)
        {
            if (existing.Contains(entry.FormKey))
            {
                report.Actions.Add($"{pair.Key} already contains {entry.EditorId} ({entry.FormKey}).");
                continue;
            }

            formList.Items.Add(entry.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
            existing.Add(entry.FormKey);
            report.Actions.Add($"Added {entry.EditorId} ({entry.FormKey}) to {pair.Key}.");
        }

        foreach (var stale in existing.Except(expected).OrderBy(item => item.ToString()).ToArray())
        {
            foreach (var staleItem in formList.Items.Where(item => item.FormKey == stale).ToArray())
            {
                formList.Items.Remove(staleItem);
            }

            report.Actions.Add($"Removed unexpected generic faucet entry {stale} from {pair.Key}.");
        }
    }
}

static void CheckGenericFaucetEntries(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyDictionary<string, GenericFaucetEntry[]> entriesByList,
    AuthorReport report)
{
    foreach (var pair in entriesByList)
    {
        var formList = RequireRecord<SkyrimFormList>(index, pair.Key);
        var expected = pair.Value.Select(entry => entry.FormKey).ToArray();
        var expectedSet = expected.ToHashSet();
        var actual = formList.Items.Select(item => item.FormKey).ToArray();
        var actualSet = actual.ToHashSet();

        if (expectedSet.Count != expected.Length)
        {
            report.Errors.Add($"{pair.Key} expected contract contains duplicate FormKeys.");
        }

        foreach (var duplicate in actual.GroupBy(item => item).Where(group => group.Count() > 1).Select(group => group.Key))
        {
            report.Errors.Add($"{pair.Key} contains duplicate entry {duplicate}.");
        }

        foreach (var entry in pair.Value)
        {
            if (!actualSet.Contains(entry.FormKey))
            {
                report.Errors.Add($"{pair.Key} is missing {entry.EditorId} ({entry.FormKey}).");
            }
        }

        foreach (var extra in actualSet.Except(expectedSet).OrderBy(item => item.ToString()))
        {
            report.Errors.Add($"{pair.Key} contains unexpected entry {extra}.");
        }

        if (actualSet.SetEquals(expectedSet) && actual.Length == expected.Length)
        {
            report.Actions.Add($"{pair.Key} has exact generic faucet fill: {expected.Length} entries.");
        }
    }
}

static IReadOnlyDictionary<string, GenericFaucetEntry[]> BuildGenericFaucetFillEntries(ModKey skyrimMaster)
{
    FormKey F(uint id) => new(skyrimMaster, id);
    GenericFaucetEntry E(uint id, string editorId) => new(F(id), editorId);

    return new Dictionary<string, GenericFaucetEntry[]>(StringComparer.OrdinalIgnoreCase)
    {
        ["PDV_FLST_FaucetSkillBooks"] =
        [
            E(0x01AFC4, "SkillAlchemy1"),
            E(0x01AFC5, "SkillAlchemy2"),
            E(0x01AFC6, "SkillAlchemy3"),
            E(0x01AFC7, "SkillAlchemy4"),
            E(0x01AFC8, "SkillAlchemy5"),
            E(0x01AFC9, "SkillAlteration1"),
            E(0x01B236, "SkillAlteration2"),
            E(0x01AFCB, "SkillAlteration3"),
            E(0x01AFCC, "SkillAlteration4"),
            E(0x01AFCD, "SkillAlteration5"),
            E(0x01AFDD, "SkillBlock1"),
            E(0x01AFDE, "SkillBlock2"),
            E(0x01AFDF, "SkillBlock3"),
            E(0x01AFE0, "SkillBlock4"),
            E(0x02F83C, "SkillBlock5"),
            E(0x01AFE7, "SkillConjuration1"),
            E(0x01AFE8, "SkillConjuration2"),
            E(0x01AFE9, "SkillConjuration3"),
            E(0x01AFEA, "SkillConjuration4"),
            E(0x01AFEB, "SkillConjuration5"),
            E(0x01AFEC, "SkillDestruction1"),
            E(0x01AFED, "SkillDestruction2"),
            E(0x01AFEE, "SkillDestruction3"),
            E(0x01AFEF, "SkillDestruction4"),
            E(0x01AFF0, "SkillDestruction5"),
            E(0x02F837, "SkillEnchanting1"),
            E(0x02F838, "SkillEnchanting2"),
            E(0x02F839, "SkillEnchanting3"),
            E(0x02F83A, "SkillEnchanting4"),
            E(0x02F83B, "SkillEnchanting5"),
            E(0x01AFF6, "SkillHeavyArmor1"),
            E(0x01AFF7, "SkillHeavyArmor2"),
            E(0x01AFF8, "SkillHeavyArmor3"),
            E(0x01AFF9, "SkillHeavyArmor4"),
            E(0x01AFFA, "SkillHeavyArmor5"),
            E(0x01B00F, "SkillIllusion1"),
            E(0x01B010, "SkillIllusion2"),
            E(0x01B011, "SkillIllusion3"),
            E(0x01B012, "SkillIllusion4"),
            E(0x01B013, "SkillIllusion5"),
            E(0x01B000, "SkillLightArmor1"),
            E(0x01B001, "SkillLightArmor2"),
            E(0x01B002, "SkillLightArmor3"),
            E(0x01B003, "SkillLightArmor4"),
            E(0x01B004, "SkillLightArmor5"),
            E(0x01B019, "SkillLockpicking1"),
            E(0x01B01A, "SkillLockpicking2"),
            E(0x01B01B, "SkillLockpicking3"),
            E(0x01B01C, "SkillLockpicking4"),
            E(0x01B01D, "SkillLockpicking5"),
            E(0x01B005, "SkillMarksman1"),
            E(0x01B26D, "SkillMarksman2"),
            E(0x01B007, "SkillMarksman3"),
            E(0x01B008, "SkillMarksman4"),
            E(0x01B009, "SkillMarksman5"),
            E(0x01AFE3, "SkillOneHanded1"),
            E(0x01AFD9, "SkillOneHanded2"),
            E(0x01AFDA, "SkillOneHanded3"),
            E(0x01AFE4, "SkillOneHanded4"),
            E(0x01AFE6, "SkillOneHanded5"),
            E(0x01B022, "SkillPickpocket1"),
            E(0x01AFBF, "SkillPickpocket2"),
            E(0x01ACE6, "SkillPickpocket3"),
            E(0x01AFD6, "SkillPickpocket4"),
            E(0x02F836, "SkillPickpocket5"),
            E(0x01B014, "SkillRestoration1"),
            E(0x01B015, "SkillRestoration2"),
            E(0x01B016, "SkillRestoration3"),
            E(0x01B017, "SkillRestoration4"),
            E(0x01B018, "SkillRestoration5"),
            E(0x01AFCE, "SkillSmithing1"),
            E(0x01AFCF, "SkillSmithing2"),
            E(0x01AFD0, "SkillSmithing3"),
            E(0x01AFD1, "SkillSmithing4"),
            E(0x01AFD2, "SkillSmithing5"),
            E(0x01B276, "SkillSneak1"),
            E(0x01B01F, "SkillSneak2"),
            E(0x01B020, "SkillSneak3"),
            E(0x01B021, "SkillSneak4"),
            E(0x01AFD5, "SkillSneak5"),
            E(0x01B00D, "SkillSpeechcraft1"),
            E(0x01B00E, "SkillSpeechcraft2"),
            E(0x01B025, "SkillSpeechcraft3"),
            E(0x01B00A, "SkillSpeechcraft4"),
            E(0x01B023, "SkillSpeechcraft5"),
            E(0x01AFD8, "SkillTwoHanded1"),
            E(0x01AFE2, "SkillTwoHanded2"),
            E(0x01AFE5, "SkillTwoHanded3"),
            E(0x01AFDB, "SkillTwoHanded4"),
            E(0x01AFDC, "SkillTwoHanded5"),
        ],
        ["PDV_FLST_FaucetSpellTomes"] =
        [
            E(0x09CD51, "SpellTomeFlames"),
            E(0x09CD52, "SpellTomeFrostbite"),
            E(0x09CD53, "SpellTomeSparks"),
            E(0x09CD54, "SpellTomeSoulTrap"),
            E(0x09E2A7, "SpellTomeCandlelight"),
            E(0x09E2A8, "SpellTomeOakflesh"),
            E(0x09E2A9, "SpellTomeBoundSword"),
            E(0x09E2AA, "SpellTomeRaiseZombie"),
            E(0x09E2AB, "SpellTomeConjureFamiliar"),
            E(0x09E2AC, "SpellTomeFury"),
            E(0x09E2AD, "SpellTomeCourage"),
            E(0x09E2AE, "SpellTomeLesserWard"),
            E(0x09E2AF, "SpellTomeHealing"),
            E(0x0A26E2, "SpellTomeMagelight"),
            E(0x0A26E3, "SpellTomeStoneflesh"),
            E(0x0A26E4, "SpellTomeIronflesh"),
            E(0x0A26E5, "SpellTomeTelekinesis"),
            E(0x0A26E6, "SpellTomeWaterbreathing"),
            E(0x0A26E7, "SpellTomeDetectLife"),
            E(0x0A26E8, "SpellTomeParalyze"),
            E(0x0A26E9, "SpellTomeEbonyflesh"),
            E(0x0A26EA, "SpellTomeDetectUndead"),
            E(0x0A26EB, "SpellTomeReanimateCorpse"),
            E(0x0A26EC, "SpellTomeConjureFlameAtronach"),
            E(0x0A26ED, "SpellTomeBoundBattleaxe"),
            E(0x0A26EE, "SpellTomeBanishDaedra"),
            E(0x0A26EF, "SpellTomeConjureFrostAtronach"),
            E(0x0A26F0, "SpellTomeConjureStormAtronach"),
            E(0x0A26F1, "SpellTomeBoundBow"),
            E(0x0A26F2, "SpellTomeRevenant"),
            E(0x0A26F6, "SpellTomeCommandDaedra"),
            E(0x0A26F7, "SpellTomeDreadZombie"),
            E(0x0A26F8, "SpellTomeExpelDaedra"),
            E(0x0A26F9, "SpellTomeDeadThrall"),
            E(0x0A26FA, "SpellTomeFlameThrall"),
            E(0x0A26FB, "SpellTomeFrostThrall"),
            E(0x0A26FC, "SpellTomeStormThrall"),
            E(0x0A26FD, "SpellTomeFirebolt"),
            E(0x0A26FE, "SpellTomeIceSpike"),
            E(0x0A26FF, "SpellTomeLightningBolt"),
            E(0x0A2700, "SpellTomeFireRune"),
            E(0x0A2701, "SpellTomeFrostRune"),
            E(0x0A2702, "SpellTomeShockRune"),
            E(0x0A2703, "SpellTomeFlameCloak"),
            E(0x0A2704, "SpellTomeFrostCloak"),
            E(0x0A2705, "SpellTomeLightningCloak"),
            E(0x0A2706, "SpellTomeFireball"),
            E(0x0A2707, "SpellTomeIceStorm"),
            E(0x0A2708, "SpellTomeChainLightning"),
            E(0x0A2709, "SpellTomeWallOfFlames"),
            E(0x0A270A, "SpellTomeWallOfFrost"),
            E(0x0A270B, "SpellTomeWallOfStorms"),
            E(0x0A270C, "SpellTomeFireStorm"),
            E(0x0A270D, "SpellTomeBlizzard"),
            E(0x0A270E, "SpellTomeLightningStorm"),
            E(0x0A270F, "SpellTomeMuffle"),
            E(0x0A2711, "SpellTomeCalm"),
            E(0x0A2712, "SpellTomeFear"),
            E(0x0A2713, "SpellTomeRally"),
            E(0x0A2714, "SpellTomeFrenzy"),
            E(0x0A2715, "SpellTomeInvisibility"),
            E(0x0A2717, "SpellTomePacify"),
            E(0x0A2718, "SpellTomeRout"),
            E(0x0A2719, "SpellTomeMayhem"),
            E(0x0A271A, "SpellTomeHarmony"),
            E(0x0A271B, "SpellTomeCallToArms"),
            E(0x0A271C, "SpellTomeHysteria"),
            E(0x0A271D, "SpellTomeFastHealing"),
            E(0x0A271E, "SpellTomeHealingHands"),
            E(0x0A271F, "SpellTomeTurnLesserUndead"),
            E(0x0A2720, "SpellTomeSteadfastWard"),
            E(0x0A2721, "SpellTomeTurnUndead"),
            E(0x0A2722, "SpellTomeGreaterWard"),
            E(0x0A2725, "SpellTomeRepelLesserUndead"),
            E(0x0A2726, "SpellTomeRepelUndead"),
            E(0x0A2727, "SpellTomeHealOther"),
            E(0x0A2728, "SpellTomeCircleOfProtection"),
            E(0x0A2729, "SpellTomeTurnGreaterUndead"),
            E(0x0D2B4E, "SpellTomeDragonhide"),
            E(0x0DD643, "SpellTomeGrandHealing"),
            E(0x0DD646, "SpellTomeMassParalysis"),
            E(0x0DD647, "SpellTomeBaneOfTheUndead"),
            E(0x0F4997, "DunLabyrinthianSpellTomeEquilibrium"),
            E(0x0FDE7B, "SpellTomeGuardianCircle"),
            E(0x0FF7D1, "SpellTomeClairvoyance"),
            E(0x109112, "SpellTomeTransmuteOreMineral"),
            E(0x10F64D, "SpellTomeCloseWounds"),
            E(0x10F7F3, "SpellTomeIcySpear"),
            E(0x10F7F4, "SpellTomeIncinerate"),
            E(0x10F7F5, "SpellTomeThunderbolt"),
            E(0x10FD60, "SpellTomeConjureDremoraLord"),
            E(0x0B45F7, "dunHighGateSpellTomeFlamingFamiliar"),
            E(0x0B3165, "dunTrevasSpellTomeSpectralArrow"),
        ],
        ["PDV_FLST_FaucetRaiseUndeadEffects"] =
        [
            E(0x016B4B, "ReanimateFFTargetActor0"),
            E(0x016C0F, "ReanimateFFTargetActor25"),
            E(0x016C3B, "ReanimateFFTargetActor50"),
            E(0x016C3D, "ReanimateFFTargetActor75"),
            E(0x07E8E0, "ReanimateThrallFFAimed"),
            E(0x096D0B, "ReanimateFFAimed25"),
            E(0x096D0C, "ReanimateFFAimed50"),
            E(0x096D0D, "ReanimateFFAimed75"),
        ],
        ["PDV_FLST_FaucetDaedricArtifacts"] =
        [
            E(0x01A332, "DA04OghmaInfinium"),
            E(0x02AC60, "DA05HircinesRing"),
            E(0x02AC61, "DA05SaviorsHide"),
            E(0x02ACD2, "DA06Volendrung"),
            E(0x02C37B, "DA11RingofNamira"),
            E(0x035066, "DA16SkullofCorruption"),
            E(0x03A070, "TG08SkeletonKey"),
            E(0x045F96, "DA13Spellbreaker"),
            E(0x04A38F, "DA08EbonyBlade"),
            E(0x04E4EE, "DA09Dawnbreaker"),
            E(0x052794, "DA02Armor"),
            E(0x063B27, "DA01SoulGemAzurasStar"),
            E(0x063B29, "DA01SoulGemBlackStar"),
            E(0x0240D2, "DA07MehrunesRazor"),
            E(0x0233E3, "DA10MaceofMolagBal"),
            E(0x01CB36, "DA14SanguineRose"),
            E(0x02AC6F, "DA15Wabbajack"),
            E(0x0F82FE, "DA05HircinesRingCursed"),
            E(0x0F6D1A, "DA02EbonyMail"),
        ],
    };
}

static void EnsureGenericFaucetReceivers(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<string> receiverQuestNames,
    AuthorReport report)
{
    var router = RequireRecord<Quest>(index, "PDV_ActionRouter");
    foreach (var receiverQuestName in receiverQuestNames)
    {
        var receiver = EnsureReceiverQuest(mod, index, allocator, receiverQuestName);
        WireQuestScript(receiver, receiverQuestName, new ScriptProperty[]
        {
            ObjectProp("PDV_Router", router.FormKey)
        });
        report.Actions.Add($"Ensured receiver quest {receiverQuestName} with PDV_Router property.");
    }
}

static Quest EnsureReceiverQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId)
{
    Quest quest;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest typed)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected QUST/Quest.");
        }

        quest = typed;
    }
    else
    {
        quest = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = editorId
        };
        mod.Quests.Add(quest);
        index[editorId] = quest;
    }

    quest.EditorID = editorId;
    quest.Name = Tx(editorId);
    quest.FormVersion = 44;
    quest.QuestFormVersion = 65;
    quest.Type = Quest.TypeEnum.None;
    quest.Priority = 0;
    quest.Flags &= ~Quest.Flag.StartGameEnabled;
    return quest;
}

static void CheckGenericFaucetReceivers(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<string> receiverQuestNames,
    AuthorReport report)
{
    var router = RequireRecord<Quest>(index, "PDV_ActionRouter");
    foreach (var receiverQuestName in receiverQuestNames)
    {
        if (!index.TryGetValue(receiverQuestName, out var record))
        {
            report.Errors.Add($"Missing generic faucet receiver quest: {receiverQuestName}");
            continue;
        }

        if (record is not Quest quest)
        {
            report.Errors.Add($"{receiverQuestName} exists as {record.GetType().Name}, expected QUST/Quest.");
            continue;
        }

        if (quest.Flags.HasFlag(Quest.Flag.StartGameEnabled))
        {
            report.Errors.Add($"{receiverQuestName} must not be Start Game Enabled.");
        }
        else
        {
            report.Actions.Add($"{receiverQuestName} is not Start Game Enabled.");
        }

        var script = quest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, receiverQuestName, StringComparison.OrdinalIgnoreCase));
        if (script is null)
        {
            report.Errors.Add($"{receiverQuestName} is missing script {receiverQuestName}.");
            continue;
        }

        CheckObjectProperty(script, "PDV_Router", router.FormKey, receiverQuestName, report);
    }
}

static void EnsureGenericFaucetStoryManager(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    IEnumerable<GenericFaucetStoryManagerNode> nodes,
    AuthorReport report)
{
    foreach (var nodeSpec in nodes)
    {
        var receiver = RequireRecord<Quest>(index, nodeSpec.ReceiverQuestEditorId);
        StoryManagerQuestNode node;
        if (index.TryGetValue(nodeSpec.NodeEditorId, out var existing))
        {
            if (existing is not StoryManagerQuestNode typed)
            {
                throw new InvalidOperationException($"{nodeSpec.NodeEditorId} exists as {existing.GetType().Name}, expected SMQN/StoryManagerQuestNode.");
            }

            node = typed;
        }
        else
        {
            node = new StoryManagerQuestNode(allocator.Next(), SkyrimRelease.SkyrimSE);
            mod.StoryManagerQuestNodes.Add(node);
            index[nodeSpec.NodeEditorId] = node;
        }

        node.EditorID = nodeSpec.NodeEditorId;
        node.FormVersion = 44;
        node.Parent = nodeSpec.Parent.ToNullableLink<IAStoryManagerNodeGetter>();
        if (nodeSpec.PreviousSibling is { } previousSibling)
        {
            node.PreviousSibling = previousSibling.ToNullableLink<IAStoryManagerNodeGetter>();
        }
        node.Flags = 0;
        node.QuestFlags = StoryManagerQuestNode.QuestFlag.SharesEvent;
        node.MaxConcurrentQuests = 0;
        node.Quests.Clear();
        node.Quests.Add(new StoryManagerQuest
        {
            Quest = receiver.FormKey.ToNullableLink<IQuestGetter>()
        });
        report.Actions.Add($"Ensured Story Manager node {nodeSpec.NodeEditorId} -> {nodeSpec.ReceiverQuestEditorId} with SharesEvent.");
    }

    // Trespass: vanilla Skyrim.esm has ~24 Story Manager event roots but NONE of type
    // TrespassActorEvent, so there is no parent to share. TrespassActorEvent IS a valid
    // engine event type (StoryManagerEventNode.Types), so create the event root in the
    // framework plugin (parented at the SM root 00005B, mirroring AssaultActorEvent), then
    // attach the PDV__SM_Trespass receiver node under it with Shares Event. The receiver
    // fragment filters to the player trespasser, so no node-level conditions are needed.
    var trespassReceiver = RequireRecord<Quest>(index, "PDV__SM_Trespass");
    var storyManagerRoot = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x00005B);

    StoryManagerEventNode trespassEvent;
    if (index.TryGetValue("PDV__SM_TrespassEvent", out var existingTrespassEvent))
    {
        if (existingTrespassEvent is not StoryManagerEventNode typedTrespassEvent)
        {
            throw new InvalidOperationException($"PDV__SM_TrespassEvent exists as {existingTrespassEvent.GetType().Name}, expected SMEN/StoryManagerEventNode.");
        }

        trespassEvent = typedTrespassEvent;
    }
    else
    {
        trespassEvent = new StoryManagerEventNode(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.StoryManagerEventNodes.Add(trespassEvent);
        index["PDV__SM_TrespassEvent"] = trespassEvent;
    }

    trespassEvent.EditorID = "PDV__SM_TrespassEvent";
    trespassEvent.FormVersion = 44;
    trespassEvent.Type = StoryManagerEventNode.Types.TrespassActorEvent;
    trespassEvent.Parent = storyManagerRoot.ToNullableLink<IAStoryManagerNodeGetter>();
    trespassEvent.Flags = 0;
    trespassEvent.MaxConcurrentQuests = 0;

    StoryManagerQuestNode trespassNode;
    if (index.TryGetValue("PDV__SM_TrespassNode", out var existingTrespassNode))
    {
        if (existingTrespassNode is not StoryManagerQuestNode typedTrespassNode)
        {
            throw new InvalidOperationException($"PDV__SM_TrespassNode exists as {existingTrespassNode.GetType().Name}, expected SMQN/StoryManagerQuestNode.");
        }

        trespassNode = typedTrespassNode;
    }
    else
    {
        trespassNode = new StoryManagerQuestNode(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.StoryManagerQuestNodes.Add(trespassNode);
        index["PDV__SM_TrespassNode"] = trespassNode;
    }

    trespassNode.EditorID = "PDV__SM_TrespassNode";
    trespassNode.FormVersion = 44;
    trespassNode.Parent = trespassEvent.FormKey.ToNullableLink<IAStoryManagerNodeGetter>();
    trespassNode.Flags = 0;
    trespassNode.QuestFlags = StoryManagerQuestNode.QuestFlag.SharesEvent;
    trespassNode.MaxConcurrentQuests = 0;
    trespassNode.Quests.Clear();
    trespassNode.Quests.Add(new StoryManagerQuest
    {
        Quest = trespassReceiver.FormKey.ToNullableLink<IQuestGetter>()
    });
    report.Actions.Add("Ensured Trespass SMEN root PDV__SM_TrespassEvent (Type=TrespassActorEvent) + node PDV__SM_TrespassNode -> PDV__SM_Trespass with SharesEvent.");
}

static void CheckGenericFaucetStoryManager(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<GenericFaucetStoryManagerNode> nodes,
    AuthorReport report)
{
    foreach (var nodeSpec in nodes)
    {
        var receiver = RequireRecord<Quest>(index, nodeSpec.ReceiverQuestEditorId);
        if (!index.TryGetValue(nodeSpec.NodeEditorId, out var record))
        {
            report.Errors.Add($"Missing Story Manager quest node: {nodeSpec.NodeEditorId}");
            continue;
        }

        if (record is not StoryManagerQuestNode node)
        {
            report.Errors.Add($"{nodeSpec.NodeEditorId} exists as {record.GetType().Name}, expected SMQN/StoryManagerQuestNode.");
            continue;
        }

        if (!node.Parent.FormKey.Equals(nodeSpec.Parent))
        {
            report.Errors.Add($"{nodeSpec.NodeEditorId} parent is {node.Parent.FormKey}, expected {nodeSpec.Parent}.");
        }

        if (nodeSpec.PreviousSibling is { } previousSibling)
        {
            if (node.PreviousSibling is null || !node.PreviousSibling.FormKey.Equals(previousSibling))
            {
                report.Errors.Add($"{nodeSpec.NodeEditorId} previous sibling is {node.PreviousSibling?.FormKey.ToString() ?? "(none)"}, expected {previousSibling}.");
            }
        }
        else if (node.PreviousSibling is not null && !node.PreviousSibling.IsNull)
        {
            report.Errors.Add($"{nodeSpec.NodeEditorId} previous sibling is {node.PreviousSibling.FormKey}, expected none.");
        }

        if (!node.QuestFlags.HasFlag(StoryManagerQuestNode.QuestFlag.SharesEvent))
        {
            report.Errors.Add($"{nodeSpec.NodeEditorId} is missing SharesEvent.");
        }

        var questTargets = node.Quests.Select(quest => quest.Quest.FormKey).ToArray();
        if (!questTargets.Contains(receiver.FormKey))
        {
            report.Errors.Add($"{nodeSpec.NodeEditorId} does not point at receiver quest {nodeSpec.ReceiverQuestEditorId} ({receiver.FormKey}).");
        }

        report.Actions.Add($"{nodeSpec.NodeEditorId} points at {nodeSpec.ReceiverQuestEditorId} with SharesEvent.");
    }

    if (!index.TryGetValue("PDV__SM_TrespassEvent", out var trespassEventRecord) || trespassEventRecord is not StoryManagerEventNode trespassEventTyped)
    {
        report.Errors.Add("PDV__SM_TrespassEvent SMEN root is missing.");
    }
    else if (trespassEventTyped.Type != StoryManagerEventNode.Types.TrespassActorEvent)
    {
        report.Errors.Add($"PDV__SM_TrespassEvent has Type {trespassEventTyped.Type}, expected TrespassActorEvent.");
    }
    else if (!index.TryGetValue("PDV__SM_TrespassNode", out var trespassNodeRecord) || trespassNodeRecord is not StoryManagerQuestNode trespassNodeTyped)
    {
        report.Errors.Add("PDV__SM_TrespassNode SMQN is missing.");
    }
    else if (!trespassNodeTyped.QuestFlags.HasFlag(StoryManagerQuestNode.QuestFlag.SharesEvent))
    {
        report.Errors.Add("PDV__SM_TrespassNode is missing SharesEvent.");
    }
    else
    {
        report.Actions.Add("PDV__SM_TrespassNode points at PDV__SM_Trespass under PDV__SM_TrespassEvent (TrespassActorEvent) with SharesEvent.");
    }
}

static void CheckGreenPact(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string playerEventsPath,
    string kidPath,
    IEnumerable<string> formListNames,
    IEnumerable<string> keywordNames,
    AuthorReport report)
{
    foreach (var formListName in formListNames)
    {
        if (!index.TryGetValue(formListName, out var record))
        {
            report.Errors.Add($"Missing Green Pact FormList: {formListName}");
        }
        else if (record is not SkyrimFormList)
        {
            report.Errors.Add($"{formListName} exists as {record.GetType().Name}, expected FLST/FormList.");
        }
        else
        {
            report.Actions.Add($"{formListName} exists as FLST.");
        }
    }

    foreach (var keywordName in keywordNames)
    {
        if (!index.TryGetValue(keywordName, out var record))
        {
            report.Errors.Add($"Missing Green Pact keyword: {keywordName}");
        }
        else if (record is not Keyword)
        {
            report.Errors.Add($"{keywordName} exists as {record.GetType().Name}, expected KYWD/Keyword.");
        }
        else
        {
            report.Actions.Add($"{keywordName} exists as KYWD.");
        }
    }

    CheckAliasProperties(index, formListNames.Concat(keywordNames), report);

    if (!File.Exists(playerEventsPath))
    {
        report.Errors.Add($"PDV_PlayerEvents source not found: {playerEventsPath}");
    }
    else
    {
        var source = File.ReadAllText(playerEventsPath);
        string[] requiredSnippets =
        [
            "Function RouteBosmerGreenPactFood(Form baseObject)",
            "Potion foodItem = baseObject as Potion",
            "foodItem.IsFood()",
            "PDV_EventBusService.RouteGreenPactViolation()",
            "PDV_EventBusService.RouteBosmerPactPositive()"
        ];

        foreach (var snippet in requiredSnippets)
        {
            if (!source.Contains(snippet, StringComparison.Ordinal))
            {
                report.Errors.Add($"PDV_PlayerEvents Green Pact source snippet missing: {snippet}");
            }
        }
    }

    if (!File.Exists(kidPath))
    {
        report.Errors.Add($"Green Pact KID ini is missing: {kidPath}");
    }
    else
    {
        var kid = File.ReadAllText(kidPath);
        foreach (var keywordName in keywordNames)
        {
            if (!kid.Contains(keywordName, StringComparison.OrdinalIgnoreCase))
            {
                report.Errors.Add($"Green Pact KID ini does not mention {keywordName}.");
            }
        }

        report.Actions.Add($"Green Pact KID ini exists: {kidPath}");
    }
}

static void WireCapstoneFallbacks(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<CapstoneFallback> capstones,
    AuthorReport report)
{
    _ = mod;
    var debugGlobal = RequireRecord<ISkyrimMajorRecordGetter>(index, "PDV_GLO_DebugLevel");
    foreach (var capstone in capstones)
    {
        var effect = RequireFirstMagicEffectForSpell(index, capstone.SpellEditorId);
        WireMagicEffectScript(effect, "PDV_T3DailyLowHealthSaveEffect", new ScriptProperty[]
        {
            StringProp("StorageKey", capstone.StorageKey),
            FloatProp("TriggerHealthPercent", 0.10f),
            FloatProp("HealAmount", capstone.HealAmount),
            FloatProp("WatchIntervalSeconds", 2.0f),
            ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey)
        });
        report.Actions.Add($"Wired PDV_T3DailyLowHealthSaveEffect on {effect.EditorID} for {capstone.SpellEditorId}.");
    }
}

static void CheckCapstoneFallbacks(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IEnumerable<CapstoneFallback> capstones,
    AuthorReport report)
{
    foreach (var capstone in capstones)
    {
        var effect = RequireFirstMagicEffectForSpell(index, capstone.SpellEditorId);
        var scripts = effect.VirtualMachineAdapter?.Scripts ?? [];
        var script = scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV_T3DailyLowHealthSaveEffect", StringComparison.OrdinalIgnoreCase));
        if (script is null)
        {
            report.Errors.Add($"{effect.EditorID} is missing PDV_T3DailyLowHealthSaveEffect for {capstone.SpellEditorId}.");
            continue;
        }

        var props = script.Properties
            .Where(prop => !string.IsNullOrWhiteSpace(prop.Name))
            .ToDictionary(prop => prop.Name!, StringComparer.OrdinalIgnoreCase);

        if (!props.TryGetValue("StorageKey", out var storageProp)
            || storageProp is not ScriptStringProperty stringProp
            || !string.Equals(stringProp.Data, capstone.StorageKey, StringComparison.Ordinal))
        {
            report.Errors.Add($"{effect.EditorID} StorageKey is not {capstone.StorageKey}.");
        }

        if (!props.ContainsKey("PDV_GLO_DebugLevel"))
        {
            report.Errors.Add($"{effect.EditorID} is missing PDV_GLO_DebugLevel property.");
        }

        report.Actions.Add($"{effect.EditorID} carries PDV_T3DailyLowHealthSaveEffect for {capstone.SpellEditorId}.");
    }
}

static MagicEffect RequireFirstMagicEffectForSpell(Dictionary<string, ISkyrimMajorRecordGetter> index, string spellEditorId)
{
    var spell = RequireRecord<Spell>(index, spellEditorId);
    var effectLink = spell.Effects.FirstOrDefault()?.BaseEffect;
    if (effectLink is null || effectLink.IsNull)
    {
        throw new InvalidOperationException($"{spellEditorId} has no first magic effect to carry the capstone script.");
    }

    var effect = index.Values
        .OfType<MagicEffect>()
        .FirstOrDefault(candidate => candidate.FormKey.Equals(effectLink.FormKey));
    if (effect is null)
    {
        throw new InvalidOperationException($"{spellEditorId} first magic effect {effectLink.FormKey} is missing.");
    }

    return effect;
}

static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
{
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
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

static void WriteKidIfNeeded(string kidPath, bool dryRun, AuthorReport report)
{
    var content = """
; PlayerDevotion Green Pact tag layer
; KID receives mod-added food classifications here after hand curation.
; Keep broad wildcard rules out of beta unless the food family is reviewed.

; Keyword = PDV_KW_GreenPact_Plant|Potion|<EditorID or FormID filters>
; Keyword = PDV_KW_GreenPact_Meat|Potion|<EditorID or FormID filters>
; Keyword = PDV_KW_GreenPact_Fungi|Potion|<EditorID or FormID filters>
; Keyword = PDV_KW_GreenPact_Egg|Potion|<EditorID or FormID filters>
; Keyword = PDV_KW_GreenPact_Insect|Potion|<EditorID or FormID filters>
""";

    if (File.Exists(kidPath) && string.Equals(File.ReadAllText(kidPath), content, StringComparison.Ordinal))
    {
        report.Actions.Add($"Green Pact KID ini already current: {kidPath}");
        return;
    }

    report.Actions.Add($"Prepared Green Pact KID ini: {kidPath}");
    if (dryRun)
    {
        return;
    }

    Directory.CreateDirectory(Path.GetDirectoryName(kidPath)!);
    File.WriteAllText(kidPath, content);
    report.TouchedFiles.Add(kidPath);
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

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report)
{
    if (dryRun)
    {
        return;
    }

    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "phase20-p2-receivers");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.phase20-p2-receivers.tmp";
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

sealed class P2ReceiverManifest
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public P2QuestStageGate? questStageGate { get; set; }
    public P2RouteContract? routeContract { get; set; }
    public List<P2RouteEntry>? routeEntries { get; set; }
    public List<P2ReceiverSourceProperty>? sourceProperties { get; set; }
    public List<P2SourceFillGroup>? sourceFillEntries { get; set; }
}

sealed class P2QuestStageGate
{
    public string? status { get; set; }
    public string? receiverStatus { get; set; }
    public string? rule { get; set; }
}

sealed class P2ReceiverSourceProperty
{
    public string? property { get; set; }
    public List<string>? sourceKinds { get; set; }
}

sealed class P2RouteContract
{
    public string? status { get; set; }
    public string? sourceOfTruth { get; set; }
    public string? script { get; set; }
    public string? verificationCommand { get; set; }
    public string? rule { get; set; }
}

sealed class P2RouteEntry
{
    public string? id { get; set; }
    public string? race { get; set; }
    public string? property { get; set; }
    public string? sourceKind { get; set; }
    public string? formKey { get; set; }
    public int expectedFormId { get; set; }
    public int approvedStage { get; set; }
    public string? routeKey { get; set; }
    public string? dispatch { get; set; }
    public string? acceptedContext { get; set; }
    public string? rejectedContext { get; set; }
    public string? duplicateGuard { get; set; }
    public string? mutualExclusionGroup { get; set; }
    public string? stageReadbackEvidence { get; set; }
    public string? implementationStatus { get; set; }
    public string? reviewStatus { get; set; }
}

sealed class P2SourceFillGroup
{
    public string? property { get; set; }
    public List<P2SourceFillEntry>? sources { get; set; }
}

sealed class P2SourceFillEntry
{
    public string? formKey { get; set; }
    public string? editorId { get; set; }
    public string? sourceKind { get; set; }
    public string? status { get; set; }
    public string? rationale { get; set; }
    public List<int>? approvedStages { get; set; }
    public string? stageReadbackEvidence { get; set; }
    public string? rejectedStageContext { get; set; }
    public string? duplicateGuard { get; set; }
}

sealed record ValidatedSourceFillGroup(string Property, List<ValidatedSourceFillEntry> Sources);

sealed record ValidatedSourceFillEntry(FormKey FormKey, string Label, string SourceKind);

sealed record CapstoneFallback(string SpellEditorId, string StorageKey, float HealAmount);

sealed record GenericFaucetEntry(FormKey FormKey, string EditorId);

sealed record GenericFaucetStoryManagerNode(string NodeEditorId, string ReceiverQuestEditorId, FormKey Parent, FormKey? PreviousSibling);

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public bool DryRun { get; set; }
    public bool CreateMissing { get; set; }
    public bool CheckFormLists { get; set; }
    public bool InspectVmad { get; set; }
    public bool WireAliasProperties { get; set; }
    public bool CheckAliasProperties { get; set; }
    public bool FillSourceEntries { get; set; }
    public bool CheckSourceFill { get; set; }
    public bool CheckExactStageGates { get; set; }
    public bool CheckRouteEntries { get; set; }
    public bool AuthorGreenPact { get; set; }
    public bool CheckGreenPact { get; set; }
    public bool AuthorCapstones { get; set; }
    public bool CheckCapstones { get; set; }
    public bool FillGenericFaucets { get; set; }
    public bool CheckGenericFaucetFill { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
