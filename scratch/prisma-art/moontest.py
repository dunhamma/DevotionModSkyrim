import math, cairosvg
GOLD="#d8b35a"; LIT="#ecdcab"; DARK="#1b1a16"; BG="#10100f"

def moon(cx, cy, r, phase):
    f=(phase-1)/8.0           # 0=new .5=full
    a=f*2*math.pi
    lit=(1-math.cos(a))/2.0
    rx=abs(r*math.cos(a))
    out=[f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{DARK}" stroke="{GOLD}" stroke-width="1.2"/>']
    top=f"{cx},{cy-r}"; bot=f"{cx},{cy+r}"
    if lit>0.985:
        out.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{LIT}" stroke="{GOLD}" stroke-width="1.2"/>')
        return "".join(out)
    if lit<0.015:
        return "".join(out)
    if f<0.5:  # waxing, lit on right
        outer=f"A {r} {r} 0 0 1 {bot}"
        inner_sweep = 0 if lit<0.5 else 1
    else:      # waning, lit on left
        outer=f"A {r} {r} 0 0 0 {bot}"
        inner_sweep = 1 if lit<0.5 else 0
    out.append(f'<path d="M {top} {outer} A {rx} {r} 0 0 {inner_sweep} {top} Z" fill="{LIT}"/>')
    out.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{GOLD}" stroke-width="1.2"/>')
    return "".join(out)

W=8*60; H=90
p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{BG}"/>']
names=["new","wax cres","first qtr","wax gibb","full","wan gibb","last qtr","wan cres"]
for i in range(8):
    cx=30+i*60; p.append(moon(cx,40,20,i+1))
    p.append(f'<text x="{cx}" y="80" fill="{GOLD}" font-size="9" font-family="sans-serif" text-anchor="middle">{i+1} {names[i]}</text>')
p.append("</svg>")
svg="".join(p)
cairosvg.svg2png(bytestring=svg.encode(), write_to="scratch/prisma-art/moontest.png", scale=2)
print("ok")
