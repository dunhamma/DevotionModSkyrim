from glyphlib import sheet
P={
 "void":[("path",{"d":"M24 10 A14 14 0 1 1 18 11","class":"thin"}),("path",{"d":"M24 18 A6 6 0 1 1 20 19"}),("circle",{"cx":"24","cy":"24","r":"1.4"})],
 "stronghold":[("path",{"d":"M12 40 V20 H16 V16 H20 V20 H24 V16 H28 V20 H32 V16 H36 V40 Z"}),("path",{"d":"M20 40 V30 H28 V40","class":"thin"})],
 "crown":[("path",{"d":"M10 34 L14 16 L20 26 L24 12 L28 26 L34 16 L38 34 Z"}),("path",{"d":"M10 34 H38","class":"thin"}),("circle",{"cx":"24","cy":"12","r":"1.6"})],
 "forebear":[("path",{"d":"M10 34 C10 24 16 22 18 30 C18 18 30 18 30 30 C32 22 38 24 38 34 Z"}),("path",{"d":"M24 30 C20 24 28 22 24 16 C28 22 28 28 24 30 Z","class":"thin"})],
 "ashabah":[("path",{"d":"M24 8 V30"}),("path",{"d":"M19 14 H29","class":"thin"}),("path",{"d":"M14 26 C14 38 34 38 34 26 C30 32 18 32 14 26 Z"}),("path",{"d":"M24 30 V38","class":"thin"})],
 "concordat":[("path",{"d":"M14 10 C12 10 12 14 14 14 V34 C12 34 12 38 14 38 H34 C36 38 36 34 34 34 V14 C36 14 36 10 34 10 Z"}),("path",{"d":"M16 12 L34 36","class":"thin"}),("path",{"d":"M19 20 H29","class":"thin"})],
 "pact":[("path",{"d":"M18 16 C30 16 30 26 18 26 C12 26 12 34 24 34 C36 34 36 26 30 26"}),("path",{"d":"M18 16 C12 16 12 24 24 24","class":"thin"})],
 "stigma":[("circle",{"cx":"24","cy":"24","r":"13"}),("path",{"d":"M24 16 L20 26 H28 L24 34"}),("path",{"d":"M24 11 V14 M24 34 V37","class":"thin"})],
 "broad":[("circle",{"cx":"24","cy":"24","r":"5"})]+[("path",{"d":f"M{24+8*__import__('math').cos(k*3.1416/6):.1f} {24+8*__import__('math').sin(k*3.1416/6):.1f} L{24+13*__import__('math').cos(k*3.1416/6):.1f} {24+13*__import__('math').sin(k*3.1416/6):.1f}","class":"thin"}) for k in range(12)],
 "curse-vampire":[("path",{"d":"M32 10 A15 15 0 1 0 32 38 A12 15 0 1 1 32 10 Z"}),("path",{"d":"M20 24 L22 30 L24 24 M26 24 L28 29 L30 24","class":"thin"})],
}
sheet(P,4,"batch5_concept.png","Batch 5 — Tier-3 concept marks")
print("ok",len(P))
