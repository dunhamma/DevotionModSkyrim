# M1 — Competitor & Inspiration Teardown Dossier

**Milestone:** M1 — Teardowns · **Status:** COMPLETE (exit gate satisfied)
**Method:** three parallel research passes (Skyrim faith mods · Skyrim intervention/omen/curse + frameworks · cross-game), synthesized under review. Cards condensed; see `01_mechanism_bank.md` for the cross-cutting pattern library and the M2 hand-off.

## Exit-gate coverage matrix
Each output channel needs ≥2 precedents; each driver ≥1. ✅ all met.

| Source | A1 Demand | A2 Omen | A3 Interv. | A4 Mood-boon | B1 Recent | B2 Context | B3 Politics | B4 Arcs |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Wintersun | ● | | | ● | ● | ◐ | | |
| Pilgrim | ● | | | ● | | | | |
| Gods & Worship | ● | ◐ | | ● | ● | | | |
| Pantheon | | | | ◐ | | ◐ | | |
| Andromeda | | | ● | ● | | | | |
| Sacrosanct/Growl | ● | | ● | ● | ● | | | ◐ |
| Sands of Time/Genesis | | ● | | | ◐ | ● | | |
| SPID/KID/BOS | | ● | | | | ● | ● | |
| Hades | ● | | ● | ● | | | ● | |
| CK3 | ● | ● | | | ● | ● | ● | ● |
| Pillars of Eternity | | | | ● | ● | | ● | |
| The Sims | ● | | | ● | ● | ● | | |
| Black & White | | ● | ● | | ● | | | ● |
| Serana DAO / SRR | ● | ● | | ● | | | ◐ | ● |
| **Totals** | **8** | **6** | **4** | **9** | **7** | **6** | **5** | **5** |

● = strong precedent · ◐ = weak/partial.

---

## Cluster 1 — Skyrim faith / worship / pilgrimage mods

### Wintersun – Faiths of Skyrim (Nexus 22506, EnaiSiaion) — the incumbent
- **Mechanism:** favor lifecycle — follower at shrine → per-deity tenets (duties+taboos) → `Pray` (+5%/24h) → shrine worship (+10-15%) → daily decay (Divines −2.5%/day, Daedra −5%/day) → binary Devotee threshold (100%) unlocks a 2nd power.
- **How:** favor stored on the unused vanilla AVs `VoicePoints`/`VoiceRate` on the player (zero globals; conflicts with anything else writing them). Tenet adherence via discrete event hooks (`OnActorKill`/`OnCrimeCommitted`/`OnQuestCompleted`/`OnSkillIncrease`) → `ModAV`. Decay via an 86400/timescale `RegisterForSingleUpdate` loop.
- **Borrow:** the zero-overhead "store the scalar on an unused AV, poll natively" trick; the split *passive-scaled-by-favor + threshold-power* reward shape; the cheap behavior event hooks (= our B1).
- **Differentiate:** tenets are **static/hardcoded** and the god **never speaks first**. PDV makes them **dynamic, mood-driven, god-initiated demands** with a real mood state machine.
- **Daedra:** mechanically differentiated (double decay, behavior-gated Devotee) but philosophically timid — the Prince has no *wants that change*. PDV gives each Prince a mood-reactive demand surface.
- **Channels:** A1(static), A4(2-band), B1(strong), B2(shrine-only).

