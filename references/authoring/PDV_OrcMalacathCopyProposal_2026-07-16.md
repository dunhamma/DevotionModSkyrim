# Orc Malacath Copy Proposal (2026-07-16)

Status: **LANDED 2026-07-16** in a Skyrim-closed window. All 17 ESP edits applied
IN PLACE to `Devotion.esp` via `housecarl_bulk_apply` (all-or-nothing, every record
re-read and verified off the written file); spec + manager updated; manager and
PDV_MCM compiled 0/0; verifier FAIL=0; Prisma UI audit 121 PASS; Book of Days audit
PASS=126 FAIL=0. Pre-edit backup:
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\orc-copy-pass\Devotion.esp.20260716-165127.bak`
(houseCARL's in-place lane keeps no undo of its own). Runtime confirmation of the new
names/text in Active Effects is still owed on the next launch.

Raised mid felt-family co-test session
after "Code-Held" / "Forge-Worthy" read as awkward in Active Effects. Lore
anchors pulled verbatim from live Skyrim.esm via houseCARL, not memory:

- `07EBC9:Skyrim.esm` "The Code of Malacath" (in-game book): "if something is
  not worth fighting for it is beneath the Code"; "All their weapons and armor
  are smithed right there in the stronghold"; "Every man, woman, and child
  inside the walls is trained from birth to defend it"; the stronghold-vs-city
  distinction -- "Imperial Law allows you to settle fights through the
  Emperor's men, but the Code of Malacath demands you settle your problems
  yourself."
- `01AD16:Skyrim.esm` "The True Nature of Orcs": Malacath's own sphere is
  "the patronage of the spurned and ostracized, **the sworn oath**, and the
  bloody curse." -- source of the "Sworn" naming.

## Names (already agreed, noted here for the full record)

| Current | Proposed | FormID |
|---|---|---|
| Code-Held - Stronghold | Hold-Sworn - Stronghold | 0715A2:Devotion.esp |
| Code-Held - City | Hearth-Sworn - City | 07159F:Devotion.esp |
| Code-Held - Legion Exile | Legion-Sworn - Legion Exile | 0715A5:Devotion.esp |
| Forge-Worthy - Seeker | Hold-Forged - Seeker | spec: PDV_OrcRewardRecords.spec.json:159 |
| Forge-Worthy - Devoted | Hold-Forged - Devoted | spec: PDV_OrcRewardRecords.spec.json:177 |

All names APPROVED 2026-07-16, including the City/Legion Exile Spine parity
renames (blanket-approved along with the rest of this proposal).

## Effect text (Description field on the MGEFs / playerFacingText in spec)

Only touching lines that were genuinely weak or now mismatch the renamed
title. Everything not listed below reviewed and judged fine as-is (see
"Reviewed, no change" at the bottom) -- not touching for the sake of touching.

| Slot | FormID / spec ref | Current | Proposed | Why |
|---|---|---|---|---|
| Spine Stronghold (both effects share this desc) | `0715A0`/`0715A1`:Devotion.esp | "The code holds where forge and kin stand near. Armor +8, Maximum Health +10." | "You are sworn to the hold, and the hold to you. Armor +8, Maximum Health +10." | Matches the Hold-Sworn rename; reciprocal oath language ties directly to Malacath's sphere ("the sworn oath") instead of the vaguer "code holds" template. |
| Spine City | `07159D`:Devotion.esp | "The code holds under stone and strangers. Armor +5, Maximum Health +10." | "You keep your oath quietly, under stone and strangers' eyes. Armor +5, Maximum Health +10." | Same oath-language pass; "quietly" nods at the book's stronghold-vs-city split without repeating the City T1 line ("You keep the code where no stronghold can see it") verbatim. |
| Spine Legion Exile | `0715A3`:Devotion.esp | "The code holds under foreign order and exile. Armor +5, Maximum Health +15." | "Far from kin and under foreign order, the oath still holds. Armor +5, Maximum Health +15." | Same pass, keeps the distance-from-kin note already established by the T1/T3 flavor for this family. |
| Stronghold T2 (Hold-Forged - Devoted) | spec:190 | "Worthy work and worthy war-gear. Smithing +13, Two-Handed +8." | "The forge does not lie: what you make, you become. Smithing +13, Two-Handed +8." | "Worthy" was already carrying T1's title (Forge-Worthy) and reappears here twice in one sentence -- reads redundant across the ladder. New line leans on the book's own smith-identity framing instead. Stat suffix re-synced 2026-07-16 after the HeavyArmor -> TwoHanded swap; prose unaffected. |
| City T2 (Private Fidelity - Devoted) | spec:261 | "Dignity held under pressure is its own kind of strength. Speech +13, Restoration +8." | "Imperial law watches; the Code answers to no one else. Speech +13, Restoration +8." | APPROVED 2026-07-16. Direct lift of the book's actual contrast (Imperial Law vs. the Code) rather than a generic "dignity/strength" line. Stat suffix re-synced 2026-07-16 after the Speech-leads swap; prose unaffected. |
| Neglect (The Code Goes Unkept) | spec:79 | "You have not kept Malacath's code. Your guard feels thin; your armor rating drops by 5 until you return to worthy work, service, or kin." | "The Code goes unkept. Your guard feels thin; armor drops by 5 until you return to worthy work, service, or kin." | FINAL 2026-07-16 (shortened from first draft, user-approved). Trims the direct book-echo clause for pacing; keeps "worthy work, service, or kin" as the lone lore tie. |

## Reviewed, no change recommended
Malacath's Regard - Observant/Faithful (spec:126/147); Stronghold T1 body
(spec:167, already ties Smithing to the forge correctly) and T3 "Blood-Kin of
the Forge" (spec:218, strong as-is); City T1/T3 (spec:237/297); Legion Exile
T1/T2/T3 (spec:316/340/375); Code Holds Seeker/Devoted (spec:516/538);
Hearth-Held (spec:556); all four Trial of Iron discipline lines
(spec:458/472/486/500) and its Book of Days/toast lines ("You took up a
discipline in the Trial of Iron. The Code is held in iron." /
"You take up a discipline of the Code. The Trial of Iron holds you to it.").
These already read clean and consistent; left untouched per scoped-change
practice. Note: City T1/T3 and Stronghold T3 prose is still endorsed as-is, but
their stat suffixes changed on 2026-07-16 (Stronghold HeavyArmor -> Two-Handed;
City Speech promoted to lead, Restoration to secondary). The live records already
carry the new suffixes -- when applying this proposal, take the PROSE only and
leave the stat lists as they now stand in the ESP.

## Hearth-Held notices -- surfacing + reword (added 2026-07-16, from co-test)

Observed in co-test: the first-time hearth DECLARE moment surfaces only as a
top-left corner notification and never chronicles. It is a once-ever milestone
(guarded by `PDV.Orc.HearthHeldDeclared == 0`) -- declaring your hearth deserves
a permanent Book of Days beat + a toast, like other milestone reaches.

**CORRECTION (2026-07-16, found at wire-in time).** The first draft of this
section quoted the manager's INLINE FALLBACK strings as the "current" text. Those
fallbacks never display: `ShowOrcNotification(messageRecord, fallbackText)` shows
the ESP Message RECORD whenever it exists and ignores the fallback. The real
displayed text was different, and only the DECLARE line actually said "code":

| Record | Text as it really shipped | Verdict |
|---|---|---|
| `071544` Declare | "This place can hold the code if you keep returning to it." | the line the owner saw; REWORDED |
| `071545` Return | "You came back to the place you made. The oath has a roof for now." | already oath-language, no "code" -- LEFT ALONE |
| `071546` MissedCadence | "The place is still there, but the habit has gone thin." | no "code" -- LEFT ALONE |

So the Return/MissedCadence rewords in the first draft were unnecessary and were
NOT applied. Lesson: read the live record, not the fallback, before proposing copy.

What LANDED:
- **Declare**: manager `MaybeShowOrcHearthHeldNotice` now emits
  `SendPrismaToast("malacath","good","A hearth held","You claim this hearth as your
  own, and swear to hold it.")` + `AppendBookOfDaysEntry(<same line>, ...,
  "substrate.act", "malacath", False)`, and NO LONGER calls `ShowOrcNotification`
  (that would double the surface). The toast honours the Notifications preference at
  the shared chokepoint (`SendPrismaToastPayloadOrFallback` -> `NotificationsEnabled`)
  while the Book of Days entry always logs -- matching the shipped 1.0 MCM rule.
  `PDV_Notif_Orc_HearthHeld_Declare` (`071544`) is now ORPHANED but its Description
  was updated to the same new line so the ESP carries no stale "code" phrasing.
- **Return** / **MissedCadence**: untouched, still corner notifications (daily-gated
  ambient reminders; a BoD entry would spam the Chronicle).

## What landed (2026-07-16) -- record of the applied change

ESP (17 edits, one `housecarl_bulk_apply` IN PLACE on `Devotion.esp`, all-or-nothing,
every record verified off the written file):

| FormID | Record | Change |
|---|---|---|
| `0715A2` | PDV_Bless_Orc_Spine_Stronghold | Name -> "Hold-Sworn - Stronghold" |
| `07159F` | PDV_Bless_Orc_Spine_City | Name -> "Hearth-Sworn - City" |
| `0715A5` | PDV_Bless_Orc_Spine_LegionExile | Name -> "Legion-Sworn - Legion Exile" |
| `07112F` | PDV_Bless_Orc_Stronghold_T1 | Name -> "Hold-Forged - Seeker" |
| `071132` | PDV_Bless_Orc_Stronghold_T2 | Name -> "Hold-Forged - Devoted" |
| `0715A0` + `0715A1` | Spine_Stronghold Armor/Health MGEFs | Description -> sworn-to-the-hold line |
| `07159D` + `07159E` | Spine_City Armor/Health MGEFs | Description -> oath-quietly line |
| `0715A3` + `0715A4` | Spine_LegionExile Armor/Health MGEFs | Description -> far-from-kin line |
| `071130` + `071131` | Stronghold_T2 Smithing/TwoHanded MGEFs | Description -> forge-does-not-lie line |
| `071139` + `07113A` | City_T2 Speech/Restoration MGEFs | Description -> Imperial-law line |
| `071128` | MGEF_Neglect_Orc_DamageResist | Description -> shortened neglect line |
| `071544` | Notif_Orc_HearthHeld_Declare | Description -> new hearth line (now orphaned; kept in sync) |

Note both effects of every two-effect spell share one description string, so each
pair was updated together -- otherwise Active Effects shows two different texts for
the same boon.

Spec `PDV_OrcRewardRecords.spec.json`: `displayName` x2 (Hold-Forged Seeker/Devoted)
and `playerFacingText` x3 (Stronghold T2, City T2, neglect). Stat suffixes were taken
from the CURRENT live values (`Two-Handed +8`, `Speech +13, Restoration +8`) -- a
parallel session had swapped them and the stale line numbers in the first draft no
longer resolved; the prose changed, the stat lists did not.

Manager `PDV__ManagerQuest.psc`: the Declare surfacing change described above.

Gates after the change: manager + PDV_MCM compile 0/0 (MCM recompiled per the
manager->MCM pex-freshness rule); `pdv_verify` FAIL=0 WARN=2 (both pre-existing
SEQ-freshness); `pdv_prisma_ui_audit` 121 PASS; `pdv_book_of_days_audit` PASS=126
WARN=0 FAIL=0; ASCII guard clean across 96 `.psc`.

## Still owed

- Runtime confirmation on next launch: the five renamed boons read correctly in
  Active Effects, and a fresh sleep-declare fires the new toast + Book of Days beat
  (needs a save whose `PDV.Orc.HearthHeldDeclared` is still 0, i.e. a hearth not yet
  declared -- the flag is once-ever, so the already-declared test save will NOT
  re-fire it).
- The renames change player-facing strings that the race guide and Nexus article
  may quote -- check `docs/player-guides/races/Orc.md` and `dist/nexus-articles/Orc.bb`
  for "Code-Held" / "Forge-Worthy" at doc-sync.
