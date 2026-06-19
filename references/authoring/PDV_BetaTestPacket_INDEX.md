# PDV Beta-Feel Testing Packets -- Index

Created: 2026-06-14
Owner: companion to `PDV_BetaFeelReleaseGate.md` (template + per-race proof
targets), `PDV_PreBetaRaceGateLedger.md` (verdicts), and
`PDV_AllRaceDaedricBetaReadinessLedger.md` (Daedric blockers).

This index routes the tester through the per-race + per-Prince in-game proof that
remains the last gate to a beta-feel release (Global Stop Condition 6: all 10
races + all 16 Skyrim-present Daedric Princes must carry runtime evidence). All
packets were refreshed to the 2026-06-14 consolidated build.

## Run-readiness at a glance

| Packet | File | State | Run now? |
|---|---|---|---|
| Khajiit | `PDV_Khajiit_BetaFeelPacket.md` (gold) | **Pass** | done -- acceptance recorded |
| Bosmer | `PDV_BetaTestPacket_Bosmer.md` | ready | **YES** |
| Nord | `PDV_BetaTestPacket_Nord.md` | ready | **YES** |
| Argonian | `PDV_BetaTestPacket_Argonian.md` | ready | **YES** |
| Orc | `PDV_BetaTestPacket_Orc.md` | ready | **YES** |
| Breton | `PDV_BetaTestPacket_Breton.md` | ready (exposure lever) | **YES** |
| Daedric (16 Princes) | `PDV_DaedricBetaFeelPacket.md` | ready | **YES** |
| Altmer | `PDV_BetaTestPacket_Altmer.md` | part-runnable | partial -- see below |
| Imperial | `PDV_BetaTestPacket_Imperial.md` | part-runnable | partial -- see below |
| Dunmer | `PDV_BetaTestPacket_Dunmer.md` | part-runnable | partial -- see below |
| Redguard | `PDV_BetaTestPacket_Redguard.md` | done | packet PASS 2026-06-19 (8/8 dims) |

### Ready to run NOW (no dependency on the concurrent build pass)

Bosmer, Nord, Argonian, Orc, Breton, and the Daedric 16-Prince packet. These were
the user's priority -- they prove the consolidated pure-script build that already
landed (build-batch tests 2/3/4/6/7/8/9, the variety tranches, and the Daedric
pact model).

- **Khajiit is already Pass.** Use the gold-standard `PDV_Khajiit_BetaFeelPacket.md`
  as the acceptance record AND as the format template for everything else. The
  trimmed `PDV_BetaTestPacket_Khajiit.md` is now a 60-second book-route smoke
  only.

### Waits on the concurrent build pass (steps written, marked PENDING)

Altmer, Imperial, Dunmer. Each packet's refresh section has a runnable
NOW part (the pure-script build-batch lever) plus a PENDING part whose vanilla
emitters the concurrent build session is wiring this pass. Do NOT log a FAIL on a
PENDING step until the build session confirms the emitter landed.
(Redguard's beta-feel packet now PASSED 2026-06-19 -- 8/8 dimensions; only its
Dawnguard exact-stage Ash'abah source remains a deferred build item, tracked in
the table below, NOT a beta-feel blocker.)

| Race | Runnable NOW | PENDING build-pass confirmation |
|---|---|---|
| Altmer | Lorkhan adjacency penalty (test 5) | ThalmorAlignment actions: read-banned-texts -5, consort-with-Daedra -25, kill-Thalmor-agent -20 |
| Imperial | Vampire-rupture halt (test 1) | Concordat 8-action table: Stormcloak join -20 (CW01B), Talos Mistake book, hidden Talos shrine, kill-Thalmor-justiciar -10 |
| Dunmer | Ancestor-layer curse silence (test 2) | Outdoor Good-Daedra shrine -> twilight window; Layer-2 werewolf 0.75x runtime |
| Redguard | PACKET PASS 2026-06-19 (8/8 dims: sect no-flip, Far Shores token, vampire/werewolf curse cycle all proven) | Dawnguard-cure stage (DLC1VQ02) -> Ash'abah re-entry: source-fill still blocked (deferred build item, NOT a beta-feel blocker) |

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
- **Debug seeding is MCM-driven, NOT `cqf`.** MCM Player page -> Developer
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

1. The four NOW races (Bosmer, Nord, Argonian, Orc) + Breton -- highest value,
   no build-pass dependency.
2. The Daedric 16-Prince packet -- one MCM `Route all Princes` sweep + per-batch
   display proof closes the Daedric half of the gate fast.
3. The four in-flight races once the build session signals its emitters landed --
   run the NOW part anytime, the PENDING part after confirmation.

After each sweep, run the relevant runtime checker before log rotation, fill the
matching ledger (`PDV_Phase20_ManualEvidenceLedger.json` for races,
`PDV_DaedricRuntimeEvidenceLedger.json` via `pdv_daedric_evidence_intake.mjs` for
Princes), and only then update verdicts in `PDV_PreBetaRaceGateLedger.md`.
