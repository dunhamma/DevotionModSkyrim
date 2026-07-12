# Breton - The Tradition You Walk

## Overview

Bretons are a contradiction, and they have made peace with it. Half-elven by blood, they built an identity as the most human of the human races, yet they carry both the logic of the Divines and the old magical traditions of the elves at the same time. A Breton can keep a knight's vow and consult a witch in the same week and find nothing strange about it. For a Breton, mixing faiths is not a flaw. It is the faith.

Because of that, your faith is organized less around a single god and more around a *tradition* you choose to live. The gods give your tradition shape, but the tradition comes first. You pick one of three at the very start, and that choice shapes the rest of your playthrough.

The three traditions barely overlap. The Knight's Road is civic honor and protective justice under the Divines. The Hidden Art is secret occult study, with one foot in the Daedric world and a public face to protect. The Green Way is druidic covenant with the old nature-god Y'ffre. Each comes with its own gods, its own way of earning standing, and its own hidden track that watches how you carry yourself. (For the basics of piety, tiers, and patrons, see the How Devotion Works primer.)

## Your Gods

Your gods depend on the tradition you walk.

Knight's Road gods (the Divines and their kin):

- Stendarr - god of mercy, justice, and righteous restraint. The Knight's Road reads him most sharply.
- Akatosh - the Dragon God of time and order; patron of dragonslayers and the keeping of oaths.
- Mara - goddess of love, family, and community.
- Arkay - keeper of the cycle of life and death; enemy of the undead.
- Mara, Stendarr, Arkay, Akatosh, and the other Divines (Julianos, Zenithar, Kynareth, Dibella) can all receive Knight's Road devotion.

Hidden Art gods (occult and Daedric):

- Julianos - god of wisdom and disciplined study; the lawful, restrained face of the secret art.
- The Daedric Princes most legible to a Breton witch reach you through the wider Daedric system: Hermaeus Mora (forbidden knowledge), Hircine (the hunt), Namira (corruption and the discarded), and Nocturnal (shadow and the Nightingales). These yield piety, not punishment, for a Breton on this road.

Green Way gods (the old nature covenant):

- Y'ffre - the Storyteller, the first and oldest god of the forest. The heart of the Green Way.
- Magnus - the elder mage-god, tied to Alteration and rare arcane lore.
- Phynaster - an elven ancestor-hero, honored through appreciation of elven heritage and craft.
- Kynareth - goddess of the sky and the wild; her shrines give modest, nature-aligned credit on this path.

Foreign gods and the Daedric Princes are not approached freely. Normal patron offers come only from the tradition you chose. The Daedric Princes open only through the Hidden Art's occult commitment, or through the Green Way's one-time werewolf trial. There is no casual god-hopping.

## Getting Started

At the very start you must choose your tradition. There is no default and no fallback - the game will keep asking until you pick. This is the single most important choice you make as a Breton, because tradition switching is not available in normal play. Choose deliberately.

The three branches:

- The Knight's Road. You serve the Divines through honor, mercy, and protection. You gain standing by helping people, sparing the helpless, and defending the weak in combat. Your hidden track here is your Knightly Vow - your honor. It begins full and degrades when you take expedient, dishonorable shortcuts. This is the hardest tradition to keep, because Skyrim constantly offers you the Thieves Guild, the Dark Brotherhood, and easy corruption.

- The Hidden Art. You study the occult in secret and deal with the Daedra. You gain standing through Daedric quests, forbidden books, and ritual work. Your hidden track is your Exposure - how visible your witchcraft has become. It starts at zero. The whole tension of this path is whether you stay hidden (slower, safe) or go fully public (faster, dangerous). You cannot sit in the middle forever.

- The Green Way. You keep a druidic covenant with Y'ffre and live close to the land. You gain standing by sleeping outdoors, visiting standing stones, and walking nature sites. Your hidden track is your Druidic Standing - the covenant's measure of you. It starts at a neutral middle and quietly fades if you spend all your time in cities and dungeons. This path also carries a one-time choice if you ever become a werewolf (see If You Are Cursed).

