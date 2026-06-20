# 2026-06-20 Redguard Ash'abah mid-game entry fix snapshot

POST-edit snapshot of the untracked live scripts after wiring mid-game entry into the
Redguard **Ash'abah** sect. Papyrus-only; both files compile 0/0, verifier FAIL=0
(PASS=3057; the 3 WARNs are the pre-existing SEQ-freshness ones, not from this change).

## The gap (pre-existing, not a Requiem-build regression)
Mid-game entry into the Ash'abah sect was **unreachable**. The sect-switch in
`RecordRedguardSectSignal` gates the Ash'abah branch on `IsRedguardAshAbahBurden(reason)`,
which only accepts the marked tokens `"redguard_ashabah_burden"` /
`"redguard_deathduty_major"`. But **no caller ever produced** those tokens: the live
death-duty path (`PDV_EventBus.RouteRedguardAshAbahDeathDuty` ->
`HandleRedguardAshAbahDeathDuty`) is always invoked with `"eventbus_<N>"`. So organically
the gate could never fire; only the startup choice (`ApplyRedguardInitialChoice`) set
Ash'abah. Design intent (PDV_OpenDecisions_RulingMemo / TargetEndStates): "Ash'abah is
entered only by a marked death/funerary burden -- major tombs, major necromancer
operations, lich/named-undead defeats, costly impurity choices."

This is the **same exact-match-on-an-unproduced-token failure class as the P2 book-notice
suffix bug** (gate correct, token never emitted).

## The fix
- **New emitter `PDV_Manager.HandleRedguardAshAbahMajorBurden(victimForm, eventType)`**
  (`PDV__ManagerQuest.psc`): the missing **producer** of the marked token. On the player's
  own killing blow against a **UNIQUE (named/boss) undead** -- the clean, iconic
  lich/named-undead moment, the undead analog of HoonDing's dragon make-way -- it routes a
  death-duty with reason `"redguard_deathduty_major"`, which the (already-correct) gate
  accepts, so a genuine named-undead defeat **marks sect entry**. V1 uses the in-engine
  `ActorBase.IsUnique()` flag as the "named undead" signal -- **no new ESP record**.
  Routine draugr/skeletons are not Unique, so casual undead fighting still cannot switch
  sect ("casual undead fighting is not enough").
- **Independent daily anti-farm** (`PDV.Signal.RedguardAshAbahMajorBurden` via
  `ConsumeDailyRepeatMultiplier`), separate from routine duty, so a real named-undead
  defeat reliably marks the burden even on a day routine death-duty already decayed.
- **Shared rewards helper `ApplyRedguardAshAbahDutyRewards(reason)`**: the routine duty and
  the marked major burden both fire the Tu'whacca death-rite signal + flat heal + social
  stigma through one helper so the two paths cannot drift.
- **Gate hardened** (`IsRedguardAshAbahBurden`): exact-match -> `StringContainsToken`, so a
  future emit site that appends a source suffix (e.g. `"redguard_deathduty_major_krosis"`)
  still satisfies it. Suffix/omission-proof per the P2 book-notice fix.
- **Hook** (`PDV_ActionRouter.HandleStoryKillActor`): new call alongside
  `HandleHoonDingBreakthroughKill`, on the player's own classified hostile kill.

## In-game proof (pending)
Route/runtime proof is achievable with the QASmoke **Ash'abah duty** REFR + a unique-undead
kill; the load-bearing manual proof is: as a Crown/Forebear Redguard, land the killing blow
on a named undead (e.g. a Dragon Priest) and confirm the sect flips to Ash'abah with the
entry notice. Magnitudes/anti-farm decay PROVISIONAL. Tracker:
`PDV_RequiemSmokeTest_Tracker.md`; run-sheet gotcha (the now-fixed gap):
`references/authoring/PDV_RunSheet_Redguard_BetaFeel.md`.

## DEFERRED (curated follow-up, same class as HoonDing's deferred named-boss FormList, task #11)
- The rest of the design list -- **major tombs**, **named necromancer leaders** (living
  humanoids, classified humanoid not undead), **costly impurity choices** -- needs curated
  FormLists / faction detection. V1 covers only "lich/named-undead defeats" via the Unique
  flag.
