# Redguard Spine — Boon Half (Codex Handoff, 2026-06-24)

## Why
Spine Stack Score **Redguard 53.3%** — still a parity target. Its **spine pulse already landed**
(`PDV_Deity_Tuwhacca` `SIGNAL_ANCESTOR_SPINE`, double-routed from `HandleRedguardAncestorSpine`),
so `piety_sink` is partly done. What's missing is the **unconditional band-keyed boon**
(`boon_floor` is 2, not 3) — Redguard has no always-active ancestral boon independent of patron.

## Scope = the BOON HALF only (pulse is done, do NOT re-do it)
Add the unconditional band-keyed boon on Redguard's existing **sect track**
(`PDV_RedguardSectTrack` — Crown/Forebear/Ash'abah), applied WITHOUT the patron gate, exactly
like the Nord/Dunmer substrates just shipped (`PDV_Substrate_NordAncestor` is the proven
template; copy its shape).

- **Boon theme (Yokudan hardiness / the ancestor-line):** recommend a **flat Health + a small
  weapon/precision boon** (Yokudan sword-saints) — flat / Requiem-proof (no regen-rate). Tiers
  Always/Mid/High keyed to the sect-track band, unconditional. **Magnitude flag for owner.**
- New band spells go in `Devotion.esp` (Mutagen) — serialize the ESP write with other writers.
- The double-route pulse to Tu'whacca already exists; the boon just reads the same metric/band.

## Also (cheap, while here)
- **6c minus:** wire `PDV_Deity_Tuwhacca` `SIGNAL_DEATH_DUTY_ABANDONMENT` (−3) on the death-duty
  abandonment act (the per-race minus the triage decision says to wire, not remove).

## ⚠️ Serialize
Touches `PDV__ManagerQuest.psc` + `Devotion.esp` → serialize with the other spine builds.

## Verify
- `pdv_compile` (substrate/manager) 0/0; `pdv_verify` FAIL=0; `pdv_signal_e2e_gate` 0 RED + parity PASS.
- Update `PDV_SpineStackRegistry.csv` Redguard row (boon_floor 2→3, minus_stack →2 once the
  abandonment minus is wired) → `pdv_spine_stack_score.mjs` → Redguard climbs out of <70%.
