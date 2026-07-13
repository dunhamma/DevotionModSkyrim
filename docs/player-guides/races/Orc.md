# Orc - The code is carried, not prayed

## Overview

Most races in Devotion pray, give offerings, and visit shrines. Orcs do none of that. You serve one god, Malacath, and Malacath does not want your prayers. He watches. He watches whether you are strong, whether you keep your oaths, whether you provide for your people, and whether the things you make are worthy. His favor is earned through how you live, and it is withheld when how you live falls short.

This is the most demanding faith in the mod, and that is on purpose. You cannot donate to a temple and call it done. You cannot stand at a shrine and feel like you did the work. The only thing Malacath counts is the life you are actually living: the quality of what you forge, the weight of the oaths you keep, and the strength you prove when something tests it.

The big question for an Orc is not which god to follow. It is always Malacath. The question is how you carry his code, given the life you are living. There are three ways: as a Stronghold Orc with your full people behind you, as a City Orc holding the code alone in mixed society, or as a Legion or Exile Orc keeping faith under foreign discipline. The world watches your conduct and confirms which one you are actually living. (For the basics of piety, tiers, and the Devotion panel, see the How Devotion Works primer.)

## Your Gods

- **Malacath** - The Code-Keeper. The god of the spurned, the outcast, and the abandoned. He does not receive prayers. He observes strength, oath-keeping, provision, and worthy craft, and he counts the life you actually lead.

There is one more name that matters to Orcs, though it is not a path you walk in normal play:

- **Trinimac** - The fallen god behind Orc identity. Lore says Malacath is Trinimac transformed. In this mod Trinimac is a rare ideological pressure tied to Orc and high-elf orthodoxy, not a steady source of rewards. You will not build devotion to Trinimac the way you build it to Malacath.

Foreign gods and the Daedric Princes are not normal Orc worship. An Orc keeps Malacath's code; chasing other altars is not the Orc path, and the mod does not reward it for this race.

## Getting Started

You do not pick a god. You carry Malacath's code in one of three life-modes. You can declare which one you intend during setup or later in the MCM menu, but a declaration is only intent. The world has to confirm it through your conduct. If you are not currently proven into a mode, you default to City Orc until your actions earn something else.

- **Stronghold Orc** - The full life. The forge serves your people, the chief enforces the code, the shaman reads Malacath's will, and every act of strength, craft, and provision feeds your devotion directly. This is the fastest mode and reaches its peak the steadiest, because the whole structure of Orc life is confirming your choices. You earn this by being accepted into a stronghold: becoming Blood-Kin, or resolving a stronghold crisis like "The Cursed Tribe" at Largashbur in your people's favor. Standing in a stronghold is not enough on its own; you have to be accepted and to act like it.

- **City Orc** - The same code, carried without the structure that makes it easy. You still keep your oaths, still do quality work, still hold your dignity, but you do it alone, in a society that does not understand or reward any of it. This is the default if nothing else is confirmed, and it is slower than Stronghold. The trade is resilience: Malacath has to see the code himself, because no chief or shaman is there to vouch for you.

- **Legion / Exile Orc** - Honor under foreign discipline. The contract is the oath. The endurance is the strength. You carry Malacath's code privately while you serve in someone else's army or institution. This is the slowest and heaviest mode, and it is also the one most Orcs in Skyrim actually live. It is meant to feel like a complete devotional life, not a lesser one. You earn this through real, completed, pressure-bearing service or an explicit commitment to exile or service. Just joining a faction does not count.

