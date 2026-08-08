# Altmer P11 -- notification copy packet (2026-08-04)

**Status:** CONSUMED 2026-08-04. All twelve records now exist in `Devotion.esp` (`0716E5`-`0716F0`)
carrying this copy verbatim, under the EditorIDs specified below; the four wire-in steps at the end
of this file are done and readback-verified. This file remains the authored string source — edit a
line here and in the record together.

**Relegibility rewrite 2026-08-05 -- ALL TWELVE lines were replaced.** The tables below carry the
current text and are synced with the ESP records and the `.psc` fallbacks. The prose commentary
around them was written for the original lines; where a note describes an earlier line it is marked
superseded inline.

Why they were replaced: the originals were written as aphorisms. That is the wrong shape for this
surface. Only the `Description` reaches the player -- `messageRecord.Show()` on a button-less MESG
renders the message text as a corner notification and never displays `Name` -- so each line gets a
couple of seconds of peripheral attention and has to carry its whole meaning alone. Lines like "You
read the wall as a door now." and "What you have done is written where it will keep." depended on
remembering a Champion-entry MessageBox from hours earlier, or on design vocabulary the player has
never been taught. The replacements use plain words and concrete images, keep the per-deity tone from
Section 13.1, and stay inside the 60-character target.

The `Name` fields were realigned to match the rewritten bodies (2026-08-06). They are editor labels
only -- never shown to the player -- so their job is to tell an editor what the line says, which the
EditorID already fails to do. The **EditorIDs are unchanged** (`_ElderWay`, `_Lineage`, `_Watch`),
because they are bound to VMAD properties and the manager's property names; renaming them would mean
re-binding all twelve. So a couple of slots hold a line their EditorID no longer describes. That is
the cheaper of the two mismatches and is deliberate.

The consolidated view of the whole lane, including everything outside these twelve, is
`race-sheets/PDV_AltmerLane_CopySheet.md`.

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
| `PDV_Notif_Altmer_AuriEl_ChampionAmbient_Dawn` | Dawn Answers | The dawn answers you now, as it answered your ancestors. | A |
| `PDV_Notif_Altmer_AuriEl_ChampionAmbient_Return` | Dawns Counted | You have met every dawn. Auri-El has counted them all. | B |

*Superseded 2026-08-05:* the A line was the manifest's own authored prose (13.4) reused verbatim.
It now keeps that line's opening but says what the dawn answering actually means, rather than
leaning on "the return" -- a phrase the player is never taught.

### Magnus -- precise, scholarly, the arts as the road out

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Magnus_ChampionAmbient_Study` | Study Shows | The spells come easily today. Your study shows. | A |
| `PDV_Notif_Altmer_Magnus_ChampionAmbient_ElderWay` | Long Study | Magnus has watched you study for a long time now. | B |

The manifest's Magnus ambient (13.4) is keyed to a **skill milestone**, but P11's ambient arm is a
4-day dawn cadence tick, so that line does not fit this trigger. Written fresh.

*Superseded 2026-08-05:* the B line used to echo the Magnus Champion entry ("I studied until the wall
became a door"). That callback only lands if the player remembers a MessageBox from many hours
earlier; on its own the line was opaque. The replacement states the same idea plainly.

### Xarxes -- dry, archival, lineage, what is written

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Xarxes_ChampionAmbient_Record` | Name Recorded | Xarxes has written your name into the record. | A |
| `PDV_Notif_Altmer_Xarxes_ChampionAmbient_Lineage` | Life Recorded | Xarxes has kept the record of your whole life. | B |

### Trinimac -- stern, militant, civilizational, the martial ancestor

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Trinimac_ChampionAmbient_Watch` | Line Held | You have held the line, and Trinimac saw it. | A |
| `PDV_Notif_Altmer_Trinimac_ChampionAmbient_Sword` | Sword Arm | Your sword arm is steady. Trinimac made it so. | B |

*Superseded 2026-08-05:* both lines used to lean on "the project" -- defensible as manifest
vocabulary (13.4, 13.8, 13.12), but a word a player reads in its modern sense first. "Trinimac's
weight sits easily on your arm" also implied an item he never gave you. The replacements name the
deed and the god directly. "The project" survives in the Trinimac signal title, where the
surrounding text supplies the sense.

### Syrabane -- gentle, guardian-toned, shields the one still on the path

| EditorID | Name | Description | Variant |
|---|---|---|---|
| `PDV_Notif_Altmer_Syrabane_ChampionAmbient_Ward` | Ward Set | Syrabane's ward is on you, quiet and steady. | A |
| `PDV_Notif_Altmer_Syrabane_ChampionAmbient_Guard` | Long Warded | Syrabane has warded you so long you forget it is there. | B |

The B line is the protection-lane version of long devotion: the ward has become ordinary. It is the
gentlest possible way to say "this has been true for a long time", which is the whole point of the
`MarkHigh` gate.

### General heritage -- the deity-agnostic ancestral spine

| EditorID | Name | Description | Trigger |
|---|---|---|---|
| `PDV_Notif_Altmer_General_HeritageExemplar` | Old Way Kept | You keep the old Altmer way, and you keep it well. | substrate tier HIGH, same cadence |
| `PDV_Notif_Altmer_General_HeritageQuiet` | Old Way Slipped | You have let the old Altmer way slip. | once, on a fall from HIGH |

Written as a matched pair against the Nord precedent `PDV_Notif_Nord_General_AncestorsQuiet` / "The
ancestors are quiet." They name **no god** -- the spine is deity-agnostic per the 2026-08-04 Dawn
Relocation note ("the ordered life every Altmer keeps because they are Altmer"), so these are the two
lines a broad worshipper with no patron can still receive.

They deliberately avoid the visible substrate tier words (`Ordered` / `Disciplined` / `Exemplar`
Heritage), which the player already sees on the substrate readout. Repeating a tier label in an
ambient line would read as a tier change that has not happened.

*Superseded 2026-08-05:* both lines used to turn on "the inheritance", an abstraction the player is
never introduced to. They now say "the old Altmer way", which needs no gloss.

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
