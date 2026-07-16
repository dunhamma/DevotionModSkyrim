# PDV Handoff -- Felt-Family Remainder (2026-07-16)

26 rows left. Authority is `PDV_FeltFamilyEvidenceLedger.json` (the runbook
checklist is a snapshot). Everything below was read off live source/ESP this
session, not remembered.

---

## 0. Read this first -- the neglect mechanic is NOT one thing

This cost the most time tonight. There are **four** different neglect systems and
the debug button only covers one of them:

| Race | Mechanic | How to prime |
|---|---|---|
| Altmer, Redguard, Breton, Orc, Khajiit | SOURCE-TIMESTAMP lapse | **Curse none**, then `Prime race-lane neglect` (backdates the stamp, re-syncs immediately -- no dawn pass needed). Game clock must be past the grace window (Altmer 3 days, Redguard/Breton/Orc 5) or it cannot fire at all. |
| Nord (patron) | patron flag, piety <= 10 | `Prime neglect eligible` (the OTHER button) |
| Bosmer | patron flag on the PATH deity (Exchange->Z'en, BanditRoad->Baan Dar, else Y'ffre) | `Prime neglect eligible`; threshold is piety <= **10**, not 25 -- set Target piety 0 |
| **Argonian** | Hist posture must be SILENCED/CORRUPTED | **APPLY A VAMPIRE CURSE** (see below) |
| **Dunmer** | `PDV.Curse.Dunmer.Posture` == 1 or 2 | **APPLY A VAMPIRE OR WEREWOLF CURSE** |

**`Prime race-lane neglect` prints "not wired for this origin" for Argonian and
Dunmer -- that is correct, not a bug.** Their neglect is curse-driven, so they are
the INVERSE of every other race: Altmer/Orc/etc. need `Curse none`, Argonian/Dunmer
need a curse ACTIVE.

Source, so nobody re-derives it:
- `RefreshHistPosture` (`PDV_Substrate_ArgonianHist.psc:294`): posture reaches
  SILENCED only at `curseState == 2` (vampire); CORRUPTED = vampire + domination
  pressure. `IsArgonianHistNeglected` (manager 16359) requires SILENCED or CORRUPTED.
- `ApplyDunmerCurseHandlers` (manager 20269): vampire -> Posture 2 (Silent),
  werewolf -> Posture 1 (Strained), cured -> 3 (RestoredScarred), else 0.
  `IsDunmerAncestorNeglected` (15776) fires on Posture 1 or 2. The comment calls
  ash-prayer silence under vampirism "the signature consequence" -- this is intended
  theology, not a gap.

Curse proof flow (from the 2026-07-13 runbook entry): use a **throwaway proof save**.
`Debug: Daedric & Curse` -> select `Curse none` -> `Curse proof race` / `Apply proof
race` for the target origin -> then force the curse transition. `ApplyCurseRaceHandlers`
dispatches off `GetPlayerOriginRaceIndex()`, so the origin must be set through those
controls. Never continue unrelated testing from a rewritten-origin save.

---

## 1. Orc (3 left) -- HIGHEST RISK, test first

Two of these exercise code changed TODAY and never runtime-proven.

**`Orc-supportSpells|boon` + `OrcCodeHolds|boon` -- MOST IMPORTANT ROW IN THE SET.**
Code Holds was changed this session to fire MID-FIGHT off the below-health gate
(Baan Dar model) instead of on combat exit. Compiled 0/0 but **never run in game**.
- Requires a **full Skyrim relaunch** to load the recompiled manager.
- Malacath as active patron at Seeker (25) -> real fight -> drop below 20% HP and
  **hold it ~4+ seconds** (the alias polls every 4s; a shorter dip is never sampled)
  -> expect **+40 Health mid-fight, while still fighting**.
- Then Malacath at Devoted (50) -> repeat -> **+60 Health AND +30 Stamina**.
- ONLY tell is the HP bar. No Active Effect, no toast (display-honesty fix 2026-06-23).
- Log marker: `[PDV] Player below-health gate detected for origin 8` then
  `Orc Code Holds fired.` If the first line is absent, the poll never caught you low.
