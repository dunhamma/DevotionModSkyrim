# LD-P1 Local Build Handoff

Everything needed to resume this work on your modding rig (Creation Kit + Skyrim).
All design decisions are **ratified and locked**; this is the build launch sheet.

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
- **Mood** = per-deity EWMA over the daily `clampedToday`: `MoodNew = Clamp(alpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-alpha)*MoodOld, -100,100)`.
- **alpha:** Kyne 0.12, Hircine 0.22 (default base 0.15).
- **Bands (asymmetric):** Wroth [−100,−40) · Cool [−40,+10) · Pleased [+10,+55) · Exalted [+55,100].
- **Stance caps ceiling:** FOREIGN → max Pleased; TABOO/HOSTILE → max Cool (unless curse/commitment active).
- **Fire on band-CROSS only**, filtered by active patron pool + anti-spam (`ScoreRepeatableAction` cooldown + `Marked` tier + MCM density).

## Build checklist (order matters; first block is verifiable without the CK)

### A. Authoring data + tooling (no CK needed — verify here)
- [ ] `references/authoring/PDV_DeityMood.csv` — rows for Kyne, Hircine (alpha, band thresholds, stance ceiling).
- [ ] `references/authoring/PDV_DemandTable.csv` — Kyne: *honor the wild* (`the_hunt`/`honor_the_wild`, 4d); Hircine: *the Hunt* (slay a great beast, 3d).
- [ ] `references/authoring/PDV_OmenProfile.csv` — Kyne up/down toast + hawk dream; Hircine down + Wroth escalation + restless-wolves dream.
- [ ] `tools/pdv_living_deities_compile.mjs` — clone of `pdv_quest_matrix_compile.mjs`; emit runtime JSON to `SKSE/Plugins/StorageUtilData/PlayerDevotion/`.
- [ ] self-test — clone of `pdv_quest_matrix_selftest.mjs` (vocab + parallel-array + no-empty-deity); run as the pre-wiring gate.

### B. Papyrus wiring
- [ ] `PDV_DeityBase.psc`: add `MoodAlpha`, `Boon_<tier>_<band>` spell props, `ClutchSaveEffect` prop; add `SyncPatronBoonsToBand()` (extend `SyncPatronBoonsToTier`).
- [ ] `PDV__ManagerQuest.psc`: `RunDawnUpdateMood()` folded into the `RunDawnConsolidateScratch` loop (read `clampedToday` before `PietyToday` is zeroed); `RunDawnProcessDemands()` mirroring `RunDawnProcessCommitmentOffers()`; `OnMoodBandCross()` dispatch; mirror band → `PDV_GLO_PatronMoodBand`; demand-fulfillment hook in `AwardPietyInternal`; demand expiry in dawn.
- [ ] Extend `SendPrismaEventToast` with `"mood_up"/"mood_down"/"demand"`; dream omen on `OnSleepStart` (`PDV_PlayerEvents.psc`).
- [ ] Extend `PDV_T3DailyLowHealthSaveEffect.psc`: add `mood >= Pleased` gate + deity theming + `Marked` toast (daily-cap already present).

### C. Creation Kit records
- [ ] `PDV_GLO_PatronMoodBand` global.
- [ ] Band-variant boon SPEL/MGEF for Kyne + Hircine (Pleased/Exalted variants of existing tier boons).
- [ ] Clutch-save effects: "Kyne's Breath" (heal + gust), "Hircine's Vigor" (heal + bestial surge).
- [ ] Wire all new properties on the deity quests + manager.

### D. Compile + prove
- [ ] `tools/pdv_compile.mjs` (Papyrus) → run self-test → `tools/pdv_verify.mjs` + `pdv_content_verify.mjs`.
- [ ] In-game / QASmoke counted proof (the "proof still required" items in `03_feasibility.md`): mood persists across save/load; band-cross fires once; demand offer/fulfill/expire each once; boon band-swap no stacking; clutch-save once/day and mood-gated; omen toast once per cross + clean degrade without Prisma.

## Map of the research docs
`README.md` (charter+status) · `00_substrate_seam_map.md` (seams) · `01_teardown_dossier.md` + `01_mechanism_bank.md` (borrows) · `02_mood_model.md` + `02_mechanism_shortlist.md` (decisions) · `03_feasibility.md` (per-mechanism feasibility + proofs needed) · `04_living_deities_architecture.md` (the spec) · `04_future_buckets_backlog.md` · `prisma-ui-reference.md` · `DECISIONS_PENDING.md` (all ratified).

Branch tip at handoff: commit on `claude/zen-allen-xrjqf8`. Nothing implemented yet — design only.
