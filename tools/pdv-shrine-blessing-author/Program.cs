using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultManifest = @"references\authoring\PDV_ShrineBlessingNeutralization.manifest.json";
const string anvilRoot = @"D:\Wabbajack\modlists\Anvil";
const string stockData = @"D:\Wabbajack\modlists\Anvil\Stock Game\Data";
const string profileDir = @"D:\Wabbajack\modlists\Anvil\profiles\Devotion Dev";
var discover = args.Contains("--discover");
var dryRun = args.Contains("--dry-run");
var write = args.Contains("--write");
var check = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var manifestPath = Path.GetFullPath(GetArg(args, "--manifest") ?? defaultManifest);

var selectedModes = new[] { discover, dryRun, write, check }.Count(value => value);
var report = new ShrineReport
{
    Mode = discover ? "discover" : dryRun ? "dry-run" : write ? "write" : check ? "check" : "none",
    EspPath = espPath,
    ManifestPath = manifestPath,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (selectedModes != 1)
    {
        throw new InvalidOperationException("Choose exactly one mode: --discover, --dry-run, --write, or --check.");
    }

    ShrineManifest? manifest = null;
    if (File.Exists(manifestPath))
    {
        manifest = LoadManifest(manifestPath);
        ValidateManifest(manifest);
    }
    else if (!discover)
    {
        throw new FileNotFoundException("Shrine neutralization manifest not found.", manifestPath);
    }

    if (discover)
    {
        report.DiscoveredActivators.AddRange(DiscoverBlessingActivators());
        if (manifest is not null)
        {
            CheckDiscoveryCoverage(manifest, report);
        }
    }
    else
    {
        if (!File.Exists(espPath))
        {
            throw new FileNotFoundException("Framework ESP not found.", espPath);
        }

        var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
        var sourceCache = new Dictionary<string, SkyrimMod>(StringComparer.OrdinalIgnoreCase);
        var pdvCureKey = ResolvePdvCureEffectKey(mod, manifest!, check, report);
        foreach (var target in manifest!.baselineSpellTargets!)
        {
            var isPdvCure = target.pdvCureEffect == true;
            var cureKey = isPdvCure ? pdvCureKey : ParseFormKey(target.expectedCureEffect!);
            var spell = EnsureSpellOverride(mod, sourceCache, target, report, check);
            if (check)
            {
                CheckCureOnly(spell, target, cureKey, report);
            }
            else
            {
                NormalizeSpell(spell, target, cureKey, isPdvCure, report);
                CheckCureOnly(spell, target, cureKey, report);
            }
        }

        if (check)
        {
            report.DiscoveredActivators.AddRange(DiscoverBlessingActivators());
            CheckDiscoveryCoverage(manifest, report);
        }
        else
        {
            WriteModIfNeeded(mod, espPath, dryRun, write, report);
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

static ShrineManifest LoadManifest(string manifestPath)
{
    return JsonSerializer.Deserialize<ShrineManifest>(File.ReadAllText(manifestPath), new JsonSerializerOptions
    {
        PropertyNameCaseInsensitive = true
    }) ?? throw new InvalidOperationException("Shrine neutralization manifest did not parse.");
}

static void ValidateManifest(ShrineManifest manifest)
{
    if (manifest.schema != "pdv.shrine-blessing-neutralization.v1")
    {
        throw new InvalidOperationException($"Unexpected shrine manifest schema {manifest.schema ?? "(missing)"}.");
    }

    if (manifest.policy != "cure-only")
    {
        throw new InvalidOperationException($"Unsupported shrine normalization policy {manifest.policy ?? "(missing)"}.");
    }

    if (manifest.output != "main-esp")
    {
        throw new InvalidOperationException($"Unsupported shrine normalization output {manifest.output ?? "(missing)"}.");
    }

    if (manifest.baselineSpellTargets is null || manifest.baselineSpellTargets.Count != 14)
    {
        throw new InvalidOperationException("Shrine manifest must contain exactly fourteen baseline spell targets.");
    }

    var acceptedMasters = new HashSet<string>(manifest.acceptedMasters ?? [], StringComparer.OrdinalIgnoreCase);
    foreach (var target in manifest.baselineSpellTargets)
    {
        if (string.IsNullOrWhiteSpace(target.deity)
            || string.IsNullOrWhiteSpace(target.spellFormId)
            || string.IsNullOrWhiteSpace(target.spellEditorId)
            || string.IsNullOrWhiteSpace(target.expectedCureEffect))
        {
            throw new InvalidOperationException("A shrine baseline spell target is incomplete.");
        }

        var key = ParseFormKey(target.spellFormId!);
        if (!acceptedMasters.Contains(key.ModKey.FileName.String))
        {
            throw new InvalidOperationException($"{target.spellEditorId} belongs to unaccepted master {key.ModKey.FileName}.");
        }
    }
}

static List<DiscoveredActivator> DiscoverBlessingActivators()
{
    var activePluginNames = ReadPluginNames(Path.Combine(profileDir, "plugins.txt"));
    foreach (var implicitMaster in new[] { "Skyrim.esm", "Update.esm", "Dawnguard.esm", "HearthFires.esm", "Dragonborn.esm" })
    {
        if (!activePluginNames.Contains(implicitMaster, StringComparer.OrdinalIgnoreCase))
        {
            activePluginNames.Insert(0, implicitMaster);
        }
    }

    var activePluginSet = activePluginNames.ToHashSet(StringComparer.OrdinalIgnoreCase);
    var loadOrderNames = ReadPluginNames(Path.Combine(profileDir, "loadorder.txt"));
    var pluginPaths = BuildPluginPathMap();
    var winners = new Dictionary<FormKey, DiscoveredActivator>();
    var scanOrder = loadOrderNames.Where(activePluginSet.Contains).ToList();
    foreach (var pluginName in activePluginNames.Where(name => !scanOrder.Contains(name, StringComparer.OrdinalIgnoreCase)))
    {
        scanOrder.Add(pluginName);
    }

    foreach (var pluginName in scanOrder)
    {
        if (!pluginPaths.TryGetValue(pluginName, out var pluginPath) || !File.Exists(pluginPath))
        {
            continue;
        }

        SkyrimMod mod;
        try
        {
            mod = SkyrimMod.CreateFromBinary(pluginPath, SkyrimRelease.SkyrimSE);
        }
        catch
        {
            continue;
        }

        foreach (var activator in mod.Activators.Records)
        {
            var script = activator.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => IsBlessingScript(candidate.Name));
            if (script is null)
            {
                continue;
            }

            var templeBlessing = script.Properties
                .OfType<ScriptObjectProperty>()
                .FirstOrDefault(property => string.Equals(property.Name, "TempleBlessing", StringComparison.OrdinalIgnoreCase))
                ?.Object.FormKeyNullable;
            if (templeBlessing is null)
            {
                continue;
            }

            winners[activator.FormKey] = new DiscoveredActivator
            {
                ActivatorFormId = ToHousecarl(activator.FormKey),
                EditorId = activator.EditorID,
                WinnerPlugin = pluginName,
                Script = script.Name,
                TempleBlessing = ToHousecarl(templeBlessing.Value)
            };
        }
    }

    return winners.Values
        .OrderBy(entry => entry.TempleBlessing, StringComparer.OrdinalIgnoreCase)
        .ThenBy(entry => entry.EditorId, StringComparer.OrdinalIgnoreCase)
        .ToList();
}

static Dictionary<string, string> BuildPluginPathMap()
{
    var result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    foreach (var file in Directory.Exists(stockData) ? Directory.EnumerateFiles(stockData, "*.*", SearchOption.TopDirectoryOnly) : [])
    {
        if (IsPlugin(file))
        {
            result[Path.GetFileName(file)] = file;
        }
    }

    var modList = Path.Combine(profileDir, "modlist.txt");
    if (!File.Exists(modList))
    {
        return result;
    }

    var enabledMods = File.ReadAllLines(modList)
        .Select(line => line.Trim())
        .Where(line => line.StartsWith("+", StringComparison.Ordinal))
        .Select(line => line[1..])
        .Where(name => !string.IsNullOrWhiteSpace(name))
        .ToList();

    foreach (var modName in enabledMods)
    {
        var dataDir = Path.Combine(anvilRoot, "mods", modName);
        if (!Directory.Exists(dataDir))
        {
            continue;
        }

        foreach (var file in Directory.EnumerateFiles(dataDir, "*.*", SearchOption.AllDirectories).Where(IsPlugin))
        {
            result[Path.GetFileName(file)] = file;
        }
    }

    return result;
}

static List<string> ReadPluginNames(string filePath)
{
    if (!File.Exists(filePath))
    {
        return [];
    }

    var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    return File.ReadAllLines(filePath)
        .Select(line => line.Trim())
        .Where(line => !string.IsNullOrWhiteSpace(line) && !line.StartsWith("#", StringComparison.Ordinal) && !line.StartsWith("*#", StringComparison.Ordinal))
        .Select(line => line.TrimStart('*'))
        .Where(IsPluginName)
        .Where(seen.Add)
        .ToList();
}

static Spell EnsureSpellOverride(
    SkyrimMod mod,
    Dictionary<string, SkyrimMod> sourceCache,
    ShrineSpellTarget target,
    ShrineReport report,
    bool checkOnly)
{
    var formKey = ParseFormKey(target.spellFormId!);
    var existing = mod.Spells.Records.FirstOrDefault(spell => spell.FormKey.Equals(formKey));
    if (existing is not null)
    {
        report.Actions.Add($"{target.spellEditorId}: using existing main-ESP override.");
        return existing;
    }

    if (checkOnly)
    {
        report.Errors.Add($"{target.spellEditorId}: missing main-ESP override for {target.spellFormId}.");
        return new Spell(formKey, SkyrimRelease.SkyrimSE);
    }

    var sourceMod = LoadSourceMod(sourceCache, formKey.ModKey.FileName.String);
    var source = sourceMod.Spells.Records.FirstOrDefault(spell => spell.FormKey.Equals(formKey))
        ?? throw new InvalidOperationException($"{target.spellEditorId}: source spell {target.spellFormId} not found in {formKey.ModKey.FileName}.");
    var copy = new Spell(formKey, SkyrimRelease.SkyrimSE);
    CopySpellSurface(source, copy);
    mod.Spells.Add(copy);
    report.Actions.Add($"{target.spellEditorId}: created main-ESP override from {formKey.ModKey.FileName}.");
    return copy;
}

static void CopySpellSurface(Spell source, Spell target)
{
    target.EditorID = source.EditorID;
    target.FormVersion = source.FormVersion;
    target.ObjectBounds = source.ObjectBounds;
    target.Name = source.Name;
    target.Description = source.Description;
    target.EquipmentType = source.EquipmentType;
    target.BaseCost = source.BaseCost;
    target.Flags = source.Flags;
    target.Type = source.Type;
    target.ChargeTime = source.ChargeTime;
    target.CastType = source.CastType;
    target.TargetType = source.TargetType;
    target.CastDuration = source.CastDuration;
    target.Range = source.Range;
    target.Effects.Clear();
    foreach (var effect in source.Effects)
    {
        target.Effects.Add(CopyEffect(effect));
    }
}

static SkyrimMod LoadSourceMod(Dictionary<string, SkyrimMod> sourceCache, string pluginName)
{
    if (sourceCache.TryGetValue(pluginName, out var cached))
    {
        return cached;
    }

    var pluginPaths = BuildPluginPathMap();
    if (!pluginPaths.TryGetValue(pluginName, out var pluginPath) || !File.Exists(pluginPath))
    {
        throw new FileNotFoundException($"Source master not found for shrine spell override: {pluginName}", Path.Combine(stockData, pluginName));
    }

    var mod = SkyrimMod.CreateFromBinary(pluginPath, SkyrimRelease.SkyrimSE);
    sourceCache[pluginName] = mod;
    return mod;
}

// PDV detection cure effect: a CureDisease MagicEffect that also carries the
// PDV_DunmerShrinePrayerEffect ActiveMagicEffect script. The three DLC2 Good-Daedra altar
// spells use this instead of vanilla 0FBFF5 so that activating the shrine (which casts the
// neutralized cure spell) fires OnEffectStart and routes the Dunmer outdoor-shrine twilight
// signal, while still curing disease.
static FormKey ResolvePdvCureEffectKey(SkyrimMod mod, ShrineManifest manifest, bool checkOnly, ShrineReport report)
{
    var needsPdvCure = (manifest.baselineSpellTargets ?? []).Any(t => t.pdvCureEffect == true);
    if (!needsPdvCure)
    {
        return default;
    }

    const string editorId = "PDV_MGEF_DunmerShrineCure";
    var existing = mod.MagicEffects.Records.FirstOrDefault(effect => string.Equals(effect.EditorID, editorId, StringComparison.OrdinalIgnoreCase));
    if (existing is not null)
    {
        return existing.FormKey;
    }

    if (checkOnly)
    {
        report.Errors.Add($"{editorId}: missing from framework ESP (run --write first).");
        return default;
    }

    return AuthorDunmerShrineCureEffect(mod, report);
}

static FormKey AuthorDunmerShrineCureEffect(SkyrimMod mod, ShrineReport report)
{
    var effect = mod.MagicEffects.AddNew();
    effect.EditorID = "PDV_MGEF_DunmerShrineCure";
    effect.FormVersion = 44;
    effect.Name = "Cure Disease";
    effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.CureDisease);
    effect.CastType = CastType.FireAndForget;
    effect.TargetType = TargetType.Self;
    effect.VirtualMachineAdapter = new VirtualMachineAdapter
    {
        Version = 5,
        ObjectFormat = 2
    };
    effect.VirtualMachineAdapter.Scripts.Add(new ScriptEntry
    {
        Name = "PDV_DunmerShrinePrayerEffect",
        Flags = ScriptEntry.Flag.Local
    });
    report.Actions.Add($"PDV_MGEF_DunmerShrineCure: authored CureDisease + PDV_DunmerShrinePrayerEffect detection effect {ToHousecarl(effect.FormKey)}.");
    return effect.FormKey;
}

static void NormalizeSpell(Spell spell, ShrineSpellTarget target, FormKey cureKey, bool isPdvCure, ShrineReport report)
{
    var cureEntries = spell.Effects.Where(effect => effect.BaseEffect.FormKey.Equals(cureKey)).ToList();
    if (cureEntries.Count == 1)
    {
        var keepCount = spell.Effects.Count;
        var preservedCure = CopyEffect(cureEntries[0]);
        spell.Effects.Clear();
        spell.Effects.Add(preservedCure);
        report.Actions.Add($"{target.spellEditorId}: normalized from {keepCount} effect(s) to cure-only.");
        return;
    }

    if (isPdvCure && !cureKey.IsNull)
    {
        var swapCount = spell.Effects.Count;
        var template = spell.Effects.FirstOrDefault();
        var swapped = new Effect
        {
            BaseEffect = new FormLinkNullable<IMagicEffectGetter>(cureKey),
            Data = template?.Data is null ? null : new EffectData
            {
                Magnitude = template.Data.Magnitude,
                Area = template.Data.Area,
                Duration = template.Data.Duration
            },
            Conditions = []
        };
        spell.Effects.Clear();
        spell.Effects.Add(swapped);
        report.Actions.Add($"{target.spellEditorId}: swapped from {swapCount} effect(s) to PDV cure effect {ToHousecarl(cureKey)}.");
        return;
    }

    report.Errors.Add($"{target.spellEditorId}: expected exactly one cure effect {target.expectedCureEffect}, found {cureEntries.Count}.");
}

static Effect CopyEffect(Effect source)
{
    return new Effect
    {
        BaseEffect = source.BaseEffect,
        Data = source.Data is null ? null : new EffectData
        {
            Magnitude = source.Data.Magnitude,
            Area = source.Data.Area,
            Duration = source.Data.Duration
        },
        Conditions = []
    };
}

static void CheckCureOnly(Spell spell, ShrineSpellTarget target, FormKey cureKey, ShrineReport report)
{
    if (spell.FormKey.ModKey.IsNull)
    {
        return;
    }

    if (!string.Equals(spell.EditorID, target.spellEditorId, StringComparison.OrdinalIgnoreCase))
    {
        report.Errors.Add($"{target.spellEditorId}: override EditorID is {spell.EditorID ?? "(missing)"}.");
    }

    if (spell.Effects.Count != 1)
    {
        report.Errors.Add($"{target.spellEditorId}: expected one cure-only effect, found {spell.Effects.Count}.");
        return;
    }

    var onlyEffect = spell.Effects[0];
    if (!onlyEffect.BaseEffect.FormKey.Equals(cureKey))
    {
        report.Errors.Add($"{target.spellEditorId}: remaining effect is {ToHousecarl(onlyEffect.BaseEffect.FormKey)}, expected {ToHousecarl(cureKey)}.");
    }
}

static void CheckDiscoveryCoverage(ShrineManifest manifest, ShrineReport report)
{
    var normalizedSpells = (manifest.baselineSpellTargets ?? [])
        .Select(target => NormalizeManifestFormId(target.spellFormId!))
        .ToHashSet(StringComparer.OrdinalIgnoreCase);
    var reviewedActivators = (manifest.activatorTargets ?? [])
        .Select(target => NormalizeManifestFormId(target.activatorFormId!))
        .ToHashSet(StringComparer.OrdinalIgnoreCase);

    foreach (var activator in report.DiscoveredActivators)
    {
        var blessing = NormalizeManifestFormId(activator.TempleBlessing!);
        var activatorKey = NormalizeManifestFormId(activator.ActivatorFormId!);
        if (normalizedSpells.Contains(blessing))
        {
            continue;
        }

        if (reviewedActivators.Contains(activatorKey))
        {
            continue;
        }

        report.Errors.Add($"{activator.EditorId} ({activator.ActivatorFormId}) resolves to unnormalized blessing spell {activator.TempleBlessing}.");
    }

    report.Actions.Add($"Discovered {report.DiscoveredActivators.Count} clickable blessing activator(s).");
}

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, bool write, ShrineReport report)
{
    if (dryRun)
    {
        report.Actions.Add("Dry run only; no ESP bytes changed.");
        return;
    }

    if (!write)
    {
        return;
    }

    if (report.Errors.Count > 0)
    {
        report.Actions.Add("Write skipped: errors present. No ESP bytes changed.");
        return;
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "shrine-blessing-neutralization");
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;

    var tempPath = $"{espPath}.shrine-blessing-neutralization.tmp";
    using (var stream = File.Create(tempPath))
    {
        mod.WriteToBinary(stream);
    }

    File.Copy(tempPath, espPath, overwrite: true);
    File.Delete(tempPath);
    report.TouchedFiles.Add(espPath);
}

