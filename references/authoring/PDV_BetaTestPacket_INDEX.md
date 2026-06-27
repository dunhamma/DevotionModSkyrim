# PDV Beta-Feel Testing Packets -- Index

Created: 2026-06-14
Owner: companion to `PDV_BetaFeelReleaseGate.md` (template + per-race proof
targets), `PDV_PreBetaRaceGateLedger.md` (verdicts), and
`PDV_AllRaceDaedricBetaReadinessLedger.md` (Daedric blockers).

This index routes the tester through the per-race + per-Prince in-game proof that
remains the last gate to a beta-feel release (Global Stop Condition 6: all 10
races + all 16 Skyrim-present Daedric Princes must carry runtime evidence). All
packets were refreshed to the 2026-06-14 consolidated build.

## Current tester entrypoints

Use the `PDV_RunSheet_<Race>_BetaFeel.md` files for the final pre-beta pass. The older
`PDV_BetaTestPacket_*` docs remain provenance/history and longer source notes, not the
primary walk-throughs.

| Race | Current sheet | State | Use now? |
|---|---|---|---|
| Altmer | `PDV_RunSheet_Altmer_BetaFeel.md` | compact regression; prior packet evidence recorded | yes, regression only |
| Argonian | `PDV_RunSheet_Argonian_BetaFeel.md` | compact regression; prior packet evidence recorded | yes, regression only |
| Bosmer | `PDV_RunSheet_Bosmer_BetaFeel.md` | compact regression; DA05 proof separated from QASmoke checker | yes, regression only |
| Breton | `PDV_RunSheet_Breton_BetaFeel.md` | full gap sheet; stack/feel and exposure edge remain important | yes |
| Dunmer | `PDV_RunSheet_Dunmer_BetaFeel.md` | full gap sheet; hand-assembled route/Survey/stack proof | yes |
| Imperial | `PDV_RunSheet_Imperial_BetaFeel.md` | full gap sheet; civic/Talos/Concordat plus Prisma | yes |
| Khajiit | `PDV_RunSheet_Khajiit_BetaFeel.md` | compact regression; gold packet evidence recorded | yes, regression only |
| Nord | `PDV_RunSheet_Nord_BetaFeel.md` | full gap sheet; includes neglect and Talos betrayal checks | yes |
| Orc | `PDV_RunSheet_Orc_BetaFeel.md` | full gap sheet; life-mode organic proof still open | yes |
| Redguard | `PDV_RunSheet_Redguard_BetaFeel.md` | detailed regression and Requiem-tail sheet | yes, regression/tuning |
| Daedric (16 Princes) | `PDV_DaedricInGameSmokePacket.md` | separate Prince runtime/display gate | yes, separate pass |

### How to read the sheet split

- **Full gap sheets:** Breton, Dunmer, Imperial, Nord, and Orc. These are the
  highest-value final runthroughs because one or more runtime/manual evidence
  slots are open, newly changed, or historically easy to confuse.
- **Compact regression sheets:** Altmer, Argonian, Bosmer, Khajiit, and Redguard.
  These do not reopen closed packet evidence; they prove that late changes did not
  regress route, Survey, stack, save/load, or Prisma behavior.
- **Daedric sheet:** keep separate. Race proof does not close Prince display proof.

### Pending and deferred route discipline

If a sheet labels a route `PENDING` or `DEFERRED`, do not turn that into an in-game
failure. It means the current repo does not expose a valid route surface for that
arm. Record the runnable evidence and bring back the missing-arm note.

### Explicitly NOT testable in V1 (no clean vanilla hook -- do not write steps)

- Altmer: arrest-Talos-worshipper, complete-Thalmor-mission, help-prisoner-escape.
- Imperial: help / refuse / report-Talos-worshipper, attack-Talos-worshipper.
- Orc: oath-break (route 74 is emitter-less); Witnessed-tranche manager behavior.
- Dunmer: Grey Quarter NPC whitelist.
- Breton: Knight's Road breach hooks (Thieves Guild / Dark Brotherhood / innocent-kill).

## Cross-cutting false-FAIL caveats (every packet)

These are the methods that trip a tester into a false FAIL. They are restated in
each packet's "Current-Build Refresh" section.

- **State inits ONLY on a NEW save / `coc qasmoke`.** Old saves keep stale
  gate/curse/life-mode state. Disable `Devotion - Living Deities Test` in MO2
  first.
- **Debug seeding is MCM-driven, not CallQuestFunction.** MCM Player page -> Developer
  Options -> Debug page. Standard `set` / `coc` are fine.
- **`coc` skips Story location-change triggers.** Bosmer Songs of the Green,
  Argonian Waters, and Dunmer outdoor Good-Daedra shrine need a load-door entry
  or fast-travel -- never `coc` straight into the cell. (Poll-based anchors like
  Eldergleam are the exception.)
- **`PDV_REFR_*Signal` proof objects are INVISIBLE, nameless activators.** Fire
  by RefID: read the 2-hex plugin prefix XX once off a NAMED blessing
  (`help "HoonDing" 0` -> the `SPEL:` FormID's first two hex digits), then
  `prid XX<refid>` + `activate player` (NOT bare `activate`). Never guess XX.
- **Bosmer neglect gate is piety <= 10** (not 25) + bottom-3-lowest; set the
  scoring deity Target piety to 0 to prove "The Path Goes Quiet".
- **Argonian bed-of-choice "Rooted Rest" gate is 12 returns** (not 3); seed the
  count via the debug seeder.
- **Kill-based beats score ONLY the player's own killing blow**
  (ATTR_DIRECT_PLAYER). NPC/environment kills are silent by design -- at a crowd
  fight an ally can steal the credit (Altmer kill-Thalmor-agent, Imperial
  kill-Thalmor-justiciar, and any feeding/transformation kill proof).

## New consolidated-build surfaces folded in

- **Neglect vanilla top-left fallback:** a neglected committed patron now prints
  `<Deity>'s regard fades as your devotion goes quiet.` even with the Prisma
  overlay off (D0). Folded into every race packet.
- **Survey "recent events" log:** Survey Devotion now lists the last few devotion
  beats in fiction voice -- confirm the just-fired beat appears with no route IDs
  or raw counters.
- **Khajiit Rajhin/Alkosh top-left notices + Prisma shift toasts** and the
  dawn-owned Champion presentation -- documented in the gold Khajiit packet.
- **Editorial Survey rewrite is a known, non-blocking gap:** several races still
  leak a raw enum or dev phrasing in Survey label builders (Bosmer
  `GetBosmerPathLabel`, Orc life-mode/code wording). These are slated for the
  all-race narrator-voice sweep and do NOT block beta-feel proof.

## Suggested run order

1. Run full gap sheets first: Orc, Breton, Dunmer, Imperial, Nord.
2. Run compact regression sheets: Altmer, Argonian, Bosmer, Khajiit, Redguard.
3. Run Daedric controlled/display proof from `PDV_DaedricInGameSmokePacket.md`.
4. After each race, capture the Papyrus log before rotation, then update the
   evidence ledger only from observed evidence.

After each sweep, run the relevant runtime checker before log rotation, fill the
matching ledger (`PDV_Phase20_ManualEvidenceLedger.json` for races,
`PDV_DaedricRuntimeEvidenceLedger.json` via `pdv_daedric_evidence_intake.mjs` for
Princes), and only then update verdicts in `PDV_PreBetaRaceGateLedger.md`.
