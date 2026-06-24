# MODERATE-Race Ancestral-Spine Parity Build — remaining 4 (Codex Handoff, 2026-06-24)

Covers the patron-gated MODERATE targets that aren't already handed off:
**Altmer 30% · Imperial 30% · Breton 36.7% · Orc 36.7%.** (Nord and Dunmer have their own
handoffs; Redguard's spine pulse already landed.) **Do these one at a time, AFTER Nord proves
the pattern and after Dunmer** — all serialize (shared `PDV__ManagerQuest.psc` + `Devotion.esp`).

## Common pattern (identical to Nord; the only per-race variance is in the table)
Each MODERATE race has a reputation/state/framework track but **no substrate**, so its T1 floor
is patron-gated (`PDV__ManagerQuest.psc:8574-8586`). Per the Argonian two-ledger template:
1. **Unconditional band-keyed boon** — a cultural boon keyed to the race's EXISTING track
   band/state, applied **without the patron gate** (carve it out like Argonian Hist_T1 at
   `:8577-8578`; mirror `PDV_Substrate_NordAncestor` once Nord lands). Author flat /
   Requiem-proof effects (no regen-rate).
2. **Spine-owned pulse** — `Int Property SIGNAL_ANCESTOR_SPINE` + `Float DELTA_ANCESTOR_SPINE = 1.0`
   + `ScoreCuratedSignal` branch on the race's ancestral deity (mirror `PDV_Deity_Tuwhacca`),
   double-routed from the race's spine acts with `ConsumeDailyRepeatMultiplier` anti-farm.
3. Re-run `pdv_signal_e2e_gate.mjs` (0 RED + parity passes the new signal) and
   `pdv_spine_stack_score.mjs` (race climbs out of <70%).

## Per-race table
| Race | Existing track | Spine pulse deity | Recommended boon theme (band-keyed, unconditional) | Design flags |
|---|---|---|---|---|
| **Orc** | `PDV_OrcLifeModeTrack` (StateTrack) | `PDV_Deity_Malacath` | Orsimer toughness — `DamageResist` (armor-points, exempt from the ~12 ceiling) + flat Health | Also dispatch the **dead Orc notifs** (Watchers×3, HearthHeld×3 — `PDV_SpeccedMinusLedger`/Score 6b) here |
| **Altmer** | `PDV_ThalmorAlignmentTrack` + `PDV_AltmerCrisisTrack` | `PDV_Deity_AuriEl` (Aldmeri progenitor — clean) | Aldmeri heritage — +Magicka / magicka affinity | Variety tranche is effect-review "Pending" in `PDV_RaceEffectReviewLedger.md` — **do together** (6f); Magnus minuses (ARTS_PROFANED/KNOWLEDGE_DESTROYED) triage with the pantheon-minus pass |
| **Breton** | tradition framework (Green Way / Hidden Art / Vow) | **FLAG:** `PDV_Deity_Magnus` (magic heritage) vs a Green-Way deity vs Mara | Iconic **MagicResist** (band-keyed, atop the racial) — lore-perfect | Pulse-target decision needed before build |
| **Imperial** | `PDV_ConcordatStandingTrack` (ReputationTrack) | **FLAG:** `PDV_Deity_Akatosh` (chief of the Nine) vs Talos | Imperial discipline — modest all-round (flat Health/Stamina) or Voice-of-the-Emperor-adjacent | No single ancestor-god → pulse-target decision needed; also **6g Book-of-Days bespoke voice** (Imperial on generic fallback) |

## Notes / cross-links
- **6e renewable channels:** none of these 4 has the prayer/home/sleep channel Dunmer/Argonian
  have; the Score's `renewable` dim stays low on a boon+pulse-ONLY build. Add at least one
  renewable maintenance channel per race (sleep/dream or prayer/home) — flag as each race's
  follow-on, don't silently skip.
- **6f variety tranche (Altmer/Orc + Redguard):** the EffectReviewLedger "substrate baseline /
  broad lane" floor IS this build's unconditional boon — same work, do it in one pass per race.
- **6c minuses:** wire/triage each race's deity minuses from `PDV_SpeccedMinusLedger.md` as part
  of its spine build (the per-race ones); the cross-race pantheon-creed minuses are a separate pass.

## Verify (per race)
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → `pdv_signal_e2e_gate` 0 RED + parity → update that
race's `PDV_SpineStackRegistry.csv` row → `pdv_spine_stack_score.mjs` shows it climb.
