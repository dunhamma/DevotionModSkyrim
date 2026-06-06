"""PDV diegetic-UX sample mockups.

Palette-accurate visual samples of the Tier B surfaces from
references/authoring/PDV_ImmersiveUX_DiegeticSurfaces_Buildout.md, in the same
SVG->cairosvg pipeline + gold/parchment palette as the Prisma instrument art.

These are MOCKUPS of what each surface looks like, not in-game captures. In game
each renders via its named tool (Description Framework, Dynamic Book Framework,
imagespace/EFSH records, RaceMenu overlays, SPID, etc.). Audio is illustrated,
not audible. Outputs:

  ux_samples_contactsheet.png   one board, every surface tiled
  ux_samples_cursecure.png      "one moment, all channels" composite (curse cure)
"""
import math, cairosvg

# ---- palette (from instruments.py) -------------------------------------------
G="#d8b35a"; GS="rgba(216,179,90,0.18)"; LIT="#ecdcab"; DARK="#1b1a16"
LINE="rgba(224,204,158,0.40)"; TXT="#f5f0e6"; MUT="#9c9485"; GRN="#8bbf9f"; RED="#c97968"
PANEL="#15140f"; BG="#0d0d0b"; PARCH="#e8dcbf"; INK="#3a3122"; COLD="#7fa8c9"
SERIF='font-family="Georgia, serif"'

def png(svg, path, scale=2.0):
    cairosvg.svg2png(bytestring=svg.encode(), write_to=path, scale=scale)
    print("wrote", path)

# ---- small drawing helpers ---------------------------------------------------
def fig(cx, by, h, fill, op=1.0):
    """hooded standing figure silhouette."""
    hr=h*0.11; hy=by-h*0.86
    b=(f'M {cx-h*0.22} {by} Q {cx-h*0.15} {by-h*0.60} {cx-h*0.10} {by-h*0.70} '
       f'L {cx-h*0.055} {by-h*0.78} Q {cx} {by-h*0.85} {cx+h*0.055} {by-h*0.78} '
       f'L {cx+h*0.10} {by-h*0.70} Q {cx+h*0.15} {by-h*0.60} {cx+h*0.22} {by} Z')
    return (f'<circle cx="{cx}" cy="{hy}" r="{hr}" fill="{fill}" opacity="{op}"/>'
            f'<path d="{b}" fill="{fill}" opacity="{op}"/>')

def kneel(cx, by, h, fill, op=1.0):
    """kneeling figure (bowed)."""
    hr=h*0.11; hy=by-h*0.55
    b=(f'M {cx-h*0.26} {by} Q {cx-h*0.20} {by-h*0.34} {cx-h*0.08} {by-h*0.44} '
       f'Q {cx} {by-h*0.52} {cx+h*0.08} {by-h*0.44} Q {cx+h*0.22} {by-h*0.32} {cx+h*0.28} {by} Z')
    return (f'<circle cx="{cx+h*0.02}" cy="{hy}" r="{hr}" fill="{fill}" opacity="{op}"/>'
            f'<path d="{b}" fill="{fill}" opacity="{op}"/>')

def moon_star(cx, cy, r, col=G):
    """Khenarthi mark: crescent + small star (lunar/wind)."""
    out=[f'<path d="M {cx} {cy-r} A {r} {r} 0 1 0 {cx} {cy+r} A {r*0.72} {r} 0 1 1 {cx} {cy-r} Z" '
         f'fill="{col}"/>']
    sx,sy,sr=cx+r*0.9, cy-r*0.55, r*0.34
    pts=[]
    for i in range(10):
        rr=sr if i%2==0 else sr*0.42
        a=-math.pi/2+i*math.pi/5
        pts.append(f'{sx+rr*math.cos(a):.1f},{sy+rr*math.sin(a):.1f}')
    out.append(f'<polygon points="{" ".join(pts)}" fill="{col}"/>')
    return "".join(out)

