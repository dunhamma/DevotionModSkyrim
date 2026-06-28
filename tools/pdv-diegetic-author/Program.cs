using System.Text.Json;
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;
using Mutagen.Bethesda.Strings;
using Noggog;

const string defaultEsp = @"D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp";
const string skyrimEsmPath = @"D:\Wabbajack\modlists\Anvil\Stock Game\Data\Skyrim.esm";

var dryRun = args.Contains("--dry-run");
var checkOnly = args.Contains("--check");
var espPath = Path.GetFullPath(defaultEsp);

var actions = new List<string>();
var errors = new List<string>();
string? backupPath = null;
var status = "PASS";

// --- record contract (vanilla source local id -> new EditorID) ---
var dupSpecs = new (uint id, string eid, string type)[]
{
    (0x084B38, "PDV_IMAD_Reverent", "IMAD"),
    (0x064D69, "PDV_IMAD_Revelation", "IMAD"),
    (0x10C445, "PDV_IMAD_Dread", "IMAD"),
    (0x084B38, "PDV_IMAD_Release", "IMAD"),
    (0x10C445, "PDV_IMAD_Absence", "IMAD"),
    (0x01702E, "PDV_SND_Chime", "SOUN"),  // MAGAltarsBlessingFireC2D (2D blessing flourish); retargeted 2026-06-23 from the inaudible 3D MAGRestorationChargeSD (056622) so the tier-up cue is heard. Existing esps keep the SOUN FormKey; use --retarget-chime to repoint in place.
    (0x01702C, "PDV_SND_Swell", "SOUN"),
    (0x057C63, "PDV_SND_Hollow", "SOUN"),
    (0x057C65, "PDV_SND_RisingChime", "SOUN"),
    (0x03F363, "PDV_SND_Distant", "SOUN"),
    (0x02D4C2, "PDV_MUS_CurseBed", "MUSC"),
};
var shaderSpecs = new (string spellEid, string mgefEid, string name, uint efsh)[]
{
    ("PDV_Abil_Shader_Reverent", "PDV_MGEF_Shader_Reverent", "Reverent", 0x04E220),
    ("PDV_Abil_Shader_Revelation", "PDV_MGEF_Shader_Revelation", "Revelation", 0x10CDC9),
    ("PDV_Abil_Shader_Dread", "PDV_MGEF_Shader_Dread", "Dread", 0x0ABEFF),
    ("PDV_Abil_Shader_Release", "PDV_MGEF_Shader_Release", "Release", 0x0E7557),
};
var recordProps = new List<string>();
foreach (var d in dupSpecs) recordProps.Add(d.eid);
foreach (var s in shaderSpecs) recordProps.Add(s.spellEid);
recordProps.Add("PDV_DevotionMedallion");
recordProps.Add("PDV_BookOfDays");

