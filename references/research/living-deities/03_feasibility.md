# M3 — Feasibility Assessment (LD-P1 mechanisms)

**Status:** REVISED in-the-loop 2026-06-10. Supersedes the autonomous 2026-06-09
draft, which was authored overnight on defaults and never checked against live
source. This pass verified every cited seam against the **live** source tree
(`D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`, `PDV__ManagerQuest.psc`
= 10,197 lines, `PDV_DeityBase.psc` = 395 lines) and corrected the defects the
audit found. See the changelog at the bottom.

**Important honesty caveat (unchanged):** this research still has **no Creation Kit
and no Skyrim runtime**, so this is **not** QASmoke/in-game proof. Every path below
is traced to a real (often **live**) function in the PDV source; each entry ends
with the specific **in-CK/in-game proof still required** — the hand-off to a future
runtime session, in PDV's counted-proof style.

**Headline (revised):** five of the six LD-P1 mechanisms resolve to *recomposition
of shipping PDV code* and are HIGH-confidence for **Kyne** today. The **Hircine**
half of the pilot is **not** pure recomposition: Hircine exists only as a
transgressive *path* actor, not a deity, so LD-P1 carries exactly **one piece of
genuinely new authoring — a curse-gated `PDV_Deity_Hircine` deity actor** (Spike 0).
Once that actor exists, the same five mechanisms apply to it unchanged. The
day-to-day faucet that feeds mood is also **narrower than the 2026-06-09 draft
assumed** (Kyne combat-only today; the non-combat vocabulary is unbuilt) — that does
not block LD-P1 but it bounds how lively mood feels at first. Honest verdict:
**buildable, but with one new actor + one faucet-breadth dependency the prior draft
silently assumed away.**

---

## Grounding constants (corrected against live source)
| Constant | Live value | Source |
|---|---|---|
| `PIETY_DAILY_MAX_DELTA` | **4.3** (the 2026-06-09 draft wrongly said 5.0) | `PDV__ManagerQuest.psc:313` |
| `GAIN_RATE_SCALE` | 1.32 | `PDV__ManagerQuest.psc:317` |
| Tiers (Seeker/Devoted/Champion) | 25 / 50 / 85 | `PDV_DeityBase` |

> **Mood normalization uses 4.3, not 5.0.** `dailyContribution = clampedToday /
> PIETY_DAILY_MAX_DELTA * 100`. Implement it symbolically (reference the property,
> never a literal) so it tracks any future retune. Pacing claims below are
> recomputed against 4.3: at sustained max daily signal, Kyne (`alpha 0.12`) reaches
> Exalted (+55) in ~6 days and has a ~5.4-day impression half-life; Hircine
> (`alpha 0.22`) reaches Wroth (−40) in ~2–3 days, ~2.8-day half-life.

> **Line numbers drift.** All `:NNNN` references in the 2026-06-09 M2/M3/M4 drafts
> were taken from an ~8,977-line snapshot; live is 10,197 lines (`ProcessDawn`
> moved `:2932 → :3877`) and `PDV__ManagerQuest.psc` was edited again 2026-06-10
> (`.bak_v2b_20260610`). Treat function **names** as the contract, not line numbers.

---

## Spike 0 — NEW: the `PDV_Deity_Hircine` actor (the only greenfield in LD-P1) · confidence MEDIUM-HIGH
**Why this spike exists:** the 2026-06-09 draft picked Kyne **and Hircine** as the
pilot and asserted "6 of 6 mechanisms = recomposition, no greenfield." That is false
for Hircine. Live source has **only** `PDV_DaedricPath_Hircine extends
PDV_DaedricPathBase` — a transgressive-cult *path* actor (commitment-signal + stigma
model). There is **no `PDV_Deity_Hircine`**, and the path actor does **not** inherit
the `PDV_DeityBase` machinery every LD-P1 mechanism builds on (`clampedToday` mood
input, `SyncPatronBoonsToTier`, `ScoreFromTable`, tier boons). The dawn consolidation
loop iterates `PDV_FLST_AllDeities` (`PDV_DeityBase` forms only), so Hircine-the-path
never even gets a `clampedToday` computed.

