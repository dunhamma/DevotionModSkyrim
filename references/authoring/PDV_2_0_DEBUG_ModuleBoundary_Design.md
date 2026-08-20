# PDV 2.0 -- Debug Module Boundary (design gate D2)

Status: IMPLEMENTED at the static/compile/readback boundary on 2026-08-20. The tester-only
console shim remains deferred until its exact driver set is chosen; it is not in the user payload.

Implementation checkpoint: 136 `Debug*` bodies reside in `PDV_DebugRuntime`; the manager retains
`RunDebugCommand` plus four scratch registers; the MCM double-hop, 111-public/25-private contract,
region map, release manifest, sync map, host QUST `0717A1`, manager property 515, and 58-entry SEQ
are landed. `tools/pdv_v3_debug_extraction_audit.mjs` passes 27/27, five affected scripts compile
0/0, direct houseCARL readback confirms the host and stable references, and VMAD passes 207/207
attachments with zero unwaived findings. Runtime/player-surface proof remains open.

Grounding read this session (facts re-derived from the current tree):

- `live-source/Scripts/Source/PDV__ManagerQuest.psc` (the 136 `Debug*` functions).
- `live-source/Scripts/Source/PDV_MCM.psc` (the sole caller).
- `references/authoring/PDV_2_0RegionMap.json` (module MANAGER).

---

## 0. Context (from the finish plan)

The 2.0 rebuild adds a 9th module, `PDV_DebugRuntime`, to hold the `Debug*` functions currently in
`PDV__ManagerQuest.psc`. Verified fact: **no `Debug*` function is declared `Global`**, so none is
console-callable via `cqf` today -- debug is 100% MCM-driven. The move must preserve that exactly:
MCM calls `PDV_Manager.DebugRuntime.X()` instead of `PDV_Manager.X()`, and nothing about the
runtime behavior changes.

This is a mechanical extraction under strict parity (F1). This document pins the boundary so F1 is
a rewire, not a redesign.

---

## 1. The public surface

### 1a. Count and Global check (verified)

- **136** functions whose name begins with `Debug` in `PDV__ManagerQuest.psc`.
- **Zero** are `Global` (grep for `Global Function Debug...` and `Function Debug... Global` returns
  nothing). Confirmed: debug is reachable only through a script-instance reference, and MCM is that
  reference. There is no `cqf`-callable debug surface today.

### 1b. What becomes public API

Every `Debug*` function MCM invokes becomes `PDV_DebugRuntime` public API. MCM reaches them two
ways today, both of which must keep working:

1. **Direct calls** -- 51 lines of `PDV_Manager.Debug*(...)` in `PDV_MCM.psc` (e.g.
   `PDV_MCM.psc:1030` `PDV_Manager.DebugApplyDomainSting(...)`, `:1156`
   `PDV_Manager.DebugGetPietyMapString()`). These are the public API of the module.
2. **The register-dispatch path** -- MCM writes the scratch registers `DebugCommand` / `DebugIndex`
   / `DebugValue` / `DebugSignalType` on the manager and calls `RunDebugCommand`, which fans out to
   the `Debug*` bodies.

The 136 `Debug*` bodies move to `PDV_DebugRuntime`. `RunDebugCommand` and its 4 scratch registers
**stay on the manager** (Section 4 / boundary ruling below), so MCM's register writes
(`PDV_Manager.DebugCommand = ...`) need no change; `RunDebugCommand` calls forward into
`DebugRuntime`.

There is no meaningful internal-only subset to keep private: the `Debug*` functions are a flat
harness surface, all reachable from MCM either directly or through `RunDebugCommand`. Any `Debug*`
helper that is only called by another `Debug*` moves with its cluster and can be left un-annotated
(Papyrus has no cross-script privacy that matters here); it simply is not wired into MCM.

### 1c. Count-drift truth-up (flag, not a D2 blocker)

The region map's MANAGER module lists **127** `Debug*` functions; live source has **136**. The 9
in source but absent from the map (`DebugConsentDivinePatronThenRaiseSanguine`,
`DebugEvaluateConsentOfferReport`, `DebugFireSanguineAlcoholTwice`,
`DebugForceUnconsentedPactThenMigrate`, `DebugSanguineConsentReadback`,
`DebugSeedCommitmentSignalDaysForDeity`, `DebugSeedSanguineOfferReady`,
`DebugSeedSanguineOfferReadyCore`, `DebugYesNo`) post-date the golden snapshot the map was built
from. This is an A2 (rebuild the region map) truth-up item. The extraction target is the 136 live
bodies regardless.

