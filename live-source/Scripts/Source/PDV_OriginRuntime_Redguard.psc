Scriptname PDV_OriginRuntime_Redguard extends PDV_OriginRuntimeBase

; ORIGIN adapter -- Redguard lane (sect: Crown / Forebear / Ash'abah, ancestor spine,
; Far Shores token, remembering rite, undead-site death duty, HoonDing / Leki /
; Tuwhacca worship). Cut from PDV_OriginRuntimeBase tranche 3 per
; PDV_2_0_ADR_OriginAdapterInterface.
;
; Section 1 below is the lane's 59 functions, copied BYTE-IDENTICAL from the base so
; the split stays provable against origin_golden.json. Section 2 is the new dispatch
; layer: thin overrides of the base virtuals that delegate to those bodies.
;
; The originals still stand in PDV_OriginRuntimeBase; a same-signature child function
; is simply an override, so this compiles. A central pass removes them from the base
; using PDV_2_0_AdapterManifest_t3.json.
;
; Script variables: this lane reads and writes NONE. Every shared manager script var
; the bodies touch already routes through a Manager accessor (see the tranche-3 header
; comment in the base), so nothing had to move and nothing needs a new base accessor.

; ===========================================================================
; SECTION 1 -- lane functions, copied verbatim from PDV_OriginRuntimeBase
; ===========================================================================

Function HandleRedguardSleepEvents(Actor playerRef, String reason)
    if !playerRef || GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Int sleepCellId = GetInteriorSleepCellId(playerRef)
    if sleepCellId == 0
        return
    endIf

    String declaredKey = "PDV.Redguard.AncestralRest.DeclaredFormID"
    if StorageUtil.GetIntValue(None, declaredKey) == 0
        if TryDeclareRestCell("PDV.Redguard.AncestralRest", sleepCellId)
            ShowRedguardNotification(None, "This resting place remembers the old line.")
            Manager.Trace(2, "Redguard ancestral-rest cell declared: " + reason)
        endIf
        return
    endIf

    if !IsPlayerAtDeclaredRestCell(playerRef, declaredKey)
        return
    endIf

    if TryRedguardRemembering(playerRef, sleepCellId, reason)
        return                          ; Remembering menu shown; suppress the rest-notice this wake
    endIf

    if !Manager.ConsumeOncePerDaySignal("PDV.Signal.RedguardAncestralRest")
        return
    endIf

    RecordRedguardAncestralRest(1.0, "sleep_ancestor_rest_" + reason)
EndFunction

Bool Function TryRedguardRemembering(Actor playerRef, Int sleepCellId, String reason)
    if !playerRef || !Manager.PDV_MSG_RedguardRemembering || GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return false
    endIf

    Float lastRite = StorageUtil.GetFloatValue(None, "PDV.RedRemember.LastRiteTime")
    if lastRite > 0.0 && (Utility.GetCurrentGameTime() - lastRite) < 7.0
        return false
    endIf

    Utility.Wait(0.5)
    Int pressed = Manager.PDV_MSG_RedguardRemembering.Show()
    if pressed < 0 || pressed > 3
        return true                 ; "Not yet" -- cooldown not spent
    endIf

    ApplyRedguardRemembering(playerRef, pressed)
    return true
EndFunction

Function ApplyRedguardRemembering(Actor playerRef, Int index)
    RemoveRedguardRememberSpells(playerRef)
    Spell chosen = GetRedguardRememberSpell(index)
    if !chosen
        return
    endIf

    Int sectNow = 0
    if Manager.PDV_RedguardSectTrack
        sectNow = Manager.PDV_RedguardSectTrack.GetCurrentState()
    endIf

    playerRef.AddSpell(chosen, False)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.Active", index + 1)
    StorageUtil.SetIntValue(None, "PDV.RedRemember.SectAtRite", sectNow)
    StorageUtil.SetFloatValue(None, "PDV.RedRemember.LastRiteTime", Utility.GetCurrentGameTime())
    ; Surface in both Prisma spaces: a small Tu'whacca pulse (Ledger driver; the 7-day
    ; rite cooldown is the anti-farm cap) + a Book of Days beat (Chronicle).
    Manager.LedgerRuntime.AwardPiety(Manager.PDV_Tuwhacca, 0.5, "Took up the Remembering of Names")
    Manager.AppendBookOfDaysEntry("You remembered a name of the old line. The dead are kept in the telling.", Utility.GetCurrentGameTime() as Int, "substrate.act", "tu-whacca", False)
    Manager.SendPrismaToast("tuwhacca", "good", "Remembering of Names", "The observance settles into you.")
    Manager.Trace(2, "Redguard Remembering observance applied: " + index)
EndFunction

Function RemoveRedguardRememberSpells(Actor playerRef)
    Int i = 0
    while i < 4
        Spell obs = GetRedguardRememberSpell(i)
        if obs && playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
        endIf
        i += 1
    endWhile
EndFunction

Spell Function GetRedguardRememberSpell(Int index)
    if index == 0
        return Manager.PDV_SPEL_RedguardRemember_Blade
    elseIf index == 1
        return Manager.PDV_SPEL_RedguardRemember_Road
    elseIf index == 2
        return Manager.PDV_SPEL_RedguardRemember_Rest
    elseIf index == 3
        return Manager.PDV_SPEL_RedguardRemember_Harvest
    endIf
    return None
EndFunction

Function SyncRedguardRemembering(Actor playerRef)
    if !playerRef
        return
    endIf
    Int active = StorageUtil.GetIntValue(None, "PDV.RedRemember.Active")
    if active <= 0
        return
    endIf
    Spell obs = GetRedguardRememberSpell(active - 1)
    if !obs
        return
    endIf

    Int sectAtRite = StorageUtil.GetIntValue(None, "PDV.RedRemember.SectAtRite")
    Bool eligible = (GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD) && IsRedguardRememberingCoherent(sectAtRite)
    if eligible
        if !playerRef.HasSpell(obs)
            playerRef.AddSpell(obs, False)
            Manager.SendPrismaToast("tuwhacca", "good", "The old line settles", "Your observance returns.")
        endIf
    else
        if playerRef.HasSpell(obs)
            playerRef.RemoveSpell(obs)
            Manager.SendPrismaToast("tuwhacca", "warning", "The observance goes quiet", "The line you named it under has shifted.")
        endIf
    endIf
