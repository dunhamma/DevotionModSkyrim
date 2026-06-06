# PDV Diegetic UX — Architecture Spec

**Status:** Architecture / design-locked spec. Pairs with
`references/authoring/PDV_ImmersiveUX_DiegeticSurfaces_Buildout.md` (rationale + tools) and
`references/authoring/PDV_ImmersiveUX_Samples.md` (visual + copy samples). **Codex handoff:**
`handoff/PDV_DiegeticUX_CodexHandoff.md`.
**Date:** 2026-06-05
**Owner split (repo convention):** Claude owns this architecture + the copy/art contracts below;
**Codex owns all code, CK record creation, and wiring.**

---

## 0. The one-sentence architecture

The diegetic UX layer is a **channel fan-out bolted onto the existing §16.7 `SurfaceTransition()`
helper**: when a transition is surfaced, a new `PDV_DiegeticDirector` reads a static **surface
profile** for that transition and calls a fixed set of **soft-dependency-gated channel emitters**
(screen, sound, music, journal, medallion, body-mark, anim). It is a *discipline over existing
systems* — exactly like §16.7 itself — **not a new UI system and not a new native DLL.**

### Why this shape
- **It reuses the backbone we already have.** §16.7 already centralizes every state transition
  through one helper with per-direction one-shot guards (`PDV.Surfaced.*`). The diegetic layer hangs
  off that single call site; nothing else in the mod has to know diegetic surfaces exist.
- **No new C++.** Every channel is reachable from Papyrus: imagespace and effect shaders (vanilla +
  po3 PE), sound/music (vanilla records), journal (Dynamic Book Framework Papyrus API), medallion
  (Description Framework Papyrus API), body marks (RaceMenu/NiOverride), animation (OAR is
  condition-driven data). The only existing native — the Prisma bridge — is **untouched**.
- **Soft-dep safe.** Each emitter no-ops if its framework is absent; PDV degrades to its current
  non-diegetic surfaces. Honors "Compatibility is trust."
- **Non-voiced.** Every channel is inside the §21.3 / §16.3 boundary. SPID stance is config-only and
  passive; nothing here speaks.

---

## 1. Component map

```
                         (existing)                          (new — this spec)
  signal/event ──▶ PDV_EventBus ──▶ PDV__ManagerQuest
                                         │
                                         ├─ SurfaceTransition(class,key,dir)   §16.7  (existing)
                                         │     1. one-shot guard  PDV.Surfaced.*
                                         │     2. level → Notification/MessageBox  §16.2
                                         │     3. Prisma toast  SendOverlayJson()  §16.6
                                         │     4. ▼ NEW: fan-out
                                         │     PDV_DiegeticDirector.Dispatch(class,key,dir,deity,tone)
                                         │
                  PDV_DiegeticDirector ──┤  reads GetSurfaceProfile(class,dir) → {tone, channels[]}
                                         │  calls each enabled+available channel emitter:
                                         │
   ┌─────────────┬─────────────┬────────┴────┬─────────────┬─────────────┬─────────────┐
   ▼             ▼             ▼             ▼             ▼             ▼             ▼
 EmitScreen   EmitSound   EmitMusicState  EmitJournal  RefreshMedallion SetBodyMark  EmitPrayerAnim
 IMAD+EFSH    SNDR        MUSC add/remove  DBF append   DF SetDescription NiOverride   OAR condition
 (vanilla/po3)(vanilla)   (vanilla)        (soft-dep)   (soft-dep)        (baseline)    (engine-only)

 PDV_DiegeticDeps : cached availability probes (DF / DBF / NiOverride / OAR / po3 PE)
 SPID _DISTR.ini  : passive, reads existing PDV_GLO_* globals (no emitter)
 PDV_MCM          : verbosity preset Silent | Transitions-only | Verbose  → enables/mutes channels
```

### New Papyrus scripts (Codex creates)
| Script | Role |
|---|---|
| `PDV_DiegeticDirector.psc` | The fan-out. `Dispatch()`, `OnLoad()`, the profile table, the channel emitters (or thin calls to them). Attached to a framework quest. |
| `PDV_DiegeticDeps.psc` | One-time availability probes, cached bools, re-probed on load. |

