# PDV Uninstall Cleanup Adversarial Acceptance (2026-06-24)

Scope: best-effort MCM-driven uninstall cleanup from `PDV_HO_UninstallCleanup_2026-06-25.md`, implemented against the live Anvil Devotion source and synced back into the tracked `live-source` mirror.

Proof boundary: this is compile, verifier, static refuter, and gate acceptance only. It does not prove in-game MCM selection, actual save cleanup, post-removal load safety, or manual acceptance. The feature remains best-effort; a save made before Devotion was installed is still the only fully clean removal.

## Refuter Pass

Accepted with five targeted refuters plus compile, verifier, E2E, and integrity gates.

| Refuter | Verdict | Evidence |
|---|---|---|
| R1 spell sweep | PASS | Live `PDV__ManagerQuest.psc` has 231 `Spell Property PDV_*` declarations and `StripAllPdvSpells` has exactly 231 matching `SyncRaceRewardSpell(playerRef, <property>, False, "<property>")` calls, with zero missing or duplicate property targets. |
| R2 cleanup ordering | PASS | `PrepareForUninstall` strips spells, removes `NecromancerFaction`/`WarlockFaction`, clears `StorageUtil.ClearAllPrefix("PDV.")`, unregisters updates, warns the player, then calls `Self.Stop()`. Cleanup does not rely on post-stop script state. |
| R3 MCM safety | PASS | `PDV_MCM.psc` adds one debug-page action, `Prepare for uninstall`, guarded by a confirmation prompt and `EnsureManagerBinding("prepare_uninstall")` before calling `PDV_Manager.PrepareForUninstall()`. |
| R4 source truth | PASS | The live MO2 source and tracked `live-source` mirror match after sync: manager SHA256 `81D47823B9FFBC0FCEA9D8F1B43600E566BDE3C0F456A8D9D03F6D7F148AD2EA`, MCM SHA256 `E3709B1F43DB1A979450FE91B6EE1B4F46E17326F338DFDA3187B85881BB05E5`. Mirror-only stale symbols (`_oidBretonDruidicFrayTest`, `PDV_Faction_Hunted_Vigilant`, `ReconcileVigilantHunt`) were not revived. |
| R5 proof boundary/no-regression | PASS | The MCM confirmation, highlight text, and manager message all state best-effort cleanup and do not claim a guaranteed clean save. Runtime/manual proof remains explicitly open. |

## Gate Results

Run from `C:\Users\Admin\Documents\Devotion Mod Project` against the live Anvil Devotion source/profile.

| Gate | Result |
|---|---|
| `node .\tools\pdv_ascii_guard.mjs` | PASS, 89 `.psc` files ASCII-clean |
| `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest --script PDV_MCM` | PASS, both scripts 0 errors / 0 warnings |
| `node .\tools\pdv_verify.mjs` | PASS, `FAIL=0`, `WARN=3`, `TODO=0`, `PASS=3497`, `INFO=35` |
| `node .\tools\pdv_signal_e2e_gate.mjs` | PASS, 39 GREEN / 0 RED, curated-signal parity PASS |
| `node .\tools\pdv_integrity_harness.mjs` | PASS, gate 39 GREEN / 0 RED, parity PASS |

## Remaining Proof

Manual proof is still required on a throwaway save: open MCM, select `Prepare for uninstall`, confirm reward/neglect spells and owned factions are gone, confirm the manager stops ticking, then treat any post-removal load as best-effort only.
