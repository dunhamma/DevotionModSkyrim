# PDV Phase 20 Pre-Beta Manual Checks Runbook

**Created:** 2026-05-31
**Status:** Manual handoff packet after automated Phase 20 pre-beta gate work
**Owner:** Companion to `PDV_PreBetaRaceGateLedger.md`, `PDV_PreBetaRaceScalingSpine.md`, `PDV_Phase20_NoInGameProof_Gates.json`, `PDV_Phase20_ManualEvidenceLedger.json`, and `PDV_Phase20_QASmokeRuntimeProof_Runbook.md`

## Purpose

This runbook starts where the automated implementation work stops. The source,
content, manifest, route-list, and placement-readback gates can prove that the
pre-beta packets are wired and readable. They do not prove player feel.

Use this packet for the manual checks that remain before any race can move from
`Fail - runtime/manual proof deferred` to `Conditional` or `Pass` in
`PDV_PreBetaRaceGateLedger.md`.

The structured no-game gate packet,
`PDV_Phase20_NoInGameProof_Gates.json`, owns the current immersive hook
contracts and asset policy. This runbook records the eventual manual evidence
against those contracts; it does not count QASmoke, paper placement plans, or
source-only receiver scaffolds as empirical proof.

Use `PDV_Phase20_AllRaceSourceCuration_Runbook.md` before treating any normal
gameplay source as final empirical proof. The same exact-source rule applies to
all ten races: scan-only quest candidates are not live route/FormList sources
until the specific quest record, stage, and outcome have been read and approved.

Use `PDV_Phase20_ManualEvidenceLedger.json` as the structured intake file when
manual/runtime evidence starts. It is intentionally checked as `pending` by the
strict verifier until real in-game evidence exists; do not change a slot to
complete, conditional, or pass without also updating the gate ledger and adding
the matching proof note.

## Before Manual Checks

Run these from `C:\Users\Admin\Documents\Devotion Mod Project`:

```powershell
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase20_runtime_check.mjs --list
dotnet run --project .\tools\pdv-phase20-proof-placement-author\PdvPhase20ProofPlacementAuthor.csproj -- --check-placements
```

If source changed, compile first:

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
```

## Known Startup Failure: `PDV_MCM` Manager Binding

Symptom seen in live Phase 20 checks:

- `Survey Devotion` can show race text, but the MCM Player page summary still says
  `PlayerDevotion is still starting up.`
- `sqv PDV_Origin` may show stopped in affected saves.

This indicates the live `PDV_MCM` quest script instance is missing a valid
`PDV_Manager` binding in that save, even when other PDV scripts are active.

Runtime recovery sequence:

```text
startquest PDV_Origin
startquest PDV__ManagerQuest
stopquest PDV_MCM
resetquest PDV_MCM
startquest PDV_MCM
set PDV_GLO_OriginRace to 3
```

Then wait ~10 seconds, re-open MCM, and re-check:

```text
sqv PDV_Origin
sqv PDV__ManagerQuest
sqv PDV_MCM
```

Expected: MCM summary no longer reports startup-only text.

Durable fix target (source follow-up):

- Harden `PDV_MCM` so it self-heals when `PDV_Manager == None` at runtime
  (for example, resolve/rebind manager quest reference on page build/select
  before showing startup fallback text).

## Universal Manual Checks

For each race under test:

```text
Wrong-origin rejection:
  Activate or trigger the race proof surface from a different origin.
  Expected: no scoring, no state movement, no misleading Survey text.

Generic-hook rejection:
  Try ordinary travel, sleep, combat, theft, crafting, faction membership,
  shrine use, or quest proximity where that race explicitly rejects it.
  Expected: no generic faucet, no broad hidden counter movement.

Survey/status clarity:
  Cast Survey Devotion or open the MCM Player page after a real accepted hook.
  Expected: the text explains what changed in race language, not route IDs or
  debug counters.

Stack snapshot:
  Record active boons, favors, prices, privileges, substrate, scars, curse
  state, Daedric modifiers, and any race-specific track.

Final placement:
  Confirm whether the proof still lives only in QASmoke or has a planned
  final-world placement. Do not count QASmoke as final placement.

Evidence intake:
  Update the matching slot in `PDV_Phase20_ManualEvidenceLedger.json` only after
  the manual check is actually run. Until then the structured ledger should
  remain pending.
