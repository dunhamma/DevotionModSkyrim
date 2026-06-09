# M0 — Substrate Seam Map
**Program:** PlayerDevotion "Living Deities" engine  
**Milestone:** M0 — Substrate Seam Map ("what we already have")  
**Date:** 2026-06-09  
**Status:** COMPLETE — exit gate satisfied (see checklist below)

---

## Exit-Gate Checklist

Every in-scope channel and driver must have a named seam or an explicit "NEW, justified" flag before M1 begins.

- [x] **A1 Demands & tithes** — named seam: dawn pass (`ProcessDawn`) + commitment-offer engine. EXTEND verdict; gap is the scheduler logic itself.
- [x] **A2 Omens & portents** — named seam: `PDV_DiegeticDirector.Dispatch()` fan-out (specced, not yet built). EXTEND verdict; gap is a new `eventClass` value + omen payload authoring.
- [x] **A3 Interventions/miracles** — named seam: contextual-favor surfacing ladder (`Marked` tier) + one-active-boost guardrail. EXTEND verdict; gap is a Story-Manager/PO3 trigger wrapper and Marked-tier spam guard.
- [x] **A4 Mood-scaled boons** — named seam: `SyncPatronBoonsToTier()` in `PDV_DeityBase.psc` + `Boon_Seeker/Devoted/Champion` spell properties. EXTEND verdict; gap is reading a mood value to scale magnitude.
- [x] **B1 Recent behavior (EWMA)** — NEW, justified: PDV computes stance-adjusted daily deltas (`PDV.PietyToday`) but has no bounded short-term sentiment window. A mood EWMA over those deltas is the core new state.
- [x] **B2 World context** — named seam: `location-theology-map.csv` (26 families) + `PDV_Substrate_KhajiitLunar` lunar substrate + `OnWeatherChange` event hook. REUSE+EXTEND verdict; gap is a mood-weight lookup table against those existing assets.
- [x] **B3 Inter-deity politics** — named seam: `RivalDeities[]` / `RivalMultipliers[]` on `PDV_DeityBase` + `ApplyRivalryPenalties()` in manager. EXTEND verdict; gap is surfacing the math as a narrated/player-visible beat.
- [x] **B4 Authored arcs** — named seam: CSV → JSON authoring pipeline (`PDV_QuestReactionMatrix_Full.csv` + `tools/pdv_quest_matrix_compile.mjs`). EXTEND verdict; gap is a new arc-state column/table that the pipeline emits and the mood service reads.

---

## Section 1 — Channel/Driver Seam Map

