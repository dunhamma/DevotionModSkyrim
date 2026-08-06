# Altmer lane -- consolidated copy sheet

**What this is.** Every player-facing string the Altmer lane ships, in one place, with where each one
lives and what fires it. Written 2026-08-05 after the grammar and legibility pass.

**Authority.** The `.psc` source and the ESP are the truth; this sheet is the readable mirror. Where a
line exists in more than one place, every copy is listed -- **edit them together or they diverge
silently.** Anything not listed here is not Altmer lane copy.

**Rules these follow.** `PDV_STANDARDS.md` Section 3.5 (grammar), `race-sheets/PDV_RaceContent_Manifest.md`
Section 3 (voice by surface), Section 4 (length budgets), Section 13.1 (per-deity tone). ASCII only. No contractions.
Titles carry no terminal punctuation, by design.

---

## 1. Book of Days -- ancestral spine

`GetAltmerHeritageSourceLine()` in `live-source/Scripts/Source/PDV__ManagerQuest.psc`. Narrator
voice, second person. One line per feed, written only when the day's substrate credit actually lands
(one per devotional day whatever claims it), so at most one of these appears per day.

Shape: past-tense report of the act, then a present-tense consequence. That pairing is the
established Book of Days frame, not a tense switch -- see Section 3.5.

| Feed | Line |
|---|---|
| Dawn observance (outdoors, at the turn of the day) | You met the dawn under the open sky. The ordered life asks no more than this. |
| Auri-El shrine rite | You performed the dawn rite as your ancestors have always done. |
| Sleep / Aldmeri dream | You awoke from a dream about the Aldmeri. It leaves an ache within you as you recall the past. |
| Enchanting | You bound magicka into a lasting shape. The binding holds. |
| Smithing | You worked the forge in the manner set down. The craft is older than you. |
| Study | You studied. The quest for knowledge is ingrained in your heritage. |
| Magic skill milestone | You have deepened your magical skills. You are closer to perfection. |
| Ancestral text read | You read an ancestral text closely. What was written is remembered. |
| Practice at the Ancestral Focus | You kept the practice where you stood, with no shrine and no witness. |
| Anything else (default) | You upheld the orthodoxy at real cost. Doctrine stands on what it costs you. |

**Vocabulary is deliberately spread** so a player reading the journal does not meet the same noun
repeatedly: the ordered life, the ancestors, the past, the binding, the craft, knowledge, perfection,
what was written, the practice, doctrine.

**The practice arm is load-bearing.** P14's focus token composes its reason as
`"practice_focus_" + <EventBus reason>`, which matches none of the other arms. Without that branch the
mod's one unlimited daily Altmer act fell to the orthodoxy default -- and for a Psijic or Heterodox
player that asserted the opposite of their theology, every day. Its line is alignment-neutral on
purpose.

---

## 2. Signal surfacings

`SurfaceReservedSignal(deity, title, body)`. The rendered line is `<DeityName> + " " + body`, so the
body is a predicate fragment by design and the full sentence is what the player reads. Fires a Prisma
toast **and** a Book of Days entry from the same text.

| Deity | Title | What the player reads | Fires on |
|---|---|---|---|
| Magnus | The design holds | Magnus marks an enchantment made as the art demands. | Completing an enchantment, once per day |
| Trinimac | The project defended | Trinimac marks the ordered world held against a threat. | Killing a hostile humanoid at ThalmorAlignment 70+, once per day |
| Syrabane | The sickness lifts | Syrabane marks a curse turned aside before it took root. | Curing or warding disease/curse, once per day |
| Syrabane | The ward holds | Syrabane marks hostile magic stopped before it reached you. | A ward absorbing hostile magic, once per day |
| Syrabane | Arcane duel survived | Syrabane marks a hostile mage outlasted and put down. | Surviving a near-fatal mage fight that ends in a kill; weekly by rarity |

Trinimac also carries a sixth, shipped before this lane and unchanged: **Orthodoxy upheld** /
*"marks a costly defense of ancestral doctrine."*

House pattern for this helper: `marks` + a noun phrase with the participle adjacent to its head.
Keep the participle next to what it modifies -- separating them garden-paths the reader.

---

## 3. Book-read notices

`SurfaceP2BookReadNotice(reason, title, body)`. Fires only on a curated book read
(`po3_book` in the reason). Title and body render into **separate journal fields**, so the body must
stand alone -- it cannot open on a pronoun whose antecedent is in the title.

| Title | Body | Fires on |
|---|---|---|
| Trinimac remembered | Trinimac is named as he was, not as he was made. | Reading a curated Trinimac text |
| The first warding | Syrabane opens the apprentice's art to you. | Learning a vanilla Ward tome (one-shot per tome) |

Shipped siblings for reference: *"Auri-El's dawn"* / "The morning rite settles deeper.",
*"The road of Magnus"* / "The discipline of light holds you to the dawn.", *"The scribe Xarxes"* /
"The ancestral record asks more of you."