try
{
    if (!File.Exists(espPath)) throw new FileNotFoundException("Framework ESP not found.", espPath);

    var mod = SkyrimMod.CreateFromBinary(espPath, SkyrimRelease.SkyrimSE);
    var index = new Dictionary<string, ISkyrimMajorRecordGetter>(StringComparer.OrdinalIgnoreCase);
    foreach (var rec in mod.EnumerateMajorRecords().OfType<ISkyrimMajorRecordGetter>())
    {
        if (!string.IsNullOrEmpty(rec.EditorID)) index[rec.EditorID!] = rec;
    }

    // --- surgical in-place repoint of the tier-up cue ---
    // Repoints the existing PDV_SND_Chime SoundMarker's descriptor to a louder, 2D blessing
    // flourish (MAGAltarsBlessingFireC2D, 01702E:Skyrim.esm) so the milestone is actually audible
    // (the old MAGRestorationChargeSD is a soft 3D spell-charge hum). PRESERVES the SoundMarker
    // FormKey -- we mutate the existing record, never re-create it, so the DiegeticDirector VMAD
    // binding stays intact (re-creating re-allocates a FormKey and orphans the binding, which is
    // the original D1 silence bug). Skyrim.esm is already a master, so no new dependency.
    if (args.Contains("--retarget-chime"))
    {
        var soun = mod.SoundMarkers.FirstOrDefault(s => string.Equals(s.EditorID, "PDV_SND_Chime", StringComparison.OrdinalIgnoreCase));
        if (soun is null) { errors.Add("PDV_SND_Chime SoundMarker not found"); status = "FAIL"; Report(); Environment.Exit(1); return; }
        var oldDescr = soun.SoundDescriptor.FormKeyNullable?.ToString() ?? "<null>";
        soun.SoundDescriptor.SetTo(FormKey.Factory("01702E:Skyrim.esm"));
        actions.Add($"retarget PDV_SND_Chime ({soun.FormKey}) descriptor {oldDescr} -> 01702E:Skyrim.esm (MAGAltarsBlessingFireC2D, 2D blessing flourish)");
        if (!dryRun)
        {
            var backupDir = Path.Combine(Path.GetDirectoryName(espPath)!, "Backups", "diegetic");
            Directory.CreateDirectory(backupDir);
            var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
            backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
            File.Copy(espPath, backupPath, overwrite: false);
            var tempPath = espPath + ".diegetic.tmp";
            using (var stream = File.Create(tempPath)) { mod.WriteToBinary(stream); }
            File.Copy(tempPath, espPath, overwrite: true);
            File.Delete(tempPath);
            actions.Add("wrote " + espPath);
        }
        else { actions.Add("dry-run: no write"); }
        Report();
        return;
    }

    var checkList = new List<string>(recordProps) { "PDV_DiegeticDeps", "PDV_DiegeticDirector" };

    if (checkOnly)
    {
        foreach (var eid in checkList)
        {
            if (index.ContainsKey(eid)) actions.Add("OK " + eid);
            else { errors.Add("MISSING " + eid); status = "FAIL"; }
        }
        foreach (var s in shaderSpecs)
        {
            if (!index.TryGetValue(s.mgefEid, out var mgefRecord) || mgefRecord is not IMagicEffectGetter mgef)
            {
                errors.Add($"MISSING or wrong-type {s.mgefEid}");
                status = "FAIL";
                continue;
            }
            if (!mgef.Flags.HasFlag(MagicEffect.Flag.HideInUI))
            {
                errors.Add($"{s.mgefEid}: missing HideInUI");
                status = "FAIL";
            }
            else actions.Add($"OK {s.mgefEid} HideInUI");

            if (!mgef.Flags.HasFlag(MagicEffect.Flag.NoArea) || !mgef.Flags.HasFlag(MagicEffect.Flag.NoDuration))
            {
                errors.Add($"{s.mgefEid}: missing NoArea/NoDuration helper flags");
                status = "FAIL";
            }

            if (!index.TryGetValue(s.spellEid, out var spellRecord) || spellRecord is not ISpellGetter spell)
            {
                errors.Add($"MISSING or wrong-type {s.spellEid}");
                status = "FAIL";
                continue;
            }
            var effect = spell.Effects.FirstOrDefault();
            if (!effect?.BaseEffect.FormKeyNullable?.Equals(mgef.FormKey) ?? true)
            {
                errors.Add($"{s.spellEid}: first effect does not point to {s.mgefEid}");
                status = "FAIL";
            }
            else actions.Add($"OK {s.spellEid} -> {s.mgefEid}");
        }
        // manager service property
        if (index.TryGetValue("PDV__ManagerQuest", out var mgrGet) && mgrGet is IQuestGetter mq
            && mq.VirtualMachineAdapter?.Scripts.Any(s => s.Properties.Any(p => p.Name == "PDV_DiegeticDirectorService")) == true)
            actions.Add("OK manager PDV_DiegeticDirectorService property");
        else { errors.Add("MISSING manager PDV_DiegeticDirectorService property"); status = "FAIL"; }
        Report();
        return;
    }

    if (args.Contains("--dump-daedric"))
    {
        var q = mod.Quests.FirstOrDefault(x => x.EditorID == "PDV_DaedricPath_Boethiah");
        if (q?.VirtualMachineAdapter != null)
        {
            foreach (var sc in q.VirtualMachineAdapter.Scripts)
            {
                var dn = sc.Properties.FirstOrDefault(p => p.Name == "DeityName") as ScriptStringProperty;
                actions.Add($"script={sc.Name} props={sc.Properties.Count} DeityName={(dn == null ? "<absent>" : ("'" + dn.Data + "'"))}");
            }
        }
        else actions.Add("PDV_DaedricPath_Boethiah quest or VMAD not found");
        Report();
        return;
    }

    if (args.Contains("--dump-sound"))
    {
        string[] soundEids = { "PDV_SND_Chime", "PDV_SND_Swell", "PDV_SND_Hollow", "PDV_SND_RisingChime", "PDV_SND_Distant" };
        foreach (var eid in soundEids)
        {
            if (!index.TryGetValue(eid, out var rec)) { actions.Add($"{eid}: MISSING"); continue; }
            string kind = rec switch
            {
                ISoundMarkerGetter => "SOUN(SoundMarker)",
                ISoundDescriptorGetter => "SNDR(SoundDescriptor)",
                _ => rec.GetType().Name
            };
            string descr = "";
            if (rec is ISoundMarkerGetter sm)
                descr = " -> descriptor " + (sm.SoundDescriptor.FormKeyNullable?.ToString() ?? "<null>");
            actions.Add($"{eid}: {rec.FormKey} {kind}{descr}");
        }
        if (index.TryGetValue("PDV_DiegeticDirector", out var dq) && dq is IQuestGetter dirq)
        {
            var sc = dirq.VirtualMachineAdapter?.Scripts.FirstOrDefault(s => string.Equals(s.Name, "PDV_DiegeticDirector", StringComparison.OrdinalIgnoreCase));
            if (sc != null)
            {
                foreach (var pn in new[] { "D1Enabled", "TraceDispatch" })
                {
                    var bp = sc.Properties.FirstOrDefault(p => p.Name == pn) as IScriptBoolPropertyGetter;
                    actions.Add($"director.{pn} = {(bp == null ? "<absent>" : bp.Data.ToString())}");
                }
                foreach (var eid in soundEids)
                {
                    var op = sc.Properties.FirstOrDefault(p => p.Name == eid) as IScriptObjectPropertyGetter;
                    actions.Add($"director.{eid} prop -> {(op == null ? "<absent>" : op.Object.FormKey.ToString())}");
                }
            }
            else actions.Add("director VMAD script PDV_DiegeticDirector not found");
        }
        else actions.Add("PDV_DiegeticDirector quest not found");
        Report();
        return;
    }

    var allocator = new FormKeyAllocator(mod, mod.EnumerateMajorRecords().OfType<IMajorRecordGetter>().Select(r => r.FormKey));
    var src = SkyrimMod.CreateFromBinary(skyrimEsmPath, SkyrimRelease.SkyrimSE);
    var skyrimKey = ModKey.FromNameAndExtension("Skyrim.esm");

    // --- duplications ---
    foreach (var d in dupSpecs)
    {
        if (index.TryGetValue(d.eid, out var existingDup))
        {
            if (d.type == "SOUN" && existingDup is ISoundDescriptorGetter)
            {
                // earlier build created this as a SoundDescriptor (wrong Papyrus type) -- drop it and re-create as a SoundMarker
                mod.SoundDescriptors.Remove(existingDup.FormKey);
                index.Remove(d.eid);
                actions.Add("removed wrong-type SNDR " + d.eid);
            }
            else { actions.Add("exists " + d.eid); continue; }
        }
        var fk = new FormKey(skyrimKey, d.id);
        switch (d.type)
        {
            case "IMAD":
            {
                var s = src.ImageSpaceAdapters.FirstOrDefault(r => r.FormKey == fk) ?? throw new Exception($"source IMAD {d.id:X6} not found");
                var dup = new ImageSpaceAdapter(allocator.Next(), SkyrimRelease.SkyrimSE);
                dup.DeepCopyIn(s); dup.EditorID = d.eid; mod.ImageSpaceAdapters.Add(dup); index[d.eid] = dup;
                break;
            }
            case "SOUN":
            {
                // confirm the vanilla descriptor exists, then wrap it in a SoundMarker (SOUN) so the Papyrus Sound property binds
                _ = src.SoundDescriptors.FirstOrDefault(r => r.FormKey == fk) ?? throw new Exception($"source SNDR {d.id:X6} not found");
                var soun = new SoundMarker(allocator.Next(), SkyrimRelease.SkyrimSE)
                {
                    EditorID = d.eid,
                    SoundDescriptor = fk.ToNullableLink<ISoundDescriptorGetter>()
                };
                mod.SoundMarkers.Add(soun); index[d.eid] = soun;
                break;
            }
            case "MUSC":
            {
                var s = src.MusicTypes.FirstOrDefault(r => r.FormKey == fk) ?? throw new Exception($"source MUSC {d.id:X6} not found");
                var dup = new MusicType(allocator.Next(), SkyrimRelease.SkyrimSE);
                dup.DeepCopyIn(s); dup.EditorID = d.eid; mod.MusicTypes.Add(dup); index[d.eid] = dup;
                break;
            }
        }
        actions.Add($"created {d.eid} (dup {d.id:X6})");
    }

    // --- MISC + BOOK placeholders (Description / Dynamic Book Framework soft-dep targets) ---
    if (!index.ContainsKey("PDV_DevotionMedallion"))
    {
        var misc = new MiscItem(allocator.Next(), SkyrimRelease.SkyrimSE) { EditorID = "PDV_DevotionMedallion", Name = Tx("Devotion Medallion"), Value = 0, Weight = 0f };
        mod.MiscItems.Add(misc); index["PDV_DevotionMedallion"] = misc; actions.Add("created PDV_DevotionMedallion");
    }
    if (!index.ContainsKey("PDV_BookOfDays"))
    {
        var book = new Book(allocator.Next(), SkyrimRelease.SkyrimSE) { EditorID = "PDV_BookOfDays", Name = Tx("Book of Days"), BookText = Tx("The pages keep the record of devotion.") };
        mod.Books.Add(book); index["PDV_BookOfDays"] = book; actions.Add("created PDV_BookOfDays");
    }

    // --- shader SPEL + MGEF (EFSH aura, added as ability by the director) ---
    foreach (var s in shaderSpecs)
    {
        MagicEffect mgef;
        if (index.TryGetValue(s.mgefEid, out var existingMgef))
        {
            if (existingMgef is not MagicEffect writableMgef)
                throw new Exception($"{s.mgefEid} exists as {existingMgef.GetType().Name}, expected MagicEffect.");
            mgef = writableMgef;
            actions.Add("exists " + s.mgefEid);
        }
        else
        {
            mgef = new MagicEffect(allocator.Next(), SkyrimRelease.SkyrimSE) { EditorID = s.mgefEid };
            mod.MagicEffects.Add(mgef);
            index[s.mgefEid] = mgef;
            actions.Add("created " + s.mgefEid);
        }
        ConfigureShaderMagicEffect(mgef, s.name, s.efsh, skyrimKey);

        Spell spell;
        if (index.TryGetValue(s.spellEid, out var existingSpell))
        {
            if (existingSpell is not Spell writableSpell)
                throw new Exception($"{s.spellEid} exists as {existingSpell.GetType().Name}, expected Spell.");
            spell = writableSpell;
            actions.Add("exists " + s.spellEid);
        }
        else
        {
            spell = new Spell(allocator.Next(), SkyrimRelease.SkyrimSE) { EditorID = s.spellEid };
            mod.Spells.Add(spell);
            index[s.spellEid] = spell;
            actions.Add("created " + s.spellEid);
        }
        ConfigureShaderSpell(spell, s.name, mgef.FormKey);
        actions.Add($"configured hidden shader carrier {s.spellEid} + {s.mgefEid}");
    }

    // --- 2 SGE quests + VMAD ---
    var depsQuest = EnsureQuest(mod, index, allocator, "PDV_DiegeticDeps", actions);
    WireQuestScript(depsQuest, "PDV_DiegeticDeps", new List<ScriptProperty> { BoolProp("ForceAllDepsAbsent", false) });

    var dirQuest = EnsureQuest(mod, index, allocator, "PDV_DiegeticDirector", actions);
    var dirProps = new List<ScriptProperty>
    {
        ObjProp("PDV_DiegeticDepsService", index["PDV_DiegeticDeps"].FormKey),
        ObjProp("PDV_GLO_ActivePiety", index["PDV_GLO_ActivePiety"].FormKey),
        ObjProp("PDV_GLO_ActiveTier", index["PDV_GLO_ActiveTier"].FormKey),
        ObjProp("PDV_GLO_ActiveDeityIndex", index["PDV_GLO_ActiveDeityIndex"].FormKey),
        ObjProp("PDV_GLO_OriginRace", index["PDV_GLO_OriginRace"].FormKey),
        ObjProp("PDV_FLST_AllDeities", index["PDV_FLST_AllDeities"].FormKey),
        BoolProp("D1Enabled", true),
        BoolProp("TraceDispatch", true),
    };
    foreach (var eid in recordProps) dirProps.Add(ObjProp(eid, index[eid].FormKey));
    WireQuestScript(dirQuest, "PDV_DiegeticDirector", dirProps);

    // --- manager service property ---
    if (index["PDV__ManagerQuest"] is not Quest managerQuest)
        throw new Exception("PDV__ManagerQuest not found as a writable Quest.");
    WireQuestScript(managerQuest, "PDV__ManagerQuest", new List<ScriptProperty> { ObjProp("PDV_DiegeticDirectorService", dirQuest.FormKey) });
    actions.Add("wired manager PDV_DiegeticDirectorService -> PDV_DiegeticDirector");

    // --- write ---
    if (!dryRun)
    {
        var backupDir = Path.Combine(Path.GetDirectoryName(espPath)!, "Backups", "diegetic");
        Directory.CreateDirectory(backupDir);
        var stamp = DateTimeOffset.Now.ToString("yyyyMMdd-HHmmss");
        backupPath = Path.Combine(backupDir, $"Devotion.esp.{stamp}.bak");
        File.Copy(espPath, backupPath, overwrite: false);
        var tempPath = espPath + ".diegetic.tmp";
        using (var stream = File.Create(tempPath)) { mod.WriteToBinary(stream); }
        File.Copy(tempPath, espPath, overwrite: true);
        File.Delete(tempPath);
        actions.Add("wrote " + espPath);
    }
    else
    {
        actions.Add("dry-run: no write");
    }

    Report();
}
catch (Exception ex)
{
    status = "FAIL";
    errors.Add(ex.GetType().Name + ": " + ex.Message);
    Report();
    Environment.Exit(1);
}

