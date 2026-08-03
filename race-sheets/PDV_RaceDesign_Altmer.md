# PDV Race Design -- Altmer
**Last updated:** 2026-06-12
**Status:** Implementation-locked for 1.0; reward magnitudes still tune during build/playtest
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md Section 10.5)
**Note:** Lorkhan Adjacency Penalty economy, crisis handling, contextual-favor lanes, and focused-deity launch hook posture are implementation-locked at the experience level; exact reward magnitudes can still tune inside the documented ranges.

---

## 2026-07-13 Substrate Pacing Addendum

This addendum supersedes later independent +5 heritage routes and automatic
Auri-El ancestry pulses. The first approved ordered rest, daily magic-skill
increase, completed enchantment, Auri-El rite, or curated heritage milestone in
each 06:00 devotional day grants `+4` toward `1/25/75`; later acts grant zero.
Passive dawn never grants the cultural metric. A declined rite grants no metric
and no cooldown; an accepted choice starts the seven-day rite cooldown.

Deity piety remains act-specific for Auri-El, Magnus, and Xarxes. Visible tiers
are `Ordered Heritage`, `Disciplined Heritage`, and `Exemplar Heritage`.
`references/authoring/PDV_SubstratePacingContracts.json` is authoritative.

## Religious Identity

Altmer religion is a project: the Apotheosis project. Auri-El, the god of time and the supreme Aldmeri ancestor, escaped Mundus -- the mortal plane, the trap. The Altmer want to follow. Every devotional act is a step toward re-achieving the divine nature their ancestors lost when Lorkhan tricked them into creating the mortal world.

The problem -- the beautiful, mechanically rich problem -- is that Skyrim is Lorkhan's world. Some comfortable, story-significant acts become concessions to Lorkhan's creation: marriage, homesteading, the Companions, the Dragonborn declaration, the Thu'um, and Sovngarde. Ordinary existence, ordinary travel, ordinary friendships, and unremarkable quests are not penalty surfaces.

A devout Altmer in Skyrim is often compromising. The theology knows it. The Lorkhan Adjacency Penalty represents authored moments where the player materially validates or touches the thing Altmer theology says broke them.

**Core design intent:** Altmer should feel judged by coherence, rupture, and orthodoxy more than by raw devotion volume. Reaching Champion means you navigated recurring authored Lorkhan pressure, kept devotional upkeep positive, and held faith anyway -- that's the statement.

---

## Worship Structure

```
Step 1: Choose faction alignment at setup
  -> Thalmor Orthodox:  ThalmorAlignment starts at 75 (enforcement as faith)
  -> The Divine Body:   ThalmorAlignment starts at 50 (moderate cultural practice)
  -> Psijic Tradition:  ThalmorAlignment starts at 25 (Old Ways, heterodox)

Step 2: Layer 1 (Auri-El) is always active -- foundation of all Altmer faith
  Dawn sun acknowledgment generates piety regardless of faction

Step 3: Aldmeri pantheon breadth (Tier 2 cap)
  ThalmorAlignment shapes which gods score more strongly and which are accessible
  This is not a generic broad-worship lane; coherence is the lane

Step 4: Primary secondary god focus (Layer 3)
  Shared patron-state offer system; sustained piety in that god's domain triggers offer
  Auri-El (Layer 1) remains at full weight always
  Tier 3 unlocked through primary secondary god commitment
```

Altmer uses the shared patron-state model for formal commitment. `ThalmorAlignment` is the orthodoxy/coherence track, not a Broad/Primary commitment state. The player experience is Auri-El foundation plus faction-theological coherence plus secondary focus, not casual whole-pantheon worship.

**V1 focus roster:** Auri-El, Magnus, Trinimac, Xarxes, and Syrabane. Phynaster remains part of the wider Altmeri pantheon presentation, but he is roster/flavor-only for V1: no `PDV_Deity_Phynaster`, no formal offer, and no reward family.

---

## ThalmorAlignment Track

Same `PDV_ReputationTrack` script as Imperial ConcordatStanding and Breton WitchcraftExposure.

```
ThalmorAlignment: -100 to +100
  Starts at 0 for the V1 record bridge; setup-specific starting offsets remain
  a follow-up when setup routes write the track.

OpenHeterodox (-100 to -76)
  Self-cultivation signals strongest; enforcement/martial signals weakest.
  Lorkhan-pressure modifier: x0.75.

PrivateHeterodox (-75 to -51)
  Heterodox lean is present but not public identity.
  Lorkhan-pressure modifier: x0.875.

Uncommitted (-50 to +50)
  The middle band: normal signal domains at x1.0.
  Lorkhan-pressure modifier: x1.0.

PublicOrthodox (+51 to +75)
  Orthodox acts carry more weight; heterodox self-cultivation carries less.
  Lorkhan-pressure modifier: x1.25.

ThalmorEnforcer (+76 to +100)
  Enforcement/martial orthodoxy is strongest; Trinimac access belongs here.
  Lorkhan-pressure modifier: x1.5.
```

