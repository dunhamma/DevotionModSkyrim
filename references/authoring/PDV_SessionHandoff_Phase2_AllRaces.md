# PDV Session Handoff — Phase 2 (All-Race Propagation)

**Date:** 2026-06-07
**Status:** Phase A (design) COMPLETE. B1 (deity scripts) COMPLETE, 22/22 compile **0/0**. B2 (manager
wiring) — Argonian pilot LANDED + compiles 0/0; 9 more races pending.
**Read first (in order):**
1. `PDV_Phase2_DeityRoster_and_ArchitectureRulings.md` — binding rulings R1-R8 + master roster + ownership map.
2. `PDV_Phase2_CapstoneSignatures.md` — locked T3 capstone designs + mechanism library M1-M11 + draft set for remaining races + LOCKED implementation rules (once/day saves; ≤1 save/race; fallback-as-floor).
3. The previous handoff `PDV_SessionHandoff_KhajiitPilot.md` for context on the proven Khajiit pattern this Phase generalizes.

---

## 0. Continuation Addendum (2026-06-07)

The header above is preserved as historical context for the original Phase 2 handoff. Current state
after this continuation: Phase A design is complete; B1 deity scripts are complete; B2/B3 manager
and receiver wiring is tool-authored and compile-clean for all ten races; reward/neglect records are
authored in the live framework ESP; SEQ is refreshed; the Green Pact tag layer is record/script-wired;
and the V1 low-health T3 fallback capstone skeleton is live on the approved once-per-race save homes.
Remaining beta gate is runtime/manual packet evidence.

Implemented in this continuation:
- Preserved the Phase A baseline in commit `d9e649f`, then committed the all-race reward/readback
  tranche in `cd9ed5e`.
- Edited `tools/pdv_verify.mjs` with the user's explicit approval to raise the Mutagen bridge
  `spawnSync` buffer for strict JSON runs.
- Authored all ten race reward/deity/neglect records into
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp` with
  `tools/pdv-phase20-race-author`, reconciled shared deities, and refreshed SEQ.
- Finished the Imperial civic discriminator gap with five parseable family receiver FormLists:
  public-service, mercy, lawful-order, honest-work, death-duty. The legacy broad
  `PDV_FLST_P2_ImperialCivicSources` now routes as public-service fallback instead of awarding a
  generic Divine.
- Applied the same parseable-token approach to Nord static/P2 source IDs so unknown tokens no-op
  instead of collapsing into an undifferentiated lane.
- Extended `tools/pdv-phase20-p2-receiver-author` with `--author-green-pact`,
  `--check-green-pact`, `--author-capstones`, and `--check-capstones`.
- Implemented the Bosmer Green Pact equip hook in `PDV_PlayerEvents.psc`: Bosmer-only, food-only,
  event-driven, FormList-first with KID keyword fallback; plant foods route to
  `RouteGreenPactViolation`, meat/insect foods route to `RouteBosmerPactPositive`, fungi/eggs are
  ignored pending curation.
- Authored the five Green Pact FormLists, five Green Pact keywords, alias VMAD properties, and
  conservative KID placeholder at
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\KeywordItemDistributor\PDV_GreenPact_KID.ini`.
- Added `PDV_T3DailyLowHealthSaveEffect.psc`, a shared fallback capstone script using
  `RegisterForSingleUpdate` with exit cleanup, StorageUtil once-per-day keys, and debug-gated traces.
  It is wired to the seven V1 save homes: Imperial Akatosh, Altmer Auri-El, Nord Shor, Orc
  Legion/Exile, Redguard Tu'whacca, Khajiit Baan Dar, and Bosmer Bandit Road.
- Expanded `tools/pdv_phase2_reward_readback_audit.mjs` to check reward records, MGEF magnitudes,
  manager properties, FLST membership, SGE/SEQ, T3 capstone script attachments, and Green Pact
  FLST/KYWD/KID/alias wiring.
- Synced live source snapshots under `scratch/phase2-live-source/` for:
  `PDV__ManagerQuest.psc`, `PDV_PlayerEvents.psc`, `PDV_T3DailyLowHealthSaveEffect.psc`, and the
  Green Pact KID placeholder.

Static verification after this addendum:
- `node .\tools\pdv_compile.mjs --all` -> all scripts compile 0 errors / 0 warnings.
- `node .\tools\pdv_verify.mjs --strict-phase20-race-costing --json` -> PASS 2841, WARN 2, INFO 30
  (WARN is the pre-existing unnamed INFO record set).