Every Breton carries all three hidden tracks under the surface, but only the one tied to your tradition matters to you in normal play. Your Exposure is always watching, even if you never touch the occult.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (tradition/track state or a small finite source pool)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Day-to-day deltas from PDV_DeityLikesDislikes.csv; curated deltas from PDV_Deity_*.psc DELTA_*.
     Breton has NO dev-only signal activators in PDV_FinalPlacementManifest.json (unlike Bosmer/Khajiit);
     its three "signature" lanes route only from P2 immersive sources (books/spells/harvests/quest stages)
     via OnBookRead/OnSpellLearned/OnItemHarvested -> RouteP2ImmersiveSource, plus the shared CSV rows. -->

Remember that piety is tracked separately for each god, daily gain is capped at about 4.3 per god per day, and repeating the same deed earns less each time. Variety matters far more than grinding.

Knight's Road deeds:

- Help an NPC with no reward, or finish a quest helping someone without taking pay (your most important honorable act). `[QUEST/INERT: no organic "help without reward" hook exists. The Knight's Road vow signal (Stendarr SIGNAL_MERCY +3.0) fires organically from just two vanilla quest completions - Book of Love (t02) s200 and Laid to Rest (MS14) s200, via PDV_FLST_P2_BretonVowSources quest-stage routing. Generic uncompensated help is not tracked.]`
- Choose mercy in a meaningful moment. `[QUEST: mercy_spare rows exist for Stendarr/Mara in the quest matrix but only a few are promoted; the organic curated "mercy" pulse is the same two-quest vow lane above, not a free-standing mercy detector.]`
- Kill the undead and the Daedra (Stendarr, Arkay, and Kynareth all approve of clearing the unnatural). `[WIRED: CSV kill-undead (300) - Stendarr +0.5, Arkay +0.5, Kynareth n/a, Akatosh +0.5, Y'ffre +0.5; kill-daedra (301, ActorTypeDaedra) - Stendarr +0.75, Arkay +0.75, Kynareth +0.5, Akatosh +0.5. Fires on the kill event.]`
- Pray at a Divine shrine - especially Stendarr's, which can also restore lost honor with clean hands. `[PARTIAL: shrine-prayer piety is not confirmed as an organic earn (shrines were normalized to cure-only across races). The "restore lost honor" half is INERT - see Review Notes: KnightlyVowIntegrity is only ever SET to 100, never lowered organically, so there is no honor to restore.]`
- Heal or cure someone in need (Mara, Stendarr, Dibella). `[WIRED: CSV heal-or-cure-npc (350) - Stendarr +0.5, Mara +0.75, Arkay +0.5, Akatosh +0.25, Kynareth +0.5.]`
- Pay off a bounty by serving your time, which the merciful gods read as making a debt right (Mara, Stendarr, Zenithar). `[WIRED: CSV clear-bounty-serve-time (351) - Stendarr +0.75, Mara +0.5. Zenithar row not present in this pull.]`
- Honest craft and labor for Zenithar; diligent study and learning Words of Power for Julianos. `[WIRED (Julianos): CSV read-skill-book (340) +0.5, read-spell-tome (341) +0.5, read-lore-book (342) +0.5, learn-word-of-power (343) +0.75, increase-skill (344) +0.25, enchant-item (331) +0.25, brew-potion (332) +0.25. Zenithar craft/labor not verified in this pull.]`

Hidden Art deeds:

- Complete a Daedric quest. These are the main scoring events on this path and give very strong piety. `[QUEST: Daedric-quest credit reaches a Breton only through the shared Daedric worship system and the quest-reaction matrix (Julianos has DA04 Discerning the Transmundane s100 +m/small). There is no Breton-specific "completed a Daedric quest" curated hook - the strong per-quest piety is the general Daedric/patron system, not a Hidden Art lane.]`
- Visit and use Daedric shrines - you draw piety from the very places others are punished for. `[STUB/PARTIAL: no Breton-specific Daedric-shrine hook. Daedric-shrine credit, if any, comes from the shared Daedric system, not a Hidden Art lane.]`
- Read approved occult and witchcraft texts (such as Herbane's Bestiary: Hagravens, The Madmen of the Reach, and Anise's Letter). `[WIRED: OnBookRead -> RouteP2ImmersiveSource("po3_book") -> PDV_FLST_P2_BretonHiddenArtSources (3 books: Book2CommonHagravens 0ED60B, Book2CommonMadmenoftheReach 07EB03, dunPOIWitchNote 0DDFB6) -> RouteBretonHiddenArtExposure -> HandleBretonHiddenArtExposure: WitchcraftExposure +25 AND (if Hidden Art tradition) Julianos SIGNAL_LAWFUL_ORDER +3.0. This is the proven organic Hidden Art book route. Anise's Letter is NOT one of the three wired books.]`
- Carry out ritual work and forbidden study, more rewarding the more you have committed. `[WIRED (spell path): learning a master forbidden spell fires the same exposure+Julianos lane. OnSpellLearned -> PDV_FLST_P2_BretonHiddenArtSpells (DeadThrall 07E8DF, ConjureDremoraLord 10DDEC) -> RouteBretonHiddenArtExposure. No broader "ritual work" detector beyond these books/spells.]`
- For Julianos, the lawful, restrained face of the art: read skill books, spell tomes, and lore. `[WIRED: same Julianos CSV study rows as the Knight's Road study bullet above (340/341/342/343/344/331/332).]`

