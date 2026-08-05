# Altmer P11 -- notification copy packet (2026-08-04)

**Status:** CONSUMED 2026-08-04. All twelve records now exist in `Devotion.esp` (`0716E5`-`0716F0`)
carrying this copy verbatim, under the EditorIDs specified below; the four wire-in steps at the end
of this file are done and readback-verified. This file remains the authored string source — edit a
line here and in the record together.

**Anchored to:** `race-sheets/PDV_RaceContent_Manifest.md` Section 13.1 (tone profiles), 13.3-13.5
(the authored `PDV_Notif_Altmer_*` prose and its voice/budget rows), Section 3 (voice-by-surface
matrix), Section 4 (length budgets); `race-sheets/PDV_RaceDesign_Altmer.md` (Religious Identity,
Tier Rewards, the 2026-08-04 Dawn Relocation note); the shipped record shape of
`071525 PDV_Notif_Nord_Kyne_ChampionAmbient_Storm`.

## Voice and shape

Champion ambient is **player-second-person** (manifest Section 3: "fires in fitting context after
entry; reads as the player noticing"). Not god-voice -- the god speaks at Champion *entry*, which is
a different surface and already authored in manifest 13.4.

Record shape, copied from `071525`:

- `Name` = the short title (Nord precedent: `Wind`, `Ancestors Quiet`)
- `Description` = the notification line
- `MenuButtons` = empty, `Quest` = null link, `Flags` = 0

Budget: 80 hard / 60 target. Every line below is under 60.

**Variant A / Variant B.** P11 gates variant B behind `MarkHigh >= 1` so the voice deepens with Long
Devotion instead of repeating flat. The B lines are written to read as *later* than the A lines --
the same relationship seen from further along, not a louder version of it.

## The twelve

### Auri-El -- vast, serene, sun and time, the return

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn` | Dawn | The dawn answers you, and the return feels near. | A |
| `PDV_Notif_Altmer_AuriEl_ChampionAmbient_Return` | The Return | The road back is shorter than it was. | B |

The A line is the manifest's own authored prose (13.4), reused verbatim.

### Magnus -- precise, scholarly, the arts as the road out

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Magnus_ChampionAmbient_Study` | Discipline | The arts come easily today. The discipline shows. | A |
| `PDV_Notif_Altmer_Magnus_ChampionAmbient_ElderWay` | The Elder Way | You read the wall as a door now. | B |

The manifest's Magnus ambient (13.4) is keyed to a **skill milestone**, but P11's ambient arm is a
4-day dawn cadence tick, so that line does not fit this trigger. Written fresh. The B line echoes the
authored Magnus Champion entry ("I studied until the wall became a door") deliberately -- it pays off
a line the player has already read.

### Xarxes -- dry, archival, lineage, what is written

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Xarxes_ChampionAmbient_Record` | The Record | The record has your name in it now. | A |
| `PDV_Notif_Altmer_Xarxes_ChampionAmbient_Lineage` | The Lineage | What you have done is written where it will keep. | B |

### Trinimac -- stern, militant, civilizational, the martial ancestor

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Trinimac_ChampionAmbient_Watch` | The Watch | The project stands where you have stood. | A |
| `PDV_Notif_Altmer_Trinimac_ChampionAmbient_Sword` | The Sword | Trinimac's weight sits easy on your arm now. | B |

"The project" is established player-facing Altmer vocabulary (manifest 13.4, 13.8, 13.12), not design
jargon. "The *elven* project" is design jargon and is not used here.

The B line pays off the authored Trinimac offer ("Name me, and carry that weight").

### Syrabane -- gentle, guardian-toned, shields the one still on the path

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Syrabane_ChampionAmbient_Ward` | The Ward | Something is holding between you and harm. | A |
| `PDV_Notif_Altmer_Syrabane_ChampionAmbient_Guard` | The Guard | You are warded, and you have stopped noticing. | B |

The B line is the protection-lane version of long devotion: the ward has become ordinary. It is the
gentlest possible way to say "this has been true for a long time", which is the whole point of the
`MarkHigh` gate.

### General heritage -- the deity-agnostic ancestral spine

| EditorID | Name | Description | Trigger |
|---|---|---|---|
| `PDV_Notif_Altmer_General_HeritageExemplar` | Heritage | The inheritance is whole in you. | substrate tier HIGH, same cadence |
| `PDV_Notif_Altmer_General_HeritageQuiet` | Heritage Quiet | The inheritance has gone quiet. | once, on a fall from HIGH |

Written as a matched pair against the Nord precedent `PDV_Notif_Nord_General_AncestorsQuiet` / "The
ancestors are quiet." These name **the inheritance**, never a god -- the spine is deity-agnostic per
the 2026-08-04 Dawn Relocation note ("the ordered life every Altmer keeps because they are Altmer").

They deliberately avoid the visible substrate tier words (`Ordered` / `Disciplined` / `Exemplar`
Heritage), which the player already sees on the substrate readout. Repeating a tier label in an
ambient line would read as a tier change that has not happened.

## Downstream wire-in -- DONE 2026-08-04

All four steps below were completed by the P11 build. Kept as the record of what was required:

1. **Create 12 MESG** in `Devotion.esp` shaped like `071525` -- `Name` and `Description` per the
   tables above, no menu buttons, null Quest.
2. **Declare 12 `Message` properties** on `PDV__ManagerQuest.psc`.
3. **Bind all 12 in the CK, then read the manager VMAD back** and confirm each property's `Object` is
   non-null. This is the step that catches the silent failure: the notification helper falls back to
   a Prisma toast when the record is `None`, so an unbound property produces no error, no log line,
   and a plausible-looking toast.
4. `ShowAltmerNotification(...)`, `RunDawnChampionAmbient()`, the substrate arm, and the
   `ProcessDawn` call site -- per the P11 packet, not this file.

**Verify:** `housecarl_cross_plugin_query plugins=["Devotion.esp"] editorid_contains="PDV_Notif_Altmer"
type=Message` -> 12 matches (0 today).

## Not changed by this packet

- Manifest Sections 13.3, 13.5, 13.6 and 13.7 author a further 15 `PDV_Notif_Altmer_*` slots
  (tier-up, lapse, neglect texture, Lorkhan pressure, ThalmorAlignment bands). Those are a separate
  wave with separate triggers and are **not** part of P11's twelve. Left untouched.
- No piety, no gating, no cadence values. Text only.
