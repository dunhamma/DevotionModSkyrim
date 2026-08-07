# Dead code and retired scaffolding -- verdicts (2026-08-07)

**Report only. Nothing was removed.** Every removal is its own packet, gated on owner approval.

Candidates harvested by `tools/pdv_hygiene_harvest.mjs` against the **live MO2 tree**
(`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`), not the repo mirror -- the mirror was
stale on 19 files by up to seven weeks on the day of this pass, so a mirror-based sweep would have
described a codebase that does not exist. Record evidence taken with houseCARL pointed at **Anvil /
Devotion Dev** (confirmed before reading; it had been on ARR 2.5, which serves a four-day-old
`Devotion.esp`).

## Candidate volumes

| Class | Count | Note |
|---|---|---|
| Unreferenced properties | 44 | highest-value set; the 21-strong OfferResponse family dominates it |
| Uncalled functions/events | 136 | most are fragment/EventBus/MCM roots, not dead |
| StorageUtil keys written-never-read | 243 | **not adjudicated** -- dominated by legitimate one-way stamps and one-shot flags; needs a different question |
| StorageUtil keys read-never-written | 18 | reads that can only ever return the default -- worth a look |
| Unreferenced tools | 6 | |
| Retired-scaffolding markers | 29 | |

## VERIFIED FINDING -- the commitment-offer response mirrors

**21 properties: `PDV_Msg_<Race>_OfferResponse_{Accept,NotYet,Refuse}` across all seven races.**

Evidence, checked directly rather than inferred:

- Zero references in live source outside their declarations. A Papyrus `Auto` property with no
  source reference cannot be shown regardless of its VMAD binding -- something must call `.Show()`.
- The live surfacing path does **not** use them. Offers resolve through built lines:
  `BuildCommitmentOfferAcceptToastLine`, `BuildCommitmentOfferAcceptJournalLine`,
  `BuildCommitmentOfferRefuseToastLine`, `BuildCommitmentOfferRefuseJournalLine`. That matches the
  shipped behaviour recorded in memory: refuse surfaces as toast + pinned Book entry.

**Prior rulings exist, and they are STALE rather than protective:**

- `references/authoring/PDV_FinalPolishLook_Ledger.md:98` (FP-020) marks the offer MESG work
  **done-on-live**, citing records `071513-071522` and a per-god selector. The records exist; the
  selector no longer consumes the OfferResponse mirrors.
- `references/authoring/PDV_FormalOfferWriting_Copy.md` carries authored, copy-reviewed text for
  every mirror ("Pass (enriched from thin placeholders)") -- real writing, landed in records, now
  bypassed by the built-line path.

**Verdict: SUPERSEDED-NOT-DEAD -- needs an owner ruling, not a deletion.** Two readings, and the
choice is a design call:

1. *The rework is intended.* Built lines replaced the MESG mirrors deliberately; the 21 properties,
   their VMAD bindings and their records are leftovers and can go. The authored copy should be
   checked against the built lines first so nothing good is lost with them.
2. *The rework was a regression.* The mirrors were authored on purpose and the built lines are
   thinner; the fix is to re-wire, not remove.

Either way **two docs now misdescribe the shipped mod** and should be corrected once the call is
made. This is the finding that most justified the pass: a mechanical sweep called it dead code, and
the prior-ruling grep turned it into a live design question.

## VERIFIED FINDING -- self-inflicted, from today's own work

**`GetAltmerPracticeLine` and the `practice_focus` arm of `GetAltmerHeritageSourceLine` are
unreachable.** `AppendAltmerHeritageVoice` intercepts `practice_focus` and delegates to
`AppendAltmerPracticeEntry` before the source-line resolver is reached, so the arm cannot fire and
`GetAltmerPracticeLine` -- its only caller -- is dead in the live flow.

Harmless today (defensive fallback), but it is a **second draw site** from the practice-line pool
with its own `LastId` write. If it ever became reachable it would reintroduce exactly the
toast/Book divergence that the single-pick design exists to prevent.