### Pilgrim – A Religion Overhaul (Nexus 54099; OSS github.com/TateTaylorOH/Pilgrim)
- **Mechanism:** prayer-recall — a `Prayer` lesser power re-applies the **last shrine's** blessing via a kneel animation; Daedric powers are "volatile, extract a great cost."
- **How (source-verified):** a **storage singleton** `MAG_BlessingStorageScript extends Quest` holds just `{Prayer, LastBlessing, LastMessage}`. Shrine `OnActivate` casts the blessing, one-time-adds `Prayer` (guarded by `HasSpell`), and overwrites the two pointers. `Prayer`'s effect `PlaceAtMe`s a **prayer-mat furniture**, force-sits the player, and on `OnSit` re-casts `LastBlessing`. Daedric "volatility" is authored into the spell records, **not** a code branch. `OnInit` injects deity items into hold vendor lists.
- **Borrow:** the **storage-singleton** state pattern (one quest, a few pointers, zero globals/save-bloat) — ideal shape for per-deity mood state; the **prayer-mat furniture trick** for a "the god contacts you" kneel scene (~5 lines, no anim framework); the `HasSpell`-guard-before-`AddSpell` discipline; the `OnInit` item-injection pattern for material tithes.
- **Differentiate:** entirely **stateless** (two-pointer swap, no accumulation); volatility is static not mood-scaled; no inter-deity awareness; never fires unprompted.
- **Daedra:** the only mod here with a **distinct Daedric perk path** (Conjuration *Cultist* vs Restoration *Pilgrim*) — validates mechanically-distinct Daedric channels. Make the blessing spell a mood-keyed FormList selection.
- **Channels:** A1(item inject), A4(binary volatile).

### Gods and Worship (Nexus 45011 + patch hubs)
- **Mechanism:** 6-rank affinity ladder (Believer→High Priest) unlocking powers, a temple, and acolyte followers; community **quest-patch hub** assigns affinity deltas to existing/modded questlines.
- **How:** per-deity quest stage bands = ranks; `Meditate` recall power; **public Papyrus API** (`ModAffinity(deityKeyword, delta)`) that tiny shim ESPs call from `OnQuestCompleted` fragments — **no base-mod edits**. Priest rank → "holy vision" → pilgrimage quest → Hearthfire-style temple.
- **Borrow:** **THE most scalable idea in this cluster** — expose a public `PDV_ModMood(deityKeyword, delta, context)` so PDV's own patches *and the community* wire any questline to any deity's mood; the holy-vision→pilgrimage arc as an A4 capstone.
- **Differentiate:** linear upward rank ladder with a "victory state" (temple) vs PDV's signed, crashable, endless mood loop; still unidirectional (player→affinity), never god-initiated.
- **Daedra:** treats Daedra isomorphically to Divines (misses the chance). PDV makes the Daedric path a volatile oscillator.
- **Channels:** A1, A4(strong multi-step), B1(strongest, via API), A2(weak one-shot vision).

### Pantheon – Worship and Prayer (Nexus 55317)
- **Mechanism:** minimal one-power loop — `Invocation` recalls any of up to 20 tracked shrine blessings (circular buffer); ESL-flagged, MCM-optional.
- **How:** a FormList/array circular buffer of blessing spells; menu via UIExtensions, else cycle-and-notify; reuses Pilgrim's prayer-mat; **config encoded as dummy-spell presence/absence** (no MCM dependency); built as a *layer* reading Pilgrim's and Wintersun's storage interfaces.
- **Borrow:** the **dependency-free "config as spell presence"** trick; the **rotating buffer as a generic "recent events" window** (directly reusable for B1); the single-power UX entry point; UIExtensions-graceful-degradation.
- **Differentiate:** player-as-shopper (you pick the god) vs god-pushes-to-you; blessing-only, no negative outputs; stateless.
- **Channels:** A4(weak), B2(very weak location history).

---

## Cluster 2 — Skyrim intervention / omen / curse + distribution frameworks

### Andromeda – Unique Standing Stones (Nexus 14910, EnaiSiaion)
- **Mechanism:** conditioned ability swap — abilities behave differently by real-time actor state (combat / health% / resource pool) with trade-offs and cooldowns.
- **How:** passive MGEF abilities with native **Condition Function stacks** (`IsInCombat`, `GetActorValuePercent Stamina/Health/Magicka`) — zero script cost, per-frame native eval. Cheat-death (`Undying Love`) = timed MGEF + a "spent" keyword removed after a **15-min real cooldown** via `RegisterForSingleUpdateGameTime`. Capstone power gated on "touched all 13 stones."
- **Borrow:** **the conditioned-MGEF pattern for A3 clutch-saves** (`IsInCombat==1 && Health%<0.15` → free, scriptless); the 15-min `RegisterForSingleUpdateGameTime` cooldown; resource-conditioned A4 boons; the "all milestones met" capstone gate.
- **Differentiate:** no mood, player-chosen not god-initiated, no inter-deity suppression. PDV wraps the same conditions in a `mood >= Favorable` gate and a `no rival intervened recently` gate.
- **Daedra:** high — each Prince gets a domain-themed threshold (Meridia smites undead at low HP, Namira triggers frenzy at starvation).
- **Channels:** A3(template), A4(resource→mood threshold).

