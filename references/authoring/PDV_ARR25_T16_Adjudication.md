# ARR 2.5 T16 adjudication

## Verdict

T16 is authored as two per-mod channels containing **58 cells across seven
outcome keys and two watched quests**. Save the Icerunner is data-only. Thieves
Guild Alternative Endings adds a soft-dependent `PDV_PlayerEvents` route seam
but no ESP and no hard master.

This is a machine-review verdict, not a support claim. All seven cases remain
OPEN. Both TGAE alternatives retain `RUNTIME-VERIFY`; controlled `setstage`
cannot establish the mod global or prove that actual quest progression selected
the observed journal branch.

## Source channels

| channel | cells | outcomes | watched quests |
|---|---:|---:|---:|
| Thieves Guild Alternative Endings | 17 | 2 | 1 |
| Save the Icerunner | 41 | 5 | 1 |
| **Total** | **58** | **7** | **2** |

## Cross-generation adjudication

The initial pass produced **53 candidates and zero conflicts**. Primary review
kept seven narrow matches: Stuhn's broken-debt response on the kept-Key ending;
Mara and Z'en on the safely docked Icerunner; Z'en on knowingly joining the
wrecking fraud; Clavicus Vile on the false compact and self-serving betrayal;
and Mara/Kynareth on the lawful arrest and restored passage. The final pass
contains **46 reviewed rejections and zero conflicts**.

The remaining suggestions were dropped under the standing rules:

- Generic protection did not turn freeing Nightingales into every sky, hero,
  knowledge, or culture-specific protection domain.
- Generic oath-breaking approval/disapproval was not spread to Hist, Sithis,
  or Boethiah where their narrow family/authority contexts were absent.
- The mixed kept-Key route did not grant Stendarr credit merely because it also
  rejects Nocturnal; theft and repudiated obligation are integral to the result.
- Protecting a ship did not become generic law/order coverage for every member
  of the time-dragon cluster or every justice god.
- Pirate theft and betrayal were not expanded to every secret, deceit, or
  murder-adjacent Prince.

## Paired-equity baseline and delta

Core plus T13-T15 is **114 open / 99 waived across 2,361 cells**. T16 first
reported seven new same-coin suggestions. All seven were reviewed and waived:
three Kyne suggestions where the direct travel aspects are Kynareth/Khenarthi,
and four Auri-El/Alkosh suggestions where Akatosh's civic-order reading has no
elven ancestry or Khajiiti cosmic-order context.

The cumulative result is **114 open / 106 waived across 2,419 cells**. T16 adds
zero unexplained open-gap delta. The audit's nonzero exit remains inherited
baseline debt.

## Script and package safety

- Repo and live sources matched before the edit. The prior FOMOD combined
  copies of Manager, EventBus, and PlayerEvents were stale; T16 refreshes all
  three source/PEX pairs so installing the compatibility package cannot
  downgrade current Devotion runtime code.
- `Game.GetModByName` guards the optional plugin before `GetFormFromFile`.
- Global 0/missing/absent mod keeps physical stage 200. Global 1 maps to 201;
  globals 2/3 map to 202.
- The same resolver gates the Nocturnal commitment route, preventing a false
  +10 commitment signal on both alternatives.
- The individual TGAE option installs the dependency-complete current
  PlayerEvents/EventBus/Manager source+PEX set and its data channel. Optional
  observers remain dormant when their plugins are absent. Save the Icerunner
  installs only its channel.

## Proof debt

- Traverse both TGAE alternatives organically and prove the global-to-stage
  mapping, suppression trace, exact piety deltas, no Nocturnal commitment gain,
  exactly one toast, exactly one Book of Days beat, and save/load behavior.
- Exercise all five Save the Icerunner resolutions and record the same route,
  piety, surface, and save/load evidence.
- The combined Authoria lane and both individual options remain
  machine-verified experimental until equivalent tester evidence passes.
