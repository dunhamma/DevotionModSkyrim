# PDV Race Implementation Costing Backlog

**Created:** 2026-05-30
**Status:** Living implementation-costing backlog
**Owner:** Companion to `PDV_RaceGameplayBalanceAudit.md`, `PDV_RaceRewardBudgetLedger.md`, and `PDV_RacePlaystyleCoverageLedger.md`

## Purpose

This backlog turns the race gameplay audit into buildable slices. The race sheets now describe the intended player fantasy; this file answers the next question:

> What must be built, rejected, surfaced, and proven so every race feels equally cared for in play?

It is deliberately not a lore rewrite. Use the race sheets and architecture reference for theology. Use this file when costing runtime records, Papyrus state, CK surfaces, content rows, verifier assertions, and runtime proof.

The shared handoff for the current pre-beta gameplay-scaling pass is
`references/authoring/PDV_PreBetaRaceScalingSpine.md`. Use that file for the
race packet template, Altmer/Khajiit/Argonian spine order, P1 buildout packets,
P2 audit-only split, subagent work split, and verification sequence. Use
`references/authoring/PDV_PreBetaRaceGateLedger.md` for the current evidence
and race verdicts, and `references/authoring/PDV_PreBetaRaceAcceptanceRubric.md`
for the actual pass/conditional/fail bar before stronger rewards or external
playfeel testing. Use
`references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md` for the
manual wrong-origin, generic-hook, Survey/status, stack snapshot, and
final-placement checks after automated gates pass.
Use `references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` when the next
session is intentionally not opening Skyrim; it owns the remaining
source/readback/planning work that can proceed before manual runtime evidence.
The structured version of that queue is
`references/authoring/PDV_Phase20_NoInGameProof_Gates.json`; the strict Phase
20 race-costing verifier reads it to check no-game status, hook contracts,
final-placement contracts, stack snapshots, CAT-6 target-record state,
recognition prep, and Daedric blockers.
Recognition/dialogue work uses `PDV_RecognitionDialogueScalePacket.md`, and
CAT-6 content promotion uses `PDV_CAT6PromotionPilot.md`; neither should be
folded into a race runtime slice without its packet gate.

## Evidence Used

- PDV race architecture and race sheets: `references/PDV_RaceArchitecture_DesignReference.md`, `race-sheets/PDV_RaceDesign_*.md`, and `race-sheets/Race_*.md`.
- Race-facing content: `race-sheets/PDV_RaceContent_Manifest.md`, `race-sheets/PDV_ContentDestinationMatrix.md`, and generated `race-sheets/writer-review/`.
- Existing proof lanes: Phase 9 Bosmer path proof, Phase 10 Dunmer substrate proof, Phase 12 Nord contextual-favor proof, Phase 13 Hircine price proof, and Phase 18 status/Nord proof.
- Neutral gameplay reference repo, read directly from `C:\Users\Admin\Documents\SkyrimGameplayReference\data`: playable race abilities, actor values, actor-type keywords, condition functions, story-manager events, location keywords, and social/faction notes.
- PDV crosswalk docs under `references/vanilla-gameplay/pdv-crosswalk/`, especially hook feasibility, route recipe, and implementation candidate notes.

## Costing Lenses

Use all lenses when promoting a race slice. A slice can be technically cheap and still bad gameplay if it flattens the race.

| Lens | Question | Failure Mode |
|---|---|---|
| Gameplay parity | Does the race get comparable felt value to other races? | Sparse-hook races feel like hidden counters while hook-rich races get constant feedback. |
| Story texture | Does the mechanic express the race's theology and lived culture? | Generic piety rewards replace distinct religious life. |
| Immersion budget | Does the reward feel like something this race would name, notice, fear, recover from, or seek? | Technically valid rewards feel like generic buffs, hidden counters, or quest bonuses. |
| Class spread | Do at least three race-shaped playstyles have satisfying routes? | One build becomes the obvious correct build. |
| Hook reality | Is the signal backed by vanilla data, curated quest stages, CK records, or explicit custom scope? | The design depends on imagined hooks the game cannot expose cleanly. |
| Anti-farm | Can the player grind it without doing meaningful devotional behavior? | Crafting, kills, sleep, travel, or faction state become repeatable faucets. |
| Comprehension | Can the player understand why the state changed? | Devotion feels arbitrary or punitive. |
| Compatibility | Will list authors and patch rules be able to reason about it? | The slice depends on list-specific NPCs, fragile references, or hidden assumptions. |
| Proof | Can source, records, verifier, and runtime tests prove it? | The slice sounds finished but cannot be closed. |