def sun(cx, cy, r, col=G, rays=12):
    out=[f'<circle cx="{cx}" cy="{cy}" r="{r*0.55}" fill="none" stroke="{col}" stroke-width="2"/>']
    for i in range(rays):
        a=i*2*math.pi/rays
        x1,y1=cx+r*0.7*math.cos(a),cy+r*0.7*math.sin(a)
        x2,y2=cx+r*math.cos(a),cy+r*math.sin(a)
        out.append(f'<line x1="{x1:.1f}" y1="{y1:.1f}" x2="{x2:.1f}" y2="{y2:.1f}" stroke="{col}" stroke-width="1.6"/>')
    return "".join(out)

def broken(cx, cy, r, col=RED):
    """curse mark: a sundered ring."""
    return (f'<path d="M {cx+r} {cy} A {r} {r} 0 1 1 {cx-r*0.2} {cy-r*0.97}" fill="none" '
            f'stroke="{col}" stroke-width="2.4" stroke-linecap="round"/>'
            f'<line x1="{cx-r*0.5}" y1="{cy-r*0.5}" x2="{cx+r*0.5}" y2="{cy+r*0.5}" '
            f'stroke="{col}" stroke-width="2.0"/>')

def panel(x,y,w,h,fill=PANEL,stroke=LINE,rx=10,sw=1.2,op=1.0):
    return (f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" '
            f'stroke="{stroke}" stroke-width="{sw}" opacity="{op}"/>')

def label(cx,y,t,col=G,size=15,anchor="middle",weight="normal",italic=False,ls="0"):
    st=' font-style="italic"' if italic else ''
    return (f'<text x="{cx}" y="{y}" fill="{col}" font-size="{size}" {SERIF} '
            f'text-anchor="{anchor}" font-weight="{weight}"{st} letter-spacing="{ls}">{t}</text>')

def lines(x,y,arr,col=TXT,size=12.5,lh=18,anchor="start",italic=False):
    st=' font-style="italic"' if italic else ''
    o=[f'<text x="{x}" y="{y}" fill="{col}" font-size="{size}" {SERIF} text-anchor="{anchor}"{st}>']
    for i,s in enumerate(arr):
        dy=0 if i==0 else lh
        o.append(f'<tspan x="{x}" dy="{dy}">{s}</tspan>')
    o.append('</text>')
    return "".join(o)

# ---- tiles (each draws into a TW x TH group at 0,0) --------------------------
TW,TH=372,256

def tile_frame(title, sub=""):
    s=[panel(1,1,TW-2,TH-2,fill=PANEL,rx=12)]
    s.append(label(TW/2,26,title,col=G,size=15,weight="bold"))
    if sub: s.append(label(TW/2,44,sub,col=MUT,size=11,italic=True))
    return s

# B1 medallion states ----------------------------------------------------------
def t_medallion(state):
    s=tile_frame("B1 · Living Medallion", "Description Framework — inventory hover")
    # disc
    dcx,dcy,dr=92,140,46
    if state=="devoted":
        rim,markcol,bodycol=G,G,TXT
        name="Medallion of Khenarthi"
        body=["Favor: <tspan fill=\"%s\">Devoted</tspan>."%GRN,
              "The wind carries your name.",
              "Last heard: this dawn."]
        glow=f'<circle cx="{dcx}" cy="{dcy}" r="{dr+7}" fill="none" stroke="{G}" stroke-width="1" opacity="0.5"/>'
    elif state=="neglected":
        rim,markcol,bodycol=MUT,MUT,MUT
        name="Medallion (dimmed)"
        body=["Favor: <tspan fill=\"%s\">Faithful</tspan>, slipping."%MUT,
              "Unheard for <tspan fill=\"%s\">six days</tspan>."%RED,
              "Pray, or offer on the road."]
        glow=""
    else: # cursed
        rim,markcol,bodycol=RED,RED,MUT
        name="Medallion (shadowed)"
        body=["Favor: <tspan fill=\"%s\">silent</tspan>."%RED,
              "A curse stands between",
              "you and the sky."]
        glow=f'<circle cx="{dcx}" cy="{dcy}" r="{dr+6}" fill="none" stroke="{RED}" stroke-width="1" opacity="0.35"/>'
    s.append(glow)
    s.append(f'<circle cx="{dcx}" cy="{dcy}" r="{dr}" fill="{DARK}" stroke="{rim}" stroke-width="2"/>')
    s.append(f'<circle cx="{dcx}" cy="{dcy}" r="{dr-7}" fill="none" stroke="{rim}" stroke-width="0.8" opacity="0.6"/>')
    s.append(f'<g transform="translate({dcx-14},{dcy-12}) scale(0.9)">{moon_star(14,14,15,markcol)}</g>')
    # tooltip panel
    px,py,pw,ph=156,98,200,96
    s.append(panel(px,py,pw,ph,fill="#0f0e0a",rx=8))
    s.append(lines(px+12,py+24,[name],col=G,size=11.5,lh=14))
    s.append(f'<line x1="{px+12}" y1="{py+32}" x2="{px+pw-12}" y2="{py+32}" stroke="{LINE}" stroke-width="0.8"/>')
    s.append(lines(px+12,py+50,body,col=bodycol,size=10.8,lh=15))
    return s

