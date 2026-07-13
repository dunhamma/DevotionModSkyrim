# PDV Race Design — Argonian (Saxhleel)
**Last updated:** 2026-05-19
**Implementation status:** LOCKED (single layered substrate, bed of choice, Hist distance, Sithis activation, and curse posture)
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §4.3, §10.10)

---

## 2026-07-13 Substrate Consolidation Addendum

This addendum supersedes later weighted-composite and three-layer-boon text.
Argonian cultural practice is one dedicated substrate metric with tiers `Root
Memory`, `River-Kept Practice`, and `Rooted Adaptation`. The first approved
Hist, water, bed, meal, People, or activated Void practice in each 06:00
devotional day grants `+4` toward `1/25/75`; later acts grant zero.

Hist, People, and Void remain independent relation ledgers. Exactly People or
Void may be the active emphasis. Hist/water/Sap acts may award Hist piety;
People/bed/community acts move relation only; Void acts may award Sithis only
after activation. The separate Hist Communion boon family is retired, so the
normal maximum is the cultural substrate plus one emphasis family. The cultural
metric has three idle days of grace, then loses 1 per dawn to floor 20, or zero
while cursed. `references/authoring/PDV_SubstratePacingContracts.json` is the
authority.

## Religious Identity

Argonians don't have religion the way other races do. They have the Hist — and the Hist is not a god in any sense the rest of Tamriel would recognize. It gave Argonians their souls at birth. It will receive those souls at death. It is constitutive of what an Argonian *is*, not something they practice or choose. Sithis is the primordial void that preceded and surrounds everything — acknowledged as real, not worshipped as personal.

An Argonian in Skyrim has had the Hist cut off. Not denied — the connection doesn't break cleanly — but stretched to near-nothing across hundreds of miles. What remains is memory, maintenance, and the exile community. Playing a Saxhleel in Skyrim is playing someone who is slowly reconstructing identity from the inside out, in a province that doesn't understand what they've lost.

**Core design intent:** Argonian should feel like exile, distance, and reconstruction of self, with the Hist still mattering even when hard to reach. The player begins inside absence, not abundance. Progression is about maintaining connection against the current, not accumulating favor.

---

## Worship Structure

```
No normal deity-choice architecture
No formal setup choice — all Argonians begin inside the same layered exile system

Three layers in descending primacy:
  Layer 1 — Hist relation:              always-primary; slowly decaying in Skyrim
  Layer 2 — Collective/community:       second layer; can buffer low Hist relation
  Layer 3 — Sithis acknowledgment:      third layer; rises only under strong repeated signals

These are not three equal tracks or parallel devotion lanes
The Hist remains constitutive even in absence
```

**What each layer answers:**
- Hist relation → How connected am I to what makes me Saxhleel at all?
- Community → If the Hist is distant, am I still being held together by my people?
- Sithis → How much am I making meaning through change, death, void, and acceptance rather than through belonging?

---

## Implementation Locks

**Separate cultural substrate and relations (LOCKED 2026-07-13):** Argonian
keeps the canonical owner `PDV_Substrate_ArgonianHist`, but its boon tiers read
only the dedicated `CulturalPractice` metric. Hist, People, and Void are
independent relation ledgers, not weighted components of that metric. Exactly
People or Void may be the active emphasis.

**Storage namespace (LOCKED):** Preserve `PDV.Substrate.ArgonianHist.*` for
save compatibility. Add `CulturalPractice` and its devotional-day credit keys;
retain `Hist`, `People`, `Void`, their last-event keys, maintenance clock,
Sithis activation, and bed cadence as independent relation/state data.

**Hist distance rule (LOCKED):** Hist distance is always gently running in Skyrim. Evaluate at dawn only. If no valid Hist-maintenance signal occurred in the last three in-game days, reduce `Hist` by `1` per dawn, with a non-curse floor of `20`. Valid maintenance can offset or recover the loss through water/wetland/rest/reflection signals and the Hist sap meditation tool. 1.0 does not provide a full home-equivalent restoration state outside Black Marsh.

