# PDV Phase 20 — Expanded Signal Architecture

**Created:** 2026-06-03
**Status:** Architecture proposal — no ESP writes authorized until user approval
**Companion files:**
- `PDV_Phase20_P2ImmersiveReceivers.manifest.json` — current approved fills
- `PDV_Phase20_SourceCurationDossier.md` — quest-stage readback source
- `PDV_Phase20_P2SourceCuration_Runbook.md` — fill rules and hard stops

---

## Purpose

The initial P2 fill tranche approved 12 book-read sources across 4 races (Breton,
Dunmer, Imperial, Nord). The remaining 6 races (Altmer, Argonian, Bosmer,
Khajiit, Orc, Redguard) have no P2 FLST properties at all.

This document proposes two expansion tranches:

**Tranche A — Fill expansion** for the existing 17 wired Breton/Dunmer/Imperial/Nord
FLSTs. Additional books and quest-stage entries aligned to each race's theological
structure and route families.

**Tranche B — New FLST proposals** for the 6 races with no P2 receivers. New
`PDV_FLST_P2_*` property shells, route assignments, book candidates, and quest-stage
candidates. These require new shell creation before any fill can run.

**Anti-farm policy remains unchanged.** Books: one-shot per formKey per character.
Quest stages: one-shot per terminal/source-marked stage. Daily piety cap applies
via dawn processing regardless of how many signals fire.

---

## Status Legend

| Field | Values |
|---|---|
| `semanticVerdict` | `strong`, `plausible`, `weak` |
| `implementationStatus` | `approved-for-fill`, `receiver-needed`, `needs-stage-readback`, `manual-only` |
| Tranche | `A` = existing FLST expansion; `B` = new FLST required |

`receiver-needed` means the FLST shell exists or is proposed, but a compatible
quest-stage receiver branch must be built before the entry can go live.
`needs-stage-readback` means the exact completion stage or branch split still
requires xEdit confirmation before the entry can be safely gated.

---

## Tranche A — Existing FLST Expansion

### A1 — Breton

#### Currently approved (reference)

| FLST property | Book | FormKey | Status |
|---|---|---|---|
| `PDV_FLST_P2_BretonHiddenArtSources` | Herbane's Bestiary: Hagravens | `Skyrim.esm:0ED60B` | approved-for-fill |
| `PDV_FLST_P2_BretonHiddenArtSources` | The Madmen of the Reach | `Skyrim.esm:07EB03` | approved-for-fill |
| `PDV_FLST_P2_BretonHiddenArtSources` | Anise's Letter (dunPOIWitchNote) | `Skyrim.esm:0DDFB6` | approved-for-fill |

#### Proposed additional books

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_BretonHiddenArtSources` | Spirit of the Daedra | `Skyrim.esm:01AD15` | `Book4RareSpiritoftheDaedra` | `strong` | First-person Daedra voice; pure forbidden-knowledge exposure. No generic Daedric spell context. |
| `PDV_FLST_P2_BretonHiddenArtSources` | N'Gasta! Kvata! Kvakis! | `Skyrim.esm:01AD0E` | `Book4RareNGastaKvataKvakis` | `strong` | Necromantic Sload language text; illicit practice; excellent Hidden Art signal. |
| `PDV_FLST_P2_BretonHiddenArtSources` | Souls, Black and White | `Skyrim.esm:01AD0C` | `Book4RareSoulsBlackAndWhite` | `strong` | Soul-trap and necromancy lore; hidden knowledge about mortality and soul trade. |
| `PDV_FLST_P2_BretonHiddenArtSources` | The Book of Daedra | `Skyrim.esm:01ACC8` | `Book2CommonBookofDaedra` | `plausible` | Catalogue of Daedric Princes; scholarly occult. Broad, but explicitly Daedric content rather than generic magic. |
| `PDV_FLST_P2_BretonHiddenArtSources` | Varieties of Daedra | `Skyrim.esm:01ACFC` | `Book3ValuableVarietiesofDaedra` | `plausible` | Taxonomy of Daedra; forbidden scholarly classification. Pair with The Book of Daedra for coverage. |

**Rejected from HiddenArt:** Generic spell tomes, College-of-Winterhold errand texts,
enchanting manuals. Skyrim's alchemy books are not Hidden Art — they are herbalism.

#### Proposed quest-stage fills

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_BretonHiddenArtSources` | The Eye of Magnus (MG08) | `Skyrim.esm:01F258` | `200` | `plausible` | `receiver-needed` | Psijic/Magnus crisis stewardship. One-shot finale only; not generic College membership. Breton Hidden Art framing: occult power contained, not exploited. |
| `PDV_FLST_P2_BretonKnightsRoadSources` | Bloodline / Dawnguard join (DLC1VQ02) | `Dawnguard.esm:002F65` | TBD — Dawnguard branch | `strong` | `needs-stage-readback` | Refusing Harkon's gift = Stendarr-Arkay protection / Knight's Road commitment. Branch stages need side-specific xEdit confirmation: distinguish 180/190/200 by Dawnguard vs. Volkihar path. |
| `PDV_FLST_P2_BretonGreenWaySources` | *(no strong quest candidate yet)* | — | — | — | — | Green Way prefers harvest/weather/location hooks. No current quest stage meets the strict curated-site requirement without custom content. Defer to post-1.0 enrichment. |

**Mutual exclusion (Breton/DLC1VQ02):** DLC1VQ02 Dawnguard branch feeds
`BretonKnightsRoadSources`. The Volkihar branch of the same quest FormKey feeds
Breton deviation / Dunmer deviation. These are mutually exclusive by stage — gate
on exact stage number, not quest form alone.

---

### A2 — Dunmer

#### Currently approved (reference)

| FLST property | Book | FormKey | Status |
|---|---|---|---|
| `PDV_FLST_P2_DunmerAzuraSources` | Invocation of Azura | `Skyrim.esm:01B245` | approved-for-fill |
| `PDV_FLST_P2_DunmerAzuraSources` | Azura and the Box | `Skyrim.esm:01ACE9` | approved-for-fill |
| `PDV_FLST_P2_DunmerBoethiahSources` | Boethiah's Glory | `Skyrim.esm:01B233` | approved-for-fill |
| `PDV_FLST_P2_DunmerBoethiahSources` | Boethiah's Proving | `Skyrim.esm:032E72` | approved-for-fill |

