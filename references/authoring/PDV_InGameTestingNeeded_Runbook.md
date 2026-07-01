# PDV In-Game Testing Needed Runbook

**Created:** 2026-06-10  
**Status:** Active manual/runtime handoff after Breton, Orc, and Nord final-run closeout; strict audit now blocks on Imperial and Dunmer race evidence
**Companions:** `PDV_RunSheet_*_BetaFeel.md`, `PDV_BetaTestPacket_*.md` (historical/source notes), `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_DaedricInGameSmokePacket.md`, `PDV_DaedricRuntimeEvidenceLedger.json`, `PDV_SessionHandoff_2026-06-29_PreBetaRaceCloseout.md`, `PDV_SessionHandoff_HircineAuditFixes.md`, `PDV_SessionHandoff_BosmerRuntimeFixes.md`, `PDV_BetaFeelReleaseGate.md`, `PDV_FaucetDetection_CKChecklist.md`, `PDV_DeityLikesDislikes.csv`, `PDV_PrinceLikesDislikes_V2_Spec.md`

## Purpose

This is the current testing queue. It starts after repo-side readback and
verifier work. Passing these checks requires in-game runtime/manual evidence;
do not replace them with source review, QASmoke-only route proof, or verifier
output.

2026-06-27 routing note: the final race-testing entrypoints are now the
`PDV_RunSheet_<Race>_BetaFeel.md` files. The older `PDV_BetaTestPacket_*` docs
remain useful provenance and source notes, but do not use them as the primary
step-by-step runthrough unless a current run-sheet points back to a specific
section.

2026-06-12 handoff note: the Hircine source/VMAD display drift is fixed and
compiled, so Hircine should be tested first in the Daedric proof session. See
`PDV_SessionHandoff_HircineAuditFixes.md` for the exact route and evidence
commands. This is still compile/readback proof only until runtime/manual slots
are recorded.

2026-06-13 handoff note: Bosmer DA05 route/manual proof is partially recorded,
and the Naming/neglect/reward-copy fixes were written after Skyrim closed. See
`PDV_SessionHandoff_BosmerRuntimeFixes.md` before continuing Bosmer. Restart
Skyrim before retesting; the previous live session had old manager script state.

2026-06-20 handoff note: Nord startup, Shor/HoonDing capstone saves, HoonDing
listed bosses, Redguard Ash'abah necromancer/warlock and clearable-undead-site
burdens, and Namira passive-zero/Health+Stamina feed copy are built/readback-clean.
This is still compile/readback proof only. Fold runtime/manual checks into the
Nord, Redguard/Requiem, and Daedric/Namira packets before making a beta-feel claim.

2026-06-27 handoff note: the Nord/Imperial felt-neglect ESP batch is
machine/readback clean. Kyne neglect is `ResistFrost -8`, Imperial civic neglect
is `ResistDisease -5`, and Nord Shor/Tsun/Stuhn/Talos per-patron neglect spells
exist and are wired. This is not runtime proof; fold Active Effects/stack checks
into the next Nord and Imperial smoke pass.

2026-06-27 handoff note: the Imperial/Nord Talos betrayal creed runtime is also
compile-clean. Use MCM Debug -> `Talos betrayal -2` / `Talos betrayal -3` on a
focused Talos path to prove piety loss, surfacing, anti-repeat, and Imperial
Concordat raw movement. Organic quest/dialogue detection for betrayal beats is
not implemented yet and must stay a follow-on, not a smoke-test blocker.

2026-06-29 handoff note: Breton Hidden Art, Orc organic life-mode, and Nord
final-run packets are recorded for the current beta-feel scope. Nord received
several runtime fixes during final testing: Book of Days/Prisma surfaces are
player-owned only, broad Old Ways T1 syncs without a dawn delay, Talos/Kyne
display casing is normalized, legacy overlapping boons are cleared/opted out
for manager-owned race rewards, dashboard piety drivers are not active-patron
gated, and vanilla shrine use is neutralized to no vanilla blessing/cure while
feeding hidden once-per-day PDV shrine-prayer signals. Kynareth/Kyne/Khenarthi,
Akatosh/Auri-El/Alkosh, Arkay/Tu'whacca, Zenithar/Z'en, and Auriel/Akatosh
share backend shrine piety where configured; Book of Days writes only the
player-origin-appropriate deity name for the line.

