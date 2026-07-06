# PDV Combined Last-Pass Sweep: Day-to-Day V1 + Prince V2 + C2 Prisma Spot-Checks

Single run sheet so the three remaining runtime sweeps can be done in one sitting.
Organized **by save** to minimize reloads. Source sweeps: runbook "Additional
last-pass runtime sweeps"; Mega Packet Blocks E1 / F; Prisma beats 3 / 5 / 7.

## What this closes (and what it does not)

- **Day-to-day V1:** the Imperial E1 vocabulary + origin-neutral mechanics already
  PASSED 2026-07-05 (AGENTS decisions log). This sheet is a **quick re-confirm on
  the current save** plus the genuinely-remaining bits, not a full Imperial redo.
- **Prince V2 path-deepening:** not yet run this cycle. Full sweep below.
- **C2 Prisma spot-checks:** beats 3 (Altmer band) / 5 (Khajiit Champion pin) / 7
  (Redguard sect toast). Manual **display** proof only; keep separate from the
  static `pdv_prisma_ui_audit`.

Proof boundary: this is **manual / runtime-route** proof. It does not stand in for
final-world placement or the Requiem felt sweep.

## Preflight (once, before loading any save)

- Gates should already be green; no code changed for this sweep. If you want a
  fresh baseline: `node .\tools\pdv_verify.mjs` (FAIL=0), and for Prince V2
  `node .\tools\pdv_daedric_beta_gate.mjs --json` (PASS=16).
- In every save: MCM -> Player -> **Developer Options ON**, then set **Debug level
  = 3** (Debug values slider). Level 3 is required to see anti-farm decay and the
  `[PDV]` markers in `Papyrus.0.log`.
