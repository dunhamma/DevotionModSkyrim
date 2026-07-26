# PDV Azura Price Actor-Value Diagnosis Handoff

**Date:** 2026-07-26 AEST  
**Project:** `C:\Users\Admin\Documents\Devotion Mod Project`  
**Live mod:** `D:\Wabbajack\modlists\Anvil\mods\Devotion`  
**MO2 instance/profile:** Anvil / `Devotion Dev`  
**Status:** all 48 price tiers repaired and read back; post-repair Azura three-tier and Mephala non-resource runtime sweeps passed  
**Skyrim state at runtime closeout:** running

## Start here

The successful Azura Seeker test established the live serialization convention:

```text
Detrimental + PowerAffectsMagnitude + positive stored magnitude
```

That convention has now been applied atomically to all 48 Daedric price
MGEFs and all 48 matching carrier spells. The semantic contract magnitudes
remain negative because they describe the player-facing penalty; the stored
spell magnitudes are their positive absolute values, while `Detrimental`
supplies the negative gameplay direction.

Direct houseCARL readback returned 48/48 matching MGEFs and 48/48 matching
spells in the corrected state. `pdv_verify.mjs` now enforces the convention and
passed with `FAIL=0`, `PASS=4120`.

## Player-reported failure

The player selected Azura in the Devotion MCM, reset the Prince path, and
forced Seeker.

Observed:

- `Azura Price - Seeker` appears in Active Effects.
- The wording is `Azura's foresight leaves the body tired. Price: Fortify
  Stamina -10.`
- `player.getavinfo stamina` shows no price modifier.
- Stamina does not acquire a lower regeneration ceiling.
- The player is a Redguard. That is a valid test origin and no race cycling is
  required.

Azura's price is intended to reduce **Stamina**, not Magicka. The `-10` is a
flat value, not ten percent. The phrase `Fortify Stamina -10` is mechanically
intended as a negative modifier but is player-facingly confusing.

## Runtime evidence

Current Papyrus log:

```text
C:\Users\Admin\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log
```

Relevant markers from the fresh post-edit test:

```text
[07/26/2026 - 01:19:19PM] [PDV] DaedricPath: Azura: ResetDaedricForDebug
[07/26/2026 - 01:19:19PM] [PDV] DaedricPath: Azura: SetStoredPiety 0.000000 (mcm_daedric_reset)
[07/26/2026 - 01:19:48PM] [PDV] Daedric milestone queued: Azura Seeker (mcm_force_Seeker)
[07/26/2026 - 01:19:48PM] [PDV] DaedricPath: Azura: DebugForceCommitmentSignals 3 (mcm_daedric_force_Seeker)
[07/26/2026 - 01:19:48PM] [PDV] Azura daedric pact tier: 0 -> 1 (active=TRUE)
[07/26/2026 - 01:19:48PM] [PDV] DaedricPath: Azura: Tier 0 -> 1 (mcm_daedric_force_Seeker)
[07/26/2026 - 01:19:48PM] [PDV] DaedricPath: Azura: SetStoredPiety 25.000000 (mcm_daedric_force_Seeker)
[07/26/2026 - 01:19:52PM] [PDV] Daedric milestone queue processing: Azura Seeker (mcm_force_Seeker)
[07/26/2026 - 01:19:54PM] [PDV] Daedric milestone Prisma payload sent=TRUE prince=Azura tier=Seeker
[07/26/2026 - 01:19:54PM] [PDV] Daedric milestone presentation: Azura Seeker prisma=TRUE
```

There is no Azura/price Papyrus exception. Unrelated missing-mod and NiOverride
messages exist earlier in the log, but they do not interrupt this route.

This rules out:

- the MCM route not firing
- the pact remaining inactive
- the price spell failing to appear
- the test using only save-baked pre-edit state, because Reset and Force Seeker
  removed and re-added the price after the edit

It does not prove that the MGEF actor-value operation executed.

### Latest test: Redguard reward confound

