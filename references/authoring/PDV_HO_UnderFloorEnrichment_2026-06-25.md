# HO_UnderFloorEnrichment — close the 23 under-floor paths (Codex Handoff, 2026-06-25)

**Queue A1 (dispatch-first, serialized on `PDV__ManagerQuest.psc`).** Full per-path design spec:
Workflow `w9ywkug8q` output (this session). This handoff carries the canonical recipe + roster;
read the Workflow output for any per-path specifics you want.

## Goal
Bring the **23 under-floor race-paths** to floor (min 5 source TYPES + min 2 RENEWABLE per path).
`node tools/pdv_signal_floor_audit.mjs` → the UNDER-FLOOR roster. The dominant shortfall is **+1
RENEWABLE** (21/23 sit at renew 1/2); a few also need +1-2 types.

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

## ⚠️ Serialize on the manager. Verify (standing cadence)
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → `pdv_signal_e2e_gate` 0 RED + parity PASS →
`pdv_signal_floor_audit` (UNDER-FLOOR count drops toward 0) → `pdv_integrity_harness` PASS.
**Verify-current-state first** — grep before authoring (Orc 6f, 6c-Tu'whacca, all of 6d were found
already-built this session). New-save proof of each renewable firing is play-gated (owner).
