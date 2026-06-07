# Codex Handoff — Diegetic UX layer: scripts, records, wiring

**For:** Codex (owns the live `PDV__ManagerQuest.psc`, all new Papyrus, all CK record creation/wiring,
and any native — though **this layer needs no native**).
**From:** the diegetic-UX design pass (Claude). **Read first, in order:**
1. `references/authoring/PDV_DiegeticUX_ArchitectureSpec.md` — the architecture, fixed interfaces, the
   surface-profile table, channel contracts, phasing. **This is what you implement from.**
2. `references/authoring/PDV_ImmersiveUX_DiegeticSurfaces_Buildout.md` — rationale + tool choices per channel.
3. `references/authoring/PDV_ImmersiveUX_Samples.md` — the literal copy banks + the visual target
   (`scratch/prisma-art/ux_samples_*.png`).

**Ownership (repo convention, unchanged):** Claude owns architecture + copy + art/asset *specs* and will
iterate on feedback. **Codex owns all code, all CK record creation, property wiring, the SPID ini, and the
OAR submod packaging.** Interfaces in the architecture spec §2 are frozen: **add fields freely, never
rename/remove.**

**The single most important fact:** this is a **fan-out over the existing §16.7 `SurfaceTransition()`** —
not a new system. The only edit to existing flow is **one line** (Architecture §2.4). Everything else is
additive scripts + records.

---

## Track ownership at a glance

| Track | Owner | Toolchain | Native? |
|---|---|---|---|
| A — new Papyrus (`PDV_DiegeticDirector`, `PDV_DiegeticDeps`) + the 1-line `SurfaceTransition()` edit | Codex | Papyrus | no |
| B — CK records (IMAD/EFSH/ARTO/SPEL/SNDR/MUSC/MISC/BOOK) + property wiring | Codex | Creation Kit / pdv_author | no |
| C — soft-dep glue (DF, DBF, NiOverride, OAR, po3 PE Papyrus calls) | Codex | Papyrus | no |
| D — SPID `_DISTR.ini` + OAR submod folder packaging | Codex | config / file layout | no |
| E — art/audio assets (EFSH textures, overlay textures, medallion icon, audio, anim clips) | Claude/art *spec*; production TBD | — | no |

**No `src/` / xmake / DLL work in this handoff.** The Prisma bridge is untouched.

---

## Track A — Papyrus

### A1. `PDV_DiegeticDeps.psc` (do first — everything gates on it)
Cached availability probes, re-probed on load. Persist to `PDV.Diegetic.Dep.<name>`.
```papyrus
Bool Function Has(String depName)        ; "DF" | "DBF" | "NiOverride" | "OAR" | "PO3"
Function Reprobe()                        ; Game.IsPluginInstalled(...) / api-handshake per dep; cache ints
```
Probe approach per dep: `Game.IsPluginInstalled("po3_papyrusextender.dll"...)` style where a plugin name
exists; for script-only frameworks (DF/DBF/NiOverride) a safe `GetFormFromFile`/known-function guard or a
try-call wrapper. Cache once; cheap reads thereafter.

### A2. `PDV_DiegeticDirector.psc`
Implements the architecture §2.3 signatures. Skeleton:
```papyrus
Scriptname PDV_DiegeticDirector extends Quest

; --- entry point, called by SurfaceTransition() after its guard is set ---
Function Dispatch(String eventClass, String key, String direction, Int deityIndex, String toneOverride = "")
    Int verб = StorageUtil.GetIntValue(none, "PDV.Diegetic.Verbosity")    ; 0/1/2
    String tone = GetProfileTone(eventClass, direction, toneOverride)
    ; channel set from the profile table (Architecture §3); each call self-gates on dep + verbosity:
    EmitScreen(tone)
    EmitSound(tone)
    EmitMusicForClass(eventClass, direction)
    EmitJournal(deityIndex, eventClass + "." + direction)
    RefreshMedallion()
    UpdateBodyMarkForClass(eventClass, direction, deityIndex)
    ; notify level + Prisma toast stay in SurfaceTransition() per §16.2/§16.6 + the verbosity mask
EndFunction

Function OnLoad()                  ; called from manager's existing OnPlayerLoadGame
    PDV_DiegeticDeps.Reprobe()
    RefreshMedallion()             ; DF text is non-persistent
    ReassertBodyMarks()            ; NiOverride is runtime-applied
    ReassertMusicStates()          ; re-add any active beds
EndFunction
```
- `GetProfileTone` / the channel-set lookup encode Architecture §3 (static dispatch is fine; no
  JContainers — StorageUtil/`if` ladder per the 1.0 dependency rule).
