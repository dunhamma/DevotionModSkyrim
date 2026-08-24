# Manual-review resolutions, and the transition-surfacing gap behind them

**Status:** LIVING. Opened 2026-08-24. Awaiting owner decisions (section 4).
**Workstream:** design-only, per `handoff/PDV_UX_Claude_Handoff_2026-08-24.md`.
**Evidence bucket:** static only — `live-source` grep and tracked design docs. No ESP
readback, no runtime route exercised, no in-game proof.
**Companion:** `handoff/PDV_UX_MarkedTier_DesignBrief_2026-08-24.md`.

---

## 1. Argonian — `PDV_Notif_Argonian_SithisActivation_FullActivation`

**Resolved: the audit row was right. The threshold is live; the crossing is silent.**

`VoidActivationSignalsRequired = 3` (`PDV_Substrate_ArgonianHist.psc:25`), and
`IsVoidFullyActive()` (`:352-354`) gates on a `SithisSignalCount` accumulator.
`RecordVoidSignalScaled` (`:115-128`) increments that counter with
`AdjustIntValue(..., 1)` at `:124` and traces — it never reads the prior value, so
nothing detects the 2→3 crossing. The only other writes to the counter are a debug
setter (`PDV_DebugRuntime.psc:206`) and a reset to zero (`:392`). The substrate script
contains no Notification, MESG, or Prisma call at all; the count appears only inside a
developer trace string as `sithis=N/3` (`:376`).

The flip is not cosmetic. When it happens, void piety begins scoring to Sithis
(`PDV_OriginRuntime_Argonian.psc:841-842`). An entire scoring lane opens unannounced.

This is the strongest beat candidate found so far, ahead of the two Talos moments. The
Talos acts are self-evidently memorable — the player knows they hid a worshipper. This
one is a hidden accumulator: three is a small number, the player cannot see 2/3, and
Sithis can enter their story entirely unremarked. The historical draft already works
("a third way to make meaning in exile" is doing real work, since Hist, People and Void
are literally the three lanes), and the owner writes the final wording.

Implementation notes for whoever builds it, not design decisions: crossing detection must
compare before and after the increment rather than test the post-state, or it re-fires on
every later signal; and the reset path at `:392` must clear whatever "already announced"
flag is added, or the beat never fires again after a reset.

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
