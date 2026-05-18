# PDV Hook Surface Catalog

**Status:** Living reference - first xEdit/PSC-backed pass
**Purpose:** One build-facing index of the hook types PDV can use for deity reactions in Skyrim SE.

This is not a deity design matrix. It answers a narrower implementation question:
where can the game tell us that something happened, and how suitable is that
surface for god reaction scoring?

## Evidence Used

- Local Mutagen/xEdit-style scan of `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Skyrim.esm` and `Update.esm`.
- Local shipped Papyrus source under `D:\Wabbajack\modlists\Anvil\Stock Game\Data\Source\Scripts`.
- Local SKSE source under `D:\Wabbajack\modlists\Anvil\mods\SKSE Script Sources - Compile Only\scripts\source`.
- Local PO3 Papyrus Extender source under `D:\Wabbajack\modlists\Anvil\mods\powerofthree's Papyrus Extender\Source\scripts`.
- Public PO3 Papyrus Extender API references in Papyrus Index and the powerof3 wiki.
- CK Wiki and UESP pages listed in the source notes below.

## Highest-Confidence Hook Families

| Hook family | Layer | Best PDV use | Avoid using it for | Build posture |
|---|---|---|---|---|
| Story Manager `SMEN` -> quest `OnStory...` | Vanilla CK + quest script | Global player events: kills, crimes, location changes, crafting, skill milestones, script events | Per-frame behavior, generic spam, raw piety writes | Primary event spine. Use `Shares Event`; route through EventBus/manager. |
| Player `ReferenceAlias` events | Vanilla Papyrus alias | Sleep/load/equip/location/vampire/werewolf/bow-shot/player-bound events | Broad world events already covered by Story Manager | Primary alias-side ingress. Keep one player alias surface per feature cluster. |
| Custom activators and object refs | Vanilla Papyrus object scripts | Shrines, offerings, ritual stations, trigger volumes, books, scripted containers | Generic interaction telemetry | Use for authored devotional acts and custom ritual UX. |
| Active magic effects | Vanilla Papyrus effect scripts | Blessing/neglect lifecycle, cloak-style watches, disease/curse observers | Permanent global telemetry when a quest/alias can do it cleaner | Good for effect-local state, not the central event bus. |
| CK conditions | CK condition system | Passive gates for spells/dialogue/perks: globals, factions, keywords, location, stage, actor values | Persistent source of truth | Read-only bridge layer. Use globals/FormLists as mirrors. |
| Quest stages/fragments/dialogue fragments | Vanilla CK + Papyrus | Curated quest/faction/deity moral choices | Replacing broad events already captured elsewhere | Best for explicit theological choices. Emit `Script Event` or call PDV APIs. |
| Timed update / dawn audit | Vanilla Papyrus registration | Daily consolidation, decay, caps, slow audits | Detecting frequent actions | Use sparingly. PDV already wants dawn consolidation. |
| SKSE generic registrations | SKSE source | Debug/MCM integration, crosshair/menu/key/control, mod events | Hidden deity scoring based on UI or keys | Optional support layer; usually not lore-facing. |
| PO3 Papyrus Extender events | SKSE plugin source | Rich hooks: book read, item harvested, spell learned, quest stage, weather, dragon soul, shout attack | Keyword/NPC/classification distribution | Accepted runtime dependency for selected event hooks. Keep behind capability checks and anti-farm rules. |
| External mod events/APIs | SKSE ModEvent, plugin APIs | Compatibility bridges with religion/survival/needs mods | Core PDV truth | Optional integration adapters only. |

## Complete Story Manager Surface

The build table is `references/vanilla-gameplay/story/story-manager-events.csv`.

Local master scan found 24 `SMEN` root event records in `Skyrim.esm`:

`ActorDialogueEvent`, `ActorHelloEvent`, `ArrestEvent`, `AssaultActorEvent`,
`Bribe`, `CastMagicEvent`, `ChangeLocationEvent`, `ChangeRelationshipRank`,
`CraftItem`, `CrimeGoldEvent`, `DeadBody`, `EscapeJail`, `Flatter`,
`IncreaseLevel`, `Intimidate`, `JailEvent`, `KillActorEvent`, `LockPick`,
`NewVoicePower`, `PlayerActivateActor`, `PlayerAddItem`, `PlayerRemoveItem`,
`ScriptEvent`, and `SkillIncrease`.

