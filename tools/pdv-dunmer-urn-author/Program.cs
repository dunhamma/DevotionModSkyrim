using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string urnEditorId = "PDV_BOOK_DunmerAncestralUrn";
const string sapManagerPropertyName = "PDV_BOOK_ArgonianHistSapToken";
const string staleSapBookEditorId = "PDV_BOOK_ArgonianHistSapToken";
const string sapPotionEditorId = "PDV_ALCH_ArgonianHistSap";
const string sapEffectEditorId = "PDV_MGEF_ArgonianHistSap";
const string managerEditorId = "PDV__ManagerQuest";
const string managerScriptName = "PDV__ManagerQuest";
const string urnScriptName = "PDV_DunmerAncestralUrn";
const string sapScriptName = "PDV_ArgonianHistSapToken";
const string sapModelPath = @"meshes\clutter\potions\potionfortifyhealratelesser.nif";

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var actions = new List<string>();
var errors = new List<string>();
string? backupPath = null;

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);

    if (checkOnly)
    {
        CheckState(index, actions, errors);
        Report(errors.Count == 0 ? "PASS" : "FAIL");
        return errors.Count == 0 ? 0 : 1;
    }

    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
    var urn = EnsureUrnBook(mod, index, allocator, actions);
    WireBookScript(urn, urnScriptName);
    actions.Add("wired " + urnEditorId + "." + urnScriptName);
    RemoveStaleSapBookRecords(mod, index, actions);
    var sapEffect = EnsureSapMagicEffect(mod, index, allocator, actions);
    var sap = EnsureSapPotion(mod, index, allocator, sapEffect.FormKey, actions);
    WireMagicEffectScript(sapEffect, sapScriptName, new[] { ObjectProp(sapPotionEditorId, sap.FormKey) });
    actions.Add("wired " + sapEffectEditorId + "." + sapScriptName);
    actions.Add("ensured " + sapPotionEditorId + " ALCH vial");

    if (index[managerEditorId] is not Quest manager)
    {
        throw new InvalidOperationException(managerEditorId + " is not a writable Quest.");
    }

    WireQuestScript(manager, managerScriptName, new[]
    {
        ObjectProp(urnEditorId, urn.FormKey),
        ObjectProp(sapManagerPropertyName, sap.FormKey)
    }, new[] { sapPotionEditorId });
    actions.Add("wired " + managerEditorId + "." + urnEditorId);
    actions.Add("wired " + managerEditorId + "." + sapManagerPropertyName);

    CheckState(index, actions, errors);
    if (errors.Count > 0)
    {
        Report("FAIL");
        return 1;
    }

    if (!dryRun)
    {
        var backupDir = Path.Combine(Path.GetDirectoryName(espPath)!, "Backups", "dunmer-urn");
        Directory.CreateDirectory(backupDir);
        var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
        backupPath = Path.Combine(backupDir, "Devotion.esp." + stamp + ".bak");
        File.Copy(espPath, backupPath, overwrite: false);
        var tempPath = espPath + ".dunmer-urn.tmp";
        using (var stream = File.Create(tempPath))
        {
            mod.WriteToBinary(stream);
        }
        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        actions.Add("wrote " + espPath);
    }
    else
    {
        actions.Add("dry-run: no write");
    }

    Report("PASS");
    return 0;
}
catch (Exception ex)
{
    errors.Add(ex.GetType().Name + ": " + ex.Message);
    Report("FAIL");
    return 1;
}

void Report(string status)
{
    Console.WriteLine(JsonSerializer.Serialize(new
    {
        status,
        dryRun,
        checkOnly,
        espPath,
        backupPath,
        actions,
        errors
    }, new JsonSerializerOptions { WriteIndented = true }));
}

static Book EnsureUrnBook(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, List<string> actions)
{
    if (index.TryGetValue(urnEditorId, out var existing))
    {
        if (existing is not Book existingBook)
        {
            throw new InvalidOperationException(urnEditorId + " exists as " + existing.GetType().Name + ", expected Book.");
        }

        actions.Add("exists " + urnEditorId);
        return existingBook;
    }

    var book = new Book(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = urnEditorId,
        Name = Tx("Ancestral Urn"),
        BookText = Tx("The ash is warm. Speak the names of the dead, and keep the old obligations close."),
        Value = 0,
        Weight = 0.5f
    };
    mod.Books.Add(book);
    index[urnEditorId] = book;
    actions.Add("created " + urnEditorId);
    return book;
}

