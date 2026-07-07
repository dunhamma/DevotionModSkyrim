# Redguard - sect, sword, and the duty owed to the dead

## Overview

For a Redguard, faith is not a quiet thing you do at a shrine. It is the Yokudan gods of the Far Shores, the ancestors who watch from beyond, and the hard work of putting the restless dead back in their proper place. Your people held the Alik'r against the Aldmeri Dominion when the Empire could not. That victory is theologically real to a Redguard: the Make Way God proved himself again, and the dead who fell for it are watching with something that is not regret.

But you are not in Hammerfell. The sands are gone, the temples are gone, and the dead here in Skyrim - the draugr, the restless spirits, the improperly buried - are an offense to the order your gods keep. Every death encounter is a theological moment for you. A draugr is not just another dungeon enemy; it is a soul out of place, and that is your domain.

The big choice comes at the very start: you pick a sect. Crown, Forebear, or Ash'abah. All three honor the same Yokudan gods - they differ in emphasis and burden, not in theology. The ancestors are always with you, no matter which road you walk. For a primer on how piety, tiers, and patrons work across all races, see the How Devotion Works article.

## Your Gods

Your pantheon is Yokudan - the gods of Hammerfell and the Far Shores. Only three of them can become your single chosen patron (your "focus"); the rest live in the background as the spirit of your sect and your ancestor reverence.

The three you can commit to:

- **Tu'whacca** - the guide of the dead, the soul-keeper who leads the fallen to the Far Shores. The god of death duty, wards, and restoration. He is at the heart of every Redguard's faith.
- **HoonDing** - the Make Way God, the Walker-Who-Makes-Way. He appears only in rare moments of true make-way: impossible odds, honorable adversity, a battle that should have been lost.
- **Leki** - the Lady of Swords, saint of the Sword-Singers. She rewards martial conduct and disciplined sword form, not raw kills.

The wider Yokudan spine you honor but cannot focus on: **Satakal** (the Worldskin, the endless cycle of devouring and renewal), **Ruptga** / Tall Papa (the first to find the Far Shores), **Tava** (the bird-goddess of good passage and the open road), and **Onsi** (the warrior who taught the people to draw swords).

Note on Tu'whacca and Arkay: in Skyrim you will sometimes do your death duty in Nord spaces like the Hall of the Dead. You are not worshipping Arkay. You are using Skyrim's death institutions while you address Tu'whacca. The mod always speaks of Tu'whacca, never Arkay, when it credits your devotion.

Foreign gods and the Daedric Princes are not part of the Redguard path. A Forebear may quietly recognize some of the Nine Divines (Arkay, Akatosh, Zenithar, Stendarr, Dibella, Julianos) as parallels to Yokudan gods, but the Yokudan names always come first in play, and the credit flows through your own framework.

## Getting Started

At setup you choose your sect. This is the single most important choice you make, because it shapes which deeds the gods notice and how your devotion feels. All three are equally faithful - they simply carry different burdens.

- **Crown** - orthodoxy and bearing. You carry the old way intact, in exile, exactly as it was kept in Hammerfell: the blade, the bearing, the rites. Your gods notice honorable combat, tomb respect, and keeping Yokudan form rather than sliding into Nine Divines convenience. The ancestors are strong at your back, because you are the living proof the orthodoxy still works.
- **Forebear** - adaptation and pragmatic survival. You make a life among outsiders and stay Redguard doing it. Your gods notice the open road traveled on foot, honored contracts completed under pressure, and the way-making it takes to survive a foreign province. This is the broadest, most flexible road, and it is the fallback if your sect choice is ever lost.
- **Ash'abah** - funerary duty and impurity borne for others. You take up the unclean work no one else will touch: cleansing the undead, putting the restless dead to rest, opposing necromancy. Your own people are uncomfortable around you, but Tu'whacca honors the burden few will carry. Death-duty deeds earn you strong piety; almost everything else earns you little.

Your ancestor reverence is always on, in every sect. It is strongest for Ash'abah, strong for Crown, and moderate for Forebear. It quietly generates small piety from any death-adjacent moment and builds an anti-undead quality over time.

