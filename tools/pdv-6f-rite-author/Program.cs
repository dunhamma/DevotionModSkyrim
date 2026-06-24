// pdv-6f-rite-author
// One-batch Mutagen author for the three 6f variety RITES (clone of the proven
// pdv-bosmer-variety-author pattern; no FLST/shader/watcher -- these rites are
// sleep-triggered, no pilgrimage). Writes in-place to Devotion.esp, backs up first,
// idempotent (Ensure* reconfigures), VMAD-wires the new PDV__ManagerQuest properties.
//
//   Orc   -- PDV_MESG_Orc_TrialOfIron (menu only; the 4 Trial SPEL/MGEF already exist)
//   Redguard -- 4 Remember abilities (+MGEF) + PDV_MSG_RedguardRemembering
//   Altmer   -- 4 Discipline abilities (+MGEF) + PDV_MESG_AltmerDisciplines
//
// Button order MUST equal the manager's Get<Race>...Spell(index) order (0-3 = ability,
// 4 = Not yet). Regen rate AVs use PeakValueModifier (durable convention). Altmer
// disciplines ship as +5 school-skill abilities (the build-guaranteed AV); the locked
// "-5% cost" is a tuning option pending the Fortify-school archetype confirmation.
//
// Flags: --esp <path>, --dry-run, --check (verify-only; never writes).

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerScriptName = "PDV__ManagerQuest";

// One-active discipline/observance abilities (ConstantEffect; manager enforces clear-before-add).
// peakRate=true -> PeakValueModifier (regen rate AVs); false -> ValueModifier.
var abilities = new[]
{
    new AbilityDef("PDV_SPEL_RedguardRemember_Blade", "PDV_MGEF_RedguardRemember_Blade", "The Blade",
        "You remember the blade. Your sword-arm is surer. (Effect: +5 One-Handed.)",
        ActorValue.OneHanded, 5.0f, false),
    new AbilityDef("PDV_SPEL_RedguardRemember_Road", "PDV_MGEF_RedguardRemember_Road", "The Road",
        "You remember the road. The wind carries you on. (Effect: +8% Stamina Regeneration.)",
        ActorValue.StaminaRateMult, 8.0f, true),
    new AbilityDef("PDV_SPEL_RedguardRemember_Rest", "PDV_MGEF_RedguardRemember_Rest", "The Rest",
        "You remember the rest owed the dead. You knit together more readily. (Effect: +5% Health Regeneration.)",
        ActorValue.HealRateMult, 5.0f, true),
    new AbilityDef("PDV_SPEL_RedguardRemember_Harvest", "PDV_MGEF_RedguardRemember_Harvest", "The Harvest",
        "You remember the harvest and its fair measure. Bargains fall your way. (Effect: +5 Speech.)",
        ActorValue.Speech, 5.0f, false),
    new AbilityDef("PDV_SPEL_AltmerDiscipline_Alteration", "PDV_MGEF_AltmerDiscipline_Alteration", "Discipline of Alteration",
        "You set the discipline of Alteration. The shaping arts come easier. (Effect: +5 Alteration.)",
        ActorValue.Alteration, 5.0f, false),
    new AbilityDef("PDV_SPEL_AltmerDiscipline_Destruction", "PDV_MGEF_AltmerDiscipline_Destruction", "Discipline of Destruction",
        "You set the discipline of Destruction. The destroying arts come easier. (Effect: +5 Destruction.)",
        ActorValue.Destruction, 5.0f, false),
    new AbilityDef("PDV_SPEL_AltmerDiscipline_Illusion", "PDV_MGEF_AltmerDiscipline_Illusion", "Discipline of Illusion",
        "You set the discipline of Illusion. The seeming arts come easier. (Effect: +5 Illusion.)",
        ActorValue.Illusion, 5.0f, false),
    new AbilityDef("PDV_SPEL_AltmerDiscipline_Restoration", "PDV_MGEF_AltmerDiscipline_Restoration", "Discipline of Restoration",
        "You set the discipline of Restoration. The restoring arts come easier. (Effect: +5 Restoration.)",
        ActorValue.Restoration, 5.0f, false),
};

