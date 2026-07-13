# Handoff: Requiem Magicka/Stamina Regen Conversion - Remaining Work (2026-07-13)

**Status of the conversion:** the project-wide Magicka/Stamina regen -> flat
Fortify max-pool conversion is BUILT + audited for all 10 races' main reward lanes,
the Daedric princes (boons + prices), the race neglect/creed-loss penalties, and
the Argonian near-death burst. Authority + full detail:
`PDV_RequiemMagickaStaminaConversion_BuildSpec_2026-07-13.md`. Testing docs updated
(16 files) with Sweep C felt-proof cards and 4 invalidated-PASS re-open notes.

Two items remain. Neither blocks the machine gates (all green: reward readback
PASS=1482, reward-order lint PASS, pdv_verify FAIL=0, pdv_prisma_ui_audit PASS 90).

---

## 1. Variety-batch records - LIVE ESP re-author OWED (the one live gap)

A completeness scan across ALL authoring JSON (not just `*RewardRecords.spec.json`)
found 4 regen rewards in variety-batch manifests that the conversion first missed.
Their SOURCE manifests + MESG text are already converted (this session) and
`PDV_FeltEffectRegistry.json` was regenerated, BUT the LIVE `Devotion.esp` records
still carry the old RateMult MGEF (muted under Requiem).

| Live SPEL (Devotion.esp) | Current live effect | Convert to (source already set) |
|---|---|---|
| `PDV_SPEL_ArgonianAdapt_Sap` | MagickaRateMult 5 | Fortify Magicka +10 (Magicka, ValueModifier/PeakValueModifier) |
| `PDV_SPEL_ArgonianAdapt_Marsh` (0714D3) | StaminaRateMult 8 | Fortify Stamina +15 (Stamina) |
| `PDV_SPEL_BosmerNaming_Wanderer` (0714FB) | StaminaRateMult 8 | Fortify Stamina +15 (Stamina) |
| CAT6-pilot record (`PDV_CAT6PromotionPilot.manifest.json`) | StaminaRateMult 5 | Fortify Stamina +10 (Stamina) |

**Why not done here:** these were originally authored via houseCARL-headless (no
dedicated `.NET` author tool exists for the variety batches - grep found none; git
blame = commits "Race variety tranches" / "Bake writing polish support"). Doing the
ESP write cleanly warrants a focused pass, not a rushed one at the end of a marathon
session.

**How to close it (pick one):**
- **Preferred:** find/confirm the tool that authored these manifests (check
  `tools/pdv-phase20-cat6-author`, or whatever reads `*Variety_RecordBatch.manifest.json`),
  update it to read the converted effects, and re-author with Skyrim closed + backup
  + houseCARL reload - mirroring the race-author flow.
- **Or:** houseCARL surgery on the 4 MGEFs directly - set `Archetype.Type` to
  ValueModifier (or PeakValueModifier, matching the race tool) and `Archetype.ActorValue`
  to Magicka/Stamina, and the effect magnitude to the converted value. Verify houseCARL
  targets `Devotion.esp` in-place, not a new patch plugin.
- Then: houseCARL readback (effect is Fortify pool, not RateMult) + `pdv_verify`.

The MGEF editorIds follow the pattern `PDV_MGEF_<spell-stem>_<AV>`; the AV change means
a new MGEF editorId, so the spell will repoint (old RateMult MGEF orphaned, harmless).

---

## 2. In-game "felt" proof - OWED per race (the release gate)

Machine gates prove the records EXIST as Fortify pool effects; they do NOT prove the
player feels them under Requiem. This is the release-blocking evidence and doubles as
the magnitude-tuning pass (all magnitudes are PROVISIONAL).

Run **Sweep C** in `PDV_RequiemSmokeTest_Tracker.md` (C1-C12) on a live Requiem/Authoria
list:
- For each converted M/S reward: seed the deity/tier, open Active Effects, confirm the
  **Magicka/Stamina bar MAX rises** by the Fortify amount. `player.getav Magicka/Stamina`
  returns CURRENT, not the ceiling - read the bar MAX / the "Fortify Magicka/Stamina"
  Active-Effects entry.
- Daedric Sheogorath Magicka / Hircine Stamina: +25/+40/+50 by tier.
- Argonian Sithis near-death: drop <20% HP in combat on the Void path -> INSTANT Stamina
  restore (+100), once/day (now a scripted `RestoreActorValue`, NOT a regen bar).
- M/S penalties: prime neglect (Altmer/Dunmer Magicka, Bosmer/Khajiit Stamina) / take the
  Breton Druidic betrayal fork -> Maximum Magicka/Stamina DROPS (-10 neglect / -15 creed).
- **Re-prove the 4 INVALIDATED already-passed proofs** (annotated in the packets):
  Bosmer "Path Goes Quiet", Breton Magnus-champion magicka leg, Argonian Rooted Rest,
  Redguard Tu'whacca Champion.

Record tuned magnitudes back into the reward specs by hand (the cumulative-rebalance
tools are not idempotent - do NOT re-run them). Sink evidence into
`PDV_1_0_ManualSignoffLedger.json` (requiemTrackB) + the felt-family ledger.

---

## Guardrail reminders (learned this session)

- **Capstone-save drop:** any AV change on a reward MGEF orphans a
  `PDV_T3DailyLowHealthSaveEffect` riding on it. After ANY reward re-author, run
  `pdv-phase20-p2-receiver-author --author-capstones` and check the readback
  "T3 capstone script" rows. (Imperial Akatosh T3 + Altmer AuriEl T3 broke this way.)
- **Do NOT blanket-run `pdv_reward_desc_regen`** after an effect change - it regenerates
  text from always-on effects only and STRIPS hand-written event-driven flavor
  (Shor/Tu'whacca/HoonDing save text). Use the convert-script's in-place regex.
- ESP writes: Skyrim closed, backup Devotion.esp, houseCARL re-point-to-reload after
  (it caches the overlay - `set_mo2_instance` forces a fresh read).
