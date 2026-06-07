using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;

// =======================================================================
// PDV Phase 20 RACE reward-record author (generalized).
//
// This tool generalizes tools/pdv-phase20-khajiit-author so it can author
// ANY race's reward records from a per-race spec JSON. The Khajiit tool
// remains the untouched regression baseline.
//
// MODES
//   --author-rewards            Create/wire SPEL/MGEF/QUST from --rewards-spec.
//   --reconcile-shared-deity    Reconcile shared/existing deity QUSTs:
//                               copy SGE Flags/Priority from a reference deity
//                               (default PDV_Deity_Kyne) and set the named
//                               stance field(s). Generalizes --fix-baandar.
//   --dry-run                   Parse + resolve only; no ESP write.
//
// FLAGS
//   --rewards-spec <path>       REQUIRED. Per-race reward spec JSON. No default.
//   --esp <path>                Framework ESP. Defaults to the Anvil path.
//   --reference-deity <edid>    Reference deity QUST for SGE flag/priority copy
//                               and shared-deity reconciliation. Default
//                               PDV_Deity_Kyne.
//
// SPEC SCHEMA (superset; backward compatible with pdv-khajiit-records.v1)
//   deityQuests[] entries support, in addition to the v1 fields
//   (editorId/script/deityName/stanceKhajiit/deityIndex/addToFormList/shared):
//     "create": true|false       false => reuse existing QUST, do NOT create
//                                 or allocate an index. (A deity entry whose
//                                 "shared" lists OTHER races but is NATIVE to
//                                 THIS race still creates; "create":false is
//                                 the explicit "another race already owns the
//                                 QUST record" marker.) Default true.
//     "deityIndex": "next-available" | <int>
//                                 "next-available" => allocate the next free
//                                 DeityIndex by scanning existing deity QUSTs'
//                                 DeityIndex script properties in the ESP.
//                                 An explicit int is used verbatim. Omitted
//                                 entries that are created get next-available.
//     "stance": { "field": "Stance_Imperial", "value": 0 }
//                                 Generalized stance descriptor. May also be a
//                                 list: "stances": [ {field,value}, ... ] to
//                                 set multiple stance fields on one (shared)
//                                 deity quest. The legacy "stanceKhajiit"
//                                 string (e.g. "NATIVE") is still honored and
//                                 maps to Stance_Khajiit with NATIVE=0.
//   Top-level optional:
//     "stanceField"              Default stance field for deity entries that
//                                 give only a numeric stance value. If absent
//                                 and only the legacy stanceKhajiit is present,
//                                 falls back to Stance_Khajiit.
//   substrateBoons              If omitted entirely, substrate wiring is
//                               skipped (state-track races have no substrate).
//                               wireTo is fully spec-driven.
//
// Preserved behaviors: SGE Flags/Priority copied from the reference deity for
// new QUSTs, night-only effect conditions, ASCII-only enforcement on player
// text, backup-before-write.
// =======================================================================

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\PlayerDevotion_Framework.esp";
const string defaultReferenceDeity = "PDV_Deity_Kyne";

var dryRun = args.Contains("--dry-run");
var authorRewards = args.Contains("--author-rewards");
var reconcileShared = args.Contains("--reconcile-shared-deity");
var espPath = Path.GetFullPath(GetArg(args, "--esp") ?? defaultEsp);
var referenceDeity = GetArg(args, "--reference-deity") ?? defaultReferenceDeity;
var rewardsSpecPath = GetArg(args, "--rewards-spec");

var report = new AuthorReport
{
    EspPath = espPath,
    DryRun = dryRun,
    StartedAt = DateTimeOffset.Now
};

