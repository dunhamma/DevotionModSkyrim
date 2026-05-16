# PlayerDevotion (PDV) — Race Architecture Design Reference
**Started:** May 12, 2026  
**Last updated:** May 16, 2026 (Section 12 added — grilling session design decisions)  
**Status:** Living reference — race architecture and pre-matrix requirements locked as confirmed

---

## SECTION 1: Core Assumptions (ALL LOCKED)

### 1.1 Race Selection is Permanent
- Players choose race at character creation
- Mid-game race changes via showracemenu are unsupported
- No cross-race state migration needed
- Allows complete isolation of race modules
- Vanilla vampire races are normalized to the underlying birth race for origin detection
- Temporary beast-form races defer one-shot origin detection rather than becoming a new origin

### 1.2 Curse States Modify Weights, Not Buckets
- Werewolf/Vampire changes HOW the same devotion is interpreted
- Single DevotionLevel persists across curse states
- Curse states never change which bucket an event affects — only magnitude
- Single quest per race with three weight profiles (base, werewolf, vampire)
- Flags: `bIsWerewolf`, `bIsVampire` on the race quest

### 1.3 Event Granularity is Simple (for now)
- Events are simple integers: `EVENT_COMBAT_WIN`, `EVENT_SHRINE_VISIT`, etc.
- No semantic splitting required (validated against all lore sources)
- Safe to add granularity later per-event without refactoring the system
- Old saves with generic events still parse when granular events are added later

### 1.4 Bucket System is Shared Names, Race-Specific Meaning
- All races use: `CombatBucket`, `SocialBucket`, `LifestyleBucket` (−10 to +10)
- Interpreter functions give each bucket race-specific theological meaning
- Exception: Argonian (deferred custom buckets) and Bosmer Orthodox (custom EcologicalBucket + HuntingBucket)
- Comments in interpreter functions must document WHY each event maps to each bucket

---

## SECTION 2: System Architecture (LOCKED)

### 2.1 Module Structure

```
PDV_Framework.esp (minimal dispatcher)
└── PDV_MasterQuest
    ├── OnPlayerLoadGame() → detect player.GetRace()
    ├── Enable correct race quest via alias
    └── Never runs again (race is permanent)

PDV_[Race].esp × 10 (one per race, completely isolated)
└── PDV_[Race]Quest
    ├── CombatBucket (−10 to +10)
    ├── SocialBucket (−10 to +10)
    ├── LifestyleBucket (−10 to +10)
    ├── DevotionLevel (0–100)
    ├── bIsWerewolf = false
    ├── bIsVampire = false
    ├── EventLog[] (int array, max 50 entries, clears daily)
    ├── OnInit() → RegisterForAllEvents()
    ├── OnWerewolfStart/Cured(), OnVampireStart/Cured() → set flags
    ├── Event handlers → log to EventLog throughout day
    └── ProcessDawn()
        ├── Iterate EventLog
        ├── Route to curse-state interpreter
        ├── Sum bucket shifts → clamp to (−5, +5)
        ├── Apply delta to DevotionLevel
        ├── Determine blessing/neglect tier
        └── Clear EventLog
```

### 2.2 Event System: Hybrid (Events + Daily Audit)

**Throughout the day:**
- Major state changes fire events and log to `EventLog[]`
- Simple event type integers (max ~20 types to start, expandable)
- Each race module defines which events it cares about

**At dawn (ProcessDawn):**
- Iterate log, call curse-state interpreter, sum shifts
- Clamp total to (−5, +5) daily devotion delta
- Apply to DevotionLevel, determine tier, clear log

### 2.3 Processing: Separate Interpreter Per Curse State

```papyrus
Function ProcessDayEvents()
  int curseState = 0
  if bIsWerewolf
    curseState = 1
  elseif bIsVampire
    curseState = 2
  endif
  
  int i = 0
  while i < EventLog.length
    int eventType = EventLog[i]
    if curseState == 0
      ApplyBaseInterpretation(eventType)
    elseif curseState == 1
      ApplyWerewolfInterpretation(eventType)
    elseif curseState == 2
      ApplyVampireInterpretation(eventType)
    endif
    i += 1
  endwhile
EndFunction
```