- If it does NOT fire mid-fight, the change regressed -- that is a real defect, file it.

**`Neglect-Orc|neglect`** -- Curse none + `Prime race-lane neglect`, read
"The Code Goes Unkept". Do NOT run a dawn pass while a debug-set life-mode is active
(see the life-mode gotcha in the runbook).

Also worth one look while there: the renamed boons (**Hold-Sworn - Stronghold**,
**Hearth-Sworn - City**, **Legion-Sworn - Legion Exile**, **Hold-Forged - Seeker/
Devoted**) should read correctly in Active Effects -- ESP-verified but not yet seen
in game.

---

## 2. Argonian (6 left) -- most rows, one hard gate

Argonian is a **no-offer** race: rewards gate on the substrate (Hist relations /
People focus / Void-active), NOT on an active patron. So do NOT go looking for a
patron override here.

Seed with `Argonian focus -> People` / `Argonian focus -> Void` (these call
`DebugSeedArgonian(hist, people, void)` under the hood).

| Row | Gate |
|---|---|
| `Argonian-Hist|boon` | broad Hist set on the substrate relation tier |
| `Argonian-People|boon` | People focus + tier ("Chosen People - Kin") |
| `Argonian-Sithis|boon` | Void ACTIVE + focus + tier ("Void Distance - Faced") |
| `Argonian-supportSpells|boon` | "Void-Held Surge" |
| `Argonian-Substrate|substrate-favor` | "Root Memory" |
| **`Neglect-ArgonianHist|neglect`** | **VAMPIRE curse** -> posture SILENCED, + no Hist maintenance (or lapse past grace). "The Hist Silenced" |

**MOST IMPORTANT:** `Neglect-ArgonianHist` (the vampire gate is non-obvious and
unproven) and `Argonian-Sithis|boon` (needs Void fully active -- `IsVoidFullyActive`
gates the near-death burst too).

Bonus if convenient: the Argonian Sithis near-death burst (Void path, drop <20% in
combat -> instant +100 Stamina, once/day) shares the same below-health gate the Orc
change touched -- a free regression check on that gate.

---

## 3. Dunmer (6 left) -- hybrid race

Ancestor substrate is always-on identity; Reclamation is an **active-patron offer**
lane (Azura/Boethiah/Mephala are the offer-eligible set, `IsDunmerOfferEligibleDeity`).
So the four boons DO need the patron override; the substrate does not.

| Row | Gate |
|---|---|
| `Dunmer-Azura|boon` / `Dunmer-Boethiah|boon` / `Dunmer-Mephala|boon` | active patron + tier (Seeker) |
| `Dunmer-Reclamation|boon` | "Reclamation Communion - Faithful" (broad) |
| `Dunmer-Substrate|substrate-favor` | "Dunmer Ancestor's Steadiness" |
| **`Neglect-Dunmer|neglect`** | **VAMPIRE or WEREWOLF curse** -> Posture 1/2. "The Ancestors' Silence" |

**MOST IMPORTANT:** `Neglect-Dunmer` (curse-driven, unproven) and
`Dunmer-Substrate` (the ancestor layer is the race's identity spine; note the
substrate goes **0x under vampirism / 0.5x under the beast** per
`GetDunmerCurseLayerWeight`, so prove the substrate BEFORE applying the curse for
the neglect row, or it will read as broken).

Ordering matters here: **substrate first (uncursed), neglect last (cursed).**

---

## 4. Bosmer (3 left) -- quickest sitting

Path-state gated; exactly one path family is active at a time, so cycle:
`Bosmer -> BanditRoad` / `-> Exchange` / `-> LivingStory`, seed the tier, read
Active Effects, move on.

- `Bosmer-BanditRoad|boon` ("Bandit Road - Seeker")
- `Bosmer-Exchange|boon` ("The Exchange - Seeker")
- `Bosmer-LivingStory|boon` ("Living Story - Seeker")

