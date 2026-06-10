# 01 -- Divine Climate Feasibility

**Status:** DESIGN DOSSIER. No Papyrus/CK/ESP changes. Design only.
**Date:** 2026-06-11
**Honesty bar:** same as `03_feasibility.md` (LD-P1). No CK, no Skyrim
runtime. Every seam traced to a live function in the PDV source tree
(`D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/`). Each
mechanism ends with the in-CK/in-game proof still required.

**Headline:** all three mechanisms are HIGH-confidence recompositions of
live PDV seams. No greenfield script authoring is required beyond a new
sub-function and one GlobalVariable record. This is the lowest-cost
cosmetic layer in the Living Deities backlog.

---

## Mechanism 1: Ascendancy Computation

**What it does:** at dawn, after `RunDawnConsolidateScratch()` completes and
all `PDV.Mood.<deity>` values are fresh, a second pass over
`PDV_FLST_AllDeities` identifies the deity with the highest current mood
value and classifies it as Aedra (+1), Daedra (-1), or -- if the highest
mood is <= 0 or the top two deities are within a threshold -- Balanced (0).

**Live seam:**
- `PDV_FLST_AllDeities` (live: `PDV__ManagerQuest.psc:35`, FormList
  property). The consolidation loop at `RunDawnConsolidateScratch()` already
  iterates this list with `PDV_FLST_AllDeities.GetAt(i) as PDV_DeityBase`.
  The scan is a second pass using the same pattern.
- `StorageUtil.GetFloatValue(deityForm, "PDV.Mood.<deity>")` is the mood key
  written by `RunDawnUpdateMood()` (LD-P1 spec). At P1, that key does not yet
  exist -- the mood system is LD-P1 work. Until LD-P1 lands, the scan can
  fall back to `PDV.Piety` (live key, `PDV__ManagerQuest.psc:4097`) as the
  ascendancy signal. See PROOF ITEM A1.
- `Bool IsAedra` -- new authored property on `PDV_DeityBase`. Cheap: one bool
  per deity record, set in CK once. Aedra classification is stable lore.

**Confidence:** HIGH (pure recomposition of live iteration pattern).

**Recomposition vs greenfield:** recomposition. The scan is ~15 lines using
the existing `PDV_FLST_AllDeities.GetAt(i)` idiom and `StorageUtil.GetFloat`.
No new Papyrus API calls.

**In-CK/in-game proof still required:**
- PROOF ITEM A1: confirm which key to scan before LD-P1 lands. If `PDV.Piety`
  is used as the interim signal, confirm it is a reliable ascendancy proxy
  (it is the most natural, but it has a different EWMA shape than mood). Owner
  decision required.
- PROOF ITEM A2: verify that `PDV_FLST_AllDeities` contains Daedric deity
  actors (PDV_Deity_Boethiah, PDV_Deity_Mephala, etc.) and not only Aedric
  ones. Transgressive Princes are `PDV_DaedricPath_*` actors and are
  explicitly NOT in the list (per `PDV__ManagerQuest.psc:3572`). Confirm the
  deity-form Daedra (Azura, Boethiah, Mephala, Sithis, Malacath etc. in
  `PDV_Deity_*.psc`) ARE present and that their `IsAedra` property can be
  set meaningfully.
- PROOF ITEM A3: verify the "balanced" tie-breaking threshold in gameplay.
  Suggest 5.0 mood-point gap as the minimum for a non-zero climate signal.
  This is a tuning value; owner decision required before CK authoring.

---

## Mechanism 2: Tint Application (Omen Tone Bias)

**What it does:** when `OnMoodBandCross()` or a dream dispatch prepares an
omen payload and calls `PDV_DiegeticDirector.Dispatch()`, the caller first
reads `PDV_GLO_DivineClimate.GetValueInt()` and passes a modified tone string
via the existing `toneOverride` parameter.

**Live seam:**
- `PDV_DiegeticDirector.Dispatch(String eventClass, String surfaceKey,
  String direction, Int deityIndex, String toneOverride = "")` (live:
  `PDV_DiegeticDirector.psc:41`). The `toneOverride` parameter already
  exists and is already handled: if non-empty it bypasses `GetProfileTone()`
  (live: `:48-49`). The climate bias slots in here without touching the
  Director interface.
- `GetProfileTone()` (live: `:203`) maps `eventClass+direction` -> tone
  string. Live tones: `"reverent"`, `"revelation"`, `"dread"`, `"release"`,
  `"absence"`, `"quiet"`. The climate layer needs two new composite tones:
  `"ominous"` (Daedric climate) and `"uplifting"` (Aedric climate) -- or it
  can map to existing tones ("dread" / "reverent") to avoid new IMAD/shader
  authoring in P1. Owner decision: new tones vs. remapping existing ones.
  See PROOF ITEM T1.
