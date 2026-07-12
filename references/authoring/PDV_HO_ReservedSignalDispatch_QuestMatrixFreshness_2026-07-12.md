# Handoff: Reserved Curated-Signal Dispatch + Quest-Matrix Freshness (2026-07-12)

**Status:** Owner-approved work order, NOT built. Two packages:
(A) dispatch the 5 reserved deity signals that are declared but never fire;
(B) prove the updated quest matrix actually reaches deities end-to-end
(regen deployed JSON, verify name normalization, close the stale ARR slice).

Origin: Khajiit stack-parity audit (2026-07-12 session). ESP readback confirmed
all 23 Khajiit reward records built AND VMAD-wired (Substrate_Always/Mid/High on
`PDV_Substrate_KhajiitLunar` 04C8A4, all 5 `PDV_Bless_Khajiit_Phase_*` props on
`PDV__ManagerQuest` 00C325). So the reward surfaces exist; the remaining earn-side
gap is these undispatched signals, and the remaining route-side risk is matrix
deployment/name drift.

---

## Package A - dispatch the 5 reserved curated signals

Registry: `tools/pdv_reserved_signals.json` (NOTE: currently present only in
worktree `.claude/worktrees/great-lewin-c094ed/tools/` - reconcile it into the
main tree first, or confirm where the live registry now lives; the seeded-33
burn-to-empty gate `pdv_signal_e2e_gate.mjs` + `pdv_verify
--strict-curated-signal-dispatch` is the completion authority).

Rules that apply to every signal below:
- Anti-farm cap on the PIETY pulse (daily-cap key via
  `ConsumeDailyRepeatMultiplier`, matching the sibling Khajiit handlers).
- Driver copy states WHEN it fires, never poetic; phrase source is
  `HumanizeCuratedSignalReason` via `[disp]` only - no new signalType->token map.
- New debug hooks = MCM dev-page buttons (user does not use cqf).
- Dispatch = the full chain: detector -> handler -> `AwardCuratedSignal*` ->
  ScoreCuratedSignal registry row -> e2e gate row burns.

### A1. Khenarthi SIGNAL_CARAVAN_AID (build)
The penalty side (CARAVAN_HARM) is wired; the reward side is not - fix the
one-sidedness. Detector recommendation, in order of preference:
1. Hostile actor dies while player is in combat alongside a member of the
   Khajiit caravan faction (`kajhiitCaravanFaction` / the four caravan leader
   factions - verify FormKeys via houseCARL, do not guess).
2. Fallback: trade transaction with a caravan merchant (OnItemAdded from a
   caravan-faction vendor chest is fragile; prefer the combat-aid detector).
Award: Khenarthi small pulse; daily key `PDV.Signal.KhenarthiCaravanAid`.

### A2. Rajhin SIGNAL_LEGEND_MADE (build)
Big-heist milestone extending the existing elegant-theft route. Detector:
single steal event whose item value >= 500 gold (read from the 362 route's
aiAcquireType path, value from the base object), once per day; plus a one-shot
latch per Thieves Guild capstone (`TG08B` Blindsighted stage complete) so the
quest route and the emergent route both count exactly once.
Award: Rajhin medium pulse; daily key `PDV.Signal.RajhinLegendMade`.

### A3. Mephala SIGNAL_WEB_WOVEN (build)
"Plot resolved by cunning" detector. Recommendation: curated quest-stage
FormList (P2 receiver pattern - `PDV_FLST_P2_MephalaWebSources`, quest-stage
kind), seeded with stages where the player resolves by manipulation/secrets:
`DA08` (The Whispering Door) s55, `MS06` persuasion branches, `TG03`
(Scoundrel's Folly) s90, DB `Bound Until Death` s100. Curate per the P2
manifest acceptedUse discipline; verify every stage via houseCARL; atomic
manifest+ESP fill (P2 source-fill rule).
Award: Mephala small-medium pulse; key `PDV.Signal.MephalaWebWoven`.

### A4. Boethiah SIGNAL_HONORABLE_DUEL (build)
Honorable-duel/test detector. Recommendation: brawl victory - vanilla brawl
system runs through `DGIntimidateQuest`; hook its player-won completion stage
(verify stage via houseCARL). Optionally add Boethiah's own arena (the
`DA02` Champion duel s50) as a one-shot latch.
Award: Boethiah small pulse; key `PDV.Signal.BoethiahHonorableDuel`.
Note: Boethiah/Mephala serve BOTH Dunmer Reclamation and the Khajiit roster -
route through the normal reachability/stance gates so each origin scores per
its own rules; no origin hardcode in the detector.