The post-Test-3 session loaded after the live ESP write, so it did use the
current plugin:

```text
Devotion.esp written: 01:45:42PM
Papyrus session start: 01:53:40PM
Force Seeker:          01:54:19PM
```

However, that session did not log `ResetDaedricForDebug` before Force Seeker.
It also logged this six seconds after Force Seeker:

```text
[07/26/2026 - 01:54:25PM] [PDV] Manager: Race reward added: Redguard Spine Forebear
```

Direct houseCARL readback identifies that reward as:

```text
Spell:  0715C3:Devotion.esp  PDV_Bless_Redguard_Spine_Forebear
MGEF:   0715C2:Devotion.esp  PDV_MGEF_Redguard_Spine_Forebear_Stamina
Effect: PeakValueModifier -> Stamina
Amount: +10
```

This creates a concrete masking confound:

```text
Redguard Spine Forebear  +10 Stamina
Azura Seeker price       -10 Stamina
Net modifier               0
```

The player then ran the controlled comparison successfully:

```text
[07/26/2026 - 01:57:57PM] [PDV] DaedricPath: Azura: ResetDaedricForDebug
[07/26/2026 - 01:57:57PM] [PDV] Azura daedric pact tier: 1 -> 0 (active=False)
[07/26/2026 - 01:58:58PM] [PDV] Daedric milestone queued: Azura Seeker (mcm_force_Seeker)
[07/26/2026 - 01:58:58PM] [PDV] Azura daedric pact tier: 0 -> 1 (active=TRUE)
```

Manual result reported by the player:

```text
confirmed Reset baseline: Redguard Spine Forebear +10 Stamina
Force Seeker result:      net modifier 0
observed delta:           -10 Stamina
```

This confirms the apparent failure was masking by an equal positive race
reward. Azura Seeker's current price record applies mechanically.

## Redguard masking root cause and applied fix

The timing was deterministic, not coincidental. Daedric milestone presentation
calls `SyncFirstTierRaceRewardRuntime()`, which in turn calls
`SyncRedguardRewards()`. The missing Forebear spine boon was therefore repaired
while Force Seeker was being presented, producing the equal and opposite
Stamina changes in the same observation window.

The root omission was in `ApplyRedguardInitialChoice()`: it recorded the chosen
sect but did not perform the immediate reward sync and panel refresh used by
the neighboring race setup flows.

The live and tracked `PDV__ManagerQuest.psc` now:

- call `SyncFirstTierRaceRewardRuntime()` and `RequestPanelRefresh()` when the
  initial Redguard choice completes
- call the narrow `ReconcileRedguardSpineRewardAfterLoad()` migration from the
  player-load lifecycle watchdog, so completed existing Redguard saves receive
  their selected spine boon before any Daedric milestone action
- do not change the stored Redguard sect or any Daedric state during that
  load-time reconciliation

Static verification on 2026-07-26 at 14:14 AEST:

```text
pdv_ascii_guard: PASS (96 files, all ASCII-clean)
PDV__ManagerQuest compile: PASS (0 errors, 0 warnings)
pdv_verify: FAIL=0, WARN=1, TODO=1, PASS=4119, INFO=72
```

The one verifier warning is the pre-existing SEQ/ESP timestamp warning and is
unrelated to this script-only change. Runtime proof of the masking fix is
captured below.

Runtime closeout on 2026-07-26:

```text
15:09:58  Redguard Spine Forebear added during player-load reconciliation
15:11:25  Azura ResetDaedricForDebug
15:13:23  Azura tier 0 -> 1 after Force Seeker
15:14:03  Azura tier 1 -> 0 after Force Lapse
```

The player confirmed the expected actor-value sequence:

```text
pre-Seeker Forebear baseline: +10 Stamina
Azura Seeker:                 net 0 (-10 delta)
Azura Lapse:                  +10 Stamina restored
```

No `Race reward added: Redguard Spine Forebear` marker occurred during Force
Seeker. The reward was already active from the load reconciliation, so the
masking-timing regression passes.

