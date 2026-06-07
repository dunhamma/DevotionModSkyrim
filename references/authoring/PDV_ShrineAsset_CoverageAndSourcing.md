# PDV Shrine Assets — Coverage Gap & Sourcing Review

**Status:** Review / decision aid. Answers: *do we need shrine assets for deities that lack them in-game, and
where would we source them?*
**Reads with:** `references/authoring/PDV_MedallionDeityCoverageAudit.md` (the roster + wired status),
`references/vanilla-gameplay/pdv-crosswalk/deity-shrine-crosswalk.csv`,
`references/vanilla-gameplay/religion-magic/divine-shrines.csv`,
`references/authoring/PDV_PortableDevotionalToken_BuildSpec.md`, `PDV_Architecture_v3.md` §21.3.
**Date:** 2026-06-05

## Short answer

**For 1.0: mostly no — by design.** PDV already routes around missing shrines with three deliberate
patterns, so bespoke shrine *meshes* are **not on the critical path** and fall in the same "custom art = V2"
bucket we just deferred. Where a shrineless deity is also a scorable focus, the **portable token** or
**co-attaching the nearest vanilla object** is the 1.0 answer. Bespoke shrines are a V2 polish track, and
there are good free/permission asset sources when we get there.

The real gate is the same as it was for glyphs: **a deity needs a shrine only once it's a *scorable* focus**
— and most cultural deities aren't scored yet (`PDV_MedallionDeityCoverageAudit.md`: only ~5–13 of 45+16 are
wired). A shrine for an unscored deity is premature.

---

## 1. What vanilla already gives us (co-attach targets — no new asset)

PDV's sanctioned posture (§21.3): **per-reference co-attachment to existing shrine references; never replace
base shrine scripts.** So every deity with a vanilla shrine is already covered:

| Vanilla shrine asset | Covers |
|---|---|
| Nine Divines blessing shrines | Akatosh, Arkay, Dibella, Julianos, **Kynareth (≈ Nord Kyne)**, Mara, Stendarr, **Talos**, Zenithar |
| Auriel shrines (Dawnguard / Forgotten Vale) | **Auri-El** (Altmer foundation) |
| Malacath shrines/totems (orc strongholds: Largashbur etc.) | **Malacath** (Orc — covered) |
| Azura statue shrine (the giant statue) | **Azura** (Dunmer Reclamation) |
| Sacellum of Boethiah altar | **Boethiah** (Dunmer Reclamation) |
| Nightingale Hall / Nocturnal | Nocturnal |
| Daedric quest statues/altars (the 17 Princes) | Princes, variably — quest-bound, not all "pray-for-blessing" |

So Divines-worshippers (Nord, Imperial, Breton broad, Altmer-Auri-El), Orc-Malacath, and Dunmer
Azura/Boethiah all have a physical shrine to co-attach to **today, with zero new art**.

---

## 2. The genuine gap — deities with no vanilla shrine

Concentrated in the **cultural pantheons**. Cross-referenced against how PDV already handles each:

| Group | Shrineless deities | Already handled by | New shrine needed? |
|---|---|---|---|
| **Khajiit lunar** | Riddle'Thar, Khenarthi, Jone/Jode, Alkosh, S'rendarr, Rajhin | **lunar substrate** + medallion/journal; moon is the "shrine" | No — substrate is the surface |
| **Argonian** | Hist, Sithis | **Hist-sap token** + Hist substrate (water proximity) | No — token + substrate |
| **Dunmer** | Mephala (no public shrine), the ancestors | **Ash-shrine token** + ancestor substrate (Azura/Boethiah have shrines) | No — token + substrate |
| **Redguard/Yokudan** | Tu'whacca, Satakal, HoonDing, Tall Papa, Morwha, Diagna, Onsi, Sep, Leki | **Far Shores token** (+ vanilla **Arkay** shrine fallback for Tu'whacca-as-death-god) | No — token + Arkay fallback |
| **Bosmer** | Y'ffre, Baan Dar, Z'en, Jephre | action/context (Green Pact) + branch substrate; **no token yet** | **Optional** — best candidate for a token or co-attach |
| **Altmer (cultural)** | Trinimac, Syrabane, Xarxes, Phynaster, Magnus | action/context; Auri-El shrine covers the lead | Optional, V2 |
| **Nord (cultural)** | Shor, Tsun, Stuhn, Orkey, Herma-Mora | action/context; Kynareth/Talos shrines cover the leads | Optional, V2 |