# B2 journal -------------------------------------------------------------------
def t_journal():
    s=[panel(1,1,TW-2,TH-2,fill=PANEL,rx=12)]
    s.append(label(TW/2,26,"B2 · The Book of Days",col=G,size=15,weight="bold"))
    s.append(label(TW/2,44,"Dynamic Book Framework — self-writing journal",col=MUT,size=11,italic=True))
    # parchment page
    px,py,pw,ph=26,56,TW-52,182
    s.append(panel(px,py,pw,ph,fill=PARCH,stroke="#b9a87f",rx=6,sw=1.4))
    s.append(label(TW/2,py+24,"The Book of Days",col=INK,size=14,italic=True))
    s.append(f'<line x1="{px+18}" y1="{py+32}" x2="{px+pw-18}" y2="{py+32}" stroke="#b9a87f" stroke-width="0.8"/>')
    entries=[
        ("17th Last Seed — dawn","The day's small devotions noted; the road was kept."),
        ("19th Last Seed","You reached <tspan font-style=\"italic\">Devoted</tspan>. The pantheon turns to look."),
        ("24th Last Seed","Six days of silence. Khenarthi's wind has stilled around you."),
        ("2nd Hearthfire","Cold takes you. The moons close their eyes — a curse is on you."),
        ("9th Hearthfire","The scar closes. The sky is yours again; she hears you once more."),
    ]
    yy=py+52
    for d,t in entries:
        s.append(lines(px+18,yy,[d],col="#6a5836",size=10.5,lh=12,italic=True))
        # wrap body to ~ width
        s.append(lines(px+18,yy+14,[t],col=INK,size=10.8,lh=13))
        yy+=30
    return s

