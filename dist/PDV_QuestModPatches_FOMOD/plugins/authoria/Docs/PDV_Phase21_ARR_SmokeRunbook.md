# Devotion ARR 2.5 Experimental Test Guide

Use this guide to try the current Devotion compatibility candidate on Authoria -
Requiem Reforged 2.5. The package is machine-verified but is not yet supported.
Your results are the runtime evidence needed to find failures and decide what can
be supported later.

## Before installing

- Use ARR 2.5 and a copied test profile.
- Use a new or disposable save.
- Do not update a valuable save that used
  `PDV_Patch_Authoria_QuestMods.esp` or
  `PDV_AuthoriaARR_Compatibility.esp`. Save-update compatibility has not been
  established.
- Keep the Papyrus log from the test session. It is normally at
  `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.

## Install in MO2

1. Install the current `PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip`.
2. Name the installed mod `Devotion - Authoria ARR Compatibility`.
3. In the installer, choose **Authoria (Requiem Reforged) - All-In-One**.
4. Do not select or install the individual-patch lane as well. That lane is for
   non-Authoria load orders.
5. Put the compatibility mod below Devotion in MO2's left pane so its scripts,
   matrices, and configuration files win conflicts.
6. In MO2's plugin pane, enable `PDV_AuthoriaARR_Combined.esp`.
7. Disable the retired `PDV_Patch_Authoria_QuestMods.esp` and
   `PDV_AuthoriaARR_Compatibility.esp` if they remain from an older test.
8. Sort the plugins in this order:
   - `Devotion.esp`
   - `PDV_AuthoriaARR_Combined.esp`
   - `Requiem for the Indifferent.esp`
9. Run Authoria's normal Reqtificator procedure after changing the plugin list.

Do not copy compatibility files into Reqtificator, Synthesis, DynDOLOD,
ParallaxGen, TexGen, xLODGen, or NPC Plugin Chooser output mods. Keep the
compatibility package as its own enabled MO2 mod.

## First launch and registration

1. Launch ARR through MO2 and load the disposable save.
2. Open **Devotion MCM -> Debug: State & Rewards**.
3. Set **Debug level** to `2`.
4. Choose **Reload quest matrix -> Re-read JSON**.
5. Wait until Devotion notifications stop before reading the results.
6. Check `Papyrus.0.log` for:
   - 154 core watched quests;
   - 62 ARR watched quests;
   - 34 registered per-mod channels;
   - one channel-refresh line for each installed Authoria channel.

Stop here and report a failure if there is no channel-registration line, the
channel folder is empty, or a channel is unreadable. Those results normally mean
the compatibility mod lost a file conflict or the package did not install
completely.

## Quick shrine experiment

Travel normally by road, load door, or fast travel. Do not use `coc`, because
it can skip location setup.

1. Visit a Daedric shrine statue for Azura, Vaermina, Molag Bal, Mephala,
   Mehrunes Dagon, Sheogorath, Namira, Sanguine, Hermaeus Mora, Hircine, or
   Peryite.
2. Confirm the statue offers a **Pray** prompt.
3. Record the Prince's piety in Survey, then pray.
4. Expect one piety change, one notification, and one Book of Days entry.
5. Pray again on the same day. Expect no second award.
6. Pass one in-game day and pray again. Expect one new award.
7. Save, reload, and confirm the earlier prayer does not repeat by itself.

Jyggalag must award nothing. Wyrmstooth shrine placements use different base
objects and are not covered by this experiment.

## Quick quest experiment

Choose one quest you were already going to play and reach a patched outcome
organically. The bundled tester runbook and evidence ledgers list the exact
outcomes and expected deity reactions.

For the outcome you test, record:

- the quest and choice you completed;
- piety before and after;
- exactly one notification;
- exactly one Book of Days entry;
- the matching `[PDV][QR_QUEUE]` start and completion lines;
- whether saving and reloading repeats anything;
- whether the reaction made sense for the choice you actually made.

A controlled `setstage` test can show that a route exists, but it cannot prove
that normal quest progression reaches the right outcome. Organic play is the
evidence needed for support.

## Optional experiments

If they fit your playthrough, the packet also needs observations for:

- bard performances with Skyrim's Got Talent or Become a Bard;
- Aetherium Forge Destroys Items;
- Green Pact food classification;
- Breton Hidden Art reflection;
- Thieves Guild Alternative Endings;
- Legacy of the Dragonborn, Beyond Skyrim - Bruma, and Wyrmstooth outcomes;
- vampire and werewolf state changes.

Use the structured JSON evidence ledgers installed under `Docs` when you want
to test a full tranche. You do not need to complete every case for a report to
be useful.

## What to send back

Send:

1. ARR version and profile name.
2. Confirmation that the Authoria All-In-One lane was selected.
3. Active plugin order around Devotion, the combined plugin, and Requiem for the
   Indifferent.
4. The 154 / 62 / 34 registration counts.
5. For each experiment: route marker, before/after piety, notification count,
   Book of Days count, save/load result, and what failed.
6. `Papyrus.0.log` when anything is missing, duplicated, or unexpected.

Please report missing reactions as well as successful ones. A silent failure is
useful evidence and is usually easier to fix than a false or duplicated award.
