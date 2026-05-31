# PDV Pre-Beta Race Gate Ledger

**Created:** 2026-05-31
**Status:** Internal Phase 20 pre-beta gate ledger
**Owner:** Companion to `PDV_PreBetaRaceAcceptanceRubric.md`, `PDV_PreBetaRaceScalingSpine.md`, and `PDV_Phase20_NoInGameProof_Gates.json`

## Purpose

This ledger records the current acceptance state for every race before external
playfeel testing or stronger reward tuning. A `Fail` verdict here does not mean
the race architecture is wrong. It means the race still lacks one or more
pre-beta evidence items: normal-session proof, rejected-hook proof, Survey/status
clarity, final placement outside QASmoke, stack snapshot, or manual feel notes.

QASmoke route proof remains technical route proof only. This ledger tracks the
player-experience gate.

## Current Baseline

```text
Content verifier: node .\tools\pdv_content_verify.mjs
Latest result: FAIL=0, WARN=0, PASS=1079, INFO=4

Strict Phase 20 gate:
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
Latest result after Altmer row reconciliation: PASS=1982, WARN=1, INFO=28
Latest result after all-race Survey source guard: PASS=2003, WARN=1, INFO=28
Latest result after structured no-in-game gate guard: PASS=2160, WARN=1, INFO=28
Latest result after structured manual-evidence intake guard: PASS=2322, WARN=1, INFO=28
Latest result after CAT-6 Khajiit Tier 1 pilot readback: PASS=2342, WARN=1, INFO=28

Runtime marker list:
node .\tools\pdv_phase20_runtime_check.mjs --list
Status: route markers list for Altmer, Argonian, Orc, Redguard, Khajiit, and Bosmer
```

The remaining verifier warning is the existing unnamed CK-authored INFO record
class in `PlayerDevotion_Framework.esp`.

Structured no-in-game gate:
`references/authoring/PDV_Phase20_NoInGameProof_Gates.json`

## Global Stop Conditions

- No external race playfeel testing until that race records `Pass` or a scoped
  `Conditional` in this ledger.
- No new reward magnitude for P1/P2 lanes until rejected hooks and stack
  ceilings are recorded.
- No broad recognition/dialogue scaling until one non-Nord CK-authored packet
  passes readback and runtime positive/negative proof.
- No broad CAT-6 string promotion until one low-risk non-dialogue source row is
  ratified, promoted, read back, displayed or explicitly accepted as readback
  proof, synced to the handbook, and checked against the holistic race-effect
  review.
- No Daedric runtime promotion wave until stigma row contract, Hircine/Molag Bal
  curse-access template, and Prince promotion order are closed.

## P0 Active Spine

### Altmer

```text
Race: Altmer
Lane type: P0 active spine
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: Auri-El or Magnus scholar managing dawn practice and study.
Edge build: Exiled vampire, werewolf halt, or mortal-world pressure run.
Normal-session route: dawn/study upkeep -> one explicit Lorkhan or crisis beat -> Survey/MCM readout -> recovery/scar check.
Accepted hooks: dragonborn declaration route 51, Lorkhan pressure route 50, dawn steadiness route 52, orthodox costly enforcement route 53.
Rejected hooks: ordinary travel, ordinary friendships, generic spellcasting, generic helping, generic combat, generic College membership, generic anti-Thalmor violence, repeated Dragonborn identity, vampire power route.
Anti-farm result: source has explicit rejected-surface helper and repeat crisis rejection; still needs normal-play rejection proof outside QASmoke.
Survey/status result: source now has Altmer-specific Survey/MCM readout for crisis, Lorkhan pressure, last favor, and curse posture; needs runtime display proof.
Final placement result: QASmoke route proof exists; needs one dawn/study surface and one crisis/pressure surface outside QASmoke.
Reward floor: coherent dawn/study play must trend net-positive before crisis rewards grow.
Reward ceiling: Auri-El foundation plus one secondary focus plus one active contextual favor; ThalmorAlignment modifies access/pressure and is not a third boon engine.
Stack snapshot: Auri-El foundation, secondary focus, active favor, crisis state, pressure count/source, ThalmorAlignment, vampire exile, werewolf halt, scar, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race altmer
Next automatable action: add structured rejected-surface and placement-contract verifier coverage.
Deferred manual proof: wrong-origin rejection, ordinary-life rejection, Survey display, Exiled vampire/werewolf status, and final-world placement.
Blocking follow-up: prove normal-play rejected hooks, Survey display, Exiled vampire/werewolf status, and final placement.
```

