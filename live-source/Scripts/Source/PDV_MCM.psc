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
FormList Property PDV_FLST_AllDeities Auto
FormList Property PDV_FLST_RepTracks_All Auto
FormList Property PDV_FLST_StateTracks_All Auto
FormList Property PDV_FLST_Substrates_All Auto
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
Float Property SIGNAL_TYPE_MAX = 999.0 AutoReadOnly

String Property PAGE_PLAYER = "Player" AutoReadOnly
String Property PAGE_COMPAT = "Compatibility" AutoReadOnly
String Property PAGE_STATUS = "Status" AutoReadOnly
String Property PAGE_DEBUG = "Debug: State & Rewards" AutoReadOnly
String Property PAGE_DEBUG2 = "Debug: Daedric & Curse" AutoReadOnly

Int _oidSurveyDevotion = -1
Int _oidExportReport = -1
Int _oidDeveloperOptions = -1
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
Int _oidPrepareUninstall = -1
Int _oidPendingSignalType = -1
Int _oidApplyCuratedSignal = -1
Int _oidRunDawn = -1
Int _oidShowPietyMap = -1
Int _oidShowStructuralMap = -1
Int _oidRunScaffoldApiSmoke = -1
Int _oidReloadQuestMatrix = -1
Int _oidDiegeticD1 = -1
Int _oidShowPatternSummary = -1
Int _oidConcordatDefiance = -1
Int _oidConcordatCompliance = -1
Int _oidTalosShrineDefiance = -1
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
Int _oidCurseOriginCycle = -1
Int _oidCurseOriginApply = -1
Int _oidForceCurseNone = -1
Int _oidForceCurseWerewolf = -1
Int _oidForceCurseVampire = -1
Int _oidNeglectRunPass = -1
Int _oidDecayPrimeGrace = -1
Int _oidDecayPrimeEligible = -1
Int _oidDecayRunPass = -1
Int _oidDecayRunProofDays = -1
Int _oidShowDecaySummary = -1
Int _oidCompatRaceMapping = -1
Int _oidCompatSurvival = -1
Int _oidCompatCC = -1
Int _oidReDetectOrigin = -1
Int _oidOpenJournalNow = -1
Int _oidJournalHotkey = -1
Int _oidPanelHotkey = -1

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
Float _pendingPiety = 10.0
Float _pendingPietyToday = 1.0
Int _pendingSignalType = 103
Int _selectedCurseOrigin = 0

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
    Parent.OnGameReload()
EndFunction

Function OnConfigInit()
    InitializePages()
    RegisterJournalHotkey()
EndFunction

Function RegisterJournalHotkey()
    Int savedKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    if savedKey >= 0
        RegisterForKey(savedKey)
    endIf
    Int savedPanelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    if savedPanelKey >= 0
        RegisterForKey(savedPanelKey)
    endIf
EndFunction

Int Function GetVersion()
    return 1
EndFunction

