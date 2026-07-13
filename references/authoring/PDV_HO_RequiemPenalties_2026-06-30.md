# PDV_HO_RequiemPenalties -- Requiem felt-penalty closeout

**Created:** 2026-06-30
**Implemented:** 2026-06-30
**Track:** ESP-record + reward-spec work (parallel; NOT serialized on
`PDV__ManagerQuest.psc` -- spell editorIds are unchanged, so no manager edit).
**Status:** Built/readback clean. In-game Requiem HP-bar/manual proof remains
open in `PDV_InGameTestingNeeded_Runbook.md`.
**Provenance:** `PDV_RequiemSmokeTest_Tracker.md`,
`PDV_RequiemRegenConversion_Plan.md`, the 2026-06-21 ruling, and the
2026-06-30 owner correction preserving Imperial civic neglect as disease
resistance.

---

## Why

Requiem zeroes natural health regeneration. A `HealRateMult` PENALTY (negative
"Health Regeneration -X%") is therefore SWALLOWED -- it changes nothing the
player feels, because there is no regen to reduce. This is the same root cause as
the positive heal conversion (author felt health as a flat/scalar Health effect,
not a rate), inverted for penalties.

Fix: re-author each truly swallowed penalty as a felt **negative Fortify-Health**
(lowers maximum Health), mirroring the positive conversion -- a new `_Health`
MGEF, the existing spell rewired to it, the old regen MGEF orphaned.

Positive-reward Requiem conversion is already COMPLETE across all 10 races. These
three converted penalties were the remaining active swallowed `HealRateMult`
penalties. Imperial is intentionally not part of that conversion.

**UPDATE 2026-07-13:** the positive-reward conversion this doc references was
HealRateMult-only; on 2026-07-13 the `MagickaRateMult`/`StaminaRateMult` positive
reward buffs (all 10 races + Daedric) were ALSO converted to flat Fortify Magicka/
Stamina pool. Positive-reward conversion now spans Health AND M/S pools. Authority:
`PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`.

---

## Correction Applied

The original queue text listed four Health conversions, including Imperial
"Divines Grow Distant." Live/spec review corrected that scope: Imperial civic
neglect was already owner-ruled as a felt civic-lapse penalty and remains
`PDV_MGEF_Neglect_Imperial_Restoration` / `ResistDisease -5`. Future agents
should fail closed if an Imperial `_Health` neglect effect appears.

---

## Implemented Work -- 3 converted effects plus Imperial preservation

Each converted row replaces the old regen penalty with a felt negative
Fortify-Health MGEF, rewires the existing spell, and leaves the old regen MGEF
orphaned. Magnitudes are PROVISIONAL until the in-game HP-bar smoke tunes them.

| # | Penalty | Spec file -> entry | Current MGEF editorId | actorValue | magnitude |
|---|---|---|---|---|---|
| 1 | Argonian "Hist Distant" | `PDV_ArgonianRewardRecords.spec.json` -> `neglect.effects[0]` | `PDV_MGEF_Neglect_ArgonianHist_Health` | Health | -10 |
| 2 | Breton "Tradition Grows Distant" | `PDV_BretonRewardRecords.spec.json` -> `neglect.effects[0]` | `PDV_MGEF_Neglect_Breton_Health` | Health | -10 |
| 3 | Breton "Cast Out" (excommunication) | `PDV_BretonRewardRecords.spec.json` -> `creedViolationLoss.excommunication.effects[0]` | `PDV_SPEL_CreedLoss_Breton_Excommunication_MGEF_Health` | Health | -15 |
| 4 | Imperial "Divines Grow Distant" | `PDV_ImperialRewardRecords.spec.json` -> neglect | PRESERVED: `PDV_MGEF_Neglect_Imperial_Restoration` | ResistDisease | -5 |

Converted copy now uses `"Maximum Health -Y"` wording. Imperial copy remains
disease-resistance based.

---

## Procedure Used

1. Edited the Argonian and Breton reward-spec entries above.
2. Ran each affected race through dry-run and live reward authoring:
   ```
   dotnet run --project tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --dry-run --rewards-spec references\authoring\PDV_ArgonianRewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
   dotnet run --project tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --rewards-spec references\authoring\PDV_ArgonianRewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
   dotnet run --project tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --dry-run --rewards-spec references\authoring\PDV_BretonRewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
   dotnet run --project tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --rewards-spec references\authoring\PDV_BretonRewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
   ```
3. Refreshed SEQ after the ESP write.
4. Added `tools/pdv_requiem_penalty_audit.mjs` as the repeatable closeout gate.

---

## Out of scope -- do NOT touch (2026-06-21 ruling)

- Stamina/Magicka-regen neglect effects (Kyne, Khajiit, Bosmer, Dunmer, Altmer):
  partly-felt under Requiem; optional review only, not this build.
  **SUPERSEDED 2026-07-13:** Altmer/Dunmer (Magicka) + Bosmer/Khajiit (Stamina)
  neglect and Breton `DruidicForkBetrayal` creed-loss WERE converted to mild
  negative Fortify Magicka/Stamina pool (neglect -10, creed-loss -15) per
  `PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`. Kyne's neglect is
  a Nord Kyne effect handled with the Nord neglect set. Historical text kept for
  provenance.
- Already-felt DamageResist/ResistMagic neglect (Orc, Redguard): leave as-is.
- The ~24 orphaned positive `_HealRateMult` MGEFs: separate optional ESP-tidiness
  prune, not this build.

---

## Verify

1. `node .\tools\pdv_requiem_penalty_audit.mjs` -> `PASS=44`.
2. Per-race reward readback for Argonian, Breton, and Imperial -> PASS.
3. houseCARL on `Devotion Dev` confirmed the three new Health MGEFs, Imperial
   `ResistDisease -5`, and zero spell refs to the three old regen MGEFs.
4. `node .\tools\pdv_phase2_reward_readback_audit.mjs` -> `PASS=1325 WARN=0 FAIL=0`.
5. `node .\tools\pdv_integrity_harness.mjs` -> PASS.
6. `node .\tools\pdv_verify.mjs` -> `FAIL=0`, with only the existing medallion
   glyph fallback warning.

Magnitudes are PROVISIONAL. The load-bearing FELT proof is the in-game HP-bar
smoke (a Requiem-list health bar visibly drops under the penalty) -- that is
play-gated and tracked separately in `PDV_RequiemSmokeTest_Tracker.md` Track B,
not part of this build's acceptance.

---

## Tracking

Closes the "requiem penalties" backend/readback build remainder on the 1.0
readiness board. The Requiem front is not gameplay-proven until the play-gated
HP-bar smoke in `PDV_InGameTestingNeeded_Runbook.md` records Active Effects,
`player.getav Health`, HP-bar movement, and manual magnitude feel.
