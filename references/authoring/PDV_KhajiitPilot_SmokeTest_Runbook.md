# PDV Khajiit Pilot — In-Game Smoke Test Runbook

**Created:** 2026-06-06
**Purpose:** Confirm the Khajiit piety/reward/neglect pilot works at runtime after the
records were authored into `Devotion.esp`. This is the last gate before
propagating the template to the other 9 races.

## Record reference (housecarl-confirmed FormIDs, local to Devotion.esp)

| Thing | EditorID | Local FormID |
|---|---|---|
| Deity Azura/Azurah | PDV_Deity_Azura | 071078 |
| Deity Khenarthi | PDV_Deity_Khenarthi | 071079 |
| Deity Rajhin | PDV_Deity_Rajhin | 07107A |
| Deity Alkosh | PDV_Deity_Alkosh | 07107B |
| Azurah reward T1/T2/T3 | PDV_Bless_Khajiit_Azurah_T1/T2/T3 | 07108E / 071091 / 071094 |
| Khenarthi reward T1/T2/T3 | PDV_Bless_Khajiit_Khenarthi_T1/T2/T3 | 071085 / 071088 / 07108C |
| BaanDar reward T1/T2/T3 | PDV_Bless_Khajiit_BaanDar_T1/T2/T3 | 071096 / 071099 / 07109C |
| Rajhin reward T1/T2/T3 | PDV_Bless_Khajiit_Rajhin_T1/T2/T3 | 07109E / 0710A1 / 0710A5 |
| Alkosh reward T1/T2/T3 | PDV_Bless_Khajiit_Alkosh_T1/T2/T3 | 0710A7 / 0710AA / 0710AD |
| Substrate boon Always / Mid / High | PDV_Bless_Khajiit_Substrate_Always / Lunar_T1 / Substrate_High | 07107D / 07103F / 071081 |
| Lunar neglect | PDV_SPEL_Neglect_KhajiitLunar | (created this pass) |

> In the **console**, prefix the local FormID with your load-order index for the framework
> (e.g. `xx07108E`). Easiest is `help "Azurah's Twilight" 4` to find the runtime FormID, or use the
> MCM, which needs no FormIDs.

## Setup (once)

1. Launch with the Devotion mod active. From the **main menu** open the console and:
   ```
   coc qasmoke
   ```
   (Starting from a fresh path makes the Start-Game-Enabled deity quests — including the 4 new
   ones now in the SEQ — initialize. The SEQ fix is what makes the emphasis piety pulses work.)
2. In the console:
   ```
   set PDV_GLO_OriginRace to 6        ; force Khajiit origin
   set PDV_GLO_DebugLevel to 2        ; verbose Papyrus traces
   ```
3. Enable Papyrus logging (Skyrim.ini `[Papyrus] bEnableLogging=1 bEnableTrace=1`). Logs land in
   `Documents\My Games\Skyrim Special Edition\SKSE\Papyrus.0.log`. Grep it for `[PDV]`.
4. The 6 Khajiit proof activators are placed in the QASmoke cell (look for the proof markers):
   `PDV_REFR_KhajiitMoonObservanceSignal`, `RoadHomeAnchorOne/Two`, `BaanDarRoadTrick`,
   `RajhinElegantTheft`, `AlkoshDragonOrder`.

---

## Requirements & how to confirm each

### R1 — Double-route: each act raises BOTH the lunar substrate AND the emphasis deity's piety
**This is the core fix.** Before, acts fed only the substrate; now they also pulse patron piety.

Steps:
1. Activate `PDV_REFR_KhajiitMoonObservanceSignal`.
2. In the Papyrus log, confirm **both** of these appear:
   - `RouteKhajiitMoonObservance complete: 10` and a `SendPrismaSubstrateProgress`/lunar move (substrate side), **and**
   - `AwardPiety: Azurah raw 0.4 …` / `AwardCuratedSignal: Azurah …` (the NEW piety pulse).
3. Open MCM → Developer → **Show Piety Map**: confirm **Azurah has PietyToday > 0**.
4. Repeat for road-home (`RoadHomeAnchorOne`) → **Khenarthi** piety pulses; Baan Dar/Rajhin/Alkosh proof refs → their deities pulse.

**Pass:** every proof act moves the substrate *and* its emphasis deity's PietyToday.

