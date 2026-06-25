# PDV Phase 21 - Authoria / ARR Compatibility Handoff

Status: trusted-tester package evidence; ARR quest backend runtime pass; shrine-prayer route/top-left/Book of Days pass; Prisma overlay toast deferred; author acceptance pending.
Date: 2026-06-25 refresh of the 2026-06-14 handoff.

This is a technical handoff for Authoria / ARR integration testing. It is not a
public support claim and not maintainer approval.

## Package Contents

- Use the current `Devotion.esp` from the Devotion mod.
- Disable the Archon religion layer listed below.
- Load `Devotion.esp` after Requiem inputs and before
  `Requiem for the Indifferent.esp`.
- Re-run the Reqtificator after placement. Treat any RFTI output from local
  testing as a reference snapshot only; the list author should regenerate it.
- The shrine-replacement slice itself still lives in `Devotion.esp`: after the
  Archon removal set is disabled, Devotion owns the cure-only shrine spell
  overrides.
- The current trusted-tester add-on does ship
  `PDV_AuthoriaARR_Compatibility.esp` for the separate shrine-prayer feature:
  11 Daedric shrine-prayer ACTIs plus a Base Object Swapper file that makes the
  decorative `man_DaedricShrines` statues clickable. This plugin is loaded after
  `Devotion.esp` and is not a replacement for the core shrine spell overrides.

## Archon Removal Set

Disable these 15 plugins for the PDV test package:

| Plugin | Role |
|---|---|
| `Archon.esp` | core religion overhaul |
| `Archon - Vigilant.esp` | quest-mod bridge |
| `Archon - BDS.esp` | quest-mod bridge |
| `Archon - Mandra Shrines.esp` | Daedric shrine content bridge |
| `Archon - Wyrmstooth.esp` | quest-mod bridge |
| `Archon - HOHQE.esp` | House of Horrors QE bridge |
| `Archon - TG Alt Endings.esp` | Thieves Guild bridge |
| `Archon - TOCQE.esp` | The Only Cure QE bridge |
| `Archon - TWDQE.esp` | The Whispering Door QE bridge |
| `Archon - Markarth Entrance and Farm Overhaul.esp` | worldspace bridge |
| `Archon - Lux Via.esp` | Lux Via bridge |
| `Lux - Archon.esp` | Lux bridge |
| `Lux - Archon - Mandra Shrines.esp` | Lux/Mandra bridge |
| `Authoria - Master Patch - Archon.esp` | Authoria consolidation |
| `Authoria - Papyrus - Missing Properties - Archon Fix.esp` | Archon script-property fix |

The earlier dossier count said 16, but the live ARR profile and the dossier
table resolve to 15 active Archon-family plugins.

## Readback Evidence

Local ARR test profile changes were backed up under:

`D:\Wabbajack\modlists\ARR\profiles\Authoria - Requiem Reforged - Main Profile\pdv-authoria-backups`

Backup stamp: `20260614-224145`.

Local test install:

- `D:\Wabbajack\modlists\ARR\mods\Devotion - PlayerDevotion Local Test`
- junction target: `D:\Wabbajack\modlists\Anvil\mods\Devotion`
- `Devotion.esp` active before `Requiem for the Indifferent.esp`

houseCARL readback after disabling Archon and activating PDV:

- `Devotion.esp` is active.
- `Archon.esp` and `Archon - Mandra Shrines.esp` are inactive.
- All 14 shrine blessing spell targets resolve to
  `Devotion.esp`.
- The three Dragonborn Good Daedra altar spells resolve to the PDV cure effect
  `071554:Devotion.esp`, carrying
  `PDV_DunmerShrinePrayerEffect`.

## Smoke Checklist

Run on a disposable ARR test save:

1. Start game and confirm no missing masters or startup crash.
2. Open the MCM/status surface.
3. Activate representative Divine, Talos, Nocturnal, and Auriel shrines.
4. Confirm disease cure remains and vanilla stat boons do not remain in Active
   Effects.
