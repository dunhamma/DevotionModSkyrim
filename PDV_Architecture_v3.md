# PDV Architecture v3 - Forward Plan

Last revised: 2026-08-15 AEST (Slice 1 bounded Quest Reaction ingress repair)
Status: **V3 Preflight complete. V3 Structural Skeleton complete. V3 Pattern Proving normal-play ingress closeout complete. Phase 7 is fully closed. Phase 8 Imperial-first reputation track closeout is fully runtime-proven. Phase 9 Bosmer path closeout is fully runtime-proven. Phase 10 Dunmer ancestor substrate proof-graduation is runtime-proven. Phase 13 Hircine/Nord Daedric pilot, Khajiit focused emphasis, Phase 14 formal commitment, Phase 15 shared curse-state handling, Phase 16 generic neglect selection, Phase 17 decay, Phase 18A/B player status/Nord pilot, Phase 19 live generated patch closeout, the Phase 11 Arngeir/Kynareth privilege pilot, and the Phase 12 contextual favor pilot are proven/closed at their required gates. Phase 20 now owns the full-roster 1.0 content target: every locked race-architecture god and all sixteen Skyrim-present Daedric Prince surfaces must be content-ready for every race, with `references/authoring/PDV_DeityCoverageMatrix.json` and `--strict-phase20-roster` as the roster authority gate. The first Altmer Phase 20 runtime lane is source-scaffolded, compile-verified, crisis-record-wired, has the first two Altmer favor spell records wired, has four Altmer ACTI trigger proof base records wired for crisis, Lorkhan pressure, dawn steadiness, and orthodox cost, and now has Altmer Exiled vampire / werewolf halt manager source plus three `MESG` records wired to `PDV__ManagerQuest`; its four QASmoke proof references read back cleanly. Argonian, Orc, Redguard, Bosmer, and Khajiit have also crossed into source/record-wired proof slices, and all 30 Phase 20 proof references are now QASmoke-placed with helper/readback proof. Runtime proof and final immersive world placement remain open; `tools/pdv_phase20_runtime_check.mjs` and `references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` define the counted route-log, Survey/status, immersion, negative-hook, and anti-farm proof lane. `references/authoring/PDV_PreBetaRaceScalingSpine.md` and `PDV_PreBetaRaceGateLedger.md` now define the internal pre-beta scaling spine and all-race evidence ledger: Altmer active spine, Khajiit first contrast, Argonian second contrast, Orc / Redguard / Bosmer P1 packets, and Breton / Dunmer / Imperial / Nord P2 audit-only packets. The race gameplay audit now treats immersion as an explicit reward-budget axis, and `--strict-phase20-race-costing` enforces `immersionProof` blocks for all Phase 20 race-costing manifests. The current Phase 20 Altmer/race-costing gate is clean again after content-lock row reconciliation; the remaining warning is the existing unnamed CK-authored INFO record class. Phase 21 is the Authoria-first compatibility package lane because compatibility testing must wait until the mod's full content surface is stable enough to test against modlists.** v2 (Phases 0-6) is closed. Preflight script/tooling, framework record wiring, strict verifier gate, and clean-start smoke are complete. The broad dev-only structural scaffold is now merged, strict-verifier clean, and runtime-smoked. Pattern Proving now has live Imperial/Khajiit proof plus Slice 1 runtime proof for Dunmer portable/private shrine practice, Bosmer Green Pact violation, and Hircine hunt rite through normal-play receiver records. Phase 7 now has counted runtime proof for PO3 shout ingress, manager/EventBus shout routing, deity-side shout anti-farm guards, the hidden Talos shrine reference contract, and the final Civil War compliance/defiance one-shot hooks. Phase 8 now has counted runtime proof for committed-state lock-in, extreme-band gate behavior, committed-state multiplier composition, and save/load persistence on the ConcordatStanding pilot. Phase 9 runtime proof covered setup, all five proof-surface routes, path offers, confirmation-rite switching, Old Contract re-entry, PactBound/compliance separation, forced reckoning `Renounce`, forced reckoning `Recommit`, and save/load persistence, with the full strict gate clean at `PASS=808, WARN=0, FAIL=0, INFO=28`. Phase 10 runtime proof covered a fresh Dunmer baseline, private/home shrine route `31`, portable shrine route `30`, substrate-only movement to `DunmerAncestor=metric=13.000000; tier=1; prayers=1; homes=1`, patron-piety separation, save/load persistence, and a clean strict Phase 10 gate at `PASS=847, WARN=0, FAIL=0, INFO=28`; the next-packet helper later repaired portable/private cooldown-key drift and strict Phase 10 now checks distinct keys. Phase 13 runtime proof now covers the Hircine negative gate before commitment-signal day three, Seeker and Devoted price activation on the multi-day rite cadence, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path. The Khajiit runtime proof still covers Khenarthi then Azurah focus with save/load persistence. Phase 14 runtime proof now also covers Kyne offer seed/evaluate, the historical Not Yet / Refuse / Accept branches, and accepted-patron persistence; current source supersedes the old 7/14-day reoffer cooldown with one offer per qualification, lapse-and-rebuild reoffer, and per-deity terminal refusal. Phase 15 runtime proof now covers the shared werewolf/vampire/none curse seam plus live Hircine curse-entry and werewolf-cure traces. Phase 16 runtime proof now covers active-Kyne low-piety neglect selection, Kyne neglect-spell application, and broad-worship suppression clearing the active neglect set on re-evaluation. Phase 17 runtime proof now covers grace, eligible decay, same-day guard, broad-worship reduced decay, active-patron skip, non-patron drift, and Devoted/Champion floors. Phase 18 runtime proof now covers the Player page, Developer Options persistence, Survey broad/focused states, Hircine/werewolf tension, vampire suppression/cure scar, save/load persistence, and positive/negative dialogue availability for Froki, Heimskr, Andurs, and Aela. The current combined Phase 18/Nord/Phase 19 strict gate is clean at `PASS=1208, INFO=28`, with no `FAIL`, `WARN`, or `TODO`. Authoring infrastructure has one proof-ledger-supported CKPE creation surface, `glob.duplicate_create`, a reusable dialogue-v1 manifest/readback proof lane for CK-authored dialogue scaffolding, and an active generated classification patch for approved core vanilla/DLC rules; this does not broaden generated dialogue or generic gameplay authoring support.

Ground-up rebuild status: **Slice 1A Quest Reaction authority and compile
inventory are complete. Slice 1B now has executable deterministic fixtures for
all eight named behavior cases, the queue/catalog/scheduler implementation is
owned by `PDV_QuestReactionRuntime`, and direct houseCARL readback confirms the
existing `0716DF:Devotion.esp` host was repurposed with no new quest or script
instance. The five touched scripts compile with zero errors/warnings. The
fresh-game queue, mid-job save/load, FIFO, duplicate-free Book surface,
four-toast, and selected-lane eligibility canaries pass. Slice 1C-A now has a
deterministic, exact-byte-checked v2 compiler and one 80-source compatibility
authority. Runtime now consumes v2, and the AFDI semantic adapter is compiled,
rewired, and read back without its source-mod master. Slice 1D-B package
consolidation is backend-green with one required official catalog and five
dependency-detected adapters. The combined fresh-game and Authoria smoke remains
open Slice 1 work. The PapyrusUtil wire-admission defect is repaired and the
installed Anvil profile preflight is green. The separate bounded-ingress fix is
backend/static/compile and runtime-route green, including sub-second organic
admission and build-stage save/load continuation; its counted manual player-
surface confirmation remains open.**

Current v3.103 addendum: **1.0.4 is shipped and public** (2026-07-27, tag `v1.0.4`,
`Devotion-1.0.4-20260727.zip`), the first public build since 1.0.2 and the first carrying
the unreleased 1.0.3. Three architecture contracts moved:

1. **The `Recover` flag is a project-wide MGEF invariant, not a Daedric-family
   convention.** Any Devotion MGEF whose archetype modifies an actor value must carry
   `Recover`, because Devotion applies its effect families as toggled abilities and the
   engine otherwise bakes the change in permanently. Shipped-ESP readback is `627/627`
   (ValueModifier `395/395`, PeakValueModifier `232/232`). Authority for the rule is the
   2026-07-27 `AGENTS.md` Decisions Log entry; `pdv_verify.mjs` owns the regression guard
   for the Daedric price family specifically. Proof bucket: RELEASE READBACK across all
   627; MANUAL revert proof still covers only the representative Azura / Mephala /
   Hermaeus Mora tiers from 2026-07-26.

2. **The shrine-neutralization boundary is amended.** Devotion now ships a loose-file
   `Scripts\TempleBlessingScript.pex` override so praying stops dispelling the player's
   active effects under Requiem's bugfix packs. The ESP-record half of the old boundary
   holds unchanged (no shrine `ACTI` override, no script-property replacement); the
   "Devotion does not replace shrine activator scripts" wording in the 2026-06-14 /
   2026-06-21 entries and in `PDV_MOD_SETUP.md` is superseded. This introduces the
   project's first hard MO2 *priority* requirement: Devotion must sit below any Requiem
   bugfix pack, and the failure mode is silent.

3. **Runtime cost is now an explicit ship gate.** The 1.0.4 pass resolves reaction data
   once per save load instead of per equip check, pre-filters scorable events per deity,
   collapses the 44-pass text formatter, and quiets background polling. **Architectural
   risk, OPEN:** that source is not on `main` - it lives on the unmerged branch
   `codex/pdv-ship-optimization` together with `pdv_ship_optimization_audit.mjs` and
   `pdv_player_events_optimization_audit.mjs`, so neither the optimization contract nor
   its gates are on the trunk that the rest of these docs describe. Until that branch
   merges, `main` cannot rebuild the shipped build. Tracked in `AGENTS.md` Current Build
   Status as `[!] SHIPPED-VS-REPO SOURCE DRIFT`.

Phase 20 / Phase 21 status is unchanged by the release: 1.0.4 is a defect-and-cost build,
not a content build, so the open Phase 20 runtime/placement lane and the Phase 21
Authoria-first compatibility lane below still stand as written.

Current v3.100 addendum: the 2026-07-14 bug-report cluster is adjudicated and its
fix pass EXECUTED (authority: Part D of
`handoff/PDV_TierNameDrift_BugReport_2026-07-14.md`; execution:
`references/authoring/PDV_HO_ScopedManagerPass_2026-07-15.md`). The curated-signal
ledger is decided end-to-end: 21 signals cut (phrase/branch/const removed, DELTA
floats retained for save safety), 8 wired organically (Tu'whacca vampire re-entry,
Magnus/Xarxes active-patron heritage-memory dawn pulse, Trinimac orthodox pressure,
Leki honorable duel, Tsun near-fatal adversity, Talos MS09 rescue, Malacath exile
return; combat sessions widened to Nord/Redguard), 8 reserved wire-later (Syrabane
BC-0153, Stuhn pair, Trinimac orthodoxy). The Altmer crisis has both exits
(evidence-gated reassertion and heterodox acceptance); the Orc stronghold forge is
an organic earn; the ThalmorAlignment track gains its only positive mover
(orthodox_rite +2/day); Akatosh's Endurance is re-authored (Maximum Health +30 +
Magic Resist +15) at the Imperial AND Breton layers; HearthHeld is a granted flat
Fortify Stamina +15. Broad-band vocabulary (Distant/Observant/Faithful) now governs
ALL broad-lane reward records including Dunmer Reclamation. Gate posture: every
machine gate is green -- dispatch coverage 102/94/8/8, naming audit 241/392/0,
strict Phase 18/Nord 0 FAIL / 4142 PASS (dialogue quartet + spine contracts
descoped to assert-ABSENT guards per owner sign-off), remap adversary PASS/0
(hidden-art assert refreshed to the GetBretonChampionSource shape). Proof boundary:
all of the above is source/record/readback; the runtime half is the RC1 + RC7-RC15
cards in the co-test runbook, owed alongside PS-A1..A12. Khajiit Champion signature
moments are post-1.0 by owner ruling (V2 backlog).

Current v3.97 addendum: Breton Hidden Art is a narrow layered-pact exception to
the global Prince-wins display rule. For a Breton actively walking Hidden Art,
Hircine, Hermaeus Mora, Namira, and Nocturnal remain global Daedric paths, but
Survey and Book of Days preserve the Breton tradition/practice/exposure base and
append the active Prince. `WitchcraftExposure` plus authored Vigilant pressure is
the sole lane cost, so the generic Prince price and per-Prince stigma are waived;
Notorious exposure keeps practice/rewards active and grants the locked 1.25 pact
gain multiplier. Same-pact refresh is idempotent and any non-waived maximum-pool
price preserves current Health, Magicka, and Stamina when first applied. A
same-family Champion T3 is an absolute cumulative total and replaces its T2
spell; distinct patron/Prince families may remain beside it. The compiler must
reject tracked/deployed source drift before building live PEX files so source
sync cannot silently occur after compilation.

Current v3.98 addendum: `references/authoring/PDV_SubstratePacingContracts.json`
and `PDV_BroadPantheonContracts.json` supersede earlier route-specific substrate
magnitudes, civic-count broad rewards, the partial Nord Nine Divines resolver,
Khajiit road-home circuits, and the Argonian weighted composite/Hist Communion
stack. Imperial, Dunmer, Argonian, Nord, Altmer, and Khajiit now share an
origin-specific first-authentic-act-per-devotional-day substrate credit of `+4`,
with thresholds `1/25/75`, a positive cap of `75`, and a 06:00 day boundary.
Imperial Divines, Nord Old Ways, and Nord Nine Divines use manager-owned broad
pantheon pools, never aggregate deity records. One logical devotional act adds
only its strongest applied eligible positive delta, or its most severe eligible
negative delta when no positive exists. The two Nord baselines mirror thresholds,
decay, patron transition, and T2 cap while retaining distinct rosters and reward
families. These are locked design contracts pending source, record, runtime, and
manual proof; older packet evidence proves only the superseded implementation.

Current Pantheon/substrate proof update: the contracts are implemented and closed at
authority, source, compile, static, and direct-record-readback layers. The live
manager owns the three pools, the shared substrate day-credit path, migrations,
focused T2/T3 transition, Argonian cultural separation, and Observe the Moons.
Direct houseCARL refutation proves exact approved P2 FormList membership, manager
and alias VMAD bindings, the parent-boon/child-mechanic Active Effects naming
convention, the six active substrate records, broad reward packets, and the
ordered lunar message packet. The local default verifier reports `4145 PASS /
79 INFO / 1 known WARN / 0 FAIL`, including the 392-effect naming audit. This
supersedes the preceding "pending source and record" wording only. Organic
ingress, save/load, player-visible boundaries, and feel remain open under
PS-A1 through PS-A12 and cannot be inferred from machine/readback proof.

Focused 2026-07-14 runtime/manual addendum: the tester confirmed that Survey
Devotion and Observe the Moons both select from Magic > Powers without a
left/right-hand prompt, replace one another in the shared Power slot, preserve
the equipped hand loadout, and fire from the normal Power/Shout key. Observe
the Moons completed its two-second rite and delivered the non-blocking Prisma
contemplation; the first valid daily rite also appeared in the Book of Days.
This closes the focused power-selection, Prisma presentation, and journal-entry
defect. PS-A1 through PS-A12 remain governed by the structured co-test ledger.

Current v3.96 addendum: the signal-floor readback/faucet tranche has landed at
source/compile/readback level. `tools/pdv_extract_quest_stage_readback.mjs` now
pins the missing exact-source quest readbacks for MS01/MS02/DBDestroy, Purity,
Totems, MS10, MS05, T01/t02, marriage, mine-favor, and T03 rows, producing 778
quest-stage readback rows and a quest-reaction runtime matrix of 1978 cells /
172 quest keys / 134 watched quests / 45 deity names. Part D has 26 compiled faucet acts:
Sanguine skooma/Sleeping Tree Sap and Sheogorath Wabbajack staff-fire are routed
in `PDV_PlayerEvents`, with compiler cap aliases preserving the shared alcohol
and carry-Wabbajack daily caps. `argonian_people` is registry-marked expected-N/A
for a separate People deity lane because credit routes to the Hist by design.
The generalized undead-crypt clear signal is source/readback clean and the
`PDV_FLST_UndeadCryptClearSites` manager property points at populated FormList
`07165E:Devotion.esp`. The Paarthurnax KILL fork is now global and one-shot
through `PDV_PlayerEvents.IsPaarthurnaxActor` -> `PDV_EventBus.RoutePaarthurnaxKill`
-> `PDV__ManagerQuest.HandlePaarthurnaxKill`, with Shor/Tsun/Kyne/Stendarr/Stuhn/Mara
loss fan-out sent through existing stance/reachability rules and the existing
Khajiit Alkosh consequence preserved. The Paarthurnax SPARE branch is also
source-wired for V1: `MQ305` stage 200 and load-time catchup check
`Paarthurnax.GetDeadCount() == 0`, then route Stuhn/Stendarr/Mara/Kyne mercy
gains through the same one-shot and stance/reachability rules.
Proof boundary is source/readback/compile/static only: `PDV_PlayerEvents`
compiles 0/0, `pdv_quest_matrix_compile --papyrusutil-check` passes,
`pdv_verify` has `FAIL=0` with only the existing medallion glyph fallback
warning, and the signal-floor adversary check passes with only the known
thin-Hist warning. In-game staff-fire, skooma, crypt-clear, plant consumption,
Paarthurnax, route-display, and manual feel proof remains open.

Current v3.93 addendum: the Redguard ancestral-spine route now feeds Tu'whacca
piety as well as sect telemetry: `PDV_Deity_Tuwhacca` owns
`SIGNAL_ANCESTOR_SPINE`, and `PDV__ManagerQuest.HandleRedguardAncestorSpine`
awards it through the scaled curated-signal path. The design-first thin-Prince
artifact faucet slice is also wired at machine/readback level for Molag Bal,
Hircine, Meridia, Sheogorath, Mehrunes Dagon, and Nocturnal through
`PDV_PlayerEvents.OnObjectEquipped`, JSON faucet keys, and six
`PDV_FLST_Faucet_*_Artifact` FormLists authored by
`tools/pdv-prince-faucet-author`. Part D now has 26 compiled faucet acts. The target
Prince floor rows now have `faucet|quest-reaction` coverage, but runtime equip
smoke, wrong-origin silence, Survey/status feel, and the broader
quest-reaction runtime proof remain open.

Current v3.92 addendum: the Nord startup gate is now explicit instead of relying
on implicit baseline drift: Old Ways button index 0, Nine Divines button index 1,
`PDV_State_NordPantheonBaseline`, `PDV.Nord.SetupComplete`, broad worship, and
immediate reward sync are wired in `Devotion.esp` and live `PDV__ManagerQuest`.
The Requiem-tail closeout is also folded into `Devotion.esp`: Shor and HoonDing
Champion hidden low-health saves, HoonDing named-boss FormList, Redguard
Necromancer/Warlock faction burden, Ash'abah clearable-undead-site burden, and
Namira passive-zero/Health+Stamina feed copy. Proof is compile/readback only;
runtime/manual Nord, Redguard, HoonDing, Shor, and Namira checks remain open.

Current v3.94 addendum: the deity signal remap source/readback tranche is landed.
The quest-reaction matrix now has 1978 cells / 172 quest keys / 134 watched quests / 45 deity names
after `PDV_QuestReactionMatrix_Tranche9_DeitySignalRemap.csv`; Syrabane is an
Altmer roster-visible focus with eight approved College/warding/plague/hostile
magic rows, Altmer Syrabane/Trinimac and Breton active-tradition formal offers
are eligible at source/readback level, shrine prayer is capped one resolved
deity per day, and the remap adversary checker guards the high-risk regressions.
Proof boundary remains source/readback/static only until the remap in-game smoke
runbook proves route firing, Active Effects, Book of Days, Survey/status,
Prisma/notification, save/load stack, and adversary behavior.

Current v3.91 addendum: the **quest-reaction matrix subsystem** is now designed and
frozen as checked-in data (new Section 5.8). It is a curated one-time table of vanilla/DLC
quest-outcome -> per-deity piety reactions (gain/loss, small/milestone) plus thin-god
repeatable faucets, modulated by race-stance at wiring time. Artifacts:
`references/authoring/PDV_QuestReactionMatrix.md` (Parts A-E), `..._Full.csv`
(now 1978 cells / 172 quest keys / 134 watched quests / 45 deity names, GENERATED from tranches via
`tools/pdv_quest_tranche_merge.mjs`), `..._PartD_ThinGodFaucets.csv` (26 compiled
faucet acts after the design-first Prince artifact/use faucets), and the Codex handoff
`..._WiringSpec.md`. Calibration is LOCKED (counts frozen; pacing
tuned later via milestone VALUE, because piety is per-god so the cross-god fan-out never
over-feeds one god). Detection reuses the proven PO3 `RegisterForQuestStage` path in
`PDV_PlayerEvents`; resolution + race-stance modulation (Part C2) is a new
`PDV__ManagerQuest.ApplyDeityReaction` award. Design frozen; core source/readback
matrix wiring is live, while runtime-route/manual proof remains open. The six design-first Prince artifact faucets
are a narrow equip-event implementation with compile/readback proof, not full
matrix runtime proof.

Current v3.90 addendum: `references/authoring/PDV_DaedricPrinceRecordContracts.json`
and `tools/pdv-daedric-author` now own the all-sixteen-Prince Daedric CAT-6
record/readback gate. The generated contract derives from the Daedric content
manifest and race/Prince matrix, creates/reads back QUST, SPEL, MGEF, MESG,
stigma global, state-array, stigma-modifier, exit-difficulty, concrete path
VMAD wiring, and `PDV_FLST_DaedricPaths_All` membership for every
Skyrim-present Prince. Every quest attaches exactly one concrete
`PDV_DaedricPath_<Prince>` script; inherited `PDV_DaedricPathBase` behavior and
properties live on that concrete instance, and the base script must never be
co-attached. All sixteen concrete scripts compile, including the earlier
Hircine pilot. The same author now also creates/checks route-200 QASmoke sender refs for
all 16 Princes and route-201 `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`, so
the controlled in-game proof surface is physically placed and readback-clean.
It also creates/checks exact organic quest-stage FormLists for all sixteen
Princes: Boethiah `DA02` 100, Azura `DA01` 100, Vaermina `DA16` 190,
Meridia `DA09` 500, Molag Bal `DA10` 200, Mephala `DA08` 60, Malacath `DA06`
200, Dagon `DA07` 100, Sheogorath `DA15` 200, Namira `DA11` 100, Sanguine
`DA14` 200, Clavicus Vile `DA03` 200, Hermaeus Mora `DA04` 100, Nocturnal
`TG09` 200, Peryite `DA13` 100, and Hircine `DA05` 100, all wired on the
`PDV_PlayerEvents` alias.
This closes the automated record/readback and controlled-sender placement
blockers only, plus all organic sender placement/readback blockers. Counted
in-game display proof, runtime proof for those exact live senders,
wrong/generic source silence, stack/Survey legibility, and deeper curse-access
proof for Hircine/Molag Bal remain required before calling any Prince
beta-display ready. `tools/pdv_daedric_test_readiness.mjs --deep` is the
preflight gate for launching that proof path; `PDV_DaedricInGameSmokePacket.md`
is the generated tester packet; `tools/pdv_daedric_evidence_intake.mjs` records
counted route/display evidence into `PDV_DaedricRuntimeEvidenceLedger.json`; and
`tools/pdv_daedric_beta_gate.mjs` fails closed until every required Prince proof
slot passes.

Current v3.71 addendum: `references/authoring/PDV_PreBetaRaceScalingSpine.md`
now owns the internal scaling gate between QASmoke route proof and external
beta readiness, while `references/authoring/PDV_PreBetaRaceAcceptanceRubric.md`
owns the measurable pass/conditional/fail bar. The chosen order is Altmer
active spine, Khajiit first contrast, Argonian second contrast, Orc / Redguard /
Bosmer P1 packets, and Breton / Dunmer / Imperial / Nord P2 audit-only packets.
The shared gate requires normal-play hooks, rejected generic hooks,
Survey/status readout, final placement, reward ceiling/floor, stack snapshot,
runtime proof command, and manual feel notes before stronger rewards or
external tester judgment. Two additional architecture packets now hold content
scale risks: `references/authoring/PDV_RecognitionDialogueScalePacket.md` for
planned V2 CK-safe recognition/dialogue scaling and
`references/authoring/PDV_CAT6PromotionPilot.md` for the first low-risk
draft-to-ESP-to-handbook promotion proof.

Current v3.72 addendum: the content decision workshop ratified the immediate
pre-beta handoff defaults. Altmer's third crisis beat is `MarriageBeat`, not
Talos/Thalmor contradiction; the current Altmer proof rewards map dawn
steadiness to `PDV_Notif_Altmer_FavorNoted_DivineBody_DawnObservance` and
orthodox cost to
`PDV_Msg_Altmer_FavorMarked_ThalmorOrthodox_ProjectDefended`. Survey/status
copy for Altmer, Khajiit, Argonian, and Bosmer should read as immersive
religious state, not diagnostic counters. First final-world placement concepts
are Altmer dawn/study/crisis, Khajiit road-home/moon/caravan, and Argonian
Hist/People/water/community. Runil is retained only as planned V2 prep for
Altmer Auri-El crisis/recovery recognition; V1 uses Survey/status or another
non-voiced fallback. The first CAT-6 pilot is
`PDV_Bless_Khajiit_Lunar_T1`; `PDV_Bless_Bosmer_Exchange_T1` is fallback only
if the Khajiit target record path is blocked. Daedric content can remain
drafted while race hook validation continues; D-15..D-18 now lock the stigma,
curse-access, authoring-order, and content-ready contracts. The 2026-06-07
all-Prince CAT-6 pass closes per-Prince record/readback proof, while final
beta-display claims still wait for controlled in-game display proof, live
sender proof, stack/Survey legibility, and curse-access runtime evidence.

Current v3.73 addendum:
`references/authoring/PDV_PreBetaRaceGateLedger.md` is now the all-race
pre-beta evidence ledger. It records the current `Fail`/internal-only state for
all ten races against normal-session routes, accepted and rejected hooks,
anti-farm rules, Survey/status clarity, final placement, reward floor/ceiling,
stack snapshots, expected/edge builds, and blocking follow-up. The Altmer
costing manifest has been reconciled to the current content-lock row IDs:
`MarriageBeat` replaces the old Talos/Thalmor contradiction row, and the wired
proof rewards map to `DivineBody_DawnObservance` and
`ThalmorOrthodox_ProjectDefended` while preserving the existing legacy record
EditorIDs. Manager source now provides fiction-facing Survey/status branches
for all ten races, including P2 Breton/Dunmer/Imperial audit readouts and less
numeric Argonian/Redguard readouts. `--strict-phase20-race-costing` now checks
the all-race Survey source scaffold, and
`references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md` owns the
manual handoff for wrong-origin, generic-hook, Survey/status, stack snapshot,
and final-placement checks. The strict Phase 20 Altmer/race-costing gate is
restored to green after the merged content lock.

Current v3.74 addendum: the content decision workshop defaults have been
cross-reviewed against the local deity, daily-worship, cursed-worship, and
Daedric reference library plus UESP. The decisions stand, with wording
guardrails. Altmer `MarriageBeat` should be presented as Marriage / Mortal
Continuity: household, lineage, embodied attachment, and continuity inside
Lorkhan's mortal world. It is not anti-Mara and not a claim that Altmer
marriage is invalid. Talos/Thalmor remains lore-valid but stays out of the
current four-row crisis list unless later restored as an explicit additional
row. Khajiit copy and CAT-6 promotion should foreground the Lunar Lattice,
road-home, moon, caravan, and Baan Dar/Rajhin/Alkosh focus while rejecting
moon-sugar, generic theft, or generic night-stealth shortcuts. Argonian copy
keeps Hist primary, People/community and water as support, and Void/Sithis as
pressure or stabilization that never replaces the Hist. Bosmer copy reads
through Y'ffre/Green Pact, Living Story, Exchange/Z'en, and Bandit Road/Baan
Dar without exposing raw path counters. Runil remains the first planned V2
Altmer recognition candidate for mortality, death, scar, and recovery
recognition, not for Orthodox proclamation; V1 uses non-voiced fallback
surfaces. D-15..D-18 now lock the Daedric stigma, curse-access, authoring
order, and content-ready contracts; Daedric final promotion waits on
per-Prince D-18/CAT-6 proof, readback, runtime/display proof, and stack/Survey
legibility.

Current v3.75 addendum:
`references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` now owns the
remaining Phase 20 planning/implementation work that can continue before
additional Skyrim runtime proof, and
`references/authoring/PDV_Phase20_NoInGameProof_Gates.json` is the structured
gate now checked by `--strict-phase20-race-costing`.
`references/authoring/PDV_Phase20_ManualEvidenceLedger.json` is the matching
pending evidence-intake ledger for later wrong-origin, rejected-hook,
Survey/status, final-placement, stack-snapshot, and manual-feel proof. The
packet allows manifest, source, readback/verifier, placement-contract,
stack-audit, Survey/status-copy, CAT-6-prep, recognition-prep, and Daedric
proof-path work, but forbids marking any race `Pass`, claiming final placement,
or broad-promoting rewards/strings without manual/runtime evidence. The
remaining Phase 20 handoff is decision-bound or runtime/manual: holistic
race-effect review, non-voiced recognition fallback selection, manual evidence
capture, and Daedric proof-path closeout.

Current v3.76 addendum: the first CAT-6 promotion pilot is now
record/readback-proven. `tools/pdv-phase20-cat6-author` created/finalized
`PDV_Bless_Khajiit_Lunar_T1` in the framework ESP from the exact race content
manifest row, along with
`PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen` and
`PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist`. Both effects are gated to
7PM-7AM, and the source copy now says "At night" to match the implementation.
The pilot remains grant-unwired and provisional: it proves source-to-record
promotion and readback, not Active Effects runtime display, distribution logic,
or broad reward policy. `references/authoring/PDV_RaceEffectReviewLedger.md`
now owns the holistic race-by-race effect review required before broad reward
authoring.

Current v3.77 addendum: the amazing-goodall branch is reconciled into main.
Daedric decisions **D-15..D-18** are locked in Section 11.6 (stigma model,
curse-access template, authoring order, per-Prince content-ready), which
resolves the Daedric blockers earlier entries left open. The voiced-content
non-goal (Section 21.3) defers all NPC dialogue to V2
(`references/authoring/PDV_V2_Backlog.md`); `PDV_RecognitionDialogueScalePacket.md`
and the dialogue half of `PDV_CAT6PromotionPilot.md` are V2-flagged, not deleted.
The branch broad-reward spec was folded into the per-race rows of
`PDV_RaceEffectReviewLedger.md`, and the branch pre-beta rubric was dropped in
favor of `PDV_PreBetaRaceAcceptanceRubric.md`.

Current v3.80 addendum:
`references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md` is now the
combined beta-feel blocker ledger. It records that beta feel readiness means all
ten playable races plus all sixteen Skyrim-present Daedric Princes, with
Jyggalag excluded. Current automated evidence remains structurally clean
(`pdv_content_verify` at `FAIL=0, WARN=0, PASS=1079, INFO=4`; strict Phase 20
Altmer/race-costing at `PASS=2699, WARN=1, INFO=29`), but runtime/manual proof
still blocks beta readiness. The P2 book checker currently passes Breton Hidden
Art only and fails the remaining filled book families. Daedric D-15..D-18 are
locked, and the all-Prince CAT-6 record/readback gate is now complete, so the
remaining 20C blockers are runtime/display proof, runtime proof for the
all-sixteen exact organic senders, wrong/generic-source silence, stack/Survey
legibility, and deeper Hircine/Molag Bal curse-access checks rather than
unresolved design, missing records, or missing sender placement.

Current v3.81 addendum:
`references/authoring/PDV_DaedricBatch0_D18ProofLedger.md` now owns static
D-18 proof for the first Daedric template batch: Azura / Azurah, Vaermina,
Meridia, and Molag Bal. The Daedric manifest now includes firing-density
sanity paragraphs for those four Princes, and Molag Bal's stigma rows are
clarified as curse-state display text rather than independent per-act stigma.
At the time, this was repo/content proof only: no ESP write, no CAT-6
promotion, and no runtime or display proof claim. The 2026-06-07 all-Prince
CAT-6 pass supersedes the ESP/readback boundary, but not the runtime/display
proof boundary. The same tranche now also adds a controlled MCM proof surface
plus EventBus route `200` for curated Prince senders, route `201` for
generic-source silence probes, and exact organic quest-stage senders for all
sixteen Princes; organic placement is now readback-clean, while organic runtime
proof remains future in-game work.

Current v3.82 addendum:
`references/authoring/PDV_MedallionRoster.manifest.json` now owns the
lightweight medallion roster contract. The design is intent plus readback:
every race can see its full native roster surface, but only entries backed by
live `PDV_FLST_AllDeities` members are selectable. Pending native entries stay
visible with disabled explanations and journal/glyph fallback. The manager
source owns fail-closed selection helpers and Prisma payload construction; the
Prisma UI owns presentation only. Current proof is compile/readback/UI-contract
proof, not fresh in-game interaction proof.

Current v3.83 addendum: the per-race piety architecture fix is locked and the
**Khajiit pilot is runtime-proven** (2026-06-07). The structural piety-rate
skew identified in `references/authoring/PDV_RacePietyRateAudit.md` is closed
by the generalized contract `references/authoring/PDV_RaceContractTemplate.md`,
which names every race's foreground patron(s), gate type (offer vs no-offer),
piety-feeding acts with anti-farm, creed-violation losses, broad + per-patron
3-tier rewards, substrate/state boons, and per-race neglect spell. The Khajiit
pilot built and proved the no-offer / substrate variant in-game: double-route
piety pulses to scripted emphasis deities alongside the substrate metric;
`SyncKhajiitEmphasisRewards` gating a 15-spell per-emphasis set on emphasis-
deity piety tier; substrate boons populated; Khajiit neglect spell wired;
anti-creed routes 110-114; tier-up notice; shared-deity reconciliation for
Baan Dar (Khajiit+Bosmer) via `PDV_DeityBase.EligibleStateTrackOriginRace` so
a shared deity does not penalize the other race. Authoritative session detail:
`references/authoring/PDV_SessionHandoff_KhajiitPilot.md`.

Current v3.85 addendum: **Phase 2 static all-race reward/receiver gate
complete** (2026-06-07, closeout pass). The full Phase 2 static gate has now
landed across all ten races: manager scoring and reward/neglect sync branches,
the Imperial/Nord source-token discriminator convention, all-race reward/deity
record authoring, shared-deity reconciliation, SEQ refresh, Green Pact static
FormList/KID/readback layer, fallback-floor T3 capstone records, and the
read-only reward readback audit. Verification evidence from the closeout pass:
full PDV Papyrus compile `0 error(s), 0 warning(s)`; strict Phase 20 race
costing `PASS=2841, WARN=2, INFO=30` with only the known unnamed INFO record
class; base wiring audit `sourceProperties=39`, `sourceFillRecords=30`,
`routeEntries=24`, `rewards=10`; Prisma UI audit `PASS=11`; content verify
`PASS=1081, WARN=0, FAIL=0, INFO=4`; and
`tools/pdv_phase2_reward_readback_audit.mjs --json` `PASS=1268`. Runtime/manual
proof is still separate and still blocks external beta: run every
`PDV_BetaTestPacket_{Race}.md`, then update
`PDV_PreBetaRaceGateLedger.md` and `PDV_Phase20_ManualEvidenceLedger.json`.

Current v3.84 addendum: **Phase 2 all-race propagation - design + B1 + Argonian
B2 pilot complete** (2026-06-07, later same day). The proven Khajiit template
is now ready to propagate to the other 9 races. Coordination authority is
`references/authoring/PDV_Phase2_DeityRoster_and_ArchitectureRulings.md`
(binding rulings R1-R8: broad worship is a STATE not a deity; broad-T1
editorIds match the manager's existing per-race props
`PDV_Bless_<Race>_<Lane>_T1`; focused 3-tier sets use
`PDV_Bless_<Race>_<Patron|Path|LifeMode|Sect>_T1/T2/T3`; deities are SHARED
records keyed by per-race stance, created once by their owner; only focusable
patrons get records; Daedric forks route through the existing 20C system;
three gate shapes - substrate/no-offer, active-patron/offer, state-enum-gated;
<=2 always-on boon families per race, broad < focused, one anti-farm per act).
T3 capstone signatures are locked in
`references/authoring/PDV_Phase2_CapstoneSignatures.md`: signature rides on
top of the T3 stat half; mechanism library M1-M11+; <=1 cheat-death per race,
all once/day; **fallback-as-floor binding** for every fiddly detection so no
capstone is ever non-functional. Locked design rails: native-track-as-parity
piety model (rewards gate on each race's authentic track by default; active-
patron piety faucet kept only for Nord/Imperial/Altmer); two-tier magnitude
convention (universal combat <=~12%, narrow resists/regen/utility up to ~15);
Nord Old Ways gods Shor/Tsun/Stuhn promoted to focusable (3 new deity QUSTs +
9 new T1/T2/T3 reward records, Nord-owned); Nord Nine Divines lane reuses the
8 Imperial-owned Divines; Breton tradition is a filter (Knight's Road reuses
Stendarr/Mara/Arkay/Julianos; Green Way reuses Kynareth; Hidden Art's Daedric
via 20C); Argonian primal-unarmed lands on Sithis/Void T2 as `UnarmedDamage
10` (parallel to Khajiit Baan Dar/Rajhin clawed builds, also +10 unarmed each;
Khajiit Alkosh T3 ResistMagic deliberately raised 8 -> 15 as a capstone
exception). Tool: new race-agnostic `tools/pdv-phase20-race-author/` builds
0/0 and its dry-run reproduces the Khajiit ESP idempotently; Khajiit fork
retained as regression baseline. 9 per-race reward specs + 4 missing P2 audit-
only costing manifests (Imperial/Breton/Dunmer/Nord, extracted from
`PDV_Phase20_NoInGameProof_Gates.json`) authored; convergence review clean (0
deity-ownership collisions, 0 orphans, 22 new deities owned with FLST
projected 10 -> 32). **B1: 22 new `PDV_Deity_*.psc` authored and compiling
clean** (`0 error(s), 0 warning(s)` each), with collision-free SIGNAL_* blocks
1000-3199. **B2: Argonian pilot LANDED and compiles 0/0** - `PDV_Hist`/
`PDV_Sithis` deity properties + 8 reward Spell properties + Argonian neglect
property declared; the 4 Argonian handlers double-route the substrate
`Record*Scaled` call with `AwardCuratedSignal(PDV_Hist, SIGNAL_HIST_PULSE,
None)` and (on the Void handler) `AwardCuratedSignal(PDV_Sithis, ...)` gated
on `IsVoidFullyActive()`; new `SyncArgonianRewards` + `SyncArgonianNeglectSpell`
mirror the Khajiit pattern; no-offer integration completes via
`GetFirstTierRaceRewardSpellForOrigin` returning `None` for Argonian.
**Important gap surfaced for the remaining races:** existing
`HandleImperial*`/`HandleAltmer*`/`HandleOrc*`/`HandleRedguard*`/`HandleNord*`/
`HandleDunmer*` handlers are TELEMETRY STUBS - they bump StorageUtil counters
but do NOT call `AwardCuratedSignal`. Bosmer/Yffre + Khajiit substrate are
the working templates; the Argonian pilot now joins the substrate template
set. Imperial additionally needs a civic-act-type discriminator on
`RouteImperialCivicService` before per-Divine scoring works (same shape
likely for any Nord Nine Divines lane). Remaining work: B2 race-by-race
(Imperial/Altmer/Dunmer/Orc/Redguard/Nord/Bosmer/Breton + Khajiit capstone
back-fill), scripted capstone signature MGEFs (fallback-as-floor binding),
the Bosmer Green Pact tag layer modelled on Biggie's Traits + Requiem FBR,
B3 real-hook landing against `immersiveHookContracts`, Phase C ESP authoring
(user-gated: Skyrim closed + housecarl stopped + SEQ refresh after each
batch; authoring order Imperial+Argonian first -> Orc -> Dunmer/Altmer/
Redguard -> Nord/Bosmer/Breton), Phase D pace tuning, Phase E static verify
(new `tools/pdv_phase2_reward_readback_audit.mjs` to author), and user-only
Phase F runtime walk per race. Open: the 4 drafted P2 manifests still need
user review before Phase C runs for those races; the prior-handoff note
about `pdv_verify` expected-data potentially being stale re: the new deities
remains - resolve at Phase E with explicit user OK before any
`pdv_verify.mjs`/`pdv_compile.mjs`/`pdv_author.mjs` edit (CLAUDE.md rule 4).
Authoritative session detail: `references/authoring/PDV_SessionHandoff_Phase2_AllRaces.md`.

