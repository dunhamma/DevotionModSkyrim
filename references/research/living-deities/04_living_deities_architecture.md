# M4 — Living Deities Engine: Architecture (LD-P1)

**Status:** REVISED in-the-loop 2026-06-10 (supersedes the autonomous 2026-06-09
draft). Aligned with the revised `03_feasibility.md` (same date): all seams
re-verified against **live** source (`D:/Wabbajack/modlists/Anvil/mods/Devotion/
Scripts/Source/`); the Hircine pilot re-specced as a **curse-gated deity actor**
(owner ruling 2026-06-10); the demand-fulfillment path rewritten against the two
real signal layers; constants corrected. Buildable spec for the engine MVP, shaped
to slot into `PDV_Architecture_v3.md` beside §12 (commitment), §14 (neglect),
§15 (decay), and the rivalry ledger.

> **Scope:** LD-P1 = the engine MVP. **This is not the mod's release V1** — per the
> owner, the Living Deities engine is forward work, not a V1-ship requirement.
> Builds on M0 (seams), M1 (borrows), M2 (mood model + shortlist), M3 (feasibility,
> revised).

> **Line-number convention:** function **names** are the contract. Live line refs
> below are from the 10,197-line `PDV__ManagerQuest.psc` as of 2026-06-10 and will
> drift; the 2026-06-09 draft's refs were ~950 lines stale.

## 1. What LD-P1 delivers
A god (Aedra or Daedra) that **notices your recent pattern, develops a mood the
game surfaces, asks one thing of you, scales its boon with that mood, and steps in
once when you're about to die.** Five runtime mechanisms — mood EWMA + bands ·
active patron pool · band-cross omens · mood-scaled boon · one demand type — plus
**one piece of authoring greenfield: the curse-gated `PDV_Deity_Hircine` actor**
(§2.0), without which the Daedra half of the pilot has no substrate. Pilot:
**Kyne + Hircine (werewolf-gated).**

## 2. Data model

### 2.0 NEW — `PDV_Deity_Hircine` (the one new actor; M3 Spike 0)
Live source has only `PDV_DaedricPath_Hircine extends PDV_DaedricPathBase` (the
transgressive-cult face: commitment signals + stigma). No `PDV_DeityBase` machinery
— no `clampedToday`, no tier boons, no `ScoreFromTable` — attaches to it, so every
LD-P1 mechanism below would silently no-op for Hircine. Per the owner's 2026-06-10
ruling, LD-P1 authors a **second, curse-gated face**:

- `PDV_Deity_Hircine extends PDV_DeityBase` — cloned from the `PDV_Deity_Kyne`
  shell; new QUST + membership in `PDV_FLST_AllDeities`.
- **Curse gate (preserves the likes/dislikes-matrix §8.2 no-ambient-drift rule):**
  `ScoreAction()` returns 0 and the deity is skipped for omen/demand eligibility
  unless `PDV_CurseState.IsWerewolf()` (live `PDV_CurseState.psc:60`; CK-readable
  mirror `PDV_GLO_CurseState`). A stray beast-kill still cannot pull a non-werewolf
  toward Hircine.
- Activation/deactivation rides the existing
  `PDV_DaedricPath_Hircine.HandleCurseTransition(oldState, newState, reason)`
  (live `:60`): on cure, the deity face's mood decays/zeros via the path's
  residue-recovery pattern. The path actor is **retained unchanged** as the
  onboarding / stigma / cure layer — two faces, same race-relative pattern as
  matrix §8.3.
- **Masking rule (hard requirement):** the new script's `ScoreAction` must
  `return ScoreFromTable(eventType)` after the curse gate — a `return 0.0` stub
  masks the data-driven base and kills its table rows (the 2026-06-08 lesson that
  broke 29 thin shells).
- New authoring: stance-matrix rows; `PDV.LD.*` like/dislike rows for hunt acts
  (promote + tune the matrix §7 Hircine block, currently "V2 reference only");
  SGE flag + SEQ entry on the new QUST (the BaanDar lesson).

