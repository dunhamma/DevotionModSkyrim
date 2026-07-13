# Altmer - The Long Road Back to the Dawn

## Overview

For the Altmer, faith is not comfort. It is a project. Their highest ancestor, Auri-El, the god of time, escaped Mundus, the mortal world that Lorkhan tricked the spirits into building. Every devotional act is a step along the road back to that lost divine nature. This is the Apotheosis project: to stop being mortal and become spirit again.

The trouble is that Skyrim is Lorkhan's world. Marriage, building a home, the Companions, being declared Dragonborn, learning the Thu'um, walking into Sovngarde: these are all, in Altmer eyes, concessions to the thing that broke them. Ordinary life is fine. Traveling, doing quests, sleeping indoors, having friends: none of that costs you anything. But certain big, meaningful choices carry a real theological price. Devotion calls this the Lorkhan pressure, and it is what makes Altmer the most demanding faith in the mod.

At the start you pick a faction lean: how you relate to Thalmor orthodoxy. That choice sets a coherence track that colors the rest of your play. Above it all, Auri-El's dawn is always with you, no matter which path you walk. If this is your first Devotion character, read the How Devotion Works primer first, then come back here.

Your ordered heritage advances at a deliberate daily pace. Only the first
qualifying act after each 06:00 dawn counts: ordered rest after resolving the
rite, disciplined magical study, a completed enchantment, an Auri-El rite, or
an exact heritage milestone. Passive dawn does not advance it. Its visible
stages are `Ordered Heritage`, `Disciplined Heritage`, and `Exemplar Heritage`.

## Your Gods

The Altmer honor the Aldmeri ancestor-spirits, the et'Ada who once were divine. Your patron options are:

- **Auri-El** - the supreme ancestor, god of time, the one who walked the road back first. He is your foundation and is always with you, whatever else you do.
- **Magnus** - the architect of magic, who fled the world and left an aperture behind. The god of disciplined study and the arcane arts.
- **Xarxes** - the ageless scribe of Auri-El, keeper of lineage, lore, and the long record of all that was.

Two more figures shape Altmer faith without being patrons you can fully commit to. **Trinimac**, the unbroken warrior-god, is the spirit of civilization defended by force; he stands behind the most orthodox, enforcement-minded path. And foreign gods matter mostly as pressure: anything tied to **Lorkhan**, **Shor**, **Talos**, or the Nordic divine frame works against your coherence rather than for it.

The Daedric Princes are the oldest forbidden ground. Consorting with Daedra breaks the most ancient Altmer religious law. The Princes can still be approached through the mod's shared Daedric path, but for an Altmer that is a rupture, not devotion.

## Getting Started

When you begin as an Altmer, you choose your faction lean. This sets your starting position on a coherence track called Thalmor Alignment, which runs from openly heterodox at one end to full Thalmor enforcer at the other. The three starts are:

- **Thalmor Orthodox** - you begin high on the track. Enforcement and orthodox restraint are your faith made visible. The catch: Lorkhan pressure hits you hardest here, so a strict, orthodox Champion is the most punishing path in the game. That difficulty is the point.
- **The Divine Body** - you begin in the middle. A balanced, moderate cultural practice. Lorkhan pressure hits at normal strength. This is the path for someone who wants coherence without rigid enforcement or full heterodoxy.
- **Psijic Tradition** - you begin low on the track, in the Old Ways. Self-cultivation, study, and the Elder Way are your faith. Lorkhan pressure is softest here, which makes reaching Champion the most achievable, with the quietest and most self-possessed payoff.

The track is not locked to your start. Your actions move it. Orthodox acts (cooperating with the Thalmor, reporting Talos worshippers) push you up; heterodox acts (helping a Thalmor prisoner, reading banned texts) push you down. The point is coherence: your deeds should match your stated position. An Orthodox Altmer who consorts with Daedra and shelters Talos worshippers does not just lose ground; they become theologically incoherent, and the track shows it.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the P2 quest-stage faucet or the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (curated-book-only, faction-gated, or crisis-state gated)
     [STUB]   = only reachable via a dev-only signal activator/effect or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     Day-to-day deltas from PDV_DeityLikesDislikes.csv; curated deltas from PDV_Deity_*.psc DELTA_*. -->

