# PDV 2.0 ground-up rebuild — session handoff (2026-08-18)

**Branch:** `feature/v3-big-update` · **Mod folder:** `Devotion-V3Dev` · **Kind:** LIVING until pilot lands.
**Plan of record:** `~/.claude/plans/modular-mixing-lampson.md` (the full parallelized plan — 8 modules,
dependency spine, E2E pilot, per-module optimize, two-tier parity, compile/PEX discipline).

**UPDATE (later same session): E2E extraction mechanism is PROVEN.**
- Region map v2 is EXHAUSTIVE + independently verified: all **1351** functions in exactly one bucket
  (0 missing / 0 dup / 0 extra vs golden). Counts: ORIGIN 667, LEDGER 220, MANAGER 184 (incl. **128
  Debug\*** — decide debug home before extracting them), PRISMA 115, DAEDRIC 48, FAVOR 33, RECOGNITION 31,
  QUESTREACTION 28, RULES 25. Ledger = 2073 rows.
- **Module mechanism decided:** RULES (0 props) → **Global library** `PDV_DevotionRules` (`Scriptname` +
  `Global` fns, no extends, called `PDV_DevotionRules.X()`). FAVOR (42 props) → instance script.
- **Pilot proof done:** extracted `AbsInt` end-to-end (created `live-source/.../PDV_DevotionRules.psc`,
  removed from manager, rewired its 1 caller). Both compile 0/0 from live-source (isolated output; V3
  folder untouched). Parity `--compare` = 1349 unchanged / 2 changed (AbsInt=moved+Global, FormatTwoDecimals=
  call-site) / 0 removed. The architecture works.
- **Pilot findings:** 3 "RULES" fns are NOT Global-safe (read instance state) → reclassify:
  `GetBuildVersion` (reads PDV_BUILD_VERSION → MANAGER), `GetDebugLevel` (67 callers), `GetDeityFormOrNone`.
- **Harness enhancement needed before bulk RULES:** add `--body-only` mode (fingerprint excl. decl line) so
  Global-conversions read as MOVED, leaving only call-site edits to review. Then **re-capture the golden with
  the enhanced harness from a clean pre-extraction state** (current golden lacks the new field; live-source is
  now post-AbsInt, so recapture from a reverted copy or git-restore the manager first).

