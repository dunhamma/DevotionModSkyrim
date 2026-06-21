# Codex Handoff — Custom-Race Origin Robustness (1H)

**Owner:** Codex (live Papyrus). **Author of this spec:** Claude.
**Batch:** 1H. **Implement:** early (pairs with Session A custom-race smoke).
**Origin:** friend's "SOS - Ohmes-Raht Player Devotion Script Patch" + Codex's
upstream notes. We adopt the *robust* ideas and **reject** the patch's
version-specific hacks (see Reject list). **Files:**
`PDV_Origin.psc`, `PDV_PlayerEvents.psc`, `PDV_MCM.psc` (all live).

## Why

Two real bugs confirmed against live source:
1. `PDV_Origin.SeedDeity` (≈line 385) calls `PDV_Manager.RecomputeTier(deity)`
   **1-arg**. The manager signature is
   `Int Function RecomputeTier(PDV_DeityBase deity, Bool surfaceTierUp = True)`
   (PDV__ManagerQuest:6289) — so origin SEEDING surfaces spurious "tier up"
   cues at character creation, for **every** race.
2. `PDV_Origin.InitializeOrigin` (lines 70–103) bails whenever
   `PDV_GLO_OriginRace.GetValueInt() >= 0`, so a modded race that fell back to
   Imperial (`PDV.CustomRaceFallback == 1`) is **stuck forever** — it never
   re-consults `PDV_RaceMap.json` even after a mapping exists.

(The Ohmes→Khajiit mapping itself already ships in
`SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_RaceMap.json` — `0x03322B` and
`0x05693A` of HalfKhajiit.esp → index 6. So **no script hardcoding is needed**;
fresh Ohmes saves already resolve. This batch fixes the toast bug and makes
already-stuck saves recoverable.)

## Fix 1 — suppress origin-seed tier surfacing (`PDV_Origin.SeedDeity`, ≈385)

```papyrus
    if PDV_Manager
        PDV_Manager.RecomputeTier(deity, False)   ; was RecomputeTier(deity)
    endIf
```
Seeding starting piety must not announce tier-ups.

## Fix 2 — recoverable custom-race fallback (`PDV_Origin.InitializeOrigin`, 70–103)

Replace the unconditional early-bail (lines 76–79) so an already-set origin is
RE-RESOLVED only when it was a fallback or a manual reset was requested — never
unconditionally, never keyed on a specific race:
```papyrus
    Actor playerActor = GetPlayerActor()
    if PDV_GLO_OriginRace.GetValueInt() >= 0
        if playerActor && ShouldRetryOriginCapture()
            Trace(1, "InitializeOrigin retrying: prior result was a custom-race fallback or a manual reset was requested.")
        else
            Trace(2, "InitializeOrigin skipped: origin already set to " + PDV_GLO_OriginRace.GetValueInt())
            return
        endIf
    elseIf !playerActor
        Trace(1, "InitializeOrigin skipped: player unavailable.")
        return
    endIf
```
Add the gate (NO Ohmes/HalfKhajiit FormIDs — purely flag-driven):
```papyrus
Bool Function ShouldRetryOriginCapture()
    if StorageUtil.GetIntValue(None, "PDV.Origin.ForceRedetect", 0) == 1
        return true
    endIf
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback", 0) == 1
        return true
    endIf
    return false
EndFunction
```
On a successful re-resolve, the existing `SeedProofSliceDeities`/`RecordCustomRaceResolved`
path already clears `PDV.CustomRaceFallback`. Also clear the manual flag after a
retry so it's one-shot — add at the top of the seed path (after line 97
`PDV_GLO_OriginRace.SetValue(...)`):
```papyrus
    StorageUtil.SetIntValue(None, "PDV.Origin.ForceRedetect", 0)
```
Guard against re-notifying: `RecordCustomRaceFallback` already no-ops its
`Debug.Notification` when the flag is already 1, so a retry that stays
unresolved won't re-spam. Keep that behavior.

## Fix 3 — one-shot origin re-check on load (`PDV_PlayerEvents.psc`)

Add a queued, run-once-per-load call to `InitializeOrigin` after player
load/init, so a recoverable fallback gets re-resolved on the next load (it's a
cheap no-op for resolved saves because Fix 2 bails fast unless a flag is set).
Model on the friend's `PDV_PlayerEvents.psc` (in the patch folder) — a local
`Bool` "queued this load" flag, NOT a RegisterForUpdate loop. **Locate** our
existing player-alias load hook (`OnPlayerLoadGame`/`OnInit`/the EventBus
player-alias entry) and route the one-shot through the manager's origin quest
ref. Do **not** re-detect every frame or every event.

## Fix 4 — MCM "Re-detect origin" button (`PDV_MCM.psc`, Compatibility page)

The Compatibility page already hosts the Survival toggle (`_oidCompatSurvival`,
≈line 1069). Add a button there:
```papyrus
_oidReDetectOrigin = AddTextOption("Re-detect origin", "Run now", OPTION_FLAG_NONE)
```
On select: confirm, set `StorageUtil.SetIntValue(None, "PDV.Origin.ForceRedetect", 1)`,
invoke `InitializeOrigin` on the origin quest (resolve it the same way the page
resolves other PDV services), then `ForcePageReset()` and a one-line
`Debug.Notification` of the resolved profile. This is the manual recovery for any
stuck save and a clean tester aid.

## REJECT (do not bring over from the friend's patch)

- Hardcoded `IsOhmesRahtRace` / HalfKhajiit.esp FormIDs in `PDV_Origin` — the
  mapping lives in `PDV_RaceMap.json` (data), already shipped.
- The broad `PDV_Origin`/`PDV_PlayerEvents` override as-shipped (version-specific,
  tailored to one stuck save).
- Unconditional re-detection every load — gate on fallback/reset flag only.

## Claude's lane (already done / confirm-only)

`PDV_RaceMap.json` already contains the two HalfKhajiit Ohmes FormIDs → 6. I'll
confirm it's in the live deploy. Other custom races add their own RaceMap entries
(or ship RaceCompatibility proxy keywords, already handled by `ResolveViaActorProxy`).

## Compile & verify

```powershell
node .\tools\pdv_compile.mjs --script PDV_Origin --script PDV_PlayerEvents --script PDV_MCM
node .\tools\pdv_verify.mjs
```
Expect `1 succeeded, 0 failed` per script, `FAIL=0`. Snapshot + hand back.

## In-game proof (User — Session A, custom-race slot)

1. Fresh Ohmes-Raht (HalfKhajiit.esp) char → origin resolves to **Khajiit** (no
   Imperial fallback), and **no** tier-up toast at creation.
2. Stuck save (origin cached Imperial-fallback) → on next load it self-heals to
   Khajiit; or use MCM "Re-detect origin" → resolves to Khajiit.
3. A truly-unsupported custom race with no RaceMap/proxy entry → stays Imperial
   fallback with the single notice, and does NOT re-spam each load.
Record in the manual evidence ledger (framework-floor / custom-race slot).