## Creative And Gameplay Rules

1. Rewards should feel like recognition, access, recovery, ritual confidence, or a well-earned favor before they become raw stat power.
2. A race with heavy friction needs clearer recognition, not necessarily stronger numbers.
3. Persistent substrates should mostly express identity, maintenance, or vulnerability. The foreground patron, path, sect, mode, or focus remains the loud layer.
4. Contextual favors should be memorable but capped. One active contextual favor family at a time is the default unless a race sheet explicitly justifies otherwise.
5. Rejected hooks are part of the design. Every runtime slice should say what ordinary behavior must not count.
6. Curse and Daedric paths must keep the native race architecture visible through price, stigma, exit, or residue.
7. Sparse-hook social play needs authored surfacing. It is not enough to silently increment piety for community care.
8. Every slice needs an immersion proof: the diegetic trigger meaning, the feedback surface, the ordinary behavior that is explicitly rejected, and the expected normal-session feel.

## Build Priority

| Priority | Slice | Why |
|---|---|---|
| P0 | Altmer pre-beta gameplay scaling | The implementation-spec gap is closed, the first manager/EventBus/EventTypes/receiver source scaffold compiles, `PDV_State_AltmerCrisis` is record-wired, the first two contextual favor spell records are wired, four Altmer trigger proof ACTI base records are wired, three curse/exile message records are wired, and the four QASmoke proof references pass readback plus route runtime proof. The next risk is not external beta; it is building enough real gameplay surface to judge Lorkhan/crisis pacing, rejected surfaces, Exiled vampire behavior, and whether the first rewards feel authored rather than punitive. |
| P1 | Multi-race pre-beta gameplay scaling | Argonian, Orc, Redguard, Bosmer, and Khajiit have moved into source/record/proof-placement wiring and QASmoke route runtime proof. Each has strong fantasy, but still needs normal-play hook validation, rejected-surface checks, status/survey feel checks, final immersive placement, and enough reward content that a tester can judge experience rather than absence. |
| P2 | Breton and Dunmer stack control | These races are rich enough that track/substrate/focus layers can overpay. Their next audit pass is reward-ceiling and stack-feel validation, not more proof-marker volume. |
| P2 | Imperial and Nord ceiling control | These races are hook-rich and proven enough that restraint matters more than adding more volume. Their next audit pass is negative-hook and over-trigger validation in normal play. |

Scaling order is now locked for the next implementation session: Altmer first,
Khajiit as the first contrast, Argonian as the second contrast, and Orc /
Redguard / Bosmer prepared in parallel as P1 packets. Breton, Dunmer, Imperial,
and Nord remain P2 audit-only until stack and ceiling evidence is recorded.
Every promoted race packet now needs a gate-ledger verdict using
`PDV_PreBetaRaceAcceptanceRubric.md`.

## P0 - Altmer Costing

