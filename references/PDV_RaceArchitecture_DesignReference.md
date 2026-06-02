# PlayerDevotion (PDV) — Race Architecture Design Reference
**Started:** May 12, 2026
**Last updated:** May 26, 2026 (Phase 13-16 closure defaults synced)
**Status:** Living reference — race architecture and pre-matrix requirements locked as confirmed

**Current implementation boundary:** Early sections of this reference were
originally written against the removed v1 bucket model. The active
implementation is the v2/v3 model: per-deity StorageUtil piety, daily scratch
in `PDV.PietyToday`, the `PDV.Tier` 0-3 spine, explicit patron state,
reputation/state tracks, and origin-gated substrates where needed. Treat any
remaining `Combat/Social/Lifestyle` wording in older per-race notes as
domain-signal shorthand, not as a request to restore bucket records or
`PDV_GLO_DevotionLevel`.

---

## SECTION 1: Core Assumptions (ALL LOCKED)

### 1.1 Race Selection is Permanent
- Players choose race at character creation
- Mid-game race changes via showracemenu are unsupported
- No cross-race state migration needed
- Allows complete isolation of race modules
- Vanilla vampire races are normalized to the underlying birth race for origin detection
- Temporary beast-form races defer one-shot origin detection rather than becoming a new origin

### 1.2 Curse States Modify Scoring Weights, Not Signal Ownership
- Werewolf/Vampire changes HOW the same devotion is interpreted
- Per-deity piety persists across curse states
- Curse states never move an event into a different theology; they change magnitude, eligibility, and interpretation
- v3 owns this through `PDV_CurseState` plus race/deity modifier tables
- Detection should be centralized so deity scripts read one current curse state

### 1.2a Phase 13-16 closure defaults
- Daedric paths stay on a separate operational roster from `PDV_FLST_AllDeities`
- The first full Daedric completion target is `Hircine + Nord`
- Daedric recovery is mixed by default: cure/renounce starts recovery, rites accelerate or complete it
- Canonical Prince-vs-Prince hostility uses reduced rivalry math, not full-strength cancellation and not stigma-only handling
- `PDV_CurseState` remains the single curse seam for both werewolf and vampire live behavior
- Werewolf detection should be combined: active beast-race plus afflicted-state / faction / quest-style evidence

Runtime status update (2026-05-28):
- Phase 13 is runtime-proven on the Hircine/Nord pilot: early hunt rites prove the negative gate, the multi-day rite cadence proves Seeker and Devoted price activation, werewolf curse-entry raises Hircine pressure, cure and renounce both start residue recovery, and vampire remains the negative path.
- Phase 14 is runtime-proven on the Kyne commitment pilot.
- Phase 15 is runtime-proven on the shared curse seam.
- Phase 16 is runtime-proven on the Kyne neglect pilot.
- Durable Hircine lesson: same-day hunt rites are anti-repeat-scaled before stigma or piety is applied, so counted Seeker proof requires one rite on each of three in-game days.

### 1.3 Event Granularity is Simple (for now)
- Events are simple integers: `EVENT_COMBAT_WIN`, `EVENT_SHRINE_VISIT`, etc.
- No semantic splitting required (validated against all lore sources)
- Safe to add granularity later per-event without refactoring the system
- Old saves with generic events still parse when granular events are added later

### 1.4 Domain Signal Axes Are Shared, Race Meaning Is Specific
- The old `CombatBucket`, `SocialBucket`, and `LifestyleBucket` records are removed
- Design may still group signals as combat, social, lifestyle, devotional, craft, faction/quest, curse, or Daedric for readability
- Each race/deity/path interprets those signal families differently
- Bosmer Old Contract and Argonian Hist/community/Sithis require custom interpretation, but not custom bucket records
- Comments in scoring functions must document WHY each signal matters theologically

---

## SECTION 2: System Architecture (LOCKED BASELINE, v3-ALIGNED)

### 2.1 Module Structure

```text
PlayerDevotion_Framework.esp
├── PDV__MainQuest
│   └── RunOnce bootstrap, calls PDV_Origin.InitializeOrigin()
├── PDV_Origin
│   └── Detects birth race, normalizes vanilla vampire races, defers beast forms
├── PDV__ManagerQuest
│   ├── Owns StorageUtil piety/tier helpers and patron state
│   ├── Consolidates PDV.PietyToday at dawn
│   ├── Runs named v3 dawn slots for decay, spell/neglect, offers, and notification
│   └── Refreshes active-patron mirror globals for CK conditions
├── PDV_EventTypes / PDV_EventBus
│   └── Central event IDs, attribution, and validated signal fan-out
├── PDV_Deity_<Name> quests
│   └── Persistent worship targets with race stance, scoring, rivalry, and boons
├── v3 track quests
│   ├── PDV_RepTrack_<Name> for continuous social/theological pressure
│   └── PDV_State_<Name> for categorical path/mode/tradition state
└── v3 substrate quests
    └── Origin-gated identity layers for Dunmer, Khajiit, and Argonian
```

### 2.2 Event System: Hybrid (Events + Daily Audit)

**Throughout the day:**
- Story Manager receivers, player alias events, and curated CK fragments emit simple event IDs
- `PDV_EventBus` validates attribution and fans scoreable events to worship targets
- Runtime events write only `PDV.PietyToday` or track/substrate scratch state

**At dawn (ProcessDawn):**
- Consolidate daily scratch to persistent piety, clamped to plus/minus 5 per deity
- Apply v3 slots in order: decay, spell/neglect sync, commitment offers, notification
- Recompute `PDV.Tier`, refresh active-patron mirrors, and clear scratch state

### 2.3 Processing: Central Gain Pipeline With Optional Modifiers

```papyrus
Float Function GetEffectiveGainMultiplier(PDV_DeityBase deity)
    Float stanceMult = deity.GetGainMultiplier(deity.GetStanceForPlayer())
    Float trackMult = GetReputationModifierOrDefault(deity)
    Float curseMult = GetCurseModifierOrDefault(deity)
    Float stigmaMult = GetDaedricStigmaModifierOrDefault(deity)
    return stanceMult * trackMult * curseMult * stigmaMult
EndFunction
```

The v3 Preflight manager already has no-op slots for these modifiers. Later
phases replace no-ops with concrete track, curse, and Daedric path readers
without changing event receivers or deity scoring signatures.

### 2.4 Public Bands vs Internal Tier Spine

| Public band | Internal meaning |
|-------|-----------|
| Devoted | `PDV.Tier == 3` |
| Faithful | `PDV.Tier == 2` |
| Observant | `PDV.Tier == 1` |
| Wavering | Presentation band below active tier |
| Distant | Presentation band below active tier |

The race sheets use five player-facing bands, but the implementation keeps the
v2 `PDV.Tier` 0-3 storage spine. Do not add new tier globals or resurrect
`PDV_GLO_DevotionLevel` to represent the two below-tier bands.

---

## SECTION 3: Worship Structure (LOCKED)

### 3.1 Mono vs Poly vs Semi-Mono Classification

**MONO — Single deity or closed cosmological system:**
Broad worship is theologically incoherent. Setup choice is depth/interpretation, not which god.

| Race | Core Deity/System | Why Mono |
|------|------------------|----------|
| Argonian | Hist + Sithis | Hist is constitutive of their being. Closed cosmological system. |
| Khajiit | Lunar Lattice (Azurah, Khenarthi, Lorkhaj) | The moons determine what you ARE biologically. Not interchangeable. |
| Orc | Malacath only | The spurned god of the spurned people. Aedric worship alongside him is incoherent. |
| Bosmer (orthodox) | Y'ffre / Green Pact | A covenant made specifically with the Bosmer. Not a choice — a contract. |

**POLY — Pantheon worship is native and expected:**
Multiple worship targets are culturally available. Broad-worship lane eligibility is narrower and defined below.

| Race | Pantheon | Notes |
|------|----------|-------|
| Nord | Old Ways + Nine Divines | Two full pantheons blend in practice simultaneously |
| Imperial | Nine Divines | Different gods for different professions and life events |
| Breton | Divines + Druidic + Witchcraft | Pragmatic syncretism is literally their tagline |
| Dunmer | Three Good Daedra + Ancestral spirits | Multi-deity by design; ancestors mediate all practice |
| Redguard | Yokudan pantheon | Tall Papa, Tu'whacca, Leki, Onsi, HoonDing — each covers specific domain |
| Altmer | Aldmeri pantheon | Auri-El, Magnus, Phynaster, Syrabane, Xarxes — self-cultivation draws from all |

**SEMI-MONO — Cultural default with meaningful lore-grounded alternatives:**

| Race | Default | Alternatives |
|------|---------|-------------|
| Bosmer (moderate) | Y'ffre (storyteller aspect) | Nocturnal (Thieves Guild), Z'en/Zenithar (merchant) |
| Dunmer | Ancestral / Good Daedra | Tribunal memory, Azura as primary |

### 3.2 Dilution System for Poly Races (LOCKED)

**Broad-worship lane eligibility:**

Broad-worship lanes exist only where culturally normal and experientially useful, not for every race with multiple worship targets. The Poly classification above means "multiple worship targets exist," not "generic whole-pantheon worship is always the active lane."

| Race | Broad-worship lane? | Reason |
|---|---|---|
| Nord | Yes | Whole-pantheon reverence is culturally normal; breadth should feel complete |
| Imperial | Yes | Civic Nine Divines worship is institutional and profession/life-event shaped |
| Redguard | Yes, sect-shaped | Yokudan worship is broad inside Crown / Forebear / Ash'abah framing |
| Dunmer | Special layered equivalent | Ancestors + Good Daedra are cumulative layers, not casual pantheon breadth |
| Breton | No generic broad lane | The tradition choice is the real lane; god choice flavors that tradition |
| Altmer | No generic broad lane | Coherence, faction alignment, and Lorkhan pressure matter more than casual breadth |
| Khajiit | No | Lunar substrate and emergent patron emphasis replace broad pantheon worship |
| Bosmer | No | Path choice defines the theology |
| Orc | No | Malacath-centered modes, not multiple gods |
| Argonian | No | Hist/community/Sithis exile architecture, not pantheon worship |

**Broad worship (no primary god chosen):**
- Signals can contribute to multiple deity relationships, but gains are dampened
- Maximum devotion cap defaults to Tier 2 / Faithful for 1.0
- Broad worship has its own reward vocabulary, especially Nord combo/contextual favors
- Broad worship counts as its own devotional lane for contextual favor authoring
- Broad-worship favors are blended across the pantheon, capped at Faithful, and should be softer / less specific than focused patron favors
- Represents: "acknowledged by the gods, beloved by none specifically"

**Primary god chosen:**
- The foreground patron receives normal scoring and full boon eligibility
- Background deity relationships may continue accumulating piety, subject to race/state filters
- Maximum daily shift = +5 (full ceiling)
- All three blessing tiers available (up to Devoted)
- Represents: "this god knows your name"

**Switching from broad to primary:**
- The accepted deity carries forward 70% of current piety into foreground commitment handling
- Weights immediately shift to primary-focused
- Switching requires a threshold offer/event; it is not a normal player MCM toggle
- Rationale: committing to a primary deity is a theological act, not a preference setting

**Resolved by Section 12 and v3:** broad worship defaults to Tier 2 for 1.0;
non-Khajiit races use commitment offers; Khajiit uses silent emergent patron
weighting instead of formal offers.

---

## SECTION 4: Race-Specific Architecture (LOCKED SUMMARY)

### 4.1 Race Status Overview

| Race | Worship Type | Special v3 Architecture | Setup / Commitment Shape | Status |
|------|-------------|-------------------------|--------------------------|--------|
| Nord | Poly | Broad-worship combos; possible substrate promotion after playtest | Broad vs Primary, Old Ways / Nine Divines | LOCKED |
| Imperial | Poly | `ConcordatStanding` reputation track | Broad vs Primary with public/private Talos pressure | LOCKED |
| Breton | Three-Track Poly | `WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding` | Tradition-first: Knight / Hidden Art / Green Way | LOCKED |
| Dunmer | Layered | Strong ancestor substrate plus Good Daedra foreground | No setup choice; portable shrine and home bonus | LOCKED |
| Altmer | Poly | `ThalmorAlignment`, Lorkhan reactions, crisis state | Faction/theological identity and threshold offers | LOCKED |
| Khajiit | Layered Lunar | Strong lunar substrate, moon cycle, road homes, emergent patron | No formal setup; behavior shifts emphasis silently | LOCKED |
| Bosmer | Multi-Path | `BosmerPath` state track and PDV-owned Green Pact tagging | Explicit 4-path choice at setup | LOCKED |
| Redguard | Sect-Layered Poly | Sect state; light ancestor reverence | Crown vs Forebear vs Ash'abah | LOCKED |
| Orc | Single-Core Social Modes | `OrcLifeMode` state and `PDV_SacredPlace` contextual modifier | Malacath across Stronghold / City / Exile | LOCKED |
| Argonian | Layered Custom | Strong Hist substrate, community, Sithis pressure | Hist / Collective / Sithis exile architecture | LOCKED |

### 4.1a Implementation Lock Audit (2026-05-19)

This audit separates **architecture locked** from **implementation-spec locked**. Every race has a locked 1.0 architecture. A race is implementation-spec locked only when its launch state tracks, setup/default rules, switch or commitment gates, fallback behavior, and major unresolved value deferrals are documented tightly enough for later build work.

| Race | Implementation-lock status | Locked enough to build? | Remaining implementation decisions |
|---|---|---|---|
| Nord | Locked | Yes | `PDV_State_NordPantheonBaseline` is split from patron state; dawn offer evaluation, per-deity decline cooldowns, accepted-patron stability, Faithful offer threshold, and recomputed offer candidates are locked |
| Imperial | Locked | Yes | Shared patron state, global offer gate, Concordat offer filters, Talos rupture acceptance, civic amplification, and Enforcer damping are locked |
| Breton | Locked | Yes | Explicit tradition setup, all three state tracks, normal no-switching rule, hook feasibility, dawn math, recovery cadence, threshold values, Hidden Art cover/notoriety split, and tradition-authored favor lanes are locked; reward magnitudes remain tunable |
| Dunmer | Locked | Yes | No `PDV_State_DunmerPath`; shared patron state owns native focus, `PDV_Substrate_DunmerAncestor` owns the ancestor substrate, `PDV_State_DunmerAncestorPosture` owns curse/restoration posture, and the Dunmer Daedric deviation option map is locked |
| Altmer | Locked | Yes | `ThalmorAlignment` bands/start values, shared patron-state use, no generic broad lane, bounded Lorkhan economy, `PDV_State_AltmerCrisis`, crisis source/resolution routes, contextual favor lanes, and launch-focused deity hook posture are locked |
| Khajiit | Locked | Yes | Lunar substrate namespace, hybrid moon-cycle model, real/fallback phase source, silent no-offer emergence, focused-emphasis enum/threshold/fallback, road-home circuit rules, lunar posture enum, curse posture, ShadowDrift boundary, five launch focused paths, and launch hook posture are locked |
| Bosmer | Locked | Yes | Path enum, Old Contract split, Living Story fallback, shared Pact-positive signal weighting, path-switch request shape, destination gates, ledger preservation, and seven-day switch lockout are locked |
| Redguard | Locked | Yes | `PDV_State_RedguardSect`, setup/default, ancestor layer posture, sect switching, broad -> focused offer gate, Dunmer-pattern portable/private Tu'whacca shrine, HoonDing 1.0 milestone posture, MS08 stage hooks, and launch hook posture are locked; Ash'abah social stigma is limited to light authored 1.0 content |
| Orc | Locked | Yes | `PDV_State_OrcLifeMode` is locked as `City = 0`, `Stronghold = 1`, `LegionExile = 2`; setup/MCM records intent; active lane is world-confirmed; soft and major switch gates are defined |
| Argonian | Locked | Yes | `PDV_Substrate_ArgonianHist`, visible `Hist` / `People` / `Void` layers, StorageUtil keys, gentle Hist distance, single bed-of-choice cadence, Sithis activation threshold, and curse posture enum are locked |

**Remaining implementation-lock priority recommendation:**
All ten races are implementation-spec locked as of the 2026-05-30 Altmer closeout. The next priority is implementation costing and verifier assertion design, not further architecture lock work.

Do not mark this audit as complete by changing the top-level race `LOCKED` status. Top-level `LOCKED` means architecture locked. Implementation lock should be advanced race by race as the exact state-track and substrate contracts are ratified.

**Shared patron-state implementation rule (LOCKED 2026-05-19):**
Do not create race-specific state tracks whose only job is `Broad` vs `Primary`. Formal patron/deity commitment uses the shared patron state model: `PDV_GLO_PatronState` for unset / broad worship / active primary, and `PDV_GLO_PatronDeity` for the accepted patron. Race-specific state tracks are reserved for orthogonal identity axes such as pantheon baseline, sect, tradition, life-mode, crisis state, substrate posture, or reputation state. This applies to Nord and Imperial immediately, and should be presumed for Redguard, Breton, Dunmer, Altmer, or any later formal-offer race unless a race-specific exception is explicitly documented. Khajiit remain the no-formal-offer exception.

### 4.2 Bosmer (LOCKED)

**Setup model confirmed:** Explicit player choice at first run (MCM or first-run quest)

**Four devotional paths identified from lore:**

| Path | Deity | Lore Source | Signal / Track Focus |
|------|-------|-------------|-------------|
| The Old Contract | Y'ffre Orthodox | Hunter/Ranger class, Green Pact | PDV-owned Green Pact tags + hunting conduct |
| The Living Story | Y'ffre Moderate | Scholar/Archer class, oral tradition | Story, memory, community, daily conduct |
| The Exchange | Z'en | Justice, balance, owed repayment | Justice, mercy, debt, proportional retaliation |
| The Bandit Road | Baan Dar | Exile survival, trickster road-life | Survival, stealth, trickster aid, road life |

**Secondary Bosmer religious layer (LOCKED):**
- `Arkay`
- `Xarxes`
- `Mara`
- `Stendarr`

**External pressures, not standard core paths (LOCKED):**
- `Hircine`
- `Nocturnal`

**Path architecture notes (LOCKED):**
- The “classes” used in source discussion are explanatory only, not selectable player archetypes
- `The Old Contract` is the only Bosmer path with hard or semi-hard Green Pact compliance mechanics
- `The Living Story`, `The Exchange`, and `The Bandit Road` do not check strict Pact behavior directly
- `The Old Contract` has a higher devotion ceiling than the other Bosmer paths as payoff for its added burden
- Bosmer path switching is limited, not free and not fully permanent
- Switching rules are destination-sensitive:
  - `The Living Story` is the easiest bridge path
  - `The Old Contract` is the hardest to re-enter cleanly
  - `The Exchange` and `The Bandit Road` sit between those poles

**Old Contract = binary `PactBound` state (LOCKED 2026-05-17):**
- `The Old Contract` is governed by a binary `PactBound` flag, not a soft scale. While bound, Y'ffre is the exclusive deity and all other Bosmer-recognized deity ledgers freeze (preserved, inert).
- `GreenPactCompliance` is a 0–100 act-driven meter (no passive decay) that scales Y'ffre gains by band: Apostate (0–19) locked, Lapsed (20–49) 50%, Observant (50–79) 100%, Strict (80–100) 120%.
- Forced reckoning: sustained Apostate dwell (3 in-game days) fires a one-shot re-commit-or-renounce prompt. No silent auto-renunciation.
- Lifetime cap: `LapsedFromPact` counter permits exactly one re-entry. Second renunciation is terminal — Y'ffre ledger freezes permanently, MCM Pact toggle disables. Other Bosmer deities remain available.
- **No Wild Hunt player-facing track.** Wild Hunt is lore context only; never a state the mod surfaces to the player.
- Full transition spec, MCM surface, and storage layout: `references/PDV_BosmerPactModel_Planning.md`.

### 4.3 Argonian (LOCKED)

**Confirmed:** Custom interpretation required. Generic shared domain axes are insufficient.

**Theological foundation (UESP verified):**
- Argonians do not worship Aedra or Daedra — no "religion" as known elsewhere in Tamriel
- The Hist gives Argonians their souls at birth; souls return to Hist at death
- Sithis is the primordial void — acknowledged, not worshipped
- In Skyrim: no Hist trees, maintaining weakening connection through meditation + community

**Locked architecture:**
- `Hist relation` is the always-primary layer
- `Collective / community identity` is the second layer
- `Sithis acknowledgment` is the third layer

Rationale:
- These are not three equal gods or three equal scoring tracks
- The Hist remains constitutive even in absence
- Community acts as the main exile survival structure
- Sithis is culturally real and more foregrounded in Skyrim exile, but not equal to the Hist

**Implementation shape (LOCKED):**
- `Tier A`: vanilla-hook core
  - light Hist decay
  - community / Assemblage weighting
  - Dark Brotherhood / Sithis weighting
  - water / swamp / rest / reflection proxies
  - curse-state interaction
- `Tier B`: optional later enrichment
  - a small number of custom Argonian ritual hooks if the vanilla core proves too thin

Rationale:
- Argonians have rich lore but limited vanilla hook surface
- The core should be honest first, then enriched only where needed

---

## SECTION 5: Lore Validation (LOCKED)

### Sources Checked:
- `tamriel-daily-worship-4e201.html` — all 10 races, daily practices, class breakdowns
- `tamriel-cursed-worship-4e201.html` — vampirism and lycanthropy theological shifts
- `tamriel-daedric-worship-4e201.html` — all 15 Daedric prince devotional practices
- `references/skyrim-deity-reference.jsx` - cross-cultural deity equivalency table
- UESP Wiki: Argonian cosmology (Hist, Sithis, soul return, Varieties of Faith)

### Key Findings:
- No semantic granularity required at event level — confirmed across all races
- Curse states change theological weight, not signal ownership — confirmed
- Argonians are categorically different: no Aedra, no Daedra, closed cosmological system
- Bosmer Green Pact is a covenant, not a practice — compliance vs non-compliance is binary
- Khajiit Lunar Lattice is identity-constitutive, not merely devotional practice
- Dunmer Good Daedra (Azura, Boethiah, Mephala) have cultural protection in Skyrim
- Daedric worship note from source: "tracked separately from Nine Divines devotion — they are not competing on the same axis but on perpendicular ones"

---

## SECTION 6: Performance Profile (LOCKED)

| Aspect | Budget | Actual | Status |
|--------|--------|--------|--------|
| Active modules | 1 per player | 1 race quest | ✓ Trivial |
| Event array | Max 50/day | ~5–30 typical | ✓ Trivial |
| Memory per race | < 1KB | ~250 bytes | ✓ Negligible |
| ProcessDawn() | < 5ms | 50 iterations max | ✓ No concern |
| Papyrus stack | Safe | One quest, one interpreter | ✓ Safe |

---

## SECTION 7: Per-Race Grill Queue

### Global questions to resolve in each race session:
- G1: Does this race cap at Tier 1 or Tier 2 for broad worship?
- G2: What threshold event(s) allow choosing a primary god?
- G3: Which specific gods are available as primary choices for this race?
- G4: How do werewolf/vampire curse states shift weights for this race specifically?

### Race grill order:
1. Nord
2. Imperial
3. Breton
4. Dunmer
5. Altmer
6. Khajiit
7. Bosmer (resume)
8. Redguard
9. Orc
10. Argonian (dedicated session)

---

## SECTION 8: Implementation Carry-Forward (v3)

The old post-grilling checklist is superseded by `PDV_Architecture_v3.md`.
Carry these race-reference requirements forward into those phases:

- Structural Skeleton: scaffold first-release reputation tracks, state tracks, strong substrates, and sacred-place helpers while keeping unfinished content dev-only.
- Pattern Proving: prove Imperial Concordat, Bosmer Path, Dunmer Ancestor, Khajiit moon/emergent patron, one contextual favor family, one Daedric price/stigma path, one commitment offer, and one neglect/decay path.
- Signal expansion: map race-specific quest/faction choices as curated signals; ambient behavior remains slower background drift.
- Curse-state overlay: centralize Werewolf/Vampire state and compose modifiers with stance, reputation, and Daedric pressure.
- UI: surface public bands, current path/mode, patron state, and custom-race fallback without exposing old bucket language.
- Verification: add coverage for track globals, state labels, substrate origin gates, sacred-place records, visibility state, and hidden dev-only scaffolds.