EndFunction

Bool Function IsRedguardRememberingCoherent(Int sectAtRite)
    if !Manager.PDV_RedguardSectTrack
        return false
    endIf
    if Manager.PDV_RedguardSectTrack.GetCurrentState() != sectAtRite
        return false
    endIf
    return true
EndFunction

Function HandleLekiHonorableDuel(String reason)
    if !Manager.PDV_Leki || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Leki)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.LekiHonorableDuel")
    if multiplier <= 0.0
        Manager.Trace(2, "Leki honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Leki, Manager.PDV_Leki.SIGNAL_HONORABLE_DUEL, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Leki, "Duel honored", "marks single combat honorably won.")
    Manager.Trace(2, "Leki honorable-duel routed (" + reason + ")")
EndFunction

Function HandleRedguardCrownTombRespect(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardCrownTombRespect")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_CROWN, multiplier, reason)
    AwardRedguardCrownSignal(multiplier, reason)
    Manager.Trace(2, "Redguard Crown tomb respect routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardForebearRoadPassage(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardForebearRoad")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_FOREBEAR, multiplier, reason)
    AwardRedguardForebearSignal(multiplier)
    Manager.Trace(2, "Redguard Forebear road passage routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahDeathDuty(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahDeathDuty")
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, reason)
    ApplyRedguardAshAbahDutyRewards(reason, multiplier)
    Manager.Trace(2, "Redguard AshAbah death duty routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAshAbahMajorBurden(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Actor victimActor = victimForm as Actor
    if !victimActor
        return
    endIf
    ActorBase victimBase = victimActor.GetLeveledActorBase()
    if !victimBase || !victimBase.IsUnique()
        return ; routine undead -- not a marked burden, no sect switch
    endIf

    String burdenReason = ""
    if eventType == 300 ; EVT_KILL_UNDEAD
        burdenReason = "redguard_deathduty_major"
    elseIf eventType == 2 && IsRedguardNamedNecromancerBurden(victimActor) ; EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
        burdenReason = "redguard_deathduty_major_necromancer"
    else
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahMajorBurden")
    if multiplier <= 0.0
        Manager.Trace(2, "Redguard Ash'abah major burden decayed out for today; no sect mark.")
        return
    endIf

    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Manager.Trace(2, "Redguard Ash'abah major burden fired: " + burdenReason + " marks sect entry (eventType=" + eventType + ").")
EndFunction

Function TrackRedguardAshAbahUndeadSiteVisit(Location currentLocation)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    if !currentLocation || !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(currentLocation)
        return
    endIf

    if currentLocation.IsCleared()
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahClearSiteArmed." + currentLocation.GetFormID(), 1)
EndFunction

Function HandleRedguardAshAbahUndeadSiteClear(Location clearedLocation)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    if !clearedLocation || !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites
        return
    endIf

    if !Manager.PDV_FLST_RedguardAshAbahUndeadClearSites.HasForm(clearedLocation)
        return
    endIf

    if !clearedLocation.IsCleared()
        return
    endIf

    String siteKey = "PDV.Redguard.AshAbahClearedSite." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, siteKey, 0) == 1
        return
    endIf

    String armKey = "PDV.Redguard.AshAbahClearSiteArmed." + clearedLocation.GetFormID()
    if StorageUtil.GetIntValue(None, armKey, 0) != 1
        return
    endIf

    StorageUtil.SetIntValue(None, siteKey, 1)
    StorageUtil.SetIntValue(None, armKey, 0)
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAshAbahUndeadSiteClear")
    String burdenReason = "redguard_ashabah_burden_undead_site_clear"
    RecordRedguardSectSignal(Manager.REDGUARD_SECT_ASHABAH, multiplier, burdenReason)
    ApplyRedguardAshAbahDutyRewards(burdenReason, multiplier)
    Manager.Trace(2, "Redguard Ash'abah undead-site clear fired for location " + clearedLocation.GetFormID() + " multiplier=" + multiplier)
EndFunction

Bool Function IsRedguardNamedNecromancerBurden(Actor victimActor)
    if !victimActor
        return False
    endIf

    if Manager.LedgerRuntime.NecromancerFaction && victimActor.IsInFaction(Manager.LedgerRuntime.NecromancerFaction)
        return True
    endIf

    if Manager.LedgerRuntime.WarlockFaction && victimActor.IsInFaction(Manager.LedgerRuntime.WarlockFaction)
        return True
    endIf

    return False
EndFunction

Function ApplyRedguardAshAbahDutyRewards(String reason, Float multiplier)
    AwardRedguardAshAbahSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    MarkRedguardAshAbahStigma(reason)
EndFunction

Function TryRedguardTuwhaccaDeathRiteHeal(String reason)
    if !Manager.PDV_Tuwhacca
        return
    endIf

    Int tuwhaccaTier = Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca)
    if tuwhaccaTier < Manager.LedgerRuntime.TIER_DEVOTED
        return
    endIf

    ; fix-plan 4.2: once-per-day gate moved onto the 06:00 devotional day.
    if Manager.LedgerRuntime.ReadZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay") == (Manager.LedgerRuntime.GetDevotionalDay() + 2)
        Manager.Trace(2, "Redguard Tu'whacca death-rite heal suppressed (already restored today).")
        return
    endIf
    Manager.LedgerRuntime.WriteZeroReservedDevotionalDayStamp("PDV.Redguard.TuwhaccaDeathRiteHealDay")

    Float deathRiteHeal = 30.0
    if tuwhaccaTier >= Manager.LedgerRuntime.TIER_CHAMPION
        deathRiteHeal = 50.0
    endIf
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", deathRiteHeal)
    Manager.Trace(2, "Redguard Tu'whacca death-rite heal fired reason=" + reason + " tier=" + tuwhaccaTier + " restore=" + deathRiteHeal)