#### Proposed additional books

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_DunmerMephalaSources` | The Night Mother's Truth | `Skyrim.esm:0E0D67` | `Book4RareNightMother` | `strong` | Mephala is the original Dunmer Night Mother (pre-Sithis reinterpretation). This text's theological content is directly Mephala-coded for a Dunmer reader. |
| `PDV_FLST_P2_DunmerAzuraSources` | The Reclamations | `Dragonborn.esm:03B052` | `DLC2Book2CommonTheReclamations` | `strong` | Directly names the Reclamations (Azura, Boethiah, Mephala) as a theological framework. Strongest broad-Reclamation devotional text in the game. Placed in AzuraSources as Azura is the primary Reclamation face. |
| `PDV_FLST_P2_DunmerAzuraSources` | Ancestors and the Dunmer | `Skyrim.esm:01B22D` | `Book2ReligiousAncestorsandtheDunmer` | `plausible` | Core Dunmer ancestor-reverence text; the ancestor layer underpins all Reclamation faith. Weak on its own but strong as cultural/devotional grounding alongside Azura texts. |

**Rejected from Dunmer:** A Short History of Morrowind (weak — general history, not
devotional), War of the First Council (historical conflict text, not piety signal),
Dunmer of Skyrim (exile identity, no Reclamation hook), Hope of the Redoran
(Redoran house politics, not Reclamation theology).

#### Proposed quest-stage fills

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_DunmerAzuraSources` | The Black Star (DA01) | `Skyrim.esm:028AD6` | `100` | `strong` | `receiver-needed` | Stage 100 = Azura's Star restored. Direct Reclamation confirmation. Mutually exclusive with stage 110. |
| `PDV_FLST_P2_DunmerDeviationSources` | The Black Star (DA01) | `Skyrim.esm:028AD6` | `110` | `strong` | `receiver-needed` | Stage 110 = Black Star completed (soul gem corruption). Deviation/rival-Prince pressure signal for Dunmer. Mutually exclusive with stage 100. |
| `PDV_FLST_P2_DunmerBoethiahSources` | Boethiah's Calling (DA02) | `Skyrim.esm:04D8D6` | `100` | `strong` | `receiver-needed` | Quest completion = champion proof. Stage 100 is the terminal Boethiah-champion outcome. Not combined with generic sacrifice/betrayal; quest-stage ownership replaces item-ownership for this signal. |
| `PDV_FLST_P2_DunmerDeviationSources` | Temple of Miraak (DLC2MQ02) | `Dragonborn.esm:017F8F` | `200` | `strong` | `needs-stage-readback` | First Apocrypha / Mora identity-theft threshold. Stage 200 is completion; exact stage meaning for mid-quest Mora-pressure beats needs xEdit confirmation before gating. |
| `PDV_FLST_P2_DunmerDeviationSources` | The Gardener of Men (DLC2MQ05) | `Dragonborn.esm:0179DE` | `1000` | `strong` | `needs-stage-readback` | Storn / Skaal secrets bargain. Stage 1000 is completion. Mora community-cost deviation. Confirm stage 1000 is the correct terminal; only fire once. |
| `PDV_FLST_P2_DunmerDeviationSources` | At the Summit of Apocrypha (DLC2MQ06) | `Dragonborn.esm:0179D7` | `550` | `plausible` | `needs-stage-readback` | Miraak defeat / Solstheim liberation. Stage 550 is completion. Plausible deviation resolution signal; confirm it does not double-score with DLC2MQ02/05 path. |
| `PDV_FLST_P2_DunmerDeviationSources` | Bloodline — Volkihar branch (DLC1VQ02) | `Dawnguard.esm:002F65` | TBD | `strong` | `needs-stage-readback` | Accepting Harkon's gift = curse/vampirism as deviation pressure. Branch stage must be isolated from Dawnguard-side stages. Do not score both branches. |

**Note on DLC2RR01/02/03 (Raven Rock quests):** These are `manual-only` per the
dossier. Raven Rock community/ancestor signals are strong for a future Dunmer
ancestor-community hook but do not map cleanly to current Reclamation FLSTs.
Defer to later enrichment phase.

---

### A3 — Imperial

#### Currently approved (reference)

| FLST property | Book | FormKey | Status |
|---|---|---|---|
| `PDV_FLST_P2_ImperialPublicTalosSources` | The Talos Mistake | `Skyrim.esm:0ED04D` | approved-for-fill |

#### Proposed additional books

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_ImperialCivicSources` | The Great War | `Skyrim.esm:0F456D` | `Book2CommonGreatWar` | `strong` | Contemporary Imperial military-legacy text; the Concordat cost is explicit. Strong civic identity signal — not generic history, but the living wound of what the Empire agreed to. |
| `PDV_FLST_P2_ImperialCivicSources` | Brief History of the Empire, v1 | `Skyrim.esm:01ACB9` | `Book1CheapBriefHistoryoftheEmpirev1` | `plausible` | Imperial genealogical/civic identity. Light one-shot context. Pair the series as four separate one-shots to give early-game book depth. |
| `PDV_FLST_P2_ImperialCivicSources` | Brief History of the Empire, v2 | `Skyrim.esm:01ACBA` | `Book1CheapBriefHistoryoftheEmpirev2` | `plausible` | Continued Imperial dynastic context. |
| `PDV_FLST_P2_ImperialCivicSources` | Brief History of the Empire, v3 | `Skyrim.esm:01ACBB` | `Book1CheapBriefHistoryoftheEmpirev3` | `plausible` | Continued. |
| `PDV_FLST_P2_ImperialCivicSources` | Brief History of the Empire, v4 | `Skyrim.esm:01ACBC` | `Book1CheapBriefHistoryoftheEmpirev4` | `plausible` | Continued. Dragonborn crisis context makes v4 most relevant. |
| `PDV_FLST_P2_ImperialCivicSources` | Gods and Worship | `Skyrim.esm:01ACD5` | `Book2CommonOverviewofGodsandWorship` | `plausible` | Nine Divines civic religion overview. Plausible as cultural/devotional grounding; weaker than quest-stage civic signals. |

**Rejected from Imperial Civic:** Life of Uriel Septim VII (too generic as civic
text without Concordat/Talos pressure hook), The Song of Pelinal series (Pelinal is
Shezarrine/Lorkhan-adjacent; poor fit for Imperial civic vs. Altmer Lorkhan penalty;
file under future Altmer Lorkhan signal surface if needed).

**Note on Private Talos sources:** No strong book candidates exist for
`PDV_FLST_P2_ImperialPrivateTalosSources`. Private Talos pressure requires quest/
dialogue proof of secrecy — a book is inherently public-facing. Leave this FLST for
quest-stage fills only.

#### Proposed quest-stage fills

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_ImperialCivicSources` | Joining the Legion (CW01A) | `Skyrim.esm:0D517A` | `200` | `strong` | `manual-only` | Legion oath = concrete public civic alignment. Stage 200 is completion. `manual-only` because the receiver needs to distinguish oath-taking from generic faction attendance; cannot rely on PO3 quest-stage receiver alone without scripted validation. |
| `PDV_FLST_P2_ImperialPublicTalosSources` | Joining the Stormcloaks (CW01B) | `Skyrim.esm:0E2D29` | `200` | `strong` | `manual-only` | Stormcloak oath = public Talos defiance / Concordat rupture. For an Imperial character, this is the maximum public-pressure signal — joining against the Empire in Talos's name. `manual-only`: same scripted validation requirement as CW01A. |

