import math, cairosvg, importlib
# ---- aggregate every glyph spec ----
B={
 "kyne":[("path",{"d":"M10 29c7 -10 16 -13 28 -7"}),("path",{"d":"M14 34c7 -5 14 -5 23 0"}),("path",{"d":"M24 10v13M20 15l4 -5 4 5"})],
 "talos":[("path",{"d":"M24 8v30"}),("path",{"d":"M16 18h16"}),("path",{"d":"M19 38h10"}),("path",{"d":"M18 13l6 -5 6 5"})],
 "auri-el":[("circle",{"cx":"24","cy":"24","r":"8"}),("path",{"d":"M24 7v7M24 34v7M7 24h7M34 24h7M12 12l5 5M31 31l5 5M36 12l-5 5M17 31l-5 5"})],
 "akatosh":[("path",{"d":"M15 9h18M15 39h18M17 11c0 8 14 8 14 18M31 37c0 -8 -14 -8 -14 -18"}),("path",{"d":"M19 24h10","class":"thin"})],
 "arkay":[("circle",{"cx":"24","cy":"24","r":"13"}),("path",{"d":"M24 11v26M14 24h20"})],
 "dibella":[("path",{"d":"M24 17c3 -7 10 -7 11 -1 1 6 -7 10 -11 18 -4 -8 -12 -12 -11 -18 1 -6 8 -6 11 1Z"}),("circle",{"cx":"24","cy":"24","r":"3","class":"thin"})],
 "julianos":[("path",{"d":"M24 8l4 12 12 4 -12 4 -4 12 -4 -12 -12 -4 12 -4 4 -12Z"}),("path",{"d":"M24 17v14M17 24h14","class":"thin"})],
 "mara":[("path",{"d":"M11 25c8 -13 18 -13 26 0"}),("path",{"d":"M15 25v12h18V25"}),("path",{"d":"M20 37v-8h8v8"})],
 "stendarr":[("path",{"d":"M24 8l14 6v10c0 8 -6 14 -14 17 -8 -3 -14 -9 -14 -17V14l14 -6Z"}),("path",{"d":"M24 15v17M17 23h14"})],
 "zenithar":[("path",{"d":"M15 32h18l4 6H11l4 -6Z"}),("path",{"d":"M18 19l8 -8 5 5 -8 8"}),("path",{"d":"M14 23l8 8"})],
 "yffre":[("path",{"d":"M24 38 C18 38 12 34 11 28"}),("path",{"d":"M24 38 C30 38 36 34 37 28"}),("path",{"d":"M24 38 V20"}),("path",{"d":"M24 20 C16 20 10 16 10 10 C10 8 12 8 14 10 C16 12 18 14 24 14"}),("path",{"d":"M24 20 C32 20 38 16 38 10 C38 8 36 8 34 10 C32 12 30 14 24 14"}),("circle",{"cx":"24","cy":"14","r":"3","class":"thin"})],
 "zen":[("path",{"d":"M24 12 V32"}),("path",{"d":"M18 32 H30"}),("path",{"d":"M14 20 H34"}),("path",{"d":"M14 20 L12 28 H20 L18 20","class":"thin"}),("path",{"d":"M34 20 L32 28 H40 L38 20","class":"thin"}),("circle",{"cx":"24","cy":"12","r":"2"})],
 "baan-dar":[("path",{"d":"M16 14 C12 16 10 20 10 24 C10 34 16 38 24 38 C32 38 38 34 38 24 C38 20 36 16 32 14 Z"}),("path",{"d":"M24 10 V38"}),("path",{"d":"M14 22 C14 20 16 19 18 20","class":"thin"}),("circle",{"cx":"30","cy":"22","r":"2.5"}),("path",{"d":"M27 18 C28 17 32 17 33 18","class":"thin"}),("path",{"d":"M18 10 C20 8 28 8 30 10"})],
}
M=dict(B)
M.update(importlib.import_module("glyphs").GLYPHS)
for m in ["batch1_princes","batch2_khajiit_argonian","batch3_nord_altmer","batch4_redguard","batch5_concept"]:
    M.update(importlib.import_module(m).P)
M.update(importlib.import_module("batch6_refined").P)

def gly(spec,col,tw=0.85,nw=1.5):
    o=[]
    for tag,a in spec:
        sw=str(tw) if a.get("class")=="thin" else str(nw)
        at=" ".join(f'{k}="{v}"' for k,v in a.items() if k!="class")
        o.append(f'<{tag} {at} fill="none" stroke="{col}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"/>')
    return "".join(o)

