# PDV Gameplay Audit — 2026-06-07

End-to-end audit of PlayerDevotion gameplay code against architecture/design,
a Papyrus optimization sweep (against
`houseCARL/Papyrus-Performance-and-Optimization-Reference.md`), and a Daedric
Prince reward/price alignment review. Audit + fixes applied this session.

---

## 1. Conformance audit (verifier-driven)

Verified against the project's own read-only ground-truth gates — **not** by
eyeballing scripts. All green:

| Gate | Result |
|---|---|
| `pdv_content_verify` | FAIL=0, WARN=0, **PASS=1081** |
| `pdv_phase2_reward_readback_audit` | **PASS=1268**, FAIL=0 |
| `pdv_phase20_base_wiring_audit` | 0 FAIL, status **PASS** |
| `pdv_verify` (strict gates, SEQ, freshness) | **0 FAIL** |
| `pdv-daedric-author --check` | **PASS** (16 Princes + QASmoke + organic FLST) |

**Architecture reality.** PDV is a *thin-deity-shell + central-manager*
design: concrete deity quest scripts are intentionally lean (identity shells
extending `PDV_DeityBase`), and per-deity behaviour is centralized in the
always-running `PDV__ManagerQuest` (~9k lines: runtime identity reconciliation,
reward/neglect sync, dawn consolidation, contextual favor, curse handlers). The
codebase is **substantially complete** and passes every conformance gate.

**Correction (important).** An automated research pass during this audit
mis-reported the codebase as "~15% implemented / 79 six-line stubs / gameplay
loop broken." This was a **hallucination** — verified false against the live
files (`PDV_EventBus`=1235 lines, `PDV_MCM`=1981, `PDV_Origin`=281,
`PDV_Deity_Talos`=91, all 16 Daedric paths=130, substrates real) and against the
compiled PEX sizes + the passing gates above. The agent had confused three
abandoned `codex-*` duplicate files for the live scripts. That report is
discarded; this section reflects verifier ground truth.

**Cleanup applied.** The three `codex-*` strays
(`codex-PDV_EventBus.psc` 1128 lines, `codex-PDV_PlayerEvents.psc` 626,
`codex-PDV__ManagerQuest.psc` 6238) declared the **same internal `Scriptname`**
as the real scripts — a Scriptname-ambiguity hazard and the source of the audit
confusion. They were not compiled (no `.pex`) or referenced. Removed from the
live Source folder; preserved in the gitignored
`scratch/parked-untracked-codex-strays-2026-06-07/`.

**Genuinely open work (not a gap, by design):** in-game **runtime proof**. The
Daedric beta gate is correctly `PENDING=16`; all-race runtime/manual evidence
remains the player's in-game session per the existing beta-readiness gates. No
true architecture/design coverage gap was found.

---

## 2. Papyrus optimization sweep

Swept all gameplay `.psc` against the reference's §6 rubric (cost =
frequency × latency; establish trigger first). **Zero 🔴.** The code already
demonstrates mature practice: cached `PlayerRef` + defensive fallback,
`RegisterForSingleUpdate` chains (no bare `RegisterForUpdate`),
`OnPlayerLoadGame` re-arm, debug-level-gated logging everywhere, symmetric
spell `Add*`/`Remove*` (DeityBase/SubstrateBase/DaedricPathBase tier sync),
no `Utility.Wait` chains, no cloak/scan distribution.

**Fix applied — manager `OnUpdate` per-tick reconciliation (🟡 → 🟢).**
`PDV__ManagerQuest.OnUpdate` ran on a 1.0s `RegisterForSingleUpdate` chain and
re-executed `EnsurePhase8/Bosmer/NordRuntimeWiring` + `EnsureSurveyDevotionPower`
**every tick** — idempotent identity/track/power reconciliation (dozens of
cross-script property reads = external calls per §2.3/§3.5) that never changes
second-to-second and is already done once in `OnInit`. Moved this block to the
existing **10-tick (10s) cadence** used by the shout-signal refresh, cutting the
redundant per-tick external calls ~10×. Kept at the 1.0s tick:
`UpdateContextualFavorRuntime` (time-sensitive favor **expiry**) and
`EnsureUnifiedStartupChoice` (cheap StorageUtil-guarded early-return; preserves
startup-prompt timing). Self-heal preserved (10s re-confirm). Recompiled
0 errors / 0 warnings.

Other 🟡s reviewed and left as **acceptable** per the reference (§5.1): the
per-kill deity fan-out loop (O(N) but per-kill, not per-frame) and
`Game.GetPlayer()` defensive fallbacks (rare path, `PlayerRef` cached primary).

---

## 3. Daedric Prince reward/price alignment

### 3.1 Aedra vs Daedric shape — confirmed correctly differentiated

| Aspect | Aedra (`PDV_DeityBase`) | Daedric (`PDV_DaedricPathBase`) |
|---|---|---|
| Reward | boon spells only (pure positive) | **boon + price** spells, carried simultaneously |
| Cost | none (stance only changes gain rate) | **price** spell = active cost while devoted |
| Entry | piety accrues immediately | **commitment-signal gate** (3 signals) before Seeker |
| Social | stance = "easier/weaker", no stigma | **stigma** accrual + per-race stigma modifier |
| Per-race | stance multiplies gain | **state** (Native…Curse) + **exit difficulty** per race |
| Exit | piety decays | price lingers; exit difficulty varies by culture |
| Hook | devotional acts | **vanilla Daedric quest** stage senders |

