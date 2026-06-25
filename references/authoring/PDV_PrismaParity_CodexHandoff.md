# PDV Prisma Parity + Phase B -- Codex Handoff

Coding work only (Claude owns the copy; see `PDV_PrismaParity_AuthoringDraft.md`). Source-of-truth
for verdicts: `PDV_PrismaParity_DecidedWorklist.md`. Owner rulings R1-R11 are ratified.

**Standard acceptance per batch:** sync live-source -> MO2 first, then
`node tools/pdv_compile.mjs` 0/0 -> `node tools/pdv_verify.mjs` FAIL=0 -> the batch's named gate ->
`node tools/pdv_integrity_harness.mjs` PASS. New save for any VMAD/record change (props bake at init).

---

## BATCH 1 -- Ready now (pure wiring, no copy dependency)
Display text is either renderer-side (app.js) or mechanical; safe to start immediately.

Closed before this cleanup: `AwardCuratedSignalScaled` already routes through
`HumanizeCuratedSignalReason(...)`; keep `pdv_ledger_coverage_audit` green while landing the remaining paths.

1. **[P1] Rivalry-drain reason** -- `:17721` `AwardPietyInternal(rivalDeity, rivalAmount, False)` -> pass
   a reason (e.g. `"rivalry with " + sourceDeity.DeityName`). Residual `IsDashboardTrackedDeity` gate is acceptable.
2. **[P1] substrate.thin** -- add a `phase="thin"` branch to `SendPrismaSubstrateProgress` (~`:12808`)
   when `tierAfter < tierBefore`. Renderer already handles `substrate_thin`. Covers all substrate races.
3. **[P2] Khajiit Champion chronicle pin** -- `:10637` `SurfaceTransition(...)` passes only 5 args; add
   `headline=true` + append `" " + GetPublicTierBand(TIER_CHAMPION)` to the surfaceKey so it pins like every other race.
4. **[P2] Orc lapse-to-City toast** -- route the 14-day lapse at `:5904` through `ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, ...)` instead of `SetState` direct, so it toasts.
5. **[P2] New-pact Daedric toast** -- at `:2896` add `SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")` beside the existing pinned chronicle.
6. **[P2] Hircine residue** -- `PDV_DaedricPath_Hircine.psc:168` `BeginNordResidueRecovery` -> `SendPrismaDaedricToast("Hircine","residue",...,"hircine")` at onset; fade-clear in `UpdateResidueRecovery` (~`:161`). Renderer is built.
7. **[P2] Daedric boon** -- add `SendPrismaDaedricToast(princeName,"boon",...)` at Daedric rite-completion (e.g. `RecordHuntRiteScaled` / `HandleDaedricPrinceSignal` rite path). Renderer is built.
8. **[cleanup] drift.warn deletion** (R9) -- remove the dead `drift` branch in `TransitionToneKey`
   (`:1773-1774`) + the orphaned entries in `JournalToneToTitle` (`:15249`) and `JournalToneToValence` (`:15283`).

---

## BATCH 2 -- Phase B formal-offer scale-out (structural; offer records already authored)
The 30 offer records' copy is locked in `PDV_FormalOffer_RecordWave.spec.json`; this is the wiring.
Full spec: `PDV_HO_FormalOfferScaleOut_2026-06-25.md`. **Gate:** `node tools/pdv_formal_offer_check.mjs` PASS.

10. **Author the 30 records** -- `dotnet run --project tools/pdv-phase20-race-author -- --author-rewards --rewards-spec references/authoring/PDV_FormalOffer_RecordWave.spec.json --esp <Devotion.esp>`.
11. **Manager props + race-aware dispatch + eligibility** -- declare the 30 `Message Property` lines (~`:465`);
    rename Nord body to `GetNordFormalCommitmentOfferMessage`, dispatch `GetFormalCommitmentOfferMessage`
    by `GetPlayerOriginRaceIndex()` to 5 per-race functions; `UsesFormalCommitmentOffersForDeity` returns
    the OR of 5 `Is*OfferEligibleDeity` helpers (+ `IsImperialTalosOfferAllowed()` gated on
    `PDV_ConcordatStandingTrack.GetValue() <= 50`). Rosters in `pdv_formal_offer_check.mjs`.
12. **`DispatchDiegeticCue`** -- add the function (mirror `SurfaceTransition` -> DiegeticDirector) + the
    `present`/`accept` calls in `ShowFormalCommitmentOffer`.
13. **Quiet-emergence wiring** -- add `GetKhajiitFocusDeity` + `GetBretonTraditionDeity` helpers and the
    `SurfaceTransition("emergence", ...)` callsites required by `quietEmergenceSnippets`.
    **DIRECTION-TOKEN RECONCILIATION (critical):** the gate snippet uses direction `"reach"` -> key
    `emergence.reach`, which MISSES the authored `emergence.onset` arms. **Emit direction `"onset"`**
    (copy exists) or add `emergence.reach` arms; if the gate's `"reach"` is wrong, fix the gate to `"onset"`.
    Verify the journal line renders non-empty after wiring.
