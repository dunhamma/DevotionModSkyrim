# Codex Handoff -- Day-to-Day Faucet: complete detection layer

**Created:** 2026-06-09 by Claude. **Owner from here:** Codex.
**Codex update 2026-06-09:** hybrid/no-duplicates source slice implemented and compile-proven. New Story Manager receiver scripts and router handlers exist; PO3-owned book/sleep/harvest/effect/item hooks route generic faucet events through EventBus. ESP receiver QUST shells, `PDV_Router` properties, generic faucet FormLists, router keyword/FormList properties, `PDV_PlayerEvents` alias properties, and six vanilla-rooted Story Manager `Shares Event` nodes are now readback-clean. The remaining CK/proof gate is Trespass because installed `Skyrim.esm` has no local `TrespassActorEvent` SMEN root.
**Supersedes** `PDV_CodexHandoff_RouterKeywords.md` (its task is Section 2 below).
**Why Codex:** primary coding agent + owns CK/Mutagen record authoring; avoids two agents editing
`PDV__ManagerQuest.psc` concurrently. Claude will stop editing shared files after this handoff.

Baseline = current compiled state (`pdv_verify.mjs` -> `FAIL=0`). Build on it; do not redo Section 1.

---

## 1. DONE (Claude) -- do not redo; these are your invariants

| Piece | Where | Note |
|---|---|---|
| Event vocabulary (IDs 300+) | `PDV_EventTypes.psc` | full block authored |
| Data-driven scoring | `PDV_DeityBase.ScoreFromTable(evt)` | reads `PDV.LD.<evt>.{D,C,O}`; ALL 29 thin-shell deities + Kyne/Talos/Shor delegate non-override events to it |
| Race-eligibility gate | `PDV_DeityBase.IsRaceNativeForPlayer()` (`stance==NATIVE`) | generic acts score ONLY race-native deities; in `ScoreFromTable` + Kyne/Talos/Shor overrides. **Preserve this.** |
| Anti-farm | `PDV_DeityBase.ScoreRepeatableAction(evt,delta,cap,cooldown)` | dawn-aligned day index; proven (Boethiah capped 3/day). **Preserve.** |
| Content table | `references/authoring/PDV_DeityLikesDislikes.csv` (32 deities, ~173 rows) | SOURCE OF TRUTH |
| Loader | `PDV__ManagerQuest.LoadRowsForDeity` (generated) + `EnsureLikesDislikesTable` (version-gated) | regenerate, never hand-edit (Section 6) |
| Stances | ESP VMAD (`tools/pdv-stance-author`) + runtime `ApplyStancesForDeity` | from `references/phase4/PDV_StanceMatrix.csv` |
| Dawn bank | `PDV__ManagerQuest.ProcessDawn` auto-fires ~06:00 | proven |
| Combat-by-victim | `PDV_ActionRouter.ClassifyKillVictim` emits 300/301/302 | needs Section 2 |

`PDV_EventBus.RouteActionWithAttribution` fans ANY event id to every deity's `ScoreAction` -- no
per-event scoring plumbing needed. Story Manager receivers reach `PDV_ActionRouter`, while already
registered PO3 player-alias hooks route their owned generic events directly through `PDV_EventBus`.

---

## 2. Router victim-type and generic faucet properties (CK Auto-Fill)

On the `PDV_ActionRouter` quest script, fill the existing victim keywords:
`ActorTypeUndead`, `ActorTypeDaedra`, `ActorTypeDragon`.

Also fill the new generic faucet properties: `PDV_FLST_FaucetSkillBooks`,
`PDV_FLST_FaucetSpellTomes`, `CraftingSmithingArmorTable`, `CraftingSmithingForge`,
`CraftingSmithingSharpeningWheel`, `CraftingSmithingSkyforge`, `CraftingCookpot`, `isAlchemy`,
and `isEnchanting`.

**Test:** kill a draugr -> `EventBus: Arkay event 300 ...`; dremora -> 301; dragon -> 302.

---

## 3. Non-kill receivers (scripts/handlers done; CK records remain)

Receiver scripts, router handlers, receiver QUST shells, and six source-ESP Story Manager quest
nodes are now authored and readback-clean. Each QUST is not Start Game Enabled, has the matching
script, and has `PDV_Router` set to `PDV_ActionRouter`. The six proven SMQN nodes use
**Shares Event** and point at their matching vanilla event roots. Remaining CK/proof work:
`PDV__SM_Trespass`, because no local vanilla `TrespassActorEvent` SMEN root was found.

### Event table

