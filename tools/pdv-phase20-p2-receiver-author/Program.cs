using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
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
        && !checkCapstones)
    {
        throw new InvalidOperationException("Specify --create-missing, --check-formlists, --inspect-vmad, --wire-alias-properties, --check-alias-properties, --fill-source-entries, --check-source-fill, --check-exact-stage-gates, --check-route-entries, --author-green-pact, --check-green-pact, --author-capstones, or --check-capstones. Use --dry-run with write modes for planning only.");
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
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