14. **Daedric titles (16)** -- set each Daedric offer MESG **title** to the Prince name (bodies unchanged)
    via a clone of `tools/pdv-nord-offer-author` (title edit only). Copy = `AuthoringDraft.md` beat 12 (pending redline).

---

## BATCH 3 -- Copy-dependent (wire AFTER the owner approves `PDV_PrismaParity_AuthoringDraft.md`)
All of these route per-race lines through new `ResolveJournalLine` tone keys (mirror the existing
Khajiit/Dunmer/Imperial/Altmer bespoke functions) + the named toast site.

15. **Offer accept/refuse beats** -- new tone keys `offer.accept` / `offer.refuse`, per-race bespoke
    (AuthoringDraft beats 1-2), fired at `DebugAcceptPendingCommitment` (`:12256`) and
    `DebugRefusePendingCommitment`. **Also: route the accept carryover through a reason-bearing
    `AwardPiety`** (it currently bypasses the funnel, so the carryover never lands a driver).
16. **Per-race chronicle beats** (AuthoringDraft 4-11): Altmer Thalmor-alignment band, Breton tradition,
    Hircine werewolf-onset, Hircine renunciation, Redguard sect Champion-entry (x3), Argonian Hist-Adaptation,
    Breton druidic-fork (Betrayed/Werewolf), Bosmer path-confirm.
17. **Two small copy lines NOT yet in the draft** (I'll add to the redline; draft text):
    - **Khajiit lunar-posture chronicle** (P1, R2; severe only) -- direct `AppendBookOfDaysEntry` at `:5342`.
      Draft: Corrupted -> `The moons curdled over your road. A corruption is on you now.`;
      ShadowDrift -> `You slipped into the moons' shadow. The dark road has you.`
    - **Altmer crisis-state toast** (P2, R3) -- `SendPrismaShiftToast` at `:7417`.
      Draft (provisional labels): `The old line strains: {crisis}.`

---

## BATCH 4 -- Prisma UI hardening (NATIVE track, parallel, owner-gated)
Separate write surface -- C++/JS under `native/DevotionPrismaBridge/` + `mod/PrismaUI/views/Devotion/`;
**no conflict** with Batches 1-3 (Papyrus/ESP), dispatch as its own queue. A real 1.0 gate
(v3 Section 25.6 "UI live"), not optional polish. Spec: `PDV_HO_PrismaHardening.md`.

**Prerequisite:** verify the deployed bridge already includes the cold-view focus-trap fix (`5301ec0`);
the 2026-06-25 rebuild likely covered it -- confirm `DevotionPrismaBridge.log` clean + ESC always
releases on a cold/first-open panel. If not, xmake rebuild + redeploy (portable xmake per the bridge-build note).

**Start now (independent of the parity surfacing):**
- **Step 1 Accessibility** -- `aria-live="polite"` on `#pdv-toasts`; keyboard nav + visible focus on the
  tabs and the startup/journal overlays; focus-trap + guaranteed ESC (reuse the `g_panelFocusPending`
  defer-to-`OnDomReady` discipline); contrast + text scaling. (reduced-motion already done.)

**Sequence AFTER the parity surfacing (Batches 1-3 define the payload shapes):**
- **Step 2 Payload contract cleanup** -- mark every toast/panel field `stable | prototype | deprecated`
  + document in the bridge README. **COORDINATION:** Batches 1-3 promote `daedric` / `substrate` / the
  new `offer`+`emergence`+`residue`+`boon` payloads out of prototype -- stabilize + document THOSE shapes
  here. Do not freeze the contract until Batch 3's beats land.
- **Step 3 Visual system pass** -- tone colors (good/neutral/warning), spacing, symbols, overlay
  readability over busy game backgrounds -- across the FULL surface set incl. the new beats (so it isn't redone).
- **Step 4 Runtime routing expansion** -- extend (don't bypass) the `recentToastKeys` anti-spam guard;
  respect the Section 16.5 quiet bar (routine per-act scoring must not become toast spam). Coordinate with the Batch 1-3 toasts.
- **Step 5 Smoke alignment** -- keep local preview, `scratch/DevotionPrismaDemo.html`, and the in-game smoke aligned.

**Proof (owner-gated -- converge with the parity in-game proof into ONE pass):** panel opens
patron/today/debug clean; the new beats render with good contrast over busy backgrounds; no spam;
ESC always escapes; `DevotionPrismaBridge.log` clean.

---

## Cross-cutting notes
- The scaled-curated empty-reason root cause is already closed; keep the ledger coverage audit green while working on the remaining reason-bearing paths.
- New save required for the offer records (VMAD props bake at first init).
- Declined: 6f overlay toast (R1 -- keep `Debug.Notification`).
- `coc` skips location triggers; the in-game proof is owner-gated (Anvil fresh save).