No other new scripts are required; the curse channel hooks the **existing** `PDV_CurseState.psc`
transition-notification hook (§17.0 #6), and the rite/anim trigger sits at the **existing** token /
shrine route sites.

---

## 2. Fixed interfaces (freeze these; add, never rename/remove)

### 2.1 Closed vocabularies
- **Event classes** (existing §16.7): `tier | emergence | curse | reorientation | neglect`.
- **Directions** (existing): `onset` / `clear` style per class (e.g. curse `onset`/`cure`, neglect
  `drop`/`recover`, tier `reach`).
- **Tones** (new closed set): `reverent | revelation | dread | release | turning | absence |
  apotheosis | quiet`.
- **Channels** (new closed set): `screen | sound | music | journal | medallion | bodymark | anim |
  notify`.

### 2.2 StorageUtil namespaces
- `PDV.Surfaced.*` — **existing** one-shot transition guards. Untouched.
- `PDV.Diegetic.*` — **new**, save-persistent. Sub-keys:
  - `PDV.Diegetic.Dep.<name>` → int bool (cached availability).
  - `PDV.Diegetic.Music.<stateKey>` → int bool (is this music state currently applied).
  - `PDV.Diegetic.Mark.<markKey>` → int bool (is this body overlay currently applied).
  - `PDV.Diegetic.MedallionDirty` → int (rebuild requested).
  - `PDV.Diegetic.Verbosity` → int (0 Silent / 1 Transitions / 2 Verbose).

### 2.3 Public function signatures (the contract Codex implements)
```papyrus
; --- PDV_DiegeticDirector.psc ---
; Called by SurfaceTransition() AFTER it sets its one-shot guard.
Function Dispatch(String eventClass, String key, String direction, Int deityIndex, String toneOverride = "")

; Re-assert non-persistent surfaces after load (DF descriptions, body marks, dep probes, music).
Function OnLoad()

; Direct rebuild of the medallion text from current piety state (also called on dawn + load).
Function RefreshMedallion()

; Channel emitters (soft-dep gated internally; safe to call unconditionally):
Function EmitScreen(String tone)
Function EmitSound(String tone)
Function EmitMusicState(String stateKey, Bool enable)
Function EmitJournal(Int deityIndex, String toneKey)
Function SetBodyMark(String markKey, Bool enable)
Function EmitPrayerAnim(String poseKey)         ; sets the OAR condition var + plays the idle

; --- PDV_DiegeticDeps.psc ---
Bool Function Has(String depName)               ; "DF" | "DBF" | "NiOverride" | "OAR" | "PO3"
Function Reprobe()                              ; on load
```

### 2.4 The single integration edit (everything else is additive)
In `SurfaceTransition()` (§16.7), after the guard is set and the existing Notification/MessageBox/
toast routing runs, add exactly one line:
```papyrus
PDV_DiegeticDirector.Dispatch(eventClass, key, direction, deityIndex, toneOverride)
```
That is the *only* change to existing flow. The Director owns everything downstream.

---

## 3. The surface-profile table (the heart of the design)

`GetSurfaceProfile(eventClass, direction)` returns a tone + the channel set. Static data; implement as
a Papyrus dispatch or a StorageUtil-seeded table. **This table is the design** — tuning is a data
edit, not new code.

| eventClass · direction | tone | screen | sound | music | journal | medallion | bodymark | notify (§16.2) |
|---|---|---|---|---|---|---|---|---|
| `tier` · reach | reverent | gold bloom + aura | soft chime | — | ✔ | ✔ | — | Medium (Notification) |
| `emergence` · onset | revelation | white bloom + sun | low swell | — | ✔ | ✔ (active flips) | warpaint on | **Loud (MessageBox)** |
| `curse` · onset | dread | cold vignette + shroud | hollow tone | curse bed ON | ✔ | ✔ (dims) | **scar on** | **Loud (MessageBox)** |
| `curse` · cure | release | clearing fade + shimmer | rising chime | curse bed OFF | ✔ | ✔ (brightens) | **scar off** | **Loud (MessageBox)** |
| `reorientation` · switch | turning | brief neutral fade | tonal click | sect motif (opt) | ✔ | ✔ (label flips) | — | Medium (Loud if major) |
| `neglect` · drop | absence | slow desaturate | distant tone | — | ✔ | ✔ (greys) | — | Medium (Notification) |
| `neglect` · recover | reverent | faint gold | soft chime | — | ✔ | ✔ | — | Quiet (silent) |
| `favor` · routine (NOT a §16.7 class) | quiet | — | optional tiny chime* | — | **dawn digest only** | live | — | **silent** |
| `champion` (= emergence at Devoted) | apotheosis | strong gold + sustained | full swell | champion motif | ✔ | ✔ (radiant) | full warpaint | **Loud (MessageBox)** |

`*` routine favor cue only when Verbosity = Verbose. Routine favor is **not** routed through
`SurfaceTransition()` — it updates the medallion/journal-digest directly to avoid touching the
one-shot machinery.

### Verbosity preset → channel mask
| Preset | screen | sound | music | journal | medallion | bodymark | notify | Prisma toast |
|---|---|---|---|---|---|---|---|---|
| **Silent** (diegetic default) | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | MessageBox only (real choices) | off |
| **Transitions-only** | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | + tier/neglect Notifications | off |
| **Verbose** | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | all | on |

This is the explicit answer to "do we remove toasts": **toasts demote to the Verbose preset**;
MessageBoxes for real choices always stay; routine notifications default off.

---

## 4. Channel contracts (record types + Papyrus method, per channel)

### 4.1 `screen` — imagespace + effect shader
- **Records (CK):** one **IMAD** per tone (`PDV_IMAD_Reverent/Revelation/Dread/Release/Turning/Absence/Apotheosis`); one **EFSH** (+ optional **ARTO**/**RFCT**) per tone, carried by a self-target **SPEL** ability (`PDV_Abil_Shader_<tone>`).
- **Papyrus:** `ImageSpaceModifier.ApplyCrossFade()` (vanilla) for the tint; cast/add the ability for the aura, remove after `Utility.Wait(duration)` or via a short magic-effect duration. po3 PE direct effect-shader apply is the alternative if cleaner.
- **Rules:** duration ≤ ~1.5s for pulses. The only *sustained* screen state is the curse shroud, tied to `PDV_CurseState`; cleared on cure.

### 4.2 `sound` — discrete cue
- **Records:** **SNDR/SOUN** per cue (`PDV_SND_Chime/Hollow/Swell/RisingChime/Click/Distant`).
- **Papyrus:** `Sound.Play(PlayerRef)`.

### 4.3 `music` — ambient bed
- **Records:** **MUSC/MUST** (`PDV_MUS_PatronPrayer`, `PDV_MUS_CurseBed`, opt `PDV_MUS_MoonNight`).
- **Papyrus:** add the music type on state-enter, remove on state-exit (the formlist/`MusicType.Add/Remove` pattern). Track applied state in `PDV.Diegetic.Music.*`; must be reversible and never stomp combat/quest music.

### 4.4 `journal` — Dynamic Book Framework
- **Records:** one **BOOK** `PDV_BookOfDays` registered with DBF; an authored line bank.
- **Papyrus:** DBF append API keyed by book title: `AppendDevotionEntry(deityIndex, toneKey, dateStr)` selects copy (§5.2) and appends. Soft-dep on DBF (no-op if absent). Routine favor → one batched dawn digest line.

### 4.5 `medallion` — Description Framework (MISC)
- **Records:** **MISC** `PDV_DevotionMedallion` (+ icon; may reuse a vanilla amulet mesh).
- **Papyrus:** `RefreshMedallion()` builds the string from StorageUtil piety and calls DF `SetDescription`. **DF text does not persist** → call from `OnLoad()` and on dawn. Soft-dep on DF; fallback is the existing Survey/status spell.

### 4.6 `bodymark` — RaceMenu / NiOverride (baseline) — **V2 (deferred; custom art)**
- **Scope:** the bodymark channel is **deferred to V2** (user 2026-06-05) because its overlay textures are
  the plan's custom-art (`PDV_DiegeticUX_CustomAssetReview.md` §7). The Director still *calls* `SetBodyMark`
  on the relevant transitions; at V1 those calls **no-op** (`Has("bodymark-assets")` / texture-missing
  guard), so the interface is in place and V2 only adds the textures.
- **Assets (V2):** overlay textures (`scar`, `warpaint`, `ash`).
- **Papyrus:** `NiOverride.AddOverlay`/`AddNodeOverrideString` + tint; clear on inverse transition. Track in `PDV.Diegetic.Mark.*`; re-assert on `OnLoad()`. Use ≤2 named slots; respect `NiOverride.ini` budget. Soft-guarded even though RaceMenu is a modlist baseline.

### 4.7 `anim` — bundled OAR submod
- **Assets:** a **PDV-owned OAR submod folder** (approach/kneel/offer/rise + race postures) with condition JSON. Only the **OAR engine** is a runtime requirement.
- **Papyrus:** `EmitPrayerAnim(poseKey)` sets the condition variable the submod JSON reads (e.g. a PDV global or `SetGraphVariable`) and plays the idle at the existing rite/shrine site. The EventBus fire stays where it is (offer beat). Skippable/interruptible.

### 4.8 SPID stance (passive — no emitter)
- **Config:** `PDV_DiegeticStance_DISTR.ini` distributes a faction/relationship rank keyed to existing `PDV_GLO_ActiveDeityIndex` / `PDV_GLO_ActiveTier`. No Director call; the world simply reads the globals PDV already maintains. Non-voiced (disposition only) for V1.

---

## 5. Content contract — the explicit copy banks ("make these explicit")

Pilot-complete for **Khajiit / Khenarthi + shared curse**. The *grammar* below is the contract; the
per-race/-deity fill comes from `race-sheets/PDV_RaceContent_Manifest.md` +
`race-sheets/PDV_ContentDestinationMatrix.md` and is authored in §6 expansion.

### 5.1 Medallion description grammar (DF)
```
Line 1 (name):   Medallion of <DeityName>            | Medallion (dimmed) | Medallion (shadowed)
Line 2 (favor):  Favor: <TierLabel>[, <modifier>].   color: green Devoted / gold Faithful / muted slip / red silent
Line 3 (state):  <one diegetic state phrase>
Line 4 (hint):   <heard/last-act OR recovery hint>   (omit when Devoted+current)
```
Worked (Khenarthi), the three sampled states verbatim in `PDV_ImmersiveUX_Samples.md` §B1.
Per-deity data needed: `DeityName`, `TierLabels[4]`, one favored-state phrase, one neglected hint,
one cursed phrase. Store in a per-deity StorageUtil/array the Director reads.

### 5.2 Journal line bank — keyed `(eventClass, direction)`, deity-voiced
Pilot-complete set (Khenarthi), verbatim in `PDV_ImmersiveUX_Samples.md` §B2. Bank shape:
```
PDV_Journal.<deity>.<class>.<direction>  = "<one in-voice line>"
PDV_Journal.<deity>.favor.digest         = "The day's small devotions noted; <race road phrase>."
```
Fallback: a Narrator-voice generic line per class when a deity line is unauthored.

### 5.3 Screen-tone → record params
| tone | IMAD look | EFSH/ARTO | dur |
|---|---|---|---|
| reverent | warm gold bloom | gold rim particles | 1.0s |
| revelation | white bloom | rising sun-mark | 1.2s |
| dread | cold blue vignette | cold shroud | onset→until cure |
| release | clearing green fade | green cleansing rings | 1.2s |
| turning | brief neutral desat | — | 0.6s |
| absence | slow grey desaturate | — | 0.8s |
| apotheosis | strong gold | sustained gold aura | 2.0s |

### 5.4 Sound cue table → §3 mapping
`reverent→chime · revelation→swell · dread→hollow · release→risingChime · turning→click ·
absence→distant · apotheosis→fullSwell`.

### 5.5 Body-mark table
`curse→scar (onset/cure) · emergence(Champion)→warpaint · dunmer-ancestor-deep→ash`.

### 5.6 MessageBox copy (real-choice pushes that stay)
Curse-cure pilot (Khenarthi), verbatim in `PDV_ImmersiveUX_Samples.md` "money shot". Onset / emergence
/ champion reuse the existing §16.3 God-voice MessageBox slots in `PDV_ContentDestinationMatrix.md`.

---

## 6. Phasing (mirrors the Phase-0-inert → pilot → expand cadence used for substrate)

| Phase | Scope | Exit gate |
|---|---|---|
| **D0 — inert scaffold** | `PDV_DiegeticDirector` + `PDV_DiegeticDeps` compile-clean; dep probes; MCM verbosity toggle; `Dispatch()` wired into `SurfaceTransition()` but every channel guarded/no-op. | Strict-verifier clean; in-game smoke shows **no behavior change**; save/load sane. |
| **D1 — pilot (Khajiit/Khenarthi + Dunmer)** | medallion (MISC+DF), journal (BOOK+DBF), screen (reverent/dread/release), sound (chime/hollow/rising — placeholders ok), the cure MessageBox. **No bodymark/anim (V2).** | QASmoke counted proof (like the substrate proofs): transitions fire each channel once per direction; one-shot guards hold across reload; deps-absent degrades cleanly. |
| **D2/V2 — channel completion + custom art** | **bodymark channel + overlay textures (scar/ash/warpaint/soot)**, **prayer-anim OAR submod**, bespoke audio/music swaps, remaining tones, verbosity presets fully wired. | Each channel proven on at least one transition; verbosity mask verified. |
| **D3 — roster fill** | per-race tone overrides + per-deity copy from RaceContent_Manifest; SPID stance `_DISTR.ini`. | Coverage map (like `PDV_TransitionSurfacing_CoverageMap.md`) marks every race×class cell authored or N/A. |

---

## 7. Dependencies & asset production

| Dependency | Posture | If absent |
|---|---|---|
| **OAR** (engine) | soft hard-ish — only engine; PDV ships the submod | anim channel no-ops; rites still fire events |
| RaceMenu / NiOverride | baseline given, soft-guarded | bodymark channel no-ops |
| Description Framework | soft | medallion falls back to Survey/status spell |
| Dynamic Book Framework | soft | journal channel no-ops (or static BOOK) |
| po3 Papyrus Extender | soft (near-ubiquitous) | screen aura uses vanilla SPEL/EFSH route |
| SPID | soft | no stance recognition |
| **New native C++** | **none** | — |

**Asset production sub-track — V1 ships with NO custom art on the critical path** (user 2026-06-05: bodymark
+ polish art = V2). V1: EFSH/IMAD = recolor vanilla (low); medallion/book = reuse vanilla mesh (low); audio
= vanilla placeholders. **V2 (batched custom art):** overlay textures (scar/ash/warpaint/soot), OAR
animation clips, bespoke audio/music, optional bespoke medallion mesh. See
`references/authoring/PDV_DiegeticUX_CustomAssetReview.md` for the full V1/V2 custom-asset split.

---

## 8. What this spec deliberately does NOT do
- No skill tree (rejected — adds player progression cost).
- No new native DLL; the Prisma bridge is untouched and still owns instruments/glyphs/panel/toasts.
- No voiced content (SPID stance is disposition-only; spoken recognition stays V2).
- No change to scoring, piety, curse, substrate, or Daedric mechanics — **only whether/how the player
  is told**, exactly the §16.7 mandate, now with more than text to say it.

---

## Appendix — anchored interfaces (existing, do not redefine)
- §16.7 `SurfaceTransition(eventClass, key, direction)` + `PDV.Surfaced.*` guards — `PDV__ManagerQuest.psc`.
- §16.2 notification levels; §16.6 toast payload + `PDV_PrismaBridge.SendOverlayJson()`.
- §17.0 #6 `PDV_CurseState.psc` transition-notification hook (the `curse` channel host).
- EventBus/EventTypes signal routing; existing token/shrine routes (anim host).
- `PDV_GLO_ActiveDeityIndex`, `PDV_GLO_ActiveTier` (SPID stance reads these).
