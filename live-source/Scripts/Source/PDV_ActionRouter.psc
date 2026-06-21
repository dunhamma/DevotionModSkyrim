;/
    PDV_ActionRouter.psc
    PlayerDevotion - Phase 3 action fan-out service
    -----------------------------------------------------------------------
    OVERVIEW
    Persistent service quest that receives validated action payloads from
    Story Manager receiver quests and fans them out to all deity quests.

    DESIGN NOTES
    - This script owns no canonical piety state.
    - Runtime events write only through PDV__ManagerQuest.AwardPiety().
    - AwardPiety writes PDV.PietyToday only; dawn consolidation remains
      owned by PDV__ManagerQuest.ProcessDawn().
    - Phase 3 is intentionally conservative: direct player Kill Actor
      events only. Followers, summons, traps, poison attribution, and
      neutral-kill theology are deferred.
    -----------------------------------------------------------------------
/;

Scriptname PDV_ActionRouter extends Quest

; -----------------------------------------------------------------------
; CORE PROPERTIES
; -----------------------------------------------------------------------
PDV__ManagerQuest Property PDV_Manager Auto
PDV_EventBus Property PDV_EventBusService Auto
PDV_EventTypes Property PDV_EventTypesService Auto
FormList Property PDV_FLST_AllDeities Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
Actor Property PlayerRef Auto

; Lazily-resolved vanilla ThalmorFaction (Skyrim.esm:00039F26) for unprovoked-kill scoring.
Faction _pdvThalmorFactionCache

; -----------------------------------------------------------------------
; CLASSIFICATION KEYWORDS
; Wire these to vanilla ActorType* keywords in CK.
; ActorTypeCreature is diagnostic/fallback only in the first slice.
; -----------------------------------------------------------------------
Keyword Property ActorTypeNPC Auto
Keyword Property ActorTypeAnimal Auto
Keyword Property ActorTypeCreature Auto
; Victim-type classification (Auto-Fill in CK; names match vanilla keyword EditorIDs).
Keyword Property ActorTypeUndead Auto
Keyword Property ActorTypeDaedra Auto
Keyword Property ActorTypeDragon Auto

; Generic faucet classification. Skill/spell/lore books stay FormList-owned
; because this local Papyrus source has no compile-visible Book.GetSpell().
FormList Property PDV_FLST_FaucetSkillBooks Auto
FormList Property PDV_FLST_FaucetSpellTomes Auto
Keyword Property CraftingSmithingArmorTable Auto
Keyword Property CraftingSmithingForge Auto
Keyword Property CraftingSmithingSharpeningWheel Auto
Keyword Property CraftingSmithingSkyforge Auto
Keyword Property CraftingCookpot Auto
Keyword Property isAlchemy Auto
Keyword Property isEnchanting Auto

; -----------------------------------------------------------------------
; EVENT CONSTANTS
; Keep these in sync with concrete deity ScoreAction() implementations.
; -----------------------------------------------------------------------
Int Property EVT_NONE = 0 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_BEAST = 1 AutoReadOnly
Int Property EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT = 2 AutoReadOnly
Int Property EVT_KILL_UNDEAD = 300 AutoReadOnly
Int Property EVT_KILL_DAEDRA = 301 AutoReadOnly
Int Property EVT_KILL_DRAGON = 302 AutoReadOnly
Int Property EVT_KILL_ANIMAL_NONCOMBAT = 303 AutoReadOnly
Int Property EVT_MURDER_DEFENSELESS = 304 AutoReadOnly
Int Property EVT_SMITH_ITEM = 330 AutoReadOnly
Int Property EVT_ENCHANT_ITEM = 331 AutoReadOnly
Int Property EVT_BREW_POTION = 332 AutoReadOnly
Int Property EVT_COOK_MEAL = 333 AutoReadOnly
Int Property EVT_HARVEST_INGREDIENT = 334 AutoReadOnly
Int Property EVT_READ_SKILL_BOOK = 340 AutoReadOnly
Int Property EVT_READ_SPELL_TOME = 341 AutoReadOnly
Int Property EVT_READ_LORE_BOOK = 342 AutoReadOnly
Int Property EVT_LEARN_WORD_OF_POWER = 343 AutoReadOnly
Int Property EVT_INCREASE_SKILL = 344 AutoReadOnly
Int Property EVT_DISCOVER_LOCATION = 345 AutoReadOnly
Int Property EVT_PICK_OWNED_LOCK = 360 AutoReadOnly
Int Property EVT_TRESPASS = 361 AutoReadOnly
Int Property EVT_ASSAULT_INNOCENT = 364 AutoReadOnly