**Owner ruling (2026-06-10):** *Keep Hircine; build a `PDV_Deity_Hircine`.*

**Design — curse-gated deity face (reconciles §8.2 of the likes/dislikes matrix):**
Making Hircine a normal always-on deity would reintroduce exactly the drift §8.2
forbids (a stray beast-kill must not pull a non-werewolf toward Hircine). So the new
deity face is **gated on the open werewolf curse**:
- New `PDV_Deity_Hircine extends PDV_DeityBase`, cloned from the `PDV_Deity_Kyne`
  shell. Registered in `PDV_FLST_AllDeities`.
- Its `ScoreAction(...)` (and therefore its `clampedToday` mood input) returns 0 and
  it is skipped for omen/demand eligibility **unless `PDV_CurseState.IsWerewolf()`**
  (live: `PDV_CurseState.psc:60`, mirrored to the CK-readable global
  `PDV_GLO_CurseState`). This mirrors the path actor's existing
  `HasCommitmentSignalGateOpen()` gate.
- The existing `PDV_DaedricPath_Hircine` is **retained unchanged** as the onboarding
  / stigma / cure layer. The deity face is the *post-curse worship + mood* layer. Two
  faces, clean division — the same race-relative two-face pattern §8.3 already uses.
- Activation/deactivation rides the existing `HandleCurseTransition(oldState,
  newState, reason)` hook (live: `PDV_DaedricPath_Hircine.psc:60`): werewolf→none
  decays/zeros the deity-face mood via the path's residue-recovery pattern.

**Critical authoring rule (the masking lesson, likes/dislikes §10.2):** the new
deity's `ScoreAction` **must** `return ScoreFromTable(eventType)` (after the curse
gate), exactly like `PDV_Deity_Kyne`. A `return 0.0` stub silently masks the
data-driven base and its table rows are dead.

**Cost (honest, not "recomposition"):**
- 1 new Papyrus script (`PDV_Deity_Hircine.psc`, ~clone of Kyne ~60 lines + curse gate).
- 1 new QUST/deity actor record + `PDV_FLST_AllDeities` membership (CK).
- Stance-matrix rows for Hircine (curse-gated NATIVE-equivalent; FOREIGN/TABOO otherwise).
- Like/dislike (`PDV.LD.*`) rows for Hircine's hunt acts (the Hircine block in the
  matrix doc §7 is currently "V2 reference only" — it must be promoted + tuned).
- `Boon_<tier>_<band>` records for Hircine (Spike 5) + the clutch-save (Spike 6).

**In-game proof still required:** (1) deity face scores **only** while werewolf and
goes silent (scores 0) when cured; (2) no double-fire between the path's
commitment-signal transitions and the deity face's mood crossings (the existing
"coordinate with curse rows, don't double-fire curse transitions" rule, matrix §8.4);
(3) new actor appears once in `PDV_FLST_AllDeities` with no verifier regression;
(4) `ScoreAction` delegates (not stubbed) — confirm a beast-kill-while-werewolf moves
Hircine's `clampedToday`.

---

