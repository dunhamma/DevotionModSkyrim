# Decay Audit — the rates of fall

Mirror of `PDV_PietyPaceBalancingTable.md` / `PDV_SignalDensityAudit.md`. Piety asked *how long
to rise to each tier, and is it uniform?* Decay asks: **how long to fall (lose a tier / hit the
floor) if you stop, is it uniform across gods, and does it honor the locked design goal —
"relationship drift that is slow and recoverable, not a daily servicing loop"** (`PDV_Architecture_v3.md:1353`)?

> **Decisions applied (this pass):** grace **3 → 2 days**; **5-point tier-down hysteresis** added;
> **vampire curse decay bypasses the floor** (werewolf respects it). Gain rate is now **3.3/day**
> (moderate-compression pass), so the decay:gain ratio improves. Two forks remain open — Orc decay
> scaling (provisional rec applied) and DruidicStanding volatility — see end.

## The constants (§15 + this pass)

| Constant | Value | |
|---|---|---|
| `DECAY_PER_DAY` | **0.5/day** | after grace |
| `DECAY_GRACE_DAYS` | **2** (was 3) | any qualifying event resets it; decay audit tightened it |
| `TIER_DOWN_HYSTERESIS` | **5.0** | lose a tier only 5 below its threshold |
| `BROAD_WORSHIP_DECAY_MULTIPLIER` | **0.2×** → 0.1/day | broad-capped gods |
| Active patron | **skipped** (0) | your chosen patron never passively decays |
| Tier floors (persistent, `PDV.PassiveDecayFloor`) | Devoted→**50**, Faithful→**25**, Observant→**0** | highest tier ever reached locks the floor |
| Curse multiplier | e.g. **5×** (Vampire Imperial Divine); **vampire bypasses floor** | §15.3 |
| Reputation multiplier | e.g. Concordat Enforcer decays Talos faster | §15.3 |

Formula: idle days to lose **X** piety = `grace + X / rate`.

## Standard decay calendar (focused deity, base rate, grace 2 + 5-pt hysteresis)

| From (value) | Floor | Lose the **tier label** (fresh tier) | Lose the label (with +10 buffer) | **Slide to the floor** (full neglect) |
|---|---|---|---|---|
| Devoted 85 | 50 | **~12 idle days** | ~32 days | **72 days** |
| Faithful 50 | 25 | ~12 idle days | ~32 days | **52 days** |
| Observant 25 | 0 | ~12 idle days | ~32 days | **52 days** |

With the adopted 5-point hysteresis, losing a *fresh* tier now takes ~12 idle days (drop 5 below
threshold after a 2-day grace), not the ~4 it would under a strict threshold — the fix described
under "Headline finding (resolved)" below.

**Broad worship (0.1/day):** 5× slower — lose a fresh label in ~52 idle days; sliding Faithful→25
takes **~252 idle days** (effectively never). Broad worship is a genuinely low-maintenance lane.

**Active patron:** never decays. Your committed patron is permanent.

## Health metrics — does it meet the design goal?

- **"Not a daily servicing loop": PASS.** Grace is 2 days, so worshipping *at least every other day*
  prevents decay entirely — and coverage shows engaged players act for a chosen god ~daily, so the
  tighter grace is invisible to them and only catches genuine neglect. Even total neglect costs only
  0.5/day. There is no treadmill.
- **"Slow and recoverable": PASS, strongly.** Decay (0.5/day) is **~1/7** of the default gain
  (3.3/day), so worship outpaces drift ~7:1 — ten idle days lose ~4 piety, recovered in ~1.2 active
  days. A lapse is a gentle nudge, not a setback.
- **Uniform across gods by construction**, with a sanctioned-exception catalogue (below), exactly
  parallel to the piety side.

## Headline finding (RESOLVED) — fresh-tier fragility / the "threshold twitch"

The original audit found a feel-bug: under a strict threshold, a **freshly-earned tier sat exactly
on its threshold and was lost after ~4 idle days** at ~99% piety, producing notification whiplash
against the §16.7 "you reached Devoted" beat and undercutting the "hard-earned, hard to lose" promise.

