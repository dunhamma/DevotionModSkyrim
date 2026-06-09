# LD-P1 Local Build Handoff

Everything needed to resume this work on your modding rig (Creation Kit + Skyrim).
All design decisions are **ratified and locked**; this is the build launch sheet.

> **2026-06-10 revision:** the autonomous M3/M4 drafts were audited in-the-loop
> against live source and corrected. Key changes baked into this sheet:
> (1) **Hircine needs a new curse-gated `PDV_Deity_Hircine` actor** (it exists only
> as a path actor; owner ruled keep-Hircine-build-the-deity); (2) demand fulfillment
> binds to the two **real** signal layers (`Int eventType` faucet / quest-matrix
> tag) — there is no string act-tag seam; (3) `PIETY_DAILY_MAX_DELTA` is **4.3**,
> not 5.0. Read the revised `03_feasibility.md` + `04_living_deities_architecture.md`.

## 1. Pull the branch
```bash
cd path\to\your\DevotionModSkyrim
git fetch origin claude/zen-allen-xrjqf8
git checkout claude/zen-allen-xrjqf8
git pull origin claude/zen-allen-xrjqf8
```
(Fresh rig: `git clone https://github.com/dunhamma/DevotionModSkyrim.git` first.)

## 2. Launch Claude Code (Node 18+)
```bash
npm install -g @anthropic-ai/claude-code
claude
```
Run from inside the repo. (Or use the VS Code / JetBrains "Claude Code" extension.)

## 3. Kickoff prompt (paste as the first message)
> Read `references/research/living-deities/README.md`, `DECISIONS_PENDING.md`, `02_mood_model.md`, and `04_living_deities_architecture.md`. All LD-P1 decisions are ratified (mood model, MVP scope, Kyne + Hircine pilot). Build the LD-P1 slice in the order in `HANDOFF.md`: authoring CSVs + compiler + self-test, then Papyrus wiring, then CK records, then compile + in-game proof.

## Locked design parameters (so you don't have to flip docs)
- **Mood** = per-deity EWMA over the daily `clampedToday`: `MoodNew = Clamp(alpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-alpha)*MoodOld, -100,100)`. `PIETY_DAILY_MAX_DELTA` = **4.3** live — always reference the property, never a literal.
- **alpha:** Kyne 0.12, Hircine 0.22 (default base 0.15).
- **Hircine = curse-gated deity face (owner, 2026-06-10):** new `PDV_Deity_Hircine extends PDV_DeityBase` (Kyne-shell clone), in `PDV_FLST_AllDeities`, scores/moods **only while `PDV_CurseState.IsWerewolf()`**; the existing `PDV_DaedricPath_Hircine` stays unchanged as the onboarding/stigma/cure layer.
- **Demand fulfillment = signal binding, not act-tags:** each demand binds to faucet `event_types` (+ optional `event_filter`) and/or a `quest_matrix_tag`; detection happens at the existing router/`ScoreAction` and `ApplyQuestReaction` points. Kyne must **not** bind to event 1 (she penalizes beast kills).
- **Bands (asymmetric):** Wroth [−100,−40) · Cool [−40,+10) · Pleased [+10,+55) · Exalted [+55,100].
- **Stance caps ceiling:** FOREIGN → max Pleased; TABOO/HOSTILE → max Cool (unless curse/commitment active).
- **Fire on band-CROSS only**, filtered by active patron pool + anti-spam (`ScoreRepeatableAction` cooldown + `Marked` tier + MCM density).

## Build checklist (order matters; first block is verifiable without the CK)

### A. Authoring data + tooling (no CK needed — verify here) — ✅ DONE 2026-06-10
- [x] `references/authoring/PDV_DeityMood.csv` — rows for Kyne, Hircine (alpha, band thresholds, stance ceiling).
- [x] `references/authoring/PDV_DemandTable.csv` — **revised schema with signal-binding columns** (`binding_layer`, `event_types`, `event_filter`, `quest_matrix_tag`, `wired_today`). Kyne: *honor the wild* (quest-matrix `the_hunt` + positive faucet events, 4d); Hircine: *the Hunt* (event 1 + `great_beast` filter, 3d).
- [x] `references/authoring/PDV_OmenProfile.csv` — Kyne up/down toast + hawk dream; Hircine down + Wroth escalation + restless-wolves dream.
- [x] `tools/pdv_living_deities_compile.mjs` — clone of `pdv_quest_matrix_compile.mjs`; emits `PDV_LivingDeities.json` to `SKSE/Plugins/StorageUtilData/PlayerDevotion/`.
- [x] `tools/pdv_living_deities_selftest.mjs` — vocab + parallel-array + no-empty-deity + binding-integrity gates; run as the pre-wiring gate.

