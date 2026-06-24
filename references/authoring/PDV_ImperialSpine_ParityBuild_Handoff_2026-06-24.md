# Imperial Ancestral-Spine Parity Build (Codex Handoff, 2026-06-24)

## Why / status
Spine Stack Score **Imperial 30%** — parity target, **not yet built**. Copy
`PDV_Substrate_NordAncestor.psc` as the proven template.

## Pulse deity — OWNER PICK (default set, override before build)
- **Default: `PDV_Deity_Talos`.** The Imperial spine track IS the Concordat (which suppresses
  Talos), so a Talos pulse beneath it = the lore-resonant "old faith in the deified ancestor-hero,
  under the political peace." Talos is the deified Imperial ancestor.
- **Override: `PDV_Deity_Akatosh`** if you want it politically neutral (chief of the Nine).
- (Both deity scripts exist. Owner: confirm or override; build proceeds on Talos otherwise.)

## Build (common two-ledger pattern)
1. **Unconditional band-keyed boon** on `PDV_ConcordatStandingTrack` (ReputationTrack), WITHOUT the
   patron gate. **Boon theme:** Imperial discipline / the Eight's steadiness — a modest all-round
   **flat Health + Stamina** (or Voice-of-the-Emperor-adjacent), band-keyed Always/Mid/High,
   Requiem-proof. Magnitude flag. Band spells -> `Devotion.esp` (serialize the write).
2. **Spine pulse** to the chosen deity (Talos default): `SIGNAL_ANCESTOR_SPINE` define+handle
   (mirror `PDV_Deity_Tuwhacca`) + double-route from Imperial spine acts.

## Cross-links
- **6g Book-of-Days bespoke voice:** Imperial is on the generic fallback — give it bespoke
  ancestor-layer lines (this is one of the two named in gap #8).
- **6e renewable channel:** Imperial has no sleep/prayer/home channel; add one.

## ⚠️ Serialize (manager/ESP). Verify
`pdv_compile` (deity + substrate + manager) 0/0 -> `pdv_verify` FAIL=0 -> `pdv_signal_e2e_gate`
0 RED + parity PASS -> update `PDV_SpineStackRegistry.csv` Imperial row -> `pdv_spine_stack_score.mjs`
shows Imperial climb out of <70%.
