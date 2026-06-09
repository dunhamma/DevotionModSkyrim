# PDV Day-to-Day Faucet Detection CK Checklist

**Created:** 2026-06-09
**Updated:** 2026-06-09
**Status:** Papyrus source/PEX, ESP receiver QUST shells, generic faucet FormLists, router properties, player-alias properties, and **all seven** Story Manager `Shares Event` nodes are readback-clean. **Trespass RESOLVED 2026-06-10:** `TrespassActorEvent` is a valid engine event type (`StoryManagerEventNode.Types`); vanilla `Skyrim.esm` simply never created a root of that type, so the framework plugin now owns one (`PDV__SM_TrespassEvent` SMEN, `0714B1`, parented at the SM root `00005B`, mirroring `AssaultActorEvent`) with `PDV__SM_TrespassNode` (`0714B2`) attached via Shares Event. `pdv_verify --strict-phase3` = FAIL=0 / TODO=0.
**Companion:** `PDV_DeityLikesDislikesMatrix.md`, `PDV_DeityLikesDislikes.csv`, `PDV_CodexHandoff_FaucetDetection_Full.md`

The locked rule is **hybrid/no-duplicates**:

- `PDV_ActionRouter` and `PDV_EventBus.RouteActionWithAttribution` remain the generic 300+ likes/dislikes scoring path.
- Existing `PDV_PlayerEvents` PO3 alias hooks own events they already see cleanly: sleep `313/314`, harvest `334`, book read `340/341/342`, Daedric artifact `368`, and raise-undead effect `365` when their FormLists are wired.
- New Story Manager receivers are only for vanilla SM events that PO3 does not already own cleanly.
- Quest-reaction faucets remain separate curated-route scoring. Do not wire a second generic source for the same owner/event pair.

## 1. Compile-Proven Source

Implemented and compiled with 0 errors / 0 warnings:

- `PDV_ActionRouter.psc`
  - hostile kill routing preserved for `1/2/300/301/302`
  - non-hostile direct-player kill branch added for `303 kill-animal-noncombat` and `304 murder-defenseless`
  - Story Manager handlers added for craft item, new voice power, increase skill, change location, pick lock, trespass, and assault actor
  - craft classification uses CK-bound bench keywords
  - book classification helper uses FormLists; this local Papyrus source has no compile-visible `Book.GetSpell()`
- `PDV_PlayerEvents.psc`
  - sleep routes `313/314` after existing sleep substrate/curse routing
  - book read routes `340/341/342` through PO3 while preserving quest-reaction book faucets
  - harvest routes `334`
  - equipped Daedric artifacts and raise-undead MagicEffects route `368/365` when FormLists are wired
- New thin receiver scripts:
  - `PDV__SM_CraftItem`
  - `PDV__SM_NewVoicePower`
  - `PDV__SM_IncreaseSkill`
  - `PDV__SM_ChangeLocation`
  - `PDV__SM_PickLock`
  - `PDV__SM_Trespass`
  - `PDV__SM_AssaultActor`

## 2. Router Property Wiring

Readback status: complete. Automated by:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --author-generic-faucets
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-generic-faucets
```

Manual CK equivalent: open `PDV_ActionRouter` -> Scripts -> `PDV_ActionRouter` -> Properties.

Fill these existing kill classifier keywords:

- `ActorTypeUndead` -> `ActorTypeUndead`
- `ActorTypeDaedra` -> `ActorTypeDaedra`
- `ActorTypeDragon` -> `ActorTypeDragon`

Fill these new generic faucet properties:

- `PDV_FLST_FaucetSkillBooks` -> `PDV_FLST_FaucetSkillBooks`
- `PDV_FLST_FaucetSpellTomes` -> `PDV_FLST_FaucetSpellTomes`
- `CraftingSmithingArmorTable` -> `CraftingSmithingArmorTable`
- `CraftingSmithingForge` -> `CraftingSmithingForge`
- `CraftingSmithingSharpeningWheel` -> `CraftingSmithingSharpeningWheel`
- `CraftingSmithingSkyforge` -> `CraftingSmithingSkyforge`
- `CraftingCookpot` -> `CraftingCookpot`
- `isAlchemy` -> `isAlchemy`
- `isEnchanting` -> `isEnchanting`

## 3. Player Alias Property Wiring

Readback status: complete. The same `--author-generic-faucets` / `--check-generic-faucets` helper creates the four empty `PDV_FLST_Faucet*` FormLists and wires the alias properties.

Manual CK equivalent: open `PDV__ManagerQuest` -> `PDV_Player` alias -> `PDV_PlayerEvents` properties.

Fill:

- `PDV_FLST_FaucetSkillBooks` -> `PDV_FLST_FaucetSkillBooks`
- `PDV_FLST_FaucetSpellTomes` -> `PDV_FLST_FaucetSpellTomes`
- `PDV_FLST_FaucetDaedricArtifacts` -> `PDV_FLST_FaucetDaedricArtifacts`
- `PDV_FLST_FaucetRaiseUndeadEffects` -> `PDV_FLST_FaucetRaiseUndeadEffects`

Book routing rule:

- listed skill book -> `340`
- listed spell tome -> `341`
- otherwise PO3 book read -> `342`

This intentionally avoids `Book.GetSpell()` because it is not present in the local vanilla/SKSE compile surface.

## 4. Story Manager Receiver Records

QUST shell readback status: complete. Automated by:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --author-generic-faucet-receivers
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-generic-faucet-receivers
```

