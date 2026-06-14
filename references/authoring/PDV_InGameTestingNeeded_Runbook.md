# PDV In-Game Testing Needed Runbook

**Created:** 2026-06-10  
**Status:** Active manual/runtime handoff after Bosmer DA05 proof intake and Bosmer runtime-fix live write
**Companions:** `PDV_BetaTestPacket_*.md`, `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_DaedricInGameSmokePacket.md`, `PDV_DaedricRuntimeEvidenceLedger.json`, `PDV_SessionHandoff_HircineAuditFixes.md`, `PDV_SessionHandoff_BosmerRuntimeFixes.md`, `PDV_BetaFeelReleaseGate.md`, `PDV_FaucetDetection_CKChecklist.md`, `PDV_DeityLikesDislikes.csv`, `PDV_PrinceLikesDislikes_V2_Spec.md`

## Purpose

This is the current testing queue. It starts after repo-side readback and
verifier work. Passing these checks requires in-game runtime/manual evidence;
do not replace them with source review, QASmoke-only route proof, or verifier
output.

2026-06-12 handoff note: the Hircine source/VMAD display drift is fixed and
compiled, so Hircine should be tested first in the Daedric proof session. See
`PDV_SessionHandoff_HircineAuditFixes.md` for the exact route and evidence
commands. This is still compile/readback proof only until runtime/manual slots
are recorded.

2026-06-13 handoff note: Bosmer DA05 route/manual proof is partially recorded,
and the Naming/neglect/reward-copy fixes were written after Skyrim closed. See
`PDV_SessionHandoff_BosmerRuntimeFixes.md` before continuing Bosmer. Restart
Skyrim before retesting; the previous live session had old manager script state.

## Preflight Before Opening Skyrim

Run from `C:\Users\Admin\Documents\Devotion Mod Project`:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_verify.mjs --strict-phase20-altmer --strict-phase20-race-costing --json
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
node .\tools\pdv_refresh_seq.mjs --write --json
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Expected before manual testing:

- Route entries: `PASS`, including all 24 manifest route entries.
- Base wiring audit: `PASS`.
- Strict Phase 20 verifier and Phase 2 reward readback audit: `PASS`; SEQ
  refresh has no stale/missing entry warning.
- Beta readiness audit: still `NOT_BETA_READY` until manual/runtime slots are
  recorded.

Known caveat: `pdv_phase2_reward_readback_audit` currently has one unrelated
Khajiit Baan Dar T3 capstone script failure. Do not treat that as a Bosmer
blocker; handle it in a separate Khajiit readback cleanup slice.

Do not use the older
`dotnet run --project .\tools\pdv-phase20-reward-author\PdvPhase20RewardAuthor.csproj -- --check`
as the blocking reward gate for this manual queue unless that tool or its
first-tier contract is intentionally refreshed. It currently reports stale T1
contract drift across older race records even when the stricter reward readback
audit passes.

## Current Last-Pass Blocker Snapshot

As of the 2026-06-10 sweep, the active beta-feel blockers are manual/runtime
evidence only. Readback and verifier gates are necessary preflight, but they do
not close these rows.

Race ledger blockers from `PDV_Phase20_ManualEvidenceLedger.json`:

| Race | Pending manual/runtime slots |
| --- | --- |
| Altmer | none for current beta packet; final-world placement remains separate |
| Khajiit | none for current beta packet; final-world placement remains separate |
| Argonian | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Bosmer | `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Breton | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Dunmer | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Imperial | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Nord | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Orc | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |
| Redguard | `wrongOriginRejection`, `genericHookRejection`, `surveyStatusClarity`, `stackSnapshot`, `manualFeelNote`, `immersiveHookProof`, `assetStatus` |

Daedric ledger blockers from `PDV_DaedricRuntimeEvidenceLedger.json`:

- All sixteen Princes remain `pending`.
- Every Prince needs `mcmRoute`, `qasmokeRoute`, `organicRoute`,
  `genericSilence`, `activeEffects`, `summaryMessage`, `prismaNotification`,
  `saveLoad`, `stackLegibility`, and `manualFeel`.
- Molag Bal and Hircine also need `curseNoDoubleFire`.

Additional last-pass runtime sweeps before any broad beta-feel claim:

- Day-to-day V1 faucet sweep: finish craft, book, sleep, transgression,
  trespass `361`, events `1` and `2`, anti-farm, attribution filter, race gate,
  and dawn bank checks.
- Prince V2 path-deepening sweep: prove deepen-not-initiate, open-path deepen
  markers, dual-face Azura behavior, anti-farm, and Hircine curse
  no-double-fire.

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

### 2. Run The New Bosmer DA05 Packet

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
- Reward/stack snapshot and short feel note. **Stage 100 reward/survey snapshot
  passed; broader Bosmer stack/feel checks remain pending.**

After each DA05 branch, use the DA05-specific log check in
`PDV_BetaTestPacket_Bosmer.md`. The generic Bosmer runtime checker currently
validates the eight QASmoke proof activators, not DA05.

```powershell
Select-String -Path "$env:USERPROFILE\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log" -Pattern "RouteBosmerYffre|po3_queststage_bosmer_da05|RouteBosmerPactPositive|RouteDaedricPrinceSignal" -Context 1,1
```

### 3. Run The Remaining Race Packets

Use one disposable save per race or a clean reload before each route family.

| Race | Packet | Primary runtime checker |
| --- | --- | --- |
| Argonian | `PDV_BetaTestPacket_Argonian.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race argonian --strict-manager` |
| Orc | `PDV_BetaTestPacket_Orc.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race orc --strict-manager` |
| Redguard | `PDV_BetaTestPacket_Redguard.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race redguard --strict-manager` |
| Breton | `PDV_BetaTestPacket_Breton.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager` |
| Dunmer | `PDV_BetaTestPacket_Dunmer.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race dunmer --strict-manager` |
| Imperial | `PDV_BetaTestPacket_Imperial.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager` |
| Nord | `PDV_BetaTestPacket_Nord.md` | `node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race nord --strict-manager` |

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

After controlled proof:

```powershell
node .\tools\pdv_daedric_runtime_check.mjs --strict
node .\tools\pdv_daedric_beta_gate.mjs --strict
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
