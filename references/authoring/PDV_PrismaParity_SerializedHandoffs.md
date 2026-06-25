# PDV Prisma Parity -- Serialized Codex Handoffs (no-stop units + dispatch order)

Only the items Codex can run **continuously to a green gate** with no owner stop and no copy
dependency. Copy-gated work (the per-race beats, the offer.accept/refuse lines, the 16 Daedric
titles, hardening steps 2-3) is deliberately excluded -- it lands later as Unit D after the authoring
redline. Full per-item detail: `PDV_PrismaParity_CodexHandoff.md` + `PDV_HO_FormalOfferScaleOut_2026-06-25.md`
+ `PDV_HO_PrismaHardening.md`.

## Dispatch order (stay in sync)
Only **A** and **B** write `PDV__ManagerQuest.psc`, so they serialize (A then B). **C** is the native
bridge (separate surface) and runs parallel to both.

1. **Now, in parallel:** dispatch **A** + **C**. Different write surfaces (Papyrus vs C++/JS) -- no conflict.
2. **After A reports green:** dispatch **B** (serializes on the manager behind A). C may still be running -- fine.
3. **In parallel (Claude + owner):** lock the authoring-draft redline. When it's approved AND B is green,
   the copy-wiring becomes **Unit D** (next serialized manager pass -- not written yet).
4. **End:** ONE owner-gated in-game Prisma smoke covers A+B's new beats and C's hardening.

**Sync rule:** never two concurrent manager passes. Manager order is A -> B -> (future D); C is free in
parallel; Claude's authoring runs in parallel and merges as D. Sync live-source -> MO2 before each compile.

---

## HANDOFF A -- Parity code-fixes  (serialized #1; machine-gated; no owner stop)
All wiring; display text is renderer-side or mechanical. Edits `PDV__ManagerQuest.psc` (+ one Hircine
path file). Run the items in this order; they are independent edits to the same file.

1. **[P0] reason through `AwardCuratedSignalScaled`** -- `:2518`. Pass a `signalType`-derived non-empty
   reason to `AwardPiety`; extend `HumanizeDriverReason` cases as needed. (Clears 11 rows.)
2. **[P1] rivalry reason** -- `:17721` `AwardPietyInternal(...)` -> add `"rivalry with " + sourceDeity.DeityName`.
3. **[P1] substrate.thin branch** -- `SendPrismaSubstrateProgress` (~`:12808`): emit `phase="thin"` when `tierAfter < tierBefore`.
4. **[P2] Khajiit Champion pin** -- `:10637`: add `headline=true` + ` " " + GetPublicTierBand(TIER_CHAMPION)` to the surfaceKey.
5. **[P2] Orc lapse-to-City toast** -- `:5904`: route through `ApplyOrcLifeModeSwitch(ORC_LIFE_MODE_CITY, ...)`.
6. **[P2] new-pact Daedric toast** -- `:2896`: `SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")`.
7. **[P2] Hircine residue** -- `PDV_DaedricPath_Hircine.psc:168` onset toast + `~:161` fade-clear (renderer built).
8. **[P2] Daedric boon** -- `SendPrismaDaedricToast(princeName,"boon",...)` at Daedric rite-completion (renderer built).
9. **[cleanup] drift.warn deletion** -- remove `:1773-1774` branch + `:15249` + `:15283` tone entries.

**Acceptance (no stop):** `pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> `pdv_ledger_coverage_audit` clean
(and a scaled-curated award now records a driver) -> `pdv_integrity_harness` PASS.

---

## HANDOFF B -- Phase B offer scale-out, STRUCTURAL  (serialized #2, after A; gate = `pdv_formal_offer_check`)
Build to `PDV_HO_FormalOfferScaleOut_2026-06-25.md` **sections 1-6**. Two carve-outs keep it no-stop:

- **Emergence (sec 6): emit direction `"onset"`**, not `"reach"` -- it resolves to the EXISTING authored
  `emergence.onset` tone arms (the archaeology confirmed they're already written), so no new copy and the
  journal line renders non-empty. Add `GetKhajiitFocusDeity` / `GetBretonTraditionDeity` helpers + the two
  callsites. If the gate snippet pins `"reach"`, update the gate to `"onset"`.
- **Offer-cadence simplification (this pass -- owner ruling):** replace the timer-based re-offer with
  **one offer per qualification**. Each deity offers ONCE when it first crosses
  `COMMITMENT_OFFER_THRESHOLD` (+ the recent-signal gate); set a per-deity "offered" guard at
  `ShowFormalCommitmentOffer`. Add `!alreadyOffered(deity)` + `!isRefused(deity)` to
  `IsEligibleForFormalCommitmentOffer` and DROP the cooldown check; **delete** the escalating-cooldown /
  `DeclineCount` logic (`ApplyCommitmentDeclineCooldown` / `ApplyCommitmentRefuseCooldown`).
  **Not yet** clears nothing permanent -- clear the per-deity "offered" guard when piety falls back below
  the threshold, so a genuine re-qualification (lapse + rebuild) re-offers. **Refuse** sets a per-deity
  refused flag (replace the inert global `PDV.Commitment.Rupture` with a per-deity key) that eligibility
  reads -> that god never offers again, even after a re-qualification. This is what makes the
  "{patron} will not ask again" copy true.
- **EXCLUDE from this pass (copy-gated -> Unit D):** (a) the `offer.accept`/`offer.refuse` journal lines --
  wire the `DispatchDiegeticCue("offer",...,"accept"/"present")` CALLS (the gate needs the call to exist; the
  line resolves empty until the approved copy lands), but do NOT author the lines here; (b) **section 7, the
  16 Daedric titles** -- that is a separate Mutagen title run on approved copy, not part of this gate.

**Acceptance (no stop):** `pdv_formal_offer_check.mjs` PASS (source + ESP readback) -> `pdv_signal_e2e_gate`
0 RED -> `pdv_integrity_harness` PASS.

---

## HANDOFF C -- Prisma hardening: prereq + accessibility  (native track; parallel to A/B)
Build to `PDV_HO_PrismaHardening.md` **prerequisite + step 1 only**. Separate surface
(`native/DevotionPrismaBridge/` + `mod/PrismaUI/views/Devotion/`), no manager/ESP conflict.

- **Prereq:** verify the deployed bridge carries the cold-view focus-trap fix `5301ec0`; if the 2026-06-25
  rebuild covered it, confirm `DevotionPrismaBridge.log` clean + ESC always releases on a cold panel. Else
  xmake rebuild + redeploy.
- **Step 1 Accessibility:** `aria-live="polite"` on `#pdv-toasts`; keyboard nav + visible focus on tabs and
  the startup/journal overlays; focus-trap + guaranteed ESC (reuse the `g_panelFocusPending` defer-to-`OnDomReady`
  discipline); contrast + text scaling. (reduced-motion already done.)

**Hold for Unit D / surfacing-landed:** steps 2 (payload contract: stabilize the `daedric`/`substrate`/new
beat shapes) and 3 (visual/contrast pass) -- both need the parity surfacing to land first.

**Acceptance (no stop for the build):** xmake builds clean; view loads in local preview with no console
errors. Owner in-game Prisma smoke converges into the single end-of-line proof.

---

## NOT in these units (gated -- for awareness)
- **Unit D (future, serialized manager pass after B):** wire the redlined per-race beats --
  `offer.accept`/`offer.refuse`, the 8 chronicle beats, Khajiit lunar chronicle, Altmer crisis toast,
  the carryover-through-`AwardPiety`, plus the 16 Daedric titles + hardening steps 2-3.
- **In-game proof:** owner-gated, one consolidated pass at the end.