---

## SECTION 9: Pre-Matrix Architectural Requirements (LOCKED)

These requirements govern the next race signal matrix. They define what each signal must feed, what the player should materially receive, and what runtime cost the system is allowed to carry.

### 9.1 Player-Facing Reward Contract

**Primary design goal:** immersive meaning first, mechanical progression second.

- PDV rewards should make the character's religious life feel materially present without becoming a dominant perk overhaul
- Baseline blessings should be modest and mostly support utility, survivability, roleplay, and narrow identity expression
- Some combat-facing power is allowed, especially when it is contextual rather than a large permanent stat increase
- Tier 3 should feel exceptional and may be unreachable in many ordinary playthroughs, especially on stricter paths
- PDV should not outcompete perk overhauls, standing stones, or major combat mods on raw numeric power

**Reward layers:**

| Layer | Purpose | Delivery |
|---|---|---|
| `Baseline blessing` | Dependable sign that devotion matters day to day | Passive, modest, tier-based |
| `Contextual favor` | Stronger momentary help when the right religious context is present | Passive conditional effect |
| `Religious privilege` | Access, recognition, restoration, or special interaction | CK conditions, dialogue, shrine options, ritual gates |
| `Neglect effect` | Thematic loss of relationship or mild spiritual drawback | Mostly loss of access; small drawbacks only where appropriate |
| `Restoration path` | Recovery from major rupture, curse, taboo drift, or re-entry | Threshold event, rite, cure, rededication, or quest-state gate |

**Tier jobs:**

- `Tier 1`: sincere alignment, small baseline blessing, first minor recognition
- `Tier 2`: stable relationship, main always-on blessing tier, broader contextual favor access
- `Tier 3`: exceptional devotion, rarest favors, strongest identity payoff, not mainly a raw stat spike

**Baseline blessings:**

- Cumulative across tiers
- At Tier 2, the player keeps Tier 1 and gains Tier 2
- At Tier 3, the player keeps Tier 1 and Tier 2 and gains Tier 3
- Each individual blessing must stay modest enough that the stack remains compatible with large modlists

**Contextual favors:**

- Automatic only; no hotbar powers, lesser powers, or activatable religion kit in the core design
- Temporary and signal-triggered; an authored preferred signal for the active patron, path, mode, or substrate may also start a favor
- Each devotional lane should generally use `3-5` trigger families, sourced from the same authored tables that decide what generates piety
- Only one contextual favor boost may be active on the player at a time, globally across PDV
- A favor may fire again after the current boost expires, but only when the player hits another qualifying preferred signal
- Similar favor mechanics may be shared across races or paths with different theological explanation wrappers
- Use family caps so overlapping favors from the same effect family do not stack into burst power

**Devotional lane counting rule:**

Favor counts are per active devotional lane, not per race. A lane may be a focused deity, path, mode, substrate layer, or broad-worship state depending on the race architecture. Broad worship therefore receives its own `3-5` blended favor trigger families, rather than inheriting every individual deity's favor set at once.

Broad-worship favor constraints:

- Capped at Faithful / Tier 2
- Built from blended pantheon meanings, not a pile of individual patron favors
- Softer or less specific than Devoted patron favors
- Still a complete, culturally normal experience for races where broad worship is normal

**One-active-boost cap:**

The cap is global across all PDV contextual favors, including temporary favors from substrates. A Khajiit lunar favor and Khenarthi road favor, for example, cannot both be active temporary boosts at the same time. Baseline blessings, low-power persistent substrate boons, religious privileges, neglect state changes, and restoration state changes are outside this cap unless they grant a temporary contextual favor.

**Marked-signal rule:**

Contextual favors are not restricted to simple positive piety events. A signal can trigger a favor when the authored matrix marks it as a preferred or meaningfully faithful moment for the current god/path/layer. This may include costly-but-faithful events such as defiance under Concordat pressure, re-commitment after rupture, cure-and-return rites, or choosing orthodoxy after a dissonant Altmer event. Pure penalties, failures, hostile-rival signals, and ordinary negative drift do not trigger favors unless an explicit restoration or recommitment signal is authored.

Implementation-facing matrix rows should carry an explicit `CanTriggerFavor` / `FavorFamily` decision rather than inferring favor eligibility from piety sign alone.

**Contextual favor duration buckets:**

| Bucket | Use for | Target duration |
|---|---|---|
| `Momentary combat favor` | Mercy, near-death, impossible odds, honorable kill, protecting someone | 30-90 seconds |
| `After-act favor` | Death rites, oath kept, caravan aid, meaningful quest beat | 2-4 in-game hours |
| `Environmental favor` | Storm, water, road, tomb, shrine, dawn/dusk, outdoor sleep aftermath | While the context is true or until the place/time window ends |
| `Rare major favor` | HoonDing make-way, Ash'abah major tomb cleansing, Baan Dar reversal, major patron recognition | 24 in-game hours |

Player-facing language should describe these as "for this fight," "for this journey," "while I am in the sacred context," or "until the next day," not as precise timer mechanics.

**Contextual favor surfacing:**

The shorter the favor, the quieter it should be. Most short combat favors should be felt through the effect itself rather than announced. Longer or rarer favors can be surfaced more clearly because they are less likely to spam the player.

| Surfacing level | Default bucket | Player feedback |
|---|---|---|
| `Quiet` | Momentary combat favor | No notification by default; effect icon or felt gameplay change only |
| `Noted` | After-act favor, environmental favor | Short notification when the context is meaningful and rare enough |
| `Marked` | Rare major favor, costly-but-faithful restoration/recommitment moments | Named notification or message; reserved for moments the player should remember |

Costly-but-faithful events may be surfaced one level higher than their duration bucket when the point of the event is that the character paid a real theological cost.

**Standard contextual-favor table shape:**

Each race sheet should express contextual favors with the same columns so lane-to-lane comparisons stay visible during the signal/reward pass:

| Column | Meaning |
|---|---|
| `Lane` | The active devotional lane: focused deity, path, mode, substrate layer, or broad-worship state |
| `Trigger family` | The 3-5 authored signal families that may start a favor for that lane |
| `Hook candidates` | Buildable Skyrim hooks: quest stages, Story Manager events, location keywords, shrine/Hall interactions, dialogue/faction states, sleep/rest events, or curated story events |
| `Favor bucket` | Momentary combat, after-act, environmental, or rare major |
| `Surfacing` | Quiet, Noted, or Marked |
| `Notes` | Anti-farm rule, theological caveat, build risk, or why the moment should feel marked |

This table is authoring scaffolding, not player-facing UI. A lane may have fewer final implemented favors than the table lists if hook reality forces a narrower launch scope, but the sheet should make that tradeoff explicit.

**Contextual-favor table rollout:**

Use a pilot-first rollout. Populate and review the shared table shape for the three broad-worship edge cases first:

- `Nord`: whole-pantheon breadth, Old Ways / Nine Divines texture, god-notices-you offer path
- `Imperial`: civic/institutional breadth under Concordat pressure
- `Redguard`: sect-shaped breadth across `Crown`, `Forebear`, and `Ash'abah`

Only after those three clear review should the table shape be propagated to all remaining race sheets. The pilot should prove that the columns help compare user experience without flattening race-specific theology.

Pilot tables may live in the affected race sheets with `Status: Pilot draft` while they are being worked. Do not promote their specific rows into this architecture reference until the pilot clears review. The architecture reference owns the table shape, rollout rule, and clearance criteria; the race sheets own draft race-specific content.

Pilot scope is broad-worship lanes only. Do not draft full focused-deity contextual-favor tables until the broad-lane pilot clears. Each pilot race should include a short `Focused contrast note` to show what focused devotion would sharpen later, but the note is only orientation, not a second table.

Pilot clearance requires:

1. Each pilot broad-worship lane has `3-5` trigger families.
2. Every trigger family has at least one strong vanilla hook candidate, or an explicit `custom / post-1.0` note.
3. Every row has a clear favor bucket and surfacing level.
4. Each pilot race includes a short user-experience sentence proving the lane does not feel like the other two broad-worship lanes.

The fourth requirement is the guardrail: `Nord` must not read like furred `Imperial`, `Imperial` must not read like civic `Nord`, and `Redguard` must not flatten into generic Yokudan pantheon worship.

**Pilot clearance result (2026-05-18):**

The Nord / Imperial / Redguard pilot cleared review against the criteria above. The shared table shape may now be propagated to the remaining race sheets. Do not promote the race-specific pilot rows into this architecture reference; keep the architecture at the level of shape, rules, and clearance.

**Dunmer layered-favor propagation rule (LOCKED 2026-05-18):**

Dunmer `Layer 1 + Layer 2` practice may trigger contextual favors before the player commits to a primary Good Daedra focus. This is not broad pantheon worship; it is the shared ancestor + Reclamations layer answering back. These shared favors should be mostly Quiet or Noted, with Marked surfacing reserved for primary-focus moments, vampire cure/restoration, major diaspora burden, or major Good Daedra quest recognition.

**Dunmer contextual-favor clearance result (2026-05-18):**

The Dunmer table is review-cleared for user-experience shape. It has five shared ancestor + Good Daedra trigger families, five focused trigger families each for Azura, Boethiah, and Mephala, and explicit boundaries preventing Azura from becoming a time-of-day faucet, Boethiah from becoming a generic violence wrapper, and Mephala from becoming a generic crime wrapper. Hook feasibility, substrate/focus implementation, curse posture, and Daedric deviation option mapping are now locked; remaining launch work is content weighting and implementation, not the experience model.

**Religious privileges:**

Reusable privilege families should include:

- `Shrine privilege`: special shrine options, cleansing, restoration, or devout-only interactions
- `Restoration privilege`: absolution, rededication, curse recovery, re-entry, reconciliation
- `Dialogue privilege`: patron, path, tier, or culture-gated lines and reactions
- `Recognition privilege`: different treatment by relevant religious or cultural spaces
- `Threshold privilege`: one-time or rare access unlocked by major devotional milestones

**Feedback:**

- Routine conditional help may stay quiet
- Meaningful state changes should be moderately surfaced
- Major thresholds, breaks, restorations, and rededications should be clearly surfaced
- Normal play should use thematic/diegetic language
- Exact piety values, current tier, path/mode state, and debug details belong in MCM/status/debug surfaces

### 9.2 System Contract

**Standalone posture:**

- Core PDV should be functionally standalone aside from core script framework requirements
- `SKSE` is acceptable
- `PapyrusUtil` is acceptable and should be treated as a hard runtime requirement with a clear fail message
- `SkyUI/MCM` should be optional, though strongly preferred for modern usability
- The core mod should not require Wintersun, Survival Mode, Requiem, or other gameplay mods
- Do not create new quest content for the first release; use existing gameplay loops, CK-gated interactions, and conditional moments

**Survival and compatibility posture:**

- Design with the likelihood that many users will run Survival Mode or survival-heavy modlists
- Do not make Survival Mode a hard dependency
- The signal matrix should include a `survival overlap` field so later compatibility work is easy to identify
- Requiem support should be planned as a later patch or compatibility layer
- Later work should investigate popular survival mods to determine whether broad default compatibility is possible or whether patch collections are needed

**Runtime budget:**

- Prefer event-driven signals
- Allow the dawn consolidation loop
- Allow at most one or two sparse global periodic subsystems if a race genuinely needs them
- Avoid broad continuous polling, high-frequency inventory scanning, constant nearby-NPC interpretation, and general "watch everything" logic
- Favor CK conditions, quest stages, faction states, location keywords, actor keywords, shrine interactions, sleep events, dialogue choices, and explicit story events

**Allowed signal cost classes:**

| Cost | Meaning | Default posture |
|---|---|---|
| `A` | Cheap event-driven signal | Preferred |
| `B` | Cheap periodic or state check | Allowed sparingly |
| `C` | Custom hook or moderate complexity | Justify clearly; likely post-core unless payoff is strong |
| `D` | Expensive, fragile, or speculative | Defer or reject |

**Signal row requirements for the matrix:**

Every signal row should define:

- `race`
- `path / mode / layer`
- `signal`
- `vanilla hook`
- `quest/faction relevance`
- `cost class`
- `reward layer`
- `cadence`
- `anti-farm rule`
- `survival overlap`
- `compatibility notes`
- `requires custom work?`
- `implementation risk`

**Cadence values:**

- `one-time`: quest completion, faction join, major religious threshold
- `repeatable with cooldown`: shrine use, ritual behavior, outdoor rest, recurring support patterns
- `daily capped`: common behaviors that matter but should not be farmable
- `state-based`: curse state, active path, broad worship, faction membership, current tier, current location state

**Anti-farm requirements:**

- Every repeatable signal needs an anti-farm rule
- Valid tools include per-day caps, diminishing returns, varied context requirements, meaningful intervals, path-state requirements, and immediate-repeat suppression
- Common behaviors such as shrine use, sleep, travel, crafting, stealing, killing, donating, eating, and outdoor rest must not become optimal grind loops

### 9.3 Race Architecture Preservation

- Active blessings and contextual favors are mostly tied to the active patron, path, or mode
- Race substrate layers remain active where the locked race architecture requires them
- Examples include Khajiit lunar substrate, Redguard ancestor layer, Argonian Hist/community/Sithis structure, and Orc life-mode standing
- Switching and persistence behavior should be inherited from each race's locked architecture rather than replaced by a new global conversion formula
- The matrix must preserve race-specific architecture instead of flattening every race into the same patron model

### 9.3.1 Hybrid Boon Policy (LOCKED)

PDV uses an asymmetric hybrid boon model.

Core rule:

- Every race gets one foreground devotional layer: active patron, active path, or active mode
- Only races whose theology is structurally layered get a true persistent substrate layer
- Most race uniqueness should live in privileges, contextual favors, and state tracks rather than stacked permanent buffs

Implementation-facing categories:

| Category | Purpose | Default posture |
|---|---|---|
| `Substrate` | Low-power persistent race identity layer | Use only where theology clearly requires it |
| `Foreground boon` | Main active patron/path/mode blessing set | Primary source of steady always-on power |
| `Contextual favor` | Conditional passive help during matching moments | Main source of flavorful situational identity |
| `Religious privilege` | Access, recognition, shrine use, cleansing, re-entry, threshold interactions | Preferred for race-specific uniqueness |
| `State track` | Non-buff identity logic such as reputation, orthodoxy, integrity, or life-mode standing | Preferred for social/political/theological pressure |

Balance rules:

- Most races should never feel like they have more than two meaningful always-on boon families at once
- True substrate layers should mostly express utility, survivability, restoration, environmental fit, or identity maintenance
- Foreground boons remain the main source of steady power
- Privileges and contextual favors should carry more of the race-specific feel than passive numbers do
- Use family caps so multiple small layers do not stack into one dominant statistical package

Race application matrix:

| Race | Hybrid structure | Persistent substrate posture | Main identity emphasis |
|---|---|---|---|
| `Nord` | No true substrate | None | Broad-to-primary worship plus privileges, quest weighting, and cultural interpretation |
| `Imperial` | No true substrate | None | Foreground Divine lane plus ConcordatStanding, public/private Talos logic, and civic privileges |
| `Breton` | No true substrate | None | Chosen lane plus WitchcraftExposure, KnightlyVowIntegrity, and Druidic standing |
| `Bosmer` | No true substrate | None | Chosen path is the hybrid system; do not add a race-wide Y'ffre substrate boon |
| `Altmer` | Light substrate | Light persistent orthodoxy frame | ThalmorAlignment, Lorkhan-adjacency penalties, scholarship privileges, apostasy handling |
| `Redguard` | Light substrate | Soft always-on ancestor reverence | Sect-shaped foreground worship, funerary privileges, anti-undead/death-order interpretation |
| `Orc` | Light substrate | Persistent life-mode standing | One Malacath-centered foreground with mode-specific ceiling and expression |
| `Dunmer` | Strong substrate | Full layered ancestor base | Ancestor layer remains always on; Good Daedra acknowledgment remains standard; one focused Good Daedra foregrounds Tier 3 |
| `Khajiit` | Strong substrate | Full lunar substrate | Lunar substrate always active; one deity becomes the strongest foreground emphasis |
| `Argonian` | Strong substrate | Hist-first exile substrate | Hist remains primary; community supports; Sithis rises only under strong repeated signals |

User-experience targets:

- `Nord` should feel like "my deeds reveal which god notices me," not "I spawned with a second passive package"
- `Imperial` should feel politically and socially split, with theology shaped by compliance or conscience
- `Breton` should feel reputation-sensitive and double-lived, with more identity in risk and status than passive power
- `Altmer` should feel judged by coherence, rupture, and orthodoxy more than by raw devotion volume
- `Dunmer` should feel cumulative and internally coherent, never like competing mutually exclusive gods
- `Khajiit` should feel cosmologically held even before focused commitment
- `Bosmer` should feel path-divergent rather than race-package-plus-patron
- `Redguard` should feel sect-shaped and duty-shaped, with ancestry always present but not dominant in every moment
- `Orc` should feel like the question is how Malacath's code is carried in this life-mode, not which god is selected
- `Argonian` should feel like exile, distance, and reconstruction of self, with the Hist still mattering even when hard to reach

First-release implementation posture:

- `Nord`, `Imperial`, `Breton`, and `Bosmer` should usually have one true boon lane plus strong privileges, contextual favors, and state tracks
- `Altmer`, `Redguard`, and `Orc` may keep a light persistent layer, but that layer should stay below the foreground boon in raw power
- `Dunmer`, `Khajiit`, and `Argonian` may keep stronger persistent substrates, but those substrates should still lean toward context, identity, and maintenance rather than broad throughput
- If later balancing forces simplification, reduce substrate strength before removing privileges or contextual race identity

### 9.4 Pre-Matrix Deliverable

Before implementation work expands, create a race signal matrix with these columns:

| Race | Path / Mode / Layer | Signal | Vanilla Hook | Quest/Faction? | Cost Class | Reward Layer | Cadence | Anti-Farm Rule | Survival Overlap | Compatibility Notes | Custom Work? | Risk |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

---

## SECTION 10: Per-Race Decisions (LOCKED)

**Quest-choice integration rule (LOCKED):**
- Across all races, repeatable behaviors establish ambient devotion drift
- Major quest and faction choices carry heavier one-time weight when they clearly expose a race's primary theological tensions
- Quest choices should act as accelerants, confirmations, ruptures, or redirects of an existing devotional structure, not as a total substitute for ambient practice
- Do not assign heavy quest weights where the theology is only weakly implicated or the in-game signal is too ambiguous

### 10.1 Nord (LOCKED)

**Setup Flow:**
```
Step 1: Choose pantheon baseline
→ [Old Ways]      6 primary god options (Shor, Kyne, Tsun, Stuhn, Mara, Talos/Ysmir)
→ [Nine Divines]  9 primary god options (all Nine)

Step 2: Worship broadly until a god's offer fires
→ Broad worship cap: Tier 2 (Faithful) — lore-accurate, most Nords blend pantheons
→ Tier 3 (Devoted) only available after committing to a primary god
```

**Broad → Primary Transition System (LOCKED):**
- No questline dependency
- No shrine location requirement
- Sustained domain-aligned piety triggers the offer organically
- Player's actual playstyle determines which god notices them first
- Multiple offers possible if player excels across domains
- Player can decline ("Not yet") — offer cooldown applies, broad worship continues
- 70% piety carry-over on commitment

**Nord implementation split (LOCKED 2026-05-19):**
- Do not use one overloaded `PDV_State_NordWorship` enum for both pantheon identity and commitment depth
- Implement pantheon baseline as `PDV_State_NordPantheonBaseline`
- Enum values are `OldWays = 0`, `NineDivines = 1`
- Commitment depth uses the shared patron state model: `PDV_GLO_PatronState` for broad worship vs active patron, and `PDV_GLO_PatronDeity` for the committed primary god
- A Nord's active devotional framing is therefore the composition of baseline plus patron state: Old Ways + Broad, Nine Divines + Broad, Old Ways + Primary, or Nine Divines + Primary
- This preserves distinct Talos presentation: Old Ways Talos / Ysmir reads as ancestral identity defiance, while Nine Divines Talos reads as carrying contradiction inside a public Divine frame

**Nord primary-offer gate (LOCKED 2026-05-19):**
- Primary offers are evaluated during `ProcessDawn()`, not mid-event
- A god becomes offer-eligible only if the god belongs to the chosen pantheon baseline, current piety meets the offer threshold, that god has qualifying signal activity on at least two separate in-game days within the last seven days, and no offer cooldown blocks it
- Default offer threshold is the Faithful / Tier 2 threshold: `50` persistent piety
- The threshold remains per-deity tunable, but lower or special thresholds require explicit race/deity exception text
- If multiple gods qualify on the same dawn, offer the highest recent signal-strength god first
- Major sacred events such as Sovngarde / Tsun, hidden Talos shrine protection, or major Kyne / Thu'um milestones may count as one qualifying day, but do not bypass the sustained-pattern requirement by themselves
- Once the player is primary-committed, competing primary offers do not fire unless a later patron-drift / reorientation system explicitly exists

**Nord offer-decline rule (LOCKED 2026-05-19):**
- Declining an offer with "Not yet" does not lower piety
- Decline sets a per-deity cooldown, not a global Nord offer cooldown
- Suggested StorageUtil key: `PDV.OfferCooldownUntil.<Deity>`
- Initial cooldown is seven in-game days for that deity
- A second decline of the same deity extends cooldown to fourteen in-game days; later declines stay at fourteen days unless testing shows abuse
- Broad worship continues normally during cooldown
- Other qualifying gods may still offer on later dawns
- If multiple gods qualify while one is cooling down, skip the cooled-down god and offer the next highest recent signal-strength god
- Accepting a patron clears pending Nord offer queues and sets the shared patron state to active primary
- Rationale: Nord worship should let a god notice the character while preserving player agency about whether recognition becomes commitment

**Nord acceptance / no-switching rule (LOCKED 2026-05-19):**
- Accepting a primary offer sets `PDV_GLO_PatronState` to active primary and `PDV_GLO_PatronDeity` to the accepted deity
- Accepting clears pending Nord offer candidates
- The accepted deity receives the standard 70% piety carry-over
- Other deity ledgers remain intact but become background-only
- Competing primary offers do not fire while active primary is set
- If devotion later decays below Tier 3, the patron relationship weakens but does not automatically clear
- For 1.0, there is no active Nord patron-switching / reorientation system
- Future patron switching should be an explicit post-1.0 rupture, restoration, or reorientation feature, not hidden automatic drift

**Nord offer-candidate storage rule (LOCKED 2026-05-19):**
- Do not persist a real queue / array of pending Nord offers
- At each `ProcessDawn()` offer pass, recompute offer candidates from current state
- Candidate filter: deity belongs to chosen pantheon baseline, persistent piety is at or above `50`, two qualifying signal days exist within the last seven in-game days, and no per-deity cooldown is active
- Select at most one offer per dawn by highest recent signal strength
- Store only per-deity decline cooldowns, recent signal-day evidence, and optional last-offered deity / time for debug
- If an offer presentation is ignored or interrupted, re-evaluate on the next dawn rather than preserving a stale queue
- Once a patron is accepted, the offer pass stops for formal patron offers

**Broad Nine Divines Nord rule (LOCKED):**
- Broad Nine Divines Nords mostly use the same deed/world hook surface as Broad Old Ways Nords
- The names and moral framing shift toward Kynareth, Arkay, Stendarr, Zenithar, and the temple-readable Divines
- The play texture remains Nord: holds, weather, family, death, honor, and Talos pressure rather than Imperial civic/institutional religion

