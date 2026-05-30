# Altmer

**Status:** Player-facing companion sheet. Implementation authority lives in `PDV_RaceDesign_Altmer.md`, `PDV_TargetEndStates_1.0.md`, `references/PDV_RaceArchitecture_DesignReference.md`, and `references/phase4/PDV_DaedricRacePrinceMatrix.csv` for Daedric response; Altmer implementation spec closed on 2026-05-30.

> The mortal world is a prison. Every act either reaches toward escape or sinks deeper into the cage Lorkhan built.

## Who They Worship

Altmer religion is the *Apotheosis project* — the collective effort to transcend mortality and return to the divine state their ancestors lost when Lorkhan tricked them into creating the mortal world. Their gods are ancestor-figures who represent stages of this return: Auri-El (the supreme ancestor who showed the way), Magnus (who escaped), Syrabane (who protects the path), Phynaster (who extends the journey), Xarxes (who records the lineage).

This makes Altmer worship fundamentally different from other races. It's not about gratitude, community, or survival. It's about *coherence* — maintaining a theological position that consistently rejects the mortal compromise and reaches toward something higher.

In 4E 201, this project is politically weaponized by the Thalmor. But the theology predates the politics by millennia.

## How Devotion Works for Altmer

**Worship type:** Layered Pantheon — similar structure to Dunmer, but judged by *coherence* rather than cumulative practice.

**Setup choice:** Faction alignment at character creation determines your theological starting point:

| Faction | Starting Orthodoxy | Character |
|---------|-------------------|-----------|
| **Thalmor Orthodox** | High | Enforcement as faith. Heresy-hunting is worship. |
| **The Divine Body** | Moderate | Standard cultural practice. Balanced self-cultivation. |
| **Psijic Tradition** | Low | The Old Ways. Private meditation. Heterodox scholarship. |

**Layered architecture:**
- **Layer 1 (always active):** Auri-El — daily dawn acknowledgment. The supreme ancestor. Foundation of everything.
- **Layer 2 (standard for devout):** Full pantheon acknowledgment — Magnus, Trinimac, Xarxes, Syrabane, Y'ffre, Mara, Stendarr, Phynaster.
- **Layer 3 (optional depth):** Primary secondary god commitment. One deity beyond Auri-El becomes your focused emphasis. Unlocks Devoted.

**Broad worship** reaches **Faithful**. **Devoted** requires primary commitment.

## Unique Mechanics

### Thalmor Alignment Track

Your position on the orthodoxy spectrum. This isn't just political — it shapes how your devotion *works*.

**Heterodox (low alignment)** — Scholarly independence, private doubt, Psijic-leaning. Self-cultivation prioritized. Enforcement feels wrong. Magnus and Syrabane paths more accessible. But Daedric worship risks *exposure* — breaking the oldest Altmer religious law.

**Orthodox Moderate (mid)** — Standard practice. All paths equally accessible. No bonuses, no penalties.

**Thalmor Devout (high)** — Enforcement as worship. Hunting heresy *is* devotion. Combat-facing devotion amplified. Personal cultivation time reduced. Trinimac (martial ancestor-hero) becomes available as primary.

**What moves it:**
- Report Talos worshippers, complete Thalmor missions → alignment rises
- Help prisoners escape, kill Thalmor, read banned texts, consort with Daedra → alignment drops
- Mastering magic is neutral (pure cultivation, not political)

### The Lorkhan Adjacency Penalty

This is the most distinctive mechanic in the mod. Lorkhan — the Corpse-God — is the most unholy power in Altmer theology. He broke the Altmer's connection to divinity by creating the mortal world. Any act that *validates, strengthens, or celebrates* his creation triggers a direct devotion hit that bypasses your normal religious practice.

**Why it's special:** This isn't "your god disapproves." It's "you touched the thing that broke us." It's categorical.

**Tier 1 — Direct Lorkhan/Shor/Talos connection (strongest penalty):**
- Activating a Talos shrine or carrying an Amulet of Talos
- Helping Talos worshippers or hiding them from Thalmor
- Entering Sovngarde (Shor's own afterlife domain)
- Meeting Tsun at the Whalebone Bridge
- Wielding Kagrenac's Tools (forged to tap Lorkhan's Heart)