2026-06-30 handoff note: the Requiem swallowed-regen penalty conversion is
backend/readback clean but still needs in-game feltness proof. Argonian Hist
Distant, Breton Tradition Distant, and Breton Excommunication now use negative
Fortify Health (`Health -10`, `Health -10`, `Health -15`). Imperial civic
neglect is intentionally preserved as `ResistDisease -5`. Do not mark this
Requiem penalty slice gameplay-proven until Active Effects, `player.getav
Health`, and HP-bar/manual feel evidence are recorded under a Requiem load.

2026-06-30 handoff note: the Daedric beta-display ledger has since closed for
the current v1.0 gate. `node .\tools\pdv_daedric_beta_gate.mjs --json` reports
`PASS=16`; do not reuse older "all sixteen pending" language unless the gate
regresses. Daedric final-world placement remains separate from this beta-display
proof.

2026-06-30 handoff note: the Prisma-to-1.0 wiring pass is static/readback clean
and adds `tools\pdv_prisma_to_oneoh_audit.mjs` as the roll-up guard. The manager
now emits the shared `neglect.recover` surface when the active patron leaves a
neglected state. This is still not runtime/manual proof; fold the recovery beat
into the universal Prisma sheet and into the next Imperial/Dunmer Prisma surface
checks.

2026-07-01 handoff note: the Prisma authoring-beats wiring is static/readback
clean and compiled. Formal offer accept/refuse, Hircine renunciation, Redguard
sect champion-entry, and Altmer Thalmor-alignment wording now have explicit
run-sheet coverage. This remains manual/felt proof until the Universal Prisma,
Daedric, Redguard, and Altmer sheets record the on-screen toast/Book-of-Days
results.

## Preflight Before Opening Skyrim

Run from `C:\Users\Admin\Documents\Devotion Mod Project`:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
dotnet run --project .\tools\pdv-neglect-esp-author\PdvNeglectEspAuthor.csproj -- --check
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM --script PDV_PlayerEvents
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_verify.mjs --strict-neglect-decay --json
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
node .\tools\pdv_requiem_penalty_audit.mjs
node .\tools\pdv_integrity_harness.mjs
node .\tools\pdv_prisma_to_oneoh_audit.mjs
node .\tools\pdv_refresh_seq.mjs --write --json
node .\tools\pdv_daedric_beta_gate.mjs --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Expected before manual testing:

- Route entries: `PASS`, including all 46 manifest route entries.
- Base wiring audit: `PASS`.
- `pdv_verify --json` and Phase 2 reward readback audit: `PASS`; SEQ refresh
  has no stale/missing entry warning.
- Integrity harness: `PASS`, including `eligibility_reward_coverage`.
- Prisma-to-1.0 audit: `PASS`; this proves producer/UI wiring and live Prisma
  asset parity, not in-game display.
- Requiem penalty audit: `PASS`, including old regen-MGEF orphan checks and
  Imperial preservation.
- Daedric beta-display gate: `PASS=16`.
- Neglect ESP author check and strict neglect verifier: `PASS`.
- Manager and MCM compile: `PASS`, including the Talos betrayal debug buttons.
- Beta readiness audit: still `NOT_BETA_READY` until manual/runtime slots are
  recorded.

2026-06-30 launch note: do not use
`node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json`
as the blocking launch gate for this manual queue unless that strict mode is
refreshed. On the current Prisma-to-1.0 build it still expects old Book of Days
source spellings and Nord pending-evidence state even though `pdv_verify --json`,
Book of Days audit, Prisma-to-1.0 audit, and the strict beta audit agree on the
current evidence boundary.

Current reward-readback expectation after the 2026-06-20 Requiem-tail closeout:
`pdv_phase2_reward_readback_audit` should pass with `FAIL=0`. The old Khajiit
Baan Dar T3 capstone-script caveat is no longer the expected blocking state for
this manual queue.

Do not use the older
`dotnet run --project .\tools\pdv-phase20-reward-author\PdvPhase20RewardAuthor.csproj -- --check`
as the blocking reward gate for this manual queue unless that tool or its
first-tier contract is intentionally refreshed. It currently reports stale T1
contract drift across older race records even when the stricter reward readback
audit passes.

## Current Last-Pass Blocker Snapshot

