from glyphlib import sheet
import math
def rays(cx,cy,r1,r2,n,cls=None):
    o=[]
    for k in range(n):
        a=k*2*math.pi/n
        d=f"M{cx+r1*math.cos(a):.1f} {cy+r1*math.sin(a):.1f} L{cx+r2*math.cos(a):.1f} {cy+r2*math.sin(a):.1f}"
        o.append(("path",{"d":d,**({"class":cls} if cls else {})}))
    return o
P={
 # --- Princes (lore-grounded) ---
 "molag-bal":[("path",{"d":"M24 40 V21"}),("circle",{"cx":"24","cy":"15","r":"6"}),
   *rays(24,15,6,9,8),("path",{"d":"M19 31 a5 5 0 1 0 10 0 a5 5 0 1 0 -10 0","class":"thin"})],   # spiked mace + chain link
  "mehrunes-dagon":[("path",{"d":"M24 6 C27 14 27 18 24 42 C21 18 21 14 24 6 Z"}),
   ("path",{"d":"M15 18 H33"}),
   ("path",{"d":"M16 18 L9 27 M32 18 L39 27"}),
   ("path",{"d":"M24 6 C27 14 27 18 24 42 C21 18 21 14 24 6 Z","class":"thin"})],
 "namira":[("circle",{"cx":"24","cy":"22","r":"11"}),  # the Ring
   ("path",{"d":"M24 33 C18 38 18 42 24 44 C30 42 30 38 24 33"}),  # hanging vermin body
   ("path",{"d":"M21 38 L17 40 M27 38 L31 40 M22 41 L19 44 M26 41 L29 44","class":"thin"}),  # legs
   ("circle",{"cx":"24","cy":"22","r":"4","class":"thin"})],
 "vaermina":[("path",{"d":"M16 22 C16 13 32 13 32 22 C32 27 30 30 28 32 V37 H20 V32 C18 30 16 27 16 22 Z"}),  # skull
   ("circle",{"cx":"20","cy":"23","r":"2.2"}),("circle",{"cx":"28","cy":"23","r":"2.2"}),
   ("path",{"d":"M24 27 L22 31 H26 Z","class":"thin"}),
   ("path",{"d":"M24 8 C28 8 28 12 24 12 C21 12 22 15 24 15","class":"thin"})],  # dream wisp
 "boethiah":[("path",{"d":"M24 42 V12"}),("path",{"d":"M20 16 L24 10 L28 16"}),  # blade
   ("path",{"d":"M24 38 C16 36 16 30 24 28 C32 26 32 20 24 18 C18 16 20 12 26 12","class":"thin"}),  # serpent
   ("circle",{"cx":"26","cy":"12","r":"1.3"})],
 # --- Khajiit ---
 "alkosh":[("path",{"d":"M10 30 C10 18 18 14 26 16 C30 12 36 12 40 14 C36 16 36 20 38 22 C40 28 34 34 26 32"}),  # dragon head
   ("circle",{"cx":"30","cy":"20","r":"1.5"}),("path",{"d":"M20 24 Q26 28 32 26","class":"thin"}),
   ("path",{"d":"M14 30 L11 34 M18 31 L16 36","class":"thin"})],  # jaw/whiskers
 "rajhin":[("path",{"d":"M24 30 C18 30 16 24 20 22 C18 18 22 16 24 19 C26 16 30 18 28 22 C32 24 30 30 24 30 Z"}),  # paw pad
   ("circle",{"cx":"16","cy":"18","r":"2.6"}),("circle",{"cx":"22","cy":"13","r":"2.6"}),
   ("circle",{"cx":"30","cy":"13","r":"2.6"}),("circle",{"cx":"34","cy":"18","r":"2.6"})],  # toe beans
 "khenarthi":[("path",{"d":"M10 30 C18 26 22 26 24 22 C26 26 30 26 38 30"}),  # wings
   ("path",{"d":"M24 22 V10"}),("path",{"d":"M21 14 L24 10 L27 14"}),  # ascending body
   ("path",{"d":"M14 36 Q24 32 34 36","class":"thin"})],  # wind
 "riddle-thar":[("path",{"d":"M18 14 A11 11 0 1 0 18 34 A8 11 0 1 1 18 14 Z"}),
   ("path",{"d":"M30 14 A11 11 0 1 1 30 34 A8 11 0 1 0 30 14 Z"}),
   ("path",{"d":"M22 24 Q24 20 26 24","class":"thin"})],  # dance arc
 # --- Nord ---
 "tsun":[("path",{"d":"M24 8 V40"}),  # haft
   ("path",{"d":"M24 12 C16 12 12 18 12 24 C18 24 22 20 24 16"}),  # axe bit L
   ("path",{"d":"M24 12 C32 12 36 18 36 24 C30 24 26 20 24 16"})],  # axe bit R (double axe)
 "stuhn":[("path",{"d":"M24 8 L37 13 V24 C37 32 31 38 24 41 C17 38 11 32 11 24 V13 Z"}),  # shield
   ("circle",{"cx":"21","cy":"22","r":"3","class":"thin"}),("path",{"d":"M23 24 L30 31 M27 31 H30 V28","class":"thin"})],  # key
 "trinimac":[("path",{"d":"M24 18 V42"}),("path",{"d":"M19 24 L24 18 L29 24"}),  # spear
   ("circle",{"cx":"24","cy":"12","r":"5"}),*rays(24,12,5,8,8,"thin")],  # sun-crown (champion of Auri-El)
 "shor":[("path",{"d":"M24 40 C8 28 11 14 18 12 C22 11 24 14 24 17 C24 14 26 11 30 12 C37 14 40 28 24 40 Z"}),
   ("path",{"d":"M18 22 L24 30 L30 22","class":"thin"})],  # heart + underking chevron
 # --- Redguard ---
 "leki":[("path",{"d":"M24 6 V40"}),("path",{"d":"M19 12 H29"}),  # sword
   ("path",{"d":"M14 22 C22 18 26 26 34 22","class":"thin"})],  # ephemeral feint
 "satakal":[("path",{"d":"M30 36 A14 14 0 1 1 33 18"}),  # body
   ("path",{"d":"M33 18 L30 13 L36 15 L34 21 Z"}),  # head biting
   ("circle",{"cx":"32","cy":"17","r":"0.9","class":"thin"})],
 # --- Concepts ---
 "ashabah":[("path",{"d":"M24 6 V30"}),("path",{"d":"M19 11 H29","class":"thin"}),("path",{"d":"M24 30 L21 36 H27 Z"}),  # downward sword
   ("path",{"d":"M12 20 C16 26 32 26 36 20 C34 30 14 30 12 20 Z","class":"thin"})],  # shroud drape
 "forebear":[("circle",{"cx":"24","cy":"20","r":"6"}),*rays(24,20,6,9,7,"thin"),  # sun
   ("path",{"d":"M8 34 C14 30 18 34 24 31 C30 34 34 30 40 34"})],  # wave (seafarers / first-landed)
 "broad":[("path",{"d":"M13 27 C15 36 21 39 24 39 C27 39 33 36 35 27"}),
   ("path",{"d":"M13 27 L10 22 M35 27 L38 22","class":"thin"}),
   ("circle",{"cx":"18","cy":"16","r":"1.7"}),("circle",{"cx":"24","cy":"13","r":"1.7"}),("circle",{"cx":"30","cy":"16","r":"1.7"}),
   ("path",{"d":"M18 19 V23 M24 16 V22 M30 19 V23","class":"thin"})],
 "curse-vampire":[("path",{"d":"M33 9 A15 15 0 1 0 33 39 A12 15 0 1 1 33 9 Z"}),  # crescent
   ("path",{"d":"M21 23 L23 29 L25 23 Z"}),("path",{"d":"M27 23 L29 29 L31 23 Z"}),  # fangs (solid triangles)
   ("circle",{"cx":"26","cy":"33","r":"1.4","class":"thin"})],  # blood drop
}
sheet(P,4,"batch6_refined.png","Refined — lore-grounded second pass")
print("ok",len(P))
