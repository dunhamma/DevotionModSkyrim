# PDV_HO_PrismaBeatsCorrection -- revert offer beats to LOCKED copy + close 2 defects

**Created:** 2026-07-01
**Track:** CODING. Manager-owning lane (`PDV__ManagerQuest.psc` +
`PDV_DaedricPath_Hircine.psc`). Serialize per `PDV_PrismaParity_SerializedHandoffs.md`.
**Trigger:** Adversarial to-spec verification (2026-06-30) found 3 offer beats
wired to an UNAPPROVED reworded copy, 1 beat wired debug-only (production gap),
and 1 coding item open.

---

## Owner ruling (2026-07-01)

**`PDV_PrismaParity_AuthoringDraft.md` (LOCKED 2026-06-25) is the authoritative
copy.** The rewordings in `PDV_PrismaAuthoringBeats_Copy.md` (2026-06-30) are NOT
approved and must be reverted. Treat `PDV_PrismaAuthoringBeats_Copy.md` as
superseded for beats 1-3; do not wire from it.

Source-of-truth caution: line numbers below are from the 2026-06-30 verification
against `live-source\Scripts\Source\`. The live manager is untracked and the MO2
copy drifts -- re-grep each function by name and sync live-source -> MO2 before
editing. Keep all copy ASCII (the `.psc` hook enforces it).

---

## Fix 1 -- Beat 1 (commitment offer ACCEPT): revert to LOCKED per-race copy

Site: the shared accept handler feeding `ShowFormalCommitmentOffer` (production)
and `DebugAcceptPendingCommitment` (~`:13400`). Currently emits the 06-30 reword
`"You have given your devotion to {patron}. {patron} takes you as their own."` --
WRONG. Restore the LOCKED per-race strings (`{patron}` = runtime name slot):

| Race | Toast | Chronicle |
|---|---|---|
| Nord / Imperial | `{patron} has named you their own.` | `The broad faith narrows to one; {patron} has named you their own.` |
| Dunmer | `The ash-prayer has a name: {patron}.` | `The Reclamation deepens in you. You named {patron} as your focus.` |
| Altmer | `You name {patron} your focus.` | `The foundation narrows to a single disciplined road. You named {patron} your focus.` |
| Redguard | `You walk under {patron} now.` | `The sect's broad worship narrows to one charge. You took {patron} as your own.` |

(Nord + Imperial share the god-agent frame; the others are player-agent. Fix the
SHARED handler so production and debug both emit the locked strings.)

## Fix 2 -- Beat 2 (commitment offer REFUSE): revert to LOCKED per-race copy

Site: shared refuse handler feeding `DebugRefusePendingCommitment` (~`:13595`).
Currently `"You turn {patron} away."` (present tense) -- WRONG. Restore LOCKED:

| Race | Toast | Chronicle |
|---|---|---|
| Nord / Imperial | `You turned {patron} away.` | `The broad faith stays whole; you turned {patron} away, and {patron} will not ask again.` |
| Dunmer | `You set {patron} aside.` | `The Reclamation holds as it was. You set {patron} aside, and {patron} will not ask again.` |
| Altmer | `You keep to the foundation.` | `The foundation stands as it was. You kept to it alone, and {patron} will not ask again.` |
| Redguard | `You keep to the sect.` | `The sect's broad worship holds as it was. You set {patron}'s charge aside; {patron} will not ask again.` |

## Fix 3 -- Beat 3 (Altmer Thalmor-alignment band): revert to LOCKED copy

Sites: toast `MaybeSurfaceAltmerAlignmentBandChange` (~`:7558`), chronicle
`BuildReorientationJournalLine` (~`:2058`). Chronicle currently the 06-30 reword
`"Where you stand in the Thalmor question shifts: {band}."` -- WRONG. Restore
LOCKED (`{band}` = the committed band label):

- toast: `The Thalmor question turns in you: {band}.`
- chronicle: `Your soul records where you stand in the Thalmor question: {band}.`

---

## Fix 4 -- Beat 6 (Hircine renunciation): PRODUCTION GAP, wire into RenouncePath

The renunciation chronicle exists ONLY in the debug function
`DebugRenounceHircinePath` (`:13123`) -- it never fires in real gameplay. Wire the
LOCKED chronicle into the production `RenouncePath()` in
`PDV_DaedricPath_Hircine.psc` (~`:114`), where the toast + ledger already fire:

- chronicle (LOCKED): `Hircine's mark fades from your blood, and the pack is no longer yours.`

Use the same `AppendBookOfDaysEntry` shape as the other chronicle beats; guard
against double-log if a curse-state transition fires the same tick. Also correct
the debug function's string to match (it currently carries the 06-30 reword).

---

## Fix 5 -- Khajiit Champion pin (open coding item)

At the Khajiit Champion surface (~`:10637`, per the DecidedWorklist): pass
`headline=true` and append the tier band to the surfaceKey so the Khajiit Champion
chronicle is PINNED, matching every other race (currently prunable).

---

## Anti-recurrence

Add a one-line header to `PDV_PrismaAuthoringBeats_Copy.md` marking it
NON-AUTHORITATIVE for beats 1-3 and pointing to
`PDV_PrismaParity_AuthoringDraft.md` (LOCKED 2026-06-25) as the copy spec, so a
future wire does not re-adopt the reworded strings.

---

## Verify

1. `node tools/pdv_compile.mjs --script PDV__ManagerQuest` and
   `--script PDV_DaedricPath_Hircine` -> 0/0.
2. Grep live-source: each locked string above present at its production site; the
   06-30 reword strings gone (0 refs).
3. `node tools/pdv_prisma_ui_audit.mjs` -> PASS.
4. `node tools/pdv_verify.mjs` -> FAIL=0; `node tools/pdv_integrity_harness.mjs` -> PASS.
5. In-game (play-gated): accept/refuse an offer, cross an Altmer Thalmor band,
   renounce Hircine, reach Khajiit Champion -> confirm the locked toast + a PINNED
   chronicle entry appear for each, and the renunciation fires in normal play (not
   just via debug).

---

## Status of the rest (verified 2026-06-30, DONE-TO-SPEC -- do NOT touch)

Beats 4, 5, 7, 8, 9, 10 wired to locked copy. Group-1 coding: 12 of 13 done
(rival driver, Khajiit posture chronicle, emergence.onset both branches +
direction reconciled, neglect-recover, substrate.thin, Orc lapse toast, Altmer
crisis toast, Hircine residue toasts, Daedric boon toast, drift.warn retired).
Only Fix 5 (Khajiit Champion pin) remains open from Group 1.