| Channel/Driver | Existing PDV asset (file/system) | Verdict | Gap to close |
|---|---|---|---|
| **A1 Demands & tithes** | `ProcessDawn()` in `scratch/phase2-live-source/PDV__ManagerQuest.psc` owns the commitment-offer recompute (`COMMITMENT_OFFER_THRESHOLD`, `COMMITMENT_DECLINE_DELAY_DAYS`, `COMMITMENT_REFUSE_COOLDOWN_DAYS`) and neglect/decay application. It already iterates every deity via `PDV_FLST_AllDeities`. | EXTEND | Add a demand-scheduler pass inside `ProcessDawn()` that (a) reads mood-band and (b) proposes/expires a time-boxed tribute window. No new tick; no new queue-persistence system. Mirror the commitment-offer recompute shape. |
| **A2 Omens & portents** | `handoff/PDV_DiegeticUX_CodexHandoff.md` → `PDV_DiegeticDirector.Dispatch(eventClass, key, direction, deityIndex, toneOverride)` fans out to screen FX (IMAD/EFSH), sound, music beds, journal (Dynamic Book Framework), body-marks (NiOverride), prayer anims (OAR), medallion (Description Framework). Each channel is soft-gated via `PDV_DiegeticDeps.Has()`. The director is specced but not yet built (Codex track). | EXTEND | Add an `"omen"` `eventClass` to the director's profile table. Author omen payloads (dream text, weather tell, audio cue) per deity in the CSV pipeline. No new director architecture needed; this is an authoring + one-new-eventClass addition. |
| **A3 Interventions/miracles** | Contextual-favor surfacing ladder (`PDV_Architecture_v3.md` §10.6) defines three tiers: `Quiet` / `Noted` / `Marked`. The `Marked` tier is explicitly "reserved for moments the player should remember." `GetFavorSurfacingLabel()` in the manager routes `Noted`/`Quiet` cases today. One-active-boost guardrail is live (`PDV_Architecture_v3.md` §10.7, keyword-family cap). `OnPlayerShoutAttack` and PO3 kill/hit events provide combat-moment hooks. | EXTEND | Wire a `Marked`-tier dispatch path for interventions (clutch save, smite, rivalry strike). A Story-Manager node or PO3-driven event fires `Dispatch("intervention", ...)`. Spam guard: track `PDV.Intervention.LastFire` in `StorageUtil` (same pattern as `ScoreRepeatableAction()`). |
| **A4 Mood-scaled boons** | `PDV_DeityBase.psc` `SyncPatronBoonsToTier(tierValue)` grants `Boon_Seeker`, `Boon_Devoted`, `Boon_Champion` (three `Spell` properties) as cumulative `AddSpell` calls. Boons are SPEL/MGEF records; magnitude is a CK-authored constant. `StorageUtil` key `PDV.Tier` is the source of truth. | EXTEND | A mood-band value (Wroth/Cool/Pleased/Exalted) written to `StorageUtil PDV.Mood.<deity>` at dawn can be read by a value-modifier MGEF via `GetVMQuestVariable` or a global mirror. No new boon grant machinery; magnitude scales within existing SPEL/MGEF. Must respect existing one-active-boost + family-cap guardrails. |
| **B1 Recent behavior (EWMA)** | `PDV__ManagerQuest.psc` writes `PDV.PietyToday` per deity every act (stance-adjusted, gain-rate-scaled, daily-cap-clamped). `ProcessDawn()` reads it and folds it into persistent piety. The individual daily delta is thus already computed. No short-term sentiment window exists. | **NEW, justified** | Design a bounded EWMA over recent stance-adjusted daily deltas: `MoodNew = α × PietyTodayScaled + (1 − α) × MoodOld`, clamped to [−100, +100], bucketed into 4 bands. Persist to `StorageUtil PDV.Mood.<deityFormID>`. Recompute in `ProcessDawn()` — no new tick needed. `α` is an authored property on `PDV_DeityBase` (like existing `ThresholdSeeker` scalars). This is the single new runtime state. |
| **B2 World context** | `references/vanilla-gameplay/pdv-crosswalk/location-theology-map.csv` maps 26 location families to deities. `PDV_Substrate_KhajiitLunar` is a live locked substrate (Masser/Secunda phase). `OnWeatherChange` hook in `scratch/phase2-live-source/PDV_PlayerEvents.psc` routes via EventBus. Season/time data available via `Utility.GetCurrentGameTime()`. Holiday data available via `Game.GetCalendarDayOfMonth()` / `GetCalendarMonth()`. | REUSE + EXTEND | No new hooks needed. A B2 mood-weight table (CSV column: `context_family → deity → delta_weight`) is authored alongside the existing location-theology map. At dawn or on weather-change, the manager looks up the player's current location family and weather and applies a small mood nudge. Lunar substrate already provides the Khajiit moon-phase value. |
| **B3 Inter-deity politics** | `PDV_DeityBase.psc` declares `Quest[] Property RivalDeities Auto` and `Float[] Property RivalMultipliers Auto`. `ApplyRivalryPenalties()` in `PDV__ManagerQuest.psc` fires stance-adjusted negative deltas to rival deities at `AwardPiety` time (Talos/Auri-El proven live). The math is silent. The Prisma panel surfaces one rival name (`PanelEventObject("rivalry", ...)`) but it is not narrated. | EXTEND | Surface the rivalry math as a player-visible beat: when a rival deity's mood crosses a threshold band downward due to player acts, emit a `Dispatch("rivalry", rivalDeityKey, "displeasure", ...)` omen. Requires only: (1) tracking the rival's previous mood band, (2) one new `eventClass` in the director. The ledger itself needs no changes. |
| **B4 Authored arcs** | `references/authoring/PDV_QuestReactionMatrix_Full.csv` → `tools/pdv_quest_matrix_compile.mjs` → runtime JSON is the live authoring pipeline. `references/phase4/PDV_StanceMatrix.csv` and `PDV_DeityLikesDislikes.csv` are additional authored tables. Arc state is today expressed only as quest-stage signals (PO3 `RegisterForQuestStage` on per-race FormLists). No arc-mood column exists. | EXTEND | Add an `arc_mood_delta` column to the quest-reaction matrix (or a parallel arc-events CSV). The compiler emits it into the runtime JSON. The mood service reads it at signal-award time. V1 scope: text/diegetic only (no new dialogue). The pipeline shape already handles this pattern. |

