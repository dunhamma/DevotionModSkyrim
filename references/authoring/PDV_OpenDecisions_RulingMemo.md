# PDV Open-Decisions Ruling Memo

**Status:** DRAFT (no-deploy prep)
**Created:** 2026-06-19
**Provenance:** Drafted from `references/authoring/PDV_BetaFeelBurndown.md`,
`references/authoring/PDV_NextBuildPass_RecordSpec.md`,
`references/authoring/PDV_RaceEffectReviewLedger.md`,
`references/authoring/PDV_Phase20_BetaReadinessRemainder.md`,
`references/authoring/PDV_DeityLikesDislikes_EnrichmentSummary_2026-06-14.md`,
`references/authoring/PDV_RaceImplementationCostingBacklog.md`,
`references/authoring/PDV_CAT6PromotionPilot.md`,
`references/authoring/PDV_FinalPolishLook_Ledger.md`,
`references/authoring/PDV_BetaFeelReleaseGate.md`,
`references/authoring/PDV_BetaReadinessClosureAudit.md`,
`PDV_TargetEndStates_1.0.md`, `PDV_V2_Backlog.md`, `PDV_Architecture_v3.md`,
and `AGENTS.md`.

## Purpose

This memo collects the twelve open decisions that currently sit in the
beta/1.0 path and gives each a crisp statement, a recommendation with a
one-line rationale, the tradeoff/risk, a beta-vs-1.0 blocker call, and a tag
of either NEEDS USER RULING (a genuine product/design call) or CAN RESOLVE
FROM DOCS (the authoritative docs already imply the answer).

This is a DRAFT prep artifact. Nothing here deploys, writes the ESP, edits the
manager, or changes the live build. Where a decision is the user's product or
design call, this memo presents a recommendation for ratification only and does
not pretend to rule it.

Proof-boundary note (carried from the burndown): the external beta-feel claim
still requires all ten races plus all sixteen Skyrim-present Daedric Princes in
the readiness evidence. None of the rulings below change that boundary; several
are explicitly off the beta path.

---

## Decision 1 -- Pending likes/dislikes event rows (events 303/334/335/351, 11 rows)

**Decision:** Whether to build routers/receivers for the 11 enrichment rows
that use PENDING-detection events before beta, or leave them inert.

**Context read:** `PDV_BetaFeelBurndown.md` lines 60, 102, 128;
`PDV_DeityLikesDislikes_EnrichmentSummary_2026-06-14.md` lines 60-71, 89. The 11
rows are: 334 harvest-ingredient (Kynareth+, The Hist+, Hermaeus Mora-path+);
335 mine-ore-or-chop-wood (Zenithar+); 351 clear-bounty-serve-time (Mara+,
Stendarr+, Zenithar+, Boethiah-path-, Hermaeus Mora-path-); 303
kill-animal-noncombat (Hircine-path+, Meridia-path-). The summary states these
"score nothing until then, exactly like the matrix's build-CLEAN-first
guidance," and the codegen (`pdv_likesdislikes_gen` / `pdv_princeld_gen`) is
deliberately not run and the VERSION not bumped, so the rows are inert by design.

**Recommendation:** DEFER the routers; keep the 11 rows inert for beta. The
burndown's own recommended sequence (step 2) says to keep pending event rows
classified as inert unless their routers are implemented, and the enrichment
summary lists router extension as an explicit "next step... NOT this session."

**Tradeoff/risk:** Deferring leaves a small amount of authored two-sided
texture dark (4 distinct events, theologically apt). Building before beta adds
router/receiver work plus a forced codegen + VERSION-bump + new-save reload
proof onto the critical path, with stale-key cleanup risk (the
`ClearRowsForDeity` superset trap) for no beta-feel blocker.

**Blocks beta?** No. **Blocks 1.0?** No (additive texture, slip-safe).

**Tag:** CAN RESOLVE FROM DOCS (recommend DEFER -- the burndown sequence and the
enrichment summary both prescribe inert-until-router).

---

## Decision 2 -- ~6 no-clean-hook track actions

**Decision:** Pick a hook approach for the ~6 track actions that have no clean
vanilla emitter, or keep them deferred: Altmer arrest-Talos-worshipper,
Altmer/Imperial help-prisoner-escape, complete-Thalmor-mission,
Orc-oath-break, Redguard-Dawnguard-cure-as-Ash'abah.

**Context read:** `PDV_NextBuildPass_RecordSpec.md` sec.10 (the consolidated
"STILL DEFERRED" list), plus sec.1 (Altmer arrest / complete-mission /
help-escape have no clean flag), sec.4 and sec.4's readback note (DLC1VQ02
"Bloodline" is a choice quest, not a cure -- no stage to map to Ash'abah
burden), sec.7 (Orc oath-break has no clean quest-fail marker, feasibility rule
sec.41 defers the concrete hook), and sec.8 (Imperial help-escape / refuse /
report / attack / public-observe are manual-dialogue or greenfield);
`PDV_BetaFeelBurndown.md` line 63 documents these as deferred.