- Every `Emit*` checks `PDV_DiegeticDeps.Has(...)` and the verbosity mask first; **safe to call
  unconditionally** so `Dispatch()` stays flat.

### A3. The one integration edit (Architecture §2.4)
In `PDV__ManagerQuest.SurfaceTransition()`, after the existing guard-set + Notification/MessageBox/toast
routing, add:
```papyrus
PDV_DiegeticDirector.Dispatch(eventClass, key, direction, deityIndex, toneOverride)
```
Plus wire `PDV_DiegeticDirector.OnLoad()` into the manager's existing load hook, and call
`RefreshMedallion()` from the existing dawn-consolidation path. **No other existing-flow changes.**

### A4. Routine favor (NOT through SurfaceTransition)
Routine per-act favor must stay Quiet (§16.2). On a scored act, call `RefreshMedallion()` and accrue the
dawn digest line only; do **not** route through `Dispatch()` (avoids touching one-shot guards). Optional
tiny chime only when Verbosity == 2.

---

## Track B — CK records (create + wire properties to the Director)

Author with the existing `pdv_author`/CK pipeline; names per Architecture §4. Minimum set for **D1 pilot**:
- **IMAD:** `PDV_IMAD_Reverent`, `PDV_IMAD_Dread`, `PDV_IMAD_Release`.
- **EFSH (+ ARTO/RFCT) + SPEL ability:** `PDV_Abil_Shader_Reverent/Dread/Release` carrying the shader.
- **SNDR:** `PDV_SND_Chime`, `PDV_SND_Hollow`, `PDV_SND_RisingChime`.
- **MISC:** `PDV_DevotionMedallion` (+ icon; vanilla amulet mesh ok) — granted at startup/origin.
- **BOOK:** `PDV_BookOfDays` (+ DBF registration) — granted alongside the medallion.
Fill the Director quest properties for each. **D2 adds:** `PDV_MUS_PatronPrayer`, `PDV_MUS_CurseBed`,
remaining IMAD/EFSH tones, `PDV_SND_Swell/Click/Distant`.