---

## 1. Scope and relationship to v2

`PDV_Architecture_v2.md` documented the migration from the original v1 codebase (one global, three buckets) to the current per-deity StorageUtil model. By the close of v2 the following are real and verifier-clean:

- Per-deity piety in StorageUtil, three mirror globals for the active patron.
- Deity-as-Quest pattern with `PDV_DeityBase` and concrete `PDV_Deity_<X>` quests.
- `PDV_ActionRouter` + `PDV__SM_KillActor` Story Manager kill-event capture.
- Dawn consolidation via `PDV__ManagerQuest.ProcessDawn()`, clamped to plus/minus 5 per day.
- Origin race detection (with vampire-race normalization and beast-form deferral).
- Stance taxonomy (`NATIVE / FOREIGN / TABOO / HOSTILE`) on `PDV_DeityBase`, with stance-aware multipliers in `AwardPiety`.
- Rivalry ledger fired from the stance-adjusted gain (not raw delta).
- Patron-only, cumulative-by-tier boon assignment.
- `PDV_MCM` dev surface (Status + Debug only), framework-attached.
- Curated-signal helpers (`AwardCuratedSignal*`) for CK-driven devotional events.
- Local toolchain: `pdv_compile.mjs`, `pdv_verify.mjs`, `pdv_author.mjs`, `pdv_patch.mjs`.

v3 plans everything past that point: signal expansion, the per-race overlay subsystems the locked race architecture requires, Daedric path architecture, curse-state handling, neglect, decay, the player-facing UX surface, the content authoring pipeline, mod compatibility, and the path to a 1.0 release.

v3 is **forward-only**. It does not restate v2 internals. Where v3 references a v2 mechanism (the manager API, the dawn loop, stance multipliers, etc.) it links back rather than duplicating the contract.

---

## 2. Invariants carried forward from v2

These are non-negotiable. Every v3 subsystem must respect them.

1. **StorageUtil is the source of truth.** Per-deity values live under deity FormID with the `PDV.` key prefix. Mirror globals are write-only caches, refreshed only by `AwardPiety` / `RecomputeTier` / patron-switch handlers.
2. **The dawn loop owns consolidation.** Runtime events write to `PDV.PietyToday` (scratch) only. Persistent piety, tier recompute, `OnTierChange`, and mirror refresh fire from `ProcessDawn()`. No runtime event path may write `PDV.Piety`, `PDV.Tier`, or mirror globals directly.
3. **Story Manager nodes share events.** Every PDV-added Story Manager node has `Shares Event` checked. PDV does not consume events vanilla or other mods need.
4. **Deity quests are persistent and uniform.** All `PDV_Deity_<X>` extend `PDV_DeityBase`, are Start-Game-Enabled, and are member of `PDV_FLST_AllDeities`. Adding a deity is a script + properties + FormList membership change, not a quest-infrastructure rewrite.
5. **One backend per StorageUtil key.** If JContainers is ever introduced, no PDV key uses two backends. Writers and readers must match.
6. **Player-facing strings are ASCII.** No curly quotes, em dashes, ellipses, bullets, or multibyte punctuation in MCM, dialogue, notifications, books, or message boxes.
7. **The framework ESP keeps `Skyrim.esm` as the first master.** Overlay patches authored via `pdv_author.mjs` must preserve this. Manually inserting `Skyrim.esm` into an existing patch without remapping FormIDs is destructive.
8. **PapyrusUtil is a hard runtime dependency.** Missing PapyrusUtil should hard-fail with a player-visible message, not silently fall back.
9. **powerofthree's Papyrus Extender is a hard runtime dependency.** PDV accepts the PO3 dependency chain for richer runtime event hooks: SKSE64, Address Library for SKSE Plugins, powerofthree's Tweaks, and the PO3 Papyrus Extender scripts/DLL. Use PO3 for event surfaces that vanilla Story Manager/player aliases cannot expose cleanly; do not use it for keyword/NPC/classification distribution that the offline patcher can generate.
10. **Race architecture preservation.** The locked race architectures in `references/PDV_RaceArchitecture_DesignReference.md` are authoritative. v3 subsystems must not flatten races into a uniform patron model.
11. **The hybrid boon policy is asymmetric.** Not every race gets a persistent substrate; structurally layered religions (Dunmer, Khajiit, Argonian) do, others lean on privileges and contextual favors. Most races should never feel like they have more than two meaningful always-on boon families at once.

### 2.1 Tier vocabulary boundary

The implementation keeps the v2 `PDV.Tier` spine at `0-3`. The public race
sheets use five player-facing devotional bands for tone and readability, but
those bands do not create extra tier storage:

| Public band | Internal meaning |
|---|---|
| Distant | Below active tier; presentation band only |
| Wavering | Below active tier; presentation band only |
| Observant | `PDV.Tier == 1` |
| Faithful | `PDV.Tier == 2` |
| Devoted | `PDV.Tier == 3` |

Do not add new tier globals, StorageUtil keys, or CK condition tiers to match
the race-sheet numbering. If player-facing labels are revised later, update the
UI/string layer and keep the storage contract stable.

---

## 3. Outstanding from Phases 4-6

These items were live or deferred when v2 was closed. v3 inherits them.

### 3.1 Resolved by policy, needs naming consistency

- **Boon revocation on patron-change.** Resolved for the proof slice: live boon spells are stripped on swap, persistent piety/tier are retained. v3 must apply the same rule to contextual favors and (where present) substrate layers - patron-foreground revokes on swap, substrate persists with origin.

### 3.2 Architecturally deferred

- **Decay model.** Runtime-proven for the Phase 17 bridge. Linear daily decay now has locked grace, once-per-day guard, persistent tier floors, broad-worship reduction, active-patron passive-decay protection, and non-patron drift while a patron is protected - see Section 15.
- **Storage migration.** v1 saves loading into v2/v3 mods: `PDV_GLO_DevotionLevel` is dead, Kyne piety reseeds from origin. Treat as a save-game gotcha rather than a migration path. v3 should document this in the mod page changelog when 1.0 ships.
- **PapyrusUtil missing-failure behavior.** Locked: add a visible hard-fail guard to `PDV__MainQuest.OnInit()` before any partial state writes. Missing PapyrusUtil should show a player-visible message, trace the dependency failure, and abort PDV bootstrap.
- **Custom-race fallback.** Locked: `PDV_Origin` may keep defaulting unknown races to `RACE_IMPERIAL`, but v3 must surface this as both a one-time first-load notice and an MCM/status diagnostic. A later custom-race soft-compat hook remains post-1.0 unless a concrete patch target appears sooner.
- **Curse-state module.** Werewolf and Vampire interpretation layers are designed (see race architecture reference) but not built. v3 owns this - see Section 13.

### 3.3 Contested lore items (must be decided before content lock)

Carried forward from v2 Section 10. Each affects stance and rivalry data, not architecture shape:

- **Trinimac as worshipable.** Locked: include as an Altmer-native specialist worship target for martial virtue, civilisational defence, and Thalmor Orthodox play. For Orcs, Trinimac remains `TABOO` fringe pressure only, not a normal Orc core path or fourth Orc lane. Scaffold in Structural Skeleton, but make content-ready only when the Thalmor Orthodox Altmer lane is being built.
- **Talos-Altmer.** Locked: `HOSTILE`. Theological enemy, not just culturally foreign.
- **Hircine for Bosmer.** Locked: `NATIVE`, with the lore disagreement noted in the deity description. Reading is Y'ffre-adjacent hunt / forest veneration.
- **Malacath classification.** Locked: dual-coded. Malacath is a Daedric Prince for non-Orsimer taxonomy and an Orsimer ancestor/core god as Mauloch/Malacath for Orc handling. Stigma and rivalry logic branch by race rather than forcing one universal label.
- **Lorkhan-family equivalence.** Locked: do not collapse `Shor`, `Sep`, `Lorkhaj`, and `Lorkhan` into one row. Keep culturally specific records where theology and rivalry differ, and note family resemblance in description text.

### 3.4 Environment / tooling (not architecture)

