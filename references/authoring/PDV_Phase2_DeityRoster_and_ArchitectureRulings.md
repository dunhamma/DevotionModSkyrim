# PDV Phase 2 — Deity Roster & Architecture Rulings

**Created:** 2026-06-07
**Status:** Coordination authority for Phase 2 per-race reward specs (the single source of truth
that keeps parallel per-race spec/manifest authoring consistent).
**Owner:** Companion to `PDV_RaceContractTemplate.md`, `PDV_RaceRewardBudgetLedger.md`,
`PDV_DeityCoverageMatrix.json`, and the Phase 2 plan
(`~/.claude/plans/use-our-handoff-to-validated-hellman.md`).

> **Superseded scope notice (2026-07-13):** This file remains the historical
> Phase 2 record and still governs shared deity identity. For Imperial and Nord
> broad progression, `PDV_BroadPantheonContracts.json` now wins: broad worship
> is still state rather than a deity, but progression is a manager-owned signed
> pool rather than civic/service counts or a single race reward resolver. The
> locked Old Ways roster is Kyne, Shor, Tsun, Stuhn, Mara, Orkey, Dibella, and
> Talos. The Nine Divines roster is Akatosh, Arkay, Dibella, Julianos, Kynareth,
> Mara, Stendarr, Zenithar, and Talos. Both Nord baselines must be mechanically
> complete and only one is active at a time.

These rulings were derived by reading the LIVE manager (`PDV__ManagerQuest.psc`) — they reflect
how the engine actually works, not a fresh design. Every Phase 2 race spec MUST conform.

---

## Architecture rulings (binding)

### R1 — Broad worship is a STATE, not a deity
Broad-lane worship runs on `PATRON_STATE_BROAD` + a single race-keyed broad reward spell resolved by
`GetFirstTierRaceRewardSpellForOrigin()`. **Do NOT create an aggregate "broad" deity record**
(no `PDV_Deity_NineDivines`, no `PDV_Deity_OldWays`, etc.). The broad lane's reward is granted by
the broad-worship reward path, gated on the race's progression state (tier/substrate/state-enum).

### R2 — The broad-T1 reward editorId is FIXED per race (match the manager)
The manager already declares exactly one broad-T1 `Spell Property` per race. Specs MUST use these
exact editorIds for the broad T1; the broad T2 follows the same stem with `_T2`:

| Race | Broad lane | Broad T1 editorId (FIXED) | Broad T2 (new) |
|---|---|---|---|
| Altmer | Orthodox | `PDV_Bless_Altmer_Orthodox_T1` | `PDV_Bless_Altmer_Orthodox_T2` |
| Argonian | Hist | `PDV_Bless_Argonian_Hist_T1` | `PDV_Bless_Argonian_Hist_T2` |
| Bosmer | Yffre/path | `PDV_Bless_Bosmer_Yffre_T1` | `PDV_Bless_Bosmer_Yffre_T2` |
| Breton | Tradition | `PDV_Bless_Breton_Tradition_T1` | `PDV_Bless_Breton_Tradition_T2` |
| Dunmer | Reclamation | `PDV_Bless_Dunmer_Reclamation_T1` | `PDV_Bless_Dunmer_Reclamation_T2` |
| Imperial | Civic | `PDV_Bless_Imperial_Civic_T1` | `PDV_Bless_Imperial_Civic_T2` |
| Khajiit (done) | Lunar | `PDV_Bless_Khajiit_Lunar_T1` | (substrate-led) |
| Nord | OldWays | `PDV_Bless_Nord_OldWays_T1` | `PDV_Bless_Nord_OldWays_T2` |
| Orc | Malacath | `PDV_Bless_Orc_Malacath_T1` | `PDV_Bless_Orc_Malacath_T2` |
| Redguard | AncestorSpine | `PDV_Bless_Redguard_AncestorSpine_T1` | `PDV_Bless_Redguard_AncestorSpine_T2` |

For Nord, the Old Ways row above remains its own record family. The Nine Divines
baseline now requires distinct `Faith of the Holds - Seeker/Faithful` records;
it must not reuse either Old Ways or Imperial records. For Imperial, the Civic
EditorIDs remain compatibility identifiers while the player-facing family is
`The Divines' Regard` and is gated by the Imperial Divines pool.

