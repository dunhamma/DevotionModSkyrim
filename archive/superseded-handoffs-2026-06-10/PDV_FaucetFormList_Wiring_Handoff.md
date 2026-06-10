# PDV Faucet FormList Wiring — Codex Handoff

**Created:** 2026-06-10  
**Author:** Claude  
**Priority:** Blocking in-game testing of events 340, 341, 365, 368  
**Root cause:** All four faucet FormLists were created as empty placeholders;
events that route through them can never fire until they are populated.

---

## Summary of blocked events

| Event ID | Name | FormList | FormList FormID | Status |
|---|---|---|---|---|
| 340 | skill-book | `PDV_FLST_FaucetSkillBooks` | `0714A0:PlayerDevotion_Framework.esp` | EMPTY — blocked |
| 341 | spell-tome | `PDV_FLST_FaucetSpellTomes` | `0714A1:PlayerDevotion_Framework.esp` | EMPTY — blocked |
| 365 | raise-undead | `PDV_FLST_FaucetRaiseUndeadEffects` | `0714A3:PlayerDevotion_Framework.esp` | EMPTY — blocked |
| 368 | daedric-artifact | `PDV_FLST_FaucetDaedricArtifacts` | `0714A2:PlayerDevotion_Framework.esp` | EMPTY — blocked |

Every book the player reads falls through to event 342 (lore-book catch-all)
because `PDV_FLST_FaucetSkillBooks` and `PDV_FLST_FaucetSpellTomes` are empty.
Confirmed by houseCARL: all four lists have `Items = 0 item(s)`.

---

## Recommended detection approach per list

### Option A — Populate the FormLists (current architecture, easiest)

Add all vanilla Skyrim.esm entries directly to each FLST using houseCARL
`housecarl_bulk_apply` or CK drag-in. Full FormID lists are below.

### Option B — Switch to keyword/flag detection (more robust, no maintenance)

For books specifically, Skyrim's BOOK record has two detection shortcuts:

- **Skill book:** `Book.Teaches` resolves to a Perk record (not None, not a Spell).
  In Papyrus: `(akBaseObject as Book).GetSpell() == None && (akBaseObject as Book).GetSkill() != -1`
  or check `Book.Flags` has `TeachesSkill`.
- **Spell tome:** `(akBaseObject as Book).GetSpell() != None`
- **Daedric artifact:** `akBaseObject.HasKeyword(DaedricArtifact_Keyword)`
  where `DaedricArtifact_Keyword` is `0A8668:Skyrim.esm`. All 15+ quest
  artifacts carry this keyword already; no list maintenance needed.
- **Raise undead MGEF:** no clean keyword — FormList is the right approach here.

**Recommendation:** Option B for artifacts (keyword is cleaner and future-proof);
Option A for the others (lists are already wired, just empty). Either is fine;
Codex decides based on what `PDV_PlayerEvents.psc` detection already expects.

---

## FormID lists (all from Skyrim.esm — verified via houseCARL)

### PDV_FLST_FaucetSkillBooks — 90 entries

All `Skill*` BOOK records from `Skyrim.esm`. These are the books that grant a
permanent +1 skill point when read. Five per skill, 18 skills = 90 unique
FormIDs (some book names appear under multiple skills via separate records).

