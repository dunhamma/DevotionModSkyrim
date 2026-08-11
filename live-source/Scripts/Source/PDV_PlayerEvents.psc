;/
    PDV_PlayerEvents.psc
    PlayerDevotion - player alias event ingress
    -----------------------------------------------------------------------
    Player-attached alias script for low-noise runtime signal ingress.
    This stage wires sleep-based Khajiit moon observance through EventBus
    and leaves the rest of the future player-event surface compile-clean
    for CK alias attachment.
    -----------------------------------------------------------------------
/;

Scriptname PDV_PlayerEvents extends ReferenceAlias

PDV_EventBus Property PDV_EventBusService Auto
PDV_Origin Property PDV_OriginQuest Auto
PDV_ActionRouter Property PDV_RouterService Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto

FormList Property PDV_FLST_P2_BretonKnightsRoadSources Auto
FormList Property PDV_FLST_P2_BretonHiddenArtSources Auto
FormList Property PDV_FLST_P2_BretonGreenWaySources Auto
FormList Property PDV_FLST_P2_BretonVowSources Auto
FormList Property PDV_FLST_P2_BretonHiddenArtSpells Auto
FormList Property PDV_FLST_P2_BretonGreenWayHarvests Auto
FormList Property PDV_FLST_P2_DunmerAzuraSources Auto
FormList Property PDV_FLST_P2_DunmerBoethiahSources Auto
FormList Property PDV_FLST_P2_DunmerMephalaSources Auto
FormList Property PDV_FLST_P2_DunmerDeviationSources Auto
FormList Property PDV_FLST_P2_ImperialCivicSources Auto
FormList Property PDV_FLST_P2_ImperialPublicServiceSources Auto
FormList Property PDV_FLST_P2_ImperialMercySources Auto
FormList Property PDV_FLST_P2_ImperialLawfulOrderSources Auto
FormList Property PDV_FLST_P2_ImperialHonestWorkSources Auto
FormList Property PDV_FLST_P2_ImperialDeathDutySources Auto
FormList Property PDV_FLST_P2_ImperialPrivateTalosSources Auto
FormList Property PDV_FLST_P2_ImperialPublicTalosSources Auto
FormList Property PDV_FLST_P2_ImperialPatronCivicSources Auto
FormList Property PDV_FLST_P2_NordOldWaysSources Auto
FormList Property PDV_FLST_P2_NordKyneTalosSources Auto
FormList Property PDV_FLST_P2_NordHircineArkaySources Auto
FormList Property PDV_FLST_P2_AltmerAurielSources Auto
FormList Property PDV_FLST_P2_AltmerMagnusSources Auto
FormList Property PDV_FLST_P2_AltmerXarxesSources Auto
; P7 (2026-08-03). MUST be bound in the CK/ESP to 0716E1:Devotion.esp. An unbound property is None,
; HasListedForm returns false, and the whole Trinimac book route no-ops SILENTLY -- no error, no trace.
FormList Property PDV_FLST_P2_AltmerTrinimacSources Auto
; P9 (2026-08-03). Both MUST be bound in the ESP or their routes no-op silently.
; Bound: CureEffects -> 0716E2:Devotion.esp, SyrabaneSources -> 0716E3:Devotion.esp.
FormList Property PDV_FLST_Altmer_Syrabane_CureEffects Auto
FormList Property PDV_FLST_P2_AltmerSyrabaneSources Auto
FormList Property PDV_FLST_P2_AltmerLorkhanPenalties Auto
FormList Property PDV_FLST_P2_ArgonianHistSources Auto
FormList Property PDV_FLST_P2_ArgonianCommunitySources Auto
FormList Property PDV_FLST_P2_ArgonianSithisSources Auto
FormList Property PDV_FLST_P2_BosmerYffreSources Auto
FormList Property PDV_FLST_P2_BosmerZenSources Auto
FormList Property PDV_FLST_P2_BosmerBaanDarSources Auto
FormList Property PDV_FLST_P2_KhajiitLunarSources Auto
FormList Property PDV_FLST_P2_KhajiitFocusedSources Auto
FormList Property PDV_FLST_P2_OrcMalacathSources Auto
FormList Property PDV_FLST_P2_RedguardSpineSources Auto
FormList Property PDV_FLST_P2_RedguardCrownSources Auto
FormList Property PDV_FLST_P2_RedguardForebearSources Auto
FormList Property PDV_FLST_P2_RedguardAshAbahSources Auto
FormList Property PDV_FLST_Daedric_AzuraLiveSources Auto
FormList Property PDV_FLST_Daedric_BoethiahLiveSources Auto
FormList Property PDV_FLST_Daedric_VaerminaLiveSources Auto
FormList Property PDV_FLST_Daedric_MeridiaLiveSources Auto
FormList Property PDV_FLST_Daedric_MolagLiveSources Auto
FormList Property PDV_FLST_Daedric_MephalaLiveSources Auto
FormList Property PDV_FLST_Daedric_HircineLiveSources Auto
FormList Property PDV_FLST_Daedric_MalacathLiveSources Auto
FormList Property PDV_FLST_Daedric_DagonLiveSources Auto
FormList Property PDV_FLST_Daedric_SheoLiveSources Auto
FormList Property PDV_FLST_Daedric_NamiraLiveSources Auto
FormList Property PDV_FLST_Daedric_SanguineLiveSources Auto
FormList Property PDV_FLST_Daedric_VileLiveSources Auto
FormList Property PDV_FLST_Daedric_MoraLiveSources Auto
FormList Property PDV_FLST_Daedric_NocturnalLiveSources Auto
FormList Property PDV_FLST_Daedric_PeryiteLiveSources Auto
FormList Property PDV_FLST_GreenPact_PlantFoods Auto
FormList Property PDV_FLST_GreenPact_MeatFoods Auto
FormList Property PDV_FLST_GreenPact_FungiFoods Auto
FormList Property PDV_FLST_GreenPact_EggFoods Auto
FormList Property PDV_FLST_GreenPact_InsectFoods Auto
Keyword Property PDV_KW_GreenPact_Plant Auto
Keyword Property PDV_KW_GreenPact_Meat Auto
Keyword Property PDV_KW_GreenPact_Fungi Auto
Keyword Property PDV_KW_GreenPact_Egg Auto
Keyword Property PDV_KW_GreenPact_Insect Auto

FormList Property PDV_FLST_FaucetSkillBooks Auto
FormList Property PDV_FLST_FaucetSpellTomes Auto
FormList Property PDV_FLST_FaucetDaedricArtifacts Auto
FormList Property PDV_FLST_FaucetRaiseUndeadEffects Auto

FormList Property PDV_FLST_AlkoshNamedDragons Auto
FormList Property PDV_FLST_RajhinNotableTargets Auto
Keyword Property ActorTypeDragon Auto
ActorBase Property Paarthurnax Auto

Int Property MQ305_FORM_ID = 0x00046EF2 AutoReadOnly
String Property QUEST_REACTION_MATRIX_FILE = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix" AutoReadOnly
String Property QUEST_REACTION_CHANNEL_FOLDER = "../StorageUtilData/PlayerDevotion/Channels" AutoReadOnly
String Property QUEST_REACTION_STAGE_ADAPTER_FOLDER = "../StorageUtilData/PlayerDevotion/QuestStageAdapters" AutoReadOnly

String Property MOD_EVENT_CONCORDAT_COMPLIANCE = "PDV.ConcordatCompliance" AutoReadOnly
String Property MOD_EVENT_CONCORDAT_DEFIANCE = "PDV.ConcordatDefiance" AutoReadOnly

Int Property EVT_REST_UNDER_OPEN_SKY = 313 AutoReadOnly
Int Property EVT_SLEEP_IN_BED = 314 AutoReadOnly
Int Property EVT_SLEEP_IN_INN = 315 AutoReadOnly
Int Property EVT_HARVEST_INGREDIENT = 334 AutoReadOnly
Int Property EVT_READ_SKILL_BOOK = 340 AutoReadOnly
Int Property EVT_READ_SPELL_TOME = 341 AutoReadOnly
Int Property EVT_READ_LORE_BOOK = 342 AutoReadOnly
Int Property EVT_PICK_OWNED_LOCK = 360 AutoReadOnly
Int Property EVT_RAISE_UNDEAD = 365 AutoReadOnly
Int Property EVT_ACCEPT_DAEDRIC_ARTIFACT = 368 AutoReadOnly

; 12.2 / audit C2 -- the resolved faucet-form cache.
;
; ShouldRouteQuestReactionFaucet used to answer "is this form in faucet list X?" by
; re-reading the matrix JSON and re-resolving every entry from scratch, on every call.
; RouteQuestReactionObjectFaucet asks that question 16 times per EQUIP, over 52 matrix
; entries, and each entry cost a Game.GetModByName -- a linear scan over the whole plugin
; list -- plus a Game.GetFormFromFile, on top of a JsonExists, two JsonUtil.GetStringValue
; reads and two StringUtil.Splits per key. In a large load order that is hundreds of
; native calls and an enormous number of engine-side plugin-name comparisons for every
; item the player equips, and the blocked-hit (Peryite) path paid the same shape on every
; blocked hit -- constant and constant-cost for a shield user.
;
; The spell faucet below was already cached correctly at registration; this mirrors it for
; the object / book / magic-effect / blocked-hit faucets. Every faucet form is resolved
; ONCE in RegisterQuestReactionFaucetEvents (so once per load, where GetModByName is
; cheap and correct) into two parallel arrays, and the hot path becomes a script-local
; scan with ZERO native calls. The Form compare is written first in the && so the string
; compare only runs on the rare form hit.
;
; The array is sized 128 (the Papyrus ceiling) and a truncation is traced rather than
; swallowed.
Int Property QUEST_REACTION_FAUCET_CACHE_MAX = 128 AutoReadOnly
Bool PDV_QuestReactionFaucetCacheReady = false
Int PDV_QuestReactionFaucetCacheCount = 0
Form[] PDV_QuestReactionFaucetForms
String[] PDV_QuestReactionFaucetListKeys

Bool PDV_QuestReactionSpellFaucetCacheReady = false
Form PDV_QRSpellSanguine0 = None
Form PDV_QRSpellSanguine1 = None
Form PDV_QRSpellVaermina0 = None
Form PDV_QRSpellVaermina1 = None
Form PDV_QRSpellSheogorathFire0 = None
Form PDV_QRSpellSheogorathFire1 = None

Bool PDV_LastSleepStartedOutside = false
Bool PDV_LastSleptInInn = false
Bool PDV_HasSleepStartContext = false
Keyword PDV_KW_LocTypeInn
ObjectReference PDV_LockpickMenuTargetRef = None
Bool PDV_LockpickMenuTargetWasLocked = false

; Organic combat-session state. Session counters are script variables:
; combat-state, PO3 kill events, and the combat poll all land on this alias, so
; no cross-script storage is needed.
Bool PDV_CombatSessionActive = false
Bool PDV_CombatStartedSneaking = false
Bool PDV_CombatObservedSneaking = false
Int PDV_CombatSessionKills = 0
Int PDV_CombatMaxLevelDelta = 0
Bool PDV_CombatLowHealthFlag = false
Bool PDV_CombatNearFatalFlag = false
; P9 (2026-08-03): set when any spell hits the player during a session (Syrabane 3113).
Bool PDV_CombatMageThreatFlag = false
Bool PDV_CombatBelowHealthRouted = false
Bool PDV_OriginQueuedThisLoad = false

; 1.0.4 scheduler. These are additive, save-compatible variables: each lane
; owns one real-time deadline, while this script owns one native update
; registration for the earliest outstanding lane. They are reset on every load
; because Utility.GetCurrentRealTime() restarts with the process.
Float PDV_ORIGIN_NEXT_DUE = -1.0
Float PDV_COMBAT_NEXT_DUE = -1.0
Float PDV_BARD_NEXT_DUE = -1.0
Float PDV_UPDATE_ARMED_DUE = -1.0
Bool PDV_UPDATE_ARMED = false
Bool PDV_UPDATE_DISPATCHING = false

; Khajiit caravan-defense detector forms (Khenarthi CARAVAN_AID). Resolved once
; per load via GetFormFromFile; script variables so no VMAD property fill is
; needed. The three caravan leaders' persistent refs are the proximity anchors.
Bool PDV_CaravanFormsResolved = false
Faction PDV_KhajiitCaravanFactionRef = None
ObjectReference PDV_CaravanLeaderRisaad = None
ObjectReference PDV_CaravanLeaderAhkari = None
ObjectReference PDV_CaravanLeaderMadran = None

; 12.3 / audit C3. The bard poll's cadence is now two-state: BARD_POLL_ACTIVE_INTERVAL
; while a performance is live (or just ended), BARD_POLL_IDLE_INTERVAL otherwise, after
; BARD_POLL_QUIET_TICKS_TO_IDLE consecutive nothing-happened ticks. See
; BardPerformancePollTick for why this is a cadence change and not a hard event gate.
Float Property BARD_POLL_ACTIVE_INTERVAL = 5.0 AutoReadOnly
Float Property BARD_POLL_IDLE_INTERVAL = 15.0 AutoReadOnly
Int Property BARD_POLL_QUIET_TICKS_TO_IDLE = 2 AutoReadOnly

Bool PDV_BardFormsResolved = false
Bool PDV_BardPollActive = false
Int PDV_BardQuietTicks = 0
GlobalVariable PDV_BardIsPlaying = None
FormList PDV_BardTavernCounts = None
GlobalVariable PDV_BardGameDaysPassed = None
GlobalVariable PDV_BardSgtLute = None
GlobalVariable PDV_BardSgtFlute = None
GlobalVariable PDV_BardSgtDrum = None
GlobalVariable PDV_BardSgtOvation = None
Float PDV_BardLastLute = 0.0
Float PDV_BardLastFlute = 0.0
Float PDV_BardLastDrum = 0.0
Int PDV_BardLastPlaying = 0
Float PDV_BardLastRouteRealTime = -100.0

Event OnInit()
    ResetUpdateScheduler()
    PDV_OriginQueuedThisLoad = false
    PDV_BardFormsResolved = false
    RegisterForPlayerEvents()
    StartBardPerformancePoll()
    QueueOriginInitialization()
    RouteCurseRefresh("alias_init")
    Trace(2, "Player alias initialized.")
EndEvent

Event OnPlayerLoadGame()
    ResetUpdateScheduler()
    PDV_OriginQueuedThisLoad = false
    PDV_BardFormsResolved = false
    RegisterForPlayerEvents()
    StartBardPerformancePoll()
    QueueOriginInitialization()
    RouteCurseRefresh("load")
    RoutePaarthurnaxSpareLoadCheck()
    KickstartDevotionLifecycle()
    Trace(2, "Player load observed; sleep hooks refreshed.")
EndEvent

