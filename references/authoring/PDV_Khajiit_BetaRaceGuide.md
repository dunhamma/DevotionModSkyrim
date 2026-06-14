# Devotion -- Khajiit Beta Race Guide (Tester Edition)

**What this is:** a play-it-and-watch guide for the Khajiit devotion experience. For each thing the
system does, it tells you **what to do in game -> what fires -> what you should see (and the Papyrus
log marker)**. It is the organic-play companion to the MCM-seeding runbooks
(`PDV_BetaTestPacket_Khajiit.md`, `PDV_Khajiit_BetaFeelPacket.md`) -- use those to force-seed states,
use this to understand and verify the natural experience.

**Status (2026-06-13):** all five focus paths, organic edge hooks, the lunar cycle, phase blessings,
and the curse-posture surface are wired. Final beta-feel sign-off is the in-game proof this guide
walks you through.

**Setup before testing**
- Character must be **Khajiit origin** (the system reads origin race, not current race form).
- MCM -> Devotion -> Player page -> enable **Developer Options**, set **Debug level 2** (turns
  on the log traces below; level 1 shows the major beats).
- Enable Papyrus logging; read `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- Quick machine check after a run: `node tools/pdv_phase20_runtime_check.mjs --race khajiit`.

---

## 1. How Khajiit devotion works

Khajiit devotion is **two layers at once**:

1. **The lunar substrate (always on).** Moon observance and the road-home cadence feed a broad
   "Lunar Lattice" standing that every Khajiit carries. This is the Riddle'Thar / ja-Kha'jay layer --
   it is never chosen; it is simply lived.
2. **A focused moon-path (emerges silently).** As your behavior favors one of the five moon-gods, that
   god quietly becomes your **focus**. There is **no menu, no offer, no commitment prompt** -- this is
   the LOCKED "silent emergence" design. You learn your focus by reading the Survey, not by being
   asked.

**The five moon-paths:** Khenarthi (wind, road, travel) - Azurah (twilight, threshold, fate) -
Baan Dar (the pariah; survival, reversal, clever theft) - Rajhin (the Purring Liar; elegant theft,
shadow) - Alkosh (dragon-order, time).

**Dual-route rule:** a focus-coded act raises **both** the lunar substrate **and** the focused god.
You should never see an act feed only one layer.

---

## 2. The Lunar Lattice cycle

The Lattice runs on the **real 24-day / 8-phase moon cycle** (it matches the moon you see in the sky).
Each phase **belongs to** one moon-god (always shown in the Survey, cosmetic by itself):

| Moon phase | Presiding god |
|---|---|
| Full moon | Alkosh |
| Waning gibbous | Azurah |
| Last quarter | Khenarthi |
| Waning crescent | Rajhin |
| New moon | Rajhin |
| Waxing crescent | Baan Dar |
| First quarter | Khenarthi |
| Waxing gibbous | Azurah |

**What the presiding god grants (only once that god is Faithful, tier 2):**
- **+10% piety gain** toward that god while it presides (script-side, always on).
- **One small phase blessing** -- a +5 / +5% stat ability that swaps in at dawn for the presiding
  god: Khenarthi/Baan Dar = Stamina regen, Azurah = Magicka regen, Rajhin = Sneak +5, Alkosh =
  Health +5. **Only one phase blessing is ever active at a time**, and only for a Faithful presiding
  god. It never requires you to schedule play around the moon -- it is amplification, not a chore.

**To test:** open Survey on different days and confirm the "This phase of the Lattice belongs to
\<god\>" line tracks the real moon. Reach Faithful with that god and confirm at the next dawn you gain
the small phase ability (check Active Effects) and the "+10% aligned" note in Survey.

---

## 3. What fires what -- per source

Format: **Do X -> fires -> see Z + `log marker`.** Markers assume Debug level 2.

### Lunar substrate (always-on layer)
- **Read a Khajiit lunar book** (Words of Clan Mother Ahnissi, Tale of Dro'Zira, etc.), or **sleep**
  (moon observance) -> substrate observance -> a quiet Prisma toast ("The moons marked this
  observance.") + substrate tier nudge -> `RouteKhajiitMoonObservance complete: 10`.
- **Return to a designated home anchor on a cadence** (road-home; cycle 2-3 anchors, do not farm one
  bed) -> road-home credit -> "The road home was remembered." toast -> `RouteKhajiitRoadHome...` /
  `RouteKhajiitRoadHomeAnchor complete: 33 anchor 1`.

### Khenarthi (road / travel)
- Travel the roads on foot, aid caravans, honor the wind -> Khenarthi focus weight + substrate ->
  standing rises in Survey under Khenarthi. (Khenarthi is the easiest, most reachable path by design.)

### Azurah (twilight / threshold / fate)
- Dawn/dusk observance under the moons; Azura's Star and threshold moments -> Azurah focus weight ->
  Azurah standing rises.

### Baan Dar -- the pariah (route 90)
- **Win badly outnumbered:** kill 3+ enemies in one fight while your health dips below 50% -> the
  outnumbered-win beat -> focus toward Baan Dar -> `Khajiit outnumbered win detected` +
  `RouteKhajiitBaanDarRoadTrick complete: 90`.
- **Near-fatal reversal (the rare marked beat):** drop below ~20% health and still win -> the marked
  reversal -> double-weight Baan Dar beat -> `Khajiit near-fatal reversal detected`. Weekly-capped.
- **At Champion, this is also your life-saver:** Baan Dar's T3 capstone, "Baan Dar's Luck," fires a
  **once-per-day avoid-death heal at 20% health** -- a killing blow is turned aside and you are pulled
  back from the edge. (This is the capstone proven in game; the daily save is on top of Armor +30 /
  Health regen +25% / Unarmed +10.)

### Rajhin -- the Purring Liar (route 91)
- **Elegant theft:** undetected pickpocket/steal from a **notable** target (jarl, court wizard, a
  named base on the curated list) **or** a single take worth **>= 200 gold**, while undetected ->
  the elegant-theft beat -> focus toward Rajhin -> `Khajiit Rajhin elegant theft detected` +
  `RouteKhajiitRajhinElegantTheft complete: 91`. Per-target 7-day cooldown.

### Alkosh -- dragon-order (routes 92 / 92b)
- **Kill a named dragon** (Mirmulnir and the other curated named dragons; Alduin and Paarthurnax
  excluded) -> the named-dragon beat (one-shot per dragon) -> `Khajiit Alkosh named-dragon beat
  routed` + `RouteKhajiitAlkoshDragonOrder complete: 92`.
- **Learn a word of power** -> at the **next dawn**, a small per-word enthusiasm drip toward Alkosh
  (max 3/dawn, remainder carried) -> `Alkosh word-of-power drip`.
- Generic (unnamed) dragon kills give only a small weekly nudge, no piety pulse. Aiding Paarthurnax
  reads as chaos-aid (negative to Alkosh).

---

## 4. Tiered rewards

Each focus god grants a 3-tier blessing as its piety crosses the thresholds (Seeker 25 / Devoted 50 /
Champion 85). The rewards are real records and resolve on the manager (verified by readback):
- **Khenarthi** -- Stamina/CarryWeight/Movement (the traveler's boons).
- **Azurah** -- Magicka regen / Magic resist (the twilight sight).
- **Rajhin** -- Sneak / Lockpicking / Pickpocket / Unarmed (the shadow's craft).
- **Alkosh** -- Fire & Magic resistance (the dragon's order).
- **Baan Dar** -- Armor / Health regen / Unarmed, **plus the daily avoid-death save at Champion**.

Plus the **phase blessing** (Section 2) layered on top while a Faithful god presides. By design the
ceiling is: lunar substrate + one focus emphasis + one phase blessing -- never a third loud stack.

---

## 5. Curse posture (the Lunar Lattice under strain)

Becoming a werewolf or vampire, or drifting into dominant shadow behavior, changes your **Lunar
posture** (shown in Survey and on transition). The curse damages *belonging*, not Khajiit identity --
both are recoverable.

| Posture | Trigger | What you see |
|---|---|---|
| **Normal** | default | "The Lunar Lattice holds you cleanly." |
| **Strained** | become a **werewolf** | MessageBox "A Competing Shape" (Hircine's gift, the caravans keep their distance); Survey reads "strained". Cure the lycanthropy -> "One Shape Again". |
| **Corrupted** | become a **vampire** | MessageBox "The Lattice Corrupted" (the thirst; the caravans fear you, but the moons do not disown the undead); Survey reads "corrupted". Cure -> "The Lattice Clears". |
| **ShadowDrift** | **dominant** shadow behavior (sustained night-only predation) | MessageBox "The Shadow Between Stars"; Survey reads the shadow-drift line. |

**How to test each:**
- **Strained / Corrupted:** become a werewolf or vampire in game. At the next dawn (or immediately on
  the curse transition), the onset MessageBox fires once and Survey shows the posture. Cure it and the
  cure MessageBox fires. Marker: `Khajiit lunar posture 0 -> 1` (etc.).
- **ShadowDrift (organic):** it is **deliberately hard to reach by accident** -- ordinary night
  travel, stealth, or moon observance must NOT trigger it. It needs sustained shadow-coded behavior:
  do **night-time** elegant thefts on 3 separate days within a 7-day window. Marker:
  `Khajiit shadow-evidence day recorded`, then `Khajiit lunar posture ... -> 3`.
- **ShadowDrift (fast, for proving the readout/message):** MCM -> Debug page -> **"Khajiit lunar
  posture"** button cycles Normal -> Strained -> Corrupted -> ShadowDrift -> Normal, firing each
  readout/message so you can confirm them without grinding.

---

## 6. Neglect

Go quiet -- stop observing the moons, stop the road-home cadence -- and standing gently regresses,
with neglect texture surfacing (substrate thinning, patron fading, caravans forgetting). This is a
slow drift, not a punishment spike. Anti-farm caps mean you cannot brute-force standing by spamming
one act; ritual/practice acts credit once per dawn cycle.

---

## 7. What should stay SILENT (rejection checks)

These must produce **no reward and no toast** -- they are how we know the system is discriminating,
not just rewarding everything:
- **Steamroll kills** (3+ kills at full health) -> NOT a Baan Dar beat.
- **Fleeing with no kill** -> nothing.
- **Petty / detected theft** (2-gold farmer loot, corpse looting, a detected attempt) -> NOT a Rajhin
  beat.
- **Generic dragon kills** -> only a small weekly nudge, no piety pulse; **Alduin** is excluded.
- **Repeated fast-travel** and **moon-sugar use** -> nothing (not devotion signals).
- **Wrong origin:** the same acts on a **non-Khajiit** character -> total silence.
- **Ordinary night travel / stealth / single thefts** -> must NOT push you into ShadowDrift.

---

## 8. Pacing expectations (so testers calibrate)

Piety is paced for a long arc: a daily gain cap (~4.3/day) and Champion at 85 means roughly
**30-45 days of normal play** (1-2 devotion acts/day) to Champion, or **~20 days** of dedicated play
at the cap. Do not expect Champion in a week -- if you are hitting the daily cap every day you are
playing harder than the intended pace. Seeker (25) and Devoted (50) come much sooner and are where
most of a beta playthrough lives.

---

## 9. Reading the Survey

MCM -> Player page -> **Survey Devotion** (or the per-path standing lines, since focus is silent).
The Survey tells you, in narrator voice: your overall Lattice standing, your moon-practice tier,
whether a lunar source has been read, whether the road-home cadence has weight, **which moon-path
walks nearest your road** (your emergent focus), **which god the current phase belongs to**, and --
when not Normal -- your **curse posture** readout. The per-path MCM lines show each god's tier,
piety, and "(leading)/(presiding)" markers.

---

## 10. MCM debug controls (Developer -> Debug page)

- **Khajiit moon observance** -- records one observance (substrate).
- **Khajiit road-home cadence** -- records one road-home event.
- **Khajiit focus -> Baan Dar / Rajhin / Alkosh** -- force the emergent focus so its tier reward
  becomes testable; then force piety and Run Dawn to light the Champion blessing.
- **Khajiit lunar posture** -- cycles the posture (Section 5) to surface every readout and curse
  message.
- Target-deity + Target-piety + Run-dawn controls -- seed any god to any tier and roll a dawn.

---

## 11. Evidence to bring back

- [ ] Substrate fires on book-read/sleep and on road-home (`RouteKhajiitMoonObservance complete: 10`,
      `RouteKhajiitRoadHomeAnchor complete: 33`).
- [ ] Each focus beat fires from natural play: Baan Dar outnumbered + near-fatal (90), Rajhin elegant
      theft (91), Alkosh named dragon + word drip (92/92b).
- [ ] A focus **emerges silently** from behavior (no offer/menu); Survey names it; the dawn after,
      its tier reward + (if Faithful) phase blessing appear in Active Effects.
- [ ] Baan Dar Champion avoid-death save fires once/day at 20% health.
- [ ] Posture: werewolf -> Strained + message; vampire -> Corrupted + message; cures fire; ShadowDrift
      reachable (organic 3-in-7 or MCM cycle) with its message + Survey line.
- [ ] Rejection sweep (Section 7) stays silent.
- [ ] `node tools/pdv_phase20_runtime_check.mjs --race khajiit` passes the route markers.
