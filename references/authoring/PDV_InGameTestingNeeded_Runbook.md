# PDV In-Game Testing Needed Runbook

**Created:** 2026-06-10  
**Status:** Active manual/runtime handoff after Nord route-entry drift repair and Bosmer DA05 source fill  
**Companions:** `PDV_BetaTestPacket_*.md`, `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_DaedricInGameSmokePacket.md`, `PDV_DaedricRuntimeEvidenceLedger.json`, `PDV_BetaFeelReleaseGate.md`, `PDV_FaucetDetection_CKChecklist.md`, `PDV_DeityLikesDislikes.csv`, `PDV_PrinceLikesDislikes_V2_Spec.md`

## Purpose

This is the current testing queue. It starts after repo-side readback and
verifier work. Passing these checks requires in-game runtime/manual evidence;
do not replace them with source review, QASmoke-only route proof, or verifier
output.

## Preflight Before Opening Skyrim

Run from `C:\Users\Admin\Documents\Devotion Mod Project`:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-route-entries
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-source-fill
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-exact-stage-gates
node .\tools\pdv_phase20_base_wiring_audit.mjs
node .\tools\pdv_beta_readiness_audit.mjs --strict --json
```

Expected before manual testing:

- Route entries: `PASS`, including all 24 manifest route entries.
- Base wiring audit: `PASS`.
- Beta readiness audit: still `NOT_BETA_READY` until manual/runtime slots are
  recorded.

## Testing Order

### 1. Close The Smallest Race Evidence Gaps

Run these first because they are already mostly proven.

- Altmer: capture the remaining reward/Active Effects or correct patron/tier
  stack snapshot in `PDV_BetaTestPacket_Altmer.md`.
- Khajiit: confirm asset status/no-new-mesh for the wired lunar packet in
  `PDV_BetaTestPacket_Khajiit.md`.

After each pass, update only the matching slot in
`PDV_Phase20_ManualEvidenceLedger.json`.

### 2. Run The New Bosmer DA05 Packet

Use `PDV_BetaTestPacket_Bosmer.md`.

Required checks:

- Bosmer origin, DA05 stage `100`: accepted Y'ffre hunt-law pressure route.
- Bosmer origin, DA05 stage `105`: accepted mercy-branch edge route.
- Wrong-origin rejection for the same DA05 route.
- Generic-source silence for hunting, forest travel, trade, theft, broad plant,
  kindness, and generic book/source attempts.
- Survey/status clarity after the accepted branch.
- Reward/stack snapshot and short feel note.

After closing Skyrim:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --race bosmer --strict-manager
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
  detected) — confirm `event 361` fires
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