Switching modes is deliberate and limited. A clear, major moment (becoming Blood-Kin through aid, or finishing hard service) can move you right away. Otherwise the world wants to see two qualifying acts on separate days within a week before it shifts you, and it settles changes at dawn. After a switch, you are locked from drifting again for three days. Walking into a city does not cost you Stronghold standing, and quitting a faction does not free you from Exile; mode is about the life you are confirmed to be living, not your last errand.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (a PO3 quest-stage route or the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (life-mode state, book source, or rare condition)
     [STUB]   = only reachable via a dev-only signal activator/effect or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Day-to-day deltas from PDV_DeityLikesDislikes.csv (Malacath rows); curated deltas from PDV_Deity_Malacath.psc DELTA_*.
     Multiplier reality: the curated life-mode "signature" lanes (STRONGHOLD_FORGE, CITY_DIGNITY, LEGION_SERVICE,
     SELF_MADE_COMMUNITY) are NOT gain-scaled x1.00/0.75/0.60 by mode - each carries its own flat DELTA and passes a
     ConsumeDailyRepeatMultiplier anti-farm. The x1.00/0.75/0.60 "pace by mode" lives in the reward/tier calendars, not
     the per-act piety here. -->

Malacath only counts what you actually do. Lead with the deeds your mode is built around, and keep variety: repeating the exact same deed earns less each time, so a range of worthy acts always beats grinding one.

- **Forge worthy work (the Orc's prayer).** Crafting is the first and primary Orc devotional language. It must be quality work, though: real, valuable, or context-rich crafting and named commissions count. Raw spam at a workbench, ore mining, and vendor flipping do not. `[WIRED (generic craft) / STUB (curated forge): smithing fires the CSV Malacath smith-item (330) +0.5 via HandleStoryCraftItem -> RouteActionWithAttribution. The curated SIGNAL_STRONGHOLD_FORGE (+2.5) "quality forge at the hold" lane has NO organic caller - RouteOrcStrongholdForge fires only from the dev-only activator/effect (Devotion.esp:071027) and debug MCM. The CSV uphold-the-code (330) +0.25 Orc-gated row rides the same smith event.]`
- **Prove strength in a real fight.** Winning against a genuinely challenging enemy (around 5 or more levels above you) is noticed. Felling a dragon or another mighty beast is the truest proof of strength. Ordinary kill-counts are not the point; the fight has to be a real test. `[WIRED: CSV kill rows via OnActorKilled - kill-hostile-humanoid (2) +0.25, kill-hostile-beast (1) +0.25, kill-daedra (301, ActorTypeDaedra) +0.5, kill-dragon (302) +0.75. NOTE these are flat kill-event rows; there is no organic "5+ levels above you" challenge gate for Malacath - the level-delta framing is design language, not a wired condition.]`
- **Keep your oaths and finish what you committed to.** Completing a contract or quest you took on, especially when keeping it was hard, is devotion. The harder it was to honor, the more it counts. `[QUEST: keep_oath / prove_by_struggle / kill_honorable_combat Malacath matrix rows fire via ApplyQuestReaction on watched quests (e.g. CW01A/CW01B oath s160, C01 Proving Honor s200). There is no free-standing organic "finish a contract" hook outside the quest matrix and the life-mode service routes below.]`
- **(Stronghold) Answer the stronghold and provide for kin.** Helping stronghold Orcs, resolving stronghold crises like "The Cursed Tribe," and earning Blood-Kin are your strongest acts. Becoming Blood-Kin or resolving a major crisis is a marked, high-value moment. `[QUEST (mode driver, not direct piety): DA06 The Cursed Tribe (0x0003B681) stage 200 -> RouteOrcBloodKinCrisis from PDV_PlayerEvents. This routes RecordOrcLifeModeSignal(Stronghold) - it flips you into Stronghold mode as a major gate; it does NOT itself award SIGNAL_BLOOD_KIN piety. The curated SIGNAL_BLOOD_KIN (+3.0) has NO caller anywhere (STUB). The piety from DA06 comes through the Malacath quest-matrix milestone, not the crisis route.]`
- **(City) Hold your dignity under pressure and keep faith with other Orcs.** When a curated moment puts an Orc in front of contempt and you answer with dignity instead of bending, Malacath counts it. Helping other Orcs anywhere in Skyrim, and doing quality labor on a named commission, also count. `[QUEST/STUB: SIGNAL_CITY_DIGNITY (+2.0) fires organically ONLY from thane-quest stage-200 routes (RouteOrcCityDignity, IsOrcCityThaneQuest covers the nine hold thane quests). SIGNAL_SELF_MADE_COMMUNITY (+3.0) fires organically from one city-home quest (0x000A7B33 s10). Beyond those quest stages, the dignity/community lanes route only from the dev-only activator (Devotion.esp:071028/07102A). There is no ambient "answer contempt with dignity" hook.]`
- **(Legion / Exile) Complete hard service and endure.** Finishing a pressure-bearing faction or service contract counts. Carrying the code through a long, punishing stretch without breaking is noticed as endurance, though endurance alone is context, not free piety. `[QUEST/STUB: SIGNAL_LEGION_SERVICE (+2.5) fires organically from two vanilla stages - CW02A The Jagged Crown (0x0002D75C s200) and the Imperial Civil War finale (0x000D1444 s500, Imperial faction only). Otherwise RouteOrcLegionService routes only from the dev-only activator (Devotion.esp:071029). "Endurance" itself is not a wired earn.]`
- **Read the rare worthy texts and visit Malacath's holds.** Approved Orc texts and shrine moments register a little. Standing at each of the four strongholds (Dushnikh Yal, Mor Khazgur, Narzulbur, Largashbur) is recognized once each, with a milestone for reaching all four. Living rough, resting under the open sky like the exile, also earns a small note. `[WIRED (holds + open sky) / PARTIAL (texts): four-holds visits and the cultural substrate signal route once per hold; location presence also feeds Stronghold mode evidence. Rest-under-open-sky scores through the generic sleep event. Worthy texts route only from the curated Orc source list and DA06.]`

A few caps to know: each deed has an anti-farm limit so you cannot loop it for easy piety, and your gain from any single god is capped at roughly 4.3 per day. Only one temporary favor blessing can be active at a time.

## How You Lose Piety

- **Cowardice and weakness.** Stealing is the coward's path the honest outcast scorns. Striking or killing the defenseless is weakness Malacath despises. Both lose you piety. `[WIRED: CSV dislikes via the crime/kill hooks - steal-item (362) -0.25, assault-innocent (364) -0.75, murder-defenseless (304) -0.75.]`
- **Soft comfort.** Sleeping in a warm bed loses a little; the exile is meant to scorn the easy comfort. (Resting under the open sky, by contrast, earns.) `[WIRED: CSV sleep-in-inn (315) -0.25 via OnSleepStop when the player slept in an inn/warm bed.]`
- **Breaking faith.** Across all modes, breaking a real commitment matters. Self-erasure (swallowing an insult the code says must be answered, or abandoning the code to be tolerated) is a major loss. Betraying your own kin, deserting service mid-obligation, or selling out a stronghold or someone who depended on you is a serious loss. These only fire on concrete, authored moments, not from ambient grumbling, but they sting more than simple drift. `[PARTIAL (desertion) / STUB (oath-break, self-erasure): SIGNAL_BROKEN_FAITH_KIN (-2.0) fires organically only when the player DRIVES a life-mode switch OUT of Legion-Exile (ApplyOrcLifeModeSwitch -> EmitMalacathBrokenFaithKinMinus); the passive 14-day dawn lapse-to-City does NOT trip it. SIGNAL_OATH_BREAK (-1.5) has no organic caller - RouteOrcOathBreak fires only from the dev-only activator/effect and debug MCM. "Self-erasure / swallowing an insult" has no hook at all. The matrix also carries several negative Malacath deceit rows (DA02, TG00, DB01Misc, etc.), but almost all are echo/REVIEW -> INERT.]`
- **Neglect (the forge goes quiet).** If you go a long stretch without doing anything your mode values (no quality forging, no city dignity or labor, no completed service), Malacath simply stops watching. This is not punishment, it is absence. A standing penalty called "The Code Goes Unkept" sets in, lowering your armor rating by 5 until you return to worthy work, service, or kin. It clears the moment you start carrying the code again. `[WIRED: SyncOrcNeglectSpell adds PDV_SPEL_Neglect_Orc (Armor -5) when IsOrcCodeNeglected. NOTE the gate is a >5-day timer since the last LIFE-MODE signal (PDV.Orc.LastLifeModeSignalTime), OR the werewolf curse code-pressure flag - it is NOT a piety threshold. Because the forge/dignity/service curated lanes are mostly quest/dev-only, in practice the acts that reset the timer are stronghold-location presence, the wired quest-stage routes, and Malacath book reads, not day-to-day "quality forging" as the copy implies.]`
- **Natural drift.** Piety also fades slowly over time if you do nothing to maintain it, the same for every Orc mode. An exile holding the code alone does not get to decay slower than a stronghold Orc with a whole community behind them. `[WIRED: passive per-deity decay (~-0.5/day), uniform across modes.]`
- **The broad-worship cap.** If you spread yourself thin instead of committing, your standing is held back. Reaching Champion requires committing fully to Malacath through one life-mode; broad, uncommitted devotion stops short of the top. `[WIRED: broad worship caps at Devoted; a confirmed life-mode is required for Champion.]`

There is no separate reputation meter to manage for Orcs. The thing the world is reading is your life-mode and whether you are living it. A Stronghold Orc who drifts to the city without keeping the code is not betraying anyone; he is just becoming someone who used to be a Stronghold Orc, and the difference shows.

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for Malacath, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (real UESP/log citations, "small"/"milestone") are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... stepped down; reviewed A6 / REVIEW before promotion" and are **not** promoted (INERT). Note that DA06 stage 200 is ALSO the Blood-Kin life-mode gate (routes Stronghold mode via `RouteOrcBloodKinCrisis` in `PDV_PlayerEvents`); the matrix milestone is where its Malacath piety comes from.

**Malacath**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Cursed Tribe (DA06) | 200 | Defended Largashbur, bested Yamarz, lifted the curse; named Champion | + / C / milestone | WIRED (also flips Stronghold mode) |
| The Cursed Tribe (DA06 QE ghost variant) | 210 | Lifted the ghost-curse on Largashbur | + / m / small | WIRED (runtime-verify no ShutDownStage) |
| Joining the Legion (CW01A) | 160/200 | Swore the binding Imperial oath | + / C / milestone | WIRED |
| Joining the Legion (CW01A) | 1 | Cleared Fort Hraggstad in open battle | + / S / small | WIRED |
| Joining the Stormcloaks (CW01B) | 160/200 | Swore the binding Stormcloak oath | + / C / milestone | WIRED |
| Joining the Stormcloaks (CW01B) | 1 | Slew the Ice Wraith in proving combat | + / S / small | WIRED |
| Proving Honor (C01) | 200 | Won a place by a judged trial of valor | + / m / small | WIRED |
| Message to Whiterun (CW03) | 16 | Defended Whiterun from the dragon | + / S / small | WIRED |
| Death Incarnate (DB10) | 20 | Defended home/kin in open battle vs the Legion | + / S / small | WIRED |
| Dragon Rising (MQ104) | 160 | Slew the dragon defending Whiterun | + / S / small | WIRED |
| A Blade in the Dark (MQ106) | 200 | Slew Sahloknir in open battle | + / S / small | WIRED |

Plus ~27 echo rows flagged REVIEW -> INERT. These split into two families: honorable/struggle candidates stepped down from the Malacath Part B profile (C02/C03/C04/C05, dunHunterQST, MQ103, MQ105/MQ105U, MQ201Malborn, MQ206, MQ304, TG08A/TG09/DB02a/DB09 s200) and dishonor/deceit disapprovals (DA02, DA02KillObj, DA08, DB01Misc, DB06, DB09 s50, DB11, MQ201, TG00, TG03, TG04). None of these fire until promoted.

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage; tagged by life-mode):

- **The curated life-mode "signature" lanes are the prime remap target.** All four marquee acts - `SIGNAL_STRONGHOLD_FORGE` (quality forge at the hold), `SIGNAL_CITY_DIGNITY`, `SIGNAL_LEGION_SERVICE`, `SIGNAL_SELF_MADE_COMMUNITY` - ship as scored signals but reach play only narrowly: forge is **STUB** (dev-only activator Devotion.esp:071027 only; the organic forge earn is the generic CSV smith row, not the curated hold-forge). City-dignity, legion-service, and self-made-community each got a handful of **QUEST**-stage routes (thane quests s200, city-home s10, CW02A s200, CW finale s500) but no ambient organic hook; outside those exact stages they route only from the dev-only activator (Devotion.esp:071028/071029/07102A).
- **`SIGNAL_BLOOD_KIN` (+3.0) and `SIGNAL_EXILE_RETURN` (+3.0) are pure STUB - no caller anywhere.** The T3 communal-proof pieces of the design (being named Blood-Kin; the exile carrying a burden home) never got wired as piety. Blood-Kin is reached only as a *mode flip* through DA06 s200 (RecordOrcLifeModeSignal), and the "place made yours / hearth held" beat exists only as the SELF_MADE_COMMUNITY quest route + a notice, not as EXILE_RETURN.
- **The mode multiplier is not a per-act piety scalar.** The x1.00 / 0.75 / 0.60 "Stronghold fastest, Legion slowest" pacing lives in the reward/tier calendars. The curated signals carry flat DELTAs and a `ConsumeDailyRepeatMultiplier` anti-farm; they are not multiplied by life-mode at earn time. `AwardOrc*Signal(multiplier)` passes the anti-farm repeat multiplier, not a mode multiplier.
- **Orc code by mode.** The Orc mode reward family delivers Armor/Health through Stronghold, City, or Legion Exile records, with all three Champions converging on Armor +50. The visible families are `Code-Held - Stronghold`, `Code-Held - City`, and `Code-Held - Legion Exile`; this is the reward layer, not the gain layer.
- **Loss wiring.** Only three organic loss paths exist: the CSV dislikes (steal/assault/murder/inn-sleep), passive decay, and the desertion minus (`SIGNAL_BROKEN_FAITH_KIN`, only on a player-driven switch out of Legion-Exile). `SIGNAL_OATH_BREAK` and "self-erasure" are STUB/absent. The werewolf `SIGNAL_CURSE_CODE_RUPTURE` (-2.0) IS wired organically (ApplyOrcCurseHandlers on werewolf onset).
- **Neglect is a timer, not a piety floor.** `IsOrcCodeNeglected` trips on >5 days since the last life-mode signal (or the werewolf code-pressure flag), so the copy's "no quality forging" framing is loose - the resetting acts are really stronghold presence, the wired quest routes, and Malacath book reads.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Your standing climbs from None to Seeker (at 25 piety), to Devoted (at 50), to Champion (at 85). The number you need is the same in every mode. What changes is the pace: Stronghold reaches the top the fastest, City takes longer, and Legion/Exile takes the longest. That is by design. The rewards themselves are equalized, so City and Legion/Exile are complete devotional lives, not weaker ones, and every mode ends at the same peak.

There is also a broad blessing that holds before you have locked into a mode, or if you stay uncommitted. It is gentler than your mode's blessings and steps aside once a mode blessing is active.

**Broad blessing (holds in any mode; caps at Devoted):**

| Tier | What you gain |
|------|---------------|
| Seeker | Armor +15 |
| Devoted | Armor +30, Health Regeneration +8% |

Champion is not available to broad, uncommitted worship; you must commit to a life-mode to reach it.

**Stronghold Orc (forge, kin, and proven war-gear):**

| Tier | What you gain |
|------|---------------|
| Seeker | Smithing +5 |
| Devoted | Smithing +13, Heavy Armor +8 |
| Champion | Smithing +23, Heavy Armor +20, Armor +50 |

**City Orc (private fidelity and dignity held under pressure):**

| Tier | What you gain |
|------|---------------|
| Seeker | Restoration +5 |
| Devoted | Restoration +13, Speech +8 |
| Champion | Restoration +23, Speech +20, Block +5, Armor +50 |

**Legion / Exile Orc (foreign discipline and the arm that carries the code):**

| Tier | What you gain |
|------|---------------|
| Seeker | One-Handed +5 |
| Devoted | One-Handed +13, Block +8 |
| Champion | One-Handed +23, Block +20, Stamina Regeneration +5%, Armor +50 |

Note that all three Champion blessings carry the same +50 armor, so whichever life you live, you reach the same hardened peak.

## Unique Mechanics

**One god, three lives.** Most races choose a patron. You always have Malacath; what you choose, in effect, is how you live for him. Your life-mode quietly decides which acts feed your devotion and how fast it grows, and the world can challenge or confirm the mode you declared. This is the heart of the Orc experience.

**The Trial of Iron.** At a forge inside a stronghold or a place you have made your own, you can undertake the Trial of Iron and choose a single discipline: the Hammer (Smithing +5), the Shield (Armor +5), the Tusk (Unarmed +5), or the Yoke (Carry Weight +15). Only one can be active at a time, and choosing again swaps it. It has a cooldown of about a week, and saying "Not yet" does not waste that cooldown. If your standing in your mode collapses, the trial's gift fades at the next dawn and returns on its own when you recover. It lives at the forge on purpose, because Malacath's language is conduct, not prayer.

**The Code Holds.** Survive a fight after dropping to near death without fleeing the area and you get a brief surge of recovery, a small reminder that you held. At Champion, this surge is sharper and brings your stamina back too.

**A place made yours (City and Exile).** If you are living without a stronghold, you can declare a home, forge, or workplace as a place you mean to keep. Return to it after days of real worthy work or completed service, and over time it becomes a genuine hearth that grants a lasting stamina-recovery boost when you come back. Just visiting does not count; the place is held by the work and the oaths you bring to it. For a City Orc this reads as belonging you built; for an Exile, as a burden you carried home.

**The Four Holds.** Stand at each of the four Orc strongholds and each is counted once. Reach all four and a milestone marks it. For a City or Exile Orc, far from any stronghold, this is belonging that reaches across distance.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith |
|-------|----------------------------|
| Vampire | Belonging collapses. Vampirism is the opposite of everything Malacath values: strength through discipline, not feeding on others. The strongholds reject you, and your devotion to Malacath goes hollow and stops working, because the code needs a living Orc and you are no longer fully that. There is no Orc faith that replaces it while the curse holds. Curing the vampirism returns you to the test. `[PARTIAL: the vampire "exile from Malacath" is enforced through the shared curse/reward-gating layer (belonging collapse), not through a Malacath-specific vampire piety hook. There is no dedicated vampire-onset Malacath minus signal - the felt effect is loss of favor/reward, not a scored sting.]` |
| Werewolf | Conditionally accepted, if you prove yourself. Malacath judges the wolf by the same code as the smith: is it strong, does it endure, does it serve the people or destroy them? A disciplined beast with strength clearly in command can be tolerated, even in some stronghold contexts. It is not a free buff; it is a demanding test you stay under. While the curse pulls against the code, Malacath's regard cools, but if you carry it with strength and discipline, the code can still hold. `[WIRED: werewolf onset routes SIGNAL_CURSE_CODE_RUPTURE (-2.0) via ApplyOrcCurseHandlers -> EmitMalacathCurseCodeRuptureMinus on a transition INTO the werewolf state (Orc-gated, anti-farmed so curse flicker cannot stack it). This also sets PDV.Curse.Orc.CodePressure, which trips the neglect gate. "Carry it with discipline and the code holds" is narrative - only the one-time onset cooling is scored.]` |

## Quick Reference

- **Gods:** Malacath only. (Trinimac is rare lore pressure, not a worship path. Other gods and Daedra are not the Orc way.)
- **Starting choice:** No god to pick. You carry Malacath's code in one of three life-modes: Stronghold (fastest), City (slower, the default), or Legion / Exile (slowest). Declare your intent, but conduct confirms it.
- **Top 3 ways to gain:** Forge quality work; prove strength against real challenges; keep your oaths and finish what you committed to (plus your mode's own acts: stronghold provision, city dignity, or completed service).
- **Main ways to lose:** Cowardice and striking the defenseless; breaking faith or erasing yourself; neglect (the forge goes quiet); slow natural drift; spreading thin instead of committing.
- **Rough time to Champion:** About 30 to 45 days of normal play, faster if you focus hard. Stronghold is the quickest; City takes longer; Legion / Exile is the longest by design.
