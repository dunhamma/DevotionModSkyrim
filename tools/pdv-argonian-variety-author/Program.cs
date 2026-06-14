// pdv-argonian-variety-author
// One-batch Mutagen author for the Argonian variety tranches (2-5):
//   - PDV_SPEL_ArgonianShadowscaleVeil (+MGEF, Invisibility archetype, 4s self)
//   - PDV_SPEL_ArgonianRootedRest (+MGEF, StaminaRateMult +5, 600s self)
//   - 4 adaptation ability spells (+MGEFs, constant-effect AV mods)
//   - PDV_MESG_ArgonianMarkBed / PDV_MESG_ArgonianAdaptRite (MessageBox, menu buttons)
//   - PDV_FLST_ArgonianSacredWaters (6 vanilla LCTNs, manifest order)
//   - VMAD wiring of the 9 new PDV__ManagerQuest properties
// Record contract of record: references/authoring/PDV_ArgonianVariety_RecordBatch.manifest.json
// Flags: --esp <path>, --dry-run, --check (verify-only slot dump + record checks, never writes)
// Patterns copied from tools/pdv-daedric-author/Program.cs (Ensure*/Wire*/WriteModIfNeeded).

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerScriptName = "PDV__ManagerQuest";
const string sacredWatersListEditorId = "PDV_FLST_ArgonianSacredWaters";

var skyrimModKey = ModKey.FromNameAndExtension("Skyrim.esm");
var dawnguardModKey = ModKey.FromNameAndExtension("Dawnguard.esm");

// Manifest order matters for the --check slot dump; script lookups are HasForm.
// Eldergleam stays in the list (counts toward the 6-site milestone) but the
// script intercepts its LCTN and fires on the interior cave cell instead.
var sacredWaters = new[]
{
    (EditorId: "EldergleamSanctuaryLocation", Key: new FormKey(skyrimModKey, 0x0192AC)),
    (EditorId: "SleepingTreeCampLocation", Key: new FormKey(skyrimModKey, 0x0192AD)),
    (EditorId: "IlinaltasDeepLocation", Key: new FormKey(skyrimModKey, 0x01919C)),
    (EditorId: "DLC1_AncestorsGladeLocation", Key: new FormKey(dawnguardModKey, 0x003583)),
    (EditorId: "BloatedMansGrottoLocation", Key: new FormKey(skyrimModKey, 0x018EEF)),
    (EditorId: "DarkwaterCrossingLocation", Key: new FormKey(skyrimModKey, 0x018A4D)),
};

