# Bosmer - Four Roads Out of the Green

## Overview

The Bosmer carry the oldest covenant in Tamriel: the Green Pact, the bargain Y'ffre made with the Wood Elves themselves. But in Skyrim there is no forest to enforce it and no warden checking whether you ate a carrot. That absence is the whole point. Far from Valenwood, you have to decide for yourself what the covenant really means - the law, or your relationship with the god the law stands for.

That question has four honest answers, and Devotion lets you pick one. More than any other race, the Bosmer are defined by the path you choose at the start, not by a single patron handed to you. Two players can both be Wood Elves and live in completely different religions: one keeping the strict hunter's code, one telling stories around community fires, one settling debts, one surviving on the road.

Whatever you choose, a thread of Green Pact memory runs underneath all of it. Proper hunting, eating what you kill, and respecting the living world earn you a little quiet favor on every path. Only one path turns that memory into a hard rule.

## Your Gods

The Bosmer pantheon in Devotion is small and personal:

- **Y'ffre** - the Storyteller, the singer of the world and keeper of the Green Pact. He is the god of two of the four paths (the strict Old Contract and the gentler Living Story), the same god heard two different ways.
- **Z'en** - the god of toil, debt, and fair return. Not revenge and not charity. Z'en keeps the ledger of what is owed. (He is not Zenithar; they are different gods.)
- **Baan Dar** - the Bandit God, patron of exiles, tricksters, and clever survivors who lived by not being where power was looking.

Beneath these, a secondary layer of gods stirs on every path: **Arkay** for death rites, **Xarxes** for ancestry, **Mara** for family and community, and **Stendarr** for mercy. They are background influences, not paths you commit to. Skyrim has no Y'ffre shrine, so **Kynareth** shrines stand in as a fair proxy when you want to make an offering.

The Daedric Princes and other foreign gods are not part of the normal Bosmer backbone. **Hircine** (the hunt and the curse) and **Nocturnal** (the criminal underworld) are pressures a Wood Elf might fall into, but they are not a Bosmer's home theology.

## Getting Started

Right after your character is created, Devotion asks you to choose your path. This is a real fork in the road, and each branch plays differently:

