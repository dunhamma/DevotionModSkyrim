// pdv-bosmer-variety-author
// One-batch Mutagen author for the Bosmer variety tranche ("The Story Goes On"):
//   - PDV_SPEL_BosmerTaleCarried (+MGEF, Speech +5, 600s self)        [Living Story hearth]
//   - PDV_SPEL_BosmerScalesAtRest (+MGEF, Speech +10, 120s self)      [Exchange signature]
//   - PDV_SPEL_BosmerBaanDarGap (+MGEF, SpeedMult +40, 15s self)      [Bandit Road signature]
//   - PDV_SPEL_BosmerBaanDarGapWatcher (+MGEF script watcher)          [Bandit Road low-health trigger]
//   - 4 Naming told-self ability spells (+MGEFs, constant-effect AV mods)
//   - PDV_MESG_BosmerMarkHearth / PDV_MESG_BosmerNaming (MessageBox, menu buttons)
//   - PDV_FLST_BosmerGreenSongs (6 vanilla LCTNs, manifest order; FAIL-CLOSED on unverified slots)
//   - forward VMAD wiring of the 10 new PDV__ManagerQuest properties
// Record contract of record: references/authoring/PDV_BosmerVariety_RecordBatch.manifest.json
// Flags: --esp <path>, --dry-run, --check (verify-only slot dump + record checks, never writes)
// Patterns copied from tools/pdv-argonian-variety-author/Program.cs.
//
// FAIL-CLOSED FORMLIST: four of the six Songs LCTNs are not yet FormID-verified
// in-repo. The tool refuses to BUILD or WIRE PDV_FLST_BosmerGreenSongs while any
// entry is unverified, so a real --esp write can never bake a guessed FormID.
// Resolve the FormIDs (pdv_extract_vanilla_gameplay_refs.mjs), fill them into the
// greenSongs table below with verified:true, then re-run.

using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string managerScriptName = "PDV__ManagerQuest";
const string greenSongsListEditorId = "PDV_FLST_BosmerGreenSongs";
const string gapSpellEditorId = "PDV_SPEL_BosmerBaanDarGap";
const string gapMgefEditorId = "PDV_MGEF_BosmerBaanDarGap";
const string gapWatcherSpellEditorId = "PDV_SPEL_BosmerBaanDarGapWatcher";
const string gapWatcherMgefEditorId = "PDV_MGEF_BosmerBaanDarGapWatcher";
const string gapWatcherScriptName = "PDV_BosmerBaanDarGapWatchEffect";
const string gapPresentationMgefEditorId = "PDV_MGEF_BosmerBaanDarGapPresentation";
const string gapPresentationScriptName = "PDV_BosmerGapPresentationEffect";
const string gapPresentationSoundEditorId = "PDV_SND_RisingChime";
const uint gapPresentationShaderLocalId = 0x0E7557; // Matches the diegetic "Release" shader source.

var skyrimModKey = ModKey.FromNameAndExtension("Skyrim.esm");

// Songs of the Green LCTNs, manifest order. All six FormID-verified
// (Eldergleam from the runtime-proven Argonian batch; the rest via houseCARL
// LCTN query 2026-06-12). Slot 2 was SWAPPED from WhiterunWindDistrictLocation
// (which does not exist as an LCTN) to WhiterunTempleofKynarethLocation, the
// tightest real LCTN anchoring the Gildergreen -- see the manifest slot-2 why.
// Eldergleam is intentionally shared with the Argonian Waters set; the manager
// script fires race-distinct vision text on a Bosmer arrival.
var greenSongs = new GreenSong[]
{
    new("EldergleamSanctuaryLocation", 0x0192AC),
    new("KynesgroveLocation", 0x018A4E),
    new("WhiterunTempleofKynarethLocation", 0x01F87D),   // Gildergreen anchor; SWAPPED from non-existent WhiterunWindDistrictLocation (see manifest slot-2 why)
    new("EvergreenGroveLocation", 0x019174),
    new("ClearspringTarnLocation", 0x019157),
    new("AutumnshadeClearingLocation", 0x018EE4),
};