5. As Dunmer, test the Solstheim Azura/Boethiah/Mephala altar route during a
   dawn or dusk window.
6. Confirm Papyrus log shows the Dunmer outdoor Good Daedra shrine route once
   and does not duplicate within the same window/day.
7. Trigger one non-shrine devotion action.
8. Run a dawn tick.
9. Save, reload, and recheck status/MCM.
10. Confirm Papyrus log has no new PDV errors.

## Devotion Extension Channel (new - machine-validated, partial runtime pass)

Beyond the shrine-replacement slice, PDV now adds a second quest-reaction channel
that lights up devotion signals from the list's own content: Vigilant, Glenmoril,
Unslaad, Olenveld, ForgottenCity, SEC Saints & Seducers, DAc0da, and the Ebony
Blade curse - 24 reaction cells / 22 quest keys / 20 watched quests / 24 faucet
acts, keyed by FormID+stage so they no-op cleanly for anyone missing that
content. The vanilla-FormID QE stages (House of Horrors, The Only Cure) and the
Gray Cowl CC were promoted into the CORE matrix (6 cells, Tranche6, equity-audit
PASS) so all players with that content benefit, not only ARR.

Two deliverables:

- A Devotion build whose `PDV_PlayerEvents`/`PDV__ManagerQuest` carry a generic
  second-channel loader: it loads `PDV_QuestReactionMatrix_ARR` when present and
  behaves identically to base Devotion when absent. Both compile 0 errors / 0
  warnings; the core matrix and core `--check` are unchanged.
- `PDV_QuestReactionMatrix_ARR.json`, compiled from
  `references/authoring/PDV_QuestReactionMatrix_ARR.csv`, deployed under
  `SKSE/Plugins/StorageUtilData/PlayerDevotion/`.

Status: machine-validated (`pdv_quest_matrix_compile.mjs --matrix ... --check`
PASS, 24 cells / 22 keys / 20 quests / 24 faucet acts in the ARR channel, +6
promoted to core). On 2026-06-25, ARR `PDV Test` backend runtime smoke passed
for the `zzzAoMMqGoodEnd` stage-255 hook: matrix reload showed core 73 watched
quests and ARR channel 20 watched, then Papyrus logged Stendarr +12 and
`[PDV] QuestReaction: 5047158|255 applied 1 cells.` No front-end toast was
observed or required for that backend quest-reaction check; MCM/status/manual
visibility remains a separate acceptance bucket. Shrine-prayer runtime smoke on
2026-06-25 passed the clickable shrine route, top-left prayer line, and Book of
Days Chronicle entry. The Prisma overlay toast did not appear and is deferred to
the broader Prisma parity backlog; do not treat this handoff as full Prisma
surface parity. Author acceptance remains pending - see
`references/vanilla-gameplay/compatibility/PDV_Phase21_ARR_SmokeRunbook.md` and
the per-cell map in
`references/vanilla-gameplay/compatibility/PDV_Phase21_ARR_ExtensionMap.md`. Five
cells are flagged RUNTIME-VERIFY (terminal stage lacks a ShutDownStage flag).

Theology is unchanged: every hook maps to a deity/Prince PDV already covers; no
new gods. Promotion of the vanilla-FormID (QE) and CC (Gray Cowl) hooks into the
core matrix is held pending a deity gain/loss balance review.

## Deferred Follow-Up

- The direct per-Prince ARR Daedric shrine override scan remains superseded by
  the BOS-based add-on. The `man_DaedricShrines` family is STAT-based, so the
  current package ships a separate ACTI plugin plus BOS swaps instead of trying
  to replace those records in place.
- Survival systems remain context-only: SunHelm, Frostfall, and Campfire should
  inform eligibility/caps only, not raw piety gain.
- Curse theology remains Requiem-native for ARR. Future hooks should key off
  Requiem vampire/werewolf records and curated artifact/quest transitions.