**Verdict: CONFIRMED-REMOVABLE**, with the removal recipe: delete `GetAltmerPracticeLine`, collapse
the `practice_focus` arm in `GetAltmerHeritageSourceLine` to fall through to the default (the arm's
comment explains why the default was wrong for this reason string -- keep that reasoning attached to
whatever replaces it), recompile the manager and PDV_MCM, then re-run the Prisma UI audit, whose
assertions touch this function.

## AGENT-PROPOSED, NOT YET VERIFIED

A Sonnet sweep covered 44/44 properties, 29/29 scaffolding markers and 42/84 functions against live
source with the guardrail set. **Everything below is a HYPOTHESIS.** A delegated classification is
not evidence; each `LIKELY-REMOVABLE` needs a main-loop re-verification before it earns a verdict
here. Recorded so the work is not lost, explicitly fenced so it is not mistaken for a finding.

Proposed counts across 115 adjudicated rows: LIKELY-REMOVABLE 32, ROOT-NOT-DEAD 43,
NEEDS-RECORD-CHECK 24, KEEP-INERT 14, LEDGER-PROTECTED 7, UNCLEAR 15.

**The guardrails earned their place** -- they caught things a mechanical sweep would have deleted:

- `SendPrismaStartupPayload` / `SendPrismaMedallionPayload` have zero callers **by machine-enforced
  design**: `tools/pdv_prisma_ui_audit.mjs:1105-1116` asserts `countMatches(...) === 1` and FAILS if
  anything calls them. Deliberate scaffolding for the unbuilt Prisma choice-panel return channel.
- `HandleNordAncestorSpine`, `HandleDunmerClumsyCrime`, `RouteOrcStrongholdPresence`,
  `RouteBosmerBaanDarGap` are all in `tools/pdv_reserved_routes.json` awaiting a Phase 4 verdict --
  deleting a reserved entry is itself a gate FAILURE.
- `TempleBlessingScript`'s two Message properties carry an in-file ruling: the activator records
  bind them, so deleting the declarations "would trade a silent no-op for a 'property does not
  exist' warning on every shrine, every load."
- `ConsumeKhajiitLunarMetricBudget` and `SelectMedallionEntry` are fail-closed compat stubs whose
  bodies say so.

**Three proposed findings that look like live defects rather than cleanup, and are worth an owner
look regardless of what happens to the rest:**

1. **`PDV_Msg_*_ChampionEntry` orphaned bindings.** `AGENTS.md:1560` already records that the
   Champion Accept/Decline offer is broken for **all 16 Princes** -- the `..._ChampionEntry` MESGs
   were never bound to the path-quest VMAD properties, so they read `None` at runtime. That is an
   open defect the sweep re-surfaced, not dead code.
2. **`RefreshOpenBookOfDays` is validated by three separate gates and called by nothing.**
   `pdv_prisma_ui_audit`, `pdv_book_of_days_audit` and `pdv_matrix_runtime_preflight` all assert
   against it -- one even forbids `AppendBookOfDaysEntry` from calling it -- yet no live code,
   including `OnUpdate`, invokes it. It looks like an intended periodic refresh that was never
   wired into the tick loop.
3. **`AwardDunmerAncestorSpinePulse` is documented as live and has no call site.**
   `PDV_PrismaParityRegistry.csv:65` and `PDV_RunSheet_Dunmer_V1.md:184` both state it fires the
   Ledger driver on ancestor prayer, but the live handlers only call `RecordPortableShrinePrayerScaled`
   on the substrate. `pdv_verify` checks only that the function's signature exists, never that
   anything calls it -- so the gate cannot catch this class.

**Two more proposed missing-wire gaps, same shape as the three above:**

4. **`PDV_Msg_Nord_CurseState_WerewolfCured`.** Its three siblings (VampireOnset, VampireCured,
   WerewolfOnset) are all wired through `ShowNordMessage` in `ApplyNordCurseHandlers`; the
   werewolf-cure branch has no matching call. `PDV_TransitionSurfacing_CoverageMap.md:97-99`
   documents the quad as complete.
