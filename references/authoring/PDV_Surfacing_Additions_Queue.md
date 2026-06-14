# PDV Surfacing Additions Queue

**Purpose.** Player-facing surface additions requested during beta testing that
live in `PDV__ManagerQuest.psc`. They were held here until the consolidated
single-writer manager pass because the manager `.psc` at
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source\` is not git-tracked,
so concurrent hand-edits can be clobbered by a later recompile.
**Status:** built in the 2026-06-14 consolidated manager pass after the voice
port landed. The live deployed manager now carries the Rajhin and Alkosh
top-left notices, Prisma toasts, and Survey recent-events buffer described
below. `node .\tools\pdv_compile.mjs --script PDV__ManagerQuest` compiled the
manager with 0 errors / 0 warnings; runtime/manual new-save confirmation remains
pending.

**D0 note.** These are D0-live floor surfaces, the same class as the neglect
vanilla `Debug.Notification` fallback (`PDV__ManagerQuest.psc:5851`) and the live
`SendPrismaShiftToast(...)` posture/focus toasts. They are NOT the D0-GATED-OFF
`SurfaceTransition -> DiegeticDirector` transition toasts (memory
`diegetic-surfacing-d0-gated`); both can ship at D0.

---

## 1. Khajiit Rajhin elegant theft (route 91) -- two surfaces

**Built 2026-06-14:** `HandleKhajiitRajhinElegantTheft(...)` now emits the
top-left notice `Rajhin purrs. That theft had style.`, sends a Rajhin Prisma
toast, and appends `Rajhin: theft with style` to the capped recent-events
Survey buffer at the same gated route site.

**Why:** in beta testing 2026-06-14 the elegant-theft beat fired correctly
(`Khajiit Rajhin elegant theft detected`, focus +25, curated signal 801, +0.40
Rajhin, ShadowDrift evidence) but produced NO on-screen feedback. User wants a
left-side notice now and a Prisma toast at the same site.

**Site:** `HandleKhajiitRajhinElegantTheft(String reason)` in
`PDV__ManagerQuest.psc` (body at ~`:3404`-`:3407`; the function with the
`RecordKhajiitFocusSignal(KHAJIIT_FOCUS_RAJHIN, "PDV.Signal.KhajiitRajhinElegantTheft", ...)`
+ `RecordKhajiitShadowEvidence("rajhin_night_theft_" + reason)` calls, directly
above `HandleKhajiitAlkoshDragonOrder` at `:3409`). Add both surfaces before the
function's `EndFunction`, so they ride the route's existing **per-target 7-day
cooldown** gate (no anti-spam work needed -- the surface only fires when the
beat itself fires).

### 1a. Left-side notification (D0 floor) -- REQUESTED, build first
- **Mechanism:** raw `Debug.Notification("...")`, modeled exactly on the neglect
  fallback at `PDV__ManagerQuest.psc:5851`.
- **Voice/budget:** Content Destination Matrix "Contextual favor (Noted)" =
  Player-2nd, HUD NOTI, 80 hard / 60 target chars, ASCII only. Match the existing
  in-world Khajiit notification register (e.g. `:3062` `"Baan Dar opens the gap. Run."`).
- **Draft copy (finalize in voice pass):** Rajhin = the Purring Liar, performer's
  voice, delighted by theft done with style. Options:
  - `"Rajhin purrs. That theft had style."`
  - `"A clean lift -- the Purring Liar is pleased."`

### 1b. Prisma toast (co-located) -- REQUESTED, note as also-wanted
- **Mechanism:** `SendPrismaShiftToast(label, readout, symbol)`, modeled on the
  Khajiit focus-shift toast at `PDV__ManagerQuest.psc:4475`
  (`SendPrismaShiftToast(GetKhajiitFocusLabel(focusValue), GetKhajiitFocusShiftText(focusValue), GetKhajiitFocusSymbol(focusValue))`).
- **Spec:** fire on the elegant-theft BEAT (not only on a focus-weight shift).
  Label = the elegant-theft beat; symbol = Rajhin's focus symbol
  (`GetKhajiitFocusSymbol(KHAJIIT_FOCUS_RAJHIN)`); readout = a short Rajhin line.
- **Budget/voice:** Prisma overlay toast = symbol-led, minimal, 60/40 (Matrix Sec 5).

---

## 2. Khajiit Alkosh word-of-power drip (route 92, DAWN drip) -- two surfaces

**Built 2026-06-14:** `ProcessKhajiitAlkoshWordDrip()` now emits the top-left
notice `Alkosh marks the words you have learned.`, sends an Alkosh Prisma toast,
and appends `Alkosh: <n> words marked` to the recent-events Survey buffer when
the dawn drip awards at least one word.

**Why:** in beta testing 2026-06-14 the drip fired correctly (`Khajiit Alkosh
word-of-power drip awarded 2 of 2 new words`, Papyrus.0.log 02:19:46) but produced
NO on-screen feedback. User wants a left-side notice + Prisma toast here too.

**Site:** `ProcessKhajiitAlkoshWordDrip()` in `PDV__ManagerQuest.psc` (~`:1197`-`:1224`),
after the award loop at `:1224` (`Trace(2, "...drip awarded " + awarded + ...")`),
gated on `awarded > 0` so it only surfaces when words were actually credited.

**Nuance vs. Rajhin:** this is a once-per-DAWN SUMMARY award (up to 3 words/dawn,
remainder carried), NOT a real-time beat. So the notice should summarize once at
dawn -- e.g. `"Alkosh marks the words you have learned."` -- not one line per word.
Same mechanisms as 1a/1b (Debug.Notification + SendPrismaShiftToast, symbol =
`GetKhajiitFocusSymbol(KHAJIIT_FOCUS_ALKOSH)`). Copy finalized in the voice pass.

---

## Player confirmation & legibility (DESIGN DECISION -- raised by user 2026-06-14)

**Problem:** at D0 a player has no reliable way to CONFIRM a beat fired. The only
surfaces are the few generic fallbacks, the just-added neglect notice, and the
Survey -- and the Survey is a status SNAPSHOT (current standing), not an event LOG
("what just happened"). Transient top-left notices / toasts help in the moment but
are easy to miss and leave nothing to review.

**This supersedes the earlier "only signature beats?" question.** Direction:
signature beats DO need real-time confirmation (top-left + optional toast, per
sections 1-2), AND players need a persistent way to review notices.

**DECISION (user 2026-06-14): Option B -- the Survey "recent events" log.**
Real-time top-left + toast notices on signature beats ship alongside (sections
1-2). The diegetic journal (former Option C) is DEFERRED as a post-beta immersion
upgrade, NOT a V1 blocker.

**Built in the consolidated manager pass (`PDV__ManagerQuest.psc`):**
- `RecordRecentDevotionEvent(String line)` -- a FIFO ring buffer in StorageUtil
  (cap ~8 entries, drop oldest), one short ASCII line per player-relevant beat
  (e.g. `"Rajhin: a theft with style"`, `"Alkosh: 2 words marked"`, `"Y'ffre's
  regard fades"`).
- Call it at the SAME sites as the top-left notices (sections 1-2 + the other
  signature beats), so notice + toast + log-append are ONE co-located add per site.
- `GetRecentDevotionEventsText()` -- renders the last N entries as a "Recent:"
  block appended to the existing Survey readout. Voice per the Survey rows of the
  Content Destination Matrix.
- No new dependency; reuses the Survey the player already opens.

**Deferred (post-beta): Option C, the DiegeticUX journal channel** (Dynamic Book
Framework). Non-voiced, so V1-eligible whenever wanted -- the V1/V2 line is voiced
content (Arch v3 Sec 21.3), not the journal. Reconcile this whole decision into
`PDV_DiegeticUX_ArchitectureSpec.md` + the v3 roadmap when the consolidated pass lands.

---

## Cross-refs
- Precedent: neglect vanilla fallback `PDV__ManagerQuest.psc:5851`; live Prisma
  toasts `:3640`/`:4475` (posture/focus).
- Voice/budget authority: `race-sheets/PDV_ContentDestinationMatrix.md` (Sec 2
  Contextual favor + Prisma toast rows; Sec 5 cheat sheet).
- Copy must be voice-conformed via `PDV_VoiceConformancePass_Plan.md`.
- D0 gating context: memory `diegetic-surfacing-d0-gated`.
- Test evidence: `PDV_Khajiit_BetaFeelPacket.md` Section 2 (Rajhin), Papyrus.0.log
  2026-06-14 01:16:16.