The Daedric model is genuinely transactional/costly/stigmatized/race-sensitive,
not a reskinned blessing. Confirmed in code.

### 3.2 Prince → vanilla-quest hook map (all 16 hooked; live `PDV_FLST_Daedric_*LiveSources`)

| Prince | Quest (Skyrim.esm) | Stage | Prince | Quest | Stage |
|---|---|---|---|---|---|
| Boethiah | 04D8D6 (DA02) | 100 | Sheogorath | 02AC68 (DA09) | 200 |
| Azura | 028AD6 (DA01) | 100 | Namira | 02C358 (DA10) | 100 |
| Vaermina | 0242AF (DA03) | 190 | Sanguine | 01BB9B (DA11) | 200 |
| Meridia | 04E4E1 (DA04) | 500 | Clavicus Vile | 01BFC4 (DA12) | 200 |
| Molag Bal | 022F08 (DA05) | 200 | Hermaeus Mora | 02D512 (DA13) | 100 |
| Mephala | 04A37B (DA06) | 60 | Nocturnal | 021555 (TG/Nightingale) | 200 |
| Malacath | 03B681 (DA07) | 200 | Peryite | 08998D (DA14) | 100 |
| Mehrunes Dagon | 0240B8 (DA08) | 100 | Hircine | 02A49A (DA05/Companions) | 100 |

### 3.3 Price retune applied — "prices must be real costs" + "diversify per Prince"

**Problem found (verified against the contract):** four Princes had a price on
the **same ActorValue as a boon**, so the "price" was just a smaller boon (net
positive): Azura & Sheogorath (MagickaRateMult, net +4 @ Champion), Sanguine &
Clavicus Vile (net +2 @ T1). Plus axis clustering: 6/16 Speechcraft, 4/16
StaminaRateMult.

**Fix:** retuned `PRINCE_META.price` in
`tools/pdv_generate_daedric_contract.mjs` so **every price is on an axis
distinct from that Prince's boons** (a genuine −3/−5/−8 net cost), sphere-fit,
and diversified. Regenerated contract → re-authored MGEF/SPEL records →
recompiled. Price flavor text is abstract, so no prose change needed.

| Prince | Price old → new | Rationale |
|---|---|---|
| Azura | MagickaRateMult → **StaminaRateMult** | fix same-axis; vigil of foresight wearies |
| Sheogorath | MagickaRateMult → **Restoration** | fix same-axis; madness erodes self-restoration |
| Sanguine | StaminaRateMult → **MagickaRateMult** | fix same-axis; dissipation dulls the mind |
| Clavicus Vile | Speechcraft → **MagickaRateMult** | fix same-axis; the bargain drains vital spark |
| Vaermina | StaminaRateMult → **HealRateMult** | corrupted sleep → poor recovery |
| Nocturnal | Speechcraft → **Restoration** | the Empty Night claims vitality |
| Hircine | Speechcraft → **HealRateMult** | the hunt's toll; bites the melee-hunter build |
| (kept) Boethiah / Mephala / Namira | **Speechcraft** | social stigma — narrative-perfect |
| (kept) Malacath SpeedMult · Dagon DamageResist · Molag HealRateMult · Meridia Illusion · Mora/Peryite StaminaRateMult | — | already distinct + real cost |

Result: no Prince has price-axis == boon-axis at any tier (verified). Axis
spread: Speechcraft 6→3, StaminaRateMult 4→3; top-two concentration 10/16 → 6/16
across 8 distinct axes.

### 3.4 Curse double-fire guard — verified already correct (no change)

Per the chosen rule ("allow both curse-paths, guard double-fire"):
- `HandleCurseStateRefresh` fires a transition only on `oldState != newState`
  and re-derives state via `RefreshFromPlayerState` → single-fire + idempotent.
- `PDV_DaedricPath_Hircine.HandleCurseTransition` is **werewolf-gated**
  (`newState/oldState == CURSE_WEREWOLF`) → a vampire transition can't credit the
  Hircine path.
- Molag is **not** wired into the curse transition (its piety comes from its own
  House-of-Horrors quest-stage route). No single transition credits both paths.

Confirmed correct in code; no change made. (Observation: vampire onset does not
credit the Molag *path* directly — Molag's commitment is modelled as the
House-of-Horrors quest, not generic vampirism. Intentional, noted for future.)

---

## 4. Post-change verification

`pdv_verify` 0 FAIL · `pdv_content_verify` FAIL=0/PASS=1081 ·
`pdv-daedric-author --check` PASS · `pdv_phase2_reward_readback` PASS=1268/FAIL=0 ·
`pdv_daedric_runtime_check --self-test` PASS · all touched scripts compile
0/0 · beta gate correctly `PENDING=16` (in-game runtime proof unchanged —
remains the player's session).
