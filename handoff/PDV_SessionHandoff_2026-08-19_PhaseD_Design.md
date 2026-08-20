# PDV Session Handoff -- Phase D design gates landed (2026-08-19)

Branch: `claude/vibrant-goodall-d0d8c4` (worktree `workplan-confirmation-203010`). Design-only
session; no `.psc`/ESP/manifest/region-map changes. Nothing pushed.

## What landed (committed, owner-signed-off)

Three Phase D design docs under `references/authoring/`, all DRAFTS the owner reviewed and accepted:

1. **`PDV_2_0_PRISMA_PresentationHook_Design.md`** (D1) -- commit `7dc3e383`. The ORIGIN->PRISMA
   seam (plan D8: ORIGIN owns per-race content, PRISMA owns the JSON envelope). 8 ten-race switches +
   ~18 lighter race branches enumerated from the CURRENT file. Frozen set: **7 new named virtuals +
   reuse `GetSurveyFragment`** on `PDV_OriginRuntimeBase`. 5 switches map clean; **3 composites**
   (`GetBookOfDaysPathStatusLabel`, `GetPlayerMcmSummaryLine`, `GetSurveyDevotionText`) -- hook
   replaces only the tail switch; the Nord scar in `GetSurveyDevotionText` needs the
   `GetOriginDetailLabel("scar")` compose or it drops silently.
2. **`PDV_2_0_DEBUG_ModuleBoundary_Design.md`** (D2) -- commits `834d68fb`, sign-off `74f3378a`.
   9th module `PDV_DebugRuntime` for the 136 `Debug*` fns (none `Global`; MCM-only preserved).
   Backref = duplicate the manager's 7 module props + a `Manager` backref (verbatim body moves).
   `RunDebugCommand` + registers stay on the manager. Console shim = tester-build-only, hidden from
   users (owner-confirmed).
3. **`PDV_2_0_MCM_Scope_Design.md`** -- the MCM cleanup/revamp scope for a single END-of-2.0 pass.

## Owner rulings captured (do not relitigate)

- D1: text-fragment seam; base virtual surface; extend the ADR named-virtual+detailKey hybrid;
  fallbacks stay PRISMA-side; `GetMcmSummaryLine(standingLabel)` takes standing as a param; accept
  the 3-composite tail-replacement + Nord scar-compose.
- D2: MCM-only shipped debug; tester `PDV_DebugConsole` shim hidden from users; Manager double-hop;
  dispatcher stays on the orchestrator.
- MCM revamp (build deferred to end of 2.0): Experience Mode full page + records (houseCARL mints
  GLOB/QUST); F2 full by-module debug reflow; **full ST native-control rewrite** (retire ~180 `_oid`;
  source real SKI_ConfigBase sigs from the SkyUI BSA first -- drift compiles green, breaks at
  runtime; hybrid is the fallback); accessibility two-tier (always-on strict-clarity wins only vs
  opt-in aesthetic-cost items); localization externalized to `$`-keys + `Devotion_ENGLISH.txt`;
  4 shipped tabs incl. a dedicated Accessibility page.

## Prerequisites this surfaced for later phases

- **A2 (region map) is a hard blocker for E2.** The PRISMA function LINE numbers in
  `PDV_2_0RegionMap.json` are stale (built from the 28k pre-extraction golden; current manager is
  10,736 lines). Names are valid, ranges are not. PRISMA extraction reads that map -- rebuild it
  first. Same map has a 127-vs-136 `Debug*` drift (9 Sanguine-consent adds post-date the golden) and
  a `RepairBookOfDaysJournalText` entry absent from the current file.
- **Standing compile rule:** recompile `PDV_MCM` after the manager or `pdv_prisma_ui_audit.mjs`
  FAILs on PEX-freshness.

## Next

Phase D (design gates) is complete. The extraction phases that consume these gates are source-
mutating and out of this session's design-only scope:
- **E1 RECOGNITION -> E2 PRISMA** (producer-first; E2 builds against the D1 frozen hook; remap the
  `GetNpcRecognitionPanelJson` concat at `PDV__ManagerQuest.psc:2391`).
- **F1 DebugRuntime + F2 MCM by-module reflow**, then the MCM revamp pass per the scope doc.
Do A2 (region-map rebuild) before E2.