**Takeaway:** the four substrate/token races (Khajiit, Argonian, Dunmer, Redguard) are *already covered* —
their whole design exists *because* their gods lack accessible shrines. The residual gap is **Bosmer +
cultural Altmer/Nord focus deities**, and even those route devotion through actions, not a shrine. The single
clearest candidate for a new devotional object is **Bosmer (a Y'ffre token/grove co-attach)**, paralleling
the three existing tokens.

---

## 3. Why PDV mostly doesn't need new shrines (the four reasons)

1. **The portable token pattern** (`PDV_PortableDevotionalToken_BuildSpec.md`) is the explicit substitute —
   a reusable BOOK "ritual focus" usable anywhere, reusing vanilla art, with a home/private-shrine bonus.
   Three ship already (ash-shrine, Far Shores, Hist sap); a Bosmer one would close the main residual gap.
2. **Action/context devotion** — most piety comes from deeds (hunts, mercy, oaths, Green Pact), not from
   shrine-praying. Shrines are one surface among many.
3. **Co-attachment to existing shrines** (§21.3) covers every Divine/Auri-El/Malacath/Azura/Boethiah deity
   with no new asset.
4. **The diegetic layer** (medallion/journal/screen/sound) gives devotional feedback *without* a shrine — a
   Khajiit feels Khenarthi via the moon tell + medallion, not an altar.

And: **bespoke shrine meshes are exactly the custom art we deferred to V2** — consistent with the
`PDV_DiegeticUX_CustomAssetReview.md` decision.

---

## 4. Sourcing ladder (cheapest/safest first) — for when we do add shrines

| # | Option | Cost | Compatibility | Use when |
|---|---|---|---|---|
| 1 | **Co-attach a vanilla shrine** (SPID/keyword/per-ref) | none | excellent | deity has a vanilla shrine (Divines, Auri-El, Malacath, Azura, Boethiah) |
| 2 | **Portable token** (reuse vanilla art) | ~zero | excellent | shrineless deity — the proven PDV answer (extend to Bosmer) |
| 3 | **Co-attach a thematic vanilla static** (a tree/grove for Y'ffre, a menhir/standing stone, an ancestral urn, a moon-dial clutter piece) | low (CK) | excellent | want an in-world spot without a custom mesh |
| 4 | **Kitbash / retexture vanilla shrine+statue meshes** | low–med (CK + texture) | good | want a distinct look from existing parts |
| 5 | **Modder-resource shrine packs** (see §5) | med (integration + license) | check per pack | want bespoke per-deity statues; V2 |
| 6 | **Commission / CC0 3D source** | high | n/a | last resort, post-1.0 |

**Default policy:** options **1–3 for 1.0** (no custom art); options **4–6 are V2**.

---

## 5. Concrete asset sources (Nexus modder resources)

If/when we go bespoke (V2), these are the lore-friendly shrine/altar resources — **verify each license
before use:**

- **Religious Resources of Tamriel (RRoT)** — altar/shrine meshes for all Aedra/Daedra/saints.
  ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/7557)) — **License caveat:** requires listing
  it as a required file / explicit permission; not freely bundleable. Best as a *dependency*, not a copy.
- **Religious Shrines of Tamriel (RSOT)** — shrines for all deities; a Wintersun addon; credits **Billyro's**
  altar mesh/texture resource. ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/25688))
- **Daedric Shrines – All in One (Xtudo)** — statues made from scratch; **assets free to use for mods if
  hosted on Nexus.** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/78809)) — friendliest
  license for the Prince statues.
- **Billyro's altar resources** — the underlying mesh/texture resource several of the above build on (look
  up Billyro's modder-resource pages).
- **Vanilla + DLC + CC** statue/standing-stone/clutter meshes — always available for kitbash (option 4).

**Reference implementations** (how religion mods solved the same gap — study, don't copy):
- **Wintersun – Faiths of Skyrim** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/22506)) —
  adds shrines for ~50 deities incl. Khajiit/Yokudan/Bosmer gods. **The de-facto religion mod most players
  run.**
- **Pilgrim – A Religion Overhaul** ([nexus](https://www.nexusmods.com/skyrimspecialedition/mods/54099)) —
  dozens of deity shrines (incompatible with Wintersun — players pick one).

---

## 6. Coexistence — the compatibility angle (important)

Most PDV players will **already run Wintersun or Pilgrim**, which *already place* cultural-deity shrines in
the world. So the highest-value, lowest-cost move is **soft co-attachment**: if a Wintersun/Pilgrim shrine
for a deity is present, PDV recognizes it (SPID keyword / reference check) and routes a devotional signal —
**reusing their asset, adding none of our own.** This matches §21.3 (co-attach, don't replace) and the
"compatibility is trust" rule. PDV should **never compete** with those mods by shipping rival shrines;
it should ride on whatever shrine layer the player already has, and fall back to the token/diegetic layer
when none is present.

---

## 7. Recommendation & decisions

**1.0 (V1):**
- Co-attach vanilla shrines where they exist (Divines/Auri-El/Malacath/Azura/Boethiah) — no asset.
- Lean on the three existing tokens; **add a Bosmer token** to close the main residual gap (reuses vanilla
  art, ~zero cost — the one shrine-adjacent thing worth doing for 1.0).
- Optional soft co-attach to Wintersun/Pilgrim shrines if present (SPID keyword).
- **No bespoke shrine meshes.**

**V2:**
- Bespoke per-deity shrine statics for the cultural focus deities, sourced via §5 (Daedric Shrines AIO for
  Princes — friendly license; RRoT/RSOT/Billyro for Aedra/cultural — license permitting; or kitbash).

**Decisions for you:**
1. **Bosmer token — in for 1.0?** (Parallels the three proven tokens; closes the clearest gap cheaply.)
2. **Soft co-attach to Wintersun/Pilgrim shrines — worth a small SPID pass for 1.0**, or V2?
3. **V2 bespoke shrines — which deities first?** (Likely Khajiit lunar + Bosmer Y'ffre + Yokudan, if we go
   beyond tokens.) And confirm the license-safe source per deity (Xtudo AIO for Princes; kitbash for the
   rest unless RRoT/RSOT permission is secured).
