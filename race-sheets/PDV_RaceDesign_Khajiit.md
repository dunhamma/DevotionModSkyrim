# PDV Race Design — Khajiit
**Last updated:** 2026-08-06
**Implementation status:** LOCKED (lunar substrate, focused emphasis, outdoor road-home practice, Observe the Moons, curse posture, and launch hook scope)
**Status:** Implementation locked for 1.0 experience shape; reward numbers remain tunable
**Architecture status:** LOCKED (see PDV_RaceArchitecture_DesignReference.md §10.6)

---

## 2026-08-06 Lunar and Champion Rebalance

This section supersedes every older statement below about silent emergence,
permanent broad worship, `50 / 15` focus gates, rotating phase-stat blessings,
the presiding-god piety multiplier, and prior Khajiit reward magnitudes.

- The exclusive substrate tiers are Lunar Hardiness at `1-24` (Disease
  Resistance `+5%`), Khajiit Lunar Road at `25-74` (Stamina `+10`, Disease
  Resistance `+10%`), and Lunar Attunement at `75+` (Stamina `+15`, Disease
  Resistance `+15%`). Lunar Attunement no longer grants Magicka.
- Broad Lunar Lattice remains valid until one deity has at least `25` focus
  weight, a `15` lead, and actual piety `25` (Seeker). The first qualifying god
  emerges automatically with a one-time ceremonial MessageBox, Prisma toast,
  and pinned Book of Days entry. Later qualifying leaders reorient the focus
  automatically with toast and Book entry but no second popup. Ties, lost lead,
  or piety loss never erase an established focus.
- The eight gods-in-strength slots remain `Alkosh, Azurah, Khenarthi, Rajhin,
  Rajhin, Baan Dar, Khenarthi, Azurah`. Public copy names only the god currently
  in strength. The five old rotating stat spells and the `+10%` piety
  multiplier are retired and reconciled away.
- Lattice Resonance activates when the focused Seeker-or-higher deity is in
  strength. It increases only that focused numeric blessing by `20%` and shows
  a separate Active Effects marker. It never amplifies substrate rewards,
  Azurah's Portent, Baan Dar's rescue, or scripted capstones.
- Moon observations load ten lines for the current god plus six shared lines
  from `PDV_KhajiitMoonObservations.json`, with uniform selection and resolved
  line-ID immediate-repeat prevention. The compiled four-line sets remain a
  missing-or-invalid-JSON fallback.
- Current focused reward totals are: Khenarthi `15`; `25/30 carry`;
  `40/80 carry/3% speed`. Azurah `15`; `25/5% magic resistance`;
  `40/15% magic resistance/Portent`. Baan Dar `5 unarmed`;
  `10 unarmed/20 health`; `20 unarmed/30 health/daily 50% rescue`. Rajhin
  `5 sneak`; `13 sneak/10 lockpicking`; `25 sneak/25 lockpicking/15
  pickpocket`. Alkosh `15 armor`; `30 armor/8 block`; `50 armor/15 block/10%
  faster Shout recovery`.
- Azurah's Portent is a Champion-only, player-triggered lesser power available
  once per 06:00 devotional day. For 15 seconds it reveals living actors,
  undead, corpses, Daedra, and Dwarven automatons through walls within 100 feet
  indoors or 200 feet outdoors, without crossing loading doors or unloaded
  cells.

`references/authoring/PDV_KhajiitFiveDeityDailySignalAudit_2026-08-06.md` is the
signal-coverage authority for the five focused deities: per-deity curated and
likes/dislikes inventory, the repeatable-parity verdict, and the locked specs for
the moon-rite split and the quest-row expansion.

Runtime and manual proof for these new surfaces remains open until the Khajiit
in-game matrix is recorded.

## 2026-07-13 Lunar-Road Pacing Addendum