Each race has three functions: `ApplyBaseInterpretation()`, `ApplyWerewolfInterpretation()`, `ApplyVampireInterpretation()`.

### 2.4 Devotion Level

| Range | Descriptor | Tier |
|-------|-----------|------|
| 85–100 | Devoted | 3 |
| 65–84 | Faithful | 2 |
| 45–64 | Observant | 1 |
| 25–44 | Wavering | — |
| 0–24 | Distant | — |

Daily shift formula: `clamp((CombatShift + SocialShift + LifestyleShift) / 3, -5, +5)`

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
Broad worship is the cultural norm. Players can worship all gods (diluted) or choose a primary (focused).

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

**Broad worship (no primary god chosen):**
- All three buckets receive shifts from all events
- Maximum daily shift capped at +2 (vs +5 for focused)
- Blessing cap: Tier 1 only (Observant — never Faithful or Devoted)
- Represents: "acknowledged by the gods, beloved by none specifically"

**Primary god chosen:**
- Primary bucket weighted ×2
- Other buckets weighted ×0.5
- Maximum daily shift = +5 (full ceiling)
- All three blessing tiers available (up to Devoted)
- Represents: "this god knows your name"

**Switching from broad to primary:**
- Accumulated DevotionLevel carries over at 70%
- Weights immediately shift to primary-focused
- Switching requires a **threshold event** (specific shrine visit or related quest) — NOT MCM toggle
- Rationale: committing to a primary deity is a theological act, not a preference setting

**OPEN — to resolve during per-race grilling:**
- Q1: Should broad worshippers cap at Tier 1 (Observant) or Tier 2 (Faithful)?
- Q2: What specific threshold events unlock primary god selection for each race?

---

## SECTION 4: Race-Specific Architecture (IN PROGRESS)

### 4.1 Race Status Overview

| Race | Worship Type | Custom Buckets? | Setup Choice Type | Grill Status |
|------|-------------|-----------------|-------------------|--------------|
| Nord | Poly | No | Broad vs Primary (Old Ways / Nine Divines) | LOCKED |
| Imperial | Poly | No | Broad vs Primary (profession-based) | LOCKED |
| Breton | Three-Track Poly | No | Tradition-first (Knight / Hidden Art / Green Way) | LOCKED |
| Dunmer | Semi-Mono | No | Default vs alternative path | QUEUED |
| Altmer | Poly | Maybe | Study definition open | LOCKED |
| Khajiit | Layered Lunar (Emergent Patron) | No | No setup — emergent alignment via behavior | LOCKED |
| Bosmer | Multi-Path | YES (Old Contract custom path) | Explicit 4-path choice at setup | LOCKED |
| Redguard | Sect-Layered Poly | No | Crown vs Forebear vs Ash'abah | LOCKED |
| Orc | Single-Core Social Modes | No | Malacath across Stronghold / City / Exile | LOCKED |
| Argonian | Layered Custom | YES | Hist / Collective / Sithis exile architecture | LOCKED |

### 4.2 Bosmer (LOCKED)

**Setup model confirmed:** Explicit player choice at first run (MCM or first-run quest)

**Four devotional paths identified from lore:**

| Path | Deity | Lore Source | Bucket Focus |
|------|-------|-------------|-------------|
| The Old Contract | Y'ffre Orthodox | Hunter/Ranger class, Green Pact | EcologicalBucket (custom) + HuntingBucket (custom) |
| The Living Story | Y'ffre Moderate | Scholar/Archer class, oral tradition | SocialBucket + LifestyleBucket |
| The Exchange | Z'en | Justice, balance, owed repayment | SocialBucket + CombatBucket |
| The Bandit Road | Baan Dar | Exile survival, trickster road-life | LifestyleBucket + CombatBucket |

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

### 4.3 Argonian (LOCKED)

**Confirmed:** Custom bucket structure required. Generic three-bucket system insufficient.

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
- These are not three equal gods or three equal buckets
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
- `skyrim-gods-reference.jsx` — cross-cultural deity equivalency table
- UESP Wiki: Argonian cosmology (Hist, Sithis, soul return, Varieties of Faith)

