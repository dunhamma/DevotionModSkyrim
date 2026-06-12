# PDV Race Effect Review Ledger

**Created:** 2026-05-31
**Status:** Reward contract baseline implemented; runtime/manual review gate remains open

## Purpose

This ledger keeps reward effects from drifting beyond their reviewed floor,
ceiling, and stack budget. The 2026-06-04 all-race reward contract implemented
first-tier `SPEL`/`MGEF` records and manager grant ownership for all ten races,
including the earlier `PDV_Bless_Khajiit_Lunar_T1` CAT-6 pilot. That automated
record/readback/wiring proof does not approve runtime display, save/load,
balance feel, or future magnitude expansion.

Before changing reward magnitudes, adding higher tiers, or promoting Daedric
reward interactions, each race needs a holistic effect review across theme,
gameplay role, magnitude, conditions, stacking, grant/removal behavior,
Survey/status explanation, anti-farm posture, curse interaction, and Daedric
interaction.

## Holistic Review Hook

Use this branch point in the content authoring tree when you want to continue
without widening reward policy by accident:

```text
Reward tuning or tier expansion remains blocked until each race row in this
ledger names the floor effect family, ceiling effect family, magnitude range,
cadence, grant/removal owner, stack cap, Survey/status copy, rejected generic
hooks, curse/Daedric interaction, and manual feel note.
```

Treat the all-race first-tier contract as the current baseline only. It proves
records and manager wiring, not that every race reward is manually felt,
balanced, or ready for higher-tier expansion.

## Review Rules

- Do not broaden CAT-6 or reward tiers beyond the current all-race T1 contract
  until the affected race has a completed row in this ledger and runtime/manual
  proof in the manual evidence ledger.
- Treat all magnitudes as provisional until the race row is reviewed.
- Conditions must match player-facing text. If the effect is night-only, the
  copy must say night-only.
- Every steady reward needs a removal or suppression story before it can be
  granted by manager logic.
- Each race should have a floor effect that supports ordinary play and a
  ceiling effect that cannot stack into a third loud reward package.
- Curse and Daedric modifiers must be reviewed with the race effect set, not
  bolted on afterward.
- Survey/MCM copy must explain the active state in fiction-facing terms without
  turning effect mechanics into debug counters.

## Variety Tranche Gate (2026-06-12)

The five race variety tranches in
`references/authoring/PDV_RaceVarietyTranche_Roadmap.md` are design-locked
into their race sheets (Bosmer, Orc, Altmer, Redguard, Khajiit addendum).
That lock covers shapes, gates, caps, and fade rules only. Before any
tranche record authoring:

- All tranche magnitudes are provisional and must pass this ledger's race
  row review like any other effect change.
- Tranche effects add no new always-on boon families: pilgrimage pulses are
  one-shot, signatures are once/day 10-minute-class pulses, and rite effects
  are one-active with dawn fade/restore. Any drift from those shapes is a
  budget change requiring re-review.
- Rite effects (Bosmer Naming, Orc Trial of Iron, Altmer Disciplines of
  Return, Redguard Remembering of Names) follow the Hist Adaptations
  contract: one active at a time, swap is clear-before-add, "Not yet" does
  not spend the cooldown, fade at dawn on coherence break, restore at dawn
  on recovery.
- Tranche effect families to fold into each race's row review: Bosmer
  (`A Tale Carried`, `Scales at Rest`, `Baan Dar Opens the Gap`, Songs
  pulses, four Naming selves), Orc (`Hearth-Held`, `The Code Holds`, Four
  Holds pulses, four Trial disciplines), Altmer (`Ordered Mind`,
  `Syrabane's Hand`, Chantry pulses, four Disciplines), Redguard
  (sword-tending Leki pulse, `Leki's Measure`, `Tava's Departure`,
  `The Unclean Hour`, Halls pulses, four Remembering observances), Khajiit
  (`Rajhin's Borrowed Moment`, `Baan Dar's Improvisation`, `Alkosh's Long
  Breath`).

