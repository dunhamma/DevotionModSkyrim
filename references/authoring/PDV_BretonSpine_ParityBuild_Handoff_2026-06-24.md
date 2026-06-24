# Breton Ancestral-Spine Parity Build (Codex Handoff, 2026-06-24)

## Why / status
Spine Stack Score **Breton 36.7%** — parity target, **not yet built**. Copy
`PDV_Substrate_NordAncestor.psc` as the proven template.

## Pulse deity — OWNER PICK (default set, override before build)
- **Default: `PDV_Deity_Magnus`** (Breton magic-heritage ancestry — Bretons are part-Aldmeri,
  magic-attuned; Magnus is the magic-progenitor).
- **Override:** a Green-Way deity (if the druidic line should own the ancestral pulse) or Mara.
- (Owner: confirm or override; build proceeds on Magnus otherwise.)

## Build (common two-ledger pattern)
1. **Unconditional band-keyed boon** on the Breton tradition framework (Green Way / Hidden Art /
   Vow), WITHOUT the patron gate. **Boon theme:** the **iconic Breton MagicResist** (band-keyed,
   atop the racial resistance) — lore-perfect and felt. Always/Mid/High; band spells ->
   `Devotion.esp` (serialize). Magnitude flag.
   - NOTE the Breton tradition path already has the Green Way *standing* channel — confirm the
     unconditional boon is independent of the tradition CHOICE (fires for any Breton, pre-choice),
     not gated behind a committed tradition.
2. **Spine pulse** to the chosen deity (Magnus default): `SIGNAL_ANCESTOR_SPINE` define+handle
   (mirror `PDV_Deity_Tuwhacca`) + double-route from Breton spine acts.

## Cross-links
- **6e renewable channel:** Breton has the Green Way standing channel but no sleep/prayer/home
  ancestral channel; add one (sleep/dream) for the `renewable` dim.

## ⚠️ Serialize (manager/ESP). Verify
`pdv_compile` (deity + substrate + manager) 0/0 -> `pdv_verify` FAIL=0 -> `pdv_signal_e2e_gate`
0 RED + parity PASS -> update `PDV_SpineStackRegistry.csv` Breton row -> `pdv_spine_stack_score.mjs`
shows Breton climb out of <70%.
