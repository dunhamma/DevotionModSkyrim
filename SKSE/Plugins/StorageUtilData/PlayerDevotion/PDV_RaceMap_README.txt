Devotion custom race support
============================

This article is for modlist maintainers and custom race authors who want a
custom playable race to use Devotion's race-based worship system.

Short version
-------------

Devotion does not add new custom-race theology in V1. A custom race chooses one
of Devotion's ten existing race profiles:

  0 Nord
  1 Imperial
  2 Breton
  3 Altmer
  4 Bosmer
  5 Dunmer
  6 Khajiit
  7 Argonian
  8 Orc
  9 Redguard

Normal playable races and their vampire forms can map to one of those profiles.
Temporary beast forms, such as werewolf or Vampire Lord races, should not map to
a permanent profile. Put those in the temporary-race file so Devotion waits
until the player reverts before capturing origin.

Files used by Devotion
----------------------

These files live in:

  SKSE\Plugins\StorageUtilData\PlayerDevotion\

PDV_RaceMap.json
  Maps normal playable custom races to one of the ten race profiles.

PDV_TemporaryRaceMap.json
  Lists temporary transformation races that should defer origin capture.

PDV_RaceMap_README.txt
  This article.

Option 1: RaceCompatibility
---------------------------

Use this when the custom race already uses RaceCompatibility.

1. Make sure RaceCompatibility.esm is installed and active.
2. Make sure the custom race has the matching ActorProxy keyword for the
   vanilla race profile it should use.
3. No PDV_RaceMap.json entry is required when the ActorProxy keyword is present.
4. Test on a new/disposable save and check Devotion's MCM Compatibility page.

RaceCompatibility ActorProxy keywords:

  ActorProxyNord      -> 0 Nord
  ActorProxyImperial  -> 1 Imperial
  ActorProxyBreton    -> 2 Breton
  ActorProxyHighElf   -> 3 Altmer
  ActorProxyWoodElf   -> 4 Bosmer
  ActorProxyDarkElf   -> 5 Dunmer
  ActorProxyKhajiit   -> 6 Khajiit
  ActorProxyArgonian  -> 7 Argonian
  ActorProxyOrc       -> 8 Orc
  ActorProxyRedguard  -> 9 Redguard

Option 2: Race Blood Test
-------------------------

Use this when the modlist uses Race Blood Test to translate custom races.

1. Add or keep the Race Blood Test rules that treat the custom race as the
   nearest vanilla race.
2. Add a Morph rule for the vampire race, if the race has one.
3. Keep PDV_RaceMap.json as a fallback when Papyrus still sees the custom RACE
   form directly.
4. Test on a new/disposable save and check Devotion's MCM Compatibility page.

Confirmed Ohmes-Raht / Half-Khajiit example:

  Treat "HalfKhajiitRace" As "KhajiitRace";
  Treat "HalfKhajiitRaceVampire" As "KhajiitRaceVampire";
  Morph "HalfKhajiitRaceVampire" Is "HalfKhajiitRace";

For another race, replace the custom EditorIDs and vanilla target race with the
profile you want Devotion to use.

Option 3: Manual PDV_RaceMap.json entry
---------------------------------------

Use this when the race has no usable RaceCompatibility ActorProxy keyword, or
when you want an explicit fallback for a modlist.

1. Open the custom race plugin in xEdit or another record viewer.
2. Find the playable RACE record.
3. Find the plugin-local FormID for that RACE record.
4. Add the form token to PDV_RaceMap.json.
5. Add the matching race profile index to raceIndices at the same array slot.
6. Repeat for the vampire race form, if one exists.
7. Test on a new/disposable save and check Devotion's MCM Compatibility page.

Form token format:

  "0x<local form id>|<plugin filename>"

Example:

  "0x03322B|HalfKhajiit.esp"

The raceForms and raceIndices arrays must stay in the same order. This example
maps two custom race forms to Khajiit profile 6:

  {
    "raceForms": [
      "0x03322B|HalfKhajiit.esp",
      "0x05693A|HalfKhajiit.esp"
    ],
    "raceIndices": [
      6,
      6
    ]
  }

Ohmes-Raht / Half-Khajiit shipped defaults
------------------------------------------

Devotion ships these entries by default:

  0x03322B|HalfKhajiit.esp = HalfKhajiitRace -> 6 Khajiit
  0x05693A|HalfKhajiit.esp = HalfKhajiitRaceVampire -> 6 Khajiit

No HalfKhajiitWerewolf RACE record exists in the lists checked so far.
If a future list adds one, do not add it to PDV_RaceMap.json. Add it to
PDV_TemporaryRaceMap.json instead.

Temporary beast forms
---------------------

Temporary forms are not cultural origins. Werewolf, Vampire Lord, and similar
beast-form RACE records should go in PDV_TemporaryRaceMap.json:

  {
    "temporaryRaceForms": [
      "0x123456|SomeCustomRace.esp"
    ]
  }

Rule: Do not put temporary transformation races in PDV_RaceMap.json.

If Devotion reads a temporary race during startup, it defers origin capture and
tries again later when the player is back in a normal playable race.

Shipped temporary-race defaults
-------------------------------

Devotion ships two entries by default, both from Triumvirate - Mage Archetypes:

  0x000837 = TVR_Verdant_Race_ForceOfNature -> Horned Lord (Druid Apprentice)
  0x29DA06 = TVR_Verdant_Race_Wildshape     -> Deer (Druid Adept)

Both are confirmed player transformations: Triumvirate's TVR_Wildshape_Script
calls SetRace() plus SetBeastForm() on the player, the same API pairing vanilla
lycanthropy uses. Without these entries, casting one of these spells before
Devotion has captured origin could read the transformation race and lock origin
to the Imperial fallback.

Entries are inert when Triumvirate is not installed: the lookup resolves through
Game.GetFormFromFile, which returns None for an absent plugin.

Not included, and why:

  - Triumvirate's summon and totem races (TVR_Primal_Race_Call*,
    TVR_Demon_Race_Conjure*, TVR_Totem_Race_Totem, TVR_Totem_Race_EyesInTheSky,
    TVR_Warrior_Race_Fylgja*) are applied to summoned actors, never the player,
    so they do not belong here. TVR_Totem_Race_EyesInTheSky in particular is the
    scrying eye of the Farsight spell (cast at a target location), not a player
    form.

How to test
-----------

Use a new game or a disposable save where Devotion has not already captured the
player's origin race.

1. Start as the custom race.
2. Let Devotion initialize.
3. Open Mod Configuration -> Devotion -> Compatibility.
4. Confirm Custom race mapping is On.
5. Confirm Detected shows the expected mapped profile, such as:

   Custom race -> Khajiit (mapped)

6. If it shows Imperial fallback, check:

   - RaceCompatibility ActorProxy keyword is present, if using RaceCompatibility.
   - Race Blood Test Treat/Morph rules are active, if using Race Blood Test.
   - PDV_RaceMap.json has the right form token.
   - raceForms and raceIndices have matching array lengths.
   - The race index is 0 through 9.
   - Temporary beast forms are in PDV_TemporaryRaceMap.json, not PDV_RaceMap.json.

Support boundary
----------------

This mapping controls which existing Devotion race profile a custom race uses.
It does not create new gods, new race writing, or new custom-race reward
families.