```

## Immersive Hook Contracts

Before placing or wiring anything outside QASmoke, read the matching
`immersiveHookContracts` entries in `PDV_Phase20_NoInGameProof_Gates.json`.
Every race now needs empirical proof from normal-play hook contracts, not just
debug-route or object placement proof. Visible objects are only acceptable for
real player-facing devotional acts such as shrines, rites, offerings, study
surfaces, or portable tokens.

```text
Altmer: dawn/study devotional context plus non-visible crisis/Lorkhan/orthodox pressure hooks.
Khajiit: lunar rest/open-sky cadence, road-home anchors, and Baan Dar/Rajhin/Alkosh focus hooks.
Argonian: Hist water/rest, People community, and thresholded Void hooks.
Orc: Stronghold quality forge, City/self-made dignity, and Legion/Exile service hooks.
Redguard: Crown/Forebear sect, Ash'abah/Far Shores death duty, and HoonDing cap hooks.
Bosmer: Living Story, Exchange, and Bandit Road/Pact pressure hooks.
Breton: tradition choice, Knight's Road, Hidden Art, and Green Way hooks.
Dunmer: portable ash-prayer/home rite, Reclamation focus, and deviation-price hooks.
Imperial: civic service, public/private Talos pressure, and focused patron civic hooks.
Nord: broad/focused Old Ways, Kyne/Talos context, and Hircine/Arkay curse-edge hooks.
```

For each hook, record:
- positive normal-play trigger
- wrong-origin rejection
- rejected generic-hook silence
- anti-farm repeat or cooldown behavior
- Survey/status clarity
- stack snapshot
- asset status

Stop if the chosen object, receiver, quest stage, FormList, or location would
turn a rejected generic hook into a scoring surface, such as generic travel,
one-bed sleep, raw craft loops, generic theft, generic combat, generic shrine
attendance, or generic undead farming.

Asset rule: every hook contract must explicitly state `newMeshRequired`. The
current end-state contract set is designed with `newMeshRequired: false` for
all races. If implementation discovers a required custom mesh, update the
contract first with `newMeshRequired: true` and name the missing asset before
building the hook.

### P2 Receiver Wiring Handoff

`PDV_Phase20_P2ImmersiveReceivers.manifest.json` defines the source-scaffolded
all-race receiver contract. `PDV_PlayerEvents.psc`
now compiles with optional PO3 book, spell-learned, harvest, weather, and
quest-stage receivers. These receivers remain inert until the wired FormLists
are populated with exact curated source records.

Current automated state:
- `tools/pdv-phase20-p2-receiver-author` created the 34 empty
  `PDV_FLST_P2_*` FormList shells in `PlayerDevotion_Framework.esp`.
- FormList readback command:
  `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-formlists`
- FormList backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\PlayerDevotion_Framework.esp.20260604-094058.bak`
- `tools/pdv-phase20-p2-receiver-author` wired all 34 `PDV_FLST_P2_*`
  properties on the existing `PDV_PlayerEvents` script attached to the
  `PDV_Player` alias.
- Alias-property readback command:
  `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-alias-properties`
- Alias-property backup:
  `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-p2-receivers\PlayerDevotion_Framework.esp.20260604-094110.bak`
- `PDV_PlayerEvents.psc` now compile-proves receiver-side repeat gates before
  routing P2 sources: book, spell, and quest-stage sources are one-shot per
  source/form/family; weather and harvest sources are once per in-game day per
  source/form/family.
- `tools/pdv-phase20-p2-receiver-author` now has source-fill tooling for the
  next approved manifest step. `--fill-source-entries` writes only entries
  declared with `status: approved-for-fill`; `--check-source-fill` readbacks
  the declared source entries against the live FormLists. The current manifest
  declares 29 approved P2 book-read entries across 13 groups; quest-stage
  source fills remain blocked until exact quest/stage entries are approved.
- Source-fill readback command:
  `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill`
- Exact-stage gate command:
  `dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates`
- P2 book runtime checker:
  `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager`
  `--strict-manager` requires source-specific manager reasons such as
  `po3_book_dunmer_azura`, not only generic route-family markers.

Remaining CK/xEdit wiring target:
- Curate exact source records in
  `PDV_Phase20_P2ImmersiveReceivers.manifest.json` under `sourceFillEntries`,
  mark only approved entries as `approved-for-fill`, then fill the existing
  `PDV_FLST_P2_*` FormLists through the source-fill tool.
- Register/fill quest-stage sources only after exact quest/stage metadata is
  approved in the manifest. Whole-quest FormList membership is not enough:
  `OnQuestStageChange` receives both quest and `aiNewStage`, and the receiver
  must compare the observed stage against approved stage metadata before
  routing.

Do not use broad category lists. Each FormList must contain exact curated
source records only. Quest-stage lists must contain terminal, one-shot, or
source-marked quests where any observed stage change is acceptable for that
source family. If a whole questline has many unrelated stages, do not add it to
the PO3 quest-stage FormList; use a narrower quest fragment, script event, or
manual receiver instead.

After wiring:
```powershell
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --list
```