EndFunction

Function MarkRedguardAshAbahStigma(String reason)
    Int before = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    Int stigma = before + 1
    if stigma > 5
        stigma = 5
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.AshAbahStigma", stigma)

    if before < 3 && stigma >= 3
        ShowRedguardNotification(None, "The tomb-smell never fully leaves you now; the clean keep their distance from the one who tends the unclean dead.")
    elseIf before < 1 && stigma >= 1
        ShowRedguardNotification(None, "The mark of the death-duty settles on you. Few will carry this burden, and they know it when they see you.")
    endIf
    Manager.Trace(2, "Redguard Ash'abah stigma marked reason=" + reason + " stigma=" + stigma + " (was " + before + ")")
EndFunction

String Function GetAshAbahStigmaLabel()
    Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
    if stigma >= 3
        return "hollow-eyed"
    elseIf stigma >= 1
        return "death-touched"
    endIf
    return "unmarked"
EndFunction

Function HandleRedguardFarShoresToken(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardFarShoresToken")
    EnsureRedguardSectInitialized()
    Int currentSect = Manager.PDV_RedguardSectTrack.GetCurrentState()
    Manager.PDV_RedguardSectTrack.RecordEvidenceDay(currentSect, reason)
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.FarShoresToken", multiplier)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf
    AwardRedguardFarShoresSignal(multiplier, reason)
    TryRedguardTuwhaccaDeathRiteHeal(reason)
    ShowRedguardNotification(Manager.PDV_Notif_Redguard_FarShoresToken_Activate, "You tend the Far Shores token and speak to Tu'whacca.")
    Manager.Trace(2, "Redguard Far Shores token routed with multiplier " + multiplier)
EndFunction

Function HandleRedguardAncestorSpine(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardAncestorSpine")
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    Manager.SurfaceP2BookReadNotice(reason, "The Yokudan dead", "The ancestor-line stands straighter in you.")
    Manager.Trace(2, "Redguard ancestor spine routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardAncestralRest(Float multiplier, String reason)
    RecordRedguardAncestorSpinePulse(multiplier, reason)
    Manager.Trace(2, "Redguard ancestral rest routed with multiplier " + multiplier)
EndFunction

Function RecordRedguardAncestorSpinePulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || !Manager.PDV_RedguardSectTrack || multiplier <= 0.0
        return
    endIf

    EnsureRedguardSectInitialized()
    Int currentSect = Manager.PDV_RedguardSectTrack.GetCurrentState()
    RecordRedguardSectSignal(currentSect, multiplier, reason)
    AwardRedguardAncestorSpinePietyPulse(multiplier, reason)
    ShowRedguardNotification(Manager.PDV_Notif_Redguard_AncestorSpine_Rest, "The ancestor-line steadies behind you.")
    Manager.RequestPanelRefresh()
EndFunction

Function HandleRedguardVampireReentryComplete(String reason)
    if !Manager.PDV_Tuwhacca || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Tuwhacca)
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_VAMPIRE_REENTRY, None, 1.0)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Tuwhacca, "The cycle restored", "marks the return through Tu'whacca after the curse.")
    Manager.Trace(1, "Tu'whacca vampire re-entry completed (" + reason + ")")
EndFunction

Function RecordRedguardSectSignal(Int sectValue, Float multiplier, String reason)
    if !Manager.PDV_RedguardSectTrack
        return
    endIf

    if sectValue < Manager.REDGUARD_SECT_CROWN || sectValue > Manager.REDGUARD_SECT_ASHABAH
        return
    endIf

    EnsureRedguardSectInitialized()
    Manager.PDV_RedguardSectTrack.RecordEvidenceDay(sectValue, reason)
    StorageUtil.AdjustFloatValue(None, GetRedguardSectWeightKey(sectValue), multiplier)
    StorageUtil.SetIntValue(None, "PDV.Redguard.LastSectSignal", sectValue)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastSectReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastSectSignalTime", Utility.GetCurrentGameTime())

    if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireReentryNeeded") == 1 && StorageUtil.GetIntValue(None, "PDV.Curse.State") != 2
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 0)
        HandleRedguardVampireReentryComplete(reason)
    endIf

    if multiplier <= 0.0
        return
    endIf

    if Manager.PDV_RedguardSectTrack.GetCurrentState() == sectValue
        MaybeShowRedguardChampionEntry(sectValue)
        SendPrismaSubstrateToast("sect", "act", "The Yokudan path was marked.", "sect", GetRedguardSectLabel())
        Manager.AppendBookOfDaysEntry("The Yokudan path was marked.", Utility.GetCurrentGameTime() as Int, "substrate.act", "sect", False)
        Manager.RequestPanelRefresh()
        return
    endIf

    ; LOCKED sect-switch rule: Crown <-> Forebear needs two sect-coded evidence days
    ; inside seven, then a three-day lock-in -- one tomb visit no longer rewrites
    ; sect identity. Ash'abah is entered only by a marked death/funerary burden
    ; (casual undead fighting is not enough), and left by a Crown/Forebear switch.
    Bool allowSwitch = False
    if sectValue == Manager.REDGUARD_SECT_ASHABAH
        allowSwitch = IsRedguardAshAbahBurden(reason)
    else
        allowSwitch = Manager.PDV_RedguardSectTrack.HasRecentEvidenceDays(sectValue, 2, 7) && !Manager.PDV_RedguardSectTrack.IsTransitionLockedOut()
    endIf

    if allowSwitch
        Manager.PDV_RedguardSectTrack.SetState(sectValue, reason)
        Manager.PDV_RedguardSectTrack.SetTransitionLockout(3.0, reason)
        ShowRedguardSectEntry(sectValue)
        MaybeShowRedguardChampionEntry(sectValue)
        Manager.SurfaceTransition("reorientation", GetRedguardSectLabel(), "shift", -1, "turning")
        Manager.SendPrismaShiftToast(GetRedguardSectLabel(), "", "sect")
        Manager.RequestPanelRefresh()
    endIf