## Khajiit T1 Baseline

`PDV_Bless_Khajiit_Lunar_T1` began as the CAT-6 pilot and is now governed by
the all-race reward contract.

Current pilot mechanics:

- Source row: `PDV_Bless_Khajiit_Lunar_T1`.
- Spell: `PDV_Bless_Khajiit_Lunar_T1`.
- Effects:
  - `PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen`: `StaminaRateMult +5`.
  - `PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist`: `ResistDisease +10`.
- Condition: both effects are active from 7PM through 7AM.
- Grant state: owned by `PDV_Phase20_RewardRecordContracts.json` and
  `tools/pdv-phase20-reward-author`.
- Proof state: record/readback/text/wiring proof only, not Active Effects
  runtime proof, save/load proof, Survey clarity proof, or balance proof.

## Race Review Table

| Race | Status | First Review Focus | Effect Questions To Lock |
|------|--------|--------------------|--------------------------|
| Altmer | Pending | Auri-El/Magnus scholar floor, crisis/recovery ceiling | What is the quiet positive floor before crisis pressure? Which favors are one-active only? How do Exiled vampire and werewolf halt suppress rewards? |
| Khajiit | Pilot-provisional | Lunar floor, road-home cadence, focus effects | Is night-only stamina/disease the right Tier 1 floor? Does the effect need road/moon/focus variants? How does ShadowDrift avoid becoming a free stealth stack? |
| Argonian | Pending | Hist/People floor before Void depth | What supports water/rest/community without swim or sleep farming? Which Void effects are pressure/stabilization rather than replacement theology? |
| Orc | Pending | Stronghold/city/Legion/exile labor dignity | Which effects reward quality forge/service without raw crafting or combat loops? How does exile remain playable without free Malacath stacking? |
| Redguard | Pending | Crown/Forebear/Ash'abah/Far Shores posture | Which effects respect undead/death-duty hooks without generic undead farming? Where does HoonDing cap escalation stop? |
| Bosmer | Pending | Old Contract, Living Story, Exchange, Bandit Road parity | Which path effects are distinct without four simultaneous reward packages? How do Z'en/Baan Dar effects avoid generic kindness/trade/theft faucets? |
| Breton | Audit-only pending | Covenant/Divines/Magnus/Witch edge stack | Which existing layers are already loud enough? What should remain audit-only until ceiling risk is understood? |
| Dunmer | Audit-only pending | Ancestor/Reclamation/House/Daedric pressure stack | How do ancestor substrate and Reclamation effects avoid overstacking with Daedric pressure? |
| Imperial | Audit-only pending | Civic Divines, Akatosh/Zenithar, broad worship | What prevents broad-worship reward density from becoming universal best-in-slot? |
| Nord | Audit-only pending | Fully felt control race and over-trigger audit | Which Kyne/Talos/Hircine/neglect layers are already at ceiling, and which generic hooks must stay silent? |

The broad / floor-ceiling layer of the completion bar is now answered for all
ten races in the "Completed Race Rows" section below (folded from the
amazing-goodall branch). The table Status above still tracks the **full**
holistic effect review, which may carry deeper per-effect work (e.g. Khajiit
focus variants, Argonian Void effects) beyond the broad layer.

## Completion Bar Per Race

A race row is complete when it names:

- Approved floor effect family.
- Approved ceiling effect family.
- Magnitude range.
- Conditions and cadence.
- Grant and removal/suppression owner.
- Stack cap.
- Survey/status explanation.
- Rejected generic hooks.
- Curse/Daedric interaction.
- Manual feel note still needed before external beta.

## Completed Race Rows (broad / floor-ceiling effect review)

