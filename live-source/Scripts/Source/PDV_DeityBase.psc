;/ 
    PDV_DeityBase.psc
    PlayerDevotion - Phase 4 deity contract / base class
    -----------------------------------------------------------------------
    OVERVIEW
    Abstract base class that every concrete deity script extends
    (PDV_Deity_Kyne, PDV_Deity_Talos, etc.). Establishes the contract
    that all deities honor: identity, tier thresholds, stance data,
    rivalry metadata, and patron-only cumulative boon handling.

    DESIGN NOTES
    - All piety reads/writes go through StorageUtil keyed by this quest's
      Form. Deities do not own canonical state in globals.
    - Phase 4 replaces the old GainMult_* origin floats with race-keyed
      stance properties.
    - Boons are cumulative across tiers, but only the active patron's
      boons are live on the player at a time.
    -----------------------------------------------------------------------
/;

Scriptname PDV_DeityBase extends Quest

String Property DeityName Auto
String Property DeityDomain Auto
Int Property DeityIndex Auto

Float Property ThresholdSeeker = 25.0 Auto
Float Property ThresholdDevoted = 50.0 Auto
Float Property ThresholdChampion = 85.0 Auto
Bool Property IsAedric = False Auto

Int Property STANCE_NATIVE = 0 AutoReadOnly
Int Property STANCE_FOREIGN = 1 AutoReadOnly
Int Property STANCE_TABOO = 2 AutoReadOnly
Int Property STANCE_HOSTILE = 3 AutoReadOnly

Int Property RACE_NORD = 0 AutoReadOnly
Int Property RACE_IMPERIAL = 1 AutoReadOnly
Int Property RACE_BRETON = 2 AutoReadOnly
Int Property RACE_ALTMER = 3 AutoReadOnly
Int Property RACE_BOSMER = 4 AutoReadOnly
Int Property RACE_DUNMER = 5 AutoReadOnly
Int Property RACE_KHAJIIT = 6 AutoReadOnly
Int Property RACE_ARGONIAN = 7 AutoReadOnly
Int Property RACE_ORSIMER = 8 AutoReadOnly
Int Property RACE_REDGUARD = 9 AutoReadOnly

Int Property NORD_BASELINE_OLD_WAYS = 0 AutoReadOnly
Int Property NORD_BASELINE_NINE_DIVINES = 1 AutoReadOnly

Int Property Stance_Nord = 1 Auto
Int Property Stance_Imperial = 1 Auto
Int Property Stance_Breton = 1 Auto
Int Property Stance_Altmer = 1 Auto
Int Property Stance_Bosmer = 1 Auto
Int Property Stance_Dunmer = 1 Auto
Int Property Stance_Khajiit = 1 Auto
Int Property Stance_Argonian = 1 Auto
Int Property Stance_Orc = 1 Auto
Int Property Stance_Redguard = 1 Auto

Quest[] Property RivalDeities Auto
Float[] Property RivalMultipliers Auto

Spell Property Boon_Seeker Auto
Spell Property Boon_Devoted Auto
Spell Property Boon_Champion Auto

PDV_ReputationTrack Property GainModifyingTrack Auto
Float[] Property GainMultiplierPerTrackState Auto
PDV_ReputationTrack Property DecayModifyingTrack Auto
Float[] Property DecayMultiplierPerTrackState Auto
PDV_StateTrack Property EligibleStateTrack Auto
Int[] Property EligibleStateValues Auto
Float Property InactivePathGainMultiplier = 0.25 Auto
; When >= 0, the EligibleStateTrack path gate applies ONLY to this origin race. Shared deities
; (e.g. Baan Dar, native to both Bosmer and Khajiit) set this to the race the path system belongs
; to (Bosmer = 4) so other native races are not penalized by another race's path gate. -1 = all.
Int Property EligibleStateTrackOriginRace = -1 Auto

GlobalVariable Property PDV_GLO_DebugLevel Auto
GlobalVariable Property PDV_GLO_OriginRace Auto

Int Property TIER_NONE = 0 AutoReadOnly
Int Property TIER_SEEKER = 1 AutoReadOnly
Int Property TIER_DEVOTED = 2 AutoReadOnly
Int Property TIER_CHAMPION = 3 AutoReadOnly

