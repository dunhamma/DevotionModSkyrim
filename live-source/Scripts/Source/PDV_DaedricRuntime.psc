Scriptname PDV_DaedricRuntime extends PDV_GainModifierProvider

; Daedric runtime, extracted from PDV__ManagerQuest for the 2.0 rebuild (DAEDRIC
; module). Behavior parity: bodies are the manager originals; the only edit inside a
; moved body is qualifying a bare manager-member reference through the Manager
; backref (Manager.X), plus the one write-shared manager script var (_dawnHadActivity)
; routed through the existing Manager accessors. Daedric-owned script vars (referenced
; only by moved bodies) moved here verbatim and stay bare. Property declarations stayed
; on the manager and are reached via Manager.<prop>, matching the ORIGIN precedent.
; INERT until the host QUST exists, Manager is filled, and CK wiring lands.

PDV__ManagerQuest Property Manager Auto

; -- Gain provider. DAEDRIC owns the stigma factor, which scales awards AND decay.
Float Function GetProviderGainMultiplier(PDV_DeityBase deity, Int phase)
    if phase == Manager.PHASE_PER_EVENT || phase == Manager.PHASE_DECAY
        return GetDaedricStigmaGainMultiplier(deity)
    endIf

    return 1.0
EndFunction

; --- Daedric-owned script variables (moved verbatim; referenced only by moved bodies) ---
PDV_DaedricPathBase _kidNamiraPath = None
PDV_DaedricPathBase _kidSanguinePath = None
PDV_DaedricPathBase _pendingDaedricMilestonePath = None
Int _pendingDaedricMilestoneOldTier = 0
Int _pendingDaedricMilestoneNewTier = 0
String _pendingDaedricMilestoneReason = ""
Bool _pendingDaedricMilestoneReplayChampionOffer = False
Int _pendingDaedricMilestoneDelayTicks = 0

Int Function RepairDaedricPathRuntimeNames()
    if !Manager.PDV_FLST_DaedricPaths_All
        return 0
    endIf
    Int repaired = 0
    Int pathCount = Manager.PDV_FLST_DaedricPaths_All.GetSize()
    Int pathIndex = 0
    while pathIndex < pathCount
        PDV_DaedricPathBase namedPath = Manager.PDV_FLST_DaedricPaths_All.GetAt(pathIndex) as PDV_DaedricPathBase
        if namedPath
            String canonicalPathName = CanonicalDaedricPathName(namedPath)
            if canonicalPathName != ""
                repaired += Manager.LedgerRuntime.RepairDeityRuntimeName(namedPath, canonicalPathName)
            endIf
        endIf
        pathIndex += 1
    endWhile
    return repaired
EndFunction

; Path identity via concrete-script downcast: immune to DeityName drift (the thing
; being repaired) and to FormList order drift. Canonical strings mirror
; PDV_DaedricPrinceRecordContracts.json displayName values exactly.
String Function CanonicalDaedricPathName(PDV_DaedricPathBase namedPath)
    if namedPath as PDV_DaedricPath_Azura
        return "Azura"
    elseIf namedPath as PDV_DaedricPath_Boethiah
        return "Boethiah"
    elseIf namedPath as PDV_DaedricPath_Dagon
        return "Mehrunes Dagon"
    elseIf namedPath as PDV_DaedricPath_Hircine
        return "Hircine"
    elseIf namedPath as PDV_DaedricPath_Malacath
        return "Malacath"
    elseIf namedPath as PDV_DaedricPath_Mephala
        return "Mephala"
    elseIf namedPath as PDV_DaedricPath_Meridia
        return "Meridia"
    elseIf namedPath as PDV_DaedricPath_Molag
        return "Molag Bal"
    elseIf namedPath as PDV_DaedricPath_Mora
        return "Hermaeus Mora"
    elseIf namedPath as PDV_DaedricPath_Namira
        return "Namira"
    elseIf namedPath as PDV_DaedricPath_Nocturnal
        return "Nocturnal"
    elseIf namedPath as PDV_DaedricPath_Peryite
        return "Peryite"
    elseIf namedPath as PDV_DaedricPath_Sanguine
        return "Sanguine"
    elseIf namedPath as PDV_DaedricPath_Sheo
        return "Sheogorath"
    elseIf namedPath as PDV_DaedricPath_Vaermina
        return "Vaermina"
    elseIf namedPath as PDV_DaedricPath_Vile
        return "Clavicus Vile"
    endIf
    return ""
EndFunction

; Namira lifesteal heal-on-feed. The Namira boon's "Namira sustains you" fantasy was
; authored as a swallowed always-on HealRateMult (felt as nothing under Requiem). It
; is re-themed to a flat, Requiem-proof restore fired when the Namira-pathed faithful
; feeds on the dead, scaled by Namira tier, with a daily soft-decay so repeated
; feeding in one day yields diminishing restoration (anti-farm). Magnitudes
; PROVISIONAL -- tune in-game (memory: requiem-proof-heal-flat-restore-not-rate).
Function TryNamiraFeedHeal()
    PDV_DeityBase namira = Manager.GetQuestReactionDeity("Namira")
    if !namira
        return
    endIf

    Int namiraTier = Manager.LedgerRuntime.GetTier(namira)
    if namiraTier < Manager.LedgerRuntime.TIER_SEEKER
        return
    endIf

    Float feedMultiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.NamiraFeedHeal")
    if feedMultiplier <= 0.0
        Manager.Trace(2, "Namira feed-heal decayed out for today; no restore.")
        return
    endIf

    Float feedHeal = 20.0
    if namiraTier >= Manager.LedgerRuntime.TIER_CHAMPION
        feedHeal = 40.0
    elseIf namiraTier >= Manager.LedgerRuntime.TIER_DEVOTED
        feedHeal = 30.0
    endIf
    feedHeal = feedHeal * feedMultiplier
    Float feedStamina = feedHeal
    Actor playerRef = Game.GetPlayer()
    playerRef.RestoreActorValue("Health", feedHeal)
    playerRef.RestoreActorValue("Stamina", feedStamina)
    Manager.Trace(2, "Namira feed-heal fired tier=" + namiraTier + " mult=" + feedMultiplier + " health=" + feedHeal + " stamina=" + feedStamina)
EndFunction

