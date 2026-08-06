# Devotion Patch - Authoria All-In-One

Experimental cumulative compatibility candidate for ARR 2.5 KoK R11. It is
machine-verified, not supported, until the bundled runtime ledgers are returned
with equivalent evidence for every included case.

## Install boundary

- Requires Devotion with per-mod channel support.
- Install the FOMOD through MO2 and select only **Authoria (Requiem Reforged) -
  All-In-One**. Do not also install individual patch options.
- Name the installed mod `Devotion - Authoria ARR Compatibility` and place it
  below Devotion in MO2's left pane so its scripts and data win conflicts.
- Enable only `PDV_AuthoriaARR_Combined.esp`. Sort it after `Devotion.esp` and
  before `Requiem for the Indifferent.esp`.
- Disable the retired `PDV_Patch_Authoria_QuestMods.esp` and
  `PDV_AuthoriaARR_Compatibility.esp` if they remain from an earlier test.
- Run Authoria's normal Reqtificator procedure after changing the plugin list.
- Do not place these source files inside Reqtificator, ParallaxGen, DynDOLOD,
  Synthesis, TexGen, xLODGen, or NPC Plugin Chooser output mods.
- Use a new or disposable test save. Updating a save that used either retired
  donor ESP has not been proven safe.

## First experiment

1. Start ARR and open **Devotion MCM -> Debug: State & Rewards**.
2. Set **Debug level** to `2`, then choose **Reload quest matrix -> Re-read
   JSON**.
3. Wait until Devotion's reward queue is quiet. Confirm the Papyrus log reports
   154 core watched quests, 62 ARR watched quests, and 34 registered channels.
4. Travel normally to one supported Daedric shrine statue and pray. Expect one
   piety change, one notification, and one Book of Days entry. A second prayer
   on the same day should award nothing.
5. Complete one patched quest outcome organically, then confirm the expected
   piety change in Survey and one matching Book of Days entry.
6. Save, reload, and confirm neither test result repeats by itself.

Report the installed lane, the three registration counts, the tested quest or
shrine, before/after piety, notification count, Book of Days count, save/load
result, and any `[PDV]` error lines. Partial reports are useful.

## Contents

- 34 per-mod quest-reaction channel JSON files, covering the original package
  and ARR 2.5 tranches T13-T17.
- Current core and legacy ARR matrix JSON files.
- `PDV_PlayerEvents`, `PDV_EventBus`, and `PDV__ManagerQuest` source/PEX. These
  include channel loading, T16 ending resolution, the optional AFDI once-ever
  observer, the existing bard observer, and the Breton Hidden Art renewable.
- `PDV_AuthoriaARR_Combined.esp` (ESPFE): the one combined Authoria plugin for
  KoK R11 deployment and this cumulative FOMOD. It replaces the former
  `PDV_Patch_Authoria_QuestMods.esp` and `PDV_AuthoriaARR_Compatibility.esp`
  donors, with 32 records total: 21 quest/dialogue overrides and 11 shrine-prayer
  ACTIs. Source quest SEQ files remain supplied by their respective masters.
- `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`: the 11 read-back prayer activators
  provide once-per-day prayer. Jyggalag is absent. Wyrmstooth placements use
  different base forms and are not claimed.
- The combined-plugin external-reference scan found five unrelated unreadable
  records; it did not establish a runtime or support result.
- `PDV_GreenPact_KID.ini`: exact-name classifications for 14 ARR animal foods
  and three Kabu gourd records, while retaining the existing Green Pact rules.
- Shared tester runbook and structured T13-T17/non-quest evidence ledgers.

## Proof boundary

The CSV/JSON gates, Papyrus compiler, source/PEX parity checks, record readback,
FOMOD simulations, file manifest, and archive checksum establish machine state
only. Controlled `setstage` may establish route delivery but cannot clear an
objective-derived row's semantic debt. Support requires the expected piety
result, exactly one toast, exactly one Book of Days beat, save/load behavior,
and organic correctness for every applicable case.
