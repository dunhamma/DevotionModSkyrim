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
//   --check-rewards             Read-only check of records/properties described
//                               by --rewards-spec.
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

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string defaultReferenceDeity = "PDV_Deity_Kyne";

var dryRun = args.Contains("--dry-run");
var authorRewards = args.Contains("--author-rewards");
var checkRewards = args.Contains("--check-rewards");
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

    if (!authorRewards && !checkRewards && !reconcileShared)
    {
        throw new InvalidOperationException("Specify --author-rewards, --check-rewards, or --reconcile-shared-deity.");
    }

    var spec = LoadSpec(rewardsSpecPath);

    if (reconcileShared)
    {
        ReconcileSharedDeities(espPath, spec, referenceDeity, dryRun, report);
    }
    else if (checkRewards)
    {
        CheckRewards(espPath, spec, report);
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

static void CheckRewards(string espPath, RewardsSpec spec, AuthorReport report)
{
    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = BuildIndex(mod);
    var debugGlobal = RequireRecord<Global>(index, "PDV_GLO_DebugLevel");
    var manager = RequireRecord<Quest>(index, "PDV__ManagerQuest");
    var managerScript = RequireScript(manager, "PDV__ManagerQuest");

    foreach (var trackSpec in spec.reputationRecordAuthoring ?? new())
    {
        CheckReputationTrack(index, managerScript, debugGlobal.FormKey, trackSpec, report);
    }

    foreach (var messageDefinition in spec.messageRecords ?? new())
    {
        CheckMessageRecord(index, managerScript, messageDefinition, report);
    }

    foreach (var modifier in spec.deityTrackModifiers ?? new())
    {
        CheckDeityTrackModifier(index, modifier, report);
    }

    if (spec.substrateBoons is { } substrate && substrate.slots is { } slots)
    {
        if (string.IsNullOrWhiteSpace(substrate.wireTo))
        {
            throw new InvalidOperationException("substrateBoons.wireTo must name the substrate quest editorId.");
        }

        var substrateQuest = RequireRecord<Quest>(index, substrate.wireTo);
        var substrateScript = RequireScript(substrateQuest, substrate.wireTo);
        foreach (var slot in slots)
        {
            CheckRewardSlot(index, substrateScript, substrate.wireTo, slot, report);
        }
    }

    if (spec.neglect is { } neglect)
    {
        CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", neglect, neglect.spellProperty, requireProperty: true, report);
    }

    foreach (var reward in spec.emphasisRewards ?? new())
    {
        CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", reward, reward.spellProperty ?? reward.spellEditorId, requireProperty: true, report);
    }

    foreach (var reward in spec.broadState?.rewards ?? new())
    {
        CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", reward, reward.spellProperty ?? reward.spellEditorId, requireProperty: true, report);
    }

    foreach (var reward in spec.supportSpells ?? new())
    {
        CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", reward, reward.spellProperty ?? reward.spellEditorId, requireProperty: true, report);
    }

    if (spec.farShoresToken is { } farShoresToken)
    {
        CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", farShoresToken, farShoresToken.spellProperty ?? farShoresToken.spellEditorId, requireProperty: true, report);
    }

    if (spec.creedViolationLoss.ValueKind == JsonValueKind.Array)
    {
        foreach (var el in spec.creedViolationLoss.EnumerateArray())
        {
            var loss = el.Deserialize<RewardsSpecReward>(new JsonSerializerOptions { PropertyNameCaseInsensitive = true })
                ?? throw new InvalidOperationException("creedViolationLoss[] entry did not parse.");
            CheckRewardSpell(index, managerScript, "PDV__ManagerQuest", loss, loss.spellProperty, requireProperty: false, report);
        }
    }

    report.Actions.Add("Read-only reward/spec check complete; ESP not written.");
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

    // Ensure the near-water context FormList exists BEFORE any reward spell resolves its
    // GetInCurrentLocFormList condition (nearWaterOnly effects). Idempotent: rebuilds
    // membership from the spec each run.
    EnsureNearWaterFormList(mod, index, allocator, spec, report);

    // Scan existing deity QUSTs for their DeityIndex script values so we can
    // allocate the next-available index(es) for any NEW deity.
    var indexAllocator = new DeityIndexAllocator(mod);
    report.Actions.Add($"Scanned existing deity QUSTs; max DeityIndex={indexAllocator.MaxSeen}, next-available starts at {indexAllocator.Peek()}.");

    var managerProps = new List<ScriptProperty>();

    // 0) Optional state-track records and global mirrors. This is opt-in so old
    // planning-only state names do not become records by accident.
    foreach (var state in spec.stateRecordAuthoring ?? new())
    {
        if (string.IsNullOrWhiteSpace(state.editorId))
        {
            throw new InvalidOperationException("stateRecordAuthoring[] entry is missing editorId.");
        }

        var labels = state.labels ?? new();
        var globalEditorId = string.IsNullOrWhiteSpace(state.globalEditorId)
            ? $"{state.editorId}_Global"
            : state.globalEditorId!;
        var trackName = string.IsNullOrWhiteSpace(state.trackName)
            ? state.editorId!
            : state.trackName!;

        var stateGlobal = EnsureGlobal(mod, index, allocator, globalEditorId, state.initialValue ?? 0.0f, report);
        var stateQuest = EnsureQuest(mod, index, allocator, state.editorId!, report);
        ConfigureQuestShell(stateQuest, state.editorId!);
        WireQuestScript(stateQuest, "PDV_StateTrack", new ScriptProperty[]
        {
            StringProp("TrackName", trackName),
            ObjectProp("StateGlobal", stateGlobal.FormKey),
            ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
            StringListProp("StateLabels", labels.ToArray()),
        });
        report.Actions.Add($"Ensured state track {state.editorId} with {labels.Count} labels.");

        foreach (var listEditorId in state.addToFormLists ?? new())
        {
            var formList = RequireRecord<FormList>(index, listEditorId);
            if (!formList.Items.Any(item => item.FormKey.Equals(stateQuest.FormKey)))
            {
                formList.Items.Add(stateQuest.FormKey.ToLink<ISkyrimMajorRecordGetter>());
                report.Actions.Add($"Added {state.editorId} to {listEditorId}.");
            }
        }

        if (!string.IsNullOrWhiteSpace(state.managerGlobalProperty))
        {
            managerProps.Add(ObjectProp(state.managerGlobalProperty!, stateGlobal.FormKey));
        }

        if (!string.IsNullOrWhiteSpace(state.managerTrackProperty))
        {
            managerProps.Add(ObjectProp(state.managerTrackProperty!, stateQuest.FormKey));
        }
    }

    foreach (var trackSpec in spec.reputationRecordAuthoring ?? new())
    {
        if (string.IsNullOrWhiteSpace(trackSpec.editorId))
        {
            throw new InvalidOperationException("reputationRecordAuthoring[] entry is missing editorId.");
        }

        if (string.IsNullOrWhiteSpace(trackSpec.globalEditorId))
        {
            throw new InvalidOperationException($"{trackSpec.editorId} is missing globalEditorId.");
        }

        var thresholdValues = trackSpec.thresholdValues ?? new();
        var thresholdLabels = trackSpec.thresholdLabels ?? new();
        if (thresholdLabels.Count != thresholdValues.Count + 1)
        {
            throw new InvalidOperationException($"{trackSpec.editorId} thresholdLabels must have exactly one more entry than thresholdValues.");
        }

        var trackName = string.IsNullOrWhiteSpace(trackSpec.trackName)
            ? trackSpec.editorId!
            : trackSpec.trackName!;

        var backingGlobal = EnsureGlobal(mod, index, allocator, trackSpec.globalEditorId!, trackSpec.initialValue ?? 0.0f, report);
        var trackQuest = EnsureQuest(mod, index, allocator, trackSpec.editorId!, report);
        ConfigureQuestShell(trackQuest, trackSpec.editorId!);
        WireQuestScript(trackQuest, "PDV_ReputationTrack", new ScriptProperty[]
        {
            StringProp("TrackName", trackName),
            ObjectProp("StorageBacking", backingGlobal.FormKey),
            ObjectProp("PDV_GLO_DebugLevel", debugGlobal.FormKey),
            IntListProp("ThresholdValues", thresholdValues.ToArray()),
            StringListProp("ThresholdLabels", thresholdLabels.ToArray()),
        });
        report.Actions.Add($"Ensured reputation track {trackSpec.editorId} with {thresholdLabels.Count} labels.");

        foreach (var listEditorId in trackSpec.addToFormLists ?? new())
        {
            var formList = RequireRecord<FormList>(index, listEditorId);
            if (!formList.Items.Any(item => item.FormKey.Equals(trackQuest.FormKey)))
            {
                formList.Items.Add(trackQuest.FormKey.ToLink<ISkyrimMajorRecordGetter>());
                report.Actions.Add($"Added {trackSpec.editorId} to {listEditorId}.");
            }
        }

        if (!string.IsNullOrWhiteSpace(trackSpec.managerGlobalProperty))
        {
            managerProps.Add(ObjectProp(trackSpec.managerGlobalProperty!, backingGlobal.FormKey));
        }

        if (!string.IsNullOrWhiteSpace(trackSpec.managerTrackProperty))
        {
            managerProps.Add(ObjectProp(trackSpec.managerTrackProperty!, trackQuest.FormKey));
        }
    }

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

    foreach (var modifier in spec.deityTrackModifiers ?? new())
    {
        WireDeityTrackModifier(index, modifier, report);
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
            var spell = BuildSpell(mod, index, allocator, slot.spellEditorId!, slot.displayName!, slot.playerFacingText!, slot.effects ?? new(), preserveAdditionalEffects: false, report);
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
        var neglectSpell = BuildSpell(mod, index, allocator, neglect.spellEditorId!, neglect.displayName!, neglect.playerFacingText!, neglect.effects ?? new(), neglect.preserveAdditionalEffects, report);
        if (string.IsNullOrWhiteSpace(neglect.spellProperty))
        {
            throw new InvalidOperationException("neglect.spellProperty must name the manager property to wire.");
        }
        managerProps.Add(ObjectProp(neglect.spellProperty, neglectSpell.FormKey));
    }

    // 4) Per-emphasis reward spells (manager-owned, gated on emphasis-deity piety tier).
    foreach (var reward in spec.emphasisRewards ?? new())
    {
        var spell = BuildSpell(mod, index, allocator, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), reward.preserveAdditionalEffects, report);
        managerProps.Add(ObjectProp(reward.spellProperty ?? reward.spellEditorId!, spell.FormKey));
    }

    // 5) Broad-state lane rewards (manager-owned broad boon tiers, e.g. Altmer
    //    Orthodox T1/T2). Same machinery as emphasis rewards; the manager
    //    already declares + applies these properties (SyncRaceRewardSpell),
    //    they were just never authored as records.
    foreach (var reward in spec.broadState?.rewards ?? new())
    {
        var spell = BuildSpell(mod, index, allocator, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), reward.preserveAdditionalEffects, report);
        managerProps.Add(ObjectProp(reward.spellProperty ?? reward.spellEditorId!, spell.FormKey));
    }

    // 5b) Support spells that are not part of the broad/focused reward ladder.
    //     Redguard Far Shores token uses this path.
    foreach (var reward in spec.supportSpells ?? new())
    {
        var spell = BuildSpell(mod, index, allocator, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), reward.preserveAdditionalEffects, report);
        managerProps.Add(ObjectProp(reward.spellProperty ?? reward.spellEditorId!, spell.FormKey));
    }

    if (spec.farShoresToken is { } farShoresToken)
    {
        var spell = BuildSpell(mod, index, allocator, farShoresToken.spellEditorId!, farShoresToken.displayName!, farShoresToken.playerFacingText!, farShoresToken.effects ?? new(), farShoresToken.preserveAdditionalEffects, report);
        managerProps.Add(ObjectProp(farShoresToken.spellProperty ?? farShoresToken.spellEditorId!, spell.FormKey));
    }

    // 6) Creed-violation loss spells (applied on authored creed-breach beats).
    //    Only the array (spell-record) shape is authored; the object shape is
    //    signal-penalty routes with no records. Records only here; the manager
    //    applies them by the creed system, not a fixed Spell Property.
    if (spec.creedViolationLoss.ValueKind == JsonValueKind.Array)
    {
        foreach (var el in spec.creedViolationLoss.EnumerateArray())
        {
            var loss = el.Deserialize<RewardsSpecReward>(new JsonSerializerOptions { PropertyNameCaseInsensitive = true })!;
            BuildSpell(mod, index, allocator, loss.spellEditorId!, loss.displayName!, loss.playerFacingText!, loss.effects ?? new(), loss.preserveAdditionalEffects, report);
            if (!string.IsNullOrWhiteSpace(loss.spellProperty))
            {
                managerProps.Add(ObjectProp(loss.spellProperty!, index[loss.spellEditorId!].FormKey));
            }
        }
    }

    // 7) Message/notification records surfaced by the manager.
    foreach (var messageDefinition in spec.messageRecords ?? new())
    {
        var message = EnsureMessage(mod, index, allocator, messageDefinition, report);
        ConfigureMessage(message, messageDefinition);
        managerProps.Add(ObjectProp(messageDefinition.property ?? messageDefinition.editorId!, message.FormKey));
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
        report.Actions.Add("No shared deity entries found; reconciliation no-op.");
        return;
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

static ScriptEntry RequireScript(Quest quest, string scriptName)
{
    var script = quest.VirtualMachineAdapter?.Scripts.FirstOrDefault(candidate => string.Equals(candidate.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script is null)
    {
        throw new InvalidOperationException($"{quest.EditorID} is missing script {scriptName}.");
    }

    return script;
}

static void CheckReputationTrack(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    ScriptEntry managerScript,
    FormKey debugGlobal,
    RewardsSpecReputationRecord trackSpec,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(trackSpec.editorId))
    {
        throw new InvalidOperationException("reputationRecordAuthoring[] entry is missing editorId.");
    }

    if (string.IsNullOrWhiteSpace(trackSpec.globalEditorId))
    {
        throw new InvalidOperationException($"{trackSpec.editorId} is missing globalEditorId.");
    }

    var expectedValues = trackSpec.thresholdValues ?? new();
    var expectedLabels = trackSpec.thresholdLabels ?? new();
    if (expectedLabels.Count != expectedValues.Count + 1)
    {
        throw new InvalidOperationException($"{trackSpec.editorId} thresholdLabels must have exactly one more entry than thresholdValues.");
    }

    var backingGlobal = RequireRecord<Global>(index, trackSpec.globalEditorId!);
    var trackQuest = RequireRecord<Quest>(index, trackSpec.editorId!);
    var trackScript = RequireScript(trackQuest, "PDV_ReputationTrack");
    var trackName = string.IsNullOrWhiteSpace(trackSpec.trackName) ? trackSpec.editorId! : trackSpec.trackName!;

    CheckStringProperty(trackScript, "TrackName", trackName, trackSpec.editorId!, report);
    CheckObjectProperty(trackScript, "StorageBacking", backingGlobal.FormKey, trackSpec.editorId!, report);
    CheckObjectProperty(trackScript, "PDV_GLO_DebugLevel", debugGlobal, trackSpec.editorId!, report);
    CheckIntListProperty(trackScript, "ThresholdValues", expectedValues, trackSpec.editorId!, report);
    CheckStringListProperty(trackScript, "ThresholdLabels", expectedLabels, trackSpec.editorId!, report);

    foreach (var listEditorId in trackSpec.addToFormLists ?? new())
    {
        var formList = RequireRecord<FormList>(index, listEditorId);
        if (!formList.Items.Any(item => item.FormKey.Equals(trackQuest.FormKey)))
        {
            report.Errors.Add($"{listEditorId} does not contain {trackSpec.editorId}.");
        }
    }

    if (!string.IsNullOrWhiteSpace(trackSpec.managerGlobalProperty))
    {
        CheckObjectProperty(managerScript, trackSpec.managerGlobalProperty!, backingGlobal.FormKey, "PDV__ManagerQuest", report);
    }

    if (!string.IsNullOrWhiteSpace(trackSpec.managerTrackProperty))
    {
        CheckObjectProperty(managerScript, trackSpec.managerTrackProperty!, trackQuest.FormKey, "PDV__ManagerQuest", report);
    }

    report.Actions.Add($"Checked reputation track {trackSpec.editorId}.");
}

static void CheckMessageRecord(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    ScriptEntry managerScript,
    RewardsSpecMessage messageDefinition,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(messageDefinition.editorId))
    {
        throw new InvalidOperationException("messageRecords[] entry is missing editorId.");
    }

    var message = RequireRecord<Message>(index, messageDefinition.editorId!);
    var expectedBody = messageDefinition.text ?? messageDefinition.body ?? "";
    var expectedTitle = messageDefinition.title ?? messageDefinition.editorId!;
    var expectedMessageBox = messageDefinition.messageBox
        || string.Equals(messageDefinition.kind, "messageBox", StringComparison.OrdinalIgnoreCase);

    if (!string.Equals(message.Name?.String ?? "", expectedTitle, StringComparison.Ordinal))
    {
        report.Errors.Add($"{messageDefinition.editorId} title is '{message.Name?.String}', expected '{expectedTitle}'.");
    }

    if (!string.Equals(message.Description?.String ?? "", expectedBody, StringComparison.Ordinal))
    {
        report.Errors.Add($"{messageDefinition.editorId} body does not match spec.");
    }

    var hasMessageBoxFlag = message.Flags.HasFlag(Message.Flag.MessageBox);
    if (hasMessageBoxFlag != expectedMessageBox)
    {
        report.Errors.Add($"{messageDefinition.editorId} MessageBox flag is {hasMessageBoxFlag}, expected {expectedMessageBox}.");
    }

    var expectedButtons = messageDefinition.buttons ?? new();
    if (expectedButtons.Count == 0 && expectedMessageBox)
    {
        expectedButtons = new List<string> { "Continue" };
    }

    if (message.MenuButtons.Count != expectedButtons.Count)
    {
        report.Errors.Add($"{messageDefinition.editorId} has {message.MenuButtons.Count} button(s), expected {expectedButtons.Count}.");
    }
    else
    {
        for (var i = 0; i < expectedButtons.Count; i++)
        {
            var actualText = message.MenuButtons[i].Text?.String ?? "";
            if (!string.Equals(actualText, expectedButtons[i], StringComparison.Ordinal))
            {
                report.Errors.Add($"{messageDefinition.editorId} button {i} is '{actualText}', expected '{expectedButtons[i]}'.");
            }
        }
    }

    CheckObjectProperty(managerScript, messageDefinition.property ?? messageDefinition.editorId!, message.FormKey, "PDV__ManagerQuest", report);
    report.Actions.Add($"Checked message {messageDefinition.editorId}.");
}

