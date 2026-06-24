# Spine Margin: 6e Renewable Retrofit + Redguard Margin (Codex Handoff, 2026-06-24)

Spine parity is 7/7, but 3 races are thin on the `renewable` dim and **Redguard sits exactly at
70%** (no margin). This pass lifts them. Verify each with `node tools/pdv_spine_stack_score.mjs`
(update the registry rows as built) — target: Nord/Orc/Redguard `renewable`→2, Redguard `diegetic`→2.

## Part 1 — 6e renewable retrofit (per `PDV_RenewableChannel_6e_Design_2026-06-24.md`)
Add the universal **sleep / ancestral-rest** channel (hook `OnSleepStart/Stop`, gated on origin +
own-home/bed, daily-capped via `ClampSignalMultiplier`), mirroring `PDV_Substrate_DunmerAncestor`
prayer/home + `PDV_Substrate_ArgonianHist` `RecordBedOfChoiceReturn`:
- **Nord** (`renewable 0→2`): `PDV_Substrate_NordAncestor` — `RecordAncestralRest` (hearth-rest) `→ AdjustMetric`; + a hold/hearth home-return channel.
- **Orc** (`renewable 1→2`): `PDV_Substrate_OrcAncestor` — sleep (stronghold-rest) `→ AdjustMetric`.
- **Redguard** (`renewable 1→2`): **no substrate script** — its boon is `SyncRedguardSpineBoon` +
  `PDV_Bless_Redguard_Spine_*` ESP spells keyed on the sect. So adapt: a sleep-based
  `RecordRedguardAncestralRest` that bumps whatever standing `SyncRedguardSpineBoon` reads for its
  tier AND pulses Tu'whacca (`AwardCuratedSignalScaled(PDV_Tuwhacca, SIGNAL_ANCESTOR_SPINE, ...)`),
  daily-capped. (Codex built `SyncRedguardSpineBoon` — use the metric/standing it already reads.)

## Part 2 — Redguard ancestor-layer diegetic (`diegetic 1→2`)
Redguard's notifs (`PDV_Notif_Redguard_Sect_*_Entry`, `FarShoresToken`) are all *sect-choice*
surfaces, not *ancestor-spine* surfaces. `HandleRedguardAncestorSpine` only emits a generic
`ShowP2BookNotice("The Yokudan dead", "The ancestor-line stands straighter in you.")`. Add ONE
dedicated ancestor-layer surface: a `PDV_Notif_Redguard_AncestorSpine_*` (a posture/ambient toast
or a Book-of-Days ancestor-line entry), dispatched from the spine pulse — parallels Nord's
ancestor-layer diegetic. That lifts `diegetic` to 2.

## Part 3 — OPTIONAL: Redguard `piety_sink` (2→3)
Redguard has **1** Tu'whacca double-route site (`HandleRedguardAncestorSpine`); Nord has **1** Shor
site yet scored 3. Either route MORE Redguard spine route-families through the Tu'whacca pulse (as
Nord does "every route family"), OR reconcile the curated score to 3 for structural parity with
Nord (justified: both are single-deity spine-owned pulses). Not required for margin — Parts 1+2
alone take Redguard to ~77%.

## ⚠️ Serialize (substrates + manager + maybe ESP for a new notif). Verify
`pdv_compile` 0/0 → `pdv_verify` FAIL=0 → `pdv_signal_e2e_gate` 0 RED + parity PASS →
update `PDV_SpineStackRegistry.csv` (Nord/Orc/Redguard renewable, Redguard diegetic) →
`pdv_spine_stack_score.mjs`: Nord ~83, Orc ~80, **Redguard ~77** (out of the 70% knife-edge).
