# PDV Build-Batch Smoke Test (2026-06-14)

In-game proof for the pure-script HIGH batch built this session (all in
`PDV__ManagerQuest.psc`, compiled 0/0). Everything below is MCM-driven (no `cqf`);
the only console is standard `set` / `coc`.

> **CORRECTION (2026-06-14):** `coc qasmoke` is fine as a clean test cell, but it shows
> only vanilla clutter -- PDV's `PDV_REFR_*Signal` proof objects are **invisible script
> activators**, so you can't see/click them there. Where tests #5/#6/#7 below say "activate
> PDV_REFR_X", instead fire it by RefID from anywhere: find the plugin prefix once via
> `help "OrcStrongholdForge" 0`, then `prid XX<refid>` + `activate`. The RefID table and the
> corrected trigger list live in `PDV_BuildBatch_Handoff_2026-06-14.md` (the authoritative
> resume point).

## Universal setup (do this for EVERY test)

1. **Start on a NEW save or `coc qasmoke` from the main menu.** The gate/curse
   changes only init on a fresh manager state -- old saves keep prior values.
   First disable `Devotion - Living Deities Test` in MO2 if present.
2. Set origin + debug:
   ```
   set PDV_GLO_OriginRace to <index>
   set PDV_GLO_DebugLevel to 2
   ```
   Origins: Nord=0, Imperial=1, Breton=2, Altmer=3, Bosmer=4, Dunmer=5,
   Khajiit=6, Argonian=7, Orc=8, Redguard=9.
3. MCM -> Devotion -> Player page -> enable **Developer Options**, open the
   **Debug page**. Controls used below: `Selected deity` (cycle), `Target piety`
   + `Apply target piety`, `Run dawn pass`, `Show piety map`, `Curse vampire` /
   `Curse werewolf` / `Curse none`, `Dunmer ancestor prayer`, `Seed commitment signals`.
4. Read the Papyrus log after each run:
   `Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` (debug 2
   prints the `[PDV]` traces called out below). Survey = MCM Player page **Survey
   Devotion**.
5. **(Tests 6/7 and ANY RefID activation) Read your plugin prefix ONCE.**
   PDV's signal objects are invisible, **nameless** activators, so
   `help "OrcStrongholdForge"` returns nothing (this list does not preserve
   EditorIDs). Read the prefix off a **named** PDV blessing instead:
   ```
   help "HoonDing" 0
   ```
   Find the `SPEL:` line, e.g. `SPEL: (B30711A0) 'HoonDing's Way - Seeker'`. The
   first two hex digits (`B3` in this example) are your prefix **XX** -- identical
   for every PDV record this session. Fire any signal with `prid XX<refid>` then
   **`activate player`** (NOT bare `activate` -- it needs the activating actor).

---

## TIER 1 -- easy, high-confidence (do these first)

### 1. Imperial vampire-rupture halt  (origin 1)
The Nine Divines path stops growing while undead; a one-way scar remains after cure.

- **State + label (primary):** Click **Curse vampire** -> Survey reads
  `civic faith halted`. Click **Curse none** -> Survey reads `civic faith scarred`
  (the one-way scar; it does NOT go back to blank). Click **Curse werewolf** ->
  `civic faith strained` (werewolf does not halt).
- **Accrual halt (deeper):** With a Divine selected, **Apply target piety** ~30,
  **Run dawn pass**, **Show piety map** -> note the value. Then **Curse vampire**,
  earn some civic piety (read the Talos book `player.additem 000ED04D 1`, read it),
  **Run dawn pass**, **Show piety map** -> that deity's piety should **not grow**
  while halted. **Curse none**, earn again, **Run dawn pass** -> growth resumes.
- **PASS:** label flips halted -> scarred on cure; no piety growth while halted.

### 2. Dunmer ancestor-layer silence  (origin 5)
Vampire silences the ash-prayer (Layer 1 = 0x) -- the signature consequence.

- Click **Dunmer ancestor prayer** 2-3 times -> Survey "Ancestor practice is ..."
  rises a tier; note it.
- Click **Curse vampire** -> Survey curse posture reads
  `silent, the ancestors cannot reach you`.