### Key Findings:
- No semantic granularity required at event level — confirmed across all races
- Curse states change theological weight, not bucket assignment — confirmed
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

## SECTION 8: Implementation Checklist (Post-Grilling)

- [ ] Lock all per-race bucket structures and primary god options
- [ ] Define full event type enum (global + race-specific)
- [ ] Implement PDV_Framework.esp dispatcher
- [ ] Build PDV_Nord.esp as reference implementation
- [ ] Implement dilution system (broad vs primary, 70% carry-over)
- [ ] Implement threshold event detection for primary god selection
- [ ] Map race-specific quest-choice signal tables and connect them to devotion weighting
- [ ] Implement ProcessDawn() with curse-state routing
- [ ] Implement blessing/neglect tier effects (3 tiers × 10 races)
- [ ] Build MCM: DevotionLevel display, current path, current tier
- [ ] Test curse state transitions
- [ ] Balance all weights per race per curse state
- [ ] Stress test in heavy mod list

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

- Passive only; no hotbar powers, lesser powers, or activatable religion kit in the core design
- Temporary and condition-based; they turn on only while their conditions are true
- Each path should generally aim for `3-5` contextual favors
- Similar favor mechanics may be shared across races or paths with different theological explanation wrappers
- Use family caps so multiple favors from the same effect family do not stack into burst power

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
- Bucket accumulation triggers the offer organically
- Player's actual playstyle determines which god notices them first
- Multiple offers possible if player excels across domains
- Player can decline ("Not yet") — bucket resets slightly, broad worship continues
- 70% DevotionLevel carry-over on commitment

**Threshold Trigger Rules (LOCKED):**
- Single bucket threshold for most gods
- Combined bucket threshold only for multi-domain gods (Mara, Talos)
- Threshold = sustained high bucket (e.g. ≥ +7 for 3 consecutive days) — exact values TBD during balancing

**God → Bucket Trigger Mapping:**

| God | Pantheon | Trigger Bucket | Notes |
|-----|----------|---------------|-------|
| Shor | Old Ways | CombatBucket ≥ threshold | Warrior-king, Sovngarde aspiration |
| Kyne | Old Ways | CombatBucket + LifestyleBucket | Storm-mother spans martial and natural |
| Tsun | Old Ways | CombatBucket ≥ threshold | Trial against adversity, honourable combat |
| Stuhn | Old Ways | CombatBucket + SocialBucket | Fair-fighting and ransom — combat with honour |
| Mara (Old Ways) | Old Ways | SocialBucket + LifestyleBucket | Hearth, harvest, survival of home |
| Talos/Ysmir | Old Ways | CombatBucket + Thalmor encounter | Shor-incarnation — combat + defiance |
| Akatosh | Nine Divines | LifestyleBucket ≥ threshold | Time, order, long devotion streaks |
| Talos | Nine Divines | CombatBucket + Thalmor encounter | Deified emperor — same trigger, different framing |
| Kynareth | Nine Divines | LifestyleBucket ≥ threshold | Nature, winds, travel |
| Mara (Imperial) | Nine Divines | SocialBucket + LifestyleBucket | Love, compassion — same trigger as Old Ways Mara |
| Zenithar | Nine Divines | SocialBucket ≥ threshold | Commerce, honest work |
| Arkay | Nine Divines | LifestyleBucket ≥ threshold | Death rites, burial, life cycle |
| Stendarr | Nine Divines | CombatBucket + SocialBucket | Mercy in combat — fighting with restraint |
| Julianos | Nine Divines | LifestyleBucket ≥ threshold | Wisdom, study, College-adjacent |
| Dibella | Nine Divines | SocialBucket ≥ threshold | Beauty, art, bardic acts |

**Quest-choice integration (LOCKED):**
- Nordic gods do not require questline completion to become available
- However, quest choices that clearly expose Nordic theological identity should outweigh passive bucket drift when present

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
- Exact bucket threshold values (e.g. ≥ +7 vs ≥ +8)
- Number of consecutive days required
- How much bucket resets on "Not yet" decline

**Curse state weight notes (to detail during implementation):**
- Werewolf Nord: Hircine pulls against Shor/Sovngarde — CombatBucket weights shift toward hunt
- Vampire Nord: Severs afterlife claim — Shor/Sovngarde path weight reduced, Molag Bal pressure added

