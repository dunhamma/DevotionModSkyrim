# Player-State Bugs Found in the Nexus Guide Pass (2026-07-14)

Broken or stuck **player states** surfaced while turning the 10 race guides into shipping
copy. Written as a filing queue: each entry is one GitHub issue in
`dunhamma/DevotionModSkyrim`, label `needs-triage`.

**Every entry carries an explicit verification level. Do not treat them as equal.**

- **CONFIRMED** = I traced the callers in `live-source` myself this session.
- **REPORTED** = surfaced by the guide pass, plausible, **not yet reproduced**.

The REPORTED ones matter because the 2026-07-07 wired-vs-stub tags that drove this pass are
**stale and under-report wiring** - four "dead" lanes turned out live. Two claims in this
very pass were wrong on inspection (see "Checked and dismissed" at the bottom). Reproduce
before acting.

---

## 1. Altmer: the crisis never resolves, so the discipline blessing is permanently lost

**CONFIRMED. High severity. Hits effectively every Altmer who plays the main quest.**

`ResolveAltmerCrisis()` (`PDV__ManagerQuest.psc:9615`) is the only function that can return a
crisis to a coherent state - it sets `ALTMER_CRISIS_REASSERTING` (:9621) or
`ALTMER_CRISIS_SCARRED_RESOLVED` (:9623). **It has zero callers.**

The crisis is nevertheless set organically:

| Trigger | Site |
|---|---|
| **MQ104 stage 160 - Dragon Rising (being declared Dragonborn)** | `PDV_PlayerEvents.psc:1509` |
| MQ304 stage 200 | `PDV_PlayerEvents.psc:1513` |
| C03 stage 200 (Companions beast blood) | `PDV_PlayerEvents.psc:1517` |
| Reading one forbidden Lorkhan book | `PDV_PlayerEvents.psc:1383` routes pressure tier **4**; `PDV__ManagerQuest.psc:9432` opens a crisis at tier >= `MORTAL_VALIDATION` (3) |

And the blessing hangs off it: `IsAltmerDisciplineCoherent()` (:5147) returns true **only** for
`CRISIS_NONE` or `SCARRED_RESOLVED`; `SCARRED_RESOLVED` is settable only inside the dead
function. `SyncAltmerDisciplineSpell` (:5132) strips the spell when incoherent and toasts
"Coherence restored" when it comes back - **a toast that can never fire.**

**Net:** finish Dragon Rising as an Altmer, lose the discipline blessing forever, with no
in-game action that recovers it.

**Fix direction:** give `ResolveAltmerCrisis` an organic caller. Design intent (per the race
guide) was that reasserting orthodoxy after a crisis is itself the rewarded beat, so the
trigger likely belongs on the same P2 source / quest-stage layer that opens the crisis.

---

## 2. Redguard: ancestor-neglect is easy to fall into and hard to climb out of

**CONFIRMED mechanics, severity is a balance judgement. NOT the "unescapable" bug first reported.**

`IsRedguardAncestorNeglected()` (`PDV__ManagerQuest.psc:~15081`) trips when more than **5 game
days** pass since `PDV.Redguard.LastSectSignalTime`.

Two corrections to the original report, both important:

- It is **not** unescapable. Crown / Forebear / Ash'abah sect signals *do* have organic
  callers via the P2 source lists (`PDV_PlayerEvents.psc:1423/1426/1429`), and those lists are
  populated in the deployed ESP. The Ash'abah named-undead burden also stamps the clock
  (`PDV__ManagerQuest.psc:8493`, reached from `PDV_ActionRouter.psc:178`).
- It **cannot** strike a player who never engaged: the gate returns `False` when
  `lastSource <= 0.0`.

**The real concern:** every clock-resetter is *curated and rare* - a specific book, a specific
quest stage, or a named-undead kill - while the window is only 5 days. A Redguard who engages
once and then plays normally will likely sit in neglect most of the time, carrying a permanent
magic-resistance penalty. Decide whether the 5-day window or the resetter set is wrong.

---

## 3. Khajiit: all five Champion "signature moments" do not exist

**REPORTED - confirm against the records.**