static Ingestible EnsureSapPotion(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, FormKey effectFormKey, List<string> actions)
{
    Ingestible potion;
    if (index.TryGetValue(sapPotionEditorId, out var existing))
    {
        if (existing is not Ingestible existingPotion)
        {
            throw new InvalidOperationException(sapPotionEditorId + " exists as " + existing.GetType().Name + ", expected Ingestible.");
        }

        potion = existingPotion;
        actions.Add("updated " + sapPotionEditorId + " ALCH");
    }
    else
    {
        potion = new Ingestible(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Ingestibles.Add(potion);
        index[sapPotionEditorId] = potion;
        actions.Add("created " + sapPotionEditorId);
    }

    potion.EditorID = sapPotionEditorId;
    potion.Name = Tx("Hist Sap Vial");
    potion.Value = 0;
    potion.Weight = 0.2f;
    potion.Model ??= new Model();
    potion.Model.File = sapModelPath;
    potion.Effects.Clear();
    potion.Effects.Add(new Effect
    {
        BaseEffect = effectFormKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData { Magnitude = 0.0f, Area = 0, Duration = 0 },
        Conditions = []
    });
    return potion;
}

static MagicEffect EnsureSapMagicEffect(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, List<string> actions)
{
    MagicEffect effect;
    if (index.TryGetValue(sapEffectEditorId, out var existing))
    {
        if (existing is not MagicEffect existingEffect)
        {
            throw new InvalidOperationException(sapEffectEditorId + " exists as " + existing.GetType().Name + ", expected MagicEffect.");
        }

        effect = existingEffect;
        actions.Add("updated " + sapEffectEditorId + " MGEF");
    }
    else
    {
        effect = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(effect);
        index[sapEffectEditorId] = effect;
        actions.Add("created " + sapEffectEditorId);
    }

    effect.EditorID = sapEffectEditorId;
    effect.Name = Tx("Hist Sap Communion");
    effect.FormVersion = 44;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script);
    effect.CastType = CastType.FireAndForget;
    effect.TargetType = TargetType.Self;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
    return effect;
}

static void RemoveStaleSapBookRecords(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, List<string> actions)
{
    if (index.TryGetValue(staleSapBookEditorId, out var staleBook))
    {
        if (staleBook is Book book)
        {
            mod.Books.Remove(book.FormKey);
            index.Remove(staleSapBookEditorId);
            actions.Add("removed stale " + staleSapBookEditorId + " BOOK");
        }
        else if (staleBook is MiscItem misc)
        {
            mod.MiscItems.Remove(misc.FormKey);
            index.Remove(staleSapBookEditorId);
            actions.Add("removed stale " + staleSapBookEditorId + " MISC");
        }
        else
        {
            throw new InvalidOperationException(staleSapBookEditorId + " exists as " + staleBook.GetType().Name + ", expected stale Book or MiscItem.");
        }
    }
}

