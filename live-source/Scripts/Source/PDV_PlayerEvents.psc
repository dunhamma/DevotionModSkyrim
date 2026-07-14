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
String Property QUEST_REACTION_MATRIX_FILE_ARR = "../StorageUtilData/PlayerDevotion/PDV_QuestReactionMatrix_ARR" AutoReadOnly

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

Bool PDV_QuestReactionSpellFaucetCacheReady = false
Form PDV_QRSpellSanguine0 = None
Form PDV_QRSpellSanguine1 = None
Form PDV_QRSpellVaermina0 = None
Form PDV_QRSpellVaermina1 = None
Form PDV_QRSpellSheogorathFire0 = None
Form PDV_QRSpellSheogorathFire1 = None

Bool PDV_LastSleepStartedOutside = false
Bool PDV_LastSleptInInn = false
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
Bool PDV_CombatBelowHealthRouted = false
Bool PDV_OriginQueuedThisLoad = false

; Khajiit caravan-defense detector forms (Khenarthi CARAVAN_AID). Resolved once
; per load via GetFormFromFile; script variables so no VMAD property fill is
; needed. The three caravan leaders' persistent refs are the proximity anchors.
Bool PDV_CaravanFormsResolved = false
Faction PDV_KhajiitCaravanFactionRef = None
ObjectReference PDV_CaravanLeaderRisaad = None
ObjectReference PDV_CaravanLeaderAhkari = None
ObjectReference PDV_CaravanLeaderMadran = None

Event OnInit()
    PDV_OriginQueuedThisLoad = false
    RegisterForPlayerEvents()
    QueueOriginInitialization()
    RouteCurseRefresh("alias_init")
    Trace(2, "Player alias initialized.")
EndEvent

Event OnPlayerLoadGame()
    PDV_OriginQueuedThisLoad = false
    RegisterForPlayerEvents()
    QueueOriginInitialization()
    RouteCurseRefresh("load")
    RoutePaarthurnaxSpareLoadCheck()
    Trace(2, "Player load observed; sleep hooks refreshed.")
EndEvent

Event OnUpdate()
    ; The single-update timer is shared: the combat poll re-registers at 4s while a
    ; session is open, and the origin retry below re-registers at 2s while origin is
    ; unresolved. Origin runs last so its shorter delay wins when both are active.
    if PDV_CombatSessionActive
        CombatPollTick()
    endIf

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
        RegisterForSingleUpdate(2.0)
        Trace(2, "Origin capture waiting for playable controls.")
        return
    endIf

    EnsureOriginInitialized()

    if GetOriginRaceValue() < 0
        RegisterForSingleUpdate(2.0)
        Trace(2, "Origin still unresolved; retry queued.")
    elseIf originQueued
        Trace(2, "Origin re-check completed.")
    else
        Trace(2, "Origin initialization completed.")
    endIf
EndEvent

Event OnSleepStart(Float afSleepStartTime, Float afDesiredSleepEndTime)
    Actor playerActor = GetActorRef()
    if playerActor
        PDV_LastSleepStartedOutside = !playerActor.IsInInterior()
        PDV_LastSleptInInn = IsPlayerInInn(playerActor)
    else
        PDV_LastSleepStartedOutside = false
        PDV_LastSleptInInn = false
    endIf

    Trace(3, "Player sleep start observed.")
EndEvent