- `node .\tools\pdv_phase20_base_wiring_audit.mjs` -> PASS.
- `node .\tools\pdv_prisma_ui_audit.mjs` -> PASS, 11 checks.
- `node .\tools\pdv_content_verify.mjs` -> PASS 1081, WARN 0.
- `node .\tools\pdv_phase2_reward_readback_audit.mjs --json` -> PASS 1268.
- Receiver author readbacks for P2 routes/properties, Green Pact, and capstones all PASS.

Runtime/manual status: not proven in this continuation. Each `PDV_BetaTestPacket_{Race}.md` still
needs the in-game accepted/rejected hook pass, Survey/status clarity, Active Effects reward snapshot,
save/load sanity, stack snapshot, and manual feel notes before external beta is truthfully shipped.

## 1. Why this work exists

Phase 1 (Khajiit pilot, prior handoff) proved one race end-to-end on the per-race piety →
tier → reward spine. Phase 2 propagates that to the other 9 races (Altmer, Argonian, Bosmer,
Breton, Dunmer, Imperial, Nord, Orc, Redguard) using the same proven engine. The user's stated goal
this session was *"push as far as we can, even if it's in phases or split by subagents."*

**Two corrections the design pass made vs the original plan:**
- The first author-agent draft would have created **9 deities per offer race** (50-60 total) — caught
  before fan-out and replaced with **shared records keyed by per-race stance** (R4). Final count: 22
  new deities, FLST 10 → 32 (bounded; dawn-iteration safe).
- The first reward-spec draft used names like `PDV_Bless_Imperial_NineDivines_T1`. The live manager
  hard-codes `PDV_Bless_Imperial_Civic_T1` etc. (R2). All 9 specs now match the manager's existing
  per-race broad-T1 editorIds.

---

## 2. What shipped this session

### Tooling
- **`tools/pdv-phase20-race-author/`** — NEW race-agnostic Mutagen records author. Generalizes
  `pdv-phase20-khajiit-author` (`--author-rewards`/`--fix-baandar`) into per-race-spec-driven
  `--author-rewards` + `--reconcile-shared-deity`. Builds 0/0. Idempotent dry-run reproduces the
  Khajiit ESP result. Khajiit fork kept as the regression baseline. Backward-compatible schema
  superset (`create:true|false`, `stances[]`, explicit-int `deityIndex`).

### Design artifacts (all under `references/authoring/`)
- `PDV_Phase2_DeityRoster_and_ArchitectureRulings.md` — rulings R1-R8 (broad-as-state, fixed
  broad-T1 editorIds, R3 per-patron naming, shared-deity model, focusable-only deities, Daedric via
  20C, three gate shapes, balance invariants); the **master deity roster** (owner ↔ reusers ↔
  stance per race); the **authoring order** (owners precede reusers). Updated to reflect Nord
  Old Ways gods being focusable (Shor/Tsun/Stuhn added to roster).
- `PDV_Phase2_CapstoneSignatures.md` — LOCKED Bosmer (4) + Khajiit (5) capstones (back-fills shipped
  pilot with +Unarmed on Baan Dar & Rajhin, +Magic Resist 15 on Alkosh); DRAFT capstones for the
  remaining 8 race sets (full per-god/per-lane signatures + mechanism family + ✅ buildable / ⚠️
  fiddly + fallback). LOCKED implementation rules: (a) all cheat-death saves are once/day; (b) ≤1
  save per race (Orc Stronghold re-flavored to kin-aura; Bosmer Living Story re-flavored to
  proactive rally); (c) **fallback-as-floor**: build the robust fallback as the guaranteed baseline,
  layer the precise detection on top, graceful degrade so no capstone is ever non-functional.
- **9 reward spec JSONs** — `PDV_{Race}RewardRecords.spec.json` for Altmer/Argonian/Bosmer/Breton/
  Dunmer/Imperial/Nord/Orc/Redguard. All valid JSON. All conform to the rulings (broad-as-state,
  manager editorIds, shared-deity create:false, ASCII text, ActorValue names, ~12% combat ceiling).
  Imperial owns the 8 Divines; Orc owns Trinimac (Altmer reuses); Nord owns Shor/Tsun/Stuhn after
  the rework. Convergence review: **0 collisions, 0 orphans, 19+3 new deities owned**.
- **4 missing costing manifests** — Breton/Dunmer/Imperial/Nord. Extracted from
  `PDV_Phase20_NoInGameProof_Gates.json`. P2 audit-only; no new reward volume beyond the gate.