### 10.2 Imperial (LOCKED)

**Setup Flow:**
```
No baseline choice needed (one pantheon — Nine Divines)
Broad worship begins automatically
Cap: Tier 2 (Faithful) — civic observance is culturally normal
Tier 3 only through primary god commitment
Same bucket threshold trigger system as Nord
```

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
- Same single/combined bucket threshold trigger system as Nord
- God → bucket trigger mapping: identical to Nine Divines column from Nord table

**Talos commitment gate (LOCKED):**
- Full Talos primary commitment is available only in `Uncommitted`, `Private Defiant`, and `Open Defiant`
- `Public Compliant` and `Concordat Enforcer` cannot fully commit to Talos as primary patron
- Rationale: high Concordat compliance must have real theological cost, not just slower Talos gain

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
elif ConcordatStanding < -50
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
  SocialBucket and other civic-facing devotion weights reduce
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

Step 2: Worship broadly within tradition until focused deity emphasis emerges
→ Broad worship cap: Tier 2 (Faithful)
→ Tier 3 (Devoted) only through focused deity commitment within tradition

Traditions can pull against each other — cross-tradition acts create tension
```

**Three-Track Restructure (LOCKED):**
The Breton identity is defined by *which tradition you walk*, not which god you pick from a list. God choice is a secondary flavor layer within each track — adding depth to your tradition rather than replacing it. The three tracks can pull against each other, creating the signature Breton tension between respectability, power, and nature.

**Focused deity options within each tradition:**

| Tradition | Available Focused Deities |
|-----------|--------------------------|
| The Knight's Road | Stendarr, Akatosh, Mara, Arkay, Julianos, Zenithar, Kynareth, Dibella |
| The Hidden Art | Hircine, Hermaeus Mora, Namira, Nocturnal (via Daedric system) |
| The Green Way | Y'ffre (primary), Magnus, Phynaster |

**UESP Confirmed:** Magnus is listed under "Additional Deities with Significant Breton Cults" — legitimate pantheon inclusion. Phynaster available for players emphasising elven heritage.

---

**Unique Mechanic 1: WitchcraftExposure Track (LOCKED)**

Same code pattern as Imperial's ConcordatStanding — one reusable `PDV_ReputationTrack` script, instantiated twice with different thresholds and labels.

```
WitchcraftExposure (0–100, starts at 0)
0–25   = Hidden       (private coven practice, socially invisible)
26–50  = Suspected    (Vigilants take notice, some Bretons uncomfortable)
51–75  = Known        (actively hunted by Vigilants, most Bretons distance)
76–100 = Notorious    (Daedra cultist in all but name, full social rupture)
```

**Exposure modifiers on Witchcraft path devotion:**
```papyrus
if WitchcraftExposure < 25
    DailyShift *= 1.0   ; hidden practice — full accumulation

elseif WitchcraftExposure < 50
    DailyShift *= 0.9   ; suspected — mild social friction
    SocialBucket -= 1

elseif WitchcraftExposure < 75
    DailyShift *= 0.75  ; known — active pressure disrupts practice
    SocialBucket -= 2

else
    DailyShift *= 1.25  ; notorious — Daedric prince rewards full commitment
    SocialBucket -= 4   ; complete social rupture
endif
```

**What raises exposure:**
- Completing Daedric quests publicly (+15)
- Caught by Vigilants of Stendarr (+20)
- Reaching Tier 2 devotion to Daedric patron (+10)
- Killing a Vigilant of Stendarr (+25)

**What lowers exposure:**
- Time passing without visible acts (slow passive decay −1/day)
- Maintaining public Imperial Divines worship as cover (−5 per sustained period)
- Avoiding Daedric-associated locations (passive)

---

**Unique Mechanic 2: KnightlyVowIntegrity Track (LOCKED)**

Applies to knight-path players (Stendarr or Akatosh as primary god).

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
if KnightlyVowIntegrity < 50
    StendarrDailyShift *= 0.5
    AkatoshDailyShift *= 0.75

elif KnightlyVowIntegrity < 25
    StendarrDailyShift *= 0.25
    AkatoshDailyShift *= 0.5
```