| Action | Points |
|--------|--------|
| Arrest/report Talos worshipper | +15 |
| Complete Thalmor Justiciar mission | +20 |
| Help Thalmor prisoner escape | -15 |
| Kill Thalmor agent unprovoked | -20 |
| Read banned religious texts | -5 |
| Master a new school of magic (skill level milestone) | 0 (pure cultivation, neutral) |
| Consort with Daedra | -25 (breaks oldest Altmer religious law) |

---

## Lorkhan Adjacency Penalty System

This is the defining Altmer mechanic. It fires on specific acts and directly reduces piety with or around the affected god(s). It bypasses ordinary domain scoring -- it's not "your god disapproves of this." It's "you touched the thing that broke us."

**Tier 1 -- Direct Lorkhan/Shor/Talos Connection (highest penalty):**
- Activating a Talos shrine or carrying Amulet of Talos (Talos = Shezarrine, mortal avatar of Lorkhan)
- Helping Talos worshippers / hiding them from Thalmor
- Entering Sovngarde (Shor's Hall -- Lorkhan's afterlife domain)
- Meeting Tsun at the Whalebone Bridge (Shor's shield-thane)
- Wielding Keening / Sunder / Wraithguard (Kagrenac's Tools -- forged to tap Lorkhan's Heart)

**Tier 2 -- Shor-Adjacent / Nordic Divine Framework (moderate penalty):**
- Learning or using the Thu'um (gifted by Kyne, wife of Shor)
- Being declared Dragonborn (cultural hero of Mankind, validates mortal experiment)
- Joining the Stormcloaks (explicitly a Talos-worship movement)
- Completing the Companions questline (traces to Ysgramor, fought in Shor's name)
- Visiting the Hall of Valor in Sovngarde
- Wielding Wuuthrad (Ysgramor's axe, +damage to elves -- theological self-harm)

**Tier 3 -- Mortal-Validation Acts (minor penalty):**
- Worshipping at any Nine Divines shrine (framework validates mortal plane)
- Marriage at Mara's Temple (celebrating mortal bonds)
- Adopting children (investing in mortal generational continuity)
- Building a homestead (accepting mortal plane as home, not prison)
- Helping Nords with religious practices
- Reading "Shor son of Shor"

**Tier 4 -- Contextual (ThalmorAlignment shift only, no automatic piety penalty):**
- Killing Thalmor unprovoked (-10 ThalmorAlignment)
- Septimus Signus quest (Lorkhan-adjacent motivation, not direct)
- Extensive Dwemer ruin exploration (Heart of Lorkhan contamination -- minor flag)
- Joining Dark Brotherhood (Sithis -- void from which Lorkhan emerged -- indirect)

**Faction modifier on Lorkhan penalties:**
- Thalmor Orthodox: penalty x1.5 (stricter theology)
- The Divine Body: penalty x1.0 (standard)
- Psijic Tradition: penalty x0.75 (more philosophical about mortal plane)

*Design intent (LOCKED):* Tier 3 acts are explicit mortal-validation actions, capped and lightly weighted. They should create recognisable dissonance when the player marries, adopts, builds a home, uses Nine Divines infrastructure, or knowingly honors Lorkhan/Shor-positive material. They do not fire from simply existing in Mundus, ordinary travel, ordinary quests, ordinary friendships, or ordinary indoor life. Reaching Champion despite this authored pressure is the statement.

Lorkhan penalties are piety pressure plus narrative reaction, not harsh permanent collapse. Tier 1 can hurt, Tier 2 should meaningfully sting, and Tier 3 should mostly create dissonance and small pressure. Major main-story conflicts that most directly challenge Altmer theology should fire `PDV_State_AltmerCrisis` instead of simple punishment: a flavorful crisis-of-faith beat with a minimal temporary sting to reflect emotional dysregulation, then resolution through continued coherent behavior.

**Implementation economy lock (2026-05-19):**

A normal Altmer who performs basic devotional upkeep should trend positive. Lorkhan pressure slows ascent and makes Skyrim theologically expensive; it must not create a hidden debt spiral from simply existing in the world.

**Positive income tags and hooks:**

| Tag | Value posture | Hook candidates | Cadence |
|---|---:|---|---|
| `PDV_ALT_POS_AURIEL_DAWN` | `+2` Auri-El piety | Dawn time-window check, custom Auri-El shrine/rite, future sun acknowledgment activator | Once per in-game day |
| `PDV_ALT_POS_STUDY_TEXT` | `+3` to `+5` relevant piety | Curated rare/skill/lore book list, book-read or activator proxy where implementation-proven | Once per book |
| `PDV_ALT_POS_MAGIC_MILESTONE` | `+6` to `+10` relevant piety | Increase Skill Story Manager event or actor-value threshold polling at `25/50/75/100` | Once per school milestone |
| `PDV_ALT_POS_COLLEGE_PSIJIC` | `+8` to `+12` relevant piety | College, Eye of Magnus, Psijic-adjacent quest stages | Once per authored milestone |
| `PDV_ALT_POS_ALIGNMENT_COHERENT` | `+8` to `+12` relevant piety or signal strength | Thalmor cooperation/enforcement quest stages, orthodox restraint, Psijic self-cultivation, Divine Body balanced conduct | Once per authored milestone; anti-farm on repeatables |

**Lorkhan pressure tags and hooks:**

| Tag | Base effect | Hook candidates | Cadence / cap |
|---|---:|---|---|
| `PDV_ALT_LORKHAN_T1_DIRECT` | `-10` piety before faction modifier | Talos shrine activation, Amulet of Talos equip/carry check, Talos aid quest stage, Sovngarde/Tsun main-quest stage or location, Keening/Sunder/Wraithguard equip/carry check | One-time per major source; repeatable direct worship sources require long cooldown |
| `PDV_ALT_LORKHAN_T2_SHOR_ADJ` | `-5` piety before faction modifier | Dragonborn declaration quest stage, curated Word of Power milestones if hook-proven, Stormcloak join, Companions completion, Hall of Valor location/story stage, Wuuthrad equip/carry check | One-time per source or milestone; no repeat spam |
| `PDV_ALT_LORKHAN_T3_MORTAL_VALIDATION` | Default `-1`; authored stronger Tier 3 `-2`, before faction modifier | Marriage, adoption, homestead build/expansion, Nine Divines shrine activation, explicit Nord religious aid, clearly Lorkhan/Shor-positive text | At most once per in-game day |
| `PDV_ALT_LORKHAN_T4_CONTEXT` | `0` piety; alignment/flag only | Unprovoked Thalmor killing, Septimus/Dwemer/Heart-adjacent curiosity, Dark Brotherhood/Sithis-adjacent commitment | Authored event cadence; normal anti-farm |
| `PDV_ALT_CRISIS_FAITH` | Replaces normal penalty; minimal temporary sting only | Major theological collisions such as Dragonborn identity, Sovngarde/Shor reality, marriage as mortal-world continuity, and the Companions beast-blood fork | One-time per crisis source; resolves through coherent behavior |

### Crisis State And Resolution Closeout

**Status:** LOCKED 2026-05-30 for 1.0 implementation. Crisis beats are not a
second punishment layer. They replace ordinary Lorkhan penalty handling when the
moment is large enough that the character should question the frame itself.

`PDV_State_AltmerCrisis` uses:

| Value | Name | Meaning |
|---:|---|---|
| `0` | `None` | No active crisis. |
| `1` | `Dissonant` | The player has touched a major contradiction and must live coherently afterward. |
| `2` | `Questioning` | The player is moving toward heterodox or Psijic interpretation. |
| `3` | `Reasserting` | The player is repairing orthodoxy through coherent action. |
| `4` | `ScarredResolved` | The crisis is resolved, but the source remains part of the character's history. |

Final 1.0 crisis sources:

| Source | Trigger posture | Initial state | Resolution route | Notes |
|---|---|---|---|---|
| Dragonborn declaration | Main-quest declaration or first unavoidable Dragonborn identity proof | `Dissonant` | Three coherent devotional days, or one major Auri-El/Magnus/Trinimac/Xarxes/Syrabane milestone after the declaration | Fires once. It teaches the player that the main quest is theologically loaded without punishing the rest of the playthrough forever. |
| Sovngarde / Tsun reality | Sovngarde entry, Hall of Valor, or Tsun confrontation where locally provable | `Dissonant` | Auri-El dawn rite plus one focused-deity act after returning to Mundus | Strongest crisis flavor. Do not stack every Sovngarde sub-beat. |
| Marriage / mortal continuity | Taking a spouse as an authored mortal-world continuity beat | `Questioning` | Heterodox acceptance through self-cultivation, or orthodox repair through dawn/lineage practice afterward | This is the current third crisis beat. It is about household, lineage, embodied attachment, and continuity inside Lorkhan's mortal world, not a rejection of Mara or marriage itself. Ordinary friendship, living indoors, and general settlement play stay rejected. |
| Companions / Wuuthrad / beast fork | Companions completion, Wuuthrad equip/carry, or werewolf pressure entering the same theological neighborhood | `Dissonant` unless actual werewolf state halts devotion | Coherent rejection, cure/avoidance, or a later Trinimac/Auri-El repair act | If the player becomes werewolf, the curse-state hard halt supersedes crisis. |

Talos/Thalmor contradiction is not a current crisis row. It can only return as
a later additional row through explicit ratification; generic anti-Thalmor
violence remains rejected.

Resolution rules:

- A crisis never removes the accepted patron by itself.
- While unresolved, Altmer positive piety still works; this avoids hidden debt spirals.
- One active crisis source is presented at a time. Later sources can update the
  last source marker, but do not spam new MessageBoxes on the same day.
- `ScarredResolved` is a memory state. It can affect Survey Devotion wording or
  rare flavor, but it is not a permanent mechanical penalty.
- Crisis resolution can trigger contextual favor only when the player responds
  with coherent action. Pure penalties, failures, and ordinary negative drift do
  not trigger favor.

**Rejected penalty surfaces:**
- Walking through Nord towns
- Having Nord friends, unless an authored quest/action explicitly turns that friendship into Lorkhan/Shor/Talos validation
- Sleeping indoors
- Doing ordinary Skyrim quests
- Existing as Dragonborn after the first authored crisis or declaration beat
- Ambient Dwemer ruin exploration unless a curated Heart/Lorkhan-adjacent event is present

**Obviousness rule:**
If the player would not reasonably understand the theological meaning, do not penalize it silently. Either reject the signal or surface a first-time Altmer-interpretation notification. Example presentation: "You feel the old dissonance: this rite honors the mortal world Lorkhan made."

---

## Tier Rewards

### Tier 1 -- Observant
*Auri-El is acknowledged. Daily practice is sincere.*

- Spell cost -3% all schools (the Aldmeri magical heritage is a devotional expression)
- Dawn acknowledgment generates minor piety (Auri-El's sun, observed correctly)
- Resist magic 5% (the gods protect those who align with spirit over matter)

### Tier 2 -- Faithful
*The pantheon relationship is stable. Theological coherence is maintained.*

- At dawn: brief spell cost reduction pulse (until noon -- Auri-El's morning blessing)
- After studying or advancing in magical skill: next spell cast of that school is free
- ThalmorAlignment above 70: enforcement acts generate stronger piety
- ThalmorAlignment below 30: self-cultivation acts generate stronger piety, scholarship privileges more accessible
- College of Winterhold advancement generates Magnus/Xarxes piety by study or record context; Syrabane only on protection/apprentice beats
- Lorkhan Adjacency Penalty still fires -- but ThalmorAlignment modifier applies correctly

### Tier 3 -- Devoted (primary secondary god committed)
*This ancestral power recognizes your devotional coherence. Auri-El watches.*

> **IMPLEMENTATION STATUS (audited 2026-08-02 -- read before treating anything below as shipped).**
> What ships today is five flat passive Abilities with **zero conditions**, verified by ESP readback:
> `07117D` Auri-El T3 (Fortify Magicka + Resist Magic), `071185` Magnus T3 (Fortify Alteration +
> Fortify Magicka), `071654` Trinimac T3 (Fortify One-Handed + Armor), `07118D` Xarxes T3 (Fortify
> Restoration + Fortify Magicka), `07165C` Syrabane T3 (Fortify Restoration + Resist Magic).
>
> Every **conditional, timed, or triggered** effect described below is `DESIGN INTENT (not
> implemented)` and is tagged inline as such. None of them has a MGEF, SPEL, or script arm --
> `SyncAltmerRewardFamily` has no branch above `TIER_CHAMPION` at all. Do not cite them as status.
> They are the design brief for a future T4 reward packet; see plan packet P10 (post-Champion
> "Long Devotion" layer), which deliberately ships recognition and a decay floor **without** granting
> spells, so this accrual model can be judged before committing to 50+ new records.
>
> The recognition-privilege and dialogue-privilege lines below are likewise unbuilt.

**Auri-El focus (available to all factions, always Layer 1):**
- *Champion moment:* You've maintained Auri-El's foundation through everything. This Champion represents pure theological commitment to return -- the Apotheosis project as a daily practice. The Lorkhan Adjacency Penalty fires normally -- but an Altmer who has reached Champion while absorbing those penalties has made their statement clearly. `DESIGN INTENT (not implemented):` dawn acknowledgment at Tier 3 generating larger piety and a brief magic regen burst -- `AwardAltmerDawnSignal` has no tier-3 branch.
- *Specific payoff:* Magic regenerates 25% faster during non-combat periods (contemplation of return). Auri-El shrine interactions give maximum blessing. `DESIGN INTENT (not implemented):` at dawn specifically, magic cost -15% until midday -- no timed effect record exists.

**Magnus focus (Psijic-aligned primary):**
- *Champion moment:* Scholar's Discipline -- the Elder Way made real. Magic regenerates 20% faster in non-combat. `DESIGN INTENT (not implemented):` College of Winterhold maximum recognition privilege (special dialogue, restricted-text access); and, after reaching a magic skill milestone (25/50/75/100), that school costing 10% less for 24 hours -- `TryAwardAltmerMagicMilestone` awards piety only, once ever per (skill, threshold).
- *Specific payoff:* Alteration costs less at Champion (shipped as Fortify Alteration on `071185`). `DESIGN INTENT (not implemented):` the Illusion half of that -10% -- the shipped record carries Alteration and Magicka only. Self-cultivation acts (skill books, magical milestones, Psijic-adjacent content like the Order of the Owl questline) generate strong piety. Psijic Tradition players have the most forgiving Lorkhan penalty (0.75x) -- this is the Champion arc that most rewards academic coherence without rigid enforcement.

**Trinimac focus (Thalmor Devout primary -- requires ThalmorAlignment 70+):**
- *Champion moment:* Martial virtue made devotional. Trinimac is the god of civilization's defense -- the Champion who reaches this tier has fought in Trinimac's name through the enforcement frame. `DESIGN INTENT (not implemented):` armor rating +15 for one in-game day after an enforcement act above ThalmorAlignment 70, and explicit Thalmor recognition privilege -- no timed effect and no dialogue condition exist. (Plan packet P7 does add a renewable ThalmorAlignment >= 70 signal, but it awards piety, not a timed buff.)
- *Specific payoff:* One-handed damage and armor at Champion (shipped flat on `071654`). `DESIGN INTENT (not implemented):` the "cumulative Tier 1 + Tier 3" stacking and the post-kill health regen -- T1/T2/T3 are exclusive bands, not cumulative, and there is no on-kill regen record. Lorkhan penalty at Thalmor Orthodox x1.5 -- this Champion suffers the most from Lorkhan-adjacent content. That tension is intentional.
- *Lore note:* Trinimac is Altmer-native but specialist. Not every Altmer will reach him. He is the god of those who defend the project by force -- the most orthodox-aggressive Champion path.
- *Offer and gain rule:* Trinimac is a true focused path, not pressure-only. The formal offer requires `ThalmorAlignment >= 70` plus meaningful civilization-defense/enforcement signals. After access, `ThalmorAlignment` continues to weight Trinimac gain and offer readiness, but it remains pressure/access/interpretation and never becomes a third boon track.

**Xarxes focus (ancestry/scholarship, Psijic or Divine Body primary):**
- *Champion moment:* The records-keeper acknowledges your genealogical fidelity. Reading rare tomes generates strong Xarxes piety (shipped: event 342 at 0.75, his highest row). `DESIGN INTENT (not implemented):` a 24-hour magic cost reduction after an ancestry/genealogy quest -- no timed effect record exists. Note also that book reads are permanently one-shot per book form, so "reading rare tomes" is a finite pool, not a renewable practice; plan packets P14-P16 address that.
- *Specific payoff:* Restoration and Magicka at Champion (shipped flat on `07118D`). `DESIGN INTENT (not implemented):` the Lockpicking/Alteration +5% and the ancestry-adjacent dialogue privilege -- the shipped record carries neither, and no such dialogue condition exists.

**Syrabane focus (magical protection, Psijic or Divine Body primary):**
- *Champion moment:* The apprentices' protector watches over you. `DESIGN INTENT (not implemented):` magic-using enemies dealing 15% less damage; and, after casting a protective spell, the next non-protection spell costing 10% less -- the shipped `07165C` carries flat Fortify Restoration + Resist Magic with zero conditions. "College and magical-institution content generates strong piety" is **also unbuilt today**: Syrabane has no likes/dislikes rows at all and all five of his curated signals are unwired, so his only live earn channel is the quest-reaction matrix. Plan packets P1, P8 and P9 close this.
- *Specific payoff:* Restoration and magic resistance at Champion (shipped flat on `07165C`). `DESIGN INTENT (not implemented):` the 15% ward-strength bonus and the magical-institution recognition privilege.
- *Offer and gain rule:* Syrabane is a true Altmer focused path, but the launch lane starts narrow. Formal offer and gain require warding, magical protection, apprentice or College aid, curse/disease warding, or anti-mage survival. Generic magic advancement, generic College membership, every ward cast, and raw magic-resistance stacking stay rejected unless the narrow implementation proves too thin.

## Focused-Deity Launch Hook Posture

**Status:** LOCKED 2026-05-30 for 1.0 implementation. These hooks describe
what should be buildable first; they are not a license to score every similar
action.

| Focus | Strong 1.0 hooks | Medium / authored hooks | Rejected launch hooks | Balance note |
|---|---|---|---|---|
| Auri-El | Dawn rite, Auri-El shrine, crisis resolution after Lorkhan pressure, stable coherence after main-quest contradiction | Sunlit sacred place, Dawnguard/Auriel shrine comparison if locally verified | Generic daytime play, generic undead fighting, passive sun exposure | Auri-El is the foundation. Keep steady value modest so it does not outpay focused secondary gods. |
| Magnus | Magic school milestones, College/Eye of Magnus stages, rare study texts, Psijic-coded quest milestones | Spell learned, skill book, staff/artifact study if curated | Raw spell casts, generic spell cost stacking, every College errand | Reward discipline and study, not button volume. |
| Trinimac | ThalmorAlignment 70+, orthodoxy defense, meaningful enforcement/defense-of-civilization beats, martial victory against a qualifying threat | Armor/one-handed milestone, Thalmor recognition dialogue, civilizational protection quest stages | Generic bandit kills, generic anti-Stormcloak violence, cruelty dressed as order | This is the sharpest Orthodox path; gate hard and keep Marked moments rare. |
| Xarxes | Rare texts, genealogy/family/record quests, hidden truth preserved, lineage or archive recovery | Lock/secret knowledge if tied to record or duty, forbidden text read with consequence | Generic lockpicking, every book read, convenient lying | The record matters because it binds lineage and truth, not because all secrets are sacred. |
| Syrabane | Ward/protection spell milestones, anti-mage survival, apprentice/College aid, magical institution recognition | Disease/curse warding, defensive spell learned, protecting a vulnerable mage | Generic magic resistance farming, every ward cast, random mage kills | Protection is the identity. Favor should feel like warding someone still on the path. |

## Contextual Favor Table

**Status:** Review-cleared and implementation-locked for user-experience shape
(2026-05-30); exact effect values remain tuning work.

**User-experience proof:** Altmer contextual favor should feel like coherence
answering back after pressure. The player is not being rewarded for volume;
they are being recognized for holding a theological shape in a hostile world.

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Shared Auri-El foundation | Dawn steadiness after dissonance | Dawn rite after a Lorkhan pressure day, Auri-El shrine, coherent day following `PDV_State_AltmerCrisis` | Environmental / until noon | Noted | This is the core recovery rhythm. It should calm pressure, not erase history. |
| Shared coherence | Orthodoxy or heterodoxy held consistently | Three-day coherent behavior window, no contradictory major signal, alignment band maintained | Environmental / until next dawn | Quiet / Noted | Works for all three faction alignments; the meaning changes with the band. |
| Thalmor Orthodox | Costly enforcement as faith | ThalmorAlignment 70+, curated enforcement/defense act, heresy protection rejected, Trinimac-compatible martial proof | After-act / rare major | Noted / Marked | Marked only when the act carries real cost, public risk, or major quest weight. |
| Divine Body | Balanced cultivation under compromise | Moderate alignment held, College or civic act completed without either rigid enforcement or collapse into heterodoxy | After-act | Noted | This lane keeps the middle path from feeling like a weaker version of Orthodox or Psijic. |
| Psijic / Heterodox | Self-cultivation after doubt | ThalmorAlignment below 30, rare text, College/Psijic milestone, crisis resolved through study rather than enforcement | After-act / environmental | Noted / Marked | Marked only for major self-possessed resolution after a crisis. |
| Auri-El focus | Return reaffirmed | Dawn rite after `Dissonant`, Auriel shrine, crisis resolution, major sun/return-coded authored beat | Environmental / until noon | Noted / Marked | Auri-El focus gets the cleanest crisis-resolution favor, but not generic day travel. |
| Magnus focus | The arts made into a road | Magic milestone, Eye of Magnus/College stage, curated spell learned, rare arcane text | After-act / until next major cast | Noted | Use one-shot markers by milestone/book/spell family. |
| Trinimac focus | Civilization defended by force | Orthodoxy-gated martial proof, threat to elven/civil order defeated, defense quest stage | Momentary combat / after-act | Quiet / Noted / Marked | No generic kill wrappers. Requires alignment and meaningful threat context. |
| Xarxes focus | Record, lineage, or truth preserved | Ancestry/family/record quest, rare lore book, protected archive/secret that preserves obligation | After-act | Noted | Do not reward generic lockpicking or every hidden thing. |
| Syrabane focus | The vulnerable mage warded | Ward/protection spell milestone, apprentice/College aid, anti-mage survival, curse/disease warding where curated | Momentary / after-act | Quiet / Noted | Favor should feel protective rather than offensive. |

**Favor boundaries (LOCKED):**

- Generic spell casting, generic book reading, every lock, every kill, every
  shrine, and ordinary daylight never trigger favor by themselves.
- Tier 1 / Tier 2 / Tier 3 Lorkhan penalties do not trigger favor just because
  they happened. Favor requires the player's coherent response afterward.
- `ThalmorAlignment` band entry can unlock or weight favor families, but the
  band-crossing notification itself is not a favor.
- Only one PDV contextual favor boost may be active at a time, using the global
  cap from the architecture reference.

---

## Signature Friction

**The Lorkhan Adjacency Penalty is the signature mechanic of Altmer play.** It does not ask permission when an authored trigger fires. Being declared Dragonborn can cost you once. Learning the Thu'um can cost you through curated milestones. Getting married or building a house can cost you because those are explicit mortal-continuity choices. The friction is not that every engagement with Skyrim is taxed; the friction is that certain meaningful engagements have a theological price.

The question the penalty system asks is: **how much of Skyrim are you willing to forgo on Altmer terms?** Some players will turn down questlines for theological reasons. Some will complete them and accept the penalty. Neither approach is wrong -- but neither is free.

**ThalmorAlignment** is the secondary friction: maintaining your faction's coherence requires that your acts match your stated theological position. An Orthodox Altmer who consorts with Daedra and helps Talos worshippers doesn't just lose piety -- they become theologically incoherent, and the track registers that.

---

## Neglect Texture

Altmer neglect is **inconsistency**, not absence.

- **Orthodoxy drift:** An Orthodox Altmer whose ThalmorAlignment drifts from 75 toward the middle because they keep making heterodox choices doesn't feel penalized -- they feel increasingly undefined. The enforcement signals that used to generate strong piety stop landing as hard.
- **Psijic drift:** A Psijic-path player who stops advancing their magical skills, stops reading, stops cultivating themselves -- the self-cultivation multiplier that was their advantage fades. They become ordinary.
- **Lorkhan accumulation:** Not technically "neglect," but if authored Lorkhan penalties are firing from main-story beats, marriage, homestead, Talos/Shor/Nordic religious support, or other explicit tags and devotion signals are not keeping pace, the piety balance slides. The penalties are capped pressure, not ambient friendship or existence tax, but they have the same mathematical effect if devotion input does not compensate.

The failure mode the mod should make legible: a devout Altmer who fully engaged with Skyrim's content and didn't navigate the theological cost carefully will plateau at Tier 2 and struggle to push into Tier 3. That's not a bug -- it's the design. Skyrim is Lorkhan's world.

---

## Signal Examples

| Action | Direction | Cadence | Notes |
|--------|-----------|---------|-------|
| Advance in any magic skill to next tier (25/50/75/100) | +piety (Magnus; Syrabane only for ward/protection milestones) | Per milestone | Finite progression; generic skill gain is not a Syrabane source |
| Read a skill book or rare lore tome | +piety (Xarxes, Magnus; Syrabane only for protection/apprentice texts) | Per book, one-time | Rich early-game signal pool |
| Arrest or report a Talos worshipper | +ThalmorAlignment +15 | Per event | Thalmor cooperation |
| Help a Thalmor prisoner escape | -ThalmorAlignment -15 | Per event | Defection signal |
| Consort with Daedra (accept a Daedric quest) | -ThalmorAlignment -25 | Per quest | Breaks oldest Altmer religious law |
| Activate Talos shrine | Lorkhan Penalty Tier 1 | Per shrine | Applies at full strength |
| Learn a new Word of Power | Lorkhan Penalty Tier 2 (Thu'um) | Per word | Main quest and Greybeard content |
| Become declared Dragonborn (post Bleak Falls Barrow) | Lorkhan Penalty Tier 2 | One-time | Major penalty event |
| Join Stormcloaks | Lorkhan Penalty Tier 2 | One-time | Large penalty |
| Get married at Mara's Temple | Lorkhan Penalty Tier 3 | One-time | Minor penalty |
| Build a homestead | Lorkhan Penalty Tier 3 | One-time | Minor penalty |
| Dawn observation (shrine interaction or time-window) | +piety (Auri-El Layer 1) | Daily cap | Foundation signal |
| College of Winterhold advancement | +piety (Magnus/Xarxes by study or record context; Syrabane only for apprentice/protection beats) | Per guild rank | Structured progression; generic membership is rejected |
| Complete Thalmor-sanctioned mission | +ThalmorAlignment +20 | Per mission | Reinforces Orthodox path |

---

## Implementation Notes

**Vanilla hook surface:** Excellent for penalties (clear trigger events). Moderate for positive signals (magic school advancement is well-structured; enforcement acts require Thalmor faction/dialogue flag checking).

**Complexity flags:**
- **Lorkhan Adjacency Penalty system:** The most novel Altmer mechanic. Requires a curated list of trigger events mapped to penalty tiers, with ThalmorAlignment multiplier applied at trigger time. This is primarily content/curation work -- the framework event system can handle it, but the trigger list needs careful maintenance.
- **ThalmorAlignment track:** Same architecture as Imperial ConcordatStanding -- proven pattern. Key complexity is making sure Thalmor cooperation quests correctly flag their beats (several are Thalmor Embassy content that isn't always faction-flagged).
- **Trinimac gating on ThalmorAlignment:** The offer for Trinimac as primary focus should only fire when ThalmorAlignment is above 70 and a meaningful civilization-defense/enforcement signal exists. Offer and gain readiness continue to be weighted by the current alignment band after access, but ThalmorAlignment is not a reward family.
- **Syrabane protection gate:** The offer for Syrabane should only fire from protection/apprentice proof. If the narrow row set is too thin during implementation, widen deliberately through authored defensive texts or institution-protection beats before allowing generic magic advancement.
- **Altmer vampire path:** The lack of a cure-and-restore arc (unlike Dunmer, Imperial, Redguard) needs a clear one-time state flag. Once a player has been an Altmer vampire, there is no recovery arc -- the theological position is LOCKED at "no recoverable Altmer position." This needs to be surfaced clearly when vampirism activates.
- **Altmer werewolf:** Complete halt of devotion -- not even the Tier 1 heretical cap that vampire gets. The state needs clean detection that doesn't rely on transformation animation (may already be sleeping, could be any time). Use SaxhlMon ActiveEffects or persistent curse flag.

**Cost class profile:**
- Magic skill advancement: Cost Class A (skill level event)
- Lorkhan penalty triggers: Cost Class A (most are quest/story events)
- Dawn/dusk observation: Cost Class B (time-state check)
- ThalmorAlignment updates: Cost Class A (specific action detection)
- Trinimac offer gate: Cost Class B (track-state check in offer evaluation)
- Syrabane offer gate: Cost Class B (curated protection/apprentice source check in offer evaluation)

---

## Variety Tranche -- "The Return Made Daily" (DESIGN-LOCKED 2026-06-12)

Roadmap source: `references/authoring/PDV_RaceVarietyTranche_Roadmap.md`.
Purpose: the inverse of the other tranches -- Altmer is friction-rich and
texture-poor on the positive side. This tranche adds ordinary-session
positive surfaces that are coherence-shaped, never volume-shaped, and never
weaken the locked Lorkhan economy. Magnitudes are tunable; shapes, gates,
caps, and fade rules are locked. Effect families remain blocked behind the
race row in `PDV_RaceEffectReviewLedger.md` before any record authoring.

**Contemplations.** Dawn-window lines keyed to `PDV_State_AltmerCrisis` and
the ThalmorAlignment band. A `Dissonant` Altmer's dawn reads differently
from a coherent one; the resolution day gets one Marked line. Pure texture
on the existing dawn rite and crisis state -- no new piety, no new records
beyond MESG/line content.

**Chamber of Study (place anchor).** Cell-keyed declaration of a study
(home, College quarters, inn room), prompted on the first qualifying read in
an ownable cell; declining re-prompts after 3 in-game days. Reading a
qualifying text (the locked `PDV_ALT_POS_STUDY_TEXT` list) inside the
declared study grants `Ordered Mind` (+5% magicka regen, 10 min). This gives
self-cultivation a *place*, which Altmer currently lack entirely; the piety
side stays owned by the existing positive-income tag.

**Syrabane's Hand (signature, once/day).** A ward that fully absorbs a
hostile spell grants a brief spell-cost pulse ("Syrabane's hand steadies
yours"). Coherence-gated: suppressed while a crisis is unresolved.
Protection-shaped per the locked Syrabane boundary -- warding someone still
on the path, never a damage reward.

**Wayshrines of the Chantry (pilgrimage, hybrid eight stations).** Locked as
the hybrid shape: two base-game stations -- the College of Winterhold's Hall
of the Elements and one authored Auri-El surface -- so the lever is felt in
early play, then the five Forgotten Vale wayshrines (Illumination, Sight,
Learning, Resolution, Radiance) plus the Inner Sanctum as the deep arc.
First arrival each = vision line + small Auri-El pulse; milestone
MessageBox at all eight. The Initiate's Ewer pilgrimage is this mechanic in
vanilla lore. Dawnguard.esm is already a framework master (Ancestor Glade
precedent), so the Vale stations add no new dependency. One-shot forever.

**Disciplines of Return (rite).** At the declared study, 7-day cooldown,
"Not yet" does not spend the cooldown. One-active cultivation discipline:
four choices covering one school of magic at -5% cost or +5% regen
(exact school list locked at effect review); choosing again swaps
(clear-before-add). Fades at dawn while a crisis is unresolved or after an
alignment-band break; returns automatically at dawn on coherent recovery --
the existing crisis system becomes something the player *feels* in their
build, gently, which is the "judged by coherence" core intent.

---

## Curse State Summary

**Vampire:**
- Auri-El absolutely closed -- sun avoidance = shrinking from the god of return
- Genealogical records expunge the vampire from bloodline
- Magic continues but loses religious framing -- becomes mere power
- Thalmor would euthanize on sight (extreme social danger -- not a PDV effect, but contextual)
- Tiny heretical path available (Tier 1 cap only): "Vampirism is at least a path away from mortal limits" -- self-justification theology; Molag Bal accessible; piety accumulates at 25% rate; hard ceiling: Tier 1
- **No restoration path** -- unlike Dunmer or Breton, no cure-and-restore arc. The Altmer position is terminal.
- Lore rationale: "There is no recoverable Altmer position for a vampire." The file is clear.

**Werewolf:**
- Most theologically annihilating combination in all of Tamriel (confirmed by multiple sources)
- Beast-state is the precise inverse of the Apotheosis project
- No heretical theology possible -- regression into animality has no framework
- Devotion halts entirely -- not even Tier 1 heretical cap
- No path forward in any direction
- If player somehow survives (which they will): Bosmer Valenwood beast-shape practices give minimal ideological cover, but this is flavor/lore only, not a mechanical path
- Lore rationale: The Altmer project is "become spirit again." Becoming a beast is the maximum possible movement in the opposite direction. There is simply no framework for it.