**Broad Nord Talos pressure rule (LOCKED):**
- Talos pressure belongs in both broad Nord lanes
- In Broad Old Ways, it presents as ancestral identity defiance
- In Broad Nine Divines, it presents as carrying a contradiction inside a public Divine frame
- In both lanes, contextual favor should require costly faithful signals, not generic anti-Thalmor violence or ordinary Civil War preference
- Default surfacing is `Noted`; escalate to `Marked` only for high-cost events like hiding a worshipper, protecting a shrine, or defying Thalmor pressure face-to-face

**Threshold Trigger Rules (LOCKED):**
- Single domain-threshold pattern for most gods
- Combined domain threshold only for multi-domain gods (Mara, Talos)
- Threshold = sustained high piety/signals in that domain — exact values TBD during balancing

**God → Domain Signal Mapping:**

| God | Pantheon | Primary Signal Domain | Notes |
|-----|----------|---------------|-------|
| Shor | Old Ways | Combat / heroic trial | Warrior-king, Sovngarde aspiration |
| Kyne | Old Ways | Combat + outdoor life | Storm-mother spans martial and natural |
| Tsun | Old Ways | Combat / honorable trial | Trial against adversity, honourable combat |
| Stuhn | Old Ways | Combat + mercy/order | Fair-fighting and ransom — combat with honour |
| Mara (Old Ways) | Old Ways | Hearth + community | Hearth, harvest, survival of home |
| Talos/Ysmir | Old Ways | Combat + Thalmor defiance | Shor-incarnation — combat + defiance |
| Akatosh | Nine Divines | Time/order persistence | Time, order, long devotion streaks |
| Talos | Nine Divines | Combat + Thalmor defiance | Deified emperor — same trigger, different framing |
| Kynareth | Nine Divines | Nature, winds, travel | Nature, winds, travel |
| Mara (Imperial) | Nine Divines | Love + household/community | Love, compassion — same trigger as Old Ways Mara |
| Zenithar | Nine Divines | Commerce and honest work | Commerce, honest work |
| Arkay | Nine Divines | Death rites and life cycle | Death rites, burial, life cycle |
| Stendarr | Nine Divines | Mercy + restraint in combat | Mercy in combat — fighting with restraint |
| Julianos | Nine Divines | Wisdom/study | Wisdom, study, College-adjacent |
| Dibella | Nine Divines | Beauty/art/social grace | Beauty, art, bardic acts |

**Quest-choice integration (LOCKED):**
- Nordic gods do not require questline completion to become available
- However, quest choices that clearly expose Nordic theological identity should outweigh passive ambient drift when present

**Heavy Nordic quest signals (LOCKED):**
- `Civil War allegiance`, `Talos-ban defiance`, and `Thalmor resistance` strongly weight `Talos/Ysmir`, `Shor`, and broader Nord identity
- `Greybeards`, `High Hrothgar`, and major `Thu'um` milestones strongly weight `Kyne/Kynareth`, with `Akatosh` also touched through dragon-order contact
- `Sovngarde`, `Tsun`, and explicit honorable-trial content strongly weight `Shor` and `Tsun`
- `Companions` and warrior-society quest content strongly weight `Shor`, `Tsun`, and `Stuhn`, while later curse-state logic adds `Hircine` tension if needed
- `Household`, `marriage`, `hold defense`, and `community-restoration` quest choices strongly weight `Mara`, with some `Stendarr` overlap where mercy is foregrounded

**Non-Worshippable Gods (excluded from setup):**
- Alduin — World-Eater, feared not worshipped, returning as antagonist
- Orkey — Enemy-god, propitiated not loved
- Jhunal — Forgotten by 4E 201 Nords, absorbed into Julianos

**Open for balancing (not architectural):**
- Exact piety values above the global Faithful offer threshold, if a specific deity needs stricter tuning
- Exact per-signal recent-strength weights used to break ties between multiple qualifying offer candidates

**Curse state weight notes (to detail during implementation):**
- Werewolf Nord: Hircine pulls against Shor/Sovngarde — combat signals shift toward hunt interpretation
- Vampire Nord: Severs afterlife claim — Shor/Sovngarde path weight reduced, Molag Bal pressure added

### 10.2 Imperial (LOCKED)

**Setup Flow:**
```
No baseline choice needed (one pantheon — Nine Divines)
Broad worship begins automatically
Cap: Tier 2 (Faithful) — civic observance is culturally normal
Tier 3 only through primary god commitment
Same piety-threshold offer system as Nord
```

**Imperial patron-state rule (LOCKED 2026-05-19):**
- Do not create `PDV_State_ImperialWorship` for Broad vs Primary
- Imperial broad worship and accepted primary commitment use the shared patron state model: `PDV_GLO_PatronState` and `PDV_GLO_PatronDeity`
- Imperial-specific state lives in `PDV_RepTrack_ConcordatStanding`, not in a duplicate worship enum
- Rationale: `ConcordatStanding` is the Imperial identity/pressure axis; Broad vs Primary is global patron machinery

**Imperial offer-gate rule (LOCKED 2026-05-19):**
- Imperial uses the global formal patron-offer gate: dawn-only evaluation, `50` persistent piety by default, qualifying signal activity on at least two separate in-game days within the last seven days, per-deity cooldowns, and no persistent offer queue
- Broad vs Primary is handled by shared patron state
- `ConcordatStanding` may modify offer eligibility and presentation, especially for Talos, but it does not replace the global offer machinery

**Imperial broad-worship lane (LOCKED):**

Imperial broad worship is civic and institutional, not mythic breadth. Its contextual favors should be led by civic acts, with institutional places acting as amplifiers, recognition surfaces, or cleaner hooks where the game supports them.

| Broad trigger family | Favor presentation |
|---|---|
| Mercy / restraint under civic pressure | Brief Stendarr-coded protection or steadiness |
| Burial, Hall of the Dead, anti-necromancer duty | Arkay-coded rest, disease/undead protection, or institutional recognition |
| Lawful order, Legion duty, public service | Akatosh / civic-order stability favor |
| Honest trade, craft, tax / contract order | Zenithar-coded speech or commerce steadiness |
| Public/private Talos pressure | Talos favor only when the authored signal is faithful defiance, not generic rebellion |

Concordat compliance may move `ConcordatStanding`, alter access, or qualify Akatosh/civic-order favor when the authored act is genuinely order-preserving. It does not trigger Talos contextual favor. Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence.

Legion allegiance, court status, and official faction state may provide scoring context, but they do not trigger Imperial contextual favor by themselves. Lawful-order favor requires a concrete public-service or order-preserving act, and the act must not be cruelty disguised as order.

`Public Compliant` and `Concordat Enforcer` may amplify Akatosh / Zenithar civic-order offer eligibility when the qualifying acts are genuinely order-preserving, public-service, or honest civic-exchange signals. They never amplify Talos. Cruelty disguised as order does not qualify.

`Private Defiant` allows Talos offers, but presentation should remain quiet / private by default. `Open Defiant` may surface more openly when the authored moment is costly enough. `Uncommitted` leaves all Nine Divines offer eligibility neutral, including Talos, provided the player has real god-specific signal evidence.

Bounty payment is not a generic mercy/restraint favor trigger. It counts only when authored as preventing harm or resolving a real civic conflict; ordinary pay-bounty menu interactions do not trigger favor.

Final trigger selection must follow buildable Skyrim hooks: quest stages, shrine/Hall of the Dead interactions, dialogue choices, faction states, and curated story events before ambient inference.

**Unique Mechanic: Concordat Standing Track (LOCKED)**

Imperial is the only race with a political reputation modifier tied to a specific god.

```
ConcordatStanding (−100 to +100, starts at 0)
Negative = Defiance (helping worshippers, hiding shrines)
Positive = Compliance (enforcing ban, reporting worshippers)
```

**Five States (threshold-locked — sustained behaviour required to change):**

| State | Range | Talos Devotion Effect | Thalmor Effect |
|-------|-------|-----------------------|----------------|
| Open Defiant | −100 to −76 | Shift × 1.5, starts at 60 | Thalmor actively hunt player |
| Private Defiant | −75 to −51 | Shift × 1.25, starts at 55 | Thalmor suspicious, occasional checks |
| Uncommitted | −50 to +50 | Shift × 1.0, starts at 50 | Thalmor ignore player |
| Public Compliant | +51 to +75 | Shift × 0.75, starts at 45 | Thalmor friendly |
| Concordat Enforcer | +76 to +100 | Shift × 0.5, starts at 35 | Thalmor allied |

**Uncommitted band width (LOCKED):** The Uncommitted band is deliberately wide (±50) to avoid rubberbanding players into forced engagement. It still forces eventual engagement through sustained behavior, but doesn't punish normal gameplay choices with immediate state shifts. Players must truly commit to defiance or compliance to leave the Uncommitted zone.

**State change rules:**
- Single acts move the track by small increments (±5 to ±15)
- Crossing a threshold locks the state until sustained behaviour reverses it
- Cannot skip states — must pass through each threshold in order
- State is persistent across sessions

**Actions and point values:**

| Action | Points |
|--------|--------|
| Find and activate hidden Talos shrine | −15 |
| Help Talos worshipper escape Thalmor | −15 |
| Kill Thalmor Justiciar (unprovoked) | −10 |
| Side with Stormcloaks (unusual for Imperial) | −20 |
| Refuse to report Talos worshipper | −5 |
| Publicly observe Talos ban | +5 |
| Report Talos worshipper to Thalmor | +15 |
| Attack Talos worshipper | +15 |
| Side with Imperial Legion | +10 |
| Escort Thalmor prisoner | +10 |

**Other Divine gods (non-Talos):**
- All Nine Divines available as primary god choices
- Same single/combined piety-threshold offer system as Nord
- God/domain mapping follows the Nine Divines column from the Nord table

**Talos commitment gate (LOCKED):**
- Full Talos primary commitment is normally available only in `Uncommitted`, `Private Defiant`, and `Open Defiant`
- `Public Compliant` and `Concordat Enforcer` normally block Talos primary offers
- A fresh costly-defiance signal may create a rupture exception that lets Talos offer despite a compliant current state
- The rupture exception must be authored as faithful defiance, not generic anti-Thalmor violence or ordinary political preference
- Rationale: high Concordat compliance must have real theological cost, while a costly act of conscience can still open the door

**Talos rupture acceptance rule (LOCKED 2026-05-19):**
- If an Imperial in `Public Compliant` or `Concordat Enforcer` accepts a Talos offer after a costly-defiance rupture, `ConcordatStanding` immediately moves at least to `Private Defiant`
- A public or high-risk authored rupture may move the player farther, including to `Open Defiant`, but only for major curated signals
- A hidden or private rupture moves the player to `Private Defiant`
- Accepting Talos cannot leave the character publicly theologically compliant

**Civic offer amplification rule (LOCKED 2026-05-19):**
- `Public Compliant` and `Concordat Enforcer` may increase Akatosh / Zenithar recent signal strength for offer priority when the qualifying acts are genuinely order-preserving, public-service, or honest civic-exchange signals
- Civic amplification does not lower the global Faithful / Tier 2 offer threshold
- Civic amplification never applies to Talos and never applies to cruelty disguised as order

**Enforcer repair-gate rule (LOCKED 2026-05-19):**
- `Concordat Enforcer` dampens Stendarr and Arkay offer eligibility unless the player has recent mercy or death-rite repair signals
- Repair signals must be concrete authored acts, such as mercy under pressure, prisoner protection, death-rite restoration, or anti-necromancer / burial duty
- Rationale: Imperial civic religion should judge its own failures; persecution and inadequate death care should not passively produce mercy or death-order devotion

**Secondary Concordat modifiers (Arkay + Stendarr):**
Reuses ConcordatStanding track — no new system needed. Two additional conditionals in `ApplyBaseInterpretation()`:

```papyrus
; Concordat Enforcer state (Standing > +50)
;   Mass graves, inadequate death rites, persecution enabled
if ConcordatStanding > 50
    ArkayDailyShift *= 0.85    ; religious failure: inadequate rites at scale
    StendarrDailyShift *= 0.85 ; mercy conflicts with active persecution

; Open Defiant state (Standing < −50)
;   Defiance aligns with Stendarr's mercy, Arkay unaffected
elseIf ConcordatStanding < -50
    StendarrDailyShift *= 1.15 ; active resistance = merciful act
    ; Arkay unaffected — death rites are separate from politics
endif
```

Rationale:
- Arkay: Civil War enforcement creates mass graves and inadequate death rites — a direct religious failure
- Stendarr: Mercy is incompatible with enabling Thalmor persecution
- Only extreme states (Enforcer/Defiant) trigger secondary modifiers — middle states are clean
- Arkay is never boosted by defiance (death rites transcend politics)

**Quest-choice integration (LOCKED):**
- Civic, legal, and faction quest resolutions are first-class Imperial signals and should outweigh passive worship drift when clear

**Heavy Imperial quest signals (LOCKED):**
- `Civil War`, `Legion`, and rebellion choices heavily reweight `ConcordatStanding`, `Akatosh` civic-order themes, and `Talos` compliance/defiance
- `Thalmor cooperation or resistance` produces some of the strongest possible `ConcordatStanding` shifts
- `Talos worshipper protection`, concealment, or denunciation is the clearest explicit `Talos` quest signal in the race file
- `Burial`, `anti-necromancy`, and death-order quests strongly weight `Arkay`
- `Mercy vs persecution` resolutions strongly weight `Stendarr`
- `Household`, `charity`, and social-restoration quests strongly weight `Mara`

**Open for balancing:**
- Exact point values per action
- Exact threshold boundaries between states
- Whether Thalmor hostility overrides or stacks with vanilla Thalmor faction system

**Curse States (LOCKED):**

**Vampire:**
```
Imperial Divine devotion collapses entirely while vampirism is active
  The Nine Divines path halts rather than merely slowing
  ConcordatStanding no longer matters religiously while the player remains a vampire
  Molag Bal or a civic-shadow survival reading becomes the only viable theological substitute

On CURE:
  Divine devotion resumes
  Starting floor returns lowered rather than restored cleanly
  Full restoration path may be added later if implementation needs it
```

Rationale:
- Imperial religion is civic infrastructure anchored by Arkay, oath, burial, and institutional belonging
- Vampirism ejects the player from that frame completely rather than creating a damaged-but-functional version of it
- Cure matters, but does not erase the rupture

**Werewolf:**
```
Nine Divines devotion remains active at reduced effectiveness
  No native Imperial Hircine path opens
  Civic-facing devotion weights reduce
  The player becomes theologically homeless rather than newly integrated
```

Rationale:
- Source material frames the Imperial werewolf as isolated and framework-less
- Hircine is an intrusion into Imperial life, not an accepted alternative religious home

### 10.3 Breton (LOCKED)

**Setup Flow:**
```
Step 1: Choose primary tradition (spine of devotional life)
→ [The Knight's Road]  Civic honor, protective justice, selfless service
→ [The Hidden Art]     Occult practice, Daedric dealings, double lives
→ [The Green Way]      Druidic covenant, standing stones, nature rites

Step 2: Practice tradition breadth until focused deity emphasis emerges
→ Tradition breadth cap: Tier 2 (Faithful)
→ Tier 3 (Devoted) only through focused deity commitment within tradition

Traditions can pull against each other — cross-tradition acts create tension
```

Breton does **not** use the generic broad-worship lane. Tradition breadth is a Breton-specific setup layer: the player lives within a chosen tradition before a focused deity or Daedric patron emerges. Patron offers normally come only from the chosen tradition unless an authored major fork explicitly opens another route.

**Three-Track Restructure (LOCKED):**
The Breton identity is defined by *which tradition you walk*, not which god you pick from a list. God choice is a secondary flavor layer within each track — adding depth to your tradition rather than replacing it. The three tracks can pull against each other, creating the signature Breton tension between respectability, power, and nature.

**Implementation-lock refinements (2026-05-19):**
- Setup requires an explicit `PDV_State_BretonTradition` choice. There is no silent default into a tradition.
- `PDV_State_BretonTradition` enum values are `KnightsRoad = 0`, `HiddenArt = 1`, `GreenWay = 2`.
- `WitchcraftExposure` is global for all Bretons because occult visibility matters even outside the Hidden Art tradition.
- `KnightlyVowIntegrity` exists for all Bretons, starts at `100`, and is presented/active only for Knight's Road play. Major dishonor can still write the track while dormant so later attempts to walk the Knight's Road remember what the player has done.
- `DruidicStanding` exists for all Bretons, starts at `50`, and is presented/active only for Green Way play or explicit Green Way forks. It does not punish non-Green Bretons for ordinary non-druidic life.
- `PDV_State_BretonDruidicFork` enum values are `Stable = 0`, `Contested = 1`, `GreenAccepted = 2`, `HircineClaimed = 3`, `Excommunicated = 4`, `Penitent = 5`, `Restored = 6`.
- Cross-lane pressure is asymmetric: Hidden Art can strongly damage KnightlyVowIntegrity and raise WitchcraftExposure; public knightly cover can slowly lower WitchcraftExposure but cannot erase severe occult commitments by itself; Knight's Road and Green Way overlap gently; Hidden Art and Green Way overlap mainly through Hircine/old magic and should create fork pressure.
- Normal Breton tradition switching is not available in 1.0. The setup tradition is stable; major authored forks may rupture or redirect a path, but casual mid-game reorientation is deferred to a later explicit feature.
- Breton contextual favors are authored per tradition lane for launch, not per deity: Knight's Road, Hidden Art, and Green Way each receive `3-5` trigger families. Focused deities may tune presentation, but they do not create separate launch favor tables.
- Hidden Art supports two valid end states: careful cover in the `Hidden` / `Suspected` bands and open notoriety in the `Notorious` band. Cover should feel subtle and safer; notoriety should feel stronger, louder, and socially ruptured rather than simply better.

**Focused deity options within each tradition:**

| Tradition | Available Focused Deities |
|-----------|--------------------------|
| The Knight's Road | Stendarr, Akatosh, Mara, Arkay, Julianos, Zenithar, Kynareth, Dibella |
| The Hidden Art | Hircine, Hermaeus Mora, Namira, Nocturnal (via Daedric system) |
| The Green Way | Y'ffre (primary), Magnus, Phynaster |

**UESP Confirmed:** Magnus is listed under "Additional Deities with Significant Breton Cults" — legitimate pantheon inclusion. Phynaster available for players emphasising elven heritage.

Hircine is Breton-legible but not Breton-native. The stance matrix's Breton `TABOO` reading and the Daedric matrix's Breton `Legible` reading are reconciled by treating Hircine as fork-access: he is available through Hidden Art commitment signals or the Green Way werewolf fork, not as ordinary Breton baseline worship.

---

**Unique Mechanic 1: WitchcraftExposure Track (LOCKED)**

Same code pattern as Imperial's ConcordatStanding — one reusable `PDV_ReputationTrack` script, instantiated twice with different thresholds and labels.

```
WitchcraftExposure (0–100, starts at 0)
0–25   = Hidden       (private coven practice, socially invisible)
26–50  = Suspected    (Vigilants may take notice through authored/contextual reactions, some Bretons uncomfortable)
51–75  = Known        (Vigilants become a credible danger when occult state is manifest or PDV-authored pressure fires, most Bretons distance)
76–100 = Notorious    (Daedra cultist in all but name, full social rupture)
```

The bands and modifiers are locked for 1.0. The `Notorious` x1.25 modifier applies only to Daedric / Hidden Art commitment, not to all Breton religion.

**Exposure modifiers on Witchcraft path devotion:**
```papyrus
if WitchcraftExposure < 25
    DailyShift *= 1.0   ; hidden practice — full accumulation

elseIf WitchcraftExposure < 50
    DailyShift *= 0.9   ; suspected — mild social friction

elseIf WitchcraftExposure < 75
    DailyShift *= 0.75  ; known — active pressure disrupts practice

else
    DailyShift *= 1.25  ; notorious — Daedric prince rewards full commitment
endif
```

Social rupture is surfaced through dialogue/privilege/state effects, not a
removed social bucket.

**What raises exposure:**
- Completing Daedric quests publicly (+15)
- Caught by Vigilants of Stendarr (+20)
- Reaching Tier 2 devotion to Daedric patron (+10)
- Killing a Vigilant of Stendarr (+25)

**What lowers exposure:**
- Time passing without visible acts (slow passive decay -1/day; visible exposure can return to `Hidden`, but one-shot major-act markers remain in history)
- Maintaining public Imperial Divines worship as cover (-5 per sustained period; requires no major occult signal for 3 in-game days and is capped once per 7 days)
- Avoiding Daedric-associated locations (passive)

---

**Unique Mechanic 2: KnightlyVowIntegrity Track (LOCKED)**

Applies to Knight's Road players. Stendarr and Akatosh read it most strongly, but the track belongs to the tradition rather than only to two gods.

```
KnightlyVowIntegrity (0–100, starts at 100 for knight-path)
```

**Broken by:**
- Joining Thieves Guild (−30)
- Joining Dark Brotherhood (−40)
- Unprovoked killing of innocents (−15 per event)
- Abandoning a quest to help an NPC in need (−10)

**Effects of low integrity:**
```papyrus
if KnightlyVowIntegrity < 25
    AllKnightsRoadDailyShift *= 0.5
    StendarrDailyShift *= 0.25
    AkatoshDailyShift *= 0.5

elseIf KnightlyVowIntegrity < 50
    AllKnightsRoadDailyShift *= 0.75
    StendarrDailyShift *= 0.5
    AkatoshDailyShift *= 0.75
endif
```

At `0`, all Knight's Road relationship progress halts until Integrity is restored above `25`; Stendarr and Akatosh recognition is fully withdrawn.

**Restoration:**
- Acts of mercy and justice rebuild integrity slowly (+5 per significant act)
- Visiting Stendarr shrine with clean hands (+10; can restore collapse but cannot raise Integrity above 75)
- Completing a quest to help an NPC without reward (+5)

Integrity above 75 requires lived conduct: curated mercy, justice, protection, or reparation acts. Shrine visits can help a fallen knight stand back up, but they cannot by themselves make the player honorable.

---

**Unique Mechanic 3: Druidic Standing (LOCKED)**

Applies to Green Way players as `PDV_RepTrack_DruidicStanding` (`0..100`) plus `PDV_State_BretonDruidicFork`. Starts at `50`, representing an open but unproven covenant. Decay is cadence-based rather than daily punishment: if no Green Way signal occurred in 5 in-game days, apply `-2` at dawn, with a non-curse floor of `30`.

**Vampire interaction:**
```
EXCOMMUNICATED: triggered on becoming vampire
  Y'ffre devotion halted entirely (not reduced — stopped)

PENITENT: triggered if cured of vampirism
  Y'ffre devotion resumes at 50% rate
  Player must complete ritual act to begin restoration:
    → Visit specific outdoor location (standing stone, ancient grove)
    → Make offering (animal remains, not plant matter — Pact-consistent)

RESTORED: after sustained Pact-aligned behaviour post-ritual
  Y'ffre devotion resumes fully
  Permanent piety/tier scar from excommunication period
```

Green Way vampire recovery is harder than ordinary neglect recovery: vampire state sets `Excommunicated`, cure moves the player only to `Penitent`, and full restoration requires a curated outdoor rite plus sustained Green Way behavior. Even restored players keep a permanent scar from the rupture.

**Werewolf interaction (LOCKED — unique fork mechanic):**
```
Druidic + Werewolf = CONTESTED state (not excommunicated, not accepted)
Y'ffre devotion continues at 75% rate

Special event: "Druidic Trial" fires after first transformation
Player chooses:

→ "The beast serves the Green"
   Druidic tradition accepts the shape as deepened beast-kinship
   Y'ffre devotion resumes at full rate
   Hircine devotion path unavailable (loyalty declared)

→ "Hircine's gift is mine"
   Druidic tradition rejects — excommunication begins
   Y'ffre closes, drift toward Hircine path begins
   WitchcraftExposure increases (beast-pact is visible)
```

Rationale: The lore explicitly says Druidic Circles are split on werewolfism. This fork gives the player the theological choice the Druids themselves have — the only race-curse combination that offers a genuine theological decision rather than just a penalty.

