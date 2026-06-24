# Nord Ancestral-Spine Parity Build (Codex Handoff, 2026-06-24)

## Why Nord first
Spine Stack Score worst: **Nord 20%** (THIN — no substrate, acts route to an inactive Shor
ledger, no spine-owned pulse, dead diegetic). Building Nord proves the **band-keyed-boon +
spine-pulse pattern** that the other 6 MODERATE targets reuse. Re-run
`node tools/pdv_spine_stack_score.mjs` after to confirm Nord climbs out of the <70% band.

## ⚠️ SERIALIZE — not parallel-safe
Codex is mid-flight editing `PDV_PlayerEvents.psc` (Eldergleam + prince faucets), the P2
manifest, and `Devotion.esp`. **This build also touches `PDV__ManagerQuest.psc`,
`PDV_Deity_Shor.psc`, `Devotion.esp` (new boon spell/MGEF), and a new substrate script** —
overlapping the manager + ESP. **Do this AFTER the current Green Way 5/5 + prince-floor slice
lands and is committed.** Do not run it concurrently.

## Design (mirror the Argonian two-ledger template; copy mechanics from the cheapest substrate)

### 1. Unconditional band-keyed boon — NEW `PDV_Substrate_NordAncestor.psc`
- **Mirror `PDV_Substrate_DunmerAncestor.psc`** (extends `PDV_SubstrateBase`; the cheapest
  working substrate). It applies the boon on metric+origin with **NO patron gate** — that is
  the whole point (the audit's smoking gun is `PDV__ManagerQuest.psc:8574-8586`, where every
  T1 floor gates on `IsFirstTierRaceRewardEligible() || IsBroadFloorEligible()` EXCEPT the
  Argonian substrate carve-out at `:8577-8578`).
- **Nord theme = ancestral hardiness** (cold-hardy Sons/Daughters of Skyrim). Boon effect,
  band-keyed Always/Mid/High, applied unconditionally:
  - **FrostResist +5 / +15 / +30** (Nord cold-hardiness), AND
  - **flat Health +10 / +25 / +50** — author as a **flat Restore/Value-mod on Health, NOT a
    regen-rate** (Requiem drives regen to ~0; see the Requiem-proof-heal rule).
  - Magnitudes mirror the Dunmer scale (`ResistMagic +3/+9/+20`); tune in review.

### 2. A spine-owned metric (the "always-on ledger")
- Add a Nord ancestral metric (StorageUtil-backed, e.g. `PDV.Nord.AncestralStanding`) that
  the substrate reads for its band — mirror the Dunmer substrate's metric handling. Decay
  −1/dawn after a grace window, floor 20, posture enum (e.g. Forgotten/Remembered/Honored).
- It can read/extend the existing `PDV_NordPantheonBaselineTrack` (a 2-state `PDV_StateTrack`,
  manager line ~90) rather than inventing a parallel track — confirm and reuse.

### 3. Spine-owned honest pulse to Shor (the SECOND ledger)
- `PDV_Deity_Shor.psc` (exists): add `Int Property SIGNAL_ANCESTOR_SPINE = <next free> AutoReadOnly`
  + `Float Property DELTA_ANCESTOR_SPINE = 1.0 Auto` + a `ScoreCuratedSignal` branch —
  **exactly mirroring the Redguard `PDV_Deity_Tuwhacca` pulse landed this session.**
- Add `HandleNordAncestorSpine(String reason)` in `PDV__ManagerQuest.psc` that **double-routes**
  every Nord spine act: bump the metric (§2) AND
  `AwardCuratedSignalScaled(PDV_Shor, PDV_Shor.SIGNAL_ANCESTOR_SPINE, None, multiplier)` with
  a `ConsumeDailyRepeatMultiplier` anti-farm. This closes gap #2 (acts no longer vanish into an
  inactive patron ledger pre-commitment).
- **Curated-parity gate enforces define+handle** — Shor must DEFINE and HANDLE the new signal
  or `pdv_signal_e2e_gate.mjs` flags it (the Kyne silent-zero class).

### 4. Dispatch the dead diegetic (Score 6b)
- `PDV_Notif_Nord_General_AncestorsQuiet` (manager line 442) and
  `PDV_Notif_Nord_Kyne_ChampionAmbient_Storm` (443) are declared `Message` properties with
  **zero dispatch sites**. Wire them: AncestorsQuiet on metric neglect/decay to the lowest
  posture; ChampionAmbient_Storm on the Kyne champion ambient beat. (Or, if a beat has no home,
  delete the declaration — dispatch-or-delete.)

## Design decisions flagged for owner review
- Boon = **FrostResist + flat Health** (vs an alternative Nord boon e.g. stagger-resist / carry).
- Pulse target = **Shor** (ancestral underking of Sovngarde) vs Kyne/Talos.
- Metric = **new substrate metric reading PantheonBaselineTrack** vs a standalone track.

## Out of scope here (separate sub-items, per open-item #6)
- **6e renewable channel** (Nord sleep/dream maintenance) — the Score's `renewable` dim; a
  boon+pulse-only build leaves Nord short on dim 4. Flag as the Nord follow-on.
- **6c specced minuses**, **6d per-culture LD category** — later passes.

## ESP coordination
The band-keyed boon needs spell/MGEF records in `Devotion.esp` (in-place Mutagen write) —
**serialize** with any other `Devotion.esp` writer (Claude source-fills, prince faucets). Back
up before the write.

## Verify
- `node tools/pdv_compile.mjs --script PDV_Substrate_NordAncestor` / `--script PDV_Deity_Shor`
  / `--script PDV__ManagerQuest` → 0/0; `node tools/pdv_verify.mjs` → FAIL=0.
- `node tools/pdv_signal_e2e_gate.mjs` → still 0 RED + parity passes the new Shor signal.
- Update `PDV_SpineStackRegistry.csv` Nord row to the as-built dim scores, then
  `node tools/pdv_spine_stack_score.mjs` → Nord climbs (boon_floor 0→2-3, piety_sink 1→2,
  diegetic 1→2-3); re-confirm the deterministic diegetic check shows the Nord notifs now wired.