**Bed of choice (LOCKED):** Argonian uses one chosen community anchor through the shared `PDV_SacredPlace` pattern, `MaxLocations = 1`, presented as "the family I chose." This is not Khajiit-style road cycling. The cadence target is three qualifying sleeps at the chosen bed within a rolling 30 in-game days. Missing the cadence removes the place bonus and applies light `People` decay, not a harsh punishment.

**Sithis activation (LOCKED):** Every Argonian has baseline Sithis awareness, but full active `Void` scoring requires repeated strong signals. Joining the Dark Brotherhood counts as one major signal, not full activation by itself. Full activation requires at least three significant Sithis signals, preferably across at least two in-game days or quest beats. Valid signals are Dark Brotherhood milestones/contracts and curated death/void/change choices. Generic stealth, generic murder, and ordinary killing do not count.

**Sithis source promotion (LOCKED 2026-07-08):** More death, void, change, and non-Brotherhood quest beats should be added over time, but only through the exact-readback candidate queue. A promoted quest source must name the exact quest/stage/outcome, accepted context, rejected context, duplicate guard, and evidence. Each promoted source contributes a significant signal; none bypasses the three-signal activation gate.

**Curse posture enum (LOCKED):** Add `PDV_State_ArgonianHistPosture` for Hist-distance and curse interpretation, with exact values `Normal = 0`, `Distant = 1`, `Strained = 2`, `Silenced = 3`, and `Corrupted = 4`. Low uncursed Hist relation may become `Distant`; active lycanthropy sets `Strained`; active vampirism sets at least `Silenced`, and may become `Corrupted` when vampirism is paired with Molag Bal / domination / feeding-pattern pressure.

**Curse split (LOCKED):** Vampire is the deep grief state: Hist silenced or corrupted, community damaged, and Sithis more available but not automatically good. Werewolf is serious strain but recoverable: the shape is altered, the Hist relation is stressed, but Saxhleel identity is not spiritually annihilated.

---

## Layer Architecture

### Layer 1 — Hist Relation (Always Primary)

The Hist is always-primary and always under pressure in Skyrim. It decays slowly without maintenance. It recovers only from a small, careful set of signals. Intentionally harder to build than Layer 2.

**Hist decay:** A slow passive negative per day (small — not punishing, but present). Reflects the distance from Black Marsh and the absence of Hist trees. The decay is not stoppable — only offset.

**Hist recovery signals (limited, carefully curated):**
- Near water: wetlands, rivers, lakes, swamps, underground streams — environmental proximity signals
- Outdoor rest near water sources
- Meditation or rest (sleep events near water keyword-tagged locations)
- Solitary reflection moments (sitting still in natural outdoor locations — hard to detect cleanly; flag for later enrichment)
- Custom Argonian ritual hooks (Tier B content — later enrichment if vanilla core proves insufficient)

**What does NOT restore Hist relation:** Generic helping quests, ordinary combat, crafting. The Hist responds to environmental and reflective proxies, not general Skyrim activity.

**Hist relation effect on gameplay:** Hist relation score modifies the effectiveness of Layer 2 and Layer 3 signals. High Hist → Layer 2 community signals generate more piety. Low Hist → community signals still work but are buffered less strongly. Very low Hist → the Argonian begins losing access to their racial identity expression in the mod's framework (diminished boons, no Champion pathway open until Hist is stabilized).

### Layer 2 — Collective/Community Identity

The strongest vanilla-facing Argonian gameplay layer. The Hist is distant — community is what the exile holds onto.

**Primary signals:**
- Helping Argonians anywhere in Skyrim
- Windhelm/Assemblage interactions (extra-heavy weight — this is the primary Argonian community in Skyrim)
- Riften Docks Argonian community interactions
- Protecting marginalized Saxhleel from exploitation or violence
- In-game solidarity acts with other Argonians (not necessarily quest-flagged; named Argonian NPC interactions)

**Community can buffer low Hist relation.** If Hist relation is low, community signals partially compensate — the people hold you together when the trees cannot. This is architecturally important: a player who maintains strong community ties will experience less consequence from Hist decay than one who plays entirely solo.

**People-layer source promotion (LOCKED 2026-07-08):** Launch source-fill is exact/readback-backed only: Argonian Ceremony text, Histcarp/shared-food continuity, and Derkeethus rescue completion. Windhelm Assemblage remains a heavy People-lane target, and Jaree-Ra betrayal remains a potential negative People loss, but both stay candidate-only until exact quest/stage/outcome readback is approved. Future Argonian quests can be extrapolated into the candidate queue, not promoted from broad prose alone.