try
{
    if (string.IsNullOrWhiteSpace(rewardsSpecPath))
    {
        throw new InvalidOperationException("--rewards-spec <path> is required (no per-race default).");
    }

    rewardsSpecPath = Path.GetFullPath(rewardsSpecPath);
    report.SpecPath = rewardsSpecPath;

    if (!File.Exists(rewardsSpecPath))
    {
        throw new FileNotFoundException("Rewards spec not found.", rewardsSpecPath);
    }

    if (!File.Exists(espPath))
    {
        throw new FileNotFoundException("Framework ESP not found.", espPath);
    }

    if (!authorRewards && !reconcileShared)
    {
        throw new InvalidOperationException("Specify --author-rewards or --reconcile-shared-deity.");
    }

    var spec = LoadSpec(rewardsSpecPath);

    if (reconcileShared)
    {
        ReconcileSharedDeities(espPath, spec, referenceDeity, dryRun, report);
    }
    else
    {
        AuthorRewards(espPath, spec, referenceDeity, dryRun, report);
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

static RewardsSpec LoadSpec(string specPath)
{
    return JsonSerializer.Deserialize<RewardsSpec>(File.ReadAllText(specPath), new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
        ?? throw new InvalidOperationException("Rewards spec did not parse.");
}

// =======================================================================
// REWARD / SUBSTRATE / NEGLECT RECORD AUTHORING (--author-rewards)
// =======================================================================

static void AuthorRewards(string espPath, RewardsSpec spec, string referenceDeityEdid, bool dryRun, AuthorReport report)
{
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(record => record.FormKey));

    var originGlobal = RequireRecord<Global>(index, "PDV_GLO_OriginRace");
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var allDeities = RequireRecord<FormList>(index, "PDV_FLST_AllDeities");
    var deityTemplate = RequireRecord<Quest>(index, referenceDeityEdid);

    // Scan existing deity QUSTs for their DeityIndex script values so we can
    // allocate the next-available index(es) for any NEW deity.
    var indexAllocator = new DeityIndexAllocator(mod);
    report.Actions.Add($"Scanned existing deity QUSTs; max DeityIndex={indexAllocator.MaxSeen}, next-available starts at {indexAllocator.Peek()}.");

    var managerProps = new List<ScriptProperty>();

    // 1) Deity quests + FormList membership + manager deity properties.
    var questByEditorId = new Dictionary<string, Quest>(StringComparer.OrdinalIgnoreCase);
    foreach (var dq in spec.deityQuests ?? new())
    {
        if (string.IsNullOrWhiteSpace(dq.editorId))
        {
            throw new InvalidOperationException("deityQuests[] entry is missing editorId.");
        }

        var stances = ResolveStances(spec, dq);
        var create = dq.create ?? true;

        if (!create)
        {
            // Shared/existing deity owned by another race: resolve, do NOT
            // create or allocate an index. Reconcile stance only.
            var existingQuest = RequireRecord<Quest>(index, dq.editorId);
            ApplyStances(existingQuest, dq.script ?? dq.editorId, stances, report);
            questByEditorId[dq.editorId] = existingQuest;
            report.Actions.Add($"Reused existing deity quest {dq.editorId} (create=false); did not allocate DeityIndex.");
        }
        else
        {
            var deityIndex = ResolveDeityIndex(dq, indexAllocator, index);
            var quest = EnsureDeityQuest(mod, index, allocator, dq, deityTemplate, originGlobal.FormKey, debugGlobal.FormKey, deityIndex, stances, report);
            questByEditorId[dq.editorId] = quest;
        }

        // FormList membership (idempotent) for both created and reused deities.
        var q = questByEditorId[dq.editorId];
        if (!allDeities.Items.Any(item => item.FormKey.Equals(q.FormKey)))
        {
            allDeities.Items.Add(q.FormKey.ToLink<ISkyrimMajorRecordGetter>());
            report.Actions.Add($"Added {dq.editorId} to PDV_FLST_AllDeities.");
        }
    }

    foreach (var mp in spec.managerDeityProperties ?? new())
    {
        if (questByEditorId.TryGetValue(mp.record!, out var quest))
        {
            managerProps.Add(ObjectProp(mp.property!, quest.FormKey));
        }
    }

    // 2) Substrate boon slots (broad reward layer) wired onto the substrate
    //    quest. Skipped entirely when the spec omits substrateBoons.
    if (spec.substrateBoons is { } substrate && substrate.slots is { } slots)
    {
        if (string.IsNullOrWhiteSpace(substrate.wireTo))
        {
            throw new InvalidOperationException("substrateBoons.wireTo must name the substrate quest editorId.");
        }

        var substrateQuest = RequireRecord<Quest>(index, substrate.wireTo);
        var substrateProps = new List<ScriptProperty>();
        foreach (var slot in slots)
        {
            var spell = BuildSpell(mod, index, allocator, slot.spellEditorId!, slot.displayName!, slot.playerFacingText!, slot.effects ?? new(), report);
            substrateProps.Add(ObjectProp(slot.slotProperty!, spell.FormKey));
        }
        WireQuestScript(substrateQuest, substrate.wireTo, substrateProps);
        report.Actions.Add($"Wired {substrateProps.Count} substrate boon slot(s) on {substrate.wireTo}.");
    }
    else
    {
        report.Actions.Add("No substrateBoons in spec; skipped substrate wiring (state-track race).");
    }

    // 3) Neglect spell (manager-owned).
    if (spec.neglect is { } neglect)
    {
        var neglectSpell = BuildSpell(mod, index, allocator, neglect.spellEditorId!, neglect.displayName!, neglect.playerFacingText!, neglect.effects ?? new(), report);
        if (string.IsNullOrWhiteSpace(neglect.spellProperty))
        {
            throw new InvalidOperationException("neglect.spellProperty must name the manager property to wire.");
        }
        managerProps.Add(ObjectProp(neglect.spellProperty, neglectSpell.FormKey));
    }

    // 4) Per-emphasis reward spells (manager-owned, gated on emphasis-deity piety tier).
    foreach (var reward in spec.emphasisRewards ?? new())
    {
        var spell = BuildSpell(mod, index, allocator, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), report);
        managerProps.Add(ObjectProp(reward.spellProperty ?? reward.spellEditorId!, spell.FormKey));
    }

    WireQuestScript(manager, "PDV__ManagerQuest", managerProps);
    report.Actions.Add($"Wired {managerProps.Count} deity/reward/neglect properties on PDV__ManagerQuest.");

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-race-rewards");
}

// =======================================================================
// SHARED-DEITY RECONCILIATION (--reconcile-shared-deity)
// Generalizes --fix-baandar: for each spec deity entry whose "shared" field
// is non-empty, copy SGE Flags/Priority from the reference deity and set the
// named stance field(s).
// =======================================================================

static void ReconcileSharedDeities(string espPath, RewardsSpec spec, string referenceDeityEdid, bool dryRun, AuthorReport report)
{
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var template = RequireRecord<Quest>(index, referenceDeityEdid);

    var reconciled = 0;
    foreach (var dq in spec.deityQuests ?? new())
    {
        if (dq.shared is not { Count: > 0 })
        {
            continue;
        }

        if (string.IsNullOrWhiteSpace(dq.editorId))
        {
            throw new InvalidOperationException("shared deityQuests[] entry is missing editorId.");
        }

        var quest = RequireRecord<Quest>(index, dq.editorId);
        quest.Flags = template.Flags;
        quest.Priority = template.Priority;
        report.Actions.Add($"Set {dq.editorId} Flags={(int)template.Flags} Priority={template.Priority} (matched {referenceDeityEdid}). Run pdv_refresh_seq after.");

        var stances = ResolveStances(spec, dq);
        ApplyStances(quest, dq.script ?? dq.editorId, stances, report);

        // Eligibility-gate origin race for the alternate (state-track) path.
        if (dq.eligibleStateTrackOriginRace is { } eligible)
        {
            WireQuestScript(quest, dq.script ?? dq.editorId, new ScriptProperty[]
            {
                IntProp("EligibleStateTrackOriginRace", eligible),
            });
            report.Actions.Add($"Set {dq.editorId} EligibleStateTrackOriginRace={eligible}.");
        }

        reconciled++;
    }

    if (reconciled == 0)
    {
        throw new InvalidOperationException("No deityQuests[] entries with a non-empty 'shared' field were found in the spec.");
    }

    WriteModIfNeeded(mod, espPath, dryRun, report, "phase20-race-shared-deity");
}

// =======================================================================
// STANCE RESOLUTION
// =======================================================================

// Resolves the stance fields to set on a deity quest from (in priority order):
//   1) dq.stances[]            list of {field,value}
//   2) dq.stance               single {field,value}
//   3) dq.stanceKhajiit/value  legacy: a value (string NATIVE=0 or numeric)
//      bound to spec.stanceField (default Stance_Khajiit).
static List<StanceSetting> ResolveStances(RewardsSpec spec, RewardsSpecDeityQuest dq)
{
    var result = new List<StanceSetting>();

    if (dq.stances is { Count: > 0 })
    {
        foreach (var s in dq.stances)
        {
            result.Add(new StanceSetting(RequireField(s.field), s.value));
        }
        return result;
    }

    if (dq.stance is { } single)
    {
        result.Add(new StanceSetting(RequireField(single.field), single.value));
        return result;
    }

    if (!string.IsNullOrWhiteSpace(dq.stanceKhajiit))
    {
        var field = spec.stanceField ?? "Stance_Khajiit";
        result.Add(new StanceSetting(field, ParseStanceValue(dq.stanceKhajiit)));
    }

    return result;

    static string RequireField(string? field)
    {
        if (string.IsNullOrWhiteSpace(field))
        {
            throw new InvalidOperationException("stance descriptor is missing 'field'.");
        }
        return field;
    }
}

static int ParseStanceValue(string raw)
{
    if (int.TryParse(raw, out var numeric))
    {
        return numeric;
    }
    return raw.Trim().ToUpperInvariant() switch
    {
        "NATIVE" => 0,
        "FOREIGN" => 1,
        "HOSTILE" => 2,
        _ => throw new InvalidOperationException($"Unknown stance value '{raw}'. Use a number or NATIVE/FOREIGN/HOSTILE."),
    };
}

static void ApplyStances(Quest quest, string scriptName, List<StanceSetting> stances, AuthorReport report)
{
    if (stances.Count == 0)
    {
        return;
    }

    WireQuestScript(quest, scriptName, stances.Select(s => (ScriptProperty)IntProp(s.Field, s.Value)));
    report.Actions.Add($"Set {quest.EditorID} stance(s): {string.Join(", ", stances.Select(s => $"{s.Field}={s.Value}"))}.");
}

static int ResolveDeityIndex(RewardsSpecDeityQuest dq, DeityIndexAllocator allocator, Dictionary<string, ISkyrimMajorRecordGetter> index)
{
    // If the QUST already exists and already carries a DeityIndex, keep it.
    if (index.TryGetValue(dq.editorId!, out var existing)
        && existing is Quest existingQuest
        && DeityIndexAllocator.TryReadDeityIndex(existingQuest, out var current))
    {
        return current;
    }

    var raw = dq.deityIndex;
    if (raw.ValueKind == JsonValueKind.Number && raw.TryGetInt32(out var explicitIndex))
    {
        allocator.Reserve(explicitIndex);
        return explicitIndex;
    }

    // "next-available", null/undefined, or any string => allocate next free.
    return allocator.Next();
}

// =======================================================================
// RECORD HELPERS (race-neutral; copied from the Khajiit baseline)
// =======================================================================

static T RequireRecord<T>(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (!index.TryGetValue(editorId, out var record))
    {
        throw new InvalidOperationException($"Required record is missing: {editorId}");
    }

    if (record is not T typed)
    {
        throw new InvalidOperationException($"{editorId} exists as {record.GetType().Name}, expected {typeof(T).Name}.");
    }

    return typed;
}

static Dictionary<string, ISkyrimMajorRecordGetter> BuildIndex(SkyrimMod mod)
{
    return mod.EnumerateMajorRecords()
        .OfType<ISkyrimMajorRecordGetter>()
        .Where(record => !string.IsNullOrWhiteSpace(record.EditorID))
        .GroupBy(record => record.EditorID!, StringComparer.OrdinalIgnoreCase)
        .ToDictionary(group => group.Key, group => group.First(), StringComparer.OrdinalIgnoreCase);
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

static ScriptIntProperty IntProp(string name, int value)
{
    return new ScriptIntProperty
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
        report.Actions.Add("DRY-RUN: parsing and record resolution complete; ESP NOT written.");
        return;
    }

    var backupDir = Path.Combine(Path.GetDirectoryName(Path.GetFullPath(espPath))!, "Backups", backupSubdir);
    Directory.CreateDirectory(backupDir);
    var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
    var backupPath = Path.Combine(backupDir, $"PlayerDevotion_Framework.esp.{stamp}.bak");
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

static Quest EnsureDeityQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardsSpecDeityQuest dq,
    Quest template,
    FormKey originGlobal,
    FormKey debugGlobal,
    int deityIndex,
    List<StanceSetting> stances,
    AuthorReport report)
{
    Quest quest;
    if (index.TryGetValue(dq.editorId!, out var existing))
    {
        if (existing is not Quest typed)
        {
            throw new InvalidOperationException($"{dq.editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }
        quest = typed;
    }
    else
    {
        quest = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Quests.Add(quest);
        index[dq.editorId!] = quest;
        report.Actions.Add($"Created deity quest {dq.editorId} (DeityIndex {deityIndex}).");
    }

    quest.EditorID = dq.editorId;
    quest.FormVersion = 44;
    quest.Flags = template.Flags;   // SGE flag copied from reference deity.
    quest.Priority = template.Priority;
    quest.Name = Tx(dq.editorId!);

    var baseProps = new List<ScriptProperty>
    {
        StringProp("DeityName", dq.deityName!),
        IntProp("DeityIndex", deityIndex),
        ObjectProp("PDV_GLO_OriginRace", originGlobal),
        ObjectProp("PDV_GLO_DebugLevel", debugGlobal),
    };
    foreach (var stance in stances)
    {
        baseProps.Add(IntProp(stance.Field, stance.Value));
    }

    WireQuestScript(quest, dq.script!, baseProps);
    return quest;
}

static ScriptStringProperty StringProp(string name, string value)
{
    return new ScriptStringProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited,
        Data = value
    };
}

static Spell BuildSpell(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string spellEditorId,
    string displayName,
    string playerFacingText,
    List<RewardsSpecEffect> effects,
    AuthorReport report)
{
    if (playerFacingText.Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{spellEditorId} player-facing text must be ASCII-safe.");
    }

    var built = new List<(RewardsSpecEffect Effect, MagicEffect Record)>();
    foreach (var effect in effects)
    {
        var mgefId = string.IsNullOrWhiteSpace(effect.magicEffectEditorId)
            ? GenerateMgefId(spellEditorId, effect.actorValue!)
            : effect.magicEffectEditorId!;
        var record = EnsureMgef(mod, index, allocator, mgefId, displayName, playerFacingText, effect, report);
        built.Add((effect, record));
    }

    Spell spell;
    if (index.TryGetValue(spellEditorId, out var existing))
    {
        if (existing is not Spell typed)
        {
            throw new InvalidOperationException($"{spellEditorId} already exists as {existing.GetType().Name}, expected Spell.");
        }
        spell = typed;
    }
    else
    {
        spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.Spells.Add(spell);
        index[spellEditorId] = spell;
        report.Actions.Add($"Created spell {spellEditorId}.");
    }

    spell.EditorID = spellEditorId;
    spell.FormVersion = 44;
    spell.Name = Tx(displayName);
    spell.Description = Tx(playerFacingText);
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    spell.Effects.Clear();
    foreach (var (effect, record) in built)
    {
        var spellEffect = new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = effect.magnitude, Area = 0, Duration = 0 },
            Conditions = []
        };
        if (effect.nightOnly)
        {
            AddNightConditions(spellEffect);
        }
        spell.Effects.Add(spellEffect);
    }
    return spell;
}

