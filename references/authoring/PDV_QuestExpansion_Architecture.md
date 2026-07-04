# Quest Expansion + Meta-Faucet Architecture (2026-07-05)

Owner-requested pre-build architecture for the 832-cell matrix expansion + the 7 quest-meta-faucets,
with the explicit constraint: DO NOT add script load to the game. Companion to
`PDV_HO_SignalRichness_2026-07-04.md` section C (the design) -- this doc is the build contract.

## 0. Headline: the whole build is script-neutral

- **Zero new scripts.** No new .psc files, no new ActiveMagicEffect/ObjectReference instances.
- **Zero new ESP records and zero VMAD changes.** No new properties on any quest; deities resolve
  through the existing `GetDeityByName`; all tuning values live in the compiled JSON.
- **Zero new registrations, zero polling, zero waits.** The system stays hung off the ONE existing
  PO3 `OnQuestStageChange` registration on the player alias (verified: `PDV_PlayerEvents.psc:292`).
- Net runtime delta: a handful of integer/float reads on watched-quest fires only, plus one
  StorageUtil write per theft event. Save-file growth bounded (~100 int/float keys lifetime).

## 1. Verified cost model of the existing pipeline (trigger-first)

```
PO3 OnQuestStageChange (player alias, ONE registration, event-driven)   <- fires for EVERY quest
  -> PDV_PlayerEvents.RouteQuestReactionStage (guard: EventBusService set)   stage change game-wide
  -> PDV_EventBus.RouteQuestReaction
  -> PDV__ManagerQuest.ApplyQuestReaction(quest, stage)
       key = "quest.<decimalFormID>|<stage>."
       deitiesCsv = JsonUtil.GetStringValue(matrix, key+"deitiesCsv")   <- in-memory keyed lookup
       "" -> EARLY OUT (the game-wide spam path: ~3 external calls + 1 keyed read)
       else -> split + per-deity loop -> ApplyQuestReactionPiety -> AwardPiety
```

Classification (papyrus-optimization tiers): the trigger is event-driven with a cheap early-out --
GREEN. The unwatched path cost is INDEPENDENT of matrix size (keyed lookup, not a scan), so growing
390 -> 832 cells costs nothing at rest. Watched fires are one-shot per quest stage; a bigger
per-key deity list (avg ~7, max ~15) adds microseconds to a rare event. JSON parse happens once at
load; 832 cells is ~100 KB of PapyrusUtil memory -- negligible. ARR channel identical.

## 2. Data plane (all offline, compile-time)

1. **Tranches 1-8** -> `pdv_quest_tranche_merge` -> Full.csv -> `pdv_quest_matrix_compile` -> live
   JSON (+ ARR variant). Unchanged shape.
2. **NEW `PDV_QuestClassFlags.csv`** (editor_id, classes: `gold|mageAid|...`): consumed by the
   compile tool, emitted as **integer keys** `quest.<key>.class.gold = 1`,
   `quest.<key>.class.mageAid = 1`. Integers, one per class, so the runtime does
   `JsonUtil.GetIntValue` -- **no string parsing at runtime**.
3. **Compile-time yield rule**: for each watched quest, the compiler knows which deities hold cells
   anywhere on it; for each meta deity that does, emit `quest.<key>.metaSkip.<Deity> = 1`.
   The runtime yield check is one int read -- **zero runtime bookkeeping** for "meta yields to
   cells" (the rule is a static fact, so it is computed statically).
4. **VALUE_TABLE additions**: `value.meta.zen`, `value.meta.nocturnalTheft`,
   `value.meta.nocturnalNight`, `value.meta.azura`, `value.meta.julianos`, `value.meta.wheel`
   (shared Akatosh/Xarxes), `value.meta.khenarthi`. Tuning stays a JSON knob; no Papyrus edits to
   rebalance.
5. Curation pass: tag `gold` + `mageAid` over the ~90 watched quests (short Sonnet pass against
   UESP reward/questgiver data; main-loop spot-check) -> the class CSV.

## 3. Runtime plane (two scoped .psc edits, no new files)

