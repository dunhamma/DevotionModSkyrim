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
| Altmer | 3 | Pass | P | P | P | P | P | P | - | P | P | Current packet closed; final-world placement remains separate |
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
runtime/display proof is manual and is recorded in
`PDV_DaedricRuntimeEvidenceLedger.json` through
`tools/pdv_daedric_evidence_intake.mjs`. Final Daedric beta-display promotion
is gated by `tools/pdv_daedric_beta_gate.mjs`, which must fail until every
required runtime/display slot passes.

| Batch | Prince | Static D-18 | CAT-6 authored | Readback | Controlled sender | Runtime/display |
|-------|--------|-------------|----------------|----------|-------------------|-----------------|
| 0 | Azura / Azurah | P | P | P | C | - |
| 0 | Vaermina | P | P | P | C | - |
| 0 | Meridia | P | P | P | C | - |
| 0 | Molag Bal *(curse-access)* | P | P | P | C | - |
| 1 | Mephala / Mafala | P | P | P | C | - |
| 1 | Malacath / Mauloch | P | P | P | C | - |
| 2 | Mehrunes Dagon | P | P | P | C | - |
| 2 | Sheogorath | P | P | P | C | - |
| 2 | Namira / Namiira | P | P | P | C | - |
| 2 | Sanguine / Sangiin | P | P | P | C | - |
| 2 | Clavicus Vile | P | P | P | C | - |
| 2 | Hermaeus Mora | P | P | P | C | - |
| 2 | Nocturnal *(oath surface)* | P | P | P | C | - |
| 3 | Peryite *(tolerated)* | P | P | P | C | - |
| 3 | Hircine *(curse-access)* | P | P | P | C | C |

**2026-06-07 authoring evidence:** `tools/pdv-daedric-author --check` passes
for all sixteen Princes after direct framework authoring from
`PDV_DaedricPrinceRecordContracts.json`; all 15 generated non-Hircine
`PDV_DaedricPath_<Prince>` scripts compile cleanly. `pdv_content_verify`
remains `FAIL=0/WARN=0/PASS=1081`, strict Phase 20 race-costing remains
`PASS=2841/WARN=2/INFO=30`, and Phase 2 reward readback remains `PASS=1268`.

**2026-06-07 controlled sender evidence:** `PDV_MCM.psc` now has a Debug-page
`Daedric display proof` section backed by `PDV_FLST_DaedricPaths_All`: selected
Prince cycling, summary, reset, commitment signal, Seeker/Devoted/Champion
forcing, lapse, stigma, EventBus live-sender scaffold, and generic-source
silence probe. It also has a `Route all Princes` sweep that routes all sixteen
Prince EventBus sender cues plus the generic silence probe in one prompt.
`node .\tools\pdv_compile.mjs --script PDV__ManagerQuest
--script PDV_EventBus --script PDV_EventTypes --script PDV_EventSignalActivator
--script PDV_EventSignalEffect --script PDV_MCM` compiled the touched scripts
with 0 errors and 0 warnings.
`tools/pdv-daedric-author --check` now also readbacks
`PDV__ManagerQuest.PDV_FLST_DaedricPaths_All`; `tools/pdv-daedric-author`
also created and read back route-200 QASmoke sender refs for all 16 Princes and
route-201 `PDV_REFR_Daedric_GenericSilenceProbe_QASmoke`. The latest live ESP
write backed up to
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\PlayerDevotion_Framework.esp.20260607-191318.bak`.
`tools/pdv_daedric_runtime_check.mjs --self-test --strict-manager` passes for
the all-Prince route marker contract and should be run against `Papyrus.0.log`
after in-game activation.
Tester instructions live in `PDV_DaedricControlledProof_Runbook.md`.

**2026-06-07 exact organic sender placement:** `PDV_PlayerEvents.psc` now
registers sixteen Daedric-specific PO3 quest-stage FormLists and routes exact
stages into `PDV_EventBus.RouteDaedricPrinceSignal`: Boethiah `DA02` stage 100
-> index 0, Azura `DA01` stage 100 -> index 1, Vaermina `DA16` stage 190 ->
index 2, Meridia `DA09` stage 500 -> index 3, Molag Bal `DA10` stage 200 ->
index 4, Mephala `DA08` stage 60 -> index 5, Malacath `DA06` stage 200 ->
index 6, Mehrunes Dagon `DA07` stage 100 -> index 7, Sheogorath `DA15` stage
200 -> index 8, Namira `DA11` stage 100 -> index 9, Sanguine `DA14` stage
200 -> index 10, Clavicus Vile `DA03` stage 200 -> index 11, Hermaeus Mora
`DA04` stage 100 -> index 12, Nocturnal `TG09` stage 200 -> index 13,
Peryite `DA13` stage 100 -> index 14, and Hircine `DA05` stage 100 -> index
15. `tools/pdv-daedric-author --check` readbacks all sixteen
`PDV_FLST_Daedric_<Prince>LiveSources` FormLists, their exact `Skyrim.esm`
quest entries, and the matching `PDV_PlayerEvents` alias properties. The
latest live ESP write backed up to
`D:\Wabbajack\modlists\Anvil\mods\Devotion\Backups\daedric-princes\PlayerDevotion_Framework.esp.20260607-194539.bak`.
`tools/pdv_daedric_runtime_check.mjs --strict-manager` still accepts any
Prince-specific `eventbus_200_*` manager trace by default for broad route
checks. Counted live-source proof must use `--source organic`, which requires
the exact `eventbus_200_po3_queststage_daedric_*` manager marker so an MCM or
QASmoke controlled route cannot satisfy organic sender proof by accident.

**Remaining blocker:** no new in-game controlled/display proof was run yet.
All sixteen exact organic quest-stage sender references are
placed/readback-clean but still need runtime proof. Hircine keeps its earlier
Phase 13 curse-path runtime proof (`C` here) but still needs the same
display-stack proof as the rest of the Daedric roster. Curse-access Princes
(Molag Bal, Hircine) must not double-fire curse-state transitions - verify
against the race `CurseState` rows during runtime proof. The structured
runtime evidence ledger currently starts all sixteen Princes at pending; do not
promote these rows from `-` until the ledger has matching in-game entries and
`tools/pdv_daedric_beta_gate.mjs` passes.

**Historical note:** Before 2026-06-07, Batch 0 had static D-18 proof only and
no Prince had runtime/display proof.
