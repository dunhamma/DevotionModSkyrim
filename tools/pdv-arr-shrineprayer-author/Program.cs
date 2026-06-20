// pdv-arr-shrineprayer-author
// Creates 11 PDV_ACTI_ShrinePrayer_* Activator records in a NEW compatibility ESP
// (PDV_AuthoriaARR_Compatibility.esp) and emits a Base Object Swapper INI.
// Does NOT modify Devotion.esp.
//
// Usage:
//   dotnet run -- [--dry-run]
//   dotnet run -- [--check]   (verify written ESP only)

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;
using SkyrimGlobal = Mutagen.Bethesda.Skyrim.Global;
using SkyrimActivator = Mutagen.Bethesda.Skyrim.Activator;

// ---------------------------------------------------------------------------
// Paths and constants
// ---------------------------------------------------------------------------
const string devotionEspPath   = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string outputEspPath     = @"C:\Users\Admin\Documents\pdv-arr-extension\dist\PDV_AuthoriaARR_Compatibility\PDV_AuthoriaARR_Compatibility.esp";
const string outputBosIniPath  = @"C:\Users\Admin\Documents\pdv-arr-extension\dist\PDV_AuthoriaARR_Compatibility\PDV_AuthoriaARR_ShrinePrayer_SWAP.ini";
const string compatModName     = "PDV_AuthoriaARR_Compatibility.esp";

// Devotion.esp EventBus FormKey (046AF7)
const uint eventBusLocalId = 0x046AF7u;
// Skyrim.esm PlayerREF (00000014)
const uint playerRefLocalId = 0x000014u;

var skyrimModKey  = ModKey.FromNameAndExtension("Skyrim.esm");
var devotionModKey = ModKey.FromNameAndExtension("Devotion.esp");

var dryRun   = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");

var report = new AuthorReport
{
    OutputEspPath   = outputEspPath,
    OutputBosPath   = outputBosIniPath,
    DryRun          = dryRun,
    CheckOnly       = checkOnly,
    StartedAt       = DateTimeOffset.Now
};

