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

## Closeout status -- 2026-06-17

Final-polish look pass is essentially complete. Net new since the last update:

- **WS-2 D1 diegetic: DONE + proven in game.** Tones tuned and accepted (FP-043),
  counted real-transition proof passed (FP-044: tier / curse onset / curse cure /
  neglect all fire their real surfaces), D1 sound fixed (`RebindSounds` self-heals
  stale `Sound`/SOUN bindings), tier-up dispatch fixed for the active patron, and
  **`D1Enabled = true` baked so D1 ships ON for new games (FP-042b)**. Dev-page test
  tools added (per-tone previews, music-bed toggle, Force neglect); documented in
  `PDV_DiegeticUX_LiveWrite_Runbook.md`.
- **WS-1 startup copy: DONE.** Advisory + per-race summaries trimmed; the choice flow
  is now a clean **two-screen select -> per-path confirm** for all four choice races
  (Breton/Redguard/Orc/Bosmer): capitalized `Race - Path` header, one-paragraph
  description, semicolon punctuation, Walk this path / Choose again. The old middle
  detail screen is removed for every race; selects use colons. Orc button->life-mode
  order fixed; Bosmer select authored in path-state order.
- **FP-049 Book of Days:** open/close + aged-parchment skin built; the *look* is
  backlogged to the design pass (PrismaUI caches the view per process -- full restart
  to see it).
- **Out-of-scope bug fixes done this session:** Kyne reward stacking (legacy Phase-4
  boon system decommissioned + one-time save migration `MigrateLegacyBoonsIfNeeded`);
  the "Kyne champion offer" was a design-understanding question (Formal Commitment
  Offer, a pre-patron event -- not a bug).

Remaining: WS-3 branding decisions (FP-050 banner, FP-051 Nexus art, FP-052 MCM
splash, FP-053 FOMOD, FP-054 medallion art) and the FP-049 journal look (design pass).

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

### RECONCILED 2026-06-15: the ESP "second batch" was ALREADY BUILT on live

Verified this session via houseCARL record reads + `node tools/pdv_verify.mjs`
(**FAIL=0 / PASS=3028** on live). The records exist in `Devotion.esp`, properties are
filled (verify would FAIL on an unfilled required property), and the `.psc` wiring is in
place. **Do NOT re-author these** -- the consolidated 2026-06-14 Codex pass already did,
via `PDV_ConsolidatedBuildPass_RecordWave.spec.json`. The plan's "REMAINING" list (which
seeded the original rows here) was stale.

| ID | Item | State | Evidence |
|----|------|-------|----------|
| FP-020 | Nord 13 commitment-offer MESG (Kyne + 12) + 3 OfferResponse | done-on-live | records `071513-071522`; props `PDV__ManagerQuest.psc:388-403`; per-god selector `:9144-9168`; Shor body == drafted copy |
| FP-021 | Curse-state MESG, all 5 races (Nord/Altmer/Redguard/Khajiit/Argonian) | done-on-live | records present (`07150E-07152A`, `070525-070527`, ...); bodies conformed from `RecordCopy.md` |
| FP-022 | Champion-entry MESG (Redguard Crown/Forebear/AshAbah, Nord Kyne, 16 Daedric) | done-on-live | records `0714E4-0714E6`, `071526`; props `:364-366`/`:407`; shown via `ShowRedguardMessage(prop, fallback)`; verify clean => props filled |
| FP-023 | Redguard neglect texture MESG | done-on-live | authored in the record-wave spec |
| FP-024 | Nord cured-vampire-scar `GetNordScarLabel` reword | done-on-live | live `:13450` returns the reworded line verbatim |
| FP-025 | Khajiit Prisma posture-title display labels | done-on-live | live `:3851-3855` => "Lattice strained/thinned" / "Drifting to shadow" |
| FP-031 | ThalmorAlignment reputation-track record + global | done-on-live (record) | `PDV_RepTrack_ThalmorAlignment` + `PDV_GLO_ThalmorAlignment` authored in the wave; SIGNAL-FEEDING (functional) is separate + out of scope |

### WS-1 player-text closeout (both done on live 2026-06-15)

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-027 | Startup ADVISORY rewrite (ends "...will shape your devotion") | done (advisory) -- in-game length check pending | live `STARTUP_ADVISORY_TEXT` `:475` ported 2026-06-15; compile 0/0, verify FAIL=0/PASS=3028. Per-race blurbs INTENTIONALLY left as current to avoid the "shape your devotion" double-up (user call). | P1 | machine done; MANUAL: glance the startup MessageBox in-game for overflow (advisory is long) |
| FP-028 | Argonian substrate toast voice | done (live) -- in-game read pending | live `:2386/2400/2456/2723/2724` reworded 2026-06-15 (bed / rooted-rest / adaptation / shadowscale + Prisma mirror). `:2400` = "You wake feeling rooted." (user wording). compile 0/0, verify FAIL=0. | P1 | machine done; MANUAL in-game read |

### Closed by verification (were "pending" in error)

| ID | Item | Finding |
|----|------|---------|
| FP-026 | Reward-description magnitude clause (Redguard AncestorSpine T1) | ALREADY SATISFIED. The T1 bless's real effect is MGEF `071193` (ResistMagic), whose live desc already reads "...Magic Resistance +3%." (magnitude=3). The 2026-06-09 review was stale twice: wrong record (`071076`, an unused flavor MGEF) and wrong stat ("Attack Speed"). Optional hygiene-only follow-up: confirm `071076` is orphaned (not player-facing; out of "look" scope). |