; B3 / fix-plan Group 2. The manager's 1s master poll and the quest-reaction worker are
; single-update chains, each re-armed ONLY at the end of its own OnUpdate. Both live on
; Quest scripts, which never receive OnPlayerLoadGame (it is alias-only) -- so the
; worker's own load-resume handler is dead code and nothing re-kicks the manager. A
; single tick lost to a Papyrus stack dump (routine under VM saturation in a large list)
; permanently stopped dawn processing, pact activation, the startup choice and the
; reconcile for the rest of the playthrough.
;
; This alias IS a player alias and does receive the event, so it is the watchdog. Both
; calls are idempotent: re-registering a single update merely resets the timer.
Function KickstartDevotionLifecycle()
    if !PDV_EventBusService
        Trace(1, "Lifecycle kickstart skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV__ManagerQuest managerService = PDV_EventBusService.PDV_Manager
    if !managerService
        Trace(1, "Lifecycle kickstart skipped: PDV_Manager not assigned on the event bus.")
        return
    endIf

    managerService.KickstartIfStalled()
EndFunction

Event OnUpdate()
    ; Consume only lanes whose deadline has arrived, then arm exactly once for
    ; the earliest deadline left by those lane handlers.
    PDV_UPDATE_ARMED = false
    PDV_UPDATE_ARMED_DUE = -1.0
    PDV_UPDATE_DISPATCHING = true
    Float nowRealTime = Utility.GetCurrentRealTime()

    if PDV_BARD_NEXT_DUE >= 0.0 && PDV_BARD_NEXT_DUE <= nowRealTime + 0.05
        PDV_BARD_NEXT_DUE = -1.0
        if PDV_BardPollActive
            BardPerformancePollTick()
        endIf
    endIf

    if PDV_COMBAT_NEXT_DUE >= 0.0 && PDV_COMBAT_NEXT_DUE <= nowRealTime + 0.05
        PDV_COMBAT_NEXT_DUE = -1.0
        if PDV_CombatSessionActive
            CombatPollTick()
        endIf
    endIf

    if PDV_ORIGIN_NEXT_DUE >= 0.0 && PDV_ORIGIN_NEXT_DUE <= nowRealTime + 0.05
        PDV_ORIGIN_NEXT_DUE = -1.0
        OriginPollTick()
    endIf

    PDV_UPDATE_DISPATCHING = false
    ArmEarliestDeadline()
EndEvent

Function OriginPollTick()
    Bool originQueued = PDV_OriginQueuedThisLoad
    if originQueued
        PDV_OriginQueuedThisLoad = false
    endIf

    if GetOriginRaceValue() >= 0 && !originQueued
        return
    endIf

    if !IsOriginCaptureSafe()
        if originQueued
            PDV_OriginQueuedThisLoad = true
        endIf
        ScheduleOriginDeadline(2.0)
        Trace(2, "Origin capture waiting for playable controls.")
        return
    endIf

    EnsureOriginInitialized()

    if GetOriginRaceValue() < 0
        ScheduleOriginDeadline(2.0)
        Trace(2, "Origin still unresolved; retry queued.")
    elseIf originQueued
        Trace(2, "Origin re-check completed.")
    else
        Trace(2, "Origin initialization completed.")
    endIf
EndFunction

Function ResetUpdateScheduler()
    UnregisterForUpdate()
    PDV_ORIGIN_NEXT_DUE = -1.0
    PDV_COMBAT_NEXT_DUE = -1.0
    PDV_BARD_NEXT_DUE = -1.0
    PDV_UPDATE_ARMED_DUE = -1.0
    PDV_UPDATE_ARMED = false
    PDV_UPDATE_DISPATCHING = false
EndFunction

Function ScheduleOriginDeadline(Float delaySeconds)
    PDV_ORIGIN_NEXT_DUE = Utility.GetCurrentRealTime() + delaySeconds
    ArmEarliestDeadline()
EndFunction

Function ScheduleCombatDeadline(Float delaySeconds)
    PDV_COMBAT_NEXT_DUE = Utility.GetCurrentRealTime() + delaySeconds
    ArmEarliestDeadline()
EndFunction

Function ScheduleBardDeadline(Float delaySeconds)
    PDV_BARD_NEXT_DUE = Utility.GetCurrentRealTime() + delaySeconds
    ArmEarliestDeadline()
EndFunction

Float Function GetEarliestPendingDeadline()
    Float earliest = -1.0
    if PDV_ORIGIN_NEXT_DUE >= 0.0
        earliest = PDV_ORIGIN_NEXT_DUE
    endIf
    if PDV_COMBAT_NEXT_DUE >= 0.0 && (earliest < 0.0 || PDV_COMBAT_NEXT_DUE < earliest)
        earliest = PDV_COMBAT_NEXT_DUE
    endIf
    if PDV_BARD_NEXT_DUE >= 0.0 && (earliest < 0.0 || PDV_BARD_NEXT_DUE < earliest)
        earliest = PDV_BARD_NEXT_DUE
    endIf
    return earliest
EndFunction

Function ArmEarliestDeadline()
    if PDV_UPDATE_DISPATCHING
        return
    endIf

    Float earliest = GetEarliestPendingDeadline()
    if earliest < 0.0
        if PDV_UPDATE_ARMED
            UnregisterForUpdate()
        endIf
        PDV_UPDATE_ARMED = false
        PDV_UPDATE_ARMED_DUE = -1.0
        return
    endIf

    ; A later lane does not disturb an earlier armed deadline. A newly earlier
    ; lane explicitly replaces the one native single-update registration.
    if PDV_UPDATE_ARMED && earliest >= PDV_UPDATE_ARMED_DUE - 0.05
        return
    endIf

    if PDV_UPDATE_ARMED
        UnregisterForUpdate()
    endIf

    Float delaySeconds = earliest - Utility.GetCurrentRealTime()
    if delaySeconds < 0.1
        delaySeconds = 0.1
    endIf
    RegisterForSingleUpdate(delaySeconds)
    PDV_UPDATE_ARMED = true
    PDV_UPDATE_ARMED_DUE = earliest
EndFunction

Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
    Actor playerActor = GetActorRef()
    PDV_HasSleepStartContext = false
    if playerActor
        PDV_LastSleepStartedOutside = !playerActor.IsInInterior()
        PDV_LastSleptInInn = IsPlayerInInn(playerActor)
        PDV_HasSleepStartContext = true
    else
        PDV_LastSleepStartedOutside = false
        PDV_LastSleptInInn = false
    endIf

    Trace(3, "Player sleep start observed.")
EndEvent

Event OnSleepStop(Bool abInterrupted)
    ; Snapshot and clear the start context before any cross-script call can yield.
    ; A stop event without a matching start must fail closed instead of reusing an
    ; exterior flag left behind by an earlier sleep.
    Actor playerActor = GetActorRef()
    Bool hadSleepStartContext = PDV_HasSleepStartContext
    Bool sleepStartedOutside = PDV_LastSleepStartedOutside
    Bool sleptInInn = PDV_LastSleptInInn
    PDV_HasSleepStartContext = false
    PDV_LastSleepStartedOutside = false
    PDV_LastSleptInInn = false

    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "Player sleep stop skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteSleepStop(playerActor, abInterrupted, hadSleepStartContext, sleepStartedOutside)

    if !abInterrupted && hadSleepStartContext
        if sleepStartedOutside
            RouteGenericAction(EVT_REST_UNDER_OPEN_SKY, playerActor as Form, None)
        else
            RouteGenericAction(EVT_SLEEP_IN_BED, playerActor as Form, None)
            ; The ascetic-creed sleep penalty bites only on paid inn comfort ("slumbering
            ; easy"), not your own bed or a bedroll. Inn sleep also fires EVT_SLEEP_IN_INN so
            ; only the inn-keyed dislike rows score; positive sleep credit stays on EVT_SLEEP_IN_BED.
            if sleptInInn
                RouteGenericAction(EVT_SLEEP_IN_INN, playerActor as Form, None)
            endIf
        endIf
    elseIf !abInterrupted
        Trace(1, "Player sleep stop had no captured start context; sleep classification skipped.")
    endIf
EndEvent

; Inn detection for the ascetic sleep-creed penalty. An inn is the player's current
; Location carrying the vanilla LocTypeInn keyword (Skyrim.esm 0x0001CB87), resolved by
; FormID so no new CK property wiring is needed. Cached after first resolve.
Bool Function IsPlayerInInn(Actor playerActor)
    if !playerActor
        return false
    endIf
    Location currentLoc = playerActor.GetCurrentLocation()
    if !currentLoc
        return false
    endIf
    if !PDV_KW_LocTypeInn
        PDV_KW_LocTypeInn = Game.GetFormFromFile(0x0001CB87, "Skyrim.esm") as Keyword
    endIf
    if !PDV_KW_LocTypeInn
        return false
    endIf
    return currentLoc.HasKeyword(PDV_KW_LocTypeInn)
EndFunction

Event OnLycanthropyStateChanged(Bool abIsWerewolf)
    if abIsWerewolf
        RouteCurseRefresh("lycanthropy_on")
    else
        RouteCurseRefresh("lycanthropy_off")
    endIf
EndEvent

Event OnVampirismStateChanged(Bool abIsVampire)
    if abIsVampire
        RouteCurseRefresh("vampirism_on")
    else
        RouteCurseRefresh("vampirism_off")
    endIf
EndEvent

Event OnShoutAttack(Shout akShout)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "Shout attack skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteShoutAttack(GetActorRef(), akShout)
EndEvent

Event OnBookRead(Book akBook)
    if !akBook
        return
    endIf

    if !PDV_EventBusService
        Trace(1, "Book read skipped: PDV_EventBusService not assigned.")
        return
    endIf

    ; Once-ever per book base form: repeat reads never award generic or daily-faucet
    ; piety again. Marked only after the bus check so a dropped event cannot burn
    ; the book's single credit.
    Bool firstRead = MarkGenericBookRead(akBook as Form)
    String logicalEventId = "book_" + akBook.GetFormID()
    PDV_EventBusService.BeginLogicalDevotionalAct(logicalEventId)
    RouteGenericBookRead(akBook, firstRead, logicalEventId)
    RouteP2ImmersiveSource(akBook as Form, "po3_book", logicalEventId)
    RouteQuestReactionBookFaucet(akBook as Form, firstRead)
    ; Altmer "read banned texts": The Talos Mistake (Skyrim.esm:000ED04D) pushes the
    ; ThalmorAlignment track toward the heterodox pole. Manager enforces origin + one-shot.
    if akBook.GetFormID() == 0x000ED04D
        PDV_EventBusService.RouteAltmerAlignmentSignal("read_banned_texts", akBook as Form, "po3_book_talos_mistake")
    endIf
    PDV_EventBusService.FlushLogicalDevotionalAct()
EndEvent

Event OnSpellLearned(Spell akSpell)
    RouteP2ImmersiveSource(akSpell as Form, "po3_spell")
EndEvent

Event OnItemHarvested(Form akProduce)
    ; Guard the payload before dereferencing it. A None produce aborts the
    ; handler mid-way in Papyrus (logged, not a CTD) and silently drops the
    ; harvest credit, so fail fast and say why instead.
    if !akProduce
        Trace(1, "Harvest skipped: produce form was None.")
        return
    endIf

    if PDV_EventBusService
        String logicalEventId = "harvest_" + akProduce.GetFormID()
        PDV_EventBusService.BeginLogicalDevotionalAct(logicalEventId)
        RouteGenericAction(EVT_HARVEST_INGREDIENT, GetActorRef() as Form, akProduce, logicalEventId)
        RouteP2ImmersiveSource(akProduce, "po3_harvest", logicalEventId)
    else
        RouteGenericAction(EVT_HARVEST_INGREDIENT, GetActorRef() as Form, akProduce)
        RouteP2ImmersiveSource(akProduce, "po3_harvest")
    endIf
    if PDV_EventBusService
        PDV_EventBusService.FlushLogicalDevotionalAct()
    endIf
EndEvent

Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)
    RouteP2ImmersiveSource(akNewWeather as Form, "po3_weather")
EndEvent

Event OnItemCrafted(ObjectReference akBench, Location akLocation, Form akCreatedItem)
    ; SKSE-delivered crafting signal (po3 Papyrus Extender). Replaces the
    ; Story Manager Craft Item receiver (PDV__SM_CraftItem): the engine's
    ; native StoryEventArguments marshalling for that event CTDs on
    ; tempering (issue #17, reproduced on 1.0.1), so the quest is detached
    ; from its Story Manager node and crafting arrives here instead.
    if !PDV_RouterService
        ResolveRouterService()
    endIf
    if !PDV_RouterService
        Trace(1, "Item crafted skipped: PDV_RouterService not assigned.")
        return
    endIf

    ; Level-1 trace on purpose: this is the proof line for the issue #17
    ; retest. createdItem=0 distinguishes a temper (nothing created) from a
    ; creation, which is exactly the case po3 delivery has to be checked for.
    Int createdId = 0
    if akCreatedItem
        createdId = akCreatedItem.GetFormID()
    endIf
    Int benchId = 0
    if akBench
        benchId = akBench.GetFormID()
    endIf
    Trace(1, "Item crafted: bench=" + benchId + ", createdItem=" + createdId + ".")

    PDV_RouterService.HandleStoryCraftItem(akBench, akLocation, akCreatedItem)
EndEvent

Event OnQuestStageChange(Quest akQuest, Int aiNewStage)
    if PDV_EventBusService && akQuest
        String logicalEventId = "quest_" + akQuest.GetFormID() + "_" + aiNewStage
        PDV_EventBusService.BeginLogicalDevotionalAct(logicalEventId)
        RouteP2ImmersiveQuestStage(akQuest, aiNewStage, logicalEventId)
        RouteQuestReactionStage(akQuest, aiNewStage, logicalEventId)
    else
        RouteP2ImmersiveQuestStage(akQuest, aiNewStage)
        RouteQuestReactionStage(akQuest, aiNewStage)
    endIf
    RoutePaarthurnaxSpareQuestStage(akQuest, aiNewStage)
    RouteCuratedMilestoneQuestStage(akQuest, aiNewStage)
    if PDV_EventBusService && akQuest
        PDV_EventBusService.FlushLogicalDevotionalAct()
    endIf
EndEvent

Event OnPDVConcordatCompliance(String eventName, String strArg, Float numArg, Form sender)
    if !PDV_EventBusService
        Trace(1, "Concordat compliance mod event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteConcordatPressure(true)
    Trace(2, "Concordat compliance mod event routed.")
EndEvent

Event OnPDVConcordatDefiance(String eventName, String strArg, Float numArg, Form sender)
    if !PDV_EventBusService
        Trace(1, "Concordat defiance mod event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteConcordatPressure(false)
    Trace(2, "Concordat defiance mod event routed.")
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    RouteBosmerGreenPactFood(akBaseObject)
    ; Sleeping Tree Sap (dunSleepingTreeCampSap, Skyrim.esm) is a one-shot
    ; Argonian vision source; the manager enforces origin and the one-shot.
    if akBaseObject && akBaseObject.GetFormID() == 0x000AED90 && PDV_EventBusService
        PDV_EventBusService.RouteArgonianSapVision()
    endIf
    if HasListedForm(PDV_FLST_FaucetDaedricArtifacts, akBaseObject)
        RouteGenericAction(EVT_ACCEPT_DAEDRIC_ARTIFACT, GetActorRef() as Form, akBaseObject)
        ; Altmer "consort with Daedra": equipping a Daedric artifact pushes ThalmorAlignment
        ; toward heterodox. Manager enforces origin + one-shot per distinct artifact.
        if PDV_EventBusService
            PDV_EventBusService.RouteAltmerAlignmentSignal("consort_with_daedra", akBaseObject, "daedric_artifact_equip")
        endIf
    endIf
    RouteQuestReactionObjectFaucet(akBaseObject)
EndEvent

Event OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, Bool abApplied)
    if !abApplied
        return
    endIf

    ; NOTE: raise-undead is NOT detected here. PO3 MagicEffectApplyEx is TARGET-side (the
    ; registered alias only hears effects applied TO it - that is why the payload carries
    ; akCaster and no target), so reanimation, which lands on the corpse, never reaches the
    ; player. PO3 OnActorReanimateStart also proved dead in game. Detection now lives in
    ; OnSpellCast, a caster-side vanilla event - same reliable-direct-hook approach as the
    ; spell-tome OnItemRemoved and lockpick-menu fixes.
    RouteQuestReactionMagicEffectFaucet(akEffect as Form)

    ; P9 (2026-08-03): Syrabane's curse/disease warding (3112). Target-side is exactly right here --
    ; the note above explains this event only hears effects applied TO the player, which is precisely
    ; "a cure landed on me". All four listed vanilla effects are TargetType=Self, so they fire on the
    ; actor being cured. The manager owns the origin, curse and daily gates.
    if PDV_EventBusService && HasListedForm(PDV_FLST_Altmer_Syrabane_CureEffects, akEffect as Form)
        PDV_EventBusService.RouteAltmerSyrabaneCureWard("magiceffect")
    endIf
EndEvent

Event OnSpellCast(Form akSpell)
    ; Caster-side raise-undead detection. Fires on the PLAYER when the player casts a spell
    ; (the alias forwards ObjectReference.OnSpellCast automatically - no PO3 registration).
    ; Reuse the raise-undead effect FormList by matching the cast spell's own effects, so no
    ; new SPELL FormList / ESP work is needed. Manager scores by event type + applies caps.
    RouteQuestReactionSpellFaucet(akSpell)

    Spell castSpell = akSpell as Spell
    if castSpell && SpellHasRaiseUndeadEffect(castSpell)
        Trace(2, "Raise-undead cast detected: " + castSpell.GetName())
        RouteGenericAction(EVT_RAISE_UNDEAD, GetActorRef() as Form, akSpell)
    endIf
EndEvent

Bool Function SpellHasRaiseUndeadEffect(Spell castSpell)
    if !castSpell || !PDV_FLST_FaucetRaiseUndeadEffects
        return false
    endIf

    Int index = 0
    Int count = castSpell.GetNumEffects()
    while index < count
        MagicEffect effectRef = castSpell.GetNthEffectMagicEffect(index)
        if effectRef && HasListedForm(PDV_FLST_FaucetRaiseUndeadEffects, effectRef as Form)
            return true
        endIf
        index += 1
    endWhile
    return false
EndFunction

Event OnHitEx(ObjectReference akAggressor, Form akSource, Projectile akProjectile, Bool abPowerAttack, Bool abSneakAttack, Bool abBashAttack, Bool abHitBlocked)
    Actor playerRef = GetActorRef()
    if playerRef && playerRef.IsInCombat()
        if !PDV_CombatSessionActive
            BeginCombatSession()
        endIf
        if PDV_CombatSessionActive
            SampleCombatHealth(playerRef, "hit")
        endIf
    endIf

    ; P9: mage-threat flag for Syrabane's anti-mage survival (3113). Set on ANY spell hit, blocked
    ; or not -- surviving a mage is the beat, not blocking one. Reset per session in BeginCombatSession.
    if akSource as Spell
        PDV_CombatMageThreatFlag = true
    endIf

    if !abHitBlocked
        return
    endIf

    RouteQuestReactionBlockedHitFaucet()

    ; P9: Syrabane's protective warding (3110). Deliberately NOT a cast counter -- his design
    ; contract rejects "every ward cast". This requires a block that actually stopped MAGIC, so
    ; akSource must be a Spell; a blocked sword swing is not warding. Zero new records.
    if PDV_EventBusService && (akSource as Spell)
        PDV_EventBusService.RouteAltmerSyrabaneProtectiveWard("blocked_spell")
    endIf
EndEvent

Function RouteGenericBookRead(Book akBook, Bool firstRead, String logicalEventId = "")
    if !akBook
        return
    endIf

    if !firstRead
        Trace(2, "Generic book read repeat skipped: " + akBook.GetFormID())
        return
    endIf

    if HasListedForm(PDV_FLST_FaucetSkillBooks, akBook as Form)
        RouteGenericAction(EVT_READ_SKILL_BOOK, GetActorRef() as Form, akBook as Form, logicalEventId)
    elseIf HasListedForm(PDV_FLST_FaucetSpellTomes, akBook as Form)
        RouteGenericAction(EVT_READ_SPELL_TOME, GetActorRef() as Form, akBook as Form, logicalEventId)
    else
        RouteGenericAction(EVT_READ_LORE_BOOK, GetActorRef() as Form, akBook as Form, logicalEventId)
    endIf
EndFunction

Function RouteGenericAction(Int eventType, Form actorForm, Form targetForm, String logicalEventId = "")
    if !PDV_EventBusService
        Trace(1, "Generic faucet event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteAction(eventType, actorForm, targetForm, logicalEventId)
EndFunction

Function RouteBosmerGreenPactFood(Form baseObject)
    if !baseObject || !PDV_EventBusService
        return
    endIf

    if GetOriginRaceValue() != 4
        return
    endIf

    Potion foodItem = baseObject as Potion
    if !foodItem || !foodItem.IsFood()
        return
    endIf

    if FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_PlantFoods, PDV_KW_GreenPact_Plant)
        PDV_EventBusService.RouteGreenPactViolation()
        Trace(2, "Green Pact plant food violation routed.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_MeatFoods, PDV_KW_GreenPact_Meat)
        PDV_EventBusService.RouteBosmerPactPositive()
        Trace(2, "Green Pact meat food positive routed.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_FungiFoods, PDV_KW_GreenPact_Fungi)
        Trace(3, "Green Pact fungi food ignored.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_EggFoods, PDV_KW_GreenPact_Egg)
        Trace(3, "Green Pact egg food ignored.")
    elseIf FormMatchesListOrKeyword(baseObject, PDV_FLST_GreenPact_InsectFoods, PDV_KW_GreenPact_Insect)
        PDV_EventBusService.RouteBosmerPactPositive()
        Trace(2, "Green Pact insect food positive routed.")
    endIf
EndFunction

Bool Function FormMatchesListOrKeyword(Form baseObject, FormList listRef, Keyword keywordRef)
    if listRef && listRef.HasForm(baseObject)
        return true
    endIf

    if keywordRef && baseObject.HasKeyword(keywordRef)
        return true
    endIf

    return false
EndFunction

Event OnLevelIncrease(Int aiLevel)
    if PDV_EventBusService && PDV_EventBusService.PDV_Manager
        PDV_EventBusService.PDV_Manager.HandleWayfarerAkatoshLevel()
        Trace(2, "Level increase routed to Experience Mode handler at level " + aiLevel + ".")
    else
        Trace(1, "Level increase skipped: PDV_Manager not assigned.")
    endIf
EndEvent

Event OnMenuOpen(String menuName)
    if menuName == "Lockpicking Menu"
        PDV_LockpickMenuTargetRef = Game.GetCurrentCrosshairRef()
        PDV_LockpickMenuTargetWasLocked = PDV_LockpickMenuTargetRef && PDV_LockpickMenuTargetRef.IsLocked()
    endIf
EndEvent

Event OnMenuClose(String menuName)
    if menuName == "RaceSex Menu"
        QueueOriginInitialization()
        Trace(2, "RaceSex menu closed; origin retry queued.")
    elseIf menuName == "Lockpicking Menu"
        ResolveLockpickMenuClose()
    endIf
EndEvent

Function ResolveLockpickMenuClose()
    ObjectReference lockRef = PDV_LockpickMenuTargetRef
    Bool wasLocked = PDV_LockpickMenuTargetWasLocked
    PDV_LockpickMenuTargetRef = None
    PDV_LockpickMenuTargetWasLocked = false

    if !wasLocked || !lockRef || lockRef.IsLocked() || !IsOwnedLockReference(lockRef)
        return
    endIf

    RouteGenericAction(EVT_PICK_OWNED_LOCK, GetActorRef() as Form, lockRef as Form)
    Trace(2, "Owned lock picked through lockpicking menu fallback.")
EndFunction

Bool Function IsOwnedLockReference(ObjectReference targetRef)
    if !targetRef
        return false
    endIf

    if targetRef.GetActorOwner() || targetRef.GetFactionOwner()
        return true
    endIf

    Cell parentCell = targetRef.GetParentCell()
    if parentCell && (parentCell.GetActorOwner() || parentCell.GetFactionOwner())
        return true
    endIf

    return false
EndFunction

; --- Organic edge hooks: low-health combat sessions, Khajiit Alkosh dragon
; --- kills, Rajhin elegant theft. Receivers validate and route; the manager owns
; --- scoring.

Event OnCombatStateChanged(Actor akTarget, Int aeCombatState)
    if aeCombatState == 1
        BeginCombatSession()
    elseIf aeCombatState == 0
        ResolveCombatSession("combat_exit")
    endIf
EndEvent

; Player combat-state events can be unreliable, so sessions also open on the first
; player-attributed kill while in combat, and the poll closes stale sessions.
Function BeginCombatSession()
    Int originRace = GetOriginRaceValue()
    if PDV_CombatSessionActive || !IsCombatSessionOrigin(originRace)
        return
    endIf

    PDV_CombatSessionActive = true
    Actor combatPlayer = Game.GetPlayer()
    PDV_CombatStartedSneaking = combatPlayer && combatPlayer.IsSneaking()
    PDV_CombatObservedSneaking = PDV_CombatStartedSneaking
    PDV_CombatSessionKills = 0
    PDV_CombatMaxLevelDelta = 0
    PDV_CombatLowHealthFlag = false
    PDV_CombatNearFatalFlag = false
    PDV_CombatMageThreatFlag = false
    PDV_CombatBelowHealthRouted = false
    ScheduleCombatDeadline(4.0)
    Trace(2, "PDV combat session opened for origin " + originRace + ".")
EndFunction

Function CombatPollTick()
    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    SampleCombatHealth(playerRef, "combat_poll")
    if playerRef.IsSneaking()
        PDV_CombatObservedSneaking = true
    endIf

    if playerRef.IsInCombat()
        ScheduleCombatDeadline(4.0)
    else
        ResolveCombatSession("poll_combat_exit")
    endIf
EndFunction

Function SampleCombatHealth(Actor playerRef, String reason)
    Int originRace = GetOriginRaceValue()
    Float healthPct = playerRef.GetActorValuePercentage("Health")
    if originRace == 4
        TryRoutePlayerBelowHealthGate(playerRef, healthPct, reason)
    elseIf originRace == 0 || originRace == 3 || originRace == 6
        ; P9: Altmer uses the FLAG-PAIR shape deliberately. Origins 4/7/8 use
        ; TryRoutePlayerBelowHealthGate instead; the two are NOT interchangeable, and picking the
        ; wrong one yields a signal that compiles and never fires.
        if healthPct <= 0.10
            PDV_CombatNearFatalFlag = true
            PDV_CombatLowHealthFlag = true
        elseIf healthPct <= 0.50
            PDV_CombatLowHealthFlag = true
        endIf
    elseIf originRace == 7 || originRace == 8
        TryRoutePlayerBelowHealthGate(playerRef, healthPct, reason)
    endIf
EndFunction

Function TryRoutePlayerBelowHealthGate(Actor playerRef, Float healthPct, String reason)
    Int originRace = GetOriginRaceValue()
    if PDV_CombatBelowHealthRouted || (originRace != 4 && originRace != 7 && originRace != 8) || !PDV_EventBusService
        return
    endIf
    if !playerRef || !playerRef.IsInCombat() || healthPct > 0.20
        return
    endIf

    PDV_CombatBelowHealthRouted = true
    PDV_EventBusService.RoutePlayerBelowHealthGate(playerRef)
    Trace(1, "Player below-health gate detected for origin " + originRace + " (" + reason + ").")
EndFunction

Function ResolveCombatSession(String reason)
    if !PDV_CombatSessionActive
        return
    endIf
    PDV_CombatSessionActive = false
    PDV_COMBAT_NEXT_DUE = -1.0
    ArmEarliestDeadline()

    Actor playerRef = Game.GetPlayer()
    if !playerRef || playerRef.IsDead()
        return
    endIf

    Int originRace = GetOriginRaceValue()
    if originRace == 8 && PDV_CombatBelowHealthRouted && PDV_EventBusService
        PDV_EventBusService.RoutePlayerBelowHealthSurvived(playerRef)
        Trace(1, "Orc Code Holds survival routed (" + reason + ").")
        return
    endIf

    ; Nord: Tsun's adversity beat rides the same rare near-fatal reversal shape as
    ; the Khajiit beat below, weekly-capped at the detector per the 2026-07-15
    ; pool-feeding ruling (rarity is the guard, pool feeding is intended).
    ; P9 (2026-08-03): Syrabane's anti-mage survival (3113), mirroring the Nord/Tsun shape below --
    ; same weekly-stamp idiom, same near-fatal + kill gate, plus the mage-threat flag so this is
    ; specifically "survived a mage", not any desperate fight.
    if originRace == 3
        if PDV_CombatMageThreatFlag && PDV_CombatLowHealthFlag && PDV_CombatSessionKills >= 1 && PDV_EventBusService
            Int altmerWeekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
            if StorageUtil.GetIntValue(None, "PDV.Altmer.Syrabane.AntiMageWeek") != altmerWeekStamp
                StorageUtil.SetIntValue(None, "PDV.Altmer.Syrabane.AntiMageWeek", altmerWeekStamp)
                PDV_EventBusService.RouteAltmerSyrabaneAntiMageSurvival("organic_anti_mage_survival")
                Trace(1, "Altmer anti-mage survival detected (" + reason + ")")
            endIf
        endIf
        return
    endIf

    if originRace == 0
        if PDV_CombatNearFatalFlag && PDV_CombatSessionKills >= 1 && PDV_EventBusService
            Int nordWeekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
            if StorageUtil.GetIntValue(None, "PDV.Nord.Tsun.AdversityWeek") != nordWeekStamp
                StorageUtil.SetIntValue(None, "PDV.Nord.Tsun.AdversityWeek", nordWeekStamp)
                PDV_EventBusService.RouteNordTsunAdversity("organic_near_fatal_reversal")
                Trace(1, "Nord near-fatal adversity detected (" + reason + ")")
            endIf
        endIf
        return
    endIf

    if originRace != 6
        return
    endIf

    ; Near-fatal reversal: the rare marked beat; weekly cap enforced here. A capped
    ; reversal still falls through to the outnumbered check (near-fatal implies the
    ; low-health adversity gate).
    if PDV_CombatNearFatalFlag && PDV_CombatSessionKills >= 1
        Int weekStamp = ((Utility.GetCurrentGameTime() as Int) / 7) + 1
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.BaanDar.ReversalWeek") != weekStamp
            StorageUtil.SetIntValue(None, "PDV.Khajiit.BaanDar.ReversalWeek", weekStamp)
            PDV_EventBusService.RouteKhajiitBaanDarReversal("organic_near_fatal_reversal")
            Trace(1, "Khajiit near-fatal reversal detected (" + reason + ")")
            return
        endIf
        Trace(2, "Khajiit reversal blocked by weekly cap; checking outnumbered award.")
    endIf

    ; Outnumbered win: multi-kill or higher-level victim, gated on real adversity
    ; (health dipped below half) so steamroll clears stay silent. One award per day.
    if (PDV_CombatSessionKills >= 3 || PDV_CombatMaxLevelDelta >= 5) && PDV_CombatLowHealthFlag
        ; fix-plan 4.2: one outnumbered-win award per devotional day.
        Int dayStamp = GetDevotionalDayStamp()
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.BaanDar.OutnumberedDay") != dayStamp
            StorageUtil.SetIntValue(None, "PDV.Khajiit.BaanDar.OutnumberedDay", dayStamp)
            PDV_EventBusService.RouteKhajiitBaanDarRoadTrick("organic_outnumbered_win")
            Trace(1, "Khajiit outnumbered win detected (" + reason + ")")
        endIf
    endIf
EndFunction

Event OnActorKilled(Actor akVictim, Actor akKiller)
    if !akVictim || !akKiller
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef || akKiller != playerRef
        return
    endIf

    Int originRace = GetOriginRaceValue()

    if IsPaarthurnaxActor(akVictim)
        if !PDV_EventBusService
            Trace(1, "Paarthurnax kill skipped: PDV_EventBusService not assigned.")
            return
        endIf

        PDV_EventBusService.RoutePaarthurnaxKill(akVictim as Form)
        if originRace == 6
            PDV_EventBusService.RouteKhajiitAlkoshChaosAid()
        endIf
        Trace(1, "Paarthurnax slain; global kill fork routed.")
        return
    endIf

    if originRace == 5 && PDV_EventBusService && PDV_CombatSessionActive && !PDV_CombatStartedSneaking && !PDV_CombatObservedSneaking && !playerRef.IsSneaking() && akVictim.IsHostileToActor(playerRef) && akVictim.GetLevel() >= playerRef.GetLevel()
        PDV_EventBusService.RouteDunmerHonorableVictory(akVictim as Form)
    endIf

    if originRace == 0 && PDV_CombatSessionActive
        PDV_CombatSessionKills += 1
    endIf

    if originRace == 9 && PDV_EventBusService && PDV_CombatSessionActive && !PDV_CombatStartedSneaking && !PDV_CombatObservedSneaking && !playerRef.IsSneaking() && akVictim.IsHostileToActor(playerRef) && akVictim.GetLevel() >= playerRef.GetLevel()
        PDV_EventBusService.RouteRedguardLekiDuel(akVictim as Form)
    endIf

    if originRace != 6
        return
    endIf

    if !PDV_EventBusService
        Trace(1, "Khajiit organic kill skipped: PDV_EventBusService not assigned.")
        return
    endIf

    HandleKhajiitOrganicKill(akVictim, playerRef)
EndEvent

Bool Function IsPaarthurnaxActor(Actor victimActor)
    if !victimActor || !ActorTypeDragon || !ActorHasInheritedKeyword(victimActor, ActorTypeDragon) || !Paarthurnax
        return False
    endIf

    ActorBase victimBase = victimActor.GetActorBase()
    ActorBase victimLeveledBase = victimActor.GetLeveledActorBase()
    return victimBase == Paarthurnax || victimLeveledBase == Paarthurnax
EndFunction

Function RoutePaarthurnaxSpareQuestStage(Quest sourceQuest, Int stageValue)
    if !sourceQuest || stageValue != 200 || sourceQuest.GetFormID() != MQ305_FORM_ID
        return
    endIf

    RoutePaarthurnaxSpareIfAlive(sourceQuest as Form, "mq305_stage_200")
EndFunction

Function RoutePaarthurnaxSpareLoadCheck()
    if StorageUtil.GetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0) == 1 || StorageUtil.GetIntValue(None, "PDV.Paarthurnax.KillSeen", 0) == 1
        return
    endIf

    Quest mq305 = Game.GetFormFromFile(MQ305_FORM_ID, "Skyrim.esm") as Quest
    if mq305 && mq305.GetStageDone(200)
        RoutePaarthurnaxSpareIfAlive(mq305 as Form, "load_mq305_complete")
    endIf
EndFunction

Function RoutePaarthurnaxSpareIfAlive(Form sourceForm, String reason)
    if !PDV_EventBusService
        Trace(1, "Paarthurnax spare skipped: PDV_EventBusService not assigned.")
        return
    endIf

    if !Paarthurnax
        Trace(1, "Paarthurnax spare skipped: Paarthurnax ActorBase not assigned.")
        return
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Paarthurnax.SpareSeen", 0) == 1 || StorageUtil.GetIntValue(None, "PDV.Paarthurnax.KillSeen", 0) == 1
        return
    endIf

    if Paarthurnax.GetDeadCount() > 0
        Trace(2, "Paarthurnax spare skipped: Paarthurnax is dead (" + reason + ").")
        return
    endIf

    PDV_EventBusService.RoutePaarthurnaxSpare(sourceForm)
    Trace(1, "Paarthurnax alive at main-quest closeout; spare fork routed (" + reason + ").")
EndFunction

Function HandleKhajiitOrganicKill(Actor victimActor, Actor playerRef)
    ; Dragon classification: Paarthurnax -> chaos-aid negative; named-dragon list ->
    ; full Alkosh beat with a one-shot marker per base; other dragons -> weekly nudge.
    if ActorTypeDragon && ActorHasInheritedKeyword(victimActor, ActorTypeDragon)
        ActorBase victimBase = victimActor.GetActorBase()
        ActorBase victimLeveledBase = victimActor.GetLeveledActorBase()
        if Paarthurnax && (victimBase == Paarthurnax || victimLeveledBase == Paarthurnax)
            PDV_EventBusService.RouteKhajiitAlkoshChaosAid()
            Trace(1, "Paarthurnax slain; Alkosh chaos-aid routed.")
        elseIf PDV_FLST_AlkoshNamedDragons && victimBase && (PDV_FLST_AlkoshNamedDragons.HasForm(victimBase) || PDV_FLST_AlkoshNamedDragons.HasForm(victimLeveledBase))
            String namedKey = "PDV.Khajiit.AlkoshNamed." + victimBase.GetFormID()
            if StorageUtil.GetIntValue(None, namedKey) == 0
                StorageUtil.SetIntValue(None, namedKey, 1)
                PDV_EventBusService.RouteKhajiitAlkoshNamedDragon("organic_named_dragon")
                Trace(1, "Khajiit named-dragon kill routed for Alkosh.")
            else
                Trace(2, "Khajiit named-dragon repeat blocked by one-shot marker.")
            endIf
        else
            PDV_EventBusService.RouteKhajiitAlkoshGenericDragon("organic_generic_dragon")
        endIf
    endIf

    ; Caravan defense (Khenarthi CARAVAN_AID): killing a faction-hostile actor
    ; while a living caravan leader's camp is loaded within ~2048 units reads as
    ; defending the caravan. IsHostileToActor is faction/relationship math, so it
    ; still discriminates on the corpse; a murdered innocent near a camp stays
    ; silent, and caravan members themselves are excluded (that is HARM's lane).
    ; The manager handler owns the Khajiit-origin gate and the daily cap.
    EnsureKhajiitCaravanForms()
    if PDV_KhajiitCaravanFactionRef && !victimActor.IsInFaction(PDV_KhajiitCaravanFactionRef)
        if victimActor.IsHostileToActor(playerRef) && IsKhajiitCaravanLeaderNearby(playerRef)
            PDV_EventBusService.RouteKhajiitKhenarthiCaravanAid("organic_caravan_defense")
            Trace(1, "Khajiit caravan-defense kill routed for Khenarthi.")
        endIf
    endIf

    ; Baan Dar session tracking: kills open a session if the combat-state event was
    ; missed, then feed the counters. Health is sampled at the kill too, so a dip
    ; just before the killing blow is not lost between polls.
    if !PDV_CombatSessionActive && playerRef.IsInCombat()
        BeginCombatSession()
    endIf

    if PDV_CombatSessionActive
        PDV_CombatSessionKills += 1
        Int levelDelta = victimActor.GetLevel() - playerRef.GetLevel()
        if levelDelta > PDV_CombatMaxLevelDelta
            PDV_CombatMaxLevelDelta = levelDelta
        endIf
        SampleCombatHealth(playerRef, "kill")
    endIf
EndFunction

Bool Function ActorHasInheritedKeyword(Actor actorRef, Keyword keywordRef)
    if !actorRef || !keywordRef
        return False
    endIf

    if actorRef.HasKeyword(keywordRef)
        return True
    endIf

    ActorBase baseActor = actorRef.GetLeveledActorBase()
    if baseActor && baseActor.HasKeyword(keywordRef)
        return True
    endIf

    Race actorRace = actorRef.GetRace()
    if actorRace && actorRace.HasKeyword(keywordRef)
        return True
    endIf

    return False
EndFunction

Bool Function IsCombatSessionOrigin(Int originRace)
    ; P9 (2026-08-03): origin 3 (Altmer) added for Syrabane's anti-mage survival beat.
    return originRace == 0 || originRace == 3 || originRace == 4 || originRace == 5 || originRace == 6 || originRace == 7 || originRace == 8 || originRace == 9
EndFunction

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Actor sourceActor = akSourceContainer as Actor
    if !sourceActor
        return
    endIf

    if GetOriginRaceValue() != 6
        return
    endIf

    ; D7 / fix-plan 10.3. The two Khajiit pickpocket routes below were the only
    ; PDV_EventBusService call sites in this script with no null guard, so on a save
    ; where the bus is not yet wired every qualifying pickpocket threw a Papyrus error
    ; instead of returning quietly. Guarded here, after the cheap origin gate and before
    ; the expensive detection/value work, matching every other route in this file.
    if !PDV_EventBusService
        Trace(1, "Khajiit pickpocket route skipped: PDV_EventBusService not assigned.")
        return
    endIf

    Actor playerRef = Game.GetPlayer()
    if !playerRef || !playerRef.IsSneaking()
        return
    endIf

    if sourceActor.IsDead() || sourceActor.IsPlayerTeammate()
        return
    endIf

    if playerRef.IsDetectedBy(sourceActor)
        return
    endIf

    ActorBase sourceBase = sourceActor.GetActorBase()
    if !sourceBase
        return
    endIf

    Int takenValue = 0
    if akBaseItem
        takenValue = akBaseItem.GetGoldValue() * aiItemCount
    endIf

    Bool notableTarget = PDV_FLST_RajhinNotableTargets && PDV_FLST_RajhinNotableTargets.HasForm(sourceBase)
    if !notableTarget && takenValue < 200
        return
    endIf

    String targetKey = "PDV.Khajiit.Rajhin.Target." + sourceBase.GetFormID()
    Float nowTime = Utility.GetCurrentGameTime()
    Float lastTime = StorageUtil.GetFloatValue(None, targetKey)
    if lastTime > 0.0 && nowTime - lastTime < 7.0
        Trace(2, "Khajiit Rajhin elegant theft blocked by per-target cooldown.")
        return
    endIf

    StorageUtil.SetFloatValue(None, targetKey, nowTime)
    PDV_EventBusService.RouteKhajiitRajhinElegantTheft("organic_elegant_theft")
    Trace(1, "Khajiit Rajhin elegant theft detected.")

    ; Rajhin legend-made: a single pickpocket take worth >= 500 gold rises above
    ; the elegant-theft cadence. The manager handler owns origin gate + daily cap.
    if takenValue >= 500
        PDV_EventBusService.RouteKhajiitRajhinLegendMade("organic_grand_pickpocket")
    endIf
EndEvent

Event OnItemRemoved(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    ; Spell-tome learning ingress (Mega Packet Sitting 1 E1, 2026-07-05).
    ; Reading a spell tome learns the spell and destroys the book, but that path
    ; does NOT raise OnBookRead, so EVT_READ_SPELL_TOME (341) never fired through
    ; RouteGenericBookRead. A learned tome is consumed with no persistent ref and
    ; no destination: akItemReference == None (non-persistent, destroyed) AND
    ; akDestContainer == None (not sold/stored/dropped). Selling sets a dest,
    ; dropping sets akItemReference to the world ref, so both are excluded here.
    if akItemReference || akDestContainer
        return
    endIf

    if !HasListedForm(PDV_FLST_FaucetSpellTomes, akBaseItem)
        return
    endIf

    if !PDV_EventBusService
        Trace(1, "Spell tome learn skipped: PDV_EventBusService not assigned.")
        return
    endIf

    ; Shares the once-ever book key with OnBookRead so a consumed-on-learn tome
    ; and a later re-read of another copy (spell now known) credit exactly once.
    if !MarkGenericBookRead(akBaseItem)
        Trace(2, "Spell tome learn repeat skipped: " + akBaseItem.GetFormID())
        return
    endIf

    RouteGenericAction(EVT_READ_SPELL_TOME, GetActorRef() as Form, akBaseItem)
    Trace(1, "Spell tome learned: routed EVT_READ_SPELL_TOME.")
EndEvent

Function RegisterForPlayerEvents()
    RegisterForSleep()
    RegisterForMenu("RaceSex Menu")
    RegisterForMenu("Lockpicking Menu")
    RegisterForShoutSignals()
    RegisterForLevelSignals()
    RegisterForCivilWarSignals()
    RegisterForP2ImmersiveSignals()
EndFunction

Function RegisterForShoutSignals()
    PO3_Events_Alias.RegisterForShoutAttack(Self)
    Trace(2, "Shout hooks refreshed.")
EndFunction

Function ResolveRouterService()
    ; Existing saves baked this script's VMAD before PDV_RouterService was
    ; added, so the CK fill reads None there. Resolve once from the plugin
    ; on the load path instead; new saves get the CK-filled property.
    if !PDV_RouterService
        Quest routerQuest = Game.GetFormFromFile(0x000296FA, "Devotion.esp") as Quest
        PDV_RouterService = routerQuest as PDV_ActionRouter
        if PDV_RouterService
            Trace(2, "Router service resolved from plugin for pre-existing save.")
        endIf
    endIf
EndFunction

Function RegisterForLevelSignals()
    PO3_Events_Alias.RegisterForLevelIncrease(Self)
    Trace(2, "Level-up hooks refreshed.")
EndFunction

Function RegisterForCivilWarSignals()
    UnregisterForModEvent(MOD_EVENT_CONCORDAT_COMPLIANCE)
    UnregisterForModEvent(MOD_EVENT_CONCORDAT_DEFIANCE)
    RegisterForModEvent(MOD_EVENT_CONCORDAT_COMPLIANCE, "OnPDVConcordatCompliance")
    RegisterForModEvent(MOD_EVENT_CONCORDAT_DEFIANCE, "OnPDVConcordatDefiance")
    Trace(2, "Civil War mod-event hooks refreshed.")
EndFunction

Function RegisterForP2ImmersiveSignals()
    PO3_Events_Alias.RegisterForBookRead(Self)
    PO3_Events_Alias.RegisterForSpellLearned(Self)
    PO3_Events_Alias.RegisterForItemHarvested(Self)
    PO3_Events_Alias.RegisterForWeatherChange(Self)
    PO3_Events_Alias.RegisterForActorKilled(Self)
    PO3_Events_Alias.RegisterForItemCrafted(Self)
    ResolveRouterService()
    RegisterQuestStageList(PDV_FLST_P2_BretonKnightsRoadSources)
    RegisterQuestStageList(PDV_FLST_P2_BretonHiddenArtSources)
    RegisterQuestStageList(PDV_FLST_P2_BretonGreenWaySources)
    RegisterQuestStageList(PDV_FLST_P2_BretonVowSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerAzuraSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerBoethiahSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerMephalaSources)
    RegisterQuestStageList(PDV_FLST_P2_DunmerDeviationSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialCivicSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPrivateTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPublicTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPatronCivicSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialPublicServiceSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialMercySources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialLawfulOrderSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialHonestWorkSources)
    RegisterQuestStageList(PDV_FLST_P2_ImperialDeathDutySources)
    RegisterQuestStageList(PDV_FLST_P2_NordOldWaysSources)
    RegisterQuestStageList(PDV_FLST_P2_NordKyneTalosSources)
    RegisterQuestStageList(PDV_FLST_P2_NordHircineArkaySources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerAurielSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerMagnusSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerXarxesSources)
    RegisterQuestStageList(PDV_FLST_P2_AltmerLorkhanPenalties)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianHistSources)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianCommunitySources)
    RegisterQuestStageList(PDV_FLST_P2_ArgonianSithisSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerYffreSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerZenSources)
    RegisterQuestStageList(PDV_FLST_P2_BosmerBaanDarSources)
    RegisterQuestStageList(PDV_FLST_P2_KhajiitLunarSources)
    RegisterQuestStageList(PDV_FLST_P2_KhajiitFocusedSources)
    RegisterQuestStageList(PDV_FLST_P2_OrcMalacathSources)
    RegisterOrcLifeModeQuestSources()
    RegisterCuratedSignalQuestSources()
    RegisterQuestStageList(PDV_FLST_P2_RedguardSpineSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardCrownSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardForebearSources)
    RegisterQuestStageList(PDV_FLST_P2_RedguardAshAbahSources)
    RegisterQuestStageList(PDV_FLST_Daedric_AzuraLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_BoethiahLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_VaerminaLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_MeridiaLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_MolagLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_MephalaLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_HircineLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_MalacathLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_DagonLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_SheoLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_NamiraLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_SanguineLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_VileLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_MoraLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_NocturnalLiveSources)
    RegisterQuestStageList(PDV_FLST_Daedric_PeryiteLiveSources)
    RegisterQuestReactionMatrix()
    RegisterQuestReactionFaucetEvents()
    ; Raise-undead is detected in OnSpellCast (caster-side vanilla event, auto-forwarded to
    ; the alias). No PO3 registration - both MagicEffectApplyEx (target-side) and
    ; ActorReanimateStart proved dead in game for player-cast reanimation.
    Trace(2, "P2 immersive PO3 hooks refreshed.")
EndFunction

Function RegisterGenericEffectList(FormList effectList)
    if !effectList
        return
    endIf

    Int index = 0
    Int count = effectList.GetSize()
    while index < count
        MagicEffect effectRef = effectList.GetAt(index) as MagicEffect
        if effectRef
            PO3_Events_Alias.RegisterForMagicEffectApplyEx(Self, effectRef as Form, True)
        endIf
        index += 1
    endWhile
EndFunction

Function RegisterQuestReactionFaucetEvents()
    CacheQuestReactionSpellFaucetForms()
    ; 12.2 / audit C2. Resolve every faucet form here, once per load, so no runtime event
    ; ever pays a Game.GetModByName again. Deliberately placed BEFORE the 8.2 hit-event
    ; registration and the matrix early-out below: the builder does its own JsonExists
    ; check and simply produces an empty cache when the matrix is missing, which is
    ; exactly what the old JSON-reading path returned in that case.
    CacheQuestReactionFaucetForms()

    ; B8 / fix-plan 8.2. The hit-event registration used to sit BELOW the JsonExists
    ; early-out, so a missing or corrupt PDV_QuestReactionMatrix.json silently killed
    ; ALL hit-driven detection -- combat-session opening and below-health sampling,
    ; which have nothing whatever to do with the reaction matrix. That in turn silently
    ; disabled every near-death payload downstream of the gate (Orc Code Holds, the
    ; Bosmer Baan Dar gap, the Argonian Sithis burst), with no error anywhere. Hit
    ; registration is matrix-independent, so it is now done FIRST and unconditionally;
    ; only the two matrix-driven magic-effect lists stay behind the early-out.
    PO3_Events_Alias.UnregisterForAllHitEventsEx(Self)
    ; Unfiltered on the block axis (2026-07-16 regression fix): OnHitEx opens the
    ; combat session + samples health on ANY hit taken (the near-death gate for
    ; Orc Code Holds / Bosmer Baan Dar Gap / Argonian Sithis burst depends on it),
    ; then self-discriminates blocked hits for the Stuhn faucet via abHitBlocked.
    ; A previous aiBlockFilter=1 narrowing served the blocked-hit faucet but
    ; silently cut off the take-a-hit session-open path, so a non-blocking player
    ; never opened a combat session and no near-death payload could ever fire.
    PO3_Events_Alias.RegisterForHitEventEx(Self, akAggressorFilter = None, akSourceFilter = None, akProjectileFilter = None, aiPowerFilter = -1, aiSneakFilter = -1, aiBashFilter = -1, aiBlockFilter = -1, abMatch = True)

    ; Matrix-dependent registrations only, from here down.
    if !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        Trace(1, "Quest-reaction matrix missing; magic-effect faucets not registered. Hit-driven detection is unaffected.")
        return
    endIf

    PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(Self)
    RegisterQuestReactionEffectList("faucetEffectForms.Namira.cannibalism")
    RegisterQuestReactionEffectList("faucetEffectForms.Dibella.charity")
EndFunction

Function RegisterQuestReactionEffectList(String listKey)
    Int sourceIndex = 0
    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionFormIdCsvKey(listKey)), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionPluginCsvKey(listKey)), ",")
    Int sourceCount = formIds.Length
    while sourceIndex < sourceCount
        MagicEffect sourceEffect = GetQuestReactionRuntimeFormFromCsv(formIds, plugins, sourceIndex) as MagicEffect
        if sourceEffect
            PO3_Events_Alias.RegisterForMagicEffectApplyEx(Self, sourceEffect as Form, True)
        endIf
        sourceIndex += 1
    endWhile
EndFunction

Function CacheQuestReactionSpellFaucetForms()
    PDV_QuestReactionSpellFaucetCacheReady = true

    if !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        PDV_QRSpellSanguine0 = None
        PDV_QRSpellSanguine1 = None
        PDV_QRSpellVaermina0 = None
        PDV_QRSpellVaermina1 = None
        PDV_QRSpellSheogorathFire0 = None
        PDV_QRSpellSheogorathFire1 = None
        return
    endIf

    PDV_QRSpellSanguine0 = GetQuestReactionRuntimeForm("faucetSpellForms.Sanguine.serve_a_daedra:sanguine", 0)
    PDV_QRSpellSanguine1 = GetQuestReactionRuntimeForm("faucetSpellForms.Sanguine.serve_a_daedra:sanguine", 1)
    PDV_QRSpellVaermina0 = GetQuestReactionRuntimeForm("faucetSpellForms.Vaermina.serve_a_daedra:vaermina", 0)
    PDV_QRSpellVaermina1 = GetQuestReactionRuntimeForm("faucetSpellForms.Vaermina.serve_a_daedra:vaermina", 1)
    PDV_QRSpellSheogorathFire0 = GetQuestReactionRuntimeForm("faucetSpellForms.Sheogorath.serve_a_daedra:sheogorath_fire", 0)
    PDV_QRSpellSheogorathFire1 = GetQuestReactionRuntimeForm("faucetSpellForms.Sheogorath.serve_a_daedra:sheogorath_fire", 1)
EndFunction

; 12.2 / audit C2. Resolve every list ShouldRouteQuestReactionFaucet can be asked about
; into the flat cache. These 21 keys are exactly the non-spell, non-questWatch entries of
; GetQuestReactionFormIdKey; the three spell lists keep their own dedicated cache above
; (RouteQuestReactionSpellFaucet compares against them directly and never calls
; ShouldRouteQuestReactionFaucet), and questWatch is a quest-registration list, not a
; faucet.
Function CacheQuestReactionFaucetForms()
    PDV_QuestReactionFaucetForms = Utility.CreateFormArray(QUEST_REACTION_FAUCET_CACHE_MAX)
    PDV_QuestReactionFaucetListKeys = Utility.CreateStringArray(QUEST_REACTION_FAUCET_CACHE_MAX)
    PDV_QuestReactionFaucetCacheCount = 0
    PDV_QuestReactionFaucetCacheReady = true

    if !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        Trace(1, "Quest-reaction matrix missing; faucet form cache left empty (no faucet can match).")
        return
    endIf

    CacheQuestReactionFaucetList("faucetForms.Azura.fate_threshold")
    CacheQuestReactionFaucetList("faucetForms.Hermaeus Mora.forbidden_knowledge")
    CacheQuestReactionFaucetList("faucetForms.Hermaeus Mora.disciplined_study")
    CacheQuestReactionFaucetList("faucetForms.Namira.cannibalism")
    CacheQuestReactionFaucetList("faucetForms.Sanguine.revel_indulge")
    CacheQuestReactionFaucetList("faucetForms.Sanguine.revel_indulge_skooma")
    CacheQuestReactionFaucetList("faucetForms.Clavicus Vile.serve_a_daedra:clavicus")
    CacheQuestReactionFaucetList("faucetForms.Vaermina.serve_a_daedra:vaermina")
    CacheQuestReactionFaucetList("faucetForms.Boethiah.serve_a_daedra:boethiah")
    CacheQuestReactionFaucetList("faucetForms.Mephala.serve_a_daedra:mephala")
    CacheQuestReactionFaucetList("faucetForms.Malacath.serve_a_daedra:malacath")
    CacheQuestReactionFaucetList("faucetForms.Molag Bal.serve_a_daedra:molagbal")
    CacheQuestReactionFaucetList("faucetForms.Hircine.serve_a_daedra:hircine")
    CacheQuestReactionFaucetList("faucetForms.Meridia.serve_a_daedra:meridia")
    CacheQuestReactionFaucetList("faucetForms.Sheogorath.serve_a_daedra:sheogorath")
    CacheQuestReactionFaucetList("faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunesdagon")
    CacheQuestReactionFaucetList("faucetForms.Nocturnal.serve_a_daedra:nocturnal")
    CacheQuestReactionFaucetList("faucetForms.Peryite.serve_a_daedra:peryite")
    CacheQuestReactionFaucetList("faucetForms.Dibella.aesthetic_devotion")
    CacheQuestReactionFaucetList("faucetEffectForms.Namira.cannibalism")
    CacheQuestReactionFaucetList("faucetEffectForms.Dibella.charity")

    Trace(2, "Quest-reaction faucet forms cached: " + PDV_QuestReactionFaucetCacheCount + ".")
EndFunction

Function CacheQuestReactionFaucetList(String listKey)
    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionFormIdCsvKey(listKey)), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionPluginCsvKey(listKey)), ",")

    Int sourceIndex = 0
    Int sourceCount = formIds.Length
    while sourceIndex < sourceCount
        if PDV_QuestReactionFaucetCacheCount >= QUEST_REACTION_FAUCET_CACHE_MAX
            Trace(1, "Faucet form cache hit its " + QUEST_REACTION_FAUCET_CACHE_MAX + "-entry ceiling; '" + listKey + "' is truncated and will not match.")
            return
        endIf

        ; Entries whose plugin is absent resolve to None and are simply not cached --
        ; the same outcome the old per-event path produced, one load earlier.
        Form resolvedForm = GetQuestReactionRuntimeFormFromCsv(formIds, plugins, sourceIndex)
        if resolvedForm
            PDV_QuestReactionFaucetForms[PDV_QuestReactionFaucetCacheCount] = resolvedForm
            PDV_QuestReactionFaucetListKeys[PDV_QuestReactionFaucetCacheCount] = listKey
            PDV_QuestReactionFaucetCacheCount += 1
        endIf
        sourceIndex += 1
    endWhile
