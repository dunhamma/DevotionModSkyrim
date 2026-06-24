# PDV CC Integration -- Form Evidence (houseCARL, 2026-06-25)

Source of truth for the FormIDs and stage indices used by HO_CCIntegration
(queue A3). All reads via houseCARL against the live "Devotion Dev" MO2
profile (359 plugins resolved). Both Creation Club plugins resolve as
implicit/force-loaded masters in the dev order, but the live build must NOT
hard-master them -- see InitSurvivalContext mirror in the handoff.

ASCII-only. FormID form is `XXXXXX:Plugin.esp` (6 hex + defining master).

## 1. Saints & Seducers -- ccbgssse025-advdsgs.esm

Load-order status: ACTIVE (implicit master/CC, force-loaded; houseCARL
reads/writes it). NOT a managed mod-folder; it is CC content.

Main questline (the Sheogorath beat):
- QuestB `ccBGSSSE025_QuestB` = **000913:ccbgssse025-advdsgs.esm**
  Name = "Restoring Order" (the climactic line that ends with Sheogorath).
  Winner is `unofficial skyrim special edition patch.esp` (override depth 2);
  the QUST FormID is still defined by the CC esm, so GetFormFromFile against
  the CC esm resolves the same record regardless of the USSEP override.
  Stage indices (6 stages): 0 (StartUpStage), 10, 20, 30, 40, **200 (final/complete)**.
  -> Stage 200 = quest done = the Sheogorath-recognition beat to mirror as a
     PDV_DaedricPath_Sheo commitment signal.
- QuestA `ccBGSSSE025_QuestA` = 000912:ccbgssse025-advdsgs.esm
  Name = "Balance of Power" (22 stages; the choose-a-faction arc that precedes
  Restoring Order). Optional secondary beat (a mid-arc commitment nudge); the
  1.0 trigger should key off QuestB stage 200 only to stay single-fire.

Other named quests present (not used in 1.0 scope, listed for completeness):
WIKillSaintLeader 21BD5F, WIKillSeducerLeader 21BD6D, StaadaQuest 198277,
PostQuestCourier 0819B5.

## 2. Fishing -- ccbgssse001-fish.esm

Load-order status: ACTIVE (implicit master/CC, force-loaded).

Day-to-day "you fished" act signal (light Kyne/Kynareth lane):
- `ccBGSSSE001_IsPlayerFishing` (GlobalShort) = **000B26:ccbgssse001-fish.esm**
  0/1 flag, flips to 1 while the player is actively fishing. Best 1s-tick edge:
  detect the 0->1 rising edge (store last value), award once per rising edge,
  then anti-farm to once per dawn cycle.
- `ccBGSSSE001_CatchTypeLargeFish` (GlobalShort) = 000892:ccbgssse001-fish.esm
- `ccBGSSSE001_CatchTypeSmallFish` (GlobalShort) = 000894:ccbgssse001-fish.esm
  Increment on a successful catch; an alternative "caught a fish" edge if the
  IsPlayerFishing flag proves too coarse (it can sit at 1 for the whole minigame).
- `ccBGSSSE001_HasCaughtFishAtLeastOnce` = 201818:ccbgssse001-fish.esm
  One-shot lifetime flag; NOT useful for a repeatable day-to-day.
- FishingSystemQuest `ccBGSSSE001_FishingSystemQuest` = 033A57:ccbgssse001-fish.esm
  (runtime quest that drives the minigame; the globals above are its outputs).

Recommended primary edge for 1.0: poll `IsPlayerFishing` (000B26) rising edge
on the existing 1s OnUpdate tick; anti-farm with ConsumeDailyRepeatMultiplier.

## 3. Post-1.0 (evidence captured, NOT in 1.0 scope)

- Ghosts of the Tribunal -- ccBGSSSE062-* : Dunmer deviation price route via
  HandleDunmerDeviationPrice (NOT a new lane). FormIDs TBD-via-houseCARL when
  promoted (plugin was not probed this pass; confirm it is in the order first).
- The Cause -- ccBGSSSE068-* : Mehrunes Dagon path. The Cause culminates in a
  Mythic Dawn / Dagon beat -> mirror to PDV_DaedricPath_Dagon. FormIDs
  TBD-via-houseCARL when promoted.

## 4. Acceptance invariant

On a CC-less load order, Game.GetModByName returns 255 for the plugin, the
per-CC present flag stays False, InitCCContent caches no forms, the tick poll
and quest-stage probe both short-circuit, and NO record references a CC master.
Graceful no-op; Devotion.esp never gains a hard master on either CC plugin.
