# In-Game Testing Handoff — 2026-06-23 session

What this session's work still needs **eyeball/in-game** proof. Everything below is committed +
machine-verified; the open item is a tester confirming it in Skyrim. Test on the ARR / PDV Test
profile (the live Devotion build). No Reqtificator needed for any of these (sound + reward records
only); relaunch is enough, no new game required.

## DONE + proven this session (no action)
- **Argonian near-water regen redesign** (commit 5743044) — PROVEN in game: Whiterun `getav Health`
  120 -> Riverwood 150 (+30 Hist-Sworn near-water pool) with visible regen. The location gate works.
- **Broad +10 floor + apply-piety self-resync** (3f10404) — proven via the MCM-slice pass + Papyrus log
  (Breton/Imperial/Orc `T1` floors granted; Khajiit/Arkay granted off the slider).
- **Reward-author condition framework + fail-closed Disallow** (5743044) — machine-verified (10-spec
  readback; Khajiit nightOnly baseline intact). No in-game test needed (authoring layer).

## PENDING in-game proof

### 1. D1 tier-up chime — louder 2D blessing (commit 132a3ac) — HIGHEST PRIORITY (untested)
The tier-up cue was repointed from a too-quiet 3D charge-hum to `MAGAltarsBlessingFireC2D` (2D, full
volume). Not yet heard in game.
- Seed any focused deity and drive a tier UP-crossing (e.g. MCM "Selected deity" -> "Target piety" 50
  -> "Apply target piety" so it crosses into a new tier; apply-piety now self-resyncs).
- Confirm you **hear** a clear blessing flourish on the tier-up (the visual already fires).
- If still too quiet: the fallback is a custom PDV SoundDescriptor with cranked static attenuation
  (the 2D vanilla descriptor is volume-capped). Note loud-enough / still-thin.

### 2. Argonian Void path — moved unarmed (commit 5743044)
The substrate's +12 unarmed was moved to the Void/Sithis champion. Only the People focus was tested.
- `set PDV_GLO_OriginRace to 7`; MCM **"Argonian focus -> Void"** (seeds Hist + Void, reaches the Void
  champion); confirm **+12 UnarmedDamage** on the Void path and that it's **gone from the substrate**
  everywhere (dry + wet). Check the Sithis near-water rewards toggle like the Hist ones did.

### 3. Argonian near-water — magnitude tuning read (provisional)
The regen is `HealRateMult` 120 (Mid) / 160 (High) and the Hist-Sworn near-water pool is +30 — all
PROVISIONAL under Requiem. The toggle is proven; the *feel* is the tuning question.
- Near water, take a hit and gauge whether the regen is **felt** (Requiem nets ~+20/+60 effective).
- Spot-check the gate fires in **other** listed wetlands too (Morthal, Riften, Ivarstead, Darkwater
  Crossing, Kynesgrove), not just Riverwood — confirm "generous" feels right and nowhere dry leaks it.
- Hand back a one-word gut read (thin / right / strong) so the magnitudes can be tuned back.

### 4. Writing-polish surfaces (A1/A2/A3) — baked, not yet in-game-confirmed
Already baked into Devotion.esp + `--check` clean (this session). Run the in-game closeout already
written in **`PDV_WritingPolish_ESP_Handoff_2026-06-23.md`** ("Verify after bake" + "IN-GAME CLOSEOUT"):
apply a Bosmer variety buff and confirm the `(Effect: ...)` clause shows + ScalesAtRest lasts 10 min;
fire a Bosmer path suggestion -> "toward **the** <Path>"; confirm Dunmer neglect reads "The Ancestors'
Silence". Plus **R2** (Bosmer Songs-of-the-Green vision rewrite) — walk into a Songs site via a load
door / fast-travel (NOT `coc`), confirm the reworded per-site line; reach all 6 for the milestone.

## NOT this session's testing (tracked elsewhere, for context)
- **Argonian People/Void quest points** — wired but the quest-source FormLists are empty; spinoff task
  + `PDV_P2QuestSourceFormList_AuditHandoff_2026-06-23.md` owns the curate-fill + audit. Until then,
  People/Void points only move via the debug MCM, not gameplay.
- The Session B/C/D + 1F-freeze critical path (per `AGENTS.md`) is unchanged by this session.