Function OnPageReset(String a_page)
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
    elseIf a_option == _oidDeveloperOptions
        SetInfoText("Shows the development Status and Debug pages for testing.")
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
    elseIf a_option == _oidPendingSignalType
        SetInfoText("Choose the curated signal ID to apply to the selected deity. Talos uses 101, 102, and 103. Auri-El uses 201 and 202.")
    elseIf a_option == _oidApplyCuratedSignal
        SetInfoText("Routes the chosen curated signal through the manager so stance and rivalry apply normally.")
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
        SetInfoText("Clears pending commitment, cooldown, rupture, carry-over, and seeded signal days for the selected deity.")
    elseIf a_option == _oidAcceptCommitmentOffer
        SetInfoText("Accepts the pending commitment offer and applies carry-over behavior.")
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
    elseIf a_option == _oidCurseOriginCycle
        SetInfoText("Cycles the origin used for curse race-handler proof. Apply it with the next button.")
    elseIf a_option == _oidCurseOriginApply
        SetInfoText("Writes the selected curse-test origin into PDV_GLO_OriginRace for backend race-handler smoke.")
    elseIf a_option == _oidForceCurseNone
        SetInfoText("Backend-forces the shared curse service to None for cure and residue smoke.")
    elseIf a_option == _oidForceCurseWerewolf
        SetInfoText("Backend-forces the shared curse service to Werewolf for Hircine entry smoke.")
    elseIf a_option == _oidForceCurseVampire
        SetInfoText("Backend-forces the shared curse service to Vampire for the Hircine negative path.")
    elseIf a_option == _oidNeglectRunPass
        SetInfoText("Runs only the neglect/spell-layer selection pass without the rest of dawn.")
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
        SetInfoText("Best-effort cleanup for a throwaway uninstall save. Save first. A pre-install save is the only fully clean removal.")
    elseIf a_option == _oidKhajiitFocusBaanDar || a_option == _oidKhajiitFocusRajhin || a_option == _oidKhajiitFocusAlkosh
        SetInfoText("Forces the Khajiit emergent focus to this moon-path so its tier reward becomes testable. Then force piety and Run Dawn to light the Champion blessing.")
    elseIf a_option == _oidBretonKnightsRoad || a_option == _oidBretonHiddenArt || a_option == _oidBretonGreenWay
        SetInfoText("Forces the Breton tradition so its tradition-gated reward family becomes testable. Then force piety and Run Dawn.")
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
                ShowMessage("Devotion report saved as '" + reportFile + "' in your Skyrim game folder (same folder as SkyrimSE.exe). Attach that file to your bug report. If you cannot find it, search your PC for " + reportFile + ".", False, "$OK", "")
            else
                ShowMessage("Could not write the report file. PapyrusUtil may be missing or the folder is read-only.", False, "$OK", "")
            endIf
        else
            ShowMessage("Devotion is still starting up. Wait a moment and try again.", False, "$OK", "")
        endIf
        return
    endIf

    if a_option == _oidDeveloperOptions
        ToggleDeveloperOptions()
        ForcePageReset()
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

    if a_option == _oidSeedBroadLane
        if ShowMessage("Seed the current race's broad-worship lane to Faithful (sets broad worship + the broad accumulator so the broad Fortify-Health applies)?", True, "$Yes", "$No")
            PDV_Manager.DebugSeedBroadLane()
            ForcePageReset()
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
        RunPatternAction("Set the Breton tradition to Knights Road?", 46)
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

    if a_option == _oidCurseOriginCycle
        CycleCurseTestOrigin()
        ForcePageReset()
        return
    endIf

    if a_option == _oidCurseOriginApply
        RunPatternAction("Apply the selected curse-test origin?", 37)
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

    if a_option == _oidNeglectRunPass
        RunPatternAction("Run the neglect/spell-layer pass now?", 38)
        return
    endIf

    if a_option == _oidDecayPrimeGrace
        RunPatternAction("Prime selected deity inside the decay grace window?", 39)
        return
    endIf

    if a_option == _oidDecayPrimeEligible
        RunPatternAction("Prime selected deity as eligible for decay?", 40)
        return
    endIf

    if a_option == _oidDecayRunPass
        RunPatternAction("Run the decay-only pass now?", 41)
        return
    endIf

    if a_option == _oidDecayRunProofDays
        RunPatternAction("Run compressed decay proof days for selected deity?", 42)
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
        StorageUtil.SetIntValue(None, "PDV.Panel.Hotkey", a_keyCode)
        if a_keyCode >= 0
            RegisterForKey(a_keyCode)
        endIf
        SetKeyMapOptionValue(_oidPanelHotkey, a_keyCode, False)
    endIf
EndFunction

Event OnKeyDown(Int a_keyCode)
    Int panelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    if panelKey >= 0 && a_keyCode == panelKey
        ; Open the focused interactive dashboard panel. A focused panel can't receive the
        ; hotkey to toggle closed (it puts the game in menu mode), so this is OPEN ONLY --
        ; the in-view X button / ESC close it via the bridge's PDVPanelClose listener.
        if Utility.IsInMenuMode()
            return
        endIf
        if !EnsureManagerBinding("panel_hotkey")
            return
        endIf
        Debug.Notification("The Devotion panel opens.")
        ; Player-owned UI entry point: push fresh panel data, then focus the view so the
        ; dashboard filter buttons are clickable. Close is in-view (X button / ESC ->
        ; the bridge's PDVPanelClose listener: Unfocus + Hide).
        PDV_Manager.PushDevotionPanel(True)
        PDV_PrismaBridge.OpenDevotionPanel()
        return
    endIf
    Int journalKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    if a_keyCode != journalKey
        return
    endIf
    if journalKey < 0
        return
    endIf
    if Utility.IsInMenuMode()
        return
    endIf
    if !EnsureManagerBinding("journal_hotkey")
        return
    endIf
    ; Player-pressed toggle: first press opens the rolling Chronicle, second press
    ; closes it. The analytical Ledger lives in the focused panel, not as the next
    ; hotkey state, so the Book stays a rolling log.
    ; The view is a NON-FOCUSED overlay (SendOverlayJson), so the close is driven by
    ; this hotkey, not an in-view button. True is the player-owned bypass of the
    ; gameplay default-off gate (see pdv_prisma_ui_audit). The open flag is reset in
    ; OnGameReload so a load (which closes the overlay) cannot leave it stuck "open".
    Int journalState = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Open")
    if journalState == 0
        StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 1)
        Debug.Notification("The Book of Days opens.")
        PDV_Manager.SendPrismaJournalPayload(True)
    else
        StorageUtil.SetIntValue(None, "PDV.Diegetic.Journal.Open", 0)
        Debug.Notification("The Book of Days closes.")
        PDV_Manager.ClosePrismaJournal()
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

    if a_option == _oidPendingSignalType
        SetSliderDialogStartValue(_pendingSignalType as Float)
        SetSliderDialogDefaultValue(_pendingSignalType as Float)
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

    if a_option == _oidPendingSignalType
        _pendingSignalType = ClampSignalType(a_value as Int)
        SetSliderOptionValue(_oidPendingSignalType, _pendingSignalType as Float, "{0}", False)
    endIf