`Quest.psc` also exposes `OnStoryPayFine`, `OnStoryCure`,
`OnStoryInfection`, `OnStoryPlayerGetsFavor`, `OnStoryServedTime`, and
`OnStoryTrespass`, but the local `Skyrim.esm`/`Update.esm` scan did not find
matching root `SMEN` records. Treat those as "prove before build" hooks.

UESP's SMEN format reference lists a `QSTR` Quest Start event type code, but
local `Quest.psc` did not expose an obvious `OnStoryQuestStart` receiver. Treat
quest stages and `Script Event` as the safe quest-milestone path.

The CK Wiki lists `PickPocket Event`, but local `Quest.psc`, the local `SMEN`
scan, and the UESP event-code table did not expose a matching receiver/code in
this setup. Treat pickpocket design as unproven; use crime, item, faction, or
curated script events until xEdit/CK proves a clean receiver path.

## Player ReferenceAlias Hooks

A player alias can receive the vanilla alias/ref/actor event surface. The most
PDV-relevant ones are:

| Event group | Events | PDV use |
|---|---|---|
| Load and time | `OnPlayerLoadGame`, `OnUpdate`, `OnUpdateGameTime`, `OnSleepStart`, `OnSleepStop` | Registration repair, dawn-style audits, rest/sleep observance. |
| Location and travel | `OnLocationChange`, `OnPlayerFastTravelEnd`, cell attach/load/detach events | Sacred places, pilgrimage, exile, fast-travel-sensitive practices. |
| Equipment and magic | `OnObjectEquipped`, `OnObjectUnequipped`, `OnSpellCast`, `OnMagicEffectApply`, `OnWardHit` | Amulets, taboo gear, magic-school behavior, ward/protection signals. |
| Combat/player body | `OnHit`, `OnCombatStateChanged`, `OnDeath`, `OnDying`, `OnEnterBleedout`, `OnPlayerBowShot` | Combat context, survival/mercy moments, archery/hunting signals. |
| Race/curse state | `OnRaceSwitchComplete`, `OnLycanthropyStateChanged`, `OnVampirismStateChanged`, `OnVampireFeed` | Werewolf/vampire overlays, origin safety, curse-state transitions. |
| Interaction/inventory | `OnActivate`, `OnItemAdded`, `OnItemRemoved`, `OnRead`, `OnSell`, lock/open/close events | Offerings, sacred texts, shrine/ritual objects, sale/donation signals. |
| Furniture/packages | `OnSit`, `OnGetUp`, `OnPackageStart`, `OnPackageChange`, `OnPackageEnd` | Low priority for player religion; more useful for NPC scenes or custom rituals. |

Use this surface when the event is naturally about the player actor or a
specific aliased reference. Do not turn it into a replacement for Story Manager
when Skyrim already emits a global event.

## Object, Shrine, Offering, and Ritual Hooks

Custom activators and object-reference scripts are the clean route for authored
PDV behavior:

- Shrine activation and commitment prompts.
- Offering containers or altar drop-off scripts.
- Books, notes, and sacred-text `OnRead` moments.
- Trigger volumes for holy places, pilgrimage thresholds, or taboo spaces.
- Furniture or idle-marker rituals where the player intentionally performs an act.

These hooks are high quality because PDV controls their meaning. They are also
easy to cap with StorageUtil markers such as per-deity/day, per-location/day, or
one-shot quest-state flags.

## Passive Condition Hooks

CK conditions are not capture hooks, but they are crucial reaction hooks. They
can gate blessings, dialogue, spells, perks, and privileges from readable state:

- Globals: active patron mirrors, patron state, origin, debug flags.
- Factions/ranks: guild, civil war, Blood-Kin, Vigilants, Thalmor, temple groups.
- Keywords: worn gear, locations, actors, magic effects, item categories.
- Quests: stage, stage-done, completed state.
- Crime: hold bounty and violent/nonviolent crime gold.
- Actor state: health/magicka/stamina percent, combat, sneaking, hostility.

PDV rule: conditions should read mirrors and classifications; they should not be
the source of truth for piety.

## SKSE and PO3 Hooks

SKSE base events add:

- `OnKeyDown`, `OnKeyUp`, `OnControlDown`, `OnControlUp`.
- `OnMenuOpen`, `OnMenuClose`.
- `OnCrosshairRefChange`.
- `OnActorAction`.
- `OnPlayerCameraState`.
- `OnNiNodeUpdate`.
- custom `ModEvent` send/register callbacks.

Those are mostly UI/debug/integration hooks. They should not become core hidden
religion scoring unless a design explicitly needs them.

PO3 Papyrus Extender adds a much richer event surface. Public PO3 references
expose this through `PO3_Events_Form`, `PO3_Events_Alias`, and
`PO3_Events_AME`; Anvil's installed source is only the local compile/dev
confirmation copy, not the portability target.

This is now the accepted expansion path for selected god reactions such as
Julianos learning spells, Hermaeus Mora reading books, Hircine hunting, Kyne
weather, Talos shouts, Arkay resurrection/necromancy, and Zenithar/Orc labor.
The dependency tradeoff is acknowledged in the architecture: PO3 is a real
runtime requirement for event hooks, while keyword/NPC/classification
distribution stays with the offline patcher.

### PO3 Event Hook Catalog

Default PDV receiver posture: use the player alias when the event is naturally
player-centered; use a persistent service quest/Form receiver for global
whitelisted events; use ActiveMagicEffect receivers only for effect-local
watchers. Every promoted hook still routes through `PDV_EventBus` and writes
scratch piety only.

| PO3 hook | Callback payload | Best PDV use | Guardrail |
|---|---|---|---|
| `ActorFallLongDistance` | actor, fall distance, fall damage | Ordeal, survival, mercy, punishment, mountain/pilgrimage signals | Score only meaningful player falls or protected targets; cap heavily. |
| `ActorKilled` | victim, killer | Backup/compat kill observation where Story Manager is too thin | Avoid double-scoring with `KillActorEvent`; prefer existing kill router first. |
| `ActorReanimateStart` / `ActorReanimateStop` | target, caster | Necromancy, Arkay, Mannimarco-style taboo, undead control | Transition-only; require player caster or curated target. |
| `ActorResurrected` | target, reset-inventory flag | Arkay boundary violations, Daedric miracles, scripted resurrection recognition | Script/console can fire this; whitelist real gameplay contexts. |
| `BookRead` | book form | Sacred texts, forbidden knowledge, ancestral records, spellbook-adjacent learning | One-shot per book or curated book family. |
| `CellFullyLoaded` | cell | Repair registration, sacred-place context validation, custom ritual cell readiness | Exteriors can fire repeatedly; not a scoring hook by itself. |
| `CriticalHit` | aggressor, weapon, sneak-hit flag | Martial prowess, hunt prowess, ambush honor/dishonor | Player-only and context-filtered; no raw combat farming. |
| `Disarmed` | source actor, weapon | Malacath/Boethiah style dominance, Redguard martial moments | Rare/contextual favor hook, not routine piety. |
| `DragonSoulGained` | soul count | Dragonborn/Talos/Akatosh/Kyne recognition | Main-story scale; score sparingly and visibly. |
| `OnPlayerFastTravelEnd` | travel game-time hours | Pilgrimage audits, travel rhythm, sacred-place arrival repair | Avoid punishing ordinary fast travel; use mostly for context repair. |
| `FastTravelConfirmed` / `FastTravelPrompt` | marker reference | Optional pre/post fast-travel ritual or pilgrimage UX | Do not create chore popups for normal map use. |
| `OnEnterFurniture` / `OnExitFurniture` | furniture reference | Prayer mats, beds, crafting stations, ritual furniture | Prefer custom furniture/FormLists; avoid broad sit/stand telemetry. |
| `HitEventEx` | aggressor, source, projectile, power/sneak/bash/block flags | Filtered combat style: blocks, bashes, sneak attacks, weapon families | Use narrow filters and cooldowns; never open-ended hit spam. |
| `ItemCrafted` | bench, location, created item | Malacath craft-as-prayer, Zenithar labor, Bosmer taboo, offering creation | Whitelist item families; value/quality bands; no dagger-loop scoring. |
| `ItemHarvested` | produce form | Bosmer Green Pact friction, Kyne/Kynareth nature, alchemy/foraging signals | Whitelist produce and contexts; separate taboo from normal gathering. |
| `LevelIncrease` | new level | Long-horizon growth, discipline, patron milestone feedback | Milestone only; not a substitute for skill or action rubrics. |
| `LocationDiscovery` | region name, worldspace name | Pilgrimage, exile, wilderness, city exclusion/arrival moments | One-shot per location/region family; map discovery can be broad. |
| `ObjectGrab` / `ObjectRelease` | object reference | Handling ritual objects, offerings, grave goods, taboo manipulation | PO3 notes limitations; use custom objects where reliability matters. |
| `ObjectLoaded` / `ObjectUnloaded` | reference, form type | Late repair, compatibility discovery, watching specific object classes | PO3 docs flag inconsistency; support/repair hook, not scoring. |
| `ObjectPoisoned` | object, poison, dose | Mephala/Nocturnal/Boethiah poison signals, poison taboo, assassin paths | Require meaningful target/use context before piety. |
| `QuestStart` / `QuestStop` | quest | Faction, Daedric, civil, temple, and crisis arc recognition | Curated quest whitelist only. |
| `QuestStageChange` | quest, new stage | Theological choices, faction allegiance, repentance, betrayal | Curated stage table; one-shot markers per stage. |
| `ShoutAttack` | shout | Talos, Kyne, Tongues, Dragonborn identity | Player-only; cooldown and context gate. Verify callback name against installed PO3 source. |
| `SkillIncrease` | skill actor-value int | Discipline, magical study, craft mastery thresholding | Milestone bands only; no raw skill-XP religion. |
| `SoulTrapped` | victim, killer | Arkay taboo, Molag Bal, necromancy, black-soul ethics | PO3 notes bypass risk with some mods; require player involvement. |
| `SpellLearned` | spell | Julianos, Hermaeus Mora, Xarxes/Auri-El, Altmer study | One-shot per spell or school tier. |
| `WeatherChange` | old weather, new weather | Kyne/Kynareth/Khenarthi, storm rites, pilgrimage weather context | Environmental context or rare favor trigger; not repeated piety. |
| `MagicEffectApplyEx` | caster, magic effect, source, applied flag | Curse/disease/blessing detection, filtered necromancy, school/domain effects | Always use filters/FormLists; do not mirror every magic apply. |
| `WeaponHit` | target, source, projectile, hit-flag mask | Weapon-family rites, bash/block/power/sneak/fatal moments | Decode flags carefully; target/context filters required. |
| `MagicHit` | target, source, projectile | Spell impact by source/projectile, offensive magic context | Filter by spell/effect/domain and target type. |
| `ProjectileHit` | target, source, projectile | Archery/hunting, Hircine, Bosmer/Redguard martial practice | Validate target and hunt context; avoid target-dummy loops. |

