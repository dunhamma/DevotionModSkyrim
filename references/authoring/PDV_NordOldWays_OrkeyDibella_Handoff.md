# Nord Old Ways: Arkay-as-Orkey + Dibella Offer Enablement -- Handoff

Owner directive 2026-07-05 (Mega Packet Sitting 1 testing): the Nord Old Ways
offer-eligible roster now includes Arkay -- surfaced under the Nord name
"Orkey" (the Old Knocker) -- and Dibella. Under the Nine Divines baseline
Arkay stays "Arkay". Related decisions-log precedent: "Old Ways Mara wired
end-to-end + Nord Nine Divines reward-lane gap" (reuse-Imperial-reward-spells
pattern, baseline -1 = both lanes).

## What shipped (machine-proof level)

All Papyrus changes are in BOTH the tracked live-source and the MO2 build copy
(`D:\Wabbajack\modlists\Anvil\mods\Devotion\Scripts\Source`), compiled 0/0.

1. `IsNordOfferEligibleDeity` Old Ways branch now returns Arkay + Dibella
   (single-line return preserved for the coverage-audit parser).
2. `SyncNordRewards`: Arkay + Dibella rows moved from
   `NORD_BASELINE_NINE_DIVINES` to `-1` (both lanes), exactly the Mara
   pattern; rewards stay the reused Imperial SPELs, zero new reward records.
3. NET-NEW display-name override: `UsesNordOldWaysDeityNames()` (Nord origin +
   Old Ways baseline) gates the `arkay -> Orkey` mapping inside
   `NormalizePublicDeityDisplayText`; `GetPublicDeityDisplayName` funnels
   through it, so Survey, toasts, Book of Days, Ledger driver text, and panel
   event payloads all resolve "Orkey" in context. `DeityName` stays "Arkay"
   internally (StorageUtil keys, symbol lookup, quest-matrix matching).
4. Panel dashboard roster (`AppendDashboardGod`) now emits the public display
   name instead of raw `DeityName`; Prisma JS `displayName()` passes unknown
   names through raw, so "Orkey" renders with the existing arkay glyph (the
   `symbol` field is unchanged) -- no Prisma UI edit needed.
5. Nord medallion roster: Arkay entry title is baseline-gated to "Orkey".
6. `GetNordFormalCommitmentOfferMessage`: Arkay branch returns the new
   `PDV_Msg_Nord_Orkey_Offer` under Old Ways, `PDV_Msg_Nord_Arkay_Offer`
   otherwise.
7. Offer copy authored in `tools/pdv-nord-offer-author` + the race-content
   manifest section 10.6: Title "Orkey Counts the Years", god-voice, ASCII,
   within 500/280 budget. Dibella's existing offer copy is baseline-neutral
   and reads correctly under Old Ways (confirmed, no change).

## Verification state

| Gate | Result |
|---|---|
| pdv_compile (PDV__ManagerQuest, PDV_MCM) | 0 errors / 0 warnings |
| pdv_verify | FAIL=0 (1 pre-existing WARN: medallion glyph fallback) |
| pdv_eligibility_reward_coverage_audit | PASS (147 rows, 0 failures) |
| pdv_formal_offer_check | PASS (194 checks) |
| pdv_prisma_ui_audit | PASS (88 checks) |
| Orkey MESG in Devotion.esp | DONE 2026-07-06 -- 07161B, --check PASS |
| SEQ refresh after ESP write | DONE (pdv_refresh_seq --write, backup kept) |
| In-game offer smoke | PASS 2026-07-06 -- owner confirmed Orkey + Dibella offer, accept, and Active Effects on a default Nord Old Ways save (after the reused-spell-strip fix) |

## Orkey MESG ESP write (completed)

The first write attempt fail-closed while SkyrimSE held `Devotion.esp`; after
the game closed, `dotnet run --project tools/pdv-nord-offer-author` wrote
`PDV_Msg_Nord_Orkey_Offer` (07161B:Devotion.esp), rewired all 13 offer
properties, and `--check` reads back PASS with buttons
[Accept | Not yet | Refuse]. ESP backup:
`Backups\nord-offer\Devotion.esp.20260706-081114.bak`. The SEQ was
regenerated afterward (`node tools/pdv_refresh_seq.mjs --write`) so
`pdv_verify` is back to FAIL=0 with only the pre-existing medallion-glyph
WARN. The build is smoke-ready.

## In-game smoke (owner, MCM debug page, default Nord Old Ways save)

Orkey lane:
1. MCM > Devotion debug page: select deity Arkay.
2. "Target piety" slider to 50+, "Apply target piety".
3. "Seed commitment signals" (2-day window).
4. "Evaluate commitment" (dawn-equivalent). EXPECT: offer box titled
   "Orkey Counts the Years" (Old Knocker god-voice body).
5. Accept. EXPECT: toast "Orkey has named you their own."; Book of Days
   chronicle line names Orkey; panel dashboard god block + medallion roster
   show "Orkey" with the Arkay glyph; Survey focused line names Orkey.
6. Rewards: at Seeker tier expect the Imperial Arkay T1 spell in Active
   Effects (same record as the Nine Divines lane).

Dibella lane (NOTE the one-patron rule: while Orkey/Arkay is the active
patron, no new offer will evaluate -- "Reset commitment state" clears
pending/cooldown only, NOT the active patron):
7. Either load a pre-commit save, or on the same save: MCM debug >
   "Debug patron override" with Dibella selected (this now resyncs reward
   spells immediately -- fix 2026-07-06), or "Clear patron" then run the
   offer flow organically.
