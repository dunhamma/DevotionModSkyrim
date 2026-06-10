import math, cairosvg
from medallions import M, gly, DEFS as BASEDEFS
EXTRA='''
<radialGradient id="g_steel" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#b7bcc2"/><stop offset="55%" stop-color="#3a3d44"/><stop offset="100%" stop-color="#15171b"/></radialGradient>
<radialGradient id="f_steel" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#22242a"/><stop offset="100%" stop-color="#0c0d10"/></radialGradient>
<radialGradient id="f_stone" cx="46%" cy="34%" r="78%"><stop offset="0%" stop-color="#e9f1fb"/><stop offset="45%" stop-color="#9fb4d2"/><stop offset="100%" stop-color="#2a3b55"/></radialGradient>
<radialGradient id="g_copper" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#e3b27e"/><stop offset="55%" stop-color="#9c6a3a"/><stop offset="100%" stop-color="#4f3418"/></radialGradient>
<radialGradient id="f_patina" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#2c4438"/><stop offset="100%" stop-color="#0e1a14"/></radialGradient>
<radialGradient id="g_rose" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#f8ddcb"/><stop offset="55%" stop-color="#d99a7a"/><stop offset="100%" stop-color="#834a36"/></radialGradient>
<radialGradient id="f_rose" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#3a2820"/><stop offset="100%" stop-color="#170f0b"/></radialGradient>
<radialGradient id="g_bone" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#efe6c8"/><stop offset="55%" stop-color="#c4b48a"/><stop offset="100%" stop-color="#6e6244"/></radialGradient>
<radialGradient id="f_bonef" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#2e2a1d"/><stop offset="100%" stop-color="#13110a"/></radialGradient>
<radialGradient id="g_void2" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#3a3744"/><stop offset="100%" stop-color="#0a0910"/></radialGradient>
<radialGradient id="f_glow" cx="50%" cy="46%" r="60%"><stop offset="0%" stop-color="#5a4a1e"/><stop offset="60%" stop-color="#1c160a"/><stop offset="100%" stop-color="#0c0a06"/></radialGradient>
'''
DEFS=BASEDEFS.replace("</defs>", EXTRA+"</defs>")

def bezel(cx,cy,R,style,col):
    o=[]
    if style=="beaded":
        for k in range(40): a=k*math.pi/20; o.append(f'<circle cx="{cx+(R-3)*math.cos(a):.1f}" cy="{cy+(R-3)*math.sin(a):.1f}" r="0.7" fill="{col}"/>')
    elif style=="notched":
        for k in range(28): a=k*math.pi/14; o.append(f'<line x1="{cx+(R-1)*math.cos(a):.1f}" y1="{cy+(R-1)*math.sin(a):.1f}" x2="{cx+(R-5)*math.cos(a):.1f}" y2="{cy+(R-5)*math.sin(a):.1f}" stroke="{col}" stroke-width="1"/>')
    elif style=="spiked":
        for k in range(18):
            a=k*math.pi/9; b=a+0.10; c=a-0.10
            o.append(f'<path d="M{cx+(R-2)*math.cos(c):.1f} {cy+(R-2)*math.sin(c):.1f} L{cx+(R+6)*math.cos(a):.1f} {cy+(R+6)*math.sin(a):.1f} L{cx+(R-2)*math.cos(b):.1f} {cy+(R-2)*math.sin(b):.1f} Z" fill="{col}"/>')
    elif style=="rope":
        for k in range(46): a=k*math.pi/23; o.append(f'<line x1="{cx+(R-1)*math.cos(a):.1f}" y1="{cy+(R-1)*math.sin(a):.1f}" x2="{cx+(R-4)*math.cos(a+0.10):.1f}" y2="{cy+(R-4)*math.sin(a+0.10):.1f}" stroke="{col}" stroke-width="1.3"/>')
    elif style=="runic":
        for k in range(12):
            a=k*math.pi/6; x=cx+(R-4)*math.cos(a); y=cy+(R-4)*math.sin(a)
            o.append(f'<g transform="translate({x:.1f},{y:.1f}) rotate({math.degrees(a)+90:.0f})"><path d="M-2 -3 L2 -3 M0 -3 V3 M-2 3 L2 1" stroke="{col}" stroke-width="0.9" fill="none"/></g>')
    elif style=="double":
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{R-4}" fill="none" stroke="{col}" stroke-width="1"/>')
    return "".join(o)

def field_extra(cx,cy,fr,style,col):
    o=[]
    if style=="sunburst":
        for k in range(24): a=k*math.pi/12; o.append(f'<line x1="{cx+5*math.cos(a):.1f}" y1="{cy+5*math.sin(a):.1f}" x2="{cx+(fr-2)*math.cos(a):.1f}" y2="{cy+(fr-2)*math.sin(a):.1f}" stroke="{col}" stroke-width="0.5" opacity="0.5"/>')
    elif style=="enamel":
        o.append(f'<path d="M{cx-fr*0.7} {cy-fr*0.4} A {fr} {fr} 0 0 1 {cx+fr*0.7} {cy-fr*0.4}" stroke="rgba(255,255,255,0.16)" stroke-width="2.5" fill="none"/>')
    elif style=="glow":
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{fr*0.62:.1f}" fill="{col}" opacity="0.5"/>')
    return "".join(o)

