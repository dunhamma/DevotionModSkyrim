using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";

var espPath = GetArg(args, "--esp") ?? defaultEsp;
var dryRun = args.Contains("--dry-run");

var report = new StartupAuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, index.Values.Select(r => r.FormKey));

    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");

    var bretonChoice = EnsureMessage(
        mod,
        index,
        allocator,
        "PDV_MSG_StartupBretonChoice",
        "Breton startup tradition",
        "High Rock raises its children to one of three traditions.\n\n" +
        "Knight's Road: mercy, protection, and the public vow.\n" +
        "Hidden Art: occult and Daedric power, openly risked.\n" +
        "Green Way: the standing stones and the old druid rites.",
        "Knight's Road",
        "Hidden Art",
        "Green Way");

    var redguardChoice = EnsureMessage(
        mod,
        index,
        allocator,
        "PDV_MSG_StartupRedguardChoice",
        "Redguard startup sect",
        "A Redguard is raised to one of three sects.\n\n" +
        "Crown: the strict old Yokudan orthodoxy.\n" +
        "Forebear: Redguard faith carried into mixed life.\n" +
        "Ash'abah: funerary duty and the unquiet dead, at a cost.",
        "Crown",
        "Forebear",
        "Ash'abah");

    var orcChoice = EnsureMessage(
        mod,
        index,
        allocator,
        "PDV_MSG_StartupOrcChoice",
        "Orc startup life mode",
        "An Orc keeps Malacath's code one of three ways.\n\n" +
        "City: faith held in private among outsiders.\n" +
        "Stronghold: the full code, lived in common.\n" +
        "Legion or exile: honor under a foreign banner.",
        "City",
        "Stronghold",
        "Legion/Exile");

    // Bosmer select (button index == path state: OldContract=0, LivingStory=1,
    // Exchange=2, BanditRoad=3 -- must stay in this order).
    var bosmerChoice = EnsureMessage(
        mod,
        index,
        allocator,
        "PDV_MSG_BosmerSetupChoice",
        "Bosmer startup path",
        "A Bosmer is raised to one of four paths.\n\n" +
        "Old Contract: the hardest Green Pact burden, and the highest reward.\n" +
        "Living Story: community kept and stories carried, under Y'ffre.\n" +
        "Exchange: debt, restitution, and fair redress, under Z'en.\n" +
        "Bandit Road: survival and reversal on the road, under Baan Dar.",
        "Old Contract",
        "Living Story",
        "Exchange",
        "Bandit Road");

    var confirmChoice = EnsureMessage(
        mod,
        index,
        allocator,
        "PDV_MSG_StartupConfirmChoice",
        "Startup confirmation",
        "The road you choose now sets where your devotion begins. Walk it?\n\n" +
        "Nothing is sealed -- how you live from here shapes the rest.",
        "Walk this path",
        "Choose again");

    // Per-path confirm screens (the merged "second screen": path name + one-paragraph
    // description + commit question + accept/decline). Removes the old detail pop-up so
    // the flow is two screens. "Choose again" returns to the selection.
    var redguardConfirmTail =
        "The road you choose now sets where your devotion begins. Walk it?\n\n" +
        "Nothing is sealed; how you live from here shapes the rest.";

    var redguardCrownConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Redguard_Crown",
        "Redguard - Crown",
        "Redguard - Crown\n\n" +
        "The Crown keeps orthodox Yokudan structure, strong ancestor duty, and the old forms preserved against the pressure of exile.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var redguardForebearConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Redguard_Forebear",
        "Redguard - Forebear",
        "Redguard - Forebear\n\n" +
        "The Forebear carries Redguard identity into mixed public life, bridging adaptation without letting the Yokudan spine break.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var redguardAshabahConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Redguard_Ashabah",
        "Redguard - Ash'abah",
        "Redguard - Ash'abah\n\n" +
        "The Ash'abah bear funerary duty and the work of the unquiet dead at real social cost. This path is narrower and heavier by design.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bretonKnightsConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Breton_KnightsRoad",
        "Breton - Knight's Road",
        "Breton - Knight's Road\n\n" +
        "The Knight's Road asks for mercy, protection, and public duty. Its friction is the pull of your vows against the easier, expedient choice.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bretonHiddenConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Breton_HiddenArt",
        "Breton - Hidden Art",
        "Breton - Hidden Art\n\n" +
        "The Hidden Art opens occult and Daedric power to you, with social exposure that rises as you go. It rewards risk taken openly, not power kept quiet.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bretonGreenConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Breton_GreenWay",
        "Breton - Green Way",
        "Breton - Green Way\n\n" +
        "The Green Way centers nature rites, the rhythm of the standing stones, and druidic belonging rather than civic standing.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var orcCityConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Orc_City",
        "Orc - City",
        "Orc - City\n\n" +
        "City life holds dignity and code in mixed society, where Orc faith is never simply given to you.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var orcStrongholdConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Orc_Stronghold",
        "Orc - Stronghold",
        "Orc - Stronghold\n\n" +
        "Stronghold life is the full expression of Malacath: labor, oath, strength, and provision held in common.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var orcLegionConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Orc_LegionExile",
        "Orc - Legion and Exile",
        "Orc - Legion and Exile\n\n" +
        "Legion and exile keep Malacath close in private, while the order around you belongs to others.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bosmerOldContractConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Bosmer_OldContract",
        "Bosmer - Old Contract",
        "Bosmer - Old Contract\n\n" +
        "The Old Contract holds you to the strict Green Pact and to Y'ffre alone. It carries the highest ceiling and the hardest fall.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bosmerExchangeConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Bosmer_Exchange",
        "Bosmer - Exchange",
        "Bosmer - Exchange\n\n" +
        "The Exchange weighs debt, return, and proportionate vengeance under Z'en. It is a moral economy, not simple kindness.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bosmerBanditConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Bosmer_BanditRoad",
        "Bosmer - Bandit Road",
        "Bosmer - Bandit Road\n\n" +
        "The Bandit Road is Baan Dar's theology of the road: reversal, trickery, and survival bought at a price.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    var bosmerLivingStoryConfirm = EnsureMessage(
        mod, index, allocator,
        "PDV_MSG_Confirm_Bosmer_LivingStory",
        "Bosmer - Living Story",
        "Bosmer - Living Story\n\n" +
        "The Living Story keeps community memory and oral continuity alive. It asks for belonging first, not covenant pushed to its limit.\n\n" +
        redguardConfirmTail,
        "Walk this path",
        "Choose again");

    WireQuestScript(manager, "PDV__ManagerQuest", new ScriptProperty[]
    {
        ObjectProp("PDV_MSG_StartupBretonChoice", bretonChoice.FormKey),
        ObjectProp("PDV_MSG_StartupRedguardChoice", redguardChoice.FormKey),
        ObjectProp("PDV_MSG_StartupOrcChoice", orcChoice.FormKey),
        ObjectProp("PDV_MSG_BosmerSetupChoice", bosmerChoice.FormKey),
        ObjectProp("PDV_MSG_StartupConfirmChoice", confirmChoice.FormKey),
        ObjectProp("PDV_MSG_Confirm_Redguard_Crown", redguardCrownConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Redguard_Forebear", redguardForebearConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Redguard_Ashabah", redguardAshabahConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Breton_KnightsRoad", bretonKnightsConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Breton_HiddenArt", bretonHiddenConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Breton_GreenWay", bretonGreenConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Orc_City", orcCityConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Orc_Stronghold", orcStrongholdConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Orc_LegionExile", orcLegionConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Bosmer_OldContract", bosmerOldContractConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Bosmer_Exchange", bosmerExchangeConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Bosmer_BanditRoad", bosmerBanditConfirm.FormKey),
        ObjectProp("PDV_MSG_Confirm_Bosmer_LivingStory", bosmerLivingStoryConfirm.FormKey),
    });

    report.Actions.Add("Created/updated startup MESG records and copy.");
    report.Actions.Add("Wired startup message properties on PDV__ManagerQuest.");

    if (!dryRun)
    {
        var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", "startup");
        Directory.CreateDirectory(backupDir);
        var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
        var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
        File.Copy(espPath, backupPath, overwrite: false);
        report.BackupPath = backupPath;

        var tempPath = $"{espPath}.startup.tmp";
        using (var stream = File.Create(tempPath))
        {
            mod.WriteToBinary(stream);
        }

        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        report.TouchedFiles.Add(espPath);
    }

    report.Status = "PASS";
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static ISkyrimMajorRecordGetter Require(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (!index.TryGetValue(editorId, out var record))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }
    return record;
}

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    var record = Require(index, editorId);
    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} is {record.GetType().Name}, expected {typeof(T).Name}.");
    }
    return typed;
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    string title,
    string text,
    params string[] buttons)
{
    Message message;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Message typed)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Message.");
        }
        message = typed;
        message.EditorID = editorId;
    }
    else
    {
        message = new Message(allocator.Next(), SkyrimRelease.SkyrimSE)
        {
            EditorID = editorId,
            FormVersion = 44
        };
        mod.Messages.Add(message);
        index[editorId] = message;
    }

    message.Flags = Message.Flag.MessageBox;
    message.FormVersion = 44;
    message.Description = Tx(text);
    message.Name = Tx(title);
    message.MenuButtons.Clear();
    foreach (var button in buttons)
    {
        message.MenuButtons.Add(new MessageButton { Text = Tx(button) });
    }

    return message;
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
    var script = scripts.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(p => string.Equals(p.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
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

static TranslatedString Tx(string value) => new(Language.English, value);

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
            .Where(k => k.ModKey.Equals(modKey))
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

sealed class StartupAuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public string? BackupPath { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public List<string> Actions { get; } = new();
    public List<string> Errors { get; } = new();
    public List<string> TouchedFiles { get; } = new();
    public string? Exception { get; set; }
}
