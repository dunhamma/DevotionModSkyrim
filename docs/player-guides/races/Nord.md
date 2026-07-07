# Nord - Two pantheons, one banned god, and the deity who finally claims you

## Overview

Nords carry two faiths at once and rarely lose sleep over it. The Old Ways honor the gods of Atmora and Sovngarde - Kyne, Shor, Tsun, Stuhn, and Mara - alongside Talos, the Hero-God of Man. The Nine Divines bring the more temple-tidy Imperial roster - Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth - and Talos stands in that crowd too, though the Thalmor would see him struck from it. Most Nords blend the two without theological anxiety, but every Nord in Skyrim has quietly taken a side on the Talos ban whether they admit it or not.

For a Nord, faith is not a starting package handed to you. It is something your deeds reveal. You do not pick which god you serve. You live - you hunt, you fight, you defy the ban, you build a hearth - and at some point a god notices that the way you live points toward them, and offers to claim you. Until that moment you are a broad worshipper of your whole pantheon, honored by all and beloved by none in particular.

The big choice at the start is which pantheon frames your worship: the Old Ways or the Nine Divines. After that, the choice that matters most is one you do not consciously make - it is made for you, by how you actually play.

## Your Gods

If you start on the Old Ways, these are the gods who can claim you:

- **Kyne** - the storm-mother, widow of Shor, goddess of the wind, the hunt, and the open sky. The most "Nord" patron there is.
- **Talos** - the Hero-God of Man, the conqueror who mastered the Thu'um. Worshipping him openly is forbidden by the Thalmor, which is exactly why Nords do it.
- **Shor** - the old king of Atmora, lord of the Sovngarde mead-hall, who weighs your valor and your honorable kills.
- **Tsun** - shield-thane of Shor, god of trials and adversity, who guards the whalebone bridge to Sovngarde.
- **Stuhn** - the shield-god, brother of Tsun, who governs ransom, the just division of spoils, and mercy toward a beaten foe.

If you start on the Nine Divines, you can be claimed by **Akatosh**, **Mara**, **Arkay**, **Stendarr**, **Zenithar**, **Dibella**, **Julianos**, or **Kynareth** - and Talos remains reachable in either pantheon. A Nord under the Divines still lives like a Nord: holds, weather, household duty, death rites, honor, and Talos pressure, just wearing temple names instead of old mythic ones.

A few gods are off the table for Nords by design: Alduin (feared, not worshipped), Orkey (propitiated as an enemy-god), and Jhunal (forgotten by the Fourth Era). Foreign gods and the Daedric Princes are not part of normal Nord worship. The one Daedric road open to you is Hircine, and it opens only through the curse of lycanthropy - see "If You Are Cursed" below.

## Getting Started

At the very start you set your **pantheon baseline**: Old Ways or Nine Divines. This is a framing choice. It decides which gods can notice you and what names and stories your worship wears. The underlying way devotion works is the same either way - only the roster and the flavor change.

- **Old Ways** points you at Kyne, Talos, Shor, Tsun, and Stuhn. This is the mythic, hold-born, ancestors-and-Sovngarde frame. It leans into weather, the hunt, honorable combat, and quiet defiance of the Talos ban as ancestral identity.
- **Nine Divines** points you at the eight Imperial Divines plus Talos. It is the more temple-readable frame, but it still plays like a Nord - the difference is moral and verbal more than mechanical. Here, carrying Talos in your heart is a contradiction held inside a public Divine faith.

You do not commit to a single god at the start. You begin as a **broad worshipper** of your chosen pantheon. You earn devotion across several gods at once, and that broad worship is its own honored path - but it caps you at the Devoted tier. To reach Champion, you must commit to one god when they offer to claim you. That offer is the heart of the Nord experience, and it is covered under Unique Mechanics.

For how the tiers, the piety bar, and the panels work in general, see the How Devotion Works primer.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (patron/pantheon state, property-based call, active-deity gate)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Deltas from PDV_DeityLikesDislikes.csv (day-to-day) and PDV_Deity_*.psc DELTA_*/SIGNAL_* (curated). -->

