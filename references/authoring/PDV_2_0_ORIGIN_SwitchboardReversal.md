# ORIGIN adapter split -- switchboard reversal record

Status: LIVING until the ORIGIN split closes, then ARCHIVE.

Written BEFORE the base->lane re-routes, at the owner's instruction: *"document what we will
lose in case we realise that was a mistake and need to call it back up."*

Each entry records a race switchboard on `PDV_OriginRuntimeBase` that the split dissolves,
what each race branch actually did, the signal id replacing it, and how to recover the
original. The git diff alone is not enough -- it shows WHAT changed but not WHY a branch
existed, which is the part that is expensive to reconstruct later.

**To recover any original:** `git show 80192e4f:live-source/Scripts/Source/PDV_OriginRuntimeBase.psc`
(the last commit before re-routing began) and find the function by name.

---

## 1. HandleSubstrateActionEvent (base:11088) -- the biggest one

**Shape today:** a four-arm origin switch (`if origin == ORIGIN_IMPERIAL ... elseIf
ORIGIN_ARGONIAN ... elseIf ORIGIN_NORD ... elseIf ORIGIN_ALTMER`), each arm further switching
on `eventType`, ~78 lines.

| Race | eventType | What it does | Extra gate |
|---|---|---|---|
| Imperial | 330 / 331 / 332 | `PDV_ImperialAncestorSubstrate.RecordCivicStandingScaled(1.0, "craft_" + reason)` then `SendPrismaSubstrateProgress("imperial-civic", ...)` | `!IsImperialVampireStateActive()` |
| Argonian | 333 | `PDV_ArgonianHistSubstrate.RecordCulturalPractice("argonian_cooked_meal", reason)` | -- |
| Nord | 313 | `RecordAncestralRestScaled(1.0, "open_sky_rest_" + reason)` | -- |
| Nord | 333 | `RecordHearthReturnScaled(1.0, "cooked_meal_" + reason)` | -- |
| Altmer | 330 / 331 | `RecordHeritageStandingScaled(1.0, craftToken + reason)`, `AppendAltmerHeritageVoice(...)`, plus a Magnus aperture once-per-day signal on 331 | `!IsAltmerFavorSuppressedByCurse()` |
| Altmer | 340 / 341 / 342 | `RecordHeritageStandingScaled(1.0, "study_" + reason)`, `AppendAltmerHeritageVoice(...)`, plus the P5 Xarxes study stamp read at the NEXT dawn | same |

**Replaced by:** `HandleContextualSignal("substrate-action", reason, None, eventType as Float)`.
Each adapter implements only its own arm, keeps its own suppression gate, and reaches the
substrate scripts through `Manager.PDV_*Substrate` exactly as today.

**Why this is the function-level route (D11):** routing only the leaf `AppendAltmerHeritageVoice`
call would have left this entire four-arm switch on the base. Routing the whole function
dissolves the switch AND lets `AppendAltmerHeritageVoice(Float, String) -> String` move to the
Altmer adapter, where its signature stops being a problem.

**Reversal risk:** the Altmer arms carry a deliberate design note in-source -- each arm keeps
its OWN `metricBefore` / `RecordHeritageStandingScaled` / voice call rather than sharing one,
because `TryAwardSubstrateDayCredit` caps the substrate at one +4.0 credit per day and the
per-arm bookkeeping is what keeps each feed's accounting honest. **If the Altmer substrate
ever starts double-counting or losing a day credit after the split, this is the first place to
look.** Preserve the per-arm structure inside the adapter; do not "simplify" it into one shared
path.

---

## 2. HandlePlayerSleepStop (base:11035)

**Shape today:** nine sequential `if originRace == ORIGIN_<X>` tests, each calling that race's
`Handle<Race>SleepEvents(playerRef, reason)` -- except Khajiit, which does NOT have a sleep
handler and instead branches on sleep-start context.

| Race | Behaviour |
|---|---|
| Khajiit | `if !hadSleepStartContext` -> trace only. `elseIf sleepStartedOutside` -> `HandleKhajiitRoadHome("outdoor_rest_" + reason)`. Indoor rest does nothing. |
| Argonian, Bosmer, Breton, Dunmer, Altmer, Nord, Orc, Redguard | `Handle<Race>SleepEvents(playerRef, reason)` |

**Replaced by two signals**, because the Khajiit path needs context the other eight do not:
```papyrus
if hadSleepStartContext && sleepStartedOutside
    Manager.OriginRuntime.HandleContextualSignal("outdoor-rest", reason, playerRef)
endIf
Manager.OriginRuntime.HandleContextualSignal("sleep-stop", reason, playerRef)
```
Khajiit answers `"outdoor-rest"` only; the other eight answer `"sleep-stop"` only. That
preserves today's behaviour exactly -- Khajiit currently gets no generic sleep handler, and
the other eight ignore sleep-start context.

**Reversal risk:** the `hadSleepStartContext` / `sleepStartedOutside` booleans are computed by
the sleep-START capture, not re-sampled at wake. That is deliberate -- see the standing rule
that Khajiit road-home classification must use captured sleep-start context rather than
re-sampling the wake cell. **Do not let a future refactor move that decision into the adapter
by re-reading the current cell.**

---

## 3. ApplyUndeadCryptClearReaction (base:11447)