static bool IsBlessingScript(string? scriptName)
{
    return !string.IsNullOrWhiteSpace(scriptName)
        && (string.Equals(scriptName, "TempleBlessingScript", StringComparison.OrdinalIgnoreCase)
            || string.Equals(scriptName, "DLC2TempleShrineScript", StringComparison.OrdinalIgnoreCase));
}

static bool IsPlugin(string filePath) => IsPluginName(Path.GetFileName(filePath));

static bool IsPluginName(string value)
{
    return value.EndsWith(".esm", StringComparison.OrdinalIgnoreCase)
        || value.EndsWith(".esp", StringComparison.OrdinalIgnoreCase)
        || value.EndsWith(".esl", StringComparison.OrdinalIgnoreCase);
}

static FormKey ParseFormKey(string value)
{
    var parts = value.Split(':', 2);
    if (parts.Length != 2)
    {
        throw new InvalidOperationException($"Invalid FormID token {value}.");
    }

    if (parts[0].Length == 6 && uint.TryParse(parts[0], System.Globalization.NumberStyles.HexNumber, null, out var id))
    {
        return new FormKey(ModKey.FromNameAndExtension(parts[1]), id);
    }

    if (parts[1].Length == 6 && uint.TryParse(parts[1], System.Globalization.NumberStyles.HexNumber, null, out var reversedId))
    {
        return new FormKey(ModKey.FromNameAndExtension(parts[0]), reversedId);
    }

    throw new InvalidOperationException($"Invalid FormID token {value}.");
}

