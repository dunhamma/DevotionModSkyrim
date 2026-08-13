# Existing-matrix multi-tag normalization

## Verdict

Fifteen existing core outcome keys carried different act-tag subsets on
different deity cells even though the cited player outcome was identical. The
normalization authority now gives every cell on each key the complete truthful
act set. It changes tags only: no deity reaction, valence, intensity, magnitude,
runtime key, or core cell count changes.

The merge gate applies
`PDV_QuestReactionMatrix_OutcomeTagNormalization.csv` after canonical duplicate
resolution and fails if a declared outcome key does not exist. This keeps the
historical tranche files as evidence of the decisions made in their original
passes while making the generated `Full.csv` internally uniform.

## Primary rulings

- Oath/service, proving-combat, Daedric service/artifact, mercy/protection, and
  assassination/deceit pairs were normalized only where the same direct outcome
  text established both acts.
- DB06's isolated `sow_chaos_madness` label was not propagated. Killing Gaius
  Maro under contract and planting the incriminating letter directly establish
  assassination, treacherous murder, and deceit; generic chaos was a
  deity-specific gloss rather than a separate player act.
- Normalization is not permission to generate new deity cells. Cross-generation
  remains a reviewed candidate slate and the standing theology-stretch and
  double-credit rejection rules still apply.

## Cross-generation adjudication

The bounded pass crossed only the 15 normalized outcome keys. It produced **45
candidates and three conflicts**. Primary review kept **zero** new cells and
dropped all 45 candidates; all three conflicts were also dropped. This is the
intended result for a consistency tranche: normalizing truthful acts does not
turn those tags into an automatic coverage expansion.

| outcome | candidates | ruling |
|---|---:|---|
| `CW01B|1` | 3 | The Ice Wraith trial is already broadly represented. Trinimac and Alkosh have explicit prior double-credit/theology-stretch rulings; Dagon is a generic combat echo. |
| `DA01|100` | 2 | Generic anti-Daedra responses would double-credit an already resolved Azura branch. |
| `DA03|200` | 4 | Mercy, oath, and generic anti-Daedra echoes do not outrank the direct Barbas/Vile resolution already represented. |
| `DA04|100` | 1 | Xarxes's generic disciplined-study approval is morally conflicted by the forbidden-knowledge act and Oghma Infinium service. |
| `DA05|100` | 3 | Service to Hircine and acquisition of his artifact dominate generic hunt and anti-Daedra matches. |
| `DA05|105` | 1 | Syrabane's generic protection match adds no distinct theological ground. |
| `DA07|150` | 1 | Kyne's generic mercy echo is weaker than the directly represented spare/reject-Dagon readings. |
| `DA08|60` | 2 | Mephala service controls; generic secrecy and anti-Daedra matches do not justify another Prince lane. |
| `DA09|500` | 4 | Meridia service and the direct undead-cleansing gods control; generic anti-Daedra, nature, and cure-profile echoes are stretched. |
| `DA11|250` | 1 | Syrabane's generic protection echo adds no distinct theological ground. |
| `DB06|200` | 4 | The Dark Brotherhood contract arc is already densely represented; these are repeat murder-profile matches. |
| `DB09|50` | 4 | Same repeated Brotherhood murder-profile match; no new ground. |
| `DB10|20` | 7 | Generic combat expansion is capped, and the sanctuary is not every culture's literal kin/home. |
| `DB11|70` | 8 | The Brotherhood finale is already represented; more generic murder approvals would be coverage farming. |

The three conflicts were Akatosh on `DA03|200` and Akatosh/Auri-El on
`DA04|100`. In each case the normalized outcome truthfully contains both the
profile's approval and disapproval trigger. Neither side is promoted: the
direct Prince-service context is already covered by stronger, less ambiguous
cells.

## Paired-equity baseline and delta

Core plus T13-T15 remains **2,361 cells**. The corrected tags remove two false
open Akatosh-cluster gaps that had been inferred from DB06's isolated
`sow_chaos_madness` gloss. The composite therefore moves from **116 open / 99
waived** to **114 open / 99 waived**. No new gap is introduced; the audit's
nonzero exit is inherited baseline debt.

## Proof boundary

This is source/merge consistency proof only. It does not add content, change
runtime routing, clear any existing `RUNTIME-VERIFY` debt, or promote support.