try
{
    // --check: verify an already-written ESP
    if (checkOnly)
    {
        CheckWrittenEsp(outputEspPath, report);
        report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
        Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
        return report.Status == "PASS" ? 0 : 1;
    }

    // Load Devotion.esp to resolve cross-plugin references
    if (!File.Exists(devotionEspPath))
    {
        throw new FileNotFoundException("Devotion.esp not found.", devotionEspPath);
    }

    report.Actions.Add($"Loading Devotion.esp from {devotionEspPath}");
    var devotion = SkyrimMod.CreateFromBinary(devotionEspPath, SkyrimRelease.SkyrimSE);
    var devIndex = BuildIndex(devotion);

    // Resolve optional globals from Devotion.esp (per spec note: only PDV_EventBusService is strictly required)
    var eventBusFormKey   = new FormKey(devotionModKey, eventBusLocalId);
    var playerRefFormKey  = new FormKey(skyrimModKey, playerRefLocalId);

    FormKey? originRaceFormKey  = TryResolveFormKey(devIndex, "PDV_GLO_OriginRace",  report);
    FormKey? debugLevelFormKey  = TryResolveFormKey(devIndex, "PDV_GLO_DebugLevel",  report);

    // Verify the EventBus quest exists in Devotion.esp
    if (!devIndex.ContainsKey("PDV_EventBus"))
    {
        report.Errors.Add("PDV_EventBus quest not found in Devotion.esp — check the ESP path.");
    }

    // Define the 11 shrines from the manifest
    var shrines = new[]
    {
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Azura",         "Shrine of Azura",          @"man_azura\shrineofazura01.nif",              "man_DaedricShrines.esp", 0x00082Cu, 1,  "PDV.ARRShrinePrayer.Azura",         "arr_man_azura_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Vaermina",      "Shrine of Vaermina",       @"man_vaermina\vaermina.nif",                  "man_DaedricShrines.esp", 0x0008E9u, 2,  "PDV.ARRShrinePrayer.Vaermina",      "arr_man_vaermina_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_MolagBal",      "Shrine of Molag Bal",      @"man_molag\molag.nif",                        "man_DaedricShrines.esp", 0x0008F2u, 4,  "PDV.ARRShrinePrayer.MolagBal",      "arr_man_molagbal_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Mephala",       "Shrine of Mephala",        @"man_mephala\mephala.nif",                    "man_DaedricShrines.esp", 0x00087Au, 5,  "PDV.ARRShrinePrayer.Mephala",       "arr_man_mephala_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_MehrunesDagon", "Shrine of Mehrunes Dagon", @"Clutter\Mehrunes\ShrineMehrunes01.nif",      "Skyrim.esm",             0x0C5999u, 7,  "PDV.ARRShrinePrayer.MehrunesDagon", "arr_man_dagon_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Sheogorath",    "Shrine of Sheogorath",     @"man_sheo\sheo.nif",                          "man_DaedricShrines.esp", 0x00089Bu, 8,  "PDV.ARRShrinePrayer.Sheogorath",    "arr_man_sheogorath_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Namira",        "Shrine of Namira",         @"man_namira\namira.nif",                      "man_DaedricShrines.esp", 0x000DF4u, 9,  "PDV.ARRShrinePrayer.Namira",        "arr_man_namira_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Sanguine",      "Shrine of Sanguine",       @"man_sanguine\sanguine.nif",                  "man_DaedricShrines.esp", 0x000852u, 10, "PDV.ARRShrinePrayer.Sanguine",      "arr_man_sanguine_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_HermaeusMora",  "Shrine of Hermaeus Mora",  @"man_mora\mora.nif",                          "man_DaedricShrines.esp", 0x000864u, 12, "PDV.ARRShrinePrayer.HermaeusMora",  "arr_man_hermaeusmora_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Hircine",       "Shrine of Hircine",        @"man_Hircine\hircine.nif",                    "man_DaedricShrines.esp", 0x000D61u, 15, "PDV.ARRShrinePrayer.Hircine",       "arr_man_hircine_shrine_prayer"),
        new ShrineSpec("PDV_ACTI_ShrinePrayer_Peryite",       "Shrine of Peryite",        @"man_peryite\peryite.nif",                    "man_DaedricShrines.esp", 0x000D62u, 14, "PDV.ARRShrinePrayer.Peryite",       "arr_man_peryite_shrine_prayer"),
    };

    if (dryRun)
    {
        report.Actions.Add("DRY RUN — no files will be written.");
        foreach (var shrine in shrines)
        {
            report.Actions.Add($"[DRY] Would create {shrine.EditorId}: name='{shrine.Name}' model='{shrine.Model}' " +
                               $"RouteId=202 RequiredOriginRace=-1 SignalValue={shrine.PrinceIndex} " +
                               $"OncePerDayKey={shrine.OncePerDayKey} SignalSourceId={shrine.SignalSourceId}");
        }
        report.Actions.Add($"[DRY] Would write ESP to {outputEspPath}");
        report.Actions.Add($"[DRY] Would write BOS INI to {outputBosIniPath}");
        report.Status = "PASS";
        Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
        return 0;
    }

    // Create the new compatibility mod
    var compatModKey = ModKey.FromNameAndExtension(compatModName);
    var compatMod    = new SkyrimMod(compatModKey, SkyrimRelease.SkyrimSE);

    // ESL-flag it (tiny mod, 11 records well under ESL limit of 2048)
    compatMod.ModHeader.Flags |= SkyrimModHeader.HeaderFlag.Small;

    var allocator = new SimpleAllocator(compatModKey);

    // Build each shrine activator
    var createdActivators = new List<(ShrineSpec Spec, FormKey ActiFormKey)>();

    foreach (var shrine in shrines)
    {
        var actiFormKey = allocator.Next();
        var acti = new SkyrimActivator(actiFormKey, SkyrimRelease.SkyrimSE)
        {
            EditorID            = shrine.EditorId,
            FormVersion         = 44,
            Name                = Tx(shrine.Name),
            ActivateTextOverride = Tx("Pray"),
        };
        acti.Model ??= new Model();
        acti.Model.File = shrine.Model;

        // Wire VMAD — only PDV_EventBusService is strictly required per spec note;
        // PlayerREF + GLO globals added for completeness matching the template pattern.
        var properties = new List<ScriptProperty>
        {
            ObjectProp("PDV_EventBusService", eventBusFormKey),
            ObjectProp("PlayerREF",           playerRefFormKey),
            IntProp("RouteId",                202),
            IntProp("RequiredOriginRace",     -1),
            IntProp("SignalValue",            shrine.PrinceIndex),
            StringProp("SignalSourceId",      shrine.SignalSourceId),
            StringProp("TraceLabel",          shrine.EditorId),
            StringProp("OncePerDayKey",       shrine.OncePerDayKey),
        };

        // Add optional globals if resolved
        if (originRaceFormKey.HasValue)
            properties.Add(ObjectProp("PDV_GLO_OriginRace", originRaceFormKey.Value));
        if (debugLevelFormKey.HasValue)
            properties.Add(ObjectProp("PDV_GLO_DebugLevel", debugLevelFormKey.Value));

        WireActivatorScript(acti, "PDV_EventSignalActivator", properties);

        compatMod.Activators.Add(acti);
        createdActivators.Add((shrine, actiFormKey));

        report.Actions.Add($"Created {shrine.EditorId} [{actiFormKey}] SignalValue={shrine.PrinceIndex}");
    }

    // Write ESP
    Directory.CreateDirectory(Path.GetDirectoryName(outputEspPath)!);
    using (var stream = File.Create(outputEspPath))
    {
        compatMod.WriteToBinary(stream);
    }
    report.TouchedFiles.Add(outputEspPath);
    report.Actions.Add($"Wrote ESP to {outputEspPath}");

    // Report FormID mappings (the mod is ESL-flagged, so in-game FormIDs will use XX000800+ slot)
    foreach (var (spec, fk) in createdActivators)
    {
        report.CreatedActivators.Add(new ActivatorEntry
        {
            EditorId       = spec.EditorId,
            FormKey        = fk.ToString(),
            LocalId        = $"0x{fk.ID:X6}",
            SignalValue    = spec.PrinceIndex,
            SwapFromStat   = $"0x{spec.SwapFromId:X6}~{spec.SwapFromPlugin}",
        });
    }

    // Emit BOS INI
    // Grammar: [Forms] section, one line per swap:
    //   0xFromId~FromPlugin|0xToId~ToPlugin
    // The "To" side must reference the compat mod's local FormID with prefix 0x
    // Since the file is ESL, the FormIDs start at 0x000800 locally.
    Directory.CreateDirectory(Path.GetDirectoryName(outputBosIniPath)!);
    var bosLines = new System.Text.StringBuilder();
    bosLines.AppendLine("; PDV ARR Shrine Prayer - Base Object Swapper");
    bosLines.AppendLine("; Swaps decorative Daedric statue STATs -> PDV prayer ACTI base objects.");
    bosLines.AppendLine("; Generated by pdv-arr-shrineprayer-author on " + DateTimeOffset.Now.ToString("yyyy-MM-dd"));
    bosLines.AppendLine(";");
    bosLines.AppendLine("[Forms]");
    foreach (var (spec, fk) in createdActivators)
    {
        // BOS FormID syntax uses lowercase hex with leading 0x, no zero-padding beyond 3 digits for small IDs
        // but the files reviewed show 6-digit zero-padded: 0x0C5999~Skyrim.esm
        var fromStr = $"0x{spec.SwapFromId:X6}~{spec.SwapFromPlugin}";
        var toStr   = $"0x{fk.ID:X6}~{compatModName}";
        bosLines.AppendLine($"{fromStr}|{toStr}");
        report.Actions.Add($"BOS swap: {fromStr} -> {toStr} ({spec.EditorId})");
    }
    File.WriteAllText(outputBosIniPath, bosLines.ToString());
    report.TouchedFiles.Add(outputBosIniPath);
    report.Actions.Add($"Wrote BOS INI to {outputBosIniPath}");

    // Readback verify
    report.Actions.Add("--- Readback verify ---");
    CheckWrittenEsp(outputEspPath, report);

    report.Status = report.Errors.Count == 0 ? "PASS" : "FAIL";
}
catch (Exception ex)
{
    report.Status    = "FAIL";
    report.Errors.Add(ex.Message);
    report.Exception = ex.ToString();
}
finally
{
    report.FinishedAt = DateTimeOffset.Now;
    Console.WriteLine(JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
}

return report.Status == "PASS" ? 0 : 1;

// ---------------------------------------------------------------------------
// Readback verification
// ---------------------------------------------------------------------------
static void CheckWrittenEsp(string espPath, AuthorReport report)
{
    if (!File.Exists(espPath))
    {
        report.Errors.Add($"Output ESP not found at {espPath}");
        return;
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var actis = mod.Activators.ToList();
    report.Actions.Add($"Readback: found {actis.Count} Activator record(s) in {espPath}");

    if (actis.Count != 11)
    {
        report.Errors.Add($"Expected 11 Activators, found {actis.Count}");
    }

    foreach (var acti in actis)
    {
        var script = acti.VirtualMachineAdapter?.Scripts
            .FirstOrDefault(s => string.Equals(s.Name, "PDV_EventSignalActivator", StringComparison.OrdinalIgnoreCase));

        if (script is null)
        {
            report.Errors.Add($"{acti.EditorID}: missing PDV_EventSignalActivator VMAD");
            continue;
        }

        var routeId = script.Properties
            .OfType<ScriptIntProperty>()
            .FirstOrDefault(p => string.Equals(p.Name, "RouteId", StringComparison.OrdinalIgnoreCase));
        var signalValue = script.Properties
            .OfType<ScriptIntProperty>()
            .FirstOrDefault(p => string.Equals(p.Name, "SignalValue", StringComparison.OrdinalIgnoreCase));
        var eventBus = script.Properties
            .OfType<ScriptObjectProperty>()
            .FirstOrDefault(p => string.Equals(p.Name, "PDV_EventBusService", StringComparison.OrdinalIgnoreCase));
        var onceKey = script.Properties
            .OfType<ScriptStringProperty>()
            .FirstOrDefault(p => string.Equals(p.Name, "OncePerDayKey", StringComparison.OrdinalIgnoreCase));

        var routeOk  = routeId?.Data == 202;
        var modelSet = !string.IsNullOrWhiteSpace(acti.Model?.File);
        var busSet   = eventBus is not null;

        if (!routeOk)
            report.Errors.Add($"{acti.EditorID}: RouteId is {routeId?.Data ?? -999}, expected 202");
        if (!modelSet)
            report.Errors.Add($"{acti.EditorID}: Model.File is empty");
        if (!busSet)
            report.Errors.Add($"{acti.EditorID}: PDV_EventBusService property missing");

        report.Actions.Add($"  {acti.EditorID} [{acti.FormKey}]: RouteId={routeId?.Data} SignalValue={signalValue?.Data} " +
                           $"Model={acti.Model?.File ?? "(none)"} EventBus={(busSet ? eventBus!.Object.FormKey.ToString() : "(MISSING)")} " +
                           $"OncePerDayKey={onceKey?.Data} OK={routeOk && modelSet && busSet}");
    }
}

// ---------------------------------------------------------------------------
// Helpers (mirrored from pdv-daedric-author)
// ---------------------------------------------------------------------------
static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static FormKey? TryResolveFormKey(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, AuthorReport report)
{
    if (index.TryGetValue(editorId, out var record))
    {
        report.Actions.Add($"Resolved {editorId} = {record.FormKey}");
        return record.FormKey;
    }
    report.Actions.Add($"Optional {editorId} not found in Devotion.esp — skipping property.");
    return null;
}

static void WireActivatorScript(SkyrimActivator activator, string scriptName, IEnumerable<ScriptProperty> properties)
{
    activator.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    activator.VirtualMachineAdapter.Version      = 5;
    activator.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(activator.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName)
{
    var script = scripts.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(p => string.Equals(p.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
        }
        script.Properties.Add(property);
    }
}

static ScriptObjectProperty ObjectProp(string name, FormKey formKey) => new()
{
    Name   = name,
    Flags  = ScriptProperty.Flag.Edited,
    Object = formKey.ToLink<ISkyrimMajorRecordGetter>(),
    Alias  = -1
};

static ScriptIntProperty IntProp(string name, int value) => new()
{
    Name  = name,
    Flags = ScriptProperty.Flag.Edited,
    Data  = value
};

static ScriptStringProperty StringProp(string name, string value) => new()
{
    Name  = name,
    Flags = ScriptProperty.Flag.Edited,
    Data  = value
};

static TranslatedString Tx(string value) => new(Language.English, value);

// ---------------------------------------------------------------------------
// Simple FormKey allocator (new mod — start at 0x000800 per ESL conventions)
// ---------------------------------------------------------------------------
sealed class SimpleAllocator
{
    private readonly ModKey modKey;
    private uint nextId = 0x000800u;

    public SimpleAllocator(ModKey modKey) { this.modKey = modKey; }

    public FormKey Next() => new(modKey, nextId++);
}

// ---------------------------------------------------------------------------
// Data types
// ---------------------------------------------------------------------------
sealed record ShrineSpec(
    string EditorId,
    string Name,
    string Model,
    string SwapFromPlugin,
    uint   SwapFromId,
    int    PrinceIndex,
    string OncePerDayKey,
    string SignalSourceId);

sealed class AuthorReport
{
    public string Status          { get; set; } = "STARTED";
    public string? OutputEspPath  { get; set; }
    public string? OutputBosPath  { get; set; }
    public bool DryRun            { get; set; }
    public bool CheckOnly         { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<string> TouchedFiles    { get; } = [];
    public List<string> Actions         { get; } = [];
    public List<string> Errors          { get; } = [];
    public List<ActivatorEntry> CreatedActivators { get; } = [];
    public string? Exception            { get; set; }
}

sealed class ActivatorEntry
{
    public string EditorId     { get; set; } = "";
    public string FormKey      { get; set; } = "";
    public string LocalId      { get; set; } = "";
    public int    SignalValue   { get; set; }
    public string SwapFromStat { get; set; } = "";
}
