# PDV Race Reward Budget Ledger

**Created:** 2026-05-30
**Status:** Living gameplay-balance ledger
**Owner:** Companion to `references/authoring/PDV_RaceGameplayBalanceAudit.md`

## Purpose

This ledger turns the race gameplay audit into an operating table. Use it before authoring new race rewards, Daedric paths, contextual favors, or proof slices.

The question is not "does this race have a strong buff?" The question is:

> Does this race have a comparable amount of felt religious life without exceeding the hybrid boon budget?

Felt value includes stats, temporary favors, recognition, dialogue, ritual access, recovery arcs, social consequences, status readouts, and neglect texture.

## Budget Rules

Use these rules when reviewing or adding content:

1. Most races should not feel like they have more than two meaningful always-on boon families at once.
2. Persistent substrates should mostly express identity, maintenance, recovery, environmental fit, or utility.
3. The foreground patron/path/mode should remain the loudest steady reward layer.
4. Contextual favors should carry race-specific flavor without becoming a permanent combat package.
5. Privileges and recognition count as reward wealth even when they do not alter actor values.
6. Prices, stigma, neglect, and recovery count as design weight. A race with high friction may need richer recognition, not larger stats.
7. Sparse-hook races need more deliberate authored feedback than hook-rich races.
8. A curse or Daedric path must not silently replace the native race architecture.

## Immersion Budget Rules

Immersion is part of the reward budget, not decoration after the numbers are tuned. A race can have modest stats and still be rich if the player feels noticed by the right tradition, place, taboo, ritual, or social world. A race can also have strong stats and still fail if the reward could belong to any race.

Use these rules before promoting a reward, favor, privilege, curse state, or non-god lane:

1. Every reward must answer: "Why would this race read this as religious?"
2. Immersion value counts beside stat power, temporary favors, privileges, and recognition.
3. High-friction lanes need compensating diegetic support: status, interpretation, ritual recovery, NPC recognition, or scar text before bigger numbers.
4. No reward should promote if the trigger is mechanically convenient but culturally opaque.
5. Ordinary-session immersion matters. Each race needs at least one maintenance, recognition, recovery, or status loop that is not combat-only.
6. Surfacing should be quiet unless the event is exceptional. Constant notifications weaken immersion even when the hook is valid.
7. Moon phases, Hist distance, Green Pact compliance, ConcordatStanding, ThalmorAlignment, life modes, sects, and similar lanes are reward budget, not flavor budget.

## Status Vocabulary

| Status | Meaning |
|---|---|
| `OK` | Current design shape is likely balanced enough for the next build pass. |
| `Watch` | The concept is sound, but tuning or proof can easily drift too rich or too thin. |
| `Thin` | The race or lane needs more reward wealth, feedback, hooks, or player-facing clarity. |
| `Overstack Risk` | Too many layers could be active, loud, or statistically strong at once. |
| `Incomplete` | A named architecture/spec slot must close before balance can be judged. |

## Race Reward Budget

| Race | Foreground Reward Layer | Substrate / State Layer | Contextual Favor Budget | Privilege / Recognition Budget | Price / Neglect Budget | Current Budget Read | Next Decision |
|---|---|---|---|---|---|---|---|
| Nord | Broad-to-primary patron worship; focused patron should be stronger than broad Old Ways/Nine Divines. | No true substrate. Pantheon baseline and Talos pressure are state/identity, not passive boon packages. | Broad lanes get softer blended favors; focused patron favors can be sharper. Phase 12 proves Kyne plus two broad lanes. | Very strong vanilla recognition surface: Greybeards, holds, Talos pressure, Nord dialogue, weather/outdoors. | Time, consistency, patron neglect, Talos risk, vampire rupture/scar. | `Watch`; Nord has the densest hooks and multiple runtime-proven pilots. | Cap broad-lane rewards below focused patron rewards; avoid letting Kyne/Talos plus broad worship stack into the best generic package. |
| Imperial | Broad Nine Divines into focused primary god; Talos is filtered by ConcordatStanding. | No true substrate. `ConcordatStanding` is political/theological pressure. | Civic acts, mercy, death duty, lawful order, honest work, and costly Talos defiance. | Strong institutional recognition: temples, Hall of the Dead, Legion/civic surfaces, private/public Talos response. | Civic compromise, compliance/defiance cost, vampire collapse. | `Watch`; Concordat identity is strong and proven, but favor triggers can become abstract. | Require concrete civic acts; do not reward faction membership alone. Make non-combat civic play feel as real as combat. |
| Breton | Chosen tradition lane: Knight's Road, Hidden Art, or Green Way. | No true substrate, but three tracks can all matter: `WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding`. | Per-tradition favor tables, not per-god launch tables. Hidden Art can be stronger only when cover/notoriety cost is paid. | Strong recognition potential through Vigilants, Daedric circles, standing stones, nature rites, cover/rupture surfaces. | Integrity loss, exposure, social rupture, excommunication, curse forks. | `Overstack Risk`; concept is rich enough to outshine simpler races if every track pays at once. | Budget each tradition separately. Keep tracks mostly pressure/meaning, not three simultaneous reward engines. |
| Dunmer | Focused Reclamation commitment: Azura, Boethiah, or Mephala; Daedric deviations use global Daedric system. | Strong ancestor substrate plus ancestor posture. | Shared ancestor/Reclamations favors are quiet; focused Reclamation favors can be marked and sharper. | Strong ritual/identity recognition: ash prayer, portable/private shrine, Dunmer community, Good Daedra quests. | Ancestor silence, curse posture, diaspora burden, Daedric deviation cost. | `Overstack Risk`; ancestor substrate is proven, but substrate plus focus plus deviations can stack too much. | Keep ancestor substrate mostly interpretive/utility. Foreground Reclamation is the main reward layer. |
| Altmer | Auri-El foundation plus secondary focus. | Light orthodoxy/coherence layer through `ThalmorAlignment`; Lorkhan pressure and crisis lane. | Crisis source scaffold compiles; `PDV_State_AltmerCrisis` is record-wired; the first two favor spell records, four trigger proof ACTI base records, three curse/exile `MESG` records, and four QASmoke proof references are wired/readback-clean and route-runtime proven. | Strong possible recognition through College, scholarship, Thalmor/orthodoxy, Psijic framing, crisis resolution, and focused-deity favor. | Strongest theology friction: Lorkhan pressure, crisis, werewolf halt, vampire terminal/exile tension; the first curse-message surfaces are wired but still need normal-play feel proof. | `Watch`; route proof exists, but more pre-beta gameplay surface is needed before a tester can fairly judge whether friction is meaningful, legible, and not punitive. | Pre-beta: build crisis playfeel, Exiled vampire cap, rejected-surface assertions, survey/status feel, and final placement. |
| Khajiit | Silent focused emphasis: Khenarthi, Azurah, Baan Dar, Rajhin, or Alkosh. | Strong lunar substrate, moon-cycle cadence, road homes, lunar posture, ShadowDrift. | Lunar and focus favors must obey the one-active cap. Phase bonus stays small; cycle consistency carries strength. Route proof is closed. | Road-home belonging, caravan/community recognition, moon/status readouts, threshold flavor. | Urban/indoor disconnection, road-home cadence, curse posture, shadow drift. | `Watch`; highly distinctive, but moon/road systems can become chores and Khenarthi/Azurah are easiest to reach. | Keep moon phase as amplification, not required scheduling. Give Baan Dar, Rajhin, and Alkosh sharp behavior-specific payoff without generic crime/combat loops. |
| Bosmer | Active path: Old Contract, Living Story, Exchange, or Bandit Road. | No true race-wide substrate. Green Pact and shared Pact memory are path-interpreted state. | Four path lanes need comparable richness; Old Contract can be hardest but not the only rewarding path. Phase 20 non-hunter route proof is closed. | Path-specific recognition: Pact reckoning, storytelling, debt settlement, pariah luck, Kynareth proxy. | Green Pact burden, path switching cost, forced reckoning, terminal Old Contract renunciation. | `Watch`; path system is runtime-proven, but Old Contract/hunter proof density can dominate attention. | Living Story, Exchange, and Bandit Road need pre-beta buildout before equal emotional payoff can be tested fairly. |
| Redguard | Sect-shaped foreground worship: Crown, Forebear, Ash'abah into focused primary. | Light ancestor reverence and death-duty layer. | Sect lanes need different flavors: orthodox inheritance, pragmatic road dignity, impurity burden. Route proof is closed. | Strong death-duty recognition; Far Shores token; Hall of the Dead/undead hooks; sect survey/favor/dialogue content drafted. | Death obligations, Ash'abah stigma, ancestor distance, vampire restoration through Tu'whacca. | `Watch`; content shape is rich, but death-duty and martial hooks can swallow sect nuance. | Protect Crown/Forebear/Ash'abah distinction. Build pre-beta proof that road, contract, form, and stigma rewards compete with undead-clearing. |
| Orc | Malacath-centered life mode: Stronghold, City, or Legion/Exile. | Light persistent life-mode standing; do not turn community standing into a strong substrate. | One lane per life mode; Stronghold can use richer hooks, City/Legion need curated dignity/service beats. Route proof is closed. | Blood-Kin, stronghold recognition, forged-work identity, private dignity, service/exile recognition. | Code pressure, humiliation/dignity choices, service burden, weak community outside strongholds. | `Watch`; Stronghold and smithing are naturally rich, while City/Legion need dynamic situational parity. | Equalize life-mode value. Forge rewards need quality/context limits; City/Legion need non-smithing recognition and self-made community payoff. |
| Argonian | Layered Hist-first devotion with People and Void/Sithis thresholds. | Strong Hist substrate, People layer, Void layer, bed of choice, Hist posture. | Hist/environment, People/community, and Void/death-facing favors need distinct caps. Route proof is closed. | Windhelm/Riften Argonian recognition, water/wetland context, bed of choice, Dark Brotherhood/Sithis only at threshold. | Hist distance, exile, vampiric silence/corruption, Sithis threshold risk. | `Thin/Watch`; architecture is locked, but non-Sithis reward wealth needs deliberate support. | Strengthen Hist/People rewards before adding Void runtime depth. Keep Sithis high-threshold so it does not become the obvious Argonian route. |