Green Way deeds:

- Sleep outdoors, under the open sky rather than in an inn or house. `[WIRED: OnSleepStop with PDV_LastSleepStartedOutside -> EVT_REST_UNDER_OPEN_SKY (313). CSV rest-under-open-sky rows: Y'ffre +0.5, Kynareth +0.75, Akatosh +0.25, Mara sleep-in-bed (314) +0.25. NOTE: outdoor sleep does NOT feed the curated Green Way / DruidicStanding lane - HandleBretonSleepEvents only awards the Magnus ancestor spine (and Julianos if Hidden Art). The Green Way earn from sleep is the shared CSV rows, not the druidic track.]`
- Visit a standing stone (a rich, finite source early on - there are many across Skyrim). `[STUB: no organic standing-stone location hook for Breton. There is no HandleStoryChangeLocation or standing-stone route in PlayerEvents/ActionRouter; standing stones are not in any populated Breton FormList.]`
- Walk nature sites - groves, forests, and standing-stone areas, especially on related quests. `[STUB: no organic nature-site location hook. The one quest-stage Green Way route is the Eldergleam blessings quest (89282 s100) via PDV_FLST_P2_BretonGreenWaySources -> Kynareth SIGNAL_OPEN_SKY.]`
- Forage and harvest from the wild; rest in the open air (Kynareth and Y'ffre both honor this). `[WIRED (harvest): OnItemHarvested -> RouteP2ImmersiveSource("po3_harvest") -> PDV_FLST_P2_BretonGreenWayHarvests (SprigganSap 063B5F, Taproot 03AD71, Nirnroot 059B86, NirnrootRed 0B701A) -> RouteBretonGreenWayStanding -> HandleBretonGreenWayStanding: DruidicStanding +25 AND (if Green Way + Druidic fork) Kynareth SIGNAL_OPEN_SKY +3.0. Only these four curated harvests route the druidic lane - ordinary plant-picking does not. Generic harvest also fires the Kynareth CSV harvest-ingredient (334) +0.25.]`
- Visit a shrine of Kynareth for modest nature-aligned credit. `[PARTIAL: shrine-prayer piety unconfirmed as an organic earn (shrines normalized to cure-only). Kynareth's day-to-day table (open-sky, discover-location, harvest, heal) is the real Green-adjacent earn.]`
- Read the old druidic lore. `[WIRED (placeholder): OnBookRead -> PDV_FLST_P2_BretonGreenWaySources currently holds ONE placeholder book (Book2CommonTheWispmother 083B3B) -> RouteBretonGreenWayStanding -> Kynareth. The Green Way book pool is barren; this single book is flagged PLACEHOLDER in the fill manifest.]`
- Hunt wild game. The Green Pact takes meat with respect, and the slain are honored - so a hunt, and cooking what you take, both earn Y'ffre's favor. `[WIRED 2026-07-12 (CSV, breton-gated): hunt-wild-game (303) - Y'ffre +0.25; cook-meal (333) - Y'ffre +0.5; plus kill-undead (300) +0.5 and heal-or-cure (350) +0.5, all breton Y'ffre rows added with LIKES_DISLIKES_VERSION 16. Fires on the animal-kill event, daily-capped. A minor Kynareth -303 is expected by design. This is a day-to-day CSV earn, not the curated DruidicStanding lane.]`

To reach the top tier you must commit to a single god within your tradition. Honoring several at once is welcome, but it caps you at the middle tier. `[WIRED: broad worship caps at Devoted.]`

Under every tradition, each qualifying act also gives a small shared pulse to Magnus (the mixed-inheritance "ancestor spine," SIGNAL_ANCESTOR_SPINE +1.0), and sleeping fires an ancestral-dream ancestor pulse. `[WIRED: AwardBretonAncestorSpinePulse runs inside every Handle* tradition hook and HandleBretonSleepEvents; feeds PDV_BretonAncestorSubstrate + Magnus. Magnus also has an organic day-to-day table (read-spell-tome 341 +0.75, enchant-item 331 +0.5, increase-skill 344 +0.25, read-lore-book 342 +0.25, brew-potion 332 +0.25).]`

## How You Lose Piety

Each god dislikes things, and doing them costs you piety with that god:

- The protective gods (Stendarr, Mara, Arkay, Julianos, Kynareth) all turn away from murdering the defenseless and assaulting the innocent. `[WIRED: CSV murder-defenseless (304) - Stendarr -1.5, Mara -1.5, Arkay -1.0, Julianos -1.5, Kynareth -1.0, Akatosh -0.75; assault-innocent (364) - Stendarr -1.0, Mara -1.0, Arkay -1.0, Julianos -0.75, Y'ffre -0.5. Dibella has no rows in this pull.]`
- Stendarr, Arkay, Kynareth, and Y'ffre punish raising the undead - necromancy is among the worst offenses to them. `[WIRED: CSV raise-undead (365) - Stendarr -1.5, Arkay -1.5, Kynareth -1.0, Y'ffre -1.0, Mara -1.0, Akatosh -1.0, Julianos not listed, Magnus -0.75. Detected caster-side in OnSpellCast via the raise-undead effect FormList.]`
- Stendarr, Mara, and Julianos dislike theft, trespass, and breaking into property. `[WIRED: CSV steal-item (362, owned) - Stendarr -0.75, Mara -0.5, Julianos -0.5; trespass (361) - Stendarr -0.25, Julianos -0.25. Zenithar not in this pull.]`
- Stendarr, Arkay, Kynareth, Magnus, and Akatosh dislike accepting Daedric artifacts; that bargain betrays the Vigil and honest work. `[WIRED: CSV accept-daedric-artifact (368) - Stendarr -1.0, Arkay -1.0, Kynareth -1.0, Magnus -0.75, Akatosh -0.75. Fires from OnObjectEquipped on a Daedric artifact. NOTE: on the Hidden Art path these same Daedric acts yield piety through the Daedric system - this dislike is the Divines' reaction, felt most on the Knight's Road.]`

Beyond dislikes, a few quieter forces erode your standing:

- Neglect. If you let your chosen tradition lapse - stop practicing it for a long stretch - the tradition grows distant. It is a gentle nudge, not a punishment: your health regenerates 5% more slowly until you return to it. `[WIRED (gated): SyncBretonNeglectSpell adds PDV_SPEL_Neglect_Breton when IsBretonTraditionNeglected() - i.e. more than 5 game-days since PDV.Breton.LastTraditionSignalTime. NOTE: this is a grace-days-since-last-CURATED-signal timer, NOT a piety threshold, and it only counts the curated tradition hooks (vow/exposure/greenway/harvest/tradition-choice). CSV day-to-day acts do NOT reset it, and a Breton who has never fired a curated act (lastSource <= 0) never neglects.]`
- Natural drift. Standing settles over time if you stop tending it. `[WIRED: passive per-deity decay (~-0.5/day).]`
- The broad-worship cap. Living your tradition broadly, honoring several of its gods, is fine - but it holds you at the middle tier. Reaching the top requires committing to one god. `[WIRED: broad worship caps at Devoted.]`

Your hidden track is the big one, and it differs by tradition:

- Knightly Vow (Knight's Road). Your honor. `[INERT (degradation unbuilt): PDV.Breton.KnightlyVowIntegrity is the ONLY writer-checked track that is never lowered organically - it is only ever SET to 100 by HandleBretonKnightlyVow, and nothing (no Thieves Guild join, no Dark Brotherhood join, no kill-innocent hook) writes it down. The strained (30-70) and broken (<30) creed-loss spells PDV_SPEL_CreedLoss_Breton_VowIntegrity / _Excommunication CANNOT fire in normal play because integrity never drops. "Joining the Thieves Guild damages it, joining the Dark Brotherhood damages it worse, killing innocents erodes it" is designed-but-unbuilt. The suppress/halt/repair mechanic is present in code but unreachable until a degradation hook is added.]`

- Exposure (Hidden Art). How visible your witchcraft is. `[WIRED (rise + decay + rupture) / PARTIAL (climb sources): WitchcraftExposure rises +25 per Hidden Art book/spell (HandleBretonHiddenArtExposure) and decays -1 each dawn (DecayBretonWitchcraftExposureAtDawn). At 100+ the rupture creed-loss spell PDV_SPEL_CreedLoss_Breton_ExposureRupture fires via SyncBretonWitchcraftExposureRuptureSpell AND the Hidden Art reward family is revoked (SyncBretonTraditionRewardFamily forces isActive=False at exposure >= 100). But the ONLY organic exposure-raising sources are the 3 curated books + 2 curated spells; "caught by Vigilants" and "finish Daedric quests in the open" are NOT wired exposure inputs. Public-Divine-worship-lowers-exposure is also not wired beyond the flat dawn decay.]`

- Druidic Standing (Green Way). The covenant's measure of you. `[WIRED (rise + fray): starts at 50 (neutral middle), +25 per curated Green Way act (harvest/book/quest), and frays -1/dawn via DecayBretonDruidicStandingAtDawn when ShouldBretonDruidicStandingFray (Green Way tradition, not Betrayed fork, once-per-dawn day+1 guard). It is pressure-only: DruidicStanding gates NO reward and never withdraws a boon - "low standing weakens access" is descriptive. It also gates the Green Way reward family only through the Druidic-fork werewolf choice (IsBretonGreenWayForkEligible), not through the standing number itself.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Breton tradition gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (with real UESP citations, magnitude "small"/"milestone") are promoted and fire when the quest is on the watch list; "echo" rows (magnitude "echo", citation "cross-gen candidate ... REVIEW before promotion") are **not** promoted (INERT). Note two of the Breton P2 vow sources double as quest-reaction quests: Book of Love (t02) and Laid to Rest (MS14) also fire the curated Knight's Road vow lane at s200.

**Knight's Road - Stendarr**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Message to Whiterun (dragon aid) | 16 | Assisted the Jarl against the dragon threat (protect the weak) | + / C / small | WIRED |
| The Jagged Crown (CW02) | 72 | Defeated the crypt draugr | + / S / small | WIRED |
| Pieces of the Past (DA07) | 150 | Rejected Mehrunes Dagon's razor / lawful branch | + / S / small | WIRED |
| The Break of Dawn (DA09) | 500 | Cleansed Meridia's temple of undeath | + / m / small | WIRED |
| The House of Horrors (destroy altar) | 210 | Sided with the Vigilant, destroyed Molag Bal's altar | + / m / small | WIRED |
| The Only Cure (destroy altar) | 102 | Anti-Daedric cleansing | + / m / small | WIRED |
| (many negative Daedric/Dark-Brotherhood stages: DA02/03/07/08/10/11/16, DB06/07/08/09/11) | - | Consorting with Daedra / treacherous murder | - / varies / small | WIRED |

22 promoted rows total, plus 17 echo rows (uphold_law_justice / serve_a_daedra / murder_treacherous candidates) flagged REVIEW -> INERT.

**Hidden Art - Julianos** (the lawful face; the Daedric Princes are serviced by the shared Daedric system, not the matrix under a "Hidden Art" key)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Discerning the Transmundane (DA04) | 100 | Pursuit of forbidden truth | + / m / small | WIRED |
| First Lessons (MG01) | 200 | Began disciplined study at the College | + / C / small | WIRED |
| Under Saarthal (MG02) | 200 | Scholarly discovery | + / C / small | WIRED |
| Hitting the Books (MG03) | 200 | Recovered the Fellglow books | + / C / small | WIRED |
| Good Intentions (MG04) | 200 | Consulted the Augur; scholarship | + / C / small | WIRED |
| Revealing the Unseen (MG06) | 200 | Attuned the focusing crystal | + / C / small | WIRED |
| The Staff of Magnus (MG07) | 200 | Recovered the Staff through scholarship | + / S / small | WIRED |
| The Eye of Magnus (MG08) | 200 | Resolved the Eye crisis | + / C / milestone | WIRED |

8 promoted rows, plus 6 echo rows flagged REVIEW -> INERT.

**Green Way - Y'ffre and Kynareth** (Y'ffre carries the covenant; Kynareth is the wired curated-signal deity and the nature-site proxy)