Function HandleDaedricPrinceSignal(Int pathIndex, String sourceId)
    PDV_DaedricPathBase path = GetDaedricPathAtListIndex(pathIndex)
    if !path
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric live signal skipped: no path at index " + pathIndex)
        endIf
        return
    endIf

    if IsBlockedDaedricSourceId(sourceId)
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric live signal ignored generic source for " + path.DeityName + ": " + sourceId)
        endIf
        return
    endIf

    ; Hard daily cap: one credited live signal per path per source per devotional day.
    ; Distinct key namespace (PDV.Daedric.Signal.<pathIndex>.<sourceId>) from any soft-cap
    ; prefix so the .Day book-keeping never collides.
    if !Manager.ConsumeOncePerDaySignal("PDV.Daedric.Signal." + pathIndex + "." + sourceId)
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric live signal daily-capped for " + path.DeityName + ": " + sourceId)
        endIf
        return
    endIf
    ; Feed the offer recency gate (HasRecentCommitmentSignalDays) so the formal Prince
    ; offer can fire once enough distinct signal-days accrue.
    Manager.LedgerRuntime.RecordCommitmentSignalDay(path)

    Int tierBefore = path.GetStoredTier()
    path.AddCommitmentSignal(sourceId)
    path.AdjustStoredPiety(10.0, sourceId)
    Manager.OriginRuntime.RefreshArgonianDominationPressureForPath(path, "daedric_" + sourceId)
    Int tierAfter = path.GetStoredTier()
    ; Hard switch: re-engaging an already-committed (but dormant) Prince makes it the
    ; single active pact again, even without a tier change. OnTierChange covers
    ; first-commit and tier-ups; this covers switch-back. A sub-threshold (tier 0)
    ; Prince never steals the active pact from a committed one.
    if tierAfter > 0 && !path.IsActiveDaedricPact() && path.HasDaedricPactConsent()
        ; Activation itself is the exclusivity seam (handled in MakeActiveDaedricPact ->
        ; PendingActivation -> ProcessPendingDaedricActivation), so this funnel does not
        ; sever the patron directly: a tier-up already auto-activated via OnTierChange
        ; before this line. By design, a deliberately-abandoned (dormant, tier>0, not
        ; active) Prince re-seats ONLY via a tier crossing or this curated signal --
        ; same-tier ambient acts / shrine prayer do NOT re-seat it (RecomputeStoredTier's
        ; no-change branch strips, not activates). Every route that DOES re-activate
        ; passes through MakeActiveDaedricPact, which enforces exclusivity.
        path.MakeActiveDaedricPact()
    endIf
    ; Player-facing fiction is owned by the path's authored MESG records, fired from
    ; PDV_DaedricPathBase.OnTierChange (tier entry) and ShowCommitmentBeat (gate open).
    ; Sub-threshold signals stay silent here, and the raw sourceId never reaches the
    ; player. Only surface the Prisma UI instrument on an actual tier gain.
    ; A tier-up grants this Prince's boon and its paired price; surface both so the
    ; gain/cost beat lands for every Prince organically, not just Hircine's bespoke
    ; hunt rite. The MCM debug page already surfaces all phases per selected Prince.
    ShowDaedricMilestonePresentation(path, tierBefore, tierAfter, False)
    ; Pre-pact "taken notice" surfacing is owned by the source-agnostic path-piety seam
    ; (PDV_DaedricPathBase.UpdatePrePactNoticeState queues the crossing;
    ; ProcessPendingDaedricPrePactNotices drains it), so a Prince chronicles the first
    ; time it crosses the notice threshold from ANY piety source -- not only live signals
    ; -- and never below it. A tier gain is a commitment, surfaced above.
    Manager.RequestPanelRefresh()

    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric live signal: " + path.DeityName + " index " + pathIndex + " source " + sourceId)
    endIf
EndFunction

Function HandleDaedricShrinePrayer(Int pathIndex, String sourceId)
    ; Casual once/day shrine prayer: a flat +2 to the Prince's piety, WITHOUT the
    ; commitment/tier/active-pact machinery of HandleDaedricPrinceSignal. The
    ; once-per-day gate lives on the activator (OncePerDayKey).
    PDV_DaedricPathBase path = GetDaedricPathAtListIndex(pathIndex)
    if !path
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric shrine prayer skipped: no path at index " + pathIndex)
        endIf
        return
    endIf
    path.AdjustStoredPiety(2.0, sourceId)
    Manager.RequestPanelRefresh()

    ; Player-facing confirmation. The shrine prayer is daily-repeatable and a Prince
    ; can be uncommitted (so it never surfaces in the panel), so without this the
    ; action is invisible. Top-left line always fires; Prisma gets an explicit
    ; repeatable Daedric toast. The diegetic D1 dispatch remains separate for
    ; screen/sound/journal work and can stay disabled without hiding the toast.
    SendPrismaDaedricToast(path.DeityName, "prayer", "Shrine prayer answered.", Manager.GetPrismaSymbolForDeity(path))
    Manager.AppendBookOfDaysEntry("You offered prayer at the shrine of " + path.DeityName + ".", Utility.GetCurrentGameTime() as Int, "favor.act", Manager.GetPrismaSymbolForDeity(path), False, 1, "Shrine prayer answered")
    if Manager.PDV_DiegeticDirectorService
        Manager.PDV_DiegeticDirectorService.Dispatch("prayer", path.DeityName, "offer", path.DeityIndex, "")
    endIf

    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric shrine prayer: +2 " + path.DeityName + " index " + pathIndex + " source " + sourceId)
    endIf
EndFunction

Function HandleDaedricGenericSilenceProbe(String sourceId)
    if Manager.GetDebugLevel() >= 2
        Debug.Trace("[PDV] Daedric generic silence probe ignored: " + sourceId)
    endIf
EndFunction

Bool Function IsBlockedDaedricSourceId(String sourceId)
    return sourceId == "" || sourceId == "generic" || sourceId == "generic_combat" || sourceId == "generic_helping" || sourceId == "generic_spellcasting" || sourceId == "ordinary_travel" || sourceId == "ordinary_friendship" || sourceId == "ordinary_service" || sourceId == "debug_generic" || sourceId == "mcm_generic_probe" || sourceId == "eventbus_201_mcm_generic_probe"
EndFunction

Int Function GetDaedricPathCount()
    if !Manager.PDV_FLST_DaedricPaths_All
        return 0
    endIf

    return Manager.PDV_FLST_DaedricPaths_All.GetSize()
EndFunction

PDV_DaedricPathBase Function GetDaedricPathAtListIndex(Int listIndex)
    if listIndex < 0 || !Manager.PDV_FLST_DaedricPaths_All
        return None
    endIf

    if listIndex >= Manager.PDV_FLST_DaedricPaths_All.GetSize()
        return None
    endIf

    return Manager.PDV_FLST_DaedricPaths_All.GetAt(listIndex) as PDV_DaedricPathBase
EndFunction

; Resolve the single live Daedric pact to its path. Requires tier > NONE so a stale
; ActivePact pointer left at tier 0 reads as "no pact" (Survey/panel never render a
; ghost pact). Pure read; safe to call from Survey/panel/commit paths.
PDV_DaedricPathBase Function GetActiveDaedricPactPath()
    Form activeForm = StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact")
    if !activeForm
        return None
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetDeityForm() == activeForm && path.GetStoredTier() > Manager.LedgerRuntime.TIER_NONE
            return path
        endIf
        i += 1
    endWhile
    return None
EndFunction