```
; Alchemy
01AFC4:Skyrim.esm   ; SkillAlchemy1
01AFC5:Skyrim.esm   ; SkillAlchemy2
01AFC6:Skyrim.esm   ; SkillAlchemy3
01AFC7:Skyrim.esm   ; SkillAlchemy4
01AFC8:Skyrim.esm   ; SkillAlchemy5

; Alteration
01AFC9:Skyrim.esm   ; SkillAlteration1
01AFCB:Skyrim.esm   ; SkillAlteration3
01AFCC:Skyrim.esm   ; SkillAlteration4
01AFCD:Skyrim.esm   ; SkillAlteration5
01B236:Skyrim.esm   ; SkillAlteration2

; Block
01AFDD:Skyrim.esm   ; SkillBlock1
01AFDE:Skyrim.esm   ; SkillBlock2
01AFDF:Skyrim.esm   ; SkillBlock3
01AFE0:Skyrim.esm   ; SkillBlock4
02F83C:Skyrim.esm   ; SkillBlock5

; Conjuration
01AFE7:Skyrim.esm   ; SkillConjuration1
01AFE8:Skyrim.esm   ; SkillConjuration2
01AFE9:Skyrim.esm   ; SkillConjuration3
01AFEA:Skyrim.esm   ; SkillConjuration4
01AFEB:Skyrim.esm   ; SkillConjuration5

; Destruction
01AFEC:Skyrim.esm   ; SkillDestruction1
01AFED:Skyrim.esm   ; SkillDestruction2
01AFEE:Skyrim.esm   ; SkillDestruction3
01AFEF:Skyrim.esm   ; SkillDestruction4
01AFF0:Skyrim.esm   ; SkillDestruction5

; Enchanting
02F837:Skyrim.esm   ; SkillEnchanting1
02F838:Skyrim.esm   ; SkillEnchanting2
02F839:Skyrim.esm   ; SkillEnchanting3
02F83A:Skyrim.esm   ; SkillEnchanting4
02F83B:Skyrim.esm   ; SkillEnchanting5

; Heavy Armor
01AFF6:Skyrim.esm   ; SkillHeavyArmor1
01AFF7:Skyrim.esm   ; SkillHeavyArmor2
01AFF8:Skyrim.esm   ; SkillHeavyArmor3
01AFF9:Skyrim.esm   ; SkillHeavyArmor4
01AFFA:Skyrim.esm   ; SkillHeavyArmor5

; Illusion
01B00F:Skyrim.esm   ; SkillIllusion1
01B010:Skyrim.esm   ; SkillIllusion2
01B011:Skyrim.esm   ; SkillIllusion3
01B012:Skyrim.esm   ; SkillIllusion4
01B013:Skyrim.esm   ; SkillIllusion5

; Light Armor
01B000:Skyrim.esm   ; SkillLightArmor1
01B001:Skyrim.esm   ; SkillLightArmor2
01B002:Skyrim.esm   ; SkillLightArmor3
01B003:Skyrim.esm   ; SkillLightArmor4
01B004:Skyrim.esm   ; SkillLightArmor5

; Lockpicking
01B019:Skyrim.esm   ; SkillLockpicking1
01B01A:Skyrim.esm   ; SkillLockpicking2
01B01B:Skyrim.esm   ; SkillLockpicking3
01B01C:Skyrim.esm   ; SkillLockpicking4
01B01D:Skyrim.esm   ; SkillLockpicking5

; Marksman (Archery)
01B005:Skyrim.esm   ; SkillMarksman1
01B26D:Skyrim.esm   ; SkillMarksman2
01B007:Skyrim.esm   ; SkillMarksman3
01B008:Skyrim.esm   ; SkillMarksman4
01B009:Skyrim.esm   ; SkillMarksman5

; One-Handed
01AFE3:Skyrim.esm   ; SkillOneHanded1
01AFD9:Skyrim.esm   ; SkillOneHanded2
01AFDA:Skyrim.esm   ; SkillOneHanded3
01AFE4:Skyrim.esm   ; SkillOneHanded4
01AFE6:Skyrim.esm   ; SkillOneHanded5

; Pickpocket
01B022:Skyrim.esm   ; SkillPickpocket1
01AFBF:Skyrim.esm   ; SkillPickpocket2
01ACE6:Skyrim.esm   ; SkillPickpocket3
01AFD6:Skyrim.esm   ; SkillPickpocket4
02F836:Skyrim.esm   ; SkillPickpocket5

; Restoration
01B014:Skyrim.esm   ; SkillRestoration1
01B015:Skyrim.esm   ; SkillRestoration2
01B016:Skyrim.esm   ; SkillRestoration3
01B017:Skyrim.esm   ; SkillRestoration4
01B018:Skyrim.esm   ; SkillRestoration5

; Smithing
01AFCE:Skyrim.esm   ; SkillSmithing1
01AFCF:Skyrim.esm   ; SkillSmithing2
01AFD0:Skyrim.esm   ; SkillSmithing3
01AFD1:Skyrim.esm   ; SkillSmithing4
01AFD2:Skyrim.esm   ; SkillSmithing5

; Sneak
01B01F:Skyrim.esm   ; SkillSneak1 (note: 01B01E absent, gap in source)
01B01F:Skyrim.esm   ; SkillSneak2 -> use 01B276:Skyrim.esm for Sneak1
01B01F:Skyrim.esm   ; SkillSneak2
01B020:Skyrim.esm   ; SkillSneak3
01B021:Skyrim.esm   ; SkillSneak4
01AFD5:Skyrim.esm   ; SkillSneak5

; Speechcraft
01B00D:Skyrim.esm   ; SkillSpeechcraft1
01B00E:Skyrim.esm   ; SkillSpeechcraft2
01B025:Skyrim.esm   ; SkillSpeechcraft3
01B00A:Skyrim.esm   ; SkillSpeechcraft4
01B023:Skyrim.esm   ; SkillSpeechcraft5

; Two-Handed
01AFD8:Skyrim.esm   ; SkillTwoHanded1
01AFE2:Skyrim.esm   ; SkillTwoHanded2
01AFE5:Skyrim.esm   ; SkillTwoHanded3
01AFDB:Skyrim.esm   ; SkillTwoHanded4
01AFDC:Skyrim.esm   ; SkillTwoHanded5
```

