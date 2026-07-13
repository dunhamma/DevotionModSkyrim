# PDV Pre-Beta Race Scaling Spine

**Created:** 2026-05-31
**Status:** Living pre-beta gameplay scaling contract
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceAcceptanceRubric.md`, `PDV_Phase20_PreBetaManualChecks_Runbook.md`, `PDV_RaceImplementationCostingBacklog.md`, `PDV_RaceGameplayBalanceAudit.md`, and the Phase 20 race-costing manifests

## Purpose

This file turns the Phase 20 route-proof closeout into an internal gameplay
scaling plan. The six Phase 20 proof packets already prove that QASmoke
activators reach the intended EventBus and manager routes. They do not prove
normal-play pacing, rejected-hook protection, Survey/status clarity, final
world placement, or reward ceilings.

`PDV_PreBetaRaceGateLedger.md` records the current race-by-race evidence and
verdict. `PDV_PreBetaRaceAcceptanceRubric.md` owns the measurable pass/fail bar
for this plan, and `PDV_Phase20_PreBetaManualChecks_Runbook.md` owns the manual
wrong-origin, rejected-hook, Survey/status, stack snapshot, and final-placement
handoff. This spine owns ordering, lane type, and packet shape; the ledger
records whether a race is ready for external playfeel testing or stronger
reward tuning.

External beta should wait until these pre-beta gates prove a race experience
rather than missing systems. The current scaling spine is:

1. Altmer - active spine for explicit crisis, Lorkhan pressure, and recovery.
2. Khajiit - first contrast for silent focus, moon cadence, and road belonging.
3. Argonian - second contrast for Hist/People floor before Void depth.
4. Orc, Redguard, Bosmer - P1 packets prepared in parallel, then promoted when the shared gate is stable.
5. Breton, Dunmer, Imperial, Nord - P2 audit-only lanes until stack and ceiling risk is understood.

Related merged planning/content work:

- `race-sheets/PDV_RaceContent_Manifest.md` now carries full draft prose for
  all ten race-facing sections, with Nord still serving as the full content
  pilot. These rows help validate Survey/status feel and reward texture, but
  they are draft content until ratified and promoted into ESP records.
- `references/PDV_ExperienceMode_DesignReference.md` and
  `references/authoring/PDV_ExperienceMode.manifest.json` lock the future
  Pilgrim's Path / Wayfarer's Path difficulty surface. Experience Mode is not
  runtime-live and should not be used to compensate for missing race hooks
  during this scaling pass.
- Daedric CAT-4 expansion is a separate 1.0 content gate. Section 11.6 D-12..D-18
  decisions are locked; remaining blockers are proof-path gates: per-Prince
  CAT-6 target selection, record readback, runtime or display proof, and
  stack/Survey legibility.

## Ratified Workshop Outcomes

- `Ratified`: Altmer's third crisis beat is `MarriageBeat`, presented in
  player-facing terms as Marriage / Mortal Continuity. The beat is about
  household, lineage, embodied attachment, and continuity inside Lorkhan's
  mortal world; it is not anti-Mara and not a claim that Altmer marriage is
  invalid. The Talos/Thalmor contradiction is not part of the current four-row
  crisis list and should only return through a later explicit additional-row
  decision.
- `Ratified`: the two wired Altmer proof rewards use
  `PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance` for dawn steadiness
  and `PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended` for
  orthodox cost.
- `Ratified`: Survey/status copy for Altmer, Khajiit, Argonian, and Bosmer
  should read as immersive religious state, not as diagnostic counters. Debug
  route IDs, raw favor counters, and implementation labels stay out of the
  player-facing copy.
- `Ratified`: first final-world placement concepts are Altmer
  dawn/study/crisis, Khajiit road-home/moon/caravan, and Argonian
  Hist/People/water/community.
- `Ratified`: lore cross-review guardrails stand for all four active copy
  directions. Khajiit copy foregrounds Lunar Lattice, road-home, moon, caravan,
  and Baan Dar/Rajhin/Alkosh focus, not moon-sugar or generic theft shortcuts.
  Argonian copy keeps Hist primary, People/community and water as support, and
  Void/Sithis as pressure or stabilization that never replaces the Hist. Bosmer
  copy reads through Y'ffre/Green Pact, Living Story, Exchange/Z'en, and Bandit
  Road/Baan Dar without exposing raw path counters.
- `Ratified`: race hook validation can continue before full Daedric proof, but
  final reward text, Prince prices, stigma, exits, and final Survey/status copy
  wait for the Daedric proof path. D-15..D-18 decisions are locked; the active
  blockers are per-Prince CAT-6 promotion/readback, runtime or display proof,
  and stack/Survey legibility.

## Shared Gate

Every race packet must record the same evidence before it asks for stronger
rewards, external testing, or launch acceptance.

```text
Race:
Lane type: P0 active spine / P1 buildout / P2 audit-only
Scaling role:
Normal-play hook:
Rejected generic hooks:
Survey/status readout:
Final placement:
Reward ceiling:
Reward floor:
Stack snapshot:
Runtime proof command:
Manual feel note:
Content dependency:
```

The acceptance verdict for that evidence is recorded in
`PDV_PreBetaRaceGateLedger.md` using the `Pass`, `Conditional`, or `Fail` bar
from `PDV_PreBetaRaceAcceptanceRubric.md`.

### Evidence Rules

- `Normal-play hook` names the real-world or quest-context signal to prove next; QASmoke proof alone is not enough.
- `Rejected generic hooks` must include ordinary behaviors that stay silent: travel, sleep, combat, theft, crafting, faction membership, shrine attendance, repeat activation, or equivalent race-specific loops.
- `Survey/status readout` must explain what changed and why in player-facing terms, not as route IDs, counters, or debug labels.
- `Final placement` is tracked separately from QASmoke. Proof markers can validate routing; they do not validate pacing or worldbuilding.
- `Reward ceiling` names what must not stack too loudly.
- `Reward floor` names the minimum satisfying normal-session experience.
- `Stack snapshot` records active boons, temporary favors, privileges, prices, neglect/scar effects, and curse or Daedric modifiers active at once.
- `Manual feel note` is accepted evidence only after source/readback checks are clean; it captures whether the race feels authored, fair, and legible.

## P0 Active Spine

### Altmer

```text
Race: Altmer
Lane type: P0 active spine
Scaling role: Prove explicit theological friction without making ordinary Skyrim play punitive.
Normal-play hook: First authored crisis source, Lorkhan pressure source, dawn steadiness, orthodox costly enforcement, Exiled vampire or cured-scar transition.
Rejected generic hooks: Ordinary travel, ordinary friendships, generic spellcasting, raw magic skill gain, generic College membership, generic anti-Thalmor violence, repeated post-first-crisis Dragonborn identity.
Survey/status readout: Read as Altmer coherence pressure: dawn discipline, study, crisis, recovery or scar, and alignment posture. `MarriageBeat` should surface as Marriage / Mortal Continuity, not as a rejection of Mara or marriage itself. Do not expose route IDs, raw favor counters, or "debug" language.
Final placement: First final-world concept is a dawn/study/crisis surface: one positive dawn or study surface plus one authored crisis/pressure surface outside QASmoke.
Reward ceiling: Auri-El foundation plus one secondary focus plus one active contextual favor family; ThalmorAlignment modifies access or pressure instead of becoming a third boon engine.
Reward floor: Dawn practice, study, magic milestones, and coherent behavior keep a non-edge Altmer net-positive without perfect play.
Stack snapshot: Auri-El foundation, secondary focus, active contextual favor, crisis state, ThalmorAlignment, vampire/werewolf/cured-scar effects, and any Daedric deviation.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race altmer
Manual feel note: The player can say why the crisis or favor happened, why ordinary life stayed silent, and whether recovery felt possible.
Content dependency: Current race-facing content is enough for hook validation; full god/Daedric content is needed before exact focus rewards, prices, and Survey copy are final.
```

## P1 Contrast And Buildout Lanes

### Khajiit

```text
Race: Khajiit
Lane type: P1 first contrast
Scaling role: Prove silent emergent focus and moon/road belonging as the opposite pattern from Altmer crisis pressure.
Normal-play hook: Fallback lunar cadence, two-anchor road-home cycle, caravan/community recognition, focus movement for Baan Dar, Rajhin, and Alkosh.
Rejected generic hooks: Required visual moon inspection, moon-sugar use, manual focus entitlement, fast travel loop, one-bed camping, generic inn sleep, generic theft, generic dragon kills, ordinary night stealth.
Survey/status readout: Read as road and moon belonging: the Lattice, current focus, road-home movement, and posture should explain where the Khajiit is held without sounding like a calendar task. Avoid moon-sugar, generic theft, generic night-stealth, or generic dragon-kill language as the identity center.
Final placement: First final-world concept is a road-home/moon/caravan surface: one moon or rest surface near real travel plus one caravan or behavior-specific focus surface.
Reward ceiling: Lunar substrate stays a quiet amplifier; one active focus and one active contextual favor family carry the loud reward.
Reward floor: A Khajiit feels held by moon and road through ordinary travel, rest, and community play without scheduling phases or farming crime.
Stack snapshot: Lunar tier, focused emphasis, road-home count/anchor, active favor, lunar posture, ShadowDrift or curse pressure, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race khajiit
Manual feel note: Moon and road should feel like texture and belonging, not required homework.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before final focus reward text and Nocturnal/ShadowDrift prices.
```

### Argonian

```text
Race: Argonian
Lane type: P1 second contrast
Scaling role: Prove the non-Sithis Hist/People floor before expanding Void depth.
Normal-play hook: Water/rest/reflection maintenance, Hist sap or equivalent ritual, bed-of-choice cadence, community recognition, Arkay/death-rite reaction, curse posture.
Rejected generic hooks: Swimming loops, standing in water forever, generic inn sleep, repeated one-bed use, ordinary stealth, ordinary kills, one Dark Brotherhood join as full Sithis activation.
Survey/status readout: Read as layered exile belonging: Hist reach, People/community support, water or rest maintenance, Void pressure, bed-of-choice, and posture. One Void signal must not sound like it replaces the Hist; Sithis/Void is pressure or stabilization, not a new primary home.
Final placement: First final-world concept is a Hist/People/water/community surface: one water or Hist maintenance surface plus one community or death-rite surface outside QASmoke before Void reward expansion.
Reward ceiling: Hist substrate plus one strongest support emphasis: People/community or Void/Sithis. Void can stabilize, but it does not replace Hist.
Reward floor: A non-assassin Argonian can maintain identity through water, rest, reflection, bed of choice, and community aid.
Stack snapshot: Hist, People, Void, posture, bed cadence, active favor, curse state, Sithis signal count, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race argonian
Manual feel note: The player should understand whether they are maintained, distant, strained, silenced, or corrupted without needing Dark Brotherhood play.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before exact Sithis, Molag Bal, Hircine, and recovery text is final.
Readback note: DominationPressure now has a compile-clean manager writer as of 2026-06-14: Argonian + vampire + Molag Bal Seeker sets the existing posture-pressure flag and lets the Hist substrate resolve Corrupted(4). Runtime/manual proof of the transition remains pending.
```

### Orc

```text
Race: Orc
Lane type: P1 buildout packet
Scaling role: Prepare parity proof so Stronghold, City, and Legion/Exile are complete lives rather than one rich lane and two weak lanes.
Normal-play hook: One Stronghold beat, one City dignity or self-made community beat, and one Legion/Exile service beat.
Rejected generic hooks: Raw craft count, generic kill count, generic dungeon clear, ordinary city presence, ambient insult parsing, Legion membership alone, menu-only mode choice.
Survey/status readout: Active life mode and standing explain where the Orc belongs now and why Malacath is still the religious spine.
Final placement: Plan one Stronghold/craft surface and one City or Legion/Exile surface outside QASmoke before increasing Malacath reward magnitude.
Reward ceiling: One active life-mode lane; Stronghold may be steadier, but City and Legion/Exile get sharp situational moments, not a second substrate.
Reward floor: A City or Legion/Exile Orc gets dignity, service, quality labor, and self-made belonging without Blood-Kin.
Stack snapshot: Life mode, mode lockout, active favor, craft/service/community proof, curse state, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race orc
Manual feel note: City and Legion/Exile should not read as failed Stronghold.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before exact Malacath/Trinimac/Boethiah prices and rewards are final.
```

### Redguard

```text
Race: Redguard
Lane type: P1 buildout packet
Scaling role: Prepare sect proof so Crown, Forebear, and Ash'abah stay distinct beyond martial or undead content.
Normal-play hook: Crown tomb respect, Forebear road or contract play, Ash'abah death duty, Far Shores portable token ritual, HoonDing cap candidate.
Rejected generic hooks: Generic combat, generic body count, generic undead spam, fast travel, generic gold-making, Arkay shrine use as Tu'whacca replacement.
Survey/status readout: Sect posture and Far Shores/Tu'whacca duty explain why the act mattered in Yokudan terms.
Final placement: Plan one sect proof surface and one Far Shores/death-duty surface outside QASmoke before increasing death-duty rewards.
Reward ceiling: Broad sect worship reaches Faithful; Devoted requires focused primary commitment. Ancestor reverence and Far Shores support, not a third boon family.
Reward floor: Crown or Forebear play is satisfying through form, road, contract, martial conduct, and recognition without farming undead.
Stack snapshot: Sect, active favor, Far Shores token, HoonDing marker, Ash'abah burden, curse state, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race redguard
Manual feel note: Road, form, duty, and stigma should compete emotionally with undead-clearing.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before exact Prince friction and sect reward copy are final.
```

### Bosmer

```text
Race: Bosmer
Lane type: P1 buildout packet
Scaling role: Prepare non-hunter parity proof so Living Story, Exchange, and Bandit Road feel as authored as Old Contract.
Normal-play hook: Old Contract proper hunt/forest kept, Living Story community/nature proof, Exchange debt/redress, Bandit Road road-life/reversal.
Rejected generic hooks: Generic forest travel, generic kindness, generic bard activity, generic trade profit, random vengeance, raw theft, repeated crime, broad plant detection without reliable item evidence.
Survey/status readout: Read as active path theology: Old Contract obligation, Living Story belonging, Exchange/Z'en debt and proper return, or Bandit Road/Baan Dar reversal. Raw `favor=oc/ls/ex/br` counters stay readback-only, not player copy.
Final placement: Plan one non-hunter proof surface outside QASmoke before broad Green Pact item tagging expands.
Reward ceiling: Old Contract can have the hardest burden and high ceiling, but not the only emotionally rewarding path.
Reward floor: Non-hunter Bosmer receives clear story, exchange, or road-life recognition before Green Pact tag work.
Stack snapshot: Path, PactBound/compliance/lapse, active favor counters, path-switch state, Bandit Road cooldown, curse state, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race bosmer
Manual feel note: Non-hunter payoff should feel like path theology, not watered-down hunting.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before exact Baan Dar/Z'en/Y'ffre and Prince interactions are final.
```

## P2 Audit-Only Lanes

P2 races are in the scaling pipeline now, but they do not get more reward
volume until their ceilings are understood. Each packet must gather one
expected-build pass, one edge-build pass, a stack snapshot, generic rejected
hooks, and a Survey/status clarity check.

### Breton

```text
Race: Breton
Lane type: P2 audit-only
Scaling role: Prevent Knight's Road, Hidden Art, and Green Way from becoming three simultaneous reward engines.
Normal-play hook: Tradition setup/readback plus one tradition-specific favor family.
Rejected generic hooks: Casual tradition switching, generic spellcasting, generic Daedric artifact ownership, generic help without reward, ordinary animal kills.
Survey/status readout: Current tradition, exposure/vow/druidic pressure, and curse fork are legible without implying all traditions are active.
Final placement: Not a buildout gate yet; capture expected and edge build evidence before adding surfaces.
Reward ceiling: One tradition spine plus one focused patron; other tracks modify, gate, rupture, or penalize.
Reward floor: The chosen tradition has visible cost/recovery texture and one satisfying early favor route.
Stack snapshot: Tradition, WitchcraftExposure, KnightlyVowIntegrity, DruidicStanding, patron focus, active favor, curse fork, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_verify.mjs --strict-phase20-race-costing
Manual feel note: The audit fails if Hidden Art power, Knightly public virtue, and Green Way standing all pay loudly at once.
Content dependency: God/Daedric content is needed before final Hidden Art prices, Druidic Trial, and Prince response text are locked.
```

### Dunmer

```text
Race: Dunmer
Lane type: P2 audit-only
Scaling role: Prevent ancestor substrate, Reclamation focus, and Daedric deviations from overstacking.
Normal-play hook: Ancestor substrate proof plus one focused Reclamation route.
Rejected generic hooks: Generic crime as Mephala, generic cruelty as Boethiah, generic twilight or magic as Azura, Tribunal memory as a controllable path, non-Reclamation deviation without price.
Survey/status readout: Ancestor posture and Reclamation focus explain that focus adds weight without replacing ash-prayer.
Final placement: Not a buildout gate yet; capture expected and edge build evidence before increasing deviation rewards.
Reward ceiling: Ancestor substrate plus one Reclamation foreground focus; deviations carry price, stigma, exit, or residue.
Reward floor: Ash-prayer, portable/private shrine, and diaspora/ancestor feedback remain meaningful without becoming a second boon package.
Stack snapshot: Ancestor substrate, posture, Reclamation focus, active favor, portable/home bonus, deviation price, curse state, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_verify.mjs --strict-phase10 --strict-phase20-race-costing
Manual feel note: The audit fails if ancestor utility and Good Daedra focus combine into the best generic package.
Content dependency: God/Daedric content is needed before exact Azura/Boethiah/Mephala reward and deviation prices are final.
```

### Imperial

```text
Race: Imperial
Lane type: P2 audit-only
Scaling role: Keep civic religion concrete instead of abstract faction or law scoring.
Normal-play hook: Civic act whitelist, public/private Talos distinction, Concordat repair or rupture check.
Rejected generic hooks: Faction membership, generic temple attendance, bounty payment alone, generic anti-Thalmor violence, cruelty framed as order.
Survey/status readout: Concordat standing, Talos public/private state, repair, and civic recognition explain the act rather than the institution.
Final placement: Not a buildout gate yet; capture expected and edge build evidence before adding more civic surfaces.
Reward ceiling: Broad Nine Divines plus one focused primary; ConcordatStanding modifies access or pressure rather than adding a buff track.
Reward floor: Non-combat civic play gets visible recognition through mercy, burial, lawful repair, honest exchange, or public service.
Stack snapshot: ConcordatStanding, public/private Talos state, primary patron, active civic favor, repair/rupture state, curse state, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_verify.mjs --strict-phase8 --strict-phase20-race-costing
Manual feel note: The audit fails if the player is rewarded for wearing faction membership instead of doing concrete civic work.
Content dependency: God/Daedric content is needed before final civic Divines and taboo Prince response copy are locked.
Readback note: Arkay/Stendarr Concordat secondary gain arrays are live/readback-clean as of 2026-06-14; exact source routing and runtime feel proof remain pending.
```

### Nord

```text
Race: Nord
Lane type: P2 audit-only control
Scaling role: Use Nord as the fully felt control while auditing it for hook density and ceiling failure.
Normal-play hook: Broad Old Ways/Nine Divines readout, focused Kyne/Talos contrast, Hircine interaction, pantheon baseline and offer-gate proof.
Rejected generic hooks: Generic kill, generic travel, generic tomb clear, generic anti-Thalmor violence, broad worship inheriting every patron boon, general Nord Daedric menu.
Survey/status readout: Broad and focused states explain which god noticed the player and why without making Nord the default best-supported race.
Final placement: Not a buildout gate yet; capture expected and edge build evidence before adding more Nord content.
Reward ceiling: Broad blended favors stay softer than focused patron rewards; Kyne/Talos/Hircine do not stack into a universal build.
Reward floor: Broad Nord play still feels complete through old roads, weather, holds, Talos pressure, and chosen patron life.
Stack snapshot: Pantheon baseline, broad/focused state, primary patron, Kyne/Talos favor, Hircine price, vampire/scar state, active favor, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord
Manual feel note: The audit fails if Nord hook density turns normal Skyrim play into constant reward noise.
Content dependency: God/Daedric content is needed before final Shor/Tsun/Stuhn and non-Hircine Prince interactions are locked.
```

## Subagent Packets

When splitting the next implementation session, keep write scopes disjoint.
Read-only research packets may run in parallel; code or manifest edits should
assign one owner per file.

| Packet | Scope | Output |
|---|---|---|
| A | Altmer spine | Filled shared gate plus exact normal-play proof checklist. |
| B | Khajiit contrast | Anti-chore and rejected-hook checklist for moon, road, and focus. |
| C | Argonian floor | Hist/People before Void proof checklist. |
| D | Orc, Redguard, Bosmer | Three P1 buildout packets using the shared gate. |
| E | Breton, Dunmer, Imperial, Nord | Four P2 audit-only packets and stack snapshot template. |

## Verification Sequence

Run before any runtime proof:

```powershell
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
```

Run after QASmoke route activation:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race all
node .\tools\pdv_phase20_runtime_check.mjs --race all --strict-manager
```

