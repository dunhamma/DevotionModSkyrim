from glyphlib import sheet
P={
 "shor":[("path",{"d":"M24 38 C8 28 10 14 18 12 C22 11 24 14 24 17 C24 14 26 11 30 12 C38 14 40 28 24 38 Z"}),("path",{"d":"M24 22 V30 M20 26 H28","class":"thin"})],
 "tsun":[("path",{"d":"M24 8 L38 14 V24 C38 32 32 38 24 41 C16 38 10 32 10 24 V14 Z"}),("path",{"d":"M16 16 L32 34 M32 16 L16 34","class":"thin"})],
 "stuhn":[("path",{"d":"M24 8 L38 14 V24 C38 32 32 38 24 41 C16 38 10 32 10 24 V14 Z"}),("circle",{"cx":"24","cy":"20","r":"4","class":"thin"}),("path",{"d":"M24 24 V32 M24 28 H29","class":"thin"})],
 "magnus":[("circle",{"cx":"24","cy":"22","r":"7"}),("path",{"d":"M24 6 V11 M24 33 V38 M8 22 H13 M35 22 H40 M13 11 L16 14 M35 11 L32 14"}),("path",{"d":"M18 40 L24 28 L30 40","class":"thin"})],
 "trinimac":[("path",{"d":"M24 8 L34 12 V22 C34 30 30 36 24 40 C18 36 14 30 14 22 V12 Z"}),("path",{"d":"M24 14 V32 M18 20 L24 14 L30 20","class":"thin"}),("path",{"d":"M19 26 H29","class":"thin"})],
 "phynaster":[("path",{"d":"M24 6 V42"}),("path",{"d":"M18 6 H30","class":"thin"}),("path",{"d":"M20 14 H28 M20 22 H28 M20 30 H28","class":"thin"}),("path",{"d":"M16 42 H32","class":"thin"})],
 "syrabane":[("circle",{"cx":"24","cy":"27","r":"11"}),("path",{"d":"M24 16 L20 8 H28 Z"}),("circle",{"cx":"24","cy":"27","r":"4","class":"thin"})],
 "xarxes":[("path",{"d":"M14 12 C12 12 12 16 14 16 H32 C30 16 30 12 32 12 C36 12 36 36 32 36 H14 C12 36 12 32 14 32"}),("path",{"d":"M30 10 L36 22","class":"thin"}),("path",{"d":"M18 22 H27 M18 27 H24","class":"thin"})],
}
sheet(P,4,"batch3_nord_altmer.png","Batch 3 — Nord/Imperial + Altmer")
print("ok",len(P))
