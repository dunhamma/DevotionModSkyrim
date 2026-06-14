# PDV Final Polish Look -- Refinement Ledger

**Created:** 2026-06-15 (branch `claude/final-polish-look`)
**Scope (locked this session):** the player-facing *presentation/look* layer +
visual/branding assets. The functional friction / anti-farm / state-gating gaps from
`PDV_9Race_BetaAudit_2026-06-13.md` are OUT (separate burndown). The diegetic D1 visual
layer is IN (enable + tune).

## Why this exists

Much of the "look" work is already done on **live** but the live `.psc` source
(`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`) is **not git-tracked**, so
the repo drifted behind live (stale pre-rename snapshot). This ledger is the single
burndown list for the final-polish pass: it records what is already done-on-live (so it
is not redone), what is still pending, and what needs a decision -- with the proof gate
for each. The baseline that every diff below is measured against is
`generated/live-devotion-snapshot/2026-06-15-final-polish/`.

## How to read

- **State:** `done-on-live` (shipped on live, now captured in the baseline snapshot) /
  `pending` (designed, not built) / `decision-needed` (needs a product call) /
  `blocked` (waits on out-of-scope work).
- **Priority:** P0 lead-race / first-impression, P1 important, P2 nice-to-have.
- **Proof gate:** what makes the item *done* (machine = compile/verify; route = QASmoke;
  manual = in-game MCM-driven smoke). Diegetic items are not done on compile alone.

---

## WS-0 -- Branch + tracked baseline

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-001 | Isolation branch `claude/final-polish-look` | done | git | P0 | branch exists |
| FP-002 | Live-source baseline snapshot (85 psc + Devotion.esp + Devotion.seq, hashed manifest) | done | `generated/live-devotion-snapshot/2026-06-15-final-polish/` | P0 | manifest written, 87 items |
| FP-003 | CHANGELOG title `PlayerDevotion` -> `Devotion` | done | `CHANGELOG.md:1` (+ guide ref line 17) | P2 | edited |
| FP-004 | Beta-guide rename -> `Devotion_BetaTesterGuide.docx` | done | repo root | P2 | `git mv` done |
| FP-005 | MCM menu title `ModName = "Devotion"` | done-on-live | live `PDV_MCM.psc:1228` (in baseline) | P1 | verified on live; stale snapshot was the only "PlayerDevotion" |

---

## WS-1 -- Player-facing text / voice finish

### Already done on live (do NOT redo; captured in baseline)

| ID | Item | State | Where | Notes |
|----|------|-------|-------|-------|
| FP-010 | 10-race narrator-voice Survey rewrite (all races componentized) | done-on-live | live `PDV__ManagerQuest.psc` Get*SurveyText | compile 0/0, verify FAIL=0/PASS=2938, negative-grep clean |
| FP-011 | Survey helpers `GetPublicTierBand` / `GetCurrentStandingBand` / `GetBosmerComplianceBand` | done-on-live | live manager | per `PDV_VoiceConformancePass_Plan.md` |
| FP-012 | Shared player-tier surfaces routed (tier-up notice + Prisma tier/champion toasts) | done-on-live | live manager | tier-0 = `Distant`; lapse keeps `Wavering` |

### Pending -- the voice-pass "second batch" (ESP MESG wiring wave)

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-020 | Nord 11 god-voice commitment-offer MESG records (Shor, Tsun, Stuhn; Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth; + Talos) | pending | `Devotion.esp` MESG + wire | P0 | machine (verify) + manual offer read in-game |
| FP-021 | Curse-state MESG verify/conform (houseCARL) | pending | `Devotion.esp` MESG | P1 | verify + in-game curse onset/cure read |
| FP-022 | Champion-entry MESG binding | pending | `Devotion.esp` + manager | P1 | verify + in-game champion-entry read |
| FP-023 | Redguard neglect tight (<=80-char) texture MESG records | pending | `Devotion.esp` MESG | P2 | content_verify budget + in-game |
| FP-024 | Nord cured-vampire-scar `GetNordScarLabel` reword | pending | live manager | P2 | compile 0/0 + in-game label read |
| FP-025 | Khajiit Prisma posture-title display label | pending | live manager / Prisma | P2 | in-game toast read |
| FP-026 | Reward-description clarity: 1 record `PDV_Bless_Redguard_AncestorSpine_T1` append "(Effect: +3% Attack Speed.)" | pending | `Devotion.esp` MGEF/SPEL desc; spec `PDV_*RewardRecords.spec.json`; review `PDV_RewardDescriptionClarity_Review_2026-06-09.md` | P2 | reward-author --check + readback (257/258 already OK) |
| FP-027 | Startup copy rewrite (Dunmer blurb flagged) | pending (draft-first) | live `GetStartupCanonicalSummary` ~`:6822`, `STARTUP_ADVISORY_TEXT` ~`:353`; `handoff/PDV_PostD0_Sweep_Handoff_2026-06-08.md` task #18 | P1 | draft -> user review -> port -> compile 0/0 |
| FP-028 | Argonian toast grammar verify/reword ("the root will remember", "wake rooted", shadowscale ref) | pending (verify) | live manager (~lines 2210/2224/2280/2513) | P1 | confirm conformance-audit state, reword if mechanical; in-game |

