# PDV Daedric 16-Prince Beta-Feel Packet

Created: 2026-06-14
Status: ready to run NOW (no dependency on the concurrent race build pass)
Mode: console-assisted + MCM-driven (standard `set` / `coc`; debug seeding via
the MCM Debug page, NOT `cqf`)

**Goal:** carry runtime/display evidence for all sixteen Skyrim-present Daedric
Princes so the Daedric half of Global Stop Condition 6 can flip from PENDING.
Jyggalag is EXCLUDED. This is the tester-facing runbook companion to
`PDV_DaedricInGameSmokePacket.md`, `PDV_DaedricControlledProof_Runbook.md`, and
the structured ledger `PDV_DaedricRuntimeEvidenceLedger.json` (intake tool
`tools/pdv_daedric_evidence_intake.mjs`).

> The structured ledger already records every required slot as `pass` for all 16
> Princes, because the proof mechanism is SHARED (one EventBus -> Manager
> downstream; one Prisma/Active-Effects/summary path) and several slots were
> descoped to pass after static verification (`organicRoute` via
> `pdv_daedric_queststage_check`, `qasmokeRoute` as a test-only scaffold). This
> packet is the runnable procedure to (re)confirm that shared evidence in game
> and to let a tester judge feel. Treat readback alone as NOT proof -- a slot is
> only "pass" after the in-game observation or an explicit descope note.

## The proven pact model (read first)

- **One active pact, HARD SWITCH.** Only the latest pact's boon + price are live.
  Forming a new pact replaces the old one entirely -- the Active Effects menu
  must NEVER show two Prince boons or the whole roster at once.
- **Curse persists across a pact switch.** A lycanthropy/vampirism curse-state
  (Hircine, Molag Bal) does NOT clear or re-fire when you switch pacts. It holds
  at its current state with no extra transition. This is the no-double-fire
  guarantee in Section G.
- **High stakes by design.** Each pact reads as a build-defining Faustian bargain
  (sharp ~2x god-tier boon, a real price), distinct from ordinary worship.

## Universal setup (do once)

1. Start on a NEW save or main-menu `coc qasmoke`. Curse/pact state inits ONLY on
   a fresh manager state -- old saves keep stale values. Disable `Devotion -
   Living Deities Test` in MO2 first.
2. `set PDV_GLO_DebugLevel to 2`. (Origin race does not gate pacts; pacts are
   cross-race. Native-integration routing for Dunmer/Khajiit/Orc is exercised in
   Section H.)
3. MCM -> Devotion -> Player page -> enable **Developer Options**, open the
   **Debug page** (the **Daedric & Curse** controls: `Route all Princes`,
   `Force Seeker` / `Force Devoted` / `Force Champion`, `Curse vampire` /
   `Curse werewolf` / `Curse none`).
4. Read `Logs\Script\Papyrus.0.log` after each run (debug 2 prints the `[PDV]`
   traces).
5. **Read your plugin prefix XX once.** The `PDV_REFR_Daedric_*` QASmoke senders
   are INVISIBLE, nameless activators -- `help` on them returns nothing. Read XX
   off a NAMED PDV blessing: `help "HoonDing" 0` -> the `SPEL:` FormID's first
   two hex digits = XX. (QASmoke senders also have ACTI EditorIDs you can place;
   see `PDV_DaedricInGameSmokePacket.md` for the placeAtMe table.)

## False-FAIL caveats (bake these into your method)

- `coc` does NOT fire Story location-change triggers. None of the Daedric routes
  below depend on a location change (they are MCM, QASmoke RefID, or `setstage`),
  so this does not bite the Daedric packet directly -- but if you chain a race
  lever that does (Bosmer Songs, Argonian Waters, Dunmer outdoor shrine), enter
  via a load door / fast-travel.
- Debug seeding is MCM-driven, NOT `cqf`. Standard `set` / `coc` are fine.
- Fire QASmoke senders by RefID: `prid XX<refid>` + `activate player` (NOT bare
  `activate` -- it needs the activating actor). Never guess XX; read it from a
  named blessing.