---

## 2. The backref pattern

`Debug*` bodies are thin harnesses that delegate INTO the already-extracted modules to exercise
them, and call BACK into manager-internal helpers. Both directions must resolve after the move.

### 2a. What the bodies reach (per-cluster reach table)

| debug cluster | reaches | via |
|---|---|---|
| piety / decay / tier / dislikes / commitment | LEDGER | `LedgerRuntime.*` (e.g. `RecomputeTier`, `RunDawnApplyDecay`, `AwardPietyFromLikesDislikes`, `EvaluateFormalCommitmentOffer`) |
| origin / substrate / per-race | ORIGIN | `OriginRuntime.*` + per-race substrate props (`PDV_ImperialAncestorSubstrate`, `PDV_DunmerAncestorSubstrate`, `PDV_ArgonianHistSubstrate`, `PDV_NordAncestorSubstrate`, `PDV_AltmerAncestorSubstrate`, `PDV_KhajiitLunarSubstrate`) |
| curse / Hircine / Sanguine pacts | DAEDRIC + curse services | `DaedricRuntime.*`, `PDV_CurseStateService.*`, `PDV_HircinePath.*` |
| quest-reaction / signal-floor smoke | QUESTREACTION | `PDV_QuestReactionRuntimeService.*` (+ some `OriginRuntime.*` signal-floor routes) |
| favor | FAVOR | `FavorRuntime.UpdateContextualFavorRuntime` |
| Prisma overlay surfaces | PRISMA bridge | `PDV_PrismaBridge.*` (static Global-fn script, no property) |
| shared static helpers | rules | `PDV_DevotionRules.*` (static, no property) |
| SKSE / engine | -- | `StorageUtil.*`, `Game.*`, `Utility.*`, `Debug.Trace` (statics, no property) |

Reverse direction (backref into the manager): many bodies call non-`Debug` manager helpers and
read manager fields/consts -- `GetDebugLevel()`, `Trace(...)`, `GetPlayerOriginRaceIndex()`,
`ResolveOriginRuntime()`, `RequestPanelRefresh()`, `GetQuestReactionDeity(...)`, `_activeDeity`,
`_panelDirty`, and const families (`ORIGIN_*`, `KHAJIIT_FOCUS_*`, `DAEDRIC_CONSENT_SCHEMA_VERSION`).

### 2b. The wiring (owner ruling Q5: verbatim-move properties + Manager backref)

To move the 136 bodies **verbatim** (they reference modules by bare property name -- `LedgerRuntime.X()`,
not `Manager.LedgerRuntime.X()`), `PDV_DebugRuntime` declares the same module forward-refs the
manager holds, plus a `Manager` backref for the internal-helper calls:

```papyrus
Scriptname PDV_DebugRuntime extends Quest

; Backref -- covers GetDebugLevel(), Trace(), RequestPanelRefresh(), ResolveOriginRuntime(),
; GetPlayerOriginRaceIndex(), manager fields and const families.
PDV__ManagerQuest Property PDV_Manager Auto

; Module forward-refs -- duplicated from the manager so Debug bodies compile unchanged.
PDV_DevotionLedger            Property LedgerRuntime                    Auto
PDV_OriginRuntimeBase         Property OriginRuntime                    Auto
PDV_DaedricRuntime            Property DaedricRuntime                   Auto
PDV_ContextualFavorRuntime    Property FavorRuntime                     Auto
PDV_QuestReactionRuntime      Property PDV_QuestReactionRuntimeService  Auto
PDV_CurseState                Property PDV_CurseStateService            Auto
PDV_DaedricPath_Hircine       Property PDV_HircinePath                  Auto
```

`PDV_PrismaBridge` and `PDV_DevotionRules` need no property (reached as static Global-function
scripts). The per-race substrate references the bodies touch resolve through
`OriginRuntime`/manager as they do today.

This was chosen over the one-backref alternative (a single `Manager` property, rewriting every
module call to `Manager.LedgerRuntime.X()`) because that alternative edits many lines inside every
moved body and churns the parity diff. Duplicating seven properties is cheap; body churn is not,
and this is a strict-parity rebuild that prizes a legible diff. The manager-internal helper calls
(the handful that must go through the backref, e.g. `GetDebugLevel()` -> `PDV_Manager.GetDebugLevel()`)
are the only in-body edits and are individually visible.

### 2c. The MCM rewire (owner ruling Q6)

