import math, cairosvg
BG="#0d0d0b"; PANEL="#15140f"; LINE="rgba(224,204,158,0.40)"
GOLD="#d8b35a"; LIT="#ecdcab"; MUT="#8a8275"; DIM="#5f5a4e"; RED="#c97968"; GRN="#8bbf9f"
GLOW="rgba(216,179,90,0.33)"

def moon(cx,cy,r,phase,col,litcol,sw=1.3):
    f=(phase-1)/8; a=f*2*math.pi; lit=(1-math.cos(a))/2; rx=abs(r*math.cos(a))
    o=[f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#1b1a16" stroke="{col}" stroke-width="{sw}"/>']
    top=f"{cx},{cy-r}";bot=f"{cx},{cy+r}"
    if lit>0.985: o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{litcol}" stroke="{col}" stroke-width="{sw}"/>')
    elif lit>=0.015:
        outer=f"A {r} {r} 0 0 1 {bot}" if f<0.5 else f"A {r} {r} 0 0 0 {bot}"
        isw=(0 if lit<0.5 else 1) if f<0.5 else (1 if lit<0.5 else 0)
        o.append(f'<path d="M {top} {outer} A {rx} {r} 0 0 {isw} {top} Z" fill="{litcol}"/>')
        o.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{col}" stroke-width="{sw}"/>')
    return "".join(o)

def lunar(state):
    col={'quiet':DIM,'steady':GOLD,'strong':GOLD,'silenced':MUT}[state]
    litc={'quiet':MUT,'steady':LIT,'strong':LIT,'silenced':DIM}[state]
    o=[]
    if state=='strong': o.append(f'<circle cx="62" cy="70" r="30" fill="none" stroke="{GLOW}" stroke-width="6"/>')  # deepen glow
    o.append(moon(62,70,22,4,col,litc))
    # focus star
    cx,cy=140,66
    star=" ".join(f"{cx+R*math.cos(k*math.pi/4):.1f},{cy+R*math.sin(k*math.pi/4):.1f}" for k,R in [(i,(16 if i%2==0 else 6)) for i in range(8)])
    fill = GOLD if state=='strong' else 'none'
    o.append(f'<polygon points="{star}" fill="{fill}" stroke="{col}" stroke-width="1.1"/>')
    # phase strip
    litn={'quiet':1,'steady':4,'strong':6,'silenced':0}[state]
    for i in range(8):
        on=i<litn; o.append(f'<circle cx="{40+i*15}" cy="112" r="4.5" fill="{litc if on else "#1b1a16"}" stroke="{col if on else LINE}" stroke-width="1"/>')
    if state=='silenced': o.append(f'<path d="M24 30 L176 110" stroke="{MUT}" stroke-width="1.4" stroke-dasharray="3 4"/>')  # veil
    return "".join(o),col

def hist(state):
    col={'healthy':GOLD,'thin':MUT,'silenced':MUT}[state]
    o=[f'<path d="M100 116 V64" stroke="{col}" stroke-width="2.2" fill="none"/>']
    for dx in (-1,1): o.append(f'<path d="M100 116 C{100+dx*18} 118 {100+dx*32} 120 {100+dx*46} 116" stroke="{col}" stroke-width="1.2" fill="none"/>')
    arcs={'healthy':3,'thin':1,'silenced':2}[state]
    dash=' stroke-dasharray="3 4"' if state=='silenced' else ''
    for j,(R,sw) in enumerate([(40,1.6),(30,1.2),(20,1)]):
        if j<arcs: o.append(f'<path d="M{100-R} 64 A {R} {R} 0 0 1 {100+R} 64" stroke="{col}" stroke-width="{sw}" fill="none"{dash}/>')
    o.append(f'<circle cx="100" cy="54" r="2.6" fill="{col if state=="healthy" else "none"}" stroke="{col}"/>')
    if state=='silenced': o.append(f'<path d="M40 40 L160 110" stroke="{MUT}" stroke-width="1.4" stroke-dasharray="3 4"/>')
    return "".join(o),col

def ancestor(state):
    col=GOLD; o=[]
    if state=='deepen': o.append(f'<circle cx="100" cy="86" r="40" fill="none" stroke="{GLOW}" stroke-width="6"/>')
    o.append(f'<path d="M60 116 V70 A40 36 0 0 1 140 70 V116" stroke="{LINE}" stroke-width="1.2" fill="none"/>')
    litn={'base':2,'deepen':3}[state]
    for i,mx in enumerate((74,100,126)):
        on=i<litn
        o.append(f'<path d="M{mx-11} 82 Q{mx} 72 {mx+11} 82 Q{mx+9} 104 {mx} 110 Q{mx-9} 104 {mx-11} 82 Z" fill="{"rgba(216,179,90,0.18)" if on else "#1b1a16"}" stroke="{GOLD if on else MUT}" stroke-width="1.2"/>')
        o.append(f'<circle cx="{mx-4}" cy="89" r="1.4" fill="{GOLD if on else MUT}"/><circle cx="{mx+4}" cy="89" r="1.4" fill="{GOLD if on else MUT}"/>')
    return "".join(o),col

def card(x,y,title,state,fn,tone=None):
    inner,col=fn(state)
    w,h=190,150
    badge={'act':GRN}.get(state,None)
    return (f'<g transform="translate({x},{y})"><rect width="{w}" height="{h}" rx="9" fill="{PANEL}" stroke="{LINE}"/>'
      f'<text x="12" y="20" fill="{GOLD}" font-size="12" font-family="Georgia,serif">{title}</text>'
      f'<text x="{w-12}" y="20" fill="{tone or col}" font-size="10" font-family="sans-serif" text-anchor="end">{state}</text>'
      f'<g transform="translate(0,8)">{inner}</g></g>')

rows=[("Khajiit · lunar",lunar,["quiet","steady","strong","silenced"],{"strong":GRN,"silenced":RED}),
      ("Argonian · hist",hist,["healthy","thin","silenced"],{"thin":RED,"silenced":RED}),
      ("Dunmer · ancestor",ancestor,["base","deepen"],{"deepen":GRN})]
pad=16; cols=4; W=pad+cols*(190+pad); H=70+len(rows)*(150+pad)
p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" fill="{BG}"/>']
p.append(f'<text x="{W/2}" y="28" fill="{GOLD}" font-size="16" font-family="Georgia,serif" text-anchor="middle">Instrument state art — deepen / thin / silenced</text>')
p.append(f'<text x="{W/2}" y="48" fill="{MUT}" font-size="11" font-family="sans-serif" text-anchor="middle">strong/deepen = brighter + glow + extra lit · thin = muted, fewer elements · silenced (curse) = greyed + dashed veil</text>')
for r,(title,fn,states,tones) in enumerate(rows):
    for c,st in enumerate(states):
        p.append(card(pad+c*(190+pad), 64+r*(150+pad), title, st, fn, tones.get(st)))
p.append("</svg>")
cairosvg.svg2png(bytestring="".join(p).encode(), write_to="instrument_states.png", scale=2)
print("ok")