As of the 2026-06-30 strict audit rerun, the active race beta-feel blockers are
manual/runtime evidence only for Imperial and Dunmer. Readback and verifier
gates are necessary preflight, but they do not close these rows.

Race ledger blockers from `PDV_Phase20_ManualEvidenceLedger.json`:

| Race | Pending manual/runtime slots |
| --- | --- |
| Altmer | none for current beta packet; final-world placement remains separate |
| Khajiit | none for current beta packet; final-world placement remains separate |
| Argonian | none for current beta packet; final-world placement remains separate |
| Bosmer | none for current beta packet; final-world placement remains separate |
| Breton | none for current Hidden Art packet; optional `ExposureRupture` edge once an MCM band setter exists; Knight's Road/Green Way remain deferred V1 arms |
| Dunmer | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Imperial | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Nord | none for current beta packet; final-world placement remains separate |
| Orc | none for current organic life-mode packet; Code Holds, Witnessed tranche, oath-break, and final-world placement remain separate |
| Redguard | none for current beta packet; final-world placement remains separate |

Daedric ledger state from `PDV_DaedricRuntimeEvidenceLedger.json`:

- The current beta-display gate passes all sixteen Skyrim-present Princes.
- `node .\tools\pdv_daedric_beta_gate.mjs --json` is the promotion check; rerun
  it after any Daedric, Prisma, reward, or runtime-surfacing change.
- Daedric final-world placement remains separate and is not a blocker for the
  current race beta-feel packet unless the release scope changes.

Additional last-pass runtime sweeps before any broad beta-feel claim:

- Day-to-day V1 faucet sweep: finish craft, book, sleep, transgression,
  trespass `361`, events `1` and `2`, anti-farm, attribution filter, race gate,
  and dawn bank checks.
- Prince V2 path-deepening sweep: prove deepen-not-initiate, open-path deepen
  markers, dual-face Azura behavior, anti-farm, and Hircine curse
  no-double-fire.
- Prisma recovery sweep: run `PDV_RunSheet_Universal_Prisma_V1.md` U6/U7 once
  on the current build, and make sure the drop and recovery beats appear as
  player-owned toast/Book-of-Days/Chronicle surfaces without forcing the full
  Prisma panel.
- Prisma authoring-beats sweep: run Universal U8 for formal offer accept/refuse,
  Daedric D8 for Hircine renunciation, Redguard 6d for sect champion-entry, and
  the Altmer Thalmor-alignment regression row. These prove manual display only;
  keep them separate from the static Prisma-to-1.0 audit.
- Requiem felt-penalty sweep: prove the new negative Health penalties are felt
  in-game and Imperial remains disease-resistance based.

### Requiem Penalty Feltness Add-On

Run this after the normal race-sheet setup, on disposable saves, with Requiem
active. This is manual/Active Effects proof; the backend audit only proves the
records are wired.

Before each row:

```powershell
node .\tools\pdv_requiem_penalty_audit.mjs
```

In game, record `player.getav Health` before and after the penalty applies,
capture the Active Effects line, and write a short HP-bar/manual feel note.

| Race / route | How to seed | Expected in-game proof | Evidence sink |
| --- | --- | --- | --- |
| Argonian Hist Distant | Argonian origin; force or naturally reach the Hist neglect/distant state | `PDV_MGEF_Neglect_ArgonianHist_Health` appears as Maximum Health; max Health drops by 10; HP bar reflects the lower ceiling | Argonian run-sheet stack snapshot/manual feel note plus `PDV_Phase20_ManualEvidenceLedger.json` note |
| Breton Tradition Distant | Breton origin; force or naturally reach the tradition neglect/distant state | `PDV_MGEF_Neglect_Breton_Health` appears as Maximum Health; max Health drops by 10; text says Maximum Health -10 | Breton run-sheet stack snapshot/manual feel note plus ledger note |
| Breton Excommunication | Breton origin; force creed-loss/excommunication once the route is reachable, or use the debug path if one is added | `PDV_SPEL_CreedLoss_Breton_Excommunication_MGEF_Health` appears as Maximum Health; max Health drops by 15; no old Health Regeneration penalty appears | Breton run-sheet edge-case note plus ledger note |
| Imperial civic neglect preservation | Imperial origin; force or naturally reach civic neglect/distant state | Active Effect remains disease-resistance based (`ResistDisease -5`); no `PDV_MGEF_Neglect_Imperial_Health`; max Health does not drop from this effect | Imperial run-sheet stack snapshot/manual feel note plus ledger note |

