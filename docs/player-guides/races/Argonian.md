# Argonian - The Exile Who Holds the Hist Across the Distance

## Overview

You are Saxhleel, and you do not worship the way other races do. There is no temple, no patron to kneel before, no single god to choose. What you have is the Hist: the great soul-trees of Black Marsh that gave you your soul at birth and are meant to receive it again at death. The Hist is not a god you pray to. It is simply part of what makes you Argonian at all.

The trouble is that you are in Skyrim, hundreds of miles from the marsh. The connection to the Hist is not broken, but it is stretched thin, and it keeps thinning a little more every day you spend among the dry stone of the north. So your faith is not about gathering favor. It is about maintaining a bond against a steady current, and about rebuilding who you are from the inside while you are far from home.

There is no startup choice for an Argonian. Your cultural practice is one quiet foundation, while Hist, People, and Void are three separate relationships. Hist remains part of who you are. People and Void can each become the stronger active emphasis, but never both at once. Hist practice can honor the Hist; community life changes your People relationship without inventing a god; Void practice can honor Sithis only after that relationship has awakened.

Only the first authentic cultural act after each 06:00 dawn advances the shared
foundation. Sustained natural-water practice, Hist Sap from an exact source,
returning to your chosen bed, cooking a meal, helping your community, or an
awakened Void rite can count. Brief generic swimming and repeated Sap use do
not. There is no separate second Hist blessing family; your cultural foundation
can sit beside only one People-or-Void emphasis.

## Your Gods

Argonians do not have a roster of gods so much as a set of connections. There are really three:

- **The Hist** - Not a deity you serve, but the soul-tree bond that defines you. It is always primary. In Skyrim it is distant, and keeping it close is the heart of your devotion.
- **Your People** - The living Argonian community in exile: the Assemblage in Windhelm, the dockworkers in Riften, and any named Saxhleel you stand beside. When the Hist cannot reach you, your people hold you together.
- **Sithis and the Void** - The primordial void of change, death, and unmaking. Every Argonian carries a quiet awareness of it. It only becomes a real, active force in your devotion if you embrace it through deep Dark Brotherhood involvement and honest death-facing choices.

Foreign gods and the Daedric Princes are not part of the Argonian path. The mod treats you as Saxhleel first. You honor the Hist, your people, and the Void, and those three are what your standing is built from. (For how devotion works across all races, see the How Devotion Works primer.)

## Getting Started

You make no choice at the start. There is no menu asking you to pick a patron.
Your cultural practice and three relation ledgers begin together, but they are
not one composite and they do not produce three simultaneous reward families.

What you should do early is set your **bed of choice**. Three qualifying sleeps in the same cell declare that one community anchor; the twelfth qualifying sleep establishes Rooted Rest. A return or sleep at the declared bed can claim the first cultural-practice credit of a new devotional day and changes the People relationship only. Repeated sleep on the same day cannot add more cultural standing.

Beyond the bed, the early game is about getting into the habit of maintenance: seek out water, rest near it, and look for the small exile communities. The Hist starts distant by design. You begin inside absence, not abundance, and your progress is about closing that distance one act at a time.

## How You Gain Piety

<!-- Review tags (strip before player release, along with the REVIEW SCAFFOLDING block below):
     [WIRED]  = fires organically in normal play now (hook named)
     [QUEST]  = fires only from a specific vanilla quest stage (via the quest-reaction matrix)
     [PARTIAL]= organic but narrowly gated (layer state, cadence, condition, property-based call)
     [STUB]   = only reachable via a dev-only signal activator or the debug MCM; not organic
     [INERT]  = a CSV/matrix row exists but does not fire organically
     CulturalPractice is separate from Hist/People/Void. Deity piety is act-specific.
     Day-to-day deltas from PDV_DeityLikesDislikes.csv; curated deltas from PDV_Deity_*.psc DELTA_*. -->

Your devotional acts feed whichever layer they belong to. The most common and important ways to earn:

- **Rest and reflect near water.** Sustained natural-water swimming, wading, rest, or an exact sacred-water reflection can maintain the Hist and claim the cultural day. A brief generic swimming check does not.
- **Spend time in swamps and wetlands.** Meaningful interaction with natural water is the Black Marsh proxy; merely crossing a polling state is not.
- **Return to your bed of choice.** A qualifying return feeds People relation and may claim the day's cultural credit. It never invents Hist piety.
- **Help your people.** Aiding a named Argonian, supporting the Windhelm Assemblage, or helping at the Riften Docks builds your People layer. Windhelm Assemblage acts carry extra weight because that is the primary Argonian community in Skyrim. Protecting a Saxhleel from violence counts too. `[PARTIAL: HandleArgonianPeopleSupport fires organically from (a) reading/using an immersive P2 community source on PDV_FLST_P2_ArgonianCommunitySources, and (b) the Derkeethus rescue quest stage (Extraction/DisrRelief, formid 486218 s200). It is NOT a generic "help any Argonian / help the Assemblage" hook - only the curated P2 community forms and that one quest stage feed it. "Protecting a Saxhleel from violence" has no organic combat hook. Near-water maintenance also nudges People when People is your active focus.]`
- **Live the Hist's quiet values.** The Hist responds to small acts of rootedness and care: resting under the open sky, cooking and sharing a meal, brewing potions, harvesting living ingredients, and tending or curing the hurt. These honor the sap that gives the People life. `[WIRED: shared CSV rows keyed "The Hist" (blank originGate, so they score whenever the Hist is a scored deity): rest-under-open-sky (313) +0.5, sleep-in-bed (314) +0.25, heal-or-cure-npc (350) +0.75, cook-meal (333) +0.25, brew-potion (332) +0.5, harvest-ingredient (334) +0.5. Plus one Argonian-gated row tend-the-hist (334, originGate "Argonian") +0.25 - note eventId 334 is dual-mapped, so a harvest scores both the +0.5 and the +0.25 for an Argonian.]`
- **Face the Void honestly (Sithis path).** Joining the Dark Brotherhood, completing its contracts, and choosing death-acknowledging moments raise your awareness of Sithis. This layer stays dormant until you have given it several strong signals - one join is not enough. `[PARTIAL + QUEST: the Void RISES organically two ways. (1) Dark Brotherhood quest stages feed it: DB01 s200 and DB11 s200 route RouteArgonianSithisAcknowledgment -> HandleArgonianVoidSignal (RecordVoidSignalScaled +2.0 substrate); the broader DB contract chain (DB03/DB05-DB10) scores the Sithis deity itself via the quest matrix (see review block). (2) Immersive Sithis P2 source reads on PDV_FLST_P2_ArgonianSithisSources also route it. The substrate gates real Sithis credit behind IsVoidFullyActive() (>=3 separate Void signals), so a single DB act does nothing until the threshold is met. Sithis CSV like-rows (murder-defenseless +1.0, assault-innocent +0.5, kill-dragon +1.0, pick-owned-lock +0.5, trespass +0.25) are WIRED for anyone worshipping Sithis but only matter once the Void is active.]`

Two reminders that apply to every Argonian act. First, repeating the exact same deed earns less each time, so variety matters far more than grinding. Second, daily gain toward any one connection is capped (around 4.3 per day), so you cannot rush it in a single session.

One quiet extra: drinking or equipping Sleeping Tree Sap brushes the Hist once, ever. `[WIRED: OnObjectEquipped on dunSleepingTreeCampSap (0x000AED90) -> RouteArgonianSapVision -> HandleArgonianSapVision, a one-shot +1.0 Hist relation. The Hist-Sap token/potion items (PDV_ALCH_ArgonianHistSap) also route HistMaintenance when used.]`

## How You Lose Piety