// Timed self-buffs (FireAndForget, ValueModifier, durationed) -- Rooted Rest family.
var timedBuffs = new[]
{
    new TimedBuffDef("PDV_SPEL_BosmerTaleCarried", "PDV_MGEF_BosmerTaleCarried", "A Tale Carried",
        "You told the tale, and the telling settled. Your words carry further for a while.",
        ActorValue.Speech, 5.0f, 600),
    new TimedBuffDef("PDV_SPEL_BosmerScalesAtRest", "PDV_MGEF_BosmerScalesAtRest", "Scales at Rest",
        "The account is even. For a while, every bargain falls a little your way.",
        ActorValue.Speech, 10.0f, 120),
    new TimedBuffDef("PDV_SPEL_BosmerBaanDarGap", "PDV_MGEF_BosmerBaanDarGap", "Baan Dar Opens the Gap",
        "Baan Dar opens the gap. Run.",
        ActorValue.SpeedMult, 40.0f, 15),
};

// Naming told-self abilities (ConstantEffect, ValueModifier) -- one active at a
// time (manager script enforces clear-before-add). Keeper ships as CarryWeight,
// not barter: vanilla governs prices through Speech, already used by Speaker, so
// CarryWeight keeps the four options mechanically distinct (see manifest).
var namingAbilities = new[]
{
    new AbilityDef("PDV_SPEL_BosmerNaming_Hunter", "PDV_MGEF_BosmerNaming_Hunter", "The Hunter",
        "You told yourself the Hunter. Your aim runs truer.", ActorValue.Archery, 5.0f),
    new AbilityDef("PDV_SPEL_BosmerNaming_Speaker", "PDV_MGEF_BosmerNaming_Speaker", "The Speaker",
        "You told yourself the Speaker. People lean in to listen.", ActorValue.Speech, 5.0f),
    new AbilityDef("PDV_SPEL_BosmerNaming_Wanderer", "PDV_MGEF_BosmerNaming_Wanderer", "The Wanderer",
        "You told yourself the Wanderer. The road tires you less.", ActorValue.StaminaRateMult, 8.0f),
    new AbilityDef("PDV_SPEL_BosmerNaming_Keeper", "PDV_MGEF_BosmerNaming_Keeper", "The Keeper",
        "You told yourself the Keeper. You carry more of what the people need kept.", ActorValue.CarryWeight, 15.0f),
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

var unverifiedSongs = greenSongs.Where(song => song.LocalId is null).ToList();
var allSongsVerified = unverifiedSongs.Count == 0;

try
{
    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));
    var managerQuest = RequireRecord<Quest>(index, managerScriptName);

    var wiring = new List<(string Property, FormKey Key)>();

    if (!allSongsVerified)
    {
        report.Errors.Add($"{greenSongsListEditorId}: {unverifiedSongs.Count} unverified LCTN slot(s) [{string.Join(", ", unverifiedSongs.Select(s => s.EditorId))}]; the FormList will NOT be built or wired. Resolve the FormIDs (pdv_extract_vanilla_gameplay_refs.mjs), fill greenSongs, set verified, then re-run.");
    }

    if (!checkOnly)
    {
        var debugGlobal = RequireRecord<ISkyrimMajorRecordGetter>(index, "PDV_GLO_DebugLevel");
        var gapPresentationSound = RequireRecord<ISkyrimMajorRecordGetter>(index, gapPresentationSoundEditorId);

        // 1) Timed self-buffs (Tale Carried, Scales at Rest, Baan Dar Opens the Gap).
        foreach (var buff in timedBuffs)
        {
            var isGapSpell = string.Equals(buff.SpellEditorId, gapSpellEditorId, StringComparison.OrdinalIgnoreCase);
            var buffMgef = EnsureMagicEffect(mod, index, allocator, buff.MgefEditorId, report, effect =>
            {
                effect.Name = Tx(buff.DisplayName);
                effect.Description = Tx(buff.PlayerFacingText);
                effect.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.Recover;
                if (!isGapSpell)
                {
                    effect.Flags |= MagicEffect.Flag.NoHitEffect;
                }
                effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
                {
                    ActorValue = buff.ActorValue
                };
                effect.CastType = CastType.FireAndForget;
                effect.TargetType = TargetType.Self;
                if (isGapSpell)
                {
                    PdvPresentationSurfaceAuthoring.ApplyHitShader(effect, new FormKey(skyrimModKey, gapPresentationShaderLocalId));
                }
            });
            var buffSpell = EnsureSpell(mod, index, allocator, buff.SpellEditorId, report, spell =>
            {
                spell.Name = Tx(buff.DisplayName);
                spell.Description = Tx(buff.PlayerFacingText);
                spell.Type = SpellType.Spell;
                spell.CastType = CastType.FireAndForget;
                spell.TargetType = TargetType.Self;
                if (isGapSpell)
                {
                    var spec = BosmerGapPresentationSpec(debugGlobal.FormKey, gapPresentationSound.FormKey);
                    var presentationMgef = PdvPresentationSurfaceAuthoring.EnsureHiddenSoundCueEffect(mod, index, () => allocator.Next(), spec);
                    report.Actions.Add($"Ensured presentation effect {presentationMgef.EditorID}.");
                    PdvPresentationSurfaceAuthoring.SetPrimaryAndPresentationEffects(spell, buffMgef.FormKey, buff.Magnitude, buff.Duration, presentationMgef.FormKey);
                }
                else
                {
                    SetSingleEffect(spell, buffMgef.FormKey, buff.Magnitude, buff.Duration);
                }
            });
            wiring.Add((buff.SpellEditorId, buffSpell.FormKey));
        }

        // 1b) Hidden Bandit Road low-health watcher. This mirrors the reliable
        // Khajiit Baan Dar active-effect OnHit shape while preserving the
        // manager-owned path/day gates and notification payload.
        var gapWatcherMgef = EnsureMagicEffect(mod, index, allocator, gapWatcherMgefEditorId, report, effect =>
        {
            effect.Name = Tx("Baan Dar Watches the Gap");
            effect.Description = Tx("");
            effect.Flags = MagicEffect.Flag.Recover
                | MagicEffect.Flag.NoDuration
                | MagicEffect.Flag.NoArea
                | MagicEffect.Flag.HideInUI
                | MagicEffect.Flag.PowerAffectsMagnitude;
            effect.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.Script)
            {
                ActorValue = ActorValue.None
            };
            effect.CastType = CastType.ConstantEffect;
            effect.TargetType = TargetType.Self;
            WireMagicEffectScript(effect, gapWatcherScriptName, new ScriptProperty[]
            {
                ObjectProp("PDV_Manager", managerQuest.FormKey),
                ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
                FloatProp("TriggerHealthPercent", 0.20f)
            });
        });
        var gapWatcherSpell = EnsureSpell(mod, index, allocator, gapWatcherSpellEditorId, report, spell =>
        {
            spell.Name = Tx("Baan Dar Watches the Gap");
            spell.Description = Tx("");
            spell.Type = SpellType.Ability;
            spell.CastType = CastType.ConstantEffect;
            spell.TargetType = TargetType.Self;
            SetSingleEffect(spell, gapWatcherMgef.FormKey, 0.0f, duration: 0);
        });
        wiring.Add((gapWatcherSpellEditorId, gapWatcherSpell.FormKey));

        // 2) Naming told-self abilities: constant-effect AV mods, one active at a time (script-enforced).
        foreach (var ability in namingAbilities)
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

        // 3) Messages. Button index contracts live in the manager script:
        //    MarkHearth: 0 = declare, 1 = decline. Naming: 0-3 = told-self, 4 = not yet.
        var markHearth = EnsureMessage(mod, index, allocator, "PDV_MESG_BosmerMarkHearth", report, message =>
        {
            message.Name = Tx("Hearth of the Telling");
            message.Description = Tx("Make this hearth the place your stories come home to? The Story is kept by being told here.");
            message.Flags = Message.Flag.MessageBox;
            message.MenuButtons.Clear();
            message.MenuButtons.Add(new MessageButton { Text = Tx("Yes, this hearth is mine") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Not yet") });
        });
        wiring.Add(("PDV_MESG_BosmerMarkHearth", markHearth.FormKey));

        var naming = EnsureMessage(mod, index, allocator, "PDV_MESG_BosmerNaming", report, message =>
        {
            message.Name = Tx("The Naming");
            // Effects live in the BODY, not the buttons: Skyrim lays MessageBox
            // buttons in one horizontal row, so long labels run off-screen.
            message.Description = Tx("Y'ffre told the Bosmer their forms. In exile you tell your own.\nChoose one told-self. One holds at a time; choosing again retells you.\n\nHunter: Archery +5\nSpeaker: Speech +5\nWanderer: Stamina Regen +8%\nKeeper: Carry Weight +15");
            message.Flags = Message.Flag.MessageBox;
            message.MenuButtons.Clear();
            message.MenuButtons.Add(new MessageButton { Text = Tx("Hunter") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Speaker") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Wanderer") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Keeper") });
            message.MenuButtons.Add(new MessageButton { Text = Tx("Not yet") });
        });
        wiring.Add(("PDV_MESG_BosmerNaming", naming.FormKey));

        // 4) Songs of the Green FormList -- only when every slot is FormID-verified.
        if (allSongsVerified)
        {
            var songsList = EnsureFormList(mod, index, allocator, greenSongsListEditorId, report);
            RebuildFormListInManifestOrder(songsList, greenSongs.Select(song => song.Key(skyrimModKey)).ToList(), report, greenSongsListEditorId);
            wiring.Add((greenSongsListEditorId, songsList.FormKey));
        }
        else
        {
            report.Actions.Add($"{greenSongsListEditorId}: skipped (fail-closed on unverified slots).");
        }

        // 5) Manager VMAD wiring (forward-compatible: the Bosmer .psc runtime layer is a later step).
        WireQuestScript(managerQuest, managerScriptName, wiring.Select(entry => (ScriptProperty)ObjectProp(entry.Property, entry.Key)));
        report.Actions.Add($"Wired {wiring.Count} properties on {managerScriptName}.");
    }

    // Checks (always run; --check runs ONLY these).
    foreach (var buff in timedBuffs)
    {
        if (string.Equals(buff.SpellEditorId, gapSpellEditorId, StringComparison.OrdinalIgnoreCase))
        {
            CheckBosmerGapSpell(index, buff.Magnitude, buff.Duration, report);
        }
        else
        {
            CheckSpellEffect(index, buff.SpellEditorId, buff.MgefEditorId, buff.Magnitude, buff.Duration, report);
        }
    }
    foreach (var ability in namingAbilities)
    {
        CheckSpellEffect(index, ability.SpellEditorId, ability.MgefEditorId, ability.Magnitude, 0, report);
    }
    CheckMessageButtons(index, "PDV_MESG_BosmerMarkHearth", 2, report);
    CheckMessageButtons(index, "PDV_MESG_BosmerNaming", 5, report);
    CheckGreenSongsSlots(index, greenSongsListEditorId, greenSongs, skyrimModKey, report);
    CheckGapWatcher(index, managerQuest, report);
    CheckManagerWiring(managerQuest, managerScriptName, greenSongsListEditorId, timedBuffs, namingAbilities, allSongsVerified, report);

    if (!checkOnly)
    {
        if (report.Errors.Count == 0)
        {
            WriteModIfNeeded(mod, espPath, dryRun, report, "bosmer-variety");
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

static void CheckBosmerGapSpell(Dictionary<string, ISkyrimMajorRecordGetter> index, float magnitude, int duration, AuthorReport report)
{
    if (!index.TryGetValue(gapSpellEditorId, out var spellRecord) || spellRecord is not Spell spell)
    {
        report.Errors.Add($"{gapSpellEditorId}: missing or not a Spell.");
        return;
    }

    if (!index.TryGetValue(gapMgefEditorId, out var gapMgefRecord) || gapMgefRecord is not MagicEffect gapMgef)
    {
        report.Errors.Add($"{gapMgefEditorId}: missing or not a MagicEffect.");
        return;
    }

    if (!index.TryGetValue(gapPresentationMgefEditorId, out var presentationMgefRecord) || presentationMgefRecord is not MagicEffect presentationMgef)
    {
        report.Errors.Add($"{gapPresentationMgefEditorId}: missing or not a MagicEffect.");
        return;
    }

    if (spell.Effects.Count != 2)
    {
        report.Errors.Add($"{gapSpellEditorId}: expected exactly 2 effects, found {spell.Effects.Count}.");
        return;
    }

    var speedEffect = spell.Effects[0];
    if (speedEffect.BaseEffect.FormKey != gapMgef.FormKey)
    {
        report.Errors.Add($"{gapSpellEditorId}: first effect does not reference {gapMgefEditorId}.");
    }
    if (Math.Abs((speedEffect.Data?.Magnitude ?? 0.0f) - magnitude) > 0.001f || (speedEffect.Data?.Duration ?? 0) != duration)
    {
        report.Errors.Add($"{gapSpellEditorId}: primary magnitude/duration mismatch (expected {magnitude}/{duration}).");
    }

    var presentationEffect = spell.Effects[1];
    if (presentationEffect.BaseEffect.FormKey != presentationMgef.FormKey)
    {
        report.Errors.Add($"{gapSpellEditorId}: second effect does not reference {gapPresentationMgefEditorId}.");
    }

    if (gapMgef.CastType != CastType.FireAndForget || gapMgef.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{gapMgefEditorId}: expected self FireAndForget magic effect.");
    }
    if (gapMgef.Flags.HasFlag(MagicEffect.Flag.NoHitEffect))
    {
        report.Errors.Add($"{gapMgefEditorId}: NoHitEffect is still set; the shader will not surface cleanly.");
    }
    if (!gapMgef.HitShader.FormKeyNullable?.Equals(new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), gapPresentationShaderLocalId)) ?? true)
    {
        report.Errors.Add($"{gapMgefEditorId}: expected Release hit shader {gapPresentationShaderLocalId:X6}:Skyrim.esm.");
    }

    var spec = BosmerGapPresentationSpec(
        RequireRecord<ISkyrimMajorRecordGetter>(index, "PDV_GLO_DebugLevel").FormKey,
        RequireRecord<ISkyrimMajorRecordGetter>(index, gapPresentationSoundEditorId).FormKey);
    PdvPresentationSurfaceAuthoring.CheckHiddenSoundCueEffect(presentationMgef, spec, report.Errors, report.Actions);

    report.Actions.Add($"{gapSpellEditorId}: speed burst + presentation cue [ok]");
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

// Verified slots must match; unverified slots are reported PENDING (not an error
// in --check, since the FormList is intentionally unbuilt while any slot is
// unverified -- the build path already raised the fail-closed error).
static void CheckGreenSongsSlots(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId, GreenSong[] songs, ModKey skyrimModKey, AuthorReport report)
{
    if (!index.TryGetValue(editorId, out var record) || record is not FormList formList)
    {
        for (var slot = 0; slot < songs.Length; slot++)
        {
            var status = songs[slot].LocalId is null ? "PENDING (unverified)" : "absent (FormList not built)";
            report.Actions.Add($"{editorId} slot {slot}: {songs[slot].EditorId} -> {status}");
        }
        return;
    }

    var actual = formList.Items.Select(item => item.FormKey).ToList();
    for (var slot = 0; slot < Math.Max(actual.Count, songs.Length); slot++)
    {
        var actualText = slot < actual.Count ? actual[slot].ToString() : "(none)";
        if (slot < songs.Length && songs[slot].LocalId is null)
        {
            report.Actions.Add($"{editorId} slot {slot}: {songs[slot].EditorId} -> PENDING (unverified); expected slot empty until resolved");
            continue;
        }

        var expectedKey = slot < songs.Length ? songs[slot].Key(skyrimModKey) : default;
        var expectedText = slot < songs.Length ? $"{expectedKey} ({songs[slot].EditorId})" : "(none)";
        var matches = slot < actual.Count && slot < songs.Length && actual[slot] == expectedKey;
        report.Actions.Add($"{editorId} slot {slot}: actual={actualText} expected={expectedText} [{(matches ? "ok" : "MISWIRED")}]");
        if (!matches)
        {
            report.Errors.Add($"{editorId} slot {slot} does not match the manifest.");
        }
    }
}

static void CheckGapWatcher(Dictionary<string, ISkyrimMajorRecordGetter> index, Quest managerQuest, AuthorReport report)
{
    if (!index.TryGetValue(gapWatcherSpellEditorId, out var spellRecord) || spellRecord is not Spell spell)
    {
        report.Errors.Add($"{gapWatcherSpellEditorId}: missing or not a Spell.");
        return;
    }

    if (!index.TryGetValue(gapWatcherMgefEditorId, out var mgefRecord) || mgefRecord is not MagicEffect effect)
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: missing or not a MagicEffect.");
        return;
    }

    if (spell.Type != SpellType.Ability || spell.CastType != CastType.ConstantEffect || spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{gapWatcherSpellEditorId}: expected self ConstantEffect Ability.");
    }

    var spellEffect = spell.Effects.FirstOrDefault();
    if (spell.Effects.Count != 1 || spellEffect is null || !spellEffect.BaseEffect.FormKey.Equals(effect.FormKey))
    {
        report.Errors.Add($"{gapWatcherSpellEditorId}: expected exactly one effect pointing to {gapWatcherMgefEditorId}.");
    }

    if (effect.Archetype is not MagicEffectArchetype archetype || archetype.Type != MagicEffectArchetype.TypeEnum.Script)
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: expected Script archetype.");
    }

    if (effect.CastType != CastType.ConstantEffect || effect.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: expected self ConstantEffect magic effect.");
    }

    if (!effect.Flags.HasFlag(MagicEffect.Flag.HideInUI)
        || !effect.Flags.HasFlag(MagicEffect.Flag.Recover)
        || !effect.Flags.HasFlag(MagicEffect.Flag.NoDuration)
        || !effect.Flags.HasFlag(MagicEffect.Flag.NoArea))
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: expected hidden constant-effect flags.");
    }

    var script = effect.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, gapWatcherScriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: missing {gapWatcherScriptName}.");
        return;
    }

    CheckObjectProperty(script, "PDV_Manager", managerQuest.FormKey, gapWatcherMgefEditorId, report);
    CheckObjectProperty(script, "PDV_GLO_DebugLevel", RequireRecord<ISkyrimMajorRecordGetter>(index, "PDV_GLO_DebugLevel").FormKey, gapWatcherMgefEditorId, report);
    var trigger = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, "TriggerHealthPercent", StringComparison.OrdinalIgnoreCase));
    if (trigger is not ScriptFloatProperty triggerFloat || Math.Abs(triggerFloat.Data - 0.20f) > 0.0001f)
    {
        report.Errors.Add($"{gapWatcherMgefEditorId}: TriggerHealthPercent is not 0.2.");
    }
    else
    {
        report.Actions.Add($"{gapWatcherMgefEditorId}.TriggerHealthPercent -> 0.2 [ok]");
    }

    report.Actions.Add($"{gapWatcherSpellEditorId} carries hidden {gapWatcherMgefEditorId} watcher [ok]");
}