5. **`PDV_Msg_Nord_Kyne_ChampionEntry`.** Redguard's parallel `MaybeShowRedguardChampionEntry` is
   fully wired; the Nord/Kyne counterpart has authored copy
   (`PDV_VoiceConformance_RecordCopy.md:103`) and zero call sites.

**Two agents disagreed on several rows, which is itself worth recording.** A first-pass sweep called
`ATTR_NONE` and `PDV_BOOK_ArgonianHistSapToken` removable; a dedicated properties pass found
in-source rulings for both (`ATTR_NONE` is the sentinel of a live enum reached through
`AttributionLabel`'s fallthrough; the Hist token's book-to-potion migration landed and the comment
says the property stays declared). Where two runs disagree, the more thorough read won both times --
which is the argument for main-loop verification rather than accepting either.

Still uncovered: 42 of 84 functions, the 18 read-never-written StorageUtil keys, and the 6
unreferenced tools.
- **The 243 write-never-read StorageUtil keys** were deliberately excluded. That set is dominated by
  one-way stamps, one-shot guards and migration flags whose whole purpose is to be written and
  checked by a *different* mechanism. Asking "is this key read?" of that population produces noise;
  the useful question is narrower and should be posed separately.

## A false-positive class this pass produced, and fixed (2026-08-07)

The first harvest listed **`BeginExternalReactionBatch`, `ApplyExternalReaction` and
`EndExternalReactionBatch` as uncalled functions.** They are the public API that third-party patch
scripts call. Nothing inside Devotion calls them and nothing ever will -- removing them on that
evidence would have broken every patch using the compatibility seam.

`RegisterQuestReactionChannelFolder` is the same shape seen from the other side: it scans
`../StorageUtilData/PlayerDevotion/Channels`, a folder Devotion deliberately does not ship, because
MO2 merges it in from whichever patch provides one. That folder is empty on Anvil and holds
**39 channel JSONs (~4.3 MB) on ARR 2.5** -- so "the folder does not exist, is the function needed?"
had the opposite answer to the one the evidence first suggested, and only because the first look was
at one instance.

`tools/pdv_hygiene_harvest.mjs` now separates these into `publicSeamsNoInRepoCaller` by reading the
seam language in each function's own preceding comment. The limitation is worth stating: **an
undocumented seam still lands in the dead pile.** If a function exists for callers outside this
repo, its comment must say so.

Recorded in `PDV_STANDARDS.md` 6.7b so the next sweep does not re-propose deleting the seam.

## Companion document

Performance verdicts for the same change set:
`references/authoring/PDV_AltmerCalianPapyrusOptimization_2026-08-07.md`.

---

# Completion pass (2026-08-07, later same day)

Report only. Nothing in this section was removed.

Source read: `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source` (harvester printed
`source is live MO2 tree: YES`). houseCARL instance confirmed **Anvil / Devotion Dev**.

## What this pass fixes about the pass above

The section above records bucket counts and five narrative findings, but **it never wrote down a
per-function table**. "Still uncovered: 42 of 84 functions" cannot be acted on, because nothing says
which 42, and a later reader has no way to tell an adjudicated function from an unexamined one. Any
row-level verdicts the earlier pass produced lived only in agent output and are gone.

This pass adjudicates **all 133** uncalled functions in the current live harvest **by name**, so the
next session inherits rows rather than counts.

Counts moved between the two harvests because the same-day fix packet (`d6759eab`) changed the code:
unreferenced properties **44 -> 42** (two Nord messages got wired), uncalled functions
**136 -> 133**, unreferenced tools **6 -> 5**.

## Main-loop verification changed three delegated verdicts