- **Nord spec rework** — old R5 ("Nord owns zero new deities; Shor/Tsun/Stuhn broad-only") retired
  per the user decision *"Nord needs to have the Old Ways gods as options too."* `PDV_Deity_Shor/
  Tsun/Stuhn` are now create:true Nord-owned focusable; 8 Divines reuse from Imperial. Old Ways
  reward families authored with T1/T2/T3 stat lines; Nine Divines lane declared as a compact
  contract referencing per-god `PDV_Bless_Nord_<God>_T1/T2/T3` (full authoring deferred to a
  separate slice). Manifest reconciled.

### Papyrus (`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`)
- **22 new `PDV_Deity_*.psc` scripts** — all compile **0 errors / 0 warnings**:
  - **Imperial-owned shared Divines (8):** Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth (Talos pre-existing).
  - **Argonian-owned (2):** Hist, Sithis.
  - **Altmer-owned (2):** Magnus, Xarxes (Auri-El pre-existing).
  - **Dunmer-owned (2):** Boethiah, Mephala (Azura pre-existing).
  - **Orc-owned (2):** Malacath, Trinimac.
  - **Redguard-owned (3):** Tuwhacca, HoonDing, Leki.
  - **Nord-owned Old Ways (3):** Shor, Tsun, Stuhn.
  - Pattern: `extends PDV_DeityBase`, SIGNAL_* Int AutoReadOnly, DELTA_* Float Auto, ScoreCuratedSignal
    switch, no-op ScoreAction (except Shor: humanoid-combat ScoreRepeatableAction +0.5 honorable-kill,
    daily cap 4, cooldown 0.0104d — modelled on Kyne).
  - **SIGNAL_* block allocation** (collision-free): each new deity owns a hundreds block 1000-3199.
    Documented in each script header and confirmed via grep against existing scripts (which top out
    at 999).
- **Manager wiring — Argonian PILOT LANDED in `PDV__ManagerQuest.psc`** (compile 0/0):
  - Declared `PDV_Hist`/`PDV_Sithis` deity properties + 8 Argonian reward Spell properties + neglect spell property.
  - Double-routed the 4 Argonian handlers (`HandleArgonian{HistMaintenance, PeopleSupport, BedOfChoiceReturn, VoidSignal}`): preserve the existing substrate `Record*Scaled` call, ADD the small honest Hist pulse `AwardCuratedSignal(PDV_Hist, SIGNAL_HIST_PULSE, None)`; the Void handler additionally calls `AwardCuratedSignal(PDV_Sithis, SIGNAL_VOID_THRESHOLD, None)` gated on `PDV_ArgonianHistSubstrate.IsVoidFullyActive()`. Anti-farm: substrate keeps `ConsumeDailyRepeatMultiplier 0.7^n`; the pulse rides `AwardPiety`'s daily-cap. Two mechanisms, never on one magnitude.
  - Added `SyncArgonianRewards(Actor)` (modelled on `SyncKhajiitEmphasisRewards`/`SyncKhajiitEmphasisFamily`) — broad Hist T1/T2/signature on substrate-relation tier; People T1/T2/T3 on People-focus + tier; Sithis T1/T2 on Void-active + focus + tier; one foreground (People vs Void) at a time.
  - Added `IsArgonianHistNeglected()` + `SyncArgonianNeglectSpell(Bool)` (modelled on the Kyne/Khajiit neglect pair); bite gated on posture Silenced/Corrupted past the grace window.
  - No-offer integration: `GetFirstTierRaceRewardSpellForOrigin` returns `None` for `ORIGIN_ARGONIAN`; `SyncArgonianRewards`+`SyncArgonianNeglectSpell` are invoked beside the Khajiit calls inside `SyncFirstTierRaceRewardRuntime`. Argonian Hist_T1 is no longer in the active-patron grant list — substrate gates it.

### Spec stat tweaks recorded against the locked capstones
- Khajiit `PDV_Bless_Khajiit_BaanDar_T3` += `UnarmedDamage +10` (clawed brawler build).
- Khajiit `PDV_Bless_Khajiit_Rajhin_T3` += `UnarmedDamage +10` (clawed thief build).
- Khajiit `PDV_Bless_Khajiit_Alkosh_T3` ResistMagic 8 → **15** (deliberate capstone exception).
- Argonian `PDV_Bless_Argonian_Sithis_T2` += `UnarmedDamage +10` (Void-feral, the parallel build niche).

### Untracked / new file list (all design artifacts present locally, not committed)
See `git status -uall` near top of this packet. New files include the 9 reward specs, 4 new
manifests, the two coordination docs (rulings + capstones), the new `pdv-phase20-race-author/`
tool dir, plus the Khajiit pilot artifacts the prior handoff already documented.

