# Death-Stakes -- Buildable Spec

**Status:** DESIGN DOSSIER, 2026-06-11. Buildable once LD-P1 is runtime-proven.
Names are the contract; line numbers drift. No Papyrus/CK/ESP changes made.

---

## 1. Death-Detection Hook

### 1.1 Where it lives

`PDV_PlayerEvents.psc` -- the existing player-alias script. Add one new event
handler. No new script file needed.

### 1.2 New event handler shape

```
Event OnDying(Actor akKiller)
    TryWriteSoulFate()
EndEvent

Function TryWriteSoulFate()
    ; Guard: only write once per playthrough (owner decision D3)
    if StorageUtil.GetIntValue(None, "PDV.SoulFate.Written") == 1
        return
    endIf

    ; Guard: LD-P1 mood-band availability
    ; PDV_GLO_PatronMoodBand is a new LD-P1 global. If absent, degrade.
    Int moodBand = -1
    if PDV_PatronMoodBandGlobal
        moodBand = PDV_PatronMoodBandGlobal.GetValueInt()
    endIf

    ; Resolve destination string
    String destination = ResolveSoulFateDestination(moodBand)
    String flavorText = ResolveSoulFateText(moodBand, destination)

    ; Write the flag
    StorageUtil.SetIntValue(None, "PDV.SoulFate.Written", 1)
    StorageUtil.SetStringValue(None, "PDV.SoulFate.Destination", destination)
    StorageUtil.SetStringValue(None, "PDV.SoulFate.FlavorText", flavorText)
    StorageUtil.SetFloatValue(None, "PDV.SoulFate.GameTimeAt",
        Utility.GetCurrentGameTime())

    ; Surface: Marked toast via manager, or Debug.Notification fallback
    if PDV_ManagerRef
        PDV_ManagerRef.TrySurfaceSoulFateToast(destination, flavorText)
    else
        Debug.Notification(flavorText)
    endIf

    Trace(2, "[PDV] Soul fate written: " + destination + " (" + flavorText + ")")
EndFunction
```

### 1.3 New properties on PDV_PlayerEvents

```
GlobalVariable Property PDV_PatronMoodBandGlobal Auto
    ; CK: wire to PDV_GLO_PatronMoodBand (authored in LD-P1)
    ; If absent at death, moodBand defaults to -1 (degrade to piety check)

PDV__ManagerQuest Property PDV_ManagerRef Auto
    ; CK: wire to the main manager quest
    ; Used only for the soul-fate toast; alias already holds PDV_EventBusService
    ; for all other routing
```

---

## 2. Soul-Fate StorageUtil Namespace

All keys are None-keyed (global, not per-deity), following the
`PDV.Commitment.*` and `PDV.Intervention.Sacrifice.*` precedents.

```
PDV.SoulFate.Written          (int)    ; 0 = not yet set; 1 = set
PDV.SoulFate.Destination      (string) ; see destination vocabulary below
PDV.SoulFate.FlavorText       (string) ; the authored text shown at death
PDV.SoulFate.GameTimeAt       (float)  ; Utility.GetCurrentGameTime() at write
PDV.SoulFate.PatronName       (string) ; deity name at time of death (for survey)
PDV.SoulFate.MoodBandAtDeath  (int)    ; 0-3 band, or -1 if LD-P1 not live
```

**Destination vocabulary (string constants):**

```
"sovngarde"        ; Nord/Shor, Pleased+
"sky_road"         ; Nord/Kyne, Pleased+
"hunting_grounds"  ; Hircine (werewolf), Pleased+
"far_shores"       ; Redguard/Tu'whacca, Pleased+
"hist_return"      ; Argonian/Hist, Pleased+
"aetherius"        ; Altmer/Auri-El or Akatosh, Pleased+
"moonshadow"       ; Azura devotee, Pleased+
"colored_rooms"    ; Meridia devotee, Pleased+
"coldharbour"      ; Molag Bal devotee, Pleased+ (coercive claim)
"apocrypha"        ; Hermaeus Mora devotee, Pleased+
"ashpit"           ; Orc/Malacath, Pleased+
"great_game"       ; Boethiah devotee, Pleased+
"denied"           ; patron Wroth -- patron denies the claim
"dreamsleeve"      ; no patron, or fallback when no destination authored
```