The new deity quest must also follow the existing thin-shell + VMAD-wiring
discipline (properties baked at first init; existing saves need version-gated
runtime migration if values change post-ship).

### 2.1 `PDV_DeityBase` — new authored properties
Alongside existing `ThresholdSeeker/Devoted/Champion`, `RivalDeities[]`, `Boon_*`:
- `Float MoodAlpha` (EWMA weight; default 0.15; Kyne 0.12, Hircine 0.22)
- `Spell Boon_Seeker_Pleased / Boon_Seeker_Exalted` … band variants per existing tier boon (band-indexed; see §3.4)
- `Spell ClutchSaveEffect` (the deity-themed low-health save; §3.6)
- (LD-P2) `Float ExpectationDecayRate`, `FormList DemandActTags`

### 2.2 StorageUtil namespaces (per deity form, mirrors `PDV.Piety`)
- `PDV.Mood.<deity>` (float, [-100,100])
- `PDV.Mood.<deity>.Band` (int 0-3: Wroth/Cool/Pleased/Exalted)
- `PDV.Demand.<deity>.{Pending(int), Type(string), OfferedAt(float gametime), ExpiresAt(float), Fulfilled(int)}`

### 2.3 Global mirror (for CK conditions / MGEF reads)
- `PDV_GLO_PatronMoodBand` — the active patron's band (mirrors the existing piety/tier-to-global pattern).

### 2.4 New authoring tables (CSV → JSON, mirroring `tools/pdv_quest_matrix_compile.mjs`)
- `references/authoring/PDV_DeityMood.csv` — `deity, alpha, band_wroth_max, band_cool_max, band_pleased_max, stance_ceiling`
- `references/authoring/PDV_DemandTable.csv` — `deity, demand_type, binding_layer, event_types, event_filter, quest_matrix_tag, wired_today, window_days, reward_tag, penalty_tag, anti_farm_cap, notes`.
  **Schema change vs the 2026-06-09 draft:** the free-text `act_tag_or_target`
  column is replaced by an explicit **signal binding** (see §3.5) — `binding_layer`
  ∈ {`faucet`, `quest_matrix`, `faucet|quest_matrix`}; `event_types` = pipe-separated
  `Int eventType` IDs from the likes/dislikes §4 vocabulary; `event_filter` =
  optional condition tag (e.g. `great_beast`); `quest_matrix_tag` = curated-layer
  tag; `wired_today` = honest yes/no/partial flag for whether the bound events are
  live yet (events 1–4 wired; the 300+ block reserved but unwired).
- `references/authoring/PDV_OmenProfile.csv` — `deity, transition (up/down/->Wroth/->Exalted/dream), toast_key, dream_text_key, tone`
- Compiler `tools/pdv_living_deities_compile.mjs` (clone of the quest-matrix compiler) + self-test `tools/pdv_living_deities_selftest.mjs` (vocab + parallel-array + no-empty-deity + binding-integrity gates). **Status: built + passing (Block A, 2026-06-10).**

## 3. Runtime shape

### 3.1 `ProcessDawn()` insertions (live `PDV__ManagerQuest.psc:3877`)
Add two sub-phases (following the existing `RunDawn*Noop` wrapper convention;
live ordering verified 2026-06-10):
```
RunDawnConsolidateScratch()      ; existing (:3896) — computes clampedToday
RunDawnUpdateMood()              ; NEW — EWMA + band recompute + crossing dispatch
RunDawnRefreshTrackStates()      ; existing
RunDawnApplyDecayNoop()          ; existing
RunDawnApplySpellAndNeglectLayersNoop()  ; existing
RunDawnProcessCommitmentOffersNoop()     ; existing (:3964)
RunDawnProcessDemandsNoop()      ; NEW — mirror of commitment offers (demand offer + expiry)
RunDawnNotifyNoop()              ; existing
RequestPanelRefresh()            ; existing
```