---

## 3. Locked decisions this session (binding)

| # | Decision | Resolution |
|---|---|---|
| 1 | Tranche scope | All 9 races pushed through the ESP line + real-hook landing + static verify. |
| 2 | ESP writes | I drive them this session (deferred to Phase C, manual gate). |
| 3 | 4 missing manifests | I draft, user reviews. **Drafted; user has not yet reviewed.** |
| 4 | Author tool | Generalized into one race-agnostic tool; Khajiit fork = regression baseline. |
| 5 | Gate-type sequencing | Prove Imperial (offer) + Argonian (substrate) first. **Argonian landed.** |
| 6 | Piety model | **Native-track-as-parity (default).** Rewards gate on the race's own track (substrate/state/focus); piety stays the honest shared spine via a small pulse. Active-patron piety faucet kept only for Nord/Imperial/Altmer (theology genuinely supports a repeatable daily devotional act). |
| 7 | Real-hook landing | IN SCOPE this tranche — wire each race's designed acts to real game events (PO3 quest-stage/book/spell, player-alias sleep/load/time/location), keep QASmoke shims as regression harness. **Not started.** |
| 8 | Magnitude convention | **Two-tier:** universal combat ≤~12%; narrow resists / regen / utility may reach ~15 (CarryWeight +50). Matches shipped Khajiit pilot precedent (BaanDar HealRateMult 15, Khenarthi CarryWeight 50). |
| 9 | State-enum gating | Bosmer/Breton/Orc focused families key to the **sub-lane** (path/tradition/life-mode); Redguard hybrid (per-deity, sect-filtered); **Nord = any god in the chosen pantheon focusable** (Nine Divines lane reuses Imperial-owned Divines; Old Ways lane gets Kyne/Talos/Shor/Tsun/Stuhn focusable). |
| 10 | Breton | Tradition is the *filter*; a focused god offers within the tradition (KR = Stendarr/Mara/Arkay/Julianos; Green Way = Kynareth + Hircine via 20C; Hidden Art = Julianos lawful + Daedric via 20C). Standing tracks stay pressure-only. |
| 11 | Signature effects | **T3 capstone only.** Stat half stays under the Decision-8 ceiling; signature is the qualitative event. T1/T2 stay plain stats. Khajiit gets back-filled. |
| 12 | Cheat-death | All saves once/day. ≤1 save per race (Orc Stronghold re-flavored to kin-aura; Bosmer Living Story re-flavored to proactive rally). Remaining single saves: Akatosh, Auri-El, Tu'whacca, Shor, Orc Legion, Argonian Void, Khajiit Baan Dar, Bosmer Bandit Road. |
| 13 | Fallback-as-floor | For every ⚠️ fiddly-detection signature, the robust fallback is the GUARANTEED baseline; precise detection layers on top; graceful degradation. Binding for B2/B3. |
| 14 | Argonian unarmed | Lands on Sithis/Void T2 (Void-feral savagery, not claws). Parallel to Khajiit Baan Dar/Rajhin clawed niche. |
| 15 | Green Pact tag layer | IN SCOPE this tranche. Pattern modelled on **Biggie's Traits** (`D:\Wabbajack\modlists\ARR\mods\Biggie Traits\`): KID-distributed keywords on foods + `OnObjectEquipped` + `.IsFood()` + `.HasKeyword()`. Reference for Bosmer eat-meat/refuse-plant: `D:\Wabbajack\modlists\ARR\mods\Requiem - Food and Beverages Redone\Scripts\REQ_Apo_BosmerExclusion.pex`. |

---

## 4. The B2 picture (every agent independently confirmed it)

The per-race handlers and routes already exist in the manager and EventBus — `HandleImperial*`,
`HandleArgonian*`, `HandleOrc*`, `RouteNord*`, etc. — **but they're telemetry stubs**. They
increment StorageUtil counters and trace, they do NOT call `AwardCuratedSignal`. Two races' handlers
already DO score correctly and are the working templates:

- **Bosmer/Yffre** (`HandleBosmerGreenPactViolation`, `HandleBosmerLivingStorySignal` ~lines 1323, 1335) — the offer/active-patron template.
- **Khajiit substrate** (`HandleKhajiitMoonObservance` etc. ~1499+) — the no-offer / substrate template (now joined by the Argonian pilot).