### Altmer Content-Lock Reconciliation

The merged race content manifest is canonical. The Altmer costing manifest now
uses current Section 13.13 rows while preserving existing wired proof record and
spell EditorIDs.

Lore cross-review guardrail: `MarriageBeat` should be read as Marriage /
Mortal Continuity, not anti-Mara marriage rejection. It covers household,
lineage, embodied attachment, and continuity inside Lorkhan's mortal world.
Talos/Thalmor remains a lore-valid optional later crisis row, but it is not part
of the current four-row Altmer crisis list.

```text
PDV_Msg_Altmer_LorkhanCrisis_TalosContradiction -> PDV_Msg_Altmer_LorkhanCrisis_MarriageBeat
PDV_Notif_Altmer_FavorNoted_Shared_DawnSteadiness -> PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance
PDV_Msg_Altmer_FavorMarked_Orthodox_CostlyEnforcement -> PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended
Old DivineBody/Psijic/focused-deity favor row IDs -> current ThalmorOrthodox, DivineBody, and Psijic Section 13.13 row IDs
```

## P1 Contrast And Buildout Lanes

### Khajiit

```text
Race: Khajiit
Lane type: P1 first contrast
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: road-home Khenarthi/Azurah traveler.
Edge build: Rajhin thief, Alkosh dragon/order run, or ShadowDrift/curse pressure.
Normal-session route: travel by foot between two road-home anchors -> rest/observe moon fallback -> trigger one Baan Dar, Rajhin, or Alkosh behavior-specific beat -> Survey/MCM readout.
Accepted hooks: moon observance route 10, road-home anchors route 33, Baan Dar route 90, Rajhin route 91, Alkosh route 92.
Rejected hooks: required visual moon inspection, moon-sugar use, manual focus entitlement, fast travel loop, one-bed camping, generic inn sleep, generic crime/theft, generic combat, generic dragon spam, ordinary night stealth.
Anti-farm result: source tracks same-anchor road-home rejection and same-day diminishing multiplier; needs runtime proof that same-anchor repeats, generic theft, dragon spam, moon-sugar, and fast travel stay silent.
Survey/status result: source now has Khajiit-specific Survey/MCM readout for Lunar Lattice, moon practice, road-home cadence, and active focus; needs runtime display proof.
Final placement result: QASmoke route proof exists; needs one moon/road surface near travel/rest and one behavior-specific focus surface outside QASmoke.
Reward floor: broad lunar Faithful feels complete through road, sky, rest, and community without phase homework.
Reward ceiling: lunar substrate plus one focused emphasis plus one active contextual favor; no third loud steady package.
Stack snapshot: lunar metric/tier/phase/observance/road-home count, focused emphasis, five focus weights, last road-home anchor, repeat rejection count, active favor, lunar posture, ShadowDrift/curse pressure, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race khajiit
Next automatable action: run the holistic race-by-race effect review before using the CAT-6 Khajiit Tier 1 pilot mechanics as broader reward precedent.
Deferred manual proof: same-anchor rejection, generic theft/dragon/moon-sugar silence, Survey display, and final road/moon placement.
Blocking follow-up: prove anti-chore behavior; CAT-6 Khajiit Tier 1 now has a live pilot-provisional framework record, but it is grant-unwired and cannot stand in for Khajiit runtime reward proof.
```

### Argonian