EndFunction

Function RegisterQuestReactionMatrix()
    RegisterQuestReactionMatrixFile(QUEST_REACTION_MATRIX_FILE, "core")
    RegisterQuestReactionChannelFolder()
    RegisterQuestReactionStageAdapterFolder()
EndFunction

Function RegisterQuestReactionChannelFolder()
    ; Per-mod patch channels: every JSON dropped in the Channels folder is a
    ; matrix file. The discovered list is cached in StorageUtil so the manager's
    ; cell resolver never pays a folder scan on the reaction hot path.
    StorageUtil.StringListClear(None, "PDV.QR.ChannelFiles")
    String[] channelNames = JsonUtil.JsonInFolder(QUEST_REACTION_CHANNEL_FOLDER)
    if !channelNames
        Trace(2, "Quest reaction channel folder empty or absent; no per-mod channels registered.")
        return
    endIf

    Int channelIndex = 0
    while channelIndex < channelNames.Length
        String channelName = channelNames[channelIndex]
        if channelName != ""
            String channelFile = QUEST_REACTION_CHANNEL_FOLDER + "/" + channelName
            if JsonUtil.JsonExists(channelFile)
                RegisterQuestReactionMatrixFile(channelFile, channelName)
                StorageUtil.StringListAdd(None, "PDV.QR.ChannelFiles", channelFile, False)
            else
                Trace(1, "Quest reaction channel listed but unreadable: " + channelFile)
            endIf
        endIf
        channelIndex += 1
    endWhile
    Trace(2, "Quest reaction channels registered: " + StorageUtil.StringListCount(None, "PDV.QR.ChannelFiles") + ".")