# B3/B4 screen states ----------------------------------------------------------
def t_screen(kind):
    s=[panel(1,1,TW-2,TH-2,fill=PANEL,rx=12)]
    titles={
        "bloom":("B4+B3 · Tier reached","warm gold bloom + brief aura"),
        "emerge":("B4 · Patron emergence","white revelation bloom"),
        "neglect":("B4 · Neglect onset","grey desaturate"),
        "curse":("B4+B3 · Curse onset","cold vignette + shroud"),
        "cure":("B4+B3 · Curse cure","clearing fade + cleansing shimmer"),
    }
    tt,ss=titles[kind]
    s.append(label(TW/2,26,tt,col=G,size=14,weight="bold"))
    s.append(label(TW/2,44,ss,col=MUT,size=10.5,italic=True))
    # screen frame
    fx,fy,fw,fh=26,56,TW-52,180
    defs=[]
    # sky gradient per kind
    sky={"bloom":("#2a2418","#5a4a23"),"emerge":("#241f2a","#6f6a86"),
         "neglect":("#222019","#39362e"),"curse":("#10131a","#243246"),
         "cure":("#1a2018","#3a5a44")}[kind]
    defs.append(f'<linearGradient id="sky_{kind}" x1="0" y1="0" x2="0" y2="1">'
                f'<stop offset="0" stop-color="{sky[1]}"/><stop offset="1" stop-color="{sky[0]}"/></linearGradient>')
    # vignette
    vig={"bloom":(G,0.0),"emerge":("#ffffff",0.0),"neglect":("#000000",0.55),
         "curse":("#0a1830",0.6),"cure":("#cfe6d8",0.0)}[kind]
    defs.append(f'<radialGradient id="vig_{kind}" cx="0.5" cy="0.5" r="0.7">'
                f'<stop offset="0.55" stop-color="{vig[0]}" stop-opacity="0"/>'
                f'<stop offset="1" stop-color="{vig[0]}" stop-opacity="{vig[1]}"/></radialGradient>')
    s.append("<defs>"+"".join(defs)+"</defs>")
    s.append(f'<clipPath id="clip_{kind}"><rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" rx="6"/></clipPath>')
    s.append(f'<g clip-path="url(#clip_{kind})">')
    s.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="url(#sky_{kind})"/>')
    # distant mountains
    gy=fy+fh*0.66
    s.append(f'<path d="M {fx} {gy} L {fx+70} {gy-34} L {fx+130} {gy-8} L {fx+200} {gy-40} '
             f'L {fx+fw} {gy-14} L {fx+fw} {fy+fh} L {fx} {fy+fh} Z" fill="#000000" opacity="0.32"/>')
    # ground
    s.append(f'<rect x="{fx}" y="{fy+fh*0.82}" width="{fw}" height="{fh*0.18}" fill="#000000" opacity="0.35"/>')
    cx=fx+fw/2; by=fy+fh*0.92; h=fh*0.6
    # tint overlay
    tint={"bloom":(G,0.30),"emerge":("#ffffff",0.34),"neglect":("#8a8475",0.42),
          "curse":(COLD,0.30),"cure":("#bfe8cf",0.30)}[kind]
    # aura rings
    aura=""
    if kind=="bloom":
        for i,rr in enumerate((28,40,52)):
            aura+=f'<circle cx="{cx}" cy="{by-h*0.45}" r="{rr}" fill="none" stroke="{G}" stroke-width="{2.2-i*0.6}" opacity="{0.55-i*0.15}"/>'
    if kind=="emerge":
        aura+=sun(cx,by-h*0.62,30,"#f3efe2")
    if kind=="curse":
        aura+=f'<circle cx="{cx}" cy="{by-h*0.45}" r="40" fill="{COLD}" opacity="0.10"/>'
        aura+=broken(cx,by-h*0.95,14,RED)
    if kind=="cure":
        for i,rr in enumerate((24,38,54)):
            aura+=f'<circle cx="{cx}" cy="{by-h*0.45}" r="{rr}" fill="none" stroke="{GRN}" stroke-width="{2.0-i*0.5}" opacity="{0.6-i*0.16}"/>'
    figcol="#000000"
    s.append(fig(cx,by,h,figcol,0.82))
    s.append(aura)
    s.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="{tint[0]}" opacity="{tint[1]}"/>')
    s.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="url(#vig_{kind})"/>')
    s.append('</g>')
    s.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" rx="6" fill="none" stroke="{LINE}" stroke-width="1.2"/>')
    return s

# B5 sound cue -----------------------------------------------------------------
def t_sound():
    s=tile_frame("B5 · Favor you can hear","sound + music — illustrated, not audible")
    cues=[("Favor noted","soft chime",GRN,[0.3,0.7,0.5,0.85,0.6]),
          ("Disfavor","hollow tone",RED,[0.7,0.4,0.55,0.3,0.35]),
          ("Patron swell","low rising bed",G,[0.2,0.35,0.5,0.7,0.95])]
    yb=78
    for nm,desc,col,env in cues:
        s.append(lines(34,yb+4,[nm],col=col,size=12,lh=12))
        s.append(lines(34,yb+20,[desc],col=MUT,size=10,lh=12,italic=True))
        # waveform-ish bars
        bx=180; bw=10; gap=6; base=yb+10
        for i,e in enumerate(env):
            hh=8+e*30
            s.append(f'<rect x="{bx+i*(bw+gap)}" y="{base-hh/2}" width="{bw}" height="{hh}" rx="3" fill="{col}" opacity="0.8"/>')
        # extend with trailing softer bars
        for j in range(5):
            e=env[-1]*(0.7**(j+1))
            hh=8+e*30
            s.append(f'<rect x="{bx+(5+j)*(bw+gap)}" y="{base-hh/2}" width="{bw}" height="{hh}" rx="3" fill="{col}" opacity="0.4"/>')
        yb+=58
    return s

