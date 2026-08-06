# Khajiit Lunar and Champion Rebalance -- In-Game Acceptance

Machine/readback completion does not close these cards. Record screenshots,
Papyrus markers, Active Effects, and the exact save state used for each result.

## Outdoor sleep

- Complete one exterior bedroll sleep and one Campfire-tent sleep. Each must
  count from sleep-start context and present only at the first road-home rest of
  the 06:00 devotional day.
- Confirm an indoor sleep, an interrupted outdoor sleep, and a stop with missing
  start context do not count.
- Cross 06:00 and confirm the road-home presentation and substrate budget reset.

## Substrate and focus

- Prove exclusive substrate boundaries at `1`, `24`, `25`, `74`, and `75`:
  `Disease +5`; then `Stamina +10 / Disease +10`; then `Stamina +15 / Disease
  +15`, with no Magicka.
- Seed each deity to exactly `25` piety. Prove no focus at weight `24`, no focus
  at a lead of `14`, and emergence at weight `25` with a lead of `15`.
- On the first emergence, capture exactly one MessageBox, one toast, and one
  pinned Book entry. Save/load and confirm the popup does not repeat.
- Create a tie and lower focused piety below Seeker; confirm focus remains.
- Give another Seeker deity a qualifying `25 / 15` lead; confirm automatic
  reorientation produces toast and Book entry without another popup.

## Rewards and resonance

- Inspect all fifteen Seeker/Devoted/Champion packages in Active Effects and
  prove only the highest tier for the focused deity remains.
- Exercise all eight god-strength slots. For each, confirm the correct god name,
  observation pool, and resonance state.
- For every deity, compare one numeric focused effect with resonance off and on;
  the on value must be exactly `1.20x`. Substrate effects and scripted Champion
  gifts must not change.
- Observe representative deity and shared lines and confirm no immediate repeat,
  including a shared line across a god change. Temporarily remove or invalidate
  the JSON and prove the compiled four-line fallback.

## Azurah's Portent

- As an Azurah Champion, trigger the lesser power indoors and outdoors. Confirm
  15 seconds and the 100-foot/200-foot range difference.
- Include hostile and non-hostile living actors, undead, corpses, Daedra, and a
  Dwarven automaton. Confirm category visuals are distinguishable through walls
  but do not cross loading doors or unloaded cells.
- Confirm one successful-use toast and Book entry, then a same-day short fizzle
  with no second entry. Cross 06:00 and confirm recharge.
- Reorient or lower Azurah below Champion and confirm the power is removed.

## Baan Dar stale-rescue regression

- Seed or preserve the stale Baan Dar T3 effect, then set Baan Dar to Seeker.
  Drop below the trigger threshold and confirm no rescue occurs.
- At Baan Dar Champion, confirm a valid rescue restores to 50% Health once per
  devotional day and cannot fire again until the next 06:00 boundary.

All cards remain `OPEN` until evidence is attached to the current Khajiit race
gate ledger.