Int Property ATTR_DIRECT_PLAYER = 1 AutoReadOnly
Int Property ATTR_FOLLOWER = 2 AutoReadOnly
Int Property ATTR_ENVIRONMENT = 5 AutoReadOnly


; =======================================================================
; STORY MANAGER ENTRYPOINTS
; =======================================================================

Function HandleStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, Int aiCrimeStatus, Int aiRelationshipRank)
    Actor playerActor = GetPlayerActor()
    if !playerActor
        Trace(1, "HandleStoryKillActor skipped: PlayerRef unavailable.")
        return
    endIf

    Actor killerActor = akKiller as Actor
    Actor victimActor = akVictim as Actor

    if !victimActor
        Trace(2, "HandleStoryKillActor skipped: victim was not an Actor.")
        return
    endIf

    if !killerActor
        RouteNonScoringKillPayload(victimActor, playerActor, ATTR_ENVIRONMENT, aiRelationshipRank)
        return
    endIf

    if killerActor != playerActor
        RouteNonScoringKillPayload(victimActor, playerActor, ATTR_FOLLOWER, aiRelationshipRank)
        return
    endIf

    ; Unprovoked Thalmor kill -> heterodox/defiant act (Altmer ThalmorAlignment / Imperial
    ; Concordat). "Unprovoked" = the victim was NOT a pre-set enemy (relationship rank > -2):
    ; the player chose to kill them. Routed here, BEFORE the hostile/non-hostile split, because
    ; open-attacking a neutral Thalmor makes them hostile, which would otherwise divert the kill
    ; to the wrong branch -- so an open kill now counts the same as an assassination. Killing a
    ; Thalmor that was already your foe/enemy (rank <= -2: a scripted quest enemy) reads as
    ; self-defense and is excluded.
    if aiRelationshipRank > -2
        RouteThalmorUnprovokedKill(victimActor)
    endIf

    if !IsHostileKill(victimActor, playerActor, aiRelationshipRank)
        Int nonHostileEvent = ClassifyNonHostileKillVictim(victimActor, aiCrimeStatus)
        if nonHostileEvent == EVT_NONE
            Trace(2, "HandleStoryKillActor skipped: no hostility/noncombat evidence.")
            return
        endIf

        RouteActionWithAttribution(nonHostileEvent, ATTR_DIRECT_PLAYER, killerActor as Form, victimActor as Form)
        if PDV_Manager
            PDV_Manager.HandleArgonianShadowscaleKill(playerActor)
        endIf
        return
    endIf

    Int eventType = ClassifyKillVictim(victimActor)
    if eventType == EVT_NONE
        Trace(2, "HandleStoryKillActor skipped: victim classification unknown.")
        return
    endIf

    RouteActionWithAttribution(eventType, ATTR_DIRECT_PLAYER, killerActor as Form, victimActor as Form)
    if PDV_Manager
        PDV_Manager.HandleArgonianShadowscaleKill(playerActor)
        PDV_Manager.HandleHoonDingBreakthroughKill(victimActor as Form, eventType)
        ; A UNIQUE (named/boss) undead defeat is the marked Ash'abah death-burden that
        ; lets a Redguard switch INTO the Ash'abah sect mid-game (origin/undead/Unique
        ; gating lives in the manager). Routine undead are not Unique, so this no-ops on
        ; casual draugr fighting.
        PDV_Manager.HandleRedguardAshAbahMajorBurden(victimActor as Form, eventType)
        PDV_Manager.TrackRedguardAshAbahUndeadSiteVisit(akLocation)
        ; Final-kill fast path for clearable undead sites. If the clear flag settles later,
        ; HandleStoryChangeLocation also checks the old location when the player leaves.
        PDV_Manager.HandleRedguardAshAbahUndeadSiteClear(akLocation)
    endIf
EndFunction

Faction Function GetThalmorFaction()
    if !_pdvThalmorFactionCache
        _pdvThalmorFactionCache = Game.GetFormFromFile(0x00039F26, "Skyrim.esm") as Faction
    endIf
    return _pdvThalmorFactionCache
EndFunction

Function RouteThalmorUnprovokedKill(Actor victimActor)
    if !victimActor || !PDV_Manager
        return
    endIf

    Faction thalmorFaction = GetThalmorFaction()
    if !thalmorFaction || !victimActor.IsInFaction(thalmorFaction)
        return
    endIf

    PDV_Manager.HandleThalmorUnprovokedKill(victimActor as Form)
EndFunction

