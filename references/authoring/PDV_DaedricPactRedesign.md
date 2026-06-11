# PDV Daedric Pact Redesign — Exclusivity + High-Stakes Effects

**Created:** 2026-06-11
**Status:** Implemented in source + live ESP; in-game proof pending (test on a FRESH save).
**Origin:** Beta-feel review — the force-Seeker Active Effects snapshot showed all 16
Princes' boon+price stacking, and the effects were pegged to the same magnitude band
as the Aedra god tiers (so a pact read no sharper than ordinary worship).

## Locked decisions

1. **One active Daedric pact at a time — HARD SWITCH.** Committing to / advancing a
   Prince makes it the single active pact and grants its boon+price; the previously
   active Prince's effects switch OFF while its piety/tier/commitment are preserved.
   Re-engaging a dormant committed Prince switches back. Never more than two live
   Daedric effects (one boon + one price).
2. **HIGH-STAKES effects (~2x the god tiers).** A real Faustian bargain: a build-defining
   boon and a price that genuinely bites, because a player only ever feels one pact.

## Magnitude scheme (by effect type)

Aedra god tiers are ~`5/8/12` boon and a trivial `−3/−5/−8` price. Daedric pacts run:

| | Seeker | Devoted | Champion |
|---|---|---|---|
| Boon — skill (OneHanded, Sneak, Speechcraft, Illusion…) | +10 | +18 | +25 |
| Boon — %rate/resist (MagickaRate, DamageResist, ResistMagic…) | +15 | +25 | +35 |
| Price — % (HealRate, StaminaRate, MagickaRate…) | −10 | −20 | −30 |
| Price — skill (Speechcraft, Illusion, Restoration…) | −10 | −18 | −25 |

Source of truth: `spellPacket()` in `tools/pdv_generate_daedric_contract.mjs`
(`SKILL_AVS` set decides the band). Regen → `PDV_DaedricPrinceRecordContracts.json`
→ `pdv-daedric-author` writes the SPELL/MGEF magnitudes to the framework ESP
(`ConfigureSpell` rewrites magnitudes every run). Verified live: Boethiah Champion
boon DamageResist = 35.

## Hard-switch mechanism (self-contained, no path→manager coupling)

`PDV_DaedricPathBase`:
- `PDV.Daedric.ActivePact` (StorageUtil form) = the one active pact's deity form.
- `PDV.Daedric.LivePactSpells` (StorageUtil form-list) = the spells the active pact
  granted, so the next activation can strip them without a reference to the old path.
- `MakeActiveDaedricPact()` — strips whatever pact spells are live (any Prince), grants
  this Prince's boon+price for its tier (`SyncPatronBoonsToTier` + `SyncDaedricContractToTier`),
  records them. Idempotent.
- `OnTierChange` — `newTier > 0` → `MakeActiveDaedricPact`; lapse-to-0 of the active pact
  → strip + clear the pointer.

`PDV__ManagerQuest.HandleDaedricPrinceSignal` — after the signal, if the Prince has real
tier and isn't already active, `MakeActiveDaedricPact()` (covers switch-back on re-signal
without a tier change; MCM force-tier and organic tier crossings are covered by OnTierChange).

**Curse separation:** the werewolf/vampire curse (Hircine/Molag Bal) is NOT a pact spell,
so switching pacts does not touch it — the curse persists regardless of the active pact.

## Save migration (implemented)

The live-spell tracking is new, so saves that already stacked Daedric boon/price spells
(pre-this-change) would otherwise keep those untracked spells. `MigrateDaedricPactsIfNeeded()`
in `PDV__ManagerQuest` handles it, version-gated by `PDV.Daedric.PactVersion`
(`DAEDRIC_PACT_VERSION = 1`): on first load after the update it iterates
`PDV_FLST_DaedricPaths_All`, calls `StripPactSpells()` on every path (removes that path's
boon+price from the player), clears the live-spell list + active-pact pointer, then
re-establishes a single active pact = the most-advanced committed Prince. Runs from both
`OnInit` (new game) and the periodic maintenance block (existing saves on load). Curse
spells are not pact spells and are untouched. Compiled 0/0.

So old saves self-heal to one active pact on load; a fresh save is still the cleanest test.

## In-game proof plan (closes stackLegibility, reshapes activeEffects)

On a FRESH save:
1. Commit Prince A (MCM force Seeker/Champion) → A's boon+price in Active Effects, sharp.
2. Commit Prince B → A's boon+price DROP, B's apply. Only two Daedric effects live.
3. Re-engage A (MCM force / route) → switches back; B's drop, A's return.
4. Hircine/Molag: enter the curse with the path active, switch pacts → curse persists,
   only the favor boon/price switches.
5. Record `stackLegibility` (now one-at-a-time) and refresh `activeEffects` magnitudes.