**Mutual exclusion (CW01A / CW01B):** These quests are mutually exclusive in vanilla.
An Imperial player who completed CW01A cannot also complete CW01B. Gate both as
one-shot, and flag the character's choice so receivers know which side was taken.

---

### A4 — Nord

#### Currently approved (reference)

| FLST property | Book | FormKey | Status |
|---|---|---|---|
| `PDV_FLST_P2_NordOldWaysSources` | Nords Arise! | `Skyrim.esm:0ED161` | approved-for-fill |
| `PDV_FLST_P2_NordOldWaysSources` | A Dream of Sovngarde | `Skyrim.esm:0ED02F` | approved-for-fill |
| `PDV_FLST_P2_NordOldWaysSources` | Sovngarde: A Reexamination | `Skyrim.esm:0E2FC6` | approved-for-fill |
| `PDV_FLST_P2_NordHircineArkaySources` | The Totems of Hircine | `Skyrim.esm:0F683F` | approved-for-fill |

#### Proposed additional books

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_NordOldWaysSources` | Nords of Skyrim | `Skyrim.esm:0E0D66` | `Book2CommonNordsOfSkyrim` | `strong` | Direct Nord religious and cultural identity text; Kyne, ancestor reverence, hold traditions. Strong Old Ways signal. |
| `PDV_FLST_P2_NordOldWaysSources` | Five Songs of King Wulfharth | `Skyrim.esm:01AD05` | `Book4RareFiveSongsofKingWulfharth` | `strong` | Wulfharth is a mythic expression of the Thu'um and Nordic divinity — Ysmir, Dragonborn, Talos precursor. Reading his songs is an Old Ways act of ancestor memory. |
| `PDV_FLST_P2_NordOldWaysSources` | The Old Ways | `Skyrim.esm:01AD0F` | `Book4RareOldWays` | `strong` | Named directly for the signal family it feeds. Shalidor's account of pre-Imperial Nord practice. Unambiguous one-shot Old Ways signal. |
| `PDV_FLST_P2_NordKyneTalosSources` | Children of the Sky | `Skyrim.esm:01AD03` | `Book4RareChildrenoftheSky` | `strong` | Kyne/Kynareth as the mother of all Nords; the sky-covenant with mankind. Kyne-focused theology — natural home is NordKyneTalosSources rather than OldWays. |

#### Proposed quest-stage fills

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_NordOldWaysSources` | Dragon Rising (MQ104) | `Skyrim.esm:02610C` | `160` | `strong` | `receiver-needed` | First public Dragonborn proof and Whiterun recognition. For a Nord, this is the Old Ways awakening — the thing the ancestors carried forward is happening again. One-shot milestone only; do not combine with generic dragon routes. |
| `PDV_FLST_P2_NordOldWaysSources` | Sovngarde (MQ304) | `Skyrim.esm:046EF1` | `200` | `strong` | `receiver-needed` | Sovngarde entry and Shor permission. For a Nord, this is the ultimate Old Ways proof — the afterlife is real. One-shot terminal. |
| `PDV_FLST_P2_NordKyneTalosSources` | The Way of the Voice (MQ105) | `Skyrim.esm:0242BA` | `160` | `strong` | `receiver-needed` | Greybeard recognition and disciplined Voice learning. Kyne gifted the Voice; this is Kyne's endorsement of the player through her disciples. One-shot milestone; not every shout use. |
| `PDV_FLST_P2_NordKyneTalosSources` | Joining the Stormcloaks (CW01B) | `Skyrim.esm:0E2D29` | `200` | `strong` | `manual-only` | Stormcloak oath as public Talos / Nord identity pressure. For a Nord, Talos is an ancestor made divine — joining the Stormcloaks is an explicit act of ancestral loyalty. `manual-only`: requires scripted oath-validation. |
| `PDV_FLST_P2_NordHircineArkaySources` | The Silver Hand (C03) | `Skyrim.esm:01CEF4` | `200` | `strong` | `receiver-needed` | Beast-blood transition and Circle ascension. Hircine pressure threshold. One-shot transition marker; curse-state route must not double-score with generic werewolf signals. Stage 25 records the beast-blood gift specifically. |
| `PDV_FLST_P2_NordHircineArkaySources` | Glory of the Dead (C06) | `Skyrim.esm:01CEF6` | `200` | `strong` | `receiver-needed` | Kodlak cure, death-order restoration, Sovngarde honor. Arkay-edge: the cure is a return to Arkay's cycle. One-shot cure/restoration marker. |
| `PDV_FLST_P2_NordHircineArkaySources` | Ill Met By Moonlight (DA05) | `Skyrim.esm:02A49A` | `100` | `strong` | `receiver-needed` | Kill Sinding = follows Hircine's hunt law. Mutually exclusive with stage 105 (defend Sinding). One-shot final-choice only. |
| `PDV_FLST_P2_NordHircineArkaySources` | Ill Met By Moonlight (DA05) | `Skyrim.esm:02A49A` | `105` | `strong` | `receiver-needed` | Defend Sinding = defies Hircine, honors Arkay-adjacent mercy. Mutually exclusive with stage 100. Fire only the stage that actually completed; never score both. |

**Mutual exclusion (C03/C06):** Completing C06 (cure) implicitly resolves the
Hircine pressure from C03. Both can score as separate one-shot milestones — they
are sequential, not competing — but the curse-state route must not independently
score the ongoing werewolf condition as a repeated signal.

---

## Tranche B — New FLST Proposals

These races have no P2 FLST properties. All entries below require:
1. New `PDV_FLST_P2_*` FLST shells to be created in the ESP
2. New alias properties on `PDV_Player` wired to those shells
3. Receiver branches in `PDV_PlayerEvents.psc` for quest-stage routing
4. Then standard fill-tool approval pass

Propose these to the fill tool in a future Phase 21 manifest.

---

### B1 — Altmer

