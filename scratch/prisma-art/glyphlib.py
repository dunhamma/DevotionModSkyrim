import cairosvg, math
G="#d8b35a"; DARK="#0d0d0b"; THIN="rgba(216,179,90,0.5)"
def render(spec):
    out=[]
    for tag,a in spec:
        sw="0.85" if a.get("class")=="thin" else "1.5"
        at=" ".join(f'{k}="{v}"' for k,v in a.items() if k!="class")
        out.append(f'<{tag} {at} fill="none" stroke="{G}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"/>')
    return "".join(out)
def sheet(glyphs, cols, out, title=""):
    rows=(len(glyphs)+cols-1)//cols
    cw,ch=120,118; W=cols*cw; H=rows*ch+ (30 if title else 0)
    y0=30 if title else 0
    p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{DARK}"/>']
    if title: p.append(f'<text x="{W/2}" y="20" fill="{G}" font-size="14" font-family="Georgia,serif" text-anchor="middle">{title}</text>')
    for i,(k,spec) in enumerate(glyphs.items()):
        cx=(i%cols)*cw; cy=y0+(i//cols)*ch
        p.append(f'<g transform="translate({cx+30},{cy+8})"><svg width="48" height="48" viewBox="0 0 48 48">{render(spec)}</svg></g>')
        p.append(f'<g transform="translate({cx+78},{cy+20})"><svg width="24" height="24" viewBox="0 0 48 48">{render(spec)}</svg></g>')
        p.append(f'<text x="{cx+cw/2}" y="{cy+74}" fill="{G}" font-size="11" font-family="sans-serif" text-anchor="middle">{k}</text>')
    p.append("</svg>")
    cairosvg.svg2png(bytestring="".join(p).encode(), write_to=out, scale=3)
