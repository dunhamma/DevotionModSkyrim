# Codex D1 Pilot Packet — Diegetic UX (Khajiit/Khenarthi + Dunmer)

**Status:** Build-ready content + asset + wiring packet for **Phase D1** of the diegetic UX layer.
**Reads with:** `references/authoring/PDV_DiegeticUX_ArchitectureSpec.md` (interfaces),
`handoff/PDV_DiegeticUX_CodexHandoff.md` (tracks), `references/authoring/PDV_DiegeticUX_PerRaceImplementationMap.md`
(per-race), `references/authoring/PDV_ImmersiveUX_Samples.md` (visual target).
**Date:** 2026-06-05

## Locked decisions this packet builds on (user, 2026-06-05)
- **Medallion coexists** with the Prisma medallion roster — D1 ships **one MISC** `PDV_DevotionMedallion`
  (deity-aware text); Prisma panel untouched.
- **Hard floor = SKSE + Prisma bridge + OAR engine.** Description Framework, DBF, NiOverride, po3 PE, SPID
  all **soft** — every emitter no-ops cleanly when absent.
- **Pilot set = Khajiit/Khenarthi (lead) + Dunmer (co-pilot).** Rationale: together they exercise the
  **entire channel matrix** — see coverage below.

## Channel coverage of the pilot set (why these two)
| Channel | Khajiit covers | Dunmer covers |
|---|---|---|
| medallion (DF) | ✔ lunar/Khenarthi states | ✔ ancestor-depth states |
| journal (DBF) | ✔ | ✔ |
| screen (IMAD+EFSH) | ✔ reverent/revelation/dread/release | ✔ dread/release/absence |
| sound (SNDR) | ✔ | ✔ |
| music (MUSC) | ✔ **moon-night tell** | (curse bed) |
| bodymark (NiOverride) | ✔ scar | ✔ **scar + ancestor ash** |
| anim (OAR submod) | (moon-rite, opt) | ✔ **ash-shrine kneel/offer** |
| substrate act/deepen/thin | ✔ lunar | ✔ ancestor |
| classes: tier/emergence/curse/neglect | ✔ + **revelation emergence** | ✔ + **substrate-narrowing curse** |