## Spike 1 — Mood EWMA + bands (B1) · confidence HIGH (Kyne) / gated-on-Spike-0 (Hircine)
- **Seam (live):** `RunDawnConsolidateScratch()` (`PDV__ManagerQuest.psc:3896`) computes per-deity, in one loop: `scaledToday = pietyToday * GAIN_RATE_SCALE` then `clampedToday = ClampValue(scaledToday, -PIETY_DAILY_MAX_DELTA, PIETY_DAILY_MAX_DELTA)` (live `:3909-3910`), just before `PietyToday` is zeroed.
- **Cheapest path:** fold a mood recompute into that same per-deity loop (read the existing `clampedToday` local): `MoodNew = Clamp(alpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-alpha)*MoodOld, -100,100)`; write `PDV.Mood.<deityForm>`; recompute band; record old→new band for crossing detection. ~30 lines, one new dawn sub-phase `RunDawnUpdateMood()` (insert after `RunDawnConsolidateScratch()`; the live `ProcessDawn()` order is verified — see M4 §3.1).
- **In-repo precedent:** the dawn piety consolidation itself; the per-deity `StorageUtil` float pattern (`PDV.Piety`, `PDV.PietyToday`).
- **HONEST CORRECTION — the input is thinner than the 2026-06-09 draft claimed.** That draft asserted "the per-deity disposition net scalar is already baked in." Per `PDV_DeityLikesDislikesMatrix.md §2/§10`, the day-to-day faucet that feeds `clampedToday` is **proven for Kyne combat events only** (the data-driven `ScoreFromTable` path, events 1–4). The non-combat 300+ vocabulary (rest-under-open-sky, learn-word-of-power, craft, read…) had **no Story Manager receivers and no router classifier** when this was written. **Update 2026-06-10 (post-merge of main `2e665b7`):** the hybrid faucet wiring landed source/ESP receivers for most of the 300+ block — including Kyne's 313 (sleep hook) and 343 (`PDV__SM_NewVoicePower`) — compiled/readback-clean; only 361 (Trespass) remains blocked. **Runtime proof is still pending**, so until the Block D smoke confirms the `[PDV] EventBus` markers, Kyne's mood is still only *proven* to move from kills. The faucet-breadth soft dependency is now a runtime-proof dependency, not an authoring one.
- **In-game proof still required:** (1) `PDV.Mood.*` persists across save/load; (2) band matches expected after seeded `clampedToday` sequences (QASmoke); (3) decay-toward-0 on a no-act day; (4) negligible perf on the all-deity dawn loop.

## Spike 2 — Active patron pool filter (Hades) · confidence HIGH
- **Seam (live):** `IsEligibleForFormalCommitmentOffer()` (`:6427`) gates on `HasRecentCommitmentSignalDays(deity, ...)` (`:6624`); `RecordCommitmentSignalDay()` (`:6594`) is written on positive award.
- **Cheapest path:** pool membership = active patron ∪ deities with recent signal days ∪ cursed-path deities. Reuse `HasRecentCommitmentSignalDays`. Non-pool deities skip the demand/omen eligibility check.
- **Note for Hircine:** the path actor already routes commitment signals, so a werewolf-active Hircine is naturally in the pool — pool membership is *not* the Hircine problem (mood **input** is, Spike 0/1).
- **In-game proof still required:** confirm pool size stays ≤ ~4 under realistic play; dormant deities go silent.

## Spike 3 — Demand scheduler (A1) · confidence MEDIUM (the "act-tag hook" in the prior draft does not exist)
- **Seam (live):** the commitment-offer engine — `RunDawnProcessCommitmentOffers()` (`:4025`) / its `…Noop()` wrapper (`:3964`) → `EvaluateFormalCommitmentOffer()` (`:6356`) → `GetBestFormalCommitmentOfferCandidate()` (`:6403`) → eligibility (`:6427`). State lives in a `PDV.Commitment.*` namespace with `OfferedAt`/`PendingDeityIndex`.
- **Offer/expiry (HIGH):** add `RunDawnProcessDemands()` mirroring `RunDawnProcessCommitmentOffers()`; new `PDV.Demand.<deityForm>.{Pending,Type,OfferedAt,ExpiresAt,Fulfilled}` namespace; offer to band-crossed-down (or LD-P2 expectation-red) pool deities; expiry in dawn applies a one-time mood penalty / (Daedra) displeasure bump.
- **CORRECTION — fulfillment has no single "act_tag" seam.** The 2026-06-09 draft said "hook the existing act-tag routing in `AwardPietyInternal`/`ApplyQuestReaction` — when an act matching the demanded tag fires." But live signatures carry **no string act-tag**: `AwardPietyInternal(PDV_DeityBase deity, Float amount, Bool allowRivalry)` (`:4351`), `AwardPiety(deity, Float amount)` (`:812`), `ApplyQuestReaction(Quest sourceQuest, Int stageValue)` (`:816`). PDV has **two** signal layers and the demand must name which one it fulfills against:
  1. **Day-to-day faucet** — keyed by **`Int eventType`** (the 300+ block) routed to `ScoreAction`/`ScoreFromTable`. Hircine's *slay-a-great-beast* = `kill-hostile-beast (1)` + a "great/large" victim filter.
  2. **Curated milestone** — keyed by **quest + stage** via `ApplyQuestReaction` → the `PDV_QuestReactionMatrix`. Kyne's `the_hunt` exists **only here** (a quest-matrix tag), not as a day-to-day act.