8. Repeat steps 1-5 with Dibella. EXPECT: offer "Dibella's Recognition"
   (offer path only); all surfaces show "Dibella" (no rename in either
   baseline); Active Effects show "Dibella's Grace" for the current tier
   (Devoted at piety 50: Speech +13, Magicka Regeneration +5%).

Root-cause bug (FIXED 2026-07-06, commit after aa59daf): even a clean
offer -> accept granted the reused Imperial reward spell and then STRIPPED
it in the same pass, so Nord reused-spell rewards never reached Active
Effects while every display cue (toast/BoD/panel/Survey) passed.

Mechanism: the Nord baseline lanes reuse the Imperial Divine reward SPELs
(Mara/Arkay-Orkey/Dibella + the whole Nine Divines set, owner ruling
2026-06-27). In SyncFirstTierRaceRewardRuntime, SyncNordRewards runs and
grants the Nord patron's spell; SyncImperialRewards runs AFTER it and,
because it managed the same records unconditionally with
isActive = origin == IMPERIAL (false on a Nord save), removed the spell
SyncNordRewards had just added. Net: no Active Effect. Confirmed in the
Papyrus log (offer.Orkey.Accept fired, tier Devoted, no errors) plus static
trace of both lanes. This latently affected ALL Nord reused-spell rewards,
not just the new Orkey/Dibella ones -- the coverage audit could not see it
because it is a static existence/fill check, not a runtime add-then-remove
ordering check.

Fix: SyncImperialRewards now early-returns its reward-family block when the
player is not Imperial (Civic_T2, an Imperial-only record, stays before the
guard to keep self-clearing). Only the player's own race lane manages the
reused records; SyncNordRewards runs unconditionally and already owns both
grant and cleanup on every non-Imperial save, and on Imperial saves the
Nord-first / Imperial-last order still grants correctly.

Earlier same-day fix (also shipped): "Debug patron override"
(ForceSetActiveDeityByIndex) and DebugClearActiveDeity did not resync reward
families -- a separate debug-path dawn-lag gap. Both now call
SyncFirstTierRaceRewardRuntime. The offer-accept path always synced; that
gap was NOT the reason Active Effects were missing (the strip above was).

Both fixes require a full game restart to load the recompiled
PDV__ManagerQuest.pex.

Cross-baseline check:
9. On a Nine Divines Nord save, Arkay must still offer as "Arkay's Covenant"
   and display "Arkay" everywhere.

Proof boundary: everything above the smoke section is machine/readback proof
only; no beta-feel or in-game claim is made until the owner smoke passes.

## Follow-on: Mara reward redesign (2026-07-06, commit c5e3a4d)

Testing the reused rewards surfaced that Mara only ever showed ONE Active
Effect (Restoration). Its second half was a scripted heal-on-wake
(HandleImperialMaraSleepMercy) -- not a real passive, invisible in Active
Effects, and Imperial-gated so it never fired on the reused Nord lane at all.
Owner ruling: Mara should read as two passive effects like Arkay/Dibella.

Change (affects Imperial AND the reused Nord lane, one shared spell family):
- PDV_ImperialRewardRecords.spec.json: Mara T2/T3 gain a Resist Magic
  secondary (+5 / +15), matching the accepted Akatosh/Julianos/Kynareth
  secondary-ResistMagic ceiling and the T2-onward secondary pattern; T1 stays
  single-effect (Restoration +5). playerFacingText updated; wake-heal design
  notes scrubbed.
- Manager: HandleImperialMaraSleepMercy + its call site removed (compiles 0/0).
- Mara is now Restoration + Resist Magic -- two Requiem-felt passives,
  identical for Imperial and Nord patrons.

ESP author (DONE 2026-07-06, after game exit): minted
PDV_MGEF_Imperial_Mara_T2_ResistMagic (07161C) + _T3_ResistMagic (07161D),
both ValueModifier/ResistMagic, no conditions. Readback confirms Mara T2 =
Restoration +13 / Resist Magic +5%, Mara T3 = Restoration +23 / Resist Magic
+15% (two effects each). Backup: Backups\phase20-race-rewards\
Devotion.esp.20260706-132944.bak. Post-write chain all green: SEQ refreshed,
PDV_MCM recompiled, pdv_verify FAIL=0 (only the pre-existing medallion-glyph
WARN), coverage audit PASS 147, requiem penalty audit 44/44 PASS. Only the
in-game restart + smoke remains. Commands used:

```
dotnet run --project tools/pdv-phase20-race-author -c Release -- \
  --author-rewards --rewards-spec references/authoring/PDV_ImperialRewardRecords.spec.json
node tools/pdv_refresh_seq.mjs --write        # ESP write bumps SEQ freshness
node tools/pdv_compile.mjs --script PDV_MCM    # refresh BoD-hotkey pex dependency
node tools/pdv_verify.mjs                      # FAIL=0
node tools/pdv_eligibility_reward_coverage_audit.mjs   # PASS
node tools/pdv_requiem_penalty_audit.mjs       # unaffected (Mara is positive)
```

Smoke (Nord Old Ways OR Imperial, Mara patron, Devoted 50+): Active Effects
should show "Mara's Mercy - Devoted" with TWO lines -- Restoration +13 and
Resist Magic +5%. Requires a full game restart to load the new ESP + pex.
The former wake-on-rest heal + "Mara's mercy" toast are intentionally gone.
