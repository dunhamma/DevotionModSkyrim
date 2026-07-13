# Dunmer - The ancestors who never leave, and the three who reclaimed the faith

## Overview

Dunmer faith is not a single choice but a set of layers you carry at once. Underneath everything are the ancestors. A Dunmer is never truly alone: the honored dead of your family and your people stay with you, and you keep faith with them through quiet rites of ash and memory. This ancestor bond is always present, even in exile, even in Skyrim where there are no Houses and no family tombs to kneel before.

Above the ancestors stand the Reclamations - Azura, Boethiah, and Mephala. These are the Good Daedra of the Dunmer, the three who guided the people after the old Tribunal fell silent. You acknowledge all three as a matter of course, and in time you may come to favor one above the others. That focus does not replace the ancestors; it sits on top of them, a second layer of devotion laid over the first.

You make no starting choice as a Dunmer. The layers are simply how your people believe. What unfolds over a playthrough is which Reclamation, if any, comes to claim you as their own.

Ancestor practice grows deliberately: only the first authentic practice after
each 06:00 dawn advances the cultural layer. A portable ash prayer, a twilight
rite for the Good Daedra, an honorable victory, or an exact ancestor duty can
count. Praying at home remains meaningful, but home presence does not add a
second award and the rite does not automatically belong to Azura. This cultural
standing does not passively decay.

## Your Gods

Your devotion has two faces: the ever-present ancestors, and the three Reclamations above them.

- **The Ancestors** - not a single god but the honored dead of your blood and your people. They ask for remembrance, ash-prayer, and solidarity with other Dunmer in the diaspora. This bond is always active and never fades from neglect.
- **Azura** - Lady of Twilight and Dawn, Queen of the Night Sky, who governs the threshold between states: dusk and dawn, prophecy, painful truth, and transformation. The most beloved and most constant of the Reclamations.
- **Boethiah** - Prince of Plots, patron of struggle, rightful rebellion, and strength proven through trial. Boethiah honors the worthy who rise by their own hand and culls the unworthy.
- **Mephala** - the Webspinner, keeper of secrets, sex, and the unseen threads that bind a community together. Mephala favors the hidden hand, the kept secret, and the network that survives in shadow.

Beyond the Reclamations lie the other Daedric Princes. For a Dunmer these are not normal worship but deviation - a trial, a pact, or a rupture that the ancestors notice and the Reclamations resent. See the Daedric Princes guide.

## Getting Started

There is no startup menu for a Dunmer. The moment you begin, both layers are already live:

- **The ancestor bond is always on.** You do not earn it or choose it. Maintaining it through rites keeps it strong, and - uniquely - it never decays from neglect, because Skyrim offers no proper tombs or House shrines and the game will not punish you for that absence.
- **The Reclamations are acknowledged from the start.** You honor Azura, Boethiah, and Mephala together as broad worship. This broad reverence caps at the Devoted tier.

To reach Champion you must let one Reclamation come forward as your focus. As your deeds lean toward one of the three, that god takes notice and offers to claim you, much as a patron does for other races. Only the Reclamation you focus grants its full set of blessings; the other two recede to broad acknowledgment.

For how tiers, the piety bar, and the panels work in general, see the How Devotion Works primer.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (dawn/dusk window, declared-home cell, patron-active, native-stance)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row or signal exists but does not fire organically (no caller)
     Day-to-day deltas from PDV_DeityLikesDislikes.csv (Azura keys as "azurah"); curated deltas from PDV_Deity_*.psc DELTA_*.
     NOTE: generic day-to-day CSV rows only score a deity NATIVE to your race (ScoreFromTable IsRaceNativeForPlayer);
     for a Dunmer, Azura/Boethiah/Mephala are native, so their generic rows fire. -->

Dunmer devotion is fed from two streams: quiet ancestor upkeep, and pointed acts that please a Reclamation. Variety still matters - repeating the same deed earns less each time, and each god is capped at roughly 4.3 piety a day.

**Keeping the ancestors:**