You can change sect later, but not casually. Switching between Crown and Forebear needs two clear sect-fitting deeds on separate days within a week, judged at dawn (or one major sect-defining quest moment). Entering Ash'abah requires a real death, tomb, or impurity burden - casual undead fighting is not enough. And you will not drift out of Ash'abah just because you had a quiet week; leaving it needs a clear reorientation toward Crown or Forebear.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (sect/mode/focus state or rare condition)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Deltas from PDV_DeityLikesDislikes.csv (day-to-day) and PDV_Deity_*.psc DELTA_* (curated). -->

Remember that piety is tracked separately for each god, daily gain per god is capped at about 4.3, and repeating the exact same deed earns less each time. Variety matters far more than grinding.

Your most common and important ways to earn:

- **Defeat the undead** (draugr, skeletons, ghosts) - ending the restless dead so they reach the Far Shores. This is the bread and butter of Tu'whacca devotion and the ancestor layer. Daily capped; quality over quantity. `[WIRED: CSV Tu'whacca kill-undead (300) +0.5 (ActorTypeUndead), kill event; plus a Redguard-gated keep-the-death-duty (300) +0.25 row]`
- **Clear a draugr tomb or dungeon** - finishing the whole place, boss included. Counts once per dungeon, not per visit. Strongest for Ash'abah, meaningful for all sects. `[PARTIAL: only for the curated undead sites in PDV_FLST_RedguardAshAbahUndeadClearSites -> HandleRedguardAshAbahUndeadSiteClear (arm on visit uncleared via HandleStoryChangeLocation, credit on Location.IsCleared) -> SIGNAL_DEATH_DUTY +2.0 + ancestor spine. A generic draugr dungeon not on the list does not count as a "clear."]`
- **Complete a Hall of the Dead quest** - the most direct death-duty deed in Skyrim. One per hold, high weight, very strong for Ash'abah. `[STUB: no organic Hall-of-the-Dead quest hook; the death-duty signal lane (RouteRedguardAshAbahDeathDuty) has only the dev-only activator 07102D and unfilled P2 quest-stage sources. Related manifest ref PDV_REFR_RedguardAshAbahDeathDutySignal status:"dev-only".]`
- **Defeat a necromancer and clear their operation** - every necromancer is a religious affront; ending one is real duty. Per site. `[PARTIAL: only a UNIQUE (named) necromancer in the Necromancer/Warlock faction -> HandleRedguardAshAbahMajorBurden (eventType 2, IsRedguardNamedNecromancerBurden) -> death-duty burden +2.0. Routine necromancer mobs and "clearing the operation" have no hook.]`
- **Tend the Far Shores token** - a portable devotional surface you keep and use anywhere, praying as Tu'whacca's people do (see Unique Mechanics). Once per day. `[STUB: HandleRedguardFarShoresToken -> SIGNAL_FAR_SHORES_TOKEN +1.0 exists, but RouteRedguardFarShoresToken has only the dev-only activator 07102E (manifest PDV_REFR_RedguardFarShoresTokenSignal status:"dev-only"). No portable-token OnEquipped/activation hook is wired.]`
- **Win honorable single combat** (Crown / Leki) - no sneak opener, no follower assist, fought through to the end with a one-handed weapon. The blade tested against a worthy foe. Daily capped. `[STUB: Leki SIGNAL_HONORABLE_DUEL (2602, +3.0) has no organic caller - only a delta-lookup entry at PDV__ManagerQuest ~11429. No sneak-opener/solo-duel detector exists.]`
- **Travel the road on foot** (Forebear / Tava) - long-distance journeys, not fast travel and not short local hops. Tava blesses good passage. Daily capped. `[STUB: HandleRedguardForebearRoadPassage -> Forebear sect substrate (+ Leki sword-singing only if Leki is the active patron). Its route RouteRedguardForebearRoadPassage has only the dev-only activator 07102C (manifest PDV_REFR_RedguardForebearRoadSignal status:"dev-only") and unfilled P2 sources. No organic on-foot-distance detector. (HoonDing no longer rides road-passage.)]`
- **Complete a mercenary or contract quest honestly** (Forebear) - pragmatic honor, payment accepted without betrayal, the work done even under pressure. Per quest. (Note: generic gold-making does not count.) `[STUB: no organic mercenary/contract-honesty hook; folds into the dev-only Forebear road-passage lane above.]`
- **Defeat a lich or named undead boss** (Ash'abah) - naturally rare, high weight. `[WIRED: a UNIQUE undead kill -> HandleRedguardAshAbahMajorBurden (PDV_ActionRouter.HandleStoryKillActor:162, eventType 300, victimBase.IsUnique) -> death-duty burden +2.0 + marks Ash'abah sect entry. Routine (non-Unique) draugr do not qualify.]`
- **Make a way against impossible odds** (HoonDing) - winning a battle that was genuinely outnumbered or outleveled, or completing a curated impossible-odds milestone, a dragon, or a named boss. This is rare on purpose and capped to once per week (see Unique Mechanics). `[PARTIAL: WIRED for dragon kills (eventType 302) and the 19 forms in PDV_FLST_HoonDing_BreakthroughBosses (071585) -> HandleHoonDingBreakthroughKill (PDV_ActionRouter.HandleStoryKillActor:157) -> SIGNAL_MAKE_WAY +3.0, but ONLY while HoonDing is your active patron (_activeDeity == PDV_HoonDing). True outnumbered/outleveled combat-odds detection is not built - deferred post-1.0.]`
- **Sword discipline in honorable combat** (Leki) - clean, skilled one-handed form against a worthy foe, including smithing a true blade or sharpening your martial skill. `[WIRED (day-to-day): CSV Leki smith-item (330) +0.75, increase-skill (344) +0.25, read-skill-book (340) +0.25, learn-word-of-power (343) +0.75, kill-dragon (302) +1.0. The curated SIGNAL_SWORD_SINGING (+2.0) only fires on the dev-only/Forebear-road lane and only when Leki is active - PARTIAL - so day-to-day the CSV rows are what actually feed her.]`
- **Resolve "In My Time Of Need"** (the Saadia / Alik'r quest) - a one-time deed that reads as a sect statement: delivering Saadia to the Alik'r leans Crown (Hammerfell justice, ancestor duty); protecting her leans Forebear (exile-protection). `[INERT: MS08 (In My Time of Need, 118565) stage-201 Crown / stage-200 Forebear routes exist (PDV_PlayerEvents:1268-1272) but their P2 source FormLists (PDV_FLST_P2_RedguardCrown/ForebearSources) are unfilled - the source-fill ledger marks MS08 "blocked". The stage fires nothing until those lists are filled.]`

The one Redguard lane that genuinely fires from normal play with no patron/sect gate is the **ancestor-spine book**: reading Manual of Mixed Unit Tactics (Skyrim.esm:01ACD1) routes RouteRedguardAncestorSpine -> SIGNAL_ANCESTOR_SPINE +1.0 to Tu'whacca. `[WIRED: OnBookRead -> RouteP2ImmersiveSource -> PDV_FLST_P2_RedguardSpineSources (filled) -> HandleRedguardAncestorSpine]` Sleeping in a declared ancestral-rest cell also pulses the ancestor spine once per day. `[WIRED: OnSleepStop -> HandleRedguardSleepEvents -> RecordRedguardAncestralRest +1.0, once/day]`

## How You Lose Piety

You can lose ground through dislikes, through neglect, through natural drift, and by spreading yourself too thin. Here is what to watch for:

- **Dislikes (real offenses).** Raising the undead is the worst thing a Redguard can do - it chains souls back from the Far Shores and offends Tu'whacca and HoonDing alike. Killing the defenseless or assaulting those who cannot answer in kind shames Leki and the duty of the duel. Stealing has no place in Leki's discipline. Accepting a Daedric artifact binds a soul from its proper passage and turns Tu'whacca away. `[WIRED: CSV dislikes - Tu'whacca raise-undead (365) -1.5, murder-defenseless (304) -0.75, accept-daedric-artifact (368) -1.0; HoonDing raise-undead (365) -0.75, murder-defenseless (304) -0.25, sleep-in-inn (315) -0.25; Leki murder-defenseless (304) -0.75, steal-item (362) -0.25, assault-innocent (364) -0.75. All blank originGate = organic via the kill/steal/equip event routers.]`
- **Neglect (a god growing quiet).** Ignore the work and your gods do not punish you - they simply grow distant. The ancestors feel far away and the road feels colder; this shows up as a small drop in your magic resistance until you keep the sect and the death duty again. The flavor differs by sect: a Crown who lets Yokudan practice slide into Nine Divines convenience, a Forebear who always fast-travels and never takes a hard road or contract, an Ash'abah who leaves draugr tombs untouched and skips Hall of the Dead quests when they could act. Tu'whacca is still there - you are just not doing the work he needs done. `[WIRED: IsRedguardAncestorDistanceNeglected (no sect signal for >5 game-days, or curse cycle-pressure) -> SyncRedguardNeglectSpell adds PDV_SPEL_Neglect_Redguard (Magic Resistance drop). The sect "flavor" is descriptive text only; the same neglect spell fires for all three sects.]`
- **Creed violations (the harder loss).** Abandoning a death duty or desecrating the dead while you are bound to Ash'abah or focused on Tu'whacca turns his favor away. Sustained ancestor distance after committing to a god thins the old strength. Betraying your own sect in a major moment makes the road feel like a stranger's. `[PARTIAL: the ONLY organic creed-violation loss is death-duty abandonment, fired at neglect onset - EmitRedguardDeathDutyAbandonmentMinus -> SIGNAL_DEATH_DUTY_ABANDONMENT -3.0 to Tu'whacca (once, when the neglect spell first activates). "Desecrating the dead" (DA11 Namira, etc.) and "betraying your sect" have no organic sender outside the quest matrix.]`
- **Natural drift.** If you stop earning with a god, that god's piety slowly settles back over time. This is gentle - it keeps your standing honest, not punishing. `[WIRED: passive decay per deity]`
- **The broad-worship cap.** Honoring your sect broadly, across many Yokudan gods, can only carry you to Devoted. To reach Champion you must commit to a single focused god (Tu'whacca, HoonDing, or Leki). While you are committed, your broad ancestor blessing steps aside so the focused god's gifts can lead. `[WIRED: broad worship caps at Devoted; ancestor blessing suppressed while a focused patron is active]`

There is no separate reputation meter for Redguards. Your sect is your standing, and it changes only through credible deeds, not drift. `[WIRED: sect held in PDV_RedguardSectTrack; Crown<->Forebear needs 2 evidence days in 7 + 3-day lock; Ash'abah entry needs a marked burden (IsRedguardAshAbahBurden), casual undead fighting is not enough.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Redguard gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (with real journal/UESP citations) are promoted and fire when the quest is on the watch list (`questWatchFormIdsCsv`); "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT). None of these are Redguard-specific quests - they are the shared vanilla quests that happen to touch death-duty, make-way, or sword conduct.

**Tu'whacca** (death duty / the soul-keeper)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Glory of the Dead (C06) | 65 | Cured Kodlak's beast-taint | + / m / small | WIRED |
| Glory of the Dead (C06) | 200 | Funeral rites, passage to Sovngarde | + / C / milestone | WIRED |
| The Jagged Crown (CW02A/CW02B) | 72 | Destroyed the Korvanjund draugr | + / S / small | WIRED |
| The Black Star (DA01) | 110 | Bound souls into the corrupted Star | - / m / small | WIRED |
| The Break of Dawn (DA09) | 500 | Destroyed the necromancer Malkoran | + / m / small | WIRED |
| The Taste of Death (DA11) | 100 | Desecrated the honored dead (Namira) | - / m / small | WIRED |
| The Staff of Magnus (MG07) | 30 | Laid the risen dead of Labyrinthian low | + / S / small | WIRED |
| Laid to Rest (MS14) | 200 | Destroyed the risen dead | + / S / small | WIRED |
| The Book of Love (t02) | 200 | Guided two long-dead souls to rest | + / S / small | WIRED |

Plus 4 echo rows (DLC1SeranaCureSelfQuest, DLC1VQSaint, MQ103, MQ304) flagged REVIEW -> INERT.

**HoonDing** (make-way / prove by struggle)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Proving Honor (C01) | 200 | Won my place by a judged trial | + / C / milestone | WIRED |
| Message to Whiterun (CW03) | 16 | Held the line at Whiterun vs the dragon | + / S / small | WIRED |
| Dragon Rising (MQ104) | 160 | Defended Whiterun, slew the watchtower dragon | + / S / small | WIRED |
| The Way of the Voice (MQ105) | 160 | Passed the Greybeards' trials | + / C / milestone | WIRED |
| Horn of Jurgen Windcaller (MQ105U) | 60 | Completed the Greybeards' final trial | + / C / milestone | WIRED |
| A Blade in the Dark (MQ106) | 200 | Slew Sahloknir in open battle | + / m / small | WIRED |
| Alduin's Bane (MQ206) | 220 | Made way against the World-Eater | + / C / milestone | WIRED |
| The World-Eater's Eyrie (MQ303) | 100/300 | Pressed on against Alduin's escape | + / C / small | WIRED |
| Sovngarde (MQ304) | 200 | Crossed the devouring mist to Shor's hall | + / m / small | WIRED |
| Dragonslayer (MQ305) | 200 | Defeated Alduin against impossible odds | + / C / milestone | WIRED |

Plus 8 echo rows (C02, CW01B, DA02, DA06, DB09, DB10, MQ101, TG05) flagged REVIEW -> INERT.

**Leki** (sword-song / honorable duel)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Take Up Arms (C00) | 20 | One-on-one trial of arms with Vilkas | + / C / small | WIRED |
| Innocence Lost (DB01) | 200 | Cold-blooded murder of Grelod | - / S / small | WIRED |
| With Friends Like These (DB02) | 200 | Murdered a bound captive | - / S / small | WIRED |
| Bound Until Death (DB05) | 200 | Murder of the defenseless bride | - / S / small | WIRED |
| Dragon Rising (MQ104) | 160 | Slew the watchtower dragon in open battle | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Slew Sahloknir in open battle | + / S / small | WIRED |
| Alduin's Bane (MQ206) | 220 | Met Alduin in worthy single combat | + / S / small | WIRED |

Plus 22 echo rows (mostly murder_treacherous / kill_honorable_combat across C03, C04, C05, CW01A, CW01B, DA02, DA02KillObj, DA03, DA07, DA10, DA16, DB03, DB06, DB07, DB08, DB09, DB10, DB11, MQ201Malborn, MQ303, MQ305, TG08B) flagged REVIEW -> INERT.

Caveat: all day-to-day CSV rows in the gain/loss lists above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **The "signature" sect lanes are dev-only.** Four curated lanes ship as scripts + dev-only signal activators but never got an organic in-world trigger: Crown tomb respect (07102B), Forebear road passage (07102C), Ash'abah death duty (07102D), and the Far Shores token (07102E). All four are `status:"dev-only"` in `PDV_FinalPlacementManifest.json`. Their EventBus routes (`RouteRedguard*`) are reachable only from `PDV_EventSignalActivator` (debug/click) or from the P2 quest-stage/source hooks whose FormLists are **unfilled**.
- **Far Shores token = STUB.** The guide's marquee Unique Mechanic ("keep a portable token and pray anywhere, once per day, +5% Magic Resistance") has no OnEquipped/activation hook. `HandleRedguardFarShoresToken` exists but only the dev-only activator reaches it. This is the highest-visibility remap target.
- **Hall of the Dead quests = STUB.** "Complete a Hall of the Dead quest" (called out as the most direct death-duty deed) has no organic quest hook; it folds into the unfilled Ash'abah death-duty lane. The only organic death-duty credit today is (a) the CSV kill-undead rows, (b) curated undead-site clears (`PDV_FLST_RedguardAshAbahUndeadClearSites`), and (c) UNIQUE undead / named-necromancer kills (`HandleRedguardAshAbahMajorBurden`).
- **HoonDing and Leki curated signals are patron-gated.** `SIGNAL_MAKE_WAY` fires only while HoonDing is your active patron; `SIGNAL_SWORD_SINGING` only while Leki is active (and only on the road-passage lane). `SIGNAL_HONORABLE_DUEL` (+3.0) has **no** organic caller at all. Day-to-day, HoonDing and Leki are fed almost entirely by their generic CSV rows (dragon kills, skill-ups, smithing), not by their signature curated beats.
- **"In My Time of Need" (MS08) = INERT.** The Crown/Forebear stage routes exist in `PDV_PlayerEvents` but the source FormLists are unfilled and the source-fill ledger explicitly marks MS08 "blocked." The one-time sect-statement deed described in the guide currently does nothing.
- **Vampire re-entry reward not wired.** The cure "return through Tu'whacca" is narrative + neglect-clear only; `SIGNAL_VAMPIRE_REENTRY` (+4.0) is never awarded (delta-lookup only) and `VampireReentryNeeded` is set but never consumed.
- **What DOES fire organically, no patron/sect gate:** the ancestor-spine book (Manual of Mixed Unit Tactics, the only filled Redguard P2 source), ancestral-rest sleep, the full CSV likes/dislikes tables for all three gods (kills, undead kills, steal, smith, skill-ups, artifact acceptance, etc.), curated undead-site clears, UNIQUE-undead / named-necromancer burdens, dragon/listed-boss make-way (HoonDing-active only), the neglect Magic-Resistance loss, and the promoted quest-matrix rows above.
- **Background spine gods have no wiring.** Satakal, Ruptga, Tava, and Onsi have no likes/dislikes rows, no curated signals, and no quest-matrix rows - they are flavor only, as expected by design. "Tava blesses good passage" in the road-travel bullet has no Tava-specific mechanic.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Each god's gifts grow as you climb from Seeker (25 piety) to Devoted (50) to Champion (85). Below the focused gods, the always-on ancestor blessing is shared across all sects.

**Ancestor blessing (always on, broad worship, caps at Devoted):**

| Tier | What you gain |
|------|---------------|
| Seeker | Magic Resistance +3% |
| Devoted | Magic Resistance +5%, Armor +30 |

This blessing steps aside while you have a focused god, because the focused god's gifts are stronger.

**Tu'whacca - the soul-keeper's ward (best for Crown and Ash'abah):**

| Tier | What you gain |
|------|---------------|
| Seeker | Magic Resistance +5% |
| Devoted | Magic Resistance +10%, Health Regeneration +10% |
| Champion | Magic Resistance +20%, Health Regeneration +25% |

At Champion, Tu'whacca keeps the way to the Far Shores open for you and yours, and the Hall of the Dead priests treat you with full recognition.

**Leki - the sword-song (best for Crown and Forebear):**

| Tier | What you gain |
|------|---------------|
| Seeker | One-Handed +5 |
| Devoted | One-Handed +13, Critical Chance +5% |
| Champion | One-Handed +25, Critical Chance +13% |

At Champion the Spirit Sword sings through your hand. Note that Leki only rewards skilled, honorable sword conduct - generic combat does not feed her.

**HoonDing - the way made (best for Forebear):**

| Tier | What you gain |
|------|---------------|
| Seeker | One-Handed +5 |
| Devoted | One-Handed +13, Movement Speed +3% |
| Champion | One-Handed +25, Movement Speed +6% |

HoonDing's gifts arrive only through rare make-way moments and are capped to one such reward per week. This is the Make Way God noticing the same quality in your struggles that he saw in the Alik'r line.

Remember that only one temporary favor blessing can be active at a time across all your gods.

## Unique Mechanics

Two things make a Redguard feel different from any other race.

**Death is your domain.** Where other adventurers see a draugr crypt as loot, you see souls out of place and a duty to set them right. The ancestor reverence layer is always watching how you treat the dead. Clearing tombs, ending necromancers, completing Hall of the Dead quests, and putting the restless dead to rest are not side content for you - they are the core of your faith, and they pay piety to Tu'whacca and your ancestors in a way they pay no other race. The Ash'abah sect leans all the way into this: you carry the impurity others will not touch, and Tu'whacca honors a burden your own people will not even thank you for.

**The Far Shores token.** Because there are no public Redguard temples in Skyrim, you keep a portable token of the Far Shores and pray as your people do - in camp, on the road, anywhere. Tending it counts as your daily Yokudan observance and, once you have proven it, grants a steady +5% Magic Resistance. It speaks always of Tu'whacca and the Far Shores, never of Arkay. (Arkay's shrines remain only a fallback when you must use Skyrim's death institutions; the god you honor is still your own.)

**HoonDing cannot be farmed.** The Make Way God only appears when the way truly has to be made - a battle you should have lost, a milestone that should have been impossible. You cannot manufacture it by grinding fights. If you play it safe and avoid hard situations, HoonDing simply will not notice you. That is the correct friction: the make-way moment has to be real.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith | The way back |
|-------|---------------------------|--------------|
| Vampire | Near-total collapse. Undeath is a soul that has stepped out of the cycle Tu'whacca guides, so the Far Shores cannot receive you. Devotion across all three sects falls quiet, and your destiny is broken while the curse holds. Your sect identity remains only as memory and grief. `[WIRED: OnVampirismStateChanged -> ApplyRedguardCurseHandlers sets CyclePressure=2, which forces IsRedguardAncestorDistanceNeglected true -> the neglect Magic-Resistance loss, plus the VampireOnset message.]` | Yes, and it is meaningful. When the curse is cured you must return through Tu'whacca first, before any other god - proper mortality, ancestor order, the right re-entry into the cycle. Only after that re-entry are the Far Shores open again and your sect may have you back. The return is itself a devotional sequence, not just a timer running out. `[PARTIAL: cure clears CyclePressure and shows the Tu'whacca-re-entry message, but the promised re-entry PIETY reward is NOT wired - SIGNAL_VAMPIRE_REENTRY (+4.0) has no award caller (delta-lookup only at ~11421) and the VampireReentryNeeded flag is set but never consumed. So "the return is a devotional sequence" is narrative + neglect-clear only, with no piety grant.]` |
| Werewolf | Strained, not severed. The Yokudan gods and your sect stay within reach, but the favor is harder to keep - Hircine is an intrusion into Redguard life, not a home or an alternative. The condition stays theologically homeless. The ancestors do not turn away; they only watch the closer. `[WIRED: OnLycanthropyStateChanged -> ApplyRedguardCurseHandlers sets CyclePressure=1 (drives the neglect Magic-Resistance loss) + WerewolfOnset message.]` | Yes. When the beast is set down, the strain eases and the gods come back into full reach. The ancestors who watched the closer ease their gaze, and you are wholly theirs again. `[WIRED: cure clears CyclePressure -> neglect gate releases; WerewolfCured message. No separate piety reward.]` |

## Quick Reference

- **Gods:** Yokudan pantheon - focusable: Tu'whacca, HoonDing, Leki. Background spine: Satakal, Ruptga, Tava, Onsi.
- **Starting choice:** Sect at setup - Crown (orthodoxy, sacred martial inheritance), Forebear (pragmatic adaptation), or Ash'abah (funerary duty, cleansing the undead). Ancestor reverence is always on.
- **Top 3 ways to gain:** Defeat the undead and clear draugr tombs; complete Hall of the Dead quests and oppose necromancy; honor your sect's deed (Crown honorable combat / Forebear road and contracts / Ash'abah death duty) and tend the Far Shores token.
- **Main ways to lose:** Raising the undead, killing the defenseless, theft, accepting Daedric artifacts; neglecting your sect's work (ancestors grow distant); spreading too thin (broad worship caps at Devoted).
- **Rough days to Champion:** About 30 to 45 days of normal play (one or two devotional acts a day), or roughly 20 if you focus hard on a single god.