**Quest-choice integration (LOCKED):**
- Breton tradition is clarified most strongly by factional, knightly, occult, and pact-laden quest choices rather than ambient generic behavior alone

**Heavy Breton quest signals (LOCKED):**
- `Help-without-reward`, `knightly protection`, and explicit justice quests strongly weight the `Imperial Divines` traditions, especially `Akatosh`, `Stendarr`, and `Mara`
- `Daedric bargains`, `occult secrecy`, cult aid, and anti-`Vigilants of Stendarr` choices strongly weight `Witchcraft` and raise `WitchcraftExposure`
- `Nature-site`, `standing stone`, grove, or wilderness-rite choices strongly weight `Druidic Y'ffre`
- `Thieves Guild`, `Dark Brotherhood`, and broken-oath quest choices heavily damage `KnightlyVowIntegrity` and increase witchcraft pressure where appropriate
- The `Druidic Trial` after werewolf transformation is an explicit theological quest-fork, not ambient drift

**Breton 1.0 hook feasibility locks (LOCKED 2026-05-19):**
- Knight's Road positive scoring is curated-only for launch. Strong surfaces are faction/quest/stage/location/shrine hooks: `DLC1HunterFaction` for Dawnguard protection, `VigilantOfStendarrFaction`, `StendarrsBeaconLocation`, `HalloftheVigilantLocation`, Divine shrine activators, `Destroy Brotherhood`, `Book of Love`, `Paarthurnax choice`, and selected justice/mercy quest outcomes. Generic "helped without reward" intent detection is not a launch hook unless a specific quest outcome cleanly exposes it.
- Knightly vow pressure uses strong faction/crime/state hooks first: `ThievesGuildFaction`, `CrimeFactionThievesGuild`, `DarkBrotherhoodFaction`, `DB10SanctuaryFamilyFaction`, major murder/crime proxies, and explicit oath-breaking quest outcomes. Petty theft spam and radiant crime loops do not drive the track.
- WitchcraftExposure is major-act only. Strong surfaces are Daedric quest outcomes, Nightingale oath / Nocturnal compact, Black Book / Apocrypha / Oghma-style forbidden knowledge, killing or directly opposing Vigilants, Daedric Tier 2, and vampire/Volkihar state. Generic spellcasting, stealth, artifact ownership alone, or visiting spooky places does not count.
- Vigilant pressure has partial vanilla support, but not as a general exposure-based hunter system. `VigilantOfStendarrFaction` is hostile to vampire, Daedra, undead, necromancer, hagraven, and werewolf factions; world interactions include Vigilants fighting abominations; and `A Daedra's Best Friend` can make Vigilants attack Barbas. UESP also documents unused Daedric-artifact confrontation dialogue that is set to never happen in-game. Therefore 1.0 may use existing hostility/world-interaction surfaces and authored PDV pressure, but exposure-driven hunter squads are custom content, not assumed vanilla behavior.
- Optional Vigilant pressure extension: a light authored encounter can be added later using the disabled Daedric-artifact confrontation as design precedent. Do not implement this as real crime-gold bounty: bounty is hold-scoped reported lawbreaking, while WitchcraftExposure is religious stigma. Preferred shape is a PDV-authored road confrontation, courier/letter warning, or contract-style encounter keyed to `Known`/`Notorious`, recent major occult signal, and long cooldown. This is desirable but should not block Breton 1.0 implementation lock unless the encounter pattern proves cheap.
- Witchcraft-to-Knight drag is major-act based. Thieves Guild / Dark Brotherhood commitment, Nightingale oath, Daedric quest commitment, Namira feast, Molag Bal domination, and killing Vigilants can damage `KnightlyVowIntegrity`; ordinary magic, College membership, private curiosity, and shrine visits do not.
- Green Way launch scoring is location/rite-first. Strong surfaces are standing-stone activators (`Doomstone*` and Solstheim `dlc2StandingStone*ACT`), `LocTypeSprigganGrove` (`MossMotherCavernLocation`, `RoadsideRuinsLocation`, `ShadowgreenCavernLocation`), Kynareth shrine/temple as modest Y'ffre-adjacent support, outdoor sleep cadence, and the `PlayerWerewolfFaction` / Companions beast-blood route for the one-time Druidic Trial.
- Hunting is secondary and cautious for 1.0. Use curated hunts or strict context filters only; do not infer Y'ffre devotion from ordinary animal kills.
- Breton dawn processing order is event deltas -> curse/fork state -> cross-lane drag -> devotion modifiers -> piety consolidation.
- Player presentation is threshold-only: tradition chosen, patron offer, WitchcraftExposure band changes, Integrity crossing 50/25/0, Druidic Trial, vampire excommunication/restoration, Hircine fork, and Champion.
- WitchcraftExposure visible decay can return to `Hidden`, but major-act history remains for debug, offer context, and future authored pressure.
- Public Divine cover is not shrine-spam laundering: no major occult signal for 3 days, `-5` at most once per 7 days.
- Knightly shrine restoration is capped at 75; Integrity above 75 requires lived mercy, justice, protection, or reparation.
- DruidicStanding decay is gentle: no Green Way signal for 5 days -> `-2` at dawn, floor `30` unless curse-state rules override.
- Green Way vampire recovery is stricter than neglect: `Excommunicated` -> `Penitent` -> outdoor rite plus sustained Green Way behavior, with permanent scar.
- All three Breton tracks exist for every Breton. `WitchcraftExposure` is always active; `KnightlyVowIntegrity` and `DruidicStanding` can remain dormant/presented only when their tradition matters, but major authored events may write them so future path pressure has memory.
- Normal Breton tradition switching is unavailable in 1.0. Only major authored forks, such as Green Way -> Hircine through the Druidic Trial, can redirect the active religious frame.
- Breton contextual favors are tradition-lane authored for launch: Knight's Road, Hidden Art, and Green Way each use `3-5` trigger families, with focused deity flavor layered on top.
- Hidden Art has two valid intentional end states: concealed occult practice and open Notorious rupture. Do not tune Notorious as a pure upgrade; it is stronger but socially costly.
- Breton is implementation-locked as of 2026-05-19. Remaining reward numbers and exact effect magnitudes are balancing work, not open experience architecture.

---

**Curse State Architecture (LOCKED)**

Breton curse states are uniquely path-dependent — same curse lands completely differently per tradition:

```papyrus
Function ApplyWerewolfTransition()
    if CurrentTradition == TRADITION_WITCHCRAFT
        SetCurseInterpretation(CURSE_WEREWOLF, "GlenmorilAccepted")
    elseIf CurrentTradition == TRADITION_DRUIDIC
        SetCurseInterpretation(CURSE_WEREWOLF, "DruidicTrial")
    elseIf CurrentTradition == TRADITION_KNIGHT
        SetCurseInterpretation(CURSE_WEREWOLF, "SpirituallyHomeless")
    endIf
EndFunction
```

**Summary of tradition × curse matrix:**