// Rite menus. Button order == manager Get<Race>...Spell(index) order; index 4 = "Not yet".
var menus = new[]
{
    new MenuDef("PDV_MESG_Orc_TrialOfIron", "The Trial of Iron",
        "The Code is held in iron. Take up one discipline of the Trial.\nOne holds at a time; choosing again takes up a new one.\n\nTusk: Unarmed Damage +5\nShield: Armor Rating +5\nHammer: Smithing +5\nYoke: Carry Weight +15",
        new[] { "Tusk", "Shield", "Hammer", "Yoke", "Not yet" }),
    new MenuDef("PDV_MSG_RedguardRemembering", "The Remembering of Names",
        "The old line is kept by remembering. Take up one observance.\nOne holds at a time; choosing again takes up a new one.\n\nBlade: One-Handed +5\nRoad: Stamina Regen +8%\nRest: Health Regen +5%\nHarvest: Speech +5",
        new[] { "Blade", "Road", "Rest", "Harvest", "Not yet" }),
    new MenuDef("PDV_MESG_AltmerDisciplines", "The Disciplines of Return",
        "The Return is made daily in the disciplines. Cultivate one.\nOne holds at a time; choosing again takes up a new one.\n\nAlteration: +5\nDestruction: +5\nIllusion: +5\nRestoration: +5",
        new[] { "Alteration", "Destruction", "Illusion", "Restoration", "Not yet" }),
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
        // 1) Abilities: constant-effect AV mods, one active at a time (manager-enforced).
        foreach (var ability in abilities)
        {
            var mgef = EnsureMagicEffect(mod, index, allocator, ability.MgefEditorId, report, effect =>
            {
                effect.Name = Tx(ability.DisplayName);
                effect.Description = Tx(ability.PlayerFacingText);
                effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
                effect.Archetype = new MagicEffectArchetype(ability.PeakRate
                    ? MagicEffectArchetype.TypeEnum.PeakValueModifier
                    : MagicEffectArchetype.TypeEnum.ValueModifier)
                {
                    ActorValue = ability.ActorValue
                };
                effect.CastType = CastType.ConstantEffect;
                effect.TargetType = TargetType.Self;
            });
            var spell = EnsureSpell(mod, index, allocator, ability.SpellEditorId, report, s =>
            {
                s.Name = Tx(ability.DisplayName);
                s.Description = Tx(ability.PlayerFacingText);
                s.Type = SpellType.Ability;
                s.CastType = CastType.ConstantEffect;
                s.TargetType = TargetType.Self;
                SetSingleEffect(s, mgef.FormKey, ability.Magnitude, duration: 0);
            });
            wiring.Add((ability.SpellEditorId, spell.FormKey));
        }

        // 2) Rite menus.
        foreach (var menu in menus)
        {
            var message = EnsureMessage(mod, index, allocator, menu.EditorId, report, m =>
            {
                m.Name = Tx(menu.Title);
                m.Description = Tx(menu.Body);
                m.Flags = Message.Flag.MessageBox;
                m.MenuButtons.Clear();
                foreach (var label in menu.Buttons)
                {
                    m.MenuButtons.Add(new MessageButton { Text = Tx(label) });
                }
            });
            wiring.Add((menu.EditorId, message.FormKey));
        }

        // 3) Manager VMAD wiring (the .psc runtime layer is already applied + compiled).
        WireQuestScript(managerQuest, managerScriptName, wiring.Select(e => (ScriptProperty)ObjectProp(e.Property, e.Key)));
        report.Actions.Add($"Wired {wiring.Count} properties on {managerScriptName}.");
    }

    // Checks (always run; --check runs ONLY these).
    foreach (var ability in abilities)
    {
        CheckSpellEffect(index, ability.SpellEditorId, ability.MgefEditorId, ability.Magnitude, 0, report);
    }
    foreach (var menu in menus)
    {
        CheckMessageButtons(index, menu.EditorId, menu.Buttons.Length, report);
    }
    // Orc Trial SPELs are authored elsewhere -- confirm they exist (do not author).
    foreach (var orcSpell in new[] { "PDV_SPEL_Orc_TrialOfIron_Tusk", "PDV_SPEL_Orc_TrialOfIron_Shield", "PDV_SPEL_Orc_TrialOfIron_Hammer", "PDV_SPEL_Orc_TrialOfIron_Yoke" })
    {
        if (!index.ContainsKey(orcSpell))
        {
            report.Errors.Add($"{orcSpell}: expected to already exist in the ESP (authored by the Orc reward pass) but was not found.");
        }
        else
        {
            report.Actions.Add($"{orcSpell}: present [ok]");
        }
    }
    CheckManagerWiring(managerQuest, managerScriptName, abilities.Select(a => a.SpellEditorId).Concat(menus.Select(m => m.EditorId)), report);

    if (!checkOnly)
    {
        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report, "6f-rite");
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

