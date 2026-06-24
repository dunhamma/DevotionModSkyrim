# PDV Session Wrap + Handoff -- 2026-06-25 (6f rites · Prisma · offers audit)

## TL;DR
A large autonomous build session. **All 6f variety rites are fully built + functional**
(Papyrus + ESP records + surfacing in both Prisma spaces), the **Prisma bridge was rebuilt +
redeployed**, **Nord commitment offers** landed, and the **formal commitment-offer scale-out was
audited + fully spec'd** (one open build). Every gate stayed GREEN throughout. The next session's
headline new work is a **Prisma Parity Audit** (planned in detail below) plus the formal-offer
scale-out build.

## Session commits (this session, newest first)
| Commit | What |
|---|---|
| `5092d19` | Formal-offer scale-out: audit + build spec (Codex handoff) |
| `bc8063b` | B10: 12 Nord non-Kyne commitment-offer records authored |
| `dbc393b` | Handoff update (records authored, bridge rebuilt) |
| `b068228` | Prisma a11y: prefers-reduced-motion |
| `bdfb9f7` | Prisma end-to-end tracking demo (Ledger + Chronicle) |
| `7862299` | 6f rites surface in both Prisma spaces |
| `4a134bf` | 6f rite records: 8 SPEL/MGEF + 3 MESG -> Devotion.esp |
| `2c3e26e` · `9b73bf2` · `14d9ac3` | Altmer / Redguard / Orc rite Papyrus |
| `5885cfc` | 6f gate-spec + ratified ledger rows + Prisma bridge rebuilt |
| `215348f` | Queue-B release-prep closeout |
(Queue A A1-A5 was committed by Codex earlier: `fb1c585`..`3153d8e`.)

## Current state -- all GREEN
`pdv_compile` 0/0 · `pdv_verify` FAIL=0 · `pdv_signal_e2e_gate` 39 GREEN / 0 RED, parity PASS ·
`pdv_signal_floor_audit` 51 PASS / 0 UNDER-FLOOR · `pdv_specced_minus_audit` 0 ·
`pdv_ledger_coverage_audit` untracked [] · `pdv_antifarm_sweep_audit` uncappedGain [] ·
`pdv_integrity_harness` PASS. **live-source <-> MO2 manager copies SYNCED.** New ESP records
backed up under `Backups/{6f-rite,nord-offer}/`. Prisma bridge DLL redeployed (`.bak-20260624`).

## New tools this session
- `tools/pdv-6f-rite-author` -- authors the 6f rite SPEL/MGEF/MESG (in-place + backup, fail-closed).
- `tools/pdv-nord-offer-author` -- authors the 12 Nord offer MESGs.
- `PDVDemoLedger()` / `PDVDemoChronicle()` in the Prisma view (`app.js`) -- runnable end-to-end
  proof of both surfaces with all new-work types.

## OPEN BUILD ITEMS
### 1. Formal commitment-offer scale-out (spec ready, NOT built)
Wire in-voice offers for **Imperial (9) / Dunmer (3) / Altmer (3) / Redguard (3)** + 7
quiet-emergence cues for the 5 by-design races + **add the Prince name as a TITLE** to the 16
Daedric offers. Full spec + owner rulings: **`PDV_HO_FormalOfferScaleOut_2026-06-25.md`**. The
gate `tools/pdv_formal_offer_check.mjs --source-only` lists every required snippet (~52);
acceptance = that gate PASS. Records via `pdv-phase20-race-author --author-rewards`. Owner ruling:
Option 1 (4 races only); Bosmer/Khajiit/Argonian/Orc/Breton stay by-design.
### 2. Prisma visual/contrast hardening (HO_PrismaHardening stages 3-4)
Owner-gated -- needs eyes on the rendered overlay. Bridge + a11y(reduced-motion) + tracking are done.

---

## PLAN: Prisma Parity Audit (next-session headline)

### Why
The owner rule is "the Ledger monitors ALL data points," and this session repeatedly found
surfacing GAPS (6f rites surfaced in neither space until wired; the formal offers + quiet-emergence
cues surface in neither toast nor journal for 5 races). We need a **systematic, registry-driven
audit** that proves every surface-worthy data point achieves PARITY across the three Prisma
surfaces -- no orphans, no silent gaps -- the same way `pdv_signal_floor_audit` proved signal
parity. This is the natural next "cross-cutting integrity" gate (see memory
[[cross-cutting-audit-doctrine]] and [[ledger-monitors-all-data-points]]).

### The three Prisma surfaces (verified this session)
1. **Toasts** (transient overlay) -- `ReceivePDVOverlayJson` -> `handleOverlayPayload`; fired by
   `SurfaceTransition` / `DispatchDiegeticCue` / `ShowToast`.
2. **Chronicle / Book of Days** (modal page 0) -- `AppendBookOfDaysEntry` -> `PDV.Diegetic.Journal.*`
   -> `BuildJournalPayloadJson` -> `renderJournal` (entries `{date,title,text,symbol,valence,magnitude}`).
3. **Ledger / "what feeds your gods"** (modal page 1 + interactive Today-tab `renderDashboard`) --
   `AwardPiety`/`RecordDeityDriver` -> `PDV.Driver.Reasons/Deltas` -> `GetDashboardJson`
   (gods `{god,symbol,system,state,pietyToday,piety,tier,drivers:[{reason,count,net,dir}]}`).

### Parity dimensions to score
- **A. Ledger completeness** -- every piety/signal AWARD records a `PDV.Driver.*` (so it lands in
  the Ledger). `pdv_ledger_coverage_audit` already covers this (untracked []) -- fold it in as
  dimension A and EXTEND to confirm no NEW award site bypasses it.