Nord worship is led by deeds, not by kneeling at shrines. Variety matters far more than repetition - doing the same deed over and over earns less each time, and each god's daily devotion is capped at roughly 4.3 piety per day. Lead with these:

- **Hunt and fight honorably.** Killing a worthy, armed foe in fair combat pleases Shor, Tsun, and Stuhn. A genuine hunt - killing an animal without a sneak attack - is Kyne's deed (and Shor's). This is the most reliable Nord road to devotion. `[WIRED: Story Manager kill event -> HandleStoryKillActor classifies the victim -> CSV kill-hostile-humanoid (2): Shor +0.5, Tsun +0.75, Stuhn +0.5, Talos +0.5, Kyne +0.5. Kyne kill-hostile-beast (1) is a small penalty (-0.5), not a gain; there is no organic "clean animal hunt" reward hook.]`
- **Learn and use the Thu'um.** Learning a Word of Power honors Talos, Kyne, Shor, Tsun, and (in the Divines frame) Julianos and Kynareth. Talos and Kynareth especially treasure it - the Voice is the warrior-god's mastery and the wind given form. `[WIRED: learn-word-of-power (343) via Story Manager new-voice-power -> HandleStoryNewVoicePower -> CSV Talos +1.0, Kyne +1.0, Kynareth +1.0, Julianos +0.75, Tsun +0.25, Shor +0.5. Using a shout also scores via OnShoutAttack -> HandleShoutAttack, but that path is property-based: Kyne DELTA_SHOUT_ATTACK +0.35 and Talos +0.5 only (the CSV shout-attack rows are NOT read).]`
- **Defy the Talos ban.** Helping a Talos worshipper, activating a hidden Talos shrine, or refusing to report the faithful are among the strongest Nord deeds. Only costly, faithful defiance counts - ordinary anti-Thalmor violence or plain Civil War preference does not. `[STUB: HandleTalosShrineDefiance -> Talos SIGNAL_SHRINE_DEFIANCE exists but is reached only via the dev-only PDV_EventSignalActivator RouteTalosShrineDefiance and the debug MCM (PDV_MCM 2543). No organic shrine-activate / help-worshipper / refuse-to-report hook fires it. There is no Nord/Talos defiance ref in PDV_FinalPlacementManifest.json.]`
- **Slay dragons.** Felling a dragon is a major deed for Talos, Shor, and Tsun - the worthiest trial and the conqueror's supreme glory. `[WIRED: kill-dragon (302) via HandleStoryKillActor (ActorTypeDragon classification) -> CSV Talos +1.5, Kyne +1.0, Shor +1.0, Tsun +0.75.]`
- **Rest under the open sky.** Sleeping outdoors, not in an inn or a house, pleases Kyne, Kynareth, Shor, and Tsun. Genuine open-sky rest only - menu naps and indoor beds do not count. `[WIRED: OnSleepStop -> RouteGenericAction(EVT_REST_UNDER_OPEN_SKY) when slept outside -> CSV rest-under-open-sky (313): Kyne +0.5, Kynareth +0.75, Shor +0.25, Tsun +0.25. Note: sleeping at an interior "hearth" is a SEPARATE Shor ancestral-rest signal, not open-sky.]`
- **Tend the dead and the living.** Putting the restless undead to rest honors Arkay, Shor, Tsun, and Stuhn. Healing or curing others honors Mara, Stendarr, Stuhn, and Arkay. Completing a Hall of the Dead or burial quest is a strong one-time deed for Arkay. `[WIRED: kill-undead (300) via HandleStoryKillActor -> CSV Arkay +0.5, Shor +0.5, Tsun +0.5, Stuhn +0.25, Kyne +0.5, Stendarr +0.5. heal-or-cure-npc (350): Mara +0.75, Stendarr +0.5, Stuhn +0.75, Arkay +0.5, Kyne +0.25, Dibella +0.25, Tsun +0.25. The burial/Hall-of-the-Dead one-time deed is QUEST-only, see the review block.]`
- **Build a hearth and defend a hold.** Marriage, investing in a home, freeing prisoners, and aiding a hold are Mara's and Stuhn's deeds - meaningful community defense, not generic chores. `[QUEST: no organic marriage/home-invest/free-prisoner/aid-hold day-to-day hook exists in the likes table. These reach Nord play only through the quest-reaction matrix (e.g. Message to Whiterun for Talos/Kyne, Pieces of the Past / Waking Nightmare mercy for Stuhn). The interior "hearth-rest" that fires organically (HandleNordSleepEvents / HandleNordLocationChange) feeds Shor's ancestral-rest signal, not a Mara/Stuhn hold reward.]`
- **Do honest work and learn.** Smithing, enchanting, mining, and brewing of real quality please Zenithar; reading skill books, spell tomes, and lore please Julianos and Dibella. Clearing a bounty by serving your time pleases Stendarr, Mara, and Zenithar. `[WIRED: CSV Zenithar smith-item (330) +0.5, enchant-item (331) +0.5, brew-potion (332) +0.25, cook-meal (333) +0.25; Julianos read-skill-book (340) +0.5, read-spell-tome (341) +0.5, read-lore-book (342) +0.5, increase-skill (344) +0.25; Dibella smith/enchant/lore +0.25-0.5. clear-bounty-serve-time (351): Stendarr +0.75, Mara +0.5, Zenithar +0.5. No dedicated "mining" event; mining is not in the table.]`

