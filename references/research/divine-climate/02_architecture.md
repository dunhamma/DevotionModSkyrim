# 02 -- Divine Climate Architecture (Buildable Spec)

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes. Design only.
**Date:** 2026-06-11
**Scope:** P1 pilot -- Aedra/Daedra alignment scalar, omen tone bias only.
No weather/wildlife/NPC reactions (backlog).

---

## 1. New CK Record

**One new GlobalVariable:** `PDV_GLO_DivineClimate`

| Field | Value |
|---|---|
| EditorID | PDV_GLO_DivineClimate |
| Type | Short |
| Initial value | 0 |
| Usage | -1 = Daedric ascendant; 0 = Balanced; +1 = Aedric ascendant |

**One new property on `PDV_DeityBase`:**

```
Bool Property IsAedra = True Auto
```

Default True (most of the vanilla-accessible pantheon is Aedric). Author
False for Daedric deity forms in CK: Azura, Boethiah, Mephala, Malacath,
Sithis, and any Daedric deity actors built in later work. Transgressive
Princes (`PDV_DaedricPath_*`) are not in `PDV_FLST_AllDeities` and do not
need this property.

---

## 2. New Script Function: `RunDawnComputeDivineClimate()`

**Location:** `PDV__ManagerQuest`. Added to `ProcessDawn()` immediately after
`RunDawnConsolidateScratch()` completes (when all mood values are fresh).

**Insertion point in `ProcessDawn()` (live function):**

```
Function ProcessDawn()
    ...
    RunDawnConsolidateScratch()
    RunDawnComputeDivineClimatNoop()  ; NEW -- climate scan
    RunDawnRefreshTrackStates()
    RunDawnApplyDecayNoop()
    RunDawnApplySpellAndNeglectLayersNoop()
    RunDawnProcessCommitmentOffersNoop()
    RunDawnNotifyNoop()
    SyncKhajiitPhaseBlessing()
    RequestPanelRefresh()
    ...
EndFunction

Function RunDawnComputeDivineClimatNoop()
    RunDawnComputeDivineClimate()
EndFunction
```

Following the existing `*Noop()` wrapper convention (live examples:
`RunDawnApplyDecayNoop()`, `RunDawnApplySpellAndNeglectLayersNoop()`,
`RunDawnProcessCommitmentOffersNoop()`) -- each Noop wraps the real
function so a future stub/no-op replacement is always clean.

**Function body:**

```
Function RunDawnComputeDivineClimate()
    if !PDV_FLST_AllDeities
        return
    endIf

    ; Scan all deities for highest mood (or piety if mood not yet live).
    ; PROOF ITEM A1: use PDV.Mood.<name> once LD-P1 lands; PDV.Piety interim.
    Float bestMood   = -999.0
    String bestDeity = ""
    Bool   bestIsAedra = True
    Int    aedraCount  = 0
    Int    daedraCount = 0

    Int count = PDV_FLST_AllDeities.GetSize()
    Int i = 0
    while i < count
        Form deityForm = PDV_FLST_AllDeities.GetAt(i)
        PDV_DeityBase deity = deityForm as PDV_DeityBase
        if deity
            ; Use mood key when LD-P1 is live; fall back to piety.
            Float moodVal = StorageUtil.GetFloatValue(deityForm, "PDV.Mood." + deity.DeityName, -999.0)
            if moodVal == -999.0
                moodVal = StorageUtil.GetFloatValue(deityForm, "PDV.Piety", 0.0)
            endIf

            if moodVal > bestMood
                bestMood    = moodVal
                bestDeity   = deity.DeityName
                bestIsAedra = deity.IsAedra
            endIf

            if deity.IsAedra
                aedraCount += 1
            else
                daedraCount += 1
            endIf
        endIf
        i += 1
    endWhile

    ; Compute scalar. PROOF ITEM A3: CLIMATE_THRESHOLD tunable.
    Float CLIMATE_THRESHOLD = 5.0   ; implement as a property, not a literal
    Int climateInt = 0
    if bestMood >= CLIMATE_THRESHOLD
        if bestIsAedra
            climateInt = 1
        else
            climateInt = -1
        endIf
    endIf

    ; Write global mirror and StorageUtil diagnostic keys.
    if PDV_GLO_DivineClimate
        PDV_GLO_DivineClimate.SetValue(climateInt as Float)
    endIf
    StorageUtil.SetIntValue(None, "PDV.Climate.Scalar", climateInt)
    StorageUtil.SetStringValue(None, "PDV.Climate.AscendantDeity", bestDeity)
    StorageUtil.SetFloatValue(None, "PDV.Climate.AscendantMood", bestMood)

    if GetDebugLevel() >= 1
        Debug.Trace("[PDV] DivineClimate: scalar=" + climateInt + " ascendant=" + bestDeity + " mood=" + bestMood)
    endIf
EndFunction
```