| Event(s) -> ID | SM node / OnStory event | Classifier logic |
|---|---|---|
| read-skill/spell/lore-book 340/341/342 | PO3 `OnBookRead(Book)` on `PDV_PlayerEvents` | `PDV_FLST_FaucetSkillBooks` -> 340; `PDV_FLST_FaucetSpellTomes` -> 341; otherwise -> 342. No vanilla `OnStoryBookRead`; no local `Book.GetSpell()`. |
| smith 330 / enchant 331 / brew 332 / cook 333 | Craft Item / `OnStoryCraftItem(...)` | branch on the bench keyword (`CraftingSmithing*`->330, `IsEnchanting`->331, alchemy->332, cookpot->333) |
| learn-word-of-power 343 | New Voice Power / `OnStoryNewVoicePower(...)` | direct -> 343 |
| increase-skill 344 | Increase Skill / `OnStoryIncreaseSkill(string)` | direct -> 344 |
| discover-location 345 | Change Location / `OnStoryChangeLocation(...)` | new-location guard -> 345 |
| pick-owned-lock 360 | Pick Lock / `OnStoryPickLock(...)` | owned -> 360 |
| trespass 361 | Trespass / (root still proof-gated) | direct -> 361 once a valid event root is proven |
| assault-innocent 364 | Assault Actor / `OnStoryAssaultActor(...)` | crime status > 0 + non-hostile victim -> 364 |

The local vanilla `Quest.psc` signatures were checked before authoring. Book read is deliberately
PO3-owned because this install has no vanilla `OnStoryBookRead`.

---

## 4. Murder / non-combat kills (303/304) -- source complete

`PDV_ActionRouter.HandleStoryKillActor` now preserves the hostile-kill path and adds a direct-player
non-hostile branch: non-hostile animals emit `303`; non-hostile NPC kills with `aiCrimeStatus > 0`
emit `304`.

---

## 5. MODERATE hooks (no clean SM node -- do after Section 3)

- heal-or-cure-npc 350: Restoration cast on a non-hostile target (MagicEffect/perk hook).
- steal-item 362: needs a reliable stolen-item hook; not part of this source slice.
- rest-under-open-sky 313 / sleep-in-bed 314: implemented in `PDV_PlayerEvents`.
- accept-daedric-artifact 368: implemented through `PDV_FLST_FaucetDaedricArtifacts` on `PDV_PlayerEvents`.
- raise-undead 365: implemented through `PDV_FLST_FaucetRaiseUndeadEffects` on `PDV_PlayerEvents`.

---

## 6. Discipline -- keep these in sync (do not hand-edit generated/derived state)

- **CSV changed** -> re-run `node tools/pdv_likesdislikes_gen.mjs`, replace `LoadRowsForDeity` body
  with its output, and **bump `LIKES_DISLIKES_VERSION`** (currently 3) so existing saves reload.
- **Stance matrix changed** -> re-run `tools/pdv-stance-author` (ESP) AND update
  `ApplyStancesForDeity` (runtime) AND bump `LIKES_DISLIKES_VERSION`. Stance vectors are duplicated
  in the C# tool and the Papyrus dispatch -- keep both equal to the CSV.
- **New event id** -> add to `PDV_EventTypes` AND any router-local constant that uses it.
- **Do NOT** weaken `IsRaceNativeForPlayer` (eligibility) or `ScoreRepeatableAction` (anti-farm).
- Compile with `node tools/pdv_compile.mjs` (now auto-discovers all `PDV_Deity_*`/`PDV_DaedricPath_*`).
  Treat warnings as failures. Verify `FAIL=0`.

## 7. Verify (per event)
DebugLevel 2: do the act -> `[PDV] EventBus: <deity> event <id> delta <x>`; DebugLevel 3 shows
anti-farm `blocked by daily cap`. Restart required after `.pex` changes (VMAD/property changes need a
new game OR the version-gated runtime migration pattern -- see `deity-stance-wiring` lesson).

## 8. Files changed across the handoff baseline
`PDV_DeityBase`, `PDV_EventTypes`, `PDV__ManagerQuest`, `PDV_Deity_Kyne/Talos/Shor`, all 29 thin-shell
`PDV_Deity_*` (stub->ScoreFromTable), `PDV_ActionRouter`; `tools/pdv_compile.mjs`,
new `tools/pdv-stance-author/`, new `tools/pdv_likesdislikes_gen.mjs`; `PDV_DeityLikesDislikes.csv`;
**`PlayerDevotion_Framework.esp`** (per-race stance VMAD; backup in `mods/Devotion/Backups/stance/`).
Reference docs: `PDV_DeityLikesDislikesMatrix.md`, `PDV_FaucetDetection_CKChecklist.md`.

Codex added/updated: `PDV_ActionRouter.psc`, `PDV_PlayerEvents.psc`, seven `PDV__SM_*` receiver
scripts, `tools/pdv_compile.mjs`, `tools/pdv_verify.mjs`, and generic faucet author/check modes in
`tools/pdv-phase20-p2-receiver-author`. Current machine proof from the Codex pass: targeted Papyrus
compile 0 errors / 0 warnings, helper readback checks PASS, six Story Manager node readbacks PASS,
`pdv_verify --json` = `PASS=2932, WARN=3, TODO=1, INFO=34`, strict phase 3 fails only the Trespass
root blocker, quest matrix compile check PASS, and quest matrix self-test PASS.