EndFunction

Bool Function IsRedguardAshAbahBurden(String reason)
    ; Token-contains, not exact-match: a marked-burden emit site may append a source
    ; suffix (e.g. "redguard_deathduty_major_krosis"), and the exact-match form was the
    ; original silent gap (gate correct, token never produced). Suffix/omission-proof per
    ; the P2 book-notice fix.
    return PDV_DevotionRules.StringContainsToken(reason, "redguard_deathduty_major") || PDV_DevotionRules.StringContainsToken(reason, "redguard_ashabah_burden")
EndFunction

Function AwardRedguardCrownSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_CROWN_FORM, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "crown_tomb_" + reason)
EndFunction

Function AwardRedguardForebearSignal(Float multiplier)
    ; Road-passage is the Forebear lane's own beat: the Forebear sect substrate credit
    ; is recorded by the caller (RecordRedguardSectSignal). HoonDing's make-way no
    ; longer rides road-passage -- it now fires on curated BREAKTHROUGH kills
    ; (HandleHoonDingBreakthroughKill), so the old blunt weekly cap is retired. Leki's
    ; sword-singing remains the focused-patron beat on the road.
    if Manager.GetActiveDeity() == Manager.PDV_Leki && Manager.PDV_Leki
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Leki, Manager.PDV_Leki.SIGNAL_SWORD_SINGING, None, multiplier)
    endIf
EndFunction

Function HandleHoonDingBreakthroughKill(Form victimForm, Int eventType)
    if !IsRedguardOrigin() || !Manager.PDV_HoonDing
        return
    endIf
    if Manager.GetActiveDeity() != Manager.PDV_HoonDing
        return
    endIf

    Bool dragonKill = eventType == 302 ; EVT_KILL_DRAGON
    Bool listedBossKill = False
    if !dragonKill && Manager.PDV_FLST_HoonDing_BreakthroughBosses
        Actor victimActor = victimForm as Actor
        if victimActor
            ActorBase victimBase = victimActor.GetLeveledActorBase()
            if victimBase && Manager.PDV_FLST_HoonDing_BreakthroughBosses.HasForm(victimBase)
                listedBossKill = True
            endIf
        endIf
    endIf

    if !dragonKill && !listedBossKill
        return
    endIf

    String repeatKey = "PDV.Signal.HoonDingDragon"
    String traceLabel = "dragon"
    if listedBossKill
        repeatKey = "PDV.Signal.HoonDingBreakthroughBoss"
        traceLabel = "listed boss"
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier(repeatKey)
    if multiplier <= 0.0
        Manager.Trace(2, "HoonDing make-way (" + traceLabel + ") decayed out for today; no award.")
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_HoonDing, Manager.PDV_HoonDing.SIGNAL_MAKE_WAY, victimForm, multiplier)
    Manager.Trace(2, "HoonDing make-way fired: breakthrough " + traceLabel + " kill multiplier=" + multiplier)
EndFunction

Function AwardRedguardAshAbahSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "ashabah_death_duty_" + reason)
EndFunction

Function AwardRedguardFarShoresSignal(Float multiplier, String reason)
    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_FAR_SHORES_TOKEN, None, multiplier)
    endIf
    AwardRedguardAncestorSpinePietyPulse(multiplier, "far_shores_" + reason)
EndFunction

Function AwardRedguardAncestorSpinePietyPulse(Float multiplier, String reason)
    if !IsRedguardOrigin() || multiplier <= 0.0
        return
    endIf

    if Manager.PDV_Tuwhacca
        Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_ANCESTOR_SPINE, None, multiplier)
    endIf
    StorageUtil.AdjustFloatValue(None, "PDV.Redguard.AncestorSpine", multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.AncestorSpineSourceCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastAncestorSpineSourceReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastAncestorSpineSourceTime", Utility.GetCurrentGameTime())
EndFunction

Function EnsureRedguardSectInitialized()
    if !Manager.PDV_RedguardSectTrack
        return
    endIf

    if IsRedguardOrigin() && StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return
    endIf

    if Manager.PDV_RedguardSectTrack.GetCurrentState() < Manager.REDGUARD_SECT_CROWN
        Manager.PDV_RedguardSectTrack.SetState(Manager.REDGUARD_SECT_FOREBEAR, "redguard_default_forebear")
    endIf
EndFunction

Bool Function IsRedguardOrigin()
    return GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD
EndFunction

String Function GetRedguardSectWeightKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.Sect.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.Sect.AshAbah"
    endIf

    return "PDV.Redguard.Sect.Forebear"
EndFunction

String Function GetRedguardSectLabel()
    if !Manager.PDV_RedguardSectTrack
        return "Sect missing"
    endIf

    EnsureRedguardSectInitialized()
    return Manager.PDV_RedguardSectTrack.GetStateLabel()
EndFunction

Function ShowRedguardSectEntry(Int sectValue)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    String shownKey = GetRedguardSectEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == Manager.REDGUARD_SECT_CROWN
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_Crown_Entry, "You hold the Crown way: orthodoxy kept, the old inheritance intact.")
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_Forebear_Entry, "You hold the Forebear way: Redguard identity carried among outsiders.")
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        ShowRedguardNotification(Manager.PDV_Notif_Redguard_Sect_AshAbah_Entry, "You take up the Ash'abah duty: the unclean work others will not touch.")
    endIf

    StorageUtil.SetIntValue(None, shownKey, 1)
EndFunction

String Function GetRedguardSectEntryShownKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.SectEntryShown.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.SectEntryShown.Forebear"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.SectEntryShown.AshAbah"
    endIf

    return ""
EndFunction