**Constants (add to `PDV__ManagerQuest` constant block):**

```
Float Property CLIMATE_THRESHOLD = 5.0 AutoReadOnly
  ; Minimum ascendant mood/piety for a non-zero climate scalar.
  ; PROOF ITEM A3: tune in playtesting.
```

---

## 3. Climate Tone Bias: `GetClimateToneOverride(String baseTone)`

New helper on `PDV__ManagerQuest`. Called by the omen dispatch path before
passing `toneOverride` to `PDV_DiegeticDirector.Dispatch()`.

```
String Function GetClimateToneOverride(String baseTone)
    Int climateInt = StorageUtil.GetIntValue(None, "PDV.Climate.Scalar", 0)
    if climateInt == 0
        return baseTone   ; balanced -- no override
    endIf
    if climateInt > 0
        ; Aedric ascendant: weight toward reverent/uplifting.
        ; PROOF ITEM T1: owner decides "reverent" remap vs new "uplifting" tone.
        if baseTone == "quiet" || baseTone == "absence"
            return "reverent"
        endIf
    else
        ; Daedric ascendant: weight toward dread/ominous.
        ; PROOF ITEM T1: owner decides "dread" remap vs new "ominous" tone.
        if baseTone == "quiet" || baseTone == "reverent"
            return "dread"
        endIf
    endIf
    return baseTone   ; no override for other base tones
EndFunction
```

**Rules:**
1. The function only nudges neutral base tones ("quiet", "absence",
   "reverent"). It never downgrades a tone that already carries semantic
   weight (e.g. it does not turn "revelation" into "dread").
2. It reads `PDV.Climate.Scalar` from StorageUtil, not the GlobalVariable,
   to avoid GlobalVariable live-read limitations inside scripts.
3. The result is passed as `toneOverride` to `PDV_DiegeticDirector.Dispatch()`.
   If the Director has no IMAD/shader for the returned tone, it silently
   no-ops (PROOF ITEM T2).

**Call site (LD-P1 `OnMoodBandCross()` dispatch path, pseudocode):**

```
; Inside OnMoodBandCross() / dream dispatch:
String baseTone = GetProfileTone(eventClass, direction, "")
String climateTone = GetClimateToneOverride(baseTone)
PDV_DiegeticDirector.Dispatch(eventClass, surfaceKey, direction, deityIndex, climateTone)
```

This is the only place climate touches omen dispatch. It does not modify
`SendPrismaEventToast()` calls in P1.

---

## 4. StorageUtil Keys (summary)

All keys on global namespace `None`:

```
PDV.Climate.Scalar          Int   : -1 / 0 / +1 (same as PDV_GLO_DivineClimate)
PDV.Climate.AscendantDeity  String: DeityName of the highest-mood deity at last dawn
PDV.Climate.AscendantMood   Float : mood/piety value of the ascendant deity at last dawn
```

The `AscendantDeity` and `AscendantMood` keys are diagnostic/future-use.
Only `PDV.Climate.Scalar` is needed for P1 omen tinting. The GlobalVariable
`PDV_GLO_DivineClimate` mirrors `PDV.Climate.Scalar` for CK/MGEF/SPID.