EndFunction

Function RegisterQuestReactionStageAdapterFolder()
    ; Optional package adapters remap a physical quest stage to a synthetic matrix
    ; stage. Cache their loaded file paths so quest-stage routing never scans a
    ; folder while handling an event.
    StorageUtil.StringListClear(None, "PDV.QR.StageAdapterFiles")
    String[] adapterNames = JsonUtil.JsonInFolder(QUEST_REACTION_STAGE_ADAPTER_FOLDER)
    if !adapterNames
        return
    endIf

    Int adapterIndex = 0
    while adapterIndex < adapterNames.Length
        String adapterName = adapterNames[adapterIndex]
        if adapterName != ""
            String adapterFile = QUEST_REACTION_STAGE_ADAPTER_FOLDER + "/" + adapterName
            if JsonUtil.JsonExists(adapterFile)
                ReloadQuestReactionMatrixJsonFile(adapterFile)
                if JsonUtil.IsGood(adapterFile)
                    StorageUtil.StringListAdd(None, "PDV.QR.StageAdapterFiles", adapterFile, False)
                endIf
            else
                Trace(1, "Quest-stage adapter listed but unreadable: " + adapterFile)
            endIf
        endIf
        adapterIndex += 1
    endWhile
    Trace(2, "Quest-stage adapters registered: " + StorageUtil.StringListCount(None, "PDV.QR.StageAdapterFiles") + ".")