- **ReShade native conflict.** Crash signature was external (`ReShade64.dll` + `WS2_32.dll` + `webio.dll`). Workaround: rename `ReShade64.dll` in the Anvil Stock Game folder before launch. Not a v3 architectural concern.
- **SkyUI source-store fragility.** Mitigated by the dedicated CK header shim mod at `D:\Wabbajack\modlists\Anvil\mods\PDV - SkyUI CK Headers\`. Document only.

---

## 4. v3 subsystem map

The v3 architecture adds the following subsystems on top of the v2 core. Each gets its own section below.

| Section | Subsystem | Builds on |
|---|---|---|
| 5 | Signal expansion | `PDV_ActionRouter`, Story Manager receivers, curated-signal helpers |
| 5.8 | Quest-reaction matrix (curated quest-outcome reactions + thin-god faucets) | Section 5 Curated CK signal + PO3 `RegisterForQuestStage`; race-stance modulation; JSON-config data |
| 6 | Reputation track | New `PDV_ReputationTrack` reusable script |
| 7 | State track | New `PDV_StateTrack` lightweight per-race quest helpers |
| 8 | Race substrate layer + sacred place + moon cycle | New origin-gated quest pattern, parallel to deity quests; shared PDV_SacredPlace; Khajiit moon-cycle overlay |
| 9 | Privilege subsystem | CK Conditions on the existing mirror globals + new state-track globals |
| 10 | Contextual favor subsystem | Magic effects with stacked conditional triggers, family-capped |
| 11 | Daedric path architecture | New `PDV_DaedricPath_<X>` quest pattern with boon/price/stigma |
| 12 | Patron commitment mechanism | Threshold offer events written through the manager |
| 13 | Curse-state overlay | New `PDV_CurseState` overlay quest, weight-modifier helper API |
| 14 | Neglect subsystem | Tier downgrade + privilege/favor removal; small thematic effects |
| 15 | Decay model | New `ProcessDawn` step; per-deity floor and grace logic |
| 16 | Player-facing UI | MCM evolution + status spell + notification policy |
| 17 | Content authoring pipeline | Template scripts, `pdv_author.mjs` scope, offline classification/distribution patcher, verifier coverage |
| 18 | ESP module structure | Framework-monolithic through 1.0; race ESP split deferred |
| 19 | Performance budget | Pantheon-scale FormList iteration, dawn cost ceiling |
| 20 | Full roster content lock | Locked god/Prince roster, every-race handling, content-ready gates |
| 21 | Mod compatibility | Authoria-first list-author packages, tracked matrix, targeted adapters |

---

## 5. Signal expansion (Phase 7)

Currently the only live signal source is hostile kill events. The locked race architecture needs roughly the following signal families: shrine visits, sleep (location-typed), shouts, dialogue/quest resolutions, faction joins, marriage, donations, theft, mercy/persecution choices, and craft/labor events.

Gameplay posture locked by the 2026-05-18 gameplay reference pass: PDV
should stay quiet, event-led, lore-reactive, recoverable, and vanilla-plus.
Religion should answer Skyrim play the player already cares about, not become
a second chore meter or a stream of routine notifications.

### 5.1 Three signal-source patterns

Every v3 signal flows through one of three patterns and writes only through `PDV__ManagerQuest.AwardPiety()` or `AwardCuratedSignal()`:

| Pattern | Use when | Receiver | Cost |
|---|---|---|---|
| Story Manager receiver | The event is in the vanilla SM tree (Kill Actor, Add Item, Increase Skill, Change Location, etc.) | New `PDV__SM_<Event>` non-Start-Game-Enabled quest, calls router | A (cheap) |
| Player alias event | The event needs player-attached hooks (`OnSleepStart`, `OnObjectEquipped`, `OnPlayerLoadGame`) | `PDV_PlayerEvents` alias script on `PDV__ManagerQuest` player alias | A (cheap) |
| Curated CK signal | The event is a quest-stage outcome, dialogue choice, faction-join, or other CK-author-driven moment | Direct `AwardCuratedSignal()` from a CK fragment or dialogue script fragment | A-B |

`PDV_ActionRouter` continues to fan to all deities. New event types extend the `EVT_*` integer enum on the router. The router itself stays slim; per-deity scoring lives in each `ScoreAction()`.

Avoid polling-first capture patterns except for dev-only harnesses. If vanilla
or CK already exposes the event, use the event surface rather than a repeated
scan.

### 5.2 Event type enum growth

Current enum (v2):

```
EVT_NONE = 0
EVT_KILLED_HOSTILE_BEAST = 1
EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2
```

Reserved ranges for v3 (final integers locked when each phase ships):

```
1-9     Combat events           (kills, combat resolution)
10-19   Travel/location         (sleep outdoor, location-type entry, hold travel)
20-29   Social                  (marriage, charity, theft, mercy, persecution)
30-39   Devotional surfaces     (shrine use, ritual, prayer, donation)
40-49   Magic/voice             (shouts, school-of-magic use)
50-59   Craft/labor             (curated milestones only where lore-relevant)
60-69   Faction/quest           (faction join, allegiance, quest-stage outcomes)
70-79   Curse                   (lycanthrope/vampire state transitions)
80-89   Daedric                 (Prince-quest milestones, oath/break events)
```

Adding an event type is: append to the constants block on `PDV_ActionRouter`, add a Story Manager receiver or alias handler if the source needs one, update each deity's `ScoreAction()` rubric that cares, and append to the verifier's expected-record set.

### 5.3 Anti-farm enforcement

Every repeatable signal must carry an anti-farm rule (per the race-architecture pre-matrix requirements). v3 enforces this at three layers:

- **Per-event daily cap** in `ScoreAction()`. Read `StorageUtil.GetIntValue(deity, "PDV.Daily.<EventType>")`, gate further awards, reset at dawn.
- **Diminishing returns** for cheap repeatable signals (shrine use, sleep). Each fire scales the next by 0.7x within the day.
- **Cooldown windows** via `StorageUtil.SetFloatValue(deity, "PDV.LastFire.<EventType>", Utility.GetCurrentGameTime())` for context-sensitive signals (mercy/persecution, theft) where bursting would be exploitative.
- **Rejected source shapes** for 1.0: raw skill XP scoring, raw crafting counts, generic radiant repetition as primary proof, and notification-first reward loops.

Caps and cooldowns are deity-side, not router-side, so different deities can rate-limit the same event family differently.
Craft/labor signals are only in scope as curated milestone or context signals
(e.g. a named rite, a quest-authored proof of discipline, a high-friction
crafting moment). Do not score "made N daggers" or "gained X Smithing XP"
directly.

### 5.4 Outstanding signal-architecture decisions

- **Follower kill attribution.** Locked for Preflight: EventBus payloads should carry attribution type for direct player, follower, summon/charmed, trap, and environmental kills, but only direct-player kills score until a later signal phase gives indirect kills explicit devotional meaning.
- **Trap and environmental kills.** Same payload family as follower/summon attribution. Do not score them in Preflight; test real Story Manager behavior before any reduced-attribution scoring lands.
- **Crime events.** Story Manager has crime nodes (`OnStoryCrimeGold`, `OnStoryArrest`). These are first-class signals for Imperial Concordat Standing and Argonian community standing, but should land with Phase 8's reputation track so the events immediately adjust a real track instead of routing as empty signal scaffolding.

### 5.5 Race-specific signal mechanics (LOCKED)

These race-specific signal rules were locked during the grilling review and affect how signals are processed per-race:

**Bosmer Green Pact lifecycle (LOCKED):**
- PDV owns its Green Pact tagging layer for The Old Contract path; it may mirror ideas from Requiem/Races Redone, but it is not a dependency on their tags.
- Single violations do not lock out daily compliance reward -- the buff is withheld for that instance only (90-minute cooldown per anti-farm standard)
- The Old Contract is a binary `PactBound` commitment, not a soft ambient deity lane.
- While `PactBound`, Y'ffre is exclusive: non-Y'ffre Bosmer-recognized ledgers persist but freeze.
- `GreenPactCompliance` is a 0-100 act-driven meter with no passive decay: Apostate `0-19` locks gains, Lapsed `20-49` grants 50%, Observant `50-79` grants 100%, Strict `80-100` grants 120%.
- Sustained Apostate dwell for 3 in-game days fires a forced reckoning: re-commit and snap to 30, or renounce. No silent auto-renunciation.
- Re-entry is allowed once. A second renunciation permanently freezes the Y'ffre path.
- Wild Hunt remains lore context only, not a player-facing Bosmer track or state.

**Altmer crisis-of-faith (LOCKED):**
- Tier 3 Lorkhan-adjacent mortal-validation events (marriage, homestead, adoption, similar normal-life commitments) are lightly weighted reactions, not harsh collapses.
- Major main-story lore collisions fire crisis events instead of simple piety adjustments when they are among the biggest conflicts with Altmer theology.
- Crisis creates a temporary "questioning" state with more flavor and only a minimal temporary sting, reflecting emotional dysregulation rather than theological failure or permanent collapse.
- Crisis suppresses or softens normal gain/loss until resolved through continued consistent behavior.
- Duration and resolution are content-authored per crisis trigger (not a fixed timer)
- Altmer economy guardrail: ordinary existence in Skyrim is never a penalty source. Lorkhan pressure must use explicit tags/hooks, and basic devotional upkeep should trend positive through Auri-El dawn observance, study, magic milestones, College/Psijic milestones, or coherent factional acts.

**Dunmer Tribunal shrine random-thought (LOCKED):**
- Praying at a Tribunal shrine (Almalexia/Vivec/Sotha Sil) produces a random selection from a curated buff/debuff pool
- Each shrine has its own pool themed to its Good Daedra aspect
- Some results are positive, some negative -- reflects the Three's unpredictable legacy
- Signal source: curated CK activator script on the Tribunal shrine objects

**Nord broad-worship combo (LOCKED):**
- At Faithful (Tier 2), multiple active deity relationships produce combined contextual favors
- Favors are watered-down versions of individual deity rewards, combined for breadth-specific feel
- Broad worship counts as its own devotional lane for contextual favors
- The broad lane gets 3-5 blended trigger families, capped at Faithful, rather than activating each deity's full favor set
- Combo recipes are content-authored; architecture provides the multi-deity piety-read mechanism

**Orc community investment (LOCKED):**
- NPC disposition tracking is the preferred approach for community progression
- For 1.0: faction-favor proxy system (faction rank represents community standing)
- Progression arc: stranger -> acquaintance -> friend -> community member
- Drives devotion bonus from the Orc's self-made community location

**Imperial Concordat walk-back (LOCKED):**
- Amplified reverse weight at extreme positions: reversing from entrenched requires proportionally more counter-behavior
- Narrative gate: full reset from extreme to center requires a story-caliber event (not gradual drift alone)
- Prevents casual flip-flopping while allowing genuine character development arcs

**Redguard HoonDing accessibility (LOCKED):**
- HoonDing devotion achievable via special beast kills + major quest completions ("big wins")
- Sufficient signal sources exist in vanilla Skyrim (dragons, named creatures, quest climaxes)
- Threshold is high but attainable for active adventurers; no custom content required

### 5.6 Signal-axis vocabulary

The old `CombatBucket`, `SocialBucket`, and `LifestyleBucket` records are gone.
Race sheets may still describe behavior in combat/social/lifestyle terms, but
those are design axes only. Implementation uses event IDs, curated signal IDs,
per-deity `ScoreAction()` / `ScoreCuratedSignal()`, and optional track or
substrate modifiers. Do not add bucket globals, bucket StorageUtil keys, or a
generic race bucket quest to satisfy older reference wording.

### 5.7 Current Phase 7 packet (2026-05-19)

The current implementation packet is intentionally narrow and Nord/Imperial
first:

- `PDV_PlayerEvents.psc` now registers
  `PO3_Events_Alias.RegisterForShoutAttack(Self)` and routes
  `OnShoutAttack(Shout akShout)` through `PDV_EventBus`.
- `PDV__ManagerQuest.psc` now also registers a quest-level fallback through
  `PO3_Events_Form.RegisterForShoutAttack(Self)` and handles
  `OnPlayerShoutAttack(Shout akShout)` so live shout ingress does not depend on
  the alias receiver family alone. Duplicate callbacks inside a tiny time window
  are suppressed in manager code before scoring.
- `PDV_EventTypes.psc` now reserves `35` for hidden Talos shrine defiance and
  `40` for shout use.
- `PDV_EventBus.psc` now exposes `RouteShoutAttack(...)` and
  `RouteTalosShrineDefiance()`, both of which stay manager-facing rather than
  writing devotion state directly.
- `PDV__ManagerQuest.psc` now owns `HandleShoutAttack(...)` and
  `HandleTalosShrineDefiance(...)`. The shrine helper routes the Talos curated
  signal and applies Concordat pressure in one place.
- `PDV_DeityBase.psc` now provides a reusable deity-side repeatable-action
  helper for daily cap plus cooldown enforcement, and the live Phase 7 users are
  `PDV_Deity_Kyne.psc` and `PDV_Deity_Talos.psc` for ambient shout scoring.
- `PDV_EventSignalActivator.psc` can now route Talos shrine defiance through
  `RouteId = 35` when it is co-attached to the actual hidden shrine reference.
  The reference contract is documented in
  `references/authoring/PDV_Phase7SignalReceivers.manifest.json`.
- Runtime proof on 2026-05-20 now exists for both live surfaces in scope:
  the hidden Talos shrine reference path is proven in game on an Imperial save,
  and counted shout ingress is proven in game on a clean Nord save.
- The shout anti-farm lesson is now part of the Phase 7 contract: deity-side
  cooldown uses in-game time (`0.0208` days, about 30 in-game minutes), so a
  second shout after vanilla cooldown but before enough in-game time passes is
  expected to route without award.
- Local Civil War confirmation is now also exact rather than seed-only:
  `CW01A` (`Joining the Legion`, `Skyrim.esm:0D517A`) and `CW01B`
  (`Joining the Stormcloaks`, `Skyrim.esm:0E2D29`) are the first clean join
  markers, both with objective `160` `Take the oath` and once-only completion
  at stage `200`. The recommended Phase 7 hook point is stage `200` on each
  quest. The current manual fragment contract now prefers vanilla-safe SKSE
  mod-event calls because CK proved brittle around custom PDV script
  visibility and duplicate/ghost fragment-property state on vanilla quests.
  Preferred calls are `SendModEvent("PDV.ConcordatCompliance")` and
  `SendModEvent("PDV.ConcordatDefiance")`, with `PDV_PlayerEvents` catching
  those events and routing them through the existing EventBus path.

Still intentionally out of scope for this packet: crime/arrest Story Manager
events, broad deity-roster expansion, and guessed Civil War hooks. Civil War
one-shots are now locally verified, wired, and runtime-proven through the
vanilla-safe mod-event path; the lasting lesson is to keep vanilla quest
fragments tiny (`SendModEvent(...)`) and let PDV-owned scripts keep the real
devotion math.

---

### 5.8 Quest-reaction matrix subsystem (LOCKED design; source/readback wired)

The single largest realization of the Section 5 "dialogue/quest resolutions" signal family.
A **curated, one-time, checked-in table** that reacts to vanilla/DLC quest outcomes
with per-deity piety gain/loss. It is data, not a runtime classifier -- the judgment
(which god reacts, valence, intensity, magnitude) is authored and frozen.

**Model.** Each cell = `(quest-outcome x deity) -> valence(+/-), intensity(C/S/m),
magnitude(small|milestone)`. One quest choice fans across many gods (a sacrifice:
Boethiah+, Stendarr/Mara/Arkay-, Mephala+, Orc->Boethiah stigma). The god a cell
fires for is chosen by reading the outcome's **act-tags** (Part A vocabulary) against
each deity's **values-profile** (Part B). See `PDV_QuestReactionMatrix.md` for the full
method (Parts A-E).

**Layers (Part D).** (1) quest-outcome reactions = the milestone/small beats; (2) thin-god
repeatable **faucets** (Namira feed, Sanguine drink, Dibella adornment/alms, Mora Black
Books, etc.) = the small day-to-day signals; (3) artifact one-shots + faction-joins live
in the quest tranches; (4) a generic moral-fallback is a wiring rule. The locked act-tag
vocabulary gained `aesthetic_devotion` (2026-06-08) so Dibella's domain has a primitive.

**Data (frozen).** `PDV_QuestReactionMatrix_Full.csv` = 1978 cells / 172 quest keys / 134
watched quests / 45 deity names after the 2026-07-15 Tranche 11 full-main-quest pass, GENERATED from source tranches by
`tools/pdv_quest_tranche_merge.mjs` (do not hand-edit Full).
`PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` = 26 compiled faucet acts.
The Helgen-to-Alduin slice is a separate fail-closed contract: 45 identities x 25 exact
stages = 1125 cells across 19 quest records, with zero approved silences. T11 contributes
951 of those cells. `MQPaarthurnax` remains outside the matrix and uses exact 17-kill / 11-spare
Papyrus fork rosters because its spare branch has no dependable quest-stage completion.
Static coverage closes `C-MAIN-QUEST-FULL-COVERAGE`, including 45/45 explicit Prisma
producer symbols and rendered UI glyphs without a journal-icon fallback; the separate fail-closed
`C-MAIN-QUEST-FULL-COVERAGE-RUNTIME` criterion consumes five evidence-only co-test slots
for representative delivery/display, alias resolution, mixed polarity, paired equity, and
expanded Paarthurnax save/load latches. Older 6-kill/4-spare waivers are not current proof.

**Detection (proven, reused).** Quest stages via PO3 `RegisterForQuestStage` ->
`OnQuestStageChange` in `PDV_PlayerEvents` (already live for the Altmer MQ104-s160 P2
fill). Faucets via the existing PO3 / `OnObjectEquipped` / `OnBookRead` /
`RegisterForMagicEffectApply` hooks + curated FormLists.

**Resolution.** `PDV__ManagerQuest.ApplyDeityReaction(...)` applies **race-stance
modulation (Part C2)** - NATIVE full / FOREIGN dampened / TABOO->stigma /
CURSE->curse-layer - times intensity times the magnitude VALUE (read from a JSON
config, the single tuning lever). Quest one-shots are not anti-farm-gated (one-shot by
nature); faucets are capped 1/dawn (reuse the day-stamp guard pattern). Race-stance is
applied at WIRING time only; matrix cells stay universal.

**Calibration invariant (LOCKED).** Milestone COUNTS are frozen; pacing is tuned via
milestone VALUE because piety is per-god, so the cross-god fan-out never over-feeds any
single deity (after stance filtering, the worst single-player case is <=4 milestones on
one quest; 42/49 milestone-quests give <=2). See AGENTS.md Decisions Log 2026-06-08 and
memory `quest-reaction-matrix-calibration`.

**Data representation decision.** JSON-config (PapyrusUtil/JContainers), NOT
ESP-FormList-baked - scales to the current 1978 cells without FormList sprawl, keeps the
CSVs authoritative, and puts the tune-later values in one place. (Detection still uses a
watch set of 134 quests. Since that exceeds Papyrus's 128-element declared-array ceiling,
registration reads the PapyrusUtil string lists by indexed `StringListCount` / `StringListGet`.)
Optional PatchHub channel JSON also carries `sourceMod`, derived from the owning FOMOD
option name rather than hand-authored per channel. The queue stores that value with the
reaction job and emits it on both player-visible confirmation surfaces: the Prisma toast
and the matching persistent Book-of-Days entry. Core matrix reactions omit the field.
Existing saves keep a parallel StorageUtil source list that is padded before the first new
append, so new labels cannot drift onto historical journal entries.

**Status.** Design FROZEN. Core source/readback wiring is live through
`PDV_PlayerEvents`, `PDV__ManagerQuest.ApplyDeityReaction`, StorageUtil JSON, and the
quest matrix compiler; runtime-route/manual proof remains a separate gate. Six
design-first Prince artifact faucets now have narrow equip-event wiring through
`PDV_PlayerEvents`, compiled JSON faucet keys, and `PDV_FLST_Faucet_*_Artifact`
FormLists with direct-ESP readback proof. Deferred triggers:
Clavicus quest-persuade fragments, Dibella perform/art (no clean vanilla hook),
full staff-use beyond the curated Sanguine/Vaermina/Sheogorath spell-form routes,
hit-detection-only artifact semantics, disease polling, and Skeleton Key semantics.

The 2026-07-15 main-quest static/generated-readback gate is green at 1125/1125 required
cells, 17/17 kill reactions, 11/11 spare reactions, and indexed registration. That proof
does not promote old pre-expansion runtime evidence: representative main-quest delivery,
Book of Days ledger-all, toast-loudest, alias handling, and Paarthurnax latch behavior must
be observed again on the expanded build.

---

### 5.9 Ground-up V3 rebuild: Quest Reaction Slice 1 (LOCKED)

The ground-up V3 rebuild begins from current `main`, not the historical 1.0.3
decomposition baseline. It is new-game-only; the 1.5 line remains available for
existing saves. Extraction is strict behavior parity: timing, values, ordering,
player copy, one-logical-act aggregation, and presentation do not change while
ownership moves.

Quest Reaction is the first vertical slice because it crosses engine ingress,
data compilation, optional compatibility, persisted bounded work, scoring, and
player presentation. The target is one deep `PDV_QuestReactionRuntime` module.
Its small versioned interface accepts quest stages and semantic event IDs, owns
catalog activation/resolution, duplicate suppression, persisted FIFO delivery,
bounded scheduling, and compatibility status, and delivers one aggregated result
to the existing scoring/presentation seam. Optional adapters submit semantic
events; they do not call deity-reaction batches or own outcomes.

The existing Start-Game-Enabled worker quest at `0716DF:Devotion.esp` is
repurposed as the runtime host. This adds no quest, script instance, or scheduler.
One `RegisterForSingleUpdate` chain remains the only scheduler. The current
limits remain characterization invariants: 128 pending jobs, two applied work
items per tick, and a 0.1-second rearm while work remains.

V3 catalog identity is `pluginName|localFormId|stage`. Core data and official
third-party data compile into two deterministic runtime catalogs; only core owns
shared stance/value/faucet policy. The official third-party catalog is delta-only
and auto-installed. A source activates only when its plugin is active, every
sentinel resolves, and the source is not listed in the optional empty-by-default
disabled-source config. A malformed or incompatible extension rejects that
source only. Core wins only on the same fully-qualified key; equal local FormIDs
from different plugins remain independent.

The JavaScript catalog model retains readable camel-case field names, but the
serialized PapyrusUtil wire representation is stricter: member names inside
`string`, `float`, `int`, `stringList`, and `intList` are lowercase because
PapyrusUtil folds lookup keys before exact JSON access. Top-level bucket names
and stored values retain case. Integer selector arrays serialize into `intList`.
Case-fold collisions deduplicate only when values are identical; conflicting
values fail generation. The shared wire validator is used by generation,
extension admission fixtures, and installed-profile preflight.

The public all-in-one installer auto-installs the single catalog compiled from
the 75 data-only sources and retains dependency-detected options only for the
five real plugin/script adapters. This changes installer presentation, not the
hard-dependency boundary: core gains no third-party master, and missing source
mods remain inert. MCM exposes read-only compatibility status rather than 75
toggles.

`references/authoring/PDV_V3Slice1QuestReaction.manifest.json` is the Slice 1
interface, schema, retirement, characterization, and exit-gate authority.
Foundation work must make `PDV_ReleasePayload.manifest.json` the single shipped
Papyrus compile inventory, record the current behavior cases and static
invariants before replacement, and keep generated `dist` content output-only.
Slice 1B executes the eight behavior cases through
`tools/pdv_quest_reaction_characterization.mjs` before ownership moves. These
fixtures are an interface-level deterministic oracle, not Skyrim proof. Runtime
extraction then replaces the old Worker script rather than wrapping it:
`PDV_QuestReactionRuntime` owns source-qualified lookup, duplicate suppression,
`PDV.V3.QR.*` FIFO persistence, bounded slices, cleanup, scheduling, and status.
`PDV__ManagerQuest` retains scoring and presentation behind six narrow
callbacks. EventBus submits directly to Runtime; PlayerEvents configures/resumes
it; MCM reads Runtime status and invokes Runtime-owned controlled probes.

`housecarl_load_order_status(profile="Devotion Dev", lookup="Devotion.esp")`
first confirmed the Anvil instance, `Devotion Dev` profile, and active
`Devotion.esp`. Direct houseCARL readback on 2026-08-13 then confirms
`0716DF:Devotion.esp` remains
Start-Game-Enabled, now attaches `PDV_QuestReactionRuntime`, and retains its
`PDV_Manager -> 00C325:Devotion.esp` binding. Manager, EventBus, and MCM bind
`PDV_QuestReactionRuntimeService -> 0716DF:Devotion.esp`. This is record and
compile proof, not fresh-game runtime proof. Slice 1C-B has now removed the V1
runtime layout and local-ID fallback in source: Runtime loads the fixed core and
official v2 catalogs, then lexically sorted public extensions, and indexes only
fully-qualified quest and semantic identities.

Slice 1B closeout evidence is reproducible through these exact surfaces:

- `node .\tools\pdv_quest_reaction_characterization.mjs` -- all eight fixtures PASS.
- `node .\tools\pdv_quest_reaction_performance_audit.mjs` and `--self-test` -- 24 live assertions plus thirteen negative mutations PASS, including the armed-update, per-cell checkpoint, and unique-surface contracts.
- `node .\tools\pdv_compile.mjs --script PDV_QuestReactionRuntime --script PDV__ManagerQuest --script PDV_EventBus --script PDV_PlayerEvents --script PDV_MCM --skip-verify` -- each script compiles with 0 errors and 0 warnings.
- After the load-order confirmation above, direct `housecarl_read_record` on `0716DF`, `00C325`, `046AF7`, and `03AFBE` in `Devotion.esp` proves the Runtime host and its Manager/EventBus/MCM VMAD bindings. This is readback, not Skyrim execution.

The retired V1 JSON could not encode two plugins sharing the same local FormID
in one file. Slice 1C-B removes that fallback. Runtime now builds exact
`pluginName|localFormId|stage` and `sourceId|eventId` indexes during configuration,
registers each active quest once, and resolves stage selectors through source-owned
v2 catalog data.

Slice 1C-A supplies the backend half of that catalog contract without changing
runtime behavior. `PDV_QuestReactionCompatibility.manifest.json` names all 80
integrations (75 data-only and five adapters), every plugin and sentinel, all 78
quest CSVs, AFDI semantic authoring, and package metadata. The pure v2 library
and `pdv_quest_reaction_build.mjs` generate `PDV_QuestReactionCore.v2.json` and
`PDV_QuestReactionPatches.v2.json` with fully-qualified identities. `--check`
regenerates in memory and exact-byte-compares both LF catalogs and their SHA-256
receipt. Its fixtures prove cross-plugin local-ID independence, core then
official then lexical-extension precedence, source-local malformed/duplicate
extension rejection, full V1 tuple/shared-policy parity, and delta-only patch
output. That remains deterministic compiler/schema proof; Slice 1C-B adds the
consumer-side backend and compile proof described below.

Slice 1C-B cuts Runtime over to the two generated catalogs and optional sorted
`QuestReactionExtensions/*.json`. Each source is validated and activated
independently from plugin presence, sentinel resolution, and the optional
disabled-source list. Malformed or duplicate sources are rejected locally;
valid sources continue. Core retains first claim, then official, then lexical
extensions. The Runtime reports loaded catalog plus loaded/active/inactive/rejected
source counts, consumes compiled core and official stage selectors, and has no V1
channel discovery, separate stage-adapter discovery, or local-key fallback.
`SubmitSemanticEvent` resolves catalog outcomes; Slice 1D-A moves the shipped
AFDI observer onto that seam.

Backend proof is `pdv_quest_reaction_build --self-test --check`, the eight
characterization cases, the eighteen-mutation performance audit, qualified stage
ownership, ARR/T16 and core ambiguity checks, and zero-warning targeted compilation
of Runtime, PlayerEvents, and Manager. This proves source shape, deterministic data,
static ownership, and compileability. It does not prove fresh-game source activation,
engine registration, extension isolation inside Skyrim, post-cutover FIFO/save-load,
or player surfaces; those remain in the combined post-merge smoke.

Slice 1D-A migrates the only outcome-owning compatibility observer. AFDI keeps
its bounded 30-global poll, first-run baseline, resolve backoff, once-only seen
state, and terminal poll retirement. For every routable destruction it now
submits one `afdi|artifact_destroyed.*` event to Runtime; the 29 event payloads
and 80 deity outcomes live only in `PDV_QRE_AFDI.csv`. Jyggalag remains
classify-only. The Manager batch compatibility API is retired after a
package-wide caller audit proves no definition or call remains.

The adapter now resolves all 30 AFDI globals dynamically, so its typed anchor
property and AFDI plugin master are gone. Isolated Papyrus compilation passes at
zero errors/warnings and patch-source bytecode is relocked. Direct houseCARL
readback of the canonical/generated-identical adapter proves the ESP binds only
`PDV_QuestReactionRuntimeService -> 0716DF:Devotion.esp`, has only `Devotion.esp`
as a master, and retains its Start-Game-Enabled observer quest; the SEQ was
regenerated after master pruning. This is source/build/readback proof. Actual AFDI
baseline, destruction detection, semantic queue delivery, player surfaces, and
save-load behavior remain for the combined Skyrim smoke.

Slice 1D-B replaces the 125-file, 80-option PatchHub tree with a deterministic
31-file package generated from the compatibility manifest. One required
`PDV_QuestReactionPatches.v2.json` catalog carries the 75 data-only integrations;
exactly five dependency-detected adapter folders carry the remaining ESP/script/BOS
mechanisms. The package contains no `Channels`, `QuestStageAdapters`, `PDV_QRM_*`,
or `PDV_QSA_*` member. Canonical adapter assets live under `patch-source`, their
PSC/PEX lock is verified before generation, and `dist` is output-only.

`pdv_quest_reaction_build.mjs` now owns catalog generation, package-tree generation,
installer simulation, the exact path/length/SHA-256 receipt, and normalized ZIP
creation through one entrypoint. Self-tests cover missing assets/catalogs, a sixth
option, install collisions, legacy members, stale bytecode, two isolated output
trees, and catalog collision/isolation rules. The produced archive is written in
sorted order with forward-slash member paths and fixed timestamps, then extracted
and exact-hash compared. These are backend/package proofs, not evidence that a real
mod manager detected the five dependencies or that Skyrim activated any source.

The first installed V2 smoke exposed zero admitted catalogs because the generated
typed-bucket member names were camel-case while PapyrusUtil case-folds lookup
keys. The repair adds a catalog-only wire serializer and validator, regenerates
both catalogs plus package copies/receipts, and makes preflight reject mixed-case
wire data before Skyrim starts. Runtime now emits debug-gated `CATALOG_REJECT`
reasons for missing, load/parse, schema, and source-validation failures and emits
both aggregate admission and active-index summaries during configuration/reload.
The log checker requires at least two loaded catalogs and nonzero quest keys.

The QR-local Papyrus optimization pass first cached repeated catalog list counts
and terminal completion fields. Fresh organic proof then exposed a broken hot
path: Before the Storm stage 160 spent `7469.970703` ms materializing 45 catalog
cells synchronously inside `OnQuestStageChange`, while PlayerEvents still held
the ordinary quest broad scope. MQ103 stage 10 arrived during that work and the
Manager emitted `BROAD_SCOPE_ABORT` for the stalled MQ102 logical act.

The separate ingress fix closes and flushes the ordinary quest broad scope before
submitting Quest Reaction. Runtime admission now validates typed-list counts,
persists a lightweight job header, emits `admissionMs`, and returns. Its existing
single `0.1`-second scheduler materializes source and meta cells through persisted
build cursors, sharing the same two-work-item tick budget with later application.
`START` is delayed until an application slice can actually begin, so the lifecycle
is `ENQUEUE -> BUILD -> START -> COMPLETE`. The Manager scoring and one-final-
surface callbacks remain unchanged. Static audits and zero-warning targeted
Runtime/PlayerEvents compilation pass. The 2026-08-15 organic MQ102 stage-160
run admitted in `45.013428` ms and completed its ordered lifecycle. A clean
four-job sweep admitted every job in about 45 ms, saved during job 1 at
`build=8/45`, resumed with `pending=4`, and drained all four BUILD/START/COMPLETE
chains in FIFO order with no overflow, stack safety failure, or
`BROAD_SCOPE_ABORT`. This closes the Runtime-route and build-resume proof; four
visible toasts and four duplicate-free Book entries in that counted run remain
manual/player-surface proof.

The first fresh-game canary on 2026-08-14 proved qualified quest ingress and
five complete `ENQUEUE -> START -> COMPLETE` lifecycles. The controlled
four-job performance sweep preserved FIFO order, wrote four persistent Book of
Days entries, and produced no overflow, stack-dump, frozen-stack, or
`BROAD_SCOPE_ABORT` marker. Reloading after the queue had drained was clean. A
second counted run saved after job 1 while job 2 was at cell 4/21; load emitted
`RESUME pending=3`, then jobs 2-4 drained in FIFO order. Papyrus submitted and
Prisma received/rendered four distinct toast correlations. Manual observation
confidently saw two but could not certify all four.

The resumed job exposed a deeper presentation/replay defect: eligible Divine
names later in the job appeared twice in one newly-created Book entry, while
the pre-save Talos cell appeared once. The stacked fix now gives a saved active
slice resume ownership, cancels pending update registrations before load re-arm,
uses one persisted armed-update key, and checkpoints the cursor after every
applied cell. Manager also guarantees that one logical deed lists each deity
once; higher intensity remains the existing Book arrow/rune rather than repeated
prose. The corrected counted run produced exactly four enqueues, four starts,
four FIFO completions, and one `RESUME pending=3` at cell 2/21, with no overlap,
overflow, stack-dump, frozen-stack, or `BROAD_SCOPE_ABORT` marker. Prisma logged
four receipts and four renders with zero dedupes; the tester confirmed four
visible toasts and no repeated deity names in any new Book entry. The resumed
queue and presentation defect is therefore closed at both runtime-route and
manual/player-surface proof boundaries.
The V3 runtime-log checker now consumes the real qualified key and `v3qr_N`
marker shape; selected-lane and toast-cardinality corrections belong to the
stacked canary-fix slice rather than the strict-parity extraction.

The stacked canary-fix implementation now makes selected Nord baseline
eligibility the single automatic quest-reaction policy at both ingress and the
final pre-award guard. Ordinary Old Ways cells therefore cannot reach piety or
Book accumulation while Nine Divines is selected, and the inverse is also
true. Authored `TABOO`/`HOSTILE` displeasure, Daedric watching/commitment, and a
grandfathered active patron keep their explicit exceptions. Each completed
logical job also carries its qualified reaction key as toast `correlation`;
Prisma suppresses an exact repeat of one correlation but cannot collapse four
different jobs. Static policy/cardinality gates, isolated Manager compilation,
and the native releasedbg build pass. Mid-job `RESUME`, four UI render callbacks,
unique-name resumed Book presentation, and four visible toasts now pass. Fresh
selected-lane sweeps then produced four enqueues, starts, completions, one
mid-job resume, and no queue safety marker in each lane. Old Ways emitted
`NordOldWays` with accepted-cell shape `20/20/20/9`; the tester confirmed Stuhn
and Shor were included while Akatosh was excluded. Nine Divines emitted
`NordNineDivines` with shape `21/21/21/7`; the tester confirmed Stuhn, Shor, and
Tsun were excluded while Akatosh remained eligible. The stacked canary-fix
slice is therefore runtime/manual proven. Catalog-v2, semantic-adapter, and generated
package backend work now pass; the combined post-cutover fresh-game and Authoria smoke
is the remaining Slice 1 acceptance gate.

The appended Papyrus log also exposed a proof-tool defect: fresh sessions reuse
`v3qr_N` job IDs. The runtime checker now pairs lifecycle occurrences in order,
requires every completion to own a preceding unmatched start, rejects negative
latency, and self-tests two sessions that reuse the same IDs.

---

## 6. Reputation track subsystem (Phase 8)

Several locked race-architecture pieces use the same basic shape: a continuous
integer track with named threshold bands, sustained-behavior lock-in, and
optional state-specific gain modifiers. v3 abstracts those into one reusable
component instead of bespoke race scripts. The first-release family includes
Imperial `ConcordatStanding`, Altmer `ThalmorAlignment`, Breton
`WitchcraftExposure`, Breton `KnightlyVowIntegrity`, and Breton
`DruidicStanding`.

Status note (2026-05-21): the first live instance, `PDV_RepTrack_ConcordatStanding`,
is now runtime-proven. The committed-state/pending-state split, 3-day lock-in,
extreme-band gate, committed-state multiplier readback, and save/load
persistence all passed on an Imperial save.

### 6.1 Pattern

```papyrus
Scriptname PDV_ReputationTrack extends Quest

; -- Identity (set in CK per instance) --
String   Property TrackName Auto                 ; "ConcordatStanding"
GlobalVariable Property StorageBacking Auto      ; e.g. PDV_GLO_ConcordatStanding
Int      Property MinValue = -100 AutoReadOnly
Int      Property MaxValue = 100 AutoReadOnly

; -- Threshold table (parallel arrays, set in CK) --
Int[]    Property ThresholdValues Auto           ; e.g. Concordat [-76, -51, 51, 76]
String[] Property ThresholdLabels Auto           ; e.g. ["OpenDefiant", "PrivateDefiant", "Uncommitted", "PublicCompliant", "ConcordatEnforcer"]

; -- Lock-in (per Section 10.2 of race ref) --
Bool     Property LockInOnCross = True Auto      ; threshold must be crossed by sustained behavior
Int      Property LockInGraceDays = 3 Auto       ; days at the destination before the new state sticks
Bool     Property NarrativeGateRequiredForExtremeReset = False Auto
Int[]    Property ExtremeStateIndexes Auto
```

### 6.2 API surface

```papyrus
Int   Function GetValue()                            ; current backing value
Int   Function GetStateIndex()                       ; resolved threshold band
String Function GetStateLabel()                      ; resolved state name
Bool  Function CanAdvance(Int adjustment)            ; respects lock-in grace
Function Adjust(Int adjustment, String reason)       ; writes through, traces
Function ForceSet(Int newValue, String reason)       ; admin/debug only
```

Each track stores its current value in a dedicated `PDV_GLO_<TrackName>` global
so vanilla CK Conditions can read it natively. Lock-in state is in StorageUtil
under `PDV.Track.<TrackName>.LastCross` and
`PDV.Track.<TrackName>.LockInUntil`. If
`NarrativeGateRequiredForExtremeReset` is enabled, sustained counter-behavior
can move the value toward center, but a curated story-caliber signal must clear
`PDV.Track.<TrackName>.ExtremeResetGate` before the resolved state fully leaves
an extreme band.

### 6.2a First-release track instances

| Track | Range / bands | Owner | Notes |
|---|---|---|---|
| `PDV_RepTrack_ConcordatStanding` | `-100..-76` OpenDefiant, `-75..-51` PrivateDefiant, `-50..50` Uncommitted, `51..75` PublicCompliant, `76..100` ConcordatEnforcer | Imperial | Wide Uncommitted band prevents incidental play from forcing a Talos position; extreme walk-back requires amplified reverse weight plus narrative gate |
| `PDV_RepTrack_WitchcraftExposure` | `0..25` Hidden, `26..50` Suspected, `51..75` Known, `76..100` Notorious | Breton Hidden Art | Tracks visibility of occult practice, not moral guilt; high exposure can accelerate Daedric rewards while increasing social cost |
| `PDV_RepTrack_ThalmorAlignment` | Heterodox, OrthodoxModerate, ThalmorDevout | Altmer | Modifies orthodoxy, Trinimac access, Lorkhan-reaction weight, and crisis-of-faith framing |
| `PDV_RepTrack_KnightlyVowIntegrity` | `0..100`, starts high | Breton Knight's Road | Degrades through dishonor; low integrity suppresses knightly Divine gains until restored through mercy/justice signals |
| `PDV_RepTrack_DruidicStanding` | `0..100` plus curse-state gates | Breton Green Way | Handles Y'ffre standing; pairs with a state-track fork for vampire excommunication and the werewolf Druidic Trial |

### 6.3 Where adjustments come from

- **Curated signals from CK dialogue/quest fragments.** Most reputation track adjustments are quest-resolution moments; the points-per-action tables in the race architecture reference (e.g. "Find and activate hidden Talos shrine: -15") become dialogue/quest-script `Adjust(-15, "shrine_activate")` calls.
- **Story Manager receivers** for non-curated events like "kill Thalmor Justiciar unprovoked" (a `PDV__SM_KillActor` victim-faction check).
- **Player alias events** for sleep, marriage, faction-join hooks.

Reputation tracks **do not** modify piety directly. They modify *stance multipliers* indirectly via Section 6.4.

### 6.4 Track-modified stance multipliers

The race architecture's Concordat table shifts Talos-devotion gain by state (x1.5 for Open Defiant, x0.5 for Concordat Enforcer). This composes with the v2 stance multiplier.

v3 extends `PDV_DeityBase` with an optional track-multiplier hook:

```papyrus
; PDV_DeityBase additions
PDV_ReputationTrack Property GainModifyingTrack Auto    ; nullable
Float[] Property GainMultiplierPerTrackState Auto       ; parallel to track's threshold bands

Float Function GetEffectiveGainMultiplier()
    Float stanceMult = GetGainMultiplier(GetStanceForPlayer())
    Float trackMult = 1.0
    if GainModifyingTrack
        trackMult = GainMultiplierPerTrackState[GainModifyingTrack.GetStateIndex()]
    endif
    return stanceMult * trackMult
EndFunction
```

`PDV__ManagerQuest.AwardPiety` reads `deity.GetEffectiveGainMultiplier()` instead of the bare stance multiplier. Deities without a `GainModifyingTrack` see no behavioral change.

### 6.5 Naming

- `PDV_RepTrack_<Name>` for the quest record. Examples: `PDV_RepTrack_ConcordatStanding`, `PDV_RepTrack_WitchcraftExposure`, `PDV_RepTrack_ThalmorAlignment`.
- `PDV_GLO_<TrackName>` for the backing global. Examples: `PDV_GLO_ConcordatStanding`, `PDV_GLO_WitchcraftExposure`, `PDV_GLO_ThalmorAlignment`.
- `PDV_GLO__<TrackName>_LockInUntil` for the internal lock-in cache global (write-only mirror; canonical state in StorageUtil).

---

## 7. State track subsystem (Phase 9)

Reputation tracks are continuous integers with thresholds. State tracks are categorical enums: "which Bosmer path is active," "which Orc life-mode," "Imperial Concordat resolved state" (a coarser readout of the rep track), "broad vs primary worship state."

State tracks differ from reputation tracks in that they:

- Have no continuous backing value, just a current category integer.
- Often persist for the life of the character (Bosmer path), or until a major life event (Orc Stronghold -> City -> Exile).
- Are usually set by a one-time threshold event, not by accumulating points.

### 7.1 Pattern

```papyrus
Scriptname PDV_StateTrack extends Quest

String   Property TrackName Auto                 ; "BosmerPath"
GlobalVariable Property StateGlobal Auto         ; PDV_GLO_BosmerPath
Int      Property UnsetSentinel = -1 AutoReadOnly
String[] Property StateLabels Auto               ; ["OldContract", "LivingStory", "Exchange", "BanditRoad"]
Bool     Property AllowsTransition = True Auto   ; some tracks lock once set
```

API mirrors the reputation track: `GetCurrentState()`, `GetStateLabel()`, `SetState(Int, String reason)`, `ResetForDebug()`.

### 7.2 Where state tracks come from

- **Setup quests** at character start or immediately after startup/origin resolution (Bosmer four-path choice via a post-startup popup, not MCM-at-character-creation).
- **Threshold events** during play (Orc Stronghold-to-City transition triggered by sustained outside-stronghold residency, or a story event).
- **Quest resolutions** (Imperial Concordat "Open Defiant" reached via sustained track threshold).

### 7.3 How state tracks feed scoring

State tracks unlock or restrict eligible deities (Bosmer `OldContract` makes `Y'ffre` strongly NATIVE-foreground; `BanditRoad` makes `Baan Dar` the foreground deity; the other three Bosmer paths each foreground a different deity).

For Bosmer, `PDV_State_BosmerPath` selects the path, but `OldContract` also
needs its own bound/unbound lifecycle and discipline state. `PactBound`,
`LapsedFromPact`, and `GreenPactCompliance` remain separate from the path
track so Y'ffre exclusivity, forced reckoning, and terminal renunciation are
not collapsed into a single enum. `LivingStory` and `OldContract` deliberately
share one `Y'ffre` deity ledger; the path state changes exclusivity, scoring
interpretation, and Pact behavior rather than swapping to separate Y'ffre
records.

Green Pact respect is not exclusive to the `OldContract` path. Proper hunting,
animal-sourced food, restraint around needless plant use where detectable, and
respect for the living world may provide modest positive weighting for all
Bosmer paths. Only `OldContract` converts those tenets into hard covenant law:
plant-use penalties, `GreenPactCompliance`, forced reckoning, Y'ffre
exclusivity, and terminal renunciation. Non-Old-Contract paths can receive
shared Pact-positive weight, but they do not suffer Old Contract penalties.
Implement this as shared Bosmer signal weighting, not a hidden background
`OldContract` or Y'ffre covenant ledger: tag Pact-positive signals once, let
the active Bosmer path interpret them, and write only modest path-local piety
or recent-signal strength outside `OldContract`.

Bosmer path switching is destination-gated. The first setup choice is free, but
later switching uses Bosmer-specific system-suggested popup offers plus a
confirmation rite; it does not ride the generic deity-offer queue and it is
not a simple MCM toggle. `LivingStory` can be entered through one strong
community/story signal and is the fallback for incoherent or corrupt state.
`Exchange` and `BanditRoad` require two destination-coded signals on separate
in-game days within seven, evaluated at dawn, unless a major curated quest beat
proves the destination immediately. `OldContract` re-entry requires explicit
recommitment, no terminal second renunciation, and three Pact-positive days
within seven; on re-entry `GreenPactCompliance` snaps to 30. Path deity ledgers
are preserved across switches, but only the active path receives full scoring,
contextual favor, and Champion eligibility. After a switch, automatic switching
is locked for seven in-game days unless a major authored exception fires.

v3 adds an optional `EligibleStateTrack` + `EligibleStateValues` filter on `PDV_DeityBase`:

```papyrus
; PDV_DeityBase additions
PDV_StateTrack Property EligibleStateTrack Auto       ; nullable
Int[] Property EligibleStateValues Auto               ; deity is selectable as foreground only in these states

Bool Function IsEligibleForPlayer()
    if EligibleStateTrack == None
        return True   ; no gating
    endif
    Int currentState = EligibleStateTrack.GetCurrentState()
    Int i = 0
    while i < EligibleStateValues.Length
        if EligibleStateValues[i] == currentState
            return True
        endif
        i += 1
    endwhile
    return False
EndFunction
```

The patron-commitment mechanism (Section 12) reads `IsEligibleForPlayer()` before offering a deity as foreground. Ineligible deities can still accumulate piety in the background but cannot become foreground patron.

### 7.4 State tracks needed for first release

| Track | States | Owner race | Notes |
|---|---|---|---|
| `PDV_State_BosmerPath` | OldContract, LivingStory, Exchange, BanditRoad | Bosmer | Set by a post-startup Bosmer path popup. `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`. The startup popup auto-commits the matching foreground patron; fallback for unset/corrupt state is `LivingStory`. Later switching is destination-gated through Bosmer-specific popup offers plus a confirmation rite. `OldContract` additionally reads `PactBound`, `LapsedFromPact`, and `GreenPactCompliance`. |
| `PDV_StateTrack_OrcLifeMode` | City, Stronghold, LegionExile | Orc | Existing skeleton state track; default City; setup/MCM records intent, but active mode is world-confirmed. `City = 0`, `Stronghold = 1`, `LegionExile = 2`. Stronghold requires Blood-Kin/equivalent acceptance plus conduct; LegionExile requires service/exile gate or completed pressure-bearing service. Soft switches require two qualifying signals on separate in-game days within seven days and resolve at dawn; major gates may switch immediately. |
| `PDV_State_NordPantheonBaseline` | OldWays, NineDivines | Nord | Setup/MCM pantheon baseline only. `OldWays = 0`, `NineDivines = 1`. Commitment depth uses `PDV_GLO_PatronState`; do not overload the baseline state with Broad/Primary. |
| `PDV_State_BretonTradition` | KnightsRoad, HiddenArt, GreenWay | Breton | Primary identity chosen explicitly at setup; no silent default; `KnightsRoad = 0`, `HiddenArt = 1`, `GreenWay = 2`; patron offers normally come only from the chosen tradition |
| `PDV_State_BretonDruidicFork` | Stable, Contested, GreenAccepted, HircineClaimed, Excommunicated, Penitent, Restored | Breton Green Way | Curse-state fork/readout paired with `PDV_RepTrack_DruidicStanding`; `Stable = 0`, `Contested = 1`, `GreenAccepted = 2`, `HircineClaimed = 3`, `Excommunicated = 4`, `Penitent = 5`, `Restored = 6`; Hircine is fork-access, not baseline Breton worship |
| `PDV_StateTrack_RedguardSect` | Crown, Forebear, AshAbah | Redguard | First-run setup choice. `Crown = 0`, `Forebear = 1`, `AshAbah = 2`; fallback is `Forebear`. Crown/Forebear switching requires two sect-coded signal days within seven; AshAbah entry requires a major death, undead, tomb, funerary, or impurity-bearing burden signal. `PDV_GLO_RedguardSect` mirrors the current value for CK/readback surfaces. |
| `PDV_State_DunmerAncestorPosture` | Normal, Strained, Silent, RestoredScarred | Dunmer | Curse/restoration posture for the ancestor substrate. Dunmer native focus uses shared patron state; do not implement `PDV_State_DunmerPath`. |
| `PDV_State_AltmerCrisis` | None, Dissonant, Questioning, Reasserting, ScarredResolved | Altmer | Temporary crisis-of-faith state for major lore-challenging story points; source-scaffolded in `PDV__ManagerQuest`, record-wired as a `PDV_StateTrack`, and now paired with the first two Altmer contextual-favor spell records |
| `PDV_State_ArgonianHistPosture` | Normal, Distant, Strained, Silenced, Corrupted | Argonian | Visible Hist-posture readout paired with `PDV_Substrate_ArgonianHist`; record-wired as a `PDV_StateTrack` and refreshed by manager curse/dawn handlers |

Do not add race-specific state tracks whose only job is `Broad` vs `Primary`.
Formal patron/deity commitment uses `PDV_GLO_PatronState` and
`PDV_GLO_PatronDeity`. State tracks are for orthogonal identity axes such as
pantheon baseline, sect, tradition, life-mode, crisis, or curse fork. Imperial
therefore does not need `PDV_State_ImperialWorship`; its unique axis is
`PDV_RepTrack_ConcordatStanding`.

### 7.5 Naming

- `PDV_State_<RaceOrDomain><Track>` for the quest record.
- `PDV_GLO_State_<TrackName>` for the backing global.

---

## 8. Race substrate layer (Phase 10)

The locked hybrid boon policy gives a *persistent substrate* only to races whose theology is structurally layered. v3 implements this as a parallel-to-deity quest pattern.

### 8.1 The substrate quest pattern

A substrate quest is structurally similar to a deity quest but:

- It is **origin-gated**, not patron-gated. It runs (and its boons are live) whenever `PDV_GLO_OriginRace` matches.
- It does **not** appear in `PDV_FLST_AllDeities` and does not participate in the rivalry ledger.
- It is **always active** for matching origin; there is no "Set Substrate Active" the way patrons work.
- It can have its own tier table driven by an aggregate substrate metric, not per-deity piety.

```papyrus
Scriptname PDV_SubstrateBase extends Quest

String   Property SubstrateName Auto             ; "KhajiitLunar"
Int      Property RequiredOriginRace Auto        ; RACE_KHAJIIT
String   Property StorageKeyPrefix Auto          ; "PDV.Substrate.KhajiitLunar"

Spell    Property Substrate_Always Auto          ; the always-on layer
Spell    Property Substrate_Mid Auto             ; activates at a metric threshold
Spell    Property Substrate_High Auto            ; activates at a higher threshold

Float    Property MidThreshold = 25.0 Auto
Float    Property HighThreshold = 75.0 Auto

Float    Property LowThreshold = 1.0 Auto

Function OnInit()
    RegisterForSubstrateEvents()
EndFunction

Function RegisterForSubstrateEvents()
    ; Override per concrete substrate
EndFunction

Function RecomputeSubstrateTier()
    ; Read aggregate metric from StorageUtil
    ; Add/remove tier spells accordingly
EndFunction
```

Positive substrate progress routes through one piety-neutral daily-credit seam.
The devotional day is `floor(GameDaysPassed - 0.25)` and is stored as day plus
one. The first approved authentic act for the matching origin grants `+4`; all
later acts that devotional day grant zero. No credit banks across days, and
different route families cannot bypass the shared day lock. Migration and
developer boundary seeds are the only direct positive-write exceptions; decay
and curse resets are the only direct negative-write exceptions.

### 8.2 Substrates needed for first release

Strong persistent substrates are locked to six races for 1.0: Imperial civic
practice, Dunmer ancestor practice, Argonian cultural practice, Nord
hearth/sky-road practice, Altmer ordered heritage, and Khajiit lunar-road life.
Breton's earlier substrate records are retired compatibility/migration surfaces
and do not belong to the active substrate FormList.

| Substrate | Origin | What it tracks | Aggregate metric |
|---|---|---|---|
| `PDV_Substrate_ImperialAncestor` | Imperial | Civic and public religious practice | Daily authentic civic-practice credit; never a generic sleep or Talos pulse |
| `PDV_Substrate_DunmerAncestor` | Dunmer | Ancestor and Reclamation practice | Daily authentic practice credit; home context is texture, not a second award |
| `PDV_Substrate_ArgonianHist` | Argonian | Saxhleel cultural practice | Dedicated `CulturalPractice` metric, separate from Hist/People/Void relation ledgers |
| `PDV_Substrate_NordAncestor` | Nord | Hearthkeeping and open-sky cultural practice | Daily authentic practice credit shared across both pantheon baselines |
| `PDV_Substrate_AltmerAncestor` | Altmer | Ordered rest, cultivation, heritage, and rite | Daily authentic practice credit; passive dawn is excluded |
| `PDV_Substrate_KhajiitLunar` | Khajiit | Outdoor road-home life, lunar observance, caravan defense, and curated focus acts | Daily authentic practice credit; no designated anchors or circuit |

Redguard ancestor reverence and Orc life-mode standing express identity through
privileges, contextual favors, sacred-place modifiers, and state tracks. In
particular, Orc
City/Legion community location tracking uses `PDV_SacredPlace`, but it is not a
strong persistent substrate and should not compete with Malacath's foreground
mode as the main Orc boon lane.

`PDV_StateTrack_OrcLifeMode` owns the active Orc scoring lane. `PDV_SacredPlace`
may modify City and LegionExile presentation/reward context, but it must not
silently change the active mode by location visits alone. Mode changes come
from the Orc state-track gates: major gates immediately, or dawn-evaluated
soft switches after sustained evidence.

**Substrate roster policy (LOCKED):** The active 1.0 roster is the six origins
listed above. Redguard and Orc remain outside it. Breton is explicitly retired;
its old records may remain only for compatibility and migration.

### 8.3 Storage

Substrates use their own StorageUtil key prefix to avoid colliding with deity keys:

```
PDV.Substrate.<Name>.Metric     ; aggregate metric (0-75)
PDV.Substrate.<Name>.LastEvent  ; game time of last substrate event
PDV.Substrate.<Name>.Tier       ; current substrate tier 0-3
```

No mirror globals for substrate. CK Conditions that need substrate state read from the dedicated substrate globals when needed.

### 8.4 Interaction with patron boons

Substrate boons and patron boons coexist. Family caps (Section 10.7) prevent stacking abuse. For balance, treat substrate boons as the "always quiet" layer and patron boons as the "louder" foreground layer.

### 8.5 Sacred Place shared system (LOCKED)

Multiple races need location-based devotional tracking. Rather than bespoke per-race implementations, v3 provides a shared `PDV_SacredPlace` script that races hook into with their own parameters.

```papyrus
Scriptname PDV_SacredPlace extends Quest

; -- Identity (set in CK per instance) --
String   Property PlaceName Auto                 ; "ArgonianBedOfChoice"
Int      Property MaxLocations = 1 Auto          ; Argonian: 1, Orc: 1
Int      Property RequiredOriginRace Auto        ; RACE_ARGONIAN etc.

; -- Tracking --
ObjectReference[] Property DesignatedLocations Auto  ; player-designated places
Float[]  Property LastVisitTime Auto             ; game time of last visit per location
Int[]    Property InvestmentLevel Auto           ; 0=empty, 1=established, 2=thriving (Orc only)

; -- Tuning --
Float    Property VisitFrequencyDays = 7.0 Auto  ; how often visits are expected
Float    Property DecayRatePerMiss = 5.0 Auto    ; devotion penalty per missed cycle
Float    Property RewardModifier = 1.0 Auto      ; bonus to substrate/devotion on visit

; -- API --
Function DesignateLocation(ObjectReference loc)
Function RecordVisit(ObjectReference loc)
Function ProcessDecay()                          ; called from dawn pass
Float Function GetPlaceBonus()                   ; read by substrate scoring
```

**Per-race usage:**

| Race | Locations | Visit Model | Progression | Custom Behavior |
|---|---|---|---|---|
| Argonian | 1 | Sleep N nights/month at designated bed | Static | Community decay on absence |
| Orc (City/Legion) | 1 | Visit invested location | Dynamic (empty -> established -> thriving) | Investment builds over time |

**Design rules:**
- All towns work equally once designated (no mechanical bonus for specific locations)
- Location-specific flavor text is allowed (Windhelm for Argonian, stronghold approaches for Orc)
- Designation piggybacks off existing game concepts (bed ownership for Argonian, return frequency for Orc)
- The shared system handles tracking; race-specific substrate scripts read `GetPlaceBonus()` and integrate into their own scoring
- Orc usage feeds a contextual mode modifier only. Do not promote it into a strong substrate without a later playtest decision.
- Khajiit is explicitly excluded. Outdoor rest is road-home practice without a designated place or circuit.

### 8.5a Argonian ritual/custom-content obligations (LOCKED)

The Argonian Hist substrate needs at least one player-triggered reconnection
tool because vanilla Skyrim has no real Hist infrastructure. v3 treats the Hist
sap meditation item/power as 1.0 custom content, not a post-launch luxury.

Argonian death-rites also need Arkay-priest reaction content for the racial
theology layer to answer back through the world. Without those reactions,
Argonian death practice risks becoming hidden counter math rather than visible
roleplay.

### 8.6 Moon cycle substrate extensions (Khajiit-specific) (LOCKED)

The Khajiit substrate includes a moon-cycle overlay tied to Skyrim's actual
24-day Masser/Secunda phase formula and a deliberate `Observe the Moons` lesser
power. There is no abstract 28-day continuity score.

```papyrus
; PDV_Substrate_KhajiitLunar additions
Int      Property CurrentMoonPhase Auto          ; derived from game day
Float[]  Property PhaseRewardWeights Auto        ; which reward type is strongest per phase

Function RecomputeMoonPhase()
    ; Read Masser/Secunda from GameHour/GameDay
    ; Map to internal phase enum
    ; Update PhaseRewardWeights
EndFunction
```

**God-strength behavior:**
- The eight slots identify one god in strength: `Alkosh, Azurah, Khenarthi, Rajhin, Rajhin, Baan Dar, Khenarthi, Azurah`.
- `Observe the Moons` is valid outdoors from 20:00 to 05:00 while out of combat, unmounted, and not swimming.
- One delayed check after two seconds aborts on combat, cell change, or movement over 128 units; there is no continuous polling.
- `PDV_KhajiitMoonObservations.json` provides ten lines per god plus six shared lines (56 distinct lines, 80 logical pool memberships), selected uniformly with resolved-ID immediate-repeat prevention. The compiled four-line sets remain the missing-or-invalid-JSON fallback.
- The first rite each devotional day also enters the Book of Days, and the power shares the selectable Power slot with Survey Devotion rather than a casting hand.
- The first valid rite per devotional day may claim the shared `+4` substrate credit and awards raw god-in-strength piety `+0.4` without changing behavior-led focus weight. Later rites are informational.
- Matching a Seeker-or-higher focus to the god in strength activates Lattice Resonance: one perk multiplies keyword-tagged focused numeric spell magnitudes by `1.20`. The retired rotating stat spells and old `+10%` piety multiplier remain inert for compatibility.

---

## 9. Privilege subsystem (Phase 11)

**V1/V2 scope (2026-05-31):** Per the voiced-content non-goal in Section 21.3,
the **dialogue-surfaced** privilege families - Restoration privilege, Dialogue
privilege, and the spoken-line portion of Recognition privilege, plus the
Arngeir/Kynareth pilot in 9.4 - are **deferred to V2** because they require
voice files. **Staying in V1** are the non-voiced privileges: Shrine privilege
(activator menus), the mechanical/disposition portion of Recognition privilege
(faction stance and "Hello" preference without a new spoken line), and any
Threshold privilege that unlocks a non-dialogue effect. The CK-safe dialogue
authoring pattern is therefore a V2 concern, not a V1 blocker.

Privileges are mostly *access* effects: dialogue gates, shrine options, faction reactions, recognition. They don't need new magic effects; they need consistent CK Conditions on existing records and a stable naming convention so they're discoverable.

### 9.1 Privilege families

Each family is a label, not a separate subsystem. They share infrastructure (mirror globals + state-track globals + StorageUtil keys read via Papyrus-condition `GetVMQuestVariable`).

| Family | Surface | CK gate |
|---|---|---|
| Shrine privilege | Activator scripts on shrines | `PDV_GLO_ActiveTier >= 2` + `PDV_GLO_ActiveDeityIndex == N` |
| Restoration privilege | Dialogue topics with priests, ritual quests | Multi-condition: tier + state-track + piety |
| Dialogue privilege | NPC dialogue topics across the world | Tier + origin race + optional state-track |
| Recognition privilege | NPC faction stance / "Hello" topic preference | Tier + state-track + faction membership |
| Threshold privilege | One-time unlocks (e.g. Greybeards recognition for high Kynareth Nord) | Piety high-water mark in StorageUtil |

### 9.2 Naming

- `PDV_Privilege_<Domain>_<Description>` for dialogue topics and unique records.
- `PDV_Cond_<Reason>` as a comment label on CK Condition stacks for searchability (not a record EditorID; CK Conditions don't have names, this is a convention for human-readable design docs).

### 9.3 The "one mirror global, many privileges" pattern

The three v2 mirror globals (`PDV_GLO_ActivePiety`, `PDV_GLO_ActiveTier`, `PDV_GLO_ActiveDeityIndex`) plus the new state-track globals are read by potentially hundreds of CK Condition stacks. v3 does not add new mirror globals for every privilege class - that's the trap v1 fell into. Instead, privileges compose from the existing globals plus condition stacks.

Where a privilege genuinely needs a value not surfaced by the mirrors (e.g. "highest piety this character has ever reached on Kynareth"), use a dedicated additional global behind the same write-only-cache discipline. Add the global only when the condition is needed by content; don't speculatively pre-mirror.

### 9.4 Privilege pilot and shrine discipline

- **Greybeards-Kynareth recognition (V2 - voiced).** This Arngeir/Kynareth recognition line is a spoken NPC dialogue beat and is deferred to V2 per the Section 21.3 voiced-content non-goal; the design below is retained as the V2 specification. D-10 is resolved and runtime-proven: Phase 11's first privilege pilot is an Arngeir/Kynareth recognition line for a Nord Kyne Champion. The CK-readable gate is `PDV_GLO_OriginRace = Nord`, `PDV_GLO_ActiveDeityIndex = Kyne`, and `PDV_GLO_ActiveTier >= 3`, with Arngeir as the speaker gate. The generated PDV-owned dialogue records were removed on 2026-05-24 after CrashLogger tied a CTD to the generated topic/branch shape; the live replacement is CK-authored and verifier-covered as a `DLBR`, `DIAL`, and CK-authored unnamed `INFO`. Runtime proof passed for the positive Nord/Kyne Champion state, the non-Nord negative, the wrong-active-deity negative, the below-Champion negative, and save/load sanity.
- **Shrine activator overlays.** PDV does not replace vanilla shrine activator scripts for 1.0. Preferred posture is per-reference co-attachment on the actual shrine reference when a specific shrine needs devotional routing; helper objects or nearby activators are fallback proof shapes only. Global base-script replacement stays out of bounds so shrine-modifying mods remain easier to coexist with.

---

## 10. Contextual favor subsystem (Phase 12)

Contextual favors are automatic, signal-triggered temporary boosts. They are not hotbar powers, lesser powers, or player-invoked religion abilities. An authored preferred signal for the active patron, path, mode, or substrate may also trigger a favor. They are the main carrier of race-specific identity per the locked hybrid boon policy.

Phase 12 is a favor-first phase, not a toast-hardening phase and not a generic CKPE bridge-expansion phase. The first live runtime pass is locked to three lanes in one tranche:

- focused `Kyne` foreground favors
- `Nord Broad Old Ways`
- `Nord Broad Nine Divines`

The normal authoring path for this phase is the narrow direct helper plus manifest-driven readback, not generic source-plugin record creation. `tools/pdv-phase12-author --create-missing` may create the tracked Phase 12 `MGEF` / `SPEL` / `KYWD` packet and `PDV_State_NordPantheonBaseline` when absent; manual CK/xEdit shells remain fallback-only if that helper path is unavailable or intentionally bypassed.

### 10.1 Pattern

Each favor is authored as a Magic Effect or short-duration ability that the favor subsystem applies automatically after a qualifying signal. The active foreground patron/path/mode exposes its favor set, but the player can have only one contextual favor boost active at a time, globally across PDV.

```
PDV_Favor_<Lane>_<Description>            Magic Effect
PDV_SPEL_Favor_<Lane>_<Description>       Spell or short-duration carrier ability
PDV_FavorFamily_<Name>                    Shared anti-stack keyword
```

The runtime contract for Phase 12 is a hybrid split:

- `PDV__ManagerQuest` owns orchestration, lane resolution, suppression, apply/remove, expiry, and debug summary.
- A separate favor-state/effect-holder contract exists only through shared StorageUtil keys, family keywords, and stable record naming.
- Do not add a new always-on generic favor service quest in this phase.

The current `PDV.KyneFavor.ConditionMask` seam is not the general subsystem. It may remain as a Kyne-only debug adapter while the generic favor contract takes over, but future authored favor logic must route through the shared Phase 12 state model instead of Kyne-only mask math.

### 10.2 Marked-signal rule

Favor eligibility is authored, not inferred from piety sign. Most favor triggers will be positive piety signals, but some costly or ambiguous events may trigger a favor when they are meaningfully faithful to the current god/path/layer. Examples include defiance under Concordat pressure, re-commitment after rupture, cure-and-return rites, or choosing orthodoxy after a dissonant Altmer event.

Pure penalties, failures, hostile-rival signals, and ordinary negative drift do not trigger favors unless an explicit restoration or recommitment signal is authored. Implementation-facing matrix rows should carry an explicit `CanTriggerFavor` / `FavorFamily` decision rather than deriving favor eligibility from positive piety alone.

### 10.3 One-active-boost cap

The cap is global across all PDV contextual favors, including temporary favors from substrates. A Khajiit lunar favor and Khenarthi road favor, for example, cannot both be active temporary boosts at the same time.

For Phase 12, this cap suppresses new activation while another favor is active. Do not replace an active favor in place, and do not refresh an already-active favor's timer from a second trigger during this phase.

Outside the cap:

- Baseline blessings
- Low-power persistent substrate boons
- Religious privileges
- Neglect state changes
- Restoration state changes, unless they grant a temporary contextual favor

### 10.4 Favor count target

The race-architecture pre-matrix requirements call for 3-5 contextual favor trigger families per devotional lane. A lane may be a focused deity, path, mode, substrate layer, or broad-worship state depending on the race architecture.

These should be sourced from the same authored tables that decide what generates piety. v3 enforces 5 as a soft cap; the verifier should warn if a lane's contextual-favor trigger list exceeds 5.

Broad worship is a lane, not a request to activate every individual deity's favor set. Broad-worship lanes get 3-5 blended trigger families, remain capped at Faithful / Tier 2, and should feel culturally complete but softer and less personal than focused Devoted patron favor sets.

### 10.5 Duration buckets

Use a small shared duration vocabulary instead of custom timing per deity:

| Bucket | Use for | Target duration |
|---|---|---|
| `Momentary combat favor` | Mercy, near-death, impossible odds, honorable kill, protecting someone | 30-90 seconds |
| `After-act favor` | Death rites, oath kept, caravan aid, meaningful quest beat | 2-4 in-game hours |
| `Environmental favor` | Storm, water, road, tomb, shrine, dawn/dusk, outdoor sleep aftermath | While the context is true or until the place/time window ends |
| `Rare major favor` | HoonDing make-way, Ash'abah major tomb cleansing, Baan Dar reversal, major patron recognition | 24 in-game hours |

Player-facing language should describe these as "for this fight," "for this journey," "while I am in the sacred context," or "until the next day," not as precise timer mechanics.

### 10.6 Surfacing ladder

The shorter the favor, the quieter it should be. Most short combat favors should be felt through the effect itself rather than announced. Longer or rarer favors can be surfaced more clearly because they are less likely to spam the player.

| Surfacing level | Default bucket | Player feedback |
|---|---|---|
| `Quiet` | Momentary combat favor | No notification by default; effect icon or felt gameplay change only |
| `Noted` | After-act favor, environmental favor | Short notification when the context is meaningful and rare enough |
| `Marked` | Rare major favor, costly-but-faithful restoration/recommitment moments | Named notification or message; reserved for moments the player should remember |

Costly-but-faithful events may be surfaced one level higher than their duration bucket when the point of the event is that the character paid a real theological cost.

### 10.7 Family caps (anti-stack)

Multiple favors from the same effect family (e.g. "frost resistance," "shout cooldown reduction") should not stack into burst power. The one-active-boost rule is the primary guardrail. v3 also enforces this via:

- **Keyword tagging.** Each `PDV_Favor_*` magic effect carries one or more `PDV_FavorFamily_<Name>` keywords (e.g. `PDV_FavorFamily_FrostResist`, `PDV_FavorFamily_ShoutCooldown`).
- **Cap enforcement.** Cross-deity favors within the same family use the same numerical value rather than additively stacking. Implementation: prefer "Set Value" / "Max Of" archetypes over "Mod Value" archetypes where Skyrim's magic effect resolution allows.

This is design discipline more than a script feature. The verifier should detect "multiple PDV_FavorFamily_X effects with Mod Value archetype" as a balance warning.

### 10.8 Authoring overhead

Each favor is: one magic effect or short-duration ability, one trigger-family entry in the patron's contextual-favor set, a family keyword, and any needed CK Condition stack. A typical patron has 3-5 favors where the lane calls for contextual favor support. Across the full Phase 20 roster, favor count is roster-driven rather than capped by the old 25-35 deity estimate; this remains manageable only if every lane is matrix-owned, verifier-visible, and promoted through proven authoring patterns.

### 10.9 Phase 12 pilot lock

Phase 12 is the first real runtime of the contextual-favor subsystem. The lock for this phase is:

- `Kyne` focused foreground lane with 4 trigger families:
  - `open-sky rest recovery`
  - `storm-road grace`
  - `guided hunt`
  - `wind-marked passage`
- `Nord Broad Old Ways` with the 5 trigger families locked in `race-sheets/PDV_RaceDesign_Nord.md`
- `Nord Broad Nine Divines` with the 5 trigger families locked in `race-sheets/PDV_RaceDesign_Nord.md`

Focused Kyne proves the deeper personal lane. The two Nord broad lanes prove that shared broad worship is a first-class lane with softer, Faithful-capped output rather than a bundle of every individual deity's patron favors.

### 10.10 Runtime shape

Phase 12 stores the minimum generic state needed to make favors durable and verifier-visible:

- active lane id
- active favor family
- active effect/spell or logical favor id
- activation timestamp
- expiration timestamp
- last-trigger anti-farm state per lane/family

The manager should expose one generic debug summary string for MCM and runtime proof rather than phase-specific one-off counters.

---

## 11. Daedric path architecture (Phase 13)

Daedric paths run on the same tier spine as Aedric devotion but use a different contract grammar - per the race architecture Daedric matrix, every Daedric path has a `boon / price / stigma` triple and is mostly event-driven rather than ambient-accumulating.

### 11.1 Pattern

`PDV_DaedricPath_<Prince>` quests are siblings of `PDV_Deity_<X>` quests but with extended properties:

```papyrus
Scriptname PDV_DaedricPathBase extends PDV_DeityBase

; -- Contract layer --
Spell    Property Price_Seeker Auto              ; the cost of accepting the boon at this tier
Spell    Property Price_Devoted Auto
Spell    Property Price_Champion Auto

; -- Stigma layer --
Float    Property StigmaPerEvent = 1.0 Auto      ; passive social stigma accrued per devotional act
GlobalVariable Property StigmaGlobal Auto        ; cumulative stigma readout

; -- Commitment gate --
Int      Property CommitmentSignalsRequired = 3 Auto    ; how many distinct Prince-aligned events before path is open
```

### 11.2 Boon/price/stigma resolution

- **Boon.** Same as Aedric: `Boon_Seeker`, `Boon_Devoted`, `Boon_Champion` spells granted by tier.
- **Price.** A parallel spell that applies a thematic drawback when the boon is active. Examples: Hircine boon (hunt favor) + price (NPC hostility from civilized factions); Boethiah boon (deception strength) + price (oath-bond difficulty with companions).
- **Stigma.** A cumulative social-readability metric. Each Daedric devotional act adds stigma; high stigma manifests as NPC reactions, dialogue gates, faction wariness. Stigma decays slowly with abstention.

### 11.3 Commitment gating

Unlike Aedric deities, Daedric paths require *commitment signals* before they begin awarding piety. A new Khajiit cannot accidentally accrue Boethiah piety by killing a bandit - that signal does not count for Boethiah until the player has performed N (default 3) distinct Boethiah-coded acts (an oath-break, an assassination on Boethiah's "Bait", a deception quest resolution, etc.).

Implementation: each Daedric path tracks `PDV.Daedric.<Prince>.CommitmentSignals` in StorageUtil. Until that counter exceeds `CommitmentSignalsRequired`, `ScoreAction()` returns 0 and the path's contract is not engaged. Once committed, `ScoreAction()` resolves normally.

The first full runtime proof for this subsystem is locked as `Hircine + Nord`.
Phase 13 does not broaden into a second Prince until the Hircine/Nord
boon/price/stigma, curse-entry, cure/renounce, and residue loop are all stable.

### 11.4 Per-race response

The Daedric matrix encodes per-race response as `<State>; <Stigma/Friction>; <Exit>` cells. v3 stores these on `PDV_DaedricPathBase`:

```papyrus
Int[]    Property StateByRace Auto       ; Native / Legible / Tolerated / Taboo / Hostile / Curse (length 10)
Float[]  Property StigmaModByRace Auto   ; multiplier on StigmaPerEvent per race
Int[]    Property ExitDifficultyByRace Auto  ; 0=easy, 3=structurally hard
```

Native-integrated exceptions (Azura/Azurah for Khajiit, Boethra for Dunmer, Mafala for Dunmer, Malacath/Mauloch for Orsimer) override the standard Daedric contract: stigma is zero or near-zero for the integrated race, and these paths behave more like Aedric deities for that race.

### 11.5 Naming

- `PDV_DaedricPath_<Prince>` for the quest. `PDV_DaedricPath_Boethiah`, `PDV_DaedricPath_Hircine`.
- `PDV_DaedricPathBase` for the base class.
- `PDV_FLST_AllDaedricPaths` is the operational Daedric roster for routing,
  verifier, and MCM. `PDV_FLST_AllDeities` remains the live
  Aedric/cultural roster.
- Preserve a future roster module as the seam so callers do not bake FormList
  reads directly, but the 1.0 contract keeps the Daedric roster separate.

### 11.6 Locked Daedric defaults

- **D-12: Separate operational roster.** Keep `PDV_FLST_AllDaedricPaths` and
  `PDV_FLST_AllDeities` separate. Do not converge them during the Hircine-only
  Phase 13 tranche.
- **D-13: Mixed recovery by default.** Cure or renounce starts recovery; rites
  or authored restoration beats accelerate or complete it. Race/lane handlers
  may harden or soften recovery, but the default is not instant absolution and
  not rite-only absolution.
- **D-14: Reduced cross-Prince hostility.** Canonical Prince-vs-Prince
  hostility uses reduced rivalry math rather than full Aedric-strength
  cancellation and rather than stigma-only treatment.
- **D-15: Stigma model.** Daedric stigma uses the four-band `WitchcraftExposure`
  shape - `Latent` (`0..25`, no notification), `Suspected` (`26..50`), `Known`
  (`51..75`), `Notorious` (`76..100`). Stigma is stored **per Prince**
  (`PDV.Daedric.<Prince>.Stigma`, mirrored to the `StigmaGlobal` property), and
  broad social reactions key off a derived `PDV_GLO_DaedricExposure = max(active
  path stigma)` rather than an additive sum, consistent with D-14. Base accrual
  is scaled by a per-Prince weight class - `Tolerated` (Meridia, Peryite, about
  0.5x), `Standard` (1.0x), `High-rupture` (Mehrunes Dagon, Molag Bal, about
  1.5x) - then by `StigmaModByRace`; native-integration (Section 11.4) forces
  zero stigma for the integrated race. Stigma decays slowly at 1/day with the
  Phase 17 once-per-day guard and clears fully to `Latent`; the only permanent
  residue is a one-way `PDV.Daedric.<Prince>.WasChampion` dialogue flag set on
  first Champion entry. The full rationale and the per-Prince class list are in
  `references/authoring/PDV_Daedric_DecisionPacket_CAT4.md`.
- **D-16: Curse-access template variation.** Hircine and Molag Bal are
  curse-access Princes: their commitment gate is a curse acquisition
  (lycanthropy, vampirism), not a chosen pact. The `_Commitment` slot is
  reframed as a curse-onset message, stigma is driven by the Phase 15
  curse-state overlay rather than a per-act counter, and exit is the cure path
  (D-13), not renounce. Boon, price, tier-up, and per-race response author
  normally. Curse-access Princes coordinate with - and must not duplicate or
  double-fire - the race manifest per-race `CurseState` rows. Hircine is a
  content-surface-only pass because its Phase 13/15 mechanics are already
  runtime-proven; Molag Bal is the new curse-access build.
- **D-17: Daedric authoring order.** The 15 non-pilot Princes are authored in a
  template-variation proof batch first - Azura (native-override), Vaermina
  (pure standard), Meridia (`Tolerated` class), Molag Bal (curse-access) - to
  prove all four template shapes before volume, then the remaining Princes in
  batches by template type. The full batch list is in the decision packet.
- **D-18: Per-Prince content-ready definition.** A Prince is content-ready for
  the 20C gate when all Section 6 row types are authored (tone, boon/price x3,
  tier-up + lapse, Champion entry, commitment or curse-onset, stigma or
  curse-driven crossings, neglect + exit with residue, per-race response for
  non-native races), matrix fidelity matches `PDV_DaedricRacePrinceMatrix.csv`,
  the hook source is named, `pdv_content_verify` is clean with no race-manifest
  slot collision, and the firing-density sanity paragraph is present. This is
  the content gate only; runtime proof and world placement follow on the code
  track.

---

## 12. Patron commitment mechanism (Phase 14)

Earlier race-architecture drafts described patron commitment in v1 bucket-threshold terms. The bucket system was removed in v2. v3 implements commitment using per-deity piety thresholds, per-race candidate filters, and state-track eligibility.

### 12.1 Commitment trigger

Dawn-tick consolidation already runs per-deity. Add a post-consolidation pass:

```papyrus
Function ProcessCommitmentOffers()
    ; Only if no current patron, or current patron is "broad worship" sentinel
    if PDV_GLO_PatronDeity.GetValue() != 0 && !IsBroadWorshipSentinel()
        return
    endif
    ; Find candidates: deities whose persistent piety crossed an offer threshold
    ; AND who are eligible by state-track filter
    ; AND who has not already received or refused this qualification offer
    ; Fire the highest-current-priority qualifying offer; do not persist a queue
EndFunction
```

Formal patron offers use the shared 1.0 gate unless a race-specific exception is documented: evaluate during the dawn pass only, require the Faithful / Tier 2 threshold (`50` persistent piety by default), require qualifying signal activity on at least two separate in-game days within the last seven days, and fire at most one offer. A deity offers once when it first qualifies; `Not Yet` does not start a timer, and re-offer requires genuine re-qualification after piety falls below the offer threshold and later climbs back. Refuse is terminal for that deity. Do not persist pending-offer queues; recompute candidates each dawn from current ledgers, state tracks, recent signal evidence, and the per-deity `PDV.Commitment.Offered` / `PDV.Commitment.Refused` guards.

### 12.2 Offer threshold

Per-deity threshold plus StorageUtil guards:

```papyrus
Float Property CommitmentOfferThreshold = 50.0 Auto      ; Faithful threshold required to fire the offer
; deity-form StorageUtil key: PDV.Commitment.Offered = 1 after an offer is presented
; deity-form StorageUtil key: PDV.Commitment.Refused = 1 after terminal refusal
```

Most formal patron-offer deities use the default 50.0, matching the Faithful / Tier 2 threshold. A deity should not offer commitment because the player showed early interest; the offer represents sustained faith deep enough to move from broad relationship into primary commitment. Multi-domain deities (Mara, Talos) can require a higher threshold or a combined check across multiple `PDV.Piety.<*>` reads. Race-specific exceptions must be explicitly documented; Khajiit remain the standing no-formal-offer exception.

### 12.3 Offer presentation

The offer is an in-world threshold event, not an MCM toggle. Per the locked Nord/Imperial designs:

- **Notification + dialogue topic.** A traveling priest, a dream sequence, a shrine epiphany. Content-author-driven.
- **Player choice: Accept / Not Yet / Refuse.**
  - Accept: current `PDV.Piety` is preserved, patron is set, the broad boon is suppressed, and Nord/Imperial focused reward eligibility begins at T2.
  - Not Yet: patron remains unset and the deity will not offer again unless piety lapses below the threshold and later re-qualifies.
  - Refuse: terminal per-deity response. The deity will not ask again.

### 12.4 Multi-offer ordering

If multiple deities qualify simultaneously, fire at most one offer in the dawn cycle. Select by highest recent signal strength, using DeityIndex only as a deterministic tie-breaker. Player resolves before the next dawn can surface another candidate.

For 1.0, offer recomputation runs only while the player is unset or in broad worship. Once a formal patron offer is accepted, `PDV_GLO_PatronState` becomes active primary, `PDV_GLO_PatronDeity` stores the accepted deity, candidate recomputation stops, and no competing patron offers fire. Devotion decay may weaken the active patron relationship, but it does not silently clear or replace the accepted patron. Patron switching / reorientation is deferred to a post-1.0 explicit in-world rupture or restoration feature unless a race-specific exception is documented.

### 12.4a Khajiit emergent patron exception (LOCKED)

Khajiit are the **only race** that bypasses the standard `ProcessCommitmentOffers()` mechanism entirely. Per confirmed lore (UESP, Imperial Library), Khajiit gravitate toward specific deities through life-role without formal declarations.

Instead of firing an offer, the Khajiit substrate runs a silent weight-shift evaluation at dawn that:
- Reads behavioral signal patterns across recent days
- Shifts deity emphasis weight without player notification
- Allows the player to notice via shifted blessings rather than an explicit offer

No popup, no shrine event, no "Azurah notices you" moment. The emergent patron is recognized by the system when one deity's domain has clearly become the player's life. The moons already knew.

### 12.5 "Broad worship" as a first-class state

For race designs where broad worship is culturally normal and experientially useful, broad worship is a real state, not just "no patron set." v3 introduces:

- `PDV_GLO_PatronState` stores the explicit patron state: unset, broad worship, or active patron. `PDV_GLO_PatronDeity` remains an active-target cache only when the state is active; do not overload it with broad-worship sentinels.
- Broad worship is represented by `PDV_GLO_PatronState`, not by a race-specific Broad/Primary state track. A race-specific setup choice may set an orthogonal state track such as pantheon baseline, sect, or tradition.
- Under broad worship, scoring is dampened and capped at Tier 2 for 1.0 unless later race content proves a narrower exception is needed.
- Commitment offers still fire from under broad worship; accepting transitions out of broad.
- Broad worship counts as its own contextual-favor lane. It receives blended Faithful-capped favor families rather than enabling every individual deity's patron favor set.

Broad-worship lane eligibility is content-authored, not automatic for every race with multiple worship targets. Current first-release posture: Nord, Imperial, and Redguard receive broad-worship lanes; Dunmer uses a special layered equivalent; Breton and Altmer do not receive a generic broad lane.

Imperial and Nord use the following first-class broad-pool refinement:

- `ImperialDivines`, `NordOldWays`, and `NordNineDivines` are manager-owned
  StorageUtil pools, not deity records and not sums of deity piety.
- Every deity keeps its own ordinary signed piety. A logical devotional act
  contributes once to the eligible active pool using its strongest applied
  positive delta, or its most severe applied negative delta if there is no
  positive.
- Pool scratch folds at dawn with the existing scaling and signed `4.3` cap.
  Persistent thresholds are `25/50`, cap `50`, highest-slot-only, and no T3.
- Inactive or commitment-suppressed pools persist but decay after two idle days
  at `0.1` per dawn to floor zero.
- Nord Old Ways and Nine Divines have identical pool mechanics. Their roster,
  theology, and effect packet may differ; their completeness may not.
- Patron acceptance at deity piety `50` preserves piety, suppresses the broad
  boon, and begins at focused T2. Focused T1 is compatibility-only for Nord and
  Imperial; T3 begins at `85`. Below `50`, commitment persists but its boon is
  suspended.

### 12.6 Commitment offer defaults

- **Broad-worship Tier cap.** Broad worship defaults to Tier 2 for 1.0. Per-race exceptions are content-author decisions only if playtest feedback shows the default breaks a specific culture.
- **Offer choices.** Commitment offers use `Accept / Not Yet / Refuse` for 1.0. A stronger `Renounce` path is deferred past 1.0 unless content later needs a distinct rupture mechanic.

---

## 13. Curse-state overlay (Phase 15)

Werewolf and Vampire transitions shift theological weights per race. The race architecture reference specifies these weights per-race; v3 implements them as a single overlay quest with per-race weight tables.

### 13.1 Pattern

`PDV_CurseState` is the single curse-detection seam. Future vanilla and compat
support should arrive as detection adapters behind this module rather than
spreading werewolf/vampire checks across deity scripts, the manager, or MCM.
For Phase 15, the locked default is combined werewolf detection: active beast
race plus afflicted-state / faction / quest-style evidence on the same shared
service seam.

```papyrus
Scriptname PDV_CurseState extends Quest

Int Property CURSE_NONE = 0 AutoReadOnly
Int Property CURSE_WEREWOLF = 1 AutoReadOnly
Int Property CURSE_VAMPIRE = 2 AutoReadOnly

GlobalVariable Property CurseStateGlobal Auto    ; PDV_GLO_CurseState

; -- Detection hooks --
Event OnPlayerLoadGame()
    RecomputeCurseState()
EndEvent

Function RecomputeCurseState()
    Actor player = Game.GetPlayer()
    Int newState = CURSE_NONE
    if player.HasKeyword(WerewolfRaceKW) || player.GetRace() == WerewolfBeastRace
        newState = CURSE_WEREWOLF
    elseif player.HasKeyword(VampireKW) || PlayerIsVampire()
        newState = CURSE_VAMPIRE
    endif
    if newState != CurseStateGlobal.GetValueInt()
        OnCurseStateChange(CurseStateGlobal.GetValueInt(), newState)
        CurseStateGlobal.SetValueInt(newState)
    endif
EndFunction
```

### 13.2 Per-race per-deity weight modifier

`PDV_DeityBase` extends with a curse-modifier table:

```papyrus
; Length 30: 10 races x 3 curse states (None/Werewolf/Vampire)
Float[] Property GainMultByRaceAndCurse Auto

Float Function GetCurseModifier()
    Int race = PDV_GLO_OriginRace.GetValueInt()
    Int curse = PDV_GLO_CurseState.GetValueInt()
    return GainMultByRaceAndCurse[race * 3 + curse]
EndFunction
```

`PDV__ManagerQuest.AwardPiety` composes curse modifier with stance multiplier and (if present) reputation track multiplier.

### 13.3 Curse-state transitions

When the player becomes a werewolf or vampire:

- `OnCurseStateChange(oldState, newState)` fires per deity (iterate `PDV_FLST_AllDeities`).
- Deities can implement transition reactions: e.g. Vampire Imperial collapses Divine devotion entirely per the locked race file; this fires as a one-time `PDV.Piety.<Divine>` reduction with a notification.
- The cure path is structurally the reverse: piety doesn't fully restore on cure, but the multiplier reactivates.

The service remains shared even when response behavior is race-owned. Bosmer,
Breton, Dunmer, Altmer, and Nord curse reactions should be handled as
race/lane-specific consequences hanging off the same curse transition seam, not
as separate curse systems.

### 13.4 Curse-state restoration path

The race architecture reference flags restoration paths as content-author concerns. v3 architecturally supports them via:

- **Threshold quest stages** in race-specific restoration quests (post-1.0 content).
- **Rededication rituals** that can write `PDV.Piety` directly via curated signals.
- **Tier downgrade on transition** so the player has measurable lost ground to recover.

### 13.5 Altmer vampire micro-path (LOCKED)

Altmer vampires gain access to an "Exiled Altmer" redirected micro-path rather than being left in a mechanically dead state. This is NOT a full worship lane; it is a survival-identity path:

- Capped at Tier 1 (no deep devotion available in vampire state)
- Represents self-reconstruction and refusal to collapse
- Rewards maintaining identity despite exile from Aedric devotion
- Enhancement-level custom content (not essential for 1.0 core function)

Implementation: a special-case branch in the Altmer curse-transition handler that enables a lightweight "Exiled Altmer" boon path when `OriginRace == RACE_ALTMER && CurseState == CURSE_VAMPIRE`. This path uses the substrate pattern (Section 8) but with a hard Tier 1 cap.

### 13.6 Curse decisions

- **Source of Werewolf detection.** Companions-quest-specific keyword? Race check? v3 should test on a vanilla Companions run first.
- **Hybrid Necromancer / Daedric overlap.** Curse state modifies multipliers, eligibility pressure, and interpretation. It does not auto-open Daedric paths; Hircine, Molag Bal, or other curse-adjacent paths still require commitment signals before real progression.

### 13.7 Curse-access framing is per-race weight, not template variance (clarification)

The curse-access **mechanical template** for Hircine and Molag Bal is locked once
in D-16 (Section 11.6): commitment gate = curse acquisition, `_Commitment`
reframed as curse-onset, stigma from this Phase 15 overlay, exit = cure path,
coordinated with -- never double-firing against -- race-manifest `CurseState` rows.

The *strength* of the consequence is a different axis and lives in the per-race
per-curse `GainMultByRaceAndCurse` table (Section 13.2). So a Nord vampire's Sovngarde
**severance** versus a Nord werewolf's **strain** are two different cells in that
table, both expressed through the one template -- vampirism is authored as the
deeper rupture across the roster; werewolf is the recoverable strain. This is the
system working as intended, anchored by Section 13.6's rule that curse state never
auto-opens a path. The earlier "curse-access asymmetry to ratify" flag is closed
on this basis; rationale of record
`references/authoring/PDV_DecisionMemo_CurseAccessReconciliation.md`. Missing
per-race curse-access response rows (e.g. Orc Molag Bal) are tracked as D-18
content-completeness items, not design decisions. The player-facing half -- telling
the player what changed at curse onset **and cure** -- is the Section 16.7 `curse`
transition class.

---

## 14. Neglect subsystem (Phase 16)

Neglect per the race architecture reference is mostly **loss of access**, not
large debuffs. Tier downgrade is the main "you lost it" feedback; secondary
thematic effects are small. The design target is legible and recoverable
friction, not death-by-a-thousand-cuts punishment.

### 14.1 What neglect looks like

- **Tier downgrade.** Piety drops below a threshold -> tier decreases -> boons revoke and contextual-favor ability spell is removed -> privileges (which were CK-condition-gated on tier) silently stop working.
- **Optional small thematic effect.** Per the race reference: "The Hist's silence weighs on you, far from Black Marsh. Health regeneration slowed." A single small magic effect, tier-locked, applied only when neglect is "active" (a specific neglected state, not just low piety).

### 14.2 Where neglect lives

Neglect eligibility lives on deity records, but activation is dawn-owned by
`PDV__ManagerQuest`, not by each deity acting independently. Each deity may
define a `NeglectEffect` and `NeglectActivePietyMax`, then the manager selects
the lowest-piety eligible deities at dawn, caps the active set at 3, and
suppresses all per-deity neglect during broad worship.

```papyrus
Function RunDawnApplySpellAndNeglectLayers()
    if IsBroadWorshipActive()
        ClearAllNeglectFlags()
        return
    endif

    ; Select the lowest-piety eligible deities and cap the active set.
    ; Current manager default: NEGLECT_ACTIVE_CAP = 3
EndFunction
```

This keeps neglect quiet, legible, and bounded even at full-pantheon scale.

### 14.3 Per-race neglect

Some races have race-wide neglect effects (Argonian Hist absence) that are not tied to a single deity. These belong on the race substrate quest (Section 8), not on a deity.

### 14.4 Locked neglect defaults

- **Active neglect cap:** 3 simultaneously active per-deity neglect effects at most, chosen from the lowest-piety eligible deities.
- **Broad worship suppression:** broad worship suppresses all per-deity neglect effects.
- **Intent:** neglect remains a readable "you have drifted" layer rather than a stack of ambient punishment spells.

---

## 15. Decay model (Phase 17)

Decay was deferred in v2. v3 now treats the live manager defaults as the
forward architecture: per-deity linear decay, a grace period before drift
starts, a tier floor, and reduced-rate broad-worship decay. The goal is
relationship drift that is slow and recoverable, not a daily servicing loop.
As of v3.46, this model is runtime-proven from a fresh-save proof pass. Runtime
also promoted `PDV.PassiveDecayFloor` as the persistent floor key so a deity
that has reached Devoted or Champion cannot decay below the locked floor later.
As of v3.80, the balancing retune standardizes live deity thresholds to
`25/50/85`, shortens passive-decay grace to `2.0` days, scales dawn gains by
`1.32` before the `4.3` daily cap, and gives vampire curse state a floor bypass
for deities marked `IsAedric`.

**Balancing-pass retune (live as of v3.80; see `references/authoring/PDV_DecayAudit.md`).**
The Phase 17 pseudocode below records the older proof model at
`DECAY_GRACE_DAYS = 3`; the live retune now uses `DECAY_GRACE_DAYS = 2`, a
`TIER_DOWN_HYSTERESIS = 5.0`, and vampire floor bypass for Aedric deities while
werewolf decay still respects the floor. Orc decay stays at **base 0.5/day for
all life-modes**; the mode multiplier scales gain only, with no Orc-specific
decay constant. DruidicStanding is unchanged.

### 15.1 Mechanism

Daily, at dawn, after `PietyToday` is consolidated:

```papyrus
Function ApplyDecayToDeity(PDV_DeityBase deity, Float nowTime)
    if GetPatronState() == PATRON_STATE_ACTIVE && deity == _activeDeity
        return   ; active patrons are protected from passive drift
    endif
    Float lastEventGameTime = StorageUtil.GetFloatValue(self, "PDV.LastEventGameTime")
    if (nowTime - lastEventGameTime) < DECAY_GRACE_DAYS
        return   ; grace period - no decay
    endif
    Float currentPiety = StorageUtil.GetFloatValue(self, "PDV.Piety")
    Float multiplier = 1.0
    if IsBroadWorshipActive()
        multiplier = BROAD_WORSHIP_DECAY_MULTIPLIER
    endif
    Float decayRate = DECAY_PER_DAY * multiplier * GetReputationDecayMultiplier(deity)
    Float floor = GetDecayFloorForDeity(deity, currentPiety)
    if PDV_CurseStateService.IsVampire() && deity.IsAedric
        floor = 0.0                              ; vampire rupture bypasses Aedric floors
    endif
    Float newPiety = currentPiety - decayRate
    if newPiety < floor
        newPiety = floor
    endif
    StorageUtil.SetFloatValue(self, "PDV.Piety", newPiety)
EndFunction
```

### 15.2 Decay floors

Per the locked design, Champion tier should not decay below Devoted threshold; that's the "Champion is hard-earned, hard to lose" promise.

```papyrus
Float Function GetDecayFloor()
    Int tier = StorageUtil.GetFloatValue(self, "PDV.Tier") as Int
    Float storedFloor = StorageUtil.GetFloatValue(self, "PDV.PassiveDecayFloor")
    Float currentFloor = 0.0
    if tier >= 3
        currentFloor = ThresholdDevoted    ; Champion floor at Devoted threshold
    elseif tier >= 2
        currentFloor = ThresholdSeeker     ; Devoted floor at Seeker threshold
    elseif tier >= 1
        currentFloor = 0.0                 ; Seeker can decay to None
    endif
    if storedFloor > currentFloor
        return storedFloor
    endif
    return currentFloor
EndFunction
```

Tier demotion is also buffered by a `5.0` piety hysteresis window: if the
recomputed tier would drop but current piety is still within five points below
the old tier's threshold, the old tier remains visible.

### 15.3 Decay rate

Default is locked at `0.5` piety per day after a `2.0` day grace period.
Per-deity tuning is still allowed later, but the baseline architecture now
assumes this default. Curse states can multiply decay rate and can also change
floors: vampire state bypasses passive tier floors for `IsAedric` records, so
Aedric/Divine devotion can fall below previously earned floors during vampire
rupture. Reputation tracks can also modify decay pressure (Concordat Enforcer
state decays Talos faster).

Positive dawn gains are paced by `GAIN_RATE_SCALE = 1.32` before the existing
daily cap, now `PIETY_DAILY_MAX_DELTA = 4.3`. Orc life-mode pacing applies only
after that clamp and only to future Malacath gain: Stronghold `1.0`, City
`0.75`, Legion/Exile `0.60`. Decay is not scaled by Orc life mode.

### 15.4 Decay vs broad worship

Under broad worship, decay applies to all deities at a reduced rate
(`0.2x` default). Under an active patron, passive decay applies to
non-patron deities at normal rate while the active patron is skipped by the
passive drift routine.

### 15.5 Phase 17 closeout status

The standalone Phase 17 source/readback gate is
`node .\tools\pdv_verify.mjs --strict-phase17`. The full Phase 18 bridge gate is
`node .\tools\pdv_verify.mjs --strict-phase16 --strict-phase17 --strict-phase18 --strict-nord --strict-phase13 --strict-phase14 --strict-phase15`.
The current full bridge verifier result after the v3.79 balancing retune is
`PASS=2369, INFO=29`, with no `FAIL`, `WARN`, or `TODO`. Fresh-save Phase 17 proof passed grace
no-op (`20.00 -> 20.00`), eligible tick (`20.00 -> 19.50`), same-day guard
(`19.50` held), broad-worship reduced decay (`20.00 -> 19.90`), active-patron
skip, non-patron drift while Kyne stayed protected, Devoted floor
(`50.00 -> 25.00`), and Champion floor (`85.00 -> 50.00`). Phase 16 regression
also held: broad worship suppressed neglect (`count=0; kyneSpell=0`) and active
Kyne still produced targeted neglect (`count=1; active=Kyne; kyneSpell=1`).

---

## 16. Player-facing UI (Phase 18)

The Phase 5 dev MCM is explicitly not the player surface. Phase 18A now builds the player surface on top of the dev MCM and adds in-world feedback through `Survey Devotion`.

### 16.1 MCM evolution

Current Phase 18A structure:

- **Player tab.** Always visible. Shows thematic summary, mode, patron, standing, curse, favor, and neglect rows, plus a `Survey Devotion` readout action. Numeric piety is not shown here.
- **Status page.** Existing roster/status diagnostics. Locked until the player enables `Developer Options`.
- **Debug page.** Existing mutation and proof controls. Locked until the player enables `Developer Options`.

Developer Options are stored in `StorageUtil` key `PDV.UI.DeveloperOptions`, so the setting is save-persistent.

### 16.2 In-world feedback

- **Status spell or lesser power.** `Survey Devotion` is implemented as `PDV_SPEL_SurveyDevotion` + `PDV_MGEF_SurveyDevotion` backed by `PDV_SurveyDevotionEffect`. Cast it to get a manager-owned thematic `MessageBox`. Numeric piety remains dev-only.
- **Notifications.** Three levels per the race-architecture reference:
  - **Quiet** (no notification): routine piety gain/loss, most dawn consolidations, ambient drift.
  - **Medium** (Notification): tier change, neglect threshold crossed, or a similarly legible state shift.
  - **Loud** (MessageBox): commitment offer, refuse-and-rupture, curse-state transition, restoration rite completion.

Detailed scoring remains debug-only. Normal play should understand major
changes without being narrated through every event fire.

Phase 18B Nord-specific rule: while a Nord is a vampire, formal Nord commitment offers and contextual favors are suppressed. Cure restores access but leaves a visible scar/status note. This is curse feedback and rupture handling, not a Molag Bal progression lane, and it does not clear patron piety. The counted runtime matrix for this rule is now part of the Phase 18 manifest and runbook.

### 16.3 Recognition and dialogue boundary

V1 does not add new NPC conversation lines, voiced responses, lip files, scene
content, or broad recognition topics. Race-coded recognition for V1 must use
non-voiced player-facing surfaces first: Survey Devotion text, MCM Player-page
rows, MessageBoxes, notifications, spell/effect descriptions, books/notes, safe
service or shrine gates, and Prisma toasts where supported. NPC recognition and
conversation content moves to a planned V2 enhancement track unless a later
release explicitly adopts a no-voice/lip strategy and the CK dialogue proof
lane remains clean.

The previous 1.0 target of ~30-50 race-coded dialogue topics is retired. Treat
the existing dialogue work below as technical proof and retained prototype
evidence, not as a V1 content-volume requirement.

Phase 18B locks the first Nord review quartet into `references/authoring/PDV_Phase18StatusNord.manifest.json` and `references/authoring/PDV_Phase18_StatusNord_Runbook.md`:

- Froki: Nord origin, active Kyne, Champion or higher.
- Heimskr: Nord origin, active Talos, Champion or higher.
- Andurs: Nord origin, broad patron state, not vampire.
- Aela: Nord origin plus werewolf curse state or active Hircine path.

These topics are CK-authored/live in `Devotion.esp`. CK saved the INFO records unnamed; strict readback accepts unnamed Topic Info only when speaker, prompt, response, owning topic, and conditions match. Phase 18 closeout also now carries a runtime matrix covering Player-page behavior, Developer Options persistence, Survey Devotion for broad/focused Nord states, Hircine/werewolf tension, vampire suppression/cure scar, save/load persistence, and positive/negative checks for all four dialogue surfaces. They prove the CK-safe recognition path, but they do not reopen V1 scope for new NPC conversation lines.

### 16.4 UI defaults

- **Thematic by default.** Player-facing status uses thematic language first, with numeric values behind a debug/advanced MCM preference for power users.
- **In-world patron switching.** Switching from one patron to another mid-game is a theological act and is deferred past 1.0 as an explicit rupture / restoration / reorientation feature. In 1.0, accepting a formal patron prevents competing patron offers; MCM patron swap remains dev-only for testing.

### 16.5 Prisma devotional surface

The Prisma surface is the current prototype path for player-facing devotional
texture. Until the player surface is promoted, the full panel remains reachable
only from MCM/debug or another explicit development opener. Runtime gameplay may
send transient overlay toasts through `PDV_PrismaBridge.SendOverlayJson()`
without focusing the panel.

Smoke expectations:

- Opening the panel from the MCM/debug opener shows the patron, today, and debug
  views without console or bridge errors.
- A real active-patron devotional gain can raise a transient deity-symbol toast
  without opening or focusing the full panel.
- `ProcessDawn()` can raise a transient dawn/system-symbol toast.
- Toasts are short-lived, symbol-led, and quiet enough for normal play; routine
  scoring still must not become notification spam.
- A missing toast with otherwise correct piety math is treated as a Prisma
  smoke failure, not as a devotional scoring failure.

### 16.6 Prisma UI repo boundary and staging

Default repo posture is bounded monorepo. Prisma UI source stays beside the
SKSE bridge and Papyrus payload declaration under `native/DevotionPrismaBridge/`
because the surface is currently tightly coupled to PDV's runtime payloads.
Prisma UI design notes must not override core piety, StorageUtil, dawn,
EventBus, or CK record architecture.

Source-of-truth rules:

- Editable Prisma UI source lives under
  `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/`.
- `scratch/DevotionPrismaDemo.html` is a generated/share review aid, not
  canonical source.
- Payload schemas become contracts only when documented in the bridge README or
  this architecture section.
- Overlay toasts for `favor`, `dawn`, `neglect`, `tier`, and `rivalry` are the
  current stable payload contract; panel payloads and any other event shapes
  remain prototype until a later player-surface pass promotes them.
- MCM remains configuration/debug/opening support until a later player-facing
  MCM pass explicitly changes that boundary.

UI staging sequence:

1. Accessibility hardening: tab semantics, keyboard navigation, focus states,
   live-region behavior, reduced motion, color contrast, and text scaling.
2. Payload contract cleanup: mark toast/panel payload fields as prototype,
   stable, or deprecated.
3. Visual system pass: symbols, spacing, tone colors, responsive constraints,
   and Skyrim overlay readability.
4. Runtime integration expansion: route more real devotional events through
   `SendOverlayJson()` without increasing notification spam.
5. Smoke/tester workflow: keep the local preview, static share demo, and
   in-game Prisma smoke aligned.

Reassess a separate Prisma UI repo only when at least two are true: it needs
its own JS build system, asset pipeline, UI test suite, release cadence,
non-PDV reuse target, large reusable visual asset set, or recurring UI context
noise that distracts from Papyrus/CK architecture work.

### 16.7 Transition surfacing contract (V1)

The mod computes meaningful state transitions it does not consistently tell the
player about. The end-to-end immersion audit
(`references/authoring/PDV_ImmersionAudit_MissedOpportunities.md`) found this is
the single highest-value, lowest-cost V1 immersion investment: the systems are
sound, they are just silent. This subsection makes "surface the transitions" an
explicit V1 implementation contract. It is a discipline over the existing Section 16.2
notification levels and the Section 16.6 toast payload contract -- not a new UI system --
and it stays inside the Section 16.3 non-voiced boundary (notifications, MessageBoxes,
Survey/status, Prisma toasts only; no new NPC dialogue or voice).

**The five transition classes that must surface.** Each fires once per direction
(guarded so reload/`RecomputeCurseState`/dawn re-evaluation does not re-fire),
and routine per-act scoring stays Quiet -- this is about legible *state changes*,
not narrating every event.

| Class | Trigger | Level (Section 16.2) | Toast (Section 16.6) | Notes / gap closed |
|-------|---------|---------------|---------------|--------------------|
| `tier` | Broad worship first reaches Faithful, then Devoted | Medium (Notification) | `tier` | First-reach one-shot per tier; the "you've reached Faithful" beat is currently absent for every race |
| `emergence` | A focused patron / emphasis first dominates | Loud (MessageBox) | `tier` | Khajiit's automatic first focus uses its own deity-specific ceremonial MessageBox plus Prisma toast and pinned Book entry; later automatic reorientation has no popup. Argonian Sithis activation continues to use the shared transition surface. |
| `curse` | Curse **onset and cure**, per curse type | Loud (MessageBox) | `neglect`/system | Onset already fires (Section 13.3); **cure is the missing half** across races. Coordinates with the D-16 cure-path exit; must not double-fire against race `CurseState` rows |
| `reorientation` | A confirmed sect / mode / tradition / path / standing switch, or a newly qualifying Khajiit focus | Medium, Loud if a major theological reorientation | system | Redguard sect, Orc mode, Bosmer path, Imperial Concordat standing, and Khajiit automatic focus replacement. Fire on the *confirmed* switch only; Khajiit uses toast plus unpinned Book entry. |
| `neglect` | A god first crosses a neglect threshold (tier drop) | Medium (Notification) | `neglect` | Cadence rule below; closes "tiers slip with no explanation" |

**Neglect firing cadence (resolves the Section 14 open).** A neglect notification fires
**once per tier-drop**, and not again for that deity until the player **recovers a
tier**. This prevents both spam (re-firing while hovering at a threshold) and
silence (never telling the player a god went quiet). Recovery re-arms the one-shot.

**Shared implementation shape.** Route all five through one manager helper rather
than scattering notification calls:

```papyrus
; PDV__ManagerQuest
; eventClass: "tier" | "emergence" | "curse" | "reorientation" | "neglect"
; key: deity/race/curse discriminator so the one-shot is per-subject-per-direction
Function SurfaceTransition(String eventClass, String key, String direction)
    String guard = "PDV.Surfaced." + eventClass + "." + key + "." + direction
    if StorageUtil.GetIntValue(none, guard) == 1
        return                                  ; already surfaced this direction
    endif
    StorageUtil.SetIntValue(none, guard, 1)
    ; pick Quiet/Medium/Loud per the table, route to Notification or MessageBox,
    ; and send the matching Prisma toast via PDV_PrismaBridge.SendOverlayJson().
EndFunction
```

- One-shot guards live under the `PDV.Surfaced.*` StorageUtil namespace, save-persistent.
- The **opposite-direction** transition clears the guard for the direction it
  re-enables (e.g. recovering a tier clears that deity's `neglect` guard;
  curing a curse clears the onset guard and arms the cure beat).
- Copy is authored per the Section 16.3 surfaces and the content-destination slot types
  in `race-sheets/PDV_ContentDestinationMatrix.md`; no new voiced or NPC content.

**Worked example -- Imperial Concordat Talos gate (do not interrupt; make state
legible).** When high Concordat compliance blocks a Talos offer, the offer must
still *fail gracefully* -- no offer-time "blocked" popup (Imperial design rule,
`race-sheets/PDV_RaceDesign_Imperial.md:226`). The political cost is surfaced
instead through the `reorientation` class at the moment **standing** changes
(crossing into `Public Compliant` / `Concordat Enforcer`) and through the
compliant Survey/status line. Rationale of record:
`references/authoring/PDV_DecisionMemo_ImperialComplianceLane.md`.

**V1 scope.** Implement the five classes and the shared helper; author per-race
copy for the transitions each race can hit. This is the "surface the transitions"
V1 workstream named in the immersion audit. It does not change scoring, piety,
curse, or Daedric mechanics -- only whether the player is told.

**Coverage / wiring.** The per-race copy for these transitions is essentially
already drafted in `race-sheets/PDV_RaceContent_Manifest.md`.
`references/authoring/PDV_TransitionSurfacing_CoverageMap.md` binds each class to
the existing slot IDs per race, marks the N/A cells, gives the `PDV.Surfaced.*`
guard keys, and records one behavioural clarification: `tier` fires only at
Observant/Faithful, and the **Devoted** crossing is surfaced once by the
`emergence` class (per-deity Champion entry) to avoid a double-fire at Devoted.

---

## 17. Content authoring pipeline (Phase 19)

By 1.0 the full Phase 20 roster will include every locked race-architecture
worship target plus all sixteen Skyrim-present Daedric Prince surfaces, three
strong substrate quests, several light sacred-place/state helpers, five
first-release reputation tracks, roughly 8-10 state tracks, roster-driven
contextual favor effects, and many dialogue topics.
The pipeline matters.

The player-facing prose this pipeline promotes is drafted ahead of time on the
content authoring track (25.9); this section covers only the code-side
promotion of ratified strings into records.

### 17.0 Structural scaffold code order

The first Structural Skeleton code-deepening pass added compile-clean base
scripts before any large CK content authoring. These scripts are inert until CK
records attach them, but they make verifier and authoring work concrete:

1. `PDV_ReputationTrack.psc`: backing global, threshold labels, lock-in state, `Adjust()` / `ForceSet()` API.
2. `PDV_StateTrack.psc`: backing global, state labels, transition policy, `SetState()` / `ResetForDebug()` API.
3. `PDV_SubstrateBase.psc`: origin gate, aggregate metric keys, tier recompute, substrate boon sync.
4. `PDV_SacredPlace.psc`: designated locations, visit timestamps, decay, reward modifier, race-specific parameter slots.
5. `PDV_DaedricPathBase.psc`: boon/price/stigma contract, race response arrays, commitment-signal gate.
6. `PDV_CurseState.psc`: central Werewolf/Vampire state, transition notification hook, modifier lookup.

Current state: source and `.pex` exist and compile with 0 errors / 0 warnings.
The locked 12-track scaffold is now merged into the framework ESP, strict
skeleton verification is green for that slice, and `PDV_MCM` has a dev-only
structural map / smoke harness. Broader substrate, sacred-place, Daedric, and
curse records are now also merged into the framework ESP, with strict
verification green for the broad scaffold wave and in-game `Show structural
map` / `Run scaffold smoke` passes confirming the scaffolds remain inert.
Pattern Proving still decides the first real content behavior per subsystem.

### 17.1 Add-a-deity workflow

1. Duplicate the most-similar proven concrete deity script (Kyne for Aedric-ambient, Talos for Aedric-hostile, first proven Prince script for Daedric).
2. Edit name, domain, stance row, rivalry list (if any), and `ScoreAction()` rubric.
3. Compile via `node tools\pdv_compile.mjs --script PDV_Deity_<X>`.
4. In CK: create the quest record, Start-Game-Enabled, attach script, fill properties (boon spells, gain modifier track if any, eligibility state track if any).
5. Add to `PDV_FLST_AllDeities` (and `PDV_FLST_AllDaedricPaths` if Daedric).
6. Generate SEQ if the quest is new and Start-Game-Enabled.
7. Update verifier expected-records.
8. In-game smoke test on a clean save.

This is mostly the same pipeline as Phase 6's Talos/Auri-El work. The big lever for reducing per-deity friction is direct record authoring through the `housecarl_*` MCP tools plus one excellent proven pattern per subsystem.

**Current tool reality (2026-07-14).** Record authoring is houseCARL, called directly. There is no local authoring bridge, adapter, or capability matrix, and none is to be rebuilt. houseCARL reads and writes every record type Mutagen models, by construction -- including the work this section previously listed as blocked:

- Stance row authoring.
- Rivalry **array** authoring (VMAD `IntArray` / `FloatArray` / `StringArray` / `ObjectArray`). The old "array writes remain manual CK/xEdit work until the Mutagen bridge can emit them" limitation belonged to the retired `pdv_author.mjs`; it does not apply to houseCARL.
- Contextual-favor ability `SPEL` + `MGEF` record creation.
- FormList membership.
- Dialogue (`DLBR` / `DIAL` / `INFO`) and SEQ. The retired `creation-authoring` `dialogue-v1` proof lane and its fail-closed capability gate described the bridge's limits, not houseCARL's.

The default write lane emits a **new** patch plugin, leaving `Devotion.esp` untouched; the in-place lane is explicit and consented. Verification is a `housecarl_read_record` / `housecarl_cross_plugin_query` readback in the same session -- that readback is the proof, with no proof-ledger or capability-promotion step in between.

If a record operation appears unsupported, **reproduce it with a direct `housecarl_*` call on the current version and read the actual error** before recording it as a limitation. Stale limitations recorded during the bridge era (archived under `_retired/bridge-era-2026-07-14/`) are not evidence. See `AGENTS.md` -> "houseCARL v1.7+ Direct Plugin Work Rule".

### 17.2 Add-a-substrate workflow

1. Create `PDV_Substrate_<Name>.psc` extending `PDV_SubstrateBase`. Implement `RegisterForSubstrateEvents()` and aggregate-metric scoring.
2. Compile.
3. In CK: create substrate quest, Start-Game-Enabled, attach script, set `RequiredOriginRace`, fill substrate boon spells.
4. Origin bootstrap (`PDV_Origin`) does not need updating - substrates self-register via their `OnInit()` and gate on `RequiredOriginRace`.
5. Verifier check: substrate quest exists, has expected properties.

### 17.3 Add-a-track workflow

Reputation track: create `PDV_RepTrack_<Name>` quest, attach `PDV_ReputationTrack` script, fill threshold table. Add `PDV_GLO_<TrackName>` global. Add reputation-track adjustments to relevant dialogue/quest fragments.

State track: same shape with `PDV_StateTrack` script.

### 17.4 Verifier coverage

The verifier needs to scale. v3 expectations:

- Per-deity: record exists, in FormList, script attached, stance row length 10, gain multipliers length 4, boon spells assigned (warn if Tier 3 unassigned, fail if Tier 1/2 missing for non-stub deities).
- Per-substrate: record exists, script attached, origin gate set, boon spells assigned per declared tiers.
- Per-track: record exists, backing global exists, threshold-array / state-array lengths match labels.
- Cross-record: rivalry FormIDs all resolve to records in `PDV_FLST_AllDeities`; eligibility-state-track FormIDs resolve to existing state tracks.

### 17.5 Pipeline defaults

- **Templating vs. duplication.** Do not add an abstract `PDV_Deity_Template.psc` for 1.0. Build one excellent concrete pattern per subsystem, then clone the closest concrete script; revisit only if script-side deity creation routinely takes more than 30 minutes before CK work.
- **MCM display order.** Use `PDV_FLST_AllDeities` order as the default display order, with an optional manual override property for special cases such as "Akatosh first."

### 17.6 Offline classification and distribution patcher

PDV should build its own **offline Mutagen-backed patcher** for
KID/SPID/SkyPatcher-like classification and distribution work instead of
making those runtime frameworks hard dependencies for core 1.0.

That direction now has a live generated-patch lane: `tools/pdv_patch.mjs`
reads tracked `pdv_patch_rules_v0` manifests under
`references/authoring/patch-rules/`, validates their schema strictly, reads the
resolved `Devotion Dev` load order through the same Mutagen/MO2 context already
used by `pdv_author.mjs` and `pdv_verify.mjs`, resolves winning target records
plus payload references, and emits deterministic `validate`, `plan`, and
`build` output. `build` writes only the generated `PDV_ClassificationPatch.esp`
artifact through the existing Mutagen bridge patch-request contract. Default
live output emits only `approved` rules; candidate and tooling-example emission
requires explicit test flags. The tracked example/proof manifests remain
tooling-only, while `PDV_Phase19TempleLocationRules.json` is the first approved
live content packet.

Working name: `tools/pdv_patch.mjs` or a dedicated Mutagen/Synthesis-style patcher. The exact host can change, but the architecture is:

1. Read the user's resolved load order.
2. Read PDV-owned classification/distribution rules from tracked CSV/JSON manifests.
3. Resolve target records from the winning load order.
4. Emit one generated patch plugin, e.g. `PDV_ClassificationPatch.esp`, with overrides only where PDV needs added keywords, FormList entries, NPC spells/perks/items, or lightweight record tweaks.
5. Verify the generated patch with `pdv_verify.mjs` before treating it as a supported artifact.

Current scope closes Steps 1-5 for the first live packet: schema validation,
load-order resolution, target/payload resolution, safe generated patch emission,
active Devotion Dev profile placement, generated-patch readback, retired
proof-rule absence, and source-plugin safety are verifier-covered by
`--strict-phase19`. Broad production classification and NPC distribution rules
remain future content work.

Packaging policy: `PDV_ClassificationPatch.esp` is a temporary generated
review/dev artifact for core rules. Approved core vanilla/DLC rules may be
promoted into `Devotion.esp` later through a separate
release-packaging merge gate. Mod-list/list-specific compatibility rules remain
separate generated patches permanently.

This is inspired by KID, SPID, and SkyPatcher, but it is intentionally **patch-build-time**, not runtime:

| Existing framework pattern | PDV-owned offline equivalent | First PDV use |
|---|---|---|
| KID keyword distribution | Add PDV semantic keywords to `WEAP`, `ARMO`, `BOOK`, `INGR`, `ALCH`, `MGEF`, `SPEL`, `LCTN`, `ACTI`, `FLOR`, `FURN`, `RACE`, and related records in a generated ESP | Green Pact tagging, sacred texts, taboo gear, offering items, magic-school/domain classification |
| SPID spell/perk/item distribution | Add spells, perks, factions, outfits/items, packages, or keywords to NPC/base-actor records in a generated ESP | Priests, Vigilants, Thalmor pressure actors, stronghold/community NPC hooks |
| SkyPatcher-style record edits | Apply declarative field patches into a generated ESP | Small compatibility/tuning patches that do not justify hand-edited CK work |
| FLM/FormList injection | Add existing records to PDV FormLists in a generated ESP | Sacred places, deity artifact lists, offering whitelists, compat FormLists |

The patcher should be **idempotent**: rerunning it with the same rules and load order produces the same patch. It should never mutate source plugins in place. Generated patches are build artifacts, not design source.

Use Mutagen rather than xEdit Pascal for the long-term tool because Mutagen exposes keyword lists and other record lists as typed APIs and handles Skyrim keyword count subrecords (`KSIZ`/`KWDA`) internally. xEdit Pascal remains a useful proofing fallback when a specific record edge case is easier to inspect interactively.

### 17.7 Runtime framework dependency posture

Runtime distribution frameworks are valuable, but PDV should not inherit them casually:

- **KID:** adopted as a strongly recommended soft dependency for optional semantic item classification. Devotion ships flat Data-root KID files for Green Pact food and seven bounded item-action families; absence of KID removes those optional signals without disabling core devotion.
- **SPID:** adopted as a strongly recommended soft dependency for bounded, non-voiced religious recognition. It distributes only PDV faith keywords and cohort factions; the manager owns Friend/Ally/explicit-rival Enemy reconciliation. It does not distribute AI packages, spells, perks, outfits, or inventory, and absence of SPID removes only NPC recognition.
- **SkyPatcher:** excellent conceptually for declarative patching, but current public docs/snippets show a powerofthree's Tweaks dependency. PDV should copy the design idea into its own offline patcher before making it a runtime requirement.
- **PO3 Papyrus Extender:** accepted as a hard runtime dependency for event hooks that cannot be baked into an ESP. This also brings Address Library and powerofthree's Tweaks into the runtime dependency chain. Treat PO3 as separate from classification/distribution: it is for runtime events, not keyword/NPC distribution.
- **JContainers:** keep out of 1.0 core unless a later rule format genuinely needs nested runtime data. Build-time JSON manifests do not require JContainers.

Default rule: if the work can be compiled into a patch plugin, PDV should tool it offline. If the work needs to observe runtime-only behavior, then a runtime framework may be justified.

---

## 18. ESP module structure (decision)

The v2 design and the `AGENTS.md` ESP Structure section both diagram a future per-race ESP split (`PDV_Nord.esp`, `PDV_Imperial.esp`, etc.). v3 keeps the framework ESP monolithic through 1.0 and revisits a split only if a Section 18.2 trigger hits.

### 18.1 Rationale

- **Cross-race rivalry.** Talos `HOSTILE` for Altmer means `PDV_Deity_Talos.RivalDeities` must reference `PDV_Deity_AuriEl`. Separating these into per-race ESPs forces cross-ESP FormID references, which complicates load-order discipline and overlay-patch authoring.
- **Shared stance matrix.** The 10x30 stance grid lives partly on each deity quest. Per-race ESPs would not own *their* deities cleanly - Mara is in both the Nord and Imperial pantheons, not one or the other.
- **Shared contextual-favor families.** A favor family ("frost resistance") shared across patron deities needs one Keyword record. Cross-ESP keyword sharing works but adds friction.
- **One verifier target.** The verifier currently reads one ESP. Adding multi-ESP awareness is doable but not free.

### 18.2 When to split

Split per-race ESPs only if one or more of the following hits:

- The framework ESP approaches Skyrim's load-order or record-count practical limits. This remains unlikely, but the full Phase 20 roster must be rechecked against real generated record counts instead of the old 25-35 deity assumption.
- A specific race module has so much dialogue or quest content that it deserves its own load-order slot for compatibility patching.
- A community contributor wants to author a race module independently.

### 18.3 Optional compatibility ESPs

Mod compatibility patches (Requiem, Sacrosanct, etc.) live in their own ESPs (Section 20). That is unrelated to the per-race split question.

---

## 19. Performance budget

At the full Phase 20 roster, the v2 architecture's hot paths still scale linearly with deity/path count. v3 sets explicit budgets so we know when to optimize.

### 19.1 Targets

| Path | Cost shape | Budget |
|---|---|---|
| Kill event route | O(N) FormList iteration, each calling `ScoreAction()` | < 5ms total |
| Dawn consolidation | O(N) per-deity scratch-to-persistent + tier recompute + decay + neglect | < 50ms total |
| MCM Status page render | O(N) per-deity readout | < 100ms render |
| Patron switch | O(N) for old-boon revoke + new-boon grant + mirror refresh | < 30ms |

### 19.2 Mitigations available before any code change

- **Stance early-out.** If a deity's stance for the player's race is `FOREIGN` with no possibility of HOSTILE-driven rivalry, `ScoreAction()` can return 0 early without running the rubric. Many deities will be FOREIGN for any given race - this skips most of the per-deity work.
- **Decay batching.** Apply decay only when `Utility.GetCurrentGameTime() - lastDecayPass > 1.0`, not every dawn-tick check.
- **Lazy contextual-favor recompute.** Don't re-apply contextual-favor abilities on every tier change; only on patron-switch and tier-crossing.

### 19.3 Performance instrumentation

- **Papyrus stack depth.** Iterating 35 deities and calling `ScoreAction()` on each is well within Papyrus limits but should be measured. Add optional `ProcessDawn()` stack-depth benchmarking around Phase 12, after contextual favors create the first realistic per-deity workload.
- **StorageUtil read costs.** Reading `PDV.Piety` for 35 deities at dawn is 35 floats. Trivial. Reading per-event-type daily caps in the same loop adds N x M reads. Still fine, but worth measuring before adding more StorageUtil keys per deity.

---

## 20. Mod compatibility (Phase 21)

Phase 21 is now an Authoria-first, list-author compatibility program. The
release target is not end-user Wabbajack swap support; it is maintainer-ready
packages that list authors can test, accept, and include. The tracked source of
truth lives in `references/vanilla-gameplay/compatibility/phase20-targets.csv`
plus the companion notes in that folder.

Phase 21 intentionally follows the full roster/content lock. The compatibility
package lane should not begin full list smoke until Phase 20 has stabilized the
god/Prince roster, player-facing handling, and verifier-covered content
surfaces that a modlist will actually test.

The seven target lists are JOJ, TOT, HOH, MOM, DoD, VOV, and Authoria/ARR.
Authoria is the P0 proof lane. The local ARR `ARSE` profile is the first
analysis target, then the package must refresh against the Authoria authors'
current list before patch development. Local DoD is a prototype lane only until
its current public/plugin evidence is refreshed.

### 20.1 Status ladder

Compatibility status uses explicit non-public labels:

- `plugin-reviewed`: plugin/mod list and initial overlap scan complete.
- `patch-packaged`: exact removal set, one list-specific compat patch,
  placement notes, patcher steps, and maintainer brief are ready.
- `author-testing`: the package is with the list author for testing.
- `smoke-passed`: focused author or local smoke passed.
- `list-included`: the list has accepted PDV into its integration/test flow or
  public build.
- `public-supported`: PDV can publicly name the list as supported.

Public claims wait until endorsement/inclusion. Repo docs may name technical
targets and evidence, but must not imply maintainer approval before it exists.

### 20.2 Patch package rules

Each target list receives one list-specific compatibility patch, ESL-flagged
unless record count, FormID shape, or tooling makes that unsafe. Shared
templates or rules may be reused internally, but the author-facing package
should not require a stack of generic compatibility ESPs.

Patch constraints:

- Do not edit list-owned plugins directly.
- Keep masters minimal: base game files, `Devotion.esp`, and
  only the target plugins whose records are touched.
- List patches win over generic internal templates.
- No new hard dependencies are added for Phase 21.
- Requiem lists receive PDV input patches and a reference-only RFTI output for
  the exact snapshot; the list author regenerates final RFTI/Reqtificator
  output in their own stack.

### 20.3 Replacement and adapter policy

PDV is replacement-first for religion overhauls. A target list should remove
the active religion overhaul plus direct dependent religion patches. Other
religion mods such as Wintersun, Pilgrim, Archon, or Gods and Worship are
research sources and removal targets, not 1.0 coexistence systems.

Shrine behavior is hybrid:

- PDV may own replacement religion shrine reward behavior through targeted
  adapters for the core religion set.
- Do not replace global vanilla shrine activator scripts.
- Reference/classify survival, visual, temple, statue, and worldspace content
  rather than taking ownership of those systems.
- Cover vanilla Divine/Talos and major Daedric worship surfaces plus visible
  list-added replacements. Unsupported deities receive context-only
  recognition rather than invented blessing mechanics.

System-family rules:

- **Survival/needs:** context only. Survival state can affect eligibility,
  caps, or duplicate-punishment avoidance, but not raw piety gain/loss.
- **Curse mods:** curated theology transitions only: onset, cure, voluntary
  embrace/renunciation, major feeding/restraint choices, beast-form rites, and
  Hircine/Molag Bal/Azura-relevant moments.
- **Quest/newland mods:** high-signal theology hooks only, with stable stages,
  clear religious meaning, and supported-list relevance.
- **Adult/romance/social frameworks:** curated authored hooks only. Do not add
  generic framework event adapters.
- **Requiem:** core PDV remains vanilla-plus; Requiem/list-specific balance
  lives in the compatibility patch.

Compatibility patches may tune mechanics, route signals, and classify records,
but they must not change PDV theology, race/deity topology, patron logic, or
player-facing doctrine.

### 20.4 Custom race support

Custom races resolve into one of PDV's ten existing race profiles. V1 does not
add bespoke custom-race deity rosters or eleventh race paths.

Supported integration routes:

- RaceCompatibility ActorProxy keywords.
- Race Blood Test `Treat` / `Morph` rules.
- Explicit PapyrusUtil fallback entries in `PDV_RaceMap.json`.

Ohmes-Raht / Half-Khajiit maps to Khajiit profile `6` by default through
`0x03322B|HalfKhajiit.esp` and `0x05693A|HalfKhajiit.esp`. Temporary beast-form
race records use `PDV_TemporaryRaceMap.json` so origin capture defers while the
player is transformed; they are not permanent cultural-origin mappings.

Readback proof and support claims stay separate. Current ARR/DoD local
Half-Khajiit plugins expose only `HalfKhajiitRace` and
`HalfKhajiitRaceVampire`, with no `HalfKhajiitWerewolf`; runtime/manual custom
race smoke remains a separate gate.

### 20.5 Handoff and smoke

Each maintainer brief must include the exact removal set, exact load-order
placement block, required patcher reruns, known non-blocking issues, and a
focused smoke checklist. Non-local lists may start from public Bordello
load-order pages; if author files differ, allow one normal package revision.

Static analysis before packaging is names-plus-conflicts: scan plugin/mod
names, then inspect targeted record conflicts for shrines, spells/effects,
quests, races, keywords, globals, and patch masters. The PDV scanner/Mutagen
style is preferred first; xEdit is the fallback for ambiguous conflicts.

Focused smoke covers startup, MCM/status, shrine prayer, one devotion action,
relevant curse/survival case where applicable, dawn tick, save/reload, and
Papyrus log review. Smoke fails on missing masters, crash/startup failure, PDV
Papyrus errors, broken MCM/status/prayer/dawn/save flows, or unresolved
high-risk record conflicts. Handoff packages may carry only non-blocking known
issues: cosmetic conflicts, unsupported outlier shrines, deferred quest hooks,
or low-risk warnings.

---

## 21. Forward phase plan

Each phase ends in a runnable mod. Phase ordering is sequenced for value-per-phase and to allow each phase to be tested before the next builds on it.

The roadmap gates in Section 25 now sit in front of this phase sequence. V3
Preflight and the Structural Skeleton pass must complete before Phase 7 signal
expansion begins. Pattern Proving is the first content-bearing wave: build one
excellent reusable example per subsystem, then clone.

| Phase | Subsystem | Dependencies | Acceptance |
|---|---|---|---|
| **V3 Preflight** | Architecture hardening | Proven v2 Phase 4/5/6 baseline | WorshipTarget base, service split, patron state, EventBus/EventTypes, dawn order, gain pipeline, schema hooks, and verifier hard-fails are compile/verifier/smoke clean |
| **V3 Structural Skeleton** | Full 1.0 structural scaffold | V3 Preflight | Dev-only scaffold targets, locked race tracks, and strong substrates are inert, hidden from player surfaces, and verifier-visible |
| **V3 Pattern Proving** | One excellent reusable pattern per subsystem | Structural Skeleton | Imperial Concordat, Bosmer Path, Dunmer Ancestor, Khajiit emergent/moon-cycle exception, contextual favor family, Daedric price/stigma path, commitment offer, and neglect/decay path are proven |
| **7** | Signal expansion (sleep, shrine, shout, social) | V3 Preflight + EventBus pattern | New events routed; per-target rubric updates; signal policy anti-farm caps functional |
| **8** | Reputation track + first instance (Concordat Standing) | Phase 7 | Imperial Concordat bands, wide Uncommitted state, edge walk-back gate, committed-state multiplier composition, and save/load persistence are runtime-proven; verifier covers |
| **9** | State track + first instance (Bosmer Path) | Phase 8 | Bosmer path setup, destination-gated offers, confirmation-rite switching, Old Contract PactBound/compliance separation, reckoning renounce/recommit, save/load persistence, framework ESP readback, and placed proof-reference routing are runtime-proven; verifier covers |
| **10** | Race substrate (Dunmer Ancestor first pilot) | Phase 9 | Portable-shrine prayer and home bonus grant origin-only substrate progress; substrate metric stays separate from patron piety |
| **11** | Privilege subsystem first wave (Arngeir/Kynareth pilot; Mara deferred until the pattern proves clean) | Phase 8/9 plus Section 21.5 commitment and neglect/decay gates | CK conditions read mirror globals + track globals; the Arngeir/Kynareth dialogue pilot gates cleanly for Nord Kyne Champion and hides for non-Nord, wrong deity, or lower tier |
| **12** | Contextual favor subsystem (focused Kyne plus Nord broad-lane pilot) | Phase 11 | Focused Kyne plus Broad Old Ways and Broad Nine Divines prove the generic favor runtime, 3-5 trigger families per lane, and the one-active-boost cap |
| **13** | Daedric path architecture + first Prince (Hircine/Nord pilot) | Phase 12 | Runtime-proven for the Hircine gate and first live exit loop: negative no-piety pre-gate rites, Seeker and Devoted price activation, werewolf curse-entry pressure, cure-started residue, renounce reset plus residue, and the vampire negative path |
| **14** | Patron commitment mechanism (generic formal-offer engine) | Phase 12/13 | Kyne proves the generic offer surface end to end: seed/evaluate, decline, refuse, accept, and accepted-patron stability |
| **15** | Curse-state overlay (shared service; werewolf and vampire live) | Phase 14 | Shared curse seam is runtime-proven for werewolf, vampire, and clear transitions; Hircine/Nord handlers trace live through curse-entry and werewolf-cure routing |
| **16** | Neglect subsystem (generic per-deity selection, max 3 active) | Phase 14 | Generic neglect selection is runtime-proven for low-piety active Kyne plus broad-worship suppression clearing the active neglect set on re-evaluation |
| **17** | Decay model (linear with tier-floor + grace) | Phase 14 | Runtime-proven for grace, eligible tick, same-day guard, broad reduction, active-patron skip, non-patron drift, Devoted floor, and Champion floor |
| **18** | Player-facing UI (player MCM tab, status spell, notification policy) | Phase 14 | Thematic display default; numeric override behind toggle |
| **19** | Content authoring pipeline expansion (`pdv_author.mjs` scope + offline patcher + verifier coverage) | Parallel | Planning-first patcher validates rules against the resolved load order, `pdv_author.mjs` emits explicit manual follow-up packets for array work, and later generated classification patches can add PDV keywords/FormList entries from rules |
| **20** | 1.0 content lock + polish | All above | Pantheon at 25-35 deities, all 10 races have at least one foreground option, all locked race architectures honored; Aedric and Daedric authored content complete |
| **21** | Mod compatibility first patch (Sacrosanct for vampire cross-routing) | Phase 15 | Sacrosanct feed events translate to PDV signals; no double-fire |

V3 Preflight and Structural Skeleton are acceleration gates: they make the
system safe to scale before broad content lands. Phases 7-9 then widen what the
system can see and react to. Phases 10-12 are the per-race overlay layer. Phase
13 brings Daedric paths online. Phases 14-17 turn the system from "tracks
piety" into "feels like a relationship." Phase 18 is the player handoff.
Phase 19 is tooling; Phase 20 is the authored content lock (Aedric and Daedric); Phase 21 is compat.

### 21.1 What "1.0" means

For content-rich 1.0:

- All locked race-architecture worship targets are implemented as content-ready deities or cultural worship surfaces.
- All sixteen Skyrim-present Daedric Prince surfaces are content-ready: Azura, Boethiah, Mephala, Malacath, Meridia, Hircine, Molag Bal, Nocturnal, Hermaeus Mora, Mehrunes Dagon, Sheogorath, Namira, Sanguine, Clavicus Vile, Peryite, and Vaermina. Nocturnal is represented through the Thieves Guild / Nightingale surface. Jyggalag remains excluded unless future adopted content explicitly adds him.
- Every race/deity and race/Prince pairing has explicit authored handling: response state, commitment gate, boon/favor surface, price/neglect/stigma, exit/residue, hook source, and player-facing feedback. This does not mean every race can worship every target safely.
- Native, tolerated, foreign, taboo, hostile, and curse-access paths all have player-facing feedback.
- Dev-only scaffold may exist while Phase 20 is being built, but no Skyrim-present god or Prince may remain dev-only at the 1.0 lock.
- Curse states (Werewolf + Vampire) are functional.
- Patron commitment, decay, and neglect are all live.
- Player-facing UI is thematic-by-default.
- New NPC conversation/recognition lines are out of V1 scope; use non-voiced
  Survey, MCM, MessageBox, notification, spell/effect, book/note, service-gate,
  shrine, or Prisma surfaces for V1 recognition.
- Normal play is quiet, recoverable, and vanilla-plus rather than chore-loop driven.
- Authoria has an accepted integration/test package. JOJ, TOT, HOH, MOM, DoD,
  and VOV are at least `patch-packaged`.
- No regression of any v2 invariant.

Phase 20 is split into roster-completion slices:

- **20A - Roster and coverage matrix.** Maintain
  `references/authoring/PDV_DeityCoverageMatrix.json` as the implementation
  authority by reconciling race sheets, the Phase 4 stance matrix, the Phase 4
  Daedric matrix, and the locked race architecture.
- **20B - Full Aedric/native god content.** Promote all non-Daedric
  race-relevant gods from scaffold or draft into content-ready lanes, including
  Divines, Talos/Ysmir, Old Ways, Yokudan, Khajiit, Dunmer, Altmer, Orc,
  Argonian, Breton, Bosmer, and other locked cultural targets.
- **20C - Full Skyrim-present Daedric content.** Build all sixteen
  Skyrim-present Prince surfaces with Hircine as the proven pattern for
  boon/price/stigma/exit/readout discipline.
- **20D - Race completeness passes.** Verify every race has authored handling
  across the full roster, including unsafe, taboo, hostile, and curse-access
  meanings.
- **20E - Content-rich 1.0 lock.** Close verifier coverage, runtime smoke,
  text polish, package readiness, compatibility gates, and performance budget
  rechecks against the full roster.

Race gameplay parity is the cross-cutting Phase 20 product gate. Use
`references/authoring/PDV_RaceGameplayBalanceAudit.md` for the multi-lens
audit, `PDV_RaceRewardBudgetLedger.md` and
`PDV_RacePlaystyleCoverageLedger.md` for reward/playstyle pressure, and
`PDV_RaceImplementationCostingBacklog.md` to translate accepted audit findings
into state artifacts, hook sources, rejected-hook assertions, player surfacing,
verifier gates, runtime proof, and compatibility notes before implementation.
The first implementation-costing manifest set covers Altmer, Argonian, Orc,
Redguard, Bosmer non-hunter parity, and Khajiit, with
`--strict-phase20-race-costing` as the shared manifest/content/source/readback
gate as each race moves beyond `costed-not-built`. Altmer
also keeps the narrower `--strict-phase20-altmer` crisis/Lorkhan/favor gate
until that runtime slice is built and proven.

### 21.2 Custom content priority classification (LOCKED)

Essential custom content (required for the racial theology layer to be playable):
- **Argonian:** Hist sap meditation, death-rites support, Arkay-priest reactions, community NPC reactions
- **Dunmer:** Ancestor ceremonies, portable shrine item/animation, ash-shrine interaction
- **Khajiit:** Moon observance flavor, road-home/circuit acknowledgment, emergent patron blessings
- **Orc:** Community investment system (NPC disposition reactions, faction-favor proxy)
- **Bosmer:** PDV-owned Green Pact tag layer, pact-compliance/violation feedback

Enhancement custom content (improves experience, not required for core function):
- **Altmer:** Post-vampire Exiled Altmer path flavor

### 21.3 Explicit non-goals for 1.0

- No original multi-stage questlines. Per the race-architecture pre-matrix requirements, the first release uses existing gameplay loops and CK-gated interactions, not bespoke quest arcs. Light authored moments such as commitment offers, shrine/ritual interactions, and notifications are in scope. NPC dialogue recognition is **not** in 1.0 scope - see the voiced-content non-goal below.
- **No voiced content in 1.0 (voiced NPC dialogue deferred to V2).** V1 ships no NPC spoken dialogue, because credible NPC lines need voice files and voice work is explicitly held for V2. Deferred to V2: the Phase 11 privilege dialogue/restoration/recognition families and the Arngeir/Kynareth recognition pilot; the Phase 18 Nord recognition quartet (Froki, Heimskr, Andurs, Aela); and the 39 `PDV_Dlog_*_Recognition` stubs drafted across the roster. V1 delivers every player-facing beat through non-voiced surfaces only: MessageBoxes, corner notifications, Survey Devotion readouts, shrine-activator menus, and mechanical faction/disposition/stance effects. **Scope-mapping rule:** where a race sheet or this document describes a "dialogue privilege" or NPC "recognition" payoff, V1 delivers the non-voiced equivalent (notification, MessageBox, Survey readout, or disposition/stance effect) and the spoken-dialogue version lands in V2; metaphorical "feels like recognition" design language is unaffected. **Build action (pending, CK-side):** the already-live Phase 18 Nord dialogue records (`DLBR`/`DIAL`/`INFO`) must be disabled or removed from the V1 release ESP, and their Phase 18 verifier assertions move to V2 scope.
- No hard Survival/Requiem dependency.
- No DLL plugins authored by PDV.
- No hard KID, SPID, or SkyPatcher dependency solely for keyword/classification/NPC distribution. KID and SPID are strongly recommended soft dependencies for the shipped semantic-item and non-voiced NPC-recognition extensions; Devotion remains functional without them. powerofthree's Tweaks remains accepted through the PO3 Papyrus Extender runtime-event dependency chain.
- No replacement of vanilla shrine activator scripts. Prefer per-reference co-attachment or overlay receiver patterns instead of global base-script overrides.

### 21.4 Implementation-plan review after race-sheet cleanup

The race-sheet cleanup does not change the phase order. It does tighten the
acceptance criteria for the next implementation plans:

- Structural Skeleton now starts from the compile-clean base scaffold scripts named in Section 17.0; next it must add verifier visibility for dev-only records.
- Phase 7 signal expansion must use event/curated-signal vocabulary, not bucket terminology, and must preserve the quiet/event-led/recoverable gameplay posture.
- Phase 8-10 Pattern Proving remains the right first content wave, but the pilots are now fixed: Imperial Concordat, Bosmer Path, Dunmer Ancestor, and Khajiit emergent patron/moon cycle.
- Orc City/Legion community remains a sacred-place contextual modifier, not a strong substrate.
- Broad worship remains a first-class patron state with Tier 2 cap for 1.0; Khajiit remains the only no-offer exception.
- No v2 implementation needs to be reopened solely because of the race sheets.

### 21.5 v3.16 implementation handoff plan

This section is the operating handoff from architecture to build work. It does
not replace the subsystem sections above; it tells future sessions which deep
module pattern must be proven first, what interface it exposes to the next
slice, and what evidence closes the slice. Do not clone broad content from a
slice until its verifier and normal-play proof are both clean.

**Implementation-ready definition:**

A slice is implementation-ready when all of the following are true:

- Its owning subsystem is named in v3 and its race/product acceptance is named
  in `PDV_TargetEndStates_1.0.md`.
- The race-specific rules it depends on are locked in
  `references/PDV_RaceArchitecture_DesignReference.md` or the relevant
  `race-sheets/Race_*.md`.
- Any compressed planning source has been expanded into implementation fields.
  For Daedric work, the race-sheet treatment map is acceptance context only;
  the target Prince/race cells from
  `references/phase4/PDV_DaedricRacePrinceMatrix.csv` must be expanded into
  the Section 11 contract fields before coding or CK authoring starts.
- The interface is small enough to call from EventBus, manager dawn, deity
  scoring, or CK Conditions without callers learning the slice internals.
- The verifier can distinguish missing records/properties from intentional
  dev-only scaffolds.
- There is one normal-play in-game proof path. Debug/MCM helpers may accelerate
  setup, but they do not count as the only proof.
- No open decision in Section 24 blocks the slice, or the handoff card names
  the explicit waiver that lets the slice proceed.

**First implementation packet checklist:**

Before starting a Pattern Proving slice, create a short working handoff note in
chat or in the implementation issue using the handoff-card template below. It
should answer the contract questions before any Papyrus or CK work begins.

1. Record the current baseline: `git status --short`, latest verifier command
   and result, current in-game proof state, and known waivers such as duplicate
   VMAD or SEQ freshness.
2. Name the narrow slice and its owner. Avoid mixing reputation, substrate,
   favor, commitment, Daedric, curse, and neglect behavior in one build pass
   unless the table below explicitly couples them.
3. Pull the source contract from the owning docs: v3 subsystem section,
   `PDV_TargetEndStates_1.0.md`, the relevant race sheet, and
   `references/PDV_RaceArchitecture_DesignReference.md`.
4. Define the data shape: StorageUtil keys, globals, FormLists, CK records,
   script properties, arrays, manifest rows, and MCM/debug visibility.
5. Define the normal-play proof path, including setup, trigger, expected
   traces, player-visible feedback, dawn behavior, save/load expectation, and
   cleanup/exit route where relevant.
6. Define the clone boundary: what future slices may reuse after this proof,
   and what remains a pilot-only shortcut.
7. After implementation, update only the living docs that own changed facts and
   add verifier coverage before broadening the pattern.

**Handoff card template:**

Use this shape before starting any slice:

| Field | Required answer |
|---|---|
| Slice | Short name and v3 phase |
| Owning module | Signal, reputation track, state track, substrate, favor, Daedric path, commitment, curse, neglect, decay, UI, or authoring |
| Source contract | Exact v3 section, target-tracker section, race sheet, matrix, or reference rule being implemented |
| Interface guarantee | What other modules can rely on without knowing implementation details |
| Data/state shape | StorageUtil keys, globals, FormLists, records, properties, arrays, and MCM/debug visibility |
| Implementation locations | Papyrus scripts, CK records, FormLists, globals, manifests, verifier paths |
| Entry gate | Prior slices, open decisions, and required current verifier state |
| Verifier gate | Exact strict/default verifier expectation |
| In-game proof | One repeatable normal-play scenario, player feedback, dawn behavior, save/load expectation, and log/screen evidence expected |
| Exit/recovery | How the player backs out, cures, rededicates, decays, or clears residue where the slice creates lasting state |
| Not in scope | What must not be pulled forward by enthusiasm |
| Docs touched | v3, target tracker, race sheet, `AGENTS.md`, `PDV_MOD_SETUP.md`, or none |

**Pattern Proving build order:**

2026-05-20 phase-order review outcome: adopt a reduced reorder only. Do not add
standalone base-script-verification or signal-breadth slices: Structural
Skeleton and the current Phase 7 proof already cover those seams in the live
repo state. The live order change is to prove commitment before decay, make
decay/favor tuning decay-aware, harden privilege and Prisma toast contracts
before the first full Daedric price/stigma pilot, and push curse-state after
that Daedric comparison point.

| Order | Slice | Owns / proves | Interface guarantee | Entry gate | Done when |
|---:|---|---|---|---|---|
| 0 | Baseline inventory | Confirms the closed Preflight/Skeleton and current Pattern Proving evidence | Future work starts from known `FAIL=0` verifier state and known partial proofs | Clean worktree; no code change | Current strict verifier commands and current in-game proof notes are recorded before new implementation begins |
| 1 | Normal-play ingress closeout | EventBus non-kill routing beyond debug-only paths | Receivers can send typed devotional events without scoring directly or knowing deity internals | Existing EventBus/PlayerEvents proof | Dunmer portable shrine/home bonus, Bosmer Green Pact, and Hircine hunt rite each have one non-debug trigger proof or an explicit waiver |
| 2 | Imperial Concordat reputation pilot | `PDV_ReputationTrack` and `ConcordatStanding` as the first real reputation track | Scoring can ask for current band/multiplier; CK can read a mirror global; callers do not know band math | Slice 1; crime events may wait if they would create empty scaffolding | Uncommitted/private/open edge walk-back works, stance multiplier composes with track multiplier, verifier covers records/properties |
| 3 | Bosmer Path state pilot | `PDV_StateTrack` and `PDV_State_BosmerPath` as the first real state track | Commitment and scoring can ask active path and eligibility; callers do not know switch proof history | Slice 2 or explicit waiver if reputation is not needed | Setup/default path, destination-gated switch, Old Contract Green Pact tagging, and PactBound separation work in normal play |
| 4 | Dunmer Ancestor substrate pilot | `PDV_Substrate_DunmerAncestor` as the first strong substrate | Dawn/scoring can adjust substrate metric without writing patron piety; CK can inspect substrate tier/posture | Slice 1; no need to wait for all state tracks | Portable shrine prayer and player-owned-home bonus grant origin-only substrate progress; vampire/werewolf posture remains separate |
| 5 | Khajiit lunar exception closeout | Lunar substrate plus emergent focused emphasis | Khajiit can update broad/focused state without formal patron offers | Slice 4 if shared substrate helpers are reused | Moon cadence, outdoor road-home practice, Observe the Moons, and focused-emphasis lead logic work without `PDV_GLO_PatronState = active primary` |
| 6 | Commitment offer pilot | Shared formal offer flow | Dawn can recompute candidates, fire at most one offer, and persist accepted patron state without a queue | Slice 3 for eligibility filtering; favor, decay, and privilege do not need to exist yet | Accept / Not Yet / Refuse works; piety is preserved on accept; Not Yet waits for lapse-and-rebuild requalification; Refuse is terminal per deity; no competing 1.0 offers fire after acceptance |
| 7 | Neglect/decay pilot | One accepted patron relationship weakening over time | Dawn owns decay and neglect effects; runtime events never write persistent decay directly | Slice 6 | Decay floors, grace, neglect spell apply/remove, and broad-worship suppression work |
| 8 | Privilege pilot | Shrine/dialogue privilege pattern | CK Conditions can read mirror globals and track globals without script glue in dialogue/shrine content | D-10 resolved; Slice 6 preferred | One shrine or dialogue privilege proves condition shape and coexistence discipline |
| 9 | Contextual favor pilot | Generic favor runtime with focused Kyne plus Nord broad-lane proof | Event/scoring can request a favor opportunity; the manager-owned favor runtime enforces one-active-boost cap, lane resolution, expiry, and anti-farm state | Slice 7; at least one reliable signal family from Slices 1-5 plus Nord baseline scaffolding | Focused Kyne and the two Nord broad lanes have locked trigger families, duration/surfacing rules work, and one-active anti-stack is verifier or smoke covered |
| 10 | UI toast hardening | Prisma overlay-toast payload contract for authored race content | Papyrus callers can rely on a stable overlay schema while the UI keeps ownership of default copy/tone expansion | Existing prototype toast path works; Slice 9 preferred before broad authored call-site growth | `favor`, `dawn`, `neglect`, `tier`, and `rivalry` all render with documented stable fields, and the README / v3 payload maturity labels agree |
| 11 | Daedric price/stigma pilot | First full Daedric path price/stigma loop | Daedric path scoring exposes boon, price, stigma, and race response through a narrow path interface | D-12, D-13, D-14 resolved; Slices 7-10 complete | One Prince path has commitment, price, stigma, race response, and exit/residue behavior proven |
| 12 | Curse-state pilot | Werewolf first, vampire second | Scoring asks curse state/modifier without knowing detection source | D-17 resolved; Slice 11 preferred so curse tuning can compare against a real Daedric path | Curse transition changes scoring posture and restoration behavior without mutating origin race |

**Overnight enabler rule:**

Section 21.5's order remains authoritative for declaring slice completion, but
the implementation queue may pull forward narrowly scoped enabler work when it
unblocks unattended overnight execution and does not claim the parent slice
complete early. Current approved enabler pulls are:

- `Commitment + neglect/decay hardening` as active-now dawn-loop work because
  the manager-owned source contract already exists.
- `UI toast contract stabilization` as a parallel Prisma contract task because
  the overlay path already works and later authored call-sites depend on a
  stable payload shape.
- `Khajiit focused-emphasis scaffold` as a split-out part of Slice 5: build the
  state/readback/debug/verifier scaffold early, but do not claim Khajiit closeout
  until the emergent weighting and normal-play proof land.
- `Bosmer path bookkeeping scaffold` may move early only for intent/cooldown/
  state bookkeeping; do not claim Bosmer path closeout until destination-gated
  switching, `OldContract` separation, and normal-play proof are real.

Do not use this rule to front-load privilege, full Daedric price/stigma, or
curse-state implementation. Those remain sequence-sensitive and should stay
behind the current Section 21.5 gates.

**Immediate handoff packets:**

These packets are the next implementation handoff. They are deliberately
narrower than a full phase plan: they define what to prove before cloning any
more content.

### Slice 0 packet - baseline inventory

| Field | Required answer |
|---|---|
| Slice | `0 - Baseline inventory`, v3.16 handoff |
| Owning module | Verification / implementation control |
| Source contract | v3 Section 21.5, `AGENTS.md` current build status, `PDV_MOD_SETUP.md` toolchain notes |
| Interface guarantee | Future implementation starts from a named strict-verifier state and named runtime-proof state |
| Data/state shape | No new gameplay data. Records current git status, verifier counts, warning waivers, and proof gaps |
| Implementation locations | Documentation only: v3, `AGENTS.md`, and `PDV_MOD_SETUP.md` |
| Entry gate | No code or ESP change. Current workspace may contain documentation edits; code implementation should start after those edits are committed or deliberately accepted |
| Verifier gate | `node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton --strict-pattern-proving --json` returned `PASS=458, WARN=2, INFO=28`, with no `FAIL` or `TODO`, at 2026-05-19 16:44 AEST |
| In-game proof | Reuses counted prior proof: clean Preflight smoke, Structural Skeleton Debug-page smoke, Imperial Concordat proof, and counted Khajiit sleep/moon observance proof from 2026-05-18 |
| Exit/recovery | None. This slice creates no player state |
| Not in scope | Running new in-game smoke, editing scripts, changing ESP records, fixing the known warnings |
| Docs touched | v3, `AGENTS.md`, `PDV_MOD_SETUP.md` |

Known Slice 0 waivers:
- `PDV_MCM` duplicate VMAD attachment remains a known warning until manual
  CK/xEdit consolidation.
- Devotion SEQ freshness remains a normal post-CK refresh reminder, not a
  Pattern Proving blocker while no dialogue behavior is being closed.
- `PDV_Player` alias creation remains manual CK/xEdit work; safe authoring can
  compile and verify `PDV_PlayerEvents`, but cannot mint future aliases.

### Slice 1 packet - normal-play ingress closeout

| Field | Required answer |
|---|---|
| Slice | `1 - Normal-play ingress closeout`, V3 Pattern Proving |
| Owning module | Signal ingress / EventBus semantic routing |
| Source contract | v3 Sections 6, 7, 11, 21.5, and 25.4; Dunmer, Bosmer, and Hircine rules in `PDV_TargetEndStates_1.0.md`, `race-sheets/Race_Dunmer.md`, `race-sheets/Race_Bosmer.md`, and `references/PDV_RaceArchitecture_DesignReference.md` |
| Interface guarantee | Normal-play receivers call typed `PDV_EventBus` routes; receivers do not write piety, substrate metrics, Green Pact state, or Daedric path state directly |
| Data/state shape | Existing event constants `EVT_DUNMER_PORTABLE_SHRINE`, `EVT_DUNMER_HOME_BONUS`, `EVT_GREEN_PACT_VIOLATION`, and `EVT_HIRCINE_HUNT_RITE`; existing routes `RouteDunmerPortableShrinePrayer`, `RouteDunmerPlayerHomeBonus`, `RouteGreenPactViolation`, and `RouteHircineHuntRite`; existing manager/substrate/Hircine handlers; receiver `RouteId` values `30`, `31`, `32`, and `34` |
| Implementation locations | `PDV_EventSignalActivator.psc` for ACTI proof records; `PDV_EventSignalEffect.psc` for MGEF/consumable proof records; `references/authoring/PDV_Slice1SignalReceivers.manifest.json` names manual CK/xEdit record creation because `pdv_author.mjs` cannot mint records; `PDV_PlayerEvents.psc` only if a future player-alias event is truly needed |
| Entry gate | Slice 0 verifier baseline remains `FAIL=0, TODO=0`; no open Section 24 decision blocks this slice |
| Verifier gate | Existing combined strict verifier remains clean. Current closeout gate: `FAIL=0, TODO=0, PASS=522, WARN=2, INFO=28` at 2026-05-19 20:28 AEST. Strict Pattern Proving checks receiver source/pex freshness, the Slice 1 receiver manifest, and ACTI/MGEF property readback for the proof records |
| In-game proof | COMPLETE on 2026-05-19: Dunmer portable shrine plus home/private shrine reached `prayers=1; homes=1`; Bosmer OldContract Green Pact violation reached `gp=1`; Hircine hunt rite reached `sig=1; stigma=1.000000; state=Legible`. Papyrus logs showed EventBus and manager/substrate/path traces for the counted routes, and Bosmer/Hircine save-load sanity passed |
| Exit/recovery | Dunmer proof has no rupture and only daily anti-repeat throttling. Bosmer proof must remain a single violation, not forced Pact reckoning. Hircine proof may use existing renounce/debug reset only as cleanup until Slice 11 defines real Daedric exit/residue |
| Not in scope | Full Green Pact tagging, full Bosmer path switching, full Dunmer substrate tuning, Daedric boon/price/stigma completion, curse detection, broad animal-kill scoring, new player-facing quest content |
| Docs touched | v3 and `AGENTS.md` for proof status; `PDV_MOD_SETUP.md` only if tool/verify commands change; race sheets only if player-facing behavior changes |

Preferred Slice 1 trigger shapes:

| Micro-proof | Preferred trigger | Why |
|---|---|---|
| Dunmer portable shrine/home | A permanent portable shrine item or activator that calls EventBus, plus an explicit private-shrine/home-context activator for the bonus | Proves the authored route without depending on broad home-location detection yet |
| Bosmer Green Pact violation | A curated plant-food / plant-use test record or activator with a PDV-owned semantic tag | Proves PDV-owned Green Pact tagging without trying to classify all food, ingredients, firewood, flora, and potions |
| Hircine hunt rite | A curated hunt-rite token, shrine, or magic effect that gates one qualifying prey kill or route activation | Proves normal play can enter the Hircine route without making every animal kill a Daedric act |

Slice 1 is closed as of 2026-05-19. All three micro-proofs passed as non-debug
in-game receiver proofs, with final strict verification clean on `FAIL=0` and
`TODO=0`.

**Daedric implementation bridge from the initial hardening pass:**

Do not start Slice 11 from the race sheets alone. The initial hardening pass
established a three-layer handoff:

1. `race-sheets/Race_*.md` answer player-facing end-state feel.
2. `references/phase4/PDV_DaedricRacePrinceMatrix.csv` answers Prince-first
   race response and buildability planning.
3. `references/PDV_RaceArchitecture_DesignReference.md` Section 11 answers the
   implementation contract fields.

Slice 11 must choose one Prince/race pairing, then expand it into explicit
records before writing code: surface type, response state, commitment signal,
temptation pressure, boon, price, stigma, faith friction, vanilla hook priority,
buildability tag, exit route, residue, and player feedback. `Nocturnal` uses
`FactionOathSurface`, not `StandaloneDaedricQuest`; `Jyggalag` remains
`Rejected for Scope`; Molag Bal and Hircine must account for curse-state entry
and cure/restoration behavior.

For the first Daedric pilot, prefer a pairing that proves the contract without
requiring broad content authoring. Good candidates are:

| Candidate | Why it proves the pattern | Main caution |
|---|---|---|
| `Hircine + Bosmer` | Connects existing hunt-rite ingress, Bosmer path tension, and curse/Daedric ambiguity | Must not collapse Y'ffre/Green Pact into generic Hircine worship |
| `Hircine + Nord` | Uses Companions/werewolf/Sovngarde tension with strong vanilla hooks | Needs clear afterlife/curse feedback and cure residue |
| `Molag Bal + Dunmer` | Proves curse rupture, ancestor silence, and recoverable-but-scarred restoration | Vampire implementation depends on curse detection reliability |
| `Boethiah + Orc` | Proves hostile Prince response and cross-Prince pressure against Malacath | Hostility posture is locked as reduced rivalry math; still wait until stigma rows and Orc/Malacath stack ceilings are understood |

The first pilot should usually be Hircine unless a later implementation session
chooses to resolve vampire detection first.

**Decision blocker map:**

| Decision | Blocks | Does not block |
|---|---|---|
| Stigma row ratification | Broad CAT-4 Prince authoring and stigma/status copy cloning | Pre-beta race-scaling hook validation, non-Daedric race packets |
| Hircine/Molag Bal curse-access template | Curse-access Prince content beyond the proven Hircine/Nord pilot | Non-curse Daedric planning, race native/foreign response drafting |
| Prince authoring order | Broad CAT-4 content grind | Altmer/Khajiit/Argonian pre-beta race scaling |
| D-17 Werewolf detection source | Slice 12 curse-state pilot | Altmer/Breton/Khajiit static curse architecture notes |
| D-30 StorageUtil read budget | Phase 12+ performance hardening | Early Pattern Proving if traces remain cheap |
| D-31 `pdv_author.mjs` compat-patch scope | Phase 19+ compat authoring automation | Manual compat notes and core v3 implementation |

**Verifier command ladder:**

Use the lowest strict mode that proves the slice, then run the combined gate
before declaring completion:

```text
node .\tools\pdv_verify.mjs
node .\tools\pdv_verify.mjs --strict-preflight
node .\tools\pdv_verify.mjs --strict-skeleton
node .\tools\pdv_verify.mjs --strict-pattern-proving
node .\tools\pdv_verify.mjs --strict-phase7
node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
node .\tools\pdv_verify.mjs --strict-phase10
node .\tools\pdv_verify.mjs --strict-phase11
```

If a slice adds a new verifier mode later, update this ladder and
`PDV_MOD_SETUP.md` in the same session. A clean compile remains required after
any `.psc` edit; verifier-only success is not enough for script changes.

**Documentation handoff rule:**

For each completed slice, update only the documents that own changed facts:
v3 for subsystem/phase status, `PDV_TargetEndStates_1.0.md` for race acceptance
or product readiness, the relevant race sheet for player-facing experience or
race-specific build notes, `AGENTS.md` for cross-session decision/status, and
`PDV_MOD_SETUP.md` for tooling/build commands. Do not copy detailed subsystem
internals into the target tracker.

---

## 22. Risk register

| Risk | Severity | Mitigation |
|---|---|---|
| Save-baked script state breaks when adding properties to `PDV_DeityBase` | High | Test all new properties from a clean save before declaring complete; document the "new game required for upgrade" expectation in the mod page changelog |
| StorageUtil key collisions as substrate and curse-state layers add new keys | Medium | Strict prefix discipline: `PDV.Substrate.<Name>.<Key>`, `PDV.Curse.<Key>`, `PDV.Track.<Name>.<Key>`. Verifier flags duplicate prefixes |
| Story Manager event ordering breaks with high-deity-count rivalry | Medium | Stress test in Phase 13 (Daedric paths with cross-Prince rivalry); keep rivalry firing in `AwardPiety` synchronous, not deferred |
| Performance at 35 deities x N signals exceeds budget | Medium | Stance early-out (Section 19.2); benchmark in Phase 12; only iterate FormList when at least one deity has a non-FOREIGN stance for the event's race-condition |
| SkyUI header chain fragility (already observed) | Low (mitigated) | Maintain the dedicated `PDV - SkyUI CK Headers` shim mod; document in `PDV_MOD_SETUP.md` |
| Contested-lore stance assignments cause community pushback at 1.0 | Low | Document the contested-lore decisions in the public mod page; flag stance text per item; the architecture supports overriding stance via compat patches |
| Werewolf/Vampire detection edge cases (Dawnguard VL race, vanilla beast race, modded curse states) | Medium | Defer-on-unknown rather than baking false state; Section 13.1 already specifies this for transient races |
| `pdv_author.mjs` writes a patch that violates "Skyrim.esm first master" | Low (mitigated) | Tool already warns; document the manual remap path; verifier flags violations |
| Religion-overhaul replacement messaging is mistaken for public list endorsement | Medium | Keep internal target/evidence docs explicit, but public support claims wait for `list-included`/`public-supported` status |
| Custom-race players see "Imperial fallback" without context | Low | Compatibility MCM reports mapped/fallback state; `PDV_RaceMap.json` and RaceCompatibility/Race Blood Test instructions provide the override path |

---

## 23. Open architectural decisions deferred past 1.0

These are intentionally not solved in v3. The running collection point for all
post-1.0 work, including the deferred voiced-dialogue lane (Section 21.3), is
`references/authoring/PDV_V2_Backlog.md`.

- **Per-race ESP split.** Stays monolithic through 1.0; revisit only on need (Section 18.2).
- **JContainers escalation.** StorageUtil is enough through 1.0. If post-1.0 features require nested structures (e.g. a complex stigma history per Daedric path with timestamp arrays), revisit. JContainers stays out of the v1.0 dependency tree.
- **SPID adoption.** Adopted for the bounded faith-keyword/cohort-faction recognition layer as a soft dependency. Broader spell, perk, outfit, inventory, AI-package, or generic actor injection remains out of scope and requires a separate design decision.
- **Multi-character cross-save patron memory.** Each save is independent; cross-save persistence is not architecturally interesting.
- **Localization.** All player-facing strings are ASCII English. A second-pass localization effort post-1.0 is in scope; the architecture supports it via string-table externalization, which would be a minor refactor.

---

## 24. Open Decisions Tracker

Mobile-friendly worklist of every architectural decision still open in v3.
Each entry is sized for phone scrolling. Decision IDs (`D-NN`) are stable:
reference them in chat as "defer D-17" or "resolve D-30."

Numbering gaps are intentional. When a decision lands, remove it from this
open tracker and resolve it by rewriting the relevant v3 section, adding an
entry to `AGENTS.md` Decisions Log, or moving the item to Section 23 if it is
deferred past 1.0.

### Before Daedric path implementation

#### D-12  Daedric in shared FormList  (Section 11.6)

- **Decision:** Keep `PDV_FLST_AllDaedricPaths` and `PDV_FLST_AllDeities`
  separate as the operational 1.0 contract.
- **Reason:** The Hircine-only tranche already benefits from explicit
  ownership, verifier clarity, and not forcing Daedric routing into the
  Aedric/cultural roster before multi-Prince pressure is real.

#### D-13  Stigma decay model  (Section 11.6)

- **Decision:** Mixed recovery by default.
- **Meaning:** Cure or renounce starts recovery, while rites or authored
  restoration beats accelerate or complete it. Race/lane handlers can make that
  recovery easier or harder, but they do not replace the mixed default.

#### D-14  Cross-Prince hostility multipliers  (Section 11.6)

- **Decision:** Canonical Prince-vs-Prince hostility uses reduced rivalry math.
- **Meaning:** Do not run full Aedric-strength cancellation, but do not reduce
  the relationship to stigma-only either.

### Before neglect/decay implementation

#### D-17  Werewolf detection source  (Section 13.5)

- **Decision:** Combined detection.
- **Meaning:** `PDV_CurseState` should compose active beast-race checks with
  afflicted-state / faction / quest-style evidence so transformed and
  afflicted-not-currently-transformed states both resolve through one service.

### Before authoring/perf tooling expansion

#### D-30  StorageUtil read budget  (Section 19.3)

- **Question:** Add per-deity StorageUtil read count to verifier output?
- **Options:**
  - (a) Yes, as informational metric.
  - (b) Yes, with a soft cap (warn above N reads per `ScoreAction()` call).
  - (c) No.
- **Recommendation:** (a). Visibility is cheap; capping prematurely is constraining.

#### D-31  Phase 21 compat-patch packaging  (Section 20.2)

- **Question:** Should Phase 21 ship generic compat patches, list-specific
  patches, or generated packages?
- **Resolution:** Use one list-specific patch per target list package, with
  ESL flagging unless unsafe. Shared templates and scanner rules may be reused
  internally, but the maintainer-facing package should stay list-specific and
  simple. `pdv_author.mjs` or the offline patcher may learn these templates
  after repeated patterns are proven; they are not new hard dependencies.

---

## 25. Roadmap to beta and launch

This section is the high-level release roadmap. It is intentionally less
detailed than the subsystem sections above: it names the gates and readiness
bars that future phase plans must satisfy. Architecture truth stays in this
document. `PDV_TargetEndStates_1.0.md` is the product-facing tracker for 1.0
race acceptance and roadmap traceability; it must defer to this document for
architecture contracts.

### 25.1 Roadmap posture

- **Structural completeness comes before content completeness.** v3 may scaffold the full 1.0 shape early, but incomplete scaffolds stay dev-only until content-ready.
- **Full roster completeness is the 1.0 content target.** The old selective target is retired; launch requires content-ready handling for every locked god and every Skyrim-present Prince named in the Phase 20 roster authority.
- **V3 Preflight comes before Phase 7.** Signal expansion should not begin until the hardening work below is compile-clean, verifier-clean, and smoke-tested.
- **Beta has two gates.** Technical Beta proves system stability for trusted testers; Content-Feel Beta proves the religious roleplay feel.
- **Launch target is content-rich 1.0.** Public launch waits for broad authored religious texture, not merely a stable narrow core.
- **Feel matters as much as function.** New systems that technically work but read as spammy, farmable, or chore-like are not ready for beta.

### 25.2 V3 Preflight

Purpose: harden the architecture before scaling.

Must complete:

- `PDV_WorshipTargetBase` shared concept for Aedric/cultural deities and Daedric paths, with optional no-op capability hooks rather than mandatory uniform behavior.
- Manager split into internal services with a staged clean API behind an outward facade for existing callers.
- `PDV_GLO_PatronState` for unset, broad worship, and active patron state, with `PDV_GLO_PatronDeity` kept as the active-target cache only.
- `PDV_EventBus` plus a central `PDV_EventTypes` quest/script owner for event IDs. The existing direct-player kill route is the first EventBus canary and must preserve v2 scoring behavior.
- Dawn pass order as named pipeline slots: consolidate scratch, apply decay, recompute tiers, apply spell/neglect layers, process commitment offers, notify. Preflight may leave future subsystem slots no-op.
- Gain pipeline that composes stance, reputation, curse, Daedric stigma, and future modifiers in one place. Preflight moves existing stance math into this pipeline and leaves future modifiers no-op.
- Minimal schema/version hooks that record the current framework schema version and trace mismatches. Do not add a full save-migration registry in Preflight.
- Verifier hard-fail rules for core invariants.

Current implementation note (2026-05-16): Preflight gate is closed.
`PDV_EventTypes`, `PDV_EventBus`, and `PDV_GLO_PatronState` are framework-owned
records in `Devotion.esp`; manager/router/eventbus wiring is
live; strict preflight verifier runs clean (`FAIL=0`); and the clean-start smoke
pass validated MCM load, origin seed, patron-state transitions, dawn
consolidation, direct-hostile vs non-hostile canary behavior, Talos/Auri-El
rivalry through dawn, and save/load sanity.

Exit gate:

- Active scripts compile cleanly.
- Verifier reports no hard failures or unexpected TODOs.
- MCM, patron switch, origin seed, dawn pass, and Talos/Auri-El rivalry smoke tests pass on a clean start.

### 25.3 Structural Skeleton

Purpose: make the final 1.0 architecture visible to tools without making
unfinished content player-visible.

Must complete:

- Full 1.0 worship-target scaffold, dev-only by default.
- Strong substrate scaffolds for Khajiit, Dunmer, and Argonian.
- Reputation-track and state-track scaffolds for all locked first-release race tracks: ConcordatStanding, ThalmorAlignment, WitchcraftExposure, KnightlyVowIntegrity, DruidicStanding, BosmerPath, OrcLifeMode, NordPantheonBaseline, BretonTradition, RedguardSect, DunmerAncestorPosture, and AltmerCrisis. Do not scaffold redundant Broad/Primary state tracks such as `PDV_State_ImperialWorship`; shared patron state owns commitment depth.
- Sacred-place scaffolds for Argonian bed-of-choice, Khajiit road homes, and Orc City/Legion community location, with Orc marked as a contextual mode modifier rather than a strong substrate.
- Matrix-driven CK authoring support where feasible, especially stance rows, FormList membership, rivalry wiring, and verifier expectations.
- Dev-only FormList indexes for authoring/dev inspection across tracks, substrates, sacred places, and Daedric pilots. Canonical per-record visibility properties are deferred; FormLists are the live operational visibility surface in this wave.
- Verifier states for structural-ready records, including hard-fails for required-script/property/FormList contradictions and for accidental Hircine membership in `PDV_FLST_AllDeities`.

Exit gate:

- Scaffolded targets are inert and hidden from player UI, commitment offers, shrine/dialogue surfaces, and normal gameplay.
- Dev UI and verifier can inspect scaffolded targets, including a debug-only structural map/API smoke path in `PDV_MCM`.
- No scaffold target can affect gameplay accidentally.

Current implementation note (2026-05-17): Structural Skeleton is now closed.
The framework ESP contains the track, substrate, sacred-place, Hircine, and
curse scaffolds plus their dev FormList indexes and `PDV_MCM` scaffold
properties. `node .\tools\pdv_verify.mjs --strict-skeleton` and
`node .\tools\pdv_verify.mjs --strict-preflight --strict-skeleton` both return
`FAIL=0, WARN=0, TODO=0, PASS=401, INFO=30`. The remaining array work is
deliberately informational/manual-deferred and does not block the gate.

### 25.4 Pattern Proving

Purpose: build one excellent pattern per subsystem before cloning it across
the roster.

Must complete:

- One expanded EventBus signal family.
- Imperial Concordat as the first reputation track, including wide Uncommitted band and edge walk-back gate.
- Bosmer Path as the first state track, including Old Contract Green Pact tag handling.
- Dunmer Ancestor as the first strong substrate, including portable shrine prayer and player-owned-home bonus.
- Khajiit emergent patron/moon-cycle as the first special-case race exception, including outdoor road-home practice, Observe the Moons, and phase-presiding-god presentation.
- One contextual favor family.
- One Daedric price/stigma path.
- One commitment offer flow.
- One neglect/decay path.

Exit gate:

- Each pattern is playable, verifier-covered, documented, and reusable.
- Each pattern has one clean in-game proof path that future clones can repeat.

Prisma UI smoke companion:

- Start from a closed Skyrim state after bridge DLL, Prisma UI, or toast-Papyrus
  changes; launch through the normal MO2/SKSE path.
- Open the Prisma panel through the MCM/debug opener and confirm the status
  surface is readable.
- Trigger one real active-patron positive devotional event and confirm the
  transient deity-symbol toast appears without focusing the panel.
- Trigger the debug dawn path and confirm the transient dawn/system-symbol toast
  appears.
- Check `DevotionPrismaBridge.log` for bridge, DOM-ready, interop, or JavaScript
  errors before calling the smoke pass clean.
- Keep the panel opener dev-only while this remains a prototype; normal play
  should see only rare, meaningful toasts.

### 25.5 Technical Beta

Audience: small trusted testers.

Ready when:

- Install/update path is documented.
- Core systems are stable on clean starts.
- MCM/status surfaces are readable.
- Normal play does not require debug surfaces, daily service actions, or tolerance for routine notification spam.
- No known hard verifier failures remain.
- At least several worship paths are content-ready.
- Testers can report bugs against normal play, not console-only flows.

Tester expectation:

- Systems are real.
- Content breadth is incomplete.
- Balance and roleplay texture are still under active tuning.

### 25.6 Content-Feel Beta

Audience: trusted roleplay testers.

Ready when:

- Every race has at least one credible, race-aware foreground path.
- Strong substrates feel distinct for Khajiit, Dunmer, and Argonian.
- Named race obligations are testable in normal play: Imperial Concordat neutrality/edge walk-back, Breton three-track tension, Bosmer Green Pact failure handling, Nord broad-worship combo feel, Khajiit no-offer emergent emphasis, Orc community mode support, Redguard HoonDing big-win accessibility, Altmer light Lorkhan reactions/crisis states, Dunmer portable shrine practice, and Argonian Hist/community maintenance.
- Commitment, neglect, decay, curse-state, and UI are live.
- Enough shrine, notification, Survey/status, and MessageBox texture exists to judge religious feel. NPC dialogue and spoken recognition are V2, so feel is judged from non-voiced surfaces in V1.
- Dev-only scaffolds remain hidden from player-facing surfaces.
- The play loop feels quiet, recoverable, and lore-reactive rather than like a second hunger meter.

Tester expectation:

- Testers should evaluate whether devotion feels meaningful, legible, and lore-grounded, not just whether the systems function.

### 25.7 Content-rich 1.0 launch

Ready when:

- All 10 races have satisfying authored devotional play.
- All locked race-architecture gods and all sixteen Skyrim-present Daedric Prince surfaces are content-ready, not merely scaffolded.
- Every race has authored handling across the full god/Prince roster; unsafe worship is valid, silent or generic fallback handling is not.
- Player-facing text is polished and ASCII-safe.
- Light authored moments are present: commitment offers, shrine/ritual interactions, and notifications. (NPC dialogue recognition is deferred to V2 per Section 21.3.)
- No original multi-stage questlines are required for 1.0.
- Compatibility posture is documented.
- External beta feedback has been addressed or explicitly deferred.
- The release build reads as vanilla-plus in ordinary play: low spam, no obvious farm loops, and no mandatory religious chore maintenance.

### 25.8 1.0 product target tracker

`PDV_TargetEndStates_1.0.md` is the living product/end-state tracker for
launch feel, per-race acceptance state, and roadmap traceability. It should not
restate subsystem internals from v3. When launch expectations change, update
the target tracker for product acceptance and this roadmap only when the gate
or architecture contract changes.

### 25.9 Content authoring track (parallel workstream)

Player-facing religious prose is drafted on a content authoring track that
runs **in parallel with, and separate from, the coding roadmap** in
25.2-25.7. Drafting and ratifying prose does not depend on the code
subsystems existing; only the final promotion of ratified strings into ESP
records does. This subsection is a standing reminder that content breadth must
be built deliberately on its own track, not improvised at the 1.0 gate.

Home artifacts: `references/authoring/PDV_DeityCoverageMatrix.json` (Phase 20
roster authority), `references/authoring/PDV_RaceGameplayBalanceAudit.md` plus
`PDV_RaceImplementationCostingBacklog.md` and
`PDV_Phase20*ImplementationCosting.manifest.json` (race parity and build
costing),
`race-sheets/PDV_RaceContent_Manifest.md` (Aedric and native devotion),
`race-sheets/PDV_DaedricContent_Manifest.md` (Daedric paths), and
`tools/pdv_content_verify.mjs` plus `tools/pdv_verify.mjs` (read-only content
and implementation-costing verifiers). The coverage matrix owns roster
completeness; the content manifests are the single source of truth for draft
prose; the implementation-costing manifests own build readiness; this document
stays the architecture truth they author against.

Adjacent player-experience artifact: `references/PDV_ExperienceMode_DesignReference.md`
and `references/authoring/PDV_ExperienceMode.manifest.json` lock the future
two-mode difficulty surface (`Pilgrim's Path` default, `Wayfarer's Path` easy).
That work is merged as a design and CK/wiring contract only; it is not a live
runtime subsystem until `PDV_ModePreset`, `PDV_GLO_Mode`, MCM wiring, manager
scalars, ActionRouter cheap-signal behavior, verifier readback, and runtime
smoke are implemented.

Pre-beta and content-scale risk artifacts:
`references/authoring/PDV_PreBetaRaceAcceptanceRubric.md` defines the
measurable race-scaling verdict; `references/authoring/PDV_RecognitionDialogueScalePacket.md`
keeps planned V2 recognition/dialogue scaling CK-safe and readback-proven; and
`references/authoring/PDV_CAT6PromotionPilot.md` defines the first CAT-6
promotion pilot before broad string promotion.

Phases:

- **CAT-1 - Aedric and native draft prose. COMPLETE.** All 10 races drafted in
  the race content manifest: tone profiles, blessings, tier-ups, champion
  moments, neglect, commitment offers, survey readouts, contextual favors,
  curse-state transitions, and planned V2 dialogue-topic recognition-intent
  stubs. Note: the 39 `PDV_Dlog_*_Recognition` stubs are drafted but are V2
  scope per the Section 21.3 voiced-content non-goal; they are not promoted in
  V1.
- **CAT-2 - Content tooling and consistency. COMPLETE.** The content verifier,
  the token tables, and the consistency audit (race manifest Sections 24-25).
- **CAT-3 - Daedric pilot. COMPLETE.** Boethiah authored end to end in the
  Daedric manifest; the boon/price/stigma row template is proven.
- **CAT-4 - Daedric expansion. COMPLETE FOR STATIC CONTENT.** All sixteen
  Skyrim-present Prince surfaces are authored in the Daedric content manifest
  to the Phase 20 content-ready target (21.1), with D-12 separate roster, D-13
  mixed recovery, D-14 reduced cross-Prince hostility, D-15 stigma handling,
  D-16 curse-access templates, D-17 authoring order, and D-18 per-Prince bar
  locked. This is static content/readback readiness only; runtime/display proof
  and organic sender proof remain separate beta-display gates.
- **CAT-5 - Gated-slot closure. PARTIAL / ALTMER COMPLETE.** Altmer
  crisis-of-faith, contextual-favor, and Exiled vampire slots are now drafted
  after the 2026-05-30 implementation-spec closeout. Breton Vigilant pressure
  remains optional/slip-able post-1.0 unless promoted by a later content pass.
- **CAT-6 - Ratification and promotion handoff. PARTIAL.** The all-Prince
  Daedric tranche has been promoted into live ESP records through
  `PDV_DaedricPrinceRecordContracts.json` and `tools/pdv-daedric-author`, with
  readback for QUST/SPEL/MGEF/MESG/GLOB/path wiring, FormList membership,
  manager property wiring, and QASmoke proof senders. Handbook/player-facing
  downstream sync and counted runtime/display proof remain open.
  The `PDV_Dlog_*_Recognition` dialogue strings are **excluded from V1
  promotion** (V2, voice-dependent); promote only non-voiced surfaces
  (MessageBox, notification, Survey, blessing/price descriptions) for 1.0.

Gate coupling:

- CAT-1 through CAT-5 (drafting and ratifying) may run ahead of the code
  roadmap and are not blocked by Pattern Proving or Technical Beta.
- CAT-6 (promotion) follows the code: it interleaves with Phase 19 and the
  run-up to Content-Feel Beta.
- The track must be substantially complete to clear the Content-Feel Beta gate
  (25.6) and fully ratified and promoted to clear the Content-rich 1.0 gate
  (25.7, "player-facing text is polished and ASCII-safe").

---

## 26. Revisions

### v3.104 - 2026-08-15 AEST - Quest Reaction bounded ingress repair

Fresh organic MQ102/MQ103 proof identified a `7469.970703` ms synchronous
catalog-materialization path inside `OnQuestStageChange` and a resulting
`BROAD_SCOPE_ABORT`. PlayerEvents now flushes the ordinary broad scope before QR
submission, while Runtime persists a lightweight header and materializes catalog
cells through its existing scheduler at the shared two-work-item budget. Static
audits and targeted compilation pass. Organic admission fell to 45 ms, and a
clean four-job run resumed from `build=8/45` before draining all jobs in FIFO
order without a safety marker. Runtime-route/build-resume proof passes; counted
manual toast and Book confirmation remains open.

### v3.96 - 2026-07-14 AEST - Pantheon/substrate presentation ratification

Ratified the player-facing boundary for the Pantheon Parity and Substrate
Pacing build. Broad-pool public bands are `Distant`, `Observant`, and
`Faithful`; internal `Seeker` identifiers remain compatibility-only. A boon
spell owns the family/tier heading in Active Effects, while each child magic
effect names only its concise mechanical result (or a distinct scripted
effect). The focused commitment state below 50 piety remains committed but is
labelled `Wavering`; the focused Book-of-Days identity is the deity name with
no redundant `Focus` suffix. `pdv_active_effect_naming_audit.mjs` reads every
`PDV_Bless_*` spell and child MGEF through houseCARL and is called by the
normal verifier. This is static/readback coverage; the remaining PS-A6 and
other co-test cards retain their separate runtime/manual proof obligations.

### v3.93 - 2026-06-24 AEST - Redguard spine pulse and thin-Prince equip faucets

Closed two narrow authoring slices at machine/readback level. Redguard
ancestral-spine acts now feed Tu'whacca piety through `SIGNAL_ANCESTOR_SPINE`
instead of staying telemetry-only. The design-first thin-Prince faucet pass
adds six artifact-equip FormLists and JSON keys for Molag Bal, Hircine,
Meridia, Sheogorath, Mehrunes Dagon, and Nocturnal, authored by
`tools/pdv-prince-faucet-author` and routed through `PDV_PlayerEvents`.
Verified by targeted Papyrus compile, quest-matrix check at 20 Part D faucet
acts, helper `--check`, default verifier, signal floor ledger regeneration, and
houseCARL FormList winner/member readback. Runtime equip smoke and broader
quest-reaction proof remain pending.

### v3.92 - 2026-06-20 AEST - Nord startup gate and Requiem-tail record closeout

Closed the Nord startup-gate and Requiem-tail build slice at compile/readback
level. Nord now routes through explicit Old Ways / Nine Divines startup messages,
sets `PDV_State_NordPantheonBaseline`, marks `PDV.Nord.SetupComplete`, applies
broad worship, and syncs rewards immediately. The Requiem-tail helper writes
directly to `Devotion.esp` with backups and no persistent patch plugin: Shor and
HoonDing Champion low-health saves, HoonDing V1 named-boss FormList, Redguard
Necromancer/Warlock faction properties, Ash'abah clearable-undead-site FormList,
and Namira passive-zero/Health+Stamina feed copy. Verified by Papyrus compile,
default verifier, reward readback, helper `--check --all`, and houseCARL readback.
Runtime/manual proof remains pending in the Nord, Redguard/Requiem, and
Daedric/Namira packets.

### v3.90 - 2026-06-07 AEST - Daedric proof-gate handoff ready

Added the fail-closed Daedric runtime evidence lane after all-Prince CAT-6
record/readback and sender placement. `tools/pdv_daedric_test_readiness.mjs
--deep` is green at `PASS=71`; `PDV_DaedricInGameSmokePacket.md` is generated
from the all-Prince contract; `PDV_DaedricRuntimeEvidenceLedger.json` exists
with all sixteen Princes pending; and `tools/pdv_daedric_evidence_intake.mjs`
can auto-record MCM, QASmoke, and exact organic route slots only from matching
runtime-check log passes. `tools/pdv_daedric_beta_gate.mjs` deliberately fails
closed at `PENDING=16` until controlled/display evidence, exact organic sender
proof, generic-source silence, save/load/stack/manual feel, and Molag/Hircine
curse no-double-fire evidence are recorded. This closes repo-side test
readiness, not beta-display readiness.

### v3.85 - 2026-06-07 AEST - Phase 2 static all-race reward/receiver gate complete

Closed the automated/static Phase 2 all-race shipment gate without claiming
external beta runtime proof. All ten races now have static manager
reward/neglect sync coverage, reward/deity records authored or reconciled,
bounded roster readback, SEQ refresh, Green Pact static list/KID/readback
coverage, fallback-floor T3 capstone record coverage, and the new read-only
`tools/pdv_phase2_reward_readback_audit.mjs` gate. Verification closeout:
`node .\tools\pdv_compile.mjs --all` compiled every PDV script with `0 error(s),
0 warning(s)`; strict Phase 20 race costing reported `PASS=2841, WARN=2,
INFO=30`; `tools/pdv_phase20_base_wiring_audit.mjs` reported
`sourceProperties=39`, `sourceFillRecords=30`, `routeEntries=24`,
`rewards=10`; Prisma UI audit passed 11 checks; content verify stayed clean at
`PASS=1081, WARN=0, FAIL=0, INFO=4`; and reward readback audit reported
`PASS=1268`. Remaining beta gate is runtime/manual: all ten
`PDV_BetaTestPacket_{Race}.md` walks, Active Effects and stack snapshots,
save/load sanity, rejected-hook silence, Survey/status clarity, and explicit
ledger verdicts.

### v3.84 - 2026-06-07 AEST - Phase 2 all-race propagation: design + B1 + Argonian B2 pilot

Picked up directly from the runtime-proven Khajiit pilot and propagated its
template across the rest of the roster. Phase A locked the binding rulings
(`references/authoring/PDV_Phase2_DeityRoster_and_ArchitectureRulings.md`,
R1-R8: broad worship is a STATE not a deity; broad-T1 editorIds match the
manager's existing per-race props; focused 3-tier sets use
`PDV_Bless_<Race>_<Patron|Path|LifeMode|Sect>_T1/T2/T3`; deities are SHARED
records keyed by per-race stance, created once by their owner; only focusable
patrons get records; Daedric forks via 20C; three gate shapes; balance
invariants), the locked design rails (native-track-as-parity piety model;
two-tier magnitude convention universal-combat <=~12% / narrow-resist-regen-
utility up to ~15; T3 capstone signatures ride on top of the stat half with
<=1 cheat-death per race, all once/day, fallback-as-floor binding; Nord Old
Ways Shor/Tsun/Stuhn promoted to focusable; Argonian primal-unarmed on
Sithis/Void T2 parallel to Khajiit clawed builds), and the new race-agnostic
records author `tools/pdv-phase20-race-author/` (idempotent dry-run reproduces
the Khajiit ESP). 9 per-race reward specs + 4 missing P2 audit-only costing
manifests (Imperial/Breton/Dunmer/Nord) authored; convergence review clean (0
deity-ownership collisions, 0 orphans, 22 new deities owned with FLST
projected 10 -> 32). B1: 22 new `PDV_Deity_*.psc` authored and compiling clean
(`0 error(s), 0 warning(s)` each), collision-free SIGNAL_* blocks 1000-3199.
B2: Argonian PILOT LANDED and compiles 0/0 - declared `PDV_Hist`/`PDV_Sithis`
+ 8 reward Spell properties + neglect property; double-routed the 4 Argonian
handlers; added `SyncArgonianRewards`/`SyncArgonianNeglectSpell`; no-offer
integration via `GetFirstTierRaceRewardSpellForOrigin` returning `None` for
Argonian. Important B2 gap surfaced for every offer race: existing
`HandleImperial*`/`HandleAltmer*`/`HandleOrc*`/`HandleRedguard*`/`HandleNord*`/
`HandleDunmer*` handlers are TELEMETRY STUBS that do NOT call
`AwardCuratedSignal`; Bosmer/Yffre + Khajiit substrate + Argonian pilot are
the working templates. Imperial additionally needs a civic-act-type
discriminator on `RouteImperialCivicService` before per-Divine scoring works.
Doc/spec/script + tooling change; B2 remainder + capstone signature MGEFs
(fallback-as-floor binding) + Bosmer Green Pact tag layer (modelled on
Biggie's Traits + Requiem FBR) + B3 real-hook landing + Phase C user-gated
ESP authoring + Phase D pace tuning + Phase E static verify (new
`tools/pdv_phase2_reward_readback_audit.mjs` to author) + user-only Phase F
runtime walk per race remain ahead. Authoritative session detail:
`references/authoring/PDV_SessionHandoff_Phase2_AllRaces.md`.

### v3.83 - 2026-06-07 AEST - Per-race piety architecture fix; Khajiit pilot complete/runtime-proven

Closed the structural piety-rate gap (`references/authoring/PDV_RacePietyRateAudit.md`): unscripted deities scored no piety and most races' per-race handlers fed state/substrate rather than the piety->tier->reward spine, so 8/10 races' rewards (gated on patron piety Tier>=Seeker) were unreachable. Locked the generalized per-race build contract (`references/authoring/PDV_RaceContractTemplate.md`: foreground patron, offer vs no-offer gate type, piety-feeding acts + anti-farm, creed-violation loss, broad + per-patron 3-tier rewards, substrate/state boons, neglect) and proved it end-to-end on Khajiit. New emphasis deity scripts (Azura/Khenarthi/Rajhin/Alkosh + Baan Dar extension); manager double-route (Khajiit acts now pulse the emphasis deity's piety), per-emphasis 3-tier reward sync, Khajiit neglect, anti-creed routes 110-114, tier-up notice for active patron + focused emphasis; `PDV_DeityBase.EligibleStateTrackOriginRace` adds origin-scoped path eligibility so a shared deity (Baan Dar: Bosmer + Khajiit) does not penalize the other race. ESP authored via `tools/pdv-phase20-khajiit-author --author-rewards` (4 deity quests into `PDV_FLST_AllDeities`=10, 18 `PDV_Bless_Khajiit_*` SPEL/MGEFs, substrate boon wiring, 20 manager props) and `--fix-baandar` (Baan Dar SGE + Stance_Khajiit=NATIVE + EligibleStateTrackOriginRace=Bosmer); SEQ refreshed to 15 via `pdv_refresh_seq`. In-game smoke (Khajiit, QASmoke) confirmed double-route piety, emphasis emergence, Seeker reward grant, anti-creed loss, and Baan Dar parity (0.4/pulse). MCM readouts fixed (scratch column, non-zero piety map, signal-ID cap 299->999). Doc/record/script + runtime change; `tools/pdv_verify.mjs` expected-data still needs the 4 new deities / 18 spells added before strict gates pass. Authoritative detail: `references/authoring/PDV_SessionHandoff_KhajiitPilot.md`. Next: generalize the records author and propagate the template to the other 9 races (Phase 2).

### v3.81 - 2026-06-02 AEST - P2 audit-only contract gate for Breton/Dunmer/Imperial/Nord

Added structured `p2AuditContract` packets to
`PDV_Phase20_NoInGameProof_Gates.json` for Breton, Dunmer, Imperial, and Nord.
The strict Phase 20 race-costing verifier now checks audit-only no-new-volume
mode, positive probes, rejected probes, required stack evidence, pass blockers,
and manual evidence targets for those four P2 lanes. This is an audit-readiness
gate only: it does not add reward volume, final placement contracts, or manual
runtime evidence, and all four races remain `Fail - runtime/manual proof
deferred` until in-game Survey/status, rejected-hook, and stack evidence is
recorded.

### v3.81 - 2026-06-04 AEST - Daedric Batch 0 static D-18 proof ledger

Added `references/authoring/PDV_DaedricBatch0_D18ProofLedger.md` as the static
D-18 proof ledger for the first Daedric template-variation batch: Azura /
Azurah, Vaermina, Meridia, and Molag Bal. Added firing-density sanity
paragraphs to those four manifest sections and clarified Molag Bal's stigma
rows as curse-state display text, not independent per-act stigma. This closes
the repo/content-contract proof for Batch 0 while keeping CAT-6
promotion/readback and runtime/display proof blocked.

### v3.80 - 2026-06-04 AEST - All-race plus Daedric beta-feel readiness ledger

Added `references/authoring/PDV_AllRaceDaedricBetaReadinessLedger.md` as the
single blocker ledger for beta-feel readiness across all ten races and all
sixteen Skyrim-present Daedric Princes. Updated Phase 20 beta-readiness routing
to treat Daedric 20C proof as part of beta feel readiness: D-15..D-18 are
locked and Batch 0 static D-18 proof is complete, but per-Prince CAT-6
promotion/readback, runtime or display proof, and race-stack legibility remain
blockers. Refreshed current
evidence to `pdv_content_verify` `FAIL=0, WARN=0, PASS=1079, INFO=4`, strict
Phase 20 Altmer/race-costing `PASS=2699, WARN=1, INFO=29`, and P2 book runtime
checker `FAIL` overall with Breton Hidden Art as the only current pass.

### v3.79 - 2026-06-01 AEST - Transition surfacing contract (Section 16.7); curse-access framing clarification (Section 13.7)

Added **Section 16.7 Transition surfacing contract (V1)**: the "surface the transitions"
workstream from the end-to-end immersion audit
(`references/authoring/PDV_ImmersionAudit_MissedOpportunities.md`). Defines five
one-shot transition classes the mod must surface -- `tier`, `emergence`, `curse`
(onset **and** the currently-missing cure beat), `reorientation`, `neglect` -- a
shared `SurfaceTransition()` helper with `PDV.Surfaced.*` one-shot guards, the
neglect once-per-tier-drop cadence rule (resolves the Section 14 open), and the Imperial
Concordat Talos gate as a worked "make state legible, don't interrupt" example.
Discipline over existing Section 16.2 levels and Section 16.6 toasts; no new UI, no scoring
change, stays inside the Section 16.3 non-voiced boundary.

Added **Section 13.7**: clarifies the curse-access "asymmetry" the audit flagged is
intended per-race weight (Section 13.2), not a divergence from the locked D-16 template;
closes the flag and routes missing per-race curse responses (e.g. Orc Molag Bal)
to the D-18 content checklist. Two reconciliation memos of record:
`PDV_DecisionMemo_CurseAccessReconciliation.md` and
`PDV_DecisionMemo_ImperialComplianceLane.md` (the latter records that Concordat
compliance is a standing modifier, not an alt-victory or dead loss-path --
Akatosh/Zenithar remain the compliant Imperial's Champion payoff). Doc/design only;
no source, record, or verifier behavior change.

### v3.80 - 2026-06-02 AEST - Balancing retune: piety pace, thresholds, decay grace, vampire floor bypass

Applied the balancing handoff retune to live source and framework records:
daily positive gains now scale by `1.32` before the `4.3` cap, standard deity
thresholds are `25/50/85`, tier-down hysteresis holds visible tiers within
five piety of the prior threshold, passive decay grace is `2.0` days, and
vampire curse state bypasses passive tier floors for records marked `IsAedric`.
The live framework VMAD properties were retuned for Kyne, Talos, Auri-El,
Y'ffre, Z'en, and Baan Dar; strict full bridge verification passed with
`PASS=2369, INFO=29` and no fail/warn/todo.

### v3.78 - 2026-06-01 AEST - Daedric D-15..D-18 locked; V1 no-new-NPC-dialogue scope lock

Reconciled the amazing-goodall branch into main and carried forward the V1/V2
voice boundary. These locks are design/documentation only; no source or record
change is implied by this merge.

Locked: **D-15** (four-band `WitchcraftExposure` stigma model - per-Prince
storage, derived `PDV_GLO_DaedricExposure = max(active path stigma)`, Tolerated/
Standard/High-rupture weight classes, 1/day decay, `WasChampion` residue),
**D-16** (curse-access template for Hircine/Molag Bal: curse-onset replaces the
pact, curse-state-driven stigma, cure-path exit, no-double-fire with race
`CurseState` rows), **D-17** (template-variation proof batch - Azura, Vaermina,
Meridia, Molag Bal - before volume), and **D-18** (per-Prince content-ready
definition for the 20C gate). These resolve the exact Daedric blockers main's
earlier entries left open: stigma ratification, curse-access template, and
authoring order. Rationale of record:
`references/authoring/PDV_Daedric_DecisionPacket_CAT4.md`; manifest Section 5
is locked; coverage matrix 20C carries the D-18 definition.

V1 now uses non-voiced recognition surfaces only: Survey/status, MCM Player
text, MessageBoxes, notifications, spell/effect descriptions, books/notes, safe
service or shrine gates, and Prisma toasts where supported. Existing Arngeir
and Phase 18 Nord dialogue remain technical proof/prototype evidence. The Phase
11 dialogue/recognition lane, the Phase 18 Nord quartet, and the 39
`PDV_Dlog_*_Recognition` stubs are V2
(`references/authoring/PDV_V2_Backlog.md`). Main's
`PDV_RecognitionDialogueScalePacket.md` and the dialogue half of
`PDV_CAT6PromotionPilot.md` are flagged V2-scoped, not deleted.

Reconcile folds: the branch broad-reward spec was re-homed into main's
`references/authoring/PDV_RaceEffectReviewLedger.md` per-race rows, and the
branch pre-beta rubric was dropped in favor of main's
`PDV_PreBetaRaceAcceptanceRubric.md`.

### v3.75 - 2026-05-31 AEST - Phase 20 no-in-game-proof workplan

Added `references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` as the
owner for Phase 20 work that can proceed before additional Skyrim runtime
proof, plus `PDV_Phase20_NoInGameProof_Gates.json` as the structured verifier
target and `PDV_Phase20_ManualEvidenceLedger.json` as the pending manual-proof
intake. It defines the no-in-game boundary, the no-game definition of done,
sequenced waves for ledger hardening, hook contracts, verifier expansion,
placement contracts, stack audits, Survey/status prep, CAT-6 prep, recognition
prep, Daedric proof-path closeout, and later evidence capture, plus explicit stop
conditions so paper work does not become a false `Pass`.

### v3.74 - 2026-05-31 AEST - Workshop lore cross-review guardrails

Recorded the cross-review of all workshop choices against the local lore
library and UESP. The ratified choices stand, but the public-facing wording is
tightened: Altmer `MarriageBeat` means Marriage / Mortal Continuity, not
anti-Mara marriage rejection; Talos/Thalmor remains a later optional crisis row;
Khajiit, Argonian, and Bosmer Survey/status copy now carries explicit lore
guardrails; Runil is scoped to planned V2 Altmer mortality/scar/recovery
recognition; and Daedric promotion remains blocked on stigma, Hircine/Molag Bal
curse-access, and Prince-order contracts.

### v3.72 - 2026-05-31 AEST - Content decision workshop ratification

Ratified the immediate pre-beta content handoff defaults. Altmer's current
crisis list uses `MarriageBeat` as the third beat and leaves Talos/Thalmor
contradiction out unless a later explicit additional-row decision restores it.
The two wired Altmer proof rewards now point at the ratified Section 13.13
rows. The scaling spine now states the less-diagnostic Survey/status direction
for Altmer, Khajiit, Argonian, and Bosmer plus first final-world placement
concepts for Altmer, Khajiit, and Argonian. Recognition fallback starts with
Survey/status for V1; Runil remains a planned V2 Altmer candidate if CK
conditions are clean when V2 dialogue scope opens. CAT-6 starts with
`PDV_Bless_Khajiit_Lunar_T1`, with
`PDV_Bless_Bosmer_Exchange_T1` as the only fallback. Daedric final promotion
remains blocked on stigma, Hircine/Molag Bal curse-access, and Prince-order
decisions while race hook validation continues.

### v3.71 - 2026-05-31 AEST - Pre-beta architecture risk packets

Added three architecture packets before the next content/runtime grind:
`PDV_PreBetaRaceAcceptanceRubric.md` defines measurable `Pass`,
`Conditional`, and `Fail` criteria for race-scaling completion;
`PDV_RecognitionDialogueScalePacket.md` defines a planned V2 CK-safe
recognition/dialogue pattern and no longer gates V1; and
`PDV_CAT6PromotionPilot.md` defines a first
low-risk non-dialogue draft-to-ESP-to-handbook promotion proof before broad
CAT-6 string promotion. Also reconciled the old Section 21.5 Daedric blocker
map so D-12/D-13/D-14 are no longer treated as open blockers.

### v3.70 - 2026-05-31 AEST - Pre-beta race scaling spine

Added `references/authoring/PDV_PreBetaRaceScalingSpine.md` as the internal
handoff between QASmoke route proof and external beta readiness. The spine locks
the next scaling order as Altmer active spine, Khajiit first contrast,
Argonian second contrast, Orc / Redguard / Bosmer P1 packet prep, and Breton /
Dunmer / Imperial / Nord P2 audit-only stack/ceiling packets. Each race packet
now uses one shared gate: normal-play hook, rejected generic hooks,
Survey/status readout, final placement, reward ceiling, reward floor, stack
snapshot, runtime proof command, manual feel note, and content dependency.
Also corrected stale CAT-4 wording: D-12/D-13/D-14 are now locked defaults, so
the remaining Daedric expansion blockers are stigma row ratification,
curse-access template resolution for Hircine/Molag Bal, and authoring order.
The merged Experience Mode design/reference pair is recorded as a design and
CK/wiring contract, not live runtime.

### v3.69 - 2026-05-31 AEST - Phase 20 runtime proof harness

Added the consolidated Phase 20 QASmoke runtime proof lane after placement
readback. `tools/pdv_phase20_runtime_check.mjs` reads the Skyrim SE
`Papyrus.0.log` and checks the Altmer, Argonian, Orc, Redguard, Khajiit, and
Bosmer route markers emitted by the 30 QASmoke proof references. The new
`references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` keeps route
proof separate from Survey/MCM status evidence, immersion feel, wrong-origin
negative checks, same-anchor or major-favor anti-farm checks, and final world
placement. The checker self-test passes, but live runtime proof remains open
until an in-game pass produces fresh log and status evidence.

### v3.68 - 2026-05-31 AEST - Phase 20 proof placement packet

Promoted the Phase 20 proof-reference boundary from pending CK placement to a
shell-reproducible QASmoke proof packet. `tools/pdv-phase20-proof-placement-author`
created and readback-verified 30 placed references across Altmer, Argonian,
Orc, Redguard, Khajiit, and Bosmer, each pointing at the matching Phase 20
proof ACTI base record. The per-race `--check-placements` helpers now pass for
all six race packets, `pdv_refresh_seq` was rerun, and the combined
`node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
gate is clean at `PASS=1985, WARN=1, INFO=28`. Runtime proof and final
immersive world placement remain open; the QASmoke cluster is a proof harness,
not the shipped worldbuilding pass.

### v3.67 - 2026-05-31 AEST - Phase 20 Bosmer non-hunter parity proof slice

Promoted the Bosmer non-hunter parity lane from costing-only into
compile-verified source and record wiring without expanding Green Pact item/tag
enforcement. `PDV__ManagerQuest` now records path-specific favor counters under
`PDV.Bosmer.Favor.*`, exposes `favor=oc/ls/ex/br` in Bosmer status readback,
and gates Bandit Road reversal through a seven-day major-favor cooldown. The
EventTypes/EventBus/receiver chain now routes Bosmer proof IDs `100-107` for
Old Contract proper hunt/forest kept, Living Story community/nature proof,
Exchange debt/redress, and Bandit Road road-life/reversal.
`tools/pdv-phase20-bosmer-author --create-missing` created/wired eight ACTI
proof base records. `references/authoring/PDV_Phase20_BosmerProofPlacement_Runbook.md`
now names the eight CK-owned `PDV_REFR_Bosmer*` placements and runtime smoke
matrix. SEQ was refreshed, and the combined Phase 20 Altmer/race-costing strict
gate is clean at `PASS=1963, WARN=1, INFO=28`, with only the existing unnamed
CK-authored INFO warning.

### v3.66 - 2026-05-31 AEST - Phase 20 Khajiit moon/road/focus proof slice

Promoted the Khajiit moon/road/focus lane from costing-only into
compile-verified source plus framework records. `PDV__ManagerQuest` now
origin-gates Khajiit moon and road-home scoring, rejects immediate repeats of
the same road-home anchor, exposes all five focus weights in summary readback,
and records Baan Dar, Rajhin, and Alkosh focus movement through dedicated proof
handlers.

`PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` now route
Khajiit proof IDs `10`, `33`, and `90-92` for moon observance, road-home
anchors, Baan Dar road trickery, Rajhin elegant theft, and Alkosh dragon/order
response. `pdv-phase20-khajiit-author --create-missing` created/wired six ACTI
proof base records and rewired `PDV_KhajiitLunarSubstrate` plus
`PDV_GLO_KhajiitFocusedEmphasis` on `PDV__ManagerQuest`.
`references/authoring/PDV_Phase20_KhajiitProofPlacement_Runbook.md` now names
the six CK-owned `PDV_REFR_Khajiit*` placements and runtime smoke matrix. SEQ
was refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1857, WARN=1, INFO=28`;
the only warning is the existing unnamed CK-authored INFO record class. Direct
automation still stops before CK placement and in-game proof.

### v3.65 - 2026-05-30 - Phase 20 Redguard sect proof slice

Promoted the Redguard sect lane from costing-only into compile-verified source
plus framework records. `PDV__ManagerQuest` now owns `ORIGIN_REDGUARD`, the
`Crown`, `Forebear`, and `AshAbah` sect constants, four routed proof handlers,
Survey/status surfacing, Far Shores token state, and a curse-cycle pressure
marker so vampire/werewolf posture does not become normal sect scoring.

`PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` reserve and
route Redguard proof IDs `80-83` for Crown tomb respect, Forebear road passage,
Ash'abah death duty, and Far Shores token use. `pdv-phase20-redguard-author
--create-missing` filled `PDV_StateTrack_RedguardSect`, created/wired four ACTI
proof base records, and wired `PDV_RedguardSectTrack` on `PDV__ManagerQuest`.
`references/authoring/PDV_Phase20_RedguardProofPlacement_Runbook.md` now names
the four CK-owned `PDV_REFR_Redguard*` placements and runtime smoke matrix. SEQ
was refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1762, WARN=1, INFO=28`;
the only warning is the existing unnamed CK-authored INFO record class. Direct
automation still stops before CK placement and in-game proof.

### v3.80 - 2026-06-20 - V1 custom-race compatibility contract

Phase 21 now includes V1 custom-race support as an existing-profile mapping
contract. Custom races resolve to one of the ten race profiles through
RaceCompatibility, Race Blood Test, or `PDV_RaceMap.json`; Ohmes-Raht /
Half-Khajiit maps to Khajiit profile `6`. Temporary beast-form races use
`PDV_TemporaryRaceMap.json` to defer origin capture while transformed rather
than becoming permanent cultural origins. This is a readback/source/package
contract; runtime/manual custom-race smoke remains a separate gate.

### v3.64 - 2026-05-30 - Phase 20 Orc life-mode proof slice

Promoted the Orc life-mode lane from costing-only into compile-verified source
plus framework records. `PDV__ManagerQuest` now owns `ORIGIN_ORC`, the
`City`, `Stronghold`, and `LegionExile` life-mode constants, four routed proof
handlers, Survey/status surfacing, summary readback, and a separate curse
code-pressure marker so vampire/werewolf posture does not become normal
life-mode scoring.

`PDV_EventTypes`, `PDV_EventBus`, and `PDV_EventSignalActivator` reserve and
route Orc proof IDs `70-73` for Stronghold forge, City dignity,
Legion/Exile service, and self-made community. `pdv-phase20-orc-author
--create-missing` filled `PDV_StateTrack_OrcLifeMode`, created/wired four ACTI
proof base records, and wired `PDV_OrcLifeModeTrack` on `PDV__ManagerQuest`.
`references/authoring/PDV_Phase20_OrcProofPlacement_Runbook.md` now names the
four CK-owned `PDV_REFR_Orc*` placements and runtime smoke matrix. SEQ was
refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1697, WARN=1, INFO=29`;
the only warning is the existing unnamed CK-authored INFO record class. Direct
automation still stops before CK placement and in-game proof.

### v3.63 - 2026-05-30 - Phase 20 Argonian Hist/People proof slice

Promoted the Argonian Hist/People lane from costing-only into compile-verified
source plus framework records. `PDV_Substrate_ArgonianHist` now owns separate
Hist, People, Void, posture, Sithis-signal, and bed-of-choice cadence keys with
gentle Hist-distance dawn decay, a non-curse floor, and threshold-gated Void
activation. `PDV__ManagerQuest` refreshes Argonian posture on dawn and curse
changes, surfaces layered status text, and routes Hist maintenance, People
support, Void signal, and bed-of-choice proof handlers. `PDV_EventTypes`,
`PDV_EventBus`, and `PDV_EventSignalActivator` reserve and route Argonian proof
route IDs `60-63`.

`pdv-phase20-argonian-author --create-missing` attached the concrete substrate,
created/wired `PDV_State_ArgonianHistPosture`, created/wired four ACTI proof
base records, and wired the manager properties. `references/authoring/PDV_Phase20_ArgonianProofPlacement_Runbook.md`
now names the four CK-owned `PDV_REFR_Argonian*` placements and runtime smoke
matrix. SEQ was refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1633, WARN=1, INFO=30`;
the only warning is the existing unnamed CK-authored INFO record class. Direct
automation still stops before CK placement and in-game proof.

### v3.51 - 2026-05-30 - Phase 19 live content closeout

Phase 19 now has one approved live content packet. Default
`tools/pdv_patch.mjs build` emits only `approved` rules; `candidate` and
`tooling-example` output require explicit test flags. The retired proof
manifest remains plan-only, and
`references/authoring/patch-rules/PDV_Phase19TempleLocationRules.json` adds
`LocTypeTemple` to six obvious shrine/temple `LCTN` records in the generated
`PDV_ClassificationPatch.esp`.

`PDV_ClassificationPatch.esp` is active in Devotion Dev immediately after
`Devotion.esp`. `tools/pdv_verify.mjs --strict-phase19`
verifies active profile placement, six Temple LCTN overrides, absence of the
retired proof overrides, and source-plugin safety. Packaging policy is locked:
core vanilla/DLC approved rules may later promote into the framework ESP via a
separate release-packaging merge gate; list-specific compatibility rules remain
separate generated patches.

### v3.50 - 2026-05-30 - Phase 19 generated patcher proof

Phase 19 now has a generated-patch proof lane. `tools/pdv_patch.mjs build`
writes `PDV_ClassificationPatch.esp` through the existing Mutagen bridge
patch-request contract, while `validate` and `plan` remain read-only. The
patcher resolves payload references, blocks unresolved candidate/approved
rules, and keeps tooling examples plan-only by default.

`references/authoring/patch-rules/PDV_Phase19ProofRules.json` is the first
candidate proof manifest. It proves one keyword override and one FormList
injection in a generated ESL-flagged patch, but does not approve live gameplay
classification content. `tools/pdv_verify.mjs --strict-phase19` verifies dry-run
determinism, generated patch readback, and source-plugin safety.

### v3.45 - 2026-05-28 - Compatibility rebaseline (renumbered to Phase 21)

The compatibility lane was rebaselined from a Sacrosanct-first standalone patch into an
Authoria-first list-author compatibility program. The seven target lists are
JOJ, TOT, HOH, MOM, DoD, VOV, and Authoria/ARR. Compatibility work now uses a
tracked matrix/status ladder, one list-specific patch per package, exact
religion-overhaul removal sets, targeted shrine adapters, system-family
policies for survival/curse/quest/social mods, and maintainer briefs with
focused smoke checklists. The 1.0 compatibility gate is Authoria accepted into
its integration/test flow, with the other six lists at least `patch-packaged`.

### v3.48 - 2026-05-30 - Phase 18 Nord dialogue readback closeout

The four Phase 18 Nord recognition topics are now live CK-authored records in
`Devotion.esp`: Froki/Kyne Champion, Heimskr/Talos Champion,
Andurs broad death-rite, and Aela werewolf/Hircine tension. CK saved the Topic
Info records unnamed, so strict readback now resolves them by owning topic,
speaker, prompt, response line, and condition stack. SEQ was refreshed after
the CK save. `node .\tools\pdv_verify.mjs --strict-phase18 --strict-nord --json`
is clean at `PASS=1185, INFO=28`, with no `FAIL`, `WARN`, or `TODO`.

The remaining runtime matrix was completed on the current proof save: Player
page, Developer Options persistence, Survey broad/focused states,
Hircine/werewolf tension, vampire suppression/cure scar, save/load, and
positive/negative dialogue availability for all four speakers.

### v3.49 - 2026-05-30 - Phase 18 runtime closeout

Phase 18A/B is runtime-proven. Fresh-save player/status proof passed for the
Player page, Developer Options persistence, Survey broad/focused Nord states,
Hircine/werewolf tension, vampire suppression/cure scar, and save/load
persistence. The final human dialogue smoke passed for Froki, Heimskr, Andurs,
and Aela, including each speaker's positive eligibility case and negative
checks for wrong race, wrong deity/state, wrong tier, or vampire-blocked state
as applicable. The current strict Phase 18/Nord verifier remains clean at
`PASS=1185, INFO=28`, with no `FAIL`, `WARN`, or `TODO`.

### v3.47 - 2026-05-28 - Phase 18 Nord runtime matrix contract

Phase 18 now has a locked handoff/runtime matrix rather than a loose pending
proof note. `references/authoring/PDV_Phase18StatusNord.manifest.json` records
branch/topic/INFO hints for Froki, Heimskr, Andurs, and Aela; it also records
the required Player-page, Developer Options, Survey Devotion, broad/focused
Nord, Hircine/werewolf, vampire suppression/cure scar, save/load, and dialogue
positive/negative proof cases. `references/authoring/PDV_Phase18_StatusNord_Runbook.md`
expands those cases into CK-safe operator steps and keeps generated dialogue
creation out of scope.

### v3.46 - 2026-05-28 - Phase 17 decay runtime closeout

Phase 17 is runtime-proven. The fresh-save proof pass covered grace no-op
(`20.00 -> 20.00`), eligible decay (`20.00 -> 19.50`), same-day guard
(`19.50` held), broad worship reduced decay (`20.00 -> 19.90`), active-patron
skip, non-patron drift while Kyne stayed protected, Devoted floor
(`50.00 -> 10.00`), and Champion floor (`150.00 -> 50.00`). The Phase 16
regression pass also held: broad worship suppressed neglect and active Kyne
still produced targeted neglect with `count=1` and `kyneSpell=1`.

Runtime proof exposed two manager fixes that are now live and compiled: fresh
debug eligibility can use negative proof timestamps on a fresh save, and tier
floors persist through `PDV.PassiveDecayFloor` instead of recalculating downward
from the current piety tier each day. The full bridge ladder is clean at
`FAIL=0, WARN=1, PASS=1155, INFO=29`; the remaining warning is expected `SEQ
freshness`.

### v3.44 - 2026-05-28 - Phase 17 decay bridge source/readback

Phase 17 now bridges Phase 16 neglect and Phase 18 player status with a
standalone manifest and verifier gate. `PDV__ManagerQuest` keeps the locked
`3.0` day grace, `0.5` daily decay, and `0.2x` broad-worship multiplier, skips
passive decay for the active patron, and leaves non-patron deities eligible to
drift. `PDV_MCM` exposes gated debug controls for grace, eligible decay,
decay-only pass, compressed proof days, and selected-deity decay summary.
`PDV__ManagerQuest` and `PDV_MCM` compile with zero Papyrus warnings, and the
full Phase 18 bridge gate is clean at `FAIL=0, WARN=1, PASS=1151, INFO=29`.
The remaining warning is the existing `SEQ freshness`. This source/readback
entry is superseded by v3.46 runtime closeout.

### v3.43 - 2026-05-28 - CKRA dialogue proof lane handoff

The vendored `tools\creation-authoring` package now includes a generic
`dialogue-v1` proof lane for future CK-authored dialogue work. It supports
manifest/readback proof for branch, topic, unnamed Topic Info, condition stack,
and SEQ freshness, while strict product mode still fails closed until native
CK command evidence exists. This reduces manual authoring bookkeeping without
reopening the unsafe generated dialogue path that caused the Phase 11 CTD risk.

### v3.42 - 2026-05-28 - Phase 13 runtime closeout and cadence lesson

The Hircine/Nord pilot is now runtime-proven as a first full Daedric path.
Fresh-save Debug-page proof confirmed the negative gate before day-three
commitment signals, Seeker and Devoted price activation on the real multi-day
hunt-rite cadence, werewolf curse-entry pressure, cure-started residue,
renounce reset plus residue, and the vampire negative path. The important
runtime lesson is that `HandleHircineHuntRite()` applies the shared daily
repeat multiplier before the pilot records stigma or piety; same-day rites
scale at `1.0`, `0.7`, `0.49`, so `sig=3` can still leave `p=5.88`, `tier=0`,
and `price=None`. Counted Seeker proof therefore requires one rite on each of
three in-game days instead of same-day spam.

### v3.41 - 2026-05-28 - Phase 14-16 runtime closeout and Phase 13 status correction

Closed the live runtime matrix for the generic Phase 14-16 seams and removed
the stale overclaim that Phase 13 was already fully proven. Fresh-save runtime
proof on the Debug page confirmed Kyne offer seed/evaluate, decline, refuse,
accept, and accepted-patron stability for Phase 14; the shared werewolf /
vampire / none curse seam plus Hircine curse-entry and werewolf-cure traces
for Phase 15; and active-Kyne low-piety neglect selection plus broad-worship
suppression on re-evaluation for Phase 16. The same pass also hardened the
debug path itself: `PDV_MCM` now reports `SelectedCommitment=...` directly, the
Kyne commitment seed helper uses the live encoded-day format with a debug-seed
override for day-0 fresh starts, and the current targeted strict gate is clean
at `FAIL=0, WARN=1, PASS=1092, INFO=28` with only `SEQ freshness` left as a
warning. Durable status correction: Hircine hunt-rite ingress remains proven
and current logs show curse-entry/cure traces, but the full Hircine/Nord
boon/price/renounce/residue/mixed-recovery loop is still open until it is
recorded explicitly.

### v3.40 - 2026-05-26 - Phase 13-16 framework closeout

Locked the Phase 13-16 architecture defaults in Sections 11-14 and the living
product/race docs: D-12 now keeps Daedric paths on a separate operational
roster, D-13 now uses mixed recovery by default, D-14 now uses reduced
cross-Prince rivalry math, and D-17 now resolves werewolf detection through a
combined shared-service seam. The first full Phase 13 pilot is now explicitly
`Hircine + Nord`. A new `tools/pdv-phase13-author` helper created and wired the
three Hircine price records into `Devotion.esp`, and SEQ was
refreshed after the live write. Phase 14-16 manifests now reflect the generic
formal-offer engine, live curse detection, and generic neglect selection pass.
`tools/pdv_verify.mjs` now checks the generic Phase 14 source surface, the live
Phase 15 curse-transition surface, and the generic Phase 16 neglect-selection
surface. The full strict ladder is clean at `PASS=1089, WARN=0, FAIL=0,
INFO=28`. Remaining work is the manual runtime proof matrix for Hircine/Nord
cure-residue behavior plus the Phase 14-16 positive/negative/save-load proofs.

### v3.38 - 2026-05-26 - Phase 11 runtime proof

Phase 11's Arngeir/Kynareth privilege pilot is now CK-authored and
runtime-proven. The live ESP contains
`PDV_DIAL_Phase11ArngeirKyneRecognitionBranch`,
`PDV_DIAL_Phase11ArngeirKyneRecognitionTopic`, and a CK-authored unnamed
`INFO` verified by topic, Arngeir speaker, prompt, response line, and the
Arngeir/Nord/Kyne/Champion condition stack. SEQ was refreshed. Runtime proof
passed for the positive Nord/Kyne Champion state, the non-Nord negative, wrong
active deity negative, below-Champion negative, and save/load sanity. The full
strict packet verifier is clean at `PASS=908, INFO=28`, with no `FAIL`, `WARN`,
or `TODO`.

### v3.37 - 2026-05-25 - Phase 11 CK authoring packet

The Phase 11 Arngeir/Kynareth manifest now doubles as a
`creation-authoring.v1` manifest while preserving its verifier-facing D-10
contract. A dedicated Phase 11 creation-authoring profile points at the CKPE
bridge and the full strict packet verifier, and the planner reports the branch,
topic, info, and SEQ operations as CKPE-ready. This does not promote live Phase
11 status: the installed native bridge still blocks mutating dialogue handlers,
so the next live step remains manual CK authoring using
`PDV_Phase11_CKSafeDialogue_Runbook.md`, followed by SEQ refresh, manifest
promotion to `live-dialogue-authored`, strict readback, and runtime
positive/negative proof.

### v3.36 - 2026-05-25 - Phase 11 generated-dialogue guard

After promoting the Phase 9/next-packet branch into `main`, the full strict
packet verifier stayed clean at `PASS=898, INFO=29`. The next-packet helper now
fails closed if asked to generate Phase 11 Arngeir dialogue, preserving only the
removal path for those records. `PDV_Phase11PrivilegePilot.manifest.json` now
records the manual CK-only branch/topic/info/SEQ packet for the future
Arngeir/Kynareth recognition rebuild. Phase 11 remains prep-only until CK-safe
dialogue readback, SEQ refresh, and positive/negative runtime proof pass.

### v3.35 - 2026-05-25 - Khajiit, commitment, and neglect runtime proof

Closed the live runtime smoke for the Section 21.5 next packet, excluding
Phase 11 dialogue which remains prep-only after v3.34. Khajiit proof showed
road-home cadence producing Khenarthi focus at
`KhajiitLunar=metric=13.139999; tier=1; roadhome=3; focus=Khenarthi;
kh=54.75; az=0.00`, then moon observance switching focus to Azurah at
`metric=24.904676; tier=1; phase=1; observance=6; roadhome=3; focus=Azurah;
kh=54.75; az=73.52`; save/load persistence held at `metric=24.904699`.

Kyne commitment proof used two positive Kyne signal days to produce
`Commitment=pending=0; days=2; cooldown=0.00`, then proved `Not Yet`
clearing pending with rupture `0` and about 7 days cooldown, `Refuse` clearing
pending with rupture `1` and 14 days cooldown, and `Accept` setting
`Active patron=KYNE [0]`, `Patron state=ACTIVE PATRON`,
`Active piety=51.000000`, `Active tier=DEVOTED`, and active deity index `0`.
The accepted patron state persisted across reload.

Kyne neglect/decay proof passed no-decay inside the 3-day grace window, one
decay tick after grace, no second same-day decay, low-piety Kyne neglect spell
application, and spell removal after piety recovery. Final strict verifier:
`PASS=898, INFO=29`, with no `FAIL`, `WARN`, or `TODO`.

### v3.34 - 2026-05-24 - Phase 11 dialogue CTD remediation

CrashLogger tied a Skyrim CTD to the generated Phase 11 Arngeir dialogue topic
and branch (`PDV_DIAL_Phase11ArngeirKyneRecognitionTopic` /
`PDV_DIAL_Phase11ArngeirKyneRecognitionBranch`). The generated
`DLBR`/`DIAL`/`INFO` records were removed from `Devotion.esp`
with a targeted helper pass, preserving the Khajiit, commitment, and
neglect/decay packet records. `references/authoring/PDV_Phase11PrivilegePilot.manifest.json`
is demoted back to `prep-only`, and `--strict-phase11` now checks live dialogue
records only when the manifest status is `live-dialogue-authored`.

### v3.33 - 2026-05-24 - Phase 11 Arngeir dialogue readback

Superseded by v3.34. The generated dialogue records passed static readback but
were unsafe at runtime and have been removed.

The next-packet helper now authors the PDV-owned Arngeir/Kynareth recognition
dialogue records directly into `Devotion.esp`:
`PDV_DIAL_Phase11ArngeirKyneRecognitionBranch`,
`PDV_DIAL_Phase11ArngeirKyneRecognitionTopic`, and
`PDV_INFO_Phase11ArngeirKyneRecognition`. `--strict-phase11` now reads back the
manifest plus live `DLBR`/`DIAL`/`INFO` structure, Arngeir speaker, prompt,
recognition line, and the Arngeir/Nord/Kyne/Champion condition stack.

Current combined strict gate:
`PASS=908, WARN=1, FAIL=0, INFO=28`. The one warning is SEQ freshness because
dialogue changed after the last SEQ generation. Runtime completion remains open
until SEQ refresh and the two-branch runtime smoke.

### v3.32 - 2026-05-24 - Khajiit/commitment/neglect packet scaffold

Implemented the next Section 21.5 packet scaffold without claiming runtime
closeout. Source and verifier coverage now exist for Khajiit focused emphasis,
Kyne formal commitment, and Kyne neglect/decay. The Khajiit focus mirror is
`PDV_GLO_KhajiitFocusedEmphasis`, with enum values `None=0`, `Khenarthi=1`,
`Azurah=2`, `BaanDar=3`, `Rajhin=4`, and `Alkosh=5`; it is deliberately
separate from `PDV_GLO_PatronState`.

`tools/pdv-next-packet-author` repaired the Phase 10 Dunmer cooldown-key drift:
portable shrine practice now uses `PDV.Signal.DunmerPortableShrine.Activator`,
private/home shrine practice keeps `PDV.Signal.DunmerHome.Activator`, and
`--strict-phase10` fails if both ACTI records share one once-per-day key again.

The helper also created `PDV_MGEF_Neglect_Kyne` and `PDV_SPEL_Neglect_Kyne`,
wired `PDV__ManagerQuest.PDV_SPEL_Neglect_Kyne`, and authored the live
PDV-owned Arngeir/Kynareth recognition `DLBR`/`DIAL`/`INFO` records. The
combined strict gate is now down to `PASS=908, WARN=1, FAIL=0, INFO=28`; the
warning is SEQ freshness after dialogue ESP mutation.

Open proof boundary: refresh SEQ, then run the combined strict gate plus the
two-branch runtime smoke in
`references/authoring/PDV_NextPacket_DocGrilledPlan.md`.

### v3.31 - 2026-05-24 - Phase 10 Dunmer substrate runtime proof

Closed Phase 10 as a Dunmer ancestor substrate proof-graduation slice. Counted
runtime proof used a fresh Dunmer baseline with active patron piety and deity
roster values at `0.000000`, then proved both reused normal-play ACTI surfaces:
private/home shrine route `31` advanced the substrate to
`DunmerAncestor=metric=8.000000; tier=1; prayers=0; homes=1`, and portable
shrine route `30` after the daily gate cleared advanced it to
`DunmerAncestor=metric=13.000000; tier=1; prayers=1; homes=1`. Patron piety
remained separate, save/load persistence passed, and the combined strict gate
was clean at `PASS=847, WARN=0, FAIL=0, INFO=28`.

The proof also exposed a small live-record follow-up: both Dunmer ACTI proof
records shared `OncePerDayKey = PDV.Signal.DunmerHome.Activator`, which forced
the portable-shrine proof to wait for the shared key to clear after the
private/home activation. v3.32 corrected that drift and added strict verifier
coverage without reopening the runtime proof.

### v3.30 - 2026-05-24 - Phase 9 status sync and Phase 10/11 handoff

Corrected the top-level architecture status to match the completed Phase 9
runtime proof already recorded in the Phase 9 closeout entry and target-state
tracker. Phase 9 Bosmer Path is fully runtime-proven: setup, all five route
proof surfaces, path offers, confirmation-rite switching, Old Contract re-entry,
PactBound/compliance separation, forced reckoning `Renounce`, forced reckoning
`Recommit`, save/load persistence, and the combined strict gate at `PASS=808,
WARN=0, FAIL=0, INFO=28` are the current closeout evidence.

Phase 10/11 planning now treats those phase numbers as subsystem labels while
Section 21.5 remains authoritative for execution order. Phase 10 may proceed as
a Dunmer ancestor substrate proof-graduation slice. Phase 11 may receive
documentation, verifier, and D-10 privilege-pilot prep, but live privilege
implementation remains behind the Section 21.5 commitment and neglect/decay
gates.

### v3.28 - 2026-05-23 - CKRA GLOB duplicate-create authoring proof

The CKPE authoring workbench now has its first proof-ledger-supported creation
capability: `glob.duplicate_create` for disposable generated plugins. The
strict evidence chain duplicates `PDV_GLO_ActivePiety` through CK's Object
Window path, proves the created GLOB is owned by the active generated plugin,
mutates FNAM/FLTV to short `1`, posts CK's native save command, reads the
saved ESP back directly, and promotes only GLOB in the generated capability
matrix. This is an authoring/tooling revision, not a PDV runtime phase
closeout. It does not prove quest, message, activator, FormList, VMAD array,
Story Manager, alias, or source-plugin promotion workflows. Durable lesson:
CK automation must respect both UX state and lower-layer persistence; right
click selection/focus/popup behavior and active-plugin save/readback are part
of the proof, not incidental noise.

### v3.27 - 2026-05-21 - Phase 8 runtime proof closeout

### v3.28 - 2026-05-24 - Phase 9 Bosmer path closeout

Phase 9 is now fully runtime-proven on a Bosmer save. The live framework ESP
contains the Bosmer path state track, Y'ffre/Z'en/Baan Dar path eligibility,
all setup/suggestion/reckoning messages, manager properties, deity FormList
membership, and five placed proof-surface activators. Runtime proof covered all
five route IDs (`41-45`), Old Contract startup, Living Story offer and
confirmation, Exchange offer and confirmation, Bandit Road offer and
confirmation, Old Contract re-entry through three Pact-positive days,
save/load persistence, and both forced-reckoning outcomes. Renounce moved the
player to `LivingStory`, cleared `PactBound`, and incremented
`LapsedFromPact`; Recommit preserved `OldContract`/`PactBound` and restored
`GreenPactCompliance` to `30`.

Runtime proof surfaced one implementation bug: `PDV_StateTrack` retained only
two evidence days, while Old Contract re-entry requires three Pact-positive
days within seven. `PDV_StateTrack.psc` now stores and counts
`LatestDay`, `PreviousDay`, and `ThirdDay`, and `PDV_StateTrack.pex` compiles
cleanly. The final strict closeout gate remains clean:
`node .\tools\pdv_verify.mjs --strict-phase9 --strict-phase8 --strict-phase7
--strict-preflight --strict-skeleton --strict-pattern-proving --json` =>
`PASS=808, WARN=0, FAIL=0, INFO=28` on 2026-05-24 AEST.

### v3.29 - 2026-05-21 - Content authoring track recorded as a parallel workstream

Added Section 25.9, naming the content authoring track as a workstream that
runs in parallel with and separate from the coding roadmap. The track covers
drafting, verification, and ratification of player-facing religious prose in
`race-sheets/PDV_RaceContent_Manifest.md` and
`race-sheets/PDV_DaedricContent_Manifest.md`, validated by
`tools/pdv_content_verify.mjs`. CAT-1 (Aedric/native draft prose, all 10
races), CAT-2 (content verifier, token tables, consistency audit), and CAT-3
(the Boethiah Daedric pilot) are complete; CAT-4 (Daedric expansion), CAT-5
(gated-slot closure), and CAT-6 (ratification and ESP promotion) are the
remaining work. Drafting runs ahead of code; promotion (CAT-6) follows the
code roadmap and feeds the Content-Feel Beta and 1.0 gates. Section 17 now
points to 25.9 for the prose-drafting side. No architecture contract changed.

### v3.27 - 2026-05-21 - Phase 8 runtime proof closeout

Phase 8 is now fully runtime-proven on an Imperial save. Baseline
`Uncommitted` raw-value movement, pending start/cancel, 3-day commit into
`PublicCompliant`, committed-state multiplier persistence under raw rollback,
3-day commit into `ConcordatEnforcer`, halved inward movement while the
extreme gate stayed locked, save/load persistence before and after gate
unlock, and 3-day exit back to `PublicCompliant` all passed. This closeout
relied on the already-proven Phase 7 ingress surfaces (`CW01A`, `CW01B`, and
hidden Talos shrine defiance) and focused the new runtime proof on the
reputation-track state machine itself. The strict combined closeout gate also
passed clean after the hotfixes: `node .\tools\pdv_compile.mjs --script
PDV__ManagerQuest --strict-phase8 --strict-phase7 --strict-preflight
--strict-skeleton --strict-pattern-proving` =>
`FAIL=0, WARN=0, TODO=0, PASS=642, INFO=28` at 2026-05-20 20:20:45 AEST.
Durable lesson: the generated `PDV_Phase8ConcordatTalosOverlay.esp` was unsafe
as a steady-state runtime solution because a partial VMAD override could win
with blank/default Talos properties. The live fix is manager-owned runtime
wiring plus save-healing (`EnsurePhase8RuntimeWiring()` and
`EnsureTalosRuntimeIdentity()`), and the overlay now remains an inactive
historical authoring artifact.

### v3.26 - 2026-05-20 - Overnight enabler implementation sync

The first approved overnight-enabler work is now reflected in the living v3
contract. `PDV__ManagerQuest.psc` hardening now treats commitment proof as
recent signal-day evidence plus per-deity cooldown storage and allows accepted
patrons to decay once per in-game day without falsely closing the full
commitment or neglect slices. Prisma Section 16.6 also now promotes the
overlay-toast payload contract for `favor`, `dawn`, `neglect`, `tier`, and
`rivalry` to stable while keeping panel payloads and other event shapes at
prototype maturity. The targeted compile pass for `PDV__ManagerQuest` and the
strict Pattern Proving verifier both ran clean on 2026-05-20; tomorrow's
remaining proof boundary is runtime smoke, not source or doc uncertainty.

### v3.24 - 2026-05-20 - FragmentBridge verifier expansion and refreshed baseline

The strict compile/verify surface now explicitly includes `PDV_FragmentBridge`
as part of the live Phase 7 closeout tooling rather than treating the Civil War
fragment helper as an undocumented sidecar. `tools/pdv_compile.mjs` now keeps
the script in the active compile set, `tools/pdv_verify.mjs` now requires it
and checks the bridge-source contract, and the combined strict gate remained
fully clean after that coverage expansion: `FAIL=0, WARN=0, TODO=0, PASS=579,
INFO=28` at 2026-05-20 15:51 AEST. This is tooling/readback hardening, not a
new phase closeout, but it is the current verifier baseline the living docs
should quote.

### v3.24 - 2026-05-20 - Overnight enabler rule added to Section 21.5

Section 21.5 now explicitly allows a narrow class of pull-forward work:
overnight enabler micro-slices. This does **not** change the authoritative
completion order. Instead, it records that implementation may pull forward
`Commitment + Neglect/decay` hardening, `UI toast` contract stabilization, the
`Khajiit focused-emphasis` scaffold, and limited `Bosmer path` bookkeeping when
those tasks unblock unattended overnight work without falsely declaring the
parent slices complete. Privilege, full Daedric price/stigma, and curse-state
remain intentionally sequence-sensitive and stay behind the live gates.

### v3.23 - 2026-05-20 - Pattern Proving reduced reorder adopted

Section 21.5 now adopts the reduced phase-order reorder ratified from the
archived review note at `archive/phase-order-recommendations-2026-05-20.md`
rather than the full extra-slice rewrite proposed there. The first four pilot
slices stay intact, then the live order becomes commitment, neglect/decay,
privilege, contextual favor, UI toast hardening, Daedric price/stigma, and
curse-state. No standalone base-script-verification slice or standalone
signal-breadth slice was added because Structural Skeleton and the current
Phase 7 proof already cover those seams in the live repo state. The practical
effect is that commitment now exists before decay is tuned against broad/patron
state, favor tuning becomes decay-aware, privilege and Prisma toast contracts
stabilize before broad authored content growth, and the first full Daedric
pilot enters after those calibration layers instead of alongside them.

### v3.25 - 2026-05-20 - Phase 7 fully closed

Phase 7 is now fully closed. The final manual packet ended on tiny vanilla
quest-fragment mod events rather than custom fragment properties or inline
EventBus casts: `CW01A` stage `200` now fires
`SendModEvent("PDV.ConcordatCompliance")`, and `CW01B` stage `200` now fires
`SendModEvent("PDV.ConcordatDefiance")`. Runtime proof in `Papyrus.0.log`
showed the full `PDV_PlayerEvents -> PDV_EventBus -> PDV__ManagerQuest` chain
for both sides on 2026-05-20: Legion compliance logged
`RouteConcordatPressure complete: 20 adjustment 15`, and Stormcloak defiance
logged `RouteConcordatPressure complete: 21 adjustment -15`, with no Talos
award on either join marker. The strict verifier was rerun after the CK/SEQ
closeout and stayed fully clean at `FAIL=0, WARN=0, TODO=0, PASS=588, INFO=28`
at 2026-05-20 16:44 AEST. Durable lesson: when a vanilla quest fragment only
needs to notify PDV, `SendModEvent(...)` is the safer posture than trying to
teach the fragment compiler about custom PDV script types.

### v3.22 - 2026-05-20 - Phase 7 runtime proof and zero-warning baseline

Phase 7 now has counted runtime proof for the live shrine/shout surfaces that
were in scope for this wave. The hidden Talos shrine reference on an Imperial
save proved curated Talos award, Concordat pressure, repeat protection,
save/load persistence, and next-day reopen while preserving shrine behavior.
The shout lane on a clean Nord save proved counted PO3 ingress, deity-side
anti-farm behavior, and the manager fallback pattern after alias-only
`OnShoutAttack(Shout akShout)` failed to surface counted events reliably in
runtime. The strict verifier baseline is also fully quiet again: after manual
xEdit consolidation of `PDV_MCM` VMAD and post-merge-back SEQ freshness, the
combined strict gate now reads `FAIL=0, WARN=0, TODO=0, PASS=572, INFO=28` at
2026-05-20 13:45 AEST. The remaining open Phase 7 packet is exact Civil War
compliance/defiance one-shot wiring after local record confirmation, using the
fragment-bridge pattern instead of direct inline EventBus casting.

### v3.21 - 2026-05-20 - Hidden shrine reference posture

Phase 7 shrine routing is now documented as a real-reference wiring problem,
not a helper-activator problem. Preferred posture is co-attachment on the
actual hidden Talos shrine reference when that devotional surface is needed;
nearby helper ACTIs remain fallback proof shapes only, and global shrine
base-script replacement stays out of bounds. Sections 5, 9, and 21 now align
the architecture with that narrower compatibility-first rule.

### v3.20 - 2026-05-20 - Phase 19 tooling foundation kickoff

Section 17 now reflects the first live Phase 19 tooling pass instead of
treating it as purely future work. `tools/pdv_patch.mjs` exists as a
planning-first dry-run patcher that validates tracked
`pdv_patch_rules_v0` manifests, reads the resolved `Devotion Dev` load order,
resolves winning records, and emits deterministic review output without
writing a generated ESP yet. `pdv_author.mjs` planning/status output now also
promotes VMAD-array work into explicit manual follow-up packets with intended
payload plus verifier readback expectations instead of generic unsupported
notes.

### v3.18 - 2026-05-19 - Slice 1 runtime proof closeout

Closed Slice 1 as a runtime-proven Pattern Proving ingress packet. Manual
ACTI/MGEF proof records now exist and pass verifier readback. Dunmer portable
and private shrine practice, Bosmer OldContract Green Pact violation, and the
Hircine hunt rite all routed through the new receiver layer into existing
EventBus/manager/substrate/path handlers.

Runtime proof surfaced two containment fixes: `PDV_PlayerEvents` now waits for
playable controls and retries after `RaceSex Menu` closes before final origin
capture, and `PDV_MCM` now falls back through `PDV_EventBusService` when a
duplicate VMAD attachment leaves the active MCM instance missing direct
manager/debug properties. The duplicate VMAD remains a known consolidation
cleanup item, but it no longer blocks Slice 1 proof.

Final closeout gate: `node .\tools\pdv_verify.mjs --strict-preflight
--strict-skeleton --strict-pattern-proving --json` returned `FAIL=0, TODO=0,
PASS=522, WARN=2, INFO=28` at 2026-05-19 20:28 AEST.

### v3.62 - 2026-05-30 - Phase 20 Altmer proof-placement handoff

Converted the remaining Altmer proof-trigger manual boundary into an exact CK
packet. `references/authoring/PDV_Phase20_AltmerProofPlacement_Runbook.md`
now names the four proof ACTI placements, the expected `PDV_REFR_Altmer*`
reference EditorIDs, the post-save placement readback, and the runtime smoke
matrix. The Altmer manifest now carries `placementRefEditorId` for each wired
trigger surface. `pdv-phase20-altmer-author --check-placements` is a read-only
placement checker matching the Phase 9 proof-reference pattern, and
`--strict-phase20-altmer` is ready to validate placed references once
`placementStatus` is promoted beyond `manual-placement-required`. Direct
automation still stops before CK placement and in-game proof.

### v3.61 - 2026-05-30 - Phase 20 Altmer curse-message slice

Promoted the Altmer Exiled curse surface out of prose. `PDV__ManagerQuest` now
handles Altmer vampire exile pressure, werewolf hard halt, cure scar text, and
survey/status summary through compile-verified source helpers, and
`pdv-phase20-altmer-author` now creates/fills the three tracked `MESG` records:
`PDV_Msg_Altmer_VampireExiledPath_Entry`,
`PDV_Msg_Altmer_VampireExiledPath_Recognition`, and
`PDV_Msg_Altmer_CurseState_WerewolfHardHalt`. The helper wires those properties
on `PDV__ManagerQuest`, the Altmer manifest status is `curse-message-wired`,
SEQ was refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1549, WARN=1, INFO=30`;
the only warning is the existing unnamed CK-authored INFO record class. CK
placement/attachment of the four proof ACTIs and runtime proof remain open.

### v3.60 - 2026-05-30 - Phase 20 Altmer trigger-proof slice

Promoted the Altmer route scaffold into concrete proof surfaces. The reusable
`PDV_EventSignalActivator` and `PDV_EventSignalEffect` receivers now understand
Altmer route IDs `50-53`, carry `SignalValue` plus `SignalSourceId`, and route
Lorkhan pressure, crisis source, dawn steadiness, and orthodox-cost signals into
the existing EventBus/manager path. `pdv-phase20-altmer-author` now creates and
wires the four tracked ACTI base records:
`PDV_ACTI_AltmerDragonbornCrisisSignal`,
`PDV_ACTI_AltmerLorkhanPressureSignal`,
`PDV_ACTI_AltmerDawnSteadinessSignal`, and
`PDV_ACTI_AltmerOrthodoxCostSignal`. The Altmer manifest status is now
`trigger-proof-wired`; CK placement/attachment, Exiled vampire handling, and
runtime proof remain open. The receiver scripts compiled cleanly, SEQ was
refreshed, and `node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1543, WARN=1, INFO=30`;
the only warning is the existing unnamed CK-authored INFO record class.

### v3.59 - 2026-05-30 - Phase 20 Altmer favor-record slice

Promoted the two source-level Altmer favor families into real contextual-favor
records. `PDV__ManagerQuest` now exposes the two Altmer favor spell properties,
activates `FAVOR_LANE_ALTMER` through `TryActivateContextualFavor()` for dawn
steadiness and orthodox costly enforcement, and suppresses the clean positive
favor lane while an Altmer curse/exile pressure state is active. The
`pdv-phase20-altmer-author` helper now creates/fills the matching `KYWD`,
`MGEF`, and `SPEL` records and wires those spell properties on
`PDV__ManagerQuest`. The Altmer manifest status became `favor-records-wired`;
later v3.60 promoted four trigger proof ACTI base records while CK placement,
Exiled vampire handling, and runtime proof stayed open. `PDV__ManagerQuest`
compiled cleanly, SEQ was refreshed, and
`node .\tools\pdv_verify.mjs --strict-phase20-altmer
--strict-phase20-race-costing --json` returned `PASS=1493, WARN=1, INFO=30`;
the only warning is the existing unnamed CK-authored INFO record class.

### v3.58 - 2026-05-30 - Phase 20 immersion-proof gate

Added `immersionProof` blocks to the Altmer, Argonian, Orc, Redguard, Bosmer
non-hunter, and Khajiit Phase 20 implementation-costing manifests. Each block
names the race's signature promise, diegetic trigger meaning, feedback surface,
rejected generic behavior, normal-session feel, and runtime promotion gate.
`tools/pdv_verify.mjs --strict-phase20-race-costing` now fails missing or thin
immersion proof, and the Altmer-specific gate validates the Altmer proof as
well. The hardened strict gate returned `PASS=1481, WARN=1, INFO=30` on
2026-05-30; the warning is the existing unnamed CK-authored INFO record class.

### v3.57 - 2026-05-30 - Race immersion budget and Altmer crisis record wiring

Promoted immersion from an implied balance concern into an explicit race reward
budget axis. `PDV_RaceRewardBudgetLedger.md` now carries immersion budget rules
and a race-by-race immersion matrix; `PDV_RaceGameplayBalanceAudit.md` requires
an immersion proof before runtime promotion; and
`PDV_RaceImplementationCostingBacklog.md` requires each slice to name the
diegetic trigger meaning, feedback surface, rejected generic behavior, and
normal-session feel. Later v3.58 made that requirement verifier-enforced.

`tools/pdv-phase20-altmer-author --create-missing` created and wired
`PDV_State_AltmerCrisis` as a `PDV_StateTrack` and set
`PDV_AltmerCrisisTrack` on `PDV__ManagerQuest`. The Altmer implementation
manifest became `record-wired`; later v3.59 wired the first two Altmer favor
spell records.

### v3.56 - 2026-05-30 - Altmer source scaffold

Promoted the Altmer Phase 20 pilot from costing-only into compile-verified
source scaffolding. `PDV__ManagerQuest` now owns the crisis enum constants,
StorageUtil-backed crisis state, Lorkhan pressure intake, accepted crisis
sources, rejected-surface assertions, debug helpers, and two source-level
favor families: quiet dawn steadiness and marked orthodox costly enforcement.
`PDV_EventBus` exposes Altmer route helpers, and `PDV_EventTypes` reserves
event IDs `50-53` for those routes. The Altmer implementation manifest is now
`source-scaffolded`; later v3.57 record-wired `PDV_State_AltmerCrisis`, and
v3.59 wired the first two Altmer favor spell records.

### v3.55 - 2026-05-30 - Phase 20 race-costing manifest gate

Expanded the race implementation-costing lane from the Altmer pilot into the
first P1 manifest set: Argonian Hist/People, Orc life-mode, Redguard sect,
Bosmer non-hunter parity, and Khajiit lunar/road. Added
`--strict-phase20-race-costing` to validate all Phase 20 race costing manifests
for schema, decision sources, state surfaces, enum contracts, required content
rows, rejected hooks, verifier gates, first implementation slices, and runtime
proof cases. `pdv_compile.mjs` now passes Phase 19/20 strict verifier flags
through when a compile should immediately run one of those gates.

### v3.54 - 2026-05-30 - Race implementation-costing backlog

Added `references/authoring/PDV_RaceImplementationCostingBacklog.md` as the
bridge between the race gameplay audit and runtime implementation. Phase 20
race slices now need to cost state artifacts, hook sources, rejected hooks,
player surfacing, verifier/readback gates, runtime proof, and compatibility
notes before coding or CK authoring starts. Added
`references/authoring/PDV_Phase20AltmerImplementationCosting.manifest.json` and
`--strict-phase20-altmer` as the first manifest-level gate. Altmer gated content
slots are no longer blocked by an open implementation spec; the remaining
Altmer work is source/record implementation, runtime proof, and tuning.

### v3.53 - 2026-05-30 - Phase 20/21 order flip

Flipped the endgame order: Phase 20 is now the full roster/content lock and
Phase 21 is the Authoria-first compatibility package lane. Rationale:
compatibility testing cannot be meaningful until the full mod surface is ready
to test against a modlist. `--strict-phase20-roster` is the canonical roster
gate; `--strict-phase21-roster` remains accepted as a temporary alias.

### v3.52 - 2026-05-30 - Full roster architecture lock

Retired the old 1.0 target of 25-35 deities and 8-12 Daedric paths. The roster phase
now requires content-ready handling for every locked race-architecture worship
target and all sixteen Skyrim-present Daedric Prince surfaces, with Jyggalag
excluded unless future adopted content explicitly adds him.

Added `references/authoring/PDV_DeityCoverageMatrix.json` as the roster
authority and strict roster verifier coverage as the first machine check. This
entry was originally drafted as Phase 21 and was immediately renumbered by
v3.53 so roster completion precedes compatibility testing.

### v3.17 - 2026-05-19 - Slice 1 receiver hardening

Added the compile-clean Slice 1 receiver layer: `PDV_EventSignalActivator` for
ACTI proof records and `PDV_EventSignalEffect` for MGEF/consumable proof
records. The receiver scripts validate player/origin/day gates, route only
through existing EventBus functions, and never write downstream devotion state
directly.

`tools/pdv_compile.mjs` now treats the receiver scripts as active, and
`tools/pdv_verify.mjs --strict-pattern-proving` checks receiver source/pex
freshness, `references/authoring/PDV_Slice1SignalReceivers.manifest.json`, and
manual proof-record readback once the ACTI/MGEF records exist. The receiver
layer gate was clean at `FAIL=0, TODO=0, PASS=494, WARN=2, INFO=32` before the
manual records and runtime proof were completed in v3.18.

### v3.16 - 2026-05-19 - Implementation handoff hardening

Added Section 21.5 as the operating implementation handoff between the
architecture and build work. The new handoff defines implementation-ready
criteria, a reusable handoff-card template, Pattern Proving build order,
decision blockers, verifier command ladder, and documentation update rules.
The hardening pass now also defines the first implementation packet checklist,
source-contract/data-shape requirements, exit/recovery proof expectations, and
the bridge from the Daedric race-sheet/matrix hardening into the Daedric pilot. No
subsystem architecture changed; the pass clarifies how to execute the
already-approved v3 roadmap without cloning incomplete patterns or treating
compressed design prose as implementation data.
Follow-up hardening added the concrete Slice 0 and Slice 1 handoff packets.
Slice 0 records the 2026-05-19 combined strict verifier baseline
(`PASS=458, WARN=2, INFO=28`, no `FAIL` or `TODO`) and names the known warning
waivers. Slice 1 now has a build-ready normal-play ingress closeout packet for
Dunmer portable shrine/home bonus, Bosmer Green Pact violation, and Hircine
hunt rite micro-proofs.

### v3.15 - 2026-05-19 - Documentation authority cleanup

Promoted `PDV_TargetEndStates_1.0.md` as the living product/end-state tracker
and removed the separate tester-brief surface from the documentation
architecture. v3 remains the authority for architecture contracts, subsystem
gates, and beta/launch readiness; the target-end-state tracker owns per-race
1.0 acceptance and roadmap traceability. No implementation or phase-status
changes.

### v3.14 - 2026-05-19 - Prisma UI repo boundary

Locked the Prisma UI repo posture as bounded monorepo for now. Prisma source
stays under `native/DevotionPrismaBridge/`, the static HTML demo is a review
artifact rather than canonical source, and a separate repo should be
reconsidered only after clear split triggers such as an independent build
system, asset pipeline, UI tests, release cadence, non-PDV reuse, or recurring
context noise. No phase status changes.

### v3.13 - 2026-05-19 - Prisma UI smoke companion

Added the Prisma devotional surface as the current prototype path for
player-facing UI texture, including transient symbol-led overlay toasts sent
through `PDV_PrismaBridge.SendOverlayJson()`. The Pattern Proving gate now has a
repeatable Prisma smoke companion for panel open, active-patron toast, dawn
toast, and bridge-log checks. No phase status changes.

### v3.10 - 2026-05-18 - Gameplay refinement and tracker hardening

Pulled the Bosmer Pact ratification and the new gameplay/UX posture back into
the forward architecture. v3 now treats PDV as quiet, event-led,
lore-reactive, recoverable, and vanilla-plus by default; explicitly rejects
raw skill-XP scoring, raw craft-count scoring, routine notification spam, and
chore-loop religion; and updates Bosmer Old Contract to the locked
`PactBound` / `GreenPactCompliance` model with forced reckoning, one-time
re-entry, and terminal second renunciation.

Closed `D-19` through `D-23` to match the live manager scaffold defaults for
neglect and decay. Reframed `D-12` as an active roster-shape tension: the
current separate Daedric roster is scaffold truth today, while the longer-term
operational roster may still converge behind a shared fan-out seam.

### v3.9 - 2026-05-17 - Broad structural scaffold gate closed

Closed the broad Structural Skeleton gate. The framework ESP now owns the
dev-only scaffold records for substrates, sacred places, the Hircine pilot, and
curse state, plus their FormList indexes and `PDV_MCM` scaffold properties.
The verifier's strict skeleton contract now passes cleanly together with strict
preflight (`FAIL=0, WARN=0, TODO=0, PASS=401, INFO=30`), and in-game Debug-page
smokes confirmed both the structural map view and the scaffold API smoke path
without touching patron mirrors, dawn behavior, or EventBus routing.

### v3.8 - 2026-05-16 - Doc cleanup and scaffold-code contract

Cleaned the v3-facing vocabulary after the race-sheet sync: older bucket terms
are now explicitly design-axis shorthand, not implementation state. Corrected
stale section references, made the decay pseudocode Papyrus-valid, and added
compile-clean Structural Skeleton base scripts for the next architecture layer.

Reviewed the implementation plan after cleanup. Phase order stays intact:
Structural Skeleton remains next, Pattern Proving still carries the first real
content behavior, and the race sheets tighten acceptance criteria rather than
forcing a new roadmap.

### v3.7 - 2026-05-16 - Race-sheet architecture sync

Synced the new race sheets and locked Section 12 race decisions back into the
forward architecture. The public five-band race-sheet vocabulary is now mapped
onto the internal `PDV.Tier` 0-3 storage spine without adding extra tier state.
Reputation and state planning now names the first-release race tracks, including
the widened Imperial Concordat bands, Altmer `ThalmorAlignment`, Breton
`WitchcraftExposure`, `KnightlyVowIntegrity`, and `DruidicStanding`.

Clarified that strong persistent substrates are limited to Dunmer ancestor
practice, Khajiit lunar life, and Argonian Hist relation; Orc community location
uses `PDV_SacredPlace` as a contextual mode modifier, not a strong substrate.
Roadmap gates now call out the required pattern pilots: Imperial Concordat,
Bosmer Path, Dunmer Ancestor, and the Khajiit emergent patron/moon-cycle
exception.

### v3.6 - 2026-05-16 - V3 Preflight gate closed

Closed the V3 Preflight exit gate. Framework-owned `PDV_GLO_PatronState`,
`PDV_EventTypes`, and `PDV_EventBus` records are now present and wired in
`Devotion.esp`; `PDV_ActionRouter` points at the framework-owned
EventBus/EventTypes services; strict preflight verification is clean; and the
clean-start in-game smoke pass is complete (A-F gate checks passed, including
the direct-vs-non-hostile canary and Talos/Auri-El rivalry validation).

### v3.4 - 2026-05-16 - V3 Preflight script/tooling kickoff

Started Preflight implementation without broad content expansion. Added
compile-clean `PDV_EventTypes` and `PDV_EventBus`, kept the existing
direct-player hostile kill route as the canary, and made follower/environment
attribution payload-only. The manager now has explicit patron-state helpers,
named dawn pipeline slots, and gain-pipeline no-op extension points for
reputation, curse, Daedric stigma, and future modifiers. Bootstrap now
hard-fails visibly when PapyrusUtil is unavailable, unsupported custom-race
fallback is surfaced through first-load notice plus MCM/status diagnostics, and
the verifier/compiler know about the Preflight surface. Remaining work is
record/property wiring plus clean-start smoke.

### v3.3 - 2026-05-16 - V3 kickoff decisions

Resolved D-01 through D-08 and tightened the Preflight/Skeleton contracts.
Trinimac is an Altmer-native specialist worship target tied to martial virtue,
civilisational defence, and Thalmor Orthodox play. It should be scaffolded in
the Structural Skeleton, but should become content-ready only when that Altmer
lane is being built. For Orcs, Trinimac stays `TABOO` fringe pressure only, not
a normal Orc core path or fourth Orc lane. Malacath is dual-coded by race, and
Shor/Sep/Lorkhaj/Lorkhan remain separate cultural records.

Preflight now uses staged service APIs behind the manager facade, a central
EventBus/EventTypes owner with the existing kill route as canary, explicit
patron state instead of overloaded `PDV_GLO_PatronDeity` sentinels, named
dawn/gain pipeline slots, and minimal schema-version tracing without a save
migration registry. Indirect kill attribution is payload-only until a later
signal phase assigns devotional meaning. Crime events move to Phase 8 with the
first reputation track. Structural Skeleton visibility uses a canonical target
visibility enum plus FormList indexes, with verifier hard-fails for leaks.

### v3.2 - 2026-05-16 - Section 24 decision cleanup

Resolved the decisions already answered by the v3 roadmap and acceleration
tradeoffs, then removed them from the open tracker. The locked defaults are:
strong substrates only for Khajiit, Dunmer, and Argonian; shrine overlays rather
than vanilla activator replacement; Tier 2 broad-worship cap; three-option
commitment offers; curse states as multiplier/pressure overlays rather than
Daedric unlocks; thematic UI by default; post-1.0 in-world patron switching; concrete
script cloning over an abstract template; FormList-driven MCM ordering;
monolithic framework ESP through 1.0; Phase 12 stack-depth benchmarking; and
the then-current Wintersun coexistence note. Phase 20 later superseded the
religion-overhaul posture with replacement-first list-author packages.

### v3.1 - 2026-05-16 - Roadmap, beta, and launch gates

Added the high-level roadmap from V3 Preflight through Structural Skeleton,
Pattern Proving, Technical Beta, Content-Feel Beta, and content-rich 1.0
launch. This revision locks the split between structural completeness and
content completeness, keeps unfinished scaffolds dev-only, and keeps
architecture authority in this document.

### v3.0 - 2026-05-16 - Initial forward-architecture draft

Created as the planning target for everything past v2's Phase 6 hostile-path slice. Phases 4 and 6 are closed; only their architectural carry-forward items appear in Section 3.

The v3 doc carries the v2 invariants forward (Section 2), surfaces the open items inherited from Phases 4-6 (Section 3), lays out the subsystem map (Section 4) and forward phase plan (Section 21), and ends with a mobile-friendly Open Decisions Tracker (Section 24) sized for working through one item at a time.

Detail level: architectural + named records. Concrete EditorIDs, script shapes, property names, and StorageUtil key prefixes are specified where the contract is load-bearing. Implementation specifics (rubric tuning, exact threshold integers, content text) are deferred to the per-phase CK Steps documents that will accompany each phase as it's built.

Major design adds in v3 vs. v2:

- Reputation track and state track as reusable subsystem patterns (Sections 6-7), absorbing the locked Imperial Concordat Standing and Breton WitchcraftExposure mechanics from the race architecture reference.
- Race substrate quest pattern (Section 8) as the architectural home for the asymmetric hybrid boon policy.
- Privilege and contextual-favor subsystems as named layers (Sections 9-10) so they are tracked and verifier-covered rather than implicit.
- Daedric path architecture as a sibling of deity quests with a boon/price/stigma contract grammar (Section 11).
- Patron commitment mechanism that replaces the v1 bucket-threshold gating with piety-threshold gating composable with state-track eligibility (Section 12).
- Curse-state overlay (Section 13), neglect subsystem (Section 14), and decay model (Section 15) given concrete shape rather than left deferred.
- Mod compatibility as patch ESPs (Section 20).
- Risk register and explicit performance budget.

No phase status changes. v3 does not advance the build; it plans it.