---

## 3. Destination Resolution Functions

These are new functions added to `PDV__ManagerQuest.psc` (or a new thin helper
script). They do not require LD-P1 seams beyond the mood-band read; they can
be authored as a conditional chain against the active patron's DeityName or a
new authored property.

### 3.1 ResolveSoulFateDestination (in PDV_PlayerEvents or routed to manager)

```
String Function ResolveSoulFateDestination(Int moodBand)
    ; moodBand: 0=Wroth, 1=Cool, 2=Pleased, 3=Exalted; -1=unknown
    ; Returns a destination string from the vocabulary above.

    ; Wroth always denies
    if moodBand == 0
        ; Check if patron authored a rival-claim (Molag Bal, Hircine at Wroth)
        String rivalClaim = GetPatronWrothRivalClaim()
        if rivalClaim != ""
            return rivalClaim
        endIf
        return "denied"
    endIf

    ; Cool or unknown: check if patron has a "cool acceptance" authored
    ; For V1 simplicity: Pleased+ = positive claim, Cool/Wroth = denied/dreamsleeve
    if moodBand <= 1
        return "dreamsleeve"
    endIf

    ; Pleased or Exalted: patron claims the soul
    return GetPatronAfterlifeDestination()
EndFunction
```

### 3.2 GetPatronAfterlifeDestination (new function in PDV__ManagerQuest)

Reads a new authored property on `PDV_DeityBase`:

```
String Property AfterlifeDestination = "dreamsleeve" Auto
    ; CK: author the correct destination string per deity
    ; Defaults to "dreamsleeve" (safe fallback for unauthored deities)
```

The function returns `_activeDeity.AfterlifeDestination` if `_activeDeity` is
not None, else `"dreamsleeve"`.

### 3.3 GetPatronWrothRivalClaim (new function)

Optional per-deity authored property:
```
String Property WrothRivalClaim = "" Auto
    ; CK: "" = no rival claim (patron merely denies)
    ; e.g. Molag Bal: "coldharbour" (patron claims even at Wroth -- the soul is trapped)
    ; e.g. Hircine at Wroth: "" (cast out, not rival-claimed)
```

---

## 4. Marked Toast / Message Surface

### 4.1 New manager function: TrySurfaceSoulFateToast

```
Function TrySurfaceSoulFateToast(String destination, String flavorText)
    ; Fire a Marked-tier toast via the existing SendPrismaEventToast path.
    ; Event name "soul_fate" is a new event type; the omen profile for it
    ; is authored in PDV_OmenProfile.csv (see 5.3).
    if _activeDeity
        SendPrismaEventToast("soul_fate", _activeDeity, destination, "", "")
    else
        SendPrismaEventToast("soul_fate", None, destination, "", "")
    endIf

    ; Fallback modal message (fires even if Prisma absent, since this is Marked)
    ; Use the ShowRaceMessage pattern (same as ShowNordMessage for vampire onset).
    ; CK: author PDV_Msg_SoulFate_Generic as a Message record with text from
    ; flavorText param (or a static authored text per destination).
    if !PDV_PrismaBridge.IsAvailable()
        Debug.MessageBox(flavorText)
        ; Note: MessageBox is synchronous and must be called from a quest-stage
        ; fragment, not from OnDying directly. Use a deferred show pattern:
        ; set PDV.SoulFate.PendingModal = 1 in OnDying; show at next OnUpdateGameTime
        ; or next dawn. See proof item below.
    endIf
EndFunction
```