Stop/fail rules:

- If any converted penalty still displays Health Regeneration, stop and keep the
  row open.
- If `player.getav Health` does not change for an Argonian/Breton converted
  penalty, stop and keep the row open even if readback is green.
- If Imperial gets a Health penalty, stop; that contradicts the 2026-06-30
  owner ruling.
- Do not use QASmoke/readback alone as feltness proof for these rows.

## Testing Order

### 1. Close The Smallest Race Evidence Gaps

Altmer is closed for the current packet. Khajiit is now closed for the current
beta-feel packet; final-world placement remains separate.

- Altmer: packet closed on 2026-06-10. All seven evidence slots are
  `evidence-recorded` in `PDV_Phase20_ManualEvidenceLedger.json`.
- Khajiit: lunar packet closed on 2026-06-10. On 2026-06-13, Baan Dar Champion
  survival passed in game after the vanilla-shaped capstone rewrite, and the
  Champion/Scratch UI presentation cleanup fixed Baan Dar casing plus narrator
  voice. On 2026-06-14, the remaining Khajiit beta-feel packet closed: Rajhin
  elegant theft/cooldown and Alkosh word-of-power dawn drip were log-proven,
  lunar books passed the focused P2 runtime checker, and remaining rejection,
  Survey, reward-ceiling, stack, and optional checks were tester-attested in
  `PDV_Khajiit_BetaFeelPacket.md`.

### 2. Bosmer DA05 Packet Closed

Use `PDV_BetaTestPacket_Bosmer.md`.

Required checks:

- Bosmer origin, DA05 stage `100`: accepted Y'ffre hunt-law pressure route.
  **Passed 2026-06-13** with visible threshold crossing after piety-23 preflight:
  Active Effects showed Old Contract / Seeker and Y'ffre's Weave / Seeker, and
  Survey Devotion showed Bosmer OldContract / Seeker. The earlier piety-25
  stable-display pass correctly showed no pre/post visible change.
- Bosmer origin, DA05 stage `105`: accepted mercy-branch edge route.
  **Passed 2026-06-13** on a separate clean save with
  `RouteBosmerYffre complete: 1 source po3_queststage_bosmer_da05_mercy`.
  The live source was also patched/compiled at 4:43 PM to share
  `bosmer_da05_yffre_outcome` across stages 100/105 for future same-save
  mutual-exclusion behavior.
- Wrong-origin rejection for the same DA05 route.
  **Passed 2026-06-13** by tester report. Source/log review also found the
  Bosmer P2 source path lacked a source-layer origin gate, so live source was
  patched/compiled at 4:43 PM to require `GetOriginRaceValue() == 4` for the
  durable contract.
- Generic-source silence for hunting, forest travel, trade, theft, broad plant,
  kindness, and generic book/source attempts.
  **Passed 2026-06-13** by tester report.
- Survey/status clarity after the accepted branch. **Stage 100 slice passed.**
- Reward/stack snapshot and short feel note. **Bosmer current packet later
  closed.** Follow-up evidence recorded after the DA05 branch pass includes
  Songs of the Green pass, Baan Dar Gap pass, no-assets-required confirmation,
  and a positive final Bosmer feel/readback closeout. Final-world placement
  remains separate.

