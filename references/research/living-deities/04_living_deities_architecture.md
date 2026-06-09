# M4 — Living Deities Engine: Architecture (LD-P1)

**Status:** DRAFT for owner ratification. Buildable spec for the engine MVP,
shaped to slot into `PDV_Architecture_v3.md` beside §12 (commitment), §14
(neglect), §15 (decay), and the rivalry ledger.

> **Scope:** LD-P1 = the engine MVP. **This is not the mod's release V1** — per the
> owner, the Living Deities engine is forward work, not a V1-ship requirement.
> Builds on M0 (seams), M1 (borrows), M2 (mood model + shortlist), M3 (feasibility).

## 1. What LD-P1 delivers
A god (Aedra or Daedra) that **notices your recent pattern, develops a mood the
game surfaces, asks one thing of you, scales its boon with that mood, and steps in
once when you're about to die.** Five mechanisms: mood EWMA + bands · active patron
pool · band-cross omens · mood-scaled boon · one demand type. Pilot: **Kyne + Hircine.**

## 2. Data model

### 2.1 `PDV_DeityBase` — new authored properties
Alongside existing `ThresholdSeeker/Devoted/Champion`, `RivalDeities[]`, `Boon_*`:
- `Float MoodAlpha` (EWMA weight; default 0.15)
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
- `references/authoring/PDV_DemandTable.csv` — `deity, demand_type, act_tag_or_target, window_days, reward_tag, penalty_tag, anti_farm_cap`
- `references/authoring/PDV_OmenProfile.csv` — `deity, transition (up/down/->Wroth/->Exalted), toast_key, dream_text_key, tone`
- New compiler `tools/pdv_living_deities_compile.mjs` (clone of the quest-matrix compiler) + a self-test (clone of `pdv_quest_matrix_selftest.mjs`).

## 3. Runtime shape

### 3.1 `ProcessDawn()` insertions (`PDV__ManagerQuest.psc:2932`)
Add two sub-phases (following the existing `RunDawn*Noop` wrapper convention):
```
RunDawnConsolidateScratch()      ; existing — computes clampedToday
RunDawnUpdateMood()              ; NEW — EWMA + band recompute + crossing dispatch
RunDawnRefreshTrackStates()      ; existing
RunDawnApplyDecayNoop()          ; existing
RunDawnApplySpellAndNeglectLayersNoop()  ; existing
RunDawnProcessCommitmentOffersNoop()     ; existing
RunDawnProcessDemandsNoop()      ; NEW — mirror of commitment offers (demand offer + expiry)
RunDawnNotifyNoop()              ; existing
RequestPanelRefresh()            ; existing
```

### 3.2 `RunDawnUpdateMood()` (B1) — folded to read `clampedToday`
Per deity, in the consolidation loop (before `PietyToday` is zeroed at `:2972`):
`MoodNew = Clamp(alpha*(clampedToday/PIETY_DAILY_MAX_DELTA*100) + (1-alpha)*MoodOld, -100,100)`, clamp ceiling by `GetStanceForPlayer()` (§M2), recompute band, and if band changed → `OnMoodBandCross(deity, oldBand, newBand)`.

### 3.3 `OnMoodBandCross()` → dispatch (A2 + A4 + A3 arming)
- Filter: deity ∈ active patron pool (reuse `HasRecentCommitmentSignalDays`) AND anti-spam gate (`ScoreRepeatableAction`-style cooldown + `Marked` tier + MCM density).
- Up-cross → positive omen toast + `SyncPatronBoonsToBand`; Down-cross → negative omen toast (+ at Wroth, arm displeasure/clutch suppression).

### 3.4 `SyncPatronBoonsToBand()` (A4) — extends `SyncPatronBoonsToTier` (`PDV_DeityBase.psc:228`)
Same `ClearAllBoons()` + gated `AddSpell` shape, but grants the **band-indexed variant** of the current tier boon (`Boon_<tier>_<band>`). Re-grant only on band-cross. Respects the one-active-boost + family-cap guardrails (clear-before-add). *Avoids the engine limitation that an applied MGEF can't re-read a global live.*

### 3.5 `RunDawnProcessDemands()` (A1) — mirror of `RunDawnProcessCommitmentOffers` (`:3077`)
- **Offer:** `EvaluateDemandOffer()` mirrors `EvaluateFormalCommitmentOffer()` (`:5249`): pick best eligible deity (band-crossed-down OR LD-P2 expectation-red) via a weight, set `PDV.Demand.<deity>.{Pending,Type,OfferedAt,ExpiresAt}`. One active demand per deity; pool-filtered.
- **Fulfillment:** in the act-tag award path (`AwardPietyInternal`/`ApplyQuestReaction`), if an act matching the demand's `act_tag` fires for that deity while pending → set `Fulfilled`, single-act reset (clear demand, mood uplift). (Sacrosanct "feed resets to zero".)
- **Expiry:** in dawn, if `now > ExpiresAt` and not `Fulfilled` → mood penalty / (Daedra) displeasure-stage bump; clear pending; cooldown.

