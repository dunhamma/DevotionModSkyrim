# PDV In-Game Beta-Feel Run-Sheet -- Imperial

Status: DRAFT (no-deploy prep)
Created: 2026-06-19
Provenance: drafted from `references/authoring/PDV_BetaTestPacket_Imperial.md`,
`race-sheets/Race_Imperial.md`, the Imperial block of
`references/authoring/PDV_Phase20_ManualEvidenceLedger.json`, the Imperial trigger
surfaces in `references/authoring/PDV_Phase20ImperialImplementationCosting.manifest.json`,
the retirement notes in `references/authoring/PDV_Phase7SignalReceivers.manifest.json`,
the cross-cutting caveats in `references/authoring/PDV_BetaTestPacket_INDEX.md`, and the
live Concordat / Survey / MCM logic in the `2026-06-15-final-polish` snapshot of
`PDV__ManagerQuest.psc`, `PDV_MCM.psc`, and `PDV_ReputationTrack.psc`.

This is a DRAFT prep artifact. Nothing here deploys or changes the live build. It
orders the seven required manual-evidence slots into a single in-game session so the
tester collects all of them in one disposable-save run. No FAIL should be logged on a
PENDING step unless current repo evidence confirms the underlying emitter is runnable.

---

## Scope

Focus surfaces for this run-sheet:

- Civic Survey display (Survey Devotion / civic-faith copy).
- Public vs private Talos stack (Talos PIETY pressure vs the Concordat axis).
- Faction / attendance rejection (faction rank, temple attendance, bounty, generic
  lawfulness must not score).
- Concordat standing surface (`PDV_ConcordatStandingTrack` raw value and band label).

Seven required manual-evidence slots, covered in order below:

1. assetStatus
2. surveyStatusClarity
3. stackSnapshot
4. immersiveHookProof
5. wrongOriginRejection
6. genericHookRejection
7. manualFeelNote

---

## Proof-boundary key

Every check is labeled with its proof class. Do not mix them when filling the ledger.

- ROUTE/RUNTIME -- machine or log proof. A Papyrus log marker, a Trace line, or a
  numeric raw-value move. Objective; backstops a manual read.
