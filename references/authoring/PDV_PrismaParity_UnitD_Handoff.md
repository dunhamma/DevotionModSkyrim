# Unit D -- Copy-Wiring Pass (Codex)

## Context
The parity code-fixes (`b6d18da`), offer scale-out structural, and offer-cadence (`f97b7db`) are committed.
The authoring copy is now LOCKED in `PDV_PrismaParity_AuthoringDraft.md` (beats 1-14 + 16 Daedric titles).
This pass wires that copy. Serialized manager pass (run after the cadence commit, which it is).

## Architecture
- **Per-race chronicle (Book of Days) lines** route through new `ResolveJournalLine` tone keys in
  `PDV_DiegeticDirector.psc` (mirror the existing Khajiit/Dunmer/Imperial/Altmer bespoke functions; the
  6g handoff added that ladder). One tone key per beat; per-race arms carry the locked copy.
- **Toasts** fire at the named site (`SurfaceTransition` / `SendPrismaShiftToast` / the existing cue).
- **Where a toast already exists**, add ONLY the `AppendBookOfDaysEntry` (chronicle). Pin (`headline=true`)
  the milestones (offers, tradition, adaptation); leave routine beats unpinned.
- Copy is verbatim from `AuthoringDraft.md` (ASCII, slots like `{patron}`/`{band}` filled at runtime).

## Per-beat wiring
| Beat (copy ref) | Surfaces to add | Fire site (function) | Tone key / notes |
|---|---|---|---|
| **1 offer.accept** (#1) | pinned chronicle (the `accept` cue already fires) | `DebugAcceptPendingCommitment` + `ResolveJournalLine` | `offer.accept`; per-race (Nord+Imperial shared, Dunmer, Altmer, Redguard) |
| **2 offer.refuse** (#2) | toast + pinned chronicle | `DebugRefusePendingCommitment` (add a `DispatchDiegeticCue("offer",...,"refuse",...)` + chronicle) | `offer.refuse`; per-race |
| **+ carryover fix** | -- | `DebugAcceptPendingCommitment`: the carryover currently uses `DebugForceSetPietyByIndex` (bypasses the funnel) -> route it through a **reason-bearing `AwardPiety`** so the carryover lands a Ledger driver | -- |
| **4 Altmer alignment** (#4) | toast + chronicle | the committed band-change site (off `ApplyAltmerAlignmentAction` -> `PDV_ThalmorAlignmentTrack`); fire on the COMMITTED band-label change, not the raw value | `reorientation` (Altmer alignment arm) |
| **5 Breton tradition** (#5) | toast + pinned chronicle | `ApplyBretonInitialChoice` | `reorientation` (Breton tradition arm) |
| **6 Hircine werewolf-onset** (#6) | chronicle (toast already via race-response MESG) | the curse-entry site in `PDV_DaedricPath_Hircine.psc` (`HandleCurseTransition`, werewolf onset) | `curse.onset` Hircine arm |
| **7 Hircine renunciation** (#7) | chronicle (toast + ledger already present) | `RenouncePath` (Hircine) | new `renounce` tone or direct `AppendBookOfDaysEntry` |
| **8 Redguard sect-entry** (#8) | chronicle (toast already via sect-entry MESG) | `MaybeShowRedguardChampionEntry` (per sect: Crown/Forebear/Ash'abah) | direct `AppendBookOfDaysEntry` per sect |
| **9 Argonian Hist-Adaptation** (#9) | toast + pinned chronicle | `ApplyArgonianAdaptation` | new milestone surface (currently Debug.Notification only) |
| **10 Breton druidic-fork** (#10) | toast + chronicle (Betrayed/Werewolf only) | `SetBretonDruidicFork` (guard old!=new; only the two meaningful forks) | per-fork |
| **11 Bosmer path-confirm** (#11) | chronicle (toast + ledger already present) | `ConfirmBosmerPendingTransition` | direct `AppendBookOfDaysEntry` |
| **13 Khajiit lunar-posture** (#13) | chronicle (severe only) | `RefreshKhajiitLunarPosture` (Corrupted / ShadowDrift) | direct `AppendBookOfDaysEntry` at the posture-change |
| **14 Altmer crisis-state** (#14) | toast | `SetAltmerCrisisState` (fire on transition INTO a crisis state; clear-to-None stays silent) | `SendPrismaShiftToast` |
| **12 Daedric titles** (#12) | MESG title (16) | clone `tools/pdv-nord-offer-author` (title edit only) -> set each Daedric offer MESG title to the epithet | bodies unchanged |

Emit-site detail (exact lines shift per commit) is in `PDV_PrismaParityRegistry.csv` (`emit_site_hint`) and
`PDV_PrismaParityTriage.md`; reference function names above, not stale line numbers.

## Acceptance
Sync live-source -> MO2, then: `pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> `pdv_formal_offer_check` still PASS
-> `pdv_integrity_harness` PASS. Trace-check: each new beat's journal line renders **non-empty** (the
emergence-style suffix/token trap -- confirm the tone key resolves to a real arm, not "").
In-game proof is owner-gated (one consolidated Prisma smoke at the end).

## Not in this pass
Prisma hardening steps 2-3 (payload contract + visual pass) -- native track, run after these surfaces land.
