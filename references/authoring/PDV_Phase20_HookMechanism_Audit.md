# PDV Phase 20 Hook-Mechanism Audit (proof ACTI vs real hook)

**Created:** 2026-06-06
**Status:** Pre-scaling classification of all 30 Phase 20 proof activators
**Owner:** Companion to the per-race `PDV_Phase20*ImplementationCosting.manifest.json`, `PDV_PreBetaRaceScalingSpine.md`, `PDV_PreBetaRaceGateLedger.md`, and `PDV_Phase20_Altmer_EndToEnd_Closeout_Checklist.md`

## Why this file exists

Every Phase 20 race proof slice wired its routes to **ACTI activators** with
all-caps `RECORD X` / `PROVE X` activate text. That was the correct *proof*
shape — an activator is the cheapest universal way to prove a route reaches the
EventBus. It is **not** the real hook shape. Most of these surfaces are passive
or contextual in normal play; only a few are genuinely opt-in objects the player
chooses to use.

This audit classifies each surface so the scaling pass does not silently ship
"walk up and press E on a crisis" chore-religion, and so the per-race time
estimate accounts for passive-hook wiring instead of object placement.

Classification legend:

- **Object (opt-in):** a real placed activatable surface; activation is fine
  because using it is intentional devotion. Reuses `PDV_EventSignalActivator`.
- **Passive-event:** fires from a contextual gameplay act (kill/eat/help/theft/
  craft) with a quality/anti-farm gate. Reuses Story Manager receiver / event
  hooks; never a placed activator.
- **Passive-location:** fires on entering a cell/location. Story Manager Change
  Location node or trigger volume.
- **Passive-quest:** fires on a vanilla quest stage / milestone. Quest-stage
  hook with a save-persistent one-shot guard.
- **Passive-cadence:** evaluated automatically in the dawn pass / lunar cadence;
  no discrete trigger and no object.

Confidence: classifications are read from each manifest's intent plus the
`Normal-play hook` and `Rejected generic hooks` lines in
`PDV_PreBetaRaceScalingSpine.md`. `~` marks a judgment call worth confirming
during that race's scaling pass.

## Headline finding

Of 30 proof activators, only **~5-6 are real opt-in objects**. The rest are
passive (event / location / quest / cadence). The proof slice's uniform ACTI
shape masked this. Net effect on scope: less object-placement work than the
ACTI count implies, more event/quest/location wiring — but all of it reuses
patterns already runtime-proven (Phase 3 Story Manager receiver, Phase 7 quest
hooks, the dawn pass, OnSleepStop-style events).

## Altmer (P0)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 52 | dawn steadiness | **Object (opt-in)** | study/dawn surface the player chooses; keep as activator |
| 51 | dragonborn declaration | **Passive-quest** | first main-quest Dragonborn beat, one-shot |
| 50 | lorkhan / mortal pressure | **Passive-quest** ~ | Sovngarde/marriage/companions beat; not an activator |
| 53 | orthodox cost | **Passive-event** | consequence of orthodox enforcement; contextual, not an object |

(Altmer is fully worked in `PDV_Phase20_Altmer_EndToEnd_Closeout_Checklist.md`.)

## Khajiit (P1 first contrast)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 10 | moon observance | **Passive-cadence** | spine explicitly rejects "required visual moon inspection"; lunar cadence in the dawn pass |
| 33 | road-home anchor one | **Passive-location** ~ | arriving at a road-home anchor; location/trigger, possibly opt-in rest |
| 33 | road-home anchor two | **Passive-location** ~ | second anchor; same mechanism |
| 90 | Baan Dar road trick | **Passive-event** | clever road act; contextual, anti-farm gated |
| 91 | Rajhin elegant theft | **Passive-event** | qualifying theft only; spine rejects "generic theft" |
| 92 | Alkosh dragon order | **Passive-event** | dragon-kill / order act |