**Theological context:** Auri-El foundation always active. Three faction alignments
(Thalmor Orthodox, Divine Body, Psijic Tradition) shape scoring weights but all use
the same FLSTs. Lorkhan Adjacency Penalties are a unique negative-piety surface —
they need their own FLST family routed to the penalty function, not the gain function.

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_AltmerAurielSources` | `PDV_EventBus.RouteAltmerAurielFoundation(sourceId)` | book, quest-stage | Auri-El-specific texts, Dawnguard Auriel relic stages, Psijic-adjacent ordered-return content |
| `PDV_FLST_P2_AltmerMagnusSources` | `PDV_EventBus.RouteAltmerMagnusScholarship(sourceId)` | book, quest-stage, spell-learned | Magic scholarship texts, College/Eye of Magnus stages, arcane milestone markers |
| `PDV_FLST_P2_AltmerXarxesSources` | `PDV_EventBus.RouteAltmerXarxesLineage(sourceId)` | book, quest-stage | Ayleid/Aldmeri lineage texts, genealogy/record-keeping quest stages |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | `PDV_EventBus.RouteAltmerLorkhanPenalty(tier, sourceId)` | quest-stage, book | Curated Lorkhan-tier-tagged penalty triggers only; routes to piety subtraction, not gain |

#### Proposed book candidates

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_AltmerAurielSources` | The Adabal-a | `Skyrim.esm:01AF94` | `Book4RareAdabala` | `strong` | Directly addresses Auri-El and Aldmeri ancestral theology. Foundational devotional text. |
| `PDV_FLST_P2_AltmerAurielSources` | Fragment: On Artaeum | `Skyrim.esm:01AD06` | `Book4RareFragmentOnArtaeum` | `strong` | Psijic Order text about Artaeum's removal from Nirn. Direct Psijic Tradition signal for Altmer. |
| `PDV_FLST_P2_AltmerMagnusSources` | Arcana Restored | `Skyrim.esm:01ACFE` | `Book4RareArcanaRestored` | `strong` | Arcane scholarship and restoration of magical knowledge. Magnus domain. |
| `PDV_FLST_P2_AltmerMagnusSources` | Magic from the Sky | `Skyrim.esm:01ACF1` | `Book3ValuableMagicFromTheSky` | `strong` | Magical theory and sky-origin of magic. Direct Magnus-school devotional text. |
| `PDV_FLST_P2_AltmerXarxesSources` | Last King of the Ayleids | `Skyrim.esm:01AD09` | `Book4RareLastKingOfAyleids` | `strong` | Ayleid heritage and lineage; ancestor record-keeping. Xarxes domain (genealogy, records, hidden lineage). |
| `PDV_FLST_P2_AltmerXarxesSources` | Treatise on Ayleidic Cities | `Skyrim.esm:01ADB4` | `Book4RareNefarivigumLore` | `plausible` | Aldmeri scholarly heritage. Plausible as lineage/record scholarship for Xarxes. |
| `PDV_FLST_P2_AltmerXarxesSources` | An Accounting of the Scrolls | `Skyrim.esm:0ED03A` | `Book4RareAccountingOfTheElderScrolls` | `plausible` | Elder Scrolls scholarship. Rare knowledge preservation — Xarxes-adjacent as keeper of hidden records. |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | *(see quest-stage table; books are not the primary penalty surface)* | — | — | — | — |

**Rejected from Altmer books:** Chimarvamidium (Dwarven tales — Dwemer are Lorkhan-
adjacent Tier 4; unclear theological ownership), generic magic texts without explicit
Magnus/Auri-El coding, Nine Divines devotional texts (these are Lorkhan Tier 3
penalties, not positive Altmer signals).

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | tier/type | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_AltmerMagnusSources` | The Eye of Magnus (MG08) | `Skyrim.esm:01F258` | `200` | positive | `plausible` | `receiver-needed` | Psijic removal of the Eye / Arch-Mage appointment. Magic stewardship. Not generic College attendance. |
| `PDV_FLST_P2_AltmerAurielSources` | Touching the Sky (DLC1VQ07) | `Dawnguard.esm:002853` | `200` | positive | `strong` | `needs-stage-readback` | Acquiring Auriel's Bow. Direct Auri-El relic signal. Confirm stage 200 is the bow-acquisition completion; review branch text for Dawnguard-side vs. any Volkihar context. |
| `PDV_FLST_P2_AltmerAurielSources` | Kindred Judgment (DLC1VQ08) | `Dawnguard.esm:007C25` | `200` | positive | `strong` | `needs-stage-readback` | Harkon defeated. Auri-El versus Molag Bal final outcome. Dawnguard-side only; confirm stage isolates Dawnguard completion from Volkihar completion. |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | Dragon Rising (MQ104) | `Skyrim.esm:02610C` | `160` | penalty T2 | `strong` | `receiver-needed` | Dragonborn declaration = Lorkhan Tier 2 penalty. Validated mortal-experiment / Mankind's cultural hero. Fires crisis state, not flat penalty, per design doc. |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | Sovngarde (MQ304) | `Skyrim.esm:046EF1` | `200` | penalty T1 | `strong` | `receiver-needed` | Entering Shor's Hall = Lorkhan Tier 1 penalty. Strongest penalty event. Fires crisis state. |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | Joining the Stormcloaks (CW01B) | `Skyrim.esm:0E2D29` | `200` | penalty T2 | `strong` | `manual-only` | Stormcloak oath = Lorkhan Tier 2 (explicitly a Talos-worship movement). One-shot; no second Talos award. |
| `PDV_FLST_P2_AltmerLorkhanPenalties` | The Silver Hand (C03) | `Skyrim.esm:01CEF4` | `200` | penalty T2 | `strong` | `receiver-needed` | Beast-blood / Companions completion. Ysgramor lineage = Tier 2 Shor-adjacent. Crisis state if beast-blood; devout halt if werewolf curse is active. |

**Note on HearthFires adoption/homestead:** Both are `plausible` Altmer Tier 3
mortal-validation penalties. Current readback lacks a clean terminal completion flag.
Defer to post-1.0: implement as custom condition checks rather than PO3 quest-stage
events.

---

### B2 — Argonian

**Theological context:** Three layers — Hist relation (always primary, decays slowly),
Community/collective, Sithis acknowledgment. Hist layer is environmental/behavioral,
not primarily book-signal driven. Books offer cultural context signals for the
community layer. Sithis layer activates through Dark Brotherhood milestones.

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_ArgonianHistSources` | `PDV_EventBus.RouteArgonianHistMaintenance(sourceId)` | book, quest-stage | Curated Saxhleel cultural/identity texts; Hist-adjacent environmental quest beats |
| `PDV_FLST_P2_ArgonianCommunitySources` | `PDV_EventBus.RouteArgonianCommunity(sourceId)` | quest-stage | Windhelm Assemblage quests, Riften Docks Argonian content, named Argonian NPC aid milestones |
| `PDV_FLST_P2_ArgonianSithisSources` | `PDV_EventBus.RouteArgonianSithisAcknowledgment(sourceId)` | quest-stage | Dark Brotherhood threshold milestones, curated death-facing quest stages |