Function HandleStoryCraftItem(ObjectReference akBench, Location akLocation, Form akCreatedItem)
    if !akBench
        Trace(2, "HandleStoryCraftItem skipped: bench missing.")
        return
    endIf

    Int eventType = ClassifyCraftBench(akBench)
    if eventType == EVT_NONE
        Trace(2, "HandleStoryCraftItem skipped: bench classification unknown.")
        return
    endIf

    RouteActionWithAttribution(eventType, ATTR_DIRECT_PLAYER, GetPlayerActor() as Form, akCreatedItem)
EndFunction

Function HandleStoryNewVoicePower(ObjectReference akActor, Form akVoicePower)
    if !IsPlayerRef(akActor)
        Trace(3, "HandleStoryNewVoicePower skipped: actor was not player.")
        return
    endIf

    RouteActionWithAttribution(EVT_LEARN_WORD_OF_POWER, ATTR_DIRECT_PLAYER, akActor as Form, akVoicePower)
EndFunction

Function HandleStoryIncreaseSkill(String asSkill)
    if asSkill == ""
        Trace(2, "HandleStoryIncreaseSkill skipped: skill missing.")
        return
    endIf

    if PDV_Manager
        PDV_Manager.HandleAltmerMagicSkillIncrease(asSkill)
    endIf

    RouteActionWithAttribution(EVT_INCREASE_SKILL, ATTR_DIRECT_PLAYER, GetPlayerActor() as Form, None)
EndFunction

Function HandleStoryChangeLocation(ObjectReference akActor, Location akOldLocation, Location akNewLocation)
    if !IsPlayerRef(akActor)
        Trace(3, "HandleStoryChangeLocation skipped: actor was not player.")
        return
    endIf

    ; Runs on EVERY location change (before the one-shot discovery gate) so the
    ; Eldergleam interior-cell catch can arm/disarm as the player comes and goes.
    if PDV_Manager
        PDV_Manager.UpdateArgonianSanctuaryActive(akNewLocation)
        ; Bosmer Songs of the Green + Hearth discovery counter. Self-contained
        ; (own per-FormID seen keys + Eldergleam arm/disarm), so it rides every
        ; change here rather than the one-shot MarkLocationSeen gate below.
        PDV_Manager.HandleBosmerLocationChange(akNewLocation)
        PDV_Manager.HandleOrcLocationChange(akNewLocation)
        PDV_Manager.TrackRedguardAshAbahUndeadSiteVisit(akNewLocation)
        PDV_Manager.HandleRedguardAshAbahUndeadSiteClear(akOldLocation)
    endIf

    if !MarkLocationSeen(akNewLocation)
        Trace(3, "HandleStoryChangeLocation skipped: location already seen or missing.")
        return
    endIf

    RouteActionWithAttribution(EVT_DISCOVER_LOCATION, ATTR_DIRECT_PLAYER, akActor as Form, akNewLocation as Form)
    if PDV_Manager
        PDV_Manager.HandleArgonianSacredWaterDiscovery(akNewLocation)
    endIf
EndFunction

Function HandleStoryPickLock(ObjectReference akActor, ObjectReference akLock)
    if !IsPlayerRef(akActor)
        Trace(3, "HandleStoryPickLock skipped: actor was not player.")
        return
    endIf

    if !IsOwnedReference(akLock)
        Trace(3, "HandleStoryPickLock skipped: lock is not owned.")
        return
    endIf

    RouteActionWithAttribution(EVT_PICK_OWNED_LOCK, ATTR_DIRECT_PLAYER, akActor as Form, akLock as Form)
EndFunction

Function HandleStoryTrespass(ObjectReference akVictim, ObjectReference akTrespasser, Location akLocation, Int aiCrime)
    if !IsPlayerRef(akTrespasser)
        Trace(3, "HandleStoryTrespass skipped: trespasser was not player.")
        return
    endIf

    if aiCrime <= 0
        Trace(3, "HandleStoryTrespass skipped: no crime flag.")
        return
    endIf

    RouteActionWithAttribution(EVT_TRESPASS, ATTR_DIRECT_PLAYER, akTrespasser as Form, akVictim as Form)
EndFunction

Function HandleStoryAssaultActor(ObjectReference akVictim, ObjectReference akAttacker, Location akLocation, Int aiCrime)
    if !IsPlayerRef(akAttacker)
        Trace(3, "HandleStoryAssaultActor skipped: attacker was not player.")
        return
    endIf

    Actor victimActor = akVictim as Actor
    Actor playerActor = GetPlayerActor()
    if !victimActor || !playerActor
        Trace(2, "HandleStoryAssaultActor skipped: actor context missing.")
        return
    endIf

    if aiCrime <= 0 || victimActor.IsHostileToActor(playerActor)
        Trace(3, "HandleStoryAssaultActor skipped: no innocent assault evidence.")
        return
    endIf

    RouteActionWithAttribution(EVT_ASSAULT_INNOCENT, ATTR_DIRECT_PLAYER, akAttacker as Form, victimActor as Form)