EndFunction

Function BuildPlayerPage()
    ResetBookOfDaysOptionIds()
    EnsureManagerBinding("build_player_page")
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Devotion", OPTION_FLAG_NONE)

    if EnsureManagerBinding("player_page")
        AddTextOption("Summary", PDV_Manager.GetPlayerMcmSummaryLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Startup", PDV_Manager.GetStartupMcmLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Mode", PDV_Manager.GetPlayerMcmModeLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Patron", PDV_Manager.GetPlayerMcmPatronLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Standing", PDV_Manager.GetPlayerMcmStandingLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Curse", PDV_Manager.GetPlayerMcmCurseLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Favor", PDV_Manager.GetPlayerMcmFavorLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Neglect", PDV_Manager.GetPlayerMcmNeglectLine(), OPTION_FLAG_DISABLED)
        _oidSurveyDevotion = AddTextOption("Survey Devotion", "Open readout", OPTION_FLAG_NONE)
        _oidExportReport = AddTextOption("Export Devotion Report", "Write file", OPTION_FLAG_NONE)

        ; Khajiit focus emerges silently, so surface each moon-path's standing and
        ; piety here for the player to track without a formal patron offer.
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
    AddHeaderOption("Options", OPTION_FLAG_NONE)
    _oidDeveloperOptions = AddTextOption("Developer Options", GetDeveloperPageStateLabel(), OPTION_FLAG_NONE)
    AddTextOption("Status page", GetDeveloperPageStateLabel(), OPTION_FLAG_DISABLED)
    AddTextOption("Debug page", GetDeveloperPageStateLabel(), OPTION_FLAG_DISABLED)

    AddHeaderOption("Book of Days", OPTION_FLAG_NONE)
    _oidOpenJournalNow = AddTextOption("Open Book of Days", "Open now", OPTION_FLAG_NONE)
    Int currentJournalKey = StorageUtil.GetIntValue(None, "PDV.Diegetic.Journal.Hotkey", -1)
    _oidJournalHotkey = AddKeyMapOption("Book of Days key", currentJournalKey, OPTION_FLAG_NONE)
    Int currentPanelKey = StorageUtil.GetIntValue(None, "PDV.Panel.Hotkey", -1)
    _oidPanelHotkey = AddKeyMapOption("Open Devotion panel", currentPanelKey, OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
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
        AddTextOption("Summary", PDV_Manager.GetPlayerMcmSummaryLine(), OPTION_FLAG_DISABLED)
        AddTextOption("Startup", PDV_Manager.GetStartupMcmLine(), OPTION_FLAG_DISABLED)
        _oidSurveyDevotion = AddTextOption("Survey Devotion", "Open readout", OPTION_FLAG_NONE)
    else
        AddTextOption("Summary", "Devotion is still starting up.", OPTION_FLAG_DISABLED)
    endIf

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function BuildCompatPage()
    EnsureManagerBinding("build_compat_page")
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
    AddHeaderOption("Custom Race", OPTION_FLAG_NONE)
    _oidCompatRaceMapping = AddTextOption("Custom race mapping", OnOffLabel(CustomRaceMappingEnabled()), OPTION_FLAG_NONE)
    AddTextOption("Detected", GetCompatRaceReadout(), OPTION_FLAG_DISABLED)
    _oidReDetectOrigin = AddTextOption("Re-detect origin", "Run now", OPTION_FLAG_NONE)
    AddTextOption("Temporary forms", "Defer origin capture", OPTION_FLAG_DISABLED)

    SetCursorPosition(1)
    AddHeaderOption("Survival Context", OPTION_FLAG_NONE)
    _oidCompatSurvival = AddTextOption("Survival integration", OnOffLabel(SurvivalContextEnabled()), OPTION_FLAG_NONE)
    AddTextOption("Status", GetCompatSurvivalReadout(), OPTION_FLAG_DISABLED)
    AddHeaderOption("AE / Creation Club", OPTION_FLAG_NONE)
    AddTextOption("AE/CC content", "Encouraged optional", OPTION_FLAG_DISABLED)
    _oidCompatCC = AddTextOption("CC integration", OnOffLabel(CCContentEnabled()), OPTION_FLAG_NONE)
    AddTextOption("Detected", GetCompatCCReadout(), OPTION_FLAG_DISABLED)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

String Function OnOffLabel(Bool isOn)
    if isOn
        return "On"
    endIf
    return "Off"
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
    _oidSeedBroadLane = AddTextOption("Seed broad lane (origin)", "Broad + 6 acts", OPTION_FLAG_NONE)
    _oidPendingPietyToday = AddSliderOption("Target scratch", _pendingPietyToday, "{1}", OPTION_FLAG_NONE)
    _oidApplyPietyToday = AddTextOption("Apply target scratch", FormatFloat(_pendingPietyToday), OPTION_FLAG_NONE)
    _oidPendingSignalType = AddSliderOption("Curated signal ID", _pendingSignalType as Float, "{0}", OPTION_FLAG_NONE)
    _oidApplyCuratedSignal = AddTextOption("Apply curated signal", GetSelectedSignalLabel(), OPTION_FLAG_NONE)

    AddEmptyOption()
    AddHeaderOption("Actions", OPTION_FLAG_NONE)
    _oidPrepareUninstall = AddTextOption("Prepare for uninstall", "Strip + stop", OPTION_FLAG_NONE)
    _oidRunDawn = AddTextOption("Run dawn pass", "Consolidate scratch", OPTION_FLAG_NONE)
    _oidShowPatternSummary = AddTextOption("Show pattern summary", "Paged readout", OPTION_FLAG_NONE)
    _oidShowPietyMap = AddTextOption("Show piety map", "Message", OPTION_FLAG_NONE)
    _oidShowStructuralMap = AddTextOption("Show structural map", "Message", OPTION_FLAG_NONE)
    _oidRunScaffoldApiSmoke = AddTextOption("Run scaffold smoke", "API set/read/reset", OPTION_FLAG_NONE)
    _oidReloadQuestMatrix = AddTextOption("Reload quest matrix", "Re-read JSON", OPTION_FLAG_NONE)
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
    _oidBretonKnightsRoad = AddTextOption("Breton -> Knights Road", "Tradition", OPTION_FLAG_NONE)
    _oidBretonHiddenArt = AddTextOption("Breton -> Hidden Art", "Tradition", OPTION_FLAG_NONE)
    _oidBretonGreenWay = AddTextOption("Breton -> Green Way", "Tradition", OPTION_FLAG_NONE)
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
    _oidCurseOriginCycle = AddTextOption("Cycle curse origin", GetCurseOriginOptionLabel(), OPTION_FLAG_NONE)
    _oidCurseOriginApply = AddTextOption("Apply curse origin", "Write origin global", OPTION_FLAG_NONE)
    _oidForceCurseNone = AddTextOption("Curse none", "Human baseline", OPTION_FLAG_NONE)
    _oidForceCurseWerewolf = AddTextOption("Curse werewolf", "Backend force", OPTION_FLAG_NONE)
    _oidForceCurseVampire = AddTextOption("Curse vampire", "Backend force", OPTION_FLAG_NONE)

    ; --- Right column: race signals + neglect/decay + commitment ---
    SetCursorPosition(1)
    AddHeaderOption("Race signals", OPTION_FLAG_NONE)
    _oidConcordatDefiance = AddTextOption("Concordat defiance", "EventBus route", OPTION_FLAG_NONE)
    _oidConcordatCompliance = AddTextOption("Concordat compliance", "EventBus route", OPTION_FLAG_NONE)
    _oidTalosShrineDefiance = AddTextOption("Talos shrine defiance", "Shrine route", OPTION_FLAG_NONE)
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

    AddEmptyOption()
    AddHeaderOption("Neglect & decay", OPTION_FLAG_NONE)
    _oidNeglectRunPass = AddTextOption("Run neglect pass", "Targeted", OPTION_FLAG_NONE)
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
    _oidAcceptCommitmentOffer = AddTextOption("Accept commitment", "Carry-over", OPTION_FLAG_NONE)
    _oidDeclineCommitmentOffer = AddTextOption("Decline commitment", "Postpone", OPTION_FLAG_NONE)
    _oidRefuseCommitmentOffer = AddTextOption("Refuse commitment", "Cooldown", OPTION_FLAG_NONE)

    SetCursorFillMode(LEFT_TO_RIGHT)
EndFunction

Function InitializePages()
    ModName = "Devotion"
    String[] configuredPages = new String[5]
    configuredPages[0] = PAGE_PLAYER
    configuredPages[1] = PAGE_COMPAT
    configuredPages[2] = PAGE_STATUS
    configuredPages[3] = PAGE_DEBUG
    configuredPages[4] = PAGE_DEBUG2
    Pages = configuredPages
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
    return StorageUtil.GetIntValue(None, "PDV.UI.DeveloperOptions") == 1
EndFunction

Function ToggleDeveloperOptions()
    if DeveloperOptionsEnabled()
        StorageUtil.SetIntValue(None, "PDV.UI.DeveloperOptions", 0)
    else
        StorageUtil.SetIntValue(None, "PDV.UI.DeveloperOptions", 1)
    endIf
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

Function CycleCurseTestOrigin()
    if _selectedCurseOrigin == 0
        _selectedCurseOrigin = 4
    elseIf _selectedCurseOrigin == 4
        _selectedCurseOrigin = 2
    elseIf _selectedCurseOrigin == 2
        _selectedCurseOrigin = 5
    elseIf _selectedCurseOrigin == 5
        _selectedCurseOrigin = 3
    else
        _selectedCurseOrigin = 0
    endIf
EndFunction

String Function GetCurseOriginOptionLabel()
    if _selectedCurseOrigin == 0
        return "Nord"
    elseIf _selectedCurseOrigin == 4
        return "Bosmer"
    elseIf _selectedCurseOrigin == 2
        return "Breton"
    elseIf _selectedCurseOrigin == 5
        return "Dunmer"
    elseIf _selectedCurseOrigin == 3
        return "Altmer"
    endIf

    return "" + _selectedCurseOrigin
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
    PDV__ManagerQuest manager = GetManagerService()
    if !manager
        ShowMessage("PDV_Manager is not assigned.", False, "$OK", "")
        return
    endIf

    if !ShowMessage(promptText, True, "$Yes", "$No")
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
        manager.DebugSetOriginRace(_selectedCurseOrigin)
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
    output = output + "; Sacred=" + GetFormListCount(PDV_FLST_SacredPlaces_All)
    output = output + "; Daedric=" + GetFormListCount(PDV_FLST_DaedricPaths_All)
    output = output + "; Curse=" + GetCurseServiceLabel()
    return output
EndFunction

String Function RunScaffoldApiSmoke()
    String output = RunReputationTrackSmoke()
    output = output + "; " + RunStateTrackSmoke()
    output = output + "; " + RunSubstrateSmoke()
    output = output + "; " + RunSacredPlaceSmoke()
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
    substrate.AdjustMetric(1.0, "mcm_scaffold_smoke")
    Float adjustedMetric = substrate.GetMetric()
    substrate.ResetForDebug()
    substrate.SetMetric(oldMetric, "mcm_scaffold_restore")
    Debug.Trace("[PDV] MCM ScaffoldSmoke: substrate " + substrate.SubstrateName + " " + oldMetric + " -> " + adjustedMetric + " -> " + substrate.GetMetric())
    return "Substrate ok"
EndFunction

String Function RunSacredPlaceSmoke()
    PDV_SacredPlace place = GetFirstSacredPlace()
    if !place
        return "Sacred missing"
    endIf

    Float oldDecay = place.GetMissedVisitDecay()
    place.DebugForceMissedVisitDecay(oldDecay + 1.0)
    Float adjustedDecay = place.GetMissedVisitDecay()
    place.DebugForceMissedVisitDecay(oldDecay)
    Debug.Trace("[PDV] MCM ScaffoldSmoke: sacred place " + place.PlaceName + " " + oldDecay + " -> " + adjustedDecay + " -> " + place.GetMissedVisitDecay())
    return "Sacred ok"
EndFunction

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

PDV_SacredPlace Function GetFirstSacredPlace()
    if !PDV_FLST_SacredPlaces_All || PDV_FLST_SacredPlaces_All.GetSize() <= 0
        return None
    endIf
    return PDV_FLST_SacredPlaces_All.GetAt(0) as PDV_SacredPlace
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