static void WireDeityTrackModifier(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    RewardsSpecDeityTrackModifier modifier,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(modifier.deityEditorId))
    {
        throw new InvalidOperationException("deityTrackModifiers[] entry is missing deityEditorId.");
    }

    var deityQuest = RequireRecord<Quest>(index, modifier.deityEditorId!);
    var scriptName = string.IsNullOrWhiteSpace(modifier.script)
        ? modifier.deityEditorId!
        : modifier.script!;
    var deityScript = RequireScript(deityQuest, scriptName);
    var props = BuildDeityTrackModifierProperties(index, modifier);
    WireQuestScript(deityQuest, scriptName, props);
    report.Actions.Add($"Wired {props.Count} track modifier properties on {modifier.deityEditorId}.");
}

static void CheckDeityTrackModifier(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    RewardsSpecDeityTrackModifier modifier,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(modifier.deityEditorId))
    {
        throw new InvalidOperationException("deityTrackModifiers[] entry is missing deityEditorId.");
    }

    var deityQuest = RequireRecord<Quest>(index, modifier.deityEditorId!);
    var scriptName = string.IsNullOrWhiteSpace(modifier.script)
        ? modifier.deityEditorId!
        : modifier.script!;
    var deityScript = RequireScript(deityQuest, scriptName);

    if (!string.IsNullOrWhiteSpace(modifier.gainTrack))
    {
        var gainTrack = RequireRecord<Quest>(index, modifier.gainTrack!);
        CheckObjectProperty(deityScript, "GainModifyingTrack", gainTrack.FormKey, modifier.deityEditorId!, report);
        CheckFloatListProperty(deityScript, "GainMultiplierPerTrackState", modifier.gainMultipliers ?? new(), modifier.deityEditorId!, report);
    }

    if (!string.IsNullOrWhiteSpace(modifier.decayTrack))
    {
        var decayTrack = RequireRecord<Quest>(index, modifier.decayTrack!);
        CheckObjectProperty(deityScript, "DecayModifyingTrack", decayTrack.FormKey, modifier.deityEditorId!, report);
        CheckFloatListProperty(deityScript, "DecayMultiplierPerTrackState", modifier.decayMultipliers ?? new(), modifier.deityEditorId!, report);
    }
}