### Sacrosanct / Growl (Nexus 3928 / 31245, EnaiSiaion) — staged state machine
- **Mechanism:** game-time-timer-driven **staged hunger state machine** (4 stages); each stage swaps an ability bundle, applies stat modifiers, triggers NPC reactions; terminal stage forces involuntary behavior; **a single feed resets to stage 0**.
- **How:** `RegisterForUpdateGameTime` loop on a player alias checks elapsed-since-feed; on threshold cross → `RemoveSpell(old bundle)` + `AddSpell(new bundle)` + one-time notification. **Growl's key trick: the update interval *shortens* at higher stages** → escalating urgency without per-frame spam. Involuntary transform = lunar-phase probability roll, **blocked by a keyword gate** (Hircine's Ring). NPC flee via race/faction relationship, no script.
- **Borrow:** **THE template for Daedric displeasure escalation** — timer loop, ability-bundle swap per band, **interval-shortening = "the master grows impatient,"** **single act resets to zero**, **keyword-gate suppresses terminal events** (= our "completed arc" flag). Stacked conditions (stage AND combat AND health) for smite.
- **Differentiate:** stages are symmetric/universal — PDV makes them **deity-specific** (Hircine=days-since-hunt, Molag Bal=days-since-domination); add B3 conflict and a B4 authored crisis stage.
- **Daedra:** extremely high — primary model for all 16 Princes' displeasure + forced-compulsion arcs.
- **Channels:** A1(feed-reset), A3(combat sub-trigger), A4(stage bundles), B1(elapsed timer), B4(terminal compulsion).

### Sands of Time / Genesis (dynamic-event mods)
- **Mechanism:** invisible-marker + cheap on-cell-enter/timer spawn with safety checks, MCM frequency, self-cleaning.
- **How:** master quest listens `OnPlayerChangeCell`/sleep; reads cell **location keyword** to pick a pool; `PlaceActorAtMe` at an XMarker passing a distance check, then deletes the marker; a per-actor **keyword-flagged cleanup** script disables/deletes when unloaded + out of combat + player absent. Anti-spam: global **min-cooldown** (`fLastEncounterTime`), **combat check before firing**, distance check, randomized interval. ~3 scripts total.
- **Borrow:** **the XMarker+`PlaceActorAtMe`+self-cleanup pattern for A2 animal omens** (stag/crow/wolf), **location-keyword filtering** for omen appropriateness (= B2), the **sleep-probability check as the A2 dream channel**, and the **MCM omen-density slider as master anti-spam**. Keep the omen subsystem to ~3 scripts.
- **Differentiate:** content-neutral hostile spawns → PDV omens are **thematically authored** (assigned deity, mood gate, ambient audio cue), paired with a subtle diegetic notification, deity-tuned lifetimes.
- **Daedra:** high — every Prince has an omen creature/prop; same pattern.
- **Channels:** A2(template), B1(recency gates probability), B2(location filter).

