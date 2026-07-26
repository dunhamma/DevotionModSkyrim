# Handoff: Champion Special Powers - Shipped vs Designed (2026-07-18)

## Why this exists

While reworking the Nexus race guides to spotlight each race's "special power,"
the shipped `Devotion.esp` was read record-by-record via houseCARL. The design
authority `references/authoring/PDV_Phase2_CapstoneSignatures.md` promises a
scripted "signature" on every focused Champion tier (a library of procs, auras,
and cheat-deaths, M1-M11). **Most of those signatures do not ship.** What ships
is one near-death power per race that should have one, plus Redguard's death-rite
heal - everything else is a stat-only Champion tier.

The guides now describe **only what ships** (verified), and state plainly where a
race has no active power. That is safe to publish as-is. This handoff is the
open question underneath it: **is stat-only the intended 1.0 state, or should
some designed signatures be built?** Decide per race, then either (a) close the
signature spec as descoped, or (b) build the chosen signatures and update the
guides.

Do not trust the design doc as evidence - it lists signatures that never shipped.
Reproduce every claim against the current ESP + live manager before acting.

## What actually ships (verified 2026-07-18, houseCARL on Anvil / Devotion Dev)

Two delivery mechanisms:

1. **Scripted MGEF on the Champion spell** - a `Archetype.Type = Script` MGEF
   (`HideInUI`) riding on the T3 spell, driven by `PDV_T3DailyLowHealthSaveEffect`
   (`live-source/Scripts/Source/PDV_T3DailyLowHealthSaveEffect.psc`): samples
   `OnHit`/`OnDying`, fires when health <= 20%, once/day (StorageUtil day-key),
   and by default restores to full (or casts a set `HealSpell`).
2. **Manager-cast near-death spell** - routed from
   `PDV__ManagerQuest.HandlePlayerBelowHealthGate` (~L6810), flat
   `RestoreActorValue` (Requiem-proof).

| Race | Power | Mechanism | Record / function | Gate |
|------|-------|-----------|-------------------|------|
| Khajiit | Baan Dar Remembers (cheat-death) | Scripted MGEF | `071502` `PDV_MGEF_Khajiit_BaanDar_T3_AvoidDeath` on SPEL `07109C` | Baan Dar Champion |
| Nord | Shor Remembers (cheat-death) | Scripted MGEF | `071582` `PDV_MGEF_Nord_Shor_T3_AvoidDeath` on SPEL `0711C7` | Shor Champion |
| Redguard | HoonDing Makes Way (cheat-death) | Scripted MGEF | `071584` `PDV_MGEF_Redguard_HoonDing_T3_AvoidDeath` on SPEL `0711A6` | HoonDing Champion |
| Redguard | Tu'whacca death-rite heal (not a save) | Manager | `TryRedguardTuwhaccaDeathRiteHeal` (~L9382), flat Health 30 (Devoted) / 50 (Champion) | Tu'whacca >= Devoted, on a kept death-rite, 1/day |
| Dunmer | The Ancestors Watch (cheat-death) | Scripted MGEF, armed daily | `071613` on SPEL `071614` `PDV_SPEL_Dunmer_AncestorWatch`; armed by home prayer (~L7220), disarmed at dawn `DisarmDunmerAncestorWatch` (~L7238) | Re-earned each day by praying at the ancestral urn/hearth |
| Bosmer | Baan Dar Opens the Gap (cheat-death) | Manager | `TryBosmerBaanDarGap` (~L6824), `PDV_SPEL_BosmerBaanDarGap` | Bandit Road path, in combat, 1/day |
| Argonian | Void near-death surge | Manager | `TryArgonianSithisNearDeathBurst` (~L6847), `PDV_SPEL_ArgonianSithisNearDeathBurst` + flat Stamina 100 | Void focus fully active, Void >= T3, 1/day |
| Orc | The Code Holds (near-death save) | Manager | `TryOrcCodeHolds` (~L6879), `PDV_SPEL_OrcCodeHolds` / `_Devoted`, flat Health 40 / 60 (+Stamina) | Malacath >= Seeker, once per fight (per-combat routing) |

The "one save per race" rule holds. Altmer, Breton, and Imperial ship **no**
active power (stat + recognition only).

## The gap: designed signatures that ship as stat-only

Source: `PDV_Phase2_CapstoneSignatures.md`. Evidence for "not shipped": the
full `Archetype.Type = Script` MGEF inventory of `Devotion.esp` contains only the
four `*_AvoidDeath` effects above (the rest are the Favor system, shrine-prayer
signals, Survey/Observe, and curse prices), and the manager has no `Try*`/`Handle*`
function for these signatures. Each named T3 spell's effects are all plain
`ValueModifier` stat MGEFs.

### LOCKED signatures (agreed 2026-06-07) - highest remediation priority

These were signed off, not left as draft, so the gap is most notable here.