EndFunction

Function RouteBookRead(Book akBook)
    RouteActionWithAttribution(ClassifyBook(akBook), ATTR_DIRECT_PLAYER, GetPlayerActor() as Form, akBook as Form)
EndFunction

Function RouteHarvestIngredient(Form akProduce)
    RouteActionWithAttribution(EVT_HARVEST_INGREDIENT, ATTR_DIRECT_PLAYER, GetPlayerActor() as Form, akProduce)
EndFunction

Function RouteNonScoringKillPayload(Actor victimActor, Actor playerActor, Int attributionType, Int aiRelationshipRank)
    if !IsHostileKill(victimActor, playerActor, aiRelationshipRank)
        Trace(3, "HandleStoryKillActor skipped non-player payload: no hostility evidence.")
        return
    endIf

    Int eventType = ClassifyKillVictim(victimActor)
    if eventType == EVT_NONE
        Trace(3, "HandleStoryKillActor skipped non-player payload: victim classification unknown.")
        return
    endIf

    RouteActionWithAttribution(eventType, attributionType, None, victimActor as Form)
EndFunction


; =======================================================================
; ROUTING
; =======================================================================

Function RouteAction(Int eventType, Form actorRef, Form targetRef)
    RouteActionWithAttribution(eventType, ATTR_DIRECT_PLAYER, actorRef, targetRef)
EndFunction

Function RouteActionWithAttribution(Int eventType, Int attributionType, Form actorRef, Form targetRef)
    PDV_EventBus eventBus = GetEventBus()
    if eventBus
        eventBus.RouteActionWithAttribution(eventType, attributionType, actorRef, targetRef)
        return
    endIf

    if attributionType != ATTR_DIRECT_PLAYER
        Trace(2, "RouteAction skipped non-scoring attribution " + attributionType + " for event " + eventType)
        return
    endIf

    if eventType == EVT_NONE
        return
    endIf

    if !PDV_Manager
        Trace(1, "RouteAction skipped: PDV_Manager not assigned.")
        return
    endIf

    if !PDV_FLST_AllDeities
        Trace(1, "RouteAction skipped: PDV_FLST_AllDeities not assigned.")
        return
    endIf

    Int i = 0
    Int count = PDV_FLST_AllDeities.GetSize()
    Int scoredCount = 0

    while i < count
        PDV_DeityBase deity = PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase
        if deity
            Float delta = deity.ScoreAction(eventType, actorRef, targetRef)
            if delta != 0.0
                PDV_Manager.AwardPiety(deity, delta)
                scoredCount += 1

                if GetDebugLevel() >= 2
                    Debug.Trace("[PDV] ActionRouter: " + deity.DeityName + " event " + eventType + " delta " + delta)
                endIf
            endIf
        else
            Trace(2, "RouteAction skipped invalid deity entry at index " + i)
        endIf

        i += 1
    endWhile

    ; V2: also deepen any OPEN transgressive-Prince paths (fallback path; EventBus does the same).
    PDV_Manager.RouteActionToOpenPaths(eventType, actorRef, targetRef)

    Trace(2, "RouteAction complete: event " + eventType + ", scored deities " + scoredCount)
EndFunction


; =======================================================================
; CLASSIFICATION HELPERS
; =======================================================================

Bool Function IsHostileKill(Actor victimActor, Actor playerActor, Int aiRelationshipRank)
    if aiRelationshipRank <= -2
        return true
    endIf

    if !victimActor || !playerActor
        return false
    endIf

    return victimActor.IsHostileToActor(playerActor)
EndFunction

Int Function ClassifyKillVictim(Actor victimActor)
    if !victimActor
        return EVT_NONE
    endIf

    ; Most-specific victim types first: an undead/daedra/dragon kill scores its own event
    ; (e.g. a draugr routes kill-undead, not humanoid), so deities react by what was slain.
    if ActorHasKeyword(victimActor, ActorTypeUndead)
        return EVT_KILL_UNDEAD
    endIf

    if ActorHasKeyword(victimActor, ActorTypeDaedra)
        return EVT_KILL_DAEDRA
    endIf

    if ActorHasKeyword(victimActor, ActorTypeDragon)
        return EVT_KILL_DRAGON
    endIf

    if ActorHasKeyword(victimActor, ActorTypeNPC)
        return EVT_KILLED_HOSTILE_HUMANOID_IN_COMBAT
    endIf

    if ActorHasKeyword(victimActor, ActorTypeAnimal)
        return EVT_KILLED_HOSTILE_BEAST
    endIf

    if ActorHasKeyword(victimActor, ActorTypeCreature)
        Trace(2, "ClassifyKillVictim found ActorTypeCreature without animal/NPC mapping.")
    endIf

    return EVT_NONE