### 3.6 Clutch-save (A3) — extends `PDV_T3DailyLowHealthSaveEffect.psc`
Add a `mood >= Pleased` gate (read `PDV_GLO_PatronMoodBand`) and deity theming; route the save moment through a `Marked`-tier toast. The daily-cap anti-spam already exists in `TryApplyDailySave()`. (LD-P2: optional Andromeda conditioned-MGEF combat-only variant.)

### 3.7 Omens (A2) — extend live `SendPrismaEventToast`
Add `"mood_up"`/`"mood_down"`/`"demand"` event types to the live toast path (`:3071/3087/3424`). Dream omens ride the live `OnSleepStart` hook (`PDV_PlayerEvents.psc:106`) with a probability roll. Degrade to `Debug.Notification` when Prisma absent. (Rich `DiegeticDirector` modalities = LD-P2, pending that director being built.)

## 4. Verifier expectations (extend `tools/pdv_verify.mjs` / `pdv_content_verify.mjs`)
- Mood: `PDV.Mood.*` present + bounded after seeded deltas; band matches thresholds; band-cross logs once.
- Demand: `PDV.Demand.*` namespace integrity; one active per deity; fulfilled-resets-once; expiry-penalty-once.
- Boons: every (tier × band) variant authored for pilot deities; no stacking after swap.
- Coverage: `PDV_DeityMood.csv` / `PDV_DemandTable.csv` / `PDV_OmenProfile.csv` rows compile; self-test passes (vocab, parallel-array integrity, no empty deity).

## 5. Authoring workflow
Author the three CSVs → `pdv_living_deities_compile.mjs` → runtime JSON under `SKSE/Plugins/StorageUtilData/PlayerDevotion/`. CK: author band-variant boon SPEL/MGEF records + the deity-themed clutch-save effects. Run the self-test as a pre-wiring gate (per PDV's Slice-D discipline).

## 6. Pilot lock content (LD-P1)
**Kyne (Aedra, NATIVE/Nord)** — `alpha 0.12` (patient). Demand: *honor the wild* (act_tag `the_hunt`/`honor_the_wild`, window 4d). Omens: up "Kyne's winds favor you" / down "the winds turn cold against you"; dream of a circling hawk. Band boons: Pleased = +stamina regen; Exalted = current Kyne T3 + gust. Clutch-save "Kyne's Breath" = heal + gust knockback. Reuses commitment-signal + neglect-spell + shout hooks.

**Hircine (Daedra, TABOO / CURSE via werewolf)** — `alpha 0.22` (impatient). Demand: *the Hunt* (slay a great beast, window 3d; days-since-hunt = Sacrosanct/Growl model). Omens: down "the Hunt grows restless"; dream of restless wolves; at Wroth → displeasure escalation (interval-shortening). Band boons: Pleased = beast vigor; Exalted = stronger + the existing werewolf hooks. Clutch-save "Hircine's Vigor" = heal + bestial surge. Reuses `OnLycanthropyStateChanged` + Phase-13 Hircine proof.

## 7. Traceability (every mechanic → borrow or justified novelty)
| Mechanic | Source / justification |
|---|---|
| Mood EWMA over `clampedToday` | NEW (justified, M0/M2); input reuses live pipeline |
| 4 bands, fire-on-cross | CK3 stress banding |
| Per-deity valence baked in | PoE dispositions — *already* in PDV stance/value pipeline |
| Stance caps ceiling | NEW (ties to existing stance matrix) |
| Patron pool filter | Hades godpool |
| Demand scheduler | PDV commitment-offer engine (in-repo) + Sims unmet-need |
| Single-act reset | Sacrosanct feeding |
| Band-indexed boon swap | PDV `SyncPatronBoonsToTier` + Sacrosanct staged bundles |
| Clutch-save | PDV `PDV_T3DailyLowHealthSaveEffect` (in-repo) + Andromeda |
| Omen toast/dream | live `SendPrismaEventToast` + SoT sleep-check |
| Anti-spam triad | PDV `ScoreRepeatableAction` + `Marked` ladder + Growl/SoT |

## 8. Exit / Codex hand-off
Pilot lock named (Kyne + Hircine); verifier rules defined (§4); every new record/dep
costed (Vanilla/PO3 only for LD-P1; no new hard dep); every mechanic traced (§7).
**Pre-implementation gate = owner ratification of the M2 tunables + this scope.**
Then: author the three CSVs + pilot CK records → wire `RunDawnUpdateMood` /
`RunDawnProcessDemands` / `SyncPatronBoonsToBand` → in-CK/in-game proof per the M3
"proof still required" lists → QASmoke counted run.
