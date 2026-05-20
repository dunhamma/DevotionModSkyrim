## PDV Phase 7 Civil War Closeout Checklist

Purpose: land the final manual Civil War one-shot hooks that close the last
open Phase 7 social-pressure packet after the shrine and shout surfaces are
already proven.

This packet is intentionally narrow:

- `CW01A` -> Imperial Legion join -> Concordat compliance
- `CW01B` -> Stormcloak join -> Concordat defiance

No Talos award is added here. These hooks move `ConcordatStanding` only.
Talos award for Phase 7 defiance remains the hidden shrine route.

## Local Record Confirmation

Verified from local `Skyrim.esm` quest data on 2026-05-20:

- `CW01A` (`Skyrim.esm:0D517A`) - `Joining the Legion`
  - objective `160`: `Take the oath`
  - completion stage `200`
- `CW01B` (`Skyrim.esm:0E2D29`) - `Joining the Stormcloaks`
  - objective `160`: `Take the oath`
  - completion stage `200`

Recommended hook point:

- use stage `200` on both quests

Reason:

- stage `200` is the verified one-shot completion point
- objective/stage `160` is a useful sanity check while inspecting the quest,
  but the completion stage is the cleaner once-only signal surface

## Fragment Call Contract

Use an SKSE mod event from the vanilla quest completion fragment and let the
already-live `PDV_PlayerEvents` alias route it into `PDV_EventBus`.

Why this is now preferred:

- the fragment body stays one line and uses no PDV custom types
- no fragment property is needed
- it avoids duplicate/ghost fragment-property state on vanilla `QF_*` scripts
- the runtime signal still lands on the existing EventBus path

Registered event names:

- `PDV.ConcordatCompliance`
- `PDV.ConcordatDefiance`

Fragment calls:

- Imperial join:
  - `SendModEvent("PDV.ConcordatCompliance")`
- Stormcloak join:
  - `SendModEvent("PDV.ConcordatDefiance")`

That preserves the locked Phase 7 posture:

- one curated compliance/defiance one-shot
- no crime/arrest Story Manager expansion
- no generic anti-Thalmor kill scoring
- no second Talos-award surface on Civil War join

## Manual CK Steps

### 1. Open CK through MO2

1. Launch `D:\Wabbajack\modlists\Anvil\Anvil.exe`
2. Choose `Creation Kit`
3. Use the `Devotion Dev` profile
4. Load the plugin that owns your Civil War override work
   - if Phase 7 Civil War hooks are being added directly to the framework
     patch stack, load that patch/plugin as the active file
   - do not edit `Skyrim.esm` directly

### 2. Wire `CW01A` Imperial join completion

1. Open quest:
   - `CW01A` (`Joining the Legion`)
2. Confirm you are on the verified quest:
   - objective `160` should read `Take the oath`
3. Open stage `200`
4. Add or edit the stage `200` fragment/result script so it calls the PDV
   mod event
5. Fragment body should call:

```papyrus
SendModEvent("PDV.ConcordatCompliance")
```

Meaning:

- Imperial Legion join counts as Concordat compliance
- expected adjustment is `+15`

### 3. Wire `CW01B` Stormcloak join completion

1. Open quest:
   - `CW01B` (`Joining the Stormcloaks`)
2. Confirm you are on the verified quest:
   - objective `160` should read `Take the oath`
3. Open stage `200`
4. Add or edit the stage `200` fragment/result script
5. Fragment body should call:

```papyrus
SendModEvent("PDV.ConcordatDefiance")
```

Meaning:

- Stormcloak join counts as Concordat defiance
- expected adjustment is `-15`

## Fragment Hygiene

- Keep the fragment logic tiny
- do not duplicate Concordat math in the fragment
- do not add fragment properties for the preferred path
- do not type-cast PDV quest script types inside the fragment body
- do not call `PDV__ManagerQuest.ApplyConcordatPressure(...)` directly from the
  vanilla quest fragment when the EventBus route already exists
- do not add Talos piety award here
- do not reuse crime/arrest Story Manager hooks in this pass

## Save / Build / Verify

After CK save:

1. Save the plugin
2. Run the strict gate:

```text
node .\tools\pdv_verify.mjs --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

Important note:

- the current strict verifier is clean on PDV-owned surfaces
- it does not yet read back these external vanilla quest fragment edits as a
  hard gate
- Phase 7 should therefore be treated as fully closed only after the runtime
  smoke below passes

## Runtime Smoke

Use disposable saves where possible.

### Imperial branch

1. Load an Imperial save
2. Set debug:

```text
set PDV_GLO_DebugLevel to 2
```

3. Complete or force `CW01A` stage `200`
4. Confirm:
   - no Talos award from this join marker
   - `ConcordatStanding` moves by `+15`
   - Papyrus shows the EventBus Concordat route

### Stormcloak branch

1. Load an Imperial or Nord save used for defiance proof
2. Set debug:

```text
set PDV_GLO_DebugLevel to 2
```

3. Complete or force `CW01B` stage `200`
4. Confirm:
   - no Talos award from this join marker
   - `ConcordatStanding` moves by `-15`
   - Papyrus shows the EventBus Concordat route

## Closeout Criteria

Phase 7 can be called fully closed when all are true:

- hidden Talos shrine reference proof is already complete
- shout ingress proof is already complete
- `CW01A` stage `200` compliance hook is wired and runtime-proven
- `CW01B` stage `200` defiance hook is wired and runtime-proven
- combined strict verifier remains clean on `FAIL=0, WARN=0, TODO=0`