**Recommendation:** KEEP DEFERRED for beta and 1.0; do not invent hooks. Each of
these maps to a missing vanilla outcome flag, a radiant loop with no terminal
stage, a manual-dialogue branch, or a greenfield assault whitelist -- exactly
the categories the RecordSpec already adjudicated as "no clean vanilla hook."
The point tables for the actions that DO have clean emitters are already live
and route-proven (Altmer read-banned/-5, consort/-25, kill-Thalmor/-20; Imperial
stormcloaks/-20, justiciar-kill/-10), so the tracks function without the deferred
actions.

**Tradeoff/risk:** Deferring leaves a few thematically strong actions
unscored, so a player who arrests a Talos worshipper or completes a Thalmor
mission sees no track movement. Building any of them risks fragile vanilla-feed
detection, false-positive scoring, or out-of-scope assault-whitelist work for
marginal coverage on tracks that are already moving via the live actions.

**Blocks beta?** No. **Blocks 1.0?** No (the tracks are functional; these are
coverage top-ups, candidate for 1.1).

**Tag:** CAN RESOLVE FROM DOCS (recommend KEEP DEFERRED -- the RecordSpec
sec.10 already classifies each as no-clean-hook).

---

## Decision 3 -- P2 quest-stage source fills blocked pending per-source approval

**Decision:** Whether to lift the per-source approval gate that blocks new
quest-stage P2 source fills (currently only Altmer MQ104 s160 and Bosmer DA05
s100/105 are approved), or keep the gate.

**Context read:** `AGENTS.md` lines 246-248 (only Altmer MQ104 stage 160 is an
approved live quest-stage fill; others blocked until separately approved with
exact stage metadata) and line 973 (Altmer MQ104 s160 and Bosmer DA05 s100/105
approved, Khajiit route metadata blocked until ledger approval);
`PDV_Phase20_BetaReadinessRemainder.md` lines 57-67 (keep the exact-stage gate
green; whole-quest FormList membership alone is insufficient; promote only after
receiver/duplicate ownership and accepted/rejected context are explicit).

**Recommendation:** KEEP THE GATE as-is; do not bulk-lift it for beta. The
remainder doc is explicit that exact quest/stage metadata must be declared
per-source and the `--check-exact-stage-gates` gate must stay green before any
additional quest-stage promotion. The two approved groups are sufficient for
the races whose packets are passing; the gate is a fail-closed safety, not a
blocker to remove.

**Tradeoff/risk:** Keeping the gate means any new immersive quest-stage source
(e.g. a Khajiit edge route) needs an explicit ledger approval pass before fill,
adding a step. Lifting it risks silently filling whole-quest FormLists that
score on the wrong stage -- the exact failure class the gate exists to prevent.

**Blocks beta?** No (the gate does not block beta; unapproved fills are simply
deferred). **Blocks 1.0?** No.

**Tag:** CAN RESOLVE FROM DOCS (recommend KEEP GATE -- the remainder doc
mandates per-source exact-stage approval; this is process, not a product call).

---

## Decision 4 -- Recognition/dialogue + CAT-6 scale gates; Bosmer Exchange_T1 fallback owner

**Decision:** (a) Whether to widen recognition/dialogue and CAT-6 string
promotion before the one-pilot-proof gates clear; and (b) who owns the missing
target record for the CAT-6 fallback `PDV_Bless_Bosmer_Exchange_T1`, which has
no live SPEL.

**Context read:** `PDV_RaceImplementationCostingBacklog.md` lines 336-344
(recognition/dialogue stays packet-draft until `PDV_RecognitionDialogueScalePacket.md`
proves one non-Nord CK line; CAT-6 stays narrow until `PDV_CAT6PromotionPilot.md`
proves one low-risk non-dialogue row end-to-end); `PDV_CAT6PromotionPilot.md`
(Khajiit Lunar T1 is the ratified first pilot and is record/readback-proven;
Candidate C `PDV_Bless_Bosmer_Exchange_T1` "does not currently read back from
Devotion.esp as an EditorID... needs a target-record owner"; the all-race reward
contract uses `PDV_Bless_Bosmer_Yffre_T1` instead). The dialogue portion of
CAT-6 is V2 per Architecture v3 Section 21.3.

