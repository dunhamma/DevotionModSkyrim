# Altmer P7 record half - implementation handback (2026-08-03)

## Scope and claim boundary

This handback covers only the record and manifest half of P7. It created the
Trinimac book FormList and declared its intended P2 route. It does not claim
Papyrus dispatch, VMAD binding, PEX freshness, runtime-route proof, player
surface proof, or late-game-feed completion.

houseCARL was set to `D:\Wabbajack\modlists\Anvil`, profile `Devotion Dev`,
and confirmed `Devotion.esp` active before the write. A verified pre-write
snapshot is at `generated/live-devotion-backups/P7-records-pre-20260803-191934`.

## Authored record and selected books

New record: `0716E1:Devotion.esp` `PDV_FLST_P2_AltmerTrinimacSources`.

| FormID | Book | Why it belongs |
|---|---|---|
| `01AD16:Skyrim.esm` | *The True Nature of Orcs* | Names Trinimac as the Altmeri champion who protected his people and frames Malacath as his corruption; this is the required fallen-champion memory, not sympathetic Malacath/Orsimer material. |
| `01ACF7:Skyrim.esm` | *Fall of the Snow Prince* | An elven leader rallies a collapsing force in a final defensive battle, giving the list a bounded martial-defence example rather than a generic kill trigger. |
| `01AD18:Skyrim.esm` | *The Wild Elves* | Preserves Ayleid cultural identity and civilisation against outsider simplification, providing the curated civilisation/heritage side of the route. |

The tracked P2 receiver manifest now declares the same FormList for Altmer,
with `sourceKinds: ["book"]`, route
`PDV_EventBus.RouteAltmerTrinimacOrthodoxy(sourceId)`, and the locked
accepted/rejected-use boundaries.

## Direct readback and overlap check

```text
batch: 8 records

type=FormList  formid=0716E1:Devotion.esp
editorid=PDV_FLST_P2_AltmerTrinimacSources  winner=Devotion.esp
  Items[0] = 01AD16:Skyrim.esm
  Items[1] = 01ACF7:Skyrim.esm
  Items[2] = 01AD18:Skyrim.esm

type=FormList  formid=071055:Devotion.esp
editorid=PDV_FLST_P2_AltmerAurielSources  winner=Devotion.esp
  Items[0] = 01AF94:Skyrim.esm
  Items[1] = 01AD06:Skyrim.esm
type=FormList  formid=071056:Devotion.esp
editorid=PDV_FLST_P2_AltmerLorkhanPenalties  winner=Devotion.esp
  Items[0] = 02610C:Skyrim.esm
type=FormList  formid=071057:Devotion.esp
editorid=PDV_FLST_P2_AltmerMagnusSources  winner=Devotion.esp
  Items[0] = 01ACFE:Skyrim.esm
  Items[1] = 01ACF1:Skyrim.esm
type=FormList  formid=071058:Devotion.esp
editorid=PDV_FLST_P2_AltmerXarxesSources  winner=Devotion.esp
  Items[0] = 01AD09:Skyrim.esm
  Items[1] = 01ADB4:Skyrim.esm
  Items[2] = 0ED03A:Skyrim.esm

type=Book  formid=01AD16:Skyrim.esm
editorid=Book4RareTrueNatureofOrcs
  Name = The True Nature of Orcs
type=Book  formid=01ACF7:Skyrim.esm
editorid=Book3ValuableSnowPrince
  Name = Fall of the Snow Prince
type=Book  formid=01AD18:Skyrim.esm
editorid=Book4RareWildElves
  Name = The Wild Elves
```

All three new entries resolve to real `BOOK` records through the active load
order. None overlaps any existing Altmer P2 source or penalty FormList.

The pre-write snapshot and post-write direct plugin read both report the same
master order: `Skyrim.esm`, `Dawnguard.esm`, `HearthFires.esm`, and
`Dragonborn.esm`. The record count moved from 1,949 to 1,950 and the FormList
count from 94 to 95, exactly matching one new FormList.

## Gates

- `node tools/pdv_ascii_guard.mjs --ext .json references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`: PASS, one file ASCII-clean.
- Manifest JSON parse: PASS.
- `node tools/pdv_verify.mjs --json` at 2026-08-03 19:26:11 AEST: `PASS=4122`, `TODO=1`, `WARN=1`, `INFO=73`, and no `FAIL` findings. The one new FormList raised the ESP scan from 1,949 to 1,950 records; this is the expected count movement.

## Remaining blocker

The next required step is the separately owned P7 Papyrus packet: add the new
3122 Trinimac signal and `HandleAltmerTrinimacOrthodoxy`, declare and bind the
PlayerEvents FormList property, and add the PlayerEvents and EventBus route.
Then obtain compile, direct VMAD readback, runtime-route, and player-surface
proof before treating this source list as a live Trinimac earn channel.
