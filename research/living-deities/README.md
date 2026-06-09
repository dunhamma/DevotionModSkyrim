# LD-P1 Block B - Isolated Papyrus Slice (research, NOT deployed)

This directory holds the Living Deities Block B Papyrus wiring as an
**isolated, investigatory future-state slice**. Nothing here is deployed:
the live MO2 tree (`D:\Wabbajack\modlists\Anvil\mods\Devotion`) is untouched
except for the inert `PDV_LivingDeities.json` data file (no script consumes
it until this slice is promoted).

## Layout
- `src/` - the six scripts. `PDV_Deity_Hircine.psc` is new; the other five
  are copies of the 2026-06-10 live source with the LD-P1 edits applied.
  Every edit block is marked `LD-P1 Living Deities (research slice)`.
- `out/` - scratch compile output (compile proof only; do not ship from here).

## Compile proof (2026-06-10)
All six compile 0 errors / 0 warnings with the repo `src/` dir FIRST in the
import chain, then the proven pdv_compile.mjs roots (Devotion live source,
SKSE sources, PapyrusUtil, PO3 Extender, Stock Game, skyui shim), output to
`out/`. The live `Scripts/` and `Scripts/Source/` dirs are never written.

## What the slice implements (per the revised M3/M4, 2026-06-10)
- Mood EWMA + bands folded into `RunDawnConsolidateScratch` (reads
  `clampedToday` before `PietyToday` zeroes; `PIETY_DAILY_MAX_DELTA`
  referenced symbolically); band-cross dispatch with pool filter + once-per-day
  anti-spam; `PDV_GLO_PatronMoodBand` mirror.
- Demand engine mirroring the commitment-offer engine: dawn offer/expiry
  (`RunDawnProcessDemands`), fulfillment at the two real signal layers
  (EventBus faucet eventType match; `ApplyDeityReaction` quest-matrix tag via
  `NotifyDemandQuestTag`), single-act reset, `great_beast` filter via the
  (Block C) `PDV_FLST_DemandGreatBeasts` FormList - fails closed when unwired.
- Curse-gated `PDV_Deity_Hircine` face (delegates to `ScoreFromTable` after
  the gate - never a 0.0 stub; `IsRaceNativeForPlayer` override = NATIVE
  equivalence while werewolf; mood/demand zero on cure via the manager's
  curse-transition fanout). Quest-matrix "Hircine" rows keep routing to the
  PATH actor via an explicit guard in `GetQuestReactionDeity`.
- Band-variant boons (`SyncPatronBoonsToBand`, clear-before-add) and the
  mood-gated, deity-themed clutch save (`RequiredMoodBand`, default -1 keeps
  shipped behavior for existing VMAD instances).
- Dream omens on `OnSleepStart` (probability + day-keyed cooldown), toasts via
  the live `SendPrismaEventToast` with `Debug.Notification` ASCII fallbacks.

## To promote (when ratified)
1. Diff `src/*.psc` against the then-current live source (live may have moved;
   re-apply the marked LD-P1 blocks, do not blind-copy).
2. Copy promoted sources into the live `Scripts\Source\`, compile via
   `node tools\pdv_compile.mjs`, run `tools\pdv_living_deities_selftest.mjs`
   and `tools\pdv_verify.mjs`.
3. Block C CK records: PDV_Deity_Hircine QUST (SGE+SEQ - the BaanDar lesson)
   + FLST membership + stance rows + PDV.LD.* rows; PDV_GLO_PatronMoodBand;
   PDV_FLST_DemandGreatBeasts; band-variant boon SPEL/MGEF; clutch-save
   records; VMAD wiring (existing saves need version-gated migration).
4. Block D runtime proof per the revised 03_feasibility.md lists, including
   the 313/343 receiver runtime proof (Kyne demand faucet half).

## Quantified tunables (derived, not guessed)
- **Demand mood swing = one ideal day of devotion.** From mood 0, a max-signal
  day moves the EWMA by exactly `alpha * 100` points, so fulfillment/expiry
  apply `+/- alpha * 100 * DEMAND_MOOD_SWING_IDEAL_DAYS(=1.0)`: Kyne +/-12,
  Hircine +/-22 at the locked alphas. The deity's temperament knob (alpha)
  drives both the EWMA and the demand stakes - no second tunable to drift.
- **Demand offer cooldown 7d** = the commitment-offer first-decline cooldown
  precedent (`ApplyCommitmentDeclineCooldown`), so demands never re-ask faster
  than commitments do. Windows stay per-demand in the CSV (Kyne 4d, Hircine 3d).
- **Dream cadence:** armed only on a band-cross into Wroth/Exalted; 25% per
  sleep, 2-day floor -> expected <= 1 dream per ~4 sleeps inside an extreme-band
  episode, none outside. Strictly rarer than the once-per-day cross toast so
  the rarest channel reads as the most portentous.
- **`PDV_FLST_DemandGreatBeasts` (Block C contents, verified against the load
  order via houseCARL):** true-beast set only -
  `BearBrownRace 0131E7`, `BearBlackRace 0131E8`, `BearSnowRace 0131E9`,
  `SabreCatRace 013200`, `SabreCatSnowyRace 013202`,
  `DLC1SabreCatGlowRace 00D0B6:Dawnguard.esm`, `MammothRace 0131FF`,
  `TrollRace 013205`, `TrollFrostRace 013206`,
  `DLC1TrollRaceArmored 0117F5:Dawnguard.esm`,
  `DLC1TrollFrostRaceArmored 0117F4:Dawnguard.esm` (11 races, Skyrim.esm
  unless noted). **Dragons are deliberately absent:** dragon kills emit
  eventType 302 (by-victim classifier), never the demand's bound event 1, and
  Hircine's dragon credit already flows through the existing MQ104/MQ106
  quest-matrix rows. Werebears (werecreatures) and giants (humanoid-classified)
  are not prey and are excluded.
- **Clutch save:** gate = band >= Pleased (2) on `PDV_GLO_PatronMoodBand`;
  heal stays the shipped `HealAmount` 75 / 10% trigger / once per day.

## Open dependencies
- Kyne quest-matrix rows (`the_hunt`/`honor_the_wild`): being authored on a
  separate branch; without them Kyne's demand fulfills only via faucet 313/343.
- 313/343 receivers: landed on main (2e665b7), readback-clean, runtime proof
  pending.
