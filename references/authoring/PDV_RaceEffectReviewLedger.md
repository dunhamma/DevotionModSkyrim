# PDV Race Effect Review Ledger

**Created:** 2026-05-31
**Status:** Required review gate before broad race reward authoring

## Purpose

This ledger keeps the first CAT-6 effect pilot from becoming accidental reward
policy. `PDV_Bless_Khajiit_Lunar_T1` is allowed as a real, provisional,
record/readback-proven effect packet. It does not approve full race reward
authoring, grant timing, magnitudes, or stack behavior for Khajiit or any other
race.

Before broad reward authoring, each race needs a holistic effect review across
theme, gameplay role, magnitude, conditions, stacking, grant/removal behavior,
Survey/status explanation, anti-farm posture, curse interaction, and Daedric
interaction.

## Review Rules

- Do not broaden CAT-6 from one passive pilot into race-wide promotion until
  the affected race has a completed row in this ledger.
- Treat all magnitudes as provisional until the race row is reviewed.
- Conditions must match player-facing text. If the effect is night-only, the
  copy must say night-only.
- Every steady reward needs a removal or suppression story before it can be
  granted by manager logic.
- Each race should have a floor effect that supports ordinary play and a
  ceiling effect that cannot stack into a third loud reward package.
- Curse and Daedric modifiers must be reviewed with the race effect set, not
  bolted on afterward.
- Survey/MCM copy must explain the active state in fiction-facing terms without
  turning effect mechanics into debug counters.

## Pilot Exception

`PDV_Bless_Khajiit_Lunar_T1` is the only approved exception before this ledger
is complete.

Current pilot mechanics:

- Source row: `PDV_Bless_Khajiit_Lunar_T1`.
- Spell: `PDV_Bless_Khajiit_Lunar_T1`.
- Effects:
  - `PDV_MGEF_Bless_Khajiit_Lunar_T1_StaminaRegen`: `StaminaRateMult +5`.
  - `PDV_MGEF_Bless_Khajiit_Lunar_T1_DiseaseResist`: `ResistDisease +10`.
- Condition: both effects are active from 7PM through 7AM.
- Grant state: intentionally unwired.
- Proof state: record/readback/text-match proof only, not Active Effects runtime
  proof and not reward-distribution proof.

## Race Review Table

| Race | Status | First Review Focus | Effect Questions To Lock |
|------|--------|--------------------|--------------------------|
| Altmer | Pending | Auri-El/Magnus scholar floor, crisis/recovery ceiling | What is the quiet positive floor before crisis pressure? Which favors are one-active only? How do Exiled vampire and werewolf halt suppress rewards? |
| Khajiit | Pilot-provisional | Lunar floor, road-home cadence, focus effects | Is night-only stamina/disease the right Tier 1 floor? Does the effect need road/moon/focus variants? How does ShadowDrift avoid becoming a free stealth stack? |
| Argonian | Pending | Hist/People floor before Void depth | What supports water/rest/community without swim or sleep farming? Which Void effects are pressure/stabilization rather than replacement theology? |
| Orc | Pending | Stronghold/city/Legion/exile labor dignity | Which effects reward quality forge/service without raw crafting or combat loops? How does exile remain playable without free Malacath stacking? |
| Redguard | Pending | Crown/Forebear/Ash'abah/Far Shores posture | Which effects respect undead/death-duty hooks without generic undead farming? Where does HoonDing cap escalation stop? |
| Bosmer | Pending | Old Contract, Living Story, Exchange, Bandit Road parity | Which path effects are distinct without four simultaneous reward packages? How do Z'en/Baan Dar effects avoid generic kindness/trade/theft faucets? |
| Breton | Audit-only pending | Covenant/Divines/Magnus/Witch edge stack | Which existing layers are already loud enough? What should remain audit-only until ceiling risk is understood? |
| Dunmer | Audit-only pending | Ancestor/Reclamation/House/Daedric pressure stack | How do ancestor substrate and Reclamation effects avoid overstacking with Daedric pressure? |
| Imperial | Audit-only pending | Civic Divines, Akatosh/Zenithar, broad worship | What prevents broad-worship reward density from becoming universal best-in-slot? |
| Nord | Audit-only pending | Fully felt control race and over-trigger audit | Which Kyne/Talos/Hircine/neglect layers are already at ceiling, and which generic hooks must stay silent? |

## Completion Bar Per Race

A race row is complete when it names:

- Approved floor effect family.
- Approved ceiling effect family.
- Magnitude range.
- Conditions and cadence.
- Grant and removal/suppression owner.
- Stack cap.
- Survey/status explanation.
- Rejected generic hooks.
- Curse/Daedric interaction.
- Manual feel note still needed before external beta.