var abilitySpells = new[]
{
    new AbilityDef("PDV_SPEL_ArgonianAdapt_Claws", "PDV_MGEF_ArgonianAdapt_Claws", "Claws of the Marsh",
        "The root sharpened your claws. Your bare strikes hit harder.", ActorValue.UnarmedDamage, 5.0f),
    new AbilityDef("PDV_SPEL_ArgonianAdapt_Skin", "PDV_MGEF_ArgonianAdapt_Skin", "Stillness of the Skin",
        "Your scales drink the light. You move a little quieter.", ActorValue.Sneak, 5.0f),
    new AbilityDef("PDV_SPEL_ArgonianAdapt_Sap", "PDV_MGEF_ArgonianAdapt_Sap", "Sap-Quickened Focus",
        "Sap-light runs behind your eyes. Magicka returns a little faster.", ActorValue.MagickaRateMult, 5.0f),
    new AbilityDef("PDV_SPEL_ArgonianAdapt_Marsh", "PDV_MGEF_ArgonianAdapt_Marsh", "Marsh-Born Endurance",
        "Marsh endurance settles into your limbs. Stamina returns faster.", ActorValue.StaminaRateMult, 8.0f),
};

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    CheckOnly = checkOnly,
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
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
    var managerQuest = RequireRecord<Quest>(index, "PDV__ManagerQuest");

    var wiring = new List<(string Property, FormKey Key)>();

    if (!checkOnly)
    {
        // 1) Shadowscale veil: real Invisibility archetype, brief fire-and-forget self cast.
        var veilMgef = EnsureMagicEffect(mod, index, allocator, "PDV_MGEF_ArgonianShadowscaleVeil", report, effect =>
        {
            effect.Name = Tx("Shadowscale Veil");
            effect.Description = Tx("The shadow takes you back. You are unseen for a moment.");
            effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoHitEffect | MagicEffect.Flag.Recover;
            effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Invisibility)
            {
                ActorValue = ActorValue.Invisibility
            };
            effect.CastType = CastType.FireAndForget;
            effect.TargetType = TargetType.Self;
        });
        var veilSpell = EnsureSpell(mod, index, allocator, "PDV_SPEL_ArgonianShadowscaleVeil", report, spell =>
        {
            spell.Name = Tx("Shadowscale Veil");
            spell.Description = Tx("The shadow takes you back. You are unseen for a moment.");
            spell.Type = SpellType.Spell;
            spell.CastType = CastType.FireAndForget;
            spell.TargetType = TargetType.Self;
            SetSingleEffect(spell, veilMgef.FormKey, magnitude: 0.0f, duration: 4);
        });
        wiring.Add(("PDV_SPEL_ArgonianShadowscaleVeil", veilSpell.FormKey));

        // 2) Rooted Rest: short timed stamina-regen wake buff (Rested-family feel).
        var restMgef = EnsureMagicEffect(mod, index, allocator, "PDV_MGEF_ArgonianRootedRest", report, effect =>
        {
            effect.Name = Tx("Rooted Rest");
            effect.Description = Tx("You wake rooted. Stamina returns faster for a while.");
            effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoHitEffect | MagicEffect.Flag.Recover;
            effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
            {
                ActorValue = ActorValue.StaminaRateMult
            };
            effect.CastType = CastType.FireAndForget;
            effect.TargetType = TargetType.Self;
        });
        var restSpell = EnsureSpell(mod, index, allocator, "PDV_SPEL_ArgonianRootedRest", report, spell =>
        {
            spell.Name = Tx("Rooted Rest");
            spell.Description = Tx("You wake rooted. Stamina returns faster for a while.");
            spell.Type = SpellType.Spell;
            spell.CastType = CastType.FireAndForget;
            spell.TargetType = TargetType.Self;
            SetSingleEffect(spell, restMgef.FormKey, magnitude: 5.0f, duration: 600);
        });
        wiring.Add(("PDV_SPEL_ArgonianRootedRest", restSpell.FormKey));

        // 3) Adaptation abilities: constant-effect AV mods, one active at a time (script-enforced).
        foreach (var ability in abilitySpells)
        {
            var abilityMgef = EnsureMagicEffect(mod, index, allocator, ability.MgefEditorId, report, effect =>
            {
                effect.Name = Tx(ability.DisplayName);
                effect.Description = Tx(ability.PlayerFacingText);
                effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
                effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
                {
                    ActorValue = ability.ActorValue
                };
                effect.CastType = CastType.ConstantEffect;
                effect.TargetType = TargetType.Self;
            });
            var abilitySpell = EnsureSpell(mod, index, allocator, ability.SpellEditorId, report, spell =>
            {
                spell.Name = Tx(ability.DisplayName);
                spell.Description = Tx(ability.PlayerFacingText);
                spell.Type = SpellType.Ability;
                spell.CastType = CastType.ConstantEffect;
                spell.TargetType = TargetType.Self;
                SetSingleEffect(spell, abilityMgef.FormKey, ability.Magnitude, duration: 0);
            });
            wiring.Add((ability.SpellEditorId, abilitySpell.FormKey));
        }

        // 4) Messages. Button index contracts live in the manager script:
        //    MarkBed: 0 = declare, 1 = decline. AdaptRite: 0-3 = adaptation, 4 = not yet.
        var markBed = EnsureMessage(mod, index, allocator, "PDV_MESG_ArgonianMarkBed", report, message =>
        {
            message.Name = Tx("Bed of Choice");
            message.Description = Tx("Settle into this bed as your bed of choice? The root remembers where you rest.");
            message.Flags = Message.Flag.MessageBox;
            message.MenuButtons.Clear();
            message.MenuButtons.Add(new MessageButton { Text = Tx("Yes, this is my bed") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Not yet") });
        });
        wiring.Add(("PDV_MESG_ArgonianMarkBed", markBed.FormKey));

        var adaptRite = EnsureMessage(mod, index, allocator, "PDV_MESG_ArgonianAdaptRite", report, message =>
        {
            message.Name = Tx("The Dreaming Root");
            // Effects live in the BODY, not the buttons: Skyrim lays MessageBox
            // buttons in one horizontal row, so long labels run off-screen.
            message.Description = Tx("The root dreams, and the dream reaches for your shape.\nChoose one gift. The change is permanent.\n\nClaws: Unarmed Damage +5\nStillness: Sneak +5\nSap-Focus: Magicka Regen +5%\nMarsh-Born: Stamina Regen +8%");
            message.Flags = Message.Flag.MessageBox;
            message.MenuButtons.Clear();
            message.MenuButtons.Add(new MessageButton { Text = Tx("Claws") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Stillness") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Sap-Focus") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Marsh-Born") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Not yet") });
        });
        wiring.Add(("PDV_MESG_ArgonianAdaptRite", adaptRite.FormKey));

        // 5) Sacred waters FormList, rebuilt in manifest order.
        var watersList = EnsureFormList(mod, index, allocator, sacredWatersListEditorId, report);
        RebuildFormListInManifestOrder(watersList, sacredWaters.Select(w => w.Key).ToList(), report, sacredWatersListEditorId);
        wiring.Add((sacredWatersListEditorId, watersList.FormKey));

        // 6) Manager VMAD wiring.
        WireQuestScript(managerQuest, managerScriptName, wiring.Select(entry => (ScriptProperty)ObjectProp(entry.Property, entry.Key)));
        report.Actions.Add($"Wired {wiring.Count} properties on PDV__ManagerQuest.");
    }

    // Checks (always run; --check runs ONLY these).
    CheckSpellEffect(index, "PDV_SPEL_ArgonianShadowscaleVeil", "PDV_MGEF_ArgonianShadowscaleVeil", 0.0f, 4, report);
    CheckSpellEffect(index, "PDV_SPEL_ArgonianRootedRest", "PDV_MGEF_ArgonianRootedRest", 5.0f, 600, report);
    foreach (var ability in abilitySpells)
    {
        CheckSpellEffect(index, ability.SpellEditorId, ability.MgefEditorId, ability.Magnitude, 0, report);
    }
    CheckMessageButtons(index, "PDV_MESG_ArgonianMarkBed", 2, report);
    CheckMessageButtons(index, "PDV_MESG_ArgonianAdaptRite", 5, report);
    CheckFormListSlots(index, sacredWatersListEditorId, sacredWaters.Select(w => (w.EditorId, w.Key)).ToList(), report);
    CheckManagerWiring(managerQuest, report);

    if (!checkOnly)
    {
        WriteModIfNeeded(mod, espPath, dryRun, report, "argonian-variety");
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
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
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
        if (existing is not MagicEffect existingEffect)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected MagicEffect.");
        }

        effect = existingEffect;
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
        if (existing is not Spell existingSpell)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected Spell.");
        }

        spell = existingSpell;
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
        if (existing is not Message existingMessage)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected Message.");
        }

        message = existingMessage;
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

