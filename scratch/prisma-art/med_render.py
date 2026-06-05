from medallions import sheet, medallion, DEFS, MATS
import cairosvg

# ---------- 1. Anatomy / design-language sheet ----------
def anatomy():
    W,H=940,720
    p=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{DEFS}<rect width="{W}" height="{H}" fill="#0d0d0b"/>']
    p.append(f'<text x="40" y="46" fill="#d8b35a" font-size="24" font-family="Georgia,serif">Devotional Medallion - design language</text>')
    p.append(f'<text x="40" y="72" fill="#bcb3a2" font-size="13" font-family="sans-serif">A pendant amulet, ~40mm. Raised metal bezel, recessed field, the deity glyph embossed proud. Material and finish carry the pantheon.</text>')
    bx,by,R=210,300,118
    p.append(medallion(bx,by,R,"auri-el","gold"))
    calls=[("Beaded outer rim",bx+R*0.66,by-R*0.66,470,150),
           ("Raised bezel (polished metal)",bx+R-2,by-6,470,225),
           ("Recessed field (matte / patina)",bx+R*0.5,by+R*0.55,470,300),
           ("Embossed glyph (proud, catches light)",bx+6,by+8,470,375)]
    for label,x1,y1,x2,y2 in calls:
        p.append(f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2-8:.0f}" y2="{y2-4:.0f}" stroke="#6b6457" stroke-width="1"/>')
        p.append(f'<circle cx="{x1:.0f}" cy="{y1:.0f}" r="2.6" fill="#d8b35a"/>')
        p.append(f'<text x="{x2:.0f}" y="{y2:.0f}" fill="#f5f0e6" font-size="15" font-family="sans-serif">{label}</text>')
    p.append(f'<text x="40" y="500" fill="#d8b35a" font-size="17" font-family="Georgia,serif">Materials by pantheon</text>')
    p.append(f'<text x="40" y="522" fill="#bcb3a2" font-size="12" font-family="sans-serif">Same form, different metal/finish - the material tells the player which tradition the medallion belongs to.</text>')
    mats=[("gold","Divines"),("ebony","Daedric"),("silver","Khajiit"),("bronze","Yokudan"),("pearl","Altmer"),("iron","Nord"),("wood","Bosmer"),("jade","Argonian"),("neutral","Concept")]
    for i,(mk,lbl) in enumerate(mats):
        cx=95+i*92; cy=590
        p.append(medallion(cx,cy,30,"auri-el",mk))
        p.append(f'<text x="{cx}" y="{cy+52}" fill="#bcb3a2" font-size="11" font-family="sans-serif" text-anchor="middle">{lbl}</text>')
    p.append("</svg>")
    cairosvg.svg2png(bytestring="".join(p).encode(),write_to="med_anatomy.png",scale=2)
    print("wrote med_anatomy.png")

anatomy()

# ---------- 2. Divines ----------
sheet("Devotional Medallions — The Divines","Aedric / Imperial pantheon · gold, beaded rim",
 [("akatosh","Akatosh","gold"),("kyne","Kyne","gold"),("talos","Talos","gold"),
  ("arkay","Arkay","gold"),("mara","Mara","gold"),("dibella","Dibella","gold"),
  ("julianos","Julianos","gold"),("stendarr","Stendarr","gold"),("zenithar","Zenithar","gold")],3,"med_divines.png")

# ---------- 3. Daedric Princes ----------
sheet("Devotional Medallions — Daedric Princes","Sixteen Skyrim-present Princes · ebony, blood-touched glyph",
 [("azura","Azura","ebony"),("boethiah","Boethiah","ebony"),("mephala","Mephala","ebony"),("malacath","Malacath","ebony"),
  ("meridia","Meridia","ebony"),("hircine","Hircine","ebony"),("molag-bal","Molag Bal","ebony"),("nocturnal","Nocturnal","ebony"),
  ("hermaeus-mora","Hermaeus Mora","ebony"),("mehrunes-dagon","Mehrunes Dagon","ebony"),("sheogorath","Sheogorath","ebony"),("namira","Namira","ebony"),
  ("sanguine","Sanguine","ebony"),("clavicus-vile","Clavicus Vile","ebony"),("peryite","Peryite","ebony"),("vaermina","Vaermina","ebony")],4,"med_daedric.png")

# ---------- 4. Khajiit lunar ----------
sheet("Devotional Medallions — Khajiit Lunar","Lunar Lattice and Two-Moons pantheon · silver / moonstone",
 [("jode","Jode (Masser)","silver"),("jone","Jone (Secunda)","silver"),("riddle-thar","Riddle'Thar","silver"),
  ("khenarthi","Khenarthi","silver"),("alkosh","Alkosh","silver"),("rajhin","Rajhin","silver"),
  ("azura","Azurah","silver"),("baan-dar","Baan Dar","silver"),("lunar","Lunar Lattice","silver")],3,"med_khajiit.png")

# ---------- 5. Cultural pantheons (material differentiates) ----------
sheet("Devotional Medallions — Cultural Pantheons","Material carries the people: Yokudan bronze · Nord iron · Altmer pearl · Bosmer livewood",
 [("satakal","Satakal","bronze"),("ruptga","Ruptga","bronze"),("tu-whacca","Tu'whacca","bronze"),("tava","Tava","bronze"),
  ("leki","Leki","bronze"),("onsi","Onsi","bronze"),("hoon-ding","HoonDing","bronze"),
  ("shor","Shor","iron"),("tsun","Tsun","iron"),("stuhn","Stuhn","iron"),("magnus","Magnus","iron"),("trinimac","Trinimac","iron"),
  ("phynaster","Phynaster","pearl"),("syrabane","Syrabane","pearl"),("xarxes","Xarxes","pearl"),
  ("yffre","Y'ffre","wood"),("zen","Z'en","wood")],4,"med_cultural.png")

# ---------- 6. Argonian + concept/substrate ----------
sheet("Devotional Medallions — Hist and Concept Marks","Argonian bone-jade · substrate and state marks (material TBD with the mode)",
 [("hist","Hist","jade"),("sithis","Sithis","jade"),("sep","Sep","jade"),
  ("ancestor","Ancestor","neutral"),("malacath","Stronghold-Malacath","neutral"),("sect","Sword-Sect","neutral"),
  ("branch","Green Pact","neutral"),("stronghold","Stronghold","neutral"),("crown","Crown","neutral"),
  ("forebear","Forebear","neutral"),("ashabah","Ash'abah","neutral"),("concordat","Concordat","neutral"),
  ("pact","Pact","neutral"),("stigma","Stigma","neutral"),("broad","Broad worship","neutral"),
  ("void","Void","neutral"),("curse-vampire","Vampire curse","neutral")],4,"med_concept.png")
