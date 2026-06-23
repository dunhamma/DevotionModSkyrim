# Thin-Prince Part D Faucets — Codex Handoff (2026-06-23)

**Mission:** Build the **renewable signal axis (Part D faucets)** for the thinnest Daedric Princes,
so the worship layer reaches floor parity with the patron deities. Most faucets are **already
designed** in `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` but **not
built**; one Prince (**Molag Bal**) has no faucet at all and needs design.

**Floor context (prince floor = 4 types / 2 renewable):**
- **2/4 Princes** (quest-reaction + a *designed* faucet, needs BUILDING + likely a 2nd renewable):
  Namira, Vaermina, Peryite, Sanguine, Clavicus Vile, Hermaeus Mora (+ Dibella as a god).
- **1/4 Princes** (quest-reaction only — no faucet, no day-to-day): **Molag Bal**, Hircine, Nocturnal,
  Meridia, Sheogorath, Mehrunes Dagon. These need a faucet **designed** (mirror the artifact-use
  pattern) before building.

## The faucet recipe (build spec is the CSV)

Each faucet row's `trigger_detection` column **is the build spec**. The pattern:
**detection hook → Part D faucet act → `AwardPiety(prince, …)` with the row's `anti_farm_cap`
(1/dawn).** First, **trace the existing faucet runtime**: `pdv_quest_matrix_compile.mjs` already
embeds `faucetForms.<Prince>.<act>` (e.g. `faucetForms.Namira.cannibalism`) into the runtime JSON —
confirm how that JSON is consumed and whether a faucet dispatcher already exists, so you wire the
*detection* into the existing path rather than a parallel one.

Designed hooks to build (from the CSV, `GOOD`/`MEDIUM`):
- **Namira** — Ring of Namira "Feed" lesser-power MGEF fires (corpse-feed); `OnObjectEquipped` of a
  curated human-flesh/heart FormList. Share one once/dawn cannibalism cap (don't double-bank).
- **Vaermina** — `OnSpellCast` of the Skull of Corruption.
- **Peryite** — afflicted-state poll (any uncured disease MGEF → small tick; curing does NOT score);
  Block event while Spellbreaker is equipped.
- **Sanguine** — `OnObjectEquipped` of a curated alcohol (mead/ale/wine) FormList; Sanguine Rose cast.
- **Clavicus Vile** — `OnObjectEquipped` of the Masque; quest persuade-success fragments (deferred).
- **Hermaeus Mora** — Black Book `OnRead` (COORDINATE: pick BookRead OR quest-stage, don't double).

## Design needed — the 1/4 Princes (artifact-use pattern)

No faucet exists. Mirror the "use the Prince's artifact = light ongoing service" pattern:
- **Molag Bal** — *(the one true gap; domination has no clean ambient hook)*. Recommended: the
  **Mace of Molag Bal**'s soul-trap/paralyze effect on hit (an MGEF on the weapon's enchantment) =
  "enslaving souls for the Lord," 1/dawn. Verify the Mace's MGEF via houseCARL.
- **Hircine** — beast-form transformation / a curated hunt-kill in beast form (reuse existing
  lycanthropy hooks where possible).
- **Nocturnal** — Skeleton Key possessed + a successful theft, or Nightingale-state act.
- **Meridia** — Dawnbreaker's undead-burst MGEF on hit (anti-undead service).
- **Sheogorath** — `OnSpellCast` of the Wabbajack.
- **Mehrunes Dagon** — Mehrunes' Razor instant-kill MGEF proc.

Each: design the row (deity, act, trigger_detection, act_tag, valence `+`, intensity, magnitude
`small`, `anti_farm_cap 1/dawn`, buildability), **add it to the Part D CSV**, recompile
(`pdv_quest_matrix_compile.mjs`), then build the hook.

## Prove the recipe first, then fan out
Proving case: **Namira** (designed, `GOOD`) end-to-end + **Molag Bal** (the design case). Re-audit,
then the rest. Where a Prince stays under 4/4 after one faucet, add lore-supported **day-to-day
likes-dislikes** rows (`PDV_DeityLikesDislikes.csv` + regen + VERSION bump) for the 2nd renewable.

## Acceptance
- Floor audit: each built Prince shows `faucet` (and/or `day-to-day`) as **wired_end_to_end**;
  verdict moves toward PASS. E2E gate + curated-parity check GREEN. Compile 0/0, verify FAIL=0;
  quest-matrix recompiled.
- In-game (server up): perform the act → confirm one piety trace per the 1/dawn cap; performing it
  again same day does not double-bank.

## Hand-back
Updated Part D CSV (+ Molag Bal/1-4 designs) + recompiled matrix JSON, the new detection hooks/MGEFs/
FormLists (houseCARL), and the floor ledger showing the Princes' renewable count up. Claude reviews
the Molag Bal + 1/4 designs (the judgment pieces).

## Model / dependency
- Runtime tracing + hook wiring → **Codex** (touches Papyrus + ESP MGEF/FormList creation, needs the
  server). Faucet *design* for the 1/4 Princes → flag to Claude/owner.
- Files: `references/authoring/PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv`,
  `tools/pdv_quest_matrix_compile.mjs`, `PDV_DeityLikesDislikes.csv` + `tools/pdv_likesdislikes_gen.mjs`,
  the Daedric record tooling (`tools/pdv-daedric-author`), `PDV__ManagerQuest.psc` faucet path.