EndFunction

Function RegisterQuestReactionMatrixFile(String matrixFile, String label)
    if !JsonUtil.JsonExists(matrixFile)
        Trace(1, "Quest reaction matrix JSON missing: " + matrixFile)
        return
    endIf

    ReloadQuestReactionMatrixJsonFile(matrixFile)

    ; The watch list has outgrown the 128-element Papyrus array ceiling, and a
    ; truncated array here silently unhooks every quest past the cap. Read the
    ; list by index so no full array is ever materialized.
    Int sourceIndex = 0
    Int registeredCount = 0
    Int sourceCount = JsonUtil.StringListCount(matrixFile, "questWatchFormIds")
    if sourceCount > 0
        while sourceIndex < sourceCount
            String entryFormId = JsonUtil.StringListGet(matrixFile, "questWatchFormIds", sourceIndex)
            String entryPlugin = JsonUtil.StringListGet(matrixFile, "questWatchPlugins", sourceIndex)
            Quest sourceQuest = GetQuestReactionRuntimeFormFromEntry(entryFormId, entryPlugin) as Quest
            if sourceQuest
                PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
                StorageUtil.SetIntValue(None, "PDV.QuestReaction.LocalFormId." + sourceQuest.GetFormID(), entryFormId as Int)
                registeredCount += 1
            endIf
            sourceIndex += 1
        endWhile
    else
        String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchFormIdsCsv"), ",")
        String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchPluginsCsv"), ",")
        sourceCount = formIds.Length
        while sourceIndex < sourceCount
            Quest sourceQuest = GetQuestReactionRuntimeFormFromCsv(formIds, plugins, sourceIndex) as Quest
            if sourceQuest
                PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
                StorageUtil.SetIntValue(None, "PDV.QuestReaction.LocalFormId." + sourceQuest.GetFormID(), formIds[sourceIndex] as Int)
                registeredCount += 1
            endIf
            sourceIndex += 1
        endWhile
        Trace(1, "Quest reaction matrix used the CSV fallback (" + label + "); a split this size can truncate at the array cap.")
    endIf

    Trace(2, "Quest reaction matrix hooks refreshed (" + label + "): " + registeredCount + " of " + sourceCount + " quest entries registered.")
EndFunction

Function RegisterQuestStageList(FormList sourceList)
    if !sourceList
        return
    endIf

    Int sourceIndex = 0
    Int sourceCount = sourceList.GetSize()
    while sourceIndex < sourceCount
        Quest sourceQuest = sourceList.GetAt(sourceIndex) as Quest
        if sourceQuest
            PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
        endIf
        sourceIndex += 1
    endWhile
EndFunction

Function RegisterOrcLifeModeQuestSources()
    RegisterQuestStageByFormId(0x0003B681, "Skyrim.esm") ; DA06
    RegisterQuestStageByFormId(0x000A2C86, "Skyrim.esm") ; Favor250
    RegisterQuestStageByFormId(0x000A2C9B, "Skyrim.esm") ; Favor252
    RegisterQuestStageByFormId(0x000A2C9E, "Skyrim.esm") ; Favor253
    RegisterQuestStageByFormId(0x000A2CA6, "Skyrim.esm") ; Favor254
    RegisterQuestStageByFormId(0x000A34CE, "Skyrim.esm") ; Favor255
    RegisterQuestStageByFormId(0x000A34D4, "Skyrim.esm") ; Favor256
    RegisterQuestStageByFormId(0x000A34D7, "Skyrim.esm") ; Favor257
    RegisterQuestStageByFormId(0x000A34DE, "Skyrim.esm") ; Favor258
    RegisterQuestStageByFormId(0x00065BDF, "Skyrim.esm") ; FreeformRiftenThane
    RegisterQuestStageByFormId(0x000A7B33, "Skyrim.esm") ; HousePurchase
    RegisterQuestStageByFormId(0x0002D75C, "Skyrim.esm") ; CW02A
    RegisterQuestStageByFormId(0x000D1444, "Skyrim.esm") ; CWFinale
EndFunction

Function RegisterQuestStageByFormId(Int localFormId, String pluginName)
    Quest sourceQuest = Game.GetFormFromFile(localFormId, pluginName) as Quest
    if sourceQuest
        PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
    else
        Trace(1, "Quest-stage registration missing form " + localFormId + " from " + pluginName)
    endIf
EndFunction

; Curated-signal milestone quest sources (reserved-signal dispatch, 2026-07-12).
; DA08/MQ201 are matrix-watched and usually already registered by the matrix hook
; refresh; explicit registration keeps these routes alive even if the deployed
; matrix JSON drops them. The brawl quest is not matrix-watched at all.
Function RegisterCuratedSignalQuestSources()
    RegisterQuestStageByFormId(0x0004A37B, "Skyrim.esm") ; DA08 (The Whispering Door)
    RegisterQuestStageByFormId(0x00035D5F, "Skyrim.esm") ; MQ201 (Diplomatic Immunity)
    RegisterQuestStageByFormId(0x00047AE6, "Skyrim.esm") ; DGIntimidateQuest (brawls)
    RegisterQuestStageByFormId(0x0001CF26, "Skyrim.esm") ; MS09 (Missing in Action)
EndFunction

; Mephala WEB_WOVEN: plots the player resolves by cunning, at beats the quest
; matrix does NOT already credit to Mephala (checked 2026-07-12: DA08 has no
; Mephala matrix cell; MQ201 s250 credits Rajhin/Baan Dar/Nocturnal but not
; Mephala) - so these one-shots add no double-credit.
; Boethiah HONORABLE_DUEL: DGIntimidateQuest stage 100 is the brawl VICTORY
; fragment (the one that runs Game.IncrementStat "Brawls Won"); stages 150/180/
; 200 are cheat/loss/shutdown paths and stay silent. Brawls repeat, so this uses
; the manager's daily cap instead of a one-shot.
Function RouteCuratedMilestoneQuestStage(Quest sourceQuest, Int newStage)
    if !sourceQuest || !PDV_EventBusService
        return
    endIf

    Int questFormId = sourceQuest.GetFormID()
    if questFormId == 0x0004A37B && newStage == 60
        if MarkP2SourceRoute(sourceQuest as Form, "mephala_da08_web_woven", "po3_queststage")
            PDV_EventBusService.RouteMephalaWebWoven("da08_whispering_door")
        endIf
    elseIf questFormId == 0x00035D5F && newStage == 250
        if MarkP2SourceRoute(sourceQuest as Form, "mephala_mq201_web_woven", "po3_queststage")
            PDV_EventBusService.RouteMephalaWebWoven("mq201_diplomatic_immunity")
        endIf
    elseIf questFormId == 0x00047AE6 && newStage == 100
        PDV_EventBusService.RouteBoethiahHonorableDuel("brawl_won")
    elseIf questFormId == 0x0001CF26 && newStage == 201
        ; Talos PROTECT_WORSHIPPER (2026-07-15 owner ruling): MS09 s201 is the
        ; CompleteQuest rescue outcome (Thorald alive and free). Rescue-with-
        ; Thalmor-kills counts; plain Thalmor killing never does.
        if MarkP2SourceRoute(sourceQuest as Form, "talos_ms09_worshipper_rescued", "po3_queststage")
            PDV_EventBusService.RouteTalosWorshipperRescued("ms09_thorald_rescued")
        endIf
    endIf
EndFunction

Function EnsureKhajiitCaravanForms()
    if PDV_CaravanFormsResolved
        return
    endIf

    PDV_CaravanFormsResolved = true
    PDV_KhajiitCaravanFactionRef = Game.GetFormFromFile(0x000EB091, "Skyrim.esm") as Faction
    PDV_CaravanLeaderRisaad = Game.GetFormFromFile(0x00074340, "Skyrim.esm") as ObjectReference
    PDV_CaravanLeaderAhkari = Game.GetFormFromFile(0x0007434A, "Skyrim.esm") as ObjectReference
    PDV_CaravanLeaderMadran = Game.GetFormFromFile(0x00074345, "Skyrim.esm") as ObjectReference
    if !PDV_KhajiitCaravanFactionRef
        Trace(1, "Khajiit caravan faction failed to resolve; caravan-defense detector inert.")
    endIf
EndFunction

Bool Function IsKhajiitCaravanLeaderNearby(Actor playerRef)
    if IsCaravanLeaderLoadedNear(PDV_CaravanLeaderRisaad, playerRef)
        return true
    endIf
    if IsCaravanLeaderLoadedNear(PDV_CaravanLeaderAhkari, playerRef)
        return true
    endIf
    return IsCaravanLeaderLoadedNear(PDV_CaravanLeaderMadran, playerRef)
EndFunction

Bool Function IsCaravanLeaderLoadedNear(ObjectReference leaderRef, Actor playerRef)
    if !leaderRef || !playerRef || !leaderRef.Is3DLoaded()
        return false
    endIf

    Actor leaderActor = leaderRef as Actor
    if leaderActor && leaderActor.IsDead()
        return false
    endIf

    return leaderRef.GetDistance(playerRef) <= 2048.0
EndFunction

Function RouteP2ImmersiveSource(Form sourceForm, String sourceKind, String parentLogicalEventId = "")
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "P2 immersive source skipped: PDV_EventBusService not assigned.")
        return
    endIf

    if !sourceForm
        Trace(2, "P2 immersive source skipped: no source form.")
        return
    endIf

    Bool joinedParentEvent = False
    if parentLogicalEventId != ""
        joinedParentEvent = PDV_EventBusService.JoinLogicalDevotionalAct(parentLogicalEventId)
    endIf
    if !joinedParentEvent
        PDV_EventBusService.BeginLogicalDevotionalAct(sourceKind + "_" + sourceForm.GetFormID())
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_BretonKnightsRoadSources, sourceForm, "breton_knights_road", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(0, sourceKind + "_breton_knights_road")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonHiddenArtSources, sourceForm, "breton_hidden_art", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(1, sourceKind + "_breton_hidden_art")
        PDV_EventBusService.RouteBretonHiddenArtExposure(sourceKind + "_breton_hidden_art_" + GetBretonHiddenArtSourceToken(sourceForm))
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonGreenWaySources, sourceForm, "breton_green_way", sourceKind)
        PDV_EventBusService.RouteBretonTraditionChoice(2, sourceKind + "_breton_green_way")
        PDV_EventBusService.RouteBretonGreenWayStanding(sourceKind + "_breton_green_way")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonVowSources, sourceForm, "breton_vow", sourceKind)
        PDV_EventBusService.RouteBretonKnightlyVow(sourceKind + "_breton_vow")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonHiddenArtSpells, sourceForm, "breton_hidden_art_spell", sourceKind)
        PDV_EventBusService.RouteBretonHiddenArtExposure(sourceKind + "_breton_hidden_art_spell")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_BretonGreenWayHarvests, sourceForm, "breton_green_way_harvest", sourceKind)
        PDV_EventBusService.RouteBretonGreenWayStanding(sourceKind + "_breton_green_way_harvest")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_DunmerAzuraSources, sourceForm, "dunmer_azura", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(0, sourceKind + "_dunmer_azura")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerBoethiahSources, sourceForm, "dunmer_boethiah", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(1, sourceKind + "_dunmer_boethiah")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerMephalaSources, sourceForm, "dunmer_mephala", sourceKind)
        PDV_EventBusService.RouteDunmerReclamationFocus(2, sourceKind + "_dunmer_mephala")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_DunmerDeviationSources, sourceForm, "dunmer_deviation", sourceKind)
        PDV_EventBusService.RouteDunmerDeviationPrice(sourceKind + "_dunmer_deviation")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_ImperialCivicSources, sourceForm, "imperial_civic", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_civic_public_service")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPublicServiceSources, sourceForm, "imperial_public_service", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_public_service")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialMercySources, sourceForm, "imperial_mercy", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_mercy")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialLawfulOrderSources, sourceForm, "imperial_lawful_order", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_lawful_order")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialHonestWorkSources, sourceForm, "imperial_honest_work", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_honest_work")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialDeathDutySources, sourceForm, "imperial_death_duty", sourceKind)
        PDV_EventBusService.RouteImperialCivicService(sourceKind + "_imperial_death_duty")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPrivateTalosSources, sourceForm, "imperial_private_talos", sourceKind)
        PDV_EventBusService.RouteImperialTalosPressure(true, sourceKind + "_imperial_private_talos")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPublicTalosSources, sourceForm, "imperial_public_talos", sourceKind)
        PDV_EventBusService.RouteImperialTalosPressure(false, sourceKind + "_imperial_public_talos")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ImperialPatronCivicSources, sourceForm, "imperial_patron_civic", sourceKind)
        PDV_EventBusService.RouteImperialPatronCivicFavor(sourceKind + "_imperial_patron_civic")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_NordOldWaysSources, sourceForm, "nord_old_ways", sourceKind)
        PDV_EventBusService.RouteNordOldWaysState(sourceKind + "_nord_old_ways_ancestor")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_NordKyneTalosSources, sourceForm, "nord_kyne_talos", sourceKind)
        PDV_EventBusService.RouteNordKyneTalosContext(sourceKind + "_nord_kyne_talos_sky_road")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_NordHircineArkaySources, sourceForm, "nord_hircine_arkay", sourceKind)
        PDV_EventBusService.RouteNordHircineArkayEdge(sourceKind + "_nord_hircine_arkay_arkay")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_AltmerAurielSources, sourceForm, "altmer_auriel", sourceKind)
        PDV_EventBusService.RouteAltmerAurielFoundation(sourceKind + "_altmer_auriel")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerMagnusSources, sourceForm, "altmer_magnus", sourceKind)
        PDV_EventBusService.RouteAltmerMagnusScholarship(sourceKind + "_altmer_magnus")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerXarxesSources, sourceForm, "altmer_xarxes", sourceKind)
        PDV_EventBusService.RouteAltmerXarxesLineage(sourceKind + "_altmer_xarxes")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerTrinimacSources, sourceForm, "altmer_trinimac", sourceKind)
        PDV_EventBusService.RouteAltmerTrinimacOrthodoxy(sourceKind + "_altmer_trinimac")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerSyrabaneSources, sourceForm, "altmer_syrabane", sourceKind)
        PDV_EventBusService.RouteAltmerSyrabaneContainment(sourceKind + "_altmer_syrabane")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_AltmerLorkhanPenalties, sourceForm, "altmer_lorkhan_penalty", sourceKind)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(4, sourceKind + "_altmer_lorkhan_penalty")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianHistSources, sourceForm, "argonian_hist", sourceKind)
        PDV_EventBusService.RouteArgonianHistMaintenanceSource(sourceKind + "_argonian_hist")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianCommunitySources, sourceForm, "argonian_community", sourceKind)
        PDV_EventBusService.RouteArgonianCommunity(sourceKind + "_argonian_community")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_ArgonianSithisSources, sourceForm, "argonian_sithis", sourceKind)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment(sourceKind + "_argonian_sithis")
    endIf

    if GetOriginRaceValue() == 4
        if ShouldRouteP2Source(PDV_FLST_P2_BosmerYffreSources, sourceForm, "bosmer_yffre", sourceKind)
            PDV_EventBusService.RouteBosmerYffre(0, sourceKind + "_bosmer_yffre")
        endIf
        if ShouldRouteP2Source(PDV_FLST_P2_BosmerZenSources, sourceForm, "bosmer_zen", sourceKind)
            PDV_EventBusService.RouteBosmerZenExchange(sourceKind + "_bosmer_zen")
        endIf
        if ShouldRouteP2Source(PDV_FLST_P2_BosmerBaanDarSources, sourceForm, "bosmer_baandar", sourceKind)
            PDV_EventBusService.RouteBosmerBaanDarRoad(sourceKind + "_bosmer_baandar")
        endIf
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_KhajiitLunarSources, sourceForm, "khajiit_lunar", sourceKind)
        PDV_EventBusService.RouteKhajiitLunarSubstrate(sourceKind + "_khajiit_lunar")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_KhajiitFocusedSources, sourceForm, "khajiit_focused", sourceKind)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(0, sourceKind + "_khajiit_focused")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_OrcMalacathSources, sourceForm, "orc_malacath", sourceKind)
        PDV_EventBusService.RouteOrcMalacathConduct(0, sourceKind + "_orc_malacath")
    endIf

    if ShouldRouteP2Source(PDV_FLST_P2_RedguardSpineSources, sourceForm, "redguard_spine", sourceKind)
        PDV_EventBusService.RouteRedguardAncestorSpine(sourceKind + "_redguard_spine")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardCrownSources, sourceForm, "redguard_crown", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(0, sourceKind + "_redguard_crown")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardForebearSources, sourceForm, "redguard_forebear", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(1, sourceKind + "_redguard_forebear")
    endIf
    if ShouldRouteP2Source(PDV_FLST_P2_RedguardAshAbahSources, sourceForm, "redguard_ashabah", sourceKind)
        PDV_EventBusService.RouteRedguardSectSignal(2, sourceKind + "_redguard_ashabah")
    endIf
    PDV_EventBusService.FlushLogicalDevotionalAct()
EndFunction