## How You Lose Piety

Nord loss is rarely a hammer-blow. Most of it is drift and distance.

- **Dislikes.** The clearest sin across nearly every Nord god is **murdering the defenseless** - it bars the door to Sovngarde for Shor, Tsun, and Stuhn (Stuhn reacts hardest of all), and offends Mara, Stendarr, and Julianos. **Raising the dead** angers Arkay, Shor, Tsun, Stuhn, Stendarr, Kynareth, and Dibella. **Theft, trespass, and picking owned locks** offend Zenithar, Stuhn, Stendarr, Mara, and Julianos. Accepting Daedric artifacts repels Stendarr, Kynareth, Tsun, and Arkay. `[WIRED: CSV dislikes - murder-defenseless (304): Stuhn -2.0, Shor/Tsun/Mara/Julianos -1.5, Kyne/Stendarr/Zenithar/Kynareth/Dibella/Arkay -1.0, Talos -0.75. raise-undead (365): Arkay -1.5, Stendarr -1.5, Shor/Tsun/Stuhn/Mara/Kynareth -1.0, Dibella -0.75. steal-item (362): Zenithar/Stendarr -0.75, Stuhn -0.75, Mara/Julianos/Talos/Shor -0.5. pick-owned-lock (360): Zenithar/Stuhn -0.5. trespass (361): Zenithar/Stendarr/Julianos -0.25. accept-daedric-artifact (368): Stendarr/Kynareth/Tsun/Arkay/Kynareth -0.75 to -1.0, Zenithar -0.75. assault-innocent (364) also offends Mara/Stendarr/Arkay/Julianos/Dibella/Shor/Tsun/Talos. All fire via the generic event routers (OnItemRemoved/OnObjectEquipped/HandleStoryKillActor/lockpick/trespass).]`
- **Talos creed.** If Talos has claimed you and then you bend the knee - reporting a worshipper, surrendering a hidden shrine, or complying with the ban - your devotion drops. Openly aiding the Thalmor against the faith is the worst betrayal of all. `[STUB: the counterpart to the defiance gain - there is no organic report-worshipper / surrender-shrine / comply-with-ban hook. The Talos defiance lane (SIGNAL_SHRINE_DEFIANCE) is only reachable dev-only/MCM, so its betrayal inverse has no organic trigger either. Nord has no Concordat reputation bar (that is Imperial-only).]`
- **Kyne's creed.** Kyne does not abide needless slaughter of her creatures. Wanton killing of beasts cools her favor. `[WIRED: CSV kill-hostile-beast (1) Kyne -0.5, capped 2/day (softened for self-defense fairness) via HandleStoryKillActor. This is the only "wanton beast" penalty; there is no separate non-hostile animal-slaughter hook.]`
- **Neglect (a god growing quiet).** Ignore a god and they grow distant rather than angry. Kyne's neglect is the most tangible: the weather stops feeling like it is on your side, animals do not settle near you, and your stamina recovers a little more slowly at night until you return to the open sky. For Talos, the shouts start to feel like mere technique. For the rest, the small graces simply dry up and the ancestors go quiet. `[PARTIAL: the neglect flag sets when a god's piety lapses, but the FELT neglect spells only apply once that god has CLAIMED you - SyncKyneNeglectSpell is gated to IsNeglectFlagActive(PDV_Kyne) && _activeDeity == PDV_Kyne, and the per-patron Shor/Tsun/Stuhn/Talos neglect spells are each gated to _activeDeity == that god. A broad worshipper who never committed feels no neglect debuff.]`
- **Natural drift.** If you stop living the way your patron expected - a Kyne Champion who moves to a city and never goes outside again - that bond slowly fades from real to formal, and your tier can slip back down. `[WIRED: passive decay lowers idle piety over time per deity; tier can slip as piety falls below a threshold.]`
- **The broad-worship cap.** Honoring your whole pantheon keeps you at Devoted. That is not a penalty - it is the natural ceiling of breadth. Reaching Champion simply requires committing to one god. `[WIRED: broad worship caps at Devoted until a patron offer is accepted.]`

Nord has no formal reputation meter the way Imperials carry a Concordat standing. Your defiance of the Talos ban is tracked as individual deeds, not a sliding political bar. `[NOTE: this is literally true - there is no Nord Concordat track; but it undersells the gap. The "defiance deed" the copy leans on is not organically trackable at all (STUB), so in normal play Talos-defiance piety currently comes only from quest-matrix rows, not from any defiance act you perform freely.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Nord gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (magnitude `small` or `milestone` with a real UESP/quest citation) are promoted and fire when the quest is on the watch list; "echo" rows carry a "cross-gen candidate ... reviewed" citation and are **not** promoted (INERT).

**Kyne**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Dragon Rising (MQ104) | 160 | Killed Mirmulnir, absorbed first dragon soul | + / S / small | WIRED |
| The Way of the Voice (MQ105) | 160 | Took up the Voice at High Hrothgar | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Slew Sahloknir at Kynesgrove | + / S / small | WIRED |
| Alduin's Bane (MQ206) | 220 | Drove off Alduin with Dragonrend | + / S / small | WIRED |
| Dragonslayer (MQ305) | 200 | Destroyed Alduin | + / S / small | WIRED |
| Message to Whiterun (CW03) | 16 | Warned Whiterun, readied the kin-hold | + / m / small | WIRED |

Plus 16 echo rows (prove_by_struggle / kill_honorable across Companions, Civil War, Dark Brotherhood, Bleak Falls, etc.) flagged REVIEW -> INERT.

**Talos**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Joining the Stormcloaks | 160/200 | Took the oath, joined the Sons of Skyrim | + / C / milestone | WIRED |
| The Jagged Crown | 30/200 | Drove the Empire out, delivered the Crown to Ulfric | + / C / milestone | WIRED |
| Message to Whiterun (CW03) | 100/240 | War on Whiterun (Stormcloak completion) | + / C / milestone | WIRED |
| Take Up Arms (C00) | 20 | Trial of arms with Vilkas | + / m / small | WIRED |
| Proving Honor (C01) | 200 | Earned a place by judged valor | + / S / small | WIRED |
| The Way of the Voice (MQ105) | 160 | Mastered the new Voice powers | + / S / small | WIRED |
| The Horn of Jurgen Windcaller | 60 | Greeted formally as Dragonborn | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Killed the dragon, absorbed its power | + / S / small | WIRED |
| Sovngarde (MQ305) | 200 | Reached the Hall of Heroes | + / S / small | WIRED |
| Joining the Legion | 1 | Cleared Fort Hraggstad | + / S / small | WIRED |
| Silver Hand / Blood's Honor / Purity of Revenge (C03/C04/C05) | 200 | Companions valor arc | + / S / small | WIRED |
| Message to Whiterun (CW03) | 16 | Assisted with the dragon threat | + / m / small | WIRED |
| Hitting the Books (MG03) | 55 | Freed Orthorn (rescue) | + / m / small | WIRED |
| Containment (MG05) | 200 | Protected Winterhold | + / m / small | WIRED |

Plus 10 echo rows flagged REVIEW -> INERT.

**Shor**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Silver Hand (C03) | 200 | Silver Hand stronghold battle | + / C / milestone | WIRED |
| Blood's Honor (C04) | 200 | Killed the Glenmoril Witches | + / C / milestone | WIRED |
| Purity of Revenge (C05) | 200 | Avenged Kodlak, ruined the Silver Hand | + / C / milestone | WIRED |
| A Blade in the Dark (MQ106) | 200 | Killed the dragon at Kynesgrove | + / C / milestone | WIRED |
| Proving Honor (C01) | 200 | Earned a place by valor | + / S / small | WIRED |
| Glory of the Dead (C06) | 65 | Defeated the wolf spirit | + / S / small | WIRED |
| Joining the Legion | 1 | Cleared the bandits | + / C / small | WIRED |
| (Thalmor assassin, unnamed) | 100 | Killed the armed Thalmor agent | + / C / small | WIRED |
| To Kill an Empire (DB09) | 50/200 | Treacherous poison kill (-) / return (+) | -/+ / S / small | WIRED |
| Recipe for Disaster (DB08) | 200 | Treacherous contract kills | - / S / small | WIRED |
| Hail Sithis! (DB11) | 200 | Treacherous kill | - / S / small | WIRED |

Plus 12 echo rows flagged REVIEW -> INERT.

**Tsun**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Proving Honor (C01) | 200 | Retrieved a Wuuthrad fragment, valor judged | + / C / milestone | WIRED |
| The Way of the Voice (MQ105) | 160 | Passed the trials of the Voice | + / C / milestone | WIRED |
| The Silver Hand (C03) | 200 | Killed the werewolf hunters | + / S / small | WIRED |
| Blood's Honor (C04) | 200 | Killed the Glenmoril Witches in battle | + / S / small | WIRED |
| Purity of Revenge (C05) | 200 | Wiped out the Silver Hand | + / S / small | WIRED |
| Dragon Rising (MQ104) | 160 | Killed the dragon | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Killed the dragon | + / S / small | WIRED |
| Sovngarde (MQ305) | 200 | Reached the Hall of Heroes | + / C / small | WIRED |

Plus 12 echo rows flagged REVIEW -> INERT.

**Stuhn**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Bound Until Death (DB05) | 200 | Killed Vittoria Vici (helpless target) | - / C / milestone | WIRED |
| Pieces of the Past (DA07) | 150 | Refused to kill Silus - mercy to the beaten | + / m / small | WIRED |
| Waking Nightmare (DA16) | 200 | Let Erandur live - mercy to the yielding | + / m / small | WIRED |
| Death Incarnate (DB10) | 70 | Finished the doomed Brotherhood remnants | - / S / small | WIRED |

Plus 14 echo rows flagged REVIEW -> INERT.

**Nine Divines note.** The Nine Divines gods carry their own promoted rows too (Arkay ~11, Stendarr ~22, Mara ~13, Julianos ~8, Dibella ~8, Akatosh ~8, Kynareth ~5, Zenithar ~3 promoted rows, with matching echo tails). These are shared cross-race quest reactions, not Nord-specific hand-authoring, and they fire for a Nord under the Divines exactly as for any other race that can be claimed by those gods.

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires organically (for owner triage):

- **Talos-defiance is the biggest gap.** "Defy the Talos ban" is sold as one of the top three Nord deeds, but there is NO organic hook for it. `HandleTalosShrineDefiance` / Talos `SIGNAL_SHRINE_DEFIANCE` is reachable only from the dev-only `PDV_EventSignalActivator` and the debug MCM. There is no hidden-Talos-shrine placement ref in `PDV_FinalPlacementManifest.json`, no "help a worshipper" hook, and no "refuse to report" hook. In normal play, Talos piety comes from CSV combat/word-of-power/discovery rows and the quest matrix (Stormcloak/Companions/Main Quest), not from any act of defiance you choose. This is the prime remap target for the race.
- **The "honorable hunt" half of combat is not a reward.** Kyne's only organic animal interaction is a small PENALTY (kill-hostile-beast -0.5). There is no "clean first-arrow animal hunt" gain hook; the honorable-combat gains all come from kill-hostile-humanoid and kill-dragon.
- **Thu'um-in-use is property-based, not table-based.** Learning a Word of Power reads the CSV normally. USING a shout (OnShoutAttack) is scored only through the hard-coded `DELTA_SHOUT_ATTACK` properties on Kyne (+0.35) and Talos (+0.5); the CSV shout-attack (40) rows are explicitly NOT read. Other gods get nothing from using a shout.
- **Hearth / hold is quest-only.** "Build a hearth and defend a hold" (marriage, home, freeing prisoners, aiding a hold) has no day-to-day like row. The only organic "hearth" hook is the interior sleep/return signal (`HandleNordSleepEvents` / `HandleNordLocationChange`), which feeds Shor's ancestral-rest substrate, NOT a Mara/Stuhn hold reward. Community-defense credit reaches the player only through the quest matrix.
- **Neglect is felt only after commitment.** Every Nord neglect debuff (Kyne weather/stamina; the per-patron Shor/Tsun/Stuhn/Talos flat spells) is gated to `_activeDeity == that god`. A broad worshipper who never accepted an offer never feels neglect, so the "shouts feel like technique" / "weather stops helping" copy only applies to a claimed patron.
- **Dead code:** `HandleNordAncestorSpine` (the general Shor ancestor-spine signal) has NO caller anywhere in live-source - only `RecordNordAncestralRest` (sleep) and `RecordNordHearthReturn` (location) invoke the underlying record function. Worth pruning or wiring.
- **Hircine hunt-rite gain is STUB.** The werewolf-curse state penalties fire organically, but the Hircine hunt-rite REWARD lane (`HandleHircineHuntRite`) is dev-only/MCM, same pattern as the Talos defiance lane.
- **Old Ways vs Nine Divines coverage:** the Old Ways patrons (Kyne/Shor/Tsun/Stuhn) get bespoke Nord signal wiring plus the shared CSV/quest rows; the Nine Divines gods rely almost entirely on the shared CSV rows and shared cross-race quest matrix. Both pantheons are organically reachable, but Old Ways has more Nord-specific hooks.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

There are two layers. The **broad layer** is what you get for honoring your whole pantheon. The **focused layer** is what you get once a single god claims you. Broad bonuses are deliberately softer than a committed patron's, and they switch off once you commit.

**Broad worship (Old Ways), caps at Devoted:**

| Tier | Bonus |
|------|-------|
| Seeker | Stamina Regeneration +4% |
| Devoted | Stamina Regeneration +6%, Frost Resistance +10% |

(The Nine Divines broad-worship path gives a comparable blended favor set, framed in Divine terms.)

**Focused patron bonuses (Old Ways gods).** All share the same shape: a modest Seeker sign, a stable Devoted blessing, and a Champion capstone with a unique scripted moment on top of the numbers.

- **Kyne** - Seeker: Stamina Regen +5%. Devoted: Stamina Regen +10%, Frost Resist +10%. Champion: Stamina Regen +20%, Frost Resist +25%, plus "The Storm Answers."
- **Shor** - Seeker: Health Regen +5%. Devoted: Health Regen +15%, One-Handed +8. Champion: Health Regen +27%, One-Handed +18, Two-Handed +10, plus "Sovngarde Looks Back" (this capstone carries the Nord's single last-stand save).
- **Tsun** - Seeker: Stamina Regen +5%. Devoted: Stamina Regen +10%, Block +10. Champion: Stamina Regen +20%, Block +22, Armor +50, plus "The Shield-Thane's Trial."
- **Stuhn** - Seeker: Armor +15. Devoted: Armor +30, Block +8. Champion: Armor +50, Block +18, One-Handed +8, plus "Just Spoils, Honored Bonds."
- **Talos** (reachable in either pantheon) - Seeker: Armor +15. Devoted: Armor +30, One-Handed +8. Champion: Armor +50, One-Handed +20, plus "Triumph of Faithful Defiance." Reached only through costly faithful defiance - compliance never builds it.

**Focused patron bonuses (Nine Divines).** Each of the eight Divines has its own three-tier blessing in the Nord frame - for example Kynareth leans into Stamina and Frost like an open-sky cousin to Kyne, Mara into Healing, Stendarr into Block and Armor, Zenithar into carrying capacity and craft. Every Champion tier carries that god's signature moment. Exact magnitudes for the Divine families are still being finalized; expect the same general shape as the Old Ways gods above, with no single combat bonus exceeding about 12%.

## Unique Mechanics

**The offer is the whole point.** No Nord chooses their patron from a menu. You worship broadly, you live a certain way, and the game watches. When you have built real, sustained devotion toward one god - reaching the Devoted threshold, with that god seeing meaningful activity on at least two separate days in the past week - that god may approach you at dawn and offer to claim you. The god that shows up is the one that matches how you actually played: hunt and camp and shout, and Kyne comes; fight for the cause and defy the ban, and Talos comes; build a home and mend the broken, and Mara comes.

**You can say "Not yet."** Declining never costs you piety. It only sets a cooldown before that god offers again (seven days the first time, fourteen after). Broad worship continues, other qualifying gods can still step forward, and your play can drift toward someone new. A Nord who refuses Kyne and then turns to the forge may find Zenithar knocking instead.

**Commitment is a living bond, not a brand.** When you accept, you keep most of your built-up devotion (a generous carry-over), the offer becomes your one patron, and Champion opens up. But the bond is not permanent paperwork - it must be fed. Stop living the way your patron expects and the relationship frays back down. This is the Nord signature: not a rule imposed on you, but the slow truth of who you turn out to be.

## If You Are Cursed (Vampire or Werewolf)

**Werewolf - the Hircine road.** The beast-blood opens a real Daedric path under Hircine, with the Hunting Grounds set against Sovngarde. While you are transformed or deep in the werewolf arc, your gains toward Shor, Tsun, and Stuhn are reduced - their honored dead and the Hunting Grounds claim the same soul. Kyne is not punished, but your deeds tilt from storm toward hunt. There is a way back: curing or renouncing the curse begins your recovery, though a readable "hunt-residue" lingers until that recovery fully advances. `[WIRED: OnLycanthropyStateChanged -> RouteCurseRefresh drives the curse state; the werewolf onset message and Shor/Tsun/Stuhn reduction fire from the curse-state service. The separate Hircine hunt-rite GAIN (HandleHircineHuntRite) is STUB - dev-only activator / MCM only, no organic transform-kill hook.]`

**Vampire - the road to Sovngarde closes.** Vampirism severs your claim to the mead-hall. While the curse holds, your Nord patron offers and favors are suppressed, your standing tells you plainly that Sovngarde is shut to you, and Kyne, Mara, and Shor's path all weaken. Curing the disease restores your access - but it leaves a permanent scar, a lowered ceiling that reflects the rupture you suffered. Your earned piety is not wiped; the door simply never opens quite as wide again. `[WIRED: OnVampirismStateChanged -> RouteCurseRefresh; vampire onset suppresses Nord patron offers/favors and shows the "Sovngarde is closed while the thirst remains" standing message. Cure restores access with a lowered ceiling scar.]`

## Quick Reference

- **Gods (Old Ways):** Kyne, Talos, Shor, Tsun, Stuhn. **(Nine Divines):** Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth, plus Talos.
- **Starting choice:** Old Ways or Nine Divines pantheon baseline; broad worship first, then a god offers to claim you.
- **Top 3 ways to gain:** honorable combat and the hunt; learning and using the Thu'um; costly defiance of the Talos ban (plus open-sky rest, death rites, hearth and hold for the right gods).
- **Main ways to lose:** murdering the defenseless and raising the dead; betraying the Talos faith once committed; theft and Daedric bargains; neglect and natural drift; the Devoted cap on broad worship.
- **Rough days to Champion:** about 30 to 45 days of normal play, roughly 20 if you focus hard on one god - and you cannot reach it at all until you accept a patron's offer.