These rows complete the per-race completion bar above for the broad / baseline
reward layer (floor and ceiling effect families and the surrounding contract).
Magnitudes are provisional per the Review Rules and are tuning work. Grounded in
`PDV_RaceRewardBudgetLedger.md` focused passes and the architecture broad-lane
rule: real broad-worship lanes for Nord, Imperial, and Redguard; layered/substrate
baselines for Dunmer, Khajiit, and Argonian; explicit "no generic broad lane"
baseline equivalents for Bosmer (path), Orc (life mode), Breton (tradition), and
Altmer (Auri-El coherence). Magnitude convention: broad floor minimal, broad
ceiling caps at Faithful (Tier 2) and roughly 50-70% of the equivalent
focused-patron Devoted value; broad never inherits individual patron boons.

### Nord (broad lane: Old Ways / Nine Divines)
- Floor effect family: light blended hearth/weather/road steadiness reflecting broad Old Ways or Nine Divines practice.
- Ceiling effect family: Faithful-tier blended broad favor (softened combination of pantheon-adjacent effects); strictly below focused Kyne/Talos Devoted boons.
- Magnitude range: Observant approx +3-5%, Faithful broad cap approx +6-10% or a minor resist/regen band; below focused Devoted (provisional).
- Conditions and cadence: dawn-owned steady layer recomputed after broad-worship signals; blended favor refreshed by qualifying broad acts, not per-kill.
- Grant and removal/suppression owner: dawn pass in `PDV__ManagerQuest`; capped/demoted on patron commitment; stripped on vampire rupture.
- Stack cap: one steady broad-blessing family plus at most one active contextual favor (global one-active cap).
- Survey/status explanation: thematic Old Ways vs Nine Divines readout, no piety numbers.
- Rejected generic hooks: generic anti-Thalmor violence, ordinary travel, raw crafting, faction membership alone, repeat tomb/kill farming.
- Curse/Daedric interaction: vampire rupture suppresses broad favors (scar on cure); Hircine is a separate focused Daedric lane, not a broad booster.
- Manual feel note: broad Nord feels culturally complete at Faithful without a patron, yet always quieter than a focused patron; Skyrim notices via weather/hold/hearth, not a stat menu.

### Imperial (broad lane: Nine Divines, civic)
- Floor effect family: civic Nine-Divines steadiness earned from concrete lawful/mercy/burial acts.
- Ceiling effect family: Faithful civic blended favor; below focused primary-god Devoted; Talos excluded from broad (favor only via faithful defiance).
- Magnitude range: small civic-flavored (minor barter/speech/restoration-adjacent or disease/undead protection), Observant to Faithful; below focused (provisional).
- Conditions and cadence: dawn-owned, refreshed by concrete curated civic acts or value thresholds, not attendance.
- Grant and removal/suppression owner: dawn pass; modified (access/priority, not buff) by `ConcordatStanding`; Concordat Enforcer corrodes Arkay/Stendarr until repair signals.
- Stack cap: one steady civic broad-blessing plus one active contextual favor; ConcordatStanding is pressure, not a stacked boon.
- Survey/status explanation: Concordat band plus public/private Talos tension plus broad Nine Divines state, plain language.
- Rejected generic hooks: generic faction membership, generic temple attendance, ordinary bounty payment, generic anti-Thalmor violence.
- Curse/Daedric interaction: vampire collapse suppresses civic broad favor; Talos defiance is a standing/focused lane, never broad.
- Manual feel note: civic religion under public law and private conscience; non-combat civic play must feel as real as combat.