The guide promised, and the records do not deliver: Khenarthi's wind that builds speed as you
travel uninterrupted; Azurah's foresight ward turning aside a spell; Baan Dar's once-a-day
survive-a-killing-blow; Rajhin's slip-into-shadow after a clean steal; Alkosh's staggering roar
against dragons. The Champion records appear to carry **stat effects only**.

Five capstone fantasies with nothing behind them. Cut from the guide pending a decision.

---

## 4. Nord: Shor's Champion last-stand save appears to be gone

**REPORTED - confirm against the record.**

The guide claimed "Sovngarde Looks Back" carried the Nord's single last-stand save. The shipped
Shor Champion record generates **stats only** (Max Health +30, One-Handed +18, Two-Handed +10).

Matches the known **"reward-author drops capstone save on converted MGEF"** pattern, so this is
plausibly a casualty of the Requiem regen conversion rather than a design cut. Worth checking
whether other capstone saves were dropped the same way.

---

## 5. Orc: a Stronghold Orc slides into neglect even while forging daily

**REPORTED - confirm.**

`HandleOrcStrongholdForge` is dev-only, **and it is the only forge path that stamps a life-mode
signal**. So the Stronghold Orc's entire theology - quality work at the forge - neither earns
piety nor holds off neglect. Ordinary smithing earns, but does not reset the neglect clock.

Wiring this one trigger fixes both the earn and the neglect framing at once. Highest-value Orc
target.

**Also on this record:** `PDV_SPEL_OrcHearthHeld` is double-dead - never granted
(`PDV__ManagerQuest.psc:420`, only ever synced `False`), *and* its effect is a `StaminaRateMult`
that the project-wide Requiem conversion missed, so it would do nothing even if granted.

---

## 6. Altmer: the Orthodox start has no organic way to defend its own track

**REPORTED - design/balance.**

Lorkhan pressure scales **1.5x for orthodox** vs 0.75x heterodox, but **every organic mover of
the alignment track is negative** (banned text -5, Daedric artifact -25, unprovoked Thalmor kill
-20). Nothing pushes it back up.

So the hardest start takes the most pressure and has no lane to hold the position it is being
punished for. The guide now frames this as deliberate asceticism, which reads well - but if it
was not intended, the Orthodox path is a trap.

---

## 7. Breton: two champion boons are identical

**REPORTED - likely copy-paste in authoring.**

`Akatosh's Endurance` and `Julianos's Insight` both ship as Fortify Magicka +40, Magic
Resistance +15%. Two different gods, same capstone.

---

## Checked and dismissed (do not re-file)

- **Redguard "permanently unescapable neglect"** - false, see #2. The sect lanes have organic
  P2 callers.
- **Argonian Void-Held near-death burst inert under Requiem** - false. The burst spell *is* a
  `StaminaRateMult`, but the manager already pairs it with a flat
  `RestoreActorValue("Stamina", 100.0)` (`PDV__ManagerQuest.psc:~6288`) for exactly that reason.
  Working as intended. Its spec `playerFacingText` ("Stamina returns 50% faster") is misleading
  though.
- **19 never-granted blessing records / no patron Seeker tier** - **intended**. (Citation
  corrected 2026-07-15: no AGENTS.md owner-confirmation entry exists; the actual authorities are
  `PDV_Architecture_v3.md` ADR-0005 -- "focused T1 records remain save-compatible artifacts but
  are never granted" -- and the enforcement comment in `PDV_DeityBase.psc:410`.) Retired-
  compatibility records kept so old saves do not break. A patron's blessing begins at Devoted by
  design. Do not "fix".

> **ADJUDICATED 2026-07-15:** every entry above now has a record-level verdict in
> `handoff/PDV_TierNameDrift_BugReport_2026-07-14.md` PART D (D1 rows 6-13). Notable
> reversals: #2 is NOT-A-BUG (a qualifying ancestral-rest sleep stamps the sect clock --
> a lane this report missed); #4 is REFUTED (the Shor save ships, ESP-verified); #3 is
> PARTLY refuted (Baan Dar's cheat-death ships; the other four are genuinely stat-only).