- Keep `Papyrus.0.log` open (`Documents\My Games\Skyrim Special Edition\SKSE\`).
- Console-time gotcha: `set timescale` / time-jumps only advance game time while
  the console is **closed** (watch the sky race). Prefer the MCM **Run dawn pass**
  button over waiting for 06:00 where a step says "bank".

## Save matrix (minimum 4 saves)

| Save | Covers |
| --- | --- |
| **Nord** (origin 0, current) | Day-to-day re-confirm; Prince V2 deepen-not-initiate / open-path / Azura-as-PATH / Hircine curse coordination |
| **Khajiit** (origin 6) | C2 beat 5 Khajiit Champion pin; Azura-as-DEITY-face confirm (no PrinceV2 double-dip) |
| **Altmer** (origin 3) | C2 beat 3 Thalmor-alignment band |
| **Redguard** (origin 9, sect already chosen) | C2 beat 7 per-sect Champion toast |

---

# PART 1 - Day-to-day V1 (Nord save, ~10 min)

The vocabulary and mechanics are origin-neutral and already proven on Imperial;
this is a fast confirm they still behave on a different origin, plus the dawn/anti-farm
mechanics. Watch the Ledger (Prisma panel) driver rows and `Papyrus.0.log`.

### 1a. Faucet vocabulary (do the real acts)

| Act | How | Expect (Ledger driver row + piety to a native Nord god) |
| --- | --- | --- |
| Craft | smith / temper `330`, enchant `331`, brew `332`, cook `333` at a station | a driver row naming the act (e.g. "a thing forged"), small piety to a Nord-roster god |
| Knowledge | read skill book `340`, lore book `342`, Word Wall `343` | knowledge driver row + small piety |
| Sleep | sleep **outside** `313`, sleep **in a bed** `314` | devotional-sleep row + piety |

Pass: each act moves a **native Nord-roster** god; the driver row names the trigger,
not raw codes (per the driver-copy rule).

### 1b. Mechanics (origin-neutral - confirm once here)

- **Attribution filter:** land an environmental / indirect kill (trap, fall, let a
  friendly NPC kill). Log shows `skipped non-scoring attribution`; no piety.
- **Anti-farm cap (needs Debug level 3):** repeat one capped act several times in a
  day. It stops at its daily cap and the log shows `0.7^n` decay + `blocked by
  daily cap`. Pass: later repeats award less then nothing.
- **Dawn bank:** note a god's `PietyToday` scratch, then click MCM **Run dawn pass**.
  Scratch banks into standing (`PietyToday -> Piety`) and tier/standing updates.
- **Race gate (the real criterion):** this is NOT "some act scores 0". It is that
  the **original native god drops out on an origin flip**. If you flip origin
  (debug), the Nord-native god should stop scoring while the new origin's roster
  picks up. On a pure Nord save, just confirm off-roster/FOREIGN gods never score
  from generic acts.

STOP if: a generic act scores a non-native god (race-gate leak), or a driver/Survey
row shows raw route IDs instead of player wording.

---

# PART 2 - Prince V2 path-deepening

Marker to grep in `Papyrus.0.log`: `[PDV] PrinceV2: <Prince> event <id> deepen <x>`.
MCM Daedric debug lives on the Daedric page: **Selected Prince** (cycle), **Add
Prince signal**, **Show Prince summary**, **Reset Prince path**, **Force Seeker /
Force Devoted**.

### 2a. Nord save - deepen-not-initiate + open-path (use e.g. Namira)

1. **Reset Prince path** on the selected Prince (clean baseline; path NOT open).
2. Do a Prince-liked act while the path is still closed.
   - **Expect: NO `PrinceV2` marker, no path piety.** An uncommitted transgressive
     path must not deepen from an ambient act. (This is a hard STOP condition if it
     fires.)
3. Open the path: click **Add Prince signal** x3 (3 commitment signals).
4. Repeat the same liked act.
   - **Expect: the `PrinceV2 ... deepen` marker fires; `Show Prince summary` `p=`
     (path contract) rises.**
5. Anti-farm: repeat the act past its cap in one day -> deepen stops at the cap.

### 2b. Azura dual-face (proves no double-dip)

- **On the Nord save (origin 0, off-race):** open the Azura PATH and do an Azura act.
  **Expect: `PrinceV2` fires** (Azura is a Prince PATH for a non-native).
- **On the Khajiit save (origin 6; Dunmer origin 5 also works):** do the same Azura
  act. **Expect: Azura resolves as the DEITY face (an EventBus deity line, NOT a
  `PrinceV2` marker); the path stays inert - no double-dip.**

### 2c. Hircine curse coordination (Nord save)

Uses the Hircine block + **Curse werewolf** backend force.

1. **Hircine reset** (clean baseline).
2. Force curse to **Werewolf** (curse debug: "Curse werewolf" / backend force).
3. Open the Hircine path, then click **Hircine hunt rite** (or make a beast kill).
   - **Expect: Hircine deepens (boon/price/stigma contract advances) with NO
     double-fired curse transition** - one curse state change, not two.

After any Daedric change, rerun `node .\tools\pdv_daedric_runtime_check.mjs` and
`node .\tools\pdv_daedric_beta_gate.mjs --json` (must stay PASS=16).

---

# PART 3 - C2 Prisma spot-checks (display proof)

### 3a. Beat 3 - Altmer Thalmor-alignment band (Altmer save)

Call site `MaybeSurfaceAltmerAlignmentBandChange`; fires on a **committed** band
change, which **lags the raw value** by design (lock-in grace) - so push hard enough
to cross a committed boundary, not just nudge the raw.

1. Open the debug status page and watch **Committed state** (Phase 8 Concordat
   readout) - this is the Altmer alignment band mirror.
2. Click **Concordat defiance** (or **Concordat compliance**) repeatedly until the
   **Committed state** flips to a new band.
   - **Expect on the commit:** toast `The Thalmor question turns in you: <band>.`
     + a reorientation Book of Days chronicle
     `Where you stand in the Thalmor question shifts: <band>.`

Pass: the toast + chronicle fire on the **committed** flip (not on every raw nudge),
and the band name is a player label, not a number.

### 3b. Beat 5 - Khajiit Champion pinned entry survives pruning (Khajiit save)

1. **Khajiit focus ->** pick one (Baan Dar / Rajhin / Alkosh).
2. Cycle **Selected deity** to that focus god; **Reset selected deity** (so the
   Champion crossing is a real up-cross), then set **Target piety = 85** and
   **Apply target piety** -> Yes.
   - **Expect:** a Champion tier-reach toast + a **pinned** Book of Days entry for
     that god at Champion.
3. Now generate several ordinary entries (small acts / other gods) so the journal
   would normally prune, then open the Book of Days.
   - **Expect:** the Champion entry is still there (pinned/milestone entries persist;
     only ordinary entries prune).

### 3c. Beat 7 - Redguard per-sect Champion toast (Redguard save with a sect)

Call site `MaybeShowRedguardChampionEntry(sect)`. Requires a Redguard save that has
already chosen a sect (Crown / Forebear / Ash'abah) - there is no MCM sect override,
so use a save that is already in a sect.

1. Cycle **Selected deity** to the sect's focused patron; **Reset selected deity**,
   then **Target piety = 85** -> **Apply target piety** -> Yes (force the Champion
   up-cross).
   - **Expect:** the existing per-sect chronicle fires **and** a new Prisma toast,
     e.g.:
     - Crown: `The Crown way, made public.`
     - Forebear: `The Forebear way, made public.`
     - Ash'abah: `The Ash'abah duty, made public.`

Pass: both the chronicle and the toast surface on the Champion crossing.

---

# Stop conditions (abort, capture notes)

- A generic act scores a non-native god (race-gate leak).
- An UNcommitted transgressive Prince path deepens from an ambient act.
- A curse transition double-fires.
- Survey / status / driver rows show raw route IDs or counters instead of wording.
- Prisma opens as a BLOCKING panel where only a toast was expected.
- Any Book of Days line renders BLANK.

# After the run

Report per item PASS/FAIL back here. Results fold into the existing trackers
(`PDV_InGameTestingNeeded_Runbook.md`, `PDV_BetaFeelBurndown.md`, Mega Packet
Blocks E1/F, Prisma beats) - no new parallel handoff. Magnitude notes feed the
later scaling / anti-farm pass.