static List<ScriptProperty> BuildDeityTrackModifierProperties(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    RewardsSpecDeityTrackModifier modifier)
{
    var props = new List<ScriptProperty>();

    if (!string.IsNullOrWhiteSpace(modifier.gainTrack))
    {
        var gainTrack = RequireRecord<Quest>(index, modifier.gainTrack!);
        props.Add(ObjectProp("GainModifyingTrack", gainTrack.FormKey));
        props.Add(FloatListProp("GainMultiplierPerTrackState", (modifier.gainMultipliers ?? new()).ToArray()));
    }

    if (!string.IsNullOrWhiteSpace(modifier.decayTrack))
    {
        var decayTrack = RequireRecord<Quest>(index, modifier.decayTrack!);
        props.Add(ObjectProp("DecayModifyingTrack", decayTrack.FormKey));
        props.Add(FloatListProp("DecayMultiplierPerTrackState", (modifier.decayMultipliers ?? new()).ToArray()));
    }

    if (props.Count == 0)
    {
        throw new InvalidOperationException($"{modifier.deityEditorId} track modifier must define gainTrack and/or decayTrack.");
    }

    return props;
}

static void CheckRewardSlot(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    ScriptEntry ownerScript,
    string owner,
    RewardsSpecSlot slot,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(slot.spellEditorId))
    {
        throw new InvalidOperationException("substrateBoons.slots[] entry is missing spellEditorId.");
    }

    var spell = CheckSpellPacket(index, slot.spellEditorId!, slot.displayName!, slot.playerFacingText!, slot.effects ?? new(), allowAdditionalEffects: false, report);
    if (string.IsNullOrWhiteSpace(slot.slotProperty))
    {
        throw new InvalidOperationException($"{slot.spellEditorId} is missing slotProperty.");
    }

    CheckObjectProperty(ownerScript, slot.slotProperty!, spell.FormKey, owner, report);
    report.Actions.Add($"Checked substrate reward spell {slot.spellEditorId}.");
}