static FormList EnsureFormList(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, string editorId, AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not FormList existingList)
        {
            throw new InvalidOperationException($"{editorId} exists as {existing.GetType().Name}, expected FormList.");
        }

        report.Actions.Add($"Verified existing FormList {editorId}.");
        return existingList;
    }

    var created = new FormList(allocator.Next(), SkyrimRelease.SkyrimSE)
    {
        FormVersion = 44,
        EditorID = editorId
    };
    mod.FormLists.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created FormList {editorId}.");
    return created;
}

static void RebuildFormListInManifestOrder(FormList formList, List<FormKey> orderedKeys, AuthorReport report, string formListLabel)
{
    var currentOrder = formList.Items.Select(item => item.FormKey).ToList();
    if (currentOrder.SequenceEqual(orderedKeys))
    {
        report.Actions.Add($"{formListLabel}: already in manifest order ({orderedKeys.Count} entries).");
        return;
    }

    formList.Items.Clear();
    foreach (var key in orderedKeys)
    {
        formList.Items.Add(key.ToLinkGetter<ISkyrimMajorRecordGetter>());
    }

    report.Actions.Add($"Rebuilt {formListLabel} in manifest order ({orderedKeys.Count} entries).");
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

    var labels = string.Join(" | ", message.MenuButtons.Select((button, slot) => $"{slot}:{button.Text?.String}"));
    report.Actions.Add($"{editorId}: buttons [{labels}]");
}

