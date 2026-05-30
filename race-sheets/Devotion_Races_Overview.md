# Devotion — Race Guide

**What is Devotion?**

Devotion is a mod that makes your character's religious life feel real. The gods of Tamriel aren't just statues you click for a buff — they're forces that notice how you live. Your race determines which gods are part of your world, how worship works, and what it costs to stray.

Every race has a different relationship with the divine. A Nord earns the attention of their gods through deeds. A Khajiit is born inside a cosmic order they can never fully leave. An Orc carries one god's code across every possible life. These aren't cosmetic differences — they shape what your character does, what rewards they earn, and what happens when they make hard choices.

---

## How Devotion Works (All Races)

**Your standing with the divine rises and falls based on how you live.** The mod watches for meaningful actions — quest choices, faction milestones, lifestyle patterns, shrine visits, and combat conduct — and adjusts your devotion accordingly. At dawn each day, your actions are weighed and your standing shifts.

**Five tiers of devotion:**

| Tier | Name | What it means |
|------|------|---------------|
| 5 | **Devoted** | The gods know your name. Rarest rewards, strongest identity. |
| 4 | **Faithful** | A stable, recognized relationship. Main blessing tier. |
| 3 | **Observant** | Sincere alignment. Small blessings, first recognition. |
| 2 | **Wavering** | Drift. The connection is loosening. |
| 1 | **Distant** | Silence. The divine is far away. |

**Broad vs. Focused worship:** Some races with pantheons can worship broadly — honoring many gods at once. Where this is culturally normal, it caps your potential at Faithful and is not empty or failed worship. For some races, especially Nords, broad worship is its own devotional lane with blended favors. To reach Devoted, you must commit to a primary deity. This isn't an MCM toggle — it's a theological act, usually triggered when your actions reveal which god has truly noticed you.

**Patron commitment usually comes from the god.** For most races, a deity reaches out once your behavior has crossed a meaningful threshold. You can accept, delay, or refuse. Khajiit are the exception: they never get a formal offer, because their strongest deity emphasis emerges silently from how they live under the moons.

**The gods notice repetition.** Doing the same thing over and over doesn't impress the divine. Devotion rewards meaningful, varied action — not grinding.

**Rewards come in layers:**
- **Baseline blessings** — Modest, steady, always-on signs that devotion matters
- **Contextual favors** — Automatic, temporary help when your current god, path, or layer recognizes a fitting act
- **Religious privileges** — Access, recognition, special interactions, shrine options
- **Neglect effects** — What you lose when you drift away
- **Restoration paths** — How you recover from major spiritual rupture

Some races also have a persistent cultural substrate underneath deity devotion: Khajiit moon-cycle observance and road homes, Argonian Hist/community maintenance, Dunmer portable ancestor practice, and Orc community-building all reward continuity rather than single dramatic acts.

Dunmer are the special case inside broad/focused language. Their shared ancestor + Good Daedra layer can answer with contextual favor before a primary focus, but it presents as cumulative Reclamation practice rather than generic pantheon worship.

Dunmer contextual-favor review cleared on 2026-05-18. The experience shape is shared ancestor/Reclamations favor first, then distinct Azura, Boethiah, and Mephala focused lanes with anti-generic boundaries.

Daedric coverage is Prince-first. `references/phase4/PDV_DaedricRacePrinceMatrix.csv` is the canonical implementation matrix; each race sheet carries a readable treatment map for all sixteen vanilla Skyrim-facing Prince surfaces. Fifteen have normal Daedric quest/artifact routes; Nocturnal is the Thieves Guild / Nightingale exception, and the Skeleton Key does not count toward vanilla Oblivion Walker. Jyggalag remains out of scope unless future Creation Club or Sheogorath/Jyggalag content is explicitly adopted.

For implementation, the race sheets are context rather than data shape. Each built Daedric slice should be expanded from the matrix into the locked architecture fields: surface type, response state, commitment signal, temptation pressure, boon, price, stigma, faith friction, hook priority, buildability tag, exit route, residue, and player feedback.