PDV_DaedricPathBase Function GetTopPrePactDaedricPath()
    if GetActiveDaedricPactPath()
        return None
    endIf

    PDV_DaedricPathBase topPath = None
    Float topPiety = 0.0
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetStoredTier() == Manager.LedgerRuntime.TIER_NONE
            Float piety = path.GetStoredPiety()
            ; Only a Prince past the pre-pact notice threshold surfaces (panel "watching"
            ; badge + the "taken notice" beat). Below it, the Prince accrues in silence.
            if piety > topPiety && piety >= path.DAEDRIC_PREPACT_NOTICE_PIETY
                topPiety = piety
                topPath = path
            endIf
        endIf
        i += 1
    endWhile

    return topPath
EndFunction

; Look up a Daedric path by its deity Form regardless of tier (used for lapse
; surfacing, where the lapsed path is at tier 0).
PDV_DaedricPathBase Function GetDaedricPathByForm(Form deityForm)
    if !deityForm
        return None
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.GetDeityForm() == deityForm
            return path
        endIf
        i += 1
    endWhile
    return None
EndFunction

; Survey block for an active pact. Uses GetPublicTierBand so the Prince band reads
; identically to a patron band. PLACEHOLDER copy (user rewrites post-beta).
String Function GetDaedricSurveyText(PDV_DaedricPathBase path)
    return path.DeityName + " holds your pact. Standing: " + Manager.GetPublicTierBand(path.GetStoredTier()) + "."
EndFunction

; Switch-severance surface (patron<->Prince). Top-left notification + Book of Days
; entry + best-effort Prisma toast. PLACEHOLDER copy.
Function SurfaceSwitchSeverance(String mode, String severedName)
    if Manager.IsRaceSetupQuietPresentationActive()
        return
    endIf
    String line = "You forsake the pact with " + severedName + ". A new devotion takes its place."
    if mode == "patron_to_prince"
        line = "You turn from your former patron to " + severedName + ". The old bond is severed."
    endIf
    Manager.SendPrismaEventToast("shift", None, line, "", "")
    Manager.AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "reorientation", "journal", true)
EndFunction

; Lapse surface (a Prince pact fell to none). PLACEHOLDER copy.
Function SurfaceDaedricLapse(PDV_DaedricPathBase path)
    if !path
        return
    endIf
    String line = "Your pact with " + path.DeityName + " has lapsed into silence."
    Manager.SendPrismaEventToast("neglect", path, line, "", "")
    Manager.AppendBookOfDaysEntry(line, Utility.GetCurrentGameTime() as Int, "neglect.drop", "daedric", false)
EndFunction

; Drain the deferred-lapse flag the base script sets in OnTierChange when a pact
; lapses to none (the base has no manager handle, so it leaves a breadcrumb the
; manager tick picks up). Switch/migration severs clear the pointer directly and
; never set this flag, so they cannot false-fire a lapse here.
Function ProcessPendingDaedricLapse()
    Form pending = StorageUtil.GetFormValue(None, "PDV.Daedric.PendingLapse")
    if !pending
        return
    endIf
    StorageUtil.SetFormValue(None, "PDV.Daedric.PendingLapse", None)
    ; If the same Prince was re-committed within the tick, the pointer is back to it,
    ; so it did not actually lapse -- skip.
    if StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact") == pending
        return
    endIf
    SurfaceDaedricLapse(GetDaedricPathByForm(pending))
EndFunction

Function ProcessPendingDaedricPrePactNotices()
    Int count = StorageUtil.FormListCount(None, "PDV.Daedric.PendingPrePactNotices")
    if count <= 0
        return
    endIf

    PDV_DaedricPathBase topPath = GetTopPrePactDaedricPath()
    Form topForm = None
    if topPath
        topForm = topPath.GetDeityForm()
    endIf

    Bool topWasQueued = False
    while count > 0
        count -= 1
        Form queuedForm = StorageUtil.FormListGet(None, "PDV.Daedric.PendingPrePactNotices", count)
        if topForm && queuedForm == topForm
            topWasQueued = True
        endIf
        StorageUtil.FormListRemoveAt(None, "PDV.Daedric.PendingPrePactNotices", count)
    endWhile

    if !topPath || !topWasQueued || StorageUtil.GetIntValue(topForm, "PDV.Daedric.PrePactNoticeShown") == 1
        return
    endIf

    if topPath.GetStoredTier() != Manager.LedgerRuntime.TIER_NONE || topPath.GetStoredPiety() < topPath.DAEDRIC_PREPACT_NOTICE_PIETY
        return
    endIf

    String symbolName = Manager.GetPrismaSymbolForDeity(topPath)
    if symbolName == "journal"
        symbolName = "daedric"
    endIf
    ; The single pre-pact beat: the first time a still-uncommitted Prince crosses the
    ; notice threshold, name it in Book of Days and fire one soft toast. Quest reactions
    ; stay silent until the Prince reaches Seeker (see AccumulateQuestReactionSurface).
    Manager.AppendBookOfDaysEntry(topPath.DeityName + " has taken notice of you.", Utility.GetCurrentGameTime() as Int, "daedric.pressure", symbolName, False, 1, "A Prince takes notice")
    SendPrismaDaedricToast(topPath.DeityName, "watching", "An interest taken, not yet a pact.", symbolName)
    StorageUtil.SetIntValue(topForm, "PDV.Daedric.PrePactNoticeShown", 1)
EndFunction

; Drain the deferred-activation flag the base sets in MakeActiveDaedricPact on a NEW
; pact activation (from ANY path: live funnel, ambient tier-up, shrine prayer, switch-
; back). This is where patron<->Prince exclusivity is enforced: if a single patron is
; still active when a Prince pact becomes the live commitment, sever the patron and
; surface the switch. (Broad worship has no competing single-patron boons and is left
; as a documented design decision.) Switch/migration severs clear the pointer directly
; and never set this flag, so they don't interfere.
Function ProcessPendingDaedricActivation()
    Form pending = StorageUtil.GetFormValue(None, "PDV.Daedric.PendingActivation")
    if !pending
        return
    endIf
    StorageUtil.SetFormValue(None, "PDV.Daedric.PendingActivation", None)
    ; Act only if this pact is still the live active pact (it may have lapsed/switched
    ; away in the interim).
    if StorageUtil.GetFormValue(None, "PDV.Daedric.ActivePact") != pending
        return
    endIf
    PDV_DaedricPathBase path = GetDaedricPathByForm(pending)
    if path
        Manager.SendPrismaEventToast("shift", path, path.DeityName + " claims your devotion.", "", "")
    endIf
    ; Patron<->Prince severance is retired: an active divine patron is no longer cut when
    ; a Prince pact activates (a pact now requires explicit consent, so both can coexist).
    ; The Prisma shift toast above and this Book-of-Days line still surface the activation.
    if path && !HasRecentDaedricMilestoneJournal(path)
        Manager.AppendBookOfDaysEntry(path.DeityName + " claims your devotion.", Utility.GetCurrentGameTime() as Int, "reorientation", "daedric", true)
    endIf
EndFunction