- **Acts the Hist dislikes.** The Hist recoils from anything that severs a soul from its root: murdering the defenseless, assaulting the harmless, raising the undead (denying a soul its return to the Hist), and binding souls into enchanted items all cost you. These are the deeds most at odds with being Saxhleel. `[WIRED: shared CSV dislikes keyed "The Hist" (blank originGate): murder-defenseless (304) -1.0, assault-innocent (364) -0.5, raise-undead (365, ActorTypeUndead) -0.75, enchant-item (331) -0.25.]`
- **Hist distance (natural drift).** This is the signature Argonian pressure. The Hist is always slightly harder to reach in Skyrim than in Black Marsh. If you go three in-game days with no valid Hist-maintenance act, the connection begins to thin at dawn, losing a little each day. It will not crash to nothing - there is a floor it will not drop below while you are uncursed - but you will feel it weaken if you ignore water and rest for too long. `[WIRED: ProcessHistDistanceDawn (called each dawn via RunDawnRefreshArgonianHist) - grace HistDawnGraceDays = 3, then HistDawnDecay = -1.0/day on the Hist relation, floored at HistNonCurseFloor = 20.0 while uncursed (floor drops to MetricMin while cursed). A maintenance act resets LastMaintenanceDay.]`
- **Neglect (a layer growing quiet).** Ignoring water and Hist practice lets the relation become Distant and can trigger the one-time abandonment response, but ordinary distance is texture rather than a repeating stat punishment. The `The Hist Silenced` Health penalty is reserved for a curse-driven Silenced or Corrupted posture after grace. People and Void remain independent relation ledgers. `[WIRED: ordinary distance and the Silenced/Corrupted debuff are deliberately separate mechanics.]`
- **The family cap.** Cultural practice is the quiet foundation. Exactly People or Void may be the active emphasis; a second Hist reward family cannot stack beside them.
- **Letting the Hist slip while chasing the Void.** Leaning hard into Sithis while you neglect Hist maintenance is treated as a real fault - the marsh feels further away, and your standing with the Hist drops. The Void is meant to steady you, never to replace the Hist. `[WIRED: in HandleArgonianVoidSignal, if IsVoidFullyActive() AND the Hist relation has lapsed to <= HistNonCurseFloor (20.0), EmitHistVoidOverreachMinus fires (Hist SIGNAL_VOID_OVERREACH -6.0). Only lands when the Void is fully active and the Hist is already at/under its floor.]`

<!-- REVIEW SCAFFOLDING - strip before player release -->

### Quests That Move Your Standing

Quest-reaction rows for the Argonian connections, pulled from `PDV_QuestReactionMatrix_Full.csv` and consumed at runtime by `ApplyQuestReaction` -> `ApplyDeityReaction` in `PDV__ManagerQuest.psc`. Hand-authored rows (with real UESP citations) are promoted and fire when the quest is on the watch list; "echo" rows carry the citation "cross-gen candidate ... REVIEW before promotion" and are **not** promoted (INERT). Note: **your People layer has no deity actor** - it lives entirely on `PDV_Substrate_ArgonianHist` (People relation), so no quest-matrix rows are keyed to it. The only Argonian community quest hook is the Derkeethus rescue stage, wired directly in `PDV_PlayerEvents` (not the matrix). Two Dark Brotherhood stages (DB01 s200, DB11 s200) are also wired directly in `PDV_PlayerEvents` to route the substrate Void signal, in addition to scoring the Sithis deity through the matrix below.

**The Hist**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| (none promoted) | - | - | - | - |

Both Hist rows are echo -> INERT: The Blessings of Nature (T03) s200 "Restored the Gildergreen" (honor_the_wild, +/m) and T03 s100 "Tapped the Eldergleam with Nettlebane" (defile_nature, -/m). Both flagged "REVIEW before promotion." The Hist earns from quests only through its shared CSV like/dislike rows (above), not the matrix.

**Sithis**

| Quest | Stage | Deed | Valence/Intensity/Mag | Status |
|-------|-------|------|-----------------------|--------|
| Innocence Lost (DB01) | 200 | Killed Grelod the Kind in cold blood | + / S / small | WIRED (also routes substrate Void signal) |
| With Friends Like These... (DB02) | 200 | Initiation kill to enter the Sanctuary | + / S / small | WIRED |
| Mourning Never Comes (DB03) | 200 | Completed the first paid contract (Alain Dufont) | + / C / milestone | WIRED |
| Bound Until Death (DB05) | 200 | Assassinated Vittoria Vici at her wedding | + / C / milestone | WIRED |
| Breaching Security (DB06) | 200 | Killed and framed Gaius Maro | + / C / milestone | WIRED |
| The Cure for Madness (DB07) | 200 | Hunted and killed Cicero | + / C / milestone | WIRED |
| Recipe for Disaster (DB08) | 200 | Assassinated the Gourmet | + / C / milestone | WIRED |
| To Kill an Empire (DB09) | 50 | Killed the decoy Emperor | + / C / small | WIRED |
| Death Incarnate (DB10) | 70 | Killed the betrayer Astrid | + / S / small | WIRED |
| Hail Sithis! (DB11) | 200 | Assassinated Emperor Titus Mede II | + / C / milestone | WIRED (also routes substrate Void signal) |