## Broad Reward Spec (per race)

This section resolves the broad-reward authoring gate: broad reward authoring is
blocked until each race below names its floor effect family, ceiling effect
family, magnitude range, cadence, grant/removal owner, stack cap, Survey/status
copy, rejected generic hooks, curse/Daedric interaction, and manual feel note.

Scope note (architecture): generic broad-worship lanes exist only where
culturally normal - Nord (Old Ways / Nine Divines), Imperial (Nine Divines),
and Redguard (sect-shaped). Dunmer, Khajiit, and Argonian use a layered or
substrate "broad" baseline. Bosmer (path), Orc (life mode), Breton (tradition),
and Altmer (Auri-El coherence) have **no generic broad lane**; their rows name
the baseline-lane equivalent so the ten fields are still answered.

Magnitude convention (all numbers are pre-tuning placeholders): the broad
**floor** is minimal-but-noticeable; the broad **ceiling** caps at Faithful
(Tier 2) and sits at roughly 50-70% of the equivalent focused-patron Devoted
value. Broad never inherits individual patron boons and never exceeds focused
reward. Final magnitudes are tuning work per the audit.

### Nord (broad lane: Old Ways / Nine Divines)
- Floor effect family: light blended hearth/weather/road steadiness reflecting broad Old Ways or Nine Divines practice (small outdoors/stamina/resist-flavored steadiness).
- Ceiling effect family: Faithful-tier blended broad favor (softened combination of pantheon-adjacent effects); strictly below focused Kyne/Talos Devoted boons.
- Magnitude range: Observant approx +3-5%, Faithful broad cap approx +6-10% or a minor resist/regen band; below focused Devoted (placeholder).
- Cadence: dawn-owned steady layer recomputed after broad-worship signals; blended favor refreshed by qualifying broad acts, not per-kill.
- Grant/removal owner: dawn pass in `PDV__ManagerQuest`; capped/demoted on patron commitment; stripped on vampire rupture.
- Stack cap: one steady broad-blessing family plus at most one active contextual favor (global one-active cap).
- Survey/status copy: thematic Old Ways vs Nine Divines readout, no piety numbers ("You keep the old ways of Skyrim").
- Rejected generic hooks: generic anti-Thalmor violence, ordinary travel, raw crafting, faction membership alone, repeat tomb/kill farming.
- Curse/Daedric interaction: vampire rupture suppresses broad favors (scar on cure); Hircine is a separate focused Daedric lane, not a broad booster.
- Manual feel note: broad Nord feels culturally complete at Faithful without a patron, yet always quieter than a focused patron; Skyrim notices via weather/hold/hearth, not a stat menu.

### Imperial (broad lane: Nine Divines, civic)
- Floor effect family: civic Nine-Divines steadiness earned from concrete lawful/mercy/burial acts.
- Ceiling effect family: Faithful civic blended favor; below focused primary-god Devoted; Talos is excluded from broad (favor only via faithful defiance).
- Magnitude range: small civic-flavored (minor barter/speech/restoration-adjacent or disease/undead protection from burial duty), Observant to Faithful; below focused (placeholder).
- Cadence: dawn-owned, refreshed by concrete curated civic acts or value thresholds, not attendance.
- Grant/removal owner: dawn pass; modified (access/priority, not buff) by `ConcordatStanding`; Concordat Enforcer corrodes Arkay/Stendarr until repair signals.
- Stack cap: one steady civic broad-blessing plus one active contextual favor; ConcordatStanding is pressure, not a stacked boon.
- Survey/status copy: Concordat band plus public/private Talos tension plus broad Nine Divines state, plain language.
- Rejected generic hooks: generic faction membership, generic temple attendance, ordinary bounty payment, generic anti-Thalmor violence.
- Curse/Daedric interaction: vampire collapse suppresses civic broad favor; Talos defiance is a standing/focused lane, never broad.
- Manual feel note: civic religion under public law and private conscience; non-combat civic play must feel as real as combat.