#### Proposed book candidates

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_ArgonianHistSources` | Argonian Account, Book 1 | `Skyrim.esm:01AFD7` | `Book0ArgonianAccountBook1` | `plausible` | Argonian experience in exile; cultural identity proxy for Hist-layer context when direct Hist signals are unavailable. |
| `PDV_FLST_P2_ArgonianHistSources` | Argonian Account, Book 2 | `Skyrim.esm:01ACE7` | `Book3ValuableArgonianAccountBook2` | `plausible` | Continued Argonian diaspora experience. |
| `PDV_FLST_P2_ArgonianHistSources` | Argonian Account, Book 3 | `Skyrim.esm:01AFFC` | `Book0ArgonianAccountBook3` | `plausible` | Continued. |
| `PDV_FLST_P2_ArgonianHistSources` | Argonian Account, Book 4 | `Skyrim.esm:01ACE8` | `Book3ValuableArgonianAccountBook4` | `plausible` | Terminal volume; most directly addresses Hist separation and Saxhleel identity. |

**Note:** The Argonian Account series is `plausible`, not `strong` — the texts are
experiential/picaresque rather than devotional. They work as cultural-maintenance
signals (community layer proxy) but should not be the primary Hist-restoration surface.
Hist restoration needs water-adjacent environmental signals per the design doc.

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_ArgonianSithisSources` | With Friends Like These... (DB01) | `Skyrim.esm:01EA50` | `200` | `plausible` | `receiver-needed` | Dark Brotherhood threshold. First Sithis commitment. One of three required strong signals for full Sithis activation; does not alone activate full Sithis scoring. |
| `PDV_FLST_P2_ArgonianSithisSources` | Hail Sithis! (DB11) | `Skyrim.esm:01EA59` | `200` | `plausible` | `receiver-needed` | Dark Brotherhood terminal. Major Sithis evidence. Counts as a second or third strong signal toward full Sithis activation threshold. |

**Note:** DB01 and DB11 are also listed for Imperial civic in Tranche A (destroying
the Dark Brotherhood is the Imperial civic signal; joining is the Sithis signal). The
quest FormKey is the same; route ownership is determined by which stage fires. DB01
stage 200 joining = Argonian/Sithis. A separate stage for destroying the Brotherhood
would route to Imperial civic. Confirm stage split in xEdit before approving either.

---

### B3 — Bosmer

**Theological context:** Four path-divergent routes (Old Contract, Living Story,
Exchange, Bandit Road). Book signal pool is very thin — vanilla Skyrim contains
almost no explicitly Bosmer-coded devotional texts. Quest-stage and behavioral signals
carry the weight. FLSTs are proposed per path; the route function receives the path
state and routes accordingly.

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_BosmerYffreSources` | `PDV_EventBus.RouteBosmerYffre(pathState, sourceId)` | book, quest-stage | Y'ffre-adjacent texts, Old Contract compliance signals, Living Story community/memory milestones |
| `PDV_FLST_P2_BosmerZenSources` | `PDV_EventBus.RouteBosmerZenExchange(sourceId)` | quest-stage | Proportionate-justice, debt-settling, contract-completion quest stages |
| `PDV_FLST_P2_BosmerBaanDarSources` | `PDV_EventBus.RouteBosmerBaanDarRoad(sourceId)` | quest-stage | Road-life, exile-survival, reversal quest beats |

**Book situation:** No vanilla Bosmer-coded devotional texts are confirmed in the
book CSV that map cleanly to Y'ffre, Z'en, or Baan Dar. Kynareth texts
(Kyne-as-Y'ffre proxy) are weak — Kynareth is not Y'ffre for a devout Bosmer. The
Living Story path could potentially use general community/oral-tradition books, but
no specific strong candidates exist.

**Recommendation:** Leave `PDV_FLST_P2_BosmerYffreSources` book slots unfilled at
1.0. Focus fill effort on quest-stage signals. Flag for custom-content enrichment in
a later phase.

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|
| `PDV_FLST_P2_BosmerYffreSources` | Ill Met By Moonlight (DA05) | `Skyrim.esm:02A49A` | `100` | `strong` | `receiver-needed` | Kill Sinding = follows Hircine's hunt law. For Old Contract Bosmer, following hunt law is Y'ffre compliance (proper killing, animal-covenant conduct). Stage 100 only. |
| `PDV_FLST_P2_BosmerYffreSources` | Ill Met By Moonlight (DA05) | `Skyrim.esm:02A49A` | `105` | `plausible` | `receiver-needed` | Defend Sinding = defies Hircine. For Living Story Bosmer, mercy-toward-the-cursed is a community/memory signal. Plausible; not applicable to Old Contract path. Route function must check path state. |
| `PDV_FLST_P2_BosmerYffreSources` | The Eye of Magnus (MG08) | `Skyrim.esm:01F258` | `200` | `plausible` | `receiver-needed` | College/Magnus crisis stewardship. Living Story path only — community preservation and memory. Route function must check path state (Living Story only). |

**Mutual exclusion (DA05 stages 100/105):** Same quest, same FormKey, different
stages. Route function must fire exactly one branch per playthrough and refuse the
other permanently. Nord and Bosmer both reference DA05; each routes to its own
FLST/receiver — no cross-race double-score.

---

### B4 — Khajiit

**Theological context:** Lunar substrate always active (no setup choice). Silent
patron emergence through behavior — no formal offer fires. Five focused emphases
(Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh). Books feed the substrate and focused
paths. Quest stages are mostly for Azurah (threshold) and Alkosh (dragon-facing).

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_KhajiitLunarSources` | `PDV_EventBus.RouteKhajiitLunarSubstrate(sourceId)` | book | Curated Khajiit theological/cultural texts that reinforce the Lattice. No behavioral signals — those route through dedicated dawn/event hooks. |
| `PDV_FLST_P2_KhajiitFocusedSources` | `PDV_EventBus.RouteKhajiitFocusedEmphasis(deityId, sourceId)` | quest-stage | Deity-specific quest milestones — Azurah thresholds, Alkosh dragon-beats, Baan Dar reversals, Rajhin theft-mythic moments |