### R3 — Focused-patron 3-tier sets follow the Khajiit naming convention
`PDV_Bless_<Race>_<Patron>_T1/T2/T3` (e.g. `PDV_Bless_Imperial_Mara_T1`,
`PDV_Bless_Redguard_Tuwhacca_T2`). These are NEW manager `Spell Property` entries (B2 work) modelled
on the existing Khajiit emphasis properties (lines 86-100 of the manager). The grant logic mirrors
`SyncKhajiitEmphasisRewards`/`SyncKhajiitEmphasisFamily` (one active focus at a time;
T1>=Seeker, T2>=Devoted, T3>=Champion).

### R4 — Deities are SHARED records keyed by per-race stance (create once, reuse elsewhere)
A focusable patron worshipped by multiple races is ONE deity QUST with multiple `Stance_<Race>`
fields, created ONCE by its **owner** race spec (`"create": true`), and referenced by every other
race spec with `"create": false` + that race's stance added (the generalized author tool's
`--reconcile-shared-deity` mode and `stances[]` support handle this). Deity creation is idempotent
and authoring is serial, so the owner's spec simply must run before reuse specs. This keeps
`PDV_FLST_AllDeities` at ~30 deities total (not races x patrons) — the manager iterates the whole
list every dawn (`RunDawnConsolidateScratch`/`RunDawnApplyDecay`), so the list must stay bounded.

### R5 — Only FOCUSABLE patrons get deity records
A god the player can commit to as a primary focus (and tier up on) needs a deity QUST. Pantheon
flavor gods that are only ever part of a broad lane do NOT get their own record in V1 (they live in
the broad-state reward). Keep each race's focusable set disciplined (see roster).

### R6 — Daedric-path focuses route through the existing Daedric system, NOT new Aedric records
Breton Hidden Art, Dunmer non-Reclamation deviations, Nord Hircine, etc. are covered by the
already-content-ready Phase 20C Daedric Prince track (16 Princes, `PDV_DeityCoverageMatrix.json`
slice 20C). Phase 2 specs author the **Aedric/native reward spine** only. Do not create new Daedric
Prince deity records here; reference the Daedric system where a tradition/path includes a Daedric
fork.

### R7 — No-offer vs offer vs state-gated (three gate shapes, not two)
- **Substrate / no-offer** (Khajiit done; Argonian; Dunmer-ancestor lane): rewards gate on substrate
  tier + layer state; a small honest piety pulse to a scripted patron keeps decay/neglect/creed
  honest. Needs a manager special-branch like the Khajiit one (B2).
- **Active-patron / offer** (Imperial; Altmer; Dunmer-Reclamation foreground): rewards gate on
  `IsFirstTierRaceRewardEligible` (active patron tier >= Seeker). Real piety faucet.
- **State-enum-gated** (Nord pantheon-baseline; Breton tradition; Bosmer path; Orc life-mode;
  Redguard sect): rewards gate on the race's state enum + the focused patron's piety tier within
  that state. The state enums already exist (`PDV_State_NordPantheonBaseline`, `PDV_State_BretonTradition`,
  `PDV_State_BosmerPath`, `PDV_State_OrcLifeMode`, `PDV_State_RedguardSect`). Treat these as offer-like
  for the focused patron, with the state enum as the eligibility filter.

### R8 — Balance invariants (carried from the budget ledger)
<=2 always-on boon families per race; broad < focused; no single act gets both anti-farm mechanisms
(`ScoreRepeatableAction` for piety vs `ConsumeDailyRepeatMultiplier` 0.7^n for substrate); per-tier
magnitude ceiling ~12%; creed-violation loss medium/major only. ASCII-only player text; Skyrim
ActorValue names only.

---

## Master deity roster (focusable patrons needing QUST records)

Tiers: **Existing** (already in ESP), **Khajiit-added** (Phase 1), **New in Phase 2** (this tranche).
"Owner" = the race spec that creates the record (`create:true`); all other worshippers reuse it.

