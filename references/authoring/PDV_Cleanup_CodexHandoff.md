# Codex Handoff — Cleanup (1C-fix + Orc Code Holds display)

**Owner:** Codex (live Papyrus). **Author:** Claude. **Priority:** low — none of
this blocks beta; fold in next time Codex touches `PDV__ManagerQuest.psc` (e.g.
before/with 1F). **File:** `PDV__ManagerQuest.psc`. Compile + verify + hand back
as usual.

## Part A — 1C-fix: gate the cap on the AWARD SINK only (5 handlers)

The 1C anti-farm pass is correct and complete, but in 5 handlers the
`if multiplier <= 0.0 return` bail was placed BEFORE non-pulse side effects
(favor-spell activation, source-favor/evidence records, P2 book notices, green-pact
compliance) instead of gating only the piety award. These are **latent** today
(`ConsumeDailyRepeatMultiplier` returns 0.7ⁿ, which never reaches ≤ 0), so nothing
misbehaves in practice — but they become **live bugs** the day that function ever
returns 0 (e.g. a future hard daily cap). Fix = move the gate so it wraps ONLY the
award call; side effects fire unconditionally. Pattern:
```papyrus
; BEFORE (suppresses side effects on a decayed repeat):
Float multiplier = ConsumeDailyRepeatMultiplier(key)
if multiplier <= 0.0
    return
endIf
RecordSourceFavor(...) ; favor spell / notice / bookkeeping
Award...Scaled(..., multiplier)

; AFTER (cap gates only the award):
Float multiplier = ConsumeDailyRepeatMultiplier(key)
RecordSourceFavor(...) ; side effects run regardless
if multiplier > 0.0
    Award...Scaled(..., multiplier)
endIf
```

| Handler (≈line) | Fix |
|---|---|
| `HandleAltmerDawnSteadiness` (~6057) | bail currently precedes `RecordAltmerSourceFavor` / `TryActivateContextualFavor` (favor SPELL) / `ShowP2BookNotice` — let those run; gate only `AwardAltmerDawnSignal(multiplier)` |
| `HandleAltmerOrthodoxCostlyEnforcement` (~6083) | same shape; gate only `AwardAltmerOrthodoxSignal(multiplier)` |
| `RouteNordFamily` (~12604) | **spec said cap at the `AwardNordRouteFamilySignal` sink, not the entry.** Currently bails with `return False`, which also drops the favor spell, the count/lastReason bookkeeping, and (via the False return) the caller's `ShowP2BookNotice` in `HandleNordOldWaysState`. Keep those; gate only the `AwardNordRouteFamilySignal(...)` call |
| `HandleBosmerPactPositiveSignal` (~3916) | bail precedes `RecordEvidenceDay` + `AdjustBosmerGreenPactCompliance(5, reason)` — let those run; gate only the award. (The other 3 Bosmer sinks bail before `RecordEvidenceDay` only, no extra effect — benign, fix if convenient.) |
| `HandleTalosShrineDefiance` (~5814) | LOWEST priority / optional: no explicit bail (the award self-bails inside `AwardCuratedSignalScaled`), and the post-award `ApplyImperialConcordatAction('hidden_talos_shrine',...)` is a penalty that arguably *should* fire full each time. Leave unless you want template consistency. |

No magnitudes change; this is purely moving where the `<= 0` gate sits.

## Part B — Orc Code Holds: drop the vestigial spell cast (display honesty)

`TryOrcCodeHolds` (lines ~3764–3771) casts a HealRate "Health Regeneration" MGEF
for flavor, then does the real flat `RestoreActorValue`. Under Requiem the cast
shows a "+X% Health Regeneration" Active Effect that does ~0 (misleading); under
vanilla it's a minor double-dip on top of the flat restore. The flat restore is
the single honest heal in both modes. Remove the two casts:
```papyrus
    if malacathTier >= TIER_DEVOTED && PDV_SPEL_OrcCodeHolds_Devoted
        PDV_SPEL_OrcCodeHolds_Devoted.Cast(playerRef, playerRef)   ; <- DELETE
        playerRef.RestoreActorValue("Stamina", 30.0)
        playerRef.RestoreActorValue("Health", 60.0)
    elseIf PDV_SPEL_OrcCodeHolds
        PDV_SPEL_OrcCodeHolds.Cast(playerRef, playerRef)           ; <- DELETE
        playerRef.RestoreActorValue("Health", 40.0)
    endIf
```
Keep the tier gating + the `RestoreActorValue` lines exactly. Leave the now-unused
`PDV_SPEL_OrcCodeHolds` / `_Devoted` properties declared (harmless; their MGEFs
join the orphan set Claude prunes at packaging). **Confirm first** the spell has no
intended cast visual/sound the designer wanted; if it does, the alternative is to
hide the MGEF in the UI instead of removing the cast — flag to Claude either way.

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
node .\tools\pdv_verify.mjs
```
Expect `1 succeeded, 0 failed`, `FAIL=0`. Tell Mari when compiled so Claude pulls
into the mirror.

## Not in this packet (Claude's lane / deferred)

- Orphan `_HealRateMult` MGEF prune (~24 records, all 0-ref): deferred to a Phase-5
  xEdit "remove unused records" pass before packaging — harmless to leave until then.
- 1B penalty re-author: separate, folds into the Session-C ESP tuning pass.
