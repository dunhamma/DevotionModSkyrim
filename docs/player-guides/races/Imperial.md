# Imperial - The Civic Faith of the Empire, Devotion Under Pressure

## Overview

Imperials carry the Nine Divines, the official, public, lawful religion of the Empire. For most races faith is a personal thing. For an Imperial it is also civic: your religion is tied to your role as a citizen of the order that the Empire built. You honor the gods through public duty, honest work, mercy, lawful burial, and standing for order in a province torn by war.

There is no setup choice and no patron to pick at the start. Broad worship of all Nine Divines is simply switched on the moment you begin. You can deepen your faith later by committing to a single god, but the public, civic religion is always running underneath you.

The thing that makes Imperial faith different from every other race is the shadow of the White-Gold Concordat. Talos, the god who unified the Empire, is banned by treaty. Every choice you make about that ban quietly shifts where you stand, and that standing decides how freely you can honor Talos at all. You can comply with the ban, defy it in secret, or defy it openly, and the religion notices.

## Your Gods

Your pantheon is the Nine Divines, all of them native to you:

- **Akatosh** - the Dragon God of Time, the chief Divine and the god of lawful, enduring order. Patient discipline and steady devotion are his.
- **Talos** - the Hero-God of Man, the man who became a god and unified the Empire. He is banned, which makes him the heart of every hard choice.
- **Kynareth** - the Lady of the heavens and the open air, goddess of nature, wind, and travel.
- **Mara** - the Mother, goddess of love, mercy, family, and the hearth.
- **Zenithar** - the god of honest work and fair trade, who rewards labor earned rather than power stolen.
- **Arkay** - keeper of the cycle of life and death, the god of proper burial and the enemy of necromancy.
- **Stendarr** - the god of mercy, righteous rule, and restraint, patron of the Vigilants.
- **Julianos** - the god of wisdom, logic, lore, and lawful justice.
- **Dibella** - the goddess of beauty, art, and grace.

Foreign gods and the sixteen Daedric Princes are not part of Imperial civic religion. The Divines are your frame. Bargaining with a Daedric Prince or taking a Daedric artifact actively offends most of the Divines (Akatosh, Arkay, Stendarr, and others all read it as a betrayal). If you walk a Daedric path you are stepping outside the civic faith, not adding to it.

## Getting Started

There is no opening choice to make. As an Imperial you begin already practicing the broad Nine Divines, honoring the whole pantheon at once through ordinary civic life. You do not have to do anything to turn this on.

What is always running, from the very first day, is the Concordat. Think of it as a hidden standing meter that tracks your relationship with the Talos ban. It starts neutral (called Uncommitted) and slides toward compliance or defiance based on the big political choices you make in the world. You do not set it at character creation; you build it through play. See the "How You Lose Piety" section below for how it moves and what it does.

Later, once your faith is deep enough, a single god may offer to take you on as their own. Accepting that offer commits you to one patron and opens the deepest tier of rewards. Until then you remain a broad worshipper, and broad worship has a ceiling (see "How You Lose Piety"). For how patron offers work in general, see the How Devotion Works primer.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via a P2 quest-source FormList or the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (Concordat band, book-source, dawn-halt, patron-state)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Day-to-day deltas from PDV_DeityLikesDislikes.csv; curated deltas from PDV_Deity_*.psc DELTA_*.
     NOTE ON "CIVIC SERVICE": the Imperial civic-family signals (public service, mercy, lawful
     order, honest work, death duty) do NOT fire from generic civic acts. They fire from a
     small, hand-picked set of vanilla QUEST STAGES filled into PDV_FLST_P2_Imperial*Sources
     (commit 91a3cc80, live-ESP). The domain gods still earn day-to-day from the CSV rows below. -->

Piety is tracked separately for each god, and your daily gain with any single god is capped (about 4.3 per god per day). Variety matters far more than repetition: doing the same deed over and over earns less each time, so spread your devotion across honest, civic acts. These are the main ways an Imperial earns favor:

- **Tend the dead properly (Arkay).** Clear a necromancer's operation, put restless undead to rest, complete a Hall of the Dead or burial quest. This is one of the cleanest, strongest ways to earn favor in the whole game. `[WIRED (day-to-day): CSV Arkay kill-undead (300, ActorTypeUndead) +0.5, heal-or-cure-npc (350) +0.5, read-lore-book (342) +0.25.] [QUEST (the civic "death duty" beat): only Laid to Rest (MS14) stage 200 fires the Arkay SIGNAL_DEATH_DUTY via PDV_FLST_P2_ImperialDeathDutySources. Generic undead-clearing earns the CSV +0.5, not the curated death-duty pulse.]`
- **Show mercy and restraint (Stendarr, Mara).** Spare a surrendering enemy, heal or cure a hurt person, answer for a crime and serve your time rather than running from it. Meaningful mercy under real pressure counts; idly paying off a small bounty does not. `[WIRED (day-to-day): CSV Mara heal-or-cure-npc (350) +0.75, clear-bounty-serve-time (351) +0.5; Stendarr heal-or-cure-npc (350) +0.5, clear-bounty-serve-time (351) +0.75; Zenithar clear-bounty-serve-time (351) +0.5. "Serve your time" (351) fires if the serve-time event is emitted. There is no organic "spare a surrendering enemy" hook.] [QUEST (the civic "mercy" beat): only In My Time of Need (MS08) stage 200 (Saadia-aid branch) fires Mara SIGNAL_MERCY via PDV_FLST_P2_ImperialMercySources.]`
- **Heal and care for people (Mara, Stendarr, Akatosh).** Mending the suffering, cooking a meal, resting in a proper bed, restoring a family or community. `[WIRED (day-to-day): CSV Mara cook-meal (333) +0.5, sleep-in-bed (314) +0.25, brew-potion (332) +0.25; Akatosh rest-under-open-sky (313) +0.25. Resting also fires the Imperial civic "spine" pulse -> Talos SIGNAL_ANCESTOR_SPINE, once/day, via OnSleepStop -> HandleImperialSleepEvents.]`
- **Do honest work and fair trade (Zenithar).** Smithing, enchanting, brewing, mining and woodcutting, selling goods you came by honestly. Win by labor, not by plunder. `[WIRED (day-to-day): CSV Zenithar smith-item (330) +0.5, enchant-item (331) +0.5, brew-potion (332) +0.25, cook-meal (333) +0.25, increase-skill (344) +0.25.] [QUEST (the civic "honest work" beat): only The Golden Claw (MS13) stage 100 (returned to Lucan) or 110 (to Camilla) fires Zenithar SIGNAL_HONEST_WORK via PDV_FLST_P2_ImperialHonestWorkSources. Day-to-day crafting is the CSV rows, not the curated pulse.]`
- **Study and master your craft (Julianos, Dibella, Akatosh).** Read skill books, spell tomes, and lore; improve your skills through patient practice. `[WIRED (day-to-day): CSV Julianos read-skill-book (340) +0.5, read-spell-tome (341) +0.5, read-lore-book (342) +0.5, learn-word-of-power (343) +0.75, increase-skill (344) +0.25, enchant-item (331) +0.25; Dibella read-lore-book (342) +0.25, enchant-item (331) +0.5, smith-item (330) +0.25, increase-skill (344) +0.25; Akatosh increase-skill (344) +0.25, learn-word-of-power (343) +0.75.]`
- **Serve lawful order and the public (Akatosh, Talos).** Complete Legion public-service beats, aid a hold, resolve disputes lawfully, slay dragons with real intent. Concrete order-preserving acts earn favor; merely belonging to a faction does not. `[QUEST (the civic "public service" beat): only Bleak Falls Barrow (MQ103) stage 190 and the Imperial Jagged Crown (CW02A) stage 200 fire Akatosh SIGNAL_CIVIC_SERVICE via PDV_FLST_P2_Imperial(Civic/PublicService)Sources. "Lawful order" (Stendarr SIGNAL_LAWFUL_ORDER) fires only from In My Time of Need (MS08) stage 201 (Alik'r-justice branch). Faction membership never routes these.] [WIRED (day-to-day, Akatosh only): CSV kill-undead (300) +0.5, rest-under-open-sky (313) +0.25. Slaying a dragon is a Talos CSV +1.5 but an Akatosh CSV -0.75 (fraught reverence, not glory).]`
- **Walk the open land and learn a Shout (Kynareth, Talos, Akatosh).** Rest under the open sky, discover new places, learn a Word of Power. The Thu'um is sacred to several of your gods. `[WIRED (day-to-day): CSV Kynareth rest-under-open-sky (313) +0.75, discover-location (345) +0.5, learn-word-of-power (343) +1.0, brew-potion (332) +0.25, harvest-ingredient (334) +0.25; Talos learn-word-of-power (343) +1.0, discover-location (345) +0.5; Akatosh learn-word-of-power (343) +0.75, rest-under-open-sky (313) +0.25. Talos CSV rows are scaled ~0.4x for an Imperial (FOREIGN stance).]`
- **Faithful defiance of the Talos ban (Talos only).** Activate a hidden Talos shrine, help a Talos worshipper escape the Thalmor, refuse to report the faithful. Talos favor comes ONLY from genuine, costly defiance. Generic rebellion, plain anti-Thalmor violence, or simply complying with the ban never earns Talos any favor. `[PARTIAL (public Talos pressure): reading "The Talos Mistake" (Book2ReligiousTalosWorship 0ED04D), one-shot, fires Talos SIGNAL_DEFIANCE_MILESTONE via OnBookRead -> PDV_FLST_P2_ImperialPublicTalosSources.] [QUEST (private Talos pressure): only Diplomatic Immunity (MQ201) stage 250 fires Talos SIGNAL_SHRINE_DEFIANCE via PDV_FLST_P2_ImperialPrivateTalosSources.] [STUB (the "hidden Talos shrine" activation the copy leads with): HandleTalosShrineDefiance routes only from the dev-only PDV_EventSignalActivator (135) and the debug MCM - there is no placed hidden-shrine object in PDV_FinalPlacementManifest. "Help a worshipper escape" and "refuse to report" exist only as Concordat pressure deltas (see below), not as Talos piety hooks.] Also, when Talos is your active patron, a hand-picked civic beat (Book of Love / T02 stage 200) fires his SIGNAL_PATRON_CIVIC_FAVOR via PDV_FLST_P2_ImperialPatronCivicSources. [QUEST]`

