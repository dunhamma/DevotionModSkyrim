# PDV Target End States - 1.0 Product Tracker
**Created:** 2026-05-18
**Last updated:** 2026-06-07 (Phase 2 all-race static gate complete; all ten races have authored/deity/reward/manager/readback coverage, while runtime/manual beta packets remain pending)
**Status:** Living 1.0 product/end-state tracker
**Purpose:** Track what each race's devotion should feel like at launch, how
close each race is to implementation-ready acceptance, and where the 1.0
roadmap still has gaps. This document owns product feel and launch acceptance;
`PDV_Architecture_v3.md` owns architecture contracts and subsystem gates.

**Three questions per race:**
1. **Champion moment** - What does Tier 3 feel like that Tier 2 doesn't? What door opens?
2. **Signature friction** - What unique daily or behavioral constraint makes this race *feel different to play*?
3. **Neglect texture** - When devotion decays, does it feel like something specific and thematic, or just a stat going down?

> These are player-experience targets and acceptance checkpoints, not a second
> architecture spec. Treat them as the "north star" when making implementation
> tradeoffs, and defer to v3 when a subsystem contract is in question.

## Documentation Architecture Role

Improve Codebase Architecture review result: keep the documentation modules
deep rather than merging them into one oversized roadmap. `PDV_Architecture_v3.md`
owns the implementation architecture, phase gates, and open architectural
decisions. This document owns launch acceptance and race-roadmap traceability.
`references/PDV_RaceArchitecture_DesignReference.md` owns locked theology and
implementation rules. `race-sheets/*.md` owns player-facing race experience and
race-specific build notes.

## Daedric Coverage Role

The full Daedric end state is Prince-first and race-modified. The canonical
implementation-facing matrix is `references/phase4/PDV_DaedricRacePrinceMatrix.csv`;
the architecture baseline lives in `references/PDV_RaceArchitecture_DesignReference.md`
Section 11; the readable race sheets carry the race-by-race treatment maps.
This tracker records launch feel and race acceptance. Full race/deity and
race-Prince coverage is now a 1.0 acceptance requirement, but the implementation
authority for those pairings is `references/authoring/PDV_DeityCoverageMatrix.json`
rather than duplicated prose in this tracker.

Each race sheet should name all sixteen vanilla Skyrim-facing Prince surfaces
and state whether that Prince is native, legible, tolerated, foreign, taboo,
hostile, or curse-access for that race. This is deliberately broader than
"standalone Daedric quest." Fifteen Princes have normal Daedric quest/artifact
routes; Nocturnal is present through the Thieves Guild / Nightingale chain and
Skeleton Key, which does not count toward vanilla Oblivion Walker. Jyggalag is
out of 1.0 scope unless future Creation Club or Sheogorath/Jyggalag content is
explicitly adopted.

Native-integrated Princes use the race's own worship language. External
Daedric paths use the global Daedric path system and present as deviation, pact,
pressure, temptation, stigma, curse, or rupture rather than as ordinary race
devotion.

Implementation handoff must not rely on race-sheet prose alone. Before a
Daedric path is built for a race, the matching matrix cell must be expanded
into the Section 11 contract fields: surface type, response state, commitment
signal, temptation pressure, boon, price, stigma, faith friction, vanilla hook
priority, buildability tag, exit route, residue, and required player feedback.
The race sheet answers "what should this feel like"; the matrix and
architecture contract answer "what state and hooks make it buildable."
`PDV_Architecture_v3.md` Section 21.5 is the implementation handoff for turning
that contract into a build slice; use it before starting any Daedric pilot or
race subsystem implementation.

## Voiced Content Scope (V1 vs V2)

V1 (1.0) ships **no voiced NPC dialogue**, per `PDV_Architecture_v3.md`
Section 21.3. All spoken-dialogue recognition is deferred to V2 with its voice
files: the Phase 11 privilege/recognition dialogue lane, the Phase 18 Nord
recognition quartet, and the 39 `PDV_Dlog_*_Recognition` stubs. Throughout the
per-race sections below, where a "dialogue privilege," "recognition privilege,"
or "special dialogue option" payoff is described, read it as: **V1 delivers the
non-voiced equivalent** (MessageBox, notification, Survey readout, or
faction/disposition effect), and **the spoken-dialogue version is V2.**
Metaphorical "the Champion should feel like recognition" design language is
about player experience, not a voiced line, and is unaffected.

## 1.0 Full Roster Gate

The launch target is full roster readiness, not a selective content lock.
`references/authoring/PDV_DeityCoverageMatrix.json` is the current roster
authority for this gate.
`references/authoring/PDV_RaceGameplayBalanceAudit.md` is the companion
gameplay audit for benefit wealth, class/playstyle coverage, non-god immersion
lanes, writing/surfacing, hook reality, compatibility, and proof status. It
does not replace the roster authority; it checks whether the covered content
will feel equally rich in play. Its working ledgers are
`references/authoring/PDV_RaceRewardBudgetLedger.md` and
`references/authoring/PDV_RacePlaystyleCoverageLedger.md`; its reward ledger
now includes an explicit immersion budget matrix, and its build-costing handoff
is `references/authoring/PDV_RaceImplementationCostingBacklog.md`. The current
pre-beta gameplay-scaling handoff is
`references/authoring/PDV_PreBetaRaceScalingSpine.md`: Altmer is the active
spine, Khajiit is the first contrast, Argonian is the second contrast, Orc /
Redguard / Bosmer are P1 packets, and Breton / Dunmer / Imperial / Nord are P2
audit-only lanes until stack and ceiling evidence is recorded.
The first implementation-costing manifest set covers Altmer, Argonian, Orc,
Redguard, Bosmer non-hunter parity, and Khajiit. Each manifest must carry
`immersionProof` so reward parity includes diegetic trigger meaning, feedback,
rejected generic behavior, and normal-session feel. Run
`node .\tools\pdv_verify.mjs --strict-phase20-race-costing` after changing any
of those manifests or the race-costing scope.

Phase 2 static closeout (2026-06-07): the all-race reward/deity/neglect manager
surface, bounded Phase 2 roster, Green Pact static layer, and fallback-floor T3
capstone records now pass the automated static gate. This is not beta runtime
proof: the ten `PDV_BetaTestPacket_{Race}.md` walks, Active Effects display,
save/load sanity, stack snapshots, and manual feel notes still gate external
beta readiness.

Acceptance:

- All locked race-architecture gods and cultural worship targets are
  content-ready.
- All sixteen Skyrim-present Daedric Prince surfaces are content-ready for
  1.0: Azura, Boethiah, Mephala, Malacath, Meridia, Hircine, Molag Bal,
  Nocturnal, Hermaeus Mora, Mehrunes Dagon, Sheogorath, Namira, Sanguine,
  Clavicus Vile, Peryite, and Vaermina.
- Every race/god and race/Prince pairing has authored handling: response
  state, commitment gate, boon or favor surface, price/neglect/stigma,
  exit/residue, hook source, implementation status, verifier status, runtime
  proof status, and player-facing feedback.
- Race runtime slices with parity risk have implementation-costing manifests
  before source or CK work: state surfaces, accepted hooks, rejected hooks,
  immersion proof, player surfacing, verifier gate, and runtime proof route.
- Native, tolerated, foreign, taboo, hostile, and curse-access paths all have
  visible handling. Universal safe worship is not required.
- No Skyrim-present locked god or Prince may remain dev-only at 1.0.
- Jyggalag remains excluded unless future adopted content explicitly adds him.

## 1.0 Acceptance Tracker

Status values:
- `Locked`: ready to plan implementation; remaining changes are tuning or content.
- `Partial`: architecture is stable, but named implementation decisions remain.
- `Pending`: not yet built or proven.
- `Static`: machine/readback/verifier-covered; runtime/manual proof still pending.
- `Drafted`: full manifest prose is authored and verifier-clean, pending promotion into shipped ESP records (used in the Content authored column).
- `Ratified`: manifest prose authored, verifier-clean, gap-audited (no missing V1 surface), and checked against the locked content guardrails; pending final editorial read and CAT-6 promotion (used in the Content authored column).

| Race | Architecture locked | Implementation-spec locked | Hook feasibility checked | Content authored | Verifier-covered | In-game proven |
|---|---|---|---|---|---|---|
| Nord | Locked | Locked | Locked | Ratified | Static | Pending |
| Imperial | Locked | Locked | Locked | Ratified | Static | Partial |
| Breton | Locked | Locked | Locked | Ratified | Static | Pending |
| Dunmer | Locked | Locked | Locked | Ratified | Static | Pending |
| Altmer | Locked | Partial | Partial | Ratified | Static | Partial |
| Khajiit | Locked | Locked | Locked | Ratified | Static | Partial |
| Bosmer | Locked | Locked | Partial | Ratified | Static | Pending |
| Redguard | Locked | Locked | Locked | Ratified | Static | Pending |
| Orc | Locked | Locked | Partial | Ratified | Static | Pending |
| Argonian | Locked | Locked | Locked | Ratified | Static | Pending |