**Restoration:**
- Acts of mercy and justice rebuild integrity slowly (+5 per significant act)
- Visiting Stendarr shrine with clean hands (+10)
- Completing a quest to help an NPC without reward (+5)

---

**Unique Mechanic 3: Druidic Standing (LOCKED)**

Applies to Y'ffre path players.

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
  Permanent −10 DevotionLevel scar from excommunication period
```

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

---

**Curse State Architecture (LOCKED)**

Breton curse states are uniquely path-dependent — same curse lands completely differently per tradition:

```papyrus
Function ApplyWerewolfInterpretation(int eventType)
  if bTradition == TRADITION_WITCHCRAFT
    ; Glenmoril is family — Hircine already in frame
    ; Most natural werewolf path in all of Tamriel
    LifestyleBucket += 3  ; coven connection, Hircine welcomed
    SocialBucket += 2     ; Glenmoril community available

  elseif bTradition == TRADITION_DRUIDIC
    ; Theological split — beast-kinship familiar but wrong god gave it
    ; Resolved by Druidic Trial choice (see above)
    LifestyleBucket += 1  ; beast-shape is familiar
    SocialBucket -= 1     ; Y'ffre priesthood disapproves pending Trial

  elseif bTradition == TRADITION_IMPERIAL
    ; No framework — silent, uncomfortable
    LifestyleBucket -= 1  ; no religious home
    SocialBucket -= 2     ; knightly orders incompatible
  endif
EndFunction
```

**Summary of tradition × curse matrix:**

| | Imperial Divines | Druidic (Y'ffre) | Witchcraft |
|--|-----------------|-----------------|------------|
| Vampire | Horror, Nine Divines lost, knightly oaths broken | Absolute excommunication (worst), ritual re-entry possible | Partial home in Volkihar court, witch-mother acceptance |
| Werewolf | Silent, no framework, SocialBucket penalty | CONTESTED — Druidic Trial fires, player chooses fork | Natural fit — Glenmoril is family, Hircine already in frame |

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
Layer 3 (primary Good Daedra focus) unlocked by bucket threshold — player choice
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
  Triggered by bucket threshold (same system as Nord/Breton)
  Ancestor practice (Layer 1) remains at FULL weight always
  Choosing Azura never reduces ash-prayer — only adds weight on top
```

**Critical distinction:** Choosing a primary Good Daedra never competes with ancestor devotion. They are theologically the same tradition at different depths.

**Primary God Options (Layer 3):**

| God | Bucket Affected | Threshold Trigger | Devotional Acts |
|-----|----------------|------------------|-----------------|
| Azura | LifestyleBucket × 2 | LifestyleBucket sustained | Dawn/dusk observance, prophetic dreams, Azura's Star quest |
| Boethiah | CombatBucket × 2 | CombatBucket sustained | Strength proved, rivalry overcome, conspiracy acts |
| Mephala | SocialBucket × 2 | SocialBucket sustained | Secrets maintained, hidden communities, information acts |

Other two Good Daedra remain active at × 0.75 after Layer 3 commitment.

**Bucket Meanings (Dunmer-specific interpretation):**

```
CombatBucket = acts witnessed by ancestors (honour/shame framework)
  Boethiah adds: strength proved beyond mere survival
  
SocialBucket = community solidarity, ancestor consultation, oral history
  Mephala adds: hidden communities, webs of trust/knowledge
  
LifestyleBucket = shrine maintenance, offerings, daily ash-prayer practice
  Azura adds: dawn/dusk observance, prophetic attentiveness
```

**Quest-choice integration (LOCKED):**
- Dunmer quest choices should layer on top of ancestor practice rather than replace it
- When a quest touches exile, family, hidden community, or Good Daedra legitimacy, it should carry heavy weight

**Heavy Dunmer quest signals (LOCKED):**
- `Azura's Star` and other twilight, prophecy, or threshold quests strongly weight `Azura`
- `Boethiah's Calling` and other rivalry, overthrow, or strength-proving resolutions strongly weight `Boethiah`
- `The Whispering Door`, hidden-network, or secret-brokerage quest content strongly weights `Mephala`
- `Grey Quarter`, Dunmer solidarity, refugee-protection, and diaspora-survival choices strongly weight the ancestor layer plus broad `Good Daedra` legitimacy
- `Burial`, `family duty`, and proper-dead obligations, when Skyrim exposes them, strongly weight the ancestor layer

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
  Permanent −10 DevotionLevel scar (ancestors remember the silence)
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

