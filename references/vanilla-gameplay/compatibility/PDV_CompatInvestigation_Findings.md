# PDV Compatibility Investigation — Findings (I-1 / I-2 / I-3)

Status: investigation evidence for the V1 compatibility bake-in plan
(`.claude/plans/i-want-you-to-keen-phoenix.md`). Read-only record-level evidence
gathered via the houseCARL Mutagen bridge against three installed MO2 instances
(Anvil "Devotion Dev", ARR, DoD) plus on-disk script/config reads. Date: 2026-06-08.

These are technical findings, not public support claims.

---

## I-1 — Custom-race frameworks (DECISIVE; both backends confirmed)

The two frameworks the owner targets exist in the reference lists and use
**different, both-supportable** mechanisms. A custom race tagged by either resolves
cleanly to a vanilla race index.

### Backend A — RaceCompatibility (TMPhoenix) — installed in ARR (`RaceCompatibility.esm`)
Defines exactly **10 `ActorProxy<Vanilla>` KYWD records** — the vanilla-equivalence tags:

| Keyword EditorID | FormID (RaceCompatibility.esm) | → race index |
|---|---|---|
| ActorProxyNord | `001D93` | 0 Nord |
| ActorProxyImperial | `001D90` | 1 Imperial |
| ActorProxyBreton | `001D8A` | 2 Breton |
| ActorProxyHighElf | `001D8E` | 3 Altmer |
| ActorProxyWoodElf | `001D92` | 4 Bosmer |
| ActorProxyDarkElf | `001D8F` | 5 Dunmer |
| ActorProxyKhajiit | `001D8C` | 6 Khajiit |
| ActorProxyArgonian | `001D8B` | 7 Argonian |
| ActorProxyOrc | `001D8D` | 8 Orsimer |
| ActorProxyRedguard | `001D91` | 9 Redguard |

- **PDV read:** `race.HasKeyword(GetFormFromFile(0x001D93,"RaceCompatibility.esm"))`, one per
  index. Covers **all 10** races including beast races. Stable across versions.
- Registry FormLists `PlayableRaceList` (`000D62`) / `PlayableVampireList` (`000D63`) list the
  compliant races (overridden by each custom-race mod, e.g. HalfKhajiit.esp) — secondary signal.
- **Soft-detect:** `Game.GetModByName("RaceCompatibility.esm") != 255`.

### Backend B — Race Blood Test (`yzx_dnatest.dll`, author YZX) — installed in DoD
An **SKSE DLL that spoofs/translates a custom race to its vanilla equivalent**
("CurrentRaceTranslation"). No plugin record; config at
`mods/Race Blood Test/SKSE/Plugins/YZX/*.yzx`. Key facts:
- It ships per-body-framework translation tables, including a **UBE-specific** one
  (`CurrentRaceTranslation_z_UBE.yzx`) and a generic custom-race one (`_z_COR.yzx`).
- **UBE race EditorIDs are self-describing:** `00UBE_BretonRace`, `00UBE_ImperialRace`,
  `00UBE_NordRace`, `00UBE_RedguardRace`, `00UBE_DarkElfRace`, `00UBE_HighElfRace`,
  `00UBE_WoodElfRace`, `00UBE_OrcRace`. **No Khajiit/Argonian** (UBE is human/elf only).
  The vanilla equivalent is literally the suffix.
- Settings show `enable_race_spoofing` / `track_race_change` / `track_vampire_effect`. Whether
  the spoof reaches Papyrus `Actor.GetRace()` is the **one runtime unknown** (verify in-game).

### Ohmes-Raht / Half-Khajiit V1 evidence (ARR + DoD)

Record readback on 2026-06-20 checked the installed ARR and DoD `HalfKhajiit.esp`
copies plus DoD's `PATCH - Half-Khajiit\HalfKhajiit.esp` copy through the
Mutagen bridge. All three expose exactly two `RACE` records:

| Source | RACE records |
|---|---|
| ARR `Half-Khajiit-Race (Ohmes-Raht)\HalfKhajiit.esp` | `HalfKhajiitRace` `03322B`, `HalfKhajiitRaceVampire` `05693A` |
| DoD `Half-Khajiit-Race (Ohmes-Raht)\HalfKhajiit.esp` | `HalfKhajiitRace` `03322B`, `HalfKhajiitRaceVampire` `05693A` |
| DoD `PATCH - Half-Khajiit\HalfKhajiit.esp` | `HalfKhajiitRace` `03322B`, `HalfKhajiitRaceVampire` `05693A` |

No `HalfKhajiitWerewolf` RACE record is present in those current local plugins.
PDV therefore ships only the normal/vampire entries in `PDV_RaceMap.json`, both
mapped to Khajiit index `6`. If a future Half-Khajiit werewolf or beast-form
race appears, it belongs in `PDV_TemporaryRaceMap.json` under
`temporaryRaceForms` so origin capture defers while transformed; it should not
be mapped as a permanent Khajiit cultural origin.

**Implication for PDV (P-A):**
- Primary heuristic backend = **RaceCompatibility ActorProxy keywords** (clean, all 10 races).
- UBE handled by **self-describing EditorID / FormID** — seed `PDV_RaceMap.json` with the
  `00UBE_*` races (or EditorID-suffix match). po3 `GetFormEditorID` would enable suffix-match
  without seeding, but is **not required** (FormID seeding works without it).
