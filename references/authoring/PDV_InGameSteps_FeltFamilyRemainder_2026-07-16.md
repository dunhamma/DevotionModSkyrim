# In-Game Steps -- Felt-Family Remainder (26 rows, 2026-07-16)

Every control name, origin index and event ID below was read off live source this
session. Nothing here needs looking up mid-sitting.

Record results into `PDV_FeltFamilyEvidenceLedger.json` (the authority).

---

## Preflight (every sitting)

1. Disposable/throwaway save. **Full Skyrim relaunch first** -- the manager was
   recompiled 2026-07-16 (mid-fight Code Holds) and a save-reload alone is not
   guaranteed to load it.
2. Console: `set PDV_GLO_DebugLevel to 2`
3. Console: `set PDV_GLO_OriginRace to <index>`
4. MCM -> Devotion -> Player -> **Developer Options** -> unlock the Debug pages.
5. **Debug: State & Rewards** -> confirm `Quest reaction queue` reads **idle**
   before any boon/reward step. A draining sweep races reward syncs.

Origin indices: `0` Nord · `1` Imperial · `2` Breton · `3` Altmer · `4` Bosmer ·
`5` Dunmer · `6` Khajiit · `7` Argonian · `8` Orc · `9` Redguard

Pages referenced: **Debug: State & Rewards** (deity/piety/dislike/neglect/race
focus) and **Debug: Daedric & Curse** (curse proof controls).

---

## A. Orc -- 3 rows. DO FIRST (regression-checks today's code change)

`set PDV_GLO_OriginRace to 8`

### A1+A2. `Orc-supportSpells|boon` and `OrcCodeHolds|boon`  -- HIGHEST RISK
The only rows exercising the mid-fight Code Holds change (commit `28ca5731`),
which compiled but has **never run in game**.

1. `Selected deity` -> **Malacath**
2. `Target piety` -> **25** -> `Apply target piety`
3. `Debug patron override`
4. Leave the MCM. Find a real fight (an enemy actively in combat with you).
5. Let health fall **below 20%** and **stay there ~4+ seconds** -- the alias polls
   every 4s; a shorter dip is never sampled and nothing fires.
6. **Expect: +40 Health while you are still fighting** (not on combat exit).
   The HP bar is the ONLY tell -- no Active Effect, no toast, by design.
7. Back to MCM: `Target piety` -> **50** -> `Apply target piety` (patron already set).
8. Repeat the fight. **Expect: +60 Health AND +30 Stamina**, mid-fight.

Log check after: `[PDV] Player below-health gate detected for origin 8` then
`Orc Code Holds fired.`
- Gate line missing -> the poll never caught you low; hold below 20% longer.
- Gate line present but no "fired" -> **real defect, file it** (the change regressed).

### A3. `Neglect-Orc|neglect`
1. **Debug: Daedric & Curse** -> `Curse none`
2. **Debug: State & Rewards** -> `Prime race-lane neglect`
3. Active Effects -> **"The Code Goes Unkept"**
- Do NOT `Run dawn pass` while a debug-set life-mode is active (dawn lapses it).
- Orc grace is 5 days: the game clock must be past in-game day ~5 or the prime
  cannot fire at all.

### A4 (free, while here). Confirm the renames
Active Effects should now read **Hold-Sworn - Stronghold**, **Hearth-Sworn - City**,
**Legion-Sworn - Legion Exile**, **Hold-Forged - Seeker/Devoted**. ESP-verified,
never seen in game.

---

## B. Bosmer -- 3 rows. Quickest sitting, no curse work

`set PDV_GLO_OriginRace to 4`

Path-state gated: exactly one path family is active at a time, so cycle.

### B1. `Bosmer-LivingStory|boon`
1. `Bosmer -> LivingStory`
2. `Selected deity` -> the Living Story scoring deity -> `Target piety` **25** ->
   `Apply target piety` -> `Debug patron override`
3. Active Effects -> **"Living Story - Seeker"**

### B2. `Bosmer-Exchange|boon`
1. `Bosmer -> Exchange` (Living Story effect should strip)
2. Same seed -> Active Effects -> **"The Exchange - Seeker"**

### B3. `Bosmer-BanditRoad|boon`
1. `Bosmer -> BanditRoad`
2. Same seed -> Active Effects -> **"Bandit Road - Seeker"**

### B4+B5. Prices, same origin -- fold in here
- `Zen|price`: `Selected deity` -> **Z'en**, `Target piety` **25**,
  `Apply target piety`; `Dislike event ID` -> **362** (steal-item, -0.75);
  `Fire dislike vs selected deity`
