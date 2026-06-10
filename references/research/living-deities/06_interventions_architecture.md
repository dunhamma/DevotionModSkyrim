# A3 Interventions -- Architecture (buildable spec)

**Status:** DESIGN DOSSIER, 2026-06-10. Buildable spec for A3c (Blessing Surge),
A3d (Smite/Curse), and A3f (Hades Sacrifice) -- the P1 pilot scope from the charter.
A3b and A3e are documented at backlog level only. No Papyrus/CK/ESP changes made.
Names are the contract; line numbers drift.

**Precondition:** LD-P1 runtime-proven. Functions below that reference LD-P1 seams
(OnMoodBandCross, RunDawnUpdateMood, mood-band StorageUtil namespace, FulfillDemand)
cannot be wired until those functions exist in the compiled manager.

---

## 1. StorageUtil namespaces

### Per-deity intervention state (form-keyed, mirrors PDV.Demand.* pattern)

```
; A3c -- Blessing Surge (no persistent state needed; MGEF duration handles expiry)
; No new StorageUtil keys.

; A3d -- Smite
PDV.Intervention.Smite.Day        (int)   ; devotion-day index of last smite
PDV.Intervention.Smite.Count      (int)   ; smites this devotion-day (cap = 1)
PDV.Intervention.Smite.LastFire   (float) ; gametime of last smite (cooldown check)

; A3e -- Rivalry Strike (per rival; keyed on rival deity form)
PDV.Intervention.Strike.Day       (int)   ; devotion-day index of last strike
PDV.Intervention.Strike.LastFire  (float) ; gametime

; A3f -- Hades Sacrifice (global, not per deity; only one active offer at a time)
; Keyed on None (global, like PDV.Commitment.*)
PDV.Intervention.Sacrifice.Active         (int)   ; 1 = offer pending
PDV.Intervention.Sacrifice.RivalIndex     (int)   ; DeityIndex of rival offering
PDV.Intervention.Sacrifice.PatronIndex    (int)   ; DeityIndex of patron being sacrificed
PDV.Intervention.Sacrifice.TargetBoonTier (int)   ; 1/2/3 = Seeker/Devoted/Champion
PDV.Intervention.Sacrifice.OfferedAt      (float) ; gametime
PDV.Intervention.Sacrifice.ExpiresAt      (float) ; gametime (3 game-days default)
PDV.Intervention.Sacrifice.Fulfilled      (int)   ; 1 = accepted, 2 = declined, 0 = pending
```

All keys follow the existing PDV.* StorageUtil discipline: floats via
StorageUtil.GetFloatValue/SetFloatValue, ints via GetIntValue/SetIntValue, form-keyed
where per-deity, None-keyed where global.

---

## 2. New PDV_DeityBase authored properties

One new property required on PDV_DeityBase (for A3f):
```
Spell Property Sacrifice_Boon Auto
```
Default = None. Deities that cannot offer a Sacrifice (no rival boon authored) simply
have Sacrifice_Boon == None, which is checked before the offer is fired. No sub-class
needed; the None-guard is sufficient.

One new property per-deity for A3d (smite magnitude/threshold):
```
Float Property SmiteThresholdDelta = 2.0 Auto
Spell Property Smite_Effect Auto
```
SmiteThresholdDelta: the minimum abs(negative score) from a single faucet event
required to trigger the smite check (guards against trivial micro-negatives spamming
smites). Default 2.0 piety (approximately half of PIETY_DAILY_MAX_DELTA). Smite_Effect:
the timed MGEF spell for this deity's domain-flavored smite. None = no smite authored
(failsafe).

---

## 3. Named functions and slot-in points

### 3.1 A3c -- TryApplyBlessingSurge (new function)

**Where it slots:** inside OnMoodBandCross(), immediately after SyncPatronBoonsToBand()
is called on an up-cross.

```
; slot-in: after SyncPatronBoonsToBand(deity, newBand) on up-cross to Pleased or Exalted
TryApplyBlessingSurge(deity, newBand)
```

