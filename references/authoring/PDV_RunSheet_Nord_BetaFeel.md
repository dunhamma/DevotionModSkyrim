# PDV In-Game Run-Sheet -- Nord

Status: final pre-beta gap sheet. Created 2026-06-27.
Companions: `PDV_BetaTestPacket_Nord.md`, `PDV_Phase18_StatusNord_Runbook.md`, `PDV_InGameTestingNeeded_Runbook.md`, `PDV_RunSheet_Universal_Prisma_V1.md`.

This sheet proves the current Nord final-run surface: Old Ways book routing, Hircine/Arkay edge routing, broad-vs-focused stack clarity, the 2026-06-27 Nord neglect batch, Talos betrayal debug route, and embedded Prisma display checks.

## Proof Key

- ROUTE/RUNTIME: Papyrus marker, checker output, piety movement, or Active Effects state.
- MANUAL: Survey, stack legibility, Prisma, save/load, and feel.
- DEFERRED: dense organic hook coverage not yet exposed through exact V1 sources.

## Preflight

1. Use a disposable new save or main-menu `coc qasmoke`.
2. Disable `Devotion - Living Deities Test` in MO2.
3. Enable MCM Developer Options.
4. Console:

```text
set PDV_GLO_OriginRace to 0
set PDV_GLO_DebugLevel to 2
```

Origin index `0` is Nord. Use MCM Debug for seeding; do not use CallQuestFunction.

## Fast Lane

### 1. Old Ways Accepted Route

Add and read the representative Old Ways book:

```text
player.additem 000ED161 1
```

`000ED161` is `Book1CheapNordsArise`.

Watch:

- Prisma overlay toast preferred; vanilla top-left only if Prisma is unavailable or the toast send fails.
- No forced full Prisma panel.
- Survey Devotion explains broad/focused Old Ways, patron state, and recent event.

Checker:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race nord --strict-manager
```

Expected marker:

```text
RouteNordOldWaysState complete:
```

### 2. Hircine/Arkay Edge Route

Add and read:

```text
player.additem 000F683F 1
```

`000F683F` is `CR12TotemsOfHircine`.

Expected marker:

```text
RouteNordHircineArkayEdge complete:
```

Pass: the edge source routes without making generic animal kills or tomb travel count as proof.

### 3. Non-Kyne Commitment Offer

Use MCM Debug:

1. `Selected deity` -> choose a non-Kyne Nord-eligible god, such as Talos, Shor, Tsun, Stuhn, Mara, Arkay, Akatosh, Stendarr, Zenithar, Dibella, Julianos, or Kynareth.
2. Set Target piety to `55`.
3. Click `Apply target piety`.
4. Click `Seed commitment signals`.
5. Click `Run dawn pass`.

Pass: a commitment offer fires for the selected non-Kyne deity. Known copy gaps in prompt labels are editorial unless the offer fails to fire.

### 4. Nord Neglect Stack, 2026-06-27 Batch

Use a focused Nord patron. Kyne and Talos are the priority checks.

1. Select Kyne or Talos as active patron.
2. Set Target piety to `5`.
3. Click `Apply target piety`.
4. Click `Run dawn pass` until neglect applies.
5. Open Magic -> Active Effects.

Expected:

- Kyne neglect: `ResistFrost -8`.
- Shor, Tsun, Stuhn, and Talos each have per-patron neglect spells available and should apply only for the neglected committed patron.
- Top-left fallback: `<Deity>'s regard fades as your devotion goes quiet.`
- Survey recent-events names the lapse in fiction voice.

### 5. Talos Betrayal Creed Runtime

Use a focused Talos path.

1. Select Talos as active patron and set piety above `50`.
2. Click `Run dawn pass`.
3. Use MCM Debug -> `Talos betrayal -2`.
4. Record piety movement and Survey/recent-event text.
5. Repeat with `Talos betrayal -3`.

Expected:

- Talos piety drops by the debug route amount.
- The route surfaces once per valid action and does not repeat-spam.
- Imperial Concordat raw movement may also occur if the route is explicitly Imperial-facing, but for Nord the pass criterion is Talos piety loss and readable surfacing.
- Organic quest/dialogue betrayal detection is not implemented and is not a blocker for this sheet.

### 6. Wrong-Origin Rejection

Clean reload if the book is already consumed.

```text
set PDV_GLO_OriginRace to 1
player.additem 000ED161 1
```

Read the book. Expected: no Nord manager state, no Nord Survey movement, no Nord reward.

Reset:

```text
set PDV_GLO_OriginRace to 0
```

### 7. Generic-Source Silence

Origin 0. Try generic look-alikes:

- Generic kill.
- Generic travel.
- Generic tomb clear.
- Generic sleep.
- Generic crafting.
- Generic anti-Thalmor violence.
- Repeated ordinary shrine activity.

Expected: no dense-hook over-trigger and no universal Nord reward stack.

### 8. Prisma Embedded Checks

- Toast: Old Ways, edge, commitment, neglect, and betrayal events should use Prisma overlay toasts first, with top-left fallback only if Prisma is unavailable; none should force a full panel.
- Panel: manually open Devotion panel; ESC and X close it.
- Chronicle: tier-up, commitment, neglect, and betrayal/dawn digest entries are readable if emitted; no blank line.
- Ledger: Old Ways and edge source rows appear; generic-source silence does not add rows.
- No input trap after combat, MCM, Survey, or save/load.

## Closeout

Before log rotation:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race nord --strict-manager
```

Capture Active Effects after:

- expected focused patron build
- neglect build
- Hircine/Arkay edge read

| Slot | Proof | Status | Note |
|---|---|---|---|
| Old Ways route | ROUTE/RUNTIME | | |
| Hircine/Arkay edge | ROUTE/RUNTIME | | |
| Non-Kyne offer | ROUTE/RUNTIME + MANUAL | | |
| Neglect spell stack | ROUTE/RUNTIME + MANUAL | | |
| Talos betrayal | ROUTE/RUNTIME + MANUAL | | |
| Wrong-origin rejection | ROUTE/RUNTIME | | |
| Generic-source silence | ROUTE/RUNTIME | | |
| Prisma surfaces | MANUAL | | |
| Save/load sanity | MANUAL | | |