### 10.5 Altmer (LOCKED — penalty values deferred to implementation review)

**Setup Flow:**
```
Step 1: Choose faction alignment
→ [Thalmor Orthodox]    ThalmørAlignment starts at 75 (enforcement as faith)
→ [The Divine Body]     ThalmørAlignment starts at 50 (moderate cultural practice)
→ [Psijic Tradition]    ThalmørAlignment starts at 25 (Old Ways, heterodox)

Step 2: Worship broadly or commit to primary god
→ Broad worship cap: Tier 2 (Faithful)
→ Tier 3 only through primary god commitment
→ Bucket threshold trigger system (same as all poly races)
→ Faction shapes accessibility of gods, not availability
```

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
  Triggered by bucket threshold
  Auri-El (Layer 1) remains at full weight always
```

**Full Pantheon — 9 worshippable gods (Lorkhan excluded):**
UESP confirmed: Auri-El, Trinimac, Magnus, Syrabane, Y'ffre, Xarxes, Mara, Stendarr, Phynaster
(10th listed is Lorkhan — excluded as active penalty, not worshippable)

| God | Domain | Bucket Trigger | Faction Affinity |
|-----|--------|---------------|-----------------|
| Auri-El | Time, return, supreme ancestor — Layer 1 always | Layer 1 always | All |
| Magnus | Magic source, escape from Mundus | LifestyleBucket | Psijic primary |
| Trinimac | Martial virtue, civilisational defence | CombatBucket | Thalmor primary |
| Xarxes | Ancestry, secret knowledge, death records | SocialBucket + LifestyleBucket | Psijic / Divine Body |
| Y'ffre | Nature laws, Earthbones | LifestyleBucket | Divine Body / Moderate |
| Mara | Fertility, family, wife of Auri-El | SocialBucket | All |
| Stendarr | Compassion, righteous rule | SocialBucket + CombatBucket | Divine Body |
| Syrabane | Magical protection, apprentices | LifestyleBucket | Psijic / Divine Body |
| Phynaster | Longevity, elven heritage | LifestyleBucket | All (cult) |

---

**Unique Mechanic: ThalmørAlignment Track (LOCKED)**

Same reusable PDV_ReputationTrack script as Imperial ConcordatStanding and Breton WitchcraftExposure.

```
ThalmørAlignment (0–100)
Thalmor Orthodox starts: 75
The Divine Body starts: 50
Psijic Tradition starts: 25

Low (0–30) = Heterodox: scholarly independence, private doubt, Psijic-leaning
  LifestyleBucket shift × 1.5 (self-cultivation prioritised)
  CombatBucket shift × 0.75 (enforcement feels wrong)
  Magnus/Syrabane devotion paths MORE accessible
  Daedra worship RISKS exposure (breaks oldest Altmer religious law)

Mid (31–69) = Orthodox Moderate: standard practice
  All buckets at × 1.0
  Full pantheon equally accessible

High (70–100) = Thalmor Devout: enforcement as worship
  CombatBucket shift × 1.5 (hunting heresy IS worship)
  LifestyleBucket shift × 0.75 (less personal cultivation time)
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

**Unique Mechanic: Lorkhan Adjacency Penalty (LOCKED — values deferred)**

UESP/Imperial Library confirmed: Lorkhan is the Corpse-God, the most unholy power
in Altmer theology. He permanently broke Altmer connection to the spirit plane.
Any act validating, strengthening, or celebrating the mortal world he created
triggers a direct DevotionLevel hit — bypassing buckets entirely.

**Why it bypasses buckets:** Not "you did something your god disapproves of" —
it's "you touched the thing that broke us." Theologically categorical.

**Lorkhan's names across cultures (all trigger same penalty):**
Lorkhan (Altmer), Shor (Nordic), Shor/Shezarr (Cyrodiilic), Sheor (Breton),
Sep (Hammerfell), Lorkhaj (Khajiit), Lorkh (Reachmen)

