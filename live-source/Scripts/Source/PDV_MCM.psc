;/ 
    PDV_MCM.psc
    PlayerDevotion - development-facing SkyUI MCM
    -----------------------------------------------------------------------
    OVERVIEW
    Thin SkyUI shell for player-facing devotion status plus curated debug
    actions. Numeric ledgers and mutation tools stay behind Developer Options.

    DESIGN NOTES
    - Scope is intentionally narrow: Player + gated Status/Debug only.
    - Patron changes exposed here are debug overrides, not theology UX.
    - No config globals or player-facing tuning controls land in this slice.
    - All interactive option OIDs are stored for reliable event handling.
    -----------------------------------------------------------------------
/;

Scriptname PDV_MCM extends SKI_ConfigBase

PDV__ManagerQuest Property PDV_Manager Auto
PDV_EventBus Property PDV_EventBusService Auto
PDV_ModePreset Property PDV_ModePresetRef Auto
FormList Property PDV_FLST_AllDeities Auto
FormList Property PDV_FLST_RepTracks_All Auto
FormList Property PDV_FLST_StateTracks_All Auto
FormList Property PDV_FLST_Substrates_All Auto
; Inert since the SacredPlace cut (1.0.3): the subsystem is superseded by the live
; per-race home systems (Argonian bed-of-choice, the shared hearth-rest declaration,
; Khajiit road-homes), so nothing reads this list any more. Kept declared only because
; the PDV_MCM record BINDS it - deleting the declaration would log a "property does not
; exist" warning every load.
FormList Property PDV_FLST_SacredPlaces_All Auto
FormList Property PDV_FLST_DaedricPaths_All Auto
GlobalVariable Property PDV_GLO_ActivePiety Auto
GlobalVariable Property PDV_GLO_ActiveTier Auto
GlobalVariable Property PDV_GLO_ActiveDeityIndex Auto
GlobalVariable Property PDV_GLO_PatronDeity Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
PDV_CurseState Property PDV_CurseStateService Auto

Int Property DEBUG_LEVEL_MIN = 0 AutoReadOnly
Int Property DEBUG_LEVEL_MAX = 3 AutoReadOnly
Float Property PIETY_MIN = 0.0 AutoReadOnly
Float Property PIETY_MAX = 200.0 AutoReadOnly
Float Property PIETY_TODAY_MIN = -5.0 AutoReadOnly
Float Property PIETY_TODAY_MAX = 5.0 AutoReadOnly
Float Property SIGNAL_TYPE_MIN = 0.0 AutoReadOnly
; B17 / fix-plan 9.2: was 999.0, but real curated-signal ids run 101-3102, so the debug
; slider could reach only about nine of the 34 deities -- everything from Akatosh through
; Stuhn was unreachable from the tool built to fire it. 3200 clears the whole range with
; headroom (and is the range fix-plan 5.3 named as free for any future renumbering).
Float Property SIGNAL_TYPE_MAX = 3200.0 AutoReadOnly

String Property PAGE_PLAYER = "Player" AutoReadOnly
String Property PAGE_COMPAT = "Settings" AutoReadOnly
String Property PAGE_STATUS = "Status" AutoReadOnly
String Property PAGE_DEBUG = "Debug: State & Rewards" AutoReadOnly
String Property PAGE_DEBUG2 = "Debug: Daedric & Curse" AutoReadOnly
String Property PAGE_PACING = "Debug: Pacing & Pantheons" AutoReadOnly

Int _oidSurveyDevotion = -1
Int _oidExportReport = -1
Int _oidModeToggle = -1
Int _oidNpcRecognition = -1
Int _oidNpcHostileRecognition = -1
Int _oidToastSize = -1
Int _oidSelectedDeity = -1
Int _oidDebugPatronOverride = -1
Int _oidDebugClearPatron = -1
Int _oidDebugResetDeity = -1
Int _oidDebugLevel = -1
Int _oidPendingPiety = -1
Int _oidApplyPiety = -1
Int _oidPendingPietyToday = -1
Int _oidApplyPietyToday = -1
Int _oidSeedBroadLane = -1
Int _oidPendingBretonPractice = -1
Int _oidApplyBretonPractice = -1
Int _oidAddBretonRenewable = -1
Int _oidAddBretonCurated = -1
Int _oidShowBretonPractice = -1
Int _oidResetBretonPractice = -1
Int _oidPrepareUninstall = -1
; A1 / fix-plan Group 11.2 -- manual stat repair (MCM-only; no automatic pass).
Int _oidRepairStats = -1
Int _oidShowStatResidue = -1
Int _oidPendingSignalType = -1
Int _oidApplyCuratedSignal = -1
Int _oidDisfavorEventId = -1
Int _oidFireDislike = -1
Int _oidDisfavorDomainCycle = -1
Int _oidDisfavorBandToggle = -1
Int _oidApplyDomainSting = -1
Int _oidDisfavorBurst = -1
Int _oidDisfavorShow = -1
Int _oidDisfavorClear = -1
Int _oidRunDawn = -1
Int _oidShowPietyMap = -1
Int _oidShowStructuralMap = -1
Int _oidRunScaffoldApiSmoke = -1
Int _oidReloadQuestMatrix = -1
Int _oidSignalFloorScenario = -1
Int _oidSignalFloorRun = -1
Int _oidQuestReactionQueueStatus = -1
Int _oidQuestReactionPerformanceSweep = -1
Int _oidDiegeticD1 = -1
Int _oidShowPatternSummary = -1
Int _oidConcordatDefiance = -1
Int _oidConcordatCompliance = -1
Int _oidTalosShrineDefiance = -1
Int _oidTalosBetrayalCompliance = -1
Int _oidTalosBetrayalMajor = -1
Int _oidConcordatUnlockGate = -1
Int _oidBosmerOldContract = -1
Int _oidBosmerBanditRoad = -1
Int _oidBosmerLivingStory = -1
Int _oidBosmerExchange = -1
Int _oidBosmerSeedVariety = -1
Int _oidBosmerGreenPactViolation = -1
Int _oidBosmerLivingStorySignal = -1
Int _oidBosmerExchangeSignal = -1
Int _oidBosmerBanditRoadSignal = -1
Int _oidBosmerPactPositiveSignal = -1
Int _oidBosmerConfirmRite = -1
Int _oidDunmerPrayer = -1
Int _oidDunmerHomeBonus = -1
Int _oidKhajiitMoonObservance = -1
Int _oidKhajiitRoadHome = -1
Int _oidKhajiitPostureCycle = -1
Int _oidKhajiitCaravanAid = -1
Int _oidKhajiitLegendMade = -1
Int _oidKhajiitLunarSeedT2 = -1
Int _oidKhajiitLunarSeedT3 = -1
Int _oidKhajiitLunarReset = -1
Int _oidKhajiitLunarBudgetShow = -1
Int _oidMephalaWebWoven = -1
Int _oidBoethiahHonorableDuel = -1
Int _oidDebugSetBroadWorship = -1
Int _oidNordOldWays = -1
Int _oidNordNineDivines = -1
Int _oidFavorLaneCycle = -1
Int _oidFavorFamilyCycle = -1
Int _oidFavorTrigger = -1
Int _oidFavorExpire = -1
Int _oidEvaluateCommitmentOffer = -1
Int _oidCommitmentSeedSignals = -1
Int _oidCommitmentReset = -1
Int _oidAcceptCommitmentOffer = -1
Int _oidDeclineCommitmentOffer = -1
Int _oidRefuseCommitmentOffer = -1
Int _oidHircineReset = -1
Int _oidHircineHuntRite = -1
Int _oidHircineRenounce = -1
Int _oidDaedricSelectedPath = -1
Int _oidDaedricShowSummary = -1
Int _oidDaedricReset = -1
Int _oidDaedricSignal = -1
Int _oidDaedricSeeker = -1
Int _oidDaedricDevoted = -1
Int _oidDaedricChampion = -1
Int _oidDaedricLapse = -1
Int _oidDaedricStigma = -1
Int _oidDaedricLiveRoute = -1
Int _oidDaedricRouteAll = -1
Int _oidDaedricGenericProbe = -1
Int _oidCurseRefreshFromPlayer = -1
Int _oidCurseProofRaceCycle = -1
Int _oidCurseProofRaceApply = -1
Int _oidForceCurseNone = -1
Int _oidForceCurseWerewolf = -1
Int _oidForceCurseVampire = -1
Bool _patternActionPromptOpen = False
Int _oidForceSelectedPatron = -1
Int _oidPrimeNeglectEligible = -1
Int _oidNeglectRunPass = -1
Int _oidPrimeRaceLaneNeglect = -1
Int _oidDecayPrimeGrace = -1
Int _oidDecayPrimeEligible = -1
Int _oidDecayRunPass = -1
Int _oidDecayRunProofDays = -1
Int _oidShowDecaySummary = -1
Int _oidCompatRaceMapping = -1
Int _oidCompatSurvival = -1
Int _oidCompatCC = -1
Int _oidInGameEffects = -1
Int _oidNotifications = -1
Int _oidReDetectOrigin = -1
Int _oidOpenJournalNow = -1
Int _oidJournalHotkey = -1
Int _oidPanelHotkey = -1

Int _oidPacingSubstrateOrigin = -1
Int _oidPacingSubstrateOriginApply = -1
Int _oidPacingSubstrateSource = -1
Int _oidPacingSubstrateStatus = -1
Int _oidPacingSubstrateTrigger = -1
Int _oidPacingSubstrateReset = -1
Int _oidPacingSubstrateSeed0 = -1
Int _oidPacingSubstrateSeed24 = -1
Int _oidPacingSubstrateSeed25 = -1
Int _oidPacingSubstrateSeed74 = -1
Int _oidPacingSubstrateSeed75 = -1
Int _oidPacingBroadPool = -1
Int _oidPacingBroadStatus = -1
Int _oidPacingBroadReset = -1
Int _oidPacingBroadSeed24 = -1
Int _oidPacingBroadSeed25 = -1
Int _oidPacingBroadSeed49 = -1
Int _oidPacingBroadSeed50 = -1
Int _oidPacingBroadFanout = -1
Int _oidPacingBroadScratchPositive = -1
Int _oidPacingBroadScratchNegative = -1
Int _oidPacingBroadMigration = -1
Int _oidPacingBroadCatchup = -1
Int _oidPacingNordBaseline = -1
Int _oidPacingNordBaselineApply = -1
Int _oidPacingPatronStatus = -1
Int _oidPacingSetBroad = -1
Int _oidPacingPatronOffer = -1
Int _oidPacingPatronAccept = -1
Int _oidPacingPatronLapse = -1
Int _oidPacingPatronRecover = -1
Int _oidPacingImperialVampire = -1
Int _oidPacingImperialCure = -1

Int _oidKhajiitFocusBaanDar = -1
Int _oidKhajiitFocusRajhin = -1
Int _oidKhajiitFocusAlkosh = -1
Int _oidBretonKnightsRoad = -1
Int _oidBretonHiddenArt = -1
Int _oidBretonGreenWay = -1
Int _oidOrcCity = -1
Int _oidOrcStronghold = -1
Int _oidOrcLegionExile = -1
Int _oidArgonianPeople = -1
Int _oidArgonianVoid = -1

Int _selectedListIndex = 0
Int _selectedDaedricPathIndex = 0
Int _selectedSignalFloorScenario = 0
Float _pendingPiety = 10.0
Float _pendingPietyToday = 1.0
Float _pendingBretonPractice = 24.0
Int _pendingSignalType = 103
Int _pendingDisfavorEventId = 365
Int _pendingDisfavorDomain = 1
Bool _pendingDisfavorSharp = False
Int _selectedCurseProofOrigin = -1
Int _selectedSubstratePacingOrigin = 0
Int _selectedSubstratePacingSource = 0
Int _selectedBroadPantheonPool = 0
Int _selectedNordBaselineForPacing = 0

Event OnInit()
    InitializePages()
    Parent.OnInit()
EndEvent

Function OnGameReload()
    InitializePages()
    RegisterJournalHotkey()
    ; A load recreates the Prisma view closed, so the journal-open toggle must start
    ; closed or the first hotkey press would "close" an already-closed book.
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
    ApplyInGameEffectsPreference()
    Parent.OnGameReload()
EndFunction

Function OnConfigInit()
    InitializePages()
    RegisterJournalHotkey()
    ApplyInGameEffectsPreference()
EndFunction

Function ApplyInGameEffectsPreference()
    ; Re-assert the player's In-Game Effects choice on load so the D1 diegetic layer
    ; matches the saved preference (default on) regardless of the baked ESP flag.
    if EnsureManagerBinding("apply_ingame_effects")
        PDV_Manager.ApplyInGameEffectsPreference()
    endIf
EndFunction

Function RegisterJournalHotkey()
    Int savedKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    Int savedPanelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    if savedKey >= 0 && savedPanelKey == savedKey
        StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)
        savedPanelKey = -1
    endIf
    if savedKey >= 0
        RegisterForKey(savedKey)
    endIf
    if savedPanelKey >= 0
        RegisterForKey(savedPanelKey)
    endIf
EndFunction

Int Function GetVersion()
    return 1
EndFunction

Function OnPageReset(String a_page)
    ; B5 / fix-plan 9.1: FIRST statement, before any page is built. Replaces the two
    ; hand-picked spot-resets that used to live here (_oidModeToggle,
    ; _oidPrepareUninstall) -- see ResetAllOptionIds below for why partial coverage
    ; was never enough.
    ResetAllOptionIds()
    InitializePages()
    EnsureManagerBinding("page_reset_" + a_page)

    if a_page == "" || a_page == PAGE_PLAYER
        BuildPlayerPage()
        return
    endIf

    if a_page == PAGE_COMPAT
        BuildCompatPage()
        return
    endIf

    if a_page == PAGE_STATUS
        if !DeveloperOptionsEnabled()
            BuildDeveloperLockedPage("Status")
            return
        endIf
        BuildStatusPage()
        return
    endIf

    if a_page == PAGE_DEBUG
        if !DeveloperOptionsEnabled()
            BuildDeveloperLockedPage("Debug: State & Rewards")
            return
        endIf
        BuildStatePage()
        return
    endIf

    if a_page == PAGE_DEBUG2
        if !DeveloperOptionsEnabled()
            BuildDeveloperLockedPage("Debug: Daedric & Curse")
            return
        endIf
        BuildDaedricPage()
        return
    endIf

    if a_page == PAGE_PACING
        if !DeveloperOptionsEnabled()
            BuildDeveloperLockedPage("Debug: Pacing & Pantheons")
            return
        endIf
        BuildPacingPantheonsPage()
    endIf
EndFunction