**B2 remaining work, per race, follows one of two patterns:**
- **Substrate / no-offer** (Argonian DONE; Dunmer needs the ancestor double-route + Reclamation foreground faucet) — mirror Argonian/Khajiit.
- **Offer or state-gated** (Imperial, Altmer, Nord, Orc, Redguard, Bosmer-Breton-Khajiit-backfill) — declare deity properties + reward Spell properties; add `AwardCuratedSignal` calls inside the handlers; add per-race `Sync*Rewards` modelled on `SyncKhajiitEmphasisRewards`/`SyncKhajiitEmphasisFamily`; add per-race `Sync*NeglectSpell` (Nord reuses Kyne neglect per spec).

**One important B2 gap surfaced by the Imperial pilot agent:**
`RouteImperialCivicService` / `HandleImperialCivicService` take no civic-act-type discriminator —
the single route covers public-service / mercy / lawful-order / honest-work / death-duty, so the
handler currently can't decide which Divine to credit. B2 must add the discriminator (sourceId-parsed
or per-family routes) before per-Divine scoring is possible. The same shape applies anywhere
multi-god lanes flow through a single undifferentiated route (Nord Nine Divines lane likely needs
the same thing). The Argonian pilot did not hit this because each Argonian act is its own route.

---

## 5. What's left (in dependency order)