### Redguard (broad lane: sect-shaped - Crown / Forebear / Ash'abah)
- Floor effect family: broad sect worship reaching Faithful plus light ancestor reverence / death-duty coloring.
- Ceiling effect family: Faithful broad sect lane; Devoted requires focused primary commitment; ancestor reverence and Far Shores token support only.
- Magnitude range: sect-lane small-to-moderate, below focused primary Devoted; HoonDing rare and weekly-capped (provisional).
- Conditions and cadence: dawn plus sect-coded signal days (two in seven to switch Crown/Forebear); death-duty event-led; HoonDing weekly cap.
- Grant and removal/suppression owner: `PDV_State_RedguardSect` plus dawn pass; Far Shores token activator; Arkay fallback copy says Tu'whacca.
- Stack cap: one sect broad lane plus light ancestor layer plus one active favor; not a second substrate.
- Survey/status explanation: sect (Crown / Forebear / AshAbah) plus death-duty / Far Shores state, Yokudan names primary.
- Rejected generic hooks: generic undead spam, generic gold-making, fast travel, generic combat, broad social-stigma simulation.
- Curse/Daedric interaction: Ash'abah impurity stigma; vampire restoration through Tu'whacca; Hircine/Molag Bal are curse-access.
- Manual feel note: protect Crown/Forebear/Ash'abah distinction; road, contract, form, and stigma must compete with undead-clearing.

### Dunmer (layered baseline equivalent - no generic broad lane)
- Floor effect family: ancestor ash-prayer substrate (always active, no passive decay) plus portable/private shrine and home bonus and diaspora solidarity.
- Ceiling effect family: ancestor substrate plus shared Reclamations (Quiet/Noted) up to feeling complete pre-focus; below a focused Reclamation foreground.
- Magnitude range: substrate interpretive/utility (small, no decay); shared Reclamations Quiet/Noted; marked moments wait for focus or major Good Daedra quests (provisional).
- Conditions and cadence: substrate continuous (no decay) with ash-prayer/shrine cadence; dawn recompute.
- Grant and removal/suppression owner: `PDV_Substrate_DunmerAncestor` plus dawn pass; focus uses shared patron state (no Dunmer path enum); ancestor-posture handlers.
- Stack cap: ancestor substrate plus one Reclamation foreground; other Good Daedra background at reduced weight; never three focus packages.
- Survey/status explanation: ancestor posture (Normal / Strained / Silent / RestoredScarred) plus shared Reclamations state.
- Rejected generic hooks: generic cruelty/violence (Boethiah), generic crime (Mephala), generic twilight/magic activity (Azura).
- Curse/Daedric interaction: ancestor silence posture; vampire cure/restoration scar; Daedric deviations route through the global system as deviation/pact/taboo.
- Manual feel note: layered, not path-based; broad Dunmer feels complete through ancestors and shrines even before a focus, and Skyrim's missing tombs must not punish.

### Khajiit (lunar baseline - balanced broad worship is valid; Tier 1 reward lives here)
- Floor effect family: lunar substrate, an always-active cosmological layer; balanced broad lunar worship is complete at Faithful, with small per-phase amplification. The approved pilot `PDV_Bless_Khajiit_Lunar_T1` (night-only StaminaRateMult +5 / ResistDisease +10) is one provisional instance of this floor.
- Ceiling effect family: lunar substrate plus one emergent focused emphasis plus the global one-active favor; phase bonuses small and never a third loud package.
- Magnitude range: phase amplification small; substrate strength from full-cycle consistency; below focused emphasis (pilot magnitudes provisional).
- Conditions and cadence: substrate continuous; moon phase amplifies (optional, never mandatory scheduling); road-home circuit cadence; dawn focus evaluation. Pilot effects gated 7PM-7AM.
- Grant and removal/suppression owner: `PDV_Substrate_KhajiitLunar` plus dawn pass; emphasis via `PDV_GLO_KhajiitFocusedEmphasis` (silent, not shared patron state); lunar-posture handlers; Tier 1 reward grant owned by `PDV_Phase20_RewardRecordContracts.json`.
- Stack cap: substrate plus one emphasis plus one active favor.
- Survey/status explanation: lunar posture plus current emphasis, legible without schedule pressure, no piety numbers.
- Rejected generic hooks: repeating one convenient camp/bed (road homes need a 2-3 anchor circuit), generic crime/combat for Baan Dar/Rajhin/Alkosh, ordinary night travel for ShadowDrift.
- Curse/Daedric interaction: lunar posture Strained/Corrupted/ShadowDrift; vampire = Corrupted, lycanthropy = Strained; ShadowDrift only on dominant Nocturnal/shadow behavior.
- Manual feel note: the moons and road shape belonging without a calendar chore; broad lunar life stays viable at Faithful without forcing a focus.