Manual closeout remains per race:

- Wrong-origin rejection.
- Generic travel, sleep, combat, theft, crafting, faction, shrine, or repeat activation rejection where relevant.
- Survey Devotion or MCM Player page explains what changed and why.
- Final placement is tracked separately from QASmoke.
- Stack snapshot records active boons, favors, prices, privileges, neglect/scar effects, and curse or Daedric modifiers.

## Next Build-Pass Record Spec (magnitudes + EditorIDs)

The locked magnitudes and EditorIDs for the next ESP-record build pass live in
`PDV_NextBuildPass_RecordSpec.md` (record list + magnitude kept together per ruling). Rulings made
with the user 2026-06-14. Headline magnitudes recorded there:

- **2026-06-14 partial closeout:** the consolidated build pass consumed sec.1
  for the first tranche. `PDV_RepTrack_ThalmorAlignment` is live/read back as a
  -100..+100 5-state Concordat mirror, the manager owns
  `PDV_ThalmorAlignmentTrack`, and Altmer Survey now uses the alignment-path
  base after track readback. This is readback/compiler proof only; no runtime or
  manual spot-check claim is made here. Sections 2-8 remain follow-up ESP
  tranches.
- **Altmer ThalmorAlignment** (USER OVERRIDE reconciled into the Altmer race
  doc): -100..+100 5-state Concordat mirror. The live first-tranche Lorkhan
  modifier is x0.75/x0.875/x1.0/x1.25/x1.5. The separate self-cultivation and
  enforcement signal multiplier helper, plus point-table routes
  +15/+20/-15/-20/-5/-25, remain deferred until those signal routes are
  implemented.