## Current live record state

Direct houseCARL readback, load-order winner:

### Magic Effect

```text
FormID:     071288:Devotion.esp
EditorID:   PDV_MGEF_Price_Daedric_Azura_Seeker
Name:       Azura Price - Seeker
Flags:      Recover, Detrimental, NoDuration, NoArea,
            PowerAffectsMagnitude, NoHitEffect
CastType:   ConstantEffect
TargetType: Self
Archetype:  PeakValueModifier
ActorValue: Stamina
Conditions: none
```

### Spell

```text
FormID:     071289:Devotion.esp
EditorID:   PDV_Price_Daedric_Azura_Seeker
Type:       Ability
CastType:   ConstantEffect
TargetType: Self
Effect:     071288:Devotion.esp
Magnitude:  +10
Duration:   0
Conditions: none
```

Both records are defined only by `Devotion.esp`; there is no later override.
`housecarl_check_errors` on `Devotion.esp` returned:

```text
0 dangling refs
0 missing masters
0 unscannable records
```

## Diagnostic edits already attempted

### Original authored state

```text
MGEF flags: Recover, NoDuration, NoArea, NoHitEffect
Spell magnitude: -10
```

Runtime result: Active Effect visible; no Stamina modifier.

### Test 1: `PowerAffectsMagnitude` alone

`PowerAffectsMagnitude` was temporarily added while the record still used the
original negative magnitude and lacked `Detrimental`.

Runtime result: Active Effect visible; no Stamina modifier.

That temporary flag was reverted.

### Test 2: sign plus `Detrimental`

The second diagnostic state was then applied atomically through
`housecarl_bulk_apply`:

```text
MGEF flags: Recover, Detrimental, NoDuration, NoArea, NoHitEffect
Spell magnitude: +10
```

Runtime result: Active Effect visible; `getavinfo stamina` still has no
modifier.

Therefore neither test has yet exercised all three relevant fields together.

### Test 3: complete three-field combination

With Skyrim confirmed closed, `PowerAffectsMagnitude` was added through a
direct houseCARL in-place edit:

```text
MGEF flags:
  Recover, Detrimental, NoDuration, NoArea,
  PowerAffectsMagnitude, NoHitEffect
Spell magnitude:
  +10
```

Direct load-order readback confirmed both records, and
`housecarl_check_errors` again returned zero dangling refs, missing masters, or
unscannable records.

Runtime result: passed for Azura Seeker application after a confirmed Reset and
post-race-reward baseline.

## Record conclusion

Before Test 3, `PowerAffectsMagnitude` was the single material difference
between Azura and the common constant-effect PeakValueModifier pattern. The
current three-field record now passes in game.

This does **not** isolate whether `PowerAffectsMagnitude` was necessary. Both
earlier record states were tested while the Redguard `+10` reward masked the
Azura `-10` price. Keep the current passing state, but do not claim that any
one of the three fields is independently causal without another controlled
runtime comparison.

Direct record comparison found:

- vanilla `10F159:Skyrim.esm` (`AbVampireDamageStamina`) uses
  `Recover, Detrimental, ... PowerAffectsMagnitude`; its carrier spells store
  positive magnitudes
- vanilla `0B8776:Skyrim.esm` (`DisDamageStamina`) uses `Detrimental` plus a
  power-affects flag; its carrier stores magnitude `+25`
- PDV constant-effect Stamina modifiers outside the older Daedric family
  consistently include `PowerAffectsMagnitude`
- `0715FE:Devotion.esp` (`PDV_MGEF_Neglect_Tsun`) has `Detrimental` and
  `PowerAffectsMagnitude`, although its carrier still stores `-15`; do not call
  that record a proven donor without a dedicated runtime check

The earlier `PowerAffectsMagnitude`-only failure did not falsify this
hypothesis because it retained the suspect negative magnitude and omitted
`Detrimental`.

## Wider family audit