**Child manifest:** `references/authoring/PDV_Phase20AltmerImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-altmer` is live at manifest/content level, checks the manager/EventBus/EventTypes/receiver source contract, reads back the `PDV_State_AltmerCrisis` state-track record, verifies any `record-wired` Altmer favor family for `KYWD`/`MGEF`/`SPEL`, spell-effect membership, magic-effect keyword, and manager spell-property wiring, verifies wired ACTI proof surfaces, and verifies wired curse/exile `MESG` records plus manager message properties. It should expand into trigger/runtime assertions as the slice is promoted.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_AltmerProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-altmer-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Crisis state | `PDV_State_AltmerCrisis` state surface, manager constants, crisis messages. Source scaffold exists in `PDV__ManagerQuest`; the CK record is wired through `PDV_StateTrack` and `PDV_AltmerCrisisTrack`. | Dragonborn declaration, Sovngarde/Tsun reality, Talos/Thalmor contradiction, Companions/Wuuthrad fork. | Ordinary Skyrim travel, ordinary friendships, normal post-first-crisis Dragonborn identity, generic Nord contact. | Enum/source/record contract: `None = 0`, `Dissonant = 1`, `Questioning = 2`, `Reasserting = 3`, `ScarredResolved = 4`; state-track labels read back; one active crisis at a time. | Fresh Altmer can enter one crisis, see clear copy, resolve or scar it, save/load, and continue net-positive daily devotion. |
| Lorkhan pressure routing | Lorkhan tag/key family and one-time/day/long-cooldown handling by tier. Source scaffold exists through `RouteAltmerLorkhanPressure`, receiver routes, manager intake, `PDV_ACTI_AltmerLorkhanPressureSignal`, and readback-clean QASmoke proof placement. | Authored main-quest, Talos, Thalmor, Sovngarde, Companions, and crisis beats. | Generic combat, generic helping, ordinary settlement play, generic Shor/Nord proximity. | Source assertions that only tagged routes can apply pressure; proof ACTI/REFR readback; rejected-surface tests. | Main-quest Altmer receives meaningful pressure without being punished for normal exploration. |
| Contextual favor families | Shared Auri-El/coherence favor, focused deity families, Thalmor Orthodox, Divine Body, Psijic/Heterodox. Quiet dawn steadiness and marked orthodox costly enforcement now have source handling, manager spell properties, `KYWD`/`MGEF`/`SPEL` records, ACTI proof surfaces, and readback-clean QASmoke proof placement. Remaining families stay open. | Dawn practice, study, magic milestones, records, warding, institutional duty, coherent restraint. | Generic spellcasting spam, raw skill gain without context, generic kindness, generic College membership. | One-active-favor behavior, favor record readback, proof ACTI/REFR readback, focused-family gates, alignment/focus conditions. | Non-edge Altmer receives occasional support from coherent play without constant popups or stacked boons. |
| Exiled vampire cap | Exile-limited cursed flavor and status copy; no full orthodox restoration while cursed. Manager source, three `MESG` records, and manager message properties are wired for vampire entry, cured scar recognition, and werewolf hard halt. | Vampire state, cure, crisis scar, Auri-El rupture handling. | Vampire power as an alternate clean devotion path. | Cursed Altmer blocks or limits full orthodox surfaces; cured path preserves scar note; record readback confirms the three message surfaces. | Vampire Altmer reads as terminal/exile-limited, not as a stronger build. |

**First implementation-safe slice:** the four proof triggers are placed/readback-clean and QASmoke route-runtime proven. Next, build the real gameplay surfaces for rejected-surface assertions, Exiled vampire proof, and first crisis/favor playfeel before adding high-value crisis rewards. A later beta tester should receive a race that already has enough normal-play content to judge pacing, clarity, and immersion.

## P1 - Argonian Hist / People Costing