---

## Section 2 — Event-Hook Inventory

All hooks currently live in `scratch/phase2-live-source/PDV_PlayerEvents.psc` (player alias) and `scratch/phase2-live-source/PDV__ManagerQuest.psc` (manager quest), with registrations via vanilla Papyrus and `PO3_Events_Alias` / `PO3_Events_Form`.

| Event name | Where registered | What it currently triggers | Living-Deities channel/driver it could feed |
|---|---|---|---|
| `OnInit` | `PDV_PlayerEvents` (alias) | `RegisterForPlayerEvents()`, origin init, curse refresh | Initialization only; no LD feed needed |
| `OnPlayerLoadGame` | `PDV_PlayerEvents` (alias) | Re-register all hooks, origin re-init, curse refresh | B2 world-context re-evaluation on load |
| `OnUpdate` (single-update polling) | `PDV_PlayerEvents` via `RegisterForSingleUpdate(2.0)` | Origin race capture retry loop | No LD feed; administrative only |
| `OnSleepStart` | `PDV_PlayerEvents` via `RegisterForSleep()` | Trace only | B2: sleep location could contribute a context tick; low priority |
| `OnSleepStop` | `PDV_PlayerEvents` via `RegisterForSleep()` | Routes `RouteSleepStop()` via EventBus → Khajiit moon observance | **B2** (moon phase already feeds lunar substrate); also natural A1 demand-window check point |
| `OnLycanthropyStateChanged` | `PDV_PlayerEvents` (vanilla ReferenceAlias event) | `RouteCurseRefresh("lycanthropy_on/off")` | **A1/A3**: curse onset is a Daedric pact signal; could trigger Hircine demand or rival Aedra displeasure |
| `OnVampirismStateChanged` | `PDV_PlayerEvents` (vanilla ReferenceAlias event) | `RouteCurseRefresh("vampirism_on/off")` | **A1/A3**: Molag Bal pact signal; rival Aedra displeasure; potential intervention hook |
| `OnShoutAttack` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForShoutAttack(Self)` | `RouteShoutAttack()` → Talos/Kyne piety delta via EventBus | **B1**: already a stance-adjusted delta; could accumulate toward mood. **A3**: high-piety shout use could seed an intervention trigger |
| `OnBookRead` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForBookRead(Self)` | `RouteP2ImmersiveSource(akBook, "po3_book")` → per-race EventBus routes | **B4**: quest-related book reads already map to arc signals; could carry `arc_mood_delta` |
| `OnSpellLearned` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForSpellLearned(Self)` | `RouteP2ImmersiveSource(akSpell, "po3_spell")` → per-race EventBus routes | **B4**: spell school learning maps to deity alignment; Julianos/Magnus arc signal |
| `OnItemHarvested` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForItemHarvested(Self)` | `RouteP2ImmersiveSource(akProduce, "po3_harvest")` → Bosmer Green Pact, Breton, Khajiit routes | **B1**: already a delta source. **A1**: Bosmer pact-positive is an existing demand-adjacent signal |
| `OnWeatherChange` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForWeatherChange(Self)` | `RouteP2ImmersiveSource(akNewWeather, "po3_weather")` → Kyne/Khajiit routes | **B2**: direct world-context feed. Could trigger an omen dispatch for storm/clear-sky deities |
| `OnQuestStageChange` | `PDV_PlayerEvents` via `PO3_Events_Alias.RegisterForQuestStage(Self, quest)` per FormList entry (32 lists) | `RouteP2ImmersiveQuestStage()` → per-race EventBus routes | **B4**: quest-stage signals are the existing arc substrate; `arc_mood_delta` column attaches here |
| `OnPDVConcordatCompliance` (mod event) | `PDV_PlayerEvents` via `RegisterForModEvent("PDV.ConcordatCompliance", ...)` | `RouteConcordatPressure(true)` via EventBus | **B3/B1**: Concordat pressure already modulates Talos gain multiplier; feeds rivalry-politics and recent-behavior |
| `OnPDVConcordatDefiance` (mod event) | `PDV_PlayerEvents` via `RegisterForModEvent("PDV.ConcordatDefiance", ...)` | `RouteConcordatPressure(false)` via EventBus | Same as above — defiance |
| `OnObjectEquipped` | `PDV_PlayerEvents` (vanilla ReferenceAlias event) | `RouteBosmerGreenPactFood()` — checks food FormLists/keywords, routes violation/positive | **A1**: Green Pact positive is an abstinence-pact compliance signal; can feed demand-scheduler |
| `OnMenuClose ("RaceSex Menu")` | `PDV_PlayerEvents` via `RegisterForMenu("RaceSex Menu")` | Re-queues origin initialization | Administrative; no LD feed needed |
| `OnInit` | `PDV__ManagerQuest` | Full runtime wiring: Phase 8, Bosmer, Nord, contextual-favor runtime; registers `RegisterForSingleUpdate(1.0)` | No LD feed at init; dawn hook attaches here |
| `OnUpdate` (polling) | `PDV__ManagerQuest` via `RegisterForSingleUpdate(1.0)` | Runtime wiring refreshes, shout fallback re-register, timed dawn detection | **A1/B1/B2/B3**: `ProcessDawn()` is called from within the dawn-detection branch here. All LD dawn-tick logic (mood EWMA recompute, demand scheduler, rival-mood update) attaches to this same path |
| `OnPlayerShoutAttack` | `PDV__ManagerQuest` via `PO3_Events_Form.RegisterForShoutAttack(Self)` | Fallback shout scoring when alias-side misses (form-level registration) | **B1/A3**: same as alias-side `OnShoutAttack` — secondary redundancy for the shout piety delta |
| `ProcessDawn()` (not a Papyrus event — called from manager `OnUpdate` dawn-detection) | Invoked from `PDV__ManagerQuest.OnUpdate()` | Iterates `PDV_FLST_AllDeities`; applies piety-today accumulation, decay, grace, tier recompute, neglect, commitment-offer recompute; calls `RequestPanelRefresh()` | **A1**: demand-scheduler pass attaches here. **B1**: mood EWMA recompute attaches here. **B3**: rival-mood re-evaluation attaches here. **B2**: location/season/lunar context read attaches here |
| `SurfaceTransition()` (not a Papyrus event — internal manager function) | Called from tier-change / patron-state change paths in manager | Fires notifications, Prisma toasts, and (once built) `PDV_DiegeticDirector.Dispatch()` | **A2**: the single integration point for omen dispatch (one new `eventClass` addition). **A4**: tier-change already fires here; mood-band crossing fires same path |

---

## Section 3 — Dependency Footprint

### Hard dependencies (required at runtime — from `PDV_MOD_SETUP.md` §Core)

| Dependency | Role | Source |
|---|---|---|
| **SKSE64** | Papyrus runtime extension, StorageUtil, PO3 plugin chain foundation | skse.silverlock.org |
| **Address Library for SKSE Plugins** | Required by powerofthree's plugin chain | Nexus |
| **SkyUI** | MCM panel for debug controls and verbosity settings | Nexus #12604 |
| **powerofthree's Tweaks** | Required by powerofthree's Papyrus Extender | Nexus |
| **powerofthree's Papyrus Extender (PO3 PE)** | Hard runtime dep for v3 event hooks: `PO3_Events_Alias.RegisterForShoutAttack`, `RegisterForBookRead`, `RegisterForSpellLearned`, `RegisterForItemHarvested`, `RegisterForWeatherChange`, `RegisterForQuestStage`; also `PO3_Events_Form` on manager | Nexus |
| **PapyrusUtil** | `StorageUtil` — all per-deity piety, tier, mood, anti-farm keys live here | Nexus |
| **Prisma UI + DevotionPrismaBridge.dll** | C++ SKSE bridge for the Prisma panel; declared hard floor per `PDV_DiegeticUX_CodexHandoff.md` resolved decisions | Custom native build |

### Soft dependencies (graceful degradation — gated via `PDV_DiegeticDeps.Has(depName)`)

`PDV_DiegeticDeps.psc` (specced, not yet built) caches availability probes to `PDV.Diegetic.Dep.<name>`. Each channel emitter checks `Has(...)` before calling its framework API; a missing dep is a silent no-op, not an error. This soft-gate contract is defined in `handoff/PDV_DiegeticUX_CodexHandoff.md` Track A1.

| Soft dependency | `Has()` key | Channel(s) it enables | Fallback when absent |
|---|---|---|---|
| **Description Framework (DF)** | `"DF"` | A2 omen: medallion description text | Falls back to `Survey Devotion` MCM/notification surface |
| **Dynamic Book Framework (DBF)** | `"DBF"` | A2 omen: journal/dream log entries | Silent no-op; omen fires other channels only |
| **RaceMenu / NiOverride** | `"NiOverride"` | A2 omen: body-mark overlays (scar, warpaint, ash) | No body-mark; other channels still fire |
| **Open Animation Replacer (OAR)** | `"OAR"` | A2 omen: prayer animations at rite sites | Hard dep per `PDV_DiegeticUX_CodexHandoff.md` resolved decisions item 2 (OAR engine is the hard floor alongside SKSE+Prisma); emitter still guards with `Has("OAR")` for safety |
| **powerofthree's Papyrus Extender** | `"PO3"` | A2 omen: direct shader API (`po3 PE` shader call vs SPEL route) | Falls back to SPEL add/remove route for screen FX |

### Candidate soft-deps for the Living-Deities engine (flagged for M2 decision)

| Candidate | Potential role | Decision gate |
|---|---|---|
| **Spell Perk Item Distributor (SPID)** | B3 politics ambient distribution: faction/relationship ranks to patron-temple priests and rival zealots via `_DISTR.ini` (already referenced in `PDV_DiegeticUX_CodexHandoff.md` Track D). Also: ambient omen-prop distribution. | **Candidate, M2 decision** |
| **Keyword Item Distributor (KID)** | Keyword-tag vanilla items/NPCs for demand/tithe identification without formlist authoring overhead | **Candidate, M2 decision** |
| **Base Object Swapper (BOS)** | A2 omen ambient: swap static objects (shrine states, world-state tells) data-driven without cell edits | **Candidate, M2 decision** |
| **MCM Helper** | Cleaner MCM authoring for mood-band verbosity controls and demand-window player UI | **Candidate, M2 decision** |

---

## Section 4 — Verdict Summary

- **The engine is ~70% REUSE / EXTEND over genuinely new machinery.** The four output channels all have existing scaffolding to ride: A1 on the dawn-pass commitment/offer engine, A2 on the already-specced `DiegeticDirector.Dispatch()`, A3 on the contextual-favor surfacing ladder's `Marked` tier, A4 on `SyncPatronBoonsToTier()` + MGEF magnitude reads. No new tick loops, no new persistence subsystems for these channels.

- **The single genuinely new runtime state is the mood EWMA (B1).** A bounded short-term sentiment window over the stance-adjusted daily piety deltas PDV already computes — persisted to `StorageUtil PDV.Mood.<deityFormID>` and recomputed in the existing `ProcessDawn()` — is the core new thing. Everything else is an extension or an authoring addition layered over this one new value.

- **B2/B3/B4 are data extensions, not new systems.** World context (B2) needs a mood-weight lookup table against the existing `location-theology-map.csv` and weather/lunar hooks already in use. Inter-deity politics (B3) needs the rivalry ledger math surfaced as a player-visible omen rather than silent math — one new `eventClass` in the director and a mood-band-crossing check. Authored arcs (B4) need an `arc_mood_delta` column in the existing CSV pipeline, which the compiler already knows how to emit.

- **The dependency footprint stays lean for V1.** Hard deps are unchanged. Soft deps add nothing new to the already-specced DF/DBF/NiOverride/OAR/PO3 gate list. SPID, KID, BOS, and MCM Helper are all reasonable M2 candidates but none is load-bearing for the core mood/demand loop.

- **No seam was found for a standalone "demand queue with persistence."** The commitment-offer engine in `ProcessDawn()` is the right shape to extend, but the demand scheduler (propose/expire a tribute window across days) will need its own `StorageUtil` key family (`PDV.Demand.<deity>.*`) since no existing key set tracks a pending demand across dawn ticks. This is scoped as an EXTEND but has a non-trivial authoring surface (demand table CSV, expiry logic). It is the largest single gap in the A1 seam.

---

## M0 Review Notes (Opus pass)

Reviewer judgment layered on the cataloging above; these refine — they do not overturn — the seam map.

1. **Dependency-tier inconsistency to reconcile at M2 (flagged, not resolved).** Section 3 lists **Prisma UI** as a hard dep (line 82) and **OAR** under soft deps yet annotates both as a "hard floor per the Codex handoff resolved decisions." This contradicts the original "optional / graceful degradation" framing of Prisma and OAR captured earlier in the project. Because the user explicitly did **not** mark modlist compatibility as sacred (so a hard floor is *allowed*) **but did** prize data-driven/authorable graceful behavior, the true V1 dependency tier of Prisma and OAR is a genuine **M2 decision**, not an M0 fact. Action: M2 must read `PDV_DiegeticUX_CodexHandoff.md` "resolved decisions" verbatim and pin each of {Prisma, OAR, DF, DBF, NiOverride} to exactly one tier (hard / soft-gated), then state the player-facing fallback for any that stay soft.

2. **The two real builds are confirmed and small.** Everything reduces to (a) the **B1 mood EWMA** (one new `StorageUtil PDV.Mood.<deity>` value + 4 bands, recomputed in the existing `ProcessDawn()`), and (b) the **A1 demand namespace** (`PDV.Demand.<deity>.*` + an expiry pass). A2/A3/A4/B2/B3/B4 are authoring + one-new-`eventClass` extensions. This is the feasibility green light the program was looking for.

3. **Daedra-parity is structurally satisfied at the seam level.** The curse-state hooks (`OnLycanthropyStateChanged`, `OnVampirismStateChanged`) and the existing boon/price/stigma triples mean every channel has a Daedric expression on the *same* machinery (pact-obligation grammar for A1, darker-tone profile for A2). M4's pilot lock should still prove one Aedra + one Daedra to confirm parity in practice.

4. **Surfacing-ladder reuse for A3 is the strongest single finding.** The live `Quiet`/`Noted`/`Marked` tiers + `ScoreRepeatableAction()` cooldown pattern mean the intervention/omen **anti-spam guardrail already exists** — the highest-risk part of a "living deity" (annoying the player) is already mitigated by shipped code.

**Exit-gate status: SATISFIED.** Every channel/driver has a named seam or a justified NEW flag. The one open question (dependency tier) is correctly deferred to M2, not a missing seam.
