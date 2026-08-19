# PDV 2.0 -- PRISMA Presentation Hook (design gate D1)

Status: DRAFT for owner review. These signatures are proposed, not frozen. The owner reviews
and freezes; this document does not itself freeze an interface.

Scope: design only. No source, manifest, or region-map edits accompany this document.

Grounding read this session (all facts below are re-derived from the current tree, not from a
handoff summary):

- `references/authoring/PDV_2_0_ADR_OriginAdapterInterface.md` (ACCEPTED 2026-08-19) -- the ORIGIN
  adapter virtual surface this hook must compose with.
- `references/authoring/PDV_PrismaIntegrationBoundary.md` -- the P2/Prisma manager-owned-state and
  typed-payload boundary.
- `references/authoring/PDV_HO_PresentationScope_BroadScopeAbort_2026-07-15.md`.
- `references/authoring/PDV_PrismaChoicePanel_CapabilityPlan.md`.
- `references/authoring/PDV_2_0RegionMap.json` (module PRISMA -- 115 functions; targetScript
  `PDV_PrismaPresenter`).
- Live source `live-source/Scripts/Source/PDV__ManagerQuest.psc` and
  `PDV_OriginRuntime_*.psc`.

---

## 0. Design decision context (LOCKED -- not relitigated here)

**D8 (LOCKED):** ORIGIN owns per-race presentation CONTENT; PRISMA owns the JSON ENVELOPE. The
hook is the seam between them. It must be designed BEFORE PRISMA is extracted so the extraction
remaps every call site exactly once, against a stable interface, rather than discovering the seam
mid-move.

This is a strict-behavior-parity rebuild: every hook call must produce output byte-identical to
the inline race branch it replaces.

---

## 1. The problem -- race knowledge leaking upward into the envelope

PRISMA (115 functions, region-map module PRISMA, target `PDV_PrismaPresenter`) is the last and
largest extraction and the project's race-leak cost centre. Today PRISMA reaches per-race content
**by race identity** -- it hardcodes `ORIGIN_*` index comparisons and per-race literals directly
inside the layer whose only job is to assemble the JSON envelope. When PRISMA is cut into its own
module, every one of those race tests travels with it, and the envelope layer keeps a hard
dependency on the ten-race matrix. That is the leak D8 forbids.

### 1a. Region-map line numbers are stale (flag -- plan gap A2)

The PRISMA function ranges in `PDV_2_0RegionMap.json` were rebuilt from the pre-extraction golden
(`_parity_golden_manager.json`, 1351 decls, max line 28318). The current
`PDV__ManagerQuest.psc` is 10,736 lines. **The function NAMES in the region map are still valid;
the line ranges are not.** All line numbers in this document were re-derived by parsing the
current file. The eventual PRISMA extraction reads that region map, so A2 (rebuild the map) must
land before E2, or the extraction will seek functions at wrong offsets.

### 1b. The 8 full ten-race switches

Each of these branches across all ten `ORIGIN_*` races and returns `String`. (Line numbers are
current-file.)

| # | PRISMA function | line | switch shape |
|---|---|---|---|
| 1 | `GetPanelQuasiPatronName` | 2847 | inline per-race string literals (+ Khajiit focus delegate) |
| 2 | `GetPanelQuasiPatronSymbol` | 2876 | inline per-race string literals (+ Khajiit focus delegate) |
| 3 | `GetPanelQuasiPatronTierLabel` | 2907 | per-race delegate to `OriginRuntime.Get<Race>Label()` |
| 4 | `BuildBookOfDaysSummary` | 8097 | pure inline per-race string literals |
| 5 | `GetBookOfDaysPathStatusLabel` | 8042 | COMPOSITE -- envelope precedence ladder wraps the race switch |
| 6 | `GetSurveyDevotionText` | 8947 | COMPOSITE -- LEDGER wrap + DAEDRIC/Breton precedence wraps the race switch |
| 7 | `GetPlayerMcmSummaryLine` | 9000 | COMPOSITE -- startup gate + pact-wins; Nord field-structure divergent |
| 8 | `GetPlayerMcmModeLine` | 9056 | per-race delegate (+ startup gate; Argonian "Hist " prefix) |

That every one returns `String` is the empirical basis for the seam-depth ruling in Section 2:
finished text fragments suffice; no structured payload crosses the line.

