# HO_UnderFloorEnrichment — close the 23 under-floor paths (Codex Handoff, 2026-06-25)

**Queue A1 (dispatch-first, serialized on `PDV__ManagerQuest.psc`).** This handoff is SELF-CONTAINED:
the canonical recipe + a per-path checklist are inline below — author all 22 remaining paths in ONE
batch, no Workflow-output lookup needed (deeper per-path spec, if ever wanted: Workflow `w9ywkug8q`).

## ⚡ EXECUTION MODE — ONE continuous batch (do NOT stop after each path)
**This is a single 23-path deliverable, not 23 deliverables.** Author the renewable channel for
EVERY remaining path in the checklist below in one continuous pass. Do **NOT** stop, hand back,
checkpoint, or run the full gate cadence after each path — that is what stalled it after
`altmer_magnus`.
- **Verify per RACE-CLUSTER, not per path:** finish a whole cluster (e.g. all 4 Bosmer), then run
  `pdv_compile --script PDV__ManagerQuest` (0/0) once. Run the full cadence (`pdv_verify` →
  `pdv_signal_e2e_gate` → `pdv_signal_floor_audit` → `pdv_integrity_harness`) **once at the very end**
  (and optionally once mid-way), NOT 22 times.
- **One commit at the end** (or one per cluster) — not one per path.
- **Hand back ONCE**, when the floor audit shows all 23 paths PASS (UNDER-FLOOR → 0), with the final
  cadence green. Only stop early if you hit a genuine blocker (compile error you can't resolve, or a
  path with no clean theme-fit hook) — name it and continue with the rest.
- Keep using the `PDV_SignalFloorDirectRenewables.csv` code-evidence registry you established for
  `altmer_magnus` — add a row per path as you go (it's how the audit credits the direct-manager
  renewable type).

## SAVE-SAFE (REQUIRED — owner preference, confirmed achievable)
This batch MUST apply to an EXISTING save (no new game). It is save-safe BY CONSTRUCTION if you keep
the recipe shape — `altmer_magnus` already is:
- **New StorageUtil keys** (day-keys, counts) default to 0/empty on an existing save — inherently safe.
- **New `Handle<Race><Signal>` functions** load with the recompiled `.pex` and fire on existing saves.
- **Reuse EXISTING manager properties** (substrate/track/deity already declared) + `AwardCuratedSignalScaled`.
- **Do NOT add a new VMAD/`Auto` property** for a renewable channel — a new property is `None` on an
  existing save. If a new FORM is genuinely needed (e.g. a location FormList), resolve it with
  `Game.GetFormFromFile(...)` (cached at init, the Survival/CC pattern ~8865) OR fold it into the
  version-gated migration (`FRAMEWORK_SCHEMA_VERSION` 469 / the re-run guard ~7139), never a raw Auto property.

## Goal
Bring the **23 under-floor race-paths** to floor (min 5 source TYPES + min 2 RENEWABLE per path).
`node tools/pdv_signal_floor_audit.mjs` → the UNDER-FLOOR roster. The dominant shortfall is **+1
RENEWABLE** (21/23 sit at renew 1/2); a few also need +1-2 types.

## Kickoff progress (2026-06-24 AEST)
First narrow enrichment landed for `altmer_magnus`: active Magnus now gets a daily sleep-dream
renewable through `HandleAltmerSleepEvents`, gated by the existing `PDV.Signal.AltmerAncestralDream`
anti-farm cap and routed through the existing dawn scholarship helper. The floor audit now counts this
only through `PDV_SignalFloorDirectRenewables.csv`, which requires code evidence for the manager
function, guard, anti-farm gate, hook seam, and sink before granting the direct-manager renewable type.

Current verified baseline after kickoff:
- `pdv_compile --script PDV__ManagerQuest`: 0 errors / 0 warnings; verifier `FAIL=0`
- `pdv_signal_e2e_gate`: PASS, 39 GREEN / 0 RED, curated parity PASS
- `pdv_signal_floor_audit`: 29 PASS / 22 UNDER-FLOOR; `altmer_magnus` is PASS at 6/5 types and 2/2 renewable
- `pdv_integrity_harness`: PASS

## Canonical +1-renewable recipe (MIRROR the 6e channels / near-water faucet)
For each path, add ONE renewable env/behavioural channel:
1. **Pick a renewable type the path lacks** — renewable types = `day-to-day` / `faucet` / `weather`
   / `harvest` (env-behavioural: sleep, location-cadence, moon/world-state poll). One-shot types
   (book/quest-stage/quest-reaction/spell-learned) do NOT count toward renewable.
2. **Add a manager `Handle<Race><Signal>(reason)`** gated on `GetPlayerOriginRaceIndex()==ORIGIN_*`
   AND the substrate/track property non-null.
3. **Anti-farm (NEVER raw):** wrap the magnitude in `ConsumeDailyRepeatMultiplier("PDV.Signal.<X>")`
   (soft 0.7^n) OR gate firing with `ConsumeOncePerDaySignal("PDV.Signal.<X>")` (hard once/dawn).
   For a poll-faucet gating on its OWN day-key, encode `day+1` before the world probe (StorageUtil
   int zero-default self-suppresses on day 0 — see `TryArgonianNearWaterMaintenance` ~3553).
4. **DOUBLE-ROUTE (load-bearing for substrate-led paths):** substrate `Record<X>Scaled(mult,reason)`
   (identity/tier) **+** `AwardCuratedSignalScaled(<pathDeity>, SIGNAL_*, None, mult)` (piety) so
   decay/neglect stay honest.