## How You Lose Piety

- **Acts your gods despise.** Murdering the defenseless, assaulting the innocent, raising the dead, theft and trespass, and taking Daedric artifacts all cost piety. Necromancy is the gravest sin against Arkay, Stendarr, and Kynareth; cruelty to the helpless offends Mara, Stendarr, and Julianos most of all. `[WIRED: CSV dislikes - raise-undead (365): Arkay -1.5, Stendarr -1.5, Kynareth -1.0, Akatosh -1.0, Mara -1.0, Dibella -0.75; murder-defenseless (304): Mara -1.5, Stendarr -1.5, Julianos -1.5, Arkay -1.0, Dibella -1.0, Kynareth -1.0, Zenithar -1.0; assault-innocent (364): Mara -1.0, Stendarr -1.0, Arkay -1.0, Julianos -0.75, Dibella -0.5; accept-daedric-artifact (368): Stendarr -1.0, Kynareth -1.0, Arkay -1.0, Zenithar -0.75; steal-item (362): Zenithar -1.0, Stendarr -0.75, Mara -0.5, Julianos -0.5, Talos -0.5(x0.4); trespass (361): Stendarr/Zenithar/Julianos -0.25.]`
- **Neglect (a god growing quiet).** If you stop feeding the civic religion (no death rites, no mercy, no public service, no honest work), the faith goes hollow. Shrines start to feel like mere architecture. Letting your devotion lapse slows your health recovery by about 5 percent until you return to public service. This is gentle texture, not a harsh punishment; the real bite is reserved for curses. `[WIRED: SyncImperialNeglectSpell(IsImperialCivicNeglected()) adds PDV_SPEL_Neglect_Imperial. NOTE the gate is a time-since-last-civic-service timer (> 3.0 days since PDV.Imperial.LastCivicServiceTime, AND CivicServiceCount > 0), NOT a piety threshold. Because civic service only fires from the handful of vanilla quest stages above, "return to public service" in practice means hitting another of those quest beats - ordinary daily CSV acts do NOT reset the civic-service timer.]`
- **Natural drift.** Piety you do not maintain slowly settles. Steady, varied devotion keeps your standing where you want it. `[WIRED: passive per-deity decay (~-0.5/day per god).]`
- **The broad-worship cap.** Honoring all Nine Divines at once is civic and normal, but it only takes you so far. Broad worship is capped at Devoted. To reach Champion you must commit to a single god as your patron. `[WIRED: broad worship caps at Devoted; broad civic reward floor gates on CivicServiceCount (T1 at >=3, T2 "Faithful" at >=6).]`
- **The Concordat track (your reputation with the Talos ban).** This is the Imperial's signature mechanic, and it is always running. Every major political choice shifts a hidden meter between five bands: `[PARTIAL: PDV_ConcordatStandingTrack (-100..+100, 5 states) modifies Talos gain/decay (GainModifyingTrack/DecayModifyingTrack) and gates his offer; it is a reputation track, not a piety buff. It only moves when ApplyImperialConcordatAction is called - see the wiring note in the review block for which of the listed acts actually have organic callers.]`
  - **Open Defiant** - you defy the ban in the open; the Thalmor hunt you, and your Talos devotion comes most freely.
  - **Private Defiant** - you keep the old faith in secret; the Thalmor are suspicious but Talos still answers strongly.
  - **Uncommitted** - the wide, neutral middle; Talos answers normally and the Thalmor leave you alone.
  - **Public Compliant** - you observe the ban publicly; the Thalmor are friendly, but Talos answers far less freely.
  - **Concordat Enforcer** - you enforce the ban; the Thalmor are allies, and Talos is all but closed to you.

  Acts that push you toward defiance: finding a hidden Talos shrine (-15), helping a worshipper escape the Thalmor (-15), siding with the Stormcloaks (-20), refusing to report the faithful (-5). Acts that push you toward compliance: reporting a Talos worshipper (+15), attacking one (+15), siding with the Legion (+10), escorting a Thalmor prisoner (+10), publicly observing the ban (+5). `[PARTIAL/STUB: the pressure VALUES are live in GetImperialConcordatPressureForAction (hidden_talos_shrine -15, help_talos_worshipper_escape -15, side_with_stormcloaks -20, refuse_report_talos_worshipper -5, public_observe_talos_ban +5, report/attack_talos_worshipper +15, kill_thalmor_justiciar_unprovoked -10). But most have NO organic caller. The two ApplyImperialConcordatAction call sites that actually fire are: (1) the "hidden Talos shrine" defiance, which routes only from the dev-only activator / debug MCM (STUB); (2) killing a Thalmor Justiciar unprovoked, which fires organically off an Altmer-alignment kill signal (-10). Stormcloak/Legion siding, reporting/attacking a worshipper, escorting a prisoner, and public observance are NOT organically wired to the track today - they are design deltas awaiting quest-stage hooks.]`

  The track does more than gate Talos. At the extremes it bleeds into two other gods: a hard-line Enforcer who enabled the worst of the war finds Arkay and Stendarr harder to please (the civic religion judges its own failures), while an open resister finds Stendarr easier, reading active resistance as a merciful act. `[PARTIAL: the extreme-band cross-god bleed is a design promise; the live track only clamps to a raw value and gates Talos gain/offers. Verify the Arkay/Stendarr modifiers are actually applied at the extremes before promoting this to WIRED.]`