**PROOF ITEM:** Confirm that `SendPrismaEventToast` (live :1245) fires correctly
during the death-fade. If the Prisma overlay is suppressed by the engine during
death, the toast must be deferred to the post-reload first-update frame
(set a pending flag in StorageUtil, check it in `PDV_PlayerEvents.OnPlayerLoadGame`).

**PROOF ITEM:** `Debug.MessageBox` cannot be called from `OnDying`
(called on the wrong thread during death). The Marked message surface must
use the deferred-modal pattern. Set `PDV.SoulFate.PendingModal = 1` in
`OnDying`, check and show in `OnPlayerLoadGame` or at the next dawn.

### 4.2 Text authoring shape

Per-destination authored texts (authored as Message records in CK, or as string
properties on a new `PDV_SoulFate_Messages` miscellaneous object, or as
StorageUtil-loaded JSON keys compiled from CSV):

**Pleased/Exalted examples (P1 pilot):**
- Shor/Sovngarde: "Shor calls the worthy. The gates of Sovngarde open."
- Kyne/sky-road: "Kyne's breath carries the warrior home. The sky-road is open."
- Hircine/Hunting Grounds: "The Hunt is eternal. Hircine calls his own."

**Cool/Wroth examples:**
- Patron denies (any deity): "The god turns away. No claim is made. The Dreamsleeve takes the unnamed."
- Hircine Wroth: "You were no hunter. The Hunting Grounds are closed. The Dreamsleeve receives the prey."
- Nord vampire severs Shor: "The thirst severs the claim. Shor does not receive the blood-drinker." (this already exists as a curse-onset message; at actual death, fire the permanent version)

**Dreamsleeve fallback:** "No god claims you. The Dreamsleeve takes the unnamed."

---

## 5. Authoring Tables and CSV Shape

### 5.1 New PDV_DeityBase properties (authored in CK, not in CSV)

```
String Property AfterlifeDestination = "dreamsleeve" Auto
String Property WrothRivalClaim = "" Auto
```

These are CK-authored VMAD properties following the existing deity-property
pattern (same as `ClutchSaveEffect`, `Boon_Seeker`, etc. in LD-P1). They do
not need a CSV column -- they are deity-specific constants, not per-event data.

### 5.2 PDV_SoulFate_Destinations.csv (new authoring file, P1 scope)

Shape:
```
deity_name, destination_pleased, destination_wroth_rival, flavor_pleased, flavor_cool, flavor_wroth, notes
```

- `deity_name`: matches `DeityName` authored string on `PDV_DeityBase`
- `destination_pleased`: string from vocabulary in section 2
- `destination_wroth_rival`: string or "" (empty = patron-denied)
- `flavor_pleased`: authored Marked toast text
- `flavor_cool`: text for Cool band (between Pleased and Wroth)
- `flavor_wroth`: authored Marked denial text
- `notes`: lore citation or "invented" flag

Compiler: extend `tools/pdv_living_deities_compile.mjs` or author a thin
`tools/pdv_death_stakes_compile.mjs` (same shape). Output: JSON under
`SKSE/Plugins/StorageUtilData/PlayerDevotion/PDV_SoulFate_Destinations.json`.

P1 rows (Nord + Hircine pilot):
```
Shor, sovngarde, "", "Shor calls the worthy. Sovngarde opens.", "Shor acknowledges you. The road is not closed.", "Shor does not know your name. The road is unmarked.", "UESP: Sovngarde as Shor's hall"
Kyne, sky_road, "", "Kyne's breath carries the warrior home.", "The winds are still. Kyne watches.", "The storm turns. Kyne does not carry you.", "Invented: sky-road framing; Old Ways death-bringer lore-adjacent"
Hircine, hunting_grounds, "", "The Hunt is eternal. Hircine calls his own.", "The Hunt watches. You were not forgotten.", "You were prey, not hunter. The Grounds are closed.", "UESP: Hircine's Hunting Grounds"
```