**Tier 2 — Shor-adjacent / Nordic divine framework (moderate penalty):**
- Learning the Thu'um (gifted by Kyne, wife of Shor)
- Being declared Dragonborn (cultural hero of Mankind, validates the mortal experiment)
- Joining the Stormcloaks (explicitly a Talos-worship movement)
- Completing the Companions questline
- Wielding Wuuthrad (theological self-harm for an elf)

**Tier 3 — Mortal-validation acts (minor penalty):**
- Worshipping at any Nine Divines shrine (validates the mortal plane)
- Marriage at Mara's Temple (celebrating mortal bonds)
- Adopting children, building a homestead (investing in mortal continuity)
- Helping Nords with religious practices

**Faction modifier:** Thalmor Orthodox feels these penalties 50% harder. Psijic Tradition feels them 25% less. The Divine Body takes them at standard weight.

**Design intent:** A player who chooses explicit mortal-continuity or Lorkhan/Shor/Talos-adjacent acts will accumulate minor Tier 3 reactions. This is intentional, but it is lightly weighted and capped. Marriage, homesteads, adoption, Nine Divines infrastructure, and similar authored actions should create evocative dissonance, not devastating devotion collapse. Ordinary travel, ordinary quests, ordinary friendships, and simply being in Mundus are theological context, not automatic penalty triggers.

### Crisis of Faith

Some story moments are too large to be treated as ordinary penalties. Discovering Thalmor hypocrisy, encountering evidence that destabilizes the Talos question, or being forced to confront the meaning of Dragonborn identity can trigger a crisis-of-faith state. This is a temporary condition of doubt, vulnerability, or questioning that resolves through sustained behavior afterward. The point is narrative pressure, not punishment for playing the main quest.

The locked launch crisis beats are Dragonborn identity, Sovngarde or Tsun proof, a real Talos/Thalmor contradiction, and the Companions/Wuuthrad/beast-fork problem. Marriage, adoption, and homesteading remain minor mortal-continuity dissonance by default, not full crises. A crisis resolves by answering with coherent behavior afterward: dawn practice, study, orthodoxy repaired, or a chosen heterodox path held steadily.

## Paths of Devotion

### Auri-El — The Supreme Ancestor (Layer 1, always active)
*The god who showed the way back.*

- **What you do:** Acknowledge the dawn daily. Maintain continuity practice. Study the lineage.
- **What you get:** Foundation blessing — the baseline of Altmer spiritual coherence.
- **The feel:** Morning means something. Every dawn is a reminder of what you're reaching toward.

### Magnus / Syrabane / Psijic Lane
*For those who pursue magical mastery as meditative discipline.*

- **What you do:** Complete College and Psijic quest stages. Practice Alteration and Illusion as contemplative arts (for Psijic-aligned). Study obscure tomes. Master spell schools.
- **What you get:** Blessings tied to magical refinement and scholarly attainment.
- **The feel:** An Altmer who worships through the perfection of the arcane — magic as meditation, not mere utility.

### Trinimac — The Martial Ancestor
*For those who defend the faith through force.*

- **What you do:** Enforce orthodoxy. Complete Thalmor-aligned missions. Defend Altmer civilizational order through martial action.
- **What you get:** Combat-facing blessings tied to righteous enforcement.
- **The feel:** An Altmer whose sword is an instrument of theology.
- **Note:** Available primarily to Thalmor Orthodox alignment.

### Xarxes — The Record-Keeper
*For those drawn to hidden knowledge and private scholarship.*

- **What you do:** Read forbidden texts. Pursue independent scholarship. Engage with heterodox ideas privately.
- **What you get:** Favors tied to knowledge, genealogical insight, and death-record wisdom.
- **The feel:** An Altmer whose faith is in the *record* — who believes truth lives in what's written, not what's enforced.
- **Note:** Lowers Thalmor Alignment. A quiet path of private doubt.

## The Daedric Question

