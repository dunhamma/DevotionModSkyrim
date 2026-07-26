# PDV Ancestral-Spine Parity Audit (2026-06-24) — RETIRED 2026-07-19

> **RETIRED. Do not cite this document for what ships.** Its central verdict
> table ("NOT at stacked parity") was disproven against `Devotion.esp` on
> 2026-07-19 via houseCARL VMAD reads. Substrate work through early-to-mid July
> landed after this audit and invalidated its per-race conclusions.
>
> **Specifically disproven:**
>
> | Audit claimed | ESP reality (2026-07-19) |
> |---|---|
> | Nord: **THIN**, "no substrate", no always-on boon | `PDV_Substrate_NordAncestor` `07159C` — all 3 slots filled (Ancestor's Steadiness / Regard / Honor) |
> | Imperial: patron-gated, no unconditional boon | `PDV_Substrate_ImperialAncestor` `0715B6` — all 3 filled; High = Health +15, Stamina +15 |
> | Breton: patron-gated, no unconditional boon | `PDV_Substrate_BretonAncestor` `0715BD` — all 3 filled; High = Magic Resist +12% |
> | Altmer: patron-gated, no unconditional boon | `PDV_Substrate_AltmerAncestor` `0715AC` — all 3 filled (Ordered / Disciplined / Exemplar Heritage) |
> | "only 3 substrate races" | 7 substrate quests ship |
>
> `SyncImperialAncestorSubstrate` and its siblings gate on **race only**, not
> patron state, so these boons ride alongside the patron boon.
>
> Not re-verified: the Redguard / Orc / Bosmer rows (those races genuinely have
> no substrate quest), and the non-boon dimensions (minus stacks, diegetic
> surfaces, text depth). Treat all of it as unverified rather than false.
>
> **Instead:** read the substrate QUST VMAD directly via houseCARL
> (`cross_plugin_query type=QUST plugins=[Devotion.esp] editorid_contains=Substrate`,
> then `read_record <quest> fields=[VirtualMachineAdapter.Scripts[0].Properties] depth=3`).
> The parity *model* in "The parity model — Spine Stack Score" may still be
> reusable as a scoring frame; its per-race scores are not.

**Source:** workflow `ancestral-spine-audit` (10 parallel Explore agents + synthesis, 1.2M tokens).
**Scope:** each race's *always-active cultural/ancestral spine* — the layer beneath patron/sect/path
choice — across structure, signals, active-effect stack, diegetic, text, and pluses/minuses.
**Method note:** this audit was STATIC (source + manifest + CSV). The ESP-reality layer was
spot-verified separately via houseCARL (FormList contents matched the manifest with zero drift).
Per [[cross-cutting-audit-doctrine]], a re-runnable harness with a houseCARL proof layer should
replace this one-off.

## Verdict: NOT at stacked parity

| Race | Richness | Spine mechanism | Always-on boon? | Notes |
|---|---|---|---|---|
| Argonian | **RICH** | `PDV_Substrate_ArgonianHist` (true substrate) | **unconditional** | the canonical template |
| Khajiit | **RICH** | Lunar Lattice substrate (`PDV_SubstrateBase`) | **unconditional** | metric-tiered, no patron gate |
| Bosmer | **RICH** | no substrate, but broad wired surfaces | partial | rich by *breadth* (Naming, dreams, Songs) |
| Dunmer | MODERATE | `PDV_Substrate_DunmerAncestor` (ResistMagic +3/+9/+20 unconditional) | one tier | strongest MODERATE; cheapest to bring to parity |
| Imperial / Breton / Altmer / Redguard / Orc | MODERATE | reputation-track / framework / accumulator / life-mode | **patron-gated** | T1 floor fires only on patron-active OR ≥3 acts |
| **Nord** | **THIN** | no substrate, `PantheonBaseline` framing track only | none | lone out-of-band outlier |

**Structural root cause (the smoking gun):** `PDV__ManagerQuest.psc:8574-8586` — every race's T1 floor
spell gates on `IsFirstTierRaceRewardEligible() || IsBroadFloorEligible()` (patron-active OR ≥3
accumulated acts), **except** Argonian Hist_T1, which is deliberately pulled OUT of the patron-gated
path (`:8577-8578`) because the substrate owns it unconditionally. **The substrate architecture is the
only thing that currently produces a true always-active stacked pile.** The 6 non-substrate spines
inherit patron conditionality; Nord inherits it with the thinnest surrounding texture (no substrate,
no neglect sync, no sleep handler, dead diegetic).

## Canonical template — Argonian Hist (model others on its TWO-LEDGER design)

1. **Unconditional boon pile** via `PDV_SubstrateBase` (Substrate_Always/Mid/High on metric+origin, NO
   patron gate). 2. **Real composite metric** (Hist + People×0.25 + Void×0.10, decay −1/dawn after 3
   grace days, floor 20, posture enum). 3. **Double-route**: every act feeds BOTH the substrate metric
   AND a small honest pulse to `PDV_Deity_Hist` (`SIGNAL_HIST_PULSE +1.0`) so the universal layer never
   goes dark for a no-patron race. 4. **Graduated minus stack** (anti-creed −4/−6/−8, posture neglect,
   curse-removes-floor). 5. **Deepest wired diegetic** (posture-keyed dreams 5×3, sacred-waters/sap
   visions, adaptation rite, Prisma toasts).

## Cross-cutting gaps (systemic — these recur across spines)

1. **No distinct ancestral LD category for ANY race** — ancestor day-to-day signals route through the
   shared per-deity table with generic verbs; no Saxhleel/Yokudan/Orsimer-specific column, so cultural
   behavior is indistinguishable from a foreign worshipper.
2. **Spines can't take signals into a spine-owned piety sink** — only the 3 substrate races accumulate
   independent of patron; everyone else routes "always-active" acts to an inactive patron ledger, so the
   ancestral layer is invisible pre-commitment (Nord→Shor, Redguard→Tu'whacca).
3. **Patron/broad-floor conditionality on every T1 floor** — unconditional boon exists only for substrate
   races.
4. **Specced-but-never-emitted minuses** — e.g. Redguard `SIGNAL_DEATH_DUTY_ABANDONMENT −3.0` has no emit
   site (same class as the historical P2 book-notice suffix bug).
5. **Declared-but-never-dispatched diegetic dead code** — Nord `PDV_Notif_Nord_General_AncestorsQuiet` /
   `_Kyne_ChampionAmbient_Storm`, Orc `PDV_Notif_Orc_Witnessed_TheWatchers_*` (zero call sites).
6. **No sleep/dream channel for half the roster** (Nord/Breton/Altmer/Redguard/Orc) despite designed
   dream/vision content; **no prayer/home maintenance channel** for most (only Dunmer + Argonian).
7. **Variety tranches uniformly blocked** behind effect-review gates (Altmer/Redguard/Orc).
8. **Book-of-Days bespoke voice uneven** — Imperial/Altmer fall back to the generic template.

## The parity model — Spine Stack Score (mechanism-agnostic)

Score each race's *always-active layer only* (exclude patron-tier rewards). Six weighted dims, 0-3 each,
normalized so **Argonian = 100%, <70% = a parity build target**:
1. **Unconditional boon floor (×3)** — the heaviest; effective magnitude sum at a fixed reference state
   (e.g. 30 days, no patron). 0=none(Nord) → 3=multi-effect unconditional metric tier (Argonian/Khajiit).
2. **Piety-sink reachability (×2)** — can spine acts feed a sink WITHOUT a committed patron?
3. **Minus stack (×2)** — graduated WIRED penalties (penalize specced-but-unemitted to 0-1).
4. **Renewable maintenance channels (×1)** — prayer/home/sleep/location count.
5. **Diegetic surfaces wired (×1)** — live-dispatched only; subtract dead declarations.
6. **Text/voice depth (×1)** — thin/moderate/rich = 0/1.5/3.

Dim 1 is mechanism-agnostic — a reputation-track race hits a 3 by adding an unconditional band-keyed
boon; a substrate race hits it via the metric tier — so equal FELT value counts regardless of build,
which is the parity definition. **This score should become a check in the Integrity Harness, with the
spine-parity build as its first customer.**

## Recommended next steps (separate "Integrity Harness" session)

- Implement the **Spine Stack Score** as a registry-driven, re-runnable check (not a one-off workflow).
- First build targets worst-first: **Nord** (give it an ancestral spine at all), then the 6 patron-gated
  MODERATE races (add an unconditional band-keyed boon + a spine-owned piety pulse), modelling all on the
  Argonian two-ledger template; **Dunmer is the cheapest to bring to full parity** (already has a substrate).
- Add the **distinct ancestral LD category per culture**, wire the **specced minuses**, and dispatch (or
  delete) the **dead diegetic declarations**.