static void CheckRewardSpell(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    ScriptEntry managerScript,
    string owner,
    RewardsSpecReward reward,
    string? propertyName,
    bool requireProperty,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(reward.spellEditorId))
    {
        throw new InvalidOperationException("Reward entry is missing spellEditorId.");
    }

    var spell = CheckSpellPacket(index, reward.spellEditorId!, reward.displayName!, reward.playerFacingText!, reward.effects ?? new(), reward.preserveAdditionalEffects, report);
    if (!string.IsNullOrWhiteSpace(propertyName))
    {
        CheckObjectProperty(managerScript, propertyName!, spell.FormKey, owner, report);
    }
    else if (requireProperty)
    {
        report.Errors.Add($"{reward.spellEditorId} is missing required manager spell property in spec.");
    }

    report.Actions.Add($"Checked reward spell {reward.spellEditorId}.");
}

static Spell CheckSpellPacket(
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    string spellEditorId,
    string displayName,
    string playerFacingText,
    List<RewardsSpecEffect> expectedEffects,
    bool allowAdditionalEffects,
    AuthorReport report)
{
    var spell = RequireRecord<Spell>(index, spellEditorId);
    if (!string.Equals(spell.Name?.String ?? "", displayName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spellEditorId} name is '{spell.Name?.String}', expected '{displayName}'.");
    }

    if (!string.Equals(spell.Description?.String ?? "", playerFacingText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{spellEditorId} description does not match spec.");
    }

    var expectedSpellType = ParseSpellType(expectedEffects);
    var expectedCastType = ParseCastType(expectedEffects);

    if (spell.Type != expectedSpellType)
    {
        report.Errors.Add($"{spellEditorId} type is {spell.Type}, expected {expectedSpellType}.");
    }

    if (spell.CastType != expectedCastType)
    {
        report.Errors.Add($"{spellEditorId} cast type is {spell.CastType}, expected {expectedCastType}.");
    }

    if (spell.TargetType != TargetType.Self)
    {
        report.Errors.Add($"{spellEditorId} target type is {spell.TargetType}, expected Self.");
    }

    if ((!allowAdditionalEffects && spell.Effects.Count != expectedEffects.Count)
        || (allowAdditionalEffects && spell.Effects.Count < expectedEffects.Count))
    {
        var expectedCount = allowAdditionalEffects
            ? $"at least {expectedEffects.Count}"
            : expectedEffects.Count.ToString();
        report.Errors.Add($"{spellEditorId} has {spell.Effects.Count} effect(s), expected {expectedCount}.");
        return spell;
    }

    for (var i = 0; i < expectedEffects.Count; i++)
    {
        var expectedEffect = expectedEffects[i];
        var expectedMgefId = string.IsNullOrWhiteSpace(expectedEffect.magicEffectEditorId)
            ? GenerateMgefId(spellEditorId, expectedEffect.actorValue!)
            : expectedEffect.magicEffectEditorId!;
        var mgef = RequireRecord<MagicEffect>(index, expectedMgefId);
        var actualEffect = spell.Effects[i];

        if (!actualEffect.BaseEffect.FormKey.Equals(mgef.FormKey))
        {
            report.Errors.Add($"{spellEditorId} effect {i} points at {actualEffect.BaseEffect.FormKey}, expected {mgef.FormKey} ({expectedMgefId}).");
        }

        if (!NearlyEqual(actualEffect.Data?.Magnitude ?? 0.0f, expectedEffect.magnitude))
        {
            report.Errors.Add($"{spellEditorId} effect {i} magnitude is {actualEffect.Data?.Magnitude ?? 0.0f}, expected {expectedEffect.magnitude}.");
        }
        if ((actualEffect.Data?.Duration ?? 0) != expectedEffect.duration)
        {
            report.Errors.Add($"{spellEditorId} effect {i} duration is {actualEffect.Data?.Duration ?? 0}, expected {expectedEffect.duration}.");
        }

        var expectedConditionCount = CountEffectConditions(expectedEffect);
        if (actualEffect.Conditions.Count != expectedConditionCount)
        {
            report.Errors.Add($"{spellEditorId} effect {i} has {actualEffect.Conditions.Count} condition(s), expected {expectedConditionCount}.");
        }

        CheckMagicEffectPacket(mgef, spellEditorId, displayName, playerFacingText, expectedEffect, report);
    }

    return spell;
}

static void CheckMagicEffectPacket(
    MagicEffect mgef,
    string spellEditorId,
    string displayName,
    string playerFacingText,
    RewardsSpecEffect expectedEffect,
    AuthorReport report)
{
    var expectedName = string.IsNullOrWhiteSpace(expectedEffect.effectName) ? displayName : expectedEffect.effectName!;
    if (!string.Equals(mgef.Name?.String ?? "", expectedName, StringComparison.Ordinal))
    {
        report.Errors.Add($"{mgef.EditorID} name is '{mgef.Name?.String}', expected '{expectedName}'.");
    }

    if (!string.Equals(mgef.Description?.String ?? "", playerFacingText, StringComparison.Ordinal))
    {
        report.Errors.Add($"{mgef.EditorID} description does not match {spellEditorId} spec text.");
    }

    var expectedActorValue = ParseActorValue(expectedEffect.actorValue!);
    if (UsesPeakValueModifier(expectedActorValue))
    {
        if (mgef.Archetype is not MagicEffectPeakValueModArchetype peakValue || peakValue.ActorValue != expectedActorValue)
        {
            report.Errors.Add($"{mgef.EditorID} archetype is not PeakValueModifier for {expectedActorValue}.");
        }
    }
    else if (mgef.Archetype is not MagicEffectArchetype valueModifier || valueModifier.ActorValue != expectedActorValue)
    {
        report.Errors.Add($"{mgef.EditorID} archetype is not ValueModifier for {expectedActorValue}.");
    }
}

static bool NearlyEqual(float actual, float expected) => Math.Abs(actual - expected) < 0.001f;

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

static Quest EnsureQuest(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Quest quest)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Quest.");
        }

        return quest;
    }

    var created = new Quest(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Quests.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created quest {editorId}.");
    return created;
}

