# PDV End-to-End Design-Coverage Adversarial Audit + Backlog (2026-06-25)

**Purpose:** the "have we covered every design consideration?" sweep, run as the adversarial
integrity tool. Each category gets a status + evidence + backlog. COVERED = built & gated;
PARTIAL = built but incomplete/unproven; GAP = declared-but-not-wired or absent; DEFERRED =
deliberately out of 1.0; PROOF-GATED = built, awaits in-game proof only the owner can run;
IN-FLIGHT = a design Workflow is producing the spec this session. Sources: `PDV_TargetEndStates_1.0.md`,
`PDV_Architecture_v3.md`, the integrity harness ledgers, and this session.

## A. Coverage matrix (18 categories)

| # | Category | Status | Evidence / where | Backlog item |
|---|---|---|---|---|
| 1 | Core mechanics / economy (piety, tiers, decay, neglect, patron/broad, substrate, spine) | **COVERED** | v2 baseline proven; spine 7/7; harness PASS | — |
| 2 | Signal sourcing / floor breadth (5 types + 2 renewable/path) | **PARTIAL / IN-FLIGHT** | 28/51 PASS; 23 under-floor (mostly +1 renewable env/behavioural) | **B1** apply under-floor enrichment spec (Workflow `w9ywkug8q`) |
| 3 | Declaration→wiring→proof integrity (the silent-gap bug class) | **COVERED** | e2e gate 39/0, floor audit, specced_minus=0, dead-diegetic=0, integrity harness | keep gates green per change |
| 4 | Rewards / effects / magnitudes | **PARTIAL / PROOF-GATED** | records all-race T1/T2/T3 (readback 1280/0); magnitudes PROVISIONAL everywhere | **B2** magnitude feel-tune (esp. Requiem cohort); **B3** variety tranches 6f (Workflow `w24lhsscd`) |
| 5 | Anti-farm / exploit | **PARTIAL** | doctrine + caps on most signals; new emits this session anti-farmed | **B4** anti-farm sweep: confirm every signal has a daily/dawn cap |
| 6 | Balance / pacing / difficulty modes | **GAP (Experience Mode)** | pacing designed; Experience Mode design-locked but NOT built | **B5** build Experience Mode (Pilgrim/Wayfarer) — OPEN DECISION D1 |
| 7 | Save/load + migration | **PARTIAL** | VMAD-bake migration pattern (stance done); LD VERSION-gating; day-key handled | **B6** version-gated migration + new-save proof per new feature; **B7** harden live-manager tracking |
| 8 | Curse interaction (werewolf/vampire) | **COVERED (proof-gated edges)** | PDV_CurseState seam; per-race posture/halt/silence; Phase 15 runtime-proven | edge re-verify on new spine/signal dims |
| 9 | Daedric system + surfacing | **PARTIAL → GAP (surfacing)** | 16 Princes record/readback done; minus wiring done (6c) | **B8** wire Daedric into Survey + Book-of-Days (finding #21 — content-ready but unwired); **B9** Molag Bal faucet + thin-Prince Part D faucets; Daedric runtime/display proof |
| 10 | UI / copy / surfacing / diegetic | **PARTIAL** | Survey rewritten 10-race; D1 ON; Book-of-Days bespoke voice (Khajiit/Dunmer/Imperial/Altmer) | **B10** remaining narrator-voice polish (Argonian toast grammar, non-Kyne Nord offer copy, FP ledger); **B8** (Daedric surfacing) |
| 11 | Localization / text encoding | **DEFERRED + COVERED(encoding)** | ASCII/mojibake guard enforced (hook); localization = English-only, deferred (TES §23) | **B11** confirm English-only for 1.0 (OPEN DECISION D5); keep strings localizable |
| 12 | Performance / script health | **LIKELY-OK, UNAUDITED** | only 9 OnUpdate/RegisterForUpdate total; dawn 1s tick is the main loop | **B12** perf + save-bloat audit before external beta (papyrus-optimization pass) |
| 13 | Compatibility (Requiem + 7 lists + Creation Club) | **PARTIAL** | Authoria/ARR = HARD 1.0 gate; Survival/SunHelm toggle built; Requiem positive-conversion done; CC soft-dep pattern proven (InitSurvivalContext) | **B13** Requiem penalty re-author + HP-bar sweep; **B14** Authoria/ARR package; **B13.5** CC soft-dep integration (1.0: framework + S&S→Sheo + Fishing→Kyne; post-1.0: Tribunal→Dunmer-deviation, The Cause→Dagon) |
| 14 | Proof / verification ladder | **PARTIAL / PROOF-GATED** | machine✓, route/QASmoke✓ (6 packets), runtime/manual mostly Pending | **B15** run-sheets Dunmer/Imperial + RE-VERIFY 8 proven races on new spine/signal dims; Active Effects / save-load / feel notes |
| 15 | Accessibility | **PARTIAL** | font-blank/casing handled; notification readability | **B16** colorblind/notification-legibility pass (low priority) |
| 16 | Distribution / support / release prep | **GAP** | compat-package + player-copy skills exist; no shipped Nexus page/install/changelog | **B17** release prep: Nexus writeup, install steps, support boundary, changelog/versioning — OPEN DECISION D6 |
| 17 | Content richness / per-race 1.0 roster | **PARTIAL (Ratified/Static, in-game Pending)** | all 10 races + 16 Princes content-ratified; in-game proven mostly Pending | rolls up into B2/B15 |
| 18 | Voiced content / V2 boundary | **COVERED (release action pending)** | V1 = no voiced dialogue; CK-authored Nord recognition INFOs exist | **B18** release-prep: DISABLE/remove the V1 voiced-dialogue records from the ship ESP |

## B. Consolidated backlog (prioritized)

**Tier 1 — buildable pre-1.0 (assistants/Codex can grind):**
- B1 under-floor enrichment (23 paths) — spec IN-FLIGHT (`w9ywkug8q`)
- B3 variety tranches 6f (Altmer/Orc/Redguard) — spec IN-FLIGHT (`w24lhsscd`)
- B8 Daedric surfacing into Survey + Book-of-Days (real declared-but-unwired gap)
- B9 Molag Bal + thin-Prince Part D faucets
- B4 anti-farm sweep (confirm caps)
- DamageResist ceiling rescale to all races (only Orc done) → **B19**
- B5 Experience Mode build (large) — gated by **D1**
- B10 narrator-voice polish tail
- B18 disable V1 voiced-dialogue records (release action)

**Tier 2 — proof-gated (only the owner, in Skyrim):**
- B15 run-sheets (Dunmer/Imperial) + re-verify 8 races on new dims
- B2 magnitude feel-tune (Requiem cohort) + B13 Requiem penalty feel + HP-bar sweep
- B6 new-save migration proofs; B12 perf/save-bloat audit

**Tier 3 — release/compat:**
- B14 Authoria/ARR integration package (HARD 1.0 compat gate); 6 lists patch-packaged
- B17 distribution/support/release prep
- B7 harden live-manager tracking; B11 localization confirm; B16 accessibility

**Watch items (flagged this session):**
- BROKEN_FAITH_KIN hook (6c) — confirm or retune → **D7**
- argonian_hist/people quest-reaction — by-design, open to reinterrogation

## C. Decisions resolved (grill, 2026-06-25)
| # | Decision | Ruling |
|---|---|---|
| D1 | Experience Mode | **DEFER to 1.0.x** — ship 1.0 on the proven Pilgrim mode |
| D2 | Daedric surfacing (B8) | **MUST-FIX pre-1.0** — wire into Survey + Book-of-Days (placeholder copy OK) |
| D3 | Proof sequencing | **BUILD then prove** — finish 1.0 build items, then one consolidated proof pass |
| D4 | DamageResist rescale (B19) | **RESCALE ALL now** (spec-only, ahead of playtest) |
| D5 | Localization | **ENGLISH-ONLY 1.0** — keep strings localizable for a later community pass |
| D6 | Distribution | **FULL package** — Nexus + overview + install + compat boundary + changelog + player guide/FAQ + per-race explainers |
| D7 | BROKEN_FAITH_KIN | **KEEP** the Legion-Exile-desertion hook (player-driven, anti-farmed, reversible) |
| D8 | Notoriety hostile-on-sight | **BUILD for 1.0** (owner override of the shelve rec) |
| D9 | Uninstall | **BUILD best-effort cleanup** (strip spells/effects + halt loops + faction removal + best-effort StorageUtil clear) + keep the "save-first" warning |
| D10 | CC coverage scope | **HYBRID** — author present religious CC (S&S→Sheo) now + soft-dep framework extensible to the AE catalog later |
| D11 | Ghosts of the Tribunal | **TENSION/DEVIATION** — route via existing `HandleDunmerDeviationPrice`, NOT a new worship lane |
| D12 | CC integration depth | **TIERED** — hook CC beats into existing Prince paths; heavier new-record work only for genuinely new targets (Tribunal) |
| D13 | CC timing | **Framework + Authoria-present CC in 1.0** (S&S, light Fishing); AE religious catalog (Tribunal, The Cause) post-1.0 |

## D. Ordered 1.0 plan (build-then-prove)
**Phase 1 — Build (assistant/Codex grind; both specs already in hand):**
1. Apply **under-floor enrichment** (B1) — 23 paths, dominant fix +1 env/behavioural renewable. Spec = Workflow `w9ywkug8q` (canonical recipe: manager `Handle<Race><Signal>` + anti-farm key + substrate/deity double-route; sleep/location/faucet seams identified).
2. Apply **6f variety tranches** (B3) — Altmer/Redguard mostly missing, **Orc already PARTIAL**. Spec = Workflow `w24lhsscd` (Bosmer Naming rite is the template; one-active/clear-before-add/dawn-fade-restore contract).
3. **Daedric surfacing** into Survey + Book-of-Days (B8/D2) — also hosts CC Prince surfacing.
   - **Creation Club coverage (B13.5):** soft-dep framework + S&S→Sheogorath + light Fishing→Kyne; Tribunal/Dagon post-1.0. Full detail in the approved plan addendum.
4. **Notoriety hostile-on-sight** (D8) — PDV faction + AddToFaction toggle gated on Vigilants-alive.
5. **DamageResist rescale** all races (D4).
6. **Best-effort uninstall cleanup** path (D9).
7. **Anti-farm sweep** (B4) + **Molag Bal / thin-Prince Part D faucets** (B9).
8. **Release prep build actions:** disable V1 voiced-dialogue records (B18); narrator-voice polish tail (B10).

**Phase 2 — Prove (owner, in Skyrim — the bottleneck):** run-sheets Dunmer/Imperial + RE-VERIFY the 8 proven races on new spine/signal dims; magnitude/Requiem HP-bar feel; save/load + new-save migration proofs; perf/save-bloat audit (B12).

**Phase 3 — Release:** Authoria/ARR integration package (HARD compat gate) + 6 lists patch-packaged; FULL distribution package (D6).

**Deferred to 1.0.x / V2:** Experience Mode (D1); voiced dialogue; localization (keep localizable); deep accessibility pass.
