using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
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
        var pdvSignalKey = ResolvePdvSignalEffectKey(mod, manifest!, check, report);
        var prayerSignalKeys = ResolvePrayerSignalEffectKeys(mod, manifest!, check, report);
        foreach (var target in manifest!.baselineSpellTargets!)
        {
            var isPdvSignal = target.pdvCureEffect == true;
            var hasPrayerSignal = target.pdvPrayerEffect == true;
            var signalKey = isPdvSignal ? pdvSignalKey : default;
            var prayerSignalKey = hasPrayerSignal && prayerSignalKeys.TryGetValue(target.spellEditorId!, out var resolvedPrayerKey)
                ? resolvedPrayerKey
                : default;
            var spell = EnsureSpellOverride(mod, sourceCache, target, report, check);
            if (check)
            {
                CheckNeutralizedSpell(spell, target, signalKey, isPdvSignal, prayerSignalKey, hasPrayerSignal, report);
                var message = EnsureBlessingMessageOverride(mod, sourceCache, target, report, check);
                CheckPrayerMessage(message, target, report);
            }
            else
            {
                NormalizeSpell(spell, target, signalKey, isPdvSignal, prayerSignalKey, hasPrayerSignal, report);
                CheckNeutralizedSpell(spell, target, signalKey, isPdvSignal, prayerSignalKey, hasPrayerSignal, report);
                var message = EnsureBlessingMessageOverride(mod, sourceCache, target, report, check);
                NormalizePrayerMessage(message, target, report);
                CheckPrayerMessage(message, target, report);
            }
        }

        var altarRemoveMessage = EnsureAltarRemoveMessageOverride(mod, sourceCache, manifest!, report, check);
        if (check)
        {
            CheckAltarRemoveMessage(altarRemoveMessage, manifest!, report);
        }
        else
        {
            NormalizeAltarRemoveMessage(altarRemoveMessage, manifest!, report);
            CheckAltarRemoveMessage(altarRemoveMessage, manifest!, report);
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
    if (manifest.schema != "pdv.shrine-blessing-neutralization.v4")
    {
        throw new InvalidOperationException($"Unexpected shrine manifest schema {manifest.schema ?? "(missing)"}.");
    }

    if (manifest.policy != "no-vanilla-effect")
    {
        throw new InvalidOperationException($"Unsupported shrine normalization policy {manifest.policy ?? "(missing)"}.");
    }

    if (manifest.output != "main-esp")
    {
        throw new InvalidOperationException($"Unsupported shrine normalization output {manifest.output ?? "(missing)"}.");
    }

    if (manifest.presentationPolicy != "override-temple-blessing-message")
    {
        throw new InvalidOperationException($"Unsupported shrine presentation policy {manifest.presentationPolicy ?? "(missing)"}.");
    }

    if (string.IsNullOrWhiteSpace(manifest.altarRemoveMessage) || manifest.expectedAltarRemoveText is null)
    {
        throw new InvalidOperationException("Shrine manifest must own the shared altar remove message and expected replacement text.");
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
            || string.IsNullOrWhiteSpace(target.spellEditorId))
        {
            throw new InvalidOperationException("A shrine baseline spell target is incomplete.");
        }

        if (string.IsNullOrWhiteSpace(target.expectedBlessingMessage)
            || string.IsNullOrWhiteSpace(target.expectedPrayerText))
        {
            throw new InvalidOperationException($"{target.spellEditorId}: shrine presentation message contract is incomplete.");
        }

        if (target.expectedPrayerText!.Any(c => c > 0x7F))
        {
            throw new InvalidOperationException($"{target.spellEditorId}: expected prayer text must be ASCII-only.");
        }

        if (!".!?".Contains(target.expectedPrayerText![^1]))
        {
            throw new InvalidOperationException($"{target.spellEditorId}: expected prayer text must end with terminal punctuation.");
        }

        if (target.pdvPrayerEffect == true)
        {
            if (string.IsNullOrWhiteSpace(target.primaryPrayerDeity)
                || string.IsNullOrWhiteSpace(target.oncePerDayKey)
                || string.IsNullOrWhiteSpace(target.signalSourceId)
                || string.IsNullOrWhiteSpace(target.prayerShrineLabel))
            {
                throw new InvalidOperationException($"{target.spellEditorId}: PDV prayer signal requires primaryPrayerDeity, prayerShrineLabel, oncePerDayKey, and signalSourceId.");
            }
        }

        var key = ParseFormKey(target.spellFormId!);
        if (!acceptedMasters.Contains(key.ModKey.FileName.String))
        {
            throw new InvalidOperationException($"{target.spellEditorId} belongs to unaccepted master {key.ModKey.FileName}.");
        }

        var messageKey = ParseFormKey(target.expectedBlessingMessage!);
        if (!acceptedMasters.Contains(messageKey.ModKey.FileName.String))
        {
            throw new InvalidOperationException($"{target.spellEditorId} message belongs to unaccepted master {messageKey.ModKey.FileName}.");
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

            var templeBlessing = GetObjectProperty(script, "TempleBlessing");
            if (templeBlessing is null)
            {
                continue;
            }

            var blessingMessage = GetObjectProperty(script, "BlessingMessage");
            var altarRemoveMsg = GetObjectProperty(script, "AltarRemoveMsg");

            winners[activator.FormKey] = new DiscoveredActivator
            {
                ActivatorFormId = ToHousecarl(activator.FormKey),
                EditorId = activator.EditorID,
                WinnerPlugin = pluginName,
                Script = script.Name,
                TempleBlessing = ToHousecarl(templeBlessing.Value),
                BlessingMessage = blessingMessage is null ? null : ToHousecarl(blessingMessage.Value),
                AltarRemoveMsg = altarRemoveMsg is null ? null : ToHousecarl(altarRemoveMsg.Value)
            };
        }
    }

    return winners.Values
        .OrderBy(entry => entry.TempleBlessing, StringComparer.OrdinalIgnoreCase)
        .ThenBy(entry => entry.EditorId, StringComparer.OrdinalIgnoreCase)
        .ToList();
}