- **Breton KnightlyVowIntegrity:** breaches TG -30 / DB -40 / innocent-kill -15 / abandon-NPC -10;
  suppression below-50 x0.75 (Stendarr x0.5) and below-25 x0.5 (Stendarr x0.25); 4 BC-0477 creed-loss
  spells. Threshold HUD notices are source/compile/readback-clean as of 2026-06-14; breach-source
  routing and in-game Active Effects proof remain pending.
- **Orc Witnessed (5 beats):** Argonian-variety mirror; Trial of Iron 4-choice (+5 each / Yoke +15
  carry), Four Holds +1.0 x4, Code Holds survival +0.5, Hearth-Held bed-of-choice, Watchers notif 1/dawn.
  Code Holds source/record/readback is live as of 2026-06-14: one shared below-20% combat-session hook
  marks the dip, then Orc pays out on survived combat exit.
- **Redguard Far Shores:** DELTA_FAR_SHORES_TOKEN 1.0; token UNCONDITIONAL V1 (BC-0524); Ash'abah category-gate.
- **Argonian:** Sithis T3 = Fortify Stamina (Maximum Stamina) passive + scripted flat `RestoreActorValue("Stamina",100)` near-death burst (1/day) [2026-07-13 Requiem conversion; was StaminaRateMult +10% + 50-stamina-regen burst];
  curse MESGs (BC-0642); DominationPressure at Molag Bal>=25 + vampire is manager-live/readback-clean;
  Hist creed-loss -4/-8/-6.
  Sithis T3 source/record/readback is live as of 2026-06-14: passive T3 plus a once/day shared
  below-20% burst. Runtime/manual proof remains pending.
