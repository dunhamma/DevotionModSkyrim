# M3 — Feasibility Assessment (LD-P1 mechanisms)

**Status:** COMPLETE as *source-grounded* feasibility.
**Important honesty caveat:** this research environment has **no Creation Kit and
no Skyrim runtime**, so this is **not** QASmoke/in-game proof. Every path below is
traced to a real (often **live**) function in the PDV source; each entry ends with
the specific **in-CK/in-game proof still required** — the hand-off to a future
runtime session, in PDV's counted-proof style.

**Headline:** every LD-P1 mechanism resolves to *recomposition of shipping PDV
code*. Six of six have a live or skeletal in-repo precedent. No greenfield
subsystem is required for the engine MVP.

---

## Spike 1 — Mood EWMA + bands (B1) · confidence HIGH
- **Seam (live):** `RunDawnConsolidateScratch()` (`PDV__ManagerQuest.psc:2951`) already computes per-deity `clampedToday` (the ±`PIETY_DAILY_MAX_DELTA` daily net stance-adjusted delta) at `:2964`, just before zeroing `PietyToday` at `:2972`.
- **Cheapest path:** fold a mood recompute into that same per-deity loop (read the existing `clampedToday` local): `MoodNew = Clamp(alpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-alpha)*MoodOld, -100,100)`; write `PDV.Mood.<deityForm>`; recompute band; record old→new band for crossing detection. ~30 lines, one new dawn sub-phase `RunDawnUpdateMood()`.
- **In-repo precedent:** the dawn piety consolidation itself; the per-deity `StorageUtil` float pattern (`PDV.Piety`, `PDV.PietyToday`).
- **In-game proof still required:** (1) `PDV.Mood.*` persists across save/load (StorageUtil persists by design — confirm); (2) band value matches expected after seeded `clampedToday` sequences (QASmoke); (3) no perf regression on the all-deity dawn loop (42 deities × one float op — negligible).

## Spike 2 — Active patron pool filter (Hades) · confidence HIGH
- **Seam (live):** `IsEligibleForFormalCommitmentOffer()` (`:5320`) already gates on `HasRecentCommitmentSignalDays(deity, 2, 7)` (`:5337`), and `RecordCommitmentSignalDay()` is written on every positive award (`AwardPietyInternal:3416`).
- **Cheapest path:** pool membership = `active patron` ∪ `deities with recent signal days` ∪ `cursed-path deities`. Reuse `HasRecentCommitmentSignalDays`. Non-pool deities are skipped by the demand/omen eligibility check.
- **In-repo precedent:** the commitment-offer eligibility computation is exactly this query.
- **In-game proof still required:** confirm pool size stays ≤ ~4 under realistic play; confirm dormant deities go silent.

## Spike 3 — Demand scheduler (A1) · confidence HIGH (1:1 mirror)
- **Seam (live):** the commitment-offer engine — `RunDawnProcessCommitmentOffers()` (`:3077`) → `EvaluateFormalCommitmentOffer()` (`:5249`) → `GetBestFormalCommitmentOfferCandidate()` (`:5296`) → eligibility (`:5320`); state lives in the `PDV.Commitment.*` namespace with an `OfferedAt` timestamp (`:5268`) and `PendingDeityIndex`.
- **Cheapest path:** add `RunDawnProcessDemands()` mirroring `RunDawnProcessCommitmentOffers()`. New `PDV.Demand.<deityForm>.{Pending,Type,OfferedAt,ExpiresAt}` namespace. Eligibility = band-crossed-downward (or expectation-meter red) + on-cooldown + not-already-pending. **Fulfillment**: hook the existing act-tag routing in `ApplyQuestReaction`/`AwardPiety` — when an act matching the demanded tag fires for that deity, mark fulfilled + single-act-reset. **Expiry**: in dawn, if `now > ExpiresAt` and unfulfilled → mood penalty / displeasure-stage bump.
- **In-repo precedent:** the entire commitment-offer subsystem (proven live; Kyne path).
- **In-game proof still required:** (1) a player-facing demand surface (MessageBox/MCM/Prisma toast — the toast channel is live, Spike 4); (2) fulfillment-detection wiring per act-tag fires once and resets; (3) expiry penalty applies exactly once; (4) `PDV.Demand.*` persists across save/load.