; Mephala/Boethiah serve BOTH the Dunmer Reclamations and the Khajiit roster, so
; these two gate on quest-reaction reachability, not a single origin.
Function HandleMephalaWebWoven(String reason)
    if !Manager.PDV_Mephala || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Mephala)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.MephalaWebWoven")
    if multiplier <= 0.0
        Manager.Trace(2, "Mephala web-woven blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Mephala, Manager.PDV_Mephala.SIGNAL_WEB_WOVEN, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Mephala, "Web woven", "marks a web woven in shadow.")
    Manager.Trace(2, "Mephala web-woven routed (" + reason + ")")
EndFunction

Function HandleBoethiahHonorableDuel(String reason)
    if !Manager.PDV_Boethiah || !Manager.IsQuestReactionDeityReachable(Manager.PDV_Boethiah)
        return
    endIf
    Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.BoethiahHonorableDuel")
    if multiplier <= 0.0
        Manager.Trace(2, "Boethiah honorable-duel blocked by daily cap (" + reason + ")")
        return
    endIf
    Manager.LedgerRuntime.AwardCuratedSignalScaled(Manager.PDV_Boethiah, Manager.PDV_Boethiah.SIGNAL_HONORABLE_DUEL, None, multiplier)
    Manager.LedgerRuntime.SurfaceReservedSignal(Manager.PDV_Boethiah, "Duel honored", "marks a trial honorably won.")
    Manager.Trace(2, "Boethiah honorable-duel routed (" + reason + ")")
EndFunction

Function HandleHircineHuntRite(String reason)
    if Manager.PDV_HircinePath
        Float multiplier = Manager.ConsumeDailyRepeatMultiplier("PDV.Signal.HircineHuntRite")
        Float stigmaBefore = Manager.PDV_HircinePath.GetStigma()
        Int tierBefore = Manager.PDV_HircinePath.GetStoredTier()
        Manager.PDV_HircinePath.RecordHuntRiteScaled(multiplier, reason)
        if multiplier > 0.0
            ShowDaedricMilestonePresentation(Manager.PDV_HircinePath, tierBefore, Manager.PDV_HircinePath.GetStoredTier(), False)
            MaybeEmitHircineStigmaPrice(stigmaBefore, Manager.PDV_HircinePath.GetStigma())
            Manager.RequestPanelRefresh()
        endIf
        Manager.Trace(2, "Hircine hunt rite routed with multiplier " + multiplier)
    endIf
EndFunction

; Surface the Hircine "price" only when stigma crosses a meaningful threshold, so the
; cost lands on a beat the player can feel rather than on every single hunt rite.
; Thresholds mirror GetDaedricStigmaGainMultiplier (3.0 stirring, 6.0 heavy).
Function MaybeEmitHircineStigmaPrice(Float stigmaBefore, Float stigmaAfter)
    if stigmaBefore < 6.0 && stigmaAfter >= 6.0
        SendPrismaDaedricToast("Hircine", "price", "The hunt's mark has grown heavy.", "hircine")
    elseIf stigmaBefore < 3.0 && stigmaAfter >= 3.0
        SendPrismaDaedricToast("Hircine", "price", "The hunt's stigma is beginning to stir.", "hircine")
    endIf
EndFunction

Function WritePLD(PDV_DaedricPathBase path, Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    Form pldForm = path as Form
    String pldPrefix = "PDV.PLD." + eventType
    StorageUtil.SetFloatValue(pldForm, pldPrefix + ".D", delta)
    StorageUtil.SetIntValue(pldForm, pldPrefix + ".C", dailyCap)
    StorageUtil.SetFloatValue(pldForm, pldPrefix + ".O", cooldownDays)
EndFunction

Function ClearPrinceRowsForPath(PDV_DaedricPathBase path)
    Form pldForm = path as Form
    Int[] pldEvents = GetPrinceEventTypes()
    Int pldIndex = 0
    while pldIndex < pldEvents.Length
        String pldPrefix = "PDV.PLD." + pldEvents[pldIndex]
        StorageUtil.UnsetFloatValue(pldForm, pldPrefix + ".D")
        StorageUtil.UnsetIntValue(pldForm, pldPrefix + ".C")
        StorageUtil.UnsetFloatValue(pldForm, pldPrefix + ".O")
        pldIndex += 1
    endWhile
EndFunction

Int[] Function GetPrinceEventTypes()
    Int[] pldEvents = new Int[33]
    pldEvents[0] = 1
    pldEvents[1] = 2
    pldEvents[2] = 300
    pldEvents[3] = 302
    pldEvents[4] = 303
    pldEvents[5] = 304
    pldEvents[6] = 313
    pldEvents[7] = 314
    pldEvents[8] = 315
    pldEvents[9] = 330
    pldEvents[10] = 331
    pldEvents[11] = 332
    pldEvents[12] = 333
    pldEvents[13] = 334
    pldEvents[14] = 340
    pldEvents[15] = 341
    pldEvents[16] = 342
    pldEvents[17] = 343
    pldEvents[18] = 344
    pldEvents[19] = 345
    pldEvents[20] = 350
    pldEvents[21] = 351
    pldEvents[22] = 354
    pldEvents[23] = 360
    pldEvents[24] = 361
    pldEvents[25] = 362
    pldEvents[26] = 364
    pldEvents[27] = 365
    pldEvents[28] = 366
    pldEvents[29] = 367
    pldEvents[30] = 368
    pldEvents[31] = 305
    pldEvents[32] = 306
    return pldEvents
EndFunction

; Fan a scored act over the OPEN Daedric paths. An open (committed) path deepens its OWN piety
; (progression + boons/prices), never the ambient V1 pool. ScorePrinceAction enforces the
; path-open gate + anti-farm. actorRef/targetRef kept for parity with the deity fan-out.
Function RouteActionToOpenPaths(Int eventType, Form actorRef, Form targetRef)
    if !Manager.PDV_FLST_DaedricPaths_All
        return
    endIf
    Int rop = 0
    Int ropCount = Manager.PDV_FLST_DaedricPaths_All.GetSize()
    while rop < ropCount
        PDV_DaedricPathBase ropPath = Manager.PDV_FLST_DaedricPaths_All.GetAt(rop) as PDV_DaedricPathBase
        if ropPath
            Float ropDelta = ropPath.ScorePrinceAction(eventType)
            if ropDelta != 0.0
                ; fix-plan 4.3: the Prince lane applies its deepen delta directly to the
                ; path's own piety with no gain pipeline in between, so a nonzero delta
                ; here always lands -- spend the cap slot. (Nothing is queued when the
                ; delta is zero, so the else side needs no discard.)
                ropPath.CommitPendingRepeatableActions()
                ropPath.AdjustStoredPiety(ropDelta, "v2_" + eventType)
                Manager.OriginRuntime.RefreshArgonianDominationPressureForPath(ropPath, "prince_v2_" + eventType)
                if Manager.GetDebugLevel() >= 2
                    Debug.Trace("[PDV] PrinceV2: " + ropPath.DeityName + " event " + eventType + " deepen " + ropDelta)
                endIf
            endIf
        endIf
        rop += 1
    endWhile
EndFunction

Function LoadPrinceRowsForPath(PDV_DaedricPathBase path)
    String ldName = path.DeityName
    if ldName == "Mehrunes Dagon"
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 302, 1.0, 2, 0.5)
        WritePLD(path, 304, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.5, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 300, 0.5, 3, 0.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 331, -0.25, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
    elseIf ldName == "Hircine"
        WritePLD(path, 1, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 302, 0.5, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
        WritePLD(path, 303, 0.75, 2, 0.5)
        WritePLD(path, 304, -0.5, 3, 0.0)
    elseIf ldName == "Meridia"
        WritePLD(path, 300, 1.0, 2, 0.5)
        WritePLD(path, 365, -2.0, 1, 1.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 303, -0.25, 3, 0.0)
    elseIf ldName == "Molag Bal"
        WritePLD(path, 364, 0.75, 2, 0.5)
        WritePLD(path, 304, 0.75, 2, 0.5)
        WritePLD(path, 366, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.5, 3, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 365, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.5, 3, 0.0)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
    elseIf ldName == "Hermaeus Mora"
        WritePLD(path, 342, 1.0, 2, 0.5)
        WritePLD(path, 341, 0.5, 3, 0.0)
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 343, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 340, 0.5, 3, 0.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 334, 0.25, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
        WritePLD(path, 351, -0.25, 3, 0.0)
    elseIf ldName == "Namira"
        WritePLD(path, 300, -0.5, 3, 0.0)
        WritePLD(path, 367, 2.0, 1, 1.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 313, -0.25, 3, 0.0)
        WritePLD(path, 365, 1.0, 1, 0.5)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
    elseIf ldName == "Nocturnal"
        WritePLD(path, 360, 0.5, 3, 0.0)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 345, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.25, 3, 0.0)
        WritePLD(path, 305, 0.5, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 2, -0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
    elseIf ldName == "Peryite"
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 330, 0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 314, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.25, 3, 0.0)
        WritePLD(path, 333, 0.25, 3, 0.0)
    elseIf ldName == "Sanguine"
        WritePLD(path, 333, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
    elseIf ldName == "Sheogorath"
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 343, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 315, -0.25, 3, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.5, 3, 0.0)
        WritePLD(path, 302, 0.5, 3, 0.0)
        WritePLD(path, 350, 0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
    elseIf ldName == "Vaermina"
        WritePLD(path, 314, 0.5, 3, 0.0)
        WritePLD(path, 342, 0.5, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.25, 3, 0.0)
        WritePLD(path, 343, 0.25, 3, 0.0)
        WritePLD(path, 304, 0.5, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 341, 0.25, 3, 0.0)
        WritePLD(path, 333, -0.25, 3, 0.0)
        WritePLD(path, 332, -0.25, 3, 0.0)
    elseIf ldName == "Clavicus Vile"
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 354, 0.5, 3, 0.0)
        WritePLD(path, 362, -0.25, 3, 0.0)
        WritePLD(path, 345, 0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 331, 0.25, 3, 0.0)
        WritePLD(path, 330, -0.25, 3, 0.0)
        WritePLD(path, 344, -0.25, 3, 0.0)
        WritePLD(path, 360, -0.25, 3, 0.0)
    elseIf ldName == "Azura"
        WritePLD(path, 313, 0.5, 3, 0.0)
        WritePLD(path, 350, 0.75, 2, 0.5)
        WritePLD(path, 343, 0.75, 2, 0.5)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 345, 0.5, 3, 0.0)
        WritePLD(path, 314, 0.25, 3, 0.0)
        WritePLD(path, 364, -0.5, 3, 0.0)
        WritePLD(path, 365, -0.75, 2, 0.5)
    elseIf ldName == "Boethiah"
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 344, 0.5, 3, 0.0)
        WritePLD(path, 304, 0.75, 2, 0.5)
        WritePLD(path, 360, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 364, 0.5, 2, 0.0)
        WritePLD(path, 362, 0.25, 3, 0.0)
        WritePLD(path, 351, -0.75, 1, 0.5)
    elseIf ldName == "Mephala"
        WritePLD(path, 360, 0.5, 3, 0.0)
        WritePLD(path, 362, 0.5, 3, 0.0)
        WritePLD(path, 304, 1.0, 2, 0.5)
        WritePLD(path, 305, 0.5, 2, 0.5)
        WritePLD(path, 361, 0.25, 3, 0.0)
        WritePLD(path, 342, 0.25, 3, 0.0)
        WritePLD(path, 368, 1.5, 1, 1.0)
        WritePLD(path, 364, 0.5, 3, 0.0)
        WritePLD(path, 332, 0.25, 3, 0.0)
        WritePLD(path, 306, 0.5, 3, 0.0)
        WritePLD(path, 2, -0.25, 3, 0.0)
        WritePLD(path, 350, -0.25, 3, 0.0)
        WritePLD(path, 313, -0.25, 3, 0.0)
    elseIf ldName == "Malacath"
        WritePLD(path, 330, 0.75, 2, 0.5)
        WritePLD(path, 2, 0.25, 3, 0.0)
        WritePLD(path, 1, 0.25, 3, 0.0)
        WritePLD(path, 313, 0.25, 3, 0.0)
        WritePLD(path, 362, -0.25, 3, 0.0)
        WritePLD(path, 364, -0.75, 2, 0.5)
        WritePLD(path, 305, -0.25, 3, 0.0)
        WritePLD(path, 368, 1.0, 1, 1.0)
        WritePLD(path, 302, 1.0, 2, 0.5)
        WritePLD(path, 344, 0.25, 3, 0.0)
        WritePLD(path, 304, -0.75, 2, 0.5)
        WritePLD(path, 360, -0.25, 3, 0.0)
    endIf
