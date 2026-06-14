# PDV Survey + D0 Voice-Conformance Pass -- Plan

**Status:** Agreed (grill-me sign-off 2026-06-14). Implementation kicked off (Step 1 inventory running).
**Owner:** Single Claude-driven pass (all four steps). Per the `PDV_DiegeticUX` convention Claude owns
copy/voice contracts; here Claude also runs the live `.psc` port per user decision 2026-06-14, with
`AGENTS.md` synced after.

## Goal
Bring every D0 player-facing string into its matrix-assigned voice, sourced from the manifest, so
nothing reads as dev-voice or leaks enum tokens. Trigger: the live Survey rendering
`Your Bosmer path is OldContract. Current standing: Unproven.` and Orc
`Malacath watches the code through City life.`

## Decisions (locked in the grill)
- **Voice per surface** = the `PDV_ContentDestinationMatrix` assignments: Survey / blessing / posture =
  **Narrator**; curse-state / commitment-offer / champion-entry / favor-Marked = **God-voice**;
  tier-up / neglect / favor-Noted / champion-ambient = **Player-2nd**; Prisma toast = symbol-led. The
  tier word is **kept, embedded** as `Standing: %s` (never a bare `Current standing:` readout).
- **Source of truth** = `race-sheets/PDV_RaceContent_Manifest.md`, **expanded** to the richer
  componentized shape (the structure the live Khajiit `GetKhajiitSurveyText` already demonstrates: a
  base variant + a narrator line per *active* sub-state), for **all 10 races**. The tight 4-variant
  blocks cannot carry the many in-game sub-states that are currently poorly voiced, so the manifest
  grows to the richer shape and the live functions are conformed to it.
- **Length** = content-driven, readability-bound (composite <= ~6 lines, each line one clean
  sentence). The Survey renders via `Debug.MessageBox` (`PDV_SurveyDevotionEffect` + the MCM
  `ShowMessage` button), so the `240 / SPEL-DESC` budget is **not** an engine limit; the manifest
  Survey budget is re-annotated to a MessageBox-composite model (per-line ~140, composite ~6 lines).
- **Ownership** = single Claude-driven pass.

## Scope
**IN:** all 10 races' Survey readouts + label-builder humanization; conformance audit of toasts,
posture labels, curse-state messages, neglect / favor notifications; **new non-Kyne commitment-offer
copy** (11 Nord gods -- Old Ways: Shor, Tsun, Stuhn; Nine Divines: Akatosh, Mara, Arkay, Stendarr,
Zenithar, Dibella, Julianos, Kynareth; + Talos), god-voice, drafted into the manifest, plus
degenericizing the Kyne-worded MCM commitment labels.

**OUT (deferred):** the D1 diegetic **surfacing** (medallion / journal / screen / sound / music
channels per `PDV_DiegeticUX_ArchitectureSpec.md`), notification dwell-time, and the actual
commitment-offer **pop**. We write the offer **copy** now; it surfaces when D1 lands. See memory
`diegetic-surfacing-d0-gated`, `survey-toast-narrator-voice-sweep`.

## Content call
The Survey is the only **persistent** status panel (curse / neglect notifications are transient), so
the richer Survey composite **keeps a brief narrator status line for active curse and active
neglect** -- they are real sub-states the componentized shape should carry, even though their
*transitions* fire on separate surfaces.

## Execution (4 steps)
1. **Inventory (workflow fan-out)** -- per-race conformance map: every live D0 string x current text x
   matrix voice x manifest row -> action (port_from_manifest / expand_manifest_new_copy /
   humanize_label_builder / conform_other_surface / already_ok).
2. **Manifest expansion (copy)** -- expand the Survey variants + components, draft the new offer copy,
   conform divergences. `node tools/pdv_content_verify.mjs` (voice / budget / ASCII) + regen
   `node tools/pdv_writer_review.mjs`.
3. **Port to live `.psc`** -- update each `Get<Race>Survey*` (+ other diverged strings) to emit the
   manifest copy, wire the `%s` / component slots, humanize the Survey label builders. Live `.psc`
   lives on `D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source` (NOT repo-tracked).
4. **Verify + prove** -- `node tools/pdv_compile.mjs --script PDV__ManagerQuest` (0/0), `pdv_verify`
   FAIL=0, manifest<->live parity, negative grep (no `OldContract` / "the code" / "Current standing:"
   / raw enum tokens in any player string), in-game new-save Survey spot-check per race.

## Acceptance
content_verify PASS (voice / budget / ASCII) - compile 0/0 - pdv_verify FAIL=0 - parity clean -
negative grep clean - in-game reads cleanly per race, correct voice, info accurate.

## Note
This is larger than the original "Survey rewrite" (10 races x multiple surfaces + manifest expansion
+ net-new offer copy); it feeds the beta-feel burndown.

## Progress (live, 2026-06-14)
- **Slice 0 foundation** -- `GetPublicTierBand(tier)` + parameterless `GetCurrentStandingBand()` added to
  `PDV__ManagerQuest.psc`; shared player-tier surfaces (tier-up notice + Prisma tier/champion toasts) routed.
  Compiles 0/0. Daedric milestone + dev traces correctly keep the internal Seeker/Champion words.
- **Drafting** -- all 10 races drafted (in the drafting-workflow output; re-extractable). Decisions LOCKED:
  Survey tier-0 = `Distant` (the lapse notifications keep `Wavering`); Nord offers use the shared
  Accept/Decline trio (manifest 10.6); Bosmer dead favor clause deleted; componentized restructure
  (off-state lines drop from Survey); Redguard neglect uses the tight <=80-char alternates; the Altmer
  slice folds in ThalmorAlignment wiring (its Survey base depends on that unbuilt track).
- **Survey .psc ports COMPLETE -- ALL 10 races, compile 0/0, verify FAIL=0 / PASS=2938, negative-grep
  CLEAN** (no "Current standing:" / enum leaks / "watches the code" / "framework" in player surfaces):
  Redguard, Bosmer, Nord, Khajiit, Altmer, Dunmer, Orc, Breton, Argonian, Imperial. New helpers:
  `GetPublicTierBand`, `GetCurrentStandingBand`, `GetBosmerComplianceBand`. Each survey is now the
  componentized shape (per-axis base + only-active component lines, public-band Standing token).
  Altmer base = interim Auri-El anchor (the alignment-path base wires when ThalmorAlignment is built).
- **REMAINING (ESP wiring wave, distinct second pass):** Nord's 11 new god-voice offer MESG records;
  curse-state MESG verify/conform (houseCARL); champion-entry binding; neglect texture MESG records
  (Redguard tight <=80 alternates); the Altmer ThalmorAlignment track + alignment-path base swap; the
  Nord cured-vampire-scar `GetNordScarLabel` reword; Khajiit Prisma posture-title display label.
  Drafts are all in the drafting-workflow output; resumable.
