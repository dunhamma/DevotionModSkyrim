using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string urnEditorId = "PDV_BOOK_DunmerAncestralUrn";
const string sapEditorId = "PDV_BOOK_ArgonianHistSapToken";
const string staleSapPotionEditorId = "PDV_ALCH_ArgonianHistSap";
const string staleSapEffectEditorId = "PDV_MGEF_ArgonianHistSap";
const string managerEditorId = "PDV__ManagerQuest";
const string managerScriptName = "PDV__ManagerQuest";
const string urnScriptName = "PDV_DunmerAncestralUrn";
const string sapScriptName = "PDV_ArgonianHistSapToken";

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
    RemoveStaleSapPotionRecords(mod, index, actions);
    var sap = EnsureSapBook(mod, index, allocator, actions);
    WireBookScript(sap, sapScriptName);
    actions.Add("wired " + sapEditorId + "." + sapScriptName);

    if (index[managerEditorId] is not Quest manager)
    {
        throw new InvalidOperationException(managerEditorId + " is not a writable Quest.");
    }

    WireQuestScript(manager, managerScriptName, new[]
    {
        ObjectProp(urnEditorId, urn.FormKey),
        ObjectProp(sapEditorId, sap.FormKey)
    }, new[] { staleSapPotionEditorId });
    actions.Add("wired " + managerEditorId + "." + urnEditorId);
    actions.Add("wired " + managerEditorId + "." + sapEditorId);

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

static Book EnsureSapBook(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, List<string> actions)
{
    if (index.TryGetValue(sapEditorId, out var existing))
    {
        if (existing is not Book existingBook)
        {
            throw new InvalidOperationException(sapEditorId + " exists as " + existing.GetType().Name + ", expected Book.");
        }

        actions.Add("exists " + sapEditorId);
        return existingBook;
    }

    var book = new Book(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = sapEditorId,
        Name = Tx("Hist Sap Token"),
        BookText = Tx("The sap remembers. Touch it to hear the old root-call and return your thoughts to the Hist."),
        Value = 0,
        Weight = 0.2f
    };
    mod.Books.Add(book);
    index[sapEditorId] = book;
    actions.Add("created " + sapEditorId);
    return book;
}

static void RemoveStaleSapPotionRecords(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, List<string> actions)
{
    if (index.TryGetValue(staleSapPotionEditorId, out var stalePotion))
    {
        if (stalePotion is not Ingestible)
        {
            throw new InvalidOperationException(staleSapPotionEditorId + " exists as " + stalePotion.GetType().Name + ", expected Ingestible for cleanup.");
        }

        mod.Ingestibles.Remove(stalePotion.FormKey);
        index.Remove(staleSapPotionEditorId);
        actions.Add("removed stale " + staleSapPotionEditorId);
    }

    if (index.TryGetValue(staleSapEffectEditorId, out var staleEffect))
    {
        if (staleEffect is not MagicEffect)
        {
            throw new InvalidOperationException(staleSapEffectEditorId + " exists as " + staleEffect.GetType().Name + ", expected MagicEffect for cleanup.");
        }

        mod.MagicEffects.Remove(staleEffect.FormKey);
        index.Remove(staleSapEffectEditorId);
        actions.Add("removed stale " + staleSapEffectEditorId);
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

    if (index.ContainsKey(staleSapPotionEditorId))
    {
        errors.Add("STALE " + staleSapPotionEditorId + " drinkable ALCH still present.");
    }

    if (index.ContainsKey(staleSapEffectEditorId))
    {
        errors.Add("STALE " + staleSapEffectEditorId + " potion MGEF still present.");
    }

    if (!index.TryGetValue(sapEditorId, out var sapRecord) || sapRecord is not IBookGetter sapBook)
    {
        errors.Add("MISSING " + sapEditorId + " as BOOK.");
        return;
    }

    actions.Add("OK " + sapEditorId + " BOOK");

    if (sapBook.VirtualMachineAdapter?.Scripts.Any(script => string.Equals(script.Name, sapScriptName, StringComparison.OrdinalIgnoreCase)) == true)
    {
        actions.Add("OK " + sapEditorId + " has " + sapScriptName);
    }
    else
    {
        errors.Add("MISSING " + sapEditorId + "." + sapScriptName + " VMAD script.");
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

    prop = managerScript.Properties.FirstOrDefault(property => string.Equals(property.Name, sapEditorId, StringComparison.OrdinalIgnoreCase));
    if (prop is not ScriptObjectProperty sapObjectProp || sapObjectProp.Object.FormKeyNullable != sapRecord.FormKey)
    {
        errors.Add("MISSING " + managerEditorId + "." + sapEditorId + " property -> " + sapEditorId + ".");
    }
    else
    {
        actions.Add("OK " + managerEditorId + "." + sapEditorId);
    }

    if (managerScript.Properties.Any(property => string.Equals(property.Name, staleSapPotionEditorId, StringComparison.OrdinalIgnoreCase)))
    {
        errors.Add("STALE " + managerEditorId + "." + staleSapPotionEditorId + " property still present.");
    }
}

static void WireBookScript(Book book, string scriptName)
{
    book.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    book.VirtualMachineAdapter.Version = 5;
    book.VirtualMachineAdapter.ObjectFormat = 2;
    EnsureScript(book.VirtualMachineAdapter.Scripts, scriptName);
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
