# PDV Voice-Conformance Pass -- Handoff to the ESP-Build / Small-Signal Session

**Date:** 2026-06-14. **From:** the voice-conformance Claude session. **To:** the parallel Claude
session doing small-signal CSV + locking ESP build specs + "codegen + ESP build".

## TL;DR
The voice pass rewrote **all 10 races' Survey readouts** in the LIVE manager `.psc` (deployed,
compiling 0/0). It did **NOT** author any ESP records -- that is your lane. Before you lock the
build specs: fold the voice copy into the manifest and build the new records. **Read the conflict
warning first -- it affects how you regen the manager.**

**2026-06-14 build-pass closeout:** the consolidated Codex pass consumed this handoff. The live manager
was backed up, the held likes/dislikes and Prince codegen ran on top of the current deployed manager,
the Nord scar/Khajiit posture/Rajhin/Alkosh/recent-events follow-ups landed, and
`PDV_ConsolidatedBuildPass_RecordWave.spec.json` authored the first record wave plus
`PDV_RepTrack_ThalmorAlignment`. Proof: `node tools/pdv_compile.mjs --script PDV__ManagerQuest`,
`node tools/pdv_content_verify.mjs`, `node tools/pdv_writer_review.mjs`, `node tools/pdv_verify.mjs`,
SEQ refresh, and targeted houseCARL readback. Runtime/manual proof remains separate.

## (1) CONFLICT WARNING -- read before you touch the manager
- Both sessions edit `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`.
  It is **DEPLOYED, NOT git-tracked -> last-write-wins, no merge.**
- The voice pass just rewrote all 10 `Get<Race>SurveyText` functions and added 3 helper functions in
  that file (live now, compiled 0/0).
- Your small-signal codegen re-runs `pdv_likesdislikes_gen` into `LoadRowsForDeity` in the **same file**
  (the "HELD until the consolidated manager pass re-runs the generators" note).
- **You MUST run your codegen on top of the CURRENT deployed manager, not an older snapshot, or you
  will clobber the Survey rewrites -- and they are NOT recoverable from git.**
- **Safety check:** before you regen, confirm the manager currently contains `GetPublicTierBand` and
  `GetCurrentStandingBand`. If it does, you have the current copy; if not, STOP and re-pull.

## (2) What the voice pass changed (DONE -- do not redo)
In `PDV__ManagerQuest.psc`:
- All 10 `Get<Race>SurveyText` rewritten to narrator voice, componentized shape (per-axis base +
  only-active component lines), with the public-band Standing token.
- New helpers: `GetPublicTierBand(Int tier)` (Distant/Observant/Faithful/Devoted per Architecture v3
  Section 2.1), parameterless `GetCurrentStandingBand()`, and `GetBosmerComplianceBand()`.
- Shared player-tier surfaces routed to public bands: the tier-up notification + Prisma tier/champion
  toasts. (Daedric milestone path + dev `Debug.Trace`s deliberately KEEP the internal Seeker/Champion
  words via `GetTierStandingLabel` -- do not change those.)
- **Proof:** compile `0 error(s)`, `pdv_verify` `FAIL=0 / PASS=2938`, negative-grep CLEAN (no
  "Current standing:", enum leaks, "watches the code", or "framework" in any player surface).

## (3) Locked decisions (do not re-litigate)
- Standing vocabulary: PLAYER surfaces use the Section 2.1 PUBLIC BANDS; `GetCurrentStandingLabel` /
  `GetTierStandingLabel` (Seeker/Champion) stay for dev/MCM/code + Daedric.
- Survey = richer componentized shape (base + only-active components), content-driven length.
- Nord commitment offers use the **SHARED** Accept/Decline trio (manifest 10.6), NOT per-offer verbs.
- Bosmer dead favor clause (`PDV.Bosmer.Favor.LastFamily`, never written) was DELETED from the survey.
- Altmer Survey base = interim Auri-El anchor; the alignment-path base (Orthodox/Divine-Body/Psijic,
  manifest 13.9) wires in WHEN you build ThalmorAlignment.

## (4) YOUR WORK -- the ESP record wave (manifest-driven)
Record-bound copy is durably captured in **`references/authoring/PDV_VoiceConformance_RecordCopy.md`**
(generated this session). Fold into `race-sheets/PDV_RaceContent_Manifest.md`, then build:
1. **Nord -- 11 NEW commitment-offer MESG records** (god-voice, 500/280 + 40 title) for the non-Kyne
   eligible gods: Old Ways Shor/Tsun/Stuhn; Nine Divines Akatosh/Mara/Arkay/Stendarr/Zenithar/
   Dibella/Julianos/Kynareth; + Talos. Plus the shared Accept/Decline. Runtime gate already exists
   (`IsNordOfferEligibleDeity`); offers fire state-only today (surfacing is deferred D1) but the
   records/copy should exist now. Full bodies in RecordCopy.md.
2. **Curse-state MESG verify/conform** -- the live `.psc` fallbacks are terse truncations of the
   manifest god-voice bodies; several diverge. Verify each `PDV_Msg_<Race>_CurseState_*` MESG carries
   the manifest body; conformed text in RecordCopy.md.
3. **Champion-entry binding** -- several races (Redguard confirmed) show a generic `.psc` fallback
   instead of the rich `PDV_Msg_<Race>_ChampionEntry_*` god-voice MESG. Bind the records.
4. **Neglect texture MESG records** -- conformed copy in RecordCopy.md; Redguard uses the TIGHT
   <=80-char alternates (HUD budget).
5. **Altmer ThalmorAlignment track** -- build the reputation track (costing manifest exists), then the
   Altmer Survey base can swap from the interim Auri-El anchor to the alignment-path base (small `.psc`
   edit at `GetAltmerSurveyText`).

## (5) Two small `.psc` follow-ups (code -- your call, near your codegen)
- Nord `GetNordScarLabel`: reword to "The vampire scar still shows. The road is open again, but not
  unmarked."
- Khajiit Prisma posture toast TITLE leaks a raw enum (ShadowDrift/Strained/Corrupted via
  `GetKhajiitLunarPostureLabelAt`). Add a display-label path -- "Drifting to shadow" / "Lattice
  strained" / "Lattice thinned" / "Lattice clear" -- keeping the raw-token function for code/MCM.

## (6) Where everything lives
- Plan + progress: `references/authoring/PDV_VoiceConformancePass_Plan.md`
- Record-bound copy (offers + conformed surfaces): `references/authoring/PDV_VoiceConformance_RecordCopy.md`
- Full per-race drafts (survey copy, highlights, open_questions): the drafting-workflow output at
  `C:\Users\Admin\AppData\Local\Temp\claude\...\tasks\w9k27i6rh.output` -- **EPHEMERAL**, extract now
  if you need survey/open-question detail beyond RecordCopy.md.
- Voice spec: `race-sheets/PDV_ContentDestinationMatrix.md` (surface->voice) + `PDV_Architecture_v3.md`
  Section 2.1 (tier bands).

## (7) Open coordination questions (for the human)
- Does your ESP build cover the manifest content records (offers / curse / champion / neglect MESG)
  **and ThalmorAlignment**, or only the small-signal + reward layer? If only the latter, items 1-5
  above need an explicit owner.
- Confirm the manager-`.psc` sequencing: Survey rewrites are in NOW; your codegen runs on top.