PO3 also exposes matching register/unregister functions for these event families.
The exact receiver parameter is script-family specific (`Form`, `Alias` /
`ReferenceAlias`, or `ActiveMagicEffect`). Before implementation, copy the
matching installed `.psc` signature into the phase plan and compile a small
receiver proof.

## Recommended PDV Build Order

1. Finish the vanilla spine first: Story Manager receivers, player alias, custom
   shrine/ritual activators, condition mirrors, dawn audit.
2. Prove the `papyrus_event_no_local_smen` Story Manager rows in CK/xEdit before
   designing around them.
3. Add a deity-signal matrix that references hook families, not raw events.
4. Promote selected PO3 events into the hook index with capability checks and
   anti-farm rules; do not treat the full PO3 surface as automatically scoreable.

## Source Notes

- CK Wiki `SM Event Node`: event list, quest-node behavior, and `Shares Event`
  compatibility warning.
- CK Wiki `Category:Story Manager`: event data and quest-start behavior.
- UESP `Skyrim Mod:Mod File Format/SMEN`: `SMEN` fields and event type codes.
- CK Wiki `Form Script` and local `Alias.psc`: registration-based events.
- CK Wiki `ActiveMagicEffect Script`: effect lifecycle, registered events, and
  inherited actor/ref events.
- Papyrus Index `powerofthree's Papyrus Extender`: public script inventory for
  `PO3_Events_Form`, `PO3_Events_Alias`, `PO3_Events_AME`, and
  `PO3_SKSEFunctions`.
- powerof3 `PapyrusExtenderSSE` wiki: public event notes and callback caveats.
