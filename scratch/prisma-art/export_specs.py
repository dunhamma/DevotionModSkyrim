import importlib
mods=["batch1_princes","batch2_khajiit_argonian","batch3_nord_altmer","batch4_redguard","batch5_concept"]
titles={"batch1_princes":"Tier 1 — Daedric Princes","batch2_khajiit_argonian":"Tier 2 — Khajiit lunar pantheon + Argonian","batch3_nord_altmer":"Tier 2 — Nord/Imperial + Altmer","batch4_redguard":"Tier 2 — Redguard / Yokudan","batch5_concept":"Tier 3 — concept marks"}
refined=importlib.import_module("batch6_refined").P   # lore-grounded overrides
def emit(spec):
    lines=[]
    for tag,a in spec:
        parts=[]
        for k,v in a.items():
            key="class" if k=="class" else k
            val="symbol-thin" if k=="class" else v
            parts.append(f'{key}: "{val}"')
        lines.append(f'    ["{tag}", {{ {", ".join(parts)} }}],')
    return "\n".join(lines)
out=["# Prisma glyph SVG data — full roster (Princes, cultural pantheons, concept marks)","",
"**Glyph art by the design pass (Claude).** Drop-in `symbolSpecs` for the 49-glyph roster. Glyphs marked",
"**(refined)** use the lore-grounded second pass (`scratch/prisma-art/batch6_refined.png`); the rest are the",
"first pass (`batch{1-5}_*.png`). Same contract as the other glyph docs (viewBox `0 0 48 48`, `currentColor`,",
"`symbol-thin` accents). See `PrismaGlyphRoster_RefinementFlags.md` for the lore basis of each refinement.",""]
gallery=[]
for m in mods:
    P=importlib.import_module(m).P
    out.append(f"## {titles[m]}\n\n```js")
    for k,spec in P.items():
        use = refined.get(k, spec)
        tag = "  // (refined)" if k in refined else ""
        out.append(f'  "{k}": [{tag}')
        out.append(emit(use)); out.append("  ],")
        gallery.append(k)
    out.append("```\n")
out.append("## gallerySymbols (?demo) entries\n\n```js")
out.append("  " + ", ".join(f'["{k}",""]' for k in gallery))
out.append("```")
open("../../handoff/PrismaGlyph_FullRoster_SVGData.md","w").write("\n".join(out))
print("regenerated with",len(refined),"refined overrides")