Bulk classification went to Sonnet subagents in four batches; every `LIKELY-REMOVABLE` and
`SUPERSEDED` row was then re-checked in the main loop against `tools/*.mjs` for an exact-name gate
needle. **Three rows flipped, all in the dangerous direction** -- each would have proposed deleting a
signature a gate requires to be present:

| Function | Agent said | Actually | Gate |
|---|---|---|---|
| `GetNordAncestorSummary` | LIKELY-REMOVABLE | **LEDGER-PROTECTED** | `pdv_verify.mjs:6228`, inside a `checkSourceContains` list |
| `GetImperialCivicLayerLabel` | LIKELY-REMOVABLE | **LEDGER-PROTECTED** | `pdv_verify.mjs:6905`, same shape |
| `RegisterGenericEffectList` | SUPERSEDED | **LEDGER-PROTECTED** | `pdv_verify.mjs:8847` requires the exact signature |

Two near-misses in the other direction are worth recording, because both are traps a careless
verification falls into:

- A plain substring grep makes `DebugSeedBosmer` look like it has 5 callers and
  `GetKhajiitLunarPostureLabel` like it has 3. Both are matches **inside longer names**
  (`DebugSeedBosmerVariety`, `GetKhajiitLunarPostureLabelAt`). Word-boundary matching is mandatory
  here, and the longer sibling is the live one in both cases.
- Every `Record*` wrapper appears to be named in `pdv_verify.mjs` and
  `pdv_substrate_pacing_audit.mjs`. Those hits are all matches on the `*Scaled` sibling. An
  exact-name needle check returns **no gate needle** for any of the twelve.

## Buckets, all 133 rows

| Bucket | Count | Meaning |
|---|---|---|
| ROOT-NOT-DEAD | 34 | reached via MCM dispatch, the Prisma panel chain, or an in-file summary chain |
| LIKELY-REMOVABLE | 37 | all checks clean, main-loop verified |
| SUPERSEDED | 16 | a `*Scaled` or refactored sibling took over; the wrapper is stranded |
| LEDGER-PROTECTED | 14 | a gate requires the signature present; deleting it FAILS the gate |
| KEEP-INERT | 9 | deliberately inert for save compat, body or comment says so |
| PUBLIC-SEAM | 4 | exists for callers outside this repo |
| NEEDS-RECORD-CHECK | 9 | forward-looking scaffolding named in a design doc; owner call |
| RETIRED THIS SESSION | 2 | `GetAltmerPracticeLine`, `RefreshOpenBookOfDays` |

### LIKELY-REMOVABLE (37) -- the actionable set

Nothing here is scheduled. A removal packet is its own commit, and each row still wants a
compile-and-gate run behind it.

**Thin wrappers whose target is called directly instead** (`PDV__ManagerQuest.psc`):
`GetPietyByIndex`, `GetPietyTodayByIndex`, `GetTierByIndex`, `GetBroadFloorServiceCount`,
`IsKyneNeglectActive`, `GetReputationDecayMultiplier`, `GetReputationGainMultiplierNoop`,
`GetKhajiitLunarPostureLabel` (the live one is `...LabelAt`), `EvaluateKyneContextualFavorFamily`,
`IsBretonNonResonantPatronChampion`, `DebugSeedBosmer` (MCM calls `DebugSeedBosmerVariety`).

**Debug entry points never wired to an MCM button** -- PDV debug is MCM-driven, and these ten have no
option handler: `DebugRecordArgonianHistMaintenance`, `DebugRecordArgonianPeopleSupport`,
`DebugRecordArgonianBedOfChoiceReturn`, `DebugRecordArgonianVoidSignal`,
`DebugRecordAltmerDawnSteadiness`, `DebugRecordAltmerOrthodoxCostlyEnforcement`,
`DebugRecordAltmerDragonbornCrisis`, `DebugRecordAltmerLorkhanPressure`,
`DebugSeedBretonDruidicFrayTest`, `DebugCycleKyneFavorMask`.

`DebugSeedBretonDruidicFrayTest` carries a comment claiming MCM wiring. The comment documents
intent, not a caller -- **a comment is not a call site**, and this is the second time in this pass a
stale comment nearly protected dead code.