static MagicEffect EnsureMgef(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string mgefEditorId,
    string displayName,
    string description,
    RewardsSpecEffect effect,
    AuthorReport report)
{
    MagicEffect record;
    if (index.TryGetValue(mgefEditorId, out var existing))
    {
        if (existing is not MagicEffect typed)
        {
            throw new InvalidOperationException($"{mgefEditorId} already exists as {existing.GetType().Name}, expected MagicEffect.");
        }
        record = typed;
    }
    else
    {
        record = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE);
        mod.MagicEffects.Add(record);
        index[mgefEditorId] = record;
        report.Actions.Add($"Created magic effect {mgefEditorId}.");
    }

    record.EditorID = mgefEditorId;
    record.FormVersion = 44;
    record.Name = Tx(displayName);
    record.Description = Tx(description);
    record.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.NoHitEffect;
    record.BaseCost = 0.0f;
    record.MagicSkill = ActorValue.None;
    record.ResistValue = ActorValue.None;
    record.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
    {
        ActorValue = ParseActorValue(effect.actorValue!)
    };
    record.CastType = CastType.ConstantEffect;
    record.TargetType = TargetType.Self;
    record.SkillUsageMultiplier = 0.0f;
    record.ScriptEffectAIScore = 0.0f;
    record.ScriptEffectAIDelayTime = 0.0f;
    return record;
}