- **The Old Contract (Y'ffre, strict).** You take the Green Pact literally. This is the only path with hard compliance: a hidden discipline meter tracks how well you keep the covenant. Eating meat and hunting properly keeps it high; eating plant food, drinking plant-based potions, and cutting wood pull it down. It is the hardest path to live and the strongest payoff if you do. Choose this if you want the covenant to be a genuine daily test.
- **The Living Story (Y'ffre, moderate).** The covenant kept alive through memory, community, and storytelling instead of strict rules. You earn favor by helping people preserve and protect what matters and by visiting nature sites. It is the most flexible path, the easiest to enter, and the safe fallback if you ever lose your way. Choose this if you want Bosmer faith without the food policing.
- **The Exchange (Z'en).** A faith built on balance. Settle debts, keep your promises, trade fairly, and answer wrongs with proportionate justice. Choose this if you want your devotion measured in honor and the careful accounting of what is owed.
- **The Bandit Road (Baan Dar).** The theology of the exile. Sleep rough, travel the open road, survive against the odds, and stand with other outcasts. Choose this if you want a faith of cunning and improbable survival.

First-run choice is free. Switching later is not a casual toggle - the world has to confirm the new path through your actions, and it carries a real cost (see Unique Mechanics). The Living Story is the easiest path to move into; the Old Contract is the hardest to return to.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (path/sect/mode state or rare condition)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Deltas from PDV_DeityLikesDislikes.csv (day-to-day) and PDV_Deity_*.psc DELTA_* (curated). -->

Remember that piety is tracked separately for each god, daily gains are capped (about 4.3 per god per day), and repeating the exact same deed earns less each time. Variety beats grinding. Your main earning deeds depend on your path:

**Old Contract (Y'ffre)**
- Hunting an animal properly - a clean, respectful kill, not wanton slaughter (a stalked, first-arrow kill is the real hunt). `[STUB: dev-only activator BosmerOldContractProperHunt 071035; no organic clean-kill hook - fires only from the debug MCM]`
- Eating meat or other animal-sourced food and keeping plant food out of your diet. `[WIRED: OnObjectEquipped -> RouteBosmerGreenPactFood -> PACT_POSITIVE +2.0]`
- Keeping the forest: restraint with the living world, leaving the green intact. `[STUB: dev-only activator BosmerOldContractForestKept 071036; no organic hook]`
- Putting down the undead, which restores the natural cycle the Pact protects. `[WIRED: CSV kill-undead (300) +0.5, kill event]`

**Living Story (Y'ffre)**
- Helping an NPC preserve, protect, or remember something that matters (community, tradition, a life). This must be genuine help, not a trivial errand. `[STUB: dev-only activator BosmerLivingStoryCommunityKept 071037; no organic hook]`
- Visiting a nature site - a grove, a standing stone, an outdoor sanctuary. `[WIRED: 6 curated green-song sites in PDV_FLST_BosmerGreenSongs, location hook -> AwardBosmerSong -> LIVING_STORY +2.5, one-shot per site. The separate dev-only NatureSite activator 071038 is unused.]`
- Healing or curing the hurt, and reading the old lore and songs of the world. `[WIRED: CSV heal-or-cure-npc (350) +0.5; read-lore-book (342) +0.25]`
- The secondary gods add texture here: burial and grief quests please Arkay, ancestry choices please Xarxes, family and community work pleases Mara, and choosing mercy pleases Stendarr. `[QUEST/INERT: only via the quest-reaction matrix for those deities; almost all Bosmer-adjacent rows are echo rows flagged "REVIEW before promotion" - largely inert]`

**Exchange (Z'en)**
- Settling a debt or honoring a contract or promise, especially under pressure. `[STUB: dev-only activator BosmerExchangeDebtSettled 071039; no organic hook]`
- Completing a quest that redresses a wrong - proportionate vengeance, the account made even. `[STUB: dev-only activator BosmerExchangeProportionateVengeance 07103A; no organic hook]`
- Defending allies by striking an enemy who attacked first, rather than being the aggressor. `[STUB: no organic Z'en "defend ally" hook; not present in the likes table]`
- Honest labor and craft: cooking, smithing, brewing, and studying a trade all repay the world its due. `[WIRED: CSV Z'en cook-meal (333) +0.5, smith-item (330) +0.5, brew-potion (332) +0.25, enchant-item (331) +0.25, read-skill-book (340) +0.25, increase-skill (344) +0.25]`

**Bandit Road (Baan Dar)**
- Sleeping outdoors and living the road instead of resting in inns. `[WIRED: CSV rest-under-open-sky (313) +0.5, OnSleepStop. The dev-only RoadLife activator 07103B is the separate curated lane.]`
- Surviving combat against severe odds - outnumbered, outmatched, and winning anyway. `[STUB: dev-only activator BosmerBanditRoadReversal 07103C; no organic outnumbered-survival hook]`
- Pickpocketing or slipping past a notable target; the trickster opens every door. `[WIRED: CSV pick-owned-lock (360) +0.25, steal-item (362) +0.5, trespass (361) +0.25]`
- Discovering new places and sharpening your skills - the survivor walks every road and adapts. `[WIRED: CSV discover-location (345) +0.5, increase-skill (344) +0.25]`

On every path, a respectful offering at a Y'ffre shrine (or a Kynareth shrine as the proxy) earns piety. `[PARTIAL: shrine blessings were normalized to cure-only; shrine-prayer piety is not confirmed as an organic earn - verify]` And the shared Green Pact memory means proper hunting and animal-sourced food give a small bonus even off the Old Contract. `[WIRED (food) / STUB (hunting): SHARED_PACT_MEMORY +1.0 fires off-path from animal-sourced food; the "proper hunting" half has no organic hook]`

## How You Lose Piety

- **Dislikes.** Each god turns away from acts that offend it. Y'ffre dislikes raising the undead, shaping dead matter through smithing and enchanting, and harming the innocent. Z'en dislikes theft (a debt taken and never paid), breaking into property, and killing those who owe nothing. Baan Dar, fittingly, dislikes the clumsy murder of the defenseless and the settled smith's honest trade - the road owes nothing to comfort. `[WIRED: CSV dislikes - Y'ffre raise-undead (365) -1.0, smith-item (330) -0.25, enchant-item (331) -0.25, assault-innocent (364) -0.5; Z'en steal-item (362) -0.75, pick-owned-lock (360) -0.25, murder-defenseless (304) -1.0; Baan Dar murder-defenseless (304) -0.75, smith-item (330) -0.25. Note: Baan Dar LIKES trespass/ambush.]`
- **Neglect ("The Path Goes Quiet").** If you stop walking your path, your god grows quiet. For a Bosmer this kicks in once a god's piety has fallen to 10 or below and that god is among your lowest - this is a gentle drift, not a punishment. It slows your stamina recovery by 5% until you walk the path again. (Note this is lower than the usual neglect line; your path forgives a longer silence before it fades.) `[WIRED: neglect gate piety <=10 and bottom-3; Stamina Regeneration -5%]`
- **Natural drift.** Piety eases downward over time if you never feed it. Quiet weeks cool any god. `[WIRED: passive decay ~-0.5/day per deity]`
- **The broad-worship cap.** If you spread yourself thin and never commit, you are capped at Devoted. Reaching Champion requires committing fully to a single path and its god. `[WIRED: broad worship caps at Devoted]`
- **The Old Contract penalty (this path only).** On the Old Contract, breaking the Green Pact - eating plant food, defiling the forest, breaking your restraint - is a real loss. Y'ffre's regard cools and the Pact tightens against you. The other three paths get the Green Pact's gentle bonus but never this penalty. `[WIRED (plant food) / STUB (defile forest): OnObjectEquipped plant food -> PACT_VIOLATION -2.0 on the Old Contract; "defiling the forest" has no organic hook]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Bosmer gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (with real UESP citations) are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT).

**Y'ffre**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Kyne's Sacred Trials (dunHunterQST) | 100 | Hunted with respect under the forest's law | + / m / small | WIRED |
| The Blessings of Nature (T03) | 200 | Restored the Gildergreen | + / S / small | WIRED |
| The Blessings of Nature (T03) | 100 | Tapped the Eldergleam with Nettlebane | - / C / small | WIRED |

Plus 1 echo row (DA05 Ill Met By Moonlight, the_hunt) flagged REVIEW -> INERT.

**Z'en**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Kolskeggr Mine reclaim (FreeformKolskeggrA) | 200 | Restored the mine to honest labor | + / S / small | WIRED |
| Recipe for Disaster (DB08) | 200 | Stole the Writ of Passage | - / m / small | WIRED |
| A Chance Arrangement (TG00) | 200 | Framed Brand-Shei | - / m / small | WIRED |
| Taking Care of Business (TG01) | 200 | Extorted shopkeepers | - / S / small | WIRED |
| Loud and Clear (TG02) | 200 | Burgled Goldenglow | - / m / small | WIRED |
| Dampened Spirits (TG03) | 200 | Ruined an honest brewer | - / S / small | WIRED |
| Hard Answers (TG06) | 200 | Burgled/forged Gallus's journal | - / m / small | WIRED |

Plus ~8 echo rows (keep_oath / uphold_law_justice: BardsCollegeLute, CW01A, CW01B, DA03, DarkBrotherhoodSanctuaryRepair, DB02a, FreeformSkyhavenTempleA, TG08A) flagged REVIEW -> INERT.

**Baan Dar**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Delayed Burial (DB01Misc) | 200 | Lied to the guard about Cicero (harmless trick) | + / C / milestone | WIRED |
| Diplomatic Immunity (MQ201) | 250 | Clever infiltration/reversal vs the Thalmor | + / C / milestone | WIRED |
| Dampened Spirits (TG03) | 200 | Pariah prank toppling a rich man's table | + / m / small | WIRED |
| Scoundrel's Folly (TG04) | 200 | Slipped through the strong men's halls | + / m / small | WIRED |
| Blindsighted (TG08B) | 50 | Robbed the betrayer Mercer | + / m / small | WIRED |

Plus ~20 echo rows (mostly prove_by_struggle / deceit / kill_the_helpless across C01, C02, DA02, DA06, DA08, DB01, DB05, DB06, DB09, DB11, MQ101, MQ105, MQ206, MQ301, MQ305, TG05, dunHunterQST) flagged REVIEW -> INERT.

Caveat: all day-to-day CSV rows above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix is live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage; tagged by path):

- **Old Contract:** "proper hunting (a clean first-arrow kill)" and "keeping the forest" have **no organic hook** - they exist only as dev-only activators 071035/071036 (debug MCM). The real Old Contract organic gains are eating meat/insect food (PACT_POSITIVE) and visiting the 6 green-song sites.
- **Living Story:** "helping a community preserve/protect/remember" is dev-only 071037 (no organic hook). Real Living Story organic gains are the green-song sites, healing/curing, and reading lore. The separate NatureSite activator 071038 is unused (green songs cover nature sites).
- **Exchange:** "settling a debt," "proportionate vengeance," and "defending allies" have no organic hooks (071039/07103A dev-only; defend-ally absent from the table). The only organic Exchange gains are generic honest craft/labor (Z'en cook/smith/brew/study), which are not debt-specific.
- **Bandit Road:** "surviving against the odds" is dev-only 07103C (no organic hook). Real organic gains are sleeping outdoors, theft/lockpick/trespass, discovery, and skill-ups.
- **Pattern:** four of the five curated "signature" lanes (Old Contract hunt/forest, Living Story community, Exchange debt/vengeance, Bandit Road road-life/reversal) ship as scripts + dev-only senders but never got organic triggers. Only two curated lanes were organically hooked: animal food (PACT_POSITIVE) and green-song location. This is the prime remap target for the race.
- **Secondary Living Story gods** (Arkay/Xarxes/Mara/Stendarr) reach Bosmer play only through the quest matrix, and the Bosmer-adjacent rows are almost all echo/REVIEW -> inert.
- **Shrine offering** piety is unconfirmed (shrines normalized to cure-only).

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Devotion tiers go None, then **Seeker** (25 piety), **Devoted** (50 piety), then **Champion** (85 piety). Your bonuses depend on your path. Each path's gifts grow at each tier:

**Old Contract (Y'ffre) - the sharpest hunter, the heaviest burden**

| Tier | Bonuses |
|------|---------|
| Seeker | Archery +5 |
| Devoted | Archery +13, Sneak +10 |
| Champion (Keeper of the Pact) | Archery +25, Sneak +22, Poison Resistance +10% |

**Living Story (Y'ffre) - the storyteller and mender**

| Tier | Bonuses |
|------|---------|
| Seeker | Speech +5 |
| Devoted | Speech +13, Health Regeneration +10% |
| Champion (Story-Keeper) | Speech +25, Health Regeneration +25%, Magicka Regeneration +5% |

**The Exchange (Z'en) - the keeper of the ledger**

| Tier | Bonuses |
|------|---------|
| Seeker | Speech +5 |
| Devoted | Speech +13, Carry Weight +30 |
| Champion (Z'en's Reckoning) | Speech +25, Carry Weight +80, Armor +50 |

**The Bandit Road (Baan Dar) - the survivor**

| Tier | Bonuses |
|------|---------|
| Seeker | Armor +15 |
| Devoted | Armor +30, Health Regeneration +10% |
| Champion (Baan Dar's Luck) | Armor +50, Health Regeneration +25%, Sneak +10 |

If you worship broadly without committing to a path, you receive a softer, Y'ffre-flavored woodland blessing instead (a small Stamina Regeneration bonus, rising to Stamina Regeneration and a Sneak bonus at the Devoted cap). It is always weaker than a committed path, and it switches off entirely once you commit.

Reaching Champion takes roughly 30 to 45 days of normal play (one or two devotional acts a day), or about 20 days if you focus hard. Bosmer progress can feel a touch slower than some races because the paths reward bursts of meaningful action rather than constant small acts.

## Unique Mechanics

**Path divergence.** This is the heart of the Bosmer experience. You are not a race package with a patron bolted on - you chose a theology, and the game scores only the behaviors that theology cares about. A Bandit Road Bosmer who starts piling up wealth and civic standing earns almost nothing. A Living Story Bosmer who never helps anyone preserve anything lets their path fall silent. Living your chosen identity is the friction, and it is what makes each Wood Elf feel distinct.

**Green Pact compliance (Old Contract only).** On the strict path, a hidden discipline meter runs from worship-blocked at the bottom to a strong bonus at the top. It rises when you eat meat and hunt properly and falls when you eat plants, drink plant-based potions, or work wood. If it stays at rock bottom for three days in a row, Y'ffre confronts you in person with a choice: recommit or renounce. This forced reckoning is a designed scene, the most dramatic neglect moment in the whole mod. You may return to the path once, but a second renunciation closes Y'ffre's door forever.

**Path switching has a cost.** You can change paths, but the world must confirm it through your deeds, not just your intentions. The Living Story accepts you with a single strong community act. The Exchange and Bandit Road each ask for two fitting deeds on separate days within a week. The Old Contract demands an explicit recommitment and three Pact-keeping days. Switching always costs you a measure of standing - what you earned does not follow you down the new road.

**Path-specific moments.** Each path also has small living beats. The Exchange gives a brief barter boost after settling a contract. The Bandit Road grants a short burst of speed when you drop low in a fight and need to escape - separate from Baan Dar's rare weekly luck. All paths can earn a temporary "told-self" blessing through a quiet naming rite (Hunter, Speaker, Wanderer, or Keeper), though only one favor can ever be active at a time across all your gods.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith |
|-------|----------------------------|
| **Vampire** | The harder break for a Bosmer. The living covenant does not extend to the undead, so on the Old Contract the Pact closes immediately - Y'ffre is shut to you. On the other three paths it is a serious strain but not a total collapse; that theology bends more around edge cases. Curing the vampirism reopens the door. |
| **Werewolf** | Easier for a Wood Elf to make sense of, because the beast-shape echoes the old Wild Hunt. It is never Green Pact approved - Hircine offers an illicit, unsanctioned route to shapeshifting - but it is intelligible. On the Old Contract it is the most serious violation, and keeping your compliance up becomes harder while cursed. On the other three paths it is contested strain rather than automatic collapse. |

Neither curse is permanent if you seek a cure, but the Old Contract is the path that takes both hardest, because it takes the covenant most literally.

## Quick Reference

- **Gods:** Y'ffre (Old Contract and Living Story), Z'en (Exchange), Baan Dar (Bandit Road); Arkay, Xarxes, Mara, and Stendarr in the background.
- **Starting choice:** Pick one of four paths at the start - Old Contract (strict hunter), Living Story (community storyteller), Exchange (debt and balance), Bandit Road (road survivor). Switching later costs you.
- **Top 3 ways to gain (by path):** Old Contract - proper hunting, eating meat, keeping the forest. Living Story - helping a community preserve something, nature-site visits, healing the hurt. Exchange - settling debts, redressing wrongs, defending allies. Bandit Road - sleeping outdoors, surviving against the odds, outwitting notable targets.
- **Main ways to lose:** Acts your god dislikes, neglect once a god falls to 10 or below (gentle stamina drift), spreading yourself thin (capped at Devoted), and on the Old Contract, breaking the Green Pact.
- **Rough days to Champion:** About 30 to 45 days of normal play, around 20 if you focus - and only by committing to a single path.

See the How Devotion Works primer for the shared rules on tiers, daily caps, and reading your standing in the Devotion panel, the MCM menu, and the Book of Days journal.
