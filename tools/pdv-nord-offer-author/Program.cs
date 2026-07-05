// pdv-nord-offer-author
// Authors the non-Kyne Nord commitment-offer MESG records into Devotion.esp
// (B10; 12 per-deity offers + the Old Ways Orkey variant of the Arkay offer).
// The show-logic + candidate->message mapping + button handling already
// exist in the manager: GetFormalCommitmentOfferMessage maps all the deities,
// ShowFormalCommitmentOffer .Show() handles choice 0=Accept / 1=Not yet / 2=Refuse.
// So this is pure MESG authoring (copy from race-sheets/PDV_RaceContent_Manifest.md
// section 10.6) + VMAD forward-wiring of the 12 manager properties. Mirrors the
// proven pdv-6f-rite-author / pdv-bosmer-variety-author pattern: in-place + backup,
// idempotent, fail-closed, --dry-run / --check.
//
// Button order MUST be [Accept, Not yet, Refuse] -> indices 0/1/2 match the manager.

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerScriptName = "PDV__ManagerQuest";
string[] offerButtons = { "Accept", "Not yet", "Refuse" };

// God-voice offer bodies, verbatim from the manifest (section 10.6). All ASCII.
var offers = new[]
{
    new OfferDef("PDV_Msg_Nord_Shor_Offer", "Shor Calls You",
        "Your sword has stayed honest to the last blow, and Tsun has counted every fall. I am keeping a seat at my table for you. Take the name of Shor now and walk to my hall as one who is awaited, or hold to the broad road and prove it further."),
    new OfferDef("PDV_Msg_Nord_Tsun_Offer", "Tsun Weighs You",
        "I have watched you stand where lesser men would have run, against odds that should have ended you. The weighing is nearly done. Take the shield-thane's mark now and be known at the crossing, or come to Shor's bridge unweighed and let the trials decide."),
    new OfferDef("PDV_Msg_Nord_Stuhn_Offer", "Stuhn Sees the Open Hand",
        "You have spared the beaten and freed the bound when cruelty would have been the easier road. The open hand can be your banner. Carry the ransom-keeper's name now, or wait, and let me test the mercy in you further."),
    new OfferDef("PDV_Msg_Nord_Akatosh_Offer", "Akatosh Marks the Hour",
        "Day upon day, unbroken, you have kept faith while others let theirs fray. The line does not slip in your hands. Take the dragon's keeping now and let time hold what you hold, or measure your hours further before you choose."),
    new OfferDef("PDV_Msg_Nord_Mara_Offer", "Mara Opens the Door",
        "You have made a hearth where there was none and held families that were breaking. The warmth you gave can be a door that is always open to you. Let me hold that hearth with you now, or stay welcome among the many a while longer."),
    new OfferDef("PDV_Msg_Nord_Arkay_Offer", "Arkay's Covenant",
        "You have given the dead their rites when the living would not, and turned back what should not walk. The cycle holds because you hold it. Walk now as keeper of the covenant, or come to the door again when you are ready."),
    // Old Ways variant of the Arkay offer: the Old Ways baseline knows Arkay by the
    // older Nord name Orkey (owner directive 2026-07-05). Same deity, same rewards;
    // GetNordFormalCommitmentOfferMessage picks this MESG when the baseline is Old Ways.
    new OfferDef("PDV_Msg_Nord_Orkey_Offer", "Orkey Counts the Years",
        "You have laid the dead down with their due and driven back what would not stay buried. I keep the count of every year, and I have kept yours well. Take the Old Knocker's mark now and hold the count with me, or let the door stand shut a while yet."),
    new OfferDef("PDV_Msg_Nord_Stendarr_Offer", "Stendarr Stays the Hand",
        "You have stayed the killing blow again and again, where wrath was the easy road. Mercy chosen so often becomes a wall no blade passes lightly. Take my mercy as your armor now, or hold the question open and be tested further."),
    new OfferDef("PDV_Msg_Nord_Zenithar_Offer", "Zenithar Names the Honest Hand",
        "Every weight you kept true, every trade you made fair, has been counted. The honest hand makes holy work. Carry the trade-god's name now and let your craft mean more than its making, or stay among the broad a while."),
    new OfferDef("PDV_Msg_Nord_Julianos_Offer", "Julianos Reads You",
        "You have studied with a patience few keep, until the arts answered as a friend answers. Wisdom in you is used, not stored. Carry the name of the schools now, or read further before you bind yourself to them."),
    new OfferDef("PDV_Msg_Nord_Dibella_Offer", "Dibella's Recognition",
        "You have made beauty where you walked and spoken the word that lands. What you give to the world, the world gives back. Carry my craft openly now, or stay among the loved a while longer."),
    new OfferDef("PDV_Msg_Nord_Talos_Offer", "Talos Marks the Defier",
        "You would not let them silence me. Carry the old breath openly now, and Tamriel will hear Talos through you. Or hold the secret close and walk the broad road yet, until you are ready to be marked."),
    new OfferDef("PDV_Msg_Nord_Kynareth_Offer", "Kynareth Calls the Traveler",
        "The road has been good to you because I am good to the road. The open sky already steadies your step. Carry my name now, traveler, and let the wind go with you, or hold to the broad reverence a while longer."),
};

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

