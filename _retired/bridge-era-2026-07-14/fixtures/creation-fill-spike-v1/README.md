# Creation Fill Spike v1

This fixture lane is discovery-only. It exists to catch the exact failure mode
where a pipeline can describe a new CK record and payload but has not proven the
generated-plugin Creation Kit path yet.

The fixture covers ten practical Skyrim record families:

- `SPEL`
- `MGEF`
- `ENCH`
- `SCRL`
- `WEAP`
- `ARMO`
- `AMMO`
- `BOOK`
- `CONT`
- `MISC`

Run the static payload/readback check with the explicit discovery flag:

```powershell
node .\packages\creation-authoring\src\cli.mjs fixture-check fixtures\creation-fill-spike-v1 --profile fixtures\creation-fill-spike-v1\creation-fill-spike-v1.profile.json --readback fixtures\creation-fill-spike-v1\creation-fill-spike-v1.readback.json --allow-unproven-ck
```

Passing this fixture means the manifest intent and readback verifier can
distinguish the created payload fields. It does not prove CK creation, CK save,
MO2 winner state, proof-ledger support, or capability-matrix promotion.

The hardened checks require:

- every operation to remain blocked without `--allow-unproven-ck`
- every operation to route through CKPE only in explicit discovery mode
- the generated plugin to be the readback winner
- the readback record type to match the requested family
- every scalar leaf under `payload.fields` to match readback
- inventory payload leaves to match readback where a family uses inventory

Use the runner for a consistent discovery sequence:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Static
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Prepare
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Ck
powershell -ExecutionPolicy Bypass -File .\scripts\run-creation-fill-spike-v1.ps1 -Stage Finalize
```

The runner owns the generated proof plugin. Before `Prepare`, `Ck`, `Finalize`,
or `All`, it ensures
`D:\Wabbajack\modlists\Anvil\mods\Devotion\CKRA_CreationFillSpikeV1.esp`
exists as a normal writable ESP with `Skyrim.esm` as a master reference. It is
not an ESL or small master. Use `-ResetGeneratedPlugin` only when intentionally
discarding the previous discovery plugin contents and starting a fresh live
proof attempt.

`Finalize` may write `generated/creation-fill-spike-v1.discovery.proof-ledger.json`
as discovery evidence, but the runner intentionally does not merge it into
`generated/proof-results.skyrimse.json` and skips capability-matrix generation.
