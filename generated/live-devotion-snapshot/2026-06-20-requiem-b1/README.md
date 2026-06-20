# 2026-06-20 Requiem Build B1 snapshot

POST-edit snapshot of the untracked live PDV__ManagerQuest.psc after Build B1
(Requiem-regen conversion, batch B1). The live manager is NOT in git; this is the
git-tracked copy that survives a mod restore.

B1 content (all in PDV__ManagerQuest.psc; compiled 0/0, verify FAIL=0, reward
readback FAIL=1 [only the unrelated GreenPact KID]):
- Redguard Tu'whacca T2/T3: swallowed HealRateMult removed from spec + ESP; flat
  event-driven death-rite heal added (TryRedguardTuwhaccaDeathRiteHeal, tier-gated
  Devoted 30 / Champion 50 HP, once/day), called from HandleRedguardAshAbahDeathDuty
  and HandleRedguardFarShoresToken.
- Ash'abah stigma (text-only, no piety penalty): MarkRedguardAshAbahStigma +
  GetAshAbahStigmaLabel, surfaced in GetRedguardSurveySectText, marked-moment notice
  on a marked burden.
- Daedric Namira heal-on-feed lifesteal (TryNamiraFeedHeal on the Namira.cannibalism
  faucet in ApplyQuestReactionFaucet; tier-scaled 20/30/40 HP, daily soft-decay).
  NOTE: the Daedric CONTRACT cleanup (remove inert HealRateMult boon + fix text) +
  Daedric ESP re-author are DEFERRED to the Daedric batch (task #10).

Magnitudes PROVISIONAL -- tune in-game under a Requiem list.
