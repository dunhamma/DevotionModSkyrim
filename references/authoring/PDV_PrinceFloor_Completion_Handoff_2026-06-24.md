# Prince-Floor Completion — 2nd renewable + 4th type (Codex Handoff, 2026-06-24)

## Goal
The prince floor is **4 types / 2 renewable**. After the equip-artifact faucets, the 6
design-first Princes are at **2/4 (faucet + quest-reaction, 1 renewable)**; the other 10 are
similar. Bring each toward floor by adding **(a) a 2nd renewable type** and **(b) a 4th type**.

## Recommended shape per Prince
- **2nd renewable = a day-to-day domain "like"** in `references/authoring/PDV_DeityLikesDislikes.csv`
  (renewable), regen via `tools/pdv_likesdislikes_gen.mjs`, **bump `LIKES_DISLIKES_VERSION`**
  (currently 9) or the change is inert, prove on a new save.
- **4th type = the Prince's own Daedric quest completion** as a `quest-stage` routeEntry
  (mirror the Green Way Eldergleam handoff: manifest routeEntry + a `ShouldRouteP2QuestStage`
  branch in `PDV_PlayerEvents.psc`, authored ATOMICALLY so the surface never RED-regresses).

## CRITICAL — detection first, no silent faucets
Before adding any day-to-day like, **confirm a real signal exists for that act** (check the
action-router / event vocabulary the likes table already consumes — e.g. kill-beast,
kill-undead, steal/pickpocket, lockpick). If there's no existing signal hook, that act is a
new-hook design task — flag it, don't wire a like that never fires (the silent class).

## Per-Prince domain acts (starter; verify detection)
| Prince | day-to-day like (renewable) | Daedric quest (quest-stage, 4th type) |
|---|---|---|
| Molag Bal | vampire feed / kill a yielding foe | DA10 "House of Horrors" |
| Hircine | kill a wild beast/animal | DA05 "Ill Met by Moonlight" (`02A49A`, verified) |
| Meridia | destroy undead | DA09 "The Break of Dawn" |
| Mehrunes Dagon | kill with destruction/fire | DA07 "Pieces of the Past" |
| Nocturnal | pickpocket / lockpick / sneak-kill | DA11 "Blindsighted" / Nightingale induction |
| Sheogorath | (no clean ambient act — DEFER; Wabbajack equip is its faucet) | DA15 "The Mind of Madness" |

(Repeat the pattern for the other 10 Princes from their domains + Daedric quests; Azura/
Boethiah/Mephala/Malacath already have a day-to-day, so they need the quest-stage 4th type.)

## Order
Do **one Prince end-to-end first** (Molag Bal: add the day-to-day like + DA10 quest-stage,
verify it clears 2/4 -> 4/2) before fanning out, so the pattern is proven once.

## Verify (per Prince)
- `node tools/pdv_likesdislikes_gen.mjs` (+ VERSION bump) and/or `pdv_quest_matrix_compile.mjs`
  as touched; `pdv_compile` 0/0; `pdv_verify` FAIL=0.
- `node tools/pdv_signal_e2e_gate.mjs` -> still **0 RED** (any new quest-stage routeEntry has
  its branch).
- `node tools/pdv_signal_floor_audit.mjs` -> the Prince moves toward **4/4, 2 renewable**.

## Coordination
ESP writes (if any new faucet FormLists are added) must be **serialized** — no concurrent
`Devotion.esp` writer (Claude may be running source-fills). The day-to-day (CSV) and
quest-stage (manifest+Papyrus) paths need NO ESP write, so they're conflict-free.
