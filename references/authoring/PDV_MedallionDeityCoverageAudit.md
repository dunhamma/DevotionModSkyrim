# Medallion Deity Coverage Audit — every god & Daedric Prince per race

**Date:** 2026-06-04
**Status:** AUDIT ONLY — no implementation. Captures the gap between the worship roster
each race *should* be able to choose (design authority) and what the runtime/menu layer
(the medallion / patron-selection surface) actually wires today.
**Scope question answered:** "Have we actually captured every deity for every race in the
medallion — the specifics of every god and Daedric Prince each race can choose to worship?"
**Short answer:** No. The *content* roster is complete in prose; the *selectable/scoring*
layer covers a subset, and no surface presents a race's full choosable roster.

---

## Method & sources

- **Design authority (what a race *can* choose):**
  - `references/phase4/PDV_StanceMatrix.csv` — 45 worship objects × 10 races, each NATIVE / FOREIGN / HOSTILE.
  - `references/phase4/PDV_DaedricRacePrinceMatrix.csv` — 16 Skyrim-present Princes × 10 races, stance keyword (Native / Legible / Tolerated / Curse / Foreign / Taboo / Hostile).
  - `references/authoring/PDV_DeityCoverageMatrix.json` — roster authority (45 locked worship objects + 16 Princes; required content-ready for every race).
- **Implementation reality (what the medallion actually wires):**
  - `scratch/p2-toast-panel-fix/PDV__ManagerQuest.psc` (live snapshot): named deity properties `PDV_Kyne`, `PDV_Talos`; `GetPrismaSymbolForDeity` recognizes 13 Aedric/cultural names; substrate/track properties for Dunmer / Khajiit / Argonian / Bosmer; `PDV_HircinePath` is the only wired Prince.