- **Required fix to the authoring data (Block A revision):** `PDV_DemandTable.csv` currently carries free-text strings (`honor_the_wild`, `slay_a_great_beast`). They must be backed by a **concrete signal binding** — an `eventType` list and/or a quest-matrix tag — and fulfillment is detected at the *existing* routing point for that layer (eventType match in the router→`ScoreAction` path; quest-stage match in `ApplyQuestReaction`). No new generic "act_tag" parameter is threaded through the award functions.
- **In-game proof still required:** (1) player-facing demand surface (toast/MCM/MessageBox); (2) fulfillment fires once and single-act-resets, per bound signal layer; (3) expiry penalty applies exactly once; (4) `PDV.Demand.*` persists across save/load.

## Spike 4 — Omen dispatch (A2) · confidence HIGH (toasts) / DEFERRED (rich director)
- **Seam (live):** `SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival)` (`PDV__ManagerQuest.psc:1057`) already fires for existing event types; the player-event side hooks `OnSleepStart` and `OnWeatherChange` (`PDV_PlayerEvents.psc`).
- **Cheapest path (LD-P1):** add `"mood_up"`/`"mood_down"`/`"demand"` event types to the **live** toast path, fired on band-cross from `RunDawnUpdateMood()`. Dream omens ride `OnSleepStart` with a probability roll. All gated by pool + `ScoreRepeatableAction`-style cooldown + MCM density.
- **Honest dependency — CORRECTED 2026-06-10 (LD-P2 research pass, verified against live source):** `PDV_DiegeticDirector.psc` **exists live** (14KB; `Dispatch(eventClass, surfaceKey, direction, deityIndex, toneOverride)`, `SetBodyMark`, `EmitPrayerAnim`), gated by `D1Enabled` and already routed from the manager via `SurfaceTransition`. The earlier "specced but not built" claim was stale. Rich modalities remain **LD-P2 scope**, but as *routing* work, not greenfield — see `05_ld_p2_feasibility.md`. LD-P1 omens still ride the live toast + dream channels only.
- **In-game proof still required:** toast fires once per band-cross (not per dawn); dream cadence feels right; degrades to `Debug.Notification` when Prisma absent.