After each DA05 branch, use the DA05-specific log check in
`PDV_BetaTestPacket_Bosmer.md`. The generic Bosmer runtime checker currently
validates the eight QASmoke proof activators, not DA05.

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "RouteBosmerYffre|po3_queststage_bosmer_da05|RouteBosmerPactPositive|RouteDaedricPrinceSignal" -Context 1,1
```

### 3. Run The Race Run-Sheets

Use one disposable save per race or a clean reload before each route family. The
full gap sheets should run first; compact sheets are regression passes for races
with prior packet evidence.

| Race | Current sheet | Primary runtime checker |
| --- | --- | --- |
| Orc | `PDV_RunSheet_Orc_BetaFeel.md` | organic/source-specific markers plus `node .\tools\pdv_phase20_runtime_check.mjs --race orc --strict-manager` for QASmoke-only cross-checks |
| Breton | `PDV_RunSheet_Breton_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager` |
| Dunmer | `PDV_RunSheet_Dunmer_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer --strict-manager`; remaining slots are manual/log assembled |
| Imperial | `PDV_RunSheet_Imperial_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager` |
| Nord | `PDV_RunSheet_Nord_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race nord --strict-manager` |
| Altmer | `PDV_RunSheet_Altmer_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race altmer --strict-manager` |
| Argonian | `PDV_RunSheet_Argonian_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race argonian --strict-manager` |
| Bosmer | `PDV_RunSheet_Bosmer_BetaFeel.md` | DA05 uses `Select-String` log proof; `node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager` is QASmoke-only |
| Khajiit | `PDV_RunSheet_Khajiit_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race khajiit --strict-manager` |
| Redguard | `PDV_RunSheet_Redguard_BetaFeel.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race redguard --strict-manager` |

For each race, record:

- accepted-source route proof
- wrong-origin rejection
- generic-source silence
- anti-farm or duplicate behavior
- Survey/status clarity
- reward/Active Effects or state-layer stack snapshot
- manual feel note
- asset status

### 4. Run Daedric Runtime/Display Proof

Use `PDV_DaedricInGameSmokePacket.md` and record results in
`PDV_DaedricRuntimeEvidenceLedger.json`.

**Console `setstage` gotcha (organic senders).** `setstage <DAxx> <stage>` does
**nothing** if the quest is not already running -- the stage is never really
set, so PO3 `OnQuestStageChange` never fires and the organic route stays silent.
This is a console-test artifact, not a wiring bug. The organic Daedric senders
only fire naturally because, in real play, the vanilla quest IS running when it
reaches the routed stage.

There is **no `startquest` console command** (and `saq` starts every quest at
once -- do not use it), so there is no clean way to force-start one vanilla
quest from the console. Real, verified commands (see
`PDV_SkyrimConsoleReference.md`):

```
sqs DA02               ; list DA02 stages and which are achieved
getstage DA02          ; current stage number
setstage DA02 100      ; only takes effect if DA02 is already running
resetquest DA02        ; reset DA02 to stage 0
```

For alternate-outcome stages (DA05 100 = killed Sinding vs 105 = spared), the
two are mutually exclusive on one quest instance: `resetquest DA05` before
firing the other branch, or the second stage will not change.

Because the organic path is fragile to drive from the console, prefer the
**QASmoke sender** for route proof (per-Prince activator, or MCM -> Debug ->
Daedric -> "Route all Princes"): it routes straight through EventBus with the
baked prince index, needs no vanilla quest running, and avoids `setstage`
advancing the real quest into handing over its vanilla reward (e.g. DA05 giving
the Savior's Hide). Confirm any route with the log: `RouteDaedricPrinceSignal
complete: 200 index <N>` plus `Daedric live signal: <Prince>`. Only the
`organicRoute` ledger slot requires the real quest-stage path; every other slot
can ride QASmoke/MCM.

Required per Prince:

- MCM route marker
- QASmoke route marker
- organic exact quest-stage route marker
- generic silence probe
- Active Effects display
- summary message
- Prisma/notification behavior
- save/load sanity
- stack legibility
- manual feel note

After any Daedric regression proof or rerun:

```powershell
node .\tools\pdv_daedric_runtime_check.mjs
node .\tools\pdv_daedric_beta_gate.mjs --json
```

### 5. Run The Day-to-Day Likes/Dislikes Signal Sweep (V1)

The generic 300+ action vocabulary (combat-by-victim, craft, knowledge,
devotional, transgression) routes `PDV_ActionRouter` -> `PDV_EventBus` ->
`PDV_DeityBase.ScoreFromTable`. It is **race-gated**: a generic act only scores
deities NATIVE to the player's race. Source of truth for deltas:
`PDV_DeityLikesDislikes.csv`; detection map: `PDV_FaucetDetection_CKChecklist.md`
section 6.

One character is enough. Set up:

```
set PDV_GLO_DebugLevel to 2     ; per-event traces (3 for anti-farm cap checks)
set PDV_GLO_OriginRace to 1     ; Imperial = broadest native coverage (~22/25 events)
```

Flip `PDV_GLO_OriginRace` to retest the gate without rerolling:
`0` Nord `1` Imperial `2` Breton `3` Altmer `4` Bosmer `5` Dunmer `6` Khajiit
`7` Argonian `8` Orc `9` Redguard.

Positive marker: `[PDV] EventBus: <deity> event <id> delta <x>` (delta must match
the CSV exactly).

Exercise (DebugLevel 2):

- combat by victim: draugr / Dremora / dragon -> `300/301/302`; non-hostile animal
  + criminal/non-hostile victim -> `303/304`
- craft (use the stations): smith / enchant / brew / cook -> `330/331/332/333`
- knowledge: skill / spell / lore book -> `340/341/342`; word wall / skill-up
  (`player.incPCS <skill>`) / new location -> `343/344/345`
- devotional: sleep outside vs inside -> `313/314`
- transgression: owned lock / **trespass** / steal / assault innocent ->
  `360/`**`361`**`/362/364`; raise undead -> `365`; daedric artifact -> `368`

Required to record:

- each event fires its EventBus marker with the CSV-exact delta
- **Trespass `361`** specifically (newest wiring; enter an owned home uninvited and
  detected) -- confirm `event 361` fires
- race-gate negative: a non-native god scores `0` for the same act
- attribution filter: environmental/indirect kills log
  `skipped non-scoring attribution`
- anti-farm (DebugLevel 3): a capped act stops at its daily cap; `0.7^n` decay
- dawn bank: `PietyToday -> Piety` at ~06:00 moves standing/tier

**Progress 2026-06-10 (Imperial origin):** `300` (akatosh/Arkay/Stendarr +0.5),
`301` (Stendarr +0.75), `345` (Kynareth +0.5) confirmed, all CSV-exact; race-gate
and attribution filter confirmed. Remaining: craft / book / sleep / the full
transgression set incl. `361`, plus `1`/`2` (set `PDV_GLO_OriginRace to 0`).

### 6. Run The Prince V2 Path-Deepening Proof

The 16 Daedric paths deepen their OWN piety from ambient acts ONLY when the path is
committed (open). Off an open path, ambient acts must do nothing
(deepen-not-initiate). Source: `PDV_PrinceLikesDislikes_V2_Spec.md`; data:
`PDV_DeityLikesDislikes_Princes_V2.csv`.

Positive marker: `[PDV] PrinceV2: <Prince> event <id> deepen <x>`.

Per a transgressive Prince (e.g. Namira):

- deepen-not-initiate negative: BEFORE committing, do a liked act -> **no** PrinceV2
  marker and no path-piety change
- open the path: MCM -> Devotion -> Debug -> Daedric, force 3 commitment signals
- with the path open, repeat the liked act -> PrinceV2 marker fires; the MCM Daedric
  contract summary `p=` rises
- anti-farm holds on the path (DebugLevel 3)

Dual-face check (Azura / Boethiah / Mephala / Malacath):

- as an OFF-race origin (`set PDV_GLO_OriginRace to 0`), open the **Azura PATH** ->
  `PrinceV2: Azura` fires
- as a native origin (`5` Dunmer / `6` Khajiit), confirm Azura is the **deity** face
  (a V1 `EventBus` line, not PrinceV2) and the path stays inert (no double-dip)

Curse coordination: with the werewolf curse active (Hircine path open), a beast kill
deepens Hircine path piety with **no** double-fired curse transition.

Required to record: per-Prince deepen marker, deepen-not-initiate negative, dual-face
both directions, curse no-double-fire.

## Evidence Intake Rule

Use these statuses in the structured ledgers:

- `pending`: not yet run or not enough evidence
- `evidence-recorded`: observed in game and described in the note
- `not-applicable`: only when the packet explicitly does not require the slot

Do not write `pass`, `complete`, or `done` into
`PDV_Phase20_ManualEvidenceLedger.json`; the beta gate derives pass/conditional
from evidence plus known-issue scope.

## Stop Conditions

Stop the packet and bring back notes if any of these happen:

- accepted source fires for the wrong race
- generic gameplay becomes a scoring faucet
- a generic day-to-day act scores a god NOT native to the player's race (race-gate leak)
- an UNcommitted transgressive Prince path deepens from an ambient act (deepen-not-initiate violation)
- Survey/status text shows route IDs instead of player-facing wording
- a reward or price stacks invisibly or cannot be explained from the UI
- Prisma/MCM opens as a blocking panel when only a toast or notification is expected
- save/load changes the visible state unexpectedly