### Blocked / partially unblocked

| ID | Item | State | Where | Notes |
|----|------|-------|-------|-------|
| FP-030 | Altmer Survey alignment-path base swap | partially unblocked | live manager (interim Auri-El anchor) | the ThalmorAlignment TRACK record now exists (FP-031), so the Survey base CAN swap -- but it depends on the track being FED by signals (functional, OUT of scope). Keep the interim Auri-El anchor until the functional track is wired. |

---

## WS-2 -- Diegetic D1 visual layer (enable + tune)

**RECONCILED 2026-06-15** (investigation workflow `wf_940b12ea-bda`; full plan in
`references/authoring/PDV_DiegeticD1_BuildoutPlan_2026-06-15.md`): **D1 is already BUILT on
live.** All 17 channel records exist (`071484-07149F`), all 23 `PDV_DiegeticDirector` props
are wired, D0 scaffold complete + PEX compiled, `D1Enabled=false`. "Enable" = flip ONE flag.
V1 visible channels are really **screen (IMAD+shader) / sound / music / notify**; medallion +
journal fall back invisibly (DF + DBF NOT installed). Bodymark + OAR = V2/excluded.

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-040 | D0 inert scaffold (quests SGE, read-props wired, `D1Enabled=false`, PEX compiled) | done-on-live | Director `07149A`, Deps `071499`; manager service link filled | P0 | verified (5/5 PASS) |
| FP-041 | D1 channel records (IMAD x5, SPEL x4, SNDR x5, MUSC, MISC, BOOK) + props wired | done-on-live | `071484-07149F` all present; 23 props filled | P0 | verified (17/17 records, 23 props) |
| FP-042a | Runtime D1 toggle (MCM Debug: State page) | done (live, compile 0/0 verify FAIL=0) | `PDV_MCM.psc` "Diegetic surfaces (D1)" button + manager `DebugGet/SetDiegeticD1Enabled`; flips `07149A.D1Enabled` in-session on the CURRENT save | P0 | machine done; in-game: flip On, fire transitions via existing debug buttons |
| FP-042b | Ship bake: ESP `D1Enabled = true` (for new players) | pending -- after tuning approved | `PDV_DiegeticDirector` `07149A` VMAD; live ESP write (houseCARL-off-Anvil) | P0 | **NEW-save** counted proof (VMAD bakes); do AFTER feel is signed off |
| FP-047b | Deploy Anvil -> ARR for Authoria play-test | NOT NEEDED (junction) | ARR `mods\Devotion - PlayerDevotion Local Test` is a JUNCTION -> `Anvil\mods\Devotion` (same files). All Anvil edits auto-appear in ARR; no copy step ever. (Earlier "separate copy" note was wrong -- checked a non-existent unsuffixed path.) | P1 | auto-synced; only a Skyrim restart loads new .pex/UI |
| FP-043 | Tune by feel + confirm 3 candidate records (dread shader `0ABEFF`, Hollow `057C63`, Distant `03F363`) | pending (post-enable, iterative) | channel records | P1 | in-game look review per tone |
| FP-044 | Counted transition proof (MCM dev-page, NEW save) | pending (after flip) | MCM Debug | P0 | tier x1, neglect x1, curse onset/cure x1 each; save/load guard; deps-absent graceful |
| FP-045 | V1 exclusions: bodymark + OAR stay OFF | decision recorded | runbook Boundaries | -- | n/a (V2) |
| FP-046 | MCM verbosity toggle (GAP-2: spec D0 deliverable, never built) | pending (optional this pass) | `PDV_MCM.psc`; writer for `PDV.Diegetic.Verbosity` (default 0=Silent) | P1 | toggle writes key; Silent default; NOT required to prove visuals |
| FP-047 | Medallion + journal channels won't surface (DF/DBF absent in Anvil; DF present in ARR, DBF absent) | decided (V1 soft-dep fallback) | medallion-hover works in ARR (DF there); journal falls back | P1 | accepted |
| FP-049 | Prisma "Book of Days" -- first-party journal (DBF-free, works in all lists incl. Authoria) | BUILT + display-blocker fixed (live) -- re-test pending | Papyrus: director ring buffer (cap 24) + manager `BuildJournalPayloadJson`/`SendPrismaJournalPayload(playerRequested)` + MCM rebindable hotkey (Player page). DISPLAY FIX: hotkey was blocked by `AllowPrismaBlockingSurfaces` (gameplay-gate, default off) -> added a player-owned bypass; README confirms `SendOverlayJson` shows the view. ACCESSIBLE TONE: `JournalToneToValence` -> good/warning/neutral; UI renders direction arrow + tag word + color spine + neutral high-contrast text (color never the only cue). Temp on-screen "The Book of Days opens." confirmation. compile 0/0, verify FAIL=0, audit 13 PASS; live JS synced to repo source. | P1 | machine DONE; re-test: press hotkey -> notice + modal should now show |

---

## WS-3 -- Branding / visual assets

| ID | Item | State | Where | Pri | Proof gate |
|----|------|-------|-------|-----|------------|
| FP-050 | Track `Devotion Main Banner.png`; decide home (repo root vs `assets/` vs Nexus-only) | placed, pending commit | `assets/branding/Devotion Main Banner.png` | P1 | include in closeout commit or deliberately remove before release |
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
