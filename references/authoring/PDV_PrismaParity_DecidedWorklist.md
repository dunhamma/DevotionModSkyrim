# PDV Prisma Parity -- Decided Worklist (execution handoff)

Owner-ratified 2026-06-25. Derived from `PDV_PrismaParityTriage.md` (triage ledger) +
`PDV_PrismaParityRegistry.csv` (75-row registry) + the orphan-beat archaeology. This is the
authoritative split for execution: **Codex owns coding; Claude + owner own authoring**
(Claude drafts -> owner approves).

## Ratified owner rulings
| # | Decision |
|---|---|
| R1 | 6f rites keep `Debug.Notification` (no Prisma overlay toast). They already surface in both Prisma spaces (Ledger + Chronicle). |
| R2 | Khajiit lunar-posture: chronicle the **severe** transitions (Corrupted/ShadowDrift) only. |
| R3 | Altmer crisis-state: **add** an immediate shift toast. |
| R4 | Breton druidic-fork: surface the **meaningful** forks (Betrayed/Werewolf), toast + pinned chronicle. |
| R5 | Commitment **refusal** (Rupture=1): **pinned milestone** (toast + pinned chronicle). Folds into Phase B. |
| R6 | Hircine stigma-price: **toast-only** for now (chronicle deferred to the consolidated Daedric BoD pass). |
| R7 | Hircine residue: **wire** (renderer built). |
| R8 | Daedric boon: **wire** the rite-answered producer (renderer built). |
| R9 | `drift.warn`: **RETIRE** (archaeology-confirmed superseded; dead-code deletion). |
| R10 | `substrate.thin`: **wire** (signal-equity loss/fraying path). |
| R11 | `emergence.onset`: **WIRE** (archaeology overturned the retire-default; it's the tone backing for the un-built quiet-emergence cues, and the formal-offer gate requires it). |

## Orphan-beat archaeology verdicts
- **drift.warn -- superseded -> RETIRE.** No `SurfaceTransition("drift")` callsite ever
  existed (git `-S` empty across all refs); authored producer-less in `9446f14` (2026-06-21);
  not among the 5 canonical transition classes. Pre-neglect space already covered by the
  neglect-drop toast (`PDV__ManagerQuest.psc:8806`) + `GetPanelDriftLabel` (`:2177`).
- **emergence.onset -- deferred -> WIRE (blocking).** Tone/copy specced 2026-06-02 (CoverageMap)
  + 2026-06-06 (ContentBank), shipped 2026-06-21; the callsite was always intended. The
  formal-offer gate (`tools/pdv_formal_offer_check.mjs:364-368 quietEmergenceSnippets`) keeps
  the offer build RED until the Khajiit/Breton emergence callsites exist.

## Codex code-fix queue (priority order)
Closed before this cleanup: `AwardCuratedSignalScaled` now passes `HumanizeCuratedSignalReason(...)`
into `AwardPiety`; see registry row `signal.curated-scaled`.

1. **[P1] Rivalry drain reason** -- pass a reason to `AwardPietyInternal` at `:17721` (residual
   `IsDashboardTrackedDeity` gate is acceptable).
2. **[P1] Khajiit lunar-posture chronicle** (R2) -- direct `AppendBookOfDaysEntry` at `:5342` for
   Corrupted/ShadowDrift (dawn-diff structurally can't catch posture).
3. **[Phase B / blocking] emergence.onset wire** (R11) -- add `GetKhajiitFocusDeity` +
   `GetBretonTraditionDeity` helpers and the two `SurfaceTransition("emergence", ...)` callsites
   required by `quietEmergenceSnippets`. **DIRECTION-TOKEN RECONCILIATION:** the gate snippet
   uses direction `"reach"` -> key `emergence.reach`, which misses the authored `emergence.onset`
   arms. **Emit direction `"onset"`** (bespoke copy exists) OR add `emergence.reach` arms to
   `JournalToneToTitle`/`JournalToneToValence` + the Khajiit/Breton `ResolveJournalLine`. If the
   gate's `"reach"` snippet is wrong, fix the gate to `"onset"`. Verify the journal line renders
   non-empty after wiring.
4. **[P2] substrate.thin** (R10) -- add a `phase="thin"` branch to `SendPrismaSubstrateProgress`
   when `tierAfter < tierBefore`; covers all substrate races' erosion.
5. **[P2] Hircine residue** (R7) -- `SendPrismaDaedricToast("Hircine","residue",...)` at onset
   (`PDV_DaedricPath_Hircine.psc:168`) + fade-clear in `UpdateResidueRecovery`.
6. **[P2] Daedric boon** (R8) -- `SendPrismaDaedricToast(prince,"boon",...)` at Daedric
   rite-completion (analogous to substrate "deepen").
7. **[P2] Khajiit champion-pin** -- pass `headline=true` + band suffix at `:10637`.
8. **[P2] Orc lapse-to-City toast** -- route `:5904` through `ApplyOrcLifeModeSwitch`.
9. **[P2] New-pact Daedric toast** -- add `SendPrismaEventToast("shift",...)` at `:2896`.
10. **[P2] Altmer crisis-state toast** (R3) -- `SendPrismaShiftToast` at `:7417`.
11. **[P2] 6f overlay toast** -- DECLINED per R1 (keep `Debug.Notification`). No action.
12. **[cleanup] drift.warn deletion** (R9) -- remove the `drift` branch (`:1773-1774`) + tone
    entries (`:15249`, `:15283`).

## Authoring queue (Claude drafts -> owner approves)
Copy beats; Codex wires them. Highest-leverage first (the offer beats unblock the Phase B pattern):
1. **Nord offer ACCEPT beat** (P1) -- "you have given your devotion to X" toast + pinned chronicle
   at `DebugAcceptPendingCommitment` (`:12256`). Also route carryover through a reason-bearing
   award (it currently bypasses `AwardPiety`).
2. **Nord offer REFUSE beat** (P1, R5) -- pinned milestone for the permanent door-closing.
3. **Altmer Thalmor-alignment** band toast + chronicle (P1) -- invisible to both surfaces today.
4. **Breton tradition** choice surfacing (P1) -- irreversible startup choice, pinned.
5. **Hircine werewolf-onset (curse-entry)** chronicle (P1).
6. **Hircine renunciation** chronicle (P1) -- toast + ledger present, chronicle absent.
7. **Redguard sect Champion-entry** chronicle (P1) -- toast present, chronicle absent.
8. **Argonian Hist-Adaptation** transformation milestone (P1) -- toast + chronicle absent (separate
   from the 6f rites; flagged by the 6f archaeology as a real standalone gap).
9. **Breton druidic-fork** surfacing (P2, R4) -- Betrayed/Werewolf.
10. **Bosmer path-confirm** chronicle (P2) -- toast + ledger present, chronicle absent.
11. **Phase B formal-offer scale-out** -- the 4-race offers (copy already authored, owner review)
    + the quiet-emergence cue lines (tie into the emergence.onset wire) + the 16 Daedric titles.

## No-action
39 rows verdicted already-correct / accept-as-is (see triage ledger appendix). drift.warn is the
only retire.