Auri-El is always with you, so dawn practice is your steady foundation. From there, leaning into study and the arcane arts is the Altmer way. Lead with these:

- **Observe the dawn.** Acknowledging Auri-El's sun in the morning window is your daily foundation. Steady, once a day, credited to Auri-El. `[PARTIAL: dawn steadiness is real but does NOT fire from a time-of-day / morning-window check. RouteAltmerDawnSteadiness() (the standalone "observe the dawn" act) has only dev-only callers (PDV_EventSignalActivator ROUTE_ALTMER_DAWN_STEADINESS / PDV_EventSignalEffect). The dawn-steadiness pulse (Auri-El SIGNAL_DAWN_ACKNOWLEDGMENT +1.0 via HandleAltmerDawnSteadiness -> AwardAltmerDawnSignal) reaches you organically ONLY by reading a curated Auri-El sacred text (see below), not by standing outside at dawn.]`
- **Study with discipline.** Reading rare and lore-heavy tomes feeds your scholar gods. Reading spell tomes pleases Magnus; reading lore and skill books pleases Xarxes and Auri-El. Curated texts give a real boost the first time. `[WIRED: two layers. (1) Day-to-day CSV (blank originGate): auri-el read-lore-book (342) +0.25; magnus read-spell-tome (341) +0.75, read-lore-book (342) +0.25; xarxes read-lore-book (342) +0.75, read-skill-book (340) +0.5, read-spell-tome (341) +0.5. (2) Curated first-read of a vanilla sacred book on the P2 source lists: OnBookRead -> RouteP2ImmersiveSource -> HandleP2Source -> RouteAltmerAurielFoundation / RouteAltmerMagnusScholarship / RouteAltmerXarxesLineage. Auri-El books route HandleAltmerDawnSteadiness (Auri-El SIGNAL_DAWN_ACKNOWLEDGMENT +1.0); Magnus books route the same handler but award Magnus SIGNAL_DISCIPLINED_STUDY +1.8 (reason contains "magnus"); Xarxes books route HandleAltmerOrthodoxCostlyEnforcement and award Xarxes SIGNAL_LINEAGE_HONORED +2.2 (reason contains "xarxes"). PlayerEvents.psc:1078-1085.]`
- **Reach a magic milestone with restraint.** Advancing a school of magic as a marker of mastery (not casting spells over and over) honors Magnus. This is finite, study-framed progress, not button-mashing. `[WIRED: HandleStoryIncreaseSkill -> HandleAltmerMagicSkillIncrease (ActionRouter.psc:221). One-shot at each of skill 25/50/75/100 for Alteration, Conjuration, Destruction, Enchanting, Illusion, Restoration -> Magnus SIGNAL_MAGIC_MILESTONE (awarded scaled 4.0). Finite by construction: four thresholds per school, each fires once.]`
- **Advance with discipline.** Mastering a skill, enchanting an item, learning a Word of Power as a step in study: these all read as disciplined self-perfection toward the ascent. `[WIRED: day-to-day CSV (blank originGate) - auri-el increase-skill (344) +0.5, learn-word-of-power (343) +0.75, kill-undead (300) +0.5; magnus enchant-item (331) +0.5, increase-skill (344) +0.25, brew-potion (332) +0.25; xarxes increase-skill (344) +0.5, enchant-item (331) +0.25, learn-word-of-power (343) +0.25, discover-location (345) +0.25, kill-undead (300) +0.5. auri-el heal-or-cure-npc (350) +0.75, rest-under-open-sky (313) +0.25.]`
- **Hold coherent under pressure.** Costly, orthodoxy-gated duty (with your Thalmor Alignment high) credits the foundation. Defending civilization at real cost is the orthodox act made into faith. `[STUB: RouteAltmerOrthodoxCostlyEnforcement() (the standalone orthodox-cost act) has only dev-only callers (PDV_EventSignalActivator ROUTE_ALTMER_ORTHODOX_COST / PDV_EventSignalEffect). The HandleAltmerOrthodoxCostlyEnforcement handler IS reached organically, but only by Xarxes book-reads (which award Xarxes, not the orthodox-cost foundation). There is no organic "orthodoxy-gated costly duty" detector - orthodox enforcement never fires from real Thalmor-side play.]`
- **Reassert after a crisis.** When a big Lorkhan moment shakes you, responding with coherent action afterward (a dawn rite, a focused act of your patron) is itself rewarded. Coherence answering back is the core Altmer rhythm. `[PARTIAL: the crisis STATE is real and organic (MQ104 s160 etc. set ALTMER_CRISIS_DISSONANT), and simply earning piety again while a crisis is open lets your positive economy keep climbing. But there is no dedicated "reassert" reward: ResolveAltmerCrisis() is defined and never called, so the Reasserting/Scarred-Resolved resolution is not organically invokable. In practice "answering back" = keep doing your ordinary book/skill/milestone gains; the crisis label is flavor, not a scored beat.]`