**Orphaned label/summary builders** whose logic the live `Get<Race>SurveyText` duplicates inline:
`GetArgonianHistLayerText`, `GetImperialCursePostureLabel`, `GetKyneFavorSummary`,
`GetBretonDruidicForkLabel`, and `CountSetBits` (dies with its only caller, `GetKyneFavorSummary`).

**MCM-local dead code** (`PDV_MCM.psc`): `GetDeveloperPageStateLabel` (the locked page hardcodes the
literal instead), `GetPatronFormCacheValue`, `GetPatternSummaryString` (superseded by
`ShowPatternSummaryPaged`), `GetSelectedCommitmentSummary` (transitively dead -- its only caller is
`GetPatternSummaryString`).

**Unconsumed getters**: `GetAcceptedCreditCount`, `GetRejectedCreditCount` (`PDV_SubstrateBase.psc`),
`GetRawStateLabel` (`PDV_ReputationTrack.psc`), `GetLastOfferAt`, `GetPendingStartedAt`
(`PDV_StateTrack.psc` -- both underlying keys ARE written, so the data is live and only the getters
are unused).

**Two with an explicit prior ruling already on record:**

- `EvaluateQuestMetaFaucets` -- `tools/pdv_qr_direct_fanout.json:36-41` already calls it dead code and
  says to remove it. **Removal must delete that JSON entry in the same commit**, or the entry becomes
  a dangling reference.
- `GetStartupOptionDetailText` -- `handoff/PDV_CleanupDebt_Handoff_2026-06-17.md:17-26` rules it dead
  and says delete the body, keeping the Summary/Description helpers it calls. `pdv_verify.mjs:4345`
  requires the old `Debug.MessageBox(GetStartupOptionDetailText` **call pattern to stay absent**,
  which removal satisfies rather than violates.

### SUPERSEDED (16)

The dominant pattern: a substrate's unscaled `Record*` wrapper self-forwards to its `*Scaled`
sibling, and the manager calls the Scaled one directly everywhere. Twelve rows:
`RecordHeritageStanding`, `RecordHistMaintenance`, `RecordPeopleSupport`, `RecordBedOfChoiceReturn`,
`RecordVoidSignal`, `RecordPortableShrinePrayer`, `RecordPlayerHomeBonus`, `RecordCivicStanding`,
`RecordAncestorStanding`, `RecordAncestralRest`, `RecordHearthReturn`, `RecordHuntRite`.

Four more from refactors that moved a responsibility: `RouteBookRead` and `RouteHarvestIngredient`
(routing moved to `PDV_PlayerEvents` -> EventBus), `ReloadQuestReactionMatrixJson` (the MCM button
calls the manager's own `DebugReloadQuestMatrix` instead), and `InitializeBootstrap` (superseded by
direct `InitializeOrigin()` calls from the player-load ingress -- its sibling `OnInit` trace already
says "Origin bootstrap deferred to player load/sleep ingress").

### NEEDS-RECORD-CHECK (9) -- owner call, not cleanup

These are named in forward-looking design docs as material for planned work, so a mechanical sweep
reads them as debris when they are build-ahead. Two carry doc claims the code now contradicts, which
is a doc bug either way:

- `handoff/PrismaSubstrateInstruments_DesignDraft.md:75,125,175` claims
  `GetBretonWitchcraftExposureLabel` is "already wired into Survey". It is not --
  `GetBretonSurveyText` duplicates the thresholds inline.
- `references/authoring/PDV_VoiceConformance_RecordCopy.md:322` asserts "the live
  `GetBretonCursePostureLabel` returns bare enum-ish phrases". It has no caller.

Others in the group: `GetBretonKnightlyVowLabel`, `GetBretonDruidicStandingLabel`,
`GetAltmerHeritageLayerLabel`, `GetDunmerCursePostureLabel`, `GetMedallionDeityForOptionId`,
`IsMedallionOptionAvailableForOrigin`, and `EmitPrayerAnim` -- one of seven documented D1 diegetic
channels the dispatcher never calls, a missing wire in an intentionally partial scaffold.