EndFunction

Int Function ClassifyNonHostileKillVictim(Actor victimActor, Int aiCrimeStatus)
    if !victimActor
        return EVT_NONE
    endIf

    if ActorHasKeyword(victimActor, ActorTypeAnimal)
        return EVT_KILL_ANIMAL_NONCOMBAT
    endIf

    if aiCrimeStatus > 0 && ActorHasKeyword(victimActor, ActorTypeNPC)
        return EVT_MURDER_DEFENSELESS
    endIf

    return EVT_NONE
EndFunction

Int Function ClassifyCraftBench(ObjectReference benchRef)
    if ObjectHasKeyword(benchRef, isEnchanting)
        return EVT_ENCHANT_ITEM
    endIf

    if ObjectHasKeyword(benchRef, isAlchemy)
        return EVT_BREW_POTION
    endIf

    if ObjectHasKeyword(benchRef, CraftingCookpot)
        return EVT_COOK_MEAL
    endIf

    if ObjectHasKeyword(benchRef, CraftingSmithingArmorTable) || ObjectHasKeyword(benchRef, CraftingSmithingForge) || ObjectHasKeyword(benchRef, CraftingSmithingSharpeningWheel) || ObjectHasKeyword(benchRef, CraftingSmithingSkyforge)
        return EVT_SMITH_ITEM
    endIf

    return EVT_NONE
EndFunction

Int Function ClassifyBook(Book bookRef)
    if !bookRef
        return EVT_NONE
    endIf

    if PDV_FLST_FaucetSkillBooks && PDV_FLST_FaucetSkillBooks.HasForm(bookRef as Form)
        return EVT_READ_SKILL_BOOK
    endIf

    if PDV_FLST_FaucetSpellTomes && PDV_FLST_FaucetSpellTomes.HasForm(bookRef as Form)
        return EVT_READ_SPELL_TOME
    endIf

    return EVT_READ_LORE_BOOK
EndFunction

Bool Function ActorHasKeyword(Actor actorRef, Keyword keywordRef)
    if !actorRef || !keywordRef
        return false
    endIf

    if actorRef.HasKeyword(keywordRef)
        return true
    endIf

    ActorBase baseActor = actorRef.GetLeveledActorBase()
    if baseActor && baseActor.HasKeyword(keywordRef)
        return true
    endIf

    return false
EndFunction

Bool Function ObjectHasKeyword(ObjectReference objectRef, Keyword keywordRef)
    if !objectRef || !keywordRef
        return false
    endIf

    if objectRef.HasKeyword(keywordRef)
        return true
    endIf

    Form baseObject = objectRef.GetBaseObject()
    if baseObject && baseObject.HasKeyword(keywordRef)
        return true
    endIf

    return false
EndFunction

Bool Function IsPlayerRef(ObjectReference candidateRef)
    if !candidateRef
        return false
    endIf

    Actor playerActor = GetPlayerActor()
    if !playerActor
        return false
    endIf

    return candidateRef == playerActor as ObjectReference
EndFunction

Bool Function IsOwnedReference(ObjectReference targetRef)
    if !targetRef
        return false
    endIf

    if targetRef.GetActorOwner()
        return true
    endIf

    if targetRef.GetFactionOwner()
        return true
    endIf

    return false
EndFunction

Bool Function MarkLocationSeen(Location locationRef)
    if !locationRef
        return false
    endIf

    String seenKey = "PDV.Generic.LocationSeen." + locationRef.GetFormID()
    if StorageUtil.GetIntValue(None, seenKey) == 1
        return false
    endIf

    StorageUtil.SetIntValue(None, seenKey, 1)
    return true
EndFunction

Actor Function GetPlayerActor()
    if PlayerRef
        return PlayerRef
    endIf

    Trace(1, "PlayerRef not assigned; falling back to Game.GetPlayer().")
    return Game.GetPlayer()
EndFunction

PDV_EventBus Function GetEventBus()
    if PDV_EventBusService
        return PDV_EventBusService
    endIf

    return None
EndFunction

Int Function GetDebugLevel()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel.GetValueInt()
    endIf
    return 0
EndFunction

Function Trace(Int level, String traceText)
    if GetDebugLevel() >= level
        Debug.Trace("[PDV] ActionRouter: " + traceText)
    endIf
EndFunction