EndFunction

; Daedric Princes apply piety immediately (no per-day fold into PDV.Piety), so this
; only rolls the day's tally into the Weekly ring and clears it -- it must NOT touch
; PDV.Piety. PietyToday for paths is accumulated in PDV_DaedricPathBase.SetStoredPiety.
Function RunDawnConsolidateDaedricWeek()
    if !Manager.PDV_FLST_DaedricPaths_All
        return
    endIf
    Int i = 0
    Int count = Manager.PDV_FLST_DaedricPaths_All.GetSize()
    while i < count
        Form pathForm = Manager.PDV_FLST_DaedricPaths_All.GetAt(i)
        if pathForm
            PDV_DaedricPathBase path = pathForm as PDV_DaedricPathBase
            Float dayNet = StorageUtil.GetFloatValue(pathForm, "PDV.PietyToday")
            if path && dayNet > 0.0
                Manager.RecordBookOfDaysFedName(path.DeityName)
            endIf
            if dayNet != 0.0
                Manager.SetDawnHadActivity(True)
            endIf
            Manager.PushWeekNet(pathForm, dayNet)
            StorageUtil.SetFloatValue(pathForm, "PDV.PietyToday", 0.0)
        endIf
        i += 1
    endWhile
EndFunction

Float Function GetDaedricStigmaGainMultiplier(PDV_DeityBase deity)
    if Manager.GetPlayerOriginRaceIndex() == Manager.ORIGIN_BRETON && Manager.OriginRuntime.GetBretonTraditionValue() == Manager.BRETON_TRADITION_HIDDEN_ART && IsBretonHiddenArtDaedricOfferDeity(deity) && StorageUtil.GetIntValue(None, "PDV.Breton.WitchcraftExposure") >= 100
        return 1.25
    endIf
    if Manager.PDV_HircinePath && deity == Manager.PDV_HircinePath
        Float stigma = Manager.PDV_HircinePath.GetStigma()
        if stigma >= 6.0
            return 1.25
        elseIf stigma >= 3.0
            return 1.1
        endIf
    endIf

    return 1.0