#### Proposed book candidates

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_KhajiitLunarSources` | Words of Clan Mother Ahnissi | `Skyrim.esm:01B27D` | `Book3ValuableWordsofClanMotherAhnissi` | `strong` | Direct Khajiit lunar theology — Azurah, the ja-Kha'jay, Khajiit creation. The single strongest Khajiit devotional text in the game. |
| `PDV_FLST_P2_KhajiitLunarSources` | Ahzirr Traajijazeri | `Skyrim.esm:01AFF3` | `Book0AhzirrTraajijazeri` | `strong` | Khajiit warrior manifesto: community identity, anti-subjugation, road-life. Feeds lunar substrate community layer. |
| `PDV_FLST_P2_KhajiitLunarSources` | The Tale of Dro'Zira | `Skyrim.esm:0F03E3` | `Book3ValuableTaleOfDroZira` | `plausible` | Khajiit folk story; cultural continuity and change. Azurah-adjacent (thresholds and change). |
| `PDV_FLST_P2_KhajiitLunarSources` | Cats of Skyrim | `Skyrim.esm:0ED605` | `Book2CommonCatsOfSkyrim` | `weak` | General Khajiit identity text from non-Khajiit perspective. Insufficient theological depth alone; include only if book pool needs additional early-game signal depth. |

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | deityId | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_KhajiitFocusedSources` | Dragon Rising (MQ104) | `Skyrim.esm:02610C` | `160` | Alkosh | `strong` | `receiver-needed` | First dragon soul absorption = Alkosh domain. Dragonborn declaration is cosmically significant for Alkosh (dragon-lord vs. chaos). One-shot; not every dragon kill. |
| `PDV_FLST_P2_KhajiitFocusedSources` | The Black Star (DA01) | `Skyrim.esm:028AD6` | `100` | Azurah | `strong` | `receiver-needed` | Azura's Star restored. Azurah threshold signal — she guards Khajiit through thresholds. Maximum Azurah recognition event. Stage 100 only; stage 110 (Black Star corruption) is not an Azurah signal. |
| `PDV_FLST_P2_KhajiitFocusedSources` | Blindsighted (TG08B) + Darkness Returns (TG09) | `Skyrim.esm:021554` / `021555` | `200` each | Rajhin/Nocturnal | `plausible` | `receiver-needed` | Nightingale oath and Skeleton Key restoration. Plausible Rajhin/Nocturnal threshold. Route to Rajhin emphasis if player is Rajhin-focused; flag as shadow-adjacent for Nocturnal pressure if ShadowDrift posture is active. One owner only — do not double-score from both quest FormKeys. |

---

### B5 — Orc

