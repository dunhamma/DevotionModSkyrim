import math, cairosvg
G="#d8b35a"; GS="rgba(216,179,90,0.18)"; LIT="#ecdcab"; DARK="#1b1a16"
LINE="rgba(224,204,158,0.45)"; TXT="#f5f0e6"; MUT="#bcb3a2"; GRN="#8bbf9f"; RED="#c97968"
PANEL="#15140f"; BG="#0d0d0b"

def moon(cx,cy,r,phase,sw=1.1):
    f=(phase-1)/8.0; a=f*2*math.pi; lit=(1-math.cos(a))/2; rx=abs(r*math.cos(a))
    o=[f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{DARK}" stroke="{G}" stroke-width="{sw}"/>']
    top=f"{cx},{cy-r}"; bot=f"{cx},{cy+r}"
    if lit>0.985: o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{LIT}" stroke="{G}" stroke-width="{sw}"/>')
    elif lit>=0.015:
        if f<0.5: outer=f"A {r} {r} 0 0 1 {bot}"; isw=0 if lit<0.5 else 1
        else:     outer=f"A {r} {r} 0 0 0 {bot}"; isw=1 if lit<0.5 else 0
        o.append(f'<path d="M {top} {outer} A {rx} {r} 0 0 {isw} {top} Z" fill="{LIT}"/>')
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{G}" stroke-width="{sw}"/>')
    return "".join(o)

def card(x,y,w,h,title,sub,state,inner,tone=G):
    return (f'<g transform="translate({x},{y})">'
      f'<rect x="0" y="0" width="{w}" height="{h}" rx="10" fill="{PANEL}" stroke="{LINE}" stroke-width="1"/>'
      f'<text x="14" y="22" fill="{G}" font-size="13" font-family="Georgia,serif" font-weight="bold">{title}</text>'
      f'<text x="{w-14}" y="22" fill="{MUT}" font-size="10" font-family="sans-serif" text-anchor="end">{sub}</text>'
      f'<g transform="translate(0,6)">{inner}</g>'
      f'<text x="14" y="{h-12}" fill="{tone}" font-size="11" font-family="sans-serif">{state}</text>'
      f'</g>')

CW,CH=300,170

def lunar():
    o=[moon(70,82,26,4)]                      # Masser, waxing gibbous
    o.append(moon(118,52,12,4,0.9))           # Secunda, smaller, offset
    # focus sigil (8-point star = Azurah/lunar) right side
    cx,cy=232,78; 
    star=" ".join(f"{cx+R*math.cos(k*math.pi/4)},{cy+R*math.sin(k*math.pi/4)}" for k,R in [(i,(20 if i%2==0 else 8)) for i in range(8)])
    o.append(f'<polygon points="{star}" fill="none" stroke="{G}" stroke-width="1.1"/>')
    o.append(f'<circle cx="{cx}" cy="{cy}" r="3" fill="{G}"/>')
    # 8-phase strip
    for i in range(8):
        bx=150+i*16; on = i==3
        o.append(f'<circle cx="{bx}" cy="128" r="5" fill="{LIT if on else DARK}" stroke="{G if on else LINE}" stroke-width="1"/>')
    return "".join(o)

def hist():
    o=[]
    # trunk
    o.append(f'<path d="M150 132 V70" stroke="{G}" stroke-width="2.4" fill="none"/>')
    # roots (Hist relation)
    for dx in (-1,1):
        o.append(f'<path d="M150 132 C{150+dx*22} 134 {150+dx*40} 138 {150+dx*58} 132" stroke="{G}" stroke-width="1.3" fill="none"/>')
        o.append(f'<path d="M150 132 C{150+dx*14} 138 {150+dx*22} 146 {150+dx*30} 150" stroke="{LINE}" stroke-width="1" fill="none"/>')
    # canopy (People) — layered arcs
    for R,sw in [(46,1.6),(34,1.2),(22,1)]:
        o.append(f'<path d="M{150-R} 70 A {R} {R} 0 0 1 {150+R} 70" stroke="{G}" stroke-width="{sw}" fill="none"/>')
    o.append(f'<circle cx="150" cy="58" r="3" fill="{G}"/>')
    # void shadow creeping from right
    o.append(f'<path d="M196 70 A 46 46 0 0 0 178 36 L196 36 Z" fill="rgba(201,121,104,0.18)" stroke="{RED}" stroke-width="0.8"/>')
    return "".join(o)

def ancestor():
    o=[]
    # niche arch
    o.append(f'<path d="M88 134 V70 A62 56 0 0 1 212 70 V134" stroke="{LINE}" stroke-width="1.2" fill="none"/>')
    # row of masks, some lit (depth=3)
    xs=[110,150,190]; lit=[1,1,0]
    for i,mx in enumerate(xs):
        on=lit[i]
        col=LIT if on else DARK
        o.append(f'<path d="M{mx-14} 92 Q{mx} 80 {mx+14} 92 Q{mx+12} 118 {mx} 124 Q{mx-12} 118 {mx-14} 92 Z" fill="{GS if on else DARK}" stroke="{G if on else LINE}" stroke-width="1.2"/>')
        o.append(f'<circle cx="{mx-5}" cy="100" r="1.6" fill="{G if on else LINE}"/><circle cx="{mx+5}" cy="100" r="1.6" fill="{G if on else LINE}"/>')
        o.append(f'<path d="M{mx} 104 V112" stroke="{G if on else LINE}" stroke-width="1"/>')
    # ash motes
    import random; random.seed(3)
    for _ in range(14):
        ax=random.uniform(95,205); ay=random.uniform(60,130)
        o.append(f'<circle cx="{ax:.0f}" cy="{ay:.0f}" r="0.9" fill="{MUT}" opacity="0.5"/>')
    return "".join(o)

def forge():
    o=[]
    # anvil
    o.append(f'<path d="M120 120 H180 L172 132 H128 Z" fill="{GS}" stroke="{G}" stroke-width="1.4"/>')
    o.append(f'<path d="M150 120 V100 M132 100 H180 L168 92 H132 Z" fill="{GS}" stroke="{G}" stroke-width="1.4"/>')
    # flame
    o.append(f'<path d="M150 86 C140 74 158 70 150 56 C168 66 164 84 150 86 Z" fill="rgba(216,179,90,0.22)" stroke="{G}" stroke-width="1.3"/>')
    # tusk marks (Malacath) flanking
    o.append(f'<path d="M96 128 C88 112 96 98 110 96" stroke="{G}" stroke-width="1.3" fill="none"/>')
    o.append(f'<path d="M204 128 C212 112 204 98 190 96" stroke="{G}" stroke-width="1.3" fill="none"/>')
    return "".join(o)

def sects():
    o=[]
    # three crossed-blade emblems; middle active (ringed)
    for i,cx in enumerate((92,150,208)):
        active = i==1
        o.append(f'<path d="M{cx} 76 V120 M{cx-13} 90 H{cx+13}" stroke="{G if active else LINE}" stroke-width="{1.8 if active else 1.2}"/>')
        o.append(f'<path d="M{cx-9} 84 L{cx} 76 L{cx+9} 84" stroke="{G if active else LINE}" stroke-width="{1.6 if active else 1.1}" fill="none"/>')
        if active:
            o.append(f'<circle cx="{cx}" cy="98" r="26" fill="none" stroke="{G}" stroke-width="1" opacity="0.7"/>')
    # Far Shores star-path
    o.append(f'<path d="M70 140 Q150 150 230 140" stroke="{LINE}" stroke-width="1" fill="none" stroke-dasharray="2 4"/>')
    for sx in (90,150,210):
        o.append(f'<circle cx="{sx}" cy="{144 if sx==150 else 142}" r="1.6" fill="{G}"/>')
    return "".join(o)

def branch():
    o=[]
    # a bound branch (curved) with binding wrap
    o.append(f'<path d="M80 120 C120 108 180 112 222 78" stroke="{G}" stroke-width="2.4" fill="none"/>')
    # growth rings (evidence days) as concentric arcs near base
    for R in (10,16,22):
        o.append(f'<path d="M{80} {120-R} A {R} {R} 0 0 1 {80+R} 120" stroke="{LINE}" stroke-width="1" fill="none"/>')
    # binding wrap
    for t in (0.42,0.5,0.58):
        bx=80+(222-80)*t; by=120+( -1)*( (t-0.1)*40 )
        o.append(f'<path d="M{bx-6} {by-4} q6 8 12 0" stroke="{G}" stroke-width="1.2" fill="none"/>')
    # bud (pending)
    o.append(f'<path d="M222 78 q-4 -10 6 -12 q4 8 -6 12 Z" fill="{GS}" stroke="{G}" stroke-width="1.1"/>')
    # leaf
    o.append(f'<path d="M150 110 q10 -14 24 -10 q-8 12 -24 10 Z" fill="none" stroke="{GRN}" stroke-width="1.1"/>')
    return "".join(o)

def piety():
    o=[]
    # deity mark (sun/akatosh-ish) left
    o.append(f'<circle cx="74" cy="86" r="20" fill="none" stroke="{G}" stroke-width="1.4"/>')
    for k in range(12):
        ang=k*math.pi/6; o.append(f'<path d="M{74+24*math.cos(ang):.1f} {86+24*math.sin(ang):.1f} L{74+30*math.cos(ang):.1f} {86+30*math.sin(ang):.1f}" stroke="{G}" stroke-width="1"/>')
    # piety meter
    o.append(f'<rect x="120" y="80" width="150" height="12" rx="6" fill="{DARK}" stroke="{LINE}"/>')
    o.append(f'<rect x="122" y="82" width="96" height="8" rx="4" fill="{G}"/>')
    # tier pips
    for i in range(3):
        on=i<2; o.append(f'<circle cx="{132+i*16}" cy="108" r="5" fill="{G if on else DARK}" stroke="{G if on else LINE}"/>')
    o.append(f'<text x="270" y="112" fill="{MUT}" font-size="10" font-family="sans-serif" text-anchor="end">Devoted · 72</text>')
    return "".join(o)

insts=[
 ("Khajiit","lunar","Lattice: steady · waxing",lunar(),G),
 ("Argonian","hist","Hist: strong · People high",hist(),GRN),
 ("Dunmer","ancestor","Ancestor layer: steady",ancestor(),G),
 ("Orc","forge","Stronghold",forge(),G),
 ("Redguard","sects","Forebear · Walkabout",sects(),G),
 ("Bosmer","branch","Old Contract · bound",branch(),G),
 ("Patron races","piety","Devoted · climbing",piety(),GRN),
]
cols=2; rows=(len(insts)+1)//2; pad=18
W=pad+cols*(CW+pad); H=pad+rows*(CH+pad)+40
p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{BG}"/>']
p.append(f'<text x="{W/2}" y="26" fill="{G}" font-size="16" font-family="Georgia,serif" text-anchor="middle">Prisma Devotional Instruments — all races (concept art)</text>')
for i,(race,kind,state,inner,tone) in enumerate(insts):
    cx=pad+(i%2)*(CW+pad); cy=40+(i//2)*(CH+pad)
    p.append(card(cx,cy,CW,CH,race,kind,state,inner,tone))
p.append("</svg>")
svg="".join(p)
cairosvg.svg2png(bytestring=svg.encode(), write_to="scratch/prisma-art/instruments.png", scale=2)
print("rendered instruments.png  %dx%d"%(W,H))