; Devotional "day" offset. Subtracts 06:00 so the anti-farm day boundary aligns with
; the dawn consolidation trigger in PDV__ManagerQuest. Keep 0.25 in sync with that
; trigger's offset. 0.25 = 6/24; use 5.0/24.0 for 05:00.
Float Property DAWN_DAY_OFFSET = 0.25 AutoReadOnly

Float Function ScoreAction(Int eventType, Form actorRef, Form targetRef)
    ; Base scoring is data-driven: read this deity's like/dislike row for eventType
    ; from StorageUtil (populated from the likes/dislikes CSV). Returns 0.0 when no
    ; row is loaded, so concrete overrides (Kyne/Talos/Shor) and unseeded deities
    ; behave exactly as before until the table is authored.
    return ScoreFromTable(eventType)
EndFunction

; Like/dislike table lookup. Base rows key on the deity form as
; "PDV.LD.<eventType>.D", ".C", ".O". Origin-gated overlay rows key as
; "PDV.LD.<eventType>.O<origin>.D", ".C", ".O". Nonzero delta means a row exists;
; anti-farm runs through the shared dawn-aligned ScoreRepeatableAction path.
; Generic day-to-day acts only score deities NATIVE to the player's race (race-eligible),
; matching the curated-signal layer's race-scoping (achieved there by targeted dispatch).
; FOREIGN/TABOO/HOSTILE deities score 0 for generic acts; cross-pantheon worship goes
; through the Daedric path (stigma) or curated signals, never the generic faucet.
Bool Function IsRaceNativeForPlayer()
    if GetStanceForPlayer() != STANCE_NATIVE
        return False
    endIf

    if GetCurrentOriginRaceIndex() == RACE_NORD
        return IsNordBaselineNativeForPlayer()
    endIf

    return True
EndFunction

Bool Function IsNordBaselineNativeForPlayer()
    Int baselineState = StorageUtil.GetIntValue(None, "PDV.NordPantheonBaseline.DebugState")

    ; Shared Nord-native names remain live in both baselines.
    if DeityName == "Talos" || DeityName == "Mara" || DeityName == "Arkay" || DeityName == "Dibella"
        return True
    endIf

    if baselineState == NORD_BASELINE_OLD_WAYS
        return DeityName == "Kyne" || DeityName == "Shor" || DeityName == "Tsun" || DeityName == "Stuhn"
    elseIf baselineState == NORD_BASELINE_NINE_DIVINES
        return DeityName == "Akatosh" || DeityName == "Stendarr" || DeityName == "Zenithar" || DeityName == "Julianos" || DeityName == "Kynareth"
    endIf

    return False
EndFunction

;/ =====================================================================
    12.4 / audit C4 -- the participating-event cache
    ---------------------------------------------------------------------
    Every broadcast act (a kill, a skill-up, a craft, a picked lock, a book,
    a harvest...) fans out over the whole ~34-deity roster in
    PDV_EventBus.RouteActionWithAttribution, calling ScoreAction -- and so
    ScoreFromTable -- once per deity. Roughly thirty of those deities have no
    likes/dislikes row for the event at all, and each of them still paid a
    "PDV.LD." + eventType string build, the race gate (a GlobalVariable read,
    and for a Nord player a StorageUtil read plus up to nine String compares),
    and then one or two StorageUtil.GetFloatValue probes to discover the row it
    already knew nothing about. On a Nord character that is ~68 native calls and
    several hundred string compares per event, and kills alone make that hot.

    The fix the fix-plan asked for is a precomputed participating-deity list per
    event type. This is that list, held from the other end: each deity records
    which event types it was given a row for, at the moment WriteLD writes them.
    Membership is then a scan of a ~13-element Int array -- no native call, no
    string work -- and a non-participating deity leaves ScoreFromTable before it
    touches anything.

    Correctness properties, in order of importance:
      - It FAILS OPEN. The cache answers "maybe" unless the manager has sealed it
        after a complete rebuild, so an old save, an interrupted load, or an
        overflow all fall back to exactly the old probing behaviour. A stale
        cache can never silently withhold piety, which is the only failure mode
        that would matter.
      - It is rebuilt in lockstep with the rows themselves: ClearRowsForDeity
        resets it, WriteLD fills it, LoadLikesDislikesTable seals it. There is no
        path that writes a row without recording it.
      - LIKES_DISLIKES_VERSION is bumped alongside this so existing saves rebuild
        the table once, which is what builds and seals the caches for them.
    Note the cache is keyed on the BASE event type, which is what both the base
    row and the origin-gated overlay row are written under -- so an origin row
    can never be missed by the early-out.
   ===================================================================== /;
