# PDV Race Design — Altmer
**Last updated:** 2026-05-19
**Status:** Implementation-lock pass in progress
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.5)
**Note:** Lorkhan Adjacency Penalty economy is implementation-locked at the experience level; exact reward magnitudes can still tune inside the documented ranges.

---

## Religious Identity

Altmer religion is a project: the Apotheosis project. Auri-El, the god of time and the supreme Aldmeri ancestor, escaped Mundus — the mortal plane, the trap. The Altmer want to follow. Every devotional act is a step toward re-achieving the divine nature their ancestors lost when Lorkhan tricked them into creating the mortal world.

The problem — the beautiful, mechanically rich problem — is that Skyrim is Lorkhan's world. Some comfortable, story-significant acts become concessions to Lorkhan's creation: marriage, homesteading, the Companions, the Dragonborn declaration, the Thu'um, and Sovngarde. Ordinary existence, ordinary travel, ordinary friendships, and unremarkable quests are not penalty surfaces.

A devout Altmer in Skyrim is often compromising. The theology knows it. The Lorkhan Adjacency Penalty represents authored moments where the player materially validates or touches the thing Altmer theology says broke them.

**Core design intent:** Altmer should feel judged by coherence, rupture, and orthodoxy more than by raw devotion volume. Reaching Champion means you navigated recurring authored Lorkhan pressure, kept devotional upkeep positive, and held faith anyway — that's the statement.

---

## Worship Structure

```
Step 1: Choose faction alignment at setup
  → Thalmor Orthodox:  ThalmørAlignment starts at 75 (enforcement as faith)
  → The Divine Body:   ThalmørAlignment starts at 50 (moderate cultural practice)
  → Psijic Tradition:  ThalmørAlignment starts at 25 (Old Ways, heterodox)

Step 2: Layer 1 (Auri-El) is always active — foundation of all Altmer faith
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

---

## ThalmørAlignment Track

Same `PDV_ReputationTrack` script as Imperial ConcordatStanding and Breton WitchcraftExposure.

```
ThalmørAlignment: 0–100
  Thalmor Orthodox starts: 75
  The Divine Body starts: 50
  Psijic Tradition starts: 25

Low (0–30) = Heterodox
  Self-cultivation signals x1.5
  Enforcement/martial signals x0.75
  Magnus/Syrabane paths MORE accessible
  Daedra worship risks exposure (breaks oldest Altmer religious law)

Mid (31–69) = Orthodox Moderate
  All normal signal domains at x1.0
  Full pantheon equally accessible

High (70–100) = Thalmor Devout
  Enforcement/martial signals x1.5
  Private self-cultivation signals x0.75
  Trinimac available as primary god at this range
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

This is the defining Altmer mechanic. It fires on specific acts and directly reduces piety with or around the affected god(s). It bypasses ordinary domain scoring — it's not "your god disapproves of this." It's "you touched the thing that broke us."