## Spike 4 — Omen dispatch (A2) · confidence HIGH (toasts) / DEFERRED (rich director)
- **Seam (live):** `SendPrismaEventToast(eventType, deity, ...)` is **already firing** for `"neglect"` (`:3071`), `"dawn"` (`:3087`), and `"favor"` (`AwardPietyInternal:3424`). The player-event side already hooks `OnSleepStart` (`PDV_PlayerEvents.psc:106`) and `OnWeatherChange` (`:164`).
- **Cheapest path (LD-P1):** add `"mood_up"`/`"mood_down"`/`"demand"` event types to the **live** `SendPrismaEventToast` path, fired on band-cross from `RunDawnUpdateMood()`. Dream omens ride the existing `OnSleepStart` hook with a probability roll (SoT pattern). All gated by pool + `ScoreRepeatableAction`-style cooldown + MCM density.
- **Honest dependency:** the richer `PDV_DiegeticDirector.Dispatch()` (weather shifts, body-marks, prayer anims, ambient world-state à la Black & White) is **specced but not yet built** (Codex track, per `handoff/PDV_DiegeticUX_CodexHandoff.md`). Those omen modalities are **LD-P2** and depend on the director being implemented first. **LD-P1 omens do not need it** — they ride the live toast + dream channels.
- **In-game proof still required:** toast fires once per band-cross (not per dawn); dream-omen probability + cooldown feel; degrades cleanly when Prisma absent (fallback to `Debug.Notification`).

## Spike 5 — Mood-scaled boon (A4) · confidence HIGH
- **Seam (live):** `SyncPatronBoonsToTier(tierValue)` (`PDV_DeityBase.psc:228`) already does the `RemoveSpell`→`AddSpell` band-swap (via `ClearAllBoons` + tier-gated `AddSpell`).
- **Cheapest path:** **band-indexed boon variants** swapped on mood-band-cross, mirroring the tier swap exactly (this is also the Sacrosanct/Growl staged-bundle model). E.g. `Boon_Devoted_Pleased` vs `Boon_Devoted_Exalted` differ in MGEF magnitude. This **avoids** the engine limitation that an already-applied MGEF can't re-read a global at runtime — instead we re-grant the band-appropriate variant on transition, which is the proven pattern. Respects the one-active-boost + family-cap guardrails (the swap removes the prior variant first).
- **In-repo precedent:** `SyncPatronBoonsToTier` + `ClearAllBoons` (live).
- **In-game proof still required:** band-swap fires only on crossing (not every dawn); no boon stacking; magnitude variants author cleanly per band per deity.

## Spike 6 — A3 clutch-save intervention · confidence HIGH (prototype exists in-repo!)
- **Seam (live skeleton):** `PDV_T3DailyLowHealthSaveEffect.psc` — a constant-effect `ActiveMagicEffect` that watches `GetActorValuePercentage("Health")` on a `RegisterForSingleUpdate(2.0)` poll and, below `TriggerHealthPercent` (0.10), calls `TryApplyDailySave()` which `RestoreActorValue("Health", 75.0)` **once per day** via a `StorageUtil` day-key. This *is* the clutch-save intervention, already written.
- **Cheapest path:** gate the existing save on `mood >= Pleased` (read via the global mirror), theme it per deity (Kyne: heal + a gust knockback; Hircine: heal + bestial vigor), and route the moment through a `Marked`-tier toast ("Kyne steadies your hand"). The daily-cap anti-spam is already present. Optionally swap the poll for the **Andromeda conditioned-MGEF** variant (`IsInCombat && Health%<0.15` native conditions) for a zero-script combat-only version.
- **In-repo precedent:** the entire `PDV_T3DailyLowHealthSaveEffect.psc` file.
- **In-game proof still required:** mood-gate + deity theming fire correctly; once-per-day across save/load; `Marked` dispatch shows once; (if conditioned-MGEF variant) condition stack evaluates as expected.

---

## Feasibility verdict
| LD-P1 mechanism | In-repo precedent | Confidence | Greenfield? |
|---|---|:-:|:-:|
| Mood EWMA + bands | dawn consolidation + StorageUtil floats | HIGH | minimal (1 sub-phase) |
| Patron pool | commitment eligibility query | HIGH | none |
| Demand scheduler | commitment-offer engine | HIGH | new `PDV.Demand.*` namespace only |
| Omen (toast + dream) | live `SendPrismaEventToast`, `OnSleepStart` | HIGH | none |
| Mood-scaled boon | `SyncPatronBoonsToTier` band-swap | HIGH | band-variant authoring |
| Clutch-save (A3) | `PDV_T3DailyLowHealthSaveEffect.psc` | HIGH | mood-gate + theming |

**Conclusion:** the LD-P1 engine MVP is buildable as recomposition of existing,
mostly-live PDV code on a Vanilla/PO3 footprint. No spike was demoted to backlog
for infeasibility. The remaining unknowns are all **runtime-verification** items
(persistence, fire-once semantics, perf, spam-feel), appropriate for an in-CK/
in-game proof session — they do not change the architecture.
