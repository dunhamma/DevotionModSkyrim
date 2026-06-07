# PDV Runtime Evidence Tracker

**Created:** 2026-06-07
**Purpose:** One consolidated, drive-able tracker for the runtime/manual evidence
that gates **Content-Feel Beta**. The static gate (compile 0/0, strict verify
PASS=2841, content PASS=1081, reward readback PASS=1268, prisma audit 11/11,
prisma roster parity FAIL=0) is closed. Everything below is the *remaining*
in-game work, none of which the static gate proves.

**Authority:** verdicts mirror
[PDV_PreBetaRaceGateLedger.md](PDV_PreBetaRaceGateLedger.md); evidence items follow
[PDV_PreBetaRaceAcceptanceRubric.md](PDV_PreBetaRaceAcceptanceRubric.md). Run the
walks with [PDV_InGameGodTestingPlan.md](PDV_InGameGodTestingPlan.md).

## Global stop conditions (do not claim beta-feel until all are met)

- Every race at `Pass` or scoped `Conditional` (with known issues + stop conditions written).
- All 16 Skyrim-present Daedric Princes through CAT-6 readback + runtime/display proof.
- No external race playfeel testing on a race still at `Fail`.

## Evidence legend

Each race needs all nine: **AS** accepted-source fires from real play · **WO**
wrong-origin silence · **GS** generic-source silence · **AF** anti-farm/repeat
cadence · **SC** Survey/status clarity in race language · **AE** reward SPEL in
Active Effects at tier · **SL** save/load sanity · **ST** stack snapshot (capped,
legible) · **FN** manual feel note. Mark `P` pass / `C` conditional / `F` fail /
`-` not started.

## Race rows

| Race | Idx | Verdict | AS | WO | GS | AF | SC | AE | SL | ST | FN | Next action |
|------|-----|---------|----|----|----|----|----|----|----|----|----|-------------|
| Altmer | 3 | Conditional | P | P | P | P | P | **-** | - | C | P | Capture `Altmer Orthodox Steadiness` Active-Effects / patron-tier snapshot → Pass |
| Khajiit | 6 | Conditional | P | P | P | C | P | **-** | - | C | P | Wire/approve one Baan Dar / Rajhin / Alkosh edge source, run edge packet |
| Nord | 0 | Fail | - | - | - | - | C | - | - | - | - | Dense-hook rejection + Hircine/Kyne/Talos stack; prove Old Ways book source |
| Imperial | 1 | Fail | - | - | - | - | C | - | - | - | - | Civic whitelist + faction/attendance rejection + public/private Talos edge |
| Breton | 2 | Fail | C | - | - | - | C | - | - | - | - | Tradition-track writes; Hidden Art cost; rejected spell/artifact loops |
| Bosmer | 4 | Fail | - | - | - | - | C | - | - | - | - | Prove 4 path contracts + generic commerce/theft/forest/kindness silence |
| Dunmer | 5 | Fail | - | - | - | - | C | - | - | - | - | Ancestor/Reclamation stack audit; deviation-price behavior; Survey display |
| Argonian | 7 | Fail | - | - | - | - | C | - | - | - | - | Hist/People floor; swim/sleep/murder rejection; Arkay death-rite; Survey |
| Orc | 8 | Fail | - | - | - | - | C | - | - | - | - | Stronghold/City/Legion parity; raw craft/combat/membership rejection |
| Redguard | 9 | Fail | - | - | - | - | C | - | - | - | - | Crown/Forebear/Ash'abah/Far Shores; fast-travel/undead rejection; HoonDing cap |

Per-race runtime marker check: `node .\tools\pdv_phase20_runtime_check.mjs --race <race>`.

## Daedric Prince rows (16; Jyggalag excluded)

Per-Prince bar (D-18): content rows ratified · `pdv_content_verify` clean · CAT-6
records authored + readback · runtime/display proof · race-stack legibility.
Authoring is Codex Workstream E
([PDV_DaedricPrinces_CodexWorkOrder.md](PDV_DaedricPrinces_CodexWorkOrder.md));
runtime/display proof is manual.

| Batch | Prince | Static D-18 | CAT-6 authored | Readback | Runtime/display |
|-------|--------|-------------|----------------|----------|-----------------|
| 0 | Azura / Azurah | P | - | - | - |
| 0 | Vaermina | P | - | - | - |
| 0 | Meridia | P | - | - | - |
| 0 | Molag Bal *(curse-access)* | P | - | - | - |
| 1 | Mephala / Mafala | draft | - | - | - |
| 1 | Malacath / Mauloch | draft | - | - | - |
| 2 | Mehrunes Dagon | draft | - | - | - |
| 2 | Sheogorath | draft | - | - | - |
| 2 | Namira / Namiira | draft | - | - | - |
| 2 | Sanguine / Sangiin | draft | - | - | - |
| 2 | Clavicus Vile | draft | - | - | - |
| 2 | Hermaeus Mora | draft | - | - | - |
| 2 | Nocturnal *(oath surface)* | draft | - | - | - |
| 3 | Peryite *(tolerated)* | draft | - | - | - |
| 3 | Hircine *(curse-access)* | draft | - | - | - |

**Note:** Batch 0 has static D-18 proof only; no Prince yet has runtime/display
proof. Curse-access Princes (Molag Bal, Hircine) must not double-fire curse-state
transitions — verify against the race `CurseState` rows during runtime proof.