SPID stance is **not** in D1 (it's D3, config-only). Warpaint marks are D2.

---

## 1. Per-deity content bank (the data the Director reads)

Format = the Architecture §5.1/§5.2 grammar. Codex transcribes into the per-deity bank (StorageUtil seed
or a const block keyed by `deityIndex`). `{n}` = runtime day count. Colors per Architecture §4.5
(green Devoted / gold Faithful / muted slip / red silent).

### 1a. Khenarthi (Khajiit lead) — `deity: khenarthi`
```yaml
name:        "Medallion of Khenarthi"
name_dim:    "Medallion (dimmed)"          # neglected
name_curse:  "Medallion (shadowed)"        # cursed
tierLabels:  [Observant, Faithful, Devoted, Champion]
medallion:
  favored:      "The wind carries your name."
  neglect_hint: "Unheard for {n} days. Pray, or offer on the road."
  cursed:       "A curse stands between you and the sky."
journal:
  substrate.act:      "The moons marked your road-rest."
  tier.Faithful:      "You reached Faithful. The pantheon turns to look."
  emergence.onset:    "Khenarthi claims your road. The wind is yours to walk."
  curse.onset:        "Cold takes you. The moons close their eyes."
  curse.cure:         "The scar closes. The sky is yours again; she hears you once more."
  neglect.drop:       "{n} days of silence. Khenarthi's wind has stilled around you."
  favor.digest:       "The day's small devotions noted; the road was kept."
messagebox:
  emergence.onset:                          # revelation — Loud (MessageBox), god-voice
    title: "— Khenarthi —"
    body:  "You have walked far, and the wind has watched. Walk now as mine: the moons will light your road, and the sky will know your name."
  curse.cure:                               # release — Loud (MessageBox), god-voice
    title: "— Khenarthi —"
    body:  "The shadow lifts. The moons open their eyes upon you once more, and the wind remembers your name. Walk on, and keep faith."
```

### 1b. Dunmer ancestors + Azura (co-pilot) — `deity: dunmer_ancestor`
The Dunmer pilot exercises the **ancestor substrate** (body-mark + anim) and the **vampire curse that opens
the Good Daedra**. Medallion/journal read the ancestor track; Azura voices the curse-cure beat.
```yaml
name:        "Ancestral Medallion"
name_dim:    "Ancestral Medallion (cold)"
name_curse:  "Ancestral Medallion (turned away)"
tierLabels:  [Distant, Remembered, Honored, "Kin of the Ash"]
medallion:
  favored:      "The ash is warm; the dead walk near."
  neglect_hint: "The shrine has gone cold for {n} days. Burn ash, speak their names."
  cursed:       "The dead draw back from what you have become."
journal:
  substrate.act:      "The ash remembers you came to the shrine today."
  tier.Remembered:    "You are Remembered. The ancestors keep your name among theirs."
  curse.onset:        "Cold blood. The ancestors recoil — yet the Good Daedra turn their eyes toward you."
  curse.cure:         "The taint lifts. The ash accepts you again, and the dead draw near."
  neglect.drop:       "The shrine has gone cold; the ancestors' voices thin."
  favor.digest:       "The day's small rites kept; the ash was not forgotten."
messagebox:
  curse.cure:                               # release — Loud (MessageBox); Azura/ancestor voice
    title: "— Azura —"
    body:  "The cold that walked your blood is gone. The ash is warm again, and the dead know your face. Tend the shrine, my child, and dusk will not abandon you."
```
> Dunmer `tier` label for the Faithful-equivalent is **Remembered** (ancestor track); the Director keys
> journal by `tier.<label>` so the per-deity labels stay self-consistent.

---

## 2. Surface-profile rows exercised in D1 (subset of Architecture §3)

| class · direction | tone | channels fired (D1) | notify |
|---|---|---|---|
| `tier` · Faithful/Remembered | reverent | screen, sound(chime), journal, medallion | Medium |
| `emergence` · onset (Khenarthi) | revelation | screen(sun), sound(swell), journal, medallion, **MessageBox** | Loud |
| `curse` · onset | dread | screen(cold, sustained), sound(hollow), music(curse bed ON), journal, medallion(dim), **bodymark scar ON**, **MessageBox** | Loud |
| `curse` · cure | release | screen(clearing), sound(rising), music(curse bed OFF), journal, medallion(bright), **bodymark scar OFF**, **MessageBox** | Loud |
| `neglect` · drop | absence | screen(desaturate), sound(distant), journal, medallion(grey) | Medium |
| substrate `act` (Khajiit lunar / Dunmer ancestor) | — | medallion refresh, journal digest, (Dunmer) **anim**, (Verbose) tiny cue | silent |
| substrate `deepen` | reverent | sound(chime), journal | silent |

---

## 3. D1 records & assets to create

### Records (Track B — Codex creates + wires to Director quest properties)
| Type | EditorIDs | Notes |
|---|---|---|
| MISC | `PDV_DevotionMedallion` | one shared item; granted at origin alongside the BOOK; icon may reuse a vanilla amulet |
| BOOK | `PDV_BookOfDays` | register with DBF; granted with medallion |
| IMAD | `PDV_IMAD_Reverent`, `_Revelation`, `_Dread`, `_Release`, `_Absence` | recolor vanilla blooms/desaturates |
| EFSH (+SPEL ability) | `PDV_Abil_Shader_Reverent`, `_Revelation`, `_Dread`, `_Release` | self-target ability carries the shader |
| SNDR | `PDV_SND_Chime`, `_Swell`, `_Hollow`, `_RisingChime`, `_Distant` | short stings |
| MUSC | `PDV_MUS_CurseBed` (D1), `PDV_MUS_MoonNight` (D1-optional) | reversible add/remove |

### Art/audio specs (Track E — Claude owns specs; production per cost note)
- **IMAD/EFSH:** recolor vanilla EFSH (heal=green/release, frost=cold/dread, a warm bloom=reverent, a white
  flash=revelation). Palette per `scratch/prisma-art/instruments.py`. **Low cost.**
- **Medallion icon:** reuse a vanilla amulet. **Low.**
- **Body overlays (NiOverride):** `pdv_scar` (shared, red), `pdv_ash` (Dunmer, muted ash dots over the
  upper body). Mark shapes per `scratch/prisma-art/ux_samples.py` (`t_body`). **Medium.**
- **SNDR:** 5 short stings sourced/licensed. `PDV_MUS_MoonNight` = one ambient loop. **Medium** (D1 can ship
  with placeholder vanilla sounds and swap later).
- **OAR submod** `.../OpenAnimationReplacer/PDV_Devotion/`: `kneel`, `offer` (shared) + `ash_kneel`
  (Dunmer). Retarget vanilla pray idles. **High — D1 may ship anim channel off (no-op) and land in D2** if
  clips aren't ready; everything else degrades cleanly.

---

## 4. Emit-site wiring (Track A/C — exact call sites)

### Khajiit
- **Substrate act:** in `HandleKhajiitMoonObservance` (~1331) and `RecordRoadHomeCadenceScaled` (~1360),
  after the existing substrate record + the existing `SendPrismaSubstrateToast(...)`, add:
  `PDV_DiegeticDirector.RefreshMedallion()`; append `journal substrate.act` to the **dawn digest** (not a
  per-act line); `EmitSound` only at Verbose.
- **Substrate deepen (tier-up):** on `GetSubstrateTier()` increase, `EmitSound("reverent")` + journal line.
- **Emergence (Khenarthi claims):** at the existing Khajiit focused-emphasis emergence site, call
  `SurfaceTransition("emergence","khenarthi","onset", deityIndex, "revelation")` → Director fires the full
  revelation set incl. the MessageBox above.
- **tier / neglect:** standard §16.7 sites; pass `toneOverride=""` (defaults reverent/absence).
- **Moon tell (music):** when outdoor + full-moon phase (the verified 8-phase clock), `EmitMusicState
  ("moon_night", true)`; clear when phase leaves full / indoors. (D1-optional.)

### Dunmer
- **Substrate act:** in `RecordPortableShrinePrayerScaled` (~1308) and `RecordPlayerHomeBonusScaled`
  (~1316), after the existing record, add `RefreshMedallion()` + `EmitPrayerAnim("ash_kneel")` (no-op if no
  OAR) + journal `substrate.act` to the digest.
- **Substrate deepen:** on ancestor tier increase, `EmitSound("reverent")` + journal; (instrument lights
  the next mask — Prisma side, already specced).
- **Curse (vampire) onset/cure:** hook the **existing** `PDV_CurseState.psc` transition-notification hook
  (do not build a parallel path): `SurfaceTransition("curse","Vampire","onset"|"cure", deityIndex, tone)`
  with tone `dread`/`release`. Director then: screen + sound + music bed + journal + medallion +
  `SetBodyMark("scar", true|false)` + the Azura MessageBox. Dunmer curse copy carries the
  **Good-Daedra-opens** framing (bank above).
- **Ancestor ash mark:** when ancestor depth ≥ 3, `SetBodyMark("ash", true)`; clear below.
- **tier / neglect:** standard §16.7 sites.

### Shared (both)
- `PDV__ManagerQuest.SurfaceTransition()` gets the **one** new line (Architecture §2.4):
  `PDV_DiegeticDirector.Dispatch(eventClass, key, direction, deityIndex, toneOverride)`.
- `OnPlayerLoadGame` → `PDV_DiegeticDirector.OnLoad()` (re-probe deps, `RefreshMedallion`, re-assert scar/
  ash marks + any music bed).
- Dawn consolidation → `RefreshMedallion()` + flush the journal digest line.

---

## 5. D1 proof checklist (mirror the substrate QASmoke discipline)
- [ ] D0 inert pre-state holds (no behavior change) before D1 records attach.
- [ ] Each profile row in §2 fires its channel set **once per direction**; one-shot guards hold across a
      save/reload at each transition.
- [ ] **Deps-absent run:** force `Has("DF")`, `Has("DBF")`, `Has("NiOverride")`, `Has("OAR")`, `Has("PO3")`
      false in turn → no errors, no missing-function CTD; existing §16.7 surfaces still fire.
- [ ] Curse `dread` screen + scar are **sustained** through the curse and **clear exactly on cure**; curse
      music bed reverses; medallion + journal reflect both directions.
- [ ] Routine favor never routes through `Dispatch()`; it only refreshes the medallion + accrues the dawn
      digest (no per-act spam).
- [ ] Verbosity: Silent shows MessageBox-only on transitions; Verbose restores Prisma toasts.
- [ ] Dunmer ancestor `act` fires on a **non-combat** shrine trigger (closes the audit's Layer-1 silence).

## 6. Out of D1 (so scope is unambiguous)
SPID stance (D3) · warpaint/Champion marks (D2) · per-race tone fill beyond the two pilots (D3) · music
beyond curse bed + moon-night (D2) · the remaining 8 races' content banks (D3) · OAR clips may slip to D2
(channel no-ops until then).