def treat(cx,cy,R,key,t):
    o=[f'<circle cx="{cx}" cy="{cy}" r="{R}" fill="url(#{t["rim"]})" stroke="{t["ring"]}" stroke-width="1.6"/>']
    o.append(bezel(cx,cy,R,t["bezel"],t["ring"]))
    fr=R-7
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{fr}" fill="{t["field"]}" stroke="{t["ring"]}" stroke-width="0.8"/>')
    o.append(field_extra(cx,cy,fr,t["fstyle"],t.get("glowcol","#ffe9a8")))
    g=2*fr*0.74; s=g/48.0; tx=cx-g/2; ty=cy-g/2
    if t.get("glow"):
        o.append(f'<g transform="translate({tx:.1f},{ty:.1f}) scale({s:.3f})" opacity="0.5">{gly(M[key],t["glow"],tw=3,nw=5)}</g>')
    o.append(f'<g transform="translate({tx:.1f},{ty:.1f}) scale({s:.3f})">{gly(M[key],t["glyph"])}</g>')
    return "".join(o)

T=[
 ("Polished gold · beaded",     dict(rim="g_gold",ring="#caa44e",field="url(#f_warm)",glyph="#f3e4b0",bezel="beaded",fstyle="matte")),
 ("Satin silver · smooth",      dict(rim="g_silver",ring="#aab4c4",field="url(#f_moon)",glyph="#e8eef7",bezel="smooth",fstyle="matte")),
 ("Obsidian · spiked · ember",  dict(rim="g_ebony",ring="#3a3744",field="url(#f_void)",glyph="#e0613f",bezel="spiked",fstyle="matte",glow="#c64f43")),
 ("Blackened steel · notched",  dict(rim="g_steel",ring="#5a5f66",field="url(#f_steel)",glyph="#cdd2d6",bezel="notched",fstyle="matte")),
 ("Moonstone cabochon",         dict(rim="g_silver",ring="#aab4c4",field="url(#f_stone)",glyph="#1a2740",bezel="double",fstyle="glow",glowcol="#dff0ff")),
 ("Verdigris copper · runic",   dict(rim="g_copper",ring="#7e6a3e",field="url(#f_patina)",glyph="#d8c08a",bezel="runic",fstyle="matte")),
 ("Rose gold · rope",           dict(rim="g_rose",ring="#c98a6a",field="url(#f_rose)",glyph="#f8ddcb",bezel="rope",fstyle="matte")),
 ("Sapphire enamel · gold",     dict(rim="g_gold",ring="#caa44e",field="#1c3f6b",glyph="#f3e4b0",bezel="beaded",fstyle="enamel")),
 ("Oxblood enamel · gold",      dict(rim="g_gold",ring="#caa44e",field="#591717",glyph="#f3e4b0",bezel="smooth",fstyle="enamel")),
 ("Nord iron · sunburst",       dict(rim="g_iron",ring="#6b6f74",field="url(#f_iron)",glyph="#cdd2d6",bezel="runic",fstyle="sunburst")),
 ("Carved bone · jade glyph",   dict(rim="g_bone",ring="#9c8e64",field="url(#f_bonef)",glyph="#a6c781",bezel="smooth",fstyle="matte")),
 ("Ethereal · glowing glyph",   dict(rim="g_void2",ring="#4a4652",field="url(#f_glow)",glyph="#ffe9a8",bezel="smooth",fstyle="glow",glow="#ffe1a0",glowcol="#3a2c0c")),
]
def render(key,out,title):
    cols=4; R=46; cw=R*2+44; ch=R*2+62; rows=(len(T)+cols-1)//cols
    W=cols*cw; H=86+rows*ch
    p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{DEFS}<rect width="{W}" height="{H}" fill="#0d0d0b"/>']
    p.append(f'<text x="{W/2}" y="34" fill="#d8b35a" font-size="21" font-family="Georgia,serif" text-anchor="middle">{title}</text>')
    p.append(f'<text x="{W/2}" y="58" fill="#bcb3a2" font-size="12" font-family="sans-serif" text-anchor="middle">Same glyph ("{key}"), twelve finishes - bezel style + metal + field treatment + glyph rendering. No bail, round form.</text>')
    for i,(lbl,t) in enumerate(T):
        cx=(i%cols)*cw+cw/2; cy=86+(i//cols)*ch+R+8
        p.append(treat(cx,cy,R,key,t))
        p.append(f'<text x="{cx}" y="{cy+R+22}" fill="#f5f0e6" font-size="11.5" font-family="sans-serif" text-anchor="middle">{lbl}</text>')
    p.append("</svg>")
    cairosvg.svg2png(bytestring="".join(p).encode(),write_to=out,scale=2); print("wrote",out)

render("auri-el","med_treatments_aurel.png","Medallion material treatments")
render("hircine","med_treatments_hircine.png","Treatments on an organic glyph")