Y'ffre:

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Kyne's Sacred Trials (dunHunterQST) | 100 | The respectful hunt done rightly | + / m / small | WIRED |

1 promoted row, plus 1 echo row (DA05 Ill Met By Moonlight, the_hunt) flagged REVIEW -> INERT.

Kynareth:

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Message to Whiterun | 16 | Aided against the dragon threat | + / m / small | WIRED |
| Hitting the Books (MG03) | 55 | Located Orthorn (protect the weak) | + / m / small | WIRED |
| Containment (MG05) | 200 | Shielded Winterhold | + / m / small | WIRED |
| Dragon Rising (MQ104) | 160 | Reinforcements at the watchtower | + / m / small | WIRED |
| The Heart of Dibella (T01) | 200 | Rescued Fjotra (protect the weak) | + / m / small | WIRED |

5 promoted rows, plus 8 echo rows (protect_the_weak / heal_comfort / defile_nature candidates) flagged REVIEW -> INERT.

Secondary Knight's Road gods also carry promoted matrix rows: Arkay (11 promoted / 3 echo - undead, funerals, Laid to Rest MS14 s200 milestone), Mara (13 / 10 - mercy, family, anti-murder), Akatosh (8 / 9 - dragon kills, oaths, Empire service), Magnus (8 / 1 - the full College of Winterhold study arc, MG07/MG08 milestones). These reach Breton play through the shared quest matrix, not a Breton-specific lane.

