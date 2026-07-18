// pdv-fix-receiver-anam-mutagen — fix for issue #17 (Craft Item / cooking CTD).
//
// The generic-faucet Story Manager receiver quests were authored without the QUST
// `ANAM` (Next Alias ID) subrecord that the Creation Kit writes for every quest.
// The malformed record makes the engine read uninitialised alias bookkeeping when
// the Story Manager starts the quest to deliver an event, dereferencing an invalid
// handle (RAX=RDX=0xFFFFFFFF) while marshalling the event args -> CTD on cooking /
// tempering (the Craft Item event).
//
// Mutagen always serialises Quest.NextAliasID as `ANAM`, so setting it explicitly
// (and re-writing the plugin) restores the field. Idempotent.
//
// Usage:
//   dotnet run --project tools/pdv-fix-receiver-anam-mutagen -- "<path-to-Devotion.esp>" ["<out-path>"]
//
// With no out-path it writes "<input>.patched.esp". Back up your plugin first.
// Prefer the pure-Node patcher (tools/pdv_fix_receiver_anam.mjs) if you don't have
// the .NET SDK — it is surgical (adds only the 7 subrecords) whereas this fully
// re-serialises the plugin through Mutagen.

using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Skyrim;

var targets = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
{
    "PDV__SM_CraftItem",
    "PDV__SM_NewVoicePower",
    "PDV__SM_IncreaseSkill",
    "PDV__SM_ChangeLocation",
    "PDV__SM_PickLock",
    "PDV__SM_Trespass",
    "PDV__SM_AssaultActor",
    "PDV__SM_AddToPlayer",
};

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: dotnet run --project tools/pdv-fix-receiver-anam-mutagen -- <Devotion.esp> [<out.esp>]");
    return 1;
}

var inPath = args[0];
var outPath = args.Length >= 2
    ? args[1]
    : System.IO.Path.Combine(
        System.IO.Path.GetDirectoryName(inPath) ?? ".",
        System.IO.Path.GetFileNameWithoutExtension(inPath) + ".patched.esp");

// SkyrimSE (1.5.97). Use SkyrimSE for both LE-derived and SE plugins on this runtime.
var mod = SkyrimMod.CreateFromBinaryOverlay(
    ModPath.FromPath(inPath), SkyrimRelease.SkyrimSE).DeepCopy();

var patched = new List<string>();
foreach (var quest in mod.Quests)
{
    var edid = quest.EditorID;
    if (edid is null || !targets.Contains(edid)) continue;

    // Mutagen always emits ANAM; set NextAliasID explicitly so intent is clear and
    // the record is well-formed like the working PDV__SM_KillActor receiver.
    quest.NextAliasID = 0;
    patched.Add(edid);
}

if (patched.Count == 0)
{
    Console.Error.WriteLine("No target receiver quests found — wrong plugin?");
    return 2;
}

mod.WriteToBinary(outPath);
Console.WriteLine($"Set NextAliasID=0 (ANAM) on: {string.Join(", ", patched)}");
Console.WriteLine($"Wrote {outPath}");
Console.WriteLine("Verify in xEdit/SSEEdit that ANAM is present, then test in-game (cook a grilled leek, temper an item).");
return 0;