Two more organic sources worth naming:

- **Ordered dreams while you rest.** Rest after resolving the rite decision can advance Ordered Heritage once for the devotional day. Magnus piety is separate and requires a Magnus-authentic act.
- **Disciplined heritage.** Magical cultivation, completed enchantment, an Auri-El rite, or an exact heritage milestone can claim the same daily cultural credit. Passive dawn does not.
- **A declined discipline rite stays quiet briefly.** Choosing `Not yet` does not spend the seven-day accepted-rite cooldown or choose a discipline, but it suppresses the same prompt for three devotional days so ordinary rest does not reopen it every night.

Remember that piety is tracked separately for each god, daily gain is capped at about 4.3 per god per day, and repeating the exact same deed earns less each time. Variety and meaning matter far more than grinding.

Note that several acts an Altmer might expect to matter earn nothing by design and are explicitly rejected: ordinary travel, generic spellcasting, generic College membership, generic helping, generic anti-Thalmor violence, repeated Dragonborn identity, and the vampire-power route. `[WIRED rejection: IsAltmerRejectedLorkhanSurface gates these source ids out of Lorkhan pressure; the P2 source-list rejectedUse fields exclude "generic magic / generic College rank / generic anti-Thalmor action" from the earn lists. These do not earn and do not cost.]`

## How You Lose Piety