- MCM's manager reference is `PDV__ManagerQuest Property PDV_Manager Auto` (`PDV_MCM.psc:19`).
- The 51 direct `PDV_Manager.Debug*` call sites become `PDV_Manager.DebugRuntime.Debug*` -- a
  single mechanical find/replace (`PDV_Manager.Debug` -> `PDV_Manager.DebugRuntime.Debug`), no new
  MCM property.
- The register-dispatch path is untouched: `RunDebugCommand` and the 4 scratch registers stay on
  the manager, so `PDV_Manager.DebugCommand = ...` writes need no change.

The double-hop through `PDV_Manager.DebugRuntime` is negligible for user-triggered debug. A direct
`PDV_DebugRuntime` property on MCM (single hop) is a legitimate efficiency the F2 MCM by-module
rebuild MAY adopt while it is already restructuring those pages, but D2 does not require it and the
plan's ESP budget does not include it.

---

## 3. Console-access question (explicit owner decision)

Today there is no `cqf`-callable debug surface (Section 1a). Adding thin `Global` wrapper functions
would be a NEW capability, slightly outside the strict-parity "preserve exactly" mandate. Three
options:

- **(A) Ship MCM-only (recommended for the shipped 2.0.0).** Zero new surface; cleanest parity
  story. Costs QA the convenience of `cqf` during the Phase I 10-race regression.
- **(B) Curated tester shim (recommended -- tester-build-only, HIDDEN FROM USERS).** A small set
  of `Global` wrappers -- the runbook drivers (bind / curse / dawn eval / survey) -- in a clearly
  namespaced `PDV_DebugConsole` script, intended for the Phase I tester runbook. Owner-confirmed
  scope: this ships in the tester build ONLY. It is NOT included in the shipped user FOMOD, is not
  surfaced in MCM, and is never advertised to players; it is a console affordance for the internal
  10-race regression, nothing a user encounters. Middle path.
- **(C) Broad wrapping (not recommended).** Wrap most of the 136. Maximum QA power, maximum new
  support surface -- players type console commands and report the results as "bugs," which is
  exactly why the mod is MCM-driven by design.

**Recommendation (owner-confirmed):** the shipped user build is MCM-only (A) -- no console surface
reaches players. The `PDV_DebugConsole` shim (B) is greenlit as a **tester-build-only** affordance,
kept out of the shipped FOMOD and hidden from users. Steer away from **(C)**. Its wrappers are thin
`Global` forwarders (`cqf PDV_DebugConsole <fn>`) into `DebugRuntime`, present in the tester build
only; they do not change the MCM path and add nothing to what a user can see or invoke.

---

## 4. ESP-host cost

`PDV_DebugRuntime` is hosted like LEDGER and DAEDRIC before it (supervised in-place houseCARL write
at F1, not this phase):

- **One new `QUST` record**, StartGameEnabled, with a VMAD `PDV_DebugRuntime` script attach.
- **A `Manager` property fill** on the new QUST's script (the backref to `PDV__ManagerQuest`) plus
  fills for the seven duplicated module forward-refs.
- **A `PDV_DebugRuntime Property DebugRuntime Auto` forward-ref on the manager**, filled to the new
  QUST.
- **One SEQ regeneration** (the new StartGameEnabled quest must be listed).

Boundary ruling carried into the host: `RunDebugCommand` + the 4 scratch registers stay on the
manager QUST (the region map's "debug dispatch stays in the orchestrator, delegating into
modules"), so the dispatcher is on the orchestrator and the 136 bodies are on the module.

---

## 5. Owner decisions (resolved 2026-08-19 -- recommendations adopted)

1. **Console access (Section 3):** RESOLVED -- shipped user build is MCM-only; the
   `PDV_DebugConsole` shim is greenlit as tester-build-only and hidden from users (not in the
   shipped FOMOD, not in MCM). Remaining owner input: the exact driver set the shim wraps.
2. **MCM property vs double-hop (2c):** RESOLVED -- keep the `PDV_Manager.DebugRuntime.X()`
   double-hop (a single mechanical find/replace, matches the ESP budget, negligible cost for
   user-triggered debug). A direct `PDV_DebugRuntime` MCM property stays available to F2 as an
   optional efficiency if it is already restructuring those pages, but D2 does not require it.
3. **Dispatcher placement (4):** RESOLVED -- `RunDebugCommand` + the 4 scratch registers stay on
   the manager (region-map ruling; keeps MCM's register writes unchanged). Only the 136 `Debug*`
   bodies move to `PDV_DebugRuntime`.
