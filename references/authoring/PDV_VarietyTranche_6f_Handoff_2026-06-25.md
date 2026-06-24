# 6f Variety Tranches — Altmer / Orc / Redguard (Codex Handoff, 2026-06-25)

## Context
Open-item **6f** (gap #7) in `PDV_SessionHandoff_2026-06-25.md`. Three race variety tranches —
**Altmer, Orc, Redguard** — are blocked "Pending" in `PDV_RaceEffectReviewLedger.md` (the Race
Review Table, rows ~105/108/109). Their **substrate-baseline / broad-lane floor is ALREADY built**:
it is the spine build's unconditional band-keyed boon (Altmer Magicka floor, Orc mode-keyed
armor/health, Redguard sect-keyed Health+OneHanded — all landed in the 2026-06-24 spine parity
build). So 6f is **not** the floor; it is the **variety layer on top** — the rite / signature /
pilgrimage pulses that give each race texture without adding a second always-on boon. Do these as
**one body of work with the effect-review row**, not as two disconnected docs (duplicate-or-skip
risk flagged in the session handoff).

## ⚠️ Verify-current-state FIRST (two stale-handoff hits this session)
6c's Tu'whacca minus and **all of 6d** turned out already-built when their handoffs still listed
them as "to dispatch." Before authoring, grep the live manager + the reward-record contracts for
each tranche family below — some pulses may already exist. Build only what's genuinely missing.

## Design lock (do NOT re-litigate)
Shapes/gates/caps/fade are design-locked in `PDV_RaceVarietyTranche_Roadmap.md` and folded into
each race sheet. The `PDV_RaceEffectReviewLedger.md` "Variety Tranche Gate (2026-06-12)" section is
the binding contract:
- **No new always-on boon families.** Pilgrimage pulses are one-shot; signatures are once/day
  ~10-minute-class pulses; rite effects are one-active with dawn fade/restore.
- **Rite effects follow the Hist Adaptations contract:** one active at a time, swap is
  clear-before-add, "Not yet" does not spend the cooldown, fade at dawn on coherence break, restore
  at dawn on recovery.
- All tranche magnitudes are **provisional** and must pass the ledger's race-row review.

## Per-race tranche families to author (from the ledger gate section)
| Race | Tranche effect families |
|---|---|
| **Altmer** | `Ordered Mind`, `Syrabane's Hand`, Chantry pulses, four Disciplines of Return (rite) |
| **Orc** | `Hearth-Held`, `The Code Holds`, Four Holds pulses, four Trial of Iron disciplines (rite) |
| **Redguard** | sword-tending Leki pulse, `Leki's Measure`, `Tava's Departure`, `The Unclean Hour`, Halls pulses, four Remembering of Names observances (rite) |

## Build path
1. Author the SPEL/MGEF records via the reward-author toolchain
   (`tools/pdv-phase20-reward-author` + `PDV_Phase20_RewardRecordContracts.json`), mirroring the
   existing tranche records (Bosmer + Khajiit tranches already shipped — use them as the template).
2. Wire manager grant/removal ownership for each pulse/rite (one-active rite swap = clear-before-add;
   dawn fade/restore on the existing dawn pass).
3. Complete each race's **Completion Bar row** in `PDV_RaceEffectReviewLedger.md` (floor family,
   ceiling family, magnitude range, cadence, grant/removal owner, stack cap, Survey copy, rejected
   generic hooks, curse/Daedric interaction, manual feel note).
4. Survey/MCM copy in-voice (run the `pdv-player-copy` guardrails; ASCII-only).

## Serialize + Verify
Reward records (ESP) + manager grant wiring serialize with any concurrent manager work.
- `pdv-phase20-reward-author --check` clean; reward readback PASS for the new records.
- `node tools/pdv_compile.mjs` 0/0 → `node tools/pdv_verify.mjs` FAIL=0.
- `node tools/pdv_signal_e2e_gate.mjs` 0 RED + parity PASS; `node tools/pdv_integrity_harness.mjs` PASS.
- Each tranche effect needs an in-game **manual feel note** before external beta (one-active swap,
  dawn fade/restore, no third-loud-package stacking) — that proof stays with the owner, not this build.