# B6 prayer storyboard ---------------------------------------------------------
def t_prayer():
    s=tile_frame("B6 · Devotion performed","bundled OAR submod — only the engine is required")
    poses=[("approach",fig),("kneel",kneel),("offer",kneel),("rise",fig)]
    n=len(poses); cellw=(TW-52)/n; x0=26; by=216; h=120
    for i,(nm,fn) in enumerate(poses):
        cx=x0+cellw*(i+0.5)
        s.append(f'<line x1="{x0+cellw*(i+1)}" y1="64" x2="{x0+cellw*(i+1)}" y2="226" stroke="{LINE}" stroke-width="0.6" opacity="0.5"/>' if i<n-1 else "")
        s.append(fn(cx,by,h,G,0.9))
        if nm=="offer":
            s.append(f'{moon_star(cx, by-h*0.5, 8, LIT)}')
        s.append(label(cx,236,nm,col=MUT,size=10.5))
    return s

# B7 body marks ----------------------------------------------------------------
def t_body():
    s=tile_frame("B7 · Marks on the body","RaceMenu / NiOverride overlays")
    marks=[("Curse scar",RED,"onset → fades on cure"),
           ("Champion warpaint",G,"appears at Champion tier"),
           ("Ancestor ash",MUT,"deep Dunmer ancestor")]
    n=len(marks); cellw=(TW-52)/n; x0=26
    for i,(nm,col,desc) in enumerate(marks):
        cx=x0+cellw*(i+0.5); by=176; h=120
        s.append(fig(cx,by,h,"#2a2a26",1.0))
        if nm=="Curse scar":
            s.append(f'<path d="M {cx-6} {by-h*0.62} l 10 26 l -8 14" fill="none" stroke="{col}" stroke-width="2.2" stroke-linecap="round"/>')
        elif nm=="Champion warpaint":
            s.append(f'<path d="M {cx-12} {by-h*0.66} q 12 -10 24 0" fill="none" stroke="{col}" stroke-width="2"/>')
            s.append(f'<line x1="{cx}" y1="{by-h*0.66}" x2="{cx}" y2="{by-h*0.5}" stroke="{col}" stroke-width="1.8"/>')
        else:
            for d in (-8,0,8):
                s.append(f'<circle cx="{cx+d}" cy="{by-h*0.5}" r="2.4" fill="{col}"/>')
        s.append(label(cx,200,nm,col=col,size=11))
        s.append(label(cx,216,desc,col=MUT,size=9,italic=True))
    return s

# B8 SPID disposition ----------------------------------------------------------
def t_spid():
    s=tile_frame("B8 · The world recognizes you","SPID stance — non-voiced (V1)")
    def bar(x,y,frac,col,who,note):
        w=150
        s.append(lines(x,y-8,[who],col=TXT,size=11,lh=12))
        s.append(f'<rect x="{x}" y="{y}" width="{w}" height="10" rx="5" fill="#000000" stroke="{LINE}" stroke-width="0.8"/>')
        s.append(f'<rect x="{x}" y="{y}" width="{w*frac}" height="10" rx="5" fill="{col}"/>')
        s.append(lines(x+w+10,y+9,[note],col=col,size=9.5,lh=11,italic=True))
    bar(34,96,0.82,GRN,"Priest of Khenarthi","warms ↑")
    bar(34,150,0.28,RED,"Zealot of a rival god","cools ↓")
    s.append(lines(34,196,["Disposition shifts on your devotion globals.","No new lines, no voice — they simply","treat you as your faith has earned."],
                   col=MUT,size=10.5,lh=15,italic=True))
    return s