- `SendPrismaEventToast()` (live: `PDV__ManagerQuest.psc:1245`) is the other
  omen surface. It does not accept a tone override today. If the climate
  tint must reach toast text, a `climateTag` parameter must be added. For
  P1, scope to the Director path only and leave toast text unmodified.

**Confidence:** HIGH (the `toneOverride` seam is live and already doing
exactly this job for curse events).

**Recomposition vs greenfield:** recomposition. The `toneOverride` parameter
is the designed extension point.

**In-CK/in-game proof still required:**
- PROOF ITEM T1: decide whether P1 maps Daedric/Aedric climate to existing
  tones ("dread"/"reverent") or authors two new tone strings with new IMAD
  and shader records. New tones require CK work; remapping is zero-cost but
  semantically coarser. Owner decision before CK authoring.
- PROOF ITEM T2: verify that calling `Dispatch()` with a tone that has no
  matching IMAD property (e.g. a new `"uplifting"` tone not yet in
  `GetImageSpaceForTone()`) silently no-ops rather than papyrus-erroring.
  The function returns `None` for unknown tones -- confirm this is a clean
  no-op vs. a Papyrus warning in logs.
- PROOF ITEM T3: verify in-game that climate tint does not double-fire with
  the base omen tone. The toneOverride replaces, not stacks -- confirm the
  `GetProfileTone()` branch is truly skipped when `toneOverride != ""`.

---

## Mechanism 3: Global Mirror (PDV_GLO_DivineClimate)

**What it does:** a single GlobalVariable updated each dawn holds the
climate scalar (-1 / 0 / +1). CK Conditions, MGEF scripts, and SPID
distributions can read it via `GetGlobalValue` without any Papyrus
dependency.

**Live seam:**
- Pattern: every PDV CK-readable state uses a GlobalVariable mirroring a
  StorageUtil key. Examples: `PDV_GLO_PatronMoodBand` (LD-P1 spec),
  `PDV_GLO_CurseState` (live, `PDV_CurseState.psc`), `PDV_GLO_ActiveTier`
  (live, referenced in `PDV_DiegeticDirector.psc:8`).
- Writing: `PDV_GLO_DivineClimate.SetValue(climateInt)` in
  `RunDawnComputeDivineClimate()`, mirroring the pattern at tier-change
  (`PDV__ManagerQuest.psc:3442`). One `SetValue` call per dawn.
- Reading: any CK Condition using `GetGlobalValue` on
  `PDV_GLO_DivineClimate` works without any script. SPID distributions
  gated on alignment climate cost zero Papyrus.

**Confidence:** HIGH (established pattern, one new CK record).

**Recomposition vs greenfield:** greenfield record (one GlobalVariable
in the ESP), recomposition of the write/read pattern.

**In-CK/in-game proof still required:**
- PROOF ITEM G1: in CK, confirm the GlobalVariable type (Short, not Float)
  is sufficient for a -1/0/+1 scalar. Short GlobalVariables are the
  standard PDV pattern for integer state flags.
- PROOF ITEM G2: in-game, after a dawn pass, confirm `PDV_GLO_DivineClimate`
  holds the expected value. Console command:
  `getglobalvalue PDV_GLO_DivineClimate`

---

## Feasibility Verdict Table

| Mechanism | Confidence | Type | Seam (live name) | Proof items |
|---|---|---|---|---|
| Ascendancy scan in dawn loop | HIGH | Recomposition | `RunDawnConsolidateScratch`, `PDV_FLST_AllDeities.GetAt()`, `StorageUtil.GetFloat` | A1 (key choice), A2 (Daedra in FLST), A3 (threshold tuning) |
| Omen tone bias via DiegeticDirector | HIGH | Recomposition | `PDV_DiegeticDirector.Dispatch()` `toneOverride` param (live `:41`) | T1 (new vs. remap tones), T2 (unknown-tone no-op), T3 (override skips base) |
| Global mirror | HIGH | Greenfield record, recomposed write | `PDV_GLO_*` pattern, `GlobalVariable.SetValue()` | G1 (Short type), G2 (in-game readback) |

**Overall verdict:** buildable as a thin P1 layer with no new Papyrus APIs
and no change to existing interfaces. The only new CK record is one
GlobalVariable. The `toneOverride` path in `PDV_DiegeticDirector` is the
designed extension point and it is live today. Zero risk of touching piety
or mood values if the function boundary in architecture section 3 is
respected.