- `BaanDar|price`: `Selected deity` -> **Baan Dar**, `Target piety` **25**;
  `Dislike event ID` -> **304** (murder-defenseless, -0.75); fire.

Bosmer neglect is already recorded -- do not redo it.

---

## C. Argonian -- 6 rows (one likely N/A). NO-OFFER race

`set PDV_GLO_OriginRace to 7`

**Do NOT look for a patron override here.** Argonian rewards gate on the substrate
(Hist relations / People focus / Void-active), not an active patron.
`Argonian focus -> People` seeds (hist 90, people 90, void 0);
`Argonian focus -> Void` seeds (hist 90, people 0, void 90).

### C1. `Argonian-Hist|boon` -- STOP, PROBABLY NOT-APPLICABLE
`SyncArgonianRewards` (manager 16312-16314) hard-passes **False** for
`PDV_Bless_Argonian_Hist_T1/T2/Signature` with the comment *"Retired Hist Communion
boon family: the cultural-practice substrate now owns the universal identity boon,
while Hist remains a relation ledger."* **The family cannot grant, so there is no
felt effect to prove.** This is the same shape as `Breton-Tradition|boon`, already
marked `not-applicable` for exactly this reason.
**Recommendation: mark `not-applicable` with that citation rather than testing it.**
The identity boon it was replaced by is proven by `Argonian-Substrate` (C2).
Owner confirmation wanted before flipping the status.

### C2. `Argonian-Substrate|substrate-favor`
1. `Argonian focus -> People`
2. Active Effects -> **"Root Memory"**
(Prove this BEFORE any curse work in C6.)

### C3. `Argonian-People|boon`
1. `Argonian focus -> People` (seeds people 90 -> above T3 threshold)
2. Active Effects -> the People family, highest tier only (e.g. **"Chosen People - Kin"**)

### C4. `Argonian-Sithis|boon`
1. `Argonian focus -> Void` (seeds void 90 > people 0, so focus resolves to Void
   and `IsVoidFullyActive` gates open)
2. Active Effects -> the Sithis family, highest tier only (e.g. **"Void Distance - Faced"**)
- Only ONE of People/Sithis shows at a time -- that is the one-active cap, not a bug.

### C5. `Argonian-supportSpells|boon`
1. Still on Void focus -> Active Effects -> **"Void-Held Surge"**
- Bonus regression check (free): with Void active, drop below 20% HP in a real
  fight -> instant **+100 Stamina**, once/day. Same below-health gate the Orc change
  touched.

### C6. `Neglect-ArgonianHist|neglect` -- **NEEDS A VAMPIRE CURSE**
`Prime race-lane neglect` will print *"not wired for this origin"* -- that is correct.
Hist posture only reaches SILENCED at `curseState == 2` (**vampire**).
1. Do C2-C5 FIRST (the curse changes the substrate).
2. **Debug: Daedric & Curse** -> `Curse none` -> `Curse proof race` (cycle to
   **Argonian**) -> `Apply proof race`
3. -> **`Curse vampire`**
4. Active Effects -> **"The Hist Silenced"**
5. If it does not appear, run `Run dawn pass` once or twice -- the gate also wants
   no Hist maintenance inside the grace window.

---

## D. Dunmer -- 6 rows. HYBRID race, ORDER MATTERS

`set PDV_GLO_OriginRace to 5`

Ancestor substrate = always-on identity (no patron). Reclamation = active-patron
offer lane (Azura/Boethiah/Mephala only).

**Order is load-bearing: `GetDunmerCurseLayerWeight` makes vampirism ZERO the
ancestor substrate (0.5x under the beast). Prove D1 UNCURSED first, curse LAST.**

### D1. `Dunmer-Substrate|substrate-favor` -- DO THIS BEFORE ANY CURSE
1. `Dunmer ancestor prayer` (Race focus & state) -- click to raise the substrate
   metric; repeat if tier 0 (Dunmer is not metric-budgeted, unlike Khajiit)
2. `Dunmer home bonus` also feeds it
3. Active Effects -> **"Dunmer Ancestor's Steadiness"**

### D2. `Dunmer-Azura|boon`
1. `Selected deity` -> **Azura** -> `Target piety` **25** -> `Apply target piety`
2. `Debug patron override`
3. Active Effects -> **"Azura's Twilight - Seeker"**