### Redguard (broad lane: sect-shaped - Crown / Forebear / Ash'abah)
- Floor effect family: broad sect worship reaching Faithful plus light ancestor reverence / death-duty coloring.
- Ceiling effect family: Faithful broad sect lane; Devoted requires focused primary commitment; ancestor reverence and Far Shores token support only (no third always-on family).
- Magnitude range: sect-lane small-to-moderate, below focused primary Devoted; HoonDing rare and weekly-capped (placeholder).
- Cadence: dawn plus sect-coded signal days (two in seven to switch Crown/Forebear); death-duty event-led; HoonDing weekly cap.
- Grant/removal owner: `PDV_State_RedguardSect` plus dawn pass; Far Shores token activator; Arkay used only as fallback infrastructure with copy that says Tu'whacca.
- Stack cap: one sect broad lane plus light ancestor layer plus one active favor; not a second substrate.
- Survey/status copy: sect (Crown / Forebear / AshAbah) plus death-duty / Far Shores state, Yokudan names primary even over Skyrim proxies.
- Rejected generic hooks: generic undead spam, generic gold-making, fast travel, generic combat, broad social-stigma simulation.
- Curse/Daedric interaction: Ash'abah impurity stigma; vampire restoration through Tu'whacca; Hircine/Molag Bal are curse-access.
- Manual feel note: protect Crown/Forebear/Ash'abah distinction; road, contract, form, and stigma must compete with undead-clearing; non-Ash'abah play stays satisfying.

### Dunmer (layered baseline equivalent - no generic broad lane)
- Floor effect family: ancestor ash-prayer substrate (always active, no passive decay) plus portable/private shrine and home bonus and diaspora solidarity.
- Ceiling effect family: ancestor substrate plus shared Reclamations (Quiet/Noted) up to feeling complete pre-focus; below a focused Reclamation foreground.
- Magnitude range: substrate interpretive/utility (small, no decay); shared Reclamations favors Quiet/Noted; marked moments wait for focus or major Good Daedra quests (placeholder).
- Cadence: substrate continuous (no decay) with ash-prayer/shrine cadence; dawn recompute.
- Grant/removal owner: `PDV_Substrate_DunmerAncestor` plus dawn pass; focus uses shared patron state (no Dunmer path enum); ancestor-posture handlers.
- Stack cap: ancestor substrate plus one Reclamation foreground; other Good Daedra background at reduced weight; never three focus packages.
- Survey/status copy: ancestor posture (Normal / Strained / Silent / RestoredScarred) plus shared Reclamations state.
- Rejected generic hooks: generic cruelty/violence (Boethiah), generic crime (Mephala), generic twilight/magic activity (Azura).
- Curse/Daedric interaction: ancestor silence posture; vampire cure/restoration scar; Daedric deviations route through the global system as deviation/pact/taboo.
- Manual feel note: layered, not path-based; broad Dunmer feels complete through ancestors and shrines even before a focus, and Skyrim's missing tombs must not punish.

### Khajiit (lunar baseline - balanced broad worship is valid)
- Floor effect family: lunar substrate, an always-active cosmological layer; balanced broad lunar worship is complete at Faithful, with small per-phase amplification.
- Ceiling effect family: lunar substrate plus one emergent focused emphasis plus the global one-active favor; phase bonuses stay small and never a third loud package.
- Magnitude range: phase amplification small; substrate strength from full-cycle consistency; below focused emphasis (placeholder).
- Cadence: substrate continuous; moon phase amplifies (optional, never mandatory scheduling); road-home circuit cadence; dawn focus evaluation.
- Grant/removal owner: `PDV_Substrate_KhajiitLunar` plus dawn pass; emphasis via `PDV_GLO_KhajiitFocusedEmphasis` (silent, not shared patron state); lunar-posture handlers.
- Stack cap: substrate plus one emphasis plus one active favor.
- Survey/status copy: lunar posture plus current emphasis, legible without schedule pressure, no piety numbers.
- Rejected generic hooks: repeating one convenient camp/bed (road homes need a 2-3 anchor circuit), generic crime/combat for Baan Dar/Rajhin/Alkosh, ordinary night travel for ShadowDrift.
- Curse/Daedric interaction: lunar posture Strained/Corrupted/ShadowDrift; vampire = Corrupted, lycanthropy = Strained; ShadowDrift only on dominant Nocturnal/shadow behavior.
- Manual feel note: the moons and road shape belonging without a calendar chore; broad lunar life stays viable at Faithful without forcing a focus.

### Bosmer (active-path baseline - no cross-deity broad lane)
- Floor effect family: active-path baseline practice (Old Contract / Living Story / Exchange / Bandit Road) plus shared Pact memory as modest positive weighting.
- Ceiling effect family: within-path deepening; Old Contract highest ceiling but most burdensome; the other paths reach comparable felt richness via recognition and momentary favors.
- Magnitude range: path-baseline small; below path-deepened or forced-reckoning payoff (placeholder).
- Cadence: path-state-driven; favor routes `100-107` event-led; Bandit Road reversal carries a seven-day cooldown.
- Grant/removal owner: `PDV_State_BosmerPath` plus manager favor counters; switching is destination-gated; no generic broad granter.
- Stack cap: one active path plus shared Pact memory weighting plus one active favor.
- Survey/status copy: active path plus `favor=oc/ls/ex/br` counters plus Pact compliance state.
- Rejected generic hooks: generic theft, generic killing, generic commerce, generic plant avoidance outside tagged surfaces, passive road travel.
- Curse/Daedric interaction: Green Pact burden; Hircine legible via Wild-Hunt adjacency but priced; path switching cost.
- Manual feel note: path identity is the frame; a flat broad lane would erase it, so breadth is interpreted through the chosen path.

### Orc (life-mode baseline - no generic broad lane)
- Floor effect family: Malacath code baseline within the active life mode (Stronghold / City / Legion-Exile): dignity, quality labor, and service as the one religious spine.
- Ceiling effect family: the active life-mode lane; Stronghold highest ceiling; City and Legion/Exile sharper situational moments but no second persistent substrate.
- Magnitude range: life-mode baseline small-to-moderate; forge rewards gated by quality/value/context; below deep commitment (placeholder).
- Cadence: life-mode-state-driven; service requires pressure-bearing completion; three-day soft-switch lockout after a mode change.
- Grant/removal owner: `PDV_State_OrcLifeMode` plus dawn pass; exactly one active scoring/favor lane at a time.
- Stack cap: one life-mode lane plus light life-mode standing plus one active favor; no second substrate.
- Survey/status copy: life mode (Stronghold / City / LegionExile) plus standing/dignity text.
- Rejected generic hooks: raw craft count, generic faction membership, ambient disrespect, ordinary travel, generic oath-breaking without a concrete quest surface.
- Curse/Daedric interaction: Malacath is native (not a Daedric-stigma path); code pressure applies; curse states are priced.
- Manual feel note: dignity under pressure across life modes; City and Legion/Exile are complete devotional lives, not failed Strongholds.