void Report()
{
    Console.WriteLine(JsonSerializer.Serialize(new { status, dryRun, checkOnly, backupPath, actions, errors }, new JsonSerializerOptions { WriteIndented = true }));
}

static TranslatedString Tx(string value) => new(Language.English, value);

static void ConfigureShaderMagicEffect(MagicEffect mgef, string toneName, uint efshLocalId, ModKey skyrimKey)
{
    mgef.Name = Tx($"Devotion {toneName} Aura");
    mgef.Flags = MagicEffect.Flag.NoArea | MagicEffect.Flag.NoDuration | MagicEffect.Flag.HideInUI;
    mgef.BaseCost = 0f;
    mgef.MagicSkill = ActorValue.None;
    mgef.ResistValue = ActorValue.None;
    mgef.Archetype = new MagicEffectArchetype(MagicEffectArchetype.TypeEnum.ValueModifier) { ActorValue = ActorValue.None };
    mgef.CastType = CastType.ConstantEffect;
    mgef.TargetType = TargetType.Self;
    mgef.HitShader = new FormKey(skyrimKey, efshLocalId).ToNullableLink<IEffectShaderGetter>();
}

static void ConfigureShaderSpell(Spell spell, string toneName, FormKey mgefKey)
{
    spell.Name = Tx($"Devotion {toneName}");
    spell.BaseCost = 0;
    spell.Type = SpellType.Ability;
    spell.CastType = CastType.ConstantEffect;
    spell.TargetType = TargetType.Self;
    spell.Effects.Clear();
    spell.Effects.Add(new Effect { BaseEffect = mgefKey.ToNullableLink<IMagicEffectGetter>(), Data = new EffectData { Magnitude = 0f, Area = 0, Duration = 0 }, Conditions = [] });
}