- **Vampirism halts the civic faith (curse).** Becoming a vampire freezes positive Nine Divines piety at dawn until you are cured. `[WIRED: ApplyImperialCurseHandlers sets PDV.Imperial.VampireHalt=1 on vampire onset; GetImperialCurseGainMultiplier returns 0.0 while halted, multiplied into clampedToday at the DAWN rollover (only when clampedToday > 0.0 - so LOSSES still apply). Cure clears the halt but PDV.Imperial.VampireHistory stays set as a permanent scar. Werewolf does NOT halt (multiplier stays 1.0); the "reduced effect" is narrative posture, not a piety multiplier.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Two runtime systems move Imperial standing off quests:

1. **P2 quest-source FormLists** (`PDV_FLST_P2_Imperial*Sources`): a small, hand-picked set of vanilla quest stages that fire the Imperial *curated* civic/Talos signals through `OnQuestStageChange` -> `ShouldRouteP2QuestStage` -> `RouteImperial*` -> the manager handlers. These are the ONLY organic source of the civic-family signals (there is no "do a civic act" hook). Filled live-ESP in commit `91a3cc80`, houseCARL stage-verified.

| Family / signal | Quest (stage) | Deity signal | Notes |
|-----------------|---------------|--------------|-------|
| Public service | Bleak Falls Barrow MQ103 (190); Imperial Jagged Crown CW02A (200) | Akatosh SIGNAL_CIVIC_SERVICE | Rejects generic Legion membership/patrol |
| Mercy | In My Time of Need MS08 (200, Saadia-aid) | Mara SIGNAL_MERCY | Mutually exclusive with the lawful-order branch |
| Lawful order | In My Time of Need MS08 (201, Alik'r-justice) | Stendarr SIGNAL_LAWFUL_ORDER | Same quest, opposite branch |
| Honest work | The Golden Claw MS13 (100 Lucan / 110 Camilla) | Zenithar SIGNAL_HONEST_WORK | One-shot; either return branch |
| Death duty | Laid to Rest MS14 (200) | Arkay SIGNAL_DEATH_DUTY | Anti-undead civic beat |
| Private Talos | Diplomatic Immunity MQ201 (250) | Talos SIGNAL_SHRINE_DEFIANCE (private) | Also a Concordat pressure point elsewhere |
| Public Talos | "The Talos Mistake" book (OnBookRead, one-shot) | Talos SIGNAL_DEFIANCE_MILESTONE (public) | Book-read, not a quest stage |
| Patron civic | The Book of Love T02 (200) | active patron's SIGNAL_PATRON_CIVIC_FAVOR | Only fires while that god is your patron |

2. **Quest-reaction matrix** (`PDV_QuestReactionMatrix_Full.csv` -> `ApplyQuestReaction` -> `ApplyDeityReaction`): deity-keyed (not race-keyed), so these promoted rows also reach an Imperial who worships that god, when the quest is on the watch list. Promoted rows carry real UESP / "owner ruling" citations; "cross-gen candidate ... REVIEW before promotion" rows are echo -> INERT. Counts below.

**Akatosh** (6 promoted / 8 echo): dragon kills MQ104 s160, MQ106 s200, MQ206 s220, MQ305 s200 (kill_honorable_combat); CW02A s30/80 serve-empire-order; CW01B oath (Stormcloak, +).
**Mara** (5 / 23): The Heart of Dibella T01 s200 (protect the weak); The Book of Love t02 s200 (+C milestone, marriage/family); DA03 s200, DA07 s150, DA11 s250 (mercy-spare).
**Arkay** (7 / 4): Glory of the Dead C06 s65 (cure undeath) + s200 (honor the dead, +C milestone); Jagged Crown CW02A/B s72 (slay undead); Laid to Rest MS14 s200 (+C milestone); Book of Love t02 s200; DA01 s110 necromancy (-).
**Stendarr** (8 / 16): protect-the-weak (CW03 s16, T01 s200, MS14 s200); slay-undead (CW02A/B s72); mercy-spare (DA07 s150, DA11 s250); DA01 s100 reject-Molag.
**Zenithar** (1 / 3): Kolskeggr Mine reclaim (FreeformKolskeggrA s200, honest_labor_trade, +C milestone). Thin on matrix; Zenithar earns mostly day-to-day CSV craft.
**Dibella** (3 / 19): Pantea's Flute (BardsCollegeFlute s40); Tending the Flames MS05 s300; Heart of Dibella T01 s200.
**Julianos** (4 / 6): College arc MG01 s200, MG02 s200, MG07 s200, MG08 s200 (disciplined_study; MG08 +C milestone).
**Kynareth** (3 / 9): Message to Whiterun CW03 s16; Blessings of Nature T03 s200 (+C milestone, restore Gildergreen); Heart of Dibella T01 s200.
**Talos** (9 / 14): heavily Nord/Stormcloak-coded - Companions trials C00 s20/C01 s200 (prove_by_struggle); CW01B/CW02B/CW03 defy_tyranny_talos (+C milestones); Voice mastery MQ105 s160, MQ105U s60, MQ304 s200; MQ106 s200. For an Imperial these fire at ~0.4x (Talos FOREIGN stance) via ApplyDeityReaction.

Caveat: CSV day-to-day rows are live only if `LoadRowsForDeity` was regenerated and `LIKES_DISLIKES_VERSION` bumped; matrix rows are live only if the quest is in `questWatchFormIdsCsv` in the compiled JSON; the P2 quest-source rows are live only because commit `91a3cc80` wrote the FormLists into Devotion.esp (reconcile gate PASS).

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **"Civic service" is quest-stage-only, not act-based.** The marquee Imperial identity - "honor the gods through public duty, honest work, mercy, lawful burial" - reads as an everyday-act loop, but the curated civic-family signals (SIGNAL_CIVIC_SERVICE / MERCY / LAWFUL_ORDER / HONEST_WORK / DEATH_DUTY) fire ONLY from the ~8 vanilla quest stages in the table above. `HandleImperialCivicService` -> `AwardImperialCivicFamilySignal` has no everyday-act caller. Generic clearing/crafting/healing earns the domain god's day-to-day CSV delta, but never the curated civic pulse and never increments `CivicServiceCount`. This is the prime remap/expansion target for the race (compare the 2026-06-23 Imperial P2 handoff, which called Imperial "the worst-off race").
- **Neglect timer keys off civic service, not piety.** `IsImperialCivicNeglected` = (>3 days since last civic-service quest beat) AND CivicServiceCount>0. So the health-regen -5% neglect spell only exists once you've hit >=1 civic quest stage, and only ordinary quest cadence clears it - daily CSV worship does not. The copy's "return to public service" is literally true and narrow.
- **Talos is thin and gated.** Talos is largely absent from the generic Imperial likes (Concordat stance-1, tolerated); his CSV rows are combat/conqueror-flavored (learn-word-of-power, discover-location, kill-hostile-humanoid, kill-dragon) and scale ~0.4x for an Imperial. Organic Talos-defiance piety = the "Talos Mistake" book (public, one-shot) + MQ201 s250 (private). The guide-lead "activate a hidden Talos shrine" is STUB - `HandleTalosShrineDefiance` has only a dev-only activator + MCM caller, and `PDV_FinalPlacementManifest.json` places no hidden-shrine object. "Help a worshipper escape" / "refuse to report" are Concordat deltas with no organic caller, not Talos piety hooks.
- **Concordat track: values live, callers mostly missing.** All eight pressure deltas exist in `GetImperialConcordatPressureForAction`, but only two `ApplyImperialConcordatAction` call sites fire organically: hidden_talos_shrine (dev-only/MCM -> STUB) and kill_thalmor_justiciar_unprovoked (-10, off the Altmer-alignment kill signal). Stormcloak/Legion siding, reporting/attacking a worshipper, escorting a Thalmor prisoner, and public observance have no organic caller yet. The track gates Talos gain/offers and clamps a raw value; the extreme-band Arkay/Stendarr cross-god bleed described in the guide is unverified in live code.
- **Vampire civic-halt is real and dawn-scoped.** `VampireHalt` -> `GetImperialCurseGainMultiplier` 0.0x is applied to `clampedToday` at the dawn rollover, and only when the day's net is positive - so an Imperial can still LOSE piety while halted, and earn-then-cure-before-dawn does not slip past it. Cure clears the halt; `VampireHistory` scar persists. Werewolf is narrative-only (no multiplier).
- **Rewards note:** Akatosh/Julianos/Kynareth Imperial reward capstones are regeneration-rate effects (~0 under Requiem) - a known reward-feel gap flagged in-source, not a piety issue.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

The player-facing tiers are Seeker (25 piety), Devoted (50 piety), and Champion (85 piety). Only one temporary favor blessing can be active at a time across all your gods.

**Broad Nine Divines (always-on civic faith, capped at Devoted):**

| Tier | What you gain |
|------|----------------|
| Seeker | Health Regeneration +4% |
| Devoted | Health Regeneration +7%, Disease Resistance +10% |

Broad worship deliberately stays softer than a committed patron, and it stops at Devoted. To go further, commit to one god below.

**Focused patron (Champion tier, by god).** Each focused god shares the same shape: a Seeker blessing, a stronger Devoted blessing, and a Champion capstone. Champion values are listed here; the Seeker and Devoted steps are gentler versions of the same effects.

| Patron god | Seeker | Champion (peak) |
|------------|--------|------------------|
| Akatosh | Magicka Regeneration +4% | Magicka Regeneration +20%, Magic Resistance +15% |
| Mara | Restoration +5 | Restoration +23, Health Regeneration +19% |
| Arkay | Disease Resistance +5% | Disease Resistance +27%, Health Regeneration +17% |
| Stendarr | Block +5 | Block +25, Armor +50 |
| Zenithar | Carry Weight +25 | Carry Weight +120, Speech +20 |
| Dibella | Speech +5 | Speech +25, Magicka Regeneration +13% |
| Julianos | Magicka Regeneration +4% | Magicka Regeneration +20%, Magic Resistance +15% |
| Kynareth | Stamina Regeneration +4% | Stamina Regeneration +20%, Magic Resistance +13% |
| Talos | Armor +15 | Armor +50, One-Handed +20 |

Talos is special: his blessings are reached only through faithful defiance and are gated by your Concordat standing. You cannot become a Talos Champion while publicly enforcing the ban unless a fresh, costly act of defiance breaks that pattern first.

## Unique Mechanics

**The Concordat is always running.** No other race carries anything like it. You cannot be religiously neutral about Talos. Your standing accumulates from the civil war, from how you treat Talos worshippers, and from how you answer the Thalmor. This means the very same Champion can mean two opposite things: a Stendarr Champion at Open Defiant chose mercy in a world that demanded persecution, and the god knows the cost; an Akatosh Champion at full compliance kept civic order and steady faith through upheaval. The mod is built to recognize which arc you actually lived.

**Public versus private faith.** Because your religion is civic, it has a public face and a private one. You can comply with the ban in the open while quietly keeping the old faith (the Private Defiant band). That double life is a real, supported way to play, not a loophole.

**The Talos commitment gate.** Wanting Talos as your patron while sitting at Public Compliant or Concordat Enforcer is normally blocked. A fresh, costly act of defiance can open the door, and accepting Talos then immediately moves a compliant Imperial at least into Private Defiant. You cannot accept Talos and remain publicly compliant; the faith makes you choose.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith |
|-------|----------------------------|
| Vampire | Your Divine devotion does not weaken; it stops completely. Imperial religion is civic infrastructure, and vampirism ejects you from that frame entirely. The Concordat no longer matters religiously. While you are a vampire, only a dark survival reading remains. There is a way back: curing the vampirism lets your faith resume, but it restarts from a lowered floor with no automatic return to your old tier. The re-entry itself becomes a meaningful late-game story. |
| Werewolf | Your Nine Divines devotion continues, but at reduced effect. No Imperial path to Hircine opens; he is an intrusion into Imperial life, not a home. Your civic-facing devotion weighs much less, and the practical result is that you become theologically homeless rather than newly belonging. |

## Quick Reference

- **Gods:** The Nine Divines - Akatosh, Talos, Kynareth, Mara, Zenithar, Arkay, Stendarr, Julianos, Dibella.
- **Starting choice:** None. Broad civic worship of all Nine is always on; the Concordat standing track runs from day one.
- **Top 3 ways to gain:** Tend the dead and clear necromancers (Arkay); show real mercy and restraint (Stendarr, Mara); do honest work and lawful public service (Zenithar, Akatosh).
- **Main ways to lose:** Cruelty to the helpless, necromancy and Daedric dealings, neglecting civic duty, the broad-worship cap at Devoted, and a Concordat standing that closes off Talos.
- **Rough days to Champion:** About 30 to 45 days of normal play (one or two devotional acts a day), or around 20 days if you focus hard on a single god. Remember: Champion requires committing to one patron; broad worship alone caps at Devoted.