> **NOTE — Sneak line duplicate above:** the raw houseCARL output for Sneak1
> returned `01B276` (SkillSneak1) separately from `01B01F` (SkillSneak2). The
> block above has a paste artifact — use the canonical list: `01B276, 01B01F,
> 01B020, 01B021, 01AFD5` for Sneak 1–5. Codex should verify the full 90
> against `Skill*` type=Book in Skyrim.esm before bulk-adding.

---

### PDV_FLST_FaucetSpellTomes — 93 entries

All `SpellTome*` BOOK records from `Skyrim.esm`. Includes dungeon-unique tomes.

```
; Base game spell tomes (0A26xx–0A27xx range, bulk)
09CD51:Skyrim.esm   ; SpellTomeFlames
09CD52:Skyrim.esm   ; SpellTomeFrostbite
09CD53:Skyrim.esm   ; SpellTomeSparks
09CD54:Skyrim.esm   ; SpellTomeSoulTrap
09E2A7:Skyrim.esm   ; SpellTomeCandlelight
09E2A8:Skyrim.esm   ; SpellTomeOakflesh
09E2A9:Skyrim.esm   ; SpellTomeBoundSword
09E2AA:Skyrim.esm   ; SpellTomeRaiseZombie
09E2AB:Skyrim.esm   ; SpellTomeConjureFamiliar
09E2AC:Skyrim.esm   ; SpellTomeFury
09E2AD:Skyrim.esm   ; SpellTomeCourage
09E2AE:Skyrim.esm   ; SpellTomeLesserWard
09E2AF:Skyrim.esm   ; SpellTomeHealing
0A26E2:Skyrim.esm   ; SpellTomeMagelight
0A26E3:Skyrim.esm   ; SpellTomeStoneflesh
0A26E4:Skyrim.esm   ; SpellTomeIronflesh
0A26E5:Skyrim.esm   ; SpellTomeTelekinesis
0A26E6:Skyrim.esm   ; SpellTomeWaterbreathing
0A26E7:Skyrim.esm   ; SpellTomeDetectLife
0A26E8:Skyrim.esm   ; SpellTomeParalyze
0A26E9:Skyrim.esm   ; SpellTomeEbonyflesh
0A26EA:Skyrim.esm   ; SpellTomeDetectUndead
0A26EB:Skyrim.esm   ; SpellTomeReanimateCorpse
0A26EC:Skyrim.esm   ; SpellTomeConjureFlameAtronach
0A26ED:Skyrim.esm   ; SpellTomeBoundBattleaxe
0A26EE:Skyrim.esm   ; SpellTomeBanishDaedra
0A26EF:Skyrim.esm   ; SpellTomeConjureFrostAtronach
0A26F0:Skyrim.esm   ; SpellTomeConjureStormAtronach
0A26F1:Skyrim.esm   ; SpellTomeBoundBow
0A26F2:Skyrim.esm   ; SpellTomeRevenant
0A26F6:Skyrim.esm   ; SpellTomeCommandDaedra
0A26F7:Skyrim.esm   ; SpellTomeDreadZombie
0A26F8:Skyrim.esm   ; SpellTomeExpelDaedra
0A26F9:Skyrim.esm   ; SpellTomeDeadThrall
0A26FA:Skyrim.esm   ; SpellTomeFlameThrall
0A26FB:Skyrim.esm   ; SpellTomeFrostThrall
0A26FC:Skyrim.esm   ; SpellTomeStormThrall
0A26FD:Skyrim.esm   ; SpellTomeFirebolt
0A26FE:Skyrim.esm   ; SpellTomeIceSpike
0A26FF:Skyrim.esm   ; SpellTomeLightningBolt
0A2700:Skyrim.esm   ; SpellTomeFireRune
0A2701:Skyrim.esm   ; SpellTomeFrostRune
0A2702:Skyrim.esm   ; SpellTomeShockRune
0A2703:Skyrim.esm   ; SpellTomeFlameCloak
0A2704:Skyrim.esm   ; SpellTomeFrostCloak
0A2705:Skyrim.esm   ; SpellTomeLightningCloak
0A2706:Skyrim.esm   ; SpellTomeFireball
0A2707:Skyrim.esm   ; SpellTomeIceStorm
0A2708:Skyrim.esm   ; SpellTomeChainLightning
0A2709:Skyrim.esm   ; SpellTomeWallOfFlames
0A270A:Skyrim.esm   ; SpellTomeWallOfFrost
0A270B:Skyrim.esm   ; SpellTomeWallOfStorms
0A270C:Skyrim.esm   ; SpellTomeFireStorm
0A270D:Skyrim.esm   ; SpellTomeBlizzard
0A270E:Skyrim.esm   ; SpellTomeLightningStorm
0A270F:Skyrim.esm   ; SpellTomeMuffle
0A2711:Skyrim.esm   ; SpellTomeCalm
0A2712:Skyrim.esm   ; SpellTomeFear
0A2713:Skyrim.esm   ; SpellTomeRally
0A2714:Skyrim.esm   ; SpellTomeFrenzy
0A2715:Skyrim.esm   ; SpellTomeInvisibility
0A2717:Skyrim.esm   ; SpellTomePacify
0A2718:Skyrim.esm   ; SpellTomeRout
0A2719:Skyrim.esm   ; SpellTomeMayhem
0A271A:Skyrim.esm   ; SpellTomeHarmony
0A271B:Skyrim.esm   ; SpellTomeCallToArms
0A271C:Skyrim.esm   ; SpellTomeHysteria
0A271D:Skyrim.esm   ; SpellTomeFastHealing
0A271E:Skyrim.esm   ; SpellTomeHealingHands
0A271F:Skyrim.esm   ; SpellTomeTurnLesserUndead
0A2720:Skyrim.esm   ; SpellTomeSteadfastWard
0A2721:Skyrim.esm   ; SpellTomeTurnUndead
0A2722:Skyrim.esm   ; SpellTomeGreaterWard
0A2725:Skyrim.esm   ; SpellTomeRepelLesserUndead
0A2726:Skyrim.esm   ; SpellTomeRepelUndead
0A2727:Skyrim.esm   ; SpellTomeHealOther
0A2728:Skyrim.esm   ; SpellTomeCircleOfProtection
0A2729:Skyrim.esm   ; SpellTomeTurnGreaterUndead
0D2B4E:Skyrim.esm   ; SpellTomeDragonhide
0DD643:Skyrim.esm   ; SpellTomeGrandHealing
0DD646:Skyrim.esm   ; SpellTomeMassParalysis
0DD647:Skyrim.esm   ; SpellTomeBaneOfTheUndead
0F4997:Skyrim.esm   ; DunLabyrinthianSpellTomeEquilibrium
0FDE7B:Skyrim.esm   ; SpellTomeGuardianCircle
0FF7D1:Skyrim.esm   ; SpellTomeClairvoyance
109112:Skyrim.esm   ; SpellTomeTransmuteOreMineral
10F64D:Skyrim.esm   ; SpellTomeCloseWounds
10F7F3:Skyrim.esm   ; SpellTomeIcySpear
10F7F4:Skyrim.esm   ; SpellTomeIncinerate
10F7F5:Skyrim.esm   ; SpellTomeThunderbolt
10FD60:Skyrim.esm   ; SpellTomeConjureDremoraLord
0B45F7:Skyrim.esm   ; dunHighGateSpellTomeFlamingFamiliar
0B3165:Skyrim.esm   ; dunTrevasSpellTomeSpectralArrow
```