Curse channel: hook the **existing** `PDV_CurseState.psc` transition-notification hook (§17.0 #6) so curse
onset/cure call `Dispatch("curse", curseType, "onset"|"cure", ...)` — do not build a parallel curse path.

---

## Track C — soft-dep Papyrus glue (the channel emitters' bodies)
Each emitter wraps its framework, gated by `PDV_DiegeticDeps.Has(...)`:
- `EmitScreen` → `ImageSpaceModifier.ApplyCrossFade()` + add/remove `PDV_Abil_Shader_<tone>` (po3 PE
  direct shader if `Has("PO3")`, else the SPEL route). Curse `dread` is sustained until cure.
- `EmitSound` → `Sound.Play(PlayerRef)`.
- `EmitMusicState` → MusicType add/remove; track `PDV.Diegetic.Music.<stateKey>`.
- `EmitJournal` → DBF append (title-keyed); select copy from the §5.2 bank; no-op if `!Has("DBF")`.
- `RefreshMedallion` → DF `SetDescription` from piety; no-op→Survey fallback if `!Has("DF")`.
- `SetBodyMark` → NiOverride add/clear overlay + tint; track `PDV.Diegetic.Mark.<markKey>`; ≤2 slots.
- `EmitPrayerAnim` → set the OAR condition var + play idle at the rite site; no-op if `!Has("OAR")`.

Interface rule: DF descriptions and NiOverride overlays are **non-persistent** → both must be re-asserted
in `OnLoad()` (already in A2).

---

## Track D — config + packaging
- **SPID** `PDV_DiegeticStance_DISTR.ini`: distribute a relationship/faction rank to patron-temple
  priests + rival zealots, conditioned on `PDV_GLO_ActiveDeityIndex` / `PDV_GLO_ActiveTier`. Disposition
  only; **no dialogue, no voice** (V1). Passive — no Director call.
- **OAR submod** `meshes/actors/character/animations/OpenAnimationReplacer/PDV_Devotion/...`: the
  approach/kneel/offer/rise clips + per-race posture conditions. PDV ships these; only the OAR engine is a
  runtime requirement. `EmitPrayerAnim` toggles the condition var the submod JSON reads.

---

## Track E — assets (Claude/art owns specs; production to schedule)
EFSH/IMAD recolor vanilla (low) · medallion icon reuse (low) · audio cues+beds (med) · overlay textures
scar/warpaint/ash (med) · OAR clips (high — D2, degrades gracefully). Claude will deliver per-asset specs
(palette per `instruments.py`; mark shapes per `scratch/prisma-art/ux_samples.py`).

---

## Proof / verification expectations (match the substrate proof discipline)
- **D0:** strict-verifier clean; in-game smoke = **no behavior change**; save/load sane. Mirror the
  scaffold "remain inert" smoke (§17.0).
- **D1:** QASmoke counted proof (like the Phase 10 substrate proof): each pilot transition fires its
  channel set **once per direction**; one-shot guards hold across reload; **deps-absent run degrades
  cleanly** (force each `Has()` false and confirm no errors, existing surfaces still fire).
- **D2/D3:** per-channel proof on ≥1 transition; verbosity mask verified (Silent shows MessageBox-only;
  Verbose restores toasts); coverage map per race×class.

Anti-spam invariants to assert: routine favor never routes through `Dispatch()`; curse `dread` screen +
scar clear exactly on cure; music states are reversible and never stomp combat/quest music.

---

## Readiness tracker

Legend: ✅ done · 📄 specced here, not built · ⛔ blocked/needs decision.

| Item | Owner | State |
|---|---|---|
| Architecture + fixed interfaces + profile table | Claude | ✅ (`PDV_DiegeticUX_ArchitectureSpec.md`) |
| Copy banks (pilot-complete Khenarthi + curse) | Claude | ✅ (`PDV_ImmersiveUX_Samples.md`) |
| Visual target mockups | Claude | ✅ (`scratch/prisma-art/ux_samples_*.png`) |
| `PDV_DiegeticDeps.psc` | Codex | 📄 (Track A1) |
| `PDV_DiegeticDirector.psc` (Dispatch/OnLoad/emitters) | Codex | 📄 (Track A2/C) |
| 1-line `SurfaceTransition()` edit + load/dawn hooks | Codex | 📄 (Track A3) |
| D1 CK records (IMAD/EFSH/SPEL/SNDR/MISC/BOOK) + wiring | Codex | 📄 (Track B) |
| Curse hook into `PDV_CurseState` | Codex | 📄 (Track B) |
| MCM verbosity preset (Silent/Transitions/Verbose) | Codex | 📄 (Architecture §3) |
| SPID `_DISTR.ini` | Codex | 📄 (Track D) |
| OAR submod packaging | Codex | 📄 (Track D) |
| Per-asset production specs | Claude | ⛔ next (Track E) |
| Per-race/-deity copy fill (D3) | Claude | ⛔ from RaceContent_Manifest |

**Resolved decisions (user, 2026-06-05) — D1 may code against these:**
1. **Medallion coexists** with the Prisma medallion roster — new **MISC** for the quick hover read, Prisma
   panel stays the deep surface. (Architecture §4.5 already assumes coexist.)
2. **Hard-dependency floor stays SKSE + Prisma bridge + OAR engine only.** Description Framework, Dynamic
   Book Framework, RaceMenu/NiOverride, po3 PE, and SPID are **all soft** — every emitter no-ops cleanly
   when its framework is absent (Architecture §7).
3. **D1 pilot = a race set: Khajiit/Khenarthi (lead) + Dunmer (co-pilot).** Together they exercise the full
   channel matrix — Khajiit covers lunar substrate + music (moon tell) + revelation emergence + curse +
   screen/sound/medallion/journal; Dunmer covers the **ancestor-ash body-mark + ash-shrine prayer anim +
   substrate-narrowing curse**. Content + asset specs for both: `PDV_DiegeticUX_D1PilotPacket.md`.
