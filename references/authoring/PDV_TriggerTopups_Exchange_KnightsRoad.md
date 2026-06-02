# Trigger Top-Ups — Bosmer Exchange (Z'en) & Breton Knight's Road

Closes the two density gaps from `PDV_SignalDensityAudit.md`. Policy (decided): **proxies
for the floor** — reliable behavioral hooks carry the pace; curated intent hooks stay
as bonus milestones. Budget: each path's new family must reach **+1.5/day** (Class B, +0.5,
daily cap 1.5) so that floor (prayer/shrine +1.0) + family = one full default day.

> **Scale note:** all values below are **raw** (pre-`GAIN_RATE_SCALE`). The global ×1.32 in
> ProcessDawn lifts raw `floor 1.0 + family 1.5 = 2.5` to the **3.3/day** effective calendar
> automatically — no per-value change needed here (`PDV_BalancingImplementationHandoff.md` Task 1).

## Detection toolkit (what we may hook)

Per `PDV_Architecture_v3.md:240-308`: Story-Manager receivers (Kill Actor w/ victim-faction,
Add Item, Increase Skill, Crime Gold), player-alias events, SKSE/PO3 (`RegisterForMenu`,
sneak-attack flag), and curated dialogue/quest `Adjust(points, reason)` calls. Intent-laden
virtue ("fairness", "mercy") is **not** cheaply detectable, hence the proxy policy.

---

## A. Bosmer — The Exchange (Z'en): the **Reciprocity** family

**Theology.** Z'en is balanced exchange — the reciprocal cycle of *producing* honestly and
*trading/paying* honestly. Distinct from Malacath's labor-as-proof-of-strength: Z'en scores the
**exchange**, not the toil. The family models the full cycle so it fires for every build, on
both town days and wilderness days.

**Floor family** — `PDV_FavorFamily_ZenReciprocity`, Class B (+0.5), **shared daily cap 1.5**,
per-signal cooldown ~1 game-hour:

| # | Hook | Detection | Fires on |
|---|------|-----------|----------|
| Z1 | **Exchange** — a completed market transaction (buy or sell), gold paid for training/services, or a fine/bounty settled | `RegisterForMenu("BarterMenu"/"Training Menu")` + gold-delta on menu close; Crime-Gold node for fines. Requires **non-zero gold movement** (an empty menu open scores nothing). | Town / vendor days |
| Z2 | **Production** — acquiring sellable goods by your own labor: ore mined, firewood chopped, ingredients/pelts gathered, an item crafted | Add-Item SM (ore/ingot/firewood/pelt/ingredient keywords) + Increase-Skill (smithing/alchemy/enchanting). Craft gated on **skill-XP gained or per-recipe cooldown** (no re-temper spam). | Wilderness / maker days |

Both hooks feed the one shared family keyword and the single 1.5/day cap, so Z1+Z2 together
guarantee the floor regardless of playstyle without letting either be farmed.

**Milestone (retained, Class D +5, one-shot/source).** The existing quest-gated
proportionate-justice / debt-settled / Exchange-path beats stay as bonus punctuation.

**Anti-farm.** Shared family cap (1.5/day); per-signal cooldown; transaction requires real gold
movement; production requires real skill-XP or a fresh recipe. Daily caps already in the schema
prevent a buy/sell loop from exceeding one day's normal contribution.

---

## B. Breton — Knight's Road: the **Justice** family

**Theology.** Chivalry — protect the weak, face your foe openly. The reliable daily hook is a
*combined* condition so it reads as knightly justice, not generic combat or assassination.

**Floor hook** — `PDV_FavorFamily_KnightJustice`, Class B (+0.5), **daily cap 1.5**:

| # | Hook | Detection | Fires on |
|---|------|-----------|----------|
| K1 | **Defend the road** — defeat a predatory-faction enemy **without a stealth-kill opener** | Kill-Actor SM; victim faction ∈ predatory set (`BanditFaction`, `ForswornFaction`; extensible); AND the killing engagement was **not** a sneak attack (`isSneakAttack` false / `player.IsSneaking()` false at kill). | Adventuring days |

Both conditions matter: the **predatory-faction gate** makes it *protection of travelers/villages*
(excludes civilians, guards, wildlife); the **no-stealth-opener gate** makes it *honorable arms*
(the dishonor is the ambush, not the distance — an honest arrow at range still qualifies). One
event, one +0.5, not two.

**Flavor toppers (bonus, not floor)** — share the cap:

| # | Hook | Detection | Note |
|---|------|-----------|------|
| K2 | **Charity & aid** — give to a beggar; complete a favor declining its reward | Curated vanilla beggar-dialogue `Adjust`; quest-resolution `Adjust` on no-reward favors | Sparse; broad-blends to Mara if also worshipped |

**Milestone (retained, Class D +5 / +8 signature).** Knightly mercy/justice quest beats and
shrine-Integrity restoration stay on the existing `KnightlyVowIntegrity` hooks.

**Negative side unchanged.** `KnightlyVowIntegrity` still degrades on Thieves-Guild/Dark-
Brotherhood/unjust acts — this family is only the positive daily side.

**Anti-farm.** Daily cap; sneak-kills excluded (also blocks stealth-archer farming); predatory-
faction gate blocks scoring innocents, guards, or animals.

---

## Coverage check — does each path clear a full day? (raw values; ×1.32 → 3.3 effective)

| Day type | Z'en (Exchange) | Knight's Road |
|----------|-----------------|---------------|
| Adventuring / wilderness | Z2 production → up to 1.5 + prayer 1.0 = **2.5** | K1 predator-kills → cap 1.5 + prayer 1.0 = **2.5** |
| Town / social | Z1 transactions → up to 1.5 + prayer 1.0 = **2.5** | K2 charity + prayer ≈ 1.5; predator-kills 0 → **leans on weekly averaging** (Knight players adventure) |

Daily variance is fine across a multi-week climb. Z'en is robust on both day types; Knight's
Road is strongest on adventuring days (appropriate for a martial tradition) and relies on weekly
averaging for pure-town stretches — acceptable, monitor in playtest.

## Verify on a vanilla save before locking (per mod discipline, `Architecture:307`)

> Procedure: `PDV_TriggerTopups_DetectionProbe_Runbook.md` runs all five as trace-only probes with pass/fail and fallbacks.

1. `RegisterForMenu` + gold-delta on Barter/Training menu close behaves (no double-fire, catches both directions).
2. Sneak-attack flag is readable at the Kill-Actor event for the K1 no-opener gate.
3. Predatory faction EditorIDs (`BanditFaction`, `ForswornFaction`) and whether unique bandit-boss sub-factions inherit them.
4. Crime-Gold / fine-paid node fires for the Z1 fine-settlement signal.
5. Vanilla beggar charity dialogue topic IDs for the K2 curated `Adjust`.

## Integration (per `Architecture:287` "adding an event type")

- Append route IDs to the `PDV_ActionRouter` constants block.
- Z'en: Add-Item/Increase-Skill SM branch + a menu-event handler on the `PDV_PlayerEvents` alias.
- Knight's Road: Kill-Actor victim-faction + sneak-flag branch.
- Register family keywords `PDV_FavorFamily_ZenReciprocity`, `PDV_FavorFamily_KnightJustice`.
- Update the verifier's expected-record set.
- Values map to Class B in `PDV_PietyPaceBalancingTable.md` (+0.5, daily cap 1.5).
