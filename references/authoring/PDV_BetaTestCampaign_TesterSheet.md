# PDV Beta In-Game Test Campaign — Tester Sheet

**Purpose:** one runnable checklist for the in-game proof that unblocks beta (and
the 1F freeze). Sessions A–D are the critical path; E–G follow. Record evidence in
`PDV_Phase20_ManualEvidenceLedger.json` + `PDV_PreBetaRaceGateLedger.md`.

Testing is **MCM-debug-driven** (you don't use `cqf`). Standard `set`/`coc` are fine.

---

## 0. Setup (do once per session)

1. **Fresh save + full restart** for Session A and any startup/MESG/D1 check (those
   load at launch, not on reload). Likes/dislikes version-reload also needs a NEW save.
2. **Archive the Papyrus log** before each proof run so stale traces don't pass:
   `…\Documents\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log` → rename it.
3. In console: `set PDV_GLO_DebugLevel to 3` (full traces; 2 is enough for routes).
4. **Preflight gate (PowerShell, before launching):**
   ```powershell
   node .\tools\pdv_verify.mjs            # FAIL=0
   node .\tools\pdv_daedric_beta_gate.mjs # PASS=16
   ```

### MCM dev controls you'll use most (Status / Debug pages)
Unlock dev pages: set `PDV.UI.DeveloperOptions` to 1. Pages: **Player · Compatibility
· Status · Debug: State & Rewards · Debug: Daedric & Curse.**

| Need | Control (button label) |
|---|---|
| Seed a deity to a piety value | select **"Selected deity"** → set **"Target piety"** slider → **"Apply target piety"** |
| Seed today's scratch | **"Target scratch"** slider → **"Apply target scratch"** |
| Fire a curated signal | **"Curated signal ID"** slider → **"Apply curated signal"** |
| Force a dawn consolidation | **"Run dawn pass"** |
| See all piety values | **"Show piety map"** |
| Force a tier (Daedric) | **"Force Seeker/Devoted/Champion/lapse"** (Daedric page) |
| Set race state | **"Orc → City/Stronghold/Legion-Exile"**, **"Nord → Old Ways/Nine Divines"**, **"Breton → …"**, **"Khajiit focus → …"**, **"Argonian focus → …"**, **"Bosmer → …"** |
| Force curse | **"Curse none/werewolf/vampire"** |
| Re-detect origin | Compatibility page → **"Re-detect origin"** |
| Run neglect/decay | **"Run neglect pass"**, **"Prime decay eligible"** → **"Run decay pass"** |

### Console + log reference
- Origin race: `set PDV_GLO_OriginRace to <n>` — **0 Nord, 1 Imperial, 2 Breton, 3 Altmer, 4 Bosmer, 5 Dunmer, 6 Khajiit, 7 Argonian, 8 Orc, 9 Redguard**.
- HP proof: `player.getav Health` (read before/after a heal).
- Route proof (after activating): `node .\tools\pdv_phase20_runtime_check.mjs --race <name> [--track route|p2-books|all] [--strict-manager]`.
- Daedric: `node .\tools\pdv_daedric_runtime_check.mjs --prince all [--source qasmoke|mcm|organic]`.
- Primary value proof = **"Show piety map"** (MCM) + `getav` (HP); raw log grep `[PDV]` is secondary.
- **Gotchas:** `coc` skips OnStoryChangeLocation (walk in via a load door for Bosmer Songs / Argonian Waters / Orc stronghold-arrival); `setstage` no-ops unless the quest is running (use the MCM/QASmoke route for Daedric instead); for a physical signal ref, `help "HoonDing" 0` gives the 2-hex plugin prefix.

---

## Session A — Framework floor (race-agnostic; full restart, fresh save)

| # | Step | Pass |
|---|---|---|
| A1 | New game, any race → reach a point with menus | game stable |
| A2 | Open MCM → **Player page** | Summary/Startup/Mode/Patron/Standing/Curse/Favor/Neglect all show real text — **never "Devotion is still starting up"** (1A self-heal). With DebugLevel≥1, log shows `Manager rebound (player_page)` if it had to heal |
| A3 | Save → reload that save → reopen MCM | Player page still healthy (no "starting up") |
| A4 | **Startup choice flow** for each choice race (Breton/Redguard/Orc/Bosmer): new game → pick each path → confirm the **button you pick maps to the path you get** (Orc was once inverted; Bosmer is the latent one to watch) | path applied == button chosen |
| A5 | **Custom-race / Ohmes (1H):** new game as Ohmes-Raht (HalfKhajiit.esp) | origin resolves to **Khajiit**, NOT Imperial; **no tier-up toast at creation** (RecomputeTier(deity,False) fix) |
| A6 | **Stuck-save recovery (1H):** on a save cached as Imperial-fallback → reload OR Compatibility → **"Re-detect origin"** | self-heals to Khajiit; unsupported race stays Imperial with the single notice, **no per-load re-spam** |
| A7 | **New-save likes/dislikes reload:** new game → do a couple curated acts → **"Show piety map"** | expanded rows live (day-to-day piety moves); version bump took effect |
| A8 | **D1 cue smoke:** trigger a tier-up (seed near a threshold → act) | the diegetic transition cue fires (visual/sound) |

---

## Session B — Faucet + anti-farm (one Imperial-origin char, DebugLevel 3)

Validates the day-to-day vocabulary, race-gating, and the **1C anti-farm caps**.

| # | Step | Pass |
|---|---|---|
| B1 | `set PDV_GLO_OriginRace to 1`; do representative acts: combat-by-victim, craft, knowledge/read, devotional sleep, a transgression | each fires its EventBus award; **"Show piety map"** moves by the CSV delta |
| B2 | **Race-gate negative:** as Imperial, do an act that should only feed a non-native god | that god scores **0** (no leak) |
| B3 | **1C anti-farm:** repeat the SAME act several times in one day (e.g. ancestor prayer, moon observance, civic service) | the piety pulse **diminishes** (0.7ⁿ) per repeat — not full each time. Confirm via "Show piety map" deltas shrinking |
| B4 | **Penalty still bites full:** repeat an anti-creed/penalty act (oath-break, deviation) | penalty applies **full** each time (NOT decayed) |
| B5 | **Dawn bank:** seed scratch, **"Run dawn pass"** | day's gain consolidates, clamped at/under **4.3** per deity |

---

## Session C — Requiem HP-bar sweep (separate Requiem load order; disposable saves)

The load-bearing proof + the magnitude tune. **Record tuned magnitudes** — this run sets them.

**Method per heal:** seed the deity to the tier (Apply target piety), `player.getav Health`,
trigger the heal, `player.getav Health` again → confirm the bar moved; note the felt value.

| # | Reward | Trigger | Pass / record |
|---|---|---|---|
| A1–A6 | Argonian/Khajiit-BaanDar/Bosmer/Breton/Orc-Malacath/Imperial Fortify-Health | seed tier via MCM | **max Health rises**; note value per tier |
| A7 | Imperial Mara sleep-mercy | Devoted+, sleep in a bed | HP restores once/day (25/40); 2nd sleep silent |
| A8 | Dunmer home-prayer | declare home (sleep) → pray at home | HP pulse at home (15/30); **not** elsewhere; once/day |
| A9 | Orc Code Holds | drop to near-death in combat | flat HP restore (40/60) |
| B1a | Redguard Tu'whacca death-rite | death-duty/Ash'abah act | HP restores (30/50) once/day |
| B1b | Namira heal-on-feed | Namira path ≥Seeker, feed | HP+Stamina pulse, tier-scaled; past cap silent |
| B2a–f | HoonDing make-way | kill a dragon | make-way fires once; 2nd same-day soft-decays; generic bandit rejected; **Champion <20% HP → AvoidDeath save once/day**; road-passage routes to Forebear NOT HoonDing |

After tuning: hand me the felt values → I write them back into the specs + the 1B penalty conversion in the same pass.

---

## Session D — Per-race feel runbooks (×10, ledger order; one save per race)

7-slot template per race (record each in the gate ledger):

1. **Asset** — no missing meshes/sounds.
2. **Survey/status** — open MCM, read the race's Survey; fiction-voiced, no route IDs/raw counters.
3. **Stack snapshot** — expected build + edge build: list Active Effects + MCM readout; no >2 loud always-on boons.
4. **Immersive hook** — the authored hooks fire outside QASmoke (use the race's MCM signal buttons or organic acts; run `pdv_phase20_runtime_check.mjs --race <name>`).
5. **Wrong-origin rejection** — `set PDV_GLO_OriginRace` to another race → confirm native state can't be read.
6. **Generic rejection** — spot-check a generic act stays silent.
7. **Feel note** — did it feel authored? loop too quiet/noisy?

Per-race expected build / edge build / accepted source are in `PDV_BetaFeelReleaseGate.md`
(Race Proof Targets table). Dunmer/Imperial: run after their routing is confirmed; Orc:
includes the life-mode promotion gate (≥1 Stronghold + ≥1 City/Legion beat outside QASmoke).

---

## Session E — Nord change testing

New Nord save, full restart. **"Nord → Old Ways"** vs **"Nord → Nine Divines"** (MCM):
confirm the new two-button startup gate, non-Kyne commitment offers fire, broad-worship
setup; plus over-trigger audit, generic rejection, immersive hook, expected/edge stack snapshot.

---

## Session F — Daedric full proof (16 Princes)

Use the existing `PDV_DaedricInGameSmokePacket.md` + the **Debug: Daedric & Curse** MCM page:
**"Route all Princes"** (route markers), per-Prince **"Force Champion"** → check Active Effects +
**"Show Prince summary"**, **"Generic silence probe"** (must stay silent), save/load, stack legibility.
Molag Bal + Hircine: curse-no-double-fire. Then `node .\tools\pdv_daedric_runtime_check.mjs --prince all`.
V2 deepen-not-initiate: uncommitted transgressive path must NOT deepen from ambient acts.

---

## Session G — Experience Mode (AFTER Phase 4 / 1F lands)

MCM Experience Mode page: toggle Wayfarer ↔ Pilgrim; confirm round-trip, 1.25× gain on a known
signal, 1.5× dawn cap, mid-save flip changes nothing stored, default-Pilgrim on existing saves.

---

## New-fix verification quick-list (fold into the sessions above)

- **1A self-heal:** A2/A3 — Player page never shows "still starting up".
- **1H origin:** A5/A6 — Ohmes→Khajiit, no creation tier-toast, stuck-save recovers, no re-spam.
- **1C anti-farm:** B3/B4 — repeats decay; penalties don't.
- **Requiem conversion:** Session C — every heal moves the HP bar; Nord Shor + HoonDing/Champion AvoidDeath saves fire.

## What unblocks the 1F freeze
Complete **B + C + D** and hand me the Session-C tuned magnitudes. I write the tune-back + the
1B penalty conversion, re-run the gate, then confirm **"tuning frozen"** → you hand Codex 1F.