Plus 1 echo row (DB04a The Silence Has Been Broken, assassination_contract) flagged REVIEW -> INERT. Note: these matrix rows score the **Sithis deity**; the substrate `IsVoidFullyActive()` gate (>=3 separate Void signals) still governs whether that Sithis credit and the Void reward tier actually surface for you.

Caveat: all day-to-day CSV rows in the gain/loss sections above are live only if the generated `LoadRowsForDeity` table has been regenerated and `LIKES_DISLIKES_VERSION` bumped; the matrix rows are live only if the quest is present in `questWatchFormIdsCsv` in the compiled JSON.

### Review Notes

Discrepancies between what the guide/design promises and what actually fires (for owner triage):

- **Water practice is duration-gated.** Sustained exterior swimming can maintain the Hist and claim the shared cultural day; a brief generic swim is rejected. Exact sacred-water reflection sources provide the authored shore-side alternative.
- **Wetland scenery alone is not a signal.** Entering a swamp cell does nothing until the player completes sustained water practice or an exact reflection source.
- **Bed-of-choice is genuinely wired** through `OnSleepStop` (declare after 3 same-cell sleeps, then return-credit + Rooted Rest at 12 sleeps). This is the most solidly organic People/Hist act.
- **The People layer is the thinnest.** It has no deity actor and no generic "help an Argonian / aid the Assemblage / protect a Saxhleel" hook. Organic People credit comes only from: (a) curated P2 community source reads (`PDV_FLST_P2_ArgonianCommunitySources`), (b) the single Derkeethus rescue quest stage (486218 s200), and (c) a spillover nudge from near-water maintenance when People is already your active focus. The Windhelm Assemblage and Riften Docks, named in the copy as core, have no dedicated hook. Prime remap target.
- **The Void is better wired than the design's "deep DB involvement" language implies a stub.** DB01 s200 and DB11 s200 route the substrate Void signal directly; the full DB contract chain (DB03/DB05-DB10) scores the Sithis deity through the matrix; and P2 Sithis source reads also feed it. The `IsVoidFullyActive()` threshold (3+ separate Void signals) is real and correctly makes a single DB act inert until the layer wakes.
- **The Hist Silenced vs. ordinary distance.** Ordinary Hist distance decays the relation and can fire a one-time abandonment response. The `The Hist Silenced` spell applies only on posture SILENCED (vampire) or CORRUPTED (Molag Bal domination), so its name now states the actual mechanical gate.
- **The dev-only signal activators** (Devotion.esp:071023 HistMaintenance, 071024 PeopleSupport, 071025 Void, 071026 BedOfChoice) exist but the manifest `reason` fields confirm the intended organic routes are the Hist book/sap/near-water/bed-of-choice states above - i.e. these lanes are NOT pure stubs like the Bosmer/Khajiit signature acts; they have real (if narrow) organic callers. The debug MCM can also drive all four plus `HandleArgonianPeopleSupport("mcm")`.

<!-- END REVIEW SCAFFOLDING -->

## Bonuses by Tier

Note: these are current beta values and may be tuned before release.

Your cultural-practice foundation is separate from every relation ledger. It is absent at 0, begins as **Root Memory** at 1, deepens into **River-Kept Practice** at 25, and becomes **Rooted Adaptation** at 75. Only the first authentic act after each 06:00 dawn adds 4, so continuous practice reaches the middle tier on day 7 and the high tier on day 19.

**Always-on Hist identity (deepens as your bond grows):**

| Bond strength | What you gain |
|---|---|
| Early bond | Resist magic +5% |
| Mid bond | Resist magic +5%, plus health regenerates +6% faster near water, plus resist poison +10% |
| Deep bond | Resist magic +5%, health regenerates +15% faster near water, resist poison +22%, and your claws carry the marsh's strength (+12 unarmed damage) |

There is no separate Hist Communion reward family. Its old records are retained only for save compatibility and are never granted. Hist remains an independent relation/posture ledger; People or awakened Void may supply the one active relation emphasis beside the cultural foundation.

**People focus (your community is your armor) - this is the path to Champion:**

- **Seeker (Kin):** Carry weight +25.
- **Devoted (Family):** Carry weight +25, resist poison +8%, health regenerates +5% faster.
- **Champion (Pillar):** Carry weight +50, resist poison +8%, health regenerates +13% faster, resist magic +5%. You are a pillar of the people you gathered, and the exile network recognizes you as someone who kept the community alive.

