# PDV In-Game Run-Sheet -- Breton

Status: final pre-beta gap sheet. Created 2026-06-27.
Companions: `PDV_BetaTestPacket_Breton.md`, `PDV_Phase20_ManualEvidenceLedger.json`, `PDV_RunSheet_Universal_Prisma_V1.md`.

This sheet is the current Breton final-run surface. It proves the wired Hidden Art lane, confirms the remaining stack/feel gaps honestly, and embeds the Prisma checks needed for the beta pass. It does not mutate evidence ledgers.

## Proof Key

- ROUTE/RUNTIME: Papyrus log marker, checker output, or numeric state movement.
- MANUAL: Survey, Active Effects, Prisma, feel, or save/load observation.
- DEFERRED: no valid V1 emitter or no debug control currently exposed; do not fail it.

## Preflight

1. Use a disposable new save or main-menu `coc qasmoke`.
2. In MO2, disable `Devotion - Living Deities Test`.
3. Open MCM -> Devotion -> Player -> Developer Options, then use the Debug pages for seeding.
4. Console:

```text
set PDV_GLO_OriginRace to 2
set PDV_GLO_DebugLevel to 2
```

Origin index `2` is Breton. Do not use CallQuestFunction for this sheet.

Papyrus log:

```text
%USERPROFILE%\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
```

## Fast Lane

### 1. Hidden Art Accepted Route

Add the three approved Hidden Art sources:

```text
player.additem 000ED60B 1
player.additem 0007EB03 1
player.additem 000DDFB6 1
```

Read each normally from inventory:

- `000ED60B` - `Book2CommonHagravens`.
- `0007EB03` - `Book2CommonMadmenoftheReach`.
- `000DDFB6` - `dunPOIWitchNote`.

Watch:

- Top-left notification or Prisma toast only.
- No forced full Prisma panel.
- Survey Devotion names the Hidden Art tradition and exposure band. After the
  three one-shot books, exposure should be high/known and close to rupture; it
  should not say `notorious` or `full commitment` until exposure reaches 100.
- Survey recent-events text names the beat in fiction voice, with no route IDs.

After closing Skyrim or before log rotation:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager
```

Expected markers:

```text
RouteBretonTraditionChoice complete: 120 tradition 1
RouteBretonHiddenArtExposure complete:
```

### 2. Witchcraft Exposure Decay

After one Hidden Art read, click MCM Debug -> `Run dawn pass` three times.

Watch:

- Log prints `Breton WitchcraftExposure passive decay -> N`.
- Survey exposure band steps down if it crosses a band.
- Prisma/Book of Days does not create a new milestone for each passive decay tick unless the existing UI intentionally summarizes the dawn.

Pass: exposure decays instead of staying a one-way ratchet.

### 3. Stack Snapshot

Use the Hidden Art state from steps 1-2.

Do:

- Open Magic -> Active Effects.
- Open Survey Devotion.
- Open Devotion panel -> Ledger.

Record:

- Active tradition: Hidden Art.
- Current exposure band.
- Any active creed-loss spell. `ExposureRupture` requires exposure >= 100 and is usually not reachable from only the three one-shot books.
- Ledger row for the Hidden Art book route.

Pass: Hidden Art is legible without pretending Knight's Road and Green Way are proven. If no creed-loss spell is active because exposure is below threshold, record that as correctly pending.

### 4. Wrong-Origin Rejection

Use a clean reload if the Breton books are already consumed.

```text
set PDV_GLO_OriginRace to 1
player.additem 000ED60B 1
```

Read the book. Expected:

- No Breton Survey movement.
- No Breton reward or tradition state.
- No Breton Hidden Art route marker after the wrong-origin read.

Reset:

```text
set PDV_GLO_OriginRace to 2
```

### 5. Generic-Source Silence

Origin 2. Try two or three generic look-alikes:

- Learn or cast an ordinary spell.
- Carry or equip a generic artifact that is not a curated Breton source.
- Join a faction.
- Activate a normal shrine.
- Help an NPC in a generic favor quest.

Expected: no tradition movement, no WitchcraftExposure movement, no new Breton Survey recent event.

### 6. Prisma Embedded Checks

Run alongside the route steps:

- Toast: the Hidden Art read may surface as a toast or top-left notice; it must not open a blocking panel.
- Panel: manually open the Devotion panel; ESC and the X close it every time.
- Chronicle: after the accepted read and one dawn, Book of Days has a readable entry or dawn digest if the UI path is enabled; no blank line.
- Ledger: the Hidden Art source appears as a driver row; generic-source tests do not add rows.
- No unexpected modal: gameplay events do not force the full Prisma panel.

Prisma failure is a UI failure unless the route marker or manager state also fails.

### 7. Shared Daedric Inn-Sleep Proof

This is cross-race backend smoke, not Breton-native proof. It may be recorded once per build and referenced from the other race sheets.

1. MCM Debug -> `Debug: Daedric & Curse`; use `Selected Prince` to choose Sanguine or Namira.
2. Select `Reset Prince path`, then `Force Seeker`.
3. Sleep in a non-inn bed. Expected: no `PrinceV2: <Prince> event 314 deepen -0.25`, and `Show Prince summary` does not drop from sleep.
4. Sleep in an inn. Expected: `PrinceV2: <Prince> event 315 deepen -0.25`, and the summary piety drops by the inn-sleep dislike.
5. Positive control: choose Vaermina, Peryite, or Azura, `Reset Prince path`, `Force Seeker`, then sleep in a non-inn bed. Expected: `event 314` still gives the positive sleep credit.
6. Record the Papyrus `PrinceV2` lines and before/after `Show Prince summary` piety.

## Deferred Arms

- Knight's Road breach hooks, Green Way degradation, and tradition-differentiated vampire behavior are deferred in V1 unless a later build exposes exact route controls.
- `ExposureRupture` Active Effects proof is pending if no debug band setter exists; do not grind repeat books beyond one-shot source limits to fake it.

## Closeout

Before closing Skyrim, preserve the log excerpt. Then run:

```powershell
node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race breton --strict-manager
```

Record ledger statuses only as `pending`, `evidence-recorded`, or `not-applicable` when evidence is actually collected.

| Slot | Proof | Status | Note |
|---|---|---|---|
| Hidden Art route | ROUTE/RUNTIME | | |
| WitchcraftExposure decay | ROUTE/RUNTIME | | |
| Stack snapshot | MANUAL | | |
| Wrong-origin rejection | ROUTE/RUNTIME | | |
| Generic-source silence | ROUTE/RUNTIME | | |
| Survey/status clarity | MANUAL | | |
| Prisma toast/panel/Chronicle/Ledger | MANUAL | | |
| Shared Daedric inn-sleep proof | ROUTE/RUNTIME + MANUAL | | |
| Manual feel note | MANUAL | | |