**Recommendation:**
(a) HOLD the scale gates -- keep recognition/dialogue draft-only and CAT-6
narrow until each one-pilot-proof clears. The costing backlog makes both
explicitly gated, and recognition dialogue is V2 anyway (see Decision 8).
(b) Exchange_T1 fallback -- RESOLVED 2026-06-20 (user ruling): DROP
`PDV_Bless_Bosmer_Exchange_T1` as a CAT-6 fallback candidate and CORRECT the
stale note. The 2026-05-31 "doesn't read back / needs a target-record owner"
claim in `PDV_CAT6PromotionPilot.md` was STALE: the record now exists in
`PDV_BosmerRewardRecords.spec.json` (The Exchange - Seeker, Z'en, Speech +5) and
was readback-confirmed + in-game tested in the 2026-06-13 Bosmer packet (Z'en
Exchange T1/T2 copy), owned by the all-race reward contract -- not a CAT-6
artifact. The Khajiit Lunar T1 pilot is ratified and proven, so no fallback
candidate is needed. `PDV_CAT6PromotionPilot.md` updated 2026-06-20.

**Tradeoff/risk:** Holding the gates keeps a large body of drafted prose
unshipped, which can feel like stalled content. Dropping the Exchange_T1
fallback means the CAT-6 packet loses a documented second candidate; if the
Khajiit pilot were ever invalidated there is no pre-named fallback SPEL. The
alternative -- authoring an Exchange_T1 owner now -- spends record-authoring
effort on a fallback that the live pilot makes redundant.

**Blocks beta?** No (both are explicitly off the beta-feel path; dialogue is
V2). **Blocks 1.0?** Partial -- the CAT-6 promotion lane should be proven once
before broad 1.0 content promotion, but the single pilot already satisfies that.

**Tag (a):** CAN RESOLVE FROM DOCS (recommend HOLD gates). **Tag (b):** RESOLVED
2026-06-20 (user ruling -- drop the fallback + fix the stale note; record already
live).

---

## Decision 5 -- Committed reward values: per-tier increments vs cumulative-totals stamp

**Decision:** Which reading of the committed per-tier reward values is
authoritative -- per-tier increments, or cumulative totals -- before any further
magnitude tuning.

**Context read:** `AGENTS.md` line 996 (the cumulative-rebalance verification
handed back the open question: "committed reward values read as per-tier
increments while the stamp says 'cumulative totals'") and line 998 (the
follow-on closure slice: "The cumulative-rebalance stamp text now says the
values are current absolute tier values, with no magnitude retune");
`PDV_RaceEffectReviewLedger.md` lines 21-52 (all magnitudes are provisional
until the per-race row is reviewed; reward tuning is blocked until each race
row names its floor/ceiling/range/cadence). The 2026-06-11 highest-tier-only
consolidation (AGENTS.md line 1005) made each top reached tier carry the sum of
all lower tiers, so the live effects are cumulative totals at the granted tier.

**Recommendation:** Treat the committed values as CURRENT ABSOLUTE TIER VALUES
(the cumulative-totals reading), per the AGENTS.md line 998 stamp correction.
The highest-tier-only consolidation means only the top reached tier is granted
and its magnitudes are the cumulative sum, so the absolute-value reading is the
one that matches live behavior; the per-tier-increment phrasing is the stale
framing that the stamp text was corrected to remove.

**Tradeoff/risk:** If a later tuner re-reads the values as per-tier increments
and re-applies a cumulative rebalance, every magnitude doubles (the documented
`rebalance-tool-idempotency` trap). The stamp + idempotency guard already
refuse a second `--write`, so the risk is mainly a human misread during hand
tuning; the mitigation is that all future tuning edits the cumulative values by
hand.

**Blocks beta?** No (values are committed and readback-clean). **Blocks 1.0?**
No, but it gates further magnitude tuning -- tuning should proceed against the
absolute-value reading.

**Tag:** CAN RESOLVE FROM DOCS (recommend ABSOLUTE/CUMULATIVE reading -- the
stamp-correction at AGENTS.md line 998 is the authoritative resolution; confirm
acceptance before tuning).

---

## Decision 6 -- Redguard HoonDing cap escalation endpoint + Ash'abah stigma scope

**Decision:** (a) Where the Redguard HoonDing cap escalation stops (how loud
make-way can get); and (b) the scope and hook for Ash'abah social stigma.

**Context read:** `PDV_RaceEffectReviewLedger.md` line 109 (the Redguard row:
"HoonDing cap = weekly (1/7d, route handler wired)... Open: where does HoonDing
cap escalation stop?"); `PDV_TargetEndStates_1.0.md` line 740 ("HoonDing 1.0
should use curated milestones, dragons, named bosses, and final boss clears
before any combat-odds automation"; "Ash'abah social stigma... should ship only
as light authored/custom 1.0 content unless a concrete broader hook is proven"),
lines 760-762 (Ash'abah friction is social; routine undead-cleansing/burial is
Noted; marked moments belong to real burden-bearing -- major tombs, major
necromancer operations, costly impurity choices, or later custom social-stigma
content). The HoonDing/Leki day-to-day generic-combat leak fix is already
applied (kill rows removed, VERSION 8->9); this decision is about the ceiling,
not the leak.

**Recommendation:**
(a) HoonDing make-way -- RESOLVED 2026-06-20 (user ruling). Two-tier, brought
into line with the locked race-sheet design and split into two distinct beats:
  - STANDARD make-way (piety signal 2501): RETARGET from the current mis-wired
    Forebear road-passage trigger to curated breakthrough -- dragons, named/unique
    bosses, major quest milestones, and final-boss clears. Road-passage returns to
    TAVA (its proper Forebear home; race sheet: "Tava leads ... bird-god of good
    passage"). DROP the blunt weekly cap; anti-farm = per-source one-shot dedup
    (quest/boss FormID) for milestones/bosses + daily soft-decay
    (ConsumeDailyRepeatMultiplier) on the only farmable trigger, dragons. Every
    genuine make-way now registers; an epic multi-deed week is no longer swallowed.
  - CHAMPION make-way: RETIRE the redundant 2nd piety signal (2502) and make the
    focused-HoonDing CHAMPION-TIER REWARD a once/day cheat-death "the way is made"
    survival save, REUSING the proven PDV_T3DailyLowHealthSaveEffect pattern
    (runtime-proven on Khajiit Baan Dar; wired to Nord Shor "Sovngarde Looks
    Back"): OnHit/OnDying at health<=20%, once/day, scripted
    RestoreActorValue("Health",x) -- a flat, Requiem-proof restore. Maximally
    on-theme (the Walker-Who-Makes-Way carves a path through death) and a
    genuinely DISTINCT mechanic (defensive survival, not a bigger kill), removing
    the standard-vs-champion overlap. HoonDing-flavored copy. Staged into the
    deferred build batch.
  - The literal outnumbered/outleveled COMBAT-ODDS detection stays POST-1.0 (the
    design's earmarked risky/farmable trigger; ships only if proven farm-resistant).
(b) Ash'abah stigma scope -- RESOLVED 2026-06-20 (user ruling): TEXT-ONLY stigma
in currently-used surfaces, modeled on the PROVEN Altmer crisis-state surfacing.
Mirror the Altmer pattern (PDV_AltmerCrisisTrack posture enum +
GetAltmerCrisisStateLabel Survey/status label dispatch, parallel to
GetRedguardSectLabel) to surface an Ash'abah stigma/burden standing in
Survey/status + a marked-moment top-left notice -- but WITHOUT the Altmer
Lorkhan-pressure piety DEDUCTION (the Altmer crisis costs piety via
HandleAltmerLorkhanPressure; the Ash'abah stigma is text-only, no mechanical
penalty per ruling). Noted for routine undead/burial duty; Marked only for major
burden-bearing (major tombs, major necromancer operations, lich/named-undead
defeats, costly impurity choices), with the stigma line fired AT the marked deed
paired with the Tu'whacca recognition reward so the burden reads as earned. NO
service penalties (design-locked), no voiced reaction lines (V2). Full dynamic
social treatment stays post-1.0. Reuses existing proven Survey/status +
notification infrastructure -- no new social system. Staged into the deferred
build batch.

**Tradeoff/risk:** Capping HoonDing conservatively risks make-way feeling too
rare to register as the Redguard signature; opening it toward combat-odds
automation risks a farmable best-in-slot piety faucet and the generic-combat
leak the project just closed. Ash'abah light-authored stigma risks the
emotionally-central sect feeling thin; a fuller simulation risks scope and
vanilla-support weakness (Redguard dignity dialogue is weak in vanilla).

**Blocks beta?** No (the Redguard packet passed 2026-06-19; these are tuning/
content depth). **Blocks 1.0?** Partial -- the HoonDing endpoint and Ash'abah
scope should be decided before the Redguard 1.0 feel is signed off, but neither
blocks the beta packet.

**Tag (a):** RESOLVED 2026-06-20 (user ruling -- retarget standard make-way +
Tava regains road-passage, drop weekly cap for dedup+decay, champion -> proven
cheat-death survival save, combat-odds post-1.0). **Tag (b):** RESOLVED
2026-06-20 (user ruling -- text-only stigma in existing surfaces, modeled on the
proven Altmer crisis-state surfacing, no piety penalty).

---

## Decision 7 -- Breton light Vigilant-of-Stendarr pressure encounter

**Decision:** Whether to include a light Vigilant-of-Stendarr pressure
encounter in 1.0, conditioned on it being cheap.

**Context read:** `PDV_TargetEndStates_1.0.md` lines 576-577 ("A light Vigilant
pressure encounter is desirable later... Prefer authored road/letter/contract
pressure over real crime-gold bounty mechanics; this should not block Breton
1.0 unless the encounter pattern proves cheap"); `PDV_V2_Backlog.md` lines 64-66
(Breton Vigilant of Stendarr pressure encounter -- CAT-5 / Section 25.9 marks it
optional/slip-able post-1.0 unless promoted by a later content pass; likely
voice-coupled if it surfaces as dialogue).

**Recommendation:** RESOLVED 2026-06-20 (user ruling). 1.0 ships ONLY a text-only
"Vigilant attention" Survey/status nod at high WitchcraftExposure, reusing PDV's
proven surfacing (parallel to the Altmer crisis + Ash'abah stigma). NO encounter,
voice, spawn, or bounty in 1.0. The actual encounter is DEFERRED, and the richer
idea -- at the top "Notorious" witness-notoriety band, have Vigilants of Stendarr
AND werewolves/vampires identify the player as hostile and attack on sight -- is
spun off to a separate POST-1.0 design-spike session (task_54dd32a0; deliverable a
dossier, not a build). HARD constraint carried into that spike: the Vigilants are
massacred early in the Dawnguard DLC, so any actual Vigilant encounter must gate
on Vigilants-still-active. This connects to the already-designed-but-unbuilt
curse-access notoriety bands (Suspected/Known/Notorious; Hircine/Molag Bal) in
PDV_DecisionMemo_CurseAccessReconciliation.md / PDV_V2_Backlog.md.

**Tradeoff/risk:** Including it adds Hidden-Art pressure that matches existing
disabled vanilla Daedric-confrontation dialogue and deepens the Breton Notorious
fantasy; but if it surfaces as dialogue it becomes voice-coupled (V2), and
crime-gold bounty mechanics are explicitly rejected. Deferring leaves Hidden Art
exposure as PDV-authored pressure without an external-hunter encounter.

**Blocks beta?** No. **Blocks 1.0?** No (explicitly slip-able; "should not block
Breton 1.0").

**Tag:** RESOLVED 2026-06-20 (user ruling -- text-only Vigilant nod for 1.0;
encounter + the Notorious-tier hostile-on-sight hook spun off to a post-1.0 design
spike, task_54dd32a0).

---

## Decision 8 -- Non-voiced recognition fallback surface selection

**Decision:** Which non-voiced surface carries V1 recognition fallback
(Survey/status vs another surface), with Runil retained as V2 prep.

**Context read:** `PDV_Architecture_v3.md` header lines 73-76 ("Runil is
retained only as planned V2 prep for Altmer Auri-El crisis/recovery recognition;
V1 uses Survey/status or another non-voiced fallback") and lines 118-120 ("Runil
remains the first planned V2 Altmer recognition candidate... V1 uses non-voiced
fallback surfaces"). `PDV_Phase20_BetaReadinessRemainder.md` line 137 confirms
V1 Daedric promotion is non-voiced only (MessageBox, notification, Survey/status,
descriptions, book/note, passive text); voiced NPC recognition is V2.

**Recommendation:** Use SURVEY/STATUS as the primary V1 non-voiced recognition
fallback, with MessageBox/notification and effect/Survey descriptions as the
supporting non-voiced surfaces already enumerated for V1. Keep Runil as V2 prep
only and do not wire any voiced recognition for V1. The architecture header
already names Survey/status as the default V1 fallback; this is selecting the
documented option, not inventing one.

**Tradeoff/risk:** Survey/status is reliable and already the legibility lane,
but it is a menu-read rather than a felt world-recognition moment, so V1
recognition will feel quieter than the eventual V2 voiced Runil line. Choosing
"another non-voiced fallback" (e.g. a one-shot MessageBox at the recognition
beat) could feel more present but risks toast/dwell limits and copy-conformance
work. Survey/status is the lowest-risk surface that the docs already lean on.

**Blocks beta?** No (voiced recognition is V2; V1 fallback surfaces exist).
**Blocks 1.0?** No (Survey/status fallback satisfies V1; Runil is V2).

**Tag:** CAN RESOLVE FROM DOCS (recommend SURVEY/STATUS -- the v3 header names
it as the V1 default with Runil deferred to V2). The choice of an additional
non-voiced surface, if any, is a minor design preference for ratification.

---

## Decision 9 -- WS-3 branding / visual-asset product decisions (FP-050..FP-054)

**Decision:** Five branding/visual-asset calls: FP-050 banner home (repo root
vs `assets/` vs Nexus-only), FP-051 Nexus mod-page art set, FP-052 MCM
splash/header in or out, FP-053 FOMOD installer vs single-folder install, FP-054
medallion item art.

**Context read:** `PDV_FinalPolishLook_Ledger.md` lines 152-160 (WS-3 table; all
five are state "decision-needed" or "pending commit" with the user as the
decider). The ledger places these in WS-3 "Branding / visual assets," which the
final-polish branch state notes are presentation/branding scope, distinct from
functional gaps.

**Recommendation (for ratification only; these are product/business judgment):**
- FP-050: track the banner under `assets/branding/` and include it in the
  closeout commit (it is already placed there), or deliberately exclude before
  release -- recommend INCLUDE under `assets/`.
- FP-051: choose one Nexus art set from `scratch/prisma-art/` candidates --
  user's brand call.
- FP-052: MCM splash -- recommend OUT for 1.0 (optional, no functional value;
  add later if desired) unless branding wants it.
- FP-053: install model -- recommend SINGLE-FOLDER for 1.0 simplicity, move to
  FOMOD only if optional components (e.g. compat patches) ship.
- FP-054: medallion art -- coordinate with the D1 medallion channel (FP-041);
  assign model/icon when the D1 medallion surface is finalized.

**Tradeoff/risk:** These are presentation choices with no machine gate; the
risk is purely product polish and Nexus-page quality, plus a minor install-UX
tradeoff on FOMOD vs single-folder. None affect runtime correctness.

**Blocks beta?** No (branding is off the beta-feel path entirely). **Blocks
1.0?** Partial -- a public 1.0 launch wants a banner, page art, and an install
model decided, but each is a quick product call, not engineering work.

**Resolution:** RESOLVED 2026-06-20 (user accepted the defaults): FP-050 banner
under `assets/branding/` + include in closeout; FP-051 Nexus art = user's brand
call, to choose later (offer to help generate/compare stands); FP-052 MCM splash
OUT for 1.0; FP-053 SINGLE-FOLDER install for 1.0 (FOMOD only when optional
components ship); FP-054 medallion art deferred until the D1 medallion surface
(FP-041) is finalized.

**Tag:** RESOLVED 2026-06-20 (user accepted defaults; FP-051 art selection
remains an open user-taste task, not a blocker).

---

## Decision 10 -- Stale pdv-phase20-reward-author --check first-tier drift

**Decision:** Whether to refresh the legacy `pdv-phase20-reward-author --check`
contract tool (which reports stale first-tier text/form drift), or treat its
drift as non-blocking because the newer readback audit is authoritative.

**Context read:** `PDV_BetaFeelReleaseGate.md` lines 67-77 ("treat
`pdv_phase2_reward_readback_audit.mjs --json` as the reward/deity/neglect
readback gate before beta-feel evidence intake. The older
`pdv-phase20-reward-author --check` contract check still reports stale
first-tier text/form drift across multiple races and should not block
Altmer/Breton reward closeout unless that tool or contract is intentionally
refreshed"); `PDV_BetaReadinessClosureAudit.md` lines 36-39 (`NOT_BETA_READY`
is the expected verdict until blockers are intentionally closed; a failing audit
is evidence, not a broken tool). The reward-readback audit is at 1280/1291 PASS
across the recent passes (AGENTS.md), i.e. the authoritative gate is green.

**Recommendation:** TREAT THE LEGACY TOOL'S DRIFT AS NON-BLOCKING. The release
gate doc explicitly names `pdv_phase2_reward_readback_audit.mjs` as the
authoritative reward readback gate and says the older
`pdv-phase20-reward-author --check` should not block closeout unless the tool or
contract is intentionally refreshed. Refreshing the legacy contract is optional
hygiene, not a beta gate. (Note: the legacy tool was spawned as a
"re-sync the stale T1 reward contract" follow-up per AGENTS.md line 977 -- doing
that refresh is a clean-debt task, not a blocker.)

**Tradeoff/risk:** Leaving the legacy `--check` drifted means anyone running
that older command sees red and may mistake it for a real failure (false-alarm
cost). Refreshing it spends tool/contract-sync effort to silence a check that
the authoritative audit already supersedes. The mitigation is documentation:
the release gate already records that the authoritative gate is the readback
audit.

**Blocks beta?** No (the authoritative readback gate is green; the legacy tool
is explicitly non-blocking). **Blocks 1.0?** No (optional clean-debt refresh).

**Tag:** CAN RESOLVE FROM DOCS (recommend TREAT AS NON-BLOCKING; optionally
refresh the legacy contract as clean-debt -- the release gate doc designates
the readback audit as authoritative).

---

## Decision 11 -- homeOrPrivateOnly condition shape + D-30 read-count verifier metric

**Decision:** (a) The condition shape for `homeOrPrivateOnly` (the Dunmer
private/home shrine bonus), which currently has no implemented shape; and (b)
whether to add a per-deity StorageUtil read-count metric to verifier output --
(a) informational, (b) soft cap, or (c) no.

**Context read:**
(a) `PDV_Architecture_v3.md` Dunmer Slice 4 (~line 2456): the substrate "Done
when" ships portable shrine prayer and player-owned-home bonus granting
origin-only substrate progress UNCONDITIONALLY (no location gate proven).
`AGENTS.md` line 999 records the open design decision: the spec's
`homeOrPrivateOnly` flag "has NO implemented condition shape anywhere (the
Dunmer `homeOrShrineOnly` precedent shipped unconditioned in V1) -- either lock
a condition shape or rewrite the player text to drop the location promise."
The same precedent governs Redguard FarShoresToken (RecordSpec sec.4: the
home/private `IsInInterior`+`IsOwner` variant is documented POST-1.0; V1 ships
unconditional).
(b) `PDV_Architecture_v3.md` D-30 (~lines 2700-2707): "Add per-deity StorageUtil
read count to verifier output?" Options (a) yes informational, (b) yes with a
soft cap (warn above N reads per `ScoreAction()`), (c) no. The doc's own
recommendation is "(a). Visibility is cheap; capping prematurely is constraining."

**Recommendation:**
(a) RESOLVED 2026-06-20 (user ruling): BUILD the gating -- do NOT ship
unconditional. Make "home" real by cloning the Argonian bed-of-choice
declaration into a Dunmer-namespaced primitive (`TryDunmerHomeDeclarationSleep`,
`IsPlayerAtDunmerDeclaredHome`, `PDV.DunHome.DeclaredFormID`), ancestor-flavored
copy, IMMEDIATE declaration (sleep once to make a cell your ancestor-space; no
10-14 day settle clock -- the deeper grow-into-home rite stays Argonian-only).
The home bonus is EVENT-DRIVEN, not a passive aura: praying with the portable
urn at the declared home fires the bigger progress step (HomeBonusDelta 8 vs
PrayerDelta 5) plus a timed restorative PULSE (mirroring how RootedRest casts on
Argonian bed-of-choice return). The pulse is HEALTH (not Magicka) regen, and
CRITICALLY it is authored as a flat Restore-Health effect (Value-Modifier on the
Health AV + Recover flag, or a scripted RestoreActorValue("Health",x) HoT) --
NOT a HealRate/HealRateMult rate multiplier, because Requiem drives base
health-regen to ~0 and would swallow a rate buff (memory:
requiem-proof-heal-flat-restore-not-rate). The `homeOrShrineOnly` Magicka-Regen
effects are removed from the always-on substrate blessing (which keeps only
Magic Resistance +3/+9/+20%); the substrate player text drops the Magicka-Regen
line. Magnitudes (+6%/+15% by tier, duration) stay PROVISIONAL pending the
Dunmer row review. Naming correction: the Dunmer spec field is `homeOrShrineOnly`,
not the `homeOrPrivateOnly` this memo originally named. Build is staged into the
deferred post-testing batch; the Dunmer run-sheet home-bonus slot is rewritten to
test the new event-driven pulse (declare home -> pray with urn there -> HP bar
moves under a Requiem list).
(b) Adopt D-30 option (a): add the per-deity StorageUtil read count as an
INFORMATIONAL verifier metric, no soft cap. This is the doc's own recommendation.

**Tradeoff/risk:**
(a) Unconditional V1 keeps the bonus always-on, which is simpler and matches
precedent but loses the "shrine feels private/home-special" fiction unless the
text is rewritten to not promise it; a leftover location promise in player text
with no condition is a real text-vs-behavior bug. Locking a condition shape adds
authoring (the race-author tool currently only implements `nightOnly` conditions)
and a runtime gate to prove.
(b) Informational read-count visibility is cheap and surfaces hotspots; a
premature soft cap could warn on legitimately read-heavy `ScoreAction()` paths
and constrain design (the exact reason D-30 recommends against it). Choosing "no"
forgoes cheap visibility.

**Blocks beta?** No (both are off the beta-feel path; the substrate already
ships unconditionally and scores). **Blocks 1.0?** Partial -- (a) needs the
text-vs-behavior mismatch resolved before 1.0 player-facing copy is finalized;
(b) is a tooling nicety that blocks nothing.

**Tag (a):** RESOLVED 2026-06-20 (user ruling -- build the gating via the
Argonian bed-of-choice clone, event-driven home-prayer pulse, flat Requiem-proof
Restore-Health, Health regen). **Tag (b):** CAN RESOLVE FROM DOCS (recommend
option (a) informational -- D-30's own recorded recommendation).

---

## Decision 12 -- Nord Phase-20 manual-evidence reconciliation

*(Added 2026-06-20.)*

**Decision:** How to close the Nord Phase-20 manual-evidence gap. Nord is carried
as "Pass" by the human gate-ledger (via the earlier Nord/Kyne pilot) but has NO
Phase-20 structured evidence in `PDV_Phase20_ManualEvidenceLedger.json` (all 7
slots `pending`, no `evidenceSummary`), so the strict gate counts Nord among the
five races holding `NOT_BETA_READY`. Pick: (A) run a full focused Phase-20 Nord
packet; (B) record a documented carry-over from the pilot proofs into the
structured slots; or (C) a hybrid -- carry over the slots the pilot genuinely
proved and run a short packet for the Phase-20-specific dimensions.

**Context read:** the Nord block of `PDV_Phase20_ManualEvidenceLedger.json` (all
7 slots `pending`; `immersiveHookProof` already carries a 2026-06-04 accepted P2
book-route log proof for Old Ways + Hircine/Arkay, with the correct origin-settle
ignore-then-route behavior); the 2026-06-19 reconciliation in
`PDV_BetaFeelBurndown.md` line 34 (Nord listed among the 8 "Pass" via the
gate-ledger) and commit 709eb78; the coverage baseline that Phases 13-18 are
runtime-proven on the Nord/Kyne pilots (Kyne offer engine, CurseState
werewolf/vampire/clear, neglect, decay, Phase 18A/B Survey/MCM). Note the four
other packet-accepted races (Argonian/Redguard/Breton/Orc) each had an
`evidenceSummary` to back-fill from on 2026-06-19; Nord uniquely has none, so
there is nothing to back-fill -- the evidence must be either carried over with
citation or freshly collected.

**Recommendation:** OPTION C (cited hybrid), for ratification:
- Carry over -- with explicit pilot citations and proof-bucket tags -- only the
  slots the Nord/Kyne pilot genuinely proved: the curse-posture and neglect/scar
  arms of `surveyStatusClarity`/`stackSnapshot`, plus `immersiveHookProof`'s
  already-recorded 2026-06-04 route proof. Mark each `evidence-recorded` with a
  "carried from Nord/Kyne pilot" note naming the exact proof.
- Run a SHORT focused Nord packet for the Phase-20-specific dimensions the pilot
  did NOT explicitly cover for Nord: `wrongOriginRejection` (non-Nord origin
  reads nothing native), `genericHookRejection` (generic travel/kills/sleep/
  crafting/repeated-shrine do not over-trigger), the dense-hook-suppression half
  of `stackSnapshot` (one active favor + suppressed faucets), and `surveyStatusClarity`
  in the Phase-20 sense (broad/focused patron + contextual favor cap legibility).
- Do NOT teach the strict gate to honor the prose gate-ledger verdict; keep it
  structured and fail-closed. Promoting a prose "Pass" into the machine gate
  would erode the exact safety that surfaced this gap.

Rationale: a pure carry-over (B) over-claims -- it would convert pilot
mechanic-proof into Phase-20 manual-acceptance proof for dimensions
(wrong-origin, generic-silence, dense-hook stack) the pilot never tested, which
the proof-boundary discipline forbids ("do not collapse different proof classes
into one claim"). A full fresh packet (A) is honest but re-tests dimensions the
pilot already proved. The hybrid is the fastest honest path, and Nord is the
most mature race to test.

**Tradeoff/risk:** The hybrid requires per-slot adjudication (which pilot
evidence maps to which Phase-20 slot) -- a small bookkeeping cost, with a risk of
over-mapping if done loosely (mitigated by citing the exact pilot proof per
slot). Option A avoids adjudication but spends a full packet run on the
most-proven race. Option B is fastest but is a proof-boundary violation and would
make the strict gate dishonest.

**Blocks beta?** The GAP does -- Nord is 1 of the 5 races whose pending slots
currently hold `NOT_BETA_READY`. The decision is which path closes it; closing it
(via A or C) removes Nord from the blocking list. **Blocks 1.0?** Same as beta
(it is a beta-evidence item, not a 1.0-only scope call).

**Tag:** NEEDS USER RULING (which path -- A, B, or C -- is a proof-policy call;
recommendation is C, the cited hybrid, with the gate kept structured).

---

## Summary table

| # | Decision | Recommendation | Blocks beta? | Needs user ruling? |
|---|----------|----------------|--------------|--------------------|
| 1 | Pending likes/dislikes event rows (303/334/335/351, 11 rows) | Defer routers; keep inert for beta | No | No (resolve from docs) |
| 2 | ~6 no-clean-hook track actions | Keep deferred; do not invent hooks | No | No (resolve from docs) |
| 3 | P2 quest-stage source fills per-source approval gate | Keep the fail-closed gate as-is | No | No (resolve from docs) |
| 4 | Recognition/CAT-6 scale gates; Bosmer Exchange_T1 fallback (4b RESOLVED) | 4a: hold gates (resolve from docs). 4b: drop Exchange_T1 fallback + fix stale note (record already live; Khajiit pilot proven) | No | 4a docs / 4b RESOLVED |
| 5 | Reward values: per-tier increments vs cumulative-totals | Read as current absolute tier values (cumulative) | No | No (resolve from docs; confirm before tuning) |
| 6 | Redguard HoonDing make-way (6a) + Ash'abah stigma (6b) -- RESOLVED | 6a: retarget standard -> curated breakthrough (Tava regains road-passage), drop weekly cap (dedup+decay), champion -> cheat-death survival save (proven PDV_T3DailyLowHealthSaveEffect), combat-odds post-1.0. 6b: text-only stigma in existing surfaces, modeled on proven Altmer crisis surfacing, no piety penalty | No | RESOLVED |
| 7 | Breton Vigilant pressure -- RESOLVED | 1.0: text-only "Vigilant attention" Survey/status nod (reuse proven surfacing); encounter + Notorious-tier hostile-on-sight (Vigilants/werewolf/vampire) spun off to post-1.0 spike (task_54dd32a0); gate any Vigilant encounter on Vigilants-still-alive | No | RESOLVED |
| 8 | Non-voiced recognition fallback surface | Survey/status primary; Runil stays V2 | No | No (resolve from docs) |
| 9 | WS-3 branding/assets FP-050..FP-054 -- RESOLVED | Defaults accepted: banner under assets/, splash OUT, single-folder install, medallion deferred (FP-041); FP-051 art = user's pick later | No | RESOLVED |
| 10 | Stale pdv-phase20-reward-author --check drift | Non-blocking; readback audit is authoritative | No | No (resolve from docs) |
| 11a | homeOrShrineOnly (Dunmer home) gating -- RESOLVED 2026-06-20 | Build it: Argonian bed-of-choice clone, event-driven home-prayer pulse, flat Requiem-proof Restore-Health (Health regen) | No | RESOLVED |
| 11b | D-30 per-deity StorageUtil read-count metric | Option (a): informational, no soft cap | No | No (resolve from docs) |
| 12 | Nord Phase-20 manual-evidence gap (gate-ledger Pass, zero structured evidence) | Hybrid: carry over cited pilot-proven slots + short packet for Phase-20-specific dims; keep gate structured | Yes (the gap holds the strict gate) | Yes (proof-policy call) |

**Net:** Of the original eleven, none block the technical beta gate -- each is
off the beta-feel path, already functional via live emitters, or process/tooling.
Decision 12 is the exception: the Nord evidence gap is one of the five races
currently holding the strict gate at `NOT_BETA_READY`, so closing it (recommended
via the cited hybrid) is squarely on the beta path. Items 1, 2, 3, 4(a), 5, 8,
10, and 11b resolve from the authoritative docs (take the recommendations as-is
unless overridden). Items 4(b), 6, 7, 9, 11a, and 12 were the genuine
product/design/proof-policy calls; ALL were RESOLVED via user ruling on
2026-06-20 (see each decision). Remaining open user-taste task: FP-051 Nexus art
selection (non-blocking).
