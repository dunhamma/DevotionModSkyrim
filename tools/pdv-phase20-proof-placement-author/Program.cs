using System.Text.Json;
using System.Reflection;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string qasmokeEditorId = "QASmoke";
var qasmokeFormKey = new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), 0x032AE7);
var qasmokeTemplatePluginCandidates = new[]
{
    @"D:\Wabbajack\modlists\Anvil\mods\Anvil - Synthesis Output\ANV_SynW4ENBPatcher.esp",
    @"D:\Wabbajack\modlists\Anvil\mods\Lux - Water for ENB patch\Lux - Water for ENB patch.esp",
    @"D:\Wabbajack\modlists\Anvil\mods\Water for ENB (Shades of Skyrim)\Water for ENB (Shades of Skyrim).esp",
    @"D:\Wabbajack\modlists\Anvil\Stock Game\Data\Skyrim.esm",
};

var defaultManifests = new[]
{
    @"references\authoring\PDV_Phase20AltmerImplementationCosting.manifest.json",
    @"references\authoring\PDV_Phase20ArgonianImplementationCosting.manifest.json",
    @"references\authoring\PDV_Phase20OrcImplementationCosting.manifest.json",
    @"references\authoring\PDV_Phase20RedguardImplementationCosting.manifest.json",
    @"references\authoring\PDV_Phase20KhajiitImplementationCosting.manifest.json",
    @"references\authoring\PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json",
};

