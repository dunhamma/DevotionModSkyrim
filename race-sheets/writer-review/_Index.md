# PDV Writer Review -- Index

**Regenerated:** 2026-05-30 via `node tools/pdv_writer_review.mjs`
**Source:** `race-sheets/PDV_RaceContent_Manifest.md`

Per-race writer-review files. Each `<Race>_Review.md` groups every drafted in-game string by the moment in which the player encounters it, with deity tone, voice, char count vs hard cap, and an empty `Edit` column for revisions.

| Race | Rows | Over budget | Moments covered | MD | CSV |
|---|---|---|---|---|---|
| Nord | 112 | - | 14 | [Nord_Review.md](Nord_Review.md) | [Nord_Review.csv](Nord_Review.csv) |
| Orc | 50 | - | 10 | [Orc_Review.md](Orc_Review.md) | [Orc_Review.csv](Orc_Review.csv) |
| Dunmer | 67 | - | 15 | [Dunmer_Review.md](Dunmer_Review.md) | [Dunmer_Review.csv](Dunmer_Review.csv) |
| Altmer | 61 | - | 16 | [Altmer_Review.md](Altmer_Review.md) | [Altmer_Review.csv](Altmer_Review.csv) |
| Khajiit | 52 | - | 15 | [Khajiit_Review.md](Khajiit_Review.md) | [Khajiit_Review.csv](Khajiit_Review.csv) |
| Imperial | 73 | - | 14 | [Imperial_Review.md](Imperial_Review.md) | [Imperial_Review.csv](Imperial_Review.csv) |
| Redguard | 62 | - | 15 | [Redguard_Review.md](Redguard_Review.md) | [Redguard_Review.csv](Redguard_Review.csv) |
| Bosmer | 58 | - | 13 | [Bosmer_Review.md](Bosmer_Review.md) | [Bosmer_Review.csv](Bosmer_Review.csv) |
| Breton | 69 | - | 13 | [Breton_Review.md](Breton_Review.md) | [Breton_Review.csv](Breton_Review.csv) |
| Argonian | 47 | - | 15 | [Argonian_Review.md](Argonian_Review.md) | [Argonian_Review.csv](Argonian_Review.csv) |

## How to use

1. Open the MD for a race to read drafted strings in moment-order with full authoring context (deity tone, voice, char cap).
2. Edit in the right-hand `Edit` column, or open the CSV in a spreadsheet for column sorting / filtering.
3. When happy with a batch of edits, hand-merge them back into `race-sheets/PDV_RaceContent_Manifest.md` against the matching `Slot ID`.
4. Re-run `node tools/pdv_content_verify.mjs` to confirm budget / voice / ASCII still pass.
5. Re-run `node tools/pdv_writer_review.mjs` to regenerate this view from the updated manifest.

**Note.** Regenerating overwrites every `<Race>_Review.md` and `<Race>_Review.csv`. Save your in-progress `Edit` columns before re-running, or do your revising in a copy.