**Child manifest:** `references/authoring/PDV_Phase20ArgonianImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the manifest/content contract, source scaffold, substrate/posture readback, manager properties, and proof ACTI base records for this lane.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_ArgonianProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-argonian-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Hist substrate skeleton | `PDV_Substrate_ArgonianHist`, `PDV.Substrate.ArgonianHist.*` keys, Hist/People/Void values, dawn decay. Source, record, and QASmoke proof-placement wiring are live. | Water/rest/reflection, Hist sap meditation, safe wetland or chosen refuge. | Generic swimming loops, standing in water forever, ordinary travel, random cave rest. | Key contract; three-day missed-maintenance delay; `-1` per dawn; non-curse floor `20`; `PDV_ACTI_ArgonianHistMaintenanceSignal` route `60` and proof-REFR readback. | Non-assassin Argonian can maintain identity through gentle cadence without chores. |
| People layer | Bed-of-choice cadence, chosen-family support, Windhelm/Riften/community recognition rows. Source and ACTI base proof records exist for People support and bed-of-choice; player-designated anchor support remains later. | Windhelm Assemblage, Riften Docks, named Argonian aid, one chosen community anchor. | Repeating one bed without context, generic inn sleep, generic town visits. | One active bed/community anchor; three qualifying sleeps in 30 days; lapse causes light People decay only; `PDV_ACTI_ArgonianPeopleSupportSignal` route `61` and `PDV_ACTI_ArgonianBedOfChoiceSignal` route `63` readback. | A community Argonian receives visible recognition and status texture. |
| Void / Sithis threshold | Sithis signal counter and Void activation gates. Source and `PDV_ACTI_ArgonianVoidSignal` route `62` are wired; deeper Void rewards wait until Hist/People proof passes. | Dark Brotherhood major beats, curated death/change/void choices. | Generic murder, generic stealth, ordinary kills, one Dark Brotherhood join event as full activation. | Full Void scoring requires at least three significant signals, preferably across separate quest beats/days. | Sithis route is powerful and readable but not the obvious default Argonian build. |
| Hist posture | `PDV_State_ArgonianHistPosture` and curse posture messages. The state track is record-wired and manager-wired; message rows still need content/record promotion. | Vampire, werewolf, cure, prolonged distance, recovery rites. | Curse state silently replacing Hist identity. | Enum/source/record contract: `Normal`, `Distant`, `Strained`, `Silenced`, `Corrupted`; Survey/status readout proves posture. | Vampire grief and werewolf strain are distinct, recoverable where intended, and visible in survey/status. |

**First implementation-safe slice:** source/readback, all four proof base records, and all four QASmoke proof references are route-runtime proven. Next, prove Hist/People normal-play feel before Void expansion: Hist sap, water/rest maintenance, bed-of-choice proof, community recognition, Arkay death-rite reactions, rejected generic hooks, and curse-posture readback.

## P1 - Orc Life-Mode Costing

**Child manifest:** `references/authoring/PDV_Phase20OrcImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the manifest/content contract, source scaffold, life-mode state-track readback, manager property, and four proof ACTI base records for this lane.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-orc-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Life-mode state | `PDV_StateTrack_OrcLifeMode`, `PDV_GLO_OrcLifeMode`, manager `PDV_OrcLifeModeTrack`, and StorageUtil keys for intent, eligibility, last switch, and lockout. Source, record, and QASmoke proof-placement wiring are live. | Blood-Kin, stronghold crisis, completed service, City fallback, player setup choice. | Mode chosen only from MCM without world confirmation, ordinary travel, generic faction membership. | Enum/source/record contract: `City = 0`, `Stronghold = 1`, `LegionExile = 2`; one active scoring lane; state labels, manager property, and proof-REFR read back. | Player can switch modes through credible life evidence and sees the current mode in status. |
| Stronghold lane | Quality forge filters, stronghold aid, Malacath shrine/Volendrung/`The Cursed Tribe`, worthy challenge. `PDV_ACTI_OrcStrongholdForgeSignal` route `70` is wired for first proof. | Blood-Kin, stronghold service, high-value/quality craft, named or quest-worthy challenge. | Raw craft count, generic kill count, generic dungeon clear. | Quality/value/context filters and daily caps; Blood-Kin is context, not a faucet; proof ACTI readback confirms route `70`, Orc origin gate, and daily key. | Stronghold Orc feels rich without becoming the best generic smith/combat loop. |
| City lane | Self-made community support, dignity under pressure, quality labor beyond forge spam. `PDV_ACTI_OrcCityDignitySignal` route `71` and `PDV_ACTI_OrcSelfMadeCommunitySignal` route `73` are wired for first proof. | Named Orc aid, merchant/service completion, protected place, curated dignity moments. | Ambient insult parser, ordinary city presence, raw barter count. | City lane has distinct favor rows and self-made community key/readback; proof ACTI readback confirms routes `71` and `73`, Orc origin gates, and daily keys. | City Orc feels complete rather than failed-Stronghold. |
| Legion / Exile lane | Service milestone gates, private endurance, disciplined completion, return-to-place recognition. `PDV_ACTI_OrcLegionServiceSignal` route `72` is wired for first proof. | Pressure-bearing service completion, curated faction stages, hardship recovery. | Legion faction membership, generic patrol, generic combat. | Service gate requires completed pressure-bearing beat; one active lane only; proof ACTI readback confirms route `72`, Orc origin gate, and daily key. | Legion/Exile Orc has sharp situational rewards without a persistent second substrate. |

**First implementation-safe slice:** state/readback, all four proof base records, and all four QASmoke proof references are route-runtime proven. Next, prove Stronghold, City, Legion/Exile, and self-made community normal-play paths before increasing reward magnitude. Do not ship Stronghold-only Orc parity.

## P1 - Redguard Sect Costing