```text
Race: Argonian
Lane type: P1 second contrast
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: Hist/People community survivor.
Edge build: Sithis-threshold assassin, vampire rupture, or werewolf strain.
Normal-session route: safe water/reflection maintenance -> chosen bed return -> Windhelm/Riften/community aid -> Survey/MCM readout; Void sampled only through a curated threshold beat.
Accepted hooks: Hist maintenance route 60, People support route 61, Void signal route 62, bed-of-choice route 63.
Rejected hooks: generic swimming loops, standing in water forever, ordinary travel, generic inn sleep, same-bed repetition, generic stealth, ordinary kills, generic murder, one Dark Brotherhood join as full Sithis activation.
Anti-farm result: source has same-day repeat multiplier, three-day Hist decay grace, non-curse floor, and three-signal Void threshold; needs normal-play proof.
Survey/status result: source now replaces numeric Hist/People/Void values with fiction-facing layer labels and bed/Sithis notes; needs runtime display proof.
Final placement result: QASmoke route proof exists; needs one Hist/People maintenance surface and one community/death-rite surface outside QASmoke.
Reward floor: non-assassin Argonian maintains identity through water, rest, reflection, bed of choice, and community aid.
Reward ceiling: Hist substrate plus one strongest support emphasis: People/community or Void/Sithis; Void never replaces Hist.
Stack snapshot: Hist, People, Void, posture, bed cadence, active favor, curse state, Sithis signal count, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race argonian
Next automatable action: write Arkay/death-rite and community recognition contracts before deeper Void rewards.
Deferred manual proof: Hist/People floor, swimming/sleep/murder rejection, Survey display, and final water/community placement.
Blocking follow-up: prove Hist/People floor, rejected hooks, Arkay/death-rite reaction, and Survey display.
```

### Orc

```text
Race: Orc
Lane type: P1 buildout packet
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: City or Legion/Exile Orc maintaining Malacath through quality labor or service.
Edge build: Stronghold/Blood-Kin, werewolf, or vampire-cured code pressure.
Normal-session route: confirmed life mode -> Stronghold forge/context beat -> City dignity or self-made community beat -> Legion/Exile service beat -> Survey/MCM readout.
Accepted hooks: Stronghold forge route 70, City dignity route 71, Legion service route 72, self-made community route 73.
Rejected hooks: raw craft count, generic kill/dungeon clear, ordinary city presence, ambient insult parsing, raw barter, Legion membership alone, generic patrol, MCM-only mode choice.
Anti-farm result: daily repeat multiplier exists; needs quality/value/context proof and generic craft/combat/membership rejection proof.
Survey/status result: source names mode, standing, and curse pressure; needs last accepted favor/reason clarity before pass.
Final placement result: QASmoke route proof exists; needs one Stronghold/craft and one City or Legion/Exile surface outside QASmoke.
Reward floor: City and Legion/Exile dignity, service, quality labor, and self-made belonging without Blood-Kin.
Reward ceiling: one active life-mode lane; Stronghold steadier, City and Legion/Exile sharper, no second substrate.
Stack snapshot: life mode, mode lockout, Stronghold/City/Legion weights, active favor, craft/service/community proof, last mode reason, curse state, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race orc
Next automatable action: add quality forge and City/Legion contract rows to the costing backlog.
Deferred manual proof: raw craft/combat/faction rejection, Survey display, and final Stronghold/City/Legion placement.
Blocking follow-up: prove parity routes and raw craft/combat rejection before increasing Malacath rewards.
```

### Redguard

```text
Race: Redguard
Lane type: P1 buildout packet
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: Crown or Forebear tomb/road/contract play.
Edge build: Ash'abah burden, vampire cure/Tu'whacca re-entry, or HoonDing make-way stack.
Normal-session route: Crown tomb respect -> Forebear road/contract passage -> Ash'abah death duty -> Far Shores private ritual -> Survey/MCM readout.
Accepted hooks: Crown route 80, Forebear route 81, Ash'abah route 82, Far Shores route 83.
Rejected hooks: menu choice without play, generic combat/body count, generic undead spam, Arkay replacement, generic amulet use, gold-making, fast travel, broad simulated stigma.
Anti-farm result: daily proof routes exist; needs fast-travel rejection, undead site/boss limits, HoonDing cap, Far Shores daily cap, and no Arkay substitution proof.
Survey/status result: source now names sect, standing, Far Shores token weight, and curse-cycle pressure without raw numbers; needs runtime display proof.
Final placement result: QASmoke route proof exists; needs one sect surface and one Far Shores/death-duty surface outside QASmoke.
Reward floor: Crown/Forebear form, road, contract, martial conduct, and recognition without undead farming.
Reward ceiling: broad sect worship reaches Faithful; Devoted requires focused primary; Far Shores supports, not a third boon engine.
Stack snapshot: sect, active favor, Far Shores token, HoonDing marker, Ash'abah burden, last sect reason, curse state, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race redguard
Next automatable action: add HoonDing cap and Ash'abah stigma contracts before reward expansion.
Deferred manual proof: fast-travel/undead/combat rejection, Survey display, and final sect/death-duty placement.
Blocking follow-up: prove rejected hooks and define HoonDing cap before expanding death-duty rewards.
```