Content-authoring ratification audit (2026-05-31): a whole-roster gap audit
confirmed the V1 manifest prose is content-complete. `pdv_content_verify` is
clean (FAIL=0, WARN=0, 1,065 rows); all 10 races and all 16 Skyrim-present
Princes carry their full V1 surface set (blessings/boons, prices, tier-ups,
champion, commitment, stigma, neglect/exit, per-race responses, Survey/status,
state/band/posture/crisis transitions); no required V1 surface is missing; and
guardrail spot-checks passed (Altmer MarriageBeat = mortal continuity, no
moon-sugar/generic-theft framing for Khajiit, Survey copy fiction-facing with no
route/debug counters, Redguard Tu'whacca-primary). Remaining content work is
out of scope here: CAT-6 promotion into ESP records (code track) and V2 voiced
dialogue. Deferred-with-dependency prose stays recorded in the race manifest:
Bosmer Green Pact per-item feedback (tag layer, Section 17.7a), MCM player-tab
copy (Section 16.1/16.4), and localization (Section 23). Final editorial
read-through is the remaining ratification step.

All ten races are now implementation-spec locked at the design level. Altmer's
remaining closeout items (crisis resolution hooks, final crisis trigger list,
contextual favor lanes, and focused-deity hook posture) were locked on
2026-05-30 and drafted in the race content manifest. The first Altmer crisis,
Lorkhan, rejected-surface, and source-level favor scaffold now compiles, and
`PDV_State_AltmerCrisis` is record-wired. The first two Altmer favor spell
records are also wired for dawn steadiness and orthodox costly enforcement,
four Altmer ACTI trigger proof base records are wired for crisis, Lorkhan
pressure, dawn steadiness, and orthodox cost, and three Altmer curse/exile
message records are wired to manager source for vampire exile pressure,
werewolf hard halt, and cured-vampire scar recognition. The four Altmer proof
references are now placed in `QASmoke`, read back cleanly, and passed route
runtime proof; final immersive world placement and pre-beta gameplay scaling
remain open.
The first Argonian Hist/People proof slice is source/record-wired:
`PDV_Substrate_ArgonianHist`, `PDV_State_ArgonianHistPosture`, four ACTI proof
base records, manager/status surfacing, and route IDs `60-63` exist. The four
Argonian proof references are now placed in `QASmoke`, read back cleanly, and
passed route runtime proof. Final immersive world placement and pre-beta
gameplay scaling remain open. The first Orc
life-mode proof slice is
also source/record-wired: `PDV_StateTrack_OrcLifeMode`, `PDV_GLO_OrcLifeMode`,
four ACTI proof base records, manager/status surfacing, and route IDs `70-73`
exist. The first Redguard sect proof slice is also source/record-wired:
`PDV_StateTrack_RedguardSect`, `PDV_GLO_RedguardSect`, four ACTI proof base
records, manager/status surfacing, and route IDs `80-83` exist. The Orc and
Redguard proof references are now placed in `QASmoke`, read back cleanly, and
passed route runtime proof. Final immersive world placement and pre-beta
gameplay scaling remain open. The first
Khajiit Phase 20 proof slice is also
source/record-wired: the existing `PDV_Substrate_KhajiitLunar` and
`PDV_GLO_KhajiitFocusedEmphasis` are readback-covered, six ACTI proof base
records exist for moon observance, two road-home anchors, Baan Dar, Rajhin, and
Alkosh, manager/status surfacing exposes all five focus weights, and route IDs
`10`, `33`, and `90-92` exist. The Bosmer non-hunter parity packet is also
source/record-wired: eight proof ACTI base records exist for Old Contract,
Living Story, Exchange, and Bandit Road favor variants, manager/status surfacing
shows `favor=oc/ls/ex/br` counters, route IDs `100-107` exist, and Baan Dar
reversal carries a seven-day major-favor cooldown. The Khajiit and Bosmer proof
references are now placed in `QASmoke`, read back cleanly, and passed route
runtime proof. Final immersive world placement and pre-beta gameplay scaling
remain open for all six Phase 20 proof packets.
The counted runtime lane now has a consolidated runbook and log checker:
`references/authoring/PDV_Phase20_QASmokeRuntimeProof_Runbook.md` and
`node .\tools\pdv_phase20_runtime_check.mjs --race all`. The checker proves
route markers only; Survey/status immersion, negative hooks, anti-farm behavior,
pre-beta gameplay scaling, and final world placement remain separate acceptance
evidence. External beta should wait until those surfaces are built enough that
testers can judge a race experience rather than missing content.
The pre-beta scaling gate now requires every race packet to record normal-play
hooks, rejected generic hooks, Survey/status readout, final placement, reward
ceiling, reward floor, stack snapshot, runtime proof command, and manual feel
notes before stronger rewards or external tester judgment.
`references/authoring/PDV_PreBetaRaceGateLedger.md` records the current
race-by-race evidence and verdicts. `PDV_PreBetaRaceAcceptanceRubric.md` is the
measurable acceptance bar for that gate: each race closes as `Pass`,
`Conditional`, or `Fail` after expected/edge builds, rejected-hook coverage,
anti-farm cadence, Survey/status legibility, final placement,
reward floor/ceiling, and stack snapshot evidence are recorded.
`references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md` is the
manual handoff packet for proving those checks after automated source,
manifest, route-list, and placement-readback gates pass.
`references/authoring/PDV_Phase20_NoInGameProof_Workplan.md` now owns the
remaining Phase 20 planning and implementation queue that can proceed before
additional Skyrim runtime proof: gate-ledger hardening, normal-play hook
contracts, static verifier expansion, final placement contracts, stack audits,
Survey/status copy prep, the pilot-provisional CAT-6 target-record proof,
recognition packet prep, and Daedric blocker closeout.
`PDV_Phase20_NoInGameProof_Gates.json` is the
structured gate for that work and is checked by the strict Phase 20
race-costing verifier. It does not permit any race to move to `Pass` without
manual/runtime evidence. `PDV_Phase20_ManualEvidenceLedger.json` is the
matching pending intake ledger for recording that future evidence without
changing the current no-game verdict.
Reward magnitudes,
immersion proof, and exact effect values remain tuning work for every race until
implementation and playtesting prove the feel.

Daedric full-content readiness remains a separate 1.0 content gate. All sixteen
Skyrim-present Princes now have draft rows, but Section 11.6's remaining
"decide before promotion" work is stigma row ratification, curse-access
template handling for Hircine and Molag Bal, and the Prince promotion order.
Those decisions must be closed before broad runtime promotion of the Prince
drafts, but they do not block the current pre-beta race hook and Survey/status
scaling work. Final reward text, Prince prices, stigma, exits,
and final Survey/status copy remain blocked on those Daedric decisions.

The 2026-05-31 lore cross-review keeps the current workshop defaults. Altmer
`MarriageBeat` is a Marriage / Mortal Continuity crisis about household,
lineage, embodied attachment, and continuity inside Lorkhan's mortal world, not
anti-Mara marriage rejection. Talos/Thalmor remains a lore-valid later optional
Altmer crisis row, not part of the current four-row list. Khajiit, Argonian,
and Bosmer Survey/status directions remain source-backed with guardrails:
Khajiit centers Lunar Lattice, road-home, moon, caravan, and native focus
movement; Argonian keeps Hist primary with People/community, water, and Void as
supporting pressures; Bosmer reads through Y'ffre/Green Pact, Living Story,
Exchange/Z'en, and Bandit Road/Baan Dar without exposing raw counters. Runil is
now scoped to the planned V2 recognition/dialogue enhancement, not V1. CAT-6
stays on the Khajiit lunar blessing first, Bosmer Exchange fallback second.

Experience Mode is design-locked but not implemented. `Pilgrim's Path` remains
the default authored experience; `Wayfarer's Path` is the future lenient mode.
The 1.0 target includes this only after `PDV_ModePreset`, `PDV_GLO_Mode`, MCM
surfacing, manager scalars, ActionRouter cheap-repeatable handling, verifier
readback, and two-mode runtime smoke are complete.

Recognition/dialogue scaling and CAT-6 promotion now have separate architecture
packets. V1 does not add new NPC conversation lines, voiced responses, lip
files, scenes, or broad recognition topics. `PDV_RecognitionDialogueScalePacket.md`
is now a planned V2 enhancement packet that preserves the CK-safe proof shape;
Runil remains the first candidate for Altmer Auri-El crisis/recovery
recognition only when V2 dialogue scope opens. V1 recognition should use
Survey/status, MCM Player text, MessageBoxes, notifications, spell/effect
descriptions, books/notes, safe service or shrine gates, and Prisma toasts where
supported. `PDV_CAT6PromotionPilot.md` requires one low-risk non-dialogue
draft-to-ESP-to-handbook pilot before broad string promotion; the ratified first
pilot is `PDV_Bless_Khajiit_Lunar_T1`, with `PDV_Bless_Bosmer_Exchange_T1` as
fallback only if the Khajiit target
record path is blocked. Drafting can continue; mass promotion and mass
recognition should wait for those gates.

## 1.0 Compatibility Gate

Phase 21 release compatibility is list-author focused, not end-user Wabbajack
swap support. The hard 1.0 compatibility gate is an accepted Authoria / ARR
integration-test package. The other six Bordello target lists (JOJ, TOT, HOH,
MOM, DoD, and VOV) should reach `patch-packaged`: exact religion-removal set,
one list-specific compatibility patch, exact placement notes, patcher rerun
steps, maintainer brief, and focused smoke checklist.

Compatibility patches may tune mechanics, route signals, and classify records,
but they must not change PDV theology or race/deity target end states.

## Global Contextual Favor Rule

Contextual favors are automatic. They are never hotbar powers, lesser powers, or player-invoked religion abilities. An authored preferred signal for the active god, path, mode, or substrate may also trigger one temporary favor.

Each devotional lane should use 3-5 trigger families, drawn from the same authored tables that decide what generates piety. A lane may be a focused deity, path, mode, substrate layer, or broad-worship state. The player may have only one contextual favor boost active at a time, globally across PDV. Once it expires, another fitting preferred signal can trigger a new boost.

For the first live runtime pass, Phase 12 is locked to three lanes in one tranche:

- focused `Kyne`
- `Nord Broad Old Ways`
- `Nord Broad Nine Divines`

That pilot keeps two guardrails explicit:

- the one-active cap suppresses new activation while another favor is active
- Phase 12 does not replace or refresh an already-active favor in place

Broad-worship lanes exist only where culturally normal and experientially useful, not for every race with multiple worship targets. First-release broad lanes are Nord, Imperial, and Redguard; Dunmer uses a special layered equivalent. Breton and Altmer do not get generic broad lanes because tradition and coherence are their real organizing lanes.

Dunmer's special layered equivalent can trigger contextual favor before a primary Good Daedra focus. This should present as the shared ancestor + Reclamations layer answering back, not as generic broad pantheon worship. Shared Dunmer favors are usually quieter than primary Azura, Boethiah, or Mephala favors.

This global cap includes temporary substrate favors, but does not include baseline blessings, low-power persistent substrate boons, religious privileges, neglect state changes, or restoration state changes unless they grant a temporary contextual favor.

This keeps favors legible and balanced: the player feels the relationship answer back, but does not stack multiple divine bursts into a general combat package.

Favor eligibility is authored, not inferred from piety sign. Most favor triggers will be positive piety signals, but some costly or ambiguous events may trigger a favor when they are meaningfully faithful: defiance under Concordat pressure, re-commitment after rupture, cure-and-return rites, or choosing orthodoxy after dissonance. Pure penalties, failures, hostile-rival signals, and ordinary negative drift do not trigger favors unless an explicit restoration or recommitment signal is authored.

Use four shared duration buckets:

| Bucket | Use for | Target duration |
|---|---|---|
| Momentary combat favor | Mercy, near-death, impossible odds, honorable kill, protecting someone | 30-90 seconds |
| After-act favor | Death rites, oath kept, caravan aid, meaningful quest beat | 2-4 in-game hours |
| Environmental favor | Storm, water, road, tomb, shrine, dawn/dusk, outdoor sleep aftermath | While the context is true or until the place/time window ends |
| Rare major favor | HoonDing make-way, Ash'abah major tomb cleansing, Baan Dar reversal, major patron recognition | 24 in-game hours |

Player-facing language should describe these as "for this fight," "for this journey," "while I am in the sacred context," or "until the next day," not as precise timer mechanics.

Visibility follows duration and significance:

| Surfacing level | Default bucket | Player feedback |
|---|---|---|
| Quiet | Momentary combat favor | No notification by default; effect icon or felt gameplay change only |
| Noted | After-act favor, environmental favor | Short notification when the context is meaningful and rare enough |
| Marked | Rare major favor, costly-but-faithful restoration/recommitment moments | Named notification or message; reserved for moments the player should remember |

The shorter the favor, the quieter it should be. Costly-but-faithful events may be surfaced one level higher than their duration bucket when the point of the event is that the character paid a real theological cost.

Race sheets should use one shared contextual-favor table shape:

| Lane | Trigger family | Hook candidates | Favor bucket | Surfacing | Notes |
|---|---|---|---|---|---|
| Focused deity, path, mode, substrate layer, or broad-worship state | One of the 3-5 authored signal families for that lane | Buildable Skyrim hooks that could detect the moment | Momentary combat, after-act, environmental, or rare major | Quiet, Noted, or Marked | Anti-farm rule, theological caveat, build risk, or why the moment should feel marked |

This keeps race end states comparable without flattening their theology.

Rollout is pilot-first: populate and review Nord, Imperial, and Redguard before filling every race. Those three are the hard test because they all allow broad worship, but each means something different: mythic breadth, civic breadth, and sect-shaped breadth.

Pilot table rows may live in the race sheets as `Status: Pilot draft` until review clears them. Architecture should not absorb race-specific pilot rows until the pilot has proven the format.

The broader race-sheet pilot remains broad-lane first, but Phase 12's implementation pilot adds one focused contrast lane as the runtime depth proof: `Kyne` alongside the two Nord broad lanes. This is a runtime architecture concession, not a change in the long-form race-sheet review order.

The pilot clears only when each pilot broad-worship lane has 3-5 trigger families, each trigger family has a strong vanilla hook candidate or explicit custom/post-1.0 note, every row has a favor bucket and surfacing level, and each race has a short user-experience sentence proving it does not feel like the other two broad-worship lanes.

Pilot clearance result: Nord, Imperial, and Redguard cleared the cross-pilot review on 2026-05-18. The table shape can now be propagated to the remaining race sheets; race-specific pilot rows stay in the race sheets rather than moving into architecture.

Dunmer contextual-favor clearance result: Dunmer cleared user-experience review on 2026-05-18. The cleared shape is shared ancestor + Good Daedra favor before primary focus, then five focused trigger families each for Azura, Boethiah, and Mephala. Hook feasibility, substrate/focus implementation, curse posture, and Daedric deviation option mapping are now locked; remaining launch work is content weighting and implementation.

Implementation-lock audit result (2026-05-19; Altmer closeout 2026-05-30): all races are architecture-locked and implementation-spec locked. Breton is closed at the explicit tradition setup, all-three-track, normal no-switching, hook feasibility, dawn math, recovery cadence, Hidden Art cover/notoriety, and tradition-authored favor-lane level; reward magnitudes remain tuning work. Redguard is closed at the state/offer and launch-hook-posture level: death-duty is buildable, Tu'whacca uses the Dunmer portable/private shrine pattern rather than a pure Arkay proxy, HoonDing can ship through curated milestone hooks, `MS08` is stage-verified, and Ash'abah social stigma is limited to light authored/custom 1.0 content. Dunmer is closed at the ancestor substrate, focus-gate, curse-posture, portable-shrine, and Daedric-deviation option-map level. Khajiit is closed at the lunar substrate, silent focused-emphasis, road-home circuit, curse posture, ShadowDrift boundary, five launch paths, and launch-hook-posture level. Argonian is closed at the single layered Hist substrate, visible Hist/People/Void layers, gentle Hist distance, one bed-of-choice anchor, Sithis activation threshold, and curse posture level. Altmer is now closed at shared patron-state use, no generic broad lane, `ThalmorAlignment` bands/start values, bounded Lorkhan economy, crisis-state enum/resolution routes, final crisis source list, contextual-favor lane families, and focused-deity launch hook posture.

Phase 13-16 closure defaults (2026-05-26):

- **Phase 13:** Hircine-only first full Daedric completion, anchored on Nord.
  The full proof bar is boon, price, stigma, curse-entry pressure,
  cure/renounce exit, and lingering residue until recovery advances.
- **Phase 14:** formal patron commitment is a generic dawn-owned offer engine,
  with Kyne as the first proven path. Accepted patrons stay stable; Khajiit
  remain the standing no-formal-offer exception.
- **Phase 15:** `PDV_CurseState` is the shared curse seam for both werewolf and
  vampire live behavior. Werewolf detection is combined: active beast-race plus
  afflicted-state / faction / quest-style evidence.
- **Phase 16:** neglect is a generic dawn-owned subsystem. Broad worship
  suppresses per-deity neglect, the active set is capped at `3`, and Kyne is
  only the first authored spell packet, not the whole subsystem.
- **Phase 17:** decay is a generic dawn-owned subsystem. Active patrons are
  protected from passive drift, non-patron deities can still decay, broad
  worship uses reduced-rate drift, and tier floors preserve the locked
  Champion/Devoted promises.
- **Daedric recovery default:** cure or renounce starts recovery; rites or
  authored restoration beats accelerate or complete it.
- **Cross-Prince pressure default:** canonical Prince-vs-Prince hostility uses
  reduced rivalry math rather than full-strength cancellation and rather than
  stigma-only treatment.

Runtime closeout update (2026-05-28):

- **Phase 13:** runtime-proven on the Hircine/Nord pilot. The counted pass covered
  the negative gate before day-three commitment signals, Seeker and Devoted
  price activation on the real multi-day hunt-rite cadence, werewolf
  curse-entry pressure, cure-started residue, renounce reset plus residue, and
  the vampire negative path.
- **Phase 14:** runtime-proven on the Kyne pilot for seed/evaluate, `Not Yet`,
  `Refuse`, `Accept`, and accepted-patron persistence.
- **Phase 15:** runtime-proven on the shared `PDV_CurseState` seam for
  werewolf, vampire, and clear transitions.
- **Phase 16:** runtime-proven on the Kyne neglect pilot for low-piety active
  selection, neglect-spell application, and broad-worship suppression.
- **Phase 17:** runtime-proven with a standalone `--strict-phase17` gate. The
  counted pass covered grace no-op, eligible tick, same-day guard,
  broad-worship reduction, active-patron skip, non-patron drift, Devoted floor,
  Champion floor, and Phase 16 neglect regression.
- **Durable Phase 13 cadence lesson:** same-day `Hircine hunt rite` repeats are
  anti-repeat-scaled before stigma or piety is applied, so counted Seeker proof
  must use one rite on each of three in-game days rather than same-day spam.

Phase 18A/B runtime closeout (2026-05-30):

- **Player surface:** `Survey Devotion` and the MCM `Player` page are live in
  source/readback. Numeric Status/Debug surfaces are gated behind Developer
  Options.
- **Nord pilot scaffold:** broad Old Ways, broad Nine Divines, focused Kyne,
  Talos status, Hircine/werewolf feedback, and Nord vampire rupture/scar
  feedback have source/readback coverage and fresh-save runtime proof.
- **Dialogue boundary (V2 - voiced):** Froki, Heimskr, Andurs, and Aela
  recognition topics were CK-authored/live as branch/topic/unnamed INFO chains
  with positive/negative in-game dialogue proof, but as spoken NPC dialogue they
  are **deferred to V2** per `PDV_Architecture_v3.md` Section 21.3 (no voiced
  content in 1.0). Build action: disable/remove these records from the V1
  release ESP. The proven pattern is retained as the V2 specification; future
  V1 race clarity should prefer non-voiced status, message, notification,
  spell/effect, book/note, shrine, service-gate, or Prisma surfaces.
- **Runtime matrix:** Phase 18 requires Player page, Developer Options
  persistence, Survey Devotion for broad/focused Nord states, Hircine/werewolf
  tension, vampire suppression, vampire cure scar, and save/load persistence for
  the V1 Nord pilot. The per-speaker positive/negative **dialogue** proof moves
  to V2 with the dialogue records above; all non-dialogue rows remain closed for
  the V1 Nord pilot.

---

## Nord

**Setup shape:** Broad worship (Tier 2 cap) → a god notices your actual playstyle → offer fires → commit → Tier 3 unlocked. Old Ways or Nine Divines baseline.

**Implementation split:** Nord pantheon baseline is separate from commitment depth. `PDV_State_NordPantheonBaseline` stores `OldWays = 0` or `NineDivines = 1`; broad vs primary commitment uses the shared patron state and active patron globals. This lets Old Ways + Talos/Ysmir and Nine Divines + Talos remain distinct presentations without inventing separate commitment machinery.

**Primary-offer gate:** Nord primary offers are dawn-evaluated. A god must belong to the chosen pantheon baseline, meet the Faithful / Tier 2 offer threshold (`50` persistent piety by default), show qualifying signal activity on at least two separate in-game days within the last seven days, and not be blocked by cooldown. Major sacred events may count as one qualifying day, but do not bypass the sustained-pattern requirement or piety threshold alone.

**Offer-decline rule:** "Not yet" is a player-agency choice, not a piety failure. Declining sets only a per-deity cooldown: seven in-game days after the first decline, fourteen after repeated declines. Broad worship continues and other qualifying gods may still offer.

**Accepted patron rule:** For Nord and all other formal patron-offer races in 1.0, accepting a patron is stable. It sets active primary, clears pending offers, and prevents competing patron offers. Later neglect can weaken or lower the relationship, but it does not silently clear the accepted patron or replace them with another. Patron switching/reorientation is a future explicit rupture/restoration feature unless a race-specific exception is documented. Khajiit remain the no-formal-offer exception.

**Global offer-threshold default:** Formal patron/deity offers default to the Faithful / Tier 2 threshold: `50` persistent piety, plus whatever race-specific sustained-pattern or eligibility gates apply. Lower thresholds or bypasses require an explicit race/deity exception.

**Shared patron-state default:** Formal patron-offer races use the shared patron state for broad vs primary commitment. Do not add race-specific Broad/Primary state tracks unless there is a documented exception. Race-specific state tracks should represent different identity axes such as pantheon baseline, sect, tradition, life-mode, crisis, or substrate posture.

**Nord offer storage:** Nord does not persist a pending-offer queue. Offer candidates are recomputed each dawn from current piety, pantheon baseline, recent signal-day evidence, and per-deity cooldowns; at most one offer fires.

**Broad worship lane:** A player who prefers whole-pantheon Nord worship stays in a complete Faithful breadth lane rather than a failed patron lane. `Nord Broad Old Ways` and `Nord Broad Nine Divines` each count as a devotional lane for contextual favors. They get 3-5 blended trigger families, capped at Faithful, with softer and less specific favors than a focused Devoted patron.

Broad Nine Divines Nords mostly use the same hook surface as Broad Old Ways Nords, but with Divine names and moral framing. They should still feel like Nords living through holds, weather, household duty, death rites, honor, and Talos pressure, not like Imperials doing civic religion.

Talos pressure belongs in both broad Nord lanes. Old Ways Talos pressure reads as ancestral identity defiance; Nine Divines Talos pressure reads as carrying contradiction inside a public Divine frame. In both lanes, it should trigger favor only when the signal is costly and faithful, not merely anti-Thalmor violence or ordinary Civil War preference. Default surfacing is Noted; reserve Marked for high-cost events like hiding a worshipper, protecting a shrine, or defying Thalmor pressure face-to-face.

Example broad favor shapes: honorable fight outdoors (Shor + Kyne steadiness), defending home/hold/family (Mara + Stuhn protection), death-rite acts (Arkay + ancestor quiet), hidden Talos reverence with public restraint (muted defiant resolve), and varied worship across several domains (rare pantheon-harmony after-act favor).

**Phase 13 lock:** the first full Daedric Nord path is `Hircine`, not a generic
Nord Daedric menu. It is curse-accessed and should surface the Hunting Grounds
vs Sovngarde tension clearly.

**Phase 18 vampire rule:** Nord vampire state is rupture feedback, not a Molag
Bal devotional lane. While vampire, Nord formal commitment offers and contextual
favors are suppressed and Survey Devotion should say that Sovngarde is closed.
Cure restores access but leaves a visible scar/status note. Existing patron
piety is not cleared.

### Champion moment
The defining payoff for Nord is that the *right* god claimed you — the one that matches how you actually played. A player who hunted and camped and learned the Thu'um gets claimed by Kyne. A player who fought with the Stormcloaks and defied the ban gets claimed by Talos/Ysmir. The Champion moment should feel like recognition, not just a bigger number.

- **Kyne Champion:** Storms are no longer enemies. Wind-resistance, animals calm near you, and outdoor rest restores more. Kyne's favor is environmental — it changes the texture of being outside.
- **Talos/Ysmir Champion:** The old faith marks you. In Stormcloak-allied areas, NPCs react as if they know. Shouts feel spiritually grounded in a way they didn't at Tier 2. This Champion is about identity in defiance — the cost of holding it openly should be present.
- **Shor Champion:** Combat trials feel cosmically real. Honorable kills have a different weight. Sovngarde-adjacent content gives more resonance (this is a privilege/recognition layer, not a mechanical buff).
- **Kyne/Kynareth Champion (Nine Divines):** Same beat as Old Ways Kyne — the outdoors changes. A Nord playing Nine Divines who chose Kynareth should still feel like the storm-mother's child, just in the Imperial frame.

**The offer IS part of the payoff.** Broad worship giving way to a god's approach is itself a Champion-trajectory experience. The moment of commitment should be surfaced clearly and diegetically.

### Signature friction
There's no hard constraint for Nord — that's intentional. The friction is **time and consistency**: broad worship can take a long time before an offer fires. The player can also decline. This means the friction is about patience and identity — you don't choose which god finds you, you just live and see who shows up.

For players who committed, the friction is **staying consistent enough** that the relationship holds. A Kyne Champion who stops going outside, stops hunting, starts spending all their time in cities — that relationship will fray.

### Neglect texture
- Kyne's neglect feels like the weather turning indifferent. You used to have a sense the outdoors was on your side. Now it's just weather.
- Talos/Ysmir neglect feels like the old faith fading — the shouts feel more like technique than spirituality.
- General Nord neglect: the ancestors are quiet. No specific punishment, but an absence of the small graces that felt like Sovngarde was paying attention.

---

## Imperial

**Setup shape:** Broad Nine Divines worship (Tier 2 cap) → piety-threshold offer for chosen primary god → Tier 3 unlocked. ConcordatStanding track active from the start, affecting Talos specifically.

**Implementation state:** Imperial broad vs primary commitment uses shared patron state, not `PDV_State_ImperialWorship`. Imperial-specific pressure lives in `PDV_RepTrack_ConcordatStanding`.

**Offer gate:** Imperial uses the global formal-offer gate: dawn-only, `50` persistent piety by default, two qualifying signal days within seven, per-deity cooldowns, no persistent queue, and stable accepted patron in 1.0. `ConcordatStanding` filters and presents offers rather than replacing the shared offer machinery.

**Broad worship lane:** Imperial broad worship is civic and institutional. Its contextual favors should be led by civic acts, with institutional places acting as amplifiers, recognition surfaces, or cleaner hooks where Skyrim supports them.

| Broad trigger family | Favor presentation |
|---|---|
| Mercy / restraint under civic pressure | Brief Stendarr-coded protection or steadiness |
| Burial, Hall of the Dead, anti-necromancer duty | Arkay-coded rest, disease/undead protection, or institutional recognition |
| Lawful order, Legion duty, public service | Akatosh / civic-order stability favor |
| Honest trade, craft, tax / contract order | Zenithar-coded speech or commerce steadiness |
| Public/private Talos pressure | Talos favor only when the authored signal is faithful defiance, not generic rebellion |

Concordat compliance may move ConcordatStanding, alter access, or qualify Akatosh/civic-order favor when the act is genuinely order-preserving. It does not trigger Talos contextual favor. Talos favor comes only from authored faithful defiance, never generic rebellion or plain anti-Thalmor violence.

Talos offers normally require `Uncommitted`, `Private Defiant`, or `Open Defiant`. `Public Compliant` and `Concordat Enforcer` block Talos offers unless a fresh costly-defiance rupture signal is authored. Public compliance can amplify Akatosh / Zenithar civic-order offer eligibility, but never Talos. `Private Defiant` Talos offers should surface privately. `Uncommitted` leaves all Nine Divines offer eligibility neutral when real god-specific signals exist.

Accepting a Talos offer after a costly-defiance rupture immediately moves a compliant Imperial at least to `Private Defiant`; public or high-risk authored rupture may move to `Open Defiant`. Civic compliance amplifies Akatosh / Zenithar offer priority through recent signal strength, not by lowering the `50` threshold. `Concordat Enforcer` dampens Stendarr and Arkay offer eligibility unless recent mercy or death-rite repair signals exist.

Legion allegiance, court status, and official faction state may provide scoring context, but they do not trigger Imperial contextual favor by themselves. Lawful-order favor requires a concrete public-service or order-preserving act, and the act must not be cruelty disguised as order.

Bounty payment is not a generic mercy/restraint favor trigger. It counts only when authored as preventing harm or resolving a real civic conflict; ordinary pay-bounty menu interactions do not trigger favor.

Final trigger selection depends on usable game hooks: quest stages, shrine/Hall of the Dead interactions, dialogue choices, faction states, and curated story events before ambient inference.

### Champion moment
Imperial Champion is politically loaded in a way no other race's is. The *same Tier 3* means something completely different depending on where ConcordatStanding sits.

- **Champion Stendarr + Open Defiant Standing:** You've committed to mercy in a world that wanted you to persecute. Your god knows what that cost. Stendarr's favor in mercy-situations (restraining rather than killing, paying bounties to protect the innocent) feels distinctly earned.
- **Champion Akatosh + Concordat Compliant:** Civic order, long devotion streaks, persistent faith through upheaval. Akatosh's temporal boons reward consistency — sleep refreshes more fully, long journeys don't wear you down the same way.
- **Champion Arkay:** The death-rites are real to you. Properly dealt-with dead (burial quests, Hall of the Dead, defeating necromancers) feel like acts of faith rather than miscellaneous quests. Recognition privilege at death-related institutions.
- **The Talos commitment:** Champion status here requires having navigated the Concordat pressure and still committed. That's the entire arc — it should feel like the mod recognized you did the hard thing.

### Signature friction
The **ConcordatStanding track** is the signature friction — it's running constantly under your Nine Divines devotion, and it has real stakes. Every time a Talos worshipper needs help or every time the Thalmor approach you, there's a theological decision embedded in the gameplay choice. An Imperial player genuinely can't be indifferent to the Concordat.

The secondary friction: Imperial Divines worship is *civic*, which means it has a public/private dimension. Defiance while maintaining public compliance is a real character expression the mod should support mechanically (Private Defiant band).

### Neglect texture
- Let Arkay devotion lapse during a civil war playthrough and the mass graves around you feel like a failure. Not a debuff — a quiet presence of something wrong.
- Stendarr devotion lapsing while ConcordatStanding rises toward Enforcer should feel like a specific theological collapse, not generic neglect.
- General Divine devotion neglect for an Imperial means the civic scaffolding of their religion starts to feel hollow — shrines feel like architecture, not presence.

**Vampire note:** Complete collapse. No workaround. The re-entry arc (post-cure) is itself a meaningful late-game experience.

---

## Breton

**Setup shape:** Choose tradition first (Knight's Road / Hidden Art / Green Way) → tradition breadth within that lane → focused deity emphasis emerges → Tier 3 unlocked.

**Implementation-lock note (2026-05-19):** Breton does not use the generic broad-worship lane. The setup choice must be explicit, normal patron offers come only from the chosen tradition, and Hircine is fork-access rather than baseline Breton worship: Hidden Art can reach him through Daedric commitment, while Green Way reaches him only through the werewolf Druidic Trial.

**Implementation status:** Breton is implementation-locked for 1.0 experience shape. `WitchcraftExposure`, `KnightlyVowIntegrity`, and `DruidicStanding` all exist for every Breton; exposure is always active, while Integrity and DruidicStanding may remain dormant until their tradition or a major authored event makes them relevant. Normal tradition switching is unavailable in 1.0; only major authored forks can redirect the frame.

**Launch-hook posture:** Knight's Road and Hidden Art have strong 1.0 support through faction, quest-stage, shrine, Vigilant, Daedric, Dawnguard, Nightingale, Black Book, and curse-state hooks. Green Way is viable as location/rite-first through standing-stone activators, `LocTypeSprigganGrove`, Kynareth-adjacent shrine support, outdoor sleep cadence, and the werewolf Druidic Trial. Generic "help without reward," generic spellcasting, artifact ownership alone, and ordinary animal kills are not launch-safe hooks without curated filters.

**Vigilant pressure note:** Vanilla has real Vigilant hostility and world-interaction support in specific cases, but not a general "known Daedra worshipper" hunter reputation system. Breton 1.0 should use the existing faction/world surfaces where they naturally fire and treat exposure-driven hunters as authored PDV pressure, not assumed vanilla behavior.

**Extension candidate:** A light Vigilant pressure encounter is desirable later, especially because Skyrim contains disabled Daedric-artifact confrontation dialogue that already matches the fantasy. Prefer authored road/letter/contract pressure over real crime-gold bounty mechanics; this should not block Breton 1.0 unless the encounter pattern proves cheap.

**Track math posture:** WitchcraftExposure bands and modifiers are locked for 1.0, with the Notorious x1.25 applying only to Daedric / Hidden Art commitment. KnightlyVowIntegrity applies to the whole Knight's Road, with Stendarr and Akatosh reading the vow most sharply. DruidicStanding starts at 50, as an open but unproven covenant. Witchcraft-to-Knight drag is major-act based, not triggered by ordinary magic, College membership, private curiosity, or shrine visits.

**Recovery cadence posture:** WitchcraftExposure visible decay can return to Hidden, but major-act history remains. Divine cover requires 3 quiet days and fires at most once per 7 days. Stendarr shrine restoration can lift Integrity toward 75, but above 75 requires lived mercy, justice, protection, or reparation. Green Way decay is gentle: 5 days without signal -> -2, with a non-curse floor of 30. Vampire restoration is Excommunicated -> Penitent -> outdoor rite plus sustained behavior, with permanent scar.

**Contextual favor posture:** Breton favors are authored per tradition lane for launch, not per deity table. Knight's Road, Hidden Art, and Green Way each get `3-5` trigger families, with focused deity flavor layered onto the tradition. Hidden Art explicitly supports two intentional end states: careful occult cover and open Notorious rupture. Notorious is stronger and louder, but socially costly rather than a pure upgrade.

### Champion moment
Strongly path-dependent — the three traditions have almost no overlap at Champion:

- **Knight's Road Champion (Stendarr/Akatosh):** Your KnightlyVowIntegrity is intact AND you've maintained Tier 3. This is one of the hardest Champions to reach because the game actively offers you Thieves Guild, Dark Brotherhood, and expediency at every turn. The payoff should be proportional — protection of something that matters when you're defending others, not just a passive stat.
- **Hidden Art Champion:** You've become Notorious or near it on the WitchcraftExposure track AND maintained Daedric patron devotion. At this point your social situation is in genuine rupture, but the Daedric patron's favor is at its strongest (the 1.25x modifier kicks in at Notorious). This is the "you went all the way" moment. The payoff should feel like having a Daedric patron who actually shows up — contextual favors that feel dangerous and real.
- **Green Way Champion:** Y'ffre's oldest claim on the Bosmer has a Breton analog here. The forest acknowledges you in Skyrim's limited way — hunting feels guided, outdoor sleep feels protected, the druidic standing makes standing stones feel more responsive (flavor/recognition layer).

### Signature friction
- **KnightlyVowIntegrity** for Knights: the game will break it if you're not paying attention. Every join-the-Guild moment, every shortcut, every unjust kill. Maintaining it while playing a full Skyrim run is the friction.
- **WitchcraftExposure** for Hidden Art: you can hide for a while, but Daedric quests raise it. At some point you have to decide whether you're going all the way or maintaining cover. Both choices are valid but require intention.
- **Druidic Standing + Werewolf fork** for Green Way: the moment after first transformation fires a one-time theological choice. That IS the signature friction for Green Way Bretons — the question of whether the beast serves the Green or takes over.

### Neglect texture
- Knight neglect is about Integrity, not piety. If Integrity collapses through unjust choices, the god's daily shift halves. It *feels* like your patron is disappointed rather than distant.
- Hidden Art neglect is tricky — if you go Notorious and then stop doing Daedric acts, the patron's reward (1.25x) vanishes and social rupture remains. You've paid the cost without getting the benefit.
- Green Way neglect feels like the forest stopped noticing you — Druidic Standing simply no longer modulates things that were quietly helpful before.

---

## Dunmer

**Setup shape:** No choice required. Layer 1 (ancestors) is always active. Layer 2 (Good Daedra acknowledgment) deepens naturally. Layer 3 (primary Good Daedra focus) unlocked by piety threshold.

**Implementation state:** Dunmer does not use `PDV_State_DunmerPath`. Shared patron state owns primary focus; `PDV_Substrate_DunmerAncestor` owns the always-active ancestor substrate. `PDV_State_DunmerAncestorPosture` uses `Normal = 0`, `Strained = 1`, `Silent = 2`, and `RestoredScarred = 3`.

**Focus options:** Native Dunmer focus is Azura, Boethiah, and Mephala. Other Daedric Princes may qualify only through the global Daedric path system, and present as deviation, trial, pact, taboo, curse pressure, or foreign bargain. Aedric patron commitment is not a Dunmer 1.0 path. The option map should preserve class appeal: Azura covers mage/restoration/threshold play, Boethiah covers warrior/spellsword/revolution play, Mephala covers stealth/social/network play, and non-Reclamation Daedric paths broaden appeal without becoming normal Dunmer religion.

### Champion moment
Dunmer Champion is quieter and more cumulative than any other race — because the layered architecture means Tier 3 isn't a sudden opening, it's the final deepening of something that was always there.

- **Azura Champion:** Painful truth and transformation carry specific weight. Dawn, dusk, Azura's Star, cure arcs, exile beats, and major choice-points give brief prophetic flavor when the character becomes something truer, not merely stronger. Azura's relationship with Dunmer vampires gives this one an additional texture: Azura Champion who becomes vampire enters a genuinely complicated theological space rather than simple collapse.
- **Boethiah Champion:** Trial, overthrow, and self-authorship have residual force. Defeating significant enemies, surviving betrayal, removing false authority, and rejecting imposed Auri-El / Altmer order generate recognition at the ancestor layer — the ancestors witnessed who you chose to become.
- **Mephala Champion:** Hidden communities, information networks, obligation webs, and necessary lies feel acknowledged. The mod cannot track every secret in any real way, but joining the Thieves Guild, protecting hidden Dunmer communities, maintaining discretion in sensitive quests, and acting through trusted networks signal correctly.

Azura has a hard threshold boundary: dawn, dusk, night, and magic-adjacent play do not trigger focused favor by themselves after the basic shared-layer rhythm. Her moments require a real threshold, painful truth, transformation, exile-continuity, artifact/shrine rite, or curated major transition.

Boethiah has a hard cruelty boundary: random betrayal, generic violence, casual cruelty, and ordinary faction hostility do not trigger favor. Her moments require trial, overthrow, false authority, betrayal-as-test, Chimeric self-authorship, or curated quest/artifact context.

Mephala has a hard crime boundary: random murder, casual theft, convenient lying, and generic crime do not trigger favor. Her moments require hidden obligation, protected community, dangerous knowledge, targeted hidden violence, a maintained network, or curated artifact/quest context.

**The ancestor layer is always the Champion's ground floor.** Even at Champion, the Dunmer's relationship with their ancestors (Layer 1) remains the foundational texture — Layer 3 sits on top of it, not instead of it.

### Signature friction
The **infrastructure ceiling** — you simply cannot do proper burial rites, cannot visit ancestral tombs in the way your religion requires, cannot maintain a full household shrine. These absences are baked into playing a Dunmer in Skyrim. The friction isn't what the mod does to you, it's what the world already took away. The mod acknowledges this rather than pretending it's fine.

The **ancestors are always watching** is the subtler ongoing friction. Combat acts, social choices, the things you do to other Dunmer — the ancestor layer interprets all of it. Playing a Dunmer who exploits their own people costs more than it looks like on the surface.

### Neglect texture
The ash-prayer going quiet. There's no dramatic punishment — the ancestor layer simply stops generating the small flavor confirmations that told you they were present.

Dunmer neglect is about **silence**, not punishment. Ancestors don't curse you for drifting. They just stop responding. After weeks of nothing, the ancestral layer has a hollow quality that's hard to describe mechanically but is its own kind of loss.

Vampire note: the ash-prayer going SILENT (ancestors don't speak to undead) is one of the most atmospheric moments in the whole mod. The cure-and-restore arc matters — but the scar (permanent piety reduction) means you carry what happened.

---

## Altmer

**Setup shape:** Choose faction alignment (Thalmor Orthodox / Divine Body / Psijic) → ThalmørAlignment starts accordingly → Layer 1 (Auri-El) always active → primary secondary deity through piety threshold → Tier 3.

**Implementation-lock note (2026-05-19; closeout 2026-05-30):** Altmer uses shared patron state for formal commitment. `ThalmorAlignment` is the orthodoxy/coherence track, not a Broad/Primary state. There is no generic broad-worship lane: the player experience is Auri-El foundation, faction-theological coherence, and secondary focus. Bands remain `0-30 Heterodox`, `31-69 Orthodox Moderate`, `70-100 Thalmor Devout`; setup starts remain `75`, `50`, and `25`. The final implementation-spec closeout locks `PDV_State_AltmerCrisis`, the crisis source list, resolution routes, contextual-favor lane families, focused-deity launch hooks, and rejected-surface tests in `race-sheets/PDV_RaceDesign_Altmer.md`.

**Lorkhan pressure posture:** Lorkhan penalties are piety pressure plus narrative reaction, not harsh permanent collapse. Tier 1 can hurt, Tier 2 should sting, and Tier 3 should mostly create dissonance and small pressure. Major main-story conflicts that are the biggest clashes with Altmer theology should fire a crisis-of-faith moment with stronger flavor and only a minimal temporary sting to reflect emotional dysregulation.

**Altmer economy posture:** Basic devotional upkeep should trend positive: dawn Auri-El observance, study, magic milestones, College/Psijic milestones, and faction-coherent acts are the positive counterweight. Lorkhan pressure uses implementation tags `PDV_ALT_LORKHAN_T1_DIRECT`, `PDV_ALT_LORKHAN_T2_SHOR_ADJ`, `PDV_ALT_LORKHAN_T3_MORTAL_VALIDATION`, `PDV_ALT_LORKHAN_T4_CONTEXT`, and `PDV_ALT_CRISIS_FAITH`. Tier 3 penalties are explicit-action only, capped once per in-game day, and never fire for walking through Nord towns, having Nord friends, sleeping indoors, ordinary quests, or simply continuing to exist as Dragonborn after the authored crisis/declaration beat. If the theological meaning would not be obvious, reject the penalty or surface a first-time Altmer interpretation notification.

### Champion moment
The most demanding and most interesting Champion to reach. Getting to Tier 3 as an Altmer means you've maintained devotion while authored Lorkhan pressure kept testing your coherence — the Dragonborn declaration can cost you, visiting Mara's temple can cost you, the *Companions questline* can cost you. Reaching Champion means you managed those explicit collisions and still kept faith.

- **Thalmor Orthodox Champion (Trinimac/Auri-El):** Theological coherence rewarded. Your enforcement acts and martial excellence feel divinely grounded. The Thalmor respond to you as someone who embodies the faith rather than just following orders. Lorkhan penalties hit you hardest (1.5x) AND you still got here — that's the statement.
- **Divine Body Champion (Magnus/Xarxes):** Scholarship and self-cultivation at its apex. Your magical investment feels like the right path toward the spirits you were before Mundus. College of Winterhold content feels spiritually productive rather than just academically interesting.
- **Psijic Champion:** The rarest path and the most internally coherent — meditation, the Elder Way, heterodox independence. Lorkhan penalties are softer (0.75x), which means reaching Champion here is more achievable but the penalties still exist. The payoff is a quieter, more self-possessed faith.

### Signature friction
The **Lorkhan Adjacency Penalty** is the signature mechanic of the whole Altmer experience, and it's the most aggressive friction in the mod. It's not about what you did wrong — it's about what certain explicit mortal-world commitments mean from the Altmer perspective. Being declared Dragonborn can fire a Tier 2 beat once. Visiting the Hall of Valor fires when the authored story/location hook proves it. Getting married fires because it is a deliberate mortal-continuity choice.

The question the friction asks is: *how much of Skyrim's content are you willing to engage with on Altmer terms?* Some Altmer players will find themselves turning down questlines for theological reasons — which is exactly the right kind of friction.

### Neglect texture
ThalmørAlignment drift in the wrong direction for your faction is the primary neglect signal. An Orthodox Altmer who consorts with Daedra or helps Talos worshippers isn't just losing piety — they're becoming theologically incoherent. The neglect texture is **inconsistency**, not absence.

Werewolf note: complete halt — no path forward, not even the heretical Tier 1 that vampire gets. The beast is the precise inversion of the Apotheosis project. This is now source/record-wired through the Altmer curse-message slice, but still needs runtime proof.

---

## Khajiit

**Setup shape:** All Khajiit begin inside the Lunar Lattice automatically (no choice). Broad lunar worship (Tier 2 cap). Focused deity emphasis emerges *silently* through behavior — no formal offer system. Tier 3 through focused commitment.

**Implementation state:** `PDV_Substrate_KhajiitLunar` owns the lunar substrate with canonical prefix `PDV.Substrate.KhajiitLunar.*`. Existing first keys are `Metric`, `Tier`, `LastEvent`, `LastPhase`, `ObservanceCount`, and `RoadHomeCount`. 1.0 uses the hybrid moon model: current phase gives small per-phase bonuses, while full-cycle consistency determines substrate strength. Prefer real Masser/Secunda state where reliable; otherwise use an abstract 28-day fallback. Khajiit do not use formal offer state for focus; `PDV_GLO_KhajiitFocusedEmphasis` mirrors the leading deity emphasis for CK/readback proof. Enum values are `None = 0`, `Khenarthi = 1`, `Azurah = 2`, `BaanDar = 3`, `Rajhin = 4`, `Alkosh = 5`. Focus requires `50` piety and a `15` piety lead over the next-highest focused deity; otherwise broad lunar worship remains valid. Road homes are `2-3` player-designated rest anchors, and piety requires cycling between them rather than repeating one convenient rest point. The first Phase 20 proof packet now wires ACTI bases for moon observance, two road-home anchors, Baan Dar road trickery, Rajhin elegant theft, and Alkosh dragon/order response; the manager rejects immediate same-anchor road-home repeats and exposes all five focus weights in summary readback. Curse/shadow pressure uses `PDV_State_KhajiitLunarPosture`: `Normal = 0`, `Strained = 1`, `Corrupted = 2`, `ShadowDrift = 3`. Vampirism sets `Corrupted`, lycanthropy sets `Strained`, and `ShadowDrift` requires dominant Nocturnal/shadow behavior rather than ordinary night travel. The six proof references are placed in `QASmoke` and pass readback plus route runtime proof. **(2026-06-07) The Khajiit piety pilot is now complete and runtime-proven.** The five emphasis deities (`PDV_Deity_Azura`/`Khenarthi`/`Rajhin`/`Alkosh` + shared `PDV_Deity_BaanDar`) are scripted, Start-Game-Enabled, and in `PDV_FLST_AllDeities` (now 10 members); Khajiit acts now **double-route** to pulse the matching emphasis deity's piety alongside the substrate/focus signal, so identity and devotion advance together; per-emphasis **T1/T2/T3 reward spells** grant at Seeker/Devoted/Champion; lunar **neglect** and **creed-violation piety loss** are wired; a tier-up notice fires for the focused emphasis; and **shared-deity reconciliation** (`PDV_DeityBase.EligibleStateTrackOriginRace`) gives the Khajiit Baan Dar emphasis full parity without disturbing Bosmer Bandit Road. In-game smoke confirmed all of the above. See `references/authoring/PDV_SessionHandoff_KhajiitPilot.md`. Remaining: optional R2/R5 smoke confirmations and cross-race propagation (Phase 2).

### Champion moment

Khajiit Champion is cosmic in texture. The moon and road-life are always present, but at Champion, they feel *responsive*.

- **Khenarthi Champion:** Open-road life has a current. Travel feels right in a way it didn't — minor weather cooperation, outdoor sleep more restorative, the sense that the wind is going your way. Subtle but pervasive.
- **Azurah Champion:** Threshold moments have weight. Major quest completions, dungeon entries, significant choices — these briefly feel foreordained rather than accidental. Flavor text at twilight-coded events.
- **Baan Dar Champion:** The reversal you weren't supposed to survive becomes story. At Champion, trickster-survival acts (narrow escapes, outsmarting superior opponents, surviving the cities that don't want you) carry a blessed quality — Baan Dar rewards the clever exile.
- **Rajhin Champion:** Elegant theft becomes mythic theater. Story-worthy stolen items, notable undetected theft, and artful deception feel like performance rather than grind; petty theft stays too small to matter.
- **Alkosh Champion:** Fighting dragons feels cosmically correct. Anti-chaos, order-keeping, exceptional threat responses — these are what Alkosh notices. Rarest to reach, most specific in its payoff.

**The silent emergent patron system is itself part of the experience.** Khajiit don't formally commit — their worship deepens through lived behavior. The Champion tier should feel like the moon noticed you, not like you applied for recognition.

### Signature friction
**Moon-phase awareness** and **exile-life maintenance**. Khajiit are excluded from most cities' temples, locked out of the institutional worship infrastructure everyone else has. The friction is playing a character whose religion exists in the open road, the caravan camp, the night sky — and Skyrim's cities are hostile to all of that.

The caravan community weighting means Khajiit players who stay city-bound and never interact with Ma'dran or Ri'saad's caravans are genuinely missing their primary community-signal surface. That's intentional friction built into the worldspace.

### Neglect texture
The lunar substrate weakens when you've been **indoors, urban, and disconnected from the road**. Not punished — just quieter. The community belonging that buffered everything starts to thin. The sense of being cosmologically held by the Lattice fades into something more like being lost in a foreign country.

Caravan helpers don't notice you the same way. Night travel feels more dangerous, less guided. The moons are still there — you just stopped listening.

---

## Bosmer

**Setup shape:** Post-startup explicit Bosmer path choice (Old Contract / Living Story / Exchange / Bandit Road). The first Bosmer popup auto-commits the matching foreground patron after startup/origin resolution rather than using an MCM-at-character-creation flow. Each path is a meaningfully different experience. Path switching has real cost.

**Implementation state:** `PDV_State_BosmerPath` uses `OldContract = 0`, `LivingStory = 1`, `Exchange = 2`, `BanditRoad = 3`. First-run setup requires a choice; unset/corrupt fallback is `LivingStory`. `OldContract` path state is separate from `PactBound`, `GreenPactCompliance`, and `LapsedFromPact`; path orientation and active Y'ffre exclusivity are not the same variable. `LivingStory` and `OldContract` intentionally share one `Y'ffre` deity ledger; path state changes exclusivity and Pact behavior rather than swapping to a second Y'ffre record. Non-Old-Contract incoherence drifts toward `LivingStory`, and path switching is explicit/destination-gated rather than automatic drift. As of 2026-05-24, Phase 9 is runtime-proven: the framework ESP contains the Bosmer path deity trio (`PDV_Deity_Yffre`, `PDV_Deity_Zen`, `PDV_Deity_BaanDar`), setup/suggestion/reckoning messages, manager properties, deity FormList membership, ACTI proof-surface base records, and verified placed proof references. Runtime proof passed for all five proof-surface routes, Living Story/Exchange/Bandit Road/Old Contract offers, confirmation-rite switching, Old Contract re-entry, PactBound/compliance separation, forced reckoning `Renounce`, forced reckoning `Recommit`, and save/load persistence after Old Contract re-entry. The Phase 20 non-hunter parity packet now adds route IDs `100-107` and eight ACTI proof base records for Old Contract proper hunt/forest kept, Living Story community/nature-site proof, Exchange debt/redress, and Bandit Road road-life/reversal proof. Survey/status readback exposes `favor=oc/ls/ex/br` counters, and Bandit Road reversal has a seven-day major-favor cooldown. The eight proof references are placed in `QASmoke` and pass readback plus route runtime proof; pre-beta gameplay scaling remains open.

**Shared Pact memory:** Green Pact respect has modest positive weight across all Bosmer paths because it is core Bosmer inheritance. Proper hunting, animal-sourced food, restraint around needless plant use, and respect for the living world can help Living Story, Exchange, and Bandit Road. Only Old Contract carries penalties, `GreenPactCompliance`, forced reckoning, and Y'ffre exclusivity. This should be implemented as shared Bosmer signal weighting interpreted by the active path, not as a hidden background Old Contract ledger.

**Path switching:** First-run path choice is free. Later path switches are Bosmer-specific system-suggested offers, not the generic deity-offer queue and not a simple MCM toggle. The game surfaces a popup when the destination path has enough evidence, the player accepts or refuses, and a curated rite confirms the new path. Living Story needs one strong community/story signal and acts as fallback. Exchange and Bandit Road need two destination-coded signals on separate in-game days within seven, unless a major curated quest beat clearly proves the path. Old Contract re-entry requires explicit recommitment, no terminal second renunciation, and three Pact-positive days within seven; `GreenPactCompliance` snaps to 30 on re-entry. Old ledgers are preserved, but only the active path gets full scoring/favor/Champion eligibility. After switching, automatic switching is locked for seven in-game days unless an authored major exception fires.

### Champion moment
Four completely different Champions — more path-divergent at the top than any other race:

- **Old Contract Champion (Y'ffre Orthodox):** The Green Pact is your religion, and you've maintained it. At Champion, animals never flee from you unprovoked, hunting feels guided (contextual favor in hunting contexts), and GreenPactCompliance at Strict (80+) gives Y'ffre's 1.2x modifier. The payoff for carrying the hardest devotional burden is the highest ceiling of any Bosmer path.
- **Living Story Champion (Y'ffre Moderate):** You carry the oral tradition. Special dialogue privilege options in relevant contexts — you can name things, situate people, tell the story correctly. Community belonging feels real rather than performed. The secondary Bosmer gods (Arkay, Xarxes, Mara, Stendarr) add texture rather than competing.
- **Exchange Champion (Z'en):** Balance restored. Proportionate vengeance completed, debt settled — these acts have a clean satisfaction that ordinary questline completions don't. The favor that follows a debt-settling act has a quality of *rightness* to it.
- **Bandit Road Champion (Baan Dar):** The improbable reversal. Once per in-game week (rough target), Baan Dar luck fires in a situation where you were at a severe disadvantage. It shouldn't feel like a power — it should feel like the god of pariahs interceding on behalf of another pariah.

### Signature friction
**Old Contract Green Pact compliance** is the most mechanically demanding friction in the mod. Every food choice matters. Potions made from plants — gone. Firewood — gone. The mod has to tag plant-based consumables and the player has to track what they're putting in their body. For a game where alchemy and plant consumption are everywhere, this is real friction.

The other paths have friction through **path identity** — you made a choice, and the game holds you to it. The Exchange player who starts playing like a trickster feels the misalignment. The Bandit Road player who starts accumulating civic standing feels the tension.

**Forced reckoning moment for Old Contract:** three consecutive days in Apostate band → Y'ffre confronts you with a recommit-or-renounce choice. This is not background noise — it's a designed story beat that turns neglect into an explicit scene.

### Neglect texture
- Old Contract: the Apostate band's forced reckoning IS the neglect texture. After the second renunciation, Y'ffre's ledger freezes permanently. The neglect system has a terminal state — which is itself the most powerful statement about what devotion means.
- Living Story: the oral tradition dries up. The flavor text that placed you in context stops appearing. You're still a Bosmer, but you're not carrying the story forward.
- Exchange: unpaid debts accumulate without acknowledgment. The justice of the world ignores you.
- Bandit Road: Baan Dar's luck goes dormant. You survive by skill, not by the pariah's luck — which is actually a meaningful absence once you've felt it.

---

## Redguard

**Setup shape:** Choose sect (Crown / Forebear / Ash'abah) at setup. All three within the same Yokudan religious universe. Ancestor reverence always active. Broad worship to Tier 2 → focused primary deity → Tier 3.

**Broad worship lane:** Redguard breadth is sect-shaped. Crown, Forebear, and Ash'abah each count as their own broad-worship devotional lane for contextual favors; they share a Yokudan spine but should not collapse into one generic Yokudan package.

**Implementation state:** `PDV_StateTrack_RedguardSect` and `PDV_GLO_RedguardSect` use `Crown = 0`, `Forebear = 1`, `AshAbah = 2`. First-run setup requires a sect choice; unset/corrupt fallback is `Forebear`. Ancestor reverence is a light origin-gated modifier/recognition layer, not a selectable path or full second blessing family. Formal focused-deity offers use the global offer gate and shared patron state. The first Redguard source/record slice is live: manager route handling, status/survey surfacing, curse-cycle pressure markers, and four route `80-83` ACTI proof bases exist for Crown tomb respect, Forebear road passage, Ash'abah death duty, and Far Shores token use. The four proof references are placed in `QASmoke` and pass readback plus route runtime proof; pre-beta gameplay scaling remains open.

**Hook feasibility:** Redguard launch hooks are strongest around death duty: undead kill classification, draugr crypt / clearable location keywords, dungeon-cleared state, Hall of the Dead / Arkay quest stages, a PDV-authored Tu'whacca devotional surface, and curated necromancy/burial/tomb outcomes. Forebear contracts and travel are buildable when curated and capped. Crown honorable combat and HoonDing make-way are feasible with conservative filters; HoonDing 1.0 should use curated milestones, dragons, named bosses, and final boss clears before any combat-odds automation. Ash'abah social stigma and Redguard dignity dialogue are weak in vanilla and should ship only as light authored/custom 1.0 content unless a concrete broader hook is proven.

**Tu'whacca surface:** Tu'whacca should feel older and more personal than Arkay. 1.0 copies the Dunmer portable/private shrine pattern: a permanent portable devotional item usable anywhere, with a bonus when used in player-owned property or an authored private shrine context. The Redguard object is a portable Far Shores token, with optional sword-tending rite texture. Arkay shrines remain fallback death infrastructure: useful in Halls of the Dead or Forebear bridge practice, but not the primary god being worshipped.

**MS08 hook:** `In My Time Of Need` is verified as `MS08` / QUST `Skyrim.esm:01CF25`. Stage `200` completes the Saadia-helped route; stage `201` completes the Kematu/Alik'r-delivery route. One-time sect meaning is locked: stage `201` is Crown / Hammerfell justice / ancestor-duty positive; stage `200` is Forebear / exile-protection / anti-Alik'r positive.

### Champion moment
Ancestor reverence carries all three Redguard Champions — it's the ground they share:

- **Crown Champion (Satakal/Tu'whacca/Ruptga/Leki):** Martial bearing and sacred inheritance at their apex. Visiting tombs at Champion level gives Tu'whacca's recognition — the ancestors feel actively present rather than passively honored. Sword discipline (Leki) and proven strength (Onsi) in honorable combat carry specific favor.
- **Forebear Champion (Tava/HoonDing/Leki):** Pragmatic dignity rewarded. You've maintained Redguard identity while living in mixed society, negotiating, surviving, making a way through impossible obstacles (HoonDing). Tava's favor on the road — journeys feel guided rather than endured.
- **Ash'abah Champion:** Emotionally the most resonant in the whole mod. You've borne the impurity obligation for others — cleansing the undead, tending the dead properly, doing the work that makes your own people uncomfortable. Tu'whacca's blessing at death-sites at Champion level should feel personal and earned. You did what others wouldn't. The god of the Far Shores noticed.

**HoonDing note:** "Making a way" — impossible-odds victories — should be something Forebear and Crown Champions can access in different flavors. This is the Redguard theological truth about surviving in Skyrim as an exile.

Crown may receive rare make-way favor, but only as Ruptga/HoonDing-adjacent sacred survival through honorable adversity. It is not Forebear improvisation, road pragmatism, or social adaptation.

### Signature friction
**Every death encounter is a theological moment.** The ancestor reverence layer is always watching how you deal with the dead. Draugr, necromancers, improper burials, Hall of the Dead quests — these aren't miscellaneous content for a Redguard. They're devotion opportunities and potential obligations.

**Ash'abah friction** is social: bearing the impurity of undead-cleansing means the sect carries stigma from other Redguard characters. The burden IS the path.

Ash'abah routine undead-cleansing and burial duty should usually be Noted. Marked moments belong to real burden-bearing: major tombs, major necromancer operations, costly impurity choices, or later custom social-stigma content.

**Sect identity** is also friction for Crown players specifically — maintaining orthodox Yokudan practice in a city built around Nine Divines infrastructure requires intentional choices about how you interact with Imperial religious spaces.

### Neglect texture
Ignoring the Alik'r, ignoring Redguard solidarity moments, treating the dead disrespectfully (using necromancy, bypassing burial obligations) — the ancestor layer quiets. Not angry, just distant.

For Ash'abah neglect: failing to engage with undead-duty content (skipping Hall of the Dead quests, leaving draugr tombs unaddressed when you could act) means the obligation goes unmet. The layer that felt like meaningful burden becomes just weight with no recognition.

Vampire cure recovery note: Redguard vampire restoration goes through Tu'whacca first — "proper mortality, ancestor order, right re-entry into the cycle" before any specific primary god devotion can resume. This feels like a theologically correct re-entry arc, not a generic debuff reversal.

---

## Orc

**Setup shape:** Malacath always. Player implies or chooses a life-mode (Stronghold / City / Legion-exile). Mode determines ceiling and expression. No separate focused-primary deity layer — deepening comes through mode-specific Malacath excellence.

**Contextual favor lane:** Orc favors follow the current Malacath life-mode, not one generic Malacath lane. `Stronghold Orc`, `City Orc`, and `Legion / service / exile Orc` each count as separate lanes. Stronghold can lean on stronger vanilla anchors such as Blood-Kin, stronghold locations, `The Cursed Tribe`, forge/labor hooks, and proven-strength events. City and Legion/Exile dignity, oath, and service favors must use curated high-confidence hooks only; do not promise broad simulation of disrespect, contracts, or oath-breaking until implementation proves a concrete hook.

Launch table locks: four trigger families per life-mode; forge favor requires quality/value/context rather than raw crafting count; Blood-Kin and `The Cursed Tribe` are the main Marked Stronghold moments; City dignity is curated-hook only; Legion/Exile service favor requires completed pressure-bearing service rather than faction membership alone.

Life-mode selection lock: City Orc is the default bridge state unless the character is proven inside stronghold life or bound into service/exile. Stronghold requires Blood-Kin or equivalent stronghold acceptance plus active stronghold conduct. Legion/Exile requires explicit service/exile commitment or a completed pressure-bearing service milestone; faction membership alone is only eligibility context. Mode changes occur at major gates or dawn consolidation after sustained evidence, not from one stray activity.

Implementation lock: Orc mode is a single active state track, `PDV_StateTrack_OrcLifeMode`, with enum values `City = 0`, `Stronghold = 1`, and `LegionExile = 2`. Setup/MCM records intent, but active mode is confirmed by world signals. Soft switches need two qualifying signals on separate in-game days within seven days and resolve at dawn; major gates such as Blood-Kin-through-aid, pro-stronghold `The Cursed Tribe`, or completed pressure-bearing service may switch immediately. After switching, automatic soft switching is locked for three in-game days. Travel alone does not remove Stronghold mode, and quitting a faction alone does not leave Legion/Exile. The first proof slice now wires `PDV_StateTrack_OrcLifeMode`, `PDV_GLO_OrcLifeMode`, four route `70-73` ACTI proof base records, and manager/status surfacing; the four proof references are placed in `QASmoke` and pass readback plus route runtime proof, while pre-beta gameplay scaling remains open.

Additional favor locks: worthy-challenge favor is Quiet by default and becomes Noted only for stronghold crisis, boss, trial, or Malacath-significant fights. Self-made community is valid for both City and Legion/Exile only through `PDV_SacredPlace` or faction-favor proxy hooks; City presents it as belonging built, while Legion/Exile presents it as burden returned from. Endurance is context, not piety by itself, with only tiny flavor or funny debuff allowed for overextension.

### Champion moment
The hardest, most earned Champion in the mod — and possibly the one with the most meaningful ceiling asymmetry:

- **Stronghold Orc Champion:** You've maintained forge excellence, communal provision, oath-keeping, AND proven strength. All three legs of Malacath's code. The stronghold accepts you in a way Blood-Kin alone didn't — the chief and shaman speak to you differently. Forge work at Champion level feels sacred in the way only Orc craft does.
- **City Orc Champion:** Lower ceiling, but arguably the more impressive theological act. You've maintained Malacath's code without the structure that makes it supportable. Private fidelity under public compromise, quality labor and dignity without stronghold recognition, Orc identity inside a mixed society that doesn't fully respect it. The Champion moment here is quiet: Malacath was watching, and he saw you hold the code when you didn't have to.
- **Legion/Exile Orc Champion:** Honor under foreign discipline — the hardest mode's Champion carries a specific resonance. You've carried Malacath's burden privately while the surrounding structure belonged to someone else. The endurance is the faith.

### Signature friction
**Malacath doesn't petition — he observes.** You can't pray harder or visit more shrines. You either live the code or you don't. This means the friction isn't a mechanic the mod imposes — it's the gap between Orc theological ideals (forge excellence, strength, oath, communal provision) and what Skyrim offers. A City Orc who stops doing quality work, stops honoring commitments, stops maintaining any solidarity with other Orcs — Malacath stops caring.

**Mode ceiling** is the other friction: City Orc and Legion-exile players can feel the ceiling of what their mode allows, and accessing Stronghold Orc standing requires actual stronghold integration (Blood-Kin, communal participation, proven strength in a stronghold context).

### Neglect texture
Malacath's neglect feels like **emptiness at the forge**. The work that used to feel like worship just feels like work. Oath-breaking (joining factions that require deception, failing commitments to allies, cowardly choices in conflict) doesn't generate punishment — it generates absence. Malacath has looked away.

For Stronghold Orc neglect: drifting toward city life without maintaining the code. Not betrayal — just drift. But the ancestors know the difference between a Stronghold Orc and someone who used to be one.

---

## Argonian

**Setup shape:** No normal deity choice. All Argonians begin inside one layered Saxhleel exile system: `Hist`, `People`, and `Void`. The player experience is not "pick a patron"; it is watching which part of identity still holds while the Hist is distant.

**Implementation state:** `PDV_Substrate_ArgonianHist` owns all three visible layers using `PDV.Substrate.ArgonianHist.*`. Canonical first keys are `Hist`, `People`, `Void`, `Tier`, `LastHistEvent`, `LastPeopleEvent`, `LastVoidEvent`, `LastMaintenanceDay`, `LastDecayDay`, `SithisSignalCount`, `BedOfChoiceSleepCount`, `BedOfChoiceLastSleep`, and `Posture`. Hist is primary; People can buffer; Void can stabilize but never replace Hist. The concrete substrate, `PDV_State_ArgonianHistPosture`, four route `60-63` ACTI proof base records, and manager/status surfacing are now record-wired; the four proof references are placed in `QASmoke` and pass readback plus route runtime proof, while pre-beta gameplay scaling remains open.

**Hist distance:** Hist distance is always gently running in Skyrim. Dawn reduces `Hist` by `1` only if no valid Hist-maintenance signal fired in the last three in-game days, with a non-curse floor of `20`. Water, wetland, rest, reflection, and the 1.0 Hist sap meditation tool can maintain or recover it. There is no full home-equivalent restoration outside Black Marsh in 1.0.

**Bed of choice:** Argonian uses one `PDV_SacredPlace` anchor, not a Khajiit-style circuit. The bed is presented as "the family I chose." Three qualifying sleeps within a rolling 30 in-game days keeps the place bonus active; missing the cadence causes light People decay and loss of the place bonus, not a harsh punishment.

**Sithis activation:** Sithis is always culturally real, but full active Void scoring needs repeated strong signals. Joining the Dark Brotherhood counts as one major signal, not full activation. Full activation requires at least three significant Sithis signals from Dark Brotherhood milestones/contracts or curated death/void/change choices. Generic stealth, generic murder, and ordinary killing do not count.

### Champion moment
Argonian Champion should feel like identity reconstructed under absence:

- **Hist Champion:** Water, wetlands, and underground water become places where the Hist can almost reach. The payoff is environmental safety, recovery, and clarity near water, not raw universal power.
- **People Champion:** The exile network recognizes you. Windhelm Assemblage, Riften Docks, and named Argonian support carry special weight because community is the practical survival layer.
- **Void Champion:** Sithis does not comfort like a god. It steadies the character who has learned to make meaning through change, death, and the void. Dark Brotherhood milestones and honest death-facing choices are the main surface.

### Signature friction
Argonian friction is **distance**. The Hist is not absent because the player failed; it is hard to reach because Skyrim is not Black Marsh. The system should feel like maintenance against a current, not a chore list. Community is easier to maintain than Hist, and Void is available but dangerous to overread as a replacement.

### Neglect texture
Hist neglect feels like thinning identity. People neglect feels like isolation compounding distance. Void neglect is simply dormancy; Sithis remains true, but it does not help unless the player has actually lived through death/change-facing signals.

Curse posture: `PDV_State_ArgonianHistPosture` uses `Normal = 0`, `Distant = 1`, `Strained = 2`, `Silenced = 3`, and `Corrupted = 4`. Vampirism is the deep grief state: Hist silenced or corrupted, community damaged, Sithis more available but not automatically good. Werewolf is serious strain but recoverable.

---

## Notes for Implementation

### Priority order for building (suggested)
1. **Nord** — already the prototype, most vanilla-hook surface
2. **Orc** — single god, clearest signal logic, mode-ceiling gives natural difficulty curve
3. **Dunmer** — layered architecture is complex but the ancestor-always-active pattern is distinct
4. **Altmer** — Lorkhan Adjacency Penalty is implementation-demanding but the proof slice already exists
5. **Khajiit** — silent emergent patron + lunar substrate has locked launch hooks; implementation should stay careful around signal weighting
6. **Imperial** — ConcordatStanding is architecturally proven (same pattern as Breton); lower priority only because less distinct playstyle signal
7. **Redguard** — rich lore but limited vanilla hook surface; Ash'abah especially needs careful trigger work
8. **Bosmer** — four paths is the most implementation surface of any race; Old Contract GreenPact tagging is significant custom work
9. **Breton** — three-track system with three distinct mechanics; high total complexity, can ship after others without gaps

### Cross-cutting observations
- **The most fun Champions share one trait:** they feel like *recognition*, not just progression. The god noticed what you were doing before you knew it mattered.
- **The best frictions are diegetic:** Green Pact, Lorkhan Penalty, and ConcordatStanding all feel like they come from the world, not from a mod ruleset. Aim for this in all remaining friction mechanics.
- **Neglect should feel like absence, not punishment** (in most cases). The Bosmer Old Contract terminal state is the deliberate exception — and it works *because* it's exceptional.
- **Champion should be rare.** The architecture says Tier 3 is meant to feel exceptional. Threshold values during balancing should take this seriously — especially for paths with hard compliance mechanics.