Direct houseCARL query found 48 `PDV_MGEF_Price_Daedric_*` MGEFs and 48 matching
`PDV_Price_Daedric_*` spells.

Current live distribution:

- all 48 price MGEFs carry exactly `Recover, Detrimental, NoDuration, NoArea,
  PowerAffectsMagnitude, NoHitEffect`
- all 48 price spells link the contracted MGEF and store the positive absolute
  value of the semantic negative magnitude
- all 18 Health/Magicka/Stamina prices retain the reversible
  `PeakValueModifier` archetype for the contracted resource
- the remaining 30 prices retain their contracted non-resource actor value

The authoritative contract now states this serialization rule, the contract
generator preserves it, and the standard verifier fails if any tier regresses.
This is family-wide record/readback proof, not family-wide runtime proof.

## Why current Stamina may initially stay unchanged

`live-source\Scripts\Source\PDV_DaedricPathBase.psc:576-590` deliberately
snapshots current Health, Magicka, and Stamina before adding a price, then calls
`RestoreCurrentPoolIfReduced` for each pool.

The function checks all three because it is generic across Princes. Only the
pool reduced by the newly added spell should need restoration.

The intended rule is:

- reduce maximum capacity
- do not also consume the player's current resource bar at commitment time

This helper can explain an unchanged immediate `player.getav stamina`. It
cannot explain an empty `player.getavinfo stamina` modifier. Git blame traces
the helper to commit `4c7bac53` (`fix(breton): close co-test wiring gaps`).

## Applied record test

Skyrim was confirmed closed and houseCARL was confirmed on Anvil /
`Devotion Dev`. The pre-write read matched the expected Test 2 state.

Applied:

```text
FormID:     071288:Devotion.esp
Field:      Flags
New value:  Recover, Detrimental, NoDuration, NoArea, PowerAffectsMagnitude, NoHitEffect
```

Retained:

```text
071289:Devotion.esp Effects[0].Data.Magnitude = 10
```

The edit used direct `housecarl_set_field` in place on `Devotion.esp`.
Independent direct readback confirmed the MGEF and spell, and the scoped plugin
integrity sweep passed. No retired PDV authoring helper was used.

## Exact in-game retest

**Completed 2026-07-26: PASS.** Preserve these steps as the regression test.

1. Refresh MO2 with `F5`, launch from `Devotion Dev`, and load the same Redguard
   test save.
2. Wait five seconds so the player-load lifecycle reconciliation can run.
3. Open `Devotion MCM -> Debug`.
4. Set `Selected Prince` to `Azura`.
5. Click `Reset Prince path`.
6. Choose `Yes` on the confirmation box.
7. Close the MCM and confirm `Azura Price - Seeker` disappears from Active
   Effects while `Redguard Spine Forebear` remains.
8. Record the pre-Seeker baseline:

   ```text
   player.getavinfo stamina
   player.getav stamina
   ```

9. Reopen the MCM and click `Force Seeker`.
10. Close the MCM and verify `Azura Price - Seeker` appears in Active Effects.
11. Run the same two console commands.
12. Sprint to consume Stamina, then allow full regeneration.
13. Run `player.getav stamina` again.
14. Click `Force lapse`, wait, and repeat the commands.

Pass criteria:

- Active Effect appears
- after load and Reset, before Force Seeker, the Redguard reward already
  produces a `+10` Stamina modifier
- Force Seeker changes the net modifier from `+10` to `0`
- Force Seeker does not first grant `Redguard Spine Forebear`
- after spending Stamina, regeneration stops ten below the Reset baseline
- `Force lapse` removes the modifier and restores the exact baseline

Fail criteria:

- Forebear is absent until Force Seeker
- the confirmed pre-Seeker baseline does not expose the Redguard `+10`
- Force Seeker produces no ten-point fall from that confirmed baseline

If it still fails, do not add more flags speculatively. The next discriminator
is a minimal known-good donor-pattern spell/MGEF comparison or temporary
controlled donor effect, with one field changed per runtime attempt.