**Function shape:**
```
Function TryApplyBlessingSurge(PDV_DeityBase deity, Int newBand)
    ; only on up-cross to Pleased or Exalted
    if newBand < MOOD_BAND_PLEASED
        return
    endIf
    Spell surgeSpell = deity.GetSurgeSpellForBand(newBand)
    if !surgeSpell
        return
    endIf
    Game.GetPlayer().AddSpell(surgeSpell, False)
    SendPrismaEventToast("surge", deity, "", "", "")
    Trace(2, "[PDV] Blessing surge fired: " + deity.DeityName + " band " + newBand)
EndFunction
```

GetSurgeSpellForBand() is a new PDV_DeityBase method returning the authored surge spell
for the given band. Simplest implementation: two new properties on PDV_DeityBase,
Surge_Pleased and Surge_Exalted (Spell), defaulting to None.

**Anti-spam:** a surge fires at most once per band-up-cross. Band can only cross once
per dawn cycle under normal play (mood moves only in RunDawnUpdateMood). No additional
cooldown key needed. MCM density: surge fires only if MCM density slider > threshold
(reuse the existing density gate applied to all A2/A3 events).

**CK authoring required:** Surge_Pleased and Surge_Exalted spell records per deity.
Domain flavoring: Kyne Pleased surge = 90s Fortify Stamina Regen 25%; Kyne Exalted
surge = 90s Fortify Archery 20% + Fortify Stamina Regen 20%. Hircine Pleased surge
= 90s Fortify Health Regen 20% (beast endurance); Hircine Exalted surge = 120s
Fortify One-Handed 15% + Fortify Health Regen 25%.

---

### 3.2 A3d -- TryApplySmite (new function)

**Where it slots:** inside ApplyDeityReaction() (live:877), after
AwardPietyInternal() is called with a negative appliedAmount for the active patron
deity.

```
; slot-in: after AwardPietyInternal call in ApplyDeityReaction, when appliedAmount < 0
if deity == _activeDeity && appliedAmount < 0.0
    TryApplySmite(deity, isFaucet, Abs(appliedAmount))
endIf
```

**Function shape:**
```
Function TryApplySmite(PDV_DeityBase deity, Bool isFaucet, Float negDeltaAbs)
    ; check band
    Int moodBand = StorageUtil.GetIntValue(deity as Form, "PDV.Mood." + deity.DeityName + ".Band")
    if moodBand != MOOD_BAND_WROTH
        return
    endIf
    ; check threshold
    if negDeltaAbs < deity.SmiteThresholdDelta
        return
    endIf
    ; check authored smite spell
    if !deity.Smite_Effect
        return
    endIf
    ; anti-spam: once per devotion-day
    Int currentDay = deity.GetDevotionDayIndex()
    Form deityForm = deity as Form
    if StorageUtil.GetIntValue(deityForm, "PDV.Intervention.Smite.Day") == currentDay
        if StorageUtil.GetIntValue(deityForm, "PDV.Intervention.Smite.Count") >= 1
            return
        endIf
    else
        StorageUtil.SetIntValue(deityForm, "PDV.Intervention.Smite.Day", currentDay)
        StorageUtil.SetIntValue(deityForm, "PDV.Intervention.Smite.Count", 0)
    endIf
    ; MCM density gate (same gate as omen dispatch)
    if !PassesDensityGate()
        return
    endIf
    ; fire
    StorageUtil.SetIntValue(deityForm, "PDV.Intervention.Smite.Count",
        StorageUtil.GetIntValue(deityForm, "PDV.Intervention.Smite.Count") + 1)
    StorageUtil.SetFloatValue(deityForm, "PDV.Intervention.Smite.LastFire",
        Utility.GetCurrentGameTime())
    Game.GetPlayer().AddSpell(deity.Smite_Effect, False)
    SendPrismaEventToast("smite", deity, "", "", "")
    Dispatch("smite", deity.DeityName, "onset", deity.DeityIndex, "dread")
EndFunction
```

Notes:
- "PDV.Mood.<deityName>.Band" is the band namespace from LD-P1. The exact key
  format must match what RunDawnUpdateMood writes -- PROOF ITEM: confirm the exact
  StorageUtil key string written by LD-P1's band write.
- Abs() is not a native Papyrus function. Use: if negDeltaAbs < 0.0 then
  negDeltaAbs = negDeltaAbs * -1.0 before the threshold check (caller already passes
  Abs(appliedAmount) as a positive float).
