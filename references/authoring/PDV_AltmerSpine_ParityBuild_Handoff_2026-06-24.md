# Altmer Ancestral-Spine Parity Build (Codex Handoff, 2026-06-24)

## Why / status
Spine Stack Score **Altmer 30%** — parity target, **not yet built**. Pattern is proven on Nord,
Dunmer, Orc — **copy `PDV_Substrate_NordAncestor.psc` as the template.**

## Build (the common two-ledger pattern)
1. **Unconditional band-keyed boon** on the Altmer track (`PDV_ThalmorAlignmentTrack` +
   `PDV_AltmerCrisisTrack`), applied WITHOUT the patron gate (carve out like the Nord/Dunmer
   substrates; the smoking gun is `PDV__ManagerQuest.psc:8574-8586`).
   - **Boon theme:** Aldmeri heritage — **+Magicka / magicka affinity** (Altmer are magicka-rich),
     band-keyed Always/Mid/High. Flat / Requiem-proof where relevant. Magnitude flag for owner.
   - Band spells -> `Devotion.esp` (Mutagen, serialize the write).
2. **Spine pulse to `PDV_Deity_AuriEl`** (the Aldmeri progenitor — unambiguous, no flag): add
   `Int Property SIGNAL_ANCESTOR_SPINE = <next free> AutoReadOnly` + `Float DELTA_ANCESTOR_SPINE = 1.0`
   + a `ScoreCuratedSignal` branch (mirror `PDV_Deity_Tuwhacca`), double-routed from Altmer spine
   acts via `AwardCuratedSignalScaled(PDV_AuriEl, ...)` with `ConsumeDailyRepeatMultiplier`.

## Cross-links (do in the same pass)
- **6f variety tranche:** Altmer's variety tranche is blocked "Pending" in
  `references/authoring/PDV_RaceEffectReviewLedger.md`; its "substrate baseline / broad lane"
  floor IS this build's unconditional boon — same work, one pass.
- **6g Book-of-Days bespoke voice:** Imperial/Altmer are on the generic fallback — give Altmer
  bespoke ancestor-layer Book-of-Days lines.
- **6e renewable channel:** Altmer has no sleep/prayer/home channel; add one (sleep/dream) so the
  Score's `renewable` dim isn't left at 0.

## ⚠️ Serialize (manager/ESP). Verify
`pdv_compile` (PDV_Deity_AuriEl + substrate + manager) 0/0 -> `pdv_verify` FAIL=0 ->
`pdv_signal_e2e_gate` 0 RED + parity PASS (new Auri-El signal) -> update
`PDV_SpineStackRegistry.csv` Altmer row -> `pdv_spine_stack_score.mjs` shows Altmer climb out of <70%.
