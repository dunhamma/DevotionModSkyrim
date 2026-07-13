# Requiem Magicka/Stamina Regen -> Fortify Pool Conversion - Build Spec (2026-07-13)

**Status:** BUILT + audited 2026-07-13 (source/record/readback/static). In-game
"felt" proof under Requiem owed per race. Supersedes the "Magicka / Stamina regen
-- secondary (leave as-is)" ruling in `PDV_RequiemRegenConversion_Plan.md` lines
218-226. Plan file: `.claude/plans/shimmying-weaving-unicorn.md`.

## Owner decision (2026-07-13)

The June 2026 batch converted only `HealRateMult` (health regen, which Requiem
zeroes) to Fortify Health and deliberately left magicka/stamina regen as-is. Owner
overrode that: magicka/stamina regen should be Requiem-felt too, project-wide, the
same parity the health case got. Conversion target = **flat Fortify max-pool**
(`MagickaRateMult` -> Fortify Magicka, `StaminaRateMult` -> Fortify Stamina). Also
folds in 2 overlooked HealRateMult survivors, converts 2 near-death bursts, and
converts the swallowed regen PENALTIES to felt negatives.

## What converted (89 regen effects total)

| Group | Count | Treatment |
|---|---|---|
| Race always-on Magicka/Stamina regen (9 races) | 57 | -> Fortify pool +15/+25/+40 by tier |
| Argonian substrate HealRateMult survivors (120/160) | 2 | -> Fortify Health +20/+30 (near-water kept) |
| Daedric boons (Sheo Magicka, Hircine Stamina) | 6 | -> Fortify pool +25/+40/+50 Seeker/Devoted/Champion |
| Daedric pact prices | 18 | -> mild negative Fortify (pool -10/-20/-30, health -8/-15/-20) |
| Race neglect/creed-loss regen debuffs | 5 | -> negative Fortify (neglect -10, creed-loss -15) |
| Argonian Sithis near-death burst | 1 | -> scripted RestoreActorValue("Stamina",100) + kept cast |
| (inert) Orc HearthHeld | 1 | NOT converted - only SyncRaceRewardSpell'd False, never granted |
| (skipped) Namira placeholders (mag 0) | 3 | untouched |

Co-effects (ResistMagic/Speech/Alteration/Sneak/Armor/etc.) UNCHANGED throughout;
only the regen effect converted. Magnitudes are PROVISIONAL, in-game tunable.

## Mechanism

- `scratch/requiem_ms_convert.mjs` - the 9-race + Argonian-survivor pass (walks all
  effects, skips mag<=0 and the near-death SPELs; magnitude-based tier map).
- `scratch/requiem_daedric_convert.mjs` - the Daedric contract pass (tier+sign-aware:
  boons positive, prices negative).
- Race penalties: targeted per-record spec edits (the 5 negative-regen debuffs).
- playerFacingText: the convert regex updates the regen phrase in-place, preserving
  event-driven flavor. (Do NOT blanket-run `pdv_reward_desc_regen` - it regenerates
  from always-on effects only and STRIPS hand-written event flavor: Shor/Tu'whacca/
  HoonDing save text, etc. Learned 2026-07-13; reverted and used convert-regex text.)
- Argonian text hand-fixed (the convert regex misses its phrasing).
- ESP authoring: races via `pdv-phase20-race-author`, Daedric via `pdv-daedric-author
  --create-missing`. Fortify pool = ValueModifier/PeakValueModifier on Magicka/
  Stamina (race tool uses PeakValueModifier per its UsesPeakValueModifier list which
  includes Health/Magicka/Stamina; daedric tool uses ValueModifier - both are valid
  felt max-pool on a constant ability).

## Capstone-save guardrail (bit us; document for next regen touch)

`PDV_T3DailyLowHealthSaveEffect` rides ON an MGEF via VMAD. Converting a regen effect
creates a NEW MGEF (new editorId from the AV change) and ORPHANS the old one carrying
the save -> the capstone loses its cheat-death. **Imperial Akatosh T3 and Altmer
AuriEl T3** had their save on the magicka regen MGEF and broke; fixed by re-running
`pdv-phase20-p2-receiver-author --author-capstones` (re-attaches to the current visible
MGEF). Orc/Nord/Redguard/Bosmer/Khajiit capstone saves rode on stable co-effect MGEFs
and survived. ALWAYS re-run `--author-capstones` after any reward re-author and check
the readback "T3 capstone script" rows.

## Audit (2026-07-13, all PASS)

- Reward readback (`pdv_phase2_reward_readback_audit`): PASS=1482 FAIL=0.
- Reward-order lint: PASS (24 reused spells, 0 collisions).
- `pdv_verify`: FAIL=0 WARN=2 (medallion glyph + SEQ freshness, latter refreshed).
- `pdv_prisma_ui_audit`: PASS (90 checks).
- Daedric `--check`: PASS. Per-race `--check-rewards`: PASS.
- houseCARL spot-checks: converted MGEFs are ValueModifier/PeakValueModifier on
  Magicka/Stamina at the mapped magnitude; prices are negative Fortify; co-effects
  intact; capstone saves re-attached.
- Manager compile 0/0 (near-death restore); MCM recompiled (BoD pex freshness).

## Prisma / player text

- app.js: the one hardcoded regen demo string (`daedric_boon` Hircine, ~line 2364)
  updated to the real converted values (Fortify Stamina +25 / Speech -8). All other
  reward magnitudes are live-data-driven, not hardcoded. Cache-bust bumped to
  `regen-fortify-20260713` (both index.html ?v= strings); deployed LF.
- No player-guide docs quote regen magnitudes (swept clean).

## Proof boundary / follow-ups

- **In-game "felt" proof owed per race** (the release gate): on an actual Requiem/
  Authoria list, prime each converted reward and confirm the Magicka/Stamina BAR MAX
  rises by the Fortify amount in Active Effects (stackSnapshot per race). Machine
  gates prove records EXIST, not that Requiem shows them.
- Magnitudes are provisional - tune against Requiem's pool economy in-game.
- Orphaned `_RateMult` MGEFs are harmless dead weight (same as the June health batch);
  optional ESP compaction later.
