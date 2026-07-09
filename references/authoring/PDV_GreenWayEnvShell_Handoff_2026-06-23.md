# Green Way Env-Shell Fill -- Codex Handoff (2026-06-23)

**Mission:** Populate Breton **Green Way**'s empty environmental source-types so it crosses the
signal floor (currently **2/5 types, 1/2 renewable -> target >=5/2**). This is the **proving case for
the env-shell recipe** (the renewable, non-quest signal types the prior enrichment pass skipped).
Green Way is the original trigger for this whole effort.

**2026-07-09 supersession:** Weather is no longer a V1 fill target. Owner
ruling: the Green Way / Y'ffre weather idea should be investigated for V2 as a
player-initiated sky-welcoming ritual/prayer, not as automatic piety from a
weather transition. Keep the `OnWeatherChange` scaffold dormant unless a future
V2 design explicitly reuses weather as context after the player performs the
rite.

**Wiring is already built -- this is curation + fill, not new code.** The hooks exist and route
end-to-end:
- `OnItemHarvested` -> `RouteP2ImmersiveSource(produce, "po3_harvest")` -> membership in
  `PDV_FLST_P2_BretonGreenWayHarvests` / `PDV_FLST_P2_BretonGreenWaySources` ->
  `RouteBretonGreenWayStanding` -> `HandleBretonGreenWayStanding` (+25 DruidicStanding + Kynareth
  `SIGNAL_OPEN_SKY` piety, daily-capped via `ConsumeDailyRepeatMultiplier`).
- `OnWeatherChange` -> `RouteP2ImmersiveSource(weather, "po3_weather")` -> `BretonGreenWaySources`
  membership -> same handler.
- `OnBookRead` -> `RouteP2ImmersiveSource(book, "po3_book")` -> `BretonGreenWaySources` -> same handler.

So filling the FormLists is sufficient; **no Papyrus change**. Anti-farm: weather/harvest are
once-per-in-game-day-per-source (manifest `antiFarmPolicy`); the piety award is daily-capped in the
handler.

## Fill targets (take Green Way 2/5 -> 5/5)

Green Way has `day-to-day` + `quest-reaction` today. Add **harvest + book** or
an exact quest-stage nature-site route for V1; weather is V2 investigation only.
Curate per the manifest contract (`acceptedUse`: "curated druidic / nature-site /
standing-stone / landscape sources"; `rejectedUse`: "generic herb picking, generic forest travel,
random standing-stone activation"). **Verify every FormKey + suitability via houseCARL; do NOT
invent FormIDs.**

- **Harvest** (`PDV_FLST_P2_BretonGreenWayHarvests`, renewable): a *small curated* set of sacred /
  rare nature ingredients -- NOT all flora. Candidates to verify: Nirnroot, Spriggan Sap, Crimson
  Nirnroot, Mora Tapinella, Bleeding Crown, Taproot. Note the harvest hook gives the produce form
  only (no location), so curate by *item rarity/sacredness*, accepting it's item-keyed. Target ~5-8.
- **Weather** (`PDV_FLST_P2_BretonGreenWaySources`, renewable): V2
  investigation only. Do not add passive weather records for V1.
- **Book** (`PDV_FLST_P2_BretonGreenWaySources`, one-shot): vanilla Green Way / Y'ffre text pool is
  **thin** (like Bosmer). Verify candidates (nature/Kynareth-adjacent lore); if none qualify, fall
  back to a curated **quest-stage** nature-site milestone (e.g. Eldergleam Sanctuary / Blessings of
  Nature) for the 5th type instead -- either gets Green Way to 5/5.

## Acceptance
- Re-run `node tools/pdv_signal_floor_audit.mjs`. Green Way may remain under the
  former weather-driven target in V1; missing passive weather is not a V1 blocker.
- E2E gate GREEN for the Green Way surfaces; the five `--check-*` modes pass.
- In-game (server up): harvest a curated plant or fire the approved exact
  nature-site route -> confirm one piety+track trace per the daily cap.

## Hand-back
Updated manifest `sourceFillEntries` for the Green Way FormLists (exact records, `approved-for-fill`
+ rationale matching acceptedUse), one backed-up `--fill-source-entries` write, and the floor ledger
showing the V1-approved Green Way surface state. Weather curation moved to the
V2 sky-welcoming ritual investigation.

## Model / dependency
- Curation reasoning -> **Sonnet/Codex**; sky-welcoming ritual design is V2 and
  needs owner sign-off before implementation.
- **Needs the Anvil MCP server up** for the ESP fill + houseCARL record verification.
- Files: `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`; vanilla candidates in
  `references/vanilla-gameplay/extracted/*`; hooks in `PDV_PlayerEvents.psc` (already wired).