static void CheckFormListSlots(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, List<(string EditorId, FormKey Key)> expected, AuthorReport report)
{
    if (!index.TryGetValue(editorId, out var record) || record is not FormList formList)
    {
        report.Errors.Add($"{editorId}: missing or not a FormList.");
        return;
    }

    var actual = formList.Items.Select(item => item.FormKey).ToList();
    for (var slot = 0; slot < Math.Max(actual.Count, expected.Count); slot++)
    {
        var actualText = slot < actual.Count ? actual[slot].ToString() : "(none)";
        var expectedEntry = slot < expected.Count ? expected[slot] : default;
        var expectedText = slot < expected.Count ? $"{expectedEntry.Key} ({expectedEntry.EditorId})" : "(none)";
        var matches = slot < actual.Count && slot < expected.Count && actual[slot] == expectedEntry.Key;
        report.Actions.Add($"{editorId} slot {slot}: actual={actualText} expected={expectedText} [{(matches ? "ok" : "MISWIRED")}]");
        if (!matches)
        {
            report.Errors.Add($"{editorId} slot {slot} does not match the manifest.");
        }
    }
}

static void CheckManagerWiring(Quest managerQuest, AuthorReport report)
{
    var expectedProperties = new[]
    {
        "PDV_SPEL_ArgonianShadowscaleVeil", "PDV_SPEL_ArgonianRootedRest",
        "PDV_MESG_ArgonianMarkBed", "PDV_MESG_ArgonianAdaptRite",
        "PDV_SPEL_ArgonianAdapt_Claws", "PDV_SPEL_ArgonianAdapt_Skin",
        "PDV_SPEL_ArgonianAdapt_Sap", "PDV_SPEL_ArgonianAdapt_Marsh",
        "PDV_FLST_ArgonianSacredWaters"
    };

    var script = managerQuest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, "PDV__ManagerQuest", StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add("PDV__ManagerQuest is missing its manager VMAD script.");
        return;
    }

    foreach (var propertyName in expectedProperties)
    {
        var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty || objectProperty.Object.FormKeyNullable is null)
        {
            report.Errors.Add($"PDV__ManagerQuest VMAD property {propertyName} is missing or unresolved.");
        }
        else
        {
            report.Actions.Add($"PDV__ManagerQuest.{propertyName} -> {objectProperty.Object.FormKeyNullable} [ok]");
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
    var script = scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
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
        while (script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, property.Name, StringComparison.OrdinalIgnoreCase)) is { } existing)
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

sealed record AbilityDef(string SpellEditorId, string MgefEditorId, string DisplayName, string PlayerFacingText, ActorValue ActorValue, float Magnitude);

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