- Dispatch() refers to PDV_DiegeticDirector.Dispatch() (live:41), called via the
  director reference. The "dread" tone is already wired in GetProfileTone (live:203).
  A new "smite" eventClass arm must be added to GetProfileTone -- proof item.
- PassesDensityGate() is the MCM density check function from LD-P1/A2.

**CK authoring required:** Smite_Effect spell records per deity. Domain flavoring:
Kyne Wroth smite = 30s Weakness to Poison 20% + Weakness to Shock 15% ("Kyne
withdraws her ward"). Hircine Wroth smite (werewolf only) = 30s Weakness to Frost
25% + Fortify Damage from Beasts 20% ("the hunt turns against you").

---

### 3.3 A3f -- Hades Sacrifice (flagship)

**Dawn slot-in:** A3f offer eligibility is checked once per dawn alongside the
demand scheduler. Add a sub-call inside RunDawnProcessDemands() (LD-P1 authored):

```
; slot-in: inside RunDawnProcessDemands, after demand offer evaluation
EvaluateSacrificeOffer()
```

**EvaluateSacrificeOffer (new function):**
```
Function EvaluateSacrificeOffer()
    ; skip if already pending
    if StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.Active") == 1
        return
    endIf
    ; skip if no active patron
    if GetPatronState() != PATRON_STATE_ACTIVE
        return
    endIf
    PDV_DeityBase patron = _activeDeity
    if !patron
        return
    endIf
    ; find the best eligible rival for Sacrifice
    PDV_DeityBase rival = GetSacrificeRivalCandidate(patron)
    if !rival
        return
    endIf
    ; check rival has a Sacrifice_Boon authored
    if !rival.Sacrifice_Boon
        return
    endIf
    ; determine highest active boon tier on the patron
    Int boonTier = GetHighestActiveBoonTier(patron)
    if boonTier == 0
        return
    endIf
    ; offer
    Float nowTime = Utility.GetCurrentGameTime()
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.Active", 1)
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.RivalIndex", rival.DeityIndex)
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.PatronIndex", patron.DeityIndex)
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.TargetBoonTier", boonTier)
    StorageUtil.SetFloatValue(None, "PDV.Intervention.Sacrifice.OfferedAt", nowTime)
    StorageUtil.SetFloatValue(None, "PDV.Intervention.Sacrifice.ExpiresAt", nowTime + 3.0)
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.Fulfilled", 0)
    SendPrismaEventToast("sacrifice_offer", rival, "", "", patron.DeityName)
    Dispatch("sacrifice", rival.DeityName, "offer", rival.DeityIndex, "dread")
    ; surface the choice (see 3.3a)
    PresentSacrificeChoice(rival, patron, boonTier)
EndFunction
```

**GetSacrificeRivalCandidate (new function):**
Iterates patron.RivalDeities[]. Returns the first rival whose mood band is Wroth
(PDV.Mood.<rivalDeity>.Band == MOOD_BAND_WROTH) and whose Sacrifice_Boon is not None
and who is in the active patron pool. Returns None if no eligible rival.

**GetHighestActiveBoonTier (new function):**
Checks whether patron.Boon_Champion is on the player (HasSpell), then Boon_Devoted,
then Boon_Seeker. Returns the highest tier present (3/2/1) or 0 if none active.

**PresentSacrificeChoice (new function):**
Surfaces the offer to the player. PROOF ITEM: use MessageBox as the safe fallback
until the Prisma two-option surface is verified. MessageBox fires synchronously on
the UI thread; it cannot be called from OnUpdate; it must be called from a quest
fragment or via a deferred Message.Show(). The cleanest path: set a pending flag,
let the daily dawn surface it via a Message.Show() call in the main quest thread.
```
; MessageBox text pattern (authored via Message record in CK):
; "<RivalName> demands you surrender <PatronName>'s gift. Accept?"
; [Yes] -> AcceptSacrifice()    [No] -> DeclineSacrifice()
```

**AcceptSacrifice (new function):**
```
Function AcceptSacrifice()
    Int rivalIdx = StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.RivalIndex")
    Int patronIdx = StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.PatronIndex")
    Int boonTier = StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.TargetBoonTier")
    PDV_DeityBase rival = GetDeityByIndex(rivalIdx)
    PDV_DeityBase patron = GetDeityByIndex(patronIdx)
    if !rival || !patron
        ClearSacrificeState()
        return
    endIf
    ; scoped boon removal: only the target tier boon
    Spell removedBoon = GetBoonSpellForTier(patron, boonTier)
    if removedBoon
        Game.GetPlayer().RemoveSpell(removedBoon)
    endIf
    ; grant rival boon
    Game.GetPlayer().AddSpell(rival.Sacrifice_Boon, False)
    ; patron mood penalty: -20 mood points (approx 2 days of negative signal at alpha 0.12)
    ; Use PushMoodModifier if LD-P2 is live, else direct StorageUtil adjust
    Float moodPenalty = -20.0
    StorageUtil.AdjustFloatValue(patron as Form, "PDV.Mood." + patron.DeityName, moodPenalty)
    ; surface
    SendPrismaEventToast("sacrifice_accepted", rival, "", "", patron.DeityName)
    Dispatch("sacrifice", rival.DeityName, "accepted", rival.DeityIndex, "dread")
    ClearSacrificeState()
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.Fulfilled", 1)
EndFunction
```

**DeclineSacrifice (new function):**
```
Function DeclineSacrifice()
    Int rivalIdx = StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.RivalIndex")
    PDV_DeityBase rival = GetDeityByIndex(rivalIdx)
    if rival
        ; rival mood drops further (player defied the demand)
        Float rivalMoodPenalty = -10.0
        StorageUtil.AdjustFloatValue(rival as Form, "PDV.Mood." + rival.DeityName, rivalMoodPenalty)
        SendPrismaEventToast("sacrifice_declined", rival, "", "", "")
    endIf
    ClearSacrificeState()
    StorageUtil.SetIntValue(None, "PDV.Intervention.Sacrifice.Fulfilled", 2)
EndFunction
```

**Sacrifice expiry (slot-in to RunDawnProcessDemands or its equivalent dawn sweep):**
```
; In RunDawnProcessDemands, check:
if StorageUtil.GetIntValue(None, "PDV.Intervention.Sacrifice.Active") == 1
    if Utility.GetCurrentGameTime() > StorageUtil.GetFloatValue(None,
       "PDV.Intervention.Sacrifice.ExpiresAt")
        ; expired without choice -- treat as decline
        DeclineSacrifice()
    endIf
endIf
```

**Helper functions needed:**
- GetDeityByIndex(Int idx) -- iterates PDV_FLST_AllDeities to find matching DeityIndex.
  This pattern likely already exists or is trivial to add (the commitment-offer engine
  already resolves deities by index from StorageUtil).
- GetBoonSpellForTier(PDV_DeityBase deity, Int tier) -- returns Boon_Seeker/Devoted/
  Champion based on tier int. One if-chain, ~6 lines.
- ClearSacrificeState() -- sets Sacrifice.Active = 0, clears the other keys.

---

## 4. Dawn flow (updated with A3 insertions)

```
RunDawnConsolidateScratch()           ; existing -- computes clampedToday
RunDawnUpdateMood()                   ; LD-P1 -- EWMA + band recompute + OnMoodBandCross
  -> OnMoodBandCross()
       -> SyncPatronBoonsToBand()     ; LD-P1 A4
       -> TryApplyBlessingSurge()     ; A3c -- NEW, on up-cross only
RunDawnRefreshTrackStates()           ; existing
RunDawnApplyDecayNoop()               ; existing
RunDawnApplySpellAndNeglectLayers()   ; existing
RunDawnProcessCommitmentOffers()      ; existing
RunDawnProcessDemands()               ; LD-P1 A1
  -> EvaluateSacrificeOffer()         ; A3f -- NEW, after demand sweep
RunDawnNotifyNoop()                   ; existing
RequestPanelRefresh()                 ; existing
```

Smite (A3d) is NOT in the dawn flow -- it fires reactively in ApplyDeityReaction()
when a negative score is applied. It is not a scheduled event.

---

## 5. Authoring CSV shape

**PDV_InterventionProfile.csv** (new file, mirrors PDV_DemandTable.csv shape):

```
deity, intervention_type, smite_threshold_delta, smite_effect_edid, surge_pleased_edid,
surge_exalted_edid, sacrifice_boon_edid, notes
```

- intervention_type: pipe-list of types this deity participates in
  (e.g. "smite|surge|sacrifice")
- smite_threshold_delta: float, default 2.0 (abs negative delta to trigger smite)
- *_edid: Editor ID strings for the authored spell records; empty = None
- Compiler maps these to PDV_DeityBase authored properties via the CK wiring pass
  (not written to JSON -- these are CK properties, not runtime JSON keys)

Self-test gates for this CSV:
- every deity in PDV_DeityMood.csv has an entry (or an explicit "none" row)
- smite_threshold_delta > 0 for any deity with "smite" in intervention_type
- edid fields non-empty for any type that deity participates in (else hard fail:
  "deity X declared smite but no smite_effect_edid authored")
- sacrifice_boon_edid only non-empty if deity has a rival in RivalDeities[] (else
  warn: "Sacrifice_Boon authored but no rival to trigger it")

---

## 6. Verifier expectations (extend pdv_verify.mjs / pdv_content_verify.mjs)

**A3c Blessing Surge:**
- Surge spell fired on band-up-cross to Pleased and Exalted; not fired on down-cross
- Surge spell is NOT in the Boon_Seeker/Devoted/Champion list (confirm ClearAllBoons
  does not clear it at patron-end)
- No double-surge if dawn triggers two crossings in sequence (should be impossible
  given one EWMA step per dawn, but verify)

**A3d Smite:**
- PDV.Intervention.Smite.Day/Count populated after a smite fires
- Count <= 1 per devotion-day per deity
- Smite does NOT fire when mood band != Wroth (seed Cool mood, apply large negative,
  confirm no smite)
- Smite_Effect is on player for at most the authored MGEF Duration
- No PDV.Curse.* keys written during or after smite (confirm CurseState unmodified)

**A3f Hades Sacrifice:**
- Sacrifice.Active = 1 after EvaluateSacrificeOffer fires (rival Wroth, patron boon active)
- Only one active offer at a time (second rival cannot overwrite a pending offer)
- On AcceptSacrifice: patron's boon-tier spell removed from player; rival boon added;
  PDV.Mood.<patron> decremented ~20; Sacrifice.Active = 0
- On DeclineSacrifice: patron boon intact; rival mood decremented; Sacrifice.Active = 0
- On expiry (ExpiresAt exceeded at dawn): DeclineSacrifice fires once; no repeat
- Sacrifice.Fulfilled persists across save/load (int in None-keyed StorageUtil)

---

## 7. Magnitude calibration (anchored to pacing model)

Pacing constants: PIETY_DAILY_MAX_DELTA = 4.3, Exalted band >= 55 mood, alpha typical
0.12-0.22. One day at max signal = 4.3 piety = ~mood delta of 4.3/4.3*100*alpha = 100
* alpha per day. At alpha 0.15: one ideal day nudges mood ~15 points.

| Effect            | Magnitude | Rationale |
|---|---|---|
| Surge (Pleased)   | +15-25% buff, 90s  | Low-intensity whisper; 1/4 of the Seeker boon value |
| Surge (Exalted)   | +20-30% buff, 90s  | Still transient; not a second persistent boon |
| Smite threshold   | abs(delta) >= 2.0  | ~0.46 days of max signal; non-trivial act only |
| Smite MGEF        | 20-25% weakness, 30s | Felt but not catastrophic; ~1/8 Seeker boon tier |
| Sacrifice patron mood penalty | -20 mood | ~1.3 days of max negative signal at alpha 0.15; serious but not instant Wroth |
| Sacrifice decline rival mood  | -10 mood | ~0.67 days; enough to matter, not punishing |
| Sacrifice offer window        | 3 game-days | Generous; player can encounter it before it expires |

All magnitudes are first-pass defaults. The authoring CSV is the tuning surface;
no magnitude is hardcoded in Papyrus (always read from authored properties or
the CSV-compiled JSON).