**Sithis / Void focus (high-threshold extra, unlocks only after you have given the Void several strong signals):**

- **Seeker (Faced):** Sneak +4.
- **Devoted (Marked):** Sneak +10, resist poison +5%, unarmed damage +10.
- **Champion (Void-Held):** Stamina returns +10% faster, and near death (below one-fifth health) the Void lends a brief surge of +50% stamina regeneration for 10 seconds, once per day. Sithis holds those who faced the Void unflinching.

The Void rewards are deliberately kept weaker than the People focus. The Void is there to steady you in exile, not to become your best path. The shared Seeker tier across these focuses is summarized in the lists above; you do not stack two focuses - you run the one you commit to.

## Unique Mechanics

**Hist distance.** This is the one thing that makes an Argonian feel different from every other race. Your connection is not something you build up and bank; it is something you maintain against a slow, constant fade. Skip water and rest for too long and the Hist thins. Stay near water, rest, and reflect, and you hold it. It is maintenance against a current, not a checklist - gentle, but always present. Other races accumulate; you sustain.

**Three layers, no single right answer.** A water-bound, solitary Argonian who rarely sees other Saxhleel is a completely different character from a Windhelm-Assemblage Argonian who never seeks the marsh's echo, and both are valid. Your standing is the story of which part of yourself you chose to keep alive in exile. Your people can buffer a thinning Hist bond, and the Void can steady you when both feel far - but nothing fully replaces the Hist.

## If You Are Cursed (Vampire or Werewolf)

| Curse | What happens to your faith | A way back? |
|---|---|---|
| **Vampirism** | This is the deepest grief in the mod for an Argonian. All three layers are compromised at once. The Hist falls silent toward your undead self - the soul is no longer going where it is meant to go - and your community belonging becomes dangerous or impossible. The Void grows more available, but Sithis does not celebrate what you have become; it only acknowledges it. You are, in a real sense, spiritually homeless. | Curing the vampirism is the only path that lifts the silence. Until then the Hist cannot reach you, and its absence is felt mechanically as well as in the world's tone. `[WIRED: curseState 2 forces Hist posture SILENCED (RefreshHistPosture), which drops the dawn-decay floor to MetricMin (the relation can now bleed all the way down) and makes IsArgonianHistNeglected() true past grace, applying PDV_SPEL_Neglect_ArgonianHist. Molag Bal domination pressure on top escalates SILENCED to CORRUPTED (-8.0 corruption minus).]` |
| **Lycanthropy** | Serious strain, but not annihilation. The werewolf shape stresses your Hist bond and makes it harder to maintain, but the Hist is used to Argonians changing, so the beast-shape does not cut you off the way undeath does. Your community can still recognize you, even if the change is uncomfortable. | Far more recoverable than vampirism. Keep up your Hist maintenance and community ties and your identity holds. Curing the lycanthropy clears the strain entirely. `[WIRED: curseState 1 sets Hist posture STRAINED (a flavor/posture state, not the SILENCED debuff gate) - the werewolf does NOT trip IsArgonianHistNeglected() or the neglect spell, matching the copy's "strain, not annihilation."]` |

## Quick Reference

- **Gods:** The Hist (your soul-tree bond, always primary), your People (Windhelm and Riften exile communities), and Sithis / the Void (rises only through deep Dark Brotherhood involvement).
- **Starting choice:** None. Cultural practice begins with separate Hist, People, and Void relation ledgers. Set a bed of choice early if People is central to your character.
- **Top 3 ways to gain:** Rest and reflect near water (Hist), help your people / support the Windhelm Assemblage (People), return to your bed of choice on its cadence (People). Honest Dark Brotherhood and death-facing acts feed the Void.
- **Main ways to lose:** Hist distance from neglecting water and rest (3-day grace, then a slow dawn fade to a floor), acts that sever soul from root (murder, raising undead, soul-trapping), isolation from your people, leaning into the Void while the Hist slips, and the broad-worship cap.
- **Rough days to Champion:** About 30 to 45 days of normal play (one or two devotional acts a day), or roughly 20 days if you commit hard to a single layer. Broad, balanced play caps you at Devoted; Champion requires committing to one connection.