- Curse-access gate/curse state inits ONLY on a NEW save.
- Kill-based beats (if you prove Hircine/Molag onset via an actual feeding/
  transformation kill rather than the curse buttons) score ONLY the player's own
  killing blow (ATTR_DIRECT_PLAYER); an ally or environmental kill is silent by
  design -- at a crowd fight a follower can steal the credit. The MCM `Curse`
  buttons sidestep this; use them for the no-double-fire proof.

## A. Fast all-Prince route sweep (slots: mcmRoute, genericSilence,
prismaNotification)

1. MCM Debug -> **Daedric & Curse** -> `Route all Princes`. This routes all 16
   EventBus sender cues + the generic-source silence probe in one prompt.
2. After closing Skyrim:

```text
node .\tools\pdv_daedric_runtime_check.mjs --prince all --strict-manager --source mcm --include-generic
```

3. **PASS:** all 16 route markers present; the generic silence probe leaves
   piety/tier/stigma/Active Effects unchanged; the shared Prisma toast mechanism
   sent (Seeker + Champion toasts `sent=TRUE`).
4. Record:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source mcm --prince all --include-generic
```

## B. Per-Prince controlled display proof (slots: activeEffects, summaryMessage,
prismaNotification)

Sweep the roster (or a representative subset per batch) via MCM Debug ->
**Daedric & Curse**:

1. Select the Prince, `Force Seeker` -> `Show Prince summary` shows the authored
   per-Prince entry line (fiction, NO route id). Active Effects shows the Seeker
   boon + paired price.
2. `Force Devoted`, then `Force Champion` -> Active Effects shows exactly ONE
   boon + ONE price at the current tier (never two Princes).
3. Drop the pact (form a different one or use the lapse control) -> the lapse
   line shows and the boon/price clear.
4. **PASS per Prince:** entry/tier/lapse copy is fiction-facing and legible;
   Active Effects carries one boon + one price; the Prisma/notification toast
   fires for commitment / boon / price / lapse.

Batch coverage (matches the ledger): Pilot Boethiah; Batch 0 Azura, Vaermina,
Meridia, Molag Bal; Batch 1 Mephala, Malacath; Batch 2 Mehrunes Dagon,
Sheogorath, Namira, Sanguine, Clavicus Vile, Hermaeus Mora, Nocturnal; Batch 3
Peryite, Hircine.

## C. Organic quest-stage route proof (slot: organicRoute)

From a throwaway save where PO3 quest-stage events are active and
`PDV_PlayerEvents` has loaded, fire the exact terminal stage. The `--source
organic` checker requires the exact `eventbus_200_po3_queststage_daedric_*`
marker, so an MCM/QASmoke route cannot count as organic proof.

| Prince | Console route | Note |
|---|---|---|
| Boethiah | `setstage DA02 100` | |
| Azura | `setstage DA01 100` | |
| Vaermina | `setstage DA16 190` | Skull branch after killing Erandur; NOT stage 200 |
| Meridia | `setstage DA09 500` | |
| Molag Bal | `setstage DA10 200` | Curse-access; also needs Section G |
| Mephala | `setstage DA08 60` | |
| Malacath | `setstage DA06 200` | |
| Mehrunes Dagon | `setstage DA07 100` | |
| Sheogorath | `setstage DA15 200` | |
| Namira | `setstage DA11 100` | |
| Sanguine | `setstage DA14 200` | |
| Clavicus Vile | `setstage DA03 200` | |
| Hermaeus Mora | `setstage DA04 100` | |
| Nocturnal | `setstage TG09 200` | Nightingale oath surface; judge oath feel |
| Peryite | `setstage DA13 100` | |
| Hircine | `setstage DA05 100` | Content-surface proof; NOT lycanthropy curse-onset |

Per-Prince checker / intake:

```text
node .\tools\pdv_daedric_runtime_check.mjs --prince <Stem> --strict-manager --source organic --no-generic
node .\tools\pdv_daedric_evidence_intake.mjs --from-runtime-check --source organic --prince <Stem> --no-generic
```

(`<Stem>` = Boethiah, Azura, Vaermina, Meridia, Molag, Mephala, Malacath, Dagon,
Sheo, Namira, Sanguine, Vile, Mora, Nocturnal, Peryite, Hircine.) The ledger
records organicRoute as descoped-to-pass via `pdv_daedric_queststage_check`
(16/16 static FormID+stage) plus the in-game Hircine DA05 proof of the shared
PO3 mechanism; run the per-Prince organic stages here only where you want a live
re-confirmation.

## D. One-active hard switch (slot: stackLegibility)

1. `Force Champion` on Prince A -> Active Effects: one boon + one price.
2. `Force Champion` on Prince B -> Active Effects swaps entirely to B; A is gone.
3. `Force Champion` on Prince C -> only C. Never A+B+C, never the roster.
4. **PASS:** only the latest pact's boon + price are ever live.

## E. Save/load sanity (slot: saveLoad)

With one standard pact, one native/tolerated pact, and one curse-access pact
active in turn: save, reload, and confirm the single active pact + its boon/price
+ tier/piety survive unchanged.

## F. Generic-source silence (slot: genericSilence)

Covered by the `Route all Princes` probe in Section A and the QASmoke generic
probe (`PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`, route 201). Confirm a
generic Daedric-adjacent act (ordinary shrine visit, generic artifact carry,
random Daedra kill) leaves piety, tier, signal count, stigma, and Active Effects
unchanged.

## G. Curse no-double-fire -- HIRCINE and MOLAG BAL only (slot: curseNoDoubleFire)

The two curse-access Princes must coordinate with race CurseState rows WITHOUT
double-firing a curse transition when you switch pacts.

1. `Curse vampire` (Molag Bal) or `Curse werewolf` (Hircine) -> note the curse
   onset fires ONCE (state reaches 2).
2. Form/force a Molag Bal (or Hircine) pact, then `Force Champion` on a DIFFERENT
   Prince (e.g. Mehrunes Dagon) -> the curse must HOLD at state 2 with NO second
   transition line, while the pact hard-switches normally.
3. **PASS:** curse persists across the pact switch; no duplicate curse-state
   transition. (Log-confirmed pattern, 2026-06-13: Molag active+vampire ->
   switch to Mehrunes Dagon -> curse held at state 2, no transition after onset.)
4. Record:

```text
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Molag --slot curseNoDoubleFire --status pass --note "<observation>"
node .\tools\pdv_daedric_evidence_intake.mjs --record --prince Hircine --slot curseNoDoubleFire --status pass --note "<observation>"
```

This slot is `not_required` for the other 14 Princes.

## H. Race/Daedric stack legibility + feel (slots: stackLegibility, manualFeel)

1. On a real race expected build (e.g. Khajiit lunar, Nord Old Ways, Dunmer
   Reclamation), form ONE Prince pact as the Daedric edge.
2. Survey Devotion + Active Effects must read legibly: the race substrate/foundation
   PLUS exactly one Prince pact (one boon + one price) -- no overstack, no second
   substrate.
3. Native-integration check: on Dunmer (Good Daedra: Azura/Boethiah/Mephala),
   Khajiit, and Orc (Malacath/Mauloch), confirm the native Prince routes through
   the documented no-native-row behavior rather than spawning a duplicate row.
4. **Feel note:** does the pact read as a sharp, build-defining bargain distinct
   from ordinary worship? Record one line per Prince batch.

## Closing automated gates (re-run after the sweep)

```text
node .\tools\pdv_daedric_evidence_intake.mjs --summary
node .\tools\pdv_daedric_beta_gate.mjs
dotnet run --project .\tools\pdv-daedric-author\PdvDaedricAuthor.csproj -- --check
node .\tools\pdv_content_verify.mjs
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
```

`pdv_daedric_beta_gate.mjs` is the fail-closed promotion gate; it should report
the roster green once the intake ledger slots are filled from in-game evidence.

## Per-Prince evidence to bring back

```text
Prince:
A  MCM route + generic silence: PASS/FAIL
B  Active Effects (Seeker/Devoted/Champion/lapse, one boon + one price): PASS/FAIL
B  Show Prince summary (fiction line, no route id): PASS/FAIL
B  Prisma/notification (commitment/boon/price/lapse): PASS/FAIL
C  Organic quest-stage route: PASS/PENDING (descope-accepted)/FAIL
D  One-active hard switch: PASS/FAIL
E  Save/load sanity: PASS/FAIL
G  Curse no-double-fire (Hircine + Molag Bal only): PASS/FAIL/N-A
H  Race/Daedric stack legibility + feel: PASS/FAIL
Feel note:
Blocking notes:
```