## StorageUtil keys read but never written (18) -- all resolved

**Four are scanner artifacts**, not findings. A key ending in `.` is a static prefix the code
concatenates onto at runtime, so the scanner sees the literal and never the write: `PDV.QR.Job.`
(`PDV__ManagerQuest.psc:1929`), `PDV.Bosmer.Favor.` (`:7822`), `PDV.Orc.FourHolds.` (`:9511`),
`PDV.LongDevotion.MarkHigh.` (`:12235`).

**Ten are written elsewhere**, through concatenation or a shared helper the scanner cannot trace: the
`PDV.ArgWaters.Seen.*`, `PDV.BosSongs.Seen.*` and `PDV.Yffre.Seen.*` site guards (the numeric suffix
is a site LCTN FormID), `PDV.Diegetic.Mark.scar`, and the two Nord counters
`PDV.Nord.HircineArkayEdgeCount` and `PDV.Nord.KyneTalosContextCount`, both written inside
`RouteNordFamily(reason, countKey, ...)` where the key arrives as a parameter.

**Three are deliberate console/manual override hooks** with no script writer by design:
`PDV.Diegetic.Dep.Disable.`, `PDV.Diegetic.Dep.Enable.`, `PDV.Diegetic.Dep.ForceAllAbsent`, plus
`PDV.Diegetic.Verbosity`. `PDV_DiegeticDeps.psc:34-35` says so in its own comment.

**One is a genuine gap, and it is the only finding in this set:**
`PDV.Khajiit.LunarSourceCount` is read at `PDV__ManagerQuest.psc:26241` to gate the display line "A
lunar source has been read and remembered." Its sibling keys `PDV.Khajiit.LastLunarSourceTime` and
`...LastLunarSourceReason` are actively written, but nothing ever increments the Count -- so that
line can only ever see 0. Worth its own look.

## Unreferenced tools (5) -- none removable

`pdv_agent_worktree.mjs` (documented in `docs/agents/worktrees.md`) and `pdv_esp_diff_sweep.mjs`
(documented in two 2026-08-04 handoffs) are REFERENCED. `pdv_daedric_tables_gen.mjs` is a generator
whose committed output feeds `docs/player-guides/Daedric_Princes_Guide.md`. `pdv_patch.test.mjs` is a
`node --test` suite discovered by convention, and `pdv_show_daedric_boon.mjs` is a standalone
operator CLI.

The repo has no `package.json` and no CI config, so "unreferenced by npm/CI" carries no signal for
any tool -- that framing should be dropped from the harvester's output rather than re-litigated every
sweep.

## Correction to the section above

Finding 1 in "Three proposed findings that look like live defects" cites `AGENTS.md:1560` for the
Daedric-Prince Champion offer being "broken for all 16 Princes -- the `..._ChampionEntry` MESGs were
never bound". **That citation does not support the claim.** `Msg_ChampionEntry` is consumed via
`ShowIfPresent` in all 13 `PDV_DaedricPath_*.psc`, and `AGENTS.md:1596` records the opposite: the
MESG record and VMAD wiring were housecarl-verified correct (Boethiah `071270`), and the real defect
was the MCM `Message.Show()` gotcha, since fixed by deferring the modal.

The genuinely orphaned record was `PDV_Msg_Nord_Kyne_ChampionEntry` (`071526`) -- a different record,
collapsed into the same row. It was wired in `d6759eab`, along with
`PDV_Msg_Nord_CurseState_WerewolfCured` (`071523`). Both were confirmed present and already bound on
`PDV__ManagerQuest` VMAD (`00C325`), so neither needed an ESP write.

This is the `search-for-prior-ruling-before-reporting-a-finding` failure mode reproducing inside the
document that exists to prevent it.