This addendum supersedes later designated road-home anchors, circuits, generic
sleep observance, and route-specific `+1/+2` magnitudes. Any completed outdoor
rest is road-home practice: the road itself is home. The first approved outdoor
rest, moon rite, caravan defense, Baan Dar reversal, notable Rajhin theft,
Alkosh milestone, or curated lunar source in each 06:00 devotional day grants
`+4` toward `1/25/75`; later acts grant zero. Generic inn/house sleep and
generic theft or stealth do not qualify. The substrate does not decay.

`Observe the Moons` is a Khajiit-only lesser power used outdoors from 20:00 to
05:00. It resolves once after two still, uninterrupted seconds in the shared
Power slot. Selecting it replaces Survey Devotion in the ordinary Magic-menu
way, but origin setup never changes the selected power. Its contemplation
appears as a non-blocking Prisma toast; the first valid rite that day also
enters the Book of Days, grants substrate credit, and raw
presiding-god piety `+0.4`. Later casts are informational.
`references/authoring/PDV_SubstratePacingContracts.json`
is authoritative.

## Religious Identity

Khajiit religion is cosmologically constitutive. The moons — Jone and Jode, Masser and Secunda — determine what form a Khajiit is born into. The Lunar Lattice (ja-Kha'jay) is the framework within which Khajiit existence makes sense. This isn't belief in the way other races believe things — it's a description of physical and metaphysical reality that is simply true for the Khajiit.

Khajiit in Skyrim carry this with them into a province that doesn't recognize it. They're excluded from most city temples. They're not welcome in holds as anything but merchants. Their religion has no local infrastructure. What they have is the road, each other, and the moons.

**Core design intent:** Khajiit should feel cosmologically held even before focused commitment — the lunar substrate is always running. The deepening toward a focused patron should emerge from lived behavior rather than a formal choice, with the first qualifying road revealed ceremonially so the change is never invisible. Playing a Khajiit should feel like exile life that is still spiritually coherent.

---

## Worship Structure

```
No setup choice and no formal archetype selection
All Khajiit begin inside the Lunar Lattice automatically
Broad lunar worship begins at game start
Broad lunar worship cap: Tier 2 (Faithful)

The substrate is always active — it does not require maintenance to exist
Focused deity emphasis emerges automatically through behavior
  (Unlike Nord/Imperial, no formal offer fires; weighting shifts until one god qualifies)
The first focus is announced once; later qualifying leaders reorient automatically
Tier 3 accessible through focused deity commitment
```

**Available focused deity paths:** Azurah, Khenarthi, Baan Dar, Rajhin, Alkosh (in rough order of accessibility).

**Substrate-only (not focused paths):** Riddle'Thar, ja-Kha'jay, Jone, Jode — these are the Lattice itself.

**Passive influences only (not full primary paths):** Mara (S'rendarr in Khajiit naming), Stendarr (S'rendarr), Magrus.

**Dark/curse/perpendicular pressures — not standard paths:** Nocturnal, Hircine, Sangiin, Namiira, Lorkhaj, Sheggorath.

---

**Substrate namespace (LOCKED):** `PDV_Substrate_KhajiitLunar` is the canonical substrate owner. Use the existing StorageUtil prefix `PDV.Substrate.KhajiitLunar.*`, extending from current keys rather than renaming them: `Metric`, `Tier`, `LastEvent`, `LastPhase`, `ObservanceCount`, and `RoadHomeCount`.

**Moon-cycle model (LOCKED, updated 2026-08-06):** 1.0 uses the merged god-aligned Lattice model. The Lattice runs on the real Skyrim moon cycle, and each slot belongs to one of the five moon-path gods. Public presentation names only the god currently **in strength**. When that god matches an established Seeker-or-higher focus, Lattice Resonance increases the focused numeric blessing by 20%; the cycle never changes piety gain and never strengthens the substrate or scripted capstones.

**Moon phase source (LOCKED, updated 2026-06-10):** The Lattice phase is the REAL visible Skyrim moon: an 8-phase, 24-day cycle computed from GameDaysPassed % 24 with the Creation Kit GetCurrentMoonphase boundaries (full moon on the wrap at days 22-23/0, new moon at days 10-12, midday rollover). No Papyrus moon API exists, so the engine formula is replicated deterministically in `GetKhajiitMoonPhaseFromGameDay`; this matches the rendered sky on vanilla phase-length settings. The earlier abstract 28-day fallback cycle is retired.

**God-strength schedule (LOCKED, updated 2026-08-06):** Slot-to-god alignment is owned in one place in code (`GetLunarPresidingFocus`). The visible-moon column is internal implementation context, not player-facing waxing/waning copy:

| Lattice slot | Visible moon | God in strength |
|---|---|---|
| 1 | Full moon | Alkosh (order at its height) |
| 2 | Waning gibbous | Azurah (twilight descending) |
| 3 | Last quarter | Khenarthi (the road in balance) |
| 4 | Waning crescent | Rajhin (fading into shadow) |
| 5 | New moon | Rajhin (the deepest dark) |
| 6 | Waxing crescent | Baan Dar (the pariah's edge) |
| 7 | First quarter | Khenarthi (the road in balance) |
| 8 | Waxing gibbous | Azurah (twilight ascending) |

Window counts follow the accessibility ordering: Khenarthi/Azurah/Rajhin two phases each, Baan Dar one, Alkosh only the full moon (rare by design).

**Lattice Resonance (LOCKED, updated 2026-08-06):** When the god in strength matches the current focused deity and that deity is at least Seeker, one keyword-conditioned perk multiplies the fifteen focused blessing spells' numeric magnitudes by `1.20`. A separate Active Effects marker explains the increase. The five old phase-stat spells and the presiding-deity piety multiplier remain inert and are removed during reconciliation.

**Automatic patron emergence (LOCKED, updated 2026-08-06):** Khajiit remain a no-offer race in 1.0. Focused deity emphasis is assigned as soon as behavior and piety qualify. The first focus shows one deity-specific ceremonial MessageBox plus Prisma toast and pinned Book entry; later reorientations use toast and Book entry without another popup. No confirmation choice or asynchronous result channel is used.

**Focused-emphasis state (LOCKED):** Do not use `PDV_GLO_PatronState = active primary` to represent Khajiit focus. Add a Khajiit-specific current emphasis state, recommended as `PDV_State_KhajiitFocusedEmphasis`, with a CK-readable mirror only if implementation needs conditions. This tracks the leading deity emphasis without pretending a formal commitment offer occurred.

**Focused-emphasis enum (LOCKED):** `PDV_State_KhajiitFocusedEmphasis` uses `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, and `Alkosh = 5`. `None` means broad lunar worship, not failure.

**Focused-emphasis threshold (LOCKED, updated 2026-08-06):** Focus activates when one deity has at least `25` focus weight, leads the next-highest focus weight by at least `15`, and has actual piety `25` or higher. Evaluation follows both weight and piety updates. Once established, ties, insufficient leads, or piety loss do not reset the focus to broad; only another deity satisfying the complete test replaces it.

**Broad pre-focus state (LOCKED):** Before any deity first satisfies the complete dominance test, `None` is the valid broad Lunar Lattice state. After focus emerges, broad is not a fallback state.

**Road home (LOCKED, supersedes the 2026-06-10 circuit):** Any completed
outdoor rest is authentic road-home practice. The road itself is home; 1.0 has
no designated anchor, circuit, elapsed-distance requirement, or repeated-place
rejection. Generic inn and house sleep do not qualify.

**Lunar posture enum (LOCKED):** Add `PDV_State_KhajiitLunarPosture` for curse and shadow pressure, with exact values `Normal = 0`, `Strained = 1`, `Corrupted = 2`, and `ShadowDrift = 3`.

**Vampire posture (LOCKED):** Active vampirism sets lunar posture to `Corrupted`. The Lattice still holds the character, but community belonging, caravan trust, and ordinary moon-life rewards are weakened. Vampirism does not automatically turn the character into a Nocturnal devotee.

**Werewolf posture (LOCKED):** Active lycanthropy sets lunar posture to `Strained`. Hircine adds a competing shape, but Khajiit identity remains recognizably Khajiit. Werewolf pressure should feel uncomfortable and socially costly, not spiritually erased.

**ShadowDrift boundary (LOCKED):** `ShadowDrift` is reserved for dominant shadow-pattern behavior: Nocturnal alignment, active vampire posture plus repeated night-only predation, or other explicitly shadow-coded behavior. Do not enter `ShadowDrift` from ordinary night travel, stealth, or lunar observance.

**Launch focused paths (LOCKED):** All five focused emphases are valid for 1.0: `Khenarthi`, `Azurah`, `Baan Dar`, `Rajhin`, and `Alkosh`. `Khenarthi` and `Azurah` are the most routinely reachable, `Baan Dar` and `Rajhin` are behavior-specific, and `Alkosh` is rare/high-threshold by design.

## Historical pre-2026-08-06 reward notes (superseded)

The reward concepts and numbers below are retained only as design history. They
must not be used for implementation, UI copy, or balance decisions; the
2026-08-06 rebalance section and live record specs above are authoritative.

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

- Stamina regen +5% at night (Khenarthi's road-breath)
- Resist disease 15% (caravan life's practical grace — Khajiit in Skyrim are resilient)
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

**Khenarthi Champion — "Khenarthi's Wind" (LOCKED per capstone signatures 2026-06-07):**
- *Passive (stat):* Stamina regen +10%, Carry Weight +50, Speed +3 (`PDV_Bless_Khajiit_Khenarthi_T3`, shipped).
- *Signature (M8):* sprinting costs little/no stamina, plus an out-of-combat travel-speed ramp the longer you move uninterrupted ("the wind at your back"), bleeding off in combat or at rest.
- *Flavor payoffs:* caravan recognition response; outdoor sleep restores health and stamina; helping a stranded or lost NPC generates strong piety.
- *Lore rationale:* Khenarthi is wind, weather, and passage — the god of the road Khajiit are forced to live. At Champion, the road itself becomes an ally.

**Azurah Champion — "Azurah's Sight" (LOCKED per capstone signatures 2026-06-07):**
- *Passive (stat):* Magicka regen +10%, Magic Resist +10% (`PDV_Bless_Khajiit_Azura_T3`, shipped).
- *Signature (M9):* at night, magicka surges and you sense living things (detect-life aura); once in a while Azurah's foresight turns a spell that would have hit you (magic-ward proc).
- *Flavor payoffs:* threshold moments (significant dungeons, major quests, defining choices) give brief Azurah-voiced flavor text; Azurah's Star quest gives maximum recognition and the strongest single Khajiit piety event.
- *Lore rationale:* Azurah shaped the Khajiit and guards their passage through thresholds — including the big ones. At Champion, she's watching your thresholds.

**Baan Dar Champion — "Baan Dar's Luck" (LOCKED per capstone signatures 2026-06-07):**
- *Passive (stat):* Armor +15, Health regen +15%, Unarmed Damage +10 (`PDV_Bless_Khajiit_BaanDar_T3`, shipped; the survivor-brawler clawed build).
- *Signature (M6, once per 24 hours per the all-once/day cheat-death rule):* a killing blow is survived — you vanish briefly (escape), the attacker staggers, and a lingering luck streak (sneak/crit) pulses for a while after it fires. The pulse hits only when the save is actually used.
- *Flavor payoffs:* outside-walls piety edge continues; exile survival and clever-reversal quest choices generate strong piety.
- *Lore rationale:* Baan Dar is the god of pariahs, clever exiles, and reversals. At Champion, the improbable reversal is your story — and the god of that story occasionally writes a scene on your behalf.

**Rajhin Champion — "Rajhin's Shadow" (LOCKED per capstone signatures 2026-06-07):**
- *Passive (stat):* Sneak +12, Lockpicking +15, Pickpocket +15, Unarmed Damage +10 (`PDV_Bless_Khajiit_Rajhin_T3`, shipped; the clawed-thief build).
- *Signature (M10):* a successful steal or sneak-attack briefly fades you (slip away) and shadows cloak you (sneak muffle); fallback trigger is the sneak attack if pickpocket-success detection is unreliable.
- *Flavor payoffs:* theft from "impossible" targets generates maximum Rajhin piety; story-worthy/legendary thefts give very strong piety; performance acts earn artistry recognition.
- *Lore rationale:* Rajhin is the greatest thief who ever lived, who wore Mephala's ring and stole from the Emperor. At Champion, you're a character in a story about theft — and the story has a patron.

**Alkosh Champion — "Alkosh's Roar" (LOCKED per capstone signatures 2026-06-07):**
- *Passive (stat):* Fire Resist +12, Magic Resist +15 (`PDV_Bless_Khajiit_Alkosh_T3`, shipped; the +15 is a documented capstone exception above the ~12 ceiling).
- *Signature (M11):* bonus damage and breath resistance against dragons and great chaotic foes; once a day, the Roar staggers and slows nearby enemies (order imposed on chaos).
- *Flavor payoffs:* named-dragon fights generate exceptional piety (their natural scarcity is the anti-farm); anti-chaos and order-keeping quest choices generate strong piety.
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
| Lunar observance / moon-phase awareness | `ObserveMoonPhase`, dawn/dusk/night outdoor checks, `LastPhase`, `ObservanceCount`, real 24-day engine cycle via `GameDaysPassed % 24` | Strong (deterministic engine formula) | Phase replicates the Creation Kit GetCurrentMoonphase boundaries, so it matches the visible sky. Small phase bonuses only. |
| Open road / Khenarthi | Sleep event, outdoor rest, location-change over time, no-fast-travel validation, open-sky checks | Medium-strong | Good launch lane. Cap daily and present as road-life continuity, not travel grinding. |
| Outdoor road-home rest | Completed outdoor rest, origin and devotional-day validation | Existing sleep completion route | No anchor or circuit state; first approved cultural act of the day claims +4. |
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
- Automatic patron emergence: Cost Class B (event-ordered evaluation of focus weight, lead, and actual piety)
- Road-travel detection (non-fast-travel): Cost Class C (requires location-change time tracking)

---

## Variety Tranche — Focus Distinctness Addendum (DESIGN-LOCKED 2026-06-12)

Roadmap source: `references/authoring/PDV_RaceVarietyTranche_Roadmap.md`.
The Lunar Lattice closed the substrate gap; this small addendum answers the
remaining balance-audit risk ("Khenarthi/Azurah crowd out Baan Dar, Rajhin,
and Alkosh") with three focus-gated signatures. No new substrate, place,
pilgrimage, or rite work -- outdoor road-home practice already owns those jobs.
Magnitudes tunable; gates and caps locked. Effect families remain blocked
behind the race row in `PDV_RaceEffectReviewLedger.md`.

- `Rajhin's Borrowed Moment` (Rajhin focus, once/day): a successful
  pickpocket of a notable target grants a brief sneak pulse.
- `Baan Dar's Improvisation` (Baan Dar focus, once/day): surviving combat
  that started while outnumbered 3+ grants a brief stamina pulse (pariah
  luck texture). Cross-race note: Bosmer Bandit Road carries a
  trigger-distinct Baan Dar signature (`Baan Dar Opens the Gap`,
  escape-below-20%-health); both are intentional and documented in the
  roadmap's resolved decisions.
- `Alkosh's Long Breath` (Alkosh focus, rare): dragon kills grant a Marked
  time-flavor line and a small pulse; naturally scarce, no cap needed
  beyond the encounter rate.

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