### Breton (tradition baseline - no generic broad lane by design)
- Floor effect family: none generic; the baseline is the chosen tradition (Knight's Road / Hidden Art / Green Way) at its entry standing. Do not implement a flat Breton pantheon or broad-worship blend.
- Ceiling effect family: within-tradition focused patron; the three standing tracks modify and pressure but never form a broad blend.
- Magnitude range: not applicable for broad; tradition-baseline magnitudes live in the per-tradition favor tables (placeholder there).
- Cadence: tradition-state and standing-track driven; no dawn broad blend.
- Grant/removal owner: `PDV_State_BretonTradition` plus the three standing tracks (`WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding`); no broad granter.
- Stack cap: one tradition spine plus one focused patron; tracks stay pressure/meaning, not stacked boons.
- Survey/status copy: chosen tradition plus track bands; explicitly no broad-worship readout.
- Rejected generic hooks: ordinary magic, College membership, private curiosity, generic shrine visits, generic tavern excess, and any flat-pantheon broad-worship hook.
- Curse/Daedric interaction: Hidden Art / Hircine fork priced via exposure and rupture; Green Way werewolf is a real fork, not a free hybrid.
- Manual feel note: Breton religion is tradition-first; a generic broad lane would flatten the spine, so it is intentionally absent.

### Altmer (Auri-El coherence baseline - no generic broad lane)
- Floor effect family: Auri-El dawn foundation - basic dawn practice, study, magic milestones, and coherent acts keep a non-edge Altmer net-positive (not a multi-god blend).
- Ceiling effect family: Auri-El foundation plus one secondary focus plus one active coherence favor; orthodoxy/alignment modifies or unlocks but adds no third steady stack.
- Magnitude range: small coherence/steadiness (dawn steadiness favor), Observant to Faithful baseline; below secondary-focus Devoted (placeholder).
- Cadence: dawn-owned coherence foundation; favors event-led on coherent acts.
- Grant/removal owner: dawn pass; `ThalmorAlignment` modifies access/interpretation; Lorkhan pressure only on tagged signals; curse/exile suppresses the positive lane.
- Stack cap: Auri-El foundation plus one secondary focus plus one active favor; no broad pantheon stack.
- Survey/status copy: crisis state (Dissonant / Questioning / Reasserting / ScarredResolved) plus coherence/orthodoxy; no broad-worship readout.
- Rejected generic hooks: ordinary existence, ordinary friendships, travel, post-first-crisis Dragonborn identity (no hidden Lorkhan debt); generic spellcasting, raw skill gain, generic kindness.
- Curse/Daedric interaction: vampire terminal/exile-limited; werewolf hard halt; no clean Daedric broad path.
- Manual feel note: coherence, not breadth; daily Auri-El life stays net-positive and a generic broad lane is omitted by design.

## Cross-Race Balance Flags

| Flag | Races | Why It Matters | Required Response |
|---|---|---|---|
| Hook-rich over-reward | Nord, Imperial | Skyrim exposes many direct hooks for these races. | Use ceilings, cooldowns, and softer broad rewards. |
| Track overstack | Breton, Altmer | Multiple tracks can become multiple reward engines. | Keep tracks as pressure/meaning unless a reward is explicitly budgeted. |
| Strong substrate overstack | Dunmer, Khajiit, Argonian | Persistent substrate plus foreground focus can exceed two-layer feel. | Substrate stays quiet/identity-heavy; foreground carries most power. |
| Sparse social hooks | Bosmer, Redguard, Orc City/Legion, Argonian People, Khajiit caravan | Vanilla gives fewer clean NPC/community surfaces. | Add curated recognition, status readouts, and custom-light beats where cheap. |
| Curse path overwrite | Nord, Khajiit, Argonian, Dunmer, Breton, Altmer | Hircine/Molag Bal/Nocturnal can erase native race meaning if too strong. | Native architecture remains visible; curse path carries price, stigma, exit, residue. |
| Craft/combat loop risk | Orc, Redguard, Bosmer Old Contract, Nord/Talos, Hircine | Repeated kills/crafting can become optimal grind. | Require context, quality, day caps, major beats, or anti-repeat scaling. |

## Race Immersion Budget

This matrix checks whether each race's reward budget has a strong enough fantasy carrier. Use it with the mechanical budget table above. A race is not balanced if its rewards are numerically fair but its best loop feels generic.

| Race | Signature Immersion Promise | Strongest Diegetic Reward | Thin / Risky Immersion Surface | Required Immersion Proof Before Runtime |
|---|---|---|---|---|
| Nord | Skyrim itself notices old roads, weather, holds, Talos pressure, and chosen patron life. | Survey/status, Kyne/Talos contrast, Greybeard/hold/Talos/Hircine recognition. | Hook density can become noise or make Nord feel like the default best-supported race. | Broad/focused readouts and contextual favors feel like Nord religious life, not a stat menu. |
| Imperial | Civic religion under public law and private conscience. | ConcordatStanding, public/private Talos handling, civic duty, mercy, lawful order. | Can collapse into faction tracker or abstract morality scoring. | Rewards come from concrete civic acts and visible public/private religious tension. |
| Breton | Chosen tradition shapes identity, risk, and belonging. | Knight's Road, Hidden Art, Green Way, cover, vow, exposure, druidic standing. | Three tracks can feel like system clutter or overstacked reward engines. | Tradition status is legible during normal play and each tradition has its own cost/recovery texture. |
| Dunmer | Ancestors and Reclamations follow the player into diaspora. | Portable/private shrine, ancestor silence, ash memory, Good Daedra focus. | Ancestor substrate can become a hidden meter if feedback is too quiet. | Ash, exile, ancestor posture, and private shrine feedback explain why the reward matters. |
| Altmer | Coherence is tested by Skyrim's Lorkhan-shaped world. | Crisis state, rejected-surface safety, dawn steadiness, orthodox costly enforcement. | Can feel punitive if pressure fires from ordinary life or hidden theological debt. | Lorkhan pressure is interpretable, rejected ordinary surfaces stay silent, and daily Auri-El life remains net-positive. |
| Khajiit | The moons and road shape belonging without becoming a calendar chore. | Lunar substrate, road homes, silent focus, caravan/community recognition. | Moon phases and road homes can become scheduling tax. | Moon phase acts as wonder and amplifier, not required homework; road homes feel rooted by movement. |
| Bosmer | Path identity interprets Green Pact burden, story, exchange, and outlaw luck. | Old Contract, Living Story, Exchange, Bandit Road, shared Pact memory. | Old Contract and hunter proof can dominate the experience. | Non-hunter paths produce equal emotional payoff and proof hooks. |
| Redguard | Yokudan sect, death duty, and honor shape the road through Skyrim. | Far Shores token, Tu'whacca death practice, Crown/Forebear/Ash'abah sect posture. | Undead-clearing and martial hooks can flatten sect nuance. | Crown, Forebear, and Ash'abah each have visible social, travel, duty, and combat texture. |
| Orc | Malacath devotion is dignity under pressure across chosen life modes. | Stronghold belonging, City private fidelity, Legion/Exile service, quality labor. | Stronghold and smithing can make City/Legion feel like failed versions. | City and Legion/Exile receive dignity, service, and community proof beside Stronghold. |
| Argonian | Hist memory, chosen people, and Void distance define exile identity. | Hist posture, bed of choice, water/reflection, People layer, threshold Sithis. | Sithis and Dark Brotherhood hooks can outshine ordinary Hist/People life. | Non-assassin Hist/People loops are visible, maintainable, and emotionally rewarding. |

## Required Output Per Race Pass

Each race-specific audit pass should end with this block:

```text
Race:
Budget verdict: OK / Watch / Thin / Overstack Risk / Incomplete
Keep:
Change:
Needs custom content:
Needs verifier/proof:
Post-1.0:
Reward ceiling:
Reward floor:
Next implementation-safe slice:
```

## Focused Pass: Altmer (2026-05-30)

```text
Race: Altmer
Budget verdict: Watch
Keep:
- Coherence, rupture, and orthodoxy are the reward axis. Altmer should not be balanced by simply adding more generic blessings.
- Auri-El stays the always-present foundation; a secondary focus can become loud, but not louder than the core Auri-El/coherence frame.
- `ThalmorAlignment` remains mostly pressure, access, interpretation, and recognition. It should not become a separate steady boon engine.
- Lorkhan pressure stays real, but only on explicit authored signals the player can understand.
Change:
- Do not solve thin social or low-violence support by adding generic mercy rewards. Frame support as restraint, protection of lineage, study, lawful defense, institutional duty, or coherent crisis resolution.
- Contextual favor families are now defined; runtime authoring must preserve their recovery/coherence purpose rather than turning them into generic power rewards.
- Rejected surfaces need to be explicit: ordinary existence in Skyrim, ordinary friendships, travel, and post-first-crisis Dragonborn identity should not create hidden piety debt.
Needs custom content:
- First-time Altmer interpretation notifications for non-obvious Lorkhan-adjacent events.
- Crisis-state and resolution readouts for `Dissonant`, `Questioning`, `Reasserting`, and `ScarredResolved`.
- Runtime placement/proof for the three wired curse/exile messages: vampire entry, cured scar recognition, and werewolf hard halt.
- Contextual favor content for scholarship, heterodox self-cultivation, record keeping, protective institutional duty, and the remaining focused families after the wired dawn steadiness and orthodox-cost families.
Needs verifier/proof:
- `PDV_State_AltmerCrisis` record readback, state-track wiring, wired favor record readback, wired curse-message readback, and source-path assertions.
- `ThalmorAlignment` gate coverage for Trinimac access and alignment-shaped reward modifiers.
- Lorkhan penalties only fire from tagged sources, with one-time/day/long-cooldown behavior by tier.
- Positive income from dawn, study, magic milestones, and coherent acts trends higher than ordinary pressure.
Post-1.0:
- Exiled Altmer vampire flavor beyond the entry/cure/werewolf-halt surfaces can expand after launch. The core launch requirement is that cursed Altmer is clearly terminal or exile-limited, not fully restored orthodoxy.
Reward ceiling:
- Auri-El foundation plus one secondary focus plus one active contextual favor family. Orthodoxy/alignment may modify or unlock, but should not add a third steady boon stack.
Reward floor:
- Basic dawn practice, study, magic milestones, and coherent behavior must keep a non-edge Altmer player net-positive without needing perfect play.
Next implementation-safe slice:
- Route proof is closed for the four wired trigger proof ACTIs. Move Lorkhan tag routing, one-active-favor behavior, Exiled vampire cap, rejected-surface assertions, survey/status feel, final placement, and first crisis playfeel into pre-beta gameplay scaling before external testing.
```

## Focused Pass: Argonian (2026-05-30)

```text
Race: Argonian
Budget verdict: Thin
Keep:
- Hist remains primary, People remains the practical exile buffer, and Void/Sithis remains tertiary. These are not three equal tracks.
- Bed of choice stays gentle: three qualifying sleeps in 30 in-game days, with missed cadence removing a bonus and applying light People decay rather than harsh punishment.
- Sithis activation stays high-threshold. Joining the Dark Brotherhood is one major signal, not full Void activation.
- Curse posture stays explicit: vampire is a deep grief state, werewolf is strain but recoverable.
Change:
- Do not add more Void/Sithis reward depth until Hist and People have enough visible reward wealth.
- Treat water proximity as maintenance and refuge, not a universal stat faucet. The stronger payoff should be environmental safety and clarity where the Hist can almost reach.
- People rewards need more than hidden piety. Windhelm Assemblage, Riften Docks, named Argonian aid, and chosen-family cadence should produce visible recognition or status texture.
Needs custom content:
- Hist sap meditation item/power is effectively 1.0 support, not optional flavor, because Skyrim has no real Hist infrastructure.
- Arkay priest reactions for Argonian death rites are essential custom content; otherwise death/Histsoul theology remains hidden counter math.
- Community recognition lines or message surfaces for Windhelm, Riften, and bed-of-choice maintenance.
Needs verifier/proof:
- `PDV_Substrate_ArgonianHist` presence and `PDV.Substrate.ArgonianHist.*` key contract.
- `PDV_State_ArgonianHistPosture` enum values: Normal, Distant, Strained, Silenced, Corrupted.
- Dawn Hist decay: only after three days without valid maintenance, `-1` per dawn, non-curse floor `20`.
- Bed-of-choice cadence: one active location, three qualifying sleeps in a rolling 30-day window, light People decay only on missed cadence.
- Sithis signal counter: full Void scoring only after at least three significant signals, preferably across separate quest beats/days.
Post-1.0:
- Richer Argonian NPC dialogue and additional meditation locations can expand after the base Hist/People loop proves playable.
- More nuanced Daedric foreign-contact copy can wait until the Prince content pass, as long as Molag Bal/Hircine curse pressure is covered.
Reward ceiling:
- Hist substrate plus one strongest active support emphasis: People/community or Void/Sithis. Void can stabilize, but it must not replace Hist or become the best generic stealth/combat path.
Reward floor:
- A normal non-assassin Argonian should be able to maintain identity through water/rest/reflection, bed of choice, and community aid without needing Dark Brotherhood content.
Next implementation-safe slice:
- Build the Argonian Hist/People backlog before Void expansion: Hist sap meditation, water/rest/reflection proof surfaces, bed-of-choice proof, Windhelm/Riften/community recognition, Arkay death-rite reactions, and curse-posture readback.
```

## Focused Pass: Orc (2026-05-30)

```text
Race: Orc
Budget verdict: Watch
Keep:
- Malacath is the one religious spine. Orc depth comes from life-mode expression, not side gods or deity shopping.
- Stronghold keeps the highest ceiling because it has the full code infrastructure: forge, shrine, chief, shaman, Blood-Kin, and community.
- City and Legion/Exile have lower ceilings but should still feel like complete devotional lives, not failed Stronghold playthroughs.
- Exactly one active life-mode lane should modify scoring and favor eligibility at a time.
Change:
- Do not let the first runtime slice become Stronghold plus smithing only. City and Legion/Exile need deliberate dynamic rewards before Orc is called balanced.
- Forge rewards must require quality, value, context, or commission. Raw crafting count should never become the Orc piety loop.
- Legion/Exile service must require pressure-bearing completion. Faction membership is eligibility/context, not a reward trigger.
Needs custom content:
- Self-made community support through `PDV_SacredPlace` or faction-favor proxies for City and Legion/Exile.
- Curated dignity-under-pressure and discipline-without-self-erasure moments; no ambient insult parser.
- Status/survey text that distinguishes Stronghold belonging, City private fidelity, and Legion/Exile burden.
Needs verifier/proof:
- `PDV_State_OrcLifeMode` and `PDV_GLO_State_OrcLifeMode` with enum values `City = 0`, `Stronghold = 1`, `LegionExile = 2`.
- StorageUtil key contract for intent, last switch, lock-in, Stronghold eligibility, and Legion/Exile eligibility.
- Mode switch gates: Blood-Kin / pro-stronghold crisis for Stronghold, completed pressure-bearing service for Legion/Exile, City as fallback.
- One active scoring/favor lane at a time, with a three-day soft-switch lockout after mode change.
- Rejected-hook proof for raw craft count, generic faction membership, ambient disrespect, ordinary travel, and generic oath-breaking without a concrete quest surface.
Post-1.0:
- Richer NPC disposition tracking for self-made community can replace faction-favor proxies if the proxy version proves too thin.
- Trinimac can remain rare ideological pressure, not a normal Orc devotional lane.
Reward ceiling:
- Stronghold may have the most stable rewards. City and Legion/Exile may have sharper situational moments, but not a second persistent substrate.
Reward floor:
- A City or Legion/Exile Orc should have reliable dignity, service, quality labor, and self-made community payoff without needing Blood-Kin.
Next implementation-safe slice:
- Build the Orc life-mode state and City/Legion parity backlog: state enum/readback, mode gates, quality forge filters, self-made community, service milestones, dignity moments, and rejected-hook tests.
```

## Focused Pass: Redguard (2026-05-30)

```text
Race: Redguard
Budget verdict: Watch
Keep:
- Sect is the organizing layer: Crown, Forebear, and Ash'abah are different broad-worship lanes, not flavor labels on one Yokudan path.
- Ancestor reverence stays light and interpretive. It colors death, tombs, legacy, and Tu'whacca without becoming a full second substrate.
- Tu'whacca must remain Yokudan. Arkay can be fallback death infrastructure, not the god being worshipped.
- HoonDing stays rare, dramatic, and tied to genuine make-way moments.
Change:
- Do not let undead-clearing become the whole Redguard economy. Crown form, Forebear road/contract, and Ash'abah impurity burden need comparable felt value.
- Do not reward generic combat as Leki/HoonDing. Martial rewards require conduct, context, or impossible-odds proof.
- Ash'abah stigma needs visible cost/recognition, even if 1.0 only carries it through light authored reactions and status text.
Needs custom content:
- Portable Far Shores token and private/home bonus copied from the Dunmer portable/private shrine pattern.
- Light Ash'abah stigma and Redguard recognition dialogue, especially Hall of the Dead / tombkeeper / Alik'r-facing topics.
- Survey/status readouts that keep Yokudan names primary even when Skyrim institutions are used as proxies.
Needs verifier/proof:
- `PDV_State_RedguardSect` with enum values `Crown = 0`, `Forebear = 1`, `AshAbah = 2`, fallback `Forebear`.
- Sect switching gates: Crown/Forebear require two sect-coded signal days in seven; Ash'abah requires major death, undead, tomb, funerary, or impurity burden.
- Far Shores token activation, private/home bonus, and Arkay fallback copy that says Tu'whacca, not Arkay.
- HoonDing weekly cap and curated major milestone/named-boss proof; combat-odds trigger only if proof-tested.
- Rejected-hook proof for generic undead spam, generic gold-making, fast travel, generic combat, and broad social-stigma simulation.
Post-1.0:
- Fuller Ash'abah social stigma and Redguard diaspora NPC content can expand after the core sect/favor loop proves balanced.
- Combat-odds HoonDing may stay post-1.0 if curated milestones already carry the experience safely.
Reward ceiling:
- Broad sect worship reaches Faithful. Devoted requires focused primary commitment. Ancestor reverence and Far Shores token should support, not create a third always-on boon family.
Reward floor:
- A non-Ash'abah Redguard should still get satisfying Crown or Forebear play through form, road, contract, martial conduct, and sect-specific recognition without farming undead.
Next implementation-safe slice:
- Build the Redguard sect backlog: state/readback, Far Shores token, sect switching proof, Crown/Forebear/Ash'abah contextual favor hooks, HoonDing cap, Hall/death-duty recognition, and rejected-hook tests.
```

## Focused Pass: Bosmer (2026-05-30)

```text
Race: Bosmer
Budget verdict: Watch
Keep:
- Bosmer remains path-divergent, not race-package-plus-patron. The setup path changes what the game watches for.
- Old Contract may keep the highest ceiling because it carries the hardest Green Pact burden.
- Living Story is not failed orthodoxy; it is diaspora Y'ffre through memory, community, and secondary gods.
- Exchange and Bandit Road are real Bosmer theologies, not generic merchant or thief paths.
Change:
- Do not let Old Contract runtime proof become a design excuse to underbuild Living Story, Exchange, and Bandit Road.
- The formal Bosmer favor proof table is now source/record/proof-placement wired; next pressure is runtime feel, not more scaffolding.
- Keep shared Green Pact memory as modest positive weighting outside Old Contract, not a hidden background compliance ledger.
Needs custom content:
- Green Pact owned tag layer for plant food, plant potions, and relevant wood/lumber surfaces before item-level feedback ships.
- Per-path recognition/survey/favor surfacing for Living Story, Exchange, and Bandit Road, not only forced reckoning drama.
- Kynareth-as-Y'ffre proxy recognition and Bosmer elder/story dialogue where cheap.
Needs verifier/proof:
- Preserve existing Phase 9 proof expectations for setup, path offers/switching, Old Contract re-entry, forced reckoning, recommit/renounce, and save/load.
- `PDV_State_BosmerPath` enum values: OldContract, LivingStory, Exchange, BanditRoad; fallback LivingStory.
- Old Contract separation from `PactBound`, `GreenPactCompliance`, and `LapsedFromPact`.
- Destination-gated switching: Living Story one strong signal; Exchange/BanditRoad two signal days in seven; Old Contract three Pact-positive days and one re-entry cycle.
- Phase 20 proof routes `100-107` for Old Contract proper hunt/forest kept, Living Story community/nature proof, Exchange debt/redress, and Bandit Road road-life/reversal.
- Rejected-hook proof for generic theft, generic killing, generic commerce, generic plant avoidance outside tagged surfaces, and passive road travel.
Post-1.0:
- More Bosmer-specific NPC/story dialogue can deepen Living Story after launch.
- Per-item Green Pact feedback can wait until the PDV-owned tag layer is ready; do not fake it with broad item assumptions.
Reward ceiling:
- Old Contract can be strongest but must be narrow and burdensome. Other paths should have fewer hard costs but comparable felt richness through recognition, privileges, and distinctive momentary favors.
Reward floor:
- A non-hunter Bosmer should have a satisfying path through community preservation, debt settlement, road survival, pariah solidarity, and secondary gods without being pushed back into Old Contract.
Next implementation-safe slice:
- Run placement readback, then prove the favor variants and rejected hooks before any Green Pact tag-layer expansion.
```

## Focused Pass: Khajiit (2026-05-30)

```text
Race: Khajiit
Budget verdict: Watch
Keep:
- Khajiit remains the no-offer exception. Focused emphasis emerges silently from behavior and should not use the shared active-primary patron state.
- The lunar substrate is cosmological and always active; it is not a chore meter that proves whether the player believes hard enough.
- Moon phases amplify and flavor activity. Full-cycle consistency carries substrate strength.
- Balanced broad lunar worship is complete and valid, not a failure to choose a god.
Change:
- Do not make moon phase timing mandatory for ordinary progression. Players who ignore phase optimization should still receive full base scoring.
- Road homes must require a real 2-3 point circuit; repeating one convenient camp, bed, or outdoor sleep should not count.
- Baan Dar, Rajhin, and Alkosh need sharp distinctive rewards so Khenarthi/Azurah do not become the only attractive focused emphases.
Needs custom content:
- Moon/status readouts that make current posture and emphasis legible without creating schedule pressure.
- Caravan/community recognition surfaces for Ri'saad, Ma'dran, Ahkari, Khaara, and threatened Khajiit where available.
- Curated Rajhin/Baan Dar differentiation copy: survival reversal versus elegant legend-making.
Needs verifier/proof:
- `PDV_Substrate_KhajiitLunar` and `PDV.Substrate.KhajiitLunar.*` key contract.
- `PDV_GLO_KhajiitFocusedEmphasis` global mirror values: None, Khenarthi, Azurah, BaanDar, Rajhin, Alkosh.
- Focus threshold: at least `50` persistent piety and a `15` piety lead over the next Khajiit deity, evaluated at dawn.
- Moon source fallback: real Masser/Secunda when proven, abstract 28-day fallback if brittle.
- Road-home circuit proof: 2-3 anchors, cycling validation, no credit for repeating one location.
- `PDV_State_KhajiitLunarPosture` enum values: Normal, Strained, Corrupted, ShadowDrift; ordinary night travel/stealth/moon observance must not set ShadowDrift.
Post-1.0:
- More caravan dialogue and moon-cycle flavor can deepen the system after base cadence proves non-chore-like.
- Moon sugar should stay curated/ritual-only unless a reliable context exists; no general moon-sugar piety loop.
Reward ceiling:
- Strong lunar substrate plus one focused emphasis plus the global one-active contextual favor cap. Phase bonuses should be small and never stack into a third loud steady package.
Reward floor:
- A Khajiit who lives broadly on road, sky, and community should remain viable at Faithful without forcing a focus or tracking every phase.
Next implementation-safe slice:
- Build the Khajiit cadence backlog: focused-emphasis readback, moon/fallback source, road-home circuit, caravan/community recognition, Baan Dar/Rajhin split, Alkosh rare hooks, ShadowDrift boundary, and rejected-hook tests.
```

## Focused Pass: Breton (2026-05-30)

```text
Race: Breton
Budget verdict: Overstack Risk
Keep:
- Tradition is the spine: Knight's Road, Hidden Art, or Green Way. Gods sit inside the chosen tradition.
- The three reputation/standing tracks are meaningful for all Bretons, but should not all become simultaneous reward engines.
- Hidden Art can be strong only because exposure, rupture, and Vigilant/social pressure are the price.
- Green Way werewolf handling stays a real fork, not a free hybrid with Hircine.
Change:
- Do not implement a flat Breton pantheon or generic broad-worship lane.
- Do not let KnightlyVowIntegrity, WitchcraftExposure, and DruidicStanding all pay positive rewards at once for the same character.
- Keep Vigilant pressure as extension scope unless the encounter pattern proves cheap; exposure bands carry the 1.0 pressure feel.
Needs custom content:
- Tradition setup and survey/status text that makes the chosen spine legible.
- Druidic Trial confrontation for Green Way werewolf fork.
- Band-crossing messages for vow integrity, exposure, and druidic standing.
Needs verifier/proof:
- `PDV_State_BretonTradition` enum values: KnightsRoad, HiddenArt, GreenWay.
- `KnightlyVowIntegrity`, `WitchcraftExposure`, `DruidicStanding`, and `PDV_State_BretonDruidicFork` band/state readback.
- Normal tradition switching blocked in 1.0 except authored forks.
- Rejected-hook proof for ordinary magic, College membership, private curiosity, generic shrine visits, generic tavern excess, and unproven Vigilant hunter assumptions.
Post-1.0:
- Bespoke per-deity focus emergence copy inside traditions.
- Full Vigilant pressure encounter chain if the pattern proves cheap and low-density.
Reward ceiling:
- One tradition spine plus one focused patron within it. Cross-track pressure can modify or penalize, but should not add extra always-on boon families.
Reward floor:
- Each tradition needs a complete play loop: Knight's Road protection/mercy, Hidden Art occult cover or declaration, Green Way rites/standing stones/outdoor covenant.
Next implementation-safe slice:
- Build the Breton stack-control backlog: tradition state, three track readbacks, DruidicFork, per-tradition favor rows, curse split, and rejected-hook tests.
```

## Focused Pass: Dunmer (2026-05-30)

```text
Race: Dunmer
Budget verdict: Overstack Risk
Keep:
- Dunmer remains layered, not path-based: ancestor ash-prayer is always active, Good Daedra deepen it, one Reclamation focus adds weight on top.
- Do not implement `PDV_State_DunmerPath`; native focus uses shared patron state.
- Ancestor substrate has no passive decay. Skyrim lacks proper tombs and House shrines, and that absence should not punish the player.
- Daedric deviations use the global Daedric system and present as deviation, trial, pact, taboo, curse pressure, or foreign bargain.
Change:
- Keep shared ancestor/Reclamation favors Quiet or Noted by default. Marked moments should usually wait for primary focus, major Good Daedra quests, vampire cure/restoration, or major diaspora burden.
- Do not let all three Good Daedra plus ancestor substrate plus deviation paths pay as equal foreground packages.
- Keep Tribunal memory flavor-only, not a controllable blessing machine.
Needs custom content:
- Portable ancestor shrine ceremony and home bonus surfacing.
- Dunmer solidarity/Grey Quarter recognition where cheap.
- Curse restoration/scar copy for ancestor silence and return.
Needs verifier/proof:
- `PDV_Substrate_DunmerAncestor` and `PDV.Substrate.DunmerAncestor.*` key contract.
- `PDV_State_DunmerAncestorPosture` enum values: Normal, Strained, Silent, RestoredScarred.
- Shared patron-state focus for Azura, Boethiah, and Mephala; no Dunmer path enum.
- Boundaries rejecting generic cruelty/violence for Boethiah, generic crime for Mephala, and generic twilight/magic activity for Azura.
Post-1.0:
- More House/diaspora dialogue and Tribunal memory texture can deepen without becoming new paths.
- Non-Reclamation deviations can expand after the normal Reclamation stack is tuned.
Reward ceiling:
- Ancestor substrate plus one Reclamation foreground focus. Other Good Daedra may remain background at reduced weight, but should not create three simultaneous focus packages.
Reward floor:
- A broad Dunmer should feel complete through ash-prayer, portable shrine, home bonus, diaspora solidarity, and shared Reclamations even before choosing a primary focus.
Next implementation-safe slice:
- Build the Dunmer stack-control backlog: ancestor substrate readback, posture states, portable shrine/home bonus, Reclamation focus boundaries, deviation boundary tests, and marked-moment caps.
```

## Focused Pass: Imperial (2026-05-30)

```text
Race: Imperial
Budget verdict: Watch
Keep:
- Imperial broad worship is civic and institutional, not Nord mythic breadth.
- `ConcordatStanding` is political/theological pressure, not a second boon package.
- Talos favor comes from faithful defiance only. Compliance may alter standing and civic access, never Talos favor.
- Concordat Enforcer corrodes Arkay/Stendarr until mercy or death-rite repair signals exist.
Change:
- Do not reward generic faction membership, generic temple attendance, ordinary bounty payment, or generic anti-Thalmor violence.
- Public service, law, mercy, trade, and burial must be concrete acts with curated hooks or value thresholds.
- Keep compliance/conscience consequences visible through status and offer eligibility, not raw stat punishment.
Needs custom content:
- Survey/status lines for Concordat bands and public/private Talos tension.
- Repair feedback for Enforcer walk-back through mercy, prisoner protection, burial restoration, or anti-necromancer duty.
- Civic recognition surfaces where temples, courts, Legion, or Halls of the Dead can acknowledge a real act.
Needs verifier/proof:
- `PDV_RepTrack_ConcordatStanding` band readback including Uncommitted, Private Defiant, Open Defiant, Public Compliant, and Concordat Enforcer.
- Talos offer filters by standing; costly-defiance rupture moves compliant characters at least Private Defiant on acceptance.
- Extreme walk-back requires sustained counter-behavior and story-caliber reset.
- Rejected-hook proof for raw faction state, cruelty as order, generic anti-Thalmor violence, ordinary pay-bounty, and generic temple attendance.
Post-1.0:
- Broader civic dialogue can expand after the initial civic-act hook set proves non-abstract.
Reward ceiling:
- Broad Nine Divines plus one focused primary. ConcordatStanding modifies access, offer priority, and pressure, but should not be a parallel always-on buff track.
Reward floor:
- Non-combat Imperial play must feel real through mercy, burial, public service, honest work, lawful repair, and private/public Talos choices.
Next implementation-safe slice:
- Build the Imperial civic-proof backlog: Concordat readback, Talos filters, civic act whitelists, repair signals, concrete non-combat hooks, and rejected-hook tests.
```

## Focused Pass: Nord (2026-05-30)

```text
Race: Nord
Budget verdict: Watch
Keep:
- Nord broad worship should feel culturally complete at Faithful, not like failed patron commitment.
- Focused patron devotion should still be stronger, sharper, and narrower than broad Old Ways or broad Nine Divines.
- Pantheon baseline and shared patron state stay separate; do not implement Broad/Primary as Nord baseline states.
- Hircine remains the first full Nord Daedric path, not an invitation to a general Prince menu.
Change:
- Do not let dense Nord hooks make the race the best generic package.
- Broad blended favors need softer caps and should not inherit every individual patron boon.
- Talos pressure must require costly faithful signals, not generic Thalmor violence or ordinary Civil War preference.
Needs custom content:
- Broad-lane status/survey text for Old Ways versus Nine Divines.
- Focused contrast content for Kyne and later patron lanes.
- Privilege dialogue surfaces like Greybeard/Kyne and Nord status topics should remain rare and earned.
Needs verifier/proof:
- `PDV_State_NordPantheonBaseline` enum values: OldWays and NineDivines.
- Dawn-only offer gate: piety threshold, two signal days in seven, pantheon eligibility, cooldown, one offer max.
- Broad/focused suppression rules: broad worship below focused patron rewards, accepted patron suppresses competing offers.
- Rejected-hook proof for generic anti-Thalmor violence, ordinary travel, raw crafting, faction membership alone, and repeat tomb/kill farming.
Post-1.0:
- Additional focused patron privilege/dialogue can expand after broad/focused reward ceilings are playtested.
- Pantheon-level substrate should only be promoted if broad-combo mechanics prove too stateful for the light model.
Reward ceiling:
- Broad blended favors at Faithful stay softer than Devoted patron benefits. Kyne/Talos/Hircine/Nord broad layers must not stack into a universal best build.
Reward floor:
- A broad Nord should still feel noticed through weather, honor, hearth, death, Talos pressure, and hold identity without needing to accept a patron.
Next implementation-safe slice:
- Build the Nord ceiling backlog: broad/focused cap checks, pantheon baseline readback, offer-gate proof, Talos-cost filters, Kyne contrast, Hircine interaction, and rejected-hook tests.
```

## Immediate Work Queue

1. **Altmer implementation costing:** follow `PDV_Phase20AltmerImplementationCosting.manifest.json` for the record-wired `PDV_State_AltmerCrisis`, the first two wired favor families, four wired ACTI trigger proof surfaces, proof-placement readback, Exiled vampire cap, rejected-surface verifier assertions, and first crisis immersion proof.
2. **Argonian Hist/People backlog:** use `PDV_Phase20ArgonianImplementationCosting.manifest.json` to keep Hist sap, water/rest maintenance, bed-of-choice proof, community recognition, Arkay death-rite reactions, and curse posture ahead of Void expansion.
3. **Orc City/Legion parity backlog:** use `PDV_Phase20OrcImplementationCosting.manifest.json` for life-mode state, mode gates, quality forge filters, self-made community, service milestones, dignity moments, and rejected hooks.
4. **Redguard sect backlog:** use `PDV_Phase20RedguardImplementationCosting.manifest.json` for sect state/readback, Far Shores token, Crown/Forebear/Ash'abah hooks, HoonDing cap, Ash'abah stigma, and rejected hooks.
5. **Bosmer/Khajiit parity backlog:** use `PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json` and `PDV_Phase20KhajiitImplementationCosting.manifest.json` for formal Bosmer favor tables plus Khajiit cadence/emphasis proof before adding more runtime reward depth.
6. **Stack-control gates:** Breton and Dunmer overstack caps; Imperial and Nord concrete-act and broad/focused ceiling gates.