static MagicEffect EnsureMagicEffect(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, AuthorReport report, Action<MagicEffect> configure)
{
    MagicEffect effect;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not MagicEffect e)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        effect = e;
        report.Actions.Add($"Reconfigured magic effect {editorId}.");
    }
    else
    {
        effect = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(effect);
        index[editorId] = effect;
        report.Actions.Add($"Created magic effect {editorId}.");
    }
    effect.EditorID = editorId;
    effect.FormVersion = 44;
    effect.BaseCost = 0.0f;
    effect.MagicSkill = ActorValue.None;
    effect.ResistValue = ActorValue.None;
    effect.SkillUsageMultiplier = 0.0f;
    effect.ScriptEffectAIScore = 0.0f;
    effect.ScriptEffectAIDelayTime = 0.0f;
    configure(effect);
    return effect;
}

static Spell EnsureSpell(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, AuthorReport report, Action<Spell> configure)
{
    Spell spell;
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Spell s)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected Spell.");
        }
        spell = s;
        report.Actions.Add($"Reconfigured spell {editorId}.");
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[editorId] = spell;
        report.Actions.Add($"Created spell {editorId}.");
    }
    spell.EditorID = editorId;
    spell.FormVersion = 44;
    spell.BaseCost = 0;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    configure(spell);
    return spell;
}

static void SetSingleEffect(Spell spell, FormKey mgefKey, float magnitude, int duration)
{
    spell.Effects.Clear();
    spell.Effects.Add(new Effect
    {
        BaseEffect = mgefKey.ToNullableLink<IMagicEffectGetter>(),
        Data = new EffectData { Magnitude = magnitude, Area = 0, Duration = duration },
        Conditions = []
    });
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

static void CheckSpellEffect(Dictionary<string, ISkyrimMajorRecordGetter> index, string spellEditorId, string mgefEditorId, float magnitude, int duration, AuthorReport report)
{
    if (!index.TryGetValue(spellEditorId, out var record) || record is not Spell spell)
    {
        report.Errors.Add($"{spellEditorId}: missing or not a Spell.");
        return;
    }
    if (!index.TryGetValue(mgefEditorId, out var mgefRecord) || mgefRecord is not MagicEffect mgef)
    {
        report.Errors.Add($"{mgefEditorId}: missing or not a MagicEffect.");
        return;
    }
    if (spell.Effects.Count != 1)
    {
        report.Errors.Add($"{spellEditorId}: expected exactly 1 effect, found {spell.Effects.Count}.");
        return;
    }
    var effect = spell.Effects[0];
    if (effect.BaseEffect.FormKey != mgef.FormKey)
    {
        report.Errors.Add($"{spellEditorId}: effect does not reference {mgefEditorId}.");
    }
    if (Math.Abs((effect.Data?.Magnitude ?? 0.0f) - magnitude) > 0.001f || (effect.Data?.Duration ?? 0) != duration)
    {
        report.Errors.Add($"{spellEditorId}: magnitude/duration mismatch (expected {magnitude}/{duration}).");
    }
    report.Actions.Add($"{spellEditorId}: effect -> {mgefEditorId} mag={magnitude} dur={duration} [ok]");
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

sealed record AbilityDef(string SpellEditorId, string MgefEditorId, string DisplayName, string PlayerFacingText, ActorValue ActorValue, float Magnitude, bool PeakRate);

sealed record MenuDef(string EditorId, string Title, string Body, string[] Buttons);

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