## Spike 5 — Mood-scaled boon (A4) · confidence HIGH (Kyne) / gated-on-Spike-0 (Hircine)
- **Seam (live):** `SyncPatronBoonsToTier(Int tierValue)` (`PDV_DeityBase.psc:332`) does the `ClearAllBoons()` (`:346`) + tier-gated `AddSpell` band-swap.
- **Cheapest path:** band-indexed boon variants (`Boon_<tier>_<band>`) swapped on mood-band-cross, mirroring the tier swap exactly. Re-grant only on transition (this avoids the engine limitation that an applied MGEF can't re-read a global live). Respects the one-active-boost + family-cap guardrails (clear-before-add).
- **Hircine caveat:** lives on the new `PDV_Deity_Hircine` (Spike 0); its boons activate with the curse.
- **In-game proof still required:** band-swap fires only on crossing; no stacking; magnitude variants author cleanly per band per deity.

## Spike 6 — A3 clutch-save intervention · confidence HIGH (prototype exists in-repo)
- **Seam (live):** `PDV_T3DailyLowHealthSaveEffect.psc` — constant-effect `ActiveMagicEffect` polling `GetActorValuePercentage("Health")`; below `TriggerHealthPercent` calls `TryApplyDailySave()` (`:49`) which `RestoreActorValue` once per day via a `StorageUtil` day-key.
- **Cheapest path:** gate the existing save on `mood >= Pleased` (read the global mirror `PDV_GLO_PatronMoodBand`, refreshed each dawn — a script-poll read, not an MGEF live-global read, so it is legal), theme per deity, route through a `Marked`-tier toast. Daily-cap anti-spam already present. (For Hircine the mood is itself curse-gated via Spike 0, so the save is implicitly werewolf-only.)
- **In-game proof still required:** mood-gate + theming fire correctly; once-per-day across save/load; `Marked` dispatch shows once.

---

## Feasibility verdict (revised)
| LD-P1 mechanism | In-repo precedent | Confidence | Greenfield? |
|---|---|:-:|:-:|
| **`PDV_Deity_Hircine` actor (Spike 0)** | Kyne deity shell + `PDV_CurseState` gate | MED-HIGH | **YES — 1 new deity actor (curse-gated)** |
| Mood EWMA + bands | dawn consolidation + StorageUtil floats | HIGH | minimal (1 sub-phase) |
| Patron pool | commitment eligibility query | HIGH | none |
| Demand scheduler | commitment-offer engine | MEDIUM | new `PDV.Demand.*` + **signal-binding fix** (no act_tag seam) |
| Omen (toast + dream) | live `SendPrismaEventToast`, `OnSleepStart` | HIGH | none |
| Mood-scaled boon | `SyncPatronBoonsToTier` band-swap | HIGH | band-variant authoring |
| Clutch-save (A3) | `PDV_T3DailyLowHealthSaveEffect.psc` | HIGH | mood-gate + theming |

**Conclusion:** LD-P1 is buildable, but **not** as the "pure recomposition, no
greenfield" the 2026-06-09 draft claimed. It carries **one new actor** (curse-gated
`PDV_Deity_Hircine`), a **demand-fulfillment signal binding** the prior draft assumed
existed, and a **faucet-breadth soft dependency** (non-combat day-to-day vocabulary)
that bounds how lively mood feels until the matrix §10 SM/router work lands. None of
these is infeasible; all are now costed honestly. The remaining unknowns are
runtime-verification items (persistence, fire-once, perf, spam-feel, curse-gating
correctness), appropriate for an in-CK/in-game proof session.

---

## Changelog — 2026-06-10 in-the-loop revision
1. **Corrected `PIETY_DAILY_MAX_DELTA` 5.0 → 4.3** (live `:313`); recomputed pacing.
2. **Added Spike 0** — the curse-gated `PDV_Deity_Hircine` actor; reclassified
   Hircine from "recomposition" to "one new actor," reconciling the owner's
   keep-Hircine ruling with the matrix §8.2 no-ambient-drift rule.
3. **Spike 1 honesty fix** — day-to-day faucet is Kyne-combat-only today; non-combat
   vocabulary (SM receivers + router) is a soft dependency, not "already baked in."
4. **Spike 3 correction** — no string `act_tag` exists in the award path; demand
   fulfillment must bind to a concrete signal layer (`Int eventType` faucet and/or
   quest-stage matrix). Flags a `PDV_DemandTable.csv` revision.
5. **Updated all line numbers** to live source; flagged that names, not lines, are
   the contract.
6. **Verdict table** regraded: Demand → MEDIUM; added the new-actor row.
</content>
</invoke>