| Race - path | Designed signature (doc) | Ships as |
|-------------|--------------------------|----------|
| Bosmer - Old Contract (Y'ffre) | M1 beast-calm + once/day beast ally; M2 kill-momentum stack + stamina | stat-only |
| Bosmer - Living Story (Y'ffre) | M3 companion heal-rate; M4 proactive rally | stat-only |
| Bosmer - The Exchange (Z'en) | M5 debt-repaid damage ledger | stat-only |
| Khajiit - Khenarthi | M8 travel momentum (sprint stamina + speed ramp) | stat-only |
| Khajiit - Azurah | M9 night magicka + detect-life + ward proc | stat-only |
| Khajiit - Rajhin | M10 thief's-fade (invis on steal/sneak-attack) | stat-only |
| Khajiit - Alkosh | M11 vs-dragon damage + once/day area stagger/slow | stat-only |

(Bosmer Bandit Road and Khajiit Baan Dar - the cheat-deaths from the same
LOCKED sets - DID ship. It is the non-save flavor signatures that did not.)

### DRAFT signatures (pending talk-through) - never locked

Lower expectation; listed for completeness. All ship stat-only unless noted.

- **Imperial** - Akatosh cheat-death; Mara heal-echo (**explicitly retired
  2026-07-06** per the Mara spec note - not a gap); Arkay kill-heal; Stendarr
  aura; Zenithar tithe; Dibella pacify; Julianos ward; Kynareth env; Talos
  momentum. Imperial currently has no save at all.
- **Altmer** - Auri-El cheat-death; Magnus daytime surge; Xarxes study buff.
  Altmer currently has no save at all.
- **Dunmer** - Azura moonshadow; Boethiah duel; Mephala web. (Dunmer's save
  shipped separately as the ancestor home-prayer watch, not on a Reclamation god.)
- **Nord** - Kyne "The Storm Answers"; Tsun "Shield-Thane's Trial"; Stuhn "Just
  Spoils." (Shor's shipped.)
- **Orc** - Stronghold kin-aura; City "Unbroken Alone." (Code Holds shipped, but
  gated on Malacath tier, not on a specific life-mode.)
- **Redguard** - Leki feint; HoonDing knockback. (HoonDing shipped a cheat-death
  instead of the knockback; see discrepancies.)
- **Argonian** - People ally-heal aura. (Void surge shipped.)
- **Breton** - none owed (Breton reuses other gods' signatures by design).

## Discrepancies to rule on (shipped != doc)

1. **Redguard save moved gods.** The doc puts Redguard's one cheat-death on
   **Tu'whacca** ("Keeper of the Far Shores"). Shipped: Tu'whacca has an
   event-driven **heal** (not a save), and the **cheat-death is on HoonDing**
   ("HoonDing Makes Way"). Confirm this is intended; the guide follows the
   shipped reality.
2. **Dunmer save is a daily ritual, not a tier.** "The Ancestors Watch" is armed
   by the home prayer and disarmed at dawn - it is not tied to a Reclamation
   Champion tier. Confirm this is the intended design (guide describes it as such).
3. **Orc save is race-wide, not life-mode-specific.** The doc put Orc's save on
   the Legion life-mode; shipped `TryOrcCodeHolds` gates only on Malacath tier,
   so any focused Orc gets it. Confirm.
4. **Imperial Mara heal retired.** Not a gap - the scripted mercy-on-rest heal was
   deliberately retired 2026-07-06 in favour of a passive ward. Leave retired.

## Recommended decision path

- **Option A - accept stat-only for 1.0 (lowest effort).** The guides are already
  correct. Action: mark `PDV_Phase2_CapstoneSignatures.md` status as "signatures
  descoped to stat + recognition for 1.0 except the shipped near-death set" so it
  stops reading as an open spec, and note it in the untested backlog. No code, no
  guide changes.
- **Option B - build the LOCKED subset (Bosmer x3 + Khajiit x4).** These were
  signed off and are the ones a returning player is most likely to miss. Each
  needs a scripted MGEF or a manager hook, then a guide + central-article update.
  Sequence behind a felt-proof smoke, one signature at a time.
- **Option C - build all, incl. DRAFT.** Large scope; the DRAFT set needs the
  original talk-through (the doc's "Flags for the talk-through" section) resolved
  first, especially cheat-death density and the fiddly detections.

Recommendation: **A or B.** C is a content project, not a fix.

## Guardrails for any remediation

- **One save per race.** Adding a cheat-death to Altmer or Imperial (who have
  none) is fine and would give them their save. Never add a second save to a race
  that already has one (Khajiit, Nord, Redguard, Dunmer, Bosmer, Argonian, Orc).
- **Requiem.** Any heal/sustain must be a flat pool restore, never a rate mult -
  Requiem swallows regen. Follow the Tu'whacca/Orc/Argonian flat-restore pattern;
  the orphaned `PDV_MGEF_Redguard_Tuwhacca_T3_HealRateMult` (carried by no spell)
  is the abandoned rate-based approach - do not revive it.
- **Verify, don't trust.** Reproduce against the current ESP + manager before and
  after any change; spec-declaration is not evidence.
- **Guides.** If any signature is built, update three things: the race article's
  Champion spotlight in `docs/player-guides/races/<Race>.md`, the "Champion
  Special Powers" table in `docs/player-guides/Blessings_and_Penalties.md`, and
  (for Altmer/Breton/Imperial) the "no scripted Champion power" line. Then
  regenerate with `node tools/pdv_guide_bbcode.mjs` and re-run `--check`.

## Reproduction (houseCARL)

- All scripted champion effects: `cross_plugin_query type=MGEF plugins=[Devotion.esp]
  where "Archetype.Type = Script"` - the only `*_T3_AvoidDeath` hits are the four saves.
- Per-race Champion spell effects: `read_record <SPEL> fields=[Effects] depth=3`,
  then resolve each `BaseEffect` (all stat MGEFs = stat-only).
- Manager near-death powers: grep `PDV__ManagerQuest.psc` for
  `HandlePlayerBelowHealthGate`, `Try<Race>...`, `RestoreActorValue("Health"`.
- Doc under review: `references/authoring/PDV_Phase2_CapstoneSignatures.md`.