Function OnOptionHighlight(Int a_option)
    if a_option == _oidSurveyDevotion
        SetInfoText("Shows the current devotion readout without exposing numeric piety.")
    elseIf a_option == _oidExportReport
        SetInfoText("Writes a full devotion snapshot to a text file you can attach to a bug report. No log digging needed.")
    elseIf a_option == _oidCompatRaceMapping
        SetInfoText("Maps normal or vampire custom races to a vanilla devotion profile. Beast forms should use the temporary-race defer list.")
    elseIf a_option == _oidReDetectOrigin
        SetInfoText("Runs origin detection again for this save. Use after adding a custom-race map or fixing a fallback.")
    elseIf a_option == _oidCompatSurvival
        SetInfoText("Let an installed survival mod's hardship gently modulate devotion. It never creates piety alone.")
    elseIf a_option == _oidCompatCC
        SetInfoText("Let supported AE and Creation Club content add small optional devotion signals. No CC plugin is required.")
    elseIf a_option == _oidInGameEffects
        SetInfoText("On-screen devotion cues: screen effects, sounds, and music stingers when your standing shifts. Turn off for a quieter, effects-free experience. The Book of Days journal still records everything.")
    elseIf a_option == _oidNotifications
        SetInfoText("Corner toast messages when your devotion changes. Turn off to play with no pop-up notifications. The Book of Days journal still records everything.")
    elseIf a_option == _oidToastSize
        SetInfoText("Size of the corner toast pop-ups. Large is intended for 4K displays where the normal toast reads small. Does not affect the Book of Days journal.")
    elseIf a_option == _oidNpcRecognition
        SetInfoText("Faith-aware NPCs treat you as a friend at Faithful standing and an ally at Devoted. Requires SPID. (experimental)")
    elseIf a_option == _oidNpcHostileRecognition
        SetInfoText("At Devoted standing, your god's sworn rivals may treat you as an enemy. (experimental)")
    elseIf a_option == _oidModeToggle
        SetInfoText("Switches between the authored Pilgrim's Path and the gentler Wayfarer's Path for non-survival players.")
    elseIf a_option == _oidPacingSubstrateOrigin
        SetInfoText("Cycles the substrate pacing target through Imperial, Dunmer, Argonian, Nord, Altmer, and Khajiit.")
    elseIf a_option == _oidPacingSubstrateOriginApply
        SetInfoText("Applies the selected race as the test origin and refreshes dependent state. Use only on the throwaway pacing save before triggering that race's true handler.")
    elseIf a_option == _oidPacingSubstrateStatus
        SetInfoText("Shows the selected metric, tier, devotional day, daily-credit state, last accepted or rejected source, and decay settings.")
    elseIf a_option == _oidPacingSubstrateTrigger
        SetInfoText("Runs one approved production handler for the selected race. Repeated or cross-source acts on the same devotional day must not add more credit.")
    elseIf a_option == _oidPacingSubstrateReset
        SetInfoText("Resets the selected substrate metric and its pacing telemetry for a clean proof case.")
    elseIf a_option == _oidPacingSubstrateSeed0 || a_option == _oidPacingSubstrateSeed24 || a_option == _oidPacingSubstrateSeed25 || a_option == _oidPacingSubstrateSeed74 || a_option == _oidPacingSubstrateSeed75
        SetInfoText("Direct boundary seed for tier and player-surface proof. This bypasses daily pacing and is not organic-route evidence.")
    elseIf a_option == _oidPacingBroadPool
        SetInfoText("Cycles the broad-pantheon target through Imperial Divines, Nord Old Ways, and Nord Nine Divines.")
    elseIf a_option == _oidPacingBroadStatus
        SetInfoText("Shows the selected pool standing, active roster, event scratch, most recent event, threshold, decay, and suppression state.")
    elseIf a_option == _oidPacingBroadReset
        SetInfoText("Resets the selected broad-pantheon pool and its migration/debug state for a clean proof case.")
    elseIf a_option == _oidPacingBroadSeed24 || a_option == _oidPacingBroadSeed25 || a_option == _oidPacingBroadSeed49 || a_option == _oidPacingBroadSeed50
        SetInfoText("Direct boundary seed for broad reward and display proof. This bypasses normal event aggregation and dawn pacing.")
    elseIf a_option == _oidPacingBroadFanout
        SetInfoText("Runs the signed mixed-god fan-out fixture. One logical event must contribute only its strongest eligible positive, or its strongest negative when no positive applies.")
    elseIf a_option == _oidPacingBroadScratchPositive || a_option == _oidPacingBroadScratchNegative
        SetInfoText("Stages deliberately excessive signed scratch. Wait through a real 06:00 dawn and confirm the selected pool folds no more than +4.3 or -4.3. This control does not advance time.")
    elseIf a_option == _oidPacingBroadMigration
        SetInfoText("Destructive throwaway-save fixture. Runs the real migration twice: Imperial count 3 to 25, Old Ways count 6 to 50, and eligible Nine Divines from the highest god only. Reload the clean QASmoke save afterward.")
    elseIf a_option == _oidPacingBroadCatchup
        SetInfoText("PS-A11 throwaway-save control. After one real positive act has folded and this pool is suppressed, runs the real catch-up routine through five days after its recorded gain. It does not change Skyrim time.")
    elseIf a_option == _oidPacingNordBaseline
        SetInfoText("Cycles the Nord broad baseline between Old Ways and Nine Divines. Only the selected baseline may gain or grant its broad boon.")
    elseIf a_option == _oidPacingNordBaselineApply
        SetInfoText("Applies the selected Nord baseline without changing either persistent broad pool.")
    elseIf a_option == _oidPacingPatronStatus
        SetInfoText("Shows the broad-to-focused transition, including pending offer, retained deity piety, boon suspension, and recovery state.")
    elseIf a_option == _oidPacingSetBroad
        SetInfoText("Returns the current Imperial or Nord test origin to clean broad worship, clears any pending offer, and preserves deity and pool ledgers.")
    elseIf a_option == _oidPacingPatronOffer
        SetInfoText("Runs the controlled patron-offer setup for the active Imperial or Nord broad baseline.")
    elseIf a_option == _oidPacingPatronAccept
        SetInfoText("Accepts the controlled offer. Deity piety is preserved, the broad boon is suppressed, and focused T2 begins at 50.")
    elseIf a_option == _oidPacingPatronLapse
        SetInfoText("Sets the active patron to 49 piety and resynchronizes rewards. Commitment remains, but the focused boon must suspend.")
    elseIf a_option == _oidPacingPatronRecover
        SetInfoText("Restores the active patron to 50 piety and resynchronizes rewards. Focused T2 must return without a new commitment.")
    elseIf a_option == _oidPacingImperialVampire
        SetInfoText("Applies Imperial vampire onset: reset civic standing to zero, strip its boon, and block civic and broad gains.")
    elseIf a_option == _oidPacingImperialCure
        SetInfoText("Applies Imperial vampire cure and seeds civic standing at 20. Two new devotional days are still needed to cross 25.")
    elseIf a_option == _oidSelectedDeity
        SetInfoText("Cycles the current debug target through the live deity roster.")
    elseIf a_option == _oidDebugPatronOverride
        SetInfoText("Development-only override. Real patron commitment should come from in-world threshold events.")
    elseIf a_option == _oidDebugClearPatron
        SetInfoText("Clears the current debug patron override without changing deity ledgers.")
    elseIf a_option == _oidDebugResetDeity
        SetInfoText("Zeros persistent piety, scratch piety, and tier for the selected deity only.")
    elseIf a_option == _oidDebugLevel
        SetInfoText("Sets PDV trace verbosity from 0 to 3 for development logging.")
    elseIf a_option == _oidPendingPiety
        SetInfoText("Choose the persistent piety value to force onto the selected deity.")
    elseIf a_option == _oidApplyPiety
        SetInfoText("Applies the chosen persistent piety to the selected deity and recomputes tier.")
    elseIf a_option == _oidPendingPietyToday
        SetInfoText("Choose the scratch piety value to force onto the selected deity before dawn.")
    elseIf a_option == _oidApplyPietyToday
        SetInfoText("Applies the chosen scratch piety to the selected deity only.")
    elseIf a_option == _oidSeedBroadLane
        SetInfoText("Seeds the current origin's broad or tradition lane directly to T2 for reward/UI proof. Breton receives 50 practice points. This bypasses pacing.")
    elseIf a_option == _oidPendingBretonPractice
        SetInfoText("Sets the direct Breton practice-point target used by Apply practice target. Use 24/25 and 49/50 for boundary tests.")
    elseIf a_option == _oidApplyBretonPractice
        SetInfoText("Directly sets the active Breton tradition's practice points and clears today's debug budget. Boundary/UI proof only; not pacing proof.")
    elseIf a_option == _oidAddBretonRenewable
        SetInfoText("Adds a controlled +1 renewable pulse through the shared Breton daily cap and reward funnel.")
    elseIf a_option == _oidAddBretonCurated
        SetInfoText("Adds a controlled +2 curated pulse through the shared Breton daily cap and reward funnel.")
    elseIf a_option == _oidShowBretonPractice
        SetInfoText("Shows active tradition points, public standing, points awarded today, and remaining daily budget.")
    elseIf a_option == _oidResetBretonPractice
        SetInfoText("Resets the active Breton tradition to zero practice points and clears today's debug practice budget.")
    elseIf a_option == _oidPendingSignalType
        SetInfoText("Choose the curated signal ID to apply to the selected deity. Talos uses 101, 102, and 103. Auri-El uses 201 and 202.")
    elseIf a_option == _oidApplyCuratedSignal
        SetInfoText("Routes the chosen curated signal through the manager so stance and rivalry apply normally.")
    elseIf a_option == _oidDisfavorEventId
        SetInfoText("Choose the dislike event ID to fire (e.g. 304 murder-defenseless, 362 steal-item, 365 raise-undead). The button label shows whether the selected deity has a dislike row for it.")
    elseIf a_option == _oidFireDislike
        SetInfoText("Fires the real dislike loss + disfavor sting for the selected deity through the live dispatch. Set Target piety >= 25 first so the standing gate passes; below standing only the piety loss applies.")
    elseIf a_option == _oidDisfavorDomainCycle
        SetInfoText("Cycles the disfavor domain (1 Sky/Storm/Hunt .. 7 Void/Secrets) for the direct Apply domain sting button.")
    elseIf a_option == _oidDisfavorBandToggle
        SetInfoText("Toggles the disfavor band (Light or Sharp) for the direct Apply domain sting button.")
    elseIf a_option == _oidApplyDomainSting
        SetInfoText("Directly adds the selected domain + band sting spell with a real expiry so you can eyeball the raw MGEF magnitude, text, and duration. Bypasses standing/repeat/cap gates.")
    elseIf a_option == _oidDisfavorBurst
        SetInfoText("Clears active disfavor, then fires four distinct-domain stings so you can confirm the cap holds at 3 active and the 4th is suppressed.")
    elseIf a_option == _oidDisfavorShow
        SetInfoText("Shows the active disfavor domains with their band and remaining game-minutes.")
    elseIf a_option == _oidDisfavorClear
        SetInfoText("Removes all active disfavor sting spells and clears their expiry state.")
    elseIf a_option == _oidRunDawn
        SetInfoText("Runs ProcessDawn immediately so scratch piety consolidates into stored piety.")
    elseIf a_option == _oidShowPietyMap
        SetInfoText("Shows a compact live summary of each deity's stored piety, scratch piety, and tier.")
    elseIf a_option == _oidShowStructuralMap
        SetInfoText("Shows the current dev-only scaffold inventory across tracks, substrates, sacred places, Daedric paths, and curse state.")
    elseIf a_option == _oidRunScaffoldApiSmoke
        SetInfoText("Exercises one safe set/read/reset path on each scaffold family and writes trace output.")
    elseIf a_option == _oidReloadQuestMatrix
        SetInfoText("Forces a fresh disk re-read of the quest-reaction matrix JSON (core + ARR channel) into memory. Use after regenerating the matrix mid-session so already-watched quests pick up newly-authored cells. Brand-new watched quests still need a game reload.")
    elseIf a_option == _oidSignalFloorScenario
        SetInfoText("Cycles the controlled signal-floor smoke scenario. These routes are backend proof only; organic smoke still proves runtime route and display behavior.")
    elseIf a_option == _oidSignalFloorRun
        SetInfoText("Runs the selected controlled manager route. It can prove the manager, Prisma, and Book of Days surfaces, but not organic quest-stage delivery.")
    elseIf a_option == _oidQuestReactionQueueStatus
        SetInfoText("Read-only worker queue state. A queued quest reaction processes two cells every 0.1 seconds and finishes with one toast and one Book of Days entry.")
    elseIf a_option == _oidQuestReactionPerformanceSweep
        SetInfoText("Queues MQ101, MQ105, MQ106, and MQ206 through the manager only. Use a disposable save; wait for QR_QUEUE COMPLETE markers, then reopen Book of Days if it was already open.")
    elseIf a_option == _oidDiegeticD1
        SetInfoText("Runtime toggle for the D1 diegetic surfaces (screen, sound, music). Default off; flip on to preview and tune on the current save, then bake D1Enabled into the ESP to ship.")
    elseIf a_option == _oidShowPatternSummary
        SetInfoText("Shows the integrated Pattern Proving summary across Concordat, Bosmer, substrate, Hircine, favor, commitment, and neglect state.")
    elseIf a_option == _oidConcordatDefiance
        SetInfoText("Routes one non-kill Concordat defiance event through EventBus and the ConcordatStanding track.")
    elseIf a_option == _oidConcordatCompliance
        SetInfoText("Routes one non-kill Concordat compliance event through EventBus and the ConcordatStanding track.")
    elseIf a_option == _oidTalosShrineDefiance
        SetInfoText("Routes the hidden Talos shrine defiance signal through EventBus and Talos/Concordat handling.")
    elseIf a_option == _oidTalosBetrayalCompliance
        SetInfoText("Applies the medium Talos betrayal creed loss when the current run is focused on Talos.")
    elseIf a_option == _oidTalosBetrayalMajor
        SetInfoText("Applies the major Talos betrayal creed loss when the current run is focused on Talos.")
    elseIf a_option == _oidConcordatUnlockGate
        SetInfoText("Unlocks the extreme Concordat walk-back gate so Open Defiant or Concordat Enforcer can be left.")
    elseIf a_option == _oidBosmerOldContract
        SetInfoText("Sets BosmerPath to OldContract for Green Pact proving.")
    elseIf a_option == _oidBosmerBanditRoad
        SetInfoText("Sets BosmerPath to BanditRoad to prove non-OldContract handling.")
    elseIf a_option == _oidBosmerLivingStory
        SetInfoText("Sets BosmerPath to LivingStory (the default path) for Hearth/Tale Carried proving.")
    elseIf a_option == _oidBosmerExchange
        SetInfoText("Sets BosmerPath to Exchange for Scales at Rest proving.")
    elseIf a_option == _oidBosmerSeedVariety
        SetInfoText("Clears the Naming/Scales/Gap once-day cooldowns and seeds +3 location discoveries on the current path (variety levers reachable fast).")
    elseIf a_option == _oidBosmerGreenPactViolation
        SetInfoText("Triggers one PDV-owned Green Pact violation. Only OldContract should react.")
    elseIf a_option == _oidBosmerLivingStorySignal
        SetInfoText("Records one Living Story signal and updates Bosmer path evidence.")
    elseIf a_option == _oidBosmerExchangeSignal
        SetInfoText("Records one Exchange signal and updates Bosmer path evidence.")
    elseIf a_option == _oidBosmerBanditRoadSignal
        SetInfoText("Records one Bandit Road signal and updates Bosmer path evidence.")
    elseIf a_option == _oidBosmerPactPositiveSignal
        SetInfoText("Records one Pact-positive Bosmer signal and shared path memory handling.")
    elseIf a_option == _oidBosmerConfirmRite
        SetInfoText("Runs the shared state-transition confirmation rite for the current pending path.")
    elseIf a_option == _oidDunmerPrayer
        SetInfoText("Records one portable-shrine ancestor prayer on the Dunmer substrate.")
    elseIf a_option == _oidDunmerHomeBonus
        SetInfoText("Records one player-home ancestor bonus on the Dunmer substrate.")
    elseIf a_option == _oidKhajiitMoonObservance
        SetInfoText("Records one Khajiit moon observance and advances the observed phase for proving.")
    elseIf a_option == _oidKhajiitRoadHome
        SetInfoText("Records one Khajiit road-home cadence event.")
    elseIf a_option == _oidKhajiitPostureCycle
        SetInfoText("Cycles the Khajiit Lunar Lattice posture (Normal / Strained / Corrupted / ShadowDrift) to surface each readout and curse message for proving.")
    elseIf a_option == _oidKhajiitLunarSeedT2
        SetInfoText("Directly sets the lunar substrate metric to 25 (tier 2). Boundary/reward/UI proof only; bypasses the shared daily metric budget.")
    elseIf a_option == _oidKhajiitLunarSeedT3
        SetInfoText("Directly sets the lunar substrate metric to 75 (tier 3). Boundary/reward/UI proof only; bypasses the shared daily metric budget.")
    elseIf a_option == _oidKhajiitLunarReset
        SetInfoText("Resets the lunar substrate metric, counters, and boons to zero and clears today's shared metric budget.")
    elseIf a_option == _oidKhajiitLunarBudgetShow
        SetInfoText("Shows the lunar substrate metric, tier, metric spent today, and remaining shared daily budget (4 per game day across moon + road-home).")
    elseIf a_option == _oidKhajiitCaravanAid
        SetInfoText("Fires one Khenarthi caravan-aid signal (daily-capped). Organic route: kill a hostile near a living caravan leader's camp.")
    elseIf a_option == _oidKhajiitLegendMade
        SetInfoText("Fires one Rajhin legend-made signal (daily-capped). Organic route: a single steal or pickpocket take worth 500+ gold.")
    elseIf a_option == _oidMephalaWebWoven
        SetInfoText("Fires one Mephala web-woven signal (daily-capped). Organic routes: DA08 or Diplomatic Immunity resolution one-shots.")
    elseIf a_option == _oidBoethiahHonorableDuel
        SetInfoText("Fires one Boethiah honorable-duel signal (daily-capped). Organic route: win a brawl.")
    elseIf a_option == _oidDebugSetBroadWorship
        SetInfoText("Sets the manager to Broad worship so the Nord broad favor lanes can be tested.")
    elseIf a_option == _oidNordOldWays
        SetInfoText("Sets the Nord pantheon baseline to OldWays for broad-lane proof.")
    elseIf a_option == _oidNordNineDivines
        SetInfoText("Sets the Nord pantheon baseline to NineDivines for broad-lane proof.")
    elseIf a_option == _oidFavorLaneCycle
        SetInfoText("Cycles the selected contextual-favor lane for Phase 12 proof.")
    elseIf a_option == _oidFavorFamilyCycle
        SetInfoText("Cycles the selected favor family inside the currently selected lane.")
    elseIf a_option == _oidFavorTrigger
        SetInfoText("Attempts to trigger the selected contextual favor through the real manager gate.")
    elseIf a_option == _oidFavorExpire
        SetInfoText("Clears the current active contextual favor so the next proof case can fire.")
    elseIf a_option == _oidEvaluateCommitmentOffer
        SetInfoText("Evaluates the first real non-Khajiit Kyne commitment offer in dev-safe form.")
    elseIf a_option == _oidCommitmentSeedSignals
        SetInfoText("Seeds a two-day commitment signal window on the selected deity so the formal offer gate can be smoked immediately.")
    elseIf a_option == _oidCommitmentReset
        SetInfoText("Clears pending commitment, cooldown, rupture, legacy transition telemetry, and seeded signal days for the selected deity.")
    elseIf a_option == _oidAcceptCommitmentOffer
        SetInfoText("Accepts the pending commitment offer, preserves deity piety, and grants the focused tier allowed by current piety.")
    elseIf a_option == _oidDeclineCommitmentOffer
        SetInfoText("Declines the pending commitment offer and postpones it.")
    elseIf a_option == _oidRefuseCommitmentOffer
        SetInfoText("Refuses the pending commitment offer and applies rupture/cooldown.")
    elseIf a_option == _oidHircineReset
        SetInfoText("Resets the Hircine proving ledger, residue, and curse state to a clean baseline.")
    elseIf a_option == _oidHircineHuntRite
        SetInfoText("Records one Hircine hunt rite and advances the boon/price/stigma contract.")
    elseIf a_option == _oidHircineRenounce
        SetInfoText("Renounces the Hircine path and resets the proving contract state.")
    elseIf a_option == _oidDaedricSelectedPath
        SetInfoText("Cycles the controlled Daedric display-proof target through all sixteen Prince paths.")
    elseIf a_option == _oidDaedricShowSummary
        SetInfoText("Shows piety, tier, commitment signals, stigma, race state, boon, price, and exit summary for the selected Prince.")
    elseIf a_option == _oidDaedricReset
        SetInfoText("Resets the selected Prince path to a clean controlled-proof baseline.")
    elseIf a_option == _oidDaedricSignal
        SetInfoText("Adds one controlled commitment signal to the selected Prince and emits proof feedback.")
    elseIf a_option == _oidDaedricSeeker
        SetInfoText("Forces the selected Prince to Seeker threshold and syncs boon/price active effects.")
    elseIf a_option == _oidDaedricDevoted
        SetInfoText("Forces the selected Prince to Devoted threshold and syncs boon/price active effects.")
    elseIf a_option == _oidDaedricChampion
        SetInfoText("Forces the selected Prince to Champion threshold and syncs boon/price active effects.")
    elseIf a_option == _oidDaedricLapse
        SetInfoText("Forces the selected Prince below Seeker and clears synced boon/price active effects.")
    elseIf a_option == _oidDaedricStigma
        SetInfoText("Adds one controlled stigma event to the selected Prince and emits proof feedback.")
    elseIf a_option == _oidDaedricLiveRoute
        SetInfoText("Routes the selected Prince through the EventBus live-sender path for display proof.")
    elseIf a_option == _oidDaedricRouteAll
        SetInfoText("Routes all sixteen Prince sender cues through EventBus, then runs the generic silence probe.")
    elseIf a_option == _oidDaedricGenericProbe
        SetInfoText("Routes a generic Daedric silence probe that should not change Prince state.")
    elseIf a_option == _oidCurseRefreshFromPlayer
        SetInfoText("Refreshes curse detection from the live player state without forcing a backend override.")
    elseIf a_option == _oidCurseProofRaceCycle
        SetInfoText("Cycles the stored PDV origin used by the race-specific curse dispatcher. This proof-only override covers all ten origins.")
    elseIf a_option == _oidCurseProofRaceApply
        SetInfoText("Temporarily rewrites PDV_GLO_OriginRace and refreshes dependent state. Use only on a throwaway proof save and restore the real origin afterward.")
    elseIf a_option == _oidForceCurseNone
        SetInfoText("Backend-forces the shared curse service to None for cure and residue smoke.")
    elseIf a_option == _oidForceCurseWerewolf
        SetInfoText("Backend-forces the shared curse service to Werewolf for Hircine entry smoke.")
    elseIf a_option == _oidForceCurseVampire
        SetInfoText("Backend-forces the shared curse service to Vampire for the Hircine negative path.")
    elseIf a_option == _oidForceSelectedPatron
        SetInfoText("Debug-only setup: makes the selected deity the active focused patron so active-patron neglect can be smoked deterministically.")
    elseIf a_option == _oidPrimeNeglectEligible
        SetInfoText("One-click neglect setup (no modal): forces the selected deity active AND drops its piety to 0 so it is neglect-eligible. Then click Run neglect pass and check Active Effects.")
    elseIf a_option == _oidNeglectRunPass
        SetInfoText("Runs only the neglect/spell-layer selection pass without the rest of dawn.")
    elseIf a_option == _oidPrimeRaceLaneNeglect
        SetInfoText("Backdates the CURRENT origin's race-lane neglect source (Altmer/Redguard/Breton/Orc/Khajiit) past its grace window and re-syncs, so the race neglect debuff applies with no multi-day wait. Ensure Curse none first.")
    elseIf a_option == _oidDecayPrimeGrace
        SetInfoText("Primes the selected deity inside the decay grace window at 20 piety.")
    elseIf a_option == _oidDecayPrimeEligible
        SetInfoText("Primes the selected deity after the decay grace window at 20 piety.")
    elseIf a_option == _oidDecayRunPass
        SetInfoText("Runs only the passive decay pass without the rest of dawn.")
    elseIf a_option == _oidDecayRunProofDays
        SetInfoText("Runs a compressed multi-day decay proof on the selected deity.")
    elseIf a_option == _oidShowDecaySummary
        SetInfoText("Shows the selected deity's decay state, rate, floor, and last decay day.")
    elseIf a_option == _oidPrepareUninstall
        SetInfoText("Best-effort cleanup for a throwaway uninstall save. Save first. Runs the stat repair first, then strips Devotion's spells, factions and saved data. A pre-install save is the only fully clean removal.")
    elseIf a_option == _oidShowStatResidue
        SetInfoText("Read-only. Lists every actor value that still carries a permanent modifier - the drift older Devotion builds baked into this save. Changes nothing.")
    elseIf a_option == _oidRepairStats
        SetInfoText("SAVE FIRST. Zeroes the permanent modifier on every actor value Devotion can touch, with no Devotion ability held, then re-grants them. Also clears any permanent modifier ANOTHER mod placed on those same values - rare, but real.")
    elseIf a_option == _oidKhajiitFocusBaanDar || a_option == _oidKhajiitFocusRajhin || a_option == _oidKhajiitFocusAlkosh
        SetInfoText("Forces the Khajiit emergent focus to this moon-path so its tier reward becomes testable. Then force piety and Run Dawn to light the Champion blessing.")
    elseIf a_option == _oidBretonKnightsRoad || a_option == _oidBretonHiddenArt || a_option == _oidBretonGreenWay
        SetInfoText("Forces the Breton tradition. Use Breton practice controls for its T1/T2 lane; deity piety remains the separate patron axis.")
    elseIf a_option == _oidOrcCity || a_option == _oidOrcStronghold || a_option == _oidOrcLegionExile
        SetInfoText("Forces the Orc life mode so its mode-gated Malacath reward becomes testable. Then force piety and Run Dawn.")
    elseIf a_option == _oidArgonianPeople || a_option == _oidArgonianVoid
        SetInfoText("Forces the Argonian focus by seeding Hist relations (Void also seeds Sithis activation), so its focus-gated reward becomes testable.")
    elseIf a_option == _oidOpenJournalNow
        SetInfoText("Opens the Book of Days rolling devotion journal.")
    elseIf a_option == _oidJournalHotkey
        SetInfoText("Press the assigned key at any time to open the Book of Days devotion journal. Unbound by default; rebind here.")
    else
        SetInfoText("")
    endIf
EndFunction