static void ConfigureQuestShell(Quest quest, string editorId)
{
    quest.EditorID = editorId;
    quest.Name = Tx(editorId);
    quest.FormVersion = 44;
    quest.QuestFormVersion = 65;
    quest.Type = Quest.TypeEnum.None;
    quest.Priority = 0;
}

static Global EnsureGlobal(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    string editorId,
    float value,
    AuthorReport report)
{
    if (index.TryGetValue(editorId, out var existing))
    {
        if (existing is not Global global)
        {
            throw new InvalidOperationException($"{editorId} already exists as {existing.GetType().Name}, expected Global.");
        }

        ConfigureGlobal(global, editorId, value);
        return global;
    }

    var created = new GlobalFloat(allocator.Next(), SkyrimRelease.SkyrimSE);
    ConfigureGlobal(created, editorId, value);
    mod.Globals.Add(created);
    index[editorId] = created;
    report.Actions.Add($"Created global {editorId}.");
    return created;
}

static void ConfigureGlobal(Global global, string editorId, float value)
{
    global.EditorID = editorId;
    global.FormVersion = 44;
    global.RawFloat = value;
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

static ScriptProperty? FindProperty(ScriptEntry script, string propertyName)
{
    return script.Properties.FirstOrDefault(candidate => string.Equals(candidate.Name, propertyName, StringComparison.OrdinalIgnoreCase));
}

static void CheckObjectProperty(ScriptEntry script, string propertyName, FormKey expectedFormKey, string owner, AuthorReport report)
{
    if (FindProperty(script, propertyName) is not ScriptObjectProperty objectProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not an object property.");
        return;
    }

    if (!objectProperty.Object.FormKey.Equals(expectedFormKey))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} points at {objectProperty.Object.FormKey}, expected {expectedFormKey}.");
    }
}

static void CheckStringProperty(ScriptEntry script, string propertyName, string expectedValue, string owner, AuthorReport report)
{
    if (FindProperty(script, propertyName) is not ScriptStringProperty stringProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not a string property.");
        return;
    }

    if (!string.Equals(stringProperty.Data, expectedValue, StringComparison.Ordinal))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is '{stringProperty.Data}', expected '{expectedValue}'.");
    }
}

static void CheckIntListProperty(ScriptEntry script, string propertyName, List<int> expectedValues, string owner, AuthorReport report)
{
    if (FindProperty(script, propertyName) is not ScriptIntListProperty listProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not an int-list property.");
        return;
    }

    var actualValues = listProperty.Data.ToList();
    if (!actualValues.SequenceEqual(expectedValues))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is [{string.Join(", ", actualValues)}], expected [{string.Join(", ", expectedValues)}].");
    }
}

static void CheckStringListProperty(ScriptEntry script, string propertyName, List<string> expectedValues, string owner, AuthorReport report)
{
    if (FindProperty(script, propertyName) is not ScriptStringListProperty listProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not a string-list property.");
        return;
    }

    var actualValues = listProperty.Data.ToList();
    if (!actualValues.SequenceEqual(expectedValues))
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is [{string.Join(", ", actualValues)}], expected [{string.Join(", ", expectedValues)}].");
    }
}