### D3. `Dunmer-Boethiah|boon`
Same as D2 with **Boethiah** -> **"Boethiah's Struggle - Seeker"**
(previous patron's boon should strip -- one focused family at a time)

### D4. `Dunmer-Mephala|boon`
Same as D2 with **Mephala** -> **"Mephala's Web - Seeker"**

### D5. `Dunmer-Reclamation|boon`
Broad lane, NOT a patron:
1. `Clear patron override` (must be BROAD state)
2. `Seed broad lane (origin)` -- needs `PDV.Dunmer.ReclamationFocusCount >= 6`
3. Active Effects -> **"Reclamation Communion - Faithful"**

### D6+D7. Prices + sting, same origin
- `Boethiah|price`: `Selected deity` -> **Boethiah**, `Target piety` **25**,
  `Apply target piety`; `Dislike event ID` -> **350** (heal-or-cure-npc, -0.25); fire.
- `Mephala|price`: `Selected deity` -> **Mephala**, `Target piety` **25**;
  `Dislike event ID` -> **350** (heal-or-cure-npc, **-0.5** -- bigger surface than
  event `2` kill-hostile-humanoid at -0.25); fire.
- `Disfavor-VoidSecrets|disfavor-sting`: `Cycle disfavor domain` until it reads
  **7 VoidSecrets** -> `Cycle disfavor band` (sharp for a clearer read) ->
  `Apply domain sting` -> Active Effects -> **"Unease clings for a while."**

### D8. `Neglect-Dunmer|neglect` -- **NEEDS A CURSE. DO LAST.**
`Prime race-lane neglect` prints *"not wired"* -- correct. Posture 1/2 comes from
the curse.
1. **Debug: Daedric & Curse** -> `Curse none` -> `Curse proof race` (cycle to
   **Dunmer**) -> `Apply proof race`
2. -> **`Curse vampire`** (Posture 2 Silent) or **`Curse werewolf`** (Posture 1 Strained)
3. Active Effects -> **"The Ancestors' Silence"**
4. Expect the ancestor substrate from D1 to go quiet at the same time -- that is
   the intended signature consequence, not a regression.

---

## E. Argonian prices (fold into section C, origin 7)

- `Sithis|price`: `Selected deity` -> **Sithis**, `Target piety` **25**,
  `Apply target piety`; `Dislike event ID` -> **365** (raise-undead, -0.75); fire.
- `TheHist|price`: `Selected deity` -> **The Hist**, `Target piety` **25**;
  `Dislike event ID` -> **304** (murder-defenseless, **-1.0**); fire.

---

## F. `Trinimac|price` -- ALTMER ONLY, 2 minutes, standalone

**Must be origin 3 (Altmer), NOT Orc.** ESP readback: `Stance_Orc = 2` (TABOO),
`Stance_Altmer = 0` (NATIVE). An Orc gets
`DebugFireDislike: Trinimac is not reachable in the current origin/baseline.`
no matter how much piety/patron you give it -- the stance gate runs first.

1. `set PDV_GLO_OriginRace to 3`
2. `Selected deity` -> **Trinimac**
3. `Target piety` -> **25** -> `Apply target piety`
   (`HasDisfavorStanding` needs active patron OR piety >= 25, else the sting silently skips)
4. `Dislike event ID` -> **368** (accept-daedric-artifact, **-2.0**)
5. `Fire dislike vs selected deity`
6. Expect: piety **-2.0** + loss surface, **AND** a **sharp War/Honor debuff (~4 in-game
   hours)** in Active Effects -- -2.0 clears `DISFAVOR_SHARP_MIN_DELTA` (1.0) and
   Trinimac maps to the WAR_HONOR domain. **This is the only remaining price row that
   produces a felt debuff.**

---

## Price-row rules (read once, applies to all 8)

- **Bar is loss-surface only** (toast / Book of Days / panel Ledger row). No debuff is
  required. V1 contract; minor dislike consequences are V2.
- A debuff appears ONLY if loss > `DISFAVOR_LIGHT_MIN_DELTA` (0.5) **and**
  `HasDisfavorStanding` passes (active patron OR piety >= 25). Light = 2 in-game
  hours; sharp (loss > 1.0) = 4 hours. Max 3 domains active at once.
- **Always set `Target piety` 25 first** -- without standing the sting silently skips
  and you will think it is broken.
- `... is not reachable in the current origin/baseline.` = the deity's `Stance_<Race>`
  is not 0/NATIVE -> **wrong origin for that row**, not a defect. `PDV_DeityBase`
  defaults every stance to 1 (FOREIGN).

## Neglect quick-reference

| Race | Button | Precondition |
|---|---|---|
| Orc | `Prime race-lane neglect` | **Curse none**, clock past day ~5 |
| Argonian | (none -- prints "not wired") | **`Curse vampire`** |
| Dunmer | (none -- prints "not wired") | **`Curse vampire`** or **`Curse werewolf`** |
| Bosmer | `Prime neglect eligible` | piety <= **10** (already recorded) |