## Argonian (P1 second contrast)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 60 | Hist maintenance | **Object (opt-in)** ~ | Hist sap / tree ritual is plausibly an opt-in object; water/rest maintenance is passive — confirm which carries the hook |
| 61 | People support | **Passive-event** | community recognition; helping Argonian/community NPCs |
| 62 | Void threshold | **Passive-quest** | Sithis crossing; spine rejects "one DB join as full activation" — accumulated/stage gated |
| 63 | bed-of-choice | **Passive-cadence** | OnSleepStop in a player-chosen bed; not an object |

## Orc (P1 buildout)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 70 | Stronghold forge | **Object (opt-in)** ~ | a stronghold forge surface, gated to stronghold context; spine rejects "raw craft count" |
| 71 | City dignity | **Passive-event** | dignified conduct; spine rejects "ordinary city presence" |
| 72 | Legion/Exile service | **Passive-quest** ~ | Legion questline service beat; spine rejects "Legion membership alone" |
| 73 | self-made community | **Passive-event** | community-building act |

## Redguard (P1 buildout)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 80 | Crown tomb respect | **Object (opt-in)** ~ | pay-respect surface at an ancestral tomb; or passive-location on tomb entry |
| 81 | Forebear road | **Passive-event** | road/contract conduct |
| 82 | Ash'abah death duty | **Passive-event** | qualifying death-duty act; spine rejects "generic undead spam" |
| 83 | Far Shores token | **Object (opt-in)** | private ritual with a token; activation is fine |

## Bosmer (P1 buildout)

| Route | Surface | Real mechanism | Notes |
|---|---|---|---|
| 100 | Old Contract proper hunt | **Passive-event** | qualifying hunt under Green Pact; kill/use gated |
| 101 | Old Contract forest kept | **Passive-event** | Green Pact compliance |
| 102 | Living Story community | **Passive-event** | community act |
| 103 | Living Story nature site | **Passive-location** ~ | nature site; location entry or opt-in nature shrine |
| 104 | Exchange debt settled | **Passive-event** | settling a debt |
| 105 | Exchange proportionate vengeance | **Passive-event** | redress act |
| 106 | Bandit Road road-life | **Passive-event** | road-life conduct |
| 107 | Bandit Road reversal | **Passive-event** | luck/reversal moment; already 7-day cooldown gated |

## P2 audit-only races (Nord, Imperial, Breton, Dunmer)

These have no Phase 20 ACTI proof surfaces in this manifest set; their hooks
already run through proven subsystems (Nord pantheon/offer gates, Imperial
Concordat civic whitelist, Breton tradition tracks, Dunmer portable/private
shrine + dawn pass). They are audit-only, so the same proof-shim risk does not
apply — but their normal-play hooks are likewise passive/contextual, not new
activators.

## Tally

| Mechanism | Count | Races |
|---|---|---|
| Object (opt-in) | ~6 | Altmer dawn, Argonian Hist~, Orc forge~, Redguard tomb~ + Far Shores |
| Passive-event | ~15 | spread across all P1 races |
| Passive-location | ~3 | Khajiit road-home x2, Bosmer nature site~ |
| Passive-quest | ~4 | Altmer dragonborn/lorkhan, Argonian Void, Orc Legion |
| Passive-cadence | ~2 | Khajiit moon, Argonian bed-of-choice |

## Recommended consequence

1. Prove the **two mechanism families once** on Altmer (opt-in object + passive
   one-shot), per the Altmer closeout checklist. That validates the patterns the
   other races clone.
2. Khajiit is the right **second** race because it forces the two mechanisms
   Altmer does not exercise: passive-cadence (moon) and passive-location
   (road-home). Proving those there means every remaining mechanism family has a
   reference implementation before Orc/Redguard/Bosmer.
3. During each race's scaling pass, confirm the `~` judgment calls and reclassify
   that race's `triggerSurfaces` / `PDV_Phase20_NoInGameProof_Gates.json`
   placement entries from ACTI-proof toward the real mechanism.
4. Keep the QASmoke ACTI proof refs as the regression harness; do not delete
   them when the real hooks land.