**Child manifest:** `references/authoring/PDV_Phase20RedguardImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the manifest/content contract, source scaffold, sect state-track readback, manager property, and four proof ACTI base records for this lane.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_RedguardProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-redguard-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Sect state | `PDV_StateTrack_RedguardSect`, `PDV_GLO_RedguardSect`, manager `PDV_RedguardSectTrack`, and StorageUtil sect keys for Crown, Forebear, AshAbah, last signal, and reason. Source, record, and QASmoke proof-placement wiring are live. | Crown form, Forebear road/contract, Ash'abah death-duty, setup and world evidence. | Pure menu choice without supporting play, generic combat identity. | Enum/source/record contract: `Crown = 0`, `Forebear = 1`, `AshAbah = 2`; state labels, manager property, and proof-REFR read back. | Player can tell which sect posture is active and why. |
| Far Shores token | Portable/private Tu'whacca devotional surface, home/private bonus, and `PDV_ACTI_RedguardFarShoresTokenSignal` route `83` for first proof. | Hall of the Dead, burial/death rites, private ritual, undead cleansing. | Arkay worship replacement, generic amulet use, generic undead spam. | Token activation, private/home bonus, proof ACTI readback, copy consistently names Tu'whacca. | Death-duty Redguard has a private ritual loop that feels Yokudan, not generic Arkay. |
| Sect favor families | Crown, Forebear, Ash'abah contextual favor rows; first proof ACTIs are wired as `PDV_ACTI_RedguardCrownTombRespectSignal` route `80`, `PDV_ACTI_RedguardForebearRoadSignal` route `81`, and `PDV_ACTI_RedguardAshAbahDeathDutySignal` route `82`. | Honorable form, road dignity, contract success, impurity borne, tomb respect. | Generic gold-making, fast travel, generic body count, broad simulated stigma. | Favor rows/gates; Ash'abah entry requires major death/undead/tomb/funerary/impurity burden; proof ACTI readback confirms Redguard origin gates and daily keys. | Crown, Forebear, and Ash'abah each compete emotionally with undead-clearing. |
| HoonDing cap | Rare make-way marker, weekly cap, curated major milestones. | Major impossible-odds, named bosses, quest stages, proof-tested odds detection if later added. | Generic combat, ordinary kill streaks, farmable dungeon loops. | Weekly cap and curated source list. | HoonDing feels dramatic and rare, not a damage buff economy. |

**First implementation-safe slice:** state/readback, all four proof base records, and all four QASmoke proof references are route-runtime proven. Next, prove Crown tomb respect, Forebear road passage, Ash'abah death duty, Far Shores token use, rejected generic hooks, and status/survey readout in normal play before increasing death-duty reward magnitude. Add Ash'abah stigma surfacing before increasing undead/death-duty rewards.

## P1 - Bosmer Non-Hunter Parity Costing

**Child manifest:** `references/authoring/PDV_Phase20BosmerNonHunterImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the manifest/content contract, source scaffold, and eight proof ACTI base records for this lane.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_BosmerProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-bosmer-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Formal favor table | Path-specific favor rows for Old Contract, Living Story, Exchange, Bandit Road. Source and ACTI base records are wired for eight proof families. | Existing `PDV_State_BosmerPath`, route messages, path switch proof, Y'ffre ledger. | One generic Bosmer favor shared by all paths. | Eight proof ACTIs read back with route IDs `100-107`, Bosmer origin gates, source IDs, and daily keys. | Non-hunter Bosmer receives comparable attention and reward cadence. |
| Living Story | Preservation, community, oral memory, mercy/restraint, Kynareth proxy where appropriate. Routes `102-103` cover community kept and nature site proof. | Curated community aid, saved life, memorial/story beats, non-destructive nature practice. | Generic kindness, generic bard activity, generic forest travel. | Living Story rows exist and avoid Green Pact compliance as the only payoff. | Story-carrier Bosmer feels as supported as Old Contract hunter. |
| Exchange | Debt, proportional justice, bargain, restitution, Z'en distinction. Routes `104-105` cover debt settled and proportionate redress. | Contract completion, restitution, proportionate reprisal, honest debt settlement. | Generic trade profit, random vengeance, raw theft. | Exchange rows/gates distinguish Z'en from Zenithar and reject generic commerce. | Exchange Bosmer gets clear moral-economy feedback. |
| Bandit Road | Pariah survival, luck, Baan Dar edge, road/community outsider beats. Routes `106-107` cover road life and rare reversal, with a seven-day major-favor cooldown for reversal. | Road hardship, near-death luck, outcast aid, difficult escape. | Generic crime, repeated theft, random banditry. | Anti-repeat and context gates; Baan Dar/Road rows stay distinct. | Bandit Road feels sly and costly, not a generic thief buff. |
| Green Pact tag layer | Item/food/body handling tag plan and compliance proof gates. | CK/tagged items, hunted meat, plant taboo, curated violation surfaces. | Broad plant detection without reliable item evidence. | Tag coverage report and rejected-item tests. | Pact feedback is concrete and fair, not arbitrary inventory punishment. |