Caveat: all day-to-day CSV rows in the gain/loss sections are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON; and the P2 curated lanes are live only if the named FormLists were actually filled in Devotion.esp (`--fill-source-entries` run).

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage, tagged by tradition):

- **Breton has NO dev-only signal activators.** Unlike Bosmer (8) and Khajiit (6), `PDV_FinalPlacementManifest.json` contains zero Breton `PDV_REFR_*Signal` entries. The three traditions route entirely through P2 immersive sources (books/spells/harvests/quest-stages) via `OnBookRead`/`OnSpellLearned`/`OnItemHarvested` -> `RouteP2ImmersiveSource`, plus the shared CSV day-to-day rows and the quest matrix. So "STUB via activator" does not apply here; the STUB gaps are simply missing organic hooks.

- **Hidden Art is the best-wired signature lane.** Reading any of the 3 curated books (Hagravens / Madmen of the Reach / Witch Note) or learning either curated master spell (Dead Thrall / Conjure Dremora Lord) organically raises WitchcraftExposure +25 and awards Julianos SIGNAL_LAWFUL_ORDER +3.0. Exposure decays -1/dawn, ruptures at 100 (creed-loss spell + reward family revoked). This is the proven organic book route the brief flagged.

- **Hidden Art gaps:** the guide's marquee earn - "complete a Daedric quest" - has no Breton curated hook; it rides the shared Daedric system + quest matrix (Julianos DA04). Daedric-shrine use, Vigilant-caught exposure, and "public Divine worship lowers exposure" are all UNWIRED as exposure inputs. Anise's Letter (named in the guide) is not one of the three wired books.

