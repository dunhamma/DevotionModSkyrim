# ARR 2.5 T16 evidence dossier

## Scope and evidence boundary

T16 covers alternate-route mods whose physical quest completion can represent
different player choices. Evidence came from absolute-path direct
`housecarl_read_plugin_file` reads against ARR 2.5 files; the active Anvil
houseCARL instance was not changed.

These reads establish records in the named files. They do not prove ARR winning
records, runtime stage delivery, player-facing presentation, or support. The TG
Alternative Endings synthetic routing is script-backed and must be traversed
organically before its semantics can be cleared.

## Authored evidence

| plugin/channel | record and resolving stages | direct evidence verdict |
|---|---|---|
| `TG Alternative Endings.esp` | override `Skyrim.esm:021555`, `TG09|200`; global `00081C` | The mod completes physical stage 200 for three conditional journal results. Global 0 returns the Key and keeps vanilla core routing. Global 1 says the player stood against Nocturnal and freed all Nightingales; it maps to synthetic `201`. Globals 2/3 say the player wrested away and kept the Skeleton Key; they map to `202`. |
| `SaveTheIcerunner.esp` | override `Skyrim.esm:023A64`, `MS07|300/310/320/330/350` | Direct resolving entries distinguish Jaree-Ra dead and the ship safe; persuasion to abandon the plot; joining the marauders for loot; betraying them for loot; and Jaree-Ra's arrest. |

## Runtime collision correction

Core already owns `TG09|200`, so a plain per-mod channel at the same key could
never override it: `ResolveQuestReactionCellFile` is core-first. T16 therefore
resolves the optional mod global before matrix routing and uses synthetic stages
201/202 only for the alternate outcomes.

TG09 physical stage 200 also drives Nocturnal's organic +10 commitment signal.
That route now runs only when the resolved stage remains 200. Synthetic 201/202
emit an explicit suppression trace and do not falsely grant Nocturnal commitment.
The dependency is soft: absent plugin, missing global, every other quest, and
every other stage return the physical stage unchanged.

## Reviewed exclusions and deferrals

- Blood on the Ice Redux adds stages 4/5/9/15/65, but none creates a new
  resolving player outcome; vanilla 100/250 remain authoritative. `NO-ROWS`.
- `TGAEDestroy` exposes a Vigilant route but its stage 15 is textless and cannot
  safely identify the terminal outcome. `DEFER` pending a direct result hook.
- A New Debt Alternate Routes changes dialogue without a new QUST/stage
  surface. `DEFER` unless a genuine dialogue result hook is later justified.
- Unmasking Sybille contains a genuine vampire reveal but only nameless,
  non-journal dialogue-holder quests. `DEFER` to a future exact INFO/result
  hook rather than inventing a quest-stage route.
- Markarth Murder Prevention and Saadia add no rowable QUST surface.
- Skyforge Immersion Addon is a headless two-stage controller, Spooky Philter
  has a zero-stage quest, and the Jagged Crown display mods are cosmetic. All
  are `NO-ROWS` for the quest matrix.
- Save the Icerunner's added jail/revenge controllers and added textless stages
  300/400 on `MS07_dunIcerunnerQST` are not safe scoring surfaces.

## FormKey rule

Both channels override vanilla quests, so their rows use origin FormKeys
`Skyrim.esm:021555` and `Skyrim.esm:023A64`. The installer detects the mod ESP;
the runtime matrix resolves the canonical quest identity.