Function MaybeShowRedguardChampionEntry(Int sectValue)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    String shownKey = GetRedguardChampionEntryShownKey(sectValue)
    if shownKey == "" || StorageUtil.GetIntValue(None, shownKey) == 1
        return
    endIf

    if sectValue == Manager.REDGUARD_SECT_CROWN
        if Manager.PDV_Tuwhacca && Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_Crown, "The Crown way has become more than memory. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Crown way is more than memory in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Crown way, made public.", "More than memory now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        if Manager.PDV_HoonDing && Manager.LedgerRuntime.GetTier(Manager.PDV_HoonDing) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_Forebear, "The Forebear way has become more than adaptation. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Forebear way is more than adaptation in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Forebear way, made public.", "More than adaptation now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        if Manager.PDV_Tuwhacca && Manager.LedgerRuntime.GetTier(Manager.PDV_Tuwhacca) >= Manager.LedgerRuntime.TIER_CHAMPION
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_ChampionEntry_AshAbah, "The Ash'abah duty has become more than necessity. It is a public shape of your devotion.", False)
            Manager.AppendBookOfDaysEntry("The Ash'abah duty is more than necessity in you now. It has become a public shape of your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "sect", False, 3)
            Manager.SendPrismaShiftToast("The Ash'abah duty, made public.", "More than necessity now -- a public shape of your devotion.", "sect")
            StorageUtil.SetIntValue(None, shownKey, 1)
        endIf
    endIf
EndFunction

String Function GetRedguardChampionEntryShownKey(Int sectValue)
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "PDV.Redguard.ChampionEntryShown.Crown"
    elseIf sectValue == Manager.REDGUARD_SECT_FOREBEAR
        return "PDV.Redguard.ChampionEntryShown.Forebear"
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        return "PDV.Redguard.ChampionEntryShown.AshAbah"
    endIf

    return ""
EndFunction

Function SyncRedguardRewards(Actor playerRef)
    if !playerRef
        return
    endIf

    Bool isRedguard = GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD
    Int sectValue = GetActiveRedguardSpineSect()
    SyncRedguardSpineBoon(playerRef, isRedguard, sectValue)
    ; Option 2 (2026-07-16): the generic ancestor FLOOR (AncestorSpine_T1, "Ancestors' Regard -
    ; Observant") is descoped -- the sect spine (SyncRedguardSpineBoon) is the always-on ancestor
    ; layer. Broad progression is KEPT (owner ruling 2026-07-16): AncestorSpine_T2 remains the
    ; broad-worship Faithful reward, so a broad Redguard at 6+ ancestor-spine sources gains
    ; "Ancestors' Regard - Faithful" on top of the sect spine. Focused patrons stay broad-state gated
    ; out of T2, so they carry only their sect spine.
    Bool broadFaithful = isRedguard && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_BROAD && StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") >= 6
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_AncestorSpine_T2, broadFaithful, "Redguard AncestorSpine T2")

    SyncRedguardRewardFamily(playerRef, Manager.PDV_Tuwhacca, Manager.PDV_Bless_Redguard_Tuwhacca_T1, Manager.PDV_Bless_Redguard_Tuwhacca_T2, Manager.PDV_Bless_Redguard_Tuwhacca_T3, "Tuwhacca")
    SyncRedguardRewardFamily(playerRef, Manager.PDV_HoonDing, Manager.PDV_Bless_Redguard_HoonDing_T1, Manager.PDV_Bless_Redguard_HoonDing_T2, Manager.PDV_Bless_Redguard_HoonDing_T3, "HoonDing")
    SyncRedguardRewardFamily(playerRef, Manager.PDV_Leki, Manager.PDV_Bless_Redguard_Leki_T1, Manager.PDV_Bless_Redguard_Leki_T2, Manager.PDV_Bless_Redguard_Leki_T3, "Leki")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_FarShoresToken, isRedguard && StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken") > 0.0, "Redguard Far Shores Token")
    if isRedguard && Manager.PDV_RedguardSectTrack
        MaybeShowRedguardChampionEntry(Manager.PDV_RedguardSectTrack.GetCurrentState())
    endIf
EndFunction

Function SyncRedguardSpineBoon(Actor playerRef, Bool isRedguard, Int sectValue)
    if !playerRef
        return
    endIf

    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_Crown, isRedguard && sectValue == Manager.REDGUARD_SECT_CROWN, "Redguard Spine Crown")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_Forebear, isRedguard && sectValue == Manager.REDGUARD_SECT_FOREBEAR, "Redguard Spine Forebear")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, Manager.PDV_Bless_Redguard_Spine_AshAbah, isRedguard && sectValue == Manager.REDGUARD_SECT_ASHABAH, "Redguard Spine AshAbah")
EndFunction

Int Function GetActiveRedguardSpineSect()
    if Manager.PDV_RedguardSectTrack
        EnsureRedguardSectInitialized()
        Int sectValue = Manager.PDV_RedguardSectTrack.GetCurrentState()
        if sectValue >= Manager.REDGUARD_SECT_CROWN && sectValue <= Manager.REDGUARD_SECT_ASHABAH
            return sectValue
        endIf
    endIf

    return Manager.REDGUARD_SECT_FOREBEAR
EndFunction

Function SyncRedguardRewardFamily(Actor playerRef, PDV_DeityBase deity, Spell t1, Spell t2, Spell t3, String label)
    Bool isActive = GetPlayerOriginRaceIndex() == Manager.ORIGIN_REDGUARD && Manager.LedgerRuntime.GetPatronState() == Manager.LedgerRuntime.PATRON_STATE_ACTIVE && Manager.GetActiveDeity() == deity
    Int activeTier = Manager.LedgerRuntime.TIER_NONE
    if isActive && deity
        activeTier = Manager.LedgerRuntime.GetTier(deity)
    endIf

    Bool hadChampionSpell = Manager.LedgerRuntime.HasRewardSpell(playerRef, t3)
    Bool wantsChampionSpell = isActive && activeTier >= Manager.LedgerRuntime.TIER_CHAMPION
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t1, isActive && activeTier == Manager.LedgerRuntime.TIER_SEEKER, "Redguard " + label + " T1")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t2, isActive && activeTier == Manager.LedgerRuntime.TIER_DEVOTED, "Redguard " + label + " T2")
    Manager.LedgerRuntime.SyncRaceRewardSpell(playerRef, t3, wantsChampionSpell, "Redguard " + label + " T3")
    Manager.LedgerRuntime.MaybeShowChampionRewardPresentation(playerRef, t3, hadChampionSpell, wantsChampionSpell, deity, "Redguard " + label)
