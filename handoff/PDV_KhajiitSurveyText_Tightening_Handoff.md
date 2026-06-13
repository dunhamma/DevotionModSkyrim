# PDV Khajiit Survey Text -- Tightening Handoff

**Type:** presentation polish (no piety / focus / posture logic change)
**Target:** `GetKhajiitSurveyText()` in the **live** `PDV__ManagerQuest.psc`
(`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\PDV__ManagerQuest.psc`, ~line 11173)
**Authored:** 2026-06-13 (web session)
**Finish-off owner:** main Claude session on the Windows box (has the live file + PapyrusCompiler)

---

## Why this is a handoff and not a compiled change

This was authored in a Claude Code **web** session. That sandbox is a fresh Linux
clone of the repo; it has **no `D:` drive**, so:

- `node tools/pdv_compile.mjs --script PDV__ManagerQuest` fails its environment
  check (PapyrusCompiler.exe and every import root live under `D:\Wabbajack\...`).
  **The compile has to run on your machine.**
- The **live** `GetKhajiitSurveyText` is ahead of every committed copy. The
  curse-posture readout you saw in game (`"You have drifted into shadow. The moons
  grow distant; the Lattice loosens toward the dark between the stars."`) and its
  helper exist in **no** tracked copy (`grep` for `drifted` / `grow distant` /
  `loosens toward` / Khajiit curse keys -> zero hits). The in-repo copies are:
  - `generated/live-devotion-snapshot/2026-06-12-.../PDV__ManagerQuest.psc` --
    closest structurally (has the presiding-phase line) but opens with
    `"...holds you. Current standing: X."` and has **no** curse-posture readout.
  - `scratch/phase2-live-source/...` and `scratch/p2-toast-panel-fix/...` -- share
    the live wording (`"...holds you as X"`, `"Your moon practice is ..."`) but are an
    earlier point on the same lineage (no presiding line, no curse-posture readout).

  None of these were edited: the snapshot is a SHA-256-manifested frozen capture,
  and the scratch copies are live-drift mirrors -- editing either would corrupt its
  purpose. So the patch below is delivered as a spec to apply against the real file.

---

## The problem (your in-game example)

> The Lunar Lattice holds you as Unproven. Your moon practice is quiet. No road-home
> cadence has settled yet. No single moon-path has pulled ahead. This phase of the
> Lattice belongs to Alkosh. You have drifted into shadow. The moons grow distant;
> the Lattice loosens toward the dark between the stars.

Six clauses concatenated into one run-on paragraph. The two worst offenders are pure
**empty-state filler**:

- `"No road-home cadence has settled yet."` (road-home `else` branch)
- `"No single moon-path has pulled ahead."` (focus `else` branch)

Every other race's Survey text already stays silent on absent state -- Bosmer/Orc/
Redguard/Argonian only surface notable conditions; Nord even separates its scar line
with a `"\n\n"` break (`GetSurveyDevotionText` -> `text + "\n\n" + scarText`). Khajiit
is the lone outlier that narrates nothing-happened states.

---

## The fix (apply to the live function)

Three surgical, presentation-only edits. **No data source, condition, or posture
logic changes** -- you are only deleting two `else` branches and changing one
separator.

### Edit 1 -- delete the road-home empty-state `else`

```papyrus
        if PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has begun to carry weight."
-       else
-           text = text + " No road-home cadence has settled yet."
        endIf
```

### Edit 2 -- delete the focus empty-state `else`

```papyrus
    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue > KHAJIIT_FOCUS_NONE
        text = text + " " + GetKhajiitFocusLabel(focusValue) + " walks nearest your road."
-   else
-       text = text + " No single moon-path has pulled ahead."
    endIf
```

(If your live wording for the focus-present branch is `"Current focus: " +
GetKhajiitFocusLabel(focusValue) + "."`, keep it -- only the `else` goes.)

### Edit 3 -- set the curse-posture readout on its own line

Find where the function appends the curse-posture readout (the `"You have drifted
into shadow..."` text, emitted only when posture != Normal). Change just its
**separator** from an inline space to a paragraph break, mirroring the Nord scar:

```papyrus
-   text = text + " " + <curse-posture readout>
+   text = text + "\n\n" + <curse-posture readout>
```

Leave the underlying curse-posture string/helper exactly as-is. This visually lifts
the ominous dark-moon line out of the status run and reads as its own beat.

---

## Result for your example state

(Unproven, quiet practice, no source read, no road-home weight, no leading focus,
presiding = Alkosh, curse = shadow)

> The Lunar Lattice holds you as Unproven. Your moon practice is quiet. This phase of
> the Lattice belongs to Alkosh.
>
> You have drifted into shadow. The moons grow distant; the Lattice loosens toward
> the dark between the stars.

Two clean lines instead of a six-clause wall, with the curse beat separated. A
fully-lit state (source read + road-home weight + leading focus + presiding-favored)
still surfaces every notable clause -- nothing positive was dropped.

---

## Optional: full reconstructed replacement (reference only)

If you'd rather paste a clean rewrite than do the three surgical edits, here is the
reconstructed live function with the tightening applied. **Verify the opening line,
the focus-branch wording, and the curse-posture block against your real source before
pasting** -- the curse block below is inferred from the in-game output, not read from
the live file, so splice your actual curse code into the marked slot.

```papyrus
String Function GetKhajiitSurveyText()
    ; Lead: standing + moon-practice tier (when the substrate is readable).
    String text = "The Lunar Lattice holds you as " + GetCurrentStandingLabel() + "."
    if PDV_KhajiitLunarSubstrate
        text = text + " Your moon practice is " + GetKhajiitLunarTierLabel(PDV_KhajiitLunarSubstrate.GetSubstrateTier()) + "."
        ; Notable practice details only -- empty states stay silent.
        if StorageUtil.GetIntValue(None, "PDV.Khajiit.LunarSourceCount") > 0
            text = text + " A lunar source has been read and remembered."
        endIf
        if PDV_KhajiitLunarSubstrate.GetRoadHomeCount() > 0
            text = text + " The road-home cadence has begun to carry weight."
        endIf
    else
        text = text + " The moon substrate is not readable yet."
    endIf

    ; Leading moon-path only -- silent when nothing has pulled ahead.
    Int focusValue = GetKhajiitFocusedEmphasis()
    if focusValue > KHAJIIT_FOCUS_NONE
        text = text + " " + GetKhajiitFocusLabel(focusValue) + " walks nearest your road."
    endIf

    ; Presiding phase line (unchanged logic).
    Int presiding = GetCurrentLunarPresidingFocus()
    if presiding > KHAJIIT_FOCUS_NONE
        if GetActiveLunarFavoredFocus() == presiding
            text = text + " This phase of the Lattice belongs to " + GetKhajiitFocusLabel(presiding) + ", and your standing lets the moons favor you."
        else
            text = text + " This phase of the Lattice belongs to " + GetKhajiitFocusLabel(presiding) + "."
        endIf
    endIf

    ; >>> SPLICE YOUR EXISTING CURSE-POSTURE READOUT HERE, UNCHANGED. <<<
    ; It already returns nothing when posture is Normal. Only change the
    ; separator so it lands on its own line, e.g.:
    ;     text = text + "\n\n" + <curse-posture readout>

    return text
EndFunction
```

ASCII-safe, no new imports (no `StringUtil` dependency), and shorter than the
original in every state.

---

## Finish-off checklist (run on the Windows box)

1. Apply Edits 1-3 to the live `GetKhajiitSurveyText` (or paste the reconstructed
   version after verifying the three flagged spots).
2. Compile:
   ```
   node tools/pdv_compile.mjs --script PDV__ManagerQuest
   ```
   (optionally add `--strict-khajiit` for the stricter Khajiit gate).
3. Confirm clean: expect `[PASS] PDV__ManagerQuest`, a fresh `.pex`, no warnings/
   errors, and `[PASS] verifier`.
4. In game: Survey as a Khajiit in a shadow-curse / no-cadence / no-focus state and
   confirm the empty-state filler is gone and the curse line sits on its own beat.
```
