# Death-Stakes -- Feasibility

**Status:** DESIGN DOSSIER, 2026-06-11. Honesty bar = `03_feasibility.md`
(living-deities series). No in-game proof exists for any mechanism here.
Proof is listed explicitly as a required gate for each seam.

---

## 1. Death Detection

Three candidate mechanisms for catching "the moment of death."

---

### 1A. OnDying on the Player Alias (RECOMMENDED)

**What it is:** `OnDying(Actor akKiller)` is a Papyrus alias event that fires
on the player alias when the player's health reaches 0 and the death sequence
begins. It fires before the death camera. It is in-scope for `PDV_PlayerEvents`
(extends `ReferenceAlias`), which already handles `OnLycanthropyStateChanged`,
`OnVampirismStateChanged`, `OnSleepStart`, `OnSleepStop`, and similar
life-events on the player alias.

**Live seam:** `PDV_PlayerEvents.psc` (the existing player alias script).
The file already registers for player events in `RegisterForPlayerEvents()`
(live ~:345). Adding `Event OnDying(Actor akKiller)` is a new event handler in
the same script -- recomposition of an existing script, not greenfield.

**Confidence:** High for the event firing. Moderate for timing: `OnDying` fires
in the same frame as the death, before `OnDeath`. The health is not yet at 0
when it fires (the killing blow just registered), so `GetActorValuePercentage("Health")`
at the event moment may return a very small positive number. Read mood-band from
`PDV_GLO_PatronMoodBand` (a global, readable without a live script call) rather
than calling into the manager.

**Edge case: essential player.** If the player has "essential" status (a known
modlist setting sometimes used with certain mods), `OnDying` fires but the
player enters bleedout rather than dying. The soul-fate flag would still be
written. This is acceptable behavior (the near-death is real) but should be
noted in the CK wiring proof.

**Edge case: Death Alternative / Sands of Time.** These mods hook into the
death sequence via a similar alias event or an MGEF `OnEffectStart` that fires
at near-death. They intercept before full death. `OnDying` should still fire
because it fires at health = 0, before DA's intercept resolves the player state.
Confirmation required in-game: fire `OnDying`, confirm the flag writes, confirm
DA still catches the death. Mark as PROOF REQUIRED.

**Edge case: instant-kill triggers.** Some scripted deaths (e.g. certain quest
events that set health to 0 directly via script) may bypass `OnDying`. This is
a rare edge case for V1 and acceptable given the one-shot nature of the flag.

**Recomposition vs. greenfield:** recomposition. Add one event handler to
`PDV_PlayerEvents.psc`. Call one new manager function via the existing
`PDV_EventBusService` or direct manager property pattern.