EndFunction

Bool Function IsRedguardAncestorDistanceNeglected()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return False
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure") > 0
        return True
    endIf

    Float lastSource = StorageUtil.GetFloatValue(None, "PDV.Redguard.LastSectSignalTime")
    if lastSource <= 0.0
        return False
    endIf

    return (Utility.GetCurrentGameTime() - lastSource) > 5.0
EndFunction

Function SyncRedguardNeglectSpell(Bool shouldBeActive)
    Actor playerRef = Game.GetPlayer()
    if !playerRef || !Manager.PDV_SPEL_Neglect_Redguard
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
        return
    endIf

    if shouldBeActive
        ; Pass 5 rubric sweep (carried from Pass 2). This asked the engine the same
        ; question twice in consecutive lines -- wasActive was computed and then the very
        ; next line re-ran HasSpell on the same spell and the same actor. Reuse the answer.
        Bool wasActive = playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Redguard)
        if !wasActive
            playerRef.AddSpell(Manager.PDV_SPEL_Neglect_Redguard, False)
        endIf
        if !wasActive
            EmitRedguardDeathDutyAbandonmentMinus("redguard_ancestor_distance_neglect")
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 1)
    else
        if playerRef.HasSpell(Manager.PDV_SPEL_Neglect_Redguard)
            playerRef.RemoveSpell(Manager.PDV_SPEL_Neglect_Redguard)
        endIf
        StorageUtil.SetIntValue(None, "PDV.Neglect.RedguardSpellActive", 0)
    endIf
EndFunction

Function EmitRedguardDeathDutyAbandonmentMinus(String reason)
    if !IsRedguardOrigin() || !Manager.PDV_Tuwhacca
        return
    endIf

    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.RedguardDeathDutyAbandonment")
    if multiplier <= 0.0
        return
    endIf

    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Tuwhacca, Manager.PDV_Tuwhacca.SIGNAL_DEATH_DUTY_ABANDONMENT, None, multiplier)
    StorageUtil.AdjustIntValue(None, "PDV.Redguard.DeathDutyAbandonmentCount", 1)
    StorageUtil.SetStringValue(None, "PDV.Redguard.LastDeathDutyAbandonmentReason", reason)
    StorageUtil.SetFloatValue(None, "PDV.Redguard.LastDeathDutyAbandonmentTime", Utility.GetCurrentGameTime())
    Manager.Trace(2, "Redguard death-duty abandonment routed: " + reason + " multiplier=" + multiplier)
EndFunction

Message Function GetRedguardFormalCommitmentOfferMessage(PDV_DeityBase deity)
    if deity == Manager.PDV_Tuwhacca
        return Manager.PDV_Msg_Redguard_Tuwhacca_Offer
    elseIf deity == Manager.PDV_Leki
        return Manager.PDV_Msg_Redguard_Leki_Offer
    elseIf deity == Manager.PDV_HoonDing
        return Manager.PDV_Msg_Redguard_HoonDing_Offer
    endIf

    return None
EndFunction

Bool Function IsRedguardOfferEligibleDeity(PDV_DeityBase deity)
    if !deity
        return False
    endIf

    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return False
    endIf

    return deity == Manager.PDV_Tuwhacca || deity == Manager.PDV_HoonDing || deity == Manager.PDV_Leki
EndFunction

