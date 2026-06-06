# PDV Diegetic UX — Asset Production Spec (Track E)

**Status:** Production spec for the **diegetic channel assets** (imagespace, shaders, sound, music,
overlays, animation, the medallion/book items). Glyph/symbol art is a separate Prisma concern — see
`references/authoring/PDV_DiegeticUX_GlyphRescope.md`.
**Owner:** Claude owns these specs; production (texture/audio/anim) is scheduled per the cost column.
**Reads with:** `PDV_DiegeticUX_ArchitectureSpec.md` §4 (channel contracts), `PDV_DiegeticUX_D1PilotPacket.md`
(the D1 subset), `scratch/prisma-art/ux_samples.py` (mark/silhouette shapes).
**Date:** 2026-06-05

## Palette (authoritative — from `scratch/prisma-art/instruments.py`)
`gold #d8b35a` · `gold-soft rgba(216,179,90,0.18)` · `lit #ecdcab` · `dark #1b1a16` · `green #8bbf9f` ·
`red #c97968` · `cold #7fa8c9` · `muted #9c9485` · `parchment #e8dcbf` · `ink #3a3122`.

## Production principle: **reuse vanilla first.** Every channel ships D1 with vanilla-derived placeholders,
then swaps to bespoke. Nothing here blocks D1 on original art except (optionally) the OAR clips.

---

## 1. Imagespace modifiers (IMAD) — `screen` tint
Records only; **no textures**. Recolor/retune vanilla IMAD as the base.

| EditorID | Tone | Base (vanilla IMAD to copy) | Tune | Dur | Phase |
|---|---|---|---|---|---|
| `PDV_IMAD_Reverent` | reverent | `BlessingImod` / a warm bloom | +brightness, warm gold tint, gentle bloom | 1.0s xfade | D1 |
| `PDV_IMAD_Revelation` | revelation | a white flash imod | high brightness, desat→white, fast in/slow out | 1.2s | D1 |
| `PDV_IMAD_Dread` | dread | a frost/curse imod | −saturation, cold-blue tint, vignette | apply→hold until cure | D1 |
| `PDV_IMAD_Release` | release | a heal/cleanse imod | clearing, faint green, brighten then settle | 1.2s | D1 |
| `PDV_IMAD_Absence` | absence | a fade-to-grey imod | slow −saturation, no tint | 0.8s | D1 |
| `PDV_IMAD_Turning` | turning | neutral | brief mild desat | 0.6s | D2 |
| `PDV_IMAD_Apotheosis` | apotheosis | strong bloom | strong warm gold, sustained | 2.0s | D2 |

**Spec rules:** keep peak subtle (this layers over ENB); never leave a persistent grade except the curse
`Dread`, which is *removed* on cure. Author the cross-fade in (`ApplyCrossFade`) and a clean `Remove`.

---

## 2. Effect shaders (EFSH/ARTO/RFCT) + carrier ability (SPEL) — `screen` aura
One self-target **ability SPEL** per tone, carrying the EFSH (+ optional ARTO art object). Recolor a
vanilla EFSH as base.

| SPEL ability | EFSH base | Color / look | Art object | Phase |
|---|---|---|---|---|
| `PDV_Abil_Shader_Reverent` | a heal/blessing EFSH | gold rim particles, soft | — | D1 |
| `PDV_Abil_Shader_Revelation` | a holy/light EFSH | white, rising sun-mark | `PDV_ARTO_SunMark` (opt) | D1 |
| `PDV_Abil_Shader_Dread` | a frost-cloak EFSH | cold-blue shroud, low | — | D1 |
| `PDV_Abil_Shader_Release` | a turn-undead/cleanse EFSH | green cleansing rings | — | D1 |

**Ability shape:** self-target, no projectile, `Recover`-style add→timed remove (≤1.5s pulse) via the
Director, EXCEPT `Dread` which is added on curse onset and removed on cure. **EFSH textures:** reuse the
vanilla particle/gradient textures recolored in the EFSH fields (membrane/particle color RGB from palette);
custom `.dds` only if a vanilla base can't be tinted to target. **Cost: low** (recolor) / med (custom ARTO).

---

## 3. Sound (SNDR/SOUN) — `sound` cue
Short stings; ship D1 with vanilla SOUN placeholders, swap to bespoke.

| SNDR EditorID | Character | Length | Placeholder (vanilla) | Phase |
|---|---|---|---|---|
| `PDV_SND_Chime` | soft ascending chime (favor/tier) | ~0.8s | a spell-learn/skill-up sound | D1 |
| `PDV_SND_Swell` | low rising swell (emergence) | ~1.5s | a shrine-blessing sound | D1 |
| `PDV_SND_Hollow` | hollow falling tone (disfavor/curse) | ~1.0s | a curse/disease sound | D1 |
| `PDV_SND_RisingChime` | brighter rising (cure) | ~1.2s | a cure-disease sound | D1 |
| `PDV_SND_Distant` | distant, thinning (neglect) | ~1.2s | a faint wind/ambience | D1 |
| `PDV_SND_Click` | tonal click (reorientation) | ~0.4s | a UI/menu tone | D2 |

**Format:** mono `.xwm` (or `.wav`→xwm), 44.1k. Output model: 2D/non-spatial (play on player). **Cost: med**
(sourcing/licensing 5–6 short stings); D1 placeholders make it non-blocking.

---

