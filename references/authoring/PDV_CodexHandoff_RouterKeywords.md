# Codex Handoff -- PDV_ActionRouter victim-type keyword wiring

**Created:** 2026-06-09 by Claude
**For:** Codex automation (Anvil MO2 MCP / Mutagen authoring tools)
**Type:** VMAD property fill on one existing quest -- no new records, no script changes.

---

## TL;DR

Fill three Keyword script properties on the `PDV_ActionRouter` quest so the router's new
victim-type kill classification (`kill-undead/daedra/dragon`) goes live. The `.psc` change is
already done and compiled; only the VMAD property links are missing.

| Quest EditorID | Script | Property (Keyword) | Target (Skyrim.esm keyword EditorID) |
|---|---|---|---|
| `PDV_ActionRouter` | `PDV_ActionRouter` | `ActorTypeUndead` | `ActorTypeUndead` |
| `PDV_ActionRouter` | `PDV_ActionRouter` | `ActorTypeDaedra` | `ActorTypeDaedra` |
| `PDV_ActionRouter` | `PDV_ActionRouter` | `ActorTypeDragon` | `ActorTypeDragon` |

Property names already match the vanilla keyword EditorIDs, so **CK Auto-Fill resolves them with
one click**, or resolve the FormKeys by EditorID from `Skyrim.esm` and set `ScriptObjectProperty`
links via Mutagen.

---

## Context (what Claude already changed -- do not redo)

- `PDV_ActionRouter.psc`: added `EVT_KILL_UNDEAD=300 / DAEDRA=301 / DRAGON=302`, the three
  `Keyword Property ActorType{Undead,Daedra,Dragon} Auto` declarations, and victim-type branches in
  `ClassifyKillVictim` (most-specific first). Compiled clean (`FAIL=0`). The `.pex` is current.
- The existing `ActorTypeNPC/Animal/Creature` properties on the same script are already filled
  (Auto-Fill precedent) -- mirror that for the three new ones.
- `PDV_EventBus.RouteActionWithAttribution` already fans any event id to every deity's
  `ScoreAction`, so 300/301/302 route with no further plumbing.
- The likes/dislikes table (`PDV_DeityLikesDislikes.csv` -> generated `LoadRowsForDeity` in
  `PDV__ManagerQuest`) already has the `kill-undead/daedra/dragon` rows for the relevant deities
  (Arkay, Stendarr, Meridia-future, Tu'whacca, Shor, Alkosh, Khenarthi, Trinimac, Malacath, ...).

## Execution options

**A. CK (manual or scripted):** open `PlayerDevotion_Framework.esp`, `PDV_ActionRouter` quest ->
Scripts -> `PDV_ActionRouter` -> Properties -> Auto-Fill All (or fill the 3 individually) -> save.

**B. Mutagen (preferred for automation):** model on `tools/pdv-stance-author/Program.cs` -- it already
opens the ESP, finds `PDV_ActionRouter` by EditorID, upserts `ScriptProperty` entries, and writes
with a backup. Add `ScriptObjectProperty` entries named `ActorType{Undead,Daedra,Dragon}` whose
`Object` link is the `Skyrim.esm` keyword of the same EditorID (resolve via the link cache).
Requires Skyrim/CK to release `PlayerDevotion_Framework.esp` first.

## Verify

1. Confirm the three properties on `PDV_ActionRouter` are non-null and point at the right keywords.
2. In-game (DebugLevel 2), kill a draugr/vampire -> expect
   `[PDV] EventBus: Arkay event 300 delta ...` (and other undead-liking deities), and the kill no
   longer routes event 2. Dremora -> event 301; dragon -> event 302.

## Coordination / conflict notes

- **Claude is actively editing `PDV__ManagerQuest.psc`** (loader, stance migration, version constant
  `LIKES_DISLIKES_VERSION`). If Codex also edits the manager, coordinate to avoid clobbering.
- `PlayerDevotion_Framework.esp` was just modified by Claude (per-race `Stance_<Race>` VMAD on all 32
  `PDV_Deity_*` quests, from `references/phase4/PDV_StanceMatrix.csv`, via `tools/pdv-stance-author`;
  backup in `mods/Devotion/Backups/stance/`). Any further ESP write should start from the current ESP.
- Observed (NOT Claude's edits): `PDV_PlayerEvents.psc` (mtime today) and `tools/pdv_quest_matrix_compile.mjs`
  (git-modified) changed from another source -- confirm whoever owns those before assuming state.

## Out of scope here (future, needs scripts first)

The non-kill receivers (Book Read / Craft Item / Pick Lock / Trespass / Increase Skill / New Voice
Power / Change Location / Assault) per `PDV_FaucetDetection_CKChecklist.md` Section 2 are NOT yet
ready for CK -- they need receiver `.psc` scripts + `PDV_ActionRouter.HandleStory*` handlers authored
first (Claude's next coding step). Do not create those QUSTs/SM nodes until the scripts exist.