Bosmer neglect is already recorded -- do not redo it.

---

## 5. Shared price rows (8) -- stance-gated, read this before firing

`DebugFireDislike` refuses with `... is not reachable in the current origin/baseline.`
unless the deity's `Stance_<Race>` is **0 (NATIVE)**. `PDV_DeityBase` defaults every
stance to **1 (FOREIGN)**, so check the ESP before filing a defect. Patron status and
piety do NOT bypass the stance gate.

Also: a price row produces **no debuff** unless the loss exceeds
`DISFAVOR_LIGHT_MIN_DELTA` (0.5) AND `HasDisfavorStanding` passes (active patron OR
piety >= 25). Small dislikes are deliberately silent -- that is the V1 contract
("loss-surfacing bar"), not a gap. Durations: light = 2 in-game hours, sharp
(delta > 1.0) = 4 hours.

| Row | Origin to use | Event | Note |
|---|---|---|---|
| **`Trinimac|price`** | **Altmer (3), NOT Orc** | 368 | Stance_Orc=2 (TABOO), Stance_Altmer=0. Mis-assigned to the Orc sitting. Set Trinimac piety 25 first for standing -> -2.0 is > 1.0 so this ALSO fires the sharp War/Honor debuff (~4h): the one price row with a felt debuff. |
| `Sithis|price` / `TheHist|price` | Argonian (7) | raise-undead / murder-defenseless | |
| `Boethiah|price` / `Mephala|price` | Dunmer (5) | heal-or-cure-npc / kill-hostile-humanoid | |
| `BaanDar|price` / `Zen|price` | Bosmer (4) | murder-defenseless / steal-item (362) | |
| `Disfavor-VoidSecrets|disfavor-sting` | Dunmer (5) | cycle domain to VoidSecrets + apply domain sting | "Unease clings for a while." |

Fold each price into its race's sitting -- they need that origin anyway.

---

## 6. Suggested order

1. **Orc** (relaunch first) -- 3 rows, and it regression-checks today's code change.
2. **Bosmer** -- 3 boons + 2 prices, no curse work.
3. **Argonian** -- 5 rows uncursed, then vampire for neglect + 2 prices.
4. **Dunmer** -- substrate/boons uncursed FIRST, then curse for neglect, + 2 prices + sting.
5. **Trinimac|price** on Altmer -- 2 minutes, standalone.

That is 26 -> 0. Requiem Track B (`C-REQUIEM-TRACKB`, 4 sweeps, Authoria instance)
is untouched and is the other 1.0 blocker.

---

## 7. Landed this session (do not redo)

- Felt-family 49 -> 26 (Altmer 2, Khajiit 3, Breton 4, Orc 5, + parallel Redguard 8).
- Orc Malacath copy pass: 5 renames + 11 MGEF descriptions + hearth Declare now
  toast+BoD. ESP edited in place, verified; committed `28ca5731`.
- Code Holds -> mid-fight. **Runtime proof owed (section 1).**
- Hearth Declare toast/BoD needs a save where `PDV.Orc.HearthHeldDeclared` is still
  0 -- the flag is once-ever, so the current proof save will NOT re-fire it.

## 8. Known-open, deliberately not done

- Dislike debuffs for small prices (e.g. Malacath steal-item -0.25): would need CSV
  magnitude changes + a `LIKES_DISLIKES_VERSION` bump and contradicts the anti-farm
  doctrine. V2.
- Trinimac Thalmor-Orthodox Altmer lane: locked but deferred per
  `PDV_Architecture_v3.md:504` ("content-ready only when the Thalmor Orthodox Altmer
  lane is being built"). NOT in the EndStateContract's formal deferred list -- worth
  adding an `X-TRINIMAC-ORTHODOX` entry so the deferral is visible in the ship gate.
- `DebugSetOrcLifeMode` doesn't record evidence days or re-sync rewards -- a
  debug-ergonomics gap, not a shipping bug. Optional post-1.0 fix.
