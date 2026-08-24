# Manual-review resolutions, and the transition-surfacing gap behind them

**Status:** LIVING. Opened 2026-08-24. Awaiting owner decisions (section 4).
**Workstream:** design-only, per `handoff/PDV_UX_Claude_Handoff_2026-08-24.md`.
**Evidence bucket:** static only — `live-source` grep and tracked design docs. No ESP
readback, no runtime route exercised, no in-game proof.
**Companion:** `handoff/PDV_UX_MarkedTier_DesignBrief_2026-08-24.md`.

---

## 1. Argonian — `PDV_Notif_Argonian_SithisActivation_FullActivation`

> **CORRECTION (2026-08-24, same day).** An earlier revision of this section claimed the
> crossing was silent. **That was wrong**, and the error was scope: the check stopped at
> `PDV_Substrate_ArgonianHist.psc`, which indeed contains no surfacing call, while the
> award path runs through the Ledger. A toast and a driver record both fire. The corrected
> finding is below and is sharper, not softer — the copy is wrong rather than absent.

**Resolved: the threshold is live and it IS announced — but by accident, with copy that
is true exactly once.**

`VoidActivationSignalsRequired = 3` (`PDV_Substrate_ArgonianHist.psc:25`), and
`IsVoidFullyActive()` (`:352-354`) gates on a `SithisSignalCount` accumulator that
`RecordVoidSignalScaled` (`:124`) increments without ever reading the prior value. So the
2→3 crossing is genuinely **not detected** as an event.

What happens instead is a side effect. `HandleArgonianVoidSignal`
(`PDV_OriginRuntime_Argonian.psc:829-843`) records the signal, then awards Sithis piety
**only if** `IsVoidFullyActive()` (`:841`) — and that award runs
`AwardCuratedSignalScaled` → `AwardPiety(..., CuratedSignalDriverReason(...))` →
`AwardPietyInternal`, which calls `RecordDeityDriver(deity, reason, amount)` and
`SendPrismaEventToast("favor", deity, "", "", "")`. `SIGNAL_VOID_THRESHOLD` is wired in
the driver table at `PDV_PrismaPresenter.psc:1507` as **"crossing a Void threshold"**.

Tracing the player's actual experience:

| Signal | Piety awarded | Toast | Driver record |
|---|---|---|---|
| 1st, 2nd | none — `:841` guard blocks it | none | none |
| 3rd (the crossing) | 2.0 to Sithis | yes | "crossing a Void threshold" |
| 4th onward | 2.0 to Sithis | yes | "crossing a Void threshold" |

Three consequences, in descending order of how much they matter:

1. **The threshold phrase never stops firing.** "Crossing a Void threshold" is attached to
   a repeating post-activation signal, not to the crossing. It is accurate exactly once
   and misleading on every subsequent void signal for the rest of the save. This is a live
   copy defect, not a missing feature.
2. **The toast drops the only explanatory text there is.** `SendPrismaEventToast` is
   called with an empty context argument, so the good phrase never reaches the toast the
   player actually sees. The player gets a generic Sithis favor toast; the sentence that
   would explain it exists and is discarded at the surface.

**Where the phrase does render — the Dashboard, and nowhere else.** Traced in full:
`RecordDeityDriver` (`PDV_DevotionLedger.psc:3309-3320`) humanizes the reason and pushes
it onto a **rolling 6-entry FIFO** on the deity form (`PDV.Driver.Reasons` / `.Deltas` /
`.Days`). Its only reader is `GetDeityDriversJson` (`:660-680`), whose only caller is
`AppendDashboardGod` (`PDV_PrismaPresenter.psc:532`), which embeds it as `"drivers":[…]`
in the per-god **Dashboard** payload. The view renders it through `groupDrivers()`
(`native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js:1869`) into a
`god__drivers` list whose empty state reads "Recent acts will show here."

Two consequences follow from that specific instrument:

- **`groupDrivers` aggregates by reason string**, summing counts. So the repeated
  post-activation signals collapse into a single Dashboard row reading *"crossing a Void
  threshold"* with a count of 2, 3, 4… A threshold crossing is by definition a one-time
  event; presenting it with a multiplier is self-evidently wrong to a player, and the
  grouping makes the defect more visible rather than less.
- **The 6-entry cap makes even the true instance transient.** Six further Sithis driver
  events push the activation out of the buffer. This is a recent-acts window, not a
  record — the wrong instrument for a once-per-save threshold.

**The Book of Days receives nothing.** It is a separate mechanism,
`Manager.Prisma.AppendBookOfDaysEntry(text, day, category, lane, …)`. The Argonian runtime
makes exactly two such calls — the Hist adaptation at `:476` and "A water that remembers."
at `:569`, both on the `hist` lane. Searching every `AppendBookOfDaysEntry` call in
`live-source` for Sithis or Void returns nothing. Sithis activation is chronicled nowhere.