var dryRun = args.Contains("--dry-run");
var placeMissing = args.Contains("--place-missing");
var checkPlacements = args.Contains("--check-placements");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPaths = GetRepeatedArgs(args, "--manifest")
    .DefaultIfEmpty()
    .SelectMany(value => value is null ? defaultManifests : [value])
    .Select(Path.GetFullPath)
    .ToArray();

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    PlaceMissing = placeMissing,
    CheckPlacements = checkPlacements,
    StartedAt = DateTimeOffset.Now
};
report.ManifestPaths.AddRange(manifestPaths);

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    foreach (var manifestPath in manifestPaths)
    {
        if (!File.Exists(manifestPath))
        {
            throw new FileNotFoundException("Phase 20 manifest not found.", manifestPath);
        }
    }

    if (!placeMissing && !checkPlacements)
    {
        throw new InvalidOperationException("Specify --dry-run, --place-missing, or --check-placements.");
    }

    var definitions = manifestPaths
        .SelectMany(path => BuildTriggerDefinitions(path))
        .OrderBy(definition => definition.RaceOrder)
        .ThenBy(definition => definition.RouteId)
        .ToArray();

    if (definitions.Length == 0)
    {
        throw new InvalidOperationException("No record-wired Phase 20 trigger surfaces were found.");
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (checkPlacements)
    {
        CheckTriggerPlacements(index, definitions, report);
        if (report.Errors.Count > 0)
        {
            throw new InvalidOperationException("Phase 20 proof placement check failed.");
        }

        report.Status = "PASS";
    }
    else
    {
        var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
        var proofCell = EnsureQASmokeOverride(mod, index, report);
        foreach (var (definition, ordinal) in definitions.Select((definition, ordinal) => (definition, ordinal)))
        {
            EnsurePlacedReference(proofCell, index, allocator, definition, ordinal, report);
        }

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
                    report.Actions.Add("Using existing QASmoke cell override.");
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
        report.Actions.Add("Created QASmoke interior cell block override shell.");
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
        report.Actions.Add("Created QASmoke interior cell sub-block override shell.");
    }

    var qasmoke = CreateQASmokeOverrideFromTemplate(report);
    targetSubBlock.Cells.Add(qasmoke);
    index[qasmokeEditorId] = qasmoke;
    report.Actions.Add("Created QASmoke cell override from existing Anvil cell data for Phase 20 proof references.");
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

static void EnsurePlacedReference(
    Cell proofCell,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    TriggerDefinition definition,
    int ordinal,
    AuthorReport report)
{
    if (!index.TryGetValue(definition.EditorId, out var baseRecord))
    {
        report.Errors.Add($"Missing base activator: {definition.EditorId}");
        return;
    }

    if (baseRecord is not IPlaceableObjectGetter)
    {
        report.Errors.Add($"{definition.EditorId} is {baseRecord.GetType().Name}, expected a placeable base record.");
        return;
    }

    PlacedObject placed;
    if (index.TryGetValue(definition.PlacementRefEditorId, out var existing))
    {
        if (existing is not PlacedObject existingPlaced)
        {
            report.Errors.Add($"{definition.PlacementRefEditorId} is {existing.GetType().Name}, expected PlacedObject/REFR.");
            return;
        }

        placed = existingPlaced;
        report.Actions.Add($"Updated existing proof reference {definition.PlacementRefEditorId}.");
    }
    else
    {
        placed = new PlacedObject(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = definition.PlacementRefEditorId
        };
        proofCell.Temporary.Add(placed);
        index[definition.PlacementRefEditorId] = placed;
        report.Actions.Add($"Created proof reference {definition.PlacementRefEditorId} in QASmoke.");
    }

    placed.EditorID = definition.PlacementRefEditorId;
    placed.Base = baseRecord.FormKey.ToNullableLink<IPlaceableObjectGetter>();
    placed.Scale = 1.0f;
    placed.Placement = new Placement
    {
        Position = PositionFor(definition, ordinal),
        Rotation = new P3Float(0, 0, 0)
    };
}

static P3Float PositionFor(TriggerDefinition definition, int ordinal)
{
    var x = -640f + (definition.RaceColumn * 256f);
    var y = (definition.IndexWithinRace * 176f);
    var z = 64f;
    return new P3Float(x, y, z);
}

static void CheckTriggerPlacements(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    IReadOnlyList<TriggerDefinition> triggers,
    AuthorReport report)
{
    foreach (var trigger in triggers)
    {
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

        if (baseRecord is not Mutagen.Bethesda.Skyrim.Activator activator)
        {
            report.Errors.Add($"{trigger.EditorId} is {baseRecord.GetType().Name}, expected Activator.");
            continue;
        }

        var actualName = activator.Name?.String ?? "";
        var actualActivateText = activator.ActivateTextOverride?.String ?? "";
        if (!string.Equals(actualName, trigger.Name, StringComparison.Ordinal))
        {
            report.Errors.Add($"{trigger.EditorId} FULL is '{actualName}', expected '{trigger.Name}'.");
            continue;
        }

        if (!string.Equals(actualActivateText, trigger.ActivateText, StringComparison.Ordinal))
        {
            report.Errors.Add($"{trigger.EditorId} activate text is '{actualActivateText}', expected '{trigger.ActivateText}'.");
            continue;
        }

        if (ContainsAsciiLowercase(actualName) || ContainsAsciiLowercase(actualActivateText))
        {
            report.Errors.Add($"{trigger.EditorId} proof display strings must be all caps: FULL='{actualName}', RNAM='{actualActivateText}'.");
            continue;
        }

        if (placed.Base.FormKey != baseRecord.FormKey)
        {
            report.Errors.Add($"{trigger.PlacementRefEditorId} points at {placed.Base.FormKey}, expected {trigger.EditorId} ({baseRecord.FormKey}).");
            continue;
        }

        report.Actions.Add($"{trigger.PlacementRefEditorId} [{placed.FormKey}] -> {trigger.EditorId} [{baseRecord.FormKey}]");
    }
}

static bool ContainsAsciiLowercase(string value)
{
    foreach (var ch in value)
    {
        if (ch >= 'a' && ch <= 'z')
        {
            return true;
        }
    }

    return false;
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
}

static IEnumerable<TriggerDefinition> BuildTriggerDefinitions(string manifestPath)
{
    var parsed = JsonSerializer.Deserialize<Phase20Manifest>(File.ReadAllText(manifestPath));
    if (parsed is null)
    {
        throw new InvalidOperationException($"Manifest could not be parsed: {manifestPath}");
    }

    var raceOrder = RaceOrderFor(manifestPath);
    var raceColumn = raceOrder;
    var indexWithinRace = 0;
    foreach (var trigger in parsed.triggerSurfaces ?? [])
    {
        if (!string.Equals(trigger.recordStatus, "record-wired", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        if (!string.Equals(trigger.recordType, "ACTI", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Trigger surface {trigger.id ?? "(unknown)"} must be an ACTI record.");
        }

        if (string.IsNullOrWhiteSpace(trigger.editorId)
            || string.IsNullOrWhiteSpace(trigger.placementRefEditorId)
            || string.IsNullOrWhiteSpace(trigger.name)
            || string.IsNullOrWhiteSpace(trigger.activateText)
            || trigger.routeId <= 0)
        {
            throw new InvalidOperationException($"Trigger surface metadata is incomplete for {trigger.id ?? "(unknown)"}.");
        }

        yield return new TriggerDefinition(
            trigger.editorId,
            trigger.placementRefEditorId,
            trigger.name,
            trigger.activateText,
            trigger.routeId,
            raceOrder,
            raceColumn,
            indexWithinRace++);
    }
}

static int RaceOrderFor(string manifestPath)
{
    var file = Path.GetFileName(manifestPath);
    if (file.Contains("Altmer", StringComparison.OrdinalIgnoreCase)) return 0;
    if (file.Contains("Argonian", StringComparison.OrdinalIgnoreCase)) return 1;
    if (file.Contains("Orc", StringComparison.OrdinalIgnoreCase)) return 2;
    if (file.Contains("Redguard", StringComparison.OrdinalIgnoreCase)) return 3;
    if (file.Contains("Khajiit", StringComparison.OrdinalIgnoreCase)) return 4;
    if (file.Contains("Bosmer", StringComparison.OrdinalIgnoreCase)) return 5;
    return 99;
}

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report)
{
    if (dryRun)
    {
        return;
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "phase20-proof-placements");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.phase20-proof-placements.tmp";
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

static IEnumerable<string> GetRepeatedArgs(string[] args, string name)
{
    for (var i = 0; i < args.Length - 1; i++)
    {
        if (string.Equals(args[i], name, StringComparison.OrdinalIgnoreCase))
        {
            yield return args[i + 1];
            i++;
        }
    }
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

sealed class Phase20Manifest
{
    public string? id { get; set; }
    public string? implementationStatus { get; set; }
    public List<ManifestTriggerSurface>? triggerSurfaces { get; set; }
}

sealed class ManifestTriggerSurface
{
    public string? id { get; set; }
    public string? recordStatus { get; set; }
    public string? recordType { get; set; }
    public string? editorId { get; set; }
    public string? placementRefEditorId { get; set; }
    public string? name { get; set; }
    public string? activateText { get; set; }
    public int routeId { get; set; }
}

sealed record TriggerDefinition(
    string EditorId,
    string PlacementRefEditorId,
    string Name,
    string ActivateText,
    int RouteId,
    int RaceOrder,
    int RaceColumn,
    int IndexWithinRace);

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public List<string> ManifestPaths { get; } = [];
    public bool DryRun { get; set; }
    public bool PlaceMissing { get; set; }
    public bool CheckPlacements { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}