static ScriptObjectProperty ObjProp(string name, FormKey fk) => new()
{
    Name = name,
    Flags = ScriptProperty.Flag.Edited,
    Object = fk.ToLink<ISkyrimMajorRecordGetter>(),
    Alias = -1
};

static ScriptBoolProperty BoolProp(string name, bool value) => new()
{
    Name = name,
    Flags = ScriptProperty.Flag.Edited,
    Data = value
};

static Quest EnsureQuest(SkyrimMod mod, Dictionary<string, ISkyrimMajorRecordGetter> index, FormKeyAllocator alloc, string eid, List<string> actions)
{
    if (index.TryGetValue(eid, out var ex) && ex is Quest existing) { actions.Add("quest exists " + eid); return existing; }
    var created = new Quest(alloc.Next(), SkyrimRelease.SkyrimSE)
    {
        EditorID = eid,
        FormVersion = 44,
        Name = Tx(eid),
        Flags = Quest.Flag.StartGameEnabled,
        Priority = 50,
        Type = Quest.TypeEnum.None,
    };
    mod.Quests.Add(created);
    index[eid] = created;
    actions.Add("created SGE quest " + eid);
    return created;
}

static void WireQuestScript(Quest quest, string scriptName, List<ScriptProperty> props)
{
    quest.VirtualMachineAdapter ??= new QuestAdapter();
    var script = quest.VirtualMachineAdapter.Scripts.FirstOrDefault(s => string.Equals(s.Name, scriptName, StringComparison.OrdinalIgnoreCase));
    if (script == null)
    {
        script = new ScriptEntry { Name = scriptName, Flags = ScriptEntry.Flag.Local };
        quest.VirtualMachineAdapter.Scripts.Add(script);
    }
    foreach (var p in props)
    {
        while (script.Properties.FirstOrDefault(x => string.Equals(x.Name, p.Name, StringComparison.OrdinalIgnoreCase)) is { } e)
            script.Properties.Remove(e);
        script.Properties.Add(p);
    }
}

sealed class FormKeyAllocator
{
    private readonly ModKey modKey;
    private readonly HashSet<uint> usedIds;
    private uint nextId;

    public FormKeyAllocator(SkyrimMod mod, IEnumerable<FormKey> existingKeys)
    {
        modKey = mod.ModKey;
        usedIds = existingKeys.Where(k => k.ModKey.Equals(modKey)).Select(k => Convert.ToUInt32(k.IDString(), 16)).ToHashSet();
        nextId = usedIds.Count == 0 ? 0x800u : Math.Max(0x800u, usedIds.Max() + 1);
    }

    public FormKey Next()
    {
        while (usedIds.Contains(nextId)) nextId++;
        var id = nextId++;
        usedIds.Add(id);
        return new FormKey(modKey, id);
    }
}
