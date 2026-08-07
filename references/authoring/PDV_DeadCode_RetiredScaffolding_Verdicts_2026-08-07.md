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

## Companion document

Performance verdicts for the same change set:
`references/authoring/PDV_AltmerCalianPapyrusOptimization_2026-08-07.md`.