- **B. Chronicle completeness** -- every MILESTONE/narrative beat writes an `AppendBookOfDaysEntry`:
  tier-ups (all deities + Princes), neglect drops, rite-takes (6f), commitment offers accepted,
  "Prince takes notice", curse onset/cure, life-mode/sect/path shifts. Registry says which events
  are beat-worthy; audit greps the event site for the BoD call.
- **C. Toast completeness** -- every surface-worthy event fires a toast/cue (`SurfaceTransition` /
  `DispatchDiegeticCue`). The 7 quiet-emergence cues are known gaps (the by-design races' silent
  commitments don't currently announce). Registry says which events should toast.
- **D. Cross-surface consistency** -- the SAME event uses a consistent **symbol** + **deity name**
  + **voice/tone** across whichever surfaces it hits (e.g. a Malacath beat = "malacath" symbol in
  toast + journal + Ledger driver). Catches symbol/name drift.
- **E. Render parity** -- the JS renderers consume every field the manager emits (no dropped
  fields), and the demo harness exercises every surface. Deterministic field-contract diff between
  the `*Json` builders and the JS `render*` field reads.
- **F. Per-deity/per-race parity** -- every patron-capable deity can surface in the Ledger (piety
  path) AND has its commitment beat in the Chronicle. This is where the formal-offer gap and the
  6f-rite gap both lived; the parity audit would have caught both.

### Methodology (mirror the project audit doctrine -- gate-first, registry-driven, score-per-unit)
1. **Registry** `references/authoring/PDV_PrismaParityRegistry.csv` -- one row per data point:
   `id, eventClass, deity/race, expected_toast(Y/N), expected_chronicle(Y/N), expected_ledger(Y/N),
   emit_site_hint`. Seed it from: the deity roster (tier-ups), the 6f rites, the offers, the curse
   service, the substrate/life-mode/sect/path tracks, the under-floor signals, the Daedric beats.
2. **Gate** `tools/pdv_prisma_parity_audit.mjs` -- for each row, DETERMINISTICALLY verify the
   manager emits the expected surface call near `emit_site_hint` (grep for `AppendBookOfDaysEntry` /
   `RecordDeityDriver`+`AwardPiety` / `SurfaceTransition`+`DispatchDiegeticCue`), and that the JS
   renderer reads the corresponding payload field. Score per row per surface: PASS / GAP / N-A.
   Output `PDV_PrismaParityLedger.md` (generated-ledger-as-truth).
3. **DETERMINISTIC vs JUDGMENT split** -- "is the call present at the site" = script. "is this beat
   WORTH surfacing / is the voice/symbol right / does it read clearly" = a JUDGMENT agent pass over
   the GAP/ambiguous rows (mirror the formal-offer audit's agent fan-out).
4. **Self-test + adversarial** -- the audit self-tests (remove a known BoD call in a scratch copy,
   confirm it flags). An adversarial agent verifies a sample of "PASS" rows actually render in
   `PDVDemoChronicle()` / `PDVDemoLedger()` (extend the demo to cover the full registry).
5. **Roll into the harness** -- add `pdv_prisma_parity_audit` to `pdv_integrity_harness.mjs`.
6. **In-game proof** (owner-gated) -- the deterministic gate proves the data-layer parity; the
   demo functions + a new-save smoke prove the render. Keep these buckets separate (proof-boundary).

### Expected first-run findings (predictions to verify)
- Dimension A (Ledger): likely CLEAN (the coverage audit is green).
- Dimension B/C (Chronicle/toast): GAPS for the formal-offer scale-out events + the 5 by-design
  races' quiet-emergence (the same items the formal-offer gate flags) + possibly some tier-ups /
  curse beats that toast but don't journal (or vice-versa).
- Dimension F: the formal-offer scale-out is the big per-race gap; building it (open item #1) closes
  most of B/C/F at once.
- Sequence suggestion: do the **formal-offer scale-out build first**, THEN the parity audit (so the
  audit measures the post-fix state and catches the residual long tail).

---

## Phase 2 -- PROVE (owner, in-game)
New-save / `coc qasmoke` proof of the 6f rites + Nord offers; re-verify the 8 proven races on the
new signal dims; Requiem HP-bar feel; save/load + migration; perf/save-bloat audit. VMAD props bake
at first init -> new save, not an old one.

## Phase 3 -- RELEASE
Authoria/ARR integration package (hard 1.0 compat gate) + full distribution package (Nexus page,
feature overview, install/load-order, changelog, per-race explainers) -- both autonomously writable.

## Deferred (1.0.x / V2)
Experience Mode (Pilgrim/Wayfarer); CC AE catalog (Ghosts of the Tribunal -> Dunmer deviation, The
Cause -> Dagon); voiced dialogue; localization.

## Gotchas carried in
- **Sync live-source -> MO2 before every compile** (`.mjs` audits read live-source; `pdv_compile`
  reads MO2; stale MO2 = false GREEN). Left synced.
- **ESP authoring works** via the Mutagen author pattern (`pdv-6f-rite-author` / `pdv-nord-offer-author`
  / `pdv-phase20-race-author`): in-place + auto-backup + fail-closed; the dotnet build validates
  ActorValue enum names. Don't re-author existing records (Ensure* is idempotent).
- **Prisma bridge** rebuilds with portable xmake -- see memory [[prisma-bridge-build-xmake]]; views
  (`mod/PrismaUI/views/Devotion/`) are runtime-loaded, no build needed.
- **Rite grants** record a small piety pulse to surface in the Ledger; the 7-day cooldown is the cap.
- **Pre-existing**: the formal-offer gate flags a Dunmer Azura offer gap -- subsumed by the
  formal-offer scale-out (Dunmer is one of the 4 races).
- Model/cadence for the Claude<->Codex loop: memory [[model-choice-for-codex-handoff-loop]].