- **Knightly Vow degradation is designed-but-unbuilt (the single biggest INERT).** `KnightlyVowIntegrity` is only ever SET to 100; nothing lowers it. No Thieves Guild join, Dark Brotherhood join, or kill-innocent hook writes it down. The strained/broken/excommunication creed-loss spells therefore cannot fire in normal play. The entire "manage your honor" tension - the heart of the Knight's Road as written - is unreachable until a degradation hook is added. The Knight's Road organic earn that DOES fire is the two-quest vow lane (Book of Love t02 s200, Laid to Rest MS14 s200) plus the shared CSV/matrix Divine rows.

- **Green Way is wired through harvest, not location.** The four curated Spriggan/Nirnroot harvests organically raise DruidicStanding +25 and award Kynareth +3.0. But "visit a standing stone" and "walk nature sites" - presented as the core Green Way acts - have NO organic location hook; only the Eldergleam quest-stage (89282 s100) routes the lane by quest. The Green Way BOOK pool is a single flagged PLACEHOLDER (The Wispmother). Outdoor sleep feeds the shared CSV rows (Y'ffre/Kynareth), NOT the druidic track.

- **DruidicStanding is pressure-only** (gates no reward; frays -1/dawn for a live/contested druidic covenant). The Green Way reward family is gated by the werewolf Druidic-fork choice (`IsBretonGreenWayForkEligible`), not by the standing number.

- **Neglect** is a >5-day-since-last-CURATED-signal timer, not a piety threshold, and CSV acts do not reset it. Because Green Way location acts are STUB and Knight's Road relies on two rare quests, a Breton can easily trip neglect between curated fires even while actively earning CSV piety.

- **Shrine-prayer piety** (Stendarr's restore-honor, Kynareth's nature credit) is unconfirmed as an organic earn across races (shrines normalized to cure-only).

- **Magnus ancestor spine** (+1.0 SIGNAL_ANCESTOR_SPINE) is the one lane that fires under all three traditions - every curated Handle* hook and sleep event calls `AwardBretonAncestorSpinePulse`.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Your tradition *is* your blessing, and it grows in two stages. You earn the first two tiers (Seeker and Devoted) by practicing your tradition *broadly* - honoring any of its gods advances the same family, capped at Devoted. The top tier (Champion) comes only when you commit to a single god within the tradition. Only your chosen tradition's family pays; the other two stay dormant. Remember, only one temporary favor blessing can be active at a time across all your gods.

(There is no separate generic "Tradition" blessing. An earlier beta granted a flat Health-regeneration "Tradition's Footing" buff on top; that has been retired so your tradition's own flavor pays from the very first tier.) `[WIRED 2026-07-12: the generic PDV_Bless_Breton_Tradition_T1/T2 lane is RETIRED and force-removed on migration; SyncBretonTraditionRewardFamily now lights T1/T2 from best-of-pool tradition breadth (capped at Devoted) and T3 from the focused patron. See breton-tradition reconciliation.]`

Knight's Road (Seeker/Devoted from broad practice; Champion from focusing one god):

| Tier | What you gain |
|------|----------------|
| Seeker | Block +5 |
| Devoted | Block +13, Restoration +8 |
| Champion | Block +25, Restoration +18, Armor +50 |

Hidden Art (focused - the strongest family, because Exposure is the price):

| Tier | What you gain |
|------|----------------|
| Seeker | Conjuration +6 |
| Devoted | Conjuration +15, Illusion +9 |
| Champion | Conjuration +27, Illusion +21, Magicka Regeneration +8% |

Green Way (focused):

| Tier | What you gain |
|------|----------------|
| Seeker | Stamina Regeneration +4% |
| Devoted | Stamina Regeneration +10%, Restoration +8 |
| Champion | Stamina Regeneration +20%, Restoration +18, Health Regeneration +10% |

The Hidden Art's numbers are deliberately the biggest in the race, but they are not a free upgrade - they only hold while you carry the cost of rising Exposure. If your cover is blown, that strength is revoked until you answer for it.

## Unique Mechanics

The Breton's whole identity is the three traditions and their hidden tracks, which pull against one another.

The first thing that makes a Breton feel different is that one starting choice forks your entire faith into three barely-overlapping playstyles - a holy knight, a secret witch, or a forest druid - and you live with it. There is no fallback and no easy switch.

The second is the hidden track that watches you. Whichever path you walk, something is keeping score behind the standard piety bar: your honor as a knight, your exposure as a witch, or the covenant's standing as a druid. These tracks rarely pay a bonus of their own. Instead they decide whether your blessings work at all. A knight who loses his honor finds his vow hollow. A witch whose cover breaks finds her art turning against her. This is the heart of playing a Breton: you manage your public face alongside your actual practice.

The tracks also drag on each other. Occult acts can badly wound a knight's honor and raise exposure. Knightly public worship can slowly lower exposure, but it cannot erase a serious occult commitment. The Knight's Road and the Green Way can overlap gently through mercy, protection, and respect for nature. The Hidden Art and the Green Way meet mainly at Hircine and old magic - which creates pressure and a hard choice rather than a free hybrid.

If you break your creed, the consequence fits the tradition. Breaking a vow drops your Block and Restoration until repaired. A blown cover turns your Conjuration and Illusion against you. Turning from the druidic covenant costs your Stamina Regeneration and Restoration. A full, story-caliber betrayal of your tradition gets you cast out entirely, with your health regeneration cut until you earn your way back. `[MIXED: the creed-loss spells exist and are wired to their tracks - Hidden Art rupture (Exposure >= 100) and Green Way betrayal (Druidic fork = Betrayed) can fire, but the Knight's Road vow-break spells are UNREACHABLE because KnightlyVowIntegrity never degrades (see How You Lose Piety / Review Notes). The Betrayed Druidic fork is also never SET by any organic caller, so the Green Way betrayal spell is likewise effectively unreachable in normal play.]`

## If You Are Cursed (Vampire or Werewolf)

What happens to your faith depends entirely on your tradition - and the werewolf curse on the Green Way is the one place in the whole game where the curse becomes a real theological *choice* instead of just a penalty.

Vampirism: `[PARTIAL: the Breton curse handler sets PDV.Curse.Breton.RestorationState (2 while cursed, 1 after a cure) which suppresses the Magnus ancestor substrate at dawn via RunDawnRefreshBretonAncestor. The per-tradition flavor below (Divines lost / Volkihar home / Y'ffre halts) is largely narrative - there is no distinct tradition-specific vampire piety-halt mechanic beyond the shared substrate suppression and the general curse system.]`

- Knight's Road: a horror. The Divines are lost to you and your knightly oaths are broken, with no positive substitute. This is the worst outcome for a cursed knight.
- Hidden Art: a partial home. The Volkihar court and witch-mothers accept you, and a Daedric patron near Molag Bal may remain reachable.
- Green Way: a betrayal-pressure state. Your Y'ffre devotion halts until an authored way back exists; a fuller restoration is planned but not yet in.

Werewolf:

- Knight's Road: theologically homeless. There is no framework for it, you pay a social and knightly cost, and your honor degrades each time you transform. `[INERT: "honor degrades each time you transform" is not wired - no werewolf-transform hook writes KnightlyVowIntegrity down (it is never lowered by anything). Designed-but-unbuilt.]`
- Hidden Art: a natural fit. Hircine already lives in this frame, the Glenmoril witches are practically family, and there is no penalty. `[WIRED (by absence): no Hidden Art werewolf penalty exists in ApplyBretonCurseHandlers, matching the design.]`
- Green Way: this is the special case. `[PARTIAL: the fork exists and flips on transform, but it is NOT presented as a player choice. ApplyBretonCurseHandlers auto-sets the Druidic fork to WEREWOLF the first time a Green Way / Druidic-fork Breton transforms (and back to Druidic on cure); there is no MessageBox trial and no "beast serves the Green" vs "Hircine's gift is mine" branch. The BETRAYED fork - the whole "the covenant rejects you, Y'ffre closes, Exposure rises" branch below - is never set by any organic caller, so that outcome is designed-but-unbuilt. What actually happens: transform silently flips your fork to Werewolf, which gates the Green Way reward family off (IsBretonGreenWayForkEligible requires the Druidic fork).]` The moment you first transform, a one-time "Druidic Trial" fires and you must choose. "The beast serves the Green" - the covenant accepts the shape as deepened kinship with the wild, your Y'ffre devotion resumes fully, and the Hircine path is closed to you because you declared your loyalty. Or "Hircine's gift is mine" - the covenant rejects you, Y'ffre closes, your drift toward Hircine begins, and your Exposure rises because a beast-pact is visible. This choice is permanent. Druidic circles themselves are split on werewolves, so the game hands you the same dilemma the druids have.

## Quick Reference

- Gods: Knight's Road - Stendarr, Akatosh, Mara, Arkay (and Julianos, Zenithar, Kynareth, Dibella). Hidden Art - Julianos plus Daedric Princes (Hermaeus Mora, Hircine, Namira, Nocturnal). Green Way - Y'ffre, Magnus, Phynaster, Kynareth.
- Starting choice: pick one tradition - Knight's Road, Hidden Art, or Green Way. Required, no fallback, and locked for the playthrough.
- Top 3 ways to gain: (Knight) help without reward, choose mercy, pray at Divine shrines. (Hidden Art) complete Daedric quests, use Daedric shrines, read occult texts. (Green Way) sleep outdoors, visit standing stones, walk nature sites.
- Main ways to lose: harming the innocent and raising undead; theft and Daedric bargains (for the Divines); neglecting your tradition; broad worship caps you at Devoted; and your hidden track - lost honor, blown cover, or faded covenant - suppressing or revoking your blessings.
- Rough days to Champion: about 30-45 days of normal play, near 20 if you focus on one god. The Knight's Road is the hardest Champion in the game to keep, because corruption is always on offer.