static FormKey? GetObjectProperty(ScriptEntry script, string propertyName)
{
    return script.Properties
        .OfType<ScriptObjectProperty>()
        .FirstOrDefault(property => string.Equals(property.Name, propertyName, StringComparison.OrdinalIgnoreCase))
        ?.Object.FormKeyNullable;
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

static Message EnsureBlessingMessageOverride(
    SkyrimMod mod,
    Dictionary<string, SkyrimMod> sourceCache,
    ShrineSpellTarget target,
    ShrineReport report,
    bool checkOnly)
{
    var formKey = ParseFormKey(target.expectedBlessingMessage!);
    var existing = mod.Messages.Records.FirstOrDefault(message => message.FormKey.Equals(formKey));
    if (existing is not null)
    {
        report.Actions.Add($"{target.spellEditorId}: using existing prayer-message override {target.expectedBlessingMessage}.");
        return existing;
    }

    if (checkOnly)
    {
        report.Errors.Add($"{target.spellEditorId}: missing main-ESP message override for {target.expectedBlessingMessage}.");
        return new Message(formKey, SkyrimRelease.SkyrimSE);
    }

    var sourceMod = LoadSourceMod(sourceCache, formKey.ModKey.FileName.String);
    var source = sourceMod.Messages.Records.FirstOrDefault(message => message.FormKey.Equals(formKey))
        ?? throw new InvalidOperationException($"{target.spellEditorId}: source message {target.expectedBlessingMessage} not found in {formKey.ModKey.FileName}.");
    var copy = new Message(formKey, SkyrimRelease.SkyrimSE);
    CopyMessageSurface(source, copy);
    mod.Messages.Add(copy);
    report.Actions.Add($"{target.spellEditorId}: created main-ESP prayer-message override from {formKey.ModKey.FileName}.");
    return copy;
}

static void CopyMessageSurface(Message source, Message target)
{
    target.EditorID = source.EditorID;
    target.FormVersion = source.FormVersion;
    target.Name = source.Name;
    target.Description = source.Description;
    target.DisplayTime = source.DisplayTime;
    target.Flags = source.Flags;
    target.Quest = source.Quest;
    target.MenuButtons.Clear();
    foreach (var button in source.MenuButtons)
    {
        target.MenuButtons.Add(new MessageButton { Text = button.Text });
    }
}

static void NormalizePrayerMessage(Message message, ShrineSpellTarget target, ShrineReport report)
{
    if (message.FormKey.ModKey.IsNull)
    {
        return;
    }

    message.Description = Tx(target.expectedPrayerText!);
    report.Actions.Add($"{target.spellEditorId}: set prayer message {target.expectedBlessingMessage} to \"{target.expectedPrayerText}\".");
}

static void CheckPrayerMessage(Message message, ShrineSpellTarget target, ShrineReport report)
{
    if (message.FormKey.ModKey.IsNull)
    {
        return;
    }

    var actualText = message.Description?.String ?? "";
    if (!string.Equals(actualText, target.expectedPrayerText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{target.spellEditorId}: prayer message text is \"{actualText}\", expected \"{target.expectedPrayerText}\".");
    }
}

static Message EnsureAltarRemoveMessageOverride(
    SkyrimMod mod,
    Dictionary<string, SkyrimMod> sourceCache,
    ShrineManifest manifest,
    ShrineReport report,
    bool checkOnly)
{
    var formKey = ParseFormKey(manifest.altarRemoveMessage!);
    var existing = mod.Messages.Records.FirstOrDefault(message => message.FormKey.Equals(formKey));
    if (existing is not null)
    {
        report.Actions.Add($"AltarRemoveMsg: using existing main-ESP override {manifest.altarRemoveMessage}.");
        return existing;
    }

    if (checkOnly)
    {
        report.Errors.Add($"AltarRemoveMsg: missing main-ESP message override for {manifest.altarRemoveMessage}.");
        return new Message(formKey, SkyrimRelease.SkyrimSE);
    }

    var sourceMod = LoadSourceMod(sourceCache, formKey.ModKey.FileName.String);
    var source = sourceMod.Messages.Records.FirstOrDefault(message => message.FormKey.Equals(formKey))
        ?? throw new InvalidOperationException($"AltarRemoveMsg: source message {manifest.altarRemoveMessage} not found in {formKey.ModKey.FileName}.");
    var copy = new Message(formKey, SkyrimRelease.SkyrimSE);
    CopyMessageSurface(source, copy);
    mod.Messages.Add(copy);
    report.Actions.Add($"AltarRemoveMsg: created main-ESP override from {formKey.ModKey.FileName}.");
    return copy;
}

static void NormalizeAltarRemoveMessage(Message message, ShrineManifest manifest, ShrineReport report)
{
    if (message.FormKey.ModKey.IsNull)
    {
        return;
    }

    message.Description = Tx(manifest.expectedAltarRemoveText!);
    message.DisplayTime = 0;
    report.Actions.Add($"AltarRemoveMsg: blanked vanilla disease/blessing-removal text on {manifest.altarRemoveMessage}.");
}

static void CheckAltarRemoveMessage(Message message, ShrineManifest manifest, ShrineReport report)
{
    if (message.FormKey.ModKey.IsNull)
    {
        return;
    }

    var actualText = message.Description?.String ?? "";
    if (!string.Equals(actualText, manifest.expectedAltarRemoveText, StringComparison.Ordinal))
    {
        report.Errors.Add($"AltarRemoveMsg: text is \"{actualText}\", expected blank suppression text.");
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

// PDV detection signal: a hidden Script MagicEffect carrying PDV_DunmerShrinePrayerEffect.
// The three DLC2 Good-Daedra altar spells keep this one hidden signal so the shrine click can
// route the Dunmer outdoor-shrine twilight hook without curing disease or granting a blessing.
static FormKey ResolvePdvSignalEffectKey(SkyrimMod mod, ShrineManifest manifest, bool checkOnly, ShrineReport report)
{
    var needsPdvSignal = (manifest.baselineSpellTargets ?? []).Any(t => t.pdvCureEffect == true);
    if (!needsPdvSignal)
    {
        return default;
    }

    const string editorId = "PDV_MGEF_DunmerShrineCure";
    var existing = mod.MagicEffects.Records.FirstOrDefault(effect => string.Equals(effect.EditorID, editorId, StringComparison.OrdinalIgnoreCase));
    if (existing is not null)
    {
        if (checkOnly)
        {
            CheckDunmerShrineSignalEffect(existing, report);
        }
        else
        {
            NormalizeDunmerShrineSignalEffect(existing, report);
            CheckDunmerShrineSignalEffect(existing, report);
        }

        return existing.FormKey;
    }

    if (checkOnly)
    {
        report.Errors.Add($"{editorId}: missing from framework ESP (run --write first).");
        return default;
    }

    return AuthorDunmerShrineSignalEffect(mod, report);
}

static FormKey AuthorDunmerShrineSignalEffect(SkyrimMod mod, ShrineReport report)
{
    var effect = mod.MagicEffects.AddNew();
    effect.EditorID = "PDV_MGEF_DunmerShrineCure";
    NormalizeDunmerShrineSignalEffect(effect, report);
    report.Actions.Add($"PDV_MGEF_DunmerShrineCure: authored hidden PDV_DunmerShrinePrayerEffect signal {ToHousecarl(effect.FormKey)}.");
    return effect.FormKey;
}

static void NormalizeDunmerShrineSignalEffect(MagicEffect effect, ShrineReport report)
{
    effect.FormVersion = 44;
    effect.Name = "Devotion Shrine Prayer Signal";
    effect.Flags = MagicEffect.Flag.NoArea
        | MagicEffect.Flag.NoDuration
        | MagicEffect.Flag.HideInUI
        | MagicEffect.Flag.NoHitEvent
        | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    effect.CastType = CastType.FireAndForget;
    effect.TargetType = TargetType.Self;
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter
    {
        Version = 5,
        ObjectFormat = 2
    };
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    effect.VirtualMachineAdapter.Scripts.Clear();
    effect.VirtualMachineAdapter.Scripts.Add(new ScriptEntry
    {
        Name = "PDV_DunmerShrinePrayerEffect",
        Flags = ScriptEntry.Flag.Local
    });
    report.Actions.Add("PDV_MGEF_DunmerShrineCure: normalized to hidden script-only shrine signal.");
}

static void CheckDunmerShrineSignalEffect(MagicEffect effect, ShrineReport report)
{
    if (effect.Archetype is not MagicEffectArchetype archetype || archetype.Type != MagicEffectArchetype.TypeEnum.Script)
    {
        report.Errors.Add("PDV_MGEF_DunmerShrineCure: expected Script archetype, not CureDisease or another gameplay archetype.");
    }

    if (!effect.Flags.HasFlag(MagicEffect.Flag.HideInUI))
    {
        report.Errors.Add("PDV_MGEF_DunmerShrineCure: expected HideInUI flag.");
    }

    var hasSignalScript = effect.VirtualMachineAdapter?.Scripts.Any(script => string.Equals(script.Name, "PDV_DunmerShrinePrayerEffect", StringComparison.OrdinalIgnoreCase)) == true;
    if (!hasSignalScript)
    {
        report.Errors.Add("PDV_MGEF_DunmerShrineCure: expected PDV_DunmerShrinePrayerEffect script.");
    }
}

static Dictionary<string, FormKey> ResolvePrayerSignalEffectKeys(SkyrimMod mod, ShrineManifest manifest, bool checkOnly, ShrineReport report)
{
    var result = new Dictionary<string, FormKey>(StringComparer.OrdinalIgnoreCase);
    foreach (var target in manifest.baselineSpellTargets ?? [])
    {
        if (target.pdvPrayerEffect != true)
        {
            continue;
        }

        var editorId = GetPrayerSignalEditorId(target);
        var existing = mod.MagicEffects.Records.FirstOrDefault(effect => string.Equals(effect.EditorID, editorId, StringComparison.OrdinalIgnoreCase));
        if (existing is not null)
        {
            if (checkOnly)
            {
                CheckPrayerSignalEffect(existing, target, report);
            }
            else
            {
                NormalizePrayerSignalEffect(existing, target, report);
                CheckPrayerSignalEffect(existing, target, report);
            }
            result[target.spellEditorId!] = existing.FormKey;
            continue;
        }

        if (checkOnly)
        {
            report.Errors.Add($"{editorId}: missing from framework ESP (run --write first).");
            continue;
        }

        var authored = AuthorPrayerSignalEffect(mod, target, report);
        result[target.spellEditorId!] = authored;
    }

    return result;
}

static FormKey AuthorPrayerSignalEffect(SkyrimMod mod, ShrineSpellTarget target, ShrineReport report)
{
    var effect = mod.MagicEffects.AddNew();
    effect.EditorID = GetPrayerSignalEditorId(target);
    NormalizePrayerSignalEffect(effect, target, report);
    report.Actions.Add($"{effect.EditorID}: authored hidden PDV_ShrinePrayerEffect signal {ToHousecarl(effect.FormKey)}.");
    return effect.FormKey;
}

static void NormalizePrayerSignalEffect(MagicEffect effect, ShrineSpellTarget target, ShrineReport report)
{
    effect.FormVersion = 44;
    effect.Name = $"Devotion Shrine Prayer - {target.prayerShrineLabel}";
    effect.Flags = MagicEffect.Flag.NoArea
        | MagicEffect.Flag.NoDuration
        | MagicEffect.Flag.HideInUI
        | MagicEffect.Flag.NoHitEvent
        | MagicEffect.Flag.NoHitEffect;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    effect.CastType = CastType.FireAndForget;
    effect.TargetType = TargetType.Self;
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter
    {
        Version = 5,
        ObjectFormat = 2
    };
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    effect.VirtualMachineAdapter.Scripts.Clear();
    effect.VirtualMachineAdapter.Scripts.Add(new ScriptEntry
    {
        Name = "PDV_ShrinePrayerEffect",
        Flags = ScriptEntry.Flag.Local,
        Properties =
        {
            StringProp("PrimaryDeityName", target.primaryPrayerDeity ?? ""),
            StringProp("SecondaryDeityName", target.secondaryPrayerDeity ?? ""),
            StringProp("TertiaryDeityName", target.tertiaryPrayerDeity ?? ""),
            StringProp("ShrineLabel", target.prayerShrineLabel ?? target.deity ?? ""),
            StringProp("SourceId", target.signalSourceId ?? ""),
            StringProp("OncePerDayKey", target.oncePerDayKey ?? "")
        }
    });
    report.Actions.Add($"{effect.EditorID}: normalized to hidden once-per-day PDV shrine-prayer signal.");
}

static void CheckPrayerSignalEffect(MagicEffect effect, ShrineSpellTarget target, ShrineReport report)
{
    if (effect.Archetype is not MagicEffectArchetype archetype || archetype.Type != MagicEffectArchetype.TypeEnum.Script)
    {
        report.Errors.Add($"{GetPrayerSignalEditorId(target)}: expected Script archetype.");
    }

    if (!effect.Flags.HasFlag(MagicEffect.Flag.HideInUI))
    {
        report.Errors.Add($"{GetPrayerSignalEditorId(target)}: expected HideInUI flag.");
    }

    var script = effect.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV_ShrinePrayerEffect", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{GetPrayerSignalEditorId(target)}: expected PDV_ShrinePrayerEffect script.");
        return;
    }

    CheckStringProperty(script, "PrimaryDeityName", target.primaryPrayerDeity ?? "", GetPrayerSignalEditorId(target), report);
    CheckStringProperty(script, "SecondaryDeityName", target.secondaryPrayerDeity ?? "", GetPrayerSignalEditorId(target), report);
    CheckStringProperty(script, "TertiaryDeityName", target.tertiaryPrayerDeity ?? "", GetPrayerSignalEditorId(target), report);
    CheckStringProperty(script, "ShrineLabel", target.prayerShrineLabel ?? target.deity ?? "", GetPrayerSignalEditorId(target), report);
    CheckStringProperty(script, "SourceId", target.signalSourceId ?? "", GetPrayerSignalEditorId(target), report);
    CheckStringProperty(script, "OncePerDayKey", target.oncePerDayKey ?? "", GetPrayerSignalEditorId(target), report);
}

static void CheckStringProperty(ScriptEntry script, string propertyName, string expected, string owner, ShrineReport report)
{
    var prop = script.Properties
        .OfType<ScriptStringProperty>()
        .FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (prop is null || prop.Data != expected)
    {
        report.Errors.Add($"{owner}: property {propertyName} is {prop?.Data ?? "(missing)"}, expected {expected}.");
    }
}

static string GetPrayerSignalEditorId(ShrineSpellTarget target)
{
    var suffix = new string((target.deity ?? target.spellEditorId ?? "Unknown")
        .Where(char.IsLetterOrDigit)
        .ToArray());
    return $"PDV_MGEF_ShrinePrayer_{suffix}";
}

static void NormalizeSpell(Spell spell, ShrineSpellTarget target, FormKey signalKey, bool isPdvSignal, FormKey prayerSignalKey, bool hasPrayerSignal, ShrineReport report)
{
    var before = spell.Effects.Count;
    spell.Effects.Clear();
    if (hasPrayerSignal && !prayerSignalKey.IsNull)
    {
        spell.Effects.Add(new Effect
        {
            BaseEffect = new FormLinkNullable<IMagicEffectGetter>(prayerSignalKey),
            Data = new EffectData
            {
                Magnitude = 0.0f,
                Area = 0,
                Duration = 0
            },
            Conditions = []
        });
    }

    if (isPdvSignal && !signalKey.IsNull)
    {
        spell.Effects.Add(new Effect
        {
            BaseEffect = new FormLinkNullable<IMagicEffectGetter>(signalKey),
            Data = new EffectData
            {
                Magnitude = 0.0f,
                Area = 0,
                Duration = 0
            },
            Conditions = []
        });
        report.Actions.Add($"{target.spellEditorId}: normalized from {before} effect(s) to hidden PDV shrine signal set.");
        return;
    }

    report.Actions.Add(hasPrayerSignal
        ? $"{target.spellEditorId}: normalized from {before} effect(s) to hidden PDV shrine-prayer signal."
        : $"{target.spellEditorId}: normalized from {before} effect(s) to zero gameplay effects.");
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

static void CheckNeutralizedSpell(Spell spell, ShrineSpellTarget target, FormKey signalKey, bool isPdvSignal, FormKey prayerSignalKey, bool hasPrayerSignal, ShrineReport report)
{
    if (spell.FormKey.ModKey.IsNull)
    {
        return;
    }

    if (!string.Equals(spell.EditorID, target.spellEditorId, StringComparison.OrdinalIgnoreCase))
    {
        report.Errors.Add($"{target.spellEditorId}: override EditorID is {spell.EditorID ?? "(missing)"}.");
    }

    var expectedCount = 0;
    if (hasPrayerSignal)
    {
        expectedCount += 1;
    }
    if (isPdvSignal)
    {
        expectedCount += 1;
    }

    if (spell.Effects.Count != expectedCount)
    {
        report.Errors.Add($"{target.spellEditorId}: expected {expectedCount} hidden PDV signal effect(s), found {spell.Effects.Count}.");
        return;
    }

    if (hasPrayerSignal && !spell.Effects.Any(effect => effect.BaseEffect.FormKey.Equals(prayerSignalKey)))
    {
        report.Errors.Add($"{target.spellEditorId}: expected hidden shrine-prayer signal {ToHousecarl(prayerSignalKey)}.");
    }

    if (isPdvSignal)
    {
        if (!spell.Effects.Any(effect => effect.BaseEffect.FormKey.Equals(signalKey)))
        {
            report.Errors.Add($"{target.spellEditorId}: expected hidden Dunmer shrine signal {ToHousecarl(signalKey)}.");
        }

        return;
    }
}

static void CheckDiscoveryCoverage(ShrineManifest manifest, ShrineReport report)
{
    var normalizedSpells = (manifest.baselineSpellTargets ?? [])
        .Select(target => NormalizeManifestFormId(target.spellFormId!))
        .ToHashSet(StringComparer.OrdinalIgnoreCase);
    var expectedMessagesBySpell = (manifest.baselineSpellTargets ?? [])
        .Where(target => !string.IsNullOrWhiteSpace(target.expectedBlessingMessage))
        .ToDictionary(
            target => NormalizeManifestFormId(target.spellFormId!),
            target => NormalizeManifestFormId(target.expectedBlessingMessage!),
            StringComparer.OrdinalIgnoreCase);
    var reviewedActivators = (manifest.activatorTargets ?? [])
        .Select(target => NormalizeManifestFormId(target.activatorFormId!))
        .ToHashSet(StringComparer.OrdinalIgnoreCase);

    foreach (var activator in report.DiscoveredActivators)
    {
        var blessing = NormalizeManifestFormId(activator.TempleBlessing!);
        var activatorKey = NormalizeManifestFormId(activator.ActivatorFormId!);
        if (normalizedSpells.Contains(blessing))
        {
            if (!string.IsNullOrWhiteSpace(activator.BlessingMessage)
                && expectedMessagesBySpell.TryGetValue(blessing, out var expectedMessage)
                && NormalizeManifestFormId(activator.BlessingMessage!) != expectedMessage)
            {
                report.Errors.Add($"{activator.EditorId} ({activator.ActivatorFormId}) uses blessing message {activator.BlessingMessage}; expected {expectedMessage} for {activator.TempleBlessing}.");
            }

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
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
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

static TranslatedString Tx(string value) => new(Language.English, value);

static ScriptStringProperty StringProp(string name, string value)
{
    return new ScriptStringProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
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

sealed class ShrineManifest
{
    public string? schema { get; set; }
    public string? status { get; set; }
    public string? policy { get; set; }
    public string? presentationPolicy { get; set; }
    public string? presentationSurface { get; set; }
    public string? output { get; set; }
    public string? sourcePlugin { get; set; }
    public List<string>? acceptedMasters { get; set; }
    public string? coreCureEffect { get; set; }
    public string? altarRemoveMessage { get; set; }
    public string? expectedAltarRemoveText { get; set; }
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
    public string? expectedBlessingMessage { get; set; }
    public string? expectedPrayerText { get; set; }
    public bool? pdvCureEffect { get; set; }
    public bool? pdvPrayerEffect { get; set; }
    public string? primaryPrayerDeity { get; set; }
    public string? secondaryPrayerDeity { get; set; }
    public string? tertiaryPrayerDeity { get; set; }
    public string? prayerShrineLabel { get; set; }
    public string? oncePerDayKey { get; set; }
    public string? signalSourceId { get; set; }
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
    public string? BlessingMessage { get; set; }
    public string? AltarRemoveMsg { get; set; }
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