**Fix adopted: 5-point tier-down hysteresis.** Tier-*down* now uses a line 5 below tier-*up*, so a
fresh tier survives ~12 idle days of total neglect before the label drops — and the persistent floor
still protects the underlying value two tiers down. One comparison in the tier-eval; whiplash gone.

## Decay isn't always loss — two flavors

"Rate of fall" has two opposite meanings in this system; keep them separate when surfacing:

- **Devotion-loss (bad):** the piety decay above — drifting from a god.
- **Pressure-relief (good):** Breton `WitchcraftExposure` cools toward Hidden at −1/day
  (`DesignReference:1123`); Daedric **stigma** heals at −1/day (`Architecture:1072`). Here passive
  decay is the system *forgiving* you over time. These should never read as "you're losing faith."

## Uniformity + sanctioned exceptions

Standard decay is identical for every ordinary deity. The deliberate departures (mirror of the
piety exceptions):

| System | Rate / grace / floor | Verdict |
|---|---|---|
| Broad worship | 0.1/day (0.2×) | **Sanctioned** — low-maintenance breadth |
| Active patron | 0 | **Sanctioned** — commitment is permanent |
| Curse — vampire (Imperial Divine) | up to **5×** (2.5/day), **bypasses floor → 0** (decided) | **Sanctioned** — true excommunication |
| Curse — werewolf | accelerated decay, **respects floor** (decided) | **Sanctioned** — strain, not severance |
| Reputation (Concordat Enforcer) | Talos decays faster | **Sanctioned** |
| **Argonian Hist** | **1.0/day** (2× std), grace 3, floor **20** (`Argonian:188`,`RewardBudgetLedger:201`) | **Sanctioned** — "always under pressure"; the most decay-exposed identity, by design |
| **Breton DruidicStanding** | **2.0/dawn** after **5** idle, floor **30** (`Breton:151`) | **Sanctioned** but see flag #4 |
| Daedric stigma | −1/day toward 0 | **Relief**, not loss |
| Breton WitchcraftExposure | −1/day toward Hidden | **Relief**, not loss |
| Bosmer GreenPactCompliance | **no passive decay** (act-driven) (`Bosmer:54`) | **Sanctioned** |
| Dunmer ancestor | **no passive decay** (infrastructure ceiling LOCKED) (`Dunmer:61`) | **Sanctioned** |
| Khajiit lunar substrate | never decays severely | **Sanctioned** |

## Decisions

**Locked this pass:**

1. **Tier hysteresis — yes, 5-point buffer.** Fixes fresh-tier fragility + §16.7 whiplash.
2. **Grace tightened 3 → 2 days.** Coverage means engaged gods are tended ~daily, so this is
   invisible to active devotion and only makes *ignored* gods slip a little sooner — the meter
   breathes without becoming a chore (broad worship still 0.1/day).
3. **Vampire curse decay bypasses the floor → 0** (true excommunication); **werewolf respects the
   floor** (strain, not severance).

**Open (need your call):**

4. **Orc + decay.** Orc has no formal patron offer, so Malacath is **not** decay-protected — Orc
   piety drifts at base 0.5/day. *Provisionally applied my lean:* **scale decay by the same
   life-mode multiplier** (Stronghold 0.50, City 0.375, Legion 0.30 per day) so the gain:decay ratio
   is constant across modes ("slow motion" rather than doubly punished — Legion's 43-day climb
   already expresses "hardest life"). Confirm, or pick: decay stays at base 0.5 for all modes
   (Legion strictly hardest/most fragile), or Malacath is decay-exempt like a patron.
5. **DruidicStanding volatility.** At 2.0/dawn to a floor of 30, a Green Way Breton slides 50→30 in
   ~15 idle days — more volatile than standard piety, despite the "gentle" framing. *Lean: intended
   (a covenant needs tending), but confirm — if it should feel gentle, lower the rate to ~1.0 or
   raise the floor.*

## Net answer

The decay model is **healthy and on-goal**: gentle 2-day grace, drift at ~1/7 of gain, fully
recoverable, uniform across gods with a coherent exception set. The one real feel-bug — fresh-tier
fragility — is **fixed** by the adopted 5-point hysteresis. Two forks remain (Orc decay scaling,
Druidic volatility); neither changes a locked constant — both are multiplier-scope choices.