- MANUAL-ACCEPTANCE -- tester judgment on felt quality (clarity, voice, "reads as
  civic"). No log marker; the tester's reading is the evidence.

A slot can require both. Where it does, the run-sheet calls out which step is which.

---

## Preflight (do once)

- New disposable save, or `coc qasmoke`. Imperial state inits ONLY on a NEW save or
  `coc qasmoke` -- old saves keep stale Concordat / curse / gate state.
- In MO2, DISABLE `Devotion - Living Deities Test` before launch (it is an isolated
  test mod and pollutes state).
- Debug seeding is the MCM Debug page, not CallQuestFunction. Open
  MCM Player page -> Developer Options -> Debug page. Standard `set` / `coc` are fine.
- Seed origin and debug level from the console:

  ```text
  set PDV_GLO_OriginRace to 1
  set PDV_GLO_DebugLevel to 2
  ```

  Origin index `1` is Imperial.

- Concordat readout lives on the MCM Debug page under the `Phase 8 Concordat`
  header. Four disabled text rows: `Raw value`, `Committed state`, `Pending state`,
  `Extreme gate`. Concordat ACTION buttons live in the right-hand `Race signals`
  column: `Concordat defiance`, `Concordat compliance`, `Talos shrine defiance`,
  `Unlock Concordat gate`.

- One-time prefix read (only needed for the PENDING signal-RefID steps in slot 4).
  The `PDV_REFR_*Signal` proof objects are invisible, nameless activators. Read the
  2-hex plugin prefix XX once off a NAMED blessing, then reuse it:

  ```text
  help "HoonDing" 0
  ```

  Take the first two hex digits of the returned `SPEL:` FormID as XX. Fire a signal
  with `prid XX<refid>` then `activate player` (NOT bare `activate`). Never guess XX.

---

## Ordered evidence checklist

### Slot 1 -- assetStatus (MANUAL-ACCEPTANCE, desk check)

- Seed: none. This is a contract read, not an in-game action.
- Action: confirm every Imperial immersive-hook contract has explicit asset status.
  The current contract target is NO required new custom mesh. The four Imperial
  trigger surfaces (routes 110-113) in
  `PDV_Phase20ImperialImplementationCosting.manifest.json` are ACTI/REFR proof
  objects, not authored art.
- Watch: each of `PDV_REFR_ImperialCivicServiceSignal` (110),
  `PDV_REFR_ImperialTalosPressureSignal` (111),
  `PDV_REFR_ImperialFocusedPatronSignal` (112),
  `PDV_REFR_ImperialCreedLossSignal` (113) carries
  `placementStatus: proof-cell-pending`. The retired hidden-shrine receiver
  `PDV_REFR_TalosShrineDefianceSignal` (Phase 7) must NOT be reattached to the
  visible Windhelm shrine.
- PASS: no Imperial hook requires a new custom mesh; the four proof-cell signals are
  the only asset-bearing contracts and all are accounted for as pending placements,
  not missing art. If any hook is found to need a new mesh, NAME the missing asset
  in the results table instead of passing.

### Slot 2 -- surveyStatusClarity (MANUAL-ACCEPTANCE)

- Seed (MCM Debug): set a clean readable state before reading Survey.
  - Pick a Divine patron and `Apply target piety` ~30 so the patron line has content.
  - Leave Concordat at default (Uncommitted) for the first read.
- Action: open Survey Devotion (the civic devotion read-out the player sees).
- Watch the Survey copy for FOUR things spelled out in plain fiction voice:
  - Civic faith framed as concrete public practice under law (Nine Divines posture),
    e.g. patron-took-note copy: "Your patron has taken note of the civic good you
    have done in their name."
  - Talos pressure tilt stated as one of three readable states (defiant /
    constrained / not yet tilted): "Your defiance has the old breath leaning your
    way..." vs "Your standing with the Concordat keeps Talos at arm's length..." vs
    "On the Talos question you have not yet leaned either way...".
  - Concordat / public state legible (Uncommitted by default; band shifts later).
  - Concrete act requirements -- the tester can tell WHAT to do, not just a number.
- PASS: Survey reads as concrete civic practice; the four elements above are present
  and in narrator voice, with no raw enum, route ID, or dev counter leaking. (The
  all-race narrator-voice sweep is a known non-blocking gap; only flag a leak if it
  is in Imperial copy specifically.)

### Slot 3 -- stackSnapshot (ROUTE/RUNTIME numeric + MANUAL-ACCEPTANCE read)

The public/private Talos STACK is two separate axes -- prove they are distinct and
that no faction-only reward appears.

- Lawful civic build (baseline read):
  - Seed: patron set, ~30 piety, Concordat Uncommitted.
  - Watch: MCM Debug `Phase 8 Concordat` -> `Raw value` near 0, `Committed state`
    Uncommitted. Active Effects shows only legitimate patron blessings -- NO
    standalone "ConcordatStanding buff" effect (the Concordat track is pressure, not
    a second buff faucet).
- Edge private-Talos defiance build:
  - Seed (MCM Debug): press `Concordat defiance` one or more times to drive the raw
    value negative toward the Private Defiant band.
  - Watch (ROUTE/RUNTIME): `Raw value` moves by the table amount per press; Papyrus
    log shows the defiance route trace. KEY: the `Committed state` band LABEL LAGS
    the raw value via the track lock-in grace -- judge movement by `Raw value`, NOT
    the band label, or you false-FAIL. The Talos PIETY axis (book route) is separate
    from this Concordat axis -- driving Concordat does not itself award Talos piety.
- Point map (for reading expected raw deltas; the two starred emitters are the
  route-proven vanilla hooks, the rest are MCM/desk-confirmable):
  - side_with_stormcloaks  -20  (CW01B Stormcloak join, route-proven) *
  - hidden_talos_shrine    -15  (MCM `Talos shrine defiance` button)
  - help_talos_worshipper_escape -15
  - kill_thalmor_justiciar_unprovoked -10  (player's own killing blow only) *
  - refuse_report_talos_worshipper -5
  - public_observe_talos_ban +5
  - report_talos_worshipper +15
  - attack_talos_worshipper +15
- PASS: the lawful build and the private-defiance build record DIFFERENT Concordat
  raw values, the public/private Talos pressure reads differently between them, the
  active patron is unchanged by Concordat moves, and NO faction-only reward stack
  appears in Active Effects. (Numeric move = ROUTE/RUNTIME; "no rogue buff" read =
  MANUAL-ACCEPTANCE.)

### Slot 4 -- immersiveHookProof (mixed: one ROUTE/RUNTIME runnable now, three PENDING)

This slot proves the immersive hooks fire OUTSIDE QASmoke. Honor the proof boundary:
only the public Talos book route is runtime-wired today.

- 4a. Public Talos pressure book route -- RUNNABLE NOW (ROUTE/RUNTIME):
  - Seed: origin 1 (preflight). Add and read the approved public Talos book from
    inventory normally:

    ```text
    player.additem 000ED04D 1
    ```

    `000ED04D` is `Book2ReligiousTalosWorship`.
  - Where to stand: anywhere; this is an inventory read, not a location trigger.
  - Watch: top-left notice / proven toast only ("The name of Talos: The question of
    the Ninth presses harder."). NO forced full Prisma panel. After closing Skyrim,
    run the backstop checker before log rotation:

    ```powershell
    node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial --strict-manager
    ```

    Expected Papyrus log marker: `RouteImperialTalosPressure complete:`.
  - NOTE: this book routes the Talos PIETY axis, NOT a Concordat point. Do not log it
    as a Concordat action.
  - PASS: toast fires, no forced panel, and the marker is present in the log.

- 4b. Concordat vanilla emitters -- RUNNABLE NOW via build-pass hooks (ROUTE/RUNTIME):
  - Stormcloak-side defiance: MCM Debug `Concordat defiance` button is the quick
    proxy; expected trace `Concordat pressure -20 ... adjustment -20`. The real
    vanilla hook is CW01B stage 200 (`SendModEvent("PDV.ConcordatDefiance")`).
    Compliance / CW01A Legion join stays +15 via `Concordat compliance`.
  - Kill a Thalmor Justiciar: PLAYER'S OWN killing blow on a `ThalmorFaction` member
    (`00039F26`) who is not a pre-set enemy. Expected trace `Concordat pressure -10`.
    KILL-CREDIT CAVEAT: scores ONLY the player's own final hit (ATTR_DIRECT_PLAYER);
    ally/environment kills are silent by design -- land the blow yourself or it
    false-FAILs.
  - PASS: each fires its expected raw-value delta in the trace (judge by raw value,
    not band label).

- 4c. Civic service / focused-patron / creed-loss signal RefIDs -- PENDING (do NOT
  FAIL):
  - Routes 110 (`imperial_civic_service_proof`),
    112 (`imperial_focused_patron_proof`), and
    113 (`imperial_creed_loss_proof`), plus the dedicated Talos-pressure signal
    (route 111), are `placementStatus: proof-cell-pending`. The
    `PDV_REFR_Imperial*Signal` references are NOT placed in the world this pass, so
    `prid XX<refid>` + `activate player` has no target to fire yet.
  - When the build pass places these proof cells, fire each with the prefix recipe
    from preflight (`prid XX<refid>` then `activate player`) and watch for the
    matching once-per-day signal and the patron-took-note Survey line.
  - PASS (deferred): mark PENDING until the build session confirms placement. Do not
    record a FAIL.

- 4d. Hidden Talos shrine in-world -- BLOCKED note:
  - The Phase 7 in-world receiver `PDV_REFR_TalosShrineDefianceSignal` was RETIRED
    2026-06-16 (clipping geometry). The MCM `Talos shrine defiance` button still
    routes the signal (`hidden_talos_shrine`, -15) for proof, but there is no
    walk-up shrine to activate in the live world until a new audited receiver lands.

### Slot 5 -- wrongOriginRejection (ROUTE/RUNTIME)

- Seed: flip origin to a non-Imperial value.

  ```text
  set PDV_GLO_OriginRace to 0
  player.additem 000ED04D 1
  ```

- Action: read the Talos book. Optionally open MCM Debug and attempt `Concordat
  defiance`.
- Watch: NO Imperial manager state, reward, or Survey movement. Concordat `Raw value`
  does not move; no civic-faith Survey copy appears as native. A non-Imperial origin
  cannot read Concordat / civic state as native.
- PASS: zero Imperial-native state movement under the wrong origin.
- Reset before the next slot:

  ```text
  set PDV_GLO_OriginRace to 1
  ```

### Slot 6 -- genericHookRejection (ROUTE/RUNTIME, negative class)

- Seed: origin 1 (just reset).
- Action: spot-check 2-3 representative NON-whitelisted triggers. All non-whitelisted
  civic/Talos sources assert the same single invariant (zero state movement), so a
  representative spot-check covers the negative class. Suggested probes:
  - Faction rank gained / temple attendance (stand at / activate a normal vanilla
    shrine, join or rank up in a faction).
  - Ordinary bounty payment alone.
  - Generic anti-Thalmor violence framed as ordinary combat (not a credited Justiciar
    kill), or generic lawfulness / generic Talos proximity.
- Watch: NO civic or Talos state movement. Concordat `Raw value` unchanged; no
  patron-took-note Survey line; no Talos pressure tilt change; no reward stack.
- PASS: faction rank, shrine attendance, generic mercy, generic lawfulness, generic
  Talos proximity, and generic trade do NOT score by themselves.

### Slot 7 -- manualFeelNote (MANUAL-ACCEPTANCE)

- Seed: none new -- this is the tester's synthesis after slots 1-6.
- Action: across the session, judge whether Imperial devotion FEELS like concrete
  civic practice under public law, with Talos faithful-defiance and ConcordatStanding
  shaping PRESSURE rather than acting as a parallel buff track.
- Watch / reflect on: did the Survey teach which concrete acts scored and why
  faction/attendance/bounty did not? Did public vs private Talos read as a real fork?
  Did the Concordat band feel like a slow political spine, not a per-action toggle?
- PASS: Imperial religion reads as concrete civic practice under public law, not
  generic faction or morality tracking. Record one or two sentences of felt-quality
  note, plus any voice/clarity nit for the narrator-voice sweep.

---

## Known gotchas

- Band LABEL lags raw value. `PDV_ConcordatStandingTrack` commits its band via a
  lock-in grace, so a single signal moves the raw value but may not flip the
  `Committed state` label. Prove emitters by `Raw value` in the trace, not the band.
  StateLabels are value-ordered, so a mismatch never self-cancels.
- The book is a PIETY axis, not Concordat. Reading `000ED04D` routes
  `RouteImperialTalosPressure` (Talos piety), NOT a Concordat point. Never test the
  book as a Concordat action.
- Kill credit is player-only. The Justiciar kill scores ONLY the player's own killing
  blow (ATTR_DIRECT_PLAYER). At a crowd fight an ally can steal the credit -- land
  the final hit yourself.
- coc skips location-change triggers. `OnStoryChangeLocation`-style anchors do NOT
  fire on `coc`. Any future location-anchored Imperial hook needs a load-door entry
  or fast-travel, never a `coc` straight into the cell. (Today's runnable Imperial
  hooks are inventory- and MCM-driven, so this mainly matters for future proof cells.)
- Vampire-halt is dawn-consolidated, not earn-time. The Nine Divines halt voids gain
  at DAWN consolidation, so earn-while-vampire-then-cure-BEFORE-dawn still grows
  (correct; moot in normal play because auto-dawn fires while still undead). Test the
  accrual halt ONLY while still vampire. Curse posture labels surface as `civic faith
  halted` (vampire) / `civic faith strained` (werewolf) / `civic faith scarred`
  (post-cure, one-way).
- Signal RefIDs are nameless invisibles. Routes 110-113 are proof-cell-pending and
  NOT placed this pass, so `prid XX<refid>` has no target yet. When they land, read
  XX once from a NAMED blessing (`help "HoonDing" 0`) and use `prid XX<refid>` +
  `activate player` (NOT bare `activate`).
- Hidden shrine in-world is retired. Do not reattach
  `PDV_REFR_TalosShrineDefianceSignal` to the visible Windhelm shrine. Use the MCM
  `Talos shrine defiance` button for the -15 route proof until a new audited receiver
  is placed.
- MCM only, not CallQuestFunction. All debug seeding is MCM Player page -> Developer Options ->
  Debug. Standard `set` / `coc` are fine.

---

## Embedded Prisma Checks

Run these during slots 2-7:

- Talos book and Concordat actions may emit a toast or top-left notice; they must not force-open the full Prisma panel.
- Manually open the Devotion panel after the Talos book read and after a Concordat raw-value move. It should open populated and close with ESC or X.
- Chronicle / Book of Days should not create blank entries for civic/Talos beats or dawn digest.
- Ledger should show the Talos-pressure or civic driver row after an accepted route, and no row after wrong-origin or generic-source probes.
- If the panel shows Concordat or Talos posture, it must agree with MCM Debug `Raw value`/Survey in meaning, even if the committed band label lags.
- Save/load after the private-defiance stack snapshot, reopen the panel, and confirm no stale or doubled UI state.

Prisma failures are UI/presentation failures unless Concordat raw value, Survey, or route logs also fail.

---

## Record results here

Fill one status per slot. Allowed values: PASS / FAIL / PENDING / N-A. Label the
proof class actually achieved (ROUTE-RUNTIME or MANUAL-ACCEPTANCE) so the ledger
intake stays boundary-clean. Do NOT log FAIL on a PENDING route step.

| Slot | Surface | Proof class | Status | Note |
|---|---|---|---|---|
| 1 assetStatus | No required new mesh; 4 proof-cell signals accounted for | MANUAL-ACCEPTANCE | | |
| 2 surveyStatusClarity | Civic Survey: civic faith + Talos tilt + Concordat + act reqs | MANUAL-ACCEPTANCE | | |
| 3 stackSnapshot | Lawful vs private-defiance build; raw value differs; no rogue buff | ROUTE-RUNTIME + MANUAL | | |
| 4 immersiveHookProof (4a book) | RouteImperialTalosPressure marker | ROUTE-RUNTIME | | |
| 4 immersiveHookProof (4b Concordat) | Stormcloak -20 / Justiciar -10 traces | ROUTE-RUNTIME | | |
| 4 immersiveHookProof (4c signals 110/112/113) | Proof cells pending placement | PENDING | | |
| 5 wrongOriginRejection | Non-Imperial origin: zero native movement | ROUTE-RUNTIME | | |
| 6 genericHookRejection | Faction/attendance/bounty/lawfulness do not score | ROUTE-RUNTIME | | |
| 7 manualFeelNote | Reads as concrete civic practice under law | MANUAL-ACCEPTANCE | | |
| 8 Prisma surfaces | Toast/panel/Chronicle/Ledger agree with manager state | MANUAL-ACCEPTANCE | | |

Blocking notes:

After the run, before log rotation, run the backstop checker
(`node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race imperial
--strict-manager`), then fill `PDV_Phase20_ManualEvidenceLedger.json` (Imperial
block) and only then update the verdict in `PDV_PreBetaRaceGateLedger.md`. Per ledger
convention, do NOT mark the Imperial race-level `status` as `pass` from this sheet --
keep it `pending` until the in-game evidence is recorded and any pending proof cells
are placed and proven.
