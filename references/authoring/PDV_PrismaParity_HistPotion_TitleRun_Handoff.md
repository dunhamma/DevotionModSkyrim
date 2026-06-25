# Codex Handoff -- Hist Sap Potion + Daedric Title Run (V1 beta-readiness)

Two small build items that gate the V1 beta (the runsheets are authored and waiting on these). Both are
self-contained. Owner ruling captured in `PDV_V1_BetaReadinessGate.md`.

## 1. Hist sap -> self-replenishing ALCH potion
**Owner ruling:** the Argonian Hist sap is currently a reusable BOOK read-token (`PDV_ArgonianHistSapToken.psc`,
granted via `EnsureArgonianHistSapToken` at `PDV_Origin.psc:127`). Change it to a **potion the character
consumes to receive Hist piety, which immediately re-adds itself to inventory** -- an infinite-use ritual vial.

### Records (ESP via the Mutagen author pattern / houseCARL)
- **ALCH** `PDV_Potion_ArgonianHistSap` -- "Hist Sap"; reuse a vanilla potion model (no new mesh); food/potion
  flag so it's "consumed" on use; one effect entry pointing at the MGEF below.
- **MGEF** `PDV_MGEF_ArgonianHistSap` -- Script archetype (Value Modifier with 0 magnitude, or a fire-and-forget
  scripted effect), self-target. Attach the script below.

### Script (the consume -> award + replenish)
On the potion's magic effect firing (effectively on drink):
1. **Award Hist piety** through the existing Hist substrate path so it lands a **Ledger driver** (the
   scaled-curated reason fix means a reason-bearing award now records). Reuse the Argonian Hist spine/substrate
   award the organic hooks already call (e.g. the `AwardArgonianHist*` / `AwardCuratedSignalScaled(PDV_Hist, ...)`
   pulse used by near-water maintenance) -- do NOT invent a new piety channel. Respect the **once/day Hist cap**
   (the award is capped like any substrate act).
2. **Replenish:** `Game.GetPlayer().AddItem(PDV_Potion_ArgonianHistSap, 1, true)` so the count never drops
   below 1. The replenish is NOT day-capped (the vial always returns); only the piety award is capped.
3. Optional: a small substrate "act" toast (the Hist substrate progress beat already fires for Hist acts).

### Grant rework
- `EnsureArgonianHistSapToken` (`PDV_Origin.psc:127`) -> grant the **potion** (1) on Argonian race-confirm
  instead of the book. Retire or repurpose `PDV_ArgonianHistSapToken.psc` (the OnRead book token).

### Acceptance
`pdv_compile` 0/0 -> `pdv_verify` FAIL=0 -> `pdv_integrity_harness` PASS. In-game (Argonian, new save): the
Hist Sap is in inventory; drinking it raises Hist piety + records a Ledger driver + the vial **returns to
inventory**; a 2nd same-day drink returns the vial but adds no extra piety (daily cap). Run-sheet: Argonian Slot 4a.

## 2. Daedric 16 epithet title author-run
The 16 epithet titles are coded in `tools/pdv-daedric-offer-title-author` (Program.cs, hardcoded list:
Azura's Twilight, Boethiah's Trial, Clavicus Vile's Bargain, Hermaeus Mora's Unread Pages, Hircine's Hunt,
Malacath's Oath, Mehrunes Dagon's Ruin, Mephala's Web, Meridia's Light, Molag Bal's Grip, Namira's Dark,
Nocturnal's Shadow, Peryite's Order, Sanguine's Revel, Sheogorath's Madness, Vaermina's Dream) but the MESG
**title records were not written to `Devotion.esp`** in the Unit D commit.

### Run
`dotnet run --project tools/pdv-daedric-offer-title-author -- --esp <Devotion.esp>` (or the tool's documented
invocation), then verify with its `--check` path if it has one. Bodies unchanged; titles only.

### Acceptance
The 16 Daedric offer/champion-entry MESGs carry the epithet titles; in-game the Champion offer pop-up shows
e.g. "Mephala's Web" as the title. Run-sheet: Daedric D4. `pdv_integrity_harness` PASS after.

## Notes
- ESP authoring uses the established Mutagen/houseCARL author pattern (in-place + auto-backup + fail-closed);
  serialize ESP writes with any concurrent writer.
- New save for the potion grant (VMAD/record bake).
- Neither item touches the offer/parity Papyrus already committed -- they're additive.