### R2 — Anti-farm: same act same day diminishes; daily piety is capped
Steps:
1. Activate the same proof ref (e.g. moon observance) 3–4 times in one in-game day.
2. Log shows the substrate multiplier shrinking (`0.7ⁿ` via `ConsumeDailyRepeatMultiplier`).
3. Sleep/wait past 5 AM (or MCM → **Run Dawn**). In Show Piety Map, Azurah's *stored* Piety
   rose by **at most ≈4.3** for the day (`PIETY_DAILY_MAX_DELTA`), not more.

**Pass:** repeats give less each time; one day's stored gain never exceeds ~4.3 per deity.

### R3 — Focused emphasis emerges from behavior
Steps:
1. Activate one emphasis's proof ref a few times (each adds 25 focus weight; threshold 50, lead 15).
2. Watch for the **emphasis toast** ("… → Azurah") and confirm via MCM **Survey Devotion** text
   (shows "Focused: Azurah") or Show Piety Map.

**Pass:** exactly one emphasis emerges once its weight clears 50 with a 15 lead; balanced play stays unfocused.

### R4 — Tiered rewards granted (the payoff)
Fast path (don't grind 6 days):
1. Get an emphasis **focused** (R3) — say Azurah.
2. MCM → Developer → select the emphasis deity (Azura), **Apply Piety = 25** (Seeker).
   *(If the MCM deity selector doesn't reach the new index, instead activate the proof ref across
   several in-game days, or `set` Azura's piety via StorageUtil debug.)*
3. MCM → **Run Dawn** (consolidates + runs `SyncKhajiitEmphasisRewards`).
4. Confirm the reward is on the player: console `player.hasspell xx07108E` (Azurah T1) → `1`,
   or check **Active Effects** for "Azurah's Twilight". Magicka regen should read +4%.
5. Raise to **50** → Run Dawn → T2 (07108E + 071091) present, +7% / +5 magic resist.
6. Raise to **85** → Run Dawn → T3 (…094) present.
7. **Substrate boons:** as the lunar substrate tier rises (MID at metric 25, HIGH at 75), confirm
   `PDV_Bless_Khajiit_Substrate_Always/Lunar_T1/Substrate_High` appear (these are the broad lunar layer,
   independent of the focused emphasis).

**Pass:** the focused emphasis's T1/T2/T3 appear at Seeker/Devoted/Champion; substrate boons appear by lunar tier; **only one emphasis set is active at a time**, and broad-lunar substrate boons coexist (two boon families, no more).

### R5 — Neglect (gentle regression)
Steps:
1. After building lunar standing, stop activating any lunar source.
2. Advance **3+ in-game days** (sleep), running dawn each day (or MCM Run Dawn).
3. Confirm `PDV_SPEL_Neglect_KhajiitLunar` ("The Moons Withdrawn") is added — Active Effects shows
   a night-time stamina penalty; Survey text reflects the moons gone quiet.
4. Activate a lunar source again → on next dawn the neglect spell is removed.

**Pass:** neglect appears only after the grace window, is gentle (night stamina −5), and lifts on return.

### R6 — Creed-violation piety loss (medium/major only)
No proof activator exists for the anti-creed routes yet, so drive it via MCM:
1. MCM → Developer → select an emphasis deity (e.g. Baan Dar), **Apply Curated Signal** with that
   deity's negative signal (Baan Dar betrayal = 504; Azurah desecration = 703; Rajhin botched = 803;
   Alkosh chaos = 903; Khenarthi caravan-harm = 604).
2. Show Piety Map → that deity's PietyToday went **negative** (−2.0 to −3.0).

**Pass:** the creed-violation signal subtracts piety from the right deity; ordinary play does not.

### R7 — Negative checks (must NOT score)
- Set `PDV_GLO_OriginRace` to a non-Khajiit value → activating any proof ref scores **nothing**.
- Repeating one road-home anchor does not advance the circuit (log: "repeat anchor rejected").
- Generic crime/combat/dragon-kill spam does not satisfy Rajhin/Alkosh (those need the curated proof).

---

## Tooling cross-check (optional)

- Route markers: `node .\tools\pdv_phase20_runtime_check.mjs` after activations (checks route logs).
- Independent record readback any time (houseCARL): FLST `017E47` == 10; the 18 `PDV_Bless_Khajiit_*`
  spells resolve; deity quests `071078–07107B` present.

## Known caveat to watch

`PDV_Deity_BaanDar` (06FA1C) is currently **not Start-Game-Enabled** (separate flagged fix). Until
that's fixed, the **Baan Dar** emphasis piety pulse (R1 for Baan Dar) may not accrue even though
the other four emphases work. Test Azurah/Khenarthi/Rajhin/Alkosh first; treat Baan Dar as pending.
