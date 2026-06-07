# PDV In-Game God Testing Plan

**Created:** 2026-06-07
**Mode:** Console-assisted, disposable-save, per-god runtime proof the user runs in
parallel with Claude (Prisma reconcile) and Codex (Daedric Princes) build work.
**Pattern source:** the proven [PDV_BetaTestPacket_Khajiit.md](PDV_BetaTestPacket_Khajiit.md).
**Records into:** [PDV_RuntimeEvidenceTracker.md](PDV_RuntimeEvidenceTracker.md).

This plan generates the runtime evidence that the static gate cannot: accepted
hooks firing from real play, wrong-origin/generic silence, anti-farm cadence,
Survey/status clarity, and the reward SPEL appearing in Active Effects.

## Setup (every session)

Use a **disposable save**. Open console with **~**.

```
set PDV_GLO_DebugLevel to 2
set PDV_GLO_OriginRace to <index>
```

### Confirmed origin-race index map

Source: [PDV_DeityBase.psc](file:///D:/Wabbajack/modlists/Anvil/mods/Devotion/Scripts/Source/PDV_DeityBase.psc) (`RACE_*` constants).

| Idx | Race | Idx | Race |
|-----|------|-----|------|
| 0 | Nord | 5 | Dunmer |
| 1 | Imperial | 6 | Khajiit |
| 2 | Breton | 7 | Argonian |
| 3 | Altmer | 8 | Orc |
| 4 | Bosmer | 9 | Redguard |

## The 5-step loop (per god / source)

1. **Accepted source** — `player.additem <FormID> 1`, then **read the book
   normally** from inventory (exact FormIDs live in each `PDV_BetaTestPacket_{Race}.md`
   preflight; Khajiit's are `0001B27D`, `0001AFF3`, `000F03E3`). Expect a top-left
   notification / proven toast — **not** a forced full Prisma panel, no blocked input.
2. **Survey read** — use **Survey Devotion**. Confirm it names the right god, in
   race language, and that the reading moved.
3. **Wrong-origin silence** — `set PDV_GLO_OriginRace to <other index>`, re-read the
   same source → **expect no movement** (no manager state, reward, or Survey change).
4. **Generic silence** — restore the correct index; do ordinary acts (generic kills,
   travel, theft, inn sleep, fast travel) → **expect no PDV movement**.
5. **Route-marker proof** — after closing Skyrim:
   ```powershell
   node .\tools\pdv_phase20_runtime_check.mjs --track p2-books --race <race> --strict-manager
   ```
   Expect the race's `Route…complete` marker (Khajiit:
   `RouteKhajiitLunarSubstrate complete: po3_book_khajiit_lunar`).

**Record per god:** AS / WO / GS / SC pass-fail, plus AE (reward in Active Effects
once piety ≥ Seeker 25) — copy verdicts into the runtime tracker.

## Testable NOW — approved live sources exist

Run the loop against each race's packet. Accepted/rejected hooks per
[PDV_PreBetaRaceGateLedger.md](PDV_PreBetaRaceGateLedger.md):

- **Khajiit (6)** — lunar substrate (Azurah/Khenarthi). *Conditional-pass; re-confirm.*
  Rejected: moon-sugar use, fast-travel loop, generic theft/combat, night stealth.
- **Altmer (3)** — Auri-El / Magnus / Xarxes books + the `MQ104` stage-160 Lorkhan
  beat. *Conditional-pass; the open item is the reward/Active-Effects snapshot — chase it.*
  Rejected: ordinary travel, generic spellcasting/combat, anti-Thalmor violence,
  repeated Dragonborn identity, vampire-power route.
- **Breton (2)** — Hidden Art books (the route that passed the 2026-06-04 runtime check).
  Rejected: casual tradition switching, generic spellcasting, generic Daedric artifact
  ownership, College membership, generic shrine visits.
- **Nord (0), Imperial (1), Dunmer (5), Bosmer (4), Redguard (9), Orc (8),
  Argonian (7)** — each has an approved book source in the current P2 tranche; pull
  the exact FormIDs from its `PDV_BetaTestPacket_{Race}.md` preflight. These sit at
  **Fail** only for lack of runtime evidence — your walk is what moves them to
  Pass/Conditional. Per-race rejected hooks are listed in the gate ledger.

## NOT yet testable — silence is the *correct* result

These have no approved live source yet; testing them now proves absence, not the
god. They become testable after source fills / Codex Workstream E lands. Use them as
**negative checks** — if any fires, that is a bug to report.

- **New Nord gods:** Shor, Tsun, Stuhn.
- **Edge focuses:** Baan Dar, Rajhin, Alkosh (Khajiit edge), and other per-race edge routes.
- **All 16 Daedric Princes:** until their records + sources exist, expect no Daedric movement.

## Prisma display spot-checks (free to do during any walk)

After the reconcile lands, confirm visually:
- A tier-up toast for a mapped Phase 2 deity shows the **correct glyph**, not the
  journal icon (note: the 17 deities in the glyph branch still show journal until
  `prisma-glyphs-phase2-deities` merges — that is expected).
- The panel "next at X" text reads the **25 / 50 / 85** thresholds, not 10 / 50 / 150,
  and the piety bar fills against Champion = 85.

## Evidence to bring back (per race)

```text
Race / index:
Accepted-source (AS): PASS/FAIL  (which source, route marker seen?)
Wrong-origin (WO):    PASS/FAIL
Generic silence (GS): PASS/FAIL
Anti-farm (AF):       PASS/FAIL
Survey clarity (SC):  PASS/FAIL
Reward in Active Effects (AE): PASS/PENDING/FAIL
Save/load (SL):       PASS/FAIL
Stack snapshot (ST):  PASS/FAIL  (effects stacked, capped?)
Feel note (FN):
Blocking notes:
```