---

### PDV_FLST_FaucetRaiseUndeadEffects — 8 core entries (MGEF)

Only the player-castable reanimate effects. Exclude FX/AI-internal ones.

```
016B4B:Skyrim.esm   ; ReanimateFFTargetActor0      (Raise Zombie)
016C0F:Skyrim.esm   ; ReanimateFFTargetActor25     (Reanimate Corpse)
016C3B:Skyrim.esm   ; ReanimateFFTargetActor50     (Revenant)
016C3D:Skyrim.esm   ; ReanimateFFTargetActor75     (Dread Zombie)
07E8E0:Skyrim.esm   ; ReanimateThrallFFAimed       (Dead Thrall)
096D0B:Skyrim.esm   ; ReanimateFFAimed25
096D0C:Skyrim.esm   ; ReanimateFFAimed50
096D0D:Skyrim.esm   ; ReanimateFFAimed75
```

Exclude from this list (not player-castable / AI-only):
- `10F7A4` FXRitualReanimateBodyHolder — FX only
- `10EAD9` ReanimateSecondayTargetActor — secondary AI effect
- `0F52AB` ReanimateSecondayFFAimed — secondary AI effect
- `0E152A` dunReanimateSelfEffect — dungeon-specific NPC only
- `0CAB63` PerkDarkSoulsReanimateEffect — Dark Souls perk (NPC)
- `0B3CA0` SpellTomeReanimateFFAimed0 — this is a BOOK, not an MGEF; wrong type
- `0DD026` DA10ReanimateEffect — Molag Bal's unique NPC reanimate, not player