### SPID / KID / Base Object Swapper (powerofthree) — data-driven distribution
- **Mechanism:** scriptless, conflict-light, **last-in-load-order** distribution of spells/perks/keywords to NPCs and base-object swaps, via `*_DISTR.ini` / `*_KID.ini` / `*_SWAP.ini`.
- **How:** SKSE DLLs intercept at engine load; **lazy distribution on actor/reference init** (no scripts, no save interaction, leaves no orphans). SPID syntax `FormType=Form|StringFilters|FormFilters|LevelFilters|TraitFilters|Count|Chance` with rich filters (keyword/faction/race/level/sex/class/traits) and `Chance%`. KID can **mint new keywords** that don't exist in any plugin. BOS swaps meshes/forms conditioned on `Cell/Location/Keyword/Region` filters.
- **Borrow:** **the canonical "authorable, not opaque" surface for B3** — distribute faith auras to priest/cultist factions (`Spell=PDV_ArkayPresence|...|100`) with zero conflict against NPC overhauls; KID to mint `PDV_HircineSacred` keywords with no ESP; BOS to swap omen props (urns→offering bowls) in deity-tagged cells; `Chance%` as free density tuning.
- **Differentiate:** static at load — **doesn't see runtime mood**. PDV layers a Papyrus MGEF condition reading a `PDV_*Displeasure` global so the distributed aura flips behavior at runtime.
- **Daedra:** high — each Prince has associated NPC factions; one INI line per faction.
- **Channels:** A2(prop swaps), B2(filters), B3(faction auras).

---

## Cluster 3 — Cross-game mechanisms (design-pattern imports)