| | Imperial Divines | Druidic (Y'ffre) | Witchcraft |
|--|-----------------|-----------------|------------|
| Vampire | Horror, Nine Divines lost, knightly oaths broken | Absolute excommunication (worst), ritual re-entry possible | Partial home in Volkihar court, witch-mother acceptance |
| Werewolf | Silent, no framework, social/knightly cost | CONTESTED — Druidic Trial fires, player chooses fork | Natural fit — Glenmoril is family, Hircine already in frame |

---

**Reusable Code Pattern (LOCKED)**

Imperial ConcordatStanding and Breton WitchcraftExposure share one `PDV_ReputationTrack` script:

```papyrus
; PDV_ReputationTrack.psc — instantiated per race as needed
int Property TrackValue Auto      ; 0–100
int Property TrackState Auto      ; current threshold state
float Property DevotionModifier Auto  ; applied in ProcessDawn()

Function UpdateTrack(int delta)
  TrackValue = clamp(TrackValue + delta, 0, 100)
  RecalculateState()
EndFunction

Function RecalculateState()
  ; Threshold values set per-race on initialization
  if TrackValue < Threshold1
    TrackState = STATE_1
  elseif TrackValue < Threshold2
    TrackState = STATE_2
  elseif TrackValue < Threshold3
    TrackState = STATE_3
  else
    TrackState = STATE_4
  endif
  UpdateDevotionModifier()
EndFunction
```

**Races using this pattern:**
- Imperial: ConcordatStanding (political compliance)
- Breton: WitchcraftExposure (visibility of Daedric practice)
- Future races may reuse as needed

### 10.4 Dunmer (LOCKED)

**Setup Flow:**
```
No setup choice needed — Dunmer worship is layered, not path-based
Layer 1 (ancestor ash-prayer) is ALWAYS active — cannot be opted out
Layer 2 (Good Daedra acknowledgment) is the natural deepening — active by default
Layer 3 (primary Good Daedra focus) unlocked by sustained piety/signal threshold — player choice
Broad worship cap: Tier 2 (Faithful) — Dunmer broad practice is already devout
Tier 3 only through primary Good Daedra commitment
```

**Layered Worship Architecture (LOCKED):**

Dunmer is fundamentally different from Nord/Breton. Not competing paths — cumulative reinforcing layers.

```
Layer 1 — ALWAYS ACTIVE (ancestor ash-prayer)
  Every Dunmer maintains this regardless of everything else
  Foundation that all other layers sit on
  Events: shrine touch at dawn, morning ash-prayer, evening report to ancestors,
          night offering, community solidarity acts

Layer 2 — STANDARD FOR DEVOUT (Good Daedra acknowledgment)
  Azura, Boethiah, Mephala alongside ancestor practice
  Not a separate choice — natural deepening of Layer 1
  Re-emerging as dominant public faith in 4E 201
  Events: dawn/dusk acknowledgment (Azura), combat strength proved (Boethiah),
          secrets maintained/hidden communities (Mephala)

Layer 3 — OPTIONAL DEPTH (primary Good Daedra focus)
  Player commits to ONE of the three Good Daedra
  Triggered by sustained piety/signal threshold (same offer family as Nord/Breton)
  Ancestor practice (Layer 1) remains at FULL weight always
  Choosing Azura never reduces ash-prayer — only adds weight on top
Daedric deviation - OPTIONAL RUPTURE / PACT
  Other Daedric Princes may qualify only through the global Daedric path system
  Presents as deviation, trial, pact, taboo, curse pressure, or foreign bargain
  Aedric patron commitment is not a Dunmer 1.0 path
```

**Critical distinction:** Choosing a primary Good Daedra never competes with ancestor devotion. They are theologically the same tradition at different depths.

**Implementation split (LOCKED 2026-05-19):**
- Do not implement `PDV_State_DunmerPath` as a path/focus enum; Dunmer has no selectable worship path
- Native focus uses shared patron state: `PDV_GLO_PatronState` for broad/shared vs active primary and `PDV_GLO_PatronDeity` for the accepted focus
- Dunmer-specific state is reserved for ancestor substrate posture and curse/restoration handling
- The always-active ancestor layer is origin-gated through `PDV_Substrate_DunmerAncestor`
- Existing substrate keys use `PDV.Substrate.DunmerAncestor.*`, including `Metric`, `Tier`, `LastEvent`, `PrayerCount`, and `HomeCount`
- Add posture as `PDV.Substrate.DunmerAncestor.Posture` if a StorageUtil key is needed, with optional CK-readable mirror `PDV_GLO_State_DunmerAncestorPosture`

**Ancestor posture enum (LOCKED 2026-05-19):**
- `PDV_State_DunmerAncestorPosture` uses exact enum values: `Normal = 0`, `Strained = 1`, `Silent = 2`, `RestoredScarred = 3`
- `Normal` is the launch default for living Dunmer
- `Strained` covers werewolf / ritual-unclean states
- `Silent` covers active vampirism, where ancestor responses are inert
- `RestoredScarred` covers post-cure return: the ash-prayer works again, but the substrate remembers the silence

**Focus gate and deviation rule (LOCKED 2026-05-19):**
- Native Dunmer focus uses the global formal-offer gate: Faithful / `50` persistent piety by default, two qualifying signal-days within seven, dawn-only offer evaluation, per-deity cooldowns, no persistent offer queue, and stable accepted patron for 1.0
- Offer language presents the moment as a Reclamation deepening through the life already being lived, not abandoning ancestors or choosing a replacement religion
- Native 1.0 Dunmer focus is `Azura`, `Boethiah`, and `Mephala`
- Non-Reclamation commitments may qualify only through the global Daedric path system
- Non-Reclamation Daedric commitments present as deviation, trial, pact, taboo, curse pressure, or foreign bargain, not a fourth normal Reclamation lane
- Aedric patron commitment is not a Dunmer 1.0 path

**Contextual Favor Presentation (LOCKED):**

The shared `Layer 1 + Layer 2` state can trigger contextual favor before a primary Good Daedra focus. This is the special layered equivalent to broad worship, but should never present as a generic pantheon lane. The player experience is cumulative: the ancestors witness the act, while Azura, Boethiah, and Mephala give it shape through the Reclamations.

Default presentation:
- Shared layered favors are mostly `Quiet` or `Noted`
- `Marked` moments usually wait for primary focus, vampire cure/restoration, major diaspora burden, or major Good Daedra quest recognition
- Shared favor language should reinforce that ancestor practice remains the ground floor
- Layer 3 primary focus adds weight on top; it never replaces or reduces the ancestor layer

**Primary God Options (Layer 3):**

| God | Primary Signal Domain | Threshold Trigger | Devotional Acts |
|-----|----------------|------------------|-----------------|
| Azura | Painful truth, transformation, exile, and thresholds | Sustained Azura-coded piety | Dawn/dusk observance, truth-revealing choices, transformation/cure arcs, Azura's Star quest |
| Boethiah | Trial, overthrow, betrayal-as-test, and self-authorship | Sustained Boethiah-coded piety | Strength proved, false authority defeated, conspiracy acts, Chimeric rejection of imposed order |
| Mephala | Hidden community, lethal secrets, obligation webs, and necessary lies | Sustained Mephala-coded piety | Secrets maintained, hidden communities protected, targeted hidden violence, information-network acts |

Layer 3 Dunmer focused lanes should target five trigger families each. The three Good Daedra are full Dunmer religious centers, not thin patron tags, so each focus needs enough width to feel like a complete Devoted identity. Rows should remain additive: they describe what the chosen Prince contributes on top of the always-active ancestor ground floor.

Other two Good Daedra remain active at × 0.75 after Layer 3 commitment.

**Dunmer Daedric deviation option map (LOCKED 2026-05-19):**

| Option | Dunmer response tag | Prince path type | Strongest vanilla hooks | Class appeal / roleplay pull | Implementation posture |
|---|---|---|---|---|---|
| `Azura` | Native Reclamation | `Fate-dawn-dusk-prophecy` | `The Black Star`, Azura shrine, artifact outcome, dawn/dusk threshold acts, cure/restoration beats | Mage, healer/restorer, pilgrim, threshold-heavy roleplay | Normal Dunmer focus; no outsider stigma |
| `Boethiah` | Native Reclamation | `Struggle-overthrow-trial` | `Boethiah's Calling`, sacrifice/betrayal outcome, boss or higher-level kills, false authority removed, Altmer/Thalmor rivalry beats | Warrior, spellsword, battlemage, assassin, revolutionary | Normal Dunmer focus; reject generic cruelty/violence |
| `Mephala` | Native Reclamation | `Web-secret-murder-clan` | `The Whispering Door`, Ebony Blade, Thieves Guild/network stages, protected secrets, Grey Quarter hidden-community support | Thief, assassin, bard/social manipulator, merchant-network character | Normal Dunmer focus; reject generic crime/theft/murder |
| `Malacath` | Taboo; House of Troubles-adjacent | `Oath-exile-code-vengeance` | `The Cursed Tribe`, Volendrung, Blood-Kin/stronghold context | Heavy warrior, smith, outcast, oath-bound mercenary | Daedric path only; hard rededication on exit |
| `Mehrunes Dagon` | Taboo; House of Troubles | `Destruction-revolution-ruin` | `Pieces of the Past`, Mehrunes' Razor, destructive quest outcomes | Destruction mage, rebel, warlord, chaos fighter | Daedric path only; high rupture, no destruction spam |
| `Molag Bal` | Taboo; House of Troubles / vampire pressure | `Domination-vampirism-enslavement` | `The House of Horrors`, active vampirism, Mace of Molag Bal | Vampire, dark knight, domination mage | Curse/rupture path; ancestor posture usually `Silent` while vampire |
| `Sheogorath` | Taboo; House of Troubles pressure | `Madness-disruption-instability` | `The Mind of Madness`, Wabbajack, instability choices | Chaos mage, trickster, wild-card roleplay | Daedric path only; hard rededication |
| `Meridia` | Foreign / tolerated utility | `Cleansing-light-anti-undead overlay` | `The Break of Dawn`, Dawnbreaker, undead/necromancer cleansing | Paladin, undead hunter, restoration mage | Useful outsider service, not a Dunmer religious center |
| `Hircine` | Foreign curse pressure | `Hunt-lycanthropy-predator` | `Ill Met by Moonlight`, active lycanthropy, Companions werewolf state | Hunter, ranger, werewolf, survival fighter | Daedric/curse pressure only; no stable Dunmer framework |
| `Nocturnal` | Taboo outsider pressure | `Shadow-oath-luck-debt` | Thieves Guild, Nightingale oath, Skeleton Key | Thief, stealth archer, nightblade, luck-driven rogue | External oath; Mephala remains the native hidden-network option |
| `Hermaeus Mora` | Foreign dangerous knowledge | `Forbidden-knowledge-artifact` | `Discerning the Transmundane`, Oghma Infinium, Black Books | Scholar, mage, enchanter, seeker of secrets | Daedric path only; not core faith |
| `Namira` | Foreign corruption / outcast hunger | `Revulsion-decay-outcast-hunger` | `The Taste of Death`, Ring of Namira, corpse taboo | Outcast, dark survivalist, horror roleplay | Daedric path only; strong social and ancestor friction |
| `Sanguine` | Foreign indulgence | `Excess-temptation-indulgence` | `A Night to Remember`, Sanguine Rose, revelry/excess contexts | Bard, social rogue, party character, temptation arc | Daedric path only; appealing but unreliable |
| `Clavicus Vile` | Foreign bargain | `Bargain-wish-contract` | `A Daedra's Best Friend`, Masque/Rueful Axe outcome, Barbas/deal logic | Merchant, negotiator, pact mage, social climber | Daedric path only; bargain price must remain visible |
| `Peryite` | Foreign affliction-order | `Plague-order-lowest-task` | `The Only Cure`, Spellbreaker, disease/affliction contexts | Shield user, alchemist, plague doctor, endurance build | Daedric path only; defensive fantasy, not Reclamation faith |
| `Vaermina` | Foreign dream/nightmare | `Dream-nightmare-memory` | `Waking Nightmare`, Skull of Corruption, sleep/nightmare corruption | Illusion mage, dream/nightmare roleplay, fear caster | Daedric path only; memory/sleep price is load-bearing |

Class appeal balance: Native Dunmer focus covers mage/restoration/threshold (`Azura`), warrior/spellsword/revolution (`Boethiah`), and stealth/social/network (`Mephala`). Non-Reclamation Daedric paths broaden appeal for undead hunters, scholars, hunters, vampires, outcasts, merchants, bards, tanks, and nightmare/illusion builds without making those paths normal Dunmer religion.

**Signal Meanings (Dunmer-specific interpretation):**

```
Combat signals = acts witnessed by ancestors (honour/shame framework)
  Boethiah adds: trial, overthrow, betrayal-as-test, and self-authorship

Social signals = community solidarity, ancestor consultation, oral history
  Mephala adds: hidden communities, lethal secrets, obligation webs, and necessary lies

Lifestyle/devotional signals = shrine maintenance, offerings, daily ash-prayer practice
  Azura adds: threshold awareness, painful truth, transformation witnessed, and prophetic attentiveness
```

**Quest-choice integration (LOCKED):**
- Dunmer quest choices should layer on top of ancestor practice rather than replace it
- When a quest touches exile, family, hidden community, or Good Daedra legitimacy, it should carry heavy weight

**Heavy Dunmer quest signals (LOCKED):**
- `Azura's Star` and other twilight, painful-truth, transformation, exile, or threshold quests strongly weight `Azura`
- `Boethiah's Calling` and other trial, betrayal-as-test, false-authority, rivalry, overthrow, or strength-proving resolutions strongly weight `Boethiah`
- `The Whispering Door`, hidden-network, obligation-web, secret-keeping, or targeted hidden-violence content strongly weights `Mephala`
- `Grey Quarter`, Dunmer solidarity, refugee-protection, and diaspora-survival choices strongly weight the ancestor layer plus broad `Good Daedra` legitimacy
- `Burial`, `family duty`, and proper-dead obligations, when Skyrim exposes them, strongly weight the ancestor layer

**Azura favor boundary (LOCKED):**
Dawn, dusk, night, and magic-adjacent play do not trigger Azura contextual favor by themselves after the basic shared-layer rhythm. Focused Azura favor requires a real threshold, painful truth, transformation, exile-continuity, artifact/shrine rite, or curated major transition. Twilight frames the moment; it is not the whole moment.

**Boethiah favor boundary (LOCKED):**
Random betrayal, generic violence, casual cruelty, and ordinary faction hostility never trigger Boethiah contextual favor. Boethiah favor requires trial, overthrow, false authority, betrayal-as-test, Chimeric self-authorship, or curated quest/artifact context. This keeps Boethiah as the Reclamation of tested strength and chosen destiny rather than a broad violence-reward wrapper.

**Mephala favor boundary (LOCKED):**
Random murder, casual theft, convenient lying, and generic crime never trigger Mephala contextual favor. Mephala favor requires hidden obligation, protected community, dangerous knowledge, targeted hidden violence, a maintained network, or curated artifact/quest context. This keeps Mephala as the Webspinner of survival and lethal secrets rather than a broad crime-reward wrapper.

**Infrastructure Ceiling (LOCKED):**
No passive devotion decay — portable shrine assumed maintained.
But hard ceiling on certain acts: proper burial rites, ancestral tomb visits,
House shrine acknowledgment are impossible in Skyrim and never appear as events.
This naturally reflects diaspora reality without punishing the player arbitrarily.

**Tribunal Memory (LOCKED — passive flavour only):**
All Dunmer carry the weight of the Tribunal's fall.
No mechanical weight — cosmetic flavour layer only.
Manifest as: notification text referencing Vivec/Sotha Sil/Almalexia on
certain devotional acts. No bucket modifiers. No separate path.
Rationale: Tribunal is a dying tradition in 4E 201. Building it as a
playable path would overstate its living relevance.

---

**Curse States (LOCKED):**

**Vampire:**
```
Ash-prayer goes SILENT — ancestors do not respond to the undead
Layer 1 events become INERT (logged but weighted at zero)
Layer 2 Good Daedra path weight INCREASES:
  Boethiah and Mephala still fully reachable
  Molag Bal becomes available as new primary god (via Daedric system)
  Azura qualified — her relationship with vampires is complicated

On CURE:
  Ash-prayer functionality RESTORES
  Permanent piety/tier scar (ancestors remember the silence)
  Layer 1 resumes at full weight
  Layer 2 resumes at full weight
  Rationale: ancestors are present and they noticed. The silence was real.
```

**Werewolf:**
```
Most theologically homeless Dunmer curse combination
Hircine has NO framework in Dunmer cosmology — not recognised by Reclamations
Ancestors treat werewolf as ritually unclean (ash-prayer strained, not silent)
  Layer 1 events continue at 50% weight
  Layer 2 continues at 75% weight (Good Daedra tolerate it more than ancestors)
  No alternative path opens (unlike vampire — Hircine is genuinely foreign)

House Telvanni exception (minor):
  If player has Telvanni-associated acts in their event log
  Werewolf penalty reduces slightly (Telvanni tolerate unusual transformations)
  Not a full path — just a minor weight modifier
```

**Curse comparison:**
- Vampire: primary path closed, viable alternative opens (Good Daedra / Molag Bal)
- Werewolf: primary path strained but not closed, no alternative path available
- Vampire is more mechanically interesting; werewolf is more theologically isolated

### 10.5 Altmer (LOCKED - implementation spec closed 2026-05-30)

**Setup Flow:**
```
Step 1: Choose faction alignment
→ [Thalmor Orthodox]    ThalmørAlignment starts at 75 (enforcement as faith)
→ [The Divine Body]     ThalmørAlignment starts at 50 (moderate cultural practice)
→ [Psijic Tradition]    ThalmørAlignment starts at 25 (Old Ways, heterodox)

Step 2: Aldmeri pantheon breadth or commit to primary god
→ Pantheon breadth cap: Tier 2 (Faithful)
→ This is not a generic broad-worship lane; coherence is the lane
→ Tier 3 only through primary god commitment
→ Shared patron-state offer system; piety threshold plus sustained signal pattern
→ Faction shapes accessibility of gods, not availability
```

**Altmer implementation-lock refinements (2026-05-19):**
- Altmer uses the shared patron-state model for formal commitment. `ThalmorAlignment` is the orthodoxy/coherence track, not a Broad/Primary commitment state.
- Altmer does not use a generic broad-worship lane. The experience is Auri-El foundation plus faction-theological coherence plus secondary focus; pantheon breadth exists, but coherence is the lane.
- `ThalmorAlignment` bands remain `0-30 Heterodox`, `31-69 Orthodox Moderate`, and `70-100 Thalmor Devout`.
- Setup starts remain `75` for Thalmor Orthodox, `50` for Divine Body, and `25` for Psijic Tradition so each path begins inside its intended band while leaving room for drift.
- Lorkhan penalties are piety pressure plus narrative reaction, not harsh permanent collapse. Tier 1 can hurt, Tier 2 should meaningfully sting, and Tier 3 should mostly create dissonance and small pressure.
- Major main-story conflicts that most directly challenge Altmer theology should fire `PDV_State_AltmerCrisis` instead of simple punishment: a flavorful crisis-of-faith beat with a minimal temporary sting to reflect emotional dysregulation, then resolution through continued coherent behavior.

---

**Worship Structure: Layered Poly (same pattern as Dunmer)**
```
Layer 1 (ALWAYS ACTIVE): Auri-El focus
  Supreme deity, daily sun acknowledgment at dawn
  Foundation everything else sits on

Layer 2 (STANDARD FOR DEVOUT): Full pantheon acknowledgment
  Xarxes (genealogy/death), Magnus (magic), Trinimac (martial virtue)
  Syrabane (magical protection), Phynaster (longevity)
  All are ancestor-gods serving the same Apotheosis project

Layer 3 (OPTIONAL DEPTH): Primary secondary god
  Player commits to one deity beyond Auri-El
  Triggered by sustained piety/signal threshold
  Auri-El (Layer 1) remains at full weight always
```

**Full Pantheon — 9 worshippable gods (Lorkhan excluded):**
UESP confirmed: Auri-El, Trinimac, Magnus, Syrabane, Y'ffre, Xarxes, Mara, Stendarr, Phynaster
(10th listed is Lorkhan — excluded as active penalty, not worshippable)

| God | Domain | Primary Signal Domain | Faction Affinity |
|-----|--------|---------------|-----------------|
| Auri-El | Time, return, supreme ancestor — Layer 1 always | Layer 1 always | All |
| Magnus | Magic source, escape from Mundus | Magic/study/self-cultivation | Psijic primary |
| Trinimac | Martial virtue, civilisational defence | Martial virtue/enforcement | Thalmor primary |
| Xarxes | Ancestry, secret knowledge, death records | Ancestry + recordkeeping | Psijic / Divine Body |
| Y'ffre | Nature laws, Earthbones | Nature law / Earthbones | Divine Body / Moderate |
| Mara | Fertility, family, wife of Auri-El | Family / continuity pressure | All |
| Stendarr | Compassion, righteous rule | Compassion + righteous force | Divine Body |
| Syrabane | Magical protection, apprentices | Magical protection/study | Psijic / Divine Body |
| Phynaster | Longevity, elven heritage | Longevity / elven heritage | All (cult) |

---

**Unique Mechanic: ThalmørAlignment Track (LOCKED)**

Same reusable PDV_ReputationTrack script as Imperial ConcordatStanding and Breton WitchcraftExposure.

```
ThalmørAlignment (0–100)
Thalmor Orthodox starts: 75
The Divine Body starts: 50
Psijic Tradition starts: 25

Low (0–30) = Heterodox: scholarly independence, private doubt, Psijic-leaning
  Self-cultivation signals × 1.5
  Enforcement/martial signals × 0.75
  Magnus/Syrabane devotion paths MORE accessible
  Daedra worship RISKS exposure (breaks oldest Altmer religious law)

Mid (31–69) = Orthodox Moderate: standard practice
  All normal signal domains at × 1.0
  Full pantheon equally accessible

High (70–100) = Thalmor Devout: enforcement as worship
  Enforcement/martial signals × 1.5
  Private self-cultivation signals × 0.75
  Trinimac devotion AVAILABLE as primary
```

**Trinimac content priority (LOCKED):**
- `Trinimac` is Altmer-native but specialist, not a universal first-wave Altmer path
- Scaffold in the v3 Structural Skeleton for matrix and verifier completeness
- Make content-ready when the `Thalmor Orthodox` / martial-defense Altmer lane is built
- Do not give every Altmer pantheon member equal-depth launch implementation by default

**Actions affecting ThalmørAlignment:**

| Action | Points |
|--------|--------|
| Arrest/report Talos worshipper | +15 |
| Complete Thalmor Justiciar mission | +20 |
| Help Thalmor prisoner escape | −15 |
| Kill Thalmor agent unprovoked | −20 |
| Read banned religious texts | −5 |
| Master a new school of magic | 0 (pure cultivation, neutral) |
| Consort with Daedra | −25 (breaks oldest Altmer religious law) |

**Thalmor Orthodox faction = faith identity, not employment (LOCKED)**
An Orthodox Altmer player in Skyrim exists as a traveller/exile/independent operative
whose actions reflect Orthodox theology without being an Embassy agent.
The track handles drift toward or away from orthodoxy.

---

**Unique Mechanic: Lorkhan Adjacency Penalty (LOCKED - economy bounded)**

UESP/Imperial Library confirmed: Lorkhan is the Corpse-God, the most unholy power
in Altmer theology. He permanently broke Altmer connection to the spirit plane.
Any act validating, strengthening, or celebrating the mortal world he created
triggers a direct piety/tier reaction — bypassing ordinary domain scoring entirely.

**Why it bypasses ordinary scoring:** Not "you did something your god disapproves of" —
it's "you touched the thing that broke us." Theologically categorical.

**Lorkhan's names across cultures (all trigger same penalty):**
Lorkhan (Altmer), Shor (Nordic), Shor/Shezarr (Cyrodiilic), Sheor (Breton),
Sep (Hammerfell), Lorkhaj (Khajiit), Lorkh (Reachmen)

**Tier structure (bounded values locked 2026-05-19):**

TIER 1 — Direct Lorkhan/Shor/Talos Connection (highest penalty):
- Activating a Talos shrine / carrying Amulet of Talos
  (Talos = Shezarrine, mortal avatar of Lorkhan who achieved apotheosis)
- Helping Talos worshippers / hiding them from Thalmor
- Entering Sovngarde (Shor's Hall — Lorkhan's own afterlife domain)
- Meeting Tsun at the Whalebone Bridge (Shor's shield-thane)
- Wielding Keening (Kagrenac's Tool — forged to tap Lorkhan's Heart)
- Wielding Sunder / Wraithguard [CC] (same — Kagrenac's Tools)

TIER 2 — Shor-Adjacent / Nordic Divine Framework (moderate penalty):
- Learning/using the Thu'um (gifted by Kyne, wife of Shor)
- Being declared Dragonborn (cultural hero of Mankind, validates mortal experiment)
- Joining the Stormcloaks (explicitly a Talos-worship movement)
- Completing the Companions questline (traces to Ysgramor, fought in Shor's name)
- Visiting the Hall of Valor in Sovngarde
- Wielding Wuuthrad (Ysgramor's axe, +damage to elves — theological self-harm)

TIER 3 — Mortal-Validation Acts (minor penalty):
- Worshipping at any Nine Divines shrine (framework validates mortal plane)
- Marriage at Mara's Temple (celebrating mortal bonds — mortality as trap)
- Adopting children (investing in mortal generational continuity)
- Building a homestead (accepting mortal plane as home, not prison)
- Helping Nords with religious practices (supporting human divine infrastructure)
- Reading "Shor son of Shor" (engaging with Lorkhanic mythology)

TIER 4 — Contextual (no automatic penalty — ThalmørAlignment shift only):
- Killing Thalmor (unprovoked: −10 ThalmørAlignment)
- Septimus Signus quest (Lorkhan-adjacent motivation, not direct)
- Extensive Dwemer ruin exploration (Heart of Lorkhan contamination — minor flag)
- Joining Dark Brotherhood (Sithis — void from which Lorkhan emerged — indirect)

**Faction modifier on Lorkhan penalties:**
- Thalmor Orthodox: penalty × 1.5 (stricter theology)
- The Divine Body: penalty × 1.0 (standard)
- Psijic Tradition: penalty × 0.75 (more philosophical about mortal plane)

**Design intent (LOCKED):** Tier 3 acts are explicit mortal-validation actions,
capped and lightly weighted. This is intentional — the entire mortal world is
Lorkhan's creation, but ordinary existence is theological context rather than
an automatic penalty trigger. The penalties reflect authored moments of
low-grade dissonance: marriage, adoption, homesteading, Nine Divines
infrastructure, explicit Nord religious aid, or clearly Lorkhan/Shor-positive
material.

Lorkhan penalties are piety pressure plus narrative reaction, not harsh permanent collapse. Tier 1 can hurt, Tier 2 should meaningfully sting, and Tier 3 should mostly create dissonance and small pressure. The largest main-story theological collisions should become crisis-of-faith events with flavor and a minimal temporary sting rather than larger permanent punishment.

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

**Psijic Tradition — Unique Event (LOCKED)**

UESP confirmed: Psijic Order practices the Elder Way / Old Ways of Aldmeris —
introspection, meditation, mastery of self through Mysticism.
```
EVENT_MYSTICISM_PRACTICE
  Fires when: player uses Alteration, Illusion, or reads certain obscure tomes
  Psijic-aligned players: generates self-cultivation / magical-discipline piety
  Other factions: no shift (same action, different theological weight)
  Rationale: the Elder Way treated magical practice as meditative, not combative
```

**Quest-choice integration (LOCKED):**
- Altmer quest choices should be one of the strongest inputs in the file because orthodoxy vs heterodoxy is often legible through explicit faction decisions

**Heavy Altmer quest signals (LOCKED):**
- `Thalmor cooperation or resistance` creates major `ThalmørAlignment` shifts
- `College`, `Eye of Magnus`, and `Psijic` quest content strongly weights `Magnus`, `Syrabane`, and heterodox / `Psijic` readings
- `Helping Talos worshippers`, `Stormcloak sympathy`, `Sovngarde`, `Tsun`, and `Companions` content strongly drives the `Lorkhan Adjacency Penalty`
- `Forbidden texts`, private scholarship, and independent mystical pursuit strongly weight `Xarxes`, `Magnus`, `Syrabane`, and heterodox drift
- `Daedric quest acceptance` is a sharp negative orthodoxy signal and should outweigh ordinary magical practice

---

**Curse States (LOCKED):**

**Vampire:**
```
Auri-El absolutely closed — sun avoidance = shrinking from god of return
Genealogical records expunge the vampire from bloodline
Magic continues but loses religious framing — becomes mere power
Thalmor would euthanize on sight — extreme social danger

Tiny heretical path available (Tier 1 cap only):
  "Vampirism is at least a path away from mortal limits"
  Self-justification theology, no institutional support
  Molag Bal accessible as hostile patron
  Piety accumulates at 25% rate
  Hard ceiling: Tier 1 (Observant) — cannot progress further

No restoration path — the file says "there is no recoverable Altmer position
for a vampire." Unlike Dunmer or Breton, no cure-and-restore arc available.
```

**Werewolf:**
```
Most theologically annihilating combination in all of Tamriel (confirmed by multiple sources)
Beast-state is the precise inverse of the Apotheosis project
No heretical theology possible — regression into animality has no framework
Almost no Altmer werewolves survive their own kin

Mechanically: devotion halts entirely
No path forward — not even Tier 1 heretical cap
If player somehow survives: exile to Valenwood/Solstheim only viable option
(Bosmer beast-shape practices give minimal ideological cover)
```

---

**Reusable Code Pattern — updated:**
Imperial, Breton, and Altmer all use PDV_ReputationTrack:
- Imperial: ConcordatStanding (political compliance/defiance)
- Breton: WitchcraftExposure (visibility of Daedric practice)
- Altmer: ThalmørAlignment (theological orthodoxy spectrum)

### 10.6 Khajiit (LOCKED)

**Setup Flow:**
```
No player-facing class choice and no hard archetype selection
All Khajiit begin inside the Lunar Lattice
Broad lunar worship begins automatically
Broad lunar worship cap: Tier 2 (Faithful)
Tier 3 only through focused deity commitment
```

**Core architecture (LOCKED): layered lunar system**

Khajiit are not strict mono in practice. Their religion is built from:

```
Layer 1 — ALWAYS ACTIVE (lunar substrate)
  Riddle'Thar / ja-Kha'jay / Jone / Jode
  This is the cosmological structure of Khajiit life, not an optional deity track

Layer 2 — STANDARD KHATIJIIT DEVOTIONAL FIELD
  Major gods can become emphasized within the lunar order
  The substrate is never replaced by primary devotion

Layer 3 — OPTIONAL DEPTH (focused deity commitment)
  One deity becomes the player's strongest devotional emphasis
  Unlocks Tier 3 and stronger, narrower blessings
```

**Broad vs focused tradeoff (LOCKED):**
- Broad lunar worship can reach `Tier 2 (Faithful)`
- Focused deity worship is required for `Tier 3 (Devoted)`
- Broad worship gives wider, steadier, community-shaped benefits
- Focused worship gives narrower, stronger, more personal benefits

Rationale:
- This mirrors the cross-race architecture while preserving Khajiit specificity
- Broad lunar practice is already genuine devotion, not indecision or dilution

**Primary deity scope (LOCKED):**

**Always-active substrate only:**
- `Riddle'Thar`
- `ja-Kha'jay`
- `Jone`
- `Jode`

**Mechanically available primary deity paths:**
- `Azurah`
- `Khenarthi`
- `Alkosh`
- `Baan Dar`
- `Rajhin`

**Passive influences only (not full primary paths):**
- `Mara`
- `S'rendarr`
- `Magrus`

**Dark / curse / perpendicular pressures, not standard primary paths:**
- `Nocturnal`
- `Hircine`
- `Sangiin`
- `Namiira`
- `Lorkhaj`
- `Sheggorath`

**Khajiit lunar implementation locks (LOCKED 2026-05-19):**
- `PDV_Substrate_KhajiitLunar` is the canonical substrate owner
- Use the existing StorageUtil prefix `PDV.Substrate.KhajiitLunar.*`, extending from current keys rather than renaming them
- Canonical first keys are `Metric`, `Tier`, `LastEvent`, `LastPhase`, `ObservanceCount`, and `RoadHomeCount`
- 1.0 uses the hybrid moon model: current phase gives small per-phase activity bonuses, while full-cycle consistency determines overall substrate strength
- Prefer reliable real Skyrim Masser/Secunda state where available; if implementation proof is weak or brittle, use an abstract 28-day fallback cycle
- Khajiit remain the only no-offer race in 1.0. Focused deity emphasis shifts silently at dawn based on weighted behavior; no formal patron offer fires
- Do not use `PDV_GLO_PatronState = active primary` to represent Khajiit focus
- Add a Khajiit-specific current emphasis state, recommended as `PDV_State_KhajiitFocusedEmphasis`, with a CK-readable mirror only if implementation needs conditions
- The player notices focus through stronger domain rewards, status readout, and flavor, not a commitment prompt
- `PDV_State_KhajiitFocusedEmphasis` uses exact enum values: `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, `Alkosh = 5`
- Focus activates only when one focused deity has at least `50` persistent piety and leads the next-highest Khajiit focused deity by at least `15` piety, evaluated at dawn
- If no deity has a clear lead, the Khajiit remains in broad lunar Faithful state; balanced worship is complete and valid, not an error state
- Khajiit road homes are `2-3` player-designated rest anchors, not one sacred place
- Road-home piety requires cycling between anchors over time; repeatedly using the same camp, bed, or convenient outdoor rest does not count as cadence
- Add `PDV_State_KhajiitLunarPosture` for curse and shadow pressure, using exact enum values `Normal = 0`, `Strained = 1`, `Corrupted = 2`, and `ShadowDrift = 3`
- Active vampirism sets `PDV_State_KhajiitLunarPosture = Corrupted`; the Lattice still holds the character, but caravan/community belonging and ordinary lunar rewards weaken
- Active lycanthropy sets `PDV_State_KhajiitLunarPosture = Strained`; Hircine adds a competing shape, but Khajiit identity remains recognizably Khajiit
- `ShadowDrift` is reserved for dominant shadow behavior: Nocturnal alignment, vampire posture plus repeated night-only predation, or other explicitly shadow-coded patterns. Ordinary night travel, stealth, or moon observance must not set it
- All five focused emphases ship as valid 1.0 launch options: `Khenarthi`, `Azurah`, `Baan Dar`, `Rajhin`, and `Alkosh`
- Launch hook posture is locked: Khenarthi/open-road and Azurah/threshold are strongest general lanes; Baan Dar/reversal and Rajhin/elegant theft are behavior-specific; Alkosh/dragon-order is rare but well supported by main quest and named dragon content

**Primary deity priority in Skyrim 4E 201 (LOCKED):**
1. `Riddle'Thar / ja-Kha'jay / Jone / Jode` as substrate
2. `Khenarthi`
3. `Azurah`
4. `Baan Dar`
5. `Rajhin`
6. `Alkosh`

**Primary path accessibility (LOCKED):**
- `Khenarthi` and `Azurah` are the most routinely reachable focused paths
- `Baan Dar` and `Rajhin` are reachable but more behavior-specific
- `Alkosh` is the rarest and highest-threshold focused path

Rationale:
- This reflects practical Khajiit religious life in Skyrim 4E 201 rather than equalizing all gods into generic options

**Always-active lunar substrate event families (LOCKED):**
1. `Moon observance`
   Dawn, dusk, or night practice under visible sky
2. `Open-road / exile life`
   Sleeping outdoors, traveling at night, or life outside hold-temple infrastructure
3. `Khajiit community ties`
   Helping caravans, protecting Khajiit, or sustaining caravan/community life where Skyrim exposes those moments

**Focused path translation notes (LOCKED):**
- `Azurah`: thresholds, twilight, fate, dreams/visions, magic-adjacent or threshold behavior
- `Khenarthi`: travel, wind, road life, open-sky movement, mercy or soul-guidance-adjacent behavior
- `Baan Dar`: pariah survival, merchant-cunning, reversals, exile cleverness, survivalist trickery
- `Rajhin`: elegant theft, performance, notoriety, artful deception, mythic thief behavior
- `Alkosh`: dragon-facing, anti-chaos, order-keeping, exceptional cosmic-threat acts rather than ordinary combat

**Baan Dar vs Rajhin split (LOCKED):**
- `Baan Dar` and `Rajhin` remain separate focused paths
- `Baan Dar` covers lived survival, caravan cleverness, and road-exile cunning
- `Rajhin` covers elegant theft, theatrical trickery, and story-worthy infamy

Rationale:
- Their overlap is real, but merging them would erase a meaningful Khajiit distinction

**Moon sugar rule (LOCKED):**
- `Moon sugar` matters mechanically only in limited, curated, high-confidence ways
- It should not become a frequent general devotion trigger

Rationale:
- Skyrim cannot reliably distinguish ritual use from contraband handling or generic ingredient traffic
- Overusing moon sugar as a trigger would create false positives

**Quest-choice integration (LOCKED):**
- Khajiit quest choices should heavily weight exile, caravan solidarity, twilight thresholds, trickster survival, and dragon-order content when those themes appear

**Heavy Khajiit quest signals (LOCKED):**
- `Helping caravans`, Khajiit traders, or marginalized Khajiit strongly weights the lunar substrate plus `Khenarthi` / `Baan Dar`
- `Azura's Star` and other twilight or threshold quests strongly weight `Azurah`
- `Thieves Guild`, artful theft, and name-making trickster choices strongly weight `Rajhin` first, with `Nocturnal` treated as external pressure only when explicitly chosen
- Pariah-survival, outsider-aiding, clever-reversal, and exile-mercy quest choices strongly weight `Baan Dar`
- Main-quest dragon, order, and anti-chaos resolutions strongly weight `Alkosh`
- When explicit quest signals appear, they should outweigh ambient travel or stealth drift

**Curse States (LOCKED):**

**Vampire:**
```
The lunar substrate remains active but corrupted and weakened
Normal Khajiit devotion does not collapse entirely
Caravan/community compatibility reduces sharply
Azurah remains a possible protective reading
Nocturnal drift increases as a shadow substitute
```

Rationale:
- Khajiit identity is cosmological and biological; vampirism damages belonging rather than erasing it cleanly

**Werewolf:**
```
The lunar substrate remains mostly intact but strained
Hircine adds an off-moon shape rather than fully severing Khajiit identity
Caravan/community belonging is damaged
Khajiit devotion remains recognizably Khajiit, but under strain
```

Rationale:
- Werewolfism adds a competing shape; vampirism destabilizes identity more deeply

### 10.7 Bosmer (LOCKED)

**Setup Flow:**
```
Bosmer choose among four devotional paths at setup
The “class” labels in source analysis are explanatory only, not player classes
Path choice matters materially and is not just flavor
Switching is possible, but only in limited, high-cost ways
```

**Primary paths (LOCKED):**
1. `The Old Contract` = strict `Y'ffre / Green Pact`
2. `The Living Story` = moderate `Y'ffre`
3. `The Exchange` = `Z'en` (distinct from `Zenithar`; do not use `Zenithar` as the Bosmer Exchange stand-in)
4. `The Bandit Road` = `Baan Dar`

**Bosmer path implementation locks (LOCKED 2026-05-19):**
- `PDV_State_BosmerPath` uses exact enum values: `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`
- First-run setup should require an explicit post-startup path choice popup after Bosmer origin/startup is resolved
- If the path state is unset, corrupt, or cannot be resolved, fall back to `LivingStory` as the safest bridge path
- `OldContract` path state remains separate from `PactBound`, `GreenPactCompliance`, and `LapsedFromPact`
- `PDV_State_BosmerPath = OldContract` means the character is oriented toward the Old Contract path; `PactBound` means Y'ffre exclusivity and Green Pact compliance are currently active
- `The Living Story` and `The Old Contract` share one `Y'ffre` deity ledger; the path state changes exclusivity and Pact handling rather than selecting separate Y'ffre variants
- If a non-Old-Contract Bosmer loses path coherence through neglect, they drift toward `LivingStory` rather than becoming unset
- Path switching is explicit and destination-gated, not automatic drift
- `LivingStory` is the easiest bridge/default destination; `OldContract` is the hardest to re-enter
- First-run setup choice is free and auto-commits the matching foreground patron
- Later path switching is not a simple MCM toggle and does not use the generic deity-offer queue
- After setup, Bosmer-specific system-suggested popup offers may surface when destination evidence is sufficient, but the world must still confirm the new path through destination-gated signals and a curated rite
- `LivingStory` may be entered through one strong Living Story, community, or story-continuity signal, and remains the fallback for incoherent/corrupt path state
- `Exchange` and `BanditRoad` require two destination-coded signals on separate in-game days within seven, evaluated at dawn; a major curated quest beat may switch immediately if it clearly proves the destination path
- `OldContract` re-entry requires explicit recommitment, no terminal second renunciation, and three Pact-positive days within seven
- On `OldContract` re-entry, `GreenPactCompliance` snaps to 30 so the player is Lapsed but recoverable, not instantly Observant
- Preserve path deity ledgers when switching; only the active path receives full scoring, contextual favor, and Champion eligibility
- After a path switch, automatic switching is locked for seven in-game days unless an explicitly authored major exception fires

**Shared Green Pact memory rule (LOCKED 2026-05-19):**
- Green Pact respect is culturally meaningful for all Bosmer paths, not only `OldContract`
- Proper hunting conduct, animal-sourced food, avoidance of needless plant use where the game can detect it cleanly, and respect for the living world may provide modest positive weighting across `LivingStory`, `Exchange`, and `BanditRoad`
- `OldContract` remains the only path with Green Pact penalties, `GreenPactCompliance`, forced reckoning, Y'ffre exclusivity, and terminal renunciation
- Non-Old-Contract paths should not receive plant-use penalties or GPC loss; at most, they miss the shared positive weighting
- Implementation should treat this as shared Bosmer signal weighting, not as a hidden background `OldContract` or Y'ffre covenant ledger
- Shared Pact-positive signals are tagged once, then interpreted by the active path's scoring table: `LivingStory` reads them as inheritance/story continuity, `Exchange` as balance with the living world, and `BanditRoad` as old survival memory
- These shared weights may add modest path-local piety or recent-signal strength, but they do not write `GreenPactCompliance`, do not advance `PactBound`, and do not trigger Old Contract penalties outside `OldContract`
- Rationale: the Green Pact is a core Bosmer cultural inheritance, but only Old Contract characters submit to the hard covenant burden

**Secondary Bosmer religious layer (LOCKED):**
- `Arkay`
- `Xarxes`
- `Mara`
- `Stendarr`

**External pressures, not core Bosmer paths (LOCKED):**
- `Hircine`
- `Nocturnal`

Rationale:
- `Baan Dar` is a better Bosmer-native trickster/survival path than `Nocturnal`
- `Nocturnal` is a Skyrim criminal overlap, not a Bosmer theological backbone
- `Hircine` matters, but as hunt / shape / curse pressure rather than a normal core lane

**The Old Contract (LOCKED, amended 2026-05-17):**
```
Only Bosmer path with hard or semi-hard Green Pact compliance mechanics
Uses PDV-owned Green Pact tags and path-specific rule checks
Represents strict orthodoxy and the heaviest devotional burden
Has the highest ceiling of all Bosmer paths as payoff

State model:
  PactBound          : binary flag — Y'ffre exclusive while true
  GreenPactCompliance: 0–100 meter, act-driven, no passive decay
  LapsedFromPact     : int counter, caps re-entry at one cycle

Bands (Y'ffre gain multiplier while PactBound):
  Apostate  0–19    locked (0%)
  Lapsed    20–49   50%
  Observant 50–79   100%
  Strict    80–100  120%

Transitions:
  Entry      : setup choice OR MCM toggle + qualifying in-world act
  Voluntary  : MCM Renounce, single confirmation
  Forced     : 3 in-game days in Apostate → re-commit-or-renounce prompt
  Re-entry   : permitted exactly once; GPC initializes at 20
  Terminal   : 2nd renunciation freezes Y'ffre permanently; toggle disables

Wild Hunt: lore context only. NOT a player-facing track or state.
```
Full spec: `references/PDV_BosmerPactModel_Planning.md`.

**The Living Story (LOCKED):**
```
Uses the shared event/curated-signal architecture
Adds a light Bosmer-only ForestAttunement overlay
Restricted to high-confidence detectable triggers only
```

**The Living Story gameplay identity (LOCKED):**
- Y'ffre-led, but rounded out by stronger influence from the secondary Bosmer gods
- Not “Y'ffre-lite” and not failed orthodoxy
- Represents Bosmer diaspora spirituality outside full Pact enforcement

**The Living Story event structure (LOCKED):**
- Lifestyle/devotional signals: Y'ffre + Arkay
- Social/community signals: Mara + Xarxes + Stendarr
- Combat/restraint signals: Y'ffre hunting conduct + Stendarr restraint
- `ForestAttunement`: built only from reliable Skyrim-observable proxies

**The Living Story trigger rule (LOCKED):**
- Use only high-confidence detectable triggers even if this is mechanically narrower than the full lore ideal

Rationale:
- Detectable and defensible beats richer-on-paper but unreliable

**The Exchange / Z'en (LOCKED):**
```
Primarily about reciprocal justice, rebalancing, and owed return
Allows vengeance when proportionate and thematically justified
Carries a soft secondary touch of economic balance, fair trade, and proper exchange
Never becomes a generic merchant-profit path
```

**The Exchange architecture (LOCKED):**
- Shared event/curated-signal architecture
- Social/community and combat/reckoning signals do most of the justice work
- Lifestyle/craft/trade signals carry the softer toil and balance-of-living layer

**The Bandit Road / Baan Dar (LOCKED):**
```
Bosmer-native survival and trickster path
Focused on exile cunning, theft for survival, road-life improvisation, and evasive success
Must not collapse into generic stealth/crime gameplay
```

**Path separation rules (LOCKED):**
- `The Old Contract` is the only path with direct Pact enforcement
- `The Living Story` is broader and more secondary-gods-amplified than `The Old Contract`
- `The Exchange` is justice and balance first, commerce second
- `The Bandit Road` is survival-cunning first, not polished criminal mystique

**Quest-choice integration (LOCKED):**
- Bosmer paths should rely heavily on explicit quest choices when available because ambient detection of Bosmer theology is sparse
- Only high-confidence quest signals should carry strong weight

**Heavy Bosmer quest signals (LOCKED):**
- `Forest`, wild-community defense, respectful-hunt, and anti-desecration quest choices weight `The Old Contract` or `The Living Story` depending on severity and Pact intensity
- `Community continuity`, mercy, kin protection, and preservation choices strongly weight `The Living Story`
- `Redress`, vengeance, debt-settling, and balance-restoring resolutions strongly weight `The Exchange`
- `Survival theft`, evasive escape, road improvisation, and anti-authority trickster wins strongly weight `The Bandit Road`
- `Sinding`, `Hircine`, or beast-shape quest content acts as external pressure only and does not count as normal Bosmer core progression

**Curse States (LOCKED):**

**Vampire:**
- Use the already-established Bosmer vampire reading from the curse source file
- Vampire remains a harder theological break than werewolfism across all Bosmer paths

**Werewolf:**
```
The Old Contract:
  Treat werewolfism as a serious theological violation
  Hircine provides an illicit rival route to shapeshifting that echoes the Wild Hunt without Y'ffre's sanction

The Living Story / The Exchange / The Bandit Road:
  Treat werewolfism as contested strain rather than automatic collapse
  Use the same general werewolf treatment across these three routes
```

Rationale:
- Wild Hunt linkage makes werewolfism intelligible to Bosmer theology
- It does not make werewolfism orthodox or Green Pact-approved

**Path switching (LOCKED):**
```
Limited switching only
No free drift between Bosmer paths
No fully permanent lock either
Switches must happen through meaningful threshold events and carry real cost
```

**Destination-sensitive switching rules (LOCKED):**
- `The Living Story` is the easiest bridge path
- `The Old Contract` is the hardest to leave and hardest to re-enter cleanly
- `The Exchange` and `The Bandit Road` sit between those poles

### 10.8 Redguard (LOCKED)

**Setup Flow:**
```
Redguards choose a societal-religious frame at setup
The three paths are:
  Crown
  Forebear
  Ash'abah

All three remain part of the same Yokudan religious universe
They differ by current-era 4E 201 emphasis, daily interpretation, and social burden
```

**Core architecture (LOCKED):**
1. `Sect choice`
   `Crown`, `Forebear`, or `Ash'abah`
2. `Preferred god weighting`
   Same wider Redguard pantheon, weighted by sect and current-era life in Skyrim
3. `Always-on ancestor reverence layer`
   Strongest around death, tombs, undead, legacy, and funerary duty

Rationale:
- This layers like Dunmer in structure, but not in depth or primacy
- Ancestor reverence is not the whole spine of Redguard religion
- It is a constant obligation and interpretive layer

**Ancestor reverence layer (LOCKED):**
- Always on for all Redguards
- Strong for `Crown`
- Moderate for `Forebear`
- Very strong for `Ash'abah`
- Never a separate selectable path or deity focus
- Implement as a light origin-gated modifier / substrate-style helper, not as a selectable path or full second blessing family
- It may add small death-adjacent piety weight, anti-undead recognition, and Hall of the Dead / equivalent privilege surfaces
- It must stay quieter than the active sect/focused deity lane

**Current-era 4E 201 weighting rule (LOCKED):**
- Weight gods by how a Redguard in Skyrim would actually live and interpret them in 4E 201
- Do not flatten the pantheon into equal pan-historical relevance

**Redguard sect implementation locks (LOCKED 2026-05-19):**
- `PDV_State_RedguardSect` uses exact enum values: `Crown = 0`, `Forebear = 1`, `AshAbah = 2`
- First-run setup should require an explicit sect choice
- If sect state is unset, corrupt, or cannot be resolved, fall back to `Forebear` as the broadest Skyrim bridge position
- Sect state is an orthogonal identity axis; broad vs focused primary commitment uses shared patron state, not a Redguard-specific Broad/Primary track
- `Crown` <-> `Forebear` switching requires two sect-coded signals on separate in-game days within seven, evaluated at dawn; a major curated sect-defining quest beat may switch immediately
- `AshAbah` entry requires a major death, undead, tomb, funerary, or impurity-bearing burden signal; casual undead fighting is not enough
- Leaving `AshAbah` requires a clear sect reorientation signal plus the same two-day/six-day Crown or Forebear destination proof; do not drift out because the player had a quiet week
- Formal focused-deity commitment uses the global offer gate: Faithful / `50` persistent piety, two qualifying signal-days within seven, dawn-only offer evaluation, per-deity cooldowns, no persistent queue, and stable accepted primary for 1.0
- Sect filters deity priority and presentation, but does not replace shared patron-state machinery

**Redguard hook feasibility cross-check (LOCKED 2026-05-19):**
- Strong launch hooks: Kill Actor Story Manager with undead classification; `LocTypeDraugrCrypt`, `LocTypeClearable`, and Nordic ruin location keywords; Hall of the Dead / Arkay quest stages; PDV-authored Tu'whacca devotional surface; curated quest-stage rows for death, necromancy, and burial outcomes
- Medium launch hooks: Forebear contracts, service, bounty/delivery, and mixed-society work through curated quest stages; travel through location-change plus no-fast-travel validation; Crown and Leki honorable combat through kill event plus weapon/sneak/follower/context filters
- Rare/controlled hooks: HoonDing make-way through major quest milestones, dragons/named bosses, final boss clears, or combat-resolution checks for outnumbered / outleveled fights; curated milestones belong in 1.0, while combat-odds triggers require proof testing, weekly caps, and anti-farm controls
- Weak vanilla hooks: Ash'abah social stigma, Redguard dignity dialogue, and Yokudan form maintained in foreign spaces; these can ship in 1.0 only as light authored/custom content, not broad vanilla social simulation
- Implementation posture: launch can support the duty side of Ash'abah well and may include light social stigma through custom Redguard reaction lines and status text; do not add Ash'abah service penalties for 1.0. Full dynamic social treatment remains post-1.0
- `MS08` / `In My Time Of Need` is verified in Skyrim.esm as QUST `Skyrim.esm:01CF25`; stage `200` completes the Saadia-helped route, and stage `201` completes the Kematu/Alik'r-delivery route. One-time sect meaning is locked: stage `201` is Crown / Hammerfell justice / ancestor-duty positive; stage `200` is Forebear / exile-protection / anti-Alik'r positive.
- Tu'whacca should not collapse into Arkay. Redguard copies the Dunmer portable/private shrine implementation pattern: a permanent portable devotional item usable anywhere, with a player-owned-property or authored private-shrine bonus. The Redguard object is a portable Far Shores token, with optional sword-tending rite texture. Arkay shrines are fallback death infrastructure only, especially for Hall of the Dead service or Forebear interpretive overlap.

**Shared active Redguard god pool (LOCKED):**
- `Satakal`
- `Ruptga`
- `Tu'whacca`
- `Tava`
- `Morwha`
- `Zeht`
- `Onsi`
- `Leki`
- `HoonDing`
- `Diagna`
- `Sep`

**Forebear interpretation overlap allowed (LOCKED):**
- `Arkay`
- `Akatosh`
- `Zenithar`
- `Stendarr`
- `Dibella`
- `Julianos`

Rule:
- Yokudan names remain primary in gameplay
- Imperial parallels remain interpretive background only

**Shared 4E 201 Redguard spine (LOCKED):**
- `Satakal`
- `Tu'whacca`
- `Ancestor reverence`

Rationale:
- These are the two most universally weighted Redguard religious forces across all three sects
- Sect differences change interpretation more than whether they matter

**Sect identities (LOCKED):**

**Crown**
- Preservation, orthodoxy, bearing, sacred martial inheritance, keeping Yokudan form intact in exile
- Strong ancestor layer
- May receive rare make-way favor only as Ruptga/HoonDing-adjacent sacred survival through honorable adversity, not Forebear improvisation or social adaptation

**Forebear**
- Adaptation, public life, pragmatic survival, and living Redguard identity in mixed or foreign spaces
- Moderate ancestor layer
- More tolerant of Imperial-name parallels in interpretation

**Ash'abah**
- Funerary duty, impurity borne for others, undead-cleansing, loyalty to the dead at social cost
- Very strong ancestor layer
- Costly, stigmatized duty path
- Available both at setup and as a later drift/unlock path

**Ash'abah burden rule (LOCKED):**
- Ash'abah gains stronger devotion potential around death, tombs, undead, and funerary duty
- Ash'abah loses normal social standing and broad community ease relative to Crown and Forebear
- Routine undead-cleansing and burial duty should usually be Noted; Marked moments require real burden-bearing such as major tombs, major necromancer operations, costly impurity choices, or later custom social-stigma content

**Broad → focused structure (LOCKED):**
```
All three sects begin in broad sect-shaped Yokudan worship
Broad worship can reach Tier 2 (Faithful)
Tier 3 (Devoted) requires focused primary deity emphasis
```

Rationale:
- Broad Redguard worship is still real devotion, not indecision
- Focused commitment is what unlocks deepest personal favor

**Contextual favor lane implication (LOCKED):**
- `Crown`, `Forebear`, and `Ash'abah` broad worship count as separate broad-worship devotional lanes for contextual-favor authoring
- They share a Yokudan spine, but do not collapse into one generic Redguard/Yokudan broad lane

**Ash'abah broad worship rule (LOCKED):**
- Even broad Ash'abah worship is narrower and more tightly pulled toward `Tu'whacca` and ancestor duty from the start

**Focused deity options by sect (LOCKED):**

**Crown**
- `Satakal`
- `Tu'whacca`
- `Ruptga`
- `Leki`
- `Onsi`
- `HoonDing` as rarer / situational

**Forebear**
- `Satakal`
- `Tu'whacca`
- `Tava`
- `Leki`
- `Zeht`
- `HoonDing`
- `Morwha` as softer / social option

**Ash'abah**
- `Tu'whacca`
- `Satakal`
- `HoonDing`
- `Ruptga` as harder / less common

**Not normal focused-primary status (LOCKED):**
- `Sep` as cautionary, not devotional
- `Ancestor reverence` as always-on layer, not selectable primary
- `Diagna` as situational / heroic pressure unless later gameplay demands more

**Current-era sect weighting (LOCKED):**

**Crown**
- Highest: `Satakal`, `Tu'whacca`, `Ruptga`, `Leki`, `Onsi`
- Strong: `Tava`, `HoonDing`, ancestor layer
- Moderate: `Zeht`, `Morwha`
- Situational: `Diagna`
- Cautionary / non-devotional: `Sep`

**Forebear**
- Highest: `Satakal`, `Tu'whacca`, `Tava`, `Leki`, `HoonDing`
- Strong: `Zeht`, `Morwha`, ancestor layer
- Moderate: `Ruptga`, `Onsi`
- Syncretic interpretive overlap allowed with Imperial parallels
- Situational: `Diagna`
- Cautionary: `Sep`

**Ash'abah**
- Highest: `Tu'whacca`, `Satakal`, ancestor layer
- Strong: `Ruptga`, `HoonDing`
- Moderate: `Leki`, `Onsi`, `Tava`
- Softer: `Zeht`, `Morwha`
- Situational: `Diagna`
- Cautionary: `Sep`

**Quest-choice integration (LOCKED):**
- Redguard architecture should read current in-game quest choices as one of the main ways sect identity becomes legible
- Quest signals around exile, honor, proper death, and “making a way” should outweigh passive combat or travel drift when explicit

**Heavy Redguard quest signals (LOCKED):**
- `Undead-cleansing`, necromancer, tomb, Hall of the Dead, and burial-duty quests strongly weight `Tu'whacca` plus the ancestor layer, especially for `Ash'abah`
- `Alik'r`, Hammerfell diaspora, honor-claim, and public Redguard-dignity choices strongly reweight `Crown` vs `Forebear` emphasis
- `Mercenary`, service, contract, and mixed-society negotiation quests strongly weight `Forebear`
- `Impossible-odds`, breakthrough, and path-making resolutions strongly weight `HoonDing`
- `Blade discipline`, martial honor, and refusal of cowardly advantage strongly weight `Leki` and `Onsi`
- Quest outcomes touching mortality, exile, or communal burden should be able to reweight sect standing more than ambient survival actions

**Curse States (LOCKED):**

**Vampire:**
```
Near-total collapse of normal Redguard devotion across Crown, Forebear, and Ash'abah
No meaningful positive Yokudan substitute path
Far Shores destiny is broken while the curse remains active
Sect identity persists as memory and grief, not active religious function
```

Rationale:
- `tamriel-cursed-worship-4e201.html` makes clear that Redguard vampirism breaks Tu'whacca's guidance, the Far Shores, Tall Papa's mortal design, and even sword-blessing practice

**On CURE from vampirism:**
```
Redemption is possible
Restoration happens first through Tu'whacca, proper mortality, ancestor order, and right re-entry into the cycle
Only after restoration may the player re-dedicate to a specific primary god again
```

**Werewolf:**
```
Sect and god structure remain accessible
Favor and interpretation are strained
No true Hircine-integrated Redguard path opens
The condition remains theologically homeless rather than positively integrated
```

Rationale:
- The curse file supports strain, homelessness, and conflict, but not the total collapse seen in vampirism

### 10.9 Orc (LOCKED)

**Setup Flow:**
```
Orcs do not choose among multiple normal primary religions
The core religious spine is Malacath
Player setup chooses or implies a lived social mode, not a different god
```

**Core architecture (LOCKED):**
- One core religion: `Malacath`
- Three main lived modes:
  - `Stronghold Orc`
  - `City Orc`
  - `Legion / service / exile Orc`
- These are not different theologies
- They are different ways of carrying Malacath's code under different social conditions

Rationale:
- In 4E 201 Skyrim, the live Orc question is not “which god?”
- It is “how fully can this Orc live inside Malacath's order?”

**Trinimac rule (LOCKED):**
- `Trinimac` is a rare exceptional ideological pressure or fringe alternative
- Not a normal player-selectable core Orc path in 4E 201 Skyrim

Rationale:
- Important historically and politically
- Not the main everyday religious function of Skyrim-era Orc life

**Mode hierarchy (LOCKED):**
- `Stronghold Orc` is the full-expression baseline of Malacath's religion
- `City Orc` and `Legion / service / exile Orc` are partial or compromised expressions of the same code

**Progression structure (LOCKED):**
- Orc progression begins in broad `Malacath` devotion only
- There is no separate focused-primary deity layer
- Deepening comes through mode-specific Malacath excellence

**Content priority (LOCKED):**
- `Malacath` is not delayed as the Orc core religion
- Deeper Orc content should wait for the Orc life-mode state track so Stronghold, City, and Legion / service / exile expression can be built cleanly
- Do not add Trinimac or another side-god path as an early substitute for Orc depth

**Mode-specific deepening (LOCKED):**

**Stronghold Orc**
- Forge excellence
- Oath-keeping
- Communal provision
- Challenge and proven strength
- Full belonging under shrine, chief, forge, and stronghold order

**City Orc**
- Private Malacath fidelity under public compromise
- Quality labor and dignity without full stronghold structure
- Maintaining Orc identity while living in mixed society
- Some public integration with non-Orc institutions is tolerated without counting as betrayal by default

**Legion / service / exile Orc**
- Honor under foreign discipline
- Contract and oath still matter
- Martial competence and endurance under humiliation or displacement matter
- Malacath is carried privately when the surrounding structure belongs to someone else

**Switching rules (LOCKED):**
- Limited switching only
- No casual fluid swapping between modes
- Mode changes are socially and religiously consequential

**Asymmetric switching (LOCKED):**
- `Stronghold Orc` is hardest to enter and re-enter
- `City Orc` is the easiest bridge state
- `Legion / service / exile Orc` is easier to fall into through circumstance, but harder to leave cleanly once it has defined the player for a long time

**Mode ceilings (LOCKED):**
- `Stronghold Orc` has the highest devotion ceiling
- `City Orc` and `Legion / service / exile Orc` have lower ceilings
- Their compensation is broader survivability and flexibility, not equal devotional depth
- Numeric lock: implemented as a daily-rate multiplier in ProcessDawn — `Stronghold ×1.00`, `City ×0.75`, `Legion / service / exile ×0.60` of base. Thresholds (25/50/85) are identical across modes; only the rate differs. Calendars and rationale in `references/authoring/PDV_SignalDensityAudit.md` and `PDV_PietyPaceBalancingTable.md`

**High-confidence trigger rule (LOCKED):**
- `City Orc` and other compromise modes should only use high-confidence detectable Skyrim proxies
- Do not attempt brittle social simulation for urban compromise

**Contextual favor lane rule (LOCKED 2026-05-19):**
- Orc contextual favor is authored through the current Malacath life-mode, not through one generic Malacath lane
- `Stronghold Orc`, `City Orc`, and `Legion / service / exile Orc` each count as separate devotional lanes for contextual-favor authoring
- Stronghold mode has the strongest vanilla support: stronghold locations, Blood-Kin, `The Cursed Tribe`, Orc community factions, forge/labor hooks, and proven-strength events
- City and Legion / service / exile dignity, oath, and service content must use curated high-confidence hooks only: quest stages, faction ranks, favor/disposition proxies, explicit service milestones, or PDV-authored sacred-place/community state
- Do not attempt broad simulation of public disrespect, contract honor, or generic oath-breaking unless an implementation pass proves a concrete hook

**Orc contextual-favor table locks (LOCKED 2026-05-19):**
- Launch table targets four trigger families per life-mode; avoid padding City or Legion / service / exile to five without a strong hook
- Forge favor requires quality, value, or context; raw crafting count never triggers favor
- Blood-Kin and `The Cursed Tribe` are the main Marked Stronghold moments
- City Orc dignity is curated-hook only; generic persuasion, intimidation, or ambient disrespect does not trigger favor
- Legion / service / exile favor requires completed pressure-bearing service; faction membership alone is context, not a trigger
- Stronghold worthy-challenge favor is Quiet by default; reserve Noted presentation for stronghold crisis, boss, trial, or Malacath-significant fights
- Self-made community can serve both City Orc and Legion / service / exile Orc, but only through `PDV_SacredPlace` or faction-favor proxy hooks; City presents it as belonging built, while Legion / service / exile presents it as burden returned from
- Legion / service / exile endurance is context, not piety by itself; overextension may receive only tiny flavor or funny debuff at most
- Communal provision and oath kept stay bundled for launch unless implementation discovers clean separate hooks
- Orc contextual favor is review-cleared for user-experience shape; implementation-costing remains before build

**Life-mode selection rule (LOCKED 2026-05-19):**
- `City Orc` is the default bridge state for an Orc who is not currently proven inside a stronghold or bound into a service / exile pattern
- `Stronghold Orc` requires `Blood-Kin` or equivalent stronghold acceptance plus active stronghold conduct; location alone is not enough
- `Legion / service / exile Orc` requires explicit service / exile commitment or a completed pressure-bearing service milestone; faction membership alone can make the lane eligible but does not switch the favor lane or trigger favor
- Mode changes happen at major gates or dawn consolidation after sustained evidence, not from one stray quest, one city visit, or one dungeon
- The player may declare a mode during setup / MCM, but the world can challenge or confirm it through high-confidence signals

**Life-mode implementation rule (LOCKED 2026-05-19):**
- Implement Orc mode as one active state track, `PDV_State_OrcLifeMode`, with exactly one active scoring / favor lane at a time
- Enum values are `City = 0`, `Stronghold = 1`, `LegionExile = 2`
- The active state modifies Malacath piety rate, contextual-favor eligibility, and CK-readable mode conditions
- Player setup / MCM records intent, not entitlement; if the declared mode is not eligible, the active lane remains or returns to `City` until confirmed by world signals
- Use `PDV_GLO_State_OrcLifeMode` for CK-readable current state and StorageUtil keys for intent, eligibility, last switch time, lock-in, and recent mode evidence
- Suggested StorageUtil keys: `PDV.Track.OrcLifeMode.Intent`, `PDV.Track.OrcLifeMode.LastSwitch`, `PDV.Track.OrcLifeMode.LockInUntil`, `PDV.Track.OrcLifeMode.EligibleStronghold`, and `PDV.Track.OrcLifeMode.EligibleLegionExile`
- Mode transition helpers should be `SetOrcLifeMode(mode, reason)`, `RecordOrcModeSignal(mode, strength, reason)`, and `EvaluateOrcLifeModeAtDawn()`
- `Stronghold` may switch immediately on a major gate that already proves conduct, such as `Blood-Kin` gained through stronghold aid or `The Cursed Tribe` resolved in a pro-stronghold way; otherwise it requires eligibility plus two qualifying stronghold signals on separate in-game days within a seven-day window
- `LegionExile` may switch immediately on completed pressure-bearing service or explicit exile / service commitment; faction membership grants eligibility only; otherwise it requires two qualifying service / exile signals on separate in-game days within a seven-day window
- Soft mode switches are evaluated at dawn consolidation, while major gates may switch immediately
- After a mode switch, automatic soft switching is locked for three in-game days unless a major gate fires
- Leaving `Stronghold` requires contradiction or sustained confirmed life elsewhere; travel time alone never demotes the player
- Leaving `LegionExile` requires completed service resolution plus community reinvestment, or a new stronghold gate; quitting a faction is not enough

**Quest weighting rule (LOCKED):**
- Orc life-modes are driven by both:
  - repeatable behavioral signals
  - major quest-choice signals
- Quest choices carry heavier weight when they clearly expose Malacath's code

Rationale:
- The mod's primary goal is to make the player's actual Skyrim life feel theologically meaningful

**Heavy Orc quest signals (LOCKED):**
- `The Cursed Tribe` / Largashbur
- `Blood-Kin`
- chief weakness, challenge, or communal crisis
- whether the player aids, ignores, or exploits Orc communities

**Non-stronghold Orc quest signals (LOCKED):**
- Handling foreign institutions and unequal belonging
- Honoring contracts under people who do not fully respect you
- Maintaining quality labor without stronghold recognition
- Carrying Orc dignity inside Imperial or mixed structures
- Accepting consequence without self-erasure
- Refusing cowardly advantage outside Orc communal enforcement

**Spiritual authority layer (LOCKED):**
- `Shamans`
- `Witch Doctors`
- `Wise Women`

Role:
- Always-present spiritual authority layer
- Strongest presence in `Stronghold Orc`
- Weaker / remembered presence in `City Orc`
- Rarest / internalized presence in `Legion / service / exile Orc`

**Secondary belief texture (LOCKED):**
- `The Allfire` is real but secondary belief texture
- Do not build a major progression system around it

**Rare sacred-trial content (LOCKED):**
- `Gar-shutan`
- `Abbas`
- `Abasseen`

Rule:
- Rare exceptional sacred-trial / shamanic-vision content only
- Not core Orc progression architecture

**Blood-Kin rule (LOCKED):**
- `Blood-Kin` and stronghold acceptance are the main gateway into `Stronghold Orc` standing
- This is the primary route for entering or re-entering stronghold life from other modes

**Bridge-state rule (LOCKED):**
- `City Orc` is the default bridge state for Orcs not currently recognized by a stronghold

**Burden rule (LOCKED):**
- `Legion / service / exile Orc` carries the highest endurance / humiliation burden
- It does not have the highest devotion ceiling

**Curse States (LOCKED):**

**Vampire:**
```
Near-total collapse of normal Orc belonging
Exile from stronghold acceptance
Malacath devotion becomes hollow or nonfunctional
No real positive Orc theological replacement
```

**Werewolf:**
```
Conditional acceptance depending on proven strength and control
Possible tolerance in some stronghold contexts
Still readable through Malacath's code, but always under pressure
Not a free positive buff; a demanding test
```

Rationale:
- Matches `tamriel-cursed-worship-4e201.html`
- Vampirism becomes dependency and contradiction
- Werewolfism remains conditionally defensible if strength and discipline are proven

### 10.10 Argonian (LOCKED)

**Setup Flow:**
```
Argonians do not use a normal deity-choice architecture
Their religion in Skyrim is built as a layered custom exile system
The player begins inside absence, not abundance
```

**Core architecture (LOCKED):**
1. `Hist relation`
   The always-primary layer
2. `Collective / community identity`
   The second layer
3. `Sithis acknowledgment`
   The third layer

Rationale:
- These are not three equal gods or parallel devotion lanes
- The Hist remains constitutive even in absence
- Community is the main survival structure in exile
- Sithis is more foregrounded in Skyrim exile, but never equal to the Hist

**Player-experience translation (LOCKED):**
- `Hist relation` answers: how connected am I to what makes me Saxhleel at all?
- `Collective / community identity` answers: if the Hist is distant, am I still being held together by my people?
- `Sithis acknowledgment` answers: how much am I making meaning through change, death, void, and acceptance rather than through belonging?

**Argonian implementation locks (LOCKED 2026-05-19):**
- `PDV_Substrate_ArgonianHist` is the canonical substrate owner
- Use one layered substrate with visible `Hist`, `People`, and `Void` readout layers, not three selectable paths or patron commitments
- Use the StorageUtil prefix `PDV.Substrate.ArgonianHist.*`
- Canonical first keys are `Hist`, `People`, `Void`, `Tier`, `LastHistEvent`, `LastPeopleEvent`, `LastVoidEvent`, `LastMaintenanceDay`, `SithisSignalCount`, `BedOfChoiceSleepCount`, and `BedOfChoiceLastSleep`
- `Hist` remains primary; `People` can buffer low Hist relation; `Void` can stabilize but never replace the Hist
- Hist distance is dawn-evaluated and always gently running in Skyrim. If no valid Hist-maintenance signal occurred in the last three in-game days, reduce `Hist` by `1` per dawn, with a non-curse floor of `20`
- Valid Hist maintenance comes from water, wetland, rest, reflection, and the 1.0 Hist sap meditation tool; ordinary helping quests, ordinary combat, and generic crafting do not restore Hist
- 1.0 does not provide full home-equivalent restoration outside Black Marsh
- Argonian bed of choice uses the shared `PDV_SacredPlace` pattern with `MaxLocations = 1`
- Bed-of-choice cadence is three qualifying sleeps at the chosen bed within a rolling 30 in-game days. Missing cadence removes the place bonus and applies light `People` decay, not harsh punishment
- Sithis baseline awareness is always present, but full active `Void` scoring requires at least three significant Sithis signals. Joining the Dark Brotherhood counts as one major signal, not full activation by itself
- Valid full-activation signals are Dark Brotherhood milestones/contracts and curated death/void/change choices. Generic stealth, generic murder, and ordinary killing do not count
- Add `PDV_State_ArgonianHistPosture` with exact enum values `Normal = 0`, `Distant = 1`, `Strained = 2`, `Silenced = 3`, and `Corrupted = 4`
- Low uncursed Hist relation may become `Distant`; active lycanthropy sets `Strained`; active vampirism sets at least `Silenced`, and may become `Corrupted` when paired with Molag Bal / domination / feeding-pattern pressure
- Vampire is the deep grief state: Hist silenced or corrupted, community damaged, and Sithis more available but not automatically good
- Werewolf is serious strain but recoverable: altered shape, stressed Hist relation, but Saxhleel identity remains intact

**Tiered implementation plan (LOCKED):**

**Tier A — vanilla-hook core**
- light Hist decay
- community / Assemblage weighting
- Dark Brotherhood / Sithis weighting
- water / swamp / rest / reflection proxies
- curse-state interaction

**Tier B — optional later enrichment**
- a small number of custom Argonian ritual hooks if the vanilla core proves too thin

Rationale:
- Argonians have rich lore but limited vanilla hook surface
- The core should be honest first, then enriched only where needed

**Hist relation (LOCKED):**
- Lightly but constantly under pressure in Skyrim
- Decays slowly without maintenance
- Recovers only from a small, careful set of signals
- Intentionally harder to build than `Collective / community identity`

**Hist relation recovery rule (LOCKED):**
- Primarily environmental and reflective proxies
- Stronger signals: swamps, wetlands, waterways, solitude/rest, meditative or reflective moments
- Generic helping quests and ordinary combat do not meaningfully restore Hist relation

**Collective / community identity (LOCKED):**
- Strongest vanilla-facing Argonian gameplay layer
- Does not replace the Hist
- Can partially buffer low `Hist relation`
- This is one of the race's defining exile survival mechanics

**Community weighting rule (LOCKED):**
- Helping Argonians anywhere in Skyrim counts
- `Windhelm / Assemblage` carries extra-heavy weight
- Other Argonian support elsewhere carries standard weight

**Sithis acknowledgment (LOCKED):**
- Every Argonian has a light baseline awareness of Sithis as change / void / death
- It becomes a major active lane only through strong repeated signals
- It is not a setup-choice equivalent to the Hist
- It can stabilize a low-Hist Argonian, but never fully compensate for Hist loss

**Skyrim exile foregrounding rule (LOCKED):**
- `Sithis` is more foregrounded in Skyrim exile conditions than in homeland Argonian life
- This does not promote Sithis to equal status with the Hist

**Quest-choice integration (LOCKED):**
- Argonian quest weighting should use the clearest vanilla hooks and avoid pretending thin signals are rich ones

**Heavy Argonian quest signals (LOCKED):**
- `Collective / community identity`
  - strongest from helping Argonians anywhere in Skyrim
  - extra-heavy from `Windhelm / Assemblage`
  - also strengthened by protecting marginalized Saxhleel and preserving identity under pressure
- `Hist relation`
  - almost never gains heavily from ordinary quest resolutions
  - relies on a small number of environmental, reflective, or later-custom ritual hooks
- `Sithis acknowledgment`
  - strongest from `Dark Brotherhood`
  - secondary from a few explicit death / void / change-facing quest choices
  - not from generic stealth or generic killing

**Curse States (LOCKED):**

**Vampire:**
```
Hist relation is hit hardest and may collapse into silence or corruption
Collective / community identity is also damaged
Sithis acknowledgment becomes more available or foregrounded, but not automatically good
This is one of the deepest grief states in the mod
```

**Werewolf:**
```
Serious strain on Hist relation, but not total collapse
Less destructive to community belonging than vampirism
Mostly neutral to Sithis acknowledgment
Potentially more manageable than for many other races because Argonian theology is less rigid about fixed form
```

Rationale:
- Matches the curse source file's distinction between Hist-refusal in vampirism and more tractable beast-shape strain in lycanthropy

---

## SECTION 11: Daedric Worship Architecture (LOCKED BASELINE; PRINCE-FIRST)

This section defines how Daedric worship sits beside the race architectures already locked above. It uses `tamriel-daedric-worship-4e201.html` as the primary local reference, interpreted in context with `tamriel-daily-worship-4e201.html`, `tamriel-cursed-worship-4e201.html`, UESP, and The Imperial Library.

Source basis:
- Local: `references/tamriel-daedric-worship-4e201.html`
- Local: `references/tamriel-daily-worship-4e201.html`
- Local: `references/tamriel-cursed-worship-4e201.html`
- UESP: https://en.uesp.net/wiki/Lore:Daedric_Princes
- UESP: https://en.uesp.net/wiki/Lore:Good_Daedra
- UESP: https://en.uesp.net/wiki/Lore:The_House_of_Troubles
- UESP: https://en.uesp.net/wiki/Lore:Varieties_of_Faith_in_Tamriel
- UESP: https://en.uesp.net/wiki/Lore:Varieties_of_Faith:_The_Orcs
- UESP: https://en.uesp.net/wiki/Lore:Varieties_of_Faith:_The_Wood_Elves
- The Imperial Library: https://www.imperial-library.info/content/book-daedra
- The Imperial Library: https://www.imperial-library.info/content/varieties-faith-khajiit
- The Imperial Library: https://www.imperial-library.info/content/dark-spirits
- The Imperial Library: https://www.imperial-library.info/content/varieties-of-faith-solstice

### 11.1 Core Model

Daedric worship is a separate path family from normal race/patron devotion.

The architecture is `Prince path first, race response second`.

Rules:
- Each Prince has a stable core identity, reward domain, and price domain across races
- Race modifies `access`, `framing`, `stigma`, `entry threshold`, `interpretation`, and `faith friction`
- Race should not reinvent the Prince's core gameplay identity unless the Prince is a native-integrated exception
- Native-integrated Princes use the race's worship vocabulary, not generic "Daedric pact" language
- Daedric commitment creates friction with normal divine/racial devotion, but does not automatically erase it
- Strongly taboo commitments must produce explicit player feedback through message, MCM state, blessing change, or price change

The player experience should feel like a parallel, sharper religious ecosystem. Daedric paths are tempting, specialized, risky, and materially meaningful, but they should not become "better gods."

### 11.2 Tier Spine and UI Contract

Daedric paths reuse the global `Tier 0-3` structure for implementation simplicity and consistency.

Recommended Daedric labels:

| Tier | Normal devotion label | Daedric label | Meaning |
|---|---|---|---|
| `0` | None | `Unmarked` | No meaningful Prince claim |
| `1` | Seeker | `Touched` | The Prince has noticed or accepted first commitment |
| `2` | Devoted | `Bound` | The bargain, curse, oath, or domain service is materially active |
| `3` | Champion | `Claimed` | The player is strongly identified with that Prince's sphere |

UI/MCM rules:
- Daedric status is normally surfaced separately from normal patron devotion
- Native-integrated Princes may appear inside the race's normal worship architecture instead of a separate Daedric side panel
- Daedric UI should expose `boon`, `price`, `stigma`, and current commitment state
- Pre-commitment signals may appear as `Tempted` or equivalent flavor, but should not imply full devotion
- Feedback must be prioritized so the player does not receive noisy mixed signals from every active theology layer

### 11.3 Reward and Cost Contract

Every Prince path must define a `boon / price / stigma` contract.

| Contract field | Meaning |
|---|---|
| `Boon` | What the player materially gains |
| `Price` | The primary mechanical cost, instability, restriction, or backlash |
| `Stigma` | How the player's race/community/theology receives the path |

Rules:
- Daedric powers are usually `narrow but sharper` than normal divine/racial worship powers
- Daedric paths may grant stronger contextual favors when the condition is narrow and the cost is real
- Daedric baseline blessings still respect the global PDV power ceiling
- Every Prince gets one primary `price type`; secondary prices require strong justification
- Disbenefits should be mostly contextual rather than broad always-on stat punishment
- Combat power is allowed only when combat is central to the Prince's sphere
- Refusing a Prince's core price should slow or cap progression
- Rival pressure exists only for obvious theological conflicts and must be used sparingly

Invalid design patterns:
- Generic "all Daedra bad" penalties
- Constant broad stat punishment
- High-frequency background harassment
- Turning Daedric paths into universal combat perk dispensers
- Making Daedric commitment disposable or consequence-free

### 11.4 Commitment, Temptation, Exit, and Residue

Daedric progression requires a `commitment signal` before meaningful tier growth begins.

Examples:
- Accepting or using a Daedric artifact
- Completing a Prince's quest in the Prince-aligned way
- Becoming a vampire or werewolf
- Joining the Nightingales
- Using a Black Book or accepting forbidden knowledge
- Making a clear pact-style choice

Pre-commitment behavior creates `temptation pressure`, not full piety. The system may notice domain-aligned behavior, surface flavor, or make later entry easier, but it must not silently convert the player into a Daedric devotee.

Exit rules:
- Daedric worship allows exit paths, but they are harder than ordinary patron switching
- Cure, artifact rejection, cleansing, rival rededication, or sustained opposite behavior can reduce or break a Prince's claim
- Molag Bal and Hircine must support restoration logic after vampirism/lycanthropy cure where mechanically feasible
- Former Daedric commitment may leave limited residue: stigma, lowered starting floor, memory flag, or renewed temptation pressure
- Residue must not permanently ruin future roleplay

### 11.5 Race Response States

Every Prince/race pairing uses one compact response state.

| State | Meaning | Mechanical posture |
|---|---|---|
| `Native` | Prince is part of the race's core religious architecture | Can use normal worship vocabulary and normal deep progression |
| `Legible` | Race has a meaningful framework for understanding the Prince | Easier entry, reduced confusion, moderate stigma |
| `Tolerated` | Acceptable under specific practical conditions | Limited or conditional progression, usually domain-bound |
| `Taboo` | Spiritually/socially dangerous | Higher threshold, stronger stigma, explicit rupture feedback |
| `Hostile` | Strongly opposed by the race's worldview | Severe faith friction; usually adversarial or rare rupture |
| `Curse` | Accessed mainly through transformation such as vampirism/lycanthropy | Active curse state can override cultural rejection if lightweight to detect |

`Curse` override rule:
- Active vampirism or lycanthropy can make Molag Bal or Hircine mechanically relevant regardless of normal race response
- This override should only be implemented if it can be done cleanly and cheaply
- Cure should reopen restoration, rededication, and lowered-floor recovery routes

### 11.6 Native-Integrated Exceptions

These Princes exist globally as Daedric paths, but for relevant races they merge into native religion rather than operating as external Daedric conversion.

| Prince | Native integration |
|---|---|
| `Azura / Azurah` | Dunmer Good Daedra / Reclamation; Khajiit Azurah and lunar theology |
| `Boethiah / Boethra` | Dunmer Good Daedra / Reclamation; Khajiit Boethra where supported by race architecture |
| `Mephala / Mafala` | Dunmer Good Daedra / Reclamation; Khajiit Mafala where supported by race architecture |
| `Malacath / Mauloch` | Orc core religion through code, exile, oath, labor, vengeance, and judgment |

Native integration effects:
- Removes most outsider stigma and identity conflict
- Uses race-specific religious vocabulary
- Keeps a light secondary `Daedric risk layer`
- Does not make Daedric power safe, civic, or bland

Explicit correction:
- Bosmer `Herma-Mora` is not the same as the Daedric Prince `Hermaeus Mora` for PDV architecture purposes
- Do not add Bosmer Herma-Mora to the Daedric Prince layer
- If Bosmer Herma-Mora matters later, handle it in Bosmer folklore/spirit architecture, not Section 11

### 11.7 Prince Path Definitions

All sixteen vanilla Skyrim-facing Prince surfaces are in scope. This means
fifteen normal Daedric quest/artifact routes plus Nocturnal's Thieves Guild /
Nightingale route. Nocturnal should be treated as a questline/oath/surface
exception, not as a normal standalone Daedric quest. The Skeleton Key is a
Daedric artifact but does not count toward vanilla Oblivion Walker. Jyggalag
remains omitted unless future Creation Club or Sheogorath/Jyggalag content is
explicitly adopted.

| Prince | PDV path type | Commitment/progression logic | Primary price type |
|---|---|---|---|
| `Azura / Azurah` | `Fate-dawn-dusk-prophecy` | Prophecy, liminal choices, mercy toward cursed souls, artifact reverence, twilight thresholds | Fate obligation and prophetic burden |
| `Boethiah / Boethra` | `Struggle-overthrow-trial` | Proving, betrayal-as-test, defeating false authority, ruthless self-assertion | Conflict escalation and trust damage |
| `Mephala / Mafala` | `Web-secret-murder-clan` | Secrecy, manipulation, hidden loyalties, targeted killing, social webs | Social corruption and hidden violence |
| `Malacath / Mauloch` | `Oath-exile-code-vengeance` | Keeping harsh codes, avenging betrayal, enduring exile, defending the rejected | Harsh judgment and code burden |
| `Meridia` | `Cleansing-light-anti-undead overlay` | Destroying undead, rejecting necromancy, cleansing corruption, Dawnbreaker-style service | Authoritarian purity and anti-undead intolerance |
| `Hircine` | `Hunt-lycanthropy-predator` | Hunt rites, beast-shape, predator/prey logic, Companions/werewolf choices, Hunting Grounds pull | Predatory instinct and social/afterlife tension |
| `Molag Bal` | `Domination-vampirism-enslavement` | Vampirism, domination, soul violation, desecration, Coldharbour-aligned choices | Domination corruption and spiritual violation |
| `Nocturnal` | `Shadow-oath-luck-debt` | Thieves Guild, Nightingale covenant, Skeleton Key, secrecy, luck, debt, oath obligations | Debt, oath-binding, and luck withdrawal |
| `Hermaeus Mora` | `Forbidden-knowledge-artifact` | Apocrypha, Black Books, Septimus-style bargains, dangerous secrets, knowledge corruption | Knowledge corruption and agency erosion |
| `Mehrunes Dagon` | `Destruction-revolution-ruin` | Overthrow, catastrophe, sacrificial destruction, destabilizing choices, artifact pursuit | Ruin escalation and civic/spiritual rupture |
| `Sheogorath` | `Madness-disruption-instability` | Absurdity, warped outcomes, reality disruption, unstable bargains | Unpredictability and loss of stable control |
| `Namira / Namiira` | `Revulsion-decay-outcast-hunger` | Cannibalism, decay, corpse taboo, outcast solidarity, darkness, rejected things | Social revulsion and consumption taboo |
| `Sanguine / Sangiin` | `Excess-temptation-indulgence` | Revelry, intoxication, lust, social excess, temptation, losing restraint | Overindulgence, unreliability, and restraint loss |
| `Clavicus Vile` | `Bargain-wish-contract` | Deals, loopholes, power-at-cost choices, Barbas/artifact logic, contractual consequences | Bargain backlash and exploitative terms |
| `Peryite` | `Plague-order-lowest-task` | Disease, pestilence, imposed order, unpleasant duties, low mechanisms of fate | Affliction and submission to task/order |
| `Vaermina` | `Dream-nightmare-memory` | Nightmares, dream manipulation, fear, memory violation, sleep corruption | Sleep corruption and memory/fear instability |

### 11.8 Prince-Specific Hook Priorities

Each Prince must receive a vanilla hook priority list before powers are designed.

Default hook priority order:
- Quest outcome
- Artifact ownership or artifact use
- Faction membership or oath state
- Curse state
- Crime, kill, or mercy choice
- Location, shrine, or scene contact
- Dawn consolidation of already-captured signals

Initial vanilla-facing anchors:

| Prince | Strongest vanilla hooks |
|---|---|
| `Azura / Azurah` | `The Black Star`, Azura shrine, artifact outcome |
| `Boethiah / Boethra` | `Boethiah's Calling`, sacrifice/betrayal outcome |
| `Mephala / Mafala` | `The Whispering Door`, Ebony Blade, hidden violence |
| `Malacath / Mauloch` | `The Cursed Tribe`, Volendrung, stronghold/Blood-Kin context |
| `Meridia` | `The Break of Dawn`, Dawnbreaker, undead/necromancer cleansing |
| `Hircine` | `Ill Met by Moonlight`, Companions, werewolf state |
| `Molag Bal` | `The House of Horrors`, Mace of Molag Bal, vampirism/Volkihar pressure |
| `Nocturnal` | Thieves Guild, Nightingale oath, Skeleton Key |
| `Hermaeus Mora` | `Discerning the Transmundane`, Oghma Infinium, Dragonborn/Black Books/Apocrypha |
| `Mehrunes Dagon` | `Pieces of the Past`, Mehrunes' Razor, destructive quest outcomes |
| `Sheogorath` | `The Mind of Madness`, Wabbajack, reality-disrupting outcomes |
| `Namira / Namiira` | `The Taste of Death`, Ring of Namira, cannibal feast |
| `Sanguine / Sangiin` | `A Night to Remember`, Sanguine Rose, revelry/excess contexts |
| `Clavicus Vile` | `A Daedra's Best Friend`, Masque/Rueful Axe outcome, Barbas/deal logic |
| `Peryite` | `The Only Cure`, Spellbreaker, disease/affliction contexts |
| `Vaermina` | `Waking Nightmare`, Skull of Corruption, dream/sleep corruption |

Artifact rules:
- Daedric artifact ownership/use is a major commitment and progression signal
- Artifact contact is not the only valid route
- Strongest progression usually requires artifact signal plus quest choice, faction/curse state, or domain-aligned behavior
- Avoid "equip artifact, get devotion" as a complete path

### 11.9 Race Response Application

Race response modifies each Prince path without rebuilding it.

Race layer fields:

| Field | Purpose |
|---|---|
| `Race response state` | Native, Legible, Tolerated, Taboo, Hostile, Curse |
| `Entry threshold` | How much commitment is needed before growth starts |
| `Stigma` | Social/religious/cultural consequence |
| `Faith friction` | Which normal substrate, patron, or layer is strained |
| `Vocabulary` | Native worship, tolerated service, pact, corruption, curse, trial, taboo |
| `Restoration route` | Normal switch, shrine/rite, cure, absolution, rededication, unavailable |

High-level race guidance:
- `Nord`: mostly external/taboo; Hircine is curse/legible through Companions; Meridia tolerated for anti-undead; Molag Bal severe rupture
- `Imperial`: mostly civic taboo; Meridia tolerated for anti-undead; Mehrunes Dagon especially hostile after Oblivion Crisis memory; Nocturnal criminal/oath path is non-civic
- `Breton`: witchcraft exposure can make some Daedric contact legible; Hircine/Namira/Hermaeus Mora remain the cleanest inherited pressure set; Meridia tolerated outside witchcraft
- `Dunmer`: Azura, Boethiah, and Mephala are native; House of Troubles remain adversarial/testing unless a curse or rupture path applies
- `Altmer`: mostly taboo/apostasy; Psijic-like study is not worship; rare Three Queens/Solstice-style material remains future heresy/exile architecture
- `Khajiit`: Azurah is native; Boethra/Mafala can be culturally meaningful where the Khajiit architecture supports them; dark spirits and Prince paths should not overwrite lunar substrate
- `Bosmer`: Hircine is the main Daedric pressure through hunt/lycanthropy/Wild Hunt adjacency; Herma-Mora is not treated as Hermaeus Mora in this Daedric layer
- `Redguard`: mostly foreign/hostile; Meridia can be tolerated for undead-cleansing but must not replace Tu'whacca/ancestor duty; Malacath/Malooc remains hostile/cautionary
- `Orc`: Malacath is native core religion; other Princes are threats, tests, or external pacts; Boethiah is especially costly
- `Argonian`: Sithis is separate and not Daedric; Daedric contact is mostly foreign; Molag Bal/Hircine enter through curse pressure; most commitments weaken Hist/community coherence

### 11.10 Implementation Safety Rules

Daedric worship must stay lightweight, event-driven, and standalone-first.

Rules:
- Prefer vanilla quest stages, faction membership, magic effects, actor values, disease/curse state, inventory/artifact checks, and dawn consolidation
- Avoid constant polling, cloak scanning, new quest content, forced scenes, and heavy compatibility assumptions
- Do not create new quest content for Daedric paths
- Build for PDV's own devotion architecture, not Wintersun compatibility
- Optional integrations or patches can be considered later for survival mods, Requiem, or other major gameplay contexts, but the Daedric base design must not require them
- Every Prince signal must be tagged as `Vanilla Hook`, `Needs SKSE/PapyrusUtil`, `Patch Candidate`, or `Rejected for Scope`

Performance posture:
- Daedric logic should be mostly event-driven
- Dawn consolidation remains acceptable for captured daily/temporary signals
- Curse override checks must be cheap or deferred
- Repeated Daedric behaviors should be capped tightly and require clear domain relevance
- Quest and artifact signals should usually be high-weight one-time or milestone signals

### 11.11 Signal Matrix Requirements

The Phase 4 Daedric matrix now carries the implementation-facing race-by-Prince
crosswalk. Future signal tables that touch Daedric content should reference
`references/phase4/PDV_DaedricRacePrinceMatrix.csv` rather than re-deriving
race response states from prose.

Required fields:

| Field | Purpose |
|---|---|
| `Prince path type` | Which locked Prince path definition applies |
| `Race response state` | Native, Legible, Tolerated, Taboo, Hostile, Curse |
| `Commitment signal` | What threshold starts real progression |
| `Temptation pressure` | What pre-commitment behavior is noticed |
| `Boon` | Narrow material benefit |
| `Primary price` | Main disbenefit/cost |
| `Stigma` | Race/community/theology response |
| `Faith friction` | Normal worship layer strained |
| `Vanilla hook priority` | Cleanest buildable signals in order |
| `Buildability tag` | Vanilla Hook, Needs SKSE/PapyrusUtil, Patch Candidate, Rejected for Scope |
| `Exit route` | Cure, cleansing, artifact rejection, rededication, sustained opposite behavior |
| `Residue` | Limited remaining stigma, floor shift, memory flag, or temptation pressure |

This section is locked as the architectural baseline. The detailed
race-by-Prince response matrix now lives in
`references/phase4/PDV_DaedricRacePrinceMatrix.csv`, with race-sheet summaries
kept in `race-sheets/Race_*.md` for readable end-state context.

Current matrix compression rule:
- The active Phase 4 CSV is Prince-first. Its race columns compress response
  state, stigma, faith friction, exit route, and sometimes residue into one
  readable cell per race.
- That compression is acceptable for architecture review, but not sufficient
  as an implementation handoff by itself.
- Before implementing any Daedric slice, expand the target Prince/race cells
  into either a 160-row implementation table, an authoring manifest, or an
  equivalent script-side data structure that carries every required field above
  explicitly.
- `PDV_Architecture_v3.md` Section 21.5 consumes this rule as the Slice 8
  Daedric pilot gate.
- `Nocturnal` expansion must use `FactionOathSurface`, not
  `StandaloneDaedricQuest`; `Jyggalag` expansion must remain
  `Rejected for Scope` unless a future adopted content surface changes that.

Player-feedback rule:
- Any `Taboo`, `Hostile`, or `Curse` commitment must produce explicit feedback
  through MCM/status text, notification, effect description, or authored
  devotional copy. It must not be silent piety math.
- `Native`, `Legible`, and `Tolerated` commitments may use lighter feedback,
  but still need an exposed commitment/pressure state if they create a boon,
  price, or exit residue.

---

## SECTION 12: Race Architecture Design Decisions (2026-05-16 Grilling Session) — ALL LOCKED

These decisions emerged from a comprehensive grilling session reviewing all 10 race sheets. They extend or override prior locked decisions where specified.

### 12.1 Nord — Broad Worship Reward Vocabulary (LOCKED)

Broad worship (multiple deities at Faithful) must have its own distinct reward vocabulary. The Tier 2 cap reflects a necessary gate, but players maintaining multiple deity relationships should receive combo effects or overlapping contextual favors that make breadth genuinely distinct from depth — not just "depth but capped."

Design intent: A Nord who worships their whole pantheon broadly gets something *specifically unique to breadth*, not merely diminished versions of what a focused worshipper gets.

### 12.2 Breton — Three-Track Primary Identity (LOCKED)

Breton architecture restructured from a 12-god flat pantheon to three-track primary identity:

| Track | Character | Unique Mechanic |
|-------|-----------|-----------------|
| The Knight's Road | Civic honor, protective justice, selfless service | KnightlyVowIntegrity |
| The Hidden Art | Occult practice, Daedric dealings, double lives | WitchcraftExposure |
| The Green Way | Druidic covenant, standing stones, nature rites | Druidic Standing |

God choice is a **secondary flavor layer** within each track, not the primary identity. The three tracks can pull against each other, creating tension. A knight tempted by witchcraft feels their vow integrity strain. A druid exposed as a witch loses standing.

This supersedes the prior "12 primary god choices" setup in Section 10.3's flow definition.

### 12.3 Khajiit — Emergent Patron Mechanic (LOCKED — LORE CONFIRMED)

**Lore basis:** UESP and Imperial Library confirm that Khajiit gravitate toward specific deities through life-role (magicians toward Azurah, travelers toward Khenarthi, tricksters toward Rajhin) without formal temple declarations.

**Implementation:** No formal commitment moment. The system silently detects behavioral alignment and shifts weight toward whichever deity the player's actions align with. The player never "picks" — they realize they've been walking that path.

This is the **only race** that bypasses the standard `ProcessCommitmentOffers()` mechanism. Instead, a silent weight-shift function in the Khajiit substrate evaluates behavioral patterns at dawn and adjusts deity emphasis without notification. The player may notice stronger blessings appearing in a particular domain before they consciously realize alignment has shifted.

### 12.4 Khajiit — Moon Cycle Reward Phasing (LOCKED)

The Khajiit substrate reward cycles with the moons. Tied to Skyrim's actual Masser/Secunda moon data where possible (abstract 28-day cycle as fallback).

Rules:
- Different phases favor different aspects of Khajiit life (road-travel, community, reflection, focused deity work)
- Overall substrate strength is determined by *consistent compliance across the full cycle* — not spiking during one favorable phase
- When the moons overlap or oppose each other, special spiritual states emerge
- Current phase is always visible to the player via power menu, with flavor text on cycle shifts

### 12.5 Khajiit — Road Homes (LOCKED)

Khajiit designate 2-3 rest points (not one sacred place) as spiritual anchors along their road. This mirrors caravan-route thinking.

Rules:
- Cycling between road homes is itself devotional
- A Khajiit who never returns is adrift; one who cycles reliably walks the moons' path
- Uses the shared PDV_SacredPlace system with race-specific multi-location parameters

### 12.6 Argonian — Bed-of-Choice Community Designation (LOCKED)

Argonians designate a "bed of choice" location as "the family I chose." This piggybacks off thane-regard mechanics.

Rules:
- Player picks a location (any town works equally once designated)
- Must sleep there a designated number of nights per week/month to avoid community decay
- Windhelm gets extra flavor text, not mechanical bonus
- Uses the shared PDV_SacredPlace system with Argonian-specific single-location parameters

**Hist Sap Meditation Item (LOCKED):**
- Inventory item that grants a player-triggered lesser power for Hist reconnection
- Custom content — likely needed for the Hist layer to be enjoyable given Skyrim's thin vanilla Hist hooks

### 12.7 Orc — Dynamic Rewards for City/Legion Modes (LOCKED)

City/Legion modes get **dynamic/situational rewards** (temporary, contextual, occasionally stronger) vs Stronghold's **static/permanent blessings**. The lower ceiling reflects fewer *opportunities* to reach it, not inherently weaker faith.

**Self-Made Community Mechanic (LOCKED):**
A City or Legion/Exile Orc who builds their own community in a location gets a devotion boost when visiting. This is a progression arc that Stronghold Orcs don't need (they already have communal infrastructure).

Uses the shared PDV_SacredPlace system with Orc-specific progression parameters (empty → established → thriving).

Presentation split:
- `City Orc`: the chosen place reads as belonging built inside mixed society
- `Legion / service / exile Orc`: the chosen place reads as a burden returned from, a private anchor after service or displacement

Hook boundary:
- Use `PDV_SacredPlace`, location/faction/relationship hooks, and faction-favor proxy investment events
- Repeated visits alone do not count without investment, service, relationship, or community-building evidence
- This is not viable as a pure vanilla inference system; it is viable as authored PDV state using the shared sacred-place contract

### 12.8 Bosmer — Own Green Pact Tagging System (LOCKED)

The Old Contract path uses its own tagging system for Green Pact detection, mirroring the approach Requiem/Races Redone use. This is NOT a dependency on those mods — PDV implements its own tag layer that functions independently.

### 12.9 Altmer - Tier 3 Lorkhan Penalty Weighting (LOCKED)

Tier 3 mortal-validation penalties (marriage, homestead, adoption, etc.) are **lightly weighted**. Default effect is `-1` piety before faction modifier; an authored stronger Tier 3 event may use `-2`. Tier 3 is capped once per in-game day and applies only to explicit, player-legible mortal-validation acts.

Design intent: The penalty triggers events and flavor, not harsh mechanical punishment. A player who marries or builds a home gets a spiritual reaction - internal Altmer dissonance manifesting as flavor/notification - not a devastating devotion collapse.

This is now governed by the Section 10.5 Altmer economy lock and its explicit Lorkhan pressure tags.

### 12.10 Shared Sacred Place System (LOCKED)

A shared `PDV_SacredPlace` script architecture serves multiple races.

**Shared contract:**

| Property | Purpose |
|----------|---------|
| Designated location(s) | Where the sacred place is |
| Visit frequency | How often the player must visit |
| Regard/investment value | How "established" the place is |
| Decay rate | What happens without visits |
| Reward modifier | Devotion boost from visiting |

**Race-specific parameters:**

| Race | Locations | Progression | Custom Loop |
|------|-----------|-------------|-------------|
| Argonian | 1 | Static (bed-of-choice) | Community decay timer |
| Khajiit | 2-3 | Static (road circuit) | Circuit cycling tracker |
| Orc (City/Legion) | 1 | Dynamic (empty → established → thriving) | Investment progression |

Race-specific hooks feed into the shared system. Custom loops per race feed back results via the shared contract.

### 12.11 Imperial — Concordat Uncommitted Band (LOCKED)

The Uncommitted band is widened to ±50 (from ±10). The outer states are compressed:
- Open Defiant: −100 to −76
- Private Defiant: −75 to −51
- Uncommitted: −50 to +50
- Public Compliant: +51 to +75
- Concordat Enforcer: +76 to +100

Design intent: Avoid rubberbanding players into forced engagement. Still forces eventual engagement through sustained behavior but doesn't punish normal gameplay choices with immediate state shifts. Players must accumulate significant defiance or compliance to leave the wide Uncommitted zone.

### 12.12 Dunmer — Portable Shrine Prayer (LOCKED)

Dunmer use an inventory-based portable shrine with a triggered animation for prayer/ancestor ceremony. The shrine is permanent inventory and can be used anywhere. Player-owned property provides a bonus modifier to prayer rewards (not a requirement). This avoids requiring the player to find specific locations and reflects the Dunmer tradition of personal ancestor worship.

### 12.13 Nord — Broad Worship Combo at Tier 2 (LOCKED)

Nord broad worship at Faithful (Tier 2) combines watered-down blessings from the player's multiple active deity relationships. This creates a genuinely distinct playstyle from depth — breadth isn't "depth but capped," it produces combo effects or overlapping contextual favors. Specific combo recipes are content-authored during the signal/reward pass.

### 12.14 Altmer — Crisis of Faith Events (LOCKED)

Major story points that challenge Altmer theological worldview (e.g., discovering Thalmor hypocrisy, Talos mantling evidence) create genuine crisis-of-faith events rather than simple piety adjustment. These trigger temporary states (doubt, questioning, vulnerability) that the player resolves through continued behavior in one direction or another. The presentation should carry more flavor and only a minimal temporary sting, reflecting emotional dysregulation rather than theological failure or permanent collapse.

Closeout lock (2026-05-30): `PDV_State_AltmerCrisis` uses `None = 0`, `Dissonant = 1`, `Questioning = 2`, `Reasserting = 3`, and `ScarredResolved = 4`. Launch crisis sources are Dragonborn declaration, Sovngarde/Tsun proof, Talos/Thalmor contradiction, and the Companions/Wuuthrad/beast fork. Marriage, adoption, and homestead ownership remain Tier 3 mortal-continuity dissonance by default, not full crisis events. Crisis resolves through coherent behavior afterward and may trigger contextual favor only when the response is itself faithful or self-possessed.

### 12.15 Bosmer — Pact Failure Mechanic (LOCKED)

No lockout on single Green Pact violations. Instead: if the player intentionally breaks their pact rule 5 times within a 2-day window, piety is lowered as a penalty. This prevents accidental single violations from being punishing while still making sustained disregard meaningful. The daily compliance buff is withheld on violation days (90-minute internal cooldown per the standard anti-farm) but no longer-term lockout.

### 12.16 Argonian — Arkay Priest Reactions (LOCKED — Custom Content Essential)

For Argonian death-rites and Hist-connection to feel meaningful, custom content is needed for Arkay priest NPCs to react to Argonian burial/death practices. Without this, the racial theology layer cannot express itself through the existing game world. Flagged as essential custom content for 1.0.

### 12.17 Patron Commitment — General Model (LOCKED)

For all non-Khajiit races, the patron commitment model is: "if you've done enough, a god notices you and reaches out." The deity initiates once piety crosses the offer threshold. This is presented as the god acknowledging the player's consistent behavior — not the player choosing from a menu. The player then accepts, delays, or refuses. Khajiit bypass this entirely per §12.4a (emergent patron, no notification).

**Offer threshold default (LOCKED 2026-05-19):**
For all formal patron/deity commitment races, the default commitment-offer threshold is the Faithful / Tier 2 threshold: `50` persistent piety with that deity, plus any race-specific sustained-pattern, state-track, or eligibility gates. The default may be tuned upward or made more complex for a deity with multiple domains, but lowering it or bypassing it requires an explicit race/deity exception. This keeps patron commitment as a move from established faith into depth, not a response to early interest.

**Offer evaluation default (LOCKED 2026-05-19):**
For formal patron/deity commitment races, offers are evaluated during the dawn pass only. A candidate must meet the piety threshold, race/state eligibility filters, per-deity cooldown filters, and qualifying signal activity on at least two separate in-game days within the last seven days unless an explicit race/deity exception is documented. Do not persist pending-offer queues; recompute candidates each dawn from current ledgers, state tracks, recent signal evidence, and cooldowns. Fire at most one offer per dawn, choosing the highest recent signal-strength candidate and using stable deity index only as a tie-breaker.

**1.0 no-switching rule (LOCKED 2026-05-19):**
For all races with formal patron/deity commitment, accepting a patron is stable for 1.0 unless a race-specific exception is explicitly documented. The accepted patron remains the active patron even if devotion later decays below Tier 3; decay weakens benefits and relationship strength, but does not silently clear or replace the commitment. Competing patron offers do not fire while `PDV_GLO_PatronState` is active primary. Patron switching, rupture, renunciation, or reorientation is deferred to a later explicit in-world feature. Khajiit remain the special no-formal-offer exception, because their focused deity emphasis emerges silently through the lunar substrate rather than an accepted offer.

Rationale: player agency matters after divine recognition. Commitment should feel chosen and consequential, not overwritten by automatic drift because the player spent a week doing another god-coded activity.

### 12.18 Orc — Community Standing Mechanic (LOCKED)

Preferred implementation: NPC disposition tracking for the self-made community system. For 1.0, use a faction-favor proxy system if full disposition tracking proves too complex. The progression (stranger → acquaintance → friend → community member) drives the devotion bonus from the Orc's invested location. Recommended approach is faction-favor proxy for initial implementation.

City and Legion / service / exile may share the same community substrate, but they should not present the same way. City mode frames the place as belonging built; Legion / service / exile frames it as return from burden. The hook surface is appropriate only when backed by explicit `PDV_SacredPlace` state, relationship/faction-favor proxy milestones, or curated investment events; generic repeated visits are not enough.

### 12.19 Redguard — HoonDing Accessibility (LOCKED)

HoonDing devotion (the spirit of "Make Way") is achievable through special beast kills and other "big win" quests that represent clearing impossible obstacles. Between Skyrim's dragon fights, named creatures, and major quest climaxes, sufficient signal sources exist without needing custom content. The threshold should be high but attainable for active adventurers.

### 12.20 Dunmer — Tribunal Random Thought (LOCKED)

When praying at a Tribunal shrine, the player receives a random buff OR debuff based on "where their thoughts wandered." This reflects the complex, unpredictable nature of the Three's legacy — even devoted Tribunal worshippers can't control which aspect of the Three answers. Mechanically: small random selection from a curated pool each prayer, some positive, some negative, all thematic to the specific shrine's Good Daedra aspect.

### 12.21 Altmer — Exiled Altmer Vampire Path (LOCKED)

Altmer vampires gain access to an "Exiled Altmer" micro-path: a redirected self-reconstruction arc rather than simply losing all divine connection. Capped at Tier 1 (no deep devotion available in this state). Represents the Altmer's characteristic refusal to simply collapse — they rebuild meaning even in exile. Not a full worship lane; a survival-identity path that prevents the vampire state from being mechanically dead for Altmer players.

### 12.22 Breton — Three-Track Triangle Drag (LOCKED)

The three Breton traditions (Knight's Road, Hidden Art, Green Way) form an asymmetric drag triangle. Actions aligned with one tradition can create tension or damage standing in another. The drag is not symmetric — some cross-pollinations are more damaging than others (e.g., Hidden Art strongly undermines Knight's Road vow integrity; Green Way and Knight's Road have milder tension). Exact drag weights are content-authored during implementation.

### 12.23 Imperial — Concordat Walk-Back Mechanics (LOCKED)

Walking back from extreme Concordat positions uses amplified reverse weight at the edges: the further entrenched you are, the harder (more consistent counter-behavior required) to reverse. Combined with a narrative gate: reaching the center from an extreme requires a story-caliber event (not just gradual drift) to fully reset. This prevents casual flip-flopping while preserving the possibility of genuine character development arcs.

### 12.24 Custom Content Priority Classification (LOCKED)

Essential custom content (required for the racial theology layer to be playable):
- Argonian: Hist connection, death rites, community
- Dunmer: Ancestor ceremonies, portable shrine, ash-shrine interaction
- Khajiit: Moon observance flavor, road-life acknowledgment
- Orc: Community investment system (NPC reactions)
- Bosmer: Green Pact detection reactions

Enhancement custom content (improves experience, not required for core function):
- Altmer: Post-vampire Exiled Altmer path flavor

### 12.25 Non-Substrate Races — Substrate Promotion Policy (LOCKED)

Races without a formal substrate (Nord, Imperial, Breton, Redguard, Altmer, Orc) can have substrates pulled forward if playtest feedback proves the lighter mechanics (privileges, contextual favors, state tracks) are insufficient. Specific candidates:
- Nord: Pantheon-level broad worship could become a substrate if combo mechanics need always-on tracking
- Breton: Three-track tension system may provide equivalent depth without needing a formal substrate layer

Decision to promote is deferred to playtesting. Architecture supports promotion without refactoring.

### 12.26 Dunmer — Home Bonus Location (LOCKED)

Dunmer prayer bonus applies at player-owned property (any owned home). Shared sacred-place system can be used if it provides a better implementation path, but the core design is simpler: own a home → prayer there gets a bonus. No specific location is privileged over another — any player-owned property works equally.

### 12.27 Khajiit — Moon Cycle Hybrid Model (LOCKED)

The moon cycle uses a hybrid reward model: per-phase bonus (current phase favors specific activities) PLUS full-cycle compliance (consistent engagement across all phases determines overall substrate strength). Neither alone is sufficient — a player who only engages during favorable phases gets the per-phase bonus but weak overall substrate, while consistent engagement across the full 28-day cycle builds the strongest substrate score.
