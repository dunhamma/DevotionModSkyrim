import cairosvg
G="#d8b35a"; DARK="#0d0d0b"; THIN="rgba(216,179,90,0.55)"
# Each glyph: list of (tag, attrs) in 48x48, currentColor stroke, no fill (line-art family)
GLYPHS={
 "lunar":[  # twin crescents interlocking (the lattice)
   ("path",{"d":"M30 10 a14 14 0 1 0 0 28 a10 14 0 1 1 0 -28 Z"}),
   ("circle",{"cx":"19","cy":"24","r":"4","class":"thin"}),
 ],
 "hist":[  # rooted tree
   ("path",{"d":"M24 40 V22"}),
   ("path",{"d":"M24 40 C18 40 13 38 11 34","class":"thin"}),
   ("path",{"d":"M24 40 C30 40 35 38 37 34","class":"thin"}),
   ("path",{"d":"M14 22 A10 10 0 0 1 34 22"}),
   ("path",{"d":"M17 26 A7 7 0 0 1 31 26","class":"thin"}),
   ("circle",{"cx":"24","cy":"14","r":"2.5"}),
 ],
 "ancestor":[  # ancestral mask
   ("path",{"d":"M14 16 Q24 8 34 16 Q34 34 24 40 Q14 34 14 16 Z"}),
   ("circle",{"cx":"19","cy":"22","r":"1.8"}),("circle",{"cx":"29","cy":"22","r":"1.8"}),
   ("path",{"d":"M24 26 V32","class":"thin"}),
   ("path",{"d":"M18 14 Q24 11 30 14","class":"thin"}),
 ],
 "malacath":[  # tusk + hammer
   ("path",{"d":"M16 38 C10 28 14 18 24 16"}),
   ("path",{"d":"M24 16 L24 8 M16 10 H32 V14 H16 Z"}),
   ("path",{"d":"M24 16 V30","class":"thin"}),
 ],
 "sect":[  # crossed scimitars
   ("path",{"d":"M12 36 C20 30 30 18 36 12"}),
   ("path",{"d":"M36 36 C28 30 18 18 12 12"}),
   ("circle",{"cx":"24","cy":"24","r":"2.4"}),
 ],
 "branch":[  # bound branch with leaf
   ("path",{"d":"M10 34 C20 30 30 24 38 12"}),
   ("path",{"d":"M22 25 q8 -10 14 -7 q-5 9 -14 7 Z","class":"thin"}),
   ("path",{"d":"M16 30 q4 5 8 0","class":"thin"}),
 ],
}
def render(spec):
    out=[]
    for tag,a in spec:
        sw="0.9" if a.get("class")=="thin" else "1.6"
        at=" ".join(f'{k}="{v}"' for k,v in a.items() if k!="class")
        out.append(f'<{tag} {at} fill="none" stroke="{G}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"/>')
    return "".join(out)
# contact sheet at two sizes (48 and 24) to verify small-size legibility
if __name__=='__main__':
    keys=list(GLYPHS)
    cell=70; W=len(keys)*cell; H=170
    p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{DARK}"/>']
    for i,k in enumerate(keys):
        x=i*cell
        p.append(f'<g transform="translate({x+11},14) scale(1.0)"><svg width="48" height="48" viewBox="0 0 48 48">{render(GLYPHS[k])}</svg></g>')
        p.append(f'<g transform="translate({x+23},74)"><svg width="24" height="24" viewBox="0 0 48 48">{render(GLYPHS[k])}</svg></g>')
        p.append(f'<text x="{x+35}" y="120" fill="{G}" font-size="11" font-family="sans-serif" text-anchor="middle">{k}</text>')
        p.append(f'<text x="{x+35}" y="136" fill="{THIN}" font-size="8" font-family="sans-serif" text-anchor="middle">48px / 24px</text>')
    p.append("</svg>")
    svg="".join(p)
    cairosvg.svg2png(bytestring=svg.encode(), write_to="scratch/prisma-art/glyphs.png", scale=3)
    print("ok")