### Hades — Olympian boons / godpool / Sacrifice
- **Mechanism:** only **4 of ~10 gods active per run** (godpool); 5 exclusive Core slots gods compete over; **Sacrifice** lets a god *replace* another's boon (inherits level, **+1 rarity**); Trial of the Gods = pick one of two, spurned god retaliates *in the moment* then forgives; per-god mechanical kit + voiced personality + Duo boons.
- **Borrow:** **the active patron pool as a noise filter** — only 2-4 recently-relevant deities can fire demands/omens/interventions at once (dormant ≠ absent); **Sacrifice-as-rivalry (A3/B3)** — a Prince offers to overwrite a rival's standing boon (more potent, but the spurned god's mood drops + may issue a retributive demand); **domain-flavored wrath** (each Prince's intervention keyed to their domain, never generic).
- **Differentiate:** PDV is persistent — the pool **decays (EWMA)** not resets; B3 rivalry is **persistent authored lore** + a decaying opinion delta, not ephemeral per-room.
- **Daedra:** high — Princes = distinct kits; the 4-of-16 pool is essential given the large pantheon.
- **Channels:** A1, A3(sacrifice), A4(rarity escalation), B3(rivalry).

### Crusader Kings 3 — Stress / Dread / Opinion
- **Mechanism:** stress meter (0-400) with a **mental-break event at each 100 band** (gates drama, doesn't continuously punish); **trait-modified valence** (same act, opposite sign per personality); **event-stamped, decaying opinion modifiers** (each named/inspectable, own decay); **Dread** as an orthogonal 0-100 axis with discrete behavioral-flip bands (Intimidated/Terrified).
- **Borrow:** **banded threshold events, not continuous penalty** — crossing a mood band fires a demand/omen, silence between (validates our EWMA-bucket design as player-friendly); **per-deity trait-valence tables** (same act = +Molag Bal / −Meridia); **event-stamped decaying modifiers = the concrete implementation of the B1 EWMA as a visible audit trail**; **Dread as a separate Dominance axis** for submission-type Princes (B4).
- **Differentiate:** the meter belongs to the **god**, not the player character, and stays partly opaque (read a divine mind, not a health bar); keep god→player and god↔god opinion tables separate.
- **Daedra:** very high — the valence-table architecture is exactly why Princes need non-uniform per-deity profiles.
- **Channels:** A1/A2(band crossing), B1(decaying modifiers — top implementation model), B2, B3(opinion table), B4(Dread axis).

### Pillars of Eternity — Priest dispositions / Holy Radiance
- **Mechanism:** 10 independently-tracked dispositions (3 ranks each); each deity has 2 favored + 2 disfavored; **Holy Radiance scales ±0.2 per rank** of favored/disfavored (caps ±60%), applied to damage+healing.
- **Borrow:** **the multi-dimensional behavior profile → deity-specific net scalar = the concrete A4 mood-scaled-boon formula** (boon power = Σ favored-rank·+w + Σ disfavored-rank·−w); **explicitly authored per-deity value profiles** (2-3 favored / 1-2 disfavored tags — feeds the stance-adjustor); **ranks not raw points** (sustained pattern advances a rank → prevents one-off swings).
- **Differentiate:** PDV's god-facing profile is **partly opaque** (read via omens, not a sheet); add **recency weighting** (EWMA) PoE lacks; evaluated by **all pool gods simultaneously**, each weighting differently.
- **Daedra:** near-perfect fit — PoE already has gods with **opposing** dispositions (Skaen vs Eothas) = B3.
- **Channels:** A4(formula), B1(multi-dim ranks), B3(opposing profiles).

### The Sims — needs / moods / autonomous action
- **Mechanism:** independent decaying need meters; mood = **weighted vote** of time-limited moodlets (dominant emotion wins, with edge); **critical-threshold autonomous override** (a red need makes the Sim act on its own).
- **Borrow:** **unmet-tithe as a decaying "need" that triggers an autonomous DEMAND (A1)** — the god demands because you've been *absent*, not because you erred; **mood = weighted blend of decaying, intensity-weighted recent-act moodlets** (= EWMA expressed as an expiring moodlet pool — past acts drop out of the window); **keep the demand-need meter SEPARATE from the mood meter** (Sims separates needs from moodlets).
- **Differentiate:** authored per-deity decay rates (Boethiah impatient, Azura patient); no active meter for a god outside the patron pool; wrap the threshold event as a dream/vision/emissary, not a flashing bar; the god has agency the Sim lacks.
- **Daedra:** high — asymmetric per-Prince decay encodes personality (Mehrunes Dagon fast; Namira slow but extreme).
- **Channels:** A1(autonomous), A4(moodlet blend), B1(expiring pool), B2(context moodlets).

### Black & White — god-as-agent / interpreted behavior
- **Mechanism:** alignment as **interpreted evaluation** of each act in context (not a tally); the world/hand is the mood readout; creature learns via BDI + reinforcement that updates *beliefs*, not just acts.
- **Borrow (the north star):** **interpret behavior patterns, never count acts** — react to *who/why/recently*, requiring behavior-tagging on events (victim faction, context flags, location) feeding the stance-adjustor; **the god's mood changes the visible WORLD** (A2 ambient: Meridia-pleased = brighter days/repelled undead; Molag-Bal-wroth = shadow weather in owned interiors); BDI-style "the god prefers the demand type this player keeps fulfilling" personalizes B4 arcs without scripted branches.
- **Differentiate:** reject the **single good↔evil axis** — use the PoE multi-dim model; the deity (not the player's pet) is the learning agent; learning is **event-driven** (Skyrim hooks), not continuous.
- **Daedra:** medium-high — "world changes with the Prince's disposition" suits each Prince's domain aesthetic.
- **Channels:** A2(ambient world-state), A3(agent channel choice), B1(interpreted pattern — the engine's philosophical core), B4(BDI desire profile).

### Serana Dialogue Add-On / Relationship Revamped — companion affinity
- **Mechanism:** affinity float + **stage gates** (Stranger→…→Close), advanced by a **time-OR-depth** dual gate; situational/location awareness; staged voiced intimacy.
- **Borrow:** **stage-gated content pools for the bilateral patron bond (B4)** — a Prince addresses a Novice vs a Chosen differently, and stage gates which A1/A2/A3/A4 events are even available (a Chosen of Azura gets prophecy dreams; a Novice gets generic omens); **"god recalling a specific past act" as an authored dream/omen payload** (set a flag at the act, condition later dialogue on it — text-only, in-scope); **time-OR-ritual dual gate** to prevent speed-running intimacy.
- **Differentiate:** a deity is **remote, not proximate** — depth manifests as *specificity/nature* of contact, not following you; **favor a few high-quality authored callbacks** over present-moment chatter (each episodic intervention should feel weighted with history); B3 rivalry as a **structural ceiling** on the bond (Molag Bal's mark impedes Meridia's stage advance).
- **Daedra:** very high — Prince↔Champion is lore-native as a deepening personal bond.
- **Channels:** A1(stage-gated), A2(dream + recall), A4(stage gate), B4(bilateral arc, dual gate, reminiscence, staged intimacy).