**RULES COMPLETE (verified):** 19 fns extracted to Global lib `PDV_DevotionRules.psc` (AbsInt + 18), each
`Global` + `; @module: RULES` tag. 485 call sites rewired (all in the manager); compile 0/0; body-only parity
0-removed, every change qualification-only. **6 fns reclassified OUT of RULES** (pilot proved not Global-safe —
they read a global property or call manager instance fns): `GetDebugLevel`, `GetBuildVersion`,
`GetDeityFormOrNone`, `NormalizePublicDeityDisplayText`, `ConsumeDailyRepeatMultiplier`,
`ConsumeOncePerDaySignal` → stay in MANAGER for now (`Consume*` likely → LEDGER when it's extracted). **TODO:
update `PDV_2_0RegionMap.json`/ledger to move these 6 from RULES → MANAGER.** Golden re-baselined post-RULES
(`_parity_golden.json`). Extraction rule learned: a Global fn cannot call a same-script non-global fn (compiler
error), so only truly stateless leaves can be Global-library members.

**STATEFUL-MODULE PATTERN DECISION (2026-08-18):** stateful modules (FAVOR, LEDGER, ORIGIN, DAEDRIC, PRISMA,
RECOGNITION) hold filled Form/Spell properties → they need a **QUST host record**. Chosen approach: **QUST host,
batch the ESP work later** — extract module `.psc` logic headlessly now (unfilled property decls + a
`PDV__ManagerQuest Property` backref for calls to not-yet-extracted modules; compiles fine, inert until wired),
and do ALL the ESP record creation + property filling in ONE coordinated houseCARL/V3-profile session before
runtime testing (Gate B). 1.5.0e is DONE, so the shared MO2 toggle is free for that batched session (still
confirm the active profile before flipping). NOT the Global+GetFormFromFile pattern.

**MIGRATION SWEEP step 1 DONE (verified):** removed `RepairBookOfDaysJournalText` + `ShouldPruneDeferredAltmerJournalLine`
+ 3 call sites (OnInit/OnUpdate/BuildJournalPayloadJson); reconciled the coupled `pdv_prisma_ui_audit`
`migration-missing` assertion. Compile 0/0; parity removed=2 (matches retire ledger), changed=3, added=0. Golden
re-baselined post-sweep (1349 fns).

**GATE FINDING — G6 should move up:** extraction is now breaking gate needles that pin bare function names. First
casualty: `pdv_prisma_ui_audit` broad-pool check FAILs because it pins bare `ClampValue(...)` which RULES
extraction qualified to `PDV_DevotionRules.ClampValue`. (The other 2 prisma FAILs are PEX-freshness = not-yet-
deployed to Devotion-V3Dev, resolved at Gate B.) **Do G6 gate-modernization (ledger-generated gate needles)
BEFORE heavy extraction** so gates stay truthful instead of going stale one needle at a time.

**G6 DONE (mechanism built + proven):** `tools/lib/pdv_symbol_home.mjs` — a ledger-driven resolver
(`symbolHome`/`callTokenPattern`/`definitionFile`/`isRetired`) that tells a gate a symbol's current
module/script + qualified call form + real definition file, from the region map + ledger. Gates now derive
needles instead of hardcoding them, so extraction won't re-stale them. Converted `pdv_prisma_ui_audit`,
`pdv_prisma_roster_parity`, `pdv_verify`, `pdv_prisma_to_oneoh_audit`; fixed the JsonSafeString definition
check to read the extracted `PDV_DevotionRules` (was silently reading the 1.5 install). Committed `3c7d459f`.
When future modules extract, convert any remaining symbol-pinning gates the same way (use the resolver, don't
hand-patch). Reclassification (6 fns RULES->MANAGER) also committed; region map RULES=19, MANAGER=190.

**FAVOR EXTRACTION SPEC READY** (`references/authoring/PDV_2_0_FAVOR_ExtractionSpec.md`, committed `d6098fb0`) +
**G2 interface freeze** (`PDV_2_0ModuleContracts.manifest.json`). FAVOR is now a known extraction: 33 fns / 42 props,
calls 11 manager fns (→ `Manager.X()` backref), externally tiny (3 call sites, all in `PDV_MCM.psc`; 0 external
prop refs), ~43 manager-internal call sites → `FavorRuntime.X`. **PREREQUISITE (must-do first): add
`PDV_DeityBase Function GetActiveDeity()` to the manager** — FAVOR reads `_activeDeity`, a bare VARIABLE not a
property, unreachable by backref. Coupled-fn flags: ResolveEligibleFavorLane (worst), SendContextualFavorToast,
IsValidAltmerSourceFavorFamily (bidirectional — stays in manager, review the pair). `GetNordPantheonBaselineState`
sits in FAVOR's line span but is NOT FAVOR — move by name only. 16 `Spell Auto` props need CK fills later; 26
`AutoReadOnly` consts move verbatim.

Next (single careful manager lane, per the spec): FAVOR code extraction — (1) add `GetActiveDeity()` accessor;
(2) create `PDV_ContextualFavorRuntime extends Quest` (Manager backref + 42 unfilled prop decls); (3) move 33 fns
as instance methods with the backref/qualified rewiring; (4) add manager `FavorRuntime` property + rewire the
~43 internal + 3 MCM call sites; (5) validity-compile 0/0 + parity (compile is the main net — the harness tracks
functions, not the property migration); ESP host record + fills deferred to the batched session. THEN migration
sweep step 2 (AncestorSpine — grant-fact decision) + Part B/C/D, then GATE 0.5. Everything below is original context.

---

Stopped mid-groundwork on a **usage-limit** (resets ~11:20am Australia/Sydney); limit later lifted, work resumed.

## Done this session (all on V3 only; live 1.5 `Devotion` untouched)
- **Version `2.0.0-dev`** stamped in `Devotion-V3Dev` manager+MCM source, recompiled, PEX-verified
  (`PDV_BUILD_VERSION` @ `PDV__ManagerQuest.psc:607`). Live 1.5 folder is `1.5.0e` and being worked
  concurrently — **do not flip the MO2 profile, do not touch `mods/Devotion`.**
- **Docs:** stale `PDV_1.1_*` reconciled → `references/authoring/PDV_2.0_Branch_Cleanup_and_Decomposition_Plan.md`.
- **G6a DONE:** `tools/lib/pdv_paths.mjs` single resolver; 11 tools (incl. `pdv_verify`) migrated to one
  `PDV_DEVOTION_ROOT`. **Set `PDV_DEVOTION_ROOT=D:/Wabbajack/modlists/Anvil/mods/Devotion-V3Dev` or V3
  gates silently audit 1.5.** V3 prisma gate is green when pointed right.
- **G1 DONE:** `tools/pdv_parity_snapshot.mjs` — static parity harness (per-function body fingerprint,
  comments/strings handled). Validated: deterministic, self-compare = 1351 unchanged / exit 0. Golden:
  `_parity_golden_manager.json` (worktree root, gitignored) = **1351** function/event decls.

## Key findings (do not re-derive)
- **Manager has 1351 functions, not the partition's ~701.** Verified (1345 EndFunction + 6 EndEvent).
  The partition draft's `decl..next-decl` method swallowed ~650 decls (e.g. `AppendBookOfDaysEntry`
  vanished into `BuildJournalPayloadJson`'s range).
- **`references/authoring/PDV_2_0RegionMap.json` + `PDV_2_0Retirement.manifest.json` are v1 = 701/1351
  = INCOMPLETE. NOT safe to extract from.** FAVOR in particular is missing its runtime core.
- **Classification needs BODY reading, not regex.** `/favor/` matches: the Disfavor economy (~25 fns
  `14551-14982` → LEDGER or its own subsystem), per-race favor (Bosmer/Altmer/Imperial/Nord → ORIGIN),
  `GetActiveLunarFavoredFocus` (Khajiit → ORIGIN). Only the ContextualFavor runtime is FAVOR.

## NEXT (after limit reset) — resume here
1. **Redo the exhaustive reclassification** over the golden 1351 (the failed agent's task, `general-purpose`,
   reading bodies). Master list = `_parity_golden_manager.json`; every one of 1351 → exactly one of the 9
   buckets (RULES/FAVOR/QUESTREACTION/LEDGER/ORIGIN/DAEDRIC/PRISMA/RECOGNITION/MANAGER). Rules:
   - `Debug*` + `RunDebugCommand` (~60) → **MANAGER** (debug dispatch; delegate into modules).
   - **FAVOR** = the v1 map's 25 getters **+ these 8 runtime fns** (verified true ContextualFavor):
     `EvaluateKyneContextualFavorFamily`(18344), `UpdateContextualFavorRuntime`(18348),
     `SyncKyneFavorDebugState`(18362), `SendContextualFavorToast`(18418), `EnsureActiveFavorApplied`(18438),
     `ClearActiveFavor`(18456), `GetFavorCooldownDays`(18579), `SetSelectedContextualFavorLane`(19533).
   - Disfavor `*Disfavor*` → LEDGER (or own subsystem — decide). Per-race `*Favor*` → ORIGIN.
   - `AwardPiety*` → LEDGER. `*Recognition*` → RECOGNITION. queued-quest-reaction txn → QUESTREACTION.
   - actions: externalize `GetPrinceEventTypes`+`GetLikesDislikesEventTypes`; retire
     `RepairBookOfDaysJournalText`+`ShouldPruneDeferredAltmerJournalLine`+AncestorSpine_T1 strip;
     retain MANAGER; extract the rest. NEEDS-REVIEW: gain-pipeline seam, presentation aggregators,
     HandleTalosBetrayal, recognition wiring.
2. **Verify** with the reconcile check (0 missing / 0 dup vs golden):
   `node -e` loading `_parity_golden_manager.json` + region map; assert all 1351 names covered once.
3. **G2 contracts** for RULES + FAVOR (`references/authoring/PDV_2_0ModuleContracts.manifest.json` + inert
   `.psc` skeletons that compile).
4. **G5 migration sweep** (manager free before extraction): remove `RepairBookOfDaysJournalText`
   (`:23892-23943`) + helper + `repairVersion` + 3 callers (`:991`,`:1088`,`:23778`); reconcile coupled
   gate `pdv_prisma_ui_audit.mjs:881-887` in same commit. AncestorSpine_T1: resolve grant-fact first.
5. **E2E pilot:** extract RULES → FAVOR. Per module: validity-compile 0/0 (isolated `PDV_COMPILE_OUTPUT_ROOT`)
   → snapshot + `--compare` vs golden (moved=OK, changed=verify call-site-only, removed=ledger) → gate-regen
   → per-module optimize. Runtime golden-capture (game session, owner-in-loop) at Gate B.

## Commands
- V3 gates: `PDV_DEVOTION_ROOT=D:/Wabbajack/modlists/Anvil/mods/Devotion-V3Dev node tools/<gate>.mjs`
- Compile (V3, isolated): `PDV_COMPILE_SOURCE_ROOT=.../Devotion-V3Dev/Scripts/Source PDV_COMPILE_OUTPUT_ROOT=.../Devotion-V3Dev/Scripts node tools/pdv_compile.mjs --script <Name> --skip-verify`
- **Recompile `PDV_MCM` after the manager** or the prisma PEX-freshness gate FAILs.
- Parity: `node tools/pdv_parity_snapshot.mjs --snapshot <out.json> <file.psc>` ; `--compare <golden> <current>`
- Task board is in the session task list (#1 G1 done, #11 G6a done; #3 G3 in progress = v1 incomplete).

## Do NOT
- Touch `mods/Devotion` (live 1.5.0e, actively worked) or flip the MO2 profile.
- Extract from the v1 region map — it's 701/1351.
- Commit `_parity_*.json` (gitignored) or any regenerable report.