Function ApplyRedguardCurseHandlers(Int oldState, Int newState, String reason)
    Bool suppressModal = ShouldSuppressRedguardCurseModal(reason)
    if newState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 2)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireScar", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_VampireOnset, "The vampire curse interrupts Tu'whacca's cycle until cure and re-entry.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 1)
        endIf
    elseIf newState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_WerewolfOnset, "The beast blood strains the route to proper mortality.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 1)
        endIf
    elseIf oldState == 2
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireReentryNeeded", 1)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_VampireCured_TuwhaccaReEntry, "The thirst is gone, but the ancestors' protection stays withheld until you take up the death-duty and re-enter Tu'whacca's cycle.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.VampireCureFeedbackShown", 1)
        endIf
    elseIf oldState == 1
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
        if StorageUtil.GetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown") != 1
            ShowRedguardMessage(Manager.PDV_Msg_Redguard_CurseState_WerewolfCured, "The beast blood is quiet. The mortal road steadies again.", suppressModal)
            StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfCureFeedbackShown", 1)
        endIf
    else
        StorageUtil.SetIntValue(None, "PDV.Curse.Redguard.CyclePressure", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.VampireFeedbackShown", 0)
        StorageUtil.SetIntValue(None, "PDV.Redguard.WerewolfFeedbackShown", 0)
    endIf

    StorageUtil.SetStringValue(None, "PDV.Curse.Redguard.LastReason", reason)
EndFunction

Bool Function ShouldSuppressRedguardCurseModal(String reason)
    return reason == "mcm_force_none" || reason == "mcm_force_werewolf" || reason == "mcm_force_vampire"
EndFunction

Function ShowRedguardNotification(Message messageRecord, String fallbackText)
    if !Manager.NotificationsEnabled()
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Manager.SendPrismaToast("tuwhacca", "neutral", "", fallbackText)
EndFunction

Function ShowRedguardMessage(Message messageRecord, String fallbackText, Bool suppressModal)
    if Manager.GetSuppressCurseTransitionOutputs()
        return
    endIf

    ; Past this point the function always emits something (toast, modal, or fallback box),
    ; so the generic curse toast can stand aside for this transition.
    Manager.SetRaceCurseSurfaceShown(True)

    if suppressModal
        Manager.SendPrismaToast("tuwhacca", "warning", "", fallbackText)
        return
    endIf

    if messageRecord
        messageRecord.Show()
        return
    endIf

    Debug.MessageBox(fallbackText)
EndFunction

Function ApplyRedguardInitialChoice(Int sectValue, String reason)
    Manager.BeginRaceSetupQuietPresentation(reason)
    if Manager.PDV_RedguardSectTrack
        Int normalized = PDV_DevotionRules.ClampInt(sectValue, Manager.REDGUARD_SECT_CROWN, Manager.REDGUARD_SECT_ASHABAH)
        Manager.PDV_RedguardSectTrack.SetState(normalized, reason)
        Manager.AppendBookOfDaysEntry(Manager.BuildStartupRoadJournalLine(GetRedguardSectLabel()), Utility.GetCurrentGameTime() as Int, "reorientation", "sect", True, 3, "", True)
        ShowRedguardSectEntry(normalized)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Redguard.SetupComplete", 1)
    Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    Manager.RequestPanelRefresh()
    Manager.EndRaceSetupQuietPresentation()
EndFunction

String Function GetRedguardMedallionEntriesJson()
    String entries = Manager.PendingMedallionEntry("satakal", "Satakal", "god", "satakal", "Worldskin, cycle, and cosmic turning.")
    entries = entries + "," + Manager.PendingMedallionEntry("ruptga", "Ruptga", "god", "ruptga", "Tall Papa, ancestry, and guidance.")
    entries = entries + "," + Manager.RosterMedallionEntry("tuwhacca", "Tu'whacca", "god", "tu-whacca", Manager.PDV_Tuwhacca, "Death, passage, and the proper road.")
    entries = entries + "," + Manager.PendingMedallionEntry("tava", "Tava", "god", "tava", "Wind, sailors, and safe passage.")
    entries = entries + "," + Manager.RosterMedallionEntry("leki", "Leki", "god", "leki", Manager.PDV_Leki, "Sword-skill, discipline, and grace.")
    entries = entries + "," + Manager.PendingMedallionEntry("onsi", "Onsi", "god", "onsi", "The blade, craft, and warrior making.")
    entries = entries + "," + Manager.RosterMedallionEntry("hoon-ding", "HoonDing", "god", "hoon-ding", Manager.PDV_HoonDing, "Make-way spirit and impossible survival.")
    return entries
EndFunction

String Function GetRedguardSurveyText()
    if !Manager.PDV_RedguardSectTrack
        return "The Far Shores are named, but your Redguard sect is not yet readable here."
    endIf

    String text = GetRedguardSurveySectText()
    if StorageUtil.GetIntValue(None, "PDV.Redguard.AncestorSpineSourceCount") > 0
        text = text + " You have read the words of the ancestors, and the dead are nearer for it."
    endIf
    Float farShoresWeight = StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")
    if farShoresWeight > 0.0
        text = text + " The Far Shores token has been tended lately, and Tu'whacca holds the way open."
    endIf

    Int cyclePressure = StorageUtil.GetIntValue(None, "PDV.Curse.Redguard.CyclePressure")
    if cyclePressure == 2
        text = text + " The vampire curse has set you outside the cycle, and the Far Shores stay shut until you cure it and return through Tu'whacca."
    elseIf cyclePressure == 1
        text = text + " The beast strains your road to a proper death, but the ancestors only watch the closer for it."
    endIf

    return text
EndFunction

String Function GetRedguardSurveySectText()
    Int sectValue = Manager.REDGUARD_SECT_FOREBEAR
    if Manager.PDV_RedguardSectTrack
        sectValue = Manager.PDV_RedguardSectTrack.GetCurrentState()
    endIf

    String standing = Manager.GetCurrentStandingBand()
    if sectValue == Manager.REDGUARD_SECT_CROWN
        return "You keep the Crown way: orthodox Yokudan practice carried intact in exile. Standing: " + standing + ". The ancestors are strong at your back."
    elseIf sectValue == Manager.REDGUARD_SECT_ASHABAH
        String ashText = "You keep the Ash'abah duty: the unclean dead are your charge. Standing: " + standing + ". Tu'whacca honors the burden few will."
        ashText = ashText + " The duty hardens you against death and plague, but it cools your welcome among the living (Speech -5)."
        Int stigma = StorageUtil.GetIntValue(None, "PDV.Redguard.AshAbahStigma", 0)
        if stigma >= 3
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the clean turn their faces, and the living keep their distance from the death-handler."
        elseIf stigma >= 1
            ashText = ashText + " You are " + GetAshAbahStigmaLabel() + ": the mark of the duty is on you, and the squeamish step wide."
        endIf
        return ashText
    endIf

    return "You keep the Forebear way: Redguard identity lived among outsiders. Standing: " + standing + ". The road and the contract are your proving ground."
EndFunction

String Function GetRedguardSummary()
    if !Manager.PDV_RedguardSectTrack
        return "missing"
    endIf

    return "sect=" + GetRedguardSectLabel() + ";crown=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Crown")) + ";forebear=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.Forebear")) + ";ashabah=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.Sect.AshAbah")) + ";farShores=" + PDV_DevotionRules.FormatTwoDecimals(StorageUtil.GetFloatValue(None, "PDV.Redguard.FarShoresToken")) + ";last=" + StorageUtil.GetStringValue(None, "PDV.Redguard.LastSectReason")
EndFunction

Function ReconcileRedguardSpineRewardAfterLoad()
    if GetPlayerOriginRaceIndex() != Manager.ORIGIN_REDGUARD
        return
    endIf
    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1 && StorageUtil.GetIntValue(None, "PDV.Redguard.SetupComplete") != 1
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    SyncRedguardSpineBoon(playerRef, True, GetActiveRedguardSpineSect())
    Manager.RequestPanelRefresh()
    Manager.Trace(2, "Redguard spine reward reconciled after player load.")
EndFunction