- **Dislikes.** Your gods recoil from base acts. Murdering the defenseless drags the soul down from its ascent (a large hit for Auri-El). Necromancy and raising the dead invert the whole Apotheosis project. And accepting a Daedric artifact offends every Altmer god, because the Daedra are lesser spirits beneath the light. `[WIRED: day-to-day CSV dislikes - auri-el murder-defenseless (304) -1.5, raise-undead (365, ActorTypeUndead) -1.5, assault-innocent (364) -0.5, accept-daedric-artifact (368, ActorTypeDaedra) -1.0. magnus raise-undead (365) -0.75, accept-daedric-artifact (368) -0.75. xarxes raise-undead (365) -1.0, murder-defenseless (304) -0.75, accept-daedric-artifact (368) -0.5.]`
- **Lorkhan pressure.** This is the signature Altmer cost. It fires only on specific, meaningful choices, never on ordinary life. The biggest are touching Talos directly, entering Sovngarde, or wielding the wrong relics. Lesser ones include learning the Thu'um, joining the Stormcloaks, being declared Dragonborn, getting married, or building a homestead. Your faction lean scales how hard these land: Orthodox feels them at full force, Psijic feels them softened. `[QUEST/PARTIAL: HandleAltmerLorkhanPressure deducts a tiered penalty (2.0 to 10.0) from your active deity (Auri-El by default), scaled by GetAltmerLorkhanFactionModifier (Thalmor Alignment: 0.75x heterodox to 1.5x orthodox). Organic firing is narrow: MQ104 s160 (Dragonborn declaration), MQ304 s200 (Sovngarde), and C03 s200 all route RouteAltmerLorkhanPenalty via the P2 quest-stage faucet (PlayerEvents.psc:1203-1213), plus any vanilla book on PDV_FLST_P2_AltmerLorkhanPenalties. The broader "Talos / Stormcloaks / marriage / homestead / Thu'um" list is NOT wired to organic triggers - those tiers exist only through the dev-only PDV_EventSignalActivator/Effect (ROUTE_ALTMER_LORKHAN_PRESSURE). Rejected surfaces (ordinary_travel, generic_combat, dragonborn_repeat, vampire_power_route, etc.) are refused by IsAltmerRejectedLorkhanSurface.]`
- **Crisis of faith.** The largest theological collisions (the Dragonborn declaration, Sovngarde, marriage as mortal continuity, the Companions beast-blood fork) do not just deduct piety. They open a crisis: a flavored moment of dissonance with only a small temporary sting, which you resolve by living coherently afterward. A crisis never strips your patron away, and your positive piety keeps working while it is unresolved, so you can always climb back. `[QUEST: HandleAltmerCrisisSource sets ALTMER_CRISIS_DISSONANT/QUESTIONING. Organic sources are the same three quest stages that route crisis alongside the Lorkhan penalty - MQ104 s160 (Dragonborn), MQ304 s200 (Sovngarde), C03 s200 (PlayerEvents.psc:1205/1208/1212 -> RouteAltmerCrisisSource). Talos and Companions crisis sources exist in HandleAltmerCrisisSource but have no organic caller (dev-only). NOTE: the crisis has no scored "resolution" - ResolveAltmerCrisis() is never called (see gain section); it is a state label plus a discipline-spell fade (SyncAltmerDisciplines removes your discipline boon while dissonant), not a repeatable piety event.]`
- **Neglect.** If you stop practicing, the dawn is withheld. Your magicka regenerates a little more slowly until you return to dawn practice and the ancestral order. For Altmer, neglect is really inconsistency: an Orthodox who drifts toward the middle, or a Psijic who stops cultivating, feels not punished but increasingly undefined, as their old advantages stop landing as hard. `[WIRED: IsAltmerCoherenceNeglected -> SyncAltmerNeglectSpell adds PDV_SPEL_Neglect_Altmer (Magicka Regeneration penalty). NOTE the gate is time-since-last-favor-source (> 3.0 days since PDV.Altmer.Favor.LastGameTime), NOT a piety threshold. And because "favor source" is set only by HandleAltmerDawnSteadiness / HandleAltmerOrthodoxCostlyEnforcement, in practice the only organic acts that reset the neglect timer are curated Auri-El/Magnus/Xarxes book-reads - not the CSV day-to-day gains or the magic milestones. Reading a sacred text is what "returns you to the dawn."]`
- **The Thalmor Alignment track.** This is your coherence meter, and it is plainly readable in your standing. Acts that contradict your stated position push it the wrong way. There is no generic broad-worship path for Altmer; staying coherent with your chosen stance is what organizes your faith instead. `[PARTIAL: the track (Concordat-style -100..+100, 5 states) moves, but it is a coherence meter, NOT piety - ApplyAltmerAlignmentAction adjusts PDV_ThalmorAlignmentTrack points only, and its sole gameplay bite on piety is the Lorkhan faction modifier above. Organic movers are few: read_banned_texts (The Talos Mistake book 000ED04D, OnBookRead:277) -5; consort_with_daedra (equipping any faucet Daedric artifact:331) -25; kill_thalmor_agent (unprovoked Thalmor kill via HandleThalmorUnprovokedKill) -20. The orthodox movers arrest_talos_worshipper (+15) and complete_thalmor_mission (+20), and help_thalmor_prisoner_escape (-15), have NO organic caller - they are reachable only through the debug MCM / dev routes.]`

Note the broad-worship rule that applies to every race: honoring several gods at once keeps you capped at Devoted. To reach Champion you must commit to a single god.

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Altmer gods, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (real UESP citations, "small"/"milestone") are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT). Separately, the P2 quest-stage faucet (`PDV_FLST_P2_AltmerLorkhanPenalties`, `PDV_FLST_P2_AltmerMagnusSources`) fires the curated Lorkhan/crisis/Magnus routes independently of the reaction matrix - those are the key organic Altmer quest beats and are listed first.

**Key curated quest beats (P2 quest-stage faucet, organic)**

| Quest | Stage | Deed | Route | Status |
|-------|-------|------|-------|--------|
| Dragon Rising (MQ104) | 160 | Slew Mirmulnir / declared Dragonborn - the signature Lorkhan crisis | RouteAltmerLorkhanPenalty(2) + RouteAltmerCrisisSource(1) | WIRED (organic, PlayerEvents:1203-1205) |
| Sovngarde (MQ304) | 200 | Entered Shor's mortal-hero afterlife | RouteAltmerLorkhanPenalty(1) + RouteAltmerCrisisSource(2) | WIRED (PlayerEvents:1207-1209) |
| Proving Honor / Companions (C03) | 200 | Beast-blood fork | RouteAltmerLorkhanPenalty(2) + RouteAltmerCrisisSource(4) | WIRED (PlayerEvents:1211-1213) |
| The Eye of Magnus (MG08) | 200 | Disciplined custody of the Eye | RouteAltmerMagnusScholarship | WIRED (Magnus focus, PlayerEvents:1200-1201) |

