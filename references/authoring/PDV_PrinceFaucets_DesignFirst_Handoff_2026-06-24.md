# PDV Thin-Prince Faucets — Design-First Six (Codex Handoff, 2026-06-24)

## What & why
The 6 design-first Princes sit at **1/4** on the signal floor — only `quest-reaction`,
**zero renewable**. Give each a **renewable `faucet`** via the **proven `OnObjectEquipped`
equip-artifact pattern** (the same one the 10 wired faucets use — Clavicus Masque,
Hermaeus Black Book, etc.). Bearing a Prince's own daedric artifact is a clean, lore-sound,
daily-capped act of devotion. This takes each from **1/4 → 2/4 (faucet added, 1 renewable)**.

> **Detection rule (do NOT deviate):** use `OnObjectEquipped` of a curated artifact FormList.
> Do NOT try `OnSpellCast`/staff-fire or weapon-on-hit detection for these — staff casts do
> not reliably fire `OnSpellCast` and weapon-hit fires on the victim, not the player, so those
> would be wired-but-never-fire (the exact silent class this project fights). The
> equip-event is light-frequency but real and floor-clearing; richer artifact-USE detection
> is a deliberately deferred enhancement (see Backlog).

## The six faucet rows (add to `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv`)
Columns: `deity,act,trigger_detection,act_tag,valence,intensity,magnitude,anti_farm_cap,buildability,notes`

| deity | act | act_tag | artifact FormList (resolve FormIDs via houseCARL) |
|---|---|---|---|
| Molag Bal | Bear the Mace of Molag Bal | `serve_a_daedra:molag_bal` | Mace of Molag Bal |
| Hircine | Don the Hunt-Lord's regalia | `serve_a_daedra:hircine` | Savior's Hide + Ring of Hircine |
| Meridia | Bear Dawnbreaker | `serve_a_daedra:meridia` | Dawnbreaker |
| Sheogorath | Carry the Wabbajack | `serve_a_daedra:sheogorath` | Wabbajack |
| Mehrunes Dagon | Bear Mehrunes' Razor | `serve_a_daedra:mehrunes_dagon` | Mehrunes' Razor |
| Nocturnal | Wear the Nightingale's shadow | `serve_a_daedra:nocturnal` | Nightingale Blade + Bow + Armor set (Skeleton Key is a returned quest item — do not use it) |

All rows: `valence=+`, `intensity=C`, `magnitude=small`, `anti_farm_cap=1/dawn`, `buildability=GOOD`,
`notes="Equip-event faucet (proven OnObjectEquipped pattern); light frequency, daily-capped; floor adds the renewable faucet type."`

## Build steps (mirror an existing equip-faucet exactly)
1. **Resolve artifact FormIDs via houseCARL** (`housecarl_read_record` / `_cross_plugin_query`).
   Use the **load-order winner** FormID per item. Do NOT invent FormIDs.
2. **Create one curated FormList per Prince** (via houseCARL `create_record`, or the project's
   FormList authoring path), e.g. `PDV_FLST_Faucet_MolagBal_Artifact`, holding the artifact(s).
3. **Register each list in `tools/pdv_quest_matrix_compile.mjs`** under `FAUCET_FORM_LISTS`,
   keyed `faucetForms.<Deity>.<tag>` (mirror the existing Clavicus/Hermaeus entries).
4. **Recompile the matrix:** `node tools/pdv_quest_matrix_compile.mjs` (writes the
   StorageUtilData JSON; `--check` validates without writing). New `faucetActs` count rises.
5. **Wire the `OnObjectEquipped` branch in `live-source/Scripts/Source/PDV_PlayerEvents.psc`** —
   copy an existing equip-faucet branch (`ShouldRouteQuestReactionFaucet(key, listKey, form)
   -> RouteQuestReactionFaucet`) and extend the `listKey -> runtimeKey` mappers (the block
   near the other faucet mappers). Detection event = `OnObjectEquipped`. No new event handler
   is needed — `OnObjectEquipped` already exists; you are adding cases to it.
6. The routing tail is already built: `RouteQuestReactionFaucet` (`PDV_EventBus.psc:107`) ->
   `ApplyQuestReactionFaucet` (`PDV__ManagerQuest.psc:1186`) -> `ApplyDeityReaction` (stance-gated,
   anti-farm via `MarkQuestReactionFaucet`). Do not re-author the tail.

## Verify (Codex, before hand-back)
- `node tools/pdv_quest_matrix_compile.mjs --check` -> PASS, `faucetActs` +6.
- `node tools/pdv_compile.mjs --script PDV_PlayerEvents` -> 0/0.
- `node tools/pdv_verify.mjs` -> FAIL=0.
- houseCARL: each new `PDV_FLST_Faucet_*` exists as FLST with the artifact members (winner=Devotion.esp).

## Acceptance (Claude re-checks)
- `node tools/pdv_signal_floor_audit.mjs` -> the 6 Princes
  (`prince_molag_bal`, `prince_hircine`, `prince_meridia`, `prince_sheogorath`,
  `prince_mehrunes_dagon`, `prince_nocturnal`) move **1/4 -> 2/4** with `faucet` in
  `wired_types_present`.
- In-game (later, MCM-driven): equip the artifact once -> exactly one piety pulse that dawn;
  re-equip same day does not double-bank.

## Backlog (NOT in this packet — Claude designs next)
- **2nd renewable** to take each Prince 2/4 -> toward 4/2 (another renewable type per Prince).
- **Artifact-USE detection** (richer than equip) for staff/weapon Princes (Vaermina Skull,
  Sanguine Rose, Wabbajack cast) — needs a detection-mechanism design pass (perk entry-point
  vs animation event); deferred precisely because the naive hooks silently never fire.
- **The 10 Princes at 2/4** need their 2nd renewable too (separate pass).