---

## 5. What Divine Climate Does NOT Touch

Hard boundary enforced by design:

| System | Status |
|---|---|
| `PDV.Piety` keys | Never written or read for assignment. Read-only for ascendancy scan (interim only). |
| `PDV.Mood.*` keys | Never written. Read-only for ascendancy scan. |
| `PDV.Demand.*` keys | Not touched. |
| `PDV.Context.*` keys (B2) | Not touched. Divine climate is above B2, not a substitute. |
| Tier recomputation | Not triggered. |
| `RunDawnConsolidateScratch()` | Not modified. Climate scan is a separate function called after it. |
| `SendPrismaEventToast()` | Not modified in P1. Toast text stays vanilla. |
| `IsOmenAppropriate()` (B2) | Not modified. B2 suppresses omens independently; climate only tints the ones that pass. |

---

## 6. Verifier Expectations

Extend `tools/pdv_verify.mjs` or `pdv_living_deities_selftest.mjs`:

- **Static gate DC1:** `PDV_GLO_DivineClimate` record present in the ESP;
  type Short; initial value 0.
- **Static gate DC2:** every `PDV_DeityBase` actor in `PDV_FLST_AllDeities`
  has the `IsAedra` property authored (not left at default without intent).
- **Runtime proof DC3:** after a dawn with a patron deity above the
  CLIMATE_THRESHOLD, confirm `getglobalvalue PDV_GLO_DivineClimate` returns
  +1 (Aedric) or -1 (Daedric) in console. Confirm
  `StorageUtil.GetStringValue(None, "PDV.Climate.AscendantDeity")` matches.
- **Runtime proof DC4:** on a dawn where no deity exceeds the threshold,
  confirm `PDV_GLO_DivineClimate` == 0.
- **Runtime proof DC5:** trigger a band-cross omen for a deity while
  climate is nonzero; confirm the trace log shows a non-default tone
  passed to Dispatch. Confirm no piety or mood values changed as a side
  effect of the climate pass.
- **Boundary proof DC6:** on a day with no player acts (`clampedToday = 0`
  for all deities), confirm `RunDawnComputeDivineClimate()` still fires and
  reflects carry-over mood from prior days (it is a read-only scan; a
  zero-activity day does not force climate to Balanced).

---

## 7. Owner Decisions Required Before Build

1. **PROOF ITEM A1 -- Key choice:** use `PDV.Mood.<deity>` (requires LD-P1
   to be landed) or `PDV.Piety` (live today) as the ascendancy signal for
   P1. Owner must decide whether to target the interim or post-LD-P1 state.

2. **PROOF ITEM A2 -- Daedra in FLST:** confirm which `PDV_Deity_*` actors
   are Daedric and should have `IsAedra = False`. The transgressive
   Princes are NOT in the list; only the balance/worship-track Daedric
   deity forms (Azura, Boethiah, Mephala, Malacath, Sithis, etc.) need
   authoring.

3. **PROOF ITEM A3 / CLIMATE_THRESHOLD:** choose the minimum mood/piety
   value for a non-zero climate signal. Suggested 5.0 (just above resting
   piety baseline); owner confirm.

4. **PROOF ITEM T1 -- Tone remap vs. new tones:** for P1, does the climate
   tint remap existing tones ("dread"/"reverent") or author new tone strings
   ("ominous"/"uplifting") requiring new IMAD/shader CK records? Remapping
   is zero-CK-cost; new tones require new visual records.

5. **Sequence gate:** does divine climate build before, alongside, or after
   LD-P1? The function is safe to build before LD-P1 (it falls back to
   `PDV.Piety`) but the tone-override call site lives inside LD-P1's
   `OnMoodBandCross()` dispatch path. Recommend: merge the StorageUtil
   write + GlobalVariable in the dawn pass independently, and wire the
   tone override when LD-P1's dispatch path is authored.