5. **Hook the trigger at the right seam:** sleep → manager per-race sleep dispatch (~2978);
   location → `PDV_ActionRouter.HandleStoryChangeLocation` every-change block (~238, **but `coc`
   skips OnStoryChangeLocation** — use a 1s-tick poll anchor for coc-immunity, Eldergleam-style); a
   world-state poll → manager 1s `OnUpdate` alongside `TryArgonianNearWaterMaintenance`.
6. **Any populated quest-stage source** must observe the gated-curation contract (approved-for-fill
   + approvedStages + houseCARL stageReadbackEvidence + rejectedStageContext + duplicateGuard) — the
   fill tool refuses unapproved entries.

## Per-cluster targets (theme-fit, no generic combat / raw loops)
- **Argonian** (`argonian_people` +3t/+1r, `argonian_hist` +2t/+1r, `argonian_void` +2t/+1r) —
  **NO quest-reaction for hist/people** (Hist has 0 matrix cells, by design — see
  `PDV_ArgonianHistQuestReaction_Decision_2026-06-25.md`). Add a SECOND env-behavioural channel each
  (marsh-weather / rooted-sleep / harvest), routed like `TryArgonianNearWaterMaintenance` with its
  own day-key + cap.
- **Bosmer** (bandit_road/exchange +2t/+1r, living_story/old_contract +1t/+1r) — location/Songs-of-
  the-Green env + a path-coded renewable (Y'ffre/Green Pact — **no plant-harvest**).
- **Khajiit** (alkosh/baandar/khenarthi/rajhin +2t/+1r; azurah/lunar +1t, renew OK) — moon-phase +
  road-home circuit env (poll-faucet pattern, coc-immune).
- **Altmer** (auriel/xarxes +1t/+1r; magnus +1r) — dawn-practice / sleep-dream renewable.
- **Imperial** (private_talos/public_talos +1t/+1r) — civic-rite / shrine-cadence renewable
  (public vs private framing).
- **Redguard** (ashabah/crown/forebear +1t/+1r) — sword-tending / Halls / road-passage per sect.
- **Misc** — `breton_hidden_art` +1r (Hidden Art exposure cadence), `dunmer_deviation` +1r
  (deviation-price recurring).

## Per-path checklist (23 total — work top-to-bottom, check off as you go)
`(+Nt/+Mr)` = needs +N source types / +M renewable. Most are just **+1 renewable**; the marked ones
also need +types (add a book or an approved quest-stage source alongside the renewable channel).
- [x] **altmer_magnus** — sleep-dream → Auri-El/Magnus (DONE, the kickoff)
- [ ] **argonian_hist** (+2t/+1r) — 2nd env channel (marsh-weather OR rooted-sleep) → Hist substrate; mirror `TryArgonianNearWaterMaintenance`, own day-key. NO quest-reaction.
- [ ] **argonian_people** (+3t/+1r) — community/rooted-sleep env → People→Hist substrate. NO quest-reaction. Needs the most types.
- [ ] **argonian_void** (+2t/+1r) — Void-acknowledgment env → Sithis.
- [ ] **bosmer_old_contract** (+1t/+1r) — Songs-of-the-Green location env → Y'ffre/path (no plant-harvest).
- [ ] **bosmer_living_story** (+1t/+1r) — location env → path.
- [ ] **bosmer_bandit_road** (+2t/+1r) — road location env → Baan Dar.
- [ ] **bosmer_exchange** (+2t/+1r) — trade-location env → Z'en.
- [ ] **khajiit_alkosh** (+2t/+1r) — moon-phase poll-faucet → Alkosh (coc-immune).
- [ ] **khajiit_baandar** (+2t/+1r) — road-home circuit → Baan Dar.
- [ ] **khajiit_khenarthi** (+2t/+1r) — road/wind env → Khenarthi.
- [ ] **khajiit_rajhin** (+2t/+1r) — night/shadow env → Rajhin.
- [ ] **khajiit_azurah** (+1t, renew OK) — **+1 type only** → Azurah (no renewable needed).
- [ ] **khajiit_lunar** (+1t, renew OK) — **+1 type only** → lunar substrate.
- [ ] **altmer_auriel** (+1t/+1r) — dawn-practice renewable → Auri-El.
- [ ] **altmer_xarxes** (+1t/+1r) — record/study env → Xarxes.
- [ ] **imperial_private_talos** (+1t/+1r) — private shrine-cadence → Talos.
- [ ] **imperial_public_talos** (+1t/+1r) — civic-rite cadence → Talos.
- [ ] **redguard_crown** (+1t/+1r) — Halls-of-the-Dead / sword-tending → Crown/Tu'whacca.
- [ ] **redguard_forebear** (+1t/+1r) — sword-tending Leki → Forebear.
- [ ] **redguard_ashabah** (+1t/+1r) — road-passage / death-duty cadence → Ash'abah/Tu'whacca.
- [ ] **breton_hidden_art** (+1r) — Hidden Art exposure cadence renewable.
- [ ] **dunmer_deviation** (+1r) — deviation-price recurring renewable.

**Standing rule (owner 2026-06-25):** each new renewable signal must record a driver
(`PDV.Driver.Reasons`/`PDV.Driver.Deltas` on its target deity form, the way `AwardPiety` does) so it
lands in the in-game Ledger ("what feeds your gods"). The double-route's `AwardCuratedSignalScaled`
path already does this — just don't bypass it with a raw StorageUtil piety write.

## ⚠️ Serialize on the manager. Verify (standing cadence)
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → `pdv_signal_e2e_gate` 0 RED + parity PASS →
`pdv_signal_floor_audit` (UNDER-FLOOR count drops toward 0) → `pdv_integrity_harness` PASS.
**Verify-current-state first** — grep before authoring (Orc 6f, 6c-Tu'whacca, all of 6d were found
already-built this session). New-save proof of each renewable firing is play-gated (owner).
