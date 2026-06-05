from glyphlib import sheet
P={
 "jode":[("circle",{"cx":"24","cy":"24","r":"14"}),("path",{"d":"M24 10 A14 14 0 0 1 24 38","class":"thin"})],
 "jone":[("path",{"d":"M30 10 A14 14 0 1 0 30 38 A11 14 0 1 1 30 10 Z"})],
 "riddle-thar":[("path",{"d":"M16 16 A10 10 0 1 0 16 32 A8 10 0 1 1 16 16 Z"}),("path",{"d":"M32 16 A10 10 0 1 1 32 32 A8 10 0 1 0 32 16 Z"}),("path",{"d":"M19 24 H29","class":"thin"})],
 "khenarthi":[("path",{"d":"M24 12 C16 18 12 26 10 36 C18 30 22 28 24 28 C26 28 30 30 38 36 C36 26 32 18 24 12 Z"}),("path",{"d":"M24 12 V28","class":"thin"})],
 "alkosh":[("path",{"d":"M10 28 C12 16 22 12 24 12 C26 12 36 16 38 28"}),("path",{"d":"M14 24 L10 20 M34 24 L38 20"}),("circle",{"cx":"19","cy":"24","r":"1.6"}),("circle",{"cx":"29","cy":"24","r":"1.6"}),("path",{"d":"M16 32 Q24 38 32 32","class":"thin"}),("path",{"d":"M24 28 L21 33 H27 Z","class":"thin"})],
 "rajhin":[("path",{"d":"M18 16 L14 9 M30 16 L34 9"}),("path",{"d":"M16 18 C12 24 12 32 18 36 C22 39 26 39 30 36 C36 32 36 24 32 18 C28 14 20 14 16 18 Z"}),("circle",{"cx":"20","cy":"25","r":"1.5"}),("circle",{"cx":"28","cy":"25","r":"1.5"}),("path",{"d":"M22 31 Q24 33 26 31","class":"thin"})],
 "sithis":[("circle",{"cx":"24","cy":"24","r":"14","class":"thin"}),("path",{"d":"M24 12 C16 18 16 30 24 36 C30 31 30 17 24 12 Z"})],
 "sep":[("path",{"d":"M14 14 C26 12 30 20 24 24 C18 28 22 36 34 34"}),("path",{"d":"M14 14 L11 11 M14 14 L11 17","class":"thin"}),("circle",{"cx":"33","cy":"34","r":"1.4"})],
}
sheet(P,4,"batch2_khajiit_argonian.png","Batch 2 — Khajiit lunar pantheon + Argonian abstract")
print("ok",len(P))