**Shape today:** the function is mostly stance handling (CURSE / TABOO / HOSTILE / FOREIGN /
TOLERATED) that is NOT race logic and stays. Only the tail is a switchboard:
```papyrus
if IsKhajiitOrigin()
    BridgeKhajiitMatrixFocus(deityName, "small")
endIf
```

**Replaced by:** `HandleContextualSignal("crypt-clear-focus", deityName, None, 0.0)`, with the
Khajiit adapter calling `BridgeKhajiitMatrixFocus(reason, "small")`.

**Note the deliberate slot reuse:** `deityName` rides the `reason` parameter. That is a mild
semantic stretch -- `reason` normally carries provenance -- but it is a String slot and the
value is contextual. Recorded here so it is not mistaken later for a bug.

**Reversal risk:** the `"small"` magnitude is a literal at this call site; the adapter supplies
it. If another caller ever needs `"milestone"`, it needs its own id rather than a magnitude
argument.

---

## 4. HandleThalmorUnprovokedKill (base:11527)

**Shape today:** a two-arm race switch, the cross-race dispatcher.
```papyrus
if IsAltmerOrigin()
    HandleAltmerAlignmentSignal("kill_thalmor_agent", victimForm, "thalmor_unprovoked_kill")
elseIf GetPlayerOriginRaceIndex() == 1
    ApplyImperialConcordatAction("kill_thalmor_justiciar_unprovoked", "thalmor_unprovoked_kill")
endIf
```
An unprovoked Thalmor kill matters to Altmer (heritage/alignment) and to Imperials (Concordat)
for different reasons. Every other race: nothing.

**Replaced by:** two signals with the action key doubling as the id -- `"kill_thalmor_agent"`
(Altmer, arm already added) and `"kill_thalmor_justiciar_unprovoked"` (Imperial, arm already
added). The base fires both; only the live adapter answers one.

---

## 5. HandleTalosShrineDefiance (base:11506)

**Shape today:** two separate race gates around shared award logic.
- `if GetPlayerOriginRaceIndex() == ORIGIN_IMPERIAL && !IsImperialVampireStateActive()` ->
  sets `PDV.Imperial.TalosBroadUnlocked`, unlocking the Imperial broad Talos roster.
- The Talos curated-signal award itself is race-free and stays on the base.
- `if GetPlayerOriginRaceIndex() == 1` -> `ApplyImperialConcordatAction("hidden_talos_shrine", "talos_shrine_" + reason)`.

**Replaced by:** the `"hidden_talos_shrine"` signal (Imperial arm already added). The
`TalosBroadUnlocked` write moves into the Imperial adapter with its vampire gate intact.

**Reversal risk:** the in-source comment marks the Concordat call as *"Phase 7 verifier
compatibility"* and records the older direct form `ApplyConcordatPressure(-15, "talos_shrine_" + reason)`.
If a Phase 7 gate starts failing after the split, that comment is the reason the call looks
indirect.

---

## 6. HandlePlayerBelowHealthGate (base:11236)

**Shape today:** three unconditional calls, each race-gated inside its own function.
```papyrus
TryBosmerBaanDarGap(playerRef)
TryArgonianSithisNearDeathBurst(playerRef)
TryOrcCodeHolds(playerRef)
```

**Replaced by:** three signals -- `"baandar-gap"`, `"sithis-near-death"`, `"code-holds"` (Orc
arm already added) -- each passing `playerRef` as `contextForm`. Equivalent: today all three
are called and two early-return on their race check; after, two hit the inert base default.

**Reversal risk:** an in-source note records that Orc Code Holds fires MID-FIGHT from here
(paired with a felt flat stamina restore because Requiem zeroes regen). Keep it on the
below-health path; it is not a dawn or rest effect.

---

## 7. GetPlayerCursePublicLabel (base:12031)

**Shape today:** a player-race switch feeding a fallback chain.
```papyrus
if GetPlayerOriginRaceIndex() == ORIGIN_ALTMER
    String altmerCurseLabel = GetAltmerCursePublicLabel()
    if altmerCurseLabel != "" ... return it
endIf
... PDV_CurseStateService.GetCurseStateLabel() if != "None"
... if HasNordVampireScar() -> "Cured vampire scar"
... "None"
```

**Replaced by:** `GetOriginDetailLabel("curse-public-label")` first, then the same fallback
chain. Nord's `HasNordVampireScar` becomes `GetOriginDetailValue("vampire-scar")`.

**Reversal risk:** the ORDER is load-bearing -- the race-specific label wins over the generic
curse label, which wins over the Nord scar, which loses to "None". Preserve that precedence.

---

## What is deliberately NOT dissolved

Three functions keep their race shape on the base, on merit rather than as exceptions:

- **`GetBroadLaneDisplayName(Int origin)`** (base:11715) and **`GetBroadLaneSymbol(Int origin)`**
  (base:11739) switch on an origin PARAMETER, answering about races the player is not -- the
  medallion roster renders all ten. Exactly one adapter is instantiated, so there is nothing
  to dispatch to. These are lookup tables, not switchboards.
- **`GetNordPantheonBaselineState()`** (base:8426) is not race behaviour at all: it reads
  `Manager.PDV_NordPantheonBaselineTrack.GetCurrentState()` with a StorageUtil debug fallback.
  A manager track read carrying a race name.

The durable gate must therefore test for branches on `GetPlayerOriginRaceIndex()` /
`Is<Race>Origin()` -- who the PLAYER is -- and not merely for the presence of `ORIGIN_*`
comparisons, or it will flag these three forever.