### 1c. The 27 race-conditional branches

Beyond the 8 switches above, ~18 further PRISMA functions carry 1--7 race branches, for **26
race-touching PRISMA functions in total** (the plan's "27" counts the same population; the extra
one is `RepairBookOfDaysJournalText`, present in the region map but renamed/removed from the
current file -- a truth-up item, not a hook target). The lighter race-touching functions:

`GetPanelInstrumentKind` (2564), `ResolveShrinePrayerJournalLabel` (3208), `PushDevotionPanel`
(2255), `BuildModeChangeLine` (4275), `IsMedallionOptionAvailableForOrigin` (8743),
`GetJournalByline` (8397), `BuildBookOfDaysInstrumentJson` (8136), `BuildReorientationJournalLine`
(2225), `BuildBookOfDaysDigestLine` (4297), `GetPanelInstrumentDataJson` (2604),
`GetPanelPatronNote` (2667), `GetPanelRelationsJson` (2770), and a tail of single-branch readers
(`GetCurrentStandingLabel`, `SurfaceTransition`, `GetDashboardJson`, `AppendBookOfDaysEntry`,
`GetCurrentStandingBand`, `SendPrismaToastPayloadOrFallback`).

These lighter functions collapse the same way the 8 switches do (Section 3); they are secondary
targets, mapped at extraction time against the same frozen surface. The 8 ten-race switches are the
load-bearing cases and are fully specified here.

### 1d. Why this leaks

`GetPanelQuasiPatronName` is the clearest illustration (2847--2874): PRISMA holds the literal
strings `"Malacath"`, `"House Ancestors"`, `"Auri-El Foundation"`, keyed on `ORIGIN_ORC`,
`ORIGIN_DUNMER`, `ORIGIN_ALTMER`. Those literals are per-race theological CONTENT. Under D8 they
belong to ORIGIN. As long as they sit in PRISMA, the envelope layer cannot be extracted without
carrying the ten-race matrix, and any new race would require an edit inside the presenter.

---

## 2. The proposed hook -- extend the existing ORIGIN virtual surface

ORIGIN already collapsed 288 race-specific verbs into a small virtual interface (the adapter ADR).
Dispatch is a single bound property, resolved once per race:

- `PDV_OriginRuntimeBase Property OriginRuntime Auto` (`PDV__ManagerQuest.psc:738`) -- the one live
  binding; every cross-boundary call is `Manager.OriginRuntime.X()` and dispatches polymorphically.
- `ResolveOriginRuntime()` (`PDV__ManagerQuest.psc:883`) binds `OriginRuntime` from
  `PDV_FLST_OriginAdapters.GetAt(raceIndex)`. There is **no `GetAdapter(race)` call and no race
  switchboard** at the boundary -- race identity is object identity.

ORIGIN already exposes six presentation virtuals the hook reuses (base declarations, inert
defaults, overridden by every adapter):

```
String Function GetOriginStateLabel()               ; base :11958
Int    Function GetOriginStateValue()               ; base :11962
String Function GetOriginSummary()                  ; base :11966
String Function GetSurveyFragment()                 ; base :11970
String Function GetOriginDetailLabel(String detailKey)  ; base :11978
Int    Function GetOriginDetailValue(String detailKey)  ; base :11982
```

**The hook extends this same surface.** PRISMA pulls a race's presentation content via
`Manager.OriginRuntime.X()` and never tests race identity. Each of the 8 ten-race switches
collapses to a single virtual call, because the bound adapter already is the right race:

```
; BEFORE (in PRISMA, leaks race identity):
String Function GetPanelQuasiPatronName(Int originRace)
    if originRace == ORIGIN_ARGONIAN
        return "Saxhleel Practice"
    elseIf originRace == ORIGIN_ORC
        return "Malacath"
    ... (ten branches) ...

; AFTER (envelope-only; content owned by ORIGIN):
String Function GetPanelQuasiPatronName()
    String s = OriginRuntime.GetQuasiPatronName()
    if s == ""
        return "Devotion"           ; the no-race fallback stays envelope-side
    endIf
    return s
```

The per-race literals (and the Khajiit focus sub-logic) move into each adapter's override of
`GetQuasiPatronName()`. The ten-way `if/elseIf` disappears from the presenter.