static void CheckManagerWiring(Quest managerQuest, string managerScriptName, string songsListEditorId, TimedBuffDef[] timedBuffs, AbilityDef[] namingAbilities, bool allSongsVerified, AuthorReport report)
{
    var expectedProperties = new List<string>
    {
        "PDV_MESG_BosmerMarkHearth", "PDV_MESG_BosmerNaming", gapWatcherSpellEditorId
    };
    expectedProperties.AddRange(timedBuffs.Select(buff => buff.SpellEditorId));
    expectedProperties.AddRange(namingAbilities.Select(ability => ability.SpellEditorId));
    if (allSongsVerified)
    {
        expectedProperties.Add(songsListEditorId);
    }

    var script = managerQuest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, managerScriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        report.Errors.Add($"{managerScriptName} is missing its manager VMAD script.");
        return;
    }

    foreach (var propertyName in expectedProperties)
    {
        var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
        if (property is not ScriptObjectProperty objectProperty || objectProperty.Object.FormKeyNullable is null)
        {
            report.Errors.Add($"{managerScriptName} VMAD property {propertyName} is missing or unresolved.");
        }
        else
        {
            report.Actions.Add($"{managerScriptName}.{propertyName} -> {objectProperty.Object.FormKeyNullable} [ok]");
        }
    }

    if (!allSongsVerified)
    {
        report.Actions.Add($"{managerScriptName}.{songsListEditorId}: not expected yet (FormList fail-closed on unverified slots).");
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

static void WireMagicEffectScript(MagicEffect effect, string scriptName, IEnumerable<ScriptProperty> properties)
{
    effect.VirtualMachineAdapter ??= new VirtualMachineAdapter();
    effect.VirtualMachineAdapter.Version = 5;
    effect.VirtualMachineAdapter.ObjectFormat = 2;
    var script = EnsureScript(effect.VirtualMachineAdapter.Scripts, scriptName);
    UpsertProperties(script, properties);
}

static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expected, string ownerLabel, AuthorReport report)
{
    var property = script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
    if (property is not ScriptObjectProperty objectProperty)
    {
        report.Errors.Add($"{ownerLabel}.{propertyName}: missing or not an object property.");
        return;
    }

    if (!objectProperty.Object.FormKey.Equals(expected))
    {
        report.Errors.Add($"{ownerLabel}.{propertyName}: actual={objectProperty.Object.FormKey} expected={expected}.");
        return;
    }

    report.Actions.Add($"{ownerLabel}.{propertyName} -> {expected} [ok]");
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

static ScriptFloatProperty FloatProp(string name, float value)
{
    return new ScriptFloatProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
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

static PdvPresentationSurfaceSpec BosmerGapPresentationSpec(FormKey debugGlobal, FormKey soundCue)
{
    return new PdvPresentationSurfaceSpec(
        gapPresentationMgefEditorId,
        "Baan Dar Opens the Gap",
        gapPresentationScriptName,
        "Cue",
        soundCue,
        "PDV_GLO_DebugLevel",
        debugGlobal,
        new FormKey(ModKey.FromNameAndExtension("Skyrim.esm"), gapPresentationShaderLocalId));
}

sealed record TimedBuffDef(string SpellEditorId, string MgefEditorId, string DisplayName, string PlayerFacingText, ActorValue ActorValue, float Magnitude, int Duration);

sealed record AbilityDef(string SpellEditorId, string MgefEditorId, string DisplayName, string PlayerFacingText, ActorValue ActorValue, float Magnitude);

sealed record GreenSong(string EditorId, uint? LocalId)
{
    public FormKey Key(ModKey skyrimModKey) => new(skyrimModKey, LocalId ?? throw new InvalidOperationException($"{EditorId} has no verified FormID."));
}

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
