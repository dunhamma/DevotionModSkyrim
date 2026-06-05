import importlib
mods=["batch1_princes","batch2_khajiit_argonian","batch3_nord_altmer","batch4_redguard","batch5_concept"]
titles={"batch1_princes":"Tier 1 — Daedric Princes","batch2_khajiit_argonian":"Tier 2 — Khajiit lunar pantheon + Argonian","batch3_nord_altmer":"Tier 2 — Nord/Imperial + Altmer","batch4_redguard":"Tier 2 — Redguard / Yokudan","batch5_concept":"Tier 3 — concept marks"}
def jsval(v): return f'"{v}"'
def emit(spec):
    lines=[]
    for tag,a in spec:
        parts=[]
        for k,v in a.items():
            key = "class" if k=="class" else k
            val = "symbol-thin" if k=="class" else v
            parts.append(f'{key}: "{val}"')
        lines.append(f'    ["{tag}", {{ {", ".join(parts)} }}],')
    return "\n".join(lines)
out=["# Prisma glyph SVG data — full roster (Princes, cultural pantheons, concept marks)",
"",
"**Glyph art by the design pass (Claude).** Drop-in `symbolSpecs` entries for the 49 glyphs authored this",
"pass, grouped by batch. Same contract as the other glyph docs (viewBox `0 0 48 48`, `currentColor`,",
"`symbol-thin` accents). Rendered contact sheets: `scratch/prisma-art/batch{1-5}_*.png`.",
"",
"See `PDV_PrismaGlyphRoster_RefinementFlags.md` for the marks I flagged for a second pass.",
""]
gallery=[]
for m in mods:
    mod=importlib.import_module(m)
    out.append(f"## {titles[m]}\n\n```js")
    for k,spec in mod.P.items():
        out.append(f'  "{k}": [')
        out.append(emit(spec))
        out.append("  ],")
        gallery.append(k)
    out.append("```\n")
out.append("## gallerySymbols (?demo) entries\n\n```js")
out.append("  " + ", ".join(f'["{k}",""]' for k in gallery))
out.append("```")
open("../../handoff/PrismaGlyph_FullRoster_SVGData.md","w").write("\n".join(out))
print("wrote handoff/PrismaGlyph_FullRoster_SVGData.md with",len(gallery),"glyphs")