**In-CK/in-game proof required:** Yes. Confirm `OnDying` fires on player alias
in SSE 1.6.x (the event is documented in SKSE's Papyrus extension). Confirm
the flag write is visible in StorageUtil after a test death. Log path:
`Logs\Script\Papyrus.0.log`.

---

### 1B. Low-Health Threshold in PDV_T3DailyLowHealthSaveEffect (NOT RECOMMENDED)

**What it is:** The existing `PDV_T3DailyLowHealthSaveEffect.psc` (live)
already polls `GetActorValuePercentage("Health") <= TriggerHealthPercent`
(default 10%) in a `RegisterForSingleUpdate(2.0)` loop. Adding a soul-fate
check inside `TryApplyDailySave()` (live :49) would piggyback on this
existing mechanism.

**Cost:** Free to wire into the existing polling loop. But there are two
problems:

1. The daily-save fires at 10% health, not at true death. Players who survive
   a near-death will get their soul-fate flag set prematurely. This is
   semantically wrong -- the soul-fate should reflect the deity's actual claim
   at the moment of death, not a dangerous-but-survived fight.

2. The daily-save MGEF is only active while a T3 boon is applied. If the
   player dies without having the MGEF active (e.g. no patron, or patron is
   Neglected), the hook never fires. This breaks the design intent that all
   players get a soul-fate flag.

**Verdict:** Not recommended. Use only as a V1 fallback if `OnDying` proves
unreliable in-game for reasons discovered during proof.

---

### 1C. No Detection -- Flag at Dawn If Health Evidence Exists (NOT RECOMMENDED)

**What it is:** If the player died and reloaded, a script cannot detect the
reload directly. However, some mods detect this via a persistent counter
incremented before death. PDV does not currently have such a counter.

**Cost:** Requires authoring a pre-death counter (written in the OnDying handler
anyway) plus a dawn-check that infers death from a flag mismatch. This is more
complex than 1A and less reliable.

**Verdict:** Not recommended.

---

## 2. Mood-at-Death Capture

**Seam:** `PDV_GLO_PatronMoodBand` (GlobalVariable, authored in LD-P1; see
`04_living_deities_architecture.md` section 2.3). This global mirrors the active
patron's current band (0 = Wroth, 1 = Cool, 2 = Pleased, 3 = Exalted).
Reading a GlobalVariable in `OnDying` is safe -- it is a synchronous read with
no Papyrus stack concern.

**Confidence:** High, conditional on LD-P1 being live. `PDV_GLO_PatronMoodBand`
does not exist in the current live source -- it is a new LD-P1 global. If
death-stakes ships before LD-P1, a fallback read is needed (read mood from
StorageUtil via the manager's `GetCurrentMoodBand(deity)` helper, but calling
into the manager from `OnDying` may cause stack timing issues during death).

**Recommended approach:** Read `PDV_GLO_PatronMoodBand` in `OnDying`. Gate on
`LD_P1_PatronMoodBandAvailable` flag (int StorageUtil key, set by LD-P1 on
first `RunDawnUpdateMood()` completion). If the flag is absent, defer soul-fate
write to the next dawn (degrade gracefully without LD-P1).

**In-CK/in-game proof required:** Yes. Confirm the global is readable in
`OnDying` timing. Confirm it does not return stale data during the death frame.

---

## 3. Soul-Fate Flag + StorageUtil Write

**Seam:** `StorageUtil.SetIntValue(None, "PDV.SoulFate.Written", 1)` and
`StorageUtil.SetStringValue(None, "PDV.SoulFate.Destination", "<string>")`.
The None-keyed pattern is already used for global state throughout the manager
(e.g. `PDV.Commitment.*`, `PDV.Intervention.Sacrifice.*` in the A3
architecture). This is zero-cost recomposition.

**Confidence:** High. StorageUtil reads/writes in `OnDying` are fast synchronous
calls. No concern about the death frame interrupting a write.

**Proof required:** Confirm StorageUtil persists across reload (it does by
design -- StorageUtil is save-file-backed). Confirm the key is readable in the
survey text function after a reload.

---

## 4. Marked Toast Surface

**Seam:** `SendPrismaEventToast(String eventName, PDV_DeityBase deity, String context, String tierLabel, String rival)`
(live `PDV__ManagerQuest.psc:1245`). This is the existing toast path used for
tier-up, neglect, commitment events. Death-stakes fires a new `"soul_fate"`
event type through the same surface.

**Concern:** `SendPrismaEventToast` requires a `PDV_DeityBase` reference. In
`OnDying`, the manager is not directly accessible unless `PDV_PlayerEvents` has
a manager property. The existing alias script already holds `PDV_EventBusService`
and `PDV_OriginQuest` properties. A `PDV__ManagerQuest` property can be added
in the same pattern.

**Alternative:** Route through a new ModEvent fired from `OnDying` and caught
by the manager's alias event handlers. This avoids a direct property on the
alias script but adds latency. For a one-shot Marked beat, latency is
acceptable; however, the direct property is simpler.

**Fallback:** `Debug.Notification()` if Prisma absent. The existing pattern in
`SendPrismaEventToast` already degrades to notification.

**In-CK/in-game proof required:** Yes. Confirm the toast fires during the
death-fade frame (the engine does briefly pause before the camera cuts). If
the toast is suppressed by the death transition, degrade to a journal-style
surface on the next load screen.

---

## 5. Summary Verdict Table

| Mechanism | Seam | Confidence | Recomposition? | Proof required |
|---|---|---|---|---|
| OnDying on player alias | `PDV_PlayerEvents.psc` (add event handler) | High | Yes -- one event handler | In-game: confirm fires, confirm flag writes, DA compat |
| Mood-band read at death | `PDV_GLO_PatronMoodBand` (LD-P1 global) | High (LD-P1 dep) | Yes -- read existing global | Confirm not stale in death frame; LD-P1 availability gate |
| Soul-fate StorageUtil write | None-keyed `PDV.SoulFate.*` keys | High | Yes -- None-keyed pattern | Confirm persists across reload |
| Marked toast at death | `SendPrismaEventToast` (live :1245) | Moderate | Yes -- new event type | Confirm toast fires during death frame; fallback |
| Survey text extension | `GetNordSurveyBaseText()` pattern | High | Yes -- same pattern as VampireActive check | No new proof needed; confirmed in Nord vampire path |

**Overall feasibility verdict: buildable, LD-P1-dependent.**
The entire mechanism is recomposition of live seams. The only greenfield element
is the `OnDying` event handler and the `PDV.SoulFate.*` StorageUtil keys.
The critical dependency is `PDV_GLO_PatronMoodBand` from LD-P1 -- without it,
mood-at-death degrades to piety-at-death (readable from StorageUtil without
LD-P1) but the band-gated semantic is lost. Proof gates are honest: none of
this is runtime-proven; all items in the proof column require in-game
verification.
