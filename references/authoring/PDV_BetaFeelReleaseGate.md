# PDV Beta-Feel Release Gate

**Created:** 2026-06-06
**Status:** Active release gate for console-assisted beta-feel proof
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`,
`PDV_PreBetaRaceAcceptanceRubric.md`,
`PDV_Phase20_PreBetaManualChecks_Runbook.md`, and
`PDV_AllRaceDaedricBetaReadinessLedger.md`

## Release Definition

Beta-feel ready means a player can test a race and judge feel without first
tripping over missing wiring, invisible state, generic activity scoring, or
obvious stack noise.

It does not mean every quest path is naturally paced, every final placement is
perfect, or every reward number is final. It means the authored slice is
coherent enough for testers to judge.

## Accepted Proof Model

Console-assisted proof is valid for beta-feel when the console is used to set
up the situation and the final PDV trigger is still exercised normally in game.

Acceptable console use:

- `coc` to move to a test location.
- `player.additem` to add an exact approved book, then read the book normally.
- `setstage` for an approved exact quest-stage hook.
- `movetoqt`, `tmm`, `unlock`, `tgm`, or similar travel/friction reducers.
- `set PDV_GLO_OriginRace to X` only in a disposable proof save when testing
  origin-gated behavior.

This proves route delivery, player-facing feedback, Survey/status clarity,
wrong-origin silence, generic-source silence, reward display, and stack sanity.

It does not prove natural quest pacing, organic discovery rate, final placement
feel, or long-session balance. Those can remain later tuning notes unless they
make the race impossible to judge.

## Required Automated Gate

Run these from `C:\Users\Admin\Documents\Devotion Mod Project` before recording
race beta-feel evidence:

```powershell
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-formlists
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-alias-properties
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-reward-author\PdvPhase20RewardAuthor.csproj -- --check
```

After each in-game proof sweep, run the relevant runtime checker immediately
before log rotation makes the evidence ambiguous:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager
node .\tools\pdv_phase20_runtime_check.mjs --race all
```

## Per-Race Beta-Feel Packet

Every race needs one expected build and one edge build.

The expected build is the intended normal character fantasy. The edge build is
the risky character shape most likely to overstack, trigger generic scoring, or
erase native race identity.

For beta-feel, each packet must answer:

```text
Race:
Expected build tested:
Expected accepted trigger:
Expected feedback:
Expected Survey/status:
Expected reward or state result:
Expected feel note:

Edge build tested:
Edge accepted or rejected trigger:
Edge feedback:
Edge Survey/status:
Edge stack result:
Edge feel note:

Wrong-origin result:
Generic-source result:
Repeat/anti-farm result:
Final placement status:
Release verdict:
Blocking follow-up:
```

Allowed release verdicts:

- `Pass`: ready for external beta-feel tester judgment.
- `Conditional`: acceptable for a narrow internal tester pass only, with a
  named fix.
- `Fail`: keep internal; the race still feels missing, generic, hidden, or
  mechanically unsafe.

## Race Proof Targets

| Race | Expected build | Edge build | Minimum beta-feel proof |
|---|---|---|---|
| Altmer | Auri-El/Magnus/Xarxes scholar under dawn/study discipline | Dragonborn crisis plus vampire, werewolf, or Daedric pressure | Prove one orthodox/study source, one Lorkhan/crisis pressure source, Survey clarity, repeat crisis rejection, and stack/cap behavior. |
| Khajiit | Lunar or road-home traveler with Khenarthi/Azurah cadence | Theft, dragon, moon-sugar, or Daedric-heavy pressure | Prove Lunar or road-home source, Survey clarity, same-anchor/generic theft/dragon/moon-sugar silence, and night reward display. |
| Argonian | Hist/People community survivor | Sithis threshold, vampire rupture, or werewolf strain | Prove Hist or People maintenance, Survey clarity, generic swimming/sleep/murder silence, and Hist/People/Void stack legibility. |
| Orc | City, Legion/Exile, or Stronghold Orc maintaining Malacath through labor or service | Blood-Kin, werewolf, vampire-cured, or raw combat/craft spam | Prove Malacath/code source, Survey clarity, raw craft/combat/faction silence, and no generic warrior overstack. |
| Redguard | Crown/Forebear road, tomb, contract, or ancestor-spine play | Ash'abah burden, vampire cure, HoonDing, or undead farming | Prove ancestor/sect source, Survey clarity, fast-travel/combat/undead/Arkay silence, and Far Shores/HoonDing cap legibility. |
| Bosmer | Living Story, Exchange, or non-hunter Pact play | Bandit Road reversal, Pact lapse, curse pressure, or generic theft/commerce | Prove at least one Bosmer path source, Survey clarity, commerce/theft/forest/kindness silence, and Bandit Road/Pact cooldown behavior. |
| Breton | One chosen tradition: Knight's Road, Hidden Art, or Green Way | Hidden Art plus Daedric rupture or curse pressure | Prove tradition readback/source, Survey clarity, generic spell/artifact/help silence, and tradition plus curse/Daedric stack legibility. |
| Dunmer | Ash-prayer/ancestor practice into one Reclamation focus | Reclamation plus Daedric deviation, curse, or generic crime/cruelty | Prove ancestor or Reclamation source, Survey clarity, generic Daedric behavior silence, and deviation price/stack legibility. |
| Imperial | Civic Nine Divines service with concrete patron identity | Public/private Talos pressure under ConcordatStanding | Prove civic or Talos source, Survey clarity, faction/attendance/bounty/generic anti-Thalmor silence, and public/private stack legibility. |
| Nord | Old Ways into Kyne or Talos | Hircine/werewolf/Kyne/Talos stack | Prove Old Ways or Hircine/Arkay source, Survey clarity, dense generic hook silence, and Kyne/Talos/Hircine stack cap. |

## Release Scope Choices

There are two possible releases:

```text
Race Beta-Feel Release:
  Requires all ten races at Pass or explicitly scoped Conditional.
  Daedric content can remain disabled, hidden, or documented as non-beta if
  Daedric proof is not complete.

Full Devotion Beta-Feel Release:
  Requires all ten races at Pass or explicitly scoped Conditional and all
  sixteen Skyrim-present Daedric Princes through the D-18/CAT-6 readback plus
  runtime/display proof bar.
```

Do not call the build a full beta-feel release if Daedric content is visible to
testers but lacks the Daedric 20C proof packet.

## Release Stop Conditions

Stop and fix before release if any of these occur:

- A full blocking panel opens from gameplay without player choice.
- Wrong-origin or generic-source actions score.
- Survey/status uses route IDs, raw debug counters, or misleading text.
- A reward appears without a clear owning race/state.
- Expected and edge builds produce an obvious always-on overstack.
- A route is claimed live but cannot be found in the current Papyrus log or
  readback evidence.
- A race has no tested expected build.
- A race has no tested edge build.

## Final Release Checklist

Before sending to testers:

```text
Automated gate green:
All ten race expected-build packets recorded:
All ten race edge-build packets recorded:
Wrong-origin/generic-source checks recorded:
Survey/status screenshots or notes recorded:
Reward/Active Effects notes recorded:
Stack snapshots recorded:
Known issues written:
Tester stop conditions written:
Release scope named: Race Beta-Feel or Full Devotion Beta-Feel
```