# ---- materials ----
MATS={
 "gold":  dict(rim="g_gold",field="f_warm",ring="#caa44e",glyph="#f3e4b0",bead=True,name="Aedric gold"),
 "ebony": dict(rim="g_ebony",field="f_void",ring="#3a3744",glyph="#c64f43",bead=False,name="Daedric ebony"),
 "silver":dict(rim="g_silver",field="f_moon",ring="#aab4c4",glyph="#e8eef7",bead=True,name="Lunar silver"),
 "bronze":dict(rim="g_bronze",field="f_sand",ring="#9c6f33",glyph="#ecca87",bead=True,name="Yokudan bronze"),
 "iron":  dict(rim="g_iron",field="f_iron",ring="#6b6f74",glyph="#cdd2d6",bead=False,name="Nordic iron"),
 "pearl": dict(rim="g_pearl",field="f_pearl",ring="#d8c79a",glyph="#f6efda",bead=True,name="Altmer pearl-gold"),
 "wood":  dict(rim="g_wood",field="f_wood",ring="#7a5a32",glyph="#cf9f63",bead=False,name="Bosmer livewood"),
 "jade":  dict(rim="g_jade",field="f_jadef",ring="#6f8a5e",glyph="#cfe0b4",bead=False,name="Argonian bone-jade"),
 "neutral":dict(rim="g_neu",field="f_neu",ring="#8a8170",glyph="#e7dcc2",bead=False,name="Concept (TBD)"),
}
DEFS='''<defs>
<radialGradient id="g_gold" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#f8ecc0"/><stop offset="55%" stop-color="#d8b35a"/><stop offset="100%" stop-color="#7d5d24"/></radialGradient>
<radialGradient id="f_warm" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#3c331f"/><stop offset="100%" stop-color="#181308"/></radialGradient>
<radialGradient id="g_ebony" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#54505e"/><stop offset="55%" stop-color="#211f28"/><stop offset="100%" stop-color="#0a0910"/></radialGradient>
<radialGradient id="f_void" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#241f2b"/><stop offset="100%" stop-color="#080610"/></radialGradient>
<radialGradient id="g_silver" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#f4f7fb"/><stop offset="55%" stop-color="#b9c2d0"/><stop offset="100%" stop-color="#5f6a7a"/></radialGradient>
<radialGradient id="f_moon" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#23293400"/><stop offset="0%" stop-color="#232934"/><stop offset="100%" stop-color="#0c0f15"/></radialGradient>
<radialGradient id="g_bronze" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#f0d49a"/><stop offset="55%" stop-color="#b07d3a"/><stop offset="100%" stop-color="#5e3f18"/></radialGradient>
<radialGradient id="f_sand" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#3a2f1c"/><stop offset="100%" stop-color="#15100a"/></radialGradient>
<radialGradient id="g_iron" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#cdd2d6"/><stop offset="55%" stop-color="#6b6f74"/><stop offset="100%" stop-color="#33363a"/></radialGradient>
<radialGradient id="f_iron" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#26282b"/><stop offset="100%" stop-color="#0e0f10"/></radialGradient>
<radialGradient id="g_pearl" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#fbf6e6"/><stop offset="55%" stop-color="#e3d3a6"/><stop offset="100%" stop-color="#9c8552"/></radialGradient>
<radialGradient id="f_pearl" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#34301f"/><stop offset="100%" stop-color="#16130b"/></radialGradient>
<radialGradient id="g_wood" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#caa06a"/><stop offset="55%" stop-color="#7a5a32"/><stop offset="100%" stop-color="#3f2c16"/></radialGradient>
<radialGradient id="f_wood" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#2e2415"/><stop offset="100%" stop-color="#120d07"/></radialGradient>
<radialGradient id="g_jade" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#cfe0b4"/><stop offset="55%" stop-color="#6f8a5e"/><stop offset="100%" stop-color="#37452e"/></radialGradient>
<radialGradient id="f_jadef" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#1f2a1b"/><stop offset="100%" stop-color="#0a0f08"/></radialGradient>
<radialGradient id="g_neu" cx="38%" cy="30%" r="75%"><stop offset="0%" stop-color="#e7dcc2"/><stop offset="55%" stop-color="#8a8170"/><stop offset="100%" stop-color="#46423a"/></radialGradient>
<radialGradient id="f_neu" cx="50%" cy="38%" r="72%"><stop offset="0%" stop-color="#2a2823"/><stop offset="100%" stop-color="#100f0c"/></radialGradient>
</defs>'''

def medallion(cx,cy,R,key,matname):
    m=MATS[matname]; o=[]
    # outer rim
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{R}" fill="url(#{m["rim"]})" stroke="{m["ring"]}" stroke-width="1.6"/>')
    if m["bead"]:
        for k in range(36):
            a=k*math.pi/18; o.append(f'<circle cx="{cx+(R-3)*math.cos(a):.1f}" cy="{cy+(R-3)*math.sin(a):.1f}" r="0.7" fill="{m["ring"]}"/>')
    # inner field (recessed)
    fr=R-7
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{fr}" fill="url(#{m["field"]})" stroke="{m["ring"]}" stroke-width="0.8"/>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="{fr}" fill="none" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>')
    # glyph
    g=2*fr*0.74; s=g/48.0
    o.append(f'<g transform="translate({cx-g/2:.1f},{cy-g/2:.1f}) scale({s:.3f})">{gly(M[key],m["glyph"])}</g>')
    return "".join(o)

def sheet(title,sub,items,cols,out,R=44):
    cw=R*2+58; ch=R*2+78; rows=(len(items)+cols-1)//cols
    W=cols*cw; H=70+rows*ch
    p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{DEFS}<rect width="{W}" height="{H}" fill="#0d0d0b"/>']
    p.append(f'<text x="{W/2}" y="30" fill="#d8b35a" font-size="20" font-family="Georgia,serif" text-anchor="middle">{title}</text>')
    p.append(f'<text x="{W/2}" y="52" fill="#bcb3a2" font-size="12" font-family="sans-serif" text-anchor="middle">{sub}</text>')
    for i,(key,label,mat) in enumerate(items):
        cx=(i%cols)*cw+cw/2; cy=70+(i//cols)*ch+R+18
        p.append(medallion(cx,cy,R,key,mat))
        p.append(f'<text x="{cx}" y="{cy+R+24}" fill="#f5f0e6" font-size="13" font-family="Georgia,serif" text-anchor="middle">{label}</text>')
    p.append("</svg>")
    cairosvg.svg2png(bytestring="".join(p).encode(),write_to=out,scale=2)
    print("wrote",out)