static void CheckFloatListProperty(ScriptEntry script, string propertyName, List<float> expectedValues, string owner, AuthorReport report)
{
    if (FindProperty(script, propertyName) is not ScriptFloatListProperty listProperty)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} is missing or not a float-list property.");
        return;
    }

    var actualValues = listProperty.Data.ToList();
    if (actualValues.Count != expectedValues.Count)
    {
        report.Errors.Add($"{owner}.{script.Name}.{propertyName} has {actualValues.Count} entries, expected {expectedValues.Count}.");
        return;
    }

    for (var i = 0; i < expectedValues.Count; i++)
    {
        if (Math.Abs(actualValues[i] - expectedValues[i]) > 0.0001f)
        {
            report.Errors.Add($"{owner}.{script.Name}.{propertyName}[{i}] is {actualValues[i]}, expected {expectedValues[i]}.");
            return;
        }
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

static ScriptStringListProperty StringListProp(string name, params string[] values)
{
    var property = new ScriptStringListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };

    foreach (var value in values)
    {
        property.Data.Add(value);
    }

    return property;
}

static ScriptIntListProperty IntListProp(string name, params int[] values)
{
    var property = new ScriptIntListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };

    foreach (var value in values)
    {
        property.Data.Add(value);
    }

    return property;
}

static ScriptFloatListProperty FloatListProp(string name, params float[] values)
{
    var property = new ScriptFloatListProperty
    {
        Name = name,
        Flags = ScriptProperty.Flag.Edited
    };

    foreach (var value in values)
    {
        property.Data.Add(value);
    }

    return property;
}

static Message EnsureMessage(
    SkyrimMod mod,
    Dictionary<string, ISkyrimMajorRecordGetter> index,
    FormKeyAllocator allocator,
    RewardsSpecMessage messageDefinition,
    AuthorReport report)
{
    if (string.IsNullOrWhiteSpace(messageDefinition.editorId))
    {
        throw new InvalidOperationException("messageRecords[] entry is missing editorId.");
    }

    if (index.TryGetValue(messageDefinition.editorId!, out var existing))
    {
        if (existing is not Message message)
        {
            throw new InvalidOperationException($"{messageDefinition.editorId} already exists as {existing.GetType().Name}, expected Message.");
        }

        return message;
    }

    var created = new Message(allocator.Next(), SkyrimRelease.SkyrimSE);
    mod.Messages.Add(created);
    index[messageDefinition.editorId!] = created;
    report.Actions.Add($"Created message {messageDefinition.editorId}.");
    return created;
}

static void ConfigureMessage(Message message, RewardsSpecMessage messageDefinition)
{
    var text = messageDefinition.text ?? messageDefinition.body ?? "";
    if (text.Any(ch => ch > 127) || (messageDefinition.title ?? "").Any(ch => ch > 127))
    {
        throw new InvalidOperationException($"{messageDefinition.editorId} message text must be ASCII-safe.");
    }

    var isMessageBox = messageDefinition.messageBox
        || string.Equals(messageDefinition.kind, "messageBox", StringComparison.OrdinalIgnoreCase);

    message.EditorID = messageDefinition.editorId;
    message.FormVersion = 44;
    message.Name = Tx(messageDefinition.title ?? messageDefinition.editorId!);
    message.Description = Tx(text);
    message.Flags = isMessageBox ? Message.Flag.MessageBox : 0;
    message.MenuButtons.Clear();

    var buttons = messageDefinition.buttons ?? new();
    if (buttons.Count == 0 && isMessageBox)
    {
        buttons.Add("Continue");
    }

    foreach (var button in buttons)
    {
        message.MenuButtons.Add(new MessageButton { Text = Tx(button) });
    }
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
    bool preserveAdditionalEffects,
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
    spell.Type = ParseSpellType(effects);
    spell.CastType = ParseCastType(effects);
    spell.TargetType = TargetType.Self;
    spell.ChargeTime = 0.0f;
    spell.CastDuration = 0.0f;
    spell.Range = 0.0f;
    var builtEffectKeys = built
        .Select(item => item.Record.FormKey)
        .ToHashSet();
    var preservedEffects = preserveAdditionalEffects
        ? spell.Effects
            .Where(effect => !effect.BaseEffect.FormKeyNullable.HasValue || !builtEffectKeys.Contains(effect.BaseEffect.FormKeyNullable.Value))
            .ToList()
        : new List<Effect>();
    spell.Effects.Clear();
    foreach (var (effect, record) in built)
    {
        var spellEffect = new Effect
        {
            BaseEffect = record.FormKey.ToNullableLink<IMagicEffectGetter>(),
            Data = new EffectData { Magnitude = effect.magnitude, Area = 0, Duration = effect.duration },
            Conditions = []
        };
        foreach (var condition in BuildEffectConditions(effect, index))
        {
            spellEffect.Conditions.Add(condition);
        }
        spell.Effects.Add(spellEffect);
    }
    foreach (var preservedEffect in preservedEffects)
    {
        spell.Effects.Add(preservedEffect);
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
    // Per-effect name keeps the Active Effects list legible (one distinct line
    // per effect); falls back to the spell display name when not supplied.
    record.Name = Tx(string.IsNullOrWhiteSpace(effect.effectName) ? displayName : effect.effectName!);
    record.Description = Tx(description);
    record.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoHitEffect;
    if (effect.duration <= 0)
    {
        record.Flags |= MagicEffect.Flag.NoDuration;
    }
    record.BaseCost = 0.0f;
    record.MagicSkill = ActorValue.None;
    record.ResistValue = ActorValue.None;
    var actorValue = ParseActorValue(effect.actorValue!);
    if (UsesPeakValueModifier(actorValue))
    {
        record.Flags |= MagicEffect.Flag.Recover | MagicEffect.Flag.PowerAffectsMagnitude;
        record.Archetype = new MagicEffectPeakValueModArchetype
        {
            ActorValue = actorValue
        };
    }
    else
    {
        record.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier)
        {
            ActorValue = actorValue
        };
    }
    record.CastType = ParseEffectCastType(effect);
    record.TargetType = TargetType.Self;
    record.SkillUsageMultiplier = 0.0f;
    record.ScriptEffectAIScore = 0.0f;
    record.ScriptEffectAIDelayTime = 0.0f;
    return record;
}

