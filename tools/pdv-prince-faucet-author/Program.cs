using System.Text.Json;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using SkyrimFormList = Mutagen.Bethesda.Skyrim.FormList;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = GetArg(args, "--esp") ?? defaultEsp;
var specs = BuildSpecs();

var report = new PrinceFaucetReport
{
    Mode = dryRun ? "dry-run" : write ? "write" : check ? "check" : "none",
    EspPath = espPath,
    StartedAt = DateTimeOffset.Now,
};

try
{
    if ((dryRun ? 1 : 0) + (write ? 1 : 0) + (check ? 1 : 0) != 1)
    {
        throw new InvalidOperationException("Choose exactly one mode: --dry-run, --write, or --check.");
    }

    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
    var changed = false;

    foreach (var spec in specs)
    {
        var changedThisList = EnsureOrCheckFormList(mod, index, allocator, spec, dryRun, check, report);
        changed = changed || changedThisList;
    }

    report.WouldChange = changed;

    if (check && report.Errors.Count > 0)
    {
        throw new InvalidOperationException("Prince faucet FormList check failed.");
    }

    if (write && changed)
    {
        WriteMod(mod, espPath, report);
        ReadBack(espPath, specs, report);
    }
    else if (write)
    {
        report.Actions.Add("No ESP write needed; all Prince faucet FormLists already match.");
    }
    else if (dryRun)
    {
        report.Actions.Add("Dry run: no bytes written.");
    }

    if (report.Errors.Count == 0)
    {
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

static bool EnsureOrCheckFormList(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    PrinceFaucetSpec spec,
    bool dryRun,
    bool check,
    PrinceFaucetReport report)
{
    if (!index.TryGetValue(spec.EditorId, out var record))
    {
        if (check)
        {
            report.Errors.Add($"Missing FLST {spec.EditorId}.");
            return false;
        }

        var created = new SkyrimFormList(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = spec.EditorId,
            FormVersion = 44
        };
        foreach (var item in spec.Items)
        {
            created.Items.Add(item.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
        }

        report.FormLists.Add(FormListSnapshot.From(spec, ToHousecarl(created.FormKey), [], spec.Items.Select(item => item.ToHousecarl()).ToArray(), "create"));
        report.Actions.Add($"Will create {spec.EditorId} with {spec.Items.Length} item(s).");
        if (!dryRun)
        {
            mod.FormLists.Add(created);
            index[spec.EditorId] = created;
        }

        return true;
    }

    if (record is not SkyrimFormList formList)
    {
        throw new InvalidOperationException($"{spec.EditorId} exists as {record.GetType().Name}, expected FLST/FormList.");
    }

    var before = formList.Items.Select(item => ToHousecarl(item.FormKey)).ToArray();
    var expected = spec.Items.Select(item => item.FormKey).ToArray();
    var current = formList.Items.Select(item => item.FormKey).ToArray();
    var matches = current.SequenceEqual(expected);
    var action = matches ? "verify" : check ? "mismatch" : "update";

    report.FormLists.Add(FormListSnapshot.From(spec, ToHousecarl(formList.FormKey), before, spec.Items.Select(item => item.ToHousecarl()).ToArray(), action));

    if (matches)
    {
        report.Actions.Add($"{spec.EditorId} already matches {spec.Items.Length} item(s).");
        return false;
    }

    var missing = expected.Except(current).Select(ToHousecarl).ToArray();
    var extra = current.Except(expected).Select(ToHousecarl).ToArray();

    if (check)
    {
        if (missing.Length > 0)
        {
            report.Errors.Add($"{spec.EditorId} missing: {string.Join(", ", missing)}");
        }
        if (extra.Length > 0)
        {
            report.Errors.Add($"{spec.EditorId} extra: {string.Join(", ", extra)}");
        }
        return false;
    }

    if (missing.Length > 0)
    {
        report.Actions.Add($"{spec.EditorId} will add: {string.Join(", ", missing)}");
    }
    if (extra.Length > 0)
    {
        report.Actions.Add($"{spec.EditorId} will remove: {string.Join(", ", extra)}");
    }

    if (!dryRun)
    {
        formList.Items.Clear();
        foreach (var item in spec.Items)
        {
            formList.Items.Add(item.FormKey.ToLinkGetter<ISkyrimMajorRecordGetter>());
        }
    }
    report.Actions.Add($"Will update {spec.EditorId} to exact {spec.Items.Length}-item artifact set.");
    return true;
}

static void ReadBack(string espPath, IEnumerable<PrinceFaucetSpec> specs, PrinceFaucetReport report)
{
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    foreach (var spec in specs)
    {
        if (!index.TryGetValue(spec.EditorId, out var record) || record is not SkyrimFormList formList)
        {
            report.Errors.Add($"Readback missing FLST {spec.EditorId}.");
            continue;
        }

        var current = formList.Items.Select(item => item.FormKey).ToArray();
        var expected = spec.Items.Select(item => item.FormKey).ToArray();
        if (!current.SequenceEqual(expected))
        {
            report.Errors.Add($"Readback mismatch for {spec.EditorId}.");
            continue;
        }

        report.Actions.Add($"Readback PASS: {spec.EditorId} ({ToHousecarl(formList.FormKey)}) has {current.Length} expected item(s).");
    }
}

static void WriteMod(SkyrimMod mod, string espPath, PrinceFaucetReport report)
{
    using (File.Open(espPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None))
    {
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "prince-faucets");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.prince-faucets.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
    report.Actions.Add($"Wrote {espPath}.");
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
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

static PrinceFaucetSpec S(string editorId, params ArtifactRef[] items) => new(editorId, items);

static ArtifactRef A(uint id, string label) => new(new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), id), label);

static string ToHousecarl(FormKey key) => $"{key.IDString().ToUpperInvariant()}:{key.ModKey.FileName}";

static PrinceFaucetSpec[] BuildSpecs() =>
[
    S("PDV_FLST_Faucet_MolagBal_Artifact",
        A(0x0233E3, "Mace of Molag Bal")),
    S("PDV_FLST_Faucet_Hircine_Artifact",
        A(0x02AC61, "Savior's Hide"),
        A(0x02AC60, "Ring of Hircine")),
    S("PDV_FLST_Faucet_Meridia_Artifact",
        A(0x04E4EE, "Dawnbreaker")),
    S("PDV_FLST_Faucet_Sheogorath_Artifact",
        A(0x02AC6F, "Wabbajack")),
    S("PDV_FLST_Faucet_MehrunesDagon_Artifact",
        A(0x0240D2, "Mehrunes' Razor")),
    S("PDV_FLST_Faucet_Nocturnal_Artifact",
        A(0x07A917, "Nightingale Blade 01"),
        A(0x0F6524, "Nightingale Blade 02"),
        A(0x0F6525, "Nightingale Blade 03"),
        A(0x0F6526, "Nightingale Blade 04"),
        A(0x0F6527, "Nightingale Blade 05"),
        A(0x07E5C3, "Nightingale Bow 01"),
        A(0x0F6529, "Nightingale Bow 02"),
        A(0x0F652A, "Nightingale Bow 03"),
        A(0x0F652B, "Nightingale Bow 04"),
        A(0x0F652C, "Nightingale Bow 05"),
        A(0x05DB86, "Nightingale Armor 01"),
        A(0x0FCC0E, "Nightingale Armor 02"),
        A(0x0FCC0F, "Nightingale Armor 03"),
        A(0x0FCC0C, "Nightingale Boots 01"),
        A(0x05DB85, "Nightingale Boots 02"),
        A(0x0FCC0D, "Nightingale Boots 03"),
        A(0x05DB87, "Nightingale Gloves 01"),
        A(0x0FCC10, "Nightingale Gloves 02"),
        A(0x0FCC11, "Nightingale Gloves 03"),
        A(0x05DB88, "Nightingale Hood 01"),
        A(0x0FCC13, "Nightingale Hood 02"),
        A(0x0FCC12, "Nightingale Hood 03"))
];

sealed record PrinceFaucetSpec(string EditorId, ArtifactRef[] Items);

sealed record ArtifactRef(FormKey FormKey, string Label)
{
    public string ToHousecarl() => $"{FormKey.IDString().ToUpperInvariant()}:{FormKey.ModKey.FileName}";
}

sealed record FormListSnapshot(
    string EditorId,
    string FormId,
    string[] Before,
    string[] Expected,
    string Action)
{
    public static FormListSnapshot From(PrinceFaucetSpec spec, string formId, string[] before, string[] expected, string action)
        => new(spec.EditorId, formId, before, expected, action);
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

    private static uint ParseLocalId(FormKey key) => Convert.ToUInt32(key.IDString(), 16);
}

sealed class PrinceFaucetReport
{
    public string Status { get; set; } = "STARTED";
    public string? Mode { get; set; }
    public string? EspPath { get; set; }
    public string? BackupPath { get; set; }
    public bool WouldChange { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<FormListSnapshot> FormLists { get; set; } = [];
    public List<string> Actions { get; set; } = [];
    public List<string> Errors { get; set; } = [];
    public List<string> TouchedFiles { get; set; } = [];
    public string? Exception { get; set; }
}