## 4. Music (MUSC/MUST) — `music` bed
| MUSC EditorID | Use | Loop | Mood | Phase |
|---|---|---|---|---|
| `PDV_MUS_CurseBed` | applied during curse state | 60–120s loop | dissonant, low, unresolved | D1 |
| `PDV_MUS_MoonNight` | Khajiit full-moon outdoor nights | 60–90s | sparse, lunar, reverent | D1-opt |
| `PDV_MUS_PatronPrayer` | praying at patron shrine | 30–60s | warm, brief, resolves | D2 |
| `PDV_MUS_ChampionMotif` | Champion entry sting→bed | 20–40s | apotheosis | D2 |

**Structure:** each MUSC references a MUST track set; add/remove the type via the formlist/`MusicType`
pattern (reversible, never stomps combat/quest — see Combat Music Fix lesson). **Format:** stereo `.xwm`.
**Cost: med** (1–2 loops for D1; bed can start from a slowed/filtered vanilla ambience).

---

## 5. Items — `medallion` (MISC) + `journal` (BOOK)
| Record | Art | Phase |
|---|---|---|
| `PDV_DevotionMedallion` (MISC) | **reuse a vanilla amulet** mesh + inventory icon; no new art | D1 |
| `PDV_BookOfDays` (BOOK) | vanilla journal/book mesh; paper — **no art** | D1 |

Both granted at origin. Medallion text via Description Framework; Book via Dynamic Book Framework. **Cost:
near-zero.** (A bespoke medallion mesh is a *nice-to-have*, D3+.)

---

## 6. Body overlays (RaceMenu / NiOverride) — `bodymark`
Texture overlays applied to body (and/or face) overlay slots. Mark shapes per
`scratch/prisma-art/ux_samples.py:t_body`.

| Texture | Use | Slot | Look | Phase |
|---|---|---|---|---|
| `pdv_scar` | curse onset→cure (shared) | body overlay 0 | red sundered mark, upper chest/arm | D1 |
| `pdv_ash` | Dunmer ancestor depth ≥3 | body overlay 1 | muted ash dust motes, shoulders | D1 |
| `pdv_warpaint_<race>` | Champion tier (per race) | face overlay | gold, race-motif (Kyne storm, moon, sun, etc.) | D2 |
| `pdv_soot` | Orc forge-life | body overlay 1 | dark forge soot, hands/forearms | D2 |

**Format:** `.dds` BC7/DXT5 with alpha, **2048² body** / 1024² face, tileable to the vanilla body UV.
Apply tint via `AddNodeOverrideInt` (emissive/tint) so one greyscale texture serves multiple colors.
**Budget:** PDV uses ≤2 named body slots + 1 face slot; respect `NiOverride.ini`. **Cost: med** (a few
hand-authored overlays; warpaints D2).

---

## 7. Animation — `anim` (PDV-owned OAR submod)
**Only the OAR engine is a runtime dependency; PDV ships the clips.** Folder layout:
```
Data/meshes/actors/character/animations/OpenAnimationReplacer/PDV_Devotion/
  config.json                      ; { "name":"PDV Devotion Rites", "author":"PDV", "priority": 1900 }
  kneel/    { config.json (conditions), pdv_kneel.hkx }      ; shared shrine kneel
  offer/    { config.json, pdv_offer.hkx }                   ; shared offering gesture
  ash_kneel/{ config.json, pdv_ash_kneel.hkx }               ; Dunmer ash-shrine posture
  moon_rite/{ config.json, pdv_moon_rite.hkx }   (D2)        ; Khajiit
  forge_ded/{ config.json, pdv_forge_ded.hkx }   (D2)        ; Orc
```
**Per-anim `config.json` conditions:** `IsActorBase`/keyword gates + a PDV condition variable
(`EmitPrayerAnim` sets it) so the clip only replaces the idle during the rite. **Clip source:** retarget
vanilla pray/kneel idles (or a CC-licensed source); `.hkx` for SE. **Cost: high** — the one real craft
item. **Mitigation:** D1 may ship the anim channel *off* (Director no-ops if `!Has("OAR")` or no clip);
everything else degrades cleanly, clips land in D2.

---

## 8. Production summary & sourcing

| Channel | New original art? | D1 path | Cost |
|---|---|---|---|
| Imagespace | no (records) | recolor vanilla | low |
| Effect shader | recolor; opt ARTO | vanilla EFSH tint | low–med |
| Sound | yes (stings) | vanilla SOUN placeholder → swap | med |
| Music | 1–2 loops | filtered vanilla bed | med |
| Medallion/Book | no | reuse vanilla mesh | ~zero |
| Body overlays | yes (greyscale + tint) | scar + ash | med |
| Animation | yes (hkx) | **channel off if absent** | high (D2) |
| Glyphs | (separate doc) | already drawn; wiring scope in GlyphRescope | — |

### Minimum-to-ship-D1 asset set (everything else degrades gracefully)
- [ ] 5 IMAD (recolor) · 4 EFSH+SPEL (recolor) — **low**
- [ ] 5 SNDR (vanilla placeholders ok) — **low if placeholder**
- [ ] 1 MUSC `PDV_MUS_CurseBed` (filtered vanilla ok) — **low if placeholder**
- [ ] `PDV_DevotionMedallion` MISC + `PDV_BookOfDays` BOOK (vanilla meshes) — **~zero**
- [ ] 2 overlays `pdv_scar`, `pdv_ash` — **med**
- [ ] OAR submod **optional** for D1 (channel no-ops without it)

**Result:** D1 can ship feeling complete with essentially **two real art tasks** (scar + ash overlays) and
a handful of audio swaps; animation and bespoke audio/music are D2 polish.