static bool UsesPeakValueModifier(ActorValue actorValue)
{
    return actorValue == ActorValue.Health
        || actorValue == ActorValue.Magicka
        || actorValue == ActorValue.Stamina
        || actorValue == ActorValue.HealRate
        || actorValue == ActorValue.MagickaRate
        || actorValue == ActorValue.StaminaRate
        || actorValue == ActorValue.HealRateMult
        || actorValue == ActorValue.MagickaRateMult
        || actorValue == ActorValue.StaminaRateMult;
}

static SpellType ParseSpellType(List<RewardsSpecEffect> effects)
{
    foreach (var effect in effects)
    {
        if (!string.IsNullOrWhiteSpace(effect.spellType))
        {
            return ParseEnum<SpellType>(effect.spellType!, "spellType");
        }
    }

    return SpellType.Ability;
}

static CastType ParseCastType(List<RewardsSpecEffect> effects)
{
    foreach (var effect in effects)
    {
        if (!string.IsNullOrWhiteSpace(effect.castType))
        {
            return ParseEnum<CastType>(effect.castType!, "castType");
        }
    }

    return CastType.ConstantEffect;
}

static CastType ParseEffectCastType(RewardsSpecEffect effect)
{
    if (!string.IsNullOrWhiteSpace(effect.castType))
    {
        return ParseEnum<CastType>(effect.castType!, "castType");
    }

    return CastType.ConstantEffect;
}

static TEnum ParseEnum<TEnum>(string value, string fieldName) where TEnum : struct
{
    if (Enum.TryParse<TEnum>(value.Trim(), ignoreCase: true, out var parsed))
    {
        return parsed;
    }

    throw new InvalidOperationException($"Unsupported {fieldName} value '{value}'.");
}

// Single source of truth for an effect's runtime conditions, consumed by BOTH the
// author (BuildSpell) and the --check-rewards verify (via CountEffectConditions) so a
// specced contextual gate can never silently no-op the way nearWaterOnly did before it
// was a recognized field. nightOnly / nearWaterOnly are SUGAR that expand to canonical
// conditions; the generic conditions[] array covers any future gate as data.
static List<Condition> BuildEffectConditions(RewardsSpecEffect effect, Dictionary<string, ISkyrimMajorRecordGetter> index)
{
    var conditions = new List<Condition>();
    if (effect.nightOnly)
    {
        // Khajiit baseline, byte-for-byte: GetCurrentTime >= 19 OR <= 7.
        conditions.Add(new ConditionFloat
        {
            Data = new GetCurrentTimeConditionData(),
            CompareOperator = CompareOperator.GreaterThanOrEqualTo,
            ComparisonValue = 19.0f,
            Flags = Condition.Flag.OR
        });
        conditions.Add(new ConditionFloat
        {
            Data = new GetCurrentTimeConditionData(),
            CompareOperator = CompareOperator.LessThanOrEqualTo,
            ComparisonValue = 7.0f
        });
    }
    if (effect.nearWaterOnly)
    {
        conditions.Add(NearWaterCondition(index));
    }
    foreach (var spec in effect.conditions ?? new())
    {
        conditions.Add(BuildGenericCondition(spec, index));
    }
    return conditions;
}

// Condition count without resolving FormKeys, so the verify never throws on a missing
// FormList while checking that a specced gate actually authored conditions. Must mirror
// BuildEffectConditions' shape (night = 2, nearWater = 1, each generic = 1).
static int CountEffectConditions(RewardsSpecEffect effect)
{
    var count = 0;
    if (effect.nightOnly) count += 2;
    if (effect.nearWaterOnly) count += 1;
    count += effect.conditions?.Count ?? 0;
    return count;
}

// Near-water = the player's current location (GetInCurrentLocFormList walks the location
// parent chain, so a hold-level entry covers everywhere in it) is in the generous
// water-context FormList. There is NO IsInWater CONDITION function in Skyrim (only the
// Papyrus method), so location membership is the mechanism; breadth lives in the list.
static Condition NearWaterCondition(Dictionary<string, ISkyrimMajorRecordGetter> index)
{
    var data = new GetInCurrentLocFormListConditionData();
    data.FormList.Link.SetTo(ResolveConditionFormList(index, "PDV_FLST_WaterContextLocations"));
    return new ConditionFloat
    {
        Data = data,
        CompareOperator = CompareOperator.EqualTo,
        ComparisonValue = 1.0f
    };
}

static Condition BuildGenericCondition(RewardsSpecCondition spec, Dictionary<string, ISkyrimMajorRecordGetter> index)
{
    var op = string.IsNullOrWhiteSpace(spec.compareOperator)
        ? CompareOperator.EqualTo
        : ParseEnum<CompareOperator>(spec.compareOperator!, "compareOperator");
    ConditionData data;
    switch ((spec.function ?? "").Trim())
    {
        case "GetCurrentTime":
            data = new GetCurrentTimeConditionData();
            break;
        case "GetInCurrentLocFormList":
            var locData = new GetInCurrentLocFormListConditionData();
            locData.FormList.Link.SetTo(ResolveConditionFormList(index, spec.formList!));
            data = locData;
            break;
        case "GetInWorldspace":
            data = new GetInWorldspaceConditionData();
            break;
        default:
            throw new InvalidOperationException($"Unsupported condition function '{spec.function}'. Add it to BuildGenericCondition's dispatch table.");
    }
    return new ConditionFloat
    {
        Data = data,
        CompareOperator = op,
        ComparisonValue = spec.comparisonValue,
        Flags = spec.or ? Condition.Flag.OR : default
    };
}

static FormKey ResolveConditionFormList(Dictionary<string, ISkyrimMajorRecordGetter> index, string editorId)
{
    if (string.IsNullOrWhiteSpace(editorId))
    {
        throw new InvalidOperationException("A GetInCurrentLocFormList condition is missing its formList editorId.");
    }
    if (!index.TryGetValue(editorId, out var rec) || rec is not IFormListGetter)
    {
        throw new InvalidOperationException($"Location condition needs FormList '{editorId}' but it is missing from the ESP. Author the FormList first.");
    }
    return rec.FormKey;
}

