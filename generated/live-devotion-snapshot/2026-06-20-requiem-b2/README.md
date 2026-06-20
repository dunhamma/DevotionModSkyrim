# 2026-06-20 Requiem Build B2 snapshot (HoonDing make-way rebuild)

POST-edit snapshot of the untracked live scripts after Build B2 (HoonDing make-way
rebuild). Papyrus-only; all three compile 0/0, verify FAIL=0.

B2 content (user ruling 2026-06-20):
- Standard make-way (signal 2501) RETARGETED off the mis-wired Forebear road-passage
  onto curated BREAKTHROUGH kills. V1 qualifies on the player's own DRAGON kills
  (PDV_ActionRouter.HandleStoryKillActor -> PDV_Manager.HandleHoonDingBreakthroughKill,
  eventType 302 = EVT_KILL_DRAGON).
- Road-passage REROUTED to the Forebear lane only (AwardRedguardForebearSignal: the
  HoonDing branch removed; Forebear sect substrate credit already recorded by the
  caller; Leki sword-singing kept). Old weekly cap (PDV.Redguard.HoonDingMakeWayWeek)
  RETIRED.
- Anti-farm = dragon daily soft-decay (ConsumeDailyRepeatMultiplier
  "PDV.Signal.HoonDingDragon"); every genuine make-way registers, a dragon-farm day
  diminishes.
- Redundant Champion signal 2502 (SIGNAL_MAKE_WAY_CHAMPION / DELTA_MAKE_WAY_CHAMPION)
  RETIRED (it was dead code -- defined in the deity, never awarded).

DEFERRED to the creation-authoring/capstone session (task #11):
- HoonDing Champion cheat-death "the way is made" survival save (attach
  PDV_T3DailyLowHealthSaveEffect to the HoonDing Champion reward MGEF, extra effect,
  HoonDing StorageKey) -- ESP/CK work, same class as the deferred Nord re-attach.
- Named-boss / major-quest-milestone / final-boss make-way qualification -- needs a
  curated FormList (ESP). Combat-odds detection stays post-1.0.