- Ohmes-Raht / Half-Khajiit ships as an explicit fallback map:
  `0x03322B|HalfKhajiit.esp -> 6` and `0x05693A|HalfKhajiit.esp -> 6`.
- If Race Blood Test's spoof DOES reach `GetRace()`, PDV's existing matcher already resolves
  UBE → vanilla with zero work; the resolver is the safety net for when it doesn't. Verify once.
- Note: UBE's *races* plugin is optional (in DoD, UBE is used as a body only; the player is a
  vanilla race). When UBE-as-body-only, PDV already works.

---

## I-2 — Survival mods' readable state (mostly GREEN)

"Context only" needs a readable severity signal per mod. Confirmed surfaces:

| Mod | Plugin | Readability | Key readable forms |
|---|---|---|---|
| **Survival Mode (CC/Improved)** | `ccqdrsse001-survivalmode.esl` (+ `SurvivalModeImproved.esp` overrides) | **GREEN** — already in Anvil dev list | `Survival_HungerNeedValue` `00081A`, `Survival_ColdNeedValue` `00081B`, `Survival_ExhaustionNeedValue` `000816`, enable `Survival_ModeEnabled` `000826`; stage thresholds `Survival_HungerStage1-5Value` |
| **SunHelm** | `SunHelmSurvival.esp` (ARR) | **GREEN** | global floats `_SHCurrentHungerLevel` `00EAAE`, `_SHCurrentThirstLevel` `05C472`, `_SHCurrentFatigueLevel` `021E3F`, `_SHCurrentColdLevel` `6A13C5`; enable `_SHEnabled` `02EB63` / `_SHModShouldBeEnabled`; context `_SHIsNearHeatSource`, `_SHIsInFreezingWater`, `_SHAmbientTemperature` |
| **Last Seed** | `Last Seed.esp` (DoD) | **GREEN** | public `LastSeedAPI.psc` globals `_Seed_HungerLevel`, `_Seed_ThirstLevel`, `_Seed_FatigueLevel`, `_Seed_VitalityLevel`, `_Seed_AlcoholLevel`; running flag `LastSeedRunning`, `_Seed_APIVersion` |
| **iNeed** | `iNeed.esp` (general target; not in ARR/DoD) | GREEN (expected) | global stage vars — confirm at build |
| **Frostfall** | `Frostfall.esp` (ARR/DoD) | **AMBER** | ships **no loose source** and no simple needs global; exposure lives in its quest. Read via active magic-effect/keyword threshold or the Campfire/Frostfall SKI API |
| **Campfire** | `Campfire.esm` (ARR/DoD) | **AMBER** | "sheltered/near-fire" state via keyword/quest, not a scalar global |

**Implication for PDV (P-B):** the adapter base is justified — three majors (incl. the one
already in the dev list) are trivial global reads; Frostfall/Campfire need effect/keyword reads.
Unreadable → severity 0 keeps any adapter safe. Exact iNeed/Frostfall forms are build-time detail.

---

## I-3 — Wintersun (takeover is LARGE; runtime-strip is non-trivial)

`Wintersun - Faiths of Skyrim.esp` (DoD). Surface is big:
- **464 SPEL** records: per-deity `WSN_<Deity>_Boon1/2_Spell_Ab`, `WSN_<Deity>_Tenets_Spell_Ab`,
  `WSN_AltarBlessing_*`, proc spells. (Some overridden by `Wintersun - Tweaks and Enhancements.esp`.)
- **103 ACTI** records: per-deity `WSN_..._Activator_PrayerActivator` (prayer points) and
  `WSN_Altar_<Deity>_Activator` (shrine altars) — the reusable assets + the prayer hooks.

**Key correction to the plan's P-D assumption:** there is **no single "religion ability"** to
strip. Devotion is driven by a quest-based favor system plus **per-deity Tenets/Boon abilities**
added on worship. A clean runtime suppression would have to strip whichever Tenets/Boon ability
the player currently holds and re-strip on a tick — fragile.

**Recommendation:** treat Wintersun as **replacement-first** (the existing documented policy) for
V1 — i.e. the user removes Wintersun's devotion driver — and deliver the **asset-reuse ESL patch
(P-E)** that overrides only Wintersun's own `..._Activator_PrayerActivator` / `WSN_Altar_*`
activator records to fire PDV's prayer/scoring path while keeping its meshes/placements. The
"overtake gameplay, reuse assets" directive is genuinely a P-E (record-patch) effort, larger than
a runtime strip. `Survival_ShrineGoldOfferingAmount` (Survival Mode) is a separate shrine-offering
interaction to keep in mind when PDV owns shrine routing.

---

## Net effect on the workload

- **P-A (custom race):** confirmed **low-risk / high-value**. Two clean backends; po3 optional;
  one in-game check (does Race Blood Test's spoof reach `GetRace()`).
- **P-B (survival context):** confirmed **low-risk**. GREEN globals for 3 majors incl. the
  in-list Survival Mode; AMBER (effect/keyword) for Frostfall/Campfire.
- **P-D/P-E (Wintersun):** **re-scope** — runtime strip is fragile; lead with replacement-first +
  the asset-reuse ESL patch. This is the largest single item and the main sizing change vs. the plan.
