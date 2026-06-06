# PDV Diegetic UX — Per-Race Implementation Map

**Status:** Implementation map / design-locked. The per-race "how and where" layer for the diegetic UX
architecture.
**Reads with:** `PDV_DiegeticUX_ArchitectureSpec.md` (the channel fan-out + fixed interfaces),
`references/authoring/PDV_TransitionSurfacing_CoverageMap.md` (the class→slot + guard-key binding — **this
doc does not duplicate it**), `handoff/PDV_DiegeticUX_CodexHandoff.md` (the wiring tracker).
**Date:** 2026-06-05

## What this doc adds (and what it relies on)

`PDV_TransitionSurfacing_CoverageMap.md` already answers **which transition classes each race hits and
which copy slot + guard key each uses** — and found the transition copy is essentially already authored.
This doc adds the **diegetic-channel layer on top of that**: per race, *which tones and channels carry the
feel, which substrate/instrument the medallion + journal mirror, what the curse silences (driving the
screen/body-mark/medallion), the body-mark + animation posture + SPID targets, and the concrete hook
sites.* The Director (`Dispatch`) is race-agnostic; **per-race expression is a data overlay** —
`toneOverride`, the per-deity copy bank, and the substrate hook calls.

**How per-race wiring actually happens (three mechanisms, no per-race Director code):**
1. **`toneOverride`** passed into `SurfaceTransition()`/`Dispatch()` at the race's emit sites (shifts the
   default profile tone to the race's signature tone).
2. **Per-deity content bank** the Director reads for medallion/journal copy (deity name, tier labels,
   state phrases) — keyed by `deityIndex`, authored from `race-sheets/PDV_RaceContent_Manifest.md`.
3. **Substrate hook calls** at the race's existing substrate emit sites (the always-on layer), which call
   the light diegetic emitters (`RefreshMedallion`, an `act/deepen/thin` cue, the rite anim) *without*
   going through the one-shot `Dispatch()` path.

---

## Master matrix — per-race diegetic signature

