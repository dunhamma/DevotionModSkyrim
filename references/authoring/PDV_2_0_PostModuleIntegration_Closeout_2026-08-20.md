# PDV 2.0 Post-Module Integration Closeout -- 2026-08-20

## Scope and branch authority

This checkpoint closes machine-verifiable integration work after ORIGIN, RECOGNITION, PRISMA,
and DEBUG extraction. It was produced directly in
`.claude/worktrees/v3-origin-extraction` on the primary feature branch
`feature/v3-big-update`; no intermediate feature-to-primary merge remains for this tranche.

This is static, compile, direct-record-readback, and generated-asset evidence. It is not
fresh-game, save/load, player-surface, performance, or release-package proof.

## Live record and SEQ reconciliation

Direct houseCARL consolidation removed 35 manager VMAD fills no longer declared by
`PDV__ManagerQuest.psc` and 25 later copies of identical names. The live manager QUST now has:

- 455 VMAD properties;
- zero present-but-undeclared fills;
- zero duplicate property names;
- intact references to the extracted runtime modules.

The pre-write ESP backup is
`generated/live-devotion-backups/vmad-consolidation-20260820/Devotion.esp.before-manager-vmad-consolidation.bak`.
Its SHA-256, matching the pre-write ESP, is
`9029D931C5A7F3B6976378A62B5A7D9CF09AF026288318DAADDFBE42CC9AFEEF`.

`pdv_refresh_seq.mjs` was corrected to honor `PDV_DEVOTION_ROOT`. Its read-only check then found
a real content mismatch: the authoritative `Devotion-V3Dev` ESP has 58 start-game-enabled quests.
The live SEQ was regenerated and its backup is
`D:/Wabbajack/modlists/Anvil/mods/Devotion-V3Dev/Seq/Devotion.seq.20260820-083351.bak`.
A second check reports `changed=false`, `questCount=58`.

## Gate hardening

- Manager VMAD gates now derive and read the complete property range in chunks, reject partial
  evidence, and test uniqueness rather than assuming a fixed tail index.
- `pdv_vmad_audit.mjs` now detects present-but-undeclared and duplicate-name properties, including
  Papyrus' case-insensitive property identity.
- `pdv_verify.mjs` recognizes the post-extraction Ledger and Prisma ownership boundaries.
- Shared symbol-family reconstruction strips stacked qualifiers such as
  `Manager.Prisma.*` and `Manager.LedgerRuntime.*` and selects substantive adapter overrides over
  empty base virtuals. Focused unit tests cover both cases.
- `pdv_prisma_ui_audit.mjs` follows the extracted Presenter, Debug, Recognition, Ledger, and race
  adapter owners. It no longer mistakes sequential sibling PEX mtimes for dependency freshness.
- Prisma and VMAD audits now inherit `PDV_DEVOTION_ROOT` from the shared path authority while
  preserving their narrower source-only overrides. This prevents a V3 run from silently mixing
  `Devotion-V3Dev` records or PEX with the retired `mods/Devotion` source tree.
- The Prisma audit now fails closed if tier and Chronicle text use a lowercase symbol key in place
  of the public deity display name.

## Machine acceptance

- Full clean Papyrus compile to a new output directory: 119 compiled, 119 unique PEX, 0 failures.
- Umbrella verifier: `FAIL=0 WARN=0 TODO=0 PASS=4098 INFO=100`.
- Prisma UI audit after decomposition-aware repairs: `PASS=133 FAIL=0`.
- Prisma extraction: 37/37; Debug extraction: 27/27.
- VMAD audit: 207/207 attachments, zero unwaived findings.
- Signal E2E: 41 surfaces green, 215/215 curated parity, 488 targets with 486 reachable and two
  reserved known gaps, zero failures.
- Broad pantheon, substrate pacing, pantheon record readback, and presentation readback pass.

The optional MO2 MCP subcheck on port 27016 was unavailable. That skip is not replaced by a
claim of MO2-tool proof; direct houseCARL readback and the repo verifier provide the static record
evidence stated above.

## Post-module optimization checkpoint

