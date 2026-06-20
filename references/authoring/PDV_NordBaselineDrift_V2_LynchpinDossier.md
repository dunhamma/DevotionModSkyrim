# PDV Nord Pantheon Baseline -- Organic Drift (V2 Lynchpin Dossier)

Status: DESIGN DOSSIER (not scheduled; research-complete, build-deferred)
Date: 2026-06-20
Depends on: `PDV_NordBaselineStartupGate_V1_BuildSpec.md` shipping first.
Proof-boundary note: this is design research; it does NOT gate on runtime proof.
Implementation of any item below DOES gate on in-game smoke.

---

## 1. Problem this solves

V1 locks the Nord Old Ways / Nine Divines baseline at startup. V2 asks: can a
player who lives contrary to their declared baseline have it shift mid-game,
without a clumsy "switch pantheon" menu button? The honest answer shaped the
whole design and is the key finding below.

## 2. Key finding: the two lanes are NOT symmetric

Ambient, per-action drift is the wrong model, because **Old Ways is signal-rich
and Nine Divines is signal-poor by nature.**

- All three existing Nord evidence counters are Old-Ways flavored:
  `PDV.Nord.OldWaysContextCount`, `PDV.Nord.KyneTalosContextCount`,
  `PDV.Nord.HircineArkayEdgeCount` (fed via `RouteNordFamily` in the EventBus,
  consumed by `HandleNordOldWaysState` / `HandleNordKyneTalosContext` /
  `HandleNordHircineArkayEdge`). One is already reward-gated:
  `broadOldWaysFaithful` grants the Nord Old Ways T2 broad blessing at
  `OldWaysContextCount >= 6` (`PDV__ManagerQuest.psc` ~`:8453`).
- Nearly every iconic Nord narrative beat reads Old Ways. From the frozen quest
  matrix (`references/authoring/PDV_QuestReactionMatrix_Full.csv`):
  - Stormcloak oath -> Talos (`CW01B`, `defy_tyranny_talos`)
  - The Way of the Voice / Greybeards -> Kyne ("Paarthurnax names the Voice
    Kyne's gift", `MQ105`)
  - Dragon slain at Kynesgrove -> Kyne (`MQ106`)
  - Companions / Glory of the Dead -> Shor + Sovngarde (`C06`)
  - Kyne's Sacred Trials (Froki) -> the hunt (`dunHunterQST`)
- There is **no symmetric Divines counter**, because a Nord's Nine Divines
  identity is civic/political, not behavioral. The one strong, repeatable
  pro-Divines act is joining the Imperial Legion (`CW01A`, `serve_empire_order`);
  the rest (temple healing, Mara marriage, Arkay funerals) is generic and not
  distinctively Nord.

Conclusion: **do not build symmetric ambient drift.** Use discrete, legible
**lynchpin moments** where the game already forces a clear declaration, and offer
a realign there.

## 3. Design: lynchpin realign-offers

Drift is a **player-confirmed offer at a high-signal quest milestone**, not
silent counter accumulation.

Guardrails (both reuse existing patterns):
- **Offer, not auto-flip.** A confirm pop-up (reuse the per-path confirm MESG
  shape from V1). A Talos-loyal Nord infiltrating the Legion is not silently
  converted.
- **Broad-worship only.** Eligible only while `GetPatronState() ==
  PATRON_STATE_BROAD`. Committing to a patron pins the baseline (the orphan-
  prevention rule) -- a committed Old Ways patron is never invalidated by a later
  Divines lynchpin.
- **One-shot per lynchpin**, with a transition lockout via the StateTrack
  evidence-gate primitives (`SetTransitionLockout` / `IsTransitionLockedOut`).

## 4. Lynchpin candidates (ranked)

1. **Civil War oath -- FLAGSHIP.** The actual in-fiction "which Nord are you"
   fork, binary, and already detected (`RegisterForCivilWarSignals`;
   `side_with_stormcloaks` action key ~`:9309`; EventBus Concordat-pressure
   route). Stormcloak oath (`CW01B`) -> offer realign to **Old Ways**; Imperial
   Legion oath (`CW01A`) -> offer realign to **Nine Divines**. This is the only
   lynchpin that cleanly points BOTH directions, and it gives the signal-poor
   Divines lane its one strong trigger.
2. **Kyne's Sacred Trials (Froki, `dunHunterQST`).** Explicitly Kyne; already a
   matrix quest. Accept/complete -> offer realign to **Old Ways**. (User's
   original instinct; good as the Old-Ways confirm path.)
3. **The Way of the Voice (Greybeards, `MQ105`).** Already routes to
   `KyneTalosContextCount`; natural Old Ways pull. Lower priority -- the main
   quest is near-universal, so gate carefully to avoid railroading every Nord
   toward Old Ways.
4. **(Optional positive Divines beat) Temple of Mara marriage** (Amulet of Mara
   / Bonds of Matrimony). The one civic sacrament that reads Divines, if Nine
   Divines needs a "yes" moment beyond joining the Legion. Requires NEW
   detection (marriage quest stage) -- not currently hooked.

## 5. New plumbing required (bounded)

Most detection already exists. The genuinely new work:
- A **Nine-Divines-ward trigger** on the Legion oath (`CW01A`). No Divines
  counter exists; this is a single detected quest stage feeding a one-shot offer,
  not a counter stream.
- A small `OfferNordBaselineRealign(targetBaseline, sourceTag)` manager function:
  guard on Nord + broad + not-locked-out, show a confirm MESG, on accept call
  `PDV_NordPantheonBaselineTrack.SetState(target, reason)` + re-sync rewards +
  set the transition lockout.
- 2 new confirm MESG (realign-to-OldWays, realign-to-NineDivines) authored via
  `tools/pdv-startup-author` (or a sibling author).
- Hook points: Civil War oath handlers (already registered) and the
  `dunHunterQST` quest-stage route.

## 6. Why this is validatable (vs the ambient approach we rejected)

Each lynchpin is a single, testable quest stage -> confirm pop-up -> state flip,
which is exactly the kind of thing this project proves cleanly in-game. There is
no open-ended "did we find enough signals" question. V2 was deferred to keep V1
shippable, NOT because the path is unknown -- the path is known and bounded.

## 7. Open questions to settle before V2 build

- Should the Way of the Voice be a lynchpin at all, or excluded because the main
  quest is near-universal and would over-pull Nords toward Old Ways?
- Does Nine Divines need the Mara-marriage "yes" beat, or is the Legion oath
  enough as its single trigger?
- Confirm the orphan rule wording in player-facing copy ("committing to a patron
  settles your path") so the lock is legible, not surprising.