Int Property LD_EVENT_CACHE_MAX = 64 AutoReadOnly
Bool _ldEventCacheSealed = false
Bool _ldEventCacheBuilding = false
Int _ldEventCacheCount = 0
Int[] _ldEventCache

Function ResetLikesDislikesEventCache()
    _ldEventCache = Utility.CreateIntArray(LD_EVENT_CACHE_MAX, -1)
    _ldEventCacheCount = 0
    _ldEventCacheSealed = false
    _ldEventCacheBuilding = true
EndFunction

Function NoteLikesDislikesEvent(Int eventType)
    ; Not inside a rebuild -- an old save whose table was written before this cache
    ; existed, or a build already abandoned below. Stay unsealed; the early-out stays
    ; off and ScoreFromTable probes StorageUtil exactly as it always did.
    if !_ldEventCacheBuilding
        return
    endIf

    Int cacheIndex = 0
    while cacheIndex < _ldEventCacheCount
        if _ldEventCache[cacheIndex] == eventType
            return
        endIf
        cacheIndex += 1
    endWhile

    if _ldEventCacheCount >= LD_EVENT_CACHE_MAX
        ; More distinct events than the array can hold. Answering "no row" for a real
        ; row would silently withhold piety, so abandon this deity's cache instead --
        ; the build is cancelled and can no longer be sealed.
        _ldEventCacheBuilding = false
        _ldEventCacheCount = 0
        return
    endIf

    _ldEventCache[_ldEventCacheCount] = eventType
    _ldEventCacheCount += 1
EndFunction

; Called by the manager only after LoadRowsForDeity has run to completion. A deity with
; no rows at all seals with count 0 and legitimately answers "no" to everything.
Function SealLikesDislikesEventCache()
    if !_ldEventCacheBuilding
        return
    endIf
    _ldEventCacheBuilding = false
    _ldEventCacheSealed = true
EndFunction

Bool Function HasLikesDislikesRowForEvent(Int eventType)
    if !_ldEventCacheSealed
        return true
    endIf

    Int cacheIndex = 0
    while cacheIndex < _ldEventCacheCount
        if _ldEventCache[cacheIndex] == eventType
            return true
        endIf
        cacheIndex += 1
    endWhile

    return false
EndFunction

Float Function ScoreFromTable(Int eventType)
    ; fix-plan 4.3: a scoring round starts clean. Anything still pending here belongs
    ; to a previous round whose caller never resolved it (a save reloaded mid-round,
    ; say), and carrying it forward would spend this event's cap slot on that one.
    DiscardPendingRepeatableActions()

    ; 12.4. The cheapest possible answer first: if this deity was never given a row
    ; for this event, nothing below can produce a score. Zero native calls, zero
    ; string work. Fails open when the cache is not sealed (see the block above).
    if !HasLikesDislikesRowForEvent(eventType)
        return 0.0
    endIf

    ; Race-eligibility gate: only deities NATIVE to the player's race score generic acts.
    if !IsRaceNativeForPlayer()
        return 0.0
    endIf

    ; 12.4. The key prefix is built AFTER both gates now. It used to be built for all
    ; ~34 deities on every broadcast event and thrown away by the race gate two lines
    ; later; a Papyrus string concat allocates and interns, so that was not free.
    Form tableDeityForm = GetDeityForm()
    String tableKeyPrefix = "PDV.LD." + eventType

    Float score = 0.0
    Float tableDelta = StorageUtil.GetFloatValue(tableDeityForm, tableKeyPrefix + ".D")
    if tableDelta != 0.0
        Int tableDailyCap = StorageUtil.GetIntValue(tableDeityForm, tableKeyPrefix + ".C")
        Float tableCooldownDays = StorageUtil.GetFloatValue(tableDeityForm, tableKeyPrefix + ".O")
        score += ScoreRepeatableAction(eventType, tableDelta, tableDailyCap, tableCooldownDays)
    endIf

    Int originRace = GetCurrentOriginRaceIndex()
    if originRace >= 0
        String originPrefix = tableKeyPrefix + ".O" + originRace
        Float originDelta = StorageUtil.GetFloatValue(tableDeityForm, originPrefix + ".D")
        if originDelta != 0.0
            Int originDailyCap = StorageUtil.GetIntValue(tableDeityForm, originPrefix + ".C")
            Float originCooldownDays = StorageUtil.GetFloatValue(tableDeityForm, originPrefix + ".O")
            score += ScoreRepeatableAction(GetOriginGatedEventType(eventType, originRace), originDelta, originDailyCap, originCooldownDays)
        endIf
    endIf

    return score