---

### PDV_FLST_FaucetDaedricArtifacts — 18 entries + keyword note

**Strong recommendation: use the `DaedricArtifact` keyword instead of this
FormList.** The keyword `0A8668:Skyrim.esm` (EditorID `DaedricArtifact`) is
already on every vanilla Daedric Artifact; checking `HasKeyword` in
`PDV_PlayerEvents.OnItemAdded` is future-proof and requires no list maintenance.

If the FormList architecture must be kept, populate with:

```
01A332:Skyrim.esm   ; DA04OghmaInfinium          (Hermaeus Mora)
02AC60:Skyrim.esm   ; DA05HircinesRing            (Hircine — Savior's Hide alt)
02AC61:Skyrim.esm   ; DA05SaviorsHide             (Hircine — Ring alt)
02ACD2:Skyrim.esm   ; DA06Volendrung              (Malacath)
02C37B:Skyrim.esm   ; DA11RingofNamira            (Namira)
035066:Skyrim.esm   ; DA16SkullofCorruption       (Vaermina)
03A070:Skyrim.esm   ; TG08SkeletonKey             (Nocturnal)
045F96:Skyrim.esm   ; DA13Spellbreaker            (Peryite)
04A38F:Skyrim.esm   ; DA08EbonyBlade              (Mephala)
04E4EE:Skyrim.esm   ; DA09Dawnbreaker             (Meridia)
052794:Skyrim.esm   ; DA02Armor                   (Clavicus Vile — Masque)
063B27:Skyrim.esm   ; DA01SoulGemAzurasStar       (Azura — Azura's Star)
063B29:Skyrim.esm   ; DA01SoulGemBlackStar        (Azura — Black Star)
0240D2:Skyrim.esm   ; DA07MehrunesRazor           (Mehrunes Dagon)
0233E3:Skyrim.esm   ; DA10MaceofMolagBal          (Molag Bal)
01CB36:Skyrim.esm   ; DA14SanguineRose            (Sanguine)
02AC6F:Skyrim.esm   ; DA15Wabbajack               (Sheogorath)
0F82FE:Skyrim.esm   ; DA05HircinesRingCursed      (Hircine — cursed form; borderline)
```