Function RouteP2ImmersiveQuestStage(Quest sourceQuest, Int newStage, String parentLogicalEventId = "")
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "P2 immersive quest stage skipped: PDV_EventBusService not assigned.")
        return
    endIf

    if !sourceQuest
        Trace(2, "P2 immersive quest stage skipped: no source quest.")
        return
    endIf

    Bool joinedParentEvent = False
    if parentLogicalEventId != ""
        joinedParentEvent = PDV_EventBusService.JoinLogicalDevotionalAct(parentLogicalEventId)
    endIf
    if !joinedParentEvent
        PDV_EventBusService.BeginLogicalDevotionalAct("p2_quest_" + sourceQuest.GetFormID() + "_" + newStage)
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordOldWaysSources, sourceQuest, 155916, 160, "nord_mq104_old_ways", newStage)
        PDV_EventBusService.RouteNordOldWaysState("po3_queststage_nord_mq104_old_ordeal")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordOldWaysSources, sourceQuest, 290545, 200, "nord_mq304_old_ways", newStage)
        PDV_EventBusService.RouteNordOldWaysState("po3_queststage_nord_mq304_old_ancestor")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordKyneTalosSources, sourceQuest, 148154, 160, "nord_mq105_kyne_talos", newStage)
        PDV_EventBusService.RouteNordKyneTalosContext("po3_queststage_nord_mq105_sky_road")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BretonGreenWaySources, sourceQuest, 89282, 100, "breton_eldergleam_blessings", newStage)
        PDV_EventBusService.RouteBretonGreenWayStanding("po3_queststage_breton_eldergleam_blessings")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BretonKnightsRoadSources, sourceQuest, 135637, 200, "breton_t02_knights_road", newStage)
        PDV_EventBusService.RouteBretonTraditionChoice(0, "po3_queststage_breton_t02_knights_road")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BretonVowSources, sourceQuest, 135637, 200, "breton_t02_vow", newStage)
        PDV_EventBusService.RouteBretonKnightlyVow("po3_queststage_breton_t02_vow")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_BretonVowSources, sourceQuest, 155454, 200, "breton_ms14_vow", newStage)
        PDV_EventBusService.RouteBretonKnightlyVow("po3_queststage_breton_ms14_vow")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 118516, 200, "nord_c03_hircine_arkay", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_c03_hircine")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 118518, 200, "nord_c06_hircine_arkay", newStage)
        PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_c06_arkay")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 173210, 100, "nord_da05_hircine_hunt", newStage)
        if StorageUtil.GetIntValue(None, "PDV.P2.Nord.DA05Outcome") == 0
            StorageUtil.SetIntValue(None, "PDV.P2.Nord.DA05Outcome", 100)
            PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_da05_kill_hircine")
        endIf
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_NordHircineArkaySources, sourceQuest, 173210, 105, "nord_da05_arkay_mercy", newStage)
        if StorageUtil.GetIntValue(None, "PDV.P2.Nord.DA05Outcome") == 0
            StorageUtil.SetIntValue(None, "PDV.P2.Nord.DA05Outcome", 105)
            PDV_EventBusService.RouteNordHircineArkayEdge("po3_queststage_nord_da05_mercy_arkay")
        endIf
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerAzuraSources, sourceQuest, 166614, 100, "dunmer_da01_azura", newStage)
        PDV_EventBusService.RouteDunmerReclamationFocus(0, "po3_queststage_dunmer_da01_azura")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerDeviationSources, sourceQuest, 166614, 110, "dunmer_da01_black_star", newStage)
        PDV_EventBusService.RouteDunmerDeviationPrice("po3_queststage_dunmer_da01_black_star")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerMephalaSources, sourceQuest, 303995, 60, "dunmer_da08_mephala", newStage)
        PDV_EventBusService.RouteDunmerReclamationFocus(2, "po3_queststage_dunmer_da08_mephala")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_DunmerBoethiahSources, sourceQuest, 317654, 100, "dunmer_da02_boethiah", newStage)
        PDV_EventBusService.RouteDunmerReclamationFocus(1, "po3_queststage_dunmer_da02")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerMagnusSources, sourceQuest, 127576, 200, "altmer_mg08_magnus", newStage)
        PDV_EventBusService.RouteAltmerMagnusScholarship("po3_queststage_altmer_mg08")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 155916, 160, "altmer_mq104_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(2, "po3_queststage_altmer_mq104")
        PDV_EventBusService.RouteAltmerCrisisSource(1, "po3_queststage_altmer_mq104")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 290545, 200, "altmer_mq304_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(1, "po3_queststage_altmer_mq304")
        PDV_EventBusService.RouteAltmerCrisisSource(2, "po3_queststage_altmer_mq304")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_AltmerLorkhanPenalties, sourceQuest, 118516, 200, "altmer_c03_lorkhan", newStage)
        PDV_EventBusService.RouteAltmerLorkhanPenalty(2, "po3_queststage_altmer_c03")
        PDV_EventBusService.RouteAltmerCrisisSource(4, "po3_queststage_altmer_c03")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_ArgonianSithisSources, sourceQuest, 125520, 200, "argonian_db01_sithis", newStage)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment("po3_queststage_argonian_db01")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ArgonianSithisSources, sourceQuest, 125529, 200, "argonian_db11_sithis", newStage)
        PDV_EventBusService.RouteArgonianSithisAcknowledgment("po3_queststage_argonian_db11")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ArgonianCommunitySources, sourceQuest, 486218, 200, "argonian_derkeethus_community", newStage)
        PDV_EventBusService.RouteArgonianCommunity("po3_queststage_argonian_derkeethus")
    endIf

    if GetOriginRaceValue() == 4
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 173210, 100, "bosmer_da05_yffre_hunt", "bosmer_da05_yffre_outcome", newStage)
            PDV_EventBusService.RouteBosmerYffre(0, "po3_queststage_bosmer_da05_kill")
        endIf
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 173210, 105, "bosmer_da05_yffre_mercy", "bosmer_da05_yffre_outcome", newStage)
            PDV_EventBusService.RouteBosmerYffre(1, "po3_queststage_bosmer_da05_mercy")
        endIf
        if ShouldRouteP2QuestStage(PDV_FLST_P2_BosmerYffreSources, sourceQuest, 127576, 200, "bosmer_mg08_living_story", newStage)
            PDV_EventBusService.RouteBosmerYffre(1, "po3_queststage_bosmer_mg08")
        endIf
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerZenSources, sourceQuest, 235077, 100, "bosmer_ms13_zen_lucan", "bosmer_ms13_zen_return", newStage)
            PDV_EventBusService.RouteBosmerZenExchange("po3_queststage_bosmer_ms13_lucan")
        endIf
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerZenSources, sourceQuest, 235077, 110, "bosmer_ms13_zen_camilla", "bosmer_ms13_zen_return", newStage)
            PDV_EventBusService.RouteBosmerZenExchange("po3_queststage_bosmer_ms13_camilla")
        endIf
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerBaanDarSources, sourceQuest, 264798, 100, "bosmer_ms02_baandar_madanach", "bosmer_ms02_baandar_escape", newStage)
            PDV_EventBusService.RouteBosmerBaanDarRoad("po3_queststage_bosmer_ms02_madanach")
        endIf
        if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_BosmerBaanDarSources, sourceQuest, 264798, 250, "bosmer_ms02_baandar_pardon", "bosmer_ms02_baandar_escape", newStage)
            PDV_EventBusService.RouteBosmerBaanDarRoad("po3_queststage_bosmer_ms02_pardon")
        endIf
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitLunarSources, sourceQuest, 155916, 160, "khajiit_mq104_lunar", newStage)
        PDV_EventBusService.RouteKhajiitLunarSubstrate("po3_queststage_khajiit_mq104_lunar")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitLunarSources, sourceQuest, 166614, 100, "khajiit_da01_lunar", newStage)
        PDV_EventBusService.RouteKhajiitLunarSubstrate("po3_queststage_khajiit_da01_lunar")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitFocusedSources, sourceQuest, 155916, 160, "khajiit_mq104_alkosh", newStage)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(5, "po3_queststage_khajiit_mq104")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_KhajiitFocusedSources, sourceQuest, 166614, 100, "khajiit_da01_azurah", newStage)
        PDV_EventBusService.RouteKhajiitFocusedEmphasis(2, "po3_queststage_khajiit_da01")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_OrcMalacathSources, sourceQuest, 243329, 200, "orc_da06_malacath", newStage)
        PDV_EventBusService.RouteOrcMalacathConduct(1, "po3_queststage_orc_da06")
    endIf
    RouteOrcLifeModeQuestStage(sourceQuest, newStage)

    if ShouldRouteP2QuestStage(PDV_FLST_P2_RedguardCrownSources, sourceQuest, 118565, 201, "redguard_ms08_crown", newStage)
        PDV_EventBusService.RouteRedguardSectSignal(0, "po3_queststage_redguard_ms08_crown")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_RedguardForebearSources, sourceQuest, 118565, 200, "redguard_ms08_forebear", newStage)
        PDV_EventBusService.RouteRedguardSectSignal(1, "po3_queststage_redguard_ms08_forebear")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_RedguardAshAbahSources, sourceQuest, 514377, 20, "redguard_da11intro_ashabah_duty", newStage)
        PDV_EventBusService.RouteRedguardSectSignal(2, "po3_queststage_redguard_da11intro_ashabah")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialCivicSources, sourceQuest, 854016, 190, "imperial_mq103_civic", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_mq103_civic_public_service")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialPublicServiceSources, sourceQuest, 186204, 200, "imperial_cw02a_public_service", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_cw02a_public_service")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialMercySources, sourceQuest, 118565, 200, "imperial_ms08_mercy", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_ms08_mercy")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialLawfulOrderSources, sourceQuest, 118565, 201, "imperial_ms08_lawful_order", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_ms08_lawful_order")
    endIf
    if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_ImperialHonestWorkSources, sourceQuest, 235077, 100, "imperial_ms13_honest_work_lucan", "imperial_ms13_honest_work", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_ms13_honest_work_lucan")
    endIf
    if ShouldRouteP2QuestStageGroup(PDV_FLST_P2_ImperialHonestWorkSources, sourceQuest, 235077, 110, "imperial_ms13_honest_work_camilla", "imperial_ms13_honest_work", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_ms13_honest_work_camilla")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialDeathDutySources, sourceQuest, 155454, 200, "imperial_ms14_death_duty", newStage)
        PDV_EventBusService.RouteImperialCivicService("po3_queststage_imperial_ms14_death_duty")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialPrivateTalosSources, sourceQuest, 220511, 250, "imperial_mq201_private_talos", newStage)
        PDV_EventBusService.RouteImperialTalosPressure(true, "po3_queststage_imperial_mq201_private_talos")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_P2_ImperialPatronCivicSources, sourceQuest, 135637, 200, "imperial_t02_patron_civic", newStage)
        PDV_EventBusService.RouteImperialPatronCivicFavor("po3_queststage_imperial_t02_patron_civic")
    endIf

    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_AzuraLiveSources, sourceQuest, 166614, 100, "daedric_azura_da01", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(1, "po3_queststage_daedric_azura_da01")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_BoethiahLiveSources, sourceQuest, 317654, 100, "daedric_boethiah_da02", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(0, "po3_queststage_daedric_boethiah_da02")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_VaerminaLiveSources, sourceQuest, 148143, 190, "daedric_vaermina_da16", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(2, "po3_queststage_daedric_vaermina_da16")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_MeridiaLiveSources, sourceQuest, 320737, 500, "daedric_meridia_da09", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(3, "po3_queststage_daedric_meridia_da09")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_MolagLiveSources, sourceQuest, 143112, 200, "daedric_molag_da10", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(4, "po3_queststage_daedric_molag_da10")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_MephalaLiveSources, sourceQuest, 303995, 60, "daedric_mephala_da08", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(5, "po3_queststage_daedric_mephala_da08")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_HircineLiveSources, sourceQuest, 173210, 100, "daedric_hircine_da05", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(15, "po3_queststage_daedric_hircine_da05")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_MalacathLiveSources, sourceQuest, 243329, 200, "daedric_malacath_da06", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(6, "po3_queststage_daedric_malacath_da06")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_DagonLiveSources, sourceQuest, 147640, 100, "daedric_dagon_da07", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(7, "po3_queststage_daedric_dagon_da07")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_SheoLiveSources, sourceQuest, 175208, 200, "daedric_sheo_da15", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(8, "po3_queststage_daedric_sheo_da15")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_NamiraLiveSources, sourceQuest, 181080, 100, "daedric_namira_da11", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(9, "po3_queststage_daedric_namira_da11")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_SanguineLiveSources, sourceQuest, 113563, 200, "daedric_sanguine_da14", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(10, "po3_queststage_daedric_sanguine_da14")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_VileLiveSources, sourceQuest, 114628, 200, "daedric_vile_da03", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(11, "po3_queststage_daedric_vile_da03")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_MoraLiveSources, sourceQuest, 185618, 100, "daedric_mora_da04", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(12, "po3_queststage_daedric_mora_da04")
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_NocturnalLiveSources, sourceQuest, 136533, 200, "daedric_nocturnal_tg09", newStage)
        Int resolvedStage = ResolveQuestReactionStageAdapter(sourceQuest, newStage)
        if resolvedStage == 200
            PDV_EventBusService.RouteDaedricPrinceSignal(13, "po3_queststage_daedric_nocturnal_tg09")
        else
            Trace(2, "Quest-stage adapter suppressed Nocturnal commitment: physical=200 matrixStage=" + resolvedStage)
        endIf
    endIf
    if ShouldRouteP2QuestStage(PDV_FLST_Daedric_PeryiteLiveSources, sourceQuest, 563597, 100, "daedric_peryite_da13", newStage)
        PDV_EventBusService.RouteDaedricPrinceSignal(14, "po3_queststage_daedric_peryite_da13")
    endIf
    PDV_EventBusService.FlushLogicalDevotionalAct()
EndFunction

Function RouteOrcLifeModeQuestStage(Quest sourceQuest, Int newStage)
    if GetOriginRaceValue() != 8 || !sourceQuest || !PDV_EventBusService
        return
    endIf

    Int questFormId = sourceQuest.GetFormID()
    if questFormId == 0x0003B681 && newStage == 200
        if MarkP2SourceRoute(sourceQuest as Form, "orc_da06_bloodkin_stage_200", "po3_queststage")
            PDV_EventBusService.RouteOrcBloodKinCrisis("orc_cursed_tribe_resolved")
        endIf
    endIf

    if newStage == 200 && IsOrcCityThaneQuest(questFormId)
        if MarkP2SourceRoute(sourceQuest as Form, "orc_city_thane_stage_200", "po3_queststage")
            PDV_EventBusService.RouteOrcCityDignity("po3_queststage_orc_city_thane")
        endIf
    endIf

    if questFormId == 0x000A7B33 && newStage == 10
        if MarkP2SourceRoute(sourceQuest as Form, "orc_city_home_stage_10", "po3_queststage")
            PDV_EventBusService.RouteOrcSelfMadeCommunity("po3_queststage_orc_city_home")
        endIf
    endIf

    if questFormId == 0x0002D75C && newStage == 200
        if MarkP2SourceRoute(sourceQuest as Form, "orc_cw02a_jagged_crown_stage_200", "po3_queststage")
            PDV_EventBusService.RouteOrcLegionService("po3_queststage_orc_cw02a")
        endIf
    endIf

    if questFormId == 0x000D1444 && newStage == 500 && IsPlayerInImperialFaction()
        if MarkP2SourceRoute(sourceQuest as Form, "orc_cwfinale_imperial_stage_500", "po3_queststage")
            PDV_EventBusService.RouteOrcLegionService("po3_queststage_orc_cwfinale_imperial")
        endIf
    endIf
EndFunction

Bool Function IsOrcCityThaneQuest(Int questFormId)
    return questFormId == 0x000A2C86 || questFormId == 0x000A2C9B || questFormId == 0x000A2C9E || questFormId == 0x000A2CA6 || questFormId == 0x000A34CE || questFormId == 0x000A34D4 || questFormId == 0x000A34D7 || questFormId == 0x000A34DE || questFormId == 0x00065BDF
EndFunction

Bool Function IsPlayerInImperialFaction()
    Actor playerActor = Game.GetPlayer()
    if !playerActor
        return false
    endIf

    Faction imperialFactionRef = Game.GetFormFromFile(0x0002BF9A, "Skyrim.esm") as Faction
    if !imperialFactionRef
        return false
    endIf

    return playerActor.IsInFaction(imperialFactionRef)
EndFunction

Function RouteQuestReactionStage(Quest sourceQuest, Int newStage, String logicalEventId = "")
    if !sourceQuest || !PDV_EventBusService
        return
    endIf

    Int resolvedStage = ResolveQuestReactionStageAdapter(sourceQuest, newStage)
    PDV_EventBusService.RouteQuestReaction(sourceQuest, resolvedStage, logicalEventId)
EndFunction

Int Function ResolveQuestReactionStageAdapter(Quest sourceQuest, Int newStage)
    ; Each opt-in JSON adapter identifies a watched quest by its owning plugin and
    ; local FormID, then maps an installed GlobalVariable value to a synthetic
    ; matrix stage. Missing, malformed, or non-matching adapters preserve the
    ; physical stage.
    if !sourceQuest
        return newStage
    endIf

    Int adapterIndex = 0
    Int adapterCount = StorageUtil.StringListCount(None, "PDV.QR.StageAdapterFiles")
    while adapterIndex < adapterCount
        String adapterFile = StorageUtil.StringListGet(None, "PDV.QR.StageAdapterFiles", adapterIndex)
        String sourcePlugin = JsonUtil.GetStringValue(adapterFile, "sourcePlugin")
        Int sourceFormId = JsonUtil.GetIntValue(adapterFile, "sourceFormId")
        Int sourceStage = JsonUtil.GetIntValue(adapterFile, "sourceStage")
        if sourcePlugin != "" && sourceStage == newStage && Game.GetModByName(sourcePlugin) != 255
            Quest configuredQuest = Game.GetFormFromFile(sourceFormId, sourcePlugin) as Quest
            if configuredQuest == sourceQuest
                String selectorPlugin = JsonUtil.GetStringValue(adapterFile, "selectorPlugin")
                Int selectorFormId = JsonUtil.GetIntValue(adapterFile, "selectorFormId")
                if selectorPlugin != "" && Game.GetModByName(selectorPlugin) != 255
                    GlobalVariable selector = Game.GetFormFromFile(selectorFormId, selectorPlugin) as GlobalVariable
                    if selector
                        Int selectorValue = selector.GetValueInt()
                        Int valueIndex = 0
                        Int valueCount = JsonUtil.IntListCount(adapterFile, "selectorValues")
                        while valueIndex < valueCount
                            if JsonUtil.IntListGet(adapterFile, "selectorValues", valueIndex) == selectorValue
                                Int targetStage = JsonUtil.IntListGet(adapterFile, "targetStages", valueIndex)
                                if targetStage > 0
                                    Trace(2, "Quest-stage adapter route: " + adapterFile + " physical=" + newStage + " selector=" + selectorValue + " matrixStage=" + targetStage)
                                    return targetStage
                                endIf
                            endIf
                            valueIndex += 1
                        endWhile
                    endIf
                endIf
            endIf
        endIf
        adapterIndex += 1
    endWhile
    return newStage