### Blocked

| ID | Item | State | Where | Notes |
|----|------|-------|-------|-------|
| FP-030 | Altmer Survey final voice (alignment-path base) | blocked | live manager (interim Auri-El anchor) | depends on ThalmorAlignment track = unbuilt FUNCTIONAL work, OUT of this scope; keep interim base, revisit when that track lands |

---

## WS-2 -- Diegetic D1 visual layer (enable + tune)

State today: dispatcher hooks are **already live-wired** in `PDV__ManagerQuest.psc`
(`SurfaceTransition` -> `PDV_DiegeticDirectorService.Dispatch`, ~`:1488-1501`; call
sites `:5428` tier, `:6526` neglect, `:7892` tier, `:9536` curse). `PDV_DiegeticDirector.psc`
+ `PDV_DiegeticDeps.psc` are already in the live source dir (in baseline). This is
finish-and-prove, not build. Runbook: `references/authoring/PDV_DiegeticUX_LiveWrite_Runbook.md`.
V1 channels: screen (IMAD), sound (SNDR), music (MUSC), journal (DBF), medallion (DF MISC),
notify. Bodymark (NiOverride) + OAR anim are V2/excluded.

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-040 | Verify/complete D0 inert scaffold: `PDV_DiegeticDeps` + `PDV_DiegeticDirector` SGE quests in `Devotion.esp`, read-props wired, `D1Enabled=false`, scaffold compiled to live PEX, SEQ refreshed | pending (verify first) | `Devotion.esp`, runbook D0 section | P0 | `pdv_diegetic_ux_check` + D0 no-behavior-change smoke (no `PDV_Diegetic*` None/missing-prop warnings) |
| FP-041 | Create D1 channel records: IMAD x5, SPEL shader x4, SNDR x5, MUSC x1, MISC medallion, BOOK; wire each property on director | pending | `Devotion.esp` per `PDV_DiegeticUX.manifest.json` | P0 | records exist + wired (not "done" yet) |
| FP-042 | Set `D1Enabled = true`; keep soft-dep fallbacks conservative | pending | `PDV_DiegeticDirector` prop | P0 | verify FAIL=0 |
| FP-043 | Tune surface profiles (tone->channel table, ArchitectureSpec §3): shader bloom/vignette, sound cues, music bed, medallion/journal updates | pending | channel records + profiles | P1 | manual look review per transition |
| FP-044 | Counted transition proof (MCM dev-page driven) | pending | QASmoke / MCM Debug | P0 | tier x1, neglect x1, curse onset/cure x1 each; save/load guard integrity; deps-absent graceful |
| FP-045 | V1 exclusions: bodymark + OAR anim stay OFF | decision recorded | runbook Boundaries | -- | n/a (V2) |
| FP-046 | MCM verbosity preset (Silent default / Transitions-only / Verbose) wired + labeled | pending (verify) | `PDV_MCM.psc` | P1 | MCM toggle works; Silent default preserved |

---

## WS-3 -- Branding / visual assets

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-050 | Track `Devotion Main Banner.png`; decide home (repo root vs `assets/` vs Nexus-only) | decision-needed | repo root (untracked) | P1 | placed + tracked, or deliberately git-ignored |
| FP-051 | Nexus mod-page art (header, featured, gallery) | decision-needed | candidates in `scratch/prisma-art/` | P1 | asset set chosen |
| FP-052 | MCM splash/header image (if SkyUI MCM is to carry one) | decision-needed | `PDV_MCM.psc` | P2 | decide in/out |
| FP-053 | FOMOD installer vs single-folder install for 1.0 | decision-needed | none in repo today | P1 | install model chosen |
| FP-054 | Medallion item art (MISC `PDV_DevotionMedallion`) -- coordinate with D1 | pending (after FP-041) | `Devotion.esp` | P2 | model/icon assigned |

---

## Verification commands (apply per touched item)

- Compile: `node tools/pdv_compile.mjs --script <name>` -> 0/0
- Structural: `node tools/pdv_verify.mjs --json` -> FAIL=0
- Text gates: `node tools/pdv_content_verify.mjs` (voice/budget/ASCII) + `node tools/pdv_writer_review.mjs`; negative grep clean
- Diegetic preflight (dry-run, before any live D1 write): `node tools/pdv_diegetic_ux_check.mjs` + `node tools/pdv_diegetic_ux_author.mjs plan --json`
- Contract gate green: `node tools/pdv_completeness_audit.mjs`
- In-game: MCM dev-page driven (not cqf); D0 no-behavior-change first, then D1 counted transition proof.

## Sequencing

1. **This slice (done):** WS-0 FP-001..FP-004 + ledger.
2. **Next (review-gated):** WS-1 ESP batch (FP-020..FP-026 together via houseCARL, one
   backup + verify pass), then FP-027/FP-028 drafts for review.
3. **Then:** WS-2 D1 (verify D0 -> records -> enable -> tune -> counted proof).
4. **Last:** WS-3 asset decisions (FP-050..FP-053), medallion art (FP-054) folds into WS-2.
