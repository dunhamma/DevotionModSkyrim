# PDV Phase 21 ARR smoke runbook

Authoria uses Devotion as the sole player-religion system; begin directly with
the Devotion initialization checks below.

## Static preflight

- Confirm `Devotion.esp` is active and this compatibility mod wins its JSON and
  three PEX overrides.
- Confirm the matrix reports 43 tranche-2 cells and every unproven row carries
  `runtimeVerify=pending`.
- Confirm no generated output plugin is a master or source dependency.
- Confirm Base Object Swapper parses
  `PDV_AuthoriaARR_DaedricShrines_SWAP.ini`.

## P0 runtime

1. New game: confirm Devotion initializes without bard mods installed.
2. With SGT only: complete performances of low and high quality; confirm one
   Dibella pulse and an ovation bonus without a second edge pulse.
3. With Become a Bard: complete two performances in one tavern and one in a
   second tavern on the same day; confirm the first tavern is capped while the
   second remains eligible.
4. Complete BaB tavern/Jarl s100 and both Bards Reborn college quests; confirm
   one-time Dibella milestones.
5. Innocence Lost QE: arrest Grelod and reach s198; confirm Mara/Stendarr.
   Confirm s199/s201 receive no mercy credit.
6. Activate every Daedric Shrines AIO statue listed in the BOS INI, then the
   Wyrmstooth Nocturnal and Vaermina placements. Confirm the matching Prince
   path receives the prayer signal.
7. Activate Jyggalag's shrine; confirm no false deity credit.

## P1 runtime

- Sacrilege + Manbeast + Requiem VampireCollection state transitions.
- Alternate Perspective start with Starting Choices active.
- JS Shrines / CC Survival Disable Shrine Menu activation routing.
- Every matrix cell marked `runtimeVerify=pending`.