### A5. Khenarthi SIGNAL_OPEN_ROAD (REMOVE - owner default)
Registry note says "Low value (delta 0.3 ambient weather); Wave 3 or REMOVE."
Recommendation: REMOVE. Road-home cadence already owns Khajiit travel identity,
and ambient weather-walk detection is the same passive-weather class the owner
already ruled out for Green Way V1. Strip the constant + registry row in the
same sweep (mirror the 6 vestigial CIVIC_SERVICE removals pattern). If the
owner instead wants it built, it must be a player-initiated act, not passive
weather state.

### Package A gates
- `pdv_compile` manager (+ MCM if dev buttons added) 0/0.
- `pdv_signal_e2e_gate.mjs`: the 4 built signals burn from the reserved list;
  OPEN_ROAD burns via removal. `pdv_verify --strict-curated-signal-dispatch`
  FAIL=0.
- Runtime smoke per signal via MCM debug button + one organic route each;
  daily caps hold on repeat.

---

## Package B - quest matrix correctly reaches deities

The authoring matrix is current (1,056 rows incl. the 07-11 tranche10 Y'ffre
rows) but the deployed artifacts lag, and there is a known name-normalization
hazard. Close all four:

### B1. Regen + deploy the runtime matrix JSON
Pipeline: `pdv_quest_tranche_merge` -> `pdv_quest_matrix_compile --check --json`
-> `--papyrusutil-check --json` -> deploy to
`SKSE/Plugins/StorageUtilData/PlayerDevotion/`. Expected backend state (co-test
runbook): 1057 rows / 169 quest keys / 135 watched quests / 26 faucet acts.
Key-drift tell: a deity logging "0 quest entries" at runtime means deployed JSON
keys drifted from the Papyrus reader - rerun the compile, do not hand-edit.

### B2. Name-normalization check (the silent-drop hazard)
`ApplyDeityReaction` has historically dropped mismatched/apostrophe deity names
(paired-deity equity fix). The Full CSV uses `Y'ffre` (apostrophe - plain
`Yffre` = 0 rows), `Baan Dar` (space), and `Azura` (while the Khajiit focus
layer says Azurah). VERIFY with a runtime marker per spelling class:
- one tranche10 `Y'ffre` row fires and lands on PDV_Yffre;
- one `Baan Dar` row lands on PDV_BaanDar;
- one `Azura` row lands on PDV_Azura for BOTH a Dunmer and a Khajiit origin.
If any drop, fix the normalizer (name-based, not row edits) and add the
spelling classes to the remap adversary check so this fails closed next time.

### B3. Regen the ARR compatibility slice
`dist/PDV_AuthoriaARR_Compatibility/.../PDV_QuestReactionMatrix_ARR.json` was
generated 2026-06-25 and predates tranche10 - its Y'ffre coverage is
stance-only. Regenerate the ARR package from the current matrix (ARR packaging
rules apply: houseCARL instance repointing, no new Requiem masters).

### B4. Reachability gates stay intact
After regen, rerun `pdv_deity_signal_remap_adversary_check.mjs` (PASS; the
off-roster hostile/taboo guard count staying nonzero is expected) and one
wrong-origin silence spot check (e.g. an Altmer firing a Khajiit-roster-only
row stays silent).

### Package B gates
- Matrix compile checks PASS at the expected counts; deployed hash != stale.
- Remap adversary check PASS.
- Runtime markers for B2's three spelling classes recorded in the signal-floor
  smoke ledger.
- `pdv_1_0_endstate_gate --run` re-green after the deploy (drift-void expected
  until then).

---

## Explicitly OUT of scope
- New substrate feed channels, substrate decay, neglect bite, lunar
  curse-posture mechanics (owner has not approved; separate decision).
- Any new Khajiit reward records (all 23 verified built + wired 2026-07-12).
- Likes/dislikes CSV changes (rows verified deity-aligned; no edits needed).

## Proof boundary
This handoff's completion claim = backend/static + runtime-route markers only.
Manual-display proof (toasts, Book of Days, Active Effects for the new signal
routes) folds into the Khajiit sitting; phase-blessing and substrate LOW/HIGH
band test cards are a separate pending runbook addition.