**Auri-El (reaction matrix)**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Glory of the Dead (C06) | 200 | Honored the fallen with rites | + / m / small | WIRED (if watched) |
| Alduin's Bane (MQ206) | 220 | Turned back the devourer of elven time | + / m / small | WIRED (if watched) |
| Dragonslayer (MQ305) | 200 | The World-Eater unmade, order upheld | + / m / small | WIRED (if watched) |
| The Way of the Voice (MQ105) | 160 | Disciplined mastery of the Voice | + / S / small | WIRED (if watched) |
| The Horn of Jurgen Windcaller (MQ105U) | 60 | Passed the Greybeards' final trial | + / m / small | WIRED (if watched) |

Plus ~17 echo rows (prove_by_struggle / uphold_law_justice / honor_the_dead / serve_a_daedra:* disapprovals across C01, CW01B, DA01, DA02, DA06, DA07, DA08, DA10, DA11, DA16, DLC1VQSaint, dunHunterQST, FreeformKolskeggrA, MG01, MG07, MQ303) flagged REVIEW -> INERT. NOTE: the many `serve_a_daedra` Auri-El rows are Daedra-service *disapprovals*, but almost all are echo/REVIEW and do not fire; the organic Daedric penalty is the CSV accept-daedric-artifact dislike, not these.

**Magnus (reaction matrix)**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Discerning the Transmundane (DA04) | 100 | Recovered lost arcane knowledge | + / m / small | WIRED (if watched) |
| First Lessons (MG01) | 200 | Entered the College, took up disciplined study | + / C / small | WIRED (if watched) |
| Under Saarthal (MG02) | 200 | Recovered buried knowledge | + / C / small | WIRED (if watched) |
| Hitting the Books (MG03) | 200 | Recovered the stolen Fellglow books | + / C / small | WIRED (if watched) |
| Good Intentions (MG04) | 200 | Heeded the Augur | + / C / small | WIRED (if watched) |
| Revealing the Unseen (mg06) | 200 | Revealed the Staff at the Oculory | + / C / small | WIRED (if watched) |
| The Staff of Magnus (MG07) | 200 | Recovered the Staff | + / C / milestone | WIRED (if watched) |
| The Eye of Magnus (MG08) | 200 | Contained the Eye; named Arch-Mage | + / C / milestone | WIRED (if watched) |

Plus 1 echo row (DA15 sow_chaos_madness) flagged REVIEW -> INERT. The College arc is Magnus's strongest matrix lane; it doubles the P2 faucet's MG08 route.

**Xarxes (reaction matrix)**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Collecting the Edda (BardsCollegePoeticEdda) | 200 | Recovered the Poetic Edda | + / m / echo | INERT (echo/REVIEW) |
| Glory of the Dead (C06) | 200 | Honored the fallen Harbinger | + / C / milestone | WIRED (if watched) |
| The Whispering Door (DA08) | 60 | Kept a secret | + / m / echo | INERT |
| The Taste of Death (DA11) | 100 | Defiled the recorded dead | - / m / small | WIRED (if watched) |
| First Lessons / Under Saarthal / Hitting the Books / Good Intentions / Revealing the Unseen / The Staff of Magnus (MG01-MG07) | 200 | Knowledge recovered into the ledger | + / m / small | WIRED (if watched) |
| The Way of the Voice (MQ105) | 160 | Disciplined study of the Words | + / S / small | WIRED (if watched) |
| Sovngarde (MQ304) | 200 | Recorded the reunited dead | + / C / echo | INERT |
| Impatience of a Saint (DLC1VQSaint) | 200 | Returned a trapped soul's life's work | + / C / echo | INERT |
| The Book of Love (t02) | 200 | Entered two reunited souls into the ledger | + / m / small | WIRED (if watched) |

