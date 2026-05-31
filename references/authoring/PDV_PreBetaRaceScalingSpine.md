# PDV Pre-Beta Race Scaling Spine

**Created:** 2026-05-31
**Status:** Living pre-beta gameplay scaling contract
**Owner:** Companion to `PDV_PreBetaRaceAcceptanceRubric.md`, `PDV_RaceImplementationCostingBacklog.md`, `PDV_RaceGameplayBalanceAudit.md`, and the Phase 20 race-costing manifests

## Purpose

This file turns the Phase 20 route-proof closeout into an internal gameplay
scaling plan. The six Phase 20 proof packets already prove that QASmoke
activators reach the intended EventBus and manager routes. They do not prove
normal-play pacing, rejected-hook protection, Survey/status clarity, final
world placement, or reward ceilings.

`PDV_PreBetaRaceAcceptanceRubric.md` owns the measurable pass/fail bar for
this plan. This spine owns ordering, lane type, and packet shape; the rubric
owns whether a race is ready for external playfeel testing or stronger reward
tuning.

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
- Daedric CAT-4 expansion is a separate 1.0 content gate. Section 11.6 roster,
  recovery, and cross-Prince hostility defaults are locked; remaining blockers
  are stigma row ratification, Hircine/Molag Bal curse-access template shape,
  and Prince authoring order.

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
`PDV_PreBetaRaceAcceptanceRubric.md` as `Pass`, `Conditional`, or `Fail`.

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
Survey/status readout: Crisis state, Lorkhan pressure, recovery or scar, alignment band, and active favor family read as Altmer coherence pressure rather than debug counters.
Final placement: Move at least one crisis/pressure proof surface and one positive daily-life proof surface out of QASmoke into a plausible normal-play location or quest-context plan.
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
Survey/status readout: Lunar substrate, current focus weights, road-home movement, and lunar posture explain belonging without calendar chores.
Final placement: Plan one moon/road proof surface near real travel or rest play and one focus proof surface tied to behavior-specific context.
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
Survey/status readout: Hist, People, Void, bed-of-choice, and posture read as layered exile belonging; one Void signal does not replace the Hist.
Final placement: Plan one Hist/People maintenance surface and one community/death-rite surface outside QASmoke before Void reward expansion.
Reward ceiling: Hist substrate plus one strongest support emphasis: People/community or Void/Sithis. Void can stabilize, but it does not replace Hist.
Reward floor: A non-assassin Argonian can maintain identity through water, rest, reflection, bed of choice, and community aid.
Stack snapshot: Hist, People, Void, posture, bed cadence, active favor, curse state, Sithis signal count, and Daedric modifiers.
Runtime proof command: node .\tools\pdv_phase20_runtime_check.mjs --race argonian
Manual feel note: The player should understand whether they are maintained, distant, strained, silenced, or corrupted without needing Dark Brotherhood play.
Content dependency: Current race-facing content is enough for hook validation; god/Daedric content is needed before exact Sithis, Molag Bal, Hircine, and recovery text is final.
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
Normal-play hook: Crown tomb respect, Forebear road or contract play, Ash'abah death duty, Far Shores private ritual, HoonDing cap candidate.
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
Survey/status readout: OldContract, LivingStory, Exchange, and BanditRoad counters and path state explain the active path without one generic Bosmer favor.
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