- Click **Dunmer ancestor prayer** again -> **nothing happens**: ancestor practice
  does NOT rise, and the log shows `Dunmer ancestor layer silenced by curse posture`.
  **This is the key check.**
- Click **Curse werewolf** -> posture `strained, the beast pulls at the ancestors`;
  the prayer now credits at half (the log still shows it routed).
- Click **Curse none** -> posture `restored, but scarred`; prayer credits fully again.
- **PASS:** prayer is silent under vampire (0x) + correct 4 posture labels.

### 3. Argonian ambient near-water Hist recovery  (origin 7)
Being in water maintains the Hist, once per in-game day.

- Go to water and **swim** (deep enough to actually swim): e.g. `coc Riverwood`,
  walk to the river, swim; or any lake/coast.
- Within ~1 second the log prints `Argonian near-water Hist maintenance routed`;
  Survey Hist practice nudges up; a "The water remembers you" toast may show.
- Swim more the **same day** -> no second fire (day-capped; log stays quiet).
- Sleep to advance a day, swim again -> it fires once more.
- **PASS:** swimming credits Hist once/day; no per-second spam.

### 4. Breton WitchcraftExposure decay  (origin 2)
Exposure is no longer a one-way ratchet -- it fades 1 per dawn.

- Read a Hidden Art book to raise exposure: `player.additem 000ED60B 1`, read it
  (Hagravens) -> Survey `Hidden Art: <band>` rises (exposure +25).
- Click **Run dawn pass** several times. Each dawn the log prints
  `Breton WitchcraftExposure passive decay -> N` and the Survey band steps back down
  (e.g. known -> suspected -> hidden).
- **PASS:** exposure decreases across dawns (was stuck climbing before).

### 5. Altmer Lorkhan adjacency penalty  (origin 3, in `coc qasmoke`)
Lorkhan-adjacent acts now cost real piety (was telemetry-only).

- Select **Auri-El**, **Apply target piety** ~50, **Run dawn pass**,
  **Show piety map** -> note Auri-El piety.
- Activate the QASmoke object `PDV_REFR_AltmerLorkhanPressureSignal` once. The log
  prints `Altmer Lorkhan penalty applied: -<n> to <deity>` (tier 3 source = -5).
- **Run dawn pass**, **Show piety map** -> Auri-El piety has **dropped**.
- **PASS:** the penalty log fires and piety actually decreases.

---

## TIER 2 -- gate confirmations (the "no single-signal flip" fixes)

### 6. Orc life-mode no longer flips on one act  (origin 8, `coc qasmoke`)
- Survey -> confirm life mode is **City** (the default).
- Activate `PDV_REFR_OrcStrongholdForgeSignal` **once**. Log shows the forge routed
  + evidence recorded, but Survey life mode **stays City** (old build flipped to
  Stronghold instantly). **PASS = no flip on a single signal.**