### Bosmer

```text
Race: Bosmer
Lane type: P1 buildout packet
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: Living Story or Exchange non-hunter Bosmer.
Edge build: Bandit Road reversal, Old Contract Pact lapse/renunciation, or curse pressure.
Normal-session route: Old Contract proper hunt/forest kept -> Living Story community/nature proof -> Exchange debt/redress -> Bandit Road road-life/reversal -> Survey/MCM readout.
Accepted hooks: Old Contract routes 100-101, Living Story routes 102-103, Exchange routes 104-105, Bandit Road routes 106-107.
Rejected hooks: one generic Bosmer favor, generic kindness, generic bard activity, generic forest travel, generic trade profit, random vengeance, raw theft, generic crime, repeated theft, broad plant detection without tag evidence.
Anti-farm result: daily route keys and Bandit Road reversal cooldown exist; needs generic commerce/theft/forest/kindness rejection proof and Green Pact tag coverage before item punishment.
Survey/status result: source now has Bosmer-specific Survey/MCM readout for path, standing, Pact binding/lapse, and recent favor memory; needs runtime display proof.
Final placement result: QASmoke route proof exists; needs at least one non-hunter proof surface outside QASmoke before Green Pact tag expansion.
Reward floor: Living Story, Exchange, or Bandit Road recognition before item-tag work.
Reward ceiling: Old Contract can have the hardest burden/high ceiling, but cannot be the only emotionally rewarding path.
Stack snapshot: path, PactBound/compliance/lapse, active favor counters, offered/pending state, path-switch state, Bandit Road reversal cooldown, curse state, Daedric modifiers.
Runtime command: node .\tools\pdv_phase20_runtime_check.mjs --race bosmer
Next automatable action: write Green Pact tag coverage and non-hunter final placement contracts before item expansion.
Deferred manual proof: generic commerce/theft/forest/kindness rejection, Survey display, and final non-hunter placement.
Blocking follow-up: prove Bosmer Survey display and generic commerce/theft/forest/kindness rejection before the race can pass pre-beta feel.
```

## P2 Audit-Only Lanes

### Breton

```text
Race: Breton
Lane type: P2 audit-only
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Planning-Ready
Expected build: one chosen tradition: Knight's Road, Hidden Art, or Green Way.
Edge build: Hidden Art plus Daedric rupture or curse pressure.
Rejected hooks: casual tradition switching, generic spellcasting, generic Daedric artifact ownership, generic help without reward, ordinary animal kills, College membership, private curiosity, generic shrine visits.
Survey/status result: source now has Breton-specific Survey/MCM readout for tradition, vow, exposure, DruidicStanding, standing, and curse posture; needs runtime display proof and real tradition-track writes before pass.
Reward ceiling: one tradition spine plus one focused patron; other tracks modify, gate, rupture, or penalize.
Stack snapshot: tradition, WitchcraftExposure, KnightlyVowIntegrity, DruidicStanding, patron focus, active favor, curse fork, Daedric modifiers.
Next automatable action: add tradition readback and Hidden Art cost verifier contracts before any reward volume.
Deferred manual proof: tradition Survey display, rejected spell/artifact/help loops, and expected/edge stack audit.
Blocking follow-up: no new Breton reward volume until tradition readback, Hidden Art cost, and rejected hooks are proven.
```

### Dunmer

```text
Race: Dunmer
Lane type: P2 audit-only
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Planning-Ready
Expected build: ash-prayer and ancestor practice into one Reclamation focus.
Edge build: ancestor substrate plus Reclamation plus Daedric deviation or curse price.
Rejected hooks: generic crime as Mephala, generic cruelty as Boethiah, generic twilight/magic as Azura, Tribunal memory as a controllable path, non-Reclamation deviation without price.
Survey/status result: source now has Dunmer-specific Survey/MCM readout for ancestor layer, portable ash-prayer, private home rite, standing, and curse posture; needs runtime display proof and future Reclamation/deviation price surfacing before pass.
Reward ceiling: ancestor substrate is identity/utility; Reclamation focus is the loud foreground; deviations carry visible price.
Stack snapshot: ancestor substrate, posture, Reclamation focus, active favor, portable/home bonus, deviation price, curse state, Daedric modifiers.
Next automatable action: write deviation-price and overstack verifier contracts before new Dunmer rewards.
Deferred manual proof: ancestor/Reclamation stack audit, rejected generic Daedric behavior, and Survey display.
Blocking follow-up: no new Dunmer reward volume until overstack risk is audited.
```

