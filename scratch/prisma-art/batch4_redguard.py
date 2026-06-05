from glyphlib import sheet
P={
 "satakal":[("path",{"d":"M24 10 A14 14 0 1 1 16 14"}),("path",{"d":"M16 14 L11 12 M16 14 L13 19","class":"thin"}),("path",{"d":"M24 10 A2 2 0 1 0 24 14 A2 2 0 1 0 24 10","class":"thin"})],
 "ruptga":[("circle",{"cx":"14","cy":"14","r":"1.8"}),("circle",{"cx":"34","cy":"12","r":"1.8"}),("circle",{"cx":"24","cy":"24","r":"1.8"}),("circle",{"cx":"16","cy":"34","r":"1.8"}),("circle",{"cx":"36","cy":"32","r":"1.8"}),("path",{"d":"M14 14 L24 24 L34 12 M24 24 L16 34 M24 24 L36 32","class":"thin"})],
 "tu-whacca":[("path",{"d":"M12 40 V20 A12 12 0 0 1 36 20 V40"}),("path",{"d":"M24 16 L26 21 L31 21 L27 24 L29 29 L24 26 L19 29 L21 24 L17 21 L22 21 Z","class":"thin"})],
 "tava":[("path",{"d":"M8 18 C16 26 20 26 24 22 C28 26 32 26 40 18 C34 28 28 32 24 40 C20 32 14 28 8 18 Z"}),("circle",{"cx":"24","cy":"21","r":"1.4"})],
 "leki":[("path",{"d":"M24 6 V34"}),("path",{"d":"M18 30 H30"}),("path",{"d":"M24 34 C20 38 28 40 24 44","class":"thin"}),("path",{"d":"M20 12 C28 12 28 18 24 18 C20 18 20 24 28 24","class":"thin"})],
 "onsi":[("path",{"d":"M14 40 C12 26 20 12 36 8 C34 12 34 14 36 16 C24 20 18 28 18 40 Z"}),("path",{"d":"M14 40 H22","class":"thin"})],
 "hoon-ding":[("path",{"d":"M12 12 L28 24 L12 36"}),("path",{"d":"M22 12 L38 24 L22 36"})],
}
if __name__=='__main__':
    sheet(P,4,"batch4_redguard.png","Batch 4 — Redguard / Yokudan")
    print("ok",len(P))
