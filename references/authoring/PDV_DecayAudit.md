# Decay Audit — the rates of fall

Mirror of `PDV_PietyPaceBalancingTable.md` / `PDV_SignalDensityAudit.md`. Piety asked *how long
to rise to each tier, and is it uniform?* Decay asks: **how long to fall (lose a tier / hit the
floor) if you stop, is it uniform across gods, and does it honor the locked design goal —
"relationship drift that is slow and recoverable, not a daily servicing loop"** (`PDV_Architecture_v3.md:1353`)?

## The constants (locked, §15)

| Constant | Value | |
|---|---|---|
| `DECAY_PER_DAY` | **0.5/day** | after grace |
| `DECAY_GRACE_DAYS` | **3** | any qualifying event resets it |
| `BROAD_WORSHIP_DECAY_MULTIPLIER` | **0.2×** → 0.1/day | broad-capped gods |
| Active patron | **skipped** (0) | your chosen patron never passively decays |
| Tier floors (persistent, `PDV.PassiveDecayFloor`) | Devoted→**50**, Faithful→**25**, Observant→**0** | highest tier ever reached locks the floor |
| Curse multiplier | e.g. **5×** (Vampire Imperial Divine) | §15.3 |
| Reputation multiplier | e.g. Concordat Enforcer decays Talos faster | §15.3 |

Formula: idle days to lose **X** piety = `grace + X / rate`.

## Standard decay calendar (focused deity, base rate)

Two very different numbers, and the gap between them is the headline finding:

| From (value) | Floor | Lose the **tier label** (fresh, at threshold) | Lose the label (with +10 buffer) | **Slide to the floor** (full neglect) |
|---|---|---|---|---|
| Devoted 85 | 50 | **~4 idle days** | ~23 days | **73 days** |
| Faithful 50 | 25 | ~4 idle days | ~23 days | **53 days** |
| Observant 25 | 0 | ~4 idle days | ~23 days | **53 days** |

**Broad worship (0.1/day):** 5× slower — lose a fresh label in ~8 idle days; sliding Faithful→25
takes **~253 idle days** (effectively never). Broad worship is a genuinely low-maintenance lane.

**Active patron:** never decays. Your committed patron is permanent.

## Health metrics — does it meet the design goal?

- **"Not a daily servicing loop": PASS, strongly.** Grace is 3 days, so worshipping *once every
  three days* prevents decay entirely. Even total neglect costs only 0.5/day. There is no treadmill.
- **"Slow and recoverable": PASS.** Decay (0.5/day) is **one-fifth** of the default gain (2.5/day),
  so worship outpaces drift 5:1 — ten idle days lose 3.5 piety, recovered in ~1.4 active days. A
  lapse is a gentle nudge, not a setback.
- **Uniform across gods by construction**, with a sanctioned-exception catalogue (below), exactly
  parallel to the piety side.

## Headline finding — fresh-tier fragility (the "threshold twitch")

The two columns above expose the issue: a **freshly-earned tier sits exactly on its threshold and
is lost after ~4 idle days**, even though piety is still ~99% intact and a single act restores it.
A player who gets the "you reached Devoted" beat (§16.7), then takes a 4-day break, gets a "you've
slipped from Devoted" beat — while sitting at 84.5/85. That is notification whiplash and it makes a
hard-won tier feel cheap, directly undercutting the "hard-earned, hard to lose" promise the floor
logic is *trying* to make.

The persistent floor already protects the **value** (a Devoted player can't fall below 50), but the
**tier label** still drops a full tier on the first tick below threshold.

**Recommendation — add tier hysteresis.** Tier-*down* should use a line below tier-*up*: you don't
lose a tier until piety falls a buffer below the threshold (recommend **5 points**, or "until it
reaches the locked floor"). This makes a just-earned tier robust, kills the whiplash against §16.7,
and costs one comparison in the tier-eval. This is the decay audit's primary design recommendation.

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
| Curse (Vampire Imperial Divine) | up to **5×** (2.5/day), still floored | **Sanctioned** but see flag #2 |
| Reputation (Concordat Enforcer) | Talos decays faster | **Sanctioned** |
| **Argonian Hist** | **1.0/day** (2× std), grace 3, floor **20** (`Argonian:188`,`RewardBudgetLedger:201`) | **Sanctioned** — "always under pressure"; the most decay-exposed identity, by design |
| **Breton DruidicStanding** | **2.0/dawn** after **5** idle, floor **30** (`Breton:151`) | **Sanctioned** but see flag #4 |
| Daedric stigma | −1/day toward 0 | **Relief**, not loss |
| Breton WitchcraftExposure | −1/day toward Hidden | **Relief**, not loss |
| Bosmer GreenPactCompliance | **no passive decay** (act-driven) (`Bosmer:54`) | **Sanctioned** |
| Dunmer ancestor | **no passive decay** (infrastructure ceiling LOCKED) (`Dunmer:61`) | **Sanctioned** |
| Khajiit lunar substrate | never decays severely | **Sanctioned** |

## Open design questions (decisions for you)

These are genuine forks the audit surfaces; my lean noted, none blocking.

1. **Tier hysteresis (recommend: yes, 5-point buffer).** Fixes fresh-tier fragility + §16.7 whiplash.

2. **Should curse-state decay bypass the protective floor?** Today a vampire Imperial decays fast
   (2.5/day) but still stops at the Faithful floor (50). Lore-wise, vampirism is *excommunication* —
   being cut from the Divines. If the curse is meant to genuinely sever the relationship, curse
   decay should **ignore `PassiveDecayFloor`** and be able to strip piety to 0. *Lean: yes for
   excommunication-class curses (vampire), no for werewolf (strain, not severance).*

3. **Orc + decay — the big one.** Orc has no formal patron offer, so Malacath is **not** an active
   patron and is **not** decay-protected — Orc piety drifts at base 0.5/day. Two sub-questions:
   - Does the Orc life-mode multiplier (1.00/0.75/0.60) apply to **decay** as well as gain? If gain
     is scaled but decay isn't, Legion Orc both climbs slowest (1.5/day) **and** loses at full rate
     (0.5/day) — a 3:1 ratio vs Stronghold's 5:1, i.e. doubly fragile. *Lean: scale decay by the
     same multiplier so the ratio is constant ("slow motion" rather than "doubly punished"); the
     57-day climb already expresses "hardest life."*
   - Or: should Malacath get implicit decay protection as the Orc's sole, permanent god? *Lean: no —
     "Malacath observes the life lived," so ceasing to live the code is genuine drift; decay is
     on-theme. Keep Orc decaying, just at the mode-scaled rate.*

4. **DruidicStanding volatility.** At 2.0/dawn to a floor of 30, a Green Way Breton slides 50→30 in
   ~15 idle days — ~3.5× more volatile than standard piety (53 days for a comparable drop), despite
   the "gentle" framing. *Lean: intended (a covenant needs active tending), but confirm — if it
   should feel gentle, either lower the rate to ~1.0 or raise the floor.*

## Net answer

The decay model is **healthy and on-goal**: gentle 3-day grace, drift at 1/5 of gain, fully
recoverable, uniform across gods with a coherent exception set. One real feel-bug — **fresh-tier
fragility** — wants a hysteresis fix, and three smaller forks (curse-floor bypass, Orc decay
scaling, Druidic volatility) want an explicit decision rather than an accidental default. None
changes the locked constants; all are tier-eval / multiplier-scope choices.