## Recovery handle

The full-family repair was preceded by a byte-for-byte backup:

```text
C:\Users\Admin\Documents\Devotion Mod Project\generated\live-devotion-backups\pre-daedric-price-family-20260726-152602\Devotion.esp
SHA-256: 7F991783D80CB2C62BAD89C1C799F255C97E7620D05891DC746610BE414ABA6F
```

The repair was one all-or-nothing direct houseCARL in-place write comprising
96 edits: 48 MGEF flag sets plus 48 SPEL magnitude sets. Do not restore the
backup as a normal rollback: it contains the defective family convention and
exists only as the exact pre-write recovery handle.

## Proof boundary

### Passed

- **Authority:** smoke packet says Azura Seeker should lower maximum Stamina by
  10 and lapse should restore baseline.
- **Readback:** the complete three-field SPEL/MGEF state is confirmed directly
  from the load-order winner for all 48 tiers.
- **Automated regression gate:** `pdv_verify.mjs` checks all 48 price records,
  links, flags, stored magnitudes, and resource-pool archetypes.
- **Runtime route:** MCM Reset and Force Seeker markers reached active tier 1.
- **Manual presentation:** Azura Seeker price appears in Active Effects.
- **Runtime actor-value payload:** after the Redguard reward settled at `+10`,
  Force Seeker changed the net modifier to `0`, proving a `-10` Azura delta.
- **Azura tier scaling:** Seeker, Devoted, and Champion applied the contracted
  Stamina deltas of `-10`, `-20`, and `-30` from the settled Reset baseline;
  all three named prices appeared in Active Effects.
- **Mephala non-resource scaling:** Seeker, Devoted, and Champion applied the
  contracted Speech deltas of `-8`, `-12`, and `-15`; all three named prices
  appeared in Active Effects.
- **Hermaeus Mora Champion:** the distinct two-effect boon showed Alteration
  `+20` and maximum Magicka `+20` alongside the Stamina `-30` price, with
  tested baselines restored on Lapse.
- **Redguard load reconciliation:** Forebear was added at player load before
  the Azura reset/force sequence and was not re-granted during Force Seeker.
- **Lapse restoration:** Force Lapse returned both Stamina and Speech exactly
  to their respective Reset baselines.

### Residual boundary

- The repaired serialization convention is runtime-proven across all three
  tiers for one `PeakValueModifier` family and one non-resource
  `ValueModifier` family.
- The other 42 price tiers were directly read back but were not each manually
  exercised after this repair.
- It is accurate to claim the family serialization repair is readback-clean
  and representative-runtime-proven. Do not claim 48/48 individual manual
  tier tests.

Current evidence closes the shared failure class without collapsing
representative runtime proof into 48 individual manual tests.

## Repository hygiene

The repository worktree already contained extensive unrelated user changes
before this handoff. Preserve them. This closeout changed the Redguard
setup/load reconciliation source and live PEX, the Daedric record contract and
generator, the standard verifier, this handoff, and the smoke packet. It also
rewrote the live `Devotion.esp` and refreshed the live `Devotion.seq`.

The deployed `PDV_DaedricPathBase.pex` is newer than its source and was current
for the runtime test:

```text
source: live-source\Scripts\Source\PDV_DaedricPathBase.psc
        2026-07-16 08:11:59
PEX:    D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV_DaedricPathBase.pex
        2026-07-25 12:35:52
```

## Next required step

GATE 4's enlarged/longer 4K toast presentation was already tested and passed.
The smoke packet's **MCM page sanity (B5)** port-regression check also passed.
**Stat repair buttons (B6)** is deferred, not failed: the owner does not
currently have a suitable damaged-stat test state, so that manual-proof slot
remains open for an external tester with a disposable save. Continue the owner
run at **Shrine prayer credit (B14)**. The Daedric price repair, Hermaeus Mora
Champion regression, 4K toast gate, and B5 require no further mandatory retest.
