# PDV Prisma Integration Boundary

**Created:** 2026-06-06
**Status:** UI integration boundary locked; runtime proof still separate

## Purpose

Prisma is the long-term player-facing UI shell for Devotion, but it is not the
proof system for Phase 20 P2 gameplay hooks. This note locks the split so the
project can keep building UI without weakening source, route, reward, or manual
proof standards.

The short rule:

```text
P2 proves state. Prisma surfaces state.
```

## Current Boundary

### P2 / Gameplay Proof Track

P2 owns gameplay truth and readiness evidence:

- route hooks and source fills
- exact-stage and source-readback gates
- manager-owned state writes
- duplicate guards and anti-farm behavior
- Survey/status clarity
- top-left `Debug.Notification` proof notices where needed
- reward `SPEL`/`MGEF` readback and manager grant/removal logic
- Active Effects display, save/load, stack snapshots, and balance feel proof

P2 proof must not depend on Prisma overlay availability, panel focus, browser
state, native bridge state, glyph coverage, or UI clickability.

### Prisma / UI Integration Track

Prisma owns presentation and final player-facing feel:

- typed event toasts
- refreshed panel payloads
- medallion roster presentation
- glyph coverage
- eventual always-on or persistent HUD concepts
- final UX polish for status, transitions, choices, and warnings

Prisma may consume canonical manager-owned state and typed JSON payloads. It
must not become the source of truth for devotion, piety, patron state, route
acceptance, reward eligibility, or manual proof status.

## Marriage Point

The two tracks meet at manager-owned state and typed payloads:

```text
source event -> EventBus/Manager -> StorageUtil/records/state -> typed JSON -> Prisma
```

The manager remains authoritative. Prisma can render:

- current patron or quasi-patron identity
- current tier or posture label
- accepted transition events
- disabled medallion entries and reasons
- race reward presence once runtime proof is complete

Prisma cannot promote a state from pending to proven. If Prisma displays
something incorrectly, the fix is a UI integration fix unless readback/logs show
the manager state itself is wrong.

## Always-On HUD Status

An always-on HUD is not implemented and is not required for P2 proof.

Current landed UI surfaces are:

- transient Prisma event toasts
- on-demand/refreshed Devotion panel payloads
- `mode:"medallion"` roster presentation

Future always-on work is a UI feature track. It must be gated by:

- input safety proof, especially around CK-backed MessageBoxes and menus
- non-overlap with player controls and MCM/menu flows
- in-game display proof across startup, load, normal play, and combat
- fallback behavior when the Prisma bridge is unavailable

## P2 Proof Feedback Policy

For current P2 empirical proof, use surfaces that do not depend on the Prisma
overlay:

- Papyrus log markers
- verifier/readback output
- top-left `Debug.Notification`
- Survey/status readout
- Active Effects display checks for rewards
- manual evidence ledger notes

Prisma can be tested in parallel as player-facing polish, but a missing Prisma
toast or panel update is not a P2 route-proof failure unless the manager state
or log marker is also wrong.

## Final-State Gate

Before beta/final, both tracks must pass:

| Track | Required proof |
|---|---|
| P2 gameplay | route/source/reward/readback gates, wrong-origin rejection, anti-farm behavior, Survey/status clarity, Active Effects, save/load, stack snapshots, manual feel |
| Prisma UI | typed toasts, medallion interaction, panel refresh, glyph fallback/coverage, no input trap, no MessageBox overlap, display proof on fresh game/load |

Do not collapse these gates. A clean P2 gate without Prisma proof means gameplay
is proven but final UI feel is not. A good Prisma display without P2 proof means
presentation is working but gameplay is not proven.

## Related Files

- `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`
- `references/authoring/PDV_Phase20_PreBetaManualChecks_Runbook.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_MedallionRoster.manifest.json`
- `references/authoring/PDV_MedallionDeityCoverageAudit.md`
- `handoff/SESSION_HANDOFF_Prisma_Surfacing.md`
- `handoff/PrismaMedallionRoster_DesignHandoff.md`
- `native/DevotionPrismaBridge/mod/PrismaUI/views/Devotion/app.js`
- `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc`
