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
