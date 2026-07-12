# Green Way Fill — Resolved Curation (staging, ready to apply ATOMICALLY post-Codex)

## Why staged, not applied
The P2 source fill is **not separable** into manifest-then-ESP: the gate's
`--check-source-fill` helper **throws** (reddening ALL 39 surfaces) whenever the manifest
declares `approved-for-fill` entries the ESP FormList does not yet contain. So the manifest
authoring + `dotnet run --project tools/pdv-phase20-p2-receiver-author -- --fill-source-entries`
(which writes `Devotion.esp` **in-place** via Mutagen) must happen as **one atomic step**.
And that in-place write must be **serialized with Codex's faucet ESP writes** — two concurrent
in-place `Devotion.esp` writers = last-writer-wins data loss. **Apply this only when Codex's
prince-faucet ESP work is confirmed done.**

## RED surfaces this clears
- `PDV_FLST_P2_BretonGreenWayHarvests` (harvest) -> via the 4 ingredients below.
- `PDV_FLST_P2_BretonGreenWaySources` -> via the Eldergleam quest-stage (below); NOT harvest
  (harvest in both lists double-routes `RouteBretonGreenWayStanding`, and `Sources` also fires
  `RouteBretonTraditionChoice(2,...)`, a path-commitment route wrong for a passive harvest).
- `PDV_FLST_P2_BretonHiddenArtSpells` (spell-learned) -> SEPARATE (Hidden Art research, TBD).

## Harvest fill -> `PDV_FLST_P2_BretonGreenWayHarvests` (sourceFillEntries group)
houseCARL-verified vanilla INGR (exist in every load order):
| formKey (Plugin:HEX) | editorId | rationale |
|---|---|---|
| `Skyrim.esm:063B5F` | SprigganSap | Spriggan sap -- harvest from a nature-guardian spirit, peak druidic; rejects generic plant gathering. |
| `Skyrim.esm:03AD71` | Taproot | Spriggan taproot -- a nature-guardian harvest honoring the Green Way; not generic farming. |
| `Skyrim.esm:059B86` | Nirnroot | The rare luminescent Nirnroot -- curated sacred-flora; rejects generic herb-picking. |
| `Skyrim.esm:0B701A` | NirnrootRed | Crimson Nirnroot (Blackreach) -- rare sacred-flora, not generic gathering. |
All `sourceKind: harvest`, `status: approved-for-fill`.

## Sources fill -> `PDV_FLST_P2_BretonGreenWaySources` (quest-stage routeEntry)
- Quest: `dunEldergleamT03` "The Blessings of Nature" (`015CC2:Skyrim.esm`) -- the
  Gildergreen/Eldergleam restoration; the iconic nature-site milestone. Robust vanilla.
- TODO before apply: houseCARL-read the quest stages, pick the milestone stage (sap drawn /
  tree restored), author the routeEntry (formKey=`015CC2:Skyrim.esm`, expectedFormId=89282,
  approvedStage=<verified>, routeKey, dispatch via the existing `RouteBretonTraditionChoice(2,...)`
  + `RouteBretonGreenWayStanding`), and **Codex adds the `ShouldRouteP2QuestStage` branch** in
  `PDV_PlayerEvents.psc` (cross-lane). Adds the `quest-stage` type -> path 4/5.

## Findings (affect the floor target, not the REDs)
- **Book pool is barren**: no Kynareth/herb/flora/druidic vanilla book exists (houseCARL: 0
  matches). The Green Way has no robust book source.
- **Weather is load-order-fragile**: this order runs NAT (Natural and Atmospheric Tamriel);
  vanilla `SkyrimClear` is overridden and the only clear/aurora weathers are NAT-specific
  records (`SClearSky*` in NAT-ENB.esp, `SoulCairnAurora`). A FormList of weather FormIDs only
  fires for NAT users and dangles for everyone else. **The floor reaches 5/5 WITHOUT weather**
  (day-to-day + quest-reaction + harvest + quest-stage = 4 types, +1 more; renewable
  day-to-day + harvest = 2). Robust 5th type would need classification-based weather detection
  (a small Codex Papyrus change: detect `weather.Classification == Pleasant` instead of FormList
  membership) -- deferred enhancement, user picked "Moderate" weather but the NAT issue makes
  classification-detection the right path if weather is wanted.

