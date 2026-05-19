# PDV Race Design — Khajiit
**Last updated:** 2026-05-19
**Implementation status:** LOCKED (lunar substrate, focused emphasis, road homes, curse posture, and launch hook scope)
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.6)

---

## Religious Identity

Khajiit religion is cosmologically constitutive. The moons — Jone and Jode, Masser and Secunda — determine what form a Khajiit is born into. The Lunar Lattice (ja-Kha'jay) is the framework within which Khajiit existence makes sense. This isn't belief in the way other races believe things — it's a description of physical and metaphysical reality that is simply true for the Khajiit.

Khajiit in Skyrim carry this with them into a province that doesn't recognize it. They're excluded from most city temples. They're not welcome in holds as anything but merchants. Their religion has no local infrastructure. What they have is the road, each other, and the moons.

**Core design intent:** Khajiit should feel cosmologically held even before focused commitment — the lunar substrate is always running. The deepening toward a focused patron should feel silent and emergent, like a preference becoming clear through lived behavior rather than a formal declaration. Playing a Khajiit should feel like exile life that is still spiritually coherent.

---

## Worship Structure

```
No setup choice and no formal archetype selection
All Khajiit begin inside the Lunar Lattice automatically
Broad lunar worship begins at game start
Broad lunar worship cap: Tier 2 (Faithful)

The substrate is always active — it does not require maintenance to exist
Focused deity emphasis emerges silently through behavior
  (Unlike Nord/Imperial — no formal offer fires; weighting shifts until one god leads)
Focused commitment confirmed when one deity's piety clearly dominates
Tier 3 accessible through focused deity commitment
```

**Available focused deity paths:** Azurah, Khenarthi, Baan Dar, Rajhin, Alkosh (in rough order of accessibility).

**Substrate-only (not focused paths):** Riddle'Thar, ja-Kha'jay, Jone, Jode — these are the Lattice itself.

**Passive influences only (not full primary paths):** Mara (S'rendarr in Khajiit naming), Stendarr (S'rendarr), Magrus.

**Dark/curse/perpendicular pressures — not standard paths:** Nocturnal, Hircine, Sangiin, Namiira, Lorkhaj, Sheggorath.

---

**Substrate namespace (LOCKED):** `PDV_Substrate_KhajiitLunar` is the canonical substrate owner. Use the existing StorageUtil prefix `PDV.Substrate.KhajiitLunar.*`, extending from current keys rather than renaming them: `Metric`, `Tier`, `LastEvent`, `LastPhase`, `ObservanceCount`, and `RoadHomeCount`.

**Moon-cycle model (LOCKED):** 1.0 uses the hybrid moon model. The current phase provides small per-phase activity bonuses, while full-cycle consistency determines overall substrate strength. This prevents moon awareness from becoming a wait-for-the-right-night chore while still rewarding players who live across the full cycle.

**Moon phase source (LOCKED):** Prefer reliable real Skyrim Masser/Secunda state where available. If implementation proof is weak or the hook is brittle, use an abstract 28-day fallback cycle. The locked experience is lunar cadence and consistency; the implementation must not depend on fragile visual/moon API assumptions.

**Silent patron emergence (LOCKED):** Khajiit remain the only no-offer race in 1.0. Focused deity emphasis shifts silently at dawn based on weighted behavior. No formal patron offer fires, and the player never "accepts" Azurah, Khenarthi, Baan Dar, Rajhin, or Alkosh through the shared offer UI. The player notices through stronger domain rewards, status readout, and flavor.

**Focused-emphasis state (LOCKED):** Do not use `PDV_GLO_PatronState = active primary` to represent Khajiit focus. Add a Khajiit-specific current emphasis state, recommended as `PDV_State_KhajiitFocusedEmphasis`, with a CK-readable mirror only if implementation needs conditions. This tracks the leading deity emphasis without pretending a formal commitment offer occurred.

**Focused-emphasis enum (LOCKED):** `PDV_State_KhajiitFocusedEmphasis` uses `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, and `Alkosh = 5`. `None` means broad lunar worship, not failure.

**Focused-emphasis threshold (LOCKED):** Focus activates only when one focused deity has at least `50` persistent piety and leads the next-highest Khajiit focused deity by at least `15` piety. This is evaluated at dawn. The margin prevents flicker between close deity emphases.

**Broad fallback (LOCKED):** If no deity has a clear lead, the Khajiit remains in broad lunar Faithful state. Balanced worship is complete and valid; do not force a focus just because the player has enough total piety across several gods.

**Road homes (LOCKED):** 1.0 implements Khajiit road homes as `2-3` player-designated rest anchors, not one sacred place. This preserves caravan-circuit identity and avoids reusing the Orc/Bosmer single-place pattern.

**Road-home cadence (LOCKED):** Road-home piety requires cycling between anchors over time. Repeating the same camp, bed, or convenient outdoor rest does not count as road-home cadence. The devotional act is the circuit.

**Lunar posture enum (LOCKED):** Add `PDV_State_KhajiitLunarPosture` for curse and shadow pressure, with exact values `Normal = 0`, `Strained = 1`, `Corrupted = 2`, and `ShadowDrift = 3`.

**Vampire posture (LOCKED):** Active vampirism sets lunar posture to `Corrupted`. The Lattice still holds the character, but community belonging, caravan trust, and ordinary moon-life rewards are weakened. Vampirism does not automatically turn the character into a Nocturnal devotee.

**Werewolf posture (LOCKED):** Active lycanthropy sets lunar posture to `Strained`. Hircine adds a competing shape, but Khajiit identity remains recognizably Khajiit. Werewolf pressure should feel uncomfortable and socially costly, not spiritually erased.

**ShadowDrift boundary (LOCKED):** `ShadowDrift` is reserved for dominant shadow-pattern behavior: Nocturnal alignment, active vampire posture plus repeated night-only predation, or other explicitly shadow-coded behavior. Do not enter `ShadowDrift` from ordinary night travel, stealth, or lunar observance.

**Launch focused paths (LOCKED):** All five focused emphases are valid for 1.0: `Khenarthi`, `Azurah`, `Baan Dar`, `Rajhin`, and `Alkosh`. `Khenarthi` and `Azurah` are the most routinely reachable, `Baan Dar` and `Rajhin` are behavior-specific, and `Alkosh` is rare/high-threshold by design.

## Tier Rewards

### Lunar Substrate — Always Active (no tier gate)

The substrate is the foundation. It runs before any tier threshold and provides:
- Night vision enhancement (already vanilla Khajiit, but devotion amplifies its effectiveness slightly at night)
- Outdoor nighttime activity generates modest continuous piety (living the road life)
- Community acts — helping caravans, protecting Khajiit, sustaining caravan life — generate piety at substrate level
- Moon-phase awareness: certain signal windows are slightly stronger at specific moon phases (first/last quarter, full moons — requires periodic state check)

*Lore rationale: The Lunar Lattice isn't a reward for belief — it's the structure of Khajiit existence. The substrate represents the religion that is simply true rather than chosen.*

### Tier 1 — Observant (lunar worship beginning to focus)
*The moons have noticed how you move through the world.*

- Stamina regen +5% while moving outdoors at night (Khenarthi's road-breath)
- Resist disease 10% (caravan life's practical grace — Khajiit in Skyrim are resilient)
- First interactions with caravan merchants each in-game day have slightly favorable prices (community recognition)
- Outdoor rest (not inn, not house) restores stamina fully at Tier 1

### Tier 2 — Faithful (focused path beginning to clarify)
*One god is beginning to notice you specifically. The Lattice holds you steady.*

Shared Tier 2 benefits:
- Outdoor nighttime travel: minor carry weight bonus (the road provides)
- Weather resistance — cold and storms less penalizing outdoors
- Caravan encounters generate piety (helping Ma'dran, Ri'saad, or other caravan content)
- Moon-phase window: at full moons, daily piety generation from outdoor acts is boosted slightly
- City-exclusion solidarity: acts outside city walls generate slightly stronger piety than equivalent acts inside (the road as home)

Path-specific Tier 2 notes:
- *Khenarthi:* Extended outdoor stamina; wind-assisted travel (sprint stamina drain -10%)
- *Azurah:* Dawn/dusk windows give brief magic cost reduction; Azura's Star quest generates strong piety
- *Baan Dar:* After surviving combat while severely outnumbered, brief stamina regen; exile/outsider NPCs more favorable
- *Rajhin:* Successful elegant theft (high-value, undetected) gives brief speed/sneak bonus
- *Alkosh:* Dragon-facing content generates strong piety; anti-chaos/order-keeping quest choices score

### Tier 3 — Devoted (focused deity fully committed)
*The god has learned your face. The Lattice has a name for what you are.*

**Khenarthi Champion:**
- *Champion moment:* Wind-Caller — the road recognizes you. In open outdoor terrain, sprinting stamina drain -15% cumulative (Tier 1 + Devoted bonus). Approaching caravan camps with Khenarthi devotion gives the caravan merchants a brief recognition response (they know someone the wind recommended). Storms don't penalize you — outdoors in storm or rain: the exposure/cold effect is negated entirely (Survival Mode). Open-sky journeys feel guided.
- *Specific payoff:* Outdoor sleep (camping, not inn) restores both health and stamina. Open-road travel between holds generates small ambient piety. Khenarthi's mercy domain: helping a stranded or lost NPC generates strong piety.
- *Lore rationale:* Khenarthi is wind, weather, and passage — the god of the road Khajiit are forced to live. At Champion, the road itself becomes an ally.

**Azurah Champion:**
- *Champion moment:* Starwalker — threshold moments have prophetic weight. Entering significant dungeons, completing major quests, making defining choices — these give brief Azurah-voiced flavor text (diegetic, subtle, in keeping with Khajiit naming conventions for her). At dawn and dusk specifically: magic cost -15% for the twilight window. Magic cost reduction -10% baseline at night (star-born favor).
- *Specific payoff:* Azurah's Star quest gives maximum recognition privilege at Tier 3 — the stone responds differently, and the event generates more piety than any other Khajiit signal. The threshold-awareness works both ways: Azurah Champion can feel when a major transition is coming before it fires (flavor/immersion layer, not mechanical prediction).
- *Lore rationale:* Azurah shaped the Khajiit and guards their passage through thresholds — including the big ones. At Champion, she's watching your thresholds.

**Baan Dar Champion:**
- *Champion moment:* Pariah's Fortune — once per in-game week, surviving a near-death combat situation (below 10% health and winning, or escaping an encounter that should have been fatal) gives a 24-hour brief bonus pulse (minor stats across the board, or a specific stamina/health regen). Baan Dar interceded. The timing should feel earned and slightly improbable — like the Trickster's blessing rather than a mechanical safety net.
- *Specific payoff:* Acts outside city walls continue to generate slightly stronger piety than equivalent acts inside. Exile survival and clever-reversal quest choices generate strong piety. After a successful pickpocket or sneak theft from a notably high-level target, brief sneak enhancement.
- *Lore rationale:* Baan Dar is the god of pariahs, clever exiles, and reversals. At Champion, the improbable reversal is your story — and the god of that story occasionally writes a scene on your behalf.

**Rajhin Champion:**
- *Champion moment:* Rajhin's Touch — elegant theft from notable targets (quest-important characters, named merchants, high-value NPCs) gives a brief near-invisibility window (5-10 seconds of enhanced sneak, not true invisibility). Theft from impossible targets — places where "no one steals from them" — generates maximum Rajhin piety. Performance/bardic acts at Champion generate recognition from certain NPCs who appreciate artistry in craft.
- *Specific payoff:* Lockpicking is easier at this tier (not faster, but more forgiving on failure). Rajhin Champion sneak attacks deal bonus damage only on first hit per encounter — the signature move, not the sustained advantage. Story-worthy thefts (quest-involved, legendary items) generate very strong piety.
- *Lore rationale:* Rajhin is the greatest thief who ever lived, who wore Mephala's ring and stole from the Emperor. At Champion, you're a character in a story about theft — and the story has a patron.

**Alkosh Champion:**
- *Champion moment:* The Rarest Champion — requires the most specific playstyle (dragon-facing, anti-chaos, order-keeping). Dragon combat generates strong Alkosh piety from Tier 1 onward; at Champion, defeating a named dragon (not random encounter) gives a 48-hour blessing pulse (resist fire 15%, minor health regen in combat). The main quest's dragon-facing content is the natural Alkosh Champion arc.
- *Specific payoff:* Resist fire 15% cumulative at Champion. Named dragon fights generate exceptional piety (truly rare events, no anti-farm needed beyond their natural scarcity). Anti-chaos and order-keeping quest choices (stopping the Thalmor from disrupting a ritual, defending a settlement from organized attack) generate strong piety.
- *Lore rationale:* Alkosh is the dragon-lord of Khajiit cosmology, the checker of Lorkhaj's chaos. At Champion, fighting dragons isn't just adventuring — it's the work of your patron god's domain.

---

## Signature Friction

**Exile-life maintenance.** Khajiit are excluded from most hold city temples. They cannot meaningfully engage with the Nine Divines institutional infrastructure in the normal way. The religion they practice exists in the road, the caravan camp, the open sky — and Skyrim's major content constantly pulls them into cities, dungeons, and guild buildings.

A Khajiit player who stays in Whiterun for three weeks without leaving, never interacts with a caravan, and sleeps only in inns is letting the substrate go quiet. Not punished — the substrate doesn't decay unless really neglected — but the scoring surface for the most meaningful Khajiit signals simply isn't firing.

**Moon-phase awareness** is the more mechanical friction: certain signal windows are stronger at specific moon phases. A player who pays attention to the moons gets slightly better signal timing. A player who ignores them gets full scoring but misses the amplification windows.

**The silent emergent patron system** is friction in a positive sense: you can't choose your patron by clicking a button. You find out who your patron is by how you've been living. This means some Khajiit players will spend a long time in broad worship not because they're slacking, but because their playstyle is genuinely balanced across multiple domains. That's fine — broad worship at Tier 2 is a complete, lore-accurate Khajiit experience.

---

## Neglect Texture

The lunar substrate weakens when you've been **indoors, urban, and disconnected from the road and sky**.

- **Substrate neglect:** The small nightly bonuses from outdoor activity stop accumulating. Indoor living generates much weaker piety from the substrate. The night vision enhancement feels less crisp. The community recognition at caravans fades — they don't know you because you haven't been where they travel.
- **Focused patron neglect:** If Khenarthi was your emerging focus and you stop taking journeys, stop sleeping outside, stop doing anything road-related — the piety balance slips back toward broad worship. You don't lose Khenarthi's attention dramatically; she just stops sending wind.
- **The caravan dimension:** Not interacting with the caravans (Ma'dran, Ri'saad, Ahkari's group, Khaara's group) means the community signal surface goes dark. For a Khajiit, that's a significant portion of their religious life.

*Khajiit neglect is not urgent. The Lattice doesn't collapse easily. But being cut off from road, sky, and community for long stretches has a cumulative thinning quality — less held, less known, less real.*

---

## Signal Examples

| Action | God(s) | Cadence | Notes |
|--------|--------|---------|-------|
| Sleep outdoors (not in inn or house) | Substrate / Khenarthi | Daily cap | Core substrate signal; Survival Mode overlap high |
| Travel between major areas on foot (not fast travel) | Substrate / Khenarthi | Daily cap; per leg | Road-life signal; fast travel bypass must be addressed |
| Help a Khajiit caravan NPC | Substrate / community | Per interaction, cooldown | Ma'dran, Ri'saad, Ahkari, Khaara — named caravan members |
| Buy or sell with a Khajiit merchant (caravan only) | Substrate / community | Daily cap | Caravan commerce as community connection |
| Observe dawn or dusk outdoors | Substrate / Azurah | Daily cap (2x) | Time-window check; outdoor requirement |
| Complete Azura's Star quest | Azurah | One-time | Maximum Azurah signal |
| Pickpocket or steal from a notable target (undetected) | Rajhin | Per target, cooldown | High-value or story-important target only |
| Win a fight while severely outnumbered | Baan Dar | Per event, cooldown | Outnumbered threshold: 3+ enemies or higher-level |
| Fight and defeat a dragon (named) | Alkosh | Per dragon | Natural scarcity is sufficient anti-farm |
| Protect or defend a Khajiit NPC | Substrate / community | Per event | Any Khajiit NPC threatened |
| Enter dungeon / complete major quest (threshold) | Azurah | Per threshold | Flavor text trigger, minor piety |
| Survive near-death combat (below 10% health, win) | Baan Dar | Weekly cap (once per week) | Anti-farm via weekly cap + cooldown |
| Full moon night outdoor activity | All substrate | Once per full moon cycle | Small bonus amplifier, not new signal |

---

## Implementation Notes

**Vanilla hook surface:** Moderate. Khajiit-specific content in Skyrim is limited (caravans, a few named NPCs, Elsweyr-adjacent lore). The lunar substrate relies heavily on behavioral signals (outdoor sleep, outdoor travel, caravan interaction) rather than content-specific events. Dragon combat content is well-structured for Alkosh.

### In-game hook cross-check

| Experience target | 1.0 hook candidates | Confidence | Implementation posture |
|---|---|---|---|
| Lunar observance / moon-phase awareness | `ObserveMoonPhase`, dawn/dusk/night outdoor checks, `LastPhase`, `ObservanceCount`, GameDaysPassed fallback cycle | Strong for fallback; medium for real moon state | Prefer real Masser/Secunda only if proven reliable; otherwise use abstract 28-day cadence. Small phase bonuses only. |
| Open road / Khenarthi | Sleep event, outdoor rest, location-change over time, no-fast-travel validation, open-sky checks | Medium-strong | Good launch lane. Cap daily and present as road-life continuity, not travel grinding. |
| Road-home circuit | `RoadHomeCount`, 2-3 designated rest anchors, cycling validation, elapsed time/distance between anchors | Medium/custom | Viable as authored state. Repeating one camp or bed never counts as the circuit. |
| Caravan/community belonging | Named caravan NPC interaction/trade/favor signals (`Ma'dran`, `Ri'saad`, `Ahkari`, `Khaara`), Khajiit aid/protection | Medium | Use cooldown per caravan encounter. Weights lunar substrate plus `Khenarthi` / `Baan Dar`. |
| Azurah thresholds | `The Black Star`, Azura shrine, dawn/dusk windows, major quest thresholds, dungeon entry/clear milestones | Strong for quest/shrine; medium for general thresholds | Use curated threshold beats and twilight windows. Do not turn dawn/dusk into a generic piety faucet. |
| Baan Dar reversals | Near-death survival, escape/win from outnumbered pressure, pariah aid, exile-survival quest choices | Medium-risk | Use weekly caps and adversity filters. The trigger is meaningful reversal, not routine survival. |
| Rajhin elegant theft | Thieves Guild stages, high-value undetected theft/pickpocket, named/notable targets, story-worthy stolen items | Medium | Favor artful theft and mythic thief beats. Petty theft should not spam piety. |
| Alkosh dragon/order | Named dragon kills, main quest dragon beats, anti-chaos/order-keeping quest stages | Strong but naturally rare | Good launch lane because scarcity handles much of the balance. Random dragons score lower than named/cosmic beats. |
| Curse posture | Vampire/werewolf state detection, Nocturnal/Hircine quest pressure, sustained nocturnal predation | Medium | Sets posture modifiers. Vampirism = `Corrupted`; lycanthropy = `Strained`; `ShadowDrift` needs dominant shadow behavior. |
| Moon sugar | Curated ritual only, if a reliable ritual context is authored | Weak/rejected for general use | Do not use moon sugar as a general devotion trigger. |

**Complexity flags:**
- **Silent emergent patron system:** Unlike Nord's formal offer system, Khajiit patron emphasis is determined by which deity's piety accumulates fastest through behavior. The commitment confirmation (when one deity's piety clearly dominates others) needs a threshold in the dawn pipeline to surface clearly. This is architecturally straightforward but requires careful UX — the player should understand what happened without feeling like the mod randomly assigned them a patron.
- **Moon-phase detection:** Requires periodic state check (or GameDaysPassed-based calculation) to determine current moon phase. Low script cost; medium implementation care. Moon sugar rule (LOCKED): moon sugar triggers only in limited, curated, high-confidence ways — not a general devotion trigger. If used at all, one specific ritual context.
- **Fast travel bypass for road-life signals:** Road-travel signals should not fire on fast travel (it would make them trivially farmable). Use elapsed-time-since-last-location-change or explicit travel-on-foot detection via location change events over time. Flag as medium complexity.
- **Caravan NPC signals:** Named caravan merchants (Ma'dran, Ri'saad, Ahkari, Khaara) need interaction events — dialogue opening or trade menu opening triggers piety. These NPCs move on schedules; signals should fire per caravan encounter, not per dialogue line.
- **Alkosh dragon-fight distinction:** Named vs. random dragon distinction requires checking the ActorBase or keyword on the killed actor. Named dragons (Mirmulnir, Sahloknir, Alduin's lieutenants) generate full piety; random encounter dragons generate less. This is lore-accurate (Alkosh is about cosmic order-keeping, not routine dragonslaying).

**Cost class profile:**
- Outdoor sleep / rest: Cost Class A (sleep event)
- Caravan NPC interaction: Cost Class B (dialogue event; NPC schedules add complexity)
- Moon-phase window: Cost Class B (periodic state check — once per day is sufficient)
- Silent patron emergence: Cost Class B (dawn pipeline evaluation of piety dominance)
- Road-travel detection (non-fast-travel): Cost Class C (requires location-change time tracking)

---

## Curse State Summary

**Vampire:**
- Lunar substrate remains active but **corrupted and weakened** (not destroyed like Dunmer ash-prayer)
- Normal Khajiit devotion does not collapse entirely — the Lattice still holds them, but it's strained
- Caravan/community compatibility reduces sharply (vampirism makes caravan interaction dangerous or unwelcome)
- Azurah remains a possible protective reading — her relationship with the undead is complex
- Nocturnal drift increases as a shadow substitute (night-dominant existence pulls toward shadow-patron)
- Lore rationale: Khajiit identity is cosmological and biological. Vampirism damages belonging rather than erasing it cleanly — the moons don't disown a vampire Khajiit, but the community does.

**Werewolf:**
- Lunar substrate remains **mostly intact but strained** (the moons are about form; werewolf is a competing form, not an opposite one)
- Hircine adds an off-moon shape rather than fully severing Khajiit identity
- Caravan/community belonging is damaged (a werewolf is a threat to the community)
- Khajiit devotion remains recognizably Khajiit, but under strain
- Lore rationale: Werewolfism adds a competing shape; vampirism destabilizes identity more deeply. The Khajiit have more theological room for shape-complexity than most races — they are defined by it. Werewolf is uncomfortable rather than theologically annihilating.