static void CheckState(Dictionary<string, ISkyrimMajorRecordGetter> index, List<string> actions, List<string> errors)
{
    if (!index.TryGetValue(urnEditorId, out var urnRecord) || urnRecord is not IBookGetter urnBook)
    {
        errors.Add("MISSING " + urnEditorId + " as BOOK.");
        return;
    }

    actions.Add("OK " + urnEditorId + " BOOK");

    if (urnBook.VirtualMachineAdapter?.Scripts.Any(script => string.Equals(script.Name, urnScriptName, StringComparison.OrdinalIgnoreCase)) == true)
    {
        actions.Add("OK " + urnEditorId + " has " + urnScriptName);
    }
    else
    {
        errors.Add("MISSING " + urnEditorId + "." + urnScriptName + " VMAD script.");
    }

    if (index.ContainsKey(staleSapBookEditorId))
    {
        errors.Add("STALE " + staleSapBookEditorId + " BOOK/MISC token still present.");
    }

    if (!index.TryGetValue(sapEffectEditorId, out var sapEffectRecord) || sapEffectRecord is not IMagicEffectGetter sapEffect)
    {
        errors.Add("MISSING " + sapEffectEditorId + " as MGEF.");
        return;
    }

    actions.Add("OK " + sapEffectEditorId + " MGEF");
    if (sapEffect.Archetype is not MagicEffectArchetype sapArchetype || sapArchetype.Type != MagicEffectArchetype.TypeEnum.Script)
    {
        errors.Add("MISMATCH " + sapEffectEditorId + " archetype; expected Script.");
        return;
    }
    actions.Add("OK " + sapEffectEditorId + " script archetype");

    var effectScript = sapEffect.VirtualMachineAdapter?.Scripts.FirstOrDefault(script => string.Equals(script.Name, sapScriptName, StringComparison.OrdinalIgnoreCase));
    if (effectScript is null)
    {
        errors.Add("MISSING " + sapEffectEditorId + "." + sapScriptName + " VMAD script.");
    }
    else
    {
        actions.Add("OK " + sapEffectEditorId + " has " + sapScriptName);
        CheckObjectProperty(effectScript, sapPotionEditorId, index.TryGetValue(sapPotionEditorId, out var potionForProp) ? potionForProp.FormKey : default, sapEffectEditorId, actions, errors);
    }

    if (!index.TryGetValue(sapPotionEditorId, out var sapRecord) || sapRecord is not IIngestibleGetter sapPotion)
    {
        errors.Add("MISSING " + sapPotionEditorId + " as ALCH.");
        return;
    }

    actions.Add("OK " + sapPotionEditorId + " ALCH");
    var sapModel = sapPotion.Model?.File.ToString();
    if (!string.Equals(sapModel, sapModelPath, StringComparison.OrdinalIgnoreCase))
    {
        errors.Add("MISMATCH " + sapPotionEditorId + " model path; expected " + sapModelPath + ".");
    }
    else
    {
        actions.Add("OK " + sapPotionEditorId + " model " + sapModelPath);
    }

    if (sapPotion.Effects.Count != 1 || sapPotion.Effects[0].BaseEffect.FormKeyNullable != sapEffectRecord.FormKey)
    {
        errors.Add("MISMATCH " + sapPotionEditorId + " effect list; expected single " + sapEffectEditorId + " effect.");
    }
    else
    {
        actions.Add("OK " + sapPotionEditorId + " effect -> " + sapEffectEditorId);
    }

    if (!index.TryGetValue(managerEditorId, out var managerRecord) || managerRecord is not IQuestGetter manager)
    {
        errors.Add("MISSING " + managerEditorId + " as QUST.");
        return;
    }

    var managerScript = manager.VirtualMachineAdapter?.Scripts.FirstOrDefault(script => string.Equals(script.Name, managerScriptName, StringComparison.OrdinalIgnoreCase));
    if (managerScript is null)
    {
        errors.Add("MISSING " + managerEditorId + "." + managerScriptName + " VMAD script.");
        return;
    }

    var prop = managerScript.Properties.FirstOrDefault(property => string.Equals(property.Name, urnEditorId, StringComparison.OrdinalIgnoreCase));
    if (prop is not ScriptObjectProperty objectProp || objectProp.Object.FormKeyNullable != urnRecord.FormKey)
    {
        errors.Add("MISSING " + managerEditorId + "." + urnEditorId + " property -> " + urnEditorId + ".");
    }
    else
    {
        actions.Add("OK " + managerEditorId + "." + urnEditorId);
    }

    prop = managerScript.Properties.FirstOrDefault(property => string.Equals(property.Name, sapManagerPropertyName, StringComparison.OrdinalIgnoreCase));
    if (prop is not ScriptObjectProperty sapObjectProp || sapObjectProp.Object.FormKeyNullable != sapRecord.FormKey)
    {
        errors.Add("MISSING " + managerEditorId + "." + sapManagerPropertyName + " property -> " + sapPotionEditorId + ".");
    }
    else
    {
        actions.Add("OK " + managerEditorId + "." + sapManagerPropertyName);
    }

    if (managerScript.Properties.Any(property => string.Equals(property.Name, sapPotionEditorId, StringComparison.OrdinalIgnoreCase)))
    {
        errors.Add("STALE " + managerEditorId + "." + sapPotionEditorId + " property still present.");
    }
}

static void WireBookScript(Book book, string scriptName)
{
    book.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    book.VirtualMachineAdapter.Version = 5;
    book.VirtualMachineAdapter.ObjectFormat = 2;
    EnsureScript(book.VirtualMachineAdapter.Scripts, scriptName);
}

static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
{
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, scriptName);
    foreach (var property in properties)
    {
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
        }
        script.Properties.Add(property);
    }
}

static void CheckObjectProperty(IScriptEntryGetter script, string propertyName, FormKey expectedFormKey, string owner, List<string> actions, List<string> errors)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptObjectProperty objectProperty)
    {
        errors.Add("MISSING " + owner + "." + propertyName + " object property.");
        return;
    }

    if (objectProperty.Object.FormKeyNullable != expectedFormKey)
    {
        errors.Add("MISMATCH " + owner + "." + propertyName + "; expected " + expectedFormKey + ".");
        return;
    }

    actions.Add("OK " + owner + "." + propertyName);
}

static void WireQuestScript(Quest quest, string scriptName, IEnumerable<ScriptProperty> properties, IEnumerable<string>? stalePropertyNames = null)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    quest.VirtualMachineAdapter.Version = 5;
    quest.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(quest.VirtualMachineAdapter.Scripts, scriptName);
    foreach (var stalePropertyName in stalePropertyNames ?? Array.Empty<string>())
    {
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, stalePropertyName, StringComparison.OrdinalIgnoreCase)) is { } stale)
        {
            script.Properties.Remove(stale);
        }
    }

    foreach (var property in properties)
    {
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
        {
            script.Properties.Remove(existing);
        }
        script.Properties.Add(property);
    }
}

static ScriptEntry EnsureScript(IList<ScriptEntry> scripts, string scriptName)
{
    var script = scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script is not null)
    {
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .ToDictionary(record => record.EditorID!, StringComparer.OrdinalIgnoreCase);
}

static string? GetArg(string[] arguments, string name)
{
    var index = Array.IndexOf(arguments, name);
    if (index < 0 || index + 1 >= arguments.Length)
    {
        return null;
    }

    return arguments[index + 1];
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
        usedIds = existingKeys.Where(key => key.ModKey.Equals(modKey)).Select(key => Convert.ToUInt32(key.IDString(), 16)).ToHashSet();
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
}