EndFunction

Function RouteQuestReactionBookFaucet(Form sourceForm, Bool firstRead)
    if !sourceForm || !PDV_EventBusService
        return
    endIf

    if !IsCachedQuestReactionFaucetForm(sourceForm)
        return
    endIf

    ; The once-per-day faucets only credit unread books; forbidden_knowledge keeps
    ; its own once-ever per-form guard in the manager and routes regardless.
    if firstRead && ShouldRouteQuestReactionFaucet("Azura.fate_threshold", "faucetForms.Azura.fate_threshold", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Azura.fate_threshold", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Hermaeus Mora.forbidden_knowledge", "faucetForms.Hermaeus Mora.forbidden_knowledge", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Hermaeus Mora.forbidden_knowledge", sourceForm)
    endIf
    if firstRead && ShouldRouteQuestReactionFaucet("Hermaeus Mora.disciplined_study", "faucetForms.Hermaeus Mora.disciplined_study", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Hermaeus Mora.disciplined_study", sourceForm)
    endIf
EndFunction

Function RouteQuestReactionObjectFaucet(Form sourceForm)
    if !sourceForm || !PDV_EventBusService
        return
    endIf

    ; 12.2. This runs on EVERY equip. One cache pass decides whether any of the fifteen
    ; checks below can possibly match; for all ordinary gear it does not, and we leave.
    if !IsCachedQuestReactionFaucetForm(sourceForm)
        return
    endIf

    if ShouldRouteQuestReactionFaucet("Namira.cannibalism", "faucetForms.Namira.cannibalism", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Namira.cannibalism", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Sanguine.revel_indulge", "faucetForms.Sanguine.revel_indulge", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Sanguine.revel_indulge", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Sanguine.revel_indulge_skooma", "faucetForms.Sanguine.revel_indulge_skooma", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Sanguine.revel_indulge_skooma", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Clavicus Vile.serve_a_daedra:clavicus", "faucetForms.Clavicus Vile.serve_a_daedra:clavicus", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Clavicus Vile.serve_a_daedra:clavicus", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Vaermina.serve_a_daedra:vaermina", "faucetForms.Vaermina.serve_a_daedra:vaermina", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Vaermina.serve_a_daedra:vaermina", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Boethiah.serve_a_daedra:boethiah", "faucetForms.Boethiah.serve_a_daedra:boethiah", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Boethiah.serve_a_daedra:boethiah", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Mephala.serve_a_daedra:mephala", "faucetForms.Mephala.serve_a_daedra:mephala", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Mephala.serve_a_daedra:mephala", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Malacath.serve_a_daedra:malacath", "faucetForms.Malacath.serve_a_daedra:malacath", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Malacath.serve_a_daedra:malacath", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Molag Bal.serve_a_daedra:molagbal", "faucetForms.Molag Bal.serve_a_daedra:molagbal", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Molag Bal.serve_a_daedra:molagbal", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Hircine.serve_a_daedra:hircine", "faucetForms.Hircine.serve_a_daedra:hircine", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Hircine.serve_a_daedra:hircine", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Meridia.serve_a_daedra:meridia", "faucetForms.Meridia.serve_a_daedra:meridia", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Meridia.serve_a_daedra:meridia", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Sheogorath.serve_a_daedra:sheogorath", "faucetForms.Sheogorath.serve_a_daedra:sheogorath", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Sheogorath.serve_a_daedra:sheogorath", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Mehrunes Dagon.serve_a_daedra:mehrunesdagon", "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunesdagon", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Mehrunes Dagon.serve_a_daedra:mehrunesdagon", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Nocturnal.serve_a_daedra:nocturnal", "faucetForms.Nocturnal.serve_a_daedra:nocturnal", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Nocturnal.serve_a_daedra:nocturnal", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Dibella.aesthetic_devotion", "faucetForms.Dibella.aesthetic_devotion", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Dibella.aesthetic_devotion", sourceForm)
    endIf
EndFunction

Function RouteQuestReactionSpellFaucet(Form sourceForm)
    if !sourceForm || !PDV_EventBusService
        return
    endIf

    if !PDV_QuestReactionSpellFaucetCacheReady
        CacheQuestReactionSpellFaucetForms()
    endIf

    if MatchesCachedQuestReactionSpellFaucet(sourceForm, PDV_QRSpellSanguine0, PDV_QRSpellSanguine1)
        PDV_EventBusService.RouteQuestReactionFaucet("Sanguine.serve_a_daedra:sanguine", sourceForm)
    endIf
    if MatchesCachedQuestReactionSpellFaucet(sourceForm, PDV_QRSpellVaermina0, PDV_QRSpellVaermina1)
        PDV_EventBusService.RouteQuestReactionFaucet("Vaermina.serve_a_daedra:vaermina", sourceForm)
    endIf
    if MatchesCachedQuestReactionSpellFaucet(sourceForm, PDV_QRSpellSheogorathFire0, PDV_QRSpellSheogorathFire1)
        PDV_EventBusService.RouteQuestReactionFaucet("Sheogorath.serve_a_daedra:sheogorath_fire", sourceForm)
    endIf
EndFunction

Bool Function MatchesCachedQuestReactionSpellFaucet(Form sourceForm, Form sourceA, Form sourceB)
    if !sourceForm
        return false
    endIf

    if sourceA && sourceForm == sourceA
        return true
    endIf

    if sourceB && sourceForm == sourceB
        return true
    endIf

    return false
EndFunction

Function RouteQuestReactionMagicEffectFaucet(Form sourceForm)
    if !sourceForm || !PDV_EventBusService
        return
    endIf

    if ShouldRouteQuestReactionFaucet("Namira.cannibalism", "faucetEffectForms.Namira.cannibalism", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Namira.cannibalism", sourceForm)
    endIf
    if ShouldRouteQuestReactionFaucet("Dibella.charity", "faucetEffectForms.Dibella.charity", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Dibella.charity", sourceForm)
    endIf
EndFunction

Function RouteQuestReactionBlockedHitFaucet()
    if !PDV_EventBusService
        return
    endIf

    ; 12.2. This is the blocked-hit path -- for a Requiem shield user it fires constantly.
    ; GetActorRef() is the alias's own actor (the player) and is what OnHitEx above already
    ; uses; Game.GetPlayer() was a second, more expensive way to reach the same reference.
    Actor playerRef = GetActorRef()
    if !playerRef
        return
    endIf

    Form shieldForm = playerRef.GetEquippedShield() as Form
    if ShouldRouteQuestReactionFaucet("Peryite.serve_a_daedra:peryite", "faucetForms.Peryite.serve_a_daedra:peryite", shieldForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Peryite.serve_a_daedra:peryite", shieldForm)
    endIf
EndFunction

; 12.2 / audit C2. Was: a JsonExists probe, two JSON string reads, two StringUtil.Splits
; and then a Game.GetModByName (linear over the whole plugin list) + Game.GetFormFromFile
; PER MATRIX ENTRY -- every time, on every equip, 16 times over. Now: a scan of the cache
; built once per load, with no native call on the path at all. The Form compare is first
; in the && so the String compare only ever runs on a genuine form hit.
Bool Function ShouldRouteQuestReactionFaucet(String faucetKey, String listKey, Form sourceForm)
    if !sourceForm
        return false
    endIf

    if !PDV_QuestReactionFaucetCacheReady
        CacheQuestReactionFaucetForms()
    endIf

    Int cacheIndex = 0
    Int cacheCount = PDV_QuestReactionFaucetCacheCount
    while cacheIndex < cacheCount
        if PDV_QuestReactionFaucetForms[cacheIndex] == sourceForm && PDV_QuestReactionFaucetListKeys[cacheIndex] == listKey
            return true
        endIf
        cacheIndex += 1
    endWhile

    return false
EndFunction

; 12.2. The cheap early-out for the multi-key faucet routers. Almost every form the
; player ever equips, reads or is hit by is in NO faucet list, and answering that takes
; one pass over the cache instead of one pass per key.
Bool Function IsCachedQuestReactionFaucetForm(Form sourceForm)
    if !sourceForm
        return false
    endIf

    if !PDV_QuestReactionFaucetCacheReady
        CacheQuestReactionFaucetForms()
    endIf

    Int cacheIndex = 0
    Int cacheCount = PDV_QuestReactionFaucetCacheCount
    while cacheIndex < cacheCount
        if PDV_QuestReactionFaucetForms[cacheIndex] == sourceForm
            return true
        endIf
        cacheIndex += 1
    endWhile

    return false
EndFunction

Form Function GetQuestReactionRuntimeForm(String listKey, Int entryIndex)
    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionFormIdCsvKey(listKey)), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionPluginCsvKey(listKey)), ",")
    return GetQuestReactionRuntimeFormFromCsv(formIds, plugins, entryIndex)
EndFunction

Form Function GetQuestReactionRuntimeFormFromCsv(String[] formIds, String[] plugins, Int entryIndex)
    if entryIndex < 0 || entryIndex >= formIds.Length || entryIndex >= plugins.Length
        return None
    endIf

    return GetQuestReactionRuntimeFormFromEntry(formIds[entryIndex], plugins[entryIndex])
EndFunction

Form Function GetQuestReactionRuntimeFormFromEntry(String formIdString, String pluginName)
    Int localFormId = formIdString as Int
    if localFormId <= 0 || pluginName == ""
        return None
    endIf

    if Game.GetModByName(pluginName) == 255
        return None
    endIf

    return Game.GetFormFromFile(localFormId, pluginName)
EndFunction

; 12.2 / audit C2 -- HasQuestReactionRuntimeForm used to live here. It re-read and
; re-resolved a faucet list from the matrix JSON on every single call, which is the whole
; of C2's cost. Its only caller was ShouldRouteQuestReactionFaucet, which now answers from
; the cache CacheQuestReactionFaucetForms builds once per load, so the function is deleted
; rather than left as a second, slower way to ask the same question.

Function ReloadQuestReactionMatrixJson()
    ReloadQuestReactionMatrixJsonFile(QUEST_REACTION_MATRIX_FILE)
    CacheQuestReactionSpellFaucetForms()
    ; 12.2. The faucet cache is derived from this file, so a reload must rebuild it or the
    ; runtime would keep answering from the pre-reload matrix.
    CacheQuestReactionFaucetForms()
EndFunction

Function ReloadQuestReactionMatrixJsonFile(String matrixFile)
    JsonUtil.Unload(matrixFile, false)
    if !JsonUtil.Load(matrixFile)
        Trace(1, "Quest reaction matrix JSON load failed: " + JsonUtil.GetErrors(matrixFile))
    elseIf !JsonUtil.IsGood(matrixFile)
        Trace(1, "Quest reaction matrix JSON parse failed: " + JsonUtil.GetErrors(matrixFile))
    endIf
EndFunction

String Function GetQuestReactionFormIdKey(String listKey)
    if listKey == "questWatch"
        return "questWatchFormIds"
    elseIf listKey == "faucetForms.Namira.cannibalism"
        return "faucetFormsNamiraCannibalismFormIds"
    elseIf listKey == "faucetForms.Sanguine.revel_indulge"
        return "faucetFormsSanguineRevelIndulgeFormIds"
    elseIf listKey == "faucetForms.Sanguine.revel_indulge_skooma"
        return "faucetFormsSanguineRevelIndulgeSkoomaFormIds"
    elseIf listKey == "faucetForms.Hermaeus Mora.forbidden_knowledge"
        return "faucetFormsHermaeusMoraForbiddenKnowledgeFormIds"
    elseIf listKey == "faucetForms.Hermaeus Mora.disciplined_study"
        return "faucetFormsHermaeusMoraDisciplinedStudyFormIds"
    elseIf listKey == "faucetForms.Azura.fate_threshold"
        return "faucetFormsAzuraFateThresholdFormIds"
    elseIf listKey == "faucetForms.Dibella.aesthetic_devotion"
        return "faucetFormsDibellaAestheticDevotionFormIds"
    elseIf listKey == "faucetForms.Clavicus Vile.serve_a_daedra:clavicus"
        return "faucetFormsClavicusVileServeADaedraClavicusFormIds"
    elseIf listKey == "faucetForms.Peryite.serve_a_daedra:peryite"
        return "faucetFormsPeryiteServeADaedraPeryiteFormIds"
    elseIf listKey == "faucetForms.Vaermina.serve_a_daedra:vaermina"
        return "faucetFormsVaerminaServeADaedraVaerminaFormIds"
    elseIf listKey == "faucetForms.Boethiah.serve_a_daedra:boethiah"
        return "faucetFormsBoethiahServeADaedraBoethiahFormIds"
    elseIf listKey == "faucetForms.Mephala.serve_a_daedra:mephala"
        return "faucetFormsMephalaServeADaedraMephalaFormIds"
    elseIf listKey == "faucetForms.Malacath.serve_a_daedra:malacath"
        return "faucetFormsMalacathServeADaedraMalacathFormIds"
    elseIf listKey == "faucetForms.Molag Bal.serve_a_daedra:molagbal"
        return "faucetFormsMolagBalServeADaedraMolagBalFormIds"
    elseIf listKey == "faucetForms.Hircine.serve_a_daedra:hircine"
        return "faucetFormsHircineServeADaedraHircineFormIds"
    elseIf listKey == "faucetForms.Meridia.serve_a_daedra:meridia"
        return "faucetFormsMeridiaServeADaedraMeridiaFormIds"
    elseIf listKey == "faucetForms.Sheogorath.serve_a_daedra:sheogorath"
        return "faucetFormsSheogorathServeADaedraSheogorathFormIds"
    elseIf listKey == "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunesdagon"
        return "faucetFormsMehrunesDagonServeADaedraMehrunesDagonFormIds"
    elseIf listKey == "faucetForms.Nocturnal.serve_a_daedra:nocturnal"
        return "faucetFormsNocturnalServeADaedraNocturnalFormIds"
    elseIf listKey == "faucetSpellForms.Sanguine.serve_a_daedra:sanguine"
        return "faucetSpellFormsSanguineServeADaedraSanguineFormIds"
    elseIf listKey == "faucetSpellForms.Vaermina.serve_a_daedra:vaermina"
        return "faucetSpellFormsVaerminaServeADaedraVaerminaFormIds"
    elseIf listKey == "faucetSpellForms.Sheogorath.serve_a_daedra:sheogorath_fire"
        return "faucetSpellFormsSheogorathServeADaedraSheogorathFireFormIds"
    elseIf listKey == "faucetEffectForms.Namira.cannibalism"
        return "faucetEffectFormsNamiraCannibalismFormIds"
    elseIf listKey == "faucetEffectForms.Dibella.charity"
        return "faucetEffectFormsDibellaCharityFormIds"
    endIf

    return ""
EndFunction

String Function GetQuestReactionPluginKey(String listKey)
    if listKey == "questWatch"
        return "questWatchPlugins"
    elseIf listKey == "faucetForms.Namira.cannibalism"
        return "faucetFormsNamiraCannibalismPlugins"
    elseIf listKey == "faucetForms.Sanguine.revel_indulge"
        return "faucetFormsSanguineRevelIndulgePlugins"
    elseIf listKey == "faucetForms.Sanguine.revel_indulge_skooma"
        return "faucetFormsSanguineRevelIndulgeSkoomaPlugins"
    elseIf listKey == "faucetForms.Hermaeus Mora.forbidden_knowledge"
        return "faucetFormsHermaeusMoraForbiddenKnowledgePlugins"
    elseIf listKey == "faucetForms.Hermaeus Mora.disciplined_study"
        return "faucetFormsHermaeusMoraDisciplinedStudyPlugins"
    elseIf listKey == "faucetForms.Azura.fate_threshold"
        return "faucetFormsAzuraFateThresholdPlugins"
    elseIf listKey == "faucetForms.Dibella.aesthetic_devotion"
        return "faucetFormsDibellaAestheticDevotionPlugins"
    elseIf listKey == "faucetForms.Clavicus Vile.serve_a_daedra:clavicus"
        return "faucetFormsClavicusVileServeADaedraClavicusPlugins"
    elseIf listKey == "faucetForms.Peryite.serve_a_daedra:peryite"
        return "faucetFormsPeryiteServeADaedraPeryitePlugins"
    elseIf listKey == "faucetForms.Vaermina.serve_a_daedra:vaermina"
        return "faucetFormsVaerminaServeADaedraVaerminaPlugins"
    elseIf listKey == "faucetForms.Boethiah.serve_a_daedra:boethiah"
        return "faucetFormsBoethiahServeADaedraBoethiahPlugins"
    elseIf listKey == "faucetForms.Mephala.serve_a_daedra:mephala"
        return "faucetFormsMephalaServeADaedraMephalaPlugins"
    elseIf listKey == "faucetForms.Malacath.serve_a_daedra:malacath"
        return "faucetFormsMalacathServeADaedraMalacathPlugins"
    elseIf listKey == "faucetForms.Molag Bal.serve_a_daedra:molagbal"
        return "faucetFormsMolagBalServeADaedraMolagBalPlugins"
    elseIf listKey == "faucetForms.Hircine.serve_a_daedra:hircine"
        return "faucetFormsHircineServeADaedraHircinePlugins"
    elseIf listKey == "faucetForms.Meridia.serve_a_daedra:meridia"
        return "faucetFormsMeridiaServeADaedraMeridiaPlugins"
    elseIf listKey == "faucetForms.Sheogorath.serve_a_daedra:sheogorath"
        return "faucetFormsSheogorathServeADaedraSheogorathPlugins"
    elseIf listKey == "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunesdagon"
        return "faucetFormsMehrunesDagonServeADaedraMehrunesDagonPlugins"
    elseIf listKey == "faucetForms.Nocturnal.serve_a_daedra:nocturnal"
        return "faucetFormsNocturnalServeADaedraNocturnalPlugins"
    elseIf listKey == "faucetSpellForms.Sanguine.serve_a_daedra:sanguine"
        return "faucetSpellFormsSanguineServeADaedraSanguinePlugins"
    elseIf listKey == "faucetSpellForms.Vaermina.serve_a_daedra:vaermina"
        return "faucetSpellFormsVaerminaServeADaedraVaerminaPlugins"
    elseIf listKey == "faucetSpellForms.Sheogorath.serve_a_daedra:sheogorath_fire"
        return "faucetSpellFormsSheogorathServeADaedraSheogorathFirePlugins"
    elseIf listKey == "faucetEffectForms.Namira.cannibalism"
        return "faucetEffectFormsNamiraCannibalismPlugins"
    elseIf listKey == "faucetEffectForms.Dibella.charity"
        return "faucetEffectFormsDibellaCharityPlugins"
    endIf

    return ""
EndFunction

String Function GetQuestReactionFormIdCsvKey(String listKey)
    return GetQuestReactionFormIdKey(listKey) + "Csv"
EndFunction

String Function GetQuestReactionPluginCsvKey(String listKey)
    return GetQuestReactionPluginKey(listKey) + "Csv"
EndFunction

Bool Function ShouldRouteP2Source(FormList sourceList, Form sourceForm, String routeKey, String sourceKind)
    if !HasListedForm(sourceList, sourceForm)
        return false
    endIf

    if !MarkP2SourceRoute(sourceForm, routeKey, sourceKind)
        Trace(2, "P2 immersive source repeat skipped: " + routeKey)
        return false
    endIf

    return true
EndFunction

Bool Function ShouldRouteP2QuestStage(FormList sourceList, Quest sourceQuest, Int expectedFormId, Int approvedStage, String routeKey, Int newStage)
    if newStage != approvedStage
        return false
    endIf

    if sourceQuest.GetFormID() != expectedFormId
        return false
    endIf

    return ShouldRouteP2Source(sourceList, sourceQuest as Form, routeKey + "_stage_" + approvedStage, "po3_queststage")
EndFunction

Bool Function ShouldRouteP2QuestStageGroup(FormList sourceList, Quest sourceQuest, Int expectedFormId, Int approvedStage, String routeKey, String groupKey, Int newStage)
    if newStage != approvedStage
        return false
    endIf

    if sourceQuest.GetFormID() != expectedFormId
        return false
    endIf

    if !HasListedForm(sourceList, sourceQuest as Form)
        return false
    endIf

    if !MarkP2SourceRoute(sourceQuest as Form, groupKey, "po3_queststage")
        Trace(2, "P2 immersive source repeat skipped: " + routeKey + " group " + groupKey)
        return false
    endIf

    return true
EndFunction

Bool Function MarkP2SourceRoute(Form sourceForm, String routeKey, String sourceKind)
    if !sourceForm
        return false
    endIf

    String baseKey = "PDV.P2Source." + routeKey + "." + sourceForm.GetFormID()
    if sourceKind == "po3_weather" || sourceKind == "po3_harvest"
        ; Store a zero-reserved day stamp: StorageUtil int keys default to 0, and game
        ; day 0 as Int is also 0, so a raw day key would silently suppress every
        ; harvest/weather route on the first in-game day (storageutil-day-key-zero-default
        ; class -- the same one B13 hit in ConsumeShrinePrayerCredit). fix-plan 4.2 moves
        ; it from the raw-midnight day onto the 06:00 devotional day with the shared +2.
        Int currentDayMark = GetDevotionalDayStamp()
        String dayKey = baseKey + ".Day"
        if StorageUtil.GetIntValue(None, dayKey) == currentDayMark
            return false
        endIf

        StorageUtil.SetIntValue(None, dayKey, currentDayMark)
        return true
    endIf

    String seenKey = baseKey + ".Seen"
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return false
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    return true
EndFunction

; P15 (2026-08-03). In-game days before an already-read book can credit again.
Float Property BOOK_REREAD_COOLDOWN_DAYS = 30.0 AutoReadOnly

; P15 (2026-08-03): books used to be a ONE-SHOT HARVEST. The `.Seen` flag was set once and never
; cleared, so a library was consumed rather than practised -- `dailyCap: 3` on read-lore-book
; actually meant "three different UNREAD books today", a finite world pool masquerading as a
; faucet. Once a player had read everything, the whole reading lane paid zero forever, which hit
; the scholar deities (Xarxes, Magnus, Auri-El) hardest and inverted the theology.
;
; DEVIATION FROM THE APPROVED SPEC, deliberate and flagged: the plan called for re-reads to credit
; at 25%. The `firstRead` return here is a pure GATE -- `RouteGenericBookRead` drops the event
; entirely when it is false, and the actual delta comes from ScoreFromTable much further
; downstream. Scaling a re-read would mean threading a multiplier through RouteGenericAction, the
; SHARED router for every event type in the mod. That is far outside this packet's blast radius,
; so re-reads credit at FULL value and the existing per-row dailyCap plus the global
; PIETY_DAILY_MAX_DELTA do the balancing: the daily ceiling does not move, only the lane's
; lifespan. Revisit if playtest shows it is too soft.
;
; MarkP2SourceRoute is deliberately untouched -- curated P2 heritage books stay once-ever. Those
; are authored beats, not practice.
Bool Function MarkGenericBookRead(Form bookForm)
    if !bookForm
        return false
    endIf

    Float nowTime = Utility.GetCurrentGameTime()
    String dayKey = "PDV.BookRead." + bookForm.GetFormID() + ".SeenDay"
    Float seenDay = StorageUtil.GetFloatValue(None, dayKey)

    if seenDay <= 0.0
        ; Migration: a pre-P15 save carries the old `.Seen` int with no timestamp. Treat that as
        ; "read just now", NOT as never-read -- otherwise an existing library would all become
        ; re-creditable at once on the first load after the update.
        String legacyKey = "PDV.BookRead." + bookForm.GetFormID() + ".Seen"
        if StorageUtil.GetIntValue(None, legacyKey) == 1
            StorageUtil.SetFloatValue(None, dayKey, nowTime)
            return false
        endIf
        StorageUtil.SetFloatValue(None, dayKey, nowTime)
        return true
    endIf

    if (nowTime - seenDay) < BOOK_REREAD_COOLDOWN_DAYS
        return false
    endIf

    StorageUtil.SetFloatValue(None, dayKey, nowTime)
    return true
EndFunction

String Function GetBretonHiddenArtSourceToken(Form sourceForm)
    if !sourceForm
        return "unknown"
    endIf

    Int sourceFormId = sourceForm.GetFormID()
    if sourceFormId == 0x000ED60B
        return "hagravens"
    elseIf sourceFormId == 0x0007EB03
        return "madmen_reach"
    elseIf sourceFormId == 0x000DDFB6
        return "witch_note"
    endIf

    return "unknown"
EndFunction

Bool Function HasListedForm(FormList sourceList, Form sourceForm)
    if !sourceList
        return false
    endIf

    if !sourceForm
        return false
    endIf

    return sourceList.HasForm(sourceForm)
EndFunction

Function QueueOriginInitialization()
    if GetOriginRaceValue() >= 0 && !ShouldQueueOriginRecheck()
        return
    endIf

    if PDV_OriginQueuedThisLoad
        return
    endIf

    PDV_OriginQueuedThisLoad = true
    ScheduleOriginDeadline(2.0)
    Trace(2, "Origin initialization queued after player load.")
EndFunction

Bool Function ShouldQueueOriginRecheck()
    if StorageUtil.GetIntValue(None, "PDV.Origin.ForceRedetect", 0) == 1
        return true
    endIf

    if StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback", 0) == 1
        return true
    endIf

    return false
EndFunction

Function EnsureOriginInitialized()
    if !PDV_OriginQuest
        Trace(1, "Origin init skipped: PDV_OriginQuest not assigned.")
        return
    endIf

    if !IsOriginCaptureSafe()
        Trace(2, "Origin init skipped: controls are not settled.")
        return
    endIf

    PDV_OriginQuest.InitializeOrigin()
EndFunction

Function RouteCurseRefresh(String reason)
    if !PDV_EventBusService
        Trace(1, "Curse refresh skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteCurseStateRefresh(reason)
EndFunction

Bool Function IsOriginCaptureSafe()
    if !Game.IsMovementControlsEnabled()
        return false
    endIf

    if !Game.IsMenuControlsEnabled()
        return false
    endIf

    return true
EndFunction

Int Function GetOriginRaceValue()
    if !PDV_OriginQuest
        return -1
    endIf

    GlobalVariable originGlobal = PDV_OriginQuest.PDV_GLO_OriginRace
    if originGlobal
        return originGlobal.GetValueInt()
    endIf

    return -1
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf

    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] PlayerEvents: " + traceText)
    endIf
EndFunction

Function StartBardPerformancePoll()
    if !PDV_BardFormsResolved
        ResolveBardPerformanceForms()
    endIf
    if !PDV_BardPollActive
        PDV_BARD_NEXT_DUE = -1.0
        ArmEarliestDeadline()
        return
    endIf

    ; B9 / fix-plan 12.3. PDV_BardLastRouteRealTime is a 12-second anti-double-route gate
    ; measured in Utility.GetCurrentRealTime(), which counts seconds since the APPLICATION
    ; started and therefore resets to 0 on every relaunch -- but the stamp itself persists
    ; in the save. So a player who performed two hours into a session and then restarted
    ; Skyrim came back with a stamp of ~7200 against a session clock of ~0, and every
    ; performance was silently discarded until the new session had been running longer
    ; than the old one. Clearing the stamp on each load makes the gate mean what it says.
    PDV_BardLastRouteRealTime = -100.0

    PDV_BardLastLute = GetBardGlobalValue(PDV_BardSgtLute)
    PDV_BardLastFlute = GetBardGlobalValue(PDV_BardSgtFlute)
    PDV_BardLastDrum = GetBardGlobalValue(PDV_BardSgtDrum)
    PDV_BardLastPlaying = GetBardGlobalValue(PDV_BardIsPlaying) as Int
    PDV_BardQuietTicks = 0
    SyncBardTavernCounts()
    ScheduleBardDeadline(BARD_POLL_ACTIVE_INTERVAL)
EndFunction

Function ResolveBardPerformanceForms()
    ; Re-resolve and cache once per load. Guard optional plugins before any
    ; GetFormFromFile call so an absent integration produces no Papyrus error.
    PDV_BardIsPlaying = None
    PDV_BardTavernCounts = None
    PDV_BardSgtLute = None
    PDV_BardSgtFlute = None
    PDV_BardSgtDrum = None
    PDV_BardSgtOvation = None

    if Game.IsPluginInstalled("BecomeABard.esp")
        PDV_BardIsPlaying = Game.GetFormFromFile(0x00051223, "BecomeABard.esp") as GlobalVariable
        PDV_BardTavernCounts = Game.GetFormFromFile(0x00065073, "BecomeABard.esp") as FormList
    endIf

    PDV_BardGameDaysPassed = Game.GetFormFromFile(0x00000038, "Skyrim.esm") as GlobalVariable
    if Game.IsPluginInstalled("SkyrimsGotTalent-Bards.esp")
        PDV_BardSgtLute = Game.GetFormFromFile(0x00000D62, "SkyrimsGotTalent-Bards.esp") as GlobalVariable
        PDV_BardSgtFlute = Game.GetFormFromFile(0x00000D61, "SkyrimsGotTalent-Bards.esp") as GlobalVariable
        PDV_BardSgtDrum = Game.GetFormFromFile(0x00000D63, "SkyrimsGotTalent-Bards.esp") as GlobalVariable
        PDV_BardSgtOvation = Game.GetFormFromFile(0x0000E0CA, "SkyrimsGotTalent-Bards.esp") as GlobalVariable
    endIf

    PDV_BardFormsResolved = true
    PDV_BardPollActive = PDV_BardIsPlaying || PDV_BardSgtLute || PDV_BardSgtFlute || PDV_BardSgtDrum
EndFunction

; 12.3 / audit C3 -- the eternal 5-second bard poll.
;
; It used to run at 5s for the whole playthrough the moment ANY BecomeABard or Skyrim's
; Got Talent form resolved, whether or not the player ever picked up an instrument.
;
; What it is NOT: a hard "start on instrument equip, stop on performance end" gate, which
; is what the fix plan sketched. Both mods drive performances through their own dialogue
; and quest machinery, and the only signals this script can see are four GlobalVariables.
; A hard gate would have to guess which forms count as "an instrument" across two mods; if
; that guess is wrong the failure is SILENT -- bard piety simply stops being awarded, with
; nothing in the log. That is the exact class of defect this whole project exists to
; remove, so trading a real ~1-native-call-per-second cost for it is a bad bargain.
;
; What it IS: a two-state cadence. While a performance is live -- IsPlaying set, expertise
; rising, or the performance just ended -- the poll runs at BARD_POLL_ACTIVE_INTERVAL
; exactly as before. After BARD_POLL_QUIET_TICKS_TO_IDLE ticks with nothing happening it
; drops to BARD_POLL_IDLE_INTERVAL, cutting the idle cost to a third.
;
; Why nothing can be missed at the idle cadence: the expertise and tavern-count reads are
; DELTAS against stored values, so a coarse sample loses no magnitude. The one edge-driven
; signal is performanceEnded (IsPlaying 1 -> 0), and catching it only requires that one
; idle tick land while IsPlaying is set. Idle period is 15 s against a sung performance
; that runs a minute or more, so the margin is several-fold, and the first tick that sees
; the performance immediately restores the 5 s cadence for the end detection itself.
Function BardPerformancePollTick()
    Float currentLute = GetBardGlobalValue(PDV_BardSgtLute)
    Float currentFlute = GetBardGlobalValue(PDV_BardSgtFlute)
    Float currentDrum = GetBardGlobalValue(PDV_BardSgtDrum)
    Int currentPlaying = GetBardGlobalValue(PDV_BardIsPlaying) as Int

    Float expertiseDelta = (currentLute - PDV_BardLastLute) + (currentFlute - PDV_BardLastFlute) + (currentDrum - PDV_BardLastDrum)
    Bool performanceEnded = PDV_BardLastPlaying > 0 && currentPlaying <= 0

    PDV_BardLastLute = currentLute
    PDV_BardLastFlute = currentFlute
    PDV_BardLastDrum = currentDrum
    PDV_BardLastPlaying = currentPlaying

    Form tavernContext = None
    Bool tavernCountChanged = false
    Bool tavernEligible = true
    if performanceEnded && PDV_BardTavernCounts
        tavernContext = ConsumeBardTavernCountIncrease()
        tavernCountChanged = tavernContext != None
        if tavernCountChanged
            tavernEligible = MarkBardTavernDay(tavernContext)
        endIf
    endIf

    if (expertiseDelta > 0.0 || performanceEnded) && tavernEligible
        Int qualityDelta = expertiseDelta as Int
        if qualityDelta < 1
            qualityDelta = 1
        elseIf qualityDelta > 8
            qualityDelta = 8
        endIf

        Float nowRealTime = Utility.GetCurrentRealTime()
        if nowRealTime - PDV_BardLastRouteRealTime >= 12.0
            Bool receivedOvation = GetBardGlobalValue(PDV_BardSgtOvation) > 0.0
            Form contextForm = tavernContext
            if !contextForm
                contextForm = GetBardExpertiseContext(currentLute, currentFlute, currentDrum)
            endIf
            if !contextForm
                contextForm = PDV_BardIsPlaying as Form
            endIf
            if PDV_EventBusService
                PDV_EventBusService.RouteBardPerformance(qualityDelta, receivedOvation, contextForm)
                PDV_BardLastRouteRealTime = nowRealTime
            endIf
        endIf
    elseIf tavernCountChanged && !tavernEligible
        Trace(3, "Bard performance blocked by per-tavern daily cap.")
    endIf

    ; 12.3. Anything at all happening this tick holds the fast cadence and resets the
    ; quiet run; a stretch of genuinely empty ticks drops to the idle cadence.
    if currentPlaying > 0 || expertiseDelta > 0.0 || performanceEnded || tavernCountChanged
        PDV_BardQuietTicks = 0
    else
        PDV_BardQuietTicks += 1
    endIf

    if PDV_BardQuietTicks >= BARD_POLL_QUIET_TICKS_TO_IDLE
        ScheduleBardDeadline(BARD_POLL_IDLE_INTERVAL)
    else
        ScheduleBardDeadline(BARD_POLL_ACTIVE_INTERVAL)
    endIf
EndFunction

Float Function GetBardGlobalValue(GlobalVariable sourceGlobal)
    if sourceGlobal
        return sourceGlobal.GetValue()
    endIf
    return 0.0
EndFunction

Form Function GetBardExpertiseContext(Float currentLute, Float currentFlute, Float currentDrum)
    if currentLute >= currentFlute && currentLute >= currentDrum && PDV_BardSgtLute
        return PDV_BardSgtLute as Form
    elseIf currentFlute >= currentDrum && PDV_BardSgtFlute
        return PDV_BardSgtFlute as Form
    elseIf PDV_BardSgtDrum
        return PDV_BardSgtDrum as Form
    endIf
    return None
EndFunction

Function SyncBardTavernCounts()
    if !PDV_BardTavernCounts
        return
    endIf

    Int index = 0
    Int count = PDV_BardTavernCounts.GetSize()
    while index < count
        GlobalVariable countGlobal = PDV_BardTavernCounts.GetAt(index) as GlobalVariable
        if countGlobal
            StorageUtil.SetFloatValue(None, "PDV.BardTavern.LastCount." + countGlobal.GetFormID(), countGlobal.GetValue())
        endIf
        index += 1
    endWhile
EndFunction

Form Function ConsumeBardTavernCountIncrease()
    Int index = 0
    Int count = PDV_BardTavernCounts.GetSize()
    Form changedTavern = None
    while index < count
        GlobalVariable countGlobal = PDV_BardTavernCounts.GetAt(index) as GlobalVariable
        if countGlobal
            String countKey = "PDV.BardTavern.LastCount." + countGlobal.GetFormID()
            Float previousCount = StorageUtil.GetFloatValue(None, countKey, countGlobal.GetValue())
            Float currentCount = countGlobal.GetValue()
            if currentCount > previousCount && !changedTavern
                changedTavern = countGlobal as Form
            endIf
            StorageUtil.SetFloatValue(None, countKey, currentCount)
        endIf
        index += 1
    endWhile
    return changedTavern
EndFunction

Bool Function MarkBardTavernDay(Form tavernContext)
    if !tavernContext
        return true
    endIf

    ; fix-plan 4.2: GameDaysPassed rolls at raw midnight, but the manager's own comment
    ; on this gate calls it "one award per tavern per devotional day". Use the devotional
    ; day so it matches the daily repeat multiplier it is paired with.
    Int dayStamp = GetDevotionalDayStamp()
    String dayKey = "PDV.BardTavern.Day." + tavernContext.GetFormID()
    if StorageUtil.GetIntValue(None, dayKey, -1) == dayStamp
        return false
    endIf
    StorageUtil.SetIntValue(None, dayKey, dayStamp)
    return true
EndFunction

; fix-plan 4.2. The 06:00 devotional day in the manager's zero-reserved +2 encoding,
; kept local because this alias script holds no manager handle at every call site.
; The dawn offset matches PDV__ManagerQuest.GetDevotionalDay and PDV_DeityBase.
Int Function GetDevotionalDayStamp()
    Float shiftedTime = Utility.GetCurrentGameTime() - 0.25
    Int truncatedDay = shiftedTime as Int
    if shiftedTime < 0.0 && shiftedTime != (truncatedDay as Float)
        truncatedDay -= 1
    endIf
    return truncatedDay + 2
EndFunction
