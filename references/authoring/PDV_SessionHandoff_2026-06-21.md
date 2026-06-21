# PDV Session Handoff — 2026-06-21

Pick-up doc for the next session. Authoritative status lives in
`PDV_BetaFeelBurndown.md` + `AGENTS.md`; this captures *this session's* work,
decisions, coordination state, and what's next.

## Where the project is

The framework is **build-complete and machine-verified**; the gating work is now
**in-game proof + reward-magnitude tuning**, not building. Two delivery tracks are
live in parallel:
1. **Beta test campaign** (Sessions A–G) — barely started; the user pivoted to (2).
2. **Authoria (ARR/Requiem) first look** — package built and ready to hand to a
   friend for the first runtime look.

## Work model / lanes (decided this session)

- **Codex** owns all live `.psc` edits (manager/MCM/ActionRouter/ModePreset),
  driven by `PDV_*_CodexHandoff.md` specs. **Claude (me)** owns `Devotion.esp`
  records (houseCARL/CK bridge), docs, verification, and writing the Codex specs.
  **User** owns in-game proof + CK record minting.
- **Live source is git-tracked now:** canonical mirror at `live-source/Scripts/Source/`
  (eol=lf). On every Codex "X is done", **I pull live→mirror + commit + gate**.
  Don't run the user's Book-of-Days source session and a Codex manager-edit at the
  same time (one untracked 15k-line file).
- houseCARL instance discipline: re-point to **Anvil (Devotion Dev)** after any ARR read.

## Locked decisions

- Scope = **Full Devotion Beta-Feel** (all 16 Princes proven). **Build Wayfarer**
  (Experience Mode) this beta. CK-blocked items via houseCARL + the CK automation
  bridge first, CK checklist for the remainder.
- **Penalties → re-author as felt** (negative Fortify-Health; magnitudes provisional).
- **1F (Experience Mode) is gated on "tuning frozen"** — it edits `RunGainPipeline`/
  `RunDawnConsolidateScratch`; do NOT start it until the in-game tune-back lands.
  Tuning is NOT frozen yet.

## Done this session (committed)

- **Phase 0:** git-tracked live source; reconciled the Requiem docs vs the live ESP
  (`PDV_RequiemSmokeTest_Tracker.md` 2026-06-21 section); baseline gate green
  (`pdv_verify` FAIL=0, Daedric PASS=16); all Codex specs written.
- **Reconciliation headline:** the Requiem **positive-reward conversion is COMPLETE
  across all 10 races incl. Nord** (Shor rewired to `_Health` + `_AvoidDeath`
  capstone; HoonDing Champion AvoidDeath save + 19-entry boss FormList done). The 27
  remaining `_HealRateMult` MGEFs are **orphaned leftovers**. Earlier "Nord deferred"
  was a stale Papyrus/spec read — trust the ESP spell→MGEF wiring.
- **Codex landed:** 1A MCM self-heal (`5b035e5`), 1H custom-race origin robustness
  (`69d0d4d` sync), 1C anti-farm pulse caps (`940d96a` + verifier sync `b7a6fb2`),
  cleanup 1C-fix (`d2d8f69`).
- **Panel ESC-close fix** (cold-view focus trap): `native/DevotionPrismaBridge/src/main.cpp`
  committed `5301ec0`; **DLL rebuilt via portable xmake + deployed** (Anvil + Authoria
  via junction); fix string verified in the binary.
- **Authoria first-look package** built: `C:\Users\Admin\Documents\PDV_Authoria_FirstLook.zip`
  (Devotion + compat patch + README + TESTING_STATUS). Patch checked on the ARR list:
  shrine overrides win cure-only, rewards resolve, compat ESP's 11 Daedric prayer ACTIs
  intact, Archon absent, Requiem resolving.
- Everything pushed to `origin/main` (local == origin).

## Adversarial verification notes

- **1C anti-farm:** full coverage (all ~35 handlers capped, no double-consume, EXCLUDE
  list clean). 5 **latent** low-severity placement issues (bail before non-pulse side
  effects; unreachable because `ConsumeDailyRepeatMultiplier` returns 0.7ⁿ, never ≤0) →
  the `1C-fix` packet (`PDV_Cleanup_CodexHandoff.md`). The Nord one (`RouteNordFamily`
  capped at entry not sink) is the one worth confirming Codex fixed.

## In flight / next

- **Codex queue remaining:** the cleanup packet (1C-fix appears done via `d2d8f69`;
  **confirm the Orc Code-Holds `.Cast` removal landed**), then **1F Experience Mode
  (LAST — only after tuning frozen)**.
- **My ESP lane:** `1B` penalty re-author (4 active `HealRateMult` penalties →
  negative Fortify-Health) — scoped + executable in the tracker; **folds into the
  Session-C ESP tuning pass** to avoid double writes. Orphaned `_HealRateMult` prune →
  Phase-5 xEdit.
- **In-game (user):** the test campaign (`PDV_BetaTestCampaign_TesterSheet.md`,
  Sessions A–G) — Session A only partially run (A1/A3/A4 pass; A2 was the Prisma panel,
  not the MCM; A5 Ohmes needs Authoria; A6 save gone). B/C/D + the Session-C tuned
  magnitudes are what **unblock the 1F freeze**.
- **Authoria first look (user + friend):** package ready. Finalize steps: master/header-
  order SSEEdit check (**deferred per user**), Reqtificator pass, runtime first-look per
  `PDV_Phase21_ARR_SmokeRunbook.md`. Friend feedback will land in TESTING_STATUS terms.

## Critical path

In-game proof (Authoria first look and/or Sessions B/C/D) → reward-magnitude tune-back
(I write tuned values + the 1B penalty conversion) → **confirm "tuning frozen"** →
hand Codex 1F → final MCM/Experience-Mode + Phase-5 close-out (gate re-run, master-order
validation, tester handoff packet, orphan prune).

## Gotchas / environment

- **xmake** is portable at `C:\Users\Admin\Documents\xmake-v3.0.8-win64\xmake\xmake.exe`
  (NOT on PATH). Rebuild the bridge DLL: set `PDV_MOD_PATH=D:\Wabbajack\modlists\Anvil\mods\Devotion`,
  `xmake build -y -P native\DevotionPrismaBridge` (auto-deploys; Skyrim must be closed).
- **Authoria = `D:\Wabbajack\modlists\ARR`**, profile **"PDV Test"**; Devotion is a
  **junction** to the Anvil folder (updates auto-reflected on ARR).
- **Prisma rule** (new memory): never `Focus()` a Prisma view before `OnDomReady` —
  cold-view focus = unrecoverable input trap.
- **Experience Mode is design-locked but NOT built** (new memory) — current build is
  Pilgrim-only; it scales the economy, not reward magnitudes.
- Reward magnitudes are **PROVISIONAL** until proven on the HP bar under Requiem.

## Open tasks (tracker)

#5 1B penalty ESP conversions (ready, folds into Session-C) · #6 Phase 4 Experience
Mode (after freeze) · #7 Phase 5 close-out · #9 cleanup batch (1C-fix done; confirm Orc
display) · #10 in-game test campaign · #11 panel fix (rebuilt+deployed; in-game ESC
confirm pending) · #12 Authoria first-look (package done; finalize/runtime pending).
