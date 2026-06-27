# PDV Neglect Rework -- Nord + Imperial Slice

Status: implemented as machine/readback proof on 2026-06-27; runtime smoke still pending.

This records the Nord/Imperial "Requiem-felt neglect" tranche. Neglect stays a gentle single flat stat below the T1 reward. Real bite remains reserved for rupture, curse, or authored creed violation.

## ESP Record Contract

Two existing MGEFs were reconfigured in place, keeping editor IDs and FormIDs so existing SPEL links stay intact:

| Race | Spell | MGEF | ActorValue | Magnitude |
|---|---|---|---|---|
| Nord/Kyne | `PDV_SPEL_Neglect_Kyne` | `PDV_MGEF_Neglect_Kyne_Stamina` | `ResistFrost` | `-8` |
| Imperial/civic | `PDV_SPEL_Neglect_Imperial` | `PDV_MGEF_Neglect_Imperial_Restoration` | `ResistDisease` | `-5` |

The `_Stamina` and `_Restoration` suffixes are benign internal misnomers. They were deliberately not renamed to avoid orphaning linked records.

Four Nord-scoped per-patron neglect SPEL/MGEF pairs were added and wired to `PDV__ManagerQuest`:

| Patron | Spell | MGEF | ActorValue | Magnitude |
|---|---|---|---|---|
| Shor | `PDV_SPEL_Neglect_Shor` | `PDV_MGEF_Neglect_Shor` | `OneHanded` | `-5` |
| Tsun | `PDV_SPEL_Neglect_Tsun` | `PDV_MGEF_Neglect_Tsun` | `Stamina` | `-15` |
| Stuhn | `PDV_SPEL_Neglect_Stuhn` | `PDV_MGEF_Neglect_Stuhn` | `DamageResist` | `-5` |
| Talos | `PDV_SPEL_Neglect_Talos` | `PDV_MGEF_Neglect_Talos` | `DamageResist` | `-5` |

`tools/pdv-neglect-esp-author` owns the direct-framework write/check path for this batch and backs up `Devotion.esp` under `Backups/neglect-esp/`.

## Runtime Shape

`PDV__ManagerQuest.psc` owns the runtime layer:

- `NEGLECT_LAPSE_GRACE_DAYS = 3.0`
- `IsPatronLapsed()` flags a focused active patron after recency lapse.
- `IsBroadLaneLapsed()` flags broad worship after a global devotional lapse.
- `SyncKyneNeglectSpell()` applies Kyne/broad Nord weather neglect.
- `SyncNordPatronNeglectSpells()` applies Shor/Tsun/Stuhn/Talos spells only for Nord origin, matching active patron, and active neglect flag.

Imperial civic neglect remains patron-agnostic through `SyncImperialNeglectSpell(IsImperialCivicNeglected())` and now uses the disease-resistance lapse record.

## Talos Creed Runtime

The same 2026-06-27 closeout also wires the minimal Talos betrayal creed-loss runtime for focused Talos paths. `PDV__ManagerQuest.HandleTalosBetrayal(severity, sourceReason)` now covers both Nord and Imperial:

- medium betrayal applies `-2` Talos piety with reason tokens `nord_talos_betrayal_compliance` / `imperial_talos_betrayal_compliance`;
- major betrayal applies `-3` Talos piety with reason tokens `nord_talos_betrayal_major` / `imperial_talos_betrayal_major`;
- both paths require active focused Talos and one application per in-game day per reason;
- Imperial additionally requires the raw Concordat track to remain Talos-eligible and pushes the raw track toward compliance;
- MCM Debug exposes `Talos betrayal -2` and `Talos betrayal -3` buttons for smoke proof.

This is runtime wiring only. Organic quest/dialogue detection for specific betrayal beats remains a follow-on design task.

## Verification

Machine/readback closeout requires:

```powershell
dotnet run --no-build --project .\tools\pdv-neglect-esp-author\PdvNeglectEspAuthor.csproj -- --check
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_compile.mjs --script PDV_MCM
node .\tools\pdv_verify.mjs --strict-neglect-decay
node .\tools\pdv_phase2_reward_readback_audit.mjs --json
node .\tools\pdv_integrity_harness.mjs
```

Runtime smoke remains separate: fresh Nord path, broad Nord lapse, focused Kyne/Shor/Tsun/Stuhn/Talos lapse, Imperial civic lapse, focused Talos betrayal medium/major debug buttons, and Prince-pact negative check.