# legend -----------------------------------------------------------------------
def t_legend():
    s=[panel(1,1,TW-2,TH-2,fill="#100f0b",rx=12)]
    s.append(label(TW/2,28,"How to read these",col=G,size=14,weight="bold"))
    s.append(lines(24,56,[
        "Mockups, not in-game captures. Each surface",
        "renders via its named tool in the build-out.",
        "",
        "One transition fires a COMBO of channels by",
        "tone (see §1 profile table): e.g. a curse cure =",
        "clearing screen + cleansing aura + rising chime",
        "+ medallion brightens + scar fades + journal",
        "line + one MessageBox.",
        "",
        "Routine favor stays SILENT by default —",
        "journal digest only. Toasts demote to an MCM",
        "verbosity option; MessageBoxes stay for real",
        "choices.",
    ],col=MUT,size=10.8,lh=14.2))
    return s

# ---- assemble contact sheet --------------------------------------------------
def contact_sheet():
    cols=3; pad=20; top=86; gap=16
    grid=[
        t_medallion("devoted"), t_medallion("neglected"), t_medallion("cursed"),
        t_journal(), t_screen("bloom"), t_screen("emerge"),
        t_screen("neglect"), t_screen("curse"), t_screen("cure"),
        t_prayer(), t_body(), t_spid(),
        t_sound(), t_legend(),
    ]
    rows=(len(grid)+cols-1)//cols
    W=pad*2+cols*TW+(cols-1)*gap
    H=top+pad+rows*TH+(rows-1)*gap
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
    out.append(f'<rect width="{W}" height="{H}" fill="{BG}"/>')
    out.append(label(W/2,46,"PlayerDevotion — Diegetic UX Sample Sheet",col=G,size=24,weight="bold"))
    out.append(label(W/2,70,"what the Tier B surfaces look like  ·  palette-accurate mockups",col=MUT,size=13,italic=True))
    for i,tile in enumerate(grid):
        r,c=divmod(i,cols)
        x=pad+c*(TW+gap); y=top+r*(TH+gap)
        out.append(f'<g transform="translate({x},{y})">'+"".join(tile)+'</g>')
    out.append('</svg>')
    png("".join(out), "ux_samples_contactsheet.png", scale=2.0)