var report = new AuthorReport { EspPath = espPath, DryRun = dryRun, CheckOnly = checkOnly, StartedAt = DateTimeOffset.Now };

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod);
    var managerQuest = RequireRecord<Quest>(index, managerScriptName);
    var wiring = new List<(string Property, FormKey Key)>();

    if (!checkOnly)
    {
        foreach (var offer in offers)
        {
            var message = EnsureMessage(mod, index, allocator, offer.EditorId, report, m =>
            {
                m.Name = Tx(offer.Title);
                m.Description = Tx(offer.Body);
                m.Flags = Message.Flag.MessageBox;
                m.MenuButtons.Clear();
                foreach (var label in offerButtons)
                {
                    m.MenuButtons.Add(new MessageButton { Text = Tx(label) });
                }
            });
            wiring.Add((offer.EditorId, message.FormKey));
        }

        WireQuestScript(managerQuest, managerScriptName, wiring.Select(e => (ScriptProperty)ObjectProp(e.Property, e.Key)));
        report.Actions.Add($"Wired {wiring.Count} Nord offer properties on {managerScriptName}.");
    }

    // Checks (always run; --check runs ONLY these).
    foreach (var offer in offers)
    {
        CheckMessageButtons(index, offer.EditorId, offerButtons.Length, report);
    }
    CheckManagerWiring(managerQuest, managerScriptName, offers.Select(o => o.EditorId), report);

    if (!checkOnly)
    {
        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report, "nord-offer");
        }
        else
        {
            report.Actions.Add("Write skipped: errors present (fail-closed). No ESP bytes changed.");
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

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords().OfType<ISkyrimMajorRecordGetter>()
        .Where(r => !string.IsNullOrWhiteSpace(r.EditorID))
        .GroupBy(r => r.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(g => g.Key, g => g.First(), StringComparer.OrdinalIgnoreCase);
}

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
    where T : class, ISkyrimMajorRecordGetter
{
    if (!index.TryGetValue(editorId, out var existing))
    {
        throw new InvalidOperationException($"{editorId} not found in the framework ESP.");
    }
    if (existing is not T typed)
    {
        throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected {typeof(T).Name}.");
    }
    return typed;
}

static Message EnsureMessage(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, AuthorReport report, Action<Message> configure)
{
    Message message;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Message m)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected Message.");
        }
        message = m;
        report.Actions.Add($"Reconfigured message {editorId}.");
    }
    else
    {
        message = new Message(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Messages.Add(message);
        index[editorId] = message;
        report.Actions.Add($"Created message {editorId}.");
    }
    message.EditorID = editorId;
    message.FormVersion = 44;
    configure(message);
    return message;
}

static void CheckMessageButtons(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, int expectedButtons, AuthorReport report)
{
    if (!index.TryGetValue(editorId, out var record) || record is not Message message)
    {
        report.Errors.Add($"{editorId}: missing or not a Message.");
        return;
    }
    if (message.MenuButtons.Count != expectedButtons)
    {
        report.Errors.Add($"{editorId}: expected {expectedButtons} buttons, found {message.MenuButtons.Count}.");
        return;
    }
    var labels = string.Join(" | ", message.MenuButtons.Select((b, slot) => $"{slot}:{b.Text?.String}"));
    report.Actions.Add($"{editorId}: buttons [{labels}]");
}

static void CheckManagerWiring(Quest managerQuest, string managerScriptName, IEnumerable<string> expectedProperties, AuthorReport report)
{
    var script = managerQuest.VirtualMachineAdapter?.Scripts.FirstOrDefault(c => string.Equals(c.Name, managerScriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{managerScriptName} is missing its manager VMAD script.");
        return;
    }
    foreach (var propertyName in expectedProperties)
    {
        var property = script.Properties.FirstOrDefault(c => string.Equals(c.Name, propertyName, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty || objectProperty.Object.FormKeyNullable is null)
        {
            report.Errors.Add($"{managerScriptName} VMAD property {propertyName} is missing or unresolved.");
        }
        else
        {
            report.Actions.Add($"{managerScriptName}.{propertyName} -> {objectProperty.Object.FormKeyNullable} [ok]");
        }
    }
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
    var script = scripts.FirstOrDefault(c => string.Equals(c.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(c => string.Equals(c.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
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

static void WriteModIfNeeded(SkyrimMod mod, string espPath, bool dryRun, AuthorReport report, string backupSubdir)
{
    if (dryRun)
    {
        return;
    }
    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", backupSubdir);
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
    File.Copy(espPath, backupPath, overwrite: false);
    report.BackupPath = backupPath;
    var tempPath = $"{espPath}.{backupSubdir}.tmp";
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

sealed record OfferDef(string EditorId, string Title, string Body);

sealed class AuthorReport
{
    public string Status { get; set; } = "UNKNOWN";
    public string? EspPath { get; set; }
    public bool DryRun { get; set; }
    public bool CheckOnly { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = new();
    public List<string> Actions { get; } = new();
    public List<string> Errors { get; } = new();
    public string? Exception { get; set; }
}

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod)
    {
        modKey = mod.ModKey;
        usedIds = mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(r => r.FormKey)
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
