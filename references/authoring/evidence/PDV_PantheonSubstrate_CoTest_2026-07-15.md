# Pantheon/Substrate Co-Test Evidence Retention - 2026-07-15

This is the durable retention record for the PS-A co-test evidence. The original
ledger was entered while the cited `Papyrus.0.log` and temporary clipboard files
were present. Papyrus rotates those logs and the clipboard paths are temporary,
so a later gate run must verify the retained reference below rather than declare
the completed test malformed solely because the transient source moved.

Provenance is intentionally explicit: this file retains the exact source
references already credited in `PDV_PantheonSubstrateRuntimeEvidenceLedger.json`.
It does not add a new runtime result, turn a failed or open bucket into a pass,
or replace the ledger's per-card notes. The tester confirmed on 2026-07-15 that
PS-A1 through PS-A11 had been run. PS-A1's quest-stage dedupe retest and its
remaining reserved-zero/first-dawn/save-load checks were tester-confirmed on
2026-07-15. The card is closed in the structured ledger below; the retained
record distinguishes the verified duplicate trace from the tester-confirmed
first-dawn result because the earlier log inspection used the wrong log path.
PS-A6 was retrospectively confirmed by the tester on 2026-07-15 and is recorded
below as a tester attestation because its separate-session raw capture was not
retained. The other PASS entries below retain their original recorded provenance.

## PS-A6 tester attestation

At 2026-07-15T20:04:07+10:00 the tester confirmed the completed in-game focused
suspension card: offer at 50, acceptance, lapse to 49, recovery to 50, and the
required Imperial/Nord player surfaces. This credits the runtime route and the
manual display result only. It is a retrospective tester attestation, not a
replacement for a raw Papyrus trace or screenshot from that prior session.

## PS-A1 duplicate-delivery remediation retest

One `setstage DBDestroy 200` produced one normal reaction and one engine repeat.
The repeat reached the new keyed guard and stopped before any second piety or
meta-faucet application:

- `[07/15/2026 - 07:45:08PM] [PDV] AwardPiety: Sithis raw -18.000000, applied -18.000000, stance 0, today=-18.000000`
- `[07/15/2026 - 07:45:09PM] [PDV] QuestReaction: 603387|200 applied 3 cells.`
- `[07/15/2026 - 07:45:09PM] [PDV] Manager: Quest reaction duplicate suppressed (603387|200)`
- No second `AwardPiety: Sithis raw -18.000000` occurs in the fresh session log.

## PS-A1 reserved-zero and first-dawn closure

The tester confirmed the remaining PS-A1 in-game sequence on 2026-07-15:
reserved-zero status at devotional day `0`, first-dawn behavior, and the
save/load portion all passed. The zero-activity dawn intentionally had no toast
or Book of Days entry: there was no accepted event, no pending scratch, and no
activity to surface. The contemporaneous status capture is
`C:/Users/Admin/AppData/Local/Temp/codex-clipboard-c0421969-ac69-4510-91bc-68c026377d63.png`.

The wrong Papyrus log path was inspected after this confirmation, so this
closure is credited as direct tester/runtime confirmation, not as a fabricated
raw-marker citation.

## Retained source references

- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:32:54 mcm_debug_rejected_home_only
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:36:46 daily_credit_dunmer_portable_prayer
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:33:38 RouteDunmerPortableShrinePrayer complete: 30
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:35:46 duplicate_event
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:36:46 granted=2.000000
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-27a8d09f-232a-4d3a-a277-bd348929d9c3.png
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-052feece-a8bb-4ed8-aebd-b3fe994ec98a.png
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:50:34 AwardPiety: Mara raw 4.000000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:01:37 [PDV][PS-A4]
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:03:07 applied=4.300000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:04:18 applied=-4.300000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#21:59:59 Auto-dawn: day rollover to 1
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-03124629-7a53-4345-8b69-4871a92f7ea5.png
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-0e80c988-c545-4bfd-aa72-888770bd6ec5.png
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:46:24 The Divines Regard Observant
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:49:43 Old Ways Observant
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:56:37 Faith of the Holds Observant
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#22:58:51 NordNineDivines applied=4.3 standing=28.299999
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#CurseState: Curse state 0 -> 2 (player_state)
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#Imperial civic service blocked by vampirism
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#ImperialAncestor: SetMetric ImperialAncestor = 28.000000 (daily_credit_imperial_civic)
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#RefreshFromPlayerState -> Vampire
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#RefreshFromPlayerState -> None
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-8256fe5c-d691-417e-a6fd-133d1f010beb.png
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#Pending commitment invalidated before acceptance.
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#06:09:30 altmer_heritage enchantment_enchant-item granted=4.000000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#imperial_civic event=craft_smith-item granted=4.000000
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-78bbda6d-1073-495f-953b-30a124ca8b45.png
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#18:37:04 [PDV][BROAD_CATCHUP] pool=ImperialDivines through=3 applied=1.848000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#18:38:24 [PDV][PS-A11] forced catch-up pool=ImperialDivines lastGainDay=2 through=7 standing=1.548000
- C:/Users/Admin/Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log#18:41:31 Loading game
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-387fdca6-0f85-4cfd-93fe-558b9411e010.png
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-b66fce02-8ee6-455e-974c-6ea8763e8a8f.png
- C:/Users/Admin/AppData/Local/Temp/codex-clipboard-46bcb1e1-aa46-4ed6-8c08-05a321c2a135.png

## Future intake rule

At evidence intake, retain any new Papyrus marker and screenshot reference in
this evidence store before a later game session can rotate or clean up its
source. A retained reference can preserve an already-observed result; it cannot
substitute for an observation that has not happened.
