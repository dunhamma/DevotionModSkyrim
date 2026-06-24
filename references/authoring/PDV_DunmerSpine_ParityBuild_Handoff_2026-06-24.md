# Dunmer Ancestral-Spine Parity Build (Codex Handoff, 2026-06-24)

## Why Dunmer (the cheapest MODERATE target)
Spine Stack Score **Dunmer 63.3%** (strongest MODERATE). Unlike the others it **already has
`PDV_Substrate_DunmerAncestor`** (extends `PDV_SubstrateBase`): a real metric, substrate tiers,
AND `PrayerDelta`/`HomeBonusDelta` prayer+home maintenance channels (so Dunmer is already strong
on the Score's `renewable` dim — most MODERATE races aren't). Its two gaps:
1. The unconditional boon is **one tier** (audit: `ResistMagic +3/+9/+20`, single band).
2. **No spine-owned pulse** — `PDV_Substrate_DunmerAncestor` has no `AwardCuratedSignal` call,
   so spine acts don't feed a universal-piety sink pre-patron (gap #2).

## ⚠️ SERIALIZE — runs AFTER Nord
Touches `PDV_Substrate_DunmerAncestor.psc`, `PDV__ManagerQuest.psc`, a deity script, and
`Devotion.esp` (upper-tier boon spells). Overlaps the Nord build's manager + ESP — **do Dunmer
after Nord lands + commits**. Not parallel-safe with Nord or with any other in-flight
`Devotion.esp` writer.

## Build

### 1. Upper boon tiers (the cheap half)
- The substrate already tiers via `PDV_SubstrateBase` (`GetSubstrateTier`). Add the **Mid/High**
  boon bands the single-tier boon is missing — mirror `PDV_Substrate_ArgonianHist`'s
  Always/Mid/High banding and the Dunmer magnitude scale (`ResistMagic +3/+9/+20` → keep that
  scale; the upper tiers are the +9/+20 bands keyed to higher metric thresholds, unconditional).
- New band spells go in `Devotion.esp` (Mutagen, serialize the write).

### 2. Spine-owned pulse (the two-ledger second ledger)
- **Pulse target = `PDV_Deity_Azura`** (lead Reclamation, dawn/guidance — the most "default
  ancestral" Dunmer deity). **DESIGN FLAG for owner:** Azura vs `PDV_Deity_Mephala` (ancestral
  lineage/secrets) vs distributing across the three Reclamations. Recommend Azura; confirm.
- On `PDV_Deity_Azura.psc`: add `Int Property SIGNAL_ANCESTOR_SPINE = <next free> AutoReadOnly`
  + `Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto` + a `ScoreCuratedSignal` branch — **mirror
  the Redguard `PDV_Deity_Tuwhacca` pulse landed this session.**
- Double-route every Dunmer spine act (the substrate's metric-input path, e.g. the prayer/home
  records + any ancestor act) to ALSO call
  `AwardCuratedSignalScaled(PDV_Azura, PDV_Azura.SIGNAL_ANCESTOR_SPINE, None, multiplier)` with
  the existing `ConsumeDailyRepeatMultiplier` anti-farm.
- Curated-parity gate enforces Azura DEFINE+HANDLE the new signal.

### 3. Minuses (open-item 6c) + diegetic
- Dunmer-adjacent unemitted minus in `PDV_SpeccedMinusLedger.md`: **none on a Dunmer-specific
  deity** (the Reclamations: Boethiah `SIGNAL_TREACHERY −3`, Mephala `SIGNAL_SECRET_BETRAYED −3`
  are unemitted but are Daedric-path scope) — triage with the Daedric pass, not here.

## Verify
- `node tools/pdv_compile.mjs --script PDV_Substrate_DunmerAncestor` / `--script PDV_Deity_Azura`
  / `--script PDV__ManagerQuest` → 0/0; `pdv_verify` → FAIL=0.
- `node tools/pdv_signal_e2e_gate.mjs` → 0 RED + parity passes the new Azura signal.
- Update `PDV_SpineStackRegistry.csv` Dunmer row (boon_floor 2→3, piety_sink 2→3) →
  `node tools/pdv_spine_stack_score.mjs` → Dunmer climbs out of the <70% band.