### 5.3 PDV_OmenProfile.csv extension

Add a row for the `soul_fate` event type:
```
deity, transition, toast_key, dream_text_key, tone
<pilot deities>, death->soul_fate, soul_fate_toast, none, marked
```

The `tone` = `"marked"` ensures the Prisma overlay (or notification fallback)
applies the highest-weight surfacing tier per the Marked-signal rule
(`PDV_RaceArchitecture_DesignReference.md` section 9.1).

---

## 6. Survey Text Integration

Pattern: mirror the existing `GetNordSurveyBaseText()` logic that reads
`IsNordVampireSuppressed()` and surfaces "Sovngarde is closed while the thirst
remains." Add a soul-fate clause AFTER the vampire-suppression check:

```
; In GetNordSurveyBaseText() or a new GetSoulFateSurveyLine():
if StorageUtil.GetIntValue(None, "PDV.SoulFate.Written") == 1
    String dest = StorageUtil.GetStringValue(None, "PDV.SoulFate.Destination")
    String flavor = StorageUtil.GetStringValue(None, "PDV.SoulFate.FlavorText")
    ; Return something like:
    ; "At your last death, <PatronName> claimed: <flavor>"
    ; or use a short authored line per destination.
endIf
```

This function would be called from the survey panel MCM or the journal overlay.
No new surface is required -- the existing survey-text pipeline handles it.

---

## 7. Verifier Expectations (extend pdv_verify.mjs / pdv_content_verify.mjs)

**Soul-fate flag write:**
- After a simulated death (set player health to 0 via console or a test MGEF),
  confirm `PDV.SoulFate.Written == 1` in StorageUtil.
- Confirm `PDV.SoulFate.Destination` matches the mood-band at the time of death.
- Confirm the flag does NOT overwrite on a second death (one-shot guard).

**Mood-band gate:**
- Seed a Pleased band on the pilot patron, simulate death, confirm
  destination = "sovngarde" (Nord/Shor) or "hunting_grounds" (Hircine).
- Seed a Wroth band, simulate death, confirm destination = "denied" or
  "dreamsleeve".

**Toast surface:**
- Confirm `SendPrismaEventToast("soul_fate", ...)` is called.
- Confirm `Debug.Notification` fallback fires when Prisma absent.

**Survey text:**
- Confirm `GetNordSurveyBaseText()` (or the new soul-fate line function) includes
  the destination text after the flag is set.

**LD-P1 degradation:**
- If `PDV_GLO_PatronMoodBand` is None (property not wired), confirm the
  function does not null-ref crash and falls back to `"dreamsleeve"`.

**Nord vampire interaction:**
- If `PDV.Nord.VampireActive == 1` at death, the destination should be forced
  to `"denied"` (Shor does not receive the blood-drinker) regardless of mood-band.
  Add this override to `ResolveSoulFateDestination` as a race-specific guard.
  PROOF ITEM: confirm the override fires correctly in combination with the
  mood-band read.

---

## 8. Build Order

1. (Dependency) LD-P1 runtime-proven: `PDV_GLO_PatronMoodBand` live and updated.
2. Author `PDV_SoulFate_Destinations.csv` for P1 deities (Nord/Shor, Kyne,
   Hircine).
3. Add `AfterlifeDestination` and `WrothRivalClaim` properties to
   `PDV_DeityBase.psc` (or as String constants on each thin-shell deity).
4. Add `OnDying` handler to `PDV_PlayerEvents.psc`; add manager property.
5. Add `TrySurfaceSoulFateToast` and `ResolveSoulFateDestination` to manager.
6. Author `PDV_OmenProfile.csv` `soul_fate` row.
7. CK: wire new properties; author Message records for each P1 destination text.
8. Compile; run verifier assertions above; in-game smoke test.
9. Confirm DA / Sands of Time compat in-game (the single highest-risk edge case).
