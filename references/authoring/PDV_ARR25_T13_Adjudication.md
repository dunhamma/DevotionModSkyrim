# ARR 2.5 T13 adjudication

## Verdict

T13 is authored as nine per-mod data channels containing **95 cells across 14
outcome keys and 14 watched quests**. M'rissi is deliberately absent and remains
owned by T14. No T13 outcome requires a dialogue/result-script hook ESP.

This is a machine-review verdict, not a support claim. The Divine Crusader
pilgrimage is the only objective-derived outcome: all nine deity cells on
`ccMTYSSE001_Quest|100` retain `RUNTIME-VERIFY`. Every other retained outcome has
direct resolving-stage log evidence from an absolute-path
`housecarl_read_plugin_file` read. Those raw-file reads establish the records in
the named plugin, not the ARR winning record or actual runtime route.

## Source channels

| Channel | cells | outcomes |
|---|---:|---:|
| Calling the Watchmaker | 16 | 1 |
| CC Divine Crusader | 9 | 1 |
| CC Ghosts of the Tribunal | 2 | 1 |
| CC The Cause | 3 | 1 |
| Gift of Saturalia | 19 | 5 |
| Hunt for the Spectre | 6 | 1 |
| Siege at Icemoth | 14 | 2 |
| Taste of Death Addon | 9 | 1 |
| Wyrmstooth | 17 | 1 |
| **Total** | **95** | **14** |

## Cross-generation adjudication

The first T13 cross-generation pass produced 116 candidates from 14 outcomes
against 45 deity profiles. The primary review kept 58 and dropped 58; the
paired-equity pass then added one independently justified Kynareth loss to the
Calling the Watchmaker outcome. A second
pass after the kept cells were written leaves exactly the 58 rejected candidates
and zero conflicts; the generated candidate file is therefore the surviving
rejection slate, not an unaudited queue.

| Outcome | generated | kept | dropped | primary ruling |
|---|---:|---:|---:|---|
| CC The Cause | 20 | 1 | 19 | Keep the directly relevant Akatosh/order reaction; reject generic battle-god and unrelated Prince coverage. |
| Hunt for the Spectre | 4 | 4 | 0 | The explicit Spectre kill supports the four retained hunt/protection/death-order profiles. |
| Font of Memory | 3 | 2 | 1 | Keep Julianos and Magnus knowledge reactions; drop the Vaermina name/realm stretch. |
| Siege at Icemoth | 18 | 9 | 9 | Keep defensible necromancer/undead-army defeat reactions; reject broad combat coverage. |
| Taste of Death Addon | 10 | 7 | 3 | Keep order, lawful-trade, and anti-cult reactions; reject unrelated Prince reach. |
| Saturalia adoption | 1 | 1 | 0 | Keep Dibella's family/community reaction. |
| Saturalia dog | 8 | 2 | 6 | Keep companionship/comfort reactions; reject low-stakes protection stretch. |
| Saturalia laughter | 2 | 0 | 2 | Drop both nature-profile stretches. |
| Saturalia music | 7 | 2 | 5 | Keep aid and craft/learning reactions; reject generic art/name affinity. |
| Saturalia orphanage | 8 | 3 | 5 | Keep mercy, family, and community aid; reject generic generosity coverage. |
| Calling the Watchmaker | 17 | 13 | 4 | Keep explicit cold-murder reactions; reject Dagon, Mephala, Vaermina, and other profiles whose specific conquest, secrecy, or terror conditions are absent. |
| Wyrmstooth | 18 | 14 | 4 | Keep named-dragon/defence/heroic-struggle reactions; reject Auri-El's Alduin/herald-only exception and generic battle expansion. |
| **Cross-generation total** | **116** | **58** | **58** | Theology stretch and double-credit remain the standing rejection rules. The separate paired-equity review adds one retained cell. |

## Explicit source-level exclusions and deferrals

- The Cause's first quest has no proven resolving route and is not authored.
- Ghosts of the Tribunal branches are dropped where the available stage collapses
  opposed choices or would require inventing a Tribunal runtime deity. Trueflame
  keeps only generic master-craft/forge reactions.
- Wyrmstooth repeatable bounties and the repeatable Thalmor job are deferred to a
  renewable, anti-farm lane.
- Gift of Saturalia's umbrella completion is dropped to avoid double-crediting
  the five authored subquests.
- Above All Else exposes no player-resolving semantic evidence and remains
  deferred.
- M'rissi is excluded from T13 and belongs exactly once in T14.

## Paired-equity baseline and delta

The core-only audit refreshes the post-T12 baseline to **116 open / 71 waived**
cluster gaps. The previously committed report's 28-open figure predated the T12
matrix expansion and was stale baseline evidence, not a T13 regression.

The audit now accepts repeated `--append-matrix` inputs plus `--no-write`, so the
nine data channels can be checked in memory without contaminating the core
report. The composite result is **116 open / 81 waived** across 2,225 cells:
the open-gap delta is **zero**. Ten new mechanical pair suggestions were reviewed
and waived with reasons in `PDV_PairedEquityWaivers.csv`. One initially
unexplained gap was accepted instead: Kynareth now shares the stepped-down loss
for Calling the Watchmaker's explicit helpless murder. This leaves no unexplained
T13 paired-equity regression while preserving the locked culture-specific
exceptions (for example, Alkosh's named-dragon rule and the Nine Divines'
Kynareth shrine identity).

## Proof debt

- Assign the Divine Crusader outcome to a tester case that traverses the actual
  nine-shrine pilgrimage and observes stage 100, route delivery, exactly one
  toast, exactly one Book of Days beat, and save/load behavior.
- Route smoke for the other 13 outcome keys is still required before any package
  option is described as runtime-proven.
- Semantic correctness for the inferred pilgrimage cannot be cleared by a
  controlled `setstage` alone.
- Individual options remain machine-verified experimental until equivalent
  per-mod tester evidence exists. The combined ARR 2.5 lane is not supported
  until every included case passes.
