# ARR 2.5 T14 adjudication

## Verdict

T14 is authored as five per-mod data channels containing **78 cells across 15
outcome keys and 12 watched quests**. M'rissi appears exactly once in this
tranche. No T14 outcome requires a dialogue/result-script hook ESP.

This is a machine-review verdict, not a support claim. The Largashbur Orc
marriage is the only objective-derived outcome: all three cells on
`dk_ThograMarriageOrc|100` retain `RUNTIME-VERIFY`. The other 14 keys have direct
resolving or failure journal evidence from absolute-path
`housecarl_read_plugin_file` reads. Raw reads establish records in the named
plugin, not ARR winning records or runtime delivery.

## Source channels

| Channel | cells | outcomes | watched quests |
|---|---:|---:|---:|
| Thogra | 24 | 4 | 3 |
| Auri | 3 | 1 | 1 |
| M'rissi | 10 | 3 | 2 |
| Xelzaz | 12 | 2 | 2 |
| Moonpath | 29 | 5 | 4 |
| **Total** | **78** | **15** | **12** |

## Cross-generation adjudication

The first pass produced 87 candidates plus one conflict from 15 outcomes. The
primary review removed three over-broad act aliases (`prove_by_struggle` from
the bare Thogra oath completion, `keep_oath` from the objective-derived Orc
marriage, and `defend_kin_home` from a den any player race may defend). That
eliminated 20 artificial matches before scoring. Of the remaining suggestions,
46 were kept and 22 dropped. The final cross-generation pass therefore leaves
exactly 22 reviewed rejections and zero conflicts.

The sole initial conflict was Sithis on Thogra's betrayal. Sithis's
`break_oath_betray` rejection is explicitly scoped to destroying the Night
Mother's family; Thogra is not that case, so the direct treacherous-murder
approval controls at a stepped-down value.

Standing rejection rules were applied throughout:

- Generic nature-profile matches were rejected where a Bosmer grove pilgrimage
  or Khajiit road did not enact another culture's specific rite.
- Generic murder approvals were rejected without the named Prince's required
  cunning, secrecy, terror, or destruction context.
- M'rissi's enslavement does not grant Sithis or Boethiah credit: neither the
  Night Mother's family nor overthrow of false authority is present.
- Crimson Nirnroot study does not grant Azura prophecy/fate credit or Akatosh
  generic discipline credit.
- Moonpath protection rows were limited to direct settlement/plague evidence;
  broad hero-god and hunt-god echoes were dropped.
- `Sleeping Tree`, `Lost Hist Leaf`, `Quid Pro Quo`, and Dragon Dissection were
  not forced into the matrix where their route or moral common denominator was
  unsafe.

## Paired-equity baseline and delta

Core plus T13 remains **116 open / 81 waived** cluster gaps. Adding T14 initially
reported seven new suggestions. All seven were reviewed and waived with exact
reasons in `PDV_PairedEquityWaivers.csv`: Auri/Khenarthi; Moonpath road/Kyne and
Y'ffre; Moonpath den/Kyne; Thogra oath/Auri-El and Alkosh; and Xelzaz theft/Z'en.
The final composite is **116 open / 88 waived across 2,303 cells**. The open-gap
delta is zero; the absolute 116 is inherited baseline debt, not a T14 pass.

## Explicit source-level exclusions and deferrals

- Thogra betrayal routes at stage 410. Textless fail stage 420 is not authored.
- M'rissi stage 0 is `NO-ROWS`; stage 1 trust text has no controlled act; the
  unresolved good/housekeeper branch remains `DEFER`.
- Xelzaz's Sleeping Tree branches all contain morally mixed killing/destruction.
  Lost Hist Leaf has no text, Quid Pro Quo collapses opposed routes at its
  completion, and Dragon Dissection has no next resolving stage.
- Moonpath's Pahmar acceptance, desert armor acquisition, and dialogue-holder
  quest do not establish player-authored moral acts.

## Proof debt

- Assign all 15 outcome keys to the structured T14 evidence ledger.
- Traverse the Largashbur marriage organically; controlled `setstage` cannot
  clear its objective-derived cultural semantics.
- Observe route marker, exact piety delta, exactly one toast, exactly one Book
  of Days beat, and save/load behavior for every case.
- Individual options remain machine-verified experimental until equivalent
  per-mod evidence exists. The ARR 2.5 combined lane remains unsupported until
  every included T13/T14 and later cumulative case passes.
