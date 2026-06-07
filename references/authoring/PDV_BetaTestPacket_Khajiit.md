# PDV Beta Test Packet - Khajiit

Created: 2026-06-06
Status: conditional pass - wired lunar packet passed; edge focus source pending
Mode: console-assisted beta-feel packet

This packet records the restarted Khajiit lunar proof and keeps the remaining
edge-focus work separate. The currently filled live source family is lunar
book-read proof only; Baan Dar, Rajhin, Alkosh, road-home, theft, dragon, and
moon-sugar edge routes still need exact approved live sources before they can
count as beta-feel pass evidence.

## Result

2026-06-06:

- `Words of Clan Mother Ahnissi` and `The Tale of Dro'Zira` produced visible
  Prisma toasts.
- Survey/status movement, wrong-origin rejection, generic-source silence, and
  correct reward-pending behavior below threshold were confirmed in game.
- The reported lower-case Azurah display was patched in the Prisma display-name
  map.
- Remaining closeout is one approved live edge focus source for Baan Dar,
  Rajhin, Alkosh, or another explicit Khajiit edge route.

## Preflight

Use a disposable save.

```text
set PDV_GLO_OriginRace to 6
set PDV_GLO_DebugLevel to 2
```

Origin index `6` is Khajiit.

## Expected Build - Lunar Road-Home

Add the approved lunar books:

```text
player.additem 0001B27D 1
player.additem 0001AFF3 1
player.additem 000F03E3 1
```

Read each book normally from inventory:

- `0001B27D` - `Book3ValuableWordsofClanMotherAhnissi`.
- `0001AFF3` - `Book0AhzirrTraajijazeri`.
- `000F03E3` - `Book3ValuableTaleOfDroZira`.

Expected in game:

- Top-left notification or proven toast feedback only.
- No forced full Prisma panel and no blocked input.
- Survey Devotion explains lunar substrate, Azurah/Khenarthi cadence, active
  focus, and reward-pending state in race language.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit --strict-manager
```

Expected log marker:

```text
RouteKhajiitLunarSubstrate complete: po3_book_khajiit_lunar
```

## Edge Build - Focus Pressure

Current live status: blocked for full pass. No Baan Dar, Rajhin, Alkosh,
moon-sugar, theft, dragon, or road-home edge source is approved for live fill in
the current P2 book tranche.

Use the 2026-06-06 wired lunar result as a conditional packet pass only.

## Wrong-Origin And Generic Silence

Wrong-origin check:

```text
set PDV_GLO_OriginRace to 3
player.additem 0001B27D 1
```

Expected: no Khajiit manager state, reward, or Survey movement.

Generic-source check:

```text
set PDV_GLO_OriginRace to 6
```

Then try ordinary night stealth, generic theft, fast travel, moon-sugar use, or
generic dragon activity. Expected: no new lunar or focus state unless an exact
approved source owns the route.

## Evidence To Bring Back

```text
Khajiit expected build: PASS/FAIL
Khajiit edge focus: PENDING/FAIL
Wrong-origin rejection: PASS/FAIL
Generic-source silence: PASS/FAIL
Reward/stack snapshot: PASS/PENDING/FAIL
Blocking notes:
```