EndFunction

Int Function GetOriginGatedEventType(Int eventType, Int originRace)
    return eventType + 10000 + originRace
EndFunction

Float Function ScoreCuratedSignal(Int signalType, Form contextRef)
    return 0.0
EndFunction

Function OnTierChange(Int oldTier, Int newTier)
    SyncPatronBoonsToTier(newTier)

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " tier change: " + oldTier + " -> " + newTier)
    endIf
EndFunction

Function OnPatronStart()
    SyncPatronBoonsToTier(GetStoredTier())

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron start")
    endIf
EndFunction

Function OnPatronEnd()
    ClearAllBoons()

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] " + DeityName + " patron end")
    endIf
EndFunction

Form Function GetDeityForm()
    return Self as Form
EndFunction

Int Function GetStoredTier()
    return StorageUtil.GetFloatValue(GetDeityForm(), "PDV.Tier") as Int
EndFunction

Int Function GetStanceForPlayer()
    if PDV_GLO_OriginRace
        return GetStanceForRace(PDV_GLO_OriginRace.GetValueInt())
    endIf
    return STANCE_FOREIGN
EndFunction

Int Function GetStanceForRace(Int raceIndex)
    if raceIndex == RACE_NORD
        return Stance_Nord
    elseIf raceIndex == RACE_IMPERIAL
        return Stance_Imperial
    elseIf raceIndex == RACE_BRETON
        return Stance_Breton
    elseIf raceIndex == RACE_ALTMER
        return Stance_Altmer
    elseIf raceIndex == RACE_BOSMER
        return Stance_Bosmer
    elseIf raceIndex == RACE_DUNMER
        return Stance_Dunmer
    elseIf raceIndex == RACE_KHAJIIT
        return Stance_Khajiit
    elseIf raceIndex == RACE_ARGONIAN
        return Stance_Argonian
    elseIf raceIndex == RACE_ORSIMER
        return Stance_Orc
    elseIf raceIndex == RACE_REDGUARD
        return Stance_Redguard
    endIf

    return STANCE_FOREIGN
EndFunction

Float Function GetGainMultiplier(Int stance)
    if stance == STANCE_NATIVE
        return 1.0
    elseIf stance == STANCE_FOREIGN
        return 0.5
    elseIf stance == STANCE_TABOO
        return 0.75
    endIf

    return 1.0
EndFunction

Float Function GetTrackGainMultiplier()
    return ResolveTrackMultiplier(GainModifyingTrack, GainMultiplierPerTrackState, True)
EndFunction

Float Function GetTrackDecayMultiplier()
    return ResolveTrackMultiplier(DecayModifyingTrack, DecayMultiplierPerTrackState, False)
EndFunction

Float Function GetEffectiveGainMultiplier()
    return GetGainMultiplier(GetStanceForPlayer()) * GetTrackGainMultiplier() * GetEligibilityGainMultiplier()
EndFunction

Float Function GetEffectiveDecayMultiplier()
    return GetTrackDecayMultiplier()
EndFunction

Float Function GetEligibilityGainMultiplier()
    if IsEligibleForPlayer()
        return 1.0
    endIf

    return InactivePathGainMultiplier
EndFunction

Bool Function IsEligibleForPlayer()
    if !EligibleStateTrack
        return True
    endIf

    ; A path-eligibility track only gates its own origin race. A race that is native to a shared
    ; deity but lives outside that path system (e.g. a Khajiit venerating Baan Dar) is not "on an
    ; inactive path" and must not take the inactive-path penalty or tier cap.
    if EligibleStateTrackOriginRace >= 0 && GetCurrentOriginRaceIndex() != EligibleStateTrackOriginRace
        return True
    endIf

    return IsEligibleForState(EligibleStateTrack.GetCurrentState())
EndFunction

