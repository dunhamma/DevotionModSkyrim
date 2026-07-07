# Khajiit - The Lattice holds you, even in exile

## Overview

For the Khajiit, faith is not a belief you choose. It is the shape of the world you were born into. The moons - Masser and Secunda - decide what kind of Khajiit you are, and the Lunar Lattice (ja-Kha'jay) is the framework that makes Khajiit existence make sense. You carry this with you into Skyrim, a province that does not recognize it. You are shut out of the city temples. You are welcome in the holds only as a merchant. Your religion has no buildings here. What you have is the road, the caravans, and the night sky.

Because of that, your devotion is always running quietly in the background from the very first moment of play. There is no shrine to kneel at, no patron to swear to at the start. The Lattice simply holds you. Living the road life - sleeping under open sky, traveling on foot, helping your people - keeps that connection real and feeds your standing.

The big difference for the Khajiit is what happens later. You never get a formal offer to take a patron god. Instead, one god quietly emerges as your focus when you have leaned toward them long enough through how you actually live. You find out who watches over you by looking back at what you have done. Five gods can come to the front: Khenarthi, Azurah, Baan Dar, Rajhin, and Alkosh. If your worship stays balanced across many gods, that is a complete and lore-true Khajiit life too - it just caps you at the Devoted tier instead of carrying you all the way to Champion.

## Your Gods

These are the five gods who can become your focus:

- **Khenarthi** - goddess of wind, weather, and the open road. The most natural fit for a wandering Khajiit, and the one who guides lost souls home.
- **Azurah** - the mother-goddess who shaped the Khajiit and guards their passage through thresholds, dawn, and dusk. Her gift is Azura's Star.
- **Baan Dar** - the Bandit God, patron of pariahs, clever exiles, and improbable reversals. He smiles on the outsider who survives against the odds.
- **Rajhin** - the Purring Liar, the greatest thief who ever lived. His domain is artful, elegant theft, never crude violence.
- **Alkosh** - the Dragon King and keeper of cosmic order, the check on chaos. The rarest focus to reach, reserved for those who fight dragons and keep the line against chaos.

Above and around these five sits the Lattice itself - Riddle'Thar, the moons Jone and Jode - which is always present and is not a focus you commit to, it is just the structure you live inside.

The Khajiit have little reason to chase foreign gods or the Daedric Princes, and the mod does not push you toward them. Shadow-aligned pressure (Nocturnal, Hircine, the night-dominant powers) is treated as a strain on your Khajiit identity rather than a path you take. If you want the full picture of how foreign gods and the Daedric Princes work in general, see the How Devotion Works primer.

## Getting Started

The Khajiit have no setup choice at all. You do not pick a patron, a sect, or a starting branch. From your first moment in the world you are already inside the Lunar Lattice, and broad lunar worship is already active.

What is "always on" instead of a choice:

- **The lunar bond.** This is your baseline connection to the moons. It runs without any upkeep and gives you a small standing footing - the moons keep you hardy (Disease Resistance +5%) and your enhanced night vision feels a touch crisper.
- **Living the road keeps it strong.** Sleeping outdoors, traveling on foot, observing dawn and dusk under the sky, and staying connected to the caravans all keep that bond strong and feed your piety.
- **The moon cycle is always turning.** The Lattice follows the real visible moon in the sky on a 24-day cycle. Each phase belongs to one of the five focus gods as flavor (for example, the full moon belongs to Alkosh, the new moon to Rajhin). Once you have raised that god to the Devoted tier, their phase gives you a small bonus while it is in the sky. You do not have to wait for the "right" night to make progress - the phases just add a little extra timing for players who pay attention.

Instead of one sacred shrine, you set **2 to 3 road-homes**: rest anchors that you cycle between over time. The devotional act is the circuit, not the place. Returning to the same camp or bed over and over does not count - moving between your anchors is what the road asks of you.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (rare condition, moon-phase, book/quest-stage gated)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Day-to-day deltas from PDV_DeityLikesDislikes.csv; curated deltas from PDV_Deity_*.psc DELTA_*. -->

Lead with the road life. The most common and important ways to earn piety:

- **Sleep outdoors**, not in an inn or a house. This is the core road-life act and pleases the lunar bond, Khenarthi, Baan Dar, and Rajhin all at once. `[WIRED: OnSleepStop with PDV_LastSleepStartedOutside -> EVT_REST_UNDER_OPEN_SKY (313). CSV rest-under-open-sky rows: khenarthi +0.5, Baan Dar +0.5, rajhin +0.25, azurah +0.5. NOTE: this is a same-god-per-night dislike gate on inn sleep, not the caravan/lunar curated lane.]`
- **Travel on foot between major areas** instead of fast-traveling. The road itself is the worship. (Fast travel does not count - it would make this too easy to farm.) `[STUB: no organic travel-on-foot / location hook. HandleKhajiitRoadHome/RoadHomeAnchor route only from the dev-only activator (Devotion.esp:071030/071031 KhajiitRoadHomeAnchorOne/Two) and the debug MCM (RunPatternAction 10). There is no HandleStoryChangeLocation or step/travel poll for Khajiit road-life.]`
- **Cycle between your 2 to 3 road-homes** over time rather than camping the same spot. `[STUB: same as above - the road-home anchor repeat-rejection logic exists in HandleKhajiitRoadHomeAnchor, but the only callers are the dev-only activator and MCM. No organic circuit tracking.]`
- **Help, trade with, and protect the Khajiit caravans** - Ma'dran, Ri'saad, Ahkari, and Khaara and their people. Community belonging is a large part of Khajiit religious life, and the caravans are where it lives. `[STUB: SIGNAL_CARAVAN_AID (+1.5, Khenarthi) has no organic caller. Only the harm side (RouteKhajiitKhenarthiCaravanHarm -> SIGNAL_CARAVAN_HARM) exists, and it too fires only from the dev-only activator. No caravan-aid/protect hook of any kind.]`
- **Observe dawn or dusk outdoors.** A quiet time-of-day act that especially pleases Azurah. `[STUB: SIGNAL_THRESHOLD_RITE (+1.5, Azura, "dawn/dusk") has no organic time-of-day caller. Moon observance (SIGNAL_MOON_OBSERVANCE +0.4) fires organically, but only from lunar BOOKS and two quest stages (see PARTIAL below), not from standing outside at dawn.]`
- **Defend or protect any threatened Khajiit.** `[STUB: no organic "defend a Khajiit" hook exists in PlayerEvents or ActionRouter.]`

Then the focus-specific deeds, which steer who emerges as your patron:

- **Khenarthi:** discover new locations, rest under open sky, heal or cure people, free trapped souls (defeat undead), guide great souls to rest (slay dragons), and learn Words of Power - the Voice is her breath given shape. `[WIRED (day-to-day CSV, blank originGate): discover-location (345) +0.5, rest-under-open-sky (313) +0.5, heal-or-cure-npc (350) +0.25, kill-undead (300) +0.5, kill-dragon (302) +0.75, learn-word-of-power (343) +0.75. The curated SIGNAL_ROAD_HOME lane (+0.4) is STUB - see road-home above.]`
- **Azurah:** show mercy by healing or curing the cursed and outcast, observe dawn and dusk, read lore and prophecy, enchant items (soul-work honors her), learn Words of Power, and complete the Azura's Star quest - that quest is the single strongest Khajiit piety event there is. `[WIRED (CSV): heal-or-cure-npc (350) +0.75, rest-under-open-sky (313) +0.5, read-lore-book (342) +0.25, enchant-item (331) +0.5, discover-location (345) +0.5, learn-word-of-power (343) +0.75, kill-undead (300) +0.5, accept-daedric-artifact (368, ActorTypeDaedra) +0.5.] [QUEST: Azura's Star = The Black Star (DA01) s100 serve_a_daedra +/C milestone -> ApplyQuestReaction. "Observe dawn and dusk" as a curated rite is STUB (SIGNAL_THRESHOLD_RITE has no organic caller).]`
- **Baan Dar:** survive a fight that began while you were badly outnumbered (3 or more enemies), pick owned locks, take what survival demands, trespass and walk every road, rest rough under open sky, and pull off improbable reversals as the clever exile. `[WIRED (CSV): pick-owned-lock (360, owned) +0.25, steal-item (362) +0.5, trespass (361) +0.25, discover-location (345) +0.5, increase-skill (344) +0.25, rest-under-open-sky (313) +0.5.] [PARTIAL (organic combat hooks): outnumbered win (3+ kills OR level-delta >=5 with health dipped below half, one/day) -> RouteKhajiitBaanDarRoadTrick; near-fatal reversal (health <=10%, >=1 kill, once/week) -> RouteKhajiitBaanDarReversal (+SIGNAL_BANDIT_ROAD). Both fire from OnCombatStateChanged/OnActorKilled for originRace 6.]`
- **Rajhin:** steal and pickpocket from notable, high-value targets while undetected, pick owned locks, and slip through thresholds with style. Story-worthy thefts earn the most; petty theft stays too small to matter. `[WIRED (CSV): steal-item (362) +0.5, pick-owned-lock (360, owned) +0.5, trespass (361) +0.25, discover-location (345) +0.25.] [PARTIAL (curated elegant-theft): OnItemAdded while sneaking + undetected, source is on PDV_FLST_RajhinNotableTargets OR taken value >=200 gold, 7-day per-target cooldown -> RouteKhajiitRajhinElegantTheft -> SIGNAL_ELEGANT_THEFT (+0.4). This is the "story-worthy theft" beat.]`
- **Alkosh:** defeat dragons (named dragons most of all), drive back chaos by killing the undead and Daedra, learn Words of Power as ordered dominion, read the chronicles of the ages, and make order-keeping, anti-chaos choices. `[WIRED (CSV): kill-dragon (302) +1.5, kill-undead (300) +0.5, learn-word-of-power (343) +0.75, kill-daedra (301, ActorTypeDaedra) +0.75, read-lore-book (342) +0.25.] [PARTIAL (curated dragon lane): OnActorKilled ActorTypeDragon -> named dragon (PDV_FLST_AlkoshNamedDragons, one-shot per base) fires SIGNAL_NAMED_DRAGON; generic dragon = emphasis-only nudge once/week; Paarthurnax -> RouteKhajiitAlkoshChaosAid (negative). "Order-keeping choices" as a curated act is STUB.]`

Remember that piety is tracked separately for each god, daily gain is capped at about 4.3 per god per day, and repeating the exact same deed earns less each time. Variety across these acts matters far more than grinding one of them.

The moon-observance pulse that feeds the lunar bond (and a small Azurah pulse) does fire organically, but not from watching the sky: `[PARTIAL: SIGNAL_MOON_OBSERVANCE (+0.4) routes via RouteKhajiitLunarSubstrate from PDV_FLST_P2_KhajiitLunarSources immersive book reads (OnBookRead / PO3 source hooks) and two quest stages (MQ104 s160, DA01 s100). The debug MCM and the dev-only MoonObservance activator (Devotion.esp:07102F) are the other, non-organic callers.]`

## How You Lose Piety

Your standing is rarely in sharp danger - the Lattice does not collapse easily - but it can thin and slip in several ways:

- **Dislikes.** Each god turns away from acts against their nature. Killing the helpless offends every one of the five (Rajhin in particular wants artful theft, never crude slaughter). Raising the undead is a grave sin to Azurah, Khenarthi, and Alkosh, who all guide or order souls toward their proper rest. Alkosh is offended by lawless slaughter, trespass, and bearing a Daedric Prince's gift. Rajhin scorns brute assault on the innocent and even the soft comfort of a warm inn bed. `[WIRED: CSV dislikes (blank originGate) - murder-defenseless (304): khenarthi -1.0, azurah -0.75, Baan Dar -0.75, rajhin -0.75, alkosh -1.0. raise-undead (365, ActorTypeUndead): khenarthi -0.75, azurah -1.5, alkosh -1.0. assault-innocent (364): rajhin -0.5, alkosh -0.5, azurah -1.0. alkosh trespass (361) -0.25; alkosh accept-daedric-artifact (368) -0.75. rajhin sleep-in-inn (315) -0.25, fired by OnSleepStop when PDV_LastSleptInInn. NOTE the CSV also gives Baan Dar +0.5 assault-innocent (the ambush like) - Baan Dar does NOT dislike it.]`
- **Neglect (a god growing quiet).** This is the main Khajiit risk. When you stay indoors, urban, and cut off from the road, sky, and caravans for a long stretch, the small nightly bonuses stop building, the lunar bond gives much weaker piety, and the caravans stop recognizing you because you have not been where they travel. It is not urgent or harsh - it is a slow thinning, "less held, less known, less real." If you have been neglecting the moons, you carry a small penalty (Stamina Regeneration -5% at night) until you return to the road. `[WIRED: SyncKhajiitNeglectSpell adds PDV_SPEL_Neglect_KhajiitLunar when time since PDV.Khajiit.LastLunarSourceTime exceeds KHAJIIT_LUNAR_NEGLECT_GRACE_DAYS. NOTE the gate is a grace-days-since-last-lunar-source timer, NOT a piety threshold; and because road-life/caravan/dawn hooks are STUB, in practice the only organic acts that reset LastLunarSourceTime are lunar-book moon observance and the curated focus signals (theft/dragon/reversal), not "returning to the road" as the copy implies.]`
- **Focus drifting back to broad.** If a god was emerging as your focus and you stop doing the things that drew them - stop journeying, stop sleeping outside - your balance simply slides back toward broad worship. The god does not punish you; they just stop sending wind. `[WIRED: passive per-deity decay (~-0.5/day) erodes an unfed focus; broad-cap re-clamps when no god leads. "Stop journeying" is not itself organically tracked - see road-life STUBs above.]`
- **The broad-worship cap.** Honoring several gods at once is valid and complete, but it caps you at the Devoted tier. Reaching Champion requires letting one single god clearly lead. `[WIRED: broad worship caps at Devoted; Champion requires a focus emphasis leading by margin (see Unique Mechanics).]`

The Khajiit carry no formal reputation track (no faction standing that swings for or against you). Your standing is simply how well you have kept the road and the moons.

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the five Khajiit gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. A positive reaction for a Khajiit-focus deity also nudges the focused-emphasis system via `BridgeKhajiitMatrixFocus`. Hand-authored rows (real UESP citations, "small"/"milestone") are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT). Azura's rows are keyed "Azura" in the matrix (not "Azurah").

**Khenarthi**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Book of Love (t02) | 200 | Honored the dead / laid a soul to rest | + / m / small | WIRED |
| The Blessings of Nature (T03) | 200 | Restored the Gildergreen (sky-blessed land) | + / m / small | WIRED |

Plus 11 echo rows (honor_the_dead / the_open_road candidates) flagged REVIEW -> INERT.

**Azurah (matrix "Azura")**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Black Star / Azura's Star (DA01) | 100 | Served Azura and reclaimed her Star | + / C / milestone | WIRED (strongest Khajiit event) |
| The Black Star (DA01) | 110 | Defied Azura (gave the Star to Nelacar) | - / S / small | WIRED |
| Glory of the Dead (C06) | 65 | Cured Kodlak of the beast-taint | + / m / small | WIRED |
| Serana's Cure (DLC1SeranaCureSelfQuest) | 200 | Cured Serana's vampirism | + / S / small | WIRED |
| The Jagged Crown (CW02A/CW02B) | 72 | Slew the crypt undead | + / m / small | WIRED |
| The Break of Dawn (DA09) | 500 | Cleansed Meridia's temple of undeath | + / m / small | WIRED |
| Impatience of a Saint (DLC1VQSaint) | 200 | Honored the dead | + / m / small | WIRED |

Plus 6 echo rows flagged REVIEW -> INERT.

**Baan Dar**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Delayed Burial (DB01Misc) | 200 | Lied to the guard about Cicero (harmless trickery) | + / C / milestone | WIRED |
| Diplomatic Immunity (MQ201) | 250 | Clever infiltration/reversal vs the Thalmor | + / C / milestone | WIRED |
| Dampened Spirits (TG03) | 200 | Pariah prank on a rich brewer | + / m / small | WIRED |
| Scoundrel's Folly (TG04) | 200 | Slipped through the strong men's halls | + / m / small | WIRED |
| Blindsighted (TG08B) | 50 | Robbed the betrayer Mercer | + / m / small | WIRED |

Plus 20 echo rows (prove_by_struggle / deceit candidates) flagged REVIEW -> INERT.

**Rajhin**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| A Chance Arrangement (TG00) | 200 | Framed Brand-Shei | + / C / small | WIRED |
| Taking Care of Business (TG01) | 200 | Extorted shopkeepers | + / C / milestone | WIRED |
| Loud and Clear (TG02) | 200 | Burgled Goldenglow | + / C / milestone | WIRED |
| Hard Answers (TG06) | 200 | Burgled/forged Gallus's journal | + / C / milestone | WIRED |
| The Pursuit (TG07) | 200 | Broke into Mercer's house | + / C / milestone | WIRED |
| Blindsighted (TG08B) | 50 | Robbed Mercer | + / m / small | WIRED |
| Diplomatic Immunity (MQ201) | 250 | Artful infiltration | + / C / small | WIRED |
| Delayed Burial (DB01Misc) | 200 | Deceived the guard | + / S / small | WIRED |
| Dampened Spirits (TG03) | 200 | Deceit against the brewer | + / m / small | WIRED |
| Scoundrel's Folly (TG04) | 200 | Deceit / infiltration | + / m / small | WIRED |

Plus 7 echo rows flagged REVIEW -> INERT.

**Alkosh**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Dragonslayer (MQ305) | 200 | Slew Alduin, the world-ending dragon | + / S / small | WIRED |
| Alduin's Bane (MQ206) | 220 | Broke the named chaos-dragon | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Slew Sahloknir in honorable combat | + / S / small | WIRED |
| Dragon Rising (MQ104) | 160 | Slew Mirmulnir | + / S / small | WIRED (also routes lunar substrate) |
| Joining the Legion (CW01A) | 160/200 | Served Imperial order | + / m / small | WIRED |
| The Jagged Crown (CW02A) | 30/80 | Served Imperial order | + / m / small | WIRED |

Plus 13 echo rows (serve_empire_order / kill_honorable_combat candidates) flagged REVIEW -> INERT.

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **The whole "road life" front of the guide is largely STUB.** Travel-on-foot, cycling road-homes, caravan help/trade/protect, dawn/dusk observance, and defending a threatened Khajiit are all presented as the *core* Khajiit acts, but none has an organic hook. `HandleKhajiitRoadHome`, `HandleKhajiitRoadHomeAnchor`, `SIGNAL_CARAVAN_AID`, and `SIGNAL_THRESHOLD_RITE` route only from the dev-only signal activators (Devotion.esp:071030/071031/07102F) and the debug MCM. This is the prime remap target for the race: the marquee identity ("the road itself is the worship") is not wired.
- **Sleeping outdoors is the one road-life act that IS wired** - but through the shared `EVT_REST_UNDER_OPEN_SKY` (313) CSV rows, i.e. the generic sleep hook, not the Khajiit curated road-home lane. Inn sleep (315) organically triggers the Rajhin dislike.
- **Moon observance fires, but not from the sky.** `SIGNAL_MOON_OBSERVANCE` (+0.4) reaches play only through P2 immersive lunar BOOK reads (`PDV_FLST_P2_KhajiitLunarSources`) and two quest stages (MQ104 s160, DA01 s100). The design's "observe dawn and dusk under the sky" has no time-of-day caller.
- **Moon-phase bonus (the 24-day cycle):** the phase-blessing spells and `GetKhajiitMoonPhaseFromGameDay` / `SyncKhajiitPhaseBlessing` are wired and driven by the real Skyrim moon, so the *reward* half (a bonus while your Devoted god's phase is up) is real. But the phase does not itself *earn* piety organically, and the observance that feeds standing depends on the book/quest sources above.
- **Silent emergence IS wired.** Focus emphasis is driven behaviorally: `AdjustKhajiitFocusedEmphasis` from CSV/curated signals plus `BridgeKhajiitMatrixFocus` from quest reactions, evaluated at dawn. The problem is the *inputs* are thin - because road-life is STUB, the only organic emphasis drivers are the CSV like-rows, the combat/theft/dragon curated beats, the lunar books, and quest reactions.
- **Baan Dar and Alkosh have the strongest organic curated lanes.** Outnumbered-win and near-fatal reversal (Baan Dar) and named/generic dragon kills (Alkosh) fire from real combat/kill events for originRace 6. Rajhin's elegant-theft beat (notable-target or >=200-gold sneak-lift) is also organic.
- **Anti-creed curated signals are mostly STUB.** Azurah desecration (703), Khenarthi caravan-harm (604), Rajhin botched-theft, and Baan Dar betrayal route only from the dev-only activator. The undead/murder/assault CSV dislike rows are the organic loss path; Alkosh chaos-aid (Paarthurnax kill) is the one organic anti-creed beat.
- **Quest matrix:** Rajhin (10 promoted), Azurah (8, incl. Azura's Star milestone), Alkosh (6), Baan Dar (5), Khenarthi (2) all have real promoted rows; echo rows across all five (57 total) are REVIEW -> inert.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

The tiers are **Seeker** (reached at 25 piety), **Devoted** (50), and **Champion** (85). Underneath all of them, always on with no tier needed, the **lunar bond** gives you Disease Resistance +5% just for being Khajiit, and grows as your overall lunar standing rises - at full attunement, night-time gives you faster stamina and magicka regeneration and strong disease resistance.

Each focus god has its own Seeker, Devoted, and Champion blessing. Only the highest tier you have reached for your leading god is active.

**Khenarthi (the road)**

| Tier | Bonus |
|------|-------|
| Seeker | Stamina Regeneration +4% |
| Devoted | Stamina Regeneration +10%, Carry Weight +30 |
| Champion ("Khenarthi's Wind") | Stamina Regeneration +20%, Carry Weight +80, Movement Speed +3% |

**Azurah (twilight)**

| Tier | Bonus |
|------|-------|
| Seeker | Magicka Regeneration +4% |
| Devoted | Magicka Regeneration +10%, Magic Resistance +5% |
| Champion ("Azurah's Sight") | Magicka Regeneration +20%, Magic Resistance +15% |

**Baan Dar (the survivor)**

| Tier | Bonus |
|------|-------|
| Seeker | Armor +15 |
| Devoted | Armor +30, Health Regeneration +10% |
| Champion ("Baan Dar's Luck") | Armor +50, Health Regeneration +25%, Unarmed Damage +10 |

**Rajhin (the thief)**

| Tier | Bonus |
|------|-------|
| Seeker | Sneak +5 |
| Devoted | Sneak +13, Lockpicking +10 |
| Champion ("Rajhin's Grace") | Sneak +25, Lockpicking +25, Pickpocket +15, Unarmed Damage +10 |

**Alkosh (order)**

| Tier | Bonus |
|------|-------|
| Seeker | Fire Resistance +5% |
| Devoted | Fire Resistance +13%, Magic Resistance +5% |
| Champion ("Alkosh's Roar") | Fire Resistance +25%, Magic Resistance +20% |

At Champion, each focus also gains a signature moment - the wind carries you faster the longer you travel uninterrupted (Khenarthi), a foresight ward that turns aside a spell that would have hit you (Azurah), a once-a-day chance to survive a killing blow and vanish (Baan Dar), a slip-into-shadow after a clean steal (Rajhin), and a once-a-day staggering roar against dragons and great chaotic foes (Alkosh).

## Unique Mechanics

Two things make the Khajiit feel different from every other race:

**The silent emergent patron.** You never get a "Will you take this god as your patron?" prompt. There is no button to press. One god rises to become your focus only when their piety clearly leads - it must reach at least 50 and stay ahead of your next-highest Khajiit god by a comfortable margin, checked quietly at each dawn. You learn who your patron is by noticing your rewards get stronger and your status readout names them. This is by design: the moon noticed how you live, you did not apply for it. Staying in broad worship for a long time is not slacking - it may simply mean your life is genuinely balanced across several domains, and that is a real Khajiit experience that tops out at Devoted.

**The road-home circuit and the moon cycle.** Instead of one sacred place, you keep 2 to 3 road-homes and earn by moving between them - the journey is the rite, not the destination. Layered over that, the visible moon in the sky turns through a 24-day cycle, and each phase belongs to one of your five gods. Once a god is at Devoted, their phase grants you a small extra bonus while it hangs in the sky. You never have to wait for a particular night to make progress, but a player who watches the moons gets a little extra from good timing.

## If You Are Cursed (Vampire or Werewolf)

For the Khajiit, identity is cosmological and biological at once, so a curse strains your belonging rather than erasing it. The moons do not disown you, but the community can.

| Curse | What happens to your faith | A way back? |
|-------|----------------------------|-------------|
| **Vampire** | Your lunar standing becomes "corrupted" and weakened, but not destroyed - the Lattice still holds you, just under strain. Caravan and community belonging drops sharply, because vampirism makes caravan life dangerous and unwelcome. Azurah may still read you with some mercy, since her relationship with the undead is complicated, but night-dominant predation pulls you toward shadow. | Yes. Curing the vampirism lifts the corruption and lets ordinary moon-life and caravan trust recover. Avoid heavy night-only predation, which deepens the shadow drift. |
| **Werewolf** | Your lunar standing becomes "strained" but stays mostly intact. The moons are about form, and the werewolf is a competing form, not an opposite one, so Hircine adds a shape without severing your Khajiit identity. Caravan and community belonging is damaged because a werewolf is a threat to the people. It should feel uncomfortable and socially costly, not spiritually erased. | Yes. Curing the lycanthropy eases the strain. The Khajiit have more theological room for shape-complexity than most races, so recovery is cleaner here than the curse is for many others. |

## Quick Reference

- **Gods:** Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh (with the always-on Lunar Lattice beneath them)
- **Starting choice:** None - you begin inside the Lunar Lattice automatically, and a focus emerges silently from how you live
- **Top 3 ways to gain:** sleep outdoors and travel on foot; help and trade with the Khajiit caravans; do your focus god's deeds (Khenarthi roads, Azurah twilight and mercy, Baan Dar survival, Rajhin artful theft, Alkosh dragons and order)
- **Main ways to lose:** neglect (going city-bound and indoors), acting against a god's dislikes (especially killing the helpless or raising the undead), letting your focus drift back to broad, and the broad-worship cap at Devoted
- **Rough days to Champion:** about 30 to 45 days of normal play, or around 20 if you focus hard on one god - and only if you let a single god clearly lead