Event OnSleepStop(Bool abInterrupted)
    if GetOriginRaceValue() < 0
        EnsureOriginInitialized()
    endIf

    if !PDV_EventBusService
        Trace(1, "Player sleep stop skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteSleepStop(GetActorRef(), abInterrupted)

    if !abInterrupted
        if PDV_LastSleepStartedOutside
            RouteGenericAction(EVT_REST_UNDER_OPEN_SKY, GetActorRef() as Form, None)
        else
            RouteGenericAction(EVT_SLEEP_IN_BED, GetActorRef() as Form, None)
            ; The ascetic-creed sleep penalty bites only on paid inn comfort ("slumbering
            ; easy"), not your own bed or a bedroll. Inn sleep also fires EVT_SLEEP_IN_INN so
            ; only the inn-keyed dislike rows score; positive sleep credit stays on EVT_SLEEP_IN_BED.
            if PDV_LastSleptInInn
                RouteGenericAction(EVT_SLEEP_IN_INN, GetActorRef() as Form, None)
            endIf
        endIf
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
    PDV_EventBusService.BeginLogicalDevotionalAct("book_" + akBook.GetFormID())
    RouteGenericBookRead(akBook, firstRead)
    RouteP2ImmersiveSource(akBook as Form, "po3_book")
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
    if PDV_EventBusService
        PDV_EventBusService.BeginLogicalDevotionalAct("harvest_" + akProduce.GetFormID())
    endIf
    RouteGenericAction(EVT_HARVEST_INGREDIENT, GetActorRef() as Form, akProduce)
    RouteP2ImmersiveSource(akProduce, "po3_harvest")
    if PDV_EventBusService
        PDV_EventBusService.FlushLogicalDevotionalAct()
    endIf
EndEvent

Event OnWeatherChange(Weather akOldWeather, Weather akNewWeather)
    RouteP2ImmersiveSource(akNewWeather as Form, "po3_weather")
EndEvent

Event OnQuestStageChange(Quest akQuest, Int aiNewStage)
    if PDV_EventBusService && akQuest
        PDV_EventBusService.BeginLogicalDevotionalAct("quest_" + akQuest.GetFormID() + "_" + aiNewStage)
    endIf
    RouteP2ImmersiveQuestStage(akQuest, aiNewStage)
    RouteQuestReactionStage(akQuest, aiNewStage)
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

    if !abHitBlocked
        return
    endIf

    RouteQuestReactionBlockedHitFaucet()
EndEvent

Function RouteGenericBookRead(Book akBook, Bool firstRead)
    if !akBook
        return
    endIf

    if !firstRead
        Trace(2, "Generic book read repeat skipped: " + akBook.GetFormID())
        return
    endIf

    if HasListedForm(PDV_FLST_FaucetSkillBooks, akBook as Form)
        RouteGenericAction(EVT_READ_SKILL_BOOK, GetActorRef() as Form, akBook as Form)
    elseIf HasListedForm(PDV_FLST_FaucetSpellTomes, akBook as Form)
        RouteGenericAction(EVT_READ_SPELL_TOME, GetActorRef() as Form, akBook as Form)
    else
        RouteGenericAction(EVT_READ_LORE_BOOK, GetActorRef() as Form, akBook as Form)
    endIf
EndFunction

Function RouteGenericAction(Int eventType, Form actorForm, Form targetForm)
    if !PDV_EventBusService
        Trace(1, "Generic faucet event skipped: PDV_EventBusService not assigned.")
        return
    endIf

    PDV_EventBusService.RouteAction(eventType, actorForm, targetForm)
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
    PDV_CombatBelowHealthRouted = false
    RegisterForSingleUpdate(4.0)
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
        RegisterForSingleUpdate(4.0)
    else
        ResolveCombatSession("poll_combat_exit")
    endIf
EndFunction

Function SampleCombatHealth(Actor playerRef, String reason)
    Int originRace = GetOriginRaceValue()
    Float healthPct = playerRef.GetActorValuePercentage("Health")
    if originRace == 4
        TryRoutePlayerBelowHealthGate(playerRef, healthPct, reason)
    elseIf originRace == 0 || originRace == 6
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
        Int dayStamp = (Utility.GetCurrentGameTime() as Int) + 1
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
    return originRace == 0 || originRace == 4 || originRace == 5 || originRace == 6 || originRace == 7 || originRace == 8 || originRace == 9
EndFunction

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    Actor sourceActor = akSourceContainer as Actor
    if !sourceActor
        return
    endIf

    if GetOriginRaceValue() != 6
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

    if !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        return
    endIf

    PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(Self)
    RegisterQuestReactionEffectList("faucetEffectForms.Namira.cannibalism")
    RegisterQuestReactionEffectList("faucetEffectForms.Dibella.charity")
    PO3_Events_Alias.UnregisterForAllHitEventsEx(Self)
    PO3_Events_Alias.RegisterForHitEventEx(Self, akAggressorFilter = None, akSourceFilter = None, akProjectileFilter = None, aiPowerFilter = -1, aiSneakFilter = -1, aiBashFilter = -1, aiBlockFilter = 1, abMatch = True)
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

Function RegisterQuestReactionMatrix()
    RegisterQuestReactionMatrixFile(QUEST_REACTION_MATRIX_FILE, "core")
    if JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE_ARR)
        RegisterQuestReactionMatrixFile(QUEST_REACTION_MATRIX_FILE_ARR, "ARR")
    endIf
EndFunction

Function RegisterQuestReactionMatrixFile(String matrixFile, String label)
    if !JsonUtil.JsonExists(matrixFile)
        Trace(1, "Quest reaction matrix JSON missing: " + matrixFile)
        return
    endIf

    ReloadQuestReactionMatrixJsonFile(matrixFile)

    Int sourceIndex = 0
    String[] formIds = JsonUtil.StringListToArray(matrixFile, "questWatchFormIds")
    String[] plugins = JsonUtil.StringListToArray(matrixFile, "questWatchPlugins")
    if formIds.Length <= 0
        formIds = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchFormIdsCsv"), ",")
        plugins = StringUtil.Split(JsonUtil.GetStringValue(matrixFile, "questWatchPluginsCsv"), ",")
    endIf
    Int sourceCount = formIds.Length
    while sourceIndex < sourceCount
        Quest sourceQuest = GetQuestReactionRuntimeFormFromCsv(formIds, plugins, sourceIndex) as Quest
        if sourceQuest
            PO3_Events_Alias.RegisterForQuestStage(Self, sourceQuest)
            StorageUtil.SetIntValue(None, "PDV.QuestReaction.LocalFormId." + sourceQuest.GetFormID(), formIds[sourceIndex] as Int)
        endIf
        sourceIndex += 1
    endWhile

    Trace(2, "Quest reaction matrix hooks refreshed (" + label + "): " + sourceCount + " quest entries.")
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

Function RouteP2ImmersiveSource(Form sourceForm, String sourceKind)
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

    PDV_EventBusService.BeginLogicalDevotionalAct(sourceKind + "_" + sourceForm.GetFormID())

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

Function RouteP2ImmersiveQuestStage(Quest sourceQuest, Int newStage)
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

    PDV_EventBusService.BeginLogicalDevotionalAct("p2_quest_" + sourceQuest.GetFormID() + "_" + newStage)

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
        PDV_EventBusService.RouteDaedricPrinceSignal(13, "po3_queststage_daedric_nocturnal_tg09")
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

Function RouteQuestReactionStage(Quest sourceQuest, Int newStage)
    if !sourceQuest || !PDV_EventBusService
        return
    endIf

    PDV_EventBusService.RouteQuestReaction(sourceQuest, newStage)
EndFunction

Function RouteQuestReactionBookFaucet(Form sourceForm, Bool firstRead)
    if !sourceForm || !PDV_EventBusService
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
    if ShouldRouteQuestReactionFaucet("Molag Bal.serve_a_daedra:molag_bal", "faucetForms.Molag Bal.serve_a_daedra:molag_bal", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Molag Bal.serve_a_daedra:molag_bal", sourceForm)
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
    if ShouldRouteQuestReactionFaucet("Mehrunes Dagon.serve_a_daedra:mehrunes_dagon", "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunes_dagon", sourceForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Mehrunes Dagon.serve_a_daedra:mehrunes_dagon", sourceForm)
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

    Actor playerRef = Game.GetPlayer()
    if !playerRef
        return
    endIf

    Form shieldForm = playerRef.GetEquippedShield() as Form
    if ShouldRouteQuestReactionFaucet("Peryite.serve_a_daedra:peryite", "faucetForms.Peryite.serve_a_daedra:peryite", shieldForm)
        PDV_EventBusService.RouteQuestReactionFaucet("Peryite.serve_a_daedra:peryite", shieldForm)
    endIf
EndFunction

Bool Function ShouldRouteQuestReactionFaucet(String faucetKey, String listKey, Form sourceForm)
    if !sourceForm
        return false
    endIf

    if !JsonUtil.JsonExists(QUEST_REACTION_MATRIX_FILE)
        return false
    endIf

    if !HasQuestReactionRuntimeForm(listKey, sourceForm)
        return false
    endIf

    return true
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

    Int localFormId = formIds[entryIndex] as Int
    String pluginName = plugins[entryIndex]
    if localFormId <= 0 || pluginName == ""
        return None
    endIf

    if Game.GetModByName(pluginName) == 255
        return None
    endIf

    return Game.GetFormFromFile(localFormId, pluginName)
EndFunction

Bool Function HasQuestReactionRuntimeForm(String listKey, Form sourceForm)
    if !sourceForm
        return false
    endIf

    Int sourceIndex = 0
    String[] formIds = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionFormIdCsvKey(listKey)), ",")
    String[] plugins = StringUtil.Split(JsonUtil.GetStringValue(QUEST_REACTION_MATRIX_FILE, GetQuestReactionPluginCsvKey(listKey)), ",")
    Int sourceCount = formIds.Length
    while sourceIndex < sourceCount
        Form resolvedForm = GetQuestReactionRuntimeFormFromCsv(formIds, plugins, sourceIndex)
        if resolvedForm && resolvedForm == sourceForm
            return true
        endIf
        sourceIndex += 1
    endWhile

    return false
EndFunction

Function ReloadQuestReactionMatrixJson()
    ReloadQuestReactionMatrixJsonFile(QUEST_REACTION_MATRIX_FILE)
    CacheQuestReactionSpellFaucetForms()
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
    elseIf listKey == "faucetForms.Molag Bal.serve_a_daedra:molag_bal"
        return "faucetFormsMolagBalServeADaedraMolagBalFormIds"
    elseIf listKey == "faucetForms.Hircine.serve_a_daedra:hircine"
        return "faucetFormsHircineServeADaedraHircineFormIds"
    elseIf listKey == "faucetForms.Meridia.serve_a_daedra:meridia"
        return "faucetFormsMeridiaServeADaedraMeridiaFormIds"
    elseIf listKey == "faucetForms.Sheogorath.serve_a_daedra:sheogorath"
        return "faucetFormsSheogorathServeADaedraSheogorathFormIds"
    elseIf listKey == "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunes_dagon"
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
    elseIf listKey == "faucetForms.Molag Bal.serve_a_daedra:molag_bal"
        return "faucetFormsMolagBalServeADaedraMolagBalPlugins"
    elseIf listKey == "faucetForms.Hircine.serve_a_daedra:hircine"
        return "faucetFormsHircineServeADaedraHircinePlugins"
    elseIf listKey == "faucetForms.Meridia.serve_a_daedra:meridia"
        return "faucetFormsMeridiaServeADaedraMeridiaPlugins"
    elseIf listKey == "faucetForms.Sheogorath.serve_a_daedra:sheogorath"
        return "faucetFormsSheogorathServeADaedraSheogorathPlugins"
    elseIf listKey == "faucetForms.Mehrunes Dagon.serve_a_daedra:mehrunes_dagon"
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
        ; Store day+1: StorageUtil int keys default to 0, and game day 0 as Int is
        ; also 0, so a raw day key would silently suppress every harvest/weather
        ; route on the first in-game day (storageutil-day-key-zero-default class).
        Int currentDayMark = (Utility.GetCurrentGameTime() as Int) + 1
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

Bool Function MarkGenericBookRead(Form bookForm)
    if !bookForm
        return false
    endIf

    String seenKey = "PDV.BookRead." + bookForm.GetFormID() + ".Seen"
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return false
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
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
    RegisterForSingleUpdate(2.0)
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