; ===========================================================================
; SECTION 2 -- adapter dispatch. New code; every body above is untouched.
;
; The corrected interface (ADR "Corrections after the pilot", 2026-08-19) carries
; the caller-composed String reason through HandleContextualSignal, so the earlier
; synthesized "signal_" + signalId placeholder is gone: every Redguard Handle* body
; now receives the caller's own reason verbatim ("eventbus_" + eventType,
; "eventbus_p2_redguard_spine_" + sourceId, and so on). Reasons are player-visible
; in the Ledger, so this is the provenance-preserving form.
;
; Location routing. HandleLocationChange(Form newLocation) now carries the caller's
; akNewLocation, so the NEW-location verb TrackRedguardAshAbahUndeadSiteVisit rides
; it. The other two location call sites cannot: PDV_ActionRouter passes akOldLocation
; to HandleRedguardAshAbahUndeadSiteClear on a location change, and the kill path
; (RouteKill) passes the kill's own akLocation to BOTH verbs -- neither is a location
; change. Those keep their signal ids on contextForm so no call site loses its
; argument.
; ===========================================================================

; -- Lifecycle --

Function ApplyInitialChoice(Int choiceValue, String reason)
    ApplyRedguardInitialChoice(choiceValue, reason)
EndFunction

Function ApplyCurseHandlers(Int oldState, Int newState, String reason)
    ApplyRedguardCurseHandlers(oldState, newState, reason)
EndFunction

; -- State --

String Function GetOriginStateLabel()
    return GetRedguardSectLabel()
EndFunction

Int Function GetOriginStateValue()
    return GetActiveRedguardSpineSect()
EndFunction

String Function GetOriginSummary()
    return GetRedguardSummary()
EndFunction

String Function GetSurveyFragment()
    return GetRedguardSurveyText()
EndFunction

Bool Function IsRaceLaneNeglected()
    return IsRedguardAncestorDistanceNeglected()
EndFunction

String Function GetOriginDetailLabel(String detailKey)
    if detailKey == "sect"
        return GetRedguardSectLabel()
    elseIf detailKey == "ashabah-stigma"
        return GetAshAbahStigmaLabel()
    elseIf detailKey == "survey-sect"
        return GetRedguardSurveySectText()
    elseIf detailKey == "summary"
        return GetRedguardSummary()
    elseIf detailKey == "medallion-entries"
        return GetRedguardMedallionEntriesJson()
    endIf

    return ""
EndFunction

Int Function GetOriginDetailValue(String detailKey)
    if detailKey == "sect"
        return GetActiveRedguardSpineSect()
    elseIf detailKey == "is-origin"
        if IsRedguardOrigin()
            return 1
        endIf
        return 0
    elseIf detailKey == "ancestor-distance-neglected"
        if IsRedguardAncestorDistanceNeglected()
            return 1
        endIf
        return 0
    endIf

    return 0
EndFunction

; -- Signals --

Bool Function HandleContextualSignal(String signalId, String reason = "", Form contextForm = None, Float magnitude = 0.0)
    if signalId == "crown-tomb-respect"
        HandleRedguardCrownTombRespect(reason)
        return True
    elseIf signalId == "forebear-road-passage"
        HandleRedguardForebearRoadPassage(reason)
        return True
    elseIf signalId == "ashabah-death-duty"
        HandleRedguardAshAbahDeathDuty(reason)
        return True
    elseIf signalId == "far-shores-token"
        HandleRedguardFarShoresToken(reason)
        return True
    elseIf signalId == "ancestor-spine"
        HandleRedguardAncestorSpine(reason)
        return True
    elseIf signalId == "leki-honorable-duel"
        HandleLekiHonorableDuel(reason)
        return True
    elseIf signalId == "vampire-reentry-complete"
        HandleRedguardVampireReentryComplete(reason)
        return True
    elseIf signalId == "hoonding-breakthrough-kill"
        HandleHoonDingBreakthroughKill(contextForm, magnitude as Int)
        return True
    elseIf signalId == "ashabah-major-burden"
        HandleRedguardAshAbahMajorBurden(contextForm, magnitude as Int)
        return True
    elseIf signalId == "ashabah-undead-site-visit"
        TrackRedguardAshAbahUndeadSiteVisit(contextForm as Location)
        return True
    elseIf signalId == "ashabah-undead-site-clear"
        HandleRedguardAshAbahUndeadSiteClear(contextForm as Location)
        return True
    elseIf signalId == "sleep"
        HandleRedguardSleepEvents(contextForm as Actor, reason)
        return True
    endIf

    return False
EndFunction

; The location-change entry point proper: the caller's akNewLocation, not a re-sample.
Function HandleLocationChange(Form newLocation = None)
    TrackRedguardAshAbahUndeadSiteVisit(newLocation as Location)
EndFunction

; -- Upkeep --

Function SyncRaceRewards()
    SyncRedguardRewards(Game.GetPlayer())
EndFunction

Function SyncNeglectSpells()
    SyncRedguardNeglectSpell(IsRedguardAncestorDistanceNeglected())
EndFunction

; -- Patron and offers --

Bool Function IsOfferEligibleDeity(PDV_DeityBase deity)
    return IsRedguardOfferEligibleDeity(deity)
EndFunction

Message Function GetFormalCommitmentOfferMessage(PDV_DeityBase deity)
    return GetRedguardFormalCommitmentOfferMessage(deity)
EndFunction

; -- Presentation --

Function ShowOriginNotification(Message messageRecord, String fallbackText)
    ShowRedguardNotification(messageRecord, fallbackText)
EndFunction

Function ShowOriginMessage(Message messageRecord, String fallbackText, Bool suppressModal = False)
    ShowRedguardMessage(messageRecord, fallbackText, suppressModal)
EndFunction

; -- Not overridden, and why --
;
; HandleContextualQuery: no Redguard lane entry point is a value-returning sibling of
; a signal. The Bool-returning lane functions (TryRedguardRemembering,
; IsRedguardAshAbahBurden, IsRedguardRememberingCoherent) are internal helpers with no
; caller outside ORIGIN, so there is nothing to route through the value channel.
;
; EvaluateAtDawn: the Redguard lane has no dawn body of its own; SyncRedguardRemembering
; is driven from PDV_DevotionLedger's dawn pass through the named call and is a
; central-removal-pass item, not a dawn override.