- **Dunmer:** werewolf Layer-2 0.75x Good Daedra is manager-source/compile-clean as of 2026-06-14;
  dawn/dusk 3-hr windows +0.25 are source/compile-clean for portable prayer only. Grey Quarter +0.75/act
  + Mephala +2.0 Champion and the outdoor Good Daedra shrine emitter remain open.
- **Orc dawn-side:** oath-break DELTA -1.5 source route and reusable receiver route 74 are
  compile-clean as of 2026-06-14; exact quest/failure emitters remain deferred. Forge/strength stay
  on the likes/dislikes faucet.
- **Orc Witnessed:** first record tranche is live/readback-clean as of 2026-06-14 for Trial of Iron
  support spells, Watchers notices, Hearth-Held spell/notices, and Four Holds hold/milestone
  messages. Four Holds route 75 is source/compile/verifier-clean with StorageUtil one-shot keys,
  and its four added QASmoke ACTI/REFR proof surfaces are readback-clean. Runtime behavior for
  Trial of Iron/Watchers/Hearth-Held, Four Holds runtime activation, and final-world Four Holds
  placement/proof remain follow-up work.
- **Imperial Concordat:** Enforcer Arkay/Stendarr -15% daily, Open Defiant Stendarr +15%; graduated
  point table (+/-5/10/15/20) replacing the flat +/-15.

Idempotency: all magnitudes are entered BY HAND in the build pass; do NOT run a cumulative/additive
rebalance tool (doubles on a 2nd write).