### 3a. `PDV_EventBus` theft stamp (3 lines)
In the existing 360/361/362 routing branches: `StorageUtil.SetFloatValue(None,
"PDV.Meta.LastTheftTime", Utility.GetCurrentGameTime())`. Cost: one StorageUtil write per theft
event the bus already processes. No new events.

### 3b. `PDV__ManagerQuest.EvaluateQuestMetaFaucets(questForm, key)` -- called from
`ApplyQuestReaction` ONLY after the watched-check passes (the unwatched spam path never reaches
it). Ordering inside, cheapest-first with early-outs:

```
1. per-quest once-guard: StorageUtil.GetIntValue(None, "PDV.Meta.Done." + qid) -> return if set
   (set it at the end; makes every meta lane finite by construction)
2. cache once per call: gameTime, hourOfDay, playerRef (existing cached player), class ints
3. per-deity lanes, each pattern: [metaSkip int read] -> [condition] -> AwardPiety(reason token)
   - zen:        class.gold == 1
   - julianos:   class.mageAid == 1
   - azura:      class.mageAid == 1  OR  hour in twilight windows
   - nocturnal:  LastTheftTime > LastFulfillTime (tier 1) else night hour (tier 2)
   - khenarthi:  !playerRef.IsInInterior()
   - wheel:      counter = AdjustIntValue("PDV.Meta.QuestCount", 1); counter % 10 == 0 ->
                 Akatosh + Xarxes lanes (ONE shared counter, one increment)
4. StorageUtil.SetFloatValue "PDV.Meta.LastFulfillTime" = gameTime; set once-guard
```

Per watched fire: ~10-20 StorageUtil/JsonUtil reads + float compares, no loops beyond the 7 fixed
lanes, no string splits, no waits, no new external-script calls. Reason tokens
(`meta_zen_wage`, `meta_nocturnal_theft`, ...) flow through `AwardPiety` so every fire lands as a
Ledger driver (owner rule) and `pdv_ledger_coverage_audit` tracks them (UNTRACKED must stay 0).

### Deliberately NOT done (anti-patterns rejected)
- No new Story Manager nodes / SM receiver quests (the PO3 event already covers all quests).
- No OnUpdate/poller, no cloak, no Utility.Wait, no RegisterForUpdate anywhere.
- No per-quest RegisterForRemoteEvent fan-out (would be 90 registrations for nothing).
- No runtime gold-delta sniffing (racy) -- gold is a compile-time class flag.
- No runtime "which deities have cells here" scans -- compiled into metaSkip ints.
- No new quest-start tracking; Nocturnal's window is the two-stamp comparison.

## 4. Save/migration posture

New StorageUtil keys only: `PDV.Meta.Done.<qid>` (max = watched quests, ~90 ints lifetime),
`PDV.Meta.QuestCount`, `PDV.Meta.LastTheftTime`, `PDV.Meta.LastFulfillTime`. No script-instance
changes, no VMAD property additions -> no save-migration concerns; mid-save players simply start
earning meta from their next fulfillment. Uninstall-safe (keys orphan harmlessly).

## 5. Build order + gates

1. Owner ratifies matrix (Phase 4/5) + meta design -> compile live JSON + ARR variant (the matrix
   half needs no Papyrus at all).
2. Class-flag curation pass -> `PDV_QuestClassFlags.csv` -> compile tool emits class/metaSkip ints
   (extend `pdv_quest_matrix_compile`; self-test fixture for class + metaSkip emission).
3. Manager + EventBus edits (Codex lane or main loop; serialize behind open manager work).
   Compile 0/0; `pdv_verify` FAIL=0; `pdv_ledger_coverage_audit` UNTRACKED=0;
   `pdv_specced_minus_audit` clean; integrity harness PASS.
4. Fresh-save smoke: matrix reload count (832/118 keys); setstage probes for the PROVISIONAL
   stages (DLC1SeranaCureSelfQuest 200, MQ301 240, MS05 300, FreeformRiftenThane 200,
   FreeformSkyhavenTempleA 50); one fire per meta lane (gold, mage-aid, twilight, theft-window,
   night, outdoors, 10th-quest); yield check (a Julianos College quest fires the CELL, not the
   meta); once-guard re-fire negative; Ledger driver rows for each reason token.
5. Rerun `pdv_signal_richness` extraction + update the coverage ledger; decisions-log entry.