- (Optional full switch: sleep to a new in-game day -- the **auto-dawn fires on the day
  rollover** by itself -- then activate it again; the **2nd signal itself** switches the mode
  to Stronghold (two evidence days in seven). No manual **Run dawn pass** needed. Verified
  in-game 2026-06-14: signal #1 stays City, auto-dawn rolls the day, signal #2 flips to Stronghold.)

### 7. Redguard sect no longer flips on one act  (origin 9, `coc qasmoke`)
- Survey -> sect is **Forebear** (default).
- Activate `PDV_REFR_RedguardCrownTombRespectSignal` **once** -> sect **stays
  Forebear** (no flip). **PASS.** (Two Crown evidence days in seven would switch it.)

### 8. Nord non-Kyne commitment offers  (origin 0)
Any pantheon-baseline god can now be offered, not just Kyne.

- Pick a non-Kyne baseline god in `Selected deity` (Old Ways: Shor/Tsun/Stuhn/Talos;
  Nine Divines: Mara/Arkay/Akatosh/etc.). **Apply target piety** to **55** (above the
  50 offer threshold).
- Click **Seed commitment signals** (seeds the 2-day window for the selected deity),
  then **Run dawn pass**.
- **PASS:** a commitment offer fires for that non-Kyne god (previously impossible --
  only Kyne could offer).

---

## TIER 3 -- supporting / cross-cutting

### 9. Neglect vanilla notification (any race with an active patron)
- Commit to a patron, then drop its piety low (`Selected deity` -> it -> **Apply
  target piety** ~5) and **Run dawn pass** until it crosses into neglect.
- **PASS:** a top-left notice `<Deity>'s regard fades as your devotion goes quiet.`
  appears (before this fix, neglect was silent without the Prisma overlay).

### 10. Copy-fix spot checks (read-only, any relevant origin)
> **FOLDED INTO THE EDITORIAL PASS (user direction 2026-06-14).** Nord PASSED; the Bosmer /
> Dunmer / Argonian spot-checks are subsumed by the all-10-race Survey rewrite below -- no point
> verifying interim copy that's being rewritten wholesale. In-game evidence: the Bosmer Survey
> still renders `Your Bosmer path is OldContract. Current standing: Unproven. No Pact binding is
> active.` -- the raw enum leaks via `GetBosmerPathLabel()` (a SEPARATE string from the already-fixed
> path-SUGGESTION line), in flat status-readout voice. Same class across races.

Open **Survey Devotion** and confirm the wording reads cleanly:
- Bosmer (4): path line says `the Old Contract` / `the Living Story` / `the
  Exchange` / `the Bandit Road` (not the run-together `OldContract`).
- Nord (0): context line says `the Old Ways`, not `old road`.
- Dunmer (5): survey says `The Reclamations have answered a source you sought out.`
- Argonian (7) at Normal posture: opens `The Hist is near, as near as exile allows.`

---

## Post-testing editorial sweep (PLANNED -- do after this smoke test)

Per user direction (2026-06-14): a dedicated narrator-voice editorial pass, NOT done mid-test.
1. **Survey Devotion text, all 10 races** -- rewrite every `Get<Race>SurveyText()` in
   `PDV__ManagerQuest.psc` into consistent narrator voice (the way Khajiit's was fixed); kill
   status-token phrasing and any leaked counters/enum tokens. needsRecompile.
   - Confirmed offenders (2026-06-14 in-game): **enum leaks via label builders** -- `GetBosmerPathLabel()`
     returns `OldContract` (should read "the Old Contract"); same pattern in `GetOrcLifeModeLabel` /
     `GetBretonTraditionLabel` / etc. **Dev language** -- Orc opens "Malacath watches **the code**
     through City life". **Uniform readout voice** -- nearly every race appends "Current standing:
     <label>." So the pass must rewrite the survey sentences AND humanize the per-race label builders,
     not just the top-level strings. (Absorbs test-10 Bosmer/Dunmer/Argonian spot-checks.)
2. **Toasts** -- grammar + voice review of the `SendPrismaShiftToast` / `SendPrismaSubstrateProgress`
   strings and posture labels (Argonian specifically flagged), plus the fresh-Argonian
   "growing thin" first-maintenance posture quirk (init posture from the real relation).
3. **Commitment-offer copy parity (non-Kyne Nord gods)** -- test 8 opened formal commitment
   offers to every Nord pantheon-baseline god, but the offer copy + MCM strings are still
   Kyne-worded (`"Evaluate the Kyne commitment offer now?"`, `"first real ... Kyne commitment
   offer"`) and no bespoke per-god offer/accept text exists. Author commitment-offer write-ups
   for each eligible non-Kyne god so they reach Kyne parity: Old Ways = **Shor, Tsun, Stuhn**;
   Nine Divines = **Akatosh, Mara, Arkay, Stendarr, Zenithar, Dibella, Julianos, Kynareth**;
   plus **Talos** (always eligible). Degenericize the Kyne-worded MCM labels in the same pass.
   (Surfacing the offer in-world is the separate deferred D0 diegetic work; this item is text only.)

## What to report back
For each test: PASS / FAIL + the key log line (or the before/after piety-map
values). Anything that FAILs, paste the relevant `[PDV]` lines from Papyrus.0.log
and I'll fix it. Once these pass, I'll start the ESP-record pass (ThalmorAlignment
track, variety tranches, creed-loss spells, the cosmetic re-authors).