EndFunction

; Clear every Daedric path's boon + price spells. StripPactSpells is the path base's
; own remover (ClearAllBoons + ClearPriceSpells), already used by the pact migration.
Function StripAllDaedricPactSpells()
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path
            path.StripPactSpells()
        endIf
        i += 1
    endWhile
EndFunction

Bool Function IsBretonHiddenArtDaedricOfferDeity(PDV_DeityBase deity)
    PDV_DaedricPathBase path = deity as PDV_DaedricPathBase
    if !path
        return False
    endIf

    String pathName = path.DeityName
    return pathName == "Hermaeus Mora" || pathName == "Hircine" || pathName == "Namira" || pathName == "Nocturnal"
EndFunction

; Emit a "daedric" event for a Daedric Prince interaction.
; princeName = e.g. "Hircine", "Azura"
; phase      = "boon" | "price" | "lapse" | "residue" | "prayer"
; context    = optional short phrase
; symbolName = Prisma symbol key; falls back to journal until glyphs land
Bool Function SendPrismaDaedricToast(String princeName, String phase, String context, String symbolName, Bool allowFallback = True)
    if phase == "price"
        PDV_DaedricPathBase activePact = GetActiveDaedricPactPath()
        if activePact && activePact.DeityName == princeName && activePact.ShouldWaivePriceForPlayer()
            Manager.Trace(2, "Daedric price toast suppressed for integrated Breton Hidden Art pact: " + princeName)
            return True
        endIf
    endIf

    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"prince\":\"" + PDV_DevotionRules.JsonSafeString(princeName) + "\""
    j = j + ",\"phase\":\"" + PDV_DevotionRules.JsonSafeString(phase) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    if phase == "boon"
        j = j + ",\"tone\":\"good\""
    endIf
    if context != ""
        j = j + ",\"context\":\"" + PDV_DevotionRules.JsonSafeString(context) + "\""
    endIf
    j = j + "}}"
    return Manager.SendPrismaToastPayloadOrFallback(j, princeName, context, allowFallback)
EndFunction

Bool Function ReplayConcreteDaedricChampionOffer(PDV_DaedricPathBase path, Int oldTier, Int newTier)
    if !path
        return False
    endIf

    Form pathForm = path.GetDeityForm()
    String princeName = path.DeityName
    if princeName == "Boethiah"
        PDV_DaedricPath_Boethiah concreteBoethiah = pathForm as PDV_DaedricPath_Boethiah
        if concreteBoethiah
            concreteBoethiah.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Azura"
        PDV_DaedricPath_Azura concreteAzura = pathForm as PDV_DaedricPath_Azura
        if concreteAzura
            concreteAzura.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Vaermina"
        PDV_DaedricPath_Vaermina concreteVaermina = pathForm as PDV_DaedricPath_Vaermina
        if concreteVaermina
            concreteVaermina.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Meridia"
        PDV_DaedricPath_Meridia concreteMeridia = pathForm as PDV_DaedricPath_Meridia
        if concreteMeridia
            concreteMeridia.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Molag Bal"
        PDV_DaedricPath_Molag concreteMolag = pathForm as PDV_DaedricPath_Molag
        if concreteMolag
            concreteMolag.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Mephala"
        PDV_DaedricPath_Mephala concreteMephala = pathForm as PDV_DaedricPath_Mephala
        if concreteMephala
            concreteMephala.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Malacath"
        PDV_DaedricPath_Malacath concreteMalacath = pathForm as PDV_DaedricPath_Malacath
        if concreteMalacath
            concreteMalacath.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Mehrunes Dagon"
        PDV_DaedricPath_Dagon concreteDagon = pathForm as PDV_DaedricPath_Dagon
        if concreteDagon
            concreteDagon.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Sheogorath"
        PDV_DaedricPath_Sheo concreteSheo = pathForm as PDV_DaedricPath_Sheo
        if concreteSheo
            concreteSheo.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Namira"
        PDV_DaedricPath_Namira concreteNamira = pathForm as PDV_DaedricPath_Namira
        if concreteNamira
            concreteNamira.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Sanguine"
        PDV_DaedricPath_Sanguine concreteSanguine = pathForm as PDV_DaedricPath_Sanguine
        if concreteSanguine
            concreteSanguine.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Clavicus Vile"
        PDV_DaedricPath_Vile concreteVile = pathForm as PDV_DaedricPath_Vile
        if concreteVile
            concreteVile.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Hermaeus Mora"
        PDV_DaedricPath_Mora concreteMora = pathForm as PDV_DaedricPath_Mora
        if concreteMora
            concreteMora.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Nocturnal"
        PDV_DaedricPath_Nocturnal concreteNocturnal = pathForm as PDV_DaedricPath_Nocturnal
        if concreteNocturnal
            concreteNocturnal.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Peryite"
        PDV_DaedricPath_Peryite concretePeryite = pathForm as PDV_DaedricPath_Peryite
        if concretePeryite
            concretePeryite.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    elseIf princeName == "Hircine"
        PDV_DaedricPath_Hircine concreteHircine = pathForm as PDV_DaedricPath_Hircine
        if concreteHircine
            concreteHircine.ShowTierEntryMessage(oldTier, newTier)
            return True
        endIf
    endIf

    Manager.Trace(1, "Daedric Champion offer replay failed to resolve concrete path: " + princeName)
    return False
EndFunction

Function DrainHircineResiduePrismaToasts()
    if !Manager.PDV_HircinePath
        return
    endIf

    Form hircineForm = Manager.PDV_HircinePath.GetDeityForm()
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks") > 0
        return
    endIf

    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastPending") == 1
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastPending", 0)
        SendPrismaDaedricToast("Hircine", "residue", "The hunt's old mark still follows.", "hircine")
    endIf
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueClearToastPending") == 1
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueClearToastPending", 0)
        SendPrismaDaedricToast("Hircine", "residue", "The hunt's old mark fades.", "hircine")
    endIf
EndFunction

Function ProcessDelayedHircineResiduePrismaToasts()
    if !Manager.PDV_HircinePath
        return
    endIf

    Form hircineForm = Manager.PDV_HircinePath.GetDeityForm()
    Int delayTicks = StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks")
    if delayTicks > 0
        StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.ResidueToastDelayTicks", delayTicks - 1)
        return
    endIf

    DrainHircineResiduePrismaToasts()
EndFunction