// Creates/refreshes the near-water context FormList from the spec's nearWaterContext block.
// Membership is rebuilt each run (idempotent) from the listed location FormIDs ('XXXXXX:Plugin.esp').
// GetInCurrentLocFormList walks the location parent chain, so hold-level entries blanket their holds.
static void EnsureNearWaterFormList(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator allocator, RewardsSpec spec, AuthorReport report)
{
    if (spec.nearWaterContext is not { } ctx || string.IsNullOrWhiteSpace(ctx.formListEditorId))
    {
        return;
    }

    FormList formList;
    if (index.TryGetValue(ctx.formListEditorId!, out var existing))
    {
        formList = existing as FormList ?? throw new InvalidOperationException($"{ctx.formListEditorId} already exists as {existing.GetType().Name}, expected FormList.");
    }
    else
    {
        formList = new FormList(allocator.Next(), SkyrimRelease.SkyrimSE) { EditorID = ctx.formListEditorId };
        mod.FormLists.Add(formList);
        index[ctx.formListEditorId!] = formList;
        report.Actions.Add($"Created FormList {ctx.formListEditorId}.");
    }

    formList.Items.Clear();
    foreach (var location in ctx.locations ?? new())
    {
        formList.Items.Add(FormKey.Factory(location).ToLink<ISkyrimMajorRecordGetter>());
    }
    report.Actions.Add($"Wired {formList.Items.Count} location(s) into {ctx.formListEditorId}.");
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
    var normalized = actorValue.Trim();
    if (Enum.TryParse<ActorValue>(normalized, ignoreCase: true, out var parsed))
    {
        return parsed;
    }

    var aliases = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
    {
        ["Speechcraft"] = new[] { "Speech" },
        ["BlockSkill"] = new[] { "Block" },
        ["CriticalChance"] = new[] { "CritChance", "CriticalChance" },
        ["Marksman"] = new[] { "Archery", "Marksman" },
        ["ResistPoison"] = new[] { "PoisonResist", "ResistPoison" }
    };

    if (aliases.TryGetValue(normalized, out var candidates))
    {
        foreach (var candidate in candidates)
        {
            if (Enum.TryParse<ActorValue>(candidate, ignoreCase: true, out parsed))
            {
                return parsed;
            }
        }
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
    public RewardsSpecNearWaterContext? nearWaterContext { get; set; }
    public RewardsSpecReward? neglect { get; set; }
    public List<RewardsSpecReward>? emphasisRewards { get; set; }
    public RewardsSpecBroadState? broadState { get; set; }
    public List<RewardsSpecReward>? supportSpells { get; set; }
    public RewardsSpecReward? farShoresToken { get; set; }
    public List<RewardsSpecMessage>? messageRecords { get; set; }
    public List<RewardsSpecStateRecord>? stateRecordAuthoring { get; set; }
    public List<RewardsSpecReputationRecord>? reputationRecordAuthoring { get; set; }
    public List<RewardsSpecDeityTrackModifier>? deityTrackModifiers { get; set; }
    // Shape varies by race: Breton uses an ARRAY of spell-record specs;
    // Altmer uses an OBJECT of signal-penalty routes (no records). Kept as a
    // raw element and only the array (spell-record) shape is authored.
    public JsonElement creedViolationLoss { get; set; }

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

sealed class RewardsSpecNearWaterContext
{
    public string? formListEditorId { get; set; }
    public List<string>? locations { get; set; }
}

sealed class RewardsSpecSlot
{
    public string? slotProperty { get; set; }
    public string? spellEditorId { get; set; }
    public string? displayName { get; set; }
    public List<RewardsSpecEffect>? effects { get; set; }
    public string? playerFacingText { get; set; }
}

sealed class RewardsSpecBroadState
{
    public string? lane { get; set; }
    public List<RewardsSpecReward>? rewards { get; set; }
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
    public bool preserveAdditionalEffects { get; set; }
}

// Fail-closed: an unknown key at the effect level THROWS at author time instead of being
// silently dropped. This closes the bug class that hid nearWaterOnly (a real gate that
// deserialized to nothing, deployed an always-on reward, and passed the verifier blind ->
// the Argonian +80 over-stack). Scoped to RewardsSpecEffect only (NOT global) so the
// doc-metadata keys on the other spec types are unaffected.
[System.Text.Json.Serialization.JsonUnmappedMemberHandling(System.Text.Json.Serialization.JsonUnmappedMemberHandling.Disallow)]
sealed class RewardsSpecEffect
{
    public string? magicEffectEditorId { get; set; }
    public string? actorValue { get; set; }
    public float magnitude { get; set; }
    public int duration { get; set; }
    public string? spellType { get; set; }
    public string? castType { get; set; }
    public bool nightOnly { get; set; }
    public bool nearWaterOnly { get; set; }
    public List<RewardsSpecCondition>? conditions { get; set; }
    public string? effectName { get; set; }
    // Recognized-but-unused doc annotations: the real gating for these is scripted in the
    // manager (curse/posture, flat scripted restore), not an MGEF condition. Modeled so the
    // Disallow guard above passes every current spec; the author never reads them.
    public string? appliesAtPosture { get; set; }
    public string? delivery { get; set; }
    public bool existing { get; set; }
    public bool homeOrShrineOnly { get; set; }
}

sealed class RewardsSpecCondition
{
    public string? function { get; set; }
    public string? formList { get; set; }
    public string? compareOperator { get; set; }
    public float comparisonValue { get; set; }
    public bool or { get; set; }
}

sealed class RewardsSpecMessage
{
    public string? editorId { get; set; }
    public string? property { get; set; }
    public string? kind { get; set; }
    public string? title { get; set; }
    public string? text { get; set; }
    public string? body { get; set; }
    public bool messageBox { get; set; }
    public List<string>? buttons { get; set; }
}

sealed class RewardsSpecStateRecord
{
    public string? editorId { get; set; }
    public string? trackName { get; set; }
    public string? globalEditorId { get; set; }
    public float? initialValue { get; set; }
    public List<string>? labels { get; set; }
    public string? managerGlobalProperty { get; set; }
    public string? managerTrackProperty { get; set; }
    public List<string>? addToFormLists { get; set; }
}

sealed class RewardsSpecReputationRecord
{
    public string? editorId { get; set; }
    public string? trackName { get; set; }
    public string? globalEditorId { get; set; }
    public float? initialValue { get; set; }
    public List<int>? thresholdValues { get; set; }
    public List<string>? thresholdLabels { get; set; }
    public string? managerGlobalProperty { get; set; }
    public string? managerTrackProperty { get; set; }
    public List<string>? addToFormLists { get; set; }
}

sealed class RewardsSpecDeityTrackModifier
{
    public string? deityEditorId { get; set; }
    public string? script { get; set; }
    public string? gainTrack { get; set; }
    public List<float>? gainMultipliers { get; set; }
    public string? decayTrack { get; set; }
    public List<float>? decayMultipliers { get; set; }
}
