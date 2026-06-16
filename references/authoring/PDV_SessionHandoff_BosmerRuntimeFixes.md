# Session Handoff - Bosmer Runtime Fixes And Next Smoke

**Created:** 2026-06-13 AEST
**From:** Local Windows session with Anvil/MO2, Skyrim closed for final ESP write
**To:** Next PDV runtime/manual testing session
**Scope:** Bosmer DA05 proof intake, Bosmer variety bug fixes, reward-copy cleanup, and live reward ESP refresh.

## Current State

This handoff is now superseded for packet-closeout purposes. The Bosmer DA05 organic source packet, Songs of the Green, Baan Dar Gap, reward/Survey stack, and final Bosmer feel/readback closeout are recorded as passed for the current beta-feel packet. The 2026-06-16 live readback refresh also moved Baan Dar Gap to the current SpeedMult +40 for 15 seconds.

Do not treat this as final-world placement proof. It remains useful as historical runtime-fix context, but it is no longer the active Bosmer packet blocker sheet.

## Live Writes Completed

### Manager script

Live source:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc
```

Compiled output:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\PDV__ManagerQuest.pex
LastWriteTime: 2026-06-13 17:55:13 AEST
```

Key source fixes:

- Bosmer hearth declaration is now path-neutral, matching the Argonian bed-of-choice pattern.
- Tale Carried remains Living Story-only after hearth declaration.
- Naming can now work from a declared hearth on non-Living Story paths after restart/fresh script load.
- Baan Dar Gap uses the shared Khajiit/Bosmer combat-session poll rather than a direct low-health hit hook.

### Framework ESP

Live ESP:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp
```

Final Bosmer reward write:

```powershell
dotnet run --project .\tools\pdv-phase20-race-author\PdvPhase20RaceAuthor.csproj -c Release -- --author-rewards --rewards-spec .\references\authoring\PDV_BosmerRewardRecords.spec.json --esp "D:\Wabbajack\modlists\Anvil\mods\Devotion\Devotion.esp"
```

Backup:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\phase20-race-rewards\Devotion.esp.20260613-181508.bak
```

SEQ refreshed:

```powershell
node .\tools\pdv_refresh_seq.mjs --write
```

SEQ backup:

```text
D:\Wabbajack\modlists\Anvil\mods\Devotion\Seq\Devotion.seq.20260613-081520.bak
```

## Readback Proof

Final verifier:

```text
node .\tools\pdv_verify.mjs
FAIL=0, WARN=2, TODO=0, PASS=2938, INFO=34
```

Targeted readback:

```text
PDV_MGEF_Neglect_Bosmer_Stamina
  Archetype.Type = PeakValueModifier
  Archetype.ActorValue = StaminaRateMult
  Flags = Recover, NoDuration, NoArea, PowerAffectsMagnitude, NoHitEffect

PDV_SPEL_Neglect_Bosmer
  BaseEffect = PDV_MGEF_Neglect_Bosmer_Stamina
  Magnitude = -5
  Duration = 0
  Area = 0

PDV_Bless_Bosmer_Exchange_T1
  Description = Z'en steadies fair dealing after a debt is settled. Speech +5.

PDV_Bless_Bosmer_Exchange_T2
  Description = Z'en weighs what is owed and what is carried. Speech +13, Carry Weight +30.
```

Important mechanic conclusion: `StaminaRateMult -5` was the correct target for a 5-point stamina-regeneration penalty. The bug was the authoring shape: regen actor values must use `PeakValueModifier`, not generic `ValueModifier`. `tools/pdv-phase20-race-author` now enforces that for `HealRate`, `MagickaRate`, `StaminaRate`, and the three `*RateMult` actor values.

## Manual Evidence Already Recorded

Recorded from tester reports and log checks:

- DA05 stage `100` accepted branch passed on a Bosmer save.
- DA05 stage `105` mercy branch passed on a separate Bosmer save.
- Wrong-origin DA05 rejection passed.
- Generic-source silence passed for the current Bosmer packet.
- DA05 threshold-crossing proof passed: Old Contract / Seeker and Survey OldContract / Seeker after piety-23 preflight, DA05, and dawn pass.
- Stable piety-25 route proof behaved correctly: same pre/post Active Effects and Survey state were expected.
- Old Contract T3 / 85-piety display passed with Keeper of the Pact package.
- Living Story T1/T2/T3 passed, and dropping below 25 removed the Living Story path reward.
- Exchange mechanics passed, but T1/T2 copy needed the Z'en text fix now written to the ESP.
- Green Dreams fired.

## Known Non-Bosmer Caveat

`node .\tools\pdv_phase2_reward_readback_audit.mjs --json` currently reports one unrelated failure:

```text
PDV_Bless_Khajiit_BaanDar_T3 first MGEF PDV_MGEF_Khajiit_BaanDar_T3_DamageResist lacks PDV_T3DailyLowHealthSaveEffect.
```

Do not treat that as a Bosmer blocker. It should be handled in a separate Khajiit capstone/readback cleanup slice.

## Next Session Order

Restart Skyrim before testing. The previous live session had old script state loaded before the manager compile.

1. **Retest Naming from a fresh load.**
   - Bosmer origin.
   - Set any Bosmer path from the MCM debug page.
   - Click `Seed Bosmer variety`.
   - Sleep once in the target bed/cell and accept the hearth declaration prompt.
   - Sleep again in the same bed/cell.
   - Expected: Naming menu appears; "Not yet" does not spend cooldown; one told-self effect applies; retelling clears the old told-self first.

2. **Retest The Path Goes Quiet.**
   - Drop active Bosmer scoring deity below 25.
   - Run dawn pass.
   - Expected Active Effects: `The Path Goes Quiet`.
   - Expected feel: stamina regenerates 5% more slowly, not held near zero.
   - If it still feels too harsh after the PeakValueModifier fix, tune magnitude. Do not change the actor value/archetype again without new readback evidence.

3. **Confirm Exchange T1/T2 copy in game.**
   - Exchange path, piety 25 and 50, run dawn pass.
   - Expected T1/T2 descriptions name `Z'en`; T3 already did.

4. **Historical: Bosmer variety smoke that was later closed.**
   - Hearth + Tale Carried.
   - Songs of the Green, including Eldergleam interior-only behavior.
   - Scales at Rest.
   - Baan Dar Gap combat-session cadence: sub-20% in combat fires; ordinary/off-path/non-combat/subsequent same-day moments stay silent.
   - Naming coherence fade/restore at dawn.

5. **Historical: slots that were later closed for the current packet.**
   - Bandit Road T1/T2/T3.
   - Broad Y'ffre lane plus suppression under active path.
   - Manual feel note.
   - Asset-status slot.

## Files To Start From

- `references/authoring/PDV_BetaTestPacket_Bosmer.md`
- `references/authoring/PDV_Phase20_ManualEvidenceLedger.json`
- `references/authoring/PDV_PreBetaRaceGateLedger.md`
- `references/authoring/PDV_InGameTestingNeeded_Runbook.md`
- `references/authoring/PDV_BosmerRewardRecords.spec.json`
- `tools/pdv-phase20-race-author/Program.cs`

## Stop Conditions

- If Naming still does not show after a fresh load and the two-sleep hearth route, inspect the current Papyrus log before changing code.
- If stamina still does not regenerate under `The Path Goes Quiet`, capture the exact Active Effects stack and stamina AV state; the record readback is correct, so the next question is magnitude or an interaction with another effect.
- If Baan Dar Gap fires on ordinary combat, off-path combat, non-combat low health, or more than once per day, treat the combat-session poll as the active bug surface.
