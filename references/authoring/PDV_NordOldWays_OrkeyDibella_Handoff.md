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
| Orkey MESG in Devotion.esp | PENDING -- see below |
| In-game offer smoke | PENDING -- owner action |

## PENDING: Orkey MESG ESP write

`dotnet run --project tools/pdv-nord-offer-author` fail-closed because
SkyrimSE was RUNNING and held `Devotion.esp` (a session monitor is armed to
retry on game exit). The dry-run passed: creates `PDV_Msg_Nord_Orkey_Offer`
(07161B), rewires 13 offer properties, buttons [Accept | Not yet | Refuse].
If the monitor did not complete it, run after closing the game:

```
dotnet run --project tools/pdv-nord-offer-author            # writes + backup
dotnet run --project tools/pdv-nord-offer-author -- --check # must be PASS
node tools/pdv_verify.mjs                                   # FAIL=0
```

Until that write lands, an Old Ways Arkay offer would show a NULL message
(no offer box) -- the eligibility change is live in script, so do not smoke
Orkey before the ESP write is in.

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

Dibella lane:
7. "Reset commitment state" on Arkay (or continue on a second save).
8. Repeat steps 1-5 with Dibella. EXPECT: offer "Dibella's Recognition";
   all surfaces show "Dibella" (no rename in either baseline).

Cross-baseline check:
9. On a Nine Divines Nord save, Arkay must still offer as "Arkay's Covenant"
   and display "Arkay" everywhere.

Proof boundary: everything above the smoke section is machine/readback proof
only; no beta-feel or in-game claim is made until the owner smoke passes.