Int Function GetCurrentOriginRaceIndex()
    if PDV_GLO_OriginRace
        return PDV_GLO_OriginRace.GetValueInt()
    endIf

    return -1
EndFunction

Bool Function IsEligibleForState(Int currentState)
    if !EligibleStateTrack
        return True
    endIf

    Int i = 0
    while i < EligibleStateValues.Length
        if EligibleStateValues[i] == currentState
            return True
        endIf
        i += 1
    endWhile

    return False
EndFunction

Int Function GetTierCap()
    if EligibleStateTrack && !IsEligibleForPlayer()
        return TIER_DEVOTED
    endIf

    return TIER_CHAMPION
EndFunction

Int Function GetDevotionDayIndex()
    Float adjustedDayTime = Utility.GetCurrentGameTime() - DAWN_DAY_OFFSET
    return adjustedDayTime as Int
EndFunction

;/ =====================================================================
    B7 / fix-plan 4.3 -- peek/commit split
    ---------------------------------------------------------------------
    ScoreRepeatableAction used to COMMIT the Day/Count/LastFire bookkeeping the
    moment it decided to return a nonzero delta. But the delta is only a proposal:
    downstream, PDV__ManagerQuest.RunGainPipeline multiplies it by the eligibility,
    curse, stigma, survival-context, lunar and mode-preset multipliers, any one of
    which can take the award to exactly 0. Every such case burned a daily cap slot
    and started a cooldown for piety that never landed -- invisible to the player,
    and worst on a cursed or ineligible character, who is already earning nothing.

    The split: the peek decides and writes NOTHING; the commit writes. The public
    entry point keeps its old name and signature, so none of the 34 deity scripts,
    PDV_Deity_Kyne's shout branch or PDV_DaedricPathBase.ScorePrinceAction change --
    they queue a pending commit instead of performing one. The caller that knows
    whether the award actually landed (PDV__ManagerQuest.AwardPietyInternal, which
    returns the applied amount, and RouteActionToOpenPaths for the Prince lane)
    resolves the queue with CommitPendingRepeatableActions/DiscardPending...

    Two slots is the true maximum for one scoring round: ScoreFromTable can queue
    the base row plus one origin-gated row, and every other path queues exactly one.
    A third queue in the same round can only mean a caller never resolved the last
    one, so it commits immediately -- degrading to the old behaviour rather than
    silently dropping anti-farm bookkeeping.
   ===================================================================== /;
Int _pendingRepeatEventA = -1
Int _pendingRepeatEventB = -1

Float Function ScoreRepeatableAction(Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    Float allowedDelta = PeekRepeatableAction(eventType, delta, dailyCap, cooldownDays)
    if allowedDelta != 0.0
        QueueRepeatableCommit(eventType)
    endIf
    return allowedDelta
EndFunction

; Decides only. No StorageUtil writes on any path -- including the stale-day reset,
; which moved into the commit so a peek on a new day cannot zero the count for an
; award that then gets multiplied away.
Float Function PeekRepeatableAction(Int eventType, Float delta, Int dailyCap, Float cooldownDays)
    if delta == 0.0
        return 0.0
    endIf

    Form deityForm = GetDeityForm()
    String keyPrefix = "PDV.Event." + eventType
    String dayKey = keyPrefix + ".Day"
    String countKey = keyPrefix + ".Count"
    String lastFireKey = keyPrefix + ".LastFire"
    Int currentDay = GetDevotionDayIndex()
    Int currentCount = 0

    if StorageUtil.GetIntValue(deityForm, dayKey) == currentDay
        currentCount = StorageUtil.GetIntValue(deityForm, countKey)
    endIf

    if dailyCap > 0 && currentCount >= dailyCap
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] " + DeityName + " repeatable event " + eventType + " blocked by daily cap.")
        endIf
        return 0.0
    endIf

    Float lastFireTime = StorageUtil.GetFloatValue(deityForm, lastFireKey)
    if cooldownDays > 0.0 && lastFireTime > 0.0 && (Utility.GetCurrentGameTime() - lastFireTime) < cooldownDays
        if GetDebugLevel() >= 3
            Debug.Trace("[PDV] " + DeityName + " repeatable event " + eventType + " blocked by cooldown.")
        endIf
        return 0.0
    endIf

    return delta
EndFunction