Implementation hook feasibility is now recorded for all ten races. Redguard is implementation-locked for 1.0 at the state, offer, sect-switch, and launch-hook-posture level. Breton is implementation-locked at the tradition setup, all-three-track memory, normal no-switching rule, hook feasibility, dawn math, recovery cadence, Hidden Art cover/notoriety split, and tradition-authored contextual favor level. Dunmer is implementation-locked at the ancestor substrate, focus-gate, curse-posture, portable-shrine, and Daedric-deviation option-map level. Khajiit is implementation-locked at the lunar substrate, silent focused-emphasis, road-home circuit, curse posture, ShadowDrift boundary, five launch paths, and launch-hook-posture level. Argonian is implementation-locked at the single layered Hist substrate, visible Hist/People/Void readout, gentle Hist distance, one bed-of-choice anchor, Sithis activation threshold, and curse posture level. Altmer is implementation-locked as of 2026-05-30 at the crisis, contextual-favor, focused-deity hook, Lorkhan pressure, and rejected-surface level. Bosmer and Orc remain implementation-locked at experience shape while final hook-costing stays tunable.

---

## Race Classification

Not every race worships the same way. The mod recognizes three fundamental structures:

### Pantheon Races (choose your god from many)
| Race | Pantheon | Flavor |
|------|----------|--------|
| Nord | Old Ways + Nine Divines | Your deeds reveal which god notices you |
| Imperial | Nine Divines | Civic faith shaped by politics and conscience |
| Breton | Three-Track (Knight / Druid / Witch) | Tradition defines identity; gods flavor it |
| Dunmer | Good Daedra + Ancestors | Cumulative layers, never competing gods |
| Altmer | Aldmeri Pantheon | Self-cultivation judged by coherence and orthodoxy |
| Redguard | Yokudan Pantheon | Sect-shaped, duty-driven, ancestors always present |

### Closed-System Races (one god, one truth)
| Race | Core | Flavor |
|------|------|--------|
| Orc | Malacath | One god, three ways to carry the code |
| Bosmer | Y'ffre / Green Pact | Four distinct paths within one covenant |

### Layered Races (cosmological identity, not choice)
| Race | Structure | Flavor |
|------|-----------|--------|
| Khajiit | Lunar Lattice | Born inside a cosmic order; deepen within it |
| Argonian | Hist + Community + Sithis | Exile spirituality; maintaining connection across distance |

---

**Orc contextual favor note:** Orcs do not get a generic Malacath favor lane. Their contextual favors follow current life-mode: Stronghold, City, or Legion/Exile. Implementation uses one active state track: `City = 0`, `Stronghold = 1`, `LegionExile = 2`. City is the default bridge state; Stronghold requires Blood-Kin or equivalent acceptance plus active stronghold conduct; Legion/Exile requires explicit service/exile commitment or completed pressure-bearing service. Setup/MCM records intent, but the world confirms the active lane. City and Legion/Exile dignity, oath, and self-made community moments use curated hooks or `PDV_SacredPlace` state only, since broad social simulation is too brittle for launch design.

---

## Curse States

Becoming a vampire or werewolf is never neutral. Every race treats these curses differently:

- Some races lose their divine connection entirely (Altmer werewolf, Redguard vampire)
- Some find damaged but functional alternatives (Dunmer vampire can still reach the Good Daedra)
- Some have unique theological forks (Breton werewolf triggers a genuine religious choice)
- Some rebuild through cultural maintenance rather than a god offer (Argonian bed-of-choice, Khajiit road homes, Orc self-made community)
- No race treats either curse as a free positive — it always costs something

---

## Reading the Race Sheets

Each race has its own document. They're designed to be read independently — pick the race that interests you. Each one covers:

1. Who they worship and why
2. How the devotion system works for them specifically
3. What paths or choices are available
4. How Daedric princes interact with their faith
5. What happens under curse states
6. What playing this race *feels* like

When a race sheet defines contextual favors, it should use the shared table shape: `Lane`, `Trigger family`, `Hook candidates`, `Favor bucket`, `Surfacing`, and `Notes`. This keeps the player experience comparable across races while still letting each theology feel specific.

The table rollout was pilot-first. Nord, Imperial, and Redguard cleared cross-pilot review on 2026-05-18, so the table shape can now be propagated to every race sheet.

Pilot tables can live directly in race sheets. Cleared pilot rows remain race-sheet content; architecture owns the shared shape and rules, not every race-specific row.

For the cleared pilot, broad-worship lanes came first and focused deity examples stayed as short contrast notes. Full focused-deity tables can now be drafted after broad-lane coverage is in place.

---

*Individual race sheets: Nord, Imperial, Breton, Dunmer, Altmer, Bosmer, Khajiit, Redguard, Orc, Argonian*