**First implementation-safe slice:** source/readback, all eight proof base records, and all eight QASmoke proof references are route-runtime proven. Next, prove Old Contract, Living Story, Exchange, Bandit Road, rejected generic hooks, and status/survey readout in normal play before expanding Green Pact item tagging.

## P1 - Khajiit Lunar / Road Costing

**Child manifest:** `references/authoring/PDV_Phase20KhajiitImplementationCosting.manifest.json`
**Verifier gate:** `node .\tools\pdv_verify.mjs --strict-phase20-race-costing` validates the manifest/content contract, source scaffold, lunar substrate/focus mirror readback, manager properties, and six proof ACTI base records for this lane.
**Proof/runtime runbook:** `references/authoring/PDV_Phase20_KhajiitProofPlacement_Runbook.md`
**Placement readback:** `dotnet run --project .\tools\pdv-phase20-khajiit-author -- --check-placements`

| Work Item | Build Artifacts | Hook Sources | Rejected Hooks | Verifier / Readback | Runtime Proof |
|---|---|---|---|---|---|
| Moon cadence | `PDV_Substrate_KhajiitLunar`, fallback 28-day clock, optional real moon read if proven reliable, and `PDV_ACTI_KhajiitMoonObservanceSignal` route `10`. Source, record, and QASmoke proof-placement wiring are live. | Sleep/load/dawn, Masser/Secunda if stable, fallback calendar. | Required visual moon inspection, fragile weather/sky dependency, moon-sugar use. | Source chooses fallback safely; phase bonus is small and not required for baseline play; proof ACTI/REFR readback confirms Khajiit origin gate and daily key. | Khajiit gets moon texture without scheduling chores. |
| Focused emphasis | `PDV_GLO_KhajiitFocusedEmphasis`, StorageUtil focus weights, and silent focus gates. Source now exposes all five weights in summary readback. | Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh behavior families. | Manual focus selection as entitlement, generic crime, generic combat. | Enum/source/record contract: `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, `Alkosh = 5`; threshold `50` piety and `15` lead; mirror global and manager property read back. | Focus emerges from play and can change without the player feeling tricked. |
| Road homes | Two anchor proof ACTIs, road-home last-anchor storage, circuit cadence, caravan/community status. `PDV_ACTI_KhajiitRoadHomeAnchorOneSignal` and `PDV_ACTI_KhajiitRoadHomeAnchorTwoSignal` route `33` are wired. | Sleep at varied homes, road travel, caravan aid, open sky. | Repeating one bed, fast travel loop, generic inn sleep. | Road-home cadence requires cycling; immediate same-anchor repeats are rejected through `PDV.Khajiit.RoadHome.LastAnchor`; one location alone does not count. | Road Khajiit feels rooted by movement, not punished by travel requirements. |
| Five-focus parity | Favor rows for Khenarthi, Azurah, Baan Dar, Rajhin, Alkosh. Baan Dar, Rajhin, and Alkosh now have proof ACTIs on routes `90-92`. | Wind/road, twilight/threshold, survival trickery, artful theft, rare dragon/order beats. | Khenarthi/Azurah crowding every playstyle, Rajhin generic theft, Alkosh generic dragon kill spam. | Each focus has attractive launch hooks and rejected-surface tests; proof ACTI readback confirms routes `90-92`, Khajiit origin gates, and daily keys. | Baan Dar, Rajhin, and Alkosh are viable without copying Khenarthi/Azurah. |
| ShadowDrift boundary | Lunar posture and curse/Nocturnal pressure rows. | Curse state, Nocturnal/Nightingale pressure, moon disconnection. | ShadowDrift as free stealth reward. | `PDV_State_KhajiitLunarPosture`: `Normal = 0`, `Strained = 1`, `Corrupted = 2`, `ShadowDrift = 3`. | Curse/Nocturnal edge remains priced and native lattice remains visible. |

**First implementation-safe slice:** source/readback, all six proof base records, and all six QASmoke proof references are route-runtime proven. Next, prove moon fallback, two-anchor road-home anti-chore behavior, Baan Dar/Rajhin/Alkosh focus movement, rejected generic hooks, and status/survey readout in normal play before adding high-value focus favors.

## P2 - Stack And Ceiling Control

| Race | Control Needed | First Gate |
|---|---|---|
| Breton | Three tradition tracks must not become three simultaneous reward engines. | Tradition state/readback, one active favor family, Hidden Art cost visible before stronger occult rewards. |
| Dunmer | Ancestor substrate plus Reclamation focus plus deviations can overstack. | Ancestor substrate mostly interpretive/utility; focused Reclamation is the loud reward layer; deviations carry price. |
| Imperial | Civic/Concordat hooks must stay concrete. | Whitelisted civic acts, public/private Talos tests, rejected faction-attendance tests. |
| Nord | Hook density needs ceilings. | Broad worship softer than focused patron, Kyne/Talos contrast proof, Hircine stack checks, rejected generic kill/travel tests. |

## Required Output Before Building A Race Slice

Each slice should produce this block in its phase plan or manifest. The expanded
pre-beta version lives in `PDV_PreBetaRaceScalingSpine.md`.

```text
Race:
Slice:
Player fantasy protected:
Primary state/record artifacts:
Hook sources:
Rejected hooks:
Immersion proof:
Reward ceiling:
Reward floor:
Player-facing surfacing:
Verifier/readback gate:
Runtime proof route:
Compatibility notes:
```

For pre-beta scaling, also record:

```text
Lane type:
Scaling role:
Normal-play hook:
Survey/status readout:
Final placement:
Stack snapshot:
Manual feel note:
Content dependency:
Rubric verdict:
```

## Immediate Queue

1. Altmer active spine: promote the crisis/favor/Lorkhan scaffold and wired curse-message surface into real normal-play hooks, rejected-surface proof, Exiled vampire proof, remaining favor families, first crisis playfeel proof, Survey/status evidence, and final placement planning.
2. Khajiit first contrast: prove moon fallback, two-anchor road-home anti-chore behavior, Baan Dar/Rajhin/Alkosh focus movement, rejected generic hooks, Survey/status readout, and final placement planning before strong focus favors.
3. Argonian second contrast: build enough Hist/People state, bed cadence, community, Arkay/death-rite reaction, curse posture, rejected generic hooks, and three-signal Void threshold behavior that non-Sithis play can be judged before deeper Void runtime rewards.
4. Orc P1 packet: prepare Stronghold forge, City dignity, Legion service, self-made community, rejected generic hooks, status/survey readout, and final placement requirements before increasing Malacath reward magnitude.
5. Redguard P1 packet: prepare Crown tomb respect, Forebear road passage, Ash'abah death duty, Far Shores token use, HoonDing cap, rejected generic hooks, status/survey readout, and final placement requirements before expanding death-duty rewards.
6. Bosmer P1 packet: prepare Old Contract, Living Story, Exchange, Bandit Road, rejected generic hooks, status/survey readout, and final placement requirements before broader Green Pact tag work.
7. P2 stack/ceiling pass: audit Breton, Dunmer, Imperial, and Nord in normal play for over-stacking, over-triggering, Survey/status clarity, generic rejected hooks, expected/edge builds, and reward ceiling issues before adding more reward volume.

Parallel planning note: broad Daedric Prince authoring is not part of this
pre-beta race-scaling queue. The former CAT-4 blockers - stigma row model,
Hircine/Molag Bal curse-access template, and Prince authoring order - are now
resolved by Section 11.6 **D-15/D-16/D-17** (rationale:
`references/authoring/PDV_Daedric_DecisionPacket_CAT4.md`), and D-18 defines
per-Prince content-ready. CAT-4 prose may now be authored/promoted against
those locks on its own track; it still does not belong inside a pre-beta race
runtime slice. Section 11.6 roster shape, recovery default, and cross-Prince
hostility (D-12/D-13/D-14) remain locked defaults, not open blockers.

Separate scale gates:

- Recognition/dialogue should remain packet-draft only until
  `PDV_RecognitionDialogueScalePacket.md` proves one non-Nord CK-authored
  recognition line through readback and runtime positive/negative proof.
- CAT-6 string promotion should remain narrow until
  `PDV_CAT6PromotionPilot.md` proves one low-risk non-dialogue draft row
  through ratification, ESP promotion, verifier/readback, runtime or menu
  display, and handbook sync.