# ---- composite: one moment, all channels (curse cure) ------------------------
def curse_cure_composite():
    W,H=1080,620; pad=28
    out=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">']
    out.append(f'<rect width="{W}" height="{H}" fill="{BG}"/>')
    out.append(label(W/2,46,"One moment, every channel — the Curse Cure beat",col=G,size=24,weight="bold"))
    out.append(label(W/2,70,"the moment PDV computes today but never tells the player (audit C2)",col=MUT,size=13,italic=True))
    # big screen on left
    fx,fy,fw,fh=pad,96,604,420
    out.append(f'<defs><linearGradient id="ck" x1="0" y1="0" x2="0" y2="1">'
               f'<stop offset="0" stop-color="#3a5a44"/><stop offset="1" stop-color="#1a2018"/></linearGradient>'
               f'<radialGradient id="cg" cx="0.5" cy="0.45" r="0.65">'
               f'<stop offset="0.4" stop-color="#ecdcab" stop-opacity="0.0"/>'
               f'<stop offset="1" stop-color="#bfe8cf" stop-opacity="0.18"/></radialGradient></defs>')
    out.append(f'<clipPath id="cc"><rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" rx="10"/></clipPath>')
    out.append(f'<g clip-path="url(#cc)">')
    out.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="url(#ck)"/>')
    gy=fy+fh*0.66
    out.append(f'<path d="M {fx} {gy} L {fx+160} {gy-70} L {fx+300} {gy-16} L {fx+440} {gy-78} '
               f'L {fx+fw} {gy-26} L {fx+fw} {fy+fh} L {fx} {fy+fh} Z" fill="#000" opacity="0.30"/>')
    cx=fx+fw/2; by=fy+fh*0.92; h=fh*0.62
    for i,rr in enumerate((54,86,120,160)):
        out.append(f'<circle cx="{cx}" cy="{by-h*0.45}" r="{rr}" fill="none" stroke="{GRN}" '
                   f'stroke-width="{3.2-i*0.6}" opacity="{0.7-i*0.15}"/>')
    out.append(fig(cx,by,h,"#0c140e",0.9))
    out.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="#bfe8cf" opacity="0.16"/>')
    out.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" fill="url(#cg)"/>')
    # MessageBox overlay (the one push surface that stays)
    mb_w,mb_h=380,150; mbx=fx+(fw-mb_w)/2; mby=fy+fh-mb_h-26
    out.append(panel(mbx,mby,mb_w,mb_h,fill="rgba(8,8,6,0.86)",stroke=G,rx=8,sw=1.4))
    out.append(label(mbx+mb_w/2,mby+30,"— Khenarthi —",col=G,size=15,italic=True))
    out.append(lines(mbx+24,mby+58,[
        "The shadow lifts. The moons open their eyes",
        "upon you once more, and the wind remembers",
        "your name. Walk on, and keep faith.",],col=TXT,size=13,lh=22))
    out.append(label(mbx+mb_w/2,mby+mb_h-16,"[ Continue ]",col=G,size=12))
    out.append('</g>')
    out.append(f'<rect x="{fx}" y="{fy}" width="{fw}" height="{fh}" rx="10" fill="none" stroke="{LINE}" stroke-width="1.4"/>')
    out.append(label(fx+fw/2,fy+fh+22,"screen  ·  clearing imagespace fade + cleansing aura (B4+B3)  +  rising chime (B5)",
                     col=MUT,size=11.5,italic=True))

    # right column: the quiet channels
    rx0=fx+fw+34; rw=W-rx0-pad
    # medallion before/after
    out.append(panel(rx0,96,rw,150,fill=PANEL,rx=10))
    out.append(label(rx0+rw/2,120,"B1 · Medallion brightens",col=G,size=14,weight="bold"))
    for j,(st,col,txt) in enumerate([("before",RED,"silent"),("after",GRN,"Faithful")]):
        mcx=rx0+rw*(0.28+0.44*j); mcy=185
        out.append(f'<circle cx="{mcx}" cy="{mcy}" r="30" fill="{DARK}" stroke="{col}" stroke-width="2"/>')
        out.append(f'<g transform="translate({mcx-12},{mcy-10}) scale(0.78)">{moon_star(12,12,13,col)}</g>')
        out.append(label(mcx,mcy+52,st,col=MUT,size=10.5,italic=True))
        out.append(label(mcx,mcy+38,txt,col=col,size=11))
    out.append(label(rx0+rw/2,193,"→",col=TXT,size=22))

    # journal line
    out.append(panel(rx0,262,rw,118,fill=PARCH,stroke="#b9a87f",rx=8,sw=1.3))
    out.append(label(rx0+rw/2,286,"B2 · The Book of Days",col=INK,size=13,italic=True))
    out.append(f'<line x1="{rx0+20}" y1="294" x2="{rx0+rw-20}" y2="294" stroke="#b9a87f" stroke-width="0.8"/>')
    out.append(lines(rx0+20,314,["9th Hearthfire"],col="#6a5836",size=11,lh=12,italic=True))
    out.append(lines(rx0+20,332,["The scar closes. The sky is yours again;",
                                 "she hears you once more."],col=INK,size=11.5,lh=16))

    # body mark
    out.append(panel(rx0,396,rw,120,fill=PANEL,rx=10))
    out.append(label(rx0+rw/2,416,"B7 · Scar fades from the body",col=G,size=14,weight="bold"))
    for j,(st,op,col) in enumerate([("before",1.0,RED),("after",0.0,RED)]):
        mcx=rx0+rw*(0.28+0.44*j); by=502; h=72
        out.append(fig(mcx,by,h,"#2a2a26",1.0))
        if op>0:
            out.append(f'<path d="M {mcx-5} {by-h*0.62} l 7 17 l -5 10" fill="none" stroke="{col}" stroke-width="2" stroke-linecap="round" opacity="{op}"/>')
        out.append(label(mcx,by+12,st,col=MUT,size=10,italic=True))
    out.append(label(rx0+rw/2,474,"→",col=TXT,size=22))

    out.append(label(W/2,H-16,
        "Routine favor would stay silent (journal digest only). A cure is a true transition, so the MessageBox stays — everything else is diegetic.",
        col=MUT,size=11.5,italic=True))
    out.append('</svg>')
    png("".join(out), "ux_samples_cursecure.png", scale=2.0)

if __name__=="__main__":
    contact_sheet()
    curse_cure_composite()