> **Missing: Boethiah's Ebony Mail.** The `DaedricArtifact` keyword query did
> not return it — either it lacks the keyword or it lives under a different
> FormID not captured by the reverse-ref scan. Codex should confirm
> `000F6D1A:Skyrim.esm` (Ebony Mail) carries `DaedricArtifact` keyword; if not,
> add it manually to the FormList. This is also why the keyword approach is
> safer — it catches whatever the game already tags, and Codex can patch the
> keyword onto any missed artifact.

---

## Additional wiring gaps (not FormList-related)

### Event 333 — Cook: no marker fired

The user cooked at a station and no `[PDV] EventBus: event 333` appeared.
Enchant (331) and brew (332) fired fine from the same craft-node route.

Suspect causes (Codex to investigate):
1. The cookpot craft event may not raise the Story Manager `CraftItem` node
   that `PDV_ActionRouter` listens to, OR
2. The `CraftingCookpot` keyword check in `PDV_ActionRouter.psc` is missing or
   the cookpot used lacked that keyword in the load order.

Check: `PDV_ActionRouter` — find where `EVT_CRAFT_COOK = 333` is referenced and
confirm the keyword gate (`CraftingCookpot`) is correct for the cookpot FormID
the player used. Log `DebugLevel >= 2` during a cook attempt to see if the
router fires at all or fires with a different classification.

### Event 362 — Steal: no detection handler (by design, deferred)

`EVT_STEAL_ITEM = 362` is authored in the CSV but Codex flagged as MODERATE
difficulty (requires `OnItemAdded` + stolen-flag heuristic). No handler exists.
This is a known gap, not a regression.

### Event 350 — Heal friendly: no detection handler (deferred)

`EVT_HEAL_FRIENDLY = 350` is in the CSV. No MGEF-cast detection wired yet.

---

## Acceptance criteria

After populating the FormLists:

1. Read a skill book → Papyrus log shows `[PDV] EventBus: <deity> event 340 delta <x>`
2. Read a spell tome → log shows `event 341`
3. Raise undead → log shows `event 365`
4. Pick up a Daedric Artifact → log shows `event 368`
5. None of the above fire for non-native deities (race-gate still holds)
6. Anti-farm: reading two skill books same dawn cycle — second fires but capped
   (delta 0 after cap exhausted); debug level 3 shows cap message

---

## Authoring method

Preferred: `housecarl_bulk_apply` on each FLST FormID with the Items array
fully specified. These are pure FormList additions — idempotent, no script
changes needed. Alternatively, CK drag-in from the Object Window is fine.

No Papyrus recompile required. No ESP version bump needed beyond the list edit.