; Spends the cap slot and starts the cooldown. Idempotent per call, not per round.
Function CommitRepeatableAction(Int eventType)
    Form deityForm = GetDeityForm()
    String keyPrefix = "PDV.Event." + eventType
    String dayKey = keyPrefix + ".Day"
    String countKey = keyPrefix + ".Count"
    String lastFireKey = keyPrefix + ".LastFire"
    Int currentDay = GetDevotionDayIndex()
    Int currentCount = 0

    if StorageUtil.GetIntValue(deityForm, dayKey) == currentDay
        currentCount = StorageUtil.GetIntValue(deityForm, countKey)
    endIf

    StorageUtil.SetIntValue(deityForm, dayKey, currentDay)
    StorageUtil.SetIntValue(deityForm, countKey, currentCount + 1)
    StorageUtil.SetFloatValue(deityForm, lastFireKey, Utility.GetCurrentGameTime())
EndFunction

Function QueueRepeatableCommit(Int eventType)
    if _pendingRepeatEventA < 0
        _pendingRepeatEventA = eventType
    elseIf _pendingRepeatEventB < 0
        _pendingRepeatEventB = eventType
    else
        if GetDebugLevel() >= 1
            Debug.Trace("[PDV] " + DeityName + " repeatable commit queue full at event " + eventType + "; committing inline (a caller left a round unresolved).")
        endIf
        CommitRepeatableAction(eventType)
    endIf
EndFunction

Function CommitPendingRepeatableActions()
    if _pendingRepeatEventA >= 0
        CommitRepeatableAction(_pendingRepeatEventA)
    endIf
    if _pendingRepeatEventB >= 0
        CommitRepeatableAction(_pendingRepeatEventB)
    endIf
    DiscardPendingRepeatableActions()
EndFunction

Function DiscardPendingRepeatableActions()
    _pendingRepeatEventA = -1
    _pendingRepeatEventB = -1
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function SyncPatronBoonsToTier(Int tierValue)
    ClearAllBoons()

    if !ShouldSyncLegacyPatronBoons()
        return
    endIf

    if tierValue >= TIER_SEEKER && Boon_Seeker
        Game.GetPlayer().AddSpell(Boon_Seeker, False)
    endIf
    if tierValue >= TIER_DEVOTED && Boon_Devoted
        Game.GetPlayer().AddSpell(Boon_Devoted, False)
    endIf
    if tierValue >= TIER_CHAMPION && Boon_Champion
        Game.GetPlayer().AddSpell(Boon_Champion, False)
    endIf
EndFunction

Function ClearAllBoons()
    if Boon_Seeker
        Game.GetPlayer().RemoveSpell(Boon_Seeker)
    endIf
    if Boon_Devoted
        Game.GetPlayer().RemoveSpell(Boon_Devoted)
    endIf
    if Boon_Champion
        Game.GetPlayer().RemoveSpell(Boon_Champion)
    endIf
EndFunction

Bool Function ShouldSyncLegacyPatronBoons()
    ; The manager exclusively owns Nord/Imperial focused rewards. Their T1
    ; records remain installed compatibility artifacts but are never granted.
    if PDV_GLO_OriginRace
        Int originRace = PDV_GLO_OriginRace.GetValueInt()
        if originRace == RACE_NORD || originRace == RACE_IMPERIAL
            return False
        endIf
    endIf
    return True
EndFunction

Float Function ResolveTrackMultiplier(PDV_ReputationTrack track, Float[] configuredMultipliers, Bool isGain)
    if !track
        return 1.0
    endIf

    Int stateIndex = track.GetStateIndex()
    if configuredMultipliers.Length > stateIndex && stateIndex >= 0
        return configuredMultipliers[stateIndex]
    endIf

    return GetFallbackTrackMultiplier(track, stateIndex, isGain)
EndFunction

Float Function GetFallbackTrackMultiplier(PDV_ReputationTrack track, Int stateIndex, Bool isGain)
    if !track
        return 1.0
    endIf

    if DeityName == "Talos" && track.TrackName == "ConcordatStanding"
        if isGain
            if stateIndex == 0
                return 1.5
            elseIf stateIndex == 1
                return 1.25
            elseIf stateIndex == 3
                return 0.75
            elseIf stateIndex >= 4
                return 0.5
            endIf
        elseIf stateIndex == 3
            return 1.25
        elseIf stateIndex >= 4
            return 1.5
        endIf
    endIf

    return 1.0
EndFunction