**Tier structure (penalty values deferred to implementation review):**

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

**Design intent (LOCKED):** Tier 3 acts mean a player who engages normally with
Skyrim's content accumulates minor penalties. This is intentional — the entire
mortal world is Lorkhan's creation. For an Altmer, simply being in Mundus is
already a theological compromise. The penalties reflect constant low-grade
dissonance of Altmer existence.

---

**Psijic Tradition — Unique Event (LOCKED)**

UESP confirmed: Psijic Order practices the Elder Way / Old Ways of Aldmeris —
introspection, meditation, mastery of self through Mysticism.
```
EVENT_MYSTICISM_PRACTICE
  Fires when: player uses Alteration, Illusion, or reads certain obscure tomes
  Psijic-aligned players: generates LifestyleBucket shift (magical discipline = devotion)
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
  DevotionLevel accumulates at 25% rate
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
3. `The Exchange` = `Z'en`
4. `The Bandit Road` = `Baan Dar`

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

**The Old Contract (LOCKED):**
```
Only Bosmer path with hard or semi-hard Green Pact compliance mechanics
Uses custom Bosmer-specific buckets or rule checks
Represents strict orthodoxy and the heaviest devotional burden
Has the highest ceiling of all Bosmer paths as payoff
```

**The Living Story (LOCKED):**
```
Uses the shared three-bucket architecture
Adds a light Bosmer-only ForestAttunement overlay
Restricted to high-confidence detectable triggers only
```

**The Living Story gameplay identity (LOCKED):**
- Y'ffre-led, but rounded out by stronger influence from the secondary Bosmer gods
- Not “Y'ffre-lite” and not failed orthodoxy
- Represents Bosmer diaspora spirituality outside full Pact enforcement

**The Living Story event structure (LOCKED):**
- `LifestyleBucket`: Y'ffre + Arkay
- `SocialBucket`: Mara + Xarxes + Stendarr
- `CombatBucket`: Y'ffre hunting conduct + Stendarr restraint
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
- Shared bucket architecture
- `SocialBucket` + `CombatBucket` do most of the justice / reckoning work
- `LifestyleBucket` carries the softer toil / trade / balance-of-living layer

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

**Current-era 4E 201 weighting rule (LOCKED):**
- Weight gods by how a Redguard in Skyrim would actually live and interpret them in 4E 201
- Do not flatten the pantheon into equal pan-historical relevance

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

**Broad → focused structure (LOCKED):**
```
All three sects begin in broad sect-shaped Yokudan worship
Broad worship can reach Tier 2 (Faithful)
Tier 3 (Devoted) requires focused primary deity emphasis
```

Rationale:
- Broad Redguard worship is still real devotion, not indecision
- Focused commitment is what unlocks deepest personal favor

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

**High-confidence trigger rule (LOCKED):**
- `City Orc` and other compromise modes should only use high-confidence detectable Skyrim proxies
- Do not attempt brittle social simulation for urban compromise

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

All sixteen active Skyrim-facing Prince paths are in scope. Jyggalag remains omitted unless future Sheogorath content requires a lore note.

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

The future race signal matrix must include Daedric-specific fields where relevant.

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

This section is locked as the architectural baseline. The detailed race-by-Prince signal matrix remains future work.

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

### 12.8 Bosmer — Own Green Pact Tagging System (LOCKED)

The Old Contract path uses its own tagging system for Green Pact detection, mirroring the approach Requiem/Races Redone use. This is NOT a dependency on those mods — PDV implements its own tag layer that functions independently.

### 12.9 Altmer — Tier 3 Lorkhan Penalty Weighting (LOCKED)

Tier 3 mortal-validation penalties (marriage, homestead, adoption, etc.) are **lightly weighted**. Not meant to punish normal play — meant to trigger evocative reactions and reflect internal pressure.

Design intent: The penalty triggers events and flavor, not harsh mechanical punishment. A player who marries or builds a home gets a spiritual *reaction* — internal Altmer dissonance manifesting as flavor/notification — not a devastating devotion collapse.

This clarifies the "values deferred to implementation review" note in Section 10.5.

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