Plus 1 echo row (DA15 sow_chaos_madness) flagged REVIEW -> INERT.

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON. The P2 quest-stage faucet rows (MQ104/MQ304/C03/MG08) are live only if `PDV_FLST_P2_AltmerLorkhanPenalties` / `PDV_FLST_P2_AltmerMagnusSources` carry the exact stage sources in the deployed ESP.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **What is genuinely organic for Altmer.** Three real organic pillars: (1) reading vanilla sacred books on the curated P2 source lists (Auri-El -> dawn steadiness, Magnus -> disciplined study, Xarxes -> lineage honored), (2) the CSV day-to-day likes/dislikes (reading, skill-ups, enchanting, learn-word, kill-undead, heal, plus the murder/undead/Daedric-artifact dislikes), and (3) the magic-skill milestones at 25/50/75/100 (Magnus). MQ104 s160 is the one big organic quest beat, doubling as Lorkhan penalty + crisis. All of these are proven to a live On*/HandleStory*/CSV-row/quest-stage caller.
- **"Observe the dawn" is a curated-book act, not a time-of-day act.** RouteAltmerDawnSteadiness() (standalone) has only dev-only callers; the dawn-steadiness pulse reaches players organically ONLY through Auri-El book-reads. There is no morning-window / GetCurrentHourOfDay hook. This is the biggest guide-vs-reality gap: the marquee "daily dawn foundation" fires from reading, not from the sun.
- **"Hold coherent under pressure" (orthodox costly enforcement) has no organic non-book caller.** RouteAltmerOrthodoxCostlyEnforcement() is dev-only; HandleAltmerOrthodoxCostlyEnforcement is reached organically only by Xarxes book-reads (awarding Xarxes, not an orthodox-cost foundation). No real Thalmor-side "costly duty" detector exists.
- **Lorkhan pressure is narrow.** Only MQ104 s160, MQ304 s200, C03 s200 (plus Lorkhan-penalty books) fire it organically. The evocative "Talos / Stormcloaks / marriage / homestead / Thu'um" catalogue in the prose is NOT wired to organic triggers - those tiers reach play only via the dev-only signal activator/effect. The four placed signal refs (Devotion.esp:07101F-071022, AltmerLorkhanPressure / DragonbornCrisis / DawnSteadiness / OrthodoxCost) are all status:"dev-only"; their manifest `reason` correctly notes the real organic route is books + MQ104 s160, so those beats are WIRED(book)/QUEST(MQ104), not STUB - but the extra pressure tiers beyond that are STUB.
- **ThalmorAlignment is a coherence track, not piety.** It only bites piety through the Lorkhan faction modifier. Its organic movers are just three (Talos Mistake read, Daedric-artifact equip, unprovoked Thalmor kill), all heterodox/negative. The orthodox movers (arrest Talos worshipper, complete Thalmor mission) have no organic caller - so a player cannot organically climb toward the enforcer pole; they can only slide heterodox. This undercuts the "Orthodox start pushes up through play" framing.
- **Crisis has no scored resolution.** ResolveAltmerCrisis() is defined but never called. "Reassert after a crisis" is not a scored event; the crisis is a flavor state + a discipline-spell fade while dissonant. Your ordinary gains keep working, which is the actual "climb back."
- **Rejected acts are correctly inert.** ordinary travel, generic spellcasting, generic College membership, generic helping, generic anti-Thalmor violence, repeated Dragonborn identity, and the vampire-power route earn nothing and cost nothing - enforced by IsAltmerRejectedLorkhanSurface and the P2 rejectedUse fields. This is correct by design.
- **Quest matrix:** Magnus has the strongest promoted lane (the full College arc, MG01-MG08). Auri-El and Xarxes have a handful of promoted rows (mostly the dragon-war / Voice / honor-the-dead beats); the bulk of both gods' rows are echo/REVIEW -> inert, including nearly all the `serve_a_daedra` disapproval rows.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Your reward comes in two layers. The **Orthodox foundation** is your always-on, broad-coherence reward; it caps at Devoted and goes quiet once you commit to a single patron. Then each focused patron (Auri-El, Magnus, or Xarxes) carries its own three-tier set that climbs all the way to Champion. Reaching Seeker is 25 piety, Devoted is 50, and Champion is 85.

**Orthodox foundation (broad coherence, caps at Devoted):**

| Tier | What you gain |
|------|---------------|
| Seeker | Magicka Regeneration +4% |
| Devoted | Magicka Regeneration +7%, Magic Resistance +5% |

**Auri-El focus (the road back, open to every faction):**

