---
title: PDV Quest Mod Patches -- ARR review + packaging feedback (draft to Whispa's AI)
date: 2026-08-06
tags: [draft, devotion, pdv, arr, packaging, outbound]
---

> [!info] Draft -- not sent
> Written for the agent working on Devotion (PDV). Reviewed archive:
> `PDV_QuestModPatches_FOMOD_ARR25_20260806-test.zip` (1,894,108 bytes,
> 2026-08-06), diffed against Devotion and Devotion - PatchHub as installed in
> ARR. Every assertion verified -- see the log at the bottom.
>
> **Aaron's ask, which the message is built around:** the end state is that
> *neither* Devotion nor the patch hub contains anything ARR-specific, and the
> hub is fully modular -- one conditional option per source mod.

---

## Draft message

**Subject: Devotion + patch hub -- packaging direction from the ARR side**

I went through the 2026-08-06 test archive and diffed it against what Devotion
and Devotion - PatchHub currently install in ARR. Sending now rather than after
you finish the update, since it's a packaging question and cheaper to act on
before things settle.

The patch content isn't in question -- the channel model, the per-mod conditional
gating, and the ESPFE plugins all look sound. This is about where content lives.

### The end state we'd like to see

Two properties, and everything below is just the gap between them and the
current package:

1. **Devotion contains nothing list-specific.** Base mod covers vanilla, DLC and
   CC only. No file named after a modlist, no third-party mod's reaction data.
2. **The patch hub is fully modular** -- one conditional option per source mod,
   each gated on that mod's plugin, each self-contained. No list-specific lane,
   no combined plugin, no "Authoria" anywhere.

ARR then installs from the same hub every other user does, and we ask nothing
bespoke of you. Anything genuinely ARR-only becomes our job to carry, and having
looked, we don't think there is anything.

### Gap 1 -- `PDV_QuestReactionMatrix_ARR.json`

This is the big one, and it's the clearest case for property 1.

That file ships inside **Devotion itself**, not in a patch. Its
`questWatchPluginsCsv` names 26 plugins. Five are core -- `Skyrim.esm`, the three
DLC, `ccbgssse020-graycowl.esl`, which is exactly the set the main
`PDV_QuestReactionMatrix.json` covers. The other 21 are third-party mods:

```
BardsRebornStudentofSong  BecomeABard  CH_IMBMDialougeAddon  DAc0da
Darbalag  EbonyBladeCurse  ForgottenCity  Forsworn Conspiracy QE
Glenmoril  Hunt for the Spectre  MrissiTailOfTroubles  Olenveld
Siege at Icemoth  Sithis Mod  Skyrim Extended Cut - Saints and Seducers
TasteOfDeath_Addon_Dialogue  The Heart Of Dibella - QE  TheGiftofSaturalia
Unslaad  Vigilant  Wyrmstooth
+ ccasvsse001-almsivi, ccbgssse067-daedinv, ccmtysse001-knightsofthenine
```

None of those is ARR-exclusive; they're all standalone Nexus mods. So a file
carrying 21 mods' worth of patch content, named after a modlist, is installed
unconditionally by the base mod for every Devotion user regardless of what they
actually run.

And the fix needs no new format. All three file types in the package declare the
same `"schema": "pdv-quest-reaction-matrix.v1"` -- the per-mod channel files are
already just this matrix scoped to one plugin. `PDV_QuestReactionMatrix_ARR.json`
is 21 channels that never got split. Splitting it into per-mod channels gated on
their source plugins satisfies both properties at once and deletes the file.

### Gap 2 -- the same quests are now watched twice

Because that legacy bundle is still shipping, ten of the new channels re-declare
quest watches it already carries. Matching on `(questWatchFormId, plugin)` pairs,
**17 pairs are watched by both sources**:

| Channel | Duplicated pairs | Of the channel's total |
|---|---|---|
| `PDV_QRM_Wyrmstooth` | 2 | of 6 |
| `PDV_QRM_GiftOfSaturalia` | 5 | of 5 -- fully redundant |
| `PDV_QRM_Mrissi` | 2 | of 2 -- fully redundant |
| `PDV_QRM_SiegeAtIcemoth` | 2 | of 2 -- fully redundant |
| `PDV_QRM_CallingTheWatchmaker` | 1 | of 1 -- fully redundant |
| `PDV_QRM_HuntForSpectre` | 1 | of 1 -- fully redundant |
| `PDV_QRM_TasteOfDeathAddon` | 1 | of 1 -- fully redundant |
| `PDV_QRM_CCTheCause` | 1 | of 1 -- fully redundant |
| `PDV_QRM_CCGhostsTribunal` | 1 | of 1 -- fully redundant |
| `PDV_QRM_CCDivineCrusader` | 1 | of 1 -- fully redundant |

We don't know how your loader resolves a quest watched from two sources -- it may
dedupe cleanly, in which case this is only dead weight. You'd know. Either way it
resolves itself once the legacy bundle is decomposed.

### Gap 3 -- core updates riding a list-specific lane

`plugins\authoria` is referenced exactly once in `fomod/ModuleConfig.xml` (line
50, the all-in-one option). Three of the four things it uniquely delivers are
**updates to files base Devotion already ships**:

| Payload | Base Devotion | This archive |
|---|---|---|
| `PDV_QuestReactionMatrix.json` | 614,651 | 709,200 |
| `PDV_QuestReactionMatrix_ARR.json` | 133,490 | 191,141 |
| `PDV__ManagerQuest.pex` (+ `PlayerEvents`, `EventBus`) | 923,022 | 957,794 |
| `PDV_GreenPact_KID.ini` | 2,397 | 1,219 |

A user on any other load order installs the new channels and runs them against
the older scripts and matrix Devotion already installed -- silently, no version
warning. The only path to the updated runtime is ticking *Thieves Guild
Alternative Endings*, because `common\TGAlternativeEndings\Scripts\` carries
byte-identical copies of all three core scripts (MD5-verified). A core update
travelling as a passenger on an unrelated quest patch.

These belong in Devotion's own package, and the `TGAlternativeEndings` duplicate
should go.

### Gap 4 -- shrine prayers and AFDI are mod-gated, not list-gated

Reading `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`, 10 of the 11 swap sources are
base forms from **`man_DaedricShrines.esp`** -- Daedric Shrines - All in One
(Nexus 78772, ~3.5M downloads); the eleventh is `0x0C5999~Skyrim.esm`. So the
real dependency is a popular standalone mod, exactly like every quest patch in
the hub. Same for the AFDI observer, whose dependency is
`Aetherium Forge Destroys Items.esp` (Nexus 114021).

Both want conditional options gated on those plugins. Neither is ARR content.

### Gap 5 -- the combined plugin has no unique quest records

Record counts read from the ESP binaries:

```
PDV_AuthoriaARR_Combined.esp    ACTI 11 - DIAL 9 - INFO 9 - QUST 3   = 32
PDV_Patch_WarsFolly.esp                   DIAL 6 -         QUST 1
PDV_Patch_OnceWeWereHere.esp              DIAL 2 -         QUST 1
PDV_Patch_SlaysManyBeasts.esp             DIAL 1 -         QUST 1
                                  individual total: DIAL 9 - QUST 3
```

The three individual patches sum to exactly the combined plugin's DIAL/QUST
content. Its only unique records are the 11 shrine ACTIs -- new records
(`0x800`-`0x80A`, ESL range), not overrides, carrying no master dependency on
the shrine mod because BOS binds them at runtime. They lift cleanly into their
own ESPFE mastering `Skyrim.esm` + `Devotion.esp`.

Masters, from the TES4 headers:

```
PDV_AuthoriaARR_Combined.esp   ESL  Skyrim.esm, Slays-Many-Beasts Quest Mod.esp,
                                    War's Folly.esp, Once We Were Here - Quest Mod.esp,
                                    Devotion.esp
PDV_Patch_WarsFolly.esp        ESL  Skyrim.esm, Update.esm, War's Folly.esp
PDV_Patch_OnceWeWereHere.esp   ESL  Skyrim.esm, Update.esm, Once We Were Here - Quest Mod.esp
PDV_Patch_SlaysManyBeasts.esp  ESL  Skyrim.esm, Update.esm, Slays-Many-Beasts Quest Mod.esp
```

All four are already ESPFE (`0x200`), so "fewer plugin slots" isn't an argument
for combining -- and a plugin mastering three quest mods fails wholesale if a list
drops any one of them, where four narrowly-mastered ESPFEs degrade one at a time.

### Getting from here to there

1. **Decompose `PDV_QuestReactionMatrix_ARR.json`** into per-mod channels gated
   on their source plugins; fold anything genuinely vanilla/DLC/CC into
   `PDV_QuestReactionMatrix.json`; delete the file. Resolves Gaps 1 and 2 and
   removes the modlist name from the base mod.
2. **Core updates ship in Devotion's own package** -- scripts, core matrix, Green
   Pact KID. Drop the `common\TGAlternativeEndings\Scripts\` duplicate.
3. **Shrine prayers -> conditional option** gated on `man_DaedricShrines.esp`, own
   ESPFE.
4. **AFDI observer -> conditional option** gated on `Aetherium Forge Destroys Items.esp`.
5. **Drop the all-in-one lane and the combined plugin.** With 1-4 done the
   individual lane is strictly more capable than the combined one on every load
   order, ARR included.

On the worry that the all-in-one guarantees ARR one tested configuration:
Wabbajack reproduces the resolved file set directly rather than replaying the
FOMOD, so ARR gets a fixed, reproducible install from the modular lane at no cost
to you.

### Three smaller things

- **The BOS ini hard-codes `PDV_AuthoriaARR_Combined.esp` as the swap target.**
  Rename or split that plugin without moving the ini in lockstep and the shrine
  feature silently no-ops, no error. Worth a docs note whatever you decide.
- **The new `PDV_GreenPact_KID.ini` drops the deployed file's comment block.**
  The rules are a strict superset -- the deployed Meat line is retained verbatim,
  three added -- but the reasoning is gone: why mod-added food is tagged via KID
  instead of `PDV_FLST_GreenPact_*` (the missing-master argument), and why
  Potion-type filters must match by name. That's what stops the next person
  undoing it.
- **Three channels can never resolve on ARR.** 31 of the 34 FOMOD dependency
  plugins are active in our shipped Main profile; the absent three are Creation
  Club -- `ccbgssse067-daedinv`, `ccasvsse001-almsivi`,
  `ccmtysse001-knightsofthenine` -- and ARR ships no CC. Fine if an unresolvable
  channel is a free no-op; worth confirming it costs nothing at StorageUtil load.

---

## Verification log (not part of the message)

Assertions **corrected** during checking are marked WRONG->CORRECT.

| Claim | How verified |
|---|---|
| `plugins\authoria` referenced once, line 50 | regex count over `ModuleConfig.xml` = 1 |
| 34 patch options, 34 `fileDependency`, 2 install steps | `ModuleConfig.xml` parsed as XML |
| ESP masters + ESL flags | TES4 header parse, all four ESPs |
| 32 records = 11 ACTI + 9 DIAL + 9 INFO + 3 QUST | recursive GRUP walk; matches her doc's "21 quest/dialogue + 11 ACTI" |
| Individual patches sum to combined's DIAL/QUST | same walk across all four ESPs |
| ACTIs are new records, not overrides | FormIDs `0x05000800`-`0x0500080A` = plugin-local ESL range |
| Shrine swap sources | `PDV_AuthoriaARR_ShrinePrayer_SWAP.ini`: 10x `man_DaedricShrines.esp`, 1x `Skyrim.esm` |
| `man_DaedricShrines.esp` = Daedric Shrines AIO | Nexus 78772; active in ARR Main profile |
| AFDI standalone + present in ARR | Nexus 114021; `aetherium forge destroys items.esp` active |
| Base-vs-archive file sizes | direct stat of both copies |
| Core matrix is genuinely universal | `questWatchPluginsCsv` = Skyrim + 3 DLC + graycowl only |
| ARR matrix carries 21 third-party mods | `questWatchPluginsCsv`, 26 plugins, minus the 5 core |
| Identical schema across matrix and channels | `"schema": "pdv-quest-reaction-matrix.v1"` in all three |
| 17 duplicated watch pairs across 10 channels | zipped `questWatchFormIdsCsv` <-> `questWatchPluginsCsv` into pairs, intersected |
| 31/34 deps active in ARR | shipped Main profile `plugins.txt` |
| WRONG->CORRECT first duplication count (12 channels) | **Wrong method.** Matched bare FormIDs, which collide across plugins -- `OnceWeWereHere` and `ForswornConspiracyQE` were false positives. Re-run on `(id, plugin)` pairs: 10 channels, 17 pairs. |
| WRONG->CORRECT "`plugins\authoria` is the sole path for the scripts" | **False.** `common\TGAlternativeEndings\Scripts\` holds byte-identical copies (MD5, all six files). Sole-path holds for matrix, KID, BOS ini only. |
| WRONG->CORRECT "the hub ships no core scripts or matrix" | **False.** Base Devotion ships both, plus the ARR matrix and the Green Pact KID. The archive's copies are updates. |
| WRONG->CORRECT "the 11 ACTIs are vanilla shrine overrides" | **False.** New records; BOS swaps them over `man_DaedricShrines.esp` base forms. |
| WRONG->CORRECT "Green Pact KID is list-flavoured, split per source mod" | **False premise.** Already a base-mod file; new one is a strict rule superset. |
| WRONG->CORRECT archive size "1.85 MB" | 1,894,108 bytes = 1.81 MB |

**Deliberately not claimed:** whether double-watched quests actually double-route
(no visibility into loader dedup -- the message says so), whether her runtime
behaviour is correct, or whether the reaction content is good. Scope is packaging.

**Baseline in ARR today** (her own work, and she's mid-update -- recorded so the
diff is checkable, not to be explained back to her): `Devotion - PatchHub` ships
`PDV_Patch_Authoria_QuestMods.esp` (DIAL 9 - QUST 3 -- the new combined plugin
minus the ACTIs), 10 channel JSONs, the TIF fragments. Base `Devotion` ships the
core scripts, both matrix JSONs, and the Green Pact KID.
