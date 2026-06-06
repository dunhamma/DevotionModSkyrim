# PDV Diegetic UX — Custom Asset & Animation Review

**Status:** Review / decision aid. Audits the *entire* diegetic UX plan for where we need **custom**
(can't-reuse-vanilla) assets — textures, audio, animation, meshes — and where vanilla reuse or code-render
already covers us.
**Reads with:** `handoff/PDV_DiegeticUX_AssetProductionSpec.md` (per-asset specs),
`references/authoring/PDV_DiegeticUX_GlyphRescope.md` (glyph wiring), `PDV_DiegeticUX_ArchitectureSpec.md`.
**Date:** 2026-06-05

## How to read this
"**Custom**" = something a person must author/source that vanilla can't supply. The plan is reuse-first, so
the goal here is to show how *small and concentrated* the genuinely-custom burden is, and to flag the
decisions (commission / retarget / source / AI-assist) for each.

Verdict columns: **Reuse** (vanilla/record/code — no custom) · **Recolor** (vanilla base, retuned — trivial)
· **Custom-low/med/high** (must author).

---

## 1. The whole-plan asset ledger

| Surface / channel | What it needs | Verdict | D-phase | Notes |
|---|---|---|---|---|
| **Imagespace tints** (screen) | IMAD records | **Reuse** (records) | D1 | recolor vanilla IMAD; no texture/art |
| **Effect-shader auras** (screen) | EFSH + carrier SPEL | **Recolor** | D1 | tint vanilla EFSH; custom `.dds` only if a base won't tint |
| *— Art object (ARTO) sun-mark* (revelation) | 1 ARTO | **Custom-low (opt)** | D1-opt | nice-to-have; revelation works without it |
| **Sound cues** (sound) | 5–6 SNDR stings | **Custom-med** | D1 | ship vanilla placeholders D1, swap to bespoke |
| **Music beds** (music) | 1–4 MUSC loops | **Custom-med** | D1 (curse bed) / D2 | curse bed can start as filtered vanilla ambience |
| **Medallion** (MISC) | mesh + icon | **Reuse** | D1 | vanilla amulet; bespoke mesh is D3+ nice-to-have |
| **Book of Days** (BOOK) | mesh | **Reuse** | D1 | vanilla book/journal; paper, no art |
| **Body marks** (bodymark) | overlay textures | **Custom-med** | D1 (scar, ash) / D2 (warpaints, soot) | **the main D1 custom-art task** |
| **Prayer/offer/rite anims** (anim) | OAR `.hkx` clips | **Custom-high** | D2 (channel no-ops until then) | **the biggest craft item — see §3** |
| **SPID stance** | `_DISTR.ini` | **Reuse** (config) | D3 | no asset |
| **Prisma instruments** | SVG rendered in JS | **Reuse** (code) | (existing) | no art files — drawn at runtime; PDV's moat |
| **Glyphs/symbols** | SVG | **mostly drawn** | per GlyphRescope | 49 drawn, 15 wired; rest enhancement behind text |

---

## 2. The genuinely-custom shortlist (everything else is reuse/recolor/record)

Only **four** classes require authoring that vanilla can't supply:

1. **Body-overlay textures** — `pdv_scar`, `pdv_ash` (D1); `pdv_warpaint_<race>` ×~10, `pdv_soot` (D2).
2. **Audio** — 5–6 sound stings + 1–4 music loops (placeholders bridge D1).
3. **Animation clips** — the OAR prayer/offer/rite set (D2; degrades gracefully).
4. **Optional polish art** — ARTO sun-mark, bespoke medallion mesh, glyph refinements (`mehrunes-dagon`,
   `tsun`, `satakal`).

**D1 reduces to two real custom-art tasks** (the `pdv_scar` + `pdv_ash` overlays) plus audio swaps —
because animation is gracefully optional and everything else is reuse/recolor/record.

---

## 3. Animation — the deep dive (since you asked specifically)

This is the only **Custom-high** item, so it deserves its own breakdown.

### What clips the plan actually calls for
| Clip | Used by | Shared? | Phase |
|---|---|---|---|
| `kneel` | any shrine/rite | shared | D2 (D1-opt) |
| `offer` (the EventBus beat) | any rite, the BOOK ritual focus | shared | D2 (D1-opt) |
| `ash_kneel` | Dunmer ash-shrine | Dunmer | D2 |
| `moon_rite` | Khajiit moon observance | Khajiit | D2 |
| `forge_ded` | Orc forge dedication | Orc | D2 |
| (later) per-race postures | Redguard Walkabout, Bosmer Pact rite, etc. | per race | D3 |

So the **core set is ~2 shared clips** (`kneel`, `offer`); race-specific postures are additive flavor, not
required for the channel to function.

### The real questions to decide (these drive cost)
- **Idle-replace vs paired/interactive?** Cheapest is a **first-person-safe idle replacement** played at the
  rite (no object alignment). A kneel *at a specific shrine* with hand placement is much costlier (alignment,
  per-shrine variance). **Recommendation: idle-style rite anims, not shrine-aligned**, matching the
  "skippable/interruptible, never a forced lock" rule.
- **Source:** (a) **retarget existing CC-licensed pray/kneel idles** (cheapest, likely sufficient),
  (b) commission, (c) capture/author in Blender→hkx. Reference: Pilgrim pairs with *Divines Prayer
  Animations* (OAR) — that lineage shows retargeted idles are enough.
- **Skeleton coverage:** male + female; first- and third-person. An idle-style clip covers both views with
  one third-person clip if first-person isn't forced.
- **Packaging:** ship as the **PDV-owned OAR submod** (only the OAR engine is a runtime dep) — already
  specced in the asset spec §7.

### Mitigation that de-risks the whole thing
The Director **no-ops the anim channel** if OAR is absent or no clip exists. So **D1 ships with zero
animation** and loses nothing but polish; clips can arrive any time in D2/D3 without rework. Animation is
therefore the *lowest-urgency* custom item despite being the highest-craft.

---

## 4. Audio — the second custom area

| Asset | Custom? | D1 bridge | Final |
|---|---|---|---|
| 5–6 SNDR stings (chime/swell/hollow/rising/distant/click) | yes, but tiny | **vanilla SOUN placeholders** (spell-learn, cure-disease, etc.) | bespoke short stings, sourced/licensed |
| `PDV_MUS_CurseBed` | yes | **filtered/slowed vanilla ambience** | bespoke dissonant loop |
| `PDV_MUS_MoonNight`, `PatronPrayer`, `ChampionMotif` | yes | defer | D2 bespoke loops |

Audio is **Custom-med** but **non-blocking** — placeholders make every audio surface functional at D1.
Decision needed: source library vs commission vs AI-generated stems (license-cleared).

---

## 5. Textures — body overlays (the one unavoidable D1 art)

| Texture | D-phase | Authoring | Trick that shrinks cost |
|---|---|---|---|
| `pdv_scar` | D1 | hand-paint a red sundered mark, 2048² body, alpha | **greyscale + runtime tint** → one texture, many colors |
| `pdv_ash` | D1 | ash-dust motes on shoulders | same greyscale+tint trick |
| `pdv_warpaint_<race>` ×~10 | D2 | per-race face motif | derive from the glyph/instrument marks already drawn |
| `pdv_soot` | D2 | forge soot on hands | reuse a vanilla dirt overlay as base |

**Key cost-saver:** author **greyscale** overlays and apply color via `NiOverride` tint, so a handful of
masks cover every race/state. The D2 warpaints can be **traced from the existing glyph SVGs**
(`scratch/prisma-art/*`), so they're cheaper than they look.

---

## 6. What is explicitly NOT custom (so we don't over-budget)
- **Prisma instruments** — rendered from SVG in JS at runtime; no art files. (Already built/specced.)
- **Glyphs** — 49 already drawn; the diegetic text layer means unwired ones fall back to text, not custom
  work (`PDV_DiegeticUX_GlyphRescope.md`).
- **Imagespace** — records, no art.
- **Medallion/Book meshes** — vanilla reuse.
- **Most effect shaders** — recolor vanilla EFSH.
- **SPID/DF/DBF/DF integration** — config/script, no assets.
- **No new native DLL** — the Prisma bridge is untouched.

---

## 7. Decisions this review surfaces (for you)

1. **Animation sourcing** — retarget CC-licensed idle clips (recommended, cheap) vs commission vs in-house?
   And confirm **idle-style rites, not shrine-aligned** (keeps it cheap + interruptible).
2. **Audio sourcing** — library / commission / AI-generated-cleared for the ~6 stings + 1–2 D1 loops? Or
   ship D1 on vanilla placeholders and revisit?
3. **Body-overlay production** — who paints `pdv_scar` + `pdv_ash` (the only unavoidable D1 art)? Confirm the
   greyscale+tint approach so we author 2 masks, not 20.
4. **Polish art priority** — are the D2 per-race warpaints + bespoke medallion mesh wanted for 1.0, or
   post-1.0? (Traceable from existing glyphs if yes.)

## 8. Bottom line
The plan's custom-asset surface is **small and back-loaded**:
- **Unavoidable for D1:** ~**2 body-overlay textures** (+ optional audio swaps). Everything else D1 is
  reuse/recolor/record.
- **D2 polish:** the OAR animation set (gracefully optional), bespoke audio, per-race warpaints.
- **Never custom:** instruments (code), most glyphs (drawn), imagespace (records), item meshes (reuse).

So the reuse-first architecture is doing its job: a feature this broad lands with essentially **one real art
task to ship the pilot**, and the high-craft animation work is decoupled so it can never block a release.