### Bosmer (active-path baseline - no cross-deity broad lane)
- Floor effect family: active-path baseline practice (Old Contract / Living Story / Exchange / Bandit Road) plus shared Pact memory as modest positive weighting.
- Ceiling effect family: within-path deepening; Old Contract highest ceiling but most burdensome; other paths reach comparable felt richness via recognition and momentary favors.
- Magnitude range: path-baseline small; below path-deepened or forced-reckoning payoff (provisional).
- Conditions and cadence: path-state-driven; favor routes `100-107` event-led; Bandit Road reversal carries a seven-day cooldown.
- Grant and removal/suppression owner: `PDV_State_BosmerPath` plus manager favor counters; switching is destination-gated; no generic broad granter.
- Stack cap: one active path plus shared Pact memory weighting plus one active favor.
- Survey/status explanation: active path plus `favor=oc/ls/ex/br` counters plus Pact compliance state.
- Rejected generic hooks: generic theft, generic killing, generic commerce, generic plant avoidance outside tagged surfaces, passive road travel.
- Curse/Daedric interaction: Green Pact burden; Hircine legible via Wild-Hunt adjacency but priced; path switching cost.
- Manual feel note: path identity is the frame; a flat broad lane would erase it, so breadth is interpreted through the chosen path.

### Orc (life-mode baseline - no generic broad lane)
- Floor effect family: Malacath code baseline within the active life mode (Stronghold / City / Legion-Exile): dignity, quality labor, and service as the one religious spine.
- Ceiling effect family: the active life-mode lane; Stronghold highest ceiling; City and Legion/Exile sharper situational moments but no second persistent substrate.
- Magnitude range: life-mode baseline small-to-moderate; forge gated by quality/value/context; below deep commitment (provisional).
- Conditions and cadence: life-mode-state-driven; service requires pressure-bearing completion; three-day soft-switch lockout after a mode change.
- Grant and removal/suppression owner: `PDV_State_OrcLifeMode` plus dawn pass; exactly one active scoring/favor lane at a time.
- Stack cap: one life-mode lane plus light life-mode standing plus one active favor; no second substrate.
- Survey/status explanation: life mode (Stronghold / City / LegionExile) plus standing/dignity text.
- Rejected generic hooks: raw craft count, generic faction membership, ambient disrespect, ordinary travel, generic oath-breaking without a concrete quest surface.
- Curse/Daedric interaction: Malacath is native (not a Daedric-stigma path); code pressure applies; curse states are priced.
- Manual feel note: dignity under pressure across life modes; City and Legion/Exile are complete devotional lives, not failed Strongholds.

