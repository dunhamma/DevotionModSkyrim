# PDV Signal Floor - Tranche10 Quest Matrix - Codex Handoff - 2026-07-09

## What shipped (already done, do not re-author)

- New source tranche `references/authoring/PDV_QuestReactionMatrix_Tranche10_SignalFloor.csv`
  (87 rows) registered in `tools/pdv_quest_tranche_merge.mjs` (one-line list add).
- Regenerated `PDV_QuestReactionMatrix_Full.csv`: 884 -> 971 cells, 90 -> 122
  watched quests, 118 -> 153 quest keys, 45 deities.
- Live StorageUtil JSON regenerated at
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\SKSE\Plugins\StorageUtilData\PlayerDevotion\PDV_QuestReactionMatrix.json`.
- Gate results at ship time: matrix compile --check/--json PASS; adversary check
  PASS (expected thin-Hist warning only); `pdv_verify` 3546 PASS / 0 FAIL / 1
  pre-existing WARN (medallion glyphs); formal-offer check PASS.
- Waiver record: `references/authoring/PDV_DeitySignalFloor_WaiverLedger_2026-07-09.md`
  (deity-level; distinct from the generated per-path `PDV_SignalFloorLedger.md`).

Design intent: every deity toward >=20 positive / >=10 negative combined signals
(quest + likes/dislikes + faucets), thematic-adjacent extrapolation allowed,
count parity NOT forced - shortfalls are waived in the ledger, not padded.

## Proof boundary

Proven: authority rows, tranche merge, generated matrix, live JSON, verifier /
adversary / formal-offer static gates.
NOT proven: in-game runtime route for any new row, Book of Days / Survey /
Prisma surfacing, Active Effects behavior, save/load stack, manual feel.
Do not claim player-ready or beta-feel for any Tranche10 content until the
smoke matrix below passes.

## Re-run gates (any time the tranche changes)

```powershell
node tools/pdv_quest_tranche_merge.mjs
node tools/pdv_quest_matrix_compile.mjs --check --json
node tools/pdv_quest_matrix_compile.mjs --json
node tools/pdv_deity_signal_remap_adversary_check.mjs
node tools/pdv_verify.mjs --json
node tools/pdv_formal_offer_check.mjs --json
```

Expected: 971 cells / 153 keys / 122 watched / 24 faucet acts; adversary PASS
with ONLY the thin-Hist warning; verify 0 FAIL (the 1 WARN is the pre-existing
medallion-glyph fallback).

## In-game smoke matrix (minimum representative set)

Use the debug MCM dev page / setstage; remember `coc` skips Story location
triggers - enter cells via load doors. Prove on a save that has NOT already
completed the target quests.

| # | Deity family | Command | Expect |
|---|---|---|---|
| 1 | Thin Prince negative | `setstage DA11 500` (after 100-path NOT taken) | Namira piety LOSS; Book of Days chronicle; Survey lane correct |
| 2 | Zero-neg Prince positive | `setstage DLC2MQ05 1000` | Hermaeus Mora milestone gain; Molag Bal + Boethiah small gains; Syrabane LOSS (multi-deity fan-out on one stage - key check) |
| 3 | Meridia negative | `setstage DLC1VQ04 200` | Meridia milestone LOSS (necromancy) |
| 4 | Y'ffre positive | `setstage DLC2SV02 200` | Y'ffre gain; Syrabane gain (paired row) |
| 5 | Mortal negative | `setstage DB11 200` | Akatosh/Alkosh/Xarxes losses (Alkosh milestone) alongside existing Sithis gain |
| 6 | Vampire-side branch | `setstage DLC1VQ03Vampire 200` | Molag Bal milestone gain; Meridia/Azura/Arkay/Akatosh losses |
| 7 | Borderline row A | `setstage DA14Start 70` | Sanguine gain fires at all (start-handler quest - if silent, DROP the row) |
| 8 | Borderline row B | `setstage T03 105` | Y'ffre gain (stage accepted via manual FormID path; verify it fires) |
| 9 | Borderline row C | DLC2RRFavor01 organic or `setstage DLC2RRFavor01 200` | Zenithar gain only on REPORT outcome framing |

Per smoke: confirm Book of Days records it, Survey/status lane is right, toast/
Prisma text coherent, no duplicate or stale effect stack after save/load, and
wrong-origin routes stay silent where expected.

## Rejected candidates (do not re-add without new evidence)

- `DA15WabbajackQST` (any stage): quest_filter `Test\` - likely never runs.
- `DLC2TT1b` (A New Debt): completion stages 300/310/320 with no branch
  readback (EXCL_OUTCOME_AMBIGUOUS).
- `FreeformWinterholdCollegeB` (Missing Apprentices): unfinished vanilla
  content, standing exclusion.
- DLC1RH*/RV* radiant hunter/vampire jobs: EXCL_RADIANT_REPEATABLE.
- `DLC2ThirskFFElmusBack`, `DLC2RRFavor05/06/07`: near-duplicate / collectible
  loop / unreadable semantics.

## Follow-up work for Codex

1. **Readback refresh (highest value single item)**: extend
   `tools/pdv_extract_quest_stage_readback.mjs` coverage to include `MS01`,
   `MS02` (Cidhna Mine), `DBDestroy` (Destroy the Dark Brotherhood), and `C05`
   ("Purity"). This unlocks lore-real negatives for Mephala (+2), Nocturnal
   (+1), Sithis (DBDestroy - strongest in the game), Hircine (+2), and deceit
   positives for Clavicus Vile. Then author a small Tranche10 addendum.
2. **Part D faucet hooks** (proposals NOT yet in the faucet CSV to avoid the
   declared-but-not-dispatched gate):
   - Sanguine "Drink skooma": OnObjectEquipped against a curated skooma/
     sleeping-tree-sap ALCH FormList; revel_indulge +C small; SHARE the
     existing once-per-dawn revel cap with the alcohol faucet (one owner per
     dawn, no double-bank).
   - Sheogorath "Fire the Wabbajack": staff-fire OnSpellCast pattern mirroring
     the proven Sanguine Rose sender; serve_a_daedra:sheogorath +S small;
     shares the 1/dawn cap with the existing carry faucet.
   Add rows to `PDV_QuestReactionMatrix_PartD_ThinGodFaucets.csv` ONLY together
   with the hooks, then re-run the full gate chain (faucetActs will go 24 -> 26).
3. **Black Book owner-coordination**: the five `DLC2BlackBook0*Quest` s20 rows
   fan out to Hermaeus Mora / Vaermina / Syrabane. Verify the Mora BookRead
   P2 receiver (if any Black Book is also in a book-read FormList) does not
   double-fire with the quest-stage route - Part D-3 owner rule applies.
4. **Version-pin note**: `LIKES_DISLIKES_VERSION` bumped 14 -> 15 by the
   companion LD handoff; the pins in `tools/pdv_verify.mjs`
   (`EXPECTED_LIKES_DISLIKES_VERSION`) and
   `tools/pdv_deity_signal_remap_adversary_check.mjs` were synced to 15 in the
   same pass (mechanical contract sync, flagged here for review).