Then prove one accepted route from each wired P2 source family, wrong-origin
silence, generic-source silence, repeat behavior, Survey clarity, and stack
snapshot before promoting Breton, Dunmer, Imperial, or Nord beyond audit-only.

Current live log status (2026-06-04):
- `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --strict-manager`
  reports `FAIL` on a single current-log full sweep after log rotation, but the
  approved filled P2 book families are proven across session logs.
- Accepted book-route proof is recorded for Dunmer Azura, Dunmer Boethiah,
  Imperial public Talos, Nord Old Ways, Nord Hircine/Arkay, Altmer Auri-El,
  Altmer Magnus, Altmer Xarxes, Argonian Hist, Khajiit Lunar, Orc Malacath, and
  Redguard ancestor spine. Breton Hidden Art passed in an earlier log and can be
  rerun only if a same-log full set is desired.
- `Papyrus.1.log` contains the non-Redguard 2026-06-04 packet after the first
  smoke run. `Papyrus.0.log` contains the Redguard proof after restart/log
  rotation.
- Khajiit route proof passed even though the Survey/status text did not visibly
  change during smoke; keep Survey/status clarity pending.
- Orc route proof passed, and the startup Prisma/CK MessageBox overlap observed
  during smoke was patched in the live manager script after compile verification.
- Remaining failures are runtime/manual evidence gaps, not source-fill or
  verifier failures.

## Race Checks

### Altmer

Expected build: Auri-El or Magnus scholar.
Edge build: Exiled vampire, werewolf halt, or mortal-world pressure run.

Check:
- Ordinary travel, friendships, generic spellcasting, College membership, and
  generic anti-Thalmor violence stay silent.
- Lorkhan pressure fires only from authored crisis/pressure routes.
- Survey explains crisis state, pressure, last favor, and curse posture.
- Exiled vampire and werewolf states surface as capped or halted, not stronger
  alternate builds.
- Immersive hook proof needs dawn/study devotional context plus crisis/pressure
  context outside QASmoke; pressure must not be a visible click object.

Progress note (2026-06-01):
- Manual check 1 (`wrong-origin rejection`) is complete for Altmer.
- Manual check 2 (`generic-hook rejection`) is complete for Altmer.
- Manual check 3 (`surveyStatusClarity`) is complete for Altmer. Survey shows
  crisis state, authored Lorkhan pressure, and last favor in fiction-facing
  wording; curse posture is evidenced by the completed Altmer vampire lane when
  applicable.

Altmer immersive-hook staging packet:
- Source ACTIs to reuse:
  `PDV_ACTI_AltmerDawnSteadinessSignal` and
  `PDV_ACTI_AltmerLorkhanPressureSignal`
  remain dev/ritual proof surfaces only.
- Final pressure wiring should use quest/stage/state context, not a visible
  crisis object.
- Asset status:
  no new mesh required. Use vanilla book, lectern, shrine-adjacent static, idle
  marker, or non-visible context.
- Validation contract once wired:
  Altmer hook routes expected positive/pressure behavior and non-Altmer origin
  remains silent except debug rejection.
- Rollback path:
  if location, object, receiver, or quest context changes, remove only the
  staged immersive hook wiring and keep QASmoke references unchanged.

### Khajiit

Expected build: lunar road mage.
Edge build: Rajhin or Baan Dar play without theft spam.

Check:
- No required visual moon inspection.
- Moon-sugar, fast travel, generic theft, generic dragon kills, one-bed camping,
  and ordinary night stealth stay silent.
- Same road-home anchor repeat does not become a loop.
- Survey explains Lunar Lattice, moon practice, road-home cadence, and focus.
- CAT-6 source row exists and `PDV_Bless_Khajiit_Lunar_T1` is present as a
  live pilot-provisional framework ESP `SPEL` as of the 2026-05-31 readback
  check. Its two pilot `MGEF` effects are night-gated and grant-unwired. Treat
  this as record/readback/text proof only, not as manual feel proof, reward
  distribution proof, or holistic race-effect approval.

### Argonian

Expected build: Hist/People community keeper.
Edge build: Void-aware assassin without replacing the floor.

Check:
- Swimming loops, same-bed sleep loops, generic murder, generic stealth, and one
  Dark Brotherhood join do not activate full Sithis depth.
- Hist/People maintenance can be felt before Void depth.
- Survey names Hist, People, Void, bed-of-choice, and Sithis posture without raw
  debug values.
- Final placement needs one Hist/People surface and one community/death-rite
  surface outside QASmoke.

### Orc

Expected build: stronghold smith or code-bound warrior.
Edge build: city dignity or Legion/exile service.

Check:
- Raw crafting, raw combat, raw mining, generic stronghold membership, and
  generic Legion membership stay silent.
