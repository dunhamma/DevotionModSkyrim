# PDV Notoriety Adversarial Acceptance (2026-06-25)

Scope: implementation of the selected broader Notoriety slice from `PDV_HO_Notoriety_2026-06-25.md`: Breton Hidden Art Notorious plus the temporary werewolf curse-state proxy.

Proof boundary: this is machine/readback/static adversarial acceptance only. It proves the PDV-owned faction relation, manager property wiring, script compile, source gates, and targeted static refuters. It does not prove in-game Vigilant attack behavior, final-world placement, Survey/manual feel, save/load behavior, or runtime hostility clearing unless those are run separately.

## Implemented Surface

- Added `PDV_Faction_Hunted_Vigilant` as a PDV-owned faction in `Devotion.esp`.
- Authored exactly one relation on that faction: target `VigilantOfStendarrFaction` (`0B3292:Skyrim.esm`), reaction `Enemy`, modifier `0`.
- Wired `PDV__ManagerQuest.PDV_Faction_Hunted_Vigilant` to the new faction.
- Added desired-state reconciliation for Hidden Art Notorious (`Breton` + `Hidden Art` + `WitchcraftExposure >= 75`) and the temporary werewolf proxy (`PDV_CurseStateService.IsWerewolf()`).
- Vampires do not opt into the PDV hunted faction.
- Dawnguard world-state gate uses `DLC1VQ01` from `Dawnguard.esm`; missing Dawnguard or stage `0` is treated as Vigilants alive, while later stages close the hunt.
- Surfaced onset/cure through `SurfaceTransition("reorientation", "hunted_vigilant", ...)`.

## Refuter Pass

Accepted with the five-refuter hand-back pattern. Refuters used Notoriety-specific hardcoded checks against the actual source diff and author helper.

| Refuter | Verdict | Evidence |
|---|---|---|
| R1 scope/whitelist | PASS | `pdv-notoriety-author` targets only `PDV_Faction_Hunted_Vigilant` and `0B3292:Skyrim.esm`; changed manager code contains no `CrimeFaction`, guard, merchant, townsfolk, or Silver Hand target. Vampire state is an exclusion before the werewolf proxy can opt in. |
| R2 state reconciliation | PASS | `ReconcileVigilantHunt` computes `desired = worldGateOpen && (hereticHunt || werewolfHunt)` and removes membership only under `!desired && active`, so heretic and werewolf reasons cannot clear each other accidentally. |
| R3 relation/world-state | PASS | Author/readback check enforces exactly one PDV-side `Enemy` relation to `VigilantOfStendarrFaction` with modifier `0`; `PDVVigilantsAlive()` resolves `DLC1VQ01` and only leaves the gate open at stage `0` or missing Dawnguard. |
| R4 surfacing/ledger | PASS | Onset/cure surfacing is membership-edge gated (`desired && !active`, `!desired && active`) and the diff adds no signal, piety, or Ledger-driver bypass path. |
| R5 regression/refactor | PASS | `PDV_MCM.psc` diff is empty; implementation adds no cloak, no new polling loop, no vanilla master edit, and no broad behavior rewrite outside manager Notoriety reconciliation plus the narrow ESP author helper. |

## Gate Results

Run from `C:\Users\Admin\Documents\Devotion Mod Project` against the live Anvil Devotion source/profile.

| Gate | Result |
|---|---|
| `git status --short` | Existing unrelated untracked docs preserved; implementation touched manager source, the generated completeness ledger count, and new Notoriety author/acceptance files. |
| `node .\tools\pdv_mcp_check.mjs` | OK, server live on profile `Devotion Dev`. |
| `node .\tools\pdv_ascii_guard.mjs` | OK, 89 `.psc` files ASCII-clean. |
| `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` | PASS, 0 errors / 0 warnings. |
| `dotnet run --project tools/pdv-notoriety-author/PdvNotorietyAuthor.csproj -- --write` | PASS; backup created at `D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\notoriety\Devotion.esp.20260624-204043.bak`. |
| `dotnet run --project tools/pdv-notoriety-author/PdvNotorietyAuthor.csproj -- --check` | PASS; faction relation and manager object property readback clean. |
| `node .\tools\pdv_verify.mjs` | `FAIL=0`, `WARN=3`, `TODO=0`, `PASS=3497`. Warnings are existing unnamed INFO records plus SEQ freshness after ESP write. |
| `node .\tools\pdv_signal_e2e_gate.mjs` | PASS, 39 GREEN / 0 RED, curated-signal parity PASS. |
| `node .\tools\pdv_integrity_harness.mjs` | PASS, gate 39 GREEN / 0 RED; parity PASS. |

## Acceptance

The Notoriety slice is accepted at the machine/readback/static layer: source compiles, the ESP record/property readback is clean, and all five adversarial refuters are clean.

Remaining proof belongs to the runtime/manual bucket:

- Notorious Breton Hidden Art with Vigilants alive makes a living Vigilant attack.
- Exposure decay below `75` clears hostility unless the werewolf proxy remains active.
- Werewolf onset/cure toggles only the placeholder path.
- Vampire onset never adds the PDV hunted faction.
- Post-Dawnguard world state prevents or removes the hunt in-game.