### B. Papyrus wiring — ✅ AUTHORED + COMPILE-PROVEN 2026-06-10 (isolated, NOT deployed)
> The full Block B slice lives in `research/living-deities/src/` on this branch
> (see `research/living-deities/README.md`): all items below are implemented and
> compile 0/0 against the live import chain, but the live MO2 tree is untouched.
> Deployment is an explicit promote step after ratification. The Kyne
> quest-matrix rows remain open (separate branch).
- [ ] **PREREQ — close the Kyne fulfillment gap (HALF-closed 2026-06-10):** the
  faucet half is landed — main's `2e665b7` (hybrid faucet wiring, merged into this
  branch) shipped receivers for 313 (`PDV_PlayerEvents` sleep hook) and 343
  (`PDV__SM_NewVoicePower` SM node), compiled/readback-clean; **runtime proof is
  still pending** (see `references/authoring/PDV_FaucetDetection_CKChecklist.md`
  §6). The quest-matrix half is still open: Kyne has zero rows in
  `PDV_QuestReactionMatrix_Full.csv` (the only `the_hunt` rows are Hircine's DA05
  s100/s105). Remaining before/with Block B: author Kyne-positive
  `the_hunt`/`honor_the_wild` matrix rows, and carry the 313/343 runtime proof in
  the Block D smoke. (Hircine is fine: event 1 is live; only the `great_beast`
  filter is new.)
- [ ] **NEW — `PDV_Deity_Hircine.psc`** (`extends PDV_DeityBase`, Kyne-shell clone): curse gate (`PDV_CurseState.IsWerewolf()`) in `ScoreAction`, then **must** `return ScoreFromTable(eventType)` (never a `0.0` stub — the masking lesson); mood decay/zero on cure via `HandleCurseTransition`.
- [ ] `PDV_DeityBase.psc`: add `MoodAlpha`, `Boon_<tier>_<band>` spell props, `ClutchSaveEffect` prop; add `SyncPatronBoonsToBand()` (extend `SyncPatronBoonsToTier`).
- [ ] `PDV__ManagerQuest.psc`: `RunDawnUpdateMood()` folded into the `RunDawnConsolidateScratch` loop (read `clampedToday` before `PietyToday` is zeroed); `RunDawnProcessDemands()` mirroring `RunDawnProcessCommitmentOffers()`; `OnMoodBandCross()` dispatch; mirror band → `PDV_GLO_PatronMoodBand`; **demand fulfillment at the two real signal points** (router/`ScoreAction` eventType match + `ApplyQuestReaction` matrix-tag match — NOT a new param on `AwardPietyInternal`); demand expiry in dawn.
- [ ] Extend `SendPrismaEventToast` with `"mood_up"/"mood_down"/"demand"`; dream omen on `OnSleepStart` (`PDV_PlayerEvents.psc`).
- [ ] Extend `PDV_T3DailyLowHealthSaveEffect.psc`: add `mood >= Pleased` gate + deity theming + `Marked` toast (daily-cap already present).

### C. Creation Kit records
- [ ] **NEW — `PDV_Deity_Hircine` QUST** (SGE flag + SEQ entry — the BaanDar lesson) + `PDV_FLST_AllDeities` membership + stance-matrix rows + `PDV.LD.*` hunt-act rows (promote the matrix §7 Hircine block from "V2 reference only").
- [ ] `PDV_GLO_PatronMoodBand` global.
- [ ] Band-variant boon SPEL/MGEF for Kyne + Hircine (Pleased/Exalted variants of existing tier boons).
- [ ] Clutch-save effects: "Kyne's Breath" (heal + gust), "Hircine's Vigor" (heal + bestial surge).
- [ ] Wire all new properties on the deity quests + manager (VMAD values bake at first init — existing saves need version-gated runtime migration).

### D. Compile + prove
- [ ] `tools/pdv_compile.mjs` (Papyrus) → run self-test → `tools/pdv_verify.mjs` + `pdv_content_verify.mjs`.
- [ ] In-game / QASmoke counted proof (the "proof still required" items in the revised `03_feasibility.md`): mood persists across save/load; band-cross fires once; demand offer/fulfill/expire each once; boon band-swap no stacking; clutch-save once/day and mood-gated; omen toast once per cross + clean degrade without Prisma; **Hircine deity face scores 0 while not werewolf, activates on curse, no double-fire vs the path actor's curse transitions**.

## Map of the research docs
`README.md` (charter+status) · `00_substrate_seam_map.md` (seams) · `01_teardown_dossier.md` + `01_mechanism_bank.md` (borrows) · `02_mood_model.md` + `02_mechanism_shortlist.md` (decisions) · `03_feasibility.md` (per-mechanism feasibility + proofs needed) · `04_living_deities_architecture.md` (the spec) · `04_future_buckets_backlog.md` · `prisma-ui-reference.md` · `DECISIONS_PENDING.md` (all ratified).

Branch tip at handoff: commit on `claude/zen-allen-xrjqf8`. Nothing implemented yet — design only.