| Race | Instrument (Prisma) ↔ medallion mirror | Signature tone(s) | Signature channel(s) | Curse silences… | Body-mark | Reorientation axis |
|---|---|---|---|---|---|---|
| **Nord** | piety bar | reverent, apotheosis | screen + music (pantheon swell) | Kyne's notice (cure = purification rite) | scar; storm-warpaint at Champion | — (Companions/Hircine = V2 fork) |
| **Imperial** | piety bar | turning, reverent | notify-legibility + medallion | Akatosh/Talos line | scar; legion-warpaint | **Concordat standing** (turning) |
| **Breton** | piety bar | turning, release | **medallion legibility** (the 3 opaque numbers) | varies by tradition | scar; druid-mark at Champion | **Druidic vs Stendarr** (turning) |
| **Altmer** | piety bar | dread, apotheosis | screen (Lorkhan cold) + medallion | **terminal** (no cure — Apotheosis lost) | scar (permanent); apotheosis-glow | — |
| **Bosmer** | branch | turning, absence | **anim** (Green Pact rite) + journal | Y'ffre's word | scar; bark-mark at Champion | **path switch** (turning) |
| **Dunmer** | ancestor masks | absence, release | **body-mark (ash)** + ash-shrine anim | ancestor narrows / Good Daedra opens | **ancestor ash** + scar | — (Reclamation lean is posture) |
| **Argonian** | hist tree | absence, dread | **medallion (hist)** + screen (hist void) | **the Hist itself** (cure = Hist-restoration) | scar over hist-mark | — (posture) |
| **Khajiit** | lunar dial | revelation, reverent | **music (moon tell)** + lunar medallion | the moons' light | scar; moon-warpaint | — (=emergence) |
| **Orc** | forge | dread, reverent | **anim (forge rite)** + music (banked/cold) | Malacath's regard | scar; forge-soot mark | **life-mode** Stronghold/City/Exile (turning) |
| **Redguard** | sect blades | turning, release | **music (sect motif)** + medallion | Tu'whacca's road | scar; sect-warpaint (Crown/Ash'abah) | **sect switch** (turning) |

> Tone vocabulary and channel set are the closed lists in Architecture §2.1. "Signature" = where to spend
> art/audio budget per race; every race still gets the full default profile for each class.

---

## Per-race detail

Each block: **deity/track · diegetic emphasis · curse expression · reorientation · body-mark · anim ·
SPID targets · hook sites.** Class→slot + guard keys are in the CoverageMap; cited here only when a
diegetic hook differs.

### Nord — Kyne (Aedric-ambient pantheon)
- **Emphasis:** `tier`/Champion as a **reverent→apotheosis** beat ("the pantheon notices") — screen gold
  bloom + a pantheon music swell. The audit's Tier-2 "the pantheon notices" gap (`PDV_RaceDesign_Nord.md`)
  is exactly the `tier·Faithful` diegetic upgrade.
- **Curse:** vampirism — **cure = the purification rite** the audit wants (visit shrine / outdoor nights);
  diegetically the cure fires `release` (clearing fade + cleansing shimmer + rising chime) so it feels
  earned, not automatic. Scar fades on the completed rite, not on the raw cure flag.
- **Body-mark:** generic scar; storm/Kyne warpaint at Champion. **Anim:** standing prayer (default).
- **SPID:** Heimskr/Kyne priests warm at high Kyne tier. **Hooks:** standard §16.7 sites; no substrate.

### Imperial — Stendarr / Akatosh / Talos
- **Emphasis:** **legibility** over spectacle. The Concordat lane's feel-bad surprises are communication
  gaps — route them through the **medallion** (current standing, what compliance closed) + a **turning**
  screen fade at standing crossings. *No offer-time "blocked" popup* (Imperial rule,
  `PDV_RaceDesign_Imperial.md:226`) — the cost surfaces via `reorientation` at the **standing change**.
- **Reorientation:** Concordat standing (`Public Compliant` / `Concordat Enforcer`) → `turning`; see the
  worked example in §16.7 and `PDV_DecisionMemo_ImperialComplianceLane.md`.
- **Curse:** standard; Akatosh/Talos-voiced MessageBox + scar. **Anim:** standing prayer.
- **SPID:** Imperial cult priests warm; Thalmor-aligned cool at Talos tiers.

### Breton — Stendarr (Integrity), Witchcraft exposure, Green Way
- **Emphasis:** the audit's headline Breton fix is **making three opaque numbers legible** — this is a
  **medallion** job. Medallion surfaces Integrity (with the penance framing for the 75 cap), a **warning
  band** as Witchcraft exposure nears the ~70/76 point-of-no-return, and Green Way standing-stone progress.
  Add a **turning/release** screen at the Druidic Trial.
- **Reorientation:** Druidic vs Stendarr tradition (turning). **Curse:** per-tradition (vampire recovery
  differs) — drives different cure copy + the same `release` channel set.
- **Body-mark:** scar; druid-mark at Champion. **Anim:** standing prayer.

### Altmer — Auri-El / Trinimac (Apotheosis), Lorkhan adjacency penalty
- **Emphasis:** **dread** is the signature. First time the Lorkhan-adjacency penalty bites, fire a cold
  **screen** (dread) + the naming MessageBox the sheet's "Obviousness rule" wants
  (`PDV_RaceDesign_Altmer.md:199-200`) so the signature mechanic is *felt*. Werewolf-onset one-time line:
  beast-form **annihilates Apotheosis**.
- **Curse:** **terminal — no cure** (CoverageMap: Altmer curse-cure intentionally absent,
  `PDV_RaceDesign_Altmer.md:367`). So the scar is **permanent**; no `release` beat. This is the one race
  where the diegetic layer must *not* offer a cleansing shimmer.
- **Body-mark:** permanent scar; apotheosis-glow aura at Champion. **SPID:** Thalmor warm / heretics cool.

### Bosmer — Y'ffre / Green Pact, four paths, Baan Dar
- **Emphasis:** **performed devotion** — the Green Pact rite is an **anim** moment; path-flavor at setup so
  the four paths' costs are legible before a blind pick. Path-switch is the headline reorientation.
- **Reorientation:** **path switch** (`turning`) — map each path's destination signal to a concrete
  vanilla checkpoint (`PDV_RaceDesign_Bosmer.md:34-36,233`; Green Pact tagging + Y'ffre scene are in
  `PDV_Bosmer_OldContract_ContentSpec.md`). Hook at the **existing branch substrate** emit sites.
- **Curse:** Y'ffre's-word framing + scar. **Body-mark:** scar; bark-mark at Champion.
- **Instrument:** `branch` — medallion mirrors path + evidence-days + pact-bound.

### Dunmer — Reclamations (Azura/Boethiah/Mephala) + ancestor substrate, Good Daedra
- **Emphasis:** the audit's Dunmer fix is **making Layer-1 ancestor silence perceptible** — so the
  **body-mark (ancestor ash)** + the **ash-shrine prayer anim** + a journal line ("the ash remembers you
  came") are the signature, ensuring ancestor flavor fires on **non-combat** triggers
  (`PDV_RaceDesign_Dunmer.md:213` vs `:100-102`).
- **Curse:** vampire **opens Good Daedra / werewolf narrows** — say *why* (curse copy explains the
  theological shift); scar over the ash-mark.
- **Anim:** ash-shrine kneel at the portable/private shrine routes.
- **Hook sites (exact):** `RecordPortableShrinePrayerScaled` (~1308) and `RecordPlayerHomeBonusScaled`
  (~1316) → `ancestor`/`act` (medallion refresh + ash shimmer + journal); substrate tier-up → `deepen`
  (light the next mask, brief chime). Token = `PDV_Book_DunmerAshShrine`
  (`PDV_PortableDevotionalToken_BuildSpec.md`).

### Argonian — Hist substrate (water proximity) + Sithis
- **Emphasis:** **medallion (hist)** is primary — the Hist layer is otherwise passive water-proximity. The
  **Hist sap** token (`PDV_PortableDevotionalToken_BuildSpec.md`) is the active rite (anim). Add the
  explicit **Hist-thinning** beat the sheet calls for (`PDV_RaceDesign_Argonian.md:193`) as a `hist/thin`
  hollow tone + medallion greys. **Patron-emergence** for the silent Sithis rise
  (`:139`) → `revelation` MessageBox.
- **Curse:** vampire **silences the Hist** — the curse screen is a **hist-void** look; **cure =
  Hist-restoration** (`release`, multi-beat). Scar over the hist-mark.
- **Hook sites (exact):** `RecordHistMaintenanceScaled` (1398), `RecordPeopleSupportScaled` (1412),
  `RecordBedOfChoiceReturnScaled` (1423), `RecordVoidSignalScaled` (1434) → `hist`/`act`;
  `ProcessHistDistanceDawn` (1449) → `hist`/`thin`.

### Khajiit — lunar substrate (moon phase) + Khenarthi / Azurah silent patron
- **Emphasis:** **music (the moon tell)** + the lunar medallion are the signature — make the moon cycle
  *visible/audible* (the audit's invisibility gap, `PDV_RaceDesign_Khajiit.md:46-48`) via a full-moon
  music motif + a moon-bloom screen on outdoor dawn/dusk/night, on the verified 8-phase clock. **Patron
  emergence** is a real `revelation` beat (closes the silent-patron invisibility, `:56,206`).
- **Curse:** the moons withhold light; scar; moon-warpaint at Champion.
- **Hook sites (exact):** `HandleKhajiitMoonObservance` (~1331), `RecordRoadHomeCadenceScaled` (~1360) →
  `lunar`/`act`; substrate tier-up → `deepen`. This is the **D1 pilot race**.

### Orc — Malacath (forge-quality, stronghold acceptance, oath-breaking) + life-mode
- **Emphasis:** **performed devotion (forge rite anim)** + **music that banks/cools with life-mode**
  (Stronghold bright → City banked → Exile cold). Forge-quality and stronghold-acceptance **recognition
  beats**; oath-acceptance framing line on hard quests (`PDV_RaceDesign_Orc.md:84,206,222`).
- **Reorientation:** **life-mode** Stronghold/City/Exile (`turning`) — also the `forge` instrument's state.
- **Curse:** Malacath's regard withdrawn; scar; forge-soot mark. **SPID:** stronghold Orcs warm at acceptance.
- **Hook sites:** the existing Orc life-mode / `stronghold` substrate emit sites (substrate enum
  `stronghold`); forge-dedication rite = anim host.

### Redguard — Tu'whacca / Satakal / HoonDing / (Alkosh) + sect
- **Emphasis:** **music (sect motif)** + medallion. **Sect switch** Crown vs Ash'abah is the headline
  reorientation; **death-duty** recognition flavor (Crown vs Ash'abah colored). Far Shores token
  (`PDV_Book_RedguardFarShores`) is the active Tu'whacca rite (anim + star-path).
- **Reorientation:** **sect switch** (`turning`) — the `sects` instrument's active-blade flip.
- **Open decision (carried):** Alkosh under-developed as a focused path
  (`PDV_RaceDesign_Redguard.md:80-87`) — if added, it gets its own medallion/journal deity entry.
- **Curse:** Tu'whacca's road obscured; scar; sect-colored warpaint.

### Shared / Daedric (all races)
- Daedric **stigma band crossings** map to `reorientation`/`neglect` tones (dread-leaning); the
  `PDV_Notif_Daedric_<Prince>_Stigma_<band>` slots already exist (ContentDestinationMatrix). Prince
  **commitment/exit** are God-voice MessageBoxes (stay as push). Meridia's "cleansing-light overlay"
  (ContentDestinationMatrix) is a natural `release`/`revelation` **screen** reuse. No per-Prince diegetic
  body-marks in V1 (avoid art sprawl); curse/scar logic is shared via `PDV_CurseState`.

---

## D3 per-race wiring checklist (for Codex, after D1/D2 channels exist)

For each race, wiring = **three data tasks, no new Director code**:

| Task | Source | Per-race output |
|---|---|---|
| 1. Per-deity content bank (medallion + journal copy) | `PDV_RaceContent_Manifest.md` slots (via CoverageMap) | deity name, tier labels, favored/neglect/curse phrases, journal lines |
| 2. `toneOverride` at emit sites | Master matrix "signature tone" column above | pass the race tone into `SurfaceTransition()` where the default profile isn't the race's feel |
| 3. Substrate hook calls | the exact hook sites per race above | `RefreshMedallion` + `act/deepen/thin` cue + (where applicable) rite anim |

**Coverage gate (mirror `PDV_TransitionSurfacing_CoverageMap.md`):** mark every race × channel cell as
*authored / N/A / deferred*. Known N/A already: **Altmer curse-cure** (terminal — no `release`); races
without a focused-patron path have no `emergence` diegetic beat (use →Champion); races without a life-mode/
sect/path/standing have no `reorientation` channel.

**Per-race art/audio budget follows the "signature channel" column** — e.g. Khajiit/Redguard/Orc justify
music production; Dunmer justifies the ash body-mark + ash-shrine anim; Breton/Argonian/Imperial justify
medallion-legibility copy depth over new art.