That is the actual shape of the gap: the permanent instrument (Book of Days) is unused for
a permanent event, while the transient instrument (Dashboard recent-acts) carries
threshold wording it cannot honour.
3. **The run-up is silent, and that is correct.** Signals 1 and 2 produce nothing because
   `:840`'s comment states the rule deliberately: "Void piety belongs to Sithis only after
   the relation is explicitly active." Pre-activation silence is design, not a gap.

So the activation *is* marked — the player's first-ever Sithis toast coincides with it —
but incidentally rather than by design, and the marking degrades into a false statement
immediately afterwards. The fix is smaller than a new feature: distinguish the crossing
from the signals that follow it, and let the toast carry the reason it already has.

Implementation notes for whoever builds it: crossing detection must compare before and
after the increment rather than test the post-state; the reset path at `:392` must clear
whatever "already announced" flag is added; and the post-crossing signals need their own
driver phrase, since reusing the threshold wording is what makes it wrong.

## 2. Khajiit — `PDV_Notif_Khajiit_NeglectTexture_SubstrateThinning`

**Resolved: not a contradiction. Two different systems, both correct.**

"The substrate does not decay" (`race-sheets/PDV_RaceDesign_Khajiit.md:66`, from the
2026-07-13 Lunar-Road Pacing Addendum) governs the lunar **metric**, which is monotonic
under a +4/day cap. The lunar neglect the source computes is the separate **lane-neglect**
channel, which the same document designs at `:263-269` — and `:253` states it explicitly:
"the substrate doesn't decay *unless really neglected*." `PDV_DecayAudit.md:94` records
the Khajiit lunar substrate as "never decays severely — Sanctioned."

The neglect code is live and organic, not debug-only: `IsKhajiitLunarNeglected()`
(`PDV_OriginRuntime_Khajiit.psc:1735-1746`) tests time since the last lunar source against
a 3.0-day grace, and `SyncKhajiitNeglectSpell()` (`:1748-1766`) adds or removes
`PDV_SPEL_Neglect_KhajiitLunar`, reached through the adapter loop in
`PDV_DevotionLedger.psc:3670-3677` from several organic callers. Nothing anywhere reduces
the substrate metric. The flagged conflict was a misreading of "decay" versus "neglect".

**No defect, and no design change needed.** The row should be reclassified from
`Manual review` to something like "keep the copy, blocked on surfacing" — because the
secondary finding is that this copy has no live surface: zero occurrences of
`SubstrateThinning` or "more thinly" anywhere in `live-source` or the ESP, and
`SyncKhajiitNeglectSpell` fires no notification. The player receives a stamina debuff
with no text explaining it.

## 3. What all three findings have in common

Three independent investigations this tranche — the Marked tier, Argonian Sithis
activation, Khajiit lunar neglect — converged on one shape:

> PDV computes state transitions reliably and announces them inconsistently. The
> mechanics are live and correct. The surfacing layer is the gap.

In each case the state change is real and has real consequences (a scoring lane opens, a
debuff spell is applied, a costly act is scored), and in each case the player is told
nothing, or told the same thing they would have been told for a routine event.

This reframes the audit's 45-row `Consider new implementation` queue. Those are not 45
unrelated content ideas. **Roughly 19 of them are the same missing capability**: the 18
`neglect.lapse` notification rows (Altmer 3, Argonian 3, Bosmer 4, Imperial 4, Orc 4)
plus the Khajiit row resolved above. Every one wants a player-facing beat at a
neglect-state transition that the runtime already computes.

The practical consequence is favourable. Building one neglect-transition surfacing path
converts about 19 backlog rows from "design and build a feature" into "write the copy" —
and under the 2026-08-24 owner-writing rule, copy is the owner's lane. The same argument
applies to the Marked tier and to Sithis activation: they are transitions too, on the same
missing layer.

## 4. Owner decisions

1. Accept both resolutions: Argonian is a real gap; Khajiit is a misreading, not a defect.
2. Reclassify the Khajiit row out of `Manual review` (proposed: keep copy, blocked on
   surfacing). Recorded in the workbook's `Owner decision` cells.
3. Decide the scope question this tranche has surfaced: treat transition surfacing as
   **one capability** covering neglect transitions, threshold crossings, and the Marked
   tier — or keep authoring bespoke beats case by case. The evidence favours the former,
   and it is the difference between roughly 19 design items and one.
4. If the capability route is chosen, rank its first slice: neglect transitions (widest
   reach, 19 rows), Sithis activation (sharpest single gap), or the Marked tier (already
   has a written brief).

## 5. Proof boundary

Everything above is static evidence. None of it establishes in-game behaviour. Before any
of these is called done it needs the proof buckets listed in the Marked-tier brief's
section 9 — in particular a runtime route, a player-surface observation, and the anti-farm
cap on the transition rather than only on the presentation.