### 2a. Keying rule (from the frozen ADR hybrid)

The ADR froze a hybrid surface: named virtuals for first-class recurring sections, plus a
string-keyed `GetOriginDetailLabel(detailKey)` table for tail content. The hook follows the same
rule, applied per switch:

1. If a switch's output already matches an existing named virtual, **reuse it** (switch #6 ->
   `GetSurveyFragment()`).
2. Else, if the switch is a first-class recurring presentation field (panel header, MCM line,
   Book-of-Days field), **add a new named virtual** (switches #1--#5, #7, #8).
3. Else (tail content, rarely rendered), **add a `detailKey` case** on the existing keyed table.

The 8 switches are all first-class panel/MCM fields, so the recommended set is 7 new named
virtuals + 1 reuse (Section 3). The ADR-purist alternative -- route all 7 through new `detailKey`
cases and add no named verbs -- is noted for the owner in Section 5; it trades type-safety for a
smaller frozen surface.

---

## 3. Frozen signatures (proposed -- ready to freeze)

Added on `PDV_OriginRuntimeBase` as concrete functions with inert defaults (Papyrus has no
`abstract`; the base default is the "wrong-origin is structurally silent" contract). Each of the
ten adapters re-declares the identical signature and delegates to its existing moved lane function.

```papyrus
; -- Presentation hook: panel quasi-patron header (no scoring patron) --
String Function GetQuasiPatronName()
    return ""
EndFunction

String Function GetQuasiPatronSymbol()
    return ""
EndFunction

String Function GetQuasiPatronTierLabel()
    return ""
EndFunction

; -- Presentation hook: Book of Days --
String Function GetBookOfDaysSummary()
    return ""
EndFunction

; Terminal per-race path label ONLY. The cross-module precedence ladder
; (startup gate, active pact, active patron, broad lane) stays in PRISMA.
String Function GetBookOfDaysPathFallbackLabel()
    return ""
EndFunction

; -- Presentation hook: MCM one-liners --
; standingLabel is the envelope-computed standing string, passed in so the
; adapter composes the exact per-race line without a Manager backref.
String Function GetMcmSummaryLine(String standingLabel)
    return ""
EndFunction

String Function GetMcmModeLine()
    return ""
EndFunction
```

Reused (already declared -- no new signature):

```papyrus
String Function GetSurveyFragment()     ; base :11970 -- scar composed via GetOriginDetailLabel("scar")
```

Adapter override idiom (verbatim shape, mirroring the existing `GetSurveyFragment` overrides):

```papyrus
; PDV_OriginRuntime_Orc.psc
String Function GetQuasiPatronName()
    return "Malacath"
EndFunction

; PDV_OriginRuntime_Khajiit.psc  -- per-race sub-logic moves into the adapter
String Function GetQuasiPatronName()
    Int focus = GetKhajiitFocusedEmphasis()
    if focus > 0
        return GetKhajiitFocusLabel(focus)
    endIf
    return "Lunar Lattice"
EndFunction
```

Envelope-side fallbacks (`"Devotion"`, `"journal"`, the generic Book-of-Days sentence, the
"Path Unsettled"/standing-band lines) stay in PRISMA: the base virtual returns `""` and the
presenter applies its terminal literal when the hook yields `""`. This keeps the "no race bound
yet" default in the envelope layer where it belongs and preserves byte-parity with today's
terminal `return` in each switch.

---

## 4. Parity note (byte-identical mapping; non-clean cases flagged)

Every switch maps to a hook call whose output is byte-identical to the inline branch. Five are
clean; three are composites that need care.

| # | switch | maps to | clean? |
|---|---|---|---|
| 1 | `GetPanelQuasiPatronName` | `GetQuasiPatronName()` + envelope `"Devotion"` fallback | CLEAN |
| 2 | `GetPanelQuasiPatronSymbol` | `GetQuasiPatronSymbol()` + envelope `"journal"` fallback | CLEAN |
| 3 | `GetPanelQuasiPatronTierLabel` | `GetQuasiPatronTierLabel()` | CLEAN (per-race prefixes move into the adapter) |
| 4 | `BuildBookOfDaysSummary` | `GetBookOfDaysSummary()` + envelope generic fallback | CLEAN (pure literals) |
| 8 | `GetPlayerMcmModeLine` | `GetMcmModeLine()`, PRISMA keeps startup gate + patron-state default | CLEAN (Argonian "Hist " prefix moves into the adapter) |
| 5 | `GetBookOfDaysPathStatusLabel` | `GetBookOfDaysPathFallbackLabel()` for the TAIL ONLY | NON-CLEAN (see 4a) |
| 7 | `GetPlayerMcmSummaryLine` | `GetMcmSummaryLine(standingLabel)` | NON-CLEAN (see 4b) |
| 6 | `GetSurveyDevotionText` | reuse `GetSurveyFragment()` + append `GetOriginDetailLabel("scar")` | NON-CLEAN (see 4c) |

For the clean cases (#1--#4, #8) parity is mechanical: the per-race literal or per-race delegate
call moves verbatim into the adapter override; the presenter loses the switch and gains one call.
`GetPanelQuasiPatronTierLabel` (#3) already delegates per race to `OriginRuntime.Get<Race>Label()`
(2907--2934) -- the hook merely relocates the dispatch from a PRISMA switch to adapter identity,
carrying the `"Focused: "` / `"Ancestor layer: "` prefixes into the respective overrides.

### 4a. Non-clean #5 -- `GetBookOfDaysPathStatusLabel` is a precedence ladder, not a race switch

The function (8042--8093) interleaves envelope-level precedence with the terminal race switch:

1. startup-complete gate -> `"Path Not Yet Chosen"` (envelope; StorageUtil);
2. Breton early return -> `OriginRuntime.GetBretonBookOfDaysPathStatusLabel()` (already ORIGIN);
3. active DAEDRIC pact -> pact name (cross-module: DAEDRIC);
4. active patron -> patron display name (cross-module: LEDGER);
5. broad-lane state -> `OriginRuntime.GetBroadLaneDisplayName(originRace)` (already ORIGIN, keyed);
6. the ten-race fallback switch (with per-race prefixes `"Crisis "`, `"Hist "`, `" Lunar Focus"`,
   `" Reclamation Focus"`, `"Ancestor Rites "`).

**Only step 6 is the race switch.** The hook replaces step 6 with
`OriginRuntime.GetBookOfDaysPathFallbackLabel()`; steps 1--5 are genuine envelope precedence
(they query DAEDRIC and LEDGER, which the envelope legitimately owns) and stay in PRISMA. The
boundary is "one race-switch -> one hook call," not "one function -> one hook call."

### 4b. Non-clean #7 -- `GetPlayerMcmSummaryLine` has a Nord-divergent field structure

The nine non-Nord branches build `"<RaceName> | <mode label> | <standing>"` (e.g.
`"Altmer | " + GetAltmerCrisisStateLabel() + " | " + GetCurrentStandingLabel()`, 9014--9031). The
Nord branch (9012--9013) builds a **different three-field line**:
`GetNordDevotionModeLabel() + " | " + GetCurrentStandingLabel() + " | " + GetPlayerCursePublicLabel()`
-- no race-name prefix, and it appends a curse label the others omit.

Because the field structure itself varies by race, the whole per-race line is per-race CONTENT.
The hook gives the adapter ownership of its entire line via `GetMcmSummaryLine(String
standingLabel)`: PRISMA computes the envelope `standingLabel` once (`GetCurrentStandingLabel()`)
and passes it in; each adapter returns its exact format (Nord returns its three-field curse
variant; others return race-name/label/standing). PRISMA keeps the startup gate (9001) and the
pact-wins early return (9007--9010). This preserves byte-parity including Nord's divergence,
without any adapter->Manager backref.

### 4c. Non-clean #6 -- `GetSurveyDevotionText` drops the Nord scar under a naive reuse

The function (8947--8995) wraps everything in `LedgerRuntime.AppendRecentDevotionEvents(...)` and
applies precedence: unbound-race message, Breton layered early return, DAEDRIC pact-wins, then the
per-race switch calling `OriginRuntime.Get<Race>SurveyText()`. The race tail maps to the existing
`GetSurveyFragment()` virtual -- **except Nord**.

Verified: Nord's `GetSurveyFragment()` returns base text only:

```papyrus
; PDV_OriginRuntime_Nord.psc:62-64
String Function GetSurveyFragment()
    return GetNordSurveyBaseText()
EndFunction
```

But `GetSurveyDevotionText` appends the scar for Nord (8988--8992):
`text = GetNordSurveyBaseText() + "\n\n" + GetNordScarLabel()`. A naive "replace the tail with
`GetSurveyFragment()`" **silently drops the scar line** -- a real parity break.

Resolution (parity-preserving, race-agnostic): the scar is already reachable as a detail key --
Nord's adapter answers `GetOriginDetailLabel("scar")` -> `GetNordScarLabel()`
(`PDV_OriginRuntime_Nord.psc:88`). PRISMA composes:

```papyrus
String frag = OriginRuntime.GetSurveyFragment()
String scar = OriginRuntime.GetOriginDetailLabel("scar")
if scar != ""
    frag = frag + "\n\n" + scar
endIf
return LedgerRuntime.AppendRecentDevotionEvents(frag)
```

This is byte-identical for Nord (scar non-empty) and for every other race (scar `""` -> no append,
so the base default keeps them unchanged). The LEDGER wrap and the DAEDRIC/Breton precedence stay
PRISMA-side. The unbound-race message and the standing-band fallback (8985) remain envelope
literals applied when `GetSurveyFragment()` is `""`.

### 4d. Flag for the owner

The three non-clean cases (#5, #6, #7) share one shape: an envelope precedence ladder wraps a
race switch. The hook replaces the race switch inside them, not the whole function; the
cross-module ladders (DAEDRIC pact, LEDGER patron/append, startup gate, broad lane) are genuine
envelope logic and stay in PRISMA. #6 additionally needs the scar-compose fix or Nord loses a
line silently.

Recommendation: accept the tail-replacement mapping for #5/#6/#7 and the scar-compose fix for #6.
At extraction, verify each adapter's `GetSurveyFragment()` reproduces its old
`Get<Race>SurveyText()` byte-for-byte (they should -- the override already delegates to the same
lane function the switch called); a one-shot parity fixture over the ten survey outputs closes it.

---

## 5. RECOGNITION feed and open questions

### 5a. RECOGNITION feed (out of D1's hook surface, remap point documented)

`GetNpcRecognitionPanelJson()` (`PDV__ManagerQuest.psc:9693`) is concatenated into the panel
payload at `PDV__ManagerQuest.psc:2391` (inside `PushDevotionPanel`):

```
j = j + ",\"recognition\":" + GetNpcRecognitionPanelJson()
```

RECOGNITION is its own module (region-map module RECOGNITION, 31 functions), extracted in **E1
before PRISMA (E2)** -- producer-first, so the concatenation site is remapped exactly once. D1
does **not** absorb the recognition feed into the ORIGIN hook: recognition content is
RECOGNITION-owned, not ORIGIN-owned. D1 records only the remap: after E1/E2 the site reads
`Recognition.GetNpcRecognitionPanelJson()` (RECOGNITION module ref), and the ORIGIN presentation
hook is orthogonal to it. If RECOGNITION carries its own race branches, those are a RECOGNITION
design concern, not part of this hook.

### 5b. Open questions for the owner

1. **Named virtuals vs `detailKey` for the 7 new sections.** Recommended: named virtuals (the 8
   switches are all first-class panel/MCM fields; type-safe dispatch, compiler-checked, a clean
   one-switch->one-verb parity table). Alternative: route all 7 through new `GetOriginDetailLabel`
   cases and add zero named verbs (smaller frozen surface, but re-imports a string-keyed lookup
   the adapter ADR existed to remove). Decide before freeze.
2. **Fallback ownership.** Recommended: the terminal no-race fallbacks (`"Devotion"`, `"journal"`,
   the generic Book-of-Days sentence, the standing-band line) live in PRISMA (envelope), with the
   base virtual returning `""`. Confirm this rather than pushing the fallback into the base default.
3. **`GetMcmSummaryLine` parameterization.** Recommended: pass the envelope-computed
   `standingLabel` in as a param (no adapter->Manager backref). Confirm vs. the alternative of the
   adapter calling back to `Manager.GetCurrentStandingLabel()` (which would introduce a backref
   this design otherwise avoids).
4. **The `RepairBookOfDaysJournalText` region-map entry** (present in the map, absent from the
   current file) -- confirm removed/renamed so A2 drops it; not a hook target either way.
