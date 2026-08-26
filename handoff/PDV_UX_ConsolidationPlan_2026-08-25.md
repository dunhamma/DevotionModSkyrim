# PDV UX consolidation plan - 2026-08-25

**Status:** LIVING until Phase 0-1 land, then it becomes the standing cycle description.
**Supersedes for workflow:** nothing. It sits *under*
`handoff/PDV_UX_NextSession_Handoff_2026-08-25.md`, which remains the operating pattern
(recover -> reconcile -> implement). This plan fixes the setup that pattern runs on.
**Evidence bucket:** repo readback and tool execution, 2026-08-25. No ESP readback, no
runtime proof, no game file touched.

---

## 1. Why this exists

The next-session handoff gives us a better operating pattern than the discovery-first loop
used on 2026-08-24, and Codex has built real infrastructure under it: stable `nodeId`s,
independent Papyrus/ESP/reachability/copy evidence per node, eight audit profiles, a
compact five-row actionable queue, and a census-validating export gate.

Reviewing that setup surfaced friction that will slow every future slice if left alone.
The owner's direction is to fix it, then run faster with polish as the north star.

## 2. What the review found

Each item below is a live condition verified today, not a recollection.

**a. The declared prose authority is untracked and at disappearance risk.** The handoff
names `outputs/PDV_Accessible_Prose_Workbook_2026-08-25/..._v3.xlsx` as the current
workbook. `git check-ignore` resolves it to `.gitignore:193 outputs/**` - it is ignored.
Git still tracks only the *superseded* v2. Yesterday's rule re-included exactly one
hardcoded dated folder, so the moment the workbook was revised it fell out of version
control. This is the same disappearance risk that rule was written to close.

**b. The workbook is now split across two folders.** The 2026-08-25 folder contains only
the xlsx and an inspect ndjson. Its round-trip inputs
(`canonical-roundtrip-source.csv`, `reference-disposition-audit.json`) exist only in the
2026-08-24 folder, and `tools/pdv_implementation_audit_export.mjs:21-22` hardcodes those
2026-08-24 paths. So the export gate passes (`{"ok":true,...}`, exit 0) while validating
against yesterday's supporting data and a workbook that is no longer the authority.

**c. Date-stamped authority paths are the common cause of (a) and (b).** Every rule, tool
constant, and handoff line that names a dated path breaks silently on the next revision,
and the breakage is invisible because the gate still exits 0.

**d. Findings live in two systems that cannot see each other.** The atlas queue holds five
rows, Imperial-focused. Six finding clusters from 2026-08-24 live only in markdown briefs:
the Marked-tier rung, the Sithis threshold copy defect, the ~19 neglect-transition rows,
champion-entry coverage, curse-message coverage, and the loose bolts (two dead
`VampireScar` keys, Redguard offers covering 3 of 7 deities [corrected 2026-08-26: no 7-roster exists -- see PDV_RedguardLoreBaseline.md], Dunmer's decay-free
substrate). The queue therefore understates real scope, and prioritising from it alone
would work the wrong things first.

**e. Superseded documents still read as live.** `PDV_UX_Claude_Handoff_2026-08-24.md` is
explicitly superseded but makes present-tense workflow claims, and the tranche wrap's
backlog section still lists resolved items as pending.

**f. Codex's improvements are uncommitted.** `.gitignore` (+1: the audit output ignore) and
`AGENTS.md` (+4/-2: better atlas/tool rows, plus the export tool) sit unstaged in the
working tree - real work, currently unprotected.

## 3. Decisions taken (owner, 2026-08-25)

1. **North star is all three of coherence, craft, and voice**, cycled in whatever order
   serves the work - not one at the expense of the others.
2. **One queue**, and the migration must be *properly deep*: full evidence carried across,
   not summaries. Skimmed information has bitten this project repeatedly.
3. **Codex owns the source/PEX drift.** Claude version-qualifies affected claims and
   explicitly calls out Codex-owned findings as they are discovered, for handoff at
   appropriate points.
4. **Stable, undated authority paths.**

## 4. Phase 0 - stop the bleeding (do first, small)

1. **Commit Codex's uncommitted work** as its own commit, unmodified, so it is protected
   before anything else moves. Verify `+N/-0` on `AGENTS.md` beyond the intended rows.