The trigger-first review preserved the single manager cadence and made four behavior-preserving
reductions:

- contextual favor snapshots the active lane/family once per one-second tick and writes its
  debug mirror only when the active-count value changes (inactive targeted StorageUtil work
  falls from four operations to one);
- five ordered Daedric per-tick calls cross the manager/module boundary once;
- seven ordered origin/content probe calls cross that boundary twice;
- completed unified-startup reconciliation is cached after load reconciliation, removing its
  steady-state StorageUtil read.

`pdv_ship_optimization_audit.mjs` now derives the exact 119-script-pair inventory from the release
manifest and fails closed if those contracts regress. `pdv_module_contract_sync.mjs` derives the
module contract from current source plus RegionMap and supersedes `e739f79f` as current authority.

Prisma's application and native bridge remain event/call-driven: there is no interval loop, the
deferred-overlay queue is bounded, and toast nodes self-remove. No code optimization is justified
by the static review. The duplicated TTF/WOFF2 font payload is a valid size experiment only after
an embedded-Prisma font-load and visual comparison proves one format can be removed.

## Residual issue ledger

### Fixed or guarded in this checkpoint

- Stale and duplicate manager VMAD fills.
- SEQ helper selecting the retired `mods/Devotion` root instead of the V3 target.
- Fixed-index VMAD reads that could silently miss moved properties.
- Manager-only audits producing false failures after extraction.
- Empty base virtuals shadowing substantive adapter implementations in audit parsing.
- Absence of a regression assertion separating public deity names from lowercase Prisma symbols.

### Deferred by design

- Formal-offer copy: direct readback found 45 offer records and 23 descriptions that do not
  explicitly contain their deity name. The exact EditorIDs are in `PDV_WordingRevisionBacklog.md`.
  The owner has reserved the rewrites, so no record copy was invented here.
- The observed lowercase Auri-El toast is not reproducible from current source: repository and
  live Prisma assets match byte-for-byte, and both JS and Presenter now statically prove use of the
  public deity field. Runtime must capture the loaded payload/cache state if the observation recurs.
- Baan Dar is not an Altmer deity; in this implementation his offer belongs to the Khajiit lane
  and remains excluded from Altmer eligibility. A tier-toast diagnostic is a separate presentation
  path, not an offer. Static reachability is guarded; the next runtime pass should still confirm
  that no Altmer run can select or receive a Baan Dar offer.

### Repository/module follow-ups

1. Revisit the intentionally deferred ORIGIN notification, state/detail, and stringly contextual
   signal/query seams only as a later design pass. The current source-derived contract is complete;
   migrate a remaining family only if it deepens the typed interface rather than recreating a
   distributed manager switchboard.
2. Decide the exact driver-set contract for the tester-only console shim; it remains outside the
   user payload and is not release-authorized.
3. Migrate `pdv_requiem_penalty_audit.mjs` to `tools/lib/pdv_paths.mjs` so a
   `PDV_DEVOTION_ROOT` V3 run cannot silently inspect the disabled public 1.5 tree.
4. Keep `e739f79f` as a reconciled historical baseline. Current authority is generated by
   `pdv_module_contract_sync.mjs`; do not hand-refresh another cast report.

## Human/runtime handoff

The next acceptance pass should cover only proof unavailable to the repository:

1. fresh-game initialization across the intended origin matrix;
2. save/load and race-change reconciliation, including removal of foreign focus state;
3. player-facing tier toast and Chronicle casing with current PEX/assets/cache;
4. negative Altmer reachability for Baan Dar and other foreign-race deities;
5. Papyrus log absence of manager missing-property warnings;
6. deterministic performance comparison after extraction;
7. owner-approved copy for the 23 formal-offer descriptions, followed by direct Message readback.
8. Kyne neglect application/removal on the V3 profile: Active Effects must show Frost Resistance
   `-8%`, broad-worship clearing must remove it, and the corrected state must survive save/load.
9. embedded-Prisma font-load and visual comparison before removing either duplicated font format.

Packaging and public readiness remain blocked on those independent proof buckets.