**Tier 1 — Direct Lorkhan/Shor/Talos Connection (highest penalty):**
- Activating a Talos shrine or carrying Amulet of Talos (Talos = Shezarrine, mortal avatar of Lorkhan)
- Helping Talos worshippers / hiding them from Thalmor
- Entering Sovngarde (Shor's Hall — Lorkhan's afterlife domain)
- Meeting Tsun at the Whalebone Bridge (Shor's shield-thane)
- Wielding Keening / Sunder / Wraithguard (Kagrenac's Tools — forged to tap Lorkhan's Heart)

**Tier 2 — Shor-Adjacent / Nordic Divine Framework (moderate penalty):**
- Learning or using the Thu'um (gifted by Kyne, wife of Shor)
- Being declared Dragonborn (cultural hero of Mankind, validates mortal experiment)
- Joining the Stormcloaks (explicitly a Talos-worship movement)
- Completing the Companions questline (traces to Ysgramor, fought in Shor's name)
- Visiting the Hall of Valor in Sovngarde
- Wielding Wuuthrad (Ysgramor's axe, +damage to elves — theological self-harm)

**Tier 3 — Mortal-Validation Acts (minor penalty):**
- Worshipping at any Nine Divines shrine (framework validates mortal plane)
- Marriage at Mara's Temple (celebrating mortal bonds)
- Adopting children (investing in mortal generational continuity)
- Building a homestead (accepting mortal plane as home, not prison)
- Helping Nords with religious practices
- Reading "Shor son of Shor"

**Tier 4 — Contextual (ThalmørAlignment shift only, no automatic piety penalty):**
- Killing Thalmor unprovoked (-10 ThalmørAlignment)
- Septimus Signus quest (Lorkhan-adjacent motivation, not direct)
- Extensive Dwemer ruin exploration (Heart of Lorkhan contamination — minor flag)
- Joining Dark Brotherhood (Sithis — void from which Lorkhan emerged — indirect)

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
| `PDV_ALT_CRISIS_FAITH` | Replaces normal penalty; minimal temporary sting only | Major main-story theological collisions such as Dragonborn identity, Sovngarde/Shor reality, Talos/Lorkhan/apotheosis contradiction, Thalmor certainty destabilized | One-time per crisis source; resolves through coherent behavior |

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

### Tier 1 — Observant
*Auri-El is acknowledged. Daily practice is sincere.*

- Spell cost -3% all schools (the Aldmeri magical heritage is a devotional expression)
- Dawn acknowledgment generates minor piety (Auri-El's sun, observed correctly)
- Resist magic 5% (the gods protect those who align with spirit over matter)

### Tier 2 — Faithful
*The pantheon relationship is stable. Theological coherence is maintained.*

- At dawn: brief spell cost reduction pulse (until noon — Auri-El's morning blessing)
- After studying or advancing in magical skill: next spell cast of that school is free
- ThalmørAlignment above 70: enforcement acts generate stronger piety
- ThalmørAlignment below 30: self-cultivation acts generate stronger piety, scholarship privileges more accessible
- College of Winterhold advancement (regardless of faction) generates Julianos/Magnus piety
- Lorkhan Adjacency Penalty still fires — but ThalmørAlignment modifier applies correctly

### Tier 3 — Devoted (primary secondary god committed)
*This ancestral power recognizes your devotional coherence. Auri-El watches.*

**Auri-El focus (available to all factions, always Layer 1):**
- *Champion moment:* You've maintained Auri-El's foundation through everything. This Champion represents pure theological commitment to return — the Apotheosis project as a daily practice. Dawn acknowledgment at Tier 3 generates larger piety and a brief magic regen burst. The Lorkhan Adjacency Penalty fires normally — but an Altmer who has reached Champion while absorbing those penalties has made their statement clearly.
- *Specific payoff:* Magic regenerates 25% faster during non-combat periods (contemplation of return). Auri-El shrine interactions give maximum blessing. At dawn specifically: magic cost -15% until midday.

**Magnus focus (Psijic-aligned primary):**
- *Champion moment:* Scholar's Discipline — the Elder Way made real. Magic regenerates 20% faster in non-combat. College of Winterhold gives maximum recognition privilege (special dialogue, access to restricted texts). After reaching a new magic skill milestone (25/50/75/100), next 24 hours: that school costs 10% less.
- *Specific payoff:* Alteration and Illusion cost -10% permanently at Champion. Self-cultivation acts (skill books, magical milestones, Psijic-adjacent content like the Order of the Owl questline) generate strong piety. Psijic Tradition players have the most forgiving Lorkhan penalty (0.75x) — this is the Champion arc that most rewards academic coherence without rigid enforcement.

**Trinimac focus (Thalmor Devout primary — requires ThalmørAlignment 70+):**
- *Champion moment:* Martial virtue made devotional. Trinimac is the god of civilization's defense — the Champion who reaches this tier has fought in Trinimac's name through the enforcement frame. After completing an enforcement or defense-of-civilization act with ThalmørAlignment above 70, armor rating +15 for one in-game day (Trinimac's martial blessing). Thalmor characters treat you with explicit recognition privilege at this tier.
- *Specific payoff:* One-handed damage +5% cumulative (Tier 1 + Tier 3). After defeating enemies threatening elven/civilizational interests, brief health regen. Lorkhan penalty at Thalmor Orthodox x1.5 — this Champion suffers the most from Lorkhan-adjacent content. That tension is intentional.
- *Lore note:* Trinimac is Altmer-native but specialist. Not every Altmer will reach him. He is the god of those who defend the project by force — the most orthodox-aggressive Champion path.

**Xarxes focus (ancestry/scholarship, Psijic or Divine Body primary):**
- *Champion moment:* The records-keeper acknowledges your genealogical fidelity. After completing a quest with significant ancestry, family duty, or genealogical content, 24-hour magic cost reduction. Reading rare tomes (one-time books, particularly lore-heavy volumes) generates strong Xarxes piety. Knowledge of Altmeri heritage acts generate the strongest scoring.
- *Specific payoff:* Lockpicking and Alteration +5% (Xarxes' domain includes secret knowledge and hidden things). Ancestry-adjacent dialogue privilege in relevant NPC encounters.

**Syrabane focus (magical protection, Psijic or Divine Body primary):**
- *Champion moment:* The apprentices' protector watches over you. Magic-using enemies deal 15% less damage at Champion. After casting a protective spell (Ward, Oakflesh-line), next non-protection spell cost -10%. College and magical-institution content generates strong piety.
- *Specific payoff:* Ward spells absorb more (15% bonus to ward strength). Magical institutions treat you with recognition privilege.

---

## Signature Friction

**The Lorkhan Adjacency Penalty is the signature mechanic of Altmer play.** It does not ask permission when an authored trigger fires. Being declared Dragonborn can cost you once. Learning the Thu'um can cost you through curated milestones. Getting married or building a house can cost you because those are explicit mortal-continuity choices. The friction is not that every engagement with Skyrim is taxed; the friction is that certain meaningful engagements have a theological price.

The question the penalty system asks is: **how much of Skyrim are you willing to forgo on Altmer terms?** Some players will turn down questlines for theological reasons. Some will complete them and accept the penalty. Neither approach is wrong — but neither is free.

**ThalmørAlignment** is the secondary friction: maintaining your faction's coherence requires that your acts match your stated theological position. An Orthodox Altmer who consorts with Daedra and helps Talos worshippers doesn't just lose piety — they become theologically incoherent, and the track registers that.

---

## Neglect Texture

Altmer neglect is **inconsistency**, not absence.

- **Orthodoxy drift:** An Orthodox Altmer whose ThalmørAlignment drifts from 75 toward the middle because they keep making heterodox choices doesn't feel penalized — they feel increasingly undefined. The enforcement signals that used to generate strong piety stop landing as hard.
- **Psijic drift:** A Psijic-path player who stops advancing their magical skills, stops reading, stops cultivating themselves — the self-cultivation multiplier that was their advantage fades. They become ordinary.
- **Lorkhan accumulation:** Not technically "neglect," but if authored Lorkhan penalties are firing from main-story beats, marriage, homestead, Talos/Shor/Nordic religious support, or other explicit tags and devotion signals are not keeping pace, the piety balance slides. The penalties are capped pressure, not ambient friendship or existence tax, but they have the same mathematical effect if devotion input does not compensate.

The failure mode the mod should make legible: a devout Altmer who fully engaged with Skyrim's content and didn't navigate the theological cost carefully will plateau at Tier 2 and struggle to push into Tier 3. That's not a bug — it's the design. Skyrim is Lorkhan's world.

---

## Signal Examples

| Action | Direction | Cadence | Notes |
|--------|-----------|---------|-------|
| Advance in any magic skill to next tier (25/50/75/100) | +piety (Magnus, Syrabane, Julianos) | Per milestone | Finite progression |
| Read a skill book or rare lore tome | +piety (Xarxes, Magnus, Julianos) | Per book, one-time | Rich early-game signal pool |
| Arrest or report a Talos worshipper | +ThalmørAlignment +15 | Per event | Thalmor cooperation |
| Help a Thalmor prisoner escape | -ThalmørAlignment -15 | Per event | Defection signal |
| Consort with Daedra (accept a Daedric quest) | -ThalmørAlignment -25 | Per quest | Breaks oldest Altmer religious law |
| Activate Talos shrine | Lorkhan Penalty Tier 1 | Per shrine | Applies at full strength |
| Learn a new Word of Power | Lorkhan Penalty Tier 2 (Thu'um) | Per word | Main quest and Greybeard content |
| Become declared Dragonborn (post Bleak Falls Barrow) | Lorkhan Penalty Tier 2 | One-time | Major penalty event |
| Join Stormcloaks | Lorkhan Penalty Tier 2 | One-time | Large penalty |
| Get married at Mara's Temple | Lorkhan Penalty Tier 3 | One-time | Minor penalty |
| Build a homestead | Lorkhan Penalty Tier 3 | One-time | Minor penalty |
| Dawn observation (shrine interaction or time-window) | +piety (Auri-El Layer 1) | Daily cap | Foundation signal |
| College of Winterhold advancement | +piety (Magnus, Syrabane, Julianos) | Per guild rank | Structured progression |
| Complete Thalmor-sanctioned mission | +ThalmørAlignment +20 | Per mission | Reinforces Orthodox path |

---

## Implementation Notes

**Vanilla hook surface:** Excellent for penalties (clear trigger events). Moderate for positive signals (magic school advancement is well-structured; enforcement acts require Thalmor faction/dialogue flag checking).

**Complexity flags:**
- **Lorkhan Adjacency Penalty system:** The most novel Altmer mechanic. Requires a curated list of trigger events mapped to penalty tiers, with ThalmørAlignment multiplier applied at trigger time. This is primarily content/curation work — the framework event system can handle it, but the trigger list needs careful maintenance.
- **ThalmørAlignment track:** Same architecture as Imperial ConcordatStanding — proven pattern. Key complexity is making sure Thalmor cooperation quests correctly flag their beats (several are Thalmor Embassy content that isn't always faction-flagged).
- **Trinimac gating on ThalmørAlignment:** The offer for Trinimac as primary focus should only fire when ThalmørAlignment is above 70. Offer system needs to check track state before firing, same as Imperial Talos commitment gate.
- **Altmer vampire path:** The lack of a cure-and-restore arc (unlike Dunmer, Imperial, Redguard) needs a clear one-time state flag. Once a player has been an Altmer vampire, there is no recovery arc — the theological position is LOCKED at "no recoverable Altmer position." This needs to be surfaced clearly when vampirism activates.
- **Altmer werewolf:** Complete halt of devotion — not even the Tier 1 heretical cap that vampire gets. The state needs clean detection that doesn't rely on transformation animation (may already be sleeping, could be any time). Use SaxhlMon ActiveEffects or persistent curse flag.

**Cost class profile:**
- Magic skill advancement: Cost Class A (skill level event)
- Lorkhan penalty triggers: Cost Class A (most are quest/story events)
- Dawn/dusk observation: Cost Class B (time-state check)
- ThalmørAlignment updates: Cost Class A (specific action detection)
- Trinimac offer gate: Cost Class B (track-state check in offer evaluation)

---

## Curse State Summary

**Vampire:**
- Auri-El absolutely closed — sun avoidance = shrinking from the god of return
- Genealogical records expunge the vampire from bloodline
- Magic continues but loses religious framing — becomes mere power
- Thalmor would euthanize on sight (extreme social danger — not a PDV effect, but contextual)
- Tiny heretical path available (Tier 1 cap only): "Vampirism is at least a path away from mortal limits" — self-justification theology; Molag Bal accessible; piety accumulates at 25% rate; hard ceiling: Tier 1
- **No restoration path** — unlike Dunmer or Breton, no cure-and-restore arc. The Altmer position is terminal.
- Lore rationale: "There is no recoverable Altmer position for a vampire." The file is clear.

**Werewolf:**
- Most theologically annihilating combination in all of Tamriel (confirmed by multiple sources)
- Beast-state is the precise inverse of the Apotheosis project
- No heretical theology possible — regression into animality has no framework
- Devotion halts entirely — not even Tier 1 heretical cap
- No path forward in any direction
- If player somehow survives (which they will): Bosmer Valenwood beast-shape practices give minimal ideological cover, but this is flavor/lore only, not a mechanical path
- Lore rationale: The Altmer project is "become spirit again." Becoming a beast is the maximum possible movement in the opposite direction. There is simply no framework for it.