- **Ash-prayer in exile.** Performing your portable ash-prayer - the diaspora rite a Dunmer carries when there is no tomb to visit - is the core maintenance of the ancestor bond. `[WIRED: equip/use the ancestral urn to route the portable prayer. The first authentic Dunmer practice after each 06:00 dawn claims the shared +4 substrate credit. The act supplies one context-appropriate Reclamation piety consequence; home presence never duplicates it. A dawn/dusk prayer may instead carry Azura's twilight rite.]`
- **Honor the hearth.** Performing your ancestor rite at home or a private shrine brings the dead closer and may arm ancestor-watch texture. Home context never adds a second cultural award or a second deity pulse.
- **Stand with your people.** Exact diaspora-solidarity sources and honorable victories the ancestors can be proud of may claim the cultural day. `[PARTIAL/WIRED: honorable victory requires a direct player kill of an existing enemy (relationship rank <= -2), victim level at least the player's, crime status 0, and a combat session whose opener and duration were never stealthy. Ambiguous or player-provoked fights stay silent. Diaspora solidarity remains limited to curated exact sources rather than generic proximity.]`

**Pleasing a Reclamation** (the real path to Champion - curated, meaningful acts, not generic crime or combat):

- **Azura** favors the threshold and the truth: rites at dawn and dusk, enduring exile, facing painful truths, undergoing transformation or curing a curse, and her own star (Azura's Star quest). `[WIRED (CSV, azurah): heal-or-cure-npc (350) +0.75, learn-word-of-power (343) +0.75, read-lore-book (342) +0.25, discover-location (345) +0.5, enchant-item (331) +0.5, kill-undead (300) +0.5, rest-under-open-sky (313) +0.5, accept-daedric-artifact (368, ActorTypeDaedra) +0.5.] [PARTIAL: dawn/dusk "twilight rite" = Azura SIGNAL_DUNMER_TWILIGHT_RITE +0.25, fired only when you ash-pray inside the 06:00-09:00 or 18:00-21:00 window (TryAwardDunmerTwilightWindowSignal, once per window per day). "Facing painful truths / transformation" as curated acts are not separately hooked.] [QUEST: Azura's Star = The Black Star (DA01) s100 -> +/C/milestone.]`
- **Boethiah** favors the trial: surviving against the odds, overthrowing false or corrupt authority, bettering yourself through hardship, and rightful struggle. She even smiles on culling the unworthy and disdains soft comfort. `[WIRED (CSV): increase-skill (344) +0.5, kill-hostile-humanoid (2) +0.25, kill-hostile-beast (1) +0.25, murder-defenseless (304) +0.75 (the "cull the unworthy" like), learn-word-of-power (343) +0.5, pick-owned-lock (360) +0.25, steal-item (362) +0.25, accept-daedric-artifact (368, ActorTypeDaedra) +1.5.] [INERT: "surviving against the odds / overthrowing corrupt authority" as curated acts have NO organic hook - SIGNAL_RIGHTEOUS_STRUGGLE (2001) fires only from the focus-emergence path (Boethiah books / DA02 quest stage), not from an outnumbered-win or overthrow event.]`
- **Mephala** favors the unseen: protecting a hidden community (the Grey Quarter especially), keeping a dangerous secret, working through a network of thieves, and the quiet taking by stealth. `[WIRED (CSV): pick-owned-lock (360) +0.5, steal-item (362) +0.5, trespass (361) +0.25, read-lore-book (342) +0.25, murder-defenseless (304) +1.0, assault-innocent (364) +1.0 (the unseen blade), accept-daedric-artifact (368, ActorTypeDaedra) +1.5.] [INERT: "protecting a hidden community / keeping a secret / weaving a network" as curated acts have NO organic hook - SIGNAL_SECRET_KEPT (2101) fires only from the focus-emergence path (DA08 quest stage), and SIGNAL_WEB_WOVEN (2102) has no caller at all.]`

Reading a genuinely sacred or ancestral book, and completing the curated quests tied to each Reclamation, are among the strongest deeds. Wandering into a Daedric shrine or committing ordinary crime does not, by itself, count. `[WIRED: reading a curated Reclamation book (OnBookRead -> RouteP2ImmersiveSource against PDV_FLST_P2_Dunmer*Sources: Book4RareInvocationofAzura / Book3ValuableAzuraandtheBox -> Azura; Book4RareBoethiahsGlory / DA02BookBoethiahsProving -> Boethiah) steers your Reclamation focus AND fires that god's strong curated signal (Azura threshold rite +1.5 / Boethiah struggle +3.0 / Mephala secret +3.0). Ordinary crime scores only the generic CSV like-rows above, not the curated signal.]`

## How You Lose Piety

Dunmer loss is rarely loud. It is mostly distance, with a few sharp betrayals.

- **Per-god dislikes.** Each Reclamation has its own creed. Boethiah scorns coddling the weak, soft beds, and domestic ease (they deny the test of struggle). Mephala dislikes the open charge and open mending - both undo the secrecy and corruption she weaves. Exploiting or preying on your fellow Dunmer offends the ancestors above all. `[WIRED (CSV dislikes, native-gated): Boethiah heal-or-cure-npc (350) -0.25, sleep-in-inn (315) -0.25 (fired by OnSleepStop when you slept in an inn), cook-meal (333) -0.25. Mephala kill-hostile-humanoid (2) -0.25 (the open charge), heal-or-cure-npc (350) -0.5 (open mending), rest-under-open-sky (313) -0.25 (the open life keeps nothing hidden). Azura (azurah) murder-defenseless (304) -0.75, raise-undead (365) -1.5, assault-innocent (364) -1.0.] [STUB/INERT: "exploiting or preying on fellow Dunmer" has no dedicated organic hook. Mephala's SIGNAL_SECRET_BETRAYED (clumsy-crime penalty via HandleDunmerClumsyCrime) exists but has NO caller = inert.]`
- **Ancestor distance (neglect).** Ignore the rites and the ancestors do not rage - they grow thin and quiet. Their voice fades. This is a texture, not a punishment: the ancestor layer carries no passive decay, so it will not bleed away while you are off adventuring. `[WIRED (as texture): the ancestor substrate has no passive decay and no idle-neglect debuff. IMPORTANT: PDV_SPEL_Neglect_Dunmer is NOT an idle-distance penalty - IsDunmerAncestorNeglected() returns true ONLY under a curse posture (vampire=2 / werewolf=1). So the "magicka mends slowly" penalty players will feel is the curse consequence below, not a punishment for staying away from the rites.]`
- **Turning to foreign Daedra.** Dealing with a non-Reclamation Prince is a real deviation. The ancestors recoil, and your standing with the Reclamations and the ancestors takes a genuine hit (the worst of the ordinary losses). `[PARTIAL: the deviation price (HandleDunmerDeviationPrice -> RECLAMATION_ABANDONED -6.0 on your active Reclamation, or Azura DESECRATION -2.5) is REAL but narrowly triggered. Organic callers: (1) completing The Black Star's defiance branch (DA01 s110, give the Star to Nelacar) via the PO3 quest-stage hook; (2) reading a curated deviation source on PDV_FLST_P2_DunmerDeviationSources; (3) sleeping at your declared home after a deviation was already banked. There is NO generic "equip any foreign Daedric artifact -> deviation" hook - equipping most Daedric artifacts routes the generic Daedric path and, for Boethiah/Mephala, is even a POSITIVE accept-daedric-artifact CSV like. Do not expect ordinary Prince-dealing to auto-penalize.]`
- **The broad-worship cap.** Acknowledging all three Reclamations equally keeps you at Devoted. That is the natural ceiling of breadth; Champion simply asks you to commit to one. `[WIRED: broad worship caps at Devoted; broad Reclamation reward T2 needs ReclamationFocusCount >= 6.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the three Reclamations, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (real UESP citations, "small"/"milestone") are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT). The matrix keys Azura as `Azura` (the runtime like/dislike table keys the same shared deity as `azurah`). The Reclamation-artifact quests (DA01 Azura's Star, DA02 Boethiah's Calling, DA08 The Whispering Door) also feed the focus-emergence path via the PO3 quest-stage hooks in `PDV_PlayerEvents`.

**Azura** (8 promoted, 6 echo)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Black Star (DA01) | 100 | Cleansed Azura's Star (gave to Aranea/Azura) | + / C / milestone | WIRED (strongest Azura event; also routes Reclamation focus) |
| The Black Star (DA01) | 110 | Defied Azura (gave the Star to Nelacar) | - / S / milestone | WIRED (also routes the deviation price) |
| Glory of the Dead (C06) | 65 | Cured Kodlak of the beast-taint | + / m / small | WIRED |
| The Jagged Crown (CW02A/CW02B) | 72 | Destroyed the Korvanjund undead | + / m / small | WIRED |
| The Break of Dawn (DA09) | 500 | Cleansed Meridia's temple of undeath | + / m / small | WIRED |
| Serana's Cure (DLC1SeranaCureSelfQuest) | 200 | Cured Serana's vampirism | + / S / small | WIRED |
| Impatience of a Saint (DLC1VQSaint) | 200 | Honored the dead | + / m / small | WIRED |

**Boethiah** (17 promoted, 14 echo)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Boethiah's Calling (DA02) | 40 | Sacrifice + champion duel + Ebony Mail | + / C / milestone | WIRED (also routes Reclamation focus) |
| Boethiah's Bidding (DA02KillObj) | 200 | Assassinated the Jarl by guile | + / S / small | WIRED |
| Proving Honor (C01) | 200 | Won my place by a judged trial of valor | + / C / milestone | WIRED |
| Take Up Arms (C00) | 20 | Sparred with Vilkas as a trial of arms | + / S / small | WIRED |
| Joining the Stormcloaks (CW01B) | 1 | Proved worth through a martial trial | + / C / small | WIRED |
| The Way of the Voice (MQ105) | 160 | Proved worth to the Greybeards | + / C / milestone | WIRED |
| The Horn of Jurgen Windcaller (MQ105U) | 60 | Retrieved the Horn through trial | + / C / milestone | WIRED |
| Alduin's Bane (MQ206) | 220 | Broke the world-ending dragon | + / C / milestone | WIRED |
| Diplomatic Immunity (MQ201) | 250 | Infiltration by nerve and reversal | + / S / small | WIRED |
| Dark Brotherhood chain (DB01/DB06/DB07/DB08/DB09/DB10/DB11) | 200/50/70 | Assorted trials and killings | + / S / small | WIRED |

**Mephala** (20 promoted, 10 echo)

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| The Whispering Door (DA08) | 60 | Claimed the Ebony Blade (slay those close) | + / C / milestone | WIRED (also routes Reclamation focus) |
| A Chance Arrangement (TG00) | 200 | Framed Brand-Shei | + / C / milestone | WIRED |
| Dampened Spirits (TG03) | 200 | Deceit against the brewer | + / C / milestone | WIRED |
| Scoundrel's Folly (TG04) | 200 | Deceit / infiltration | + / C / small | WIRED |
| Diplomatic Immunity (MQ201) | 250 | Artful infiltration | + / C / milestone | WIRED |
| Delayed Burial (DB01Misc) | 200 | Deceived the guard about Cicero | + / C / milestone | WIRED |
| Boethiah's Calling (DA02) | 40 | Sacrifice by guile (deceit) | + / m / small | WIRED |
| Boethiah's Bidding (DA02KillObj) | 200 | Assassinated a lawful ruler | + / S / small | WIRED |
| Dark Brotherhood chain (DB01/DB02/DB03/DB05/DB06/DB07/DB08/DB09/DB10/DB11) | 200/30/50/70 | Secret killings and infiltration | + / S-C / small | WIRED |

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **The ancestor layer is genuinely wired.** The ash-prayer urn fires organically through the portable-prayer handler into the shared daily substrate helper. Development activators and the debug MCM are backups, not the organic path. This is the marquee identity and it works.
- **The home rite is not a separate act.** It fires only when you ash-pray inside your declared ancestor-home cell. Home presence can arm the once-per-day near-death ancestor watch until dawn, but it adds no second metric credit or piety pulse.
- **Honorable victory is deliberately strict.** A direct player kill of a previously hostile foe at least the player's level may count only when the kill is non-murderous and not delivered from stealth; ordinary or ambiguous kills stay silent.
- **The Reclamation curated signals are focus-emergence, not gameplay beats.** `SIGNAL_RIGHTEOUS_STRUGGLE` (Boethiah +3.0), `SIGNAL_SECRET_KEPT` (Mephala +3.0), and Azura `SIGNAL_THRESHOLD_RITE` (+1.5) fire from `AwardDunmerReclamationFocusSignal`, whose only organic inputs are curated *book reads* (`PDV_FLST_P2_Dunmer*Sources`) and three DA quest stages (DA01 s100 Azura, DA02 s100 Boethiah, DA08 s60 Mephala). There is no "win a desperate struggle" or "keep a secret" runtime detector; the prose acts (surviving against the odds, overthrowing corrupt authority, protecting a hidden community, weaving a network) are **not** organically hooked.
- **Reclamation piety stays act-specific.** A prayer, twilight rite, altar, book, or exact quest can carry one matching deity consequence. The home layer never invents an additional pulse.
- **Twilight rite is dawn/dusk-gated.** Azura `SIGNAL_DUNMER_TWILIGHT_RITE` (+0.25) fires only when you ash-pray in the 06:00-09:00 or 18:00-21:00 window (once per window/day). `HandleDunmerOutdoorGoodDaedraShrine` is the Solstheim outdoor-altar entry point but reuses the same window gate.
- **The deviation loss is narrow.** `HandleDunmerDeviationPrice` (RECLAMATION_ABANDONED -6.0 / Azura DESECRATION -2.5) fires organically only from the DA01 Black Star defiance stage, the deviation book FormList, and a post-deviation home-sleep. Generic foreign-artifact equipping does not route it - and for Boethiah/Mephala, accepting a Daedric artifact (368) is a positive +1.5 CSV like. The guide should not imply ordinary Prince-dealing auto-penalizes.
- **The neglect spell is a curse consequence, not idle distance.** `IsDunmerAncestorNeglected()` is true only under vampire (posture 2) or werewolf (posture 1). The ancestor layer truly never decays; the "magicka mends slowly" penalty is the curse posture (layer-1 weight 0 under vampire), not a distance penalty.
- **Prime remap targets:** the remaining dead curated Reclamation-gameplay signals (2001/2101/2102 fired only via focus-emergence or not at all), broader organic solidarity, and the inert clumsy-crime (`SIGNAL_SECRET_BETRAYED`) penalty. Honorable victory itself is now wired through the strict two-source provenance gate above.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

There are two reward families running together: the always-on **ancestor layer**, and the **Reclamation** rewards (broad first, then your one focused god).

**The ancestor layer (always active, grows as you keep it):**

| Strength | Bonus |
|------|-------|
| Always on | Magic Resistance +3% |
| Deepened | Magic Resistance +9%; Magicka Regeneration +6% when you rest at home or a shrine |
| Attuned | Magic Resistance +20%; at home or a shrine, Magicka Regeneration +15% and Health Regeneration +5% |

**Broad Reclamation worship (caps at Devoted):**

| Tier | Bonus |
|------|-------|
| Seeker | Magic Resistance +5% |
| Devoted | Magic Resistance +8%, Magicka Regeneration +5% |

**Focused Reclamation patron** (only your chosen god grants these; each Champion tier adds a signature scripted moment on top of the numbers):

- **Azura** - Seeker: Magicka Regen +4%. Devoted: Magicka Regen +10%, Magic Resist +5%. Champion: Magicka Regen +20%, Magic Resist +15%, plus "Azura's Star."
- **Boethiah** - Seeker: One-Handed +5. Devoted: One-Handed +13, Armor +30. Champion: One-Handed +25, Armor +50, plus "Boethiah's Proving."
- **Mephala** - Seeker: Sneak +5. Devoted: Sneak +13, Illusion +10. Champion: Sneak +25, Illusion +25, plus "Mephala's Whisper."

## Unique Mechanics

**Two layers, not one.** The ancestor bond and your Reclamation focus are separate and both matter. The ancestors are your constant floor; the Reclamation you favor is your ceiling. You feed them with different deeds, and they answer in different ways - the ancestors with a steadying ward against magic, your Reclamation with its own gifts of mind, blade, or shadow.

**The ancestors never erode.** Alone among devotion layers, the ancestor bond has no passive decay. A Dunmer far from home, with no tomb to tend, is not punished for the distance. Keep the rites and the bond deepens; let them slide and it simply grows quiet, waiting for you to return.

**The Reclamations reward intent, not grinding.** The acts that please Azura, Boethiah, and Mephala are deliberate and meaningful - facing a hard truth, winning a desperate struggle, protecting your people in secret. They are not a loop you can farm, which is why focusing a Reclamation feels like a genuine commitment rather than a chore.

## If You Are Cursed (Vampire or Werewolf)

**Vampire - the ancestors fall silent.** This is one of the most striking moments in the mod. To the honored dead, undeath is a wound in the cycle, and they will not speak to what you have become. Your ancestor bond goes silent: the rites stop answering, and a quiet penalty settles over you (your magicka mends more slowly) until the silence is broken. Curing the vampirism restores the connection - but the ancestors remember the silence, and a permanent scar remains. With the ancestors muted, Boethiah and Mephala draw closer, and the road to Molag Bal opens, but none of that fills the hollow where your dead used to be. `[WIRED: ApplyDunmerCurseHandlers sets posture 2 (Silent) on vampirism. GetDunmerCurseLayerWeight(1)=0.0, so ash-prayer/home rites score nothing (HandleDunmerPortableShrinePrayer traces "silenced by curse posture"). SyncDunmerNeglectSpell adds PDV_SPEL_Neglect_Dunmer (the magicka-regen penalty) because IsDunmerAncestorNeglected()==true under posture 2. Cure sets posture 3 (RestoredScarred). Layer 2 (Reclamation) keeps its vampire pressure path (weight 1.0).]`

**Werewolf - ritually unclean.** The beast-blood does not silence the ancestors, but it makes you unclean in their sight, and the ancestor layer answers at reduced strength while the curse holds. No new Daedric road opens to comfort you - Hircine has no place in Dunmer faith. It is a strain to be endured and, in time, cured, not a path to walk. `[WIRED: posture 1 (Strained) on lycanthropy. GetDunmerCurseLayerWeight(1)=0.5 (ancestor rites at half), layer 2 =0.75 (Reclamation lightly strained). The neglect spell is also active under posture 1 (IsDunmerAncestorNeglected()==true).]`

## Quick Reference

- **Gods:** the Ancestors (always), plus the three Reclamations - Azura, Boethiah, Mephala. Other Princes are deviation, not worship.
- **Starting choice:** none - both layers run from the start. You later focus one Reclamation (via that god's offer) to reach Champion.
- **Top 3 ways to gain:** ash-prayer and ancestor rites; standing with your people and honorable victories; pointed Reclamation deeds (Azura's truths, Boethiah's trials, Mephala's secrets).
- **Main ways to lose:** preying on fellow Dunmer; turning to a foreign Daedric Prince; ancestor distance (quiet, not punishing); the Devoted cap on broad worship.
- **Rough days to Champion:** about 30 to 45 days of normal play, roughly 20 if you commit hard to one Reclamation; the ancestor layer reaches full strength in a few in-game weeks of upkeep.