| Deity (editorId) | Status | Owner (creates) | Worshippers (add `Stance_<Race>`) | Notes |
|---|---|---|---|---|
| PDV_Deity_Kyne | Existing | — | Nord (NATIVE) | Distinct from Kynareth |
| PDV_Deity_Talos | Existing | — | Nord (NATIVE), Imperial (NATIVE, ConcordatStanding-gated) | Faithful defiance only for Imperial |
| PDV_Deity_AuriEl | Existing | — | Altmer (NATIVE) | Elven Akatosh aspect; distinct record from Akatosh |
| PDV_Deity_Yffre | Existing | — | Bosmer (NATIVE) | Path-interpreted |
| PDV_Deity_Zen | Existing | — | Bosmer (NATIVE, Exchange path) | Z'en != Zenithar |
| PDV_Deity_BaanDar | Existing | — | Khajiit (NATIVE), Bosmer (tolerated, Bandit Road) | Already shared-reconciled |
| PDV_Deity_Azura | Khajiit-added | Khajiit | Khajiit (NATIVE, "Azurah"), Dunmer (NATIVE) | Dunmer reuses (create:false) |
| PDV_Deity_Khenarthi | Khajiit-added | Khajiit | Khajiit (NATIVE) | |
| PDV_Deity_Rajhin | Khajiit-added | Khajiit | Khajiit (NATIVE) | |
| PDV_Deity_Alkosh | Khajiit-added | Khajiit | Khajiit (NATIVE) | **NOT a Redguard deity** (confirmed: Redguard = Yokudan pantheon). No Redguard reconciliation needed. |
| PDV_Deity_Akatosh | **New** | Imperial | Imperial (NATIVE), Nord (NATIVE), Breton (NATIVE) | Nine Divines |
| PDV_Deity_Mara | **New** | Imperial | Imperial (NATIVE), Nord (NATIVE), Breton (NATIVE) | |
| PDV_Deity_Arkay | **New** | Imperial | Imperial (NATIVE), Nord (NATIVE), Breton (NATIVE), Redguard (fallback death infra only) | |
| PDV_Deity_Stendarr | **New** | Imperial | Imperial (NATIVE), Breton (NATIVE, Knight's Road) | |
| PDV_Deity_Zenithar | **New** | Imperial | Imperial (NATIVE), Breton (NATIVE) | Distinct from Z'en |
| PDV_Deity_Dibella | **New** | Imperial | Imperial (NATIVE) | |
| PDV_Deity_Julianos | **New** | Imperial | Imperial (NATIVE), Breton (NATIVE, Hidden Art lawful) | |
| PDV_Deity_Kynareth | **New** | Imperial | Imperial (NATIVE), Breton (NATIVE), Bosmer (tolerated, Y'ffre proxy) | Distinct from Kyne |
| PDV_Deity_Boethiah | **New** | Dunmer | Dunmer (NATIVE, Reclamation) | Good Daedra; Reclamation foreground |
| PDV_Deity_Mephala | **New** | Dunmer | Dunmer (NATIVE, Reclamation) | Good Daedra; Reclamation foreground |
| PDV_Deity_Magnus | **New** | Altmer | Altmer (NATIVE, scholarship secondary) | |
| PDV_Deity_Xarxes | **New** | Altmer | Altmer (NATIVE, record-keeping secondary) | |
| PDV_Deity_Trinimac | **New** | Orc | Orc (pressure/orthodox), Altmer (orthodox pressure) | Shared Orc/Altmer; rare ideological pressure, not a steady lane |
| PDV_Deity_Malacath | **New** | Orc | Orc (NATIVE) | The Orc spine; life-mode state gates rewards |
| PDV_Deity_Tuwhacca | **New** | Redguard | Redguard (NATIVE, death duty) | Yokudan; uses Arkay-adjacent spaces but is Yokudan |
| PDV_Deity_HoonDing | **New** | Redguard | Redguard (NATIVE, make-way, rare, weekly cap) | |
| PDV_Deity_Leki | **New** | Redguard | Redguard (NATIVE, sword-singing/martial conduct) | |
| PDV_Deity_Hist | **New** | Argonian | Argonian (NATIVE) | Substrate pulse target |
| PDV_Deity_Sithis | **New** | Argonian | Argonian (tolerated/threshold) | High-threshold Void tertiary |
| PDV_Deity_Shor | **New** | Nord | Nord (NATIVE, Old Ways) | Hero-god of Sovngarde; Old Ways focusable (added per Nord any-god-in-pantheon decision) |
| PDV_Deity_Tsun | **New** | Nord | Nord (NATIVE, Old Ways) | God of trials/adversity, guards Sovngarde; Old Ways focusable |
| PDV_Deity_Stuhn | **New** | Nord | Nord (NATIVE, Old Ways) | Shield-thane; god of ransom/justice; Old Ways focusable |

**Net new Phase 2 deities: ~22. Resulting `PDV_FLST_AllDeities` size: ~32** (bounded; dawn-iteration safe).
Includes the 3 Nord Old Ways gods (Shor/Tsun/Stuhn) added per the "Nord can focus any god in its
chosen pantheon" decision — Nine Divines lane reuses the 8 Divines + Talos; Old Ways lane = Kyne +
Talos + Shor/Tsun/Stuhn.

Optional broad-only Yokudan gods (Ruptga/Satakal/Tava/Onsi/Sep) and Old Ways gods (Shor/Tsun/Stuhn)
stay in the broad-state lane for V1 — NO separate records unless a later pass makes them focusable.

---

## Per-race quick reference (gate type, focusable patrons, new deities owned)

| Race | Gate (R7) | Broad lane | Focusable patrons | New deities this race OWNS |
|---|---|---|---|---|
| Imperial | offer | Civic (Nine Divines state) | 8 Divines + Talos(reuse) | Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth |
| Argonian | substrate/no-offer | Hist | People focus, Sithis(high-threshold) | Hist, Sithis |
| Nord | state (pantheon baseline) | OldWays / NineDivines | any god in chosen pantheon: Nine Divines lane = 8 Divines(reuse) + Talos(reuse); Old Ways lane = Kyne(reuse), Talos(reuse), Shor/Tsun/Stuhn | Shor, Tsun, Stuhn (Old Ways) |
| Altmer | offer | Orthodox | Auri-El(reuse) + Magnus, Xarxes | Magnus, Xarxes (Trinimac reused from Orc) |
| Dunmer | substrate(ancestor)+offer(Reclamation) | Reclamation | Azura(reuse), Boethiah, Mephala | Boethiah, Mephala |
| Bosmer | state (path) | Yffre | Yffre(reuse), Zen(reuse), BaanDar(reuse) | none |
| Breton | state (tradition) | Tradition | Divines(reuse, Knight's Road); Daedric via 20C (Hidden Art) | none (reuses Divines; Daedric per R6) |
| Orc | state (life-mode) | Malacath | Malacath, Trinimac(pressure) | Malacath, Trinimac |
| Redguard | state (sect) | AncestorSpine | Tu'whacca, HoonDing, Leki | Tu'whacca, HoonDing, Leki |

**Deity-index allocation:** all new deities use `"deityIndex": "next-available"`; the generalized
author tool scans existing indices and assigns sequentially at author time (collision-free because
authoring is serial). Existing Khajiit indices 40-43 are preserved.

**Authoring order (so owners precede reuse) — validated against the spec ownership map:**
1. **Imperial** (creates the 8 shared Divines) + **Argonian** (Hist/Sithis) — pilots.
2. **Orc** (creates Malacath + **Trinimac**) — MUST precede Altmer, which reuses Trinimac as pressure.
3. **Dunmer** (Boethiah/Mephala; reuses Azura), **Altmer** (Magnus/Xarxes; reuses Auri-El + Trinimac),
   **Redguard** (Tu'whacca/HoonDing/Leki; reuses Arkay — so after Imperial).
4. **Nord**, **Bosmer**, **Breton** (pure reusers) last (Breton reuses Imperial's Divines).
Each new deity QUST needs the SGE flag + a `pdv_refresh_seq` pass (the BaanDar lesson); shared-deity
stance adds use `--reconcile-shared-deity`. Verified 2026-06-07: 0 ownership collisions, 0 orphan
reuses, 19 new deities (FLST 10 -> 29).