2. **Move the prose authority to a stable path.** Target:
   `references/authoring/prose-workbook/PDV_ProseWorkbook.xlsx` plus its round-trip inputs
   in the same directory. Track all three. Untrack the superseded v2 and leave the dated
   folders on disk as local history.
   - Update `tools/pdv_implementation_audit_export.mjs:21-22` to the stable paths.
   - Update `.gitignore`: drop the dated re-include, add the stable directory.
   - Update the authority line in `PDV_UX_NextSession_Handoff_2026-08-25.md`.
   - Re-run both gates; the export gate must still exit 0 **and** now be reading the v3
     workbook's own inputs. If the v3 round-trip inputs do not exist, regenerating them is
     part of this step - a gate reading a superseded input is worse than a failing gate.
3. **Archive the superseded docs.** Add a dated ARCHIVE banner to
   `PDV_UX_Claude_Handoff_2026-08-24.md` pointing at the 2026-08-25 handoff, and correct
   the tranche wrap's backlog section so no living doc makes a stale present-tense claim.

## 5. Phase 1 - one queue, migrated deep

Migrate every 2026-08-24 finding into `implementationAudit.queue` using the existing row
contract. **Depth requirement:** each migrated row carries the same fields Codex's rows
carry, populated to the same standard - no row may be a one-line summary.

Required per row: `auditId`, `kind`, `race`, `moment`, `playerImpact`, `question`,
`gapClass`, `status`, `nodeIds[]` (linking real atlas nodes), `copyIds[]` where copy is
implicated, `papyrusResult` (the specific mechanism with file:line), `espResult`,
`implementationRoute`, `runtimeProof`.

**Honesty rule for `espResult`:** every migrated finding is Papyrus-source verified only.
Each row states that explicitly and names the ESP readback still owed. Those become Codex
handoff items - Codex has houseCARL, the UX branch does not.

Rows to create, with the evidence each must carry:

| auditId | Substance to preserve |
|---|---|
| `shared.surfacing.marked-tier` | Architecture 10.6 defines Quiet/Noted/Marked; Marked has no implementation for any race. All contextual favor exits one call, `PDV_ContextualFavorRuntime.psc:177`. Route: new event name on the existing typed toast payload (`SendPrismaEventToast` already carries heading/body and degrades via `BuildPrismaEventFallbackText`), paired with a Book of Days entry. Constraints: Prisma view cache key must be bumped; heading must resolve the public display name; anti-farm cap belongs on the pulse. |
| `argonian.sithis.threshold-copy` | Three distinct defects, not one. (i) `VoidActivationSignalsRequired=3` at `PDV_Substrate_ArgonianHist.psc:25`; `RecordVoidSignalScaled:124` increments without reading the prior value, so the crossing is never detected as an event. (ii) The driver phrase "crossing a Void threshold" (`PDV_PrismaPresenter.psc:1507`) is attached to every post-activation signal - true once, wrong thereafter - and `groupDrivers` aggregates by reason string, so the Dashboard renders it with a multiplier. (iii) `SendPrismaEventToast` is called with an empty context, so that phrase never reaches the toast; and no `AppendBookOfDaysEntry` call anywhere in live-source mentions Sithis or Void. Pre-activation silence is deliberate per the comment at `PDV_OriginRuntime_Argonian.psc:840`. |
| `shared.surfacing.neglect-transitions` | ~19 audit rows are one missing capability: 18 `neglect.lapse` notification rows (Altmer 3, Argonian 3, Bosmer 4, Imperial 4, Orc 4) plus the Khajiit substrate-thinning row. Neglect grace differs by race - 3 days for most, 5 for Breton/Orc/Redguard - and the *basis* differs too (substrate time, Hist posture, curse posture). Any shared surface must read the per-race basis rather than assume one. |
| `shared.champion-entry.coverage` | Entry messages shown through the standard path exist for Nord/Kyne only. Redguard has three but keyed to sects, not its seven deities. Dunmer and Khajiit fire the moment Prisma-only with no record. Imperial, Altmer, Breton, Argonian, Bosmer, Orc have none - and Breton's is actively suppressed by `ShouldSuppressBretonFocusedChampionTierSurface`. Ties directly to the handoff's Imperial champion row: the shared architecture it asks for is this row. |
| `shared.curse.message-coverage` | Full onset/cure coverage: Nord, Argonian, Redguard, Khajiit. Altmer werewolf-onset only - and the "terminal, no cure lane" belief is **disproven**: the cure branch clears the halt and its one-shot; only the cure-side message is missing. None at all: Imperial, Breton, Dunmer, Orc. Bosmer has no curse handler whatsoever (falls to the base no-op). Includes the handoff's Imperial curse row. |
| `shared.emergence.coverage` | Khajiit is the only race with a real emergence beat (per-focus MESG + Book of Days entry). The sole other `emergence.onset` emitter, `PDV_OriginRuntime_Breton.psc:669`, is provably unreachable - it sits inside the quiet-presentation window that `PDV_PrismaPresenter.psc:181-183` early-returns during, and fires on tradition-set rather than the Devoted crossing. The coverage map's "Devoted surfaces via emergence" is design intent, not build state. |
| `shared.offer-copy.deity-naming` | 23 of 45 offer descriptions do not contain the deity's explicit public name; per-record inventory already complete in the wording backlog. Breton is the only fully compliant race. Owner writes; supports exist in the workbook's Offer Writing Worksheet (14 targets have a same-deity compliant twin; house pattern is four moves at a ~140-char median against a 500 ceiling). |
| `shared.dead-state-keys` | `PDV.Curse.Orc.VampireScar` and the Redguard `VampireScar` are written and read nowhere. Redguard `VampireReentryNeeded` is only ever cleared and gates no earning. Confirms the Redguard vampire earn-halt is specced, not built. Codex-owned cleanup. |
| `redguard.offer.deity-coverage` | Offer records exist for 3 of 7 deities (Tu'whacca/Leki/HoonDing); `IsRedguardOfferEligibleDeity` returns false for the other four. Owner decision: deliberate scope or unfinished tranche. [RESOLVED 2026-08-26: the roster IS three; the 7 figure was documentation drift. PDV_RedguardLoreBaseline.md] |
| `dunmer.substrate.no-decay` | The only metric substrate with no decay function. Owner decision: deliberate or missing. |

After migration, **re-prioritise the combined queue by player impact**, not by which system
a row came from. Expect the Imperial-first order to survive - the handoff's three Imperial
rows are instances of the shared champion/curse rows - but state that explicitly rather
than assuming it.

## 6. Phase 2 - the working cycle

Per the owner's direction, each slice touches all three north-star dimensions rather than
sequencing them globally:

- **Coherence** - the transition actually fires and routes, with its anti-spam rule.
- **Craft** - the surface treatment is deliberately designed, not defaulted; Penpot only
  when spatial or adjacency work is genuinely needed.
- **Voice** - exact prose is the owner's, written against the workbook with Claude
  supplying targets, twins, budgets, and conformance checks.

The slice contract is the handoff's: recover the locked decision, reconcile against
independent Papyrus and ESP truth, ask only the unresolved frontier, implement the
smallest complete moment, close the loop in the narrowest authority. Because the
champion/curse/neglect rows are *shared* capabilities, the first slice of each builds the
pattern and later races become content, not new architecture.

## 7. Phase 3 - the Codex lane

Maintain a running, explicit list of findings that are Codex's to fix, surfaced as they
are found rather than batched at the end. Seeded with:

- the source/PEX drift across 26 shared scripts (blocking unqualified route claims);
- ESP readback for every migrated row's `espResult`;
- the two dead `VampireScar` keys;
- the global Message census paging defect (500-record blind spot);
- the `pdv_implementation_audit_export.mjs` path fix, if Codex would rather own it.

Until the drift is resolved, **every route claim Claude makes is explicitly qualified as
repo-mirror-derived**, and that qualifier is written into the row, not just said in chat.

## 8. Execution order

Phase 0 (safety, small) -> Phase 1 (one deep queue) -> re-prioritise -> then the first
vertical slice, expected to be Concordat posture surfacing per the handoff's reasoning that
it is the smallest fully design-locked tracer.

## 9. Verification

- `git check-ignore` on the stable workbook path returns not-ignored; `git ls-files` shows
  the workbook and its round-trip inputs tracked; the superseded v2 no longer tracked.
- `node tools/pdv_atlas_render.mjs --check` exits 0, and its node counts rise by the
  migrated rows' linked nodes.
- `node tools/pdv_implementation_audit_export.mjs --check` exits 0 **and** its resolved
  input paths point at the stable directory - checked by reading the paths, not by trusting
  the exit code.
- Every migrated queue row names its ESP readback as owed rather than implying it is done.
- No `.psc`, ESP, Prisma asset, or workbook prose cell is modified by any Phase 0-1 step.

## 10. What this plan deliberately does not do

No progression dashboard (owner chose the single-queue option without it). No redesign of
Codex's audit schema - it is good and this plan populates it rather than replacing it. No
reopening of design decisions the race packets already lock.