### Reading the columns
- **"Selectable scoring patron?"** — WIRED = the game recognizes this deity as a focused patron with a symbol (i.e. it can be the medallion's chosen god). MISSING = content exists in prose but there is no scoring/selection path.
- A race's **native gods** are its core medallion lane. **Foreign** gods are a drift/cleanse lane (not a normal medallion choice). **Hostile** is restricted.
- Princes: **native** = a normal medallion choice for that race; **conditional-access** (legible / tolerated / curse) = choosable with cost or arriving via a curse; the rest are taboo/hostile/foreign (not a normal choice).

---

## ⚠️ Certainty caveat

The definitive list of *registered* scoring deities lives in the ESP FormList
`PDV_FLST_AllDeities`, which is **not in this repo** (it ships in the live mod's plugin).
This audit's "WIRED" column is the **upper bound** derivable from code — the 13 names
`GetPrismaSymbolForDeity` maps. The true scoring set may be smaller: a parallel read
suggested only ~5 deities (Kyne, Talos, Y'ffre, Z'en, Baan Dar) are *fully* scored, with
the Nine Divines possibly handled as a single collective "broad worship" surface rather
than seven individually selectable patrons. **To close this audit, dump
`PDV_FLST_AllDeities` from the live plugin and reconcile against the WIRED column below.**

---

## High-level summary (native-god coverage)

| Race | Native gods | Wired | Native gaps | Native Princes | Princes wired |
|---|---|---|---|---|---|
| Imperial | 8 | 8 | — | 0 | n/a |
| Nord | 13 | 10 | Shor, Tsun, Stuhn | 0 | n/a |
| Breton | 12 | 10 | Magnus, Phynaster | 0 | n/a |
| Bosmer | 4 | 3 | Xarxes | 0 | n/a |
| Altmer | 9 | 4 | Magnus, Phynaster, Syrabane, Xarxes, Trinimac | 0 | n/a |
| Khajiit | 9 | 1 | Rajhin, Alkosh, Khenarthi, Riddle'Thar, Jone/Jode, +3 Reclamations | 1 (Azura) | 0 |
| Dunmer | 3 | 0 | Azura, Boethiah, Mephala (all Princes) | 3 | 0 |
| Redguard | 7 | 0 | Satakal, Ruptga, Tu'whacca, Tava, Leki, Onsi, HoonDing | 0 | n/a |
| Orc | 1 | 0 | Malacath | 1 | 0 |
| Argonian | 2 | 0 | Hist, Sithis | 0 | n/a |

**Daedric Princes overall:** 1 of 16 wired (**Hircine** only). The 15 unwired include every
race-native Prince — Dunmer's Azura/Boethiah/Mephala and Orc's Malacath.

**Two distinct causes of the gaps (do not conflate):**
1. **By design (not a true gap):** Dunmer, Khajiit, Argonian, Orc, Redguard, and the Bosmer
   fallback route devotion through a *substrate / quasi-patron* (House Ancestors, Lunar
   Lattice, The Hist, Malacath life-mode, Yokudan sect, Path track) rather than per-deity
   scoring. Their "0 wired native gods" is the substrate design, not an oversight — the
   roster authority asks for content-ready prose, which exists.
2. **Genuine wiring gaps:** deities the design *does* treat as focusable medallion patrons
   but that have no scoring/selection path — Altmer's Trinimac/Syrabane/Xarxes/Magnus/
   Phynaster, Nord's Shor/Tsun/Stuhn, Breton's Magnus/Phynaster, Bosmer's Xarxes, and the
   15 unwired Princes.

---

## Per-race ledger

### Nord

**Quasi-patron / substrate surface (wired today):** Broad Old Ways

**Native gods (13)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Kyne | WIRED |
| Kynareth | WIRED |
| Talos | WIRED |
| Shor | MISSING |
| Tsun | MISSING |
| Stuhn | MISSING |
| Mara | WIRED |
| Akatosh | WIRED |
| Arkay | WIRED |
| Stendarr | WIRED |
| Julianos | WIRED |
| Dibella | WIRED |
| Zenithar | WIRED |

_Native gaps: Shor, Tsun, Stuhn_

**Daedric Princes** — native: 0, conditional-access: 3, restricted (taboo/hostile/foreign): 13

_Conditional-access princes (choosable w/ cost or via curse): Meridia (Tolerated), Hircine (Curse), Molag Bal (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 25 · Hostile (restricted): 0_


### Imperial

**Quasi-patron / substrate surface (wired today):** Nine Divines (broad)

**Native gods (8)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Kynareth | WIRED |
| Mara | WIRED |
| Akatosh | WIRED |
| Arkay | WIRED |
| Stendarr | WIRED |
| Julianos | WIRED |
| Dibella | WIRED |
| Zenithar | WIRED |

_Native gaps: none_

**Daedric Princes** — native: 0, conditional-access: 3, restricted (taboo/hostile/foreign): 13

_Conditional-access princes (choosable w/ cost or via curse): Meridia (Tolerated), Hircine (Curse), Molag Bal (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 28 · Hostile (restricted): 0_


### Breton

**Quasi-patron / substrate surface (wired today):** Breton Tradition

**Native gods (12)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Kynareth | WIRED |
| Talos | WIRED |
| Mara | WIRED |
| Akatosh | WIRED |
| Arkay | WIRED |
| Stendarr | WIRED |
| Julianos | WIRED |
| Dibella | WIRED |
| Zenithar | WIRED |
| Magnus | MISSING |
| Phynaster | MISSING |
| Y'ffre | WIRED |

_Native gaps: Magnus, Phynaster_

**Daedric Princes** — native: 0, conditional-access: 9, restricted (taboo/hostile/foreign): 7

_Conditional-access princes (choosable w/ cost or via curse): Azura / Azurah (Legible), Mephala / Mafala (Legible), Meridia (Tolerated), Hircine (Legible), Molag Bal (Curse), Nocturnal (Legible), Hermaeus Mora (Legible), Namira / Namiira (Legible), Clavicus Vile (Legible)_

_Foreign-stance gods (drift/cleanse lane, not core): 29 · Hostile (restricted): 1_


### Dunmer

**Quasi-patron / substrate surface (wired today):** House Ancestors substrate

**Native gods (3)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Azura / Azurah | MISSING |
| Boethiah / Boethra | MISSING |
| Mephala / Mafala | MISSING |

_Native gaps: Azura / Azurah, Boethiah / Boethra, Mephala / Mafala_

**Daedric Princes** — native: 3, conditional-access: 0, restricted (taboo/hostile/foreign): 13

| Native Prince | Wired? |
|---|---|
| Azura / Azurah | MISSING |
| Boethiah / Boethra | MISSING |
| Mephala / Mafala | MISSING |

_Foreign-stance gods (drift/cleanse lane, not core): 38 · Hostile (restricted): 0_


### Altmer

**Quasi-patron / substrate surface (wired today):** Auri-El crisis-state

**Native gods (9)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Mara | WIRED |
| Stendarr | WIRED |
| Magnus | MISSING |
| Phynaster | MISSING |
| Y'ffre | WIRED |
| Auri-El | WIRED |
| Syrabane | MISSING |
| Xarxes | MISSING |
| Trinimac | MISSING |

_Native gaps: Magnus, Phynaster, Syrabane, Xarxes, Trinimac_

**Daedric Princes** — native: 0, conditional-access: 1, restricted (taboo/hostile/foreign): 15

_Conditional-access princes (choosable w/ cost or via curse): Molag Bal (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 25 · Hostile (restricted): 3_


### Khajiit

**Quasi-patron / substrate surface (wired today):** Lunar Lattice substrate + focus

**Native gods (9)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Azura / Azurah | MISSING |
| Boethiah / Boethra | MISSING |
| Mephala / Mafala | MISSING |
| Baan Dar | WIRED |
| Rajhin | MISSING |
| Alkosh | MISSING |
| Khenarthi | MISSING |
| Riddle'Thar / ja-Kha'jay | MISSING |
| Jone / Jode | MISSING |

_Native gaps: Azura / Azurah, Boethiah / Boethra, Mephala / Mafala, Rajhin, Alkosh, Khenarthi, Riddle'Thar / ja-Kha'jay, Jone / Jode_

**Daedric Princes** — native: 1, conditional-access: 7, restricted (taboo/hostile/foreign): 8

| Native Prince | Wired? |
|---|---|
| Azura / Azurah | MISSING |

_Conditional-access princes (choosable w/ cost or via curse): Boethiah / Boethra (Legible), Mephala / Mafala (Legible), Hircine (Curse), Molag Bal (Curse), Hermaeus Mora (Legible), Namira / Namiira (Legible), Sanguine / Sangiin (Legible)_

_Foreign-stance gods (drift/cleanse lane, not core): 32 · Hostile (restricted): 0_


### Bosmer

**Quasi-patron / substrate surface (wired today):** Path track

**Native gods (4)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Y'ffre | WIRED |
| Auri-El | WIRED |
| Xarxes | MISSING |
| Baan Dar | WIRED |

_Native gaps: Xarxes_

**Daedric Princes** — native: 0, conditional-access: 3, restricted (taboo/hostile/foreign): 13

_Conditional-access princes (choosable w/ cost or via curse): Hircine (Legible), Molag Bal (Curse), Nocturnal (Legible)_

_Foreign-stance gods (drift/cleanse lane, not core): 38 · Hostile (restricted): 0_


### Redguard

**Quasi-patron / substrate surface (wired today):** Yokudan sect

**Native gods (7)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Satakal | MISSING |
| Ruptga | MISSING |
| Tu'whacca | MISSING |
| Tava | MISSING |
| Leki | MISSING |
| Onsi | MISSING |
| HoonDing | MISSING |

_Native gaps: Satakal, Ruptga, Tu'whacca, Tava, Leki, Onsi, HoonDing_

**Daedric Princes** — native: 0, conditional-access: 2, restricted (taboo/hostile/foreign): 14

_Conditional-access princes (choosable w/ cost or via curse): Meridia (Tolerated), Hircine (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 32 · Hostile (restricted): 4_


### Orc

**Quasi-patron / substrate surface (wired today):** Malacath life-mode

**Native gods (1)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Malacath / Mauloch | MISSING |

_Native gaps: Malacath / Mauloch_

**Daedric Princes** — native: 1, conditional-access: 1, restricted (taboo/hostile/foreign): 14

| Native Prince | Wired? |
|---|---|
| Malacath / Mauloch | MISSING |

_Conditional-access princes (choosable w/ cost or via curse): Hircine (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 34 · Hostile (restricted): 2_


### Argonian

**Quasi-patron / substrate surface (wired today):** The Hist substrate

**Native gods (2)** — the core worship lane:

| God | Selectable scoring patron? |
|---|---|
| Hist | MISSING |
| Sithis | MISSING |

_Native gaps: Hist, Sithis_

**Daedric Princes** — native: 0, conditional-access: 2, restricted (taboo/hostile/foreign): 14

_Conditional-access princes (choosable w/ cost or via curse): Hircine (Curse), Molag Bal (Curse)_

_Foreign-stance gods (drift/cleanse lane, not core): 41 · Hostile (restricted): 0_


---

## Why no current surface shows a race's full choosable roster

None of the existing menus is a per-race deity/Prince browser:

| Surface | What it shows | Limitation for "choose your god" |
|---|---|---|
| MCM "Deity roster" | Iterates `PDV_FLST_AllDeities` (debug/status) | Only registered scoring deities; debug-only; not per-race; read-only |
| Startup race modal | Per-race **path/tradition** options | Only Breton/Bosmer/Redguard/Orc get choices; only Bosmer's are actual deities; 6 races info-only |
| Survey power / Prisma panel | The **active** patron or substrate, one at a time | Not a chooser; no roster view |

So there is no "medallion" UI today that enumerates, per race, the gods + Princes that race
may worship. The choosable set exists only implicitly in code (the FormList + startup branches)
and explicitly in the design matrices.

---

## Recommended next step (when implementation resumes)

1. **Settle the WIRED column for real** — dump `PDV_FLST_AllDeities` from the live plugin and
   mark each native god as fully-scored vs. broad-worship-only. This audit can't see the FormList.
2. **Decide the design intent per race** before building: which races are *meant* to have
   individually-selectable native gods (Nord, Imperial, Breton, Altmer, Bosmer) vs. substrate-only
   (Dunmer, Khajiit, Argonian, Orc, Redguard). The gaps in group 1 are the real backlog.
3. **Princes:** 15 of 16 unwired is the single largest gap; the native ones (Dunmer ×3, Orc ×1,
   Khajiit Azura) are the highest-salience to wire first — they double as those races' deepest lane.

_This document is an audit only. No code or menu was changed to produce it._