For Altmer, Daedric worship is **apostasy**: breaking the oldest religious law of their people. This is not mere social disapproval; it is a fundamental violation of the Apotheosis project. Study, artifact contact, or tactical use can happen in stories, but worship means accepting a power outside the ancestral return.

| Prince | Altmer treatment | What that means in play |
|---|---|---|
| **Azura** | Taboo | Prophecy and twilight threaten Auri-El's ordered ascent. Difficult absolution only. |
| **Boethiah** | Hostile | The Betrayer of Trinimac. This is load-bearing hostility, not ordinary taboo. |
| **Mephala** | Taboo | Covert corruption and hidden murder violate disciplined order and lineage coherence. |
| **Malacath** | Taboo | The degraded Trinimac narrative makes Malacath a shameful outsider pressure, not an alternate ancestor. |
| **Meridia** | Foreign | Anti-undead utility can be understood, but she is not core orthodoxy and still requires renunciation if worshipped. |
| **Hircine** | Hostile | Beast regression is almost the precise inverse of Apotheosis. Cure is the only clean route. |
| **Molag Bal** | Curse-access | Vampirism is catastrophic apostasy with no clean restoration while cursed. Molag Bal is hostile patron pressure, not a secret Altmer lane. |
| **Nocturnal** | Taboo | Shadow oath is apostasy from order, lineage, and visible self-cultivation. |
| **Hermaeus Mora** | Taboo | Study is not worship, but Mora is still apostasy. Psijic-like scholarship must stay distinct from bargain with Apocrypha. |
| **Mehrunes Dagon** | Taboo | Destructive anti-order cult violates the whole civilizational project. |
| **Sheogorath** | Taboo | Unstable reality-play and madness oppose disciplined self-cultivation. |
| **Namira** | Taboo | Impurity and degradation oppose Altmer order, refinement, and ascent. |
| **Sanguine** | Taboo | Indulgence is not merely messy; it pulls the self away from disciplined return. |
| **Clavicus Vile** | Taboo | Bargaining with power violates orthodoxy even when the contract looks clever. |
| **Peryite** | Taboo | Diseased submission and low-order task logic violate purity and self-cultivation. |
| **Vaermina** | Taboo | Nightmare and memory corruption attack the disciplined self. |

Any Daedric quest acceptance creates a sharp negative orthodoxy signal that outweighs ordinary magical practice. A heterodox Altmer can study dangerous material, but worship turns scholarship into apostasy.

## Curse States

**Vampire:**
Auri-El is absolutely closed — avoiding the sun means shrinking from the god of return. Genealogical records expunge you. Magic continues but loses religious framing — it becomes mere power.

A tiny **Exiled Altmer** micro-path exists: a redirected self-reconstruction arc rather than true restored devotion. The vampire Altmer refuses simple collapse and tries to rebuild meaning in exile from their own theology. This can reach only the lowest recognition band and never becomes a deep worship lane. No institutional support. Molag Bal remains accessible only as a hostile patron pressure.

**No clean restoration path while cursed.** Unlike Dunmer or Breton, there is no accepted Altmer position for a vampire. Cure may allow rebuilding, but the vampire state itself is exile, not a hidden alternate orthodoxy.

**Werewolf:**
The most theologically annihilating combination in all of Tamriel. Beast-state is the *precise inverse* of the Apotheosis project — regression into animality. No heretical theology is even possible. Devotion halts entirely. Not even the tiny vampire cap.

Almost no Altmer werewolves survive their own kin.

## Playing This Race — What to Expect

Playing an Altmer in Devotion feels like being **judged by coherence** rather than by volume. You aren't rewarded for doing lots of religious things — you're rewarded for maintaining a consistent theological position in a world that constantly tempts you away from it.

The Lorkhan Adjacency Penalty means the main questline *itself* challenges your faith. Being Dragonborn is a moderate theological problem. Entering Sovngarde is a major one. Even marrying and building a home generates minor spiritual friction. The entire world is trying to make you accept mortality, and your faith says mortality is a trap.

The richest Altmer playthrough involves choosing how you relate to this tension: Orthodox enforcement, moderate acceptance, or heterodox doubt. Each landing is mechanically distinct and emotionally different. No Altmer playthrough feels like any other race.