### Imperial

```text
Race: Imperial
Lane type: P2 audit-only
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Planning-Ready
Expected build: civic Nine Divines broad worship with concrete service.
Edge build: public/private Talos pressure under ConcordatStanding.
Rejected hooks: faction membership, generic temple attendance, bounty payment alone, generic anti-Thalmor violence, cruelty framed as order.
Survey/status result: source now has Imperial-specific Survey/MCM readout for civic faith, ConcordatStanding, Talos pressure tilt, repair gate, standing, and curse posture; needs runtime display proof and future civic favor explanation before pass.
Reward ceiling: civic acts must remain concrete; ConcordatStanding modifies access or pressure, not a buff track.
Stack snapshot: ConcordatStanding, public/private Talos state, primary patron, active civic favor, repair/rupture state, curse state, Daedric modifiers.
Next automatable action: write civic act whitelist and rejected faction/attendance verifier contracts.
Deferred manual proof: civic Survey display, faction/attendance rejection, public/private Talos edge stack.
Blocking follow-up: no new civic surfaces until whitelisted civic acts and rejected faction/attendance tests are in the ledger.
```

### Nord

```text
Race: Nord
Lane type: P2 audit-only control
Verdict: Fail - runtime/manual proof deferred
No-in-game status: Readback-Ready
Expected build: broad Old Ways into Kyne or Talos.
Edge build: Hircine/werewolf stack.
Rejected hooks: generic kill, generic travel, generic tomb clear, generic anti-Thalmor violence, broad worship inheriting every patron boon, general Nord Daedric menu.
Survey/status result: strongest current surface; Nord has dedicated Survey and MCM mode labels. Needs shared stack snapshot and over-trigger evidence.
Reward ceiling: broad blended favors stay softer than focused patron rewards; Kyne/Talos/Hircine cannot stack into a universal build.
Stack snapshot: pantheon baseline, broad/focused state, primary patron, Kyne/Talos favor, Hircine price, vampire/scar state, active favor, Daedric modifiers.
Next automatable action: add dense-hook rejection and Hircine/Kyne/Talos stack audit contracts.
Deferred manual proof: over-trigger audit, generic hook rejection, and expected/edge stack snapshot.
Blocking follow-up: no new Nord content volume until dense-hook rejection and Hircine/Kyne/Talos stack checks pass.
```

## Scale-Gate Pilots

### CAT-6

First candidate remains `PDV_Bless_Khajiit_Lunar_T1`.

```text
Status: Pilot-provisional record/readback-proven
Source row: race-sheets/PDV_RaceContent_Manifest.md Section 14.3
Reason: low-risk passive non-dialogue blessing description tied to the Khajiit contrast lane: Lunar Lattice, road-home, moon, and caravan identity
Readback result: source row exists; PDV_Bless_Khajiit_Lunar_T1 is present in PlayerDevotion_Framework.esp as a pilot-provisional direct-framework CAT-6 record; its two night-gated MGEF effects also read back
Blocking follow-up: keep the pilot grant-unwired and run holistic race-effect review before full reward authoring
Fallback: PDV_Bless_Bosmer_Exchange_T1 source row exists, but the live target EditorID is absent and still needs a target-record owner decision; fallback copy should stay in Exchange/Z'en debt, proper return, and Bandit Road/Baan Dar reversal space
Not allowed for first pilot: Daedric stigma rows, Hircine/Molag Bal curse-access rows, dialogue
```

### Recognition/Dialogue

First candidate remains Altmer Auri-El crisis recovery recognition only if the
positive gate is CK-readable without generated dialogue or fragile helper state.

```text
Status: Packet draft only
Preferred fallback: Survey/status recognition only
Blocking follow-up: complete one non-Nord manual CK-authored packet with SEQ refresh, readback, runtime positive proof, and wrong-origin/wrong-state negative proof
Not allowed: generated dialogue creation or roster-wide recognition cloning
```