| Tier | What you gain |
|------|---------------|
| Seeker | Magicka Regeneration +5% |
| Devoted | Magicka Regeneration +10%, Magic Resistance +6% |
| Champion | Magicka Regeneration +20%, Magic Resistance +16% |

**Magnus focus (the architect's arts):**

| Tier | What you gain |
|------|---------------|
| Seeker | Alteration +5 |
| Devoted | Alteration +13, Magicka Regeneration +6% |
| Champion | Alteration +25, Magicka Regeneration +15% |

**Xarxes focus (the ageless record):**

| Tier | What you gain |
|------|---------------|
| Seeker | Restoration +5 |
| Devoted | Restoration +13, Magicka Regeneration +6% |
| Champion | Restoration +25, Magicka Regeneration +15% |

At Champion, your standing also reads back in the Devotion panel and Survey text. Auri-El names you as one who kept the Dawn foundation through everything; Magnus names you a true student of the arts; Xarxes writes your name into the long ledger.

## Unique Mechanics

**Lorkhan pressure.** This is what makes Altmer feel like no other race. Certain explicit, meaningful choices carry a theological cost because of what they mean to an Altmer, not because a god is angry with you. The friction does not ask permission; when an authored trigger fires, it fires. The real question it puts to you is: how much of Skyrim are you willing to forgo on Altmer terms? Some players turn down whole questlines for theological reasons. Some complete them and accept the cost. Neither is wrong, but neither is free. Crucially, ordinary existence is never taxed. Walking through Nord towns, having Nord friends, sleeping indoors, doing ordinary quests, and simply being Dragonborn after the first crisis beat all stay silent. There is no hidden debt for living.

**Coherence over volume.** Most races reward you for piling up devotion. Altmer rewards you for holding a shape. Your faction lean, your alignment track, and your patron focus all want to point the same direction. When they do, contextual favor (a brief blessing earned by coherent action) answers back, especially after you weather a crisis. Because broad worship caps you at Devoted and Lorkhan pressure keeps testing you, an Altmer who engaged carelessly with Skyrim's content will plateau at Devoted and struggle to push into Champion. Reaching Champion as an Altmer is the strongest statement in the mod: you navigated recurring pressure, kept your devotion positive, and held faith anyway.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith |
|-------|----------------------------|
| **Vampire** | Auri-El closes completely. To shrink from the sun is to shrink from the god of return, and the records expunge a vampire from the bloodline. Your magic still works, but it loses its religious framing and becomes mere power. There is no cure-and-restore arc for an Altmer vampire, unlike some other races. The active exile state clears ordinary favor and suppresses dawn, orthodoxy, and heritage gains; cure reopens those earns while leaving a scar. |
| **Werewolf** | This is the most theologically annihilating fate in all of Tamriel. The beast-state is the exact inverse of the Apotheosis project: the maximum possible movement away from becoming spirit again. There is no heretical theology to soften it, not even the lowest cap that vampirism gets. Devotion halts entirely. There is no path forward in any direction. `[WIRED: IsAltmerFavorSuppressedByCurse returns True for werewolf as well as vampire (PDV_CurseStateService.IsWerewolf()), so the same favor suppression that closes the vampire's dawn lanes closes the werewolf's, with no exile-heresy message path at all. Werewolf has no dedicated Altmer earn or recovery lane; curing lifts the suppression.]` |

## Quick Reference

- **Gods:** Auri-El (foundation, always on), Magnus, Xarxes. Trinimac as orthodox pressure; Daedra forbidden.
- **Starting choice:** Faction lean - Thalmor Orthodox (hardest), The Divine Body (balanced), or Psijic Tradition (most forgiving) - which sets your Thalmor Alignment coherence track.
- **Top 3 ways to gain:** Observe the dawn daily (Auri-El); study rare and lore tomes (Magnus, Xarxes); reach magic milestones with restraint and hold coherent under pressure.
- **Main ways to lose:** Lorkhan pressure from big mortal-world commitments (Talos, Sovngarde, marriage, homestead, Dragonborn); accepting Daedric artifacts; murder and necromancy; drifting out of coherence on the alignment track; neglect.
- **Rough days to Champion:** About 30 to 45 days of normal play, or near 20 if you focus hard and navigate the Lorkhan pressure carefully. It is the most demanding Champion in the mod.