- Quality/context filters matter for forge and service hooks.
- Survey names life mode, standing, and curse/code pressure.
- Stack snapshot confirms Malacath/code surfaces do not become a generic
  warrior buff stack.

### Redguard

Expected build: Crown or Forebear route.
Edge build: Ash'abah death-duty route.

Check:
- Generic combat, generic undead kills, fast travel, ordinary shrine visits, and
  Arkay substitution stay silent.
- Far Shores token and HoonDing pressure are capped.
- Survey names sect, standing, Far Shores weight, and curse-cycle pressure
  without numeric debug output.
- Final placement needs one sect surface and one death-duty/Far Shores surface
  outside QASmoke.

### Bosmer

Expected build: Living Story or Exchange non-hunter.
Edge build: Bandit Road reversal.

Check:
- Generic kindness, bard activity, forest travel, trade profit, theft, and
  random vengeance stay silent.
- Bandit Road reversal keeps its cooldown and does not become a theft faucet.
- Survey names path, standing, Pact binding/lapse, and recent favor memory.
- Final placement needs one non-hunter surface outside QASmoke before Green Pact
  item-tag expansion.

### Breton

Expected build: one chosen tradition.
Edge build: Hidden Art plus Daedric rupture or curse pressure.

Check:
- Casual tradition switching, generic spellcasting, generic artifact ownership,
  generic help, College membership, private curiosity, and generic shrine visits
  stay silent.
- Survey names tradition, vow, Hidden Art exposure, DruidicStanding, and curse
  posture.
- Stack snapshot records tradition, KnightlyVowIntegrity, WitchcraftExposure,
  DruidicStanding, patron focus, curse fork, and Daedric modifiers.
- Audit target: prove one tradition readback plus one tradition-specific favor
  without letting Knight's Road, Hidden Art, and Green Way reward at the same
  time.
- Stop condition: no Breton reward volume or placement expansion until Hidden
  Art cost, generic spell/artifact silence, and expected/edge stack evidence are
  recorded.

### Dunmer

Expected build: ash-prayer and ancestor practice into one Reclamation focus.
Edge build: ancestor substrate plus Daedric deviation or curse price.

Check:
- Generic crime, cruelty, twilight, magic, Tribunal memory, and non-Reclamation
  deviation stay silent unless a curated row owns the signal.
- Survey names ancestor layer, portable ash-prayer, private home rite, standing,
  and curse posture.
- Stack snapshot records ancestor substrate, Reclamation focus, active favor,
  deviation price, curse state, and Daedric modifiers.
- Audit target: prove ancestor substrate plus one focused Reclamation foreground
  while deviation, curse, and Daedric contact remain priced.
- Stop condition: no new Dunmer reward volume until generic Daedric behavior is
  rejected and substrate/focus/deviation overstack risk is recorded.

### Imperial

Expected build: civic Nine Divines broad worship.
Edge build: public/private Talos pressure under ConcordatStanding.

Check:
- Faction membership, generic temple attendance, bounty payment alone, generic
  anti-Thalmor violence, and cruelty-as-order stay silent.
- Survey names civic faith, ConcordatStanding, Talos pressure tilt, repair gate,
  standing, and curse posture.
- Stack snapshot records ConcordatStanding, public/private Talos state, primary
  patron, civic favor, repair/rupture, curse state, and Daedric modifiers.
- Audit target: prove concrete civic service and public/private Talos pressure
  without rewarding faction rank, temple attendance, or abstract lawfulness.
- Stop condition: no new civic surface expansion until the civic whitelist and
  faction/attendance rejection evidence are in the ledger.

### Nord

Expected build: broad Old Ways into Kyne or Talos.
Edge build: Hircine/werewolf stack.

Check:
- Generic kill, generic travel, generic tomb clear, generic anti-Thalmor
  violence, and broad worship inheriting every patron boon stay silent.
- Survey remains the control/reference for clear race feel.
- Stack snapshot proves Kyne, Talos, Hircine, broad favors, vampire/scar, and
  Daedric modifiers do not overstack.
- Audit target: prove broad/focused Nord remains the control race without dense
  vanilla hooks turning into a faucet.
- Stop condition: no new Nord content volume until generic dense-hook rejection
  and Hircine/Kyne/Talos stack evidence are recorded.

## Recording Results

After each race, update `PDV_PreBetaRaceGateLedger.md`:

```text
Verdict:
Evidence date:
Manual feel note:
Wrong-origin result:
Generic-hook result:
Survey/status result:
Stack snapshot:
Final placement result:
Blocking follow-up:
```

Only use `Pass` when the evidence proves the whole race-level gate. Use
`Conditional` when the race is coherent enough for scoped internal playfeel but
has named gaps. Keep `Fail` when the player would still be judging missing
systems.
