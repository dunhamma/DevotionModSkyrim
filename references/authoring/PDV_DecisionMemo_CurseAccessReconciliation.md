# Decision Memo — Curse-Access Template (reconciliation)

**Status:** Reconciliation, not a new decision. The curse-access template is **already
locked as D-16** (`PDV_Architecture_v3.md:1077-1086`, Decisions Log 2026-05-31, rationale
`references/authoring/PDV_Daedric_DecisionPacket_CAT4.md`). The immersion audit
(`PDV_ImmersionAudit_MissedOpportunities.md` §3) flagged a curse-access "asymmetry to
ratify"; that flag was reading stale "needs ratification" language. This memo records why the
flag is closed and isolates the one genuine residual gap.

## What the audit raised

1. Hircine (werewolf) and Molag Bal (vampire) seem to use different framing — e.g. a Nord
   vampire's Sovngarde is **severed** while a Nord werewolf's is only **strained**. Is that a
   template inconsistency?
2. The Orc Molag Bal per-race response appears missing.

## Resolution

### 1. The severance-vs-strain difference is intended per-race *weight*, not template variance

D-16 fixes the **mechanical template** for both curse-access Princes identically: commitment
gate = curse acquisition; the `_Commitment` slot is reframed as a curse-onset message; stigma
is driven by the Phase 15 curse-state overlay (not a per-act counter); exit is the cure path
(D-13); and they must coordinate with — not double-fire against — the race-manifest
`CurseState` rows (`PDV_Architecture_v3.md:1077-1086`).

The *strength* of the theological consequence is a separate axis: the per-race/per-curse
`GainMultByRaceAndCurse` table (`PDV_Architecture_v3.md:1226-1239`, §13.2). A Nord vampire's
Sovngarde severance vs a Nord werewolf's strain is two different cells in that table, both
expressed through the one template. That is the system working as designed — vampirism is
authored as the deeper rupture across the roster (e.g. Argonian vampire is "one of the deepest
grief states", `PDV_RaceDesign_Argonian.md:122-124`); werewolf is the recoverable strain.

**Therefore:** no template change. The asymmetry is a *content* expression of per-race weight,
and the principle that anchors it is already locked in §13.6 — *curse state never auto-opens a
Daedric path; commitment signals are still required* (`PDV_Architecture_v3.md:1278`). To keep
this from being re-litigated, the reconciliation is encoded as a short clarifying subsection
§13.7 (this change set).

### 2. The Orc Molag Bal response is a D-18 content-completeness item, not an open decision

D-16 says per-race responses "author normally" for curse-access Princes, and D-18 requires a
per-race response for every non-native race before the 20C content gate
(`PDV_Architecture_v3.md:1092-1100`). A missing Orc Molag Bal row is therefore a tracked
content gap under the existing D-18 checklist, not a design fork. **Action:** ensure the Orc
(and any other missing) Molag Bal per-race response rows are present in the Daedric/race
manifests before 20C; no architectural decision required.

## Net

- D-16 stands unchanged.
- Add §13.7 clarifying that curse-access *framing* strength is per-race weight (§13.2), not
  template divergence — closes the audit flag.
- Route the Orc Molag Bal response into the D-18 content checklist.
- The *player-facing* concern underneath the audit flag (the player isn't told what changed at
  curse onset/cure) is real and is handled by the transition-surfacing contract (§16.7),
  specifically the curse onset **and cure** beats.