static string NormalizeManifestFormId(string value)
{
    var key = ParseFormKey(value);
    return $"{key.ModKey.FileName.String.ToLowerInvariant()}:{key.IDString().ToUpperInvariant()}";
}

static string ToHousecarl(FormKey key) => $"{key.IDString().ToUpperInvariant()}:{key.ModKey.FileName}";

static string? GetArg(string[] args, string name)
{
    var index = Array.IndexOf(args, name);
    if (index < 0 || index + 1 >= args.Length)
    {
        return null;
    }

    return args[index + 1];
}

sealed class ShrineManifest
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public string? policy { get; set; }
    public string? output { get; set; }
    public string? sourcePlugin { get; set; }
    public List<string>? acceptedMasters { get; set; }
    public string? coreCureEffect { get; set; }
    public List<ShrineSpellTarget>? baselineSpellTargets { get; set; }
    public List<ShrineActivatorTarget>? activatorTargets { get; set; }
}

sealed class ShrineSpellTarget
{
    public string? deity { get; set; }
    public string? spellFormId { get; set; }
    public string? spellEditorId { get; set; }
    public string? sourceActivator { get; set; }
    public string? sourceActivatorEditorId { get; set; }
    public string? winnerPlugin { get; set; }
    public string? expectedCureEffect { get; set; }
    public List<string>? expectedRemovedEffects { get; set; }
    public bool? pdvCureEffect { get; set; }
}

sealed class ShrineActivatorTarget
{
    public string? activatorFormId { get; set; }
    public string? editorId { get; set; }
    public string? winnerPlugin { get; set; }
    public string? script { get; set; }
    public string? templeBlessing { get; set; }
    public string? status { get; set; }
}

sealed class DiscoveredActivator
{
    public string? ActivatorFormId { get; set; }
    public string? EditorId { get; set; }
    public string? WinnerPlugin { get; set; }
    public string? Script { get; set; }
    public string? TempleBlessing { get; set; }
}

sealed class ShrineReport
{
    public string Status { get; set; } = "STARTED";
    public string? Mode { get; set; }
    public string? EspPath { get; set; }
    public string? ManifestPath { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public List<DiscoveredActivator> DiscoveredActivators { get; } = [];
    public string? Exception { get; set; }
}