static void AddNightConditions(Effect effect)
{
    effect.Conditions.Clear();
    effect.Conditions.Add(new ConditionFloat
    {
        Data = new GetCurrentTimeConditionData(),
        CompareOperator = CompareOperator.GreaterThanOrEqualTo,
        ComparisonValue = 19.0f,
        Flags = Condition.Flag.OR
    });
    effect.Conditions.Add(new ConditionFloat
    {
        Data = new GetCurrentTimeConditionData(),
        CompareOperator = CompareOperator.LessThanOrEqualTo,
        ComparisonValue = 7.0f
    });
}

static string GenerateMgefId(string spellEditorId, string actorValue)
{
    var stem = spellEditorId.StartsWith("PDV_Bless", StringComparison.OrdinalIgnoreCase)
        ? "PDV_MGEF" + spellEditorId.Substring("PDV_Bless".Length)
        : spellEditorId + "_MGEF";
    return $"{stem}_{actorValue}";
}

static ActorValue ParseActorValue(string actorValue)
{
    if (Enum.TryParse<ActorValue>(actorValue, ignoreCase: true, out var parsed))
    {
        return parsed;
    }
    throw new InvalidOperationException($"Unknown ActorValue {actorValue}.");
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

// Allocates DeityIndex values by scanning the DeityIndex script property on
// every existing deity QUST in the mod (editorId starts with PDV_Deity_).
sealed class DeityIndexAllocator
{
    private readonly HashSet<int> usedIndices = new();
    private int nextIndex;

    public int MaxSeen { get; }

    public DeityIndexAllocator(SkyrimMod mod)
    {
        foreach (var quest in mod.Quests)
        {
            if (TryReadDeityIndex(quest, out var idx))
            {
                usedIndices.Add(idx);
            }
        }

        MaxSeen = usedIndices.Count == 0 ? -1 : usedIndices.Max();
        // Start above existing low indices to avoid colliding with the core
        // pantheon. Existing PDV deity indices are low (single digit); reward
        // deities are conventionally allocated at 40+.
        nextIndex = usedIndices.Count == 0 ? 40 : Math.Max(40, MaxSeen + 1);
        while (usedIndices.Contains(nextIndex))
        {
            nextIndex++;
        }
    }

    public int Peek() => nextIndex;

    public int Next()
    {
        while (usedIndices.Contains(nextIndex))
        {
            nextIndex++;
        }

        var idx = nextIndex++;
        usedIndices.Add(idx);
        return idx;
    }

    public void Reserve(int index)
    {
        usedIndices.Add(index);
        if (index >= nextIndex)
        {
            nextIndex = index + 1;
        }
    }

    public static bool TryReadDeityIndex(IQuestGetter quest, out int index)
    {
        index = 0;
        var adapter = quest.VirtualMachineAdapter;
        if (adapter is null)
        {
            return false;
        }

        foreach (var script in adapter.Scripts)
        {
            foreach (var prop in script.Properties)
            {
                if (prop is IScriptIntPropertyGetter intProp
                    && string.Equals(prop.Name, "DeityIndex", StringComparison.OrdinalIgnoreCase))
                {
                    index = intProp.Data;
                    return true;
                }
            }
        }

        return false;
    }
}

sealed class AuthorReport
{
    public string Status { get; set; } = "STARTED";
    public string? EspPath { get; set; }
    public string? SpecPath { get; set; }
    public bool DryRun { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public DateTimeOffset FinishedAt { get; set; }
    public string? BackupPath { get; set; }
    public List<string> TouchedFiles { get; } = [];
    public List<string> Actions { get; } = [];
    public List<string> Errors { get; } = [];
    public string? Exception { get; set; }
}

readonly record struct StanceSetting(string Field, int Value);

sealed class RewardsSpec
{
    public List<RewardsSpecDeityQuest>? deityQuests { get; set; }
    public List<RewardsSpecManagerProp>? managerDeityProperties { get; set; }
    public RewardsSpecSubstrate? substrateBoons { get; set; }
    public RewardsSpecReward? neglect { get; set; }
    public List<RewardsSpecReward>? emphasisRewards { get; set; }

    // Optional: default stance field for entries that supply only a stance value.
    public string? stanceField { get; set; }
}

sealed class RewardsSpecDeityQuest
{
    public string? editorId { get; set; }
    public string? script { get; set; }
    public string? deityName { get; set; }

    // Index allocation: "next-available" (string) or an explicit int.
    public JsonElement deityIndex { get; set; }

    // false => reuse the existing QUST owned by another race; do not create
    // or allocate a DeityIndex.
    public bool? create { get; set; }

    // Cross-race ownership marker; drives --reconcile-shared-deity.
    public List<string>? shared { get; set; }

    // Stance descriptors (generalized).
    public StanceDescriptor? stance { get; set; }
    public List<StanceDescriptor>? stances { get; set; }

    // Legacy Khajiit field: a value (NATIVE/FOREIGN/HOSTILE or number) bound to
    // spec.stanceField (default Stance_Khajiit).
    public string? stanceKhajiit { get; set; }

    // Reconciliation extra: eligibility-gate origin race for the alt path.
    public int? eligibleStateTrackOriginRace { get; set; }
}

sealed class StanceDescriptor
{
    public string? field { get; set; }
    public int value { get; set; }
}

sealed class RewardsSpecManagerProp
{
    public string? property { get; set; }
    public string? record { get; set; }
}

sealed class RewardsSpecSubstrate
{
    public string? wireTo { get; set; }
    public List<RewardsSpecSlot>? slots { get; set; }
}

sealed class RewardsSpecSlot
{
    public string? slotProperty { get; set; }
    public string? spellEditorId { get; set; }
    public string? displayName { get; set; }
    public List<RewardsSpecEffect>? effects { get; set; }
    public string? playerFacingText { get; set; }
}

sealed class RewardsSpecReward
{
    public string? emphasis { get; set; }
    public string? tier { get; set; }
    public string? spellEditorId { get; set; }
    public string? spellProperty { get; set; }
    public string? displayName { get; set; }
    public List<RewardsSpecEffect>? effects { get; set; }
    public string? playerFacingText { get; set; }
}

sealed class RewardsSpecEffect
{
    public string? magicEffectEditorId { get; set; }
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public bool nightOnly { get; set; }
}
