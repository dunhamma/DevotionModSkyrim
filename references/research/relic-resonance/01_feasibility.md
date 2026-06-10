# Relic Resonance -- Feasibility

**Status:** SOURCE-TRACED ONLY -- no in-game proof exists for this bucket.
**Date:** 2026-06-10

> All live line refs follow the names-are-the-contract convention from
> `04_living_deities_architecture.md`. Line numbers from
> `D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/` as of 2026-06-10.

---

## 1. Live seams relic resonance builds on

### 1.1 The dawn tick -- `RunDawnConsolidateScratch` (live :3954)

`ProcessDawn` (live :3933) calls `RunDawnConsolidateScratch`, which iterates
`PDV_FLST_AllDeities` and for each deity computes `clampedToday`, banks it to
`PDV.Piety`, then calls `RunDawnUpdateMoodForDeity(deity, clampedToday)`.
Relic resonance does NOT hook into `RunDawnUpdateMoodForDeity` (that function
is the EWMA path that consumes `clampedToday`). Instead it slots as a
**separate sub-function** called immediately after `RunDawnConsolidateScratch`
completes, before `RunDawnRefreshTrackStates`. This preserves the ordering
contract while keeping mood EWMA and relic nudge as independent paths.

**Confidence:** HIGH -- the dawn tick is runtime-proven (2026-06-08 Tu'whacca
test). The loop structure and call-order is readable in the authored LD-P1
slice (`research/living-deities/src/PDV__ManagerQuest.psc` :3933--3950).

### 1.2 ApplyMoodDelta (authored LD-P1 slice :10683)

```
Function ApplyMoodDelta(PDV_DeityBase deity, Float delta, String reason)
```

Direct mood adjustment that recomputes the band through the same
`ComputeMoodBand` + `OnMoodBandCross` ceiling-and-crossing dispatch.
Relic resonance calls `ApplyMoodDelta(deity, relicNudge, "relic_resonance")`
once per dawn per eligible deity. This is the **only** path that should be
used -- invoking `RunDawnUpdateMoodForDeity` directly with a fake
`clampedToday` would corrupt the EWMA with a phantom piety signal.

**Confidence:** HIGH -- function is authored, not greenfield; signature is
stable; reason string is logged for diagnostics.

### 1.3 The per-deity patron pool filter -- `IsDeityInActivePool` (live)

LD-P1 gates `OnMoodBandCross` toasts and omen dispatch to deities in the
active patron pool (`HasRecentCommitmentSignalDays`). Relic resonance should
apply the **same pool filter**: a relic nudge for a deity the player has never
committed to would silently inflate mood with no player-facing effect. Gate:
apply relic nudge only when `IsDeityInActivePool(deity)` returns true (or
equivalent active-patron gate used elsewhere -- proof item: confirm which
guard is correct for "has committed to this deity at all", not just "recently
active").

**Confidence:** MODERATE -- the guard name is traced from `OnMoodBandCross`
(:10420); confirming it is the right gate for relic resonance (vs. a stricter
recency check) is a **proof item**.

### 1.4 PDV_FLST_FaucetDaedricArtifacts -- already wired (live)

`PDV_PlayerEvents.psc:86` declares
`FormList Property PDV_FLST_FaucetDaedricArtifacts Auto` and
`OnObjectEquipped` (live :245--250) already dispatches event 368 when an item
in this list is equipped. The list is CK-populated with the vanilla Daedric
artifact set.

Relic resonance introduces **per-deity** FormLists
(`PDV_FLST_Relic_Hircine`, etc.), NOT a second global artifact list.
`PDV_FLST_FaucetDaedricArtifacts` is a different concern (on-equip piety
signal); per-deity relic lists are checked at dawn for inventory presence
only. The two lists may overlap (the same item can be in both), but they
serve distinct routing paths.

**Confidence:** HIGH -- `PDV_FLST_FaucetDaedricArtifacts` is live and
readback-clean. Per-deity FormList pattern is the existing idiom throughout
`PDV_PlayerEvents` (see the ~40 `PDV_FLST_P2_*` per-race/deity source lists).

### 1.5 Actor.GetItemCount for inventory scan

Vanilla Papyrus: `Actor.GetItemCount(Form akItem) -> Int` returns the count
of a specific form in an actor's inventory. Checking a FormList requires an
iteration: for each form in `PDV_FLST_Relic_<Deity>`, call
`playerActor.GetItemCount(formRef)` and stop at the first non-zero result.

For P1 pilot relics (1--2 items per deity, 3 deities), this is 3--6 sync
calls at the dawn tick. At scale (all 15+ deities, up to 4 relics each), this
is ~60 sync calls -- still well within the per-dawn budget for a one-time
execution.

**Confidence:** HIGH -- `GetItemCount` is a core vanilla Papyrus API.
**No in-game proof exists yet; this must be verified in a dawn-tick smoke.**

---

## 2. Proof items still required (not blocking design, blocking build)

| # | Proof item | Why it matters | Owner |
|---|---|---|---|
| P1 | `IsDeityInActivePool` is the correct pool guard for relic resonance | Wrong guard = silent off-state nudges or missed nudges | Builder |
| P2 | Skeleton Key relic behavior: is it flagged as quest item, and does `GetItemCount` return 1 while it is held? | Skeleton Key may be non-droppable; confirm it resolves normally | Builder |
| P3 | Dawn-tick `GetItemCount` across 3 FormLists: no measurable frame hitch | Inventory scan is synchronous; must be profiled at dawn | Builder |
| P4 | Hircine relic resonance interaction with the curse gate (SS2.0 in arch doc): mood nudge should only fire while `IsWerewolf()` | Without the gate, the Savior's Hide nudges a non-werewolf toward Hircine mood, violating the `PDV_Deity_Hircine` design | Builder |
| P5 | Accepted-deity face requirement for Nocturnal/Meridia: current live source has only `PDV_DaedricPath_Nocturnal/Meridia` -- no `PDV_Deity_*` face. Without the deity face, `IsDeityInActivePool` returns false for these Princes and the nudge never fires. P1 pilot may need to restrict to Hircine only, or defer Nocturnal/Meridia until their accepted-deity faces are authored. | Owner decision required. |

---

## 3. Confidence / recomposition summary

| Seam | Status | Confidence |
|---|---|---|
| Dawn tick entry point (`RunDawnConsolidateScratch`) | Runtime-proven 2026-06-08 | HIGH |
| `ApplyMoodDelta` mood path | Authored LD-P1, not yet proven in-game | MODERATE-HIGH |
| Per-deity FormList pattern | Live, ~40 instances in PlayerEvents | HIGH |
| `Actor.GetItemCount` inventory scan | Core API, no project proof yet | MODERATE |
| Active-pool guard for relics | Name traced, semantics need confirmation | MODERATE |
| Nocturnal/Meridia accepted-deity face | Not present in live source | REQUIRES OWNER DECISION |

---

## 4. Recomposition vs. greenfield verdict

Relic resonance is **recomposition**: it adds one new sub-function and three
new FormLists, then calls the existing `ApplyMoodDelta` path. No new event
IDs, no new Papyrus APIs, no new CK record types beyond three FLST records.
The only authoring greenfield is the per-deity relic CSV + the
`pdv_relic_resonance_compile.mjs` tool (or manual inline data if keeping
authoring minimal for P1).