### B2 — manager wiring (Papyrus only; serial on `PDV__ManagerQuest.psc`)
Per-race, mirror the Argonian/Khajiit pilots:
1. **Imperial** (offer pilot): add civic-act-type discriminator on `RouteImperialCivicService`; declare 8 Divine props (+ Talos already exists); wire `Handle*` → `AwardCuratedSignal` per civic family + active focused patron's `SIGNAL_PATRON_CIVIC_FAVOR`; add new `HandleImperialCreedLoss` + route 113; add `SyncImperialRewards` + `SyncImperialNeglectSpell`. Talos gating already uses `PDV_ConcordatStandingTrack.RefreshState()`.
2. **Altmer** (offer): wire `RouteAltmerMagnusScholarship` → Magnus (`SIGNAL_DISCIPLINED_STUDY`/`MAGIC_MILESTONE`); `RouteAltmerXarxesLineage` → Xarxes (`SIGNAL_LINEAGE_HONORED`/`RECORD_KEEPING`); creed-loss handler. `SyncAltmerRewards` for broad Orthodox + Auri-El/Magnus/Xarxes focused; neglect spell.
3. **Dunmer** (substrate + Reclamation offer): `HandleDunmerPortableShrinePrayer` / `HandleDunmerPlayerHomeBonus` should double-route a small honest pulse to the active Reclamation patron. `HandleDunmerReclamationFocus` (currently telemetry only) must call `AwardCuratedSignal(active patron, ...)`. `HandleDunmerDeviationPrice` → `SIGNAL_RECLAMATION_ABANDONED` (-6.0) on active patron. `SyncDunmerRewards` (substrate-led ancestor + one focused Reclamation T1/T2/T3). Neglect spell.
4. **Orc** (state-gated): wire the 4 life-mode handlers + Malacath conduct to Malacath signals (`SIGNAL_STRONGHOLD_FORGE` etc.); add `SyncOrcRewards` (broad Malacath + one of Stronghold/City/LegionExile family by life-mode state + tier); neglect spell. Equal felt value across modes per the ledger.
5. **Redguard** (state-gated): wire Crown/Forebear/Ash'abah handlers to Tu'whacca / HoonDing / Leki by sect; add HoonDing weekly-cap handler + Leki conduct-gate handler (manager-owned); `SyncRedguardRewards` (broad AncestorSpine + one focused Yokudan patron by sect). Far Shores token mechanic. Neglect spell.
6. **Nord** (state-gated): wire OldWays / NineDivines route into the pantheon-baseline state + active focused god; for Nine Divines lane, civic-act-type discriminator (same as Imperial). `SyncNordRewards`. Reuse `PDV_SPEL_Neglect_Kyne` per spec.
7. **Bosmer** (state-gated, partly wired): `HandleBosmer*` already does `AwardCuratedSignal(PDV_Yffre, ...)`. Add the per-path reward grant logic in a new `SyncBosmerRewards` (broad Yffre + one path-family by `PDV_State_BosmerPath` + path's scoring-deity tier); add the missing routes 100-107 path-specific handlers.
8. **Breton** (state-gated, planning-ready): tradition-state-gated; reuse Divines/Kynareth signals; no new deity scripts. `SyncBretonRewards`. P2 audit-only — no new reward volume.
9. **Khajiit capstone back-fill**: existing `SyncKhajiitEmphasisFamily` works for T1/T2/T3 grant; the spec stat tweaks above (Baan Dar/Rajhin/Alkosh) need the new SPEL records authored at Phase C, then the manager just grants the updated record.

After each race: `node tools/pdv_compile.mjs --script PDV__ManagerQuest` → 0/0 required before moving on.

### B3 — real-hook landing (Papyrus + receivers)
Per race, wire devotional acts to REAL game events against `immersiveHookContracts` in
`PDV_Phase20_NoInGameProof_Gates.json`: PO3 `RegisterForQuestStage`/`BookRead`/`SpellLearned`,
player-alias sleep/load/time/location, Story-Manager. Keep QASmoke `devProofContracts` as the
regression harness. Single-file receivers (`PDV_PlayerEvents`, `PDV_EventBus`, `PDV_EventTypes`,
`PDV_EventSignalActivator`) are serial.

### Capstone signature MGEFs (Papyrus; per `PDV_Phase2_CapstoneSignatures.md`)
A small library of scripted MGEFs implementing mechanisms M1-M11 + the new ones identified during
the design pass (Mercy Overflow / Cycle / Guardian Aura / Honest Tithe / Allure / Disciplined Mind /
Champion's Duel / Web-Sense / Open-Sky Storm / Honored-Dead / Trial Vigil / Honored-Bond / Kin-Forged
Stand / Lone-Stand / Warden's Turn / Make-Way Surge / Duel Focus / Void Fearlessness / Recorded
Steadiness / Aperture Draw / Dawn's Refusal / Ascendant Light / Twilight Sight / Travel Momentum).
Many reuse one shared "low-HP once/day save" skeleton (the M4 family) with different payloads.
**Fallback-as-floor (Decision 13) is binding** — every fiddly detection ships with its robust
fallback active by default; precise detection layers on top.

### Green Pact tag layer (Bosmer; Decision 15)
Author curated FormLists:
- `PDV_FLST_GreenPact_ViolatingFood`, `PDV_FLST_GreenPact_ViolatingPotion`,
  `PDV_FLST_GreenPact_ViolatingIngredient`, `PDV_FLST_GreenPact_HonoringFood`,
  `PDV_FLST_GreenPact_WoodAct`.
- Distribute via KID (`PDV_GreenPact_KID.ini`) — keyword `PDV_KW_GreenPact_Plant` on plant
  ingestibles, `PDV_KW_GreenPact_Meat` on animal-source. Reference Biggie's Traits config + the
  Requiem F&BR `REQ_Apo_BosmerExclusion.pex` for the proven Bosmer-eat-meat-only pattern. Hand-curate
  edge cases (fungi, eggs, insects).
- New Papyrus magic effect script on a player-cloak ability: `OnObjectEquipped` →
  `akBaseObject.IsFood()` + `.HasKeyword(...)` → call into the existing
  `HandleBosmerGreenPactViolation` (already -15 compliance / -2.0 Yffre) for plant, or new
  honor-meat handler for honoring meat.
- Spec note: `references/authoring/PDV_Bosmer_OldContract_ContentSpec.md` already documents the
  five FormLists + hybrid FormList-authoritative / keyword-fallback approach.

### Phase C — ESP authoring + CK hook wiring + SEQ (manual gate)
**Operational protocol (CRITICAL — per the prior handoff and confirmed this session):**
1. **Skyrim CLOSED** + `Stop-Process -Name housecarl-mcp -Force`. Do NOT call any housecarl tool
   between the stop and the write (it respawns + re-locks).
2. Run `pdv-phase20-race-author --author-rewards --rewards-spec references/authoring/PDV_{Race}RewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"` per race. Batch races back-to-back in one open window (idempotent + auto-backup).
3. Authoring order (per the deity-roster doc): Imperial + Argonian first → Orc (before Altmer because Altmer reuses Trinimac) → Dunmer / Altmer / Redguard → Nord / Bosmer / Breton (pure reusers) last.
4. For shared deities (Azura ↔ Dunmer, Trinimac ↔ Altmer, Divines ↔ Nord/Breton): `--reconcile-shared-deity` after the owner runs.
5. **Every new `PDV_Deity_*` QUST must have the SGE flag (Flags=17)** — the tool copies it from `PDV_Deity_Kyne`. **Then `node tools/pdv_refresh_seq.mjs --write` after each batch.** Non-skippable: this is how BaanDar shipped broken.
6. Re-verify with housecarl (Devotion Dev profile) — FLST 10 → ~32, all new SPEL/MGEFs present, properties resolve. Confirm property *values* via in-game behavior, not housecarl (VMAD is an opaque overlay).

### Phase D — pace tuning
Validate days-to-tier per race against the locked model (native-track cadence per spec +
active-patron faucet pace for Nord/Imperial/Altmer ~12 days to Devoted vs `PIETY_DAILY_MAX_DELTA=4.3`
/ `GAIN_RATE_SCALE=1.32`). Update `PDV_RaceRewardBudgetLedger.md` + `PDV_PietyPaceBalancingTable.md`.

### Phase E — verification
- `node tools/pdv_verify.mjs --strict-phase20-race-costing --json` → FAIL=0.
- `node tools/pdv_phase20_base_wiring_audit.mjs`, `node tools/pdv_prisma_ui_audit.mjs`, `node tools/pdv_content_verify.mjs`.
- **NEW audit script** `tools/pdv_phase2_reward_readback_audit.mjs` (NOT YET WRITTEN) for: per-race spec-vs-ESP readback (all SPEL exist with correct MGEF actor-values + magnitudes); substrate slots non-empty; FLST membership 32; route entries; **real-hook-mechanism classification** (each act has a real sender, not just a QASmoke shim).
- `pdv_verify.mjs` may need updated "expected data" (the prior handoff says it doesn't know the
  Khajiit-pilot additions; this session's exploration found it reads dynamically — but a strict
  re-run after Phase C will surface any genuine staleness). **Per CLAUDE.md rule 4: explicit user
  OK required before editing `pdv_verify.mjs` / `pdv_compile.mjs` / `pdv_author.mjs`.**

### Phase F — runtime proof (user-only, manual)
Per-race normal-play walk via `PDV_BetaTestPacket_{Race}.md`: accepted hook fires from real
gameplay, rejected hooks silent (≥6 families P0/P1, ≥4 P2), Survey clear, reward SPEL in Active
Effects, stack snapshot, feel note. Records `Pass` verdicts in `PDV_PreBetaRaceGateLedger.md` /
`PDV_Phase20_ManualEvidenceLedger.json`.

---

## 6. Operational gotchas (must heed)

1. **ESP-write lock protocol** (handoff §5 from Phase 1, re-confirmed): Skyrim closed AND housecarl
   stopped; don't call housecarl tools between the stop and the write.
2. **SGE flag + SEQ refresh** — every new `PDV_Deity_*` QUST. The author tool copies SGE from
   `PDV_Deity_Kyne`; `pdv_refresh_seq --write` is the operator's job. Skipping either = the
   BaanDar dead-quest bug.
3. **`PDV__ManagerQuest.psc` is one ~300 KB file** — B2 is strictly serial. Compile per race
   (`pdv_compile --script PDV__ManagerQuest`); a late compile error is expensive to bisect.
4. **CLAUDE.md rule 4**: do NOT edit `pdv_verify.mjs` / `pdv_compile.mjs` / `pdv_author.mjs` (or
   the skill files) without explicit user OK. New checks go in NEW audit scripts.
5. **Author tool is idempotent** but ESP writes still cannot run concurrently — batch.
6. **Binding rules for testing:** `.pex` changes → relaunch + load save; **new VMAD properties or
   new SGE quests → NEW game** (`coc qasmoke` from main menu).
7. **Spec-file conformance** (R2): the manager hard-codes the per-race broad-T1 editorIds —
   `PDV_Bless_<Race>_<Lane>_T1` already declared. Any new T2/Tx records must match. Do not
   invent names; check the spec.
8. **Fallback-as-floor** (Decision 13) is non-optional for capstone MGEFs. Detection-fiddly
   capstones (honorable-kill, surrender, fear immunity, live "strongest-foe" marking, single-foe
   crowd-count, hostile-spell classification) each ship with their robust fallback live; precise
   detection only adds finesse on top.

---

## 7. Reference data (for resumption)

**Ownership map (validated 2026-06-07: 0 collisions, 0 orphans, 22 new deities owned):**
- Altmer owns: Magnus, Xarxes. Reuses Auri-El (existing) + Trinimac (Orc) pressure.
- Argonian owns: Hist, Sithis. Reuses no others.
- Bosmer owns: none. Reuses Yffre, Zen, BaanDar.
- Breton owns: none. Reuses Imperial Divines (KR: Stendarr/Mara/Arkay/Julianos; GW: Kynareth) + Daedric via 20C.
- Dunmer owns: Boethiah, Mephala. Reuses Azura (Khajiit-added).
- Imperial owns: Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth. Reuses Talos.
- Nord owns: Shor, Tsun, Stuhn. Reuses Kyne, Talos + all 8 Divines (Imperial).
- Orc owns: Malacath, Trinimac.
- Redguard owns: Tuwhacca, HoonDing, Leki. Reuses Arkay (infra only).

**SIGNAL_* blocks (collision-free):**
Akatosh 1000-1099 · Mara 1100-1199 · Arkay 1200-1299 · Stendarr 1300-1399 · Zenithar 1400-1499 ·
Dibella 1500-1599 · Julianos 1600-1699 · Kynareth 1700-1799 · Magnus 1800-1899 · Xarxes 1900-1999 ·
Boethiah 2000-2099 · Mephala 2100-2199 · Malacath 2200-2299 · Trinimac 2300-2399 · Tuwhacca 2400-2499 ·
HoonDing 2500-2599 · Leki 2600-2699 · Hist 2700-2799 · Sithis 2800-2899 · Shor 2900-2999 ·
Tsun 3000-3099 · Stuhn 3100-3199.
(Existing deities: Talos 101-103, AuriEl 201-202, Yffre 301-305, Zen 401-403, BaanDar 501-505,
Khenarthi 601-604, Azura/Azurah 701-703, Rajhin 801-803, Alkosh 901-903.)

**Event/route IDs (free ranges in `PDV_EventTypes.psc`):** 160+; gaps 2-9, 11-19, 22-29, 36-39,
54-59, 64-69, 74-79, 84-89, 93-99, 108-119, 124-129, 132-139, 143-149, 153-159.

**DeityIndex:** existing 1 (Talos) / 3 (Yffre) / 4 (Zen) / 5 (BaanDar) + Khajiit 40-43. Use 10-31
sequentially for new deities at ESP-author time (the generalized tool allocates next-available).

**Constants:** `PIETY_DAILY_MAX_DELTA=4.3`, `GAIN_RATE_SCALE=1.32`, tiers 25/50/85, focus
threshold 50 / lead 15, emphasis pulse ~+1.0 (Argonian Hist) or 0.3-0.5 (Khajiit), substrate
diminishing 0.7^n.

---

## 8. Open items / cleanup

- **You owe the user a manifest review** (Decision 3): the 4 drafted P2 manifests
  (Breton/Dunmer/Imperial/Nord) — surface them for sign-off before Phase C ESP authoring.
- **`pdv_verify` expected-data**: the prior handoff says it's stale re: the 4 new Khajiit deities
  / 18 spells. This session's exploration found it appears to read dynamically. Resolve at Phase E;
  if it truly needs editing, get explicit OK first (rule 4).
- **Stale spawned-task chip from the prior session** ("Fix PDV_Deity_BaanDar…") — the work is done;
  user should dismiss manually.
- **MCM `(+-2.5)` cosmetic fix** for negative scratch column — fold into the next manager compile.
- **R2/R5 cosmetic smoke** (Khajiit-pilot leftovers from the prior session) still on the punch list:
  daily-cap ceiling and 3-day-neglect smoke.
- **Documentation sync** — consider running the `pdv-doc-sync` skill at session end to propagate
  Phase 2 status into `AGENTS.md` / `PDV_Architecture_v3.md` / `PDV_TargetEndStates_1.0.md`. Per
  CLAUDE.md, `AGENTS.md` should be updated only on explicit user ask.

---

## 9. One-paragraph resume

Phase A (design) is complete and validated: a generalized records-author tool, 9 reward specs, 4 new
costing manifests, and a binding rulings + master deity roster + capstone-signature spec, all
locked under user-decided design rails (native-track-as-parity piety model, two-tier magnitude
ceiling, shared Divines as one record per god keyed by per-race stance, signatures at T3 capstone
only, every save once/day with ≤1 per race, fallback-as-floor for all fiddly detections). B1
(deity scripts) is complete: all 22 new `PDV_Deity_*.psc` compile clean. B2 (manager wiring) has
the **Argonian substrate pilot landed and compiling 0/0** — double-routed handlers, new
`SyncArgonianRewards`/`SyncArgonianNeglectSpell`, no-offer special-case integrated. The remaining
B2 work is per-race wiring (one race at a time on the serial 300 KB manager file), following the
Bosmer/Yffre + Khajiit/Argonian templates and the noted civic-act-discriminator gap for Imperial.
After B2: capstone-signature MGEFs (fallback-as-floor binding), the Bosmer Green Pact tag layer
(Biggie's Traits + Requiem FBR are the references), B3 real-hook landing, then the user-gated ESP
authoring window (Skyrim closed + housecarl stopped + SEQ refresh), pace tuning, static verify,
and the user's manual runtime walk per race.