The helper creates/checks each QUST as **not Start Game Enabled**, attaches its matching script, and sets `PDV_Router` to `PDV_ActionRouter`.

| Receiver QUST | Event | Router event IDs |
|---|---|---|
| `PDV__SM_CraftItem` | Craft Item | `330/331/332/333` |
| `PDV__SM_NewVoicePower` | New Voice Power | `343` |
| `PDV__SM_IncreaseSkill` | Increase Skill | `344` |
| `PDV__SM_ChangeLocation` | Change Location | `345` |
| `PDV__SM_PickLock` | Pick Lock | `360` |
| `PDV__SM_Trespass` | Trespass | `361` |
| `PDV__SM_AssaultActor` | Assault Actor | `364` |

Story Manager node readback status: six complete, one blocked/proof-gated. Automated by:

```powershell
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --author-generic-faucet-story-manager
dotnet run --project .\tools\pdv-phase20-p2-receiver-author\PdvPhase20P2ReceiverAuthor.csproj -- --check-generic-faucet-story-manager
```

Readback-clean nodes:

- `PDV__SM_CraftItemNode` -> `PDV__SM_CraftItem`, parent `Skyrim.esm:039D86`, previous sibling `Skyrim.esm:04F593`
- `PDV__SM_NewVoicePowerNode` -> `PDV__SM_NewVoicePower`, parent `Skyrim.esm:02D389`, previous sibling `Skyrim.esm:02D38A`
- `PDV__SM_IncreaseSkillNode` -> `PDV__SM_IncreaseSkill`, parent `Skyrim.esm:02D386`, previous sibling `Skyrim.esm:02D387`
- `PDV__SM_ChangeLocationNode` -> `PDV__SM_ChangeLocation`, parent `Skyrim.esm:01320E`, previous sibling `Skyrim.esm:0A39C6`
- `PDV__SM_PickLockNode` -> `PDV__SM_PickLock`, parent `Skyrim.esm:05BD7B`, no previous sibling
- `PDV__SM_AssaultActorNode` -> `PDV__SM_AssaultActor`, parent `Skyrim.esm:02C494`, previous sibling `Skyrim.esm:0A39C0`

`PDV__SM_Trespass` — DONE 2026-06-10:

1. `TrespassActorEvent` confirmed a valid `StoryManagerEventNode.Types` enum value (Mutagen reflects the engine library), so the source-plugin SMEN root is safe to create.
2. `tools/pdv-phase20-p2-receiver-author --author-generic-faucet-story-manager` now creates `PDV__SM_TrespassEvent` (SMEN, Type=`TrespassActorEvent`, Parent=`00005B:Skyrim.esm`) and attaches `PDV__SM_TrespassNode` (SMQN, Parent=`0714B1`, **Shares Event**, Quest=`PDV__SM_Trespass`).
3. Player-identity filtering stays in the `PDV__SM_Trespass` fragment (matches the other six nodes — no node-level conditions), so the receiver routes `361` only for the player trespasser.
4. Readback-clean: `0714B1` SMEN + `0714B2` SMQN in `PlayerDevotion_Framework.esp`; `pdv_verify --strict-phase3` FAIL=0. ESP backup under `Backups\trespass\` + the tool's `Backups\phase20-p2-receivers\`.

No SEQ refresh is expected because these quests must not be Start Game Enabled. **Runtime proof still pending** (in-game: trespass a marked cell, expect `[PDV] EventBus: <deity> event 361 delta <x>`).

## 5. Verification Boundary

Machine proof currently covers source/PEX freshness, source-token route contracts, and readback when CK records exist.

Run:

```powershell
node .\tools\pdv_compile.mjs --script PDV_ActionRouter --script PDV_PlayerEvents --script PDV_EventBus --script PDV__SM_CraftItem --script PDV__SM_NewVoicePower --script PDV__SM_IncreaseSkill --script PDV__SM_ChangeLocation --script PDV__SM_PickLock --script PDV__SM_Trespass --script PDV__SM_AssaultActor
node .\tools\pdv_verify.mjs --json
node .\tools\pdv_quest_matrix_compile.mjs --check
node .\tools\pdv_quest_matrix_selftest.mjs
```

Default `pdv_verify --json` should show `FAIL=0`; as of this update it reports one TODO for Trespass because no local vanilla `TrespassActorEvent` SMEN root was found. `--strict-phase3` is the hard gate and should fail only that Trespass TODO until the root is proven/wired.

## 6. Runtime Smoke

Runtime proof remains manual/in-game proof, not verifier proof.

At DebugLevel 2, exercise:

- draugr, Dremora, dragon -> `300/301/302`
- non-hostile animal, criminal/non-hostile victim -> `303/304`
- smith, enchant, brew, cook -> `330-333`
- skill/spell/lore book -> `340/341/342`
- word wall, skill increase, new location -> `343/344/345`
- owned lock, trespass, assault innocent -> `360/361/364`
- sleep outside vs inside -> `313/314`

Expected positive marker:

```text
[PDV] EventBus: <deity> event <id> delta <x>
```

At DebugLevel 3, repeat capped acts to confirm same-day caps/anti-farm behavior where table rows define caps.
