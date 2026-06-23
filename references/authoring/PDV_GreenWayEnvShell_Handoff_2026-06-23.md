# Green Way Env-Shell Fill — Codex Handoff (2026-06-23)

**Mission:** Populate Breton **Green Way**'s empty environmental source-types so it crosses the
signal floor (currently **2/5 types, 1/2 renewable → target ≥5/2**). This is the **proving case for
the env-shell recipe** (the renewable, non-quest signal types the prior enrichment pass skipped).
Green Way is the original trigger for this whole effort.

**Wiring is already built — this is curation + fill, not new code.** The hooks exist and route
end-to-end:
- `OnItemHarvested` → `RouteP2ImmersiveSource(produce, "po3_harvest")` → membership in
  `PDV_FLST_P2_BretonGreenWayHarvests` / `PDV_FLST_P2_BretonGreenWaySources` →
  `RouteBretonGreenWayStanding` → `HandleBretonGreenWayStanding` (+25 DruidicStanding + Kynareth
  `SIGNAL_OPEN_SKY` piety, daily-capped via `ConsumeDailyRepeatMultiplier`).
- `OnWeatherChange` → `RouteP2ImmersiveSource(weather, "po3_weather")` → `BretonGreenWaySources`
  membership → same handler.
- `OnBookRead` → `RouteP2ImmersiveSource(book, "po3_book")` → `BretonGreenWaySources` → same handler.

So filling the FormLists is sufficient; **no Papyrus change**. Anti-farm: weather/harvest are
once-per-in-game-day-per-source (manifest `antiFarmPolicy`); the piety award is daily-capped in the
handler.

## Fill targets (take Green Way 2/5 → 5/5)

Green Way has `day-to-day` + `quest-reaction` today. Add **harvest + weather + book** (→ 5 types, 3
renewable). Curate per the manifest contract (`acceptedUse`: "curated druidic / nature-site /
standing-stone / landscape sources"; `rejectedUse`: "generic herb picking, generic forest travel,
random standing-stone activation"). **Verify every FormKey + suitability via houseCARL; do NOT
invent FormIDs.**

- **Harvest** (`PDV_FLST_P2_BretonGreenWayHarvests`, renewable): a *small curated* set of sacred /
  rare nature ingredients — NOT all flora. Candidates to verify: Nirnroot, Spriggan Sap, Crimson
  Nirnroot, Mora Tapinella, Bleeding Crown, Taproot. Note the harvest hook gives the produce form
  only (no location), so curate by *item rarity/sacredness*, accepting it's item-keyed. Target ~5–8.
- **Weather** (`PDV_FLST_P2_BretonGreenWaySources`, renewable — NET-NEW type, no race uses it yet):
  a curated set of open-sky / nature weathers ("communing under the living sky"). Candidates to
  verify: clear-sky and aurora weathers, and Eldergleam/Falkreath-forest region weathers if any.
  **Flag for design sign-off** — which weathers count as "druidic" is a judgment call; confirm the
  `OnWeatherChange` → `po3_weather` route fires for a list member before committing. Target ~3–5.
- **Book** (`PDV_FLST_P2_BretonGreenWaySources`, one-shot): vanilla Green Way / Y'ffre text pool is
  **thin** (like Bosmer). Verify candidates (nature/Kynareth-adjacent lore); if none qualify, fall
  back to a curated **quest-stage** nature-site milestone (e.g. Eldergleam Sanctuary / Blessings of
  Nature) for the 5th type instead — either gets Green Way to 5/5.

## Acceptance
- Re-run `node tools/pdv_signal_floor_audit.mjs` → Green Way's harvest + weather + (book|quest-stage)
  count as **wired_end_to_end**, verdict **PASS** (≥5 types, ≥2 renewable).
- E2E gate GREEN for the Green Way surfaces; the five `--check-*` modes pass.
- In-game (server up): harvest a curated plant / hit a curated weather → confirm one piety+track
  trace per the daily cap.

## Hand-back
Updated manifest `sourceFillEntries` for the Green Way FormLists (exact records, `approved-for-fill`
+ rationale matching acceptedUse), one backed-up `--fill-source-entries` write, and the floor ledger
showing Green Way PASS. Claude reviews the weather curation (the novel/judgment piece).

## Model / dependency
- Curation reasoning → **Sonnet/Codex**; weather design call → flag to Claude/owner.
- **Needs the Anvil MCP server up** for the ESP fill + houseCARL record verification.
- Files: `references/authoring/PDV_Phase20_P2ImmersiveReceivers.manifest.json`; vanilla candidates in
  `references/vanilla-gameplay/extracted/*`; hooks in `PDV_PlayerEvents.psc` (already wired).