Function OnOptionSelect(Int a_option)
    if a_option == _oidSurveyDevotion
        if EnsureManagerBinding("survey_devotion")
            ShowMessage(PDV_Manager.GetSurveyDevotionText(), False, "$OK", "")
        else
            ShowMessage("Devotion is still starting up.", False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidExportReport
        if EnsureManagerBinding("export_report")
            String reportFile = PDV_Manager.ExportDevotionReport()
            if reportFile != ""
                ShowMessage("Devotion report saved as '" + reportFile + "' in your Skyrim game folder (same folder as SkyrimSE.exe). Attach that file to your bug report. If you cannot find it, search your PC for " + reportFile + ". For a crash or a hard-to-repro bug, also attach your Papyrus log (Documents\\My Games\\Skyrim Special Edition\\Logs\\Script\\Papyrus.0.log); the report file lists the exact path.", False, "$OK", "")
            else
                ShowMessage("Could not write the report file. PapyrusUtil may be missing or the folder is read-only.", False, "$OK", "")
            endIf
        else
            ShowMessage("Devotion is still starting up. Wait a moment and try again.", False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidPacingSubstrateOrigin
        _selectedSubstratePacingOrigin += 1
        if _selectedSubstratePacingOrigin > 5
            _selectedSubstratePacingOrigin = 0
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidPacingSubstrateOriginApply
        DebugApplySubstratePacingOrigin()
        ForcePageReset()
        return
    endIf

    if a_option == _oidPacingSubstrateSource
        _selectedSubstratePacingSource += 1
        if _selectedSubstratePacingSource > 2
            _selectedSubstratePacingSource = 0
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidPacingSubstrateStatus
        DebugShowSubstratePacingSummary()
        return
    endIf

    if a_option == _oidPacingSubstrateTrigger
        DebugTriggerSubstratePacingSource()
        return
    endIf

    if a_option == _oidPacingSubstrateReset
        DebugResetSubstratePacing()
        return
    endIf

    if a_option == _oidPacingSubstrateSeed0
        DebugSeedSubstratePacing(0.0)
        return
    endIf

    if a_option == _oidPacingSubstrateSeed24
        DebugSeedSubstratePacing(24.0)
        return
    endIf

    if a_option == _oidPacingSubstrateSeed25
        DebugSeedSubstratePacing(25.0)
        return
    endIf

    if a_option == _oidPacingSubstrateSeed74
        DebugSeedSubstratePacing(74.0)
        return
    endIf

    if a_option == _oidPacingSubstrateSeed75
        DebugSeedSubstratePacing(75.0)
        return
    endIf

    if a_option == _oidPacingBroadPool
        _selectedBroadPantheonPool += 1
        if _selectedBroadPantheonPool > 2
            _selectedBroadPantheonPool = 0
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidPacingBroadStatus
        DebugShowBroadPantheonSummary()
        return
    endIf

    if a_option == _oidPacingBroadReset
        DebugResetBroadPantheonPool()
        return
    endIf

    if a_option == _oidPacingBroadSeed24
        DebugSeedBroadPantheonPool(24.0)
        return
    endIf

    if a_option == _oidPacingBroadSeed25
        DebugSeedBroadPantheonPool(25.0)
        return
    endIf

    if a_option == _oidPacingBroadSeed49
        DebugSeedBroadPantheonPool(49.0)
        return
    endIf

    if a_option == _oidPacingBroadSeed50
        DebugSeedBroadPantheonPool(50.0)
        return
    endIf

    if a_option == _oidPacingBroadFanout
        DebugRunBroadPantheonFanoutTest()
        return
    endIf

    if a_option == _oidPacingBroadScratchPositive
        DebugPrimeBroadPantheonScratch(100.0)
        return
    endIf

    if a_option == _oidPacingBroadScratchNegative
        DebugPrimeBroadPantheonScratch(-100.0)
        return
    endIf

    if a_option == _oidPacingBroadMigration
        DebugRunBroadPantheonMigrationFixture()
        return
    endIf

    if a_option == _oidPacingBroadCatchup
        DebugRunBroadPantheonCatchupForPacing()
        return
    endIf

    if a_option == _oidPacingNordBaseline
        if _selectedNordBaselineForPacing == 0
            _selectedNordBaselineForPacing = 1
        else
            _selectedNordBaselineForPacing = 0
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidPacingNordBaselineApply
        DebugApplyNordBaselineForPacing()
        return
    endIf

    if a_option == _oidPacingPatronStatus
        DebugShowPatronOfferRecoverySummary()
        return
    endIf

    if a_option == _oidPacingSetBroad
        DebugSetBroadWorshipForPacing()
        return
    endIf

    if a_option == _oidPacingPatronOffer
        DebugRunPatronOfferForPacing()
        return
    endIf

    if a_option == _oidPacingPatronAccept
        DebugAcceptPatronForPacing()
        return
    endIf

    if a_option == _oidPacingPatronLapse
        DebugLapsePatronForPacing()
        return
    endIf

    if a_option == _oidPacingPatronRecover
        DebugRecoverPatronForPacing()
        return
    endIf

    if a_option == _oidPacingImperialVampire
        DebugSetImperialVampireForPacing(True)
        return
    endIf

    if a_option == _oidPacingImperialCure
        DebugSetImperialVampireForPacing(False)
        return
    endIf

    if a_option == _oidModeToggle
        ToggleExperienceMode()
        return
    endIf

    if a_option == _oidOpenJournalNow
        OpenBookOfDaysFromMcm()
        return
    endIf

    if a_option == _oidCompatRaceMapping
        ToggleCustomRaceMapping()
        ForcePageReset()
        return
    endIf

    if a_option == _oidReDetectOrigin
        ReDetectOrigin()
        return
    endIf

    if a_option == _oidCompatSurvival
        ToggleSurvivalContext()
        ForcePageReset()
        return
    endIf

    if a_option == _oidCompatCC
        ToggleCCContent()
        ForcePageReset()
        return
    endIf

    if a_option == _oidInGameEffects
        if EnsureManagerBinding("toggle_ingame_effects")
            PDV_Manager.SetInGameEffectsEnabled(!PDV_Manager.InGameEffectsEnabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidNotifications
        if EnsureManagerBinding("toggle_notifications")
            PDV_Manager.SetNotificationsEnabled(!PDV_Manager.NotificationsEnabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidToastSize
        if EnsureManagerBinding("toggle_toast_size")
            PDV_Manager.SetPrismaToastLargeEnabled(!PDV_Manager.PrismaToastLargeEnabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidNpcRecognition
        if EnsureManagerBinding("toggle_npc_recognition")
            PDV_Manager.SetNpcReligiousRecognitionEnabled(!PDV_Manager.NpcReligiousRecognitionEnabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidNpcHostileRecognition
        if EnsureManagerBinding("toggle_npc_hostile_recognition")
            PDV_Manager.SetNpcHostileRecognitionEnabled(!PDV_Manager.NpcHostileRecognitionEnabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidSelectedDeity
        CycleSelectedDeity()
        ForcePageReset()
        return
    endIf

    if a_option == _oidDebugPatronOverride
        DebugOverridePatron()
        return
    endIf

    if a_option == _oidDebugClearPatron
        DebugClearPatron()
        return
    endIf

    if a_option == _oidDebugResetDeity
        DebugResetSelectedDeity()
        return
    endIf

    if a_option == _oidApplyPiety
        DebugApplySelectedPiety()
        return
    endIf

    if a_option == _oidApplyPietyToday
        DebugApplySelectedPietyToday()
        return
    endIf

    if a_option == _oidApplyCuratedSignal
        DebugApplyCuratedSignal()
        return
    endIf

    if a_option == _oidFireDislike
        DebugFireSelectedDislike()
        return
    endIf

    if a_option == _oidDisfavorDomainCycle
        _pendingDisfavorDomain += 1
        if _pendingDisfavorDomain > 7
            _pendingDisfavorDomain = 1
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidDisfavorBandToggle
        _pendingDisfavorSharp = !_pendingDisfavorSharp
        ForcePageReset()
        return
    endIf

    if a_option == _oidApplyDomainSting
        if PDV_Manager
            PDV_Manager.DebugApplyDomainSting(_pendingDisfavorDomain, _pendingDisfavorSharp)
            ShowMessage(PDV_Manager.GetActiveDisfavorSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidDisfavorBurst
        if PDV_Manager
            PDV_Manager.DebugBurstAntiStack()
            ShowMessage(PDV_Manager.GetActiveDisfavorSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidDisfavorShow
        if PDV_Manager
            ShowMessage(PDV_Manager.GetActiveDisfavorSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidDisfavorClear
        if PDV_Manager
            PDV_Manager.ClearAllDisfavorStings()
            ShowMessage(PDV_Manager.GetActiveDisfavorSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidSeedBroadLane
        String seedPrompt = "Seed the current race's broad-worship lane directly to T2? This bypasses normal accumulation and is reward/UI proof only."
        if PDV_Manager && PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_BRETON
            seedPrompt = "Set the active Breton tradition directly to 50 practice points (Devoted)? This bypasses daily pacing and is reward/UI proof only."
        endIf
        if ShowMessage(seedPrompt, True, "$Yes", "$No")
            PDV_Manager.DebugSeedBroadLane()
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidApplyBretonPractice
        if EnsureManagerBinding("debug_breton_practice_target")
            if ShowMessage("Set the active Breton tradition directly to " + (_pendingBretonPractice as Int) + " practice points? This resets today's debug budget and bypasses pacing.", True, "$Yes", "$No")
                ShowMessage(PDV_Manager.DebugSetBretonPracticePoints(_pendingBretonPractice as Int), False, "$OK", "")
                ForcePageReset()
            endIf
        endIf
        return
    endIf

    if a_option == _oidAddBretonRenewable
        if EnsureManagerBinding("debug_breton_practice_renewable")
            ShowMessage(PDV_Manager.DebugAddBretonPracticePoints(1), False, "$OK", "")
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidAddBretonCurated
        if EnsureManagerBinding("debug_breton_practice_curated")
            ShowMessage(PDV_Manager.DebugAddBretonPracticePoints(2), False, "$OK", "")
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidShowBretonPractice
        if EnsureManagerBinding("debug_breton_practice_summary")
            ShowMessage(PDV_Manager.DebugGetBretonPracticeSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidResetBretonPractice
        if EnsureManagerBinding("debug_breton_practice_reset")
            if ShowMessage("Reset the active Breton tradition to zero practice points and clear today's debug budget?", True, "$Yes", "$No")
                ShowMessage(PDV_Manager.DebugResetBretonPracticePoints(), False, "$OK", "")
                ForcePageReset()
            endIf
        endIf
        return
    endIf

    if a_option == _oidShowStatResidue
        if EnsureManagerBinding("authoria_stat_residue")
            ShowMessage(PDV_Manager.GetAuthoriaResidueSummary(), False, "$OK", "")
        else
            ShowMessage("Devotion is still starting up. Try again in a moment.", False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidRepairStats
        if ShowMessage("Repair Devotion's permanent stat damage? SAVE FIRST. Older Devotion builds applied their penalties and boons as PERMANENT actor-value changes that were never reverted, so a long save drifts thousands of points away from truth. This removes every Devotion ability, zeroes the permanent modifier on the actor values Devotion can touch, then re-grants your abilities normally. It ALSO clears any permanent modifier another mod placed on those same values - rare, but real. Continue?", True, "$Yes", "$No")
            if EnsureManagerBinding("authoria_stat_repair")
                PDV_Manager.RunAuthoriaActorValueRepair(True, True)
                ShowMessage(PDV_Manager.GetAuthoriaResidueSummary(), False, "$OK", "")
                ForcePageReset()
            else
                ShowMessage("Devotion is still starting up. Try again in a moment.", False, "$OK", "")
            endIf
        endIf
        return
    endIf

    if a_option == _oidPrepareUninstall
        if ShowMessage("Prepare Devotion for uninstall? SAVE FIRST. This strips Devotion spells, removes its factions, clears most of its saved data, and STOPS the mod. It is best-effort, NOT a guaranteed clean save. The only fully clean removal is a save made before Devotion was installed. Continue?", True, "$Yes", "$No")
            if EnsureManagerBinding("prepare_uninstall")
                PDV_Manager.PrepareForUninstall()
            else
                ShowMessage("Devotion is still starting up. Try again in a moment.", False, "$OK", "")
            endIf
        endIf
        return
    endIf

    if a_option == _oidRunDawn
        if ShowMessage("Run ProcessDawn now?", True, "$Yes", "$No")
            PDV_Manager.ProcessDawn()
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidShowPietyMap
        ShowMessage(PDV_Manager.DebugGetPietyMapString(), False, "$OK", "")
        return
    endIf

    if a_option == _oidShowStructuralMap
        ShowMessage(BuildStructuralMapString(), False, "$OK", "")
        return
    endIf

    if a_option == _oidRunScaffoldApiSmoke
        if ShowMessage("Run the structural scaffold API smoke now?", True, "$Yes", "$No")
            ShowMessage(RunScaffoldApiSmoke(), False, "$OK", "")
            ForcePageReset()
        endIf
        return
    endIf

    if a_option == _oidReloadQuestMatrix
        if PDV_Manager
            ShowMessage(PDV_Manager.DebugReloadQuestMatrix(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidSignalFloorScenario
        CycleSignalFloorScenario()
        ForcePageReset()
        return
    endIf

    if a_option == _oidSignalFloorRun
        RunSignalFloorSmokeScenario()
        return
    endIf

    if a_option == _oidQuestReactionQueueStatus
        ForcePageReset()
        return
    endIf

    if a_option == _oidQuestReactionPerformanceSweep
        RunQuestReactionPerformanceSweep()
        return
    endIf

    if a_option == _oidDiegeticD1
        if PDV_Manager
            PDV_Manager.DebugSetDiegeticD1Enabled(!PDV_Manager.DebugGetDiegeticD1Enabled())
        endIf
        ForcePageReset()
        return
    endIf

    if a_option == _oidShowPatternSummary
        ShowPatternSummaryPaged()
        return
    endIf

    if a_option == _oidConcordatDefiance
        RunPatternAction("Route one Concordat defiance event?", 1)
        return
    endIf

    if a_option == _oidConcordatCompliance
        RunPatternAction("Route one Concordat compliance event?", 2)
        return
    endIf

    if a_option == _oidTalosShrineDefiance
        RunPatternAction("Route one Talos shrine defiance signal?", 18)
        return
    endIf

    if a_option == _oidTalosBetrayalCompliance
        RunPatternAction("Apply medium Talos betrayal creed loss?", 58)
        return
    endIf

    if a_option == _oidTalosBetrayalMajor
        RunPatternAction("Apply major Talos betrayal creed loss?", 59)
        return
    endIf

    if a_option == _oidConcordatUnlockGate
        RunPatternAction("Unlock the Concordat extreme walk-back gate?", 3)
        return
    endIf

    if a_option == _oidBosmerOldContract
        RunPatternAction("Set BosmerPath to OldContract?", 4)
        return
    endIf

    if a_option == _oidBosmerBanditRoad
        RunPatternAction("Set BosmerPath to BanditRoad?", 5)
        return
    endIf

    if a_option == _oidBosmerLivingStory
        RunPatternAction("Set BosmerPath to LivingStory?", 54)
        return
    endIf

    if a_option == _oidBosmerExchange
        RunPatternAction("Set BosmerPath to Exchange?", 55)
        return
    endIf

    if a_option == _oidBosmerSeedVariety
        RunPatternAction("Seed Bosmer variety cooldowns + 3 discoveries?", 56)
        return
    endIf

    if a_option == _oidBosmerGreenPactViolation
        RunPatternAction("Trigger one Green Pact violation?", 6)
        return
    endIf

    if a_option == _oidBosmerLivingStorySignal
        RunPatternAction("Record one Living Story signal?", 19)
        return
    endIf

    if a_option == _oidBosmerExchangeSignal
        RunPatternAction("Record one Exchange signal?", 20)
        return
    endIf

    if a_option == _oidBosmerBanditRoadSignal
        RunPatternAction("Record one Bandit Road signal?", 21)
        return
    endIf

    if a_option == _oidBosmerPactPositiveSignal
        RunPatternAction("Record one Pact-positive Bosmer signal?", 22)
        return
    endIf

    if a_option == _oidBosmerConfirmRite
        RunPatternAction("Run the confirmation rite now?", 23)
        return
    endIf

    if a_option == _oidDunmerPrayer
        RunPatternAction("Record one Dunmer ancestor prayer?", 7)
        return
    endIf

    if a_option == _oidDunmerHomeBonus
        RunPatternAction("Record one Dunmer home bonus?", 8)
        return
    endIf

    if a_option == _oidKhajiitMoonObservance
        RunPatternAction("Record one Khajiit moon observance?", 9)
        return
    endIf

    if a_option == _oidKhajiitRoadHome
        RunPatternAction("Record one Khajiit road-home cadence event?", 10)
        return
    endIf

    if a_option == _oidKhajiitPostureCycle
        RunPatternAction("Cycle the Khajiit lunar posture (Normal/Strained/Corrupted/ShadowDrift)?", 57)
        return
    endIf

    if a_option == _oidKhajiitLunarSeedT2
        if EnsureManagerBinding("debug_khajiit_lunar_seed")
            if ShowMessage("Seed the Khajiit lunar substrate directly to metric 25 (tier 2)? Boundary proof only; bypasses the daily metric budget.", True, "$Yes", "$No")
                ShowMessage(PDV_Manager.DebugSetKhajiitLunarMetric(25.0), False, "$OK", "")
            endIf
        endIf
        return
    endIf

    if a_option == _oidKhajiitLunarSeedT3
        if EnsureManagerBinding("debug_khajiit_lunar_seed")
            if ShowMessage("Seed the Khajiit lunar substrate directly to metric 75 (tier 3)? Boundary proof only; bypasses the daily metric budget.", True, "$Yes", "$No")
                ShowMessage(PDV_Manager.DebugSetKhajiitLunarMetric(75.0), False, "$OK", "")
            endIf
        endIf
        return
    endIf

    if a_option == _oidKhajiitLunarReset
        if EnsureManagerBinding("debug_khajiit_lunar_reset")
            if ShowMessage("Reset the Khajiit lunar substrate to zero and clear today's metric budget?", True, "$Yes", "$No")
                ShowMessage(PDV_Manager.DebugResetKhajiitLunarSubstrate(), False, "$OK", "")
            endIf
        endIf
        return
    endIf

    if a_option == _oidKhajiitLunarBudgetShow
        if EnsureManagerBinding("debug_khajiit_lunar_budget")
            ShowMessage(PDV_Manager.DebugGetKhajiitLunarBudgetSummary(), False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidKhajiitCaravanAid
        RunPatternAction("Fire one Khenarthi caravan-aid signal?", 60)
        return
    endIf

    if a_option == _oidKhajiitLegendMade
        RunPatternAction("Fire one Rajhin legend-made signal?", 61)
        return
    endIf

    if a_option == _oidMephalaWebWoven
        RunPatternAction("Fire one Mephala web-woven signal?", 62)
        return
    endIf

    if a_option == _oidBoethiahHonorableDuel
        RunPatternAction("Fire one Boethiah honorable-duel signal?", 63)
        return
    endIf

    if a_option == _oidDebugSetBroadWorship
        RunPatternAction("Set Broad worship for Nord broad-lane proof?", 11)
        return
    endIf

    if a_option == _oidNordOldWays
        RunPatternAction("Set the Nord pantheon baseline to OldWays?", 24)
        return
    endIf

    if a_option == _oidNordNineDivines
        RunPatternAction("Set the Nord pantheon baseline to NineDivines?", 25)
        return
    endIf

    if a_option == _oidKhajiitFocusBaanDar
        RunPatternAction("Force the Khajiit emergent focus to Baan Dar?", 43)
        return
    endIf

    if a_option == _oidKhajiitFocusRajhin
        RunPatternAction("Force the Khajiit emergent focus to Rajhin?", 44)
        return
    endIf

    if a_option == _oidKhajiitFocusAlkosh
        RunPatternAction("Force the Khajiit emergent focus to Alkosh?", 45)
        return
    endIf

    if a_option == _oidBretonKnightsRoad
        RunPatternAction("Set the Breton tradition to Knight's Road?", 46)
        return
    endIf

    if a_option == _oidBretonHiddenArt
        RunPatternAction("Set the Breton tradition to Hidden Art?", 47)
        return
    endIf

    if a_option == _oidBretonGreenWay
        RunPatternAction("Set the Breton tradition to Green Way?", 48)
        return
    endIf

    if a_option == _oidOrcCity
        RunPatternAction("Set the Orc life mode to City?", 49)
        return
    endIf

    if a_option == _oidOrcStronghold
        RunPatternAction("Set the Orc life mode to Stronghold?", 50)
        return
    endIf

    if a_option == _oidOrcLegionExile
        RunPatternAction("Set the Orc life mode to Legion-Exile?", 51)
        return
    endIf

    if a_option == _oidArgonianPeople
        RunPatternAction("Force the Argonian focus to People (seeds relations)?", 52)
        return
    endIf

    if a_option == _oidArgonianVoid
        RunPatternAction("Force the Argonian focus to Void (seeds relations + Sithis signals)?", 53)
        return
    endIf

    if a_option == _oidFavorLaneCycle
        RunPatternAction("Cycle the selected contextual-favor lane?", 26)
        return
    endIf

    if a_option == _oidFavorFamilyCycle
        RunPatternAction("Cycle the selected contextual-favor family?", 27)
        return
    endIf

    if a_option == _oidFavorTrigger
        RunPatternAction("Attempt to trigger the selected contextual favor?", 28)
        return
    endIf

    if a_option == _oidFavorExpire
        RunPatternAction("Clear the current active contextual favor?", 29)
        return
    endIf

    if a_option == _oidEvaluateCommitmentOffer
        RunPatternAction("Evaluate the Kyne commitment offer now?", 12)
        return
    endIf

    if a_option == _oidCommitmentSeedSignals
        RunPatternAction("Seed a two-day commitment signal window on the selected deity?", 34)
        return
    endIf

    if a_option == _oidCommitmentReset
        RunPatternAction("Reset the selected deity's commitment state?", 35)
        return
    endIf

    if a_option == _oidAcceptCommitmentOffer
        RunPatternAction("Accept the pending commitment offer?", 13)
        return
    endIf

    if a_option == _oidDeclineCommitmentOffer
        RunPatternAction("Decline the pending commitment offer?", 14)
        return
    endIf

    if a_option == _oidRefuseCommitmentOffer
        RunPatternAction("Refuse the pending commitment offer?", 15)
        return
    endIf

    if a_option == _oidHircineReset
        RunPatternAction("Reset the Hircine proving state to a clean baseline?", 30)
        return
    endIf

    if a_option == _oidHircineHuntRite
        RunPatternAction("Record one Hircine hunt rite?", 16)
        return
    endIf

    if a_option == _oidHircineRenounce
        RunPatternAction("Renounce the Hircine path?", 17)
        return
    endIf

    if a_option == _oidDaedricSelectedPath
        CycleSelectedDaedricPath()
        ForcePageReset()
        return
    endIf

    if a_option == _oidDaedricShowSummary
        DebugShowSelectedDaedricSummary()
        return
    endIf

    if a_option == _oidDaedricReset
        DebugResetSelectedDaedricPath()
        return
    endIf

    if a_option == _oidDaedricSignal
        DebugAddSelectedDaedricSignal()
        return
    endIf

    if a_option == _oidDaedricSeeker
        DebugForceSelectedDaedricTier(1)
        return
    endIf

    if a_option == _oidDaedricDevoted
        DebugForceSelectedDaedricTier(2)
        return
    endIf

    if a_option == _oidDaedricChampion
        DebugForceSelectedDaedricTier(3)
        return
    endIf

    if a_option == _oidDaedricLapse
        DebugForceSelectedDaedricTier(0)
        return
    endIf

    if a_option == _oidDaedricStigma
        DebugAddSelectedDaedricStigma()
        return
    endIf

    if a_option == _oidDaedricLiveRoute
        DebugRouteSelectedDaedricLiveSender()
        return
    endIf

    if a_option == _oidDaedricRouteAll
        DebugRouteAllDaedricLiveSenders()
        return
    endIf

    if a_option == _oidDaedricGenericProbe
        DebugRouteDaedricGenericProbe()
        return
    endIf

    if a_option == _oidCurseRefreshFromPlayer
        RunPatternAction("Refresh curse detection from the live player state?", 36)
        return
    endIf

    if a_option == _oidCurseProofRaceCycle
        CycleCurseProofOrigin()
        ForcePageReset()
        return
    endIf

    if a_option == _oidCurseProofRaceApply
        if PDV_CurseStateService && PDV_CurseStateService.GetCurseState() != 0
            ShowMessage("Force Curse none before changing the proof race. This prevents the new race from receiving a false cure transition.", False, "$OK", "")
            return
        endIf
        RunPatternAction("Temporarily rewrite the stored PDV origin to " + GetCurseProofOriginLabel() + " for curse race-handler proof? Use a throwaway save.", 37)
        return
    endIf

    if a_option == _oidForceCurseNone
        RunPatternAction("Force the curse state to None?", 31)
        return
    endIf

    if a_option == _oidForceCurseWerewolf
        RunPatternAction("Force the curse state to Werewolf?", 32)
        return
    endIf

    if a_option == _oidForceCurseVampire
        RunPatternAction("Force the curse state to Vampire?", 33)
        return
    endIf

    if a_option == _oidForceSelectedPatron
        PDV__ManagerQuest forcePatronManager = GetManagerService()
        PDV_DeityBase forcePatronDeity = GetSelectedDeity()
        if forcePatronManager && forcePatronDeity
            forcePatronManager.SetActiveDeity(forcePatronDeity, True)
            Debug.Notification("PDV: active patron forced.")
            ForcePageReset()
        else
            Debug.Notification("PDV: select a deity first.")
        endIf
        return
    endIf

    if a_option == _oidPrimeNeglectEligible
        PDV__ManagerQuest primeNeglectManager = GetManagerService()
        PDV_DeityBase primeNeglectDeity = GetSelectedDeity()
        if primeNeglectManager && primeNeglectDeity
            ; Deterministic active-patron neglect setup, modal-free: make the selected deity the
            ; active patron, then drop its piety to 0 so ApplyGenericNeglectFlags selects it (piety
            ; <= NEGLECT_ACTIVE_PIETY_MAX). Sidesteps Prime-decay-eligible, which sets piety 20 and
            ; a lapse stamp of exactly the grace boundary -- neither flags neglect.
            primeNeglectManager.SetActiveDeity(primeNeglectDeity, True)
            primeNeglectManager.DebugForceSetPietyByIndex(primeNeglectDeity.DeityIndex, 0.0)
            Debug.Notification("PDV: neglect eligible primed (active + piety 0).")
            ForcePageReset()
        else
            Debug.Notification("PDV: select a deity first.")
        endIf
        return
    endIf

    if a_option == _oidNeglectRunPass
        PDV__ManagerQuest neglectManager = GetManagerService()
        if neglectManager
            neglectManager.DebugRunNeglectPass()
            Debug.Notification("PDV: neglect pass run.")
        else
            Debug.Notification("PDV: manager is not assigned.")
        endIf
        return
    endIf

    if a_option == _oidPrimeRaceLaneNeglect
        PDV__ManagerQuest raceLaneNeglectManager = GetManagerService()
        if raceLaneNeglectManager
            raceLaneNeglectManager.DebugPrimeRaceLaneNeglect()
            ForcePageReset()
        else
            Debug.Notification("PDV: manager is not assigned.")
        endIf
        return
    endIf

    if a_option == _oidDecayPrimeGrace
        PDV__ManagerQuest decayGraceManager = GetManagerService()
        PDV_DeityBase decayGraceDeity = GetSelectedDeity()
        if decayGraceManager && decayGraceDeity
            decayGraceManager.DebugPrimeDecayGraceByIndex(decayGraceDeity.DeityIndex)
            Debug.Notification("PDV: decay grace primed.")
        else
            Debug.Notification("PDV: select a deity first.")
        endIf
        return
    endIf

    if a_option == _oidDecayPrimeEligible
        PDV__ManagerQuest decayEligibleManager = GetManagerService()
        PDV_DeityBase decayEligibleDeity = GetSelectedDeity()
        if decayEligibleManager && decayEligibleDeity
            decayEligibleManager.DebugPrimeDecayEligibleByIndex(decayEligibleDeity.DeityIndex)
            Debug.Notification("PDV: decay eligible primed.")
        else
            Debug.Notification("PDV: select a deity first.")
        endIf
        return
    endIf

    if a_option == _oidDecayRunPass
        PDV__ManagerQuest decayRunManager = GetManagerService()
        if decayRunManager
            decayRunManager.DebugRunDecayPass()
            Debug.Notification("PDV: decay pass run.")
        else
            Debug.Notification("PDV: manager is not assigned.")
        endIf
        return
    endIf

    if a_option == _oidDecayRunProofDays
        PDV__ManagerQuest decayProofManager = GetManagerService()
        PDV_DeityBase decayProofDeity = GetSelectedDeity()
        if decayProofManager && decayProofDeity
            decayProofManager.DebugRunDecayProofDaysByIndex(decayProofDeity.DeityIndex)
            Debug.Notification("PDV: decay proof days run.")
        else
            Debug.Notification("PDV: select a deity first.")
        endIf
        return
    endIf

    if a_option == _oidShowDecaySummary
        ShowSelectedDecaySummary()
    endIf
EndFunction

Function OnOptionKeyMapChange(Int a_option, Int a_keyCode, String a_conflictControl, String a_conflictName)
    if a_option == _oidJournalHotkey
        Int oldKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
        if oldKey >= 0
            UnregisterForKey(oldKey)
        endIf
        Int panelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
        if a_keyCode >= 0 && panelKey == a_keyCode
            StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", -1)
            UnregisterForKey(panelKey)
            if _oidPanelHotkey >= 0
                SetKeyMapOptionValue(_oidPanelHotkey, -1, False)
            endIf
        endIf
        StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Hotkey", a_keyCode)
        if a_keyCode >= 0
            RegisterForKey(a_keyCode)
        endIf
        SetKeyMapOptionValue(_oidJournalHotkey, a_keyCode, False)
    elseIf a_option == _oidPanelHotkey
        Int oldPanelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
        if oldPanelKey >= 0
            UnregisterForKey(oldPanelKey)
        endIf
        Int journalKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
        if a_keyCode >= 0 && journalKey == a_keyCode
            StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
            UnregisterForKey(journalKey)
            if _oidJournalHotkey >= 0
                SetKeyMapOptionValue(_oidJournalHotkey, -1, False)
            endIf
        endIf
        StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", a_keyCode)
        if a_keyCode >= 0
            RegisterForKey(a_keyCode)
        endIf
        SetKeyMapOptionValue(_oidPanelHotkey, a_keyCode, False)
    endIf
EndFunction

Event OnKeyDown(Int a_keyCode)
    Int journalKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    if journalKey >= 0 && a_keyCode == journalKey
        if !EnsureManagerBinding("journal_hotkey")
            return
        endIf
        ; Book of Days owns its hotkey absolutely. If a user accidentally maps the
        ; full panel to the same key, the journal path wins and returns here.
        Int journalState = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Open")
        Bool journalVisible = PDV_PrismaBridge.IsJournalVisible()
        if journalVisible
            StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
            Debug.Notification("The Book of Days closes.")
            PDV_Manager.ClosePrismaJournal()
            return
        endIf

        if journalState != 0
            StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
        endIf

        if Utility.IsInMenuMode()
            return
        endIf

        StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 1)
        Debug.Notification("The Book of Days opens.")
        PDV_Manager.SendPrismaJournalPayload(True)
        return
    endIf

    Int panelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    if panelKey >= 0 && a_keyCode == panelKey
        ; Close first so the rebindable panel key can release the focused panel if
        ; SkyUI delivers the key while the view has put the game in menu mode.
        if PDV_PrismaBridge.IsPanelVisible()
            PDV_PrismaBridge.CloseDevotionPanel()
            return
        endIf

        ; Open the focused interactive dashboard panel only from gameplay. Close is
        ; handled by the in-view X, ESC in the native bridge, or the same MCM key above.
        if Utility.IsInMenuMode()
            return
        endIf
        if !EnsureManagerBinding("panel_hotkey")
            return
        endIf
        Debug.Notification("The Devotion panel opens.")
        ; Player-owned UI entry point: push fresh panel data, then focus the view so the
        ; dashboard filter buttons are clickable.
        PDV_Manager.PushDevotionPanel(True)
        PDV_PrismaBridge.OpenDevotionPanel()
        return
    endIf
EndEvent

Function OpenBookOfDaysFromMcm()
    if !EnsureManagerBinding("journal_mcm_open")
        return
    endIf
    StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 1)
    Debug.Notification("The Book of Days opens.")
    PDV_Manager.SendPrismaJournalPayload(True)
EndFunction

Function OnOptionSliderOpen(Int a_option)
    if a_option == _oidDebugLevel
        SetSliderDialogStartValue(GetDebugLevelValue())
        SetSliderDialogDefaultValue(GetDebugLevelValue())
        SetSliderDialogRange(DEBUG_LEVEL_MIN as Float, DEBUG_LEVEL_MAX as Float)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidPendingPiety
        SetSliderDialogStartValue(_pendingPiety)
        SetSliderDialogDefaultValue(GetSelectedDeityPiety())
        SetSliderDialogRange(PIETY_MIN, PIETY_MAX)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidPendingPietyToday
        SetSliderDialogStartValue(_pendingPietyToday)
        SetSliderDialogDefaultValue(GetSelectedDeityPietyToday())
        SetSliderDialogRange(PIETY_TODAY_MIN, PIETY_TODAY_MAX)
        SetSliderDialogInterval(0.25)
        return
    endIf

    if a_option == _oidPendingBretonPractice
        SetSliderDialogStartValue(_pendingBretonPractice)
        SetSliderDialogDefaultValue(24.0)
        SetSliderDialogRange(0.0, 50.0)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidPendingSignalType
        SetSliderDialogStartValue(_pendingSignalType as Float)
        SetSliderDialogDefaultValue(_pendingSignalType as Float)
        SetSliderDialogRange(SIGNAL_TYPE_MIN, SIGNAL_TYPE_MAX)
        SetSliderDialogInterval(1.0)
        return
    endIf

    if a_option == _oidDisfavorEventId
        SetSliderDialogStartValue(_pendingDisfavorEventId as Float)
        SetSliderDialogDefaultValue(_pendingDisfavorEventId as Float)
        SetSliderDialogRange(SIGNAL_TYPE_MIN, SIGNAL_TYPE_MAX)
        SetSliderDialogInterval(1.0)
    endIf
EndFunction

Function OnOptionSliderAccept(Int a_option, Float a_value)
    if a_option == _oidDebugLevel
        PDV__ManagerQuest manager = GetManagerService()
        if manager
            manager.SetDebugLevel(a_value as Int)
        endIf
        SetSliderOptionValue(_oidDebugLevel, GetDebugLevelValue(), "{0}", False)
        return
    endIf

    if a_option == _oidPendingPiety
        _pendingPiety = ClampFloat(a_value, PIETY_MIN, PIETY_MAX)
        SetSliderOptionValue(_oidPendingPiety, _pendingPiety, "{0}", False)
        return
    endIf

    if a_option == _oidPendingPietyToday
        _pendingPietyToday = ClampFloat(a_value, PIETY_TODAY_MIN, PIETY_TODAY_MAX)
        SetSliderOptionValue(_oidPendingPietyToday, _pendingPietyToday, "{1}", False)
        return
    endIf

    if a_option == _oidPendingBretonPractice
        _pendingBretonPractice = ClampFloat(a_value, 0.0, 50.0)
        SetSliderOptionValue(_oidPendingBretonPractice, _pendingBretonPractice, "{0}", False)
        return
    endIf

    if a_option == _oidPendingSignalType
        _pendingSignalType = ClampSignalType(a_value as Int)
        SetSliderOptionValue(_oidPendingSignalType, _pendingSignalType as Float, "{0}", False)
        return
    endIf

    if a_option == _oidDisfavorEventId
        _pendingDisfavorEventId = ClampSignalType(a_value as Int)
        SetSliderOptionValue(_oidDisfavorEventId, _pendingDisfavorEventId as Float, "{0}", False)
        ForcePageReset()
    endIf
EndFunction

Function BuildPlayerPage()
    ResetBookOfDaysOptionIds()
    EnsureManagerBinding("build_player_page")
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Devotion", OPTION_FLAG_NONE)

    if EnsureManagerBinding("player_page")
        AddTextOption("Summary", GetPlayerPageSummaryLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Startup", GetPlayerPageStartupLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Path", GetExperienceModeLabel(), OPTION_FLAG_DISABLED)
        AddTextOption("Mode", PDV_Manager.GetPlayerMcmModeLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Patron", PDV_Manager.GetPlayerMcmPatronLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Standing", PDV_Manager.GetPlayerMcmStandingLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Curse", PDV_Manager.GetPlayerMcmCurseLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Favor", PDV_Manager.GetPlayerMcmFavorLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Neglect", PDV_Manager.GetPlayerMcmNeglectLine(), OPTION_FLAG_DISABLED)
        _oidSurveyDevotion = AddTextOption("Survey Devotion", "Open readout", OPTION_FLAG_NONE)
        _oidExportReport = AddTextOption("Export Devotion Report", "Write file", OPTION_FLAG_NONE)

        ; Surface each moon-path's standing and the current god in strength for
        ; players who want a detailed readout beyond the emergence ceremony.
        if PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_KHAJIIT
            AddHeaderOption("Moon-paths", OPTION_FLAG_NONE)
            Int khajiitFocus = 1
            while khajiitFocus <= 5
                AddTextOption(PDV_Manager.GetKhajiitFocusLabel(khajiitFocus), PDV_Manager.GetKhajiitFocusStandingLine(khajiitFocus), OPTION_FLAG_DISABLED)
                khajiitFocus += 1
            endWhile
        endIf
    else
        AddTextOption("Summary", "Devotion is still starting up.", OPTION_FLAG_DISABLED)
    endIf

    SetCursorPosition(1)
    AddHeaderOption("Book of Days", OPTION_FLAG_NONE)
    _oidOpenJournalNow = AddTextOption("Open Book of Days", "Open now", OPTION_FLAG_NONE)
    Int currentJournalKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    _oidJournalHotkey = AddKeyMapOption("Book of Days key", currentJournalKey, OPTION_FLAG_NONE)
    Int currentPanelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    _oidPanelHotkey = AddKeyMapOption("Open Devotion panel", currentPanelKey, OPTION_FLAG_NONE)

    AddHeaderOption("Maintenance", OPTION_FLAG_NONE)
    AddTextOption("Version", GetBuildVersionLabel(), OPTION_FLAG_DISABLED)
    _oidShowStatResidue = AddTextOption("Check stat damage", "Read now", OPTION_FLAG_NONE)
    _oidRepairStats = AddTextOption("Repair stats", "Save first", OPTION_FLAG_NONE)
    _oidPrepareUninstall = AddTextOption("Prepare for uninstall", "Save first", OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

String Function GetBuildVersionLabel()
    if PDV_Manager
        return PDV_Manager.GetBuildVersion()
    endIf
    return "Unknown"
EndFunction

String Function GetPlayerPageSummaryLine()
    if !PDV_Manager
        return "Unavailable"
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Startup pending"
    endIf

    return PDV_Manager.GetPlayerMcmPatronLine() + " | " + PDV_Manager.GetPlayerMcmStandingLine()
EndFunction

String Function GetPlayerPageStartupLine()
    if !PDV_Manager
        return "Unavailable"
    endIf

    if StorageUtil.GetIntValue(None, "PDV.Startup.UnifiedChoiceComplete") != 1
        return "Choose path"
    endIf

    return "Complete"
EndFunction

Function ResetBookOfDaysOptionIds()
    _oidOpenJournalNow = -1
    _oidJournalHotkey = -1
EndFunction

Function BuildDeveloperLockedPage(String pageName)
    EnsureManagerBinding("build_locked_page_" + pageName)
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption(pageName, OPTION_FLAG_NONE)
    AddTextOption("Developer Options", "Locked", OPTION_FLAG_DISABLED)
    AddTextOption("Access", "Enable Developer Options on the Player page to view this page.", OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Player", OPTION_FLAG_NONE)
    if PDV_Manager
        AddTextOption("Summary", GetPlayerPageSummaryLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Startup", GetPlayerPageStartupLine(), OPTION_FLAG_DISABLED)
        _oidSurveyDevotion = AddTextOption("Survey Devotion", "Open readout", OPTION_FLAG_NONE)
    else
        AddTextOption("Summary", "Devotion is still starting up.", OPTION_FLAG_DISABLED)
    endIf

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function BuildCompatPage()
    EnsureManagerBinding("build_compat_page")
    Bool devMode = DeveloperOptionsEnabled()
    ; Reset the mapping toggle OID so a stale value can't collide with another
    ; control's OID on the shipped page, where the toggle is not rendered.
    _oidCompatRaceMapping = -1

    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Devotional Path", OPTION_FLAG_NONE)
    if PDV_ModePresetRef
        _oidModeToggle = AddTextOption("Current path", PDV_ModePresetRef.GetModeLabel(), OPTION_FLAG_NONE)
    else
        _oidModeToggle = -1
        AddTextOption("Current path", "Unavailable", OPTION_FLAG_DISABLED)
    endIf

    AddHeaderOption("Presentation", OPTION_FLAG_NONE)
    if PDV_Manager
        _oidInGameEffects = AddTextOption("In-Game Effects", OnOffLabel(PDV_Manager.InGameEffectsEnabled()), OPTION_FLAG_NONE)
        _oidNotifications = AddTextOption("Notifications", OnOffLabel(PDV_Manager.NotificationsEnabled()), OPTION_FLAG_NONE)
        _oidToastSize = AddTextOption("Toast size", ToastSizeLabel(), OPTION_FLAG_NONE)
    else
        _oidInGameEffects = -1
        _oidNotifications = -1
        _oidToastSize = -1
        AddTextOption("In-Game Effects", "Unavailable", OPTION_FLAG_DISABLED)
        AddTextOption("Notifications", "Unavailable", OPTION_FLAG_DISABLED)
        AddTextOption("Toast size", "Unavailable", OPTION_FLAG_DISABLED)
    endIf

    AddHeaderOption("NPC Recognition", OPTION_FLAG_NONE)
    if PDV_Manager
        _oidNpcRecognition = AddTextOption("Religious recognition", OnOffLabel(PDV_Manager.NpcReligiousRecognitionEnabled()), OPTION_FLAG_NONE)
        _oidNpcHostileRecognition = AddTextOption("Hard-rival reactions", OnOffLabel(PDV_Manager.NpcHostileRecognitionEnabled()), OPTION_FLAG_NONE)
        AddTextOption("Current", PDV_Manager.GetNpcRecognitionStatusLine(), OPTION_FLAG_DISABLED)
    else
        AddTextOption("Religious recognition", "Unavailable", OPTION_FLAG_DISABLED)
        AddTextOption("Hard-rival reactions", "Unavailable", OPTION_FLAG_DISABLED)
    endIf

    AddHeaderOption("Custom Race", OPTION_FLAG_NONE)
    ; Custom race mapping stays ON by default and is not a shipped choice; the
    ; toggle only appears when Developer Options are unlocked. Players keep the
    ; Detected readout and Re-detect origin as recovery tools.
    if devMode
        _oidCompatRaceMapping = AddTextOption("Custom race mapping", OnOffLabel(CustomRaceMappingEnabled()), OPTION_FLAG_NONE)
    endIf
    AddTextOption("Detected", GetCompatRaceReadout(), OPTION_FLAG_DISABLED)
    _oidReDetectOrigin = AddTextOption("Re-detect origin", "Run now", OPTION_FLAG_NONE)
    AddTextOption("Temporary forms", "Defer origin capture", OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Survival Context", OPTION_FLAG_NONE)
    _oidCompatSurvival = AddTextOption("Survival integration", OnOffLabel(SurvivalContextEnabled()), OPTION_FLAG_NONE)
    if devMode
        AddTextOption("Status", GetCompatSurvivalReadout(), OPTION_FLAG_DISABLED)
    endIf
    AddHeaderOption("AE / Creation Club", OPTION_FLAG_NONE)
    if devMode
        AddTextOption("AE/CC content", "Encouraged optional", OPTION_FLAG_DISABLED)
    endIf
    _oidCompatCC = AddTextOption("CC integration", OnOffLabel(CCContentEnabled()), OPTION_FLAG_NONE)
    if devMode
        AddTextOption("Detected", GetCompatCCReadout(), OPTION_FLAG_DISABLED)
    endIf

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

String Function GetExperienceModeLabel()
    if PDV_ModePresetRef
        return PDV_ModePresetRef.GetModeLabel()
    endIf
    return "Pilgrim's Path"
EndFunction

Function ToggleExperienceMode()
    if !PDV_ModePresetRef
        ShowMessage("Experience Mode is not wired yet.", False, "$OK", "")
        return
    endIf

    Int current = PDV_ModePresetRef.GetMode()
    Int nextMode = 1
    String label = "Wayfarer's Path"
    if current == 1
        nextMode = 0
        label = "Pilgrim's Path"
    endIf

    if ShowMessage("Walk the " + label + "?", True, "$Yes", "$No")
        PDV_ModePresetRef.SetMode(nextMode)
        ForcePageReset()
    endIf
EndFunction

String Function OnOffLabel(Bool isOn)
    if isOn
        return "On"
    endIf
    return "Off"
EndFunction

String Function ToastSizeLabel()
    if PDV_Manager && PDV_Manager.PrismaToastLargeEnabled()
        return "Large"
    endIf
    return "Normal"
EndFunction

Bool Function CustomRaceMappingEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Compat.CustomRaceMapping", 1) != 0
EndFunction

Function ToggleCustomRaceMapping()
    if CustomRaceMappingEnabled()
        StorageUtil.SetIntValue(None, "PDV.Compat.CustomRaceMapping", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Compat.CustomRaceMapping", 1)
    endIf
EndFunction

Function ReDetectOrigin()
    if !ShowMessage("Re-detect your origin now?", True, "$Yes", "$No")
        return
    endIf

    StorageUtil.SetIntValue(None, "PDV.Origin.ForceRedetect", 1)
    PDV_Origin originService = GetOriginService()
    if originService
        originService.InitializeOrigin()
        Debug.Notification("Devotion origin: " + GetCompatRaceReadout())
    else
        TraceMcm(1, "Origin re-detect failed: PDV_Origin service unavailable.")
        Debug.Notification("Devotion origin re-detect could not start.")
    endIf

    ForcePageReset()
EndFunction

Bool Function SurvivalContextEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Compat.SurvivalContextEnabled", 1) != 0
EndFunction

Function ToggleSurvivalContext()
    if SurvivalContextEnabled()
        StorageUtil.SetIntValue(None, "PDV.Compat.SurvivalContextEnabled", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Compat.SurvivalContextEnabled", 1)
    endIf
EndFunction

Bool Function CCContentEnabled()
    return StorageUtil.GetIntValue(None, "PDV.Compat.CCContentEnabled", 1) != 0
EndFunction

Function ToggleCCContent()
    if CCContentEnabled()
        StorageUtil.SetIntValue(None, "PDV.Compat.CCContentEnabled", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.Compat.CCContentEnabled", 1)
    endIf
EndFunction

String Function GetCompatRaceReadout()
    if StorageUtil.GetIntValue(None, "PDV.CustomRaceResolved") == 1
        Int resolvedIndex = StorageUtil.GetIntValue(None, "PDV.CustomRaceResolvedIndex")
        if PDV_Manager
            return "Custom race -> " + PDV_Manager.GetOriginRaceLabel(resolvedIndex) + " (mapped)"
        endIf
        return "Custom race mapped"
    elseIf StorageUtil.GetIntValue(None, "PDV.CustomRaceFallback") == 1
        return "Custom race -> Imperial (fallback)"
    endIf

    return "Vanilla race (no mapping needed)"
EndFunction

String Function GetCompatSurvivalReadout()
    if PDV_Manager
        return PDV_Manager.GetSurvivalContextStatusLine()
    endIf

    return "Unknown"
EndFunction

String Function GetCompatCCReadout()
    if PDV_Manager
        return PDV_Manager.GetCCContentStatusLine()
    endIf

    return "Unknown"
EndFunction

Function BuildStatusPage()
    Int activeDeityIndex = GetActiveDeityIndexValue()
    Int deityCount = GetDeityCount()

    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Current state", OPTION_FLAG_NONE)
    AddTextOption("Active patron", GetActivePatronLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Patron state", GetPatronStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Active piety", FormatFloat(GetActivePietyValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active tier", TierToLabel(GetActiveTierValue()), OPTION_FLAG_DISABLED)
    AddTextOption("Active deity index", GetIndexLabel(activeDeityIndex), OPTION_FLAG_DISABLED)
    AddTextOption("Origin diagnostic", GetOriginDiagnosticLabel(), OPTION_FLAG_DISABLED)
    AddEmptyOption()
    AddHeaderOption("Phase 8 Concordat", OPTION_FLAG_NONE)
    AddTextOption("Raw value", GetConcordatRawLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Committed state", GetConcordatStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Pending state", GetConcordatPendingStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Extreme gate", GetConcordatGateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Talos gain x", GetTalosGainMultiplierLabel(), OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Deity roster", OPTION_FLAG_NONE)

    if deityCount <= 0
        AddTextOption("Roster", "No deity quests found.", OPTION_FLAG_DISABLED)
        SetCursorFillMode(LEFT_TO_RIGHT)
        return
    endIf

    Int i = 0
    while i < deityCount
        PDV_DeityBase deity = PDV_Manager.GetDeityAtListIndex(i)
        if deity
            String rowValue = TierToLabel(PDV_Manager.GetTier(deity)) + " | " + FormatFloat(PDV_Manager.GetPiety(deity)) + " (+" + FormatFloat(PDV_Manager.GetPietyToday(deity)) + ")"
            if deity.DeityIndex == activeDeityIndex
                rowValue = rowValue + " | active"
            endIf
            AddTextOption(deity.DeityName, rowValue, OPTION_FLAG_DISABLED)
        endIf
        i += 1
    endWhile

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

String Function DiegeticD1Label()
    if PDV_Manager && PDV_Manager.DebugGetDiegeticD1Enabled()
        return "On"
    endIf
    return "Off"
EndFunction

String Function GetBroadLaneSeedLabel()
    if PDV_Manager && PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_IMPERIAL
        return "Imperial pool 50"
    endIf
    if PDV_Manager && PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_BRETON
        return "Breton practice 50"
    endIf
    return "Origin lane T2"
EndFunction

Function BuildStatePage()
    SyncSelection()
    SetCursorFillMode(TOP_TO_BOTTOM)

    ; --- Left column: deity ledger control + values + actions ---
    SetCursorPosition(0)
    AddHeaderOption("Target deity", OPTION_FLAG_NONE)
    _oidSelectedDeity = AddTextOption("Selected deity", GetSelectedDeityLabel(), OPTION_FLAG_NONE)
    _oidDebugPatronOverride = AddTextOption("Debug patron override", "Set selected deity active", OPTION_FLAG_NONE)
    _oidDebugClearPatron = AddTextOption("Clear patron override", GetActivePatronLabel(), OPTION_FLAG_NONE)
    _oidDebugResetDeity = AddTextOption("Reset selected deity", "Zero ledger", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Debug values", OPTION_FLAG_NONE)
    _oidDebugLevel = AddSliderOption("Debug level", GetDebugLevelValue(), "{0}", OPTION_FLAG_NONE)
    _oidPendingPiety = AddSliderOption("Target piety", _pendingPiety, "{0}", OPTION_FLAG_NONE)
    _oidApplyPiety = AddTextOption("Apply target piety", FormatFloat(_pendingPiety), OPTION_FLAG_NONE)
    _oidSeedBroadLane = AddTextOption("Seed broad lane (origin)", GetBroadLaneSeedLabel(), OPTION_FLAG_NONE)
    _oidPendingPietyToday = AddSliderOption("Target scratch", _pendingPietyToday, "{1}", OPTION_FLAG_NONE)
    _oidApplyPietyToday = AddTextOption("Apply target scratch", FormatFloat(_pendingPietyToday), OPTION_FLAG_NONE)
    _oidPendingSignalType = AddSliderOption("Curated signal ID", _pendingSignalType as Float, "{0}", OPTION_FLAG_NONE)
    _oidApplyCuratedSignal = AddTextOption("Apply curated signal", GetSelectedSignalLabel(), OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Disfavor (dislikes)", OPTION_FLAG_NONE)
    _oidDisfavorEventId = AddSliderOption("Dislike event ID", _pendingDisfavorEventId as Float, "{0}", OPTION_FLAG_NONE)
    _oidFireDislike = AddTextOption("Fire dislike vs selected deity", GetFireDislikeLabel(), OPTION_FLAG_NONE)
    _oidDisfavorDomainCycle = AddTextOption("Cycle disfavor domain", GetDisfavorDomainCycleLabel(), OPTION_FLAG_NONE)
    _oidDisfavorBandToggle = AddTextOption("Cycle disfavor band", GetDisfavorBandCycleLabel(), OPTION_FLAG_NONE)
    _oidApplyDomainSting = AddTextOption("Apply domain sting", "Direct MGEF add", OPTION_FLAG_NONE)
    _oidDisfavorBurst = AddTextOption("Anti-stack burst (4 domains)", "Cap holds at 3", OPTION_FLAG_NONE)
    _oidDisfavorShow = AddTextOption("Show active disfavor", "Summary message", OPTION_FLAG_NONE)
    _oidDisfavorClear = AddTextOption("Clear active disfavor", "Remove all stings", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Actions", OPTION_FLAG_NONE)
    _oidRunDawn = AddTextOption("Run dawn pass", "Consolidate scratch", OPTION_FLAG_NONE)
    _oidShowPatternSummary = AddTextOption("Show pattern summary", "Paged readout", OPTION_FLAG_NONE)
    _oidShowPietyMap = AddTextOption("Show piety map", "Message", OPTION_FLAG_NONE)
    _oidShowStructuralMap = AddTextOption("Show structural map", "Message", OPTION_FLAG_NONE)
    _oidRunScaffoldApiSmoke = AddTextOption("Run scaffold smoke", "API set/read/reset", OPTION_FLAG_NONE)
    _oidReloadQuestMatrix = AddTextOption("Reload quest matrix", "Re-read JSON", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Signal-floor smoke", OPTION_FLAG_NONE)
    _oidSignalFloorScenario = AddTextOption("Selected smoke", GetSignalFloorScenarioLabel(), OPTION_FLAG_NONE)
    _oidSignalFloorRun = AddTextOption("Run signal-floor smoke", "Controlled route", OPTION_FLAG_NONE)
    _oidQuestReactionQueueStatus = AddTextOption("Quest reaction queue", GetQuestReactionQueueStatusLabel(), OPTION_FLAG_NONE)
    _oidQuestReactionPerformanceSweep = AddTextOption("Run performance sweep", "Disposable save", OPTION_FLAG_NONE)
    _oidDiegeticD1 = AddTextOption("Diegetic surfaces (D1)", DiegeticD1Label(), OPTION_FLAG_NONE)

    ; --- Right column: race focus/state setters + favor ---
    SetCursorPosition(1)
    AddHeaderOption("Race focus & state", OPTION_FLAG_NONE)
    _oidDebugSetBroadWorship = AddTextOption("Set Broad worship", "All races", OPTION_FLAG_NONE)
    _oidBosmerOldContract = AddTextOption("Bosmer -> OldContract", "Path", OPTION_FLAG_NONE)
    _oidBosmerBanditRoad = AddTextOption("Bosmer -> BanditRoad", "Path", OPTION_FLAG_NONE)
    _oidBosmerLivingStory = AddTextOption("Bosmer -> LivingStory", "Path", OPTION_FLAG_NONE)
    _oidBosmerExchange = AddTextOption("Bosmer -> Exchange", "Path", OPTION_FLAG_NONE)
    _oidBosmerSeedVariety = AddTextOption("Seed Bosmer variety", "Cooldowns + 3 discoveries", OPTION_FLAG_NONE)
    _oidNordOldWays = AddTextOption("Nord -> Old Ways", "Baseline", OPTION_FLAG_NONE)
    _oidNordNineDivines = AddTextOption("Nord -> Nine Divines", "Baseline", OPTION_FLAG_NONE)
    _oidKhajiitFocusBaanDar = AddTextOption("Khajiit focus -> Baan Dar", "Force focus", OPTION_FLAG_NONE)
    _oidKhajiitFocusRajhin = AddTextOption("Khajiit focus -> Rajhin", "Force focus", OPTION_FLAG_NONE)
    _oidKhajiitFocusAlkosh = AddTextOption("Khajiit focus -> Alkosh", "Force focus", OPTION_FLAG_NONE)
    _oidBretonKnightsRoad = AddTextOption("Breton -> Knight's Road", "Tradition", OPTION_FLAG_NONE)
    _oidBretonHiddenArt = AddTextOption("Breton -> Hidden Art", "Tradition", OPTION_FLAG_NONE)
    _oidBretonGreenWay = AddTextOption("Breton -> Green Way", "Tradition", OPTION_FLAG_NONE)
    Int bretonPracticeFlags = OPTION_FLAG_DISABLED
    if PDV_Manager && PDV_Manager.GetPlayerOriginRaceIndex() == PDV_Manager.ORIGIN_BRETON
        bretonPracticeFlags = OPTION_FLAG_NONE
    endIf
    AddHeaderOption("Breton practice", bretonPracticeFlags)
    _oidPendingBretonPractice = AddSliderOption("Practice target", _pendingBretonPractice, "{0}", bretonPracticeFlags)
    _oidApplyBretonPractice = AddTextOption("Apply practice target", "Direct boundary seed", bretonPracticeFlags)
    _oidAddBretonRenewable = AddTextOption("Add renewable practice", "+1 capped pulse", bretonPracticeFlags)
    _oidAddBretonCurated = AddTextOption("Add curated practice", "+2 capped pulse", bretonPracticeFlags)
    _oidShowBretonPractice = AddTextOption("Show Breton practice", "Points + daily budget", bretonPracticeFlags)
    _oidResetBretonPractice = AddTextOption("Reset Breton practice", "Points + debug budget", bretonPracticeFlags)
    _oidOrcCity = AddTextOption("Orc -> City", "Life mode", OPTION_FLAG_NONE)
    _oidOrcStronghold = AddTextOption("Orc -> Stronghold", "Life mode", OPTION_FLAG_NONE)
    _oidOrcLegionExile = AddTextOption("Orc -> Legion-Exile", "Life mode", OPTION_FLAG_NONE)
    _oidArgonianPeople = AddTextOption("Argonian focus -> People", "Force focus", OPTION_FLAG_NONE)
    _oidArgonianVoid = AddTextOption("Argonian focus -> Void", "Force focus", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Contextual favor", OPTION_FLAG_NONE)
    _oidFavorLaneCycle = AddTextOption("Cycle favor lane", GetFavorLaneOptionLabel(), OPTION_FLAG_NONE)
    _oidFavorFamilyCycle = AddTextOption("Cycle favor family", GetFavorFamilyOptionLabel(), OPTION_FLAG_NONE)
    _oidFavorTrigger = AddTextOption("Trigger selected favor", "Gate check", OPTION_FLAG_NONE)
    _oidFavorExpire = AddTextOption("Clear active favor", "Expire now", OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function BuildDaedricPage()
    SyncSelection()
    if _selectedCurseProofOrigin < 0 && PDV_Manager
        _selectedCurseProofOrigin = PDV_Manager.GetPlayerOriginRaceIndex()
    endIf
    SetCursorFillMode(TOP_TO_BOTTOM)

    ; --- Left column: Daedric display proof + Hircine + Curse ---
    SetCursorPosition(0)
    AddHeaderOption("Daedric display proof", OPTION_FLAG_NONE)
    _oidDaedricSelectedPath = AddTextOption("Selected Prince", GetSelectedDaedricPathLabel(), OPTION_FLAG_NONE)
    _oidDaedricShowSummary = AddTextOption("Show Prince summary", "Message", OPTION_FLAG_NONE)
    _oidDaedricReset = AddTextOption("Reset Prince path", "Clean baseline", OPTION_FLAG_NONE)
    _oidDaedricSignal = AddTextOption("Add Prince signal", "Commitment cue", OPTION_FLAG_NONE)
    _oidDaedricSeeker = AddTextOption("Force Seeker", "Boon/price T1", OPTION_FLAG_NONE)
    _oidDaedricDevoted = AddTextOption("Force Devoted", "Boon/price T2", OPTION_FLAG_NONE)
    _oidDaedricChampion = AddTextOption("Force Champion", "Boon/price T3", OPTION_FLAG_NONE)
    _oidDaedricLapse = AddTextOption("Force lapse", "Clear tiers", OPTION_FLAG_NONE)
    _oidDaedricStigma = AddTextOption("Add stigma", "Stigma cue", OPTION_FLAG_NONE)
    _oidDaedricLiveRoute = AddTextOption("Route live sender", "EventBus cue", OPTION_FLAG_NONE)
    _oidDaedricRouteAll = AddTextOption("Route all Princes", "All sender cues", OPTION_FLAG_NONE)
    _oidDaedricGenericProbe = AddTextOption("Generic silence probe", "No state change", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Hircine", OPTION_FLAG_NONE)
    _oidHircineReset = AddTextOption("Hircine reset", "Clean baseline", OPTION_FLAG_NONE)
    _oidHircineHuntRite = AddTextOption("Hircine hunt rite", "Boon/price/stigma", OPTION_FLAG_NONE)
    _oidHircineRenounce = AddTextOption("Hircine renounce", "Restore path", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Curse", OPTION_FLAG_NONE)
    _oidCurseRefreshFromPlayer = AddTextOption("Curse refresh", "Read player state", OPTION_FLAG_NONE)
    _oidCurseProofRaceCycle = AddTextOption("Curse proof race", GetCurseProofOriginLabel(), OPTION_FLAG_NONE)
    _oidCurseProofRaceApply = AddTextOption("Apply proof race", "Rewrite PDV origin", OPTION_FLAG_NONE)
    _oidForceCurseNone = AddTextOption("Curse none", "Human baseline", OPTION_FLAG_NONE)
    _oidForceCurseWerewolf = AddTextOption("Curse werewolf", "Backend force", OPTION_FLAG_NONE)
    _oidForceCurseVampire = AddTextOption("Curse vampire", "Backend force", OPTION_FLAG_NONE)

    ; --- Right column: race signals + neglect/decay + commitment ---
    SetCursorPosition(1)
    AddHeaderOption("Race signals", OPTION_FLAG_NONE)
    _oidConcordatDefiance = AddTextOption("Concordat defiance", "EventBus route", OPTION_FLAG_NONE)
    _oidConcordatCompliance = AddTextOption("Concordat compliance", "EventBus route", OPTION_FLAG_NONE)
    _oidTalosShrineDefiance = AddTextOption("Talos shrine defiance", "Shrine route", OPTION_FLAG_NONE)
    _oidTalosBetrayalCompliance = AddTextOption("Talos betrayal -2", "Creed loss", OPTION_FLAG_NONE)
    _oidTalosBetrayalMajor = AddTextOption("Talos betrayal -3", "Creed loss", OPTION_FLAG_NONE)
    _oidConcordatUnlockGate = AddTextOption("Unlock Concordat gate", "Extreme walk-back", OPTION_FLAG_NONE)
    _oidBosmerGreenPactViolation = AddTextOption("Green Pact violation", "OldContract only", OPTION_FLAG_NONE)
    _oidBosmerLivingStorySignal = AddTextOption("Bosmer Living Story", "Path evidence", OPTION_FLAG_NONE)
    _oidBosmerExchangeSignal = AddTextOption("Bosmer Exchange", "Path evidence", OPTION_FLAG_NONE)
    _oidBosmerBanditRoadSignal = AddTextOption("Bosmer Bandit Road", "Path evidence", OPTION_FLAG_NONE)
    _oidBosmerPactPositiveSignal = AddTextOption("Bosmer Pact-positive", "Path evidence", OPTION_FLAG_NONE)
    _oidBosmerConfirmRite = AddTextOption("Bosmer confirm rite", "Finalize pending", OPTION_FLAG_NONE)
    _oidDunmerPrayer = AddTextOption("Dunmer ancestor prayer", "Substrate pilot", OPTION_FLAG_NONE)
    _oidDunmerHomeBonus = AddTextOption("Dunmer home bonus", "Substrate pilot", OPTION_FLAG_NONE)
    _oidKhajiitMoonObservance = AddTextOption("Khajiit moon observance", "Emergent lane", OPTION_FLAG_NONE)
    _oidKhajiitRoadHome = AddTextOption("Khajiit road-home cadence", "Emergent lane", OPTION_FLAG_NONE)
    _oidKhajiitPostureCycle = AddTextOption("Khajiit lunar posture", "Cycle posture", OPTION_FLAG_NONE)
    _oidKhajiitLunarSeedT2 = AddTextOption("Seed lunar metric 25", "Tier 2 boundary", OPTION_FLAG_NONE)
    _oidKhajiitLunarSeedT3 = AddTextOption("Seed lunar metric 75", "Tier 3 boundary", OPTION_FLAG_NONE)
    _oidKhajiitLunarReset = AddTextOption("Reset lunar substrate", "Metric + budget", OPTION_FLAG_NONE)
    _oidKhajiitLunarBudgetShow = AddTextOption("Show lunar budget", "Metric + daily budget", OPTION_FLAG_NONE)
    _oidKhajiitCaravanAid = AddTextOption("Khajiit caravan aid", "Emergent lane", OPTION_FLAG_NONE)
    _oidKhajiitLegendMade = AddTextOption("Khajiit legend-made heist", "Emergent lane", OPTION_FLAG_NONE)
    _oidMephalaWebWoven = AddTextOption("Mephala web woven", "Milestone lane", OPTION_FLAG_NONE)
    _oidBoethiahHonorableDuel = AddTextOption("Boethiah honorable duel", "Brawl win", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Neglect & decay", OPTION_FLAG_NONE)
    _oidForceSelectedPatron = AddTextOption("Force selected patron", "Focused", OPTION_FLAG_NONE)
    _oidPrimeNeglectEligible = AddTextOption("Prime neglect eligible", "Active + piety 0", OPTION_FLAG_NONE)
    _oidNeglectRunPass = AddTextOption("Run neglect pass", "Targeted", OPTION_FLAG_NONE)
    _oidPrimeRaceLaneNeglect = AddTextOption("Prime race-lane neglect", "Backdate source", OPTION_FLAG_NONE)
    _oidDecayPrimeGrace = AddTextOption("Prime decay grace", "Proof", OPTION_FLAG_NONE)
    _oidDecayPrimeEligible = AddTextOption("Prime decay eligible", "Proof", OPTION_FLAG_NONE)
    _oidDecayRunPass = AddTextOption("Run decay pass", "Targeted", OPTION_FLAG_NONE)
    _oidDecayRunProofDays = AddTextOption("Run decay proof days", "Compressed", OPTION_FLAG_NONE)
    _oidShowDecaySummary = AddTextOption("Show decay summary", "Selected deity", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Commitment offers", OPTION_FLAG_NONE)
    _oidEvaluateCommitmentOffer = AddTextOption("Evaluate commitment", "Dawn-equivalent", OPTION_FLAG_NONE)
    _oidCommitmentSeedSignals = AddTextOption("Seed commitment signals", "2-day window", OPTION_FLAG_NONE)
    _oidCommitmentReset = AddTextOption("Reset commitment state", "Clear pending/cooldown", OPTION_FLAG_NONE)
    _oidAcceptCommitmentOffer = AddTextOption("Accept commitment", "Preserve piety", OPTION_FLAG_NONE)
    _oidDeclineCommitmentOffer = AddTextOption("Decline commitment", "Postpone", OPTION_FLAG_NONE)
    _oidRefuseCommitmentOffer = AddTextOption("Refuse commitment", "Cooldown", OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function BuildPacingPantheonsPage()
    SetCursorFillMode(TOP_TO_BOTTOM)

    SetCursorPosition(0)
    AddHeaderOption("Substrate pacing", OPTION_FLAG_NONE)
    _oidPacingSubstrateOrigin = AddTextOption("Race", GetSubstratePacingOriginLabel(), OPTION_FLAG_NONE)
    _oidPacingSubstrateOriginApply = AddTextOption("Apply test origin", "Throwaway save", OPTION_FLAG_NONE)
    _oidPacingSubstrateSource = AddTextOption("Source", GetSubstratePacingSourceLabel(), OPTION_FLAG_NONE)
    _oidPacingSubstrateStatus = AddTextOption("Status", "Open readout", OPTION_FLAG_NONE)
    _oidPacingSubstrateTrigger = AddTextOption("Trigger approved source", "True handler", OPTION_FLAG_NONE)
    _oidPacingSubstrateReset = AddTextOption("Reset substrate", "Metric + pacing state", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Substrate boundary seeds", OPTION_FLAG_NONE)
    _oidPacingSubstrateSeed0 = AddTextOption("Seed 0", "No boon", OPTION_FLAG_NONE)
    _oidPacingSubstrateSeed24 = AddTextOption("Seed 24", "Below mid", OPTION_FLAG_NONE)
    _oidPacingSubstrateSeed25 = AddTextOption("Seed 25", "Mid boundary", OPTION_FLAG_NONE)
    _oidPacingSubstrateSeed74 = AddTextOption("Seed 74", "Below high", OPTION_FLAG_NONE)
    _oidPacingSubstrateSeed75 = AddTextOption("Seed 75", "High boundary", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Devotional clock", OPTION_FLAG_NONE)
    AddTextOption("Day progression", "Use real wait and dawn", OPTION_FLAG_DISABLED)
    AddTextOption("Organic proof", "One real ingress per race", OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Broad pantheon pool", OPTION_FLAG_NONE)
    _oidPacingBroadPool = AddTextOption("Pool", GetBroadPantheonPoolLabel(), OPTION_FLAG_NONE)
    _oidPacingBroadStatus = AddTextOption("Status", "Open readout", OPTION_FLAG_NONE)
    _oidPacingBroadReset = AddTextOption("Reset pool", "Standing + scratch", OPTION_FLAG_NONE)
    _oidPacingBroadSeed24 = AddTextOption("Seed 24", "Below Seeker", OPTION_FLAG_NONE)
    _oidPacingBroadSeed25 = AddTextOption("Seed 25", "Seeker boundary", OPTION_FLAG_NONE)
    _oidPacingBroadSeed49 = AddTextOption("Seed 49", "Below Faithful", OPTION_FLAG_NONE)
    _oidPacingBroadSeed50 = AddTextOption("Seed 50", "Faithful boundary", OPTION_FLAG_NONE)
    _oidPacingBroadFanout = AddTextOption("Signed fan-out test", "Strongest delta only", OPTION_FLAG_NONE)
    _oidPacingBroadScratchPositive = AddTextOption("Prime +100 scratch", "Real dawn caps +4.3", OPTION_FLAG_NONE)
    _oidPacingBroadScratchNegative = AddTextOption("Prime -100 scratch", "Real dawn caps -4.3", OPTION_FLAG_NONE)
    _oidPacingBroadMigration = AddTextOption("Run migration fixture", "Destructive: throwaway save", OPTION_FLAG_NONE)
    _oidPacingBroadCatchup = AddTextOption("PS-A11 catch-up", "Suppressed pool: gain day +5", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Nord baseline", OPTION_FLAG_NONE)
    _oidPacingNordBaseline = AddTextOption("Selected baseline", GetNordBaselinePacingLabel(), OPTION_FLAG_NONE)
    _oidPacingNordBaselineApply = AddTextOption("Apply baseline", "Keep both pools", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Patron transition", OPTION_FLAG_NONE)
    _oidPacingPatronStatus = AddTextOption("Status", "Offer + lapse + recovery", OPTION_FLAG_NONE)
    _oidPacingSetBroad = AddTextOption("Return to broad worship", "Clean baseline state", OPTION_FLAG_NONE)
    _oidPacingPatronOffer = AddTextOption("Prepare patron offer", "Controlled setup", OPTION_FLAG_NONE)
    _oidPacingPatronAccept = AddTextOption("Accept patron", "Preserve deity piety", OPTION_FLAG_NONE)
    _oidPacingPatronLapse = AddTextOption("Lapse patron to 49", "Suspend focused boon", OPTION_FLAG_NONE)
    _oidPacingPatronRecover = AddTextOption("Recover patron to 50", "Restore focused T2", OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Imperial vampire state", OPTION_FLAG_NONE)
    _oidPacingImperialVampire = AddTextOption("Vampire onset", "Reset + block", OPTION_FLAG_NONE)
    _oidPacingImperialCure = AddTextOption("Vampire cure", "Seed civic 20", OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

String Function GetSubstratePacingSourceLabel()
    if _selectedSubstratePacingSource == 0
        return "Primary approved"
    elseIf _selectedSubstratePacingSource == 1
        return "Alternate approved"
    endIf
    return "Rejected probe"
EndFunction

Function InitializePages()
    ModName = "Devotion"

    ; Players see only the three user-facing tabs. The four dev tabs are appended
    ; only when the owner has unlocked Developer Options from the console, so a
    ; shipped copy never renders a debug tab at all (not even a locked stub).
    if DeveloperOptionsEnabled()
        String[] devPages = new String[6]
        devPages[0] = PAGE_PLAYER
        devPages[1] = PAGE_COMPAT
        devPages[2] = PAGE_STATUS
        devPages[3] = PAGE_DEBUG
        devPages[4] = PAGE_DEBUG2
        devPages[5] = PAGE_PACING
        Pages = devPages
    else
        String[] userPages = new String[2]
        userPages[0] = PAGE_PLAYER
        userPages[1] = PAGE_COMPAT
        Pages = userPages
    endIf
EndFunction

String Function GetSubstratePacingOriginLabel()
    if _selectedSubstratePacingOrigin == 0
        return "Imperial"
    elseIf _selectedSubstratePacingOrigin == 1
        return "Dunmer"
    elseIf _selectedSubstratePacingOrigin == 2
        return "Argonian"
    elseIf _selectedSubstratePacingOrigin == 3
        return "Nord"
    elseIf _selectedSubstratePacingOrigin == 4
        return "Altmer"
    endIf
    return "Khajiit"
EndFunction

Function DebugApplySubstratePacingOrigin()
    if !PDV_Manager
        ShowMessage("PDV manager is not available.", False, "$OK", "")
        return
    endIf
    Int originValue = GetSelectedSubstratePacingOriginValue()
    if PDV_Manager.DebugSetCurseProofOriginRace(originValue)
        ShowMessage("Test origin applied: " + GetSubstratePacingOriginLabel() + ". Use only on this throwaway pacing save.", False, "$OK", "")
    else
        ShowMessage("Test origin was not changed. Clear the forced curse state, then try again.", False, "$OK", "")
    endIf
EndFunction

Int Function GetSelectedSubstratePacingOriginValue()
    if !PDV_Manager
        return -1
    endIf
    if _selectedSubstratePacingOrigin == 0
        return PDV_Manager.ORIGIN_IMPERIAL
    elseIf _selectedSubstratePacingOrigin == 1
        return PDV_Manager.ORIGIN_DUNMER
    elseIf _selectedSubstratePacingOrigin == 2
        return PDV_Manager.ORIGIN_ARGONIAN
    elseIf _selectedSubstratePacingOrigin == 3
        return PDV_Manager.ORIGIN_NORD
    elseIf _selectedSubstratePacingOrigin == 4
        return PDV_Manager.ORIGIN_ALTMER
    endIf
    return PDV_Manager.ORIGIN_KHAJIIT
EndFunction

String Function GetBroadPantheonPoolLabel()
    if _selectedBroadPantheonPool == 0
        return "Imperial Divines"
    elseIf _selectedBroadPantheonPool == 1
        return "Nord Old Ways"
    endIf
    return "Nord Nine Divines"
EndFunction

String Function GetNordBaselinePacingLabel()
    if _selectedNordBaselineForPacing == 0
        return "Old Ways"
    endIf
    return "Nine Divines"
EndFunction

Function DebugShowSubstratePacingSummary()
    if EnsureManagerBinding("pacing_substrate_summary")
        ShowMessage(PDV_Manager.DebugGetSubstratePacingSummary(GetSelectedSubstratePacingOriginValue()), False, "$OK", "")
    endIf
EndFunction

Function DebugTriggerSubstratePacingSource()
    if EnsureManagerBinding("pacing_substrate_trigger")
        ShowMessage(PDV_Manager.DebugTriggerSubstratePacingSource(GetSelectedSubstratePacingOriginValue(), _selectedSubstratePacingSource), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugSeedSubstratePacing(Float targetMetric)
    if EnsureManagerBinding("pacing_substrate_seed")
        ShowMessage(PDV_Manager.DebugSeedSubstrateMetric(GetSelectedSubstratePacingOriginValue(), targetMetric), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugResetSubstratePacing()
    if EnsureManagerBinding("pacing_substrate_reset")
        ShowMessage(PDV_Manager.DebugResetSubstratePacing(GetSelectedSubstratePacingOriginValue()), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugShowBroadPantheonSummary()
    if EnsureManagerBinding("pacing_broad_summary")
        ShowMessage(PDV_Manager.DebugGetBroadPantheonSummary(_selectedBroadPantheonPool), False, "$OK", "")
    endIf
EndFunction

Function DebugSeedBroadPantheonPool(Float targetStanding)
    if EnsureManagerBinding("pacing_broad_seed")
        ShowMessage(PDV_Manager.DebugSeedBroadPantheonPool(_selectedBroadPantheonPool, targetStanding), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugResetBroadPantheonPool()
    if EnsureManagerBinding("pacing_broad_reset")
        ShowMessage(PDV_Manager.DebugResetBroadPantheonPool(_selectedBroadPantheonPool), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRunBroadPantheonFanoutTest()
    if EnsureManagerBinding("pacing_broad_fanout")
        ShowMessage(PDV_Manager.DebugRunBroadPantheonFanoutTest(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugPrimeBroadPantheonScratch(Float scratchValue)
    if EnsureManagerBinding("pacing_broad_scratch")
        ShowMessage(PDV_Manager.DebugPrimeBroadPantheonScratch(_selectedBroadPantheonPool, scratchValue), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRunBroadPantheonMigrationFixture()
    if EnsureManagerBinding("pacing_broad_migration")
        ShowMessage(PDV_Manager.DebugRunBroadPantheonMigrationFixture(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRunBroadPantheonCatchupForPacing()
    if EnsureManagerBinding("pacing_broad_catchup")
        ShowMessage(PDV_Manager.DebugRunBroadPantheonCatchupForPacing(_selectedBroadPantheonPool), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugApplyNordBaselineForPacing()
    if EnsureManagerBinding("pacing_nord_baseline")
        ShowMessage(PDV_Manager.DebugSetNordBaselineForPacing(_selectedNordBaselineForPacing), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugShowPatronOfferRecoverySummary()
    if EnsureManagerBinding("pacing_patron_summary")
        ShowMessage(PDV_Manager.DebugOfferAcceptRecoverySummary(), False, "$OK", "")
    endIf
EndFunction

Function DebugSetBroadWorshipForPacing()
    if EnsureManagerBinding("pacing_set_broad")
        ShowMessage(PDV_Manager.DebugSetBroadWorshipForPacing(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRunPatronOfferForPacing()
    if EnsureManagerBinding("pacing_patron_offer")
        ShowMessage(PDV_Manager.DebugRunPatronOfferForPacing(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugAcceptPatronForPacing()
    if EnsureManagerBinding("pacing_patron_accept")
        ShowMessage(PDV_Manager.DebugAcceptPatronForPacing(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugLapsePatronForPacing()
    if EnsureManagerBinding("pacing_patron_lapse")
        ShowMessage(PDV_Manager.DebugLapsePatronForPacing(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRecoverPatronForPacing()
    if EnsureManagerBinding("pacing_patron_recover")
        ShowMessage(PDV_Manager.DebugRecoverPatronForPacing(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugSetImperialVampireForPacing(Bool vampireOnset)
    if EnsureManagerBinding("pacing_imperial_vampire")
        ShowMessage(PDV_Manager.DebugSetImperialVampireForPacing(vampireOnset), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function CycleSelectedDeity()
    Int deityCount = GetDeityCount()
    if deityCount <= 0
        _selectedListIndex = -1
        return
    endIf

    _selectedListIndex += 1
    if _selectedListIndex >= deityCount
        _selectedListIndex = 0
    endIf
EndFunction

Function CycleSelectedDaedricPath()
    Int pathCount = GetDaedricPathCount()
    if pathCount <= 0
        _selectedDaedricPathIndex = -1
        return
    endIf

    _selectedDaedricPathIndex += 1
    if _selectedDaedricPathIndex >= pathCount
        _selectedDaedricPathIndex = 0
    endIf
EndFunction

Function CycleCurseProofOrigin()
    _selectedCurseProofOrigin += 1
    if _selectedCurseProofOrigin > 9
        _selectedCurseProofOrigin = 0
    endIf
EndFunction

String Function GetCurseProofOriginLabel()
    if _selectedCurseProofOrigin == 0
        return "Nord"
    elseIf _selectedCurseProofOrigin == 1
        return "Imperial"
    elseIf _selectedCurseProofOrigin == 2
        return "Breton"
    elseIf _selectedCurseProofOrigin == 3
        return "Altmer"
    elseIf _selectedCurseProofOrigin == 4
        return "Bosmer"
    elseIf _selectedCurseProofOrigin == 5
        return "Dunmer"
    elseIf _selectedCurseProofOrigin == 6
        return "Khajiit"
    elseIf _selectedCurseProofOrigin == 7
        return "Argonian"
    elseIf _selectedCurseProofOrigin == 8
        return "Orc"
    elseIf _selectedCurseProofOrigin == 9
        return "Redguard"
    endIf

    return "Unavailable"
EndFunction

Function CycleSignalFloorScenario()
    Int count = 1
    if PDV_Manager
        count = PDV_Manager.DebugGetSignalFloorSmokeScenarioCount() + 1
    endIf

    _selectedSignalFloorScenario += 1
    if _selectedSignalFloorScenario >= count
        _selectedSignalFloorScenario = 0
    endIf
EndFunction

String Function GetSignalFloorScenarioLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetSignalFloorSmokeLabel(_selectedSignalFloorScenario)
    endIf
    return "Unavailable"
EndFunction

Function RunSignalFloorSmokeScenario()
    if !EnsureManagerBinding("signal_floor_smoke")
        ShowMessage("Devotion is still starting up.", False, "$OK", "")
        return
    endIf

    String label = PDV_Manager.DebugGetSignalFloorSmokeLabel(_selectedSignalFloorScenario)
    if ShowMessage("Run controlled signal-floor smoke scenario: " + label + "? Capture Prisma and Book of Days separately. Organic quest-stage delivery remains open.", True, "$Yes", "$No")
        ShowMessage(PDV_Manager.DebugRunSignalFloorSmokeScenario(_selectedSignalFloorScenario), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

String Function GetQuestReactionQueueStatusLabel()
    if PDV_Manager
        return PDV_Manager.GetQuestReactionQueueStatus()
    endIf
    return "Unavailable"
EndFunction

Function RunQuestReactionPerformanceSweep()
    if !EnsureManagerBinding("quest_reaction_performance_sweep")
        ShowMessage("Devotion is still starting up.", False, "$OK", "")
        return
    endIf
    if ShowMessage("Queue the controlled Quest Reaction Performance Sweep? It changes piety/state on this save. Capture Prisma and Book of Days separately; reopen Book of Days after completion if it was already open.", True, "$Yes", "$No")
        ShowMessage(PDV_Manager.DebugQueueQuestReactionPerformanceSweep(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugOverridePatron()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Apply a debug patron override to " + deity.DeityName + "?", True, "$Yes", "$No")
        PDV_Manager.ForceSetActiveDeityByIndex(deity.DeityIndex)
        ForcePageReset()
    endIf
EndFunction

Function DebugClearPatron()
    if ShowMessage("Clear the current debug patron override?", True, "$Yes", "$No")
        PDV_Manager.DebugClearActiveDeity()
        ForcePageReset()
    endIf
EndFunction

Function DebugResetSelectedDeity()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Reset " + deity.DeityName + " to zero piety and tier 0?", True, "$Yes", "$No")
        PDV_Manager.DebugResetDeityByIndex(deity.DeityIndex)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplySelectedPiety()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Force " + deity.DeityName + " piety to " + FormatFloat(_pendingPiety) + "?", True, "$Yes", "$No")
        PDV_Manager.DebugForceSetPietyByIndex(deity.DeityIndex, _pendingPiety)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplySelectedPietyToday()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Force " + deity.DeityName + " scratch piety to " + FormatFloat(_pendingPietyToday) + "?", True, "$Yes", "$No")
        PDV_Manager.DebugForceSetPietyTodayByIndex(deity.DeityIndex, _pendingPietyToday)
        ForcePageReset()
    endIf
EndFunction

Function DebugApplyCuratedSignal()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Apply curated signal " + _pendingSignalType + " to " + deity.DeityName + "?", True, "$Yes", "$No")
        PDV_Manager.DebugAwardCuratedSignalByIndex(deity.DeityIndex, _pendingSignalType)
        ForcePageReset()
    endIf
EndFunction

Function DebugFireSelectedDislike()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf
    if !PDV_Manager
        return
    endIf

    if ShowMessage("Fire dislike event " + _pendingDisfavorEventId + " vs " + deity.DeityName + "? Set Target piety >= 25 first (or make it your patron) so the disfavor standing gate passes; below standing it applies the piety loss only.", True, "$Yes", "$No")
        PDV_Manager.DebugFireDislike(deity, _pendingDisfavorEventId)
        ShowMessage(PDV_Manager.GetActiveDisfavorSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

String Function GetFireDislikeLabel()
    if !PDV_Manager
        return "event " + _pendingDisfavorEventId
    endIf
    return PDV_Manager.DebugDislikeSummaryLine(GetSelectedDeity(), _pendingDisfavorEventId)
EndFunction

String Function GetDisfavorDomainCycleLabel()
    if PDV_Manager
        return _pendingDisfavorDomain + " " + PDV_Manager.GetDisfavorDomainLabel(_pendingDisfavorDomain)
    endIf
    return "Domain " + _pendingDisfavorDomain
EndFunction

String Function GetDisfavorBandCycleLabel()
    if _pendingDisfavorSharp
        return "Sharp"
    endIf
    return "Light"
EndFunction

Function SyncSelection()
    Int deityCount = GetDeityCount()
    if deityCount <= 0
        _selectedListIndex = -1
        return
    endIf

    if _selectedListIndex < 0
        _selectedListIndex = 0
    elseIf _selectedListIndex >= deityCount
        _selectedListIndex = deityCount - 1
    endIf

    SyncDaedricPathSelection()
EndFunction

Function SyncDaedricPathSelection()
    Int pathCount = GetDaedricPathCount()
    if pathCount <= 0
        _selectedDaedricPathIndex = -1
        return
    endIf

    if _selectedDaedricPathIndex < 0
        _selectedDaedricPathIndex = 0
    elseIf _selectedDaedricPathIndex >= pathCount
        _selectedDaedricPathIndex = pathCount - 1
    endIf
EndFunction

PDV_DeityBase Function GetSelectedDeity()
    SyncSelection()
    if _selectedListIndex < 0
        return None
    endIf
    return PDV_Manager.GetDeityAtListIndex(_selectedListIndex)
EndFunction

Int Function GetDeityCount()
    if PDV_Manager
        return PDV_Manager.GetDeityCount()
    endIf
    if PDV_FLST_AllDeities
        return PDV_FLST_AllDeities.GetSize()
    endIf
    return 0
EndFunction

String Function GetSelectedDeityLabel()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity
        return "None"
    endIf
    return deity.DeityName + " [" + deity.DeityIndex + "]"
EndFunction

Int Function GetDaedricPathCount()
    if PDV_FLST_DaedricPaths_All
        return PDV_FLST_DaedricPaths_All.GetSize()
    endIf

    return 0
EndFunction

PDV_DaedricPathBase Function GetSelectedDaedricPath()
    SyncDaedricPathSelection()
    if _selectedDaedricPathIndex < 0 || !PDV_FLST_DaedricPaths_All
        return None
    endIf

    return PDV_FLST_DaedricPaths_All.GetAt(_selectedDaedricPathIndex) as PDV_DaedricPathBase
EndFunction

String Function GetSelectedDaedricPathLabel()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        return "None"
    endIf

    return path.DeityName + " [" + _selectedDaedricPathIndex + "]"
EndFunction

String Function GetSelectedDaedricProofSummary()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        return "No Daedric path is available."
    endIf

    return path.DeityName + ": " + path.GetContractSummary() + "; activePact=" + BoolToYesNo(path.IsActiveDaedricPact()) + "; " + path.GetDaedricSpellSummary() + "; exit=" + path.GetExitDifficultyForPlayer()
EndFunction

Function DebugShowSelectedDaedricSummary()
    ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
EndFunction

Function DebugResetSelectedDaedricPath()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        ShowMessage("No Daedric path is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Reset " + path.DeityName + " to a clean Daedric proof baseline?", True, "$Yes", "$No")
        path.ResetDaedricForDebug()
        path.SetStoredPiety(0.0, "mcm_daedric_reset")
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugAddSelectedDaedricSignal()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        ShowMessage("No Daedric path is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Add one controlled Daedric commitment signal to " + path.DeityName + "?", True, "$Yes", "$No")
        path.AddCommitmentSignal("mcm_daedric_controlled_signal")
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugForceSelectedDaedricTier(Int tierValue)
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        ShowMessage("No Daedric path is available.", False, "$OK", "")
        return
    endIf

    String tierLabel = GetDaedricProofTierLabel(tierValue)
    if ShowMessage("Force " + path.DeityName + " to " + tierLabel + " for controlled display proof?", True, "$Yes", "$No")
        PDV__ManagerQuest manager = GetManagerService()
        if tierValue == 3
            ; The authored Champion message (Msg_ChampionEntry) cannot display while the
            ; MCM is open. Seat Champion silently, then queue the authored offer replay --
            ; the manager fires it once the menu closes (ShowTierEntryMessage shows the
            ; real message + Accept/Decline; Decline reverts to Devoted, toast only on
            ; Accept). This restores the authored text and fires it after the menu, not
            ; mid-menu.
            path.DebugForceCommitmentSignals(path.CommitmentSignalsRequired, "mcm_daedric_force_" + tierLabel)
            path.DebugSeatChampionSilently()
            TraceMcm(1, "Daedric Champion forced for " + path.DeityName + "; authored offer queued for after menu close.")
            if manager
                manager.QueueDaedricMilestoneMcmReplay(path, 2, 3, "mcm_force_" + tierLabel)
            endIf
        else
            Int oldTier = path.GetStoredTier()
            if manager && tierValue > 0
                manager.QueueDaedricMilestonePresentation(path, oldTier, tierValue, "mcm_force_" + tierLabel)
            endIf
            if tierValue > 0
                path.DebugForceCommitmentSignals(path.CommitmentSignalsRequired, "mcm_daedric_force_" + tierLabel)
            endIf
            path.SetStoredPiety(GetDaedricProofPietyForTier(path, tierValue), "mcm_daedric_force_" + tierLabel)
            if tierValue > 0
                path.MakeActiveDaedricPact()
            endIf
        endIf
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

String Function BoolToYesNo(Bool flag)
    if flag
        return "Y"
    endIf

    return "N"
EndFunction

Function DebugAddSelectedDaedricStigma()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        ShowMessage("No Daedric path is available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Add one controlled stigma event to " + path.DeityName + "?", True, "$Yes", "$No")
        path.AddStigma(path.StigmaPerEvent, "mcm_daedric_controlled_stigma")
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Float Function GetDaedricProofPietyForTier(PDV_DaedricPathBase path, Int tierValue)
    if !path
        return 0.0
    endIf

    if tierValue >= 3
        return path.ThresholdChampion
    elseIf tierValue == 2
        return path.ThresholdDevoted
    elseIf tierValue == 1
        return path.ThresholdSeeker
    endIf

    return 0.0
EndFunction

String Function GetDaedricProofTierLabel(Int tierValue)
    if tierValue >= 3
        return "Champion"
    elseIf tierValue == 2
        return "Devoted"
    elseIf tierValue == 1
        return "Seeker"
    endIf

    return "Lapse"
EndFunction

Function DebugRouteSelectedDaedricLiveSender()
    PDV_DaedricPathBase path = GetSelectedDaedricPath()
    if !path
        ShowMessage("No Daedric path is available.", False, "$OK", "")
        return
    endIf

    if !PDV_EventBusService
        ShowMessage("PDV_EventBusService is not wired for Daedric live sender proof.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Route a curated live sender cue to " + path.DeityName + "?", True, "$Yes", "$No")
        PDV_EventBusService.RouteDaedricPrinceSignal(_selectedDaedricPathIndex, "mcm_live_curated")
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRouteAllDaedricLiveSenders()
    if !PDV_EventBusService
        ShowMessage("PDV_EventBusService is not wired for Daedric live sender proof.", False, "$OK", "")
        return
    endIf

    Int pathCount = GetDaedricPathCount()
    if pathCount <= 0
        ShowMessage("No Daedric paths are available.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Route one controlled EventBus sender cue for every Daedric Prince, then route the generic silence probe?", True, "$Yes", "$No")
        Int pathIndex = 0
        while pathIndex < pathCount
            PDV_EventBusService.RouteDaedricPrinceSignal(pathIndex, "mcm_live_all")
            pathIndex += 1
        endWhile

        PDV_EventBusService.RouteDaedricGenericSilenceProbe("mcm_generic_probe")
        Debug.Notification("PDV Daedric all-Prince sender sweep complete")
        ShowMessage("Daedric all-Prince sender sweep routed: " + pathCount + " Prince cues plus generic silence probe.", False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Function DebugRouteDaedricGenericProbe()
    if !PDV_EventBusService
        ShowMessage("PDV_EventBusService is not wired for Daedric generic silence proof.", False, "$OK", "")
        return
    endIf

    if ShowMessage("Route a generic Daedric silence probe? The selected Prince should not change.", True, "$Yes", "$No")
        PDV_EventBusService.RouteDaedricGenericSilenceProbe("mcm_generic_probe")
        Debug.Notification("PDV Daedric generic probe ignored")
        ShowMessage(GetSelectedDaedricProofSummary(), False, "$OK", "")
        ForcePageReset()
    endIf
EndFunction

Bool Function DeveloperOptionsEnabled()
    ; Owner-only debug unlock. Raise the existing trace-verbosity global from the
    ; console ("set PDV_GLO_DebugLevel to 3") to reveal the dev tabs; set it back
    ; to 0 to hide them again. Reusing this global keeps a single build with no
    ; discoverable in-game toggle for players.
    if !PDV_GLO_DebugLevel
        return False
    endIf
    return PDV_GLO_DebugLevel.GetValueInt() >= 1
EndFunction

String Function GetDeveloperPageStateLabel()
    if DeveloperOptionsEnabled()
        return "Visible"
    endIf

    return "Locked"
EndFunction

String Function GetActivePatronLabel()
    Int activeDeityIndex = GetActiveDeityIndexValue()
    if activeDeityIndex < 0 || !PDV_Manager
        return "None"
    endIf

    PDV_DeityBase deity = PDV_Manager.GetDeityByIndex(activeDeityIndex)
    if deity
        return deity.DeityName + " [" + deity.DeityIndex + "]"
    endIf

    return "Unknown [" + activeDeityIndex + "]"
EndFunction

String Function GetPatronStateLabel()
    if PDV_Manager
        return PDV_Manager.GetPatronStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetOriginDiagnosticLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetOriginDiagnostic()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatRawLabel()
    if PDV_Manager
        return "" + PDV_Manager.DebugGetConcordatRawValue()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatStateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatPendingStateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatPendingStateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetConcordatGateLabel()
    if PDV_Manager
        return PDV_Manager.DebugGetConcordatGateLabel()
    endIf

    return "Unknown"
EndFunction

String Function GetTalosGainMultiplierLabel()
    if PDV_Manager
        return FormatFloat(PDV_Manager.GetTalosEffectiveGainMultiplier()) + " (track " + FormatFloat(PDV_Manager.GetTalosTrackGainMultiplier()) + ")"
    endIf

    return "Unknown"
EndFunction

String Function GetSelectedSignalLabel()
    if _pendingSignalType == 101
        return "Talos shrine defiance"
    elseIf _pendingSignalType == 102
        return "Talos protect worshipper"
    elseIf _pendingSignalType == 103
        return "Talos defiance milestone"
    elseIf _pendingSignalType == 201
        return "Auri-El dawn acknowledgment"
    elseIf _pendingSignalType == 202
        return "Auri-El orthodoxy affirmation"
    endIf

    return "Signal " + _pendingSignalType
EndFunction

Float Function GetActivePietyValue()
    if PDV_GLO_ActivePiety
        return PDV_GLO_ActivePiety.GetValue()
    endIf
    return 0.0
EndFunction

Int Function GetActiveTierValue()
    if PDV_GLO_ActiveTier
        return PDV_GLO_ActiveTier.GetValueInt()
    endIf
    return 0
EndFunction

Int Function GetActiveDeityIndexValue()
    if PDV_GLO_ActiveDeityIndex
        return PDV_GLO_ActiveDeityIndex.GetValueInt()
    endIf
    return -1
EndFunction

Float Function GetDebugLevelValue()
    GlobalVariable debugGlobal = GetDebugLevelGlobal()
    if debugGlobal
        return debugGlobal.GetValue()
    endIf
    return 0.0
EndFunction

Float Function GetPatronFormCacheValue()
    if PDV_GLO_PatronDeity
        return PDV_GLO_PatronDeity.GetValue()
    endIf
    return 0.0
EndFunction

Int Function ClampSignalType(Int value)
    if value < SIGNAL_TYPE_MIN as Int
        return SIGNAL_TYPE_MIN as Int
    elseIf value > SIGNAL_TYPE_MAX as Int
        return SIGNAL_TYPE_MAX as Int
    endIf
    return value
EndFunction

Float Function GetSelectedDeityPiety()
    PDV_DeityBase deity = GetSelectedDeity()
    if deity && PDV_Manager
        return PDV_Manager.GetPiety(deity)
    endIf
    return 0.0
EndFunction

Float Function GetSelectedDeityPietyToday()
    PDV_DeityBase deity = GetSelectedDeity()
    if deity && PDV_Manager
        return PDV_Manager.GetPietyToday(deity)
    endIf
    return 0.0
EndFunction

Function RunPatternAction(String promptText, Int actionId)
    if _patternActionPromptOpen
        return
    endIf

    PDV__ManagerQuest manager = GetManagerService()
    if !manager
        ShowMessage("PDV_Manager is not assigned.", False, "$OK", "")
        return
    endIf

    _patternActionPromptOpen = True
    Bool confirmed = ShowMessage(promptText, True, "$Yes", "$No")
    _patternActionPromptOpen = False

    if !confirmed
        return
    endIf

    if actionId == 1
        if PDV_EventBusService
            PDV_EventBusService.RouteConcordatPressure(False)
        endIf
    elseIf actionId == 2
        if PDV_EventBusService
            PDV_EventBusService.RouteConcordatPressure(True)
        endIf
    elseIf actionId == 3
        manager.DebugUnlockConcordatWalkback()
    elseIf actionId == 4
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_OLD_CONTRACT)
    elseIf actionId == 5
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_BANDIT_ROAD)
    elseIf actionId == 6
        if PDV_EventBusService
            PDV_EventBusService.RouteGreenPactViolation()
        else
            manager.DebugTriggerGreenPactViolation()
        endIf
    elseIf actionId == 19
        if PDV_EventBusService
            PDV_EventBusService.RouteBosmerLivingStory()
        else
            manager.DebugRecordBosmerLivingStorySignal()
        endIf
    elseIf actionId == 20
        if PDV_EventBusService
            PDV_EventBusService.RouteBosmerExchange()
        else
            manager.DebugRecordBosmerExchangeSignal()
        endIf
    elseIf actionId == 21
        if PDV_EventBusService
            PDV_EventBusService.RouteBosmerBanditRoad()
        else
            manager.DebugRecordBosmerBanditRoadSignal()
        endIf
    elseIf actionId == 22
        if PDV_EventBusService
            PDV_EventBusService.RouteBosmerPactPositive()
        else
            manager.DebugRecordBosmerPactPositiveSignal()
        endIf
    elseIf actionId == 23
        if PDV_EventBusService
            PDV_EventBusService.RouteStateTransitionConfirmationRite()
        else
            manager.DebugConfirmStateTransitionRite()
        endIf
    elseIf actionId == 7
        if PDV_EventBusService
            PDV_EventBusService.RouteDunmerPortableShrinePrayer()
        else
            manager.DebugRecordDunmerAncestorPrayer()
        endIf
    elseIf actionId == 8
        if PDV_EventBusService
            PDV_EventBusService.RouteDunmerPlayerHomeBonus()
        else
            manager.DebugRecordDunmerAncestorHomeBonus()
        endIf
    elseIf actionId == 9
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitMoonObservance(0)
        else
            manager.DebugRecordKhajiitMoonObservance()
        endIf
    elseIf actionId == 10
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitRoadHome()
        else
            manager.DebugRecordKhajiitRoadHome()
        endIf
    elseIf actionId == 11
        manager.DebugSetBroadWorship()
    elseIf actionId == 12
        manager.DebugEvaluateCommitmentOffer()
    elseIf actionId == 13
        manager.DebugAcceptPendingCommitment()
    elseIf actionId == 14
        manager.DebugDeclinePendingCommitment()
    elseIf actionId == 15
        manager.DebugRefusePendingCommitment()
    elseIf actionId == 16
        if PDV_EventBusService
            PDV_EventBusService.RouteHircineHuntRite()
        else
            manager.DebugRecordHircineHuntRite()
        endIf
    elseIf actionId == 17
        manager.DebugRenounceHircinePath()
    elseIf actionId == 18
        if PDV_EventBusService
            PDV_EventBusService.RouteTalosShrineDefiance()
        else
            manager.DebugRecordTalosShrineDefiance()
        endIf
    elseIf actionId == 60
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitKhenarthiCaravanAid("mcm")
        else
            manager.DebugRecordKhajiitCaravanAid()
        endIf
    elseIf actionId == 61
        if PDV_EventBusService
            PDV_EventBusService.RouteKhajiitRajhinLegendMade("mcm")
        else
            manager.DebugRecordKhajiitLegendMade()
        endIf
    elseIf actionId == 62
        if PDV_EventBusService
            PDV_EventBusService.RouteMephalaWebWoven("mcm")
        else
            manager.DebugRecordMephalaWebWoven()
        endIf
    elseIf actionId == 63
        if PDV_EventBusService
            PDV_EventBusService.RouteBoethiahHonorableDuel("mcm")
        else
            manager.DebugRecordBoethiahHonorableDuel()
        endIf
    elseIf actionId == 58
        manager.DebugApplyTalosBetrayalCompliance()
    elseIf actionId == 59
        manager.DebugApplyTalosBetrayalMajor()
    elseIf actionId == 24
        manager.DebugSetNordPantheonBaseline(manager.NORD_BASELINE_OLD_WAYS)
    elseIf actionId == 25
        manager.DebugSetNordPantheonBaseline(manager.NORD_BASELINE_NINE_DIVINES)
    elseIf actionId == 26
        manager.DebugCycleContextualFavorLane()
    elseIf actionId == 27
        manager.DebugCycleContextualFavorFamily()
    elseIf actionId == 28
        manager.DebugTriggerSelectedContextualFavor()
    elseIf actionId == 29
        manager.DebugExpireActiveFavor()
    elseIf actionId == 30
        manager.DebugResetHircinePath()
    elseIf actionId == 31
        manager.DebugForceCurseNone()
    elseIf actionId == 32
        manager.DebugForceCurseWerewolf()
    elseIf actionId == 33
        manager.DebugForceCurseVampire()
    elseIf actionId == 34
        PDV_DeityBase selectedDeity = GetSelectedDeity()
        if selectedDeity
            manager.DebugSeedCommitmentSignalDaysByIndex(selectedDeity.DeityIndex)
        endIf
    elseIf actionId == 35
        PDV_DeityBase selectedDeity = GetSelectedDeity()
        if selectedDeity
            manager.DebugResetCommitmentStateByIndex(selectedDeity.DeityIndex)
        endIf
    elseIf actionId == 36
        manager.DebugRefreshCurseFromPlayerState()
    elseIf actionId == 37
        if manager.DebugSetCurseProofOriginRace(_selectedCurseProofOrigin)
            Debug.Notification("PDV: curse proof race set to " + GetCurseProofOriginLabel() + ".")
        else
            Debug.Notification("PDV: curse proof race was not changed.")
        endIf
    elseIf actionId == 38
        manager.DebugRunNeglectPass()
    elseIf actionId == 39
        PDV_DeityBase selectedDeity = GetSelectedDeity()
        if selectedDeity
            manager.DebugPrimeDecayGraceByIndex(selectedDeity.DeityIndex)
        endIf
    elseIf actionId == 40
        PDV_DeityBase selectedDeity = GetSelectedDeity()
        if selectedDeity
            manager.DebugPrimeDecayEligibleByIndex(selectedDeity.DeityIndex)
        endIf
    elseIf actionId == 41
        manager.DebugRunDecayPass()
    elseIf actionId == 42
        PDV_DeityBase selectedDeity = GetSelectedDeity()
        if selectedDeity
            manager.DebugRunDecayProofDaysByIndex(selectedDeity.DeityIndex)
        endIf
    elseIf actionId == 43
        manager.DebugSetKhajiitFocus(manager.KHAJIIT_FOCUS_BAANDAR)
    elseIf actionId == 44
        manager.DebugSetKhajiitFocus(manager.KHAJIIT_FOCUS_RAJHIN)
    elseIf actionId == 45
        manager.DebugSetKhajiitFocus(manager.KHAJIIT_FOCUS_ALKOSH)
    elseIf actionId == 46
        manager.DebugSetBretonTradition(manager.BRETON_TRADITION_KNIGHTS_ROAD)
    elseIf actionId == 47
        manager.DebugSetBretonTradition(manager.BRETON_TRADITION_HIDDEN_ART)
    elseIf actionId == 48
        manager.DebugSetBretonTradition(manager.BRETON_TRADITION_GREEN_WAY)
    elseIf actionId == 49
        manager.DebugSetOrcLifeMode(manager.ORC_LIFE_MODE_CITY)
    elseIf actionId == 50
        manager.DebugSetOrcLifeMode(manager.ORC_LIFE_MODE_STRONGHOLD)
    elseIf actionId == 51
        manager.DebugSetOrcLifeMode(manager.ORC_LIFE_MODE_LEGION_EXILE)
    elseIf actionId == 52
        manager.DebugSetArgonianFocus(manager.ARGONIAN_FOCUS_PEOPLE)
    elseIf actionId == 53
        manager.DebugSetArgonianFocus(manager.ARGONIAN_FOCUS_VOID)
    elseIf actionId == 54
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_LIVING_STORY)
    elseIf actionId == 55
        manager.DebugSetBosmerPathState(manager.BOSMER_PATH_EXCHANGE)
    elseIf actionId == 56
        manager.DebugSeedBosmerVariety()
    elseIf actionId == 57
        manager.DebugCycleKhajiitLunarPosture()
    endIf

    ShowPatternSummaryBrief()
    ForcePageReset()
EndFunction

; Compact post-action feedback: just the player's race section (or global state
; if the race has none) in a single box, so action feedback never overflows.
Function ShowPatternSummaryBrief()
    PDV__ManagerQuest manager = GetManagerService()
    if !manager
        return
    endIf

    Int raceSection = manager.DebugGetPatternSummaryRaceSection(manager.GetPlayerOriginRaceIndex())
    if raceSection < 0
        raceSection = 0
    endIf

    ShowMessage(manager.DebugGetPatternSummarySection(raceSection), False, "$OK", "")
EndFunction

Function ShowSelectedDecaySummary()
    PDV_DeityBase deity = GetSelectedDeity()
    if !deity || !PDV_Manager
        ShowMessage("No selected deity is available.", False, "$OK", "")
        return
    endIf

    ShowMessage(PDV_Manager.DebugGetDecaySummaryByIndex(deity.DeityIndex), False, "$OK", "")
EndFunction

String Function GetFavorLaneOptionLabel()
    PDV__ManagerQuest manager = GetManagerService()
    if manager
        return manager.GetSelectedContextualFavorLaneLabel()
    endIf

    return "Unavailable"
EndFunction

String Function GetFavorFamilyOptionLabel()
    PDV__ManagerQuest manager = GetManagerService()
    if manager
        return manager.GetSelectedContextualFavorFamilyLabel()
    endIf

    return "Unavailable"
EndFunction

String Function GetPatternSummaryString()
    PDV__ManagerQuest manager = GetManagerService()
    if manager
        return manager.DebugGetPatternProvingSummary() + "; SelectedCommitment=" + GetSelectedCommitmentSummary(manager)
    endIf

    return "Pattern proving summary unavailable."
EndFunction

; Pages the pattern summary one section per screen so it never overflows the
; message box. Leads with the player's origin-race section, then the rest in
; order; Next advances, Close stops. Section 0..13 map in the manager.
Function ShowPatternSummaryPaged()
    PDV__ManagerQuest manager = GetManagerService()
    if !manager
        ShowMessage("Pattern proving summary unavailable.", False, "$OK", "")
        return
    endIf

    Int total = manager.DebugGetPatternSummarySectionCount()
    Int raceSection = manager.DebugGetPatternSummaryRaceSection(manager.GetPlayerOriginRaceIndex())
    Int shown = 0

    if raceSection >= 0
        shown += 1
        if !ShowSummaryScreen(manager, raceSection, shown, total)
            return
        endIf
    endIf

    Int s = 0
    while s < total
        if s != raceSection
            shown += 1
            if !ShowSummaryScreen(manager, s, shown, total)
                return
            endIf
        endIf
        s += 1
    endWhile
EndFunction

; Shows one summary section. Returns True to keep paging, False to stop (Close
; pressed or last screen reached).
Bool Function ShowSummaryScreen(PDV__ManagerQuest manager, Int sectionIndex, Int position, Int total)
    String body = "(" + position + "/" + total + ")  " + manager.DebugGetPatternSummarySection(sectionIndex)
    if position < total
        return ShowMessage(body, True, "Next", "Close")
    endIf

    ShowMessage(body, False, "Close", "")
    return False
EndFunction

String Function GetSelectedCommitmentSummary(PDV__ManagerQuest manager)
    PDV_DeityBase selectedDeity = GetSelectedDeity()
    if !selectedDeity || !manager
        return "selected=none"
    endIf

    Int usesFormal = 0
    if manager.UsesFormalCommitmentOffersForDeity(selectedDeity)
        usesFormal = 1
    endIf

    Int ready = 0
    if manager.HasRecentCommitmentSignalDays(selectedDeity, 2, 7)
        ready = 1
    endIf

    Int offered = 0
    if manager.IsCommitmentOffered(selectedDeity)
        offered = 1
    endIf

    Int refused = 0
    if manager.IsCommitmentRefused(selectedDeity)
        refused = 1
    endIf

    return "selected=" + selectedDeity.DeityName + "[" + selectedDeity.DeityIndex + "]" + ";formal=" + usesFormal + ";ready=" + ready + ";days=" + manager.GetRecentCommitmentSignalDayCount(selectedDeity, 7) + ";piety=" + FormatFloat(manager.GetPiety(selectedDeity)) + ";offered=" + offered + ";refused=" + refused
EndFunction

PDV__ManagerQuest Function GetManagerService()
    if PDV_Manager
        return PDV_Manager
    endIf

    if PDV_EventBusService && PDV_EventBusService.PDV_Manager
        return PDV_EventBusService.PDV_Manager
    endIf

    ; Plugin-level last resort: resolve the manager quest directly from
    ; Devotion.esp so the MCM self-heals even when both baked manager
    ; references are unbound on an existing save. 00C325 is the
    ; PDV__ManagerQuest local FormID in Devotion.esp.
    PDV__ManagerQuest pluginManager = Game.GetFormFromFile(0x00C325, "Devotion.esp") as PDV__ManagerQuest
    if pluginManager
        return pluginManager
    endIf

    return None
EndFunction

PDV_Origin Function GetOriginService()
    PDV_Origin pluginOrigin = Game.GetFormFromFile(0x02F490, "Devotion.esp") as PDV_Origin
    if pluginOrigin
        return pluginOrigin
    endIf

    return None
EndFunction

Bool Function EnsureManagerBinding(String reason)
    if PDV_Manager
        return True
    endIf

    PDV__ManagerQuest resolvedManager = GetManagerService()
    if !resolvedManager
        TraceMcm(1, "Manager bind failed (" + reason + ")")
        return False
    endIf

    ; Validate key read-only API callability before caching.
    resolvedManager.GetStartupMcmLine()
    PDV_Manager = resolvedManager
    TraceMcm(1, "Manager rebound (" + reason + ")")
    return True
EndFunction

Function TraceMcm(Int level, String messageText)
    GlobalVariable debugGlobal = GetDebugLevelGlobal()
    if !debugGlobal
        return
    endIf

    if debugGlobal.GetValueInt() >= level
        Debug.Trace("[PDV] MCM: " + messageText)
    endIf
EndFunction

GlobalVariable Function GetDebugLevelGlobal()
    if PDV_GLO_DebugLevel
        return PDV_GLO_DebugLevel
    endIf

    if PDV_EventBusService && PDV_EventBusService.PDV_GLO_DebugLevel
        return PDV_EventBusService.PDV_GLO_DebugLevel
    endIf

    return None
EndFunction

String Function BuildStructuralMapString()
    String output = "Rep=" + GetFormListCount(PDV_FLST_RepTracks_All)
    output = output + "; State=" + GetFormListCount(PDV_FLST_StateTracks_All)
    output = output + "; Substrate=" + GetFormListCount(PDV_FLST_Substrates_All)
    output = output + "; Daedric=" + GetFormListCount(PDV_FLST_DaedricPaths_All)
    output = output + "; Curse=" + GetCurseServiceLabel()
    return output
EndFunction

String Function RunScaffoldApiSmoke()
    String output = RunReputationTrackSmoke()
    output = output + "; " + RunStateTrackSmoke()
    output = output + "; " + RunSubstrateSmoke()
    output = output + "; " + RunDaedricSmoke()
    output = output + "; " + RunCurseStateSmoke()
    return output
EndFunction

String Function RunReputationTrackSmoke()
    PDV_ReputationTrack track = GetFirstReputationTrack()
    if !track
        return "Rep missing"
    endIf

    Int oldValue = track.GetValue()
    Int adjustment = 1
    if oldValue >= track.MaxValue
        adjustment = -1
    endIf

    track.Adjust(adjustment, "mcm_scaffold_smoke")
    Int adjustedValue = track.GetValue()
    track.ForceSet(oldValue, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: reputation " + track.TrackName + " " + oldValue + " -> " + adjustedValue + " -> " + track.GetValue())
    return "Rep ok"
EndFunction

String Function RunStateTrackSmoke()
    PDV_StateTrack track = GetFirstStateTrack()
    if !track
        return "State missing"
    endIf

    Int oldState = track.GetCurrentState()
    Int smokeState = 0
    if oldState == 0
        smokeState = 1
    endIf

    track.SetState(smokeState, "mcm_scaffold_smoke")
    Int adjustedState = track.GetCurrentState()
    track.SetState(oldState, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: state " + track.TrackName + " " + oldState + " -> " + adjustedState + " -> " + track.GetCurrentState())
    return "State ok"
EndFunction

String Function RunSubstrateSmoke()
    PDV_SubstrateBase substrate = GetFirstSubstrate()
    if !substrate
        return "Substrate missing"
    endIf

    Float oldMetric = substrate.GetMetric()
    Int oldTier = substrate.GetSubstrateTier()
    Int recomputedTier = substrate.RecomputeSubstrateTier()
    Debug.Trace("[PDV] MCM ScaffoldSmoke: substrate " + substrate.SubstrateName + " metric " + oldMetric + ", tier " + oldTier + " -> " + recomputedTier)
    return "Substrate ok"
EndFunction

; RunSacredPlaceSmoke() CUT (1.0.3) along with the rest of the SacredPlace subsystem -
; it was the only code left in the mod that still reached into PDV_SacredPlace. The
; feature itself ships live elsewhere (Argonian bed-of-choice, the shared hearth-rest
; declaration, Khajiit road-homes), so this was smoke-testing a superseded design.

String Function RunDaedricSmoke()
    PDV_DaedricPathBase path = GetFirstDaedricPath()
    if !path
        return "Daedric missing"
    endIf

    Int oldSignals = path.GetCommitmentSignalCount()
    Float oldStigma = path.GetStigma()
    path.AddCommitmentSignal("mcm_scaffold_smoke")
    path.AddStigma(1.0, "mcm_scaffold_smoke")
    Int adjustedSignals = path.GetCommitmentSignalCount()
    Float adjustedStigma = path.GetStigma()
    path.ResetDaedricForDebug()
    path.DebugForceCommitmentSignals(oldSignals, "mcm_scaffold_restore")
    path.DebugForceStigma(oldStigma, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: daedric " + path.DeityName + " sig " + oldSignals + " -> " + adjustedSignals + "; stigma " + oldStigma + " -> " + adjustedStigma)
    return "Daedric ok"
EndFunction

String Function RunCurseStateSmoke()
    if !PDV_CurseStateService
        return "Curse missing"
    endIf

    Int oldState = PDV_CurseStateService.GetCurseState()
    PDV_CurseStateService.SetCurseState(PDV_CurseStateService.CURSE_UNKNOWN, "mcm_scaffold_smoke")
    Int adjustedState = PDV_CurseStateService.GetCurseState()
    if oldState == PDV_CurseStateService.CURSE_NONE
        PDV_CurseStateService.ClearCurseState("mcm_scaffold_restore")
    else
        PDV_CurseStateService.SetCurseState(oldState, "mcm_scaffold_restore")
    endIf
    ; D5 / fix-plan 9.3. This smoke drives curse state through the SERVICE, which owns
    ; the value on its own form, and never through PDV__ManagerQuest.HandleCurseStateTransition,
    ; which owns the None-keyed "PDV.Curse.State" mirror the Redguard vampire-reentry gate
    ; and the diegetic director read. The two could be left disagreeing. Re-sync the mirror
    ; rather than routing the restore through the transition handler: the state has been put
    ; back where it started, so nothing should re-fire a curse-onset surface for it.
    if PDV_Manager
        PDV_Manager.ResyncCurseStateMirror("mcm_scaffold_restore")
    endIf
    Debug.Trace("[PDV] MCM ScaffoldSmoke: curse " + oldState + " -> " + adjustedState + " -> " + PDV_CurseStateService.GetCurseState())
    return "Curse ok"
EndFunction

PDV_ReputationTrack Function GetFirstReputationTrack()
    if !PDV_FLST_RepTracks_All || PDV_FLST_RepTracks_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_RepTracks_All.GetAt(0) as PDV_ReputationTrack
EndFunction

PDV_StateTrack Function GetFirstStateTrack()
    if !PDV_FLST_StateTracks_All || PDV_FLST_StateTracks_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_StateTracks_All.GetAt(0) as PDV_StateTrack
EndFunction

PDV_SubstrateBase Function GetFirstSubstrate()
    if !PDV_FLST_Substrates_All || PDV_FLST_Substrates_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_Substrates_All.GetAt(0) as PDV_SubstrateBase
EndFunction

PDV_DaedricPathBase Function GetFirstDaedricPath()
    if !PDV_FLST_DaedricPaths_All || PDV_FLST_DaedricPaths_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_DaedricPaths_All.GetAt(0) as PDV_DaedricPathBase
EndFunction

Int Function GetFormListCount(FormList listRef)
    if listRef
        return listRef.GetSize()
    endIf
    return 0
EndFunction

String Function GetCurseServiceLabel()
    if PDV_CurseStateService
        return PDV_CurseStateService.GetCurseStateLabel()
    endIf
    return "Missing"
EndFunction

String Function TierToLabel(Int tierValue)
    if tierValue == 3
        return "Champion"
    elseIf tierValue == 2
        return "Devoted"
    elseIf tierValue == 1
        return "Seeker"
    endIf
    return "None (0)"
EndFunction

String Function GetIndexLabel(Int indexValue)
    if indexValue < 0
        return "None"
    endIf
    return "" + indexValue
EndFunction

String Function FormatFloat(Float value)
    return "" + value
EndFunction

Float Function ClampFloat(Float value, Float minValue, Float maxValue)
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction

;/ =====================================================================
    B5 / fix-plan 9.1 -- stale option IDs, the dangerous one
    ---------------------------------------------------------------------
    PDV_MCM holds 171 _oid* variables and OnPageReset used to clear exactly
    two of them. SkyUI hands out option IDs SEQUENTIALLY PER PAGE, so an oid
    left over from a page visited earlier can numerically equal a live option
    on the page you are looking at now -- and OnOptionSelect / OnOptionSliderAccept
    dispatch through one flat, page-blind if-chain of == comparisons, so the
    FIRST stale match wins and the click lands on the wrong handler. Among the
    handlers reachable that way are destructive debug ones: ResetDaedricForDebug,
    DebugRenouncePath, the piety seeds.

    The authors had already met this bug and patched the two symptoms they saw
    (_oidModeToggle, _oidPrepareUninstall). This generalizes that fix instead of
    waiting for the next symptom: every _oid* goes back to -1 before a page is
    rebuilt, so a comparison can only match a control the current page actually
    registered.

    Generated from this file's own declaration list -- all 171, in name order.
    If a control is added, add its reset here too.
   ===================================================================== /;
Function ResetAllOptionIds()
    _oidAcceptCommitmentOffer = -1
    _oidAddBretonCurated = -1
    _oidAddBretonRenewable = -1
    _oidApplyBretonPractice = -1
    _oidApplyCuratedSignal = -1
    _oidApplyDomainSting = -1
    _oidApplyPiety = -1
    _oidApplyPietyToday = -1
    _oidArgonianPeople = -1
    _oidArgonianVoid = -1
    _oidBoethiahHonorableDuel = -1
    _oidBosmerBanditRoad = -1
    _oidBosmerBanditRoadSignal = -1
    _oidBosmerConfirmRite = -1
    _oidBosmerExchange = -1
    _oidBosmerExchangeSignal = -1
    _oidBosmerGreenPactViolation = -1
    _oidBosmerLivingStory = -1
    _oidBosmerLivingStorySignal = -1
    _oidBosmerOldContract = -1
    _oidBosmerPactPositiveSignal = -1
    _oidBosmerSeedVariety = -1
    _oidBretonGreenWay = -1
    _oidBretonHiddenArt = -1
    _oidBretonKnightsRoad = -1
    _oidCommitmentReset = -1
    _oidCommitmentSeedSignals = -1
    _oidCompatCC = -1
    _oidCompatRaceMapping = -1
    _oidCompatSurvival = -1
    _oidConcordatCompliance = -1
    _oidConcordatDefiance = -1
    _oidConcordatUnlockGate = -1
    _oidCurseProofRaceApply = -1
    _oidCurseProofRaceCycle = -1
    _oidCurseRefreshFromPlayer = -1
    _oidDaedricChampion = -1
    _oidDaedricDevoted = -1
    _oidDaedricGenericProbe = -1
    _oidDaedricLapse = -1
    _oidDaedricLiveRoute = -1
    _oidDaedricReset = -1
    _oidDaedricRouteAll = -1
    _oidDaedricSeeker = -1
    _oidDaedricSelectedPath = -1
    _oidDaedricShowSummary = -1
    _oidDaedricSignal = -1
    _oidDaedricStigma = -1
    _oidDebugClearPatron = -1
    _oidDebugLevel = -1
    _oidDebugPatronOverride = -1
    _oidDebugResetDeity = -1
    _oidDebugSetBroadWorship = -1
    _oidDecayPrimeEligible = -1
    _oidDecayPrimeGrace = -1
    _oidDecayRunPass = -1
    _oidDecayRunProofDays = -1
    _oidDeclineCommitmentOffer = -1
    _oidDiegeticD1 = -1
    _oidDisfavorBandToggle = -1
    _oidDisfavorBurst = -1
    _oidDisfavorClear = -1
    _oidDisfavorDomainCycle = -1
    _oidDisfavorEventId = -1
    _oidDisfavorShow = -1
    _oidDunmerHomeBonus = -1
    _oidDunmerPrayer = -1
    _oidEvaluateCommitmentOffer = -1
    _oidExportReport = -1
    _oidFavorExpire = -1
    _oidFavorFamilyCycle = -1
    _oidFavorLaneCycle = -1
    _oidFavorTrigger = -1
    _oidFireDislike = -1
    _oidForceCurseNone = -1
    _oidForceCurseVampire = -1
    _oidForceCurseWerewolf = -1
    _oidForceSelectedPatron = -1
    _oidHircineHuntRite = -1
    _oidHircineRenounce = -1
    _oidHircineReset = -1
    _oidInGameEffects = -1
    _oidJournalHotkey = -1
    _oidKhajiitCaravanAid = -1
    _oidKhajiitFocusAlkosh = -1
    _oidKhajiitFocusBaanDar = -1
    _oidKhajiitFocusRajhin = -1
    _oidKhajiitLegendMade = -1
    _oidKhajiitLunarBudgetShow = -1
    _oidKhajiitLunarReset = -1
    _oidKhajiitLunarSeedT2 = -1
    _oidKhajiitLunarSeedT3 = -1
    _oidKhajiitMoonObservance = -1
    _oidKhajiitPostureCycle = -1
    _oidKhajiitRoadHome = -1
    _oidMephalaWebWoven = -1
    _oidModeToggle = -1
    _oidNpcRecognition = -1
    _oidNpcHostileRecognition = -1
    _oidNeglectRunPass = -1
    _oidNordNineDivines = -1
    _oidNordOldWays = -1
    _oidNotifications = -1
    _oidToastSize = -1
    _oidOpenJournalNow = -1
    _oidOrcCity = -1
    _oidOrcLegionExile = -1
    _oidOrcStronghold = -1
    _oidPacingBroadCatchup = -1
    _oidPacingBroadFanout = -1
    _oidPacingBroadMigration = -1
    _oidPacingBroadPool = -1
    _oidPacingBroadReset = -1
    _oidPacingBroadScratchNegative = -1
    _oidPacingBroadScratchPositive = -1
    _oidPacingBroadSeed24 = -1
    _oidPacingBroadSeed25 = -1
    _oidPacingBroadSeed49 = -1
    _oidPacingBroadSeed50 = -1
    _oidPacingBroadStatus = -1
    _oidPacingImperialCure = -1
    _oidPacingImperialVampire = -1
    _oidPacingNordBaseline = -1
    _oidPacingNordBaselineApply = -1
    _oidPacingPatronAccept = -1
    _oidPacingPatronLapse = -1
    _oidPacingPatronOffer = -1
    _oidPacingPatronRecover = -1
    _oidPacingPatronStatus = -1
    _oidPacingSetBroad = -1
    _oidPacingSubstrateOrigin = -1
    _oidPacingSubstrateOriginApply = -1
    _oidPacingSubstrateReset = -1
    _oidPacingSubstrateSeed0 = -1
    _oidPacingSubstrateSeed24 = -1
    _oidPacingSubstrateSeed25 = -1
    _oidPacingSubstrateSeed74 = -1
    _oidPacingSubstrateSeed75 = -1
    _oidPacingSubstrateSource = -1
    _oidPacingSubstrateStatus = -1
    _oidPacingSubstrateTrigger = -1
    _oidPanelHotkey = -1
    _oidPendingBretonPractice = -1
    _oidPendingPiety = -1
    _oidPendingPietyToday = -1
    _oidPendingSignalType = -1
    _oidPrepareUninstall = -1
    _oidPrimeNeglectEligible = -1
    _oidPrimeRaceLaneNeglect = -1
    _oidQuestReactionPerformanceSweep = -1
    _oidQuestReactionQueueStatus = -1
    _oidReDetectOrigin = -1
    _oidRefuseCommitmentOffer = -1
    _oidReloadQuestMatrix = -1
    _oidRepairStats = -1
    _oidResetBretonPractice = -1
    _oidRunDawn = -1
    _oidRunScaffoldApiSmoke = -1
    _oidSeedBroadLane = -1
    _oidSelectedDeity = -1
    _oidShowBretonPractice = -1
    _oidShowDecaySummary = -1
    _oidShowPatternSummary = -1
    _oidShowPietyMap = -1
    _oidShowStatResidue = -1
    _oidShowStructuralMap = -1
    _oidSignalFloorRun = -1
    _oidSignalFloorScenario = -1
    _oidSurveyDevotion = -1
    _oidTalosBetrayalCompliance = -1
    _oidTalosBetrayalMajor = -1
    _oidTalosShrineDefiance = -1
EndFunction