### Layer 3 — Sithis Acknowledgment

Every Argonian has a light baseline awareness of Sithis as change, void, and death. It becomes a major active lane only through strong repeated signals. It is not a setup-choice equivalent to the Hist.

**Sithis rises through:**
- Dark Brotherhood involvement (joining, completing contracts)
- Death-facing choices in dialogue (accepting mortality, choosing the void-embracing option in relevant dialogue nodes)
- Being present at significant deaths and accepting their reality rather than resisting them
- Specific Argonian acknowledgment of Sithis in roleplay contexts (few vanilla hooks; primarily Dark Brotherhood content)

**Sithis can stabilize a low-Hist Argonian** — it never fully compensates for Hist loss, but it provides an alternative framework for making meaning when the primary connection is strained. A Sithis-leaning Argonian in Skyrim exile is a specific character type: someone who has found a theology in the distance itself.

---

## Tier Rewards

### Tier 1 — Observant (Hist relation stable, community active)
*The Hist is distant but present. Your people recognize you. The void is acknowledged.*

- Water breathing enhanced (Argonian race ability, deepened by devotion)
- Swimming speed +10%
- Near water environments: +2 health/sec while in or near water environments (the Hist's echo in all water)
- Resist disease 15% (exile resilience — the community keeps you healthy)
- Windhelm Assemblage and Riften Docks NPCs treat you as a recognized member of the community (dialogue access)

### Tier 2 -- Faithful (cultural practice maintained; one emphasis may be active)
*The connection is maintained under exile conditions. Community is real. The void is accepted.*

- Near water/wetlands: water health regen increases to +5 health/sec (from +2 at Tier 1)
- Rest near water fully restores both health and stamina
- After helping another Argonian NPC, +30 stamina immediately (community as mutual sustenance)
- Windhelm Assemblage weighting: strong community acts give larger piety than equivalent acts elsewhere
- Dark Brotherhood advancement generates strong Sithis piety
- Sithis acknowledgment in dialogue generates modest piety at this tier
- Hist relation maintenance (water-adjacent behavior) gives modest daily piety — the maintenance is itself devotional

### Tier 3 -- Devoted (cultural practice at its high threshold)
*The Hist still knows you, even from this distance. Your community holds. The void is familiar.*

**Hist Champion:**
- *Champion moment:* Hist-Touched — in wetland, water, or underground-water environments, your connection is tangible. Damage resist 10% in those environments (the Hist's presence, even in proxy). In-combat clarity near water: +15 sneak (reduced detection threshold) and +3% attack speed (the Hist-sense, however attenuated, is real). The swamp gives you something Skyrim's dry stone corridors cannot.
- *Specific payoff:* Water environments are genuinely safer for you than for others. Environmental hazards (cold, hostile weather) near water are mitigated. In-combat detection threshold is improved by +15 sneak (harder to detect) and attack speed increases by +3% in water, wetland, or underground-water environments — the Hist-sense sharpens where it can reach. The sense of being somewhere the Hist can reach is the experience — not raw power, but a palpable presence that other environments lack.

**Community Champion:**
- *Champion moment:* Saxhleel Bond — your community is your armor. Helping Argonians generates significant piety (doubled at Devoted tier). When a friendly Argonian NPC is present (follower or story-relevant companion NPC), +8 armor rating (community as physical support). Maximum recognition at Windhelm Assemblage and Riften Docks — special dialogue, community-elder access, help that isn't offered to outsiders.
- *Specific payoff:* Community-facing acts generate the strongest piety in the mod at this tier for this layer. The Argonian exile network in Skyrim recognizes you as someone who kept the community alive.

**Sithis Champion:**
- *Champion moment:* Void-Held — near death (below 20% health), +50 stamina regen burst for 10 seconds (the void catches those who have acknowledged it honestly). Dark Brotherhood recognition: maximum standing, special dialogue with Brotherhood contacts. After completing a Dark Brotherhood contract, +10% movement speed and +15 sneak for 60 seconds. Death-facing choices in dialogue give a momentary clarity (flavor) that makes subsequent choices feel grounded.
- *Specific payoff:* The Sithis path is the most active combat-supporter of the three Argonian layers, but it's still secondary to Hist and community. Near-death resilience is the core mechanic — Sithis acknowledges those who have looked into the void without flinching. Dark Brotherhood completion generates the strongest single piety events available to an Argonian.

---

## Signature Friction

**Hist relation decay is always running.** Even if you're doing everything right, the Hist is still slightly harder to reach in Skyrim than in Black Marsh. This creates a constant, gentle pressure — you need to maintain water-proximity and reflective acts just to keep the connection from thinning. It's not punishing (the rate is slow), but it's present. An Argonian who spends months in Whiterun without seeking out water or rest near it will feel the Hist relation weakening in the tier threshold behavior.

**Community is the practical survival mechanic.** The Hist is hard to maintain; community is easier. For most Argonian playthroughs, the community layer is doing the heavy lifting — and that's lore-accurate. In exile, the people are what holds the Saxhleel together. The friction is that Skyrim's Argonian community is small, isolated (Windhelm, Riften Docks), and often in distress. Finding and helping them requires intentional geographic engagement with areas most players pass through briefly.

**The layered system means there's no single "correct" Argonian play.** A deeply water-connected solo Argonian with low community investment and modest Sithis awareness is a different character than a Windhelm Assemblage-focused Argonian who never seeks out water. Both are valid; both feel different. The friction is in figuring out which character you're playing.

---

## Neglect Texture

- **Hist relation neglect:** The connection thins. The water-based boons diminish gradually as Hist relation decays without maintenance. The sense of being constitutively Saxhleel — which should be present at high relation — fades into a more generic Argonian identity. You're still Argonian. The Hist still exists. It just can't reach you.
- **Community neglect:** Isolation compounds the Hist decay. An Argonian who never seeks out the Assemblage, never helps other Saxhleel, never maintains the exile network — the community buffers aren't there when Hist relation thins. It's the double-loss: both connections weakening simultaneously.
- **Sithis neglect:** Sithis is the void — it doesn't disappear when ignored. It's always present. But active Sithis acknowledgment generating piety requires the strong repeated signals (Dark Brotherhood content primarily). Neglecting this layer simply means the stabilization effect it offers isn't available when needed.
- **Total neglect:** An Argonian who avoids water, never helps other Saxhleel, and has no Dark Brotherhood involvement will see Hist relation decay slowly toward a floor, community piety never building above the base, and Sithis dormant. The tier ceiling drops. The racial boons thin. It feels like being a stranger in your own skin — which is exactly what the lore says happens to Argonians far from the Hist for too long.

---

## Signal Examples

| Layer | Action | Cadence | Notes |
|-------|--------|---------|-------|
| Hist | Sleep near water (riverbank, lake shore, wetland) | Daily cap | Location keyword: water-adjacent |
| Hist | Rest or idle near a large body of water | Daily cap | Broader than sleep — meditation proxy |
| Hist | Enter a swamp or significant wetland area | Per zone, daily cap | Black Marsh-proxy environment |
| Hist | Cross or wade through a large river | Daily cap | Movement through water, not just proximity |
| Community | Argonian Ceremony text, Histcarp/shared-food continuity, Derkeethus rescue completion | One-shot or capped source | Exact launch sources only; not generic Argonian contact |
| Community | Help a named Argonian NPC (quest or dialogue) | Candidate queue | Requires exact quest/stage/outcome readback before source-fill |
| Community | Complete a quest helping the Windhelm Assemblage | Candidate queue | Extra-heavy target, but generic Windhelm presence is rejected |
| Community | Protect an Argonian NPC from violence | Candidate queue | Reactive to NPC threat; exact source/outcome required |
| Community | Riften Docks interaction (buy from, help, defend Argonians) | Candidate queue | Secondary hub; generic Riften presence is rejected |
| Sithis | Dark Brotherhood initiation or end-state milestones | One-shot significant signal | Exact launch sources; one signal does not fully activate Void scoring |
| Sithis | Future death/void/change quest beat | Candidate queue | Requires exact quest/stage/outcome readback before source-fill |
| Sithis | Complete a Dark Brotherhood contract | Candidate queue / post-threshold context | No radiant assassination loop; exact source or controlled route required |
| Sithis | Choose a death-acknowledging dialogue option | Candidate queue | Curated node list required; small piety only |
| All | Near-water combat win | Hist layer | Location-keyword + Story Manager kill event |
| Hist decay | Any in-game day without a Hist-recovery signal | Passive negative | Small; recoverable with water proximity |

---

## Implementation Notes

**Vanilla hook surface:** Limited but workable. Argonian-specific quest content in Skyrim is sparse (Windhelm Assemblage situation, Riften Docks, Blood on the Ice has Argonian adjacency). Water-environment detection requires location keyword checking or proximity to water plane. Dark Brotherhood content is well-structured for Sithis signals.

**Complexity flags:**
- **Hist relation decay system:** Requires a passive daily negative in ProcessDawn — a negative piety contribution that fires unless offset by water-proximity signals from the day. This is a novel pattern (most races only accumulate piety, not decay it passively). The decay rate must be carefully tuned: too fast and it's punishing; too slow and the connection never meaningfully degrades.
- **Water-proximity detection:** Requires either location keywords (water-adjacent markers in the CK) or a water-plane proximity check (more expensive). Recommended: use existing water-type location keywords on cells/regions as the primary detection surface. This is less precise but more performant and avoids constant proximity polling.
- **Hist relation as modifier on Layer 2:** The interaction between Hist relation and community scoring means ProcessDawn needs to read Hist relation score and apply it as a multiplier to community piety before consolidation. This is new logic but fits cleanly into the existing gain pipeline no-op slots.
- **Sithis rising from low:** The Sithis layer needs a signal density check — it should only become a major active lane after "strong repeated signals," not from a single Dark Brotherhood join event. Recommend: a running Sithis-signal counter that unlocks full Sithis scoring at a threshold (e.g., three significant Sithis acts). Below that threshold, Sithis generates quarter piety.
- **Tier B enrichment:** Custom Argonian ritual hooks (meditation at specific locations, ritual behavior) are deferred to post-launch enrichment if the vanilla core proves thin. Don't build custom content infrastructure in 1.0 — build the vanilla hook system first and assess.
- **Vampire curse depth:** "One of the deepest grief states in the mod" — this requires particular care in how it's surfaced. The Hist relation collapsing toward silence should have explicit notification, not just mechanical silence. Content work.

**Cost class profile:**
- Water-proximity detection: Cost Class B (location keyword check, periodic or event-based)
- Argonian NPC interaction signals: Cost Class A (dialogue event or quest stage)
- Hist decay in ProcessDawn: Cost Class A (passive negative in dawn pipeline)
- Sithis signal threshold system: Cost Class B (running counter with unlock threshold)
- Layer interaction (Hist × Community): Cost Class A (multiplier in dawn pipeline)

---

## Curse State Summary

**Vampire:**
- Hist relation hits hardest and may collapse toward silence or active corruption — the Hist does not speak to its own undead
- Collective/community identity is also damaged — vampirism makes community belonging dangerous or impossible
- Sithis acknowledgment becomes more available or foregrounded (the void is the closest thing vampirism has to a Saxhleel frame), but not automatically good — Sithis doesn't celebrate vampirism, he acknowledges it
- This is one of the deepest grief states in the mod — all three layers are compromised simultaneously; the Argonian is genuinely spiritually homeless
- Lore rationale: The Hist gives Argonian souls and receives them at death. Vampirism interrupts that cycle at the most fundamental level — the soul is no longer going where it was supposed to go.

**Werewolf:**
- Serious strain on Hist relation, but not total collapse
- Less destructive to community belonging than vampirism — the community can still recognize you, even if the werewolf state is uncomfortable
- Mostly neutral to Sithis acknowledgment (the beast-shape doesn't engage the void in the same way vampirism does)
- Potentially more manageable than for many other races because Argonian theology is less rigid about fixed form — the Hist is accustomed to Argonians changing, and beast-shape, while strange, isn't theologically annihilating
- Lore rationale: Matches the curse source material's distinction between Hist-refusal in vampirism (the Hist cannot guide what has been cut from its cycle) and more tractable beast-shape strain in lycanthropy (the Hist can still hold an Argonian who has a changed shape, if less easily).