---

## 4. Champion ambient notifications

Twelve MESG records, `0716E5`-`0716F0`, each mirrored as a fallback literal in the manager. Player
second person, 80 hard / 60 target.

**Only the `Description` reaches the player.** These are shown with `messageRecord.Show()` on a
button-less MESG, which renders the message text as a corner notification -- the `Name` field is an
editor label and is never displayed. Each line therefore has to carry its whole meaning alone, with no
callback to text the player saw hours earlier and no design vocabulary.

`Name` fields were realigned to their bodies on 2026-08-06 (`Dawn Answers`, `Dawns Counted`,
`Study Shows`, `Long Study`, `Name Recorded`, `Life Recorded`, `Line Held`, `Sword Arm`, `Ward Set`,
`Long Warded`, `Old Way Kept`, `Old Way Slipped`). The **EditorIDs were not** -- they are bound to
VMAD properties and the manager's property names, so renaming would mean re-binding all twelve. A few
slots therefore hold a line their EditorID no longer describes (`_ElderWay`, `_Lineage`, `_Watch`).
Navigate by EditorID, read the `Name` to see what the line says.

Fires at dawn on a 4-day cadence per deity, for the **active patron** at Champion or above. The
second variant is gated on `MarkHigh >= 1` -- at least one Long Devotion mark actually earned -- so it
cannot say "you have kept this a long time" to someone who reached Champion four days ago.

| Record | Deity | Standing variant | Long-devotion variant |
|---|---|---|---|
| `0716E5` / `0716E6` | Auri-El | The dawn answers you now, as it answered your ancestors. | You have met every dawn. Auri-El has counted them all. |
| `0716E7` / `0716E8` | Magnus | The spells come easily today. Your study shows. | Magnus has watched you study for a long time now. |
| `0716E9` / `0716EA` | Xarxes | Xarxes has written your name into the record. | Xarxes has kept the record of your whole life. |
| `0716EB` / `0716EC` | Trinimac | You have held the line, and Trinimac saw it. | Your sword arm is steady. Trinimac made it so. |
| `0716ED` / `0716EE` | Syrabane | Syrabane's ward is on you, quiet and steady. | Syrabane has warded you so long you forget it is there. |

Two deity-agnostic heritage records on the same cadence, reaching a broad worshipper with no patron
at all:

| Record | Line | Fires on |
|---|---|---|
| `0716EF` | You keep the old Altmer way, and you keep it well. | Substrate tier HIGH, 4-day cadence |
| `0716F0` | You have let the old Altmer way slip. | Once, on falling from HIGH |

Each line lives in **three** places: the ESP record, the `.psc` fallback in
`ShowChampionAmbientForDeity` / `RunDawnAltmerHeritageAmbient`, and
`handoff/PDV_Altmer_P11_NotificationCopy_2026-08-04.md`. The fallback only renders when a `Message`
property comes back `None`, so an ESP-only edit looks correct in normal play and diverges silently.

---

## 5. Cross-race lines that surface on the Altmer lane

Listed because they appear in an Altmer playthrough, **not** because they are Altmer copy. Editing
either changes every race.

| Line | Scope |
|---|---|
| `<Deity>` marks devotion held long past the day it was proven. | Long Devotion mark, post-Champion, per 15 piety above the threshold, max 7. `MaybeSurfaceDevotionMark` runs for the active patron of **any** race. |
| The wind is blowing your way. | Nord/Kyne, registered in the same ambient dispatcher as the twelve above. |

---

## 6. Items

| Record | Name | Note |
|---|---|---|
| `0716E4` | Ancestral Focus | The daily practice token. Renamed from "Ordered Focus", which collided with the visible substrate tier name `Ordered Heritage` and so read as tier-gated when it works at every tier. Names the inheritance rather than one god, which suits a deity-agnostic spine, and parallels the Dunmer `Ancestral Urn`. **Mesh is still a placeholder** -- vanilla `Dungeons\Mines\Ore\IngotMoonstone.nif`. |

---

## 7. Not on this sheet

- **Tier-up, lapse, neglect texture, Lorkhan pressure and ThalmorAlignment band notifications.**
  `PDV_RaceContent_Manifest.md` Sections 13.3, 13.5, 13.6, 13.7 author 15 further `PDV_Notif_Altmer_*` slots.
  None is built; they are a separate wave with separate triggers.
- **Blessing descriptions, commitment offers, Champion entries, Survey readouts, curse-state
  transitions.** Authored in manifest Sections 13.2, 13.4, 13.8, 13.9, 13.10. Those are shipped from the
  reward spec JSONs and the offer MESG records, not from this lane's work.
- **Manifest Section 13.4 is out of date with the ESP** -- it documents a Magnus ambient slot that does not
  exist and predates ten of the twelve records above. A drift note sits in that section.