### Breton (tradition baseline - no generic broad lane by design)
- Floor effect family: none generic; the baseline is the chosen tradition (Knight's Road / Hidden Art / Green Way) at its entry standing. Do not implement a flat Breton pantheon or broad-worship blend.
- Ceiling effect family: within-tradition focused patron; the three standing tracks modify and pressure but never form a broad blend.
- Magnitude range: not applicable for broad; tradition-baseline magnitudes live in the per-tradition favor tables (provisional there).
- Conditions and cadence: tradition-state and standing-track driven; no dawn broad blend.
- Grant and removal/suppression owner: `PDV_State_BretonTradition` plus the three standing tracks (`WitchcraftExposure`, `KnightlyVowIntegrity`, `DruidicStanding`); no broad granter.
- Stack cap: one tradition spine plus one focused patron; tracks stay pressure/meaning, not stacked boons.
- Survey/status explanation: chosen tradition plus track bands; explicitly no broad-worship readout.
- Rejected generic hooks: ordinary magic, College membership, private curiosity, generic shrine visits, generic tavern excess, and any flat-pantheon broad-worship hook.
- Curse/Daedric interaction: Hidden Art / Hircine fork priced via exposure and rupture; Green Way werewolf is a real fork, not a free hybrid.
- Manual feel note: Breton religion is tradition-first; a generic broad lane would flatten the spine, so it is intentionally absent.

### Altmer (Auri-El coherence baseline - no generic broad lane)
- Floor effect family: Auri-El dawn foundation - basic dawn practice, study, magic milestones, and coherent acts keep a non-edge Altmer net-positive (not a multi-god blend).
- Ceiling effect family: Auri-El foundation plus one secondary focus plus one active coherence favor; orthodoxy/alignment modifies or unlocks but adds no third steady stack.
- Magnitude range: small coherence/steadiness (dawn steadiness favor), Observant to Faithful baseline; below secondary-focus Devoted (provisional).
- Conditions and cadence: dawn-owned coherence foundation; favors event-led on coherent acts.
- Grant and removal/suppression owner: dawn pass; `ThalmorAlignment` modifies access/interpretation; Lorkhan pressure only on tagged signals; curse/exile suppresses the positive lane.
- Stack cap: Auri-El foundation plus one secondary focus plus one active favor; no broad pantheon stack.
- Survey/status explanation: crisis state (Dissonant / Questioning / Reasserting / ScarredResolved) plus coherence/orthodoxy; no broad-worship readout.
- Rejected generic hooks: ordinary existence, ordinary friendships, travel, post-first-crisis Dragonborn identity (no hidden Lorkhan debt); generic spellcasting, raw skill gain, generic kindness.
- Curse/Daedric interaction: vampire terminal/exile-limited; werewolf hard halt; no clean Daedric broad path.
- Manual feel note: coherence, not breadth; daily Auri-El life stays net-positive and a generic broad lane is omitted by design.

## Daedric Price-Axis Retune (2026-06-07)

Daedric `price` spells must impose a **genuine net cost** (unlike Aedra blessings)
and read as a **per-Prince** cost (not a shared tax). Source of truth:
`PRINCE_META[stem].price` in `tools/pdv_generate_daedric_contract.mjs` (single
axis, −3/−5/−8 across Seeker/Devoted/Champion). Invariants now enforced:

- **No price axis may equal any of that Prince's boon axes at any tier** (else
  the price is a strictly-smaller boon — netted positive). Audit the contract
  with: every `prices[].effects[].actorValue` must be disjoint from
  `boons[].effects[].actorValue`.
- Spread price axes (cap ~3 per axis) so the cost feels Prince-specific.

Retune applied (fixes four same-axis overlaps + diversifies):

| Prince | old price | new price | reason |
|---|---|---|---|
| Azura | MagickaRateMult | StaminaRateMult | same-axis fix; vigil of foresight wearies |
| Sheogorath | MagickaRateMult | Restoration | same-axis fix; madness erodes self-restoration |
| Sanguine | StaminaRateMult | MagickaRateMult | same-axis fix; dissipation dulls the mind |
| Clavicus Vile | Speechcraft | MagickaRateMult | same-axis fix; the bargain drains vital spark |
| Vaermina | StaminaRateMult | HealRateMult | corrupted sleep → poor recovery |
| Nocturnal | Speechcraft | Restoration | the Empty Night claims vitality |
| Hircine | Speechcraft | HealRateMult | the hunt's toll; bites the melee build |

Kept (already distinct + real cost): Boethiah/Mephala/Namira = Speechcraft (social
stigma), Malacath = SpeedMult, Dagon = DamageResist, Molag Bal = HealRateMult,
Meridia = Illusion, Hermaeus Mora/Peryite = StaminaRateMult. Price flavor text is
abstract narrative, so no prose change. Post-retune: Speechcraft 6→3,
StaminaRateMult 4→3; no price-axis == boon-axis anywhere. Curse double-fire guard
verified already correct (Hircine `HandleCurseTransition` werewolf-gated; Molag on
its own quest channel). Full audit: `PDV_GameplayAudit_2026-06-07.md`.