## Apply procedure (atomic, post-Codex)
1. Confirm Codex's faucet ESP writes are done (no concurrent `Devotion.esp` writer).
2. Author the harvest sourceFillEntries group + the Eldergleam routeEntry in the manifest.
3. `dotnet run --project ./tools/pdv-phase20-p2-receiver-author -- --fill-source-entries`.
4. `node tools/pdv_signal_e2e_gate.mjs` -> Green Way surfaces GREEN; `node tools/pdv_signal_floor_audit.mjs` -> breton_green_way 2/5 -> 4-5/5.

---

## Execution status 2026-07-12 (floor-pass session)

Done this session:
- Manifest: `GreenWaySources` sourceKinds trimmed to `[quest-stage, book]` (weather/harvest
  were phantom declarations a GREEN surface would falsely credit); Eldergleam quest-stage
  sourceFillEntry added (`Skyrim.esm:015CC2`, approvedStages [100], full exact-stage metadata)
  matching the already-approved `breton-eldergleam-blessings` routeEntry.
  `--check-route-entries` (46 match) and `--check-exact-stage-gates` (29 approved) PASS.
- Breton driver-row voice: Green Way signals now award `PDV_Yffre.SIGNAL_GREEN_WAY` (new, 306,
  DELTA 2.5) instead of reusing the Bosmer-voiced `SIGNAL_LIVING_STORY`; humanized phrase
  "keeping the Green Way". Prisma JS needs no change (rows render pre-humanized strings).
- Papyrus-optimization pass on the route path: fixed the day-0 self-suppression in
  `MarkP2SourceRoute` (day-key now stores day+1; StorageUtil int default 0 == game day 0
  silently ate all harvest/weather routes on the first in-game day) and made the retired
  ancestor-substrate strip one-shot (`PDV.Breton.SubstrateLegacyCleared`).
- Compiles: PDV_Deity_Yffre, PDV__ManagerQuest, PDV_PlayerEvents, PDV_MCM all clean; pdv_verify FAIL=0.

PENDING (blocked in-session):
- **ESP fill** (`--fill-source-entries` adds 015CC2 to `GreenWaySources`): blocked while
  SkyrimSE.exe holds `Devotion.esp`. IMPORTANT: with the manifest entry now declared, the E2E
  gate's `--check-source-fill` REDs until this fill lands -- run the fill BEFORE the gate.
- **Live E2E run** (Anvil MCP server up) -> both Green Way surfaces GREEN -> floor ledger
  `breton_green_way` PASS 5/5, 2/2 (day-to-day, quest-reaction, book, quest-stage, harvest).

## Runtime smoke checklist (MCM-driven; proof class = runtime-route, currently OPEN)

Run on a NEW save or post-fill load (quest-stage watch registration re-reads the FormList at
init; an old session predating the fill will not watch dunEldergleamT03).

1. **Book (once-ever)**: read *The Wispmother*. Expect: Green Way tradition latch (if setup
   incomplete) or CrossTraditionPressure (if another tradition latched); driver row
   "keeping the Green Way"; `PDV.Breton.DruidicStanding` +25.
2. **Harvest (once/day/form)**: harvest Nirnroot (or Spriggan Sap / Taproot / Crimson
   Nirnroot). Expect: same row/standing; second harvest of the SAME form same day = silent
   (day-key); different form same day = routes with x0.7 decayed multiplier.
   Day-0 regression: harvesting on game day 0 must now route (day+1 key fix).
3. **Quest-stage (once-ever)**: complete The Blessings of Nature (dunEldergleamT03 stage 100).
   Expect: one-shot "keeping the Green Way" row; no re-fire on later stages/revisits.
4. Verify in panel: Ledger driver rows read "keeping the Green Way" (NOT "a Living Story
   deed"); Survey Green Way band moves with DruidicStanding.

## Follow-ups (out of this session's scope)
- Nord Old Ways floor pass: same pattern (trim phantom weather on NordKyneTalosSources or wire
  classification-based weather; curate its missing 5th type; live E2E).
- Wispmother book remains a flagged PLACEHOLDER pending a stronger druidic book.
- Weather stays deferred pending classification-based detection (NAT fragility, above).