**Theological context:** Single deity (Malacath) always. Three life-modes
(Stronghold, City, Legion/Exile) shape signal scoring weights and contextual-favor
lanes. FLST structure should be simplified: one property per mode rather than per
deity, since Malacath is the only deity and mode determines everything.

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_OrcMalacathSources` | `PDV_EventBus.RouteOrcMalacathConduct(modeId, sourceId)` | book, quest-stage | Malacath theological texts; Stronghold mode: Blood-Kin/community milestones; City mode: curated dignity/labor stages; Legion mode: completed-service milestones |

**Note:** A single `OrcMalacathSources` FLST routes through mode-state detection in
the EventBus. The route function receives `modeId` from the active `PDV_State_OrcLifeMode`
at event time. This avoids three separate FLSTs for the same deity.

#### Proposed book candidates

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_OrcMalacathSources` | The Code of Malacath | `Skyrim.esm:07EBC9` | `Book1CheapTheCodeofMalacath` | `strong` | Direct Malacath theology and the Orc code. The single most semantically clear Orc devotional text. |
| `PDV_FLST_P2_OrcMalacathSources` | The True Nature of Orcs | `Skyrim.esm:01AD16` | `Book4RareTrueNatureofOrcs` | `strong` | Addresses Orc theology and Malacath's relationship to the Orsimer directly. Strong cultural/devotional identity signal. |

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | modeId | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_OrcMalacathSources` | The Cursed Tribe (DA06) | `Skyrim.esm:03B681` | `200` | Stronghold | `strong` | `receiver-needed` | Stage 200: curse lifted, Malacath names the player his champion. Primary Stronghold Blood-Kin/community milestone. Major gate event; can immediately switch mode to Stronghold if not already confirmed. One-shot. |
| `PDV_FLST_P2_OrcMalacathSources` | Boethiah's Calling (DA02) | `Skyrim.esm:04D8D6` | `100` | all modes | `plausible` | `receiver-needed` | Boethiah is a rival/taboo pressure for Orcs — Malacath and Boethiah are enemies. Completing DA02 as an Orc is a deviation signal, not a Malacath-positive one. Route as negative piety or contextual-pressure signal, not a gain. **Note:** This contradicts a simple positive-routing FLST. May require a separate OrcBoethiahDeviation property or a mode-conditioned negative path. Clarify with design before approving. |

**Note on DA02 and Orc:** The dossier flags DA02 as "Boethiah focus or taboo
pressure" for Dunmer/Orc. For Dunmer it is positive (Reclamation). For Orc it is
negative (Boethiah is Malacath's enemy). The same quest, same stage, routes
differently by race. Confirm this is handled at the EventBus routing level, not by
using the same FLST for both routes.

---

### B6 — Redguard

**Theological context:** Three sects (Crown, Forebear, Ash'abah). Yokudan pantheon
spine shared. Tu'whacca/ancestor layer always active. Books are thin for Redguard
specifically; the primary fill surface is quest-stage (death-duty, MS08 sect split,
Hall of the Dead). One FLST per sect plus one shared spine FLST.

#### Proposed new FLST properties

| Property name | Route | Source kinds | Accepted scope |
|---|---|---|---|
| `PDV_FLST_P2_RedguardSpineSources` | `PDV_EventBus.RouteRedguardAncestorSpine(sourceId)` | book, quest-stage | Shared Satakal/Tu'whacca/ancestor signals across all sects; undead-opposition, burial-adjacent, death-duty milestones |
| `PDV_FLST_P2_RedguardCrownSources` | `PDV_EventBus.RouteRedguardSectSignal(0, sourceId)` | quest-stage | Crown honorable-martial, ancestor-duty, Alik'r-aligned quest stages |
| `PDV_FLST_P2_RedguardForebeaRSources` | `PDV_EventBus.RouteRedguardSectSignal(1, sourceId)` | quest-stage | Forebear road-passage, contract-completion, HoonDing make-way quest stages |
| `PDV_FLST_P2_RedguardAshAbahSources` | `PDV_EventBus.RouteRedguardSectSignal(2, sourceId)` | quest-stage | Ash'abah undead-cleansing, Hall of the Dead, major necromancer-operation quest stages |

#### Proposed book candidates

| FLST property | Book | FormKey | editorId | semanticVerdict | Rationale |
|---|---|---|---|---|---|
| `PDV_FLST_P2_RedguardSpineSources` | Mixed Unit Tactics | `Skyrim.esm:01ACD1` | `Book2CommonManualMixedUnitTactics` | `plausible` | Redguard military heritage — Leki-adjacent martial bearing; the sword-discipline legacy. Plausible as a shared Crown/Forebear military-identity context signal. |

**Note on Redguard book pool:** Like Bosmer, the vanilla Redguard devotional book
pool is sparse. No Tu'whacca-specific, Satakal-specific, or Ash'abah-specific texts
exist in the scan. Mixed Unit Tactics is the strongest single candidate. The
spine FLST should rely primarily on quest-stage fills. Leave book slots open for
future custom-content enrichment.

#### Proposed quest-stage candidates

| FLST property | Quest | FormKey | Stage | sect | semanticVerdict | implementationStatus | Notes |
|---|---|---|---|---|---|---|---|
| `PDV_FLST_P2_RedguardCrownSources` | In My Time of Need (MS08) | `Skyrim.esm:01CF25` | `201` | Crown | `strong` | `receiver-needed` | Stage 201 = Saadia delivered to Kematu/Alik'r. Crown / Hammerfell justice / ancestor-duty positive. Mutually exclusive with stage 200 (Forebear). One-shot. |
| `PDV_FLST_P2_RedguardForebeaRSources` | In My Time of Need (MS08) | `Skyrim.esm:01CF25` | `200` | Forebear | `strong` | `receiver-needed` | Stage 200 = helped Saadia escape. Forebear / exile-protection / anti-Alik'r positive. Mutually exclusive with stage 201 (Crown). One-shot. |
| `PDV_FLST_P2_RedguardSpineSources` | Hall of the Dead / Arkay NPC quests | Confirm per hold | terminal | all sects | `strong` | `receiver-needed` | Each hold's Hall of the Dead quest is a one-shot Tu'whacca/ancestor signal for Redguard. Heaviest weight for Ash'abah. Exact FormKeys require per-hold xEdit confirmation (Whiterun HoD, Riften HoD, etc.). |
| `PDV_FLST_P2_RedguardAshAbahSources` | Dark Brotherhood destruction path (DB) | Confirm stage | terminal | Ash'abah/all | `plausible` | `needs-stage-readback` | If the player destroys the Dark Brotherhood (not joins), this is a death-purification act for an Ash'abah Redguard — clearing the Night Mother cult. Needs exact stage readback for the destruction path vs. joining path. |

---

## Cross-Race Mutual Exclusion Register

These quests have split outcomes that score differently by race or by branch. All
require one-shot gates keyed to the **exact stage that completed**, never the quest
form alone.

| Quest | FormKey | Branch A stage | Branch A routes | Branch B stage | Branch B routes | Guard |
|---|---|---|---|---|---|---|
| DA01 The Black Star | `Skyrim.esm:028AD6` | `100` (Azura's Star) | Dunmer Azura, Khajiit Azurah | `110` (Black Star) | Dunmer Deviation | Fire exactly one branch; mutual-exclusion source marker per character |
| DA05 Ill Met By Moonlight | `Skyrim.esm:02A49A` | `100` (kill Sinding) | Nord HircineArkay, Bosmer YffireOldContract | `105` (defend Sinding) | Nord HircineArkay, Bosmer YffireLivingStory | Fire exactly one; Bosmer route checks path state before routing |
| CW01A / CW01B Civil War join | `Skyrim.esm:0D517A` / `0E2D29` | CW01A `200` | Imperial Civic (positive), Altmer Lorkhan T2 (penalty from Stormcloaks only) | CW01B `200` | Nord KyneTalos, Imperial PublicTalos, Altmer Lorkhan T2 penalty | Mutually exclusive in vanilla; gate at quest-form level; one marker per character |
| DLC1VQ02 Bloodline | `Dawnguard.esm:002F65` | Dawnguard branch (stages TBD) | Breton KnightsRoad, Altmer AurielSources | Volkihar branch (stages TBD) | Dunmer Deviation, Breton HiddenArt deviation | Branch stage split requires xEdit confirmation before fill |
| MS08 In My Time of Need | `Skyrim.esm:01CF25` | `201` (Alik'r) | Redguard Crown | `200` (Saadia) | Redguard Forebear | Mutually exclusive by quest design; gate on stage only |
| DB01 / DB11 Dark Brotherhood | `Skyrim.esm:01EA50` / `01EA59` | DB01 join `200` | Argonian Sithis | DB destruction path (confirm stage) | Redguard AshAbah, Imperial Civic | Stage readback required for destruction path; joining and destruction are mutually exclusive |
| TG08B / TG09 Nightingale | `Skyrim.esm:021554` / `021555` | TG09 `200` full oath | Khajiit Rajhin/Nocturnal, Dunmer Deviation | — | — | One owner between quest-stage and item-source receiver; do not double-score from both FormKeys |

---

## Implementation Priority

### Priority 1 — Ready for receiver build (existing FLST, known exact stage)

These entries have confirmed FormKeys and stage numbers from the dossier readback.
They need a receiver branch added to `PDV_PlayerEvents.psc` that processes
`RegisterForQuestStage` events for the relevant FLST.

| Race | Quest | FormKey | Stage | FLST |
|---|---|---|---|---|
| Nord | MQ104 Dragon Rising | `Skyrim.esm:02610C` | `160` | `PDV_FLST_P2_NordOldWaysSources` |
| Nord | MQ105 Way of the Voice | `Skyrim.esm:0242BA` | `160` | `PDV_FLST_P2_NordKyneTalosSources` |
| Nord | MQ304 Sovngarde | `Skyrim.esm:046EF1` | `200` | `PDV_FLST_P2_NordOldWaysSources` |
| Nord | C03 Silver Hand | `Skyrim.esm:01CEF4` | `200` | `PDV_FLST_P2_NordHircineArkaySources` |
| Nord | C06 Glory of the Dead | `Skyrim.esm:01CEF6` | `200` | `PDV_FLST_P2_NordHircineArkaySources` |
| Nord | DA05 Ill Met By Moonlight | `Skyrim.esm:02A49A` | `100` / `105` | `PDV_FLST_P2_NordHircineArkaySources` |
| Dunmer | DA01 The Black Star | `Skyrim.esm:028AD6` | `100` | `PDV_FLST_P2_DunmerAzuraSources` |
| Dunmer | DA01 The Black Star | `Skyrim.esm:028AD6` | `110` | `PDV_FLST_P2_DunmerDeviationSources` |
| Dunmer | DA02 Boethiah's Calling | `Skyrim.esm:04D8D6` | `100` | `PDV_FLST_P2_DunmerBoethiahSources` |
| Redguard | MS08 In My Time of Need | `Skyrim.esm:01CF25` | `200` / `201` | `RedguardForebeaRSources` / `RedguardCrownSources` |
| Argonian | DB01 With Friends Like These | `Skyrim.esm:01EA50` | `200` | `ArgonianSithisSources` |
| Argonian | DB11 Hail Sithis! | `Skyrim.esm:01EA59` | `200` | `ArgonianSithisSources` |
| Khajiit | DA01 The Black Star | `Skyrim.esm:028AD6` | `100` | `KhajiitFocusedSources` (Azurah) |
| Khajiit | MQ104 Dragon Rising | `Skyrim.esm:02610C` | `160` | `KhajiitFocusedSources` (Alkosh) |
| Orc | DA06 The Cursed Tribe | `Skyrim.esm:03B681` | `200` | `OrcMalacathSources` (Stronghold) |

### Priority 2 — Needs xEdit stage-branch readback first

| Race | Quest | FormKey | Blocker |
|---|---|---|---|
| Breton | DLC1VQ02 Bloodline | `Dawnguard.esm:002F65` | Dawnguard vs. Volkihar branch stage split |
| Dunmer | DLC2MQ02/05/06 | Dragonborn.esm entries | Confirm terminal stage vs. mid-quest pressure stage |
| Dunmer | DLC1VQ02 Volkihar branch | `Dawnguard.esm:002F65` | Same branch readback as Breton |
| Altmer | DLC1VQ07/08 | Dawnguard.esm entries | Confirm Dawnguard-side isolation |
| Redguard | DB destruction path | Unknown stage | Exact stage for Brotherhood-destroyed vs. Brotherhood-joined |

### Priority 3 — Manual-only (needs scripted validation, not PO3 quest-stage receiver)

| Race | Quest | Reason |
|---|---|---|
| Imperial | CW01A Joining the Legion | Oath must be distinguished from generic Legion attendance |
| Imperial / Nord | CW01B Joining Stormcloaks | Same |
| Imperial | CW01A Destroy Dark Brotherhood | DB destruction path requires scripted intent validation |

### Priority 4 — New FLST shells (Tranche B, Phase 21)

All 16 new FLST properties proposed in Tranche B require:
1. CK shell creation for each new `PDV_FLST_P2_*` record
2. New alias property on `PDV_Player` alias
3. `formListShellReadback` and `aliasPropertyReadback` tool passes
4. EventBus route functions for new race routing families
5. Then this document's book/quest-stage candidates can be submitted to the fill tool

---

## Book-Fill Summary Table

All proposed new book fills by FLST (Tranche A and B). Entries marked `plausible`
require closer semantic review before final approval. Entries marked `strong` are
recommended for approval in the next fill pass.

| FLST | Book | FormKey | Verdict | Tranche |
|---|---|---|---|---|
| BretonHiddenArtSources | Spirit of the Daedra | `Skyrim.esm:01AD15` | strong | A |
| BretonHiddenArtSources | N'Gasta! Kvata! Kvakis! | `Skyrim.esm:01AD0E` | strong | A |
| BretonHiddenArtSources | Souls, Black and White | `Skyrim.esm:01AD0C` | strong | A |
| BretonHiddenArtSources | The Book of Daedra | `Skyrim.esm:01ACC8` | plausible | A |
| BretonHiddenArtSources | Varieties of Daedra | `Skyrim.esm:01ACFC` | plausible | A |
| DunmerMephalaSources | The Night Mother's Truth | `Skyrim.esm:0E0D67` | strong | A |
| DunmerAzuraSources | The Reclamations | `Dragonborn.esm:03B052` | strong | A |
| DunmerAzuraSources | Ancestors and the Dunmer | `Skyrim.esm:01B22D` | plausible | A |
| ImperialCivicSources | The Great War | `Skyrim.esm:0F456D` | strong | A |
| ImperialCivicSources | Brief History of the Empire v1 | `Skyrim.esm:01ACB9` | plausible | A |
| ImperialCivicSources | Brief History of the Empire v2 | `Skyrim.esm:01ACBA` | plausible | A |
| ImperialCivicSources | Brief History of the Empire v3 | `Skyrim.esm:01ACBB` | plausible | A |
| ImperialCivicSources | Brief History of the Empire v4 | `Skyrim.esm:01ACBC` | plausible | A |
| ImperialCivicSources | Gods and Worship | `Skyrim.esm:01ACD5` | plausible | A |
| NordOldWaysSources | Nords of Skyrim | `Skyrim.esm:0E0D66` | strong | A |
| NordOldWaysSources | Five Songs of King Wulfharth | `Skyrim.esm:01AD05` | strong | A |
| NordOldWaysSources | The Old Ways | `Skyrim.esm:01AD0F` | strong | A |
| NordKyneTalosSources | Children of the Sky | `Skyrim.esm:01AD03` | strong | A |
| AltmerAurielSources | The Adabal-a | `Skyrim.esm:01AF94` | strong | B |
| AltmerAurielSources | Fragment: On Artaeum | `Skyrim.esm:01AD06` | strong | B |
| AltmerMagnusSources | Arcana Restored | `Skyrim.esm:01ACFE` | strong | B |
| AltmerMagnusSources | Magic from the Sky | `Skyrim.esm:01ACF1` | strong | B |
| AltmerXarxesSources | Last King of the Ayleids | `Skyrim.esm:01AD09` | strong | B |
| AltmerXarxesSources | Treatise on Ayleidic Cities | `Skyrim.esm:01ADB4` | plausible | B |
| AltmerXarxesSources | An Accounting of the Scrolls | `Skyrim.esm:0ED03A` | plausible | B |
| ArgonianHistSources | Argonian Account, Book 1 | `Skyrim.esm:01AFD7` | plausible | B |
| ArgonianHistSources | Argonian Account, Book 2 | `Skyrim.esm:01ACE7` | plausible | B |
| ArgonianHistSources | Argonian Account, Book 3 | `Skyrim.esm:01AFFC` | plausible | B |
| ArgonianHistSources | Argonian Account, Book 4 | `Skyrim.esm:01ACE8` | plausible | B |
| KhajiitLunarSources | Words of Clan Mother Ahnissi | `Skyrim.esm:01B27D` | strong | B |
| KhajiitLunarSources | Ahzirr Traajijazeri | `Skyrim.esm:01AFF3` | strong | B |
| KhajiitLunarSources | The Tale of Dro'Zira | `Skyrim.esm:0F03E3` | plausible | B |
| KhajiitLunarSources | Cats of Skyrim | `Skyrim.esm:0ED605` | weak | B |
| OrcMalacathSources | The Code of Malacath | `Skyrim.esm:07EBC9` | strong | B |
| OrcMalacathSources | The True Nature of Orcs | `Skyrim.esm:01AD16` | strong | B |
| RedguardSpineSources | Mixed Unit Tactics | `Skyrim.esm:01ACD1` | plausible | B |