Function DrainHircineRenunciationJournal()
    if !Manager.PDV_HircinePath
        return
    endIf

    Form hircineForm = Manager.PDV_HircinePath.GetDeityForm()
    if StorageUtil.GetIntValue(hircineForm, "PDV.Daedric.Hircine.RenunciationJournalPending") != 1
        return
    endIf

    StorageUtil.SetIntValue(hircineForm, "PDV.Daedric.Hircine.RenunciationJournalPending", 0)
    Manager.SendPrismaToast("hircine", "neutral", "You renounce the hunt.", "Hircine's pact is set down.")
    Manager.AppendBookOfDaysEntry("Hircine's mark fades from your blood, and the pack is no longer yours.", Utility.GetCurrentGameTime() as Int, "reorientation", "hircine", True, 3)
EndFunction

Function QueueDaedricMilestonePresentation(PDV_DaedricPathBase path, Int oldTier, Int newTier, String reason)
    if !path || newTier <= Manager.LedgerRuntime.TIER_NONE
        return
    endIf

    _pendingDaedricMilestonePath = path
    _pendingDaedricMilestoneOldTier = oldTier
    _pendingDaedricMilestoneNewTier = newTier
    _pendingDaedricMilestoneReason = reason
    _pendingDaedricMilestoneReplayChampionOffer = False
    _pendingDaedricMilestoneDelayTicks = 0
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone queued: " + path.DeityName + " " + Manager.GetTierStandingLabel(newTier) + " (" + reason + ")")
    endIf
EndFunction

Function QueueDaedricMilestoneMcmReplay(PDV_DaedricPathBase path, Int oldTier, Int newTier, String reason)
    if !path || newTier <= Manager.LedgerRuntime.TIER_NONE
        return
    endIf

    _pendingDaedricMilestonePath = path
    _pendingDaedricMilestoneOldTier = oldTier
    _pendingDaedricMilestoneNewTier = newTier
    _pendingDaedricMilestoneReason = reason
    _pendingDaedricMilestoneReplayChampionOffer = True
    _pendingDaedricMilestoneDelayTicks = 2
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone MCM replay queued: " + path.DeityName + " " + Manager.GetTierStandingLabel(newTier) + " (" + reason + ")")
    endIf
EndFunction

Function ProcessQueuedDaedricMilestonePresentation()
    if !_pendingDaedricMilestonePath
        return
    endIf

    if _pendingDaedricMilestoneDelayTicks > 0
        _pendingDaedricMilestoneDelayTicks -= 1
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric milestone queue waiting: " + _pendingDaedricMilestonePath.DeityName + " ticks=" + _pendingDaedricMilestoneDelayTicks)
        endIf
        return
    endIf

    ; The Champion-offer replay shows a blocking authored Message that cannot display
    ; while a menu (the MCM) is open. Hold the pending presentation until menus close;
    ; OnUpdate re-checks each tick. Non-replay toasts are Prisma overlay and unaffected.
    if _pendingDaedricMilestoneReplayChampionOffer && Utility.IsInMenuMode()
        if Manager.GetDebugLevel() >= 2
            Debug.Trace("[PDV] Daedric Champion offer holding for menu close: " + _pendingDaedricMilestonePath.DeityName)
        endIf
        return
    endIf

    PDV_DaedricPathBase path = _pendingDaedricMilestonePath
    Int oldTier = _pendingDaedricMilestoneOldTier
    Int requestedTier = _pendingDaedricMilestoneNewTier
    String reason = _pendingDaedricMilestoneReason
    Bool replayChampionOffer = _pendingDaedricMilestoneReplayChampionOffer
    _pendingDaedricMilestonePath = None
    _pendingDaedricMilestoneOldTier = 0
    _pendingDaedricMilestoneNewTier = 0
    _pendingDaedricMilestoneReason = ""
    _pendingDaedricMilestoneReplayChampionOffer = False
    _pendingDaedricMilestoneDelayTicks = 0

    Int currentTier = path.GetStoredTier()
    if currentTier <= Manager.LedgerRuntime.TIER_NONE
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric milestone queue skipped: " + path.DeityName + " has no active tier (" + reason + ")")
        endIf
        return
    endIf

    Int targetTier = requestedTier
    if targetTier > currentTier
        targetTier = currentTier
    endIf
    if targetTier <= oldTier
        if Manager.GetDebugLevel() >= 1
            Debug.Trace("[PDV] Daedric milestone queue skipped: " + path.DeityName + " target " + targetTier + " <= old " + oldTier + " (" + reason + ")")
        endIf
        return
    endIf

    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone queue processing: " + path.DeityName + " " + Manager.GetTierStandingLabel(targetTier) + " (" + reason + ")")
    endIf
    ShowDaedricMilestonePresentation(path, oldTier, targetTier, replayChampionOffer)
EndFunction

Function ShowDaedricMilestonePresentation(PDV_DaedricPathBase path, Int oldTier, Int newTier, Bool replayChampionOffer)
    if !path || newTier <= oldTier || newTier <= Manager.LedgerRuntime.TIER_NONE
        return
    endIf

    if replayChampionOffer && newTier == Manager.LedgerRuntime.TIER_CHAMPION
        if !ReplayConcreteDaedricChampionOffer(path, oldTier, newTier)
            return
        endIf
        Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
        if path.GetStoredTier() < Manager.LedgerRuntime.TIER_CHAMPION
            if Manager.GetDebugLevel() >= 1
                Debug.Trace("[PDV] Daedric milestone presentation skipped after Champion decline: " + path.DeityName)
            endIf
            return
        endIf
    else
        Manager.LedgerRuntime.SyncFirstTierRaceRewardRuntime()
    endIf

    String princeName = path.DeityName
    String tierLabel = Manager.GetTierStandingLabel(newTier)
    String flavorText = GetDaedricMilestoneFlavor(princeName, newTier)
    String boonText = GetDaedricBoonMechanicText(princeName, newTier)
    String priceText = ""
    if !path.ShouldWaivePriceForPlayer()
        priceText = GetDaedricPriceMechanicText(princeName, newTier)
    endIf
    String symbolName = Manager.GetPrismaSymbolForDeity(path)
    if symbolName == "journal"
        symbolName = "daedric"
    endIf

    Bool prismaSent = SendPrismaDaedricMilestoneToast(princeName, tierLabel, flavorText, boonText, priceText, symbolName)
    SendPrismaDaedricToast(princeName, "boon", boonText, symbolName)
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone presentation: " + princeName + " " + tierLabel + " prisma=" + prismaSent)
    endIf
    ; Surface the Daedric tier gain in the Book of Days like a patron tier-up
    ; (tone tier.reach -> "Favor deepened"/good; Champion pinned). The toast already
    ; fired above; this adds the persistent journal entry. PLACEHOLDER copy.
    Manager.AppendBookOfDaysEntry(princeName + " names you " + tierLabel + ".", Utility.GetCurrentGameTime() as Int, "tier.reach", symbolName, newTier >= Manager.LedgerRuntime.TIER_CHAMPION)
    StorageUtil.SetFormValue(None, "PDV.Daedric.LastMilestoneJournalPath", path.GetDeityForm())
    StorageUtil.SetFloatValue(None, "PDV.Daedric.LastMilestoneJournalTime", Utility.GetCurrentGameTime())
