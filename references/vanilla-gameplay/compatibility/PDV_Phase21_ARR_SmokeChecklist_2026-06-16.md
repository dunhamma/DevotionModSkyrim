# PDV Phase 21 -- ARR In-Game Smoke Checklist (2026-06-16)

Tickable run sheet for the updated Authoria/ARR package (compat patch +
extensibility + the 2026-06-15/16 shrine-prayer feedback and MCM reload button).
Companion to `PDV_Phase21_ARR_SmokeRunbook.md` (deploy detail) and
`PDV_Phase21_ARR_ExtensionMap.md` (cell table).

**Key change since the last run:** use the new **Reload quest matrix** MCM button
early -- it fixes the stale-cell drift that made The Only Cure (DA13) route but not
apply.

## Pre-flight (once)
- [ ] ARR profile: `Devotion.esp` active **before** Requiem; `PDV_AuthoriaARR_Compatibility.esp`
      enabled **after** Devotion.esp; `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini` in the mod `Data` root;
      po3 Base Object Swapper active.
- [ ] MCM -> Devotion dev page -> **Debug level = 2**.
- [ ] Papyrus logging on; log at `...\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`.
- [ ] Load a save fresh from the main menu (not a mid-session continue).

## Steps

- [ ] **1 -- Matrix channel loaded.** MCM -> Developer Options -> **Reload quest matrix**.
      Expect popup: *"Core: N watched. ARR channel: 20 watched."*
      (If ARR says "absent" -> `_ARR.json` not deployed. Run this before any quest test --
      it also forces current cell data into memory.)

- [ ] **2 -- Quest hook fires (easy win).** Drive one to its stage:
      - Olenveld `OlenveldBOTE` stage **80** -> +Arkay, or
      - Gray Cowl `ccBGSSSE020_Quest` stage **100** -> +Nocturnal.
      Expect log `[PDV] QuestReaction: <decimal>|<stage> applied N cells` + deity piety moves (Survey).

      **2026-06-25 backend PASS:** ARR `PDV Test` profile, Imperial disposable save.
      MCM reload showed **Core: 73 watched quests** and **ARR channel: 20 watched**.
      `setstage zzzAoMMqGoodEnd 255` produced:
      - `[PDV] AwardPiety: Stendarr raw 12.000000, applied 12.000000`
      - `[PDV] QuestReaction piety: Stendarr 12.000000 (Stendarr.show_mercy)`
      - `[PDV] QuestReaction: 5047158|255 applied 1 cells.`
      - `[PDV] EventBus: RouteQuestReaction complete: stage 255`
      No front-end toast was observed or required for this backend route check.
      MCM/status/manual visibility remains a separate acceptance bucket.

- [ ] **3 -- Re-test The Only Cure (prior failure).** After step 1's reload, replay **DA13 stage 102**.
      Expect `[PDV] QuestReaction piety: Stendarr +<n>`.
      (Peryite -milestone half may be silent if race stance for Peryite is taboo -- Stendarr is the tell.)

- [ ] **4 -- RUNTIME-VERIFY cells (confirm each fires).**
  - [ ] Vigilant Aetherius `1363DB` s255 -> Akatosh
  - [ ] Vigilant Archer of Kyne `1279A1` s255 -> Kyne
  - [ ] Vigilant Knight of Julianos `1265FB` s999 -> Julianos
  - [ ] Vigilant Knight of Zenithar `1306FA` s999 -> Zenithar
  - [ ] Glenmoril Azura `355287` s10 -> Azura

  (Any that don't fire = one-line CSV stage fix, no script change.)

- [ ] **5 -- Negative check.** A non-hooked quest stage applies nothing (no stray `[PDV] QuestReaction` line).

- [ ] **6 -- Shrine prayer (now with feedback).** Travel via load-door/fast-travel (**not** `coc`)
      to a man_ Daedric statue -> "Pray" prompt.
      - [ ] Top-left line: *"You offer a prayer at the shrine of \<Prince\>. \<Prince\> hears you."*
      - [ ] Book of Days records the shrine prayer in the Chronicle.
      - [ ] Log `[PDV] Daedric shrine prayer: +2 <Prince>` + Prince +2 (Survey).
      - [ ] Activate again same day -> **no** second award (once/day gate).
      - Covered (11): Azura, Vaermina, Molag Bal, Mephala, Mehrunes Dagon, Sheogorath,
        Namira, Sanguine, Hermaeus Mora, Hircine, Peryite. (Hircine passed 2026-06-15 -- pick a different one.)

- [ ] **7 -- Daedric artifact faucet (re-confirm).** Equip Masque of Clavicus Vile ->
      event 368 scores multiple deities. (Passed 2026-06-15; confirm still good after redeploy.)

## Report back
**2026-06-25 shrine-prayer frontend PASS / Prisma deferral:** ARR `PDV Test`
profile. Shrine click produced the top-left prayer line, and Book of Days
Chronicle displayed the shrine-prayer entry with the restored rolling-log
layout. The Prisma overlay toast did not appear. Treat that as deferred Prisma
parity work, not as a blocker for this ARR shrine-prayer route/backend smoke
slice.

- ARR channel "20 watched" in the reload popup? **PASS 2026-06-25, ARR PDV Test**
- Hooks that fired correct piety: **PASS 2026-06-25, `zzzAoMMqGoodEnd` s255 -> Stendarr +12 backend**
- RUNTIME-VERIFY stages that did NOT fire: __
- Shrine-prayer top-left line appeared? **PASS 2026-06-25, ARR PDV Test**
- Shrine-prayer Book of Days entry appeared? **PASS 2026-06-25, ARR PDV Test**
- Shrine-prayer Prisma overlay toast appeared? **FAIL/DEFERRED 2026-06-25, folded into Prisma parity backlog**
- Any Papyrus errors mentioning the matrix/loader: __

## Deploy note
Core `.pex` (ManagerQuest, MCM) reach the ARR test mod via the
`Devotion - PlayerDevotion Local Test` junction -> Anvil Devotion, so this session's
recompiles are already present. Only the ARR add-on files (`.esp`, `_SWAP.ini`,
`_ARR.json`) live separately in the ARR mod -- unchanged from last install, no redeploy
needed unless wiped.
