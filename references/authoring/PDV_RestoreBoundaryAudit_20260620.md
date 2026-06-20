# PDV Restore Boundary-Loss Audit (2026-06-20)

## Current Verdict

The live-manager recovery items from the 2026-06-20 disappearance audit have been
cross-checked and restored in live Papyrus source as of the Codex recovery pass.

Recovered:

- #1 P2 `po3_book` book-notice suffix gate.
- #5 Orc life-mode organic wiring.
- #15 startup per-path confirm selector.
- #2 Breton per-book Hidden Art notices.
- #8 Argonian bed-of-choice move-home / re-adapt path.

Already present before this pass:

- Argonian adaptation 10-14 day clock.
- Argonian extended debug seeds.
- Phase 0 Prisma choice round trip.

Tracked hardening added:

- Source snapshot:
  `generated/live-devotion-snapshot/2026-06-20-restore-recovery/Scripts/Source/`
- Restore runbook:
  `references/authoring/PDV_LiveManagerLocalEdits_RestorePatch.md`
- Verifier assertions:
  `tools/pdv_verify.mjs` now checks the restored source anchors and the absence of
  the old startup detail-box flow.

## Scope Boundary

The ESP audit result from the original read-only pass still stands: `Devotion.esp`
records were retained from the 18th/19th. The behavioral loss was confined to live
Papyrus source/compiled script surfaces.

This document tracks machine/source recovery. It does not claim fresh Skyrim
runtime proof. The restored routes still need in-game/manual evidence where the
normal beta gate requires it.

## Item Cross-Check

### #1 - P2 book notice suffix gate

Status: restored.

Live source:

- `PDV__ManagerQuest.psc`
- `IsP2BookNoticeReason` now returns
  `StringContainsToken(reason, "po3_book")`.

Why it matters: all PO3 book emitters append per-source suffixes. Exact-matching
suffixless tokens silently swallowed the top-left book-read notice even when the
route and piety movement succeeded.

Verification:

- Targeted Papyrus compile passed for `PDV__ManagerQuest`.
- `pdv_verify.mjs` now asserts the token-match body.

Runtime/manual proof still needed:

- Fresh Skyrim book-read proof for at least one suffixed route.
- Dunmer Mephala should be included because it was doubly exposed by the old
  whitelist shape.

### #5 - Orc life-mode organic wiring

Status: restored to source reachability; not runtime-proven.

Live sources:

- `PDV_ActionRouter.psc` now forwards location changes to
  `PDV_Manager.HandleOrcLocationChange(akNewLocation)`.
- `PDV__ManagerQuest.psc` now has:
  - `HandleOrcLocationChange`
  - `HandleOrcStrongholdPresence`
  - `HandleOrcBloodKinCrisis`
  - exact stronghold `LCTN` FormID mapping
  - token-aware major life-mode reason matching
- `PDV_EventBus.psc` now has:
  - `RouteOrcStrongholdPresence`
  - `RouteOrcBloodKinCrisis`
  - optional organic source IDs for City, Legion, and Self-Made routes
- `PDV_PlayerEvents.psc` now registers and routes approved Orc quest-stage sources:
  - DA06 Blood-Kin stage 200
  - nine city Thane stage 200 quests
  - HousePurchase stage 10
  - CW02A stage 200
  - CWFinale stage 500, guarded by Imperial faction membership

Verification:

- Targeted Papyrus compile passed for `PDV__ManagerQuest`, `PDV_PlayerEvents`,
  `PDV_ActionRouter`, and `PDV_EventBus`.
- `pdv_verify.mjs` now asserts the recovered Orc source anchors.

Runtime/manual proof still needed:

- Stronghold location transition.
- DA06 Blood-Kin completion.
- City/house/Legion quest-stage routes.
- Survey/status and stack snapshots according to the race beta gate.

### #15 - Startup per-path confirm selector

Status: restored.

Live source:

- `PDV__ManagerQuest.psc`
- 13 `PDV_MSG_Confirm_*` properties are declared.
- `ConfirmStartupSelection(Int originRace, Message choiceMessage, Int expectedSelection)`
  calls `GetStartupConfirmMessage`.
- `GetStartupConfirmMessage` maps Breton, Redguard, Orc, and Bosmer choices to
  their per-path confirm records.
- The old `Debug.MessageBox(GetStartupOptionDetailText(...))` middle detail-box
  flow is absent.

Verification:

- Targeted Papyrus compile passed for `PDV__ManagerQuest`.
- `pdv_verify.mjs` now asserts the selector and asserts the old middle-detail call
  is absent.

Runtime/manual proof still needed:

- Fresh startup-path click-through proof on a new/fresh test save for one mapped
  option per affected race family, or the narrower beta gate equivalent.

### #2 - Breton per-book Hidden Art notices

Status: re-authored and restored.

Live sources:

- `PDV_PlayerEvents.psc` now appends source tokens for Breton Hidden Art book
  routes.
- `PDV__ManagerQuest.psc` now branches notice title/text through:
  - `GetBretonHiddenArtNoticeTitle`
  - `GetBretonHiddenArtNoticeText`

Current source tokens:

- `hagravens`
- `madmen_reach`
- `witch_note`
- `unknown` fallback

Verification:

- Targeted Papyrus compile passed for `PDV__ManagerQuest` and `PDV_PlayerEvents`.
- `pdv_verify.mjs` now asserts the Breton notice helpers and PO3 source token
  routing.

Runtime/manual proof still needed:

- Breton Hidden Art book-read proof for each distinct token if the beta packet
  wants copy-level confidence.

### #8 - Argonian bed-of-choice move-home rework

Status: re-authored and restored.

Live source:

- `PDV__ManagerQuest.psc`
- `TryArgonianBedOfChoiceSleep` now tracks a candidate home cell and requires a
  three-sleep settle streak before prompting.
- Accepting the prompt calls `SetArgonianHome`.
- Declining records a short decline cooldown and clears candidate state.
- `SetArgonianHome` clears candidate state, clears current adaptation, resets
  rooted-rest sleep count, and rolls a new 10-14 day adaptation clock.
- `ClearArgonianAdaptation` removes active adaptation spells and clears active/due
  StorageUtil state.

Verification:

- Targeted Papyrus compile passed for `PDV__ManagerQuest`.
- `pdv_verify.mjs` now asserts the move-home helper anchors.

Runtime/manual proof still needed:

- Three sleeps at a new non-home cell should prompt.
- Accept should move home, reset current adaptation, and re-arm the maturation
  clock.
- Decline should suppress immediate repeat prompting.

## Recovery Commands Used

Targeted compile:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_PlayerEvents --script PDV_ActionRouter --script PDV_EventBus --skip-verify
```

Expected compile result:

- All four scripts pass.
- Each reports `0 error(s), 0 warning(s)`.

Full verifier gate:

```powershell
node .\tools\pdv_verify.mjs
```

## Next Runtime Proof Queue

1. Book-notice smoke, including a suffixed route and Dunmer Mephala.
2. Startup confirm smoke for mapped per-path records.
3. Orc organic route smoke, with runtime log markers plus Survey/status checks.
4. Breton Hidden Art per-token notice smoke if copy-level proof is required.
5. Argonian move-home three-sleep accept/decline smoke.

Keep these proof buckets separate from the machine/source recovery above.