EndFunction

Bool Function HasRecentDaedricMilestoneJournal(PDV_DaedricPathBase path)
    if !path
        return false
    endIf
    if StorageUtil.GetFormValue(None, "PDV.Daedric.LastMilestoneJournalPath") != path.GetDeityForm()
        return false
    endIf
    Float lastTime = StorageUtil.GetFloatValue(None, "PDV.Daedric.LastMilestoneJournalTime")
    return lastTime > 0.0 && (Utility.GetCurrentGameTime() - lastTime) <= 0.0001
EndFunction

Bool Function SendPrismaDaedricMilestoneToast(String princeName, String tierLabel, String flavorText, String boonText, String priceText, String symbolName, Bool allowFallback = True)
    String titleText = princeName + " names you " + tierLabel
    String j = "{\"mode\":\"toast\",\"toast\":{\"event\":\"daedric\""
    j = j + ",\"phase\":\"milestone\""
    j = j + ",\"prince\":\"" + PDV_DevotionRules.JsonSafeString(princeName) + "\""
    j = j + ",\"tierLabel\":\"" + PDV_DevotionRules.JsonSafeString(tierLabel) + "\""
    j = j + ",\"symbol\":\"" + PDV_DevotionRules.JsonSafeString(symbolName) + "\""
    j = j + ",\"title\":\"" + PDV_DevotionRules.JsonSafeString(titleText) + "\""
    j = j + ",\"message\":\"" + PDV_DevotionRules.JsonSafeString(flavorText) + "\""
    j = j + ",\"duration\":9000"
    j = j + "}}"
    Bool sent = Manager.SendPrismaToastPayloadOrFallback(j, titleText, flavorText, allowFallback)
    if Manager.GetDebugLevel() >= 1
        Debug.Trace("[PDV] Daedric milestone Prisma payload sent=" + sent + " prince=" + princeName + " tier=" + tierLabel)
    endIf
    return sent
EndFunction

String Function GetDaedricMilestoneFlavor(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Boethiah marks the seeker of trials."
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Boethiah's trial momentum is yours."
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Boethiah names you proven."
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Azura opens the threshold a little."
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Azura's twilight is yours."
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Azura names you her seer."
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Vaermina's touch opens the dream-path."
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Vaermina's nightmare deepens."
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Vaermina names you her nightmare-walker."
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Meridia's light stirs in you."
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Meridia's radiance is yours in full."
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Meridia names you her cleansing blade."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Molag Bal's domination-edge settles in you."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "The grip deepens."
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "You carry the full weight of Molag Bal's domination."
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Mephala spins you a first thread."
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Mephala's web is yours to read."
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Mephala names you of the web."
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Malacath hardens the outcast."
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Malacath's endurance is yours."
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Malacath names you of the spurned-and-strong."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Dagon's edge settles in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Dagon's ruin deepens in you."
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Dagon names you his ruin made walking."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Sheogorath's absurdity opens a crack."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Sheogorath's disruption deepens."
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Sheogorath names you the Mad God's own."
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Namira's darkness settles around you."
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Namira's outcast fellowship deepens."
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Namira names you of the outcast faithful."
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Sanguine's ease settles in you."
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Sanguine's indulgence deepens."
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Sanguine names you his own."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Vile's transactional edge is yours."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Vile's contract deepens."
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Vile names you his preferred client."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Mora's archive opens a corner."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Mora's collection deepens in you."
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Mora names you archivist."
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Shadow luck covers you."
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Nocturnal's shade deepens."
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Nocturnal's debt runs in your favor."
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Peryite's resilience settles in you."
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Peryite's imposed order deepens."
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Peryite names you keeper of the lowest order."
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Hircine's hunt-sense is in you."
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "The hunt runs deeper now."
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "You see the whole arc of the hunt -- target, approach, kill, clean territory."
    endIf

    return "The pact has deepened."
EndFunction

String Function GetDaedricBoonMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 One-handed"
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Armor rating"
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35 Armor rating"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+15% Magic resistance"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35 Magicka"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Sneak"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Restoration"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25% Disease resistance"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35% Disease resistance"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Illusion"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Pickpocket"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Pickpocket"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+15 Armor rating"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Two-handed"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Two-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Destruction"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 One-handed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 One-handed"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Illusion"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35 Magicka"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "Feeding restores Health and Stamina"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+15 Stamina"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Speech"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Speech"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Carry weight"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35 Carry weight"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Alteration"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Magicka"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+20 Alteration; +20 Magicka"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+10 Sneak"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Lockpicking"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Lockpicking"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+15% Disease resistance"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+25 Health"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+35 Health"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "+15 Stamina"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "+18 Sneak"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "+25 Sneak"
    endIf

    return "pact boon active"
EndFunction

String Function GetDaedricPriceMechanicText(String princeName, Int tierValue)
    if (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Boethiah") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Azura") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Vaermina") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Illusion"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Illusion"
    elseIf (princeName == "Meridia") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Illusion"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Molag Bal" || princeName == "Molag") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Mephala") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-4% Movement speed"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-7% Movement speed"
    elseIf (princeName == "Malacath") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-10% Movement speed"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Armor rating"
    elseIf (princeName == "Mehrunes Dagon" || princeName == "Dagon") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Armor rating"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Sheogorath" || princeName == "Sheo") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Speech"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Speech"
    elseIf (princeName == "Namira") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Speech"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Magicka"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Magicka"
    elseIf (princeName == "Sanguine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Magicka"
    elseIf (princeName == "Clavicus Vile" || princeName == "Vile") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Magicka"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Hermaeus Mora" || princeName == "Mora") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-18 Restoration"
    elseIf (princeName == "Nocturnal") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-25 Restoration"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Stamina"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Stamina"
    elseIf (princeName == "Peryite") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Stamina"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_SEEKER
        return "-10 Health"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_DEVOTED
        return "-20 Health"
    elseIf (princeName == "Hircine") && tierValue == Manager.LedgerRuntime.TIER_CHAMPION
        return "-30 Health"
    endIf

    return "pact price active"
EndFunction

String Function GetHircineSummary()
    if !Manager.PDV_HircinePath
        return "missing"
    endIf

    return Manager.PDV_HircinePath.GetPilotSummary()
EndFunction

PDV_DaedricPathBase Function GetDaedricPathByName(String deityName)
    if deityName == "Namira" && _kidNamiraPath
        return _kidNamiraPath
    elseIf deityName == "Sanguine" && _kidSanguinePath
        return _kidSanguinePath
    endIf
    Int i = 0
    Int count = GetDaedricPathCount()
    while i < count
        PDV_DaedricPathBase path = GetDaedricPathAtListIndex(i)
        if path && path.DeityName == deityName
            if deityName == "Namira"
                _kidNamiraPath = path
            elseIf deityName == "Sanguine"
                _kidSanguinePath = path
            endIf
            return path
        endIf
        i += 1
    endWhile
    return None
EndFunction