### 3.2 `RunDawnUpdateMood()` (B1) — folded to read `clampedToday`
Per deity, in the consolidation loop (before `PietyToday` is zeroed):
`MoodNew = Clamp(MoodAlpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-MoodAlpha)*MoodOld, -100,100)`,
clamp ceiling by `GetStanceForPlayer()` (§M2), recompute band, and if band changed →
`OnMoodBandCross(deity, oldBand, newBand)`.

**Constant correction:** `PIETY_DAILY_MAX_DELTA` is **4.3** live (`:313`), not the
5.0 the 2026-06-09 draft stated. Implement **symbolically** (reference the property,
never a literal). Recomputed pacing at sustained max signal: Kyne (α 0.12) reaches
Exalted in ~6 days, ~5.4-day impression half-life; Hircine (α 0.22) reaches Wroth
in ~2–3 days, ~2.8-day half-life.

**Input-breadth caveat (updated 2026-06-10 post-merge):** the day-to-day faucet
feeding `clampedToday` is runtime-proven for **Kyne combat events only**. The
non-combat 300+ receivers landed via main `2e665b7` (hybrid faucet wiring:
compiled/readback-clean, incl. 313/343; only 361 Trespass blocked), but **runtime
proof is pending** (`PDV_FaucetDetection_CKChecklist.md` §6). Mood works off live
signals from day one and broadens once the smoke confirms the new receivers — a
**runtime-proof dependency**, tracked, not a blocker.

### 3.3 `OnMoodBandCross()` → dispatch (A2 + A4 + A3 arming)
- Filter: deity ∈ active patron pool (reuse `HasRecentCommitmentSignalDays`, live `:6624`) AND anti-spam gate (`ScoreRepeatableAction`-style cooldown + `Marked` tier + MCM density) AND (for Hircine) the §2.0 curse gate.
- Up-cross → positive omen toast + `SyncPatronBoonsToBand`; Down-cross → negative omen toast (+ at Wroth, arm displeasure/clutch suppression).

### 3.4 `SyncPatronBoonsToBand()` (A4) — extends `SyncPatronBoonsToTier` (live `PDV_DeityBase.psc:332`)
Same `ClearAllBoons()` (`:346`) + gated `AddSpell` shape, but grants the
**band-indexed variant** of the current tier boon (`Boon_<tier>_<band>`). Re-grant
only on band-cross. Respects the one-active-boost + family-cap guardrails
(clear-before-add). *Avoids the engine limitation that an applied MGEF can't re-read
a global live.*

### 3.5 `RunDawnProcessDemands()` (A1) — mirror of `RunDawnProcessCommitmentOffers` (live `:4025`)
- **Offer:** `EvaluateDemandOffer()` mirrors `EvaluateFormalCommitmentOffer()` (live `:6356`): pick best eligible deity (band-crossed-down OR LD-P2 expectation-red) via a weight, set `PDV.Demand.<deity>.{Pending,Type,OfferedAt,ExpiresAt}`. One active demand per deity; pool-filtered.
- **Fulfillment — REWRITTEN (the 2026-06-09 draft's "act-tag hook" does not exist).**
  Live award signatures carry no string act-tag: `AwardPietyInternal(deity, Float,
  Bool)` (`:4351`), `ApplyQuestReaction(Quest, Int stageValue)` (`:816`). A demand
  therefore declares a **signal binding** (§2.4) against one or both real layers,
  and fulfillment is detected at each layer's *existing* routing point — no new
  parameter is threaded through the award path:
  - **Faucet binding:** in the router→`ScoreAction` path, after a positive score for
    deity D with a pending demand, if `eventType ∈ demand.event_types` (and the
    optional `event_filter` predicate passes, e.g. great-beast victim keywords) →
    fulfilled. Hircine *the Hunt* = event 1 (`kill-hostile-beast`) + `great_beast`
    filter.
  - **Quest-matrix binding:** in `ApplyQuestReaction`, if the matched matrix row's
    tag equals `demand.quest_matrix_tag` for deity D with a pending demand →
    fulfilled. Kyne *honor the wild* binds here (`the_hunt` is a quest-matrix tag,
    not a faucet event) plus any wired positive faucet events.
  - On fulfillment: set `Fulfilled`, single-act reset (clear demand, mood uplift) —
    the Sacrosanct "feed resets to zero" pattern.
- **Expiry:** in dawn, if `now > ExpiresAt` and not `Fulfilled` → mood penalty /
  (Daedra) displeasure-stage bump; clear pending; cooldown.

### 3.6 Clutch-save (A3) — extends `PDV_T3DailyLowHealthSaveEffect.psc`
Add a `mood >= Pleased` gate (read `PDV_GLO_PatronMoodBand` — a script-poll read at
trigger time, not an MGEF live-global read, so it is legal) and deity theming; route
the save moment through a `Marked`-tier toast. The daily-cap anti-spam already
exists in `TryApplyDailySave()` (`:49`). For Hircine the mood is itself curse-gated
(§2.0), so the save is implicitly werewolf-only. (LD-P2: optional Andromeda
conditioned-MGEF combat-only variant.)

### 3.7 Omens (A2) — extend live `SendPrismaEventToast`
Add `"mood_up"`/`"mood_down"`/`"demand"` event types to the live toast path
(`SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context,
String tierLabel, String rival)`, live `:1057`). Dream omens ride the live
`OnSleepStart` hook (`PDV_PlayerEvents.psc`) with a probability roll. Degrade to
`Debug.Notification` when Prisma absent. (Rich `DiegeticDirector` modalities =
LD-P2, pending that director being built.)

## 4. Verifier expectations (extend `tools/pdv_verify.mjs` / `pdv_content_verify.mjs`)
- Mood: `PDV.Mood.*` present + bounded after seeded deltas; band matches thresholds; band-cross logs once.
- Demand: `PDV.Demand.*` namespace integrity; one active per deity; fulfilled-resets-once; expiry-penalty-once; **every demand row carries ≥1 concrete signal binding** (self-test gate).
- Boons: every (tier × band) variant authored for pilot deities; no stacking after swap.
- Hircine gate: deity face scores 0 / stays silent while not werewolf; no double-fire against the path actor's curse transitions.
- Coverage: `PDV_DeityMood.csv` / `PDV_DemandTable.csv` / `PDV_OmenProfile.csv` rows compile; self-test passes (vocab, parallel-array integrity, no empty deity, binding integrity).

## 5. Authoring workflow
Author the three CSVs → `pdv_living_deities_compile.mjs` → runtime JSON under
`SKSE/Plugins/StorageUtilData/PlayerDevotion/`. CK: author the `PDV_Deity_Hircine`
QUST (SGE+SEQ!), band-variant boon SPEL/MGEF records, and the deity-themed
clutch-save effects. Run the self-test as a pre-wiring gate (per PDV's Slice-D
discipline).

## 6. Pilot lock content (LD-P1)
**Kyne (Aedra, NATIVE/Nord)** — `alpha 0.12` (patient). Demand: *honor the wild*
(binding: quest-matrix `the_hunt` tag + faucet events 313 rest-under-open-sky / 343
learn-word-of-power; window 4d — Kyne **penalizes** beast kills, so her demand must
never bind to event 1). **OPEN AUTHORING GAP (Block A grounding, 2026-06-10; HALF-closed post-merge):** the
`the_hunt` tag exists in `PDV_QuestReactionMatrix_Full.csv` only on two *Hircine*
rows (DA05 s100/s105); **Kyne has zero curated-matrix rows**. The faucet half is
landed: main `2e665b7` shipped 313/343 receivers (readback-clean; runtime proof
pending). Remaining before/with Block B: author Kyne-positive
`the_hunt`/`honor_the_wild` matrix rows; carry the 313/343 runtime proof in the
Block D smoke.
Omens: up "Kyne's winds favor you" / down "the winds turn cold against you"; dream
of a circling hawk. Band boons: Pleased = +stamina regen; Exalted = current Kyne T3
+ gust. Clutch-save "Kyne's Breath" = heal + gust knockback. Reuses
commitment-signal + neglect-spell + shout hooks.

**Hircine (Daedra, curse-gated deity face — §2.0; path face retained)** —
`alpha 0.22` (impatient). Deity face active only while `IsWerewolf()`. Demand:
*the Hunt* (binding: faucet event 1 `kill-hostile-beast` + `great_beast` filter;
window 3d; days-since-hunt = Sacrosanct/Growl model). Omens: down "the Hunt grows
restless"; dream of restless wolves; at Wroth → displeasure escalation
(interval-shortening). Band boons: Pleased = beast vigor; Exalted = stronger + the
existing werewolf hooks. Clutch-save "Hircine's Vigor" = heal + bestial surge.
Reuses `HandleCurseTransition` + the Phase-13 Hircine proof.

## 7. Traceability (every mechanic → borrow or justified novelty)
| Mechanic | Source / justification |
|---|---|
| **Curse-gated `PDV_Deity_Hircine`** | **NEW actor (owner-ruled 2026-06-10)**; gate = `PDV_CurseState` (in-repo); shell = `PDV_Deity_Kyne` clone; two-face pattern = matrix §8.3 |
| Mood EWMA over `clampedToday` | NEW (justified, M0/M2); input reuses live pipeline |
| 4 bands, fire-on-cross | CK3 stress banding |
| Per-deity valence baked in | PoE dispositions — in PDV stance/value pipeline (breadth caveat §3.2) |
| Stance caps ceiling | NEW (ties to existing stance matrix) |
| Patron pool filter | Hades godpool |
| Demand scheduler | PDV commitment-offer engine (in-repo) + Sims unmet-need |
| Demand fulfillment via **signal binding** | PDV's two real layers: router/`ScoreAction` eventType + quest-matrix tag (no act-tag seam exists) |
| Single-act reset | Sacrosanct feeding |
| Band-indexed boon swap | PDV `SyncPatronBoonsToTier` + Sacrosanct staged bundles |
| Clutch-save | PDV `PDV_T3DailyLowHealthSaveEffect` (in-repo) + Andromeda |
| Omen toast/dream | live `SendPrismaEventToast` + SoT sleep-check |
| Anti-spam triad | PDV `ScoreRepeatableAction` + `Marked` ladder + Growl/SoT |

## 8. Exit / build hand-off
Pilot lock named (Kyne + curse-gated Hircine); verifier rules defined (§4); every
new record/dep costed — **honest costing: Vanilla/PO3 only, no new hard dep, but
one new deity actor** (`PDV_Deity_Hircine` script + QUST + FLST membership +
stance rows + LD table rows), band-variant boons, clutch-save records, one global.
Every mechanic traced (§7). Owner ratification of the M2 tunables + this scope:
**done** (2026-06-09 ratification + 2026-06-10 Hircine ruling).
Build order (per `HANDOFF.md`): Block A authoring + tooling (**done, incl. the
binding-schema revision**) → Papyrus wiring (§3, **plus the new
`PDV_Deity_Hircine.psc`**) → CK records (§5) → compile + in-game proof per the
revised M3 "proof still required" lists → QASmoke counted run.

---

## Changelog — 2026-06-10 in-the-loop revision
1. Added §2.0: the curse-gated `PDV_Deity_Hircine` actor (M3 Spike 0; owner ruling).
   §1/§6/§7/§8 updated to stop claiming "no greenfield."
2. §3.5 fulfillment rewritten against the two real signal layers (no act-tag seam);
   §2.4 demand schema gained explicit binding columns.
3. §3.2: `PIETY_DAILY_MAX_DELTA` corrected 5.0 → 4.3 (symbolic implementation);
   pacing recomputed; faucet-breadth soft dependency stated.
4. All line refs updated to the 2026-06-10 live source; names-are-the-contract note.
5. §4 verifier gains binding-integrity + Hircine-gate checks; §6 Kyne demand
   explicitly forbidden from binding to event 1 (she penalizes beast kills).
